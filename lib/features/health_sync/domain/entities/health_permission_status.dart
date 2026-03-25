import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';

part 'health_permission_status.freezed.dart';

/// Represents the current permission state for health data access.
///
/// **IMPORTANT**: This entity is VOLATILE (not persisted in Hive).
/// Permissions must be checked at runtime before every sync operation
/// to avoid stale state bugs (user revokes permissions in iOS Settings).
///
/// iOS: Sequential permission requests (workout → weight)
/// Android: Batch permission request + Health Connect availability check
@freezed
abstract class HealthPermissionStatus with _$HealthPermissionStatus {
  const factory HealthPermissionStatus({
    /// Map of permission states per data type
    /// Key: HealthDataType (workout, bodyWeight, etc.)
    /// Value: PermissionState (authorized, denied, etc.)
    required Map<HealthDataType, PermissionState> permissions,

    /// Android-only: Whether Health Connect is installed and available
    /// - iOS: Always false (uses HealthKit natively)
    /// - Android 14+: True if Health Connect app installed
    @Default(false) bool healthConnectAvailable,
  }) = _HealthPermissionStatus;

  // NO fromJson - This entity is NEVER persisted (volatile)
  // Permission status is always fetched fresh at runtime
}

/// Enum representing the authorization state for a specific health data type
enum PermissionState {
  /// Permission not yet requested (initial state)
  notDetermined,

  /// User authorized access to this data type
  authorized,

  /// iOS-only: permission flow completed, but HealthKit does not disclose
  /// the current READ authorization state through the plugin.
  unverified,

  /// User explicitly denied access
  denied,

  /// Android-specific: Health Connect app not installed
  /// Shows installation prompt with Play Store link
  healthConnectNotInstalled,
}

extension PermissionStateExtension on PermissionState {
  bool get isConfirmedAuthorized => this == PermissionState.authorized;

  bool get isSyncAttemptable =>
      this == PermissionState.authorized || this == PermissionState.unverified;

  bool get isPendingVerification => this == PermissionState.unverified;
}

/// Extension methods for [HealthPermissionStatus]
extension HealthPermissionStatusExtension on HealthPermissionStatus {
  /// Returns true if the specified data type can be synced
  /// (permission is authorized)
  bool canSync(HealthDataType type) =>
      (permissions[type]?.isConfirmedAuthorized ?? false);

  /// Returns true if the specified data type can be attempted.
  ///
  /// This is used on iOS, where READ access may be impossible to verify even
  /// after the user has already completed the HealthKit permission flow.
  bool canAttemptSync(HealthDataType type) =>
      (permissions[type]?.isSyncAttemptable ?? false);

  /// Returns true if at least one permission is authorized
  /// but not all (partial approval scenario)
  ///
  /// Example: User approved workout sync but denied weight sync
  bool get hasPartialPermissions {
    final hasAuthorized = permissions.values.any((p) => p.isSyncAttemptable);
    final hasNonAuthorized = permissions.values.any(
      (p) => !p.isSyncAttemptable,
    );
    return hasAuthorized && hasNonAuthorized;
  }

  /// Returns true if all requested permissions are authorized
  bool get hasFullPermissions =>
      permissions.values.every((p) => p.isConfirmedAuthorized);

  /// Returns true if no permissions have been granted
  bool get hasNoPermissions =>
      permissions.values.every((p) => !p.isSyncAttemptable);

  /// Returns true if at least one permission can be attempted.
  bool get hasAnySyncAccess =>
      permissions.values.any((p) => p.isSyncAttemptable);

  /// Returns a list of data types that are currently authorized
  List<HealthDataType> get authorizedDataTypes => permissions.entries
      .where((e) => e.value.isConfirmedAuthorized)
      .map((e) => e.key)
      .toList();

  /// Returns a list of data types whose sync can be attempted.
  List<HealthDataType> get attemptableDataTypes => permissions.entries
      .where((e) => e.value.isSyncAttemptable)
      .map((e) => e.key)
      .toList();

  /// Returns a list of data types that are denied
  List<HealthDataType> get deniedDataTypes => permissions.entries
      .where((e) => e.value == PermissionState.denied)
      .map((e) => e.key)
      .toList();

  /// Returns a list of data types waiting for runtime verification on iOS.
  List<HealthDataType> get unverifiedDataTypes => permissions.entries
      .where((e) => e.value.isPendingVerification)
      .map((e) => e.key)
      .toList();

  /// iOS-specific: Returns true if sequential permission flow is needed
  /// (workout authorized, weight not yet requested)
  bool get needsSequentialPermission {
    final workoutState = permissions[HealthDataType.workout];
    final weightState = permissions[HealthDataType.bodyWeight];

    return (workoutState?.isSyncAttemptable ?? false) &&
        weightState == PermissionState.notDetermined;
  }
}
