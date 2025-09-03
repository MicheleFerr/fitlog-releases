import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

part 'workout_draft.g.dart';

/// Entity for storing workout drafts locally to prevent data loss
@HiveType(typeId: 10)
class WorkoutDraft {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String workoutJson;
  
  @HiveField(2)
  final DateTime lastSaved;
  
  @HiveField(3)
  final String? deviceId;
  
  @HiveField(4)
  final Map<String, dynamic>? metadata;
  
  @HiveField(5)
  final bool isRecovered;

  WorkoutDraft({
    required this.id,
    required this.workoutJson,
    required this.lastSaved,
    this.deviceId,
    this.metadata,
    this.isRecovered = false,
  });

  /// Create draft from Workout object
  factory WorkoutDraft.fromWorkout(Workout workout) {
    return WorkoutDraft(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      workoutJson: jsonEncode(workout.toJson()),
      lastSaved: DateTime.now(),
      metadata: {
        'workoutName': workout.name,
        'exerciseCount': workout.exercises.length,
        'startTime': workout.startTime?.toIso8601String(),
      },
    );
  }

  /// Convert draft back to Workout
  Workout toWorkout() {
    return Workout.fromJson(jsonDecode(workoutJson) as Map<String, dynamic>);
  }

  /// Check if draft is stale (older than 24 hours)
  bool get isStale {
    final hoursSinceLastSave = DateTime.now().difference(lastSaved).inHours;
    return hoursSinceLastSave > 24;
  }

  /// Create a copy with updated fields
  WorkoutDraft copyWith({
    String? workoutJson,
    DateTime? lastSaved,
    bool? isRecovered,
  }) {
    return WorkoutDraft(
      id: id,
      workoutJson: workoutJson ?? this.workoutJson,
      lastSaved: lastSaved ?? this.lastSaved,
      deviceId: deviceId,
      metadata: metadata,
      isRecovered: isRecovered ?? this.isRecovered,
    );
  }
}