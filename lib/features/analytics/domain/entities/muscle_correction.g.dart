// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_correction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuscleCorrection _$MuscleCorrectionFromJson(Map<String, dynamic> json) =>
    _MuscleCorrection(
      exerciseName: json['exerciseName'] as String,
      oldMuscleGroup: json['oldMuscleGroup'] as String,
      newMuscleGroup: json['newMuscleGroup'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MuscleCorrectionToJson(_MuscleCorrection instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'oldMuscleGroup': instance.oldMuscleGroup,
      'newMuscleGroup': instance.newMuscleGroup,
      'timestamp': instance.timestamp.toIso8601String(),
    };
