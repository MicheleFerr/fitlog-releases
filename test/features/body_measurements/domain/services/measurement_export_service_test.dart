import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/services/measurement_export_service.dart';

@GenerateMocks([MeasurementRepository, ConsentRepository])
import 'measurement_export_service_test.mocks.dart';

void main() {
  late MeasurementExportService service;
  late MockMeasurementRepository mockMeasurementRepo;
  late MockConsentRepository mockConsentRepo;

  const testUserId = 'test-user-123';

  final testMeasurements = [
    Measurement(
      id: 'meas-1',
      userId: testUserId,
      metricType: MetricType.weight,
      value: 75.5,
      unit: 'kg',
      timestamp: DateTime.utc(2026, 1, 15, 8, 0),
      source: MeasurementSource.manual,
      notes: 'Morning weight',
      createdAt: DateTime.utc(2026, 1, 15, 8, 0),
    ),
    Measurement(
      id: 'meas-2',
      userId: testUserId,
      metricType: MetricType.bodyFatPercentage,
      value: 18.5,
      unit: '%',
      timestamp: DateTime.utc(2026, 1, 15, 8, 5),
      source: MeasurementSource.manual,
      createdAt: DateTime.utc(2026, 1, 15, 8, 5),
    ),
    Measurement(
      id: 'meas-3',
      userId: testUserId,
      metricType: MetricType.height,
      value: 180.0,
      unit: 'cm',
      timestamp: DateTime.utc(2026, 1, 10),
      source: MeasurementSource.healthKit,
      createdAt: DateTime.utc(2026, 1, 10),
    ),
  ];

  final testConsent = UserConsent(
    id: 'consent-1',
    userId: testUserId,
    groupConsents: {
      MetricGroup.essential: ConsentState.granted,
      MetricGroup.measurements: ConsentState.notAsked,
      MetricGroup.vitals: ConsentState.denied,
    },
    consentVersion: 1,
    acceptedAt: DateTime.utc(2026, 1, 1),
    ipAddress: '192.168.1.***',
    essentialGrantedAt: DateTime.utc(2026, 1, 1),
  );

  setUpAll(() {
    // Provide dummy values for Either types that Mockito can't auto-generate
    provideDummy<Either<MeasurementFailure, List<Measurement>>>(
      right(<Measurement>[]),
    );
    provideDummy<Either<MeasurementFailure, void>>(right(null));
    provideDummy<Either<MeasurementFailure, Map<MetricType, Measurement>>>(
      right(<MetricType, Measurement>{}),
    );
    provideDummy<Either<MeasurementFailure, SyncResult>>(
      right(SyncResult(
        readCount: 0,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: DateTime.now(),
      )),
    );
    provideDummy<Either<MeasurementFailure, List<SyncConflict>>>(
      right(<SyncConflict>[]),
    );
    provideDummy<Either<MeasurementFailure, DateTime?>>(right(null));
    provideDummy<Either<MeasurementFailure, int>>(right(0));
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
    provideDummy<Either<ConsentFailure, void>>(right(null));
    provideDummy<Either<ConsentFailure, bool>>(right(false));
    provideDummy<Either<ConsentFailure, List<MetricType>>>(
      right(<MetricType>[]),
    );
  });

  setUp(() {
    mockMeasurementRepo = MockMeasurementRepository();
    mockConsentRepo = MockConsentRepository();
    service = MeasurementExportService(
      measurementRepo: mockMeasurementRepo,
      consentRepo: mockConsentRepo,
    );
  });

  group('MeasurementExportService', () {
    group('exportUserMeasurements', () {
      test('exports valid JSON with all measurements', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right(testMeasurements));
        when(mockConsentRepo.getConsent(testUserId))
            .thenAnswer((_) async => right(testConsent));

        final result = await service.exportUserMeasurements(testUserId);

        expect(result.isRight(), isTrue);
        final jsonString = result.getOrElse((_) => '');

        // Verify valid JSON
        final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
        expect(parsed, isNotNull);

        // Verify structure
        expect(parsed.containsKey('exportMetadata'), isTrue);
        expect(parsed.containsKey('consent'), isTrue);
        expect(parsed.containsKey('measurements'), isTrue);
      });

      test('export metadata contains required fields', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right(testMeasurements));
        when(mockConsentRepo.getConsent(testUserId))
            .thenAnswer((_) async => right(testConsent));

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}'))
            as Map<String, dynamic>;
        final metadata = parsed['exportMetadata'] as Map<String, dynamic>;

        expect(metadata['formatVersion'], equals(1));
        expect(metadata['userId'], equals(testUserId));
        expect(metadata['totalMeasurements'], equals(3));
        expect(metadata['gdprArticle'], contains('Article 20'));
        expect(metadata['exportedAt'], isNotNull);
      });

      test('measurements contain all required fields', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right(testMeasurements));
        when(mockConsentRepo.getConsent(testUserId))
            .thenAnswer((_) async => right(testConsent));

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}'))
            as Map<String, dynamic>;
        final measurements = parsed['measurements'] as List;

        expect(measurements.length, equals(3));

        final first = measurements[0] as Map<String, dynamic>;
        expect(first['id'], equals('meas-1'));
        expect(first['metricType'], equals('weight'));
        expect(first['value'], equals(75.5));
        expect(first['unit'], equals('kg'));
        expect(first['timestamp'], isNotNull);
        expect(first['source'], equals('manual'));
        expect(first['notes'], equals('Morning weight'));
        expect(first['createdAt'], isNotNull);
      });

      test('consent data included when available', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right(testMeasurements));
        when(mockConsentRepo.getConsent(testUserId))
            .thenAnswer((_) async => right(testConsent));

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}'))
            as Map<String, dynamic>;
        final consent = parsed['consent'] as Map<String, dynamic>;

        expect(consent['consentVersion'], equals(1));
        expect(consent['isRevoked'], isFalse);
        expect(consent['groups'], isNotNull);
        final groups = consent['groups'] as Map<String, dynamic>;
        expect(groups['essential'], equals('granted'));
        expect(groups['measurements'], equals('notAsked'));
        expect(groups['vitals'], equals('denied'));
      });

      test('consent is null when not found', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right(testMeasurements));
        when(mockConsentRepo.getConsent(testUserId)).thenAnswer(
            (_) async => left(const ConsentNotFoundFailure()));

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}'))
            as Map<String, dynamic>;

        expect(parsed['consent'], isNull);
      });

      test('returns empty measurements list when no data', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right([]));
        when(mockConsentRepo.getConsent(testUserId))
            .thenAnswer((_) async => right(testConsent));

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}'))
            as Map<String, dynamic>;
        final measurements = parsed['measurements'] as List;

        expect(measurements, isEmpty);
        expect(
          (parsed['exportMetadata'] as Map)['totalMeasurements'],
          equals(0),
        );
      });

      test('returns ExportFailure when measurement fetch fails', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId)).thenAnswer(
          (_) async => left(
            const StorageFailure(message: 'Network error'),
          ),
        );

        final result = await service.exportUserMeasurements(testUserId);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure.message, contains('Failed to fetch')),
          (_) => fail('Expected failure'),
        );
      });

      test('timestamps are in UTC ISO 8601 format', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right([testMeasurements.first]));
        when(mockConsentRepo.getConsent(testUserId))
            .thenAnswer((_) async => right(testConsent));

        final result = await service.exportUserMeasurements(testUserId);
        final parsed = jsonDecode(result.getOrElse((_) => '{}'))
            as Map<String, dynamic>;
        final measurements = parsed['measurements'] as List;
        final first = measurements[0] as Map<String, dynamic>;

        final timestamp = first['timestamp'] as String;
        expect(timestamp, contains('T'));
        expect(timestamp, endsWith('Z'));
        // Verify it parses back correctly
        expect(DateTime.parse(timestamp), isNotNull);
      });
    });

    group('exportUserMeasurementsAsMap', () {
      test('returns Map instead of JSON string', () async {
        when(mockMeasurementRepo.getMeasurements(testUserId))
            .thenAnswer((_) async => right(testMeasurements));
        when(mockConsentRepo.getConsent(testUserId))
            .thenAnswer((_) async => right(testConsent));

        final result = await service.exportUserMeasurementsAsMap(testUserId);

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected success'),
          (map) {
            expect(map, isA<Map<String, dynamic>>());
            expect(map.containsKey('exportMetadata'), isTrue);
            expect(map.containsKey('measurements'), isTrue);
          },
        );
      });
    });
  });
}
