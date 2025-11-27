// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserGoal {

 GoalType get goalType; int get weeklyWorkoutTarget; ExperienceLevel get experienceLevel;
/// Create a copy of UserGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserGoalCopyWith<UserGoal> get copyWith => _$UserGoalCopyWithImpl<UserGoal>(this as UserGoal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserGoal&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.weeklyWorkoutTarget, weeklyWorkoutTarget) || other.weeklyWorkoutTarget == weeklyWorkoutTarget)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel));
}


@override
int get hashCode => Object.hash(runtimeType,goalType,weeklyWorkoutTarget,experienceLevel);

@override
String toString() {
  return 'UserGoal(goalType: $goalType, weeklyWorkoutTarget: $weeklyWorkoutTarget, experienceLevel: $experienceLevel)';
}


}

/// @nodoc
abstract mixin class $UserGoalCopyWith<$Res>  {
  factory $UserGoalCopyWith(UserGoal value, $Res Function(UserGoal) _then) = _$UserGoalCopyWithImpl;
@useResult
$Res call({
 GoalType goalType, int weeklyWorkoutTarget, ExperienceLevel experienceLevel
});




}
/// @nodoc
class _$UserGoalCopyWithImpl<$Res>
    implements $UserGoalCopyWith<$Res> {
  _$UserGoalCopyWithImpl(this._self, this._then);

  final UserGoal _self;
  final $Res Function(UserGoal) _then;

/// Create a copy of UserGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goalType = null,Object? weeklyWorkoutTarget = null,Object? experienceLevel = null,}) {
  return _then(_self.copyWith(
goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as GoalType,weeklyWorkoutTarget: null == weeklyWorkoutTarget ? _self.weeklyWorkoutTarget : weeklyWorkoutTarget // ignore: cast_nullable_to_non_nullable
as int,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,
  ));
}

}


/// Adds pattern-matching-related methods to [UserGoal].
extension UserGoalPatterns on UserGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserGoal value)  $default,){
final _that = this;
switch (_that) {
case _UserGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserGoal value)?  $default,){
final _that = this;
switch (_that) {
case _UserGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GoalType goalType,  int weeklyWorkoutTarget,  ExperienceLevel experienceLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserGoal() when $default != null:
return $default(_that.goalType,_that.weeklyWorkoutTarget,_that.experienceLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GoalType goalType,  int weeklyWorkoutTarget,  ExperienceLevel experienceLevel)  $default,) {final _that = this;
switch (_that) {
case _UserGoal():
return $default(_that.goalType,_that.weeklyWorkoutTarget,_that.experienceLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GoalType goalType,  int weeklyWorkoutTarget,  ExperienceLevel experienceLevel)?  $default,) {final _that = this;
switch (_that) {
case _UserGoal() when $default != null:
return $default(_that.goalType,_that.weeklyWorkoutTarget,_that.experienceLevel);case _:
  return null;

}
}

}

/// @nodoc


class _UserGoal implements UserGoal {
  const _UserGoal({required this.goalType, required this.weeklyWorkoutTarget, required this.experienceLevel});
  

@override final  GoalType goalType;
@override final  int weeklyWorkoutTarget;
@override final  ExperienceLevel experienceLevel;

/// Create a copy of UserGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserGoalCopyWith<_UserGoal> get copyWith => __$UserGoalCopyWithImpl<_UserGoal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserGoal&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.weeklyWorkoutTarget, weeklyWorkoutTarget) || other.weeklyWorkoutTarget == weeklyWorkoutTarget)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel));
}


@override
int get hashCode => Object.hash(runtimeType,goalType,weeklyWorkoutTarget,experienceLevel);

@override
String toString() {
  return 'UserGoal(goalType: $goalType, weeklyWorkoutTarget: $weeklyWorkoutTarget, experienceLevel: $experienceLevel)';
}


}

/// @nodoc
abstract mixin class _$UserGoalCopyWith<$Res> implements $UserGoalCopyWith<$Res> {
  factory _$UserGoalCopyWith(_UserGoal value, $Res Function(_UserGoal) _then) = __$UserGoalCopyWithImpl;
@override @useResult
$Res call({
 GoalType goalType, int weeklyWorkoutTarget, ExperienceLevel experienceLevel
});




}
/// @nodoc
class __$UserGoalCopyWithImpl<$Res>
    implements _$UserGoalCopyWith<$Res> {
  __$UserGoalCopyWithImpl(this._self, this._then);

  final _UserGoal _self;
  final $Res Function(_UserGoal) _then;

/// Create a copy of UserGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goalType = null,Object? weeklyWorkoutTarget = null,Object? experienceLevel = null,}) {
  return _then(_UserGoal(
goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as GoalType,weeklyWorkoutTarget: null == weeklyWorkoutTarget ? _self.weeklyWorkoutTarget : weeklyWorkoutTarget // ignore: cast_nullable_to_non_nullable
as int,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,
  ));
}


}

// dart format on
