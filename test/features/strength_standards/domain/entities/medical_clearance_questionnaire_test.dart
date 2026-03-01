/// MedicalClearanceQuestionnaire unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/medical_clearance_questionnaire.dart';

void main() {
  group('cardiovascularRiskFactors', () {
    test('default has 0 risk factors', () {
      const q = MedicalClearanceQuestionnaire();
      expect(q.cardiovascularRiskFactors, 0);
    });

    test('counts all risk factors', () {
      const q = MedicalClearanceQuestionnaire(
        isHighRiskAge: true,
        hasFamilyHistory: true,
        currentSmoker: true,
        isObese: true,
        hasDiabetes: true,
        hasHighBloodPressure: true,
      );
      expect(q.cardiovascularRiskFactors, 6);
    });

    test('counts only selected risk factors', () {
      const q = MedicalClearanceQuestionnaire(
        isHighRiskAge: true,
        currentSmoker: true,
      );
      expect(q.cardiovascularRiskFactors, 2);
    });
  });

  group('needsMedicalClearance', () {
    test('default does not need clearance', () {
      const q = MedicalClearanceQuestionnaire();
      expect(q.needsMedicalClearance, false);
    });

    test('heart condition needs clearance', () {
      const q = MedicalClearanceQuestionnaire(hasHeartCondition: true);
      expect(q.needsMedicalClearance, true);
    });

    test('chest pain needs clearance', () {
      const q = MedicalClearanceQuestionnaire(hasChestPain: true);
      expect(q.needsMedicalClearance, true);
    });

    test('chest pain at rest needs clearance', () {
      const q = MedicalClearanceQuestionnaire(hasChestPainAtRest: true);
      expect(q.needsMedicalClearance, true);
    });

    test('dizziness needs clearance', () {
      const q = MedicalClearanceQuestionnaire(hasDizzinessOrFainting: true);
      expect(q.needsMedicalClearance, true);
    });

    test('bone/joint problem needs clearance', () {
      const q = MedicalClearanceQuestionnaire(hasBoneJointProblem: true);
      expect(q.needsMedicalClearance, true);
    });

    test('heart medication needs clearance', () {
      const q = MedicalClearanceQuestionnaire(takesHeartMedication: true);
      expect(q.needsMedicalClearance, true);
    });

    test('other medical reason needs clearance', () {
      const q = MedicalClearanceQuestionnaire(hasOtherMedicalReason: true);
      expect(q.needsMedicalClearance, true);
    });

    test('2+ CV risk factors needs clearance', () {
      const q = MedicalClearanceQuestionnaire(
        isHighRiskAge: true,
        currentSmoker: true,
      );
      expect(q.needsMedicalClearance, true);
    });

    test('1 CV risk factor does not need clearance', () {
      const q = MedicalClearanceQuestionnaire(isHighRiskAge: true);
      expect(q.needsMedicalClearance, false);
    });
  });

  group('canProceedWithModerateIntensity', () {
    test('default can proceed', () {
      const q = MedicalClearanceQuestionnaire();
      expect(q.canProceedWithModerateIntensity, true);
    });

    test('with red flag cannot proceed', () {
      const q = MedicalClearanceQuestionnaire(hasHeartCondition: true);
      expect(q.canProceedWithModerateIntensity, false);
    });
  });

  group('clearanceLevel', () {
    test('default is cleared', () {
      const q = MedicalClearanceQuestionnaire();
      expect(q.clearanceLevel, ClearanceLevel.cleared);
    });

    test('1 risk factor => proceedWithCaution', () {
      const q = MedicalClearanceQuestionnaire(isHighRiskAge: true);
      expect(q.clearanceLevel, ClearanceLevel.proceedWithCaution);
    });

    test('2+ risk factors => medicalClearanceRequired', () {
      const q = MedicalClearanceQuestionnaire(
        isHighRiskAge: true,
        currentSmoker: true,
      );
      expect(q.clearanceLevel, ClearanceLevel.medicalClearanceRequired);
    });

    test('red flag => medicalClearanceRequired', () {
      const q = MedicalClearanceQuestionnaire(hasChestPain: true);
      expect(q.clearanceLevel, ClearanceLevel.medicalClearanceRequired);
    });
  });

  group('getClearanceMessage', () {
    test('cleared - English', () {
      const q = MedicalClearanceQuestionnaire();
      expect(q.getClearanceMessage('en'), contains('safely'));
    });

    test('cleared - Italian', () {
      const q = MedicalClearanceQuestionnaire();
      expect(q.getClearanceMessage('it'), contains('sicurezza'));
    });

    test('proceedWithCaution - English', () {
      const q = MedicalClearanceQuestionnaire(isHighRiskAge: true);
      expect(q.getClearanceMessage('en'), contains('caution'));
    });

    test('proceedWithCaution - Italian', () {
      const q = MedicalClearanceQuestionnaire(isHighRiskAge: true);
      expect(q.getClearanceMessage('it'), contains('cautela'));
    });

    test('medicalClearanceRequired - English', () {
      const q = MedicalClearanceQuestionnaire(hasHeartCondition: true);
      expect(q.getClearanceMessage('en'), contains('doctor'));
    });

    test('medicalClearanceRequired - Italian', () {
      const q = MedicalClearanceQuestionnaire(hasHeartCondition: true);
      expect(q.getClearanceMessage('it'), contains('medico'));
    });
  });

  group('ClearanceLevel', () {
    test('has 3 values', () {
      expect(ClearanceLevel.values.length, 3);
    });
  });
}
