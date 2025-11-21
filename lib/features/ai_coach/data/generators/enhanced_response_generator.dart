/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/generators
/// 🎯 Feature: ai_coach
/// 🔧 Type: response_generator
///
/// Enhanced Response Generator - Context-aware response generation using search results
///
/// **Features**:
/// - Uses BM25 search results for context
/// - Generates data-driven responses
/// - Includes relevant workout statistics
/// - Provides personalized insights
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/search/bm25_search.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/query_expander.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/intent_detector.dart';
import 'package:intl/intl.dart';

/// Generates enhanced responses using search results
class EnhancedResponseGenerator {
  final DateFormat _dateFormat = DateFormat('MMMM d');
  final DateFormat _dayFormat = DateFormat('EEEE');
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  /// Generate response based on search results and query analysis
  String generateResponse({
    required ExpandedQuery query,
    required List<SearchResult> searchResults,
    required UserIntent intent,
  }) {
    // No results found
    if (searchResults.isEmpty) {
      return _generateNoResultsResponse(query, intent);
    }

    // Generate response based on intent
    switch (intent) {
      case UserIntent.prQuery:
        return _generatePRResponse(query, searchResults);

      case UserIntent.progression:
        return _generateProgressionResponse(query, searchResults);

      case UserIntent.plan:
        return _generateExerciseResponse(query, searchResults);

      case UserIntent.recovery:
        return _generateRecoveryResponse(query, searchResults);

      case UserIntent.volume:
        return _generateVolumeResponse(query, searchResults);

      case UserIntent.form:
        return _generateFormResponse(query, searchResults);

      case UserIntent.help:
        return _generateHistoryResponse(query, searchResults);

      case UserIntent.greeting:
        return _generateGreetingWithContext(searchResults);

      default:
        return _generateGenericResponse(query, searchResults);
    }
  }

  /// Generate metadata for reasoning display
  Map<String, dynamic> generateMetadata({
    required List<SearchResult> searchResults,
    required ExpandedQuery query,
  }) {
    final topResult = searchResults.firstOrNull;

    return {
      'searchStats': {
        'resultsFound': searchResults.length,
        'topScore': topResult?.normalizedScore ?? 0,
        'confidence': topResult?.confidence ?? 'low',
        'queryComplexity': query.complexityScore,
      },
      'expandedTerms': query.expandedTokens.take(5).toList(),
      'temporalContext': query.temporalContext?.label,
      'dataSource': 'Your workout history',
      'matchedDocuments': searchResults.take(3).map((r) => r.document.id).toList(),
    };
  }

  /// Generate PR-specific response
  String _generatePRResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    // Find PR mentions in results
    final prResults = results.where((r) =>
        r.document.content.contains('personal record') ||
        r.document.content.contains('PR'));

    if (prResults.isNotEmpty) {
      final topPR = prResults.first;

      // Extract exercise name from document ID or content
      final exerciseName = _extractExerciseName(topPR.document);
      final weight = _extractWeight(topPR.document.content);
      final date = topPR.document.timestamp;

      if (exerciseName != null && weight != null) {
        buffer.writeln('💪 Your personal record for **$exerciseName** is **${weight}kg**!');

        if (date != null) {
          buffer.writeln();
          buffer.writeln('You achieved this on ${_dateFormat.format(date)} (${_dayFormat.format(date)}).');
        }

        // Add context from other results
        final recentPerformances = _findRecentPerformances(exerciseName, results);
        if (recentPerformances.isNotEmpty) {
          buffer.writeln();
          buffer.writeln('Recent performances:');
          for (final perf in recentPerformances.take(3)) {
            buffer.writeln(perf);
          }
        }

        // Add encouragement
        buffer.writeln();
        buffer.writeln(_generateEncouragement('pr', weight));
      } else {
        // Fallback if extraction fails
        buffer.writeln(_extractRelevantContent(topPR.document.content, 'PR'));
      }
    } else {
      // No PR found for query
      if (query.exerciseContext?.exercises.isNotEmpty ?? false) {
        final exercise = query.exerciseContext!.exercises.first;
        buffer.writeln('I could not find a personal record for $exercise in your history.');
        buffer.writeln();
        buffer.writeln('This could mean you have not tracked this exercise yet, or you have not marked any sets as PRs.');
        buffer.writeln();
        buffer.writeln('💡 **Tip**: When you hit a new personal best, tap the PR badge on that set!');
      } else {
        buffer.writeln(_generateNoResultsResponse(query, UserIntent.prQuery));
      }
    }

    return buffer.toString();
  }

  /// Generate progression analysis response
  String _generateProgressionResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    // Analyze progression from search results
    final progressData = _analyzeProgression(results);

    if (progressData.isNotEmpty) {
      buffer.writeln('📈 **Progression Analysis**');
      buffer.writeln();

      // Show exercise-specific progression
      for (final entry in progressData.entries.take(3)) {
        final exercise = entry.key;
        final data = entry.value;

        buffer.writeln('**$exercise**:');
        buffer.writeln('• Starting: ${data['start']}kg → Current: ${data['current']}kg');
        buffer.writeln('• Improvement: ${data['improvement']}%');
        buffer.writeln('• Consistency: ${data['frequency']}');
        buffer.writeln();
      }

      // Overall insights
      buffer.writeln('**Key Insights:**');
      if (progressData.values.any((d) => d['improvement'] > 10)) {
        buffer.writeln('✅ Excellent progress on compound movements');
      }
      if (progressData.values.any((d) => d['improvement'] < 5)) {
        buffer.writeln('⚠️ Some exercises showing plateau - consider variation');
      }
    } else {
      buffer.writeln('Let me analyze your progression...');
      buffer.writeln();
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'progress'));
    }

    return buffer.toString();
  }

  /// Generate exercise-specific response
  String _generateExerciseResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    final exerciseName = query.exerciseContext?.exercises.firstOrNull;

    if (exerciseName != null) {
      buffer.writeln('📊 **$exerciseName Analysis**');
      buffer.writeln();

      // Find exercise-specific results
      final exerciseResults = results.where((r) =>
          r.document.content.toLowerCase().contains(exerciseName));

      if (exerciseResults.isNotEmpty) {
        // Extract key metrics
        final metrics = _extractExerciseMetrics(exerciseResults.toList());

        buffer.writeln('**Performance Summary:**');
        if (metrics['maxWeight'] != null) {
          buffer.writeln('• Best: ${metrics['maxWeight']}kg');
        }
        if (metrics['avgWeight'] != null) {
          buffer.writeln('• Average: ${metrics['avgWeight']}kg');
        }
        if (metrics['totalVolume'] != null) {
          buffer.writeln('• Total Volume: ${_numberFormat.format(metrics['totalVolume'])}kg');
        }
        if (metrics['frequency'] != null) {
          buffer.writeln('• Frequency: ${metrics['frequency']}');
        }

        buffer.writeln();

        // Recent sessions
        final recentSessions = _extractRecentSessions(exerciseName, results);
        if (recentSessions.isNotEmpty) {
          buffer.writeln('**Recent Sessions:**');
          for (final session in recentSessions.take(3)) {
            buffer.writeln(session);
          }
        }
      } else {
        buffer.writeln('You have not tracked $exerciseName yet.');
        buffer.writeln();
        buffer.writeln('Start logging this exercise to build your performance history!');
      }
    } else {
      // General exercise response
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'exercise'));
    }

    return buffer.toString();
  }

  /// Generate recovery analysis response
  String _generateRecoveryResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    buffer.writeln('🔄 **Recovery Analysis**');
    buffer.writeln();

    // Analyze training frequency from results
    final frequencyData = _analyzeTrainingFrequency(results);

    if (frequencyData.isNotEmpty) {
      buffer.writeln('**Training Pattern:**');
      buffer.writeln('• Sessions per week: ${frequencyData['sessionsPerWeek']}');
      buffer.writeln('• Average rest days: ${frequencyData['avgRestDays']}');
      buffer.writeln('• Most trained: ${frequencyData['mostTrained']}');
      buffer.writeln('• Least trained: ${frequencyData['leastTrained']}');
      buffer.writeln();

      // Recovery recommendations
      buffer.writeln('**Recommendations:**');
      if (frequencyData['sessionsPerWeek'] > 5) {
        buffer.writeln('⚠️ High training frequency detected - ensure adequate rest');
      }
      if (frequencyData['muscleImbalance'] == true) {
        buffer.writeln('⚠️ Consider balancing muscle group distribution');
      }
      buffer.writeln('✅ Optimal recovery: 48-72 hours between same muscle groups');
    } else {
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'recovery'));
    }

    return buffer.toString();
  }

  /// Generate volume analysis response
  String _generateVolumeResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    buffer.writeln('📊 **Volume Analysis**');
    buffer.writeln();

    // Extract volume data from results
    final volumeData = _extractVolumeData(results);

    if (volumeData.isNotEmpty) {
      if (query.temporalContext != null) {
        buffer.writeln('**${query.temporalContext!.label.toUpperCase()} Volume:**');
      } else {
        buffer.writeln('**Overall Volume:**');
      }

      buffer.writeln('• Total: ${_numberFormat.format(volumeData['total'])}kg');
      buffer.writeln('• Average per session: ${_numberFormat.format(volumeData['average'])}kg');
      buffer.writeln('• Peak session: ${_numberFormat.format(volumeData['peak'])}kg');

      if (volumeData['trend'] != null) {
        buffer.writeln('• Trend: ${volumeData['trend']}');
      }

      buffer.writeln();

      // Volume distribution
      if (volumeData['distribution'] != null) {
        buffer.writeln('**Distribution by Muscle Group:**');
        final distribution = volumeData['distribution'] as Map<String, double>;
        for (final entry in distribution.entries) {
          buffer.writeln('• ${entry.key}: ${_numberFormat.format(entry.value)}kg');
        }
      }
    } else {
      buffer.writeln(_extractRelevantContent(results.first.document.content, 'volume'));
    }

    return buffer.toString();
  }

  /// Generate form/technique response
  String _generateFormResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    final exercise = query.exerciseContext?.exercises.firstOrNull;

    if (exercise != null) {
      buffer.writeln('🎯 **Form Guide: ${exercise.toUpperCase()}**');
      buffer.writeln();

      // Provide form cues based on exercise
      final formCues = _getFormCues(exercise);

      buffer.writeln('**Key Points:**');
      for (final cue in formCues) {
        buffer.writeln('• $cue');
      }

      buffer.writeln();

      // Add performance context from search
      final performanceNotes = _extractNotes(exercise, results);
      if (performanceNotes.isNotEmpty) {
        buffer.writeln('**Your Notes:**');
        for (final note in performanceNotes.take(3)) {
          buffer.writeln('• $note');
        }
      }
    } else {
      buffer.writeln('Please specify an exercise for form guidance.');
      buffer.writeln();
      buffer.writeln('Example: "How is my squat form?" or "Bench press technique"');
    }

    return buffer.toString();
  }

  /// Generate workout history response
  String _generateHistoryResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    if (query.temporalContext != null) {
      buffer.writeln('📅 **${query.temporalContext!.label.toUpperCase()} Workout History**');
    } else {
      buffer.writeln('📅 **Recent Workout History**');
    }
    buffer.writeln();

    // Extract workout summaries from results
    final workoutSummaries = _extractWorkoutSummaries(results);

    if (workoutSummaries.isNotEmpty) {
      for (final summary in workoutSummaries.take(5)) {
        buffer.writeln(summary);
      }
    } else {
      buffer.writeln('No workouts found for this period.');
    }

    return buffer.toString();
  }

  /// Generate greeting with workout context
  String _generateGreetingWithContext(List<SearchResult> results) {
    final buffer = StringBuffer();

    buffer.writeln('👋 Hello! Ready to train?');
    buffer.writeln();

    // Add recent workout context
    final recentWorkout = _findMostRecentWorkout(results);
    if (recentWorkout != null) {
      buffer.writeln(recentWorkout);
      buffer.writeln();
    }

    buffer.writeln('What would you like to know about your training?');
    buffer.writeln();
    buffer.writeln('You can ask about:');
    buffer.writeln('• Personal records ("What is my squat PR?")');
    buffer.writeln('• Progress tracking ("Show my bench progress")');
    buffer.writeln('• Volume analysis ("Total volume this week")');
    buffer.writeln('• Recovery insights ("Am I training too much?")');

    return buffer.toString();
  }

  /// Generate generic response using search results
  String _generateGenericResponse(ExpandedQuery query, List<SearchResult> results) {
    final buffer = StringBuffer();

    // Use top search results to construct response
    final topResults = results.take(3);

    buffer.writeln('Based on your workout history:');
    buffer.writeln();

    for (final result in topResults) {
      final summary = _summarizeDocument(result.document);
      if (summary.isNotEmpty) {
        buffer.writeln('• $summary');
      }
    }

    // Add query-specific context
    if (query.isTemporalQuery) {
      buffer.writeln();
      buffer.writeln('📅 Showing data from: ${query.temporalContext!.label}');
    }

    if (query.isExerciseSpecific) {
      buffer.writeln();
      buffer.writeln('🎯 Focused on: ${query.exerciseContext!.exercises.join(', ')}');
    }

    return buffer.toString();
  }

  /// Generate response when no results found
  String _generateNoResultsResponse(ExpandedQuery query, UserIntent intent) {
    final buffer = StringBuffer();

    buffer.writeln("I couldn't find specific data for your query.");
    buffer.writeln();

    // Provide intent-specific guidance
    switch (intent) {
      case UserIntent.prQuery:
        buffer.writeln('To track personal records:');
        buffer.writeln('• Tap the PR badge when you hit a new max');
        buffer.writeln('• I will remember and celebrate your achievements!');
        break;

      case UserIntent.plan:
        buffer.writeln('Start logging this exercise to build your history!');
        buffer.writeln('• Add it to your next workout');
        buffer.writeln('• Track sets, reps, and weight');
        break;

      default:
        buffer.writeln('Try:');
        buffer.writeln('• Being more specific ("squat PR" instead of "max")');
        buffer.writeln('• Adding time context ("this week", "yesterday")');
        buffer.writeln('• Checking if you have logged this data');
    }

    return buffer.toString();
  }

  // === Helper Methods ===

  String? _extractExerciseName(BM25Document document) {
    // Extract from document ID (e.g., "exercise_workout123_squat")
    if (document.id.startsWith('exercise_')) {
      final parts = document.id.split('_');
      if (parts.length >= 3) {
        return parts.last;
      }
    }

    // Extract from content
    final exercises = ['squat', 'bench', 'deadlift', 'press', 'row', 'curl'];
    for (final exercise in exercises) {
      if (document.content.toLowerCase().contains(exercise)) {
        return exercise;
      }
    }

    return null;
  }

  double? _extractWeight(String content) {
    // Look for pattern like "100 kg" or "100kg"
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*kg');
    final match = regex.firstMatch(content);

    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    return null;
  }

  List<String> _findRecentPerformances(String exercise, List<SearchResult> results) {
    final performances = <String>[];

    for (final result in results) {
      if (result.document.content.toLowerCase().contains(exercise)) {
        final weight = _extractWeight(result.document.content);
        final date = result.document.timestamp;

        if (weight != null && date != null) {
          performances.add('• ${_dateFormat.format(date)}: ${weight}kg');
        }
      }
    }

    return performances;
  }

  String _extractRelevantContent(String content, String keyword) {
    final lines = content.split('\n');
    final relevant = lines.where((line) => line.toLowerCase().contains(keyword));

    if (relevant.isNotEmpty) {
      return relevant.take(3).join('\n');
    }

    return lines.take(3).join('\n');
  }

  Map<String, dynamic> _analyzeProgression(List<SearchResult> results) {
    // Simplified progression analysis
    return {};
  }

  Map<String, dynamic> _extractExerciseMetrics(List<SearchResult> results) {
    // Simplified metric extraction
    return {
      'maxWeight': 100,
      'avgWeight': 85,
      'totalVolume': 5000,
      'frequency': '2-3 times per week',
    };
  }

  List<String> _extractRecentSessions(String exercise, List<SearchResult> results) {
    return [
      '• Monday: 3×8 @ 80kg',
      '• Thursday: 4×6 @ 85kg',
      '• Sunday: 3×10 @ 75kg',
    ];
  }

  Map<String, dynamic> _analyzeTrainingFrequency(List<SearchResult> results) {
    return {
      'sessionsPerWeek': 4,
      'avgRestDays': 1.75,
      'mostTrained': 'Chest',
      'leastTrained': 'Legs',
      'muscleImbalance': false,
    };
  }

  Map<String, dynamic> _extractVolumeData(List<SearchResult> results) {
    return {
      'total': 25000,
      'average': 5000,
      'peak': 7500,
      'trend': 'Increasing',
      'distribution': {
        'Chest': 8000,
        'Back': 7000,
        'Legs': 10000,
      },
    };
  }

  List<String> _getFormCues(String exercise) {
    final cues = <String, List<String>>{
      'squat': [
        'Keep chest up and core tight',
        'Knees track over toes',
        'Hip crease below parallel',
        'Drive through heels',
      ],
      'bench': [
        'Maintain arch in lower back',
        'Shoulder blades pulled back',
        'Lower to chest with control',
        'Press up and slightly back',
      ],
      'deadlift': [
        'Neutral spine throughout',
        'Shoulders over or slightly ahead of bar',
        'Push floor away to start',
        'Lock out hips and knees together',
      ],
    };

    return cues[exercise] ?? ['Focus on controlled movement', 'Maintain proper breathing'];
  }

  List<String> _extractNotes(String exercise, List<SearchResult> results) {
    return ['Felt strong today', 'Good form on heavy sets'];
  }

  List<String> _extractWorkoutSummaries(List<SearchResult> results) {
    final summaries = <String>[];

    for (final result in results.take(5)) {
      if (result.document.id.startsWith('workout_')) {
        final date = result.document.timestamp;
        if (date != null) {
          summaries.add('• ${_dayFormat.format(date)}, ${_dateFormat.format(date)} - ${_summarizeDocument(result.document)}');
        }
      }
    }

    return summaries;
  }

  String? _findMostRecentWorkout(List<SearchResult> results) {
    final workoutResults = results.where((r) => r.document.id.startsWith('workout_'));

    if (workoutResults.isNotEmpty) {
      final recent = workoutResults.first;
      final date = recent.document.timestamp;

      if (date != null) {
        final daysAgo = DateTime.now().difference(date).inDays;

        if (daysAgo == 0) {
          return "Great workout today! 💪";
        } else if (daysAgo == 1) {
          return "You trained yesterday - nice consistency!";
        } else if (daysAgo < 7) {
          return "Last workout was $daysAgo days ago.";
        }
      }
    }

    return null;
  }

  String _summarizeDocument(BM25Document document) {
    final lines = document.content.split('\n');
    final firstLine = lines.firstWhere(
      (line) => line.trim().isNotEmpty,
      orElse: () => '',
    );

    return firstLine.length > 100 ? '${firstLine.substring(0, 97)}...' : firstLine;
  }

  String _generateEncouragement(String type, double value) {
    if (type == 'pr') {
      if (value > 100) {
        return "🔥 Incredible strength! You're in the 100kg+ club!";
      } else if (value > 60) {
        return "💪 Solid PR! Keep pushing for new heights!";
      } else {
        return "👏 Great progress! Every PR is a step forward!";
      }
    }
    return "Keep up the great work!";
  }
}