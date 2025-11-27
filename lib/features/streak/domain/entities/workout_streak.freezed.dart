// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_streak.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkoutStreak {

 int get currentStreak; int get longestStreak; bool get isActive; DateTime? get lastWorkoutDate; int get totalWorkoutDays;
/// Create a copy of WorkoutStreak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutStreakCopyWith<WorkoutStreak> get copyWith => _$WorkoutStreakCopyWithImpl<WorkoutStreak>(this as WorkoutStreak, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutStreak&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.totalWorkoutDays, totalWorkoutDays) || other.totalWorkoutDays == totalWorkoutDays));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,isActive,lastWorkoutDate,totalWorkoutDays);

@override
String toString() {
  return 'WorkoutStreak(currentStreak: $currentStreak, longestStreak: $longestStreak, isActive: $isActive, lastWorkoutDate: $lastWorkoutDate, totalWorkoutDays: $totalWorkoutDays)';
}


}

/// @nodoc
abstract mixin class $WorkoutStreakCopyWith<$Res>  {
  factory $WorkoutStreakCopyWith(WorkoutStreak value, $Res Function(WorkoutStreak) _then) = _$WorkoutStreakCopyWithImpl;
@useResult
$Res call({
 int currentStreak, int longestStreak, bool isActive, DateTime? lastWorkoutDate, int totalWorkoutDays
});




}
/// @nodoc
class _$WorkoutStreakCopyWithImpl<$Res>
    implements $WorkoutStreakCopyWith<$Res> {
  _$WorkoutStreakCopyWithImpl(this._self, this._then);

  final WorkoutStreak _self;
  final $Res Function(WorkoutStreak) _then;

/// Create a copy of WorkoutStreak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? isActive = null,Object? lastWorkoutDate = freezed,Object? totalWorkoutDays = null,}) {
  return _then(_self.copyWith(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalWorkoutDays: null == totalWorkoutDays ? _self.totalWorkoutDays : totalWorkoutDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutStreak].
extension WorkoutStreakPatterns on WorkoutStreak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutStreak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutStreak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutStreak value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutStreak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutStreak value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutStreak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  bool isActive,  DateTime? lastWorkoutDate,  int totalWorkoutDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutStreak() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.isActive,_that.lastWorkoutDate,_that.totalWorkoutDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  bool isActive,  DateTime? lastWorkoutDate,  int totalWorkoutDays)  $default,) {final _that = this;
switch (_that) {
case _WorkoutStreak():
return $default(_that.currentStreak,_that.longestStreak,_that.isActive,_that.lastWorkoutDate,_that.totalWorkoutDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  int longestStreak,  bool isActive,  DateTime? lastWorkoutDate,  int totalWorkoutDays)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutStreak() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.isActive,_that.lastWorkoutDate,_that.totalWorkoutDays);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutStreak extends WorkoutStreak {
  const _WorkoutStreak({required this.currentStreak, required this.longestStreak, required this.isActive, required this.lastWorkoutDate, required this.totalWorkoutDays}): super._();
  

@override final  int currentStreak;
@override final  int longestStreak;
@override final  bool isActive;
@override final  DateTime? lastWorkoutDate;
@override final  int totalWorkoutDays;

/// Create a copy of WorkoutStreak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutStreakCopyWith<_WorkoutStreak> get copyWith => __$WorkoutStreakCopyWithImpl<_WorkoutStreak>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutStreak&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.totalWorkoutDays, totalWorkoutDays) || other.totalWorkoutDays == totalWorkoutDays));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,isActive,lastWorkoutDate,totalWorkoutDays);

@override
String toString() {
  return 'WorkoutStreak(currentStreak: $currentStreak, longestStreak: $longestStreak, isActive: $isActive, lastWorkoutDate: $lastWorkoutDate, totalWorkoutDays: $totalWorkoutDays)';
}


}

/// @nodoc
abstract mixin class _$WorkoutStreakCopyWith<$Res> implements $WorkoutStreakCopyWith<$Res> {
  factory _$WorkoutStreakCopyWith(_WorkoutStreak value, $Res Function(_WorkoutStreak) _then) = __$WorkoutStreakCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, int longestStreak, bool isActive, DateTime? lastWorkoutDate, int totalWorkoutDays
});




}
/// @nodoc
class __$WorkoutStreakCopyWithImpl<$Res>
    implements _$WorkoutStreakCopyWith<$Res> {
  __$WorkoutStreakCopyWithImpl(this._self, this._then);

  final _WorkoutStreak _self;
  final $Res Function(_WorkoutStreak) _then;

/// Create a copy of WorkoutStreak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? isActive = null,Object? lastWorkoutDate = freezed,Object? totalWorkoutDays = null,}) {
  return _then(_WorkoutStreak(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalWorkoutDays: null == totalWorkoutDays ? _self.totalWorkoutDays : totalWorkoutDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
