// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatternPrediction _$PatternPredictionFromJson(Map<String, dynamic> json) =>
    _PatternPrediction(
      missing: WorkoutFingerprint.fromJson(
        json['missing'] as Map<String, dynamic>,
      ),
      musclesCovered: (json['musclesCovered'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestedTemplateId: json['suggestedTemplateId'] as String?,
      suggestedTemplateName: json['suggestedTemplateName'] as String?,
      missingCount: (json['missingCount'] as num?)?.toInt() ?? 1,
      patternConfidence: (json['patternConfidence'] as num).toDouble(),
    );

Map<String, dynamic> _$PatternPredictionToJson(_PatternPrediction instance) =>
    <String, dynamic>{
      'missing': instance.missing.toJson(),
      'musclesCovered': instance.musclesCovered,
      'suggestedTemplateId': instance.suggestedTemplateId,
      'suggestedTemplateName': instance.suggestedTemplateName,
      'missingCount': instance.missingCount,
      'patternConfidence': instance.patternConfidence,
    };
