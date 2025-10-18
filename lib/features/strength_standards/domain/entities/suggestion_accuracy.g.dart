// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_accuracy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SuggestionAccuracyImpl _$$SuggestionAccuracyImplFromJson(
        Map<String, dynamic> json) =>
    _$SuggestionAccuracyImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      exerciseId: json['exerciseId'] as String,
      suggestedWeight: (json['suggestedWeight'] as num).toDouble(),
      actualWeight: (json['actualWeight'] as num).toDouble(),
      suggestedReps: (json['suggestedReps'] as num).toInt(),
      actualReps: (json['actualReps'] as num).toInt(),
      weightErrorPercent: (json['weightErrorPercent'] as num).toDouble(),
      repsError: (json['repsError'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      experienceLevel: json['experienceLevel'] as String,
      trainingGoal: json['trainingGoal'] as String,
      wasHelpful: json['wasHelpful'] as bool?,
      perceivedExertion: (json['perceivedExertion'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SuggestionAccuracyImplToJson(
        _$SuggestionAccuracyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'exerciseId': instance.exerciseId,
      'suggestedWeight': instance.suggestedWeight,
      'actualWeight': instance.actualWeight,
      'suggestedReps': instance.suggestedReps,
      'actualReps': instance.actualReps,
      'weightErrorPercent': instance.weightErrorPercent,
      'repsError': instance.repsError,
      'timestamp': instance.timestamp.toIso8601String(),
      'experienceLevel': instance.experienceLevel,
      'trainingGoal': instance.trainingGoal,
      'wasHelpful': instance.wasHelpful,
      'perceivedExertion': instance.perceivedExertion,
    };
