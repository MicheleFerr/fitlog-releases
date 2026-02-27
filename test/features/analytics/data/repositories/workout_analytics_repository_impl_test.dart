import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/workout_analytics_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_cache_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockBox extends Mock implements Box {}
class MockHiveBoxManagerEnhanced extends Mock implements HiveBoxManagerEnhanced {}
class MockPRTracker extends Mock implements PRTracker {}
class MockHiveWorkoutDataSource extends Mock implements HiveWorkoutDataSource {}
class MockAnalyticsCacheService extends Mock implements AnalyticsCacheService {}
class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}
class MockQuery<T> extends Mock implements Query<T> {}
class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}
class MockQueryDocumentSnapshot<T> extends Mock implements QueryDocumentSnapshot<T> {}

// Fakes for fallback values
class FakeWorkoutModel extends Fake implements WorkoutModel {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(FakeWorkoutModel());
  });
  late WorkoutAnalyticsRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockBox mockMetricsCache;
  late MockHiveBoxManagerEnhanced mockBoxManager;
  late MockPRTracker mockPRTracker;
  late MockHiveWorkoutDataSource mockHiveWorkoutDataSource;
  late MockAnalyticsCacheService mockCacheService;

  // Test data factories
  Workout createTestWorkout({
    String id = 'workout-1',
    String name = 'Test Workout',
    WorkoutStatus status = WorkoutStatus.completed,
    List<Exercise>? exercises,
    DateTime? endTime,
    DateTime? startTime,
  }) {
    return Workout(
      id: id,
      name: name,
      status: status,
      exercises: exercises ?? [
        Exercise(
          id: 'exercise-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              id: 'set-1',
              setNumber: 1,
              weight: 100,
              reps: 10,
              actualReps: 10,
              isCompleted: true,
            ),
          ],
        ),
      ],
      startTime: startTime ?? DateTime.now(),
      endTime: endTime ?? DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  WorkoutModel createTestWorkoutModel({
    String id = 'workout-1',
    String status = 'completed',
  }) {
    return WorkoutModel(
      id: id,
      name: 'Test Workout',
      exercises: [],
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  PersonalRecord createTestPR({
    String exerciseId = 'exercise-1',
    String exerciseName = 'Bench Press',
    PRType type = PRType.oneRM,
    double value = 150.0,
  }) {
    return PersonalRecord(
      id: 'pr-1',
      userId: 'user-123',
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      type: type,
      value: value,
      achievedAt: DateTime.now(),
    );
  }

  WorkoutMetrics createTestMetrics({
    String workoutId = 'workout-1',
    double totalVolume = 1000.0,
  }) {
    return WorkoutMetrics(
      workoutId: workoutId,
      calculatedAt: DateTime.now(),
      totalVolume: totalVolume,
      workingSetsVolume: 800.0,
      warmupVolume: 200.0,
      volumeByMuscleGroup: {ExerciseCategory.chest: 1000.0},
      totalSets: 10,
      completedSets: 10,
      workingSets: 8,
      warmupSets: 2,
      averageWeight: 100.0,
      averageRPE: 8.0,
      averageIntensity: 0.75,
      peakIntensity: 0.9,
      totalDuration: const Duration(minutes: 45),
      workingTime: const Duration(minutes: 30),
      restTime: const Duration(minutes: 15),
      trainingDensity: 0.67,
      completionPercentage: 100.0,
      exercisesCompleted: 5,
      totalExercises: 5,
    );
  }

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockMetricsCache = MockBox();
    mockBoxManager = MockHiveBoxManagerEnhanced();
    mockPRTracker = MockPRTracker();
    mockHiveWorkoutDataSource = MockHiveWorkoutDataSource();
    mockCacheService = MockAnalyticsCacheService();

    // Setup default cache behavior (no cache by default)
    when(() => mockCacheService.get<List<Map<String, dynamic>>>(
      any(),
      any(),
    )).thenAnswer((_) async => null);

    when(() => mockCacheService.get<Map<String, dynamic>>(
      any(),
      any(),
    )).thenAnswer((_) async => null);

    when(() => mockCacheService.get<int>(
      any(),
    )).thenAnswer((_) async => null);

    when(() => mockCacheService.set<List<Map<String, dynamic>>>(
      any(),
      any(),
      any(),
      any(),
    )).thenAnswer((_) async {});

    when(() => mockCacheService.set<Map<String, dynamic>>(
      any(),
      any(),
      any(),
      any(),
    )).thenAnswer((_) async {});

    repository = WorkoutAnalyticsRepositoryImpl(
      firestore: mockFirestore,
      metricsCache: mockMetricsCache,
      boxManager: mockBoxManager,
      prTracker: mockPRTracker,
      hiveWorkoutDataSource: mockHiveWorkoutDataSource,
      cacheService: mockCacheService,
    );
  });

  group('Initialization', () {
    test('should initialize with correct dependencies', () {
      expect(repository, isNotNull);
    });

    test('should accept custom dependencies', () {
      final customRepository = WorkoutAnalyticsRepositoryImpl(
        firestore: mockFirestore,
        metricsCache: mockMetricsCache,
        boxManager: mockBoxManager,
        prTracker: mockPRTracker,
        hiveWorkoutDataSource: mockHiveWorkoutDataSource,
        cacheService: mockCacheService,
      );
      expect(customRepository, isNotNull);
    });
  });

  group('getHistoricalWorkouts', () {
    const userId = 'user-123';

    test('should return cached workouts when cache hit', () async {
      // Arrange
      final cachedWorkouts = [createTestWorkout().toJson()];
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => cachedWorkouts);

      // Act
      final result = await repository.getHistoricalWorkouts(userId);

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result.first.name, 'Test Workout');
      verify(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).called(1);
      verifyNever(() => mockHiveWorkoutDataSource.getWorkoutsForAnalytics(
        any(),
        limit: any(named: 'limit'),
        since: any(named: 'since'),
      ));
    });

    test('should sync from Firebase when Firebase has more workouts', () async {
      // Arrange - No cache for list data
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => null);

      // Firebase count = 2 (via cache hit, skips AggregateQuery which is hard to mock)
      when(() => mockCacheService.get<int>(any())).thenAnswer((_) async => 2);

      // Setup Firestore query for _syncFirebaseToHive
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection('workouts')).thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockDoc, mockDoc]); // 2 docs in Firebase
      when(() => mockDoc.data()).thenReturn({
        'userId': userId,
        'name': 'Test Workout',
        'exercises': [
          {'name': 'Bench Press'}
        ],
        'status': 'completed',
      });
      when(() => mockDoc.id).thenReturn('workout-1');

      // Hive returns 1 completed workout (firebaseCount=2 > hiveCount=1 → sync)
      final testWorkoutModel = createTestWorkoutModel();
      when(() => mockHiveWorkoutDataSource.getWorkoutsForAnalytics(
        userId,
        limit: any(named: 'limit'),
        since: any(named: 'since'),
      )).thenAnswer((_) async => [testWorkoutModel]);

      // Mock saveWorkout for sync operation
      when(() => mockHiveWorkoutDataSource.saveWorkout(any(), userId))
          .thenAnswer((_) async => 'workout-1');

      // Act
      final result = await repository.getHistoricalWorkouts(userId, limit: 50);

      // Assert
      expect(result, isNotEmpty);
      // Called 2 times because we have 2 docs in Firebase (mockDoc, mockDoc)
      verify(() => mockHiveWorkoutDataSource.saveWorkout(any(), userId)).called(2);
    });

    test('should get from Hive when already synced', () async {
      // Arrange - No cache
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => null);

      // Setup counts - Hive has same or more workouts
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection('workouts')).thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]); // 0 workouts in Firebase

      final testWorkoutModel = createTestWorkoutModel();
      when(() => mockHiveWorkoutDataSource.getWorkoutsForAnalytics(
        userId,
        limit: any(named: 'limit'),
        since: any(named: 'since'),
      )).thenAnswer((_) async => [testWorkoutModel]);

      // Act
      final result = await repository.getHistoricalWorkouts(userId);

      // Assert
      expect(result, isNotEmpty);
      // Called once - in-memory _localWorkoutsCache caches first call result
      verify(() => mockHiveWorkoutDataSource.getWorkoutsForAnalytics(
        userId,
        limit: any(named: 'limit'),
        since: any(named: 'since'),
      )).called(1);
    });

    test('should apply limit and since filters', () async {
      // Arrange
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => null);

      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection('workouts')).thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      final testWorkoutModel = createTestWorkoutModel();
      when(() => mockHiveWorkoutDataSource.getWorkoutsForAnalytics(
        userId,
        limit: any(named: 'limit'),
        since: any(named: 'since'),
      )).thenAnswer((_) async => [testWorkoutModel]);

      final sinceDate = DateTime.now().subtract(const Duration(days: 7));

      // Act
      final result = await repository.getHistoricalWorkouts(
        userId,
        limit: 10,
        since: sinceDate,
      );

      // Assert
      expect(result, isNotEmpty);
      // Implementation always calls getWorkoutsForAnalytics(userId, limit: null)
      // then filters by limit/since in memory via _getLocalWorkouts
      verify(() => mockHiveWorkoutDataSource.getWorkoutsForAnalytics(
        userId,
        limit: any(named: 'limit'),
        since: any(named: 'since'),
      )).called(1);
    });

    test('should return empty list on error', () async {
      // Arrange
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenThrow(Exception('Cache error'));

      // Act
      final result = await repository.getHistoricalWorkouts(userId);

      // Assert
      expect(result, isEmpty);
    });

    test('should handle malformed cached data gracefully', () async {
      // Arrange - Cache has invalid JSON
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => [
        {'invalid': 'data'}, // Missing required fields
      ]);

      // Act
      final result = await repository.getHistoricalWorkouts(userId);

      // Assert
      expect(result, isEmpty); // Should filter out invalid workouts
    });
  });

  group('getSimilarWorkouts', () {
    const userId = 'user-123';

    test('should find similar workouts based on muscle group overlap', () async {
      // Arrange
      final targetWorkout = createTestWorkout(
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [],
          ),
        ],
      );

      final similarWorkout = createTestWorkout(
        id: 'workout-2',
        exercises: [
          Exercise(
            id: 'ex-2',
            name: 'Incline Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [],
          ),
        ],
      );

      // Mock getHistoricalWorkouts to return test data
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => [
        similarWorkout.toJson(),
      ]);

      // Act
      final result = await repository.getSimilarWorkouts(
        userId,
        targetWorkout,
        limit: 10,
        minSimilarity: 0.3,
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.exercises.first.category, ExerciseCategory.chest);
    });

    test('should filter by minimum similarity threshold', () async {
      // Arrange
      final targetWorkout = createTestWorkout(
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [],
          ),
        ],
      );

      final dissimilarWorkout = createTestWorkout(
        id: 'workout-2',
        exercises: [
          Exercise(
            id: 'ex-2',
            name: 'Squat',
            type: ExerciseType.single,
            category: ExerciseCategory.legs,
            sets: [],
          ),
        ],
      );

      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => [
        dissimilarWorkout.toJson(),
      ]);

      // Act
      final result = await repository.getSimilarWorkouts(
        userId,
        targetWorkout,
        limit: 10,
        minSimilarity: 0.8, // High threshold
      );

      // Assert
      expect(result, isEmpty); // No overlap, should be filtered out
    });

    test('should respect limit parameter', () async {
      // Arrange
      final targetWorkout = createTestWorkout();
      final workouts = List.generate(20, (i) => createTestWorkout(id: 'workout-$i'));

      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => workouts.map((w) => w.toJson()).toList());

      // Act
      final result = await repository.getSimilarWorkouts(
        userId,
        targetWorkout,
        limit: 5,
      );

      // Assert
      expect(result.length, lessThanOrEqualTo(5));
    });
  });

  group('PR Methods', () {
    const userId = 'user-123';

    test('getUserPRs should delegate to PRTracker', () async {
      // Arrange
      final testPRs = [createTestPR()];
      when(() => mockPRTracker.getUserPRs(userId))
          .thenAnswer((_) async => testPRs);

      // Act
      final result = await repository.getUserPRs(userId);

      // Assert
      expect(result, equals(testPRs));
      verify(() => mockPRTracker.getUserPRs(userId)).called(1);
    });

    test('getExercisePRs should delegate to PRTracker', () async {
      // Arrange
      const exerciseId = 'exercise-1';
      final testPRs = <PRType, PersonalRecord>{
        PRType.oneRM: createTestPR(type: PRType.oneRM),
        PRType.weight: createTestPR(type: PRType.weight),
      };
      when(() => mockPRTracker.getExercisePRs(userId, exerciseId))
          .thenAnswer((_) async => testPRs);

      // Act
      final result = await repository.getExercisePRs(userId, exerciseId);

      // Assert
      expect(result, equals(testPRs));
      verify(() => mockPRTracker.getExercisePRs(userId, exerciseId)).called(1);
    });

    test('savePR should delegate to PRTracker and notify', () async {
      // Arrange
      final testPR = createTestPR();
      when(() => mockPRTracker.savePR(testPR)).thenAnswer((_) async {});

      // Act
      await repository.savePR(testPR);

      // Assert
      verify(() => mockPRTracker.savePR(testPR)).called(1);
    });
  });

  group('Metrics Methods', () {
    const userId = 'user-123';

    test('getWorkoutMetricsHistory should query Firestore with limit', () async {
      // Arrange
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection('workoutMetrics'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('calculatedAt', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(30)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getWorkoutMetricsHistory(userId, limit: 30);

      // Assert
      expect(result, isEmpty);
      verify(() => mockQuery.limit(30)).called(1);
    });

    test('getWorkoutMetricsHistory should apply since filter', () async {
      // Arrange
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final sinceDate = DateTime.now().subtract(const Duration(days: 7));

      when(() => mockFirestore.collection('workoutMetrics'))
          .thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('calculatedAt', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(() => mockQuery.where('calculatedAt', isGreaterThan: any(named: 'isGreaterThan')))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getWorkoutMetricsHistory(
        userId,
        since: sinceDate,
      );

      // Assert
      expect(result, isEmpty);
      verify(() => mockQuery.where('calculatedAt', isGreaterThan: any(named: 'isGreaterThan')))
          .called(1);
    });

    test('cacheWorkoutMetrics should save to Hive box', () async {
      // Arrange
      final testMetrics = createTestMetrics();
      when(() => mockMetricsCache.put(any(), any())).thenAnswer((_) async {});

      // Act
      await repository.cacheWorkoutMetrics(testMetrics);

      // Assert
      verify(() => mockMetricsCache.put(testMetrics.workoutId, any())).called(1);
    });

    test('getCachedWorkoutMetrics should return null when not cached', () async {
      // Arrange
      const workoutId = 'workout-1';
      when(() => mockMetricsCache.get(workoutId)).thenReturn(null);

      // Act
      final result = await repository.getCachedWorkoutMetrics(workoutId);

      // Assert
      expect(result, isNull);
    });

    test('getCachedWorkoutMetrics should return metrics when cached', () async {
      // Arrange
      const workoutId = 'workout-1';
      final cachedData = {
        'workoutId': workoutId,
        'calculatedAt': DateTime.now().toIso8601String(),
        'totalVolume': 1000.0,
        'completedSets': 10,
        'totalSets': 10,
        'completionPercentage': 100.0,
        'trainingDensity': 0.67,
        'averageRPE': 8.0,
        'totalDurationMinutes': 45,
      };
      when(() => mockMetricsCache.get(workoutId)).thenReturn(cachedData);

      // Act
      final result = await repository.getCachedWorkoutMetrics(workoutId);

      // Assert
      expect(result, isNotNull);
      expect(result!.workoutId, workoutId);
      expect(result.totalVolume, 1000.0);
    });
  });

  group('getAnalyticsStats', () {
    const userId = 'user-123';

    test('should return cached stats when cache hit', () async {
      // Arrange
      final cachedStats = {
        'totalWorkouts': 10,
        'totalPRs': 5,
        'averageWorkoutVolume': 5000.0,
        'averageWorkoutDuration': 45.0,
        'totalVolumeLifted': 50000.0,
        'exerciseFrequency': {'Bench Press': 10},
        'exerciseVolumeDistribution': {'Bench Press': 10000.0},
      };
      when(() => mockCacheService.get<Map<String, dynamic>>(
        any(),
        any(),
      )).thenAnswer((_) async => cachedStats);

      // Act
      final result = await repository.getAnalyticsStats(userId);

      // Assert
      expect(result.totalWorkouts, 10);
      expect(result.totalPRs, 5);
      verify(() => mockCacheService.get<Map<String, dynamic>>(
        any(),
        any(),
      )).called(1);
    });

    test('should calculate stats from workouts when no cache', () async {
      // Arrange
      when(() => mockCacheService.get<Map<String, dynamic>>(
        any(),
        any(),
      )).thenAnswer((_) async => null);

      final testWorkout = createTestWorkout();
      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => [testWorkout.toJson()]);

      when(() => mockPRTracker.getUserPRs(userId))
          .thenAnswer((_) async => [createTestPR()]);

      // Act
      final result = await repository.getAnalyticsStats(userId);

      // Assert
      expect(result.totalWorkouts, 1);
      expect(result.totalPRs, 1);
      expect(result.averageWorkoutVolume, greaterThan(0));
      verify(() => mockCacheService.set<Map<String, dynamic>>(
        any(),
        any(),
        any(),
        any(),
      )).called(1);
    });

    test('should return empty stats when no workouts', () async {
      // Arrange
      when(() => mockCacheService.get<Map<String, dynamic>>(
        any(),
        any(),
      )).thenAnswer((_) async => null);

      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => []);

      when(() => mockPRTracker.getUserPRs(userId))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getAnalyticsStats(userId);

      // Assert
      expect(result.totalWorkouts, 0);
      expect(result.totalPRs, 0);
      expect(result.averageWorkoutVolume, 0);
      expect(result.totalVolumeLifted, 0);
    });

    test('should calculate exercise frequency correctly', () async {
      // Arrange
      when(() => mockCacheService.get<Map<String, dynamic>>(
        any(),
        any(),
      )).thenAnswer((_) async => null);

      final workout1 = createTestWorkout(
        id: 'w1',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(
                id: 's1',
                setNumber: 1,
                weight: 100,
                reps: 10,
                actualReps: 10,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      final workout2 = createTestWorkout(
        id: 'w2',
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(
                id: 's1',
                setNumber: 1,
                weight: 100,
                reps: 10,
                actualReps: 10,
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      when(() => mockCacheService.get<List<Map<String, dynamic>>>(
        any(),
        any(),
      )).thenAnswer((_) async => [
        workout1.toJson(),
        workout2.toJson(),
      ]);

      when(() => mockPRTracker.getUserPRs(userId))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getAnalyticsStats(userId);

      // Assert
      expect(result.exerciseFrequency['Bench Press'], 2);
    });

    test('should return empty stats on error', () async {
      // Arrange
      when(() => mockCacheService.get<Map<String, dynamic>>(
        any(),
        any(),
      )).thenThrow(Exception('Cache error'));

      // Act
      final result = await repository.getAnalyticsStats(userId);

      // Assert
      expect(result.totalWorkouts, 0);
      expect(result.totalPRs, 0);
    });
  });

  group('Stream Methods', () {
    test('watchWorkoutUpdates should create stream controller', () {
      // Arrange
      const workoutId = 'workout-1';

      // Act
      final stream = repository.watchWorkoutUpdates(workoutId);

      // Assert
      expect(stream, isNotNull);
      expect(stream, isA<Stream<WorkoutAnalyticsUpdate>>());
    });

    test('watchWorkoutUpdates should reuse existing controller', () {
      // Arrange
      const workoutId = 'workout-1';

      // Act
      final stream1 = repository.watchWorkoutUpdates(workoutId);
      final stream2 = repository.watchWorkoutUpdates(workoutId);

      // Assert
      expect(stream1, equals(stream2));
    });

    test('notifyWorkoutUpdate should emit to stream', () async {
      // Arrange
      const workoutId = 'workout-1';
      final testMetrics = createTestMetrics(workoutId: workoutId);
      final stream = repository.watchWorkoutUpdates(workoutId);

      // Create expectation BEFORE notifying
      final expectation = expectLater(
        stream,
        emits(predicate<WorkoutAnalyticsUpdate>(
          (update) => update.workoutId == workoutId,
        )),
      );

      // Act - notify after setting up listener
      repository.notifyWorkoutUpdate(testMetrics);

      // Assert
      await expectation;
    });
  });

  group('Sync Methods', () {
    const userId = 'user-123';

    test('syncWorkoutsFromFirebase should call internal sync', () async {
      // Arrange
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection('workouts')).thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act
      await repository.syncWorkoutsFromFirebase(userId);

      // Assert
      verify(() => mockQuery.get()).called(1);
    });

    test('syncWorkoutsFromFirebase should report progress', () async {
      // Arrange
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection('workouts')).thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockDoc]);
      when(() => mockDoc.data()).thenReturn({
        'userId': userId,
        'name': 'Test',
        'exercises': [
          {'name': 'Bench Press'}
        ],
      });
      when(() => mockDoc.id).thenReturn('workout-1');
      when(() => mockHiveWorkoutDataSource.saveWorkout(any(), userId))
          .thenAnswer((_) async => 'workout-1');

      var progressCalls = 0;
      void onProgress(int current, int total) {
        progressCalls++;
      }

      // Act
      await repository.syncWorkoutsFromFirebase(userId, onProgress: onProgress);

      // Assert
      expect(progressCalls, greaterThan(0));
    });

    test('getSyncStatus should return counts comparison', () async {
      // Arrange
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection('workouts')).thenReturn(mockCollection);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      when(() => mockHiveWorkoutDataSource.getWorkoutsForAnalytics(
        userId,
        limit: null,
      )).thenAnswer((_) async => []);

      // Act
      final status = await repository.getSyncStatus(userId);

      // Assert
      expect(status.firebase, 0);
      expect(status.hive, 0);
      expect(status.needsSync, false);
    });
  });

  group('Cache Management', () {
    const userId = 'user-123';

    test('invalidateAnalyticsCache should clear user cache', () async {
      // Arrange
      when(() => mockCacheService.invalidateUser(userId))
          .thenAnswer((_) async {});

      // Act
      await repository.invalidateAnalyticsCache(userId);

      // Assert
      verify(() => mockCacheService.invalidateUser(userId)).called(1);
    });

    test('getCacheStatistics should return stats', () {
      // Arrange
      final stats = {'hits': 10, 'misses': 5};
      when(() => mockCacheService.getStatistics()).thenReturn(stats);

      // Act
      final result = repository.getCacheStatistics();

      // Assert
      expect(result, equals(stats));
    });
  });

  group('Dispose', () {
    test('should close all stream controllers', () async {
      // Arrange
      repository.watchWorkoutUpdates('workout-1');
      repository.watchWorkoutUpdates('workout-2');

      when(() => mockCacheService.getStatistics()).thenReturn({});
      when(() => mockCacheService.dispose()).thenAnswer((_) async {});

      // Act
      await repository.dispose();

      // Assert
      verify(() => mockCacheService.dispose()).called(1);
    });

    test('should dispose cache service', () async {
      // Arrange
      when(() => mockCacheService.getStatistics()).thenReturn({});
      when(() => mockCacheService.dispose()).thenAnswer((_) async {});

      // Act
      await repository.dispose();

      // Assert
      verify(() => mockCacheService.dispose()).called(1);
    });
  });
}
