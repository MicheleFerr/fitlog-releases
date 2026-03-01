// Tests for the value types declared in measurement_repository.dart
// Covers: SyncResult, SyncConflict, MeasurementFailure subtypes, enums
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';

void main() {
  final baseTime = DateTime(2025, 6, 15, 10, 0);

  Measurement _makeMeasurement({
    String id = 'meas-1',
    String userId = 'user-1',
    MetricType metricType = MetricType.weight,
    double value = 75.0,
  }) {
    return Measurement(
      id: id,
      userId: userId,
      metricType: metricType,
      value: value,
      unit: metricType.defaultUnit,
      timestamp: baseTime,
      source: MeasurementSource.manual,
    );
  }

  // ---------------------------------------------------------------------------
  // SyncResult
  // ---------------------------------------------------------------------------
  group('SyncResult', () {
    test('stores readCount, writeCount, conflictCount, syncedAt', () {
      final result = SyncResult(
        readCount: 5,
        writeCount: 3,
        conflictCount: 1,
        syncedAt: baseTime,
      );

      expect(result.readCount, 5);
      expect(result.writeCount, 3);
      expect(result.conflictCount, 1);
      expect(result.syncedAt, baseTime);
    });

    test('importedMeasurements defaults to empty list', () {
      final result = SyncResult(
        readCount: 0,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: baseTime,
      );

      expect(result.importedMeasurements, isEmpty);
    });

    test('importedMeasurements can be provided', () {
      final m = _makeMeasurement();
      final result = SyncResult(
        readCount: 1,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: baseTime,
        importedMeasurements: [m],
      );

      expect(result.importedMeasurements.length, 1);
      expect(result.importedMeasurements.first.id, 'meas-1');
    });

    test('zero counts are valid', () {
      final result = SyncResult(
        readCount: 0,
        writeCount: 0,
        conflictCount: 0,
        syncedAt: baseTime,
      );

      expect(result.readCount, 0);
      expect(result.writeCount, 0);
      expect(result.conflictCount, 0);
    });

    test('can handle large counts', () {
      final result = SyncResult(
        readCount: 10000,
        writeCount: 5000,
        conflictCount: 42,
        syncedAt: baseTime,
      );

      expect(result.readCount, 10000);
      expect(result.writeCount, 5000);
      expect(result.conflictCount, 42);
    });
  });

  // ---------------------------------------------------------------------------
  // SyncDirection enum
  // ---------------------------------------------------------------------------
  group('SyncDirection', () {
    test('has 3 values', () {
      expect(SyncDirection.values.length, 3);
    });

    test('contains read, write, both', () {
      expect(SyncDirection.values, contains(SyncDirection.read));
      expect(SyncDirection.values, contains(SyncDirection.write));
      expect(SyncDirection.values, contains(SyncDirection.both));
    });
  });

  // ---------------------------------------------------------------------------
  // SyncConflict
  // ---------------------------------------------------------------------------
  group('SyncConflict', () {
    test('stores id, deviceVersion, cloudVersion, detectedAt', () {
      final device = _makeMeasurement(value: 75.0);
      final cloud = _makeMeasurement(value: 76.5);

      final conflict = SyncConflict(
        id: 'conflict-1',
        deviceVersion: device,
        cloudVersion: cloud,
        detectedAt: baseTime,
      );

      expect(conflict.id, 'conflict-1');
      expect(conflict.deviceVersion.value, 75.0);
      expect(conflict.cloudVersion.value, 76.5);
      expect(conflict.detectedAt, baseTime);
    });

    test('device and cloud versions can be the same measurement type', () {
      final device = _makeMeasurement(
        id: 'same-id',
        metricType: MetricType.bodyFatPercentage,
        value: 18.5,
      );
      final cloud = _makeMeasurement(
        id: 'same-id',
        metricType: MetricType.bodyFatPercentage,
        value: 20.0,
      );

      final conflict = SyncConflict(
        id: 'conflict-bf',
        deviceVersion: device,
        cloudVersion: cloud,
        detectedAt: baseTime,
      );

      expect(conflict.deviceVersion.metricType, MetricType.bodyFatPercentage);
      expect(conflict.cloudVersion.metricType, MetricType.bodyFatPercentage);
      expect(conflict.deviceVersion.value, isNot(equals(conflict.cloudVersion.value)));
    });
  });

  // ---------------------------------------------------------------------------
  // ConflictResolution enum
  // ---------------------------------------------------------------------------
  group('ConflictResolution', () {
    test('has 3 values', () {
      expect(ConflictResolution.values.length, 3);
    });

    test('contains keepDevice, keepCloud, keepBoth', () {
      expect(ConflictResolution.values, contains(ConflictResolution.keepDevice));
      expect(ConflictResolution.values, contains(ConflictResolution.keepCloud));
      expect(ConflictResolution.values, contains(ConflictResolution.keepBoth));
    });
  });

  // ---------------------------------------------------------------------------
  // MeasurementFailure subtypes
  // ---------------------------------------------------------------------------
  group('MeasurementFailure subtypes', () {
    test('ConsentRequiredFailure stores metricType', () {
      const failure = ConsentRequiredFailure(MetricType.weight);
      expect(failure.metricType, MetricType.weight);
      expect(failure, isA<MeasurementFailure>());
    });

    test('ConsentRequiredFailure stores different metric types', () {
      const failure1 = ConsentRequiredFailure(MetricType.bodyFatPercentage);
      const failure2 = ConsentRequiredFailure(MetricType.waistCircumference);

      expect(failure1.metricType, MetricType.bodyFatPercentage);
      expect(failure2.metricType, MetricType.waistCircumference);
    });

    test('ValidationFailure stores message', () {
      const failure = ValidationFailure('Weight out of range');
      expect(failure.message, 'Weight out of range');
      expect(failure, isA<MeasurementFailure>());
    });

    test('StorageFailure stores message and optional error', () {
      const failure = StorageFailure(message: 'Disk full');
      expect(failure.message, 'Disk full');
      expect(failure.error, isNull);
      expect(failure, isA<MeasurementFailure>());
    });

    test('StorageFailure stores error object', () {
      final error = Exception('Connection timeout');
      final failure = StorageFailure(message: 'Network error', error: error);

      expect(failure.message, 'Network error');
      expect(failure.error, equals(error));
    });

    test('MeasurementNotFoundFailure stores measurementId', () {
      const failure = MeasurementNotFoundFailure('uuid-123');
      expect(failure.measurementId, 'uuid-123');
      expect(failure, isA<MeasurementFailure>());
    });

    test('SyncConflictFailure stores message', () {
      const failure = SyncConflictFailure('Conflict detected for measurement-5');
      expect(failure.message, 'Conflict detected for measurement-5');
      expect(failure, isA<MeasurementFailure>());
    });

    test('HealthPlatformFailure stores message and optional error', () {
      const failure = HealthPlatformFailure(message: 'HealthKit unavailable');
      expect(failure.message, 'HealthKit unavailable');
      expect(failure.error, isNull);
      expect(failure, isA<MeasurementFailure>());
    });

    test('HealthPlatformFailure stores error object', () {
      final err = Exception('Permission denied');
      final failure = HealthPlatformFailure(message: 'Access denied', error: err);

      expect(failure.error, equals(err));
    });

    test('MeasurementFailure subtypes are distinct types', () {
      const consent = ConsentRequiredFailure(MetricType.weight);
      const validation = ValidationFailure('msg');
      const storage = StorageFailure(message: 'msg');

      expect(consent, isNot(isA<ValidationFailure>()));
      expect(validation, isNot(isA<StorageFailure>()));
      expect(storage, isNot(isA<ConsentRequiredFailure>()));
    });
  });
}
