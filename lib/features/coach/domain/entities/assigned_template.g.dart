// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssignedTemplate _$AssignedTemplateFromJson(Map<String, dynamic> json) =>
    _AssignedTemplate(
      id: json['id'] as String,
      coachTemplateId: json['coachTemplateId'] as String,
      coachId: json['coachId'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String),
      athleteNotes: json['athleteNotes'] as String?,
      templateName: json['templateName'] as String?,
      coachName: json['coachName'] as String?,
      exerciseCount: (json['exerciseCount'] as num?)?.toInt(),
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AssignedTemplateToJson(_AssignedTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coachTemplateId': instance.coachTemplateId,
      'coachId': instance.coachId,
      'assignedAt': instance.assignedAt.toIso8601String(),
      'lastSyncedAt': instance.lastSyncedAt.toIso8601String(),
      'athleteNotes': instance.athleteNotes,
      'templateName': instance.templateName,
      'coachName': instance.coachName,
      'exerciseCount': instance.exerciseCount,
      'estimatedDuration': instance.estimatedDuration,
    };
