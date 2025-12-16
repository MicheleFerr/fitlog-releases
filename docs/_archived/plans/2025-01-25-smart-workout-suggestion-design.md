# Smart Workout Suggestion - Design Document

**Data**: 2025-01-25
**Status**: Validato, pronto per implementazione
**Complexity**: MEDIUM (v1), HIGH (v2)
**References**: Fitbod algorithm, JMIR 2024, Nature 2025, Bartolomei 2017

---

## Obiettivo

Sostituire il pulsante "inizia workout da routine" (rimosso) con un sistema intelligente che suggerisce il template migliore basandosi su:
1. Tempo trascorso dall'ultimo allenamento per gruppo muscolare
2. Tipo di esercizio (4 categorie: compound_heavy/medium, isolation_heavy/light)
3. Volume e RPE dell'ultima sessione
4. CNS fatigue (compound heavy)
5. Antagonist muscle synergy
6. User feedback tracking (rifiuti)

---

## Fondamenti Scientifici

| Fatto | Fonte | Implicazione |
|-------|-------|--------------|
| Volume alto recupera più lentamente di intensità alta | Bartolomei et al., 2017 | Formula include volume decay |
| CNS fatigue da compound heavy = 72-96h | Nature 2025 | Aggiungi `cnsStress` factor |
| Antagonist muscles affect readiness | Fitbod algorithm | Petto affatica tricipiti |
| Recovery varia DENTRO categoria compound | JMIR 2024 | 4 varianti MovementType |
| RPE è proxy affidabile di danneggiamento muscolare | Foster et al. | RPE nel calcolo |

### Recovery Time per MovementType

| MovementType | Esempi | Recovery | CNS Stress |
|--------------|--------|----------|------------|
| `compound_heavy` | Squat, Deadlift | 96h (4d) | HIGH |
| `compound_medium` | Bench, Row, OHP | 72h (3d) | MEDIUM |
| `isolation_heavy` | Leg Press, Cable Row | 72h (3d) | LOW |
| `isolation_light` | Curl, Leg Ext, Fly | 48h (2d) | NONE |

---

## Algoritmo

### v1 (Launch) - Fitbod-Lite

```dart
double calculateMuscleReadiness(MuscleGroup muscle, List<Workout> history) {
  final daysSince = getDaysSinceLastWorkout(muscle, history);
  final lastSession = getLastSessionForMuscle(muscle, history);

  // Factor 1: Recovery giorni vs optimal
  final optimalDays = getOptimalRecoveryDays(lastSession.dominantMovementType);
  final recoveryRatio = daysSince / optimalDays;

  // Factor 2: Volume fatigue decay
  final volumeFatigue = lastSession.totalVolume / maxSessionVolume;
  final volumeDecay = math.exp(-volumeFatigue * 0.5);

  // Factor 3: CNS stress (compound heavy = 0.7 penalty)
  final cnsStress = lastSession.hasCompoundHeavy ? 0.7 : 1.0;

  return (recoveryRatio * volumeDecay * cnsStress).clamp(0.0, 3.0);
}
```

**Esempio v1:**
- Petto dopo Push Day (5 giorni fa, bench press = compound_medium)
  - recoveryRatio = 5 / 3 = 1.67
  - volumeDecay = e^(-0.4) = 0.67
  - cnsStress = 1.0 (no compound heavy)
  - **readiness = 1.67 × 0.67 × 1.0 = 1.12** ✅ Ready

- Gambe dopo Leg Day (2 giorni fa, squat = compound_heavy)
  - recoveryRatio = 2 / 4 = 0.5
  - volumeDecay = e^(-0.6) = 0.55
  - cnsStress = 0.7 (CNS stressed)
  - **readiness = 0.5 × 0.55 × 0.7 = 0.19** ❌ Not ready

### v2 (Futuro) - Full Fitbod

```dart
double calculateMuscleReadiness(MuscleGroup muscle, List<Workout> history) {
  // ... v1 factors ...

  // Factor 4: Antagonist synergy
  final antagonist = getAntagonistMuscle(muscle);
  final antagonistReadiness = calculateMuscleReadiness(antagonist, history);
  final antagonistPenalty = antagonistReadiness < 0.7 ? 0.8 : 1.0;

  // Factor 5: User feedback penalty
  final rejectionPenalty = getUserRejectionPenalty(muscle);

  return (recoveryRatio * volumeDecay * cnsStress * antagonistPenalty * rejectionPenalty)
    .clamp(0.0, 3.0);
}
```

### Antagonist Muscle Map

```dart
const antagonistMap = {
  MuscleGroup.chest: MuscleGroup.back,
  MuscleGroup.back: MuscleGroup.chest,
  MuscleGroup.biceps: MuscleGroup.triceps,
  MuscleGroup.triceps: MuscleGroup.biceps,
  MuscleGroup.shoulders: MuscleGroup.back,
  MuscleGroup.legs: null, // No direct antagonist
  MuscleGroup.core: null,
};
```

---

## Template Matching (con Workload Normalization)

```dart
double getTemplateMatchScore(
  WorkoutTemplate template,
  MuscleGroup primaryMuscle,
) {
  double totalStress = 0;

  for (var exercise in template.exercises) {
    if (exercise.targetMuscles.contains(primaryMuscle)) {
      // Stress = sets × movementMultiplier (non solo count!)
      final movementMultiplier = switch (exercise.movementType) {
        MovementType.compoundHeavy => 1.5,
        MovementType.compoundMedium => 1.2,
        MovementType.isolationHeavy => 1.0,
        MovementType.isolationLight => 0.8,
      };

      totalStress += exercise.sets.length * movementMultiplier;
    }
  }

  // Normalizza per workload totale → evita bias "più esercizi = meglio"
  final templateTotalSets = template.totalSets;
  if (templateTotalSets == 0) return 0;

  return totalStress / templateTotalSets; // Intensity ratio
}
```

**Esempio:**
- Push Day: 4 esercizi petto (20 set totali, stress=24)
- Upper Power: 1 esercizio petto (5 set totali, stress=7.5)

**Calcolo:**
- Push Day: 24 / 20 = **1.2**
- Upper Power: 7.5 / 5 = **1.5** → **Vince!** (più intenso per set)

---

## Modifiche Richieste

### 1. Nuovo Enum: `MovementType` (4 varianti)

```dart
// lib/features/workout/domain/entities/exercise.dart
enum MovementType {
  compoundHeavy,    // Squat, Deadlift → 96h recovery, HIGH CNS
  compoundMedium,   // Bench, Row, OHP → 72h recovery, MEDIUM CNS
  isolationHeavy,   // Leg Press, Cable Row → 72h recovery, LOW CNS
  isolationLight,   // Curl, Leg Ext, Fly → 48h recovery, NO CNS
}

extension MovementTypeExtension on MovementType {
  int get recoveryHours => switch (this) {
    MovementType.compoundHeavy => 96,
    MovementType.compoundMedium => 72,
    MovementType.isolationHeavy => 72,
    MovementType.isolationLight => 48,
  };

  double get cnsStressFactor => switch (this) {
    MovementType.compoundHeavy => 0.7,  // 30% penalty
    MovementType.compoundMedium => 0.85, // 15% penalty
    MovementType.isolationHeavy => 1.0,  // No penalty
    MovementType.isolationLight => 1.0,  // No penalty
  };
}
```

### 2. Aggiungere campo a `Exercise`

```dart
class Exercise {
  // ... existing fields
  final MovementType? movementType; // NEW - nullable per backward compat
}
```

### 3. Nuovo Entity: `SuggestionFeedback` (User Override Tracking)

```dart
// lib/features/workout/domain/entities/suggestion_feedback.dart

/// Motivi di rifiuto con implicazioni diverse per l'algoritmo
enum RejectionReason {
  tooTired,    // Penalizza template per 2-3 giorni (decay exponenziale)
  noTime,      // NON influenza ranking (vincolo esterno)
  injury,      // Esclude muscoli specifici per 7-14 giorni
  notInMood,   // Lieve penalty (0.8) per preferenza personale
  other,       // Lieve penalty generico
}

class SuggestionFeedback {
  final String id;
  final String templateId;
  final String templateName;
  final bool accepted; // true = utente ha iniziato il workout
  final DateTime timestamp;
  final RejectionReason? reason; // NEW - motivo specifico del rifiuto

  // Factory per quando utente rifiuta
  factory SuggestionFeedback.rejected({
    required String templateId,
    required String templateName,
    required RejectionReason reason, // NOW REQUIRED
  });

  // Factory per quando utente accetta
  factory SuggestionFeedback.accepted({
    required String templateId,
    required String templateName,
  });
}
```

### 4. Nuovo Service: `WorkoutSuggestionService`

```dart
// lib/features/workout/domain/services/workout_suggestion_service.dart
class WorkoutSuggestionService {

  // ========== CONSTANTS ==========
  static const int minWorkoutsForSmartSuggestion = 3;
  static const double antagonistConflictThreshold = 0.6; // <60% = conflict

  /// Calcola readiness score per ogni gruppo muscolare
  Map<MuscleGroup, double> calculateMuscleReadiness(List<Workout> history);

  /// Trova il muscolo primario da allenare oggi
  MuscleGroup? getPrimaryMuscleForToday(Map<MuscleGroup, double> readiness);

  /// Ranking dei template per il muscolo primario
  List<TemplateSuggestion> rankTemplates(
    List<WorkoutTemplate> templates,
    MuscleGroup primaryMuscle,
    List<SuggestionFeedback> recentFeedback,
  );

  // ========== STATO CRITICO 1: INSUFFICIENT_DATA ==========

  /// Verifica se abbiamo abbastanza dati per suggerimenti intelligenti
  bool hasInsufficientData(List<Workout> history) {
    return history.length < minWorkoutsForSmartSuggestion;
  }

  /// Genera stato per utenti con dati insufficienti
  SuggestionState getInsufficientDataState(int currentWorkoutCount) {
    return SuggestionState.insufficientData(
      workoutsCompleted: currentWorkoutCount,
      workoutsRequired: minWorkoutsForSmartSuggestion,
      message: 'Stai costruendo il tuo storico ($currentWorkoutCount/$minWorkoutsForSmartSuggestion)',
    );
  }

  // ========== STATO CRITICO 2: ANTAGONIST_CONFLICT ==========

  /// Verifica se c'è conflitto con muscoli antagonisti
  bool hasAntagonistConflict(
    MuscleGroup primary,
    Map<MuscleGroup, double> readiness,
  ) {
    final antagonist = getAntagonistMuscle(primary);
    if (antagonist == null) return false;

    final antagonistReadiness = readiness[antagonist] ?? 1.0;
    return antagonistReadiness < antagonistConflictThreshold;
  }

  /// Ottieni dettagli del conflitto per mostrare warning
  AntagonistConflict? getAntagonistConflictDetails(
    MuscleGroup primary,
    Map<MuscleGroup, double> readiness,
  ) {
    final antagonist = getAntagonistMuscle(primary);
    if (antagonist == null) return null;

    final antagonistReadiness = readiness[antagonist] ?? 1.0;
    if (antagonistReadiness >= antagonistConflictThreshold) return null;

    return AntagonistConflict(
      primaryMuscle: primary,
      primaryReadiness: readiness[primary] ?? 0.0,
      antagonistMuscle: antagonist,
      antagonistReadiness: antagonistReadiness,
    );
  }

  // ========== STATO CRITICO 3: REASON-BASED PENALTY ==========

  /// Calcola penalty basato su MOTIVO del rifiuto (non solo count)
  double applyRejectionPenalty(
    String templateId,
    List<SuggestionFeedback> feedback,
  ) {
    double penalty = 1.0;

    final rejections = feedback.where(
      (f) => f.templateId == templateId && !f.accepted,
    );

    for (var f in rejections) {
      final daysSince = DateTime.now().difference(f.timestamp).inDays;

      switch (f.reason) {
        case RejectionReason.tooTired:
          // Decay exponenziale: 0.6 oggi, 0.7 domani, 0.85 tra 2 giorni
          penalty *= (1.0 - 0.4 * math.exp(-daysSince / 1.5));
          break;

        case RejectionReason.noTime:
          // Nessun penalty (vincolo esterno, non preferenza)
          break;

        case RejectionReason.injury:
          // Esclude il template per 14 giorni
          if (daysSince < 14) {
            penalty *= 0.0; // Template NON suggerito
          }
          break;

        case RejectionReason.notInMood:
        case RejectionReason.other:
        default:
          // Lieve penalty che decade in 3 giorni
          if (daysSince < 3) {
            penalty *= 0.8;
          }
          break;
      }
    }

    return penalty.clamp(0.0, 1.0);
  }
}

/// Dettagli di un conflitto antagonista
class AntagonistConflict {
  final MuscleGroup primaryMuscle;
  final double primaryReadiness;
  final MuscleGroup antagonistMuscle;
  final double antagonistReadiness;

  const AntagonistConflict({
    required this.primaryMuscle,
    required this.primaryReadiness,
    required this.antagonistMuscle,
    required this.antagonistReadiness,
  });

  String get warningMessage =>
    '${primaryMuscle.name} pronto (${(primaryReadiness * 100).toInt()}%), '
    'ma ${antagonistMuscle.name} ancora affaticato (${(antagonistReadiness * 100).toInt()}%)';
}
```

### 5. Update `SmartWorkoutCTA` Widget

Sostituire lo stato "disabled" con il suggerimento intelligente.

---

## UI Design (Minimale - Solo 2 Data Point)

> **UX Research**: >3 data points causa "decision paralysis". Massimo 2 info visibili.

### Stato 0: INSUFFICIENT_DATA (nuovo utente, <3 workout)

```
┌─────────────────────────────────────────────┐
│                                             │
│  🎯 Allenati                                │
│     Stai costruendo il tuo storico          │
│     (2/3 sessioni completate)               │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │    ▶  Sfoglia i miei template       │    │
│  └─────────────────────────────────────┘    │
│                                             │
│        [O crea un nuovo workout]            │
└─────────────────────────────────────────────┘
```

**Importante**: Sistema continua a collezionare dati in background. Dopo 3 workout → passa a SMART_CTA.

### Stato Default (Super Minimale)

```
┌─────────────────────────────────────────────┐
│                                             │
│  🎯 Push Day                                │
│     Petto: 5 giorni • 112% ready            │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │         ▶  Inizia                   │    │
│  └─────────────────────────────────────┘    │
│                                             │
│           [Tap per altre opzioni]           │
└─────────────────────────────────────────────┘
```

**Solo 2 info:**
1. **Muscolo chiave** + giorni ("Petto: 5 giorni")
2. **Readiness %** ("112% ready")

### Stato WARNING_MODE (antagonist conflict)

```
┌─────────────────────────────────────────────┐
│                                             │
│  ⚠️ Push Day - Con Avviso                   │
│     Petto pronto (90%)                      │
│     ⚠️ Ma tricipiti ancora affaticati (40%) │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │    ▶  Comunque, inizia              │    │
│  └─────────────────────────────────────┘    │
│                                             │
│           [Altre opzioni]                   │
└─────────────────────────────────────────────┘
```

**Comportamento**: Utente può ignorare warning e procedere. Warning è informativo, non bloccante.

### Tap "Altre opzioni" → Bottom Sheet

```
┌─────────────────────────────────────────────┐
│  Scegli un workout                          │
│  ───────────────────────────────────────    │
│                                             │
│  🏆 Push Day (consigliato)                  │
│     Petto: 5g • 112% ready                  │
│                                             │
│  💪 Upper Body                              │
│     Schiena: 4g • 95% ready                 │
│                                             │
│  🦵 Leg Day                                 │
│     Gambe: 3g • 78% ready                   │
│                                             │
│  ───────────────────────────────────────    │
│  😴 Oggi sono troppo stanco                 │
│  ───────────────────────────────────────    │
└─────────────────────────────────────────────┘
```

### Tap "Oggi sono troppo stanco" → REASON_PICKER

```
┌─────────────────────────────────────────────┐
│  Perché non vuoi allenarti oggi?            │
│  ───────────────────────────────────────    │
│                                             │
│  ○ 😴 Sono troppo stanco                    │
│  ○ ⏰ Non ho tempo                          │
│  ○ 🤕 Ho dolore/infortunio                  │
│  ○ 😐 Semplicemente non voglio              │
│  ○ ❓ Altro                                  │
│                                             │
│  ───────────────────────────────────────    │
│  [Annulla]              [Conferma]          │
└─────────────────────────────────────────────┘
```

**Implicazioni per l'algoritmo:**

| Motivo | Effetto | Durata |
|--------|---------|--------|
| `tooTired` | Penalizza template (0.6 → 1.0 decay) | 2-3 giorni |
| `noTime` | **Nessun effetto** sul ranking | - |
| `injury` | Esclude template completamente | 14 giorni |
| `notInMood` | Lieve penalty (0.8) | 3 giorni |
| `other` | Lieve penalty (0.8) | 3 giorni |

**Comportamento:**
```dart
// Salva SuggestionFeedback.rejected() con reason specifico
// L'algoritmo applicherà penalty diverso in base al motivo
```

---

## State Machine (Production-Ready)

```
                    ┌──────────────┐
                    │   APP OPEN   │
                    └──────┬───────┘
                           │
                           ▼
                ┌────────────────────────┐
                │ todayWorkout != null?  │
                └────────────┬───────────┘
                      │             │
                     YES           NO
                      │             │
                      ▼             ▼
             ┌────────────┐  ┌─────────────────┐
             │ REST_MODE  │  │ workouts >= 3?  │
             └────────────┘  └────────┬────────┘
                                  │         │
                                 YES       NO
                                  │         │
                                  ▼         ▼
                       ┌────────────────┐  ┌──────────────────┐
                       │ Calculate      │  │ INSUFFICIENT_    │
                       │ readiness      │  │ DATA (UI generic)│
                       └────────┬───────┘  └──────────────────┘
                                │
                                ▼
                     ┌──────────────────────┐
                     │ hasAntagonistConflict?│
                     └────────┬─────────────┘
                           │      │
                          YES    NO
                           │      │
                           ▼      ▼
                    ┌────────┐  ┌──────────┐
                    │WARNING │  │SMART_CTA │
                    │_MODE   │  │          │
                    └────┬───┘  └────┬─────┘
                         │           │
             ┌───────────┴───────────┼───────────┐
             ▼                       ▼           ▼
      ┌────────────┐          ┌────────────┐  ┌────────┐
      │  ACCEPT    │          │  OPTIONS   │  │ REJECT │
      │(di warning)│          │  (sheet)   │  │        │
      └─────┬──────┘          └─────┬──────┘  └────┬───┘
            │                       │              │
            ▼                       ▼              ▼
       ┌────────┐           ┌────────────┐  ┌──────────────┐
       │WORKOUT │           │  CHOOSE    │  │ REASON_      │
       │STARTED │           │  ALT       │  │ PICKER       │
       └────────┘           └────────────┘  │              │
                                            │ ┌──────────┐ │
                                            │ │SAVE      │ │
                                            │ │FEEDBACK  │ │
                                            │ └──────────┘ │
                                            └──────────────┘
```

**Stati totali:** 8 (REST_MODE, INSUFFICIENT_DATA, SMART_CTA, WARNING_MODE, OPTIONS, REASON_PICKER, ACCEPT, REJECT)

---

## Fallback Chain

1. **Se storico muscolare disponibile (≥3 workout)** → usa readinessScore + antagonist check
2. **Se <3 workout** → INSUFFICIENT_DATA state
3. **Se nessun template** → "Crea il tuo primo workout"

---

## File da Modificare/Creare

| File | Azione |
|------|--------|
| `lib/features/workout/domain/entities/exercise.dart` | Add `MovementType` enum + field |
| `lib/features/workout/domain/entities/suggestion_feedback.dart` | CREATE - with `RejectionReason` enum |
| `lib/features/workout/domain/entities/suggestion_state.dart` | CREATE - union type per stati UI |
| `lib/features/workout/domain/entities/antagonist_conflict.dart` | CREATE |
| `lib/features/workout/domain/services/workout_suggestion_service.dart` | CREATE |
| `lib/features/workout/presentation/providers/workout_suggestion_provider.dart` | CREATE |
| `lib/features/home/presentation/widgets/smart_workout_cta.dart` | UPDATE - 4 stati UI |
| `lib/features/home/presentation/widgets/reason_picker_dialog.dart` | CREATE |
| `assets/i18n/app_en.arb` | Add localization keys |
| `assets/i18n/app_it.arb` | Add localization keys |

---

## Task Breakdown

### v1 (Launch) - Production-Ready

**Domain Layer:**
- [ ] Add `MovementType` enum (4 varianti + extension)
- [ ] Add `movementType` field to Exercise (nullable, backward compat)
- [ ] Create `RejectionReason` enum
- [ ] Create `SuggestionFeedback` entity (freezed)
- [ ] Create `AntagonistConflict` entity
- [ ] Create `SuggestionState` union type (insufficientData, smartCta, warningMode, restMode)

**Service Layer:**
- [ ] Create `WorkoutSuggestionService` con:
  - `calculateMuscleReadiness()` (con CNS + volume decay)
  - `hasInsufficientData()` check
  - `hasAntagonistConflict()` check
  - `applyRejectionPenalty()` reason-based

**Presentation Layer:**
- [ ] Create `workoutSuggestionProvider` (StateNotifier)
- [ ] Update `SmartWorkoutCTA` per 4 stati:
  - INSUFFICIENT_DATA
  - SMART_CTA
  - WARNING_MODE
  - REST_MODE (esistente)
- [ ] Create `ReasonPickerDialog` widget
- [ ] Add localizations (EN + IT) ~20 keys

**Testing:**
- [ ] Unit test `WorkoutSuggestionService`
- [ ] Widget test `SmartWorkoutCTA` per ogni stato
- [ ] Integration test con dati reali

### v2 (Futuro)

- [ ] Add `injuryFactor` calculation (track injured muscles)
- [ ] Add `intensityDecay` formula (RPE-based)
- [ ] Track `avgRPE` per muscle group over time
- [ ] Injury muscle picker UI (quando reason=injury)
- [ ] Analytics dashboard per tracking feedback patterns

---

## References

1. [Bartolomei et al., 2017 - Recovery comparison](https://paulogentil.com/pdf/Comparison%20of%C2%A0the%C2%A0recovery%20response%20from%C2%A0high-intensity%20and%C2%A0high-volume%20resistance%20exercise%20in%C2%A0trained%20men.pdf)
2. [Muscle & Fitness - Compound vs Isolation Recovery](https://www.muscleandfitness.com/flexonline/training/recovery-compound-vs-isolation-exercises/)
3. [PMC - RPE as proxy for muscle damage](https://pmc.ncbi.nlm.nih.gov/articles/PMC7457072/)
