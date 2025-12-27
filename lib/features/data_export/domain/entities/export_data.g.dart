// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExportRequest _$ExportRequestFromJson(Map<String, dynamic> json) =>
    _ExportRequest(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => $enumDecode(_$ExportCategoryEnumMap, e))
          .toSet(),
      format:
          $enumDecodeNullable(_$ExportFormatEnumMap, json['format']) ??
          ExportFormat.zip,
      includePhotos: json['includePhotos'] as bool? ?? true,
      dateFrom: json['dateFrom'] == null
          ? null
          : DateTime.parse(json['dateFrom'] as String),
      dateTo: json['dateTo'] == null
          ? null
          : DateTime.parse(json['dateTo'] as String),
    );

Map<String, dynamic> _$ExportRequestToJson(_ExportRequest instance) =>
    <String, dynamic>{
      'categories': instance.categories
          .map((e) => _$ExportCategoryEnumMap[e]!)
          .toList(),
      'format': _$ExportFormatEnumMap[instance.format]!,
      'includePhotos': instance.includePhotos,
      'dateFrom': instance.dateFrom?.toIso8601String(),
      'dateTo': instance.dateTo?.toIso8601String(),
    };

const _$ExportCategoryEnumMap = {
  ExportCategory.workoutHistory: 'workoutHistory',
  ExportCategory.templates: 'templates',
  ExportCategory.customExercises: 'customExercises',
  ExportCategory.bodyMeasurements: 'bodyMeasurements',
  ExportCategory.progressPhotos: 'progressPhotos',
  ExportCategory.personalRecords: 'personalRecords',
  ExportCategory.settings: 'settings',
  ExportCategory.achievements: 'achievements',
};

const _$ExportFormatEnumMap = {
  ExportFormat.json: 'json',
  ExportFormat.csv: 'csv',
  ExportFormat.zip: 'zip',
};

_ExportProgress _$ExportProgressFromJson(Map<String, dynamic> json) =>
    _ExportProgress(
      status: $enumDecode(_$ExportStatusEnumMap, json['status']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      currentStep: json['currentStep'] as String?,
      errorMessage: json['errorMessage'] as String?,
      exportFilePath: json['exportFilePath'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      itemCounts:
          (json['itemCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              $enumDecode(_$ExportCategoryEnumMap, k),
              (e as num).toInt(),
            ),
          ) ??
          const {},
    );

Map<String, dynamic> _$ExportProgressToJson(_ExportProgress instance) =>
    <String, dynamic>{
      'status': _$ExportStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'currentStep': instance.currentStep,
      'errorMessage': instance.errorMessage,
      'exportFilePath': instance.exportFilePath,
      'completedAt': instance.completedAt?.toIso8601String(),
      'itemCounts': instance.itemCounts.map(
        (k, e) => MapEntry(_$ExportCategoryEnumMap[k]!, e),
      ),
    };

const _$ExportStatusEnumMap = {
  ExportStatus.idle: 'idle',
  ExportStatus.preparing: 'preparing',
  ExportStatus.collectingWorkouts: 'collectingWorkouts',
  ExportStatus.collectingTemplates: 'collectingTemplates',
  ExportStatus.collectingExercises: 'collectingExercises',
  ExportStatus.collectingMeasurements: 'collectingMeasurements',
  ExportStatus.collectingPhotos: 'collectingPhotos',
  ExportStatus.collectingRecords: 'collectingRecords',
  ExportStatus.collectingSettings: 'collectingSettings',
  ExportStatus.packaging: 'packaging',
  ExportStatus.completed: 'completed',
  ExportStatus.failed: 'failed',
};

_ExportedData _$ExportedDataFromJson(Map<String, dynamic> json) =>
    _ExportedData(
      exportId: json['exportId'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      appVersion: json['appVersion'] as String,
      userId: json['userId'] as String,
      workouts:
          (json['workouts'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      templates:
          (json['templates'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      customExercises:
          (json['customExercises'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      bodyMeasurements:
          (json['bodyMeasurements'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      progressPhotoUrls:
          (json['progressPhotoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      personalRecords:
          (json['personalRecords'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ExportedDataToJson(_ExportedData instance) =>
    <String, dynamic>{
      'exportId': instance.exportId,
      'exportedAt': instance.exportedAt.toIso8601String(),
      'appVersion': instance.appVersion,
      'userId': instance.userId,
      'workouts': instance.workouts,
      'templates': instance.templates,
      'customExercises': instance.customExercises,
      'bodyMeasurements': instance.bodyMeasurements,
      'progressPhotoUrls': instance.progressPhotoUrls,
      'personalRecords': instance.personalRecords,
      'settings': instance.settings,
      'achievements': instance.achievements,
    };
