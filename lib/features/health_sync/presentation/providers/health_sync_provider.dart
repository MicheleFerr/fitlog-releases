import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/repositories/health_repository.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';

// ============================================================
// SYNC STATUS PROVIDERS
// ============================================================

/// Provider that exposes the last sync status for a specific data type.
///
/// **Auto-refresh**: Watches repository for changes, no manual refresh needed.
///
/// Usage:
/// ```dart
/// final workoutSyncStatus = ref.watch(
///   healthSyncStatusProvider(HealthDataType.workout),
/// );
///
/// workoutSyncStatus.when(
///   data: (status) {
///     if (status.lastResult == SyncResult.success) {
///       // Last sync succeeded
///     }
///   },
///   loading: () => LoadingIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final healthSyncStatusProvider =
    FutureProvider.family<HealthSyncStatus, HealthDataType>((
      ref,
      dataType,
    ) async {
      // P0 FIX: Add proper error handling
      try {
        final repository = ref.watch(healthRepositoryProvider);

        final result = await repository.getLastSyncStatus(dataType);

        return result.fold((failure) {
          throw Exception(
            'Failed to get sync status for ${dataType.name}: ${failure.toString()}',
          );
        }, (status) => status);
      } catch (e, stackTrace) {
        // Re-throw with context for better debugging
        Error.throwWithStackTrace(
          Exception('HealthSyncStatus error for ${dataType.name}: $e'),
          stackTrace,
        );
      }
    });

/// Provider that exposes sync history for a data type (last 30 days).
///
/// Usage:
/// ```dart
/// final history = ref.watch(
///   healthSyncHistoryProvider(HealthDataType.bodyWeight),
/// );
/// ```
final healthSyncHistoryProvider =
    FutureProvider.family<List<HealthSyncStatus>, HealthDataType>((
      ref,
      dataType,
    ) async {
      // P0 FIX: Add proper error handling
      try {
        final repository = ref.watch(healthRepositoryProvider);

        final result = await repository.getSyncHistory(
          dataType: dataType,
          since: DateTime.now().subtract(const Duration(days: 30)),
        );

        return result.fold((failure) {
          throw Exception(
            'Failed to get sync history for ${dataType.name}: ${failure.toString()}',
          );
        }, (history) => history);
      } catch (e, stackTrace) {
        // Re-throw with context for better debugging
        Error.throwWithStackTrace(
          Exception('HealthSyncHistory error for ${dataType.name}: $e'),
          stackTrace,
        );
      }
    });

// ============================================================
// MEASUREMENTS PROVIDERS
// ============================================================

/// Provider that exposes cached body measurements (last 90 days).
///
/// **Note**: This is cached data from local Hive storage.
/// For fresh data, trigger a sync first via `HealthSyncController`.
///
/// Usage:
/// ```dart
/// final weights = ref.watch(
///   bodyMeasurementsProvider(HealthDataType.bodyWeight),
/// );
/// ```
final bodyMeasurementsProvider =
    FutureProvider.family<List<BodyMeasurement>, HealthDataType>((
      ref,
      dataType,
    ) async {
      // P0 FIX: Add proper error handling
      try {
        final repository = ref.watch(healthRepositoryProvider);

        final result = await repository.getMeasurements(
          dataType: dataType,
          startDate: DateTime.now().subtract(const Duration(days: 90)),
          endDate: DateTime.now(),
        );

        return result.fold((failure) {
          throw Exception(
            'Failed to get measurements for ${dataType.name}: ${failure.toString()}',
          );
        }, (measurements) => measurements);
      } catch (e, stackTrace) {
        // Re-throw with context for better debugging
        Error.throwWithStackTrace(
          Exception('BodyMeasurements error for ${dataType.name}: $e'),
          stackTrace,
        );
      }
    });

// ============================================================
// SYNC CONTROLLER
// ============================================================

/// Controller for triggering health data sync operations.
///
/// **Features**:
/// - Manual sync triggers (workout, body weight)
/// - Automatic retry for failed syncs (exponential backoff)
/// - Bidirectional body weight sync (read + write)
/// - Permission checks before sync
///
/// Usage:
/// ```dart
/// final controller = ref.read(healthSyncControllerProvider.notifier);
///
/// // Trigger workout sync (last 30 days)
/// await controller.syncWorkouts();
///
/// // Trigger body weight sync (last 90 days)
/// await controller.syncBodyWeight();
///
/// // Write new body weight to HealthKit
/// await controller.writeBodyWeight(
///   BodyMeasurement(
///     value: 75.5,
///     unit: MeasurementUnit.kilograms,
///     recordedAt: DateTime.now(),
///     dataType: HealthDataType.bodyWeight,
///     source: 'FitLog',
///   ),
/// );
/// ```
final healthSyncControllerProvider =
    NotifierProvider<HealthSyncController, AsyncValue<void>>(
      HealthSyncController.new,
    );

class HealthSyncController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IHealthRepository get _repository => ref.read(healthRepositoryProvider);

  /// Syncs workouts from HealthKit/Health Connect (last 30 days).
  ///
  /// **Permission Required**: User must have granted workout sync permission.
  ///
  /// **Date Range**: Last 30 days (configurable in repository layer).
  ///
  /// **Returns**: Success or failure via AsyncValue state.
  Future<void> syncWorkouts() async {
    state = const AsyncValue.loading();

    final result = await _repository.syncWorkouts(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );

    state = result.fold(
      (failure) =>
          AsyncValue.error(Exception(failure.toString()), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  /// Syncs body weight measurements from HealthKit/Health Connect (last 90 days).
  ///
  /// **Permission Required**: User must have granted body weight sync permission.
  ///
  /// **Date Range**: Last 90 days (typical weight tracking period).
  ///
  /// **Returns**: Success or failure via AsyncValue state.
  Future<void> syncBodyWeight() async {
    state = const AsyncValue.loading();

    final result = await _repository.syncBodyWeight(
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      endDate: DateTime.now(),
    );

    state = result.fold(
      (failure) =>
          AsyncValue.error(Exception(failure.toString()), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  /// Writes a single body weight measurement to HealthKit/Health Connect.
  ///
  /// **Instant Sync**: Called when user manually enters weight in FitLog.
  /// Writes immediately to health platform without waiting for daily background sync.
  ///
  /// **Permission Required**: User must have granted body weight write permission.
  ///
  /// Example:
  /// ```dart
  /// await controller.writeBodyWeight(
  ///   BodyMeasurement(
  ///     value: 75.5,
  ///     unit: MeasurementUnit.kilograms,
  ///     recordedAt: DateTime.now(),
  ///     dataType: HealthDataType.bodyWeight,
  ///     source: 'FitLog',
  ///   ),
  /// );
  /// ```
  Future<void> writeBodyWeight(BodyMeasurement measurement) async {
    state = const AsyncValue.loading();

    final result = await _repository.writeBodyWeight(measurement);

    state = result.fold(
      (failure) =>
          AsyncValue.error(Exception(failure.toString()), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  /// Retries a failed sync operation with exponential backoff.
  ///
  /// **Retry Logic**:
  /// - Retry 1: After 1 hour
  /// - Retry 2: After 4 hours
  /// - Retry 3: After 24 hours
  /// - Max retries: 3 (then gives up)
  ///
  /// **Auto-called by background sync** if last sync failed.
  /// **Manually callable** from UI "Retry" button.
  ///
  /// Example:
  /// ```dart
  /// await controller.retryFailedSync(HealthDataType.workout);
  /// ```
  Future<void> retryFailedSync(HealthDataType dataType) async {
    state = const AsyncValue.loading();

    final result = await _repository.retryFailedSync(dataType);

    state = result.fold(
      (failure) =>
          AsyncValue.error(Exception(failure.toString()), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  /// Clears all sync cache (status + measurements).
  ///
  /// **Use when**:
  /// - User logs out
  /// - User disables health sync
  /// - Testing/debugging
  ///
  /// **Warning**: This deletes local cache only, not health platform data.
  Future<void> clearSyncCache() async {
    state = const AsyncValue.loading();

    final result = await _repository.clearSyncCache();

    state = result.fold(
      (failure) =>
          AsyncValue.error(Exception(failure.toString()), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  /// Triggers a full sync for all authorized data types.
  ///
  /// **Convenience method** that syncs all data types user has authorized.
  ///
  /// **Use when**:
  /// - Initial setup after permission grant
  /// - "Sync All" button in settings
  /// - Daily background sync
  ///
  /// **Smart behavior**: Only syncs data types user has authorized.
  Future<void> syncAll() async {
    state = const AsyncValue.loading();

    try {
      // Sync workouts (last 30 days)
      await syncWorkouts();

      // Sync body weight (last 90 days)
      await syncBodyWeight();

      // TODO: Add other data types when implemented
      // - Body fat %
      // - Lean mass
      // - Heart rate
      // - Sleep
      // - Nutrition

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
