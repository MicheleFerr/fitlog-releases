/// Template Suggestion Providers
///
/// Riverpod providers for template stress analysis and recommendations.
/// Analyzes all user templates against current muscle recovery to suggest
/// which workout to do today.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/template_stress_analysis.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/calibration_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/template_stress_analyzer.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

// ============================================================================
// PERSONAL CALIBRATION PROVIDER
// ============================================================================

/// Provider for personal calibration factors
///
/// Calculates calibration from:
/// - User fitness questionnaire (age, sex, experience, injuries)
/// - HealthKit data (sleep, HRV) - when available
/// - Historical workout data - for baselines
final personalCalibrationProvider =
    FutureProvider.autoDispose<PersonalCalibration>((ref) async {
  // Get current user ID
  final userAsync = ref.watch(firebaseUserProvider);
  final userId = userAsync.valueOrNull?.uid ?? 'anonymous';

  // Get user questionnaire if available
  final questionnaire = ref.watch(userFitnessQuestionnaireProvider);

  // TODO: Get HealthKit data when available
  // For now, use empty snapshot
  const healthData = HealthDataSnapshot.empty;

  // TODO: Get historical HRV and sleep data for baselines
  // This would come from HealthKit over time
  const List<double>? historicalHrv = null;
  const List<double>? historicalSleep = null;

  // Calculate calibration
  final calibration = CalibrationService.calculateCalibration(
    userId: userId,
    questionnaire: questionnaire,
    healthData: healthData,
    historicalHrv: historicalHrv,
    historicalSleep: historicalSleep,
  );

  if (kDebugMode) {
    debugPrint('[PersonalCalibration] Calculated for $userId:');
    debugPrint('  - ageFactor: ${calibration.ageFactor}');
    debugPrint('  - trainingAgeFactor: ${calibration.trainingAgeFactor}');
    debugPrint('  - confidence: ${calibration.confidenceLevel}');
    debugPrint('  - τ₁: ${calibration.personalTau1Hours}h');
    debugPrint('  - τ₂: ${calibration.personalTau2Hours}h');
  }

  return calibration;
});

// ============================================================================
// EXERCISE DEFINITION MAP PROVIDER
// ============================================================================

/// Provider for exercise definition map (id -> ExerciseDefinition)
///
/// Used by template stress analyzer to look up muscles for each exercise.
final exerciseDefinitionMapProvider =
    FutureProvider.autoDispose<Map<String, ExerciseDefinition>>((ref) async {
  try {
    final repository = ref.watch(hybridExerciseRepositoryProvider);
    final exercises = await repository.getAllExercises();

    final exerciseMap = <String, ExerciseDefinition>{};
    for (final exercise in exercises) {
      exerciseMap[exercise.id] = exercise;
      // Also map by name for templates that use name as ID
      exerciseMap[exercise.nome] = exercise;
    }

    return exerciseMap;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[ExerciseDefinitionMap] Failed to load: $e');
    }
    return {};
  }
});

// ============================================================================
// MUSCLE RECOVERY HISTORY PROVIDER
// ============================================================================

/// Provider for muscle recovery history
///
/// Builds a map of muscle ID -> last workout info from stress index history.
final muscleRecoveryHistoryProvider =
    FutureProvider.autoDispose<Map<String, MuscleRecoveryHistory>>((ref) async {
  final stressState = ref.watch(stressIndexNotifierProvider);
  final history = stressState.valueOrNull?.history ?? [];

  final muscleHistory = <String, MuscleRecoveryHistory>{};

  // Process history from newest to oldest
  for (final result in history) {
    for (final entry in result.muscleBreakdown.entries) {
      final muscleId = entry.key;

      // Only keep the most recent entry for each muscle
      if (!muscleHistory.containsKey(muscleId)) {
        muscleHistory[muscleId] = MuscleRecoveryHistory(
          muscleId: muscleId,
          displayName: entry.value.displayName,
          lastWorkedAt: result.calculatedAt,
          lastStressScore: entry.value.stressScore,
        );
      }
    }
  }

  return muscleHistory;
});

// ============================================================================
// TEMPLATE STRESS ANALYSIS PROVIDER
// ============================================================================

/// Provider for template stress analysis
///
/// Analyzes all user templates and returns ranked recommendations.
/// Returns null if no templates or insufficient data.
final templateSuggestionProvider =
    FutureProvider.autoDispose<List<TemplateStressAnalysis>?>((ref) async {
  try {
    // Get user templates from the template provider
    final templateState = ref.watch(templateProvider);
    final templates = templateState.userTemplates;

    if (templates.isEmpty) {
      if (kDebugMode) {
        debugPrint('[TemplateSuggestion] No templates found');
      }
      return null;
    }

    // Get exercise definition map
    final exerciseMap = await ref.watch(exerciseDefinitionMapProvider.future);

    // Get muscle recovery history
    final muscleHistory =
        await ref.watch(muscleRecoveryHistoryProvider.future);

    // Get personal calibration
    final calibration = await ref.watch(personalCalibrationProvider.future);

    // Get current stress level
    final stressState = ref.watch(stressIndexNotifierProvider);
    final currentStress =
        stressState.valueOrNull?.latestResult?.displayScore ?? 0;

    // TODO: Get HealthKit data for today
    const healthData = HealthDataSnapshot.empty;

    // Analyze all templates
    final analyses = TemplateStressAnalyzer.analyzeAllTemplates(
      templates: templates,
      exerciseDatabase: exerciseMap,
      muscleHistory: muscleHistory,
      calibration: calibration,
      healthData: healthData,
      currentStress: currentStress,
    );

    if (kDebugMode) {
      debugPrint('[TemplateSuggestion] Analyzed ${analyses.length} templates:');
      for (final analysis in analyses.take(3)) {
        debugPrint(
          '  - ${analysis.templateName}: '
          '${analysis.recommendation.name} '
          '(score: ${analysis.optimalityScore.toStringAsFixed(0)})',
        );
      }
    }

    return analyses;
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[TemplateSuggestion] Failed: $e\n$st');
    }
    return null;
  }
});

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider for the best template recommendation
///
/// Returns the template with the highest optimality score, or null if none.
final bestTemplateProvider =
    Provider.autoDispose<TemplateStressAnalysis?>((ref) {
  final analyses = ref.watch(templateSuggestionProvider).valueOrNull;

  if (analyses == null || analyses.isEmpty) return null;

  // Return the first one (already sorted by optimality score)
  return analyses.first;
});

/// Provider for optimal templates (those marked as optimal)
final optimalTemplatesProvider =
    Provider.autoDispose<List<TemplateStressAnalysis>>((ref) {
  final analyses = ref.watch(templateSuggestionProvider).valueOrNull ?? [];

  return analyses
      .where((a) => a.recommendation == TemplateRecommendation.optimal)
      .toList();
});

/// Provider for templates to avoid
final templatesToAvoidProvider =
    Provider.autoDispose<List<TemplateStressAnalysis>>((ref) {
  final analyses = ref.watch(templateSuggestionProvider).valueOrNull ?? [];

  return analyses
      .where((a) => a.recommendation == TemplateRecommendation.avoid)
      .toList();
});

/// Provider for checking if template suggestion data is available
final hasTemplateSuggestionDataProvider = Provider.autoDispose<bool>((ref) {
  final analyses = ref.watch(templateSuggestionProvider).valueOrNull;
  return analyses != null && analyses.isNotEmpty;
});

/// Provider for calibration quality
final calibrationQualityProvider =
    Provider.autoDispose<CalibrationQuality>((ref) {
  final calibration = ref.watch(personalCalibrationProvider).valueOrNull;
  return calibration?.quality ?? CalibrationQuality.poor;
});
