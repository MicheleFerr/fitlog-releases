/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository implementation (Chart Data)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Domain: ChartDataPoint, ExerciseChartRepository
/// - Data: ExerciseHistoryService
library;

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/exercise_chart_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Implementazione concreta del repository chart data
///
/// Clean Architecture: Implementa interfaccia domain, usa data sources.
///
/// Data sources:
/// - exerciseHistoryDataGroupedProvider (via Ref)
///
/// FASE 1: Implementazione base
/// FASE 2: Aggiunto error handling con Either
class ExerciseChartRepositoryImpl implements ExerciseChartRepository {
  final Ref _ref;

  const ExerciseChartRepositoryImpl(this._ref);

  @override
  Future<Either<ChartFailure, List<ChartDataPoint>>> getChartData({
    required String exerciseName,
    required String metric,
    int days = 90,
  }) async {
    try {
      // ✅ FASE 2: Input validation
      if (exerciseName.trim().isEmpty) {
        return left(const ChartFailure.invalidInput(
          message: 'Exercise name cannot be empty',
          details: 'exerciseName',
        ));
      }

      if (!_isValidMetric(metric)) {
        return left(ChartFailure.invalidInput(
          message: 'Invalid metric: $metric',
          details: 'metric must be one of: Peso, Reps, RPE, TUT',
        ));
      }

      if (days <= 0) {
        return left(ChartFailure.invalidInput(
          message: 'Days must be positive',
          details: 'days: $days',
        ));
      }

      // Ottiene dati raggruppati dal provider esistente
      final historyGrouped = await _ref.read(
        exerciseHistoryDataGroupedProvider(exerciseName).future,
      );

      // Filtra per ultimi N giorni
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final dataPoints = <ChartDataPoint>[];

      historyGrouped.forEach((date, sets) {
        if (date.isAfter(cutoffDate) || date.isAtSameMomentAs(cutoffDate)) {
          // Calcola valore medio per metrica
          final value = _calculateMetricAverage(sets, metric);

          if (value != null) {
            dataPoints.add(ChartDataPoint(date: date, value: value));
          }
        }
      });

      // Ordina per data crescente
      dataPoints.sort((a, b) => a.date.compareTo(b.date));

      // ✅ FASE 2: Success - Right
      return right(dataPoints);
    } on FirebaseException catch (e) {
      // ✅ FASE 2: Firestore/Server error
      return left(ChartFailure.serverFailure(
        message: 'Firebase error: ${e.code}',
        error: e,
      ));
    } catch (e, stack) {
      // ✅ FASE 2: Unknown error
      return left(ChartFailure.unknown(
        message: 'Unexpected error occurred',
        error: e,
        stackTrace: stack,
      ));
    }
  }

  /// Valida metrica supportata
  ///
  /// ✅ UPDATED: Tutte le metriche ora disponibili in ExerciseHistoryData
  bool _isValidMetric(String metric) {
    const validMetrics = ['Peso', 'Reps', 'RPE', 'TUT'];
    return validMetrics.contains(metric);
  }

  /// Calcola media metrica da lista set
  ///
  /// Returns null se nessun valore valido
  double? _calculateMetricAverage(
    List<ExerciseHistoryData> sets,
    String metric,
  ) {
    switch (metric) {
      case 'Peso':
        final weights = sets.where((s) => s.weight != null).map((s) => s.weight!);
        return weights.isNotEmpty
            ? weights.reduce((a, b) => a + b) / weights.length
            : null;

      case 'Reps':
        final reps = sets.where((s) => s.reps != null).map((s) => s.reps!.toDouble());
        return reps.isNotEmpty
            ? reps.reduce((a, b) => a + b) / reps.length
            : null;

      case 'RPE':
        // ✅ RPE: Average Rate of Perceived Exertion (5-10 scale)
        final rpeValues = sets.where((s) => s.rpe != null).map((s) => s.rpe!.toDouble());

        // ✅ DEBUG: Log RPE data availability
        if (kDebugMode) {
          debugPrint('📊 RPE Calculation: ${sets.length} sets total, ${rpeValues.length} with RPE');
          if (rpeValues.isNotEmpty) {
            debugPrint('   RPE values: ${rpeValues.toList()}');
          } else {
            debugPrint('   ⚠️ NO RPE DATA - user needs to add RPE to workout sets');
          }
        }

        return rpeValues.isNotEmpty
            ? rpeValues.reduce((a, b) => a + b) / rpeValues.length
            : null;

      case 'TUT':
        // ✅ TUT: Average set duration in seconds (from setDurationMillis)
        final durations = sets
            .where((s) => s.setDurationMillis != null)
            .map((s) => s.setDurationMillis! / 1000); // Convert ms to seconds
        return durations.isNotEmpty
            ? durations.reduce((a, b) => a + b) / durations.length
            : null;

      default:
        return null;
    }
  }
}

/// Provider per repository implementation
///
/// Dependency Injection: Inietta Ref per accesso a data sources
final exerciseChartRepositoryProvider = Provider<ExerciseChartRepository>((ref) {
  return ExerciseChartRepositoryImpl(ref);
});
