/// Recovery stats tool executor for AI Coach
///
/// Handles: getRecoveryData
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart'
    as h;
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart'
    as health;
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/repositories/health_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/healthkit_datasource.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';

class RecoveryStatsExecutor {
  const RecoveryStatsExecutor({
    required this.historyRepo,
    this.healthRepo,
    this.healthKitDatasource,
  });

  final WorkoutHistoryRepositoryEnhanced historyRepo;
  final IHealthRepository? healthRepo;
  final HealthKitDatasource? healthKitDatasource;

  // ------------------------------------------------------------------
  // getRecoveryData
  // ------------------------------------------------------------------

  Future<String> getRecoveryData(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final workoutsEither = await historyRepo.getWorkouts();

      return await workoutsEither.fold(
        (failure) async => jsonEncode({
          'error': 'Failed to fetch workouts: ${failure.message}',
          'toolName': 'getRecoveryData',
        }),
        (workouts) async {
          final now = DateTime.now();
          final sevenDaysAgo = now.subtract(const Duration(days: 7));

          final recentWorkouts = workouts
              .where((w) => w.completedAt.isAfter(sevenDaysAgo))
              .toList();

          int daysSinceLastWorkout = -1;
          if (workouts.isNotEmpty) {
            final sorted = [...workouts]
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
            daysSinceLastWorkout =
                now.difference(sorted.first.completedAt).inDays;
          }

          double score = 70.0;
          if (recentWorkouts.length >= 6) {
            score -= 25;
          } else if (recentWorkouts.length >= 4) {
            score -= 10;
          } else if (recentWorkouts.length <= 2) {
            score += 6;
          }

          if (daysSinceLastWorkout >= 3) score += 8;
          if (daysSinceLastWorkout == 0) score -= 6;

          double? avgSleepHours;
          double? currentHeartRate;
          double? baselineHeartRate;
          double? hrvRatioToBaseline;
          final healthSignals = <String, dynamic>{};

          if (healthRepo != null) {
            final healthNow = DateTime.now();
            final sleepResult = await healthRepo!.getMeasurements(
              dataType: HealthDataType.sleep,
              startDate: healthNow.subtract(const Duration(days: 7)),
              endDate: healthNow,
            );
            final heartThisWeekResult = await healthRepo!.getMeasurements(
              dataType: HealthDataType.heartRate,
              startDate: healthNow.subtract(const Duration(days: 7)),
              endDate: healthNow,
            );
            final heartBaselineResult = await healthRepo!.getMeasurements(
              dataType: HealthDataType.heartRate,
              startDate: healthNow.subtract(const Duration(days: 14)),
              endDate: healthNow.subtract(const Duration(days: 7)),
            );

            sleepResult.fold((_) {}, (sleepPoints) {
              if (sleepPoints.isNotEmpty) {
                final values = sleepPoints
                    .map(_sleepHoursFromMeasurement)
                    .where((v) => v > 0)
                    .toList();
                if (values.isNotEmpty) {
                  avgSleepHours =
                      values.reduce((a, b) => a + b) / values.length;
                }
              }
            });

            heartThisWeekResult.fold((_) {}, (heartPoints) {
              if (heartPoints.isNotEmpty) {
                final values = heartPoints.map((m) => m.value).toList();
                currentHeartRate =
                    values.reduce((a, b) => a + b) / values.length;
              }
            });

            heartBaselineResult.fold((_) {}, (heartPoints) {
              if (heartPoints.isNotEmpty) {
                final values = heartPoints.map((m) => m.value).toList();
                baselineHeartRate =
                    values.reduce((a, b) => a + b) / values.length;
              }
            });
          }

          if (healthKitDatasource != null && avgSleepHours == null) {
            try {
              final sleepAnalytics =
                  await healthKitDatasource!.getSleepAnalytics(days: 7);
              if (sleepAnalytics['available'] == true &&
                  avgSleepHours == null) {
                avgSleepHours =
                    (sleepAnalytics['avg_sleep_hours'] as num?)?.toDouble();
              }

              final hrvAnalytics =
                  await healthKitDatasource!.getHrvAnalytics(days: 7);
              if (hrvAnalytics['available'] == true) {
                hrvRatioToBaseline =
                    (hrvAnalytics['ratio_to_baseline'] as num?)?.toDouble();
              }
            } catch (_) {
              // Keep recovery calculation robust even if HealthKit calls fail.
            }
          }

          final sleepHours = avgSleepHours;
          if (sleepHours != null) {
            healthSignals['avgSleepHours'] = avgSleepHours;
            if (sleepHours < 6) {
              score -= 18;
            } else if (sleepHours < 7) {
              score -= 10;
            } else if (sleepHours <= 9) {
              score += 8;
            } else {
              score -= 4;
            }
          }

          if (currentHeartRate != null && baselineHeartRate != null) {
            final delta = currentHeartRate! - baselineHeartRate!;
            healthSignals['heartRateDelta'] = delta.toStringAsFixed(1);
            if (delta >= 6) {
              score -= 12;
            } else if (delta <= -3) {
              score += 5;
            }
          }

          if (hrvRatioToBaseline != null) {
            healthSignals['hrvRatioToBaseline'] =
                hrvRatioToBaseline.toStringAsFixed(2);
            if (hrvRatioToBaseline < 0.85) {
              score -= 15;
            } else if (hrvRatioToBaseline > 1.10) {
              score += 8;
            }
          }

          score = score.clamp(0, 100);

          final recoveryStatus = score >= 75
              ? 'green'
              : score >= 45
                  ? 'amber'
                  : 'red';

          final confidenceSignals = [
            avgSleepHours,
            currentHeartRate,
            baselineHeartRate,
            hrvRatioToBaseline,
          ].whereType<Object>().length;

          return jsonEncode({
            'workoutsLast7Days': recentWorkouts.length,
            'daysSinceLastWorkout': daysSinceLastWorkout,
            'recoveryStatus': recoveryStatus,
            'recoveryScore': score.round(),
            'confidence': confidenceSignals >= 3
                ? 'high'
                : confidenceSignals >= 1
                    ? 'medium'
                    : 'low',
            'healthSignals': healthSignals,
            'recommendation': _getRecoveryRecommendation(
              workoutsLast7Days: recentWorkouts.length,
              daysSinceLastWorkout: daysSinceLastWorkout,
              recoveryStatus: recoveryStatus,
              avgSleepHours: avgSleepHours,
              hrvRatioToBaseline: hrvRatioToBaseline,
            ),
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getRecoveryData',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getRecoveryData',
      });
    }
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  double _sleepHoursFromMeasurement(health.BodyMeasurement measurement) {
    return switch (measurement.unit) {
      health.MeasurementUnit.minutes => measurement.value / 60,
      health.MeasurementUnit.percent ||
      health.MeasurementUnit.kilograms ||
      health.MeasurementUnit.pounds ||
      health.MeasurementUnit.bpm ||
      health.MeasurementUnit.meters ||
      health.MeasurementUnit.centimeters => measurement.value,
    };
  }

  String _getRecoveryRecommendation({
    required int workoutsLast7Days,
    required int daysSinceLastWorkout,
    required String recoveryStatus,
    double? avgSleepHours,
    double? hrvRatioToBaseline,
  }) {
    if (recoveryStatus == 'red') {
      return 'Oggi meglio recupero attivo o rest day: volume recente alto e segnali di recupero non ottimali.';
    }

    if (recoveryStatus == 'amber') {
      if (avgSleepHours != null && avgSleepHours < 7) {
        return 'Recupero medio: mantieni intensità moderata e punta a 7-9h di sonno stanotte.';
      }
      return 'Recupero discreto: bene una sessione moderata, evita cedimento sistematico.';
    }

    if (daysSinceLastWorkout >= 4) {
      return 'Buona freschezza: puoi pianificare una sessione intensa con focus sui fondamentali.';
    }
    if (workoutsLast7Days <= 2) {
      return 'Recupero alto: puoi aumentare leggermente intensità o volume nella prossima seduta.';
    }
    if (hrvRatioToBaseline != null && hrvRatioToBaseline > 1.1) {
      return 'Segnali molto positivi di readiness: ottimo momento per progressione controllata.';
    }
    return 'Recupero buono: continua con progressione graduale mantenendo tecnica e qualità del sonno.';
  }
}
