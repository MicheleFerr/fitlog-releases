/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain
/// 🎯 Feature: analytics
/// 🔧 Type: entity
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: iOS/Android/Universal
///
/// Dependencies:
/// - workout/domain/entities
library;

import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

/// Types of personal records that can be tracked
enum PRType {
  weight, // Heaviest weight lifted for any reps
  volume, // Highest volume (weight * reps) in a single set
  reps, // Most reps at a specific weight
  oneRM, // Calculated 1RM estimate
  totalVolume, // Total volume for an exercise in a workout
  totalSets, // Total sets completed for an exercise
  time, // Fastest time for time-based exercises
}

/// Status of an exercise relative to personal records
enum PRStatus {
  newPR, // New personal record achieved
  nearPR, // Within 5% of personal record
  approaching, // Within 10% of personal record
  normal, // Not close to PR
}

/// Personal Record entity for tracking exercise achievements
class PersonalRecord {
  const PersonalRecord({
    required this.id,
    required this.exerciseName,
    required this.exerciseId,
    required this.type,
    required this.value,
    this.reps,
    this.weight,
    required this.achievedAt,
    required this.workoutId,
    this.metadata = const {},
  });

  /// Create from an exercise set
  factory PersonalRecord.fromSet({
    required String exerciseName,
    required String exerciseId,
    required ExerciseSet set,
    required PRType type,
    required String workoutId,
  }) {
    double value;

    switch (type) {
      case PRType.weight:
        value = set.weight ?? 0.0;
        break;
      case PRType.volume:
        value = set.volume;
        break;
      case PRType.reps:
        value = set.actualReps?.toDouble() ?? set.reps?.toDouble() ?? 0.0;
        break;
      case PRType.oneRM:
        // Epley formula: 1RM = weight × (1 + reps/30)
        final actualReps = set.actualReps ?? set.reps ?? 0;
        final weight = set.weight ?? 0.0;
        value = weight * (1 + actualReps / 30.0);
        break;
      case PRType.time:
        value = set.seconds?.toDouble() ?? 0;
        break;
      case PRType.totalVolume:
        value = set.volume;
        break;
      case PRType.totalSets:
        value = 1.0; // Each set counts as 1
        break;
    }

    return PersonalRecord(
      id: '${exerciseId}_${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      type: type,
      value: value,
      reps: set.actualReps ?? set.reps,
      weight: set.weight,
      achievedAt: set.completedAt ?? DateTime.now(),
      workoutId: workoutId,
      metadata: {
        'setNumber': set.setNumber,
        'isWarmup': set.isWarmup,
        'rpe': set.rpe,
      },
    );
  }

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'],
      exerciseName: json['exerciseName'],
      exerciseId: json['exerciseId'],
      type: PRType.values.firstWhere((e) => e.name == json['type']),
      value: (json['value'] as num).toDouble(),
      reps: json['reps'],
      weight: (json['weight'] as num?)?.toDouble(),
      achievedAt: DateTime.parse(json['achievedAt']),
      workoutId: json['workoutId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  final String id;
  final String exerciseName;
  final String exerciseId;
  final PRType type;
  final double value;
  final int? reps;
  final double? weight;
  final DateTime achievedAt;
  final String workoutId;
  final Map<String, dynamic> metadata;

  /// Get formatted value based on PR type
  String get formattedValue {
    switch (type) {
      case PRType.weight:
        return '${value.toStringAsFixed(1)} kg';
      case PRType.volume:
        return '${value.toStringAsFixed(0)} kg';
      case PRType.reps:
        return '${value.toInt()} reps';
      case PRType.oneRM:
        return '${value.toStringAsFixed(1)} kg (1RM)';
      case PRType.totalVolume:
        return '${value.toStringAsFixed(0)} kg total';
      case PRType.totalSets:
        return '${value.toInt()} sets';
      case PRType.time:
        return '${(value / 60).toStringAsFixed(1)} min';
    }
  }

  /// Get description for the PR
  String get description {
    switch (type) {
      case PRType.weight:
        return reps != null ? '$formattedValue × $reps reps' : formattedValue;
      case PRType.reps:
        return weight != null
            ? '${value.toInt()} reps @ ${weight!.toStringAsFixed(1)} kg'
            : formattedValue;
      case PRType.volume:
        return weight != null && reps != null
            ? '${weight!.toStringAsFixed(1)} kg × $reps = $formattedValue'
            : formattedValue;
      default:
        return formattedValue;
    }
  }

  PersonalRecord copyWith({
    String? exerciseName,
    PRType? type,
    double? value,
    int? reps,
    double? weight,
    DateTime? achievedAt,
    String? workoutId,
    Map<String, dynamic>? metadata,
  }) {
    return PersonalRecord(
      id: id,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseId: exerciseId,
      type: type ?? this.type,
      value: value ?? this.value,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      achievedAt: achievedAt ?? this.achievedAt,
      workoutId: workoutId ?? this.workoutId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'exerciseId': exerciseId,
      'type': type.name,
      'value': value,
      'reps': reps,
      'weight': weight,
      'achievedAt': achievedAt.toIso8601String(),
      'workoutId': workoutId,
      'metadata': metadata,
    };
  }
}

/// PR Detection result for an exercise
class PRDetectionResult {
  const PRDetectionResult({
    required this.exerciseId,
    required this.exerciseName,
    this.newPRs = const [],
    required this.status,
    this.proximityPercentage,
    this.currentPR,
    this.prsByType = const {},
  });
  final String exerciseId;
  final String exerciseName;
  final List<PersonalRecord> newPRs;
  final PRStatus status;
  final double? proximityPercentage; // How close to PR (0-100%)
  final PersonalRecord? currentPR;
  final Map<PRType, PersonalRecord> prsByType;

  bool get hasNewPR => newPRs.isNotEmpty;

  bool get isNearPR =>
      status == PRStatus.nearPR || status == PRStatus.approaching;

  /// Get motivational message based on status
  String getMotivationalMessage() {
    switch (status) {
      case PRStatus.newPR:
        return '🎉 NEW PERSONAL RECORD!';
      case PRStatus.nearPR:
        return '🔥 ${proximityPercentage?.toStringAsFixed(0)}% of your PR!';
      case PRStatus.approaching:
        return '💪 Getting closer to your PR!';
      case PRStatus.normal:
        return '';
    }
  }
}

/// Service for detecting PRs in real-time
class PRDetector {
  const PRDetector({required this.historicalPRs});
  final Map<String, List<PersonalRecord>> historicalPRs;

  /// Detect PRs for a single exercise
  PRDetectionResult detectForExercise(Exercise exercise, String workoutId) {
    final stableExerciseId = exercise.stableExerciseId;
    final exercisePRs = historicalPRs[stableExerciseId] ?? [];
    final newPRs = <PersonalRecord>[];
    final prsByType = <PRType, PersonalRecord>{};

    // Group historical PRs by type
    for (final pr in exercisePRs) {
      final existing = prsByType[pr.type];
      if (existing == null || pr.value > existing.value) {
        prsByType[pr.type] = pr;
      }
    }

    double maxProximity = 0;
    PersonalRecord? closestPR;

    // Check each completed set for PRs
    for (final set in exercise.sets.where(
      (s) => s.isCompleted && !s.isWarmup,
    )) {
      // Check weight PR
      final weightPR = prsByType[PRType.weight];
      if (weightPR == null ||
          (set.weight != null && set.weight! > weightPR.value)) {
        newPRs.add(
          PersonalRecord.fromSet(
            exerciseName: exercise.name,
            exerciseId: stableExerciseId,
            set: set,
            type: PRType.weight,
            workoutId: workoutId,
          ),
        );
      } else if (set.weight != null) {
        final proximity = (set.weight! / weightPR.value) * 100;
        if (proximity > maxProximity) {
          maxProximity = proximity;
          closestPR = weightPR;
        }
      }

      // Check volume PR
      final volumePR = prsByType[PRType.volume];
      if (volumePR == null || set.volume > volumePR.value) {
        newPRs.add(
          PersonalRecord.fromSet(
            exerciseName: exercise.name,
            exerciseId: stableExerciseId,
            set: set,
            type: PRType.volume,
            workoutId: workoutId,
          ),
        );
      }

      // Check reps PR at this weight
      final actualReps = set.actualReps ?? set.reps;
      final repsPRs = exercisePRs
          .where(
            (pr) =>
                pr.type == PRType.reps &&
                pr.weight != null &&
                set.weight != null &&
                (pr.weight! - set.weight!).abs() < 2.5, // Within 2.5kg
          )
          .toList();

      if (repsPRs.isEmpty || (actualReps ?? 0) > repsPRs.first.value) {
        newPRs.add(
          PersonalRecord.fromSet(
            exerciseName: exercise.name,
            exerciseId: stableExerciseId,
            set: set,
            type: PRType.reps,
            workoutId: workoutId,
          ),
        );
      }

      // Check 1RM estimate
      if (set.weight != null && actualReps != null) {
        final oneRM = set.weight! * (1 + actualReps / 30.0);
        final oneRMPR = prsByType[PRType.oneRM];
        if (oneRMPR == null || oneRM > oneRMPR.value) {
          newPRs.add(
            PersonalRecord(
              id:
                  '${stableExerciseId}_oneRM_${DateTime.now().millisecondsSinceEpoch}',
              exerciseName: exercise.name,
              exerciseId: stableExerciseId,
              type: PRType.oneRM,
              value: oneRM,
              reps: actualReps,
              weight: set.weight,
              achievedAt: set.completedAt ?? DateTime.now(),
              workoutId: workoutId,
              metadata: {'setNumber': set.setNumber},
            ),
          );
        }
      }
    }

    // Calculate total volume PR
    final totalVolume = exercise.sets
        .where((s) => s.isCompleted && !s.isWarmup)
        .fold<double>(0, (sum, set) => sum + set.volume);

    final totalVolumePR = prsByType[PRType.totalVolume];
    if (totalVolumePR == null || totalVolume > totalVolumePR.value) {
      newPRs.add(
        PersonalRecord(
          id:
              '${stableExerciseId}_totalVolume_${DateTime.now().millisecondsSinceEpoch}',
          exerciseName: exercise.name,
          exerciseId: stableExerciseId,
          type: PRType.totalVolume,
          value: totalVolume,
          achievedAt: DateTime.now(),
          workoutId: workoutId,
          metadata: {
            'setsCount': exercise.sets.where((s) => s.isCompleted).length,
          },
        ),
      );
    }

    // Determine status
    PRStatus status;
    if (newPRs.isNotEmpty) {
      status = PRStatus.newPR;
    } else if (maxProximity >= 95) {
      status = PRStatus.nearPR;
    } else if (maxProximity >= 90) {
      status = PRStatus.approaching;
    } else {
      status = PRStatus.normal;
    }

    return PRDetectionResult(
      exerciseId: stableExerciseId,
      exerciseName: exercise.name,
      newPRs: newPRs,
      status: status,
      proximityPercentage: maxProximity > 0 ? maxProximity : null,
      currentPR: closestPR,
      prsByType: prsByType,
    );
  }

  /// Detect all PRs in a workout
  List<PRDetectionResult> detectForWorkout(
    List<Exercise> exercises,
    String workoutId,
  ) {
    return exercises
        .map((exercise) => detectForExercise(exercise, workoutId))
        .toList();
  }
}
