import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';

void main() {
  group('WorkoutFingerprint', () {
    group('matches', () {
      test('should match when template names are the same', () {
        const fp1 = WorkoutFingerprint(
          id: 'test1',
          templateName: 'Push Day',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.push,
          totalVolume: 5000.0,
        );

        const fp2 = WorkoutFingerprint(
          id: 'test2',
          templateName: 'Push Day',
          dominantMuscles: ['back', 'biceps'],
          category: WorkoutCategory.pull,
          totalVolume: 4000.0,
        );

        expect(fp1.matches(fp2), isTrue);
      });

      test('should not match when template names are empty', () {
        const fp1 = WorkoutFingerprint(
          id: 'test1',
          templateName: '',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.push,
          totalVolume: 5000.0,
        );

        const fp2 = WorkoutFingerprint(
          id: 'test2',
          templateName: '',
          dominantMuscles: ['back', 'biceps'],
          category: WorkoutCategory.pull,
          totalVolume: 4000.0,
        );

        // Empty names should not match by name
        expect(fp1.matches(fp2), isFalse);
      });

      test('should match when categories are the same (excluding other)', () {
        const fp1 = WorkoutFingerprint(
          id: 'test1',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.push,
          totalVolume: 5000.0,
        );

        const fp2 = WorkoutFingerprint(
          id: 'test2',
          dominantMuscles: ['chest', 'shoulders'],
          category: WorkoutCategory.push,
          totalVolume: 3000.0,
        );

        expect(fp1.matches(fp2), isTrue);
      });

      test('should not match when both categories are "other"', () {
        const fp1 = WorkoutFingerprint(
          id: 'test1',
          dominantMuscles: ['core'],
          category: WorkoutCategory.other,
          totalVolume: 1000.0,
        );

        const fp2 = WorkoutFingerprint(
          id: 'test2',
          dominantMuscles: ['forearms'],
          category: WorkoutCategory.other,
          totalVolume: 800.0,
        );

        // "other" category should not match even if both are "other"
        expect(fp1.matches(fp2), isFalse);
      });

      test('should match when 2 out of 3 dominant muscles overlap', () {
        const fp1 = WorkoutFingerprint(
          id: 'test1',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.other,
          totalVolume: 5000.0,
        );

        const fp2 = WorkoutFingerprint(
          id: 'test2',
          dominantMuscles: ['chest', 'shoulders', 'back'],
          category: WorkoutCategory.other,
          totalVolume: 4500.0,
        );

        // 2 overlapping muscles: chest, shoulders
        expect(fp1.matches(fp2), isTrue);
      });

      test('should not match when only 1 dominant muscle overlaps', () {
        const fp1 = WorkoutFingerprint(
          id: 'test1',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.other,
          totalVolume: 5000.0,
        );

        const fp2 = WorkoutFingerprint(
          id: 'test2',
          dominantMuscles: ['chest', 'back', 'biceps'],
          category: WorkoutCategory.other,
          totalVolume: 4500.0,
        );

        // Only 1 overlapping muscle: chest
        expect(fp1.matches(fp2), isFalse);
      });

      test('should not match when no muscles overlap', () {
        const fp1 = WorkoutFingerprint(
          id: 'test1',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.other,
          totalVolume: 5000.0,
        );

        const fp2 = WorkoutFingerprint(
          id: 'test2',
          dominantMuscles: ['quadriceps', 'hamstrings', 'glutes'],
          category: WorkoutCategory.other,
          totalVolume: 6000.0,
        );

        expect(fp1.matches(fp2), isFalse);
      });
    });

    group('displayName', () {
      test('should return templateName when available', () {
        const fp = WorkoutFingerprint(
          id: 'test1',
          templateName: 'Push Day',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.push,
          totalVolume: 5000.0,
        );

        expect(fp.displayName, equals('Push Day'));
      });

      test('should return category name when templateName is null', () {
        const fp = WorkoutFingerprint(
          id: 'test1',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.push,
          totalVolume: 5000.0,
        );

        expect(fp.displayName, equals('push'));
      });

      test('should return category name when templateName is empty', () {
        const fp = WorkoutFingerprint(
          id: 'test1',
          templateName: '',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.push,
          totalVolume: 5000.0,
        );

        expect(fp.displayName, equals('push'));
      });
    });

    group('WorkoutCategory', () {
      test('should have all expected values', () {
        expect(WorkoutCategory.values, contains(WorkoutCategory.push));
        expect(WorkoutCategory.values, contains(WorkoutCategory.pull));
        expect(WorkoutCategory.values, contains(WorkoutCategory.legs));
        expect(WorkoutCategory.values, contains(WorkoutCategory.upper));
        expect(WorkoutCategory.values, contains(WorkoutCategory.lower));
        expect(WorkoutCategory.values, contains(WorkoutCategory.fullBody));
        expect(WorkoutCategory.values, contains(WorkoutCategory.other));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON and back', () {
        final original = WorkoutFingerprint(
          id: 'test1',
          templateName: 'Push Day',
          templateId: 'template-123',
          dominantMuscles: ['chest', 'shoulders', 'triceps'],
          category: WorkoutCategory.push,
          totalVolume: 5000.0,
          workoutDate: DateTime(2024, 1, 15),
        );

        final json = original.toJson();
        final restored = WorkoutFingerprint.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.templateName, equals(original.templateName));
        expect(restored.templateId, equals(original.templateId));
        expect(restored.dominantMuscles, equals(original.dominantMuscles));
        expect(restored.category, equals(original.category));
        expect(restored.totalVolume, equals(original.totalVolume));
        expect(restored.workoutDate, equals(original.workoutDate));
      });
    });
  });
}
