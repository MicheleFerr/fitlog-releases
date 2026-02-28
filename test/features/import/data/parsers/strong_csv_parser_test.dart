import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/import/data/parsers/strong_csv_parser.dart';

void main() {
  late StrongCsvParser parser;

  setUp(() {
    parser = StrongCsvParser();
  });

  // ---------------------------------------------------------------------------
  // The CsvToListConverter (with shouldParseNumbers: false, allowInvalid: true)
  // defaults to \r\n line endings. Use this helper to build CSV strings.
  String csv(List<String> rows) => rows.join('\r\n');

  const strongHeader =
      'Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes';

  // ---------------------------------------------------------------------------
  group('StrongCsvParser - happy path', () {
    test('parses a single workout with one exercise and two sets', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,45:00,Bench Press,1,80,8,,,Good form,Great session',
        '2024-01-15 10:30:00,Push Day,45:00,Bench Press,2,80,6,,,Last set,Great session',
      ]);

      final result = parser.parse(content);

      expect(result.sourceApp, 'strong');
      expect(result.workouts.length, 1);
      expect(result.parsedRows, 2);
      expect(result.totalRows, 2);

      final workout = result.workouts.first;
      expect(workout.name, 'Push Day');
      expect(workout.date, DateTime(2024, 1, 15, 10, 30, 0));
      expect(workout.durationMinutes, 45);
      expect(workout.exercises.length, 1);

      final exercise = workout.exercises.first;
      expect(exercise.originalName, 'Bench Press');
      expect(exercise.sets.length, 2);

      final set1 = exercise.sets.first;
      expect(set1.setNumber, 1);
      expect(set1.weight, 80.0);
      expect(set1.reps, 8);
      expect(set1.notes, 'Good form');
    });

    test('parses multiple workouts from different dates', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,60:00,Bench Press,1,80,8,,,',
        '2024-01-16 09:00:00,Pull Day,50:00,Pull Up,1,0,8,,,',
      ]);

      final result = parser.parse(content);

      expect(result.workouts.length, 2);
      // Sorted newest first
      expect(result.workouts.first.name, 'Pull Day');
      expect(result.workouts.last.name, 'Push Day');
    });

    test('parses multiple exercises within one workout', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,60:00,Bench Press,1,80,8,,,',
        '2024-01-15 10:00:00,Push Day,60:00,Overhead Press,1,50,10,,,',
      ]);

      final result = parser.parse(content);

      expect(result.workouts.length, 1);
      expect(result.workouts.first.exercises.length, 2);
    });

    test('handles HH:MM:SS duration format', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Leg Day,1:30:00,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.durationMinutes, 90); // 1h30m
    });

    test('handles MM:SS duration format', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Leg Day,45:00,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.durationMinutes, 45);
    });

    test('handles empty duration field', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Leg Day,,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.durationMinutes, isNull);
    });

    test('parses optional numeric fields: distance and seconds', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Cardio,,Running,1,,,5.0,1800,,',
      ]);

      final result = parser.parse(content);

      final set = result.workouts.first.exercises.first.sets.first;
      expect(set.distance, 5.0);
      expect(set.seconds, 1800);
    });

    test('handles empty weight and reps gracefully', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Workout,,Plank,1,,,, 60,,',
      ]);

      final result = parser.parse(content);

      final set = result.workouts.first.exercises.first.sets.first;
      expect(set.weight, isNull);
      expect(set.reps, isNull);
      expect(set.seconds, 60);
    });

    test('collects unmapped exercises with occurrence counts', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,',
        '2024-01-15 10:00:00,Push Day,,Bench Press,2,80,6,,,',
        '2024-01-15 10:00:00,Push Day,,Overhead Press,1,50,10,,,',
      ]);

      final result = parser.parse(content);

      expect(result.unmappedExercises.length, 2);
      // Sorted by occurrence descending
      expect(result.unmappedExercises.first.originalName, 'Bench Press');
      expect(result.unmappedExercises.first.occurrences, 2);
      expect(result.unmappedExercises.last.originalName, 'Overhead Press');
      expect(result.unmappedExercises.last.occurrences, 1);
    });

    test('autoMappedExercises is empty after parse (mapping happens later)', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.autoMappedExercises, isEmpty);
    });

    test('workout notes are preserved', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,,Bench Press,1,80,8,,,Set note,Workout note here',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.notes, 'Workout note here');
    });

    test('null notes when workout notes column is empty', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,,Bench Press,1,80,8,,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.notes, isNull);
    });

    test('sets are sorted by set number', () {
      // Provide set 2 before set 1 to ensure sorting works
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,2,75,6,,,',
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      final sets = result.workouts.first.exercises.first.sets;
      expect(sets[0].setNumber, 1);
      expect(sets[1].setNumber, 2);
    });
  });

  // ---------------------------------------------------------------------------
  group('StrongCsvParser - date parsing', () {
    test('parses standard Strong date format YYYY-MM-DD HH:MM:SS', () {
      final content = csv([
        strongHeader,
        '2024-03-20 08:15:30,Workout,,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.date, DateTime(2024, 3, 20, 8, 15, 30));
    });

    test('parses date without time component', () {
      final content = csv([
        strongHeader,
        '2024-03-20,Workout,,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.date.year, 2024);
      expect(result.workouts.first.date.month, 3);
      expect(result.workouts.first.date.day, 20);
    });

    test('records warning for unparseable date', () {
      final content = csv([
        strongHeader,
        'not-a-date,Workout,,Squat,1,100,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.any((w) => w.contains('Invalid date')), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  group('StrongCsvParser - empty / malformed input', () {
    test('handles empty CSV string', () {
      final result = parser.parse('');

      expect(result.workouts, isEmpty);
      expect(result.warnings, contains('CSV file is empty'));
      expect(result.totalRows, 0);
      expect(result.parsedRows, 0);
    });

    test('handles header-only CSV (no data rows)', () {
      final result = parser.parse(strongHeader);

      expect(result.workouts, isEmpty);
      expect(result.parsedRows, 0);
      expect(result.totalRows, 0);
    });

    test('skips completely empty rows', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,,Bench Press,1,80,8,,,',
        '', // empty row
        '2024-01-15 10:30:00,Push Day,,Bench Press,2,75,6,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 2);
    });

    test('skips rows with missing required fields (date)', () {
      final content = csv([
        strongHeader,
        ',Push Day,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 0);
      expect(result.workouts, isEmpty);
    });

    test('skips rows with missing workout name', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,,,Bench Press,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 0);
    });

    test('skips rows with missing exercise name', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,,,1,80,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 0);
    });

    test('adds warning for missing required columns', () {
      const incompleteHeader = 'Date,Workout Name,Exercise Name';
      final content = csv([
        incompleteHeader,
        '2024-01-15 10:30:00,Push Day,Bench Press',
      ]);

      final result = parser.parse(content);
      expect(result.warnings, isNotEmpty);
      expect(
        result.warnings.any((w) => w.contains('Missing required columns')),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('StrongCsvParser - edge cases', () {
    test('handles decimal weight values', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,,Bench Press,1,82.5,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.first.exercises.first.sets.first.weight, 82.5);
    });

    test('handles set order defaulting to 1 when missing or invalid', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:30:00,Push Day,,Bench Press,abc,80,8,,,',
      ]);

      final result = parser.parse(content);
      // Falls back to 1 on parse failure
      expect(
        result.workouts.first.exercises.first.sets.first.setNumber,
        1,
      );
    });

    test('same workout name on different dates = separate workouts', () {
      final content = csv([
        strongHeader,
        '2024-01-15 10:00:00,Push Day,,Bench Press,1,80,8,,,',
        '2024-01-22 10:00:00,Push Day,,Bench Press,1,82.5,8,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts.length, 2);
    });

    test('workouts sorted newest first', () {
      final content = csv([
        strongHeader,
        '2024-01-10 10:00:00,Old Workout,,Squat,1,100,5,,,',
        '2024-01-20 10:00:00,New Workout,,Squat,1,110,5,,,',
        '2024-01-15 10:00:00,Mid Workout,,Squat,1,105,5,,,',
      ]);

      final result = parser.parse(content);
      expect(result.workouts[0].name, 'New Workout');
      expect(result.workouts[1].name, 'Mid Workout');
      expect(result.workouts[2].name, 'Old Workout');
    });

    test('handles CSV with extra columns gracefully', () {
      const extendedHeader = '$strongHeader,Extra Column,Another Extra';
      final content = csv([
        extendedHeader,
        '2024-01-15 10:30:00,Push Day,,Bench Press,1,80,8,,,,,extra1,extra2',
      ]);

      final result = parser.parse(content);
      expect(result.parsedRows, 1);
    });

    test('expectedHeaders constant contains 11 columns', () {
      expect(StrongCsvParser.expectedHeaders.length, 11);
      expect(StrongCsvParser.expectedHeaders, contains('Date'));
      expect(StrongCsvParser.expectedHeaders, contains('Exercise Name'));
    });
  });
}
