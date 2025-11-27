/// ExerciseListItem v2 - Refactored Version
///
/// This is the new modular version of ExerciseListItem that uses composition
/// with smaller, focused widgets. Part of the refactoring effort to reduce
/// the original 5593-line file.
///
/// ## Components
///
/// ### Main Widgets (Full Implementation)
/// - [ExerciseListItemHeader]: Full header with all badges, GIF, options (~837 lines)
/// - [ExerciseListItemSets]: Full sets section with all set types (~1110 lines)
/// - [ExerciseListItemActions]: Action handlers and modals (~285 lines)
///
/// ### Compact Widgets (Simplified)
/// - [ExerciseHeader]: Compact header widget (~310 lines)
/// - [ExerciseSetsSection]: Simplified sets section (~842 lines)
///
/// ### Controllers
/// - [ExerciseListItemController]: All set operations via StateNotifier (~414 lines)
///
/// ### Utils
/// - [ExerciseNotesHandler]: Notes dialog and formatting (~131 lines)
/// - [SetDisplayUtils]: Set display formatting based on counting mode (~273 lines)
///
/// ## Migration Status: GRADUAL
///
/// **Current State**: Sub-components extracted but NOT YET integrated into main widget.
///
/// **Original file** (`exercise_list_item.dart` - 5593 lines): Still in use, works correctly.
/// **New components** (this file): Available for new code or gradual refactoring.
///
/// **Integration Path** (future work):
/// 1. Create orchestrator that composes sub-components
/// 2. Match same public interface as original
/// 3. Replace original import with orchestrator
/// 4. Delete original file
///
/// For now, continue using original `exercise_list_item.dart` for ExerciseListItem widget.
/// Use these sub-components when building NEW features or refactoring existing code.
///
/// ## Usage
/// ```dart
/// import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_v2.dart';
///
/// // Access full widgets
/// ExerciseListItemHeader(...)
/// ExerciseListItemSets(...)
///
/// // Or compact widgets
/// ExerciseHeader(...)
/// ExerciseSetsSection(...)
///
/// // Access controller
/// final controller = ref.watch(exerciseListItemControllerProvider.notifier);
/// ```
library;

// Full Implementation Widgets (from root)
export 'exercise_list_item_header.dart';
export 'exercise_list_item_sets.dart';
export 'exercise_list_item_actions.dart';

// Compact Widgets (from widgets/)
export 'widgets/exercise_header.dart';
export 'widgets/exercise_sets_section.dart';

// Controllers
export 'controllers/controllers.dart';

// Utils
export 'utils/exercise_notes_handler.dart';
export 'utils/set_display_utils.dart';
