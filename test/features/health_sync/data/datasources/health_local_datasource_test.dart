import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_local_datasource.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../helpers/test_setup.dart';

void main() {
  late HealthLocalDatasourceImpl datasource;
  final hiveDir = Directory('./test/.hive_health_local_datasource');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockSecureStorage();

    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }

    Hive.init(hiveDir.path);
    HiveBoxManagerEnhanced.resetInitializationForTesting();
    await HiveBoxManagerEnhanced.initialize();
  });

  setUp(() async {
    datasource = HealthLocalDatasourceImpl();
    await datasource.clearMeasurements();
    await datasource.clearSyncStatuses();
  });

  tearDown(() async {
    await datasource.dispose();
    await Hive.deleteFromDisk();
    HiveBoxManagerEnhanced().resetForTesting();
  });

  test(
    'saveMeasurement skips duplicate measurements with the same fingerprint',
    () async {
      final measurement = BodyMeasurement(
        value: 80.2,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime(2026, 3, 10, 8),
        dataType: HealthDataType.bodyWeight,
        source: 'HealthKit',
      );

      await datasource.saveMeasurement(measurement);
      await datasource.saveMeasurement(measurement);

      final measurements = await datasource.getMeasurements(
        dataType: HealthDataType.bodyWeight,
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 12),
      );

      expect(measurements, hasLength(1));
      expect(measurements.first, measurement);
    },
  );

  test(
    'saveMeasurements deduplicates duplicates already stored and in the incoming batch',
    () async {
      final existingMeasurement = BodyMeasurement(
        value: 79.8,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime(2026, 3, 8, 7, 30),
        dataType: HealthDataType.bodyWeight,
        source: 'HealthKit',
      );
      final duplicateOfExisting = existingMeasurement;
      final duplicateInBatch = BodyMeasurement(
        value: 80.0,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime(2026, 3, 9, 7, 30),
        dataType: HealthDataType.bodyWeight,
        source: 'HealthKit',
      );
      final anotherDuplicateInBatch = duplicateInBatch;

      await datasource.saveMeasurement(existingMeasurement);
      await datasource.saveMeasurements([
        duplicateOfExisting,
        duplicateInBatch,
        anotherDuplicateInBatch,
      ]);

      final measurements = await datasource.getMeasurements(
        dataType: HealthDataType.bodyWeight,
        startDate: DateTime(2026, 3, 7),
        endDate: DateTime(2026, 3, 12),
      );

      expect(measurements, hasLength(2));
      expect(
        measurements.map((measurement) => measurement.recordedAt).toSet(),
        {DateTime(2026, 3, 8, 7, 30), DateTime(2026, 3, 9, 7, 30)},
      );
    },
  );
}
