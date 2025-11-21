// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutineModel _$RoutineModelFromJson(Map<String, dynamic> json) => RoutineModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      presetType: $enumDecode(_$RoutinePresetEnumMap, json['presetType']),
      trainingDays: (json['trainingDays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      workoutSchedule: Map<String, String>.from(json['workoutSchedule'] as Map),
      isActive: json['isActive'] as bool,
      completedDays: (json['completedDays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalWorkouts: (json['totalWorkouts'] as num).toInt(),
      createdAt: RoutineModel._timestampFromJson(json['createdAt']),
      updatedAt: RoutineModel._timestampFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$RoutineModelToJson(RoutineModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'presetType': _$RoutinePresetEnumMap[instance.presetType]!,
      'trainingDays': instance.trainingDays,
      'workoutSchedule': instance.workoutSchedule,
      'isActive': instance.isActive,
      'completedDays': instance.completedDays,
      'totalWorkouts': instance.totalWorkouts,
      'createdAt': RoutineModel._timestampToJson(instance.createdAt),
      'updatedAt': RoutineModel._timestampToJson(instance.updatedAt),
    };

const _$RoutinePresetEnumMap = {
  RoutinePreset.ppl6Day: 'ppl_6_day',
  RoutinePreset.upperLower4Day: 'upper_lower_4_day',
  RoutinePreset.fullBody3Day: 'full_body_3_day',
  RoutinePreset.broSplit5Day: 'bro_split_5_day',
  RoutinePreset.custom: 'custom',
};
