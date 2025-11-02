/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository interface (Chart Data)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - ChartDataPoint entity
/// - Either/ChartFailure (FASE 2)
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';

/// Repository interface per chart data - definisce contratto per data layer
///
/// Clean Architecture: Domain layer non dipende da implementation details.
/// Data layer implementerà questo contratto.
///
/// FASE 1: Return type semplice (Future<List<ChartDataPoint>>)
/// FASE 2: Aggiornato a Either<Failure, List<ChartDataPoint>>
abstract class ExerciseChartRepository {
  /// Ottiene dati grafico per esercizio e metrica specifici
  ///
  /// [exerciseName] - Nome esercizio
  /// [metric] - Metrica da visualizzare (Peso/Reps/RPE/TUT)
  /// [days] - Numero giorni da filtrare (default 90)
  ///
  /// Returns Either:
  /// - Right: Lista ChartDataPoint ordinati per data crescente (può essere vuota)
  /// - Left: ChartFailure specifico per tipo di errore
  ///
  /// FASE 2: ✅ Either pattern implementato
  Future<Either<ChartFailure, List<ChartDataPoint>>> getChartData({
    required String exerciseName,
    required String metric,
    int days = 90,
  });
}
