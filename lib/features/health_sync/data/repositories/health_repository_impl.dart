import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/repositories/health_repository.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_local_datasource.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_remote_datasource.dart';

/// Implementation of [IHealthRepository] coordinating local and remote datasources.
///
/// Architecture:
/// - Local datasource (Hive): Persists sync status and measurements
/// - Remote datasource (health package): Interfaces with HealthKit/Health Connect
///
/// Error handling:
/// - Platform errors → [ServerFailure]
/// - Permission denied → [PermissionDeniedFailure]
/// - Cache errors → [CacheFailure]
class HealthRepositoryImpl implements IHealthRepository {
  final IHealthLocalDatasource _localDatasource;
  final IHealthRemoteDatasource _remoteDatasource;

  HealthRepositoryImpl({
    required IHealthLocalDatasource localDatasource,
    required IHealthRemoteDatasource remoteDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource;

  // ============================================================
  // PERMISSION MANAGEMENT
  // ============================================================

  @override
  Future<Either<Failure, HealthPermissionStatus>> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    try {
      final status = await _remoteDatasource.requestPermissions(
        dataTypes: dataTypes,
      );
      return right(status);
    } catch (e) {
      return left(
        ServerFailure('Failed to request health permissions: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, HealthPermissionStatus>> checkPermissionStatus() async {
    try {
      final status = await _remoteDatasource.checkPermissionStatus();
      return right(status);
    } catch (e) {
      return left(
        ServerFailure('Failed to check permission status: $e'),
      );
    }
  }

  // ============================================================
  // SYNC OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, void>> syncWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 1. Check permission (runtime verification)
      final permissionResult = await checkPermissionStatus();
      final permissionStatus = permissionResult.getOrElse(
        (failure) => throw Exception('Permission check failed'),
      );

      if (!permissionStatus.canSync(HealthDataType.workout)) {
        return left(
          PermissionDeniedFailure('Workout sync permission not granted'),
        );
      }

      // 2. Update sync status to "syncing"
      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.syncing,
        ),
      );

      // 3. Fetch workouts from remote datasource
      final workouts = await _remoteDatasource.fetchWorkouts(
        startDate: startDate,
        endDate: endDate,
      );

      // TODO: Map workouts to FitLog domain entities and save to workout repository
      // This will be implemented when integrating with existing workout system

      // 4. Update sync status to "success"
      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.success,
          retryCount: 0, // Reset retry count on success
        ),
      );

      return right(null);
    } catch (e) {
      // Update sync status to "error"
      final currentStatus = await _localDatasource.getSyncStatus(
        HealthDataType.workout,
      );

      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.error,
          retryCount: (currentStatus?.retryCount ?? 0) + 1,
          errorMessage: e.toString(),
        ),
      );

      return left(
        ServerFailure('Failed to sync workouts: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> syncBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 1. Check permission (runtime verification)
      final permissionResult = await checkPermissionStatus();
      final permissionStatus = permissionResult.getOrElse(
        (failure) => throw Exception('Permission check failed'),
      );

      if (!permissionStatus.canSync(HealthDataType.bodyWeight)) {
        return left(
          PermissionDeniedFailure('Body weight sync permission not granted'),
        );
      }

      // 2. Update sync status to "syncing"
      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.syncing,
        ),
      );

      // 3. Fetch weight from remote datasource (HealthKit/Health Connect)
      final measurements = await _remoteDatasource.fetchBodyWeight(
        startDate: startDate,
        endDate: endDate,
      );

      // 4. Save measurements to local cache
      await _localDatasource.saveMeasurements(measurements);

      // 5. Update sync status to "success"
      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.success,
          retryCount: 0, // Reset retry count on success
        ),
      );

      return right(null);
    } catch (e) {
      // Update sync status to "error"
      final currentStatus = await _localDatasource.getSyncStatus(
        HealthDataType.bodyWeight,
      );

      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.error,
          retryCount: (currentStatus?.retryCount ?? 0) + 1,
          errorMessage: e.toString(),
        ),
      );

      return left(
        ServerFailure('Failed to sync body weight: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> writeBodyWeight(
    BodyMeasurement measurement,
  ) async {
    try {
      // 1. Check permission (runtime verification)
      final permissionResult = await checkPermissionStatus();
      final permissionStatus = permissionResult.getOrElse(
        (failure) => throw Exception('Permission check failed'),
      );

      if (!permissionStatus.canSync(HealthDataType.bodyWeight)) {
        return left(
          PermissionDeniedFailure('Body weight write permission not granted'),
        );
      }

      // 2. Write to health platform (instant sync)
      await _remoteDatasource.writeBodyWeight(measurement);

      // 3. Save to local cache
      await _localDatasource.saveMeasurement(measurement);

      return right(null);
    } catch (e) {
      return left(
        ServerFailure('Failed to write body weight: $e'),
      );
    }
  }

  // ============================================================
  // SYNC STATUS & HISTORY
  // ============================================================

  @override
  Future<Either<Failure, HealthSyncStatus>> getLastSyncStatus(
    HealthDataType dataType,
  ) async {
    try {
      final status = await _localDatasource.getSyncStatus(dataType);

      if (status == null) {
        // Return default "never synced" status
        return right(
          HealthSyncStatus(
            dataType: dataType,
            lastSyncTime: null,
            lastResult: SyncResult.idle,
          ),
        );
      }

      return right(status);
    } catch (e) {
      return left(
        CacheFailure('Failed to get sync status from cache: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<HealthSyncStatus>>> getSyncHistory({
    required HealthDataType dataType,
    required DateTime since,
  }) async {
    try {
      final history = await _localDatasource.getSyncHistory(
        dataType: dataType,
        since: since,
      );
      return right(history);
    } catch (e) {
      return left(
        CacheFailure('Failed to get sync history from cache: $e'),
      );
    }
  }

  // ============================================================
  // RETRY & MAINTENANCE
  // ============================================================

  @override
  Future<Either<Failure, void>> retryFailedSync(HealthDataType dataType) async {
    try {
      // 1. Get last sync status
      final statusResult = await getLastSyncStatus(dataType);
      final status = statusResult.getOrElse(
        (failure) => throw Exception('Failed to get sync status'),
      );

      // 2. Check if retry is allowed
      if (!status.shouldRetry()) {
        return left(
          ServerFailure('Max retries reached or sync not in error state'),
        );
      }

      // 3. Calculate exponential backoff delay
      final retryDelays = [
        Duration(hours: 1),  // Retry 1
        Duration(hours: 4),  // Retry 2
        Duration(hours: 24), // Retry 3
      ];

      final delay = retryDelays[status.retryCount];

      // Check if enough time has passed since last sync
      if (status.lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(status.lastSyncTime!);
        if (timeSinceLastSync < delay) {
          return left(
            ServerFailure('Retry delay not elapsed yet (${delay.inHours}h required)'),
          );
        }
      }

      // 4. Trigger sync based on data type
      switch (dataType) {
        case HealthDataType.workout:
          return syncWorkouts(
            startDate: DateTime.now().subtract(Duration(days: 30)),
            endDate: DateTime.now(),
          );
        case HealthDataType.bodyWeight:
          return syncBodyWeight(
            startDate: DateTime.now().subtract(Duration(days: 90)),
            endDate: DateTime.now(),
          );
        default:
          return left(
            ServerFailure('Retry not supported for data type: ${dataType.name}'),
          );
      }
    } catch (e) {
      return left(
        ServerFailure('Failed to retry sync: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearSyncCache() async {
    try {
      await _localDatasource.clearSyncStatuses();
      await _localDatasource.clearMeasurements();
      return right(null);
    } catch (e) {
      return left(
        CacheFailure('Failed to clear sync cache: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<BodyMeasurement>>> getMeasurements({
    required HealthDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final measurements = await _localDatasource.getMeasurements(
        dataType: dataType,
        startDate: startDate,
        endDate: endDate,
      );
      return right(measurements);
    } catch (e) {
      return left(
        CacheFailure('Failed to get measurements from cache: $e'),
      );
    }
  }
}
