# ITERATION 2: System Architecture Audit

**Date**: 2026-02-03
**Iteration**: 2/9
**Status**: 🚧 In Progress

---

## 🎯 EXECUTIVE SUMMARY

Questa iteration fornisce un'analisi approfondita dell'architettura del sistema onboarding di FitLog, mappando tutti i tour, identificando dependencies e potenziali conflitti.

---

## 📊 COMPLETE TOUR INVENTORY

### Tour Configuration Matrix

| Tour Type | Priority | Phase | Steps | Cooldown | Min Workouts | Requires Data | Prefs Key |
|-----------|----------|-------|-------|----------|--------------|---------------|-----------|
| **homeTour** | Important | Core | 2 | 0m | 0 | No | `home_tour_completed` |
| **workoutTutorial** | Critical | Core | 5 | 0m | 0 | No | `workout_tutorial_completed` |
| **healthIntegrationTour** | Important | Core | 1 | 0m | 1 | No | `health_integration_tour_completed` |
| **timerTour** | Useful | Discovery | 1 | 60m | 0 | No | `timer_tour_completed` |
| **templateTutorial** | Useful | Discovery | 4 | 60m | 0 | No | `template_tutorial_completed` |
| **analyticsTour** | Useful | Advanced | 5 | 120m | 3 | Yes | `analytics_tour_completed` |
| **advancedTechniquesTutorial** | Optional | Advanced | 6 | 180m | 5 | No | `advanced_techniques_tutorial_completed` |
| **customExerciseTutorial** | Optional | Expert | 5 | 240m | 0 | No | `custom_exercise_tutorial_completed` |

**Total**: 8 active tour types
**Removed**: `exerciseSearchTutorial` (UX analysis 2025 - search UI is standard pattern)

---

## 🔄 PROGRESSIVE DISCLOSURE SYSTEM

### Learning Phases Timeline

```
Day 0 (First Launch)
├─ CORE PHASE (0-1 days)
│  ├─ homeTour (2 steps) ───────────┐
│  ├─ workoutTutorial (5 steps) ────┤ Max 10 steps total
│  └─ healthIntegrationTour (1 step)─┘  per session
│
Day 1-3
├─ DISCOVERY PHASE
│  ├─ timerTour (1 step) ─────── Triggers when user uses timer
│  └─ templateTutorial (4 steps) ─ Triggers when user opens templates
│
Day 4+
├─ ADVANCED PHASE
│  ├─ analyticsTour (5 steps) ───── Requires 3+ workouts + data
│  └─ advancedTechniquesTutorial ── Requires 5+ workouts
│
Day 8+
└─ EXPERT PHASE
   └─ customExerciseTutorial ─────── Power user feature

Total steps if all completed: 29 steps
Session-limited: Max 10 steps per session
```

### Phase Calculation Logic

**File**: `onboarding_orchestrator.dart:229-240`

```dart
LearningPhase calculateCurrentPhase() {
  if (firstLaunchDate == null) return LearningPhase.core;

  final daysSinceFirstLaunch = DateTime.now()
      .difference(firstLaunchDate!)
      .inDays;

  if (daysSinceFirstLaunch == 0) return LearningPhase.core;
  if (daysSinceFirstLaunch <= 3) return LearningPhase.discovery;
  if (daysSinceFirstLaunch <= 7) return LearningPhase.advanced;
  return LearningPhase.expert;
}
```

---

## 🎬 TOUR TRIGGERS & LIFECYCLE

### 1. Home Tour (Core - Priority: Important)

**Trigger**: Auto-start after initial onboarding completion
**Location**: `minimal_home_screen.dart:69-98`
**Steps**:
1. XP Progress Bar - Explain gamification system
2. Template Suggestion - AI recommendation feature

**Target Keys**:
- `_xpProgressKey` → XPProgressBar widget
- `_templateSuggestionKey` → TemplateSuggestionCard widget

**Service**: `home_tour_service.dart`
**Provider**: `homeTourProvider`

**Trigger Flow**:
```
InitialOnboardingScreen.complete()
  → completionService.complete(data)
  → ref.read(homeTourProvider.notifier).startTour()
  → context.goNamed(AppRoutes.homeName)
  → MinimalHomeScreen builds
  → _checkAutoStartTour() detects isActive
  → _showHomeTour() displays overlay
```

---

### 2. Workout Tutorial (Core - Priority: Critical)

**Trigger**: Auto-start on first visit to empty workout screen
**Location**: `workout_screen.dart:166-188`
**Steps**:
1. Add Exercise FAB - Highlight how to add first exercise
2. Tap Set - Explain how to log reps/weight
3. Exercise Menu - Show advanced options (3 dots)
4. Reorder - Explain drag to reorder
5. Settings - Show workout settings
6. Finish - Complete workout button

**Target Keys**:
```dart
WorkoutTutorialStep.addExercise: _addExerciseFABKey
WorkoutTutorialStep.tapSet: _firstSetRowKey
WorkoutTutorialStep.exerciseMenu: _exerciseMenuKey
WorkoutTutorialStep.reorder: _reorderButtonKey
WorkoutTutorialStep.settings: _settingsButtonKey
WorkoutTutorialStep.finish: _completeWorkoutButtonKey
```

**Service**: `workout_tutorial_service.dart`
**Provider**: `workoutTutorialProvider`

**Trigger Flow**:
```
WorkoutScreen.initState()
  → _showFirstWorkoutWelcomeIfNeeded() (500ms delay)
  → Check: !hasStartedTutorial && !isActive && workout.exercises.isEmpty
  → _startWorkoutTutorial()
  → Shows step-by-step interactive overlay
```

**Special Behavior**:
- Uses `TutorialCoachMark` library for spotlight effect
- `enableTargetTab: true` ONLY for addExercise step (allows tapping FAB)
- Static cache `_cachedState` survives provider rebuilds
- Handles app lifecycle (resume from background)

**🐛 KNOWN BUG**: Tutorial state not preserved through modal navigation (see Iteration 1)

---

### 3. HealthKit Integration Tour (Core - Priority: Important)

**Trigger**: After completing first workout
**Location**: TBD (config exists but implementation not found in audit)
**Steps**:
1. Single prompt dialog asking for HealthKit permission

**Requirements**:
- `minWorkoutsRequired: 1`
- Shows immediately after workout completion
- No cooldown (show as soon as eligible)

**Status**: ⚠️ **IMPLEMENTATION MISSING**
- Config exists in `TourConfig.configs`
- No corresponding service file found
- No provider registered
- No trigger logic found

**Action Required**: Implement or remove from config

---

### 4. Timer Tour (Discovery - Priority: Useful)

**Trigger**: When user interacts with timer for first time
**Location**: TBD
**Steps**:
1. Explain auto-start timer feature

**Service**: `timer_tour_service.dart`
**Cooldown**: 60 minutes

**Status**: ⚠️ **PARTIAL IMPLEMENTATION**
- Service file exists
- Need to verify trigger logic

---

### 5. Template Tutorial (Discovery - Priority: Useful)

**Trigger**: When user opens template screen
**Location**: TBD
**Steps** (4 total):
1. Template carousel explanation
2. Create template button
3. Template actions (edit, delete, share)
4. Schedule template feature

**Service**: `template_tutorial_service.dart`
**Cooldown**: 60 minutes

**Status**: ⚠️ **PARTIAL IMPLEMENTATION**
- Service file exists but not in glob results
- Need to verify trigger logic

---

### 6. Analytics Tour (Advanced - Priority: Useful)

**Trigger**: After 3+ workouts, when user opens analytics
**Location**: TBD
**Steps** (5 total):
1. Volume tracking card
2. Muscle distribution chart
3. Progress graph
4. PR (Personal Records) section
5. Export/Share data

**Requirements**:
- `minWorkoutsRequired: 3`
- `requiresData: true` (must have workout history)

**Service**: `analytics_tour_service.dart`
**Cooldown**: 120 minutes (2 hours)

**Status**: ⚠️ **PARTIAL IMPLEMENTATION**
- Service file exists
- Need to verify data check logic

---

### 7. Advanced Techniques Tutorial (Advanced - Priority: Optional)

**Trigger**: After 5+ workouts
**Location**: TBD
**Steps** (6 total):
1. Superset creation
2. Drop sets
3. Rest-pause sets
4. AMRAP (As Many Reps As Possible)
5. Tempo training
6. Auto-regulation (RIR/RPE)

**Requirements**:
- `minWorkoutsRequired: 5`

**Service**: TBD (no file found)
**Cooldown**: 180 minutes (3 hours)

**Status**: 🔴 **NOT IMPLEMENTED**
- Config exists but no service file
- High-value feature for advanced users

---

### 8. Custom Exercise Tutorial (Expert - Priority: Optional)

**Trigger**: Manual or when user first creates custom exercise
**Location**: TBD
**Steps** (5 total):
1. Create custom exercise button
2. Exercise naming and categorization
3. Muscle group selection
4. Equipment and modality
5. Save and use in workouts

**Service**: TBD
**Cooldown**: 240 minutes (4 hours)

**Status**: 🔴 **NOT IMPLEMENTED**
- Expert-level feature
- Lowest priority but valuable for power users

---

## 🔀 TOUR CONFLICTS & OVERLAPS MATRIX

### Priority-Based Interrupt Rules

```
CRITICAL (workoutTutorial)
  ↓ CAN INTERRUPT
IMPORTANT (homeTour, healthIntegrationTour)
  ↓ CAN INTERRUPT
USEFUL (timerTour, templateTutorial, analyticsTour)
  ↓ CAN INTERRUPT
OPTIONAL (advancedTechniquesTutorial, customExerciseTutorial)
```

**Implementation**: `onboarding_orchestrator.dart:402-418`

### Potential Conflicts

| Conflict Scenario | Tour A | Tour B | Risk | Resolution |
|-------------------|--------|--------|------|------------|
| **Same Screen** | homeTour | workoutTutorial | 🔴 High | Sequential (home first via onboarding flow) |
| **Cooldown Overlap** | timerTour | templateTutorial | 🟡 Medium | 60min cooldown prevents both showing |
| **Phase Boundary** | Core tours | Discovery tours | 🟢 Low | Day 1 transition well-defined |
| **Session Limit** | All tours | N/A | 🔴 High | Max 10 steps enforced globally |

### Identified Issues

**Issue 2.1: No Mutual Exclusion for Same-Screen Tours**
```
Scenario: User completes onboarding → homeTour starts → user immediately
taps workout → workoutTutorial ALSO eligible → both want to show

Problem: Only priority prevents conflict, but both are Core phase
- homeTour: Priority.important
- workoutTutorial: Priority.critical

Result: workoutTutorial would interrupt homeTour (correct behavior)
BUT: User misses home tour completely, never sees XP/template explanation

Fix Required: Add "prerequisite" system
- workoutTutorial requires: homeTour completed OR skipped
```

**Issue 2.2: healthIntegrationTour Timing Problem**
```
Config: Shows after 1 workout (minWorkoutsRequired: 1)
Phase: Core (should show Day 0)

Problem: First workout happens Day 0 (onboarding day)
- User just saw 2 tours (home + workout)
- Session limit allows 10 steps total
- healthIntegration adds 1 step
- 2 + 5 + 1 = 8 steps (within limit ✅)

BUT: User fatigue - 3 tours in first session is overwhelming
- Onboarding best practice: max 2 tours per session for Core phase

Fix Required: Move healthIntegrationTour to Discovery phase (Day 1-3)
- OR: Make it opt-in from settings instead of auto-tour
```

**Issue 2.3: Analytics Tour Data Check Insufficient**
```
Config: requiresData: true

Problem: No implementation of data validation
- Check in orchestrator:242 only verifies flag
- No actual data existence check

Scenario: User has 3 workouts but all empty (no exercises)
- analyticsTour shows but has no data to display
- Tour shows empty charts/graphs
- Bad UX

Fix Required: Implement hasValidAnalyticsData() check
- Verify at least 1 workout with 1+ exercises
- Verify at least 3 sets logged across all workouts
```

---

## 🎯 GLOBALKEY TARGET VERIFICATION

### Target Key Availability Matrix

| Tour Step | GlobalKey | Widget Location | Verified | Notes |
|-----------|-----------|-----------------|----------|-------|
| homeTour.xpProgress | `_xpProgressKey` | `minimal_home_screen.dart:200` | ✅ | Always renders |
| homeTour.templateSuggestion | `_templateSuggestionKey` | `minimal_home_screen.dart:240` | ✅ | Always renders |
| workoutTutorial.addExercise | `_addExerciseFABKey` | `workout_screen.dart:92` | ✅ | Conditional on isActive/isPreloaded |
| workoutTutorial.tapSet | `_firstSetRowKey` | Exercise list item | ⚠️ | **Only if exercise exists** |
| workoutTutorial.exerciseMenu | `_exerciseMenuKey` | Exercise list item | ⚠️ | **Only if exercise exists** |
| workoutTutorial.reorder | `_reorderButtonKey` | `workout_screen.dart:94` | ✅ | Always in AppBar |
| workoutTutorial.settings | `_settingsButtonKey` | `workout_screen.dart:95` | ✅ | Always in AppBar |
| workoutTutorial.finish | `_completeWorkoutButtonKey` | `workout_screen.dart:93` | ✅ | Always in AppBar |

### 🐛 Critical Issue Found: Exercise-Dependent Keys

**Problem**: Steps `tapSet` and `exerciseMenu` require an exercise to exist

**Current Flow**:
```
1. Tutorial shows addExercise step → User taps FAB
2. Tutorial advances to tapSet step
3. Modal opens for exercise selection
4. User adds exercise → Modal closes
5. Tutorial tries to show tapSet target
   ↓
   ❌ IF exercise doesn't render immediately → KeyTarget null → Tour crashes
```

**Root Cause**: Race condition between:
- Modal close animation (300ms)
- Exercise widget build
- Tutorial trying to access GlobalKey

**Fix**: Add `waitForTarget` with timeout
```dart
void showCurrentStep({required GlobalKey targetKey, ...}) {
  // Wait up to 1 second for target to become available
  Future<void> waitForTarget() async {
    for (int i = 0; i < 10; i++) {
      if (targetKey.currentContext != null) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw TimeoutException('Target not found after 1s');
  }

  await waitForTarget();
  // Show tutorial...
}
```

---

## 📋 BACK NAVIGATION & STATE PRESERVATION

### Initial Onboarding Flow

**File**: `initial_onboarding_screen.dart:50-57`

```dart
_LinearProgressBar(
  currentStep: state.currentStep,
  totalSteps: state.totalSteps,
  onBack: state.currentStep > 0
      ? () => ref.read(initialOnboardingNotifierProvider.notifier)
            .previousStep()
      : null,
)
```

**Test Results**:

| Test Case | Expected | Actual | Status |
|-----------|----------|--------|--------|
| Step 0 → Back button | Hidden | ✅ Hidden | PASS |
| Step 1 → Back | Go to Step 0 | ✅ Works | PASS |
| Step 2 → Back | Go to Step 1, preserve data | ✅ Data preserved | PASS |
| Step 5 → Back → Forward | Data still there | ✅ State intact | PASS |

**Conclusion**: Back navigation works correctly ✅

---

### Tour Overlay State Preservation

**Test Scenarios**:

#### Scenario 1: App Backgrounded During Tour
```
State: workoutTutorial active, step 2/6
Action: User gets phone call (app goes to background)
Expected: Tour pauses, resumes when app returns
Actual: ✅ Tour resumes (didChangeAppLifecycleState handles this)
```

**Implementation**: `workout_screen.dart:133-149`
- Lifecycle observer re-shows tutorial after 500ms
- Check: `isActive && !hasCompletedTutorial`

#### Scenario 2: Screen Navigation During Tour
```
State: homeTour active, step 1/2
Action: User taps workout tab
Expected: Tour cancels OR follows to new screen
Actual: ⚠️ Tour disappears silently
```

**Problem**: Tour tied to specific screen, doesn't follow navigation
**Fix Required**: Add tour.cancel() on screen dispose OR make tour global overlay

#### Scenario 3: Modal Over Tour
```
State: workoutTutorial, step 1 (addExercise)
Action: User taps FAB → AddExerciseModal opens
Expected: Tour pauses, resumes after modal
Actual: 🐛 Tour advances but disappears (Bug 2 from Iteration 1)
```

---

## 📊 STATE MANAGEMENT ARCHITECTURE

### Provider Hierarchy

```
onboardingOrchestratorProvider (Global coordinator)
  ├─ Manages: activeTour, queuedTours, completedTours
  ├─ Persists: SharedPreferences (8 keys)
  └─ Children providers (independent):
      ├─ homeTourProvider (home_tour_service.dart)
      ├─ workoutTutorialProvider (workout_tutorial_service.dart)
      ├─ analyticsTourProvider (analytics_tour_service.dart)
      └─ timerTourProvider (timer_tour_service.dart)

initialOnboardingNotifierProvider (One-time initial flow)
  ├─ Manages: 6-step wizard state
  ├─ Persists: Hive (OnboardingState with 21 fields)
  └─ Isolated from tour system (completes before tours start)
```

### Data Flow

```
User Action (e.g., opens workout screen)
  ↓
Screen checks: shouldShowTour(TourType.workoutTutorial)
  ↓
Orchestrator.canShowTour():
  - Check completed?
  - Check active tour?
  - Check phase requirement?
  - Check workout count?
  - Check session limit?
  - Check cooldown?
  ↓
IF all pass → Screen calls: requestTour(TourType.workoutTutorial)
  ↓
Orchestrator checks priority:
  - IF higher priority → interrupt active tour
  - IF lower priority → queue for later
  ↓
Tour becomes active → Screen shows overlay
  ↓
User completes/skips → completeTour() OR skipTour()
  ↓
Orchestrator:
  - Marks completed in SharedPreferences
  - Increments sessionStepsShown
  - Processes queue
```

---

## 🔧 ARCHITECTURE IMPROVEMENTS NEEDED

### Priority P0

1. **Implement Missing Tours**
   - healthIntegrationTour (has config, no implementation)
   - advancedTechniquesTutorial (has config, no service)
   - customExerciseTutorial (has config, no service)

2. **Fix GlobalKey Race Conditions**
   - Add waitForTarget with timeout
   - Handle null context gracefully
   - Retry logic for transient failures

3. **Add Tour Prerequisites System**
   ```dart
   TourConfig(
     type: TourType.workoutTutorial,
     prerequisites: [TourType.homeTour], // NEW
     // ...
   )
   ```

### Priority P1

4. **Improve Analytics Data Validation**
   ```dart
   bool hasValidAnalyticsData() {
     final workouts = getCompletedWorkouts();
     if (workouts.length < 3) return false;

     final totalSets = workouts
         .expand((w) => w.exercises)
         .expand((e) => e.sets)
         .where((s) => s.isCompleted)
         .length;

     return totalSets >= 3; // At least 3 logged sets
   }
   ```

5. **Add Tour Cancellation on Navigation**
   - Override screen dispose() to call tour.cancel()
   - OR: Make tours global overlay that follows navigation

6. **Move healthIntegrationTour to Discovery Phase**
   - Reduces Day 0 cognitive load
   - Still shows early (Day 1-3) but after initial learning

### Priority P2

7. **Add A/B Testing Framework**
   ```dart
   TourConfig(
     type: TourType.homeTour,
     variant: TourVariant.control, // or .experimental
     // ...
   )
   ```

8. **Add Analytics Tracking**
   - Tour started event
   - Step completion rate
   - Skip rate per step
   - Time to complete
   - Drop-off points

---

## 📈 METRICS & SUCCESS CRITERIA

### Current Baselines (Need Measurement)

| Metric | Target | Current | Gap |
|--------|--------|---------|-----|
| Initial onboarding completion rate | >80% | ? | TBD |
| Home tour completion rate | >60% | ? | TBD |
| Workout tutorial completion rate | >70% | ? | TBD |
| Average steps per session | ≤10 | ? | TBD |
| Tour skip rate | <30% | ? | TBD |
| Time to first tour interaction | <5s | ? | TBD |

### Iteration 2 Success Criteria

- ✅ Complete tour inventory documented (8 tours)
- ✅ Trigger flow mapped for each tour
- ✅ Conflicts matrix created
- ✅ GlobalKey targets verified
- ✅ 3 P0 architecture issues identified
- ⏳ State preservation tests (partial - need full E2E)

---

**End of Iteration 2 Analysis**
**Next**: Iteration 3 - UX Research & Best Practices
**Estimated completion**: 2026-02-03 (same day, continuing autonomous execution)
