import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/repositories/health_repository.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_local_datasource.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_remote_datasource.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';

/// Implementation of [IHealthRepository] coordinating local and remote datasources.
///
/// Architecture:
/// - Local datasource (Hive): Persists sync status and measurements
/// - Remote datasource (health package): Interfaces with HealthKit/Health Connect
///
/// Error handling:
/// - Uses [FirebaseErrorMapperMixin] for consistent error handling
/// - Platform errors → [ServerFailure]
/// - Permission denied → [PermissionDeniedFailure]
/// - Cache errors → [CacheFailure]
class HealthRepositoryImpl
    with FirebaseErrorMapperMixin
    implements IHealthRepository {

  HealthRepositoryImpl({
    required IHealthLocalDatasource localDatasource,
    required IHealthRemoteDatasource remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;
  final IHealthLocalDatasource _localDatasource;
  final IHealthRemoteDatasource _remoteDatasource;

  // ============================================================
  // PERMISSION MANAGEMENT
  // ============================================================

  @override
  Future<Either<Failure, HealthPermissionStatus>> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    return handleFirebaseOperation(() async {
      final status = await _remoteDatasource.requestPermissions(
        dataTypes: dataTypes,
      );
      return status;
    }, operationName: 'requestHealthPermissions');
  }

  @override
  Future<Either<Failure, HealthPermissionStatus>>
  checkPermissionStatus() async {
    return handleFirebaseOperation(() async {
      final status = await _remoteDatasource.checkPermissionStatus();
      return status;
    }, operationName: 'checkHealthPermissionStatus');
  }

  // ============================================================
  // SYNC OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, void>> syncWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return handleFirebaseVoidOperation(() async {
      // 1. Check permission (runtime verification)
      final permissionResult = await checkPermissionStatus();
      final permissionStatus = permissionResult.getOrElse(
        (failure) => throw Exception('Permission check failed'),
      );

      if (!permissionStatus.canSync(HealthDataType.workout)) {
        throw Exception('Workout sync permission not granted');
      }

      // 2. Update sync status to "syncing"
      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.syncing,
        ),
      );

      try {
        // 3. Fetch workouts from remote datasource
        // ignore: unused_local_variable
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
        rethrow;
      }
    }, operationName: 'syncWorkouts');
  }

  @override
  Future<Either<Failure, void>> syncBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return handleFirebaseVoidOperation(() async {
      // 1. Check permission (runtime verification)
      final permissionResult = await checkPermissionStatus();
      final permissionStatus = permissionResult.getOrElse(
        (failure) => throw Exception('Permission check failed'),
      );

      if (!permissionStatus.canSync(HealthDataType.bodyWeight)) {
        throw Exception('Body weight sync permission not granted');
      }

      // 2. Update sync status to "syncing"
      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.syncing,
        ),
      );

      try {
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
        rethrow;
      }
    }, operationName: 'syncBodyWeight');
  }

  @override
  Future<Either<Failure, void>> syncHeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return handleFirebaseVoidOperation(() async {
      // 1. Check permission (runtime verification)
      final permissionResult = await checkPermissionStatus();
      final permissionStatus = permissionResult.getOrElse(
        (failure) => throw Exception('Permission check failed'),
      );

      if (!permissionStatus.canSync(HealthDataType.height)) {
        throw Exception('Height sync permission not granted');
      }

      // 2. Update sync status to "syncing"
      await _localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.height,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.syncing,
        ),
      );

      try {
        // 3. Fetch height from remote datasource (HealthKit/Health Connect)
        final measurements = await _remoteDatasource.fetchHeight(
          startDate: startDate,
          endDate: endDate,
        );

        // 4. Save measurements to local cache
        await _localDatasource.saveMeasurements(measurements);

        // 5. Update sync status to "success"
        await _localDatasource.saveSyncStatus(
          HealthSyncStatus(
            dataType: HealthDataType.height,
            lastSyncTime: DateTime.now(),
            lastResult: SyncResult.success,
            retryCount: 0, // Reset retry count on success
          ),
        );
      } catch (e) {
        // Update sync status to "error"
        final currentStatus = await _localDatasource.getSyncStatus(
          HealthDataType.height,
        );

        await _localDatasource.saveSyncStatus(
          HealthSyncStatus(
            dataType: HealthDataType.height,
            lastSyncTime: DateTime.now(),
            lastResult: SyncResult.error,
            retryCount: (currentStatus?.retryCount ?? 0) + 1,
            errorMessage: e.toString(),
          ),
        );
        rethrow;
      }
    }, operationName: 'syncHeight');
  }

  @override
  Future<Either<Failure, bool>> writeWorkout({
    required DateTime startTime,
    required DateTime endTime,
    int? totalCalories,
    String? workoutName,
  }) async {
    return handleFirebaseOperation(() async {
      final success = await _remoteDatasource.writeWorkout(
        startTime: startTime,
        endTime: endTime,
        totalCalories: totalCalories,
        workoutName: workoutName,
      );
      return success;
    }, operationName: 'writeWorkout');
  }

  @override
  Future<Either<Failure, void>> writeBodyWeight(
    BodyMeasurement measurement,
  ) async {
    return handleFirebaseVoidOperation(() async {
      // 1. Check permission (runtime verification)
      final permissionResult = await checkPermissionStatus();
      final permissionStatus = permissionResult.getOrElse(
        (failure) => throw Exception('Permission check failed'),
      );

      if (!permissionStatus.canSync(HealthDataType.bodyWeight)) {
        throw Exception('Body weight write permission not granted');
      }

      // 2. Write to health platform (instant sync)
      await _remoteDatasource.writeBodyWeight(measurement);

      // 3. Save to local cache
      await _localDatasource.saveMeasurement(measurement);
    }, operationName: 'writeBodyWeight');
  }

  // ============================================================
  // SYNC STATUS & HISTORY
  // ============================================================

  @override
  Future<Either<Failure, HealthSyncStatus>> getLastSyncStatus(
    HealthDataType dataType,
  ) async {
    return handleFirebaseOperation(() async {
      final status = await _localDatasource.getSyncStatus(dataType);

      if (status == null) {
        // Return default "never synced" status
        return HealthSyncStatus(
          dataType: dataType,
          lastSyncTime: null,
          lastResult: SyncResult.idle,
        );
      }

      return status;
    }, operationName: 'getLastSyncStatus');
  }

  @override
  Future<Either<Failure, List<HealthSyncStatus>>> getSyncHistory({
    required HealthDataType dataType,
    required DateTime since,
  }) async {
    return handleFirebaseOperation(() async {
      final history = await _localDatasource.getSyncHistory(
        dataType: dataType,
        since: since,
      );
      return history;
    }, operationName: 'getSyncHistory');
  }

  // ============================================================
  // RETRY & MAINTENANCE
  // ============================================================

  @override
  Future<Either<Failure, void>> retryFailedSync(HealthDataType dataType) async {
    return handleFirebaseVoidOperation(() async {
      // 1. Get last sync status
      final statusResult = await getLastSyncStatus(dataType);
      final status = statusResult.getOrElse(
        (failure) => throw Exception('Failed to get sync status'),
      );

      // 2. Check if retry is allowed
      if (!status.shouldRetry()) {
        throw Exception('Max retries reached or sync not in error state');
      }

      // 3. Calculate exponential backoff delay
      const retryDelays = [
        Duration(hours: 1), // Retry 1
        Duration(hours: 4), // Retry 2
        Duration(hours: 24), // Retry 3
      ];

      final delay = retryDelays[status.retryCount];

      // Check if enough time has passed since last sync
      if (status.lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(
          status.lastSyncTime!,
        );
        if (timeSinceLastSync < delay) {
          throw Exception(
            'Retry delay not elapsed yet (${delay.inHours}h required)',
          );
        }
      }

      // 4. Trigger sync based on data type
      final syncResult = switch (dataType) {
        HealthDataType.workout => await syncWorkouts(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
        HealthDataType.bodyWeight => await syncBodyWeight(
          startDate: DateTime.now().subtract(const Duration(days: 90)),
          endDate: DateTime.now(),
        ),
        _ => throw Exception(
          'Retry not supported for data type: ${dataType.name}',
        ),
      };

      // Propagate sync errors
      syncResult.fold(
        (failure) => throw failure,
        (_) => null,
      );
    }, operationName: 'retryFailedSync');
  }

  @override
  Future<Either<Failure, void>> clearSyncCache() async {
    return handleFirebaseVoidOperation(() async {
      await _localDatasource.clearSyncStatuses();
      await _localDatasource.clearMeasurements();
    }, operationName: 'clearSyncCache');
  }

  @override
  Future<Either<Failure, List<BodyMeasurement>>> getMeasurements({
    required HealthDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return handleFirebaseOperation(() async {
      final measurements = await _localDatasource.getMeasurements(
        dataType: dataType,
        startDate: startDate,
        endDate: endDate,
      );
      return measurements;
    }, operationName: 'getMeasurements');
  }

  @override
  Future<Either<Failure, void>> installHealthConnect() async {
    return handleFirebaseVoidOperation(() async {
      await _remoteDatasource.installHealthConnect();
    }, operationName: 'installHealthConnect');
  }
}
