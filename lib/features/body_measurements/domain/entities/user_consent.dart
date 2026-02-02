import 'package:freezed_annotation/freezed_annotation.dart';
import 'metric_type.dart';

part 'user_consent.freezed.dart';
part 'user_consent.g.dart';

/// UserConsent - Domain entity for user consent tracking
///
/// Implements GDPR Article 7 (Conditions for consent):
/// - Explicit opt-in per metric (no pre-checked boxes)
/// - Granular control (user chooses which metrics to track)
/// - Consent version tracking (privacy policy updates)
/// - Audit trail (timestamp, IP address)
/// - Revocable (user can withdraw consent anytime)
///
/// **GDPR Compliance**:
/// - Explicit consent: User must actively check each metric checkbox
/// - Informed consent: Privacy policy must be presented and accepted
/// - Freely given: No dark patterns, no forced bundling
/// - Specific: Granular per-metric, not blanket consent
/// - Unambiguous: Clear language, no legalese in UI
///
/// Example:
/// ```dart
/// final consent = UserConsent(
///   id: 'consent-123',
///   userId: 'user-456',
///   groupConsents: {
///     MetricGroup.essential: ConsentState.granted,
///     MetricGroup.measurements: ConsentState.notAsked,
///     MetricGroup.vitals: ConsentState.denied,
///   },
///   consentVersion: 1,
///   acceptedAt: DateTime.now(),
///   ipAddress: '192.168.1.100',
/// );
/// ```
@freezed
abstract class UserConsent with _$UserConsent {
  const factory UserConsent({
    /// Unique consent record ID (UUID v4)
    required String id,

    /// User ID (Firebase Auth UID)
    required String userId,

    /// Consent state per metric group (Essential, Measurements, Vitals)
    ///
    /// **Just-in-Time Consent Flow**:
    /// - Essential: Requested during onboarding (weight, body fat)
    /// - Measurements: Requested when user taps "Track Body Measurements"
    /// - Vitals: Requested when user taps "Track Vitals"
    ///
    /// **GDPR**: Implements Privacy by Design (Article 25)
    /// - Default state: ConsentState.notAsked
    /// - User explicitly grants or denies each group
    /// - No implicit consent (asking = not granted)
    required Map<MetricGroup, ConsentState> groupConsents,

    /// Privacy policy version accepted by user
    ///
    /// **GDPR**: When privacy policy updates, increment version.
    /// Users must re-consent to new policy version.
    ///
    /// Version history:
    /// - v1: Initial GDPR-compliant policy (2025-01-24)
    /// - v2: Future updates (prompt user to review and re-accept)
    required int consentVersion,

    /// When consent was granted (user's local time)
    required DateTime acceptedAt,

    /// IP address when consent was granted
    ///
    /// **GDPR Article 30**: Required for audit trail and compliance proof.
    /// Stored masked for privacy (last octet redacted: "192.168.1.***")
    required String ipAddress,

    /// When Essential metrics consent was granted
    /// (Separate timestamp for Just-in-Time consent tracking)
    DateTime? essentialGrantedAt,

    /// When Measurements group consent was granted
    DateTime? measurementsGrantedAt,

    /// When Vitals group consent was granted
    DateTime? vitalsGrantedAt,

    /// When this consent record was created
    DateTime? createdAt,

    /// When this consent record was last updated
    /// (e.g., user revoked consent for Vitals group)
    DateTime? updatedAt,

    /// Whether this consent has been revoked
    /// (Soft-delete: keep record for audit trail)
    @Default(false) bool isRevoked,

    /// When consent was revoked (if isRevoked = true)
    DateTime? revokedAt,

    /// User agent string (browser/app version)
    /// Example: "FitLog Pro/1.0.0 iOS/17.2 (iPhone 14 Pro)"
    String? userAgent,
  }) = _UserConsent;

  factory UserConsent.fromJson(Map<String, dynamic> json) =>
      _$UserConsentFromJson(json);
}

/// UserConsent extension methods
extension UserConsentX on UserConsent {
  /// Check if user has consented to a specific metric
  bool hasConsentFor(MetricType metric) {
    final group = metric.group;
    return groupConsents[group] == ConsentState.granted;
  }

  /// Get list of all consented metric types
  List<MetricType> get consentedMetrics {
    return MetricType.values.where((metric) {
      final group = metric.group;
      return groupConsents[group] == ConsentState.granted;
    }).toList();
  }

  /// Check if user has denied consent for a specific group
  bool hasDenied(MetricGroup group) {
    return groupConsents[group] == ConsentState.denied;
  }

  /// Check if user has not yet been asked for consent
  bool isNotAsked(MetricGroup group) {
    return groupConsents[group] == ConsentState.notAsked;
  }

  /// Create new consent with updated group consent state
  UserConsent grantConsentFor(MetricGroup group) {
    final updatedConsents = Map<MetricGroup, ConsentState>.from(groupConsents);
    updatedConsents[group] = ConsentState.granted;

    final now = DateTime.now();
    return copyWith(
      groupConsents: updatedConsents,
      updatedAt: now,
      essentialGrantedAt: group == MetricGroup.essential
          ? now
          : essentialGrantedAt,
      measurementsGrantedAt: group == MetricGroup.measurements
          ? now
          : measurementsGrantedAt,
      vitalsGrantedAt: group == MetricGroup.vitals ? now : vitalsGrantedAt,
    );
  }

  /// Revoke consent for a specific group
  UserConsent revokeConsentFor(MetricGroup group) {
    final updatedConsents = Map<MetricGroup, ConsentState>.from(groupConsents);
    updatedConsents[group] = ConsentState.denied;

    return copyWith(groupConsents: updatedConsents, updatedAt: DateTime.now());
  }
}

/// ConsentState - State of user consent for a metric group
///
/// **GDPR Compliance**: Three-state model enforces explicit opt-in
/// - notAsked: Default state (no consent dialog shown)
/// - denied: User explicitly declined (respect choice, don't re-prompt)
/// - granted: User explicitly accepted (can revoke anytime)
///
/// **Important**: `notAsked != granted`
/// - Never assume consent without explicit user action
/// - Asking the question ≠ receiving consent
enum ConsentState {
  /// User has not yet been asked for consent
  /// (Default state, no consent dialog shown)
  notAsked,

  /// User explicitly declined consent
  /// (Respect choice, don't re-prompt immediately)
  denied,

  /// User explicitly granted consent
  /// (Can be revoked anytime via privacy settings)
  granted,
}

/// AuditLog - Domain entity for audit trail logging
///
/// Implements GDPR Article 30 (Records of processing activities):
/// - Log all data processing operations
/// - Include: who, what, when, where
/// - Tamper-evident (hash chain verification)
/// - 2-year retention for compliance
///
/// **GDPR Compliance**:
/// - Complete audit trail of all data operations
/// - User can view their own audit logs
/// - Logs are immutable (no edits, only append)
/// - Integrity verification via hash chain
///
/// Example:
/// ```dart
/// final log = AuditLog(
///   id: 'audit-123',
///   userId: 'user-456',
///   action: AuditAction.dataAccess,
///   timestamp: DateTime.now(),
///   ipAddress: '192.168.1.***',
///   affectedMetrics: [MetricType.weight, MetricType.bodyFat],
///   previousHash: 'abc123...',
/// );
/// ```
@freezed
abstract class AuditLog with _$AuditLog {
  const factory AuditLog({
    /// Unique audit log ID (UUID v4)
    required String id,

    /// User ID (Firebase Auth UID)
    required String userId,

    /// Action that was performed
    required AuditAction action,

    /// When action occurred (UTC timestamp)
    required DateTime timestamp,

    /// IP address where action originated
    /// (Masked for privacy: "192.168.1.***")
    required String ipAddress,

    /// List of metrics affected by this action
    /// (e.g., [MetricType.weight] for "dataAccess" action)
    List<MetricType>? affectedMetrics,

    /// Action details (e.g., "Exported 150 measurements to JSON")
    String? actionDetails,

    /// Previous log entry hash (for tamper-evidence chain)
    ///
    /// **Integrity Verification**:
    /// - Each log has hash = SHA256(previousHash + userId + action + timestamp)
    /// - First log has previousHash = "GENESIS"
    /// - Chain verification detects tampered/deleted logs
    String? previousHash,

    /// Hash of this log entry (SHA256)
    /// Computed as: SHA256(previousHash + userId + action + timestamp)
    String? hash,

    /// User agent (browser/app version)
    String? userAgent,

    /// Platform (iOS, Android, Web)
    String? platform,

    /// App version when action occurred
    String? appVersion,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);
}

/// AuditAction - Type of action logged in audit trail
enum AuditAction {
  /// User accessed/viewed measurement data
  dataAccess,

  /// User exported data (JSON, CSV, PDF)
  dataExport,

  /// User deleted measurement data (soft-delete or permanent)
  dataDelete,

  /// User granted or revoked consent
  consentChange,

  /// Measurement created (manual entry or health platform sync)
  measurementCreated,

  /// Measurement updated (value modified)
  measurementUpdated,

  /// Health platform sync completed (HealthKit or Health Connect)
  healthPlatformSync,

  /// Encryption key rotated (90-day rotation policy)
  keyRotation,

  /// Privacy policy accepted (initial or updated version)
  privacyPolicyAccepted,
}

/// PermissionScope - Deprecated (kept for migration compatibility)
///
/// **Note**: This enum is no longer used in v1.0.
/// Granular consent now uses MetricGroup (Essential, Measurements, Vitals).
///
/// Kept in codebase for backwards compatibility with old consent records.
/// Will be removed in future version after data migration.
@Deprecated('Use MetricGroup instead')
enum PermissionScope {
  @Deprecated('Use MetricGroup.essential')
  perMetricGranularity,
}
