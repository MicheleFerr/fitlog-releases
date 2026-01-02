// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateFolder _$TemplateFolderFromJson(Map<String, dynamic> json) =>
    _TemplateFolder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      color: json['color'] as String?,
      icon:
          $enumDecodeNullable(_$FolderIconEnumMap, json['icon']) ??
          FolderIcon.folder,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      depth: (json['depth'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      templateCount: (json['templateCount'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TemplateFolderToJson(_TemplateFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'parentId': instance.parentId,
      'color': instance.color,
      'icon': _$FolderIconEnumMap[instance.icon]!,
      'sortOrder': instance.sortOrder,
      'depth': instance.depth,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'templateCount': instance.templateCount,
      'description': instance.description,
    };

const _$FolderIconEnumMap = {
  FolderIcon.folder: 'folder',
  FolderIcon.star: 'star',
  FolderIcon.fire: 'fire',
  FolderIcon.muscle: 'muscle',
  FolderIcon.dumbbell: 'dumbbell',
  FolderIcon.run: 'run',
  FolderIcon.heart: 'heart',
  FolderIcon.trophy: 'trophy',
  FolderIcon.calendar: 'calendar',
  FolderIcon.target: 'target',
};
