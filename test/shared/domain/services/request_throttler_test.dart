/// RequestThrottler tests - Debouncer, Throttler, RateLimitHandler, RequestQueue.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/services/request_throttler.dart';

void main() {
  group('Debouncer', () {
    test('isActive false initially', () {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      expect(debouncer.isActive, isFalse);
      debouncer.dispose();
    });

    test('isActive true after run', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 200));
      debouncer.run(() {});
      expect(debouncer.isActive, isTrue);
      debouncer.dispose();
    });

    test('executes action after duration', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      var executed = false;
      debouncer.run(() => executed = true);

      expect(executed, isFalse);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(executed, isTrue);
      debouncer.dispose();
    });

    test('cancels previous action on repeated run', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 80));
      var callCount = 0;

      debouncer.run(() => callCount++);
      await Future.delayed(const Duration(milliseconds: 30));
      debouncer.run(() => callCount++); // Resets the timer

      await Future.delayed(const Duration(milliseconds: 120));
      expect(callCount, 1); // Only the second run fires
      debouncer.dispose();
    });

    test('cancel stops pending action', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      var executed = false;
      debouncer.run(() => executed = true);
      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(executed, isFalse);
      expect(debouncer.isActive, isFalse);
      debouncer.dispose();
    });

    test('dispose cancels pending action', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      var executed = false;
      debouncer.run(() => executed = true);
      debouncer.dispose();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(executed, isFalse);
    });

    test('onError called when action throws', () async {
      Object? caughtError;
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 50),
        onError: (error, _) => caughtError = error,
      );

      debouncer.run(() => throw Exception('test error'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(caughtError, isA<Exception>());
      debouncer.dispose();
    });
  });

  group('Throttler', () {
    test('isThrottled false initially', () {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      expect(throttler.isThrottled, isFalse);
      throttler.dispose();
    });

    test('executes immediately with leading=true (default)', () {
      final throttler = Throttler(duration: const Duration(milliseconds: 500));
      var executed = false;

      throttler.run(() => executed = true);
      expect(executed, isTrue);
      throttler.dispose();
    });

    test('isThrottled true after execution', () {
      final throttler = Throttler(duration: const Duration(milliseconds: 500));
      throttler.run(() {});

      expect(throttler.isThrottled, isTrue);
      throttler.dispose();
    });

    test('drops calls during throttle window', () {
      final throttler = Throttler(duration: const Duration(milliseconds: 500));
      var callCount = 0;

      throttler.run(() => callCount++);
      throttler.run(() => callCount++);
      throttler.run(() => callCount++);

      expect(callCount, 1); // Only first call executes
      throttler.dispose();
    });

    test('allows execution after throttle window', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 50));
      var callCount = 0;

      throttler.run(() => callCount++);
      await Future.delayed(const Duration(milliseconds: 80));
      throttler.run(() => callCount++);

      expect(callCount, 2);
      throttler.dispose();
    });

    test('reset clears throttle state', () {
      final throttler = Throttler(duration: const Duration(milliseconds: 500));
      var callCount = 0;

      throttler.run(() => callCount++);
      expect(throttler.isThrottled, isTrue);

      throttler.reset();
      expect(throttler.isThrottled, isFalse);

      throttler.run(() => callCount++);
      expect(callCount, 2);
      throttler.dispose();
    });

    test('trailing edge fires after window', () async {
      final throttler = Throttler(
        duration: const Duration(milliseconds: 50),
        leading: true,
        trailing: true,
      );
      var callCount = 0;

      throttler.run(() => callCount++); // Leading: executes immediately
      throttler.run(() => callCount++); // Trailing: queued

      expect(callCount, 1);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(callCount, 2); // Trailing fired
      throttler.dispose();
    });

    test('onError called when action throws', () {
      Object? caughtError;
      final throttler = Throttler(
        duration: const Duration(milliseconds: 100),
        onError: (error, _) => caughtError = error,
      );

      throttler.run(() => throw Exception('throttle error'));
      expect(caughtError, isA<Exception>());
      throttler.dispose();
    });

    test('leading=false does not execute immediately', () {
      final throttler = Throttler(
        duration: const Duration(milliseconds: 500),
        leading: false,
      );
      var executed = false;

      throttler.run(() => executed = true);
      expect(executed, isFalse);
      throttler.dispose();
    });
  });

  group('RateLimitHandler', () {
    test('returns result on success', () async {
      final handler = RateLimitHandler();
      final result = await handler.executeWithRetry(() async => 42);
      expect(result, 42);
    });

    test('rethrows non-rate-limit errors', () async {
      final handler = RateLimitHandler();
      expect(
        () => handler.executeWithRetry<int>(
            () async => throw Exception('generic error')),
        throwsException,
      );
    });

    test('maxRetries defaults to 2', () {
      final handler = RateLimitHandler();
      expect(handler.maxRetries, 2);
    });

    test('retryMultiplier defaults to 1.5', () {
      final handler = RateLimitHandler();
      expect(handler.retryMultiplier, 1.5);
    });

    test('custom maxRetries and retryMultiplier', () {
      final handler = RateLimitHandler(maxRetries: 5, retryMultiplier: 2.0);
      expect(handler.maxRetries, 5);
      expect(handler.retryMultiplier, 2.0);
    });
  });

  group('RequestQueue', () {
    test('defaults', () {
      final queue = RequestQueue();
      expect(queue.maxConcurrent, 3);
      expect(queue.maxPerMinute, isNull);
      expect(queue.pendingCount, 0);
      expect(queue.activeCount, 0);
      queue.dispose();
    });

    test('custom concurrency', () {
      final queue = RequestQueue(maxConcurrent: 5, maxPerMinute: 30);
      expect(queue.maxConcurrent, 5);
      expect(queue.maxPerMinute, 30);
      queue.dispose();
    });

    test('enqueue executes action', () async {
      final queue = RequestQueue();
      final result = await queue.enqueue(() async => 'hello');
      expect(result, 'hello');
      queue.dispose();
    });

    test('enqueue propagates errors', () async {
      final queue = RequestQueue();
      expect(
        () => queue.enqueue<int>(() async => throw Exception('queue error')),
        throwsException,
      );
      queue.dispose();
    });

    test('throws StateError after dispose', () {
      final queue = RequestQueue();
      queue.dispose();
      expect(
        () => queue.enqueue(() async => 1),
        throwsStateError,
      );
    });

    test('clear removes pending items', () async {
      final queue = RequestQueue(maxConcurrent: 1);
      final completer = Completer<void>();
      // First item blocks the queue
      unawaited(queue.enqueue(() => completer.future));
      // Queue more items (they will be pending)
      unawaited(queue.enqueue(() async => 1));
      unawaited(queue.enqueue(() async => 2));

      await Future.delayed(const Duration(milliseconds: 50));

      queue.clear();
      expect(queue.pendingCount, 0);

      completer.complete();
      await Future.delayed(const Duration(milliseconds: 50));
      queue.dispose();
    });

    test('waitUntilEmpty waits for completion', () async {
      final queue = RequestQueue();
      var completed = 0;

      unawaited(queue.enqueue(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        completed++;
      }));
      unawaited(queue.enqueue(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        completed++;
      }));

      await queue.waitUntilEmpty();
      expect(completed, 2);
      queue.dispose();
    });

    test('multiple concurrent respects limit', () async {
      final queue = RequestQueue(maxConcurrent: 2);
      var maxActive = 0;
      var currentActive = 0;

      Future<void> trackAction() async {
        currentActive++;
        if (currentActive > maxActive) maxActive = currentActive;
        await Future.delayed(const Duration(milliseconds: 50));
        currentActive--;
      }

      unawaited(queue.enqueue(trackAction));
      unawaited(queue.enqueue(trackAction));
      unawaited(queue.enqueue(trackAction));
      unawaited(queue.enqueue(trackAction));

      await queue.waitUntilEmpty();
      expect(maxActive, lessThanOrEqualTo(2));
      queue.dispose();
    });
  });
}
