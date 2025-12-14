# Custom Exercise Categorization - Design Document

**Date**: 2025-01-14
**Status**: Approved
**Feature**: Allow users to categorize custom exercises with focus, type, pattern for accurate Push/Pull analytics

---

## 1. Problem Statement

Custom exercises created by users lack proper categorization (focus muscles, compound/isolation, movement pattern), causing:
- Incorrect Push/Pull ratio calculations in analytics
- Missing muscle balance tracking
- Incomplete workout insights

**Goal**: Enable users to optionally categorize custom exercises to integrate them properly with analytics while warning about potential inconsistencies.

---

## 2. User Flow

### 2.1 Entry Points

Two entry points for creating/categorizing custom exercises:

#### A. Search Results - Quick Create
When searching for an exercise that doesn't exist:
```
┌─────────────────────────────────────────┐
│ 🔍 "Panca 30 gradi"                     │
├─────────────────────────────────────────┤
│ Panca Piana                        [+]  │
│ Panca Inclinata 45°               [+]  │
│ ─────────────────────────────────────── │
│ ➕ Crea "Panca 30 gradi"                │
│    Esercizio non trovato? Crealo!       │
└─────────────────────────────────────────┘
```

#### B. Exercise Card - Create Variant
From existing exercise in search results:
```
┌─────────────────────────────────────────┐
│ Panca Inclinata 45°               [⋮]  │
│ PETT, DELT ANT • Compound              │
├─────────────────────────────────────────┤
│ Menu [⋮]:                               │
│ ┌─────────────────────────┐             │
│ │ 📋 Crea variante        │ ← Primary   │
│ │ ℹ️  Dettagli esercizio  │             │
│ │ ⭐ Aggiungi ai preferiti│             │
│ └─────────────────────────┘             │
└─────────────────────────────────────────┘
```

### 2.2 Flow Diagram

```
User searches exercise
        │
        ▼
┌───────────────────┐
│ Exercise found?   │
└───────────────────┘
    │           │
   Yes          No
    │           │
    ▼           ▼
[+] or [⋮]   ➕ "Crea nuovo"
    │           │
    ▼           ▼
Form pre-filled  Empty form
with base data   (name only)
    │           │
    └─────┬─────┘
          ▼
   Categorization Form
   (progressive disclosure)
          │
          ▼
   ⚡ Warning if incomplete
          │
          ▼
   Save to local storage
   (cloud sync if Premium)
```

---

## 3. Form Design

### 3.1 Progressive Disclosure Pattern

Form starts minimal, expands on demand:

```
┌─────────────────────────────────────────────────┐
│ Crea Variante Esercizio                      ✕ │
├─────────────────────────────────────────────────┤
│                                                 │
│ Nome *                                          │
│ ┌─────────────────────────────────────────────┐ │
│ │ Panca Inclinata 30°                         │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ Basato su: Panca Inclinata 45°           [⌄]  │
│                                                 │
│ ─────────── Categorizzazione ──────────────── │
│                                                 │
│ Focus Principale                               │
│ [PETT ✓] [DELT ANT ✓] [TRIC] [DELT LAT] [+]   │
│                                                 │
│ Muscoli Secondari                         [⌄]  │
│ (inherited: TRIC, DELT ANT)                    │
│                                                 │
│ Tipo Esercizio                                 │
│ ┌──────────────┬────────────────┐              │
│ │  Compound ✓  │   Isolamento   │              │
│ └──────────────┴────────────────┘              │
│                                                 │
│ Pattern Movimento                              │
│ [Push ✓] [Pull] [Hinge] [Squat] [Accessory]   │
│                                                 │
│ Attrezzatura                              [⌄]  │
│ (inherited: Bilanciere)                        │
│                                                 │
│ ⚡ Modifica focus/pattern può influenzare     │
│    i calcoli del rapporto Push/Pull            │
│                                                 │
│              ┌──────────────────┐              │
│              │   💾 Salva       │              │
│              └──────────────────┘              │
└─────────────────────────────────────────────────┘
```

### 3.2 Component Specifications

| Component | Type | Behavior |
|-----------|------|----------|
| Nome | TextField | Required, auto-focused |
| Focus Principale | FilterChip (multi-select) | Checkmarks, max 3 recommended |
| Muscoli Secondari | Expandable chips | Collapsed by default |
| Tipo Esercizio | SegmentedButton | Single select, exclusive |
| Pattern Movimento | FilterChip (single-select) | Critical for Push/Pull |
| Attrezzatura | Expandable dropdown | Collapsed, shows inherited |

### 3.3 Muscle Abbreviations (Italian)

```dart
const muscleAbbreviations = {
  'PETT': 'Pettorali',
  'DELT ANT': 'Deltoidi Anteriori',
  'DELT LAT': 'Deltoidi Laterali',
  'DELT POST': 'Deltoidi Posteriori',
  'TRIC': 'Tricipiti',
  'BIC': 'Bicipiti',
  'LAT': 'Dorsali',
  'TRAP': 'Trapezio',
  'QUAD': 'Quadricipiti',
  'FEMOR': 'Femorali',
  'GLUT': 'Glutei',
  'POLP': 'Polpacci',
  'ADDOM': 'Addominali',
  'CORE': 'Core',
};
```

### 3.4 Warning Display

**Inline warning** (non-modal, non-blocking):
```
┌─────────────────────────────────────────────────┐
│ ⚡ Modifica focus/pattern può influenzare      │
│    i calcoli del rapporto Push/Pull            │
└─────────────────────────────────────────────────┘
```

**Badge in lists** for modified exercises:
```
┌─────────────────────────────────────────┐
│ ⚡ Panca 30° (personalizzato)           │
│ PETT, DELT ANT • Compound • Push        │
└─────────────────────────────────────────┘
```

---

## 4. Limits & Monetization

### 4.1 Free Tier Limits

| Aspect | Limit |
|--------|-------|
| Custom exercises | 5 permanent |
| Temporary unlocks | Unlimited via ads |
| Sync | Local only |

### 4.2 Ad-Unlock Model

```
User creates 6th exercise
        │
        ▼
┌───────────────────────────────────────┐
│ 🎯 Limite Raggiunto                   │
│                                        │
│ Hai creato 5 esercizi personalizzati. │
│                                        │
│ Opzioni:                              │
│ ┌──────────────────────────────┐      │
│ │ 🎬 Guarda annuncio           │      │
│ │    Sblocca per 7 giorni      │      │
│ └──────────────────────────────┘      │
│ ┌──────────────────────────────┐      │
│ │ ⭐ Passa a Premium           │      │
│ │    Esercizi illimitati       │      │
│ └──────────────────────────────┘      │
└───────────────────────────────────────┘
```

### 4.3 Expiration Behavior (Soft Block)

When temporary unlock expires:
- Exercise **remains** in existing workouts
- Exercise **blocked** for new workout additions
- Badge shows "⏰ Scaduto - Rinnova"
- User can re-watch ad to unlock again

```
┌─────────────────────────────────────────┐
│ ⏰ Panca 30° (scaduto)                  │
│ PETT, DELT ANT • Compound               │
│ ─────────────────────────────────────── │
│ [🎬 Rinnova con annuncio]               │
└─────────────────────────────────────────┘
```

### 4.4 Premium Benefits

| Feature | Free | Premium |
|---------|------|---------|
| Custom exercises | 5 | Unlimited |
| Temporary unlocks | 7 days | N/A (permanent) |
| Cloud sync | ❌ | ✅ |
| Cross-device | ❌ | ✅ |

---

## 5. Data Model & Architecture

### 5.1 Entity Definition

```dart
/// Custom Exercise Entity
///
/// Stores user-created exercise variants with optional categorization.
/// Extends base exercise with unlock/expiration tracking.
@HiveType(typeId: 50)
class CustomExercise extends Equatable {
  const CustomExercise({
    required this.id,
    required this.nome,
    this.baseExerciseId,
    required this.focus,
    required this.muscoliSecondari,
    required this.tipoEsercizio,
    required this.patternMovimento,
    required this.attrezzatura,
    required this.createdAt,
    this.unlockedUntil,
    this.isModifiedFromBase = false,
    this.userId,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nome;

  /// Reference to base exercise (null if pure custom)
  @HiveField(2)
  final String? baseExerciseId;

  /// Primary muscles: ["PETT", "DELT ANT"]
  @HiveField(3)
  final List<String> focus;

  /// Secondary muscles: ["TRIC"]
  @HiveField(4)
  final List<String> muscoliSecondari;

  /// "Compound" | "Isolamento"
  @HiveField(5)
  final String tipoEsercizio;

  /// "Push" | "Pull" | "Hinge" | "Squat" | "Accessory"
  @HiveField(6)
  final String patternMovimento;

  /// Equipment: "Bilanciere" | "Manubri" | etc.
  @HiveField(7)
  final String attrezzatura;

  @HiveField(8)
  final DateTime createdAt;

  /// null = permanent (free slot or Premium)
  /// DateTime = temporary unlock expiration
  @HiveField(9)
  final DateTime? unlockedUntil;

  /// true if user changed focus/pattern from base
  @HiveField(10)
  final bool isModifiedFromBase;

  /// For cloud sync (Premium users)
  @HiveField(11)
  final String? userId;

  /// Check if exercise is currently usable
  bool get isActive {
    if (unlockedUntil == null) return true;
    return DateTime.now().isBefore(unlockedUntil!);
  }

  /// Check if temporary and expired
  bool get isExpired {
    if (unlockedUntil == null) return false;
    return DateTime.now().isAfter(unlockedUntil!);
  }

  @override
  List<Object?> get props => [
    id, nome, baseExerciseId, focus, muscoliSecondari,
    tipoEsercizio, patternMovimento, attrezzatura,
    createdAt, unlockedUntil, isModifiedFromBase, userId,
  ];
}
```

### 5.2 Repository Pattern

```dart
/// Custom Exercise Repository Interface
abstract class CustomExerciseRepository {
  /// Get all custom exercises (active + expired)
  Future<List<CustomExercise>> getAll();

  /// Get only active (non-expired) exercises
  Future<List<CustomExercise>> getActive();

  /// Get count of permanent slots used
  Future<int> getPermanentCount();

  /// Save new custom exercise
  Future<void> save(CustomExercise exercise);

  /// Update existing exercise
  Future<void> update(CustomExercise exercise);

  /// Delete exercise
  Future<void> delete(String id);

  /// Extend temporary unlock by 7 days
  Future<void> extendUnlock(String id, {int days = 7});

  /// Sync with cloud (Premium only)
  Future<void> syncToCloud();
}
```

### 5.3 Architecture Structure

```
lib/features/custom_exercises/
├── domain/
│   ├── entities/
│   │   └── custom_exercise.dart
│   ├── repositories/
│   │   └── custom_exercise_repository.dart
│   └── services/
│       └── custom_exercise_limit_service.dart
├── data/
│   ├── datasources/
│   │   ├── custom_exercise_local_datasource.dart
│   │   └── custom_exercise_remote_datasource.dart
│   └── repositories/
│       └── custom_exercise_repository_impl.dart
└── presentation/
    ├── providers/
    │   ├── custom_exercises_provider.dart
    │   └── custom_exercise_form_provider.dart
    ├── screens/
    │   └── custom_exercise_form_screen.dart
    └── widgets/
        ├── custom_exercise_card.dart
        ├── muscle_chip_selector.dart
        ├── pattern_selector.dart
        └── limit_reached_dialog.dart
```

### 5.4 Integration Points

#### With Analytics (Push/Pull Calculation)
```dart
// In MuscleBalanceCalculator
String _getCorrectedMuscleGroup(String exerciseName, String storedMuscleGroup) {
  // First check if it's a custom exercise with explicit categorization
  final customExercise = customExerciseRepository.findByName(exerciseName);
  if (customExercise != null && customExercise.patternMovimento.isNotEmpty) {
    return customExercise.patternMovimento.toLowerCase(); // "push" or "pull"
  }

  // Fallback to name-based inference
  final inferred = _inferMuscleFromName(exerciseName);
  return inferred.isNotEmpty ? inferred : storedMuscleGroup;
}
```

#### With Exercise Search
```dart
// In ExerciseSearchService
Future<List<SearchResult>> search(String query) async {
  final catalogResults = await catalogRepository.search(query);
  final customResults = await customExerciseRepository.searchActive(query);

  return [
    ...customResults.map((e) => SearchResult.custom(e)),
    ...catalogResults.map((e) => SearchResult.catalog(e)),
  ];
}
```

---

## 6. UI/UX Research Sources

Design decisions based on:
- **Hevy/Strong apps**: Custom exercise creation flow, inline actions
- **Material 3 Guidelines**: Filter chips, segmented buttons, progressive disclosure
- **NNGroup**: Form design, warning placement, soft limits
- **Fitbod**: Muscle selection chips, equipment dropdowns

---

## 7. Implementation Phases

### Phase 1: Core Infrastructure
- [ ] Create `CustomExercise` entity with Hive adapter
- [ ] Implement `CustomExerciseLocalDatasource`
- [ ] Create repository with basic CRUD

### Phase 2: Form & UI
- [ ] Build `CustomExerciseFormScreen` with progressive disclosure
- [ ] Implement `MuscleChipSelector` component
- [ ] Add inline warning display

### Phase 3: Integration
- [ ] Integrate with exercise search
- [ ] Update `MuscleBalanceCalculator` to use custom exercise data
- [ ] Add ⚡ badge to exercise cards

### Phase 4: Monetization
- [ ] Implement limit checking service
- [ ] Create `LimitReachedDialog` with ad option
- [ ] Add expiration tracking and renewal flow

### Phase 5: Premium & Sync
- [ ] Implement cloud sync for Premium users
- [ ] Add cross-device support

---

## 8. Acceptance Criteria

- [ ] User can create variant from existing exercise with pre-filled form
- [ ] User can create pure custom exercise from search
- [ ] Focus, type, pattern selections work correctly
- [ ] Inline warning shows when modifying categorization
- [ ] ⚡ badge appears on modified exercises
- [ ] Free users limited to 5 permanent exercises
- [ ] Ad unlock grants 7-day temporary access
- [ ] Expired exercises remain in existing workouts
- [ ] Push/Pull analytics correctly use custom exercise categorization
- [ ] Premium users get unlimited exercises + cloud sync

---

## Appendix: Decision Log

| Decision | Option Chosen | Rationale |
|----------|---------------|-----------|
| Entry points | Both (+) and menu | Maximum discoverability |
| Form approach | Pre-filled template | Reduces friction, smart defaults |
| Required fields | Name only | Progressive disclosure, lower barrier |
| Warning style | Inline + badge | Non-blocking, persistent visibility |
| Storage | Hybrid (local + cloud) | Works offline, Premium value-add |
| Limit model | 5 free + ads | Fair free tier, monetization path |
| Ad unlock | 7 days temporary | Balanced value per ad view |
| Expiration | Soft block | Preserves user workout history |
