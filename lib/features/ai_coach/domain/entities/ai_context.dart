/// AI Context Entity
///
/// Aggregated user data for AI Coach context.
/// Contains streak, workout history, 1RM data, and recovery status.
///
/// **Layer**: Domain - Entity
/// **Feature**: AI Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_context.freezed.dart';
part 'ai_context.g.dart';

/// User recovery status
enum RecoveryStatus {
  /// Full recovery - ready for intense training
  green,

  /// Moderate fatigue - consider lighter training
  amber,

  /// High fatigue - rest recommended
  red,
}

/// Summary of a completed workout
@freezed
sealed class WorkoutSummary with _$WorkoutSummary {
  const factory WorkoutSummary({
    required String id,
    required String name,
    required DateTime completedAt,
    int? durationMinutes,
    int? exerciseCount,
  }) = _WorkoutSummary;

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSummaryFromJson(json);
}

/// AI context aggregated from user analytics
@freezed
sealed class AIContext with _$AIContext {
  const factory AIContext({
    required int currentStreak,
    WorkoutSummary? lastWorkout,
    required Map<String, int> top5OneRM,
    required RecoveryStatus recoveryStatus,
    required String userTier,
    String? experienceLevel, // 'beginner', 'some', 'experienced', 'athlete'
    String? fitnessGoal, // 'muscle', 'strength', 'endurance', etc.
  }) = _AIContext;

  factory AIContext.fromJson(Map<String, dynamic> json) =>
      _$AIContextFromJson(json);

  const AIContext._();

  /// Convert context to natural language for AI system prompt
  String toPromptString() {
    final buffer = StringBuffer();
    buffer.writeln('## User Context');
    buffer.writeln('- Streak: $currentStreak days');

    if (lastWorkout != null) {
      final hoursAgo = DateTime.now().difference(lastWorkout!.completedAt).inHours;
      buffer.writeln('- Last workout: ${lastWorkout!.name} (${hoursAgo}h ago)');
    } else {
      buffer.writeln('- Last workout: Never');
    }

    buffer.writeln('- Top 1RM:');
    top5OneRM.forEach((exercise, kg) {
      buffer.writeln('  - $exercise: ${kg}kg');
    });

    buffer.writeln('- Recovery: ${recoveryStatus.name.toUpperCase()}');

    // Add experience level and fitness goal for tone adaptation
    if (experienceLevel != null) {
      buffer.writeln('- Experience: $experienceLevel');
    }
    if (fitnessGoal != null) {
      buffer.writeln('- Goal: $fitnessGoal');
    }

    return buffer.toString();
  }
}
