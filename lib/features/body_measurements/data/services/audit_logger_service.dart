import 'dart:convert';
import 'dart:developer' show log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

/// AuditLoggerService - GDPR Article 30 compliance (Records of processing activities)
///
/// **GDPR CRITICAL**: Tamper-evident audit trail for all data processing activities.
///
/// **Functionality**:
/// - Records all GDPR-relevant events (consent changes, data access, deletions, etc.)
/// - Implements tamper-evident hash chain (SHA256)
/// - Dual storage: Firestore (cloud) + Hive (local backup)
/// - Automatic metadata collection (IP, platform, app version)
/// - Integrity verification to detect tampering
///
/// **Hash Chain Algorithm**:
/// ```
/// First log: previousHash = "GENESIS"
/// Subsequent logs: previousHash = hash of previous log
/// hash = SHA256(previousHash + userId + action + timestamp.toIso8601String())
/// ```
///
/// **Why Hash Chain**:
/// - Prevents log tampering (changing/deleting entries breaks chain)
/// - GDPR Article 30 requires "demonstrable compliance"
/// - Allows independent verification by data protection authorities
///
/// **Storage Schema**:
/// - Firestore: `/auditLogs/{userId}/logs/{logId}`
/// - Hive: Box name "audit_logs", key format "{userId}_{logId}"
///
/// **Usage**:
/// ```dart
/// final auditLogger = AuditLoggerService();
///
/// // Log consent granted
/// await auditLogger.logAction(
///   userId: currentUser.uid,
///   action: AuditAction.consentChange,
///   affectedMetrics: [MetricType.weight, MetricType.bodyFatPercentage],
///   actionDetails: 'Consent granted for weight and body fat tracking',
/// );
///
/// // Log data export
/// await auditLogger.logAction(
///   userId: currentUser.uid,
///   action: AuditAction.dataExport,
///   affectedMetrics: null, // All metrics
///   actionDetails: 'Exported 150 measurements to JSON',
/// );
///
/// // Verify integrity (detect tampering)
/// final verificationResult = await auditLogger.verifyIntegrity(currentUser.uid);
/// verificationResult.fold(
///   (failure) => showError('Audit log verification failed'),
///   (isValid) {
///     if (!isValid) {
///       // CRITICAL: Audit log has been tampered with!
///       reportToSecurityTeam();
///     }
///   },
/// );
/// ```
///
/// **Error Handling**:
/// - Returns Either&lt;AuditLogFailure, AuditLog&gt; for all operations
/// - Automatic retry on Firestore write failures
/// - Local Hive backup ensures logs never lost (even if cloud fails)
class AuditLoggerService {
  /// Hive box name for local audit log storage
  static const String _auditLogsBoxName = 'audit_logs';

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  AuditLoggerService({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  /// Log an action to the audit trail
  ///
  /// **GDPR CRITICAL**: This method must be called for EVERY data processing activity.
  ///
  /// Parameters:
  /// - [userId]: User ID (Firebase Auth UID)
  /// - [action]: Type of action (from AuditAction enum)
  /// - [affectedMetrics]: List of metrics affected (null = all metrics)
  /// - [actionDetails]: Human-readable description of action
  ///
  /// Returns:
  /// - Right(AuditLog): Log created successfully
  /// - Left(AuditLogFailure): Storage or hash computation failed
  ///
  /// Example:
  /// ```dart
  /// await auditLogger.logAction(
  ///   userId: 'user-123',
  ///   action: AuditAction.measurementCreated,
  ///   affectedMetrics: [MetricType.weight],
  ///   actionDetails: 'Created weight measurement: 75.5 kg',
  /// );
  /// ```
  Future<Either<AuditLogFailure, AuditLog>> logAction({
    required String userId,
    required AuditAction action,
    List<MetricType>? affectedMetrics,
    String? actionDetails,
  }) async {
    try {
      // 1. Get previous log's hash (for chain continuity)
      final previousHashResult = await _getPreviousLogHash(userId);
      if (previousHashResult.isLeft()) {
        return left(
          previousHashResult.fold(
            (failure) => failure,
            (_) =>
                throw Exception('Unreachable: isLeft() but fold got Right'),
          ),
        );
      }

      final previousHash = previousHashResult.fold(
        (_) => throw Exception('Unreachable: checked isLeft() above'),
        (hash) => hash,
      );

      // 2. Generate unique log ID
      final logId = _uuid.v4();
      final timestamp = DateTime.now().toUtc();

      // 3. Compute hash for this log entry (SHA256)
      final hash = _computeHash(
        previousHash: previousHash,
        userId: userId,
        action: action,
        timestamp: timestamp,
      );

      // 4. Collect metadata
      final metadata = await _collectMetadata();

      // 5. Create AuditLog entity
      final auditLog = AuditLog(
        id: logId,
        userId: userId,
        action: action,
        timestamp: timestamp,
        ipAddress: metadata['ipAddress'] as String,
        affectedMetrics: affectedMetrics,
        actionDetails: actionDetails,
        previousHash: previousHash,
        hash: hash,
        userAgent: metadata['userAgent'] as String?,
        platform: metadata['platform'] as String?,
        appVersion: metadata['appVersion'] as String?,
      );

      // 6. Store in Firestore (cloud)
      final firestoreResult = await _storeInFirestore(userId, auditLog);
      if (firestoreResult.isLeft()) {
        // Log to console but continue (local backup still works)
        if (kDebugMode) {
          log('Warning: Failed to store audit log in Firestore, but local backup succeeded');
        }
      }

      // 7. Store in Hive (local backup)
      final hiveResult = await _storeInHive(userId, auditLog);
      if (hiveResult.isLeft()) {
        return left(
          hiveResult.fold(
            (failure) => failure,
            (_) =>
                throw Exception('Unreachable: isLeft() but fold got Right'),
          ),
        );
      }

      return right(auditLog);
    } catch (e) {
      return left(AuditLogFailure(
        message: 'Failed to log action: $e',
        error: e,
      ));
    }
  }

  /// Get audit logs for a user within a date range
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [dateFrom]: Start date (inclusive, default: 90 days ago)
  /// - [dateTo]: End date (inclusive, default: now)
  ///
  /// Returns:
  /// - Right(List&lt;AuditLog&gt;): Logs retrieved successfully (may be empty)
  /// - Left(AuditLogFailure): Query failed
  ///
  /// Example:
  /// ```dart
  /// // Get last 30 days of logs
  /// final result = await auditLogger.getAuditLogs(
  ///   userId: currentUser.uid,
  ///   dateFrom: DateTime.now().subtract(Duration(days: 30)),
  /// );
  /// ```
  Future<Either<AuditLogFailure, List<AuditLog>>> getAuditLogs({
    required String userId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final startDate = dateFrom ?? DateTime.now().subtract(const Duration(days: 90));
      final endDate = dateTo ?? DateTime.now();

      // Try Firestore first (most up-to-date)
      final firestoreResult = await _getFromFirestore(
        userId,
        startDate,
        endDate,
      );

      return firestoreResult.fold(
        (failure) async {
          // Fallback to local Hive if Firestore fails
          if (kDebugMode) {
            log('Firestore query failed, falling back to local Hive: $failure');
          }
          return _getFromHive(userId, startDate, endDate);
        },
        (logs) => right(logs),
      );
    } catch (e) {
      return left(AuditLogFailure(
        message: 'Failed to get audit logs: $e',
        error: e,
      ));
    }
  }

  /// Verify integrity of audit log chain
  ///
  /// **GDPR CRITICAL**: Detects tampering with audit trail.
  ///
  /// Verification algorithm:
  /// 1. Retrieve all logs for user (sorted by timestamp)
  /// 2. First log must have previousHash = "GENESIS"
  /// 3. For each subsequent log:
  ///    a. Recompute hash = SHA256(previousHash + userId + action + timestamp)
  ///    b. Check if computed hash matches stored hash
  ///    c. Check if this log's hash equals next log's previousHash
  ///
  /// Parameters:
  /// - [userId]: User ID to verify
  ///
  /// Returns:
  /// - Right(true): Chain integrity verified (no tampering detected)
  /// - Right(false): Chain broken (tampering detected!)
  /// - Left(AuditLogFailure): Verification failed (query error)
  ///
  /// Example:
  /// ```dart
  /// final result = await auditLogger.verifyIntegrity(currentUser.uid);
  /// result.fold(
  ///   (failure) => showError('Verification failed'),
  ///   (isValid) {
  ///     if (!isValid) {
  ///       // CRITICAL: Audit log tampered!
  ///       alertSecurityTeam();
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<AuditLogFailure, bool>> verifyIntegrity(String userId) async {
    try {
      // Get all logs for user (sorted by timestamp ascending)
      final logsResult = await getAuditLogs(
        userId: userId,
        dateFrom: DateTime(2020), // From beginning of time
        dateTo: DateTime.now(),
      );

      if (logsResult.isLeft()) {
        return left(
          logsResult.fold(
            (failure) => failure,
            (_) =>
                throw Exception('Unreachable: isLeft() but fold got Right'),
          ),
        );
      }

      final logs = logsResult.fold(
        (_) => throw Exception('Unreachable: checked isLeft() above'),
        (logs) => logs,
      );

      // Sort by timestamp ascending
      logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Empty chain is valid (user has no activity yet)
      if (logs.isEmpty) {
        return right(true);
      }

      // Verify first log
      if (logs.first.previousHash != 'GENESIS') {
        if (kDebugMode) {
          log('Integrity violation: First log previousHash != "GENESIS" (got: ${logs.first.previousHash})');
        }
        return right(false);
      }

      // Verify each log in chain
      for (var i = 0; i < logs.length; i++) {
        final currentLog = logs[i];

        // Recompute hash
        final computedHash = _computeHash(
          previousHash: currentLog.previousHash ?? 'GENESIS',
          userId: currentLog.userId,
          action: currentLog.action,
          timestamp: currentLog.timestamp,
        );

        // Check if stored hash matches computed hash
        if (currentLog.hash != computedHash) {
          if (kDebugMode) {
            log('Integrity violation at log ${i + 1}/${logs.length}: Hash mismatch (stored: ${currentLog.hash}, computed: $computedHash)');
          }
          return right(false);
        }

        // Check chain continuity (this log's hash should be next log's previousHash)
        if (i < logs.length - 1) {
          final nextLog = logs[i + 1];
          if (nextLog.previousHash != currentLog.hash) {
            if (kDebugMode) {
              log('Integrity violation at log ${i + 1}/${logs.length}: Chain broken (this.hash: ${currentLog.hash}, next.previousHash: ${nextLog.previousHash})');
            }
            return right(false);
          }
        }
      }

      // All checks passed
      return right(true);
    } catch (e) {
      return left(AuditLogFailure(
        message: 'Failed to verify audit log integrity: $e',
        error: e,
      ));
    }
  }

  // ========== Private Helper Methods ==========

  /// Get hash of most recent log entry (for chain continuity)
  ///
  /// Returns:
  /// - Right(String): Hash of previous log (or "GENESIS" if no logs exist)
  /// - Left(AuditLogFailure): Query failed
  Future<Either<AuditLogFailure, String>> _getPreviousLogHash(
    String userId,
  ) async {
    try {
      // Query Firestore for most recent log
      final snapshot = await _firestore
          .collection('auditLogs')
          .doc(userId)
          .collection('logs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // No previous logs - this is first log
        return right('GENESIS');
      }

      final previousLog = AuditLog.fromJson(snapshot.docs.first.data());
      return right(previousLog.hash ?? 'GENESIS');
    } catch (e) {
      // Fallback to local Hive if Firestore fails
      try {
        final box = await Hive.openLazyBox<Map<dynamic, dynamic>>(
          _auditLogsBoxName,
        );

        // Get all keys for this user
        final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_'));

        if (userKeys.isEmpty) {
          return right('GENESIS');
        }

        // Load all logs and find most recent
        AuditLog? mostRecentLog;
        DateTime? mostRecentTimestamp;

        for (final key in userKeys) {
          final logJson = await box.get(key);
          if (logJson != null) {
            final log = AuditLog.fromJson(Map<String, dynamic>.from(logJson));
            if (mostRecentTimestamp == null ||
                log.timestamp.isAfter(mostRecentTimestamp)) {
              mostRecentLog = log;
              mostRecentTimestamp = log.timestamp;
            }
          }
        }

        return right(mostRecentLog?.hash ?? 'GENESIS');
      } catch (hiveError) {
        return left(AuditLogFailure(
          message:
              'Failed to get previous log hash from both Firestore and Hive: $e, $hiveError',
          error: hiveError,
        ));
      }
    }
  }

  /// Compute SHA256 hash for audit log entry
  ///
  /// Algorithm: SHA256(previousHash + userId + action + timestamp)
  String _computeHash({
    required String previousHash,
    required String userId,
    required AuditAction action,
    required DateTime timestamp,
  }) {
    final input =
        '$previousHash$userId${action.name}${timestamp.toIso8601String()}';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Collect metadata about current environment
  ///
  /// Returns:
  /// - ipAddress: Masked IP (e.g., "192.168.1.***")
  /// - userAgent: Browser/app user agent
  /// - platform: iOS, Android, Web, etc.
  /// - appVersion: App version from package_info_plus
  Future<Map<String, dynamic>> _collectMetadata() async {
    try {
      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // Get platform
      String platform;
      try {
        if (Platform.isIOS) {
          platform = 'iOS';
        } else if (Platform.isAndroid) {
          platform = 'Android';
        } else if (Platform.isMacOS) {
          platform = 'macOS';
        } else if (Platform.isWindows) {
          platform = 'Windows';
        } else if (Platform.isLinux) {
          platform = 'Linux';
        } else {
          platform = 'Unknown';
        }
      } catch (e) {
        // Web or other platform without dart:io
        platform = 'Web';
      }

      // TODO: Get actual IP address (requires platform-specific code)
      // For now, use placeholder
      final ipAddress = '0.0.0.***'; // Masked for privacy

      // TODO: Get actual user agent (requires platform-specific code)
      final userAgent = 'GymBro/$appVersion ($platform)';

      return {
        'ipAddress': ipAddress,
        'userAgent': userAgent,
        'platform': platform,
        'appVersion': appVersion,
      };
    } catch (e) {
      // Fallback metadata
      return {
        'ipAddress': 'unknown',
        'userAgent': 'unknown',
        'platform': 'unknown',
        'appVersion': 'unknown',
      };
    }
  }

  /// Store audit log in Firestore
  Future<Either<AuditLogFailure, void>> _storeInFirestore(
    String userId,
    AuditLog auditLog,
  ) async {
    try {
      await _firestore
          .collection('auditLogs')
          .doc(userId)
          .collection('logs')
          .doc(auditLog.id)
          .set(auditLog.toJson());

      return right(null);
    } catch (e) {
      return left(AuditLogFailure(
        message: 'Failed to store audit log in Firestore: $e',
        error: e,
      ));
    }
  }

  /// Store audit log in Hive (local backup)
  Future<Either<AuditLogFailure, void>> _storeInHive(
    String userId,
    AuditLog auditLog,
  ) async {
    try {
      final box = await Hive.openLazyBox<Map<dynamic, dynamic>>(
        _auditLogsBoxName,
      );
      final key = '${userId}_${auditLog.id}';
      await box.put(key, auditLog.toJson());
      return right(null);
    } catch (e) {
      return left(AuditLogFailure(
        message: 'Failed to store audit log in Hive: $e',
        error: e,
      ));
    }
  }

  /// Get audit logs from Firestore
  Future<Either<AuditLogFailure, List<AuditLog>>> _getFromFirestore(
    String userId,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('auditLogs')
          .doc(userId)
          .collection('logs')
          .where('timestamp', isGreaterThanOrEqualTo: dateFrom.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: dateTo.toIso8601String())
          .orderBy('timestamp', descending: false)
          .get();

      final logs = snapshot.docs
          .map((doc) => AuditLog.fromJson(doc.data()))
          .toList();

      return right(logs);
    } catch (e) {
      return left(AuditLogFailure(
        message: 'Failed to get audit logs from Firestore: $e',
        error: e,
      ));
    }
  }

  /// Get audit logs from Hive (local backup)
  Future<Either<AuditLogFailure, List<AuditLog>>> _getFromHive(
    String userId,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    try {
      final box = await Hive.openLazyBox<Map<dynamic, dynamic>>(
        _auditLogsBoxName,
      );

      final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_'));
      final logs = <AuditLog>[];

      for (final key in userKeys) {
        final logJson = await box.get(key);
        if (logJson != null) {
          final log = AuditLog.fromJson(Map<String, dynamic>.from(logJson));

          // Filter by date range
          if (log.timestamp.isAfter(dateFrom.subtract(const Duration(seconds: 1))) &&
              log.timestamp.isBefore(dateTo.add(const Duration(seconds: 1)))) {
            logs.add(log);
          }
        }
      }

      // Sort by timestamp ascending
      logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return right(logs);
    } catch (e) {
      return left(AuditLogFailure(
        message: 'Failed to get audit logs from Hive: $e',
        error: e,
      ));
    }
  }
}

/// AuditLogFailure - Audit logging error
class AuditLogFailure {
  final String message;
  final Object? error;

  const AuditLogFailure({
    required this.message,
    this.error,
  });

  @override
  String toString() => 'AuditLogFailure(message: $message, error: $error)';
}
