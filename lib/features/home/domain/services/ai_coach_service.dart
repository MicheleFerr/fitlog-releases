/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/home/domain/services
/// 🎯 Feature: home
/// 🔧 Type: service
///
/// Servizio che analizza i dati di allenamento e fornisce insights intelligenti
/// Implementazione scientificamente accurata basata su ricerca evidence-based
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_volume_calculator.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';

/// Types of AI insights that can be generated
enum InsightType {
  muscleGroupBalance,
  progressOverload,
  recoveryPattern,
  volumeOptimization,
  frequencyRecommendation,
  plateauBreaker,
  formWarning,
  motivational,
}

/// Action type for insights that can be acted upon
enum InsightActionType {
  replaceExercise,
  modifyVolume,
  adjustRest,
  none,
}

/// Severity level for insights (affects UI color and priority display)
enum InsightSeverity {
  critical,   // 🔴 Red - Immediate attention (injury risk, overtraining)
  warning,    // 🟠 Orange - Important but not urgent (plateaus, imbalances)
  info,       // 🔵 Blue - Informative/educational
  success,    // 🟢 Green - Positive feedback
}

/// Template where affected exercise appears
class AffectedTemplate {

  const AffectedTemplate({
    required this.templateId,
    required this.templateName,
  });
  final String templateId;
  final String templateName;
}

/// AI insight generated for the user
class AIInsight { // IDs of anomalies affecting this insight

  const AIInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.priority,
    this.data = const {},
    this.detailedAnalysis,
    this.dataPoints,
    this.strategies,
    this.scientificReference,
    this.affectedExercise,
    this.affectedTemplates,
    this.actionType,
    this.severity,
    this.dataQualityConfidence,
    this.detectedAnomalies,
  });
  final InsightType type;
  final String title;
  final String description;
  final String recommendation;
  final int priority; // 1 = highest, 5 = lowest
  final Map<String, dynamic> data;

  // Enhanced details for expandable UI
  final String? detailedAnalysis; // Why this is flagged
  final List<String>? dataPoints; // Specific data supporting the insight
  final List<ScientificStrategy>? strategies; // Evidence-based solutions
  final String? scientificReference; // Paper citation

  // Actionable exercise data
  final String? affectedExercise; // Exercise name with issue
  final List<AffectedTemplate>? affectedTemplates; // Templates containing this exercise
  final InsightActionType? actionType; // Type of action user can take

  // UI/UX enhancements
  final InsightSeverity? severity; // Optional explicit severity (auto-calculated if null)

  // Data quality tracking
  final double? dataQualityConfidence; // 0.0-1.0, null = not checked
  final List<String>? detectedAnomalies;

  /// Whether this insight has actionable data
  bool get hasAction =>
      affectedExercise != null &&
      affectedTemplates != null &&
      affectedTemplates!.isNotEmpty &&
      actionType != null &&
      actionType != InsightActionType.none;

  /// Get severity level (auto-calculated from type and priority if not explicit)
  InsightSeverity get effectiveSeverity {
    // If severity is explicitly set, use it
    if (severity != null) return severity!;

    // Auto-calculate based on type and priority
    switch (type) {
      case InsightType.formWarning:
        return InsightSeverity.critical; // 🔴 Injury risk
      case InsightType.volumeOptimization:
        return priority == 1 ? InsightSeverity.critical : InsightSeverity.warning; // Overtraining
      case InsightType.recoveryPattern:
        return priority <= 2 ? InsightSeverity.warning : InsightSeverity.info;
      case InsightType.muscleGroupBalance:
        return InsightSeverity.warning; // 🟠 Imbalance
      case InsightType.progressOverload:
      case InsightType.plateauBreaker:
        return InsightSeverity.warning; // 🟠 Plateau
      case InsightType.frequencyRecommendation:
        return InsightSeverity.info; // 🔵 Informational
      case InsightType.motivational:
        return InsightSeverity.success; // 🟢 Positive
    }
  }

  /// Whether this insight is based on questionable data (low confidence)
  /// Threshold: < 0.7 is considered low quality
  bool get hasDataQualityIssues =>
      dataQualityConfidence != null &&
      dataQualityConfidence! < 0.7;

  /// Generate a deterministic hash for this insight
  /// Used to identify the same insight across sessions for feedback tracking
  String generateHash() {
    // Build a unique string from insight key data
    final components = <String>[
      type.toString(),
      // Include affected exercise if present (most specific identifier)
      if (affectedExercise != null) affectedExercise!,
      // Include muscle group from data if present
      if (data['muscleGroup'] != null) data['muscleGroup'].toString(),
      // Include exercise from data if present
      if (data['exercise'] != null) data['exercise'].toString(),
    ];

    // Create hash from components
    final content = components.join('|');
    final bytes = utf8.encode(content);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}

/// Scientific strategy for resolving training issues
class ScientificStrategy { // e.g., "Schoenfeld et al. 2017"

  const ScientificStrategy({
    required this.title,
    required this.description,
    required this.howToImplement,
    required this.expectedOutcome,
    required this.scientificBasis,
  });
  final String title;
  final String description;
  final String howToImplement;
  final String expectedOutcome;
  final String scientificBasis;
}

/// Service that analyzes workout data and provides intelligent insights
class AICoachService {
  /// Generate personalized insights based on workout data
  static List<AIInsight> generateInsights(
    List<ExerciseActivity> activities,
    QuickStats? stats,
    int currentStreak,
    double weeklyFrequency,
    AppLocalizations l10n,
    Map<String, Exercise> exerciseDatabase,
    List<WorkoutTemplate> userTemplates, {
    List<dynamic> completedWorkouts = const [],
  }) {
    final insights = <AIInsight>[];

    if (activities.isEmpty) {
      insights.add(AIInsight(
        type: InsightType.motivational,
        title: l10n.aiInsightStartJourney,
        description: l10n.aiInsightStartJourneyDesc,
        recommendation: l10n.aiInsightStartJourneyRec,
        priority: 1,
      ));
      return insights;
    }

    // Special handling for new users (1-3 workouts total)
    if (activities.length <= 3) {
      insights.add(AIInsight(
        type: InsightType.motivational,
        title: l10n.aiInsightNewUser,
        description: l10n.aiInsightNewUserDesc,
        recommendation: l10n.aiInsightNewUserRec,
        priority: 1,
      ));
      return insights; // Skip advanced analytics for new users
    }

    // Filtra attività dell'ultima settimana per analisi volume
    final weeklyActivities = activities.where(
      (a) => a.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7))),
    ).toList();

    // Analisi scientifica del volume per muscle group
    insights.addAll(_analyzeVolumeByMuscleGroup(weeklyActivities, exerciseDatabase, l10n));

    // Analyze progressive overload
    insights.addAll(_analyzeProgressiveOverload(activities, l10n, userTemplates));

    // Analyze recovery patterns (use completed workouts if available, fallback to activities)
    insights.addAll(_analyzeRecoveryPatterns(
      completedWorkouts.isNotEmpty ? completedWorkouts : activities,
      l10n,
      useWorkouts: completedWorkouts.isNotEmpty,
    ));

    // Analyze frequency
    insights.addAll(_analyzeFrequency(weeklyFrequency, l10n));

    // Check for plateaus
    insights.addAll(_detectPlateaus(activities, l10n));

    // Form warnings
    insights.addAll(_analyzeFormWarnings(activities, l10n, userTemplates));

    // Sort by priority and return top insights
    insights.sort((a, b) => a.priority.compareTo(b.priority));
    return insights.take(5).toList();
  }

  /// Analisi CORRETTA del volume per muscle group (approccio scientifico)
  static List<AIInsight> _analyzeVolumeByMuscleGroup(
    List<ExerciseActivity> weeklyActivities,
    Map<String, Exercise> exerciseDatabase,
    AppLocalizations l10n,
  ) {
    final insights = <AIInsight>[];

    if (weeklyActivities.isEmpty) return insights;

    // Calcola volume settimanale per muscle group
    final volumeByMuscle = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
      weeklyActivities,
      exerciseDatabase,
    );

    // Identifica muscle groups sbilanciati (sotto MEV)
    final undertrainedMuscles = AIVolumeCalculator.findImbalancedMuscles(volumeByMuscle);
    if (undertrainedMuscles.isNotEmpty) {
      final muscle = undertrainedMuscles.first;
      final volume = volumeByMuscle[muscle]!;

      insights.add(AIInsight(
        type: InsightType.muscleGroupBalance,
        title: l10n.aiInsightMuscleImbalance,
        description: l10n.aiInsightMuscleImbalanceDesc(_getMuscleGroupName(muscle, l10n)),
        recommendation: l10n.aiInsightMuscleImbalanceRec(_getMuscleGroupName(muscle, l10n)),
        priority: 2,
        data: {
          'muscleGroup': muscle,
          'currentSets': volume.totalSets,
          'recommendedSets': 15,
        },
        detailedAnalysis: l10n.aiMuscleImbalanceAnalysis(
          _getMuscleGroupName(muscle, l10n),
          volume.totalSets.toString(),
        ),
        dataPoints: [
          l10n.dataCurrentVolume(volume.totalSets.toString()),
          l10n.dataMEV,
          l10n.dataMAV,
          l10n.dataDeficit((10 - volume.totalSets).toString()),
          l10n.dataExercisesList(volume.exercises.take(3).join(', ')),
        ],
        strategies: _getMuscleBalanceStrategies(l10n),
        scientificReference: '''Schoenfeld & Grgic (2018) - Evidence-based guidelines for resistance training volume
https://doi.org/10.1519/SSC.0000000000000363''',
      ));
    }

    // Identifica muscle groups in overtraining (sopra MRV)
    final overtrainedMuscles = AIVolumeCalculator.findOvertrainedMuscles(volumeByMuscle);
    if (overtrainedMuscles.isNotEmpty) {
      final muscle = overtrainedMuscles.first;
      final volume = volumeByMuscle[muscle]!;

      insights.add(AIInsight(
        type: InsightType.volumeOptimization,
        title: l10n.aiInsightHighVolume,
        description: l10n.aiInsightHighVolumeDesc(volume.totalSets),
        recommendation: l10n.aiInsightHighVolumeRec,
        priority: 1, // Alta priorità - rischio overtraining
        data: {
          'muscleGroup': muscle,
          'currentSets': volume.totalSets,
          'recommendedSets': 20,
        },
        detailedAnalysis: l10n.aiHighVolumeAnalysis(
          _getMuscleGroupName(muscle, l10n),
          volume.totalSets.toString(),
        ),
        dataPoints: [
          l10n.dataCurrentVolume(volume.totalSets.toString()),
          l10n.dataMRV,
          l10n.dataMAV,
          l10n.dataExcess((volume.totalSets - 25).toString()),
          l10n.dataExercisesList(volume.exercises.take(3).join(', ')),
          l10n.dataRiskOvertraining,
        ],
        strategies: [
          ScientificStrategy(
            title: l10n.strategyHighvolumereducegraduallyTitle,
            description: l10n.strategyHighvolumereducegraduallyDesc,
            howToImplement: l10n.strategyHighvolumereducegraduallyImpl,
            expectedOutcome: l10n.strategyHighvolumereducegraduallyOutcome,
            scientificBasis: 'Israetel et al. (2017) - Volume Landmarks for muscle growth',
          ),
          ScientificStrategy(
            title: l10n.strategyHighvolumedeloadTitle,
            description: l10n.strategyHighvolumedeloadDesc,
            howToImplement: l10n.strategyHighvolumedeloadImpl,
            expectedOutcome: l10n.strategyHighvolumedeloadOutcome,
            scientificBasis: 'Pritchard et al. (2015) - Effects and mechanisms of deloading',
          ),
          ScientificStrategy(
            title: l10n.strategyHighvolumeincreasefreqTitle,
            description: l10n.strategyHighvolumeincreasefreqDesc,
            howToImplement: l10n.strategyHighvolumeincreasefreqImpl,
            expectedOutcome: l10n.strategyHighvolumeincreasefreqOutcome,
            scientificBasis: 'Schoenfeld et al. (2019) - Training frequency and hypertrophy',
          ),
        ],
        scientificReference: '''Fry & Kraemer (1997) - Resistance exercise overtraining and overreaching
https://pubmed.ncbi.nlm.nih.gov/9475647/''',
      ));
    }

    // POSITIVE FEEDBACK: Identify optimal volume muscle groups
    final optimalMuscles = volumeByMuscle.entries
        .where((e) => e.value.isOptimal)
        .toList();

    if (optimalMuscles.isNotEmpty && undertrainedMuscles.isEmpty && overtrainedMuscles.isEmpty) {
      final muscle = optimalMuscles.first.key;
      final volume = optimalMuscles.first.value;

      insights.add(AIInsight(
        type: InsightType.motivational,
        title: l10n.aiInsightOptimalVolume,
        description: l10n.aiInsightOptimalVolumeDesc(_getMuscleGroupName(muscle, l10n), volume.totalSets),
        recommendation: l10n.aiInsightOptimalVolumeRec,
        priority: 4, // Bassa priorità - feedback positivo
        data: {
          'muscleGroup': muscle,
          'currentSets': volume.totalSets,
          'optimalMuscles': optimalMuscles.length,
        },
      ));
    }

    return insights;
  }

  /// Analyze progressive overload patterns
  static List<AIInsight> _analyzeProgressiveOverload(
    List<ExerciseActivity> activities,
    AppLocalizations l10n,
    List<WorkoutTemplate> userTemplates,
  ) {
    final insights = <AIInsight>[];

    // Group activities by exercise
    final exerciseGroups = <String, List<ExerciseActivity>>{};
    for (final activity in activities) {
      exerciseGroups.putIfAbsent(activity.exerciseName, () => []).add(activity);
    }

    for (final entry in exerciseGroups.entries) {
      final exerciseName = entry.key;
      final exerciseActivities = entry.value
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (exerciseActivities.length >= 3) {
        final recent = exerciseActivities.length >= 3
            ? exerciseActivities.sublist(exerciseActivities.length - 3)
            : exerciseActivities;
        final weights = recent.map((a) => _getMaxWeight(a)).toList();

        if (weights.isNotEmpty && weights.first > 0) {
          // Calculate weight range and average
          final minWeight = weights.reduce((a, b) => a < b ? a : b);
          final maxWeight = weights.reduce((a, b) => a > b ? a : b);
          final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
          final weightRange = maxWeight - minWeight;

          // Plateau if variation is less than 5% of average weight
          final isStagnant = weightRange / avgWeight < 0.05;

          if (isStagnant) {
            // Find which templates contain this exercise
            final affectedTemplates = _findTemplatesWithExercise(exerciseName, userTemplates);

            insights.add(AIInsight(
              type: InsightType.progressOverload,
              title: l10n.aiInsightPlateauAlert,
              description: l10n.aiInsightPlateauDesc(exerciseName),
              recommendation: l10n.aiInsightPlateauRec,
              priority: 3,
              data: {
                'exercise': exerciseName,
                'currentWeight': avgWeight.toStringAsFixed(1),
                'weightRange': weightRange,
              },
              detailedAnalysis: l10n.aiPlateauAnalysis(
              ((weightRange / avgWeight) * 100).toStringAsFixed(1),
            ),
              dataPoints: [
                l10n.dataSession1(weights[0].toStringAsFixed(1)),
                l10n.dataSession2(weights[1].toStringAsFixed(1)),
                l10n.dataSession3(weights[2].toStringAsFixed(1)),
                l10n.dataAverageWeight(avgWeight.toStringAsFixed(1)),
                l10n.dataWeightVariation2(
                  weightRange.toStringAsFixed(1),
                  ((weightRange / avgWeight) * 100).toStringAsFixed(1),
                ),
              ],
              strategies: _getPlateauBreakingStrategies(l10n),
              scientificReference: '''Schoenfeld et al. (2017) - Mechanisms of Hypertrophy
https://doi.org/10.1007/s40279-017-0713-y''',
              // Actionable data
              affectedExercise: exerciseName,
              affectedTemplates: affectedTemplates.isNotEmpty ? affectedTemplates : null,
              actionType: affectedTemplates.isNotEmpty ? InsightActionType.replaceExercise : InsightActionType.none,
            ));
            break; // Solo un insight per plateau
          }
        }
      }
    }

    return insights;
  }

  /// Analyze recovery patterns between workouts
  static List<AIInsight> _analyzeRecoveryPatterns(
    List<dynamic> data,
    AppLocalizations l10n, {
    bool useWorkouts = false,
  }) {
    final insights = <AIInsight>[];

    if (data.isEmpty) return insights;

    DateTime? lastWorkoutDate;

    if (useWorkouts) {
      // Using Workout entities (preferred)
      final workouts = data.cast<dynamic>();
      if (workouts.isEmpty) return insights;

      // Sort workouts by end time or created time (most recent first)
      final sortedWorkouts = List<dynamic>.from(workouts)
        ..sort((a, b) {
          final aDate = (a.endTime ?? a.createdAt) as DateTime;
          final bDate = (b.endTime ?? b.createdAt) as DateTime;
          return bDate.compareTo(aDate);
        });

      final lastWorkout = sortedWorkouts.first;
      lastWorkoutDate = (lastWorkout.endTime ?? lastWorkout.createdAt) as DateTime;
    } else {
      // Fallback to ExerciseActivity
      final activities = data.cast<ExerciseActivity>();

      // Filter only completed activities
      final completedActivities = activities.where((activity) {
        return activity.sets.any((set) => set.done);
      }).toList();

      if (completedActivities.isEmpty) return insights;

      // Sort by date (most recent first)
      final sortedActivities = completedActivities
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      lastWorkoutDate = sortedActivities.first.createdAt;
    }

    final hoursSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inHours;
    final daysSinceLastWorkout = hoursSinceLastWorkout / 24.0;

    // Insufficient recovery: working out again within 24 hours
    if (daysSinceLastWorkout < 1.0) {
      insights.add(AIInsight(
        type: InsightType.recoveryPattern,
        title: l10n.aiInsightInsufficientRecovery,
        description: l10n.aiInsightInsufficientRecoveryDesc,
        recommendation: l10n.aiInsightInsufficientRecoveryRec,
        priority: 2,
        data: {'daysSinceLastWorkout': daysSinceLastWorkout},
        detailedAnalysis: l10n.aiInsufficientRecoveryAnalysis(
          daysSinceLastWorkout.toStringAsFixed(1),
        ),
        dataPoints: [
          l10n.dataLastWorkout(daysSinceLastWorkout.toStringAsFixed(1)),
          l10n.dataMinimumRecovery,
          l10n.dataOptimalRange,
          l10n.dataCurrentStatus,
          l10n.dataMuscleProteinSynthesis,
        ],
        strategies: _getRecoveryStrategies(l10n),
        scientificReference: '''Dattilo et al. (2011) - Sleep and muscle recovery
https://pubmed.ncbi.nlm.nih.gov/21550729/''',
      ));
    }
    // Long recovery: more than 4 days without training
    else if (daysSinceLastWorkout > 4.0) {
      insights.add(AIInsight(
        type: InsightType.recoveryPattern,
        title: l10n.aiInsightLongRecovery,
        description: l10n.aiInsightLongRecoveryDesc,
        recommendation: l10n.aiInsightLongRecoveryRec,
        priority: 3,
        data: {'daysSinceLastWorkout': daysSinceLastWorkout},
        detailedAnalysis: l10n.aiLongRecoveryAnalysis(
          daysSinceLastWorkout.toStringAsFixed(1),
        ),
        dataPoints: [
          l10n.dataLastWorkout(daysSinceLastWorkout.toStringAsFixed(1)),
          l10n.dataMaxRecommended,
          l10n.dataProteinSynthesisPeak,
          l10n.dataDetrainingRisk,
          l10n.dataOptimalFrequency,
        ],
        strategies: [
          ScientificStrategy(
            title: l10n.strategyLongrecoveryscheduleTitle,
            description: l10n.strategyLongrecoveryscheduleDesc,
            howToImplement: l10n.strategyLongrecoveryscheduleImpl,
            expectedOutcome: l10n.strategyLongrecoveryscheduleOutcome,
            scientificBasis: 'Gardner et al. (2012) - Exercise habit formation',
          ),
          ScientificStrategy(
            title: l10n.strategyLongrecoverymindoseTitle,
            description: l10n.strategyLongrecoverymindoseDesc,
            howToImplement: l10n.strategyLongrecoverymindoseImpl,
            expectedOutcome: l10n.strategyLongrecoverymindoseOutcome,
            scientificBasis: 'Bickel et al. (2011) - Exercise dosage for muscle maintenance',
          ),
        ],
        scientificReference: '''McMaster et al. (2013) - Strength retention and decay rates
https://doi.org/10.1007/s40279-013-0031-3''',
      ));
    }

    return insights;
  }

  /// Analyze training frequency
  static List<AIInsight> _analyzeFrequency(double weeklyFrequency, AppLocalizations l10n) {
    final insights = <AIInsight>[];

    // Low frequency: less than 1 workout per week (too low for any progress)
    if (weeklyFrequency > 0 && weeklyFrequency < 1.0) {
      insights.add(AIInsight(
        type: InsightType.frequencyRecommendation,
        title: l10n.aiInsightLowFrequency,
        description: l10n.aiInsightLowFrequencyDesc(weeklyFrequency.toStringAsFixed(1)),
        recommendation: l10n.aiInsightLowFrequencyRec,
        priority: 2,
        data: {'currentFrequency': weeklyFrequency, 'recommendedFrequency': 3.0},
        detailedAnalysis: l10n.aiLowFrequencyAnalysis(
          weeklyFrequency.toStringAsFixed(1),
        ),
        dataPoints: [
          l10n.dataCurrentFrequency(weeklyFrequency.toStringAsFixed(1)),
          l10n.dataMinimumEffective,
          l10n.dataOptimalFrequency,
          l10n.dataAdaptationStatus,
          l10n.dataMPSCycle('72'),
        ],
        strategies: [
          ScientificStrategy(
            title: l10n.strategyLowfrequencyminviableTitle,
            description: l10n.strategyLowfrequencyminviableDesc,
            howToImplement: l10n.strategyLowfrequencyminviableImpl,
            expectedOutcome: l10n.strategyLowfrequencyminviableOutcome,
            scientificBasis: 'Schoenfeld et al. (2016) - Frequency and hypertrophy: A dose-response relationship',
          ),
          ScientificStrategy(
            title: l10n.strategyLowfrequencytimeefficientTitle,
            description: l10n.strategyLowfrequencytimeefficientDesc,
            howToImplement: l10n.strategyLowfrequencytimeefficientImpl,
            expectedOutcome: l10n.strategyLowfrequencytimeefficientOutcome,
            scientificBasis: 'Gentil et al. (2017) - Exercise selection and muscle activation',
          ),
        ],
        scientificReference: '''Dankel et al. (2017) - Training frequency and muscle growth
https://doi.org/10.1007/s40279-016-0543-8''',
      ));
    }
    // High frequency: more than 6 workouts per week (potential overtraining)
    else if (weeklyFrequency > 6.0) {
      insights.add(AIInsight(
        type: InsightType.frequencyRecommendation,
        title: l10n.aiInsightHighFrequency,
        description: l10n.aiInsightHighFrequencyDesc(weeklyFrequency.toStringAsFixed(1)),
        recommendation: l10n.aiInsightHighFrequencyRec,
        priority: 3,
        data: {'currentFrequency': weeklyFrequency, 'recommendedFrequency': 5.0},
        detailedAnalysis: l10n.aiHighFrequencyAnalysis(
          weeklyFrequency.toStringAsFixed(1),
        ),
        dataPoints: [
          l10n.dataCurrentFrequency(weeklyFrequency.toStringAsFixed(1)),
          l10n.dataOptimalFrequency,
          l10n.dataMaxBeneficial,
          l10n.dataRecoveryStatus,
          l10n.dataCNSFatigue,
        ],
        strategies: [
          ScientificStrategy(
            title: l10n.strategyHighfrequencyconsolidateTitle,
            description: l10n.strategyHighfrequencyconsolidateDesc,
            howToImplement: l10n.strategyHighfrequencyconsolidateImpl,
            expectedOutcome: l10n.strategyHighfrequencyconsolidateOutcome,
            scientificBasis: 'Schoenfeld et al. (2019) - Frequency and muscle hypertrophy: A meta-analysis',
          ),
          ScientificStrategy(
            title: l10n.strategyHighfrequencyrestdaysTitle,
            description: l10n.strategyHighfrequencyrestdaysDesc,
            howToImplement: l10n.strategyHighfrequencyrestdaysImpl,
            expectedOutcome: l10n.strategyHighfrequencyrestdaysOutcome,
            scientificBasis: 'Kellmann et al. (2018) - Recovery and Performance in Sport',
          ),
        ],
        scientificReference: '''Grgic et al. (2018) - Training frequency effects on strength
https://doi.org/10.1007/s40279-018-0872-x''',
      ));
    }

    return insights;
  }

  /// Detect training plateaus
  static List<AIInsight> _detectPlateaus(
    List<ExerciseActivity> activities,
    AppLocalizations l10n,
  ) {
    final insights = <AIInsight>[];

    if (activities.length >= 5) {
      final recentActivities = activities
          .where((a) => a.createdAt.isAfter(
              DateTime.now().subtract(const Duration(days: 30))))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (recentActivities.length >= 5) {
        final totalVolumes = recentActivities
            .map((a) => _calculateActivityVolume(a))
            .toList();
        final recentTrend = _calculateTrend(totalVolumes);

        if (recentTrend.abs() < 0.1) {
          // Less than 10% change over period
          insights.add(AIInsight(
            type: InsightType.plateauBreaker,
            title: l10n.aiInsightVolumePlateau,
            description: l10n.aiInsightVolumePlateauDesc,
            recommendation: l10n.aiInsightVolumePlateauRec,
            priority: 3,
            data: {'trend': recentTrend},
          ));
        }
      }
    }

    return insights;
  }

  /// Analyze potential form issues
  static List<AIInsight> _analyzeFormWarnings(
    List<ExerciseActivity> activities,
    AppLocalizations l10n,
    List<WorkoutTemplate> userTemplates,
  ) {
    final insights = <AIInsight>[];

    // Check for rapid weight increases that might indicate form breakdown
    final exerciseGroups = <String, List<ExerciseActivity>>{};
    for (final activity in activities) {
      exerciseGroups.putIfAbsent(activity.exerciseName, () => []).add(activity);
    }

    for (final entry in exerciseGroups.entries) {
      final exerciseName = entry.key;
      final exerciseActivities = entry.value
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Skip if less than 4 workouts (early progression phase)
      if (exerciseActivities.length < 4) continue;

      final recent = exerciseActivities.length >= 2
          ? exerciseActivities.sublist(exerciseActivities.length - 2)
          : exerciseActivities;
      final oldWeight = _getMaxWeight(recent[0]);
      final newWeight = _getMaxWeight(recent[1]);

      if (oldWeight > 0 && newWeight > oldWeight) {
        final increase = (newWeight - oldWeight) / oldWeight;
        final absoluteIncrease = newWeight - oldWeight;

        // Adaptive threshold based on weight and experience
        final isLowWeight = oldWeight < 20; // Low absolute weight
        final threshold = isLowWeight ? 0.40 : 0.25; // 40% for light weights, 25% for heavy

        // Only warn if both percentage AND absolute increase are significant
        if (increase > threshold && absoluteIncrease > 5) {
          // Find which templates contain this exercise
          final affectedTemplates = _findTemplatesWithExercise(exerciseName, userTemplates);

          insights.add(AIInsight(
            type: InsightType.formWarning,
            title: l10n.aiInsightLargeWeightJump,
            description: l10n.aiInsightLargeWeightJumpDesc(
                exerciseName, (increase * 100).round()),
            recommendation: l10n.aiInsightLargeWeightJumpRec,
            priority: 2,
            data: {
              'exercise': exerciseName,
              'increase': increase,
              'newWeight': newWeight,
              'absoluteIncrease': absoluteIncrease,
            },
            detailedAnalysis: l10n.aiWeightJumpAnalysis(
              (increase * 100).round().toString(),
              absoluteIncrease.toStringAsFixed(1),
            ),
            dataPoints: [
              l10n.dataPreviousWeight(oldWeight.toStringAsFixed(1)),
              l10n.dataCurrentWeight(newWeight.toStringAsFixed(1)),
              l10n.dataAbsoluteJump(absoluteIncrease.toStringAsFixed(1)),
              l10n.dataPercentageIncrease((increase * 100).round().toString()),
              l10n.dataSafeThreshold((threshold * 100).round().toString()),
              l10n.dataRiskFactors,
            ],
            strategies: [
              ScientificStrategy(
                title: l10n.strategyUseSmallerIncrementsTitle,
                description: l10n.strategyUseSmallerIncrementsDesc,
                howToImplement: l10n.strategyUseSmallerIncrementsHow,
                expectedOutcome: l10n.strategyUseSmallerIncrementsOutcome,
                scientificBasis: 'Kubo et al. (2010) - Tendon adaptation to mechanical loading',
              ),
              ScientificStrategy(
                title: l10n.strategyFocusRepQualityTitle,
                description: l10n.strategyFocusRepQualityDesc,
                howToImplement: l10n.strategyFocusRepQualityHow,
                expectedOutcome: l10n.strategyFocusRepQualityOutcome,
                scientificBasis: 'Cronin et al. (2001) - Velocity-based training for strength development',
              ),
              ScientificStrategy(
                title: l10n.strategyDeloadWeekTitle,
                description: l10n.strategyDeloadWeekDesc,
                howToImplement: l10n.strategyDeloadWeekHow,
                expectedOutcome: l10n.strategyDeloadWeekOutcome,
                scientificBasis: 'Croisier et al. (2008) - Strength training and injury prevention',
              ),
            ],
            scientificReference: '''Lauersen et al. (2014) - Strength training for injury prevention
https://doi.org/10.1136/bjsports-2013-092538''',
            // Actionable data
            affectedExercise: exerciseName,
            affectedTemplates: affectedTemplates.isNotEmpty ? affectedTemplates : null,
            actionType: affectedTemplates.isNotEmpty ? InsightActionType.replaceExercise : InsightActionType.none,
          ));
          break; // Solo un warning per form
        }
      }
    }

    return insights;
  }

  /// Helper per ottenere nome muscle group localizzato
  ///
  /// Uses [MuscleAbbreviationMapper] as SINGLE SOURCE OF TRUTH.
  /// Note: l10n parameter kept for API compatibility but displayNameIt is used.
  static String _getMuscleGroupName(String code, AppLocalizations l10n) {
    return MuscleAbbreviationMapper.getMuscleInfo(code)?.displayNameIt ?? code;
  }

  /// Get maximum weight used in an activity
  static double _getMaxWeight(ExerciseActivity activity) {
    double maxWeight = 0;
    for (final set in activity.sets) {
      if (set.done) {
        final weight = _parseWeight(set.weight);
        if (weight > maxWeight) {
          maxWeight = weight;
        }
      }
    }
    return maxWeight;
  }

  /// Calculate total volume for an activity
  static double _calculateActivityVolume(ExerciseActivity activity) {
    double volume = 0;
    for (final set in activity.sets) {
      if (set.done) {
        final weight = _parseWeight(set.weight);
        final reps = _parseReps(set.reps);
        volume += weight * reps;
      }
    }
    return volume;
  }

  /// Calculate trend in a series of values (improved with variance consideration)
  static double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    // Simple linear regression for better trend detection
    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final avgValue = sumY / n;

    if (avgValue == 0) return 0.0;

    // Return normalized trend
    return slope / avgValue;
  }

  /// Parse weight safely
  static double _parseWeight(dynamic weight) {
    if (weight == null) return 0.0;
    if (weight is double) return weight;
    if (weight is int) return weight.toDouble();
    if (weight is String) return double.tryParse(weight) ?? 0.0;
    return 0.0;
  }

  /// Parse reps safely
  static double _parseReps(dynamic reps) {
    if (reps == null) return 0.0;
    if (reps is double) return reps;
    if (reps is int) return reps.toDouble();
    if (reps is String) return double.tryParse(reps) ?? 0.0;
    return 0.0;
  }

  /// Get evidence-based strategies for breaking through plateaus
  static List<ScientificStrategy> _getPlateauBreakingStrategies(AppLocalizations l10n) {
    return [
      ScientificStrategy(
        title: l10n.strategyPlateauincreasevolumeTitle,
        description: l10n.strategyPlateauincreasevolumeDesc,
        howToImplement: l10n.strategyPlateauincreasevolumeImpl,
        expectedOutcome: l10n.strategyPlateauincreasevolumeOutcome,
        scientificBasis: 'Schoenfeld et al. (2017) - Dose-response relationship between weekly resistance training volume and increases in muscle mass',
      ),
      ScientificStrategy(
        title: l10n.strategyPlateauvaryrepsTitle,
        description: l10n.strategyPlateauvaryrepsDesc,
        howToImplement: l10n.strategyPlateauvaryrepsImpl,
        expectedOutcome: l10n.strategyPlateauvaryrepsOutcome,
        scientificBasis: 'Schoenfeld et al. (2021) - Hypertrophic Effects of Concentric vs. Eccentric Muscle Actions',
      ),
      ScientificStrategy(
        title: l10n.strategyPlateauadvancedtechniquesTitle,
        description: l10n.strategyPlateauadvancedtechniquesDesc,
        howToImplement: l10n.strategyPlateauadvancedtechniquesImpl,
        expectedOutcome: l10n.strategyPlateauadvancedtechniquesOutcome,
        scientificBasis: 'Fink et al. (2018) - Effects of drop set resistance training on acute stress indicators',
      ),
      ScientificStrategy(
        title: l10n.strategyPlateauchangeexercisesTitle,
        description: l10n.strategyPlateauchangeexercisesDesc,
        howToImplement: l10n.strategyPlateauchangeexercisesImpl,
        expectedOutcome: l10n.strategyPlateauchangeexercisesOutcome,
        scientificBasis: 'Fonseca et al. (2014) - Changes in exercises are more effective than in loading schemes to improve muscle strength',
      ),
      ScientificStrategy(
        title: l10n.strategyPlateaudeloadweekTitle,
        description: l10n.strategyPlateaudeloadweekDesc,
        howToImplement: l10n.strategyPlateaudeloadweekImpl,
        expectedOutcome: l10n.strategyPlateaudeloadweekOutcome,
        scientificBasis: 'Pritchard et al. (2015) - Effects of deloading in trained individuals',
      ),
    ];
  }

  /// Get strategies for muscle group imbalances
  static List<ScientificStrategy> _getMuscleBalanceStrategies(AppLocalizations l10n) {
    return [
      ScientificStrategy(
        title: l10n.strategyBalanceincreasefrequencyTitle,
        description: l10n.strategyBalanceincreasefrequencyDesc,
        howToImplement: l10n.strategyBalanceincreasefrequencyImpl,
        expectedOutcome: l10n.strategyBalanceincreasefrequencyOutcome,
        scientificBasis: 'Schoenfeld et al. (2019) - Effects of Resistance Training Frequency on Measures of Muscle Hypertrophy',
      ),
      ScientificStrategy(
        title: l10n.strategyBalanceprioritizeweakTitle,
        description: l10n.strategyBalanceprioritizeweakDesc,
        howToImplement: l10n.strategyBalanceprioritizeweakImpl,
        expectedOutcome: l10n.strategyBalanceprioritizeweakOutcome,
        scientificBasis: 'Simão et al. (2012) - Exercise order in resistance training',
      ),
      ScientificStrategy(
        title: l10n.strategyBalanceaddisolationTitle,
        description: l10n.strategyBalanceaddisolationDesc,
        howToImplement: l10n.strategyBalanceaddisolationImpl,
        expectedOutcome: l10n.strategyBalanceaddisolationOutcome,
        scientificBasis: 'Paoli et al. (2017) - Resistance Training with Single vs. Multi-joint Exercises',
      ),
    ];
  }

  /// Get strategies for recovery optimization
  static List<ScientificStrategy> _getRecoveryStrategies(AppLocalizations l10n) {
    return [
      ScientificStrategy(
        title: l10n.strategyRecoveryoptimizesleepTitle,
        description: l10n.strategyRecoveryoptimizesleepDesc,
        howToImplement: l10n.strategyRecoveryoptimizesleepImpl,
        expectedOutcome: l10n.strategyRecoveryoptimizesleepOutcome,
        scientificBasis: 'Dattilo et al. (2011) - Sleep and muscle recovery',
      ),
      ScientificStrategy(
        title: l10n.strategyRecoveryperiodizeTitle,
        description: l10n.strategyRecoveryperiodizeDesc,
        howToImplement: l10n.strategyRecoveryperiodizeImpl,
        expectedOutcome: l10n.strategyRecoveryperiodizeOutcome,
        scientificBasis: 'Williams et al. (2017) - Periodization strategies for athletes',
      ),
      ScientificStrategy(
        title: l10n.strategyRecoveryactiverecoveryTitle,
        description: l10n.strategyRecoveryactiverecoveryDesc,
        howToImplement: l10n.strategyRecoveryactiverecoveryImpl,
        expectedOutcome: l10n.strategyRecoveryactiverecoveryOutcome,
        scientificBasis: 'Nédélec et al. (2012) - Recovery in soccer',
      ),
    ];
  }

  /// Find templates containing a specific exercise
  static List<AffectedTemplate> _findTemplatesWithExercise(
    String exerciseName,
    List<WorkoutTemplate> templates,
  ) {
    final affectedTemplates = <AffectedTemplate>[];

    for (final template in templates) {
      final hasExercise = template.exercises.any(
        (ex) => ex.name.toLowerCase() == exerciseName.toLowerCase(),
      );

      if (hasExercise) {
        affectedTemplates.add(AffectedTemplate(
          templateId: template.id,
          templateName: template.name,
        ));
      }
    }

    return affectedTemplates;
  }
}
