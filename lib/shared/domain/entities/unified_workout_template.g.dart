// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_workout_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnifiedWorkoutTemplate _$UnifiedWorkoutTemplateFromJson(
        Map<String, dynamic> json) =>
    UnifiedWorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      exercisesRaw: json['exercisesRaw'] as List<dynamic>,
      isCustom: json['isCustom'] as bool,
      isPublic: json['isPublic'] as bool,
      usageCount: (json['usageCount'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      userId: json['userId'] as String?,
      authorName: json['authorName'] as String?,
      downloadCount: (json['downloadCount'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      difficulty: json['difficulty'] as String?,
      visibility:
          $enumDecode(_$UnifiedTemplateVisibilityEnumMap, json['visibility']),
      category: $enumDecode(_$UnifiedTemplateCategoryEnumMap, json['category']),
      likeCount: (json['likeCount'] as num).toInt(),
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      requiredEquipment: (json['requiredEquipment'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      targetMuscles: (json['targetMuscles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      adaptiveParameters: json['adaptiveParameters'] as Map<String, dynamic>?,
      muscleGroupVolume:
          (json['muscleGroupVolume'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt(),
      exerciseFormat:
          $enumDecode(_$ExerciseFormatEnumMap, json['exerciseFormat']),
      source: $enumDecode(_$TemplateSourceEnumMap, json['source']),
      importSource: json['importSource'] as String?,
      importDate: json['importDate'] == null
          ? null
          : DateTime.parse(json['importDate'] as String),
      useCount: (json['useCount'] as num).toInt(),
      supportsSuperset: json['supportsSuperset'] as bool,
      requiresPremium: json['requiresPremium'] as bool,
      allowComments: json['allowComments'] as bool,
      allowRating: json['allowRating'] as bool,
      rating: (json['rating'] as num?)?.toDouble(),
      isBeingDeleted: json['isBeingDeleted'] as bool,
      isSyncInProgress: json['isSyncInProgress'] as bool,
      lastModifiedBy: json['lastModifiedBy'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UnifiedWorkoutTemplateToJson(
        UnifiedWorkoutTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'exercisesRaw': instance.exercisesRaw,
      'isCustom': instance.isCustom,
      'isPublic': instance.isPublic,
      'usageCount': instance.usageCount,
      'imageUrl': instance.imageUrl,
      'userId': instance.userId,
      'authorName': instance.authorName,
      'downloadCount': instance.downloadCount,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
      'difficulty': instance.difficulty,
      'visibility': _$UnifiedTemplateVisibilityEnumMap[instance.visibility]!,
      'category': _$UnifiedTemplateCategoryEnumMap[instance.category]!,
      'likeCount': instance.likeCount,
      'authorPhotoUrl': instance.authorPhotoUrl,
      'requiredEquipment': instance.requiredEquipment,
      'targetMuscles': instance.targetMuscles,
      'adaptiveParameters': instance.adaptiveParameters,
      'muscleGroupVolume': instance.muscleGroupVolume,
      'alternatives': instance.alternatives,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'tags': instance.tags,
      'estimatedDuration': instance.estimatedDuration,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'exerciseFormat': _$ExerciseFormatEnumMap[instance.exerciseFormat]!,
      'source': _$TemplateSourceEnumMap[instance.source]!,
      'importSource': instance.importSource,
      'importDate': instance.importDate?.toIso8601String(),
      'useCount': instance.useCount,
      'supportsSuperset': instance.supportsSuperset,
      'requiresPremium': instance.requiresPremium,
      'allowComments': instance.allowComments,
      'allowRating': instance.allowRating,
      'rating': instance.rating,
      'isBeingDeleted': instance.isBeingDeleted,
      'isSyncInProgress': instance.isSyncInProgress,
      'lastModifiedBy': instance.lastModifiedBy,
      'version': instance.version,
    };

const _$UnifiedTemplateVisibilityEnumMap = {
  UnifiedTemplateVisibility.private: 'private',
  UnifiedTemplateVisibility.public: 'public',
  UnifiedTemplateVisibility.friends: 'friends',
};

const _$UnifiedTemplateCategoryEnumMap = {
  UnifiedTemplateCategory.strength: 'strength',
  UnifiedTemplateCategory.hypertrophy: 'hypertrophy',
  UnifiedTemplateCategory.endurance: 'endurance',
  UnifiedTemplateCategory.powerlifting: 'powerlifting',
  UnifiedTemplateCategory.bodybuilding: 'bodybuilding',
  UnifiedTemplateCategory.crossfit: 'crossfit',
  UnifiedTemplateCategory.calisthenics: 'calisthenics',
  UnifiedTemplateCategory.cardio: 'cardio',
  UnifiedTemplateCategory.mixed: 'mixed',
  UnifiedTemplateCategory.custom: 'custom',
  UnifiedTemplateCategory.flexibility: 'flexibility',
};

const _$ExerciseFormatEnumMap = {
  ExerciseFormat.legacy: 'legacy',
  ExerciseFormat.modern: 'modern',
  ExerciseFormat.json: 'json',
};

const _$TemplateSourceEnumMap = {
  TemplateSource.legacy: 'legacy',
  TemplateSource.modern: 'modern',
  TemplateSource.jsonImport: 'jsonImport',
  TemplateSource.community: 'community',
};
