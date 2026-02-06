# Rest Timer Tracking - Design Document

**Data:** 2026-02-06
**Status:** Approvato
**Autore:** Claude + Michele

---

## Obiettivo

Tracciare il comportamento dell'utente con il timer di recupero per ottenere insights sulla padronanza del peso:

- **Timer saltato** (skip) → L'utente padroneggia il peso, pronto prima del tempo
- **Timer esteso** (+30s) → L'utente ha bisogno di più recupero, possibile fatica

Questo dato permette suggerimenti automatici su quando aumentare/diminuire il peso.

---

## Decisioni di Design

| Aspetto | Decisione | Motivazione |
|---------|-----------|-------------|
| **Dove salvare i dati** | Nel `ExerciseSet` | Granularità per-set, storico completo |
| **UI per +30s** | Bubble dropdown al tap sul timer | Premium feel, no conflitti gesti |
| **Posizionamento bubble** | Sotto il timer | Dropdown naturale, non copre il timer |
| **Effetti visivi** | Spring animation, ombre profonde, haptic | Esperienza premium e tangibile |

---

## UI Design: Timer Action Bubble

### Comportamento

```
IDLE:        [⏱️ Rest]           → tap apre modal durata (invariato)

RUNNING:     [⏱️ 1:23 ━━━]       → tap apre bubble azioni
                  ↓
             ┌─────────────┐
             │  ⏸️ Pausa   │
             │  +30s ⏱️+   │
             │  ⏭️ Salta   │
             └─────────────┘

PAUSED:      [⏱️ 1:23 ⏸️]        → tap riprende (invariato)
```

### Azioni nel Bubble

| Azione | Icona | Colore | Haptic | Effetto |
|--------|-------|--------|--------|---------|
| Pausa | `AppIcons.pause` | Primary | `selectionClick` | Pausa timer |
| +30s | `AppIcons.timerAdd` | Success/Green | `mediumImpact` | Aggiunge 30s |
| Salta | `AppIcons.skipNext` | Warning/Amber | `heavyImpact` | Salta e traccia |

### Dismissal

- Tap fuori bubble → chiude (timer continua)
- Timer scade → bubble si chiude automaticamente
- Azione selezionata → chiude dopo esecuzione

---

## Animazioni Premium

### Apertura Bubble (350ms)

```dart
// Curva: Curves.elasticOut
AnimatedBuilder(
  animation: CurvedAnimation(
    parent: controller,
    curve: Curves.elasticOut,
  ),
  builder: (context, child) => Transform.scale(
    scale: 0.8 + (0.2 * animation.value),
    child: Opacity(
      opacity: animation.value,
      child: Transform.translate(
        offset: Offset(0, -10 * (1 - animation.value)),
        child: child,
      ),
    ),
  ),
)
```

### Chiusura Bubble (200ms)

```dart
// Curva: Curves.easeInBack (risucchio)
// Scala: 1.0 → 0.9
// Opacità: 1 → 0
// Offset Y: verso l'alto
```

### Press Bottoni (150ms)

```dart
// Touch down
Transform.scale(scale: 0.95)
// Ombra ridotta del 50%

// Touch up
Spring animation back to 1.0
```

---

## Stile Visivo

### Bubble Container

```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surface.withOpacity(0.98),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: context.colors.outline.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      // Ombra principale (profondità)
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 24,
        offset: Offset(0, 12),
        spreadRadius: -4,
      ),
      // Ombra secondaria (definizione bordi)
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

### Triangolo Connettore

```dart
CustomPaint(
  painter: BubbleArrowPainter(
    color: context.colors.surface.withOpacity(0.98),
    shadowColor: Colors.black.withOpacity(0.1),
  ),
)
```

---

## Data Model

### Modifiche a `ExerciseSet`

```dart
class ExerciseSet {
  // ... campi esistenti ...

  /// Timer di recupero saltato prima di questo set?
  /// true = utente ha premuto "Salta" prima che il timer finisse
  final bool restTimerSkipped;

  /// Secondi rimanenti quando il timer è stato saltato
  /// Esempio: timer 90s, saltato a 45s → restTimerSecondsRemaining = 45
  /// null se timer completato normalmente o non saltato
  final int? restTimerSecondsRemaining;

  /// Secondi totali aggiunti al timer durante il recupero
  /// Esempio: premuto +30s due volte → restTimerSecondsAdded = 60
  /// null o 0 se nessuna estensione
  final int? restTimerSecondsAdded;

  /// Tempo di recupero effettivo in secondi
  /// Calcolato: configuredRestTime - secondsRemaining + secondsAdded
  final int? actualRestSeconds;
}
```

### Modifiche a `UnifiedTimerState`

```dart
class UnifiedTimerState {
  // ... campi esistenti ...

  /// Contatore dei secondi aggiunti durante questo timer
  /// Reset a 0 quando il timer viene avviato
  final int secondsAdded; // default 0
}
```

### JSON Serialization

```dart
// ExerciseSet.toJson()
{
  // ... existing fields ...
  'restTimerSkipped': restTimerSkipped,
  'restTimerSecondsRemaining': restTimerSecondsRemaining,
  'restTimerSecondsAdded': restTimerSecondsAdded,
  'actualRestSeconds': actualRestSeconds,
}

// ExerciseSet.fromJson()
restTimerSkipped: json['restTimerSkipped'] ?? false,
restTimerSecondsRemaining: json['restTimerSecondsRemaining'] as int?,
restTimerSecondsAdded: json['restTimerSecondsAdded'] as int?,
actualRestSeconds: json['actualRestSeconds'] as int?,
```

---

## Flow di Persistenza

```
┌─────────────────────────────────────────────────────────────────┐
│                       TIMER LIFECYCLE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Set N completato                                                │
│       │                                                          │
│       ▼                                                          │
│  Timer Start (configuredRestTime seconds)                        │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────┐                                                     │
│  │ Running │◄────────────────────────────────┐                   │
│  └────┬────┘                                 │                   │
│       │                                      │                   │
│       ├──── Tap ────► Bubble apre            │                   │
│       │                   │                  │                   │
│       │                   ├── Pausa ──► Timer pausa              │
│       │                   │                  │                   │
│       │                   ├── +30s ──► secondsAdded += 30        │
│       │                   │             timer += 30s             │
│       │                   │             chiudi bubble ───────────┘
│       │                   │                                      │
│       │                   └── Salta ──► GOTO Skip                │
│       │                                                          │
│       ├──── Skip (long-press O bubble) ────►                     │
│       │                                                          │
│       │     Salva per Set N+1:                                   │
│       │       - restTimerSkipped: true                           │
│       │       - restTimerSecondsRemaining: remainingSeconds      │
│       │       - restTimerSecondsAdded: secondsAdded              │
│       │       - actualRestSeconds: elapsed                       │
│       │                                                          │
│       └──── Complete (timer = 0) ────►                           │
│                                                                  │
│             Salva per Set N+1:                                   │
│               - restTimerSkipped: false                          │
│               - restTimerSecondsRemaining: null                  │
│               - restTimerSecondsAdded: secondsAdded              │
│               - actualRestSeconds: totalDuration + secondsAdded  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Integrazione Live Activity iOS

La Live Activity già supporta il bottone +30s. Sincronizzazione:

### Quando iOS chiama `extendRestTimerFromLiveActivity`:

```dart
Future<void> extendRestTimerFromLiveActivity(int additionalSeconds) async {
  // 1. Aggiorna stato timer
  state = state?.copyWith(
    remainingSeconds: state!.remainingSeconds + additionalSeconds,
    totalDurationSeconds: state!.totalDurationSeconds + additionalSeconds,
    secondsAdded: state!.secondsAdded + additionalSeconds, // NUOVO
  );

  // 2. Aggiorna Live Activity (già gestito)
  // 3. Notifica Watch (già gestito)
  // 4. Salva stato
  await _saveState();
}
```

### Consistenza Flutter ↔ iOS

| Sorgente | Azione | Risultato |
|----------|--------|-----------|
| Flutter bubble +30s | `addTime(30)` | Aggiorna LA + Watch + state |
| iOS LA button +30s | `extendRestTimerFromLiveActivity(30)` | Aggiorna Flutter state |
| Watch button +30s | Via WatchConnectivity | Aggiorna Flutter + LA |

---

## Utilizzo Dati: Insights Futuri

### Analisi Pattern di Recupero

```dart
extension RestTimeInsights on List<ExerciseSet> {

  /// Calcola il "Rest Efficiency Score" per l'esercizio
  /// 100 = perfetto (mai esteso, qualche skip)
  /// < 50 = fatica (molte estensioni)
  double get restEfficiencyScore {
    if (isEmpty) return 100;

    int totalSkipBonus = 0;
    int totalExtendPenalty = 0;

    for (final set in this) {
      // Skip = bonus (padronanza)
      if (set.restTimerSkipped && set.restTimerSecondsRemaining != null) {
        totalSkipBonus += set.restTimerSecondsRemaining!;
      }
      // Extend = penalty (fatica)
      if (set.restTimerSecondsAdded != null && set.restTimerSecondsAdded! > 0) {
        totalExtendPenalty += set.restTimerSecondsAdded!;
      }
    }

    // Normalizza su scala 0-100
    final netScore = totalSkipBonus - totalExtendPenalty;
    return (100 + netScore).clamp(0, 150).toDouble();
  }

  /// Suggerisce azione sul peso basata sui pattern
  WeightSuggestion get weightSuggestion {
    final skippedRatio = where((s) => s.restTimerSkipped).length / length;
    final extendedRatio = where((s) =>
      (s.restTimerSecondsAdded ?? 0) > 0
    ).length / length;

    if (skippedRatio >= 0.8) {
      return WeightSuggestion.increase;
      // "Hai saltato il timer nell'80% dei set - considera +2.5kg"
    }
    if (extendedRatio >= 0.5) {
      return WeightSuggestion.decrease;
      // "Hai esteso il timer nel 50% dei set - considera -2.5kg"
    }
    return WeightSuggestion.maintain;
  }
}

enum WeightSuggestion { increase, maintain, decrease }
```

### Visualizzazione Storico

```
Panca Piana - Ultimi 4 allenamenti:

12 Gen │ ██████████ 100% │ Skip: 3 │ +30s: 0 │ ↗️ Aumenta
19 Gen │ ████████░░  80% │ Skip: 2 │ +30s: 1 │ ✓ Mantieni
26 Gen │ ██████░░░░  60% │ Skip: 0 │ +30s: 2 │ ⚠️ Attenzione
02 Feb │ ████░░░░░░  40% │ Skip: 0 │ +30s: 3 │ ↘️ Riduci
```

---

## File da Modificare

### Domain Layer

| File | Modifiche |
|------|-----------|
| `lib/features/workout/domain/entities/exercise.dart` | Aggiungere 4 campi a `ExerciseSet` |
| `lib/features/timer/domain/models/unified_timer_state.dart` | Aggiungere `secondsAdded` |

### Presentation Layer

| File | Modifiche |
|------|-----------|
| `lib/features/workout/presentation/widgets/header_rest_timer.dart` | Nuovo widget `TimerActionBubble` |
| `lib/features/timer/presentation/providers/unified_timer_provider.dart` | Gestire `secondsAdded`, passare dati al set |

### Data Layer

| File | Modifiche |
|------|-----------|
| `lib/features/workout/data/models/workout_model.dart` | Serializzazione nuovi campi |

### Nuovi File

| File | Contenuto |
|------|-----------|
| `lib/features/workout/presentation/widgets/timer_action_bubble.dart` | Widget bubble con animazioni |

---

## Checklist Implementazione

### Fase 1: Data Model
- [ ] Aggiungere campi a `ExerciseSet`
- [ ] Aggiungere `secondsAdded` a `UnifiedTimerState`
- [ ] Aggiornare serializzazione JSON
- [ ] Aggiornare `copyWith` methods

### Fase 2: Timer Provider
- [ ] Tracciare `secondsAdded` durante `addTime()`
- [ ] Reset `secondsAdded` quando timer parte
- [ ] Passare dati al set quando timer completa/skip

### Fase 3: UI Bubble
- [ ] Creare `TimerActionBubble` widget
- [ ] Implementare animazioni apertura/chiusura
- [ ] Implementare press effects sui bottoni
- [ ] Aggiungere triangolo connettore
- [ ] Integrare in `HeaderRestTimer`

### Fase 4: Integrazione
- [ ] Sincronizzare con Live Activity iOS
- [ ] Sincronizzare con Apple Watch
- [ ] Test end-to-end

### Fase 5: Analytics (Futuro)
- [ ] Implementare `RestTimeInsights` extension
- [ ] UI per visualizzare pattern
- [ ] Suggerimenti automatici peso

---

## Note Tecniche

### Posizionamento Bubble

Usare `OverlayEntry` o `showMenu` per posizionare il bubble sotto il timer senza modificare il layout dell'header.

```dart
final RenderBox timerBox = timerKey.currentContext!.findRenderObject() as RenderBox;
final Offset timerPosition = timerBox.localToGlobal(Offset.zero);
final Size timerSize = timerBox.size;

// Posiziona bubble centrato sotto il timer
final bubblePosition = Offset(
  timerPosition.dx + (timerSize.width / 2) - (bubbleWidth / 2),
  timerPosition.dy + timerSize.height + 8, // 8px gap
);
```

### Accessibilità

- Bubble deve essere navigabile con VoiceOver/TalkBack
- Focus trap dentro il bubble quando aperto
- Announce delle azioni disponibili
- Escape/back button chiude bubble

---

## Rischi e Mitigazioni

| Rischio | Probabilità | Mitigazione |
|---------|-------------|-------------|
| Bubble copre contenuto importante | Media | Dismissal facile, auto-close |
| Conflitto con gesti esistenti | Bassa | Tap su running ora apre bubble invece di pausare |
| Dati non sincronizzati iOS ↔ Flutter | Media | Single source of truth in provider |
| Performance animazioni | Bassa | Usare `AnimatedBuilder` ottimizzato |

---

## Timeline Stimata

| Fase | Effort |
|------|--------|
| Data Model | 1-2 ore |
| Timer Provider | 2-3 ore |
| UI Bubble + Animazioni | 4-6 ore |
| Integrazione LA/Watch | 2-3 ore |
| Testing | 2-3 ore |
| **Totale** | **~2 giorni** |

---

## Appendice: Localizzazioni

```arb
// app_en.arb
"timerActionPause": "Pause",
"timerActionExtend": "+30s",
"timerActionSkip": "Skip",
"timerExtendedBy": "Extended by {seconds}s",
"timerSkippedWith": "Skipped with {seconds}s remaining"

// app_it.arb
"timerActionPause": "Pausa",
"timerActionExtend": "+30s",
"timerActionSkip": "Salta",
"timerExtendedBy": "Esteso di {seconds}s",
"timerSkippedWith": "Saltato con {seconds}s rimanenti"
```
