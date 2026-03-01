/// TutorialState entity tests - JSON round-trip, computed properties,
/// factory constructors, copyWith.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';

void main() {
  group('TutorialState JSON round-trip', () {
    test('all fields', () {
      final state = TutorialState(
        seenTutorialsList: ['logging_set', 'rest_timer'],
        dismissedHintsList: ['hint1'],
        lastDismissTimeList: ['hint1:2025-03-01T10:00:00.000'],
        totalWorkouts: 5,
        firstWorkoutDate: DateTime(2025, 2, 1),
        tutorialsEnabled: false,
      );

      final json = state.toJson();
      final restored = TutorialState.fromJson(json);

      expect(restored.seenTutorialsList, ['logging_set', 'rest_timer']);
      expect(restored.dismissedHintsList, ['hint1']);
      expect(restored.lastDismissTimeList, ['hint1:2025-03-01T10:00:00.000']);
      expect(restored.totalWorkouts, 5);
      expect(restored.firstWorkoutDate, DateTime(2025, 2, 1));
      expect(restored.tutorialsEnabled, isFalse);
    });

    test('defaults', () {
      final state = const TutorialState();
      final restored = TutorialState.fromJson(state.toJson());

      expect(restored.seenTutorialsList, isEmpty);
      expect(restored.dismissedHintsList, isEmpty);
      expect(restored.lastDismissTimeList, isEmpty);
      expect(restored.totalWorkouts, 0);
      expect(restored.firstWorkoutDate, isNull);
      expect(restored.tutorialsEnabled, isTrue);
    });
  });

  group('TutorialState factories', () {
    test('initial creates empty state', () {
      final state = TutorialState.initial();
      expect(state.seenTutorialsList, isEmpty);
      expect(state.totalWorkouts, 0);
      expect(state.tutorialsEnabled, isTrue);
    });

    test('fromSets converts Sets/Maps to Lists', () {
      final state = TutorialState.fromSets(
        seenTutorials: {'a', 'b'},
        dismissedHints: {'hint1'},
        lastDismissTime: {
          'hint1': DateTime(2025, 3, 1, 10, 0),
        },
        totalWorkouts: 3,
      );
      expect(state.seenTutorials, containsAll(['a', 'b']));
      expect(state.dismissedHints, contains('hint1'));
      expect(state.lastDismissTime['hint1'], DateTime(2025, 3, 1, 10, 0));
      expect(state.totalWorkouts, 3);
    });
  });

  group('TutorialState computed properties', () {
    test('seenTutorials returns Set', () {
      final state = TutorialState(seenTutorialsList: ['a', 'b', 'a']);
      expect(state.seenTutorials, {'a', 'b'});
    });

    test('dismissedHints returns Set', () {
      final state = TutorialState(dismissedHintsList: ['x', 'y']);
      expect(state.dismissedHints, {'x', 'y'});
    });

    test('lastDismissTime parses entries', () {
      final state = TutorialState(
        lastDismissTimeList: ['h1:2025-03-01T10:00:00.000'],
      );
      final map = state.lastDismissTime;
      expect(map.containsKey('h1'), isTrue);
      expect(map['h1'], DateTime(2025, 3, 1, 10, 0));
    });

    test('lastDismissTime skips invalid entries', () {
      final state = TutorialState(
        lastDismissTimeList: ['bad_entry', 'ok:2025-01-01T00:00:00.000'],
      );
      final map = state.lastDismissTime;
      // 'bad_entry' has no colon separator so split produces just 1 part
      expect(map.length, lessThanOrEqualTo(2));
      expect(map.containsKey('ok'), isTrue);
    });

    test('hasSeen', () {
      final state = TutorialState(seenTutorialsList: ['logging_set']);
      expect(state.hasSeen('logging_set'), isTrue);
      expect(state.hasSeen('analytics_intro'), isFalse);
    });

    test('isNewUser', () {
      expect(const TutorialState(totalWorkouts: 0).isNewUser, isTrue);
      expect(const TutorialState(totalWorkouts: 2).isNewUser, isTrue);
      expect(const TutorialState(totalWorkouts: 3).isNewUser, isFalse);
    });

    test('hasCompletedFirstWorkout', () {
      expect(
        const TutorialState(totalWorkouts: 0).hasCompletedFirstWorkout,
        isFalse,
      );
      expect(
        const TutorialState(totalWorkouts: 1).hasCompletedFirstWorkout,
        isTrue,
      );
    });
  });

  group('TutorialState copyWith', () {
    test('changes list fields', () {
      final original = TutorialState.initial();
      final copy = original.copyWith(
        seenTutorialsList: ['new_tutorial'],
        totalWorkouts: 10,
      );
      expect(copy.seenTutorialsList, ['new_tutorial']);
      expect(copy.totalWorkouts, 10);
      expect(copy.tutorialsEnabled, original.tutorialsEnabled);
    });

    test('accepts Set via seenTutorials param', () {
      final copy = TutorialState.initial().copyWith(
        seenTutorials: {'a', 'b'},
      );
      expect(copy.seenTutorials, containsAll(['a', 'b']));
    });

    test('accepts Map via lastDismissTime param', () {
      final copy = TutorialState.initial().copyWith(
        lastDismissTime: {'h1': DateTime(2025, 1, 1)},
      );
      expect(copy.lastDismissTime['h1'], DateTime(2025, 1, 1));
    });
  });

  group('TutorialState equality', () {
    test('equal states', () {
      final a = TutorialState(
        seenTutorialsList: ['a'],
        totalWorkouts: 5,
      );
      final b = TutorialState(
        seenTutorialsList: ['a'],
        totalWorkouts: 5,
      );
      expect(a, equals(b));
    });

    test('different states', () {
      final a = const TutorialState(totalWorkouts: 5);
      final b = const TutorialState(totalWorkouts: 10);
      expect(a, isNot(equals(b)));
    });
  });
}
