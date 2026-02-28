import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/import/data/parsers/hevy_csv_parser.dart';

void main() {
  late HevyCsvParser parser;

  setUp(() {
    parser = HevyCsvParser();
  });

  // The CsvToListConverter (with shouldParseNumbers: false, allowInvalid: true)
  // defaults to \r\n. Use this helper to build CSV strings with proper line endings.
  String csv(List<String> rows) => rows.join('\r\n');

  // ---------------------------------------------------------------------------
  // Hevy CSV headers (both unit variants)
  // Note: Hevy dates contain commas so they MUST be quoted in tests that use
  // the "DD Mon YYYY, HH:MM" format.
  const hevyHeaderLbs =
      'title,start_time,end_time,description,exercise_title,superset_id,exercise_notes,set_index,set_type,weight_lbs,reps,distance_miles,duration_seconds,rpe';

  const hevyHeaderKg =
      'title,start_time,end_time,description,exercise_title,superset_id,exercise_notes,set_index,set_type,weight_kg,reps,distance_km,duration_seconds,rpe';

  // ---------------------------------------------------------------------------
  group('HevyCsvParser - happy path', () {
    test('parses a single workout with one exercise and one set (lbs)', () {
      final content = csv([
        hevyHeaderLbs,
        // Use ISO dates to avoid comma-in-field issues
        'Push Day,2025-03-28T17:29:00,2025-03-28T18:29:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);

      expect(result.sourceApp, 'hevy');
      expect(result.workouts.length, 1);
      expect(result.parsedRows, 1);

      final workout = result.workouts.first;
      expect(workout.name, 'Push Day');
      // lbs converted to kg: 175 * 0.453592 ≈ 79.38
      final weight = workout.exercises.first.sets.first.weight!;
      expect(weight, closeTo(79.38, 0.1));
    });

    test('parses without unit conversion when header is kg', () {
      final content = csv([
        hevyHeaderKg,
        'Push Day,2025-03-28T17:29:00,2025-03-28T18:29:00,,Bench Press,,,0,normal,80,8,,,',
      ]);

      final result = parser.parse(content);
      final weight = result.workouts.first.exercises.first.sets.first.weight!;
      expect(weight, closeTo(80.0, 0.001));
    });

    test('calculates duration from start and end time', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:23:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      // 83 minutes difference
      expect(result.workouts.first.durationMinutes, 83);
    });

    test('parses multiple sets for one exercise (0-based set_index)', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,1,normal,185,6,,,',
      ]);

      final result = parser.parse(content);

      expect(result.workouts.length, 1);
      final sets = result.workouts.first.exercises.first.sets;
      expect(sets.length, 2);
      // set_index 0 -> setNumber 1, set_index 1 -> setNumber 2
      expect(sets[0].setNumber, 1);
      expect(sets[1].setNumber, 2);
    });

    test('parses multiple exercises within one workout', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Overhead Press,,,0,normal,115,10,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.exercises.length, 2);
    });

    test('parses multiple workouts', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
        'Pull Day,2025-03-29T09:00:00,2025-03-29T10:00:00,,Pull Up,,,0,normal,0,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.length, 2);
      // Sorted newest first
      expect(result.workouts.first.name, 'Pull Day');
    });

    test('parses rpe field', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,8',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.exercises.first.sets.first.rpe, 8);
    });

    test('parses duration_seconds for timed exercises', () {
      final content = csv([
        hevyHeaderLbs,
        'Core Work,2025-03-28T17:00:00,2025-03-28T17:30:00,,Plank,,,0,normal,0,,,60,',
      ]);

      final result = parser.parse(content);
      expect(
        result.workouts.first.exercises.first.sets.first.seconds,
        60,
      );
    });

    test('converts distance from miles to km when lbs header', () {
      const csvWithDist =
          'title,start_time,end_time,description,exercise_title,superset_id,exercise_notes,set_index,set_type,weight_lbs,reps,distance_miles,duration_seconds,rpe\r\n'
          'Cardio,2025-03-28T17:00:00,2025-03-28T18:00:00,,Running,,,0,normal,0,,3.1,1800,';

      final result = parser.parse(csvWithDist);
      final distance =
          result.workouts.first.exercises.first.sets.first.distance!;
      // 3.1 miles * 1.60934 ≈ 4.989 km
      expect(distance, closeTo(4.989, 0.01));
    });

    test('does NOT convert distance when header is km', () {
      final content = csv([
        hevyHeaderKg,
        'Cardio,2025-03-28T17:00:00,2025-03-28T18:00:00,,Running,,,0,normal,0,,5.0,1800,',
      ]);

      final result = parser.parse(content);
      final distance =
          result.workouts.first.exercises.first.sets.first.distance!;
      expect(distance, closeTo(5.0, 0.001));
    });

    test('collects unmapped exercises with occurrence counts', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,1,normal,185,6,,,',
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Overhead Press,,,0,normal,115,10,,,',
      ]);

      final result = parser.parse(content);
      expect(result.unmappedExercises.length, 2);
      expect(result.unmappedExercises.first.originalName, 'Bench Press');
      expect(result.unmappedExercises.first.occurrences, 2);
    });

    test('autoMappedExercises is empty after parse', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.autoMappedExercises, isEmpty);
    });

    test('description / workout notes preserved when non-empty', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,Amazing session,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.notes, 'Amazing session');
    });

    test('notes is null when description column is empty', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.notes, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('HevyCsvParser - date parsing', () {
    test('parses ISO 8601 date format', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:29:00,2025-03-28T18:29:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      final date = result.workouts.first.date;
      expect(date.year, 2025);
      expect(date.month, 3);
      expect(date.day, 28);
      expect(date.hour, 17);
      expect(date.minute, 29);
    });

    test('parses Hevy format without comma: "28 Mar 2025 17:29"', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,28 Mar 2025 17:29,28 Mar 2025 18:29,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      final date = result.workouts.first.date;
      expect(date.year, 2025);
      expect(date.month, 3);
      expect(date.day, 28);
      expect(date.hour, 17);
    });

    test('parses Hevy format with comma using quoted fields', () {
      // Date with comma must be quoted in CSV
      final content = csv([
        hevyHeaderLbs,
        '"Push Day","28 Mar 2025, 17:29","28 Mar 2025, 18:29","","Bench Press","","",0,"normal",175,8,,,',
      ]);

      final result = parser.parse(content);
      final date = result.workouts.first.date;
      expect(date.year, 2025);
      expect(date.month, 3);
      expect(date.day, 28);
      expect(date.hour, 17);
    });

    test('records warning for unparseable date', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,not-a-date,2025-03-28T18:29:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.warnings, isNotEmpty);
      expect(
        result.warnings.any((w) => w.contains('Invalid date')),
        isTrue,
      );
    });

    test('parses all months correctly via Hevy format', () {
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };

      for (final entry in months.entries) {
        final content = csv([
          hevyHeaderLbs,
          'Workout,01 ${entry.key} 2025 10:00,01 ${entry.key} 2025 11:00,,Squat,,,0,normal,100,5,,,',
        ]);

        final result = parser.parse(content);
        expect(
          result.workouts.first.date.month,
          entry.value,
          reason: 'Month ${entry.key} should map to ${entry.value}',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  group('HevyCsvParser - empty / malformed input', () {
    test('handles empty CSV', () {
      final result = parser.parse('');

      expect(result.workouts, isEmpty);
      expect(result.warnings, contains('CSV file is empty'));
      expect(result.totalRows, 0);
      expect(result.parsedRows, 0);
    });

    test('handles header-only CSV', () {
      final result = parser.parse(hevyHeaderLbs);

      expect(result.workouts, isEmpty);
      expect(result.parsedRows, 0);
    });

    test('skips empty rows', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
        '',
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,1,normal,185,6,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 2);
    });

    test('skips rows with missing title', () {
      final content = csv([
        hevyHeaderLbs,
        ',2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 0);
    });

    test('skips rows with missing start_time', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 0);
    });

    test('skips rows with missing exercise_title', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 0);
    });

    test('adds warning when required columns are missing', () {
      const badHeader = 'title,start_time,weight_lbs,reps';
      final content = csv([
        badHeader,
        'Push Day,2025-03-28T17:00:00,175,8',
      ]);

      final result = parser.parse(content);
      expect(
        result.warnings.any((w) => w.contains('Missing required columns')),
        isTrue,
      );
    });

    test('adds warning when no weight column found', () {
      const noWeightHeader =
          'title,start_time,end_time,description,exercise_title,superset_id,exercise_notes,set_index,set_type,reps,duration_seconds,rpe';
      final content = csv([
        noWeightHeader,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,8,,',
      ]);

      final result = parser.parse(content);
      expect(
        result.warnings.any((w) => w.contains('weight')),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('HevyCsvParser - edge cases', () {
    test('set_index defaults to 0 when unparseable', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,abc,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      // index 0 -> setNumber 1
      expect(
        result.workouts.first.exercises.first.sets.first.setNumber,
        1,
      );
    });

    test('workouts sorted newest first', () {
      final content = csv([
        hevyHeaderLbs,
        'Old Workout,2024-01-10T10:00:00,2024-01-10T11:00:00,,Squat,,,0,normal,100,5,,,',
        'New Workout,2024-01-20T10:00:00,2024-01-20T11:00:00,,Squat,,,0,normal,110,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.name, 'New Workout');
      expect(result.workouts.last.name, 'Old Workout');
    });

    test('handles no end_time (duration is null)', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,,,Bench Press,,,0,normal,175,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.durationMinutes, isNull);
    });

    test('totalRows excludes header row', () {
      final content = csv([
        hevyHeaderLbs,
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,0,normal,175,8,,,',
        'Push Day,2025-03-28T17:00:00,2025-03-28T18:00:00,,Bench Press,,,1,normal,185,6,,,',
      ]);

      final result = parser.parse(content);
      expect(result.totalRows, 2);
    });
  });
}
