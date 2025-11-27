// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_detection_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatternDetectionResult _$PatternDetectionResultFromJson(
  Map<String, dynamic> json,
) => _PatternDetectionResult(
  pattern: (json['pattern'] as List<dynamic>).map((e) => e as String).toList(),
  repetitions: (json['repetitions'] as num).toInt(),
  confidence: (json['confidence'] as num).toDouble(),
  lastPosition: (json['lastPosition'] as num).toInt(),
);

Map<String, dynamic> _$PatternDetectionResultToJson(
  _PatternDetectionResult instance,
) => <String, dynamic>{
  'pattern': instance.pattern,
  'repetitions': instance.repetitions,
  'confidence': instance.confidence,
  'lastPosition': instance.lastPosition,
};
