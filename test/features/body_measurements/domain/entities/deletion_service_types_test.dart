// Tests for DeletionReport and DeletionFailure from measurement_deletion_service.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/services/measurement_deletion_service.dart';

void main() {
  final now = DateTime.utc(2025, 6, 15, 12, 0);

  // ---------------------------------------------------------------------------
  // DeletionReport
  // ---------------------------------------------------------------------------
  group('DeletionReport', () {
    DeletionReport _makeReport({
      String userId = 'user-1',
      int measurementsDeleted = 10,
      int localMeasurementsDeleted = 5,
      bool consentDeleted = true,
      DateTime? deletedAt,
    }) {
      return DeletionReport(
        userId: userId,
        measurementsDeleted: measurementsDeleted,
        localMeasurementsDeleted: localMeasurementsDeleted,
        consentDeleted: consentDeleted,
        deletedAt: deletedAt ?? now,
      );
    }

    test('stores all required fields', () {
      final report = _makeReport();

      expect(report.userId, 'user-1');
      expect(report.measurementsDeleted, 10);
      expect(report.localMeasurementsDeleted, 5);
      expect(report.consentDeleted, isTrue);
      expect(report.deletedAt, now);
    });

    test('totalDeleted sums measurementsDeleted + localMeasurementsDeleted', () {
      final report = _makeReport(
        measurementsDeleted: 10,
        localMeasurementsDeleted: 5,
      );

      expect(report.totalDeleted, 15);
    });

    test('totalDeleted is 0 when both counts are 0', () {
      final report = _makeReport(
        measurementsDeleted: 0,
        localMeasurementsDeleted: 0,
      );

      expect(report.totalDeleted, 0);
    });

    test('totalDeleted with only cloud measurements', () {
      final report = _makeReport(
        measurementsDeleted: 100,
        localMeasurementsDeleted: 0,
      );

      expect(report.totalDeleted, 100);
    });

    test('totalDeleted with only local measurements', () {
      final report = _makeReport(
        measurementsDeleted: 0,
        localMeasurementsDeleted: 50,
      );

      expect(report.totalDeleted, 50);
    });

    test('consentDeleted can be false (consent not found scenario)', () {
      final report = _makeReport(consentDeleted: false);

      expect(report.consentDeleted, isFalse);
    });

    test('large dataset counts are handled correctly', () {
      final report = _makeReport(
        measurementsDeleted: 5000,
        localMeasurementsDeleted: 2000,
      );

      expect(report.totalDeleted, 7000);
    });

    test('stores userId correctly', () {
      final report = _makeReport(userId: 'firebase-uid-abc123');
      expect(report.userId, 'firebase-uid-abc123');
    });

    test('deletedAt is stored as provided', () {
      final deletionTime = DateTime.utc(2025, 12, 31, 23, 59);
      final report = _makeReport(deletedAt: deletionTime);

      expect(report.deletedAt, deletionTime);
    });
  });

  // ---------------------------------------------------------------------------
  // DeletionFailure
  // ---------------------------------------------------------------------------
  group('DeletionFailure', () {
    test('stores message', () {
      const failure = DeletionFailure(
        message: 'Cascade deletion failed',
      );

      expect(failure.message, 'Cascade deletion failed');
    });

    test('error defaults to null', () {
      const failure = DeletionFailure(message: 'Error occurred');
      expect(failure.error, isNull);
    });

    test('partialReport defaults to null', () {
      const failure = DeletionFailure(message: 'Error occurred');
      expect(failure.partialReport, isNull);
    });

    test('stores error object', () {
      final exception = Exception('Firestore batch failed');
      final failure = DeletionFailure(
        message: 'Batch operation failed',
        error: exception,
      );

      expect(failure.error, equals(exception));
    });

    test('stores partial report for partial failure scenarios', () {
      final partialReport = DeletionReport(
        userId: 'user-2',
        measurementsDeleted: 3,
        localMeasurementsDeleted: 0,
        consentDeleted: false,
        deletedAt: now,
      );

      final failure = DeletionFailure(
        message: 'Deletion partially completed',
        partialReport: partialReport,
      );

      expect(failure.partialReport, isNotNull);
      expect(failure.partialReport!.measurementsDeleted, 3);
      expect(failure.partialReport!.consentDeleted, isFalse);
      expect(failure.partialReport!.totalDeleted, 3);
    });

    test('message is included for debugging', () {
      final error = StateError('Unexpected state');
      final failure = DeletionFailure(
        message: 'Cascade deletion failed: $error',
        error: error,
      );

      expect(failure.message, contains('Cascade deletion failed'));
    });
  });

  // ---------------------------------------------------------------------------
  // DeletionReport.totalDeleted - mathematical correctness
  // ---------------------------------------------------------------------------
  group('DeletionReport totalDeleted computed property', () {
    test('is additive: totalDeleted == measurementsDeleted + localMeasurementsDeleted', () {
      for (final pair in [
        [0, 0],
        [1, 0],
        [0, 1],
        [10, 5],
        [100, 50],
        [999, 1],
      ]) {
        final report = DeletionReport(
          userId: 'u',
          measurementsDeleted: pair[0],
          localMeasurementsDeleted: pair[1],
          consentDeleted: true,
          deletedAt: now,
        );
        expect(
          report.totalDeleted,
          pair[0] + pair[1],
          reason: 'Failed for ${pair[0]} + ${pair[1]}',
        );
      }
    });
  });
}
