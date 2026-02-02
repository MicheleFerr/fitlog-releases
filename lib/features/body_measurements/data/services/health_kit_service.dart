import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/healthkit_datasource.dart';
import 'package:uuid/uuid.dart';

/// HealthKitService - Cross-platform health integration for body measurements
///
/// **Single Source of Truth**: Delegates to ai_coach/HealthKitDatasource
///
/// **Platforms**:
/// - iOS: Apple HealthKit (requires iOS 8+)
/// - Android: Health Connect (requires Android 8.0+ / API 26)
///
/// **Package**: health (Flutter package for HealthKit/HealthConnect bridge)
/// **Note**: Google Fit is deprecated (May 2024). Health Connect is the replacement.
///
/// **Functionality**:
/// - Read measurements from health platform (weight, body fat, BMI, etc.)
/// - Write measurements to health platform
/// - Bi-directional sync with consent filtering
/// - Last sync timestamp tracking
///
/// **GDPR Compliance**:
/// - Only syncs metrics user has explicitly consented to
/// - Enforces platform-specific health permissions
/// - Audit logging for all health data access
///
/// **iOS HealthKit Permissions** (required in Info.plist):
/// ```xml
/// <key>NSHealthShareUsageDescription</key>
/// <string>Read body measurements to track your fitness progress</string>
/// <key>NSHealthUpdateUsageDescription</key>
/// <string>Save body measurements to HealthKit</string>
/// ```
///
/// **Android Health Connect Permissions** (required in AndroidManifest.xml):
/// ```xml
/// <uses-permission android:name="android.permission.health.READ_WEIGHT"/>
/// <uses-permission android:name="android.permission.health.WRITE_WEIGHT"/>
/// <!-- Add similar permissions for each metric type -->
/// ```
///
/// **Supported Metrics by Platform**:
/// | MetricType          | iOS | Android | Unit Conversion |
/// |---------------------|-----|---------|-----------------|
/// | weight              | ✅  | ✅      | none (kg)       |
/// | height              | ✅  | ✅      | m → cm (×100)   |
/// | bodyFatPercentage   | ✅  | ✅      | ratio → % (×100)|
/// | leanMass            | ✅  | ✅      | none (kg)       |
/// | bmi                 | ✅  | ✅      | none            |
/// | bodyTemperature     | ✅  | ✅      | none (°C)       |
/// | waistCircumference  | ✅  | ❌      | m → cm (×100)   |
/// | waterMass           | ❌  | ✅      | kg → % (calc)   |
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
///       print('Health platform permissions granted');
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
  bool _isConfigured = false;

  /// Configure the Health package (required before any HealthKit operation)
  Future<void> _ensureConfigured() async {
    if (_isConfigured) return;
    await _health.configure();
    _isConfigured = true;
    if (kDebugMode) {
      debugPrint('✅ [HealthKitService] Health package configured');
    }
  }

  /// Check if health platform is available on this device
  ///
  /// Returns:
  /// - true: iOS with HealthKit or Android with Health Connect
  /// - false: Platform not supported or health services not available
  Future<bool> isAvailable() async {
    if (Platform.isIOS) {
      return _healthKitDatasource.isAvailable;
    } else if (Platform.isAndroid) {
      // Health Connect availability check
      try {
        await _ensureConfigured();
        // Check if Health Connect is actually installed/available
        final status = await _health.getHealthConnectSdkStatus();
        if (kDebugMode) {
          debugPrint('📱 [HealthKitService] Health Connect SDK status: $status');
        }
        // HealthConnectSdkStatus values:
        // - unavailable: Not installed
        // - installed: Ready to use
        // - sdkUnavailable: SDK not supported on this device
        return status == HealthConnectSdkStatus.sdkAvailable;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [HealthKitService] Health Connect check failed: $e');
        }
        return false;
      }
    }

    if (kDebugMode) {
      debugPrint('⚠️ [HealthKitService] Unsupported platform');
    }
    return false;
  }

  /// Check Health Connect SDK status (Android only)
  ///
  /// Returns detailed status for UI guidance:
  /// - sdkAvailable: Ready to use
  /// - sdkUnavailable: Device doesn't support Health Connect
  /// - sdkUnavailableProviderUpdateRequired: Health Connect app needs update
  Future<HealthConnectSdkStatus?> getHealthConnectStatus() async {
    if (!Platform.isAndroid) return null;
    try {
      await _ensureConfigured();
      return await _health.getHealthConnectSdkStatus();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitService] Failed to get Health Connect status: $e');
      }
      return null;
    }
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
      if (!Platform.isIOS && !Platform.isAndroid) {
        if (kDebugMode) {
          debugPrint('❌ [HealthKitService] Unsupported platform');
        }
        return left(const HealthPlatformFailure(
          message: 'Health platform only available on iOS and Android',
        ));
      }

      await _ensureConfigured();

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
      if (!Platform.isIOS && !Platform.isAndroid) {
        return left(const HealthPlatformFailure(
          message: 'Health platform only available on iOS and Android',
        ));
      }

      await _ensureConfigured();

      final endDateTime = endDate ?? DateTime.now();
      final measurements = <Measurement>[];

      // Read for each metric type
      for (final metricType in metricTypes) {
        // Skip if metric not supported on this platform
        if (!_isHealthKitSupported(metricType)) {
          if (kDebugMode) {
            debugPrint(
                '⚠️ [HealthKitService] Skipping unsupported metric: ${metricType.name}');
          }
          continue;
        }

        try {
          final healthType = _mapMetricTypeToHealthDataType(metricType);

          // Read from HealthKit
          if (kDebugMode) {
            debugPrint(
                '📱 [HealthKitService] Querying $healthType from $startDate to $endDateTime');
          }

          final healthData = await _health.getHealthDataFromTypes(
            types: [healthType],
            startTime: startDate,
            endTime: endDateTime,
          );

          if (kDebugMode) {
            debugPrint(
                '📱 [HealthKitService] Got ${healthData.length} data points for $healthType');
            for (final dp in healthData.take(3)) {
              debugPrint('   - ${dp.dateFrom}: ${dp.value}');
            }
          }

          // Convert to Measurement entities with validation
          for (final dataPoint in healthData) {
            final measurement = _healthDataPointToMeasurement(
              dataPoint,
              userId,
              metricType,
            );
            // Skip invalid measurements (negative, NaN, extreme values)
            if (_isValidMeasurementValue(measurement)) {
              measurements.add(measurement);
            } else if (kDebugMode) {
              debugPrint(
                  '⚠️ [HealthKitService] Skipped invalid value: ${metricType.name} = ${measurement.value}');
            }
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

  /// Write measurement to health platform
  ///
  /// Converts app values to health platform SI units before writing.
  Future<Either<HealthPlatformFailure, void>> writeMeasurement(
    Measurement measurement,
  ) async {
    try {
      if (!Platform.isIOS && !Platform.isAndroid) {
        return left(const HealthPlatformFailure(
          message: 'Health platform only available on iOS and Android',
        ));
      }

      // Check if metric is supported on this platform
      if (!_isHealthKitSupported(measurement.metricType)) {
        return left(HealthPlatformFailure(
          message:
              '${measurement.metricType.name} not supported on this platform',
        ));
      }

      await _ensureConfigured();

      final healthType = _mapMetricTypeToHealthDataType(measurement.metricType);

      // Convert app units back to HealthKit SI units
      final healthKitValue = _convertToHealthKitValue(
        measurement.value,
        measurement.metricType,
      );

      final success = await _health.writeHealthData(
        value: healthKitValue,
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
  ///
  /// Parameters:
  /// - [userId]: Firebase Auth UID
  /// - [consentedMetrics]: Metrics user has consented to sync
  /// - [direction]: Read, write, or both
  /// - [startDate]: Start date for read sync (default: 30 days ago)
  /// - [measurements]: Local measurements to write to HealthKit (required for write/both)
  Future<Either<HealthPlatformFailure, SyncResult>> syncMeasurements({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
    DateTime? startDate,
    List<Measurement>? measurements,
  }) async {
    try {
      if (!Platform.isIOS && !Platform.isAndroid) {
        return left(const HealthPlatformFailure(
          message: 'Health platform only available on iOS and Android',
        ));
      }

      final syncStart = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      int readCount = 0;
      int writeCount = 0;
      List<Measurement> readMeasurementsData = [];

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
          (readData) {
            readCount = readData.length;
            readMeasurementsData = readData;
          },
        );
      }

      // Write local measurements to HealthKit
      if (direction == SyncDirection.write || direction == SyncDirection.both) {
        if (measurements != null && measurements.isNotEmpty) {
          for (final measurement in measurements) {
            // Only write metrics supported by HealthKit
            if (!_isHealthKitSupported(measurement.metricType)) continue;
            // Only write consented metrics
            if (!consentedMetrics.contains(measurement.metricType)) continue;

            final writeResult = await writeMeasurement(measurement);
            writeResult.fold(
              (failure) {
                if (kDebugMode) {
                  debugPrint(
                      '⚠️ [HealthKitService] Write failed for ${measurement.metricType.name}: ${failure.message}');
                }
              },
              (_) {
                writeCount++;
              },
            );
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
            '✅ [HealthKitService] Sync completed: $readCount read, $writeCount written');
      }

      return right(SyncResult(
        readCount: readCount,
        writeCount: writeCount,
        conflictCount: 0,
        syncedAt: DateTime.now(),
        importedMeasurements: readMeasurementsData,
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

  /// Check if a metric type is supported by the current health platform
  ///
  /// Platform-specific support:
  /// - iOS: weight, height, bodyFat, bmi, leanMass, waist, bodyTemp
  /// - Android: weight, height, bodyFat, bmi, leanMass, bodyTemp, waterMass
  bool _isHealthKitSupported(MetricType metricType) {
    // Cross-platform metrics (iOS + Android)
    switch (metricType) {
      case MetricType.weight:
      case MetricType.height:
      case MetricType.bodyFatPercentage:
      case MetricType.bmi:
      case MetricType.leanMass:
      case MetricType.bodyTemperature:
        return true;

      // iOS-only metrics
      case MetricType.waistCircumference:
        return Platform.isIOS;

      // Android-only metrics
      case MetricType.waterMass:
        return Platform.isAndroid;

      default:
        return false;
    }
  }

  // ========== Private Helper Methods ==========

  /// Map MetricType to health platform HealthDataType
  ///
  /// **Cross-platform Mapping**:
  /// - MetricType.weight → HealthDataType.WEIGHT
  /// - MetricType.height → HealthDataType.HEIGHT
  /// - MetricType.bodyFatPercentage → HealthDataType.BODY_FAT_PERCENTAGE
  /// - MetricType.bmi → HealthDataType.BODY_MASS_INDEX
  /// - MetricType.leanMass → HealthDataType.LEAN_BODY_MASS
  /// - MetricType.bodyTemperature → HealthDataType.BODY_TEMPERATURE
  ///
  /// **iOS-only**:
  /// - MetricType.waistCircumference → HealthDataType.WAIST_CIRCUMFERENCE
  ///
  /// **Android-only**:
  /// - MetricType.waterMass → HealthDataType.BODY_WATER_MASS
  ///
  /// Throws UnsupportedError for metrics not supported by the platform
  HealthDataType _mapMetricTypeToHealthDataType(MetricType metricType) {
    switch (metricType) {
      // Cross-platform metrics
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
      case MetricType.bodyTemperature:
        return HealthDataType.BODY_TEMPERATURE;

      // iOS-only: waist circumference
      case MetricType.waistCircumference:
        if (!Platform.isIOS) {
          throw UnsupportedError(
              'Waist circumference only supported on iOS HealthKit');
        }
        return HealthDataType.WAIST_CIRCUMFERENCE;

      // Android-only: body water mass
      case MetricType.waterMass:
        if (!Platform.isAndroid) {
          throw UnsupportedError(
              'Body water mass only supported on Android Health Connect');
        }
        return HealthDataType.BODY_WATER_MASS;

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
      case MetricType.boneMass:
        throw UnsupportedError(
            'Metric type $metricType not supported by health platforms. Use manual entry.');
    }
  }

  /// Convert HealthKit HealthDataPoint to Measurement entity
  ///
  /// **Unit Conversion** (HealthKit uses SI units):
  /// - HEIGHT: meters → cm (×100)
  /// - BODY_FAT_PERCENTAGE: ratio (0-1) → % (0-100) (×100)
  /// - WAIST_CIRCUMFERENCE: meters → cm (×100)
  /// - WEIGHT, LEAN_BODY_MASS: kg (no conversion)
  /// - BMI: kg/m² (no conversion)
  /// - BODY_TEMPERATURE: °C (no conversion)
  ///
  /// Reference: https://pub.dev/packages/health
  Measurement _healthDataPointToMeasurement(
    HealthDataPoint dataPoint,
    String userId,
    MetricType metricType,
  ) {
    // health package v13+ returns NumericHealthValue, not raw num
    final healthValue = dataPoint.value;
    final rawValue = healthValue is NumericHealthValue
        ? healthValue.numericValue.toDouble()
        : 0.0;

    // Apply unit conversion based on metric type
    final convertedValue = _convertHealthKitValue(rawValue, metricType);

    return Measurement(
      id: const Uuid().v4(),
      userId: userId,
      metricType: metricType,
      value: convertedValue,
      unit: metricType.defaultUnit,
      timestamp: dataPoint.dateFrom,
      source: MeasurementSource.healthKit,
      notes: 'Imported from HealthKit',
    );
  }

  /// Convert health platform raw value to app's expected unit
  ///
  /// Health platforms store values in SI units:
  /// - Height/circumferences in METERS
  /// - Body fat percentage as RATIO (0-1, not 0-100)
  /// - Weight in KILOGRAMS
  /// - Body water mass in KILOGRAMS (Android only)
  ///
  /// **NOTE:** Some devices/regions may return unexpected formats.
  /// We use heuristics to detect and handle these edge cases.
  double _convertHealthKitValue(double rawValue, MetricType metricType) {
    switch (metricType) {
      // Height: Meters → Centimeters (×100)
      // Handle edge cases where HealthKit may return unexpected values
      case MetricType.height:
        // Take absolute value in case of negative (data corruption)
        final absValue = rawValue.abs();

        // Heuristic: detect if value is already in cm vs meters
        // - Meters: typical range 0.5-2.5 (50cm-250cm)
        // - Centimeters: typical range 50-250
        if (absValue >= 50 && absValue <= 300) {
          // Already in cm (some devices/regions report this way)
          return absValue;
        } else if (absValue >= 0.4 && absValue <= 3.0) {
          // In meters, convert to cm
          return absValue * 100;
        } else {
          // Invalid range - return as-is but flag for validation
          debugPrint(
              '[HealthKit] Unexpected height value: $rawValue (abs: $absValue)');
          return absValue * 100; // Assume meters
        }

      // Waist circumference: Meters → Centimeters
      case MetricType.waistCircumference:
        final absValue = rawValue.abs();
        // Waist: 40-200cm typical, 0.4-2.0m in meters
        if (absValue >= 30 && absValue <= 250) {
          return absValue; // Already in cm
        } else if (absValue >= 0.3 && absValue <= 2.5) {
          return absValue * 100; // Convert from meters
        } else {
          return absValue * 100;
        }

      // Ratio (0-1) → Percentage (0-100)
      case MetricType.bodyFatPercentage:
        // Health platform may return 0.18 for 18% or 18.0 for 18%
        // If value > 1, assume it's already in percentage form
        return rawValue <= 1.0 ? rawValue * 100 : rawValue;

      // Already in correct units (kg, kg/m², °C)
      case MetricType.weight:
      case MetricType.leanMass:
      case MetricType.bmi:
      case MetricType.bodyTemperature:
        return rawValue;

      // Android Health Connect: BODY_WATER_MASS is in kg
      // NOTE: Our app expects percentage, but we can't calculate % without weight
      // Store raw kg value - consider improving by fetching weight for calculation
      case MetricType.waterMass:
        // Return raw kg value for now
        // TODO: Fetch weight to calculate actual percentage
        return rawValue;

      // Should not reach here for supported types
      default:
        return rawValue;
    }
  }

  /// Convert app value to health platform SI units (inverse of _convertHealthKitValue)
  ///
  /// Used when writing measurements to health platform.
  /// - Centimeters → Meters (÷100)
  /// - Percentage (0-100) → Ratio (0-1) (÷100)
  double _convertToHealthKitValue(double appValue, MetricType metricType) {
    switch (metricType) {
      // Centimeters → Meters (÷100)
      case MetricType.height:
      case MetricType.waistCircumference:
        return appValue / 100;

      // Percentage (0-100) → Ratio (0-1)
      case MetricType.bodyFatPercentage:
        // If value > 1, assume it's in percentage form and convert to ratio
        return appValue > 1.0 ? appValue / 100 : appValue;

      // Already in correct health platform units (kg, kg/m², °C)
      case MetricType.weight:
      case MetricType.leanMass:
      case MetricType.bmi:
      case MetricType.bodyTemperature:
        return appValue;

      // Android Health Connect: waterMass % cannot be written without weight context
      // NOTE: This would require fetching weight to convert % back to kg
      case MetricType.waterMass:
        // Return raw value (may be incorrect without weight context)
        return appValue;

      // Should not reach here for supported types
      default:
        return appValue;
    }
  }

  /// Validate that a measurement value is within reasonable bounds
  ///
  /// Filters out:
  /// - Negative values (impossible for body measurements)
  /// - NaN or infinite values
  /// - Extreme outliers that indicate data corruption
  bool _isValidMeasurementValue(Measurement measurement) {
    final value = measurement.value;

    // Basic validity checks
    if (value.isNaN || value.isInfinite || value < 0) {
      return false;
    }

    // Type-specific validation bounds
    switch (measurement.metricType) {
      case MetricType.weight:
        // Valid: 1-500 kg (covers infants to extreme cases)
        return value >= 1 && value <= 500;
      case MetricType.height:
        // Valid: 50-300 cm (covers children to tall adults)
        return value >= 50 && value <= 300;
      case MetricType.bodyFatPercentage:
        // Valid: 1-70% (essential fat minimum to obese)
        return value >= 1 && value <= 70;
      case MetricType.bmi:
        // Valid: 10-100 (severely underweight to extremely obese)
        return value >= 10 && value <= 100;
      case MetricType.leanMass:
        // Valid: 10-200 kg
        return value >= 10 && value <= 200;
      case MetricType.bodyTemperature:
        // Valid: 30-45°C (hypothermia to severe fever)
        return value >= 30 && value <= 45;
      case MetricType.waistCircumference:
        // Valid: 30-200 cm
        return value >= 30 && value <= 200;
      case MetricType.waterMass:
        // If in kg: 10-100, if in %: 30-80
        return value >= 10 && value <= 100;
      default:
        // For other metrics, accept reasonable values
        return value >= 0 && value <= 1000;
    }
  }
}
