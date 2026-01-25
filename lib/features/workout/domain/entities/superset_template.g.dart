// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'superset_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SupersetTemplate _$SupersetTemplateFromJson(Map<String, dynamic> json) =>
    _SupersetTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKey: json['nameKey'] as String?,
      exerciseIds: (json['exerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exerciseNames:
          (json['exerciseNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rounds: (json['rounds'] as num).toInt(),
      repsRange: json['repsRange'] as String,
      restAfterRound: (json['restAfterRound'] as num).toInt(),
      restBetween: (json['restBetween'] as num).toInt(),
      difficulty: $enumDecode(_$TemplateDifficultyEnumMap, json['difficulty']),
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
      targetPersona: $enumDecodeNullable(
        _$UserPersonaEnumMap,
        json['targetPersona'],
      ),
      targetMuscles: (json['targetMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SupersetTemplateToJson(_SupersetTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameKey': instance.nameKey,
      'exerciseIds': instance.exerciseIds,
      'exerciseNames': instance.exerciseNames,
      'rounds': instance.rounds,
      'repsRange': instance.repsRange,
      'restAfterRound': instance.restAfterRound,
      'restBetween': instance.restBetween,
      'difficulty': _$TemplateDifficultyEnumMap[instance.difficulty]!,
      'estimatedTimeMinutes': instance.estimatedTimeMinutes,
      'scientificBasis': instance.scientificBasis,
      'notes': instance.notes,
      'tut': instance.tut,
      'equipmentRequired': instance.equipmentRequired,
      'equipmentAlternatives': instance.equipmentAlternatives,
      'targetPersona': _$UserPersonaEnumMap[instance.targetPersona],
      'targetMuscles': instance.targetMuscles,
      'isCustom': instance.isCustom,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$TemplateDifficultyEnumMap = {
  TemplateDifficulty.beginner: 'beginner',
  TemplateDifficulty.intermediate: 'intermediate',
  TemplateDifficulty.intermediateAdvanced: 'intermediate-advanced',
  TemplateDifficulty.advanced: 'advanced',
};

const _$UserPersonaEnumMap = {
  UserPersona.marco: 'marco',
  UserPersona.chiara: 'chiara',
  UserPersona.luca: 'luca',
  UserPersona.sofia: 'sofia',
  UserPersona.roberto: 'roberto',
  UserPersona.generic: 'generic',
};
