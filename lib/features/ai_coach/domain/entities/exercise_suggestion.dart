/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: AI Coach
/// 🔧 Type: entity
///
/// ExerciseSuggestion Entity - Smart suggestion for exercise queries
///
/// **Purpose**: Provides contextual suggestions when user types exercise
/// names in the AI Coach chat. Inspired by Perplexity AI's smart suggestions.
///
/// **Usage**:
/// ```dart
/// final suggestion = ExerciseSuggestion(
///   exerciseName: 'Bench Press',
///   sessionCount: 12,
///   lastSessionDate: DateTime.now().subtract(Duration(days: 2)),
///   suggestedQuestions: [
///     SuggestedQuestion(
///       displayText: 'What is my max?',
///       fullQuestion: 'What is my max on Bench Press?',
///       icon: AppIcons.fitness,
///     ),
///   ],
/// );
/// ```
library;

import 'package:flutter/widgets.dart'; // solo per IconData — non Material-specific
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_suggestion.freezed.dart';

/// Suggested question for a specific exercise
///
/// **Properties**:
/// - displayText: Short text shown in dropdown (e.g., "What is my max?")
/// - fullQuestion: Complete question to send (e.g., "What is my max on Bench Press?")
/// - icon: Icon for the question
@freezed
sealed class SuggestedQuestion with _$SuggestedQuestion {
  const factory SuggestedQuestion({
    /// Short text displayed in the suggestion dropdown
    required String displayText,

    /// Full question to send to the AI Coach
    required String fullQuestion,

    /// Icon displayed next to the question
    required IconData icon,
  }) = _SuggestedQuestion;
}

/// Suggestion for an exercise found in user's database
///
/// **Properties**:
/// - exerciseName: Exact name from database
/// - sessionCount: Number of sessions with this exercise
/// - lastSessionDate: Date of most recent session (null if no sessions)
/// - suggestedQuestions: List of clickable questions
///
/// **Computed Properties**:
/// - hasData: True if user has historical data for this exercise
@freezed
sealed class ExerciseSuggestion with _$ExerciseSuggestion {
  const factory ExerciseSuggestion({
    /// Exercise name exactly as stored in database
    required String exerciseName,

    /// Number of sessions recorded for this exercise
    required int sessionCount,

    /// Date of most recent session (null if no sessions)
    DateTime? lastSessionDate,

    /// List of suggested questions for this exercise
    required List<SuggestedQuestion> suggestedQuestions,
  }) = _ExerciseSuggestion;

  const ExerciseSuggestion._();

  /// True if user has historical data for this exercise
  bool get hasData => sessionCount > 0;
}
