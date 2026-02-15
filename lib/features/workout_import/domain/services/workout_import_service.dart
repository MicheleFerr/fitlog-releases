/// Workout Import Service
///
/// Orchestrates the full import pipeline: text preprocessing,
/// AI parsing, JSON mapping, and fuzzy matching.
///
/// **Layer**: Domain - Service (FAT service, thin provider)
/// **Feature**: Workout Import
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    show ExerciseDefinition;
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout_import/data/datasources/workout_import_ai_client.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/entities/parsed_workout.dart';

/// Service that orchestrates the full workout import pipeline
class WorkoutImportService {
  WorkoutImportService({required this.aiClient});

  final WorkoutImportAiClient aiClient;

  /// Parse text into a structured workout with fuzzy-matched exercises
  Future<ParsedWorkout> parseFromText({
    required String text,
    required List<ExerciseDefinition> exerciseDb,
  }) async {
    // 1. Preprocess text
    final cleaned = _preprocessText(text);
    if (cleaned.isEmpty) {
      throw const FormatException('Empty input text');
    }

    // 2. Call AI to parse text into JSON
    final json = await aiClient.parseText(cleaned);

    // 3. Map JSON to domain entities
    final workout = _mapJsonToWorkout(json, text);

    // 4. Run fuzzy matching against exercise database
    return _matchExercises(workout, exerciseDb);
  }

  /// Parse image into a structured workout with fuzzy-matched exercises
  Future<ParsedWorkout> parseFromImage({
    required String base64Image,
    required List<ExerciseDefinition> exerciseDb,
  }) async {
    // 1. Call AI vision model
    final json = await aiClient.parseImage(base64Image);

    // 2. Map JSON to domain entities
    final workout = _mapJsonToWorkout(json, null);

    // 3. Run fuzzy matching against exercise database
    return _matchExercises(workout, exerciseDb);
  }

  /// Preprocess input text for better AI parsing
  String _preprocessText(String text) {
    var cleaned = text.trim();

    // Normalize common separators
    cleaned = cleaned.replaceAll('×', 'x');
    cleaned = cleaned.replaceAll('X', 'x');

    // Remove excessive blank lines
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned;
  }

  /// Map AI JSON response to domain entities
  ParsedWorkout _mapJsonToWorkout(
    Map<String, dynamic> json,
    String? rawText,
  ) {
    final daysJson = json['days'] as List<dynamic>? ?? [];

    if (daysJson.isEmpty) {
      throw const FormatException('No days found in parsed workout');
    }

    final days = daysJson.map((dayJson) {
      final day = dayJson as Map<String, dynamic>;
      final exercisesJson = day['exercises'] as List<dynamic>? ?? [];

      final exercises = exercisesJson.map((exJson) {
        final ex = exJson as Map<String, dynamic>;
        final setsJson = ex['sets'] as List<dynamic>? ?? [];

        final sets = setsJson.map((setJson) {
          final s = setJson as Map<String, dynamic>;
          return ParsedSet(
            reps: s['reps'] as int?,
            isMaxReps: s['isMaxReps'] as bool? ?? false,
            weight: (s['weight'] as num?)?.toDouble(),
            durationSeconds: s['durationSeconds'] as int?,
            minReps: s['minReps'] as int?,
            maxReps: s['maxReps'] as int?,
          );
        }).toList();

        return ParsedExerciseLine(
          rawName: ex['rawName'] as String? ?? 'Unknown',
          sets: sets,
          restSeconds: ex['restSeconds'] as int?,
          muscleGroup: ex['muscleGroup'] as String?,
          notes: ex['notes'] as String?,
          supersetGroup: ex['supersetGroup'] as String?,
        );
      }).toList();

      return ParsedDay(
        name: day['name'] as String? ?? 'Workout',
        exercises: exercises,
      );
    }).toList();

    return ParsedWorkout(
      days: days,
      rawText: rawText,
      hasMultipleDays: days.length > 1,
    );
  }

  /// Run fuzzy matching on all exercises against the database
  Future<ParsedWorkout> _matchExercises(
    ParsedWorkout workout,
    List<ExerciseDefinition> exerciseDb,
  ) async {
    final matchedDays = <ParsedDay>[];

    for (final day in workout.days) {
      final matchedExercises = <ParsedExerciseLine>[];

      for (final exercise in day.exercises) {
        final matched = await _matchSingleExercise(exercise, exerciseDb);
        matchedExercises.add(matched);
      }

      matchedDays.add(day.copyWith(exercises: matchedExercises));
    }

    return workout.copyWith(days: matchedDays);
  }

  /// Fuzzy match a single exercise against the database
  Future<ParsedExerciseLine> _matchSingleExercise(
    ParsedExerciseLine exercise,
    List<ExerciseDefinition> exerciseDb,
  ) async {
    try {
      final result = await ExerciseFuzzyMatcher.findBestMatch(
        exercises: exerciseDb,
        query: exercise.rawName,
        minScore: 0.45, // Lower threshold to show suggestions
      );

      if (result != null) {
        // Map muscle group to ExerciseCategory
        ExerciseCategory? category;
        try {
          final muscleGroup = exercise.muscleGroup?.toLowerCase();
          if (muscleGroup != null) {
            category = ExerciseCategory.values.firstWhere(
              (c) => c.name == muscleGroup,
              orElse: () => ExerciseCategory.other,
            );
          }
        } catch (_) {
          // Ignore category mapping errors
        }

        return exercise.copyWith(
          matchedExerciseId: result.exercise.id,
          matchedExerciseName: result.exercise.nome,
          matchConfidence: result.score,
          matchedCategory: category ?? _inferCategory(result.exercise),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Fuzzy match error for "${exercise.rawName}": $e');
      }
    }

    return exercise;
  }

  /// Infer ExerciseCategory from exercise database entity
  ExerciseCategory _inferCategory(ExerciseDefinition exercise) {
    final focusStr = exercise.focus.join(' ').toLowerCase();
    if (focusStr.contains('petto') || focusStr.contains('chest')) {
      return ExerciseCategory.chest;
    }
    if (focusStr.contains('dorso') || focusStr.contains('back') || focusStr.contains('schiena')) {
      return ExerciseCategory.back;
    }
    if (focusStr.contains('spall') || focusStr.contains('shoulder')) {
      return ExerciseCategory.shoulders;
    }
    if (focusStr.contains('bracc') || focusStr.contains('bicip') || focusStr.contains('tricip') || focusStr.contains('arm')) {
      return ExerciseCategory.arms;
    }
    if (focusStr.contains('gamb') || focusStr.contains('quad') || focusStr.contains('leg') || focusStr.contains('glut')) {
      return ExerciseCategory.legs;
    }
    if (focusStr.contains('addom') || focusStr.contains('abs') || focusStr.contains('core')) {
      return ExerciseCategory.abs;
    }
    if (focusStr.contains('cardio') || focusStr.contains('corsa') || focusStr.contains('run')) {
      return ExerciseCategory.cardio;
    }
    return ExerciseCategory.other;
  }
}
