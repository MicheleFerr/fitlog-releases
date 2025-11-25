/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/routine/presentation/providers
/// 🎯 Feature: flexible_routine
/// 🔧 Type: provider test
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE NOTIFIER PROVIDER TESTS
///
/// Tests:
/// - FlexibleRoutineNotifier state transitions (loading → success/error)
/// - CRUD operations (create, update, delete, activate, deactivate)
/// - Error handling and state management
/// - Provider dependency injection (userId required)
/// - Stream providers (activeRoutine, userRoutines)
/// - Computed providers (hasActiveRoutine, routineCount, isRoutineCreationComplete)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_providers.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

// ────────────────────────────────────────────────────────────────────────────
// STUB REPOSITORY (For Testing)
// ────────────────────────────────────────────────────────────────────────────

class StubRoutineRepository implements RoutineRepository {
  StubRoutineRepository({
    this.shouldThrowError = false,
    this.errorMessage = 'Test error',
  });

  final bool shouldThrowError;
  final String errorMessage;

  final List<FlexibleRoutine> _routines = [];
  FlexibleRoutine? _activeRoutine;

  @override
  Future<void> createRoutine(FlexibleRoutine routine) async {
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate async
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    _routines.add(routine);
    _activeRoutine = routine;
  }

  @override
  Future<void> updateRoutine(FlexibleRoutine routine) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      _routines[index] = routine;
    }
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    _routines.removeWhere((r) => r.id == routineId);
  }

  @override
  Future<void> activateRoutine(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    final routine = _routines.firstWhere((r) => r.id == routineId);
    _activeRoutine = routine;
  }

  @override
  Future<void> deactivateAllRoutines(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    _activeRoutine = null;
  }

  @override
  Future<FlexibleRoutine?> getActiveRoutine(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return _activeRoutine;
  }

  @override
  Future<List<FlexibleRoutine>> getUserRoutines(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return _routines;
  }

  @override
  Future<FlexibleRoutine?> getRoutineById(String routineId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    try {
      return _routines.firstWhere((r) => r.id == routineId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId) {
    if (shouldThrowError) {
      return Stream.error(Exception(errorMessage));
    }
    return Stream.value(_activeRoutine);
  }

  @override
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId) {
    if (shouldThrowError) {
      return Stream.error(Exception(errorMessage));
    }
    return Stream.value(_routines);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// STUB ANALYTICS SERVICE (For Testing)
// ────────────────────────────────────────────────────────────────────────────

class StubAnalyticsService implements IAnalyticsService {
  final List<Map<String, dynamic>> loggedEvents = [];

  @override
  Future<void> initialize() async {
    // No-op for testing
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    // No-op for testing
  }

  @override
  Future<bool> isAnalyticsCollectionEnabled() async {
    return true;
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    loggedEvents.add({
      'name': name,
      'parameters': parameters ?? {},
    });
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
  Future<void> setUserId(String? userId) async {
    // No-op for testing
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    // No-op for testing
  }

  @override
  Future<String> startTrace(String name) async {
    return 'trace-$name';
  }

  @override
  Future<void> stopTrace(
    String traceId, {
    Map<String, int>? metrics,
    Map<String, String>? attributes,
  }) async {
    // No-op for testing
  }

  @override
  Future<void> logNetworkRequest({
    required String url,
    required String httpMethod,
    int? requestPayloadSize,
    int? responsePayloadSize,
    int? httpResponseCode,
    int? responseTime,
  }) async {
    // No-op for testing
  }

  @override
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {
    // No-op for testing
  }

  @override
  Future<void> setDebugMode(bool enabled) async {
    // No-op for testing
  }

  @override
  Future<void> resetAnalyticsData() async {
    loggedEvents.clear();
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

void main() {
  group('FlexibleRoutineNotifier Provider Tests', () {
    // ────────────────────────────────────────────────────────────────────────
    // SETUP
    // ────────────────────────────────────────────────────────────────────────

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
    // PROVIDER DEPENDENCY INJECTION
    // ────────────────────────────────────────────────────────────────────────

    group('Provider Dependency Injection', () {
      test('throws exception when userId is null', () {
        final containerNoUser = ProviderContainer(
          overrides: [
            routineRepositoryProvider.overrideWith((ref) => stubRepository),
            currentUserIdProvider.overrideWith((ref) => null), // No user
            analyticsServiceProvider.overrideWith((ref) => StubAnalyticsService()),
          ],
        );

        expect(
          () => containerNoUser.read(flexibleRoutineNotifierProvider),
          throwsA(isA<Exception>()),
        );

        containerNoUser.dispose();
      });

      test('provides notifier when userId is present', () {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
        expect(notifier, isA<FlexibleRoutineNotifier>());
      });

      test('uses injected repository', () {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
        expect(notifier, isNotNull);
        // Repository is used internally (verified by operation tests)
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // INITIAL STATE
    // ────────────────────────────────────────────────────────────────────────

    group('Initial State', () {
      test('starts with empty state', () {
        final state = container.read(flexibleRoutineNotifierProvider);

        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
        expect(state.successMessage, isNull);
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // CREATE ROUTINE
    // ────────────────────────────────────────────────────────────────────────

    group('Create Routine', () {
      test('success: transitions loading → success', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
        final routine = createTestRoutine();

        // Initial state
        var state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);

        // Start operation
        final future = notifier.createRoutine(routine);

        // Loading state (may be immediate)
        await Future.delayed(const Duration(milliseconds: 1));
        state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, true);
        expect(state.errorMessage, isNull);

        // Wait for completion
        await future;

        // Success state
        state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.successMessage, 'Routine created successfully');
        expect(state.errorMessage, isNull);
      });

      test('error: transitions loading → error', () async {
        // Create repository that throws
        final errorRepository = StubRoutineRepository(
          shouldThrowError: true,
          errorMessage: 'Failed to create routine',
        );

        final errorContainer = ProviderContainer(
          overrides: [
            routineRepositoryProvider.overrideWith((ref) => errorRepository),
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
            analyticsServiceProvider.overrideWith((ref) => StubAnalyticsService()),
          ],
        );

        final notifier = errorContainer.read(flexibleRoutineNotifierProvider.notifier);
        final routine = createTestRoutine();

        // Attempt operation
        await notifier.createRoutine(routine);

        // Error state
        final state = errorContainer.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.successMessage, isNull);
        expect(state.errorMessage, contains('Failed to create routine'));

        errorContainer.dispose();
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // UPDATE ROUTINE
    // ────────────────────────────────────────────────────────────────────────

    group('Update Routine', () {
      test('success: transitions loading → success', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
        final routine = createTestRoutine();

        // Create first
        await notifier.createRoutine(routine);

        // Reset state for clarity
        notifier.reset();

        // Update
        final updatedRoutine = routine.copyWith(name: 'Updated Name');
        await notifier.updateRoutine(updatedRoutine);

        // Success state
        final state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.successMessage, 'Routine updated successfully');
        expect(state.errorMessage, isNull);
      });

      test('error: transitions loading → error', () async {
        final errorRepository = StubRoutineRepository(
          shouldThrowError: true,
          errorMessage: 'Failed to update routine',
        );

        final errorContainer = ProviderContainer(
          overrides: [
            routineRepositoryProvider.overrideWith((ref) => errorRepository),
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
            analyticsServiceProvider.overrideWith((ref) => StubAnalyticsService()),
          ],
        );

        final notifier = errorContainer.read(flexibleRoutineNotifierProvider.notifier);
        final routine = createTestRoutine();

        await notifier.updateRoutine(routine);

        final state = errorContainer.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.errorMessage, contains('Failed to update routine'));

        errorContainer.dispose();
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // DELETE ROUTINE
    // ────────────────────────────────────────────────────────────────────────

    group('Delete Routine', () {
      test('success: transitions loading → success', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
        final routine = createTestRoutine();

        // Create first
        await notifier.createRoutine(routine);

        // Reset state
        notifier.reset();

        // Delete
        await notifier.deleteRoutine(routine.id);

        // Success state
        final state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.successMessage, 'Routine deleted successfully');
        expect(state.errorMessage, isNull);
      });

      test('error: transitions loading → error', () async {
        final errorRepository = StubRoutineRepository(
          shouldThrowError: true,
          errorMessage: 'Failed to delete routine',
        );

        final errorContainer = ProviderContainer(
          overrides: [
            routineRepositoryProvider.overrideWith((ref) => errorRepository),
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
            analyticsServiceProvider.overrideWith((ref) => StubAnalyticsService()),
          ],
        );

        final notifier = errorContainer.read(flexibleRoutineNotifierProvider.notifier);

        await notifier.deleteRoutine('routine-test');

        final state = errorContainer.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.errorMessage, contains('Failed to delete routine'));

        errorContainer.dispose();
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // ACTIVATE ROUTINE
    // ────────────────────────────────────────────────────────────────────────

    group('Activate Routine', () {
      test('success: transitions loading → success', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);
        final routine = createTestRoutine();

        // Create first
        await notifier.createRoutine(routine);

        // Reset state
        notifier.reset();

        // Activate
        await notifier.activateRoutine(routine.id);

        // Success state
        final state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.successMessage, 'Routine activated successfully');
        expect(state.errorMessage, isNull);
      });

      test('error: transitions loading → error', () async {
        final errorRepository = StubRoutineRepository(
          shouldThrowError: true,
          errorMessage: 'Failed to activate routine',
        );

        final errorContainer = ProviderContainer(
          overrides: [
            routineRepositoryProvider.overrideWith((ref) => errorRepository),
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
            analyticsServiceProvider.overrideWith((ref) => StubAnalyticsService()),
          ],
        );

        final notifier = errorContainer.read(flexibleRoutineNotifierProvider.notifier);

        await notifier.activateRoutine('routine-test');

        final state = errorContainer.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.errorMessage, contains('Failed to activate routine'));

        errorContainer.dispose();
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // DEACTIVATE ALL ROUTINES
    // ────────────────────────────────────────────────────────────────────────

    group('Deactivate All Routines', () {
      test('success: transitions loading → success', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);

        await notifier.deactivateAllRoutines();

        final state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.successMessage, 'All routines deactivated');
        expect(state.errorMessage, isNull);
      });

      test('error: transitions loading → error', () async {
        final errorRepository = StubRoutineRepository(
          shouldThrowError: true,
          errorMessage: 'Failed to deactivate routines',
        );

        final errorContainer = ProviderContainer(
          overrides: [
            routineRepositoryProvider.overrideWith((ref) => errorRepository),
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
            analyticsServiceProvider.overrideWith((ref) => StubAnalyticsService()),
          ],
        );

        final notifier = errorContainer.read(flexibleRoutineNotifierProvider.notifier);

        await notifier.deactivateAllRoutines();

        final state = errorContainer.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.errorMessage, contains('Failed to deactivate routines'));

        errorContainer.dispose();
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // STATE MANAGEMENT METHODS
    // ────────────────────────────────────────────────────────────────────────

    group('State Management Methods', () {
      test('clearError() removes error message', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);

        // Create error state
        final errorRepository = StubRoutineRepository(shouldThrowError: true);
        final errorContainer = ProviderContainer(
          overrides: [
            routineRepositoryProvider.overrideWith((ref) => errorRepository),
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
            analyticsServiceProvider.overrideWith((ref) => StubAnalyticsService()),
          ],
        );

        final errorNotifier = errorContainer.read(flexibleRoutineNotifierProvider.notifier);
        await errorNotifier.createRoutine(createTestRoutine());

        // Verify error exists
        var state = errorContainer.read(flexibleRoutineNotifierProvider);
        expect(state.errorMessage, isNotNull);

        // Clear error
        errorNotifier.clearError();

        // Verify error cleared
        state = errorContainer.read(flexibleRoutineNotifierProvider);
        expect(state.errorMessage, isNull);

        errorContainer.dispose();
      });

      test('clearSuccess() removes success message', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);

        // Create success state
        await notifier.createRoutine(createTestRoutine());

        // Verify success exists
        var state = container.read(flexibleRoutineNotifierProvider);
        expect(state.successMessage, isNotNull);

        // Clear success
        notifier.clearSuccess();

        // Verify success cleared
        state = container.read(flexibleRoutineNotifierProvider);
        expect(state.successMessage, isNull);
      });

      test('reset() returns to initial state', () async {
        final notifier = container.read(flexibleRoutineNotifierProvider.notifier);

        // Create success state
        await notifier.createRoutine(createTestRoutine());

        // Verify non-initial state
        var state = container.read(flexibleRoutineNotifierProvider);
        expect(state.successMessage, isNotNull);

        // Reset
        notifier.reset();

        // Verify initial state
        state = container.read(flexibleRoutineNotifierProvider);
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
        expect(state.successMessage, isNull);
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // STREAM PROVIDERS
    // ────────────────────────────────────────────────────────────────────────

    group('Stream Providers', () {
      test('activeRoutineProvider emits stream from repository', () async {
        final routine = createTestRoutine();
        stubRepository._activeRoutine = routine;

        // Wait for stream to emit data
        final activeRoutine = await container.read(activeRoutineProvider.future);

        expect(activeRoutine, equals(routine));
      });

      test('activeRoutineProvider returns null when no active routine', () async {
        stubRepository._activeRoutine = null;

        // Wait for stream to emit data
        final activeRoutine = await container.read(activeRoutineProvider.future);

        expect(activeRoutine, isNull);
      });

      test('userRoutinesProvider emits stream from repository', () async {
        final routine1 = createTestRoutine(id: 'routine-1');
        final routine2 = createTestRoutine(id: 'routine-2');
        stubRepository._routines.addAll([routine1, routine2]);

        // Wait for stream to emit data
        final userRoutines = await container.read(userRoutinesProvider.future);

        expect(userRoutines, equals([routine1, routine2]));
      });

      test('userRoutinesProvider returns empty list when no routines', () async {
        // Wait for stream to emit data
        final userRoutines = await container.read(userRoutinesProvider.future);

        expect(userRoutines, isEmpty);
      });
    });

    // ────────────────────────────────────────────────────────────────────────
    // COMPUTED PROVIDERS
    // ────────────────────────────────────────────────────────────────────────

    group('Computed Providers', () {
      test('hasActiveRoutineProvider returns true when active routine exists', () async {
        stubRepository._activeRoutine = createTestRoutine();

        // Wait for activeRoutineProvider to emit data
        await container.read(activeRoutineProvider.future);

        final hasActive = container.read(hasActiveRoutineProvider);
        expect(hasActive, true);
      });

      test('hasActiveRoutineProvider returns false when no active routine', () async {
        stubRepository._activeRoutine = null;

        // Wait for activeRoutineProvider to emit data
        await container.read(activeRoutineProvider.future);

        final hasActive = container.read(hasActiveRoutineProvider);
        expect(hasActive, false);
      });

      test('routineCountProvider returns correct count', () async {
        stubRepository._routines.addAll([
          createTestRoutine(id: 'routine-1'),
          createTestRoutine(id: 'routine-2'),
          createTestRoutine(id: 'routine-3'),
        ]);

        // Wait for userRoutinesProvider to emit data
        await container.read(userRoutinesProvider.future);

        final count = container.read(routineCountProvider);
        expect(count, 3);
      });

      test('routineCountProvider returns 0 when no routines', () async {
        // Wait for userRoutinesProvider to emit data
        await container.read(userRoutinesProvider.future);

        final count = container.read(routineCountProvider);
        expect(count, 0);
      });

      test('isRoutineCreationCompleteProvider returns false when preset is null', () {
        // No preset selected
        container.read(selectedPresetProvider.notifier).state = null;
        container.read(trainingDaysProvider.notifier).state = {1, 2, 3};
        container.read(dayTemplatesProvider.notifier).state = {
          1: WorkoutTemplate(
            id: 'template-1',
            name: 'Template 1',
            description: '',
            exercises: const [],
            isPublic: false,
          ),
        };

        final isComplete = container.read(isRoutineCreationCompleteProvider);
        expect(isComplete, false);
      });

      test('isRoutineCreationCompleteProvider returns false when training days empty', () {
        container.read(selectedPresetProvider.notifier).state = RoutinePreset.ppl6Day;
        container.read(trainingDaysProvider.notifier).state = {}; // Empty
        container.read(dayTemplatesProvider.notifier).state = {};

        final isComplete = container.read(isRoutineCreationCompleteProvider);
        expect(isComplete, false);
      });

      test('isRoutineCreationCompleteProvider returns false when template missing for day', () {
        container.read(selectedPresetProvider.notifier).state = RoutinePreset.ppl6Day;
        container.read(trainingDaysProvider.notifier).state = {1, 2, 3};
        container.read(dayTemplatesProvider.notifier).state = {
          1: WorkoutTemplate(
            id: 'template-1',
            name: 'Template 1',
            description: '',
            exercises: const [],
            isPublic: false,
          ),
          // Missing template for day 2 and 3
        };

        final isComplete = container.read(isRoutineCreationCompleteProvider);
        expect(isComplete, false);
      });

      test('isRoutineCreationCompleteProvider returns true when all fields valid', () {
        container.read(selectedPresetProvider.notifier).state = RoutinePreset.ppl6Day;
        container.read(trainingDaysProvider.notifier).state = {1, 2, 3};
        container.read(dayTemplatesProvider.notifier).state = {
          1: WorkoutTemplate(
            id: 'template-1',
            name: 'Template 1',
            description: '',
            exercises: const [],
            isPublic: false,
          ),
          2: WorkoutTemplate(
            id: 'template-2',
            name: 'Template 2',
            description: '',
            exercises: const [],
            isPublic: false,
          ),
          3: WorkoutTemplate(
            id: 'template-3',
            name: 'Template 3',
            description: '',
            exercises: const [],
            isPublic: false,
          ),
        };

        final isComplete = container.read(isRoutineCreationCompleteProvider);
        expect(isComplete, true);
      });
    });
  });
}
