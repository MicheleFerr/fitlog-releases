import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/user_exercise_preferences_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/user_exercise_preferences.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

// Mocks
class MockHiveBoxManagerEnhanced extends Mock
    implements HiveBoxManagerEnhanced {}

class MockLazyBox extends Mock implements LazyBox<UserExercisePreferences> {}

class FakeUserExercisePreferences extends Fake
    implements UserExercisePreferences {}

void main() {
  late UserExercisePreferencesRepository repository;
  late MockHiveBoxManagerEnhanced mockBoxManager;
  late MockLazyBox mockBox;

  setUpAll(() {
    registerFallbackValue(FakeUserExercisePreferences());
  });

  setUp(() {
    mockBoxManager = MockHiveBoxManagerEnhanced();
    mockBox = MockLazyBox();

    when(() => mockBoxManager
            .openLazyBox<UserExercisePreferences>('user_exercise_preferences'))
        .thenAnswer((_) async => mockBox);

    when(() => mockBox.isOpen).thenReturn(true);
    when(() => mockBox.keys).thenReturn([]);
    when(() => mockBox.get(any())).thenAnswer((_) async => null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockBox.delete(any())).thenAnswer((_) async {});
    when(() => mockBox.flush()).thenAnswer((_) async {});
    when(() => mockBox.clear()).thenAnswer((_) async => 0);
    when(() => mockBox.close()).thenAnswer((_) async {});

    repository = UserExercisePreferencesRepository(mockBoxManager);
  });

  group('UserExercisePreferencesRepository', () {
    group('init', () {
      test('opens lazy box on first init', () async {
        await repository.init();

        verify(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
            'user_exercise_preferences')).called(1);
      });

      test('handles BoxCorruptedException with retry', () async {
        var firstCall = true;
        when(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
            'user_exercise_preferences')).thenAnswer((_) async {
          if (firstCall) {
            firstCall = false;
            throw BoxCorruptedException('user_exercise_preferences', 'corrupted');
          }
          return mockBox;
        });

        // Should not throw - retries after corruption
        await repository.init();
      });

      test('sets initFailed flag on BoxOpenException', () async {
        when(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
                'user_exercise_preferences'))
            .thenThrow(BoxOpenException('user_exercise_preferences', 'failed'));

        await repository.init();

        // Subsequent calls should return null/false/empty
        final result = await repository.getFormCues('ex-1', 'Test');
        expect(result, isNull);
      });

      test('skips init after previous failure', () async {
        when(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
                'user_exercise_preferences'))
            .thenThrow(Exception('unexpected'));

        await repository.init();
        await repository.init(); // second call should be skipped

        // Only one attempt because _initFailed is true
        verify(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
            'user_exercise_preferences')).called(1);
      });
    });

    group('getFormCues', () {
      test('returns form cues for existing exercise', () async {
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          formCues: 'Keep elbows tucked',
          updatedAt: DateTime.now(),
        );
        // The key lookup uses _userKey which depends on UserCacheKeyManager
        // which uses FirebaseAuth. In the code it calls
        // userCacheKeys.userScopedKey('exercise_prefs_$exerciseKey')
        // Since userCacheKeys uses FirebaseAuth and currentUserId may be null,
        // it falls back to 'exercise_prefs_ex-1_null'
        when(() => mockBox.get(any())).thenAnswer((_) async => prefs);

        final result = await repository.getFormCues('ex-1', 'Bench Press');

        expect(result, 'Keep elbows tucked');
      });

      test('returns null when no preferences exist', () async {
        when(() => mockBox.get(any())).thenAnswer((_) async => null);

        final result = await repository.getFormCues('ex-1', 'Test');

        expect(result, isNull);
      });

      test('returns null when init failed', () async {
        when(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
                'user_exercise_preferences'))
            .thenThrow(Exception('init failed'));

        final result = await repository.getFormCues('ex-1', 'Test');

        expect(result, isNull);
      });
    });

    group('saveFormCues', () {
      test('saves new form cues', () async {
        when(() => mockBox.get(any())).thenAnswer((_) async => null);

        await repository.saveFormCues('ex-1', 'Bench Press', 'Keep tight');

        verify(() => mockBox.put(any(), any())).called(1);
        verify(() => mockBox.flush()).called(1);
      });

      test('updates existing form cues', () async {
        final existing = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          formCues: 'Old cues',
          updatedAt: DateTime(2024, 1, 1),
        );
        when(() => mockBox.get(any())).thenAnswer((_) async => existing);

        await repository.saveFormCues('ex-1', 'Bench Press', 'New cues');

        verify(() => mockBox.put(any(), any())).called(1);
        verify(() => mockBox.flush()).called(1);
      });

      test('deletes entry when formCues is null', () async {
        await repository.saveFormCues('ex-1', 'Bench Press', null);

        verify(() => mockBox.delete(any())).called(1);
        verifyNever(() => mockBox.put(any(), any()));
      });

      test('deletes entry when formCues is empty string', () async {
        await repository.saveFormCues('ex-1', 'Bench Press', '');

        verify(() => mockBox.delete(any())).called(1);
        verifyNever(() => mockBox.put(any(), any()));
      });

      test('deletes entry when formCues is whitespace only', () async {
        await repository.saveFormCues('ex-1', 'Bench Press', '   ');

        verify(() => mockBox.delete(any())).called(1);
        verifyNever(() => mockBox.put(any(), any()));
      });

      test('does nothing when init failed', () async {
        when(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
                'user_exercise_preferences'))
            .thenThrow(Exception('init failed'));

        await repository.saveFormCues('ex-1', 'Test', 'cues');

        verifyNever(() => mockBox.put(any(), any()));
      });
    });

    group('hasFormCues', () {
      test('returns true when form cues exist', () async {
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench',
          formCues: 'Keep tight',
          updatedAt: DateTime.now(),
        );
        when(() => mockBox.get(any())).thenAnswer((_) async => prefs);

        final result = await repository.hasFormCues('ex-1', 'Bench');

        expect(result, true);
      });

      test('returns false when form cues are null', () async {
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench',
          updatedAt: DateTime.now(),
        );
        when(() => mockBox.get(any())).thenAnswer((_) async => prefs);

        final result = await repository.hasFormCues('ex-1', 'Bench');

        expect(result, false);
      });

      test('returns false when form cues are empty', () async {
        final prefs = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench',
          formCues: '',
          updatedAt: DateTime.now(),
        );
        when(() => mockBox.get(any())).thenAnswer((_) async => prefs);

        final result = await repository.hasFormCues('ex-1', 'Bench');

        expect(result, false);
      });

      test('returns false when no preferences exist', () async {
        when(() => mockBox.get(any())).thenAnswer((_) async => null);

        final result = await repository.hasFormCues('ex-1', 'Bench');

        expect(result, false);
      });

      test('returns false when init failed', () async {
        when(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
                'user_exercise_preferences'))
            .thenThrow(Exception('init failed'));

        final result = await repository.hasFormCues('ex-1', 'Test');

        expect(result, false);
      });
    });

    group('getAllWithFormCues', () {
      test('returns only preferences with non-empty form cues', () async {
        final pref1 = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench Press',
          formCues: 'Cue 1',
          updatedAt: DateTime.now(),
        );
        final pref2 = UserExercisePreferences(
          visibleId: 'ex-2',
          exerciseName: 'Squat',
          formCues: null,
          updatedAt: DateTime.now(),
        );
        final pref3 = UserExercisePreferences(
          visibleId: 'ex-3',
          exerciseName: 'Deadlift',
          formCues: 'Cue 3',
          updatedAt: DateTime.now(),
        );

        when(() => mockBox.keys).thenReturn(['key1', 'key2', 'key3']);
        var callCount = 0;
        when(() => mockBox.get(any())).thenAnswer((_) async {
          callCount++;
          switch (callCount) {
            case 1:
              return pref1;
            case 2:
              return pref2;
            case 3:
              return pref3;
            default:
              return null;
          }
        });

        final results = await repository.getAllWithFormCues();

        expect(results.length, 2);
        expect(results[0].exerciseName, 'Bench Press');
        expect(results[1].exerciseName, 'Deadlift');
      });

      test('returns empty list when no form cues exist', () async {
        when(() => mockBox.keys).thenReturn([]);

        final results = await repository.getAllWithFormCues();

        expect(results, isEmpty);
      });

      test('returns empty list when init failed', () async {
        when(() => mockBoxManager.openLazyBox<UserExercisePreferences>(
                'user_exercise_preferences'))
            .thenThrow(Exception('init failed'));

        final results = await repository.getAllWithFormCues();

        expect(results, isEmpty);
      });
    });

    group('getPendingSyncPreferences', () {
      test('returns only preferences with needsSync flag', () async {
        final pref1 = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench',
          updatedAt: DateTime.now(),
          needsSync: true,
        );
        final pref2 = UserExercisePreferences(
          visibleId: 'ex-2',
          exerciseName: 'Squat',
          updatedAt: DateTime.now(),
          needsSync: false,
        );

        when(() => mockBox.keys).thenReturn(['key1', 'key2']);
        var callCount = 0;
        when(() => mockBox.get(any())).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? pref1 : pref2;
        });

        final results = await repository.getPendingSyncPreferences();

        expect(results.length, 1);
        expect(results[0].exerciseName, 'Bench');
      });
    });

    group('markAsSynced', () {
      test('clears needsSync flag on existing preference', () async {
        final pref = UserExercisePreferences(
          visibleId: 'ex-1',
          exerciseName: 'Bench',
          updatedAt: DateTime.now(),
          needsSync: true,
        );
        when(() => mockBox.get(any())).thenAnswer((_) async => pref);

        await repository.markAsSynced('ex-1', 'Bench');

        verify(() => mockBox.put(any(), any())).called(1);
        verify(() => mockBox.flush()).called(1);
      });

      test('does nothing when preference does not exist', () async {
        when(() => mockBox.get(any())).thenAnswer((_) async => null);

        await repository.markAsSynced('ex-1', 'Bench');

        verifyNever(() => mockBox.put(any(), any()));
      });
    });

    group('clearAll', () {
      test('clears all preferences', () async {
        await repository.clearAll();

        verify(() => mockBox.clear()).called(1);
      });
    });

    group('dispose', () {
      test('closes the lazy box', () async {
        await repository.init();
        await repository.dispose();

        verify(() => mockBox.close()).called(1);
      });

      test('handles already closed box', () async {
        when(() => mockBox.isOpen).thenReturn(false);

        await repository.init();
        await repository.dispose();

        verifyNever(() => mockBox.close());
      });
    });
  });
}
