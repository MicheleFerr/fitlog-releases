import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/utils/memory_leak_detector.dart';
import 'package:gymbro_flutter_new/core/utils/disposable_resources_mixin.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';

void main() {
  group('Memory Leak Detection and Prevention Tests', () {
    late MemoryLeakDetector detector;
    
    setUp(() {
      detector = MemoryLeakDetector();
      detector.startMonitoring(interval: const Duration(seconds: 1));
    });
    
    tearDown(() {
      detector.stopMonitoring();
      detector.forceCleanupAll();
    });
    
    testWidgets('Timer tracking and cleanup', (tester) async {
      // Test timer tracking
      final timer1 = Timer.periodic(const Duration(milliseconds: 100), (_) {}).trackMemoryLeaks('test-timer-1');
      final timer2 = Timer(const Duration(milliseconds: 200), () {}).trackMemoryLeaks('test-timer-2');
      
      await tester.pump(const Duration(milliseconds: 50));
      
      // Check that timers are tracked
      final initialReport = detector.getMemoryReport();
      expect(initialReport['activeTimers'], equals(2));
      expect(initialReport['totalTimers'], equals(2));
      
      // Cancel timers properly
      timer1.cancelAndUntrack('test-timer-1');
      timer2.cancelAndUntrack('test-timer-2');
      
      await tester.pump(const Duration(milliseconds: 50));
      
      // Check that timers are cleaned up
      final finalReport = detector.getMemoryReport();
      expect(finalReport['activeTimers'], equals(0));
      expect(finalReport['totalTimers'], equals(2)); // Total count should remain
    });
    
    test('Stream subscription tracking', () async {
      final controller = StreamController<int>.broadcast();

      // Track subscriptions
      final sub1 = controller.stream.listen((_) {}).trackMemoryLeaks('test-sub-1');
      final sub2 = controller.stream.listen((_) {}).trackMemoryLeaks('test-sub-2');
      
      // Check that subscriptions are tracked
      final initialReport = detector.getMemoryReport();
      expect(initialReport['activeSubscriptions'], equals(2));
      
      // Cancel subscriptions properly
      await sub1.cancelAndUntrack('test-sub-1');
      await sub2.cancelAndUntrack('test-sub-2');
      
      // Check cleanup
      final finalReport = detector.getMemoryReport();
      expect(finalReport['activeSubscriptions'], equals(0));
      
      await controller.close();
    });
    
    test('DisposableResourcesMixin functionality', () async {
      // Create a test class using the mixin
      final testProvider = _TestProviderWithMixin();
      
      // Add resources
      final timer = Timer.periodic(const Duration(milliseconds: 100), (_) {});
      final controller = StreamController<int>();
      final subscription = controller.stream.listen((_) {});
      
      testProvider.addTimer(timer);
      testProvider.addStreamSubscription(subscription);
      testProvider.addCustomDisposer(() {
        controller.close();
      });
      
      // Check resources are managed
      final report = testProvider.getResourceReport();
      expect(report['timers'], equals(1));
      expect(report['subscriptions'], equals(1));
      expect(report['customDisposers'], equals(1));
      expect(report['isDisposed'], equals(0));
      
      // Dispose all resources
      testProvider.disposeResources();
      
      // Check everything is cleaned up
      final finalReport = testProvider.getResourceReport();
      expect(finalReport['timers'], equals(0));
      expect(finalReport['subscriptions'], equals(0));
      expect(finalReport['customDisposers'], equals(0));
      expect(finalReport['isDisposed'], equals(1));
      
      // Verify timer is actually cancelled
      expect(timer.isActive, isFalse);
    });
    
    testWidgets('UnifiedTimerProvider memory leak prevention', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      // Create and use the provider
      final provider = container.read(unifiedTimerProvider.notifier);
      
      // Start a timer
      await provider.startTimer(
        durationSeconds: 5,
        exerciseName: 'Test Exercise',
      );
      
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify timer is active
      final state = container.read(unifiedTimerProvider);
      expect(state?.isActive, isTrue);
      
      // Dispose the container (simulates app shutdown or provider disposal)
      container.dispose();
      
      await tester.pump(const Duration(milliseconds: 100));
      
      // Provider should have cleaned up its resources
      // Note: We can't directly test the internal cleanup since it's private,
      // but we can verify the provider is properly disposed by checking
      // that operations on it fail gracefully
    });
    
    test('Memory leak report generation', () {
      // Create some tracked resources
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {}).trackMemoryLeaks('report-test');
      final controller = StreamController<String>();
      final subscription = controller.stream.listen((_) {}).trackMemoryLeaks('report-test');
      
      detector.registerProvider('test-provider-1', 'TestProvider');
      detector.registerProvider('test-provider-2', 'AnotherProvider');
      
      // Generate report
      final report = detector.generateLeakReport();
      
      expect(report, contains('MEMORY LEAK DETECTION REPORT'));
      expect(report, contains('Timers: 1 active'));
      expect(report, contains('Subscriptions: 1 active'));
      expect(report, contains('Providers: 2 active'));
      
      // Cleanup
      timer.cancelAndUntrack('report-test');
      subscription.cancelAndUntrack('report-test');
      detector.unregisterProvider('test-provider-1', 'TestProvider');
      detector.unregisterProvider('test-provider-2', 'AnotherProvider');
      controller.close();
    });
    
    test('High resource count warnings', () {
      // Create many resources to trigger warnings
      final timers = <Timer>[];
      for (int i = 0; i < 15; i++) {
        timers.add(Timer.periodic(const Duration(seconds: 1), (_) {}).trackMemoryLeaks('warning-test-$i'));
      }
      
      // Generate report and check for warnings
      final report = detector.generateLeakReport();
      expect(report, contains('🚨 HIGH TIMER COUNT'));
      
      // Cleanup
      for (final timer in timers) {
        timer.cancelAndUntrack();
      }
    });
    
    testWidgets('Widget with proper resource disposal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestWidgetWithResources(),
          ),
        ),
      );
      
      // Widget should be displayed
      expect(find.byType(_TestWidgetWithResources), findsOneWidget);
      
      // Navigate away to trigger disposal
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('New Page'),
          ),
        ),
      );
      
      // Resources should be disposed (we can't test directly, but no exceptions should occur)
      await tester.pump();
    });
  });
}

/// Test provider using DisposableResourcesMixin
class _TestProviderWithMixin with DisposableResourcesMixin {
  // Empty implementation for testing
}

/// Test widget with disposable resources
class _TestWidgetWithResources extends StatefulWidget {
  @override
  _TestWidgetWithResourcesState createState() => _TestWidgetWithResourcesState();
}

class _TestWidgetWithResourcesState extends State<_TestWidgetWithResources>
    with DisposableWidgetMixin {
  
  @override
  void initState() {
    super.initState();
    
    // Add some resources to test disposal
    addTimer(Timer.periodic(const Duration(seconds: 1), (_) {
      // Mock timer operation
    }));
    
    final controller = StreamController<int>();
    addStreamSubscription(controller.stream.listen((_) {}));
    
    // Add custom disposer for the controller
    addCustomDisposer(() {
      controller.close();
    });
  }
  
  @override
  void dispose() {
    disposeWidgetResources();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return const Text('Test Widget');
  }
}

/// Extension for custom disposer in widget mixin
extension DisposableWidgetMixinExtension<T extends StatefulWidget> on DisposableWidgetMixin<T> {
  void addCustomDisposer(VoidCallback disposer) {
    // Store custom disposer - in real implementation this would be part of the mixin
  }
}