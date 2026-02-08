# AI Coach Improvements - Implementation Plan

**Data**: 2026-02-08
**Stato**: Da implementare
**Priorità**: Alta → Media → Bassa

---

## 🗺️ ARCHITETTURA AI COACH

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           USER INPUT                                     │
│                    "Come sta andando la panca?"                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      AICoachScreen (UI)                                  │
│  lib/features/ai_coach/presentation/screens/ai_coach_screen.dart        │
│  - Mostra messaggi, input bar, loading indicator                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      AIChatProvider (State)                              │
│  lib/features/ai_coach/presentation/providers/ai_chat_provider.dart     │
│  - Gestisce stato conversazione                                         │
│  - Controlla rate limit                                                 │
│  - Chiama AICoachService                                                │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    AICoachServiceImpl (Business Logic)                   │
│  lib/features/ai_coach/data/services/ai_coach_service_impl.dart         │
│  - Costruisce messaggi con contesto utente                              │
│  - Loop di tool calling (max 3 iterazioni)                              │
│  - Safety check (keyword mediche)                                       │
│  - Sanitizza risposta                                                   │
└─────────────────────────────────────────────────────────────────────────┘
                    │                               │
                    ▼                               ▼
┌───────────────────────────────┐   ┌─────────────────────────────────────┐
│     AnalyticsAggregator       │   │         AIToolExecutor              │
│  (Contesto iniziale)          │   │  (Esecuzione tool calls)            │
│  - Streak                     │   │  - get1RMHistory                    │
│  - Last workout               │   │  - getWeeklyVolume                  │
│  - Top 5 1RM                  │   │  - suggestWorkout                   │
│  - Recovery status            │   │  - 10+ altri tool                   │
└───────────────────────────────┘   └─────────────────────────────────────┘
                    │                               │
                    └───────────────┬───────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    AIChatRepositoryImpl (API)                            │
│  lib/features/ai_coach/data/repositories/ai_chat_repository_impl.dart   │
│  - Chiama OpenRouter API                                                │
│  - Gestisce tool calling format                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    OpenRouter API (External)                             │
│  Model: meta-llama/llama-3.3-70b-instruct                               │
│  - Genera risposte                                                      │
│  - Può richiedere tool calls                                            │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 FILE CHIAVE

| File | Scopo | Righe |
|------|-------|-------|
| `ai_coach_screen.dart` | UI principale chat | ~260 |
| `ai_chat_provider.dart` | State management | ~245 |
| `ai_coach_service_impl.dart` | Business logic, loop tool calling | ~415 |
| `ai_tool_executor.dart` | Esecuzione 13 tool | ~1210 |
| `analytics_aggregator.dart` | Aggregazione contesto utente | ~232 |
| `ai_chat_repository_impl.dart` | Chiamate API OpenRouter | ~118 |
| `ai_system_prompt.dart` | System prompt per AI | ~177 |
| `ai_tool_definitions.dart` | Definizioni tool in formato OpenAI | ~330 |
| `ai_input_bar.dart` | Widget input messaggio | ~117 |
| `ai_message_bubble.dart` | Widget singolo messaggio | ~394 |
| `ai_rate_limit_provider.dart` | Rate limiting (attualmente disabilitato) | ~140 |

---

## 🔗 DIPENDENZE TRA FIX

```
Fix 1 (Parallelizzare) ──────────────────────────────► Indipendente
Fix 2 (Timeout stream) ──────────────────────────────► Indipendente
Fix 3 (Race condition) ──────────────────────────────► Indipendente

Fix 4 (Localizzare placeholder) ─────► Richiede: flutter gen-l10n dopo
Fix 7 (Suggerimenti onboarding) ─────► Richiede: flutter gen-l10n dopo

Fix 5 (Retry button) ────────────────────────────────► Indipendente
Fix 6 (Haptic feedback) ─────────────────────────────► Indipendente

Fix 8, 9 ────────────────────────────────────────────► Opzionali/Futuri
```

**Ordine consigliato**:
1. Fix 1, 2, 3 (Alta priorità, indipendenti)
2. Fix 4, 7 insieme (richiedono entrambi `flutter gen-l10n`)
3. Fix 5, 6 (Media priorità, indipendenti)

---

## ⚠️ ERRORI COMUNI E SOLUZIONI

### Errore 1: Import mancante fpdart
```
Error: The getter 'Right' isn't defined...
```
**Soluzione**: Aggiungi in cima al file:
```dart
import 'package:fpdart/fpdart.dart' hide State;
```

### Errore 2: context.l10n non riconosciuto
```
Error: The getter 'l10n' isn't defined...
```
**Soluzione**: Aggiungi import:
```dart
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

### Errore 3: Chiave localizzazione mancante
```
Error: The getter 'aiCoachInputHint' isn't defined...
```
**Soluzione**:
1. Aggiungi la chiave nei file `.arb`
2. Esegui `flutter gen-l10n`
3. Riavvia l'IDE se necessario

### Errore 4: HapticFeedback non trovato
```
Error: Undefined name 'HapticFeedback'...
```
**Soluzione**: Aggiungi import:
```dart
import 'package:flutter/services.dart';
```

### Errore 5: WorkoutSummary non trovato dopo parallelizzazione
```
Error: The name 'WorkoutSummary' isn't a type...
```
**Soluzione**: L'import è già presente, ma assicurati che ci sia:
```dart
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
```

---

## ✅ VERIFICA INTERMEDIA

### Dopo Fix 1-2-3 (Performance)
```bash
# Verifica che compili
flutter analyze lib/features/ai_coach/

# Test manuale: invia messaggio e verifica nei log
# Dovresti vedere "Parallel fetch complete" invece di chiamate sequenziali
```

### Dopo Fix 4-7 (Localizzazione)
```bash
# Rigenera localizzazioni
flutter gen-l10n

# Verifica che compili
flutter analyze

# Test manuale:
# - Verifica placeholder in italiano/inglese
# - Verifica suggerimenti visibili all'apertura chat
```

### Dopo Fix 5-6 (UX)
```bash
# Test manuale:
# - Invia messaggio → verifica vibrazione
# - Simula errore (disattiva rete) → verifica pulsante retry
```

---

## 📋 CONTESTO

Questo documento contiene tutte le istruzioni per implementare i miglioramenti identificati nell'analisi dell'AI Coach di FitLog Pro.

**Problema principale risolto**: L'AI Coach entrava in loop infinito di tool calling, restituendo sempre il messaggio "Ho avuto difficoltà a completare l'analisi". Questo è stato fixato aggiungendo:
1. Istruzione esplicita dopo i tool results
2. Rimozione tools dopo 2 iterazioni per forzare risposta
3. Istruzioni nel system prompt

**Questo documento copre i miglioramenti aggiuntivi** identificati durante l'analisi approfondita.

---

## 🔴 PRIORITÀ ALTA

### 1. Parallelizzare chiamate in AnalyticsAggregator

**File**: `lib/features/ai_coach/data/datasources/analytics_aggregator.dart`

**Problema**: 4 chiamate sequenziali che rallentano la risposta di 2-4 secondi.

**Linee da modificare**: 32-61

**TROVA questo codice**:
```dart
  Future<AIContext> aggregateContext({required String userId}) async {
    debugPrint('[AI_COACH] 🔍 Starting context aggregation for user: $userId');

    try {
      // Fetch real data from repositories
      debugPrint('[AI_COACH] 📊 Fetching streak...');
      final streak = await getCurrentStreak(userId);
      debugPrint('[AI_COACH] ✅ Streak: $streak days');

      debugPrint('[AI_COACH] 📝 Fetching last workout...');
      final lastWorkout = await getLastWorkout(userId);
      debugPrint('[AI_COACH] ✅ Last workout: ${lastWorkout?.name ?? "none"}');

      debugPrint('[AI_COACH] 💪 Fetching top 5 1RM...');
      final top5 = await getTop5OneRM(userId);
      debugPrint('[AI_COACH] ✅ Top 5 1RM: ${top5.length} exercises');

      debugPrint('[AI_COACH] 🏃 Fetching recovery status...');
      final recovery = await getRecoveryStatus(userId);
      debugPrint('[AI_COACH] ✅ Recovery: ${recovery.name}');

      final context = AIContext(
        currentStreak: streak,
        lastWorkout: lastWorkout,
        top5OneRM: top5,
        recoveryStatus: recovery,
        userTier: 'free', // TODO: Get from user profile when tier system active
      );
```

**SOSTITUISCI con**:
```dart
  Future<AIContext> aggregateContext({required String userId}) async {
    debugPrint('[AI_COACH] 🔍 Starting context aggregation for user: $userId');

    try {
      // Fetch all data in PARALLEL for better performance
      debugPrint('[AI_COACH] 📊 Fetching all context data in parallel...');

      final results = await Future.wait([
        getCurrentStreak(userId),
        getLastWorkout(userId),
        getTop5OneRM(userId),
        getRecoveryStatus(userId),
      ]);

      final streak = results[0] as int;
      final lastWorkout = results[1] as WorkoutSummary?;
      final top5 = results[2] as Map<String, int>;
      final recovery = results[3] as RecoveryStatus;

      debugPrint('[AI_COACH] ✅ Parallel fetch complete:');
      debugPrint('[AI_COACH]   - Streak: $streak days');
      debugPrint('[AI_COACH]   - Last workout: ${lastWorkout?.name ?? "none"}');
      debugPrint('[AI_COACH]   - Top 5 1RM: ${top5.length} exercises');
      debugPrint('[AI_COACH]   - Recovery: ${recovery.name}');

      final context = AIContext(
        currentStreak: streak,
        lastWorkout: lastWorkout,
        top5OneRM: top5,
        recoveryStatus: recovery,
        userTier: 'free', // TODO: Get from user profile when tier system active
      );
```

**Impatto**: Riduzione tempo risposta del 50-70%

---

### 2. Aggiungere timeout su stream in AnalyticsAggregator

**File**: `lib/features/ai_coach/data/datasources/analytics_aggregator.dart`

**Problema**: `exerciseHistoryStream.first` può bloccarsi indefinitamente.

**Linee da modificare**: 86-89

**TROVA questo codice**:
```dart
      // Analytics repo returns Stream<Either<Failure, List<ExerciseHistory>>>
      // We need to get the first value from the stream
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);

      // Get first emit (cached or real-time)
      final firstResult = await exerciseHistoryStream.first;
```

**SOSTITUISCI con**:
```dart
      // Analytics repo returns Stream<Either<Failure, List<ExerciseHistory>>>
      // We need to get the first value from the stream
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);

      // Get first emit with timeout to prevent indefinite blocking
      final firstResult = await exerciseHistoryStream.first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('[AI_COACH] ⚠️ Timeout waiting for exercise history');
          return const Right(<ExerciseHistory>[]);
        },
      );
```

**Aggiungi import** in cima al file se manca:
```dart
import 'package:fpdart/fpdart.dart' hide State;
```

---

### 3. Prevenire race condition su invii rapidi

**File**: `lib/features/ai_coach/presentation/providers/ai_chat_provider.dart`

**Problema**: Se l'utente invia due messaggi rapidamente, potrebbero sovrapporsi.

**AGGIUNGI** questa variabile dopo la riga 101:
```dart
  // Memory limit: keep last 10 messages (design requirement line 585)
  static const int _maxMessages = 10;

  // Lock to prevent concurrent message sends
  bool _isSending = false;
```

**MODIFICA** il metodo `sendMessage` (riga 116):

**TROVA**:
```dart
  /// Send a message to the AI Coach
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
```

**SOSTITUISCI con**:
```dart
  /// Send a message to the AI Coach
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Prevent concurrent sends (race condition protection)
    if (_isSending) {
      debugPrint('[AI_CHAT] ⚠️ Message send already in progress, ignoring');
      return;
    }
    _isSending = true;

    try {
```

**AGGIUNGI** reset del lock nel blocco finally. Trova la fine del try-catch:

**TROVA**:
```dart
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Error sending AI Coach message',
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Errore durante l\'invio del messaggio. Riprova.',
      );
    }
  }
```

**SOSTITUISCI con**:
```dart
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Error sending AI Coach message',
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Errore durante l\'invio del messaggio. Riprova.',
      );
    } finally {
      _isSending = false;
    }
  }
```

---

## 🟠 PRIORITÀ MEDIA

### 4. Localizzare placeholder input

**File**: `lib/features/ai_coach/presentation/widgets/ai_input_bar.dart`

**Linea**: 89

**TROVA**:
```dart
                decoration: InputDecoration(
                  hintText: 'Chiedi al tuo AI Coach...',
```

**SOSTITUISCI con**:
```dart
                decoration: InputDecoration(
                  hintText: context.l10n.aiCoachInputHint,
```

**AGGIUNGI** le traduzioni nei file ARB:

**File**: `assets/i18n/app_en.arb`
```json
"aiCoachInputHint": "Ask your AI Coach...",
```

**File**: `assets/i18n/app_it.arb`
```json
"aiCoachInputHint": "Chiedi al tuo AI Coach...",
```

**Dopo aver modificato i file ARB**, esegui:
```bash
flutter gen-l10n
```

---

### 5. Aggiungere retry button su errore

**File**: `lib/features/ai_coach/presentation/screens/ai_coach_screen.dart`

**AGGIUNGI** variabile per memorizzare ultimo messaggio (dopo riga 39):
```dart
  bool _disclaimerAccepted = false;
  String? _lastFailedMessage;
```

**MODIFICA** il metodo onSend nella AIInputBar (riga 224-227):

**TROVA**:
```dart
          // Input bar
          AIInputBar(
            onSend: (text) {
              ref.read(aIChatProvider.notifier).sendMessage(text);
              _scrollToBottom();
            },
            isLoading: chatState.isLoading,
          ),
```

**SOSTITUISCI con**:
```dart
          // Input bar
          AIInputBar(
            onSend: (text) {
              setState(() => _lastFailedMessage = text);
              ref.read(aIChatProvider.notifier).sendMessage(text);
              _scrollToBottom();
            },
            isLoading: chatState.isLoading,
          ),
```

**MODIFICA** la sezione errore (righe 209-220):

**TROVA**:
```dart
          // Error message
          if (chatState.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                chatState.error!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
```

**SOSTITUISCI con**:
```dart
          // Error message with retry button
          if (chatState.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    chatState.error!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_lastFailedMessage != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        final message = _lastFailedMessage!;
                        ref.read(aIChatProvider.notifier).sendMessage(message);
                        _scrollToBottom();
                      },
                      icon: const Icon(AppIcons.refresh),
                      label: Text(context.l10n.retry),
                    ),
                  ],
                ],
              ),
            ),
```

---

### 6. Aggiungere feedback tattile su invio messaggio

**File**: `lib/features/ai_coach/presentation/widgets/ai_input_bar.dart`

**Aggiungi import** in cima:
```dart
import 'package:flutter/services.dart';
```

**Linea**: 54-59

**TROVA**:
```dart
  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }
```

**SOSTITUISCI con**:
```dart
  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }
```

---

### 7. Aggiungere suggerimenti iniziali (onboarding)

**File**: `lib/features/ai_coach/presentation/screens/ai_coach_screen.dart`

**AGGIUNGI** questo widget helper alla fine del file, prima della chiusura della classe:

```dart
  Widget _buildSuggestionChips(BuildContext context) {
    final suggestions = [
      context.l10n.aiCoachSuggestion1,
      context.l10n.aiCoachSuggestion2,
      context.l10n.aiCoachSuggestion3,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.aiCoachSuggestionsTitle,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  ref.read(aIChatProvider.notifier).sendMessage(suggestion);
                  _scrollToBottom();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
```

**MODIFICA** il body della Scaffold per includere i suggerimenti quando la chat ha solo il disclaimer:

**TROVA** (nella ListView.builder, circa riga 180-204):
```dart
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatState.messages.length,
```

**SOSTITUISCI con**:
```dart
          // Messages list
          Expanded(
            child: Column(
              children: [
                // Show suggestions when chat is empty (only disclaimer)
                if (chatState.messages.length <= 1)
                  _buildSuggestionChips(context),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: chatState.messages.length,
```

E **aggiungi** la chiusura del Column dopo la ListView:
```dart
                  ),
                ),
              ],
            ),
          ),
```

**AGGIUNGI** le traduzioni:

**File**: `assets/i18n/app_en.arb`
```json
"aiCoachSuggestionsTitle": "Try asking:",
"aiCoachSuggestion1": "What should I train today?",
"aiCoachSuggestion2": "How is my bench press progressing?",
"aiCoachSuggestion3": "How many workouts did I do this week?",
```

**File**: `assets/i18n/app_it.arb`
```json
"aiCoachSuggestionsTitle": "Prova a chiedere:",
"aiCoachSuggestion1": "Cosa alleno oggi?",
"aiCoachSuggestion2": "Come sta andando la mia panca?",
"aiCoachSuggestion3": "Quanti allenamenti ho fatto questa settimana?",
```

---

## 🟡 PRIORITÀ BASSA

### 8. Cleanup rate limit (opzionale)

Il rate limit attuale è impostato a 999999 messaggi/giorno, quindi è praticamente inutile.

**Opzione A**: Rimuovere completamente il rate limiting
**Opzione B**: Implementare un vero limite (es. 50 messaggi/giorno per free tier)

Per ora si può lasciare così, ma è codice morto.

---

### 9. Split Tool Executor (refactoring futuro)

**File**: `lib/features/ai_coach/data/services/ai_tool_executor.dart` (1200+ righe)

Suggerimento per refactoring futuro:
```
lib/features/ai_coach/data/services/
├── ai_tool_executor.dart           # Coordinator
├── tools/
│   ├── workout_tools.dart          # getWorkoutStats, getWorkoutHistory, etc.
│   ├── body_measurement_tools.dart # getBodyProgress, addBodyMeasurement
│   ├── analytics_tools.dart        # get1RMHistory, getWeeklyVolume, etc.
│   └── template_tools.dart         # generateTemplate
```

---

## ✅ CHECKLIST IMPLEMENTAZIONE

```
[ ] 1. Parallelizzare chiamate AnalyticsAggregator
[ ] 2. Aggiungere timeout su stream
[ ] 3. Prevenire race condition
[ ] 4. Localizzare placeholder input
[ ] 5. Aggiungere retry button
[ ] 6. Feedback tattile su invio
[ ] 7. Suggerimenti iniziali onboarding
[ ] 8. (Opzionale) Cleanup rate limit
[ ] 9. (Futuro) Split tool executor
```

---

## 🧪 TESTING

Dopo l'implementazione, testare:

1. **Performance**: Verificare che il tempo di risposta sia migliorato
2. **Race condition**: Provare a inviare messaggi rapidamente
3. **Timeout**: Simulare rete lenta e verificare che non si blocchi
4. **UI**: Verificare retry button, suggerimenti, feedback tattile
5. **Localizzazione**: Testare in inglese e italiano

```bash
# Esegui analisi statica
flutter analyze

# Rigenera localizzazioni
flutter gen-l10n

# Esegui test
flutter test test/features/ai_coach/
```

---

## 🚀 COMANDI RAPIDI

```bash
# Prima di iniziare - verifica stato
flutter analyze lib/features/ai_coach/

# Dopo modifiche ai file .arb
flutter gen-l10n

# Verifica completa
flutter analyze && flutter test test/features/ai_coach/

# Se qualcosa non funziona, ripristina
git checkout -- lib/features/ai_coach/
```

---

## 💡 TIPS PER L'IMPLEMENTAZIONE

1. **Usa Edit tool** con `old_string` e `new_string` per modifiche precise
2. **Leggi sempre il file** prima di modificarlo per avere contesto
3. **Un fix alla volta** - verifica che compili prima di passare al successivo
4. **Se un fix fallisce** - non andare avanti, risolvi prima
5. **Commit frequenti** - dopo ogni fix funzionante

---

## 📊 EXECUTIVE SUMMARY

**Situazione attuale**: L'AI Coach funziona ma ha problemi di performance (chiamate sequenziali) e UX (nessun retry, nessun onboarding).

**Obiettivo**: Migliorare tempo risposta del 50-70% e UX generale.

**Effort totale stimato**: ~2-3 ore per tutti i fix

**Rischio**: Basso - tutti i fix sono isolati e retrocompatibili

**ROI**: Alto - miglioramenti significativi con poco sforzo

---

## 📝 NOTE FINALI

- Tutti i fix sono retrocompatibili
- Nessuna modifica al database o alle API
- I fix possono essere implementati in ordine qualsiasi (rispettando dipendenze)
- Priorità alta = impatto maggiore su performance/stabilità
- Il documento è auto-contenuto: un'altra sessione può implementare tutto senza contesto aggiuntivo
