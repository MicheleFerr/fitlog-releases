// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementDataImpl _$$AchievementDataImplFromJson(
        Map<String, dynamic> json) =>
    _$AchievementDataImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
      rarity: $enumDecode(_$AchievementRarityEnumMap, json['rarity']),
      conditionDescription: json['conditionDescription'] as String,
      iconKey: json['iconKey'] as String,
      rewardMessage: json['rewardMessage'] as String,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isHidden: json['isHidden'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AchievementDataImplToJson(
        _$AchievementDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$AchievementCategoryEnumMap[instance.category]!,
      'rarity': _$AchievementRarityEnumMap[instance.rarity]!,
      'conditionDescription': instance.conditionDescription,
      'iconKey': instance.iconKey,
      'rewardMessage': instance.rewardMessage,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'progress': instance.progress,
      'isHidden': instance.isHidden,
      'sortOrder': instance.sortOrder,
    };

const _$AchievementCategoryEnumMap = {
  AchievementCategory.firstTime: 'firstTime',
  AchievementCategory.consistency: 'consistency',
  AchievementCategory.volume: 'volume',
  AchievementCategory.personalRecords: 'personalRecords',
  AchievementCategory.templates: 'templates',
  AchievementCategory.hidden: 'hidden',
};

const _$AchievementRarityEnumMap = {
  AchievementRarity.common: 'common',
  AchievementRarity.uncommon: 'uncommon',
  AchievementRarity.rare: 'rare',
  AchievementRarity.epic: 'epic',
  AchievementRarity.legendary: 'legendary',
};
