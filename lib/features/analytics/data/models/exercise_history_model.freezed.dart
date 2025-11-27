// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExerciseHistoryModel {

/// Name of the exercise (also the document ID)
 String get exerciseName;/// Target muscle group (e.g., "chest", "back", "legs")
 String get muscleGroup;/// All sessions for this exercise (sorted by date descending)
 List<ExerciseSessionModel> get sessions;/// When this document was last updated (for cache invalidation)
 DateTime get lastUpdated;
/// Create a copy of ExerciseHistoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseHistoryModelCopyWith<ExerciseHistoryModel> get copyWith => _$ExerciseHistoryModelCopyWithImpl<ExerciseHistoryModel>(this as ExerciseHistoryModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseHistoryModel&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(sessions),lastUpdated);

@override
String toString() {
  return 'ExerciseHistoryModel(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sessions: $sessions, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $ExerciseHistoryModelCopyWith<$Res>  {
  factory $ExerciseHistoryModelCopyWith(ExerciseHistoryModel value, $Res Function(ExerciseHistoryModel) _then) = _$ExerciseHistoryModelCopyWithImpl;
@useResult
$Res call({
 String exerciseName, String muscleGroup, List<ExerciseSessionModel> sessions, DateTime lastUpdated
});




}
/// @nodoc
class _$ExerciseHistoryModelCopyWithImpl<$Res>
    implements $ExerciseHistoryModelCopyWith<$Res> {
  _$ExerciseHistoryModelCopyWithImpl(this._self, this._then);

  final ExerciseHistoryModel _self;
  final $Res Function(ExerciseHistoryModel) _then;

/// Create a copy of ExerciseHistoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sessions = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ExerciseSessionModel>,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseHistoryModel].
extension ExerciseHistoryModelPatterns on ExerciseHistoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseHistoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseHistoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseHistoryModel value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseHistoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseHistoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseHistoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<ExerciseSessionModel> sessions,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseHistoryModel() when $default != null:
return $default(_that.exerciseName,_that.muscleGroup,_that.sessions,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<ExerciseSessionModel> sessions,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _ExerciseHistoryModel():
return $default(_that.exerciseName,_that.muscleGroup,_that.sessions,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  String muscleGroup,  List<ExerciseSessionModel> sessions,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseHistoryModel() when $default != null:
return $default(_that.exerciseName,_that.muscleGroup,_that.sessions,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseHistoryModel extends ExerciseHistoryModel {
  const _ExerciseHistoryModel({required this.exerciseName, required this.muscleGroup, required final  List<ExerciseSessionModel> sessions, required this.lastUpdated}): _sessions = sessions,super._();
  

/// Name of the exercise (also the document ID)
@override final  String exerciseName;
/// Target muscle group (e.g., "chest", "back", "legs")
@override final  String muscleGroup;
/// All sessions for this exercise (sorted by date descending)
 final  List<ExerciseSessionModel> _sessions;
/// All sessions for this exercise (sorted by date descending)
@override List<ExerciseSessionModel> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

/// When this document was last updated (for cache invalidation)
@override final  DateTime lastUpdated;

/// Create a copy of ExerciseHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseHistoryModelCopyWith<_ExerciseHistoryModel> get copyWith => __$ExerciseHistoryModelCopyWithImpl<_ExerciseHistoryModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseHistoryModel&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(_sessions),lastUpdated);

@override
String toString() {
  return 'ExerciseHistoryModel(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sessions: $sessions, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$ExerciseHistoryModelCopyWith<$Res> implements $ExerciseHistoryModelCopyWith<$Res> {
  factory _$ExerciseHistoryModelCopyWith(_ExerciseHistoryModel value, $Res Function(_ExerciseHistoryModel) _then) = __$ExerciseHistoryModelCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, String muscleGroup, List<ExerciseSessionModel> sessions, DateTime lastUpdated
});




}
/// @nodoc
class __$ExerciseHistoryModelCopyWithImpl<$Res>
    implements _$ExerciseHistoryModelCopyWith<$Res> {
  __$ExerciseHistoryModelCopyWithImpl(this._self, this._then);

  final _ExerciseHistoryModel _self;
  final $Res Function(_ExerciseHistoryModel) _then;

/// Create a copy of ExerciseHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sessions = null,Object? lastUpdated = null,}) {
  return _then(_ExerciseHistoryModel(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ExerciseSessionModel>,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
