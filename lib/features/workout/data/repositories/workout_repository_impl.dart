/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Firebase Firestore
/// - Domain entities
/// - Repository interface
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';

/// Firebase implementation of WorkoutRepository
class WorkoutRepositoryImpl
    with FirebaseErrorMapperMixin
    implements WorkoutRepository {
  const WorkoutRepositoryImpl({
    required FirebaseWorkoutDataSource dataSource,
    required FirebaseAuth auth,
  }) : _dataSource = dataSource,
       _auth = auth;

  final FirebaseWorkoutDataSource _dataSource;
  final FirebaseAuth _auth;

  /// Helper to convert fpdart Either to project Either
  Either<Failure, T> _toProjectEither<T>(fpdart.Either<Failure, T> fpResult) {
    return fpResult.fold((failure) => left(failure), (value) => right(value));
  }

  /// Helper to check authentication and return user ID or failure
  Either<Failure, String> _requireAuth() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return left(const AuthenticationFailure('User not authenticated'));
    }
    return right(currentUser.uid);
  }

  @override
  Future<Either<Failure, String>> saveWorkout(Workout workout) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;
    final workoutModel = WorkoutModel.fromDomain(workout);

    final result = await handleFirebaseOperation(
      () => _dataSource.saveWorkout(workoutModel, userId),
      operationName: 'saveWorkout',
    );

    return _toProjectEither(result);
  }

  @override
  Future<Either<Failure, void>> updateWorkout(Workout workout) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;
    final workoutModel = WorkoutModel.fromDomain(workout);

    final result = await handleFirebaseVoidOperation(
      () => _dataSource.updateWorkout(workoutModel, userId),
      operationName: 'updateWorkout',
    );

    return result.fold((failure) => left(failure), (_) => right(null));
  }

  @override
  Future<Either<Failure, Workout>> getWorkout(String workoutId) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseOperation(() async {
      final workoutModel = await _dataSource.getWorkout(workoutId, userId);
      if (workoutModel == null) {
        throw const WorkoutNotFoundFailure('Workout not found');
      }
      return workoutModel.toDomain();
    }, operationName: 'getWorkout');

    // Handle WorkoutNotFoundFailure thrown inside
    return result.fold((failure) => left(failure), (workout) => right(workout));
  }

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseOperation(() async {
      final workoutModels = await _dataSource.getWorkouts(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return workoutModels.map((model) => model.toDomain()).toList();
    }, operationName: 'getWorkouts');

    return _toProjectEither(result);
  }

  @override
  Future<Either<Failure, void>> deleteWorkout(String workoutId) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseVoidOperation(
      () => _dataSource.deleteWorkout(workoutId, userId),
      operationName: 'deleteWorkout',
    );

    return result.fold((failure) => left(failure), (_) => right(null));
  }

  @override
  Future<Either<Failure, List<String>>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final workoutModel = WorkoutModel.fromDomain(workout);

    final result = await handleFirebaseOperation(
      () => _dataSource.saveCompletedWorkout(workoutModel, userEmail),
      operationName: 'saveCompletedWorkout',
    );

    return _toProjectEither(result);
  }

  @override
  Future<Either<Failure, void>> updateExerciseSet({
    required String workoutId,
    required String exerciseId,
    required ExerciseSet exerciseSet,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseVoidOperation(
      () => _dataSource.updateExerciseSet(
        workoutId,
        exerciseId,
        exerciseSet,
        userId,
      ),
      operationName: 'updateExerciseSet',
    );

    return result.fold((failure) => left(failure), (_) => right(null));
  }

  @override
  Future<Either<Failure, void>> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseVoidOperation(
      () => _dataSource.addExerciseToWorkout(workoutId, exercise, userId),
      operationName: 'addExerciseToWorkout',
    );

    return result.fold((failure) => left(failure), (_) => right(null));
  }

  @override
  Future<Either<Failure, void>> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseVoidOperation(
      () =>
          _dataSource.removeExerciseFromWorkout(workoutId, exerciseId, userId),
      operationName: 'removeExerciseFromWorkout',
    );

    return result.fold((failure) => left(failure), (_) => right(null));
  }

  @override
  Future<Either<Failure, WorkoutStats>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseOperation(
      () => _dataSource.getWorkoutStats(
        userId,
        startDate: startDate,
        endDate: endDate,
      ),
      operationName: 'getWorkoutStats',
    );

    return _toProjectEither(result);
  }

  @override
  Stream<Either<Failure, Workout?>> watchActiveWorkout() {
    final authResult = _requireAuth();
    if (authResult.isLeft) {
      return Stream.value(left(authResult.leftOrNull!));
    }

    final userId = authResult.rightOrNull!;

    return _dataSource
        .watchActiveWorkout(userId)
        .map((workoutModel) {
          if (workoutModel == null) {
            return right<Failure, Workout?>(null);
          }
          return right<Failure, Workout?>(workoutModel.toDomain());
        })
        .handleError((Object error) {
          if (error is FirebaseException) {
            return left<Failure, Workout?>(
              mapFirebaseException(error, operationName: 'watchActiveWorkout'),
            );
          }
          return left<Failure, Workout?>(
            UnexpectedFailure('Failed to watch active workout: $error'),
          );
        });
  }

  @override
  Future<Either<Failure, WorkoutHistory>> getWorkoutHistory({
    int page = 1,
    int limit = 10,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseOperation(
      () => _dataSource.getWorkoutHistory(userId, page: page, limit: limit),
      operationName: 'getWorkoutHistory',
    );

    return _toProjectEither(result);
  }

  @override
  Future<Workout?> getLastCompletedWorkout(String userId) async {
    // Firebase-only implementation - not commonly used
    // The app uses HybridWorkoutRepositoryImpl in production
    throw UnimplementedError(
      'getLastCompletedWorkout not implemented for Firebase-only repository. '
      'Use HybridWorkoutRepositoryImpl instead.',
    );
  }

  @override
  Future<Either<Failure, PaginatedResult<Workout>>> getWorkoutsPaginated({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) async {
    final authResult = _requireAuth();
    if (authResult.isLeft) return left(authResult.leftOrNull!);

    final userId = authResult.rightOrNull!;

    final result = await handleFirebaseOperation(() async {
      final modelResult = await _dataSource.getWorkoutsPaginated(
        userId,
        pageSize: pageSize,
        startAfter: startAfter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );

      final workouts = modelResult.items
          .map((model) => model.toDomain())
          .toList();

      return PaginatedResult<Workout>(
        items: workouts,
        hasMore: modelResult.hasMore,
        lastDocument: modelResult.lastDocument,
      );
    }, operationName: 'getWorkoutsPaginated');

    return _toProjectEither(result);
  }
}
