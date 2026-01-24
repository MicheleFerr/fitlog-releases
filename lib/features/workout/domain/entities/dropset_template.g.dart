// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropset_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DropsetTemplate _$DropsetTemplateFromJson(Map<String, dynamic> json) =>
    _DropsetTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      exerciseName: json['exerciseName'] as String,
      drops: (json['drops'] as num).toInt(),
      initialReps: json['initialReps'] as String,
      dropPercentage: (json['dropPercentage'] as num).toInt(),
      restBetweenDrops: (json['restBetweenDrops'] as num).toInt(),
      totalSets: (json['totalSets'] as num).toInt(),
      restBetweenSets: (json['restBetweenSets'] as num).toInt(),
      difficulty: $enumDecode(_$DropsetDifficultyEnumMap, json['difficulty']),
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

Map<String, dynamic> _$DropsetTemplateToJson(_DropsetTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'exerciseName': instance.exerciseName,
      'drops': instance.drops,
      'initialReps': instance.initialReps,
      'dropPercentage': instance.dropPercentage,
      'restBetweenDrops': instance.restBetweenDrops,
      'totalSets': instance.totalSets,
      'restBetweenSets': instance.restBetweenSets,
      'difficulty': _$DropsetDifficultyEnumMap[instance.difficulty]!,
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

const _$DropsetDifficultyEnumMap = {
  DropsetDifficulty.beginner: 'beginner',
  DropsetDifficulty.intermediate: 'intermediate',
  DropsetDifficulty.intermediateAdvanced: 'intermediate-advanced',
  DropsetDifficulty.advanced: 'advanced',
};
