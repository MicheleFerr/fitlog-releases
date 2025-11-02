import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_sequential_execution_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/restpause_execution_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/dropset_execution_sheet.dart';

/// ✅ CONSULTANT RECOMMENDATION: Factory pattern for execution sheets
///
/// This pattern allows switching between old and new implementations
/// without scattered if/else statements throughout the codebase.
/// When the feature flag is disabled, simply remove UnifiedExecutionSheetFactory.
abstract class ExecutionSheetFactory {
  /// Build execution sheet for any advanced exercise type
  Widget buildExecutionSheet({
    required BuildContext context,
    required Exercise exercise,
    required int stageIndex,
    required Function(dynamic) onStageCompleted,
    VoidCallback? onAllStagesCompleted,
  });
}

/// New implementation with sealed classes (Phase 4)
///
/// For now this is a placeholder that throws UnsupportedError.
/// Will be implemented in Phase 4 with AdvancedExerciseExecutionSheet.
class UnifiedExecutionSheetFactory implements ExecutionSheetFactory {
  @override
  Widget buildExecutionSheet({
    required BuildContext context,
    required Exercise exercise,
    required int stageIndex,
    required Function(dynamic) onStageCompleted,
    VoidCallback? onAllStagesCompleted,
  }) {
    // TODO(Phase 4): Implement AdvancedExerciseExecutionSheet
    throw UnsupportedError(
      'UnifiedExecutionSheetFactory not yet implemented. '
      'Set FeatureFlags.useUnifiedExecutionSheets = false to use legacy implementation.',
    );

    /* Phase 4 implementation will be:
    return AdvancedExerciseExecutionSheet(
      exercise: exercise as AdvancedExercise,
      stageIndex: stageIndex,
      onStageCompleted: onStageCompleted,
      onAllStagesCompleted: onAllStagesCompleted,
    );
    */
  }
}

/// Legacy implementation (current code)
///
/// Uses existing execution sheet widgets based on exercise type.
/// This factory wraps the current implementation for clean separation.
class LegacyExecutionSheetFactory implements ExecutionSheetFactory {
  @override
  Widget buildExecutionSheet({
    required BuildContext context,
    required Exercise exercise,
    required int stageIndex,
    required Function(dynamic) onStageCompleted,
    VoidCallback? onAllStagesCompleted,
  }) {
    if (exercise is SupersetExercise) {
      return SupersetSequentialExecutionSheet(
        superset: exercise,
        roundIndex: stageIndex,
        onRoundCompleted: (completedRound) => onStageCompleted(completedRound),
        onAllRoundsCompleted: onAllStagesCompleted,
      );
    } else if (exercise is DropSetExercise) {
      return DropSetExecutionSheet(
        dropset: exercise,
        setIndex: stageIndex,
        onComplete: (weights, actualReps, rpes) => onStageCompleted({
          'weights': weights,
          'actualReps': actualReps,
          'rpes': rpes,
        }),
      );
    } else if (exercise is RestPauseExercise) {
      return RestPauseExecutionSheet(
        restPause: exercise,
        setIndex: stageIndex,
        onComplete: (weight, reps, rpe) => onStageCompleted({
          'weight': weight,
          'reps': reps,
          'rpe': rpe,
        }),
      );
    }

    throw UnsupportedError('Unknown exercise type: ${exercise.runtimeType}');
  }
}

/// Feature flag configuration
///
/// Controls which execution sheet implementation to use.
/// Default: false (use legacy implementation)
class FeatureFlags {
  static bool _useUnifiedExecutionSheets = false;

  /// Whether to use the new unified execution sheets (sealed classes)
  static bool get useUnifiedExecutionSheets => _useUnifiedExecutionSheets;

  /// Get the appropriate execution sheet factory based on feature flag
  static ExecutionSheetFactory get executionSheetFactory {
    return _useUnifiedExecutionSheets
        ? UnifiedExecutionSheetFactory()
        : LegacyExecutionSheetFactory();
  }

  /// Enable or disable unified execution sheets
  ///
  /// For development/beta testing:
  /// ```dart
  /// if (kDebugMode) {
  ///   FeatureFlags.setUnifiedExecutionSheets(true);
  /// }
  /// ```
  ///
  /// For gradual rollout:
  /// ```dart
  /// final userId = auth.currentUser?.uid;
  /// final enableForUser = await remoteConfig.getBool('unified_sheets_$userId');
  /// FeatureFlags.setUnifiedExecutionSheets(enableForUser);
  /// ```
  static void setUnifiedExecutionSheets(bool enabled) {
    _useUnifiedExecutionSheets = enabled;
  }
}
