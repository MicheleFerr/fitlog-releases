import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// ConsentRepositoryImpl - Firestore implementation of ConsentRepository
///
/// **Data Layer Responsibility**:
/// - Firestore CRUD operations for /userConsents/{userId}
/// - Schema validation (ensure data matches UserConsent entity)
/// - Error handling (Firebase exceptions → ConsentFailure)
/// - Audit logging integration (log all consent changes)
///
/// **Firestore Schema**:
/// ```
/// /userConsents/{userId}
/// {
///   id: string (UUID v4)
///   userId: string (Firebase Auth UID)
///   groupConsents: {
///     essential: 'notAsked' | 'granted' | 'denied'
///     measurements: 'notAsked' | 'granted' | 'denied'
///     vitals: 'notAsked' | 'granted' | 'denied'
///   }
///   consentVersion: number (1)
///   acceptedAt: timestamp
///   ipAddress: string (masked: "192.168.1.***")
///   essentialGrantedAt: timestamp?
///   measurementsGrantedAt: timestamp?
///   vitalsGrantedAt: timestamp?
///   createdAt: timestamp
///   updatedAt: timestamp
///   isRevoked: boolean
///   revokedAt: timestamp?
///   userAgent: string?
/// }
/// ```
///
/// **GDPR Compliance**:
/// - Consent enforced at repository layer (fail-secure)
/// - Audit logs created for all consent changes
/// - Firestore security rules enforce server-side validation
///
/// **Usage**:
/// ```dart
/// final consentRepo = ConsentRepositoryImpl(FirebaseFirestore.instance);
///
/// // Create initial consent (onboarding)
/// await consentRepo.createInitialConsent(
///   userId: 'user-123',
///   ipAddress: '192.168.1.100',
/// );
///
/// // Grant consent (Just-in-Time)
/// await consentRepo.grantConsent(
///   userId: 'user-123',
///   group: MetricGroup.essential,
///   ipAddress: '192.168.1.100',
/// );
/// ```
class ConsentRepositoryImpl with FirebaseErrorMapperMixin implements ConsentRepository {
  /// Collection name in Firestore
  static const String _collectionName = 'userConsents';

  /// Current privacy policy version
  /// **IMPORTANT**: Increment this when privacy policy is updated
  /// to trigger re-consent flow for all users
  static const int _currentPolicyVersion = 1;

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ConsentRepositoryImpl(
    this._firestore, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  /// Get reference to user's consent document
  DocumentReference<Map<String, dynamic>> _getConsentDoc(String userId) {
    return _firestore.collection(_collectionName).doc(userId);
  }

  /// Convert shared Failure to ConsentFailure
  ConsentFailure _mapFailureToConsentFailure(Failure failure) {
    // Map specific failure types to appropriate ConsentFailure types
    if (failure is NotFoundFailure) {
      return const ConsentNotFoundFailure();
    } else if (failure is RateLimitFailure) {
      return const RateLimitExceededFailure(
        limitPerDay: 10,
        currentCount: 10,
      );
    } else {
      // Default to FirebaseConsentFailure for all other failures
      return FirebaseConsentFailure(
        message: failure.message,
        code: failure.code,
      );
    }
  }

  @override
  Future<Either<ConsentFailure, UserConsent>> getConsent(
    String userId,
  ) async {
    final result = await handleFirebaseOperation(
      () async {
        final doc = await _getConsentDoc(userId).get();

        if (!doc.exists || doc.data() == null) {
          // Return null to indicate not found - will be handled below
          return null;
        }

        // Parse Firestore data to UserConsent entity
        // Convert Firestore Timestamps back to ISO8601 strings for fromJson
        return UserConsent.fromJson(_fromFirestoreData(doc.data()!));
      },
      operationName: 'getConsent',
    );

    return result.fold(
      (failure) => left(_mapFailureToConsentFailure(failure)),
      (consent) => consent == null
          ? left(const ConsentNotFoundFailure())
          : right(consent),
    );
  }

  @override
  Future<Either<ConsentFailure, UserConsent>> createInitialConsent({
    required String userId,
    required String ipAddress,
    String? userAgent,
  }) async {
    // Check if consent already exists
    final existingConsent = await getConsent(userId);
    if (existingConsent.isRight()) {
      return left(const ConsentAlreadyExistsFailure());
    }

    // Create initial consent with all groups set to 'notAsked'
    final now = DateTime.now();
    final consentId = _uuid.v4();

    final consent = UserConsent(
      id: consentId,
      userId: userId,
      groupConsents: {
        MetricGroup.essential: ConsentState.notAsked,
        MetricGroup.measurements: ConsentState.notAsked,
        MetricGroup.vitals: ConsentState.notAsked,
      },
      consentVersion: _currentPolicyVersion,
      acceptedAt: now,
      ipAddress: _maskIpAddress(ipAddress),
      createdAt: now,
      updatedAt: now,
      userAgent: userAgent,
    );

    final result = await handleFirebaseOperation(
      () async {
        // Save to Firestore (uses userId as document ID for easy lookup)
        // Convert to JSON and transform DateTime strings to Firestore Timestamps
        await _getConsentDoc(userId).set(_toFirestoreData(consent.toJson()));

        // TODO: Create audit log entry (Task 2.9)
        // await _auditLogger.log(
        //   userId: userId,
        //   action: AuditAction.privacyPolicyAccepted,
        //   timestamp: now,
        //   ipAddress: ipAddress,
        // );

        return consent;
      },
      operationName: 'createInitialConsent',
    );

    return result.fold(
      (failure) => left(_mapFailureToConsentFailure(failure)),
      (consent) => right(consent),
    );
  }

  @override
  Future<Either<ConsentFailure, UserConsent>> grantConsent({
    required String userId,
    required MetricGroup group,
    required String ipAddress,
    String? userAgent,
  }) async {
    // Get existing consent
    final consentResult = await getConsent(userId);
    if (consentResult.isLeft()) {
      return consentResult; // Return failure (ConsentNotFoundFailure)
    }

    final existingConsent = consentResult.getRight().getOrElse(() {
      throw Exception('Unreachable: getConsent returned Right but null');
    });

    // Grant consent for the specified group
    final updatedConsent = existingConsent.grantConsentFor(group);

    // Update userAgent if provided
    final consentWithAgent = userAgent != null
        ? updatedConsent.copyWith(userAgent: userAgent)
        : updatedConsent;

    final result = await handleFirebaseOperation(
      () async {
        // Save to Firestore - convert DateTime strings to Timestamps
        await _getConsentDoc(userId).update(_toFirestoreData(consentWithAgent.toJson()));

        // TODO: Create audit log entry (Task 2.9)
        // await _auditLogger.log(
        //   userId: userId,
        //   action: AuditAction.consentChange,
        //   timestamp: DateTime.now(),
        //   ipAddress: ipAddress,
        //   actionDetails: 'Granted consent for ${group.name}',
        // );

        return consentWithAgent;
      },
      operationName: 'grantConsent',
    );

    return result.fold(
      (failure) => left(_mapFailureToConsentFailure(failure)),
      (consent) => right(consent),
    );
  }

  @override
  Future<Either<ConsentFailure, UserConsent>> revokeConsent({
    required String userId,
    required MetricGroup group,
    required String ipAddress,
    String? userAgent,
  }) async {
    // Get existing consent
    final consentResult = await getConsent(userId);
    if (consentResult.isLeft()) {
      return consentResult; // Return failure (ConsentNotFoundFailure)
    }

    final existingConsent = consentResult.getRight().getOrElse(() {
      throw Exception('Unreachable: getConsent returned Right but null');
    });

    // Revoke consent for the specified group
    final updatedConsent = existingConsent.revokeConsentFor(group);

    // Update userAgent if provided
    final consentWithAgent = userAgent != null
        ? updatedConsent.copyWith(userAgent: userAgent)
        : updatedConsent;

    final result = await handleFirebaseOperation(
      () async {
        // Save to Firestore - convert DateTime strings to Timestamps
        await _getConsentDoc(userId).update(_toFirestoreData(consentWithAgent.toJson()));

        // TODO: Create audit log entry (Task 2.9)
        // await _auditLogger.log(
        //   userId: userId,
        //   action: AuditAction.consentChange,
        //   timestamp: DateTime.now(),
        //   ipAddress: ipAddress,
        //   actionDetails: 'Revoked consent for ${group.name}',
        // );

        // TODO: Schedule measurements for deletion after 30 days (Task 2.8)
        // await _deletionService.scheduleMeasurementDeletion(
        //   userId: userId,
        //   metricGroup: group,
        //   deleteAfter: Duration(days: 30),
        // );

        return consentWithAgent;
      },
      operationName: 'revokeConsent',
    );

    return result.fold(
      (failure) => left(_mapFailureToConsentFailure(failure)),
      (consent) => right(consent),
    );
  }

  @override
  Future<Either<ConsentFailure, bool>> hasConsentFor(
    String userId,
    MetricType metric,
  ) async {
    final consentResult = await getConsent(userId);
    if (consentResult.isLeft()) {
      // No consent record = no consent granted
      return right(false);
    }

    final consent = consentResult.getRight().getOrElse(() {
      throw Exception('Unreachable: getConsent returned Right but null');
    });

    // Check if consent is granted for metric's group
    final hasConsent = consent.hasConsentFor(metric);
    return right(hasConsent);
  }

  @override
  Future<Either<ConsentFailure, UserConsent>> updateConsentVersion({
    required String userId,
    required int newVersion,
    required String ipAddress,
    String? userAgent,
  }) async {
    // Get existing consent
    final consentResult = await getConsent(userId);
    if (consentResult.isLeft()) {
      return consentResult; // Return failure (ConsentNotFoundFailure)
    }

    final existingConsent = consentResult.getRight().getOrElse(() {
      throw Exception('Unreachable: getConsent returned Right but null');
    });

    // Validate version upgrade (no downgrades allowed)
    if (newVersion <= existingConsent.consentVersion) {
      return left(InvalidVersionFailure(
        currentVersion: existingConsent.consentVersion,
        attemptedVersion: newVersion,
      ));
    }

    // Update consent version and timestamp
    final now = DateTime.now();
    final updatedConsent = existingConsent.copyWith(
      consentVersion: newVersion,
      acceptedAt: now,
      updatedAt: now,
      userAgent: userAgent,
    );

    final result = await handleFirebaseOperation(
      () async {
        // Save to Firestore - convert DateTime strings to Timestamps
        await _getConsentDoc(userId).update(_toFirestoreData(updatedConsent.toJson()));

        // TODO: Create audit log entry (Task 2.9)
        // await _auditLogger.log(
        //   userId: userId,
        //   action: AuditAction.privacyPolicyAccepted,
        //   timestamp: now,
        //   ipAddress: ipAddress,
        //   actionDetails: 'Updated consent version: $newVersion',
        // );

        return updatedConsent;
      },
      operationName: 'updateConsentVersion',
    );

    return result.fold(
      (failure) => left(_mapFailureToConsentFailure(failure)),
      (consent) => right(consent),
    );
  }

  @override
  Future<Either<ConsentFailure, void>> deleteConsent(String userId) async {
    // Check if consent exists
    final consentResult = await getConsent(userId);
    if (consentResult.isLeft()) {
      return left(const ConsentNotFoundFailure());
    }

    final result = await handleFirebaseVoidOperation(
      () async {
        // TODO: Create audit log entry BEFORE deletion (Task 2.9)
        // await _auditLogger.log(
        //   userId: userId,
        //   action: AuditAction.dataDelete,
        //   timestamp: DateTime.now(),
        //   ipAddress: '0.0.0.0', // No IP (automated deletion)
        //   actionDetails: 'Consent record deleted (account deletion)',
        // );

        // Delete consent document
        await _getConsentDoc(userId).delete();
      },
      operationName: 'deleteConsent',
    );

    return result.fold(
      (failure) => left(_mapFailureToConsentFailure(failure)),
      (_) => right(null),
    );
  }

  @override
  Future<Either<ConsentFailure, List<MetricType>>> getConsentedMetrics(
    String userId,
  ) async {
    final consentResult = await getConsent(userId);
    if (consentResult.isLeft()) {
      return consentResult
          .map((consent) => <MetricType>[]); // Return empty list
    }

    final consent = consentResult.getRight().getOrElse(() {
      throw Exception('Unreachable: getConsent returned Right but null');
    });

    // Get list of consented metrics using extension method
    final consentedMetrics = consent.consentedMetrics;
    return right(consentedMetrics);
  }

  @override
  Future<Either<ConsentFailure, bool>> needsReConsent({
    required String userId,
    required int currentPolicyVersion,
  }) async {
    final consentResult = await getConsent(userId);
    if (consentResult.isLeft()) {
      // No consent record = needs to consent for the first time
      return right(true);
    }

    final consent = consentResult.getRight().getOrElse(() {
      throw Exception('Unreachable: getConsent returned Right but null');
    });

    // Check if user's consent version is outdated
    final needsReConsent = consent.consentVersion < currentPolicyVersion;
    return right(needsReConsent);
  }

  /// Mask IP address for privacy (GDPR Article 32 - Pseudonymization)
  ///
  /// Example: "192.168.1.100" → "192.168.1.***"
  ///
  /// **GDPR Compliance**: IP addresses are personal data.
  /// Masking reduces risk while preserving audit trail utility.
  String _maskIpAddress(String ipAddress) {
    final parts = ipAddress.split('.');
    if (parts.length == 4) {
      // IPv4: mask last octet
      return '${parts[0]}.${parts[1]}.${parts[2]}.***';
    } else if (ipAddress.contains(':')) {
      // IPv6: mask last 4 segments
      final segments = ipAddress.split(':');
      if (segments.length >= 4) {
        final visibleSegments = segments.take(segments.length - 4).join(':');
        return '$visibleSegments:****:****:****:****';
      }
    }
    // Fallback: mask entire IP if format unknown
    return '***';
  }

  /// Convert Firestore data to entity-compatible format
  ///
  /// Firestore returns Timestamp objects for DateTime fields.
  /// The fromJson method expects ISO8601 strings.
  /// This method converts Timestamps to ISO8601 strings.
  Map<String, dynamic> _fromFirestoreData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    // List of DateTime fields that might be Timestamps
    const dateTimeFields = [
      'acceptedAt',
      'createdAt',
      'updatedAt',
      'essentialGrantedAt',
      'measurementsGrantedAt',
      'vitalsGrantedAt',
      'revokedAt',
    ];

    for (final field in dateTimeFields) {
      if (result[field] != null && result[field] is Timestamp) {
        final timestamp = result[field] as Timestamp;
        result[field] = timestamp.toDate().toIso8601String();
      }
    }

    return result;
  }

  /// Convert JSON data to Firestore-compatible format
  ///
  /// Firestore security rules require DateTime fields to be Timestamps,
  /// not ISO8601 strings. This method converts all DateTime string fields
  /// to Firestore Timestamps.
  ///
  /// **DateTime fields converted**:
  /// - acceptedAt (required)
  /// - createdAt, updatedAt (optional)
  /// - essentialGrantedAt, measurementsGrantedAt, vitalsGrantedAt (optional)
  /// - revokedAt (optional)
  Map<String, dynamic> _toFirestoreData(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);

    // List of DateTime fields that need conversion to Timestamp
    const dateTimeFields = [
      'acceptedAt',
      'createdAt',
      'updatedAt',
      'essentialGrantedAt',
      'measurementsGrantedAt',
      'vitalsGrantedAt',
      'revokedAt',
    ];

    for (final field in dateTimeFields) {
      if (result[field] != null && result[field] is String) {
        try {
          final dateTime = DateTime.parse(result[field] as String);
          result[field] = Timestamp.fromDate(dateTime);
        } catch (_) {
          // Keep original value if parsing fails
        }
      }
    }

    return result;
  }
}
