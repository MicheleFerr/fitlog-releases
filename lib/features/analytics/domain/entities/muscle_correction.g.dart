// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_correction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MuscleCorrectionImpl _$$MuscleCorrectionImplFromJson(
  Map<String, dynamic> json,
) => _$MuscleCorrectionImpl(
  exerciseName: json['exerciseName'] as String,
  oldMuscleGroup: json['oldMuscleGroup'] as String,
  newMuscleGroup: json['newMuscleGroup'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$MuscleCorrectionImplToJson(
  _$MuscleCorrectionImpl instance,
) => <String, dynamic>{
  'exerciseName': instance.exerciseName,
  'oldMuscleGroup': instance.oldMuscleGroup,
  'newMuscleGroup': instance.newMuscleGroup,
  'timestamp': instance.timestamp.toIso8601String(),
};
