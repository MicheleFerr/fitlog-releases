// Tests for MeasurementExportService using manual fake repositories (no mockito)
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/services/measurement_export_service.dart';

// ---------------------------------------------------------------------------
// Manual fakes - no mockito
// ---------------------------------------------------------------------------

class FakeMeasurementRepository implements MeasurementRepository {
  FakeMeasurementRepository({
    required this.measurementsResult,
  });

  final Either<MeasurementFailure, List<Measurement>> measurementsResult;

  @override
  Future<Either<MeasurementFailure, List<Measurement>>> getMeasurements(
    String userId, {
    MetricType? filterByType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async =>
      measurementsResult;

  @override
  Future<Either<MeasurementFailure, void>> addMeasurement(
    Measurement measurement, {
    required bool hasConsent,
  }) async =>
      right(null);

  @override
  Future<Either<MeasurementFailure, void>> updateMeasurement(
    Measurement measurement,
  ) async =>
      right(null);

  @override
  Future<Either<MeasurementFailure, void>> deleteMeasurement({
    required String measurementId,
    required String userId,
  }) async =>
      right(null);

  @override
  Future<Either<MeasurementFailure, void>> permanentlyDeleteMeasurement(
    String measurementId,
  ) async =>
      right(null);

  @override
  Future<Either<MeasurementFailure, SyncResult>> syncWithHealthPlatform({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
  }) async =>
      right(SyncResult(
        readCount: 0,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: DateTime.now(),
      ));

  @override
  Future<Either<MeasurementFailure, Map<MetricType, Measurement>>>
  getLatestMeasurementsByType(String userId) async =>
      right({});

  @override
  Future<Either<MeasurementFailure, List<SyncConflict>>> getSyncConflicts(
    String userId,
  ) async =>
      right([]);

  @override
  Future<Either<MeasurementFailure, void>> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async =>
      right(null);

  @override
  Future<Either<MeasurementFailure, DateTime?>> getLastSyncTimestamp(
    String userId,
  ) async =>
      right(null);

  @override
  Future<Either<MeasurementFailure, int>> cleanupExpiredMeasurements(
    String userId, {
    int retentionDays = 30,
  }) async =>
      right(0);
}

class FakeConsentRepository implements ConsentRepository {
  FakeConsentRepository({required this.consentResult});

  final Either<ConsentFailure, UserConsent> consentResult;

  @override
  Future<Either<ConsentFailure, UserConsent>> getConsent(String userId) async =>
      consentResult;

  @override
  Future<Either<ConsentFailure, UserConsent>> createInitialConsent({
    required String userId,
    required String ipAddress,
    String? userAgent,
  }) async =>
      consentResult;

  @override
  Future<Either<ConsentFailure, UserConsent>> grantConsent({
    required String userId,
    required MetricGroup group,
    required String ipAddress,
    String? userAgent,
  }) async =>
      consentResult;

  @override
  Future<Either<ConsentFailure, UserConsent>> revokeConsent({
    required String userId,
    required MetricGroup group,
    required String ipAddress,
    String? userAgent,
  }) async =>
      consentResult;

  @override
  Future<Either<ConsentFailure, bool>> hasConsentFor(
    String userId,
    MetricType metric,
  ) async =>
      right(true);

  @override
  Future<Either<ConsentFailure, UserConsent>> updateConsentVersion({
    required String userId,
    required int newVersion,
    required String ipAddress,
    String? userAgent,
  }) async =>
      consentResult;

  @override
  Future<Either<ConsentFailure, void>> deleteConsent(String userId) async =>
      right(null);

  @override
  Future<Either<ConsentFailure, List<MetricType>>> getConsentedMetrics(
    String userId,
  ) async =>
      right([]);

  @override
  Future<Either<ConsentFailure, bool>> needsReConsent({
    required String userId,
    required int currentPolicyVersion,
  }) async =>
      right(false);
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

const testUserId = 'test-user-fake';

Measurement _makeMeasurement({
  String id = 'meas-1',
  MetricType metricType = MetricType.weight,
  double value = 75.0,
  String? notes,
}) {
  return Measurement(
    id: id,
    userId: testUserId,
    metricType: metricType,
    value: value,
    unit: metricType.defaultUnit,
    timestamp: DateTime.utc(2026, 1, 15, 8, 0),
    source: MeasurementSource.manual,
    notes: notes,
    createdAt: DateTime.utc(2026, 1, 15, 8, 0),
  );
}

UserConsent _makeConsent({bool isRevoked = false}) {
  return UserConsent(
    id: 'consent-fake',
    userId: testUserId,
    groupConsents: {
      MetricGroup.essential: ConsentState.granted,
      MetricGroup.measurements: ConsentState.notAsked,
      MetricGroup.vitals: ConsentState.denied,
    },
    consentVersion: 1,
    acceptedAt: DateTime.utc(2026, 1, 1),
    ipAddress: '192.168.1.***',
    isRevoked: isRevoked,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MeasurementExportService (fake repositories)', () {
    group('exportUserMeasurements', () {
      test('returns valid JSON string on success', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([_makeMeasurement()]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);

        expect(result.isRight(), isTrue);
        final json = result.getOrElse((_) => '');
        expect(() => jsonDecode(json), returnsNormally);
      });

      test('export JSON contains exportMetadata, consent, measurements keys', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([_makeMeasurement()]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;

        expect(parsed.containsKey('exportMetadata'), isTrue);
        expect(parsed.containsKey('consent'), isTrue);
        expect(parsed.containsKey('measurements'), isTrue);
      });

      test('exportMetadata contains correct format version', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final metadata = parsed['exportMetadata'] as Map<String, dynamic>;

        expect(metadata['formatVersion'], MeasurementExportService.exportFormatVersion);
        expect(metadata['formatVersion'], 1);
      });

      test('exportMetadata contains userId', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final metadata = parsed['exportMetadata'] as Map<String, dynamic>;

        expect(metadata['userId'], testUserId);
      });

      test('exportMetadata totalMeasurements matches list size', () async {
        final measurements = List.generate(
          5,
          (i) => _makeMeasurement(id: 'meas-$i'),
        );

        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right(measurements),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final metadata = parsed['exportMetadata'] as Map<String, dynamic>;

        expect(metadata['totalMeasurements'], 5);
      });

      test('exportMetadata references Article 20', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final metadata = parsed['exportMetadata'] as Map<String, dynamic>;

        expect(metadata['gdprArticle'].toString(), contains('Article 20'));
      });

      test('measurements array contains all exported items', () async {
        final measurements = [
          _makeMeasurement(id: 'm-1', metricType: MetricType.weight, value: 80.0),
          _makeMeasurement(id: 'm-2', metricType: MetricType.height, value: 175.0),
          _makeMeasurement(id: 'm-3', metricType: MetricType.bmi, value: 26.1),
        ];

        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right(measurements),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final exported = parsed['measurements'] as List;

        expect(exported.length, 3);
        expect((exported[0] as Map)['id'], 'm-1');
        expect((exported[1] as Map)['id'], 'm-2');
        expect((exported[2] as Map)['id'], 'm-3');
      });

      test('each measurement export contains required fields', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([
              _makeMeasurement(
                notes: 'Morning weight',
              ),
            ]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final m = (parsed['measurements'] as List).first as Map<String, dynamic>;

        expect(m.containsKey('id'), isTrue);
        expect(m.containsKey('metricType'), isTrue);
        expect(m.containsKey('value'), isTrue);
        expect(m.containsKey('unit'), isTrue);
        expect(m.containsKey('timestamp'), isTrue);
        expect(m.containsKey('source'), isTrue);
        expect(m.containsKey('notes'), isTrue);
        expect(m['notes'], 'Morning weight');
      });

      test('measurement timestamp in UTC ISO 8601 format', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([_makeMeasurement()]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final m = (parsed['measurements'] as List).first as Map<String, dynamic>;
        final timestamp = m['timestamp'] as String;

        expect(timestamp, endsWith('Z'));
        expect(DateTime.parse(timestamp), isA<DateTime>());
      });

      test('consent data is included in export when available', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;

        expect(parsed['consent'], isNotNull);
        final consent = parsed['consent'] as Map<String, dynamic>;
        expect(consent['consentVersion'], 1);
        expect(consent['isRevoked'], isFalse);
      });

      test('consent groups are serialized correctly', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;
        final groups = (parsed['consent'] as Map)['groups'] as Map<String, dynamic>;

        expect(groups['essential'], 'granted');
        expect(groups['measurements'], 'notAsked');
        expect(groups['vitals'], 'denied');
      });

      test('consent is null in export when consent not found', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: left(const ConsentNotFoundFailure()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;

        expect(parsed['consent'], isNull);
      });

      test('returns ExportFailure when measurement fetch fails', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: left(const StorageFailure(message: 'Disk full')),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ExportFailure>());
            expect(failure.message, contains('Failed to fetch'));
          },
          (_) => fail('Expected failure'),
        );
      });

      test('returns empty measurements list when no data', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}')) as Map<String, dynamic>;

        expect((parsed['measurements'] as List), isEmpty);
        expect((parsed['exportMetadata'] as Map)['totalMeasurements'], 0);
      });
    });

    group('exportUserMeasurementsAsMap', () {
      test('returns Map<String, dynamic> on success', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right([_makeMeasurement()]),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurementsAsMap(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (map) {
            expect(map, isA<Map<String, dynamic>>());
            expect(map.containsKey('exportMetadata'), isTrue);
            expect(map.containsKey('measurements'), isTrue);
            expect(map.containsKey('consent'), isTrue);
          },
        );
      });

      test('returns ExportFailure when measurements fail', () async {
        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: left(
              const StorageFailure(message: 'Network error'),
            ),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurementsAsMap(testUserId);
        expect(result.isLeft(), isTrue);
      });

      test('map totalMeasurements is correct', () async {
        final measurements = List.generate(
          3,
          (i) => _makeMeasurement(id: 'map-$i'),
        );

        final service = MeasurementExportService(
          measurementRepo: FakeMeasurementRepository(
            measurementsResult: right(measurements),
          ),
          consentRepo: FakeConsentRepository(
            consentResult: right(_makeConsent()),
          ),
        );

        final result = await service.exportUserMeasurementsAsMap(testUserId);
        result.fold(
          (_) => fail('Expected success'),
          (map) {
            final metadata = map['exportMetadata'] as Map<String, dynamic>;
            expect(metadata['totalMeasurements'], 3);
          },
        );
      });
    });

    group('ExportFailure', () {
      test('stores message', () {
        const failure = ExportFailure(message: 'Export failed');
        expect(failure.message, 'Export failed');
        expect(failure.error, isNull);
      });

      test('stores optional error', () {
        final err = Exception('Storage error');
        final failure = ExportFailure(message: 'Export failed', error: err);
        expect(failure.error, equals(err));
      });
    });

    group('MeasurementExportService.exportFormatVersion', () {
      test('format version is 1', () {
        expect(MeasurementExportService.exportFormatVersion, 1);
      });
    });
  });
}
