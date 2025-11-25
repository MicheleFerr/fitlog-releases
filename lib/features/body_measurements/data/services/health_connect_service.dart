import 'dart:io' show Platform;
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';

/// HealthConnectService - Android Health Connect integration
///
/// **Platform**: Android only (requires Android 14+ or Android 7+ with Google Play Services)
/// **Framework**: Health Connect (Android native)
/// **Package**: health (Flutter package for HealthKit/HealthConnect bridge)
///
/// **Health Connect Overview**:
/// - Centralized health data repository on Android
/// - Unified API for fitness apps, wearables, health trackers
/// - User controls permissions per app, per data type
/// - Data stored encrypted on device
///
/// **Functionality**:
/// - Read measurements from Health Connect (weight, body fat, BMI, etc.)
/// - Write measurements to Health Connect
/// - Bi-directional sync with consent filtering
/// - Last sync timestamp tracking
///
/// **GDPR Compliance**:
/// - Only syncs metrics user has explicitly consented to (in-app consent)
/// - Enforces Android Health Connect permissions separately
/// - Audit logging for all Health Connect access (TODO: Task 2.9)
///
/// **Android Permissions** (required in AndroidManifest.xml):
/// ```xml
/// <!-- Health Connect permissions (Android 14+) -->
/// <uses-permission android:name="android.permission.health.READ_WEIGHT"/>
/// <uses-permission android:name="android.permission.health.WRITE_WEIGHT"/>
/// <uses-permission android:name="android.permission.health.READ_BODY_FAT"/>
/// <uses-permission android:name="android.permission.health.WRITE_BODY_FAT"/>
/// <!-- Add more as needed -->
///
/// <!-- Query Health Connect app availability -->
/// <queries>
///   <package android:name="com.google.android.apps.healthdata"/>
/// </queries>
/// ```
///
/// **Supported Metrics** (Health Connect → MetricType mapping):
/// - WeightRecord → MetricType.weight
/// - BodyFatRecord → MetricType.bodyFatPercentage
/// - LeanBodyMassRecord → MetricType.leanBodyMass
/// - BoneMassRecord → MetricType.boneMass
/// - (Add more mappings as needed)
///
/// **Installation Check**:
/// Health Connect is a separate app that must be installed:
/// - Android 14+: Built-in system app
/// - Android 7-13: Downloadable from Google Play Store
/// - App prompts user to install if missing
///
/// **Usage**:
/// ```dart
/// final healthConnectService = HealthConnectService();
///
/// // Check if Health Connect is installed
/// final isAvailable = await healthConnectService.isAvailable();
///
/// // Request permissions for specific metrics
/// final granted = await healthConnectService.requestPermissions([
///   MetricType.weight,
///   MetricType.bodyFatPercentage,
/// ]);
///
/// // Read measurements from Health Connect
/// final result = await healthConnectService.readMeasurements(
///   userId: 'user-123',
///   metricTypes: [MetricType.weight],
///   startDate: DateTime.now().subtract(Duration(days: 30)),
/// );
///
/// // Write measurement to Health Connect
/// final writeResult = await healthConnectService.writeMeasurement(
///   measurement: measurement,
/// );
/// ```
///
/// **Error Handling**:
/// - Platform not Android → HealthPlatformFailure
/// - Health Connect not installed → HealthPlatformFailure (with install prompt)
/// - Permissions denied → HealthPlatformFailure
/// - Sync errors → HealthPlatformFailure
class HealthConnectService {
  /// Check if Health Connect is available on this device
  ///
  /// Returns:
  /// - true: Android device with Health Connect installed
  /// - false: Not Android, or Health Connect not installed
  ///
  /// **Installation**:
  /// - Android 14+: Health Connect is built-in (always available)
  /// - Android 7-13: User must install from Google Play Store
  ///
  /// Example:
  /// ```dart
  /// final available = await healthConnectService.isAvailable();
  /// if (!available) {
  ///   // Prompt user to install Health Connect
  ///   showDialog(
  ///     title: 'Install Health Connect',
  ///     message: 'Health Connect is required to sync health data',
  ///     actions: [
  ///       TextButton(
  ///         onPressed: () => openPlayStore('com.google.android.apps.healthdata'),
  ///         child: Text('Install'),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  Future<bool> isAvailable() async {
    // Check platform
    if (!Platform.isAndroid) {
      return false;
    }

    // TODO: Check if Health Connect is installed
    // Use health package: await Health().isHealthDataAvailable()
    // On Android, this checks for Health Connect app installation

    // For now, assume available on all Android devices (Android 14+)
    return true;
  }

  /// Request Health Connect permissions for specific metric types
  ///
  /// **Android Behavior**:
  /// - User must grant permission for EACH metric type separately
  /// - Read and Write permissions requested separately
  /// - Permission dialog shows native Android Health Connect UI
  /// - Permissions can be revoked anytime via Health Connect settings
  ///
  /// Parameters:
  /// - [metricTypes]: List of metrics to request permissions for
  ///
  /// Returns:
  /// - Right(true): Permissions granted for ALL requested metrics
  /// - Right(false): Some permissions denied
  /// - Left(HealthPlatformFailure): Health Connect not available, or request failed
  ///
  /// Example:
  /// ```dart
  /// final result = await healthConnectService.requestPermissions([
  ///   MetricType.weight,
  ///   MetricType.bodyFatPercentage,
  /// ]);
  ///
  /// result.fold(
  ///   (failure) => showError('Health Connect not available'),
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
      // Check platform
      if (!Platform.isAndroid) {
        return left(const HealthPlatformFailure(
          message: 'Health Connect only available on Android',
        ));
      }

      // Check if Health Connect available
      final available = await isAvailable();
      if (!available) {
        return left(const HealthPlatformFailure(
          message: 'Health Connect not installed. Please install from Google Play Store.',
        ));
      }

      // TODO: Implement actual permission request using health package
      // Example:
      // final types = metricTypes.map(_mapMetricTypeToHealthDataType).toList();
      // final granted = await Health().requestAuthorization(types);
      // return right(granted);

      // For now, simulate permission request (PLACEHOLDER)
      // In production, this MUST call actual Health Connect permission API
      await Future.delayed(const Duration(milliseconds: 100));

      // Simulated: Assume permissions granted
      return right(true);
    } catch (e) {
      return left(HealthPlatformFailure(
        message: 'Failed to request Health Connect permissions: $e',
        error: e,
      ));
    }
  }

  /// Read measurements from Health Connect
  ///
  /// **GDPR CRITICAL**: Only reads metrics user has consented to.
  /// Caller must verify consent before calling this method.
  ///
  /// Parameters:
  /// - [userId]: User ID (for creating Measurement objects)
  /// - [metricTypes]: List of metrics to read (must have consent)
  /// - [startDate]: Read measurements from this date onwards
  /// - [endDate]: Read measurements up to this date (default: now)
  ///
  /// Returns:
  /// - Right(List<Measurement>): Measurements read from Health Connect (may be empty)
  /// - Left(HealthPlatformFailure): Health Connect error, permissions denied, or platform not Android
  ///
  /// **Data Sources**:
  /// Health Connect aggregates data from multiple sources:
  /// - Google Fit
  /// - Samsung Health
  /// - Fitbit
  /// - Garmin Connect
  /// - etc.
  ///
  /// Example:
  /// ```dart
  /// // User has consented to weight tracking
  /// final result = await healthConnectService.readMeasurements(
  ///   userId: currentUser.uid,
  ///   metricTypes: [MetricType.weight],
  ///   startDate: DateTime.now().subtract(Duration(days: 30)),
  /// );
  ///
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (measurements) {
  ///     print('Read ${measurements.length} weight measurements from Health Connect');
  ///     // Save to local database
  ///     for (final m in measurements) {
  ///       await measurementRepo.addMeasurement(m, hasConsent: true);
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<HealthPlatformFailure, List<Measurement>>> readMeasurements({
    required String userId,
    required List<MetricType> metricTypes,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      // Check platform
      if (!Platform.isAndroid) {
        return left(const HealthPlatformFailure(
          message: 'Health Connect only available on Android',
        ));
      }

      final endDateTime = endDate ?? DateTime.now();

      final measurements = <Measurement>[];

      // TODO: Implement actual Health Connect data read
      // For each metric type:
      // 1. Map MetricType to HealthDataType (using _mapMetricTypeToHealthDataType)
      // 2. Read data from Health Connect using health package:
      //    final healthData = await Health().getHealthDataFromTypes(
      //      startDate,
      //      endDateTime,
      //      [healthDataType],
      //    );
      // 3. Convert HealthDataPoint → Measurement (using _healthDataPointToMeasurement)
      // 4. Add to measurements list

      // PLACEHOLDER implementation (returns empty list)
      // In production, this MUST call actual Health Connect read API

      return right(measurements);
    } catch (e) {
      return left(HealthPlatformFailure(
        message: 'Failed to read from Health Connect: $e',
        error: e,
      ));
    }
  }

  /// Write measurement to Health Connect
  ///
  /// Parameters:
  /// - [measurement]: Measurement to write to Health Connect
  ///
  /// Returns:
  /// - Right(void): Successfully written to Health Connect
  /// - Left(HealthPlatformFailure): Health Connect error, permissions denied, or platform not Android
  ///
  /// **Data Sharing**:
  /// Once written to Health Connect, data becomes available to:
  /// - Other health apps user has granted permissions to
  /// - Google Fit (if user has enabled sync)
  /// - Wearables and fitness trackers
  ///
  /// Example:
  /// ```dart
  /// final result = await healthConnectService.writeMeasurement(
  ///   measurement: weightMeasurement,
  /// );
  ///
  /// result.fold(
  ///   (failure) => showError('Failed to write to Health Connect'),
  ///   (_) => showSuccess('Saved to Health Connect'),
  /// );
  /// ```
  Future<Either<HealthPlatformFailure, void>> writeMeasurement(
    Measurement measurement,
  ) async {
    try {
      // Check platform
      if (!Platform.isAndroid) {
        return left(const HealthPlatformFailure(
          message: 'Health Connect only available on Android',
        ));
      }

      // TODO: Implement actual Health Connect data write
      // 1. Map MetricType to HealthDataType
      // 2. Convert Measurement → HealthDataPoint
      // 3. Write to Health Connect:
      //    final success = await Health().writeHealthData(
      //      measurement.value,
      //      healthDataType,
      //      measurement.timestamp,
      //      measurement.timestamp,
      //    );
      // 4. Return result

      // PLACEHOLDER implementation
      // In production, this MUST call actual Health Connect write API

      return right(null);
    } catch (e) {
      return left(HealthPlatformFailure(
        message: 'Failed to write to Health Connect: $e',
        error: e,
      ));
    }
  }

  /// Sync measurements between app and Health Connect
  ///
  /// **Bi-directional sync**:
  /// - Read: Import measurements from Health Connect → App database
  /// - Write: Export measurements from App database → Health Connect
  ///
  /// **GDPR CRITICAL**:
  /// - Only syncs metrics user has explicitly consented to
  /// - Caller must pass consentedMetrics from ConsentRepository
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [consentedMetrics]: Metrics user has consented to sync
  /// - [direction]: Sync direction (read, write, or both)
  /// - [startDate]: Sync measurements from this date onwards (default: last sync)
  ///
  /// Returns:
  /// - Right(SyncResult): Sync completed with counts (read, written, conflicts)
  /// - Left(HealthPlatformFailure): Sync failed
  ///
  /// Example:
  /// ```dart
  /// // Get user's consented metrics
  /// final consent = await consentRepo.getConsent(userId);
  ///
  /// // Sync with Health Connect
  /// final result = await healthConnectService.syncMeasurements(
  ///   userId: userId,
  ///   consentedMetrics: consent.consentedMetrics,
  ///   direction: SyncDirection.both,
  /// );
  ///
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (syncResult) {
  ///     print('Synced: ${syncResult.readCount} read, ${syncResult.writeCount} written');
  ///   },
  /// );
  /// ```
  Future<Either<HealthPlatformFailure, SyncResult>> syncMeasurements({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
    DateTime? startDate,
  }) async {
    try {
      // Check platform
      if (!Platform.isAndroid) {
        return left(const HealthPlatformFailure(
          message: 'Health Connect only available on Android',
        ));
      }

      // TODO: Implement actual sync logic
      // Strategy:
      // 1. Determine start date (use last sync timestamp if not provided)
      // 2. If direction = read or both:
      //    a. Read measurements from Health Connect (using readMeasurements)
      //    b. Filter by consentedMetrics
      //    c. Save to app database
      // 3. If direction = write or both:
      //    a. Get measurements from app database (since last sync)
      //    b. Filter by consentedMetrics
      //    c. Write to Health Connect (using writeMeasurement)
      // 4. Detect conflicts (same measurement modified in both places)
      // 5. Update last sync timestamp
      // 6. Return SyncResult with counts

      // PLACEHOLDER implementation
      return right(SyncResult(
        readCount: 0,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: DateTime.now(),
      ));
    } catch (e) {
      return left(HealthPlatformFailure(
        message: 'Failed to sync with Health Connect: $e',
        error: e,
      ));
    }
  }

  // ========== Private Helper Methods ==========

  /// Map MetricType to Health Connect HealthDataType
  ///
  /// **Mapping**:
  /// - MetricType.weight → HealthDataType.WEIGHT
  /// - MetricType.bodyFatPercentage → HealthDataType.BODY_FAT_PERCENTAGE
  /// - MetricType.bmi → HealthDataType.BODY_MASS_INDEX
  /// - etc.
  ///
  /// TODO: Complete mapping for all 20+ metrics
  // HealthDataType _mapMetricTypeToHealthDataType(MetricType metricType) {
  //   switch (metricType) {
  //     case MetricType.weight:
  //       return HealthDataType.WEIGHT;
  //     case MetricType.bodyFatPercentage:
  //       return HealthDataType.BODY_FAT_PERCENTAGE;
  //     case MetricType.bmi:
  //       return HealthDataType.BODY_MASS_INDEX;
  //     case MetricType.leanBodyMass:
  //       return HealthDataType.LEAN_BODY_MASS;
  //     // Add more mappings
  //     default:
  //       throw UnsupportedError('Metric type $metricType not supported in Health Connect');
  //   }
  // }

  /// Convert Health Connect HealthDataPoint to Measurement entity
  ///
  /// TODO: Implement conversion logic
  // Measurement _healthDataPointToMeasurement(
  //   HealthDataPoint dataPoint,
  //   String userId,
  // ) {
  //   return Measurement(
  //     id: Uuid().v4(),
  //     userId: userId,
  //     metricType: _healthDataTypeToMetricType(dataPoint.type),
  //     value: dataPoint.value.toDouble(),
  //     unit: _getUnitForMetricType(_healthDataTypeToMetricType(dataPoint.type)),
  //     timestamp: dataPoint.dateFrom,
  //     source: MeasurementSource.healthPlatform,
  //     notes: 'Imported from Health Connect',
  //   );
  // }

  /// Convert HealthDataType to MetricType (reverse mapping)
  ///
  /// TODO: Implement reverse mapping
  // MetricType _healthDataTypeToMetricType(HealthDataType healthDataType) {
  //   // Reverse mapping of _mapMetricTypeToHealthDataType
  //   throw UnimplementedError();
  // }

  /// Get unit string for MetricType
  ///
  /// Used when importing from Health Connect (Health Connect has own units)
  ///
  /// TODO: Implement unit mapping
  // String _getUnitForMetricType(MetricType metricType) {
  //   switch (metricType) {
  //     case MetricType.weight:
  //       return 'kg'; // Or 'lb' based on user preference
  //     case MetricType.bodyFatPercentage:
  //       return '%';
  //     case MetricType.bmi:
  //       return 'kg/m²';
  //     // Add more units
  //     default:
  //       return '';
  //   }
  // }

  /// Open Health Connect app settings
  ///
  /// Allows user to manage permissions, view connected apps, etc.
  ///
  /// TODO: Implement platform channel call to open Health Connect settings
  // Future<void> openSettings() async {
  //   if (!Platform.isAndroid) return;
  //   // Open Health Connect settings:
  //   // const intent = 'android.intent.action.HEALTH_CONNECT_SETTINGS';
  //   // await platform.invokeMethod('openHealthConnectSettings');
  // }
}
