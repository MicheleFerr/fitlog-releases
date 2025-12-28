// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutLinkMetadata {

 String get workoutId; String get workoutName; int get durationMinutes; DateTime get completedAt; int? get exerciseCount; double? get totalVolumeKg;
/// Create a copy of WorkoutLinkMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutLinkMetadataCopyWith<WorkoutLinkMetadata> get copyWith => _$WorkoutLinkMetadataCopyWithImpl<WorkoutLinkMetadata>(this as WorkoutLinkMetadata, _$identity);

  /// Serializes this WorkoutLinkMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutLinkMetadata&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutId,workoutName,durationMinutes,completedAt,exerciseCount,totalVolumeKg);

@override
String toString() {
  return 'WorkoutLinkMetadata(workoutId: $workoutId, workoutName: $workoutName, durationMinutes: $durationMinutes, completedAt: $completedAt, exerciseCount: $exerciseCount, totalVolumeKg: $totalVolumeKg)';
}


}

/// @nodoc
abstract mixin class $WorkoutLinkMetadataCopyWith<$Res>  {
  factory $WorkoutLinkMetadataCopyWith(WorkoutLinkMetadata value, $Res Function(WorkoutLinkMetadata) _then) = _$WorkoutLinkMetadataCopyWithImpl;
@useResult
$Res call({
 String workoutId, String workoutName, int durationMinutes, DateTime completedAt, int? exerciseCount, double? totalVolumeKg
});




}
/// @nodoc
class _$WorkoutLinkMetadataCopyWithImpl<$Res>
    implements $WorkoutLinkMetadataCopyWith<$Res> {
  _$WorkoutLinkMetadataCopyWithImpl(this._self, this._then);

  final WorkoutLinkMetadata _self;
  final $Res Function(WorkoutLinkMetadata) _then;

/// Create a copy of WorkoutLinkMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutId = null,Object? workoutName = null,Object? durationMinutes = null,Object? completedAt = null,Object? exerciseCount = freezed,Object? totalVolumeKg = freezed,}) {
  return _then(_self.copyWith(
workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,exerciseCount: freezed == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int?,totalVolumeKg: freezed == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutLinkMetadata].
extension WorkoutLinkMetadataPatterns on WorkoutLinkMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutLinkMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutLinkMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutLinkMetadata value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutLinkMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutLinkMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutLinkMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String workoutId,  String workoutName,  int durationMinutes,  DateTime completedAt,  int? exerciseCount,  double? totalVolumeKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutLinkMetadata() when $default != null:
return $default(_that.workoutId,_that.workoutName,_that.durationMinutes,_that.completedAt,_that.exerciseCount,_that.totalVolumeKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String workoutId,  String workoutName,  int durationMinutes,  DateTime completedAt,  int? exerciseCount,  double? totalVolumeKg)  $default,) {final _that = this;
switch (_that) {
case _WorkoutLinkMetadata():
return $default(_that.workoutId,_that.workoutName,_that.durationMinutes,_that.completedAt,_that.exerciseCount,_that.totalVolumeKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String workoutId,  String workoutName,  int durationMinutes,  DateTime completedAt,  int? exerciseCount,  double? totalVolumeKg)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutLinkMetadata() when $default != null:
return $default(_that.workoutId,_that.workoutName,_that.durationMinutes,_that.completedAt,_that.exerciseCount,_that.totalVolumeKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutLinkMetadata implements WorkoutLinkMetadata {
  const _WorkoutLinkMetadata({required this.workoutId, required this.workoutName, required this.durationMinutes, required this.completedAt, this.exerciseCount, this.totalVolumeKg});
  factory _WorkoutLinkMetadata.fromJson(Map<String, dynamic> json) => _$WorkoutLinkMetadataFromJson(json);

@override final  String workoutId;
@override final  String workoutName;
@override final  int durationMinutes;
@override final  DateTime completedAt;
@override final  int? exerciseCount;
@override final  double? totalVolumeKg;

/// Create a copy of WorkoutLinkMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutLinkMetadataCopyWith<_WorkoutLinkMetadata> get copyWith => __$WorkoutLinkMetadataCopyWithImpl<_WorkoutLinkMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutLinkMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutLinkMetadata&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutId,workoutName,durationMinutes,completedAt,exerciseCount,totalVolumeKg);

@override
String toString() {
  return 'WorkoutLinkMetadata(workoutId: $workoutId, workoutName: $workoutName, durationMinutes: $durationMinutes, completedAt: $completedAt, exerciseCount: $exerciseCount, totalVolumeKg: $totalVolumeKg)';
}


}

/// @nodoc
abstract mixin class _$WorkoutLinkMetadataCopyWith<$Res> implements $WorkoutLinkMetadataCopyWith<$Res> {
  factory _$WorkoutLinkMetadataCopyWith(_WorkoutLinkMetadata value, $Res Function(_WorkoutLinkMetadata) _then) = __$WorkoutLinkMetadataCopyWithImpl;
@override @useResult
$Res call({
 String workoutId, String workoutName, int durationMinutes, DateTime completedAt, int? exerciseCount, double? totalVolumeKg
});




}
/// @nodoc
class __$WorkoutLinkMetadataCopyWithImpl<$Res>
    implements _$WorkoutLinkMetadataCopyWith<$Res> {
  __$WorkoutLinkMetadataCopyWithImpl(this._self, this._then);

  final _WorkoutLinkMetadata _self;
  final $Res Function(_WorkoutLinkMetadata) _then;

/// Create a copy of WorkoutLinkMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutId = null,Object? workoutName = null,Object? durationMinutes = null,Object? completedAt = null,Object? exerciseCount = freezed,Object? totalVolumeKg = freezed,}) {
  return _then(_WorkoutLinkMetadata(
workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,exerciseCount: freezed == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int?,totalVolumeKg: freezed == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ImageMetadata {

 String get imageUrl; String get thumbnailUrl; String get storagePath; int? get fileSizeBytes; int? get width; int? get height;
/// Create a copy of ImageMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageMetadataCopyWith<ImageMetadata> get copyWith => _$ImageMetadataCopyWithImpl<ImageMetadata>(this as ImageMetadata, _$identity);

  /// Serializes this ImageMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageMetadata&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUrl,thumbnailUrl,storagePath,fileSizeBytes,width,height);

@override
String toString() {
  return 'ImageMetadata(imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, storagePath: $storagePath, fileSizeBytes: $fileSizeBytes, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $ImageMetadataCopyWith<$Res>  {
  factory $ImageMetadataCopyWith(ImageMetadata value, $Res Function(ImageMetadata) _then) = _$ImageMetadataCopyWithImpl;
@useResult
$Res call({
 String imageUrl, String thumbnailUrl, String storagePath, int? fileSizeBytes, int? width, int? height
});




}
/// @nodoc
class _$ImageMetadataCopyWithImpl<$Res>
    implements $ImageMetadataCopyWith<$Res> {
  _$ImageMetadataCopyWithImpl(this._self, this._then);

  final ImageMetadata _self;
  final $Res Function(ImageMetadata) _then;

/// Create a copy of ImageMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageUrl = null,Object? thumbnailUrl = null,Object? storagePath = null,Object? fileSizeBytes = freezed,Object? width = freezed,Object? height = freezed,}) {
  return _then(_self.copyWith(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageMetadata].
extension ImageMetadataPatterns on ImageMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageMetadata value)  $default,){
final _that = this;
switch (_that) {
case _ImageMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _ImageMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageUrl,  String thumbnailUrl,  String storagePath,  int? fileSizeBytes,  int? width,  int? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageMetadata() when $default != null:
return $default(_that.imageUrl,_that.thumbnailUrl,_that.storagePath,_that.fileSizeBytes,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageUrl,  String thumbnailUrl,  String storagePath,  int? fileSizeBytes,  int? width,  int? height)  $default,) {final _that = this;
switch (_that) {
case _ImageMetadata():
return $default(_that.imageUrl,_that.thumbnailUrl,_that.storagePath,_that.fileSizeBytes,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageUrl,  String thumbnailUrl,  String storagePath,  int? fileSizeBytes,  int? width,  int? height)?  $default,) {final _that = this;
switch (_that) {
case _ImageMetadata() when $default != null:
return $default(_that.imageUrl,_that.thumbnailUrl,_that.storagePath,_that.fileSizeBytes,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageMetadata implements ImageMetadata {
  const _ImageMetadata({required this.imageUrl, required this.thumbnailUrl, required this.storagePath, this.fileSizeBytes, this.width, this.height});
  factory _ImageMetadata.fromJson(Map<String, dynamic> json) => _$ImageMetadataFromJson(json);

@override final  String imageUrl;
@override final  String thumbnailUrl;
@override final  String storagePath;
@override final  int? fileSizeBytes;
@override final  int? width;
@override final  int? height;

/// Create a copy of ImageMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageMetadataCopyWith<_ImageMetadata> get copyWith => __$ImageMetadataCopyWithImpl<_ImageMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageMetadata&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,imageUrl,thumbnailUrl,storagePath,fileSizeBytes,width,height);

@override
String toString() {
  return 'ImageMetadata(imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, storagePath: $storagePath, fileSizeBytes: $fileSizeBytes, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$ImageMetadataCopyWith<$Res> implements $ImageMetadataCopyWith<$Res> {
  factory _$ImageMetadataCopyWith(_ImageMetadata value, $Res Function(_ImageMetadata) _then) = __$ImageMetadataCopyWithImpl;
@override @useResult
$Res call({
 String imageUrl, String thumbnailUrl, String storagePath, int? fileSizeBytes, int? width, int? height
});




}
/// @nodoc
class __$ImageMetadataCopyWithImpl<$Res>
    implements _$ImageMetadataCopyWith<$Res> {
  __$ImageMetadataCopyWithImpl(this._self, this._then);

  final _ImageMetadata _self;
  final $Res Function(_ImageMetadata) _then;

/// Create a copy of ImageMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageUrl = null,Object? thumbnailUrl = null,Object? storagePath = null,Object? fileSizeBytes = freezed,Object? width = freezed,Object? height = freezed,}) {
  return _then(_ImageMetadata(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ChatMessage {

/// Unique message ID
 String get id;/// ID of the sender (coach or athlete)
 String get senderId;/// Display name of sender (denormalized for performance)
 String get senderName;/// Message text content
 String get text;/// Type of message
 MessageType get type;/// Workout link metadata (only for workoutLink type)
 WorkoutLinkMetadata? get workoutMetadata;/// Image metadata (only for image type)
 ImageMetadata? get imageMetadata;/// When the message was created
 DateTime get createdAt;/// When the message was read by recipient (null = unread)
 DateTime? get readAt;/// Soft delete flag
 bool get isDeleted;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.workoutMetadata, workoutMetadata) || other.workoutMetadata == workoutMetadata)&&(identical(other.imageMetadata, imageMetadata) || other.imageMetadata == imageMetadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderName,text,type,workoutMetadata,imageMetadata,createdAt,readAt,isDeleted);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, senderName: $senderName, text: $text, type: $type, workoutMetadata: $workoutMetadata, imageMetadata: $imageMetadata, createdAt: $createdAt, readAt: $readAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String senderName, String text, MessageType type, WorkoutLinkMetadata? workoutMetadata, ImageMetadata? imageMetadata, DateTime createdAt, DateTime? readAt, bool isDeleted
});


$WorkoutLinkMetadataCopyWith<$Res>? get workoutMetadata;$ImageMetadataCopyWith<$Res>? get imageMetadata;

}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? senderName = null,Object? text = null,Object? type = null,Object? workoutMetadata = freezed,Object? imageMetadata = freezed,Object? createdAt = null,Object? readAt = freezed,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,workoutMetadata: freezed == workoutMetadata ? _self.workoutMetadata : workoutMetadata // ignore: cast_nullable_to_non_nullable
as WorkoutLinkMetadata?,imageMetadata: freezed == imageMetadata ? _self.imageMetadata : imageMetadata // ignore: cast_nullable_to_non_nullable
as ImageMetadata?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutLinkMetadataCopyWith<$Res>? get workoutMetadata {
    if (_self.workoutMetadata == null) {
    return null;
  }

  return $WorkoutLinkMetadataCopyWith<$Res>(_self.workoutMetadata!, (value) {
    return _then(_self.copyWith(workoutMetadata: value));
  });
}/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageMetadataCopyWith<$Res>? get imageMetadata {
    if (_self.imageMetadata == null) {
    return null;
  }

  return $ImageMetadataCopyWith<$Res>(_self.imageMetadata!, (value) {
    return _then(_self.copyWith(imageMetadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String senderName,  String text,  MessageType type,  WorkoutLinkMetadata? workoutMetadata,  ImageMetadata? imageMetadata,  DateTime createdAt,  DateTime? readAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.text,_that.type,_that.workoutMetadata,_that.imageMetadata,_that.createdAt,_that.readAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String senderName,  String text,  MessageType type,  WorkoutLinkMetadata? workoutMetadata,  ImageMetadata? imageMetadata,  DateTime createdAt,  DateTime? readAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.senderId,_that.senderName,_that.text,_that.type,_that.workoutMetadata,_that.imageMetadata,_that.createdAt,_that.readAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String senderName,  String text,  MessageType type,  WorkoutLinkMetadata? workoutMetadata,  ImageMetadata? imageMetadata,  DateTime createdAt,  DateTime? readAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.text,_that.type,_that.workoutMetadata,_that.imageMetadata,_that.createdAt,_that.readAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage extends ChatMessage {
  const _ChatMessage({required this.id, required this.senderId, required this.senderName, required this.text, this.type = MessageType.text, this.workoutMetadata, this.imageMetadata, required this.createdAt, this.readAt, this.isDeleted = false}): super._();
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

/// Unique message ID
@override final  String id;
/// ID of the sender (coach or athlete)
@override final  String senderId;
/// Display name of sender (denormalized for performance)
@override final  String senderName;
/// Message text content
@override final  String text;
/// Type of message
@override@JsonKey() final  MessageType type;
/// Workout link metadata (only for workoutLink type)
@override final  WorkoutLinkMetadata? workoutMetadata;
/// Image metadata (only for image type)
@override final  ImageMetadata? imageMetadata;
/// When the message was created
@override final  DateTime createdAt;
/// When the message was read by recipient (null = unread)
@override final  DateTime? readAt;
/// Soft delete flag
@override@JsonKey() final  bool isDeleted;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.workoutMetadata, workoutMetadata) || other.workoutMetadata == workoutMetadata)&&(identical(other.imageMetadata, imageMetadata) || other.imageMetadata == imageMetadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderName,text,type,workoutMetadata,imageMetadata,createdAt,readAt,isDeleted);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, senderName: $senderName, text: $text, type: $type, workoutMetadata: $workoutMetadata, imageMetadata: $imageMetadata, createdAt: $createdAt, readAt: $readAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String senderName, String text, MessageType type, WorkoutLinkMetadata? workoutMetadata, ImageMetadata? imageMetadata, DateTime createdAt, DateTime? readAt, bool isDeleted
});


@override $WorkoutLinkMetadataCopyWith<$Res>? get workoutMetadata;@override $ImageMetadataCopyWith<$Res>? get imageMetadata;

}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? senderName = null,Object? text = null,Object? type = null,Object? workoutMetadata = freezed,Object? imageMetadata = freezed,Object? createdAt = null,Object? readAt = freezed,Object? isDeleted = null,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,workoutMetadata: freezed == workoutMetadata ? _self.workoutMetadata : workoutMetadata // ignore: cast_nullable_to_non_nullable
as WorkoutLinkMetadata?,imageMetadata: freezed == imageMetadata ? _self.imageMetadata : imageMetadata // ignore: cast_nullable_to_non_nullable
as ImageMetadata?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutLinkMetadataCopyWith<$Res>? get workoutMetadata {
    if (_self.workoutMetadata == null) {
    return null;
  }

  return $WorkoutLinkMetadataCopyWith<$Res>(_self.workoutMetadata!, (value) {
    return _then(_self.copyWith(workoutMetadata: value));
  });
}/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageMetadataCopyWith<$Res>? get imageMetadata {
    if (_self.imageMetadata == null) {
    return null;
  }

  return $ImageMetadataCopyWith<$Res>(_self.imageMetadata!, (value) {
    return _then(_self.copyWith(imageMetadata: value));
  });
}
}

// dart format on
