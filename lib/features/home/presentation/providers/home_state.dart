import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    required String greeting,
    required WorkoutSection workoutSection,
    required AICoachSection aiCoachSection,
    required StreakSection streakSection,
    @Default(LoadingPhase.initial) LoadingPhase loadingPhase,
    @Default({}) Map<String, Duration> sectionLoadTimes,
    DateTime? lastRefresh,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _HomeState;
}

enum LoadingPhase {
  initial,
  loadingCritical,  // Greeting + workout banner
  loadingSecondary, // AI coach + streak
  loadingOptional,  // Secondary actions
  complete,
  error
}

@freezed
abstract class WorkoutSection with _$WorkoutSection {
  const factory WorkoutSection({
    required bool hasActiveWorkout,
    String? workoutName,
    double? progress,
    int? exercisesCompleted,
    int? totalExercises,
  }) = _WorkoutSection;

  const WorkoutSection._();

  factory WorkoutSection.empty() => _empty;

  static const WorkoutSection _empty = WorkoutSection(
    hasActiveWorkout: false,
  );
}

@freezed
abstract class AICoachSection with _$AICoachSection {
  const factory AICoachSection({
    required String message,
    String? suggestion,
    String? imageUrl,
  }) = _AICoachSection;

  const AICoachSection._();

  factory AICoachSection.empty() => _empty;

  static const AICoachSection _empty = AICoachSection(
    message: '',
  );
}

@freezed
abstract class StreakSection with _$StreakSection {
  const factory StreakSection({
    required int currentStreak,
    required int bestStreak,
    DateTime? lastWorkoutDate,
  }) = _StreakSection;

  const StreakSection._();

  factory StreakSection.empty() => _empty;

  static const StreakSection _empty = StreakSection(
    currentStreak: 0,
    bestStreak: 0,
  );
}
