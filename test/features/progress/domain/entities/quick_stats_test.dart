/// QuickStats tests - computed formatting properties, empty factory.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';

void main() {
  group('QuickStats.empty', () {
    test('creates zeroed instance', () {
      final stats = QuickStats.empty();
      expect(stats.totalVolume, 0);
      expect(stats.volumeIncrease, 0);
      expect(stats.maxPR, 0);
      expect(stats.prExercise, 'N/A');
      expect(stats.totalWorkouts, 0);
    });
  });

  group('QuickStats.formattedVolume', () {
    test('formats below 1000 as integer kg', () {
      const stats = QuickStats(
        totalVolume: 500,
        volumeIncrease: 0,
        maxPR: 0,
        prExercise: 'N/A',
        totalWorkouts: 0,
      );
      expect(stats.formattedVolume, '500 kg');
    });

    test('formats 1000+ as k kg', () {
      const stats = QuickStats(
        totalVolume: 1500,
        volumeIncrease: 0,
        maxPR: 0,
        prExercise: 'N/A',
        totalWorkouts: 0,
      );
      expect(stats.formattedVolume, '1.5k kg');
    });

    test('formats exactly 1000', () {
      const stats = QuickStats(
        totalVolume: 1000,
        volumeIncrease: 0,
        maxPR: 0,
        prExercise: 'N/A',
        totalWorkouts: 0,
      );
      expect(stats.formattedVolume, '1.0k kg');
    });

    test('formats zero', () {
      const stats = QuickStats(
        totalVolume: 0,
        volumeIncrease: 0,
        maxPR: 0,
        prExercise: 'N/A',
        totalWorkouts: 0,
      );
      expect(stats.formattedVolume, '0 kg');
    });
  });

  group('QuickStats.formattedVolumeIncrease', () {
    test('positive increase', () {
      const stats = QuickStats(
        totalVolume: 0,
        volumeIncrease: 15.7,
        maxPR: 0,
        prExercise: 'N/A',
        totalWorkouts: 0,
      );
      expect(stats.formattedVolumeIncrease, '+16%');
    });

    test('negative increase', () {
      const stats = QuickStats(
        totalVolume: 0,
        volumeIncrease: -10.3,
        maxPR: 0,
        prExercise: 'N/A',
        totalWorkouts: 0,
      );
      expect(stats.formattedVolumeIncrease, '-10%');
    });

    test('zero increase', () {
      const stats = QuickStats(
        totalVolume: 0,
        volumeIncrease: 0,
        maxPR: 0,
        prExercise: 'N/A',
        totalWorkouts: 0,
      );
      expect(stats.formattedVolumeIncrease, '0%');
    });
  });

  group('QuickStats.formattedMaxPR', () {
    test('formats PR as integer kg', () {
      const stats = QuickStats(
        totalVolume: 0,
        volumeIncrease: 0,
        maxPR: 120.5,
        prExercise: 'Bench Press',
        totalWorkouts: 0,
      );
      expect(stats.formattedMaxPR, '121 kg');
    });

    test('formats zero PR', () {
      expect(QuickStats.empty().formattedMaxPR, '0 kg');
    });
  });
}
