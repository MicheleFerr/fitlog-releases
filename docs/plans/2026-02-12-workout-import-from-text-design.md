# Importa Scheda da Testo/Foto - Design Document

**Data**: 2026-02-12 | **Aggiornamento**: 2026-02-13 (post-validazione team)
**Status**: Validated - Pronto per implementazione
**Feature**: Auto-generazione template da testo libero o foto

---

## Problema

Gli utenti hanno schede palestra in formato testuale (WhatsApp, note, appunti) o cartaceo (foto della scheda dal personal trainer). Attualmente devono ricreare manualmente ogni esercizio nell'app, un processo tedioso che scoraggia l'adozione.

## Soluzione

Una feature che permette di incollare testo o scattare una foto di una scheda, e l'app la converte automaticamente in uno o piu template strutturati con esercizi matchati al database.

## Vantaggio Competitivo

| Differenziatore | FitLog | SmartGym | Hevy | Strong | Tutti gli altri |
|-----------------|--------|----------|------|--------|-----------------|
| Import da foto | **Si** | No | No | No | No |
| Testo libero naturale | **Si** | Si (formato rigido) | No | No | No |
| Italiano nativo | **Si** | Solo inglese | N/A | N/A | N/A |
| Cross-platform | **Si** | Solo iOS 26+ | N/A | N/A | N/A |
| Preview interattiva | **Si** | Sostituzione silenziosa | N/A | N/A | N/A |

**Finestra di opportunita**: 6-12 mesi. Zero competitor offrono import da foto. Dettagli in `docs/research/IMPORT_WORKOUT_COMPETITOR_ANALYSIS.md`.

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
| Entry point wording | "Ho gia una scheda" | "Importa da testo/foto" | Meno tecnico, naturale per Marco/Chiara |

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
│   │   └── workout_import_service_impl.dart # Pre/post-processing + AI parsing + validation
│   └── datasources/
│       └── workout_import_ai_client.dart    # OpenRouter API calls (riusa OpenRouterHttpClient)
└── presentation/
    ├── providers/
    │   └── workout_import_provider.dart     # @riverpod con keepAlive + _isImporting + cancellation
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
       ├── implements → _preprocessText() (strip WhatsApp, emoji, normalize)
       ├── implements → _extractJsonFromResponse() (post-processing)
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
- Fallback chain: try model A, if 404/503 → try model B → errore

**Token budget stimato**:
- Per import testo: ~1700-3200 tokens (prompt ~700 + testo ~500 + output ~2000)
- Per import foto: ~2700-4200 tokens (prompt ~700 + image desc ~1000 + output ~2500)
- Budget giornaliero: 200K tokens / ~3000 avg = ~66 import/day condiviso con AI Coach

---

## Entities (Domain Layer)

### ParsedWorkout

```dart
@freezed
class ParsedWorkout with _$ParsedWorkout {
  const factory ParsedWorkout({
    required List<ParsedDay> days,
    String? rawText,              // Testo originale per debug (MAI base64 immagine)
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
    String? notes,                    // Note aggiuntive (RPE, TUT, "per lato", "drop set", etc.)
    String? supersetGroup,            // "A", "B" per raggruppare superset (pattern A1/A2)

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
    int? reps,               // Ripetizioni target (null per "Max")
    @Default(false) bool isMaxReps,      // true per "3xMax" / "AMRAP"
    double? weight,          // Peso (se specificato)
    int? durationSeconds,    // Per isometriche/cardio (plank 30s, corsa 20min)
    int? minReps,            // Range reps min (per "8-12" → 8)
    int? maxReps,            // Range reps max (per "8-12" → 12)
  }) = _ParsedSet;
}
```

---

## Pre-Processing Layer (NUOVO)

Prima di inviare all'AI, normalizzare l'input:

```dart
String _preprocessText(String raw) {
  var text = raw;
  // 1. Strip emoji
  text = text.replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}\u{2702}-\u{27B0}]', unicode: true), '');
  // 2. Strip markdown WhatsApp (* bold *, _ italic _, ~ strikethrough ~)
  text = text.replaceAll(RegExp(r'[*_~]'), '');
  // 3. Normalizza whitespace (tab → spazio, spazi multipli → singolo)
  text = text.replaceAll(RegExp(r'\t'), ' ');
  text = text.replaceAll(RegExp(r' {2,}'), ' ');
  // 4. Normalizza apici
  text = text.replaceAll('\u2019', "'"); // ' → '
  text = text.replaceAll('\u201C', '"'); // " → "
  text = text.replaceAll('\u201D', '"'); // " → "
  return text.trim();
}
```

## Post-Processing Layer (NUOVO)

Dopo risposta AI, estrarre JSON robusto:

```dart
Map<String, dynamic> _extractJsonFromResponse(String aiResponse) {
  // 1. Cerca il primo { e l'ultimo }
  final start = aiResponse.indexOf('{');
  final end = aiResponse.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) {
    throw FormatException('Nessun JSON trovato nella risposta AI');
  }
  final jsonString = aiResponse.substring(start, end + 1);

  // 2. Prova decode
  try {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  } catch (e) {
    // 3. Tenta fix comuni (trailing comma)
    final fixed = jsonString.replaceAll(RegExp(r',\s*}'), '}').replaceAll(RegExp(r',\s*]'), ']');
    return jsonDecode(fixed) as Map<String, dynamic>;
  }
}
```

---

## AI Prompt Design

### System Prompt (Testo)

```
Sei un parser esperto di schede palestra italiane.
Analizza il testo e restituisci SOLO JSON valido, senza commenti o spiegazioni prima/dopo.

DIZIONARIO ABBREVIAZIONI ITALIANE:
- panc. = panca, lat. = laterale/lat machine, bil. = bilanciere
- man. = manubri, mach. = machine, dist. = distensioni
- addm. = addominali, quadr. = quadricipiti, pol. = puleggia/polley
- rec = recupero, ric. = richiamo

SINONIMI PALESTRA ITALIANI:
- francese = skull crusher / lying triceps extension
- lento avanti = overhead press / military press
- tirate al mento = upright row
- croci = cable/dumbbell fly
- rematore = barbell/dumbbell row
- alzate laterali = lateral raise
- spinte = press
- trazioni = pull up
- flessioni/piegamenti = push up

ACRONIMI COMUNI:
- SQ = squat, DL = deadlift, BP = bench press
- OHP = overhead press, MR = military press
- AMRAP = as many reps as possible (cedimento)

FORMATI SERIE RICONOSCIUTI:
- "3x12" → 3 serie da 12 reps
- "10-10-8-8" → 4 serie piramidali (10, 10, 8, 8 reps)
- "4x8-12" → 4 serie con range reps (min_reps: 8, max_reps: 12)
- "5/3/1" → 3 serie piramidali DISCENDENTI (5, 3, 1 reps)
- "3xMax" / "3xAMRAP" / "3xF" / "3x cedimento" → is_max_reps: true
- "3x30s" / "3x45sec" / "plank 60s" → duration_seconds (NON reps)
- "10+10+10" → cluster set = 3 serie da 10 reps, notes: "cluster set"

FORMATI RECUPERO:
- "1'" / "1 min" / "60s" → rest_seconds: 60
- "1'30" / "90s" → rest_seconds: 90
- "2'" / "2 min" / "120s" → rest_seconds: 120
- "rec 1'30" → rest_seconds: 90

SEPARATORI DI GIORNO (qualsiasi di questi):
- "1 giorno", "giorno 1", "day 1"
- "A", "B", "C", "D" (lettere singole come header)
- "Lunedi", "Martedi", "Mercoledi" etc.
- "PUSH", "PULL", "LEGS", "UPPER", "LOWER", "FULL BODY"
- Headers con gruppi muscolari: "PETTORALI", "DORSALI", "GAMBE"

SUPERSET (pattern A1/A2):
- "A1. Squat", "A2. Romanian Deadlift" → superset_group: "A"
- "SS:" o "Superset:" → superset_group incrementale

CIRCUITI:
- "Circuito 3 giri: Push up 10, Squat 15, Plank 30s"
  → Ogni esercizio = 3 serie (dai giri), notes: "circuito"

NOTE SPECIALI (salvare in notes):
- "RPE 8", "@RPE8" → notes: "RPE 8"
- "drop set", "DS" → notes: "drop set"
- "rest pause", "RP" → notes: "rest pause"
- "per lato", "each leg", "per braccio" → notes: "per lato"
- "TUT 3-1-2-0" → notes: "TUT 3-1-2-0"
- Riscaldamento/warmup → includere come esercizio con notes: "riscaldamento"

REGOLE:
1. Se trovi separatori di giorno → separa in days distinti
2. Se trovi gruppi muscolari come header → usa come muscle_group
3. Se non c'e separazione giorni → tutto in un unico day chiamato "Allenamento"
4. Il campo "name" DEVE essere il nome ESATTO dal testo originale
5. rest_seconds = null se non specificato
6. I numeri/bullet PRIMA del nome sono numerazione lista, NON parte del nome
7. Se trovi peso esplicito (es. "@60kg", "80kg") → weight nel set
8. Note del PT generiche → salvare in notes dell'esercizio piu vicino
9. Varianti condizionali ("o leg press se dolore") → esercizio principale + notes
10. Progressioni settimanali → parsare solo la prima settimana, il resto in notes

OUTPUT FORMAT (JSON):
```

### Few-Shot Examples nel Prompt

```json
{
  "days": [
    {
      "name": "Giorno 1 - Push",
      "exercises": [
        {
          "name": "Chest press",
          "sets": [{"reps": 15}, {"reps": 15}, {"reps": 15}],
          "rest_seconds": 60,
          "muscle_group": "chest",
          "notes": null,
          "superset_group": null
        },
        {
          "name": "panca piana con Manubri",
          "sets": [{"reps": 10}, {"reps": 10}, {"reps": 8}, {"reps": 8}],
          "rest_seconds": null,
          "muscle_group": "chest",
          "notes": null,
          "superset_group": null
        },
        {
          "name": "Trazioni",
          "sets": [{"reps": null, "is_max_reps": true}, {"reps": null, "is_max_reps": true}],
          "rest_seconds": null,
          "muscle_group": "back",
          "notes": null,
          "superset_group": null
        },
        {
          "name": "Plank",
          "sets": [{"duration_seconds": 45}, {"duration_seconds": 45}, {"duration_seconds": 45}],
          "rest_seconds": 30,
          "muscle_group": "core",
          "notes": null,
          "superset_group": null
        },
        {
          "name": "Squat",
          "sets": [{"min_reps": 8, "max_reps": 12}, {"min_reps": 8, "max_reps": 12}, {"min_reps": 8, "max_reps": 12}],
          "rest_seconds": 90,
          "muscle_group": "legs",
          "notes": "RPE 8",
          "superset_group": null
        }
      ]
    }
  ]
}
```

### Esempio Circuito

```json
{
  "days": [{"name": "Circuito", "exercises": [
    {"name": "Push up", "sets": [{"reps": 10}, {"reps": 10}, {"reps": 10}], "notes": "circuito", "superset_group": null},
    {"name": "Squat", "sets": [{"reps": 15}, {"reps": 15}, {"reps": 15}], "notes": "circuito", "superset_group": null},
    {"name": "Plank", "sets": [{"duration_seconds": 30}, {"duration_seconds": 30}, {"duration_seconds": 30}], "notes": "circuito", "superset_group": null}
  ]}]
}
```

### Esempio Superset

```json
{
  "days": [{"name": "Upper", "exercises": [
    {"name": "Squat", "sets": [{"reps": 5}, {"reps": 5}, {"reps": 5}], "superset_group": "A"},
    {"name": "Romanian Deadlift", "sets": [{"reps": 10}, {"reps": 10}, {"reps": 10}], "superset_group": "A"},
    {"name": "Leg Press", "sets": [{"reps": 12}, {"reps": 12}], "superset_group": "B"},
    {"name": "Leg Curl", "sets": [{"reps": 12}, {"reps": 12}], "superset_group": "B"}
  ]}]
}
```

### System Prompt Aggiuntivo (Vision/Foto)

```
Stai analizzando una FOTO di una scheda palestra.
Leggi tutto il testo visibile, incluse tabelle e colonne.
Per le tabelle, collega ogni riga esercizio alle colonne SERIE, REC, CARICO.
Ignora dati nelle colonne CARICO (sono pesi personali, non servono nel template).
Se il testo sembra tagliato/incompleto, parsalo comunque e indica notes: "testo potenzialmente incompleto".
Se la foto contiene una tabella con intestazioni di colonna, usa le intestazioni per capire cosa c'e in ogni cella.
```

---

## Pipeline di Parsing

```
1. INPUT
   ├── Testo incollato → _preprocessText() → testo normalizzato
   └── Foto scattata/selezionata → comprimi (maxWidth:1280, quality:80) → base64

2. VALIDAZIONE PRE-INVIO
   ├── Testo vuoto? → errore "Inserisci il testo della scheda"
   ├── Testo < 10 chars? → errore "Il testo sembra troppo corto"
   ├── Connessione? → check prima di chiamare AI
   ├── Rate limit? → check import giornaliero (max 15/day)
   └── Cooldown? → min 10 secondi tra un import e l'altro

3. AI CALL (con timeout: 30s testo, 60s vision)
   ├── Testo → Llama 3.3 70B (maxTokens: 4096, jsonMode: true)
   ├── Foto  → Llama 4 Maverick (maxTokens: 4096, content array con image_url)
   ├── Delimitare testo utente: <USER_TEXT>...testo...</USER_TEXT>
   └── Se finish_reason == 'length' → retry con maxTokens piu alto

4. POST-PROCESSING
   ├── _extractJsonFromResponse() → estrai JSON dalla risposta
   ├── Se fallisce → retry con prompt di repair (max 1 retry)
   ├── Valida schema (days[], exercises[], sets[])
   ├── Dedup: se stesso nome + stesse serie → rimuovi duplicato
   └── Se 0 esercizi → errore "Non ho trovato esercizi nel testo"

5. FUZZY MATCH (per ogni esercizio, in parallelo con Future.wait)
   ├── ExerciseFuzzyMatcher.searchExercises(query: rawName) (ESISTENTE)
   ├── Prendi top match
   ├── Se score > 0.80 → auto-match (badge verde ✓ "Trovato")
   ├── Se score 0.50-0.80 → suggerimento (badge giallo ? "Suggerito")
   └── Se score < 0.50 → nessun match (badge rosso ✗ "Non trovato")

6. PREVIEW → Mostra all'utente per conferma/editing

7. SAVE → Crea WorkoutTemplate per ogni day (via workoutTemplateNotifierProvider)
   └── Guard: disabilita bottone dopo primo tap (anti double-tap)
```

### Retry Strategy per Errori di Rete

```
Errori transienti (timeout, 500, 502, 503):
  1° retry dopo 2s
  2° retry dopo 4s
  Max 2 retry con backoff esponenziale

Errori non-retriable (400, 401, 429):
  No retry → messaggio errore user-friendly
```

---

## Modifiche a OpenRouterHttpClient (ESISTENTE)

L'HTTP client esistente necessita di queste aggiunte:

```dart
Future<OpenRouterResponse> chatCompletion({
  required String model,
  required List<Map<String, dynamic>> messages,
  List<Map<String, dynamic>>? tools,
  int maxTokens = 1000,
  Duration? timeout,           // NUOVO - default null (no timeout)
  bool jsonMode = false,       // NUOVO - response_format: json_object
}) async {
  final body = {
    'model': model,
    'messages': messages,
    if (tools != null && tools.isNotEmpty) 'tools': tools,
    if (tools != null && tools.isNotEmpty) 'tool_choice': 'auto',
    'max_tokens': maxTokens,
    if (jsonMode) 'response_format': {'type': 'json_object'},
  };

  final future = http.post(
    Uri.parse('$_baseUrl/chat/completions'),
    headers: { /* esistenti */ },
    body: jsonEncode(body),
  );

  // Timeout support
  final response = timeout != null
      ? await future.timeout(timeout)
      : await future;

  // ... check finish_reason per troncamento
  final finishReason = firstChoice['finish_reason'] as String?;
  // Esporre finish_reason nella response per check troncamento
}
```

### Vision Message Format

Il client HTTP gia supporta content array (usa `Map<String, dynamic>` generico):

```dart
final messages = [
  {'role': 'system', 'content': systemPrompt},
  {
    'role': 'user',
    'content': [
      {'type': 'text', 'text': 'Analizza questa scheda palestra...'},
      {
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/jpeg;base64,$base64Image',
        },
      },
    ],
  },
];
```

**IMPORTANTE**: Usare SEMPRE l'HTTP client path per vision (non l'SDK che converte content a String).

---

## UX Flow Dettagliato

### Entry Point

Nel `CreateTemplateModal` esistente, aggiungere una nuova opzione prima del form:

```
┌──────────────────────────────────────┐
│  ⚡ Crea Template                     │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ 📋 Ho gia una scheda        │    │  ← NUOVO (wording rivisto)
│  │ Incolla il testo o scatta   │    │
│  │ una foto per crearla auto.  │    │
│  └──────────────────────────────┘    │
│                                      │
│  ─── oppure crea manualmente ───     │
│                                      │
│  [Nome template.............]        │
│  [Upper] [Lower] [Full Body]         │
│  ...resto del form attuale...        │
└──────────────────────────────────────┘
```

### Banner Primo Uso (per Marco)

Al primo utilizzo, mostrare banner dismissibile:
```
┌────────────────────────────────────────┐
│ ℹ️ Incolla il testo o scatta una foto │
│ della tua scheda palestra e la        │
│ creeremo per te automaticamente.      │
│                                [✕]    │
└────────────────────────────────────────┘
```

### Import Screen (fullscreen via ModalService)

```
┌──────────────────────────────────────┐
│  ← Importa Scheda                    │
│                                      │
│  ┌────────────┐ ┌────────────┐       │
│  │  📝 Testo  │ │  📷 Foto   │       │  ← Segmented control (min 44pt touch)
│  └────────────┘ └────────────┘       │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ Incolla qui la tua scheda... │    │  ← Placeholder con esempio sbiadito
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
│  │     🔍 Analizza Scheda       │    │  ← Disabilitato se campo vuoto o offline
│  └──────────────────────────────┘    │
│                                      │
│  ⚠️ Se offline: banner              │
│  "Connessione necessaria per         │
│  analizzare la scheda"               │
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
│  ℹ️ La foto verra analizzata da un   │  ← Privacy disclosure (GDPR)
│  servizio AI. Non viene salvata.     │
│                                      │
│  ┌──────────────────────────────┐    │
│  │    📷 Scatta foto            │    │
│  │    🖼️ Scegli dalla galleria  │    │
│  └──────────────────────────────┘    │
│                                      │
│  Preview immagine selezionata        │
│  ┌──────────────────────────────┐    │
│  │  [foto scheda compressa]     │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │     🔍 Analizza Scheda       │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
```

### Loading State (con messaggi progressivi)

```
┌──────────────────────────────────────┐
│                                      │
│         ⏳ (shimmer animation)       │
│                                      │
│    0-3s:  "Analizzando la scheda..." │
│    3-8s:  "Leggendo gli esercizi..." │
│    8-15s: "Quasi fatto..."           │
│    15-30s: "Sta richiedendo          │
│            piu tempo del solito..."   │
│    30s+:   Timeout → bottone Riprova │
└──────────────────────────────────────┘
```

### Preview Risultati

```
┌──────────────────────────────────────┐
│  ← Risultati                         │
│                                      │
│  Trovati 3 giorni, 18 esercizi       │
│  ⚠️ 2 esercizi da confermare        │  ← Contatore badge gialli/rossi
│                                      │
│  ── Giorno 1 - Petto/Bicipiti ──     │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ ✓ Chest Press        3x15   │    │  badge verde + icona checkmark
│  │    → Chest Press Machine     │    │  + testo "Trovato"
│  │    Rec: 1'00"                │    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │ ? Panca piana manubri       │    │  badge giallo + icona ?
│  │    → Dumbbell Bench Press?   │    │  + testo "Suggerito"
│  │    10-10-8-8                 │    │
│  │    [Cambia esercizio]        │    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │ ✗ Curl cavi alti    3x12   │    │  badge rosso + icona ✗
│  │    Nessun match trovato      │    │  + testo "Non trovato"
│  │    [Scegli esercizio]        │    │
│  └──────────────────────────────┘    │
│                                      │
│  ── Giorno 2 - Gambe ──             │
│  ...                                 │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  Crea 3 Template              │    │  ← Disabilitato dopo primo tap
│  └──────────────────────────────┘    │
│                                      │
│  Badge rossi: permessi per salvare   │
│  (match giallo accettato, rosso =    │
│  esercizio custom con nome originale)│
└──────────────────────────────────────┘
```

**Accessibilita badge (CRITICO)**: I badge DEVONO avere icona + testo, non solo colore.
Per daltonismo rosso-verde (8% uomini), i colori da soli sono insufficienti.

| Badge | Colore | Icona | Testo | Semantics label |
|-------|--------|-------|-------|-----------------|
| Match sicuro | Verde | ✓ checkmark | "Trovato" | "Esercizio X, 3 serie da 15, trovato nel database" |
| Suggerimento | Giallo | ? domanda | "Suggerito" | "Esercizio X, suggerito Y, tap per cambiare" |
| Non trovato | Rosso | ✗ croce | "Non trovato" | "Esercizio X non trovato, tap per scegliere" |

### Exercise Match Picker (tap su badge giallo/rosso)

```
┌──────────────────────────────────────┐
│  Scegli esercizio per:               │
│  "Curl cavi alti"                    │
│                                      │
│  ── Suggerimenti ──                  │
│  ┌──────────────────────────────┐    │
│  │ Cable Curl               78% │    │  ← Nomi localizzati
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

### Error States (completi)

| Errore | Messaggio utente | Azioni |
|--------|------------------|--------|
| Input vuoto | "Inserisci il testo della scheda" | Disabilita bottone Analizza |
| Testo troppo corto | "Il testo sembra troppo corto per una scheda" | - |
| Offline | "Connessione necessaria per analizzare la scheda" | Banner + bottone disabilitato |
| AI non raggiungibile | "Servizio temporaneamente non disponibile. Riprova tra poco." | [Riprova] |
| Rate limit (429) | "Troppe richieste. Attendi un minuto e riprova." | [Riprova dopo 60s] |
| Timeout | "L'analisi sta richiedendo troppo tempo. Riprova." | [Riprova] + [Crea manualmente] |
| JSON malformato (dopo retry) | "Non sono riuscito a interpretare la scheda. Prova a riformattare." | [Riprova] + [Crea manualmente] |
| Zero esercizi | "Non ho trovato esercizi nel testo. Assicurati che contenga nomi con serie e ripetizioni." | [Riprova] + esempio formato |
| Foto sfocata/illeggibile | "Non riesco a leggere la foto. Prova a scattare con piu luce." | [Riprova] + [Prova con testo] |
| Salvataggio fallito | "Errore nel salvataggio. Riprova." | [Riprova] (preview intatta) |
| Rate limit giornaliero | "Limite giornaliero di import raggiunto. Riprova domani." | [Crea manualmente] |

**REGOLA**: Mai dead-end. Dopo OGNI errore, sempre offrire "Crea manualmente" come fallback.

---

## Provider Pattern

```dart
@riverpod
class WorkoutImport extends _$WorkoutImport {
  bool _isImporting = false;
  bool _isCreating = false;       // Anti double-tap per creazione
  DateTime? _lastImportTime;
  int _importsToday = 0;
  CancelableOperation<void>? _currentOperation;  // Per cancellation

  static const _maxImportsPerDay = 15;
  static const _cooldownBetweenImports = Duration(seconds: 10);

  @override
  WorkoutImportState build() {
    ref.keepAlive();
    ref.onDispose(() {
      _currentOperation?.cancel();  // Cancella richiesta in corso
    });
    return const WorkoutImportState.initial();
  }

  /// Parse testo libero
  Future<void> parseText(String text) async {
    if (_isImporting) return;
    if (!_checkRateLimit()) return;
    _isImporting = true;

    try {
      state = const WorkoutImportState.loading();
      final service = ref.read(workoutImportServiceProvider);
      final parsed = await service.parseFromText(text);
      final matched = await _matchExercises(parsed);
      state = WorkoutImportState.preview(matched);
    } on TimeoutException {
      state = WorkoutImportState.error(_userFriendlyError('timeout'));
    } catch (e) {
      state = WorkoutImportState.error(_userFriendlyError(e));
    } finally {
      _isImporting = false;
      _lastImportTime = DateTime.now();
      _importsToday++;
    }
  }

  /// Parse foto (NON salvare base64 nello state!)
  Future<void> parseImage(File imageFile) async {
    if (_isImporting) return;
    if (!_checkRateLimit()) return;
    _isImporting = true;

    try {
      state = const WorkoutImportState.loading();
      final service = ref.read(workoutImportServiceProvider);
      // Compressione gestita via ImagePicker(maxWidth:1280, imageQuality:80)
      final parsed = await service.parseFromImage(imageFile);
      // imageFile reference rilasciata dopo il parsing, base64 GC'd
      final matched = await _matchExercises(parsed);
      state = WorkoutImportState.preview(matched);
    } on TimeoutException {
      state = WorkoutImportState.error(_userFriendlyError('timeout'));
    } catch (e) {
      state = WorkoutImportState.error(_userFriendlyError(e));
    } finally {
      _isImporting = false;
      _lastImportTime = DateTime.now();
      _importsToday++;
    }
  }

  bool _checkRateLimit() {
    if (_importsToday >= _maxImportsPerDay) {
      state = WorkoutImportState.error('Limite giornaliero raggiunto');
      return false;
    }
    if (_lastImportTime != null &&
        DateTime.now().difference(_lastImportTime!) < _cooldownBetweenImports) {
      state = WorkoutImportState.error('Attendi qualche secondo...');
      return false;
    }
    return true;
  }

  String _userFriendlyError(dynamic error) {
    // Mappa errori tecnici a messaggi utente
    final msg = error.toString();
    if (msg.contains('429')) return 'Troppe richieste. Attendi un minuto.';
    if (msg.contains('500') || msg.contains('502') || msg.contains('503'))
      return 'Servizio temporaneamente non disponibile.';
    if (msg.contains('timeout') || error is TimeoutException)
      return "L'analisi sta richiedendo troppo tempo. Riprova.";
    return 'Errore nell\'analisi. Riprova o crea manualmente.';
  }

  /// Fuzzy match ogni esercizio con DB (in parallelo)
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

  /// Crea i template finali (con guard anti double-tap)
  Future<void> createTemplates() async {
    if (_isCreating) return;
    _isCreating = true;
    try {
      // Per ogni day → crea WorkoutTemplate
      // Salva via workoutTemplateNotifierProvider
    } finally {
      _isCreating = false;
    }
  }
}
```

### Logging Sicuro

```dart
// ✅ CORRETTO
debugPrint('[WORKOUT_IMPORT] parseText called, text length: ${text.length}');
debugPrint('[WORKOUT_IMPORT] parseImage called, image size: ${file.lengthSync()} bytes');
debugPrint('[WORKOUT_IMPORT] AI response: ${parsed.days.length} days, ${totalExercises} exercises');

// ❌ MAI loggare contenuto completo
debugPrint('[WORKOUT_IMPORT] Text: $text');  // Dati del PT
debugPrint('[WORKOUT_IMPORT] Base64: $base64');  // Immagine in chiaro
```

---

## Compressione Immagine (CRITICO)

```dart
final image = await ImagePicker().pickImage(
  source: ImageSource.camera,  // o .gallery
  maxWidth: 1280,
  maxHeight: 960,
  imageQuality: 80,  // JPEG quality
);
// Risultato: ~200-500KB invece di 4-12MB originali
// In base64: ~270-670KB invece di 5-16MB
```

**Senza compressione**: foto iPhone 12MP = 4-12MB → 5-16MB base64 → timeout o errore API.

---

## Sicurezza e Privacy

### Prompt Injection

Il testo utente viene delimitato per prevenire injection:

```
<USER_TEXT>
{testo incollato dall'utente}
</USER_TEXT>
```

Il rischio e' attenuato dal fatto che l'output e' JSON strutturato validato dallo schema parser.

### Privacy / GDPR

1. **Disclosure foto**: Banner visibile nel tab foto: "La foto verra analizzata da un servizio AI esterno. Non viene salvata permanentemente."
2. **Dati sensibili**: Le foto di schede possono contenere nome PT, telefono. L'utente e' informato.
3. **Base64 in memoria**: NON persistere nel provider state. Dopo il parsing, la stringa viene GC'd.
4. **rawText**: Salvato nel ParsedWorkout per debug ma MAI il base64 dell'immagine.
5. **API key**: Client-side come AI Coach (rischio accettato: modelli free, rate limit protegge).

---

## Feature Flag

```dart
// In lib/core/config/feature_flags.dart
static bool get workoutImportEnabled =>
    EnvironmentConfig.openRouterApiKey != null &&
    EnvironmentConfig.openRouterApiKey!.isNotEmpty;
```

Stessa condizione dell'AI Coach: se c'e la API key, la feature e' disponibile.

---

## Packages Necessari

| Package | Scopo | Status |
|---------|-------|--------|
| `image_picker` | Camera/galleria per foto | Gia presente (^1.2.1) |
| `http` | OpenRouter API calls | Gia presente |
| `freezed` | Entities immutabili | Gia presente |
| `riverpod` | State management | Gia presente |
| `async` | `CancelableOperation` per cancellation | Gia presente |

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
| Pre/Post processing | Layer separati per robustezza |

---

## Persona Impact Analysis (Validata)

| Persona | Impatto base | Con fix P0+P1 | Note chiave |
|---------|-------------|---------------|-------------|
| **Marco** (principiante) | + | ++ | Wording "Ho gia una scheda", banner primo uso, fallback manuale |
| **Chiara** (multitasking) | ++ | +++ | 9 tap + 15-20s = target <30s rispettato, keepAlive per interruzioni |
| **Luca** (powerlifter) | + | ++ | Manca %1RM (P2), superset e RPE in notes, piramidali supportati |
| **Sofia** (estetica) | + | ++ | Inglese supportato (schede da social), shimmer loading |
| **Roberto** (busy) | ++ | +++ | Screenshot → import → fatto in 9 tap, discovery notification |

**Nessun impatto negativo** su alcuna persona. Feature puramente additiva.

### Limitazioni Note (v1)

- **Periodizzazione multi-settimana**: Fuori scope. Wendler 5/3/1 multi-week → template separati per settimana.
- **Batch import**: Un import alla volta. 5 screenshot = 5 flussi separati.
- **%1RM come campo strutturato**: v1 li salva in notes, non come campo dedicato.
- **Edit inline nella preview**: v1 richiede picker, non edit diretto serie/reps.

---

## Rischi e Mitigazioni (Aggiornati)

| Rischio | Prob. | Sev. | Mitigazione |
|---------|-------|------|-------------|
| maxTokens insufficiente | Alta | P0 | **Alzato a 4096**. Check `finish_reason == 'length'` per retry |
| Foto troppo grande | Alta | P0 | **Compressione obbligatoria** (1280x960, quality 80) |
| JSON malformato dall'AI | Media | P0 | Pre/post-processing + retry con repair + fallback manuale |
| Modello free non disponibile | Bassa | P1 | Fallback chain: model A → model B → errore |
| Foto illeggibile | Media | P1 | Messaggio specifico + suggerimento "prova con testo" |
| Esercizi non matchati | Alta (atteso) | P0 | Picker manuale + suggerimenti + opzione custom |
| Rate limiting OpenRouter | Bassa | P1 | Rate limit client-side (15/day) + cooldown 10s |
| Prompt injection | Bassa | P1 | Delimitatori `<USER_TEXT>` + validazione schema JSON |
| Privacy foto | Media | P0 | Disclosure GDPR + no logging contenuto + no persist base64 |
| SmartGym competitor | Media | P2 | Solo iOS 26+, formato rigido, no foto, no italiano |
| Double-tap crea duplicati | Media | P1 | Guard `_isCreating` + disabilita bottone |
| Timeout richieste | Media | P1 | Timeout 30s/60s + messaggi progressivi + retry |

---

## Stima Complessita

| Componente | File | Complessita |
|------------|------|-------------|
| Entities (freezed) | 2 file | Bassa |
| AI Client (datasource) | 1 file | Media (riuso OpenRouterHttpClient) |
| Import Service (data) | 1 file | Alta (pre/post-processing + prompt + validation + retry) |
| OpenRouterHttpClient mod | 1 modifica | Bassa (timeout + jsonMode) |
| Provider (@riverpod) | 1 file | Alta (state machine + rate limit + cancellation) |
| Import Screen | 1 file | Alta (tabs, preview, loading states, error states) |
| Widgets (card, picker) | 3 file | Media |
| Feature flag | 1 modifica | Bassa |
| CreateTemplateModal modifica | 1 modifica | Bassa |
| Localizzazione (l10n) | 2 file ARB | Media (molti error messages) |
| **Totale** | ~13 file | **Alta** |

---

## Prioritizzazione Fix (Consolidata)

### P0 - Bloccanti (prima del rilascio)

1. maxTokens 4096 (non 1000)
2. Compressione immagine obbligatoria
3. Privacy disclosure foto (GDPR)
4. Accessibilita badge: icona + testo, non solo colore
5. Pre-processing: strip WhatsApp/emoji/whitespace
6. Post-processing: estrazione JSON robusta
7. Error recovery completo per ogni punto di fallimento
8. Check connettivita prima di AI call
9. Empty state per zero risultati
10. Prompt AI: abbreviazioni IT, sinonimi palestra, formati serie, separatori giorno, circuiti

### P1 - Importanti (durante implementazione)

11. Wording "Ho gia una scheda"
12. Badge con testo esplicito
13. Timeout con messaggi progressivi
14. Rate limiting import (15/day + cooldown 10s)
15. Cancellation support (CancelableOperation)
16. Anti double-tap creazione template
17. Retry backoff per errori rete
18. Superset group nel prompt (A1/A2)
19. Range reps (min/max) e duration nel prompt
20. User-friendly error messages (no raw HTTP errors)
21. Logging sicuro (mai contenuto completo)

### P2 - Nice to Have (iterazioni future)

22. Salvataggio intermedio per interruzioni
23. Edit inline nella preview
24. Shimmer loading premium
25. Banner primo uso per Marco
26. Discovery notification per Roberto
27. Cache risultati per stesso testo
28. %1RM come campo strutturato
29. Batch import multi-screenshot
30. Periodizzazione multi-settimana
31. Fallback model chain con cache ultimo funzionante
