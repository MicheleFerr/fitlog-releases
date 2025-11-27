// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_progress_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetProgressData {

/// Current weight being lifted
 double get currentWeight;/// Weight from last workout for same exercise/set
 double get lastWeight;/// Current reps being performed
 int get currentReps;/// Reps from last workout for same exercise/set
 int get lastReps;/// Date of the last workout for reference
 DateTime get lastWorkoutDate;/// Set number this comparison is for
 int get setNumber;/// Exercise name for reference
 String get exerciseName;
/// Create a copy of SetProgressData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetProgressDataCopyWith<SetProgressData> get copyWith => _$SetProgressDataCopyWithImpl<SetProgressData>(this as SetProgressData, _$identity);

  /// Serializes this SetProgressData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetProgressData&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.lastWeight, lastWeight) || other.lastWeight == lastWeight)&&(identical(other.currentReps, currentReps) || other.currentReps == currentReps)&&(identical(other.lastReps, lastReps) || other.lastReps == lastReps)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentWeight,lastWeight,currentReps,lastReps,lastWorkoutDate,setNumber,exerciseName);

@override
String toString() {
  return 'SetProgressData(currentWeight: $currentWeight, lastWeight: $lastWeight, currentReps: $currentReps, lastReps: $lastReps, lastWorkoutDate: $lastWorkoutDate, setNumber: $setNumber, exerciseName: $exerciseName)';
}


}

/// @nodoc
abstract mixin class $SetProgressDataCopyWith<$Res>  {
  factory $SetProgressDataCopyWith(SetProgressData value, $Res Function(SetProgressData) _then) = _$SetProgressDataCopyWithImpl;
@useResult
$Res call({
 double currentWeight, double lastWeight, int currentReps, int lastReps, DateTime lastWorkoutDate, int setNumber, String exerciseName
});




}
/// @nodoc
class _$SetProgressDataCopyWithImpl<$Res>
    implements $SetProgressDataCopyWith<$Res> {
  _$SetProgressDataCopyWithImpl(this._self, this._then);

  final SetProgressData _self;
  final $Res Function(SetProgressData) _then;

/// Create a copy of SetProgressData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentWeight = null,Object? lastWeight = null,Object? currentReps = null,Object? lastReps = null,Object? lastWorkoutDate = null,Object? setNumber = null,Object? exerciseName = null,}) {
  return _then(_self.copyWith(
currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,lastWeight: null == lastWeight ? _self.lastWeight : lastWeight // ignore: cast_nullable_to_non_nullable
as double,currentReps: null == currentReps ? _self.currentReps : currentReps // ignore: cast_nullable_to_non_nullable
as int,lastReps: null == lastReps ? _self.lastReps : lastReps // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: null == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SetProgressData].
extension SetProgressDataPatterns on SetProgressData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetProgressData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetProgressData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetProgressData value)  $default,){
final _that = this;
switch (_that) {
case _SetProgressData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetProgressData value)?  $default,){
final _that = this;
switch (_that) {
case _SetProgressData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentWeight,  double lastWeight,  int currentReps,  int lastReps,  DateTime lastWorkoutDate,  int setNumber,  String exerciseName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetProgressData() when $default != null:
return $default(_that.currentWeight,_that.lastWeight,_that.currentReps,_that.lastReps,_that.lastWorkoutDate,_that.setNumber,_that.exerciseName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentWeight,  double lastWeight,  int currentReps,  int lastReps,  DateTime lastWorkoutDate,  int setNumber,  String exerciseName)  $default,) {final _that = this;
switch (_that) {
case _SetProgressData():
return $default(_that.currentWeight,_that.lastWeight,_that.currentReps,_that.lastReps,_that.lastWorkoutDate,_that.setNumber,_that.exerciseName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentWeight,  double lastWeight,  int currentReps,  int lastReps,  DateTime lastWorkoutDate,  int setNumber,  String exerciseName)?  $default,) {final _that = this;
switch (_that) {
case _SetProgressData() when $default != null:
return $default(_that.currentWeight,_that.lastWeight,_that.currentReps,_that.lastReps,_that.lastWorkoutDate,_that.setNumber,_that.exerciseName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetProgressData extends SetProgressData {
  const _SetProgressData({required this.currentWeight, required this.lastWeight, required this.currentReps, required this.lastReps, required this.lastWorkoutDate, required this.setNumber, required this.exerciseName}): super._();
  factory _SetProgressData.fromJson(Map<String, dynamic> json) => _$SetProgressDataFromJson(json);

/// Current weight being lifted
@override final  double currentWeight;
/// Weight from last workout for same exercise/set
@override final  double lastWeight;
/// Current reps being performed
@override final  int currentReps;
/// Reps from last workout for same exercise/set
@override final  int lastReps;
/// Date of the last workout for reference
@override final  DateTime lastWorkoutDate;
/// Set number this comparison is for
@override final  int setNumber;
/// Exercise name for reference
@override final  String exerciseName;

/// Create a copy of SetProgressData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetProgressDataCopyWith<_SetProgressData> get copyWith => __$SetProgressDataCopyWithImpl<_SetProgressData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetProgressDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetProgressData&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.lastWeight, lastWeight) || other.lastWeight == lastWeight)&&(identical(other.currentReps, currentReps) || other.currentReps == currentReps)&&(identical(other.lastReps, lastReps) || other.lastReps == lastReps)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentWeight,lastWeight,currentReps,lastReps,lastWorkoutDate,setNumber,exerciseName);

@override
String toString() {
  return 'SetProgressData(currentWeight: $currentWeight, lastWeight: $lastWeight, currentReps: $currentReps, lastReps: $lastReps, lastWorkoutDate: $lastWorkoutDate, setNumber: $setNumber, exerciseName: $exerciseName)';
}


}

/// @nodoc
abstract mixin class _$SetProgressDataCopyWith<$Res> implements $SetProgressDataCopyWith<$Res> {
  factory _$SetProgressDataCopyWith(_SetProgressData value, $Res Function(_SetProgressData) _then) = __$SetProgressDataCopyWithImpl;
@override @useResult
$Res call({
 double currentWeight, double lastWeight, int currentReps, int lastReps, DateTime lastWorkoutDate, int setNumber, String exerciseName
});




}
/// @nodoc
class __$SetProgressDataCopyWithImpl<$Res>
    implements _$SetProgressDataCopyWith<$Res> {
  __$SetProgressDataCopyWithImpl(this._self, this._then);

  final _SetProgressData _self;
  final $Res Function(_SetProgressData) _then;

/// Create a copy of SetProgressData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentWeight = null,Object? lastWeight = null,Object? currentReps = null,Object? lastReps = null,Object? lastWorkoutDate = null,Object? setNumber = null,Object? exerciseName = null,}) {
  return _then(_SetProgressData(
currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,lastWeight: null == lastWeight ? _self.lastWeight : lastWeight // ignore: cast_nullable_to_non_nullable
as double,currentReps: null == currentReps ? _self.currentReps : currentReps // ignore: cast_nullable_to_non_nullable
as int,lastReps: null == lastReps ? _self.lastReps : lastReps // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: null == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SetProgressParams {

 String get exerciseName; int get setNumber; double get currentWeight; int get currentReps;
/// Create a copy of SetProgressParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetProgressParamsCopyWith<SetProgressParams> get copyWith => _$SetProgressParamsCopyWithImpl<SetProgressParams>(this as SetProgressParams, _$identity);

  /// Serializes this SetProgressParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetProgressParams&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.currentReps, currentReps) || other.currentReps == currentReps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,setNumber,currentWeight,currentReps);

@override
String toString() {
  return 'SetProgressParams(exerciseName: $exerciseName, setNumber: $setNumber, currentWeight: $currentWeight, currentReps: $currentReps)';
}


}

/// @nodoc
abstract mixin class $SetProgressParamsCopyWith<$Res>  {
  factory $SetProgressParamsCopyWith(SetProgressParams value, $Res Function(SetProgressParams) _then) = _$SetProgressParamsCopyWithImpl;
@useResult
$Res call({
 String exerciseName, int setNumber, double currentWeight, int currentReps
});




}
/// @nodoc
class _$SetProgressParamsCopyWithImpl<$Res>
    implements $SetProgressParamsCopyWith<$Res> {
  _$SetProgressParamsCopyWithImpl(this._self, this._then);

  final SetProgressParams _self;
  final $Res Function(SetProgressParams) _then;

/// Create a copy of SetProgressParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? setNumber = null,Object? currentWeight = null,Object? currentReps = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,currentReps: null == currentReps ? _self.currentReps : currentReps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SetProgressParams].
extension SetProgressParamsPatterns on SetProgressParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetProgressParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetProgressParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetProgressParams value)  $default,){
final _that = this;
switch (_that) {
case _SetProgressParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetProgressParams value)?  $default,){
final _that = this;
switch (_that) {
case _SetProgressParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  int setNumber,  double currentWeight,  int currentReps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetProgressParams() when $default != null:
return $default(_that.exerciseName,_that.setNumber,_that.currentWeight,_that.currentReps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  int setNumber,  double currentWeight,  int currentReps)  $default,) {final _that = this;
switch (_that) {
case _SetProgressParams():
return $default(_that.exerciseName,_that.setNumber,_that.currentWeight,_that.currentReps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  int setNumber,  double currentWeight,  int currentReps)?  $default,) {final _that = this;
switch (_that) {
case _SetProgressParams() when $default != null:
return $default(_that.exerciseName,_that.setNumber,_that.currentWeight,_that.currentReps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetProgressParams implements SetProgressParams {
  const _SetProgressParams({required this.exerciseName, required this.setNumber, required this.currentWeight, required this.currentReps});
  factory _SetProgressParams.fromJson(Map<String, dynamic> json) => _$SetProgressParamsFromJson(json);

@override final  String exerciseName;
@override final  int setNumber;
@override final  double currentWeight;
@override final  int currentReps;

/// Create a copy of SetProgressParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetProgressParamsCopyWith<_SetProgressParams> get copyWith => __$SetProgressParamsCopyWithImpl<_SetProgressParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetProgressParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetProgressParams&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.currentReps, currentReps) || other.currentReps == currentReps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,setNumber,currentWeight,currentReps);

@override
String toString() {
  return 'SetProgressParams(exerciseName: $exerciseName, setNumber: $setNumber, currentWeight: $currentWeight, currentReps: $currentReps)';
}


}

/// @nodoc
abstract mixin class _$SetProgressParamsCopyWith<$Res> implements $SetProgressParamsCopyWith<$Res> {
  factory _$SetProgressParamsCopyWith(_SetProgressParams value, $Res Function(_SetProgressParams) _then) = __$SetProgressParamsCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, int setNumber, double currentWeight, int currentReps
});




}
/// @nodoc
class __$SetProgressParamsCopyWithImpl<$Res>
    implements _$SetProgressParamsCopyWith<$Res> {
  __$SetProgressParamsCopyWithImpl(this._self, this._then);

  final _SetProgressParams _self;
  final $Res Function(_SetProgressParams) _then;

/// Create a copy of SetProgressParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? setNumber = null,Object? currentWeight = null,Object? currentReps = null,}) {
  return _then(_SetProgressParams(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,currentReps: null == currentReps ? _self.currentReps : currentReps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
