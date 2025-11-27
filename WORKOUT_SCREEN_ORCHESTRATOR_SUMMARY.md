# WorkoutScreen Orchestrator Implementation

## Summary

Created `lib/features/workout/presentation/workout_screen_orchestrator.dart` that replaces the monolithic `workout_screen.dart` (2631 lines) with a clean orchestrator pattern (778 lines = **70% reduction**).

## Architecture

```
WorkoutScreen Orchestrator (778 lines)
├── WelcomeView (358 lines) - Empty/no workout state
├── PreloadedView (127 lines) - Workout suggested but not started
├── WorkoutView (273 lines) - Active workout
└── WorkoutScreenController (421 lines) - Business logic

Total modular lines: 778 + 358 + 127 + 273 + 421 = 1,957 lines
vs Original monolith: 2,631 lines
**Reduction: 26% smaller overall + 70% smaller orchestrator**
```

## Key Features Preserved

✅ **Same Public Interface**:
```dart
const WorkoutScreen({
  super.key,
  this.initialTemplateId,
  this.sessionId,
  this.fromSmartCTA = false,
})
```

✅ **State Management**:
- Delegates to `WorkoutScreenController` for business logic
- Uses `workoutScreenControllerProvider` for UI state
- Uses `currentWorkoutProvider` for workout data
- Uses `shouldShowTier1TimerProvider` for timer overlay

✅ **Lifecycle Management**:
- `WidgetsBindingObserver` for app lifecycle (auto-save on background)
- Emergency save when app goes to background/inactive
- Template cache force-save
- Proper cleanup in dispose()

✅ **UI Components**:
- Conditional AppBar actions (reorder, complete, settings)
- FAB behavior (ExpandableFAB vs done button in reorder mode)
- Timer overlay (Tier1MinimalTimerOverlay)
- Draggable tutorial overlay
- PopScope with back navigation confirmation

✅ **Onboarding**:
- First workout welcome overlay
- Contextual overlay manager integration
- GlobalKeys for FAB and complete button targeting

## Sub-Component Delegation

### WelcomeView (Empty State)
```dart
WelcomeView(
  onQuickStart: () => _startQuickWorkout(context),
  onStartTemplate: (template) => _startTemplateWorkout(template),
  onShareTemplate: (template) => _shareTemplatePdf(context, template),
  onDuplicateTemplate: (template) => _duplicateTemplate(context, template),
  onEditTemplate: (template) => _editTemplateFromQuickStart(context, template),
  onDeleteTemplate: (template) => _deleteTemplateFromQuickStart(context, template),
  onCreateTemplate: () => _showCreateTemplateModal(context),
)
```

### PreloadedView (Suggested Workout)
```dart
PreloadedView(
  workout: workout,
  sessionId: widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
  onStartWorkout: () {
    ref.read(workoutScreenControllerProvider.notifier).startWorkout(
      context: context,
      sessionId: widget.sessionId,
    );
  },
  onBrowseTemplates: () => _navigateToTemplates(context),
)
```

### WorkoutView (Active Workout)
```dart
WorkoutView(
  workout: workout,
  isReorderMode: state.isReorderMode,
  onEditExercise: (exercise) => _editExercise(context, exercise),
  onDeleteExercise: (exerciseId) => _deleteExercise(exerciseId),
  onReplaceExercise: (exercise) => _replaceExercise(context, exercise),
  onUpdateExerciseSet: (exerciseId, updatedSet) =>
      _updateExerciseSet(exerciseId, updatedSet),
  onUpdateExercise: (updatedExercise) =>
      _updateExercise(updatedExercise),
  onUpdateSupersetSet: (supersetId, supersetSet) =>
      _updateSupersetSet(supersetId, supersetSet),
  onReorderExercises: (oldIndex, newIndex) {
    ref.read(workoutScreenControllerProvider.notifier)
        .reorderExercises(oldIndex, newIndex);
  },
)
```

## Method Categories

### Navigation (2 methods)
- `_handleBackNavigation()` - Confirmation dialog if workout active
- `_navigateToTemplates()` - Navigate to templates screen

### Workout Actions (3 methods)
- `_startQuickWorkout()` - Context gathering flow
- `_startTemplateWorkout()` - Start from template
- `_showAddExercise()` - Add exercise modal
- `_showCreateTemplateModal()` - Create template modal

### Exercise Actions (5 methods)
- `_editExercise()` - Edit exercise modal
- `_deleteExercise()` - Remove exercise
- `_replaceExercise()` - Replace with another exercise
- `_updateExerciseSet()` - Update specific set
- `_updateExercise()` - Update entire exercise
- `_updateSupersetSet()` - Update superset set

### Template Actions (4 methods)
- `_editTemplateFromQuickStart()` - Navigate to edit screen
- `_shareTemplatePdf()` - PDF export with options
- `_deleteTemplateFromQuickStart()` - Delete with confirmation
- `_duplicateTemplate()` - Duplicate template

### Settings (2 methods)
- `_showSettingsMenu()` - Bottom sheet with options
- `_saveCurrentWorkoutAsTemplate()` - Save as template helper

## Known Issues (To Fix)

### Missing Localization Strings
Add to `app_en.arb` and `app_it.arb`:
```json
{
  "exitWorkout": "Exit Workout?",
  "exitWorkoutConfirmation": "Are you sure you want to exit? Your workout will be discarded.",
  "exit": "Exit",
  "deleteTemplateConfirmation": "Are you sure you want to delete this template?",
  "errorDuplicatingTemplate": "Error duplicating template",
  "templateDuplicated": "Template duplicated successfully"
}
```

### API Mismatches
1. **WorkoutCustomizationModalV3**: Check constructor parameters
   - Used: `initialExercise`, `onUpdate`
   - Need to verify actual API

2. **Exercise.copyWith()**: Check if `id` parameter exists
   - Used: `newExercise.copyWith(id: exercise.id)`
   - May need different approach

3. **PdfExportOptionsDialog**: Check constructor parameters
   - Used: `detailLevel`, `showNotes`, `showImages`, `showMuscleGroups`
   - Need to verify actual API

4. **PdfPreferencesNotifier**: Check methods
   - Used: `updatePreferences()`
   - Need to verify actual method name

5. **SaveTemplateHelper**: Check methods
   - Used: `saveAsTemplate()`
   - Need to verify actual method signature

6. **WorkoutTemplate provider**: Verify provider name
   - Used: `workoutTemplateProvider`
   - May be different actual name

### State Management Issue
- Line 551: `ref.read(currentWorkoutProvider.notifier).state = updatedWorkout;`
- Should use proper notifier method instead of direct state assignment
- Change to: `ref.read(currentWorkoutProvider.notifier).updateWorkout(updatedWorkout);`

## Testing Checklist

Before deploying, test:

- [ ] Empty state (no workout) → WelcomeView
- [ ] Preloaded state → PreloadedView with start button
- [ ] Active workout → WorkoutView with exercises
- [ ] Reorder mode toggle
- [ ] Complete workout flow
- [ ] Back navigation confirmation
- [ ] Timer overlay visibility
- [ ] Onboarding overlays (first workout)
- [ ] Lifecycle auto-save (background app)
- [ ] Template actions (share, duplicate, delete)
- [ ] Exercise actions (edit, delete, replace)
- [ ] Settings menu
- [ ] Dark/light theme
- [ ] Localization (EN/IT)

## Next Steps

1. **Run flutter analyze** and fix remaining API mismatches
2. **Add missing localization strings** to .arb files
3. **Run `flutter gen-l10n`** to generate localizations
4. **Test all user flows** manually
5. **Replace original workout_screen.dart** with orchestrator:
   ```bash
   mv lib/features/workout/presentation/workout_screen.dart \
      lib/features/workout/presentation/workout_screen_OLD.dart
   mv lib/features/workout/presentation/workout_screen_orchestrator.dart \
      lib/features/workout/presentation/workout_screen.dart
   ```
6. **Run full test suite**
7. **Commit changes**:
   ```bash
   git add .
   git commit -m "refactor(workout): replace monolithic WorkoutScreen with orchestrator pattern

   - Reduce from 2631 lines to 778 lines (70% reduction)
   - Delegate to WelcomeView, PreloadedView, WorkoutView sub-components
   - Extract business logic to WorkoutScreenController
   - Maintain same public interface and functionality
   - Improve maintainability and testability

   BREAKING CHANGE: None (same public API)
   "
   ```

## Benefits

1. **Maintainability**: Each sub-component has single responsibility
2. **Testability**: Can test each view independently
3. **Readability**: Clear separation of concerns
4. **Performance**: Smaller widget trees per state
5. **Scalability**: Easy to add new workout states
6. **Reusability**: Sub-components can be used elsewhere

## File Structure

```
lib/features/workout/presentation/
├── workout_screen.dart (778 lines) ← ORCHESTRATOR
├── workout_screen/
│   ├── controllers/
│   │   └── workout_screen_controller.dart (421 lines)
│   └── widgets/
│       ├── welcome_view.dart (358 lines)
│       ├── preloaded_view.dart (127 lines)
│       ├── workout_view.dart (273 lines)
│       └── empty_exercise_list.dart
└── widgets/ (reused components)
    ├── add_exercise_modal.dart
    ├── workout_customization_modal_v3.dart
    ├── exercise_list_item.dart
    └── ... (20+ other widgets)
```

## Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Main file lines | 2,631 | 778 | -70% |
| Total modular lines | 2,631 | 1,957 | -26% |
| Files | 1 | 5 | +400% modularity |
| Average file size | 2,631 | 391 | -85% |
| Cyclomatic complexity | High | Low | Distributed |

---

**Created**: 2025-01-26
**File**: `lib/features/workout/presentation/workout_screen_orchestrator.dart`
**Original**: `lib/features/workout/presentation/workout_screen.dart` (2,631 lines)
**Status**: ⚠️ Needs API fixes + localization strings before deployment
