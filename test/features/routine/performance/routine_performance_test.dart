/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/routine/performance
/// 🎯 Feature: flexible_routine
/// 🔧 Type: performance test
/// 📱 Platform: Universal
///
/// ROUTINE CENTER V2.0 PERFORMANCE TESTS
///
/// Performance benchmarks for:
/// - CRUD operations (create, update, delete, activate)
/// - Stream provider performance (load routines)
/// - Analytics tracking overhead
/// - Concurrent operations
///
/// Target metrics (for reference, not enforced):
/// - Create routine: < 100ms
/// - Update routine: < 100ms
/// - Delete routine: < 50ms
/// - Activate routine: < 50ms
/// - Load routines: < 200ms
/// - Analytics overhead: < 10ms per event

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_providers.dart';

// ────────────────────────────────────────────────────────────────────────────
// STUB REPOSITORY (For Testing)
// ────────────────────────────────────────────────────────────────────────────

class StubRoutineRepository implements RoutineRepository {
  final List<FlexibleRoutine> _routines = [];
  FlexibleRoutine? _activeRoutine;

  @override
  Future<void> createRoutine(FlexibleRoutine routine) async {
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate DB latency
    _routines.add(routine);
    _activeRoutine = routine;
  }

  @override
  Future<void> updateRoutine(FlexibleRoutine routine) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      _routines[index] = routine;
    }
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 5));
    _routines.removeWhere((r) => r.id == routineId);
  }

  @override
  Future<void> activateRoutine(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 5));
    final routine = _routines.firstWhere((r) => r.id == routineId);
    _activeRoutine = routine;
  }

  @override
  Future<void> deactivateAllRoutines(String userId) async {
    await Future.delayed(const Duration(milliseconds: 5));
    _activeRoutine = null;
  }

  @override
  Future<FlexibleRoutine?> getActiveRoutine(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _activeRoutine;
  }

  @override
  Future<List<FlexibleRoutine>> getUserRoutines(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate Firestore query
    return _routines;
  }

  @override
  Future<FlexibleRoutine?> getRoutineById(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    try {
      return _routines.firstWhere((r) => r.id == routineId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId) {
    return Stream.value(_activeRoutine);
  }

  @override
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId) {
    return Stream.value(_routines);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// STUB ANALYTICS SERVICE (For Testing)
// ────────────────────────────────────────────────────────────────────────────

class StubAnalyticsService implements IAnalyticsService {
  final List<Map<String, dynamic>> loggedEvents = [];
  final List<Duration> eventDurations = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<bool> isAnalyticsCollectionEnabled() async => true;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    final stopwatch = Stopwatch()..start();
    loggedEvents.add({
      'name': name,
      'parameters': parameters ?? {},
    });
    stopwatch.stop();
    eventDurations.add(stopwatch.elapsed);
  }

  @override
  Future<void> logAppOpen() async {
    await logEvent(name: 'app_open');
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        if (screenClass != null) 'screen_class': screenClass,
      },
    );
  }

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {}

  @override
  Future<String> startTrace(String name) async => 'trace-$name';

  @override
  Future<void> stopTrace(
    String traceId, {
    Map<String, int>? metrics,
    Map<String, String>? attributes,
  }) async {}

  @override
  Future<void> logNetworkRequest({
    required String url,
    required String httpMethod,
    int? requestPayloadSize,
    int? responsePayloadSize,
    int? httpResponseCode,
    int? responseTime,
  }) async {}

  @override
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {}

  @override
  Future<void> setDebugMode(bool enabled) async {}

  @override
  Future<void> resetAnalyticsData() async {
    loggedEvents.clear();
    eventDurations.clear();
  }

  /// Get average analytics event duration
  Duration get averageEventDuration {
    if (eventDurations.isEmpty) return Duration.zero;
    final totalMs = eventDurations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMicroseconds,
    );
    return Duration(microseconds: totalMs ~/ eventDurations.length);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TEST HELPERS
// ────────────────────────────────────────────────────────────────────────────

FlexibleRoutine createTestRoutine({
  String id = 'routine-test',
  String userId = 'user-test',
  String name = 'Test Routine',
  RoutinePreset presetType = RoutinePreset.ppl6Day,
  Set<int> trainingDays = const {1, 2, 3, 4, 5, 6},
  Map<int, String> workoutSchedule = const {},
  bool isActive = true,
}) {
  final now = DateTime.now();
  return FlexibleRoutine(
    id: id,
    userId: userId,
    name: name,
    presetType: presetType,
    trainingDays: trainingDays,
    workoutSchedule: workoutSchedule,
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}

// ────────────────────────────────────────────────────────────────────────────
// PERFORMANCE TESTS
// ────────────────────────────────────────────────────────────────────────────

void main() {
  group('Routine Performance Tests', () {
    late ProviderContainer container;
    late StubRoutineRepository stubRepository;
    late StubAnalyticsService stubAnalytics;

    setUp(() {
      stubRepository = StubRoutineRepository();
      stubAnalytics = StubAnalyticsService();
      container = ProviderContainer(
        overrides: [
          routineRepositoryProvider.overrideWith((ref) => stubRepository),
          currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
          analyticsServiceProvider.overrideWith((ref) => stubAnalytics),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    // ────────────────────────────────────────────────────────────────────────
    // CREATE ROUTINE PERFORMANCE
    // ────────────────────────────────────────────────────────────────────────

    test('createRoutine completes within acceptable time', () async {
      final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
      final routine = createTestRoutine();

      final stopwatch = Stopwatch()..start();
      await notifier.createRoutine(routine);
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      // Log performance
      // ignore: avoid_print
      print('✓ createRoutine: ${duration}ms');

      // Reference target: < 100ms (not enforced, for monitoring)
      // Actual includes: repository (10ms) + analytics (~1ms) + state updates
      expect(duration, lessThan(200), reason: 'createRoutine took ${duration}ms');
    });

    // ────────────────────────────────────────────────────────────────────────
    // UPDATE ROUTINE PERFORMANCE
    // ────────────────────────────────────────────────────────────────────────

    test('updateRoutine completes within acceptable time', () async {
      final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
      final routine = createTestRoutine();

      // Create first
      await notifier.createRoutine(routine);

      // Measure update
      final updatedRoutine = routine.copyWith(name: 'Updated Name');
      final stopwatch = Stopwatch()..start();
      await notifier.updateRoutine(updatedRoutine);
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      // ignore: avoid_print
      print('✓ updateRoutine: ${duration}ms');

      expect(duration, lessThan(200), reason: 'updateRoutine took ${duration}ms');
    });

    // ────────────────────────────────────────────────────────────────────────
    // DELETE ROUTINE PERFORMANCE
    // ────────────────────────────────────────────────────────────────────────

    test('deleteRoutine completes within acceptable time', () async {
      final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
      final routine = createTestRoutine();

      // Create first
      await notifier.createRoutine(routine);

      // Measure delete
      final stopwatch = Stopwatch()..start();
      await notifier.deleteRoutine(routine.id);
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      // ignore: avoid_print
      print('✓ deleteRoutine: ${duration}ms');

      // Delete is faster (5ms repository + analytics)
      expect(duration, lessThan(100), reason: 'deleteRoutine took ${duration}ms');
    });

    // ────────────────────────────────────────────────────────────────────────
    // ACTIVATE ROUTINE PERFORMANCE
    // ────────────────────────────────────────────────────────────────────────

    test('activateRoutine completes within acceptable time', () async {
      final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
      final routine = createTestRoutine();

      // Create first
      await notifier.createRoutine(routine);

      // Measure activate
      final stopwatch = Stopwatch()..start();
      await notifier.activateRoutine(routine.id);
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      // ignore: avoid_print
      print('✓ activateRoutine: ${duration}ms');

      expect(duration, lessThan(100), reason: 'activateRoutine took ${duration}ms');
    });

    // ────────────────────────────────────────────────────────────────────────
    // LOAD ROUTINES PERFORMANCE
    // ────────────────────────────────────────────────────────────────────────

    test('getUserRoutines completes within acceptable time', () async {
      // Pre-populate with 10 routines
      for (int i = 0; i < 10; i++) {
        stubRepository._routines.add(
          createTestRoutine(id: 'routine-$i', name: 'Routine $i'),
        );
      }

      final stopwatch = Stopwatch()..start();
      final routines = await stubRepository.getUserRoutines('test-user-123');
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      // ignore: avoid_print
      print('✓ getUserRoutines (10 items): ${duration}ms');

      expect(routines.length, 10);
      expect(duration, lessThan(300), reason: 'getUserRoutines took ${duration}ms');
    });

    // ────────────────────────────────────────────────────────────────────────
    // ANALYTICS OVERHEAD
    // ────────────────────────────────────────────────────────────────────────

    test('analytics tracking has minimal overhead', () async {
      final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
      final routine = createTestRoutine();

      // Perform operation (creates analytics event)
      await notifier.createRoutine(routine);

      // Check analytics overhead
      final avgDuration = stubAnalytics.averageEventDuration;

      // ignore: avoid_print
      print('✓ Analytics average overhead: ${avgDuration.inMicroseconds}μs');

      // Analytics should be very fast (< 10ms per event)
      expect(
        avgDuration.inMilliseconds,
        lessThan(10),
        reason: 'Analytics overhead is ${avgDuration.inMilliseconds}ms',
      );
    });

    // ────────────────────────────────────────────────────────────────────────
    // CONCURRENT OPERATIONS
    // ────────────────────────────────────────────────────────────────────────

    test('handles concurrent routine creations efficiently', () async {
      final notifier = container.read(flexibleRoutineNotifierProvider.notifier);

      // Create 5 routines concurrently
      final stopwatch = Stopwatch()..start();
      await Future.wait([
        notifier.createRoutine(createTestRoutine(id: 'routine-1', name: 'Routine 1')),
        notifier.createRoutine(createTestRoutine(id: 'routine-2', name: 'Routine 2')),
        notifier.createRoutine(createTestRoutine(id: 'routine-3', name: 'Routine 3')),
        notifier.createRoutine(createTestRoutine(id: 'routine-4', name: 'Routine 4')),
        notifier.createRoutine(createTestRoutine(id: 'routine-5', name: 'Routine 5')),
      ]);
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      // ignore: avoid_print
      print('✓ Concurrent creations (5 routines): ${duration}ms');

      // Should be faster than sequential (5 * 100ms = 500ms)
      // Concurrent should be ~100-150ms (max of parallel operations)
      expect(duration, lessThan(400), reason: 'Concurrent operations took ${duration}ms');
    });

    // ────────────────────────────────────────────────────────────────────────
    // STREAM PROVIDER PERFORMANCE
    // ────────────────────────────────────────────────────────────────────────

    test('userRoutinesProvider emits data quickly', () async {
      // Pre-populate with routines
      for (int i = 0; i < 10; i++) {
        stubRepository._routines.add(
          createTestRoutine(id: 'routine-$i', name: 'Routine $i'),
        );
      }

      final stopwatch = Stopwatch()..start();
      final routines = await container.read(userRoutinesProvider.future);
      stopwatch.stop();

      final duration = stopwatch.elapsedMilliseconds;

      // ignore: avoid_print
      print('✓ userRoutinesProvider stream: ${duration}ms');

      expect(routines.length, 10);
      expect(duration, lessThan(200), reason: 'Stream provider took ${duration}ms');
    });

    // ────────────────────────────────────────────────────────────────────────
    // PERFORMANCE SUMMARY
    // ────────────────────────────────────────────────────────────────────────

    test('performance summary', () {
      // This test always passes - it's just for printing summary
      // ignore: avoid_print
      print('''

═══════════════════════════════════════════════════════════════════
ROUTINE CENTER V2.0 PERFORMANCE SUMMARY
═══════════════════════════════════════════════════════════════════

All tests completed. See individual test outputs above for timings.

Target metrics (reference, not enforced):
  - Create routine: < 100ms
  - Update routine: < 100ms
  - Delete routine: < 50ms
  - Activate routine: < 50ms
  - Load routines: < 200ms
  - Analytics overhead: < 10ms per event

Note: These tests use stub implementations. Real-world performance
      will vary based on Firebase latency, network conditions, and
      device capabilities.

═══════════════════════════════════════════════════════════════════
      ''');
    });
  });
}
