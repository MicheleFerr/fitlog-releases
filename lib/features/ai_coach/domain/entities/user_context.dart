import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_context.freezed.dart';
part 'user_context.g.dart';

/// User context for personalized AI Coach insights
@freezed
class UserContext with _$UserContext {
  const factory UserContext({
    required String userId,
    required ExperienceLevel experienceLevel,
    required TrainingGoal primaryGoal,
    required int weeklyAvailability, // Number of workout days per week
    List<String>? injuryHistory,
    List<String>? preferredExercises,
  }) = _UserContext;

  factory UserContext.fromJson(Map<String, dynamic> json) =>
      _$UserContextFromJson(json);
}

/// User's training experience level
enum ExperienceLevel {
  beginner,     // 0-1 years training
  intermediate, // 1-3 years training
  advanced,     // 3+ years training
}

/// Primary training goal
enum TrainingGoal {
  hypertrophy, // Muscle growth (8-12 reps, 60-90s rest)
  strength,    // Max strength (1-5 reps, 3-5min rest)
  endurance,   // Muscular endurance (15+ reps, <30s rest)
}
