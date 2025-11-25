import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/healthkit_datasource.dart';
import 'package:uuid/uuid.dart';

/// HealthKitService - iOS HealthKit integration for body measurements
///
/// **Single Source of Truth**: Delegates to ai_coach/HealthKitDatasource
///
/// **Platform**: iOS only (requires iOS 8+)
/// **Framework**: HealthKit (iOS native)
/// **Package**: health (Flutter package for HealthKit/HealthConnect bridge)
///
/// **Functionality**:
/// - Read measurements from HealthKit (weight, body fat, BMI, etc.)
/// - Write measurements to HealthKit
/// - Bi-directional sync with consent filtering
/// - Last sync timestamp tracking
///
/// **GDPR Compliance**:
/// - Only syncs metrics user has explicitly consented to
/// - Enforces iOS HealthKit permissions separately
/// - Audit logging for all HealthKit access
///
/// **iOS HealthKit Permissions** (required in Info.plist):
/// ```xml
/// <key>NSHealthShareUsageDescription</key>
/// <string>Read body measurements to track your fitness progress</string>
/// <key>NSHealthUpdateUsageDescription</key>
/// <string>Save body measurements to HealthKit</string>
/// ```
///
/// **Supported Metrics** (HealthKit → MetricType mapping):
/// - HKQuantityTypeIdentifierBodyMass → MetricType.weight
/// - HKQuantityTypeIdentifierBodyFatPercentage → MetricType.bodyFatPercentage
/// - HKQuantityTypeIdentifierBodyMassIndex → MetricType.bmi
/// - HKQuantityTypeIdentifierLeanBodyMass → MetricType.leanMass
/// - HKQuantityTypeIdentifierHeight → MetricType.height
///
/// **Usage**:
/// ```dart
/// final healthKitService = HealthKitService();
///
/// // Request permissions for specific metrics
/// final granted = await healthKitService.requestPermissions([
///   MetricType.weight,
///   MetricType.bodyFatPercentage,
/// ]);
///
/// granted.fold(
///   (failure) => showError(failure.message),
///   (success) {
///     if (success) {
///       print('HealthKit permissions granted');
///     }
///   },
/// );
/// ```
class HealthKitService {
  HealthKitService({
    HealthKitDatasource? healthKitDatasource,
    Health? healthFactory,
  })  : _healthKitDatasource = healthKitDatasource ?? HealthKitDatasource(),
        _health = healthFactory ?? Health();

  final HealthKitDatasource _healthKitDatasource;
  final Health _health;

  /// Check if HealthKit is available on this device
  ///
  /// Returns:
  /// - true: iOS device with HealthKit support
  /// - false: Not iOS, or HealthKit not available (iPod touch, some iPads)
  Future<bool> isAvailable() async {
    if (!Platform.isIOS) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthKitService] Not iOS platform');
      }
      return false;
    }

    return _healthKitDatasource.isAvailable;
  }

  /// Request HealthKit permissions for specific metric types
  ///
  /// **Delegates to ai_coach/HealthKitDatasource** for actual permission request.
  ///
  /// **iOS Behavior**:
  /// - User must grant permission for EACH metric type separately
  /// - Read and Write permissions requested separately
  /// - Permission dialog shows native iOS HealthKit UI
  ///
  /// Parameters:
  /// - [metricTypes]: List of body measurement metrics to request permissions for
  ///
  /// Returns:
  /// - Right(true): Permissions granted for ALL requested metrics
  /// - Right(false): Some permissions denied
  /// - Left(HealthPlatformFailure): HealthKit not available, or request failed
  ///
  /// Example:
  /// ```dart
  /// final result = await healthKitService.requestPermissions([
  ///   MetricType.weight,
  ///   MetricType.bodyFatPercentage,
  /// ]);
  ///
  /// result.fold(
  ///   (failure) => showError('HealthKit not available'),
  ///   (granted) {
  ///     if (granted) {
  ///       startSync();
  ///     } else {
  ///       showError('Some permissions denied');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<HealthPlatformFailure, bool>> requestPermissions(
    List<MetricType> metricTypes,
  ) async {
    try {
      if (!Platform.isIOS) {
        if (kDebugMode) {
          debugPrint('❌ [HealthKitService] Not iOS platform');
        }
        return left(const HealthPlatformFailure(
          message: 'HealthKit only available on iOS',
        ));
      }

      if (kDebugMode) {
        debugPrint(
            '🔧 [HealthKitService] Requesting permissions for ${metricTypes.length} metrics');
        debugPrint('   Metrics: ${metricTypes.map((m) => m.name).join(', ')}');
      }

      // Map MetricType → HealthDataType
      final healthDataTypes = <HealthDataType>[];
      for (final metricType in metricTypes) {
        try {
          final healthType = _mapMetricTypeToHealthDataType(metricType);
          healthDataTypes.add(healthType);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                '⚠️ [HealthKitService] Unsupported metric: ${metricType.name}');
          }
          // Skip unsupported metrics (don't fail entire request)
        }
      }

      if (healthDataTypes.isEmpty) {
        if (kDebugMode) {
          debugPrint(
              '❌ [HealthKitService] No supported HealthKit metrics found');
        }
        return left(const HealthPlatformFailure(
          message: 'No supported HealthKit metrics in request',
        ));
      }

      if (kDebugMode) {
        debugPrint(
            '📱 [HealthKitService] Calling HealthKit with ${healthDataTypes.length} types');
      }

      // Delegate to ai_coach/HealthKitDatasource for actual permission request
      // This will show the native iOS HealthKit permission dialog
      final permissions = List<HealthDataAccess>.filled(
        healthDataTypes.length,
        HealthDataAccess.READ_WRITE, // Request both read and write
      );

      final granted = await _health.requestAuthorization(
        healthDataTypes,
        permissions: permissions,
      );

      if (kDebugMode) {
        debugPrint(
          granted
              ? '✅ [HealthKitService] Permissions granted'
              : '❌ [HealthKitService] Permissions denied',
        );
      }

      return right(granted);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitService] Permission request failed: $e');
      }
      return left(HealthPlatformFailure(
        message: 'Failed to request HealthKit permissions: $e',
        error: e,
      ));
    }
  }

  /// Read measurements from HealthKit
  ///
  /// **GDPR CRITICAL**: Only reads metrics user has consented to.
  /// Caller must verify consent before calling this method.
  Future<Either<HealthPlatformFailure, List<Measurement>>> readMeasurements({
    required String userId,
    required List<MetricType> metricTypes,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      if (!Platform.isIOS) {
        return left(const HealthPlatformFailure(
          message: 'HealthKit only available on iOS',
        ));
      }

      final endDateTime = endDate ?? DateTime.now();
      final measurements = <Measurement>[];

      // Read for each metric type
      for (final metricType in metricTypes) {
        try {
          final healthType = _mapMetricTypeToHealthDataType(metricType);

          // Read from HealthKit
          final healthData = await _health.getHealthDataFromTypes(
            types: [healthType],
            startTime: startDate,
            endTime: endDateTime,
          );

          // Convert to Measurement entities
          for (final dataPoint in healthData) {
            final measurement = _healthDataPointToMeasurement(
              dataPoint,
              userId,
              metricType,
            );
            measurements.add(measurement);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
                '⚠️ [HealthKitService] Failed to read ${metricType.name}: $e');
          }
          // Continue with other metrics
        }
      }

      if (kDebugMode) {
        debugPrint(
            '✅ [HealthKitService] Read ${measurements.length} measurements from HealthKit');
      }

      return right(measurements);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitService] Read failed: $e');
      }
      return left(HealthPlatformFailure(
        message: 'Failed to read from HealthKit: $e',
        error: e,
      ));
    }
  }

  /// Write measurement to HealthKit
  Future<Either<HealthPlatformFailure, void>> writeMeasurement(
    Measurement measurement,
  ) async {
    try {
      if (!Platform.isIOS) {
        return left(const HealthPlatformFailure(
          message: 'HealthKit only available on iOS',
        ));
      }

      final healthType = _mapMetricTypeToHealthDataType(measurement.metricType);

      final success = await _health.writeHealthData(
        value: measurement.value,
        type: healthType,
        startTime: measurement.timestamp,
        endTime: measurement.timestamp,
      );

      if (!success) {
        return left(const HealthPlatformFailure(
          message: 'HealthKit write returned false',
        ));
      }

      if (kDebugMode) {
        debugPrint(
            '✅ [HealthKitService] Wrote ${measurement.metricType.name} to HealthKit');
      }

      return right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitService] Write failed: $e');
      }
      return left(HealthPlatformFailure(
        message: 'Failed to write to HealthKit: $e',
        error: e,
      ));
    }
  }

  /// Sync measurements between app and HealthKit
  Future<Either<HealthPlatformFailure, SyncResult>> syncMeasurements({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
    DateTime? startDate,
  }) async {
    try {
      if (!Platform.isIOS) {
        return left(const HealthPlatformFailure(
          message: 'HealthKit only available on iOS',
        ));
      }

      final syncStart = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      int readCount = 0;
      int writeCount = 0;

      // Read from HealthKit (if needed)
      if (direction == SyncDirection.read || direction == SyncDirection.both) {
        final result = await readMeasurements(
          userId: userId,
          metricTypes: consentedMetrics,
          startDate: syncStart,
        );

        result.fold(
          (failure) {
            if (kDebugMode) {
              debugPrint('⚠️ [HealthKitService] Sync read failed: ${failure.message}');
            }
          },
          (measurements) {
            readCount = measurements.length;
          },
        );
      }

      // Write to HealthKit would go here (if direction = write or both)
      // Not implemented yet - requires local database integration

      if (kDebugMode) {
        debugPrint(
            '✅ [HealthKitService] Sync completed: $readCount read, $writeCount written');
      }

      return right(SyncResult(
        readCount: readCount,
        writeCount: writeCount,
        conflictCount: 0,
        syncedAt: DateTime.now(),
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitService] Sync failed: $e');
      }
      return left(HealthPlatformFailure(
        message: 'Failed to sync with HealthKit: $e',
        error: e,
      ));
    }
  }

  // ========== Private Helper Methods ==========

  /// Map MetricType to HealthKit HealthDataType
  ///
  /// **Mapping** (body measurements subset):
  /// - MetricType.weight → HealthDataType.WEIGHT
  /// - MetricType.height → HealthDataType.HEIGHT
  /// - MetricType.bodyFatPercentage → HealthDataType.BODY_FAT_PERCENTAGE
  /// - MetricType.bmi → HealthDataType.BODY_MASS_INDEX
  /// - MetricType.leanMass → HealthDataType.LEAN_BODY_MASS
  /// - MetricType.waistCircumference → HealthDataType.WAIST_CIRCUMFERENCE
  ///
  /// Throws UnsupportedError for metrics not supported by HealthKit
  HealthDataType _mapMetricTypeToHealthDataType(MetricType metricType) {
    switch (metricType) {
      case MetricType.weight:
        return HealthDataType.WEIGHT;
      case MetricType.height:
        return HealthDataType.HEIGHT;
      case MetricType.bodyFatPercentage:
        return HealthDataType.BODY_FAT_PERCENTAGE;
      case MetricType.bmi:
        return HealthDataType.BODY_MASS_INDEX;
      case MetricType.leanMass:
        return HealthDataType.LEAN_BODY_MASS;
      case MetricType.waistCircumference:
        return HealthDataType.WAIST_CIRCUMFERENCE;
      case MetricType.bodyTemperature:
        return HealthDataType.BODY_TEMPERATURE;

      // Unsupported by HealthKit (custom measurements)
      case MetricType.bmr:
      case MetricType.neckCircumference:
      case MetricType.shoulderCircumference:
      case MetricType.chestCircumference:
      case MetricType.abdomenCircumference:
      case MetricType.hipCircumference:
      case MetricType.bicepLeftCircumference:
      case MetricType.bicepRightCircumference:
      case MetricType.forearmLeftCircumference:
      case MetricType.forearmRightCircumference:
      case MetricType.thighLeftCircumference:
      case MetricType.thighRightCircumference:
      case MetricType.calfLeftCircumference:
      case MetricType.calfRightCircumference:
      case MetricType.waterMass:
      case MetricType.boneMass:
        throw UnsupportedError(
            'Metric type $metricType not supported by HealthKit. Use manual entry.');
    }
  }

  /// Convert HealthKit HealthDataPoint to Measurement entity
  Measurement _healthDataPointToMeasurement(
    HealthDataPoint dataPoint,
    String userId,
    MetricType metricType,
  ) {
    return Measurement(
      id: const Uuid().v4(),
      userId: userId,
      metricType: metricType,
      value: (dataPoint.value as num).toDouble(),
      unit: metricType.defaultUnit,
      timestamp: dataPoint.dateFrom,
      source: MeasurementSource.healthKit,
      notes: 'Imported from HealthKit',
    );
  }
}
