// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Workout _$WorkoutFromJson(Map<String, dynamic> json) => _Workout(
  id: json['id'] as String,
  name: json['name'] as String,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$WorkoutStatusEnumMap, json['status']) ??
      WorkoutStatus.planned,
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  templateId: json['templateId'] as String?,
  isPreloaded: json['isPreloaded'] as bool? ?? false,
  preloadExpiry: json['preloadExpiry'] == null
      ? null
      : DateTime.parse(json['preloadExpiry'] as String),
  exercisesModified: json['exercisesModified'] as bool?,
  sessionId: json['sessionId'] as String?,
);

Map<String, dynamic> _$WorkoutToJson(_Workout instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'exercises': instance.exercises.map((e) => e.toJson()).toList(),
  'status': _$WorkoutStatusEnumMap[instance.status]!,
  'startTime': instance.startTime?.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'templateId': instance.templateId,
  'isPreloaded': instance.isPreloaded,
  'preloadExpiry': instance.preloadExpiry?.toIso8601String(),
  'exercisesModified': instance.exercisesModified,
  'sessionId': instance.sessionId,
};

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.planned: 'planned',
  WorkoutStatus.inProgress: 'inProgress',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.paused: 'paused',
};
