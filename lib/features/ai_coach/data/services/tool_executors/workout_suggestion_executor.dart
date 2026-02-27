/// Workout suggestion tool executor for AI Coach
///
/// Handles: suggestWorkout, compareToStandards
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart'
    as h;
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/analytics_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/recovery_stats_executor.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:flutter/widgets.dart' show Locale;

class WorkoutSuggestionExecutor {
  const WorkoutSuggestionExecutor({
    required this.analyticsExecutor,
    required this.recoveryExecutor,
    required this.exerciseSearchService,
    this.locale,
  });

  final AnalyticsToolExecutor analyticsExecutor;
  final RecoveryStatsExecutor recoveryExecutor;
  final ExerciseSearchService exerciseSearchService;
  final Locale? locale;

  // ------------------------------------------------------------------
  // suggestWorkout
  // ------------------------------------------------------------------

  Future<String> suggestWorkout(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final targetMuscleRaw = args['muscleGroup'] as String?;
      final targetMuscleCanonical = targetMuscleRaw != null
          ? h.canonicalMuscleGroup(targetMuscleRaw)
          : null;
      final targetMuscle =
          (targetMuscleCanonical == null || targetMuscleCanonical == 'other')
              ? null
              : targetMuscleCanonical;
      final difficulty = args['difficulty'] as String?;

      final balanceJson =
          await analyticsExecutor.analyzeMuscleBalance({}, userId);
      final balanceData = jsonDecode(balanceJson) as Map<String, dynamic>;

      final recoveryJson =
          await recoveryExecutor.getRecoveryData({}, userId);
      final recoveryData = jsonDecode(recoveryJson) as Map<String, dynamic>;

      final underTrainedRaw = balanceData['underTrained'] as String?;
      final underTrainedCanonical = underTrainedRaw != null
          ? h.canonicalMuscleGroup(underTrainedRaw)
          : null;
      final underTrained =
          (underTrainedCanonical == null || underTrainedCanonical == 'other')
              ? null
              : underTrainedCanonical;
      final recoveryStatus =
          recoveryData['recoveryStatus'] as String? ?? 'green';
      final daysSinceLastWorkout =
          recoveryData['daysSinceLastWorkout'] as int? ?? -1;

      String suggestedFocusCanonical;
      String intensity;

      if (recoveryStatus == 'red') {
        suggestedFocusCanonical = 'recovery';
        intensity = 'molto leggera';
      } else if (recoveryStatus == 'amber') {
        suggestedFocusCanonical = targetMuscle ?? underTrained ?? 'full_body';
        intensity = difficulty ?? 'moderata';
      } else {
        suggestedFocusCanonical = targetMuscle ?? underTrained ?? 'full_body';
        intensity = difficulty ??
            (daysSinceLastWorkout >= 3 ? 'alta' : 'moderata-alta');
      }

      final suggestedSession = await h.buildSuggestedSession(
        focusCanonical: suggestedFocusCanonical,
        intensity: intensity,
        recoveryStatus: recoveryStatus,
        exerciseSearchService: exerciseSearchService,
        locale: locale,
      );

      return jsonEncode({
        'suggestedMuscleGroup': h.muscleGroupLabel(suggestedFocusCanonical),
        'suggestedMuscleGroupCanonical': suggestedFocusCanonical,
        'intensity': intensity,
        'recoveryStatus': recoveryStatus,
        'underTrainedMuscle':
            underTrained != null ? h.muscleGroupLabel(underTrained) : null,
        'underTrainedMuscleCanonical': underTrained,
        'daysSinceLastWorkout': daysSinceLastWorkout,
        'requestedMuscleGroup': targetMuscleRaw,
        'requestedMuscleGroupCanonical': targetMuscle,
        'requestedDifficulty': difficulty,
        'balance': balanceData['balanceLocalized'] ?? balanceData['balance'],
        'balanceCanonical': balanceData['balance'],
        'suggestedSession': suggestedSession,
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: suggestWorkout',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'suggestWorkout',
      });
    }
  }

  // ------------------------------------------------------------------
  // compareToStandards
  // ------------------------------------------------------------------

  Future<String> compareToStandards(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final lift = args['lift'] as String?;

    final weightRaw = args['weight'];
    final weight = weightRaw is num
        ? weightRaw.toDouble()
        : double.tryParse(weightRaw?.toString() ?? '0') ?? 0;

    final bodyWeightRaw = args['bodyWeight'];
    final bodyWeight = bodyWeightRaw is num
        ? bodyWeightRaw.toDouble()
        : double.tryParse(bodyWeightRaw?.toString() ?? '75') ?? 75;

    try {
      if (bodyWeight <= 0) {
        return jsonEncode({
          'error': 'bodyWeight must be > 0',
          'toolName': 'compareToStandards',
        });
      }

      final ratio = weight / bodyWeight;
      String level;

      if (ratio < 0.5) {
        level = 'Non allenato';
      } else if (ratio < 1.0) {
        level = 'Principiante';
      } else if (ratio < 1.5) {
        level = 'Novizio';
      } else if (ratio < 2.0) {
        level = 'Intermedio';
      } else if (ratio < 2.5) {
        level = 'Avanzato';
      } else {
        level = 'Elite';
      }

      return jsonEncode({
        'lift': lift ?? 'unknown',
        'weight': weight,
        'bodyWeight': bodyWeight,
        'ratio': ratio.toStringAsFixed(2),
        'level': level,
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: compareToStandards',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'compareToStandards',
      });
    }
  }
}
