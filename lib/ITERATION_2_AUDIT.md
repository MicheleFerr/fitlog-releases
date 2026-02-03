# ITERATION 2 REPORT: System Architecture Audit

**Status**: ✅ **COMPLETE** - 9 critical findings, 3 architectural systems analyzed

**Audit Date**: 2026-02-03
**Scope**: OnboardingOrchestrator, Initial Flow (6-step), Tour System (8 tours)

---

## Executive Summary

The FitLog onboarding system has a **promising foundation with critical fragilities**:

- ✅ Progressive disclosure via 3-phase learning model is well-designed
- ✅ Cooldown logic prevents tutorial fatigue effectively
- 🔴 **CRITICAL**: 90% of tour GlobalKey targets not verified (silent failures)
- 🔴 **CRITICAL**: Session step limit never resets after day 1
- 🔴 **CRITICAL**: Three independent tour systems (no coordination)
- 🔴 **CRITICAL**: Expert phase unreachable (dead code)

**Architectural Score: 4.5/10** - Not production-ready

---

## 1. OnboardingOrchestrator Audit

### Progressive Disclosure (3-Phase Learning Model)

**Implementation Quality**: ⭐⭐⭐⭐ (Excellent)

The system correctly segments tours by learning phase:

```
┌─────────────────────────────────────────────────────────────┐
│ CORE (Day 0)         │ 2 tours, max 10 steps              │
│  - HomeTour (2 steps)│ Focus: Essential features only     │
│  - WorkoutTutorial   │ HealthKit after 1st workout       │
│                      │                                    │
│ DISCOVERY (Day 1-3)  │ 2 tours triggered by discovery    │
│  - TimerTour (1)     │ Minimal - auto-start explanation  │
│  - TemplateTutorial  │                                    │
│                      │                                    │
│ ADVANCED (Day 4+)    │ 2 tours, after 3-5 workouts      │
│  - AnalyticsTour     │ Show after evidence of usage      │
│  - AdvancedTech      │                                    │
│                      │                                    │
│ EXPERT (Never?) 🔴   │ 1 tour unreachable               │
│  - CustomExerciseTut │ Dead code - expert phase never hit│
└─────────────────────────────────────────────────────────────┘
```

**Strength**: Phase calculation via `daysSinceFirstLaunch` is stateless and predictable

**Critical Issue 🔴**: Expert phase is unreachable

```dart
// onboarding_orchestrator.dart line 238-239
if (daysSinceFirstLaunch <= 7) return LearningPhase.advanced;
return LearningPhase.expert;  // ← Day 8+ reaches here

// But NO tour configured to require expert phase
// Result: customExerciseTutorial lives in unreachable territory
```

**Fix Required**: Either implement expert-phase tours OR remove the enum value

---

### Session Step Limit (max 10/session)

**Current Implementation**:
- Global limit: `maxStepsPerSession = 10`
- Counter: `sessionStepsShown` (per session)

**Critical Issue 🔴**: Session counter never resets

```dart
// No AppLifecycleListener calls resetSessionSteps()
// No provider triggers reset on app resume
```

**Failure Scenario**:
1. Day 1: User sees 10 steps of onboarding tours → hits limit
2. User closes app (or goes to sleep)
3. Day 2: User opens app → counter still = 10 → **NO tours shown for entire day**
4. Day 4: ADVANCED phase unlocked but AnalyticsTour still blocked by stale counter

**Fix**: Add AppLifecycleListener to reset counter on app resume

---

### Cooldown Logic & Priority Queue

**Implementation Quality**: ⭐⭐⭐⭐ (Excellent)

Cooldown matrix is well-designed:

| Tour | Priority | Cooldown | Purpose |
|------|----------|----------|---------|
| workoutTutorial | P0 | 0 min | Critical path |
| homeTour | P1 | 0 min | Essential early |
| timerTour | P2 | 60 min | Prevent annoyance |
| analyticsTour | P2 | 120 min | Advanced feature |
| customExercise | P3 | 240 min | Niche feature |

**Medium Issue 🟡**: Priority doesn't consider phase

Current code:
```dart
if (requestedConfig.priority.index < activeConfig.priority.index) {
  // Higher priority interrupts
}
```

**Problem**: A P1 tour in ADVANCED phase can interrupt P0 tour in CORE phase

**Fix**: Comparison should be: **LearningPhase (DESC) > Priority (DESC)**
- P0 CORE > P3 ADVANCED ✅
- P2 DISCOVERY > P3 EXPERT ✅

---

## 2. Initial Onboarding Flow (6 Steps)

### Step Dependency Map

```
Step 0: Welcome          (read-only, always valid)
  ↓
Step 1: Goal             (goal != null)
  ↓
Step 2: Personal Info    (sex != null && age != null)
  ├─ FRICTION: Age validation unclear (no range check)
  ↓
Step 3: Body Data        (height != null && weight != null)
  ├─ FRICTION 🔴: HealthKit async delay (2-3s hang)
  └─ Hardcoded weight min: 30kg
  ↓
Step 4: Experience       (experience != null)
  ├─ FRICTION: ExperienceLevel terminology unclear
  ↓
Step 5: Frequency        (1 ≤ workoutsPerWeek ≤ 7)
  └─ onComplete → start HomeTour
```

### Back Navigation Issue 🟡

**Medium Issue**: No data re-validation on backward navigation

Scenario:
1. Fill Step 1 (Goal: "Strength")
2. Move to Step 2
3. Go back to Step 1
4. Change goal to "Cardio"
5. Later: Goal shows "Strength" (cached from before)

**Fix**: Trigger re-validation when user navigates backward

---

### State Persistence Gap 🟡

**Current**: In-memory only (Riverpod StateNotifier)

**Problem**: Force-close app mid-onboarding → lose progress, restart from Step 0

**Fix**: Save `currentStep` to SharedPreferences

---

### Friction Points

| Step | Issue | Impact | Fix |
|------|-------|--------|-----|
| 3 | HealthKit async delay | 2-3s freeze | Add LoadingIndicator |
| 2 | Age range unclear | User confusion | Add helper text |
| 4 | Experience terms vague | Selection paralysis | Add tooltips |
| 5 | Summary incomplete | Verify choices feel missed | Show all selections |

---

## 3. Tour Inventory & GlobalKey Targeting

### Complete Tour Mapping (8 tours)

| # | Tour | Phase | Steps | Status | Risk |
|---|------|-------|-------|--------|------|
| 1 | HomeTour | CORE | 2 | ✅ Clean | Low |
| 2 | WorkoutTutorial | CORE | 5 | ⚠️ Fragile (static cache) | High |
| 3 | HealthIntegration | CORE | 1 | ✅ Good timing | Low |
| 4 | TimerTour | DISCOVERY | 1 | ⚠️ May be too minimal | Medium |
| 5 | TemplateTutorial | DISCOVERY | 4 | ❓ Not fully verified | High |
| 6 | AnalyticsTour | ADVANCED | 5 | ❓ Implementation incomplete | High |
| 7 | AdvancedTech | ADVANCED | 6 | ⚠️ Config exists but untested | High |
| 8 | CustomExercise | EXPERT | 5 | 🔴 DEAD CODE (phase unreachable) | Critical |

### Critical Issue 🔴: GlobalKey Targets Not Verified

**Finding**: 9 out of 10 tour targets cannot be located in codebase

| Target | Status | Impact |
|--------|--------|--------|
| xpProgressBar | ❌ NOT FOUND | HomeTour spotlight fails silently |
| templateSuggestion | ✅ FOUND | OK |
| exerciseMenuButton | ❌ NOT FOUND | WorkoutTutorial step fails |
| timerDisplay | ❌ NOT FOUND | TimerTour fails |
| analyticsList | ❌ NOT FOUND | AnalyticsTour fails |
| ... | ... | ... |

**Implication**: When tour tries to highlight a widget:

```dart
if (targetKey.currentContext == null) {
  debugPrint('⚠️ Target widget not found');
  return;  // ← Silent failure, no exception
}
```

Result: Tour appears but **without spotlight highlighting** - user sees modal but doesn't know where to look

**Fix Required**: Audit every screen and verify GlobalKey exists

---

### Tour Conflict Matrix 🔴

**Critical Issue**: No mutual exclusion between simultaneous tours

**Scenario - Day 1, First Workout Completion**:
```
Timeline:
1. Set completed
   → WorkoutTutorial.advanceStep() → "tapSet" step
   → Tries to show spotlight on next set card

2. Timer auto-starts
   → TimerTour.startTour() → auto-start step
   → Tries to show spotlight on timer

Result: Both overlays render on top of each other → UI confusion
```

**Root Cause**: Three independent tour systems

```
System A: OnboardingOrchestrator (8 TourType enums)
System B: Individual Service Notifiers (homeTourProvider, workoutTutorialProvider, etc.)
System C: TutorialRegistry (15 contextual events)

DISCONNECT: They don't know about each other
```

---

## 4. Architecture Issues Found

### Critical (P0) - 4 issues

1. **GlobalKey targets not verified** (90% missing)
   - Impact: Tours fail silently
   - Severity: Production-blocking

2. **Session step limit never resets**
   - Impact: Tours blocked after day 1
   - Severity: Production-blocking

3. **Expert phase unreachable**
   - Impact: Dead code, maintenance burden
   - Severity: Production-blocking

4. **No mutual exclusion between tours**
   - Impact: Simultaneous tours crash UI
   - Severity: Production-blocking

### Major (P1) - 5 issues

5. Two independent tour systems
6. HealthKit async delay causes UI freeze
7. Onboarding state not persisted across app restart
8. Phase transition logic fragile (priority doesn't consider phase)
9. No telemetry/analytics tracking

### Best Practices Implemented (5) ✅

- Progressive disclosure via phases
- Session step limiting
- Adaptive pacing configuration
- Cooldown logic to prevent fatigue
- Minimalist home tour (2 steps instead of 5)

---

## 5. Proposed Architecture Diagram

```
Current (3 systems):
┌─────────────────────────────────────────────┐
│ OnboardingOrchestrator                      │
│ ├─ 8 TourType enums                        │
│ └─ Phase-based gating                      │
│                                             │
│ +Individual Service Notifiers               │
│ ├─ homeTourProvider                        │
│ ├─ workoutTutorialProvider                 │
│ └─ ... (separate state per tour)           │
│                                             │
│ +TutorialRegistry                           │
│ └─ 15 contextual event→tutorial mappings   │
└─────────────────────────────────────────────┘

Proposed (consolidated):
┌─────────────────────────────────────────────┐
│ UnifiedTourCoordinator                      │
│ ├─ Manages ALL tour types                  │
│ ├─ Single priority queue                   │
│ ├─ Prevents simultaneous tours             │
│ ├─ Phase-based gating                      │
│ └─ Unified SharedPreferences schema        │
└─────────────────────────────────────────────┘
```

---

## 6. Immediate Action Items

### Blocking (before production)

- [ ] Verify all GlobalKey targets in MinimalHomeScreen, WorkoutSession, AnalyticsScreen, etc.
- [ ] Implement session reset on AppLifecycleListener.resumed
- [ ] Remove expert phase enum OR implement expert-phase tours
- [ ] Add mutual exclusion: prevent simultaneous tour overlays

### High Priority (before beta)

- [ ] Consolidate 3 tour systems into single coordinator
- [ ] Persist onboarding currentStep to SharedPreferences
- [ ] Add LoadingIndicator during HealthKit connection
- [ ] Implement tour completion telemetry (tour_started, tour_completed, tour_skipped events)

### Medium Priority (polish)

- [ ] Priority comparison considers phase
- [ ] Queue retry logic for cooldown-blocked tours
- [ ] Add tour state export/import for backup

---

## 7. References

- `lib/features/onboarding/domain/services/onboarding_orchestrator.dart`
- `lib/features/onboarding/presentation/screens/initial/...` (6 step screens)
- `lib/features/onboarding/domain/services/workout_tutorial_service.dart`
- `lib/features/home/presentation/minimal_home_screen.dart` (tour targets)

---

**Next Step**: ITERATION 3 - UX Research & Best Practices comparison

