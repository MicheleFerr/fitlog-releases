import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/concurrency/mutex_wrapper.dart';

void main() {
  group('MutexWrapper', () {
    test('serializes concurrent operations (FIFO order)', () async {
      final mutex = MutexWrapper(name: 'Test');
      final results = <int>[];

      // Launch 5 concurrent operations
      final futures = <Future>[];
      for (int i = 0; i < 5; i++) {
        futures.add(mutex.protect(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          results.add(i);
        }));
      }

      await Future.wait(futures);

      // ASSERT: Operations executed in FIFO order
      expect(results, [0, 1, 2, 3, 4]);
    });

    test('handles exceptions without breaking queue', () async {
      final mutex = MutexWrapper(name: 'Test');
      final results = <String>[];

      // Operation 1: Success
      final future1 = mutex.protect(() async {
        results.add('success1');
      });

      // Operation 2: Throws exception
      final future2 = mutex.protect(() async {
        results.add('before_error');
        throw Exception('Test error');
      });

      // Operation 3: Success (should still execute)
      final future3 = mutex.protect(() async {
        results.add('success3');
      });

      await future1;
      expect(future2, throwsException);
      await future3;

      // ASSERT: Queue continued after exception
      expect(results, ['success1', 'before_error', 'success3']);
    });

    test('prevents race condition in concurrent saves', () async {
      final mutex = MutexWrapper(name: 'Save');
      final saveOrder = <int>[];
      int counter = 0;

      // Simulate concurrent saves
      final futures = List.generate(10, (i) {
        return mutex.protect(() async {
          // Read counter
          final currentValue = counter;

          // Simulate async operation
          await Future.delayed(const Duration(milliseconds: 5));

          // Increment counter
          counter = currentValue + 1;
          saveOrder.add(i);
        });
      });

      await Future.wait(futures);

      // ASSERT: Counter incremented correctly (no race condition)
      expect(counter, 10);

      // ASSERT: All saves completed
      expect(saveOrder.length, 10);
    });

    test('returns correct result from protected operation', () async {
      final mutex = MutexWrapper(name: 'Test');

      final result = await mutex.protect(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      expect(result, 42);
    });

    test('supports different return types', () async {
      final mutex = MutexWrapper(name: 'Test');

      // String
      final stringResult = await mutex.protect(() async => 'hello');
      expect(stringResult, 'hello');

      // List
      final listResult = await mutex.protect(() async => [1, 2, 3]);
      expect(listResult, [1, 2, 3]);

      // Null
      final nullResult = await mutex.protect(() async => null);
      expect(nullResult, null);
    });

    test('queue size reflects pending operations', () async {
      final mutex = MutexWrapper(name: 'Test');

      // Initially empty
      expect(mutex.queueSize, 0);

      // Add operation that takes 100ms
      final future1 = mutex.protect(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });

      // Add 3 more operations while first is running
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = mutex.protect(() async {});
      final future3 = mutex.protect(() async {});
      final future4 = mutex.protect(() async {});

      // Queue should have pending operations
      expect(mutex.queueSize, greaterThan(0));

      // Wait for all to complete
      await Future.wait([future1, future2, future3, future4]);

      // Queue should be empty
      expect(mutex.queueSize, 0);
    });

    test('operations completed counter increments', () async {
      final mutex = MutexWrapper(name: 'Test');

      expect(mutex.operationsCompleted, 0);

      await mutex.protect(() async {});
      expect(mutex.operationsCompleted, 1);

      await mutex.protect(() async {});
      expect(mutex.operationsCompleted, 2);

      await mutex.protect(() async {});
      expect(mutex.operationsCompleted, 3);
    });

    test('isLocked reflects current state', () async {
      final mutex = MutexWrapper(name: 'Test');

      // Initially unlocked
      expect(mutex.isLocked, false);

      // Start long operation
      final future = mutex.protect(() async {
        expect(mutex.isLocked, true);
        await Future.delayed(const Duration(milliseconds: 50));
      });

      // Should be locked while operation running
      await Future.delayed(const Duration(milliseconds: 10));
      expect(mutex.isLocked, true);

      // Wait for completion
      await future;

      // Should be unlocked after completion
      expect(mutex.isLocked, false);
    });
  });
}
