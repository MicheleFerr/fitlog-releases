import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_import_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('WorkoutImportService', () {
    late WorkoutImportService service;

    setUp(() {
      service = WorkoutImportService();
    });

    group('importFromJson', () {
      test('should import valid JSON format with workouts array', () async {
        // Arrange
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Test Workout",
              "exercises": [
                {
                  "name": "Bench Press",
                  "type": "single",
                  "category": "chest",
                  "sets": [
                    {"setNumber": 1, "weight": 100.0, "reps": 10, "isCompleted": true}
                  ]
                }
              ],
              "status": "completed"
            }
          ]
        }
        ''';

        // Act
        final result = await service.importFromJson(jsonContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(1));
        expect(result.workouts, isNotNull);
        expect(result.workouts!.first.name, equals('Test Workout'));
        expect(result.workouts!.first.exercises.length, equals(1));
        expect(result.workouts!.first.exercises.first.name, equals('Bench Press'));
      });

      test('should handle multiple workouts in JSON', () async {
        // Arrange
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Workout 1",
              "exercises": [{"name": "Exercise 1", "sets": []}]
            },
            {
              "name": "Workout 2",
              "exercises": [{"name": "Exercise 2", "sets": []}]
            },
            {
              "name": "Workout 3",
              "exercises": [{"name": "Exercise 3", "sets": []}]
            }
          ]
        }
        ''';

        // Act
        final result = await service.importFromJson(jsonContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(3));
        expect(result.workouts!.map((w) => w.name), containsAll(['Workout 1', 'Workout 2', 'Workout 3']));
      });

      test('should skip invalid workouts when skipInvalidRows is true', () async {
        // Arrange
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Valid Workout",
              "exercises": [{"name": "Exercise 1", "sets": []}]
            },
            {
              "exercises": [{"name": "Exercise 2", "sets": []}]
            },
            {
              "name": "Another Valid",
              "exercises": [{"name": "Exercise 3", "sets": []}]
            }
          ]
        }
        ''';

        // Act
        final result = await service.importFromJson(
          jsonContent,
          ImportOptions(skipInvalidRows: true),
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(2)); // Only 2 valid workouts
        expect(result.errors, isNotNull);
        expect(result.errorCount, greaterThan(0));
      });

      test('should fail when skipInvalidRows is false and encounters invalid data', () async {
        // Arrange
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Valid Workout",
              "exercises": [{"name": "Exercise 1", "sets": []}]
            },
            {
              "exercises": [{"name": "Exercise 2", "sets": []}]
            }
          ]
        }
        ''';

        // Act
        final result = await service.importFromJson(
          jsonContent,
          ImportOptions(skipInvalidRows: false),
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Invalid workout data'));
      });

      test('should handle legacy JSON format (array of workouts)', () async {
        // Arrange - Legacy format without "workouts" wrapper
        const jsonContent = '''
        [
          {
            "name": "Legacy Workout",
            "exercises": [{"name": "Exercise 1", "sets": []}]
          }
        ]
        ''';

        // Act
        final result = await service.importFromJson(jsonContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(1));
        expect(result.message, contains('legacy format'));
      });

      test('should handle legacy JSON format (single workout)', () async {
        // Arrange - Single workout object
        const jsonContent = '''
        {
          "name": "Single Workout",
          "exercises": [{"name": "Exercise 1", "sets": []}]
        }
        ''';

        // Act
        final result = await service.importFromJson(jsonContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(1));
      });

      test('should use default workout name when not provided', () async {
        // Arrange
        const jsonContent = '''
        {
          "workouts": [
            {
              "exercises": [{"name": "Exercise 1", "sets": []}]
            }
          ]
        }
        ''';

        // Act
        final result = await service.importFromJson(
          jsonContent,
          ImportOptions(defaultWorkoutName: 'My Default Workout', validateData: false),
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.workouts!.first.name, equals('My Default Workout'));
      });

      test('should parse exercise details correctly', () async {
        // Arrange
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Test",
              "exercises": [
                {
                  "name": "Bench Press",
                  "type": "single",
                  "category": "chest",
                  "notes": "Focus on form",
                  "restTimeSeconds": 90,
                  "isCompleted": true,
                  "sets": []
                }
              ]
            }
          ]
        }
        ''';

        // Act
        final result = await service.importFromJson(jsonContent, ImportOptions());

        // Assert
        final exercise = result.workouts!.first.exercises.first;
        expect(exercise.name, equals('Bench Press'));
        expect(exercise.type, equals(ExerciseType.single));
        expect(exercise.category, equals(ExerciseCategory.chest));
        expect(exercise.notes, equals('Focus on form'));
        expect(exercise.restTime, equals(90));
        expect(exercise.isCompleted, isTrue);
      });

      test('should parse set details correctly', () async {
        // Arrange
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Test",
              "exercises": [
                {
                  "name": "Exercise",
                  "sets": [
                    {
                      "setNumber": 1,
                      "weight": 100.5,
                      "reps": 10,
                      "actualReps": 8,
                      "rpe": 8,
                      "isCompleted": true,
                      "notes": "Good set",
                      "restTimeSeconds": 60,
                      "isWarmup": false
                    }
                  ]
                }
              ]
            }
          ]
        }
        ''';

        // Act
        final result = await service.importFromJson(jsonContent, ImportOptions());

        // Assert
        final set = result.workouts!.first.exercises.first.sets.first;
        expect(set.setNumber, equals(1));
        expect(set.weight, equals(100.5));
        expect(set.reps, equals(10));
        expect(set.actualReps, equals(8));
        expect(set.rpe, equals(8));
        expect(set.isCompleted, isTrue);
        expect(set.notes, equals('Good set'));
        expect(set.restTime, equals(60));
        expect(set.isWarmup, isFalse);
      });

      test('should handle invalid JSON gracefully', () async {
        // Arrange
        const invalidJson = '{ invalid json }';

        // Act
        final result = await service.importFromJson(invalidJson, ImportOptions());

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Invalid JSON format'));
      });

      test('should handle empty workouts array', () async {
        // Arrange
        const jsonContent = '''{"workouts": []}''';

        // Act
        final result = await service.importFromJson(jsonContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(0));
      });
    });

    group('importFromCsv', () {
      test('should import valid CSV with required columns', () async {
        // Arrange
        const csvContent = '''
Workout Date,Workout Name,Exercise,Set,Weight,Reps
2024-01-15,Push Day,Bench Press,1,100,10
2024-01-15,Push Day,Bench Press,2,100,9
2024-01-15,Push Day,Overhead Press,1,60,8
        ''';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, greaterThan(0));
        expect(result.message, contains('CSV'));
      });

      test('should group exercises by workout', () async {
        // Arrange
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Bench Press,100,10
2024-01-15,Bench Press,100,9
2024-01-15,Squat,120,8
        ''';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        final workout = result.workouts!.first;
        expect(workout.exercises.length, equals(2)); // Bench Press and Squat
      });

      test('should parse RPE when present', () async {
        // Arrange
        const csvContent = '''
Workout Date,Exercise,Weight,Reps,RPE
2024-01-15,Bench Press,100,10,8
        ''';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        final set = result.workouts!.first.exercises.first.sets.first;
        expect(set.rpe, equals(8));
      });

      test('should handle notes column when present', () async {
        // Arrange
        const csvContent = '''
Workout Date,Exercise,Weight,Reps,Notes
2024-01-15,Bench Press,100,10,Great form
        ''';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        final set = result.workouts!.first.exercises.first.sets.first;
        expect(set.notes, equals('Great form'));
      });

      test('should fail when required columns are missing', () async {
        // Arrange - Missing Weight column
        const csvContent = '''
Workout Date,Exercise,Reps
2024-01-15,Bench Press,10
        ''';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Missing required CSV columns'));
      });

      test('should skip invalid rows when skipInvalidRows is true', () async {
        // Arrange - Row with invalid weight
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Bench Press,100,10
2024-01-15,Invalid,abc,10
2024-01-15,Squat,120,8
        ''';

        // Act
        final result = await service.importFromCsv(
          csvContent,
          ImportOptions(skipInvalidRows: true),
        );

        // Assert
        expect(result.success, isTrue);
        // Should still import valid rows
      });

      test('should use default workout name when name not in CSV', () async {
        // Arrange - No Workout Name column
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Bench Press,100,10
        ''';

        // Act
        final result = await service.importFromCsv(
          csvContent,
          ImportOptions(defaultWorkoutName: 'CSV Workout'),
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.workouts!.first.name, equals('CSV Workout'));
      });

      test('should handle empty CSV file', () async {
        // Arrange
        const csvContent = '';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Empty CSV'));
      });

      test('should handle CSV with only headers', () async {
        // Arrange
        const csvContent = 'Workout Date,Exercise,Weight,Reps';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(0));
      });

      test('should guess exercise categories from names', () async {
        // Arrange
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Bench Press,100,10
2024-01-15,Squat,120,8
2024-01-15,Bicep Curl,30,12
        ''';

        // Act
        final result = await service.importFromCsv(csvContent, ImportOptions());

        // Assert
        expect(result.success, isTrue);
        final exercises = result.workouts!.first.exercises;
        expect(exercises.any((e) => e.category == ExerciseCategory.chest), isTrue);
        expect(exercises.any((e) => e.category == ExerciseCategory.legs), isTrue);
        expect(exercises.any((e) => e.category == ExerciseCategory.arms), isTrue);
      });
    });

    group('ImportOptions', () {
      test('should create with default values', () {
        // Act
        final options = ImportOptions();

        // Assert
        expect(options.overwriteExisting, isFalse);
        expect(options.mergeWithExisting, isFalse);
        expect(options.validateData, isTrue);
        expect(options.skipInvalidRows, isTrue);
        expect(options.defaultWorkoutName, isNull);
      });

      test('should create with custom values', () {
        // Act
        final options = ImportOptions(
          overwriteExisting: true,
          mergeWithExisting: true,
          validateData: false,
          skipInvalidRows: false,
          defaultWorkoutName: 'Custom',
        );

        // Assert
        expect(options.overwriteExisting, isTrue);
        expect(options.mergeWithExisting, isTrue);
        expect(options.validateData, isFalse);
        expect(options.skipInvalidRows, isFalse);
        expect(options.defaultWorkoutName, equals('Custom'));
      });
    });

    group('ImportResult', () {
      test('should calculate importedCount correctly', () {
        // Arrange & Act
        final result = ImportResult(
          success: true,
          message: 'Test',
          workouts: [
            Workout(name: 'W1', exercises: []),
            Workout(name: 'W2', exercises: []),
          ],
        );

        // Assert
        expect(result.importedCount, equals(2));
      });

      test('should calculate errorCount correctly', () {
        // Arrange & Act
        final result = ImportResult(
          success: true,
          message: 'Test',
          errors: ['Error 1', 'Error 2', 'Error 3'],
        );

        // Assert
        expect(result.errorCount, equals(3));
      });

      test('should return 0 counts when workouts/errors are null', () {
        // Arrange & Act
        final result = ImportResult(
          success: true,
          message: 'Test',
        );

        // Assert
        expect(result.importedCount, equals(0));
        expect(result.errorCount, equals(0));
      });
    });

    group('Category guessing', () {
      test('should guess legs category', () async {
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Squat,100,10
2024-01-15,Leg Press,200,12
2024-01-15,Calf Raise,80,15
        ''';

        final result = await service.importFromCsv(csvContent, ImportOptions());
        final categories = result.workouts!.first.exercises.map((e) => e.category);

        expect(categories, everyElement(equals(ExerciseCategory.legs)));
      });

      test('should guess chest category', () async {
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Bench Press,100,10
2024-01-15,Chest Fly,30,12
2024-01-15,Pec Deck,50,10
        ''';

        final result = await service.importFromCsv(csvContent, ImportOptions());
        final categories = result.workouts!.first.exercises.map((e) => e.category);

        expect(categories, everyElement(equals(ExerciseCategory.chest)));
      });

      test('should guess back category', () async {
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Barbell Row,80,10
2024-01-15,Pull Up,0,10
2024-01-15,Lat Pulldown,70,12
        ''';

        final result = await service.importFromCsv(csvContent, ImportOptions());
        final categories = result.workouts!.first.exercises.map((e) => e.category);

        expect(categories, everyElement(equals(ExerciseCategory.back)));
      });

      test('should guess shoulders category', () async {
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Shoulder Press,60,10
2024-01-15,Overhead Press,70,8
2024-01-15,Delt Raise,20,12
        ''';

        final result = await service.importFromCsv(csvContent, ImportOptions());
        final categories = result.workouts!.first.exercises.map((e) => e.category);

        expect(categories, everyElement(equals(ExerciseCategory.shoulders)));
      });

      test('should guess arms category', () async {
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Bicep Curl,30,10
2024-01-15,Tricep Extension,25,12
        ''';

        final result = await service.importFromCsv(csvContent, ImportOptions());
        final categories = result.workouts!.first.exercises.map((e) => e.category);

        expect(categories, everyElement(equals(ExerciseCategory.arms)));
      });

      test('should guess cardio category', () async {
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Running,0,0
2024-01-15,Bike,0,0
        ''';

        final result = await service.importFromCsv(csvContent, ImportOptions());
        final categories = result.workouts!.first.exercises.map((e) => e.category);

        expect(categories, everyElement(equals(ExerciseCategory.cardio)));
      });

      test('should default to other category for unknown exercises', () async {
        const csvContent = '''
Workout Date,Exercise,Weight,Reps
2024-01-15,Unknown Exercise,50,10
        ''';

        final result = await service.importFromCsv(csvContent, ImportOptions());
        final category = result.workouts!.first.exercises.first.category;

        expect(category, equals(ExerciseCategory.other));
      });
    });

    group('Enum parsing', () {
      test('should parse workout status correctly', () async {
        const jsonContent = '''
        {
          "workouts": [
            {"name": "Planned", "exercises": [], "status": "planned"},
            {"name": "In Progress", "exercises": [], "status": "inProgress"},
            {"name": "Completed", "exercises": [], "status": "completed"}
          ]
        }
        ''';

        final result = await service.importFromJson(jsonContent, ImportOptions(validateData: false));

        expect(result.success, isTrue);
        expect(result.workouts![0].status, equals(WorkoutStatus.planned));
        expect(result.workouts![1].status, equals(WorkoutStatus.inProgress));
        expect(result.workouts![2].status, equals(WorkoutStatus.completed));
      });

      test('should default to planned for invalid status', () async {
        const jsonContent = '''
        {
          "workouts": [
            {"name": "Test", "exercises": [], "status": "invalid_status"}
          ]
        }
        ''';

        final result = await service.importFromJson(jsonContent, ImportOptions(validateData: false));

        expect(result.success, isTrue);
        expect(result.workouts!.first.status, equals(WorkoutStatus.planned));
      });

      test('should parse exercise type correctly', () async {
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Test",
              "exercises": [
                {"name": "Single", "type": "single", "sets": []},
                {"name": "Superset", "type": "superset", "sets": []},
                {"name": "Circuit", "type": "circuit", "sets": []}
              ]
            }
          ]
        }
        ''';

        final result = await service.importFromJson(jsonContent, ImportOptions());

        expect(result.success, isTrue);
        final exercises = result.workouts!.first.exercises;
        expect(exercises[0].type, equals(ExerciseType.single));
        expect(exercises[1].type, equals(ExerciseType.superset));
        expect(exercises[2].type, equals(ExerciseType.restPause));
      });

      test('should parse exercise category correctly', () async {
        const jsonContent = '''
        {
          "workouts": [
            {
              "name": "Test",
              "exercises": [
                {"name": "Ex1", "category": "chest", "sets": []},
                {"name": "Ex2", "category": "back", "sets": []},
                {"name": "Ex3", "category": "legs", "sets": []}
              ]
            }
          ]
        }
        ''';

        final result = await service.importFromJson(jsonContent, ImportOptions());

        expect(result.success, isTrue);
        final exercises = result.workouts!.first.exercises;
        expect(exercises[0].category, equals(ExerciseCategory.chest));
        expect(exercises[1].category, equals(ExerciseCategory.back));
        expect(exercises[2].category, equals(ExerciseCategory.legs));
      });
    });
  });
}
