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
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';

/// Firebase implementation of WorkoutRepository
class WorkoutRepositoryImpl implements WorkoutRepository {
  
  const WorkoutRepositoryImpl({
    required FirebaseWorkoutDataSource dataSource,
    required FirebaseAuth auth,
  }) : _dataSource = dataSource, _auth = auth;
  final FirebaseWorkoutDataSource _dataSource;
  final FirebaseAuth _auth;

  @override
  Future<Either<Failure, String>> saveWorkout(Workout workout) async {
    try {
      // Check authentication
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      // Convert domain entity to data model
      final workoutModel = WorkoutModel.fromDomain(workout);
      
      // Save via data source
      final result = await _dataSource.saveWorkout(
        workoutModel,
        currentUser.uid,
      );
      
      return right(result);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to save workout: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateWorkout(Workout workout) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      final workoutModel = WorkoutModel.fromDomain(workout);
      
      await _dataSource.updateWorkout(
        workoutModel,
        currentUser.uid,
      );
      
      return right(null);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to update workout: $e'));
    }
  }

  @override
  Future<Either<Failure, Workout>> getWorkout(String workoutId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      final workoutModel = await _dataSource.getWorkout(
        workoutId,
        currentUser.uid,
      );
      
      if (workoutModel == null) {
        return left(const WorkoutNotFoundFailure('Workout not found'));
      }
      
      return right(workoutModel.toDomain());
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workout: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      final workoutModels = await _dataSource.getWorkouts(
        currentUser.uid,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      
      final workouts = workoutModels
          .map((model) => model.toDomain())
          .toList();
      
      return right(workouts);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workouts: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkout(String workoutId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      await _dataSource.deleteWorkout(workoutId, currentUser.uid);
      
      return right(null);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to delete workout: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      final workoutModel = WorkoutModel.fromDomain(workout);
      
      final activityIds = await _dataSource.saveCompletedWorkout(
        workoutModel,
        userEmail,
      );
      
      return right(activityIds);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to save completed workout: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExerciseSet({
    required String workoutId,
    required String exerciseId,
    required ExerciseSet exerciseSet,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      await _dataSource.updateExerciseSet(
        workoutId,
        exerciseId,
        exerciseSet,
        currentUser.uid,
      );
      
      return right(null);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to update exercise set: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      await _dataSource.addExerciseToWorkout(
        workoutId,
        exercise,
        currentUser.uid,
      );
      
      return right(null);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to add exercise to workout: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      await _dataSource.removeExerciseFromWorkout(
        workoutId,
        exerciseId,
        currentUser.uid,
      );
      
      return right(null);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to remove exercise from workout: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkoutStats>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }
      
      final stats = await _dataSource.getWorkoutStats(
        currentUser.uid,
        startDate: startDate,
        endDate: endDate,
      );
      
      return right(stats);
      
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workout stats: $e'));
    }
  }

  @override
  Stream<Either<Failure, Workout?>> watchActiveWorkout() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Stream.value(left(const AuthenticationFailure('User not authenticated')));
      }
      
      return _dataSource.watchActiveWorkout(currentUser.uid).map((workoutModel) {
        if (workoutModel == null) {
          return right<Failure, Workout?>(null);
        }
        return right<Failure, Workout?>(workoutModel.toDomain());
      }).handleError((error) {
        if (error is FirebaseException) {
          return left(_mapFirebaseException(error));
        }
        return left(UnexpectedFailure('Failed to watch active workout: $error'));
      });
      
    } catch (e) {
      return Stream.value(left(UnexpectedFailure('Failed to watch active workout: $e')));
    }
  }

  @override
  Future<Either<Failure, WorkoutHistory>> getWorkoutHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      final history = await _dataSource.getWorkoutHistory(
        currentUser.uid,
        page: page,
        limit: limit,
      );

      return right(history);

    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to get workout history: $e'));
    }
  }

  @override
  Future<Workout?> getLastCompletedWorkout(String userId) async {
    // Firebase-only implementation - not commonly used
    // The app uses HybridWorkoutRepositoryImpl in production
    throw UnimplementedError(
      'getLastCompletedWorkout not implemented for Firebase-only repository. '
      'Use HybridWorkoutRepositoryImpl instead.'
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
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return left(const AuthenticationFailure('User not authenticated'));
      }

      // Delegate to datasource for cursor-based pagination
      final modelResult = await _dataSource.getWorkoutsPaginated(
        currentUser.uid,
        pageSize: pageSize,
        startAfter: startAfter,
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );

      // Convert WorkoutModel list to Workout domain entities
      final workouts = modelResult.items
          .map((model) => model.toDomain())
          .toList();

      // Return domain result with converted items
      return right(PaginatedResult<Workout>(
        items: workouts,
        hasMore: modelResult.hasMore,
        lastDocument: modelResult.lastDocument,
      ));

    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e) {
      return left(UnexpectedFailure('Failed to get paginated workouts: $e'));
    }
  }

  /// Map Firebase exceptions to domain failures
  Failure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return PermissionDeniedFailure(
          'Permission denied: ${e.message}',
          code: e.code,
        );
      case 'not-found':
        return WorkoutNotFoundFailure(
          'Workout not found: ${e.message}',
          code: e.code,
        );
      case 'quota-exceeded':
        return QuotaExceededFailure(
          'Storage quota exceeded: ${e.message}',
          code: e.code,
        );
      case 'unauthenticated':
        return AuthenticationFailure(
          'Authentication required: ${e.message}',
          code: e.code,
        );
      case 'unavailable':
        return NetworkFailure(
          'Service unavailable: ${e.message}',
          code: e.code,
        );
      case 'deadline-exceeded':
        return TimeoutFailure(
          'Request timeout: ${e.message}',
          code: e.code,
        );
      default:
        return ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        );
    }
  }
}