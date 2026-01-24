// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_pause_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RestPauseTemplate _$RestPauseTemplateFromJson(Map<String, dynamic> json) =>
    _RestPauseTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      exerciseName: json['exerciseName'] as String,
      initialReps: json['initialReps'] as String,
      clusters: (json['clusters'] as num).toInt(),
      clusterReps: json['clusterReps'] as String,
      pauseDuration: (json['pauseDuration'] as num).toInt(),
      totalSets: (json['totalSets'] as num).toInt(),
      restBetweenSets: (json['restBetweenSets'] as num).toInt(),
      difficulty: $enumDecode(_$RestPauseDifficultyEnumMap, json['difficulty']),
      estimatedTimeMinutes: (json['estimatedTimeMinutes'] as num).toInt(),
      scientificBasis: json['scientificBasis'] as String,
      notes: json['notes'] as String?,
      tut: json['tut'] as String?,
      equipmentRequired: (json['equipmentRequired'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      equipmentAlternatives: (json['equipmentAlternatives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RestPauseTemplateToJson(_RestPauseTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'exerciseName': instance.exerciseName,
      'initialReps': instance.initialReps,
      'clusters': instance.clusters,
      'clusterReps': instance.clusterReps,
      'pauseDuration': instance.pauseDuration,
      'totalSets': instance.totalSets,
      'restBetweenSets': instance.restBetweenSets,
      'difficulty': _$RestPauseDifficultyEnumMap[instance.difficulty]!,
      'estimatedTimeMinutes': instance.estimatedTimeMinutes,
      'scientificBasis': instance.scientificBasis,
      'notes': instance.notes,
      'tut': instance.tut,
      'equipmentRequired': instance.equipmentRequired,
      'equipmentAlternatives': instance.equipmentAlternatives,
      'targetMuscles': instance.targetMuscles,
      'isCustom': instance.isCustom,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$RestPauseDifficultyEnumMap = {
  RestPauseDifficulty.beginner: 'beginner',
  RestPauseDifficulty.intermediate: 'intermediate',
  RestPauseDifficulty.intermediateAdvanced: 'intermediate-advanced',
  RestPauseDifficulty.advanced: 'advanced',
};
