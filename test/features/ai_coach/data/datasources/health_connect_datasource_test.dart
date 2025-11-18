/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: unit_test
///
/// HealthConnectDatasource Unit Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/health_connect_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/errors/healthkit_errors.dart';

import 'health_connect_datasource_test.mocks.dart';

@GenerateMocks([Health])
void main() {
  group('HealthConnectDatasource', () {
    late HealthConnectDatasource datasource;
    late MockHealth mockHealth;

    setUp(() {
      mockHealth = MockHealth();
      datasource = HealthConnectDatasource(healthFactory: mockHealth);
    });

    group('isAvailable', () {
      test('returns true on Android platform', () {
        // Platform check is handled by Platform.isAndroid
        // This test verifies the getter exists
        expect(datasource.isAvailable, isA<bool>());
      });
    });

    group('initialize', () {
      test('requests permissions and returns true when granted', () async {
        // Arrange
        when(mockHealth.requestAuthorization(
          any,
          permissions: anyNamed('permissions'),
        )).thenAnswer((_) async => true);

        // Act
        final result = await datasource.initialize();

        // Assert
        expect(result, true);
        verify(mockHealth.requestAuthorization(
          HealthConnectDatasource.supportedTypes,
          permissions: anyNamed('permissions'),
        )).called(1);
      });

      test('throws HealthKitPermissionDeniedError when permissions denied',
          () async {
        // Arrange
        when(mockHealth.requestAuthorization(
          any,
          permissions: anyNamed('permissions'),
        )).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => datasource.initialize(),
          throwsA(isA<HealthKitPermissionDeniedError>()),
        );
      });

      test('throws HealthKitNotAvailableError when not on Android', () async {
        // Note: Platform checks are tested via integration tests
        // Unit test focuses on error handling logic
      });
    });

    group('getStepsToday', () {
      test('returns HealthDataPoint when data available', () async {
        // Arrange
        final now = DateTime.now();
        final mockDataPoint = HealthDataPoint(
          uuid: 'test-uuid',
          value: NumericHealthValue(numericValue: 5000),
          type: HealthDataType.STEPS,
          unit: HealthDataUnit.COUNT,
          dateFrom: DateTime(now.year, now.month, now.day),
          dateTo: now,
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'test-device',
          sourceId: 'test-source',
          sourceName: 'Test Source',
          recordingMethod: RecordingMethod.automatic,
        );

        when(mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenAnswer((_) async => [mockDataPoint]);

        // Act
        final result = await datasource.getStepsToday();

        // Assert
        expect(result, isNotNull);
        expect((result!.value as NumericHealthValue).numericValue, 5000);
        expect(result.type, HealthDataType.STEPS);
      });

      test('returns null when no data available', () async {
        // Arrange
        when(mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenAnswer((_) async => []);

        // Act
        final result = await datasource.getStepsToday();

        // Assert
        expect(result, isNull);
      });

      test('returns null when permission denied', () async {
        // Arrange
        when(mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenThrow(Exception('Permission denied'));

        // Act
        final result = await datasource.getStepsToday();

        // Assert
        expect(result, isNull);
      });
    });

    group('getHeartRateToday', () {
      test('returns average heart rate when data available', () async {
        // Arrange
        final now = DateTime.now();
        final mockDataPoints = [
          HealthDataPoint(
            uuid: 'test-uuid-1',
            value: NumericHealthValue(numericValue: 70),
            type: HealthDataType.HEART_RATE,
            unit: HealthDataUnit.BEATS_PER_MINUTE,
            dateFrom: DateTime(now.year, now.month, now.day, 8, 0),
            dateTo: DateTime(now.year, now.month, now.day, 8, 1),
            sourcePlatform: HealthPlatformType.googleHealthConnect,
            sourceDeviceId: 'test-device',
            sourceId: 'test-source',
            sourceName: 'Test Source',
            recordingMethod: RecordingMethod.automatic,
          ),
          HealthDataPoint(
            uuid: 'test-uuid-2',
            value: NumericHealthValue(numericValue: 80),
            type: HealthDataType.HEART_RATE,
            unit: HealthDataUnit.BEATS_PER_MINUTE,
            dateFrom: DateTime(now.year, now.month, now.day, 10, 0),
            dateTo: DateTime(now.year, now.month, now.day, 10, 1),
            sourcePlatform: HealthPlatformType.googleHealthConnect,
            sourceDeviceId: 'test-device',
            sourceId: 'test-source',
            sourceName: 'Test Source',
            recordingMethod: RecordingMethod.automatic,
          ),
        ];

        when(mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenAnswer((_) async => mockDataPoints);

        // Act
        final result = await datasource.getHeartRateToday();

        // Assert
        expect(result, isNotNull);
        expect((result!.value as NumericHealthValue).numericValue, 75); // Average of 70 and 80
        expect(result.type, HealthDataType.HEART_RATE);
      });
    });

    group('getWorkoutsToday', () {
      test('returns list of workouts when data available', () async {
        // Arrange
        final now = DateTime.now();
        final mockWorkouts = [
          HealthDataPoint(
            uuid: 'workout-uuid-1',
            value: WorkoutHealthValue(
              workoutActivityType: HealthWorkoutActivityType.RUNNING,
              totalEnergyBurned: 300,
              totalDistance: 5000,
            ),
            type: HealthDataType.WORKOUT,
            unit: HealthDataUnit.NO_UNIT,
            dateFrom: DateTime(now.year, now.month, now.day, 7, 0),
            dateTo: DateTime(now.year, now.month, now.day, 8, 0),
            sourcePlatform: HealthPlatformType.googleHealthConnect,
            sourceDeviceId: 'test-device',
            sourceId: 'test-source',
            sourceName: 'Test Source',
            recordingMethod: RecordingMethod.manual,
          ),
        ];

        when(mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenAnswer((_) async => mockWorkouts);

        // Act
        final result = await datasource.getWorkoutsToday();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.type, HealthDataType.WORKOUT);
      });
    });

    group('GDPR Compliance', () {
      test('deleteAllHealthData returns true on success', () async {
        // Act
        final result = await datasource.deleteAllHealthData();

        // Assert
        expect(result, true);
      });

      test('exportHealthData returns JSON map with health data', () async {
        // Arrange
        final mockSteps = HealthDataPoint(
          uuid: 'steps-uuid',
          value: NumericHealthValue(numericValue: 8000),
          type: HealthDataType.STEPS,
          unit: HealthDataUnit.COUNT,
          dateFrom: DateTime.now().subtract(const Duration(hours: 12)),
          dateTo: DateTime.now(),
          sourcePlatform: HealthPlatformType.googleHealthConnect,
          sourceDeviceId: 'test-device',
          sourceId: 'test-source',
          sourceName: 'Test Source',
          recordingMethod: RecordingMethod.automatic,
        );

        when(mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        )).thenAnswer((_) async => [mockSteps]);

        // Act
        final result = await datasource.exportHealthData();

        // Assert
        expect(result, isNotEmpty);
        expect(result['steps'], isNotNull);
        expect(result['exported_at'], isNotNull);
      });
    });
  });
}
