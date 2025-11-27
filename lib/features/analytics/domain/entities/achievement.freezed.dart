// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Achievement {

/// Unique achievement identifier
 String get id;/// User who unlocked this achievement
 String get userId;/// Type of badge/achievement
 BadgeType get badgeType;/// When the achievement was unlocked
 DateTime get unlockedAt;/// Evidence/context for the achievement
/// Examples:
/// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
/// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
/// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
 Map<String, dynamic> get evidence;
/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementCopyWith<Achievement> get copyWith => _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.badgeType, badgeType) || other.badgeType == badgeType)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&const DeepCollectionEquality().equals(other.evidence, evidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,badgeType,unlockedAt,const DeepCollectionEquality().hash(evidence));

@override
String toString() {
  return 'Achievement(id: $id, userId: $userId, badgeType: $badgeType, unlockedAt: $unlockedAt, evidence: $evidence)';
}


}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res>  {
  factory $AchievementCopyWith(Achievement value, $Res Function(Achievement) _then) = _$AchievementCopyWithImpl;
@useResult
$Res call({
 String id, String userId, BadgeType badgeType, DateTime unlockedAt, Map<String, dynamic> evidence
});




}
/// @nodoc
class _$AchievementCopyWithImpl<$Res>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? badgeType = null,Object? unlockedAt = null,Object? evidence = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,badgeType: null == badgeType ? _self.badgeType : badgeType // ignore: cast_nullable_to_non_nullable
as BadgeType,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Achievement].
extension AchievementPatterns on Achievement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Achievement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Achievement value)  $default,){
final _that = this;
switch (_that) {
case _Achievement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Achievement value)?  $default,){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  BadgeType badgeType,  DateTime unlockedAt,  Map<String, dynamic> evidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.userId,_that.badgeType,_that.unlockedAt,_that.evidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  BadgeType badgeType,  DateTime unlockedAt,  Map<String, dynamic> evidence)  $default,) {final _that = this;
switch (_that) {
case _Achievement():
return $default(_that.id,_that.userId,_that.badgeType,_that.unlockedAt,_that.evidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  BadgeType badgeType,  DateTime unlockedAt,  Map<String, dynamic> evidence)?  $default,) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.userId,_that.badgeType,_that.unlockedAt,_that.evidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Achievement implements Achievement {
  const _Achievement({required this.id, required this.userId, required this.badgeType, required this.unlockedAt, required final  Map<String, dynamic> evidence}): _evidence = evidence;
  factory _Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

/// Unique achievement identifier
@override final  String id;
/// User who unlocked this achievement
@override final  String userId;
/// Type of badge/achievement
@override final  BadgeType badgeType;
/// When the achievement was unlocked
@override final  DateTime unlockedAt;
/// Evidence/context for the achievement
/// Examples:
/// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
/// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
/// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
 final  Map<String, dynamic> _evidence;
/// Evidence/context for the achievement
/// Examples:
/// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
/// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
/// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
@override Map<String, dynamic> get evidence {
  if (_evidence is EqualUnmodifiableMapView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_evidence);
}


/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementCopyWith<_Achievement> get copyWith => __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.badgeType, badgeType) || other.badgeType == badgeType)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&const DeepCollectionEquality().equals(other._evidence, _evidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,badgeType,unlockedAt,const DeepCollectionEquality().hash(_evidence));

@override
String toString() {
  return 'Achievement(id: $id, userId: $userId, badgeType: $badgeType, unlockedAt: $unlockedAt, evidence: $evidence)';
}


}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res> implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(_Achievement value, $Res Function(_Achievement) _then) = __$AchievementCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, BadgeType badgeType, DateTime unlockedAt, Map<String, dynamic> evidence
});




}
/// @nodoc
class __$AchievementCopyWithImpl<$Res>
    implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? badgeType = null,Object? unlockedAt = null,Object? evidence = null,}) {
  return _then(_Achievement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,badgeType: null == badgeType ? _self.badgeType : badgeType // ignore: cast_nullable_to_non_nullable
as BadgeType,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
