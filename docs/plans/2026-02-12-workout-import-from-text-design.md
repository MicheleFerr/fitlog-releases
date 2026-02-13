# Importa Scheda da Testo/Foto - Design Document

**Data**: 2026-02-12
**Status**: Draft - In attesa approvazione
**Feature**: Auto-generazione template da testo libero o foto

---

## Problema

Gli utenti hanno schede palestra in formato testuale (WhatsApp, note, appunti) o cartaceo (foto della scheda dal personal trainer). Attualmente devono ricreare manualmente ogni esercizio nell'app, un processo tedioso che scoraggia l'adozione.

## Soluzione

Una feature che permette di incollare testo o scattare una foto di una scheda, e l'app la converte automaticamente in uno o piu template strutturati con esercizi matchati al database.

---

## Decisioni di Design

| Decisione | Scelta | Alternativa scartata | Motivo |
|-----------|--------|---------------------|--------|
| Input method | Testo + Foto via AI | OCR on-device (ML Kit) | Un unico AI call fa OCR + parsing. Zero package extra. |
| AI backend | OpenRouter (modelli free) | Apple Intelligence / On-device ML | Cross-platform, gratis, gia integrato per AI Coach |
| Multi-day | Template separati | Template unico multi-day | Compatibile con struttura `WorkoutTemplate` esistente |
| Exercise matching | Fuzzy match DB + picker manuale | Nomi liberi | Collegamento a statistiche/history + UX controllata |
| UI placement | Opzione nel CreateTemplateModal | Screen dedicata / FAB | Minimo impatto UI, discovery naturale |
| Feature module | `workout_import/` separato | Dentro `workout/` | Pattern codebase: feature indipendenti |

---

## Architettura

### Struttura File

```
lib/features/workout_import/
├── domain/
│   ├── entities/
│   │   ├── parsed_workout.dart              # Freezed: risultato completo del parsing
│   │   └── parsed_exercise_line.dart        # Freezed: singola riga esercizio parsata
│   └── services/
│       └── workout_import_service.dart      # Abstract interface
├── data/
│   ├── services/
│   │   └── workout_import_service_impl.dart # Logica AI parsing + validation
│   └── datasources/
│       └── workout_import_ai_client.dart    # OpenRouter API calls (riusa pattern OpenRouterHttpClient)
└── presentation/
    ├── providers/
    │   └── workout_import_provider.dart     # @riverpod con keepAlive + _isImporting
    ├── screens/
    │   └── workout_import_screen.dart       # Schermata fullscreen di import
    └── widgets/
        ├── text_input_section.dart          # Tab testo + tab foto
        ├── parsed_exercise_card.dart        # Card singolo esercizio con match status
        └── exercise_match_picker.dart       # Picker per scegliere esercizio dal DB
```

### Dipendenze tra Layer

```
presentation/
  └── providers/workout_import_provider.dart
       ├── reads → data/services/workout_import_service_impl.dart
       ├── reads → exercise_database/domain/services/exercise_fuzzy_matcher.dart (ESISTENTE)
       └── reads → workout/presentation/providers/workout_template_provider.dart (ESISTENTE)

data/
  └── services/workout_import_service_impl.dart
       ├── uses → data/datasources/workout_import_ai_client.dart
       └── uses → domain/entities/parsed_workout.dart

  └── datasources/workout_import_ai_client.dart
       └── uses → ai_coach/data/datasources/openrouter_http_client.dart (ESISTENTE, riuso)
```

---

## Modelli AI (OpenRouter - Gratis)

| Modello | Uso | Capacita |
|---------|-----|----------|
| `meta-llama/llama-3.3-70b-instruct:free` | **Parsing testo** | Eccellente su italiano, gia usato per AI Coach |
| `meta-llama/llama-4-maverick:free` | **Parsing foto** (vision) | Multimodale nativo, legge immagini |
| `meta-llama/llama-3.2-11b-vision-instruct:free` | Fallback vision | Piu leggero, se Maverick non disponibile |

**Strategia**:
- Input testo -> Llama 3.3 70B (solo testo, piu forte)
- Input foto -> Llama 4 Maverick (vision, legge immagini direttamente)
- Nessun OCR on-device necessario

---

## Entities (Domain Layer)

### ParsedWorkout

```dart
@freezed
class ParsedWorkout with _$ParsedWorkout {
  const factory ParsedWorkout({
    required List<ParsedDay> days,
    String? rawText,              // Testo originale per debug
    @Default(false) bool hasMultipleDays,
  }) = _ParsedWorkout;
}

@freezed
class ParsedDay with _$ParsedDay {
  const factory ParsedDay({
    required String name,                        // "Giorno 1 - Petto/Bicipiti"
    required List<ParsedExerciseLine> exercises,
  }) = _ParsedDay;
}
```

### ParsedExerciseLine

```dart
@freezed
class ParsedExerciseLine with _$ParsedExerciseLine {
  const factory ParsedExerciseLine({
    required String rawName,          // Nome originale dal testo ("Chest press")
    required List<ParsedSet> sets,    // Serie parsate
    int? restSeconds,                 // Recupero in secondi (se trovato)
    String? muscleGroup,              // Gruppo muscolare (se trovato dal contesto)
    String? notes,                    // Note aggiuntive

    // Fuzzy match result (populated dopo matching)
    String? matchedExerciseId,        // ID esercizio nel DB
    String? matchedExerciseName,      // Nome esercizio matchato
    double? matchConfidence,          // 0.0 - 1.0
    ExerciseCategory? matchedCategory,
  }) = _ParsedExerciseLine;
}

@freezed
class ParsedSet with _$ParsedSet {
  const factory ParsedSet({
    int? reps,           // Ripetizioni target (null per "Max")
    bool isMaxReps,      // true per "3xMax"
    double? weight,      // Peso (se specificato)
  }) = _ParsedSet;
}
```

---

## AI Prompt Design

### System Prompt (Testo)

```
Sei un parser esperto di schede palestra italiane.
Analizza il testo e restituisci SOLO JSON valido, senza commenti.

FORMATI RICONOSCIUTI:
- "3x12" → 3 serie da 12 reps
- "10-10-8-8" → 4 serie piramidale (10, 10, 8, 8 reps)
- "3xMax" → 3 serie a cedimento
- "1'" o "1 min" o "60s" → recupero 60 secondi
- "1'30" o "90s" → recupero 90 secondi
- "2'" o "2 min" → recupero 120 secondi
- Headers come "PETTORALI", "DORSALI", "1 giorno" → separatori di sezioni

REGOLE:
1. Se trovi "1 giorno", "2 giorno" etc → separa in days distinti
2. Se trovi "PETTORALI", "BICIPITI" etc → usa come muscle_group
3. Se non c'e' separazione giorni → tutto in un unico day
4. Il campo "name" dell'esercizio deve essere il nome ESATTO dal testo
5. rest_seconds = null se non specificato nel testo
6. Per "Max" o "cedimento" → reps: null, is_max_reps: true

OUTPUT FORMAT (JSON):
```

### Few-Shot Example nel Prompt

```json
{
  "days": [
    {
      "name": "Giorno 1",
      "exercises": [
        {
          "name": "Chest press",
          "sets": [{"reps": 15}, {"reps": 15}, {"reps": 15}],
          "rest_seconds": 60,
          "muscle_group": "chest",
          "notes": null
        },
        {
          "name": "panca piana con Manubri",
          "sets": [{"reps": 10}, {"reps": 10}, {"reps": 8}, {"reps": 8}],
          "rest_seconds": null,
          "muscle_group": "chest",
          "notes": null
        },
        {
          "name": "Trazioni",
          "sets": [{"reps": null, "is_max_reps": true}, {"reps": null, "is_max_reps": true}, {"reps": null, "is_max_reps": true}],
          "rest_seconds": null,
          "muscle_group": "back",
          "notes": null
        }
      ]
    }
  ]
}
```

### System Prompt (Vision/Foto)

Stesso prompt di sopra, con aggiunta:

```
Stai analizzando una FOTO di una scheda palestra.
Leggi tutto il testo visibile, incluse tabelle e colonne.
Per le tabelle, collega ogni riga esercizio alle colonne SERIE, REC, CARICO.
Ignora dati nelle colonne CARICO (sono pesi personali, non servono nel template).
```

---

## Pipeline di Parsing

```
1. INPUT
   ├── Testo incollato → usa direttamente
   └── Foto scattata/selezionata → converti in base64

2. AI CALL
   ├── Testo → Llama 3.3 70B (openrouter_http_client.chatCompletion)
   └── Foto  → Llama 4 Maverick (con image_url nel message content)

3. VALIDATE JSON
   ├── Prova jsonDecode()
   ├── Se fallisce → retry con prompt di repair (max 1 retry)
   └── Valida schema (days[], exercises[], sets[])

4. PARSE → List<ParsedDay> con List<ParsedExerciseLine>

5. FUZZY MATCH (per ogni esercizio)
   ├── ExerciseFuzzyMatcher.searchExercises(query: rawName) (ESISTENTE)
   ├── Prendi top match
   ├── Se score > 0.80 → auto-match (badge verde)
   ├── Se score 0.50-0.80 → suggerimento (badge giallo)
   └── Se score < 0.50 → nessun match (badge rosso, picker manuale)

6. PREVIEW → Mostra all'utente per conferma/editing

7. SAVE → Crea WorkoutTemplate per ogni day (via workoutTemplateNotifierProvider)
```

---

## UX Flow Dettagliato

### Entry Point

Nel `CreateTemplateModal` esistente, aggiungere una nuova opzione prima del form:

```
┌──────────────────────────────────────┐
│  ⚡ Crea Template                     │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 📋 Importa da testo/foto    │    │  ← NUOVO
│  │ Incolla una scheda o scatta  │    │
│  │ una foto per crearla auto.   │    │
│  └──────────────────────────────┘    │
│                                      │
│  ─── oppure crea manualmente ───     │
│                                      │
│  [Nome template.............]        │
│  [Upper] [Lower] [Full Body]         │
│  ...resto del form attuale...        │
└──────────────────────────────────────┘
```

### Import Screen (fullscreen via ModalService)

```
┌──────────────────────────────────────┐
│  ← Importa Scheda                    │
│                                      │
│  ┌────────────┐ ┌────────────┐       │
│  │  📝 Testo  │ │  📷 Foto   │       │
│  └────────────┘ └────────────┘       │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ Incolla qui la tua scheda... │    │
│  │                              │    │
│  │ 1 giorno                     │    │
│  │ Chest press 3x15 1' rec     │    │
│  │ Panca piana 10-10-8-8       │    │
│  │ ...                          │    │
│  │                              │    │
│  └──────────────────────────────┘    │
│                                      │
│  [📋 Incolla da appunti]            │
│                                      │
│  ┌──────────────────────────────┐    │
│  │     🔍 Analizza Scheda       │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
```

### Tab Foto

```
┌──────────────────────────────────────┐
│  ← Importa Scheda                    │
│                                      │
│  ┌────────────┐ ┌────────────┐       │
│  │  📝 Testo  │ │  📷 Foto   │       │
│  └────────────┘ └────────────┘       │
│                                      │
│  ┌──────────────────────────────┐    │
│  │                              │    │
│  │    📷 Scatta foto            │    │
│  │    🖼️ Scegli dalla galleria  │    │
│  │                              │    │
│  └──────────────────────────────┘    │
│                                      │
│  Preview immagine selezionata        │
│  ┌──────────────────────────────┐    │
│  │  [foto scheda]               │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │     🔍 Analizza Scheda       │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
```

### Preview Risultati

```
┌──────────────────────────────────────┐
│  ← Risultati                         │
│                                      │
│  Trovati 3 giorni, 18 esercizi       │
│                                      │
│  ── Giorno 1 - Petto/Bicipiti ──     │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ ✅ Chest Press        3x15   │    │  badge verde (auto-matched)
│  │    → Chest Press Machine     │    │
│  │    Rec: 1'00"                │    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │ 🟡 Panca piana manubri      │    │  badge giallo (suggerimento)
│  │    → Dumbbell Bench Press?   │    │
│  │    10-10-8-8                 │    │
│  │    [Cambia esercizio]        │    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │ 🔴 Curl cavi alti    3x12   │    │  badge rosso (no match)
│  │    Nessun match trovato      │    │
│  │    [Scegli esercizio]        │    │
│  └──────────────────────────────┘    │
│                                      │
│  ── Giorno 2 - Gambe ──             │
│  ...                                 │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  Crea 3 Template              │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
```

### Exercise Match Picker (tap su badge giallo/rosso)

```
┌──────────────────────────────────────┐
│  Scegli esercizio per:               │
│  "Curl cavi alti"                    │
│                                      │
│  ── Suggerimenti ──                  │
│  ┌──────────────────────────────┐    │
│  │ Cable Curl               78% │    │
│  │ High Cable Curl           72% │    │
│  │ Cable Bicep Curl          65% │    │
│  └──────────────────────────────┘    │
│                                      │
│  🔍 Cerca nel database...            │
│  ┌──────────────────────────────┐    │
│  │ [                          ] │    │
│  └──────────────────────────────┘    │
│                                      │
│  [Usa nome originale]                │
│  (crea come esercizio custom)        │
└──────────────────────────────────────┘
```

---

## Provider Pattern

```dart
@riverpod
class WorkoutImport extends _$WorkoutImport {
  bool _isImporting = false;

  @override
  WorkoutImportState build() {
    ref.keepAlive();
    return const WorkoutImportState.initial();
  }

  /// Parse testo libero
  Future<void> parseText(String text) async {
    if (_isImporting) return;
    _isImporting = true;

    try {
      state = const WorkoutImportState.loading();
      final service = ref.read(workoutImportServiceProvider);
      final parsed = await service.parseFromText(text);
      final matched = await _matchExercises(parsed);
      state = WorkoutImportState.preview(matched);
    } catch (e) {
      state = WorkoutImportState.error(e.toString());
    } finally {
      _isImporting = false;
    }
  }

  /// Parse foto
  Future<void> parseImage(File imageFile) async {
    if (_isImporting) return;
    _isImporting = true;

    try {
      state = const WorkoutImportState.loading();
      final service = ref.read(workoutImportServiceProvider);
      final parsed = await service.parseFromImage(imageFile);
      final matched = await _matchExercises(parsed);
      state = WorkoutImportState.preview(matched);
    } catch (e) {
      state = WorkoutImportState.error(e.toString());
    } finally {
      _isImporting = false;
    }
  }

  /// Fuzzy match ogni esercizio con DB
  Future<ParsedWorkout> _matchExercises(ParsedWorkout parsed) async {
    final exercises = ref.read(allExercisesProvider);
    // Usa ExerciseFuzzyMatcher ESISTENTE - non duplicare logica
    // Future.wait per parallelizzare i match
    // ...
  }

  /// Aggiorna match per singolo esercizio (dopo picker manuale)
  void updateExerciseMatch(int dayIndex, int exerciseIndex, ExerciseDefinition selected) {
    // Aggiorna ParsedExerciseLine con il match scelto dall'utente
  }

  /// Crea i template finali
  Future<void> createTemplates() async {
    // Per ogni day → crea WorkoutTemplate
    // Salva via workoutTemplateNotifierProvider
  }
}
```

---

## Feature Flag

```dart
// In lib/core/config/feature_flags.dart
static bool get workoutImportEnabled =>
    EnvironmentConfig.openRouterApiKey != null &&
    EnvironmentConfig.openRouterApiKey!.isNotEmpty;
```

Stessa condizione dell'AI Coach: se c'e' la API key, la feature e' disponibile.

---

## Packages Necessari

| Package | Scopo | Status |
|---------|-------|--------|
| `image_picker` | Camera/galleria per foto | Gia presente (^1.2.1) |
| `http` | OpenRouter API calls | Gia presente |
| `freezed` | Entities immutabili | Gia presente |
| `riverpod` | State management | Gia presente |

**Nessun package nuovo richiesto.**

---

## Pattern Codebase Rispettati

| Pattern | Come viene applicato |
|---------|---------------------|
| Feature separata | `lib/features/workout_import/` (non dentro `workout/`) |
| `ExerciseFuzzyMatcher` riuso | Matching esercizi via servizio ESISTENTE |
| `ModalService.showFullScreenSheet()` | Per navigazione import screen (navbar hide) |
| `FeatureFlags` guard | Condizionale su OpenRouter API key |
| `@riverpod` + `keepAlive()` + `_isImporting` | Pattern da `ai_chat_provider.dart` |
| `OpenRouterHttpClient` riuso | Datasource riusa client HTTP esistente |
| `context.l10n.*` per testi | Nessuna stringa hardcoded |
| `context.colors.*` per colori | Nessun `Colors.*` diretto |
| `AppIcons.*` per icone | Nessun `Icons.*` diretto |
| Batch operations | `Future.wait()` per match paralleli |

---

## Persona Impact Analysis

| Persona | Impatto | Note |
|---------|---------|------|
| **Marco** (principiante) | ++ | Puo importare la scheda del PT senza capire la struttura |
| **Chiara** (multitasking) | +++ | Foto della scheda → template in 10 secondi |
| **Luca** (powerlifter) | ++ | Importa programmi complessi con piramidali |
| **Sofia** (estetica) | + | Importa schede da influencer/social |
| **Roberto** (busy) | +++ | Zero friction, incolla da WhatsApp e via |

**Nessun impatto negativo** su alcuna persona. Feature puramente additiva.

---

## Rischi e Mitigazioni

| Rischio | Probabilita | Mitigazione |
|---------|-------------|-------------|
| LLM restituisce JSON malformato | Media | Retry con prompt di repair (max 1), fallback graceful |
| Modello free non disponibile | Bassa | Fallback a modello alternativo (`nvidia/...`) |
| Foto illeggibile (bassa qualita) | Media | Messaggio chiaro "Non riesco a leggere la foto, riprova" |
| Esercizi non matchati | Alta (atteso) | Picker manuale con suggerimenti + opzione "crea custom" |
| Rate limiting OpenRouter free | Bassa | Stesso budget dell'AI Coach, una call per import |

---

## Stima Complessita

| Componente | File | Complessita |
|------------|------|-------------|
| Entities (freezed) | 2 file | Bassa |
| AI Client (datasource) | 1 file | Media (riuso OpenRouterHttpClient) |
| Import Service (data) | 1 file | Media (prompt + validation) |
| Provider (@riverpod) | 1 file | Media (state machine) |
| Import Screen | 1 file | Alta (tabs, preview, loading states) |
| Widgets (card, picker) | 3 file | Media |
| Feature flag | 1 modifica | Bassa |
| CreateTemplateModal modifica | 1 modifica | Bassa |
| Localizzazione (l10n) | 2 file ARB | Bassa |
| **Totale** | ~12 file | **Media-Alta** |
