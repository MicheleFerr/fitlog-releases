import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/utils/document_data_extractor.dart';

void main() {
  group('DocumentDataExtractor', () {
    late DocumentDataExtractor extractor;

    setUp(() {
      extractor = DocumentDataExtractor();
    });

    group('extractSets', () {
      test('extracts single set with weight and reps', () {
        const content = 'Bench Press exercise on December 5\nset 1 80 kg 10 reps';
        final sets = extractor.extractSets(content);

        expect(sets, hasLength(1));
        expect(sets[0].setNumber, 1);
        expect(sets[0].weight, 80.0);
        expect(sets[0].reps, 10);
      });

      test('extracts multiple sets', () {
        const content = '''
Squat exercise on December 5
set 1 100 kg 8 reps
set 2 110 kg 6 reps
set 3 120 kg 4 reps
''';
        final sets = extractor.extractSets(content);

        expect(sets, hasLength(3));
        expect(sets[0].weight, 100.0);
        expect(sets[1].weight, 110.0);
        expect(sets[2].weight, 120.0);
      });

      test('handles bodyweight sets', () {
        const content = 'Pull-ups exercise\nset 1 12 reps bodyweight';
        final sets = extractor.extractSets(content);

        expect(sets, hasLength(1));
        expect(sets[0].weight, isNull);
        expect(sets[0].reps, 12);
        expect(sets[0].isBodyweight, true);
      });
    });

    group('extractVolume', () {
      test('extracts total volume from workout document', () {
        const content = 'workout on December 5\ntotal volume 5000 kg';
        final volume = extractor.extractVolume(content);

        expect(volume, 5000.0);
      });

      test('extracts exercise volume', () {
        const content = 'Bench Press exercise\nexercise volume 2400 kg';
        final volume = extractor.extractExerciseVolume(content);

        expect(volume, 2400.0);
      });

      test('returns null when no volume found', () {
        const content = 'some random content';
        final volume = extractor.extractVolume(content);

        expect(volume, isNull);
      });
    });

    group('extractDate', () {
      test('extracts date from workout content', () {
        const content = 'workout on December 5, 2024 Monday';
        final date = extractor.extractDateString(content);

        expect(date, 'December 5, 2024');
      });
    });

    group('extractExerciseName', () {
      test('extracts exercise name from document ID', () {
        const docId = 'exercise_workout123_bench_press';
        final name = extractor.extractExerciseNameFromId(docId);

        expect(name, 'bench_press');
      });

      test('extracts exercise name from content', () {
        const content = 'Bench Press exercise on December 5';
        final name = extractor.extractExerciseNameFromContent(content);

        expect(name, 'Bench Press');
      });
    });

    group('extractPersonalRecord', () {
      test('extracts PR from history document', () {
        const content = 'Squat exercise history\npersonal record 150.0 kg estimated 1RM';
        final pr = extractor.extractPersonalRecord(content);

        expect(pr, 150.0);
      });
    });

    group('calculation methods', () {
      test('calculateMaxWeight returns highest weight from sets', () {
        const content = '''
set 1 80 kg 10 reps
set 2 90 kg 8 reps
set 3 85 kg 9 reps
''';
        final sets = extractor.extractSets(content);
        final maxWeight = extractor.calculateMaxWeight(sets);

        expect(maxWeight, 90.0);
      });

      test('calculateMaxWeight returns null for empty sets', () {
        final maxWeight = extractor.calculateMaxWeight([]);

        expect(maxWeight, isNull);
      });

      test('calculateAverageWeight calculates correct average', () {
        const content = '''
set 1 80 kg 10 reps
set 2 90 kg 8 reps
set 3 70 kg 12 reps
''';
        final sets = extractor.extractSets(content);
        final avgWeight = extractor.calculateAverageWeight(sets);

        expect(avgWeight, 80.0); // (80 + 90 + 70) / 3
      });

      test('calculateTotalVolume sums up all set volumes', () {
        const content = '''
set 1 100 kg 8 reps
set 2 100 kg 8 reps
set 3 100 kg 8 reps
''';
        final sets = extractor.extractSets(content);
        final totalVolume = extractor.calculateTotalVolume(sets);

        expect(totalVolume, 2400.0); // 100 * 8 * 3 sets
      });
    });

    group('ParsedSet', () {
      test('calculates volume correctly', () {
        const set = ParsedSet(
          setNumber: 1,
          weight: 100.0,
          reps: 10,
        );

        expect(set.volume, 1000.0);
      });

      test('volume is zero for bodyweight sets', () {
        const set = ParsedSet(
          setNumber: 1,
          reps: 12,
          isBodyweight: true,
        );

        expect(set.volume, 0.0);
      });
    });

    group('edge cases', () {
      test('handles mixed weight and bodyweight sets', () {
        const content = '''
set 1 80 kg 10 reps
set 2 12 reps bodyweight
set 3 85 kg 8 reps
''';
        final sets = extractor.extractSets(content);

        expect(sets, hasLength(3));
        expect(sets[0].weight, 80.0);
        expect(sets[1].isBodyweight, true);
        expect(sets[2].weight, 85.0);
      });

      test('extractExerciseNameFromId handles multi-word exercise names', () {
        const docId = 'exercise_workout123_barbell_bench_press';
        final name = extractor.extractExerciseNameFromId(docId);

        expect(name, 'barbell_bench_press');
      });

      test('extractExerciseNameFromId returns null for invalid format', () {
        const docId = 'workout_123';
        final name = extractor.extractExerciseNameFromId(docId);

        expect(name, isNull);
      });

      test('extractDuration extracts workout duration', () {
        const content = 'workout on December 5\nworkout duration 45 minutes';
        final duration = extractor.extractDuration(content);

        expect(duration, 45);
      });

      test('extractTotalSets extracts total sets count', () {
        const content = 'workout summary\ncompleted 15 sets';
        final totalSets = extractor.extractTotalSets(content);

        expect(totalSets, 15);
      });
    });
  });
}
