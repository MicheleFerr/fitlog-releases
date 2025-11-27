// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UnifiedFeedback {

/// Unique feedback ID (Firestore document ID)
 String get id;/// User who submitted feedback (Firebase Auth UID)
 String get userId;/// Type of feedback (discriminator)
 UnifiedFeedbackType get type;/// Current status in review workflow
 UnifiedFeedbackStatus get status;/// Severity level (for prioritization)
 FeedbackSeverity get severity;/// Main feedback message/description
 String get message;/// When feedback was submitted
 DateTime get createdAt;/// Last update timestamp (status change, admin note, etc.)
 DateTime? get updatedAt;/// When feedback was marked resolved/dismissed (if applicable)
 DateTime? get resolvedAt;// ========================================
// ADMIN REVIEW FIELDS
// ========================================
/// Admin user ID who reviewed this feedback
 String? get reviewedBy;/// Admin notes/comments (visible to user if status is resolved)
 String? get adminNotes;// ========================================
// TYPE-SPECIFIC METADATA
// ========================================
/// Type-specific data stored as Map
///
/// **Exercise Feedback**:
/// - exerciseId: String
/// - exerciseName: String
/// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
/// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
///
/// **AI Insight Feedback**:
/// - insightId: String
/// - insightType: String (e.g., "overtraining", "progression")
/// - insightCategory: String (e.g., "recovery", "performance")
/// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
/// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
/// - viewDurationSeconds: int (time insight was visible before feedback)
///
/// **Analytics Feedback**:
/// - isHelpful: bool (true = 👍, false = 👎)
/// - lastViewedSection: String? (overview/progress/insights/routine)
/// - totalWorkoutsViewed: int? (user engagement metric)
///
/// **Buddy Report**:
/// - targetUserId: String (reported user ID)
/// - targetUserName: String (reported user display name)
/// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
///
/// **General Feedback**:
/// - category: String (bug/feature/improvement/praise/other)
/// - rating: int? (1-5 stars, optional)
/// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
/// - appVersion: String? (e.g., "1.2.3")
/// - screenshotUrl: String? (Firebase Storage URL, future)
 Map<String, dynamic> get metadata;// ========================================
// USER INFO (OPTIONAL - FOR ADMIN)
// ========================================
/// User email (for admin contact)
 String? get userEmail;/// User display name (for admin reference)
 String? get userDisplayName;
/// Create a copy of UnifiedFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnifiedFeedbackCopyWith<UnifiedFeedback> get copyWith => _$UnifiedFeedbackCopyWithImpl<UnifiedFeedback>(this as UnifiedFeedback, _$identity);

  /// Serializes this UnifiedFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnifiedFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,status,severity,message,createdAt,updatedAt,resolvedAt,reviewedBy,adminNotes,const DeepCollectionEquality().hash(metadata),userEmail,userDisplayName);

@override
String toString() {
  return 'UnifiedFeedback(id: $id, userId: $userId, type: $type, status: $status, severity: $severity, message: $message, createdAt: $createdAt, updatedAt: $updatedAt, resolvedAt: $resolvedAt, reviewedBy: $reviewedBy, adminNotes: $adminNotes, metadata: $metadata, userEmail: $userEmail, userDisplayName: $userDisplayName)';
}


}

/// @nodoc
abstract mixin class $UnifiedFeedbackCopyWith<$Res>  {
  factory $UnifiedFeedbackCopyWith(UnifiedFeedback value, $Res Function(UnifiedFeedback) _then) = _$UnifiedFeedbackCopyWithImpl;
@useResult
$Res call({
 String id, String userId, UnifiedFeedbackType type, UnifiedFeedbackStatus status, FeedbackSeverity severity, String message, DateTime createdAt, DateTime? updatedAt, DateTime? resolvedAt, String? reviewedBy, String? adminNotes, Map<String, dynamic> metadata, String? userEmail, String? userDisplayName
});




}
/// @nodoc
class _$UnifiedFeedbackCopyWithImpl<$Res>
    implements $UnifiedFeedbackCopyWith<$Res> {
  _$UnifiedFeedbackCopyWithImpl(this._self, this._then);

  final UnifiedFeedback _self;
  final $Res Function(UnifiedFeedback) _then;

/// Create a copy of UnifiedFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? status = null,Object? severity = null,Object? message = null,Object? createdAt = null,Object? updatedAt = freezed,Object? resolvedAt = freezed,Object? reviewedBy = freezed,Object? adminNotes = freezed,Object? metadata = null,Object? userEmail = freezed,Object? userDisplayName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UnifiedFeedbackType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UnifiedFeedbackStatus,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FeedbackSeverity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UnifiedFeedback].
extension UnifiedFeedbackPatterns on UnifiedFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnifiedFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnifiedFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnifiedFeedback value)  $default,){
final _that = this;
switch (_that) {
case _UnifiedFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnifiedFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _UnifiedFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  UnifiedFeedbackType type,  UnifiedFeedbackStatus status,  FeedbackSeverity severity,  String message,  DateTime createdAt,  DateTime? updatedAt,  DateTime? resolvedAt,  String? reviewedBy,  String? adminNotes,  Map<String, dynamic> metadata,  String? userEmail,  String? userDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnifiedFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.status,_that.severity,_that.message,_that.createdAt,_that.updatedAt,_that.resolvedAt,_that.reviewedBy,_that.adminNotes,_that.metadata,_that.userEmail,_that.userDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  UnifiedFeedbackType type,  UnifiedFeedbackStatus status,  FeedbackSeverity severity,  String message,  DateTime createdAt,  DateTime? updatedAt,  DateTime? resolvedAt,  String? reviewedBy,  String? adminNotes,  Map<String, dynamic> metadata,  String? userEmail,  String? userDisplayName)  $default,) {final _that = this;
switch (_that) {
case _UnifiedFeedback():
return $default(_that.id,_that.userId,_that.type,_that.status,_that.severity,_that.message,_that.createdAt,_that.updatedAt,_that.resolvedAt,_that.reviewedBy,_that.adminNotes,_that.metadata,_that.userEmail,_that.userDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  UnifiedFeedbackType type,  UnifiedFeedbackStatus status,  FeedbackSeverity severity,  String message,  DateTime createdAt,  DateTime? updatedAt,  DateTime? resolvedAt,  String? reviewedBy,  String? adminNotes,  Map<String, dynamic> metadata,  String? userEmail,  String? userDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _UnifiedFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.status,_that.severity,_that.message,_that.createdAt,_that.updatedAt,_that.resolvedAt,_that.reviewedBy,_that.adminNotes,_that.metadata,_that.userEmail,_that.userDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnifiedFeedback implements UnifiedFeedback {
  const _UnifiedFeedback({required this.id, required this.userId, required this.type, required this.status, required this.severity, required this.message, required this.createdAt, this.updatedAt, this.resolvedAt, this.reviewedBy, this.adminNotes, final  Map<String, dynamic> metadata = const {}, this.userEmail, this.userDisplayName}): _metadata = metadata;
  factory _UnifiedFeedback.fromJson(Map<String, dynamic> json) => _$UnifiedFeedbackFromJson(json);

/// Unique feedback ID (Firestore document ID)
@override final  String id;
/// User who submitted feedback (Firebase Auth UID)
@override final  String userId;
/// Type of feedback (discriminator)
@override final  UnifiedFeedbackType type;
/// Current status in review workflow
@override final  UnifiedFeedbackStatus status;
/// Severity level (for prioritization)
@override final  FeedbackSeverity severity;
/// Main feedback message/description
@override final  String message;
/// When feedback was submitted
@override final  DateTime createdAt;
/// Last update timestamp (status change, admin note, etc.)
@override final  DateTime? updatedAt;
/// When feedback was marked resolved/dismissed (if applicable)
@override final  DateTime? resolvedAt;
// ========================================
// ADMIN REVIEW FIELDS
// ========================================
/// Admin user ID who reviewed this feedback
@override final  String? reviewedBy;
/// Admin notes/comments (visible to user if status is resolved)
@override final  String? adminNotes;
// ========================================
// TYPE-SPECIFIC METADATA
// ========================================
/// Type-specific data stored as Map
///
/// **Exercise Feedback**:
/// - exerciseId: String
/// - exerciseName: String
/// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
/// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
///
/// **AI Insight Feedback**:
/// - insightId: String
/// - insightType: String (e.g., "overtraining", "progression")
/// - insightCategory: String (e.g., "recovery", "performance")
/// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
/// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
/// - viewDurationSeconds: int (time insight was visible before feedback)
///
/// **Analytics Feedback**:
/// - isHelpful: bool (true = 👍, false = 👎)
/// - lastViewedSection: String? (overview/progress/insights/routine)
/// - totalWorkoutsViewed: int? (user engagement metric)
///
/// **Buddy Report**:
/// - targetUserId: String (reported user ID)
/// - targetUserName: String (reported user display name)
/// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
///
/// **General Feedback**:
/// - category: String (bug/feature/improvement/praise/other)
/// - rating: int? (1-5 stars, optional)
/// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
/// - appVersion: String? (e.g., "1.2.3")
/// - screenshotUrl: String? (Firebase Storage URL, future)
 final  Map<String, dynamic> _metadata;
// ========================================
// TYPE-SPECIFIC METADATA
// ========================================
/// Type-specific data stored as Map
///
/// **Exercise Feedback**:
/// - exerciseId: String
/// - exerciseName: String
/// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
/// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
///
/// **AI Insight Feedback**:
/// - insightId: String
/// - insightType: String (e.g., "overtraining", "progression")
/// - insightCategory: String (e.g., "recovery", "performance")
/// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
/// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
/// - viewDurationSeconds: int (time insight was visible before feedback)
///
/// **Analytics Feedback**:
/// - isHelpful: bool (true = 👍, false = 👎)
/// - lastViewedSection: String? (overview/progress/insights/routine)
/// - totalWorkoutsViewed: int? (user engagement metric)
///
/// **Buddy Report**:
/// - targetUserId: String (reported user ID)
/// - targetUserName: String (reported user display name)
/// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
///
/// **General Feedback**:
/// - category: String (bug/feature/improvement/praise/other)
/// - rating: int? (1-5 stars, optional)
/// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
/// - appVersion: String? (e.g., "1.2.3")
/// - screenshotUrl: String? (Firebase Storage URL, future)
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

// ========================================
// USER INFO (OPTIONAL - FOR ADMIN)
// ========================================
/// User email (for admin contact)
@override final  String? userEmail;
/// User display name (for admin reference)
@override final  String? userDisplayName;

/// Create a copy of UnifiedFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnifiedFeedbackCopyWith<_UnifiedFeedback> get copyWith => __$UnifiedFeedbackCopyWithImpl<_UnifiedFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnifiedFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnifiedFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,status,severity,message,createdAt,updatedAt,resolvedAt,reviewedBy,adminNotes,const DeepCollectionEquality().hash(_metadata),userEmail,userDisplayName);

@override
String toString() {
  return 'UnifiedFeedback(id: $id, userId: $userId, type: $type, status: $status, severity: $severity, message: $message, createdAt: $createdAt, updatedAt: $updatedAt, resolvedAt: $resolvedAt, reviewedBy: $reviewedBy, adminNotes: $adminNotes, metadata: $metadata, userEmail: $userEmail, userDisplayName: $userDisplayName)';
}


}

/// @nodoc
abstract mixin class _$UnifiedFeedbackCopyWith<$Res> implements $UnifiedFeedbackCopyWith<$Res> {
  factory _$UnifiedFeedbackCopyWith(_UnifiedFeedback value, $Res Function(_UnifiedFeedback) _then) = __$UnifiedFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, UnifiedFeedbackType type, UnifiedFeedbackStatus status, FeedbackSeverity severity, String message, DateTime createdAt, DateTime? updatedAt, DateTime? resolvedAt, String? reviewedBy, String? adminNotes, Map<String, dynamic> metadata, String? userEmail, String? userDisplayName
});




}
/// @nodoc
class __$UnifiedFeedbackCopyWithImpl<$Res>
    implements _$UnifiedFeedbackCopyWith<$Res> {
  __$UnifiedFeedbackCopyWithImpl(this._self, this._then);

  final _UnifiedFeedback _self;
  final $Res Function(_UnifiedFeedback) _then;

/// Create a copy of UnifiedFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? status = null,Object? severity = null,Object? message = null,Object? createdAt = null,Object? updatedAt = freezed,Object? resolvedAt = freezed,Object? reviewedBy = freezed,Object? adminNotes = freezed,Object? metadata = null,Object? userEmail = freezed,Object? userDisplayName = freezed,}) {
  return _then(_UnifiedFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UnifiedFeedbackType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UnifiedFeedbackStatus,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FeedbackSeverity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
