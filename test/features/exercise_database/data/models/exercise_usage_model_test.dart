// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseUsageModel _baseModel({
  String exerciseId = 'squat',
  String exerciseName = 'Squat con Bilanciere',
  int usageCount = 5,
  DateTime? lastUsedAt,
  DateTime? firstUsedAt,
  String userId = 'user-001',
}) {
  final now = lastUsedAt ?? DateTime(2024, 6, 1, 10);
  final first = firstUsedAt ?? DateTime(2024, 1, 1, 8);
  return ExerciseUsageModel(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    usageCount: usageCount,
    lastUsedAt: now,
    firstUsedAt: first,
    userId: userId,
  );
}

void main() {
  // ================================================================
  // ExerciseUsageModel.firstUse factory
  // ================================================================
  group('ExerciseUsageModel.firstUse', () {
    test('sets usageCount to 1', () {
      final model = ExerciseUsageModel.firstUse(
        exerciseId: 'bench_press',
        exerciseName: 'Panca Piana',
        userId: 'user-001',
      );
      expect(model.usageCount, 1);
    });

    test('stores exerciseId', () {
      final model = ExerciseUsageModel.firstUse(
        exerciseId: 'bench_press',
        exerciseName: 'Panca Piana',
        userId: 'user-001',
      );
      expect(model.exerciseId, 'bench_press');
    });

    test('stores exerciseName', () {
      final model = ExerciseUsageModel.firstUse(
        exerciseId: 'bench_press',
        exerciseName: 'Panca Piana',
        userId: 'user-001',
      );
      expect(model.exerciseName, 'Panca Piana');
    });

    test('stores userId', () {
      final model = ExerciseUsageModel.firstUse(
        exerciseId: 'bench_press',
        exerciseName: 'Panca Piana',
        userId: 'user-abc',
      );
      expect(model.userId, 'user-abc');
    });

    test('lastUsedAt and firstUsedAt are roughly equal (same call)', () {
      final model = ExerciseUsageModel.firstUse(
        exerciseId: 'bench_press',
        exerciseName: 'Panca Piana',
        userId: 'user-001',
      );
      final diff = model.lastUsedAt.difference(model.firstUsedAt).abs();
      expect(diff.inSeconds, lessThan(2));
    });
  });

  // ================================================================
  // Constructor fields
  // ================================================================
  group('ExerciseUsageModel constructor', () {
    test('stores all fields', () {
      final lastUsed = DateTime(2024, 6, 1);
      final firstUsed = DateTime(2024, 1, 1);
      final model = ExerciseUsageModel(
        exerciseId: 'rdl',
        exerciseName: 'Stacco Rumeno',
        usageCount: 12,
        lastUsedAt: lastUsed,
        firstUsedAt: firstUsed,
        userId: 'user-xyz',
      );

      expect(model.exerciseId, 'rdl');
      expect(model.exerciseName, 'Stacco Rumeno');
      expect(model.usageCount, 12);
      expect(model.lastUsedAt, lastUsed);
      expect(model.firstUsedAt, firstUsed);
      expect(model.userId, 'user-xyz');
    });
  });

  // ================================================================
  // getBoost method
  // ================================================================
  group('ExerciseUsageModel.getBoost', () {
    test('returns 0.0 when maxCount is 0', () {
      final model = _baseModel(usageCount: 10);
      expect(model.getBoost(0), 0.0);
    });

    test('returns 1.0 when usageCount equals maxCount', () {
      final model = _baseModel(usageCount: 10);
      expect(model.getBoost(10), closeTo(1.0, 0.001));
    });

    test('returns 0.5 when usageCount is half of maxCount', () {
      final model = _baseModel(usageCount: 5);
      expect(model.getBoost(10), closeTo(0.5, 0.001));
    });

    test('returns 0.0 when usageCount is 0', () {
      final model = _baseModel(usageCount: 0);
      expect(model.getBoost(10), 0.0);
    });

    test('returns value between 0 and 1 always', () {
      final model = _baseModel(usageCount: 3);
      final boost = model.getBoost(10);
      expect(boost, greaterThanOrEqualTo(0.0));
      expect(boost, lessThanOrEqualTo(1.0));
    });

    test('100% usage returns 1.0', () {
      final model = _baseModel(usageCount: 100);
      expect(model.getBoost(100), closeTo(1.0, 0.001));
    });

    test('1 usage out of 100 returns 0.01', () {
      final model = _baseModel(usageCount: 1);
      expect(model.getBoost(100), closeTo(0.01, 0.001));
    });

    test('boost is proportional to usage fraction', () {
      final low = _baseModel(usageCount: 1).getBoost(10);
      final high = _baseModel(usageCount: 8).getBoost(10);
      expect(high, greaterThan(low));
    });
  });

  // ================================================================
  // copyWith method
  // ================================================================
  group('ExerciseUsageModel.copyWith', () {
    test('can change exerciseId', () {
      final model = _baseModel();
      final copy = model.copyWith(exerciseId: 'new_id');
      expect(copy.exerciseId, 'new_id');
      expect(model.exerciseId, 'squat'); // original unchanged
    });

    test('can change exerciseName', () {
      final model = _baseModel();
      final copy = model.copyWith(exerciseName: 'New Name');
      expect(copy.exerciseName, 'New Name');
    });

    test('can change usageCount', () {
      final model = _baseModel(usageCount: 5);
      final copy = model.copyWith(usageCount: 20);
      expect(copy.usageCount, 20);
      expect(model.usageCount, 5);
    });

    test('can change userId', () {
      final model = _baseModel();
      final copy = model.copyWith(userId: 'new_user');
      expect(copy.userId, 'new_user');
    });

    test('can change lastUsedAt', () {
      final model = _baseModel();
      final newDate = DateTime(2025, 1, 1);
      final copy = model.copyWith(lastUsedAt: newDate);
      expect(copy.lastUsedAt, newDate);
    });

    test('copyWith no args preserves all fields', () {
      final model = _baseModel(usageCount: 7, userId: 'user-abc');
      final copy = model.copyWith();
      expect(copy.exerciseId, model.exerciseId);
      expect(copy.exerciseName, model.exerciseName);
      expect(copy.usageCount, model.usageCount);
      expect(copy.userId, model.userId);
    });

    test('original is not mutated', () {
      final model = _baseModel(usageCount: 5);
      // ignore: unused_result
      final _ = model.copyWith(usageCount: 99);
      expect(model.usageCount, 5);
    });
  });

  // ================================================================
  // toString method
  // ================================================================
  group('ExerciseUsageModel.toString', () {
    test('contains exerciseId', () {
      final model = _baseModel(exerciseId: 'squat_barbell');
      expect(model.toString(), contains('squat_barbell'));
    });

    test('contains exerciseName', () {
      final model = _baseModel(exerciseName: 'Squat con Bilanciere');
      expect(model.toString(), contains('Squat con Bilanciere'));
    });

    test('contains usageCount', () {
      final model = _baseModel(usageCount: 42);
      expect(model.toString(), contains('42'));
    });

    test('contains userId', () {
      final model = _baseModel(userId: 'user-xyz');
      expect(model.toString(), contains('user-xyz'));
    });
  });

  // ================================================================
  // ExerciseUsageModel - business logic edge cases
  // ================================================================
  group('ExerciseUsageModel - edge cases', () {
    test('boost with maxCount=1 and usageCount=1 returns 1.0', () {
      final model = _baseModel(usageCount: 1);
      expect(model.getBoost(1), closeTo(1.0, 0.001));
    });

    test('boost with very large usageCount is clamped to 1.0', () {
      final model = _baseModel(usageCount: 1000);
      expect(model.getBoost(1000), lessThanOrEqualTo(1.0));
    });

    test('multiple models with different usageCounts rank in order', () {
      final low = _baseModel(usageCount: 1).getBoost(100);
      final mid = _baseModel(usageCount: 50).getBoost(100);
      final high = _baseModel(usageCount: 100).getBoost(100);
      expect(low < mid, isTrue);
      expect(mid < high, isTrue);
    });
  });
}
