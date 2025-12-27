// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProgressPhoto _$ProgressPhotoFromJson(Map<String, dynamic> json) =>
    _ProgressPhoto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      photoUrl: json['photoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      storagePath: json['storagePath'] as String,
      thumbnailStoragePath: json['thumbnailStoragePath'] as String,
      pose: $enumDecode(_$PhotoPoseEnumMap, json['pose']),
      takenAt: DateTime.parse(json['takenAt'] as String),
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      originalFileSizeBytes: (json['originalFileSizeBytes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isSharedWithCoach: json['isSharedWithCoach'] as bool? ?? false,
      sharedWithCoachId: json['sharedWithCoachId'] as String?,
      sharedAt: json['sharedAt'] == null
          ? null
          : DateTime.parse(json['sharedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.pending,
    );

Map<String, dynamic> _$ProgressPhotoToJson(_ProgressPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'photoUrl': instance.photoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'storagePath': instance.storagePath,
      'thumbnailStoragePath': instance.thumbnailStoragePath,
      'pose': _$PhotoPoseEnumMap[instance.pose]!,
      'takenAt': instance.takenAt.toIso8601String(),
      'fileSizeBytes': instance.fileSizeBytes,
      'originalFileSizeBytes': instance.originalFileSizeBytes,
      'notes': instance.notes,
      'weightKg': instance.weightKg,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isSharedWithCoach': instance.isSharedWithCoach,
      'sharedWithCoachId': instance.sharedWithCoachId,
      'sharedAt': instance.sharedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
    };

const _$PhotoPoseEnumMap = {
  PhotoPose.frontRelaxed: 'frontRelaxed',
  PhotoPose.frontFlexed: 'frontFlexed',
  PhotoPose.sideLeft: 'sideLeft',
  PhotoPose.sideRight: 'sideRight',
  PhotoPose.backRelaxed: 'backRelaxed',
  PhotoPose.backFlexed: 'backFlexed',
  PhotoPose.other: 'other',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.uploading: 'uploading',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
};

_PhotoUploadProgress _$PhotoUploadProgressFromJson(Map<String, dynamic> json) =>
    _PhotoUploadProgress(
      photoId: json['photoId'] as String,
      progress: (json['progress'] as num).toDouble(),
      status: $enumDecode(_$UploadStatusEnumMap, json['status']),
      errorMessage: json['errorMessage'] as String?,
      bytesUploaded: (json['bytesUploaded'] as num?)?.toInt() ?? 0,
      totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PhotoUploadProgressToJson(
  _PhotoUploadProgress instance,
) => <String, dynamic>{
  'photoId': instance.photoId,
  'progress': instance.progress,
  'status': _$UploadStatusEnumMap[instance.status]!,
  'errorMessage': instance.errorMessage,
  'bytesUploaded': instance.bytesUploaded,
  'totalBytes': instance.totalBytes,
};

const _$UploadStatusEnumMap = {
  UploadStatus.pending: 'pending',
  UploadStatus.compressing: 'compressing',
  UploadStatus.uploading: 'uploading',
  UploadStatus.completed: 'completed',
  UploadStatus.failed: 'failed',
  UploadStatus.cancelled: 'cancelled',
};

_PhotoComparisonPair _$PhotoComparisonPairFromJson(Map<String, dynamic> json) =>
    _PhotoComparisonPair(
      before: ProgressPhoto.fromJson(json['before'] as Map<String, dynamic>),
      after: ProgressPhoto.fromJson(json['after'] as Map<String, dynamic>),
      daysBetween: (json['daysBetween'] as num).toInt(),
      weightChangeKg: (json['weightChangeKg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PhotoComparisonPairToJson(
  _PhotoComparisonPair instance,
) => <String, dynamic>{
  'before': instance.before.toJson(),
  'after': instance.after.toJson(),
  'daysBetween': instance.daysBetween,
  'weightChangeKg': instance.weightChangeKg,
};
