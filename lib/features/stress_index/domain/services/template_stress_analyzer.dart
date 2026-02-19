/// Template Stress Analyzer
///
/// Analyzes workout templates against current muscle recovery status
/// to recommend which template to do today.
///
/// Key Features:
/// - Extracts primary/secondary muscles from each exercise
/// - Cross-references with current muscle recovery
/// - Calculates expected stress from template
/// - Ranks templates by optimality
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/template_stress_analysis.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/calibration_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
    as workout;
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';

/// Muscle recovery history for analysis
class MuscleRecoveryHistory {
  const MuscleRecoveryHistory({
    required this.muscleId,
    required this.displayName,
    required this.lastWorkedAt,
    required this.lastStressScore,
  });

  final String muscleId;
  final String displayName;
  final DateTime lastWorkedAt;
  final double lastStressScore;
}

/// Static service for template stress analysis
class TemplateStressAnalyzer {
  TemplateStressAnalyzer._();

  /// Get display name for a muscle ID using centralized mapper
  ///
  /// Uses [MuscleAbbreviationMapper] as SINGLE SOURCE OF TRUTH.
  static String _getMuscleDisplayName(String muscleId) {
    return MuscleAbbreviationMapper.getMuscleInfo(muscleId)?.displayNameIt ??
        muscleId;
  }

  /// Analyze all templates and return ranked recommendations
  ///
  /// Parameters:
  /// - [templates]: List of user's workout templates
  /// - [exerciseDatabase]: Map of exerciseId -> ExerciseDefinition for muscle lookup
  /// - [muscleHistory]: Map of muscleId -> recovery history
  /// - [calibration]: Personal calibration factors
  /// - [healthData]: Current health data snapshot
  /// - [currentStress]: Current overall stress level (0-100)
  static List<TemplateStressAnalysis> analyzeAllTemplates({
    required List<CommunityWorkoutTemplate> templates,
    required Map<String, ExerciseDefinition> exerciseDatabase,
    required Map<String, MuscleRecoveryHistory> muscleHistory,
    required PersonalCalibration calibration,
    HealthDataSnapshot? healthData,
    double currentStress = 0,
  }) {
    final analyses = <TemplateStressAnalysis>[];

    for (final template in templates) {
      final analysis = analyzeTemplate(
        template: template,
        exerciseDatabase: exerciseDatabase,
        muscleHistory: muscleHistory,
        calibration: calibration,
        healthData: healthData,
        currentStress: currentStress,
      );
      analyses.add(analysis);
    }

    // Sort by optimality score (higher is better)
    analyses.sort((a, b) => b.optimalityScore.compareTo(a.optimalityScore));

    return analyses;
  }

  /// Analyze a single template
  static TemplateStressAnalysis analyzeTemplate({
    required CommunityWorkoutTemplate template,
    required Map<String, ExerciseDefinition> exerciseDatabase,
    required Map<String, MuscleRecoveryHistory> muscleHistory,
    required PersonalCalibration calibration,
    HealthDataSnapshot? healthData,
    double currentStress = 0,
  }) {
    // Extract muscles from template
    final muscles = _extractMusclesFromTemplate(template, exerciseDatabase);
    final primaryMuscles = muscles['primary'] ?? <String>[];
    final secondaryMuscles = muscles['secondary'] ?? <String>[];
    final allMuscles = {...primaryMuscles, ...secondaryMuscles};

    // Calculate readiness for each muscle
    final muscleReadiness = <String, MuscleReadinessData>{};
    final underRecoveredMuscles = <String>[];
    final fatiguedMuscles = <String>[];

    for (final muscleId in allMuscles) {
      final history = muscleHistory[muscleId];
      final displayName = _getMuscleDisplayName(muscleId);

      final MuscleReadinessData readiness;

      if (history != null) {
        readiness = CalibrationService.calculateMuscleRecovery(
          muscleId: muscleId,
          displayName: displayName,
          lastWorkedAt: history.lastWorkedAt,
          lastWorkoutStress: history.lastStressScore,
          calibration: calibration,
          healthData: healthData,
          isPrimaryMuscle: primaryMuscles.contains(muscleId),
        );
      } else {
        // Never worked = fully ready
        readiness = MuscleReadinessData(
          muscleId: muscleId,
          displayName: displayName,
          recoveryPercent: 100,
          hoursSinceWorkout: 999,
          isPrimaryMuscle: primaryMuscles.contains(muscleId),
        );
      }

      muscleReadiness[muscleId] = readiness;

      if (readiness.shouldAvoid) {
        fatiguedMuscles.add(muscleId);
      } else if (readiness.isSuboptimal) {
        underRecoveredMuscles.add(muscleId);
      }
    }

    // Calculate expected stress from this template
    final expectedStress = _calculateExpectedStress(
      template: template,
      exerciseDatabase: exerciseDatabase,
      muscleReadiness: muscleReadiness,
    );

    final resultingTotalStress = currentStress + expectedStress;

    // Determine recommendation
    final recommendation = _determineRecommendation(
      muscleReadiness: muscleReadiness,
      primaryMuscles: primaryMuscles.toList(),
      fatiguedMuscles: fatiguedMuscles,
      underRecoveredMuscles: underRecoveredMuscles,
    );

    // Calculate optimality score (0-100)
    final optimalityScore = _calculateOptimalityScore(
      muscleReadiness: muscleReadiness,
      primaryMuscles: primaryMuscles.toList(),
      recommendation: recommendation,
    );

    // Generate rationale
    final rationale = _generateRationale(
      templateName: template.name,
      recommendation: recommendation,
      muscleReadiness: muscleReadiness,
      primaryMuscles: primaryMuscles.toList(),
      fatiguedMuscles: fatiguedMuscles,
      underRecoveredMuscles: underRecoveredMuscles,
      healthData: healthData,
    );

    return TemplateStressAnalysis(
      templateId: template.id,
      templateName: template.name,
      templateIcon: null, // CommunityWorkoutTemplate doesn't have an icon field
      expectedStress: expectedStress,
      currentStress: currentStress,
      resultingTotalStress: resultingTotalStress,
      muscleReadiness: muscleReadiness,
      primaryMuscles: primaryMuscles.toList(),
      secondaryMuscles: secondaryMuscles.toList(),
      underRecoveredMuscles: underRecoveredMuscles,
      fatiguedMuscles: fatiguedMuscles,
      recommendation: recommendation,
      rationale: rationale,
      optimalityScore: optimalityScore,
      sleepDataUsed: healthData?.sleepHoursLastNight != null,
      hrvDataUsed: healthData?.hrvMs != null,
      sleepHoursLastNight: healthData?.sleepHoursLastNight,
      hrvMs: healthData?.hrvMs,
    );
  }

  /// Extract primary and secondary muscles from template
  static Map<String, Set<String>> _extractMusclesFromTemplate(
    CommunityWorkoutTemplate template,
    Map<String, ExerciseDefinition> exerciseDatabase,
  ) {
    final primaryMuscles = <String>{};
    final secondaryMuscles = <String>{};

    for (final exercise in template.exercises) {
      // Look up by exercise name (templates use name to reference exercises)
      final definition =
          exerciseDatabase[exercise.name] ?? exerciseDatabase[exercise.id];

      if (definition != null) {
        primaryMuscles.addAll(definition.focus);
        secondaryMuscles.addAll(definition.muscoliSecondari);
      }

      // Also check sub-exercises (for supersets)
      if (exercise is workout.SupersetExercise) {
        for (final subExercise in exercise.exercises) {
          final subDef =
              exerciseDatabase[subExercise.name] ??
              exerciseDatabase[subExercise.id];
          if (subDef != null) {
            primaryMuscles.addAll(subDef.focus);
            secondaryMuscles.addAll(subDef.muscoliSecondari);
          }
        }
      }
    }

    // Remove primary muscles from secondary (no overlap)
    secondaryMuscles.removeWhere((m) => primaryMuscles.contains(m));

    return {'primary': primaryMuscles, 'secondary': secondaryMuscles};
  }

  /// Calculate expected stress from template
  static double _calculateExpectedStress({
    required CommunityWorkoutTemplate template,
    required Map<String, ExerciseDefinition> exerciseDatabase,
    required Map<String, MuscleReadinessData> muscleReadiness,
  }) {
    double totalStress = 0;

    for (final exercise in template.exercises) {
      // Handle supersets differently
      if (exercise is workout.SupersetExercise) {
        // For supersets, calculate stress from superset rounds
        final roundCount = exercise.supersetSets.length;
        final subExerciseCount = exercise.exercises.length;
        // Estimate: 3 rounds × 2 exercises × 50kg × 10 reps / 1000
        totalStress +=
            (roundCount == 0 ? 3 : roundCount) *
            subExerciseCount *
            50 *
            10 /
            1000;
        continue;
      }

      // Regular exercise: estimate stress from sets
      int totalSets = exercise.sets.length;
      double avgWeight = 0;
      double avgReps = 0;

      for (final set in exercise.sets) {
        if (set.weight != null) {
          avgWeight += set.weight!;
        }
        if (set.reps != null) {
          avgReps += set.reps!;
        }
      }

      if (exercise.sets.isNotEmpty) {
        avgWeight /= exercise.sets.length;
        avgReps /= exercise.sets.length;
      }

      // Default values if not specified
      if (avgWeight == 0) avgWeight = 50; // Default weight
      if (avgReps == 0) avgReps = 10; // Default reps
      if (totalSets == 0) totalSets = 3; // Default sets

      // Simple stress formula: weight × reps × sets / 1000
      final exerciseStress = (avgWeight * avgReps * totalSets) / 1000;
      totalStress += exerciseStress;
    }

    // Normalize to 0-100 scale
    // Typical workout: 5-10 exercises × 3-5 sets × 60kg × 10 reps = 9000-30000
    // Map to approximately 30-80 stress
    double normalizedStress = (totalStress / 30) * 100;
    normalizedStress = normalizedStress.clamp(10, 100);

    return normalizedStress;
  }

  /// Determine template recommendation
  static TemplateRecommendation _determineRecommendation({
    required Map<String, MuscleReadinessData> muscleReadiness,
    required List<String> primaryMuscles,
    required List<String> fatiguedMuscles,
    required List<String> underRecoveredMuscles,
  }) {
    // Check primary muscles specifically
    final primaryFatigued = fatiguedMuscles
        .where((m) => primaryMuscles.contains(m))
        .toList();
    final primaryUnderRecovered = underRecoveredMuscles
        .where((m) => primaryMuscles.contains(m))
        .toList();

    // If any primary muscle is fatigued (<50%), avoid
    if (primaryFatigued.isNotEmpty) {
      return TemplateRecommendation.avoid;
    }

    // If multiple primary muscles are under-recovered (<70%), suboptimal
    if (primaryUnderRecovered.length > 1) {
      return TemplateRecommendation.suboptimal;
    }

    // If one primary muscle is under-recovered, acceptable
    if (primaryUnderRecovered.isNotEmpty) {
      return TemplateRecommendation.acceptable;
    }

    // Check if all primary muscles are >90%
    final allPrimaryReady = primaryMuscles.every((m) {
      final readiness = muscleReadiness[m];
      return (readiness?.recoveryPercent ?? 100) >= 90;
    });

    if (allPrimaryReady) {
      return TemplateRecommendation.optimal;
    }

    return TemplateRecommendation.acceptable;
  }

  /// Calculate optimality score (0-100)
  static double _calculateOptimalityScore({
    required Map<String, MuscleReadinessData> muscleReadiness,
    required List<String> primaryMuscles,
    required TemplateRecommendation recommendation,
  }) {
    // Base score from recommendation
    double baseScore;
    switch (recommendation) {
      case TemplateRecommendation.optimal:
        baseScore = 90;
      case TemplateRecommendation.acceptable:
        baseScore = 70;
      case TemplateRecommendation.suboptimal:
        baseScore = 40;
      case TemplateRecommendation.avoid:
        baseScore = 10;
    }

    // Adjust based on average primary muscle recovery
    if (primaryMuscles.isNotEmpty) {
      double avgRecovery = 0;
      for (final m in primaryMuscles) {
        avgRecovery += muscleReadiness[m]?.recoveryPercent ?? 100;
      }
      avgRecovery /= primaryMuscles.length;

      // Add bonus/penalty based on recovery
      final recoveryBonus = ((avgRecovery - 75) / 25) * 10;
      baseScore += recoveryBonus;
    }

    return baseScore.clamp(0, 100);
  }

  /// Generate human-readable rationale
  static String _generateRationale({
    required String templateName,
    required TemplateRecommendation recommendation,
    required Map<String, MuscleReadinessData> muscleReadiness,
    required List<String> primaryMuscles,
    required List<String> fatiguedMuscles,
    required List<String> underRecoveredMuscles,
    HealthDataSnapshot? healthData,
  }) {
    final buffer = StringBuffer();

    switch (recommendation) {
      case TemplateRecommendation.optimal:
        buffer.write('Tutti i muscoli principali sono recuperati (>90%). ');
        buffer.write('Ottimo momento per $templateName!');

      case TemplateRecommendation.acceptable:
        buffer.write('La maggior parte dei muscoli è pronta. ');
        if (underRecoveredMuscles.isNotEmpty) {
          final muscleNames = underRecoveredMuscles
              .take(2)
              .map(_getMuscleDisplayName)
              .join(', ');
          buffer.write('$muscleNames leggermente affaticati. ');
        }
        buffer.write('Puoi procedere con $templateName.');

      case TemplateRecommendation.suboptimal:
        buffer.write('Alcuni muscoli sono sotto-recuperati: ');
        final muscleNames = underRecoveredMuscles
            .take(3)
            .map((m) {
              final recovery = muscleReadiness[m]?.recoveryPercent.round() ?? 0;
              return '${_getMuscleDisplayName(m)} ($recovery%)';
            })
            .join(', ');
        buffer.write('$muscleNames. ');
        buffer.write('Considera una sessione leggera o riposo.');

      case TemplateRecommendation.avoid:
        buffer.write('Muscoli criticamente affaticati: ');
        final muscleNames = fatiguedMuscles
            .take(3)
            .map((m) {
              final recovery = muscleReadiness[m]?.recoveryPercent.round() ?? 0;
              return '${_getMuscleDisplayName(m)} ($recovery%)';
            })
            .join(', ');
        buffer.write('$muscleNames. ');
        buffer.write('Evita $templateName oggi.');
    }

    // Add health data context
    if (healthData != null) {
      final factors = <String>[];

      if (healthData.sleepHoursLastNight != null) {
        final sleep = healthData.sleepHoursLastNight!;
        if (sleep < 6) {
          factors.add('sonno critico (${sleep.toStringAsFixed(1)}h)');
        } else if (sleep < 7) {
          factors.add('sonno ${sleep.toStringAsFixed(1)}h');
        }
      }

      if (healthData.hrvMs != null) {
        factors.add('HRV ${healthData.hrvMs!.round()}ms');
      }

      if (factors.isNotEmpty) {
        buffer.write(' [${factors.join(' • ')}]');
      }
    }

    return buffer.toString();
  }
}
