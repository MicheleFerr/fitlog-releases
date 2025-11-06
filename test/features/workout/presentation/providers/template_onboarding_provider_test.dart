import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/template_onboarding_provider.dart';

void main() {
  group('TemplateOnboardingState', () {
    test('should create with default values', () {
      const state = TemplateOnboardingState();

      expect(state.hasSeenOnboarding, isFalse);
      expect(state.currentStep, equals(0));
      expect(state.isActive, isFalse);
    });

    test('should create with custom values', () {
      const state = TemplateOnboardingState(
        hasSeenOnboarding: true,
        currentStep: 2,
        isActive: true,
      );

      expect(state.hasSeenOnboarding, isTrue);
      expect(state.currentStep, equals(2));
      expect(state.isActive, isTrue);
    });

    test('copyWith should update hasSeenOnboarding only', () {
      const original = TemplateOnboardingState();

      final updated = original.copyWith(hasSeenOnboarding: true);

      expect(updated.hasSeenOnboarding, isTrue);
      expect(updated.currentStep, equals(0));
      expect(updated.isActive, isFalse);
    });

    test('copyWith should update currentStep only', () {
      const original = TemplateOnboardingState();

      final updated = original.copyWith(currentStep: 3);

      expect(updated.hasSeenOnboarding, isFalse);
      expect(updated.currentStep, equals(3));
      expect(updated.isActive, isFalse);
    });

    test('copyWith should update isActive only', () {
      const original = TemplateOnboardingState();

      final updated = original.copyWith(isActive: true);

      expect(updated.hasSeenOnboarding, isFalse);
      expect(updated.currentStep, equals(0));
      expect(updated.isActive, isTrue);
    });

    test('copyWith should update multiple fields', () {
      const original = TemplateOnboardingState();

      final updated = original.copyWith(
        hasSeenOnboarding: true,
        currentStep: 2,
        isActive: true,
      );

      expect(updated.hasSeenOnboarding, isTrue);
      expect(updated.currentStep, equals(2));
      expect(updated.isActive, isTrue);
    });

    test('copyWith should return new instance with unchanged values when no params', () {
      const original = TemplateOnboardingState(
        hasSeenOnboarding: true,
        currentStep: 2,
        isActive: true,
      );

      final updated = original.copyWith();

      expect(updated.hasSeenOnboarding, equals(original.hasSeenOnboarding));
      expect(updated.currentStep, equals(original.currentStep));
      expect(updated.isActive, equals(original.isActive));
    });
  });
}
