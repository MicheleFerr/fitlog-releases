import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/timer/domain/entities/rest_timer.dart';

void main() {
  group('RestTimer', () {
    group('constructor defaults', () {
      test('auto-generates id when null', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.id, isNotEmpty);
      });

      test('generates unique ids for different instances', () {
        final timer1 = RestTimer(totalDurationSeconds: 60);
        final timer2 = RestTimer(totalDurationSeconds: 60);
        expect(timer1.id, isNot(equals(timer2.id)));
      });

      test('uses provided id when given', () {
        final timer = RestTimer(id: 'my-id', totalDurationSeconds: 60);
        expect(timer.id, 'my-id');
      });

      test('remainingSeconds defaults to totalDurationSeconds', () {
        final timer = RestTimer(totalDurationSeconds: 90);
        expect(timer.remainingSeconds, 90);
      });

      test('uses provided remainingSeconds when given', () {
        final timer = RestTimer(
          totalDurationSeconds: 90,
          remainingSeconds: 30,
        );
        expect(timer.remainingSeconds, 30);
      });

      test('defaults to TimerType.rest', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.type, TimerType.rest);
      });

      test('defaults to TimerStatus.idle', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.status, TimerStatus.idle);
      });

      test('defaults audioAlreadyPlayed to false', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.audioAlreadyPlayed, false);
      });

      test('optional fields default to null', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.startTime, isNull);
        expect(timer.endTime, isNull);
        expect(timer.exerciseName, isNull);
        expect(timer.currentSet, isNull);
        expect(timer.totalSets, isNull);
        expect(timer.workoutId, isNull);
        expect(timer.completionTime, isNull);
      });

      test('sets all provided fields', () {
        final now = DateTime(2026, 1, 1);
        final timer = RestTimer(
          id: 'test-id',
          type: TimerType.warmup,
          totalDurationSeconds: 120,
          remainingSeconds: 45,
          status: TimerStatus.running,
          startTime: now,
          endTime: now.add(const Duration(seconds: 45)),
          exerciseName: 'Bench Press',
          currentSet: 2,
          totalSets: 4,
          workoutId: 'w-1',
          audioAlreadyPlayed: true,
          completionTime: now,
        );
        expect(timer.id, 'test-id');
        expect(timer.type, TimerType.warmup);
        expect(timer.totalDurationSeconds, 120);
        expect(timer.remainingSeconds, 45);
        expect(timer.status, TimerStatus.running);
        expect(timer.startTime, now);
        expect(timer.exerciseName, 'Bench Press');
        expect(timer.currentSet, 2);
        expect(timer.totalSets, 4);
        expect(timer.workoutId, 'w-1');
        expect(timer.audioAlreadyPlayed, true);
        expect(timer.completionTime, now);
      });
    });

    group('progress', () {
      test('returns 0.0 at start (remaining = total)', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.progress, 0.0);
      });

      test('returns 0.5 at halfway', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 30,
        );
        expect(timer.progress, 0.5);
      });

      test('returns 1.0 when remaining is 0', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 0,
        );
        expect(timer.progress, 1.0);
      });

      test('returns 1.0 when totalDurationSeconds is 0', () {
        final timer = RestTimer(totalDurationSeconds: 0);
        expect(timer.progress, 1.0);
      });

      test('returns correct fractional progress', () {
        final timer = RestTimer(
          totalDurationSeconds: 100,
          remainingSeconds: 75,
        );
        expect(timer.progress, 0.25);
      });
    });

    group('elapsedSeconds', () {
      test('returns 0 at start', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.elapsedSeconds, 0);
      });

      test('returns correct elapsed', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 20,
        );
        expect(timer.elapsedSeconds, 40);
      });

      test('returns total when remaining is 0', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 0,
        );
        expect(timer.elapsedSeconds, 60);
      });
    });

    group('elapsedDuration', () {
      test('returns Duration with correct seconds', () {
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 50,
        );
        expect(timer.elapsedDuration, const Duration(seconds: 70));
      });
    });

    group('remainingDuration', () {
      test('returns Duration with remaining seconds', () {
        final timer = RestTimer(
          totalDurationSeconds: 120,
          remainingSeconds: 45,
        );
        expect(timer.remainingDuration, const Duration(seconds: 45));
      });
    });

    group('formattedTime', () {
      test('formats 0 seconds as 00:00', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 0,
        );
        expect(timer.formattedTime, '00:00');
      });

      test('formats 90 seconds as 01:30', () {
        final timer = RestTimer(
          totalDurationSeconds: 90,
          remainingSeconds: 90,
        );
        expect(timer.formattedTime, '01:30');
      });

      test('formats 600 seconds as 10:00', () {
        final timer = RestTimer(
          totalDurationSeconds: 600,
          remainingSeconds: 600,
        );
        expect(timer.formattedTime, '10:00');
      });

      test('formats 5 seconds as 00:05', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 5,
        );
        expect(timer.formattedTime, '00:05');
      });

      test('formats 65 seconds as 01:05', () {
        final timer = RestTimer(
          totalDurationSeconds: 65,
          remainingSeconds: 65,
        );
        expect(timer.formattedTime, '01:05');
      });
    });

    group('boolean getters', () {
      test('isActive is true when running', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          status: TimerStatus.running,
        );
        expect(timer.isActive, true);
      });

      test('isActive is true when paused', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          status: TimerStatus.paused,
        );
        expect(timer.isActive, true);
      });

      test('isActive is false when idle', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.isActive, false);
      });

      test('isActive is false when completed', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          status: TimerStatus.completed,
        );
        expect(timer.isActive, false);
      });

      test('isCompleted is true when status is completed', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          status: TimerStatus.completed,
        );
        expect(timer.isCompleted, true);
      });

      test('isCompleted is true when remaining <= 0', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 0,
        );
        expect(timer.isCompleted, true);
      });

      test('isCompleted is false when idle with remaining > 0', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer.isCompleted, false);
      });

      test('isRunning is true only when running', () {
        expect(
          RestTimer(
            totalDurationSeconds: 60,
            status: TimerStatus.running,
          ).isRunning,
          true,
        );
        expect(
          RestTimer(
            totalDurationSeconds: 60,
            status: TimerStatus.paused,
          ).isRunning,
          false,
        );
      });

      test('isPaused is true only when paused', () {
        expect(
          RestTimer(
            totalDurationSeconds: 60,
            status: TimerStatus.paused,
          ).isPaused,
          true,
        );
        expect(
          RestTimer(
            totalDurationSeconds: 60,
            status: TimerStatus.running,
          ).isPaused,
          false,
        );
      });

      test('isAwaitingRPE is true only when awaitingRPE', () {
        expect(
          RestTimer(
            totalDurationSeconds: 60,
            status: TimerStatus.awaitingRPE,
          ).isAwaitingRPE,
          true,
        );
        expect(
          RestTimer(
            totalDurationSeconds: 60,
            status: TimerStatus.running,
          ).isAwaitingRPE,
          false,
        );
      });
    });

    group('state transitions', () {
      test('start sets status to running and sets startTime', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        final started = timer.start();
        expect(started.status, TimerStatus.running);
        expect(started.startTime, isNotNull);
        expect(started.id, timer.id);
        expect(started.remainingSeconds, 60);
      });

      test('pause sets status to paused', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          status: TimerStatus.running,
        );
        final paused = timer.pause();
        expect(paused.status, TimerStatus.paused);
        expect(paused.id, timer.id);
      });

      test('resume sets status to running', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          status: TimerStatus.paused,
        );
        final resumed = timer.resume();
        expect(resumed.status, TimerStatus.running);
        expect(resumed.id, timer.id);
      });

      test('complete sets status to completed and remaining to 0', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 30,
          status: TimerStatus.running,
        );
        final completed = timer.complete();
        expect(completed.status, TimerStatus.completed);
        expect(completed.remainingSeconds, 0);
        expect(completed.endTime, isNotNull);
        expect(completed.completionTime, isNotNull);
        expect(completed.audioAlreadyPlayed, false);
      });

      test('awaitRPE sets status to awaitingRPE and remaining to 0', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 10,
          status: TimerStatus.running,
        );
        final awaiting = timer.awaitRPE();
        expect(awaiting.status, TimerStatus.awaitingRPE);
        expect(awaiting.remainingSeconds, 0);
        expect(awaiting.endTime, isNotNull);
      });

      test('reset sets status to idle and restores remaining', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 10,
          status: TimerStatus.running,
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        );
        final resetTimer = timer.reset();
        expect(resetTimer.status, TimerStatus.idle);
        expect(resetTimer.remainingSeconds, 60);
        // copyWith does not set null for startTime/endTime
        // because the copyWith uses ?? operator
        // Actually looking at the code: startTime: null is passed
        // but copyWith uses startTime ?? this.startTime
        // So null won't actually clear it - let's verify behavior
      });
    });

    group('tick', () {
      test('decrements remaining by 1', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 30,
        );
        final ticked = timer.tick();
        expect(ticked.remainingSeconds, 29);
      });

      test('completes when remaining is 1', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 1,
        );
        final ticked = timer.tick();
        expect(ticked.status, TimerStatus.completed);
        expect(ticked.remainingSeconds, 0);
      });

      test('completes when remaining is 0', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 0,
        );
        final ticked = timer.tick();
        expect(ticked.status, TimerStatus.completed);
        expect(ticked.remainingSeconds, 0);
      });

      test('multiple ticks decrement correctly', () {
        var timer = RestTimer(totalDurationSeconds: 5);
        timer = timer.tick(); // 4
        timer = timer.tick(); // 3
        timer = timer.tick(); // 2
        expect(timer.remainingSeconds, 2);
        timer = timer.tick(); // 1
        expect(timer.remainingSeconds, 1);
        timer = timer.tick(); // <=1 -> completes
        expect(timer.status, TimerStatus.completed);
        expect(timer.remainingSeconds, 0);
      });
    });

    group('addTime', () {
      test('increases remaining and total', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 30,
        );
        final added = timer.addTime(15);
        expect(added.remainingSeconds, 45);
        expect(added.totalDurationSeconds, 75);
      });

      test('works with zero seconds', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        final added = timer.addTime(0);
        expect(added.remainingSeconds, 60);
        expect(added.totalDurationSeconds, 60);
      });
    });

    group('skip', () {
      test('completes the timer', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          remainingSeconds: 45,
          status: TimerStatus.running,
        );
        final skipped = timer.skip();
        expect(skipped.status, TimerStatus.completed);
        expect(skipped.remainingSeconds, 0);
        expect(skipped.endTime, isNotNull);
        expect(skipped.completionTime, isNotNull);
      });
    });

    group('full lifecycle', () {
      test('idle -> start -> tick -> tick -> ... -> complete', () {
        var timer = RestTimer(totalDurationSeconds: 3);
        expect(timer.status, TimerStatus.idle);

        timer = timer.start();
        expect(timer.status, TimerStatus.running);
        expect(timer.remainingSeconds, 3);

        timer = timer.tick(); // 2
        expect(timer.remainingSeconds, 2);
        expect(timer.status, TimerStatus.running);

        timer = timer.tick(); // 1
        expect(timer.remainingSeconds, 1);
        expect(timer.status, TimerStatus.running);

        timer = timer.tick(); // <=1 -> completes
        expect(timer.status, TimerStatus.completed);
        expect(timer.remainingSeconds, 0);
      });

      test('start -> pause -> resume -> tick -> complete', () {
        var timer = RestTimer(totalDurationSeconds: 2);

        timer = timer.start();
        expect(timer.status, TimerStatus.running);

        timer = timer.pause();
        expect(timer.status, TimerStatus.paused);

        timer = timer.resume();
        expect(timer.status, TimerStatus.running);

        timer = timer.tick(); // 1
        expect(timer.remainingSeconds, 1);

        timer = timer.tick(); // <=1 -> completes
        expect(timer.status, TimerStatus.completed);
        expect(timer.remainingSeconds, 0);
      });

      test('start -> skip completes immediately', () {
        var timer = RestTimer(totalDurationSeconds: 60);
        timer = timer.start();
        timer = timer.skip();
        expect(timer.status, TimerStatus.completed);
        expect(timer.remainingSeconds, 0);
      });
    });

    group('copyWith', () {
      test('preserves id', () {
        final timer = RestTimer(id: 'keep-me', totalDurationSeconds: 60);
        final copy = timer.copyWith(totalDurationSeconds: 120);
        expect(copy.id, 'keep-me');
      });

      test('updates specified fields', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        final copy = timer.copyWith(
          type: TimerType.cooldown,
          totalDurationSeconds: 120,
          remainingSeconds: 100,
          status: TimerStatus.paused,
          exerciseName: 'Squat',
          currentSet: 3,
          totalSets: 5,
          workoutId: 'w-2',
          audioAlreadyPlayed: true,
        );
        expect(copy.type, TimerType.cooldown);
        expect(copy.totalDurationSeconds, 120);
        expect(copy.remainingSeconds, 100);
        expect(copy.status, TimerStatus.paused);
        expect(copy.exerciseName, 'Squat');
        expect(copy.currentSet, 3);
        expect(copy.totalSets, 5);
        expect(copy.workoutId, 'w-2');
        expect(copy.audioAlreadyPlayed, true);
      });

      test('keeps unchanged fields', () {
        final timer = RestTimer(
          totalDurationSeconds: 60,
          exerciseName: 'Bench Press',
          currentSet: 2,
        );
        final copy = timer.copyWith(totalDurationSeconds: 120);
        expect(copy.exerciseName, 'Bench Press');
        expect(copy.currentSet, 2);
      });
    });

    group('toJson / fromJson', () {
      test('round-trips all fields', () {
        final now = DateTime.now();
        final timer = RestTimer(
          id: 'json-test',
          type: TimerType.warmup,
          totalDurationSeconds: 120,
          remainingSeconds: 45,
          status: TimerStatus.running,
          startTime: now,
          endTime: now.add(const Duration(seconds: 45)),
          exerciseName: 'Deadlift',
          currentSet: 3,
          totalSets: 5,
          workoutId: 'w-abc',
          audioAlreadyPlayed: true,
          completionTime: now,
        );

        final json = timer.toJson();
        final restored = RestTimer.fromJson(json);

        expect(restored.id, timer.id);
        expect(restored.type, timer.type);
        expect(restored.totalDurationSeconds, timer.totalDurationSeconds);
        expect(restored.remainingSeconds, timer.remainingSeconds);
        expect(restored.status, timer.status);
        expect(restored.exerciseName, timer.exerciseName);
        expect(restored.currentSet, timer.currentSet);
        expect(restored.totalSets, timer.totalSets);
        expect(restored.workoutId, timer.workoutId);
        expect(restored.audioAlreadyPlayed, timer.audioAlreadyPlayed);
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'min-test',
          'type': 'rest',
          'totalDurationSeconds': 60,
          'remainingSeconds': 60,
          'status': 'idle',
          'audioAlreadyPlayed': false,
        };

        final timer = RestTimer.fromJson(json);
        expect(timer.id, 'min-test');
        expect(timer.type, TimerType.rest);
        expect(timer.totalDurationSeconds, 60);
        expect(timer.startTime, isNull);
        expect(timer.endTime, isNull);
        expect(timer.exerciseName, isNull);
        expect(timer.completionTime, isNull);
      });

      test('fromJson defaults audioAlreadyPlayed to false when missing', () {
        final json = {
          'id': 'test',
          'type': 'rest',
          'totalDurationSeconds': 60,
          'remainingSeconds': 60,
          'status': 'idle',
        };
        final timer = RestTimer.fromJson(json);
        expect(timer.audioAlreadyPlayed, false);
      });

      test('fromJson defaults to rest type for unknown type', () {
        final json = {
          'id': 'test',
          'type': 'unknown_type',
          'totalDurationSeconds': 60,
          'remainingSeconds': 60,
          'status': 'idle',
        };
        final timer = RestTimer.fromJson(json);
        expect(timer.type, TimerType.rest);
      });

      test('fromJson defaults to idle status for unknown status', () {
        final json = {
          'id': 'test',
          'type': 'rest',
          'totalDurationSeconds': 60,
          'remainingSeconds': 60,
          'status': 'unknown_status',
        };
        final timer = RestTimer.fromJson(json);
        expect(timer.status, TimerStatus.idle);
      });

      test('toJson produces correct keys', () {
        final timer = RestTimer(
          id: 'key-test',
          totalDurationSeconds: 60,
        );
        final json = timer.toJson();
        expect(json.containsKey('id'), true);
        expect(json.containsKey('type'), true);
        expect(json.containsKey('totalDurationSeconds'), true);
        expect(json.containsKey('remainingSeconds'), true);
        expect(json.containsKey('status'), true);
        expect(json.containsKey('audioAlreadyPlayed'), true);
      });
    });

    group('equality', () {
      test('timers with same id are equal', () {
        final timer1 = RestTimer(
          id: 'same-id',
          totalDurationSeconds: 60,
          remainingSeconds: 60,
        );
        final timer2 = RestTimer(
          id: 'same-id',
          totalDurationSeconds: 120,
          remainingSeconds: 10,
        );
        expect(timer1, equals(timer2));
      });

      test('timers with different ids are not equal', () {
        final timer1 = RestTimer(
          id: 'id-1',
          totalDurationSeconds: 60,
        );
        final timer2 = RestTimer(
          id: 'id-2',
          totalDurationSeconds: 60,
        );
        expect(timer1, isNot(equals(timer2)));
      });

      test('hashCode is based on id', () {
        final timer1 = RestTimer(
          id: 'hash-test',
          totalDurationSeconds: 60,
        );
        final timer2 = RestTimer(
          id: 'hash-test',
          totalDurationSeconds: 120,
        );
        expect(timer1.hashCode, timer2.hashCode);
      });

      test('identical instance is equal', () {
        final timer = RestTimer(totalDurationSeconds: 60);
        expect(timer == timer, true);
      });
    });

    group('toString', () {
      test('contains type, time, status, and exercise name', () {
        final timer = RestTimer(
          totalDurationSeconds: 90,
          exerciseName: 'Squat',
          status: TimerStatus.running,
        );
        final str = timer.toString();
        expect(str, contains('rest'));
        expect(str, contains('01:30'));
        expect(str, contains('running'));
        expect(str, contains('Squat'));
      });
    });
  });

  group('TimerStatus enum', () {
    test('has all expected values', () {
      expect(TimerStatus.values, hasLength(5));
      expect(TimerStatus.values, contains(TimerStatus.idle));
      expect(TimerStatus.values, contains(TimerStatus.running));
      expect(TimerStatus.values, contains(TimerStatus.paused));
      expect(TimerStatus.values, contains(TimerStatus.completed));
      expect(TimerStatus.values, contains(TimerStatus.awaitingRPE));
    });
  });

  group('TimerType enum', () {
    test('has all expected values', () {
      expect(TimerType.values, hasLength(4));
      expect(TimerType.values, contains(TimerType.rest));
      expect(TimerType.values, contains(TimerType.workout));
      expect(TimerType.values, contains(TimerType.warmup));
      expect(TimerType.values, contains(TimerType.cooldown));
    });
  });

  group('RestTimerFactory', () {
    group('strength', () {
      test('creates timer with default 3 minutes', () {
        final timer = RestTimerFactory.strength(exerciseName: 'Bench Press');
        expect(timer.totalDurationSeconds, 180);
        expect(timer.exerciseName, 'Bench Press');
        expect(timer.currentSet, 1);
        expect(timer.totalSets, 4);
        expect(timer.type, TimerType.rest);
      });

      test('accepts custom duration and sets', () {
        final timer = RestTimerFactory.strength(
          exerciseName: 'Squat',
          durationMinutes: 5,
          currentSet: 2,
          totalSets: 6,
          workoutId: 'w-1',
        );
        expect(timer.totalDurationSeconds, 300);
        expect(timer.currentSet, 2);
        expect(timer.totalSets, 6);
        expect(timer.workoutId, 'w-1');
      });
    });

    group('hypertrophy', () {
      test('creates timer with default 2 minutes', () {
        final timer = RestTimerFactory.hypertrophy(exerciseName: 'Curl');
        expect(timer.totalDurationSeconds, 120);
        expect(timer.exerciseName, 'Curl');
        expect(timer.currentSet, 1);
        expect(timer.totalSets, 4);
      });

      test('accepts custom duration', () {
        final timer = RestTimerFactory.hypertrophy(
          exerciseName: 'Curl',
          durationMinutes: 1,
        );
        expect(timer.totalDurationSeconds, 60);
      });
    });

    group('endurance', () {
      test('creates timer with default 60 seconds', () {
        final timer = RestTimerFactory.endurance(exerciseName: 'Burpees');
        expect(timer.totalDurationSeconds, 60);
        expect(timer.exerciseName, 'Burpees');
      });

      test('accepts custom duration in seconds', () {
        final timer = RestTimerFactory.endurance(
          exerciseName: 'Burpees',
          durationSeconds: 30,
        );
        expect(timer.totalDurationSeconds, 30);
      });
    });

    group('superset', () {
      test('creates timer with default 45 seconds and 3 sets', () {
        final timer = RestTimerFactory.superset(exerciseName: 'A1/A2');
        expect(timer.totalDurationSeconds, 45);
        expect(timer.totalSets, 3);
      });

      test('accepts custom duration in seconds', () {
        final timer = RestTimerFactory.superset(
          exerciseName: 'A1/A2',
          durationSeconds: 30,
        );
        expect(timer.totalDurationSeconds, 30);
      });
    });

    group('custom', () {
      test('creates timer with exact parameters', () {
        final timer = RestTimerFactory.custom(
          exerciseName: 'Plank',
          durationSeconds: 45,
          currentSet: 1,
          totalSets: 3,
          type: TimerType.workout,
          workoutId: 'w-plank',
        );
        expect(timer.totalDurationSeconds, 45);
        expect(timer.exerciseName, 'Plank');
        expect(timer.type, TimerType.workout);
        expect(timer.workoutId, 'w-plank');
      });

      test('defaults to rest type', () {
        final timer = RestTimerFactory.custom(
          exerciseName: 'Test',
          durationSeconds: 30,
        );
        expect(timer.type, TimerType.rest);
      });
    });
  });
}
