import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_clearance_questionnaire.freezed.dart';
part 'medical_clearance_questionnaire.g.dart';

/// PAR-Q+ inspired medical clearance questionnaire.
///
/// Based on:
/// - Bredin SSD et al. (2013) "PAR-Q+ and ePARmed-X+" PMCID: PMC3596208
/// - ACSM Pre-participation Screening (Whitfield GP et al. 2017)
///
/// Administered BEFORE fitness questionnaire to ensure safety.
@freezed
abstract class MedicalClearanceQuestionnaire with _$MedicalClearanceQuestionnaire {
  const factory MedicalClearanceQuestionnaire({
    // Core PAR-Q+ questions (simplified for app context)

    /// Has doctor ever said you have heart condition?
    @Default(false) bool hasHeartCondition,

    /// Do you feel pain in chest during physical activity?
    @Default(false) bool hasChestPain,

    /// In past month, chest pain when NOT doing physical activity?
    @Default(false) bool hasChestPainAtRest,

    /// Do you lose balance because of dizziness or consciousness?
    @Default(false) bool hasDizzinessOrFainting,

    /// Bone or joint problem that could worsen with activity?
    @Default(false) bool hasBoneJointProblem,

    /// Currently taking medication for blood pressure or heart?
    @Default(false) bool takesHeartMedication,

    /// Any other reason you should not do physical activity?
    @Default(false) bool hasOtherMedicalReason,

    // Additional ACSM screening

    /// Age ≥45 for men, ≥55 for women (higher risk)
    @Default(false) bool isHighRiskAge,

    /// Family history cardiovascular disease before age 55
    @Default(false) bool hasFamilyHistory,

    /// Currently smoke or quit within 6 months
    @Default(false) bool currentSmoker,

    /// BMI ≥30 or waist >102cm (men) or >88cm (women)
    @Default(false) bool isObese,

    /// Diabetes (Type 1 or 2)
    @Default(false) bool hasDiabetes,

    /// High blood pressure (≥140/90 or on medication)
    @Default(false) bool hasHighBloodPressure,

    // Metadata
    DateTime? completedAt,
    @Default(false) bool userAcknowledgedRisks,
  }) = _MedicalClearanceQuestionnaire;

  factory MedicalClearanceQuestionnaire.fromJson(Map<String, dynamic> json) =>
      _$MedicalClearanceQuestionnaireFromJson(json);
}

/// Extension for medical clearance logic
extension MedicalClearanceExtension on MedicalClearanceQuestionnaire {
  /// Number of cardiovascular risk factors (ACSM criteria)
  int get cardiovascularRiskFactors {
    int count = 0;
    if (isHighRiskAge) count++;
    if (hasFamilyHistory) count++;
    if (currentSmoker) count++;
    if (isObese) count++;
    if (hasDiabetes) count++;
    if (hasHighBloodPressure) count++;
    return count;
  }

  /// Whether user needs medical clearance before exercise
  /// Based on ACSM algorithm (Whitfield 2017)
  bool get needsMedicalClearance {
    // Any PAR-Q+ red flags = immediate referral
    if (hasHeartCondition ||
        hasChestPain ||
        hasChestPainAtRest ||
        hasDizzinessOrFainting ||
        hasBoneJointProblem ||
        takesHeartMedication ||
        hasOtherMedicalReason) {
      return true;
    }

    // ACSM: ≥2 CV risk factors + sedentary = medical clearance recommended
    if (cardiovascularRiskFactors >= 2) {
      return true;
    }

    return false;
  }

  /// Whether user can proceed with moderate-intensity exercise
  bool get canProceedWithModerateIntensity {
    // No red flags and <2 risk factors
    return !needsMedicalClearance;
  }

  /// Clearance level for exercise
  ClearanceLevel get clearanceLevel {
    if (needsMedicalClearance) {
      return ClearanceLevel.medicalClearanceRequired;
    }

    if (cardiovascularRiskFactors == 1) {
      return ClearanceLevel.proceedWithCaution;
    }

    return ClearanceLevel.cleared;
  }

  /// User-friendly message based on clearance
  String getClearanceMessage(String locale) {
    switch (clearanceLevel) {
      case ClearanceLevel.cleared:
        return locale.startsWith('it')
            ? 'Puoi procedere in sicurezza con l\'allenamento'
            : 'You can safely proceed with training';

      case ClearanceLevel.proceedWithCaution:
        return locale.startsWith('it')
            ? 'Procedi con cautela. Inizia con carichi leggeri.'
            : 'Proceed with caution. Start with light weights.';

      case ClearanceLevel.medicalClearanceRequired:
        return locale.startsWith('it')
            ? 'Consulta un medico prima di iniziare l\'allenamento'
            : 'Please consult a doctor before starting exercise';
    }
  }
}

/// Medical clearance level
enum ClearanceLevel {
  /// No risk factors, can proceed normally
  cleared,

  /// 1 risk factor, proceed with caution
  proceedWithCaution,

  /// Medical clearance required before exercise
  medicalClearanceRequired,
}
