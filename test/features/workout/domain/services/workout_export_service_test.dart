import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_export_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('WorkoutExportService', () {
    late WorkoutExportService service;
    late List<Workout> testWorkouts;

    setUp(() {
      service = WorkoutExportService();

      // Create test workouts
      testWorkouts = [
        Workout(
          id: 'workout1',
          name: 'Push Day',
          exercises: [
            Exercise(
              id: 'ex1',
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [
                ExerciseSet(
                  id: 'set1',
                  setNumber: 1,
                  weight: 100.0,
                  reps: 10,
                  actualReps: 10,
                  isCompleted: true,
                  rpe: 8,
                  notes: 'Good form',
                  setDurationMillis: 45000,
                ),
                ExerciseSet(
                  id: 'set2',
                  setNumber: 2,
                  weight: 100.0,
                  reps: 10,
                  actualReps: 9,
                  isCompleted: true,
                  rpe: 9,
                ),
              ],
              isCompleted: true,
            ),
          ],
          status: WorkoutStatus.completed,
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 11, 0),
          createdAt: DateTime(2024, 1, 15, 10, 0),
          notes: 'Great workout',
        ),
        Workout(
          id: 'workout2',
          name: 'Pull Day',
          exercises: [
            Exercise(
              id: 'ex2',
              name: 'Pull Ups',
              type: ExerciseType.single,
              category: ExerciseCategory.back,
              sets: [
                ExerciseSet(
                  id: 'set3',
                  setNumber: 1,
                  weight: 0.0,
                  reps: 12,
                  actualReps: 12,
                  isCompleted: true,
                ),
              ],
              isCompleted: true,
            ),
          ],
          status: WorkoutStatus.completed,
          startTime: DateTime(2024, 1, 16, 10, 0),
          createdAt: DateTime(2024, 1, 16, 10, 0),
        ),
        Workout(
          id: 'workout3',
          name: 'Leg Day',
          exercises: [
            Exercise(
              id: 'ex3',
              name: 'Squat',
              type: ExerciseType.single,
              category: ExerciseCategory.legs,
              sets: [
                ExerciseSet(
                  id: 'set4',
                  setNumber: 1,
                  weight: 120.0,
                  reps: 8,
                  actualReps: 8,
                  isCompleted: true,
                ),
              ],
              isCompleted: false, // Incomplete exercise
            ),
          ],
          status: WorkoutStatus.inProgress,
          createdAt: DateTime(2024, 1, 17, 10, 0),
        ),
      ];
    });

    group('ExportOptions', () {
      test('should create with default values', () {
        // Act
        final options = ExportOptions();

        // Assert
        expect(options.format, equals(ExportFormat.json));
        expect(options.includeIncomplete, isFalse);
        expect(options.includeNotes, isTrue);
        expect(options.includeRPE, isTrue);
        expect(options.includeSetDurations, isTrue);
        expect(options.compressJson, isFalse);
        expect(options.workoutIds, isNull);
        expect(options.startDate, isNull);
        expect(options.endDate, isNull);
      });

      test('should create with custom values', () {
        // Act
        final options = ExportOptions(
          format: ExportFormat.csv,
          includeIncomplete: true,
          includeNotes: false,
          includeRPE: false,
          includeSetDurations: false,
          compressJson: true,
          workoutIds: ['id1', 'id2'],
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 12, 31),
        );

        // Assert
        expect(options.format, equals(ExportFormat.csv));
        expect(options.includeIncomplete, isTrue);
        expect(options.includeNotes, isFalse);
        expect(options.includeRPE, isFalse);
        expect(options.includeSetDurations, isFalse);
        expect(options.compressJson, isTrue);
        expect(options.workoutIds, equals(['id1', 'id2']));
        expect(options.startDate, equals(DateTime(2024, 1, 1)));
        expect(options.endDate, equals(DateTime(2024, 12, 31)));
      });
    });

    group('ExportResult', () {
      test('should calculate formattedFileSize in bytes', () {
        // Act
        final result = ExportResult(
          success: true,
          message: 'Test',
          fileSize: 512,
        );

        // Assert
        expect(result.formattedFileSize, equals('512 B'));
      });

      test('should calculate formattedFileSize in KB', () {
        // Act
        final result = ExportResult(
          success: true,
          message: 'Test',
          fileSize: 2048, // 2 KB
        );

        // Assert
        expect(result.formattedFileSize, equals('2.0 KB'));
      });

      test('should calculate formattedFileSize in MB', () {
        // Act
        final result = ExportResult(
          success: true,
          message: 'Test',
          fileSize: 1536 * 1024, // 1.5 MB
        );

        // Assert
        expect(result.formattedFileSize, equals('1.5 MB'));
      });

      test('should return empty string when fileSize is null', () {
        // Act
        final result = ExportResult(
          success: true,
          message: 'Test',
        );

        // Assert
        expect(result.formattedFileSize, equals(''));
      });
    });

    group('Filtering', () {
      test('should filter by workout IDs', () {
        // Arrange
        final options = ExportOptions(
          workoutIds: ['workout1', 'workout3'],
        );

        // Act
        final filtered = service._filterWorkouts(testWorkouts, options);

        // Assert
        expect(filtered.length, equals(2));
        expect(filtered.map((w) => w.id), containsAll(['workout1', 'workout3']));
      });

      test('should filter by start date', () {
        // Arrange
        final options = ExportOptions(
          startDate: DateTime(2024, 1, 16),
        );

        // Act
        final filtered = service._filterWorkouts(testWorkouts, options);

        // Assert
        expect(filtered.length, equals(2)); // workout2 and workout3
        expect(filtered.every((w) => w.createdAt.isAfter(DateTime(2024, 1, 16))), isTrue);
      });

      test('should filter by end date', () {
        // Arrange
        final options = ExportOptions(
          endDate: DateTime(2024, 1, 16),
        );

        // Act
        final filtered = service._filterWorkouts(testWorkouts, options);

        // Assert
        expect(filtered.length, equals(1)); // Only workout1
        expect(filtered.first.id, equals('workout1'));
      });

      test('should exclude incomplete workouts when includeIncomplete is false', () {
        // Arrange
        final options = ExportOptions(
          includeIncomplete: false,
        );

        // Act
        final filtered = service._filterWorkouts(testWorkouts, options);

        // Assert
        expect(filtered.length, equals(2)); // Only completed workouts
        expect(filtered.every((w) => w.isCompleted), isTrue);
      });

      test('should include incomplete workouts when includeIncomplete is true', () {
        // Arrange
        final options = ExportOptions(
          includeIncomplete: true,
        );

        // Act
        final filtered = service._filterWorkouts(testWorkouts, options);

        // Assert
        expect(filtered.length, equals(3)); // All workouts
      });

      test('should sort workouts by date (newest first)', () {
        // Arrange
        final options = ExportOptions();

        // Act
        final filtered = service._filterWorkouts(testWorkouts, options);

        // Assert
        expect(filtered.length, greaterThan(1));
        for (int i = 0; i < filtered.length - 1; i++) {
          expect(
            filtered[i].createdAt.isAfter(filtered[i + 1].createdAt) ||
                filtered[i].createdAt.isAtSameMomentAs(filtered[i + 1].createdAt),
            isTrue,
          );
        }
      });

      test('should apply multiple filters together', () {
        // Arrange
        final options = ExportOptions(
          workoutIds: ['workout1', 'workout2', 'workout3'],
          startDate: DateTime(2024, 1, 15),
          endDate: DateTime(2024, 1, 17),
          includeIncomplete: false,
        );

        // Act
        final filtered = service._filterWorkouts(testWorkouts, options);

        // Assert
        expect(filtered.length, equals(2)); // workout1 and workout2
        expect(filtered.every((w) => w.isCompleted), isTrue);
      });
    });

    group('JSON Export', () {
      test('should generate valid JSON structure', () {
        // Arrange
        final options = ExportOptions(format: ExportFormat.json);

        // Act
        final json = service._generateJson([testWorkouts.first], options);
        final parsed = jsonDecode(json);

        // Assert
        expect(parsed['version'], equals('1.0.0'));
        expect(parsed['app'], equals('GymBro TrackLog'));
        expect(parsed['exportDate'], isNotNull);
        expect(parsed['workouts'], isA<List>());
        expect(parsed['stats'], isA<Map>());
      });

      test('should include export statistics', () {
        // Arrange
        final options = ExportOptions();

        // Act
        final json = service._generateJson(testWorkouts.take(2).toList(), options);
        final parsed = jsonDecode(json);
        final stats = parsed['stats'];

        // Assert
        expect(stats['totalWorkouts'], equals(2));
        expect(stats['completedWorkouts'], equals(2));
        expect(stats['totalExercises'], greaterThan(0));
        expect(stats['totalSets'], greaterThan(0));
      });

      test('should pretty print JSON when compressJson is false', () {
        // Arrange
        final options = ExportOptions(compressJson: false);

        // Act
        final json = service._generateJson([testWorkouts.first], options);

        // Assert
        expect(json, contains('\n')); // Should have newlines
        expect(json, contains('  ')); // Should have indentation
      });

      test('should compress JSON when compressJson is true', () {
        // Arrange
        final options = ExportOptions(compressJson: true);

        // Act
        final json = service._generateJson([testWorkouts.first], options);

        // Assert - Compressed JSON has fewer newlines
        final newlineCount = '\n'.allMatches(json).length;
        expect(newlineCount, lessThan(10)); // Compact format
      });

      test('should exclude notes when includeNotes is false', () {
        // Arrange
        final options = ExportOptions(includeNotes: false);

        // Act
        final json = service._generateJson([testWorkouts.first], options);

        // Assert
        expect(json, isNot(contains('notes')));
        expect(json, isNot(contains('Good form')));
      });

      test('should include notes when includeNotes is true', () {
        // Arrange
        final options = ExportOptions(includeNotes: true);

        // Act
        final json = service._generateJson([testWorkouts.first], options);

        // Assert
        expect(json, contains('notes'));
      });

      test('should exclude RPE when includeRPE is false', () {
        // Arrange
        final options = ExportOptions(includeRPE: false);

        // Act
        final json = service._generateJson([testWorkouts.first], options);

        // Assert
        expect(json, isNot(contains('"rpe"')));
      });

      test('should exclude set durations when includeSetDurations is false', () {
        // Arrange
        final options = ExportOptions(includeSetDurations: false);

        // Act
        final json = service._generateJson([testWorkouts.first], options);

        // Assert
        expect(json, isNot(contains('setDurationMillis')));
        expect(json, isNot(contains('setStartedAt')));
      });
    });

    group('CSV Export', () {
      test('should generate CSV with header row', () {
        // Arrange
        final options = ExportOptions(format: ExportFormat.csv);

        // Act
        final csv = service._generateCsv([testWorkouts.first], options);
        final lines = csv.split('\n');

        // Assert
        expect(lines.first, contains('Workout Date'));
        expect(lines.first, contains('Exercise'));
        expect(lines.first, contains('Weight'));
        expect(lines.first, contains('Reps'));
        expect(lines.first, contains('Volume'));
      });

      test('should include RPE column when includeRPE is true', () {
        // Arrange
        final options = ExportOptions(includeRPE: true);

        // Act
        final csv = service._generateCsv([testWorkouts.first], options);

        // Assert
        expect(csv, contains('RPE'));
      });

      test('should exclude RPE column when includeRPE is false', () {
        // Arrange
        final options = ExportOptions(includeRPE: false);

        // Act
        final csv = service._generateCsv([testWorkouts.first], options);
        final lines = csv.split('\n');

        // Assert
        expect(lines.first, isNot(contains('RPE')));
      });

      test('should include Duration column when includeSetDurations is true', () {
        // Arrange
        final options = ExportOptions(includeSetDurations: true);

        // Act
        final csv = service._generateCsv([testWorkouts.first], options);

        // Assert
        expect(csv, contains('Duration'));
      });

      test('should include Notes column when includeNotes is true', () {
        // Arrange
        final options = ExportOptions(includeNotes: true);

        // Act
        final csv = service._generateCsv([testWorkouts.first], options);

        // Assert
        expect(csv, contains('Notes'));
        expect(csv, contains('Good form'));
      });

      test('should escape quotes in notes', () {
        // Arrange
        final workoutWithQuotes = Workout(
          name: 'Test',
          exercises: [
            Exercise(
              name: 'Exercise',
              sets: [
                ExerciseSet(
                  setNumber: 1,
                  weight: 100,
                  reps: 10,
                  isCompleted: true,
                  notes: 'Notes with "quotes"',
                ),
              ],
            ),
          ],
          createdAt: DateTime.now(),
        );
        final options = ExportOptions(includeNotes: true);

        // Act
        final csv = service._generateCsv([workoutWithQuotes], options);

        // Assert
        expect(csv, contains('""')); // Escaped quotes
      });

      test('should only include completed sets', () {
        // Arrange
        final workoutWithIncompleteSets = Workout(
          name: 'Test',
          exercises: [
            Exercise(
              name: 'Exercise',
              sets: [
                ExerciseSet(
                  setNumber: 1,
                  weight: 100,
                  reps: 10,
                  isCompleted: true,
                ),
                ExerciseSet(
                  setNumber: 2,
                  weight: 100,
                  reps: 10,
                  isCompleted: false, // Incomplete
                ),
              ],
            ),
          ],
          createdAt: DateTime.now(),
        );
        final options = ExportOptions();

        // Act
        final csv = service._generateCsv([workoutWithIncompleteSets], options);
        final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();

        // Assert
        expect(lines.length, equals(2)); // Header + 1 completed set
      });

      test('should format data correctly', () {
        // Arrange
        final options = ExportOptions(
          includeRPE: true,
          includeNotes: false,
          includeSetDurations: false,
        );

        // Act
        final csv = service._generateCsv([testWorkouts.first], options);
        final lines = csv.split('\n');
        final dataLine = lines[1]; // First data row

        // Assert
        expect(dataLine, contains('Push Day'));
        expect(dataLine, contains('Bench Press'));
        expect(dataLine, contains('100')); // Weight
        expect(dataLine, contains('10')); // Reps
        expect(dataLine, contains('8')); // RPE
      });

      test('should use actualReps if available, otherwise use reps', () {
        // Arrange
        final options = ExportOptions();

        // Act
        final csv = service._generateCsv([testWorkouts.first], options);

        // Assert
        // First set has actualReps = 10
        expect(csv, contains(',10,')); // actualReps
        // Second set has actualReps = 9
        expect(csv, contains(',9,')); // actualReps
      });
    });

    group('Markdown Export', () {
      test('should generate markdown with header', () {
        // Arrange
        final options = ExportOptions(format: ExportFormat.markdown);

        // Act
        final markdown = service._generateMarkdown([testWorkouts.first], options);

        // Assert
        expect(markdown, contains('# 🏋️‍♂️ GymBro Workout Export'));
        expect(markdown, contains('**Export Date:**'));
        expect(markdown, contains('**Total Workouts:**'));
      });

      test('should format workouts as sections', () {
        // Arrange
        final options = ExportOptions();

        // Act
        final markdown = service._generateMarkdown([testWorkouts.first], options);

        // Assert
        expect(markdown, contains('## 📅')); // Workout header
        expect(markdown, contains('Push Day'));
        expect(markdown, contains('### 💪')); // Exercise header
        expect(markdown, contains('Bench Press'));
      });

      test('should include workout duration when available', () {
        // Arrange
        final options = ExportOptions();

        // Act
        final markdown = service._generateMarkdown([testWorkouts.first], options);

        // Assert
        expect(markdown, contains('⏱️ **Duration:**'));
        expect(markdown, contains('60 minutes'));
      });

      test('should format sets as table', () {
        // Arrange
        final options = ExportOptions();

        // Act
        final markdown = service._generateMarkdown([testWorkouts.first], options);

        // Assert
        expect(markdown, contains('| Set | Weight | Reps | Volume |'));
        expect(markdown, contains('|-----|--------|------|--------|'));
        expect(markdown, contains('| 1 | 100.0 kg | 10 | 1000.0 kg |'));
      });

      test('should include RPE column when includeRPE is true', () {
        // Arrange
        final options = ExportOptions(includeRPE: true);

        // Act
        final markdown = service._generateMarkdown([testWorkouts.first], options);

        // Assert
        expect(markdown, contains('RPE'));
        expect(markdown, contains('| 8 |')); // RPE value
      });

      test('should exclude RPE column when includeRPE is false', () {
        // Arrange
        final options = ExportOptions(includeRPE: false);

        // Act
        final markdown = service._generateMarkdown([testWorkouts.first], options);
        final lines = markdown.split('\n');
        final headerLine = lines.firstWhere((line) => line.contains('| Set |'));

        // Assert
        expect(headerLine, isNot(contains('RPE')));
      });

      test('should include notes column when includeNotes is true', () {
        // Arrange
        final options = ExportOptions(includeNotes: true);

        // Act
        final markdown = service._generateMarkdown([testWorkouts.first], options);

        // Assert
        expect(markdown, contains('Notes'));
        expect(markdown, contains('Good form'));
      });

      test('should handle skipped exercises', () {
        // Arrange
        final workoutWithSkip = Workout(
          name: 'Test',
          exercises: [
            Exercise(
              name: 'Skipped Exercise',
              isSkipped: true,
              skipReason: 'Injury',
              sets: [],
            ),
          ],
          createdAt: DateTime.now(),
        );
        final options = ExportOptions();

        // Act
        final markdown = service._generateMarkdown([workoutWithSkip], options);

        // Assert
        expect(markdown, contains('*Skipped: Injury*'));
      });
    });
  });
}
