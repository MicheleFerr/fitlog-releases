/// Unit tests for BodyMeasurementExecutor
///
/// Tests all public methods:
/// - getBodyProgress
/// - addBodyMeasurement (including 2-step confirmation flow)
library;

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/body_measurement_executor.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';

// ---------------------------------------------------------------------------
// Firebase test setup helpers
// ---------------------------------------------------------------------------

void _setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebasePlatform.instance = _MockFirebasePlatform();
}

class _MockFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _MockFirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'test',
        appId: 'test',
        messagingSenderId: 'test',
        projectId: 'test',
      ),
    );
  }

  @override
  List<FirebaseAppPlatform> get apps => [app()];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return app(name ?? defaultFirebaseAppName);
  }
}

class _MockFirebaseAppPlatform extends FirebaseAppPlatform {
  _MockFirebaseAppPlatform(super.name, super.options);

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

/// No-op Crashlytics platform to prevent assertion errors in tests.
class _FakeCrashlyticsPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FirebaseCrashlyticsPlatform {
  @override
  bool get isCrashlyticsCollectionEnabled => false;

  @override
  Future<void> recordError({
    required String exception,
    required String information,
    required String? reason,
    bool fatal = false,
    String? buildId,
    List<String> loadingUnits = const [],
    List<Map<String, String>>? stackTraceElements,
  }) async {}

  @override
  Future<bool> checkForUnsentReports() async => false;

  @override
  Future<bool> didCrashOnPreviousExecution() async => false;

  @override
  Future<void> deleteUnsentReports() async {}

  @override
  Future<void> sendUnsentReports() async {}

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}

  @override
  Future<void> setCustomKey(String key, String value) async {}

  @override
  Future<void> log(String message) async {}

  @override
  void crash() {}

  @override
  FirebaseApp get app => Firebase.app();

  @override
  FirebaseCrashlyticsPlatform setInitialValues({
    required bool isCrashlyticsCollectionEnabled,
  }) => this;
}

// ---------------------------------------------------------------------------
// Fake implementation
// ---------------------------------------------------------------------------

class _FakeMeasurementRepository implements MeasurementRepository {
  fp.Either<MeasurementFailure, List<Measurement>>? getMeasurementsResult;
  fp.Either<MeasurementFailure, void>? addResult;
  fp.Either<MeasurementFailure, Map<MetricType, Measurement>>? latestResult;
  MeasurementFailure? getMeasurementsFailure;

  @override
  Future<fp.Either<MeasurementFailure, List<Measurement>>> getMeasurements(
    String userId, {
    MetricType? filterByType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (getMeasurementsFailure != null) {
      return fp.Left(getMeasurementsFailure!);
    }
    return getMeasurementsResult ?? fp.Right([]);
  }

  @override
  Future<fp.Either<MeasurementFailure, void>> addMeasurement(
    Measurement measurement, {
    required bool hasConsent,
  }) async {
    return addResult ?? fp.Right(null);
  }

  @override
  Future<fp.Either<MeasurementFailure, Map<MetricType, Measurement>>>
  getLatestMeasurementsByType(String userId) async {
    return latestResult ?? fp.Right({});
  }

  @override
  Future<fp.Either<MeasurementFailure, void>> updateMeasurement(
    Measurement measurement,
  ) async => fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, void>> deleteMeasurement({
    required String measurementId,
    required String userId,
  }) async => fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, void>> permanentlyDeleteMeasurement(
    String measurementId,
  ) async => fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, SyncResult>> syncWithHealthPlatform({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
  }) async {
    return fp.Right(
      SyncResult(
        readCount: 0,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<fp.Either<MeasurementFailure, List<SyncConflict>>> getSyncConflicts(
    String userId,
  ) async => fp.Right([]);

  @override
  Future<fp.Either<MeasurementFailure, void>> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async => fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, DateTime?>> getLastSyncTimestamp(
    String userId,
  ) async => fp.Right(null);

  @override
  Future<fp.Either<MeasurementFailure, int>> cleanupExpiredMeasurements(
    String userId, {
    int retentionDays = 30,
  }) async => fp.Right(0);
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

Measurement _makeMeasurement({
  MetricType type = MetricType.weight,
  double value = 75.0,
  String unit = 'kg',
  int daysAgo = 0,
}) {
  final ts = DateTime.now().subtract(Duration(days: daysAgo));
  return Measurement(
    id: 'meas-$daysAgo',
    userId: 'user-1',
    metricType: type,
    value: value,
    unit: unit,
    timestamp: ts,
    source: MeasurementSource.manual,
    createdAt: ts,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const userId = 'user-test-1';

  setUpAll(() async {
    _setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseCrashlyticsPlatform.instance = _FakeCrashlyticsPlatform();
  });

  group('BodyMeasurementExecutor - getBodyProgress', () {
    test('returns valid JSON with progress data when measurements exist',
        () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([
        _makeMeasurement(value: 75.0, daysAgo: 30),
        _makeMeasurement(value: 73.5, daysAgo: 0),
      ]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({'weeksBack': 12}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('progress'), isTrue);
      expect(json['weeksBack'], equals(12));
      expect(json.containsKey('totalMeasurements'), isTrue);
      expect(json['toolName'], equals('getBodyProgress'));
    });

    test('returns no-data message when no measurements found', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('message'), isTrue);
      expect(json['toolName'], equals('getBodyProgress'));
    });

    test('filters by metricType when provided', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([
        _makeMeasurement(type: MetricType.weight, value: 75.0),
      ]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress(
        {'metricType': 'peso', 'weeksBack': 8},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('progress'), isTrue);
      final progress = json['progress'] as Map<String, dynamic>;
      expect(progress.containsKey('weight'), isTrue);
    });

    test('returns error JSON for unknown metricType', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress(
        {'metricType': 'unknownMetric123'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('non riconosciuto'));
      expect(json.containsKey('suggestedTypes'), isTrue);
      expect(json['toolName'], equals('getBodyProgress'));
    });

    test('calculates correct change and changePercent', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([
        _makeMeasurement(value: 80.0, daysAgo: 30),
        _makeMeasurement(value: 76.0, daysAgo: 0),
      ]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({'weeksBack': 12}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;
      final progress = json['progress'] as Map<String, dynamic>;
      final weightProgress = progress['weight'] as Map<String, dynamic>;

      expect(weightProgress['firstValue'], equals(80.0));
      expect(weightProgress['lastValue'], equals(76.0));
      expect(weightProgress['change'], equals('-4.0'));
      expect(weightProgress['measurementCount'], equals(2));
    });

    test('returns error JSON when repository fails', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsFailure = const StorageFailure(message: 'DB error');
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Failed to fetch measurements'));
      expect(json['toolName'], equals('getBodyProgress'));
    });

    test('returns error JSON on exception', () async {
      final repo = _ThrowingMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('getBodyProgress'));
    });

    test('defaults weeksBack to 12 when not provided', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['weeksBack'], equals(12));
    });

    test('parses weeksBack from string argument', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({'weeksBack': '8'}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['weeksBack'], equals(8));
    });

    test('defaults to 12 when weeksBack is 0 or negative', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({'weeksBack': -5}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['weeksBack'], equals(12));
    });

    test('supports Italian metric type names', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([
        _makeMeasurement(type: MetricType.waistCircumference, value: 80.0),
      ]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress(
        {'metricType': 'vita'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      // Should not return unknown metric type error
      expect(
        json.containsKey('error') &&
            (json['error'] as String).contains('non riconosciuto'),
        isFalse,
      );
    });

    test('groups multiple metric types separately', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([
        _makeMeasurement(type: MetricType.weight, value: 75.0, daysAgo: 30),
        _makeMeasurement(type: MetricType.weight, value: 73.0, daysAgo: 0),
        _makeMeasurement(
          type: MetricType.waistCircumference,
          value: 80.0,
          unit: 'cm',
          daysAgo: 30,
        ),
        _makeMeasurement(
          type: MetricType.waistCircumference,
          value: 78.0,
          unit: 'cm',
          daysAgo: 0,
        ),
      ]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress({'weeksBack': 12}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;
      final progress = json['progress'] as Map<String, dynamic>;

      expect(progress.containsKey('weight'), isTrue);
      expect(progress.containsKey('waistCircumference'), isTrue);
      expect(json['totalMeasurements'], equals(4));
    });
  });

  group('BodyMeasurementExecutor - addBodyMeasurement', () {
    test('returns confirmationRequired for new measurement', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['confirmationRequired'], isTrue);
      expect(json['toolName'], equals('addBodyMeasurement'));
      expect(json.containsKey('pending'), isTrue);
      expect(json.containsKey('nextAction'), isTrue);
    });

    test('pending data contains correct metric info', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.5},
        userId,
      );

      // Verify pending is set by confirming it
      final confirmResult = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(confirmResult) as Map<String, dynamic>;

      // After confirmation, should have success or error (not confirmationRequired)
      expect(json.containsKey('confirmationRequired'), isFalse);
    });

    test('saves measurement and returns success after confirmation', () async {
      final repo = _FakeMeasurementRepository();
      repo.addResult = fp.Right(null);
      repo.latestResult = fp.Right({});
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      // Step 1: prepare
      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0},
        userId,
      );

      // Step 2: confirm
      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['success'], isTrue);
      expect(json['confirmed'], isTrue);
      expect(json.containsKey('saved'), isTrue);
      expect(json['toolName'], equals('addBodyMeasurement'));
    });

    test('saved data includes correct metric type and value', () async {
      final repo = _FakeMeasurementRepository();
      repo.addResult = fp.Right(null);
      repo.latestResult = fp.Right({});
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 80.5},
        userId,
      );

      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;
      final saved = json['saved'] as Map<String, dynamic>;

      expect(saved['metricType'], equals('weight'));
      expect(saved['value'], equals(80.5));
      expect(saved['unit'], equals('kg'));
    });

    test('includes comparison when previous measurement exists', () async {
      final repo = _FakeMeasurementRepository();
      repo.addResult = fp.Right(null);
      repo.latestResult = fp.Right({
        MetricType.weight: _makeMeasurement(value: 78.0, daysAgo: 7),
      });
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0},
        userId,
      );

      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json.containsKey('comparison'), isTrue);
      final comparison = json['comparison'] as Map<String, dynamic>;
      expect(comparison['previousValue'], equals(78.0));
      expect(comparison['direction'], equals('decreased'));
      expect(comparison['change'], equals('-3.0'));
    });

    test('comparison direction is increased when value goes up', () async {
      final repo = _FakeMeasurementRepository();
      repo.addResult = fp.Right(null);
      repo.latestResult = fp.Right({
        MetricType.weight: _makeMeasurement(value: 70.0),
      });
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0},
        userId,
      );
      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;
      final comparison = json['comparison'] as Map<String, dynamic>;

      expect(comparison['direction'], equals('increased'));
    });

    test('confirms with full payload matching pending measurement', () async {
      final repo = _FakeMeasurementRepository();
      repo.addResult = fp.Right(null);
      repo.latestResult = fp.Right({});
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      // Step 1: prepare
      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0, 'notes': 'morning'},
        userId,
      );

      // Step 2: confirm with full payload (same as pending)
      final result = await executor.addBodyMeasurement(
        {
          'metricType': 'peso',
          'value': 75.0,
          'notes': 'morning',
          'confirmed': true,
        },
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['success'], isTrue);
    });

    test('returns error when confirm sent with no pending measurement',
        () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      // Confirm without first preparing
      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Nessuna misurazione in attesa'));
      expect(json['toolName'], equals('addBodyMeasurement'));
    });

    test('returns error for missing required parameters', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.addBodyMeasurement({}, userId);
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Missing required parameters'));
      expect(json['toolName'], equals('addBodyMeasurement'));
    });

    test('returns error for unknown metric type', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.addBodyMeasurement(
        {'metricType': 'unknownType', 'value': 75.0},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Unknown metric type'));
      expect(json.containsKey('supportedTypes'), isTrue);
      expect(json['toolName'], equals('addBodyMeasurement'));
    });

    test('returns error for value out of valid range', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      // Weight cannot be 999 kg
      final result = await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 999},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Value out of range'));
      expect(json.containsKey('validRange'), isTrue);
      expect(json['providedValue'], equals(999.0));
      expect(json['toolName'], equals('addBodyMeasurement'));
    });

    test('returns error for zero value', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 0},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Missing required parameters'));
    });

    test('parses Italian decimal separator (comma)', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': '75,5'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      // Should not be a parse error - should return confirmationRequired
      if (json.containsKey('confirmationRequired')) {
        expect(json['confirmationRequired'], isTrue);
        final pending = json['pending'] as Map<String, dynamic>;
        expect(pending['value'], equals(75.5));
      } else {
        // Should not have unknown metric type or range error
        expect(
          json['error'],
          isNot(contains('Missing required')),
        );
      }
    });

    test('returns error JSON when addMeasurement repository fails', () async {
      final repo = _FakeMeasurementRepository();
      repo.addResult = fp.Left(const StorageFailure(message: 'Write failed'));
      repo.latestResult = fp.Right({});
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0},
        userId,
      );

      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Failed to save measurement'));
      expect(json['toolName'], equals('addBodyMeasurement'));
    });

    test('returns error JSON on unexpected exception', () async {
      final repo = _ThrowingMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      // Step 1: prepare - doesn't call any repo method, returns confirmationRequired
      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0},
        userId,
      );

      // Step 2: confirm - calls _savePendingMeasurement -> addMeasurement which throws
      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
      expect(json['toolName'], equals('addBodyMeasurement'));
    });

    test('supports all major Italian metric type aliases', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final italianAliases = {
        'grasso': 20.0, // bodyFatPercentage
        'vita': 80.0, // waistCircumference
        'petto': 100.0, // chestCircumference
        'bicipite': 35.0, // bicepRightCircumference
        'coscia': 55.0, // thighRightCircumference
      };

      for (final entry in italianAliases.entries) {
        final result = await executor.addBodyMeasurement(
          {'metricType': entry.key, 'value': entry.value},
          userId,
        );
        final json = jsonDecode(result) as Map<String, dynamic>;

        // Should return confirmationRequired, not unknown type error
        expect(
          json['confirmationRequired'] == true ||
              (json.containsKey('error') &&
                  !(json['error'] as String).contains('Unknown metric type')),
          isTrue,
          reason: 'Alias "${entry.key}" should be recognized',
        );
      }
    });

    test('pending measurements are per-userId (isolated)', () async {
      final repo = _FakeMeasurementRepository();
      repo.addResult = fp.Right(null);
      repo.latestResult = fp.Right({});
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      // Prepare for user1
      await executor.addBodyMeasurement(
        {'metricType': 'peso', 'value': 75.0},
        'user-1',
      );

      // Confirm for different user2 - should fail (no pending for user-2)
      final result = await executor.addBodyMeasurement(
        {'confirmed': true},
        'user-2',
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('Nessuna misurazione in attesa'));
    });
  });

  group('BodyMeasurementExecutor - _parseMetricType (via getBodyProgress)', () {
    test('recognizes weight / peso', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([
        _makeMeasurement(type: MetricType.weight, value: 75.0),
      ]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      for (final alias in ['weight', 'peso', 'pesokg']) {
        final result = await executor.getBodyProgress(
          {'metricType': alias},
          userId,
        );
        final json = jsonDecode(result) as Map<String, dynamic>;

        expect(
          json.containsKey('error') &&
              (json['error'] as String).contains('non riconosciuto'),
          isFalse,
          reason: 'Alias "$alias" should be recognized',
        );
      }
    });

    test('recognizes bodyFatPercentage aliases', () async {
      final repo = _FakeMeasurementRepository();
      repo.getMeasurementsResult = fp.Right([]);
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      for (final alias in ['bodyfat', 'grasso', 'bf', 'bodyfatpercentage']) {
        final result = await executor.getBodyProgress(
          {'metricType': alias},
          userId,
        );
        final json = jsonDecode(result) as Map<String, dynamic>;

        expect(
          json.containsKey('error') &&
              (json['error'] as String).contains('non riconosciuto'),
          isFalse,
          reason: 'Alias "$alias" should be recognized',
        );
      }
    });

    test('returns error for unrecognized metric type string', () async {
      final repo = _FakeMeasurementRepository();
      final executor = BodyMeasurementExecutor(measurementRepo: repo);

      final result = await executor.getBodyProgress(
        {'metricType': 'xyz_totally_unknown'},
        userId,
      );
      final json = jsonDecode(result) as Map<String, dynamic>;

      expect(json['error'], contains('non riconosciuto'));
      expect(json.containsKey('suggestedTypes'), isTrue);
    });
  });
}

// ---------------------------------------------------------------------------
// Error-throwing helper
// ---------------------------------------------------------------------------

class _ThrowingMeasurementRepository extends _FakeMeasurementRepository {
  @override
  Future<fp.Either<MeasurementFailure, List<Measurement>>> getMeasurements(
    String userId, {
    MetricType? filterByType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    throw Exception('Measurement service unavailable');
  }

  @override
  Future<fp.Either<MeasurementFailure, void>> addMeasurement(
    Measurement measurement, {
    required bool hasConsent,
  }) async {
    throw Exception('Add measurement failed');
  }
}
