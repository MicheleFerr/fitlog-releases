/// Template Suggestion Providers
///
/// Riverpod providers for template stress analysis and recommendations.
/// Analyzes all user templates against current muscle recovery to suggest
/// which workout to do today.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/template_stress_analysis.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/calibration_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/fitness_fatigue_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/prediction_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/template_stress_analyzer.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/presentation/providers/recovery_insight_provider.dart';
import 'package:health/health.dart' show NumericHealthValue;

// ============================================================================
// STRESS REFRESH TRIGGER PROVIDER
// ============================================================================

/// Provider that triggers stress insight refresh every 10 minutes
///
/// This ensures the FFM-based stress values update over time as fatigue decays.
/// Without this, the stress values would remain cached indefinitely.
final stressRefreshTriggerProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(
    const Duration(minutes: 10),
    (count) => count,
  );
});

// ============================================================================
// HEALTH DATA SNAPSHOT PROVIDER
// ============================================================================

/// Provider for HealthDataSnapshot from HealthKit
///
/// Fetches sleep, HRV, and resting heart rate from HealthKit to create
/// a snapshot for calibration and stress analysis.
///
/// **Returns**:
/// - HealthDataSnapshot with real data if available
/// - HealthDataSnapshot.empty if HealthKit not available or errors
final healthDataSnapshotProvider =
    FutureProvider.autoDispose<HealthDataSnapshot>((ref) async {
  final datasource = ref.watch(healthKitDatasourceProvider);

  // Check if HealthKit is available (iOS only)
  if (!datasource.isAvailable) {
    if (kDebugMode) {
      debugPrint('[HealthDataSnapshot] HealthKit not available');
    }
    return HealthDataSnapshot.empty;
  }

  try {
    // Initialize HealthKit (request permissions if needed)
    await datasource.initialize();

    // Fetch all needed data in parallel for efficiency
    final results = await Future.wait([
      datasource.getSleepLastNight(),
      datasource.getHrvToday(),
      datasource.getRestingHeartRate(),
    ]);

    final sleepData = results[0];
    final hrvData = results[1];
    final restingHrData = results[2];

    // Extract values
    double? sleepHours;
    if (sleepData != null) {
      final sleepMinutes = (sleepData.value as NumericHealthValue).numericValue;
      sleepHours = sleepMinutes / 60.0;
    }

    double? hrvMs;
    if (hrvData != null) {
      hrvMs = (hrvData.value as NumericHealthValue).numericValue.toDouble();
    }

    double? restingHr;
    if (restingHrData != null) {
      restingHr =
          (restingHrData.value as NumericHealthValue).numericValue.toDouble();
    }

    if (kDebugMode) {
      debugPrint('[HealthDataSnapshot] Fetched from HealthKit:');
      debugPrint('  - Sleep: ${sleepHours?.toStringAsFixed(1)}h');
      debugPrint('  - HRV: ${hrvMs?.toStringAsFixed(0)}ms');
      debugPrint('  - Resting HR: ${restingHr?.toStringAsFixed(0)}bpm');
    }

    // 🔧 PERF FIX: Cache for 5 minutes - health data doesn't change frequently
    final link = ref.keepAlive();
    Timer(const Duration(minutes: 5), link.close);

    return HealthDataSnapshot(
      sleepHoursLastNight: sleepHours,
      hrvMs: hrvMs,
      restingHeartRate: restingHr,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[HealthDataSnapshot] Error: $e');
    }
    return HealthDataSnapshot.empty;
  }
});

/// Provider for historical HRV data (last 7 days)
///
/// Used for calculating personal HRV baseline
final historicalHrvProvider =
    FutureProvider.autoDispose<List<double>?>((ref) async {
  final datasource = ref.watch(healthKitDatasourceProvider);

  if (!datasource.isAvailable) return null;

  try {
    await datasource.initialize();
    final hrvData = await datasource.getHrvThisWeek();

    if (hrvData.isEmpty) return null;

    // Extract numeric values
    final values = hrvData.map((p) {
      final numValue = p.value as NumericHealthValue;
      return numValue.numericValue.toDouble();
    }).toList();

    if (kDebugMode) {
      debugPrint('[HistoricalHRV] ${values.length} days of HRV data');
    }

    return values;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[HistoricalHRV] Error: $e');
    }
    return null;
  }
});

/// Provider for historical sleep data (last 7 days)
///
/// Used for calculating personal sleep baseline
final historicalSleepProvider =
    FutureProvider.autoDispose<List<double>?>((ref) async {
  // Reuse sleep records from recovery insight
  final sleepRecords = await ref.watch(sleepRecordsProvider.future);

  if (sleepRecords.isEmpty) return null;

  // Convert to hours
  final values = sleepRecords
      .map((r) => r.asleepDuration.inMinutes / 60.0)
      .toList();

  if (kDebugMode) {
    debugPrint('[HistoricalSleep] ${values.length} nights of sleep data');
  }

  return values;
});

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

  // Get HealthKit data (sleep, HRV, resting HR)
  final healthData = await ref.watch(healthDataSnapshotProvider.future);

  // Get historical HRV and sleep data for baselines
  final historicalHrv = await ref.watch(historicalHrvProvider.future);
  final historicalSleep = await ref.watch(historicalSleepProvider.future);

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

    // Get HealthKit data for today
    final healthData = await ref.watch(healthDataSnapshotProvider.future);

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
  // 🔧 PERF FIX: Use .select() to only rebuild when analyses change
  final analyses = ref.watch(
    templateSuggestionProvider.select((async) => async.valueOrNull),
  );

  if (analyses == null || analyses.isEmpty) return null;

  // Return the first one (already sorted by optimality score)
  return analyses.first;
});

/// Provider for optimal templates (those marked as optimal)
final optimalTemplatesProvider =
    Provider.autoDispose<List<TemplateStressAnalysis>>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when analyses change
  final analyses = ref.watch(
    templateSuggestionProvider.select((async) => async.valueOrNull ?? []),
  );

  return analyses
      .where((a) => a.recommendation == TemplateRecommendation.optimal)
      .toList();
});

/// Provider for templates to avoid
final templatesToAvoidProvider =
    Provider.autoDispose<List<TemplateStressAnalysis>>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when analyses change
  final analyses = ref.watch(
    templateSuggestionProvider.select((async) => async.valueOrNull ?? []),
  );

  return analyses
      .where((a) => a.recommendation == TemplateRecommendation.avoid)
      .toList();
});

/// Provider for checking if template suggestion data is available
final hasTemplateSuggestionDataProvider = Provider.autoDispose<bool>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when analyses change
  final analyses = ref.watch(
    templateSuggestionProvider.select((async) => async.valueOrNull),
  );
  return analyses != null && analyses.isNotEmpty;
});

/// Provider for calibration quality
final calibrationQualityProvider =
    Provider.autoDispose<CalibrationQuality>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when calibration changes
  final calibration = ref.watch(
    personalCalibrationProvider.select((async) => async.valueOrNull),
  );
  return calibration?.quality ?? CalibrationQuality.poor;
});

// ============================================================================
// STRESS INSIGHT PROVIDER
// ============================================================================

/// Provider for stress insight with predictions and recommendations
///
/// Combines:
/// - Current stress from stress index calculator
/// - Personal calibration factors
/// - HealthKit data (sleep, HRV, resting HR)
/// - **Sleep-aware stress calculation** (NEW: integrates sleep quality)
///
/// **Returns**: StressInsight with predictions and recovery recommendations
final stressInsightProvider =
    FutureProvider.autoDispose<StressInsight>((ref) async {
  try {
    // 🔧 FIX: Read ALL dependencies synchronously BEFORE any async work
    // This prevents Riverpod race condition "Cannot use ref functions after dependency changed"
    ref.watch(stressRefreshTriggerProvider);
    final stressState = ref.watch(stressIndexNotifierProvider);
    final calibrationFuture = ref.watch(personalCalibrationProvider.future);
    final healthDataFuture = ref.watch(healthDataSnapshotProvider.future);
    final sleepAwareDataFuture = ref.watch(sleepAwareStressDataProvider.future);

    // Now await the futures (after all ref.watch calls are done)
    final calibration = await calibrationFuture;
    final healthData = await healthDataFuture;
    final sleepAwareData = await sleepAwareDataFuture;

    // Get stress history for FFM calculation
    final history = stressState.valueOrNull?.history ?? [];

    // 🔧 FIX: Use SLEEP-AWARE FFM-based calculation
    // Combines training fatigue + sleep quality for complete recovery picture
    // Formula: AdjustedReadiness = FFM_Readiness × SleepModifier × ConsecutivePenalty
    final double currentStress;
    if (history.isNotEmpty) {
      // Use sleep-adjusted stress score (considers both training and sleep)
      currentStress = sleepAwareData.stressScore;

      if (kDebugMode && sleepAwareData.hasSleepImpact) {
        debugPrint('[StressInsight] Sleep impact detected:');
        debugPrint('  - Raw FFM stress: ${(100 - sleepAwareData.rawReadiness).clamp(0.0, 100.0).toStringAsFixed(1)}');
        debugPrint('  - Sleep hours: ${sleepAwareData.sleepHours.toStringAsFixed(1)}h (${sleepAwareData.sleepCategory.name})');
        debugPrint('  - Adjusted stress: ${currentStress.toStringAsFixed(1)}');
        debugPrint('  - Sleep impact: +${sleepAwareData.sleepImpact.toStringAsFixed(1)} stress');
      }
    } else {
      currentStress = 0.0; // No history = no stress
    }

    // Get average workout stress for predictions (from history)
    double avgWorkoutStress = 40.0; // Default
    if (history.isNotEmpty) {
      final stressValues = history.map((r) => r.displayScore).toList();
      avgWorkoutStress = stressValues.reduce((a, b) => a + b) / stressValues.length;
    }

    // Calculate insight using SINGLE SOURCE OF TRUTH (FFM)
    // First get base prediction from PredictionService
    final baseInsight = PredictionService.calculateInsight(
      currentStress: currentStress,
      calibration: calibration,
      healthData: healthData.hasData ? healthData : null,
      averageWorkoutStress: avgWorkoutStress,
    );

    // Override predictedIfWorkout with FFM-based simulation
    // This ensures consistency between actual stress and predictions
    final ffmPredictedIfWorkout = history.isNotEmpty
        ? FitnessFatigueService.predictStressAfterSimulatedWorkout(
            workoutHistory: history,
            simulatedWorkoutStress: avgWorkoutStress,
          )
        : avgWorkoutStress; // No history = just use average

    // Create updated insight with FFM prediction
    final insight = StressInsight(
      currentStress: baseInsight.currentStress,
      predictedTomorrow: baseInsight.predictedTomorrow,
      predictedIfWorkout: ffmPredictedIfWorkout,
      recommendation: baseInsight.recommendation,
      rationale: baseInsight.rationale,
      factors: baseInsight.factors,
      calibrationQuality: baseInsight.calibrationQuality,
      calculatedAt: DateTime.now(),
    );

    if (kDebugMode) {
      final now = DateTime.now();
      debugPrint('[StressInsight] Calculated at ${now.hour}:${now.minute}:${now.second}');
      debugPrint('  - Raw FFM Readiness: ${sleepAwareData.rawReadiness.toStringAsFixed(1)}%');
      debugPrint('  - Sleep Hours: ${sleepAwareData.sleepHours.toStringAsFixed(1)}h (${sleepAwareData.sleepCategory.name})');
      debugPrint('  - Sleep Modifier: ${sleepAwareData.sleepModifier}x');
      debugPrint('  - Adjusted Readiness: ${sleepAwareData.adjustedReadiness.toStringAsFixed(1)}%');
      debugPrint('  - Current Stress: ${insight.displayStress} (sleep-aware)');
      debugPrint('  - Tomorrow (rest): ${insight.displayPredicted}');
      debugPrint('  - If Workout (FFM): ${insight.predictedIfWorkout.toStringAsFixed(1)} (avg stress: ${avgWorkoutStress.toStringAsFixed(1)})');
      debugPrint('  - Recovery rate: ${insight.recoveryRatePerHour.toStringAsFixed(2)}/h');
      debugPrint('  - Recommendation: ${insight.recommendation.name}');
    }

    return insight;
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[StressInsight] Error: $e\n$st');
    }
    return StressInsight.empty();
  }
});

/// Provider for recovery recommendation only
final recoveryRecommendationProvider =
    Provider.autoDispose<RecoveryRecommendation>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when insight changes
  final insight = ref.watch(
    stressInsightProvider.select((async) => async.valueOrNull),
  );
  return insight?.recommendation ?? RecoveryRecommendation.readyHard;
});

/// Provider for predicted stress tomorrow (if resting)
final predictedStressTomorrowProvider = Provider.autoDispose<int>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when insight changes
  final insight = ref.watch(
    stressInsightProvider.select((async) => async.valueOrNull),
  );
  return insight?.displayPredicted ?? 0;
});

/// Provider for stress rationale
final stressRationaleProvider = Provider.autoDispose<String>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when insight changes
  final insight = ref.watch(
    stressInsightProvider.select((async) => async.valueOrNull),
  );
  return insight?.rationale ?? '';
});

/// Provider to check if training tomorrow is advisable
final canTrainTomorrowProvider = Provider.autoDispose<bool>((ref) {
  // 🔧 PERF FIX: Use .select() to only rebuild when insight changes
  final insight = ref.watch(
    stressInsightProvider.select((async) => async.valueOrNull),
  );
  return insight?.canTrainTomorrow ?? true;
});
