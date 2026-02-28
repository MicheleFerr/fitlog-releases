import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/measurement_local_datasource.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/services/measurement_deletion_service.dart';

@GenerateMocks([ConsentRepository, MeasurementLocalDatasource])
import 'measurement_deletion_service_test.mocks.dart';

void main() {
  late MeasurementDeletionService service;
  late FakeFirebaseFirestore fakeFirestore;
  late MockConsentRepository mockConsentRepo;
  late MockMeasurementLocalDatasource mockLocalDatasource;

  const testUserId = 'test-user-123';

  setUpAll(() {
    provideDummy<Either<ConsentFailure, void>>(right(null));
    provideDummy<Either<ConsentFailure, UserConsent>>(
      right(UserConsent(
        id: 'dummy',
        userId: 'dummy',
        groupConsents: {},
        consentVersion: 1,
        acceptedAt: DateTime.now(),
        ipAddress: '0.0.0.0',
      )),
    );
    provideDummy<Either<ConsentFailure, bool>>(right(false));
    provideDummy<Either<ConsentFailure, List<MetricType>>>(
      right(<MetricType>[]),
    );
    provideDummy<Either<LocalStorageFailure, void>>(right(null));
    provideDummy<Either<LocalStorageFailure, int>>(right(0));
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockConsentRepo = MockConsentRepository();
    mockLocalDatasource = MockMeasurementLocalDatasource();

    service = MeasurementDeletionService(
      firestore: fakeFirestore,
      consentRepo: mockConsentRepo,
      localDatasource: mockLocalDatasource,
    );
  });

  Future<void> _seedMeasurements(int count) async {
    final collection = fakeFirestore
        .collection('bodyMeasurements')
        .doc(testUserId)
        .collection('measurements');

    for (var i = 0; i < count; i++) {
      await collection.doc('meas-$i').set({
        'id': 'meas-$i',
        'userId': testUserId,
        'metricType': 'weight',
        'encryptedData': 'encrypted-$i',
        'iv': 'iv-$i',
        'tag': 'tag-$i',
        'timestamp': Timestamp.now(),
        'isDeleted': false,
      });
    }
  }

  Future<void> _seedSoftDeletedMeasurements(
    int count, {
    required DateTime deletedAt,
  }) async {
    final collection = fakeFirestore
        .collection('bodyMeasurements')
        .doc(testUserId)
        .collection('measurements');

    for (var i = 0; i < count; i++) {
      await collection.doc('deleted-$i').set({
        'id': 'deleted-$i',
        'userId': testUserId,
        'metricType': 'weight',
        'encryptedData': 'encrypted-$i',
        'iv': 'iv-$i',
        'tag': 'tag-$i',
        'timestamp': Timestamp.now(),
        'isDeleted': true,
        'deletedAt': Timestamp.fromDate(deletedAt),
      });
    }
  }

  group('MeasurementDeletionService', () {
    group('deleteAllUserData', () {
      test('deletes all Firestore measurements', () async {
        await _seedMeasurements(5);

        when(mockConsentRepo.deleteConsent(testUserId))
            .thenAnswer((_) async => right(null));
        when(mockLocalDatasource.deleteAllMeasurements(testUserId))
            .thenAnswer((_) async => right(3));

        final result = await service.deleteAllUserData(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (report) {
            expect(report.measurementsDeleted, equals(5));
            expect(report.userId, equals(testUserId));
            expect(report.deletedAt, isNotNull);
          },
        );

        // Verify Firestore is empty
        final snapshot = await fakeFirestore
            .collection('bodyMeasurements')
            .doc(testUserId)
            .collection('measurements')
            .get();
        expect(snapshot.docs, isEmpty);
      });

      test('deletes consent record', () async {
        await _seedMeasurements(1);

        when(mockConsentRepo.deleteConsent(testUserId))
            .thenAnswer((_) async => right(null));
        when(mockLocalDatasource.deleteAllMeasurements(testUserId))
            .thenAnswer((_) async => right(0));

        final result = await service.deleteAllUserData(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (report) => expect(report.consentDeleted, isTrue),
        );

        verify(mockConsentRepo.deleteConsent(testUserId)).called(1);
      });

      test('deletes local Hive measurements', () async {
        when(mockConsentRepo.deleteConsent(testUserId))
            .thenAnswer((_) async => right(null));
        when(mockLocalDatasource.deleteAllMeasurements(testUserId))
            .thenAnswer((_) async => right(10));

        final result = await service.deleteAllUserData(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (report) => expect(report.localMeasurementsDeleted, equals(10)),
        );

        verify(mockLocalDatasource.deleteAllMeasurements(testUserId)).called(1);
      });

      test('reports correct totalDeleted', () async {
        await _seedMeasurements(3);

        when(mockConsentRepo.deleteConsent(testUserId))
            .thenAnswer((_) async => right(null));
        when(mockLocalDatasource.deleteAllMeasurements(testUserId))
            .thenAnswer((_) async => right(5));

        final result = await service.deleteAllUserData(testUserId);

        result.fold(
          (_) => fail('Expected success'),
          (report) => expect(report.totalDeleted, equals(8)), // 3 + 5
        );
      });

      test('handles empty user (no measurements)', () async {
        when(mockConsentRepo.deleteConsent(testUserId))
            .thenAnswer((_) async => right(null));
        when(mockLocalDatasource.deleteAllMeasurements(testUserId))
            .thenAnswer((_) async => right(0));

        final result = await service.deleteAllUserData(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (report) {
            expect(report.measurementsDeleted, equals(0));
            expect(report.localMeasurementsDeleted, equals(0));
          },
        );
      });

      test('continues even if consent delete fails', () async {
        await _seedMeasurements(2);

        when(mockConsentRepo.deleteConsent(testUserId)).thenAnswer(
          (_) async => left(const ConsentNotFoundFailure()),
        );
        when(mockLocalDatasource.deleteAllMeasurements(testUserId))
            .thenAnswer((_) async => right(1));

        final result = await service.deleteAllUserData(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (report) {
            expect(report.consentDeleted, isFalse);
            expect(report.measurementsDeleted, equals(2));
          },
        );
      });
    });

    group('cleanupExpiredMeasurements', () {
      test('deletes measurements past retention period', () async {
        final expiredDate = DateTime.now().subtract(const Duration(days: 45));
        await _seedSoftDeletedMeasurements(3, deletedAt: expiredDate);

        final result = await service.cleanupExpiredMeasurements(
          testUserId,
          retentionDays: 30,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, equals(3)),
        );
      });

      test('does not delete measurements within retention period', () async {
        final recentDate = DateTime.now().subtract(const Duration(days: 10));
        await _seedSoftDeletedMeasurements(3, deletedAt: recentDate);

        final result = await service.cleanupExpiredMeasurements(
          testUserId,
          retentionDays: 30,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, equals(0)),
        );
      });

      test('does not delete active (non-soft-deleted) measurements', () async {
        await _seedMeasurements(5);

        final result = await service.cleanupExpiredMeasurements(
          testUserId,
          retentionDays: 30,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, equals(0)),
        );

        // Verify active measurements still exist
        final snapshot = await fakeFirestore
            .collection('bodyMeasurements')
            .doc(testUserId)
            .collection('measurements')
            .get();
        expect(snapshot.docs.length, equals(5));
      });

      test('uses custom retention period', () async {
        final date60DaysAgo =
            DateTime.now().subtract(const Duration(days: 60));
        await _seedSoftDeletedMeasurements(2, deletedAt: date60DaysAgo);

        // 90-day retention: should NOT delete 60-day-old soft-deleted items
        final result = await service.cleanupExpiredMeasurements(
          testUserId,
          retentionDays: 90,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, equals(0)),
        );
      });

      test('returns 0 when no expired measurements', () async {
        final result = await service.cleanupExpiredMeasurements(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, equals(0)),
        );
      });
    });

    group('DeletionReport', () {
      test('totalDeleted sums Firestore and local', () {
        final report = DeletionReport(
          userId: testUserId,
          measurementsDeleted: 10,
          localMeasurementsDeleted: 5,
          consentDeleted: true,
          deletedAt: DateTime.utc(2026, 1, 1),
        );

        expect(report.totalDeleted, equals(15));
      });
    });
  });
}
