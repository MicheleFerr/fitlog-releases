import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_preview.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MergePreview _makePreview({
  String sourceExerciseName = 'Panca Piana Custom',
  String targetExerciseName = 'Bench Press',
  String targetExerciseId = 'bp_001',
  int sessionsToMerge = 10,
  int templatesAffected = 2,
  double? currentPR = 100.0,
  double? newPR = 120.0,
  List<String> targetMuscleGroups = const ['CHEST'],
  List<String> targetSecondaryMuscles = const ['TRICEP', 'SHOULDER'],
}) {
  return MergePreview(
    sourceExerciseName: sourceExerciseName,
    targetExerciseName: targetExerciseName,
    targetExerciseId: targetExerciseId,
    sessionsToMerge: sessionsToMerge,
    templatesAffected: templatesAffected,
    currentPR: currentPR,
    newPR: newPR,
    targetMuscleGroups: targetMuscleGroups,
    targetSecondaryMuscles: targetSecondaryMuscles,
  );
}

// ---------------------------------------------------------------------------
// Tests: MergePreview
// ---------------------------------------------------------------------------

void main() {
  group('MergePreview — constructor', () {
    test('stores all required fields correctly', () {
      final preview = _makePreview(
        sourceExerciseName: 'My Custom Squat',
        targetExerciseName: 'Squat',
        targetExerciseId: 'squat_001',
        sessionsToMerge: 20,
        templatesAffected: 3,
        currentPR: 140.0,
        newPR: 150.0,
        targetMuscleGroups: ['QUAD', 'GLUT'],
        targetSecondaryMuscles: ['HAMSTRING', 'CORE'],
      );

      expect(preview.sourceExerciseName, 'My Custom Squat');
      expect(preview.targetExerciseName, 'Squat');
      expect(preview.targetExerciseId, 'squat_001');
      expect(preview.sessionsToMerge, 20);
      expect(preview.templatesAffected, 3);
      expect(preview.currentPR, 140.0);
      expect(preview.newPR, 150.0);
      expect(preview.targetMuscleGroups, ['QUAD', 'GLUT']);
      expect(preview.targetSecondaryMuscles, ['HAMSTRING', 'CORE']);
    });

    test('currentPR and newPR can both be null', () {
      final preview = _makePreview(currentPR: null, newPR: null);
      expect(preview.currentPR, isNull);
      expect(preview.newPR, isNull);
    });
  });

  group('MergePreview.prWillChange', () {
    test('returns true when currentPR and newPR are both non-null and different', () {
      final preview = _makePreview(currentPR: 100.0, newPR: 120.0);
      expect(preview.prWillChange, isTrue);
    });

    test('returns false when currentPR == newPR', () {
      final preview = _makePreview(currentPR: 100.0, newPR: 100.0);
      expect(preview.prWillChange, isFalse);
    });

    test('returns false when currentPR is null', () {
      final preview = _makePreview(currentPR: null, newPR: 120.0);
      expect(preview.prWillChange, isFalse);
    });

    test('returns false when newPR is null', () {
      final preview = _makePreview(currentPR: 100.0, newPR: null);
      expect(preview.prWillChange, isFalse);
    });

    test('returns false when both PRs are null', () {
      final preview = _makePreview(currentPR: null, newPR: null);
      expect(preview.prWillChange, isFalse);
    });
  });

  group('MergePreview.prWillIncrease', () {
    test('returns true when newPR > currentPR', () {
      final preview = _makePreview(currentPR: 100.0, newPR: 120.0);
      expect(preview.prWillIncrease, isTrue);
    });

    test('returns false when newPR < currentPR (PR decreases)', () {
      final preview = _makePreview(currentPR: 120.0, newPR: 100.0);
      expect(preview.prWillIncrease, isFalse);
    });

    test('returns false when newPR == currentPR (no change)', () {
      final preview = _makePreview(currentPR: 100.0, newPR: 100.0);
      expect(preview.prWillIncrease, isFalse);
    });

    test('returns false when currentPR is null', () {
      final preview = _makePreview(currentPR: null, newPR: 120.0);
      expect(preview.prWillIncrease, isFalse);
    });

    test('returns false when newPR is null', () {
      final preview = _makePreview(currentPR: 100.0, newPR: null);
      expect(preview.prWillIncrease, isFalse);
    });
  });

  group('MergePreview — sessions and templates counts', () {
    test('can have zero sessions and templates', () {
      final preview = _makePreview(sessionsToMerge: 0, templatesAffected: 0);
      expect(preview.sessionsToMerge, 0);
      expect(preview.templatesAffected, 0);
    });

    test('can have large counts', () {
      final preview = _makePreview(
          sessionsToMerge: 500, templatesAffected: 100);
      expect(preview.sessionsToMerge, 500);
      expect(preview.templatesAffected, 100);
    });
  });

  // -------------------------------------------------------------------------
  // Tests: MergeResult
  // -------------------------------------------------------------------------

  group('MergeResult.success factory', () {
    test('creates a successful result with correct counts', () {
      final result = MergeResult.success(
        sessionsUpdated: 15,
        templatesUpdated: 3,
      );

      expect(result.success, isTrue);
      expect(result.sessionsUpdated, 15);
      expect(result.templatesUpdated, 3);
      expect(result.errorMessage, isNull);
    });

    test('zero counts are valid for success', () {
      final result = MergeResult.success(
        sessionsUpdated: 0,
        templatesUpdated: 0,
      );

      expect(result.success, isTrue);
      expect(result.sessionsUpdated, 0);
      expect(result.templatesUpdated, 0);
    });
  });

  group('MergeResult.failure factory', () {
    test('creates a failed result with error message', () {
      final result = MergeResult.failure('Network error');

      expect(result.success, isFalse);
      expect(result.sessionsUpdated, 0);
      expect(result.templatesUpdated, 0);
      expect(result.errorMessage, 'Network error');
    });

    test('error message is preserved exactly', () {
      const message = 'Firebase permission denied';
      final result = MergeResult.failure(message);
      expect(result.errorMessage, message);
    });
  });

  group('MergeResult — direct constructor', () {
    test('allows full control over all fields', () {
      const result = MergeResult(
        success: true,
        sessionsUpdated: 7,
        templatesUpdated: 2,
        errorMessage: null,
      );

      expect(result.success, isTrue);
      expect(result.sessionsUpdated, 7);
      expect(result.templatesUpdated, 2);
      expect(result.errorMessage, isNull);
    });

    test('can represent partial failure with error message and non-zero counts', () {
      const result = MergeResult(
        success: false,
        sessionsUpdated: 3,
        templatesUpdated: 0,
        errorMessage: 'Partial failure',
      );

      expect(result.success, isFalse);
      expect(result.sessionsUpdated, 3);
      expect(result.errorMessage, 'Partial failure');
    });
  });
}
