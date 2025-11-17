// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_tier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecoveryTierConfigImpl _$$RecoveryTierConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$RecoveryTierConfigImpl(
      tier: $enumDecode(_$RecoveryTierEnumMap, json['tier']),
      minWorkouts: (json['minWorkouts'] as num).toInt(),
      minDays: (json['minDays'] as num).toInt(),
    );

Map<String, dynamic> _$$RecoveryTierConfigImplToJson(
        _$RecoveryTierConfigImpl instance) =>
    <String, dynamic>{
      'tier': _$RecoveryTierEnumMap[instance.tier]!,
      'minWorkouts': instance.minWorkouts,
      'minDays': instance.minDays,
    };

const _$RecoveryTierEnumMap = {
  RecoveryTier.basic: 'basic',
  RecoveryTier.intermediate: 'intermediate',
  RecoveryTier.advanced: 'advanced',
};

_$RecoveryTierStatusImpl _$$RecoveryTierStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$RecoveryTierStatusImpl(
      tier: $enumDecode(_$RecoveryTierEnumMap, json['tier']),
      isUnlocked: json['isUnlocked'] as bool,
      currentWorkouts: (json['currentWorkouts'] as num).toInt(),
      currentDays: (json['currentDays'] as num).toInt(),
      config:
          RecoveryTierConfig.fromJson(json['config'] as Map<String, dynamic>),
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$$RecoveryTierStatusImplToJson(
        _$RecoveryTierStatusImpl instance) =>
    <String, dynamic>{
      'tier': _$RecoveryTierEnumMap[instance.tier]!,
      'isUnlocked': instance.isUnlocked,
      'currentWorkouts': instance.currentWorkouts,
      'currentDays': instance.currentDays,
      'config': instance.config.toJson(),
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };
