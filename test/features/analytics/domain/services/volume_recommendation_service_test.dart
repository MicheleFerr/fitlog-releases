/// VolumeRecommendationService tests - sets, reps, rest, experience, goal, injury.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_recommendation_service.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

void main() {
  late VolumeRecommendationService service;

  setUp(() {
    service = const VolumeRecommendationService();
  });

  group('VolumeRecommendation', () {
    test('toString format', () {
      const rec = VolumeRecommendation(
        sets: 3,
        reps: 10,
        restSeconds: 90,
      );
      expect(rec.toString(), 'VolumeRecommendation(3 sets x 10 reps, 90s rest)');
    });

    test('rationale can be null', () {
      const rec = VolumeRecommendation(
        sets: 3,
        reps: 10,
        restSeconds: 90,
      );
      expect(rec.rationale, isNull);
    });
  });

  group('VolumeRecommendationService.calculateDefault', () {
    test('returns default 3x10 with 90s rest', () {
      final rec = service.calculateDefault();
      expect(rec.sets, VolumeRecommendationService.defaultSets);
      expect(rec.reps, VolumeRecommendationService.defaultReps);
      expect(rec.restSeconds, VolumeRecommendationService.defaultRestSeconds);
      expect(rec.rationale, isNotNull);
    });
  });

  group('VolumeRecommendationService.calculate - Compound exercises', () {
    test('strength: 4 sets x 5 reps, 180s rest (intermediate)', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.strength,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 4);
      expect(rec.reps, 5);
      expect(rec.restSeconds, 180);
    });

    test('hypertrophy: 4 sets x 8 reps, 120s rest (intermediate)', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 4);
      expect(rec.reps, 8);
      expect(rec.restSeconds, 120);
    });

    test('endurance: 3 sets x 12 reps, 60s rest (intermediate)', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.endurance,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 3);
      expect(rec.reps, 12);
      expect(rec.restSeconds, 60);
    });
  });

  group('VolumeRecommendationService.calculate - Isolation exercises', () {
    test('strength isolation: 3 sets x 8 reps, 120s rest', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.strength,
        hasInjuryHistory: false,
        exerciseType: 'Isolation',
      );
      expect(rec.sets, 3);
      expect(rec.reps, 8);
      expect(rec.restSeconds, 120);
    });

    test('hypertrophy isolation: 3 sets x 12 reps, 90s rest', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
        exerciseType: 'Isolation',
      );
      expect(rec.sets, 3);
      expect(rec.reps, 12);
      expect(rec.restSeconds, 90);
    });

    test('endurance isolation: 3 sets x 15 reps, 45s rest', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.endurance,
        hasInjuryHistory: false,
        exerciseType: 'Isolation',
      );
      expect(rec.sets, 3);
      expect(rec.reps, 15);
      expect(rec.restSeconds, 45);
    });
  });

  group('VolumeRecommendationService.calculate - Experience modifier', () {
    test('untrained reduces sets by 1', () {
      final rec = service.calculate(
        experience: ExperienceLevel.untrained,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 3); // 4 - 1
    });

    test('novice reduces sets by 1', () {
      final rec = service.calculate(
        experience: ExperienceLevel.novice,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 3); // 4 - 1
    });

    test('advanced adds 1 set', () {
      final rec = service.calculate(
        experience: ExperienceLevel.advanced,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 5); // 4 + 1
    });

    test('elite adds 1 set', () {
      final rec = service.calculate(
        experience: ExperienceLevel.elite,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 5); // 4 + 1
    });

    test('beginner minimum 2 sets (endurance compound)', () {
      final rec = service.calculate(
        experience: ExperienceLevel.untrained,
        goal: TrainingGoal.endurance,
        hasInjuryHistory: false,
      );
      expect(rec.sets, 2); // max(2, 3 - 1)
    });
  });

  group('VolumeRecommendationService.calculate - Injury modifier', () {
    test('injury reduces sets by 1', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: true,
      );
      expect(rec.sets, 3); // 4 - 1
    });

    test('injury + beginner double reduction with min 2', () {
      final rec = service.calculate(
        experience: ExperienceLevel.untrained,
        goal: TrainingGoal.endurance,
        hasInjuryHistory: true,
      );
      expect(rec.sets, 2); // max(2, max(2, 3-1) - 1) = max(2, 1) = 2
    });

    test('injury + advanced still reduces', () {
      final rec = service.calculate(
        experience: ExperienceLevel.advanced,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: true,
      );
      expect(rec.sets, 4); // (4 + 1) - 1 = 4
    });
  });

  group('VolumeRecommendationService.calculate - Rationale', () {
    test('rationale includes exercise type', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.strength,
        hasInjuryHistory: false,
      );
      expect(rec.rationale, contains('Compound'));
    });

    test('rationale includes isolation type', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.strength,
        hasInjuryHistory: false,
        exerciseType: 'Isolation',
      );
      expect(rec.rationale, contains('Isolation'));
    });

    test('rationale includes injury note when applicable', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.strength,
        hasInjuryHistory: true,
      );
      expect(rec.rationale, contains('sicurezza'));
    });

    test('rationale no injury note when no injury', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.strength,
        hasInjuryHistory: false,
      );
      expect(rec.rationale, isNot(contains('sicurezza')));
    });

    test('rationale includes experience level', () {
      final recBeg = service.calculate(
        experience: ExperienceLevel.novice,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
      );
      expect(recBeg.rationale, contains('principiante'));

      final recAdv = service.calculate(
        experience: ExperienceLevel.advanced,
        goal: TrainingGoal.hypertrophy,
        hasInjuryHistory: false,
      );
      expect(recAdv.rationale, contains('avanzato'));
    });

    test('rationale includes goal', () {
      final rec = service.calculate(
        experience: ExperienceLevel.intermediate,
        goal: TrainingGoal.strength,
        hasInjuryHistory: false,
      );
      expect(rec.rationale, contains('forza'));
    });
  });

  group('VolumeRecommendationService constants', () {
    test('defaultSets is 3', () {
      expect(VolumeRecommendationService.defaultSets, 3);
    });

    test('defaultReps is 10', () {
      expect(VolumeRecommendationService.defaultReps, 10);
    });

    test('defaultRestSeconds is 90', () {
      expect(VolumeRecommendationService.defaultRestSeconds, 90);
    });
  });
}
