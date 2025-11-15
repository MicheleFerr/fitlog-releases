/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/analyzers
/// 🎯 Feature: ai_coach
/// 🔧 Type: analyzer
///
/// Mobility Analyzer - detects lack of mobility/flexibility work
/// NEW analyzer addressing blind spot in original AI Coach design
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/insight_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Analyzes mobility and flexibility work frequency
///
/// Based on scientific evidence:
/// - Behm et al. (2016): Flexibility and range of motion for injury prevention
/// - Page (2012): Current concepts in muscle stretching for exercise and rehabilitation
/// - Konrad & Tilp (2014): Increased ROM from muscle stretching
///
/// Detection criteria:
/// - Mobility exercises: Stretching, yoga, foam rolling, dynamic mobility
/// - Recommended frequency: 2-3 sessions per week minimum
/// - Alert if < 1 mobility session in last 2 weeks
class MobilityAnalyzer implements InsightAnalyzer {
  @override
  InsightType get type => InsightType.mobility;

  @override
  int get basePriority => 4; // Medium-low priority - preventative

  @override
  bool shouldAnalyze(UserContext context) {
    // Available for all tiers (injury prevention is universal)
    return true;
  }

  @override
  Future<AIInsight?> analyze(
    List<Workout> workouts,
    UserContext context,
  ) async {
    // Require at least 2 weeks of data
    if (workouts.length < 4) return null;

    // Filter last 2 weeks
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final recentWorkouts = workouts.where(
      (w) => w.createdAt.isAfter(twoWeeksAgo),
    ).toList();

    if (recentWorkouts.isEmpty) return null;

    // Count mobility/flexibility sessions and exercises
    int mobilitySessions = 0;
    int mobilityExercises = 0;
    final mobilityExerciseNames = <String>[];

    for (final workout in recentWorkouts) {
      bool hasMobility = false;

      for (final exercise in workout.exercises) {
        if (_isMobilityExercise(exercise.name)) {
          mobilityExercises++;
          hasMobility = true;
          if (!mobilityExerciseNames.contains(exercise.name)) {
            mobilityExerciseNames.add(exercise.name);
          }
        }
      }

      if (hasMobility) {
        mobilitySessions++;
      }
    }

    // Alert if < 2 mobility sessions in 2 weeks (below recommended minimum)
    if (mobilitySessions < 2) {
      return _createMobilityInsight(
        mobilitySessions,
        mobilityExercises,
        mobilityExerciseNames,
      );
    }

    return null; // Mobility work is adequate
  }

  /// Check if exercise is mobility/flexibility focused
  bool _isMobilityExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();

    // Stretching patterns
    if (name.contains('stretch') ||
        name.contains('stretching') ||
        name.contains('flexibility')) {
      return true;
    }

    // Yoga/Pilates patterns
    if (name.contains('yoga') ||
        name.contains('pilates') ||
        name.contains('downward dog') ||
        name.contains('cat cow') ||
        name.contains('child pose')) {
      return true;
    }

    // Foam rolling/SMR patterns
    if (name.contains('foam roll') ||
        name.contains('roller') ||
        name.contains('smr') ||
        name.contains('self-myofascial')) {
      return true;
    }

    // Dynamic mobility patterns
    if (name.contains('mobility') ||
        name.contains('hip circle') ||
        name.contains('shoulder circle') ||
        name.contains('arm circle') ||
        name.contains('leg swing') ||
        name.contains('dynamic warm')) {
      return true;
    }

    // Specific mobility exercises
    if (name.contains('90/90') ||
        name.contains('pigeon') ||
        name.contains('couch stretch') ||
        name.contains('world greatest stretch') ||
        name.contains('frog stretch')) {
      return true;
    }

    return false;
  }

  /// Create mobility deficit insight
  AIInsight _createMobilityInsight(
    int mobilitySessions,
    int mobilityExercises,
    List<String> mobilityExerciseNames,
  ) {
    final sessionsDeficit = 2 - mobilitySessions;

    return AIInsight(
      id: 'mobility_deficit_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.mobility,
      severity: InsightSeverity.medium,
      title: 'Mobility Work Needed',
      description: 'You completed only $mobilitySessions mobility sessions in the last 2 weeks ($sessionsDeficit below recommended minimum). Insufficient mobility work increases injury risk and limits performance.',
      recommendation: 'Add 2-3 mobility sessions per week (10-15 minutes each). Focus on problem areas: hips, shoulders, thoracic spine, ankles.',
      priority: basePriority,
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Dynamic mobility: Pre-workout (leg swings, arm circles, hip CARs) for 5-10 minutes',
        'Static stretching: Post-workout when muscles are warm (30-60s holds per muscle)',
        'Foam rolling: 2-3x per week for myofascial release (60-120s per muscle group)',
        'Yoga/Pilates: 1-2x per week for full-body mobility and motor control',
        'Injury prevention: Target tight areas (hip flexors, hamstrings, thoracic spine, shoulders)',
      ],
      dataPoints: {
        'mobilitySessions': mobilitySessions,
        'recommendedMinimum': '2 sessions per week',
        'optimalFrequency': '3-4 sessions per week',
        'sessionsDeficit': sessionsDeficit,
        'mobilityExercises': mobilityExercises,
        'examples': mobilityExerciseNames.take(3).join(', '),
        'benefitsInjuryReduction': '20-30% lower injury risk with regular mobility work (Behm et al. 2016)',
      },
      timestamp: DateTime.now(),
    );
  }
}
