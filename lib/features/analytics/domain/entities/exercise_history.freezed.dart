// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseHistory {

/// Name of the exercise (e.g., "Bench Press", "Squat")
 String get exerciseName;/// Target muscle group (e.g., "chest", "back", "legs")
 String get muscleGroup;/// All sessions performed for this exercise (sorted by date)
 List<ExerciseSession> get sessions;
/// Create a copy of ExerciseHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseHistoryCopyWith<ExerciseHistory> get copyWith => _$ExerciseHistoryCopyWithImpl<ExerciseHistory>(this as ExerciseHistory, _$identity);

  /// Serializes this ExerciseHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseHistory&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other.sessions, sessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(sessions));

@override
String toString() {
  return 'ExerciseHistory(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class $ExerciseHistoryCopyWith<$Res>  {
  factory $ExerciseHistoryCopyWith(ExerciseHistory value, $Res Function(ExerciseHistory) _then) = _$ExerciseHistoryCopyWithImpl;
@useResult
$Res call({
 String exerciseName, String muscleGroup, List<ExerciseSession> sessions
});




}
/// @nodoc
class _$ExerciseHistoryCopyWithImpl<$Res>
    implements $ExerciseHistoryCopyWith<$Res> {
  _$ExerciseHistoryCopyWithImpl(this._self, this._then);

  final ExerciseHistory _self;
  final $Res Function(ExerciseHistory) _then;

/// Create a copy of ExerciseHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sessions = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ExerciseSession>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseHistory].
extension ExerciseHistoryPatterns on ExerciseHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseHistory value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseHistory value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<ExerciseSession> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseHistory() when $default != null:
return $default(_that.exerciseName,_that.muscleGroup,_that.sessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<ExerciseSession> sessions)  $default,) {final _that = this;
switch (_that) {
case _ExerciseHistory():
return $default(_that.exerciseName,_that.muscleGroup,_that.sessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  String muscleGroup,  List<ExerciseSession> sessions)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseHistory() when $default != null:
return $default(_that.exerciseName,_that.muscleGroup,_that.sessions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseHistory extends ExerciseHistory {
  const _ExerciseHistory({required this.exerciseName, required this.muscleGroup, required final  List<ExerciseSession> sessions}): _sessions = sessions,super._();
  factory _ExerciseHistory.fromJson(Map<String, dynamic> json) => _$ExerciseHistoryFromJson(json);

/// Name of the exercise (e.g., "Bench Press", "Squat")
@override final  String exerciseName;
/// Target muscle group (e.g., "chest", "back", "legs")
@override final  String muscleGroup;
/// All sessions performed for this exercise (sorted by date)
 final  List<ExerciseSession> _sessions;
/// All sessions performed for this exercise (sorted by date)
@override List<ExerciseSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}


/// Create a copy of ExerciseHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseHistoryCopyWith<_ExerciseHistory> get copyWith => __$ExerciseHistoryCopyWithImpl<_ExerciseHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseHistory&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other._sessions, _sessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(_sessions));

@override
String toString() {
  return 'ExerciseHistory(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$ExerciseHistoryCopyWith<$Res> implements $ExerciseHistoryCopyWith<$Res> {
  factory _$ExerciseHistoryCopyWith(_ExerciseHistory value, $Res Function(_ExerciseHistory) _then) = __$ExerciseHistoryCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, String muscleGroup, List<ExerciseSession> sessions
});




}
/// @nodoc
class __$ExerciseHistoryCopyWithImpl<$Res>
    implements _$ExerciseHistoryCopyWith<$Res> {
  __$ExerciseHistoryCopyWithImpl(this._self, this._then);

  final _ExerciseHistory _self;
  final $Res Function(_ExerciseHistory) _then;

/// Create a copy of ExerciseHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sessions = null,}) {
  return _then(_ExerciseHistory(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ExerciseSession>,
  ));
}


}

// dart format on
