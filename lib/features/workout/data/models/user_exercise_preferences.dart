import 'package:hive_ce_flutter/hive_flutter.dart';

part 'user_exercise_preferences.g.dart';

/// User preferences for exercises including Form Cues
///
/// Form Cues are persistent technique reminders that appear
/// every time the user performs an exercise.
@HiveType(typeId: 70)
class UserExercisePreferences extends HiveObject {
  UserExercisePreferences({
    required this.visibleId,
    required this.exerciseName,
    this.formCues,
    required this.updatedAt,
    this.needsSync = false,
  });

  /// Unique identifier - exerciseId if available, else normalized name
  @HiveField(0)
  String visibleId;

  /// Display name of the exercise
  @HiveField(1)
  String exerciseName;

  /// Form cues / technique reminders (persistent)
  @HiveField(2)
  String? formCues;

  /// Last update timestamp
  @HiveField(3)
  DateTime updatedAt;

  /// Flag for premium Firebase sync
  @HiveField(4)
  bool needsSync;

  /// Generate key for storage lookup
  static String generateKey(String? exerciseId, String exerciseName) {
    return exerciseId ?? _normalizeExerciseName(exerciseName);
  }

  static String _normalizeExerciseName(String name) {
    return name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
  }

  UserExercisePreferences copyWith({
    String? visibleId,
    String? exerciseName,
    String? formCues,
    DateTime? updatedAt,
    bool? needsSync,
  }) {
    return UserExercisePreferences(
      visibleId: visibleId ?? this.visibleId,
      exerciseName: exerciseName ?? this.exerciseName,
      formCues: formCues ?? this.formCues,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  String toString() {
    return 'UserExercisePreferences(visibleId: $visibleId, exerciseName: $exerciseName, formCues: $formCues, updatedAt: $updatedAt, needsSync: $needsSync)';
  }
}
