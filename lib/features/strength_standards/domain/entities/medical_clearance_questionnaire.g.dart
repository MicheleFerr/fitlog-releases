// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_clearance_questionnaire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicalClearanceQuestionnaireImpl
_$$MedicalClearanceQuestionnaireImplFromJson(Map<String, dynamic> json) =>
    _$MedicalClearanceQuestionnaireImpl(
      hasHeartCondition: json['hasHeartCondition'] as bool? ?? false,
      hasChestPain: json['hasChestPain'] as bool? ?? false,
      hasChestPainAtRest: json['hasChestPainAtRest'] as bool? ?? false,
      hasDizzinessOrFainting: json['hasDizzinessOrFainting'] as bool? ?? false,
      hasBoneJointProblem: json['hasBoneJointProblem'] as bool? ?? false,
      takesHeartMedication: json['takesHeartMedication'] as bool? ?? false,
      hasOtherMedicalReason: json['hasOtherMedicalReason'] as bool? ?? false,
      isHighRiskAge: json['isHighRiskAge'] as bool? ?? false,
      hasFamilyHistory: json['hasFamilyHistory'] as bool? ?? false,
      currentSmoker: json['currentSmoker'] as bool? ?? false,
      isObese: json['isObese'] as bool? ?? false,
      hasDiabetes: json['hasDiabetes'] as bool? ?? false,
      hasHighBloodPressure: json['hasHighBloodPressure'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      userAcknowledgedRisks: json['userAcknowledgedRisks'] as bool? ?? false,
    );

Map<String, dynamic> _$$MedicalClearanceQuestionnaireImplToJson(
  _$MedicalClearanceQuestionnaireImpl instance,
) => <String, dynamic>{
  'hasHeartCondition': instance.hasHeartCondition,
  'hasChestPain': instance.hasChestPain,
  'hasChestPainAtRest': instance.hasChestPainAtRest,
  'hasDizzinessOrFainting': instance.hasDizzinessOrFainting,
  'hasBoneJointProblem': instance.hasBoneJointProblem,
  'takesHeartMedication': instance.takesHeartMedication,
  'hasOtherMedicalReason': instance.hasOtherMedicalReason,
  'isHighRiskAge': instance.isHighRiskAge,
  'hasFamilyHistory': instance.hasFamilyHistory,
  'currentSmoker': instance.currentSmoker,
  'isObese': instance.isObese,
  'hasDiabetes': instance.hasDiabetes,
  'hasHighBloodPressure': instance.hasHighBloodPressure,
  'completedAt': instance.completedAt?.toIso8601String(),
  'userAcknowledgedRisks': instance.userAcknowledgedRisks,
};
