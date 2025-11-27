// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_gate_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeatureGateConfig _$FeatureGateConfigFromJson(Map<String, dynamic> json) =>
    _FeatureGateConfig(
      feature: $enumDecode(_$AiCoachFeatureEnumMap, json['feature']),
      displayNameKey: json['displayNameKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      rules:
          (json['rules'] as List<dynamic>?)
              ?.map((e) => GateRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isGloballyEnabled: json['isGloballyEnabled'] as bool? ?? true,
      defaultEnabled: json['defaultEnabled'] as bool? ?? false,
      userConfigurable: json['userConfigurable'] as bool? ?? true,
    );

Map<String, dynamic> _$FeatureGateConfigToJson(_FeatureGateConfig instance) =>
    <String, dynamic>{
      'feature': _$AiCoachFeatureEnumMap[instance.feature]!,
      'displayNameKey': instance.displayNameKey,
      'descriptionKey': instance.descriptionKey,
      'rules': instance.rules.map((e) => e.toJson()).toList(),
      'isGloballyEnabled': instance.isGloballyEnabled,
      'defaultEnabled': instance.defaultEnabled,
      'userConfigurable': instance.userConfigurable,
    };

const _$AiCoachFeatureEnumMap = {
  AiCoachFeature.insights: 'insights',
  AiCoachFeature.notifications: 'notifications',
  AiCoachFeature.achievements: 'achievements',
  AiCoachFeature.streakTracking: 'streakTracking',
  AiCoachFeature.advancedAnalytics: 'advancedAnalytics',
  AiCoachFeature.workoutSuggestions: 'workoutSuggestions',
  AiCoachFeature.recoveryInsights: 'recoveryInsights',
  AiCoachFeature.formCorrections: 'formCorrections',
};

_GateRule _$GateRuleFromJson(Map<String, dynamic> json) => _GateRule(
  type: $enumDecode(_$GateRuleTypeEnumMap, json['type']),
  value: json['value'],
);

Map<String, dynamic> _$GateRuleToJson(_GateRule instance) => <String, dynamic>{
  'type': _$GateRuleTypeEnumMap[instance.type]!,
  'value': instance.value,
};

const _$GateRuleTypeEnumMap = {
  GateRuleType.minExperienceLevel: 'minExperienceLevel',
  GateRuleType.minEffectiveness: 'minEffectiveness',
  GateRuleType.minWorkoutCount: 'minWorkoutCount',
  GateRuleType.minDaysSinceRegistration: 'minDaysSinceRegistration',
  GateRuleType.userPreference: 'userPreference',
  GateRuleType.abTestGroup: 'abTestGroup',
  GateRuleType.featureFlag: 'featureFlag',
};

_FeatureGateStatus _$FeatureGateStatusFromJson(Map<String, dynamic> json) =>
    _FeatureGateStatus(
      feature: $enumDecode(_$AiCoachFeatureEnumMap, json['feature']),
      isEnabled: json['isEnabled'] as bool,
      reasonKey: json['reasonKey'] as String,
      passedRules:
          (json['passedRules'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GateRuleTypeEnumMap, e))
              .toList() ??
          const [],
      failedRules:
          (json['failedRules'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GateRuleTypeEnumMap, e))
              .toList() ??
          const [],
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
    );

Map<String, dynamic> _$FeatureGateStatusToJson(_FeatureGateStatus instance) =>
    <String, dynamic>{
      'feature': _$AiCoachFeatureEnumMap[instance.feature]!,
      'isEnabled': instance.isEnabled,
      'reasonKey': instance.reasonKey,
      'passedRules': instance.passedRules
          .map((e) => _$GateRuleTypeEnumMap[e]!)
          .toList(),
      'failedRules': instance.failedRules
          .map((e) => _$GateRuleTypeEnumMap[e]!)
          .toList(),
      'evaluatedAt': instance.evaluatedAt.toIso8601String(),
    };
