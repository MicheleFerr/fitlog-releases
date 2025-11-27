// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'last_workout_set_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LastWorkoutSetData {

/// Weight used in the last workout (in kg)
 double get weight;/// Number of reps completed
 int get reps;/// RPE rating (1-10) if recorded
 int? get rpe;/// Date when this workout was completed
 DateTime get date;/// Name of the workout (e.g., "Push Day")
 String? get workoutName;/// Set number this data corresponds to
 int get setNumber;/// Exercise name for reference
 String get exerciseName;
/// Create a copy of LastWorkoutSetData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LastWorkoutSetDataCopyWith<LastWorkoutSetData> get copyWith => _$LastWorkoutSetDataCopyWithImpl<LastWorkoutSetData>(this as LastWorkoutSetData, _$identity);

  /// Serializes this LastWorkoutSetData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastWorkoutSetData&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.date, date) || other.date == date)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,reps,rpe,date,workoutName,setNumber,exerciseName);

@override
String toString() {
  return 'LastWorkoutSetData(weight: $weight, reps: $reps, rpe: $rpe, date: $date, workoutName: $workoutName, setNumber: $setNumber, exerciseName: $exerciseName)';
}


}

/// @nodoc
abstract mixin class $LastWorkoutSetDataCopyWith<$Res>  {
  factory $LastWorkoutSetDataCopyWith(LastWorkoutSetData value, $Res Function(LastWorkoutSetData) _then) = _$LastWorkoutSetDataCopyWithImpl;
@useResult
$Res call({
 double weight, int reps, int? rpe, DateTime date, String? workoutName, int setNumber, String exerciseName
});




}
/// @nodoc
class _$LastWorkoutSetDataCopyWithImpl<$Res>
    implements $LastWorkoutSetDataCopyWith<$Res> {
  _$LastWorkoutSetDataCopyWithImpl(this._self, this._then);

  final LastWorkoutSetData _self;
  final $Res Function(LastWorkoutSetData) _then;

/// Create a copy of LastWorkoutSetData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weight = null,Object? reps = null,Object? rpe = freezed,Object? date = null,Object? workoutName = freezed,Object? setNumber = null,Object? exerciseName = null,}) {
  return _then(_self.copyWith(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,workoutName: freezed == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String?,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LastWorkoutSetData].
extension LastWorkoutSetDataPatterns on LastWorkoutSetData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LastWorkoutSetData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LastWorkoutSetData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LastWorkoutSetData value)  $default,){
final _that = this;
switch (_that) {
case _LastWorkoutSetData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LastWorkoutSetData value)?  $default,){
final _that = this;
switch (_that) {
case _LastWorkoutSetData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weight,  int reps,  int? rpe,  DateTime date,  String? workoutName,  int setNumber,  String exerciseName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LastWorkoutSetData() when $default != null:
return $default(_that.weight,_that.reps,_that.rpe,_that.date,_that.workoutName,_that.setNumber,_that.exerciseName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weight,  int reps,  int? rpe,  DateTime date,  String? workoutName,  int setNumber,  String exerciseName)  $default,) {final _that = this;
switch (_that) {
case _LastWorkoutSetData():
return $default(_that.weight,_that.reps,_that.rpe,_that.date,_that.workoutName,_that.setNumber,_that.exerciseName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weight,  int reps,  int? rpe,  DateTime date,  String? workoutName,  int setNumber,  String exerciseName)?  $default,) {final _that = this;
switch (_that) {
case _LastWorkoutSetData() when $default != null:
return $default(_that.weight,_that.reps,_that.rpe,_that.date,_that.workoutName,_that.setNumber,_that.exerciseName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LastWorkoutSetData implements LastWorkoutSetData {
  const _LastWorkoutSetData({required this.weight, required this.reps, this.rpe, required this.date, this.workoutName, required this.setNumber, required this.exerciseName});
  factory _LastWorkoutSetData.fromJson(Map<String, dynamic> json) => _$LastWorkoutSetDataFromJson(json);

/// Weight used in the last workout (in kg)
@override final  double weight;
/// Number of reps completed
@override final  int reps;
/// RPE rating (1-10) if recorded
@override final  int? rpe;
/// Date when this workout was completed
@override final  DateTime date;
/// Name of the workout (e.g., "Push Day")
@override final  String? workoutName;
/// Set number this data corresponds to
@override final  int setNumber;
/// Exercise name for reference
@override final  String exerciseName;

/// Create a copy of LastWorkoutSetData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LastWorkoutSetDataCopyWith<_LastWorkoutSetData> get copyWith => __$LastWorkoutSetDataCopyWithImpl<_LastWorkoutSetData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LastWorkoutSetDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LastWorkoutSetData&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.date, date) || other.date == date)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,reps,rpe,date,workoutName,setNumber,exerciseName);

@override
String toString() {
  return 'LastWorkoutSetData(weight: $weight, reps: $reps, rpe: $rpe, date: $date, workoutName: $workoutName, setNumber: $setNumber, exerciseName: $exerciseName)';
}


}

/// @nodoc
abstract mixin class _$LastWorkoutSetDataCopyWith<$Res> implements $LastWorkoutSetDataCopyWith<$Res> {
  factory _$LastWorkoutSetDataCopyWith(_LastWorkoutSetData value, $Res Function(_LastWorkoutSetData) _then) = __$LastWorkoutSetDataCopyWithImpl;
@override @useResult
$Res call({
 double weight, int reps, int? rpe, DateTime date, String? workoutName, int setNumber, String exerciseName
});




}
/// @nodoc
class __$LastWorkoutSetDataCopyWithImpl<$Res>
    implements _$LastWorkoutSetDataCopyWith<$Res> {
  __$LastWorkoutSetDataCopyWithImpl(this._self, this._then);

  final _LastWorkoutSetData _self;
  final $Res Function(_LastWorkoutSetData) _then;

/// Create a copy of LastWorkoutSetData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weight = null,Object? reps = null,Object? rpe = freezed,Object? date = null,Object? workoutName = freezed,Object? setNumber = null,Object? exerciseName = null,}) {
  return _then(_LastWorkoutSetData(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,workoutName: freezed == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String?,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LastWorkoutSetParams {

 String get exerciseName; int get setNumber;
/// Create a copy of LastWorkoutSetParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LastWorkoutSetParamsCopyWith<LastWorkoutSetParams> get copyWith => _$LastWorkoutSetParamsCopyWithImpl<LastWorkoutSetParams>(this as LastWorkoutSetParams, _$identity);

  /// Serializes this LastWorkoutSetParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastWorkoutSetParams&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,setNumber);

@override
String toString() {
  return 'LastWorkoutSetParams(exerciseName: $exerciseName, setNumber: $setNumber)';
}


}

/// @nodoc
abstract mixin class $LastWorkoutSetParamsCopyWith<$Res>  {
  factory $LastWorkoutSetParamsCopyWith(LastWorkoutSetParams value, $Res Function(LastWorkoutSetParams) _then) = _$LastWorkoutSetParamsCopyWithImpl;
@useResult
$Res call({
 String exerciseName, int setNumber
});




}
/// @nodoc
class _$LastWorkoutSetParamsCopyWithImpl<$Res>
    implements $LastWorkoutSetParamsCopyWith<$Res> {
  _$LastWorkoutSetParamsCopyWithImpl(this._self, this._then);

  final LastWorkoutSetParams _self;
  final $Res Function(LastWorkoutSetParams) _then;

/// Create a copy of LastWorkoutSetParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? setNumber = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LastWorkoutSetParams].
extension LastWorkoutSetParamsPatterns on LastWorkoutSetParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LastWorkoutSetParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LastWorkoutSetParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LastWorkoutSetParams value)  $default,){
final _that = this;
switch (_that) {
case _LastWorkoutSetParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LastWorkoutSetParams value)?  $default,){
final _that = this;
switch (_that) {
case _LastWorkoutSetParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  int setNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LastWorkoutSetParams() when $default != null:
return $default(_that.exerciseName,_that.setNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  int setNumber)  $default,) {final _that = this;
switch (_that) {
case _LastWorkoutSetParams():
return $default(_that.exerciseName,_that.setNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  int setNumber)?  $default,) {final _that = this;
switch (_that) {
case _LastWorkoutSetParams() when $default != null:
return $default(_that.exerciseName,_that.setNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LastWorkoutSetParams implements LastWorkoutSetParams {
  const _LastWorkoutSetParams({required this.exerciseName, required this.setNumber});
  factory _LastWorkoutSetParams.fromJson(Map<String, dynamic> json) => _$LastWorkoutSetParamsFromJson(json);

@override final  String exerciseName;
@override final  int setNumber;

/// Create a copy of LastWorkoutSetParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LastWorkoutSetParamsCopyWith<_LastWorkoutSetParams> get copyWith => __$LastWorkoutSetParamsCopyWithImpl<_LastWorkoutSetParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LastWorkoutSetParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LastWorkoutSetParams&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,setNumber);

@override
String toString() {
  return 'LastWorkoutSetParams(exerciseName: $exerciseName, setNumber: $setNumber)';
}


}

/// @nodoc
abstract mixin class _$LastWorkoutSetParamsCopyWith<$Res> implements $LastWorkoutSetParamsCopyWith<$Res> {
  factory _$LastWorkoutSetParamsCopyWith(_LastWorkoutSetParams value, $Res Function(_LastWorkoutSetParams) _then) = __$LastWorkoutSetParamsCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, int setNumber
});




}
/// @nodoc
class __$LastWorkoutSetParamsCopyWithImpl<$Res>
    implements _$LastWorkoutSetParamsCopyWith<$Res> {
  __$LastWorkoutSetParamsCopyWithImpl(this._self, this._then);

  final _LastWorkoutSetParams _self;
  final $Res Function(_LastWorkoutSetParams) _then;

/// Create a copy of LastWorkoutSetParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? setNumber = null,}) {
  return _then(_LastWorkoutSetParams(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
