/// Import Repository
///
/// Orchestrates the complete import workflow:
/// 1. Parse CSV file
/// 2. Map exercises to database
/// 3. Create workouts with mapped exercises
/// 4. Save to local storage and sync
library;

import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/import/data/parsers/strong_csv_parser.dart';
import 'package:gymbro_flutter_new/features/import/data/mappers/exercise_name_mapper.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart' as workout_entities;
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';

/// Repository for importing workout data from external apps
class ImportRepository {
  ImportRepository({
    required this.exerciseDatabase,
    required this.workoutRepository,
  });

  final List<ExerciseDefinition> exerciseDatabase;
  final WorkoutRepository workoutRepository;

  late final StrongCsvParser _strongParser = StrongCsvParser();
  late final ExerciseNameMapper _exerciseMapper = ExerciseNameMapper(exerciseDatabase);

  /// Parse CSV and prepare for import
  ///
  /// Returns parsed data with exercise mapping suggestions.
  /// User can review and adjust mappings before final import.
  Future<ImportParseResult> parseAndMap(String csvContent, {String sourceApp = 'strong'}) async {
    // Parse CSV
    ImportParseResult parseResult;

    switch (sourceApp.toLowerCase()) {
      case 'strong':
        parseResult = _strongParser.parse(csvContent);
        break;
      // TODO: Add hevy parser
      // case 'hevy':
      //   parseResult = _hevyParser.parse(csvContent);
      //   break;
      default:
        parseResult = _strongParser.parse(csvContent);
    }

    // Map exercises
    final mappedResult = await _exerciseMapper.mapExercises(parseResult);

    return mappedResult;
  }

  /// Apply manual exercise mappings
  ///
  /// Called when user manually maps exercises that couldn't be auto-mapped.
  ImportParseResult applyManualMappings(
    ImportParseResult parseResult,
    Map<String, String> manualMappings, // originalName -> exerciseId
  ) {
    final updatedAutoMapped = Map<String, String>.from(parseResult.autoMappedExercises)
      ..addAll(manualMappings);

    // Update workouts with manual mappings
    final updatedWorkouts = parseResult.workouts.map((workout) {
      final updatedExercises = workout.exercises.map((exercise) {
        final mappedId = manualMappings[exercise.originalName] ??
            parseResult.autoMappedExercises[exercise.originalName];

        if (mappedId != null && exercise.mappedExerciseId == null) {
          final mappedExercise = exerciseDatabase.firstWhere(
            (e) => e.id == mappedId,
            orElse: () => exerciseDatabase.first,
          );
          return exercise.copyWith(
            mappedExerciseId: mappedId,
            mappedExerciseName: mappedExercise.nome,
          );
        }
        return exercise;
      }).toList();

      return workout.copyWith(exercises: updatedExercises);
    }).toList();

    // Remove manually mapped from unmapped list
    final stillUnmapped = parseResult.unmappedExercises
        .where((u) => !manualMappings.containsKey(u.originalName))
        .toList();

    return parseResult.copyWith(
      workouts: updatedWorkouts,
      autoMappedExercises: updatedAutoMapped,
      unmappedExercises: stillUnmapped,
    );
  }

  /// Execute final import
  ///
  /// Creates workout entries for all parsed workouts.
  /// Exercises without mapping are imported with original name.
  Future<ImportFinalResult> executeImport(
    ImportParseResult parseResult, {
    bool skipUnmapped = false, // If true, skip exercises without mapping
  }) async {
    int workoutsImported = 0;
    int workoutsSkipped = 0;
    int exercisesImported = 0;
    int setsImported = 0;
    final List<String> errors = [];

    for (final parsedWorkout in parseResult.workouts) {
      try {
        // Convert ParsedWorkout to Workout entity
        final workout = _convertToWorkout(
          parsedWorkout,
          parseResult.autoMappedExercises,
          skipUnmapped: skipUnmapped,
        );

        if (workout.exercises.isEmpty) {
          workoutsSkipped++;
          continue;
        }

        // Save workout (exercises are stored within the workout)
        final result = await workoutRepository.saveWorkout(workout);

        // Check if save was successful
        if (result.isLeft) {
          throw Exception('Failed to save workout');
        }

        workoutsImported++;
        exercisesImported += workout.exercises.length;
        setsImported += workout.exercises.fold(
          0,
          (sum, e) => sum + e.sets.length,
        );
      } catch (e) {
        errors.add('Failed to import workout "${parsedWorkout.name}": $e');
        workoutsSkipped++;
      }
    }

    return ImportFinalResult(
      workoutsImported: workoutsImported,
      workoutsSkipped: workoutsSkipped,
      exercisesImported: exercisesImported,
      setsImported: setsImported,
      errors: errors,
      importedAt: DateTime.now(),
      sourceApp: parseResult.sourceApp,
    );
  }

  /// Convert parsed workout to domain entity
  Workout _convertToWorkout(
    ParsedWorkout parsed,
    Map<String, String> exerciseMappings, {
    bool skipUnmapped = false,
  }) {
    final exercises = <workout_entities.Exercise>[];

    for (final parsedExercise in parsed.exercises) {
      // Skip unmapped if requested
      if (skipUnmapped && parsedExercise.mappedExerciseId == null) {
        continue;
      }

      // Get exercise name (mapped or original)
      final exerciseName = parsedExercise.mappedExerciseName ??
          parsedExercise.originalName;

      // Determine category from database if mapped
      var category = workout_entities.ExerciseCategory.other;
      if (parsedExercise.mappedExerciseId != null) {
        final dbExercise = exerciseDatabase.firstWhere(
          (e) => e.id == parsedExercise.mappedExerciseId,
          orElse: () => exerciseDatabase.first,
        );
        category = _mapCategory(dbExercise.focus.firstOrNull ?? '');
      }

      // Convert sets
      final sets = parsedExercise.sets.map((parsedSet) {
        return workout_entities.ExerciseSet(
          setNumber: parsedSet.setNumber,
          weight: parsedSet.weight,
          reps: parsedSet.reps,
          actualReps: parsedSet.reps, // Imported data = completed
          seconds: parsedSet.seconds,
          distance: parsedSet.distance,
          rpe: parsedSet.rpe,
          isCompleted: true, // Imported workouts are already completed
          notes: parsedSet.notes,
        );
      }).toList();

      exercises.add(workout_entities.Exercise(
        id: parsedExercise.mappedExerciseId ?? const Uuid().v4(),
        name: exerciseName,
        type: workout_entities.ExerciseType.single,
        category: category,
        sets: sets,
        notes: parsedExercise.notes,
      ));
    }

    // Calculate end time from duration
    DateTime? endTime;
    if (parsed.durationMinutes != null) {
      endTime = parsed.date.add(Duration(minutes: parsed.durationMinutes!));
    }

    return Workout(
      id: const Uuid().v4(),
      name: parsed.name,
      exercises: exercises,
      status: WorkoutStatus.completed,
      startTime: parsed.date,
      endTime: endTime,
      notes: parsed.notes,
      createdAt: parsed.date,
      updatedAt: DateTime.now(),
    );
  }

  /// Map focus area to exercise category
  /// Uses centralized MuscleAbbreviationMapper as single source of truth
  workout_entities.ExerciseCategory _mapCategory(String focus) {
    return MuscleAbbreviationMapper.focusToExerciseCategory(focus);
  }
}
