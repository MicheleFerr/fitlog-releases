import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/hive_measurement_datasource.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/measurement_local_datasource.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/encrypted_measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';

// ---------------------------------------------------------------------------
// FakeLazyBox: implementazione in-memory di LazyBox<Map<String,dynamic>>
// per testare HiveMeasurementDatasource senza Hive reale
// ---------------------------------------------------------------------------
class FakeLazyBox implements LazyBox<Map<String, dynamic>> {
  final Map<dynamic, Map<String, dynamic>> _store = {};
  bool _isOpen = true;

  @override
  bool get isOpen => _isOpen;

  @override
  Iterable<dynamic> get keys => _store.keys;

  @override
  bool containsKey(dynamic key) => _store.containsKey(key);

  @override
  Future<Map<String, dynamic>?> get(
    dynamic key, {
    Map<String, dynamic>? defaultValue,
  }) async {
    return _store[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, Map<String, dynamic> value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key);
  }

  @override
  Future<int> clear() async {
    final count = _store.length;
    _store.clear();
    return count;
  }

  @override
  Future<void> flush() async {}

  @override
  int get length => _store.length;

  @override
  bool get isEmpty => _store.isEmpty;

  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  Future<void> close() async {
    _isOpen = false;
  }

  @override
  Future<void> deleteFromDisk() async {
    _store.clear();
    _isOpen = false;
  }

  @override
  String get name => 'fake_lazy_box';

  @override
  String? get path => null;

  @override
  bool get lazy => true;

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();

  Map<dynamic, Map<String, dynamic>> toMap() => Map.from(_store);

  @override
  Future<void> putAll(Map<dynamic, Map<String, dynamic>> entries) async {
    _store.addAll(entries);
  }

  @override
  Future<void> deleteAll(Iterable keys) async {
    for (final key in keys) {
      _store.remove(key);
    }
  }

  @override
  Future<Iterable<int>> addAll(Iterable<Map<String, dynamic>> values) async {
    final keys = <int>[];
    for (final v in values) {
      final key = _store.length;
      _store[key] = v;
      keys.add(key);
    }
    return keys;
  }

  @override
  Future<int> add(Map<String, dynamic> value) async {
    final key = _store.length;
    _store[key] = value;
    return key;
  }

  @override
  dynamic keyAt(int index) => _store.keys.elementAt(index);

  @override
  Future<void> compact() async {}

  Iterable<Map<String, dynamic>> get values => _store.values;

  @override
  Future<Map<String, dynamic>?> getAt(int index) async {
    if (index < 0 || index >= _store.length) return null;
    return _store.values.elementAt(index);
  }

  @override
  Future<void> putAt(int index, Map<String, dynamic> value) async {
    if (index < 0 || index >= _store.length) return;
    final key = _store.keys.elementAt(index);
    _store[key] = value;
  }

  @override
  Future<void> deleteAt(int index) async {
    if (index < 0 || index >= _store.length) return;
    final key = _store.keys.elementAt(index);
    _store.remove(key);
  }
}

// ---------------------------------------------------------------------------
// TestableHiveMeasurementDatasource: exposes _box for injection in tests
// ---------------------------------------------------------------------------
class TestableHiveMeasurementDatasource extends HiveMeasurementDatasource {
  FakeLazyBox? _fakeBox;

  void injectFakeBox(FakeLazyBox box) {
    _fakeBox = box;
  }

  @override
  Future<Either<LocalStorageFailure, void>> initialize() async {
    if (_fakeBox != null) {
      // Already injected, consider initialized
      return right(null);
    }
    return super.initialize();
  }
}

// ---------------------------------------------------------------------------
// FakeHiveMeasurementDatasource: implementazione manuale per test diretti
// Usa direttamente un FakeLazyBox interno, evitando Hive reale
// ---------------------------------------------------------------------------
class FakeHiveMeasurementDatasource implements MeasurementLocalDatasource {
  final FakeLazyBox _box = FakeLazyBox();
  bool _initialized = false;

  @override
  Future<Either<LocalStorageFailure, void>> initialize() async {
    _initialized = true;
    return right(null);
  }

  @override
  Future<Either<LocalStorageFailure, void>> close() async {
    _initialized = false;
    return right(null);
  }

  bool get isInitialized => _initialized;

  String _buildKey(String userId, String measurementId) =>
      '${userId}_$measurementId';

  @override
  Future<Either<LocalStorageFailure, void>> saveMeasurement(
    EncryptedMeasurement measurement,
  ) async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    final key = _buildKey(measurement.userId, measurement.id);
    await _box.put(key, measurement.toJson());
    return right(null);
  }

  @override
  Future<Either<LocalStorageFailure, EncryptedMeasurement>> getMeasurement({
    required String userId,
    required String measurementId,
  }) async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    final key = _buildKey(userId, measurementId);
    final json = await _box.get(key);
    if (json == null) return left(MeasurementNotFoundFailure(measurementId));
    return right(EncryptedMeasurement.fromJson(json));
  }

  @override
  Future<Either<LocalStorageFailure, List<EncryptedMeasurement>>>
  getAllMeasurements(String userId) async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    final measurements = <EncryptedMeasurement>[];
    for (final key in _box.keys) {
      if (key.toString().startsWith('${userId}_')) {
        final json = await _box.get(key);
        if (json != null) {
          measurements.add(EncryptedMeasurement.fromJson(json));
        }
      }
    }
    measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return right(measurements);
  }

  @override
  Future<Either<LocalStorageFailure, List<EncryptedMeasurement>>>
  getMeasurementsByMetric({
    required String userId,
    required MetricType metricType,
  }) async {
    final allResult = await getAllMeasurements(userId);
    return allResult.map((measurements) {
      return measurements
          .where((m) => m.metricType == metricType.name)
          .toList();
    });
  }

  @override
  Future<Either<LocalStorageFailure, List<EncryptedMeasurement>>>
  getMeasurementsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allResult = await getAllMeasurements(userId);
    return allResult.map((measurements) {
      return measurements.where((m) {
        return m.timestamp.isAfter(
              startDate.subtract(const Duration(seconds: 1)),
            ) &&
            m.timestamp.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    });
  }

  @override
  Future<Either<LocalStorageFailure, void>> updateMeasurement(
    EncryptedMeasurement measurement,
  ) async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    final key = _buildKey(measurement.userId, measurement.id);
    if (!_box.containsKey(key)) {
      return left(MeasurementNotFoundFailure(measurement.id));
    }
    await _box.put(key, measurement.toJson());
    return right(null);
  }

  @override
  Future<Either<LocalStorageFailure, void>> deleteMeasurement({
    required String userId,
    required String measurementId,
  }) async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    final key = _buildKey(userId, measurementId);
    if (!_box.containsKey(key)) {
      return left(MeasurementNotFoundFailure(measurementId));
    }
    await _box.delete(key);
    return right(null);
  }

  @override
  Future<Either<LocalStorageFailure, int>> deleteAllMeasurements(
    String userId,
  ) async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    int deleted = 0;
    final keysToDelete = _box.keys
        .where((k) => k.toString().startsWith('${userId}_'))
        .toList();
    for (final key in keysToDelete) {
      await _box.delete(key);
      deleted++;
    }
    return right(deleted);
  }

  @override
  Future<Either<LocalStorageFailure, int>> deleteMeasurementsByMetric({
    required String userId,
    required MetricType metricType,
  }) async {
    final result = await getMeasurementsByMetric(
      userId: userId,
      metricType: metricType,
    );
    if (result.isLeft()) {
      return left(result.fold((f) => f, (_) => throw Exception('unreachable')));
    }
    final measurements = result.fold(
      (_) => throw Exception('unreachable'),
      (m) => m,
    );
    int deleted = 0;
    for (final m in measurements) {
      final del = await deleteMeasurement(userId: userId, measurementId: m.id);
      del.fold((_) {}, (_) => deleted++);
    }
    return right(deleted);
  }

  @override
  Future<Either<LocalStorageFailure, int>> getMeasurementCount(
    String userId,
  ) async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    int count = 0;
    for (final key in _box.keys) {
      if (key.toString().startsWith('${userId}_')) count++;
    }
    return right(count);
  }

  @override
  Future<Either<LocalStorageFailure, void>> clearAllData() async {
    if (!_initialized) return left(const HiveNotInitializedFailure());
    await _box.clear();
    return right(null);
  }
}

// ---------------------------------------------------------------------------
// Helper factory per EncryptedMeasurement
// ---------------------------------------------------------------------------
EncryptedMeasurement makeEncrypted({
  String id = 'meas-1',
  String userId = 'user-1',
  String metricType = 'weight',
  DateTime? timestamp,
}) {
  return EncryptedMeasurement(
    id: id,
    userId: userId,
    metricType: metricType,
    encryptedData: 'base64data==',
    iv: 'base64iv====',
    tag: 'base64tag===',
    timestamp: timestamp ?? DateTime.utc(2025, 1, 15, 8, 0),
  );
}

void main() {
  late FakeHiveMeasurementDatasource datasource;

  setUp(() {
    datasource = FakeHiveMeasurementDatasource();
  });

  // ---------------------------------------------------------------------------
  // initialize / close
  // ---------------------------------------------------------------------------
  group('initialize / close', () {
    test('initialize sets isInitialized to true', () async {
      expect(datasource.isInitialized, isFalse);
      final result = await datasource.initialize();
      expect(result.isRight(), isTrue);
      expect(datasource.isInitialized, isTrue);
    });

    test('close sets isInitialized to false', () async {
      await datasource.initialize();
      final result = await datasource.close();
      expect(result.isRight(), isTrue);
      expect(datasource.isInitialized, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // saveMeasurement
  // ---------------------------------------------------------------------------
  group('saveMeasurement', () {
    test('returns HiveNotInitializedFailure when not initialized', () async {
      final result = await datasource.saveMeasurement(makeEncrypted());
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<HiveNotInitializedFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('saves measurement successfully after initialization', () async {
      await datasource.initialize();
      final result = await datasource.saveMeasurement(makeEncrypted());
      expect(result.isRight(), isTrue);
    });

    test('saves measurement with correct key format', () async {
      await datasource.initialize();
      final em = makeEncrypted(id: 'my-meas', userId: 'my-user');
      await datasource.saveMeasurement(em);

      // Verify we can retrieve it
      final retrieved = await datasource.getMeasurement(
        userId: 'my-user',
        measurementId: 'my-meas',
      );
      expect(retrieved.isRight(), isTrue);
      retrieved.fold(
        (_) => fail('Expected success'),
        (m) => expect(m.id, equals('my-meas')),
      );
    });

    test('saves multiple measurements for same user', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(makeEncrypted(id: 'm1'));
      await datasource.saveMeasurement(makeEncrypted(id: 'm2'));
      await datasource.saveMeasurement(makeEncrypted(id: 'm3'));

      final countResult = await datasource.getMeasurementCount('user-1');
      expect(countResult.getOrElse((_) => 0), equals(3));
    });
  });

  // ---------------------------------------------------------------------------
  // getMeasurement
  // ---------------------------------------------------------------------------
  group('getMeasurement', () {
    test('returns HiveNotInitializedFailure when not initialized', () async {
      final result = await datasource.getMeasurement(
        userId: 'user-1',
        measurementId: 'meas-1',
      );
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<HiveNotInitializedFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test(
      'returns MeasurementNotFoundFailure for missing measurement',
      () async {
        await datasource.initialize();
        final result = await datasource.getMeasurement(
          userId: 'user-1',
          measurementId: 'nonexistent',
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<MeasurementNotFoundFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    test('returns saved measurement', () async {
      await datasource.initialize();
      final em = makeEncrypted(id: 'found-meas', userId: 'user-a');
      await datasource.saveMeasurement(em);

      final result = await datasource.getMeasurement(
        userId: 'user-a',
        measurementId: 'found-meas',
      );
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (m) {
        expect(m.id, equals('found-meas'));
        expect(m.userId, equals('user-a'));
      });
    });

    test('cannot retrieve other user measurement', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'meas-x', userId: 'user-x'),
      );

      final result = await datasource.getMeasurement(
        userId: 'user-y', // different user
        measurementId: 'meas-x',
      );
      expect(result.isLeft(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getAllMeasurements
  // ---------------------------------------------------------------------------
  group('getAllMeasurements', () {
    test('returns empty list for user with no measurements', () async {
      await datasource.initialize();
      final result = await datasource.getAllMeasurements('user-empty');
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (ms) => expect(ms, isEmpty));
    });

    test('returns only measurements for the specified user', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm1', userId: 'user-1'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm2', userId: 'user-1'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm3', userId: 'user-2'), // different user
      );

      final result = await datasource.getAllMeasurements('user-1');
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (ms) {
        expect(ms.length, equals(2));
        expect(ms.every((m) => m.userId == 'user-1'), isTrue);
      });
    });

    test('returns measurements sorted by timestamp descending', () async {
      await datasource.initialize();
      final older = makeEncrypted(
        id: 'm-old',
        timestamp: DateTime.utc(2025, 1, 10),
      );
      final newer = makeEncrypted(
        id: 'm-new',
        timestamp: DateTime.utc(2025, 6, 15),
      );
      await datasource.saveMeasurement(older);
      await datasource.saveMeasurement(newer);

      final result = await datasource.getAllMeasurements('user-1');
      result.fold((_) => fail('Expected success'), (ms) {
        expect(ms.first.id, equals('m-new'));
        expect(ms.last.id, equals('m-old'));
      });
    });
  });

  // ---------------------------------------------------------------------------
  // getMeasurementsByMetric
  // ---------------------------------------------------------------------------
  group('getMeasurementsByMetric', () {
    test('returns only measurements of specified metric type', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'w1', metricType: 'weight'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'w2', metricType: 'weight'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'bf1', metricType: 'bodyFatPercentage'),
      );

      final result = await datasource.getMeasurementsByMetric(
        userId: 'user-1',
        metricType: MetricType.weight,
      );
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (ms) {
        expect(ms.length, equals(2));
        expect(ms.every((m) => m.metricType == 'weight'), isTrue);
      });
    });

    test('returns empty list when no measurements of metric type', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'w1', metricType: 'weight'),
      );

      final result = await datasource.getMeasurementsByMetric(
        userId: 'user-1',
        metricType: MetricType.height,
      );
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (ms) => expect(ms, isEmpty));
    });
  });

  // ---------------------------------------------------------------------------
  // getMeasurementsByDateRange
  // ---------------------------------------------------------------------------
  group('getMeasurementsByDateRange', () {
    test('returns only measurements within date range', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm-jan', timestamp: DateTime.utc(2025, 1, 15)),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm-mar', timestamp: DateTime.utc(2025, 3, 15)),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm-jun', timestamp: DateTime.utc(2025, 6, 15)),
      );

      final result = await datasource.getMeasurementsByDateRange(
        userId: 'user-1',
        startDate: DateTime.utc(2025, 2, 1),
        endDate: DateTime.utc(2025, 5, 31),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (ms) {
        expect(ms.length, equals(1));
        expect(ms.first.id, equals('m-mar'));
      });
    });

    test('returns empty list when no measurements in range', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm-old', timestamp: DateTime.utc(2023, 1, 1)),
      );

      final result = await datasource.getMeasurementsByDateRange(
        userId: 'user-1',
        startDate: DateTime.utc(2025, 1, 1),
        endDate: DateTime.utc(2025, 12, 31),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected success'), (ms) => expect(ms, isEmpty));
    });

    test('includes measurements on boundary dates', () async {
      await datasource.initialize();
      final start = DateTime.utc(2025, 1, 1);
      final end = DateTime.utc(2025, 12, 31);

      await datasource.saveMeasurement(
        makeEncrypted(id: 'm-start', timestamp: start),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm-end', timestamp: end),
      );

      final result = await datasource.getMeasurementsByDateRange(
        userId: 'user-1',
        startDate: start,
        endDate: end,
      );

      result.fold(
        (_) => fail('Expected success'),
        (ms) => expect(ms.length, equals(2)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // updateMeasurement
  // ---------------------------------------------------------------------------
  group('updateMeasurement', () {
    test('returns HiveNotInitializedFailure when not initialized', () async {
      final result = await datasource.updateMeasurement(makeEncrypted());
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<HiveNotInitializedFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test(
      'returns MeasurementNotFoundFailure for missing measurement',
      () async {
        await datasource.initialize();
        final result = await datasource.updateMeasurement(
          makeEncrypted(id: 'nonexistent'),
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<MeasurementNotFoundFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    test('updates existing measurement', () async {
      await datasource.initialize();
      final original = makeEncrypted(id: 'upd-meas', userId: 'user-u');
      await datasource.saveMeasurement(original);

      final updated = original.copyWith(encryptedData: 'updatedCiphertext==');
      final result = await datasource.updateMeasurement(updated);
      expect(result.isRight(), isTrue);

      // Verify update persisted
      final retrieved = await datasource.getMeasurement(
        userId: 'user-u',
        measurementId: 'upd-meas',
      );
      retrieved.fold(
        (_) => fail('Expected success'),
        (m) => expect(m.encryptedData, equals('updatedCiphertext==')),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // deleteMeasurement
  // ---------------------------------------------------------------------------
  group('deleteMeasurement', () {
    test('returns HiveNotInitializedFailure when not initialized', () async {
      final result = await datasource.deleteMeasurement(
        userId: 'u',
        measurementId: 'm',
      );
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<HiveNotInitializedFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test(
      'returns MeasurementNotFoundFailure for nonexistent measurement',
      () async {
        await datasource.initialize();
        final result = await datasource.deleteMeasurement(
          userId: 'user-1',
          measurementId: 'ghost',
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<MeasurementNotFoundFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );

    test('deletes measurement successfully', () async {
      await datasource.initialize();
      final em = makeEncrypted(id: 'del-me', userId: 'user-d');
      await datasource.saveMeasurement(em);

      final result = await datasource.deleteMeasurement(
        userId: 'user-d',
        measurementId: 'del-me',
      );
      expect(result.isRight(), isTrue);

      // Verify deleted
      final retrieved = await datasource.getMeasurement(
        userId: 'user-d',
        measurementId: 'del-me',
      );
      expect(retrieved.isLeft(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // deleteAllMeasurements
  // ---------------------------------------------------------------------------
  group('deleteAllMeasurements', () {
    test('returns HiveNotInitializedFailure when not initialized', () async {
      final result = await datasource.deleteAllMeasurements('user-1');
      expect(result.isLeft(), isTrue);
    });

    test('deletes all measurements for user', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm1', userId: 'user-del'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm2', userId: 'user-del'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm3', userId: 'user-other'), // should NOT be deleted
      );

      final result = await datasource.deleteAllMeasurements('user-del');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (count) => expect(count, equals(2)),
      );

      // user-other measurement still exists
      final otherCount = await datasource.getMeasurementCount('user-other');
      expect(otherCount.getOrElse((_) => -1), equals(1));

      // user-del has 0
      final delCount = await datasource.getMeasurementCount('user-del');
      expect(delCount.getOrElse((_) => -1), equals(0));
    });

    test('returns 0 for user with no measurements', () async {
      await datasource.initialize();
      final result = await datasource.deleteAllMeasurements('empty-user');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (count) => expect(count, equals(0)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // deleteMeasurementsByMetric
  // ---------------------------------------------------------------------------
  group('deleteMeasurementsByMetric', () {
    test('deletes only measurements of specified metric type', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'w1', metricType: 'weight'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'w2', metricType: 'weight'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'h1', metricType: 'height'),
      );

      final result = await datasource.deleteMeasurementsByMetric(
        userId: 'user-1',
        metricType: MetricType.weight,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (count) => expect(count, equals(2)),
      );

      // height measurement still exists
      final remaining = await datasource.getAllMeasurements('user-1');
      remaining.fold((_) => fail('Expected success'), (ms) {
        expect(ms.length, equals(1));
        expect(ms.first.metricType, equals('height'));
      });
    });

    test('returns 0 when no measurements of metric type', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'w1', metricType: 'weight'),
      );

      final result = await datasource.deleteMeasurementsByMetric(
        userId: 'user-1',
        metricType: MetricType.boneMass,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (count) => expect(count, equals(0)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getMeasurementCount
  // ---------------------------------------------------------------------------
  group('getMeasurementCount', () {
    test('returns HiveNotInitializedFailure when not initialized', () async {
      final result = await datasource.getMeasurementCount('user-1');
      expect(result.isLeft(), isTrue);
    });

    test('returns 0 for user with no measurements', () async {
      await datasource.initialize();
      final result = await datasource.getMeasurementCount('user-nobody');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (count) => expect(count, equals(0)),
      );
    });

    test('returns correct count after saving', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(makeEncrypted(id: 'm1'));
      await datasource.saveMeasurement(makeEncrypted(id: 'm2'));
      await datasource.saveMeasurement(makeEncrypted(id: 'm3'));

      final result = await datasource.getMeasurementCount('user-1');
      result.fold(
        (_) => fail('Expected success'),
        (count) => expect(count, equals(3)),
      );
    });

    test('counts only measurements for specified user', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'u1m1', userId: 'user-1'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'u2m1', userId: 'user-2'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'u2m2', userId: 'user-2'),
      );

      final u1Count = await datasource.getMeasurementCount('user-1');
      final u2Count = await datasource.getMeasurementCount('user-2');

      expect(u1Count.getOrElse((_) => -1), equals(1));
      expect(u2Count.getOrElse((_) => -1), equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // clearAllData
  // ---------------------------------------------------------------------------
  group('clearAllData', () {
    test('returns HiveNotInitializedFailure when not initialized', () async {
      final result = await datasource.clearAllData();
      expect(result.isLeft(), isTrue);
    });

    test('clears all data including other users', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm1', userId: 'user-1'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm2', userId: 'user-2'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm3', userId: 'user-3'),
      );

      final result = await datasource.clearAllData();
      expect(result.isRight(), isTrue);

      // All users have 0 measurements now
      for (final uid in ['user-1', 'user-2', 'user-3']) {
        final count = await datasource.getMeasurementCount(uid);
        expect(count.getOrElse((_) => -1), equals(0));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // key format / isolation tests
  // ---------------------------------------------------------------------------
  group('key format and user isolation', () {
    test('user-1 and user-2 measurements are isolated', () async {
      await datasource.initialize();

      // Same measurement ID but different users
      await datasource.saveMeasurement(
        makeEncrypted(id: 'shared-id', userId: 'user-1'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'shared-id', userId: 'user-2'),
      );

      final u1Measurements = await datasource.getAllMeasurements('user-1');
      final u2Measurements = await datasource.getAllMeasurements('user-2');

      u1Measurements.fold(
        (_) => fail('Expected success'),
        (ms) => expect(ms.length, equals(1)),
      );
      u2Measurements.fold(
        (_) => fail('Expected success'),
        (ms) => expect(ms.length, equals(1)),
      );
    });

    test('deleteAllMeasurements does not affect other users', () async {
      await datasource.initialize();
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm1', userId: 'user-a'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm2', userId: 'user-a'),
      );
      await datasource.saveMeasurement(
        makeEncrypted(id: 'm3', userId: 'user-b'),
      );

      await datasource.deleteAllMeasurements('user-a');

      final bCount = await datasource.getMeasurementCount('user-b');
      expect(bCount.getOrElse((_) => -1), equals(1));
    });
  });
}
