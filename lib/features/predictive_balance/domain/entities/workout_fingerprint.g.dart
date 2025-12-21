// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_fingerprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutFingerprint _$WorkoutFingerprintFromJson(Map<String, dynamic> json) =>
    _WorkoutFingerprint(
      id: json['id'] as String,
      templateName: json['templateName'] as String?,
      templateId: json['templateId'] as String?,
      dominantMuscles: (json['dominantMuscles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      category: $enumDecode(_$WorkoutCategoryEnumMap, json['category']),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      workoutDate: json['workoutDate'] == null
          ? null
          : DateTime.parse(json['workoutDate'] as String),
    );

Map<String, dynamic> _$WorkoutFingerprintToJson(_WorkoutFingerprint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateName': instance.templateName,
      'templateId': instance.templateId,
      'dominantMuscles': instance.dominantMuscles,
      'category': _$WorkoutCategoryEnumMap[instance.category]!,
      'totalVolume': instance.totalVolume,
      'workoutDate': instance.workoutDate?.toIso8601String(),
    };

const _$WorkoutCategoryEnumMap = {
  WorkoutCategory.push: 'push',
  WorkoutCategory.pull: 'pull',
  WorkoutCategory.legs: 'legs',
  WorkoutCategory.upper: 'upper',
  WorkoutCategory.lower: 'lower',
  WorkoutCategory.fullBody: 'fullBody',
  WorkoutCategory.other: 'other',
};
