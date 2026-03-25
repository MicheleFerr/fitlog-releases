import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

void main() {
  group('InitialOnboardingState.toOnboardingData', () {
    test('persists the onboarding core Health bundle once connected', () {
      const state = InitialOnboardingState(
        goal: TrainingGoalUI.endurance,
        sex: BiologicalSex.female,
        age: 30,
        heightCm: 165,
        bodyweightKg: 60,
        experience: ExperienceLevelUI.experienced,
        healthKitConnected: true,
        selectedHealthTypes: [HealthDataType.sleep],
      );

      final data = state.toOnboardingData();

      expect(
        data!.healthKitPermissionsGranted,
        equals(['workout', 'bodyWeight', 'height', 'sleep']),
      );
    });

    test(
      'keeps Health permissions empty when the onboarding connection is skipped',
      () {
        const state = InitialOnboardingState(
          goal: TrainingGoalUI.endurance,
          sex: BiologicalSex.female,
          age: 30,
          heightCm: 165,
          bodyweightKg: 60,
          experience: ExperienceLevelUI.experienced,
          selectedHealthTypes: [HealthDataType.sleep],
        );

        final data = state.toOnboardingData();

        expect(data!.healthKitPermissionsGranted, isEmpty);
      },
    );
  });
}
