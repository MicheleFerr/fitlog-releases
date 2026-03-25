import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/repositories/health_repository.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/repositories/health_repository_impl.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_local_datasource.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_remote_datasource.dart';

// ============================================================
// REPOSITORY PROVIDERS
// ============================================================

/// Provider for local datasource (Hive)
final healthLocalDatasourceProvider = Provider<IHealthLocalDatasource>((ref) {
  return HealthLocalDatasourceImpl();
});

/// Provider for remote datasource (health package)
final healthRemoteDatasourceProvider = Provider<IHealthRemoteDatasource>((ref) {
  return HealthRemoteDatasourceImpl();
});

/// Provider for health repository (main data access point)
final healthRepositoryProvider = Provider<IHealthRepository>((ref) {
  return HealthRepositoryImpl(
    localDatasource: ref.watch(healthLocalDatasourceProvider),
    remoteDatasource: ref.watch(healthRemoteDatasourceProvider),
  );
});

// ============================================================
// PERMISSION STATE PROVIDER
// ============================================================

/// Provider that holds current runtime permission status.
///
/// **IMPORTANT**: This is VOLATILE (not persisted).
/// Permission status is always fetched fresh from the system to avoid stale state.
///
/// Usage:
/// ```dart
/// final permissionStatus = ref.watch(healthPermissionStatusProvider);
///
/// permissionStatus.when(
///   data: (status) {
///     if (status.canAttemptSync(HealthDataType.workout)) {
///       // Authorized to sync workouts
///     }
///   },
///   loading: () => LoadingIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final healthPermissionStatusProvider = FutureProvider<HealthPermissionStatus>((
  ref,
) async {
  final repository = ref.watch(healthRepositoryProvider);

  final result = await repository.checkPermissionStatus();

  return result.fold((failure) => throw failure, (status) => status);
});

// ============================================================
// PERMISSION CONTROLLER
// ============================================================

/// Controller for managing health permission requests.
///
/// Handles:
/// - iOS: Sequential permission flow (workout → bodyWeight)
/// - Android: Batch permission request + Health Connect availability check
///
/// Usage:
/// ```dart
/// final controller = ref.read(healthPermissionControllerProvider.notifier);
///
/// await controller.requestPermissions(
///   dataTypes: [HealthDataType.workout, HealthDataType.bodyWeight],
/// );
/// ```
final healthPermissionControllerProvider =
    NotifierProvider<
      HealthPermissionController,
      AsyncValue<HealthPermissionStatus>
    >(HealthPermissionController.new);

class HealthPermissionController
    extends Notifier<AsyncValue<HealthPermissionStatus>> {
  @override
  AsyncValue<HealthPermissionStatus> build() {
    // P0 FIX: Add disposal callback
    ref.onDispose(() {
      // No active resources to clean up in this controller
      // (no timers, subscriptions, or persistent connections)
      // This callback is here to satisfy audit requirements
    });

    // Load initial permission status on creation
    _loadPermissionStatus();
    return const AsyncValue.loading();
  }

  IHealthRepository get _repository => ref.read(healthRepositoryProvider);

  /// Loads current runtime permission status from system.
  ///
  /// Always fetches fresh status (no caching) to avoid stale state bugs.
  Future<void> _loadPermissionStatus() async {
    state = const AsyncValue.loading();

    final result = await _repository.checkPermissionStatus();

    state = result.fold(
      (failure) =>
          AsyncValue.error(Exception(failure.toString()), StackTrace.current),
      (status) => AsyncValue.data(status),
    );
  }

  /// Requests permissions for specified health data types.
  ///
  /// **Platform Behavior**:
  /// - iOS: Shows native HealthKit permission dialog (sequential per type)
  /// - Android: Shows Health Connect permission dialog (batch request)
  ///
  /// **Returns**: Updated permission status after user responds to dialog.
  ///
  /// Example:
  /// ```dart
  /// await controller.requestPermissions(
  ///   dataTypes: [HealthDataType.workout, HealthDataType.bodyWeight],
  /// );
  /// ```
  Future<void> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.requestPermissions(dataTypes: dataTypes);

    state = result.fold(
      (failure) =>
          AsyncValue.error(Exception(failure.toString()), StackTrace.current),
      (status) => AsyncValue.data(status),
    );
  }

  /// Refreshes permission status from system (runtime check).
  ///
  /// Call this when:
  /// - User returns to app after granting/denying permissions in Settings
  /// - Before starting a sync operation
  /// - After permission request dialog is dismissed
  Future<void> refreshPermissionStatus() async {
    await _loadPermissionStatus();
  }

  /// iOS-specific: Requests workout permission first, then bodyWeight.
  ///
  /// iOS best practice: Request permissions sequentially to avoid overwhelming user.
  /// Call this instead of `requestPermissions()` on iOS if you need both types.
  ///
  /// **Flow**:
  /// 1. Request workout permission
  /// 2. If granted, request bodyWeight permission
  /// 3. Return final status with both results
  Future<void> requestPermissionsSequential() async {
    // Step 1: Request workout permission
    await requestPermissions(dataTypes: [HealthDataType.workout]);

    // Check if workout was granted
    state.maybeWhen(
      data: (workoutResult) {
        if (workoutResult.canAttemptSync(HealthDataType.workout)) {
          // Step 2: Request body weight permission
          requestPermissions(dataTypes: [HealthDataType.bodyWeight]);
        }
      },
      orElse: () {},
    );
  }

  /// Android-specific: Opens Health Connect app settings.
  ///
  /// Use when:
  /// - User denied permissions and needs to grant them manually
  /// - Health Connect is not installed (shows Play Store link)
  ///
  /// **Note**: Implementation requires platform channel to health package.
  /// For MVP, this is a placeholder - actual implementation will be added when needed.
  Future<void> openHealthConnectSettings() async {
    // TODO: Implement platform channel call to health package
    // await _health.openHealthConnectSettings();
    throw UnimplementedError(
      'Opening Health Connect settings not implemented yet',
    );
  }
}
