/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider (Chart - Clean Architecture)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Domain: GetExerciseChartData use case, ChartDataPoint
/// - Data: ExerciseChartRepository
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/get_exercise_chart_data.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_chart_repository_impl.dart';

/// Provider per use case GetExerciseChartData
///
/// Dependency Injection: Inietta repository
final getExerciseChartDataProvider = Provider<GetExerciseChartData>((ref) {
  final repository = ref.watch(exerciseChartRepositoryProvider);
  return GetExerciseChartData(repository);
});

/// Parameters per chart data request
class ChartDataParams {

  const ChartDataParams({
    required this.exerciseName,
    required this.metric,
    this.days = 90,
  });
  final String exerciseName;
  final String metric;
  final int days;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataParams &&
          runtimeType == other.runtimeType &&
          exerciseName == other.exerciseName &&
          metric == other.metric &&
          days == other.days;

  @override
  int get hashCode => exerciseName.hashCode ^ metric.hashCode ^ days.hashCode;
}

/// Provider per chart data con Clean Architecture
///
/// FASE 1: FutureProvider con use case injection
/// FASE 2: ✅ Either pattern - converte Left a Exception, Right a data
/// FASE 3: TODO - Performance optimization (caching, debounce)
final exerciseChartCleanProvider = FutureProvider.family<List<ChartDataPoint>, ChartDataParams>(
  (ref, params) async {
    final useCase = ref.watch(getExerciseChartDataProvider);

    // Call use case (returns Either<ChartFailure, List<ChartDataPoint>>)
    final result = await useCase(
      exerciseName: params.exerciseName,
      metric: params.metric,
      days: params.days,
    );

    // ✅ FASE 2: Handle Either pattern
    return result.fold(
      // Left (Failure) → throw exception → AsyncValue.error
      (failure) => throw ChartDataException(failure),
      // Right (Success) → return data → AsyncValue.data
      (data) => data,
    );
  },
);

/// Exception wrapper per ChartFailure
///
/// Permette a FutureProvider di catturare errori in AsyncValue.error
class ChartDataException implements Exception {

  const ChartDataException(this.failure);
  final ChartFailure failure;

  @override
  String toString() => 'ChartDataException: ${failure.message}';
}
