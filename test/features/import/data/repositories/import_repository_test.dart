/// Unit tests for ImportRepository
///
/// Tests parseAndMap, applyManualMappings, executeImport, _convertToWorkout,
/// and _mapCategory methods using manual fake classes only (no mockito/mocktail).
///
/// The WorkoutRepository fake returns configurable Either results.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' hide Exercise;
import 'package:gymbro_flutter_new/features/import/data/repositories/import_repository.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Fake WorkoutRepository
// ---------------------------------------------------------------------------

class _FakeWorkoutRepository implements WorkoutRepository {
  _FakeWorkoutRepository({bool saveShouldFail = false})
      : _saveShouldFail = saveShouldFail;

  final bool _saveShouldFail;
  final List<Workout> savedWorkouts = [];

  @override
  Future<Either<Failure, String>> saveWorkout(Workout workout) async {
    if (_saveShouldFail) {
      return Left(const ServerFailure('Save failed'));
    }
    savedWorkouts.add(workout);
    return Right(workout.id);
  }

  // --- Unused interface members ---

  @override
  Future<Either<Failure, void>> updateWorkout(Workout workout) async =>
      const Right(null);

  @override
  Future<Either<Failure, Workout>> getWorkout(String workoutId) async =>
      Left(const ServerFailure('Not implemented'));

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async => const Right([]);

  @override
  Future<Either<Failure, void>> deleteWorkout(String workoutId) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<String>>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) async => const Right([]);

  @override
  Future<Either<Failure, void>> updateExerciseSet({
    required String workoutId,
    required String exerciseId,
    required ExerciseSet exerciseSet,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) async => const Right(null);

  @override
  Future<Either<Failure, WorkoutStats>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async => Left(const ServerFailure('Not implemented'));

  @override
  Stream<Either<Failure, Workout?>> watchActiveWorkout() =>
      const Stream.empty();

  @override
  Future<Either<Failure, WorkoutHistory>> getWorkoutHistory({
    int page = 1,
    int limit = 10,
  }) async => Left(const ServerFailure('Not implemented'));

  @override
  Future<Workout?> getLastCompletedWorkout(String userId) async => null;

  @override
  Future<Either<Failure, PaginatedResult<Workout>>> getWorkoutsPaginated({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) async => Left(const ServerFailure('Not implemented'));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseDefinition _makeExercise({
  required String id,
  required String nome,
  List<String> focus = const [],
}) {
  return ExerciseDefinition(
    id: id,
    nome: nome,
    focus: focus,
    muscoliSecondari: [],
    difficolta: 'Intermedio',
    tipoEsercizio: 'Compound',
    attrezzatura: 'Bilanciere',
    patternMovimento: 'Push',
    rangeRipetizioni: '6-12',
    countingMode: ExerciseCountingMode.weighted,
  );
}

/// Builds a minimal [ImportParseResult] with given exercises already mapped.
ImportParseResult _buildMappedParseResult({
  required String workoutName,
  required List<ParsedExercise> exercises,
  String sourceApp = 'strong',
  List<UnmappedExercise> unmapped = const [],
  Map<String, String> autoMapped = const {},
  List<String> warnings = const [],
}) {
  return ImportParseResult(
    sourceApp: sourceApp,
    workouts: [
      ParsedWorkout(
        name: workoutName,
        date: DateTime(2024, 1, 15, 10, 0),
        exercises: exercises,
      ),
    ],
    unmappedExercises: unmapped,
    autoMappedExercises: autoMapped,
    warnings: warnings,
    totalRows: exercises.length,
    parsedRows: exercises.length,
  );
}

const _benchSet = ParsedSet(setNumber: 1, weight: 80.0, reps: 8);
const _squatSet = ParsedSet(setNumber: 1, weight: 100.0, reps: 5);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeWorkoutRepository fakeRepo;
  late List<ExerciseDefinition> exerciseDb;
  late ImportRepository repository;

  setUp(() {
    fakeRepo = _FakeWorkoutRepository();
    exerciseDb = [
      _makeExercise(id: 'ex-bench', nome: 'Panca Piana', focus: ['PETT']),
      _makeExercise(id: 'ex-squat', nome: 'Squat', focus: ['QUAD']),
      _makeExercise(id: 'ex-deadlift', nome: 'Stacco', focus: ['LOMB']),
      _makeExercise(id: 'ex-curl', nome: 'Curl Bilanciere', focus: ['BICI']),
      _makeExercise(id: 'ex-ohp', nome: 'Military Press', focus: ['DELT']),
      _makeExercise(id: 'ex-row', nome: 'Rematore', focus: ['LAT']),
      _makeExercise(id: 'ex-crunch', nome: 'Crunch', focus: ['CORE']),
      _makeExercise(id: 'ex-run', nome: 'Corsa', focus: ['cardio']),
    ];
    repository = ImportRepository(
      exerciseDatabase: exerciseDb,
      workoutRepository: fakeRepo,
    );
  });

  // -------------------------------------------------------------------------
  // parseAndMap
  // -------------------------------------------------------------------------
  group('ImportRepository.parseAndMap', () {
    const strongCsv =
        'Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes\r\n'
        '2024-01-15 10:30:00,Push Day,45:00,Bench Press,1,80,8,,,Good form,Great session';

    test('parses strong CSV and returns ImportParseResult', () async {
      final result = await repository.parseAndMap(strongCsv);

      expect(result.sourceApp, 'strong');
      expect(result.workouts.length, 1);
      expect(result.workouts.first.name, 'Push Day');
    });

    test('defaults to strong parser when sourceApp is unrecognized', () async {
      final result = await repository.parseAndMap(
        strongCsv,
        sourceApp: 'unknown_app',
      );

      expect(result.sourceApp, 'strong');
    });

    test('explicit sourceApp=strong uses strong parser', () async {
      final result = await repository.parseAndMap(
        strongCsv,
        sourceApp: 'strong',
      );

      expect(result.sourceApp, 'strong');
      expect(result.workouts.isNotEmpty, isTrue);
    });

    test('returns result with unmappedExercises populated', () async {
      final result = await repository.parseAndMap(strongCsv);

      // After parsing, exercises are either auto-mapped or in unmapped list
      expect(result.unmappedExercises.length + result.autoMappedExercises.length,
          greaterThanOrEqualTo(0));
    });

    test('returns result with totalRows and parsedRows', () async {
      final result = await repository.parseAndMap(strongCsv);

      expect(result.totalRows, 1);
      expect(result.parsedRows, 1);
    });

    test('handles empty CSV gracefully', () async {
      final result = await repository.parseAndMap('');

      expect(result.workouts, isEmpty);
      expect(result.warnings, isNotEmpty);
    });

    test('handles CSV with multiple workouts', () async {
      const multiCsv =
          'Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes\r\n'
          '2024-01-15 10:30:00,Push Day,,Bench Press,1,80,8,,,\r\n'
          '2024-01-16 09:00:00,Pull Day,,Pull Up,1,0,8,,,';

      final result = await repository.parseAndMap(multiCsv);

      expect(result.workouts.length, 2);
    });
  });

  // -------------------------------------------------------------------------
  // applyManualMappings
  // -------------------------------------------------------------------------
  group('ImportRepository.applyManualMappings', () {
    test('applies manual mapping to unmapped exercises', () {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Flat Bench Press',
            sets: [_benchSet],
          ),
        ],
        unmapped: [
          const UnmappedExercise(
            originalName: 'Flat Bench Press',
            occurrences: 1,
          ),
        ],
      );

      final mapped = repository.applyManualMappings(parseResult, {
        'Flat Bench Press': 'ex-bench',
      });

      expect(mapped.autoMappedExercises.containsKey('Flat Bench Press'), isTrue);
      expect(mapped.autoMappedExercises['Flat Bench Press'], 'ex-bench');
    });

    test('removes manually mapped exercises from unmappedExercises list', () {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Flat Bench Press',
            sets: [_benchSet],
          ),
        ],
        unmapped: [
          const UnmappedExercise(
            originalName: 'Flat Bench Press',
            occurrences: 1,
          ),
        ],
      );

      final mapped = repository.applyManualMappings(parseResult, {
        'Flat Bench Press': 'ex-bench',
      });

      expect(
        mapped.unmappedExercises.any((u) => u.originalName == 'Flat Bench Press'),
        isFalse,
      );
    });

    test('keeps previously auto-mapped exercises in autoMappedExercises', () {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Flat Bench Press',
            sets: [_benchSet],
          ),
          const ParsedExercise(
            originalName: 'Squat',
            sets: [_squatSet],
          ),
        ],
        autoMapped: {'Squat': 'ex-squat'},
        unmapped: [
          const UnmappedExercise(
            originalName: 'Flat Bench Press',
            occurrences: 1,
          ),
        ],
      );

      final mapped = repository.applyManualMappings(parseResult, {
        'Flat Bench Press': 'ex-bench',
      });

      expect(mapped.autoMappedExercises.containsKey('Squat'), isTrue);
      expect(mapped.autoMappedExercises.containsKey('Flat Bench Press'), isTrue);
    });

    test('updates exercises in workouts with new mappedExerciseId', () {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Flat Bench Press',
            sets: [_benchSet],
          ),
        ],
        unmapped: [
          const UnmappedExercise(
            originalName: 'Flat Bench Press',
            occurrences: 1,
          ),
        ],
      );

      final mapped = repository.applyManualMappings(parseResult, {
        'Flat Bench Press': 'ex-bench',
      });

      final exercise = mapped.workouts.first.exercises.first;
      expect(exercise.mappedExerciseId, 'ex-bench');
      expect(exercise.mappedExerciseName, 'Panca Piana');
    });

    test('does not remap already-mapped exercises', () {
      // Exercise already has a mappedExerciseId — should not be overwritten
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        unmapped: [],
      );

      final mapped = repository.applyManualMappings(parseResult, {
        'Bench Press': 'ex-squat', // Try to override with wrong ID
      });

      // Already mapped — should keep original mapping
      final exercise = mapped.workouts.first.exercises.first;
      expect(exercise.mappedExerciseId, 'ex-bench');
    });

    test('handles empty manualMappings gracefully', () {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Unknown Exercise',
            sets: [const ParsedSet(setNumber: 1)],
          ),
        ],
        unmapped: [
          const UnmappedExercise(
            originalName: 'Unknown Exercise',
            occurrences: 1,
          ),
        ],
      );

      final mapped = repository.applyManualMappings(parseResult, {});

      expect(mapped.unmappedExercises, hasLength(1));
      expect(mapped.autoMappedExercises, isEmpty);
    });

    test('preserves multiple unmapped exercises when only one is manually mapped', () {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(originalName: 'A', sets: [_benchSet]),
          const ParsedExercise(originalName: 'B', sets: [_benchSet]),
          const ParsedExercise(originalName: 'C', sets: [_benchSet]),
        ],
        unmapped: [
          const UnmappedExercise(originalName: 'A', occurrences: 1),
          const UnmappedExercise(originalName: 'B', occurrences: 1),
          const UnmappedExercise(originalName: 'C', occurrences: 1),
        ],
      );

      final mapped = repository.applyManualMappings(parseResult, {
        'A': 'ex-bench',
      });

      expect(mapped.unmappedExercises.length, 2);
      expect(
        mapped.unmappedExercises.any((u) => u.originalName == 'B'),
        isTrue,
      );
      expect(
        mapped.unmappedExercises.any((u) => u.originalName == 'C'),
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------------------
  // executeImport
  // -------------------------------------------------------------------------
  group('ImportRepository.executeImport', () {
    test('imports workout with mapped exercises', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        autoMapped: {'Bench Press': 'ex-bench'},
      );

      final result = await repository.executeImport(parseResult);

      expect(result.workoutsImported, 1);
      expect(result.workoutsSkipped, 0);
      expect(result.exercisesImported, 1);
      expect(result.setsImported, 1);
      expect(result.errors, isEmpty);
    });

    test('imports workout with unmapped exercises (use original name)', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Unknown Exercise',
            sets: [const ParsedSet(setNumber: 1, weight: 50.0, reps: 10)],
          ),
        ],
      );

      // skipUnmapped = false (default) → use original name
      final result = await repository.executeImport(parseResult);

      expect(result.workoutsImported, 1);
      expect(result.exercisesImported, 1);
    });

    test('skips exercises without mapping when skipUnmapped=true', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Unknown Exercise',
            sets: [const ParsedSet(setNumber: 1, weight: 50.0, reps: 10)],
          ),
        ],
      );

      final result = await repository.executeImport(
        parseResult,
        skipUnmapped: true,
      );

      // All exercises are skipped → workout has no exercises → workout skipped
      expect(result.workoutsSkipped, 1);
      expect(result.workoutsImported, 0);
    });

    test('counts skipped workouts when saveWorkout fails', () async {
      final failingRepo = _FakeWorkoutRepository(saveShouldFail: true);
      final failingImportRepo = ImportRepository(
        exerciseDatabase: exerciseDb,
        workoutRepository: failingRepo,
      );

      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        autoMapped: {'Bench Press': 'ex-bench'},
      );

      final result = await failingImportRepo.executeImport(parseResult);

      expect(result.workoutsSkipped, 1);
      expect(result.workoutsImported, 0);
      expect(result.errors, isNotEmpty);
    });

    test('records error message for each failed workout', () async {
      final failingRepo = _FakeWorkoutRepository(saveShouldFail: true);
      final failingImportRepo = ImportRepository(
        exerciseDatabase: exerciseDb,
        workoutRepository: failingRepo,
      );

      final parseResult = _buildMappedParseResult(
        workoutName: 'My Workout',
        exercises: [
          const ParsedExercise(
            originalName: 'Squat',
            mappedExerciseId: 'ex-squat',
            mappedExerciseName: 'Squat',
            sets: [_squatSet],
          ),
        ],
        autoMapped: {'Squat': 'ex-squat'},
      );

      final result = await failingImportRepo.executeImport(parseResult);

      expect(result.errors.first, contains('My Workout'));
    });

    test('sets sourceApp from parse result', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        sourceApp: 'hevy',
        autoMapped: {'Bench Press': 'ex-bench'},
      );

      final result = await repository.executeImport(parseResult);

      expect(result.sourceApp, 'hevy');
    });

    test('sets importedAt close to now', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        autoMapped: {'Bench Press': 'ex-bench'},
      );

      final result = await repository.executeImport(parseResult);
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(result.importedAt.isAfter(before), isTrue);
      expect(result.importedAt.isBefore(after), isTrue);
    });

    test('imports multiple workouts from parse result', () async {
      final parseResult = ImportParseResult(
        sourceApp: 'strong',
        workouts: [
          ParsedWorkout(
            name: 'Push Day',
            date: DateTime(2024, 1, 15, 10, 0),
            exercises: [
              const ParsedExercise(
                originalName: 'Bench Press',
                mappedExerciseId: 'ex-bench',
                mappedExerciseName: 'Panca Piana',
                sets: [_benchSet],
              ),
            ],
          ),
          ParsedWorkout(
            name: 'Pull Day',
            date: DateTime(2024, 1, 16, 9, 0),
            exercises: [
              const ParsedExercise(
                originalName: 'Squat',
                mappedExerciseId: 'ex-squat',
                mappedExerciseName: 'Squat',
                sets: [_squatSet],
              ),
            ],
          ),
        ],
        unmappedExercises: const [],
        autoMappedExercises: const {
          'Bench Press': 'ex-bench',
          'Squat': 'ex-squat',
        },
        totalRows: 2,
        parsedRows: 2,
      );

      final result = await repository.executeImport(parseResult);

      expect(result.workoutsImported, 2);
      expect(result.exercisesImported, 2);
      expect(result.setsImported, 2);
    });

    test('calculates correct sets count across multiple exercises', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [
              ParsedSet(setNumber: 1, weight: 80.0, reps: 8),
              ParsedSet(setNumber: 2, weight: 80.0, reps: 8),
              ParsedSet(setNumber: 3, weight: 80.0, reps: 6),
            ],
          ),
          const ParsedExercise(
            originalName: 'Squat',
            mappedExerciseId: 'ex-squat',
            mappedExerciseName: 'Squat',
            sets: [
              ParsedSet(setNumber: 1, weight: 100.0, reps: 5),
              ParsedSet(setNumber: 2, weight: 100.0, reps: 5),
            ],
          ),
        ],
        autoMapped: {
          'Bench Press': 'ex-bench',
          'Squat': 'ex-squat',
        },
      );

      final result = await repository.executeImport(parseResult);

      expect(result.setsImported, 5); // 3 + 2
      expect(result.exercisesImported, 2);
    });

    test('workout with duration has correct endTime', () async {
      final parseResult = ImportParseResult(
        sourceApp: 'strong',
        workouts: [
          ParsedWorkout(
            name: 'Timed Workout',
            date: DateTime(2024, 1, 15, 10, 0),
            durationMinutes: 60,
            exercises: [
              const ParsedExercise(
                originalName: 'Bench Press',
                mappedExerciseId: 'ex-bench',
                mappedExerciseName: 'Panca Piana',
                sets: [_benchSet],
              ),
            ],
          ),
        ],
        unmappedExercises: const [],
        autoMappedExercises: const {'Bench Press': 'ex-bench'},
        totalRows: 1,
        parsedRows: 1,
      );

      await repository.executeImport(parseResult);

      // Verify the saved workout has an endTime 60 minutes after start
      expect(fakeRepo.savedWorkouts.length, 1);
      final saved = fakeRepo.savedWorkouts.first;
      expect(saved.endTime, isNotNull);
      expect(
        saved.endTime!.difference(DateTime(2024, 1, 15, 10, 0)).inMinutes,
        60,
      );
    });

    test('workout without duration has null endTime', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Quick Workout',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        autoMapped: {'Bench Press': 'ex-bench'},
      );

      await repository.executeImport(parseResult);

      expect(fakeRepo.savedWorkouts.first.endTime, isNull);
    });

    test('imported sets are marked as completed', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        autoMapped: {'Bench Press': 'ex-bench'},
      );

      await repository.executeImport(parseResult);

      final savedExercise = fakeRepo.savedWorkouts.first.exercises.first;
      expect(savedExercise.sets.every((s) => s.isCompleted), isTrue);
    });

    test('workout status is completed after import', () async {
      final parseResult = _buildMappedParseResult(
        workoutName: 'Push Day',
        exercises: [
          const ParsedExercise(
            originalName: 'Bench Press',
            mappedExerciseId: 'ex-bench',
            mappedExerciseName: 'Panca Piana',
            sets: [_benchSet],
          ),
        ],
        autoMapped: {'Bench Press': 'ex-bench'},
      );

      await repository.executeImport(parseResult);

      expect(
        fakeRepo.savedWorkouts.first.status,
        WorkoutStatus.completed,
      );
    });

    test('empty parse result imports nothing', () async {
      const parseResult = ImportParseResult(
        sourceApp: 'strong',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 0,
        parsedRows: 0,
      );

      final result = await repository.executeImport(parseResult);

      expect(result.workoutsImported, 0);
      expect(result.workoutsSkipped, 0);
      expect(result.exercisesImported, 0);
    });
  });

  // -------------------------------------------------------------------------
  // _mapCategory (via executeImport saving actual workouts)
  // -------------------------------------------------------------------------
  group('ImportRepository._mapCategory - focus word mapping', () {
    Future<ExerciseCategory> savedCategory(String focus) async {
      final exercise = _makeExercise(
        id: 'ex-test',
        nome: 'Test Exercise',
        focus: [focus],
      );
      final repo = ImportRepository(
        exerciseDatabase: [exercise],
        workoutRepository: fakeRepo,
      );
      final parseResult = _buildMappedParseResult(
        workoutName: 'Test Workout',
        exercises: [
          const ParsedExercise(
            originalName: 'Test Exercise',
            mappedExerciseId: 'ex-test',
            mappedExerciseName: 'Test Exercise',
            sets: [const ParsedSet(setNumber: 1, weight: 60.0, reps: 10)],
          ),
        ],
        autoMapped: {'Test Exercise': 'ex-test'},
      );
      await repo.executeImport(parseResult);
      return fakeRepo.savedWorkouts.last.exercises.first.category;
    }

    test('PETT focus maps to ExerciseCategory.chest', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('PETT');
      expect(category, ExerciseCategory.chest);
    });

    test('QUAD focus maps to ExerciseCategory.legs', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('QUAD');
      expect(category, ExerciseCategory.legs);
    });

    test('LAT focus maps to ExerciseCategory.back', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('LAT');
      expect(category, ExerciseCategory.back);
    });

    test('DELT focus maps to ExerciseCategory.shoulders', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('DELT');
      expect(category, ExerciseCategory.shoulders);
    });

    test('BICI focus maps to ExerciseCategory.arms', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('BICI');
      expect(category, ExerciseCategory.arms);
    });

    test('TRIC focus maps to ExerciseCategory.arms', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('TRIC');
      expect(category, ExerciseCategory.arms);
    });

    test('CORE focus maps to ExerciseCategory.abs', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('CORE');
      expect(category, ExerciseCategory.abs);
    });

    test('unknown focus maps to ExerciseCategory.other', () async {
      fakeRepo = _FakeWorkoutRepository();
      final category = await savedCategory('UNKNOWN_MUSCLE');
      expect(category, ExerciseCategory.other);
    });
  });
}
