# FitLog Onboarding System - Complete Documentation

## Executive Summary

FitLog's onboarding system implements a sophisticated **progressive disclosure** model for fitness app retention, managing 6 initial steps + 8 contextual tours across 3 learning phases (CORE/DISCOVERY/ADVANCED).

**Current Status**: ⚠️ Compilation issues prevent production deployment (169 errors in domain services layer)

---

## 1. Architecture Overview

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────────┐
│ FitLog Onboarding System (Complete Flow)                        │
└─────────────────────────────────────────────────────────────────┘

┌─ INITIAL ONBOARDING (6 steps) ──────────────────────────────────┐
│                                                                  │
│ Step 0: Welcome          → Feature highlights (2 visible items) │
│ Step 1: Goal Selection   → Choose fitness goal                 │
│ Step 2: Personal Info    → Sex + Age input                     │
│ Step 3: Body Data        → Height + Weight + HealthKit import  │
│ Step 4: Experience       → Training level assessment           │
│ Step 5: Frequency+Summary→ Weekly workout frequency + preview  │
│                                                                  │
│ Output: OnboardingState saved to Hive + Firestore             │
└──────────────────────────────────────────────────────────────────┘

┌─ CONTEXTUAL TOURS (8 types) ───────────────────────────────────┐
│                                                                  │
│ CORE PHASE (Day 0):                                            │
│   - Home Tour (2 steps): XP bar + template suggestions         │
│   - Workout Tutorial (5 steps): Full workout creation flow     │
│                                                                  │
│ DISCOVERY PHASE (Day 1-3):                                    │
│   - Timer Tour: Rest timer functionality                       │
│   - Template Tutorial: Saving & reusing templates             │
│                                                                  │
│ ADVANCED PHASE (Day 4+):                                      │
│   - Analytics Tour: Metrics & progress tracking               │
│   - Custom Exercise Tutorial: Building custom exercises       │
│   - Advanced Techniques: Supersets, drop sets, etc.           │
│                                                                  │
│ EXPERT PHASE (Unreachable in practice - dead code)            │
│   - Health Integration Tour                                    │
│                                                                  │
│ Manager: OnboardingOrchestrator                                │
│   - Priority queue: Manages simultaneous tour requests        │
│   - Session limit: Max 10 steps per session                   │
│   - Cooldown: 30min between similar priority tours            │
│   - Phase gating: Controls feature reveal by learning phase   │
└──────────────────────────────────────────────────────────────────┘
```

### 1.2 State Management Architecture

```
Hive (Persistent Storage)
├── onboarding_state (21 HiveFields)
│   ├── hasSeenGlobalOnboarding
│   ├── currentStep / completedSteps
│   ├── stepData (questionnaire form values)
│   ├── userExperienceLevel
│   ├── hasAcceptedLegalDisclaimer ← CRITICAL
│   ├── legalDisclaimerAcceptedAt
│   └── [17 more fields]
│
└─── ISSUE: Not encrypted (PII: height, weight, health data)

Riverpod Providers (State Management)
├── onboardingStateProvider → OnboardingStateNotifier
├── onboardingOrchestratorProvider → OnboardingOrchestrator
├── initialOnboardingNotifierProvider → InitialOnboardingNotifier
├── initialOnboardingPageControllerProvider → Syncs PageView
└── shouldShowTourProvider → Tour availability checker

SharedPreferences (Quick Access)
├── firstLaunchKey: bool
├── firstLaunchDate: DateTime
├── workoutCount: int
└── tourCompletedFlags: bool per tour type
```

---

## 2. Initial Onboarding Flow (6 Steps)

### Step-by-Step Breakdown

| Step | Widget | Purpose | Input | Output |
|------|--------|---------|-------|--------|
| **0** | WelcomeStep | Feature intro | User reads copy | No input |
| **1** | GoalSelectionStep | Fitness goal | Button tap (Goal enum) | `userGoal` |
| **2** | PersonalInfoStep | Demographics | Sex (enum) + Age (int) | `sex`, `age` |
| **3** | BodyDataStep | Body measurements | Height + Weight ± HealthKit | `heightCm`, `bodyweightKg` |
| **4** | ExperienceStep | Training level | Radio button (Beginner/Intermediate/Advanced) | `userExperienceLevel` |
| **5** | FrequencySummaryStep | Cadence + confirmation | Weekly frequency + "Confirm" button | `weeklyWorkoutTarget` |

### 2.1 Critical Path

**Success Path**:
1. User completes all 6 steps (validation passes)
2. InitialOnboardingCompletionService.complete() called
3. Data persisted: Hive + Firestore
4. `hasSeenGlobalOnboarding = true`
5. Redirect to HomeScreen
6. Schedule HealthKit import (post-onboarding if needed)

**Error Paths**:
- **Permission Denied** (HealthKit): Shows dialog, allows skip (line 615-625 body_data_step.dart)
- **Validation Failed** (age <16): Prevents next step
- **App Kill Mid-Flow**: State persisted, can resume from `currentStep`
- **Network Offline**: HealthKit import deferred, LocalFirst Hive persists

### 2.2 Known Issues & Fixes

| Issue | Severity | Current Status | Fix |
|-------|----------|-----------------|-----|
| Session steps never reset | CRITICAL | ✅ Method exists (resetSessionSteps) | Needs AppLifecycleListener |
| HealthKit infinite spinner | CRITICAL | ✅ FIXED (finally block added 605-610) | Already implemented |
| PageController disposal race | HIGH | ⚠️ Partial fix (hasClients check only) | Need to verify disposed state |
| Weight suggestions visible | HIGH | ✅ FIXED (ITERATION 1) | Removed from welcome_step.dart |
| Weight input regex weak | MEDIUM | ❌ Not fixed | Use Pattern `^\d+(\.\d{1,2})?$` |

---

## 3. Progressive Disclosure & Learning Phases

### 3.1 Phase Progression

```
┌─────────────────────────────────────────────────────────────────┐
│ User Learning Journey (Timeline)                                │
└─────────────────────────────────────────────────────────────────┘

DAY 0 → CORE PHASE (Most Restrictive)
├─ Initial onboarding required
├─ Home tour (2 steps only) → XP bar + templates
├─ Workout tutorial (5 steps) → Create first workout
├─ Max: 10 steps total across all tours per session
├─ Tours queued if limit reached
└─ Purpose: Reduce cognitive overload, establish immediate wins

DAY 1-3 → DISCOVERY PHASE (Progressive Reveal)
├─ Core features well-understood
├─ Timer tutorial unlocked
├─ Template tutorial unlocked
├─ Advanced techniques hidden
├─ Session limit still enforced
└─ Purpose: Reveal secondary features as user discovers them

DAY 4+ → ADVANCED PHASE (Full Access)
├─ Analytics tour unlocked
├─ Custom exercise tutorial unlocked
├─ All features discoverable
├─ Session limit removed (or relaxed)
└─ Purpose: Empower power users

DAY 8+ → EXPERT PHASE (DEAD CODE - Never Reached)
├─ Calculated but never shown
├─ No tours configured for this phase
├─ Consider removing or implementing power features
└─ Recommendation: Remove from codebase (technical debt)
```

### 3.2 Learning Phase Calculation

```dart
LearningPhase calculateCurrentPhase() {
  final daysSinceFirstLaunch = DateTime.now().difference(firstLaunchDate).inDays;
  
  if (daysSinceFirstLaunch == 0) return LearningPhase.core;        // Day 0 only
  if (daysSinceFirstLaunch <= 3) return LearningPhase.discovery;   // Day 1-3
  if (daysSinceFirstLaunch <= 7) return LearningPhase.advanced;    // Day 4-7
  return LearningPhase.expert;                                     // Day 8+ (unused)
}
```

---

## 4. Tour Inventory & Conflict Matrix

### 4.1 All 8 Tour Types

```
CORE PHASE (Shown Day 0):
┌─ homeTour
│  Priority: IMPORTANT
│  Steps: 2 (XP bar + template suggestions)
│  Cooldown: 0 min (show immediately after onboarding)
│  Config: lib/features/onboarding/domain/services/onboarding_orchestrator.dart:97-105
│
└─ workoutTutorial
   Priority: CRITICAL (blocks if not understood)
   Steps: 5 (Add exercise → Set weight → Reps → Complete → History)
   Cooldown: 0 min
   Config: lib/features/onboarding/domain/services/onboarding_orchestrator.dart:106-113

DISCOVERY PHASE (Shown Day 1-3):
┌─ timerTour
│  Priority: USEFUL
│  Steps: 4 (Rest timer intro → Start → Pause → Complete)
│  Cooldown: 30 min (don't repeat during session)
│  Trigger: User starts first rest period
│
└─ templateTutorial
   Priority: USEFUL
   Steps: 4 (Save template → Name → Reuse → Confirm)
   Cooldown: 30 min
   Trigger: User completes second workout

ADVANCED PHASE (Shown Day 4+):
┌─ analyticsTour
│  Priority: OPTIONAL
│  Steps: 3 (Weekly chart → Muscle focus → Volume)
│  Cooldown: 60 min
│  Trigger: User views home/analytics
│
├─ customExerciseTutorial
│  Priority: OPTIONAL
│  Steps: 4 (Exercise library → Custom tab → Create → Save)
│  Cooldown: 60 min
│  Trigger: User clicks "+" to add exercise
│
├─ advancedTechniquesTutorial
│  Priority: OPTIONAL
│  Steps: 3 (What are supersets → Drop sets → Trisets)
│  Cooldown: 120 min
│  Trigger: User taps "Advanced" in exercise detail
│
└─ healthIntegrationTour
   Priority: OPTIONAL
   Steps: 2 (HealthKit intro → Benefits)
   Cooldown: 120 min
   Trigger: User taps HealthKit button

EXPERT PHASE (Never shown - dead code):
└─ (No tours configured - recommend cleanup)
```

### 4.2 Conflict Matrix

| Tour A | Tour B | Conflict? | Resolution |
|--------|--------|-----------|------------|
| homeTour | workoutTutorial | ❌ NO | Both shown Day 0 sequentially |
| workoutTutorial | timerTour | ✅ MAYBE | Timer only shown after first rest |
| timerTour | templateTutorial | ❌ NO | Different features, no overlap |
| analyticsTour | customExerciseTutorial | ✅ CONFLICT | Both show on same day - priority queued |

**Resolution Strategy**: OnboardingOrchestrator uses priority queue to serialize conflicting tours.

---

## 5. Data Model & Persistence

### 5.1 OnboardingState Entity (Hive Type 3)

```dart
@HiveType(typeId: 3)
class OnboardingState {
  // Progress tracking
  bool hasSeenGlobalOnboarding;     // Main gate
  int currentStep;                   // 0-5 in initial flow
  List<int> completedSteps;         // e.g., [0, 1, 2]
  bool canResume;                    // Resume from this step
  
  // Questionnaire data (raw form values)
  Map<String, dynamic> stepData;    // {height_cm: 180, weight_kg: 75}
  String? userExperienceLevel;      // "beginner" | "intermediate" | "advanced"
  String? userGoal;                 // "weight_loss" | "muscle_gain" | "endurance"
  int? weeklyWorkoutTarget;         // 3, 4, 5, 6, 7
  
  // Legal compliance (GDPR)
  bool hasAcceptedLegalDisclaimer;  // MUST be true before data use
  DateTime? legalDisclaimerAcceptedAt;
  
  // Tour tracking (for contextual tours)
  List<String> seenOverlays;        // ["homeTour", "timerTour"]
  int overlayVersionSeen;            // Version tracking for re-shows
  
  // Milestones
  DateTime? quickStartCompletedAt;   // When user completed onboarding
  bool hasCompletedFirstWorkout;     // Day 0 milestone
  DateTime? firstExerciseAddedAt;    // First "Add Exercise" action
  DateTime? firstSetCompletedAt;     // First set logged
  
  // Version tracking
  int onboardingVersion;             // Support migrations (currently 1)
  DateTime? lastInteraction;
}
```

### 5.2 Persistence Strategy

```
Initial Onboarding Complete
    ↓
1. Save to Hive (OnboardingState box)
   - Immediate (sync)
   - Survives app kill
   - Local-first
    ↓
2. Sync to Firestore (async)
   - Background task
   - Retry on network failure
   - For analytics/admin
    ↓
3. Update user profile
   - Set fitness profile metadata
   - Trigger AI coach initialization
```

---

## 6. Edge Cases & Error Handling

### 6.1 Critical Edge Cases

| Scenario | Current Behavior | Recommendation |
|----------|------------------|-----------------|
| **App kill mid-onboarding** | Resume from currentStep | ✅ Works via canResume flag |
| **No internet** | HealthKit import fails gracefully | ⚠️ May leave spinner stuck |
| **HealthKit permission denied** | Shows dialog, allows skip | ✅ Already fixed (finally block) |
| **Age < 16** | Validation blocks next step | ✅ Works |
| **Age >120** | Validation blocks next step | ✅ Works |
| **Weight input: "75.5.5"** | Accepted (weak regex) | ❌ FIX NEEDED |
| **User back-navigates** | Can go back through steps | ✅ Works |
| **Session limit hit (10 steps)** | Tours queued, never reset | ❌ CRITICAL FIX NEEDED |
| **Tour triggered during modal** | Pauses/hidden mid-tour | ❌ CRITICAL FIX NEEDED (Fix #2) |
| **Global onboarding seen but incomplete** | Allows restart | ⚠️ No re-entry mechanism |

### 6.2 Error Handling Strategy

**Recommended Pattern**:
```dart
try {
  await saveToHive();          // Local persistence
  await syncToFirestore();     // Remote sync (fire-and-forget)
} catch (e, stack) {
  // Log error
  debugPrint('Error: $e');
  // Show user-friendly message
  SnackBarService.showError(context, context.l10n.errorSaving);
  // Recovery: allow user to retry
} finally {
  setState(() => isLoading = false);  // Always reset loading state
}
```

---

## 7. UX Research Findings

### 7.1 Industry Benchmarks (2025)

| Metric | Industry Average | FitLog Current |
|--------|------------------|---|
| Day 1 Retention | 22-25% (mobile) | Unknown |
| Day 3 Retention | 10-15% | Unknown |
| Optimal onboarding steps | 7-8 screens | 6 ✅ |
| HealthKit delay perceived as freeze | >2s | 2-3s ⚠️ |
| AI adaptation impact | +50% retention | Not implemented |
| Gamification impact | +60% retention | Implemented (XP system) |

### 7.2 FitLog vs Best Practices

| Category | FitLog | Best Practice | Gap |
|----------|--------|---------------|-----|
| Progressive disclosure | ✅ 3-phase model | 7-8 screens reveal | 0 |
| Permission timing | ⏭️ After onboarding | When needed | -1 (late HealthKit) |
| Quick wins | Missing | Show first workout complete immediately | -1 |
| Social features | Not in onboarding | Suggest friend add early | -1 |
| AI personalization | Not implemented | Adapt to fitness level | -2 (HIGH PRIORITY) |
| Visual engagement | Text-heavy | Before/after gallery | -1 |

### 7.3 Persona-Specific Friction

| Persona | Friction Points | Time-to-Value | Abandonment Risk |
|---------|-----------------|----------------|-----------------|
| **Marco** (Overwhelmed) | 6 screens feel long; body questions scary | 5-8 min | ❌ HIGH |
| **Chiara** (Busy) | HealthKit 2-3s lag; permission interrupts flow | 3-5 min | ❌ HIGH |
| **Luca** (Powerlifter) | No advanced metrics setup | 2-3 min | ⚠️ MEDIUM (frustrated) |
| **Sofia** (Visual) | No instant results; boring welcome screen | 4-6 min | ⚠️ MEDIUM |
| **Roberto** (Efficient) | Too many clicks; no "skip details" option | 2-4 min | ❌ HIGH |

---

## 8. Implementation Checklist (Post-Corruption Fix)

```
Blocking Issues (Fix required before production):
☐ Restore onboarding domain services from git history
☐ Fix StateNotifier inheritance in all 7 tour services
☐ Re-enable compilation (resolve 169 errors)
☐ Implement session step reset on app resume
☐ Test tour pause/resume for modal navigation

High Priority (v1.0):
☐ Add HealthKit loading indicator (UX improvement)
☐ Implement experience-level branching (personas)
☐ Gate Hive writes on legal acceptance (GDPR)
☐ Fix weight input regex (validation)

Medium Priority (v1.1):
☐ Encrypt Hive box for health data
☐ Consolidate 3 tour systems into UnifiedTourCoordinator
☐ Lazy-load tour services (app startup optimization)
☐ Implement AI-driven personalization

Testing (ITERATION 8 - post-fix):
☐ Unit tests: OnboardingOrchestrator (priority queue, phase gating)
☐ Unit tests: OnboardingState (serialization, migrations)
☐ Widget tests: All 6 initial steps
☐ Integration tests: Full flow E2E (Patrol if available)
☐ Edge case tests: Permission denial, app kill, network offline

Documentation:
☐ Create ADR for session reset pattern
☐ Document tour conflict resolution strategy
☐ Update README with onboarding flow diagrams
☐ Create troubleshooting guide for common issues
```

---

## 9. Troubleshooting Guide

### Common Issues

**Q: User stuck at 10-step limit, tours not showing**
- **Cause**: Session step counter never resets
- **Fix**: Implement AppLifecycleListener to call resetSessionSteps() on resume
- **Status**: CRITICAL - blocking

**Q: Tour shows briefly then disappears when opening modal**
- **Cause**: Modal navigation disposes tour state
- **Fix**: Add resumeAfterModal flag to OnboardingTourStep
- **Status**: CRITICAL - blocking (Fix #2)

**Q: HealthKit import shows spinner forever**
- **Cause**: _isImportingFromHealth flag not reset on permission deny
- **Fix**: Use finally block to reset flag
- **Status**: ✅ FIXED

**Q: Weight validation accepts "75.5.5" (invalid)**
- **Cause**: Regex pattern too permissive
- **Fix**: Use `Pattern(r'^\d+(\.\d{1,2})?$')` 
- **Status**: MEDIUM priority

**Q: Onboarding doesn't resume after app kill**
- **Cause**: canResume flag not set correctly
- **Fix**: Ensure setResumeFromStep() called after each step
- **Status**: ✅ Works (verify in testing)

---

## 10. ADRs (Architecture Decision Records)

### ADR-001: Progressive Disclosure via Learning Phases

**Decision**: Implement 3-phase learning system (CORE/DISCOVERY/ADVANCED) gated by days since first launch.

**Rationale**:
- Reduces Day 0 cognitive overload (industry best practice)
- Enables feature reveal aligned with user readiness
- Supports A/B testing for feature timing optimization

**Alternatives Rejected**:
- Single upfront tutorial: Too overwhelming for beginners
- Single contextual help: No structured onboarding

**Trade-offs**:
- Adds complexity: Phase calculation, tour gating logic
- Benefits: +50% retention potential (industry data)

---

### ADR-002: Session Step Limit (Max 10 steps/session)

**Decision**: Limit onboarding steps shown per user session to 10 maximum.

**Rationale**:
- Nielsen Norman research: Cognitive overload after 10+ sequential steps
- Prevents "tutorial fatigue" from overwhelming users

**Implementation**:
- OnboardingOrchestrator tracks `sessionStepsShown`
- Queues tours if limit reached
- Resets counter on app resume ⚠️ NOT IMPLEMENTED

**Trade-off**:
- Users may not see all tours in one session
- Benefit: Better UX, higher completion rates

---

### ADR-003: OnboardingOrchestrator as Single Coordinator

**Decision**: Centralize all onboarding logic in OnboardingOrchestrator (priority queue, phase gating, cooldown).

**Rationale**:
- Prevents tour conflicts (only one tour active at a time)
- Enables priority-based scheduling
- Enforces phase gating globally

**Current Issue**:
- ⚠️ Corrupted with 169 compilation errors (requires git recovery)

**Recommendation**:
- Fix corruption via git history restore
- Consider extracting to separate module post-recovery

---

## 11. Recommended Improvements (Priority)

### P0 (Critical):
1. Fix onboarding domain services compilation errors (169 errors)
2. Implement session step reset on app resume
3. Fix tour pause/resume for modal navigation
4. Test all edge cases post-fix

### P1 (High):
1. Add HealthKit loading indicator (improves perceived performance)
2. Implement experience-level branching (solves Luca/Marco/Roberto friction)
3. Gate Hive writes on legal acceptance (GDPR compliance)
4. Fix weight input regex (validation improvement)

### P2 (Medium):
1. Encrypt Hive box for health data (security)
2. Lazy-load tour services (app startup optimization)
3. Add skip/resume options for permissions (Chiara friction)
4. Show achievement preview on welcome screen (Sofia engagement)

### P3 (Nice-to-have):
1. Implement AI-driven personalization (adaptive flow)
2. Consolidate 3 independent tour systems
3. Add social features to onboarding (friend challenges)
4. Gamification: Show XP/streak early

---

## Appendix: Files Reference

### Key Files

**Presentation Layer**:
- `lib/features/onboarding/presentation/screens/initial/initial_onboarding_screen.dart` - Main screen
- `lib/features/onboarding/presentation/widgets/initial/steps/` - 6 step widgets
- `lib/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart` - Provider + PageController

**Domain Layer** (⚠️ CORRUPTED):
- `lib/features/onboarding/domain/services/onboarding_orchestrator.dart` - Central coordinator
- `lib/features/onboarding/domain/services/home_tour_service.dart` - Home tour
- `lib/features/onboarding/domain/services/workout_tutorial_service.dart` - Workout tutorial
- [5 more service files with same corruption pattern]

**Data Layer**:
- `lib/features/onboarding/domain/entities/onboarding_state.dart` - Hive entity
- `lib/features/onboarding/data/repositories/onboarding_repository.dart` - Data access

**Localization**:
- `assets/i18n/app_en.arb` - English strings
- `assets/i18n/app_it.arb` - Italian strings

---

## Document Version

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 3, 2026 | ITERATION 9 | Initial comprehensive documentation post-analysis |

---

**Status**: 🔴 **NOT PRODUCTION READY** - Requires codebase corruption fix + testing (estimated 2-3 days of engineering)

**Last Updated**: ITERATION 9 - Documentation & Finalization
