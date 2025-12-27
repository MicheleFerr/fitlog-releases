import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/scientific_metrics_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_analyzer.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';

/// Types of insights
enum InsightType {
  achievement,  // Positive milestone reached
  warning,      // Potential issue detected
  suggestion,   // Improvement opportunity
  improvement,  // Performance improvement detected
  info,         // General information
  motivation,   // Motivational message
}

/// Priority levels for insights
enum InsightPriority {
  high,    // Must address immediately
  medium,  // Should address soon
  low,     // Nice to know
}

/// Training insight
class TrainingInsight {

  TrainingInsight({
    String? id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.recommendation,
    DateTime? generatedAt,
    this.metadata = const {},
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        generatedAt = generatedAt ?? DateTime.now();
  final String id;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String message;
  final String recommendation;
  final DateTime generatedAt;
  final Map<String, dynamic> metadata;

  /// Get icon for insight type
  String get icon {
    switch (type) {
      case InsightType.achievement:
      case InsightType.improvement:
        return '🏆';
      case InsightType.warning:
        return '⚠️';
      case InsightType.suggestion:
        return '💡';
      case InsightType.info:
        return 'ℹ️';
      case InsightType.motivation:
        return '💪';
    }
  }

  /// Get color name for UI
  String get colorName {
    switch (type) {
      case InsightType.achievement:
      case InsightType.improvement:
        return 'success';
      case InsightType.warning:
        return 'warning';
      case InsightType.suggestion:
        return 'info';
      case InsightType.info:
        return 'neutral';
      case InsightType.motivation:
        return 'primary';
    }
  }
}

/// Muscle group balance data
class MuscleGroupBalance {

  MuscleGroupBalance({
    required this.volumeDistribution,
    required this.idealDistribution,
    required this.imbalanceScores,
  });
  final Map<String, double> volumeDistribution;
  final Map<String, double> idealDistribution;
  final Map<String, double> imbalanceScores;

  /// Get most neglected muscle group
  String? get mostNeglected {
    if (imbalanceScores.isEmpty) return null;
    
    return imbalanceScores.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  /// Get overdeveloped muscle group
  String? get overdeveloped {
    if (imbalanceScores.isEmpty) return null;
    
    return imbalanceScores.entries
        .where((e) => e.value > 1.3) // 30% over ideal
        .map((e) => e.key)
        .firstOrNull;
  }

  /// Check if balanced (removed arbitrary thresholds)
  bool get isBalanced {
    // Removed - balance is subjective to goals
    return true;
  }
}

/// Service for generating training insights and recommendations
class InsightsEngine {
  /// Generate comprehensive insights from user data
  static List<TrainingInsight> generateInsights({
    required List<ExerciseActivity> activities,
    required List<PersonalRecord> recentPRs,
    required String userId,
  }) {
    final insights = <TrainingInsight>[];
    
    // Performance insights
    insights.addAll(_generatePerformanceInsights(activities));
    
    // Volume insights
    insights.addAll(_generateVolumeInsights(activities));
    
    // Frequency insights
    insights.addAll(_generateFrequencyInsights(activities));
    
    // PR insights
    insights.addAll(_generatePRInsights(recentPRs));
    
    // Muscle balance insights
    insights.addAll(_generateMuscleBalanceInsights(activities));

    // Scientific metrics insights (NEW)
    insights.addAll(_generateScientificMetricsInsights(activities));

    // Recovery insights
    insights.addAll(_generateRecoveryInsights(activities));
    
    // Motivational insights
    insights.addAll(_generateMotivationalInsights(activities, recentPRs));
    
    // Sort by priority
    insights.sort((a, b) {
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      return b.generatedAt.compareTo(a.generatedAt);
    });
    
    // Limit to top 10 insights
    return insights.take(10).toList();
  }

  /// Analyze muscle group balance
  static MuscleGroupBalance analyzeMuscleBalance(
    List<ExerciseActivity> activities,
  ) {
    // Calculate volume by muscle group
    final volumeByGroup = VolumeCalculator.calculateVolumeByMuscleGroup(activities);
    final totalVolume = volumeByGroup.values.fold(0.0, (sum, v) => sum + v);
    
    if (totalVolume == 0) {
      return MuscleGroupBalance(
        volumeDistribution: {},
        idealDistribution: {},
        imbalanceScores: {},
      );
    }
    
    // Calculate percentage distribution
    final distribution = <String, double>{};
    for (final entry in volumeByGroup.entries) {
      distribution[entry.key] = (entry.value / totalVolume) * 100;
    }
    
    // Define ideal distribution (can be customized)
    final ideal = <String, double>{
      'Chest': 15,
      'Back': 20,
      'Shoulders': 10,
      'Arms': 10,
      'Legs': 30,
      'Core': 10,
      'Other': 5,
    };
    
    // Calculate imbalance scores (actual/ideal ratio)
    final scores = <String, double>{};
    for (final group in ideal.keys) {
      final actual = distribution[group] ?? 0;
      final target = ideal[group]!;
      scores[group] = target > 0 ? actual / target : 0;
    }
    
    return MuscleGroupBalance(
      volumeDistribution: distribution,
      idealDistribution: ideal,
      imbalanceScores: scores,
    );
  }

  /// Generate training observations (not recommendations)
  static List<String> generateObservations({
    required List<ExerciseActivity> activities,
    required MuscleGroupBalance balance,
    required TrendAnalysis volumeTrend,
    required TrendAnalysis frequencyTrend,
  }) {
    final observations = <String>[];
    
    // Volume observations
    if (volumeTrend.type == TrendType.declining) {
      observations.add('Volume trend: Declining over recent period');
    } else if (volumeTrend.type == TrendType.improving) {
      observations.add('Volume trend: Increasing (${volumeTrend.percentageChange.toStringAsFixed(0)}%)');
    } else if (volumeTrend.type == TrendType.plateau) {
      observations.add('Volume trend: Stable over recent period');
    }
    
    // Frequency observations
    observations.add('Training frequency: ${frequencyTrend.currentValue.toStringAsFixed(0)} days/week average');
    
    // Balance observations
    if (balance.volumeDistribution.isNotEmpty) {
      final topGroup = balance.volumeDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      observations.add('Most trained: ${topGroup.key} (${topGroup.value.toStringAsFixed(0)}% of volume)');
    }
    
    // Last workout observation
    if (activities.isNotEmpty) {
      final daysSince = DateTime.now().difference(activities.first.createdAt).inDays;
      observations.add('Last workout: $daysSince days ago');
    }
    
    return observations;
  }

  // Private helper methods for generating specific insights
  
  static List<TrainingInsight> _generatePerformanceInsights(
    List<ExerciseActivity> activities,
  ) {
    final insights = <TrainingInsight>[];
    
    if (activities.isEmpty) return insights;
    
    // Group by exercise for analysis
    final exerciseGroups = <String, List<ExerciseActivity>>{};
    for (final activity in activities) {
      exerciseGroups[activity.exerciseId] ??= [];
      exerciseGroups[activity.exerciseId]!.add(activity);
    }
    
    // Analyze top 3 exercises
    final sortedExercises = exerciseGroups.entries
        .map((e) => MapEntry(e.key, e.value.length))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final exercise in sortedExercises.take(3)) {
      final exerciseActivities = exerciseGroups[exercise.key]!;
      final trend = TrendAnalyzer.analyzeStrengthTrend(activities, exercise.key);
      
      if (trend.type == TrendType.improving && trend.isSignificant) {
        // Calculate actual improvement in kg
        final recentActivities = exerciseActivities.take(5).toList();
        final oldActivities = exerciseActivities.skip(10).take(5).toList();
        
        double recentMax = 0;
        double oldMax = 0;
        
        for (final activity in recentActivities) {
          for (final set in activity.sets.where((s) => s.done)) {
            final weight = double.tryParse(set.weight) ?? 0.0;
            if (weight > recentMax) recentMax = weight;
          }
        }
        
        for (final activity in oldActivities) {
          for (final set in activity.sets.where((s) => s.done)) {
            final weight = double.tryParse(set.weight) ?? 0.0;
            if (weight > oldMax) oldMax = weight;
          }
        }
        
        final improvement = recentMax - oldMax;
        
        insights.add(TrainingInsight(
          type: InsightType.achievement,
          priority: InsightPriority.medium,
          title: 'insightStrengthGainsTitle',
          message: 'insightStrengthGainsMessage',
          recommendation: 'insightStrengthGainsRecommendation',
          metadata: {
            'exerciseId': exercise.key,
            'exerciseName': exerciseActivities.first.exerciseName,
            'improvement': improvement.toStringAsFixed(1),
            'previousMax': oldMax.toStringAsFixed(1),
            'currentMax': recentMax.toStringAsFixed(1),
            'percentageChange': trend.percentageChange.toStringAsFixed(1),
            'daysSince': exerciseActivities.first.createdAt.difference(exerciseActivities[10].createdAt).inDays.toString(),
          },
        ));
      } else if (trend.type == TrendType.plateau) {
        final plateau = TrendAnalyzer.detectPlateau(activities, exercise.key);
        if (plateau.isPlateaued && plateau.duration > 14) {
          // Get last working weight
          double lastWeight = 0;
          int lastReps = 0;
          for (final activity in exerciseActivities.take(3)) {
            for (final set in activity.sets.where((s) => s.done)) {
              final weight = double.tryParse(set.weight) ?? 0.0;
              if (weight > 0) {
                lastWeight = weight;
                lastReps = int.tryParse(set.reps) ?? 0;
                break;
              }
            }
            if (lastWeight > 0) break;
          }
          
          insights.add(TrainingInsight(
            type: InsightType.info,
            priority: InsightPriority.medium,
            title: 'insightPlateauTitle',
            message: 'insightPlateauMessage',
            recommendation: 'insightPlateauRecommendation',
            metadata: {
              'exerciseId': exercise.key,
              'exerciseName': exerciseActivities.first.exerciseName,
              'duration': plateau.duration.toString(),
              'lastWeight': lastWeight.toStringAsFixed(1),
              'lastReps': lastReps.toString(),
              'totalSets': exerciseActivities.take(5).expand((a) => a.sets).where((s) => s.done).length.toString(),
            },
          ));
        }
      }
    }
    
    return insights;
  }

  static List<TrainingInsight> _generateVolumeInsights(
    List<ExerciseActivity> activities,
  ) {
    final insights = <TrainingInsight>[];
    
    if (activities.isEmpty) return insights;
    
    final volumeProgression = VolumeCalculator.calculateProgression(activities);
    
    // Calculate actual volume in kg
    final thisWeekVolume = volumeProgression.currentWeekVolume;
    final lastWeekVolume = thisWeekVolume / (1 + volumeProgression.weeklyChange / 100);
    final volumeDiff = thisWeekVolume - lastWeekVolume;
    
    // Show significant volume changes as neutral observations
    if (volumeProgression.weeklyChange.abs() > 15) {
      final isIncrease = volumeProgression.weeklyChange > 0;
      insights.add(TrainingInsight(
        type: InsightType.info,
        priority: InsightPriority.low,
        title: isIncrease ? 'insightVolumeSurgeTitle' : 'insightVolumeDropTitle',
        message: isIncrease ? 'insightVolumeSurgeMessage' : 'insightVolumeDropMessage',
        recommendation: 'insightVolumeObservation',
        metadata: {
          'weeklyChange': volumeProgression.weeklyChange.abs().toStringAsFixed(0),
          'currentVolume': (thisWeekVolume / 1000).toStringAsFixed(1),
          'previousVolume': (lastWeekVolume / 1000).toStringAsFixed(1),
          'volumeDiff': (volumeDiff.abs() / 1000).toStringAsFixed(1),
        },
      ));
    }
    
    if (volumeProgression.isPlateau) {
      // Calculate specific suggestions
      final avgWeight = activities.take(10)
          .expand((a) => a.sets)
          .where((s) => s.done)
          .map((s) => double.tryParse(s.weight) ?? 0.0)
          .where((w) => w > 0)
          .fold(0.0, (sum, w) => sum + w) / 
          math.max(1, activities.take(10).expand((a) => a.sets).where((s) => s.done).length);
      
      insights.add(TrainingInsight(
        type: InsightType.info,
        priority: InsightPriority.low,
        title: 'insightVolumePlateauTitle',
        message: 'insightVolumePlateauMessage',
        recommendation: 'insightVolumeObservation',
        metadata: {
          'weeksSame': '2+',
          'currentVolume': (thisWeekVolume / 1000).toStringAsFixed(1),
          'avgSetsPerWorkout': (activities.take(7).expand((a) => a.sets).length / math.max(1, 7)).toStringAsFixed(0),
        },
      ));
    }
    
    return insights;
  }

  static List<TrainingInsight> _generateFrequencyInsights(
    List<ExerciseActivity> activities,
  ) {
    final insights = <TrainingInsight>[];
    
    if (activities.isEmpty) return insights;
    
    // Calculate workout frequency with specific dates
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentActivities = activities.where((a) => a.createdAt.isAfter(thirtyDaysAgo));
    
    final workoutDays = recentActivities
        .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
        .toSet()
        .length;
    
    final avgPerWeek = (workoutDays / 4.3).round(); // 30 days ≈ 4.3 weeks
    
    // Calculate workout pattern (which days)
    final dayOfWeekCount = <int, int>{};
    for (final activity in recentActivities) {
      final day = activity.createdAt.weekday;
      dayOfWeekCount[day] = (dayOfWeekCount[day] ?? 0) + 1;
    }
    
    final mostCommonDay = dayOfWeekCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // Show frequency as neutral observation, not judgment
    insights.add(TrainingInsight(
      type: InsightType.info,
      priority: InsightPriority.low,
      title: 'insightFrequencyTitle',
      message: 'insightFrequencyMessage',
      recommendation: 'insightFrequencyObservation',
      metadata: {
        'avgPerWeek': avgPerWeek.toString(),
        'totalDays': workoutDays.toString(),
        'favoriteDay': _getDayName(mostCommonDay),
        'mostCommonTime': _getMostCommonWorkoutTime(recentActivities),
        'consecutiveDays': _findMaxConsecutiveDays(activities).toString(),
      },
    ));
    
    // Check for missed workouts with specific date
    final daysSinceLastWorkout = activities.isNotEmpty
        ? DateTime.now().difference(activities.first.createdAt).inDays
        : 999;
    
    if (daysSinceLastWorkout > 7) {
      final lastWorkoutDate = activities.isNotEmpty 
          ? activities.first.createdAt
          : DateTime.now();
      
      // Calculate recommended return weight
      double avgWeight = 0;
      if (activities.isNotEmpty) {
        final weights = activities.take(5)
            .expand((a) => a.sets)
            .where((s) => s.done)
            .map((s) => double.tryParse(s.weight) ?? 0.0)
            .where((w) => w > 0)
            .toList();
        if (weights.isNotEmpty) {
          avgWeight = weights.reduce((a, b) => a + b) / weights.length;
        }
      }
      
      insights.add(TrainingInsight(
        type: InsightType.info,
        priority: InsightPriority.medium,
        title: 'insightExtendedBreakTitle',
        message: 'insightExtendedBreakMessage',
        recommendation: 'insightBreakObservation',
        metadata: {
          'daysSince': daysSinceLastWorkout.toString(),
          'lastDate': '${lastWorkoutDate.day}/${lastWorkoutDate.month}',
          'lastExercise': activities.first.exerciseName,
          'lastWeight': avgWeight > 0 ? avgWeight.toStringAsFixed(1) : 'N/A',
        },
      ));
    }
    
    return insights;
  }
  
  static int _findMaxConsecutiveDays(List<ExerciseActivity> activities) {
    if (activities.isEmpty) return 0;
    
    final dates = activities
        .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
        .toSet()
        .toList()
      ..sort();
    
    int maxConsecutive = 1;
    int currentConsecutive = 1;
    
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        currentConsecutive++;
        maxConsecutive = math.max(maxConsecutive, currentConsecutive);
      } else {
        currentConsecutive = 1;
      }
    }
    
    return maxConsecutive;
  }
  
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
  
  static String _getMostCommonWorkoutTime(Iterable<ExerciseActivity> activities) {
    if (activities.isEmpty) return 'N/A';
    
    final hourCounts = <int, int>{};
    for (final activity in activities) {
      final hour = activity.createdAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    if (hourCounts.isEmpty) return 'N/A';
    
    final mostCommon = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    if (mostCommon < 6) return 'Early morning';
    if (mostCommon < 12) return 'Morning';
    if (mostCommon < 17) return 'Afternoon';
    if (mostCommon < 21) return 'Evening';
    return 'Night';
  }

  static List<TrainingInsight> _generatePRInsights(
    List<PersonalRecord> recentPRs,
  ) {
    final insights = <TrainingInsight>[];
    
    if (recentPRs.isEmpty) {
      insights.add(TrainingInsight(
        type: InsightType.info,
        priority: InsightPriority.low,
        title: 'insightNoPRsTitle',
        message: 'insightNoPRsMessage',
        recommendation: 'insightNoPRsObservation',
        metadata: {
          'totalWorkouts': '0',
        },
      ));
      return insights;
    }
    
    // Celebrate recent PRs with specific details
    final lastWeekPRs = recentPRs.where((pr) {
      return DateTime.now().difference(pr.achievedAt).inDays <= 7;
    }).toList();
    
    if (lastWeekPRs.isNotEmpty) {
      // Get best PR details
      final bestPR = lastWeekPRs.first;
      final prTypes = lastWeekPRs.map((pr) => pr.type.name).toSet();
      
      String improvement = '';
      if (bestPR.previousValue != null && bestPR.previousValue! > 0) {
        final increase = ((bestPR.value - bestPR.previousValue!) / bestPR.previousValue! * 100);
        improvement = increase.toStringAsFixed(1);
      }
      
      insights.add(TrainingInsight(
        type: InsightType.achievement,
        priority: InsightPriority.high,
        title: 'insightPRWeekTitle',
        message: 'insightPRWeekMessage',
        recommendation: 'insightPRObservation',
        metadata: {
          'count': lastWeekPRs.length.toString(),
          'types': prTypes.join(', '),
          'bestExercise': bestPR.exerciseName,
          'bestValue': bestPR.value.toStringAsFixed(1),
          'unit': 'kg',
          'previousValue': bestPR.previousValue?.toStringAsFixed(1) ?? 'N/A',
          'date': '${bestPR.achievedAt.day}/${bestPR.achievedAt.month}',
        },
      ));
    }
    
    // Check PR drought with specific suggestions
    final daysSinceLastPR = recentPRs.isNotEmpty
        ? DateTime.now().difference(recentPRs.first.achievedAt).inDays
        : 999;
    
    if (daysSinceLastPR > 30) {
      // Find exercises close to PR
      final lastPR = recentPRs.first;
      
      insights.add(TrainingInsight(
        type: InsightType.info,
        priority: InsightPriority.low,
        title: 'insightPRHistoryTitle',
        message: 'insightPRHistoryMessage',
        recommendation: 'insightPRObservation',
        metadata: {
          'daysSince': daysSinceLastPR.toString(),
          'lastPRExercise': lastPR.exerciseName,
          'lastPRValue': lastPR.value.toStringAsFixed(1),
          'lastPRDate': '${lastPR.achievedAt.day}/${lastPR.achievedAt.month}',
          'unit': 'kg',
        },
      ));
    }
    
    return insights;
  }

  static List<TrainingInsight> _generateMuscleBalanceInsights(
    List<ExerciseActivity> activities,
  ) {
    final insights = <TrainingInsight>[];
    
    if (activities.isEmpty) return insights;
    
    final balance = analyzeMuscleBalance(activities);
    
    if (!balance.isBalanced) {
      final neglected = balance.mostNeglected;
      if (neglected != null && balance.imbalanceScores[neglected]! < 0.5) {
        // Show distribution data only
        final currentVolume = balance.volumeDistribution[neglected] ?? 0;
        
        insights.add(TrainingInsight(
          type: InsightType.info,
          priority: InsightPriority.medium,
          title: 'insightMuscleDistributionTitle',
          message: 'insightMuscleDistributionMessage',
          recommendation: 'insightDistributionObservation',
          metadata: {
            'muscleGroup': neglected,
            'currentPercentage': currentVolume.toStringAsFixed(1),
            'totalGroups': balance.volumeDistribution.length.toString(),
            'lowestGroup': neglected,
            'highestGroup': balance.volumeDistribution.entries
                .reduce((a, b) => a.value > b.value ? a : b).key,
          },
        ));
      }
      
      final overdeveloped = balance.overdeveloped;
      if (overdeveloped != null) {
        final currentVolume = balance.volumeDistribution[overdeveloped] ?? 0;
        final excess = ((balance.imbalanceScores[overdeveloped]! - 1) * 100);
        
        // Removed - no longer giving training advice
      }
    } else {
      // Calculate distribution details
      final topGroup = balance.volumeDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      insights.add(TrainingInsight(
        type: InsightType.info,
        priority: InsightPriority.low,
        title: 'insightBalanceTitle',
        message: 'insightBalanceMessage',
        recommendation: 'insightBalanceObservation',
        metadata: {
          'topGroup': topGroup.key,
          'topPercentage': topGroup.value.toStringAsFixed(1),
          'groups': balance.volumeDistribution.length.toString(),
          'distribution': balance.volumeDistribution.entries
              .map((e) => '${e.key}: ${e.value.toStringAsFixed(0)}%')
              .join(', '),
        },
      ));
    }

    return insights;
  }

  static List<TrainingInsight> _generateRecoveryInsights(
    List<ExerciseActivity> activities,
  ) {
    final insights = <TrainingInsight>[];
    
    if (activities.isEmpty) return insights;
    
    // Check for overtraining signs with specific metrics
    final lastWeek = activities.where((a) {
      return DateTime.now().difference(a.createdAt).inDays <= 7;
    }).toList();
    
    final previousWeek = activities.where((a) {
      final days = DateTime.now().difference(a.createdAt).inDays;
      return days > 7 && days <= 14;
    }).toList();
    
    if (lastWeek.length > 6) {
      // Calculate total volume and intensity
      final thisWeekVolume = lastWeek.fold(0.0, (sum, a) => 
          sum + VolumeCalculator.calculateTotalVolume(a.sets));
      final lastWeekVolume = previousWeek.fold(0.0, (sum, a) => 
          sum + VolumeCalculator.calculateTotalVolume(a.sets));
      
      final avgEffort = lastWeek
          .expand((a) => a.sets)
          .where((s) => s.done)
          .map((s) => s.effort)
          .fold(0, (sum, e) => sum + e) / 
          math.max(1, lastWeek.expand((a) => a.sets).where((s) => s.done).length);
      
      // Show high volume/frequency as observation only
      if (lastWeek.length >= 6 || thisWeekVolume > lastWeekVolume * 1.3) {
        insights.add(TrainingInsight(
          type: InsightType.info,
          priority: InsightPriority.medium,
          title: 'insightHighActivityTitle',
          message: 'insightHighActivityMessage',
          recommendation: 'insightActivityObservation',
          metadata: {
            'workoutCount': lastWeek.length.toString(),
            'currentVolume': (thisWeekVolume / 1000).toStringAsFixed(1),
            'previousVolume': (lastWeekVolume / 1000).toStringAsFixed(1),
            'restDays': (7 - lastWeek.length).toString(),
            'volumeChange': ((thisWeekVolume - lastWeekVolume) / lastWeekVolume * 100).toStringAsFixed(0),
          },
        ));
      }
    }
    
    // Check rest between similar muscle groups with specific recovery times
    // **Uses SSOT**: MuscleAbbreviationMapper.categorizeExerciseByName
    final muscleGroupDates = <String, DateTime>{};
    for (final activity in activities.take(20)) {
      final group = MuscleAbbreviationMapper.categorizeExerciseByName(
        activity.exerciseName,
      );
      if (!muscleGroupDates.containsKey(group) ||
          activity.createdAt.isAfter(muscleGroupDates[group]!)) {
        muscleGroupDates[group] = activity.createdAt;
      }
    }
    
    for (final entry in muscleGroupDates.entries) {
      final hoursSinceTraining = DateTime.now().difference(entry.value).inHours;
      if (hoursSinceTraining < 48) {
        final recoveryHours = _getRecoveryTime(entry.key);
        final remainingHours = math.max(0, recoveryHours - hoursSinceTraining);
        
        insights.add(TrainingInsight(
          type: InsightType.info,
          priority: InsightPriority.low,
          title: 'insightRecentActivityTitle',
          message: 'insightRecentActivityMessage',
          recommendation: 'insightRecentObservation',
          metadata: {
            'muscleGroup': entry.key,
            'hoursSince': hoursSinceTraining.toString(),
            'daysSince': (hoursSinceTraining / 24).toStringAsFixed(1),
            'lastDate': '${entry.value.day}/${entry.value.month}',
          },
        ));
        break; // Only show one recovery insight
      }
    }
    
    return insights;
  }
  
  static int _getRecoveryTime(String muscleGroup) {
    // Removed - recovery is individual
    return 48; // Default fallback only for calculation
  }

  static List<TrainingInsight> _generateMotivationalInsights(
    List<ExerciseActivity> activities,
    List<PersonalRecord> recentPRs,
  ) {
    final insights = <TrainingInsight>[];
    
    // Calculate workout streak with dates
    final uniqueDates = activities
        .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
        .toSet()
        .toList()
      ..sort();
    
    var currentStreak = 0;
    DateTime? streakStartDate;
    if (uniqueDates.isNotEmpty) {
      var lastDate = uniqueDates.last;
      currentStreak = 1;
      streakStartDate = lastDate;
      
      for (var i = uniqueDates.length - 2; i >= 0; i--) {
        if (lastDate.difference(uniqueDates[i]).inDays == 1) {
          currentStreak++;
          streakStartDate = uniqueDates[i];
          lastDate = uniqueDates[i];
        } else {
          break;
        }
      }
    }
    
    if (currentStreak >= 3) {
      insights.add(TrainingInsight(
        type: InsightType.achievement,
        priority: InsightPriority.low,
        title: 'insightStreakTitle',
        message: 'insightStreakMessage',
        recommendation: 'insightStreakObservation',
        metadata: {
          'streak': currentStreak.toString(),
          'startDate': streakStartDate != null ? 
              '${streakStartDate.day}/${streakStartDate.month}' : '',
          'endDate': uniqueDates.isNotEmpty ? 
              '${uniqueDates.last.day}/${uniqueDates.last.month}' : '',
        },
      ));
    }
    
    // Total volume milestone with comparison
    final totalVolume = activities.fold(0.0, (sum, a) {
      return sum + VolumeCalculator.calculateTotalVolume(a.sets);
    });
    
    if (totalVolume > 50000) { // 50 tons milestone
      final tons = totalVolume / 1000;
      final workouts = activities
          .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
          .toSet()
          .length;
      
      insights.add(TrainingInsight(
        type: InsightType.achievement,
        priority: InsightPriority.low,
        title: 'insightVolumeMilestoneTitle',
        message: 'insightVolumeMilestoneMessage',
        recommendation: 'insightVolumeObservation',
        metadata: {
          'totalTons': tons.toStringAsFixed(1),
          'totalKg': totalVolume.toStringAsFixed(0),
          'workouts': workouts.toString(),
          'avgPerWorkout': (tons / math.max(1, workouts)).toStringAsFixed(2),
          'periodDays': activities.isNotEmpty ? 
              DateTime.now().difference(activities.last.createdAt).inDays.toString() : '0',
        },
      ));
    }
    
    // PR celebration with specifics
    if (recentPRs.length >= 3) {
      final prsByType = <PRType, int>{};
      for (final pr in recentPRs) {
        prsByType[pr.type] = (prsByType[pr.type] ?? 0) + 1;
      }
      
      final uniqueExercises = recentPRs.map((pr) => pr.exerciseName).toSet();
      
      insights.add(TrainingInsight(
        type: InsightType.achievement,
        priority: InsightPriority.medium,
        title: 'insightMultiplePRsTitle',
        message: 'insightMultiplePRsMessage',
        recommendation: 'insightPRsObservation',
        metadata: {
          'totalPRs': recentPRs.length.toString(),
          'uniqueExercises': uniqueExercises.length.toString(),
          'exercises': uniqueExercises.take(3).join(', '),
          'periodDays': recentPRs.isNotEmpty ? 
              DateTime.now().difference(recentPRs.last.achievedAt).inDays.toString() : '0',
        },
      ));
    }
    
    // Show training summary as observation
    if (activities.isNotEmpty) {
      final last30Days = activities.where((a) => 
          DateTime.now().difference(a.createdAt).inDays <= 30).toList();
      
      if (last30Days.length >= 8) {
        final uniqueDays = last30Days
            .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
            .toSet()
            .length;
        final totalSets = last30Days.expand((a) => a.sets).where((s) => s.done).length;
        
        insights.add(TrainingInsight(
          type: InsightType.info,
          priority: InsightPriority.low,
          title: 'insightMonthlySummaryTitle',
          message: 'insightMonthlySummaryMessage',
          recommendation: 'insightSummaryObservation',
          metadata: {
            'workouts30Days': uniqueDays.toString(),
            'totalSets': totalSets.toString(),
            'avgSetsPerWorkout': (totalSets / math.max(1, uniqueDays)).toStringAsFixed(0),
            'totalExercises': last30Days.length.toString(),
          },
        ));
      }
    }
    
    return insights;
  }

  /// Generate insights from scientific metrics (Tier-1)
  ///
  /// Based on peer-reviewed research:
  /// - Progressive Overload (Kraemer & Ratamess, 2004)
  /// - Volume Load Index (Schoenfeld et al., 2017)
  /// - Relative Intensity (Reynolds et al., 2006)
  static List<TrainingInsight> _generateScientificMetricsInsights(
    List<ExerciseActivity> activities,
  ) {
    final insights = <TrainingInsight>[];

    if (activities.isEmpty) return insights;

    // 1. PROGRESSIVE OVERLOAD ANALYSIS
    // Group by exercise and check recent progression
    final exerciseGroups = <String, List<ExerciseActivity>>{};
    for (final activity in activities) {
      exerciseGroups[activity.exerciseId] ??= [];
      exerciseGroups[activity.exerciseId]!.add(activity);
    }

    for (final entry in exerciseGroups.entries.take(3)) {
      final exerciseActivities = entry.value;
      if (exerciseActivities.length < 2) continue;

      final current = exerciseActivities.take(1).toList();
      final previous = exerciseActivities.skip(1).take(1).toList();

      final overload = ScientificMetricsService.calculateProgressiveOverload(
        currentSession: current,
        previousSession: previous,
        exerciseId: entry.key,
      );

      if (!overload.hasData) continue;

      // Generate insight based on overload
      if (overload.overloadPercent < 0) {
        insights.add(TrainingInsight(
          type: InsightType.warning,
          priority: InsightPriority.medium,
          title: 'insightProgressiveOverloadRegressionTitle',
          message: 'insightProgressiveOverloadRegressionMessage',
          recommendation: 'insightProgressiveOverloadRegressionRec',
          metadata: {
            'exerciseName': overload.exerciseName,
            'overloadPercent': overload.overloadPercent.abs().toStringAsFixed(1),
            'currentVolume': (overload.currentVolume / 1000).toStringAsFixed(1),
            'previousVolume': (overload.previousVolume / 1000).toStringAsFixed(1),
            'reference': 'Kraemer & Ratamess (2004)',
          },
        ));
      } else if (overload.overloadPercent > 10) {
        insights.add(TrainingInsight(
          type: InsightType.warning,
          priority: InsightPriority.high,
          title: 'insightProgressiveOverloadExcessiveTitle',
          message: 'insightProgressiveOverloadExcessiveMessage',
          recommendation: 'insightProgressiveOverloadExcessiveRec',
          metadata: {
            'exerciseName': overload.exerciseName,
            'overloadPercent': overload.overloadPercent.toStringAsFixed(1),
            'currentVolume': (overload.currentVolume / 1000).toStringAsFixed(1),
            'reference': 'ACSM (2009)',
          },
        ));
      } else if (overload.isOptimal) {
        insights.add(TrainingInsight(
          type: InsightType.achievement,
          priority: InsightPriority.low,
          title: 'insightProgressiveOverloadOptimalTitle',
          message: 'insightProgressiveOverloadOptimalMessage',
          recommendation: 'insightProgressiveOverloadOptimalRec',
          metadata: {
            'exerciseName': overload.exerciseName,
            'overloadPercent': overload.overloadPercent.toStringAsFixed(1),
            'reference': 'Kraemer & Ratamess (2004)',
          },
        ));
      }
    }

    // 2. VOLUME LOAD INDEX ANALYSIS
    final lastWeek = activities.where((a) {
      return DateTime.now().difference(a.createdAt).inDays <= 7;
    }).toList();

    if (lastWeek.isNotEmpty) {
      final volumeLoads = ScientificMetricsService.calculateVolumeLoadIndex(lastWeek);

      for (final entry in volumeLoads.entries) {
        final muscleGroup = entry.key;
        final result = entry.value;

        // Check against hypertrophy standards (most common goal)
        if (result.totalSets < 10) {
          insights.add(TrainingInsight(
            type: InsightType.info,
            priority: InsightPriority.medium,
            title: 'insightVolumeLowTitle',
            message: 'insightVolumeLowMessage',
            recommendation: 'insightVolumeLowRec',
            metadata: {
              'muscleGroup': muscleGroup,
              'currentSets': result.totalSets.toString(),
              'targetMin': '10-12',
              'reference': 'Schoenfeld et al. (2017)',
            },
          ));
        } else if (result.totalSets > 25) {
          insights.add(TrainingInsight(
            type: InsightType.warning,
            priority: InsightPriority.medium,
            title: 'insightVolumeExcessiveTitle',
            message: 'insightVolumeExcessiveMessage',
            recommendation: 'insightVolumeExcessiveRec',
            metadata: {
              'muscleGroup': muscleGroup,
              'currentSets': result.totalSets.toString(),
              'maxRecommended': '25',
              'reference': 'Schoenfeld et al. (2017)',
            },
          ));
        }
      }
    }

    // 3. RELATIVE INTENSITY ANALYSIS
    // Check recent working sets for intensity
    for (final activity in activities.take(5)) {
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup).take(1)) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.actualReps ?? set.reps) ?? 0;

        if (weight > 0 && reps > 0 && reps <= 15) {
          final intensity = ScientificMetricsService.calculateRelativeIntensity(
            weight: weight,
            reps: reps,
          );

          if (!intensity.isValid) continue;

          // Generate insight if intensity doesn't match common goals
          if (intensity.percentOf1RM < 67) {
            insights.add(TrainingInsight(
              type: InsightType.info,
              priority: InsightPriority.low,
              title: 'insightIntensityLowTitle',
              message: 'insightIntensityLowMessage',
              recommendation: 'insightIntensityLowRec',
              metadata: {
                'exerciseName': activity.exerciseName,
                'percentOf1RM': intensity.percentOf1RM.toStringAsFixed(0),
                'reps': reps.toString(),
                'weight': weight.toStringAsFixed(1),
                'formula': intensity.formula,
                'reference': 'Reynolds et al. (2006)',
              },
            ));
            break; // One intensity insight is enough
          }
        }
      }
    }

    // 4. PUSH:PULL BALANCE (Scientific Ratio)
    final pushPull = MuscleBalanceAnalyzer.analyzePushPullBalance(activities);
    if (!pushPull.isBalanced && (pushPull.pushSets > 0 || pushPull.pullSets > 0)) {
      insights.add(TrainingInsight(
        type: InsightType.info,
        priority: InsightPriority.medium,
        title: 'insightPushPullImbalanceTitle',
        message: 'insightPushPullImbalanceMessage',
        recommendation: 'insightPushPullImbalanceRec',
        metadata: {
          'ratio': pushPull.ratio.toStringAsFixed(2),
          'pushSets': pushPull.pushSets.toString(),
          'pullSets': pushPull.pullSets.toString(),
          'targetRange': '0.8-1.2',
          'feedback': MuscleBalanceAnalyzer.getPushPullFeedback(pushPull.ratio),
          'reference': 'Boyle (2016)',
        },
      ));
    }

    // 5. QUAD:HAMSTRING BALANCE (Injury Prevention)
    final quadHam = MuscleBalanceAnalyzer.analyzeQuadHamstringBalance(activities);
    if (quadHam.isHighRisk) {
      insights.add(TrainingInsight(
        type: InsightType.warning,
        priority: InsightPriority.high,
        title: 'insightQuadHamHighRiskTitle',
        message: 'insightQuadHamHighRiskMessage',
        recommendation: 'insightQuadHamHighRiskRec',
        metadata: {
          'ratio': quadHam.ratio.toStringAsFixed(2),
          'quadSets': quadHam.quadSets.toString(),
          'hamSets': quadHam.hamstringSets.toString(),
          'riskMultiplier': '17x',
          'reference': 'Croisier et al. (2008)',
        },
      ));
    }

    return insights;
  }

  // NOTE: _categorizeExercise REMOVED - use MuscleAbbreviationMapper.categorizeExerciseByName
}