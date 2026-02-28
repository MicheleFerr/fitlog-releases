import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/measurement_local_datasource.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';

/// GDPR Article 17 - Right to Erasure ("Right to be Forgotten")
///
/// Cascade-deletes ALL user body measurement data:
/// - All measurements (Firestore + local Hive)
/// - Consent record (Firestore)
/// - Pending measurements (local queue)
///
/// Audit logs are retained for 2 years per GDPR Article 30.
///
/// Uses Firestore batch/transaction for all-or-nothing guarantee.
///
/// Usage:
/// ```dart
/// final service = MeasurementDeletionService(
///   firestore: FirebaseFirestore.instance,
///   consentRepo: ref.read(consentRepositoryProvider),
///   localDatasource: ref.read(measurementLocalDatasourceProvider),
/// );
/// final result = await service.deleteAllUserData(userId);
/// result.fold(
///   (failure) => showError(failure.message),
///   (report) => print('Deleted ${report.measurementsDeleted} measurements'),
/// );
/// ```
class MeasurementDeletionService {
  MeasurementDeletionService({
    required FirebaseFirestore firestore,
    required ConsentRepository consentRepo,
    required MeasurementLocalDatasource localDatasource,
  })  : _firestore = firestore,
        _consentRepo = consentRepo,
        _localDatasource = localDatasource;

  final FirebaseFirestore _firestore;
  final ConsentRepository _consentRepo;
  final MeasurementLocalDatasource _localDatasource;

  static const String _measurementsCollection = 'bodyMeasurements';
  static const String _measurementsSubcollection = 'measurements';

  /// Maximum documents per Firestore batch (Firestore limit: 500)
  static const int _batchLimit = 450;

  /// Delete ALL user measurement data (cascade)
  ///
  /// Deletes in order:
  /// 1. All Firestore measurements (batched)
  /// 2. Consent record (via ConsentRepository)
  /// 3. All local Hive measurements
  ///
  /// [userId] - Firebase Auth UID of the user
  ///
  /// Returns:
  /// - Right(DeletionReport): Summary of what was deleted
  /// - Left(DeletionFailure): Error during deletion (partial may have occurred)
  Future<Either<DeletionFailure, DeletionReport>> deleteAllUserData(
    String userId,
  ) async {
    var measurementsDeleted = 0;
    var localDeleted = 0;
    var consentDeleted = false;

    try {
      // 1. Delete all Firestore measurements (batched for large datasets)
      measurementsDeleted = await _deleteFirestoreMeasurements(userId);

      // 2. Delete consent record
      final consentResult = await _consentRepo.deleteConsent(userId);
      consentDeleted = consentResult.isRight();

      // 3. Delete all local Hive measurements
      localDeleted = await _deleteLocalMeasurements(userId);

      return right(DeletionReport(
        userId: userId,
        measurementsDeleted: measurementsDeleted,
        localMeasurementsDeleted: localDeleted,
        consentDeleted: consentDeleted,
        deletedAt: DateTime.now().toUtc(),
      ));
    } catch (e) {
      return left(DeletionFailure(
        message: 'Cascade deletion failed: $e',
        error: e,
        partialReport: DeletionReport(
          userId: userId,
          measurementsDeleted: measurementsDeleted,
          localMeasurementsDeleted: localDeleted,
          consentDeleted: consentDeleted,
          deletedAt: DateTime.now().toUtc(),
        ),
      ));
    }
  }

  /// Delete only expired soft-deleted measurements
  ///
  /// Called by retention cleanup job. Permanently removes measurements
  /// that were soft-deleted more than [retentionDays] ago.
  ///
  /// [userId] - Firebase Auth UID
  /// [retentionDays] - Days to retain after soft-delete (default: 30)
  ///
  /// Returns number of permanently deleted measurements
  Future<Either<DeletionFailure, int>> cleanupExpiredMeasurements(
    String userId, {
    int retentionDays = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(
        Duration(days: retentionDays),
      );

      final collection = _firestore
          .collection(_measurementsCollection)
          .doc(userId)
          .collection(_measurementsSubcollection);

      // Query soft-deleted measurements past retention period
      final snapshot = await collection
          .where('isDeleted', isEqualTo: true)
          .where('deletedAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      if (snapshot.docs.isEmpty) {
        return right(0);
      }

      // Batch delete
      var deleted = 0;
      var batch = _firestore.batch();
      var batchCount = 0;

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        batchCount++;
        deleted++;

        if (batchCount >= _batchLimit) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      return right(deleted);
    } catch (e) {
      return left(DeletionFailure(
        message: 'Cleanup of expired measurements failed: $e',
        error: e,
      ));
    }
  }

  /// Delete all Firestore measurements for a user (batched)
  Future<int> _deleteFirestoreMeasurements(String userId) async {
    final collection = _firestore
        .collection(_measurementsCollection)
        .doc(userId)
        .collection(_measurementsSubcollection);

    var totalDeleted = 0;

    // Delete in batches (Firestore limit: 500 per batch)
    while (true) {
      final snapshot = await collection.limit(_batchLimit).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      totalDeleted += snapshot.docs.length;
    }

    // Also delete the parent user document
    await _firestore
        .collection(_measurementsCollection)
        .doc(userId)
        .delete();

    return totalDeleted;
  }

  /// Delete all local Hive measurements for a user
  Future<int> _deleteLocalMeasurements(String userId) async {
    final result = await _localDatasource.deleteAllMeasurements(userId);
    return result.getOrElse((_) => 0);
  }
}

/// Report of what was deleted during cascade deletion
class DeletionReport {
  const DeletionReport({
    required this.userId,
    required this.measurementsDeleted,
    required this.localMeasurementsDeleted,
    required this.consentDeleted,
    required this.deletedAt,
  });

  final String userId;
  final int measurementsDeleted;
  final int localMeasurementsDeleted;
  final bool consentDeleted;
  final DateTime deletedAt;

  int get totalDeleted => measurementsDeleted + localMeasurementsDeleted;
}

/// Failure type for deletion operations
class DeletionFailure {
  const DeletionFailure({
    required this.message,
    this.error,
    this.partialReport,
  });

  final String message;
  final Object? error;

  /// If deletion failed partway, this shows what was deleted before failure
  final DeletionReport? partialReport;
}
