// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIInsightImpl _$$AIInsightImplFromJson(Map<String, dynamic> json) =>
    _$AIInsightImpl(
      id: json['id'] as String,
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      severity: $enumDecode(_$InsightSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      description: json['description'] as String,
      recommendation: json['recommendation'] as String,
      priority: (json['priority'] as num).toInt(),
      affectedExercise: json['affectedExercise'] as String?,
      affectedTemplates: (json['affectedTemplates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      scientificStrategies: (json['scientificStrategies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dataPoints: json['dataPoints'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$AIInsightImplToJson(_$AIInsightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$InsightTypeEnumMap[instance.type]!,
      'severity': _$InsightSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'description': instance.description,
      'recommendation': instance.recommendation,
      'priority': instance.priority,
      'affectedExercise': instance.affectedExercise,
      'affectedTemplates': instance.affectedTemplates,
      'scientificStrategies': instance.scientificStrategies,
      'dataPoints': instance.dataPoints,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$InsightTypeEnumMap = {
  InsightType.muscleGroupBalance: 'muscleGroupBalance',
  InsightType.progressOverload: 'progressOverload',
  InsightType.recoveryPattern: 'recoveryPattern',
  InsightType.volumeOptimization: 'volumeOptimization',
  InsightType.frequencyRecommendation: 'frequencyRecommendation',
  InsightType.plateauBreaker: 'plateauBreaker',
  InsightType.formWarning: 'formWarning',
  InsightType.motivational: 'motivational',
  InsightType.cnsFatigue: 'cnsFatigue',
  InsightType.periodization: 'periodization',
  InsightType.mobility: 'mobility',
};

const _$InsightSeverityEnumMap = {
  InsightSeverity.low: 'low',
  InsightSeverity.medium: 'medium',
  InsightSeverity.high: 'high',
  InsightSeverity.critical: 'critical',
};
