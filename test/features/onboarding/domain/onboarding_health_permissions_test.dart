import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/utils/onboarding_health_permissions.dart';

void main() {
  group('buildOnboardingHealthPermissionRequest', () {
    test('always includes the onboarding core bundle', () {
      expect(
        buildOnboardingHealthPermissionRequest(const []),
        equals([
          HealthDataType.workout,
          HealthDataType.bodyWeight,
          HealthDataType.height,
        ]),
      );
    });

    test('appends optional types without duplicates', () {
      expect(
        buildOnboardingHealthPermissionRequest(const [
          HealthDataType.sleep,
          HealthDataType.workout,
          HealthDataType.heartRate,
        ]),
        equals([
          HealthDataType.workout,
          HealthDataType.bodyWeight,
          HealthDataType.height,
          HealthDataType.sleep,
          HealthDataType.heartRate,
        ]),
      );
    });
  });

  group('missingOnboardingCoreHealthTypes', () {
    test('returns only core types that cannot be attempted', () {
      const status = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.unverified,
          HealthDataType.bodyWeight: PermissionState.denied,
          HealthDataType.height: PermissionState.notDetermined,
          HealthDataType.sleep: PermissionState.authorized,
        },
      );

      expect(
        missingOnboardingCoreHealthTypes(status),
        equals([HealthDataType.bodyWeight, HealthDataType.height]),
      );
    });
  });

  group('onboardingHealthPermissionNames', () {
    test('returns an empty list until HealthKit is connected', () {
      expect(
        onboardingHealthPermissionNames(
          healthKitConnected: false,
          selectedTypes: const [HealthDataType.sleep],
        ),
        isEmpty,
      );
    });

    test(
      'includes the core bundle plus optional selections once connected',
      () {
        expect(
          onboardingHealthPermissionNames(
            healthKitConnected: true,
            selectedTypes: const [HealthDataType.sleep],
          ),
          equals(['workout', 'bodyWeight', 'height', 'sleep']),
        );
      },
    );
  });
}
