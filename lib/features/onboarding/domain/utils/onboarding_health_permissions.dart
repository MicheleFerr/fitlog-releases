import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';

const onboardingCoreHealthTypes = <HealthDataType>[
  HealthDataType.workout,
  HealthDataType.bodyWeight,
  HealthDataType.height,
];

List<HealthDataType> buildOnboardingHealthPermissionRequest(
  Iterable<HealthDataType> selectedTypes,
) {
  final requestedTypes = <HealthDataType>[];
  final seenTypes = <HealthDataType>{};

  for (final type in onboardingCoreHealthTypes) {
    if (seenTypes.add(type)) {
      requestedTypes.add(type);
    }
  }

  for (final type in selectedTypes) {
    if (seenTypes.add(type)) {
      requestedTypes.add(type);
    }
  }

  return requestedTypes;
}

List<HealthDataType> missingOnboardingCoreHealthTypes(
  HealthPermissionStatus status,
) {
  return onboardingCoreHealthTypes
      .where((type) => !status.canAttemptSync(type))
      .toList();
}

List<String> onboardingHealthPermissionNames({
  required bool healthKitConnected,
  required Iterable<HealthDataType> selectedTypes,
}) {
  if (!healthKitConnected) {
    return const [];
  }

  return buildOnboardingHealthPermissionRequest(
    selectedTypes,
  ).map((type) => type.name).toList();
}
