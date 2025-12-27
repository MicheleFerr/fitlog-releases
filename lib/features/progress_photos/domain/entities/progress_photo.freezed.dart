// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProgressPhoto {

/// Unique identifier (UUID v4)
 String get id;/// User ID (Firebase Auth UID)
/// GDPR: Required for data isolation and deletion
 String get userId;/// Firebase Storage URL for full-size photo (WebP, ~200KB)
 String get photoUrl;/// Firebase Storage URL for thumbnail (~20KB, 200x200)
 String get thumbnailUrl;/// Storage path in Firebase Storage (for deletion)
/// Example: "users/{userId}/progress_photos/2025-01-15_front.webp"
 String get storagePath;/// Storage path for thumbnail
 String get thumbnailStoragePath;/// Pose/angle of the photo
 PhotoPose get pose;/// When the photo was taken (user's local time)
 DateTime get takenAt;/// File size in bytes (compressed WebP)
 int get fileSizeBytes;/// Original file size before compression (for stats)
 int? get originalFileSizeBytes;/// Optional user notes (max 500 characters)
 String? get notes;/// Optional body weight at time of photo (kg)
 double? get weightKg;/// When this photo was created in the app
 DateTime? get createdAt;/// When this photo was last modified
 DateTime? get updatedAt;/// Whether this photo is shared with coach
/// GDPR: Requires explicit consent
 bool get isSharedWithCoach;/// Coach ID if shared (null if not shared)
 String? get sharedWithCoachId;/// When sharing was enabled
 DateTime? get sharedAt;/// Whether this photo is marked for deletion
/// GDPR: Soft-delete with 30-day retention
 bool get isDeleted;/// When this photo was soft-deleted
 DateTime? get deletedAt;/// Sync status with cloud
 SyncStatus get syncStatus;
/// Create a copy of ProgressPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressPhotoCopyWith<ProgressPhoto> get copyWith => _$ProgressPhotoCopyWithImpl<ProgressPhoto>(this as ProgressPhoto, _$identity);

  /// Serializes this ProgressPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.thumbnailStoragePath, thumbnailStoragePath) || other.thumbnailStoragePath == thumbnailStoragePath)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.originalFileSizeBytes, originalFileSizeBytes) || other.originalFileSizeBytes == originalFileSizeBytes)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSharedWithCoach, isSharedWithCoach) || other.isSharedWithCoach == isSharedWithCoach)&&(identical(other.sharedWithCoachId, sharedWithCoachId) || other.sharedWithCoachId == sharedWithCoachId)&&(identical(other.sharedAt, sharedAt) || other.sharedAt == sharedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,photoUrl,thumbnailUrl,storagePath,thumbnailStoragePath,pose,takenAt,fileSizeBytes,originalFileSizeBytes,notes,weightKg,createdAt,updatedAt,isSharedWithCoach,sharedWithCoachId,sharedAt,isDeleted,deletedAt,syncStatus]);

@override
String toString() {
  return 'ProgressPhoto(id: $id, userId: $userId, photoUrl: $photoUrl, thumbnailUrl: $thumbnailUrl, storagePath: $storagePath, thumbnailStoragePath: $thumbnailStoragePath, pose: $pose, takenAt: $takenAt, fileSizeBytes: $fileSizeBytes, originalFileSizeBytes: $originalFileSizeBytes, notes: $notes, weightKg: $weightKg, createdAt: $createdAt, updatedAt: $updatedAt, isSharedWithCoach: $isSharedWithCoach, sharedWithCoachId: $sharedWithCoachId, sharedAt: $sharedAt, isDeleted: $isDeleted, deletedAt: $deletedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $ProgressPhotoCopyWith<$Res>  {
  factory $ProgressPhotoCopyWith(ProgressPhoto value, $Res Function(ProgressPhoto) _then) = _$ProgressPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String photoUrl, String thumbnailUrl, String storagePath, String thumbnailStoragePath, PhotoPose pose, DateTime takenAt, int fileSizeBytes, int? originalFileSizeBytes, String? notes, double? weightKg, DateTime? createdAt, DateTime? updatedAt, bool isSharedWithCoach, String? sharedWithCoachId, DateTime? sharedAt, bool isDeleted, DateTime? deletedAt, SyncStatus syncStatus
});




}
/// @nodoc
class _$ProgressPhotoCopyWithImpl<$Res>
    implements $ProgressPhotoCopyWith<$Res> {
  _$ProgressPhotoCopyWithImpl(this._self, this._then);

  final ProgressPhoto _self;
  final $Res Function(ProgressPhoto) _then;

/// Create a copy of ProgressPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? photoUrl = null,Object? thumbnailUrl = null,Object? storagePath = null,Object? thumbnailStoragePath = null,Object? pose = null,Object? takenAt = null,Object? fileSizeBytes = null,Object? originalFileSizeBytes = freezed,Object? notes = freezed,Object? weightKg = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isSharedWithCoach = null,Object? sharedWithCoachId = freezed,Object? sharedAt = freezed,Object? isDeleted = null,Object? deletedAt = freezed,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,thumbnailStoragePath: null == thumbnailStoragePath ? _self.thumbnailStoragePath : thumbnailStoragePath // ignore: cast_nullable_to_non_nullable
as String,pose: null == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as PhotoPose,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,originalFileSizeBytes: freezed == originalFileSizeBytes ? _self.originalFileSizeBytes : originalFileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isSharedWithCoach: null == isSharedWithCoach ? _self.isSharedWithCoach : isSharedWithCoach // ignore: cast_nullable_to_non_nullable
as bool,sharedWithCoachId: freezed == sharedWithCoachId ? _self.sharedWithCoachId : sharedWithCoachId // ignore: cast_nullable_to_non_nullable
as String?,sharedAt: freezed == sharedAt ? _self.sharedAt : sharedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressPhoto].
extension ProgressPhotoPatterns on ProgressPhoto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressPhoto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressPhoto value)  $default,){
final _that = this;
switch (_that) {
case _ProgressPhoto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressPhoto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String photoUrl,  String thumbnailUrl,  String storagePath,  String thumbnailStoragePath,  PhotoPose pose,  DateTime takenAt,  int fileSizeBytes,  int? originalFileSizeBytes,  String? notes,  double? weightKg,  DateTime? createdAt,  DateTime? updatedAt,  bool isSharedWithCoach,  String? sharedWithCoachId,  DateTime? sharedAt,  bool isDeleted,  DateTime? deletedAt,  SyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressPhoto() when $default != null:
return $default(_that.id,_that.userId,_that.photoUrl,_that.thumbnailUrl,_that.storagePath,_that.thumbnailStoragePath,_that.pose,_that.takenAt,_that.fileSizeBytes,_that.originalFileSizeBytes,_that.notes,_that.weightKg,_that.createdAt,_that.updatedAt,_that.isSharedWithCoach,_that.sharedWithCoachId,_that.sharedAt,_that.isDeleted,_that.deletedAt,_that.syncStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String photoUrl,  String thumbnailUrl,  String storagePath,  String thumbnailStoragePath,  PhotoPose pose,  DateTime takenAt,  int fileSizeBytes,  int? originalFileSizeBytes,  String? notes,  double? weightKg,  DateTime? createdAt,  DateTime? updatedAt,  bool isSharedWithCoach,  String? sharedWithCoachId,  DateTime? sharedAt,  bool isDeleted,  DateTime? deletedAt,  SyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _ProgressPhoto():
return $default(_that.id,_that.userId,_that.photoUrl,_that.thumbnailUrl,_that.storagePath,_that.thumbnailStoragePath,_that.pose,_that.takenAt,_that.fileSizeBytes,_that.originalFileSizeBytes,_that.notes,_that.weightKg,_that.createdAt,_that.updatedAt,_that.isSharedWithCoach,_that.sharedWithCoachId,_that.sharedAt,_that.isDeleted,_that.deletedAt,_that.syncStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String photoUrl,  String thumbnailUrl,  String storagePath,  String thumbnailStoragePath,  PhotoPose pose,  DateTime takenAt,  int fileSizeBytes,  int? originalFileSizeBytes,  String? notes,  double? weightKg,  DateTime? createdAt,  DateTime? updatedAt,  bool isSharedWithCoach,  String? sharedWithCoachId,  DateTime? sharedAt,  bool isDeleted,  DateTime? deletedAt,  SyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _ProgressPhoto() when $default != null:
return $default(_that.id,_that.userId,_that.photoUrl,_that.thumbnailUrl,_that.storagePath,_that.thumbnailStoragePath,_that.pose,_that.takenAt,_that.fileSizeBytes,_that.originalFileSizeBytes,_that.notes,_that.weightKg,_that.createdAt,_that.updatedAt,_that.isSharedWithCoach,_that.sharedWithCoachId,_that.sharedAt,_that.isDeleted,_that.deletedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgressPhoto implements ProgressPhoto {
  const _ProgressPhoto({required this.id, required this.userId, required this.photoUrl, required this.thumbnailUrl, required this.storagePath, required this.thumbnailStoragePath, required this.pose, required this.takenAt, required this.fileSizeBytes, this.originalFileSizeBytes, this.notes, this.weightKg, this.createdAt, this.updatedAt, this.isSharedWithCoach = false, this.sharedWithCoachId, this.sharedAt, this.isDeleted = false, this.deletedAt, this.syncStatus = SyncStatus.pending});
  factory _ProgressPhoto.fromJson(Map<String, dynamic> json) => _$ProgressPhotoFromJson(json);

/// Unique identifier (UUID v4)
@override final  String id;
/// User ID (Firebase Auth UID)
/// GDPR: Required for data isolation and deletion
@override final  String userId;
/// Firebase Storage URL for full-size photo (WebP, ~200KB)
@override final  String photoUrl;
/// Firebase Storage URL for thumbnail (~20KB, 200x200)
@override final  String thumbnailUrl;
/// Storage path in Firebase Storage (for deletion)
/// Example: "users/{userId}/progress_photos/2025-01-15_front.webp"
@override final  String storagePath;
/// Storage path for thumbnail
@override final  String thumbnailStoragePath;
/// Pose/angle of the photo
@override final  PhotoPose pose;
/// When the photo was taken (user's local time)
@override final  DateTime takenAt;
/// File size in bytes (compressed WebP)
@override final  int fileSizeBytes;
/// Original file size before compression (for stats)
@override final  int? originalFileSizeBytes;
/// Optional user notes (max 500 characters)
@override final  String? notes;
/// Optional body weight at time of photo (kg)
@override final  double? weightKg;
/// When this photo was created in the app
@override final  DateTime? createdAt;
/// When this photo was last modified
@override final  DateTime? updatedAt;
/// Whether this photo is shared with coach
/// GDPR: Requires explicit consent
@override@JsonKey() final  bool isSharedWithCoach;
/// Coach ID if shared (null if not shared)
@override final  String? sharedWithCoachId;
/// When sharing was enabled
@override final  DateTime? sharedAt;
/// Whether this photo is marked for deletion
/// GDPR: Soft-delete with 30-day retention
@override@JsonKey() final  bool isDeleted;
/// When this photo was soft-deleted
@override final  DateTime? deletedAt;
/// Sync status with cloud
@override@JsonKey() final  SyncStatus syncStatus;

/// Create a copy of ProgressPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressPhotoCopyWith<_ProgressPhoto> get copyWith => __$ProgressPhotoCopyWithImpl<_ProgressPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgressPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.thumbnailStoragePath, thumbnailStoragePath) || other.thumbnailStoragePath == thumbnailStoragePath)&&(identical(other.pose, pose) || other.pose == pose)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.originalFileSizeBytes, originalFileSizeBytes) || other.originalFileSizeBytes == originalFileSizeBytes)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSharedWithCoach, isSharedWithCoach) || other.isSharedWithCoach == isSharedWithCoach)&&(identical(other.sharedWithCoachId, sharedWithCoachId) || other.sharedWithCoachId == sharedWithCoachId)&&(identical(other.sharedAt, sharedAt) || other.sharedAt == sharedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,photoUrl,thumbnailUrl,storagePath,thumbnailStoragePath,pose,takenAt,fileSizeBytes,originalFileSizeBytes,notes,weightKg,createdAt,updatedAt,isSharedWithCoach,sharedWithCoachId,sharedAt,isDeleted,deletedAt,syncStatus]);

@override
String toString() {
  return 'ProgressPhoto(id: $id, userId: $userId, photoUrl: $photoUrl, thumbnailUrl: $thumbnailUrl, storagePath: $storagePath, thumbnailStoragePath: $thumbnailStoragePath, pose: $pose, takenAt: $takenAt, fileSizeBytes: $fileSizeBytes, originalFileSizeBytes: $originalFileSizeBytes, notes: $notes, weightKg: $weightKg, createdAt: $createdAt, updatedAt: $updatedAt, isSharedWithCoach: $isSharedWithCoach, sharedWithCoachId: $sharedWithCoachId, sharedAt: $sharedAt, isDeleted: $isDeleted, deletedAt: $deletedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$ProgressPhotoCopyWith<$Res> implements $ProgressPhotoCopyWith<$Res> {
  factory _$ProgressPhotoCopyWith(_ProgressPhoto value, $Res Function(_ProgressPhoto) _then) = __$ProgressPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String photoUrl, String thumbnailUrl, String storagePath, String thumbnailStoragePath, PhotoPose pose, DateTime takenAt, int fileSizeBytes, int? originalFileSizeBytes, String? notes, double? weightKg, DateTime? createdAt, DateTime? updatedAt, bool isSharedWithCoach, String? sharedWithCoachId, DateTime? sharedAt, bool isDeleted, DateTime? deletedAt, SyncStatus syncStatus
});




}
/// @nodoc
class __$ProgressPhotoCopyWithImpl<$Res>
    implements _$ProgressPhotoCopyWith<$Res> {
  __$ProgressPhotoCopyWithImpl(this._self, this._then);

  final _ProgressPhoto _self;
  final $Res Function(_ProgressPhoto) _then;

/// Create a copy of ProgressPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? photoUrl = null,Object? thumbnailUrl = null,Object? storagePath = null,Object? thumbnailStoragePath = null,Object? pose = null,Object? takenAt = null,Object? fileSizeBytes = null,Object? originalFileSizeBytes = freezed,Object? notes = freezed,Object? weightKg = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isSharedWithCoach = null,Object? sharedWithCoachId = freezed,Object? sharedAt = freezed,Object? isDeleted = null,Object? deletedAt = freezed,Object? syncStatus = null,}) {
  return _then(_ProgressPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,thumbnailStoragePath: null == thumbnailStoragePath ? _self.thumbnailStoragePath : thumbnailStoragePath // ignore: cast_nullable_to_non_nullable
as String,pose: null == pose ? _self.pose : pose // ignore: cast_nullable_to_non_nullable
as PhotoPose,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileSizeBytes: null == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int,originalFileSizeBytes: freezed == originalFileSizeBytes ? _self.originalFileSizeBytes : originalFileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isSharedWithCoach: null == isSharedWithCoach ? _self.isSharedWithCoach : isSharedWithCoach // ignore: cast_nullable_to_non_nullable
as bool,sharedWithCoachId: freezed == sharedWithCoachId ? _self.sharedWithCoachId : sharedWithCoachId // ignore: cast_nullable_to_non_nullable
as String?,sharedAt: freezed == sharedAt ? _self.sharedAt : sharedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}


}


/// @nodoc
mixin _$PhotoUploadProgress {

/// Photo being uploaded
 String get photoId;/// Upload progress (0.0 - 1.0)
 double get progress;/// Current status
 UploadStatus get status;/// Error message if failed
 String? get errorMessage;/// Bytes uploaded so far
 int get bytesUploaded;/// Total bytes to upload
 int get totalBytes;
/// Create a copy of PhotoUploadProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoUploadProgressCopyWith<PhotoUploadProgress> get copyWith => _$PhotoUploadProgressCopyWithImpl<PhotoUploadProgress>(this as PhotoUploadProgress, _$identity);

  /// Serializes this PhotoUploadProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoUploadProgress&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.bytesUploaded, bytesUploaded) || other.bytesUploaded == bytesUploaded)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,photoId,progress,status,errorMessage,bytesUploaded,totalBytes);

@override
String toString() {
  return 'PhotoUploadProgress(photoId: $photoId, progress: $progress, status: $status, errorMessage: $errorMessage, bytesUploaded: $bytesUploaded, totalBytes: $totalBytes)';
}


}

/// @nodoc
abstract mixin class $PhotoUploadProgressCopyWith<$Res>  {
  factory $PhotoUploadProgressCopyWith(PhotoUploadProgress value, $Res Function(PhotoUploadProgress) _then) = _$PhotoUploadProgressCopyWithImpl;
@useResult
$Res call({
 String photoId, double progress, UploadStatus status, String? errorMessage, int bytesUploaded, int totalBytes
});




}
/// @nodoc
class _$PhotoUploadProgressCopyWithImpl<$Res>
    implements $PhotoUploadProgressCopyWith<$Res> {
  _$PhotoUploadProgressCopyWithImpl(this._self, this._then);

  final PhotoUploadProgress _self;
  final $Res Function(PhotoUploadProgress) _then;

/// Create a copy of PhotoUploadProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photoId = null,Object? progress = null,Object? status = null,Object? errorMessage = freezed,Object? bytesUploaded = null,Object? totalBytes = null,}) {
  return _then(_self.copyWith(
photoId: null == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,bytesUploaded: null == bytesUploaded ? _self.bytesUploaded : bytesUploaded // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoUploadProgress].
extension PhotoUploadProgressPatterns on PhotoUploadProgress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoUploadProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoUploadProgress() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoUploadProgress value)  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadProgress():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoUploadProgress value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadProgress() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String photoId,  double progress,  UploadStatus status,  String? errorMessage,  int bytesUploaded,  int totalBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoUploadProgress() when $default != null:
return $default(_that.photoId,_that.progress,_that.status,_that.errorMessage,_that.bytesUploaded,_that.totalBytes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String photoId,  double progress,  UploadStatus status,  String? errorMessage,  int bytesUploaded,  int totalBytes)  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadProgress():
return $default(_that.photoId,_that.progress,_that.status,_that.errorMessage,_that.bytesUploaded,_that.totalBytes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String photoId,  double progress,  UploadStatus status,  String? errorMessage,  int bytesUploaded,  int totalBytes)?  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadProgress() when $default != null:
return $default(_that.photoId,_that.progress,_that.status,_that.errorMessage,_that.bytesUploaded,_that.totalBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoUploadProgress implements PhotoUploadProgress {
  const _PhotoUploadProgress({required this.photoId, required this.progress, required this.status, this.errorMessage, this.bytesUploaded = 0, this.totalBytes = 0});
  factory _PhotoUploadProgress.fromJson(Map<String, dynamic> json) => _$PhotoUploadProgressFromJson(json);

/// Photo being uploaded
@override final  String photoId;
/// Upload progress (0.0 - 1.0)
@override final  double progress;
/// Current status
@override final  UploadStatus status;
/// Error message if failed
@override final  String? errorMessage;
/// Bytes uploaded so far
@override@JsonKey() final  int bytesUploaded;
/// Total bytes to upload
@override@JsonKey() final  int totalBytes;

/// Create a copy of PhotoUploadProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoUploadProgressCopyWith<_PhotoUploadProgress> get copyWith => __$PhotoUploadProgressCopyWithImpl<_PhotoUploadProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoUploadProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoUploadProgress&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.bytesUploaded, bytesUploaded) || other.bytesUploaded == bytesUploaded)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,photoId,progress,status,errorMessage,bytesUploaded,totalBytes);

@override
String toString() {
  return 'PhotoUploadProgress(photoId: $photoId, progress: $progress, status: $status, errorMessage: $errorMessage, bytesUploaded: $bytesUploaded, totalBytes: $totalBytes)';
}


}

/// @nodoc
abstract mixin class _$PhotoUploadProgressCopyWith<$Res> implements $PhotoUploadProgressCopyWith<$Res> {
  factory _$PhotoUploadProgressCopyWith(_PhotoUploadProgress value, $Res Function(_PhotoUploadProgress) _then) = __$PhotoUploadProgressCopyWithImpl;
@override @useResult
$Res call({
 String photoId, double progress, UploadStatus status, String? errorMessage, int bytesUploaded, int totalBytes
});




}
/// @nodoc
class __$PhotoUploadProgressCopyWithImpl<$Res>
    implements _$PhotoUploadProgressCopyWith<$Res> {
  __$PhotoUploadProgressCopyWithImpl(this._self, this._then);

  final _PhotoUploadProgress _self;
  final $Res Function(_PhotoUploadProgress) _then;

/// Create a copy of PhotoUploadProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photoId = null,Object? progress = null,Object? status = null,Object? errorMessage = freezed,Object? bytesUploaded = null,Object? totalBytes = null,}) {
  return _then(_PhotoUploadProgress(
photoId: null == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,bytesUploaded: null == bytesUploaded ? _self.bytesUploaded : bytesUploaded // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PhotoComparisonPair {

/// Earlier photo (before)
 ProgressPhoto get before;/// Later photo (after)
 ProgressPhoto get after;/// Days between photos
 int get daysBetween;/// Weight change in kg (if both have weight data)
 double? get weightChangeKg;
/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoComparisonPairCopyWith<PhotoComparisonPair> get copyWith => _$PhotoComparisonPairCopyWithImpl<PhotoComparisonPair>(this as PhotoComparisonPair, _$identity);

  /// Serializes this PhotoComparisonPair to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoComparisonPair&&(identical(other.before, before) || other.before == before)&&(identical(other.after, after) || other.after == after)&&(identical(other.daysBetween, daysBetween) || other.daysBetween == daysBetween)&&(identical(other.weightChangeKg, weightChangeKg) || other.weightChangeKg == weightChangeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,before,after,daysBetween,weightChangeKg);

@override
String toString() {
  return 'PhotoComparisonPair(before: $before, after: $after, daysBetween: $daysBetween, weightChangeKg: $weightChangeKg)';
}


}

/// @nodoc
abstract mixin class $PhotoComparisonPairCopyWith<$Res>  {
  factory $PhotoComparisonPairCopyWith(PhotoComparisonPair value, $Res Function(PhotoComparisonPair) _then) = _$PhotoComparisonPairCopyWithImpl;
@useResult
$Res call({
 ProgressPhoto before, ProgressPhoto after, int daysBetween, double? weightChangeKg
});


$ProgressPhotoCopyWith<$Res> get before;$ProgressPhotoCopyWith<$Res> get after;

}
/// @nodoc
class _$PhotoComparisonPairCopyWithImpl<$Res>
    implements $PhotoComparisonPairCopyWith<$Res> {
  _$PhotoComparisonPairCopyWithImpl(this._self, this._then);

  final PhotoComparisonPair _self;
  final $Res Function(PhotoComparisonPair) _then;

/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? before = null,Object? after = null,Object? daysBetween = null,Object? weightChangeKg = freezed,}) {
  return _then(_self.copyWith(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as ProgressPhoto,after: null == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as ProgressPhoto,daysBetween: null == daysBetween ? _self.daysBetween : daysBetween // ignore: cast_nullable_to_non_nullable
as int,weightChangeKg: freezed == weightChangeKg ? _self.weightChangeKg : weightChangeKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressPhotoCopyWith<$Res> get before {
  
  return $ProgressPhotoCopyWith<$Res>(_self.before, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressPhotoCopyWith<$Res> get after {
  
  return $ProgressPhotoCopyWith<$Res>(_self.after, (value) {
    return _then(_self.copyWith(after: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhotoComparisonPair].
extension PhotoComparisonPairPatterns on PhotoComparisonPair {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoComparisonPair value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoComparisonPair() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoComparisonPair value)  $default,){
final _that = this;
switch (_that) {
case _PhotoComparisonPair():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoComparisonPair value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoComparisonPair() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProgressPhoto before,  ProgressPhoto after,  int daysBetween,  double? weightChangeKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoComparisonPair() when $default != null:
return $default(_that.before,_that.after,_that.daysBetween,_that.weightChangeKg);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProgressPhoto before,  ProgressPhoto after,  int daysBetween,  double? weightChangeKg)  $default,) {final _that = this;
switch (_that) {
case _PhotoComparisonPair():
return $default(_that.before,_that.after,_that.daysBetween,_that.weightChangeKg);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProgressPhoto before,  ProgressPhoto after,  int daysBetween,  double? weightChangeKg)?  $default,) {final _that = this;
switch (_that) {
case _PhotoComparisonPair() when $default != null:
return $default(_that.before,_that.after,_that.daysBetween,_that.weightChangeKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoComparisonPair implements PhotoComparisonPair {
  const _PhotoComparisonPair({required this.before, required this.after, required this.daysBetween, this.weightChangeKg});
  factory _PhotoComparisonPair.fromJson(Map<String, dynamic> json) => _$PhotoComparisonPairFromJson(json);

/// Earlier photo (before)
@override final  ProgressPhoto before;
/// Later photo (after)
@override final  ProgressPhoto after;
/// Days between photos
@override final  int daysBetween;
/// Weight change in kg (if both have weight data)
@override final  double? weightChangeKg;

/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoComparisonPairCopyWith<_PhotoComparisonPair> get copyWith => __$PhotoComparisonPairCopyWithImpl<_PhotoComparisonPair>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoComparisonPairToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoComparisonPair&&(identical(other.before, before) || other.before == before)&&(identical(other.after, after) || other.after == after)&&(identical(other.daysBetween, daysBetween) || other.daysBetween == daysBetween)&&(identical(other.weightChangeKg, weightChangeKg) || other.weightChangeKg == weightChangeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,before,after,daysBetween,weightChangeKg);

@override
String toString() {
  return 'PhotoComparisonPair(before: $before, after: $after, daysBetween: $daysBetween, weightChangeKg: $weightChangeKg)';
}


}

/// @nodoc
abstract mixin class _$PhotoComparisonPairCopyWith<$Res> implements $PhotoComparisonPairCopyWith<$Res> {
  factory _$PhotoComparisonPairCopyWith(_PhotoComparisonPair value, $Res Function(_PhotoComparisonPair) _then) = __$PhotoComparisonPairCopyWithImpl;
@override @useResult
$Res call({
 ProgressPhoto before, ProgressPhoto after, int daysBetween, double? weightChangeKg
});


@override $ProgressPhotoCopyWith<$Res> get before;@override $ProgressPhotoCopyWith<$Res> get after;

}
/// @nodoc
class __$PhotoComparisonPairCopyWithImpl<$Res>
    implements _$PhotoComparisonPairCopyWith<$Res> {
  __$PhotoComparisonPairCopyWithImpl(this._self, this._then);

  final _PhotoComparisonPair _self;
  final $Res Function(_PhotoComparisonPair) _then;

/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? before = null,Object? after = null,Object? daysBetween = null,Object? weightChangeKg = freezed,}) {
  return _then(_PhotoComparisonPair(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as ProgressPhoto,after: null == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as ProgressPhoto,daysBetween: null == daysBetween ? _self.daysBetween : daysBetween // ignore: cast_nullable_to_non_nullable
as int,weightChangeKg: freezed == weightChangeKg ? _self.weightChangeKg : weightChangeKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressPhotoCopyWith<$Res> get before {
  
  return $ProgressPhotoCopyWith<$Res>(_self.before, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of PhotoComparisonPair
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressPhotoCopyWith<$Res> get after {
  
  return $ProgressPhotoCopyWith<$Res>(_self.after, (value) {
    return _then(_self.copyWith(after: value));
  });
}
}

// dart format on
