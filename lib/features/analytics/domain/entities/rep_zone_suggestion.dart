/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// Rep Zone Suggestion - Entity for zone-based exercise suggestions
///
/// **Scientific Basis**:
/// Based on Schoenfeld et al. (2021) and the 80/20 training principle.
/// Variety in rep ranges maximizes muscle adaptation through different
/// mechanisms (mechanical tension, metabolic stress, muscle damage).
library;

import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

/// Rep Zone types
enum RepZone {
  strength, // 1-5 reps
  hypertrophy, // 6-15 reps
  endurance; // 15+ reps

  String get label {
    switch (this) {
      case RepZone.strength:
        return 'Forza';
      case RepZone.hypertrophy:
        return 'Ipertrofia';
      case RepZone.endurance:
        return 'Resistenza';
    }
  }

  String get repRange {
    switch (this) {
      case RepZone.strength:
        return '1-5 rep';
      case RepZone.hypertrophy:
        return '6-15 rep';
      case RepZone.endurance:
        return '15+ rep';
    }
  }

  /// Recommended sets for this zone
  int get recommendedSets {
    switch (this) {
      case RepZone.strength:
        return 3;
      case RepZone.hypertrophy:
        return 4;
      case RepZone.endurance:
        return 3;
    }
  }

  /// Recommended reps for this zone
  int get recommendedReps {
    switch (this) {
      case RepZone.strength:
        return 5;
      case RepZone.hypertrophy:
        return 10;
      case RepZone.endurance:
        return 15;
    }
  }

  /// Recommended rest time in seconds
  int get recommendedRestSeconds {
    switch (this) {
      case RepZone.strength:
        return 180; // 3 min
      case RepZone.hypertrophy:
        return 90; // 1.5 min
      case RepZone.endurance:
        return 60; // 1 min
    }
  }
}

/// Variety level based on rep zone distribution
enum VarietyLevel {
  /// Excellent variety - no zone > 60%
  excellent,

  /// Good variety - no zone > 70%
  good,

  /// Low variety - one zone > 80%
  low,

  /// Very low - one zone > 90%
  veryLow;

  bool get needsSuggestions => this == low || this == veryLow;
}

/// Rep Zone Analysis Result
class RepZoneAnalysis {
  const RepZoneAnalysis({
    required this.strengthPercentage,
    required this.hypertrophyPercentage,
    required this.endurancePercentage,
    required this.strengthSets,
    required this.hypertrophySets,
    required this.enduranceSets,
    required this.totalSets,
    required this.varietyLevel,
    required this.dominantZone,
    required this.neglectedZones,
  });

  final double strengthPercentage;
  final double hypertrophyPercentage;
  final double endurancePercentage;
  final int strengthSets;
  final int hypertrophySets;
  final int enduranceSets;
  final int totalSets;
  final VarietyLevel varietyLevel;
  final RepZone? dominantZone;
  final List<RepZone> neglectedZones;

  /// Check if suggestions are needed
  bool get needsSuggestions => varietyLevel.needsSuggestions;

  /// Get the percentage for a specific zone
  double getPercentage(RepZone zone) {
    switch (zone) {
      case RepZone.strength:
        return strengthPercentage;
      case RepZone.hypertrophy:
        return hypertrophyPercentage;
      case RepZone.endurance:
        return endurancePercentage;
    }
  }
}

/// Score breakdown for exercise suggestion scoring system
///
/// Each criterion has a max score contributing to total 0-100
///
/// **v3 Scoring Criteria**:
/// - MUSCLE RELEVANCE (0-30): How well exercise targets needed muscle groups
/// - EXERCISE TYPE (0-20): Compound vs Isolation match for zone
/// - EQUIPMENT (0-15): Equipment already available in user's templates
/// - DIFFICULTY MATCH (0-10): Difficulty matches user's experience level
/// - VARIETY (0-10): Exercise variety - not done recently
/// - WEEKLY VOLUME (0-15): Fills gaps in weekly muscle volume
/// - INTENSITY MATCH (0-10): Exercise intensity matches target zone % 1RM
///
/// Total theoretical max: 110 (normalized to 0-100)
class ScoreBreakdown {
  const ScoreBreakdown({
    this.muscleRelevance = 0,
    this.exerciseType = 0,
    this.equipment = 0,
    this.difficultyMatch = 0,
    this.variety = 0,
    this.weeklyVolume = 0,
    this.intensityMatch = 0,
  });

  /// How well exercise targets needed muscle groups (0-30)
  final int muscleRelevance;

  /// Compound vs Isolation match for zone (0-20)
  final int exerciseType;

  /// Equipment already available in user's templates (0-15)
  final int equipment;

  /// Difficulty matches user's experience level (0-10)
  final int difficultyMatch;

  /// Exercise variety - not done recently (0-10)
  final int variety;

  /// v3: Weekly volume gap fill - exercise targets under-volumed muscles (0-15)
  ///
  /// Scoring:
  /// - 15: Targets muscle group with <50% of recommended weekly sets
  /// - 10: Targets muscle group with 50-70% of recommended weekly sets
  /// - 5: Targets muscle group with 70-90% of recommended weekly sets
  /// - 0: Muscle group already at or above recommended volume
  final int weeklyVolume;

  /// v3: Intensity match - typical % 1RM matches target zone (0-10)
  ///
  /// Based on Schoenfeld et al.:
  /// - Strength zone: 85-100% 1RM (1-5 reps)
  /// - Hypertrophy zone: 65-85% 1RM (6-15 reps)
  /// - Endurance zone: 40-65% 1RM (15+ reps)
  final int intensityMatch;

  /// Total score (0-110 theoretical max, normalized to 0-100)
  int get total =>
      muscleRelevance +
      exerciseType +
      equipment +
      difficultyMatch +
      variety +
      weeklyVolume +
      intensityMatch;

  /// Normalized score 0-100
  int get normalizedScore => ((total / 110) * 100).round().clamp(0, 100);
}

/// Alternative exercise suggestion with score and short reason
class AlternativeExercise {
  const AlternativeExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.score,
    required this.shortReason,
    required this.equipment,
    required this.countingMode,
  });

  /// Exercise ID from database
  final String exerciseId;

  /// Exercise name
  final String exerciseName;

  /// Score 0-100
  final int score;

  /// Short reason for this alternative (e.g., "Stesso pattern, manubri")
  final String shortReason;

  /// Required equipment
  final String equipment;

  /// How this exercise is counted
  final ExerciseCountingMode countingMode;
}

/// Rep Zone Suggestion - Exercise suggestion for balancing rep zones
///
/// v2: Now includes score breakdown, motivations, and alternatives
class RepZoneSuggestion {
  const RepZoneSuggestion({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetZone,
    required this.targetTemplate,
    required this.targetTemplateId,
    required this.recommendedSets,
    required this.recommendedReps,
    required this.recommendedRestSeconds,
    required this.difficulty,
    required this.equipment,
    required this.reasonKey,
    required this.countingMode,
    // v2 fields
    this.score = 0,
    this.scoreBreakdown = const ScoreBreakdown(),
    this.motivations = const [],
    this.alternatives = const [],
    this.exerciseType,
    this.musclesFocus = const [],
    this.patternMovimento,
    this.rangeRipetizioni,
    this.daysSinceLastDone,
  });

  /// Create from ExerciseSuggestion with zone info
  factory RepZoneSuggestion.fromExerciseSuggestion({
    required ExerciseSuggestion suggestion,
    required RepZone targetZone,
    required String targetTemplate,
    required String targetTemplateId,
    required String reasonKey,
  }) {
    return RepZoneSuggestion(
      exerciseId: suggestion.exerciseId,
      exerciseName: suggestion.exerciseName,
      targetZone: targetZone,
      targetTemplate: targetTemplate,
      targetTemplateId: targetTemplateId,
      recommendedSets: targetZone.recommendedSets,
      recommendedReps: targetZone.recommendedReps,
      recommendedRestSeconds: targetZone.recommendedRestSeconds,
      difficulty: suggestion.difficulty,
      equipment: suggestion.equipment,
      reasonKey: reasonKey,
      countingMode: suggestion.countingMode,
    );
  }

  /// Exercise ID from database
  final String exerciseId;

  /// Exercise name
  final String exerciseName;

  /// Target rep zone to add
  final RepZone targetZone;

  /// Template name to add to (auto-detected)
  final String targetTemplate;

  /// Template ID to add to
  final String targetTemplateId;

  /// Recommended number of sets
  final int recommendedSets;

  /// Recommended number of reps
  final int recommendedReps;

  /// Recommended rest time in seconds
  final int recommendedRestSeconds;

  /// Exercise difficulty
  final ExerciseDifficulty difficulty;

  /// Required equipment
  final String equipment;

  /// Reason key for localization (e.g., 'balanceStrength', 'addVariety')
  final String reasonKey;

  /// How this exercise is counted
  final ExerciseCountingMode countingMode;

  // ===== v2 FIELDS =====

  /// Overall score 0-100 (higher = better match)
  final int score;

  /// Detailed score breakdown
  final ScoreBreakdown scoreBreakdown;

  /// List of motivation strings (already localized or keys)
  final List<String> motivations;

  /// Alternative exercises for this zone (3-4)
  final List<AlternativeExercise> alternatives;

  /// Exercise type (Compound/Isolamento)
  final String? exerciseType;

  /// Primary muscles targeted
  final List<String> musclesFocus;

  /// Movement pattern (Push/Pull/etc)
  final String? patternMovimento;

  /// Natural rep range for this exercise
  final String? rangeRipetizioni;

  /// Days since user last performed this exercise (null = never)
  final int? daysSinceLastDone;

  /// Create a copy with updated fields
  RepZoneSuggestion copyWith({
    String? exerciseId,
    String? exerciseName,
    RepZone? targetZone,
    String? targetTemplate,
    String? targetTemplateId,
    int? recommendedSets,
    int? recommendedReps,
    int? recommendedRestSeconds,
    ExerciseDifficulty? difficulty,
    String? equipment,
    String? reasonKey,
    ExerciseCountingMode? countingMode,
    int? score,
    ScoreBreakdown? scoreBreakdown,
    List<String>? motivations,
    List<AlternativeExercise>? alternatives,
    String? exerciseType,
    List<String>? musclesFocus,
    String? patternMovimento,
    String? rangeRipetizioni,
    int? daysSinceLastDone,
  }) {
    return RepZoneSuggestion(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      targetZone: targetZone ?? this.targetZone,
      targetTemplate: targetTemplate ?? this.targetTemplate,
      targetTemplateId: targetTemplateId ?? this.targetTemplateId,
      recommendedSets: recommendedSets ?? this.recommendedSets,
      recommendedReps: recommendedReps ?? this.recommendedReps,
      recommendedRestSeconds:
          recommendedRestSeconds ?? this.recommendedRestSeconds,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      reasonKey: reasonKey ?? this.reasonKey,
      countingMode: countingMode ?? this.countingMode,
      score: score ?? this.score,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      motivations: motivations ?? this.motivations,
      alternatives: alternatives ?? this.alternatives,
      exerciseType: exerciseType ?? this.exerciseType,
      musclesFocus: musclesFocus ?? this.musclesFocus,
      patternMovimento: patternMovimento ?? this.patternMovimento,
      rangeRipetizioni: rangeRipetizioni ?? this.rangeRipetizioni,
      daysSinceLastDone: daysSinceLastDone ?? this.daysSinceLastDone,
    );
  }
}
