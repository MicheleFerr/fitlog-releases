// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_progress_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetProgressDataImpl _$$SetProgressDataImplFromJson(
  Map<String, dynamic> json,
) => _$SetProgressDataImpl(
  currentWeight: (json['currentWeight'] as num).toDouble(),
  lastWeight: (json['lastWeight'] as num).toDouble(),
  currentReps: (json['currentReps'] as num).toInt(),
  lastReps: (json['lastReps'] as num).toInt(),
  lastWorkoutDate: DateTime.parse(json['lastWorkoutDate'] as String),
  setNumber: (json['setNumber'] as num).toInt(),
  exerciseName: json['exerciseName'] as String,
);

Map<String, dynamic> _$$SetProgressDataImplToJson(
  _$SetProgressDataImpl instance,
) => <String, dynamic>{
  'currentWeight': instance.currentWeight,
  'lastWeight': instance.lastWeight,
  'currentReps': instance.currentReps,
  'lastReps': instance.lastReps,
  'lastWorkoutDate': instance.lastWorkoutDate.toIso8601String(),
  'setNumber': instance.setNumber,
  'exerciseName': instance.exerciseName,
};

_$SetProgressParamsImpl _$$SetProgressParamsImplFromJson(
  Map<String, dynamic> json,
) => _$SetProgressParamsImpl(
  exerciseName: json['exerciseName'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
  currentWeight: (json['currentWeight'] as num).toDouble(),
  currentReps: (json['currentReps'] as num).toInt(),
);

Map<String, dynamic> _$$SetProgressParamsImplToJson(
  _$SetProgressParamsImpl instance,
) => <String, dynamic>{
  'exerciseName': instance.exerciseName,
  'setNumber': instance.setNumber,
  'currentWeight': instance.currentWeight,
  'currentReps': instance.currentReps,
};
