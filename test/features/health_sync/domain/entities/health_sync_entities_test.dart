// Health Sync entities tests - HealthDataType, HealthPermissionStatus,
// HealthSyncStatus JSON, BodyMeasurement JSON + computed properties.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';

void main() {
  group('HealthDataType', () {
    test('has 8 values', () {
      expect(HealthDataType.values.length, 8);
    });

    test('displayNameKey for all types', () {
      expect(HealthDataType.workout.displayNameKey, 'healthDataTypeWorkout');
      expect(
        HealthDataType.bodyWeight.displayNameKey,
        'healthDataTypeBodyWeight',
      );
      expect(HealthDataType.height.displayNameKey, 'healthDataTypeHeight');
      expect(HealthDataType.bodyFat.displayNameKey, 'healthDataTypeBodyFat');
      expect(HealthDataType.leanMass.displayNameKey, 'healthDataTypeLeanMass');
      expect(
        HealthDataType.heartRate.displayNameKey,
        'healthDataTypeHeartRate',
      );
      expect(HealthDataType.sleep.displayNameKey, 'healthDataTypeSleep');
      expect(
        HealthDataType.nutrition.displayNameKey,
        'healthDataTypeNutrition',
      );
    });

    test('isMvp for phase 1 types', () {
      expect(HealthDataType.workout.isMvp, isTrue);
      expect(HealthDataType.bodyWeight.isMvp, isTrue);
      expect(HealthDataType.height.isMvp, isTrue);
      expect(HealthDataType.bodyFat.isMvp, isFalse);
      expect(HealthDataType.leanMass.isMvp, isFalse);
      expect(HealthDataType.heartRate.isMvp, isFalse);
      expect(HealthDataType.sleep.isMvp, isFalse);
      expect(HealthDataType.nutrition.isMvp, isFalse);
    });

    test('phaseNumber for all types', () {
      expect(HealthDataType.workout.phaseNumber, 1);
      expect(HealthDataType.bodyWeight.phaseNumber, 1);
      expect(HealthDataType.height.phaseNumber, 1);
      expect(HealthDataType.bodyFat.phaseNumber, 2);
      expect(HealthDataType.leanMass.phaseNumber, 2);
      expect(HealthDataType.heartRate.phaseNumber, 2);
      expect(HealthDataType.sleep.phaseNumber, 3);
      expect(HealthDataType.nutrition.phaseNumber, 3);
    });
  });

  group('PermissionState', () {
    test('has 5 values', () {
      expect(PermissionState.values.length, 5);
    });
  });

  group('HealthPermissionStatus', () {
    test('constructor with all fields', () {
      const status = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.bodyWeight: PermissionState.denied,
        },
        healthConnectAvailable: true,
      );
      expect(status.permissions.length, 2);
      expect(status.healthConnectAvailable, isTrue);
    });

    test('healthConnectAvailable defaults to false', () {
      const status = HealthPermissionStatus(
        permissions: {HealthDataType.workout: PermissionState.notDetermined},
      );
      expect(status.healthConnectAvailable, isFalse);
    });

    test('canSync returns true for authorized', () {
      const status = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.bodyWeight: PermissionState.denied,
        },
      );
      expect(status.canSync(HealthDataType.workout), isTrue);
      expect(status.canSync(HealthDataType.bodyWeight), isFalse);
    });

    test('canSync returns false for missing type', () {
      const status = HealthPermissionStatus(permissions: {});
      expect(status.canSync(HealthDataType.workout), isFalse);
    });

    test('canAttemptSync returns true for unverified iOS state', () {
      const status = HealthPermissionStatus(
        permissions: {HealthDataType.workout: PermissionState.unverified},
      );
      expect(status.canSync(HealthDataType.workout), isFalse);
      expect(status.canAttemptSync(HealthDataType.workout), isTrue);
      expect(status.hasAnySyncAccess, isTrue);
    });

    test('hasFullPermissions', () {
      const full = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.bodyWeight: PermissionState.authorized,
        },
      );
      expect(full.hasFullPermissions, isTrue);
      expect(full.hasPartialPermissions, isFalse);
      expect(full.hasNoPermissions, isFalse);
    });

    test('hasPartialPermissions', () {
      const partial = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.bodyWeight: PermissionState.denied,
        },
      );
      expect(partial.hasPartialPermissions, isTrue);
      expect(partial.hasFullPermissions, isFalse);
      expect(partial.hasNoPermissions, isFalse);
    });

    test('hasNoPermissions', () {
      const none = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.denied,
          HealthDataType.bodyWeight: PermissionState.notDetermined,
        },
      );
      expect(none.hasNoPermissions, isTrue);
      expect(none.hasPartialPermissions, isFalse);
      expect(none.hasFullPermissions, isFalse);
    });

    test('hasNoPermissions is false for unverified permissions', () {
      const status = HealthPermissionStatus(
        permissions: {HealthDataType.bodyWeight: PermissionState.unverified},
      );
      expect(status.hasNoPermissions, isFalse);
      expect(status.attemptableDataTypes, [HealthDataType.bodyWeight]);
      expect(status.unverifiedDataTypes, [HealthDataType.bodyWeight]);
    });

    test('authorizedDataTypes', () {
      const status = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.bodyWeight: PermissionState.denied,
          HealthDataType.height: PermissionState.authorized,
        },
      );
      expect(
        status.authorizedDataTypes,
        containsAll([HealthDataType.workout, HealthDataType.height]),
      );
      expect(status.authorizedDataTypes.length, 2);
    });

    test('deniedDataTypes', () {
      const status = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.bodyWeight: PermissionState.denied,
        },
      );
      expect(status.deniedDataTypes, [HealthDataType.bodyWeight]);
    });

    test('needsSequentialPermission', () {
      const needs = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.unverified,
          HealthDataType.bodyWeight: PermissionState.notDetermined,
        },
      );
      expect(needs.needsSequentialPermission, isTrue);

      const doesNot = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.bodyWeight: PermissionState.authorized,
        },
      );
      expect(doesNot.needsSequentialPermission, isFalse);

      const workoutNotReady = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.notDetermined,
          HealthDataType.bodyWeight: PermissionState.notDetermined,
        },
      );
      expect(workoutNotReady.needsSequentialPermission, isFalse);
    });
  });

  group('SyncResult', () {
    test('has 4 values', () {
      expect(SyncResult.values.length, 4);
    });
  });

  group('HealthSyncStatus JSON', () {
    test('round-trip with all fields', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.bodyWeight,
        lastSyncTime: DateTime(2025, 3, 1, 10, 30),
        lastResult: SyncResult.success,
        retryCount: 2,
        errorMessage: 'timeout',
      );
      final json = status.toJson();
      final restored = HealthSyncStatus.fromJson(json);
      expect(restored.dataType, HealthDataType.bodyWeight);
      expect(restored.lastSyncTime, DateTime(2025, 3, 1, 10, 30));
      expect(restored.lastResult, SyncResult.success);
      expect(restored.retryCount, 2);
      expect(restored.errorMessage, 'timeout');
    });

    test('round-trip with defaults', () {
      const status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: null,
        lastResult: SyncResult.idle,
      );
      final restored = HealthSyncStatus.fromJson(status.toJson());
      expect(restored.retryCount, 0);
      expect(restored.errorMessage, isNull);
      expect(restored.lastSyncTime, isNull);
    });

    test('round-trip all SyncResult values', () {
      for (final result in SyncResult.values) {
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: result,
        );
        final restored = HealthSyncStatus.fromJson(status.toJson());
        expect(restored.lastResult, result);
      }
    });

    test('round-trip all HealthDataType values', () {
      for (final type in HealthDataType.values) {
        final status = HealthSyncStatus(
          dataType: type,
          lastSyncTime: null,
          lastResult: SyncResult.idle,
        );
        final restored = HealthSyncStatus.fromJson(status.toJson());
        expect(restored.dataType, type);
      }
    });
  });

  group('HealthSyncStatus computed', () {
    test('shouldRetry true when error and retryCount < 3', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.error,
        retryCount: 2,
      );
      expect(status.shouldRetry(), isTrue);
    });

    test('shouldRetry false when error but retryCount >= 3', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.error,
        retryCount: 3,
      );
      expect(status.shouldRetry(), isFalse);
    });

    test('shouldRetry false when not error', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.success,
        retryCount: 0,
      );
      expect(status.shouldRetry(), isFalse);
    });

    test('shouldAutoSync true when never synced', () {
      const status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: null,
        lastResult: SyncResult.idle,
      );
      expect(status.shouldAutoSync(), isTrue);
    });

    test('shouldAutoSync true when >24h since last sync', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now().subtract(const Duration(hours: 25)),
        lastResult: SyncResult.success,
      );
      expect(status.shouldAutoSync(), isTrue);
    });

    test('shouldAutoSync false when <24h since last sync', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now().subtract(const Duration(hours: 12)),
        lastResult: SyncResult.success,
      );
      expect(status.shouldAutoSync(), isFalse);
    });

    test('statusMessageKey for idle never synced', () {
      const status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: null,
        lastResult: SyncResult.idle,
      );
      expect(status.statusMessageKey, 'healthSyncStatusNeverSynced');
    });

    test('statusMessageKey for idle with lastSync', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.idle,
      );
      expect(status.statusMessageKey, 'healthSyncStatusIdle');
    });

    test('statusMessageKey for syncing', () {
      const status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: null,
        lastResult: SyncResult.syncing,
      );
      expect(status.statusMessageKey, 'healthSyncStatusSyncing');
    });

    test('statusMessageKey for success', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.success,
      );
      expect(status.statusMessageKey, 'healthSyncStatusSuccess');
    });

    test('statusMessageKey for error', () {
      const status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: null,
        lastResult: SyncResult.error,
      );
      expect(status.statusMessageKey, 'healthSyncStatusError');
    });
  });

  group('MeasurementUnit', () {
    test('has 7 values', () {
      expect(MeasurementUnit.values.length, 7);
    });
  });

  group('BodyMeasurement JSON', () {
    test('round-trip with all fields', () {
      final m = BodyMeasurement(
        value: 80.5,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime(2025, 3, 1, 8, 0),
        dataType: HealthDataType.bodyWeight,
        source: 'HealthKit',
      );
      final json = m.toJson();
      final restored = BodyMeasurement.fromJson(json);
      expect(restored.value, 80.5);
      expect(restored.unit, MeasurementUnit.kilograms);
      expect(restored.recordedAt, DateTime(2025, 3, 1, 8, 0));
      expect(restored.dataType, HealthDataType.bodyWeight);
      expect(restored.source, 'HealthKit');
    });

    test('round-trip with null source', () {
      final m = BodyMeasurement(
        value: 175.0,
        unit: MeasurementUnit.centimeters,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.height,
      );
      final restored = BodyMeasurement.fromJson(m.toJson());
      expect(restored.source, isNull);
    });

    test('round-trip all MeasurementUnit values', () {
      for (final unit in MeasurementUnit.values) {
        final m = BodyMeasurement(
          value: 42.0,
          unit: unit,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
        );
        final restored = BodyMeasurement.fromJson(m.toJson());
        expect(restored.unit, unit);
      }
    });
  });

  group('BodyMeasurement computed', () {
    test('toKilograms from kg', () {
      final m = BodyMeasurement(
        value: 80.0,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.bodyWeight,
      );
      expect(m.toKilograms(), 80.0);
    });

    test('toKilograms from pounds', () {
      final m = BodyMeasurement(
        value: 176.37,
        unit: MeasurementUnit.pounds,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.bodyWeight,
      );
      expect(m.toKilograms(), closeTo(80.0, 0.1));
    });

    test('toKilograms throws for non-weight units', () {
      final m = BodyMeasurement(
        value: 15.0,
        unit: MeasurementUnit.percent,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.bodyFat,
      );
      expect(() => m.toKilograms(), throwsA(isA<UnsupportedError>()));
    });

    test('toPounds from kg', () {
      final m = BodyMeasurement(
        value: 80.0,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.bodyWeight,
      );
      expect(m.toPounds(), closeTo(176.37, 0.1));
    });

    test('toPounds from pounds', () {
      final m = BodyMeasurement(
        value: 176.37,
        unit: MeasurementUnit.pounds,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.bodyWeight,
      );
      expect(m.toPounds(), 176.37);
    });

    test('toPounds throws for non-weight units', () {
      final m = BodyMeasurement(
        value: 1.75,
        unit: MeasurementUnit.meters,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.height,
      );
      expect(() => m.toPounds(), throwsA(isA<UnsupportedError>()));
    });

    test('toCentimeters from meters', () {
      final m = BodyMeasurement(
        value: 1.75,
        unit: MeasurementUnit.meters,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.height,
      );
      expect(m.toCentimeters(), 175.0);
    });

    test('toCentimeters from centimeters', () {
      final m = BodyMeasurement(
        value: 175.0,
        unit: MeasurementUnit.centimeters,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.height,
      );
      expect(m.toCentimeters(), 175.0);
    });

    test('toCentimeters throws for non-height units', () {
      final m = BodyMeasurement(
        value: 80.0,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime(2025, 1, 1),
        dataType: HealthDataType.bodyWeight,
      );
      expect(() => m.toCentimeters(), throwsA(isA<UnsupportedError>()));
    });

    test('isSyncedFromHealth', () {
      expect(
        BodyMeasurement(
          value: 80,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
          source: 'HealthKit',
        ).isSyncedFromHealth,
        isTrue,
      );
      expect(
        BodyMeasurement(
          value: 80,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
          source: 'Health Connect',
        ).isSyncedFromHealth,
        isTrue,
      );
      expect(
        BodyMeasurement(
          value: 80,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
          source: 'FitLog',
        ).isSyncedFromHealth,
        isFalse,
      );
    });

    test('isManualEntry', () {
      expect(
        BodyMeasurement(
          value: 80,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
          source: 'FitLog',
        ).isManualEntry,
        isTrue,
      );
      expect(
        BodyMeasurement(
          value: 80,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
        ).isManualEntry,
        isTrue, // null source = manual
      );
      expect(
        BodyMeasurement(
          value: 80,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
          source: 'HealthKit',
        ).isManualEntry,
        isFalse,
      );
    });

    test('unitDisplayKey for all units', () {
      expect(
        BodyMeasurement(
          value: 80,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
        ).unitDisplayKey,
        'unitKilograms',
      );
      expect(
        BodyMeasurement(
          value: 176,
          unit: MeasurementUnit.pounds,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyWeight,
        ).unitDisplayKey,
        'unitPounds',
      );
      expect(
        BodyMeasurement(
          value: 15,
          unit: MeasurementUnit.percent,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.bodyFat,
        ).unitDisplayKey,
        'unitPercent',
      );
      expect(
        BodyMeasurement(
          value: 60,
          unit: MeasurementUnit.minutes,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.workout,
        ).unitDisplayKey,
        'unitMinutes',
      );
      expect(
        BodyMeasurement(
          value: 72,
          unit: MeasurementUnit.bpm,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.heartRate,
        ).unitDisplayKey,
        'unitBpm',
      );
      expect(
        BodyMeasurement(
          value: 1.75,
          unit: MeasurementUnit.meters,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.height,
        ).unitDisplayKey,
        'unitMeters',
      );
      expect(
        BodyMeasurement(
          value: 175,
          unit: MeasurementUnit.centimeters,
          recordedAt: DateTime(2025, 1, 1),
          dataType: HealthDataType.height,
        ).unitDisplayKey,
        'unitCentimeters',
      );
    });
  });
}
