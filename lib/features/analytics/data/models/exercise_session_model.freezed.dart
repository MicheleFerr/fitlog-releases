// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExerciseSessionModel {

/// Name of the exercise (e.g., "Bench Press", "Squat")
 String get exerciseName;/// Target muscle group (e.g., "chest", "back", "legs")
 String get muscleGroup;/// All sets performed in this session
 List<AnalyticsSetModel> get sets;/// When the session was performed (Firestore Timestamp)
 DateTime get date;
/// Create a copy of ExerciseSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseSessionModelCopyWith<ExerciseSessionModel> get copyWith => _$ExerciseSessionModelCopyWithImpl<ExerciseSessionModel>(this as ExerciseSessionModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseSessionModel&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(sets),date);

@override
String toString() {
  return 'ExerciseSessionModel(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sets: $sets, date: $date)';
}


}

/// @nodoc
abstract mixin class $ExerciseSessionModelCopyWith<$Res>  {
  factory $ExerciseSessionModelCopyWith(ExerciseSessionModel value, $Res Function(ExerciseSessionModel) _then) = _$ExerciseSessionModelCopyWithImpl;
@useResult
$Res call({
 String exerciseName, String muscleGroup, List<AnalyticsSetModel> sets, DateTime date
});




}
/// @nodoc
class _$ExerciseSessionModelCopyWithImpl<$Res>
    implements $ExerciseSessionModelCopyWith<$Res> {
  _$ExerciseSessionModelCopyWithImpl(this._self, this._then);

  final ExerciseSessionModel _self;
  final $Res Function(ExerciseSessionModel) _then;

/// Create a copy of ExerciseSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sets = null,Object? date = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<AnalyticsSetModel>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseSessionModel].
extension ExerciseSessionModelPatterns on ExerciseSessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseSessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseSessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseSessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<AnalyticsSetModel> sets,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseSessionModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  String muscleGroup,  List<AnalyticsSetModel> sets,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _ExerciseSessionModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  String muscleGroup,  List<AnalyticsSetModel> sets,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseSessionModel() when $default != null:
return $default(_that.exerciseName,_that.muscleGroup,_that.sets,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseSessionModel extends ExerciseSessionModel {
  const _ExerciseSessionModel({required this.exerciseName, required this.muscleGroup, required final  List<AnalyticsSetModel> sets, required this.date}): _sets = sets,super._();
  

/// Name of the exercise (e.g., "Bench Press", "Squat")
@override final  String exerciseName;
/// Target muscle group (e.g., "chest", "back", "legs")
@override final  String muscleGroup;
/// All sets performed in this session
 final  List<AnalyticsSetModel> _sets;
/// All sets performed in this session
@override List<AnalyticsSetModel> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

/// When the session was performed (Firestore Timestamp)
@override final  DateTime date;

/// Create a copy of ExerciseSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseSessionModelCopyWith<_ExerciseSessionModel> get copyWith => __$ExerciseSessionModelCopyWithImpl<_ExerciseSessionModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseSessionModel&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,muscleGroup,const DeepCollectionEquality().hash(_sets),date);

@override
String toString() {
  return 'ExerciseSessionModel(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sets: $sets, date: $date)';
}


}

/// @nodoc
abstract mixin class _$ExerciseSessionModelCopyWith<$Res> implements $ExerciseSessionModelCopyWith<$Res> {
  factory _$ExerciseSessionModelCopyWith(_ExerciseSessionModel value, $Res Function(_ExerciseSessionModel) _then) = __$ExerciseSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, String muscleGroup, List<AnalyticsSetModel> sets, DateTime date
});




}
/// @nodoc
class __$ExerciseSessionModelCopyWithImpl<$Res>
    implements _$ExerciseSessionModelCopyWith<$Res> {
  __$ExerciseSessionModelCopyWithImpl(this._self, this._then);

  final _ExerciseSessionModel _self;
  final $Res Function(_ExerciseSessionModel) _then;

/// Create a copy of ExerciseSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? muscleGroup = null,Object? sets = null,Object? date = null,}) {
  return _then(_ExerciseSessionModel(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,muscleGroup: null == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<AnalyticsSetModel>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
