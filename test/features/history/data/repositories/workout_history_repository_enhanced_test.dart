import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/sync_status.dart';

// -------------------------------------------------------------------------
// FakeBox: implementazione in-memory di Box<T> per i test
// -------------------------------------------------------------------------
class FakeBox<T> implements Box<T> {
  final Map<dynamic, T> _store = {};
  bool _isOpen = true;

  @override
  bool get isOpen => _isOpen;

  @override
  Iterable<dynamic> get keys => _store.keys;

  @override
  T? get(dynamic key, {T? defaultValue}) => _store[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, T value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key);
  }

  @override
  Future<int> clear() async {
    final count = _store.length;
    _store.clear();
    return count;
  }

  @override
  Future<void> flush() async {}

  @override
  bool containsKey(dynamic key) => _store.containsKey(key);

  @override
  int get length => _store.length;

  @override
  bool get isEmpty => _store.isEmpty;

  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  Iterable<T> get values => _store.values;

  @override
  Iterable<T> valuesBetween({dynamic startKey, dynamic endKey}) =>
      _store.values;

  @override
  Map<dynamic, T> toMap() => Map.from(_store);

  @override
  Future<void> putAll(Map<dynamic, T> entries) async {
    _store.addAll(entries);
  }

  @override
  Future<void> deleteAll(Iterable keys) async {
    for (final key in keys) {
      _store.remove(key);
    }
  }

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) async {
    final keys = <int>[];
    for (final v in values) {
      final key = _store.length;
      _store[key] = v;
      keys.add(key);
    }
    return keys;
  }

  @override
  Future<int> add(T value) async {
    final key = _store.length;
    _store[key] = value;
    return key;
  }

  @override
  Future<void> deleteAt(int index) async {
    final key = keys.elementAt(index);
    _store.remove(key);
  }

  @override
  Future<void> putAt(int index, T value) async {
    final key = keys.elementAt(index);
    _store[key] = value;
  }

  @override
  T getAt(int index) {
    return _store.values.elementAt(index);
  }

  @override
  dynamic keyAt(int index) => _store.keys.elementAt(index);

  @override
  Future<void> compact() async {}

  @override
  Future<void> close() async {
    _isOpen = false;
  }

  @override
  Future<void> deleteFromDisk() async {
    _store.clear();
    _isOpen = false;
  }

  @override
  String get name => 'fake_box';

  @override
  String? get path => null;

  @override
  bool get lazy => false;

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();
}

// -------------------------------------------------------------------------
// FakeHiveBoxManager: restituisce FakeBox per ogni nome box
// -------------------------------------------------------------------------
class FakeHiveBoxManager {
  final Map<String, FakeBox> _boxes = {};

  FakeBox getBox(String name) {
    _boxes.putIfAbsent(name, () => FakeBox());
    return _boxes[name]!;
  }

  Future<Box> openBox(String name) async => getBox(name);
  Future<Box<T>> openBoxTyped<T>(String name) async =>
      getBox(name) as Box<T>;
}

// -------------------------------------------------------------------------
// FakeFirebaseAuth: simula FirebaseAuth senza Firebase
// -------------------------------------------------------------------------
class FakeUser {
  const FakeUser({required this.uid});
  final String uid;
}

// Helper per creare WorkoutHistoryDetail nei test
SetHistoryDetail makeSet({
  int setNumber = 1,
  double weight = 100.0,
  int reps = 10,
  int rpe = 7,
}) {
  return SetHistoryDetail(
    setNumber: setNumber,
    weight: weight,
    reps: reps,
    rpe: rpe,
  );
}

ExerciseHistoryDetail makeExercise({
  String id = 'ex1',
  String name = 'Bench Press',
  String category = 'chest',
  List<SetHistoryDetail>? sets,
}) {
  return ExerciseHistoryDetail(
    id: id,
    name: name,
    category: category,
    sets: sets ?? [makeSet()],
    exerciseData: {},
  );
}

WorkoutHistoryDetail makeWorkout({
  String id = 'workout1',
  String userId = 'user1',
  String name = 'Test Workout',
  DateTime? completedAt,
  Duration duration = const Duration(minutes: 60),
  List<ExerciseHistoryDetail>? exercises,
  String? templateId,
}) {
  final now = DateTime(2024, 1, 15, 10, 0);
  return WorkoutHistoryDetail(
    id: id,
    userId: userId,
    name: name,
    description: '',
    createdAt: now,
    startedAt: now,
    completedAt: completedAt ?? now.add(duration),
    updatedAt: now,
    duration: duration,
    exercises: exercises ?? [makeExercise()],
    metadata: {},
    templateId: templateId,
  );
}

void main() {
  group('DatabaseFailure', () {
    test('crea con messaggio', () {
      const failure = DatabaseFailure('Test error');
      expect(failure.message, equals('Test error'));
    });

    test('uguaglianza basata su messaggio', () {
      const f1 = DatabaseFailure('Error');
      const f2 = DatabaseFailure('Error');
      expect(f1, equals(f2));
    });

    test('disuguaglianza per messaggi diversi', () {
      const f1 = DatabaseFailure('Error A');
      const f2 = DatabaseFailure('Error B');
      expect(f1, isNot(equals(f2)));
    });
  });

  group('WorkoutHistoryDetail - toMap / fromMap round-trip', () {
    test('salva e ripristina workout con exercises', () {
      final workout = makeWorkout(
        id: 'test_workout',
        userId: 'test_user',
        name: 'My Test',
        templateId: 'tmpl_123',
        exercises: [
          makeExercise(
            id: 'ex1',
            name: 'Squat',
            sets: [
              makeSet(weight: 120.0, reps: 5, rpe: 9),
              makeSet(setNumber: 2, weight: 120.0, reps: 5, rpe: 9),
            ],
          ),
        ],
      );

      final map = workout.toMap();
      final restored = WorkoutHistoryDetail.fromMap(map);

      expect(restored.id, equals('test_workout'));
      expect(restored.userId, equals('test_user'));
      expect(restored.name, equals('My Test'));
      expect(restored.templateId, equals('tmpl_123'));
      expect(restored.exercises.length, equals(1));
      expect(restored.exercises.first.sets.length, equals(2));
    });

    test('round-trip preserva la durata in minuti', () {
      final workout = makeWorkout(duration: const Duration(minutes: 90));
      final map = workout.toMap();
      final restored = WorkoutHistoryDetail.fromMap(map);

      expect(restored.duration.inMinutes, equals(90));
    });

    test('round-trip preserva metadata', () {
      final workout = makeWorkout();
      final workoutWithMeta = workout.copyWith(
        metadata: {'source': 'manual', 'version': 2},
      );
      final map = workoutWithMeta.toMap();
      final restored = WorkoutHistoryDetail.fromMap(map);

      expect(restored.metadata['source'], equals('manual'));
      expect(restored.metadata['version'], equals(2));
    });
  });

  group('SetHistoryDetail - toMap / fromMap round-trip', () {
    test('preserva tutti i campi inclusi quelli TUT', () {
      final startTime = DateTime(2024, 1, 15, 10, 0);
      final endTime = DateTime(2024, 1, 15, 10, 0, 30);

      final set = SetHistoryDetail(
        setNumber: 2,
        weight: 85.5,
        reps: 8,
        rpe: 7,
        restSeconds: 120,
        notes: 'Felt heavy',
        isWarmup: false,
        isDropSet: true,
        isFailure: false,
        setDurationMillis: 28500.0,
        setStartedAt: startTime,
        completedAt: endTime,
        actualReps: 7,
      );

      final map = set.toMap();
      final restored = SetHistoryDetail.fromMap(map);

      expect(restored.setNumber, equals(2));
      expect(restored.weight, equals(85.5));
      expect(restored.reps, equals(8));
      expect(restored.rpe, equals(7));
      expect(restored.restSeconds, equals(120));
      expect(restored.notes, equals('Felt heavy'));
      expect(restored.isDropSet, isTrue);
      expect(restored.setDurationMillis, equals(28500.0));
      expect(restored.actualReps, equals(7));
    });

    test('round-trip gestisce campi nulli', () {
      const set = SetHistoryDetail(
        setNumber: 1,
        weight: 60.0,
        reps: 15,
        rpe: 5,
      );

      final map = set.toMap();
      final restored = SetHistoryDetail.fromMap(map);

      expect(restored.restSeconds, isNull);
      expect(restored.notes, isNull);
      expect(restored.setDurationMillis, isNull);
      expect(restored.setStartedAt, isNull);
      expect(restored.completedAt, isNull);
      expect(restored.actualReps, isNull);
    });
  });

  group('ExerciseHistoryDetail - toMap / fromMap round-trip', () {
    test('preserva tutti i campi', () {
      final exercise = ExerciseHistoryDetail(
        id: 'ex_test',
        name: 'Romanian Deadlift',
        category: 'legs',
        notes: 'Focus on stretch',
        sets: [
          makeSet(weight: 80.0, reps: 12, rpe: 7),
          makeSet(setNumber: 2, weight: 80.0, reps: 10, rpe: 8),
        ],
        exerciseData: {
          'focus': ['FEMO', 'GLUT'],
          'equipment': 'barbell',
        },
      );

      final map = exercise.toMap();
      final restored = ExerciseHistoryDetail.fromMap(map);

      expect(restored.id, equals('ex_test'));
      expect(restored.name, equals('Romanian Deadlift'));
      expect(restored.category, equals('legs'));
      expect(restored.notes, equals('Focus on stretch'));
      expect(restored.sets.length, equals(2));
    });

    test('normalizza muscoli legacy durante fromMap', () {
      final map = {
        'id': 'ex1',
        'name': 'Curl',
        'category': 'arms',
        'sets': [],
        'exerciseData': {
          'focus': ['BIC', 'AVAMB'], // legacy
        },
      };

      final exercise = ExerciseHistoryDetail.fromMap(map);
      final focus = exercise.exerciseData['focus'] as List;

      expect(focus, contains('BICI')); // BIC -> BICI
      expect(focus, contains('AVA')); // AVAMB -> AVA
    });
  });

  group('SyncStatus - logica di stato', () {
    test('notSynced quando metadata non ha initial_sync_done', () {
      // Simulazione della logica currentSyncStatus
      bool hasInitialSync = false;
      DateTime? lastSyncTimestamp;

      SyncStatus computeStatus() {
        if (!hasInitialSync) return SyncStatus.notSynced;
        if (lastSyncTimestamp == null) return SyncStatus.notSynced;
        final hours = DateTime.now().difference(lastSyncTimestamp!).inHours;
        if (hours > 24) return SyncStatus.needsSync;
        return SyncStatus.synced;
      }

      expect(computeStatus(), equals(SyncStatus.notSynced));
    });

    test('synced dopo sync recente', () {
      bool hasInitialSync = true;
      DateTime? lastSyncTimestamp = DateTime.now().subtract(
        const Duration(hours: 2),
      );

      SyncStatus computeStatus() {
        if (!hasInitialSync) return SyncStatus.notSynced;
        if (lastSyncTimestamp == null) return SyncStatus.notSynced;
        final hours = DateTime.now().difference(lastSyncTimestamp!).inHours;
        if (hours > 24) return SyncStatus.needsSync;
        return SyncStatus.synced;
      }

      expect(computeStatus(), equals(SyncStatus.synced));
    });

    test('needsSync dopo 24+ ore', () {
      bool hasInitialSync = true;
      DateTime? lastSyncTimestamp = DateTime.now().subtract(
        const Duration(hours: 25),
      );

      SyncStatus computeStatus() {
        if (!hasInitialSync) return SyncStatus.notSynced;
        if (lastSyncTimestamp == null) return SyncStatus.notSynced;
        final hours = DateTime.now().difference(lastSyncTimestamp!).inHours;
        if (hours > 24) return SyncStatus.needsSync;
        return SyncStatus.synced;
      }

      expect(computeStatus(), equals(SyncStatus.needsSync));
    });
  });

  group('WorkoutHistoryDetail - proprietà computate', () {
    test('totalVolume con più esercizi e set', () {
      final workout = makeWorkout(
        exercises: [
          makeExercise(
            id: 'ex1',
            sets: [
              makeSet(weight: 100.0, reps: 5), // 500
              makeSet(setNumber: 2, weight: 100.0, reps: 5), // 500
            ],
          ),
          makeExercise(
            id: 'ex2',
            sets: [
              makeSet(weight: 80.0, reps: 10), // 800
            ],
          ),
        ],
      );

      expect(workout.totalVolume, equals(1800.0));
    });

    test('totalSets conta correttamente', () {
      final workout = makeWorkout(
        exercises: [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(), makeSet(setNumber: 2), makeSet(setNumber: 3)],
          ),
          makeExercise(
            id: 'ex2',
            sets: [makeSet(), makeSet(setNumber: 2)],
          ),
        ],
      );

      expect(workout.totalSets, equals(5));
    });

    test('totalReps conta correttamente', () {
      final workout = makeWorkout(
        exercises: [
          makeExercise(
            id: 'ex1',
            sets: [makeSet(reps: 10), makeSet(reps: 8, setNumber: 2)],
          ),
        ],
      );

      expect(workout.totalReps, equals(18));
    });

    test('averageRPE con set misti (alcuni senza RPE)', () {
      final workout = makeWorkout(
        exercises: [
          makeExercise(
            id: 'ex1',
            sets: [
              makeSet(rpe: 8),
              makeSet(rpe: 0, setNumber: 2), // escluso
              makeSet(rpe: 7, setNumber: 3),
            ],
          ),
        ],
      );

      // (8 + 7) / 2 = 7.5
      expect(workout.averageRPE, equals(7.5));
    });
  });

  group('FakeBox - operazioni base', () {
    test('put e get funzionano correttamente', () async {
      final box = FakeBox<String>();

      await box.put('key1', 'value1');
      expect(box.get('key1'), equals('value1'));
    });

    test('delete rimuove la chiave', () async {
      final box = FakeBox<String>();

      await box.put('key1', 'value1');
      await box.delete('key1');
      expect(box.get('key1'), isNull);
    });

    test('clear svuota il box', () async {
      final box = FakeBox<String>();

      await box.put('k1', 'v1');
      await box.put('k2', 'v2');
      await box.clear();

      expect(box.isEmpty, isTrue);
    });

    test('keys restituisce tutte le chiavi', () async {
      final box = FakeBox<String>();

      await box.put('k1', 'v1');
      await box.put('k2', 'v2');

      expect(box.keys, containsAll(['k1', 'k2']));
    });

    test('containsKey funziona', () async {
      final box = FakeBox<String>();

      await box.put('exists', 'value');

      expect(box.containsKey('exists'), isTrue);
      expect(box.containsKey('not_exists'), isFalse);
    });

    test('defaultValue restituito quando chiave non esiste', () async {
      final box = FakeBox<String>();
      expect(box.get('missing', defaultValue: 'default'), equals('default'));
    });
  });

  group('WorkoutHistoryDetail - storeKey format', () {
    test('formato chiave include userId e workoutId', () {
      const userId = 'user123';
      const workoutId = 'workout456';
      final expectedKey = 'workout_${userId}_$workoutId';

      expect(expectedKey, equals('workout_user123_workout456'));
    });

    test('chiave legacy non include userId', () {
      const workoutId = 'workout456';
      final legacyKey = 'workout_$workoutId';

      expect(legacyKey, equals('workout_workout456'));
    });

    test('filtra chiavi per prefisso utente', () {
      const userId = 'user1';
      const otherUserId = 'user2';
      final keys = [
        'workout_${userId}_w1',
        'workout_${userId}_w2',
        'workout_${otherUserId}_w3',
        'workout_legacy',
        'other_key',
      ];

      final userPrefix = 'workout_${userId}_';
      final userKeys = keys.where((k) => k.startsWith(userPrefix)).toList();

      expect(userKeys.length, equals(2));
      expect(userKeys, contains('workout_user1_w1'));
      expect(userKeys, contains('workout_user1_w2'));
    });
  });
}
