/// OnboardingTourStep tests - Freezed computed properties, TourStepType,
/// BottomSheetPosition, OnboardingTourConfig helpers.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_config.dart';

void main() {
  group('OnboardingTourStep computed', () {
    OnboardingTourStep makeStep({
      TourStepType type = TourStepType.simple,
      List<String> bulletPointKeys = const [],
      int position = 0,
      int totalSteps = 5,
    }) {
      return OnboardingTourStep(
        id: 'test',
        titleKey: 'title',
        descriptionKey: 'desc',
        bulletPointKeys: bulletPointKeys,
        type: type,
        targetWidgetKey: 'widget',
        position: position,
        totalSteps: totalSteps,
      );
    }

    test('isSimple and isComplex', () {
      expect(makeStep(type: TourStepType.simple).isSimple, isTrue);
      expect(makeStep(type: TourStepType.simple).isComplex, isFalse);
      expect(makeStep(type: TourStepType.complex).isComplex, isTrue);
      expect(makeStep(type: TourStepType.complex).isSimple, isFalse);
    });

    test('hasBulletPoints', () {
      expect(makeStep().hasBulletPoints, isFalse);
      expect(
        makeStep(bulletPointKeys: ['a', 'b']).hasBulletPoints,
        isTrue,
      );
    });

    test('progress', () {
      expect(makeStep(position: 0, totalSteps: 4).progress, 0.25);
      expect(makeStep(position: 1, totalSteps: 4).progress, 0.5);
      expect(makeStep(position: 3, totalSteps: 4).progress, 1.0);
    });

    test('isFirst and isLast', () {
      expect(makeStep(position: 0, totalSteps: 5).isFirst, isTrue);
      expect(makeStep(position: 0, totalSteps: 5).isLast, isFalse);
      expect(makeStep(position: 4, totalSteps: 5).isLast, isTrue);
      expect(makeStep(position: 4, totalSteps: 5).isFirst, isFalse);
    });
  });

  group('TourStepType', () {
    test('has 2 values', () {
      expect(TourStepType.values.length, 2);
    });
  });

  group('BottomSheetPosition', () {
    test('has 2 values', () {
      expect(BottomSheetPosition.values.length, 2);
    });
  });

  group('OnboardingTourConfig', () {
    test('totalSteps is 10', () {
      expect(OnboardingTourConfig.totalSteps, 10);
    });

    test('allSteps has correct count', () {
      expect(OnboardingTourConfig.allSteps.length, 10);
    });

    test('first step is xpProgress', () {
      final first = OnboardingTourConfig.allSteps.first;
      expect(first.id, 'xpProgress');
      expect(first.position, 0);
      expect(first.isFirst, isTrue);
    });

    test('last step is settings', () {
      final last = OnboardingTourConfig.allSteps.last;
      expect(last.id, 'settings');
      expect(last.position, 9);
      expect(last.isLast, isTrue);
      expect(last.type, TourStepType.complex);
    });

    test('getStepById returns correct step', () {
      final step = OnboardingTourConfig.getStepById('startWorkout');
      expect(step, isNotNull);
      expect(step!.id, 'startWorkout');
    });

    test('getStepById returns null for unknown', () {
      expect(OnboardingTourConfig.getStepById('nonexistent'), isNull);
    });

    test('getStepByPosition returns correct step', () {
      final step = OnboardingTourConfig.getStepByPosition(0);
      expect(step, isNotNull);
      expect(step!.id, 'xpProgress');
    });

    test('getStepByPosition returns null for out of range', () {
      expect(OnboardingTourConfig.getStepByPosition(-1), isNull);
      expect(OnboardingTourConfig.getStepByPosition(10), isNull);
    });
  });
}
