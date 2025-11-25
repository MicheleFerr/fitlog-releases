import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';

/// ConsentRepository - Abstract interface for consent management
///
/// Implements GDPR Article 7 (Conditions for Consent) and
/// Article 25 (Privacy by Design and by Default).
///
/// **Key Responsibilities**:
/// - Consent CRUD operations (Create, Read, Update, Delete)
/// - Consent enforcement (block data access if no consent)
/// - Version tracking (privacy policy updates require re-consent)
/// - Audit logging (all consent changes logged)
/// - Just-in-Time consent prompting
///
/// **GDPR Compliance**:
/// - Explicit opt-in: User must actively grant consent
/// - Granular control: Per-metric-group consent (Essential, Measurements, Vitals)
/// - Revocable: User can withdraw consent anytime
/// - Audit trail: All consent changes logged with timestamp + IP
/// - Version management: Privacy policy updates trigger re-consent
///
/// **Usage Example**:
/// ```dart
/// // Check if user has consent for a metric
/// final hasConsent = await consentRepository
///   .hasConsentFor(userId, MetricType.weight);
///
/// if (!hasConsent) {
///   // Show Just-in-Time consent dialog
///   final granted = await showConsentDialog(MetricGroup.essential);
///   if (granted) {
///     await consentRepository.grantConsent(
///       userId,
///       MetricGroup.essential,
///     );
///   }
/// }
///
/// // Save measurement (only if consent granted)
/// await measurementRepository.saveMeasurement(measurement);
/// ```
abstract class ConsentRepository {
  /// Get user's consent record
  ///
  /// Returns:
  /// - Right(UserConsent): Consent record exists
  /// - Left(ConsentNotFoundFailure): No consent record (first time user)
  /// - Left(FirebaseFailure): Firebase read error
  ///
  /// **GDPR Article 7**: User must explicitly grant consent.
  /// Absence of consent = no data access allowed.
  Future<Either<ConsentFailure, UserConsent>> getConsent(String userId);

  /// Create initial consent record (onboarding)
  ///
  /// Called when user first opens the app and accepts privacy policy.
  ///
  /// **Initial State**: All consent groups set to ConsentState.notAsked
  /// (user hasn't been prompted yet, Just-in-Time consent flow)
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - ipAddress: User's IP (masked: "192.168.1.***")
  /// - userAgent: Browser/app version
  ///
  /// Returns:
  /// - Right(UserConsent): Consent record created successfully
  /// - Left(ConsentAlreadyExistsFailure): User already has consent
  /// - Left(FirebaseFailure): Firebase write error
  ///
  /// **GDPR Article 30**: Audit log entry created for initial consent.
  Future<Either<ConsentFailure, UserConsent>> createInitialConsent({
    required String userId,
    required String ipAddress,
    String? userAgent,
  });

  /// Grant consent for a metric group
  ///
  /// Called when user explicitly accepts consent in Just-in-Time dialog.
  ///
  /// **State Transition**: ConsentState.notAsked → ConsentState.granted
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - group: MetricGroup to grant consent for
  /// - ipAddress: User's IP (for audit trail)
  ///
  /// Returns:
  /// - Right(UserConsent): Updated consent record
  /// - Left(ConsentNotFoundFailure): No existing consent record
  /// - Left(FirebaseFailure): Firebase write error
  ///
  /// **GDPR Article 7**: Explicit opt-in. User actively checked checkbox.
  /// **GDPR Article 30**: Audit log entry created with timestamp + IP.
  Future<Either<ConsentFailure, UserConsent>> grantConsent({
    required String userId,
    required MetricGroup group,
    required String ipAddress,
    String? userAgent,
  });

  /// Revoke consent for a metric group
  ///
  /// Called when user withdraws consent via privacy settings.
  ///
  /// **State Transition**: ConsentState.granted → ConsentState.denied
  ///
  /// **Effect**: All measurements for this metric group will be:
  /// - Hidden from UI (read blocked by Firestore rules)
  /// - Scheduled for deletion after 30 days (soft-delete)
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - group: MetricGroup to revoke consent for
  /// - ipAddress: User's IP (for audit trail)
  ///
  /// Returns:
  /// - Right(UserConsent): Updated consent record
  /// - Left(ConsentNotFoundFailure): No existing consent record
  /// - Left(FirebaseFailure): Firebase write error
  ///
  /// **GDPR Article 7(3)**: User can withdraw consent anytime.
  /// **GDPR Article 17**: Right to Erasure (data deleted after revoke).
  /// **GDPR Article 30**: Audit log entry created.
  Future<Either<ConsentFailure, UserConsent>> revokeConsent({
    required String userId,
    required MetricGroup group,
    required String ipAddress,
    String? userAgent,
  });

  /// Check if user has consented to a specific metric
  ///
  /// **Consent Enforcement**: This is called BEFORE any measurement
  /// read/write operation to enforce GDPR compliance.
  ///
  /// Flow:
  /// 1. Check consent record exists
  /// 2. Get metric's group (Essential/Measurements/Vitals)
  /// 3. Check if consent.groupConsents[group] == ConsentState.granted
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - metric: MetricType to check (e.g., MetricType.weight)
  ///
  /// Returns:
  /// - Right(true): User has granted consent for this metric
  /// - Right(false): User has NOT granted consent (or denied/notAsked)
  /// - Left(ConsentNotFoundFailure): No consent record exists
  /// - Left(FirebaseFailure): Firebase read error
  ///
  /// **GDPR Article 6**: Legal basis for processing. No consent = no access.
  Future<Either<ConsentFailure, bool>> hasConsentFor(
    String userId,
    MetricType metric,
  );

  /// Update consent version (privacy policy change)
  ///
  /// Called when privacy policy is updated and user must re-consent.
  ///
  /// **Version Upgrade Flow**:
  /// 1. Privacy policy updated (v1 → v2)
  /// 2. User opens app → prompt "Privacy policy updated, please review"
  /// 3. User accepts → call updateConsentVersion()
  /// 4. Consent version incremented, acceptedAt updated
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - newVersion: New privacy policy version number
  /// - ipAddress: User's IP (for audit trail)
  ///
  /// Returns:
  /// - Right(UserConsent): Updated consent record with new version
  /// - Left(ConsentNotFoundFailure): No existing consent record
  /// - Left(InvalidVersionFailure): newVersion <= currentVersion
  /// - Left(FirebaseFailure): Firebase write error
  ///
  /// **GDPR Article 7(4)**: User must be informed of changes and re-consent.
  Future<Either<ConsentFailure, UserConsent>> updateConsentVersion({
    required String userId,
    required int newVersion,
    required String ipAddress,
    String? userAgent,
  });

  /// Delete consent record (account deletion)
  ///
  /// Called when user deletes their account (GDPR Right to Erasure).
  ///
  /// **Effect**:
  /// - Consent record deleted from Firestore
  /// - Audit log entry created (permanent record of deletion)
  /// - All measurements deleted (cascading delete)
  ///
  /// **Note**: Audit logs are retained for 2 years (GDPR Article 30)
  /// even after account deletion for compliance proof.
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  ///
  /// Returns:
  /// - Right(void): Consent deleted successfully
  /// - Left(ConsentNotFoundFailure): No consent record to delete
  /// - Left(FirebaseFailure): Firebase delete error
  ///
  /// **GDPR Article 17**: Right to Erasure. User can request data deletion.
  Future<Either<ConsentFailure, void>> deleteConsent(String userId);

  /// Get list of all consented metrics
  ///
  /// Returns list of MetricType values that user has granted consent for.
  ///
  /// **Usage**: Filter measurement list based on consent.
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  ///
  /// Returns:
  /// - Right(List<MetricType>): List of consented metrics
  /// - Left(ConsentNotFoundFailure): No consent record
  /// - Left(FirebaseFailure): Firebase read error
  ///
  /// Example:
  /// ```dart
  /// final consentedMetrics = await getConsentedMetrics('user-123');
  /// consentedMetrics.fold(
  ///   (failure) => showError(failure),
  ///   (metrics) => print('Consented: $metrics'),
  /// );
  /// // Output: Consented: [MetricType.weight, MetricType.bodyFat]
  /// ```
  Future<Either<ConsentFailure, List<MetricType>>> getConsentedMetrics(
    String userId,
  );

  /// Check if user needs to re-consent (privacy policy updated)
  ///
  /// Called on app launch to check if consent is outdated.
  ///
  /// **Outdated Consent Detection**:
  /// - Current privacy policy version: 1
  /// - User's consent version: 1
  /// - Result: false (up to date)
  ///
  /// - Current privacy policy version: 2
  /// - User's consent version: 1
  /// - Result: true (needs re-consent)
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - currentPolicyVersion: Latest privacy policy version
  ///
  /// Returns:
  /// - Right(true): User needs to re-consent (outdated)
  /// - Right(false): Consent is up to date
  /// - Left(ConsentNotFoundFailure): No consent record
  /// - Left(FirebaseFailure): Firebase read error
  Future<Either<ConsentFailure, bool>> needsReConsent({
    required String userId,
    required int currentPolicyVersion,
  });
}

/// ConsentFailure - Error types for consent operations
sealed class ConsentFailure {
  const ConsentFailure();
}

/// Consent record not found (user hasn't created consent yet)
class ConsentNotFoundFailure extends ConsentFailure {
  const ConsentNotFoundFailure();
}

/// Consent record already exists (duplicate creation attempt)
class ConsentAlreadyExistsFailure extends ConsentFailure {
  const ConsentAlreadyExistsFailure();
}

/// Invalid consent version (downgrade attempt)
class InvalidVersionFailure extends ConsentFailure {
  final int currentVersion;
  final int attemptedVersion;

  const InvalidVersionFailure({
    required this.currentVersion,
    required this.attemptedVersion,
  });
}

/// Firebase operation failed (network, permissions, etc.)
class FirebaseConsentFailure extends ConsentFailure {
  final String message;
  final String? code;

  const FirebaseConsentFailure({
    required this.message,
    this.code,
  });
}

/// Rate limit exceeded (too many consent changes)
///
/// **GDPR Article 32**: Rate limiting prevents abuse.
/// Max 10 consent changes per day per user.
class RateLimitExceededFailure extends ConsentFailure {
  final int limitPerDay;
  final int currentCount;

  const RateLimitExceededFailure({
    required this.limitPerDay,
    required this.currentCount,
  });
}
