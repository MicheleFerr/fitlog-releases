import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';

void main() {
  final now = DateTime(2025, 6, 15, 9, 30);

  Measurement _makeMeasurement({
    String id = 'meas-1',
    String userId = 'user-1',
    MetricType metricType = MetricType.weight,
    double value = 75.5,
    String unit = 'kg',
    MeasurementSource source = MeasurementSource.manual,
    bool isDeleted = false,
  }) {
    return Measurement(
      id: id,
      userId: userId,
      metricType: metricType,
      value: value,
      unit: unit,
      timestamp: now,
      source: source,
      isDeleted: isDeleted,
    );
  }

  // ---------------------------------------------------------------------------
  // Measurement construction
  // ---------------------------------------------------------------------------
  group('Measurement construction', () {
    test('creates with all required fields', () {
      final m = _makeMeasurement();

      expect(m.id, 'meas-1');
      expect(m.userId, 'user-1');
      expect(m.metricType, MetricType.weight);
      expect(m.value, 75.5);
      expect(m.unit, 'kg');
      expect(m.timestamp, now);
      expect(m.source, MeasurementSource.manual);
    });

    test('defaults isDeleted to false', () {
      final m = _makeMeasurement();

      expect(m.isDeleted, isFalse);
    });

    test('optional fields default to null', () {
      final m = _makeMeasurement();

      expect(m.notes, isNull);
      expect(m.createdAt, isNull);
      expect(m.updatedAt, isNull);
      expect(m.deletedAt, isNull);
    });

    test('accepts optional notes', () {
      final m = _makeMeasurement().copyWith(notes: 'Morning measurement');

      expect(m.notes, 'Morning measurement');
    });

    test('marks measurement as soft-deleted', () {
      final m = _makeMeasurement(isDeleted: true).copyWith(deletedAt: now);

      expect(m.isDeleted, isTrue);
      expect(m.deletedAt, now);
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith immutability
  // ---------------------------------------------------------------------------
  group('Measurement.copyWith', () {
    test('returns new instance without mutating original', () {
      final original = _makeMeasurement(value: 75.0);
      final updated = original.copyWith(value: 76.0);

      expect(updated.value, 76.0);
      expect(original.value, 75.0);
    });

    test('can update source', () {
      final m = _makeMeasurement(source: MeasurementSource.manual).copyWith(
        source: MeasurementSource.healthKit,
      );

      expect(m.source, MeasurementSource.healthKit);
    });

    test('can mark as deleted', () {
      final m = _makeMeasurement().copyWith(
        isDeleted: true,
        deletedAt: now,
      );

      expect(m.isDeleted, isTrue);
      expect(m.deletedAt, now);
    });
  });

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------
  group('Measurement equality', () {
    test('identical measurements are equal', () {
      final a = _makeMeasurement(id: 'same');
      final b = _makeMeasurement(id: 'same');

      expect(a, equals(b));
    });

    test('measurements with different ids are not equal', () {
      final a = _makeMeasurement(id: 'a');
      final b = _makeMeasurement(id: 'b');

      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // JSON round-trip
  // ---------------------------------------------------------------------------
  group('Measurement JSON', () {
    test('fromJson/toJson preserves required fields', () {
      final original = _makeMeasurement(
        id: 'json-1',
        userId: 'json-user',
        metricType: MetricType.bodyFatPercentage,
        value: 18.5,
        unit: '%',
        source: MeasurementSource.calculated,
      );

      final json = original.toJson();
      final restored = Measurement.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.metricType, original.metricType);
      expect(restored.value, original.value);
      expect(restored.unit, original.unit);
      expect(restored.source, original.source);
      expect(restored.timestamp, original.timestamp);
    });

    test('fromJson/toJson preserves isDeleted flag', () {
      final original = _makeMeasurement(isDeleted: true).copyWith(
        deletedAt: now,
      );

      final json = original.toJson();
      final restored = Measurement.fromJson(json);

      expect(restored.isDeleted, isTrue);
      expect(restored.deletedAt, now);
    });

    test('fromJson/toJson preserves notes', () {
      final original = _makeMeasurement().copyWith(
        notes: 'After breakfast',
      );

      final json = original.toJson();
      final restored = Measurement.fromJson(json);

      expect(restored.notes, 'After breakfast');
    });
  });

  // ---------------------------------------------------------------------------
  // SyncStatus enum
  // ---------------------------------------------------------------------------
  group('SyncStatus', () {
    test('has 4 values', () {
      expect(SyncStatus.values.length, 4);
    });

    test('contains expected statuses', () {
      expect(SyncStatus.values, contains(SyncStatus.pending));
      expect(SyncStatus.values, contains(SyncStatus.synced));
      expect(SyncStatus.values, contains(SyncStatus.conflict));
      expect(SyncStatus.values, contains(SyncStatus.failed));
    });
  });

  // ---------------------------------------------------------------------------
  // MeasurementMetadata
  // ---------------------------------------------------------------------------
  group('MeasurementMetadata construction', () {
    test('creates with defaults', () {
      const meta = MeasurementMetadata();

      expect(meta.syncStatus, SyncStatus.pending);
      expect(meta.isValidated, isFalse);
      expect(meta.deviceInfo, isNull);
      expect(meta.appVersion, isNull);
      expect(meta.syncError, isNull);
    });

    test('accepts custom sync status', () {
      const meta = MeasurementMetadata(syncStatus: SyncStatus.synced);

      expect(meta.syncStatus, SyncStatus.synced);
    });

    test('fromJson/toJson round-trip for MeasurementMetadata', () {
      const original = MeasurementMetadata(
        syncStatus: SyncStatus.failed,
        isValidated: true,
        syncError: 'Network timeout',
        appVersion: '1.0.0+49',
      );

      final json = original.toJson();
      final restored = MeasurementMetadata.fromJson(json);

      expect(restored.syncStatus, SyncStatus.failed);
      expect(restored.isValidated, isTrue);
      expect(restored.syncError, 'Network timeout');
      expect(restored.appVersion, '1.0.0+49');
    });
  });
}
