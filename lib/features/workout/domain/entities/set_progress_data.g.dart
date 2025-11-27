// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_progress_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetProgressData _$SetProgressDataFromJson(Map<String, dynamic> json) =>
    _SetProgressData(
      currentWeight: (json['currentWeight'] as num).toDouble(),
      lastWeight: (json['lastWeight'] as num).toDouble(),
      currentReps: (json['currentReps'] as num).toInt(),
      lastReps: (json['lastReps'] as num).toInt(),
      lastWorkoutDate: DateTime.parse(json['lastWorkoutDate'] as String),
      setNumber: (json['setNumber'] as num).toInt(),
      exerciseName: json['exerciseName'] as String,
    );

Map<String, dynamic> _$SetProgressDataToJson(_SetProgressData instance) =>
    <String, dynamic>{
      'currentWeight': instance.currentWeight,
      'lastWeight': instance.lastWeight,
      'currentReps': instance.currentReps,
      'lastReps': instance.lastReps,
      'lastWorkoutDate': instance.lastWorkoutDate.toIso8601String(),
      'setNumber': instance.setNumber,
      'exerciseName': instance.exerciseName,
    };

_SetProgressParams _$SetProgressParamsFromJson(Map<String, dynamic> json) =>
    _SetProgressParams(
      exerciseName: json['exerciseName'] as String,
      setNumber: (json['setNumber'] as num).toInt(),
      currentWeight: (json['currentWeight'] as num).toDouble(),
      currentReps: (json['currentReps'] as num).toInt(),
    );

Map<String, dynamic> _$SetProgressParamsToJson(_SetProgressParams instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'setNumber': instance.setNumber,
      'currentWeight': instance.currentWeight,
      'currentReps': instance.currentReps,
    };
