// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseSession {

/// Name of the exercise (e.g., "Bench Press", "Squat")
 String get exerciseName;/// Target muscle group (e.g., "chest", "back", "legs")
 String get muscleGroup;/// All sets performed in this session
 List<AnalyticsSet> get sets;/// When the session was performed
 DateTime get date;
/// Create a copy of ExerciseSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseSessionCopyWith<ExerciseSession> get copyWith => _$ExerciseSessionCopyWithImpl<ExerciseSession>(this as ExerciseSession, _$identity);

  /// Serializes this ExerciseSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseSession&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(sets),date);

@override
String toString() {
  return 'ExerciseSession(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sets: $sets, date: $date)';
}


}

/// @nodoc
abstract mixin class $ExerciseSessionCopyWith<$Res>  {
  factory $ExerciseSessionCopyWith(ExerciseSession value, $Res Function(ExerciseSession) _then) = _$ExerciseSessionCopyWithImpl;
@useResult
$Res call({
 String exerciseName, String muscleGroup, List<AnalyticsSet> sets, DateTime date
});




}
/// @nodoc
class _$ExerciseSessionCopyWithImpl<$Res>
    implements $ExerciseSessionCopyWith<$Res> {
  _$ExerciseSessionCopyWithImpl(this._self, this._then);

  final ExerciseSession _self;
  final $Res Function(ExerciseSession) _then;

/// Create a copy of ExerciseSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sets = null,Object? date = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<AnalyticsSet>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseSession].
extension ExerciseSessionPatterns on ExerciseSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseSession value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseSession value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<AnalyticsSet> sets,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseSession() when $default != null:
return $default(_that.exerciseName,_that.muscleGroup,_that.sets,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<AnalyticsSet> sets,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _ExerciseSession():
return $default(_that.exerciseName,_that.muscleGroup,_that.sets,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  String muscleGroup,  List<AnalyticsSet> sets,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseSession() when $default != null:
return $default(_that.exerciseName,_that.muscleGroup,_that.sets,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseSession extends ExerciseSession {
  const _ExerciseSession({required this.exerciseName, required this.muscleGroup, required final  List<AnalyticsSet> sets, required this.date}): _sets = sets,super._();
  factory _ExerciseSession.fromJson(Map<String, dynamic> json) => _$ExerciseSessionFromJson(json);

/// Name of the exercise (e.g., "Bench Press", "Squat")
@override final  String exerciseName;
/// Target muscle group (e.g., "chest", "back", "legs")
@override final  String muscleGroup;
/// All sets performed in this session
 final  List<AnalyticsSet> _sets;
/// All sets performed in this session
@override List<AnalyticsSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

/// When the session was performed
@override final  DateTime date;

/// Create a copy of ExerciseSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseSessionCopyWith<_ExerciseSession> get copyWith => __$ExerciseSessionCopyWithImpl<_ExerciseSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseSession&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(_sets),date);

@override
String toString() {
  return 'ExerciseSession(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sets: $sets, date: $date)';
}


}

/// @nodoc
abstract mixin class _$ExerciseSessionCopyWith<$Res> implements $ExerciseSessionCopyWith<$Res> {
  factory _$ExerciseSessionCopyWith(_ExerciseSession value, $Res Function(_ExerciseSession) _then) = __$ExerciseSessionCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, String muscleGroup, List<AnalyticsSet> sets, DateTime date
});




}
/// @nodoc
class __$ExerciseSessionCopyWithImpl<$Res>
    implements _$ExerciseSessionCopyWith<$Res> {
  __$ExerciseSessionCopyWithImpl(this._self, this._then);

  final _ExerciseSession _self;
  final $Res Function(_ExerciseSession) _then;

/// Create a copy of ExerciseSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sets = null,Object? date = null,}) {
  return _then(_ExerciseSession(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<AnalyticsSet>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
