// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_tier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecoveryTierConfig _$RecoveryTierConfigFromJson(Map<String, dynamic> json) =>
    _RecoveryTierConfig(
      tier: $enumDecode(_$RecoveryTierEnumMap, json['tier']),
      minWorkouts: (json['minWorkouts'] as num).toInt(),
      minDays: (json['minDays'] as num).toInt(),
    );

Map<String, dynamic> _$RecoveryTierConfigToJson(_RecoveryTierConfig instance) =>
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

_RecoveryTierStatus _$RecoveryTierStatusFromJson(Map<String, dynamic> json) =>
    _RecoveryTierStatus(
      tier: $enumDecode(_$RecoveryTierEnumMap, json['tier']),
      isUnlocked: json['isUnlocked'] as bool,
      currentWorkouts: (json['currentWorkouts'] as num).toInt(),
      currentDays: (json['currentDays'] as num).toInt(),
      config: RecoveryTierConfig.fromJson(
        json['config'] as Map<String, dynamic>,
      ),
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$RecoveryTierStatusToJson(_RecoveryTierStatus instance) =>
    <String, dynamic>{
      'tier': _$RecoveryTierEnumMap[instance.tier]!,
      'isUnlocked': instance.isUnlocked,
      'currentWorkouts': instance.currentWorkouts,
      'currentDays': instance.currentDays,
      'config': instance.config.toJson(),
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };
