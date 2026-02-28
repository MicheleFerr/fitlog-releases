import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/exercise_preferences_model.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/exercise_preferences_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/favorite_exercises_notifier.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_providers_shared.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/i_exercise_preferences.dart';

// --------------------------------------------------------------------------
// Mock Firebase User
// --------------------------------------------------------------------------

class MockUser extends Mock implements User {}

// --------------------------------------------------------------------------
// Fake in-memory repository implementing IExercisePreferencesRepository
// --------------------------------------------------------------------------

class _FakePreferencesRepo implements IExercisePreferencesRepository {
  Set<String> _favorites = {};
  final List<Set<String>> writtenFavorites = [];

  void seed(Set<String> favorites) {
    _favorites = Set.from(favorites);
  }

  @override
  Future<Set<String>> getFavorites() async => Set.from(_favorites);

  @override
  Future<void> setFavorites(Set<String> favorites) async {
    _favorites = Set.from(favorites);
    writtenFavorites.add(Set.from(favorites));
  }

  @override
  Future<void> toggleFavorite(String exerciseName) async {
    if (_favorites.contains(exerciseName)) {
      _favorites.remove(exerciseName);
    } else {
      _favorites.add(exerciseName);
    }
  }

  @override
  Future<String?> getCountingModeOverride(String exerciseId) async => null;

  @override
  Future<void> setCountingModeOverride(
    String exerciseId,
    String countingMode,
  ) async {}

  @override
  Future<void> removeCountingModeOverride(String exerciseId) async {}

  @override
  Future<Map<String, String>> getAllCountingModeOverrides() async => {};

  @override
  void dispose() {}
}

/// Wraps the fake interface repo as an [ExercisePreferencesRepository] override.
/// We never call any Firebase methods; all paths use the in-memory fake.
class _FakeConcreteRepo extends _FakePreferencesRepo
    implements ExercisePreferencesRepository {
  ExercisePreferencesModel? _model;

  @override
  void seed(Set<String> favorites) {
    super.seed(favorites);
    _model = ExercisePreferencesModel(
      favorites: favorites.toList(),
      lastUpdated: DateTime.now(),
    );
  }

  // Called by FavoriteExercisesNotifier._loadInitialState()
  Future<ExercisePreferencesModel?> getPreferences() async => _model;

  // Called by favoriteExercisesStreamProvider
  Stream<ExercisePreferencesModel?> watchPreferences() =>
      Stream.value(_model);
}

// --------------------------------------------------------------------------
// Container builder
// --------------------------------------------------------------------------

ProviderContainer buildContainer({
  _FakeConcreteRepo? fakeRepo,
  bool isAuthenticated = true,
}) {
  final repo = fakeRepo ?? _FakeConcreteRepo();

  // Build a MockUser that Riverpod will return from firebaseUserProvider
  final mockUser = MockUser();
  when(() => mockUser.uid).thenReturn('test_user');

  return ProviderContainer(
    overrides: [
      // Supply a typed User? stream
      firebaseUserProvider.overrideWith(
        (ref) => isAuthenticated
            ? Stream<User?>.value(mockUser)
            : Stream<User?>.value(null),
      ),

      // Provide the fake repo (non-null signals "logged in" to the notifier)
      exercisePreferencesRepositoryProvider.overrideWith((ref) => repo),

      // Stream provider returns empty to avoid Firebase access
      favoriteExercisesStreamProvider.overrideWith(
        (ref) => Stream<ExercisePreferencesModel?>.value(null),
      ),
    ],
  );
}

// --------------------------------------------------------------------------
// Tests
// --------------------------------------------------------------------------

void main() {
  group('FavoriteExercisesNotifier - initial state', () {
    test('starts with empty set when no favorites have been seeded', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final state = container.read(favoriteExercisesNotifierProvider);
      expect(state, isEmpty);
    });
  });

  group('FavoriteExercisesNotifier - toggleFavorite', () {
    test('adds exercise when not already favorited', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      container
          .read(favoriteExercisesNotifierProvider.notifier)
          .toggleFavorite('Bench Press');

      expect(
        container.read(favoriteExercisesNotifierProvider),
        contains('Bench Press'),
      );
    });

    test('removes exercise when already favorited', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);

      notifier.toggleFavorite('Squat');
      expect(
          container.read(favoriteExercisesNotifierProvider), contains('Squat'));

      notifier.toggleFavorite('Squat');
      expect(
        container.read(favoriteExercisesNotifierProvider),
        isNot(contains('Squat')),
      );
    });

    test('toggling multiple exercises adds each independently', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);

      notifier.toggleFavorite('Bench Press');
      notifier.toggleFavorite('Squat');
      notifier.toggleFavorite('Deadlift');

      final state = container.read(favoriteExercisesNotifierProvider);
      expect(state, containsAll(['Bench Press', 'Squat', 'Deadlift']));
      expect(state.length, equals(3));
    });
  });

  group('FavoriteExercisesNotifier - isFavorite', () {
    test('returns true for a favorited exercise', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.toggleFavorite('Pull Up');

      expect(notifier.isFavorite('Pull Up'), isTrue);
    });

    test('returns false for a non-favorited exercise', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);

      expect(notifier.isFavorite('Overhead Press'), isFalse);
    });

    test('correctly reflects state after add-then-remove sequence', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);

      notifier.toggleFavorite('Row');
      expect(notifier.isFavorite('Row'), isTrue);

      notifier.toggleFavorite('Row');
      expect(notifier.isFavorite('Row'), isFalse);
    });
  });

  group('FavoriteExercisesNotifier - addFavorites', () {
    test('adds multiple exercises at once', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.addFavorites({'Row', 'Curl', 'Dip'});

      final state = container.read(favoriteExercisesNotifierProvider);
      expect(state, containsAll(['Row', 'Curl', 'Dip']));
    });

    test('merges with existing favorites (no duplicates, Set semantics)', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.toggleFavorite('Bench Press');
      notifier.addFavorites({'Bench Press', 'Squat'}); // Bench Press already in

      final state = container.read(favoriteExercisesNotifierProvider);
      expect(state, containsAll(['Bench Press', 'Squat']));
      expect(state.where((e) => e == 'Bench Press').length, equals(1));
    });
  });

  group('FavoriteExercisesNotifier - removeFavorites', () {
    test('removes the specified exercises', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.addFavorites({'A', 'B', 'C'});
      notifier.removeFavorites({'A', 'C'});

      final state = container.read(favoriteExercisesNotifierProvider);
      expect(state, isNot(contains('A')));
      expect(state, isNot(contains('C')));
      expect(state, contains('B'));
    });

    test('is safe when removing exercise not in favorites', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.addFavorites({'Squat'});
      notifier.removeFavorites({'NonExistent'}); // Should not throw

      expect(
        container.read(favoriteExercisesNotifierProvider),
        contains('Squat'),
      );
    });
  });

  group('FavoriteExercisesNotifier - clearAll', () {
    test('removes all favorites', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.addFavorites({'Bench Press', 'Squat', 'Deadlift'});
      notifier.clearAll();

      expect(container.read(favoriteExercisesNotifierProvider), isEmpty);
    });

    test('is safe when called on already empty state', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.clearAll(); // Should not throw

      expect(container.read(favoriteExercisesNotifierProvider), isEmpty);
    });
  });

  group('FavoriteExercisesNotifier - updateFromFirestore', () {
    test('replaces current state with new Firestore data', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.addFavorites({'OldFavorite'});
      notifier.updateFromFirestore({'NewFavorite1', 'NewFavorite2'});

      final state = container.read(favoriteExercisesNotifierProvider);
      expect(state, containsAll(['NewFavorite1', 'NewFavorite2']));
      expect(state, isNot(contains('OldFavorite')));
    });

    test('does not change state when called with identical data', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(favoriteExercisesNotifierProvider.notifier);
      notifier.updateFromFirestore({'Bench Press'});

      final stateBefore = container.read(favoriteExercisesNotifierProvider);
      notifier.updateFromFirestore({'Bench Press'}); // Same content
      final stateAfter = container.read(favoriteExercisesNotifierProvider);

      expect(stateAfter, equals(stateBefore));
    });
  });

  group('FavoriteExercisesNotifier - unauthenticated', () {
    test('returns empty set when user is not authenticated', () {
      final container = buildContainer(isAuthenticated: false);
      addTearDown(container.dispose);

      final state = container.read(favoriteExercisesNotifierProvider);
      expect(state, isEmpty);
    });
  });
}
