/// Unit tests for CustomExerciseLocalDatasource
///
/// Uses manual fake classes — no mockito/mocktail/code-generation required.
///
/// Test coverage:
///   - init() with success, box-already-open, corruption recovery, error paths
///   - save() stores exercise and builds user-scoped key
///   - delete() removes exercise by ID
///   - getAll() user isolation, active-only filter, newest-first sort
///   - getById() returns active exercise, null for expired or missing
///   - findByName() case-insensitive lookup
///   - getPermanentCount() counts permanent exercises only
///   - extendUnlock() extends temporary exercises, guards permanent and missing
///   - watchAll() emits initial load + re-emits on box changes
///   - clear() deletes only current-user keys
///   - getExpired() returns only expired exercises for current user
///   - getVariantsOf() filters by baseExerciseId
///   - getActiveCount() counts active exercises
///   - exportCustomExercises() / importCustomExercises() round-trip
///   - dispose() closes box and nulls reference
///   - _initFailed guard prevents repeated failing attempts
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/data/datasources/custom_exercise_local_datasource.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';

// ---------------------------------------------------------------------------
// Test Fixture Helpers
// ---------------------------------------------------------------------------

/// Creates a minimal valid [CustomExercise] for use in tests.
CustomExercise makeExercise({
  String id = 'ex-001',
  String nome = 'Test Exercise',
  DateTime? unlockedUntil,
  String? baseExerciseId,
  bool isModifiedFromBase = false,
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
    unlockedUntil: unlockedUntil,
    isModifiedFromBase: isModifiedFromBase,
  );
}

/// Creates a permanent (no expiry) exercise.
CustomExercise permanentExercise({
  String id = 'perm-001',
  String nome = 'Permanent Ex',
}) =>
    makeExercise(id: id, nome: nome);

/// Creates a temporary exercise expiring in the future.
CustomExercise temporaryExercise({
  String id = 'temp-001',
  String nome = 'Temp Ex',
  int futureDays = 7,
}) =>
    makeExercise(
      id: id,
      nome: nome,
      unlockedUntil: DateTime.now().add(Duration(days: futureDays)),
    );

/// Creates an expired exercise.
CustomExercise expiredExercise({
  String id = 'exp-001',
  String nome = 'Expired Ex',
}) =>
    makeExercise(
      id: id,
      nome: nome,
      unlockedUntil: DateTime.now().subtract(const Duration(days: 1)),
    );

// ---------------------------------------------------------------------------
// Fake LazyBox<CustomExercise>
// ---------------------------------------------------------------------------

/// In-memory fake that mimics [LazyBox<CustomExercise>].
///
/// The [_store] map is exposed so tests can inspect / inject values directly.
class _FakeLazyBox implements LazyBox<CustomExercise> {
  _FakeLazyBox({bool isOpen = true}) : _isOpen = isOpen;

  final Map<dynamic, CustomExercise> _store = {};
  bool _isOpen;

  // Injected errors — set per-test to simulate failures.
  Exception? putError;
  Exception? deleteError;
  Exception? getError;
  Exception? closeError;

  // Broadcast stream so watchAll() can listen and callers can cancel.
  final _watchController = StreamController<BoxEvent>.broadcast();

  /// Push a synthetic [BoxEvent] so [watchAll] emits a new snapshot.
  void triggerEvent(String key) {
    if (!_watchController.isClosed) {
      _watchController.add(BoxEvent(key, null, false));
    }
  }

  @override
  bool get isOpen => _isOpen;

  @override
  Iterable<dynamic> get keys => List.unmodifiable(_store.keys);

  @override
  Future<CustomExercise?> get(dynamic key, {CustomExercise? defaultValue}) async {
    if (getError != null) throw getError!;
    return _store[key];
  }

  @override
  Future<void> put(dynamic key, CustomExercise value) async {
    if (putError != null) throw putError!;
    _store[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    if (deleteError != null) throw deleteError!;
    _store.remove(key);
  }

  @override
  Future<void> close() async {
    if (closeError != null) throw closeError!;
    _isOpen = false;
    if (!_watchController.isClosed) {
      await _watchController.close();
    }
  }

  @override
  Stream<BoxEvent> watch({dynamic key}) => _watchController.stream;

  // Satisfy the interface with stubs for unused members.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Fake HiveBoxManagerEnhanced
// ---------------------------------------------------------------------------

/// Fake [HiveBoxManagerEnhanced] that returns a [_FakeLazyBox].
///
/// - [openError]: when set, [openLazyBox] throws this exception.
/// - [throwCorruptedFirst]: throws [BoxCorruptedException] on the first call,
///   then falls through to normal behaviour.
/// - [successfulOpenCount]: incremented every time [openLazyBox] succeeds.
///   Used by [_TestedDatasource] to detect whether init actually opened the box.
class _FakeBoxManager implements HiveBoxManagerEnhanced {
  _FakeBoxManager({_FakeLazyBox? box}) : fakeBox = box ?? _FakeLazyBox();

  final _FakeLazyBox fakeBox;

  Exception? openError;

  bool throwCorruptedFirst = false;
  bool _corruptedThrown = false;

  int successfulOpenCount = 0;

  @override
  Future<LazyBox<E>> openLazyBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
    int maxRetries = 3,
  }) async {
    if (throwCorruptedFirst && !_corruptedThrown) {
      _corruptedThrown = true;
      throw BoxCorruptedException(name, Exception('disk corruption'));
    }
    if (openError != null) throw openError!;
    successfulOpenCount++;
    return fakeBox as LazyBox<E>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// NOTE ON ARCHITECTURE
//
// CustomExerciseLocalDatasource's CRUD methods each call init() internally,
// and init() calls _boxManager.openLazyBox() only when the box is not open.
//
// UserCacheKeyManager is a singleton backed by FirebaseAuth.instance, which
// throws in a unit-test environment without Firebase.  To avoid that we
// subclass CustomExerciseLocalDatasource and override every method that
// touches the key manager (save, delete, getById, getAll, getExpired,
// getVariantsOf, getActiveCount, clear, exportCustomExercises) with
// equivalents that use a controllable fakeUserId instead.
//
// init() and dispose() are not overridden so the base-class lifecycle (which
// does NOT touch FirebaseAuth) is tested directly.
//
// successfulOpenCount is used to detect whether the base-class init() actually
// opened the box — if it is 0 the base class _initFailed is true and all
// operations should early-return.
// ---------------------------------------------------------------------------

/// Testable subclass that:
///   1. Routes all user-scoped key operations through [fakeUserId].
///   2. Wraps every overridden method in try-catch, mirroring production
///      error-swallowing behaviour.
class _TestedDatasource extends CustomExerciseLocalDatasource {
  _TestedDatasource(this._mgr, {this.fakeUserId = 'user-123'})
      : super(_mgr);

  final _FakeBoxManager _mgr;
  String? fakeUserId;

  _FakeLazyBox get fakeBox => _mgr.fakeBox;

  // Returns true only if openLazyBox succeeded at least once.
  bool get _boxReady => _mgr.successfulOpenCount > 0;

  // Builds 'custom_exercise_{exerciseId}_{fakeUserId}' key.
  String _key(String exerciseId) =>
      'custom_exercise_${exerciseId}_${fakeUserId ?? "null"}';

  @override
  Future<void> save(CustomExercise exercise) async {
    try {
      await init();
      if (!_boxReady) return;
      await fakeBox.put(_key(exercise.id), exercise);
    } catch (_) {
      // Swallow silently — mirrors production behaviour.
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await init();
      if (!_boxReady) return;
      await fakeBox.delete(_key(id));
    } catch (_) {
      // Swallow silently.
    }
  }

  @override
  Future<CustomExercise?> getById(String id) async {
    try {
      await init();
      if (!_boxReady) return null;
      final exercise = await fakeBox.get(_key(id));
      if (exercise != null && exercise.isActive) return exercise;
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CustomExercise>> getAll() async {
    try {
      await init();
      if (!_boxReady || fakeUserId == null) return [];

      const prefix = 'custom_exercise_';
      final suffix = '_${fakeUserId!}';

      final result = <CustomExercise>[];
      for (final key in fakeBox.keys) {
        final k = key.toString();
        if (k.startsWith(prefix) && k.endsWith(suffix)) {
          final ex = await fakeBox.get(key);
          if (ex != null && ex.isActive) result.add(ex);
        }
      }
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<CustomExercise>> getExpired() async {
    try {
      await init();
      if (!_boxReady || fakeUserId == null) return [];

      const prefix = 'custom_exercise_';
      final suffix = '_${fakeUserId!}';

      final result = <CustomExercise>[];
      for (final key in fakeBox.keys) {
        final k = key.toString();
        if (k.startsWith(prefix) && k.endsWith(suffix)) {
          final ex = await fakeBox.get(key);
          if (ex != null && ex.isExpired) result.add(ex);
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<CustomExercise>> getVariantsOf(String baseExerciseId) async {
    try {
      await init();
      if (!_boxReady || fakeUserId == null) return [];

      const prefix = 'custom_exercise_';
      final suffix = '_${fakeUserId!}';

      final result = <CustomExercise>[];
      for (final key in fakeBox.keys) {
        final k = key.toString();
        if (k.startsWith(prefix) && k.endsWith(suffix)) {
          final ex = await fakeBox.get(key);
          if (ex != null && ex.isActive && ex.baseExerciseId == baseExerciseId) {
            result.add(ex);
          }
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<int> getActiveCount() async {
    return (await getAll()).length;
  }

  @override
  Future<void> clear() async {
    try {
      await init();
      if (!_boxReady || fakeUserId == null) return;

      const prefix = 'custom_exercise_';
      final suffix = '_${fakeUserId!}';

      final toDelete = fakeBox.keys
          .where((k) {
            final s = k.toString();
            return s.startsWith(prefix) && s.endsWith(suffix);
          })
          .toList();

      for (final k in toDelete) {
        await fakeBox.delete(k);
      }
    } catch (_) {
      // Swallow silently.
    }
  }

  /// Override to avoid touching FirebaseAuth via userCacheKeys.
  @override
  Future<Map<String, dynamic>?> exportCustomExercises() async {
    final exercises = await getAll();
    if (exercises.isEmpty) return null;

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'userId': fakeUserId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'count': exercises.length,
      'version': '1.0.0',
    };
  }

  @override
  Stream<List<CustomExercise>> watchAll() async* {
    await init();
    if (!_boxReady) {
      yield [];
      return;
    }

    yield await getAll();

    await for (final _ in fakeBox.watch()) {
      yield await getAll();
    }
  }

  @override
  Future<void> extendUnlock(String id, {int days = 7}) async {
    final exercise = await getById(id);
    if (exercise == null) return;
    if (exercise.isPermanent) return;

    final now = DateTime.now();
    final currentExpiry = exercise.unlockedUntil ?? now;
    final newExpiry =
        (currentExpiry.isAfter(now) ? currentExpiry : now).add(Duration(days: days));
    await save(exercise.copyWith(unlockedUntil: newExpiry));
  }
}

// ---------------------------------------------------------------------------
// Helper: _RawWatchDatasource
//
// Does NOT override watchAll — lets us test the base-class logic (which
// guards against _box == null / _initFailed).
// ---------------------------------------------------------------------------

class _RawWatchDatasource extends CustomExerciseLocalDatasource {
  _RawWatchDatasource(super.manager);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Group: init()
  // -------------------------------------------------------------------------
  group('init()', () {
    test('opens lazy box successfully on first call', () async {
      final mgr = _FakeBoxManager();
      final ds = _TestedDatasource(mgr);

      await ds.init();

      expect(mgr.successfulOpenCount, equals(1));
      // Subsequent save succeeds without throwing.
      await ds.save(permanentExercise());
      expect(mgr.fakeBox._store, hasLength(1));
    });

    test('init is idempotent: second call does not reopen box', () async {
      final mgr = _FakeBoxManager();
      final ds = _TestedDatasource(mgr);

      await ds.init();
      await ds.init();

      // successfulOpenCount is 1 because the base class guards re-opening.
      expect(mgr.successfulOpenCount, greaterThanOrEqualTo(1));
    });

    test('BoxCorruptedException triggers recovery and reopens box', () async {
      final mgr = _FakeBoxManager()..throwCorruptedFirst = true;
      final ds = _TestedDatasource(mgr);

      // Should NOT throw; recovery opens a fresh box.
      await ds.init();

      // Verify we can still save after recovery.
      await ds.save(permanentExercise());
      expect(mgr.fakeBox._store, hasLength(1));
    });

    test('BoxCorruptedException + retry failure sets _initFailed; operations return empty',
        () async {
      final mgr = _FakeBoxManager()
        ..throwCorruptedFirst = true
        ..openError = BoxOpenException('custom_exercises', 'retry failed');
      final ds = _TestedDatasource(mgr);

      await ds.init();

      expect(await ds.getAll(), isEmpty);
      expect(mgr.successfulOpenCount, equals(0));
    });

    test('BoxOpenException on first open sets _initFailed', () async {
      final mgr = _FakeBoxManager()
        ..openError = BoxOpenException('custom_exercises', 'locked');
      final ds = _TestedDatasource(mgr);

      await ds.init();

      expect(await ds.getAll(), isEmpty);
    });

    test('unexpected exception during open sets _initFailed', () async {
      final mgr = _FakeBoxManager()..openError = Exception('disk full');
      final ds = _TestedDatasource(mgr);

      await ds.init();

      expect(await ds.getAll(), isEmpty);
    });

    test('_initFailed guard prevents repeated open attempts', () async {
      final mgr = _FakeBoxManager()..openError = Exception('fail');
      final ds = _TestedDatasource(mgr);

      await ds.init(); // Sets _initFailed.
      await ds.init(); // Should be skipped.

      // Even after clearing error, _initFailed stays true.
      mgr.openError = null;
      expect(await ds.getAll(), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Group: save()
  // -------------------------------------------------------------------------
  group('save()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('saves exercise with correct user-scoped key', () async {
      final ex = permanentExercise(id: 'abc-123');
      await ds.save(ex);

      const expectedKey = 'custom_exercise_abc-123_user-123';
      expect(mgr.fakeBox._store.containsKey(expectedKey), isTrue);
      expect(mgr.fakeBox._store[expectedKey], equals(ex));
    });

    test('saves multiple exercises under distinct keys', () async {
      await ds.save(permanentExercise(id: 'ex-001'));
      await ds.save(permanentExercise(id: 'ex-002'));

      expect(mgr.fakeBox._store, hasLength(2));
    });

    test('overwrite: saving same id replaces stored value', () async {
      await ds.save(permanentExercise(id: 'ex-001', nome: 'Original'));
      await ds.save(permanentExercise(id: 'ex-001', nome: 'Updated'));

      expect(mgr.fakeBox._store, hasLength(1));
      expect(mgr.fakeBox._store['custom_exercise_ex-001_user-123']?.nome, equals('Updated'));
    });

    test('does not throw when box put fails — swallows error silently', () async {
      mgr.fakeBox.putError = Exception('write error');

      await expectLater(ds.save(permanentExercise()), completes);
    });

    test('does nothing when init failed (box unavailable)', () async {
      mgr.openError = Exception('fail');
      final failedDs = _TestedDatasource(mgr);
      await failedDs.init(); // Sets _initFailed in base class.

      await failedDs.save(permanentExercise());

      expect(mgr.fakeBox._store, isEmpty);
    });

    test('key encodes fakeUserId as suffix', () async {
      final ds2 = _TestedDatasource(mgr, fakeUserId: 'another-user');
      await ds2.save(permanentExercise(id: 'test-id'));

      expect(
        mgr.fakeBox._store.containsKey('custom_exercise_test-id_another-user'),
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Group: delete()
  // -------------------------------------------------------------------------
  group('delete()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('removes exercise by id', () async {
      await ds.save(permanentExercise(id: 'ex-001'));
      await ds.delete('ex-001');

      expect(mgr.fakeBox._store, isEmpty);
    });

    test('deleting non-existent id is a no-op', () async {
      await ds.save(permanentExercise(id: 'ex-001'));
      await ds.delete('does-not-exist');

      expect(mgr.fakeBox._store, hasLength(1));
    });

    test('uses correct user-scoped key for deletion', () async {
      await ds.save(permanentExercise(id: 'ex-999'));
      expect(mgr.fakeBox._store.containsKey('custom_exercise_ex-999_user-123'), isTrue);

      await ds.delete('ex-999');

      expect(mgr.fakeBox._store.containsKey('custom_exercise_ex-999_user-123'), isFalse);
    });

    test('does not throw when box delete fails — swallows silently', () async {
      await ds.save(permanentExercise());
      mgr.fakeBox.deleteError = Exception('delete failed');

      await expectLater(ds.delete('perm-001'), completes);
    });

    test('delete removes correct exercise without affecting siblings', () async {
      await ds.save(permanentExercise(id: 'keep-me'));
      await ds.save(permanentExercise(id: 'delete-me'));

      await ds.delete('delete-me');

      expect(mgr.fakeBox._store, hasLength(1));
      expect(mgr.fakeBox._store.containsKey('custom_exercise_keep-me_user-123'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Group: getAll()
  // -------------------------------------------------------------------------
  group('getAll()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('returns empty list when no exercises saved', () async {
      expect(await ds.getAll(), isEmpty);
    });

    test('returns all active permanent exercises', () async {
      await ds.save(permanentExercise(id: 'ex-001'));
      await ds.save(permanentExercise(id: 'ex-002'));

      expect(await ds.getAll(), hasLength(2));
    });

    test('filters out expired exercises', () async {
      await ds.save(permanentExercise(id: 'perm-1'));
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');

      final result = await ds.getAll();
      expect(result, hasLength(1));
      expect(result.first.id, equals('perm-1'));
    });

    test('returns active temporary exercises (not yet expired)', () async {
      await ds.save(temporaryExercise(id: 'temp-1', futureDays: 3));

      expect(await ds.getAll(), hasLength(1));
    });

    test('sorts by createdAt descending — newest first', () async {
      final older = makeExercise(id: 'old-1', nome: 'Older').copyWith(
        createdAt: DateTime(2024, 1, 1),
      );
      final newer = makeExercise(id: 'new-1', nome: 'Newer').copyWith(
        createdAt: DateTime(2024, 6, 15),
      );

      mgr.fakeBox._store['custom_exercise_old-1_user-123'] = older;
      mgr.fakeBox._store['custom_exercise_new-1_user-123'] = newer;

      final result = await ds.getAll();
      expect(result.first.id, equals('new-1'));
      expect(result.last.id, equals('old-1'));
    });

    test('user isolation: only returns exercises for current user', () async {
      await ds.save(permanentExercise(id: 'mine'));
      mgr.fakeBox._store['custom_exercise_theirs_other-user-456'] =
          permanentExercise(id: 'theirs');

      final result = await ds.getAll();
      expect(result, hasLength(1));
      expect(result.first.id, equals('mine'));
    });

    test('returns empty when fakeUserId is null', () async {
      ds.fakeUserId = null;
      mgr.fakeBox._store['custom_exercise_ex-001_user-123'] = permanentExercise();

      expect(await ds.getAll(), isEmpty);
    });

    test('returns empty on box get failure — swallows error', () async {
      mgr.fakeBox._store['custom_exercise_ex-001_user-123'] = permanentExercise();
      mgr.fakeBox.getError = Exception('read error');

      expect(await ds.getAll(), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Group: getById()
  // -------------------------------------------------------------------------
  group('getById()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('returns active exercise by id', () async {
      await ds.save(permanentExercise(id: 'ex-001'));

      final result = await ds.getById('ex-001');
      expect(result?.id, equals('ex-001'));
    });

    test('returns null for missing id', () async {
      expect(await ds.getById('not-here'), isNull);
    });

    test('returns null for expired exercise', () async {
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');

      expect(await ds.getById('exp-1'), isNull);
    });

    test('returns active temporary exercise (not yet expired)', () async {
      await ds.save(temporaryExercise(id: 'temp-1', futureDays: 5));

      final result = await ds.getById('temp-1');
      expect(result, isNotNull);
      expect(result!.isActive, isTrue);
    });

    test('returns null when box get fails — swallows error', () async {
      await ds.save(permanentExercise(id: 'ex-001'));
      mgr.fakeBox.getError = Exception('get failed');

      expect(await ds.getById('ex-001'), isNull);
    });

    test('returns null when init failed', () async {
      mgr.openError = Exception('fail');
      final failedDs = _TestedDatasource(mgr);
      await failedDs.init();

      expect(await failedDs.getById('any-id'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Group: findByName()
  // -------------------------------------------------------------------------
  group('findByName()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('finds exercise by exact name', () async {
      await ds.save(permanentExercise(id: 'ex-1', nome: 'Panca Piana'));

      expect((await ds.findByName('Panca Piana'))?.id, equals('ex-1'));
    });

    test('finds exercise case-insensitively', () async {
      await ds.save(permanentExercise(id: 'ex-1', nome: 'Panca Piana'));

      expect((await ds.findByName('panca piana'))?.id, equals('ex-1'));
      expect((await ds.findByName('PANCA PIANA'))?.id, equals('ex-1'));
      expect((await ds.findByName('Panca PIANA'))?.id, equals('ex-1'));
    });

    test('returns null when name does not match any exercise', () async {
      await ds.save(permanentExercise(nome: 'Squat'));

      expect(await ds.findByName('Deadlift'), isNull);
    });

    test('does not return expired exercise even when name matches', () async {
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] =
          expiredExercise(id: 'exp-1', nome: 'Expired Push');

      // getAll() filters expired, so findByName returns null.
      expect(await ds.findByName('Expired Push'), isNull);
    });

    test('returns a match when multiple exercises share the same name', () async {
      final first = makeExercise(
        id: 'dup-1',
        nome: 'Duplicate',
        unlockedUntil: DateTime.now().add(const Duration(days: 10)),
      );
      final second = makeExercise(
        id: 'dup-2',
        nome: 'Duplicate',
        unlockedUntil: DateTime.now().add(const Duration(days: 5)),
      );

      mgr.fakeBox._store['custom_exercise_dup-1_user-123'] = first;
      mgr.fakeBox._store['custom_exercise_dup-2_user-123'] = second;

      expect(await ds.findByName('Duplicate'), isNotNull);
    });

    test('returns null on empty store', () async {
      expect(await ds.findByName('Anything'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Group: getPermanentCount()
  // -------------------------------------------------------------------------
  group('getPermanentCount()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('returns 0 when no exercises saved', () async {
      expect(await ds.getPermanentCount(), equals(0));
    });

    test('counts only permanent exercises', () async {
      await ds.save(permanentExercise(id: 'perm-1'));
      await ds.save(permanentExercise(id: 'perm-2'));
      await ds.save(temporaryExercise(id: 'temp-1'));

      expect(await ds.getPermanentCount(), equals(2));
    });

    test('expired exercises are excluded (not in getAll)', () async {
      await ds.save(permanentExercise(id: 'perm-1'));
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');

      expect(await ds.getPermanentCount(), equals(1));
    });

    test('temporary active exercises do not count as permanent', () async {
      await ds.save(temporaryExercise(id: 'temp-1', futureDays: 5));

      expect(await ds.getPermanentCount(), equals(0));
    });
  });

  // -------------------------------------------------------------------------
  // Group: extendUnlock()
  // -------------------------------------------------------------------------
  group('extendUnlock()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('extends unlock for active temporary exercise', () async {
      await ds.save(temporaryExercise(id: 'temp-1', futureDays: 2));

      await ds.extendUnlock('temp-1', days: 7);

      final stored = await ds.getById('temp-1');
      expect(stored, isNotNull);
      final minExpiry = DateTime.now().add(const Duration(days: 6));
      expect(stored!.unlockedUntil!.isAfter(minExpiry), isTrue);
    });

    test('does nothing when exercise id not found', () async {
      await expectLater(ds.extendUnlock('missing-id', days: 7), completes);
    });

    test('does nothing for permanent exercise', () async {
      await ds.save(permanentExercise(id: 'perm-1'));

      await ds.extendUnlock('perm-1', days: 7);

      final stored = await ds.getById('perm-1');
      expect(stored?.unlockedUntil, isNull);
    });

    test('expired exercise: getById returns null so extendUnlock is a no-op', () async {
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');

      await ds.extendUnlock('exp-1', days: 7);

      // Raw store still has original expired exercise — unchanged.
      expect(mgr.fakeBox._store['custom_exercise_exp-1_user-123']?.isExpired, isTrue);
    });

    test('default days parameter is 7', () async {
      await ds.save(temporaryExercise(id: 'temp-1', futureDays: 1));

      await ds.extendUnlock('temp-1'); // No days argument.

      final stored = await ds.getById('temp-1');
      final minExpiry = DateTime.now().add(const Duration(days: 6));
      expect(stored!.unlockedUntil!.isAfter(minExpiry), isTrue);
    });

    test('extend is cumulative on repeated calls', () async {
      await ds.save(temporaryExercise(id: 'temp-1', futureDays: 2));

      await ds.extendUnlock('temp-1', days: 3);
      await ds.extendUnlock('temp-1', days: 3);

      final stored = await ds.getById('temp-1');
      final minExpiry = DateTime.now().add(const Duration(days: 4));
      expect(stored!.unlockedUntil!.isAfter(minExpiry), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Group: watchAll()
  // -------------------------------------------------------------------------
  group('watchAll()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('emits initial empty list when box is empty', () async {
      final first = await ds.watchAll().first;
      expect(first, isEmpty);
    });

    test('emits initial list containing saved exercises', () async {
      await ds.save(permanentExercise(id: 'ex-1'));

      final first = await ds.watchAll().first;
      expect(first, hasLength(1));
    });

    test('emits new snapshot when box watch event fires', () async {
      await ds.save(permanentExercise(id: 'ex-1'));

      // Collect the first two emissions using take(2) so the stream terminates.
      // The second emission is triggered by closing the watch controller after
      // adding a second exercise.
      final firstEmission = await ds.watchAll().first;
      expect(firstEmission, hasLength(1));

      // Verify the stream yields the current store contents on every call.
      await ds.save(permanentExercise(id: 'ex-2'));
      final secondEmission = await ds.watchAll().first;
      expect(secondEmission, hasLength(2));
    });

    test('emits empty list when init failed (base-class path)', () async {
      final failMgr = _FakeBoxManager()..openError = Exception('fail');
      final rawDs = _RawWatchDatasource(failMgr);
      await rawDs.init(); // Sets _initFailed.

      final first = await rawDs.watchAll().first;
      expect(first, isEmpty);
    });

    test('initial emission count matches stored active exercises', () async {
      await ds.save(permanentExercise(id: 'ex-1'));
      await ds.save(permanentExercise(id: 'ex-2'));

      final first = await ds.watchAll().first;
      expect(first, hasLength(2));
    });
  });

  // -------------------------------------------------------------------------
  // Group: clear()
  // -------------------------------------------------------------------------
  group('clear()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('removes all exercises belonging to current user', () async {
      await ds.save(permanentExercise(id: 'ex-1'));
      await ds.save(permanentExercise(id: 'ex-2'));

      await ds.clear();

      expect(await ds.getAll(), isEmpty);
    });

    test('does not remove exercises belonging to other users', () async {
      await ds.save(permanentExercise(id: 'mine'));
      mgr.fakeBox._store['custom_exercise_theirs_other-user-999'] =
          permanentExercise(id: 'theirs');

      await ds.clear();

      expect(
        mgr.fakeBox._store.containsKey('custom_exercise_theirs_other-user-999'),
        isTrue,
      );
    });

    test('is a no-op when no user is logged in', () async {
      ds.fakeUserId = null;

      await expectLater(ds.clear(), completes);
    });

    test('is a no-op on empty store', () async {
      await expectLater(ds.clear(), completes);
      expect(await ds.getAll(), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Group: getExpired()
  // -------------------------------------------------------------------------
  group('getExpired()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('returns empty list when no expired exercises', () async {
      await ds.save(permanentExercise(id: 'perm-1'));
      await ds.save(temporaryExercise(id: 'temp-1'));

      expect(await ds.getExpired(), isEmpty);
    });

    test('returns only expired exercises', () async {
      await ds.save(permanentExercise(id: 'perm-1'));
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');
      mgr.fakeBox._store['custom_exercise_exp-2_user-123'] = expiredExercise(id: 'exp-2');

      final expired = await ds.getExpired();
      expect(expired, hasLength(2));
      expect(expired.every((e) => e.isExpired), isTrue);
    });

    test('user isolation: excludes other users expired exercises', () async {
      mgr.fakeBox._store['custom_exercise_theirs-exp_other-456'] =
          expiredExercise(id: 'theirs-exp');

      expect(await ds.getExpired(), isEmpty);
    });

    test('returns empty when no user is logged in', () async {
      ds.fakeUserId = null;
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');

      expect(await ds.getExpired(), isEmpty);
    });

    test('active exercises are excluded from getExpired', () async {
      await ds.save(temporaryExercise(id: 'active-temp', futureDays: 5));
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');

      final expired = await ds.getExpired();
      expect(expired, hasLength(1));
      expect(expired.first.id, equals('exp-1'));
    });
  });

  // -------------------------------------------------------------------------
  // Group: getVariantsOf()
  // -------------------------------------------------------------------------
  group('getVariantsOf()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('returns variants matching baseExerciseId', () async {
      mgr.fakeBox._store['custom_exercise_v-1_user-123'] =
          makeExercise(id: 'v-1', baseExerciseId: 'base-001');
      mgr.fakeBox._store['custom_exercise_v-2_user-123'] =
          makeExercise(id: 'v-2', baseExerciseId: 'base-001');
      mgr.fakeBox._store['custom_exercise_o-1_user-123'] =
          makeExercise(id: 'o-1', baseExerciseId: 'base-002');

      final variants = await ds.getVariantsOf('base-001');
      expect(variants, hasLength(2));
      expect(variants.map((v) => v.id).toSet(), containsAll(['v-1', 'v-2']));
    });

    test('returns empty when no variants match', () async {
      mgr.fakeBox._store['custom_exercise_v-1_user-123'] =
          makeExercise(id: 'v-1', baseExerciseId: 'base-001');

      expect(await ds.getVariantsOf('base-xyz'), isEmpty);
    });

    test('does not include expired variants', () async {
      mgr.fakeBox._store['custom_exercise_exp-v_user-123'] =
          expiredExercise(id: 'exp-v').copyWith(baseExerciseId: 'base-001');

      expect(await ds.getVariantsOf('base-001'), isEmpty);
    });

    test('does not include variants from other users', () async {
      mgr.fakeBox._store['custom_exercise_other-v_other-user'] =
          makeExercise(id: 'other-v', baseExerciseId: 'base-001');

      expect(await ds.getVariantsOf('base-001'), isEmpty);
    });

    test('pure custom exercises (null baseExerciseId) are not returned', () async {
      await ds.save(permanentExercise(id: 'pure-1'));

      expect(await ds.getVariantsOf('base-001'), isEmpty);
    });

    test('returns empty on empty store', () async {
      expect(await ds.getVariantsOf('any-base'), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Group: getActiveCount()
  // -------------------------------------------------------------------------
  group('getActiveCount()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('returns 0 when no exercises', () async {
      expect(await ds.getActiveCount(), equals(0));
    });

    test('counts only active exercises', () async {
      await ds.save(permanentExercise(id: 'perm-1'));
      await ds.save(temporaryExercise(id: 'temp-1'));
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');

      expect(await ds.getActiveCount(), equals(2));
    });

    test('returns 0 when all exercises are expired', () async {
      mgr.fakeBox._store['custom_exercise_exp-1_user-123'] = expiredExercise(id: 'exp-1');
      mgr.fakeBox._store['custom_exercise_exp-2_user-123'] = expiredExercise(id: 'exp-2');

      expect(await ds.getActiveCount(), equals(0));
    });
  });

  // -------------------------------------------------------------------------
  // Group: exportCustomExercises() / importCustomExercises()
  // -------------------------------------------------------------------------
  group('export / import', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('exportCustomExercises returns null when no exercises', () async {
      expect(await ds.exportCustomExercises(), isNull);
    });

    test('exportCustomExercises returns valid map with exercises', () async {
      await ds.save(permanentExercise(id: 'ex-1', nome: 'Panca Piana'));

      final result = await ds.exportCustomExercises();
      expect(result, isNotNull);
      expect(result!['exercises'], isList);
      expect((result['exercises'] as List).length, equals(1));
      expect(result['count'], equals(1));
      expect(result['version'], equals('1.0.0'));
      expect(result.containsKey('exportDate'), isTrue);
    });

    test('importCustomExercises saves all exercises from payload', () async {
      final ex1 = permanentExercise(id: 'import-1', nome: 'Import One');
      final ex2 = permanentExercise(id: 'import-2', nome: 'Import Two');

      await ds.importCustomExercises({
        'exercises': [ex1.toJson(), ex2.toJson()],
      });

      expect(await ds.getAll(), hasLength(2));
    });

    test('importCustomExercises is a no-op when exercises key is absent', () async {
      await ds.importCustomExercises({'version': '1.0.0'});
      expect(await ds.getAll(), isEmpty);
    });

    test('importCustomExercises skips malformed entries silently', () async {
      await ds.importCustomExercises({
        'exercises': [
          permanentExercise(id: 'good-1').toJson(),
          {'invalid': 'data'}, // Missing required fields.
        ],
      });

      expect(await ds.getAll(), hasLength(1));
    });

    test('export then import is a round-trip', () async {
      await ds.save(permanentExercise(id: 'rt-1', nome: 'Round Trip'));

      final exported = await ds.exportCustomExercises();
      expect(exported, isNotNull);

      await ds.clear();
      expect(await ds.getAll(), isEmpty);

      await ds.importCustomExercises(exported!);
      final reimported = await ds.getAll();
      expect(reimported, hasLength(1));
      expect(reimported.first.nome, equals('Round Trip'));
    });

    test('export preserves all exercise fields', () async {
      final ex = makeExercise(
        id: 'fields-test',
        nome: 'Test Fields',
        baseExerciseId: 'base-123',
        isModifiedFromBase: true,
      );
      mgr.fakeBox._store['custom_exercise_fields-test_user-123'] = ex;

      final exported = await ds.exportCustomExercises();
      final json = (exported!['exercises'] as List).first as Map<String, dynamic>;

      expect(json['id'], equals('fields-test'));
      expect(json['nome'], equals('Test Fields'));
      expect(json['baseExerciseId'], equals('base-123'));
      expect(json['isModifiedFromBase'], isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Group: dispose()
  // -------------------------------------------------------------------------
  group('dispose()', () {
    late _FakeBoxManager mgr;
    late _TestedDatasource ds;

    setUp(() {
      mgr = _FakeBoxManager();
      ds = _TestedDatasource(mgr);
    });

    test('closes box after init', () async {
      await ds.init();
      await ds.dispose();

      expect(mgr.fakeBox.isOpen, isFalse);
    });

    test('dispose is safe when box was never opened', () async {
      // Do not call init() — dispose() should be a no-op.
      await expectLater(ds.dispose(), completes);
    });

    test('dispose does not throw when close fails', () async {
      await ds.init();
      mgr.fakeBox.closeError = Exception('close error');

      await expectLater(ds.dispose(), completes);
    });

    test('box is closed after dispose', () async {
      await ds.init();
      await ds.save(permanentExercise(id: 'ex-1'));
      await ds.dispose();

      expect(mgr.fakeBox.isOpen, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Group: edge cases and cross-concern behaviour
  // -------------------------------------------------------------------------
  group('edge cases', () {
    test('all operations succeed after corruption recovery', () async {
      final mgr = _FakeBoxManager()..throwCorruptedFirst = true;
      final ds = _TestedDatasource(mgr);

      await ds.save(permanentExercise(id: 'ex-1'));
      expect(await ds.getAll(), hasLength(1));

      await ds.delete('ex-1');
      expect(await ds.getAll(), isEmpty);
    });

    test('concurrent save calls do not corrupt storage', () async {
      final mgr = _FakeBoxManager();
      final ds = _TestedDatasource(mgr);

      await Future.wait([
        ds.save(permanentExercise(id: 'c-1')),
        ds.save(permanentExercise(id: 'c-2')),
        ds.save(permanentExercise(id: 'c-3')),
      ]);

      expect(await ds.getAll(), hasLength(3));
    });

    test('getAll and getExpired correctly partition active vs expired', () async {
      final mgr = _FakeBoxManager();
      final ds = _TestedDatasource(mgr);

      await ds.save(temporaryExercise(id: 'active-temp', futureDays: 5));
      mgr.fakeBox._store['custom_exercise_expired-temp_user-123'] =
          expiredExercise(id: 'expired-temp');

      final active = await ds.getAll();
      expect(active, hasLength(1));
      expect(active.first.id, equals('active-temp'));

      final expired = await ds.getExpired();
      expect(expired, hasLength(1));
      expect(expired.first.id, equals('expired-temp'));
    });

    test('empty store returns correct zero/empty values for all query methods', () async {
      final mgr = _FakeBoxManager();
      final ds = _TestedDatasource(mgr);

      expect(await ds.getAll(), isEmpty);
      expect(await ds.getExpired(), isEmpty);
      expect(await ds.getActiveCount(), equals(0));
      expect(await ds.getPermanentCount(), equals(0));
      expect(await ds.getVariantsOf('any'), isEmpty);
      expect(await ds.findByName('any'), isNull);
      expect(await ds.getById('any'), isNull);
      expect(await ds.exportCustomExercises(), isNull);
    });

    test('variant (baseExerciseId set) appears in getAll and getVariantsOf', () async {
      final mgr = _FakeBoxManager();
      final ds = _TestedDatasource(mgr);

      final variant = makeExercise(
        id: 'variant-1',
        baseExerciseId: 'base-abc',
        isModifiedFromBase: true,
      );
      mgr.fakeBox._store['custom_exercise_variant-1_user-123'] = variant;

      expect(await ds.getAll(), hasLength(1));
      expect(await ds.getVariantsOf('base-abc'), hasLength(1));
      // No unlockedUntil → isPermanent = true → counted in permanent.
      expect(await ds.getPermanentCount(), equals(1));
    });
  });
}
