# ExerciseListItem Controller Architecture

## Overview

This directory contains the controller layer for the ExerciseListItem widget refactoring. The goal is to extract business logic and set operations from the monolithic 5593-line `exercise_list_item.dart` widget into smaller, testable, reusable components.

## Design Pattern

**StateNotifier + Riverpod**

- **Presentation-agnostic**: Controller has no BuildContext dependencies (except for callbacks)
- **Pure business logic**: All set operations are encapsulated in the controller
- **Immutable state updates**: Uses Riverpod's StateNotifier for predictable state management
- **Callback-based UI feedback**: Controller doesn't know about SnackBarService or localization - delegates to caller

## Files

### `exercise_list_item_controller.dart`

Main controller for set operations with the following methods:

#### Set Operations
- `addSet()` - Add new set with smart defaults from last set
- `deleteSet()` - Delete set with undo support
- `toggleSetCompletion()` - Toggle set completion status
- `updateSet()` - Update set data (weight/reps/etc.)
- `duplicateSet()` - Clone existing set

#### APRE/RPE Autoregulation
- `handleAPRESuggestion()` - Apply APRE protocol weight adjustment
- `handleRPESuggestion()` - Apply RPE-based weight adjustment

#### Utility Methods
- `getCompletedSetsCount()` - Count completed sets
- `getLastWorkingSet()` - Get last non-warmup set
- `isExerciseCompleted()` - Check if all sets complete
- `getTotalVolume()` - Calculate total exercise volume

### `controllers.dart`

Barrel export file for all controllers in this directory.

## Usage Example

### Basic Setup

```dart
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/controllers/controllers.dart';

class ExerciseListItem extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(exerciseListItemControllerProvider.notifier);

    // Use controller methods with callbacks
  }
}
```

### Add Set

```dart
void _onAddSet() {
  controller.addSet(
    exercise: currentExercise,
    onUpdate: (updatedExercise) {
      // Update parent state (e.g., workout provider)
      ref.read(currentWorkoutProvider.notifier).updateExercise(updatedExercise);
    },
    onFeedback: (message) {
      // Show localized feedback
      SnackBarService.showInfo(
        context,
        context.l10n.exerciseListSetAdded(updatedExercise.sets.length.toString()),
      );
    },
  );
}
```

### Delete Set with Undo

```dart
void _onDeleteSet(int index) {
  controller.deleteSet(
    exercise: currentExercise,
    setIndex: index,
    onUpdate: (updatedExercise) {
      ref.read(currentWorkoutProvider.notifier).updateExercise(updatedExercise);
    },
    onFeedbackWithAction: (message, actionLabel, onAction) {
      // Show feedback with undo action
      SnackBarService.showCustom(
        context,
        message: message,
        actionLabel: context.l10n.undo,
        onAction: onAction,
      );
    },
  );
}
```

### Toggle Set Completion

```dart
void _onToggleSet(ExerciseSet set) {
  controller.toggleSetCompletion(
    exercise: currentExercise,
    set: set,
    onUpdate: (updatedExercise) {
      ref.read(currentWorkoutProvider.notifier).updateExercise(updatedExercise);
    },
  );
}
```

### Handle APRE Suggestion

```dart
void _onAPRESuggestion(ExerciseSet currentSet, double suggestedWeight) {
  controller.handleAPRESuggestion(
    exercise: currentExercise,
    currentSet: currentSet,
    suggestedWeight: suggestedWeight,
    onUpdate: (updatedExercise) {
      ref.read(currentWorkoutProvider.notifier).updateExercise(updatedExercise);
    },
    onFeedback: (message) {
      SnackBarService.showInfo(context, message);
    },
  );
}
```

## Callback Types

The controller uses strongly-typed callbacks for flexibility:

```dart
/// Update exercise in parent state (e.g., workout provider)
typedef OnExerciseUpdate = void Function(Exercise updatedExercise);

/// Show simple feedback message (e.g., snackbar)
typedef OnFeedback = void Function(String message);

/// Show feedback with action (e.g., snackbar with undo button)
typedef OnFeedbackWithAction = void Function(
  String message,
  String actionLabel,
  VoidCallback onAction,
);
```

## Benefits of This Architecture

### Separation of Concerns
- **Controller**: Pure business logic (add/delete/update sets)
- **Widget**: UI rendering and user interactions
- **Callbacks**: Bridge between controller and widget (localization, snackbars, state updates)

### Testability
- Controller can be unit tested without widget/BuildContext
- Mock callbacks for testing feedback behavior
- Test set operations in isolation

### Reusability
- Controller can be used by multiple widgets
- Same logic for set operations across different UIs
- Easy to extend with new operations

### Maintainability
- Single source of truth for set operations
- Easy to debug (clear data flow)
- Small, focused files instead of 5593-line monolith

## Haptic Feedback Strategy

The controller includes intelligent haptic feedback:

| Operation | Haptic | Reason |
|-----------|--------|--------|
| `addSet()` | Light | Quick confirmation |
| `deleteSet()` | Medium | Destructive action |
| `toggleSetCompletion()` | Light | Frequent action |
| `updateSet()` | None | Called during typing |
| `duplicateSet()` | Light | Quick confirmation |
| `handleAPRESuggestion()` | None | Automated adjustment |
| `handleRPESuggestion()` | None | Automated adjustment |

## Next Steps

### Phase 2: Extract UI Components
- `ExerciseListItemHeader` - Exercise name, options menu
- `ExerciseListItemSetRow` - Individual set row
- `ExerciseListItemFooter` - Add set button, stats

### Phase 3: Extract Business Logic Services
- `SetDefaultsService` - Smart defaults for new sets
- `SetNumberingService` - Auto-renumbering logic
- `APRECalculationService` - APRE protocol logic
- `RPECalculationService` - RPE autoregulation logic

### Phase 4: Testing
- Unit tests for controller methods
- Widget tests for UI components
- Integration tests for full workflow

## Related Documentation

- **Exercise Entity**: `lib/features/workout/domain/entities/exercise.dart`
- **SnackBarService**: `lib/shared/presentation/services/snackbar_service.dart`
- **Workout Provider**: `lib/features/workout/presentation/providers/workout_provider.dart`
- **APRE Documentation**: `docs/features/APRE_INDEX.md`

## Architecture Compliance

This controller follows all GymBro project rules:

- ✅ **REGOLA #3**: Riverpod StateNotifier pattern
- ✅ **REGOLA #1**: No hardcoded strings (callbacks pass raw strings, caller localizes)
- ✅ **REGOLA #2**: No hardcoded colors (controller has no UI)
- ✅ **REGOLA #11**: Unified components (uses HapticFeedback from Flutter services)
- ✅ **REGOLA #15**: Single Source of Truth (one controller for all set operations)

---

**Refactoring Progress**: 1/4 phases complete (Controller extraction done ✅)
**Next**: Extract UI components (Header, SetRow, Footer)
