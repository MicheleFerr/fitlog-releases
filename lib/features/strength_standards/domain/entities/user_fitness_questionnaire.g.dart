// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_fitness_questionnaire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserFitnessQuestionnaire _$UserFitnessQuestionnaireFromJson(
  Map<String, dynamic> json,
) => _UserFitnessQuestionnaire(
  bodyweightKg: (json['bodyweightKg'] as num).toDouble(),
  age: (json['age'] as num).toInt(),
  heightCm: (json['heightCm'] as num).toDouble(),
  sex: $enumDecode(_$BiologicalSexEnumMap, json['sex']),
  experienceLevel: $enumDecode(
    _$ExperienceLevelEnumMap,
    json['experienceLevel'],
  ),
  monthsOfTraining: (json['monthsOfTraining'] as num?)?.toInt(),
  benchPressMax: (json['benchPressMax'] as num?)?.toDouble(),
  squatMax: (json['squatMax'] as num?)?.toDouble(),
  deadliftMax: (json['deadliftMax'] as num?)?.toDouble(),
  overheadPressMax: (json['overheadPressMax'] as num?)?.toDouble(),
  trainingGoal:
      $enumDecodeNullable(_$TrainingGoalEnumMap, json['trainingGoal']) ??
      TrainingGoal.hypertrophy,
  hasInjuryHistory: json['hasInjuryHistory'] as bool? ?? false,
  injuryDetails: json['injuryDetails'] == null
      ? null
      : InjuryDetails.fromJson(json['injuryDetails'] as Map<String, dynamic>),
  currentPainLevel: (json['currentPainLevel'] as num?)?.toInt() ?? 0,
  suggestionStyle:
      $enumDecodeNullable(_$SuggestionStyleEnumMap, json['suggestionStyle']) ??
      SuggestionStyle.balanced,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  allowPeriodicUpdates: json['allowPeriodicUpdates'] as bool? ?? true,
  selfReportCalibration:
      $enumDecodeNullable(
        _$SelfReportCalibrationEnumMap,
        json['selfReportCalibration'],
      ) ??
      SelfReportCalibration.realistic,
);

Map<String, dynamic> _$UserFitnessQuestionnaireToJson(
  _UserFitnessQuestionnaire instance,
) => <String, dynamic>{
  'bodyweightKg': instance.bodyweightKg,
  'age': instance.age,
  'heightCm': instance.heightCm,
  'sex': _$BiologicalSexEnumMap[instance.sex]!,
  'experienceLevel': _$ExperienceLevelEnumMap[instance.experienceLevel]!,
  'monthsOfTraining': instance.monthsOfTraining,
  'benchPressMax': instance.benchPressMax,
  'squatMax': instance.squatMax,
  'deadliftMax': instance.deadliftMax,
  'overheadPressMax': instance.overheadPressMax,
  'trainingGoal': _$TrainingGoalEnumMap[instance.trainingGoal]!,
  'hasInjuryHistory': instance.hasInjuryHistory,
  'injuryDetails': instance.injuryDetails?.toJson(),
  'currentPainLevel': instance.currentPainLevel,
  'suggestionStyle': _$SuggestionStyleEnumMap[instance.suggestionStyle]!,
  'completedAt': instance.completedAt?.toIso8601String(),
  'allowPeriodicUpdates': instance.allowPeriodicUpdates,
  'selfReportCalibration':
      _$SelfReportCalibrationEnumMap[instance.selfReportCalibration]!,
};

const _$BiologicalSexEnumMap = {
  BiologicalSex.male: 'male',
  BiologicalSex.female: 'female',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.untrained: 'untrained',
  ExperienceLevel.novice: 'novice',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
  ExperienceLevel.elite: 'elite',
};

const _$TrainingGoalEnumMap = {
  TrainingGoal.strength: 'strength',
  TrainingGoal.hypertrophy: 'hypertrophy',
  TrainingGoal.endurance: 'endurance',
};

const _$SuggestionStyleEnumMap = {
  SuggestionStyle.conservative: 'conservative',
  SuggestionStyle.balanced: 'balanced',
  SuggestionStyle.aggressive: 'aggressive',
};

const _$SelfReportCalibrationEnumMap = {
  SelfReportCalibration.optimistic: 'optimistic',
  SelfReportCalibration.realistic: 'realistic',
  SelfReportCalibration.conservative: 'conservative',
};

_InjuryDetails _$InjuryDetailsFromJson(Map<String, dynamic> json) =>
    _InjuryDetails(
      injuryType: json['injuryType'] as String,
      region: $enumDecode(_$InjuryRegionEnumMap, json['region']),
      monthsSinceInjury: (json['monthsSinceInjury'] as num).toInt(),
      fullyRecovered: json['fullyRecovered'] as bool? ?? false,
      inRehabilitation: json['inRehabilitation'] as bool? ?? false,
      aggravatingActivities:
          (json['aggravatingActivities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$InjuryDetailsToJson(_InjuryDetails instance) =>
    <String, dynamic>{
      'injuryType': instance.injuryType,
      'region': _$InjuryRegionEnumMap[instance.region]!,
      'monthsSinceInjury': instance.monthsSinceInjury,
      'fullyRecovered': instance.fullyRecovered,
      'inRehabilitation': instance.inRehabilitation,
      'aggravatingActivities': instance.aggravatingActivities,
    };

const _$InjuryRegionEnumMap = {
  InjuryRegion.lowerBack: 'lower_back',
  InjuryRegion.shoulder: 'shoulder',
  InjuryRegion.knee: 'knee',
  InjuryRegion.elbow: 'elbow',
  InjuryRegion.wrist: 'wrist',
  InjuryRegion.hip: 'hip',
  InjuryRegion.ankle: 'ankle',
  InjuryRegion.neck: 'neck',
  InjuryRegion.other: 'other',
};
