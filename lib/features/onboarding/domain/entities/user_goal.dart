import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_goal.freezed.dart';

/// User's fitness goal selected during onboarding
///
/// Captures what the user wants to achieve and their experience level
/// Part of P4 onboarding retention feature (+10-15% completion improvement)
/// Evidence: Personalized experience increases commitment
@freezed
class UserGoal with _$UserGoal {
  const factory UserGoal({
    required GoalType goalType,
    required int weeklyWorkoutTarget,
    required ExperienceLevel experienceLevel,
  }) = _UserGoal;
}

/// Types of fitness goals users can select
enum GoalType {
  /// Build muscle mass
  buildMuscle,

  /// Lose weight/fat
  loseWeight,

  /// Increase strength (powerlifting focus)
  getStronger,

  /// General fitness and health
  stayFit,
}

/// User's experience level with weight training
enum ExperienceLevel {
  /// New to weight training (0-6 months)
  beginner,

  /// Some experience (6 months - 2 years)
  intermediate,

  /// Experienced lifter (2+ years)
  advanced,
}
