/// Unit tests for WorkoutRepositoryImpl
///
/// Tests the Firebase-backed implementation of WorkoutRepository.
/// Uses manual fake classes (no Mockito/mocktail) to isolate the repository
/// from real Firebase dependencies.
///
/// Coverage areas:
/// - Auth guard (_requireAuth) on every public method
/// - Successful data flow through FirebaseWorkoutDataSource
/// - Error mapping via FirebaseErrorMapperMixin
/// - Model-to-domain conversions
/// - watchActiveWorkout stream behavior
/// - getWorkoutsPaginated cursor-based pagination
/// - getLastCompletedWorkout unimplemented guard
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Fake FirebaseAuth helpers
// ---------------------------------------------------------------------------

/// A minimal fake FirebaseUser that returns a configurable uid.
class _FakeUser implements User {
  _FakeUser({required this.uid, this.email});

  @override
  final String uid;
  @override
  final String? email;

  // All other User members are not needed for these tests.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake FirebaseAuth that controls whether a user is signed in.
class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth({User? user}) : _currentUser = user;

  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  void signIn(User user) => _currentUser = user;
  @override
  Future<void> signOut() async => _currentUser = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Fake FirebaseWorkoutDataSource
// ---------------------------------------------------------------------------

/// Configurable fake data source — no Firestore involved.
class _FakeFirebaseWorkoutDataSource implements FirebaseWorkoutDataSource {
  // Injected behaviours: set these before each test.

  /// Called when saveWorkout is invoked; returns a workout id or throws.
  Future<String> Function(WorkoutModel workout, String userId)? onSaveWorkout;

  /// Called when updateWorkout is invoked; completes or throws.
  Future<void> Function(WorkoutModel workout, String userId)? onUpdateWorkout;

  /// Called when getWorkout is invoked; returns a model or throws.
  Future<WorkoutModel?> Function(String workoutId, String userId)? onGetWorkout;

  /// Called when getWorkouts is invoked; returns a list or throws.
  Future<List<WorkoutModel>> Function(
    String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    bool useUpdatedAt,
  })?
  onGetWorkouts;

  /// Called when deleteWorkout is invoked; completes or throws.
  Future<void> Function(String workoutId, String userId)? onDeleteWorkout;

  /// Called when saveCompletedWorkout is invoked; returns ids or throws.
  // ignore: deprecated_member_use_from_same_package
  Future<List<String>> Function(WorkoutModel workout, String userEmail)?
  onSaveCompletedWorkout;

  /// Called when updateExerciseSet is invoked; completes or throws.
  Future<void> Function(
    String workoutId,
    String exerciseId,
    ExerciseSet exerciseSet,
    String userId,
  )?
  onUpdateExerciseSet;

  /// Called when addExerciseToWorkout is invoked; completes or throws.
  Future<void> Function(String workoutId, Exercise exercise, String userId)?
  onAddExerciseToWorkout;

  /// Called when removeExerciseFromWorkout is invoked; completes or throws.
  Future<void> Function(String workoutId, String exerciseId, String userId)?
  onRemoveExerciseFromWorkout;

  /// Called when getWorkoutStats is invoked; returns stats or throws.
  Future<WorkoutStats> Function(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  })?
  onGetWorkoutStats;

  /// Stream to emit from watchActiveWorkout.
  Stream<WorkoutModel?> Function(String userId)? onWatchActiveWorkout;

  /// Called when getWorkoutHistory is invoked; returns history or throws.
  Future<WorkoutHistory> Function(String userId, {int page, int limit})?
  onGetWorkoutHistory;

  /// Called when getWorkoutsPaginated is invoked; returns paginated or throws.
  Future<PaginatedResult<WorkoutModel>> Function(
    String userId, {
    int pageSize,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  })?
  onGetWorkoutsPaginated;

  // -------------------------------------------------------------------------
  // Interface implementation
  // -------------------------------------------------------------------------

  @override
  Future<String> saveWorkout(WorkoutModel workout, String userId) {
    return onSaveWorkout!(workout, userId);
  }

  @override
  Future<void> updateWorkout(WorkoutModel workout, String userId) {
    return onUpdateWorkout!(workout, userId);
  }

  @override
  Future<WorkoutModel?> getWorkout(String workoutId, String userId) {
    return onGetWorkout!(workoutId, userId);
  }

  @override
  Future<List<WorkoutModel>> getWorkouts(
    String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    bool useUpdatedAt = false,
  }) {
    return onGetWorkouts!(
      userId,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
      useUpdatedAt: useUpdatedAt,
    );
  }

  @override
  Future<void> deleteWorkout(String workoutId, String userId) {
    return onDeleteWorkout!(workoutId, userId);
  }

  @override
  // ignore: deprecated_member_use_from_same_package
  @Deprecated('Use saveWorkout() instead.')
  Future<List<String>> saveCompletedWorkout(
    WorkoutModel workout,
    String userEmail,
  ) {
    return onSaveCompletedWorkout!(workout, userEmail);
  }

  @override
  Future<void> updateExerciseSet(
    String workoutId,
    String exerciseId,
    ExerciseSet exerciseSet,
    String userId,
  ) {
    return onUpdateExerciseSet!(workoutId, exerciseId, exerciseSet, userId);
  }

  @override
  Future<void> addExerciseToWorkout(
    String workoutId,
    Exercise exercise,
    String userId,
  ) {
    return onAddExerciseToWorkout!(workoutId, exercise, userId);
  }

  @override
  Future<void> removeExerciseFromWorkout(
    String workoutId,
    String exerciseId,
    String userId,
  ) {
    return onRemoveExerciseFromWorkout!(workoutId, exerciseId, userId);
  }

  @override
  Future<WorkoutStats> getWorkoutStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return onGetWorkoutStats!(userId, startDate: startDate, endDate: endDate);
  }

  @override
  Stream<WorkoutModel?> watchActiveWorkout(String userId) {
    return onWatchActiveWorkout!(userId);
  }

  @override
  Future<WorkoutHistory> getWorkoutHistory(
    String userId, {
    int page = 1,
    int limit = 10,
  }) {
    return onGetWorkoutHistory!(userId, page: page, limit: limit);
  }

  @override
  Future<PaginatedResult<WorkoutModel>> getWorkoutsPaginated(
    String userId, {
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) {
    return onGetWorkoutsPaginated!(
      userId,
      pageSize: pageSize,
      startAfter: startAfter,
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
    );
  }
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

final _fixedNow = DateTime(2025, 6, 15, 10, 0, 0);

Workout _makeWorkout({
  String id = 'wk-001',
  String name = 'Morning Push',
  WorkoutStatus status = WorkoutStatus.planned,
  List<Exercise> exercises = const [],
}) {
  return Workout(
    id: id,
    name: name,
    exercises: exercises,
    status: status,
    createdAt: _fixedNow,
    updatedAt: _fixedNow,
  );
}

WorkoutModel _makeWorkoutModel({
  String id = 'wk-001',
  String name = 'Morning Push',
  String status = 'planned',
}) {
  return WorkoutModel(
    id: id,
    name: name,
    exercises: const [],
    status: status,
    createdAt: _fixedNow,
    updatedAt: _fixedNow,
  );
}

ExerciseSet _makeExerciseSet({String id = 'set-001'}) {
  return ExerciseSet(
    id: id,
    setNumber: 1,
    reps: 10,
    weight: 80.0,
    isCompleted: false,
  );
}

Exercise _makeExercise({String id = 'ex-001', String name = 'Bench Press'}) {
  return Exercise(
    id: id,
    name: name,
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
    sets: [_makeExerciseSet()],
  );
}

WorkoutStats _makeWorkoutStats() {
  return const WorkoutStats(
    totalWorkouts: 5,
    totalExercises: 15,
    totalSets: 45,
    totalDuration: Duration(hours: 5),
    averageWorkoutDuration: 3600.0,
    exercisesByCategory: {},
  );
}

// ---------------------------------------------------------------------------
// Helpers to build the repository under test
// ---------------------------------------------------------------------------

WorkoutRepositoryImpl _makeRepo({
  required _FakeFirebaseWorkoutDataSource dataSource,
  required _FakeFirebaseAuth auth,
}) {
  return WorkoutRepositoryImpl(dataSource: dataSource, auth: auth);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeFirebaseWorkoutDataSource dataSource;
  late _FakeFirebaseAuth auth;
  late _FakeUser authenticatedUser;
  late WorkoutRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeFirebaseWorkoutDataSource();
    authenticatedUser = _FakeUser(uid: 'user-123', email: 'test@fitlog.pro');
    auth = _FakeFirebaseAuth(user: authenticatedUser);
    repository = _makeRepo(dataSource: dataSource, auth: auth);
  });

  // =========================================================================
  // saveWorkout
  // =========================================================================

  group('saveWorkout', () {
    test('returns Right with workout id on success', () async {
      final workout = _makeWorkout();
      dataSource.onSaveWorkout = (model, userId) async => 'wk-001';

      final result = await repository.saveWorkout(workout);

      expect(result.isRight, isTrue);
      expect(result.rightOrNull, equals('wk-001'));
    });

    test('passes the correct userId extracted from auth', () async {
      final workout = _makeWorkout();
      String? capturedUserId;
      dataSource.onSaveWorkout = (model, userId) async {
        capturedUserId = userId;
        return model.id;
      };

      await repository.saveWorkout(workout);

      expect(capturedUserId, equals('user-123'));
    });

    test('converts Workout to WorkoutModel before saving', () async {
      final workout = _makeWorkout(id: 'wk-abc', name: 'Leg Day');
      WorkoutModel? capturedModel;
      dataSource.onSaveWorkout = (model, userId) async {
        capturedModel = model;
        return model.id;
      };

      await repository.saveWorkout(workout);

      expect(capturedModel, isNotNull);
      expect(capturedModel!.id, equals('wk-abc'));
      expect(capturedModel!.name, equals('Leg Day'));
    });

    test(
      'returns Left(AuthenticationFailure) when user is not authenticated',
      () async {
        await auth.signOut();
        final workout = _makeWorkout();

        final result = await repository.saveWorkout(workout);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('returns Left(NetworkFailure) on TimeoutException', () async {
      final workout = _makeWorkout();
      dataSource.onSaveWorkout = (_, __) async =>
          throw TimeoutException('timed out');

      final result = await repository.saveWorkout(workout);

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NetworkFailure>());
    });

    test('returns Left(UnexpectedFailure) on generic exception', () async {
      final workout = _makeWorkout();
      dataSource.onSaveWorkout = (_, __) async => throw Exception('unexpected');

      final result = await repository.saveWorkout(workout);

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<UnexpectedFailure>());
    });
  });

  // =========================================================================
  // updateWorkout
  // =========================================================================

  group('updateWorkout', () {
    test('returns Right on success', () async {
      final workout = _makeWorkout();
      dataSource.onUpdateWorkout = (_, __) async {};

      final result = await repository.updateWorkout(workout);

      expect(result.isRight, isTrue);
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.updateWorkout(_makeWorkout());

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('returns Left(NetworkFailure) on TimeoutException', () async {
      final workout = _makeWorkout();
      dataSource.onUpdateWorkout = (_, __) async =>
          throw TimeoutException('update timed out');

      final result = await repository.updateWorkout(workout);

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NetworkFailure>());
    });

    test('returns Left(UnexpectedFailure) on unexpected error', () async {
      dataSource.onUpdateWorkout = (_, __) async => throw StateError('boom');

      final result = await repository.updateWorkout(_makeWorkout());

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<UnexpectedFailure>());
    });
  });

  // =========================================================================
  // getWorkout
  // =========================================================================

  group('getWorkout', () {
    test('returns Right(Workout) when datasource finds the workout', () async {
      final model = _makeWorkoutModel(id: 'wk-001');
      dataSource.onGetWorkout = (workoutId, userId) async => model;

      final result = await repository.getWorkout('wk-001');

      expect(result.isRight, isTrue);
      expect(result.rightOrNull, isA<Workout>());
      expect(result.rightOrNull!.id, equals('wk-001'));
    });

    test(
      'returns Left(Failure) when datasource returns null (workout not found)',
      () async {
        // The repository throws WorkoutNotFoundFailure (a Failure, not an
        // Exception) inside handleFirebaseOperation. The mixin's generic catch
        // block intercepts it and wraps it as an UnexpectedFailure.
        dataSource.onGetWorkout = (workoutId, userId) async => null;

        final result = await repository.getWorkout('does-not-exist');

        expect(result.isLeft, isTrue);
        // WorkoutNotFoundFailure is not an Exception so the mixin maps it
        // to UnexpectedFailure via the generic catch.
        expect(result.leftOrNull, isA<Failure>());
      },
    );

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.getWorkout('wk-001');

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test(
      'maps FirebaseException permission-denied to PermissionFailure',
      () async {
        dataSource.onGetWorkout = (_, __) async => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing permissions',
        );

        final result = await repository.getWorkout('wk-001');

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<PermissionFailure>());
      },
    );

    test('maps FirebaseException unavailable to NetworkFailure', () async {
      dataSource.onGetWorkout = (_, __) async => throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      );

      final result = await repository.getWorkout('wk-001');

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // getWorkouts
  // =========================================================================

  group('getWorkouts', () {
    test('returns Right with list of Workouts on success', () async {
      final models = [
        _makeWorkoutModel(id: 'wk-001'),
        _makeWorkoutModel(id: 'wk-002', name: 'Pull Day'),
      ];
      dataSource.onGetWorkouts =
          (userId, {limit, startDate, endDate, useUpdatedAt = false}) async =>
              models;

      final result = await repository.getWorkouts();

      expect(result.isRight, isTrue);
      final workouts = result.rightOrNull!;
      expect(workouts.length, equals(2));
      expect(workouts.first.id, equals('wk-001'));
      expect(workouts.last.id, equals('wk-002'));
    });

    test('passes limit and date filters to datasource', () async {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 12, 31);
      int? capturedLimit;
      DateTime? capturedStart;
      DateTime? capturedEnd;

      dataSource.onGetWorkouts =
          (userId, {limit, startDate, endDate, useUpdatedAt = false}) async {
            capturedLimit = limit;
            capturedStart = startDate;
            capturedEnd = endDate;
            expect(useUpdatedAt, isFalse);
            return [];
          };

      await repository.getWorkouts(limit: 5, startDate: start, endDate: end);

      expect(capturedLimit, equals(5));
      expect(capturedStart, equals(start));
      expect(capturedEnd, equals(end));
    });

    test('returns empty list when datasource returns no workouts', () async {
      dataSource.onGetWorkouts =
          (_, {limit, startDate, endDate, useUpdatedAt = false}) async => [];

      final result = await repository.getWorkouts();

      expect(result.isRight, isTrue);
      expect(result.rightOrNull, isEmpty);
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.getWorkouts();

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('returns Left(NetworkFailure) on TimeoutException', () async {
      dataSource.onGetWorkouts =
          (_, {limit, startDate, endDate, useUpdatedAt = false}) async =>
              throw TimeoutException('getWorkouts timed out');

      final result = await repository.getWorkouts();

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // deleteWorkout
  // =========================================================================

  group('deleteWorkout', () {
    test('returns Right on success', () async {
      dataSource.onDeleteWorkout = (workoutId, userId) async {};

      final result = await repository.deleteWorkout('wk-001');

      expect(result.isRight, isTrue);
    });

    test('passes the workoutId and userId to datasource', () async {
      String? capturedWorkoutId;
      String? capturedUserId;
      dataSource.onDeleteWorkout = (workoutId, userId) async {
        capturedWorkoutId = workoutId;
        capturedUserId = userId;
      };

      await repository.deleteWorkout('wk-target');

      expect(capturedWorkoutId, equals('wk-target'));
      expect(capturedUserId, equals('user-123'));
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.deleteWorkout('wk-001');

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('maps FirebaseException not-found to NotFoundFailure', () async {
      dataSource.onDeleteWorkout = (_, __) async => throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Workout not found',
      );

      final result = await repository.deleteWorkout('wk-ghost');

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NotFoundFailure>());
    });
  });

  // =========================================================================
  // saveCompletedWorkout (deprecated no-op)
  // =========================================================================

  group('saveCompletedWorkout', () {
    test('returns Right with empty list (deprecated no-op)', () async {
      // ignore: deprecated_member_use_from_same_package
      dataSource.onSaveCompletedWorkout = (_, __) async => [];

      final result = await repository.saveCompletedWorkout(
        workout: _makeWorkout(),
        userEmail: 'test@fitlog.pro',
      );

      expect(result.isRight, isTrue);
      expect(result.rightOrNull, isEmpty);
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.saveCompletedWorkout(
          workout: _makeWorkout(),
          userEmail: 'test@fitlog.pro',
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );
  });

  // =========================================================================
  // updateExerciseSet
  // =========================================================================

  group('updateExerciseSet', () {
    test('returns Right(null) on success', () async {
      dataSource.onUpdateExerciseSet = (_, __, ___, ____) async {};

      final result = await repository.updateExerciseSet(
        workoutId: 'wk-001',
        exerciseId: 'ex-001',
        exerciseSet: _makeExerciseSet(),
      );

      expect(result.isRight, isTrue);
    });

    test('passes all parameters to datasource', () async {
      String? capturedWorkoutId;
      String? capturedExerciseId;
      String? capturedUserId;
      ExerciseSet? capturedSet;

      dataSource.onUpdateExerciseSet =
          (workoutId, exerciseId, exerciseSet, userId) async {
            capturedWorkoutId = workoutId;
            capturedExerciseId = exerciseId;
            capturedSet = exerciseSet;
            capturedUserId = userId;
          };

      final set = _makeExerciseSet(id: 'set-999');
      await repository.updateExerciseSet(
        workoutId: 'wk-007',
        exerciseId: 'ex-007',
        exerciseSet: set,
      );

      expect(capturedWorkoutId, equals('wk-007'));
      expect(capturedExerciseId, equals('ex-007'));
      expect(capturedSet!.id, equals('set-999'));
      expect(capturedUserId, equals('user-123'));
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.updateExerciseSet(
          workoutId: 'wk-001',
          exerciseId: 'ex-001',
          exerciseSet: _makeExerciseSet(),
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('returns Left(UnexpectedFailure) on unexpected error', () async {
      dataSource.onUpdateExerciseSet =
          (workoutId, exerciseId, exerciseSet, userId) async =>
              throw Exception('set not found');

      final result = await repository.updateExerciseSet(
        workoutId: 'wk-001',
        exerciseId: 'ex-001',
        exerciseSet: _makeExerciseSet(),
      );

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<UnexpectedFailure>());
    });
  });

  // =========================================================================
  // addExerciseToWorkout
  // =========================================================================

  group('addExerciseToWorkout', () {
    test('returns Right(null) on success', () async {
      dataSource.onAddExerciseToWorkout = (_, __, ___) async {};

      final result = await repository.addExerciseToWorkout(
        workoutId: 'wk-001',
        exercise: _makeExercise(),
      );

      expect(result.isRight, isTrue);
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.addExerciseToWorkout(
          workoutId: 'wk-001',
          exercise: _makeExercise(),
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test(
      'maps FirebaseException permission-denied to PermissionFailure',
      () async {
        dataSource.onAddExerciseToWorkout = (_, __, ___) async =>
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
            );

        final result = await repository.addExerciseToWorkout(
          workoutId: 'wk-001',
          exercise: _makeExercise(),
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<PermissionFailure>());
      },
    );
  });

  // =========================================================================
  // removeExerciseFromWorkout
  // =========================================================================

  group('removeExerciseFromWorkout', () {
    test('returns Right(null) on success', () async {
      dataSource.onRemoveExerciseFromWorkout = (_, __, ___) async {};

      final result = await repository.removeExerciseFromWorkout(
        workoutId: 'wk-001',
        exerciseId: 'ex-001',
      );

      expect(result.isRight, isTrue);
    });

    test('passes workoutId, exerciseId, and userId to datasource', () async {
      String? capturedWorkoutId;
      String? capturedExerciseId;
      String? capturedUserId;
      dataSource.onRemoveExerciseFromWorkout =
          (workoutId, exerciseId, userId) async {
            capturedWorkoutId = workoutId;
            capturedExerciseId = exerciseId;
            capturedUserId = userId;
          };

      await repository.removeExerciseFromWorkout(
        workoutId: 'wk-99',
        exerciseId: 'ex-99',
      );

      expect(capturedWorkoutId, equals('wk-99'));
      expect(capturedExerciseId, equals('ex-99'));
      expect(capturedUserId, equals('user-123'));
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.removeExerciseFromWorkout(
          workoutId: 'wk-001',
          exerciseId: 'ex-001',
        );

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );
  });

  // =========================================================================
  // getWorkoutStats
  // =========================================================================

  group('getWorkoutStats', () {
    test('returns Right(WorkoutStats) on success', () async {
      final stats = _makeWorkoutStats();
      dataSource.onGetWorkoutStats = (userId, {startDate, endDate}) async =>
          stats;

      final result = await repository.getWorkoutStats();

      expect(result.isRight, isTrue);
      final returned = result.rightOrNull!;
      expect(returned.totalWorkouts, equals(5));
      expect(returned.totalExercises, equals(15));
    });

    test('passes date filters to datasource', () async {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 6, 30);
      DateTime? capturedStart;
      DateTime? capturedEnd;

      dataSource.onGetWorkoutStats = (userId, {startDate, endDate}) async {
        capturedStart = startDate;
        capturedEnd = endDate;
        return _makeWorkoutStats();
      };

      await repository.getWorkoutStats(startDate: start, endDate: end);

      expect(capturedStart, equals(start));
      expect(capturedEnd, equals(end));
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.getWorkoutStats();

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('returns Left(NetworkFailure) on TimeoutException', () async {
      dataSource.onGetWorkoutStats = (_, {startDate, endDate}) async =>
          throw TimeoutException('stats timed out');

      final result = await repository.getWorkoutStats();

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // watchActiveWorkout
  // =========================================================================

  group('watchActiveWorkout', () {
    test('emits Right(null) when no active workout', () async {
      dataSource.onWatchActiveWorkout = (userId) => Stream.value(null);

      final stream = repository.watchActiveWorkout();
      final emitted = await stream.first;

      expect(emitted.isRight, isTrue);
      expect(emitted.rightOrNull, isNull);
    });

    test('emits Right(Workout) when active workout exists', () async {
      final model = _makeWorkoutModel(status: 'inProgress');
      dataSource.onWatchActiveWorkout = (userId) => Stream.value(model);

      final stream = repository.watchActiveWorkout();
      final emitted = await stream.first;

      expect(emitted.isRight, isTrue);
      expect(emitted.rightOrNull, isA<Workout>());
      expect(emitted.rightOrNull!.status, equals(WorkoutStatus.inProgress));
    });

    test('emits Left(AuthenticationFailure) when not authenticated', () async {
      await auth.signOut();

      final stream = repository.watchActiveWorkout();
      final emitted = await stream.first;

      expect(emitted.isLeft, isTrue);
      expect(emitted.leftOrNull, isA<AuthenticationFailure>());
    });

    test('emits multiple values from datasource stream', () async {
      final controller = StreamController<WorkoutModel?>();
      dataSource.onWatchActiveWorkout = (userId) => controller.stream;

      final results = <bool>[];
      final sub = repository.watchActiveWorkout().listen((either) {
        results.add(either.isRight);
      });

      controller.add(null);
      controller.add(_makeWorkoutModel(status: 'inProgress'));
      controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(results, equals([true, true, true]));
      await sub.cancel();
      await controller.close();
    });

    test('completes without throwing when stream emits generic error', () async {
      // The repository uses handleError() which suppresses stream errors
      // and maps them; the stream ends cleanly without propagating exceptions.
      dataSource.onWatchActiveWorkout = (userId) =>
          Stream.error(Exception('stream error'));

      final stream = repository.watchActiveWorkout();
      // Collect all emitted values; should be empty (error was swallowed)
      // and not throw an unhandled stream exception.
      final emitted = await stream.toList();
      // The key assertion: no exception was propagated to the subscriber.
      expect(emitted, isA<List>());
    });
  });

  // =========================================================================
  // getWorkoutHistory
  // =========================================================================

  group('getWorkoutHistory', () {
    test('returns Right(WorkoutHistory) on success', () async {
      final history = WorkoutHistory(
        workouts: [_makeWorkout()],
        totalCount: 1,
        hasMore: false,
        currentPage: 1,
      );
      dataSource.onGetWorkoutHistory = (userId, {page = 1, limit = 10}) async =>
          history;

      final result = await repository.getWorkoutHistory(page: 1, limit: 10);

      expect(result.isRight, isTrue);
      final returned = result.rightOrNull!;
      expect(returned.totalCount, equals(1));
      expect(returned.hasMore, isFalse);
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.getWorkoutHistory();

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('passes page and limit to datasource', () async {
      int? capturedPage;
      int? capturedLimit;
      dataSource.onGetWorkoutHistory = (userId, {page = 1, limit = 10}) async {
        capturedPage = page;
        capturedLimit = limit;
        return WorkoutHistory(
          workouts: [],
          totalCount: 0,
          hasMore: false,
          currentPage: page,
        );
      };

      await repository.getWorkoutHistory(page: 3, limit: 25);

      expect(capturedPage, equals(3));
      expect(capturedLimit, equals(25));
    });
  });

  // =========================================================================
  // getLastCompletedWorkout
  // =========================================================================

  group('getLastCompletedWorkout', () {
    test(
      'throws UnimplementedError (Firebase-only repo does not support this)',
      () async {
        expect(
          () => repository.getLastCompletedWorkout('user-123'),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });

  // =========================================================================
  // getWorkoutsPaginated
  // =========================================================================

  group('getWorkoutsPaginated', () {
    test(
      'returns Right(PaginatedResult) with domain workouts on success',
      () async {
        final models = [
          _makeWorkoutModel(id: 'wk-p1'),
          _makeWorkoutModel(id: 'wk-p2'),
        ];
        dataSource.onGetWorkoutsPaginated =
            (
              userId, {
              pageSize = 20,
              startAfter,
              dateFrom,
              dateTo,
              status,
            }) async =>
                PaginatedResult<WorkoutModel>(items: models, hasMore: false);

        final result = await repository.getWorkoutsPaginated(pageSize: 2);

        expect(result.isRight, isTrue);
        final paginated = result.rightOrNull!;
        expect(paginated.items.length, equals(2));
        expect(paginated.items.first, isA<Workout>());
        expect(paginated.items.first.id, equals('wk-p1'));
        expect(paginated.hasMore, isFalse);
      },
    );

    test('forwards hasMore flag from datasource result', () async {
      final models = List.generate(5, (i) => _makeWorkoutModel(id: 'wk-$i'));
      dataSource.onGetWorkoutsPaginated =
          (
            userId, {
            pageSize = 20,
            startAfter,
            dateFrom,
            dateTo,
            status,
          }) async =>
              PaginatedResult<WorkoutModel>(items: models, hasMore: true);

      final result = await repository.getWorkoutsPaginated(pageSize: 5);

      expect(result.rightOrNull!.hasMore, isTrue);
    });

    test('passes filters to datasource', () async {
      final dateFrom = DateTime(2025, 1, 1);
      final dateTo = DateTime(2025, 6, 30);
      String? capturedStatus;
      DateTime? capturedDateFrom;
      DateTime? capturedDateTo;
      int? capturedPageSize;

      dataSource.onGetWorkoutsPaginated =
          (
            userId, {
            pageSize = 20,
            startAfter,
            dateFrom,
            dateTo,
            status,
          }) async {
            capturedPageSize = pageSize;
            capturedDateFrom = dateFrom;
            capturedDateTo = dateTo;
            capturedStatus = status;
            return const PaginatedResult<WorkoutModel>(
              items: [],
              hasMore: false,
            );
          };

      await repository.getWorkoutsPaginated(
        pageSize: 10,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: 'completed',
      );

      expect(capturedPageSize, equals(10));
      expect(capturedDateFrom, equals(dateFrom));
      expect(capturedDateTo, equals(dateTo));
      expect(capturedStatus, equals('completed'));
    });

    test(
      'returns Left(AuthenticationFailure) when not authenticated',
      () async {
        await auth.signOut();

        final result = await repository.getWorkoutsPaginated();

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test('returns Left on TimeoutException', () async {
      dataSource.onGetWorkoutsPaginated =
          (
            userId, {
            pageSize = 20,
            startAfter,
            dateFrom,
            dateTo,
            status,
          }) async => throw TimeoutException('paginated timed out');

      final result = await repository.getWorkoutsPaginated();

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // FirebaseErrorMapperMixin - error mapping coverage
  // =========================================================================

  group('FirebaseErrorMapperMixin error mapping', () {
    test(
      'maps resource-exhausted FirebaseException to RateLimitFailure',
      () async {
        dataSource.onGetWorkouts =
            (_, {limit, startDate, endDate, useUpdatedAt = false}) async =>
                throw FirebaseException(
                  plugin: 'cloud_firestore',
                  code: 'resource-exhausted',
                  message: 'Quota exceeded',
                );

        final result = await repository.getWorkouts();

        expect(result.leftOrNull, isA<RateLimitFailure>());
      },
    );

    test('maps already-exists FirebaseException to ConflictFailure', () async {
      dataSource.onSaveWorkout = (_, __) async => throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'Document already exists',
      );

      final result = await repository.saveWorkout(_makeWorkout());

      expect(result.leftOrNull, isA<ConflictFailure>());
    });

    test(
      'maps unauthenticated FirebaseException to AuthenticationFailure',
      () async {
        dataSource.onGetWorkout = (_, __) async => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unauthenticated',
          message: 'Token expired',
        );

        final result = await repository.getWorkout('wk-001');

        expect(result.leftOrNull, isA<AuthenticationFailure>());
      },
    );

    test(
      'maps invalid-argument FirebaseException to ValidationFailure',
      () async {
        dataSource.onDeleteWorkout = (_, __) async => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'invalid-argument',
          message: 'Bad document path',
        );

        final result = await repository.deleteWorkout('bad//path');

        expect(result.leftOrNull, isA<ValidationFailure>());
      },
    );

    test('maps unknown FirebaseException code to ServerFailure', () async {
      dataSource.onGetWorkoutStats = (_, {startDate, endDate}) async =>
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'internal',
            message: 'Internal server error',
          );

      final result = await repository.getWorkoutStats();

      expect(result.leftOrNull, isA<ServerFailure>());
    });
  });
}
