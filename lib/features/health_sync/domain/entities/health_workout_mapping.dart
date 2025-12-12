import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
/// Enum representing FitLog workout categories (bodybuilding-focused).
///
/// Simplified to 3 categories based on app scope:
/// - Strength: Bodybuilding, resistance training
/// - Cardio: Running, cycling, rowing
/// - Other: Fallback for unsupported types
enum FitLogWorkoutCategory {
  /// Bodybuilding and resistance training
  /// Maps to: weight lifting, strength training, functional training
  strength,

  /// Cardiovascular exercises
  /// Maps to: running, cycling, rowing, elliptical
  cardio,

  /// Fallback category for other workout types
  /// Maps to: yoga, HIIT, sports, etc. (not primary focus for MVP)
  other,
}

/// Mapper utility for converting between health platform workout types
/// and FitLog workout categories.
///
/// Platform support:
/// - iOS: HealthKit HKWorkoutActivityType
/// - Android 14+: Health Connect ExerciseType
///
/// Design: Bidirectional mapping allows:
/// 1. HealthKit → FitLog (import workouts from Apple Health)
/// 2. FitLog → HealthKit (export workouts to Apple Health)
class HealthWorkoutTypeMapper {
  /// iOS HealthKit workout types (from health package)
  /// Reference: https://developer.apple.com/documentation/healthkit/hkworkoutactivitytype
  ///
  /// Note: Using string constants since `health` package doesn't export
  /// the enum directly. Verified against health ^13.2.1 source.
  static const String _hkStrengthTraining = 'TRADITIONAL_STRENGTH_TRAINING';
  static const String _hkFunctionalStrength = 'FUNCTIONAL_STRENGTH_TRAINING';
  static const String _hkRunning = 'RUNNING';
  static const String _hkCycling = 'CYCLING';
  static const String _hkRowing = 'ROWING';
  static const String _hkElliptical = 'ELLIPTICAL';
  static const String _hkOther = 'OTHER';

  // Android Health Connect types (when implemented in Phase 1.5)
  static const String _hcWeightLifting = 'EXERCISE_TYPE_WEIGHTLIFTING';
  static const String _hcRunning = 'EXERCISE_TYPE_RUNNING';
  static const String _hcCycling = 'EXERCISE_TYPE_CYCLING';

  /// Converts iOS HealthKit workout type to FitLog category.
  ///
  /// Mapping strategy (bodybuilding-focused):
  /// - Traditional/Functional Strength → Strength
  /// - Running/Cycling/Rowing → Cardio
  /// - All other types → Other (fallback)
  ///
  /// Example:
  /// ```dart
  /// final category = HealthWorkoutTypeMapper.fromHealthKit('RUNNING');
  /// // Returns: FitLogWorkoutCategory.cardio
  /// ```
  static FitLogWorkoutCategory fromHealthKit(String healthKitType) {
    switch (healthKitType) {
      // Strength training
      case _hkStrengthTraining:
      case _hkFunctionalStrength:
        return FitLogWorkoutCategory.strength;

      // Cardio exercises
      case _hkRunning:
      case _hkCycling:
      case _hkRowing:
      case _hkElliptical:
        return FitLogWorkoutCategory.cardio;

      // Fallback for yoga, HIIT, sports, etc.
      default:
        return FitLogWorkoutCategory.other;
    }
  }

  /// Converts FitLog category to iOS HealthKit workout type.
  ///
  /// Reverse mapping for exporting workouts to Apple Health.
  ///
  /// Default mappings:
  /// - Strength → Traditional Strength Training
  /// - Cardio → Running (most common cardio in bodybuilding)
  /// - Other → Other
  ///
  /// Example:
  /// ```dart
  /// final hkType = HealthWorkoutTypeMapper.toHealthKit(
  ///   FitLogWorkoutCategory.strength,
  /// );
  /// // Returns: 'TRADITIONAL_STRENGTH_TRAINING'
  /// ```
  static String toHealthKit(FitLogWorkoutCategory category) {
    switch (category) {
      case FitLogWorkoutCategory.strength:
        return _hkStrengthTraining;
      case FitLogWorkoutCategory.cardio:
        return _hkRunning; // Default to running for cardio
      case FitLogWorkoutCategory.other:
        return _hkOther;
    }
  }

  /// Converts Android Health Connect exercise type to FitLog category.
  ///
  /// Similar logic to HealthKit mapping but for Android.
  ///
  /// TODO: Implement in Phase 1.5 (Android testing)
  /// Placeholder for now since user can only test on iOS.
  static FitLogWorkoutCategory fromHealthConnect(String healthConnectType) {
    switch (healthConnectType) {
      case _hcWeightLifting:
        return FitLogWorkoutCategory.strength;
      case _hcRunning:
      case _hcCycling:
        return FitLogWorkoutCategory.cardio;
      default:
        return FitLogWorkoutCategory.other;
    }
  }

  /// Converts FitLog category to Android Health Connect exercise type.
  ///
  /// Reverse mapping for exporting workouts to Health Connect.
  ///
  /// TODO: Implement in Phase 1.5 (Android testing)
  static String toHealthConnect(FitLogWorkoutCategory category) {
    switch (category) {
      case FitLogWorkoutCategory.strength:
        return _hcWeightLifting;
      case FitLogWorkoutCategory.cardio:
        return _hcRunning;
      case FitLogWorkoutCategory.other:
        return 'EXERCISE_TYPE_OTHER';
    }
  }
}

/// Extension methods for [FitLogWorkoutCategory]
extension FitLogWorkoutCategoryExtension on FitLogWorkoutCategory {
  /// Returns the localization key for this category's display name
  String get displayNameKey {
    switch (this) {
      case FitLogWorkoutCategory.strength:
        return 'workoutCategoryStrength'; // "Strength Training"
      case FitLogWorkoutCategory.cardio:
        return 'workoutCategoryCardio'; // "Cardio"
      case FitLogWorkoutCategory.other:
        return 'workoutCategoryOther'; // "Other"
    }
  }

  /// Returns the icon name for this category (from AppIcons)
  String get iconName {
    switch (this) {
      case FitLogWorkoutCategory.strength:
        return 'dumbbell'; // AppIcons.dumbbell
      case FitLogWorkoutCategory.cardio:
        return 'run'; // AppIcons.run
      case FitLogWorkoutCategory.other:
        return 'fitness'; // AppIcons.fitness
    }
  }
}
