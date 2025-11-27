// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserFeedback {

 String get id; String get userId; String get message; FeedbackCategory get category; FeedbackStatus get status; DateTime get createdAt; int? get rating;// 1-5 stars (optional)
 String? get userEmail; String? get userDisplayName; String? get deviceInfo; String? get appVersion; String? get screenshotUrl;// Firebase Storage URL (future)
 DateTime? get reviewedAt; String? get reviewedBy;// Admin user ID
 String? get adminNotes;
/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFeedbackCopyWith<UserFeedback> get copyWith => _$UserFeedbackCopyWithImpl<UserFeedback>(this as UserFeedback, _$identity);

  /// Serializes this UserFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.message, message) || other.message == message)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.screenshotUrl, screenshotUrl) || other.screenshotUrl == screenshotUrl)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,message,category,status,createdAt,rating,userEmail,userDisplayName,deviceInfo,appVersion,screenshotUrl,reviewedAt,reviewedBy,adminNotes);

@override
String toString() {
  return 'UserFeedback(id: $id, userId: $userId, message: $message, category: $category, status: $status, createdAt: $createdAt, rating: $rating, userEmail: $userEmail, userDisplayName: $userDisplayName, deviceInfo: $deviceInfo, appVersion: $appVersion, screenshotUrl: $screenshotUrl, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, adminNotes: $adminNotes)';
}


}

/// @nodoc
abstract mixin class $UserFeedbackCopyWith<$Res>  {
  factory $UserFeedbackCopyWith(UserFeedback value, $Res Function(UserFeedback) _then) = _$UserFeedbackCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String message, FeedbackCategory category, FeedbackStatus status, DateTime createdAt, int? rating, String? userEmail, String? userDisplayName, String? deviceInfo, String? appVersion, String? screenshotUrl, DateTime? reviewedAt, String? reviewedBy, String? adminNotes
});




}
/// @nodoc
class _$UserFeedbackCopyWithImpl<$Res>
    implements $UserFeedbackCopyWith<$Res> {
  _$UserFeedbackCopyWithImpl(this._self, this._then);

  final UserFeedback _self;
  final $Res Function(UserFeedback) _then;

/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? message = null,Object? category = null,Object? status = null,Object? createdAt = null,Object? rating = freezed,Object? userEmail = freezed,Object? userDisplayName = freezed,Object? deviceInfo = freezed,Object? appVersion = freezed,Object? screenshotUrl = freezed,Object? reviewedAt = freezed,Object? reviewedBy = freezed,Object? adminNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FeedbackCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeedbackStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,screenshotUrl: freezed == screenshotUrl ? _self.screenshotUrl : screenshotUrl // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFeedback].
extension UserFeedbackPatterns on UserFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFeedback value)  $default,){
final _that = this;
switch (_that) {
case _UserFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String message,  FeedbackCategory category,  FeedbackStatus status,  DateTime createdAt,  int? rating,  String? userEmail,  String? userDisplayName,  String? deviceInfo,  String? appVersion,  String? screenshotUrl,  DateTime? reviewedAt,  String? reviewedBy,  String? adminNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.message,_that.category,_that.status,_that.createdAt,_that.rating,_that.userEmail,_that.userDisplayName,_that.deviceInfo,_that.appVersion,_that.screenshotUrl,_that.reviewedAt,_that.reviewedBy,_that.adminNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String message,  FeedbackCategory category,  FeedbackStatus status,  DateTime createdAt,  int? rating,  String? userEmail,  String? userDisplayName,  String? deviceInfo,  String? appVersion,  String? screenshotUrl,  DateTime? reviewedAt,  String? reviewedBy,  String? adminNotes)  $default,) {final _that = this;
switch (_that) {
case _UserFeedback():
return $default(_that.id,_that.userId,_that.message,_that.category,_that.status,_that.createdAt,_that.rating,_that.userEmail,_that.userDisplayName,_that.deviceInfo,_that.appVersion,_that.screenshotUrl,_that.reviewedAt,_that.reviewedBy,_that.adminNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String message,  FeedbackCategory category,  FeedbackStatus status,  DateTime createdAt,  int? rating,  String? userEmail,  String? userDisplayName,  String? deviceInfo,  String? appVersion,  String? screenshotUrl,  DateTime? reviewedAt,  String? reviewedBy,  String? adminNotes)?  $default,) {final _that = this;
switch (_that) {
case _UserFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.message,_that.category,_that.status,_that.createdAt,_that.rating,_that.userEmail,_that.userDisplayName,_that.deviceInfo,_that.appVersion,_that.screenshotUrl,_that.reviewedAt,_that.reviewedBy,_that.adminNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserFeedback implements UserFeedback {
  const _UserFeedback({required this.id, required this.userId, required this.message, required this.category, required this.status, required this.createdAt, this.rating, this.userEmail, this.userDisplayName, this.deviceInfo, this.appVersion, this.screenshotUrl, this.reviewedAt, this.reviewedBy, this.adminNotes});
  factory _UserFeedback.fromJson(Map<String, dynamic> json) => _$UserFeedbackFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String message;
@override final  FeedbackCategory category;
@override final  FeedbackStatus status;
@override final  DateTime createdAt;
@override final  int? rating;
// 1-5 stars (optional)
@override final  String? userEmail;
@override final  String? userDisplayName;
@override final  String? deviceInfo;
@override final  String? appVersion;
@override final  String? screenshotUrl;
// Firebase Storage URL (future)
@override final  DateTime? reviewedAt;
@override final  String? reviewedBy;
// Admin user ID
@override final  String? adminNotes;

/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFeedbackCopyWith<_UserFeedback> get copyWith => __$UserFeedbackCopyWithImpl<_UserFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.message, message) || other.message == message)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.screenshotUrl, screenshotUrl) || other.screenshotUrl == screenshotUrl)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,message,category,status,createdAt,rating,userEmail,userDisplayName,deviceInfo,appVersion,screenshotUrl,reviewedAt,reviewedBy,adminNotes);

@override
String toString() {
  return 'UserFeedback(id: $id, userId: $userId, message: $message, category: $category, status: $status, createdAt: $createdAt, rating: $rating, userEmail: $userEmail, userDisplayName: $userDisplayName, deviceInfo: $deviceInfo, appVersion: $appVersion, screenshotUrl: $screenshotUrl, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, adminNotes: $adminNotes)';
}


}

/// @nodoc
abstract mixin class _$UserFeedbackCopyWith<$Res> implements $UserFeedbackCopyWith<$Res> {
  factory _$UserFeedbackCopyWith(_UserFeedback value, $Res Function(_UserFeedback) _then) = __$UserFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String message, FeedbackCategory category, FeedbackStatus status, DateTime createdAt, int? rating, String? userEmail, String? userDisplayName, String? deviceInfo, String? appVersion, String? screenshotUrl, DateTime? reviewedAt, String? reviewedBy, String? adminNotes
});




}
/// @nodoc
class __$UserFeedbackCopyWithImpl<$Res>
    implements _$UserFeedbackCopyWith<$Res> {
  __$UserFeedbackCopyWithImpl(this._self, this._then);

  final _UserFeedback _self;
  final $Res Function(_UserFeedback) _then;

/// Create a copy of UserFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? message = null,Object? category = null,Object? status = null,Object? createdAt = null,Object? rating = freezed,Object? userEmail = freezed,Object? userDisplayName = freezed,Object? deviceInfo = freezed,Object? appVersion = freezed,Object? screenshotUrl = freezed,Object? reviewedAt = freezed,Object? reviewedBy = freezed,Object? adminNotes = freezed,}) {
  return _then(_UserFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FeedbackCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeedbackStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,screenshotUrl: freezed == screenshotUrl ? _self.screenshotUrl : screenshotUrl // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
