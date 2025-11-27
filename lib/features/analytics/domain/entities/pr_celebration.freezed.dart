// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pr_celebration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PRCelebration {

/// Unique celebration identifier
 String get id;/// User who achieved the PR
 String get userId;/// Personal record identifier
 String get prId;/// Type of personal record achieved
 PRType get prType;/// When the celebration was triggered
 DateTime get celebratedAt;/// How the user engaged with the celebration
 CelebrationEngagement get engagement;/// Previous personal record value
 double get previousValue;/// New personal record value
 double get newValue;/// Exercise name (optional for context)
 String? get exerciseName;/// Whether a push notification was sent
 bool get notificationSent;/// When the notification was sent (if applicable)
 DateTime? get notificationSentAt;
/// Create a copy of PRCelebration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PRCelebrationCopyWith<PRCelebration> get copyWith => _$PRCelebrationCopyWithImpl<PRCelebration>(this as PRCelebration, _$identity);

  /// Serializes this PRCelebration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PRCelebration&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.prId, prId) || other.prId == prId)&&(identical(other.prType, prType) || other.prType == prType)&&(identical(other.celebratedAt, celebratedAt) || other.celebratedAt == celebratedAt)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.notificationSent, notificationSent) || other.notificationSent == notificationSent)&&(identical(other.notificationSentAt, notificationSentAt) || other.notificationSentAt == notificationSentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,prId,prType,celebratedAt,engagement,previousValue,newValue,exerciseName,notificationSent,notificationSentAt);

@override
String toString() {
  return 'PRCelebration(id: $id, userId: $userId, prId: $prId, prType: $prType, celebratedAt: $celebratedAt, engagement: $engagement, previousValue: $previousValue, newValue: $newValue, exerciseName: $exerciseName, notificationSent: $notificationSent, notificationSentAt: $notificationSentAt)';
}


}

/// @nodoc
abstract mixin class $PRCelebrationCopyWith<$Res>  {
  factory $PRCelebrationCopyWith(PRCelebration value, $Res Function(PRCelebration) _then) = _$PRCelebrationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String prId, PRType prType, DateTime celebratedAt, CelebrationEngagement engagement, double previousValue, double newValue, String? exerciseName, bool notificationSent, DateTime? notificationSentAt
});




}
/// @nodoc
class _$PRCelebrationCopyWithImpl<$Res>
    implements $PRCelebrationCopyWith<$Res> {
  _$PRCelebrationCopyWithImpl(this._self, this._then);

  final PRCelebration _self;
  final $Res Function(PRCelebration) _then;

/// Create a copy of PRCelebration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? prId = null,Object? prType = null,Object? celebratedAt = null,Object? engagement = null,Object? previousValue = null,Object? newValue = null,Object? exerciseName = freezed,Object? notificationSent = null,Object? notificationSentAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,prId: null == prId ? _self.prId : prId // ignore: cast_nullable_to_non_nullable
as String,prType: null == prType ? _self.prType : prType // ignore: cast_nullable_to_non_nullable
as PRType,celebratedAt: null == celebratedAt ? _self.celebratedAt : celebratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,engagement: null == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as CelebrationEngagement,previousValue: null == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as double,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,notificationSent: null == notificationSent ? _self.notificationSent : notificationSent // ignore: cast_nullable_to_non_nullable
as bool,notificationSentAt: freezed == notificationSentAt ? _self.notificationSentAt : notificationSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PRCelebration].
extension PRCelebrationPatterns on PRCelebration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PRCelebration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PRCelebration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PRCelebration value)  $default,){
final _that = this;
switch (_that) {
case _PRCelebration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PRCelebration value)?  $default,){
final _that = this;
switch (_that) {
case _PRCelebration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String prId,  PRType prType,  DateTime celebratedAt,  CelebrationEngagement engagement,  double previousValue,  double newValue,  String? exerciseName,  bool notificationSent,  DateTime? notificationSentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PRCelebration() when $default != null:
return $default(_that.id,_that.userId,_that.prId,_that.prType,_that.celebratedAt,_that.engagement,_that.previousValue,_that.newValue,_that.exerciseName,_that.notificationSent,_that.notificationSentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String prId,  PRType prType,  DateTime celebratedAt,  CelebrationEngagement engagement,  double previousValue,  double newValue,  String? exerciseName,  bool notificationSent,  DateTime? notificationSentAt)  $default,) {final _that = this;
switch (_that) {
case _PRCelebration():
return $default(_that.id,_that.userId,_that.prId,_that.prType,_that.celebratedAt,_that.engagement,_that.previousValue,_that.newValue,_that.exerciseName,_that.notificationSent,_that.notificationSentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String prId,  PRType prType,  DateTime celebratedAt,  CelebrationEngagement engagement,  double previousValue,  double newValue,  String? exerciseName,  bool notificationSent,  DateTime? notificationSentAt)?  $default,) {final _that = this;
switch (_that) {
case _PRCelebration() when $default != null:
return $default(_that.id,_that.userId,_that.prId,_that.prType,_that.celebratedAt,_that.engagement,_that.previousValue,_that.newValue,_that.exerciseName,_that.notificationSent,_that.notificationSentAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PRCelebration implements PRCelebration {
  const _PRCelebration({required this.id, required this.userId, required this.prId, required this.prType, required this.celebratedAt, required this.engagement, required this.previousValue, required this.newValue, this.exerciseName, this.notificationSent = false, this.notificationSentAt});
  factory _PRCelebration.fromJson(Map<String, dynamic> json) => _$PRCelebrationFromJson(json);

/// Unique celebration identifier
@override final  String id;
/// User who achieved the PR
@override final  String userId;
/// Personal record identifier
@override final  String prId;
/// Type of personal record achieved
@override final  PRType prType;
/// When the celebration was triggered
@override final  DateTime celebratedAt;
/// How the user engaged with the celebration
@override final  CelebrationEngagement engagement;
/// Previous personal record value
@override final  double previousValue;
/// New personal record value
@override final  double newValue;
/// Exercise name (optional for context)
@override final  String? exerciseName;
/// Whether a push notification was sent
@override@JsonKey() final  bool notificationSent;
/// When the notification was sent (if applicable)
@override final  DateTime? notificationSentAt;

/// Create a copy of PRCelebration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PRCelebrationCopyWith<_PRCelebration> get copyWith => __$PRCelebrationCopyWithImpl<_PRCelebration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PRCelebrationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PRCelebration&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.prId, prId) || other.prId == prId)&&(identical(other.prType, prType) || other.prType == prType)&&(identical(other.celebratedAt, celebratedAt) || other.celebratedAt == celebratedAt)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.notificationSent, notificationSent) || other.notificationSent == notificationSent)&&(identical(other.notificationSentAt, notificationSentAt) || other.notificationSentAt == notificationSentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,prId,prType,celebratedAt,engagement,previousValue,newValue,exerciseName,notificationSent,notificationSentAt);

@override
String toString() {
  return 'PRCelebration(id: $id, userId: $userId, prId: $prId, prType: $prType, celebratedAt: $celebratedAt, engagement: $engagement, previousValue: $previousValue, newValue: $newValue, exerciseName: $exerciseName, notificationSent: $notificationSent, notificationSentAt: $notificationSentAt)';
}


}

/// @nodoc
abstract mixin class _$PRCelebrationCopyWith<$Res> implements $PRCelebrationCopyWith<$Res> {
  factory _$PRCelebrationCopyWith(_PRCelebration value, $Res Function(_PRCelebration) _then) = __$PRCelebrationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String prId, PRType prType, DateTime celebratedAt, CelebrationEngagement engagement, double previousValue, double newValue, String? exerciseName, bool notificationSent, DateTime? notificationSentAt
});




}
/// @nodoc
class __$PRCelebrationCopyWithImpl<$Res>
    implements _$PRCelebrationCopyWith<$Res> {
  __$PRCelebrationCopyWithImpl(this._self, this._then);

  final _PRCelebration _self;
  final $Res Function(_PRCelebration) _then;

/// Create a copy of PRCelebration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? prId = null,Object? prType = null,Object? celebratedAt = null,Object? engagement = null,Object? previousValue = null,Object? newValue = null,Object? exerciseName = freezed,Object? notificationSent = null,Object? notificationSentAt = freezed,}) {
  return _then(_PRCelebration(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,prId: null == prId ? _self.prId : prId // ignore: cast_nullable_to_non_nullable
as String,prType: null == prType ? _self.prType : prType // ignore: cast_nullable_to_non_nullable
as PRType,celebratedAt: null == celebratedAt ? _self.celebratedAt : celebratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,engagement: null == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as CelebrationEngagement,previousValue: null == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as double,exerciseName: freezed == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String?,notificationSent: null == notificationSent ? _self.notificationSent : notificationSent // ignore: cast_nullable_to_non_nullable
as bool,notificationSentAt: freezed == notificationSentAt ? _self.notificationSentAt : notificationSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
