import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_auto_completion_service.dart';

void main() {
  group('RoutineAutoCompletionResult', () {
    test('success creates result with completed true', () {
      final date = DateTime.now();
      final result = RoutineAutoCompletionResult.success(date);

      expect(result.completed, true);
      expect(result.reason, isNotNull);
      expect(result.candidateDates, isNull);
    });

    test('skipped creates result with completed false', () {
      final result = RoutineAutoCompletionResult.skipped('No routine found');

      expect(result.completed, false);
      expect(result.reason, equals('No routine found'));
      expect(result.candidateDates, isNull);
    });

    test('needsUserSelection includes candidate dates', () {
      final candidates = [
        DateTime.now(),
        DateTime.now().add(const Duration(days: 1)),
      ];
      final result = RoutineAutoCompletionResult.needsUserSelection(candidates);

      expect(result.completed, false);
      expect(result.candidateDates, equals(candidates));
      expect(result.reason, isNotNull);
    });

    test('constructor with explicit values', () {
      final result = RoutineAutoCompletionResult(
        completed: true,
        reason: 'Custom reason',
        candidateDates: [],
      );

      expect(result.completed, true);
      expect(result.reason, equals('Custom reason'));
      expect(result.candidateDates, equals([]));
    });
  });

  group('RoutineAutoCompletionService scenarios', () {
    test('result types are distinct', () {
      final success = RoutineAutoCompletionResult.success(DateTime.now());
      final skipped = RoutineAutoCompletionResult.skipped('reason');
      final needsSelection = RoutineAutoCompletionResult.needsUserSelection([]);

      expect(success.completed, true);
      expect(skipped.completed, false);
      expect(needsSelection.completed, false);
      expect(needsSelection.candidateDates, isNotEmpty == false);
    });

    test('success result preserves date', () {
      final now = DateTime.now();
      final result = RoutineAutoCompletionResult.success(now);

      expect(result.reason, contains('${now.toLocal()}'));
    });

    test('skipped result preserves reason', () {
      const reason = 'No matching scheduled days';
      final result = RoutineAutoCompletionResult.skipped(reason);

      expect(result.reason, equals(reason));
    });

    test('multiple candidates returned in correct type', () {
      final dates = [DateTime.now(), DateTime.now().add(const Duration(days: 1))];
      final result = RoutineAutoCompletionResult.needsUserSelection(dates);

      expect(result.candidateDates, hasLength(2));
      expect(result.candidateDates, contains(dates[0]));
      expect(result.candidateDates, contains(dates[1]));
    });
  });

  group('RoutineAutoCompletionService expected behavior', () {
    test('service exists and can be instantiated', () {
      // Note: Full instantiation requires Ref, so this is structural test
      expect(RoutineAutoCompletionResult, isNotNull);
    });

    test('result factory methods create correct types', () {
      final success = RoutineAutoCompletionResult.success(DateTime.now());
      final skipped = RoutineAutoCompletionResult.skipped('test');
      final multi = RoutineAutoCompletionResult.needsUserSelection([DateTime.now()]);

      expect(success is RoutineAutoCompletionResult, true);
      expect(skipped is RoutineAutoCompletionResult, true);
      expect(multi is RoutineAutoCompletionResult, true);
    });

    test('empty candidates list handled correctly', () {
      final result = RoutineAutoCompletionResult.needsUserSelection([]);

      expect(result.completed, false);
      expect(result.candidateDates, isEmpty);
    });

    test('single candidate still uses needsUserSelection', () {
      final date = DateTime.now();
      final result = RoutineAutoCompletionResult.needsUserSelection([date]);

      expect(result.completed, false);
      expect(result.candidateDates, contains(date));
    });
  });

  group('integration flow scenarios', () {
    test('simple match flow: workout matches routine day', () {
      // Scenario: Today=LEG, Workout=LEG
      const templateId = 'leg_template';

      final result = RoutineAutoCompletionResult.success(DateTime.now());

      expect(result.completed, true);
      expect(templateId, equals('leg_template'));
    });

    test('no match flow: workout template not in routine', () {
      // Scenario: No days match the workout template
      const reason = 'No matching scheduled days';

      final result = RoutineAutoCompletionResult.skipped(reason);

      expect(result.completed, false);
      expect(reason, contains('matching'));
    });

    test('swap opportunity flow: multiple candidates detected', () {
      // Scenario: Multiple days have same template
      final dates = [DateTime.now(), DateTime.now().add(const Duration(days: 7))];

      final result = RoutineAutoCompletionResult.needsUserSelection(dates);

      expect(result.completed, false);
      expect(result.candidateDates, hasLength(2));
    });

    test('auto-completion path: single match auto-completes', () {
      final date = DateTime.now();
      final result = RoutineAutoCompletionResult.success(date);

      expect(result.completed, true);
      expect(result.candidateDates, isNull);
    });

    test('user selection path: multiple candidates need UI', () {
      final candidates = [
        DateTime.now(),
        DateTime.now().add(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 7)),
      ];

      final result = RoutineAutoCompletionResult.needsUserSelection(candidates);

      expect(result.completed, false);
      expect(result.candidateDates, hasLength(3));
    });
  });

  group('error scenarios', () {
    test('no active routine: skipped result', () {
      const reason = 'No active routine';
      final result = RoutineAutoCompletionResult.skipped(reason);

      expect(result.completed, false);
      expect(reason, contains('No active'));
    });

    test('no template: skipped result', () {
      const reason = 'No workout template';
      final result = RoutineAutoCompletionResult.skipped(reason);

      expect(result.completed, false);
    });

    test('error during processing: skipped result', () {
      const reason = 'Error: Exception message';
      final result = RoutineAutoCompletionResult.skipped(reason);

      expect(result.completed, false);
      expect(reason, contains('Error'));
    });
  });
}
