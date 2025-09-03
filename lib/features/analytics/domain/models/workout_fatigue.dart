/// Model for tracking workout fatigue and recovery data
class WorkoutFatigue {
  final String workoutId;
  final DateTime date;
  final int fatigueLevel; // 1-5 scale
  final double totalVolume;
  final List<String> exercisesPerformed;
  final Map<String, double> muscleGroupVolume;
  final String? notes;
  final DateTime? recoveryCompletedAt;

  const WorkoutFatigue({
    required this.workoutId,
    required this.date,
    required this.fatigueLevel,
    required this.totalVolume,
    required this.exercisesPerformed,
    required this.muscleGroupVolume,
    this.notes,
    this.recoveryCompletedAt,
  });

  /// Calculate Muscle Efficiency Score
  /// Higher score = better efficiency (more volume with less fatigue)
  double get muscleEfficiencyScore {
    // Formula: (Volume / 1000) / (Fatigue Level)
    // Normalized to 0-100 scale
    final baseScore = (totalVolume / 1000) / fatigueLevel;
    return (baseScore * 20).clamp(0, 100);
  }

  /// Estimated recovery time in hours based on fatigue level
  int get estimatedRecoveryHours {
    switch (fatigueLevel) {
      case 1:
        return 24; // Light fatigue
      case 2:
        return 36; // Moderate fatigue
      case 3:
        return 48; // Normal fatigue
      case 4:
        return 60; // High fatigue
      case 5:
        return 72; // Extreme fatigue
      default:
        return 48;
    }
  }

  /// Check if muscles are recovered
  bool get isRecovered {
    final hoursPassedSince = DateTime.now().difference(date).inHours;
    return hoursPassedSince >= estimatedRecoveryHours;
  }

  Map<String, dynamic> toJson() => {
    'workoutId': workoutId,
    'date': date.toIso8601String(),
    'fatigueLevel': fatigueLevel,
    'totalVolume': totalVolume,
    'exercisesPerformed': exercisesPerformed,
    'muscleGroupVolume': muscleGroupVolume,
    'notes': notes,
    'recoveryCompletedAt': recoveryCompletedAt?.toIso8601String(),
  };

  factory WorkoutFatigue.fromJson(Map<String, dynamic> json) => WorkoutFatigue(
    workoutId: json['workoutId'] as String,
    date: DateTime.parse(json['date'] as String),
    fatigueLevel: json['fatigueLevel'] as int,
    totalVolume: (json['totalVolume'] as num).toDouble(),
    exercisesPerformed: (json['exercisesPerformed'] as List).cast<String>(),
    muscleGroupVolume: (json['muscleGroupVolume'] as Map).cast<String, double>(),
    notes: json['notes'] as String?,
    recoveryCompletedAt: json['recoveryCompletedAt'] != null
        ? DateTime.parse(json['recoveryCompletedAt'] as String)
        : null,
  );
}

/// Enum for fatigue levels with descriptions
enum FatigueLevel {
  veryLight(1, 'Very Light', '😊', 'Could do more'),
  light(2, 'Light', '🙂', 'Good energy left'),
  moderate(3, 'Moderate', '😐', 'Normal tiredness'),
  heavy(4, 'Heavy', '😮‍💨', 'Very tired'),
  extreme(5, 'Extreme', '😵', 'Completely exhausted');

  final int value;
  final String label;
  final String emoji;
  final String description;

  const FatigueLevel(this.value, this.label, this.emoji, this.description);

  static FatigueLevel fromValue(int value) {
    return FatigueLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => FatigueLevel.moderate,
    );
  }
}