// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_popularity_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExercisePopularityData _$ExercisePopularityDataFromJson(
  Map<String, dynamic> json,
) => _ExercisePopularityData(
  exerciseId: json['exerciseId'] as String,
  count: (json['count'] as num).toInt(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$ExercisePopularityDataToJson(
  _ExercisePopularityData instance,
) => <String, dynamic>{
  'exerciseId': instance.exerciseId,
  'count': instance.count,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
