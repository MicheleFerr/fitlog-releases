// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoachTemplate _$CoachTemplateFromJson(Map<String, dynamic> json) =>
    _CoachTemplate(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: json['exercises'] == null
          ? const []
          : const ExerciseTemplateListConverter().fromJson(
              json['exercises'] as List,
            ),
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt() ?? 45,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      difficulty: json['difficulty'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      assignedTo:
          (json['assignedTo'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isArchived: json['isArchived'] as bool? ?? false,
      coachNotes: json['coachNotes'] as String?,
    );

Map<String, dynamic> _$CoachTemplateToJson(
  _CoachTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'coachId': instance.coachId,
  'name': instance.name,
  'description': instance.description,
  'exercises': const ExerciseTemplateListConverter().toJson(instance.exercises),
  'estimatedDuration': instance.estimatedDuration,
  'tags': instance.tags,
  'difficulty': instance.difficulty,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'assignedTo': instance.assignedTo,
  'isArchived': instance.isArchived,
  'coachNotes': instance.coachNotes,
};
