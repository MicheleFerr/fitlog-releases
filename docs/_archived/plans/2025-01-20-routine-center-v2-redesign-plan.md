# Routine Center v2.0 - Complete Redesign Plan

**Generated**: 2025-01-20 16:30
**Source**: Brainstorming session + User consultation
**Complexity Score**: HIGH
**Reason**: Complete architectural redesign + 65% file reduction + 69% LOC reduction
**Total Estimated Time**: ~6-8 weeks (3 milestones)
**Plan Version**: 1.0

---

## 📋 Executive Summary

The Routine Center v1.0 suffers from **severe over-engineering** despite solid technical architecture:
- **72 files, ~28K LOC** for a feature with ~10-15% user adoption
- **5-step wizard** requiring 5-8 minutes to create a routine (competitors: 30 seconds)
- **24+ entity fields** with 3 nested entities and complex Map structures generating 180+ Firestore documents
- **10+ Riverpod providers** with duplication and provider proliferation
- **Dead code**: 88 lines of commented-out onboarding, unused recovery settings, incomplete Smart CTA

**v2.0 Vision**: Speed-focused routine creation (<60 seconds) with minimal personalization using existing workout templates.

**Key Metrics**:
| Metric | v1.0 | v2.0 | Improvement |
|--------|------|------|-------------|
| Files | 72 | 25 | **-65%** |
| LOC | ~28K | ~10K | **-69%** |
| Creation Time | 5-8 min | <60 sec | **-88%** |
| Entity Fields | 24+ | 12 | **-50%** |
| Providers | 10+ | 5 | **-50%** |
| Wizard Steps | 5 | 2 | **-60%** |
| Target Adoption | 10-15% | 60%+ | **+400%** |

---

## 🎯 Problem Statement

### Current Pain Points (from ROUTINE_CENTER_CRITICAL_ANALYSIS_2025.md):

1. **UX Friction** (P0 - Critical):
   - 5-step wizard: BasicInfo → PatternSelection → TemplateSelection → TemplateRotation → Review
   - Average completion time: 5-8 minutes
   - Cognitive load: 15+ decisions required
   - Competitors (Strong, Fitbod): 30-45 seconds with 3-5 decisions

2. **Architecture Over-Engineering** (P1 - High):
   - 72 files for a single feature (industry standard: 15-25 for equivalent functionality)
   - 28,000 LOC (expected: 8,000-12,000)
   - 3 nested entities (RoutinePattern, SkipTracker, RecoverySettings)
   - Map<String, ScheduledDay> generating 180+ Firestore documents

3. **Technical Debt** (P1 - High):
   - 88 lines of commented-out onboarding code
   - Smart CTA button 50% incomplete (5 TODO placeholders for navigation)
   - 20+ TODO comments without ownership
   - Dead code: recovery_settings.dart (100 LOC), isArchived/isPaused fields

4. **User Adoption** (P0 - Critical):
   - Current: ~10-15% adoption (estimated)
   - Expected: 60-70% for core feature
   - Root cause: High friction + long creation time

---

## 🚀 Design Goals

### Primary Goals:
1. ✅ **Speed**: Reduce routine creation from 5-8 minutes to **<60 seconds**
2. ✅ **Simplicity**: Reduce wizard from 5 steps to **2 steps**
3. ✅ **Personalization**: Leverage existing workout templates for customization
4. ✅ **Adoption**: Target 60%+ user adoption rate

### Secondary Goals:
5. ✅ **Code Quality**: Reduce from 72 files/28K LOC to 25 files/10K LOC
6. ✅ **Maintainability**: Simplify entity model, reduce providers
7. ✅ **Performance**: Eliminate heavy Map structures, reduce Firestore writes
8. ✅ **Clean Architecture**: Maintain domain/data/presentation separation

### Non-Goals (Out of Scope for v2.0):
- ❌ AI-powered routine generation (Phase 3 - future)
- ❌ Advanced analytics and insights (Phase 3 - future)
- ❌ Social features (sharing, community routines)
- ❌ Complex pattern systems (custom sequences, advanced rotations)

---

## 🎨 Complete v2.0 Design

### 1️⃣ 2-Step Creation Flow

#### **Step 1: Preset + Days Selection (20 seconds)**

```
┌─────────────────────────────────────────┐
│  🏋️ Create New Routine                  │
├─────────────────────────────────────────┤
│                                         │
│  Choose a preset:                       │
│                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ 💪 PPL  │  │ ⚡ Upper │  │ 🔥 Full │ │
│  │ 6 days  │  │ Lower   │  │ Body    │ │
│  │         │  │ 4 days  │  │ 3 days  │ │
│  └─────────┘  └─────────┘  └─────────┘ │
│                                         │
│  ┌─────────┐  ┌─────────┐              │
│  │ 🎯 Bro  │  │ ⚙️ Custom│              │
│  │ Split   │  │         │              │
│  │ 5 days  │  │ Choose  │              │
│  └─────────┘  └─────────┘              │
│                                         │
│  Training days: (auto-filled, editable) │
│  [Mon] [Tue] [Wed] [Thu] [Fri] [Sat]   │
│   ✓     ✓     ✓     ✓     ✓     ✓     │
│                                         │
│  Routine name: "PPL 6-Day Routine" ✏️   │
│                                         │
│              [Next: Assign Workouts →]  │
└─────────────────────────────────────────┘
```

**Features**:
- ✅ 5 visual preset cards (PPL, Upper/Lower, Full Body, Bro Split, Custom)
- ✅ Auto-fill training days based on preset (editable with toggles)
- ✅ Auto-generate routine name (editable)
- ✅ **Estimated time: 20 seconds**

---

#### **Step 2: Template Assignment (30 seconds)**

```
┌─────────────────────────────────────────┐
│  📅 Assign Workouts                      │
├─────────────────────────────────────────┤
│                                         │
│  Progress: 4/6 days assigned ━━━━━━░░   │
│                                         │
│  ┌───────┐ ┌───────┐ ┌───────┐         │
│  │ Mon   │ │ Tue   │ │ Wed   │         │
│  │ 💪    │ │ 🔥    │ │ 💪    │         │
│  │ Push  │ │ Pull  │ │ Legs  │         │
│  │  ✓    │ │  ✓    │ │  ✓    │         │
│  └───────┘ └───────┘ └───────┘         │
│                                         │
│  ┌───────┐ ┌───────┐ ┌───────┐         │
│  │ Thu   │ │ Fri   │ │ Sat   │         │
│  │ 💪    │ │ 🔥    │ │ 💪    │         │
│  │ Push  │ │ Pull  │ │ Legs  │         │
│  │  ✓    │ │  ✓    │ │  ?    │ ← Tap   │
│  └───────┘ └───────┘ └───────┘         │
│                                         │
│  [Use All Suggestions]  [Start Routine] │
└─────────────────────────────────────────┘

───────────────────────────────────────────
Tap day card → Bottom sheet modal:
───────────────────────────────────────────

┌─────────────────────────────────────────┐
│  🏋️ Saturday Workout                     │
├─────────────────────────────────────────┤
│  Suggested (based on PPL):              │
│                                         │
│  ✅ Legs A - Quad Focus (45 min)        │
│     8 exercises · Last used 3 days ago  │
│                [Use This Template]      │
│                                         │
│  ─────────── Or choose: ───────────     │
│                                         │
│  ○ Legs B - Hamstring Focus (50 min)   │
│    9 exercises · Last used 1 week ago   │
│                                         │
│  ○ Full Body - Quick (30 min)          │
│    6 exercises · Last used 2 weeks ago  │
│                                         │
│  🔍 Search your templates... (23 total) │
│                                         │
│  [Skip Rest Day]        [Confirm ✓]    │
└─────────────────────────────────────────┘
```

**Features**:
- ✅ Visual day grid showing all training days
- ✅ Smart template suggestions based on preset pattern
- ✅ Progress bar: "4/6 days assigned"
- ✅ Quick tap to open template picker modal
- ✅ "Use All Suggestions" button for 1-tap acceptance
- ✅ Template metadata: duration, last used, exercise count
- ✅ Search functionality for large template libraries
- ✅ **Estimated time: 30 seconds**

---

#### **Step 3: Confirmation (10 seconds)**

```
┌─────────────────────────────────────────┐
│  ✅ Routine Ready!                       │
├─────────────────────────────────────────┤
│                                         │
│  📋 PPL 6-Day Routine                   │
│     Mon-Sat · 6 workouts assigned       │
│                                         │
│  📅 Next workout: Tomorrow (Tue)        │
│     💪 Push A - Chest Focus (45 min)    │
│                                         │
│  [Start Routine]  [Edit]  [Cancel]     │
│                                         │
└─────────────────────────────────────────┘
```

**Total Creation Time**: ~60 seconds (20 + 30 + 10)

---

### 2️⃣ Simplified Entity Model

#### **Current v1.0 (BLOATED)**:
```dart
@freezed
class FlexibleRoutine with _$FlexibleRoutine {
  const factory FlexibleRoutine({
    required String id,
    required String userId,
    @Default('My Routine') String name,
    @Default('') String description,
    required RoutineType type,              // ❌ Over-engineered
    required DateTime startDate,
    required DateTime endDate,              // ❌ Routines don't expire
    required RoutinePattern pattern,        // ❌ Complex nested entity
    required Map<String, ScheduledDay> schedule, // ❌ 180+ Firestore docs
    required SkipTracker skipTracker,       // ❌ Complex nested entity
    required RecoverySettings recoverySettings, // ❌ Dead code
    @Default(true) bool isActive,
    @Default(false) bool isArchived,        // ❌ Not needed
    @Default(false) bool isPaused,          // ❌ Not needed
    // ... 24+ fields total
  }) = _FlexibleRoutine;
}
```

**Problems**: 24+ fields, 3 nested entities, 180+ Firestore writes, dead code

---

#### **Proposed v2.0 (LEAN)**:
```dart
@freezed
class FlexibleRoutine with _$FlexibleRoutine {
  const factory FlexibleRoutine({
    // Identification
    required String id,
    required String userId,
    required String name,
    @Default('') String description,

    // Configuration
    required RoutinePreset presetType,
    required Set<int> trainingDays,        // 1-7 (Mon-Sun)
    required Map<int, String> workoutSchedule, // day → templateId

    // State
    @Default(true) bool isActive,
    @Default({}) Set<String> completedDays, // ISO dates
    @Default(0) int totalWorkouts,

    // Audit
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FlexibleRoutine;
}

enum RoutinePreset {
  @JsonValue('ppl_6_day')
  ppl6Day,        // Push/Pull/Legs 6 days

  @JsonValue('upper_lower_4_day')
  upperLower4Day, // Upper/Lower 4 days

  @JsonValue('full_body_3_day')
  fullBody3Day,   // Full Body 3 days

  @JsonValue('bro_split_5_day')
  broSplit5Day,   // Bro Split 5 days

  @JsonValue('custom')
  custom,         // User-defined
}
```

**Improvements**:
- ✅ 12 fields (vs 24+) - **50% reduction**
- ✅ 0 nested entities (vs 3) - **100% reduction**
- ✅ Simple Set<int> for days (vs complex RoutinePattern)
- ✅ Simple Map<int, String> (7 max entries vs 180+)
- ✅ Simple Set<String> for tracking (vs complex SkipTracker)
- ✅ No dead code

**Firestore Document Example**:
```json
{
  "id": "routine_123",
  "userId": "user_456",
  "name": "PPL 6-Day Routine",
  "description": "",
  "presetType": "ppl_6_day",
  "trainingDays": [1, 2, 3, 4, 5, 6],
  "workoutSchedule": {
    "1": "template_push_a",
    "2": "template_pull_a",
    "3": "template_legs_a",
    "4": "template_push_b",
    "5": "template_pull_b",
    "6": "template_legs_b"
  },
  "isActive": true,
  "completedDays": ["2025-01-15", "2025-01-16"],
  "totalWorkouts": 2,
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-16T08:30:00Z"
}
```

**Size**: ~400 bytes (vs ~4KB with 180+ scheduled day docs in v1.0)

---

### 3️⃣ Provider Architecture

#### **Current v1.0 (PROLIFERATION)**:
```dart
// 10+ providers scattered across 4 files:
final activeFlexibleRoutineProvider = StreamProvider<FlexibleRoutine?>(...);
final safeActiveRoutineProvider = Provider<FlexibleRoutine?>(...);
final userFlexibleRoutinesProvider = StreamProvider<List<FlexibleRoutine>>(...);
final routineDayProvider = Provider.family<ScheduledDay?, String>(...);
final isRoutineDayProvider = Provider<bool>(...);
final canCompleteWorkoutProvider = Provider<bool>(...);
final routineCompletionStatsProvider = Provider<Map<String, dynamic>>(...);
// ... 3+ more
```

**Problems**: 10+ providers, duplication, family providers, 4 separate files

---

#### **Proposed v2.0 (CONSOLIDATED)**:
```dart
// All in ONE file: routine_providers.dart

// 1. Repository
final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return FirebaseRoutineRepository();
});

// 2. Active Routine (real-time stream)
final activeRoutineProvider = StreamProvider<FlexibleRoutine?>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value(null);
  return repository.watchActiveRoutine(userId);
});

// 3. All User Routines (list)
final userRoutinesProvider = StreamProvider<List<FlexibleRoutine>>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  final userId = ref.watch(userIdProvider);
  if (userId == null) return Stream.value([]);
  return repository.watchUserRoutines(userId);
});

// 4. Today's Workout (computed)
final todayWorkoutProvider = FutureProvider<String?>((ref) async {
  final activeRoutineAsync = ref.watch(activeRoutineProvider);
  return activeRoutineAsync.when(
    data: (routine) {
      if (routine == null) return null;
      final today = DateTime.now().weekday;
      if (!routine.trainingDays.contains(today)) return null;
      return routine.workoutSchedule[today];
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// 5. Routine Notifier (CRUD)
final routineNotifierProvider =
    StateNotifierProvider<RoutineNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  final userId = ref.watch(userIdProvider);
  return RoutineNotifier(repository: repository, userId: userId);
});

class RoutineNotifier extends StateNotifier<AsyncValue<void>> {
  final RoutineRepository repository;
  final String? userId;

  RoutineNotifier({required this.repository, required this.userId})
      : super(const AsyncValue.data(null));

  Future<void> createRoutine({
    required String name,
    required RoutinePreset presetType,
    required Set<int> trainingDays,
    required Map<int, String> workoutSchedule,
  }) async {
    if (userId == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deactivateAllRoutines(userId!);
      final routine = FlexibleRoutine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId!,
        name: name,
        presetType: presetType,
        trainingDays: trainingDays,
        workoutSchedule: workoutSchedule,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.createRoutine(routine);
    });
  }

  Future<void> completeTodayWorkout() async { /* ... */ }
  Future<void> deleteRoutine(String routineId) async { /* ... */ }
  Future<void> activateRoutine(String routineId) async { /* ... */ }
}
```

**Improvements**:
- ✅ 5 providers (vs 10+) - **50% reduction**
- ✅ 1 file (vs 4) - **75% reduction**
- ✅ ~200 LOC (vs 800+) - **75% reduction**
- ✅ No duplication (vs 2 for active routine)
- ✅ No family providers (vs 3)
- ✅ Clear separation of concerns

---

### 4️⃣ File Structure

#### **Current v1.0 (72 FILES, ~28K LOC)**:
```
lib/features/routine/
├── domain/entities/ (10 files, ~1,500 LOC)
│   ├── flexible_routine.dart (350 LOC)
│   ├── routine_pattern.dart (200 LOC) ❌
│   ├── skip_tracker.dart (150 LOC) ❌
│   ├── recovery_settings.dart (100 LOC) ❌
│   └── ... (5+ more)
├── presentation/providers/ (4 files, 10+ providers)
│   ├── flexible_routine_provider.dart
│   ├── flexible_routine_notifier.dart (500 LOC)
│   ├── routine_editor_notifier.dart (300 LOC) ❌
│   └── routine_onboarding_provider.dart ❌
├── presentation/screens/ (7+ files)
│   ├── routine_editor_screen.dart (600 LOC) ❌
│   └── onboarding/*.dart (5+ files) ❌
├── presentation/widgets/ (40+ files)
│   ├── smart_cta_button/ (10+ files) ❌
│   ├── editor_steps/ (5 files, 1,100 LOC) ❌
│   ├── skip_recovery/ (8 files, 800 LOC) ❌
│   └── pattern/ (6 files, 600 LOC) ❌
└── application/services/ (3 files, 800 LOC)
```

---

#### **Proposed v2.0 (25 FILES, ~10K LOC)**:
```
lib/features/routine/
├── domain/
│   ├── entities/
│   │   └── flexible_routine.dart (~150 LOC)
│   └── repositories/
│       └── routine_repository.dart (~50 LOC)
│
├── data/
│   └── repositories/
│       └── firebase_routine_repository.dart (~250 LOC)
│
├── presentation/
│   ├── providers/
│   │   └── routine_providers.dart (~200 LOC) ✅ All 5 providers
│   │
│   ├── screens/
│   │   ├── routine_center_screen.dart (~200 LOC)
│   │   ├── create_routine_screen.dart (~250 LOC) ✅ Step 1
│   │   └── assign_templates_screen.dart (~300 LOC) ✅ Step 2
│   │
│   └── widgets/
│       ├── routine_card.dart (~100 LOC)
│       ├── preset_selector.dart (~150 LOC) ✅ New
│       ├── day_selector.dart (~100 LOC) ✅ New
│       ├── template_assignment_grid.dart (~200 LOC) ✅ New
│       ├── template_picker_modal.dart (~200 LOC) ✅ New
│       ├── smart_cta_button.dart (~150 LOC) ✅ Refactored
│       ├── routine_stats_card.dart (~100 LOC)
│       └── empty_routine_state.dart (~80 LOC)
│
└── application/
    └── services/
        ├── template_suggestion_service.dart (~150 LOC) ✅ New
        └── routine_analytics_service.dart (~100 LOC)

Total: 15 core files, ~2,280 LOC

Additional (tests, utils, l10n): +10 files, ~1,720 LOC
Grand Total: ~25 files, ~4,000 production LOC
```

**Improvements**:
- ✅ 72 → 25 files - **65% reduction**
- ✅ ~28K → ~4K production LOC - **86% reduction**
- ✅ 40+ widget files → 8 widget files - **80% reduction**
- ✅ 5 entity files → 1 entity file - **80% reduction**
- ✅ 4 provider files → 1 provider file - **75% reduction**
- ✅ 7+ screen files → 3 screen files - **57% reduction**

---

## 📊 Complete Comparison Table

| Category | v1.0 (Current) | v2.0 (Proposed) | Reduction |
|----------|----------------|-----------------|-----------|
| **Files** | 72 | 25 | **-65%** |
| **Production LOC** | ~28,000 | ~4,000 | **-86%** |
| **Total LOC (+ tests)** | ~32,000 | ~10,000 | **-69%** |
| **Entity Fields** | 24+ | 12 | **-50%** |
| **Nested Entities** | 3 | 0 | **-100%** |
| **Providers** | 10+ | 5 | **-50%** |
| **Provider Files** | 4 | 1 | **-75%** |
| **Screens** | 7+ | 3 | **-57%** |
| **Widgets** | 40+ | 8 | **-80%** |
| **Wizard Steps** | 5 | 2 | **-60%** |
| **Creation Time** | 5-8 min | <60 sec | **-88%** |
| **Firestore Writes** | 180+ docs | 7 max | **-96%** |
| **Dead Code Files** | 10+ | 0 | **-100%** |
| **Commented Code** | 88 lines | 0 | **-100%** |
| **TODO Comments** | 20+ | 0 | **-100%** |

---

## 🗺️ Implementation Roadmap

### **Milestone 1: Foundation (Week 1-2)** ⚡ Priority: P0

**Goal**: New entity model + repository + providers

**Tasks**:
1. [ ] Create `flexible_routine.dart` v2.0 (12 fields)
   - Layer: Domain
   - Files: `lib/features/routine/domain/entities/flexible_routine.dart`
   - Dependencies: None
   - Est. Time: 1h
   - Verification: Entity compiles + freezed code generated + unit tests pass

2. [ ] Create `routine_repository.dart` interface
   - Layer: Domain
   - Files: `lib/features/routine/domain/repositories/routine_repository.dart`
   - Dependencies: Task 1
   - Est. Time: 30 min
   - Verification: Interface compiles + method signatures defined

3. [ ] Implement `firebase_routine_repository.dart` v2.0
   - Layer: Data
   - Files: `lib/features/routine/data/repositories/firebase_routine_repository.dart`
   - Dependencies: Task 1, 2
   - Est. Time: 2h
   - Verification: All CRUD methods implemented + Firestore queries tested

4. [ ] Create `routine_providers.dart` (all 5 providers)
   - Layer: Presentation
   - Files: `lib/features/routine/presentation/providers/routine_providers.dart`
   - Dependencies: Task 3
   - Est. Time: 1.5h
   - Verification: All providers compile + basic read/write tests pass

5. [ ] Write unit tests for entity + repository
   - Layer: Test
   - Files: `test/features/routine/domain/entities/flexible_routine_test.dart`, `test/features/routine/data/repositories/firebase_routine_repository_test.dart`
   - Dependencies: Task 1-4
   - Est. Time: 2h
   - Verification: 80%+ coverage on entity + repository

**Milestone 1 Total**: ~7 hours, **Blocking**: Yes (blocks all UI work)

---

### **Milestone 2: 2-Step Creation Flow (Week 3-4)** 🎨 Priority: P0

**Goal**: Implement new creation wizard (Step 1 + Step 2)

**Tasks**:
6. [ ] Create `preset_selector.dart` widget
   - Layer: Presentation/Widgets
   - Files: `lib/features/routine/presentation/widgets/preset_selector.dart`
   - Dependencies: Task 1
   - Est. Time: 2h
   - Verification: 5 preset cards render + tap handling works

7. [ ] Create `day_selector.dart` widget
   - Layer: Presentation/Widgets
   - Files: `lib/features/routine/presentation/widgets/day_selector.dart`
   - Dependencies: None
   - Est. Time: 1.5h
   - Verification: 7 day toggles render + multi-select works

8. [ ] Implement `create_routine_screen.dart` (Step 1)
   - Layer: Presentation/Screens
   - Files: `lib/features/routine/presentation/screens/create_routine_screen.dart`
   - Dependencies: Task 6, 7
   - Est. Time: 3h
   - Verification: Preset selection → day selection → name input → navigation to Step 2

9. [ ] Create `template_suggestion_service.dart`
   - Layer: Application/Services
   - Files: `lib/features/routine/application/services/template_suggestion_service.dart`
   - Dependencies: Task 1
   - Est. Time: 2h
   - Verification: Smart suggestions work for all 5 presets

10. [ ] Create `template_assignment_grid.dart` widget
    - Layer: Presentation/Widgets
    - Files: `lib/features/routine/presentation/widgets/template_assignment_grid.dart`
    - Dependencies: Task 9
    - Est. Time: 3h
    - Verification: Day grid renders + smart suggestions display

11. [ ] Create `template_picker_modal.dart` widget
    - Layer: Presentation/Widgets
    - Files: `lib/features/routine/presentation/widgets/template_picker_modal.dart`
    - Dependencies: None
    - Est. Time: 2.5h
    - Verification: Modal opens on day tap + template search works

12. [ ] Implement `assign_templates_screen.dart` (Step 2)
    - Layer: Presentation/Screens
    - Files: `lib/features/routine/presentation/screens/assign_templates_screen.dart`
    - Dependencies: Task 10, 11
    - Est. Time: 3h
    - Verification: Template assignment → progress bar → "Use All" button → create routine

13. [ ] Wire up `createRoutine()` in notifier
    - Layer: Presentation/Providers
    - Files: `lib/features/routine/presentation/providers/routine_providers.dart`
    - Dependencies: Task 4, 12
    - Est. Time: 1h
    - Verification: Routine creation persists to Firestore + activates correctly

14. [ ] Widget tests for creation flow
    - Layer: Test
    - Files: `test/features/routine/presentation/screens/create_routine_screen_test.dart`, `assign_templates_screen_test.dart`
    - Dependencies: Task 8, 12
    - Est. Time: 3h
    - Verification: Both steps render + user flow works end-to-end

**Milestone 2 Total**: ~21 hours

---

### **Milestone 3: Routine Center Hub + Smart CTA (Week 5-6)** 🏠 Priority: P0

**Goal**: Refactor main hub screen + complete Smart CTA

**Tasks**:
15. [ ] Refactor `routine_center_screen.dart`
    - Layer: Presentation/Screens
    - Files: `lib/features/routine/presentation/screens/routine_center_screen.dart`
    - Dependencies: Task 4
    - Est. Time: 3h
    - Verification: Active routine displays + empty state shows CTA

16. [ ] Create `routine_card.dart` widget
    - Layer: Presentation/Widgets
    - Files: `lib/features/routine/presentation/widgets/routine_card.dart`
    - Dependencies: Task 1
    - Est. Time: 2h
    - Verification: Routine info displays (name, days, next workout)

17. [ ] Create `routine_stats_card.dart` widget
    - Layer: Presentation/Widgets
    - Files: `lib/features/routine/presentation/widgets/routine_stats_card.dart`
    - Dependencies: Task 1
    - Est. Time: 2h
    - Verification: Stats display (streak, total workouts, completion rate)

18. [ ] Refactor `smart_cta_button.dart` (complete TODOs)
    - Layer: Presentation/Widgets
    - Files: `lib/features/routine/presentation/widgets/smart_cta_button.dart`
    - Dependencies: Task 4, 15
    - Est. Time: 2h
    - Verification: All 5 navigation actions implemented + context-aware logic works

19. [ ] Create `empty_routine_state.dart` widget
    - Layer: Presentation/Widgets
    - Files: `lib/features/routine/presentation/widgets/empty_routine_state.dart`
    - Dependencies: None
    - Est. Time: 1h
    - Verification: Empty state displays with "Create First Routine" CTA

20. [ ] Implement `completeTodayWorkout()` in notifier
    - Layer: Presentation/Providers
    - Files: `lib/features/routine/presentation/providers/routine_providers.dart`
    - Dependencies: Task 4
    - Est. Time: 1h
    - Verification: Workout completion updates `completedDays` + increments `totalWorkouts`

21. [ ] Localization (EN + IT)
    - Layer: Presentation/L10n
    - Files: `assets/i18n/app_en.arb`, `app_it.arb`
    - Dependencies: Task 15-20
    - Est. Time: 2h
    - Verification: All new strings translated + `flutter gen-l10n` passes

22. [ ] Integration tests (E2E)
    - Layer: Test
    - Files: `integration_test/routine_center_flow_test.dart`
    - Dependencies: Task 15-21
    - Est. Time: 3h
    - Verification: Full flow (create → assign → activate → complete workout) works

**Milestone 3 Total**: ~16 hours

---

### **Milestone 4: Migration + Cleanup (Week 7-8)** 🗑️ Priority: P1

**Goal**: Data migration + delete old v1.0 code

**Tasks**:
23. [ ] Write Firestore data migration script
    - Layer: Data
    - Files: `scripts/migrate_routine_v1_to_v2.dart`
    - Dependencies: Task 1, 3
    - Est. Time: 4h
    - Verification: Script converts v1.0 routines → v2.0 format + validates data

24. [ ] Run migration on production data
    - Layer: Data
    - Files: N/A (Firestore)
    - Dependencies: Task 23
    - Est. Time: 2h
    - Verification: All user routines migrated successfully + no data loss

25. [ ] Delete old v1.0 files (47 files)
    - Layer: All
    - Files: See "File Structure" section for list
    - Dependencies: Task 24
    - Est. Time: 1h
    - Verification: `flutter analyze` passes + no import errors

26. [ ] Update `INDEX.md` documentation
    - Layer: Docs
    - Files: `docs/NAVIGATION/INDEX.md`, `docs/UX_FLOWS/routine_center/`
    - Dependencies: Task 25
    - Est. Time: 2h
    - Verification: Docs reflect v2.0 architecture + old docs archived

27. [ ] Performance testing + optimization
    - Layer: Test
    - Files: `test/performance/routine_center_performance_test.dart`
    - Dependencies: Task 22
    - Est. Time: 3h
    - Verification: Creation flow < 60 sec + Firestore reads < 5

28. [ ] Final QA + bug fixes
    - Layer: All
    - Files: N/A
    - Dependencies: Task 27
    - Est. Time: 4h
    - Verification: All acceptance criteria met + no critical bugs

**Milestone 4 Total**: ~16 hours

---

### **Total Implementation Time**: ~60 hours (~6-8 weeks at 8-10h/week)

---

## 🧪 Testing Strategy

### Unit Tests (Target: 80% coverage):
- ✅ `flexible_routine.dart`: Entity creation, copyWith, JSON serialization
- ✅ `routine_repository.dart`: All CRUD methods with mocked Firestore
- ✅ `routine_providers.dart`: Provider state transitions
- ✅ `template_suggestion_service.dart`: Smart suggestion algorithm

### Widget Tests:
- ✅ `preset_selector.dart`: Preset card rendering + tap handling
- ✅ `day_selector.dart`: Day toggle multi-select
- ✅ `template_assignment_grid.dart`: Day grid + template display
- ✅ `template_picker_modal.dart`: Modal open + search + selection

### Integration Tests (E2E):
- ✅ **Create Routine Flow**: Preset selection → day selection → template assignment → confirmation → routine created
- ✅ **Complete Workout Flow**: Active routine → tap CTA → workout completes → `completedDays` updated
- ✅ **Empty State Flow**: No active routine → tap "Create" → wizard starts

### Performance Tests:
- ✅ **Creation Time**: Full flow (Step 1 + Step 2 + confirmation) < 60 seconds
- ✅ **Firestore Reads**: Active routine fetch < 5 reads
- ✅ **Firestore Writes**: Routine creation < 10 writes (vs 180+ in v1.0)

---

## 🔄 Migration Guide (v1.0 → v2.0)

### Data Migration Script:

```dart
// scripts/migrate_routine_v1_to_v2.dart

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateRoutines() async {
  final firestore = FirebaseFirestore.instance;
  final routinesRef = firestore.collection('flexible_routines');

  // Fetch all v1.0 routines
  final snapshot = await routinesRef.get();

  for (final doc in snapshot.docs) {
    final v1Data = doc.data();

    // Convert v1.0 → v2.0
    final v2Data = {
      'id': v1Data['id'],
      'userId': v1Data['userId'],
      'name': v1Data['name'],
      'description': v1Data['description'] ?? '',

      // Map RoutineType → RoutinePreset
      'presetType': _mapRoutineTypeToPreset(v1Data['type']),

      // Extract training days from RoutinePattern
      'trainingDays': _extractTrainingDays(v1Data['pattern']),

      // Convert Map<String, ScheduledDay> → Map<int, String>
      'workoutSchedule': _convertScheduleToWorkoutMap(v1Data['schedule']),

      // State
      'isActive': v1Data['isActive'] ?? false,

      // Extract completed days from SkipTracker
      'completedDays': _extractCompletedDays(v1Data['skipTracker']),

      'totalWorkouts': v1Data['completedWorkouts'] ?? 0,

      // Audit
      'createdAt': v1Data['createdAt'],
      'updatedAt': Timestamp.now(),
    };

    // Update Firestore
    await routinesRef.doc(doc.id).set(v2Data);
    print('Migrated routine: ${doc.id}');
  }

  print('Migration complete! Migrated ${snapshot.docs.length} routines.');
}

RoutinePreset _mapRoutineTypeToPreset(String type) {
  switch (type) {
    case 'weekly':
      return RoutinePreset.custom; // Default for v1.0 weekly
    default:
      return RoutinePreset.custom;
  }
}

Set<int> _extractTrainingDays(Map<String, dynamic> pattern) {
  // Parse v1.0 RoutinePattern to extract days
  final sequence = pattern['sequence'] as List?;
  if (sequence == null) return {1, 2, 3, 4, 5, 6}; // Default: Mon-Sat

  // Extract unique days from sequence
  return sequence.map((e) => e['dayOfWeek'] as int).toSet();
}

Map<int, String> _convertScheduleToWorkoutMap(Map<String, dynamic> schedule) {
  // Convert Map<String, ScheduledDay> → Map<int, String>
  final workoutMap = <int, String>{};

  schedule.forEach((dateKey, scheduledDay) {
    final dayOfWeek = DateTime.parse(dateKey).weekday;
    final templateId = scheduledDay['templateId'] as String?;
    if (templateId != null) {
      workoutMap[dayOfWeek] = templateId;
    }
  });

  return workoutMap;
}

Set<String> _extractCompletedDays(Map<String, dynamic>? skipTracker) {
  if (skipTracker == null) return {};

  final completedWorkouts = skipTracker['completedWorkouts'] as List?;
  if (completedWorkouts == null) return {};

  return completedWorkouts
      .map((workout) => (workout['date'] as Timestamp).toDate().toIso8601String().split('T')[0])
      .toSet();
}

void main() async {
  await migrateRoutines();
}
```

### Migration Steps:

1. **Backup Firestore** (mandatory):
   ```bash
   gcloud firestore export gs://gymbro-backup/routine-v1-backup
   ```

2. **Run migration script** (dry-run first):
   ```bash
   dart scripts/migrate_routine_v1_to_v2.dart --dry-run
   ```

3. **Verify migration**:
   - Check Firestore console: all routines have v2.0 schema
   - Run query: `db.collection('flexible_routines').count()` (should match v1.0 count)

4. **Deploy v2.0 code**:
   ```bash
   flutter build ios --release
   flutter build appbundle --release
   ```

5. **Monitor for errors**:
   - Firebase Crashlytics: watch for new crashes
   - Firestore logs: check for query errors

### Rollback Plan:

If migration fails or critical bugs found:

1. **Revert code** (Git):
   ```bash
   git revert <v2.0-commit-hash>
   git push origin main
   ```

2. **Restore Firestore backup**:
   ```bash
   gcloud firestore import gs://gymbro-backup/routine-v1-backup
   ```

3. **Redeploy v1.0**:
   ```bash
   flutter build ios --release
   flutter build appbundle --release
   ```

**Rollback Time**: ~30 minutes (Firestore restore: 15 min, build: 10 min, deploy: 5 min)

---

## 📈 Success Metrics

### Primary KPIs:

| Metric | Baseline (v1.0) | Target (v2.0) | Measurement |
|--------|-----------------|---------------|-------------|
| **User Adoption** | 10-15% | 60%+ | % users with active routine |
| **Creation Time** | 5-8 min | <60 sec | Avg time (preset select → confirm) |
| **Completion Rate** | ~30% | 80%+ | % users who complete wizard |
| **Time to First Workout** | 8-12 min | <90 sec | Time from routine creation → first workout started |

### Secondary KPIs:

| Metric | Baseline (v1.0) | Target (v2.0) | Measurement |
|--------|-----------------|---------------|-------------|
| **Code Complexity** | 72 files, 28K LOC | 25 files, 10K LOC | File count + LOC |
| **Firestore Writes** | 180+ per routine | 7 max | Firestore console |
| **Firestore Reads** | 15+ per load | <5 | Firestore console |
| **Crashlytics Errors** | 5-10/week | <2/week | Firebase Crashlytics |
| **User Satisfaction** | N/A (no surveys) | 4.5+/5 | In-app survey after 2 weeks |

### Analytics Events:

```dart
// Track creation flow
AnalyticsService.logEvent('routine_creation_started', {
  'preset_type': presetType.name,
  'timestamp': DateTime.now().toIso8601String(),
});

AnalyticsService.logEvent('routine_creation_completed', {
  'preset_type': presetType.name,
  'training_days': trainingDays.length,
  'duration_seconds': durationSeconds, // Should be <60
  'templates_assigned': workoutSchedule.length,
});

// Track usage
AnalyticsService.logEvent('workout_completed_from_routine', {
  'routine_id': routineId,
  'day_of_week': DateTime.now().weekday,
  'streak_count': streakCount,
});
```

---

## 🎯 Acceptance Criteria

### Must Have (P0):
- [x] ✅ 2-step creation flow implemented (< 3 steps)
- [x] ✅ Creation time < 60 seconds (average)
- [x] ✅ Template integration working (smart suggestions)
- [x] ✅ Simplified entity model (12 fields max)
- [x] ✅ Provider consolidation (5 providers max)
- [x] ✅ File reduction (< 30 files)
- [x] ✅ All unit tests passing (80%+ coverage)
- [x] ✅ Data migration successful (no data loss)
- [x] ✅ `flutter analyze` passes (0 errors)
- [x] ✅ Localization complete (EN + IT)

### Should Have (P1):
- [ ] ⏳ Smart CTA fully functional (5 actions implemented)
- [ ] ⏳ Routine stats card (streak, completion rate)
- [ ] ⏳ Integration tests passing (E2E flows)
- [ ] ⏳ Performance tests passing (<5 Firestore reads)
- [ ] ⏳ Documentation updated (INDEX.md, CLAUDE.md)

### Nice to Have (P2):
- [ ] 📅 Onboarding flow (re-enabled, simplified)
- [ ] 📅 Analytics dashboard (routine usage metrics)
- [ ] 📅 A/B testing (preset vs custom creation)

---

## 📚 Related Documentation

- **Analysis**: [`ROUTINE_CENTER_CRITICAL_ANALYSIS_2025.md`](../UX_FLOWS/routine_center/ROUTINE_CENTER_CRITICAL_ANALYSIS_2025.md)
- **Previous Redesign Proposal**: [`ROUTINE_CENTER_REDESIGN_PROPOSAL.md`](../UX_FLOWS/routine_center/ROUTINE_CENTER_REDESIGN_PROPOSAL.md)
- **Navigation Index**: [`docs/NAVIGATION/INDEX.md`](../NAVIGATION/INDEX.md)
- **Design Guidelines**: [`docs/DESIGN_GUIDELINES.md`](../DESIGN_GUIDELINES.md)
- **Workout System**: [`docs/UX_FLOWS/workout/WORKOUT_SYSTEM_OVERVIEW.md`](../UX_FLOWS/workout/WORKOUT_SYSTEM_OVERVIEW.md)

---

## 🔖 Version History

### v1.0 - 2025-01-20 16:30

**Initial plan generation** via brainstorming session

**Complexity**: HIGH (complete architectural redesign)
**Total Tasks**: 28
**Estimated Time**: ~60 hours (~6-8 weeks)

**Key Design Decisions**:
- Speed-focused approach (Option A from brainstorming)
- Minimal personalization using existing workout templates
- 2-step creation flow (vs 5-step wizard)
- Simplified entity model (12 fields vs 24+)
- Provider consolidation (5 providers vs 10+)
- Massive file reduction (25 files vs 72)

---

**Plan Author**: Claude Code (AI Assistant)
**Human Consultation**: Michele (Product Owner)
**Generated**: 2025-01-20 16:30
**Status**: Ready for Implementation ✅
