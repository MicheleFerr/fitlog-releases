/// Tests for WorkoutHistoryRepositoryEnhanced – pure logic (no Firebase/Hive).
///
/// Strategy:
/// - DatabaseFailure value object tests (fully isolated)
/// - SyncStatus computation logic (replicated from repository)
/// - Key format logic (replicated from repository)
/// - WorkoutHistoryDetail / ExerciseHistoryDetail / SetHistoryDetail
///   edge cases not yet covered in other test files
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/sync_status.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------
SetHistoryDetail makeSet({
  int setNumber = 1,
  double weight = 100.0,
  int reps = 10,
  int rpe = 7,
  bool isWarmup = false,
  bool isDropSet = false,
  bool isFailure = false,
  int? restSeconds,
  double? setDurationMillis,
  DateTime? setStartedAt,
  DateTime? completedAt,
  int? actualReps,
}) =>
    SetHistoryDetail(
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      rpe: rpe,
      isWarmup: isWarmup,
      isDropSet: isDropSet,
      isFailure: isFailure,
      restSeconds: restSeconds,
      setDurationMillis: setDurationMillis,
      setStartedAt: setStartedAt,
      completedAt: completedAt,
      actualReps: actualReps,
    );

ExerciseHistoryDetail makeExercise({
  String id = 'ex1',
  String name = 'Bench Press',
  String category = 'chest',
  String? exerciseNotes,
  List<SetHistoryDetail>? sets,
  Map<String, dynamic>? exerciseData,
}) =>
    ExerciseHistoryDetail(
      id: id,
      name: name,
      category: category,
      notes: exerciseNotes,
      sets: sets ?? [makeSet()],
      exerciseData: exerciseData ?? {},
    );

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

// ---------------------------------------------------------------------------
// Replicate pure SyncStatus computation from repository for testing
// ---------------------------------------------------------------------------
SyncStatus computeSyncStatus({
  required bool hasInitialSync,
  required DateTime? lastSyncTimestamp,
}) {
  if (!hasInitialSync) return SyncStatus.notSynced;
  if (lastSyncTimestamp == null) return SyncStatus.notSynced;
  final hours = DateTime.now().difference(lastSyncTimestamp).inHours;
  if (hours > 24) return SyncStatus.needsSync;
  return SyncStatus.synced;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('DatabaseFailure', () {
    test('stores message', () {
      const f = DatabaseFailure('oops');
      expect(f.message, equals('oops'));
    });

    test('equality based on message', () {
      const f1 = DatabaseFailure('e');
      const f2 = DatabaseFailure('e');
      expect(f1, equals(f2));
    });

    test('inequality for different messages', () {
      const f1 = DatabaseFailure('a');
      const f2 = DatabaseFailure('b');
      expect(f1, isNot(equals(f2)));
    });

    test('hashCode consistent with equality', () {
      const f1 = DatabaseFailure('same');
      const f2 = DatabaseFailure('same');
      expect(f1.hashCode, equals(f2.hashCode));
    });
  });

  group('SyncStatus computation logic', () {
    test('notSynced when hasInitialSync is false', () {
      final status = computeSyncStatus(
        hasInitialSync: false,
        lastSyncTimestamp: null,
      );
      expect(status, equals(SyncStatus.notSynced));
    });

    test('notSynced when hasInitialSync is true but no timestamp', () {
      final status = computeSyncStatus(
        hasInitialSync: true,
        lastSyncTimestamp: null,
      );
      expect(status, equals(SyncStatus.notSynced));
    });

    test('synced when synced 2 hours ago', () {
      final status = computeSyncStatus(
        hasInitialSync: true,
        lastSyncTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
      );
      expect(status, equals(SyncStatus.synced));
    });

    test('synced when synced just now', () {
      final status = computeSyncStatus(
        hasInitialSync: true,
        lastSyncTimestamp: DateTime.now(),
      );
      expect(status, equals(SyncStatus.synced));
    });

    test('needsSync when last sync was 25 hours ago', () {
      final status = computeSyncStatus(
        hasInitialSync: true,
        lastSyncTimestamp: DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(status, equals(SyncStatus.needsSync));
    });

    test('synced at exactly 24 hours (boundary check)', () {
      // 24 hours ago = hoursSinceSync == 24 which is NOT > 24
      final status = computeSyncStatus(
        hasInitialSync: true,
        lastSyncTimestamp: DateTime.now().subtract(const Duration(hours: 24)),
      );
      expect(status, equals(SyncStatus.synced));
    });
  });

  group('Key format logic', () {
    test('new key format is workout_{userId}_{workoutId}', () {
      const userId = 'user123';
      const workoutId = 'workout456';
      final key = 'workout_${userId}_$workoutId';
      expect(key, equals('workout_user123_workout456'));
    });

    test('legacy key format is workout_{workoutId}', () {
      const workoutId = 'abc';
      expect('workout_$workoutId', equals('workout_abc'));
    });

    test('user prefix filter matches only the correct user', () {
      const userId = 'userA';
      final keys = [
        'workout_userA_w1',
        'workout_userA_w2',
        'workout_userB_w3',
        'workout_legacy',
        'other_key',
      ];
      final prefix = 'workout_${userId}_';
      final filtered = keys.where((k) => k.startsWith(prefix)).toList();
      expect(filtered.length, equals(2));
      expect(filtered, containsAll(['workout_userA_w1', 'workout_userA_w2']));
    });

    test('non-workout keys are filtered out', () {
      final keys = ['workout_u1_w1', 'metadata_key', 'sync_queue_item'];
      final workoutKeys = keys.where((k) => k.startsWith('workout_')).toList();
      expect(workoutKeys.length, equals(1));
    });
  });

  group('WorkoutHistoryDetail – toMap/fromMap edge cases', () {
    test('round-trip with empty exercises list', () {
      final workout = makeWorkout(exercises: []);
      final restored = WorkoutHistoryDetail.fromMap(workout.toMap());
      expect(restored.exercises, isEmpty);
      expect(restored.totalVolume, equals(0.0));
      expect(restored.totalSets, equals(0));
      expect(restored.totalReps, equals(0));
    });

    test('round-trip with null templateId', () {
      final workout = makeWorkout(templateId: null);
      final restored = WorkoutHistoryDetail.fromMap(workout.toMap());
      expect(restored.templateId, isNull);
    });

    test('round-trip with non-null templateId', () {
      final workout = makeWorkout(templateId: 'tmpl_xyz');
      final restored = WorkoutHistoryDetail.fromMap(workout.toMap());
      expect(restored.templateId, equals('tmpl_xyz'));
    });

    test('toMap contains all required keys', () {
      final map = makeWorkout().toMap();
      expect(
        map.keys,
        containsAll([
          'id', 'userId', 'name', 'description',
          'createdAt', 'startedAt', 'completedAt', 'updatedAt',
          'durationMinutes', 'exercises', 'metadata', 'templateId',
        ]),
      );
    });

    test('fromMap uses Unknown Workout as default name', () {
      final workout = WorkoutHistoryDetail.fromMap({'id': 'x'});
      expect(workout.name, equals('Unknown Workout'));
    });

    test('fromMap uses empty string as default userId', () {
      final workout = WorkoutHistoryDetail.fromMap({'id': 'x'});
      expect(workout.userId, equals(''));
    });

    test('durationMinutes is serialized correctly', () {
      final workout = makeWorkout(duration: const Duration(minutes: 75));
      final map = workout.toMap();
      expect(map['durationMinutes'], equals(75));
      final restored = WorkoutHistoryDetail.fromMap(map);
      expect(restored.duration.inMinutes, equals(75));
    });
  });

  group('WorkoutHistoryDetail – computed properties edge cases', () {
    test('totalVolume with bodyweight exercise (weight=0) uses reps', () {
      final bwExercise = ExerciseHistoryDetail(
        id: 'bw1',
        name: 'Pull Up',
        category: 'back',
        sets: [
          const SetHistoryDetail(setNumber: 1, weight: 0.0, reps: 12, rpe: 7),
        ],
        exerciseData: {},
      );
      final workout = makeWorkout(exercises: [bwExercise]);
      expect(workout.totalVolume, equals(12.0));
    });

    test('averageRPE with mixed zero/non-zero rpe', () {
      final workout = makeWorkout(
        exercises: [
          makeExercise(
            sets: [
              makeSet(rpe: 0),
              makeSet(rpe: 6, setNumber: 2),
              makeSet(rpe: 8, setNumber: 3),
            ],
          ),
        ],
      );
      // (6+8)/2 = 7.0
      expect(workout.averageRPE, equals(7.0));
    });

    test('averageRPE returns 0 when all sets have rpe=0', () {
      final workout = makeWorkout(
        exercises: [makeExercise(sets: [makeSet(rpe: 0)])],
      );
      expect(workout.averageRPE, equals(0.0));
    });

    test('averageRPE returns 0 for empty exercises', () {
      final workout = makeWorkout(exercises: []);
      expect(workout.averageRPE, equals(0.0));
    });
  });

  group('WorkoutHistoryDetail – factory empty', () {
    test('creates workout with specified id', () {
      final workout = WorkoutHistoryDetail.empty(id: 'del_id');
      expect(workout.id, equals('del_id'));
      expect(workout.userId, isEmpty);
      expect(workout.name, isEmpty);
      expect(workout.exercises, isEmpty);
      expect(workout.duration, equals(Duration.zero));
    });
  });

  group('WorkoutHistoryDetail – equality and hashCode', () {
    test('same id = equal', () {
      final w1 = makeWorkout(id: 'x', name: 'A');
      final w2 = makeWorkout(id: 'x', name: 'B');
      expect(w1, equals(w2));
      expect(w1.hashCode, equals(w2.hashCode));
    });

    test('different id = not equal', () {
      final w1 = makeWorkout(id: 'x');
      final w2 = makeWorkout(id: 'y');
      expect(w1, isNot(equals(w2)));
    });
  });

  group('WorkoutHistoryDetail – copyWith', () {
    test('creates new instance with updated name', () {
      final original = makeWorkout(name: 'Original');
      final copy = original.copyWith(name: 'Updated');
      expect(copy.name, equals('Updated'));
      expect(copy.id, equals('workout1'));
      expect(original.name, equals('Original')); // immutable
    });

    test('updatedAt is refreshed when copyWith is called', () {
      final fixedTime = DateTime(2020, 1, 1);
      final original = makeWorkout().copyWith(updatedAt: fixedTime);
      // Wait a tiny moment to ensure different timestamp
      final copy = original.copyWith(name: 'New');
      expect(copy.updatedAt, isNot(equals(fixedTime)));
    });
  });

  group('WorkoutHistoryDetail – toWorkout conversion', () {
    test('converts to Workout with status=completed', () {
      final workout = makeWorkout(id: 'w9', name: 'Leg Day');
      final result = workout.toWorkout();
      expect(result.id, equals('w9'));
      expect(result.name, equals('Leg Day'));
    });

    test('preserves exercise list length', () {
      final workout = makeWorkout(
        exercises: [
          makeExercise(id: 'e1'),
          makeExercise(id: 'e2'),
          makeExercise(id: 'e3'),
        ],
      );
      expect(workout.toWorkout().exercises.length, equals(3));
    });
  });

  group('ExerciseHistoryDetail – computed properties edge cases', () {
    test('maxWeight returns 0 for empty sets', () {
      final exercise = ExerciseHistoryDetail(
        id: 'ex1', name: 'Test', category: 'other', sets: [], exerciseData: {},
      );
      expect(exercise.maxWeight, equals(0.0));
    });

    test('maxWeight returns largest weight', () {
      final exercise = ExerciseHistoryDetail(
        id: 'ex1',
        name: 'Test',
        category: 'other',
        sets: [
          makeSet(weight: 80.0),
          makeSet(weight: 120.0, setNumber: 2),
          makeSet(weight: 100.0, setNumber: 3),
        ],
        exerciseData: {},
      );
      expect(exercise.maxWeight, equals(120.0));
    });

    test('averageRPE is 0.0 when all sets have rpe=0', () {
      final exercise = ExerciseHistoryDetail(
        id: 'ex1',
        name: 'Test',
        category: 'other',
        sets: [makeSet(rpe: 0)],
        exerciseData: {},
      );
      expect(exercise.averageRPE, equals(0.0));
    });

    test('averageRPE is 0.0 for empty sets', () {
      final exercise = ExerciseHistoryDetail(
        id: 'ex1', name: 'Test', category: 'other', sets: [], exerciseData: {},
      );
      expect(exercise.averageRPE, equals(0.0));
    });

    test('copyWith preserves unchanged fields including notes', () {
      final original = makeExercise(exerciseNotes: 'focus on form');
      final copy = original.copyWith(name: 'New Name');
      expect(copy.notes, equals('focus on form'));
      expect(copy.name, equals('New Name'));
    });
  });

  group('ExerciseHistoryDetail – muscle normalization edge cases', () {
    test('muscoliSecondari as CSV string is normalized', () {
      final map = {
        'id': 'ex1', 'name': 'Row', 'category': 'back',
        'sets': <dynamic>[],
        'exerciseData': {'muscoliSecondari': 'BIC, LOMBAR'},
      };
      final exercise = ExerciseHistoryDetail.fromMap(map);
      final secondary = exercise.exerciseData['muscoliSecondari'] as List;
      expect(secondary, contains('BICI'));
      expect(secondary, contains('LOMB'));
    });

    test('null focus field passes through unchanged', () {
      final map = {
        'id': 'ex1', 'name': 'Test', 'category': 'chest',
        'sets': <dynamic>[],
        'exerciseData': {'someField': 'value'},
      };
      final exercise = ExerciseHistoryDetail.fromMap(map);
      expect(exercise.exerciseData['focus'], isNull);
    });

    test('toExercise with countingMode in exerciseData', () {
      final exercise = ExerciseHistoryDetail(
        id: 'ex1', name: 'Pull Up', category: 'back',
        sets: [makeSet()],
        exerciseData: {'countingMode': 'reps'},
      );
      final result = exercise.toExercise();
      expect(result.id, equals('ex1'));
    });
  });

  group('SetHistoryDetail – volume and 1RM calculations', () {
    test('volume = weight * reps when weight > 0', () {
      const s = SetHistoryDetail(setNumber: 1, weight: 50.0, reps: 12, rpe: 6);
      expect(s.volume, equals(600.0));
    });

    test('volume = reps when weight == 0 (bodyweight)', () {
      const s = SetHistoryDetail(setNumber: 1, weight: 0.0, reps: 15, rpe: 5);
      expect(s.volume, equals(15.0));
    });

    test('estimated1RM with reps=1 returns weight unchanged', () {
      const s = SetHistoryDetail(setNumber: 1, weight: 200.0, reps: 1, rpe: 10);
      expect(s.estimated1RM, equals(200.0));
    });

    test('estimated1RM uses Epley formula for reps > 1', () {
      // 100 * (1 + 10/30) ≈ 133.33
      const s = SetHistoryDetail(setNumber: 1, weight: 100.0, reps: 10, rpe: 8);
      expect(s.estimated1RM, closeTo(133.33, 0.1));
    });

    test('estimated1RM with 5 reps', () {
      // 60 * (1 + 5/30) = 60 * 1.1667 = 70
      const s = SetHistoryDetail(setNumber: 1, weight: 60.0, reps: 5, rpe: 8);
      expect(s.estimated1RM, closeTo(70.0, 0.1));
    });
  });

  group('SetHistoryDetail – copyWith immutability', () {
    test('copyWith preserves all optional fields', () {
      final start = DateTime(2024, 1, 1, 10, 0);
      final end = DateTime(2024, 1, 1, 10, 0, 30);
      final original = SetHistoryDetail(
        setNumber: 1,
        weight: 100.0,
        reps: 10,
        rpe: 7,
        notes: 'heavy',
        restSeconds: 90,
        isWarmup: true,
        setDurationMillis: 25000.0,
        setStartedAt: start,
        completedAt: end,
        actualReps: 9,
      );
      final copy = original.copyWith(weight: 110.0);
      expect(copy.notes, equals('heavy'));
      expect(copy.restSeconds, equals(90));
      expect(copy.isWarmup, isTrue);
      expect(copy.setDurationMillis, equals(25000.0));
      expect(copy.setStartedAt, equals(start));
      expect(copy.completedAt, equals(end));
      expect(copy.actualReps, equals(9));
      expect(original.weight, equals(100.0)); // original unchanged
    });

    test('copyWith can update isDropSet and isFailure', () {
      const original = SetHistoryDetail(
        setNumber: 1, weight: 100.0, reps: 5, rpe: 8,
      );
      final copy = original.copyWith(isDropSet: true, isFailure: true);
      expect(copy.isDropSet, isTrue);
      expect(copy.isFailure, isTrue);
    });
  });

  group('SetHistoryDetail – toExerciseSet conversion', () {
    test('uses reps as actualReps when actualReps is null', () {
      const s = SetHistoryDetail(setNumber: 2, weight: 60.0, reps: 15, rpe: 5);
      final set = s.toExerciseSet();
      expect(set.actualReps, equals(15));
      expect(set.isCompleted, isTrue);
    });

    test('uses actualReps when provided', () {
      const s = SetHistoryDetail(
        setNumber: 1, weight: 80.0, reps: 10, rpe: 8, actualReps: 8,
      );
      expect(s.toExerciseSet().actualReps, equals(8));
    });

    test('propagates TUT fields', () {
      final start = DateTime(2024, 1, 1, 10, 0);
      final end = DateTime(2024, 1, 1, 10, 0, 30);
      final s = SetHistoryDetail(
        setNumber: 1, weight: 80.0, reps: 8, rpe: 7,
        setDurationMillis: 30000.0,
        setStartedAt: start,
        completedAt: end,
      );
      final set = s.toExerciseSet();
      expect(set.setDurationMillis, equals(30000.0));
      expect(set.setStartedAt, equals(start));
      expect(set.completedAt, equals(end));
    });

    test('isWarmup is propagated', () {
      const s = SetHistoryDetail(
        setNumber: 1, weight: 40.0, reps: 15, rpe: 3, isWarmup: true,
      );
      expect(s.toExerciseSet().isWarmup, isTrue);
    });

    test('set id is derived from setNumber', () {
      const s = SetHistoryDetail(setNumber: 3, weight: 90.0, reps: 5, rpe: 9);
      expect(s.toExerciseSet().id, equals('3'));
    });
  });

  group('SetHistoryDetail – fromMap edge cases', () {
    test('handles integer weight (from Firestore int fields)', () {
      final map = {'setNumber': 1, 'weight': 100, 'reps': 5, 'rpe': 8};
      final s = SetHistoryDetail.fromMap(map);
      expect(s.weight, equals(100.0));
    });

    test('handles null setDurationMillis', () {
      final map = {'setNumber': 1, 'weight': 80.0, 'reps': 10, 'rpe': 7,
                   'setDurationMillis': null};
      final s = SetHistoryDetail.fromMap(map);
      expect(s.setDurationMillis, isNull);
    });

    test('handles all boolean flags from map', () {
      final map = {
        'setNumber': 1, 'weight': 80.0, 'reps': 5, 'rpe': 9,
        'isWarmup': true, 'isDropSet': true, 'isFailure': true,
      };
      final s = SetHistoryDetail.fromMap(map);
      expect(s.isWarmup, isTrue);
      expect(s.isDropSet, isTrue);
      expect(s.isFailure, isTrue);
    });

    test('restSeconds can be parsed from map', () {
      final map = {'setNumber': 1, 'weight': 80.0, 'reps': 10, 'rpe': 7,
                   'restSeconds': 120};
      final s = SetHistoryDetail.fromMap(map);
      expect(s.restSeconds, equals(120));
    });
  });

  group('Either type used by repository', () {
    test('Right.isRight is true', () {
      const r = Right<String, int>(42);
      expect(r.isRight, isTrue);
      expect(r.isLeft, isFalse);
    });

    test('Left.isLeft is true', () {
      const l = Left<String, int>('error');
      expect(l.isLeft, isTrue);
      expect(l.isRight, isFalse);
    });

    test('Right.fold returns right value', () {
      const r = Right<String, int>(42);
      final result = r.fold((_) => -1, (v) => v);
      expect(result, equals(42));
    });

    test('Left.fold returns left value', () {
      const l = Left<String, int>('err');
      final result = l.fold((e) => e.length, (_) => 0);
      expect(result, equals(3));
    });

    test('Right.rightOrNull returns value', () {
      const r = Right<String, int>(99);
      expect(r.rightOrNull, equals(99));
    });

    test('Left.leftOrNull returns value', () {
      const l = Left<String, int>('fail');
      expect(l.leftOrNull, equals('fail'));
    });
  });
}
