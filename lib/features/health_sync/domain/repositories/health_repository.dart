import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';

/// Repository interface for health data synchronization operations.
///
/// Defines the contract between domain and data layers following
/// Clean Architecture principles.
///
/// Error handling: All methods return `Either<Failure, T>` from fpdart
/// - Left: Failure (network, permission, platform errors)
/// - Right: Success result
///
/// Platform abstraction: Implementation handles iOS (HealthKit) and
/// Android (Health Connect) differences transparently.
abstract class IHealthRepository {
  // ============================================================
  // PERMISSION MANAGEMENT
  // ============================================================

  /// Requests permission to access specified health data types.
  ///
  /// iOS: Sequential permission requests (workout → weight)
  /// - Shows native HealthKit permission dialog for each type
  /// - Returns granular status per data type
  ///
  /// Android: Batch permission request + Health Connect check
  /// - Checks if Health Connect is installed first
  /// - Shows Health Connect permission dialog
  /// - Returns status per data type
  ///
  /// Returns:
  /// - Right: [HealthPermissionStatus] with permission state per type
  /// - Left: [ServerFailure] if platform error occurs
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.requestPermissions(
  ///   dataTypes: [HealthDataType.workout, HealthDataType.bodyWeight],
  /// );
  ///
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (status) {
  ///     if (status.canSync(HealthDataType.workout)) {
  ///       print('Workout sync authorized');
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<Failure, HealthPermissionStatus>> requestPermissions({
    required List<HealthDataType> dataTypes,
  });

  /// Checks current permission status without requesting.
  ///
  /// **IMPORTANT**: Always checks runtime status (no cached state).
  /// This prevents stale state bugs when user revokes permissions
  /// in iOS Settings or Android Health Connect.
  ///
  /// Returns:
  /// - Right: Current [HealthPermissionStatus]
  /// - Left: [ServerFailure] if platform error
  ///
  /// Called:
  /// - On app resume (check for permission changes)
  /// - Before sync operations (verify still authorized)
  /// - When user opens Health Sync settings screen
  Future<Either<Failure, HealthPermissionStatus>> checkPermissionStatus();

  // ============================================================
  // SYNC OPERATIONS
  // ============================================================

  /// Syncs workout data from health platform to FitLog.
  ///
  /// Flow:
  /// 1. Check permission status (runtime check)
  /// 2. Fetch workouts from HealthKit/Health Connect
  /// 3. Map workout types to FitLog categories
  /// 4. Save to local Hive storage
  /// 5. Update sync status (success/error)
  ///
  /// Date range:
  /// - [startDate]: Earliest workout to fetch (e.g., 30 days ago)
  /// - [endDate]: Latest workout to fetch (e.g., today)
  ///
  /// Returns:
  /// - Right: void (success)
  /// - Left: [PermissionDeniedFailure] if not authorized
  /// - Left: [ServerFailure] if fetch/save fails
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime.now();
  /// final result = await repository.syncWorkouts(
  ///   startDate: now.subtract(Duration(days: 30)),
  ///   endDate: now,
  /// );
  /// ```
  Future<Either<Failure, void>> syncWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Syncs body weight data from health platform to FitLog.
  ///
  /// Bidirectional sync:
  /// 1. Import: Fetch weight from HealthKit/Health Connect
  /// 2. Export: Write FitLog weight to HealthKit/Health Connect
  /// 3. Conflict resolution: Newest timestamp wins
  ///
  /// Returns:
  /// - Right: void (success)
  /// - Left: [PermissionDeniedFailure] if not authorized
  /// - Left: [ServerFailure] if sync fails
  Future<Either<Failure, void>> syncBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Writes a single body weight measurement to health platform.
  ///
  /// Instant sync: Called when user manually enters weight in FitLog.
  /// Writes immediately to HealthKit/Health Connect without waiting
  /// for daily background sync.
  ///
  /// iOS: Uses HKQuantitySample for weight
  /// Android: Uses WeightRecord in Health Connect
  ///
  /// Returns:
  /// - Right: void (success)
  /// - Left: [PermissionDeniedFailure] if not authorized
  /// - Left: [ServerFailure] if write fails
  ///
  /// Example:
  /// ```dart
  /// final measurement = BodyMeasurement(
  ///   value: 75.5,
  ///   unit: MeasurementUnit.kilograms,
  ///   recordedAt: DateTime.now(),
  ///   dataType: HealthDataType.bodyWeight,
  ///   source: 'FitLog',
  /// );
  ///
  /// await repository.writeBodyWeight(measurement);
  /// ```
  Future<Either<Failure, void>> writeBodyWeight(
    BodyMeasurement measurement,
  );

  // ============================================================
  // SYNC STATUS & HISTORY
  // ============================================================

  /// Gets the last sync status for a specific health data type.
  ///
  /// Returns persisted status from Hive including:
  /// - Last sync timestamp
  /// - Sync result (success/error)
  /// - Retry count (if error)
  /// - Error message (if applicable)
  ///
  /// Returns:
  /// - Right: [HealthSyncStatus] from local storage
  /// - Left: [CacheFailure] if Hive read fails
  ///
  /// Used by UI to display:
  /// - "Last synced 2 hours ago"
  /// - "Sync failed: Network error"
  /// - Retry button (if shouldRetry() == true)
  Future<Either<Failure, HealthSyncStatus>> getLastSyncStatus(
    HealthDataType dataType,
  );

  /// Gets sync history for a specific data type (last 30 days).
  ///
  /// Returns list of [HealthSyncStatus] entries for displaying
  /// sync timeline in UI.
  ///
  /// Returns:
  /// - Right: `List<HealthSyncStatus>` (may be empty)
  /// - Left: [CacheFailure] if Hive read fails
  Future<Either<Failure, List<HealthSyncStatus>>> getSyncHistory({
    required HealthDataType dataType,
    required DateTime since,
  });

  // ============================================================
  // RETRY & MAINTENANCE
  // ============================================================

  /// Retries a failed sync with exponential backoff.
  ///
  /// Backoff delays:
  /// - Retry 1: 1 hour
  /// - Retry 2: 4 hours
  /// - Retry 3: 24 hours
  /// - Max retries: 3 (then user must manually sync)
  ///
  /// Flow:
  /// 1. Get last sync status
  /// 2. Check shouldRetry() and retry count
  /// 3. Wait for exponential delay
  /// 4. Re-attempt sync
  /// 5. Update status (success or increment retry count)
  ///
  /// Returns:
  /// - Right: void (retry triggered)
  /// - Left: [CacheFailure] if status check fails
  /// - Left: [ServerFailure] if retry sync fails
  Future<Either<Failure, void>> retryFailedSync(HealthDataType dataType);

  /// Clears all synced data and sync status from local storage.
  ///
  /// Use cases:
  /// - User logs out
  /// - User disables health sync
  /// - Testing/debugging
  ///
  /// Clears:
  /// - Hive measurements cache
  /// - Sync status history
  /// - Retry counters
  ///
  /// Does NOT:
  /// - Revoke platform permissions (user must do in iOS Settings)
  /// - Delete data from HealthKit/Health Connect
  ///
  /// Returns:
  /// - Right: void (cache cleared)
  /// - Left: [CacheFailure] if Hive clear fails
  Future<Either<Failure, void>> clearSyncCache();

  /// Gets list of body measurements from local cache.
  ///
  /// Filters:
  /// - By data type (bodyWeight, bodyFat, etc.)
  /// - By date range
  /// - By source (FitLog, HealthKit, Health Connect)
  ///
  /// Returns:
  /// - Right: `List<BodyMeasurement>` (sorted by recordedAt desc)
  /// - Left: [CacheFailure] if Hive read fails
  Future<Either<Failure, List<BodyMeasurement>>> getMeasurements({
    required HealthDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================================
  // HEALTH CONNECT (ANDROID) - INSTALLATION
  // ============================================================

  /// Android-specific: Opens Play Store to install Health Connect.
  ///
  /// Call this when Health Connect is not available on the device.
  /// iOS: No-op (returns Right immediately).
  ///
  /// Use case:
  /// - User is on Android 14+ but Health Connect is not installed
  /// - Show dialog explaining why Health Connect is needed
  /// - Button to install from Play Store
  ///
  /// Returns:
  /// - Right: void (Play Store opened or iOS no-op)
  /// - Left: [ServerFailure] if opening Play Store fails
  ///
  /// Example:
  /// ```dart
  /// final status = await repository.checkPermissionStatus();
  /// status.fold(
  ///   (failure) => showError(failure),
  ///   (permission) async {
  ///     if (!permission.healthConnectAvailable && Platform.isAndroid) {
  ///       await repository.installHealthConnect();
  ///       // Show snackbar: "Please install Health Connect and return"
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<Failure, void>> installHealthConnect();
}
