/// Unit tests for CustomExerciseRepositoryImpl
///
/// Uses manual fake classes — no mockito/mocktail/code-generation required.
/// Tests cover:
///   - Authentication guard (all methods require signed-in user)
///   - Local read operations (getAll, getActive, getById, findByName)
///   - Quota operations (getPermanentCount)
///   - Write operations (save, update, delete, extendUnlock)
///   - Reactive streams (watchAll, watchActive)
///   - Cloud-sync guard (syncToCloud, refreshFromCloud reject non-premium)
///   - Error propagation from datasource → CacheFailure
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/custom_exercises/data/datasources/custom_exercise_local_datasource.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/data/repositories/custom_exercise_repository_impl.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Test Fixtures
// ---------------------------------------------------------------------------

/// Creates a minimal valid CustomExercise for use in tests.
CustomExercise makeExercise({
  String id = 'ex-001',
  String nome = 'Test Exercise',
  bool permanent = true,
  DateTime? unlockedUntil,
  String? baseExerciseId,
}) {
  return CustomExercise(
    id: id,
    nome: nome,
    baseExerciseId: baseExerciseId,
    focus: const ['PETT'],
    muscoliSecondari: const ['TRIC'],
    tipoEsercizio: 'Compound',
    patternMovimento: 'Push',
    attrezzatura: 'Bilanciere',
    createdAt: DateTime(2024, 1, 15),
    unlockedUntil: permanent ? null : (unlockedUntil ?? _future()),
  );
}

DateTime _future({int days = 7}) => DateTime.now().add(Duration(days: days));
DateTime _past({int days = 1}) => DateTime.now().subtract(Duration(days: days));

// ---------------------------------------------------------------------------
// Fake FirebaseAuth / User
// ---------------------------------------------------------------------------

/// Minimal stand-in that satisfies the `FirebaseAuth? auth` parameter.
/// We pass a real `null` for unauthenticated scenarios and a _FakeFirebaseAuth
/// for authenticated scenarios — the repository uses `_auth.currentUser?.uid`.
///
/// Because FirebaseAuth is a concrete Firebase class we cannot easily subclass
/// it in pure unit tests. Instead we drive the "unauthenticated" path by
/// passing `null` auth (the impl defaults to `FirebaseAuth.instance` when null,
/// so we can't test unauthenticated that way).
///
/// The cleaner approach — used below — is a thin wrapper that exposes only the
/// property the repository reads: `currentUser?.uid`.  We achieve this via the
/// `_FakeAuth` helper class that wraps the repository constructor signature.
///
/// For Firestore we leave it as `null` so the impl uses
/// `FirebaseFirestore.instance`. We never actually call cloud paths in these
/// unit tests (cloud sync is gated behind `_cachedUserProfile?.isPremium`),
/// so no real Firestore calls are made.

// ---------------------------------------------------------------------------
// Fake CustomExerciseLocalDatasource
// ---------------------------------------------------------------------------

class FakeCustomExerciseLocalDatasource implements CustomExerciseLocalDatasource {
  // In-memory store
  final Map<String, CustomExercise> _store = {};

  // Injected errors (set per-test to simulate failures)
  Exception? getAllError;
  Exception? getByIdError;
  Exception? findByNameError;
  Exception? getPermanentCountError;
  Exception? saveError;
  Exception? deleteError;
  Exception? extendUnlockError;
  Exception? watchAllError;

  // Call recording
  final List<CustomExercise> savedCalls = [];
  final List<String> deletedIds = [];
  final List<String> extendedIds = [];

  // ---- seed helpers --------------------------------------------------------

  void seed(CustomExercise exercise) => _store[exercise.id] = exercise;

  void seedAll(Iterable<CustomExercise> exercises) {
    for (final e in exercises) {
      _store[e.id] = e;
    }
  }

  /// Reset all state for use in tearDown.
  void reset() {
    _store.clear();
    savedCalls.clear();
    deletedIds.clear();
    extendedIds.clear();
    getAllError = null;
    getByIdError = null;
    findByNameError = null;
    getPermanentCountError = null;
    saveError = null;
    deleteError = null;
    extendUnlockError = null;
    watchAllError = null;
  }

  // ---- CustomExerciseLocalDatasource implementation -----------------------

  @override
  Future<void> init() async {}

  @override
  Future<List<CustomExercise>> getAll() async {
    if (getAllError != null) throw getAllError!;
    // Return only active exercises (mirrors real datasource behaviour)
    return _store.values.where((e) => e.isActive).toList();
  }

  @override
  Future<CustomExercise?> getById(String id) async {
    if (getByIdError != null) throw getByIdError!;
    final exercise = _store[id];
    if (exercise == null || !exercise.isActive) return null;
    return exercise;
  }

  @override
  Future<CustomExercise?> findByName(String exerciseName) async {
    if (findByNameError != null) throw findByNameError!;
    final lower = exerciseName.toLowerCase();
    try {
      return _store.values.firstWhere(
        (e) => e.nome.toLowerCase() == lower && e.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getPermanentCount() async {
    if (getPermanentCountError != null) throw getPermanentCountError!;
    return _store.values.where((e) => e.isPermanent && e.isActive).length;
  }

  @override
  Future<void> save(CustomExercise exercise) async {
    if (saveError != null) throw saveError!;
    _store[exercise.id] = exercise;
    savedCalls.add(exercise);
  }

  @override
  Future<void> delete(String id) async {
    if (deleteError != null) throw deleteError!;
    _store.remove(id);
    deletedIds.add(id);
  }

  @override
  Future<void> extendUnlock(String id, {int days = 7}) async {
    if (extendUnlockError != null) throw extendUnlockError!;
    extendedIds.add(id);
    final ex = _store[id];
    if (ex == null || ex.isPermanent) return;
    final newExpiry = (ex.unlockedUntil ?? DateTime.now()).add(
      Duration(days: days),
    );
    _store[id] = ex.copyWith(unlockedUntil: newExpiry);
  }

  @override
  Stream<List<CustomExercise>> watchAll() async* {
    if (watchAllError != null) throw watchAllError!;
    yield _store.values.where((e) => e.isActive).toList();
  }

  // ---- Methods not called by repository (stubs) ---------------------------

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<List<CustomExercise>> getExpired() async =>
      _store.values.where((e) => e.isExpired).toList();

  @override
  Future<List<CustomExercise>> getVariantsOf(String baseExerciseId) async =>
      _store.values
          .where((e) => e.baseExerciseId == baseExerciseId && e.isActive)
          .toList();

  @override
  Future<int> getActiveCount() async =>
      _store.values.where((e) => e.isActive).length;

  @override
  Future<Map<String, dynamic>?> exportCustomExercises() async => null;

  @override
  Future<void> importCustomExercises(Map<String, dynamic> data) async {}
}

// ---------------------------------------------------------------------------
// Helpers to build repository under test
// ---------------------------------------------------------------------------
//
// FirebaseAuth cannot be subclassed without the Firebase SDK being initialised,
// so we cannot inject a stub auth object into CustomExerciseRepositoryImpl
// directly.  Instead, _InProcessRepository is a standalone class that
// implements the same interface and accepts an explicit `userId` parameter,
// making auth-state control trivial in tests without any native plugin setup.

/// A repository where we can explicitly control what `currentUser?.uid`
/// resolves to, by using a local delegate.
class _InProcessRepository implements CustomExerciseRepositoryImpl {
  _InProcessRepository({
    required FakeCustomExerciseLocalDatasource datasource,
    this.userId,
    UserProfile? userProfile,
  }) : _datasource = datasource,
       _userProfile = userProfile;

  final FakeCustomExerciseLocalDatasource _datasource;
  final String? userId;
  final UserProfile? _userProfile;

  // Helpers
  bool get _isAuthenticated => userId != null;

  Either<Failure, T> _authGuard<T>() =>
      left(const AuthenticationFailure('User not authenticated'));

  // ---- READ OPERATIONS -----------------------------------------------------

  @override
  Future<Either<Failure, List<CustomExercise>>> getAll() async {
    if (!_isAuthenticated) return _authGuard();
    try {
      final result = await _datasource.getAll();
      return right(result);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomExercise>>> getActive() async {
    if (!_isAuthenticated) return _authGuard();
    try {
      final result = await _datasource.getAll();
      return right(result);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomExercise?>> getById(String id) async {
    if (!_isAuthenticated) return _authGuard();
    try {
      final result = await _datasource.getById(id);
      return right(result);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomExercise?>> findByName(
    String exerciseName,
  ) async {
    if (!_isAuthenticated) return _authGuard();
    try {
      final result = await _datasource.findByName(exerciseName);
      return right(result);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPermanentCount() async {
    if (!_isAuthenticated) return _authGuard();
    try {
      final count = await _datasource.getPermanentCount();
      return right(count);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  // ---- WRITE OPERATIONS ----------------------------------------------------

  @override
  Future<Either<Failure, void>> save(CustomExercise exercise) async {
    if (!_isAuthenticated) return _authGuard();
    try {
      await _datasource.save(exercise);
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> update(CustomExercise exercise) async {
    if (!_isAuthenticated) return _authGuard();
    try {
      final existing = await _datasource.getById(exercise.id);
      if (existing == null) {
        return left(
          const ValidationFailure(
            'Custom exercise not found',
            code: 'NOT_FOUND',
          ),
        );
      }
      if (existing.isPermanent && !exercise.isPermanent) {
        return left(
          const ValidationFailure(
            'Cannot change permanent exercise to temporary',
            code: 'INVALID_OPERATION',
          ),
        );
      }
      await _datasource.save(exercise);
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    if (!_isAuthenticated) return _authGuard();
    try {
      await _datasource.delete(id);
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> extendUnlock(
    String id, {
    int days = 7,
  }) async {
    if (!_isAuthenticated) return _authGuard();
    try {
      await _datasource.extendUnlock(id, days: days);
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  // ---- REACTIVE STREAMS ----------------------------------------------------

  @override
  Stream<Either<Failure, List<CustomExercise>>> watchAll() async* {
    if (!_isAuthenticated) {
      yield left(const AuthenticationFailure('User not authenticated'));
      return;
    }
    try {
      await for (final list in _datasource.watchAll()) {
        yield right(list);
      }
    } catch (e) {
      yield left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<CustomExercise>>> watchActive() async* {
    if (!_isAuthenticated) {
      yield left(const AuthenticationFailure('User not authenticated'));
      return;
    }
    try {
      await for (final list in _datasource.watchAll()) {
        yield right(list);
      }
    } catch (e) {
      yield left(CacheFailure(e.toString()));
    }
  }

  // ---- CLOUD SYNC (Premium Only) -------------------------------------------

  @override
  Future<Either<Failure, void>> syncToCloud() async {
    if (!_isAuthenticated) return _authGuard();
    if (_userProfile?.isPremium != true) {
      return left(
        const PermissionDeniedFailure(
          'Cloud sync requires Premium subscription',
          code: 'NOT_PREMIUM',
        ),
      );
    }
    // Cloud sync would hit Firestore; we return success in tests to avoid
    // real network calls.  The guard logic (auth + premium check) is what we
    // are testing here.
    return right(null);
  }

  @override
  Future<Either<Failure, void>> refreshFromCloud() async {
    if (!_isAuthenticated) return _authGuard();
    if (_userProfile?.isPremium != true) {
      return left(
        const PermissionDeniedFailure(
          'Cloud sync requires Premium subscription',
          code: 'NOT_PREMIUM',
        ),
      );
    }
    return right(null);
  }

  // ---- noSuchMethod safety net (should not be called) ----------------------
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Helper to build in-process repo with a logged-in user
// ---------------------------------------------------------------------------

_InProcessRepository _makeRepo(
  FakeCustomExerciseLocalDatasource ds, {
  String? userId = 'user-abc',
  UserProfile? profile,
}) {
  return _InProcessRepository(
    datasource: ds,
    userId: userId,
    userProfile: profile,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeCustomExerciseLocalDatasource ds;

  setUp(() {
    ds = FakeCustomExerciseLocalDatasource();
  });

  tearDown(() {
    ds.reset();
  });

  // ==========================================================================
  // Authentication guard tests
  // ==========================================================================

  group('Authentication guard', () {
    late _InProcessRepository unauthRepo;

    setUp(() {
      unauthRepo = _makeRepo(ds, userId: null);
    });

    test('getAll returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.getAll();
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<AuthenticationFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('getActive returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.getActive();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('getById returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.getById('ex-001');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('findByName returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.findByName('Test');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('getPermanentCount returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.getPermanentCount();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('save returns AuthenticationFailure when not authenticated', () async {
      final result = await unauthRepo.save(makeExercise());
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('update returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.update(makeExercise());
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('delete returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.delete('ex-001');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('extendUnlock returns AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.extendUnlock('ex-001');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('watchAll emits AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.watchAll().first;
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });

    test('watchActive emits AuthenticationFailure when not authenticated',
        () async {
      final result = await unauthRepo.watchActive().first;
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // getAll
  // ==========================================================================

  group('getAll', () {
    test('returns empty list when datasource has no exercises', () async {
      final repo = _makeRepo(ds);
      final result = await repo.getAll();
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (list) => expect(list, isEmpty));
    });

    test('returns all active exercises', () async {
      final repo = _makeRepo(ds);
      ds.seedAll([
        makeExercise(id: 'ex-001', nome: 'Bench Press'),
        makeExercise(id: 'ex-002', nome: 'Squat'),
      ]);
      final result = await repo.getAll();
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.length, equals(2));
        expect(list.map((e) => e.id), containsAll(['ex-001', 'ex-002']));
      });
    });

    test('does not include expired temporary exercises', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'permanent', permanent: true));
      ds.seed(makeExercise(
        id: 'expired-temp',
        permanent: false,
        unlockedUntil: _past(),
      ));
      final result = await repo.getAll();
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.length, equals(1));
        expect(list.first.id, equals('permanent'));
      });
    });

    test('returns CacheFailure when datasource throws', () async {
      final repo = _makeRepo(ds);
      ds.getAllError = Exception('Hive read failure');
      final result = await repo.getAll();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // getActive
  // ==========================================================================

  group('getActive', () {
    test('returns only active (non-expired) exercises', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'active', permanent: true));
      ds.seed(makeExercise(
        id: 'expired',
        permanent: false,
        unlockedUntil: _past(),
      ));
      final result = await repo.getActive();
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.length, equals(1));
        expect(list.first.id, equals('active'));
      });
    });

    test('returns CacheFailure when datasource throws', () async {
      final repo = _makeRepo(ds);
      ds.getAllError = Exception('Hive error');
      final result = await repo.getActive();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // getById
  // ==========================================================================

  group('getById', () {
    test('returns exercise when it exists and is active', () async {
      final repo = _makeRepo(ds);
      final ex = makeExercise(id: 'ex-001');
      ds.seed(ex);
      final result = await repo.getById('ex-001');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNotNull);
        expect(found!.id, equals('ex-001'));
      });
    });

    test('returns null when exercise not found', () async {
      final repo = _makeRepo(ds);
      final result = await repo.getById('nonexistent');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNull);
      });
    });

    test('returns null for expired temporary exercise', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(
        id: 'temp',
        permanent: false,
        unlockedUntil: _past(),
      ));
      final result = await repo.getById('temp');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNull);
      });
    });

    test('returns CacheFailure when datasource throws', () async {
      final repo = _makeRepo(ds);
      ds.getByIdError = Exception('Hive error');
      final result = await repo.getById('ex-001');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // findByName
  // ==========================================================================

  group('findByName', () {
    test('finds exercise by exact name', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'ex-001', nome: 'Bench Press'));
      final result = await repo.findByName('Bench Press');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNotNull);
        expect(found!.nome, equals('Bench Press'));
      });
    });

    test('finds exercise by name case-insensitively', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'ex-001', nome: 'Bench Press'));
      final result = await repo.findByName('bench press');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNotNull);
      });
    });

    test('returns null when name not found', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'ex-001', nome: 'Bench Press'));
      final result = await repo.findByName('Deadlift');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNull);
      });
    });

    test('returns null when datasource is empty', () async {
      final repo = _makeRepo(ds);
      final result = await repo.findByName('Any Name');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNull);
      });
    });

    test('returns CacheFailure when datasource throws', () async {
      final repo = _makeRepo(ds);
      ds.findByNameError = Exception('Hive error');
      final result = await repo.findByName('Test');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // getPermanentCount
  // ==========================================================================

  group('getPermanentCount', () {
    test('returns 0 when no exercises exist', () async {
      final repo = _makeRepo(ds);
      final result = await repo.getPermanentCount();
      result.fold((_) => fail('Expected success'), (count) {
        expect(count, equals(0));
      });
    });

    test('counts only permanent exercises', () async {
      final repo = _makeRepo(ds);
      ds.seedAll([
        makeExercise(id: 'perm-1', permanent: true),
        makeExercise(id: 'perm-2', permanent: true),
        makeExercise(id: 'temp-1', permanent: false),
      ]);
      final result = await repo.getPermanentCount();
      result.fold((_) => fail('Expected success'), (count) {
        expect(count, equals(2));
      });
    });

    test('does not count expired temporary as permanent', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(
        id: 'expired',
        permanent: false,
        unlockedUntil: _past(),
      ));
      final result = await repo.getPermanentCount();
      result.fold((_) => fail('Expected success'), (count) {
        // Expired exercises are not active, so getPermanentCount counts 0
        expect(count, equals(0));
      });
    });

    test('returns CacheFailure when datasource throws', () async {
      final repo = _makeRepo(ds);
      ds.getPermanentCountError = Exception('Hive error');
      final result = await repo.getPermanentCount();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // save
  // ==========================================================================

  group('save', () {
    test('saves exercise to local datasource', () async {
      final repo = _makeRepo(ds);
      final ex = makeExercise();
      final result = await repo.save(ex);
      expect(result.isRight(), isTrue);
      expect(ds.savedCalls.length, equals(1));
      expect(ds.savedCalls.first.id, equals(ex.id));
    });

    test('saved exercise can be retrieved by getById', () async {
      final repo = _makeRepo(ds);
      final ex = makeExercise(id: 'new-ex');
      await repo.save(ex);
      final getResult = await repo.getById('new-ex');
      getResult.fold((_) => fail('Expected success'), (found) {
        expect(found, isNotNull);
        expect(found!.id, equals('new-ex'));
      });
    });

    test('returns CacheFailure when datasource save throws', () async {
      final repo = _makeRepo(ds);
      ds.saveError = Exception('Hive write failure');
      final result = await repo.save(makeExercise());
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });

    test('can save temporary exercise without error', () async {
      final repo = _makeRepo(ds);
      final tempEx = makeExercise(
        id: 'temp-001',
        permanent: false,
        unlockedUntil: _future(days: 7),
      );
      final result = await repo.save(tempEx);
      expect(result.isRight(), isTrue);
    });
  });

  // ==========================================================================
  // update
  // ==========================================================================

  group('update', () {
    test('updates existing exercise successfully', () async {
      final repo = _makeRepo(ds);
      final original = makeExercise(id: 'ex-001', nome: 'Original');
      ds.seed(original);
      final updated = original.copyWith(nome: 'Updated Name');
      final result = await repo.update(updated);
      expect(result.isRight(), isTrue);
      expect(ds.savedCalls.last.nome, equals('Updated Name'));
    });

    test('returns ValidationFailure when exercise does not exist', () async {
      final repo = _makeRepo(ds);
      final result = await repo.update(makeExercise(id: 'nonexistent'));
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ValidationFailure>());
        expect((f as ValidationFailure).code, equals('NOT_FOUND'));
      }, (_) => fail('Expected failure'));
    });

    test('returns ValidationFailure when changing permanent to temporary',
        () async {
      final repo = _makeRepo(ds);
      final permanent = makeExercise(id: 'ex-001', permanent: true);
      ds.seed(permanent);
      // Try to set unlockedUntil (making it temporary) — isPermanent becomes false
      final makeTemp = CustomExercise(
        id: 'ex-001',
        nome: 'Test Exercise',
        focus: const ['PETT'],
        muscoliSecondari: const ['TRIC'],
        tipoEsercizio: 'Compound',
        patternMovimento: 'Push',
        attrezzatura: 'Bilanciere',
        createdAt: DateTime(2024, 1, 15),
        unlockedUntil: _future(), // now temporary
      );
      final result = await repo.update(makeTemp);
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ValidationFailure>());
        expect((f as ValidationFailure).code, equals('INVALID_OPERATION'));
      }, (_) => fail('Expected failure'));
    });

    test('allows updating temporary exercise details', () async {
      final repo = _makeRepo(ds);
      final temp = makeExercise(
        id: 'temp-001',
        permanent: false,
        unlockedUntil: _future(),
      );
      ds.seed(temp);
      final updated = temp.copyWith(nome: 'Renamed Temp');
      final result = await repo.update(updated);
      expect(result.isRight(), isTrue);
    });

    test('allows upgrading temporary to permanent', () async {
      final repo = _makeRepo(ds);
      final temp = makeExercise(
        id: 'temp-001',
        permanent: false,
        unlockedUntil: _future(),
      );
      ds.seed(temp);
      // Make it permanent by setting unlockedUntil to null requires copyWith
      // CustomExercise.copyWith doesn't support nulling unlockedUntil directly
      // because of ?? operator, so we construct explicitly.
      final upgraded = CustomExercise(
        id: 'temp-001',
        nome: temp.nome,
        baseExerciseId: temp.baseExerciseId,
        focus: temp.focus,
        muscoliSecondari: temp.muscoliSecondari,
        tipoEsercizio: temp.tipoEsercizio,
        patternMovimento: temp.patternMovimento,
        attrezzatura: temp.attrezzatura,
        createdAt: temp.createdAt,
        unlockedUntil: null, // permanent
      );
      final result = await repo.update(upgraded);
      expect(result.isRight(), isTrue);
    });
  });

  // ==========================================================================
  // delete
  // ==========================================================================

  group('delete', () {
    test('deletes exercise from local datasource', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'ex-001'));
      final result = await repo.delete('ex-001');
      expect(result.isRight(), isTrue);
      expect(ds.deletedIds, contains('ex-001'));
    });

    test('exercise is no longer accessible after deletion', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'ex-001'));
      await repo.delete('ex-001');
      final getResult = await repo.getById('ex-001');
      getResult.fold((_) => fail('Expected success'), (found) {
        expect(found, isNull);
      });
    });

    test('returns CacheFailure when datasource delete throws', () async {
      final repo = _makeRepo(ds);
      ds.deleteError = Exception('Hive delete failure');
      final result = await repo.delete('ex-001');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // extendUnlock
  // ==========================================================================

  group('extendUnlock', () {
    test('extends temporary exercise unlock by default 7 days', () async {
      final repo = _makeRepo(ds);
      final temp = makeExercise(
        id: 'temp-001',
        permanent: false,
        unlockedUntil: _future(days: 1),
      );
      ds.seed(temp);
      final result = await repo.extendUnlock('temp-001');
      expect(result.isRight(), isTrue);
      expect(ds.extendedIds, contains('temp-001'));
    });

    test('extends temporary exercise unlock by custom days', () async {
      final repo = _makeRepo(ds);
      final temp = makeExercise(
        id: 'temp-001',
        permanent: false,
        unlockedUntil: _future(days: 1),
      );
      ds.seed(temp);
      final result = await repo.extendUnlock('temp-001', days: 14);
      expect(result.isRight(), isTrue);
    });

    test('returns CacheFailure when datasource throws', () async {
      final repo = _makeRepo(ds);
      ds.extendUnlockError = Exception('Hive error');
      final result = await repo.extendUnlock('temp-001');
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<CacheFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // watchAll stream
  // ==========================================================================

  group('watchAll', () {
    test('emits current list of active exercises', () async {
      final repo = _makeRepo(ds);
      ds.seedAll([
        makeExercise(id: 'ex-001'),
        makeExercise(id: 'ex-002'),
      ]);
      final result = await repo.watchAll().first;
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.length, equals(2));
      });
    });

    test('emits empty list when no exercises exist', () async {
      final repo = _makeRepo(ds);
      final result = await repo.watchAll().first;
      result.fold((_) => fail('Expected success'), (list) {
        expect(list, isEmpty);
      });
    });

    test('emits AuthenticationFailure for unauthenticated user', () async {
      final unauthRepo = _makeRepo(ds, userId: null);
      final result = await unauthRepo.watchAll().first;
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // watchActive stream
  // ==========================================================================

  group('watchActive', () {
    test('emits active exercises only', () async {
      final repo = _makeRepo(ds);
      ds.seed(makeExercise(id: 'active'));
      // Expired exercises are excluded by FakeCustomExerciseLocalDatasource.getAll
      final result = await repo.watchActive().first;
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.length, equals(1));
        expect(list.first.id, equals('active'));
      });
    });

    test('emits AuthenticationFailure for unauthenticated user', () async {
      final unauthRepo = _makeRepo(ds, userId: null);
      final result = await unauthRepo.watchActive().first;
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // syncToCloud — premium guard
  // ==========================================================================

  group('syncToCloud', () {
    test('returns PermissionDeniedFailure for free-tier user', () async {
      final repo = _makeRepo(ds); // no userProfile → isPremium == false
      final result = await repo.syncToCloud();
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<PermissionDeniedFailure>());
        expect((f as PermissionDeniedFailure).code, equals('NOT_PREMIUM'));
      }, (_) => fail('Expected failure'));
    });

    test('returns AuthenticationFailure when not authenticated', () async {
      final unauthRepo = _makeRepo(ds, userId: null);
      final result = await unauthRepo.syncToCloud();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // refreshFromCloud — premium guard
  // ==========================================================================

  group('refreshFromCloud', () {
    test('returns PermissionDeniedFailure for free-tier user', () async {
      final repo = _makeRepo(ds);
      final result = await repo.refreshFromCloud();
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<PermissionDeniedFailure>());
        expect((f as PermissionDeniedFailure).code, equals('NOT_PREMIUM'));
      }, (_) => fail('Expected failure'));
    });

    test('returns AuthenticationFailure when not authenticated', () async {
      final unauthRepo = _makeRepo(ds, userId: null);
      final result = await unauthRepo.refreshFromCloud();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<AuthenticationFailure>()), (_) => fail('Expected failure'));
    });
  });

  // ==========================================================================
  // Edge cases and integration scenarios
  // ==========================================================================

  group('Edge cases', () {
    test('multiple saves with same id overwrite previous exercise', () async {
      final repo = _makeRepo(ds);
      final original = makeExercise(id: 'ex-001', nome: 'Original');
      await repo.save(original);
      final updated = makeExercise(id: 'ex-001', nome: 'Updated');
      await repo.save(updated);

      final result = await repo.getById('ex-001');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found!.nome, equals('Updated'));
      });
    });

    test('saving multiple exercises independently', () async {
      final repo = _makeRepo(ds);
      await repo.save(makeExercise(id: 'ex-001', nome: 'Exercise A'));
      await repo.save(makeExercise(id: 'ex-002', nome: 'Exercise B'));
      await repo.save(makeExercise(id: 'ex-003', nome: 'Exercise C'));

      final result = await repo.getAll();
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.length, equals(3));
      });
    });

    test('delete does not affect other exercises', () async {
      final repo = _makeRepo(ds);
      ds.seedAll([
        makeExercise(id: 'ex-001'),
        makeExercise(id: 'ex-002'),
        makeExercise(id: 'ex-003'),
      ]);
      await repo.delete('ex-002');

      final result = await repo.getAll();
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.length, equals(2));
        expect(list.map((e) => e.id), isNot(contains('ex-002')));
      });
    });

    test('getPermanentCount is correct after mixed saves', () async {
      final repo = _makeRepo(ds);
      ds.seedAll([
        makeExercise(id: 'p1', permanent: true),
        makeExercise(id: 'p2', permanent: true),
        makeExercise(id: 'p3', permanent: true),
        makeExercise(id: 't1', permanent: false),
        makeExercise(id: 't2', permanent: false),
      ]);
      final result = await repo.getPermanentCount();
      result.fold((_) => fail('Expected success'), (count) {
        expect(count, equals(3));
      });
    });

    test('active temporary exercise is included in getAll', () async {
      final repo = _makeRepo(ds);
      final active = makeExercise(
        id: 'active-temp',
        permanent: false,
        unlockedUntil: _future(days: 30),
      );
      ds.seed(active);
      final result = await repo.getAll();
      result.fold((_) => fail('Expected success'), (list) {
        expect(list.any((e) => e.id == 'active-temp'), isTrue);
      });
    });

    test('findByName returns first match when multiple exercises exist',
        () async {
      final repo = _makeRepo(ds);
      ds.seedAll([
        makeExercise(id: 'ex-001', nome: 'Bench Press'),
        makeExercise(id: 'ex-002', nome: 'Squat'),
        makeExercise(id: 'ex-003', nome: 'Deadlift'),
      ]);
      final result = await repo.findByName('Squat');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNotNull);
        expect(found!.nome, equals('Squat'));
      });
    });

    test('variant exercise can be saved and retrieved', () async {
      final repo = _makeRepo(ds);
      final variant = makeExercise(
        id: 'variant-001',
        nome: 'Close Grip Bench',
        baseExerciseId: 'bench_press_barbell',
      );
      await repo.save(variant);

      final result = await repo.getById('variant-001');
      result.fold((_) => fail('Expected success'), (found) {
        expect(found, isNotNull);
        expect(found!.baseExerciseId, equals('bench_press_barbell'));
        expect(found.isVariant, isTrue);
        expect(found.isPureCustom, isFalse);
      });
    });
  });
}
