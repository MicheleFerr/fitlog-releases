// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ice_breaker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IceBreakerImpl _$$IceBreakerImplFromJson(Map<String, dynamic> json) =>
    _$IceBreakerImpl(
      id: json['id'] as String,
      messageTemplate: json['messageTemplate'] as String,
      category: $enumDecode(_$IceBreakerCategoryEnumMap, json['category']),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isActive: json['isActive'] as bool? ?? true,
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$IceBreakerImplToJson(_$IceBreakerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageTemplate': instance.messageTemplate,
      'category': _$IceBreakerCategoryEnumMap[instance.category]!,
      'tags': instance.tags,
      'isActive': instance.isActive,
      'usageCount': instance.usageCount,
    };

const _$IceBreakerCategoryEnumMap = {
  IceBreakerCategory.workout: 'workout',
  IceBreakerCategory.motivation: 'motivation',
  IceBreakerCategory.fitness: 'fitness',
  IceBreakerCategory.goals: 'goals',
  IceBreakerCategory.experience: 'experience',
  IceBreakerCategory.casual: 'casual',
};
