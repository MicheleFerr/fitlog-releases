// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flexible_routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlexibleRoutineImpl _$$FlexibleRoutineImplFromJson(
        Map<String, dynamic> json) =>
    _$FlexibleRoutineImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      presetType: $enumDecode(_$RoutinePresetEnumMap, json['presetType']),
      trainingDays: (json['trainingDays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toSet(),
      workoutSchedule: (json['workoutSchedule'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
      isActive: json['isActive'] as bool? ?? true,
      completedDays: (json['completedDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$FlexibleRoutineImplToJson(
        _$FlexibleRoutineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'presetType': _$RoutinePresetEnumMap[instance.presetType]!,
      'trainingDays': instance.trainingDays.toList(),
      'workoutSchedule':
          instance.workoutSchedule.map((k, e) => MapEntry(k.toString(), e)),
      'isActive': instance.isActive,
      'completedDays': instance.completedDays.toList(),
      'totalWorkouts': instance.totalWorkouts,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RoutinePresetEnumMap = {
  RoutinePreset.ppl6Day: 'ppl_6_day',
  RoutinePreset.upperLower4Day: 'upper_lower_4_day',
  RoutinePreset.fullBody3Day: 'full_body_3_day',
  RoutinePreset.broSplit5Day: 'bro_split_5_day',
  RoutinePreset.custom: 'custom',
};
