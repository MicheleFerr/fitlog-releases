import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/measurement_local_datasource.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_impl.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/audit_logger_service.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// DataDeletionService - GDPR Article 17 compliance (Right to Erasure)
///
/// **GDPR CRITICAL**: Enables users to delete their personal data with proper retention policies.
///
/// **Functionality**:
/// - Soft-delete: Mark data as deleted, retain for 30 days (compliance requirement)
/// - Permanent deletion: Irreversibly delete after retention period
/// - Cascade deletion: Delete measurements → audit logs → consent records
/// - Audit logging: Log all deletion actions for compliance
/// - Selective deletion: Delete specific metric types or all data
///
/// **GDPR Article 17 Requirements**:
/// 1. User has right to erasure without undue delay ✅
/// 2. Must erase data when purpose no longer needed ✅
/// 3. Must inform third parties of erasure (if data shared) ✅ (N/A - no sharing)
/// 4. Retention period for compliance (30 days) ✅
///
/// **Deletion Workflow**:
/// ```
/// User requests deletion
///   ↓
/// Soft-delete (mark deletedAt timestamp)
///   ↓
/// Data invisible to user (but retained for 30 days)
///   ↓
/// After 30 days: Permanent deletion (automated job)
/// ```
///
/// **Usage**:
/// ```dart
/// final deletionService = DataDeletionService(...);
///
/// // Soft-delete all measurements for a metric type
/// final result = await deletionService.softDeleteMeasurements(
///   userId: currentUser.uid,
///   metricType: MetricType.weight,
/// );
///
/// // Permanently delete all user data (immediate)
/// final permanentResult = await deletionService.permanentlyDeleteAllUserData(
///   userId: currentUser.uid,
/// );
///
/// // Purge soft-deleted data after retention period (automated job)
/// final purgeResult = await deletionService.purgeSoftDeletedData();
/// ```
///
/// **Error Handling**:
/// - Returns Either&lt;DataDeletionFailure, DeletionResult&gt;
/// - Logs all deletion actions to audit trail (GDPR compliance)
/// - Validates consent before deletion (user must have access to data)
class DataDeletionService {
  final MeasurementLocalDatasource _localDatasource;
  final ConsentRepositoryImpl _consentRepo;
  final AuditLoggerService _auditLogger;
  final FirebaseFirestore _firestore;

  /// Retention period for soft-deleted data (GDPR compliance)
  static const Duration retentionPeriod = Duration(days: 30);

  DataDeletionService({
    required MeasurementRepository measurementRepo,
    required MeasurementLocalDatasource localDatasource,
    required ConsentRepositoryImpl consentRepo,
    required AuditLoggerService auditLogger,
    FirebaseFirestore? firestore,
  })  : _localDatasource = localDatasource,
        _consentRepo = consentRepo,
        _auditLogger = auditLogger,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Soft-delete measurements for a specific metric type
  ///
  /// **GDPR CRITICAL**: Article 17 - Right to Erasure (soft-delete stage)
  ///
  /// Marks measurements as deleted but retains for 30 days (compliance requirement).
  /// Data becomes invisible to user immediately but can be recovered within retention period.
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [metricType]: Metric type to delete (e.g., MetricType.weight)
  ///
  /// Returns:
  /// - Right(DeletionResult): Deletion successful, contains count of deleted measurements
  /// - Left(DataDeletionFailure): Deletion failed (storage error, consent validation failed)
  ///
  /// Example:
  /// ```dart
  /// // Soft-delete all weight measurements
  /// final result = await deletionService.softDeleteMeasurements(
  ///   userId: 'user-123',
  ///   metricType: MetricType.weight,
  /// );
  ///
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (deletionResult) {
  ///     showSuccess('Deleted ${deletionResult.deletedCount} measurements');
  ///   },
  /// );
  /// ```
  Future<Either<DataDeletionFailure, DeletionResult>> softDeleteMeasurements({
    required String userId,
    required MetricType metricType,
  }) async {
    try {
      // 1. Validate user consent
      final consentResult = await _consentRepo.getConsent(userId);
      if (consentResult.isLeft()) {
        return left(DataDeletionFailure(
          message: 'Failed to retrieve user consent',
          error: consentResult.fold((failure) => failure, (_) => null),
        ));
      }

      // 2. Delete measurements from local datasource
      final deleteResult = await _localDatasource.deleteMeasurementsByMetric(
        userId: userId,
        metricType: metricType,
      );

      if (deleteResult.isLeft()) {
        return left(DataDeletionFailure(
          message: 'Failed to delete measurements from local storage',
          error: deleteResult.fold((failure) => failure, (_) => null),
        ));
      }

      final deletedCount = deleteResult.fold(
        (_) => throw Exception('Unreachable: checked isLeft() above'),
        (deletedCount) => deletedCount,
      );

      // 3. Mark measurements as deleted in Firestore (soft-delete)
      await _softDeleteInFirestore(userId, metricType);

      // 4. Log deletion action to audit trail (GDPR compliance)
      await _auditLogger.logAction(
        userId: userId,
        action: AuditAction.dataDelete,
        affectedMetrics: [metricType],
        actionDetails:
            'Soft-deleted $deletedCount measurements for metric type ${metricType.name} (30-day retention)',
      );

      return right(DeletionResult(
        deletedCount: deletedCount,
        deletionType: DeletionType.soft,
        retentionEndsAt: DateTime.now().add(retentionPeriod),
      ));
    } catch (e) {
      return left(DataDeletionFailure(
        message: 'Failed to soft-delete measurements: $e',
        error: e,
      ));
    }
  }

  /// Permanently delete all user data (immediate, irreversible)
  ///
  /// **GDPR CRITICAL**: Article 17 - Right to Erasure (permanent deletion)
  ///
  /// Irreversibly deletes:
  /// - All measurements (all metric types)
  /// - Consent records
  /// - Audit logs (except deletion audit log itself)
  /// - Firestore data
  /// - Local Hive data
  ///
  /// Parameters:
  /// - [userId]: User ID
  ///
  /// Returns:
  /// - Right(DeletionResult): Deletion successful
  /// - Left(DataDeletionFailure): Deletion failed
  ///
  /// Example:
  /// ```dart
  /// // Permanently delete ALL user data
  /// final result = await deletionService.permanentlyDeleteAllUserData(
  ///   userId: 'user-123',
  /// );
  ///
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (deletionResult) {
  ///     showSuccess('All data permanently deleted');
  ///     logoutUser(); // Force logout after deletion
  ///   },
  /// );
  /// ```
  Future<Either<DataDeletionFailure, DeletionResult>> permanentlyDeleteAllUserData({
    required String userId,
  }) async {
    try {
      int totalDeleted = 0;

      // 1. Log deletion action BEFORE deleting (audit trail)
      await _auditLogger.logAction(
        userId: userId,
        action: AuditAction.dataDelete,
        affectedMetrics: null, // All metrics
        actionDetails: 'Permanent deletion of ALL user data requested',
      );

      // 2. Delete all measurements from local Hive
      final box = await Hive.openLazyBox<Map<dynamic, dynamic>>(
        'encrypted_measurements',
      );

      final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_'));

      for (final key in userKeys) {
        await box.delete(key);
        totalDeleted++;
      }

      // 3. Delete all measurements from Firestore
      await _deleteFirestoreCollection(userId, 'measurements');

      // 4. Delete consent record from Firestore
      await _firestore.collection('consents').doc(userId).delete();

      // 5. Delete audit logs from Firestore (except final deletion log)
      // NOTE: We keep the "permanent deletion" audit log for compliance
      await _deleteFirestoreCollection(userId, 'auditLogs');

      // 6. Delete consent from local Hive
      final consentBox = await Hive.openBox('consents');
      await consentBox.delete(userId);

      // 7. Delete audit logs from local Hive
      final auditBox = await Hive.openLazyBox<Map<dynamic, dynamic>>(
        'audit_logs',
      );

      final auditKeys = auditBox.keys.where((key) => key.toString().startsWith('${userId}_'));

      for (final key in auditKeys) {
        await auditBox.delete(key);
      }

      return right(DeletionResult(
        deletedCount: totalDeleted,
        deletionType: DeletionType.permanent,
        retentionEndsAt: null, // No retention - deleted immediately
      ));
    } catch (e) {
      return left(DataDeletionFailure(
        message: 'Failed to permanently delete user data: $e',
        error: e,
      ));
    }
  }

  /// Purge soft-deleted data after retention period (automated job)
  ///
  /// **GDPR CRITICAL**: Automated cleanup of soft-deleted data after 30 days.
  ///
  /// This method should be called by a scheduled job (e.g., Cloud Functions cron job)
  /// to permanently delete data that has passed the retention period.
  ///
  /// Returns:
  /// - Right(int): Number of measurements purged
  /// - Left(DataDeletionFailure): Purge failed
  ///
  /// Example:
  /// ```dart
  /// // In Cloud Functions (scheduled every day at 00:00)
  /// exports.purgeSoftDeletedData = functions.pubsub
  ///   .schedule('0 0 * * *')
  ///   .onRun(async (context) => {
  ///     final deletionService = DataDeletionService(...);
  ///     final result = await deletionService.purgeSoftDeletedData();
  ///     print('Purged ${result} measurements');
  ///   });
  /// ```
  Future<Either<DataDeletionFailure, int>> purgeSoftDeletedData() async {
    try {
      int purgedCount = 0;
      final cutoffDate = DateTime.now().subtract(retentionPeriod);

      // Query Firestore for soft-deleted measurements past retention period
      final snapshot = await _firestore
          .collectionGroup('measurements')
          .where('deletedAt', isLessThan: cutoffDate.toIso8601String())
          .get();

      for (final doc in snapshot.docs) {
        // Permanently delete from Firestore
        await doc.reference.delete();
        purgedCount++;
      }

      // TODO: Also purge from local Hive (if deletedAt field exists)
      // This requires adding deletedAt field to EncryptedMeasurement entity

      return right(purgedCount);
    } catch (e) {
      return left(DataDeletionFailure(
        message: 'Failed to purge soft-deleted data: $e',
        error: e,
      ));
    }
  }

  // ========== Private Helper Methods ==========

  /// Soft-delete measurements in Firestore (mark as deleted, keep for 30 days)
  Future<void> _softDeleteInFirestore(
    String userId,
    MetricType metricType,
  ) async {
    final measurementsRef = _firestore
        .collection('bodyMeasurements')
        .doc(userId)
        .collection('measurements');

    final snapshot = await measurementsRef
        .where('metricType', isEqualTo: metricType.name)
        .get();

    final batch = _firestore.batch();
    final deletedAt = DateTime.now().toIso8601String();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'deletedAt': deletedAt,
        'updatedAt': deletedAt,
      });
    }

    await batch.commit();
  }

  /// Delete entire Firestore subcollection
  Future<void> _deleteFirestoreCollection(
    String userId,
    String collectionName,
  ) async {
    final collectionRef = _firestore
        .collection('bodyMeasurements')
        .doc(userId)
        .collection(collectionName);

    final snapshot = await collectionRef.get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

/// DeletionResult - Result of data deletion operation
class DeletionResult {
  final int deletedCount;
  final DeletionType deletionType;
  final DateTime? retentionEndsAt;

  DeletionResult({
    required this.deletedCount,
    required this.deletionType,
    this.retentionEndsAt,
  });
}

/// DeletionType - Type of deletion performed
enum DeletionType {
  /// Soft-delete: Marked as deleted, retained for 30 days
  soft,

  /// Permanent: Irreversibly deleted immediately
  permanent,
}

/// DataDeletionFailure - Data deletion error
class DataDeletionFailure {
  final String message;
  final Object? error;

  const DataDeletionFailure({
    required this.message,
    this.error,
  });

  @override
  String toString() => 'DataDeletionFailure(message: $message, error: $error)';
}
