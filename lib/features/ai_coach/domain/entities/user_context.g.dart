// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserContextImpl _$$UserContextImplFromJson(Map<String, dynamic> json) =>
    _$UserContextImpl(
      userId: json['userId'] as String,
      experienceLevel: $enumDecode(
        _$ExperienceLevelEnumMap,
        json['experienceLevel'],
      ),
      primaryGoal: $enumDecode(_$TrainingGoalEnumMap, json['primaryGoal']),
      weeklyAvailability: (json['weeklyAvailability'] as num).toInt(),
      injuryHistory: (json['injuryHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredExercises: (json['preferredExercises'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$UserContextImplToJson(_$UserContextImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'experienceLevel': _$ExperienceLevelEnumMap[instance.experienceLevel]!,
      'primaryGoal': _$TrainingGoalEnumMap[instance.primaryGoal]!,
      'weeklyAvailability': instance.weeklyAvailability,
      'injuryHistory': instance.injuryHistory,
      'preferredExercises': instance.preferredExercises,
    };

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};

const _$TrainingGoalEnumMap = {
  TrainingGoal.hypertrophy: 'hypertrophy',
  TrainingGoal.strength: 'strength',
  TrainingGoal.endurance: 'endurance',
};
