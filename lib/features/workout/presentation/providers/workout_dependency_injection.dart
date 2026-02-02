/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: dependency_injection
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Riverpod for DI
/// - Firebase services
/// - All layers (data, domain, presentation)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data layer providers
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_repository_impl.dart';

// Domain layer providers
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/save_workout_usecase.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/update_exercise_set_usecase.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/get_workouts_usecase.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/complete_workout_usecase.dart';

// Re-export common imports for convenience
export 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
export 'package:gymbro_flutter_new/features/workout/domain/usecases/save_workout_usecase.dart';
export 'package:gymbro_flutter_new/features/workout/domain/usecases/update_exercise_set_usecase.dart';
export 'package:gymbro_flutter_new/features/workout/domain/usecases/get_workouts_usecase.dart';
export 'package:gymbro_flutter_new/features/workout/domain/usecases/complete_workout_usecase.dart';
export 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
export 'package:gymbro_flutter_new/shared/domain/either/either.dart';

/// Firebase instances
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Data Source Layer
final firebaseWorkoutDataSourceProvider = Provider<FirebaseWorkoutDataSource>((
  ref,
) {
  final firestore = ref.read(firebaseFirestoreProvider);
  return FirebaseWorkoutDataSource(firestore);
});

/// Repository Layer
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dataSource = ref.read(firebaseWorkoutDataSourceProvider);
  final auth = ref.read(firebaseAuthProvider);

  return WorkoutRepositoryImpl(dataSource: dataSource, auth: auth);
});

/// Use Cases Layer
final saveWorkoutUseCaseProvider = Provider<SaveWorkoutUseCase>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return SaveWorkoutUseCase(repository);
});

final updateExerciseSetUseCaseProvider = Provider<UpdateExerciseSetUseCase>((
  ref,
) {
  final repository = ref.read(workoutRepositoryProvider);
  return UpdateExerciseSetUseCase(repository);
});

final getWorkoutsUseCaseProvider = Provider<GetWorkoutsUseCase>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return GetWorkoutsUseCase(repository);
});

final completeWorkoutUseCaseProvider = Provider<CompleteWorkoutUseCase>((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return CompleteWorkoutUseCase(repository);
});

/// Utility providers for common operations
final currentUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  return auth.authStateChanges();
});

final currentUserEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.email?.toLowerCase().trim();
});

/// Workout Stream Providers
final activeWorkoutStreamProvider = StreamProvider((ref) {
  final repository = ref.read(workoutRepositoryProvider);
  return repository.watchActiveWorkout();
});

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final workoutStatsProvider = FutureProvider.autoDispose
    .family<WorkoutStats?, WorkoutStatsParams>((ref, params) async {
      final repository = ref.read(workoutRepositoryProvider);

      final result = await repository.getWorkoutStats(
        startDate: params.startDate,
        endDate: params.endDate,
      );

      return result.fold(
        (failure) => null, // Could handle error differently
        (stats) => stats,
      );
    });

/// Parameter classes for family providers
class WorkoutStatsParams {
  const WorkoutStatsParams({this.startDate, this.endDate});
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutStatsParams &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

class WorkoutHistoryParams {
  const WorkoutHistoryParams({this.page = 1, this.limit = 10});
  final int page;
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutHistoryParams &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode;
}
