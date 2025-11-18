/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/ai_coach/data/mappers
/// 🎯 Feature: ai_coach
/// 🔧 Type: unit_test
///
/// HealthDataMapper Unit Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/mappers/health_data_mapper.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/health_metric.dart';

void main() {
  group('HealthDataMapper', () {
    group('toHealthMetric', () {
      test('converts STEPS data point correctly', () {
        // Arrange
        final dataPoint = HealthDataPoint(
          uuid: 'test-uuid',
          value: NumericHealthValue(numericValue: 8500),
          type: HealthDataType.STEPS,
          unit: HealthDataUnit.COUNT,
          dateFrom: DateTime(2025, 1, 15, 0, 0),
          dateTo: DateTime(2025, 1, 15, 23, 59),
          sourcePlatform: HealthPlatformType.appleHealth,
          sourceDeviceId: 'iphone-14',
          sourceId: 'apple-health',
          sourceName: 'Apple Health',
          recordingMethod: RecordingMethod.automatic,
        );

        // Act
        final result = HealthDataMapper.toHealthMetric(dataPoint);

        // Assert
        expect(result, isNotNull);
        expect(result!.type, HealthMetricType.steps);
        expect(result.value, 8500);
        expect(result.unit, 'count');
        expect(result.sourceDevice, 'iphone-14');
        expect(result.sourceApp, 'Apple Health');
      });

      test('converts HEART_RATE data point correctly', () {
        // Arrange
        final dataPoint = HealthDataPoint(
          uuid: 'test-uuid',
          value: NumericHealthValue(numericValue: 72),
          type: HealthDataType.HEART_RATE,
          unit: HealthDataUnit.BEATS_PER_MINUTE,
          dateFrom: DateTime(2025, 1, 15, 8, 0),
          dateTo: DateTime(2025, 1, 15, 8, 1),
          sourcePlatform: HealthPlatformType.appleHealth,
          sourceDeviceId: 'apple-watch',
          sourceId: 'apple-health',
          sourceName: 'Apple Health',
          recordingMethod: RecordingMethod.automatic,
        );

        // Act
        final result = HealthDataMapper.toHealthMetric(dataPoint);

        // Assert
        expect(result, isNotNull);
        expect(result!.type, HealthMetricType.heartRate);
        expect(result.value, 72);
        expect(result.unit, 'bpm');
      });

      test('converts WORKOUT data point with duration from timestamps', () {
        // Arrange
        final startTime = DateTime(2025, 1, 15, 10, 0);
        final endTime = DateTime(2025, 1, 15, 11, 0); // 1 hour = 3600 seconds

        final dataPoint = HealthDataPoint(
          uuid: 'test-uuid',
          value: WorkoutHealthValue(
            workoutActivityType: HealthWorkoutActivityType.RUNNING,
            totalEnergyBurned: 450,
            totalDistance: 5000, // 5km in meters
          ),
          type: HealthDataType.WORKOUT,
          unit: HealthDataUnit.NO_UNIT,
          dateFrom: startTime,
          dateTo: endTime,
          sourcePlatform: HealthPlatformType.appleHealth,
          sourceDeviceId: 'apple-watch',
          sourceId: 'apple-health',
          sourceName: 'Apple Health',
          recordingMethod: RecordingMethod.manual,
        );

        // Act
        final result = HealthDataMapper.toHealthMetric(dataPoint);

        // Assert
        expect(result, isNotNull);
        expect(result!.type, HealthMetricType.workout);
        expect(result.workoutType, 'RUNNING');
        expect(result.workoutDuration, 3600); // 1 hour in seconds
        expect(result.workoutDistance, 5000);
      });

      test('returns null for unsupported data type', () {
        // Arrange
        final dataPoint = HealthDataPoint(
          uuid: 'test-uuid',
          value: NumericHealthValue(numericValue: 100),
          type: HealthDataType.BLOOD_GLUCOSE, // Unsupported type
          unit: HealthDataUnit.MILLIGRAM_PER_DECILITER,
          dateFrom: DateTime(2025, 1, 15),
          dateTo: DateTime(2025, 1, 15),
          sourcePlatform: HealthPlatformType.appleHealth,
          sourceDeviceId: 'device',
          sourceId: 'id',
          sourceName: 'name',
          recordingMethod: RecordingMethod.automatic,
        );

        // Act
        final result = HealthDataMapper.toHealthMetric(dataPoint);

        // Assert
        expect(result, isNull);
      });
    });

    group('toHealthMetrics', () {
      test('converts list of data points and filters nulls', () {
        // Arrange
        final dataPoints = [
          HealthDataPoint(
            uuid: '1',
            value: NumericHealthValue(numericValue: 8500),
            type: HealthDataType.STEPS,
            unit: HealthDataUnit.COUNT,
            dateFrom: DateTime(2025, 1, 15),
            dateTo: DateTime(2025, 1, 15),
            sourcePlatform: HealthPlatformType.appleHealth,
            sourceDeviceId: 'device',
            sourceId: 'id',
            sourceName: 'name',
            recordingMethod: RecordingMethod.automatic,
          ),
          HealthDataPoint(
            uuid: '2',
            value: NumericHealthValue(numericValue: 100),
            type: HealthDataType.BLOOD_GLUCOSE, // Unsupported - should be filtered
            unit: HealthDataUnit.MILLIGRAM_PER_DECILITER,
            dateFrom: DateTime(2025, 1, 15),
            dateTo: DateTime(2025, 1, 15),
            sourcePlatform: HealthPlatformType.appleHealth,
            sourceDeviceId: 'device',
            sourceId: 'id',
            sourceName: 'name',
            recordingMethod: RecordingMethod.automatic,
          ),
          HealthDataPoint(
            uuid: '3',
            value: NumericHealthValue(numericValue: 72),
            type: HealthDataType.HEART_RATE,
            unit: HealthDataUnit.BEATS_PER_MINUTE,
            dateFrom: DateTime(2025, 1, 15),
            dateTo: DateTime(2025, 1, 15),
            sourcePlatform: HealthPlatformType.appleHealth,
            sourceDeviceId: 'device',
            sourceId: 'id',
            sourceName: 'name',
            recordingMethod: RecordingMethod.automatic,
          ),
        ];

        // Act
        final result = HealthDataMapper.toHealthMetrics(dataPoints);

        // Assert
        expect(result, hasLength(2)); // 1 unsupported filtered out
        expect(result[0].type, HealthMetricType.steps);
        expect(result[1].type, HealthMetricType.heartRate);
      });
    });

    group('toHealthMetricSummary', () {
      test('aggregates data points correctly', () {
        // Arrange
        final dataPoints = [
          HealthDataPoint(
            uuid: '1',
            value: NumericHealthValue(numericValue: 8000),
            type: HealthDataType.STEPS,
            unit: HealthDataUnit.COUNT,
            dateFrom: DateTime(2025, 1, 15, 0, 0),
            dateTo: DateTime(2025, 1, 15, 23, 59),
            sourcePlatform: HealthPlatformType.appleHealth,
            sourceDeviceId: 'device',
            sourceId: 'id',
            sourceName: 'name',
            recordingMethod: RecordingMethod.automatic,
          ),
          HealthDataPoint(
            uuid: '2',
            value: NumericHealthValue(numericValue: 10000),
            type: HealthDataType.STEPS,
            unit: HealthDataUnit.COUNT,
            dateFrom: DateTime(2025, 1, 16, 0, 0),
            dateTo: DateTime(2025, 1, 16, 23, 59),
            sourcePlatform: HealthPlatformType.appleHealth,
            sourceDeviceId: 'device',
            sourceId: 'id',
            sourceName: 'name',
            recordingMethod: RecordingMethod.automatic,
          ),
          HealthDataPoint(
            uuid: '3',
            value: NumericHealthValue(numericValue: 6000),
            type: HealthDataType.STEPS,
            unit: HealthDataUnit.COUNT,
            dateFrom: DateTime(2025, 1, 17, 0, 0),
            dateTo: DateTime(2025, 1, 17, 23, 59),
            sourcePlatform: HealthPlatformType.appleHealth,
            sourceDeviceId: 'device',
            sourceId: 'id',
            sourceName: 'name',
            recordingMethod: RecordingMethod.automatic,
          ),
        ];

        // Act
        final result = HealthDataMapper.toHealthMetricSummary(dataPoints);

        // Assert
        expect(result, isNotNull);
        expect(result!.metricType, HealthMetricType.steps);
        expect(result.totalValue, 24000); // 8000 + 10000 + 6000
        expect(result.averageValue, 8000); // 24000 / 3
        expect(result.minValue, 6000);
        expect(result.maxValue, 10000);
        expect(result.dataPoints, 3);
        expect(result.unit, 'count');
      });

      test('returns null for empty list', () {
        // Act
        final result = HealthDataMapper.toHealthMetricSummary([]);

        // Assert
        expect(result, isNull);
      });
    });

    group('toFirebaseMap', () {
      test('converts HealthMetric to Firebase map', () {
        // Arrange
        final metric = HealthMetric(
          type: HealthMetricType.steps,
          value: 8500,
          unit: 'count',
          dateFrom: DateTime(2025, 1, 15, 0, 0),
          dateTo: DateTime(2025, 1, 15, 23, 59),
          sourceDevice: 'iphone-14',
          sourceApp: 'Apple Health',
        );

        // Act
        final result = HealthDataMapper.toFirebaseMap(metric);

        // Assert
        expect(result['type'], 'steps');
        expect(result['value'], 8500);
        expect(result['unit'], 'count');
        expect(result['date_from'], '2025-01-15T00:00:00.000');
        expect(result['date_to'], '2025-01-15T23:59:00.000');
        expect(result['source_device'], 'iphone-14');
        expect(result['source_app'], 'Apple Health');
      });

      test('includes workout fields when present', () {
        // Arrange
        final metric = HealthMetric(
          type: HealthMetricType.workout,
          value: 450,
          unit: 'kcal',
          dateFrom: DateTime(2025, 1, 15, 10, 0),
          dateTo: DateTime(2025, 1, 15, 11, 0),
          workoutType: 'RUNNING',
          workoutDuration: 3600,
          workoutDistance: 5000,
        );

        // Act
        final result = HealthDataMapper.toFirebaseMap(metric);

        // Assert
        expect(result['workout_type'], 'RUNNING');
        expect(result['workout_duration'], 3600);
        expect(result['workout_distance'], 5000);
      });
    });

    group('metricsToFirebaseMap', () {
      test('groups metrics by type and adds metadata', () {
        // Arrange
        final metrics = [
          HealthMetric(
            type: HealthMetricType.steps,
            value: 8500,
            unit: 'count',
            dateFrom: DateTime(2025, 1, 15),
            dateTo: DateTime(2025, 1, 15),
          ),
          HealthMetric(
            type: HealthMetricType.heartRate,
            value: 72,
            unit: 'bpm',
            dateFrom: DateTime(2025, 1, 15),
            dateTo: DateTime(2025, 1, 15),
          ),
        ];

        // Act
        final result = HealthDataMapper.metricsToFirebaseMap(metrics);

        // Assert
        expect(result['steps_metrics'], hasLength(1));
        expect(result['heartRate_metrics'], hasLength(1));
        expect(result['total_metrics'], 2);
        expect(result['synced_at'], isNotNull);
      });
    });
  });
}
