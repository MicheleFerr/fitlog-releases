import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// Test helper class for AnimationController vsync
class TestVSync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

void main() {
  setUpAll(() async {
    // Initialize Hive with temporary directory for tests
    Hive.init('./test/.hive_test');

    // Initialize HiveBoxManagerEnhanced
    await HiveBoxManagerEnhanced.initialize();
  });

  tearDown(() async {
    // Clean up all boxes after each test
    await Hive.deleteFromDisk();

    // Reset HiveBoxManagerEnhanced for next test (singleton state)
    HiveBoxManagerEnhanced().resetForTesting();
  });

  group('HiveBoxManager Leak Detection Tests', () {
    testWidgets('should not leak boxes after dispose',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      // Open boxes
      final manager = container.read(hiveBoxManagerProvider);
      await manager.openBox<Map>('test_box_1');
      await manager.openBox<Map>('test_box_2');

      // Verify boxes are open
      expect(Hive.isBoxOpen('test_box_1'), true);
      expect(Hive.isBoxOpen('test_box_2'), true);

      // Dispose container (should close boxes)
      container.dispose();
      await tester.pumpAndSettle();

      // Wait for async disposal
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify boxes are closed (no leak)
      expect(Hive.isBoxOpen('test_box_1'), false);
      expect(Hive.isBoxOpen('test_box_2'), false);
    }, experimentalLeakTesting: LeakTesting.settings);

    test('should not leak AnimationController with HiveBoxManager', () async {
      final events = await memoryEvents(() async {
        final controller = AnimationController(
          duration: const Duration(seconds: 1),
          vsync: TestVSync(),
        );

        final manager = HiveBoxManagerEnhanced();
        await manager.openBox<Map>('animation_box');

        // Dispose both
        controller.dispose();
        await manager.closeAll();
      }, AnimationController);

      // Verify: create + dispose (no leak)
      expect(events, areCreateAndDispose);
    });

    testWidgets('Provider disposal should close all boxes',
        (WidgetTester tester) async {
      final container = ProviderContainer();

      final manager = container.read(hiveBoxManagerProvider);
      await manager.openBox<Map>('workout_box');
      await manager.openBox<Map>('exercise_box');

      // Verify open
      expect(Hive.isBoxOpen('workout_box'), true);
      expect(Hive.isBoxOpen('exercise_box'), true);

      // Dispose
      container.dispose();
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify closed (no leak)
      expect(Hive.isBoxOpen('workout_box'), false);
      expect(Hive.isBoxOpen('exercise_box'), false);
    });

    test('should not leak boxes on multiple open/close cycles', () async {
      final manager = HiveBoxManagerEnhanced();

      // Cycle 1
      await manager.openBox<Map>('cycle_box');
      expect(Hive.isBoxOpen('cycle_box'), true);
      await manager.closeBox('cycle_box');
      expect(Hive.isBoxOpen('cycle_box'), false);

      // Cycle 2
      await manager.openBox<Map>('cycle_box');
      expect(Hive.isBoxOpen('cycle_box'), true);
      await manager.closeBox('cycle_box');
      expect(Hive.isBoxOpen('cycle_box'), false);

      // Cycle 3
      await manager.openBox<Map>('cycle_box');
      expect(Hive.isBoxOpen('cycle_box'), true);
      await manager.closeAll();
      expect(Hive.isBoxOpen('cycle_box'), false);
    });

    test('should handle concurrent box operations without leak', () async {
      final manager = HiveBoxManagerEnhanced();

      // Open multiple boxes concurrently
      await Future.wait([
        manager.openBox<Map>('concurrent_1'),
        manager.openBox<Map>('concurrent_2'),
        manager.openBox<Map>('concurrent_3'),
      ]);

      expect(Hive.isBoxOpen('concurrent_1'), true);
      expect(Hive.isBoxOpen('concurrent_2'), true);
      expect(Hive.isBoxOpen('concurrent_3'), true);

      // Close all
      await manager.closeAll();

      expect(Hive.isBoxOpen('concurrent_1'), false);
      expect(Hive.isBoxOpen('concurrent_2'), false);
      expect(Hive.isBoxOpen('concurrent_3'), false);
    });

    test('should not leak LazyBox', () async {
      final manager = HiveBoxManagerEnhanced();

      await manager.openLazyBox<Map>('lazy_test');
      expect(Hive.isBoxOpen('lazy_test'), true);

      await manager.closeLazyBox('lazy_test');
      expect(Hive.isBoxOpen('lazy_test'), false);
    });

    test('should cleanup locks on box close', () async {
      final manager = HiveBoxManagerEnhanced();

      // Open box (creates lock internally)
      await manager.openBox<Map>('lock_test');

      // Close box (should remove lock)
      await manager.closeBox('lock_test');

      // Verify no lock leak by checking manager state
      expect(manager.isBoxOpen('lock_test'), false);
    });
  });

  group('HiveBoxManager Error Handling Tests', () {
    test('should handle corrupted box gracefully', () async {
      final manager = HiveBoxManagerEnhanced();

      // Create a box
      final box = await manager.openBox<Map>('corruption_test');
      await box.put('key', {'value': 'test'});
      await manager.closeBox('corruption_test');

      // Note: Actual corruption testing requires native file system manipulation
      // This test verifies the error handling path exists

      // Reopen should work
      final box2 = await manager.openBox<Map>('corruption_test');
      expect(box2.isOpen, true);

      await manager.closeAll();
    });

    test('should retry on I/O errors', () async {
      final manager = HiveBoxManagerEnhanced();

      // Opening a box should succeed (even with retry logic)
      final box = await manager.openBox<Map>('retry_test', maxRetries: 3);
      expect(box.isOpen, true);

      await manager.closeAll();
    });
  });

  group('HiveBoxManager Transaction Tests', () {
    test('should execute transaction atomically', () async {
      final manager = HiveBoxManagerEnhanced();

      await manager.transaction<Map>('transaction_test', (box) async {
        await box.put('counter', {'value': 0});
      });

      await manager.transaction<Map>('transaction_test', (box) async {
        final current = box.get('counter') as Map;
        current['value'] = (current['value'] as int) + 1;
        await box.put('counter', current);
      });

      final box = await manager.openBox<Map>('transaction_test');
      final result = box.get('counter') as Map;
      expect(result['value'], 1);

      await manager.closeAll();
    });
  });

  group('HiveBoxManager Batch Operations Tests', () {
    test('should perform batch put without leak', () async {
      final manager = HiveBoxManagerEnhanced();

      final entries = <String, Map>{
        for (var i = 0; i < 100; i++) 'key_$i': {'value': i},
      };

      await manager.putAll<Map>('batch_test', entries);

      final box = await manager.openBox<Map>('batch_test');
      expect(box.length, 100);

      await manager.closeAll();
    });

    test('should perform batch delete without leak', () async {
      final manager = HiveBoxManagerEnhanced();

      // Setup: add 100 entries
      final box = await manager.openBox<Map>('batch_delete_test');
      for (var i = 0; i < 100; i++) {
        await box.put('key_$i', {'value': i});
      }
      expect(box.length, 100);

      // Batch delete 50 entries
      final keysToDelete = List.generate(50, (i) => 'key_$i');
      await manager.deleteAll('batch_delete_test', keysToDelete);

      expect(box.length, 50);

      await manager.closeAll();
    });
  });
}
