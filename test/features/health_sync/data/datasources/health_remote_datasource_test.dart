import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart' as health_pkg;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/health_sync/data/datasources/health_remote_datasource.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';

class MockHealth extends Mock implements health_pkg.Health {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthRemoteDatasourceImpl iOS permission handling', () {
    late MockHealth health;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      health = MockHealth();
      when(() => health.configure()).thenAnswer((_) async {});
    });

    HealthRemoteDatasourceImpl buildSubject() {
      return HealthRemoteDatasourceImpl(
        health: health,
        sharedPreferencesFactory: SharedPreferences.getInstance,
        isIOSOverride: true,
        isAndroidOverride: false,
      );
    }

    health_pkg.HealthDataType mapType(HealthDataType dataType) {
      switch (dataType) {
        case HealthDataType.workout:
          return health_pkg.HealthDataType.WORKOUT;
        case HealthDataType.bodyWeight:
          return health_pkg.HealthDataType.WEIGHT;
        case HealthDataType.height:
          return health_pkg.HealthDataType.HEIGHT;
        case HealthDataType.bodyFat:
          return health_pkg.HealthDataType.BODY_FAT_PERCENTAGE;
        case HealthDataType.leanMass:
          return health_pkg.HealthDataType.LEAN_BODY_MASS;
        case HealthDataType.heartRate:
          return health_pkg.HealthDataType.HEART_RATE;
        case HealthDataType.sleep:
          return health_pkg.HealthDataType.SLEEP_ASLEEP;
        case HealthDataType.nutrition:
          return health_pkg.HealthDataType.NUTRITION;
      }
    }

    health_pkg.HealthDataAccess mapAccess(HealthDataType dataType) {
      if (dataType == HealthDataType.workout ||
          dataType == HealthDataType.bodyWeight) {
        return health_pkg.HealthDataAccess.READ_WRITE;
      }

      return health_pkg.HealthDataAccess.READ;
    }

    void stubAllPermissionChecks({bool? readResult, bool? writeResult}) {
      for (final dataType in HealthDataType.values) {
        final healthType = mapType(dataType);
        final access = mapAccess(dataType);
        when(
          () => health.hasPermissions([healthType], permissions: [access]),
        ).thenAnswer((_) async => readResult);

        if (access != health_pkg.HealthDataAccess.READ) {
          when(
            () => health.hasPermissions(
              [healthType],
              permissions: [health_pkg.HealthDataAccess.WRITE],
            ),
          ).thenAnswer((_) async => writeResult);
        }
      }
    }

    test(
      'requestPermissions stores iOS requested types and returns unverified when read state is not disclosed',
      () async {
        final subject = buildSubject();
        when(
          () => health.requestAuthorization(
            [health_pkg.HealthDataType.WEIGHT],
            permissions: [health_pkg.HealthDataAccess.READ_WRITE],
          ),
        ).thenAnswer((_) async => true);
        when(
          () => health.hasPermissions(
            [health_pkg.HealthDataType.WEIGHT],
            permissions: [health_pkg.HealthDataAccess.READ_WRITE],
          ),
        ).thenAnswer((_) async => null);
        when(
          () => health.hasPermissions(
            [health_pkg.HealthDataType.WEIGHT],
            permissions: [health_pkg.HealthDataAccess.WRITE],
          ),
        ).thenAnswer((_) async => null);

        final status = await subject.requestPermissions(
          dataTypes: [HealthDataType.bodyWeight],
        );

        expect(
          status.permissions[HealthDataType.bodyWeight],
          PermissionState.unverified,
        );

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('health_sync_ios_requested_permissions'),
          contains(HealthDataType.bodyWeight.name),
        );
      },
    );

    test(
      'checkPermissionStatus returns notDetermined before request and unverified after persisted iOS request marker',
      () async {
        stubAllPermissionChecks(readResult: null, writeResult: null);
        final subject = buildSubject();

        final initialStatus = await subject.checkPermissionStatus();
        expect(
          initialStatus.permissions[HealthDataType.height],
          PermissionState.notDetermined,
        );
        expect(
          initialStatus.permissions[HealthDataType.workout],
          PermissionState.notDetermined,
        );

        SharedPreferences.setMockInitialValues({
          'health_sync_ios_requested_permissions': [HealthDataType.height.name],
        });

        final updatedSubject = buildSubject();
        final updatedStatus = await updatedSubject.checkPermissionStatus();
        expect(
          updatedStatus.permissions[HealthDataType.height],
          PermissionState.unverified,
        );
        expect(
          updatedStatus.permissions[HealthDataType.workout],
          PermissionState.notDetermined,
        );
      },
    );
  });
}
