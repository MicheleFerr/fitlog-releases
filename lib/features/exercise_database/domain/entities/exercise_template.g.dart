// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseDefinitionTemplateImpl _$$ExerciseDefinitionTemplateImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseDefinitionTemplateImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$ExerciseCategoryEnumMap, json['category']),
  type: $enumDecode(_$ExerciseTypeEnumMap, json['type']),
  muscleGroups: (json['muscleGroups'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  equipment: (json['equipment'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  difficulty: json['difficulty'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ExerciseDefinitionTemplateImplToJson(
  _$ExerciseDefinitionTemplateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': _$ExerciseCategoryEnumMap[instance.category]!,
  'type': _$ExerciseTypeEnumMap[instance.type]!,
  'muscleGroups': instance.muscleGroups,
  'equipment': instance.equipment,
  'instructions': instance.instructions,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'difficulty': instance.difficulty,
  'metadata': instance.metadata,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$ExerciseCategoryEnumMap = {
  ExerciseCategory.chest: 'chest',
  ExerciseCategory.back: 'back',
  ExerciseCategory.shoulders: 'shoulders',
  ExerciseCategory.arms: 'arms',
  ExerciseCategory.legs: 'legs',
  ExerciseCategory.abs: 'abs',
  ExerciseCategory.cardio: 'cardio',
  ExerciseCategory.other: 'other',
};

const _$ExerciseTypeEnumMap = {
  ExerciseType.single: 'single',
  ExerciseType.superset: 'superset',
  ExerciseType.dropset: 'dropset',
  ExerciseType.restPause: 'restPause',
};
