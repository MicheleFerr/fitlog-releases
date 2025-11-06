/// Schema version constants for database migrations
///
/// Used to track and migrate data schema changes across app versions.
class SchemaVersions {
  /// Versione 1: SupersetExerciseData without countingMode
  /// - Only supports weighted exercises (targetWeight + targetReps)
  /// - No support for time-based exercises
  static const int supersetDataV1 = 1;

  /// Versione 2: SupersetExerciseData with countingMode + time support
  /// - Supports all ExerciseCountingMode: weighted, reps, time
  /// - Adds targetSeconds/actualSeconds for time-based exercises
  /// - Explicit countingMode field
  static const int supersetDataV2 = 2;

  /// Current schema version (target)
  static const int currentSupersetDataVersion = supersetDataV2;
}
