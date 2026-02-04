// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stress_index_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StressIndexResult _$StressIndexResultFromJson(Map<String, dynamic> json) =>
    _StressIndexResult(
      primaryScore: (json['primaryScore'] as num).toDouble(),
      fallbackScore: (json['fallbackScore'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      muscleBreakdown: (json['muscleBreakdown'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, MuscleStressData.fromJson(e as Map<String, dynamic>)),
      ),
      totalSets: (json['totalSets'] as num).toInt(),
      setsWithRpe: (json['setsWithRpe'] as num).toInt(),
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String?,
      workoutDate: json['workoutDate'] == null
          ? null
          : DateTime.parse(json['workoutDate'] as String),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      rawScore: (json['rawScore'] as num).toDouble(),
    );

Map<String, dynamic> _$StressIndexResultToJson(_StressIndexResult instance) =>
    <String, dynamic>{
      'primaryScore': instance.primaryScore,
      'fallbackScore': instance.fallbackScore,
      'confidence': instance.confidence,
      'muscleBreakdown': instance.muscleBreakdown.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'totalSets': instance.totalSets,
      'setsWithRpe': instance.setsWithRpe,
      'workoutId': instance.workoutId,
      'workoutName': instance.workoutName,
      'workoutDate': instance.workoutDate?.toIso8601String(),
      'calculatedAt': instance.calculatedAt.toIso8601String(),
      'rawScore': instance.rawScore,
    };
