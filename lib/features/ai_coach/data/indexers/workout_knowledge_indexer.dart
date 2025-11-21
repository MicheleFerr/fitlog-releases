/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/indexers
/// 🎯 Feature: ai_coach
/// 🔧 Type: indexer
///
/// Workout Knowledge Indexer - Converts workout data to searchable documents
///
/// **Features**:
/// - Indexes workouts, exercises, and analytics data
/// - Creates rich text representations for BM25 search
/// - Extracts key metrics and patterns
/// - Optimizes for fitness-specific queries
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/search/bm25_search.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:intl/intl.dart';

/// Indexes workout data into searchable knowledge base
class WorkoutKnowledgeIndexer {
  final BM25SearchEngine searchEngine;
  final DateFormat _dateFormat = DateFormat('MMMM d, y');
  final DateFormat _dayFormat = DateFormat('EEEE');

  // Cache for performance
  final Map<String, BM25Document> _documentCache = {};

  WorkoutKnowledgeIndexer({
    required this.searchEngine,
  });

  /// Index all workouts for a user
  Future<void> indexWorkouts(List<Workout> workouts) async {
    searchEngine.clear();
    _documentCache.clear();

    final documents = <BM25Document>[];

    for (final workout in workouts) {
      // Index workout summary
      documents.add(_createWorkoutDocument(workout));

      // Index individual exercises
      for (final exercise in workout.exercises) {
        documents.add(_createExerciseDocument(exercise, workout));
      }

      // Index supersets if present
      final hasSupersets = workout.exercises.any((e) => e.type == ExerciseType.superset);
      if (hasSupersets) {
        documents.add(_createSupersetDocument(workout));
      }
    }

    searchEngine.addDocuments(documents);
  }

  /// Index exercise history data for richer search
  Future<void> indexExerciseHistories(List<ExerciseHistory> histories) async {
    final documents = <BM25Document>[];

    for (final history in histories) {
      documents.add(_createExerciseHistoryDocument(history));
    }

    searchEngine.addDocuments(documents);
  }

  /// Create searchable document from workout
  BM25Document _createWorkoutDocument(Workout workout) {
    final workoutDate = workout.startTime ?? workout.createdAt;
    final dateStr = _dateFormat.format(workoutDate);
    final dayStr = _dayFormat.format(workoutDate);
    final duration = workout.duration?.inMinutes ?? 0;

    // Build rich text representation
    final content = StringBuffer();

    // Temporal information
    content.writeln('workout on $dateStr $dayStr');

    // Workout name if exists
    if (workout.name.isNotEmpty) {
      content.writeln('workout named ${workout.name}');
    }

    // Exercise summary
    final exerciseNames = workout.exercises
        .map((e) => e.name.toLowerCase())
        .toSet()
        .join(' ');
    content.writeln('exercises performed $exerciseNames');

    // Volume and stats
    final totalVolume = _calculateTotalVolume(workout);
    final totalSets = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets.length,
    );

    content.writeln('total volume $totalVolume kg');
    content.writeln('completed $totalSets sets');
    content.writeln('workout duration $duration minutes');

    // Exercise categories
    final categories = workout.exercises
        .map((e) => e.category.name.toLowerCase())
        .toSet()
        .join(' ');
    content.writeln('categories trained $categories');

    // Special patterns
    final hasSupersets = workout.exercises.any((e) => e.type == ExerciseType.superset);
    final hasDropsets = workout.exercises.any((e) => e.type == ExerciseType.dropset);

    if (hasSupersets) {
      content.writeln('superset workout');
    }
    if (hasDropsets) {
      content.writeln('dropset included');
    }

    return BM25Document(
      id: 'workout_${workout.id}',
      content: content.toString(),
      timestamp: workoutDate,
      boost: 1.2, // Workouts get slight boost over individual exercises
    );
  }

  /// Create searchable document from exercise
  BM25Document _createExerciseDocument(
    Exercise exercise,
    Workout workout,
  ) {
    final workoutDate = workout.startTime ?? workout.createdAt;
    final dateStr = _dateFormat.format(workoutDate);

    final content = StringBuffer();

    // Exercise identification
    content.writeln('${exercise.name} exercise on $dateStr');

    // Performance data
    for (int i = 0; i < exercise.sets.length; i++) {
      final set = exercise.sets[i];
      if (set.weight != null && set.reps != null) {
        content.writeln('set ${i + 1} ${set.weight} kg ${set.reps} reps');
      } else if (set.reps != null) {
        content.writeln('set ${i + 1} ${set.reps} reps bodyweight');
      } else if (set.seconds != null) {
        content.writeln('set ${i + 1} ${set.seconds} seconds');
      }
    }

    // Volume for this exercise
    final volume = _calculateExerciseVolume(exercise);
    content.writeln('exercise volume $volume kg');

    // Exercise type and category
    content.writeln('exercise type ${exercise.type.name}');
    content.writeln('category ${exercise.category.name}');

    // Special techniques
    if (exercise.type == ExerciseType.dropset) {
      content.writeln('dropset technique used');
    }
    if (exercise.type == ExerciseType.restPause) {
      content.writeln('rest pause technique');
    }

    // Notes if present
    if (exercise.notes?.isNotEmpty ?? false) {
      content.writeln('notes ${exercise.notes}');
    }

    return BM25Document(
      id: 'exercise_${workout.id}_${exercise.id}',
      content: content.toString(),
      timestamp: workoutDate,
      boost: 1.0,
    );
  }

  /// Create document for superset patterns
  BM25Document _createSupersetDocument(Workout workout) {
    final workoutDate = workout.startTime ?? workout.createdAt;
    final dateStr = _dateFormat.format(workoutDate);
    final content = StringBuffer();

    content.writeln('superset workout on $dateStr');

    // Find superset exercises
    final supersetExercises = workout.exercises
        .where((e) => e.type == ExerciseType.superset)
        .map((e) => e.name)
        .toList();

    for (final exerciseName in supersetExercises) {
      content.writeln('superset exercise $exerciseName');
    }

    content.writeln('advanced training technique superset');
    content.writeln('minimal rest between exercises');

    return BM25Document(
      id: 'superset_${workout.id}',
      content: content.toString(),
      timestamp: workoutDate,
      boost: 1.1, // Slight boost for advanced techniques
    );
  }

  /// Create document from exercise history data
  BM25Document _createExerciseHistoryDocument(ExerciseHistory history) {
    final content = StringBuffer();

    // Exercise name
    content.writeln('${history.exerciseName} exercise history');

    // Session count
    content.writeln('performed ${history.sessions.length} times total');

    // Muscle group
    content.writeln('targets ${history.muscleGroup} muscles');

    // If we have recent sessions, mention them
    if (history.sessions.isNotEmpty) {
      content.writeln('tracked exercise workout history');

      // Calculate some basic stats if possible
      content.writeln('exercise progression data available');

      // Personal record if available
      if (history.personalRecord > 0) {
        content.writeln('personal record ${history.personalRecord.toStringAsFixed(1)} kg estimated 1RM');
      }
    }

    return BM25Document(
      id: 'history_${history.exerciseName.replaceAll(' ', '_')}',
      content: content.toString(),
      timestamp: DateTime.now(), // History data is current
      boost: 1.2, // History gets slight boost for insights
    );
  }

  /// Calculate total volume for a workout
  double _calculateTotalVolume(Workout workout) {
    return workout.exercises.fold<double>(
      0,
      (sum, exercise) => sum + _calculateExerciseVolume(exercise),
    );
  }

  /// Calculate volume for an exercise
  double _calculateExerciseVolume(Exercise exercise) {
    return exercise.sets.fold<double>(
      0,
      (sum, set) {
        if (set.weight != null && set.reps != null) {
          return sum + (set.weight! * set.reps!);
        }
        return sum;
      },
    );
  }

  /// Create knowledge snippets for common queries
  List<BM25Document> createKnowledgeSnippets({
    required String userId,
    required List<Workout> workouts,
  }) {
    final snippets = <BM25Document>[];

    // Recent workout summary
    if (workouts.isNotEmpty) {
      final recent = workouts.first;
      final workoutDate = recent.startTime ?? recent.createdAt;
      snippets.add(BM25Document(
        id: 'snippet_recent',
        content: 'most recent workout was on ${_dateFormat.format(workoutDate)} '
            'with ${recent.exercises.length} exercises '
            'total volume ${_calculateTotalVolume(recent)} kg',
        timestamp: DateTime.now(),
        boost: 1.5,
      ));
    }

    // Favorite exercises (most frequent)
    final exerciseFrequency = <String, int>{};
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        final name = exercise.name;
        exerciseFrequency[name] = (exerciseFrequency[name] ?? 0) + 1;
      }
    }

    final topExercises = exerciseFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topExercises.isNotEmpty) {
      final top3 = topExercises.take(3).map((e) => e.key).join(', ');
      snippets.add(BM25Document(
        id: 'snippet_favorites',
        content: 'favorite exercises most performed are $top3 '
            'based on ${workouts.length} workouts',
        timestamp: DateTime.now(),
        boost: 1.4,
      ));
    }

    // Workout patterns
    final weekdayCount = <int, int>{};
    for (final workout in workouts) {
      final workoutDate = workout.startTime ?? workout.createdAt;
      weekdayCount[workoutDate.weekday] =
          (weekdayCount[workoutDate.weekday] ?? 0) + 1;
    }

    final preferredDay = weekdayCount.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    final dayName = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
                     'Friday', 'Saturday', 'Sunday'][preferredDay.key];

    snippets.add(BM25Document(
      id: 'snippet_pattern',
      content: 'workout pattern shows preference for $dayName '
          'with ${preferredDay.value} workouts on this day',
      timestamp: DateTime.now(),
      boost: 1.2,
    ));

    return snippets;
  }

  /// Extract key terms from user's workout history for query expansion
  Set<String> extractKeyTerms(List<Workout> workouts) {
    final terms = <String>{};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        // Exercise names
        terms.add(exercise.name.toLowerCase());

        // Exercise types
        terms.add(exercise.type.name.toLowerCase());

        // Categories
        terms.add(exercise.category.name.toLowerCase());
      }
    }

    return terms;
  }
}