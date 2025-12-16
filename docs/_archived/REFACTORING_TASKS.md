# Refactoring Tasks - Detailed Breakdown

This document provides specific, actionable tasks for refactoring the 5 critical files.

## PHASE 1: CRITICAL FILES (Weeks 1-2)

### Task 1.1: Extract APREService from workout_provider.dart

**Current Location**: `lib/features/workout/presentation/providers/workout_provider.dart` (lines 1756-1974)

**What to Extract**:
- `_preCalculateAllAPREWeights()` method
- `_preCalculateAllAPREWeightsInternal()` method
- `_calculateAndSetBaseWeight()` method
- All APRE-related logic

**New File**: `lib/features/workout/domain/services/apre_auto_regulation_service.dart`

**Benefits**:
- Extract 200+ LOC from provider
- Service can be unit tested independently
- Reusable from other features

**Acceptance Criteria**:
- [ ] New APREService class created
- [ ] All APRE methods moved to service
- [ ] Provider delegates to service
- [ ] Unit tests for APREService (at least 5 test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 2-3 hours

---

### Task 1.2: Extract ExerciseSetService from workout_provider.dart

**Current Location**: `lib/features/workout/presentation/providers/workout_provider.dart` (lines 1377-1463)

**What to Extract**:
- `updateExerciseSet()` method
- `addSetToExercise()` method
- `removeSetFromExercise()` method
- Set-specific logic

**New File**: `lib/features/workout/domain/services/exercise_set_service.dart`

**Benefits**:
- Extract 150+ LOC from provider
- Clean separation of concerns
- Better testability

**Acceptance Criteria**:
- [ ] New ExerciseSetService class created
- [ ] All set methods moved to service
- [ ] Provider calls service for set operations
- [ ] Unit tests for ExerciseSetService (5+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 2 hours

---

### Task 1.3: Extract SupersetService from workout_provider.dart

**Current Location**: `lib/features/workout/presentation/providers/workout_provider.dart` (lines 1493-1691)

**What to Extract**:
- `updateSupersetSet()` method
- `addRoundToSuperset()` method
- `removeRoundFromSuperset()` method
- All superset-specific operations

**New File**: `lib/features/workout/domain/services/superset_service.dart`

**Benefits**:
- Extract 100+ LOC from provider
- Isolate superset complexity
- Better code organization

**Acceptance Criteria**:
- [ ] New SupersetService class created
- [ ] All superset methods moved
- [ ] Provider delegates superset operations
- [ ] Unit tests for SupersetService (4+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 1.5 hours

---

### Task 1.4: Extract WorkoutPersistenceService from workout_provider.dart

**Current Location**: `lib/features/workout/presentation/providers/workout_provider.dart` (lines 449-1088)

**What to Extract**:
- `_saveCompletedWorkoutToFirestore()` method
- `_autoSaveIfNeeded()` method
- Firebase persistence logic
- Hive cache operations

**New File**: `lib/features/workout/data/services/workout_persistence_service.dart`

**Benefits**:
- Extract 250+ LOC from provider
- Separate persistence concerns
- Easier Firebase testing

**Acceptance Criteria**:
- [ ] New WorkoutPersistenceService class created
- [ ] All persistence methods moved
- [ ] Provider uses service for save operations
- [ ] Unit tests for WorkoutPersistenceService (3+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 2.5 hours

---

### Task 1.5: Refactor unified_timer_provider.dart - Extract Audio Service

**Current Location**: `lib/features/timer/presentation/providers/unified_timer_provider.dart`

**What to Extract**:
- Audio playback logic (lines with AudioPlayer usage)
- Sound playback methods
- Audio initialization/cleanup

**New File**: `lib/features/timer/domain/services/timer_audio_service.dart`

**Benefits**:
- Extract 200+ LOC
- Platform-specific audio code isolated
- Better testability
- Reusable for other features

**Acceptance Criteria**:
- [ ] New TimerAudioService class created
- [ ] All audio methods moved
- [ ] Provider delegates audio to service
- [ ] Unit tests for TimerAudioService (4+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 2.5 hours

---

### Task 1.6: Refactor unified_timer_provider.dart - Extract Platform Service

**Current Location**: `lib/features/timer/presentation/providers/unified_timer_provider.dart` (lines 40-93)

**What to Extract**:
- iOS platform channel handler
- MethodChannel setup
- iOS-specific notifications

**New File**: `lib/features/timer/domain/services/timer_platform_service.dart`

**Benefits**:
- Extract 150+ LOC
- iOS code fully isolated
- Better platform separation

**Acceptance Criteria**:
- [ ] New TimerPlatformService class created
- [ ] Platform channel logic moved
- [ ] Provider delegates platform calls
- [ ] Unit tests for TimerPlatformService (3+ test cases)
- [ ] iOS build still works

**Estimated Effort**: 2 hours

---

### Task 1.7: Refactor home_widget_factory.dart - Extract Widget Builders

**Current Location**: `lib/features/home/presentation/widgets/home_widget_factory.dart`

**What to Extract**:
- `_buildAICoachWidget()` (300 LOC)
- `_buildQuickActionsWidget()` (150 LOC)
- `_buildRecentWorkoutsWidget()` (100 LOC)
- `_buildMotivationalQuoteWidget()` (50 LOC)

**New Files**:
- `lib/features/home/presentation/widgets/builders/ai_coach_widget_builder.dart`
- `lib/features/home/presentation/widgets/builders/quick_actions_widget_builder.dart`
- `lib/features/home/presentation/widgets/builders/recent_workouts_widget_builder.dart`
- `lib/features/home/presentation/widgets/builders/motivational_quote_widget_builder.dart`

**Benefits**:
- Extract 600+ LOC from main factory
- Each builder is independently testable
- Easier to understand individual widgets

**Acceptance Criteria**:
- [ ] 4 new builder classes created
- [ ] Factory routes to builders (simple switch)
- [ ] All build methods moved
- [ ] Widget tests for each builder (5+ total)
- [ ] `flutter analyze` passes
- [ ] Home screen still renders correctly

**Estimated Effort**: 4 hours

---

### Task 1.8: Extract AI Coach Dialog to Separate File

**Current Location**: `lib/features/home/presentation/widgets/home_widget_factory.dart` (lines 1982+)

**What to Extract**:
- `_AICoachDialog` class (200 LOC)

**New File**: `lib/features/home/presentation/widgets/ai_coach_dialog.dart`

**Benefits**:
- Reduce factory file size further
- Reusable dialog for other screens
- Easier to test dialog behavior

**Acceptance Criteria**:
- [ ] New AICoachDialog widget created
- [ ] Dialog logic moved from factory
- [ ] Factory imports and uses new dialog
- [ ] Widget tests for dialog (3+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 1.5 hours

---

## PHASE 2: HIGH IMPACT FILES (Weeks 3-4)

### Task 2.1: Extract State Providers from quick_edit_overlay_v2.dart

**Current Location**: `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart` (lines 70-98)

**What to Extract**:
- All state fields to Riverpod providers
- `_selectedWeight`, `_selectedReps`, `_selectedSeconds`
- `_supersetWeights`, `_supersetReps`, `_supersetSeconds`
- Animation controllers

**New File**: `lib/features/workout/presentation/providers/quick_edit_state_providers.dart`

**Benefits**:
- Extract 500+ LOC from widget state
- Reusable state management
- Better separation of concerns

**Acceptance Criteria**:
- [ ] Quick edit providers file created (15+ providers)
- [ ] All state fields converted to providers
- [ ] Widget reads from providers
- [ ] Unit tests for providers (10+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 3 hours

---

### Task 2.2: Extract UI Components from quick_edit_overlay_v2.dart

**Current Location**: `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart`

**What to Extract**:
- Weight picker UI (200 LOC)
- Reps picker UI (150 LOC)
- Actions bar UI (100 LOC)
- Header/title section (80 LOC)

**New Files**:
- `lib/features/workout/presentation/widgets/quick_edit/quick_edit_weight_picker.dart`
- `lib/features/workout/presentation/widgets/quick_edit/quick_edit_reps_picker.dart`
- `lib/features/workout/presentation/widgets/quick_edit/quick_edit_actions.dart`
- `lib/features/workout/presentation/widgets/quick_edit/quick_edit_header.dart`

**Benefits**:
- Extract 530+ LOC from main widget
- Each component independently testable
- Better code organization

**Acceptance Criteria**:
- [ ] 4 new widget components created
- [ ] Main widget uses component widgets
- [ ] Each component has own tests (12+ total)
- [ ] `flutter analyze` passes
- [ ] Overlay still functions correctly

**Estimated Effort**: 4 hours

---

### Task 2.3: Extract Smart Positioning Service from quick_edit_overlay_v2.dart

**Current Location**: `lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart` (lines 2118+)

**What to Extract**:
- `_SmartPositioning` class
- Collision detection logic
- Overlay positioning algorithm

**New File**: `lib/features/workout/presentation/services/overlay_positioning_service.dart`

**Benefits**:
- Extract 200+ LOC
- Reusable for other overlays
- Easier to test positioning logic

**Acceptance Criteria**:
- [ ] New OverlayPositioningService created
- [ ] Positioning logic moved from widget
- [ ] Widget delegates to service
- [ ] Unit tests for positioning (8+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 2 hours

---

### Task 2.4: Extract Analytics Computation from analytics_overview_tab.dart

**Current Location**: `lib/features/analytics/presentation/tabs/analytics_overview_tab.dart` (lines 38-72)

**What to Extract**:
- Workout filtering logic (_filteredWorkouts getter)
- Statistics computation (_computePeriodStats method)
- Chart data preparation

**New File**: `lib/features/analytics/domain/services/analytics_computation_service.dart`

**Benefits**:
- Extract 300+ LOC
- Computation logic reusable
- Better testability
- Separates business logic from UI

**Acceptance Criteria**:
- [ ] New AnalyticsComputationService created
- [ ] All computation logic moved
- [ ] Provider created for lazy computation
- [ ] Unit tests for service (10+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 2.5 hours

---

### Task 2.5: Extract Filtering Service from analytics_overview_tab.dart

**Current Location**: `lib/features/analytics/presentation/tabs/analytics_overview_tab.dart`

**What to Extract**:
- Time period filtering logic
- Workout filtering by date range
- Period selection state

**New File**: `lib/features/analytics/domain/services/analytics_filter_service.dart`

**Benefits**:
- Extract 150+ LOC
- Reusable filter logic
- Better code organization

**Acceptance Criteria**:
- [ ] New AnalyticsFilterService created
- [ ] Filter logic moved from widget
- [ ] Provider for filter state created
- [ ] Unit tests for service (8+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 1.5 hours

---

### Task 2.6: Extract Modals from analytics_overview_tab.dart

**Current Location**: `lib/features/analytics/presentation/tabs/analytics_overview_tab.dart` (lines 1230+)

**What to Extract**:
- `_AllActivitiesModal` (200 LOC)
- `_AllActivitiesModalState` (400 LOC)
- Weekly goal dialog

**New Files**:
- `lib/features/analytics/presentation/widgets/all_activities_modal.dart`
- `lib/features/analytics/presentation/widgets/weekly_goal_dialog.dart`

**Benefits**:
- Extract 600+ LOC from main tab
- Reusable modals for other screens
- Easier to test modal logic

**Acceptance Criteria**:
- [ ] 2 new modal files created
- [ ] Modal logic moved from tab
- [ ] Tab imports and uses new modals
- [ ] Modal tests (8+ test cases)
- [ ] `flutter analyze` passes

**Estimated Effort**: 3 hours

---

## VERIFICATION CHECKLIST

After each task completion:

- [ ] File size reduced (target LOC met)
- [ ] `flutter analyze` passes (0 errors)
- [ ] `flutter pub get` succeeds
- [ ] All imports correct (no circular dependencies)
- [ ] Localization still works (context.l10n usage)
- [ ] Theme still works (context.colors usage)
- [ ] Platform code unchanged (iOS/Android build)
- [ ] Tests pass locally
- [ ] No new warnings introduced

## Summary of Effort

| Phase | Files | Tasks | Hours | Week |
|-------|-------|-------|-------|------|
| 1 | 3 | 8 | 18 hours | Week 1-2 |
| 2 | 2 | 6 | 18 hours | Week 3-4 |
| 3 | 5 | TBD | 20 hours | Week 5-6 |
| **Total** | **10** | **14+** | **56+ hours** | **6 weeks** |

## Recommended Implementation Order

1. Start with **workout_provider.dart** (highest impact, blocks other work)
2. Then **unified_timer_provider.dart** (critical for timer functionality)
3. Then **home_widget_factory.dart** (visual/interactive features)
4. Then **quick_edit_overlay_v2.dart** (UX improvements)
5. Finally **analytics_overview_tab.dart** (less blocking)

## Success Metrics

After Phase 1-2 completion:
- workspace_provider: 2,047 → 1,200 LOC (41% ↓)
- unified_timer_provider: 1,991 → 1,100 LOC (45% ↓)
- home_widget_factory: 2,409 → 960 LOC (60% ↓)
- quick_edit_overlay_v2: 2,216 → 775 LOC (65% ↓)
- analytics_overview_tab: 2,057 → 1,030 LOC (50% ↓)

**Total: 10,720 → 5,065 LOC (53% reduction)**
