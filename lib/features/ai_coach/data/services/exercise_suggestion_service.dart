/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/services
/// 🎯 Feature: AI Coach
/// 🔧 Type: service
///
/// ExerciseSuggestionService - Generates contextual exercise suggestions
///
/// **Purpose**: Searches user's exercise database and generates smart
/// suggestion questions based on historical data.
///
/// **Usage**:
/// ```dart
/// final service = ExerciseSuggestionService(
///   analyticsRepository: analyticsRepo,
/// );
///
/// final suggestions = await service.getSuggestions(
///   userId: 'user123',
///   query: 'bench',
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/exercise_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Service for generating contextual exercise suggestions
class ExerciseSuggestionService {
  ExerciseSuggestionService({
    required AnalyticsRepository analyticsRepository,
  }) : _analyticsRepository = analyticsRepository;

  final AnalyticsRepository _analyticsRepository;

  /// Question templates for exercises with data
  ///
  /// Each template includes:
  /// - display: Short text shown in dropdown
  /// - template: Full question with {exercise} placeholder
  /// - icon: Icon to display
  static final List<({String display, String template, IconData icon})>
      _questionTemplates = [
    (
      display: 'Qual è il mio massimale?',
      template: 'Qual è il mio massimale sulla {exercise}?',
      icon: AppIcons.workout,
    ),
    (
      display: 'Come sta andando la progressione?',
      template: 'Come sta andando la mia progressione con {exercise}?',
      icon: AppIcons.trendUp,
    ),
    (
      display: 'Mostra gli ultimi allenamenti',
      template: 'Mostrami gli ultimi allenamenti con {exercise}',
      icon: AppIcons.history,
    ),
    (
      display: 'Consigli per migliorare',
      template: 'Dammi consigli per migliorare sulla {exercise}',
      icon: AppIcons.lightbulb,
    ),
  ];

  /// Search exercises matching query and generate suggestions
  ///
  /// **Parameters**:
  /// - userId: User identifier for accessing analytics data
  /// - query: Text typed by user (minimum 3 characters)
  /// - maxResults: Maximum number of exercises to return (default 5)
  ///
  /// **Returns**: Empty list if:
  /// - Query < 3 characters
  /// - Query appears to be a complete question
  /// - No matching exercises found
  /// - Repository error (silent failure)
  Future<List<ExerciseSuggestion>> getSuggestions({
    required String userId,
    required String query,
    int maxResults = 5,
  }) async {
    final trimmed = query.trim();

    // Too short - don't search
    if (trimmed.length < 3) return [];

    // Already looks like a question - don't show suggestions
    if (_isAlreadyQuestion(trimmed)) return [];

    // Search for matching exercises
    final searchResult = await _analyticsRepository.searchExercises(
      userId: userId,
      query: trimmed,
    );

    return searchResult.fold(
      (failure) => <ExerciseSuggestion>[],
      (matches) {
        if (matches.isEmpty) return <ExerciseSuggestion>[];

        // Sort: exercises with sessions first, then by most recent date
        final sorted = [...matches]..sort((a, b) {
            // Prioritize exercises with sessions
            if (a.sessions.isNotEmpty && b.sessions.isEmpty) return -1;
            if (a.sessions.isEmpty && b.sessions.isNotEmpty) return 1;

            // Both have sessions - sort by most recent date
            if (a.sessions.isNotEmpty && b.sessions.isNotEmpty) {
              final aLatest = a.sessions
                  .map((s) => s.date)
                  .reduce((x, y) => x.isAfter(y) ? x : y);
              final bLatest = b.sessions
                  .map((s) => s.date)
                  .reduce((x, y) => x.isAfter(y) ? x : y);
              return bLatest.compareTo(aLatest);
            }

            return 0;
          });

        return sorted.take(maxResults).map((match) {
          // Generate questions only for exercises with data
          final questions = match.sessions.isNotEmpty
              ? _questionTemplates
                  .map(
                    (t) => SuggestedQuestion(
                      displayText: t.display,
                      fullQuestion:
                          t.template.replaceAll('{exercise}', match.exerciseName),
                      icon: t.icon,
                    ),
                  )
                  .toList()
              : <SuggestedQuestion>[];

          return ExerciseSuggestion(
            exerciseName: match.exerciseName,
            sessionCount: match.sessions.length,
            lastSessionDate: match.sessions.isNotEmpty
                ? match.sessions
                    .map((s) => s.date)
                    .reduce((a, b) => a.isAfter(b) ? a : b)
                : null,
            suggestedQuestions: questions,
          );
        }).toList();
      },
    );
  }

  /// Detect if text appears to be a complete question
  ///
  /// Returns true if text starts with common question words.
  /// This prevents showing suggestions when user is already
  /// typing a question.
  bool _isAlreadyQuestion(String text) {
    final lower = text.toLowerCase();
    const questionStarters = [
      'qual',
      'come',
      'quanto',
      'mostra',
      'dimmi',
      'cosa',
      'perché',
      'quando',
      'dove',
      'chi',
      // English variants
      'what',
      'how',
      'show',
      'tell',
      'why',
      'when',
      'where',
      'who',
    ];
    return questionStarters.any((q) => lower.startsWith(q));
  }
}
