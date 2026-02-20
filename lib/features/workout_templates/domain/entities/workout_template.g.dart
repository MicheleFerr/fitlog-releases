// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunityWorkoutTemplate _$CommunityWorkoutTemplateFromJson(
  Map<String, dynamic> json,
) => _CommunityWorkoutTemplate(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
      .toList(),
  category:
      $enumDecodeNullable(_$TemplateCategoryEnumMap, json['category']) ??
      TemplateCategory.custom,
  visibility:
      $enumDecodeNullable(_$TemplateVisibilityEnumMap, json['visibility']) ??
      TemplateVisibility.private,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  authorName: json['authorName'] as String?,
  authorPhotoUrl: json['authorPhotoUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  folderId: json['folderId'] as String?,
  estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt(),
  difficultyLevel: json['difficultyLevel'] as String?,
  requiredEquipment:
      (json['requiredEquipment'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  targetMuscles:
      (json['targetMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  forkedFromTemplateId: json['forkedFromTemplateId'] as String?,
  originalAuthorName: json['originalAuthorName'] as String?,
);

Map<String, dynamic> _$CommunityWorkoutTemplateToJson(
  _CommunityWorkoutTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'description': instance.description,
  'exercises': instance.exercises.map((e) => e.toJson()).toList(),
  'category': _$TemplateCategoryEnumMap[instance.category]!,
  'visibility': _$TemplateVisibilityEnumMap[instance.visibility]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'downloadCount': instance.downloadCount,
  'likeCount': instance.likeCount,
  'reviewCount': instance.reviewCount,
  'averageRating': instance.averageRating,
  'authorName': instance.authorName,
  'authorPhotoUrl': instance.authorPhotoUrl,
  'tags': instance.tags,
  'folderId': instance.folderId,
  'estimatedDurationMinutes': instance.estimatedDurationMinutes,
  'difficultyLevel': instance.difficultyLevel,
  'requiredEquipment': instance.requiredEquipment,
  'targetMuscles': instance.targetMuscles,
  'isAnonymous': instance.isAnonymous,
  'forkedFromTemplateId': instance.forkedFromTemplateId,
  'originalAuthorName': instance.originalAuthorName,
};

const _$TemplateCategoryEnumMap = {
  TemplateCategory.strength: 'strength',
  TemplateCategory.hypertrophy: 'hypertrophy',
  TemplateCategory.endurance: 'endurance',
  TemplateCategory.powerlifting: 'powerlifting',
  TemplateCategory.bodybuilding: 'bodybuilding',
  TemplateCategory.crossfit: 'crossfit',
  TemplateCategory.calisthenics: 'calisthenics',
  TemplateCategory.cardio: 'cardio',
  TemplateCategory.mixed: 'mixed',
  TemplateCategory.custom: 'custom',
};

const _$TemplateVisibilityEnumMap = {
  TemplateVisibility.private: 'private',
  TemplateVisibility.public: 'public',
  TemplateVisibility.friends: 'friends',
};
