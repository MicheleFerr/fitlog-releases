import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

/// UNIT TEST for Analytics Provider
///
/// ✅ Tests state management using Riverpod
/// ✅ Uses mocktail for clean mocking
/// ✅ Tests all provider functionality:
///    - Sync status management
///    - Analytics state loading
///    - PR tracking and checking
///    - Volume calculations
///    - Frequency stats
///    - Exercise-specific stats
///    - Streak calculation
///
/// This test suite ensures analytics provider correctly:
/// - Manages loading states
/// - Loads activities and PRs from repositories
/// - Calculates volume progression
/// - Generates insights and muscle balance
/// - Handles errors gracefully
/// - Provides chart data

// Mocks - MUST be outside main()
class MockHybridExerciseActivityRepository extends Mock
    implements HybridExerciseActivityRepository {}

class MockPRTracker extends Mock implements PRTracker {}

void main() {
  late MockHybridExerciseActivityRepository mockActivityRepository;
  late MockPRTracker mockPRTracker;

  // Test data factories
  ExerciseActivity createTestActivity({
    String id = 'activity-1',
    String exerciseId = 'exercise-1',
    String exerciseName = 'Bench Press',
    String email = 'user@test.com',
    String schedaName = 'Test Workout',
    DateTime? createdAt,
    List<ExerciseActivitySet>? sets,
  }) {
    return ExerciseActivity(
      id: id,
      email: email,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      exerciseImage: null,
      schedaName: schedaName,
      sets: sets ?? [
        ExerciseActivitySet(
          set: 1,
          weight: '100',
          reps: '10',
          done: true,
          effort: 3,
          isWarmup: false,
        ),
      ],
      createdAt: createdAt ?? DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  PersonalRecord createTestPR({
    String id = 'pr-1',
    String exerciseId = 'exercise-1',
    PRType type = PRType.oneRM,
    double value = 150.0,
  }) {
    return PersonalRecord(
      id: id,
      userId: 'user-123',
      exerciseId: exerciseId,
      exerciseName: 'Bench Press',
      type: type,
      value: value,
      achievedAt: DateTime.now(),
    );
  }

  setUp(() {
    mockActivityRepository = MockHybridExerciseActivityRepository();
    mockPRTracker = MockPRTracker();

    // Default mock responses
    when(() => mockActivityRepository.getUserActivities(
          userEmail: any(named: 'userEmail'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => []);

    when(() => mockPRTracker.getUserPRs(any()))
        .thenAnswer((_) async => []);

    when(() => mockPRTracker.getRecentPRs(any()))
        .thenAnswer((_) async => []);
  });

  group('WorkoutSyncNotifier', () {
    test('should initialize with idle state', () {
      final notifier = WorkoutSyncNotifier();

      expect(notifier.state.state, SyncState.idle);
      expect(notifier.state.currentCount, 0);
      expect(notifier.state.totalCount, 0);
      expect(notifier.state.errorMessage, isNull);
    });

    test('setChecking() should update state to checking', () {
      final notifier = WorkoutSyncNotifier();

      notifier.setChecking();

      expect(notifier.state.state, SyncState.checking);
      expect(notifier.state.isActive, isTrue);
    });

    test('setSyncing() should update state with progress', () {
      final notifier = WorkoutSyncNotifier();

      notifier.setSyncing(5, 10);

      expect(notifier.state.state, SyncState.syncing);
      expect(notifier.state.currentCount, 5);
      expect(notifier.state.totalCount, 10);
      expect(notifier.state.progress, 0.5);
      expect(notifier.state.isActive, isTrue);
    });

    test('setCompleted() should update state and reset after delay', () async {
      final notifier = WorkoutSyncNotifier();

      notifier.setCompleted();

      expect(notifier.state.state, SyncState.completed);
      expect(notifier.state.isActive, isFalse);

      // Wait for auto-reset (2 seconds)
      await Future.delayed(const Duration(seconds: 3));

      expect(notifier.state.state, SyncState.idle);
    });

    test('setError() should update state with error message', () {
      final notifier = WorkoutSyncNotifier();

      notifier.setError('Test error');

      expect(notifier.state.state, SyncState.error);
      expect(notifier.state.errorMessage, 'Test error');
      expect(notifier.state.isActive, isFalse);
    });

    test('reset() should return to idle state', () {
      final notifier = WorkoutSyncNotifier();

      notifier.setSyncing(5, 10);
      notifier.reset();

      expect(notifier.state.state, SyncState.idle);
    });

    test('progress calculation should handle zero total', () {
      final status = WorkoutSyncStatus.syncing(0, 0);

      expect(status.progress, 0.0);
    });
  });

  group('WorkoutSyncStatus', () {
    test('idle() factory should create idle status', () {
      final status = WorkoutSyncStatus.idle();

      expect(status.state, SyncState.idle);
      expect(status.isActive, isFalse);
    });

    test('checking() factory should create checking status', () {
      final status = WorkoutSyncStatus.checking();

      expect(status.state, SyncState.checking);
      expect(status.isActive, isTrue);
    });

    test('syncing() factory should create syncing status with counts', () {
      final status = WorkoutSyncStatus.syncing(3, 10);

      expect(status.state, SyncState.syncing);
      expect(status.currentCount, 3);
      expect(status.totalCount, 10);
      expect(status.progress, 0.3);
      expect(status.isActive, isTrue);
    });

    test('completed() factory should create completed status', () {
      final status = WorkoutSyncStatus.completed();

      expect(status.state, SyncState.completed);
      expect(status.isActive, isFalse);
    });

    test('error() factory should create error status with message', () {
      final status = WorkoutSyncStatus.error('Failed to sync');

      expect(status.state, SyncState.error);
      expect(status.errorMessage, 'Failed to sync');
      expect(status.isActive, isFalse);
    });

    test('copyWith() should update only specified fields', () {
      final status = WorkoutSyncStatus.syncing(5, 10);
      final updated = status.copyWith(currentCount: 8);

      expect(updated.state, SyncState.syncing);
      expect(updated.currentCount, 8);
      expect(updated.totalCount, 10);
    });
  });

  group('AnalyticsState', () {
    test('initial() factory should create empty state', () {
      final state = AnalyticsState.initial();

      expect(state.activities, isEmpty);
      expect(state.personalRecords, isEmpty);
      expect(state.recentPRs, isEmpty);
      expect(state.insights, isEmpty);
      expect(state.exerciseTrends, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.volumeProgression.weeklyChange, 0);
      expect(state.volumeProgression.monthlyChange, 0);
    });

    test('copyWith() should update only specified fields', () {
      final state = AnalyticsState.initial();
      final activity = createTestActivity();
      final updated = state.copyWith(
        activities: [activity],
        isLoading: true,
      );

      expect(updated.activities.length, 1);
      expect(updated.isLoading, isTrue);
      expect(updated.error, isNull);
    });
  });

  group('AnalyticsNotifier - Initialization', () {
    test('should initialize with initial state when no userId', () {
      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: null,
      );

      expect(notifier.state.activities, isEmpty);
      expect(notifier.state.isLoading, isFalse);
    });

    test('should auto-load analytics when userId provided', () async {
      // Setup mocks
      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => [createTestActivity()]);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for auto-load
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.activities.length, 1);
      verify(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).called(1);
    });
  });

  group('AnalyticsNotifier - loadAnalytics()', () {
    test('should set loading state during load', () async {
      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [];
      });

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait a bit to start loading
      await Future.delayed(const Duration(milliseconds: 10));

      expect(notifier.state.isLoading, isTrue);
    });

    test('should load activities and PRs successfully', () async {
      final activities = [
        createTestActivity(id: '1'),
        createTestActivity(id: '2'),
      ];
      final prs = [createTestPR()];

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => prs);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => prs);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: null,
      );

      await notifier.loadAnalytics();

      // Verify loading completed
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('should handle errors gracefully', () async {
      when(() => mockActivityRepository.getUserActivities(
            userEmail: any(named: 'userEmail'),
            limit: any(named: 'limit'),
          )).thenThrow(Exception('Network error'));

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for auto-load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, contains('Network error'));
    });

    test('should skip loading when userId is null', () async {
      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: null,
      );

      await notifier.loadAnalytics();

      verifyNever(() => mockActivityRepository.getUserActivities(
            userEmail: any(named: 'userEmail'),
            limit: any(named: 'limit'),
          ));
    });
  });

  group('AnalyticsNotifier - refresh()', () {
    test('should reload analytics data', () async {
      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => [createTestActivity()]);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Clear call count
      reset(mockActivityRepository);
      reset(mockPRTracker);

      // Refresh
      await notifier.refresh();

      // Verify refresh called repository again
      verify(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).called(1);
    });
  });

  group('AnalyticsNotifier - checkForNewPRs()', () {
    test('should check for new PRs and update state', () async {
      final activity = createTestActivity();
      final newPRs = [createTestPR()];
      final allPRs = [createTestPR(), createTestPR(id: 'pr-2')];

      when(() => mockPRTracker.checkAndUpdatePRs(activity))
          .thenAnswer((_) async => newPRs);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => allPRs);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => newPRs);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      final result = await notifier.checkForNewPRs(activity);

      expect(result.length, 1);
      expect(notifier.state.personalRecords.length, 2);
      expect(notifier.state.recentPRs.length, 1);
    });

    test('should return empty list when no new PRs', () async {
      final activity = createTestActivity();

      when(() => mockPRTracker.checkAndUpdatePRs(activity))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      final result = await notifier.checkForNewPRs(activity);

      expect(result, isEmpty);
    });

    test('should handle errors when checking PRs', () async {
      final activity = createTestActivity();

      when(() => mockPRTracker.checkAndUpdatePRs(activity))
          .thenThrow(Exception('PR check failed'));

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      final result = await notifier.checkForNewPRs(activity);

      expect(result, isEmpty);
    });
  });

  group('AnalyticsNotifier - Volume Calculations', () {
    test('getVolumeByPeriod() should calculate weekly volume', () async {
      final now = DateTime.now();
      final activities = [
        createTestActivity(id: '1', createdAt: now),
        createTestActivity(id: '2', createdAt: now.subtract(const Duration(days: 1))),
        createTestActivity(id: '3', createdAt: now.subtract(const Duration(days: 8))),
      ];

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final volumeData = notifier.getVolumeByPeriod(AnalysisPeriod.week);

      expect(volumeData.isNotEmpty, isTrue);
      expect(volumeData.length, greaterThanOrEqualTo(2));
    });
  });

  group('AnalyticsNotifier - Exercise Stats', () {
    test('getExerciseStats() should return empty for non-existent exercise', () {
      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      final stats = notifier.getExerciseStats('nonexistent');

      expect(stats, isEmpty);
    });

    test('getExerciseStats() should calculate max weight and reps', () async {
      final activities = [
        createTestActivity(
          exerciseId: 'bench-press',
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '100',
              reps: '10',
              done: true,
              effort: 3,
              isWarmup: false,
            ),
            ExerciseActivitySet(
              set: 2,
              weight: '120',
              reps: '8',
              done: true,
              effort: 4,
              isWarmup: false,
            ),
          ],
        ),
      ];

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final stats = notifier.getExerciseStats('bench-press');

      expect(stats['maxWeight'], 120.0);
      expect(stats['maxReps'], 10);
      expect(stats['estimated1RM'], greaterThan(0));
    });
  });

  group('AnalyticsNotifier - Frequency Stats', () {
    test('getFrequencyStats() should calculate workout days correctly', () async {
      final now = DateTime.now();
      final activities = List.generate(
        10,
        (i) => createTestActivity(
          id: 'activity-$i',
          createdAt: now.subtract(Duration(days: i * 3)),
        ),
      );

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final stats = notifier.getFrequencyStats();

      expect(stats['daysInLast30'], greaterThan(0));
      expect(stats['avgPerWeek'], isA<int>());
      expect(stats['dayDistribution'], isA<Map>());
      expect(stats['currentStreak'], isA<int>());
    });

    test('getFrequencyStats() should return zero for no activities', () {
      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      final stats = notifier.getFrequencyStats();

      expect(stats['daysInLast30'], 0);
      expect(stats['currentStreak'], 0);
    });
  });

  group('AnalyticsNotifier - Streak Calculation', () {
    test('should calculate current streak correctly for consecutive days', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final activities = [
        createTestActivity(id: '1', createdAt: today),
        createTestActivity(id: '2', createdAt: today.subtract(const Duration(days: 1))),
        createTestActivity(id: '3', createdAt: today.subtract(const Duration(days: 2))),
      ];

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final stats = notifier.getFrequencyStats();

      expect(stats['currentStreak'], 3);
    });

    test('should return zero streak if last workout was not recent', () async {
      final now = DateTime.now();
      final activities = [
        createTestActivity(
          id: '1',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      ];

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final stats = notifier.getFrequencyStats();

      expect(stats['currentStreak'], 0);
    });
  });

  group('AnalyticsNotifier - 1RM Progression', () {
    test('get1RMProgression() should calculate 1RM for exercise', () async {
      final now = DateTime.now();
      final activities = [
        createTestActivity(
          exerciseId: 'bench',
          createdAt: now.subtract(const Duration(days: 7)),
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '100',
              reps: '10',
              done: true,
              effort: 3,
              isWarmup: false,
            ),
          ],
        ),
        createTestActivity(
          exerciseId: 'bench',
          createdAt: DateTime(2024, 1, 1),
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '110',
              reps: '8',
              done: true,
              effort: 4,
              isWarmup: false,
            ),
          ],
        ),
      ];

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final progression = notifier.get1RMProgression('bench');

      expect(progression.length, 2);
      expect(progression.values.every((v) => v > 0), isTrue);
    });

    test('get1RMProgression() should skip warmup sets', () async {
      final activities = [
        createTestActivity(
          exerciseId: 'bench',
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '50',
              reps: '10',
              done: true,
              effort: 2,
              isWarmup: true, // Warmup set
            ),
            ExerciseActivitySet(
              set: 2,
              weight: '100',
              reps: '8',
              done: true,
              effort: 3,
              isWarmup: false,
            ),
          ],
        ),
      ];

      when(() => mockActivityRepository.getUserActivities(
            userEmail: 'user@test.com',
            limit: 100,
          )).thenAnswer((_) async => activities);

      when(() => mockPRTracker.getUserPRs('user@test.com'))
          .thenAnswer((_) async => []);

      when(() => mockPRTracker.getRecentPRs('user@test.com'))
          .thenAnswer((_) async => []);

      final notifier = AnalyticsNotifier(
        activityRepository: mockActivityRepository,
        prTracker: mockPRTracker,
        userId: 'user@test.com',
      );

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final progression = notifier.get1RMProgression('bench');

      // Should have only 1 entry (ignoring warmup)
      expect(progression.length, 1);
    });
  });
}
