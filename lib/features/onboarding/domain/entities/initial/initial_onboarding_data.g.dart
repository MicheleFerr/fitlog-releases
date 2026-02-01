// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_onboarding_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InitialOnboardingData _$InitialOnboardingDataFromJson(
  Map<String, dynamic> json,
) => _InitialOnboardingData(
  goal: $enumDecode(_$TrainingGoalUIEnumMap, json['goal']),
  sex: $enumDecode(_$BiologicalSexEnumMap, json['sex']),
  age: (json['age'] as num).toInt(),
  heightCm: (json['heightCm'] as num).toDouble(),
  bodyweightKg: (json['bodyweightKg'] as num).toDouble(),
  experience: $enumDecode(_$ExperienceLevelUIEnumMap, json['experience']),
  healthKitConnected: json['healthKitConnected'] as bool? ?? false,
  healthKitPermissionsGranted:
      (json['healthKitPermissionsGranted'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  workoutsPerWeek: (json['workoutsPerWeek'] as num?)?.toInt() ?? 3,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$InitialOnboardingDataToJson(
  _InitialOnboardingData instance,
) => <String, dynamic>{
  'goal': _$TrainingGoalUIEnumMap[instance.goal]!,
  'sex': _$BiologicalSexEnumMap[instance.sex]!,
  'age': instance.age,
  'heightCm': instance.heightCm,
  'bodyweightKg': instance.bodyweightKg,
  'experience': _$ExperienceLevelUIEnumMap[instance.experience]!,
  'healthKitConnected': instance.healthKitConnected,
  'healthKitPermissionsGranted': instance.healthKitPermissionsGranted,
  'workoutsPerWeek': instance.workoutsPerWeek,
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$TrainingGoalUIEnumMap = {
  TrainingGoalUI.buildMuscle: 'buildMuscle',
  TrainingGoalUI.getStronger: 'getStronger',
  TrainingGoalUI.endurance: 'endurance',
  TrainingGoalUI.stayFit: 'stayFit',
};

const _$BiologicalSexEnumMap = {
  BiologicalSex.male: 'male',
  BiologicalSex.female: 'female',
};

const _$ExperienceLevelUIEnumMap = {
  ExperienceLevelUI.beginner: 'beginner',
  ExperienceLevelUI.someExperience: 'someExperience',
  ExperienceLevelUI.experienced: 'experienced',
  ExperienceLevelUI.athlete: 'athlete',
};
