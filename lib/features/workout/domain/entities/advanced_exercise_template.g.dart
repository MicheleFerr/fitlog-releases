// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_exercise_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdvancedExerciseTemplate _$AdvancedExerciseTemplateFromJson(
  Map<String, dynamic> json,
) => _AdvancedExerciseTemplate(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$AdvancedExerciseTypeEnumMap, json['type']),
  config: AdvancedExerciseConfig.fromJson(
    json['config'] as Map<String, dynamic>,
  ),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
  isFavorite: json['isFavorite'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
);

Map<String, dynamic> _$AdvancedExerciseTemplateToJson(
  _AdvancedExerciseTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'description': instance.description,
  'type': _$AdvancedExerciseTypeEnumMap[instance.type]!,
  'config': instance.config.toJson(),
  'tags': instance.tags,
  'usageCount': instance.usageCount,
  'isFavorite': instance.isFavorite,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
};

const _$AdvancedExerciseTypeEnumMap = {
  AdvancedExerciseType.superset: 'superset',
  AdvancedExerciseType.dropset: 'dropset',
  AdvancedExerciseType.restPause: 'restPause',
};

SupersetConfig _$SupersetConfigFromJson(Map<String, dynamic> json) =>
    SupersetConfig(
      exerciseNames: (json['exerciseNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exerciseIds: (json['exerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      targetSets: (json['targetSets'] as num).toInt(),
      restBetweenExercises:
          (json['restBetweenExercises'] as num?)?.toInt() ?? 0,
      restBetweenRounds: (json['restBetweenRounds'] as num?)?.toInt() ?? 90,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$SupersetConfigToJson(SupersetConfig instance) =>
    <String, dynamic>{
      'exerciseNames': instance.exerciseNames,
      'exerciseIds': instance.exerciseIds,
      'targetSets': instance.targetSets,
      'restBetweenExercises': instance.restBetweenExercises,
      'restBetweenRounds': instance.restBetweenRounds,
      'runtimeType': instance.$type,
    };

DropSetConfig _$DropSetConfigFromJson(Map<String, dynamic> json) =>
    DropSetConfig(
      exerciseName: json['exerciseName'] as String,
      exerciseId: json['exerciseId'] as String,
      drops: (json['drops'] as num).toInt(),
      percentageDrops: (json['percentageDrops'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      restBetweenDrops: (json['restBetweenDrops'] as num?)?.toInt() ?? 0,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$DropSetConfigToJson(DropSetConfig instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'exerciseId': instance.exerciseId,
      'drops': instance.drops,
      'percentageDrops': instance.percentageDrops,
      'restBetweenDrops': instance.restBetweenDrops,
      'runtimeType': instance.$type,
    };

RestPauseConfig _$RestPauseConfigFromJson(Map<String, dynamic> json) =>
    RestPauseConfig(
      exerciseName: json['exerciseName'] as String,
      exerciseId: json['exerciseId'] as String,
      miniSets: (json['miniSets'] as num).toInt(),
      restDuration: (json['restDuration'] as num?)?.toInt() ?? 15,
      targetReps: (json['targetReps'] as num?)?.toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$RestPauseConfigToJson(RestPauseConfig instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'exerciseId': instance.exerciseId,
      'miniSets': instance.miniSets,
      'restDuration': instance.restDuration,
      'targetReps': instance.targetReps,
      'runtimeType': instance.$type,
    };
