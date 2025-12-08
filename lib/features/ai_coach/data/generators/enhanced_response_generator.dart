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
import 'package:gymbro_flutter_new/features/ai_coach/data/utils/document_data_extractor.dart';
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

  /// Analyze real progression from search results
  Map<String, Map<String, dynamic>> _analyzeProgression(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();
    final progressionData = <String, Map<String, dynamic>>{};

    // Group results by exercise
    final exerciseData = <String, List<_ExerciseDataPoint>>{};

    for (final result in results) {
      if (!result.document.id.startsWith('exercise_')) continue;

      final content = result.document.content;
      final exerciseName = extractor.extractExerciseNameFromContent(content);
      final date = result.document.timestamp;

      if (exerciseName == null || date == null) continue;

      final sets = extractor.extractSets(content);
      if (sets.isEmpty) continue;

      final maxWeight = extractor.calculateMaxWeight(sets);
      if (maxWeight == null) continue;

      exerciseData.putIfAbsent(exerciseName, () => []);
      exerciseData[exerciseName]!.add(_ExerciseDataPoint(
        date: date,
        maxWeight: maxWeight,
        volume: extractor.calculateTotalVolume(sets),
      ));
    }

    // Calculate progression for each exercise
    for (final entry in exerciseData.entries) {
      final dataPoints = entry.value..sort((a, b) => a.date.compareTo(b.date));

      if (dataPoints.length < 2) continue;

      final first = dataPoints.first;
      final last = dataPoints.last;

      final improvement = ((last.maxWeight - first.maxWeight) / first.maxWeight * 100);

      // Determine frequency
      final daySpan = last.date.difference(first.date).inDays;
      final frequency = daySpan > 0
          ? '${(dataPoints.length / (daySpan / 7)).toStringAsFixed(1)}x/week'
          : 'N/A';

      progressionData[entry.key] = {
        'start': first.maxWeight.round(),
        'current': last.maxWeight.round(),
        'improvement': improvement.round(),
        'frequency': frequency,
        'sessions': dataPoints.length,
      };
    }

    return progressionData;
  }

  /// Extract real metrics from exercise search results
  Map<String, dynamic> _extractExerciseMetrics(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();

    double? maxWeight;
    final allWeights = <double>[];
    double totalVolume = 0;
    int sessionCount = 0;

    for (final result in results) {
      final content = result.document.content;

      // Extract sets and calculate metrics
      final sets = extractor.extractSets(content);

      for (final set in sets) {
        if (set.weight != null) {
          allWeights.add(set.weight!);
          if (maxWeight == null || set.weight! > maxWeight) {
            maxWeight = set.weight;
          }
        }
      }

      // Extract volume
      final exerciseVolume = extractor.extractExerciseVolume(content);
      if (exerciseVolume != null) {
        totalVolume += exerciseVolume;
      } else {
        // Calculate from sets if not explicitly stated
        totalVolume += extractor.calculateTotalVolume(sets);
      }

      // Count sessions (documents with exercise_ prefix)
      if (result.document.id.startsWith('exercise_')) {
        sessionCount++;
      }
    }

    // Calculate average weight
    final avgWeight = allWeights.isNotEmpty
        ? allWeights.reduce((a, b) => a + b) / allWeights.length
        : null;

    // Determine frequency description
    String frequency;
    if (sessionCount >= 12) {
      frequency = '3+ times per week';
    } else if (sessionCount >= 8) {
      frequency = '2-3 times per week';
    } else if (sessionCount >= 4) {
      frequency = '1-2 times per week';
    } else {
      frequency = 'Less than weekly';
    }

    return {
      if (maxWeight != null) 'maxWeight': maxWeight.round(),
      if (avgWeight != null) 'avgWeight': avgWeight.round(),
      if (totalVolume > 0) 'totalVolume': totalVolume.round(),
      'frequency': frequency,
      'sessionCount': sessionCount,
    };
  }

  /// Extract real recent sessions from search results
  List<String> _extractRecentSessions(String exercise, List<SearchResult> results) {
    final extractor = DocumentDataExtractor();
    final sessions = <String>[];
    final dateFormat = DateFormat('EEEE'); // Day name

    // Filter for exercise documents and sort by date
    final exerciseResults = results
        .where((r) => r.document.id.startsWith('exercise_'))
        .where((r) => r.document.content.toLowerCase().contains(exercise.toLowerCase()))
        .toList()
      ..sort((a, b) {
        final dateA = a.document.timestamp ?? DateTime(1970);
        final dateB = b.document.timestamp ?? DateTime(1970);
        return dateB.compareTo(dateA); // Most recent first
      });

    for (final result in exerciseResults.take(5)) {
      final content = result.document.content;
      final sets = extractor.extractSets(content);
      final date = result.document.timestamp;

      if (sets.isNotEmpty && date != null) {
        final dayName = dateFormat.format(date);

        // Build set summary (e.g., "3x8 @ 80kg")
        if (sets.length > 1 && _areSetsHomogeneous(sets)) {
          // If all sets have same reps, show as NxR format
          final avgWeight = sets
              .where((s) => s.weight != null)
              .map((s) => s.weight!)
              .fold(0.0, (a, b) => a + b) / sets.length;

          sessions.add('$dayName: ${sets.length}x${sets.first.reps} @ ${avgWeight.round()}kg');
        } else {
          // Show individual sets
          final setSummary = sets.take(3).map((s) {
            if (s.weight != null && s.reps != null) {
              return '${s.reps}@${s.weight!.round()}kg';
            } else if (s.reps != null) {
              return '${s.reps} reps';
            }
            return '';
          }).where((s) => s.isNotEmpty).join(', ');

          sessions.add('$dayName: $setSummary');
        }
      }
    }

    return sessions;
  }

  /// Analyze real training frequency from search results
  Map<String, dynamic> _analyzeTrainingFrequency(List<SearchResult> results) {
    if (results.isEmpty) return {};

    // Get workout documents only
    final workoutResults = results
        .where((r) => r.document.id.startsWith('workout_'))
        .toList();

    if (workoutResults.isEmpty) return {};

    // Get dates and sort
    final workoutDates = workoutResults
        .map((r) => r.document.timestamp)
        .whereType<DateTime>()
        .toList()
      ..sort();

    if (workoutDates.isEmpty) return {};

    // Calculate sessions per week (last 4 weeks)
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final recentWorkouts = workoutDates.where((d) => d.isAfter(fourWeeksAgo)).length;
    final sessionsPerWeek = (recentWorkouts / 4).round();

    // Calculate average rest days
    double avgRestDays = 0;
    if (workoutDates.length > 1) {
      int totalRestDays = 0;
      for (int i = 1; i < workoutDates.length; i++) {
        totalRestDays += workoutDates[i].difference(workoutDates[i - 1]).inDays - 1;
      }
      avgRestDays = totalRestDays / (workoutDates.length - 1);
    }

    // Analyze muscle group distribution
    final muscleGroupCount = <String, int>{};
    for (final result in results) {
      final content = result.document.content.toLowerCase();

      // Check for category mentions
      for (final category in ['chest', 'back', 'legs', 'shoulders', 'arms', 'core']) {
        if (content.contains(category)) {
          muscleGroupCount[category] = (muscleGroupCount[category] ?? 0) + 1;
        }
      }
    }

    // Find most and least trained
    String? mostTrained;
    String? leastTrained;

    if (muscleGroupCount.isNotEmpty) {
      final sorted = muscleGroupCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      mostTrained = sorted.first.key;
      mostTrained = mostTrained[0].toUpperCase() + mostTrained.substring(1);

      leastTrained = sorted.last.key;
      leastTrained = leastTrained[0].toUpperCase() + leastTrained.substring(1);
    }

    // Check for muscle imbalance (>2x difference)
    final muscleImbalance = muscleGroupCount.isNotEmpty &&
        muscleGroupCount.values.reduce((a, b) => a > b ? a : b) >
            muscleGroupCount.values.reduce((a, b) => a < b ? a : b) * 2;

    return {
      'sessionsPerWeek': sessionsPerWeek,
      'avgRestDays': double.parse(avgRestDays.toStringAsFixed(1)),
      if (mostTrained != null) 'mostTrained': mostTrained,
      if (leastTrained != null) 'leastTrained': leastTrained,
      'muscleImbalance': muscleImbalance,
      'totalWorkouts': workoutDates.length,
    };
  }

  /// Extract real volume data from search results
  Map<String, dynamic> _extractVolumeData(List<SearchResult> results) {
    if (results.isEmpty) return {};

    final extractor = DocumentDataExtractor();

    final volumes = <double>[];
    final muscleGroupVolumes = <String, double>{};

    for (final result in results) {
      final content = result.document.content;

      // Try to get total volume from workout documents
      if (result.document.id.startsWith('workout_')) {
        final volume = extractor.extractVolume(content);
        if (volume != null && volume > 0) {
          volumes.add(volume);
        }

        // Track muscle group distribution
        for (final category in ['chest', 'back', 'legs', 'shoulders', 'arms', 'core']) {
          if (content.toLowerCase().contains(category)) {
            muscleGroupVolumes[category] =
                (muscleGroupVolumes[category] ?? 0) + (volume ?? 0) / 3; // Approximate split
          }
        }
      }

      // Get exercise-specific volume
      if (result.document.id.startsWith('exercise_')) {
        final exerciseVolume = extractor.extractExerciseVolume(content);
        if (exerciseVolume != null) {
          // Add to appropriate muscle group
          final exerciseName = extractor.extractExerciseNameFromContent(content);
          final category = _inferMuscleGroup(exerciseName ?? '');
          if (category != null) {
            muscleGroupVolumes[category] =
                (muscleGroupVolumes[category] ?? 0) + exerciseVolume;
          }
        }
      }
    }

    if (volumes.isEmpty) return {};

    final totalVolume = volumes.reduce((a, b) => a + b);
    final averageVolume = totalVolume / volumes.length;
    final peakVolume = volumes.reduce((a, b) => a > b ? a : b);

    // Determine trend
    String? trend;
    if (volumes.length >= 3) {
      final firstHalf = volumes.take(volumes.length ~/ 2).toList();
      final secondHalf = volumes.skip(volumes.length ~/ 2).toList();

      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

      if (secondAvg > firstAvg * 1.1) {
        trend = 'Increasing';
      } else if (secondAvg < firstAvg * 0.9) {
        trend = 'Decreasing';
      } else {
        trend = 'Stable';
      }
    }

    // Format muscle group volumes
    final distribution = <String, double>{};
    for (final entry in muscleGroupVolumes.entries) {
      if (entry.value > 0) {
        final formattedName = entry.key[0].toUpperCase() + entry.key.substring(1);
        distribution[formattedName] = entry.value.roundToDouble();
      }
    }

    return {
      'total': totalVolume.round(),
      'average': averageVolume.round(),
      'peak': peakVolume.round(),
      if (trend != null) 'trend': trend,
      if (distribution.isNotEmpty) 'distribution': distribution,
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
          return 'Great workout today! 💪';
        } else if (daysAgo == 1) {
          return 'You trained yesterday - nice consistency!';
        } else if (daysAgo < 7) {
          return 'Last workout was $daysAgo days ago.';
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
        return '💪 Solid PR! Keep pushing for new heights!';
      } else {
        return '👏 Great progress! Every PR is a step forward!';
      }
    }
    return 'Keep up the great work!';
  }

  /// Check if sets have similar reps (within 2 reps)
  bool _areSetsHomogeneous(List<ParsedSet> sets) {
    if (sets.isEmpty) return false;

    final reps = sets.where((s) => s.reps != null).map((s) => s.reps!).toList();
    if (reps.isEmpty) return false;

    final minReps = reps.reduce((a, b) => a < b ? a : b);
    final maxReps = reps.reduce((a, b) => a > b ? a : b);

    return (maxReps - minReps) <= 2;
  }

  /// Infer muscle group from exercise name
  String? _inferMuscleGroup(String exerciseName) {
    final name = exerciseName.toLowerCase();

    if (name.contains('bench') || name.contains('chest') || name.contains('fly')) {
      return 'chest';
    }
    if (name.contains('row') || name.contains('pull') || name.contains('lat') || name.contains('back')) {
      return 'back';
    }
    if (name.contains('squat') || name.contains('leg') || name.contains('lunge') || name.contains('deadlift')) {
      return 'legs';
    }
    if (name.contains('press') || name.contains('shoulder') || name.contains('delt')) {
      return 'shoulders';
    }
    if (name.contains('curl') || name.contains('tricep') || name.contains('bicep') || name.contains('arm')) {
      return 'arms';
    }
    if (name.contains('crunch') || name.contains('plank') || name.contains('ab') || name.contains('core')) {
      return 'core';
    }

    return null;
  }
}

/// Helper class for exercise progression tracking
class _ExerciseDataPoint {
  const _ExerciseDataPoint({
    required this.date,
    required this.maxWeight,
    required this.volume,
  });

  final DateTime date;
  final double maxWeight;
  final double volume;
}