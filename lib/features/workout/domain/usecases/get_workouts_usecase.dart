/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain/usecases
 * 🎯 Feature: workout
 * 🔧 Type: usecase
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Domain entities
 * - Repository interface
 * - Shared failures
 */

import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

/// Use case for retrieving workouts with filtering and business logic
class GetWorkoutsUseCase {
  final WorkoutRepository _repository;
  
  const GetWorkoutsUseCase(this._repository);
  
  /// Get workouts with filtering and sorting
  Future<Either<Failure, List<Workout>>> call(GetWorkoutsParams params) async {
    // Validate parameters
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return left(validationResult);
    }
    
    try {
      // Get workouts from repository
      final result = await _repository.getWorkouts(
        limit: params.limit,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      
      // Apply additional business logic filtering/sorting
      return result.map((workouts) => _processWorkouts(workouts, params));
      
    } catch (e) {
      return left(UnexpectedFailure('Failed to retrieve workouts: $e'));
    }
  }
  
  /// Validate parameters
  ValidationFailure? _validateParams(GetWorkoutsParams params) {
    if (params.limit != null && params.limit! <= 0) {
      return const ValidationFailure(
        'Limit must be greater than 0',
        code: 'invalid_limit',
      );
    }
    
    if (params.limit != null && params.limit! > 1000) {
      return const ValidationFailure(
        'Limit cannot exceed 1000',
        code: 'limit_too_high',
      );
    }
    
    if (params.startDate != null && 
        params.endDate != null && 
        params.startDate!.isAfter(params.endDate!)) {
      return const ValidationFailure(
        'Start date cannot be after end date',
        code: 'invalid_date_range',
      );
    }
    
    return null;
  }
  
  /// Process workouts with business logic
  List<Workout> _processWorkouts(List<Workout> workouts, GetWorkoutsParams params) {
    var result = workouts;
    
    // Apply status filtering
    if (params.statusFilter != null) {
      result = result.where((w) => w.status == params.statusFilter).toList();
    }
    
    // Apply minimum duration filter
    if (params.minDuration != null) {
      result = result.where((w) {
        final duration = w.duration;
        return duration != null && duration >= params.minDuration!;
      }).toList();
    }
    
    // Apply exercise count filter
    if (params.minExercises != null) {
      result = result.where((w) => w.exercises.length >= params.minExercises!).toList();
    }
    
    // Apply sorting
    switch (params.sortBy) {
      case WorkoutSortBy.date:
        result.sort((a, b) {
          final aDate = a.startTime ?? a.createdAt;
          final bDate = b.startTime ?? b.createdAt;
          return params.sortDescending ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
        });
        break;
      case WorkoutSortBy.name:
        result.sort((a, b) => params.sortDescending ? 
          b.name.compareTo(a.name) : a.name.compareTo(b.name));
        break;
      case WorkoutSortBy.duration:
        result.sort((a, b) {
          final aDuration = a.duration?.inMinutes ?? 0;
          final bDuration = b.duration?.inMinutes ?? 0;
          return params.sortDescending ? bDuration.compareTo(aDuration) : aDuration.compareTo(bDuration);
        });
        break;
      case WorkoutSortBy.exerciseCount:
        result.sort((a, b) => params.sortDescending ? 
          b.exercises.length.compareTo(a.exercises.length) : 
          a.exercises.length.compareTo(b.exercises.length));
        break;
    }
    
    return result;
  }
}

/// Parameters for GetWorkoutsUseCase
class GetWorkoutsParams {
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;
  final WorkoutStatus? statusFilter;
  final Duration? minDuration;
  final int? minExercises;
  final WorkoutSortBy sortBy;
  final bool sortDescending;
  
  const GetWorkoutsParams({
    this.limit,
    this.startDate,
    this.endDate,
    this.statusFilter,
    this.minDuration,
    this.minExercises,
    this.sortBy = WorkoutSortBy.date,
    this.sortDescending = true,
  });
}

/// Enum for workout sorting options
enum WorkoutSortBy {
  date,
  name,
  duration,
  exerciseCount,
}