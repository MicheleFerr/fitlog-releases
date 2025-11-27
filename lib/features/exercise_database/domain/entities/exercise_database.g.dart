// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_database.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseDatabaseImpl _$$ExerciseDatabaseImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseDatabaseImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String?,
  equipment: json['equipment'] as String?,
  primaryMuscleGroups: (json['primaryMuscleGroups'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  secondaryMuscleGroups: (json['secondaryMuscleGroups'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  difficulty: json['difficulty'] as String?,
  instructions: json['instructions'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isFavorite: json['isFavorite'] as bool?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ExerciseDatabaseImplToJson(
  _$ExerciseDatabaseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'equipment': instance.equipment,
  'primaryMuscleGroups': instance.primaryMuscleGroups,
  'secondaryMuscleGroups': instance.secondaryMuscleGroups,
  'difficulty': instance.difficulty,
  'instructions': instance.instructions,
  'imageUrl': instance.imageUrl,
  'isFavorite': instance.isFavorite,
  'metadata': instance.metadata,
};
