/// Additional unit tests for StrongCsvParser covering uncovered date format paths
/// and edge cases not exercised by the primary test file.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/import/data/parsers/strong_csv_parser.dart';

void main() {
  late StrongCsvParser parser;

  setUp(() {
    parser = StrongCsvParser();
  });

  String csv(List<String> rows) => rows.join('\r\n');

  const strongHeader =
      'Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes';

  // -------------------------------------------------------------------------
  // Date parsing — alternative formats
  // -------------------------------------------------------------------------
  group('StrongCsvParser - alternative date formats', () {
    test('parses US date format MM/DD/YYYY', () {
      // Exercises the RegExp branch: r'(\d{2})/(\d{2})/(\d{4})'
      final content = csv([
        strongHeader,
        '01/15/2024,Push Day,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);

      expect(result.workouts.length, 1);
      final date = result.workouts.first.date;
      expect(date.year, 2024);
      expect(date.month, 1);
      expect(date.day, 15);
    });

    test('parses date with only YYYY-MM-DD (no time component) via regex', () {
      // Falls through DateTime.parse first, but let us verify the date is correct
      final content = csv([
        strongHeader,
        '2024-06-20,Leg Day,,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.date.year, 2024);
      expect(result.workouts.first.date.month, 6);
      expect(result.workouts.first.date.day, 20);
    });

    test('parses YYYY-MM-DD HH:MM format (without seconds)', () {
      // Exercises the RegExp: r'(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})'
      final content = csv([
        strongHeader,
        '2024-03-10 14:30,Morning Workout,,Overhead Press,1,60,10,,,',
      ]);

      final result = parser.parse(content);

      expect(result.workouts.length, 1);
      final date = result.workouts.first.date;
      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 10);
    });
  });

  // -------------------------------------------------------------------------
  // Duration parsing — edge cases
  // -------------------------------------------------------------------------
  group('StrongCsvParser - duration edge cases', () {
    test('duration with only one part returns null', () {
      // If parts.length == 1, _parseDuration returns null
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,60,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      // Single part (no colon) → null duration
      expect(result.workouts.first.durationMinutes, isNull);
    });

    test('HH:MM:SS duration is correctly parsed as hours*60+minutes', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Long Workout,2:15:00,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      // 2 hours * 60 + 15 minutes = 135
      expect(result.workouts.first.durationMinutes, 135);
    });

    test('zero duration returns 0 minutes', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Quick Workout,0:00,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.durationMinutes, 0);
    });
  });

  // -------------------------------------------------------------------------
  // Numeric field edge cases
  // -------------------------------------------------------------------------
  group('StrongCsvParser - numeric field edge cases', () {
    test('integer weight is parsed as double', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.exercises.first.sets.first.weight, 80.0);
      expect(result.workouts.first.exercises.first.sets.first.weight, isA<double>());
    });

    test('rpe field is null when not present', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      final set = result.workouts.first.exercises.first.sets.first;
      // StrongCsvParser does not map RPE from Strong format — confirm it is null
      expect(set.rpe, isNull);
    });

    test('set notes are parsed from Notes column', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,Touch and go,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.exercises.first.sets.first.notes, 'Touch and go');
    });

    test('all numeric fields can be null', () {
      // No weight, no reps, no distance, no seconds
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Plank,1,,,,,,',
      ]);

      final result = parser.parse(content);
      final set = result.workouts.first.exercises.first.sets.first;
      expect(set.weight, isNull);
      expect(set.reps, isNull);
      expect(set.distance, isNull);
      expect(set.seconds, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Multiple exercises and sets
  // -------------------------------------------------------------------------
  group('StrongCsvParser - multi-exercise multi-set workouts', () {
    test('parses a full PPL workout with multiple exercises and sets', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,60:00,Bench Press,1,80,8,,,',
        '2024-01-15 10:00:00,Push Day,60:00,Bench Press,2,80,6,,,',
        '2024-01-15 10:00:00,Push Day,60:00,Bench Press,3,75,6,,,',
        '2024-01-15 10:00:00,Push Day,60:00,Overhead Press,1,50,10,,,',
        '2024-01-15 10:00:00,Push Day,60:00,Overhead Press,2,50,8,,,',
      ]);

      final result = parser.parse(content);

      expect(result.workouts.length, 1);
      expect(result.workouts.first.exercises.length, 2);
      expect(
        result.workouts.first.exercises
            .firstWhere((e) => e.originalName == 'Bench Press')
            .sets
            .length,
        3,
      );
      expect(
        result.workouts.first.exercises
            .firstWhere((e) => e.originalName == 'Overhead Press')
            .sets
            .length,
        2,
      );
    });

    test('exercise occurrence counts are tracked across multiple workouts', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,',
        '2024-01-22 10:00:00,Push Day,,Bench Press,1,82.5,8,,,',
      ]);

      final result = parser.parse(content);

      // 2 separate workouts (different dates)
      expect(result.workouts.length, 2);
      // Bench Press appears in 2 rows → 2 occurrences
      final benchEntry = result.unmappedExercises.firstWhere(
        (u) => u.originalName == 'Bench Press',
      );
      expect(benchEntry.occurrences, 2);
    });
  });

  // -------------------------------------------------------------------------
  // Header validation
  // -------------------------------------------------------------------------
  group('StrongCsvParser - header validation', () {
    test('case-insensitive column matching works', () {
      // Headers in different case — should still be found
      const lowerHeader =
          'date,workout name,duration,exercise name,set order,weight,reps,distance,seconds,notes,workout notes';
      final content = csv([
        lowerHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      // Case-insensitive column matching → no missing-column warning
      expect(
        result.warnings.any((w) => w.contains('Missing required columns')),
        isFalse,
      );
      expect(result.parsedRows, 1);
    });

    test('adds warning when Weight column missing', () {
      const noWeightHeader = 'Date,Workout Name,Exercise Name,Reps,Set Order';
      final content = csv([
        noWeightHeader,
        '2024-01-15 10:00:00,Push Day,Bench Press,8,1',
      ]);

      final result = parser.parse(content);
      expect(result.warnings, isNotEmpty);
    });
  });
}
