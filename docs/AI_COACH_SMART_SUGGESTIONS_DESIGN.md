# AI Coach Smart Suggestions - Design Document

> **Status**: Proposta
> **Autore**: Claude AI
> **Data**: 2025-02-09
> **Ispirazione**: [Perplexity AI](https://www.perplexity.ai) autocomplete pattern

---

## 1. Problema

Quando l'utente scrive nella chat dell'AI Coach un nome di esercizio (es. "Panca Piana"), il sistema cerca un match esatto che potrebbe non esistere. L'utente deve conoscere il nome esatto dell'esercizio nel suo storico.

**Esempio problema attuale**:
```
User: "Qual è il mio massimale sulla panca?"
AI: Cerca "panca" → trova "Panca Piana" (0 sessioni) invece di "Panca Piana con Bilanciere" (57 sessioni)
```

---

## 2. Soluzione Proposta

Implementare un sistema di **Smart Suggestions** ispirato a [Perplexity AI](https://collabnix.com/perplexity-ai-review-2025-the-complete-guide-to-pros-cons-and-user-experience/):

- Mentre l'utente digita, analizzare il testo per rilevare nomi di esercizi
- Mostrare un dropdown con **suggerimenti contestuali cliccabili**
- Click su suggerimento → invia automaticamente la domanda formattata

### 2.1 Flusso UX

```
┌─────────────────────────────────────────────────────────────┐
│  AI Coach Chat                                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [User digita: "panca piana"]                               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 💡 Suggerimenti per "panca piana":                  │   │
│  │                                                      │   │
│  │  🏋️ Panca Piana con Bilanciere (57 sessioni)       │   │
│  │     • Qual è il mio massimale?                      │   │
│  │     • Come sta andando la progressione?             │   │
│  │     • Mostra gli ultimi allenamenti                 │   │
│  │                                                      │   │
│  │  🏋️ Panca Piana con Manubri (12 sessioni)          │   │
│  │     • Qual è il mio massimale?                      │   │
│  │     • Come sta andando la progressione?             │   │
│  │                                                      │   │
│  │  🏋️ Panca Piana (0 sessioni)                       │   │
│  │     (Nessun dato disponibile)                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ panca piana                                    [📤] │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Click su Suggerimento

Quando l'utente clicca su "Qual è il mio massimale?" sotto "Panca Piana con Bilanciere":

1. Il campo di input viene **sostituito** con: `Qual è il mio massimale sulla Panca Piana con Bilanciere?`
2. Il messaggio viene **inviato automaticamente**
3. Il dropdown si chiude

---

## 3. Architettura Tecnica

### 3.1 Componenti

```
┌────────────────────────────────────────────────────────────────┐
│                     AI Coach Chat Screen                        │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ChatMessageList                                          │  │
│  │  (messages, scrollController)                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SmartSuggestionsOverlay  ← NUOVO                        │  │
│  │  (isVisible, suggestions, onSelect)                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ChatInputField                                           │  │
│  │  (controller, onTextChanged, onSend)                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### 3.2 Nuovi File

```
lib/features/ai_coach/
├── data/
│   └── services/
│       └── exercise_suggestion_service.dart    ← NUOVO
├── domain/
│   └── entities/
│       └── exercise_suggestion.dart            ← NUOVO
└── presentation/
    ├── providers/
    │   └── exercise_suggestions_provider.dart  ← NUOVO
    └── widgets/
        ├── smart_suggestions_overlay.dart      ← NUOVO
        └── suggestion_card.dart                ← NUOVO
```

### 3.3 Entity: ExerciseSuggestion

```dart
/// Suggerimento per un esercizio trovato
class ExerciseSuggestion {
  const ExerciseSuggestion({
    required this.exerciseName,
    required this.sessionCount,
    required this.lastSessionDate,
    required this.suggestedQuestions,
  });

  final String exerciseName;
  final int sessionCount;
  final DateTime? lastSessionDate;
  final List<SuggestedQuestion> suggestedQuestions;

  bool get hasData => sessionCount > 0;
}

/// Domanda suggerita per un esercizio
class SuggestedQuestion {
  const SuggestedQuestion({
    required this.displayText,
    required this.fullQuestion,
    required this.icon,
  });

  final String displayText;     // "Qual è il mio massimale?"
  final String fullQuestion;    // "Qual è il mio massimale sulla Panca Piana con Bilanciere?"
  final IconData icon;
}
```

### 3.4 Service: ExerciseSuggestionService

```dart
/// Service per generare suggerimenti contestuali
class ExerciseSuggestionService {
  ExerciseSuggestionService({
    required this.analyticsRepo,
  });

  final AnalyticsRepository analyticsRepo;

  /// Template delle domande suggerite per ogni esercizio
  static const _questionTemplates = [
    (
      display: 'Qual è il mio massimale?',
      template: 'Qual è il mio massimale sulla {exercise}?',
      icon: Icons.fitness_center,
    ),
    (
      display: 'Come sta andando la progressione?',
      template: 'Come sta andando la mia progressione con {exercise}?',
      icon: Icons.trending_up,
    ),
    (
      display: 'Mostra gli ultimi allenamenti',
      template: 'Mostrami gli ultimi allenamenti con {exercise}',
      icon: Icons.history,
    ),
    (
      display: 'Consigli per migliorare',
      template: 'Dammi consigli per migliorare sulla {exercise}',
      icon: Icons.lightbulb_outline,
    ),
  ];

  /// Cerca esercizi che matchano la query e genera suggerimenti
  Future<List<ExerciseSuggestion>> getSuggestions({
    required String userId,
    required String query,
    int maxResults = 5,
  }) async {
    if (query.trim().length < 3) return [];

    final searchResult = await analyticsRepo.searchExercises(
      userId: userId,
      query: query.trim(),
    );

    return searchResult.fold(
      (failure) => [],
      (matches) {
        // Ordina: prima quelli con sessioni, poi per data più recente
        final sorted = [...matches]..sort((a, b) {
          if (a.sessions.isNotEmpty && b.sessions.isEmpty) return -1;
          if (a.sessions.isEmpty && b.sessions.isNotEmpty) return 1;
          if (a.sessions.isNotEmpty && b.sessions.isNotEmpty) {
            final aLatest = a.sessions.map((s) => s.date).reduce((x, y) => x.isAfter(y) ? x : y);
            final bLatest = b.sessions.map((s) => s.date).reduce((x, y) => x.isAfter(y) ? x : y);
            return bLatest.compareTo(aLatest);
          }
          return 0;
        });

        return sorted.take(maxResults).map((match) {
          final questions = _questionTemplates.map((t) {
            return SuggestedQuestion(
              displayText: t.display,
              fullQuestion: t.template.replaceAll('{exercise}', match.exerciseName),
              icon: t.icon,
            );
          }).toList();

          return ExerciseSuggestion(
            exerciseName: match.exerciseName,
            sessionCount: match.sessions.length,
            lastSessionDate: match.sessions.isNotEmpty
                ? match.sessions.map((s) => s.date).reduce((a, b) => a.isAfter(b) ? a : b)
                : null,
            suggestedQuestions: questions,
          );
        }).toList();
      },
    );
  }
}
```

### 3.5 Provider: ExerciseSuggestionsProvider

```dart
@riverpod
class ExerciseSuggestions extends _$ExerciseSuggestions {
  Timer? _debounceTimer;

  @override
  AsyncValue<List<ExerciseSuggestion>> build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const AsyncValue.data([]);
  }

  /// Aggiorna suggerimenti con debounce (300ms)
  void updateQuery(String query) {
    _debounceTimer?.cancel();

    if (query.trim().length < 3) {
      state = const AsyncValue.data([]);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      state = const AsyncValue.loading();

      try {
        final userAsync = await ref.read(currentUserProvider.future);
        final userId = userAsync?.uid;

        if (userId == null) {
          state = const AsyncValue.data([]);
          return;
        }

        final service = ref.read(exerciseSuggestionServiceProvider);
        final suggestions = await service.getSuggestions(
          userId: userId,
          query: query,
        );

        state = AsyncValue.data(suggestions);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  /// Nascondi suggerimenti
  void clear() {
    _debounceTimer?.cancel();
    state = const AsyncValue.data([]);
  }
}
```

### 3.6 Widget: SmartSuggestionsOverlay

```dart
/// Overlay che mostra i suggerimenti sopra l'input
class SmartSuggestionsOverlay extends ConsumerWidget {
  const SmartSuggestionsOverlay({
    super.key,
    required this.onSelect,
  });

  final void Function(String fullQuestion) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(exerciseSuggestionsProvider);

    return suggestionsAsync.when(
      loading: () => const SizedBox.shrink(), // Non mostrare loading
      error: (_, __) => const SizedBox.shrink(),
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Container(
          constraints: const BoxConstraints(maxHeight: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _SuggestionCard(
                suggestion: suggestion,
                onQuestionTap: onSelect,
              );
            },
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.onQuestionTap,
  });

  final ExerciseSuggestion suggestion;
  final void Function(String) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con nome esercizio e badge sessioni
        Row(
          children: [
            Icon(
              AppIcons.fitness,
              size: 16,
              color: suggestion.hasData
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suggestion.exerciseName,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _SessionBadge(count: suggestion.sessionCount),
          ],
        ),
        const SizedBox(height: 8),

        // Domande suggerite (solo se ha dati)
        if (suggestion.hasData)
          ...suggestion.suggestedQuestions.map((q) {
            return InkWell(
              onTap: () => onQuestionTap(q.fullQuestion),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  children: [
                    Icon(q.icon, size: 14, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      q.displayText,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          })
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              'Nessun dato disponibile',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        const Divider(height: 16),
      ],
    );
  }
}

class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: count > 0
            ? context.colors.primaryContainer
            : context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 0 ? '$count sessioni' : 'Nessuna',
        style: context.textTheme.labelSmall?.copyWith(
          color: count > 0
              ? context.colors.onPrimaryContainer
              : context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
```

### 3.7 Integrazione in ChatInputField

```dart
// In ai_coach_chat_screen.dart

class _ChatInput extends ConsumerStatefulWidget {
  // ...
}

class _ChatInputState extends ConsumerState<_ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Aggiorna suggerimenti con debounce
    ref.read(exerciseSuggestionsProvider.notifier).updateQuery(_controller.text);
  }

  void _onSuggestionSelected(String fullQuestion) {
    // 1. Pulisci suggerimenti
    ref.read(exerciseSuggestionsProvider.notifier).clear();

    // 2. Invia messaggio
    ref.read(aIChatProvider.notifier).sendMessage(fullQuestion);

    // 3. Pulisci input
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overlay suggerimenti (sopra l'input)
        SmartSuggestionsOverlay(
          onSelect: _onSuggestionSelected,
        ),

        // Input field esistente
        _buildInputField(),
      ],
    );
  }
}
```

---

## 4. Trigger Detection

### 4.1 Quando Mostrare Suggerimenti

| Condizione | Mostra? |
|------------|---------|
| Input < 3 caratteri | ❌ |
| Input contiene nome esercizio | ✅ |
| Input è una domanda completa | ❌ (es. "qual è il mio...") |
| Focus perso dall'input | ❌ (nascondi) |
| Utente sta scrollando chat | ❌ (nascondi) |

### 4.2 Pattern Rilevamento

```dart
/// Rileva se l'utente sta scrivendo un nome di esercizio
bool _shouldShowSuggestions(String text) {
  final trimmed = text.trim().toLowerCase();

  // Troppo corto
  if (trimmed.length < 3) return false;

  // È già una domanda completa (inizia con interrogativo)
  final questionStarters = ['qual', 'come', 'quanto', 'mostra', 'dimmi', 'cosa'];
  if (questionStarters.any((q) => trimmed.startsWith(q))) return false;

  // Potrebbe essere un nome esercizio
  return true;
}
```

---

## 5. Performance Considerations

### 5.1 Debounce
- **300ms** di debounce per evitare troppe chiamate durante la digitazione
- Cancella timer se l'utente continua a scrivere

### 5.2 Cache
- Cachare risultati di ricerca per query identiche
- TTL: 5 minuti (i dati analytics non cambiano frequentemente)

### 5.3 Lazy Loading
- Non caricare suggerimenti finché l'utente non inizia a scrivere
- Nessun loading indicator per evitare "flickering"

---

## 6. Accessibilità

- **Keyboard navigation**: frecce su/giù per navigare suggerimenti
- **Enter**: seleziona suggerimento evidenziato
- **Escape**: chiudi overlay
- **Screen reader**: annuncia numero di suggerimenti trovati

---

## 7. Analytics Events

```dart
// Quando l'utente seleziona un suggerimento
FirebaseAnalytics.instance.logEvent(
  name: 'ai_coach_suggestion_selected',
  parameters: {
    'exercise_name': suggestion.exerciseName,
    'question_type': selectedQuestion.displayText,
    'session_count': suggestion.sessionCount,
  },
);

// Quando i suggerimenti vengono mostrati
FirebaseAnalytics.instance.logEvent(
  name: 'ai_coach_suggestions_shown',
  parameters: {
    'query': query,
    'suggestions_count': suggestions.length,
  },
);
```

---

## 8. Mockup Visivo

```
┌─────────────────────────────────────────────────────────────┐
│  ← AI Coach                                            ⋮   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 👋 Ciao! Sono il tuo AI Coach di FitLog.           │   │
│  │                                                     │   │
│  │ ⚠️ Disclaimer: Non sono un medico...              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                                                             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 💡 Suggerimenti per "panca piana"                  │   │
│  │                                                     │   │
│  │ 🏋️ Panca Piana con Bilanciere          57 sessioni│   │
│  │   ├─ 💪 Qual è il mio massimale?                   │   │
│  │   ├─ 📈 Come sta andando la progressione?          │   │
│  │   ├─ 📅 Mostra gli ultimi allenamenti              │   │
│  │   └─ 💡 Consigli per migliorare                    │   │
│  │                                                     │   │
│  │ 🏋️ Panca Piana con Manubri             12 sessioni│   │
│  │   ├─ 💪 Qual è il mio massimale?                   │   │
│  │   └─ ...                                            │   │
│  │                                                     │   │
│  │ 🏋️ Panca Piana                          0 sessioni│   │
│  │   └─ Nessun dato disponibile                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ panca piana                                    [📤] │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 9. Effort Estimate

| Task | Complessità | Note |
|------|-------------|------|
| Entity `ExerciseSuggestion` | 🟢 Bassa | 30 min |
| Service `ExerciseSuggestionService` | 🟡 Media | 1-2 ore |
| Provider con debounce | 🟡 Media | 1 ora |
| Widget `SmartSuggestionsOverlay` | 🟡 Media | 2-3 ore |
| Integrazione in ChatScreen | 🟡 Media | 1-2 ore |
| Animazioni e polish | 🟢 Bassa | 1 ora |
| Testing | 🟡 Media | 2 ore |

**Totale stimato**: 8-12 ore

---

## 10. Future Enhancements

1. **Suggerimenti basati su contesto**: Se l'utente ha chiesto del "petto" prima, mostrare esercizi petto in cima
2. **Suggerimenti generici**: Non solo esercizi, ma anche "Come sta andando la mia settimana?" ecc.
3. **Learning**: Tracciare quali suggerimenti vengono cliccati e migliorare l'ordine
4. **Quick actions**: Bottoni rapidi sempre visibili ("Massimale", "Progressione", "Storico")

---

## 11. References

- [Perplexity AI Review 2025](https://collabnix.com/perplexity-ai-review-2025-the-complete-guide-to-pros-cons-and-user-experience/)
- [How to Use Perplexity AI](https://medium.com/@CherryZhouTech/how-to-use-perplexity-ai-complete-guide-for-smarter-searching-9ca4a89d151d)
- [Perplexity AI Explained](https://www.hixx.ai/blog/awesome-ai-tools/perplexity-ai-2025)
