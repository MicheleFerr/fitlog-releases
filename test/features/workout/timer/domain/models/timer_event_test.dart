import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/timer/domain/models/timer_event.dart';

void main() {
  group('TimerEvent', () {
    group('TimerStartedEvent', () {
      test('creates via factory constructor', () {
        final event = TimerEvent.started(const Duration(seconds: 60));
        expect(event, isA<TimerStartedEvent>());
      });

      test('stores duration', () {
        const duration = Duration(minutes: 2, seconds: 30);
        final event = TimerEvent.started(duration) as TimerStartedEvent;
        expect(event.duration, duration);
      });

      test('creates directly', () {
        const event = TimerStartedEvent(Duration(seconds: 90));
        expect(event.duration, const Duration(seconds: 90));
      });

      test('is a TimerEvent', () {
        const event = TimerStartedEvent(Duration(seconds: 60));
        expect(event, isA<TimerEvent>());
      });

      test('stores zero duration', () {
        const event = TimerStartedEvent(Duration.zero);
        expect(event.duration, Duration.zero);
      });

      test('stores large duration', () {
        const event = TimerStartedEvent(Duration(hours: 1));
        expect(event.duration, const Duration(hours: 1));
      });
    });

    group('TimerPausedEvent', () {
      test('creates via factory constructor', () {
        final event = TimerEvent.paused();
        expect(event, isA<TimerPausedEvent>());
      });

      test('creates directly', () {
        const event = TimerPausedEvent();
        expect(event, isA<TimerEvent>());
      });
    });

    group('TimerResumedEvent', () {
      test('creates via factory constructor', () {
        final event = TimerEvent.resumed();
        expect(event, isA<TimerResumedEvent>());
      });

      test('creates directly', () {
        const event = TimerResumedEvent();
        expect(event, isA<TimerEvent>());
      });
    });

    group('TimerCompletedEvent', () {
      test('creates via factory constructor', () {
        final event = TimerEvent.completed();
        expect(event, isA<TimerCompletedEvent>());
      });

      test('creates directly', () {
        const event = TimerCompletedEvent();
        expect(event, isA<TimerEvent>());
      });
    });

    group('TimerSkippedEvent', () {
      test('creates via factory constructor', () {
        final event = TimerEvent.skipped();
        expect(event, isA<TimerSkippedEvent>());
      });

      test('creates directly', () {
        const event = TimerSkippedEvent();
        expect(event, isA<TimerEvent>());
      });
    });

    group('type checking', () {
      test('each event type is distinct', () {
        final started = TimerEvent.started(const Duration(seconds: 60));
        final paused = TimerEvent.paused();
        final resumed = TimerEvent.resumed();
        final completed = TimerEvent.completed();
        final skipped = TimerEvent.skipped();

        expect(started, isA<TimerStartedEvent>());
        expect(started, isNot(isA<TimerPausedEvent>()));
        expect(started, isNot(isA<TimerResumedEvent>()));
        expect(started, isNot(isA<TimerCompletedEvent>()));
        expect(started, isNot(isA<TimerSkippedEvent>()));

        expect(paused, isA<TimerPausedEvent>());
        expect(resumed, isA<TimerResumedEvent>());
        expect(completed, isA<TimerCompletedEvent>());
        expect(skipped, isA<TimerSkippedEvent>());
      });
    });

    group('pattern matching', () {
      test('switch exhaustively matches all event types', () {
        final events = <TimerEvent>[
          TimerEvent.started(const Duration(seconds: 60)),
          TimerEvent.paused(),
          TimerEvent.resumed(),
          TimerEvent.completed(),
          TimerEvent.skipped(),
        ];

        final results = <String>[];
        for (final event in events) {
          final result = switch (event) {
            TimerStartedEvent(:final duration) =>
              'started:${duration.inSeconds}',
            TimerPausedEvent() => 'paused',
            TimerResumedEvent() => 'resumed',
            TimerCompletedEvent() => 'completed',
            TimerSkippedEvent() => 'skipped',
          };
          results.add(result);
        }

        expect(results, [
          'started:60',
          'paused',
          'resumed',
          'completed',
          'skipped',
        ]);
      });

      test('switch extracts duration from started event', () {
        final event = TimerEvent.started(const Duration(minutes: 3));
        final seconds = switch (event) {
          TimerStartedEvent(:final duration) => duration.inSeconds,
          _ => -1,
        };
        expect(seconds, 180);
      });
    });
  });
}
