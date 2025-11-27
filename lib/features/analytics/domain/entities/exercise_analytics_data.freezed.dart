// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_analytics_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChartDataPoint {

/// Date of the data point
 DateTime get date;/// Primary value (weight, volume, etc.)
 double get value;/// Optional RPE for this data point
 int? get rpe;/// Optional reps count
 int? get reps;/// Optional session index (1, 2, 3...)
 int? get sessionIndex;
/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChartDataPointCopyWith<ChartDataPoint> get copyWith => _$ChartDataPointCopyWithImpl<ChartDataPoint>(this as ChartDataPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChartDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.sessionIndex, sessionIndex) || other.sessionIndex == sessionIndex));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,rpe,reps,sessionIndex);

@override
String toString() {
  return 'ChartDataPoint(date: $date, value: $value, rpe: $rpe, reps: $reps, sessionIndex: $sessionIndex)';
}


}

/// @nodoc
abstract mixin class $ChartDataPointCopyWith<$Res>  {
  factory $ChartDataPointCopyWith(ChartDataPoint value, $Res Function(ChartDataPoint) _then) = _$ChartDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double value, int? rpe, int? reps, int? sessionIndex
});




}
/// @nodoc
class _$ChartDataPointCopyWithImpl<$Res>
    implements $ChartDataPointCopyWith<$Res> {
  _$ChartDataPointCopyWithImpl(this._self, this._then);

  final ChartDataPoint _self;
  final $Res Function(ChartDataPoint) _then;

/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,Object? rpe = freezed,Object? reps = freezed,Object? sessionIndex = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,sessionIndex: freezed == sessionIndex ? _self.sessionIndex : sessionIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChartDataPoint].
extension ChartDataPointPatterns on ChartDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChartDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChartDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _ChartDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChartDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double value,  int? rpe,  int? reps,  int? sessionIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.rpe,_that.reps,_that.sessionIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double value,  int? rpe,  int? reps,  int? sessionIndex)  $default,) {final _that = this;
switch (_that) {
case _ChartDataPoint():
return $default(_that.date,_that.value,_that.rpe,_that.reps,_that.sessionIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double value,  int? rpe,  int? reps,  int? sessionIndex)?  $default,) {final _that = this;
switch (_that) {
case _ChartDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.rpe,_that.reps,_that.sessionIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ChartDataPoint extends ChartDataPoint {
  const _ChartDataPoint({required this.date, required this.value, this.rpe, this.reps, this.sessionIndex}): super._();
  

/// Date of the data point
@override final  DateTime date;
/// Primary value (weight, volume, etc.)
@override final  double value;
/// Optional RPE for this data point
@override final  int? rpe;
/// Optional reps count
@override final  int? reps;
/// Optional session index (1, 2, 3...)
@override final  int? sessionIndex;

/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartDataPointCopyWith<_ChartDataPoint> get copyWith => __$ChartDataPointCopyWithImpl<_ChartDataPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.sessionIndex, sessionIndex) || other.sessionIndex == sessionIndex));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,rpe,reps,sessionIndex);

@override
String toString() {
  return 'ChartDataPoint(date: $date, value: $value, rpe: $rpe, reps: $reps, sessionIndex: $sessionIndex)';
}


}

/// @nodoc
abstract mixin class _$ChartDataPointCopyWith<$Res> implements $ChartDataPointCopyWith<$Res> {
  factory _$ChartDataPointCopyWith(_ChartDataPoint value, $Res Function(_ChartDataPoint) _then) = __$ChartDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double value, int? rpe, int? reps, int? sessionIndex
});




}
/// @nodoc
class __$ChartDataPointCopyWithImpl<$Res>
    implements _$ChartDataPointCopyWith<$Res> {
  __$ChartDataPointCopyWithImpl(this._self, this._then);

  final _ChartDataPoint _self;
  final $Res Function(_ChartDataPoint) _then;

/// Create a copy of ChartDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,Object? rpe = freezed,Object? reps = freezed,Object? sessionIndex = freezed,}) {
  return _then(_ChartDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,sessionIndex: freezed == sessionIndex ? _self.sessionIndex : sessionIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$ProgressiveOverloadData {

/// Current weekly progression percentage
 double get currentPercent;/// Target min-max range for user's level
 double get targetMin; double get targetMax;/// Status classification
 OverloadStatus get status;/// User's experience level used for calculation
 String get userLevel;/// Current volume
 double get currentVolume;/// Previous volume (for comparison)
 double get previousVolume;
/// Create a copy of ProgressiveOverloadData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressiveOverloadDataCopyWith<ProgressiveOverloadData> get copyWith => _$ProgressiveOverloadDataCopyWithImpl<ProgressiveOverloadData>(this as ProgressiveOverloadData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressiveOverloadData&&(identical(other.currentPercent, currentPercent) || other.currentPercent == currentPercent)&&(identical(other.targetMin, targetMin) || other.targetMin == targetMin)&&(identical(other.targetMax, targetMax) || other.targetMax == targetMax)&&(identical(other.status, status) || other.status == status)&&(identical(other.userLevel, userLevel) || other.userLevel == userLevel)&&(identical(other.currentVolume, currentVolume) || other.currentVolume == currentVolume)&&(identical(other.previousVolume, previousVolume) || other.previousVolume == previousVolume));
}


@override
int get hashCode => Object.hash(runtimeType,currentPercent,targetMin,targetMax,status,userLevel,currentVolume,previousVolume);

@override
String toString() {
  return 'ProgressiveOverloadData(currentPercent: $currentPercent, targetMin: $targetMin, targetMax: $targetMax, status: $status, userLevel: $userLevel, currentVolume: $currentVolume, previousVolume: $previousVolume)';
}


}

/// @nodoc
abstract mixin class $ProgressiveOverloadDataCopyWith<$Res>  {
  factory $ProgressiveOverloadDataCopyWith(ProgressiveOverloadData value, $Res Function(ProgressiveOverloadData) _then) = _$ProgressiveOverloadDataCopyWithImpl;
@useResult
$Res call({
 double currentPercent, double targetMin, double targetMax, OverloadStatus status, String userLevel, double currentVolume, double previousVolume
});




}
/// @nodoc
class _$ProgressiveOverloadDataCopyWithImpl<$Res>
    implements $ProgressiveOverloadDataCopyWith<$Res> {
  _$ProgressiveOverloadDataCopyWithImpl(this._self, this._then);

  final ProgressiveOverloadData _self;
  final $Res Function(ProgressiveOverloadData) _then;

/// Create a copy of ProgressiveOverloadData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPercent = null,Object? targetMin = null,Object? targetMax = null,Object? status = null,Object? userLevel = null,Object? currentVolume = null,Object? previousVolume = null,}) {
  return _then(_self.copyWith(
currentPercent: null == currentPercent ? _self.currentPercent : currentPercent // ignore: cast_nullable_to_non_nullable
as double,targetMin: null == targetMin ? _self.targetMin : targetMin // ignore: cast_nullable_to_non_nullable
as double,targetMax: null == targetMax ? _self.targetMax : targetMax // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OverloadStatus,userLevel: null == userLevel ? _self.userLevel : userLevel // ignore: cast_nullable_to_non_nullable
as String,currentVolume: null == currentVolume ? _self.currentVolume : currentVolume // ignore: cast_nullable_to_non_nullable
as double,previousVolume: null == previousVolume ? _self.previousVolume : previousVolume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressiveOverloadData].
extension ProgressiveOverloadDataPatterns on ProgressiveOverloadData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressiveOverloadData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressiveOverloadData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressiveOverloadData value)  $default,){
final _that = this;
switch (_that) {
case _ProgressiveOverloadData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressiveOverloadData value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressiveOverloadData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentPercent,  double targetMin,  double targetMax,  OverloadStatus status,  String userLevel,  double currentVolume,  double previousVolume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressiveOverloadData() when $default != null:
return $default(_that.currentPercent,_that.targetMin,_that.targetMax,_that.status,_that.userLevel,_that.currentVolume,_that.previousVolume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentPercent,  double targetMin,  double targetMax,  OverloadStatus status,  String userLevel,  double currentVolume,  double previousVolume)  $default,) {final _that = this;
switch (_that) {
case _ProgressiveOverloadData():
return $default(_that.currentPercent,_that.targetMin,_that.targetMax,_that.status,_that.userLevel,_that.currentVolume,_that.previousVolume);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentPercent,  double targetMin,  double targetMax,  OverloadStatus status,  String userLevel,  double currentVolume,  double previousVolume)?  $default,) {final _that = this;
switch (_that) {
case _ProgressiveOverloadData() when $default != null:
return $default(_that.currentPercent,_that.targetMin,_that.targetMax,_that.status,_that.userLevel,_that.currentVolume,_that.previousVolume);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressiveOverloadData extends ProgressiveOverloadData {
  const _ProgressiveOverloadData({required this.currentPercent, required this.targetMin, required this.targetMax, required this.status, required this.userLevel, required this.currentVolume, required this.previousVolume}): super._();
  

/// Current weekly progression percentage
@override final  double currentPercent;
/// Target min-max range for user's level
@override final  double targetMin;
@override final  double targetMax;
/// Status classification
@override final  OverloadStatus status;
/// User's experience level used for calculation
@override final  String userLevel;
/// Current volume
@override final  double currentVolume;
/// Previous volume (for comparison)
@override final  double previousVolume;

/// Create a copy of ProgressiveOverloadData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressiveOverloadDataCopyWith<_ProgressiveOverloadData> get copyWith => __$ProgressiveOverloadDataCopyWithImpl<_ProgressiveOverloadData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressiveOverloadData&&(identical(other.currentPercent, currentPercent) || other.currentPercent == currentPercent)&&(identical(other.targetMin, targetMin) || other.targetMin == targetMin)&&(identical(other.targetMax, targetMax) || other.targetMax == targetMax)&&(identical(other.status, status) || other.status == status)&&(identical(other.userLevel, userLevel) || other.userLevel == userLevel)&&(identical(other.currentVolume, currentVolume) || other.currentVolume == currentVolume)&&(identical(other.previousVolume, previousVolume) || other.previousVolume == previousVolume));
}


@override
int get hashCode => Object.hash(runtimeType,currentPercent,targetMin,targetMax,status,userLevel,currentVolume,previousVolume);

@override
String toString() {
  return 'ProgressiveOverloadData(currentPercent: $currentPercent, targetMin: $targetMin, targetMax: $targetMax, status: $status, userLevel: $userLevel, currentVolume: $currentVolume, previousVolume: $previousVolume)';
}


}

/// @nodoc
abstract mixin class _$ProgressiveOverloadDataCopyWith<$Res> implements $ProgressiveOverloadDataCopyWith<$Res> {
  factory _$ProgressiveOverloadDataCopyWith(_ProgressiveOverloadData value, $Res Function(_ProgressiveOverloadData) _then) = __$ProgressiveOverloadDataCopyWithImpl;
@override @useResult
$Res call({
 double currentPercent, double targetMin, double targetMax, OverloadStatus status, String userLevel, double currentVolume, double previousVolume
});




}
/// @nodoc
class __$ProgressiveOverloadDataCopyWithImpl<$Res>
    implements _$ProgressiveOverloadDataCopyWith<$Res> {
  __$ProgressiveOverloadDataCopyWithImpl(this._self, this._then);

  final _ProgressiveOverloadData _self;
  final $Res Function(_ProgressiveOverloadData) _then;

/// Create a copy of ProgressiveOverloadData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPercent = null,Object? targetMin = null,Object? targetMax = null,Object? status = null,Object? userLevel = null,Object? currentVolume = null,Object? previousVolume = null,}) {
  return _then(_ProgressiveOverloadData(
currentPercent: null == currentPercent ? _self.currentPercent : currentPercent // ignore: cast_nullable_to_non_nullable
as double,targetMin: null == targetMin ? _self.targetMin : targetMin // ignore: cast_nullable_to_non_nullable
as double,targetMax: null == targetMax ? _self.targetMax : targetMax // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OverloadStatus,userLevel: null == userLevel ? _self.userLevel : userLevel // ignore: cast_nullable_to_non_nullable
as String,currentVolume: null == currentVolume ? _self.currentVolume : currentVolume // ignore: cast_nullable_to_non_nullable
as double,previousVolume: null == previousVolume ? _self.previousVolume : previousVolume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$IntensityData {

/// Estimated 1RM in kg
 double get estimated1RM;/// Current working weight
 double get currentWeight;/// Current reps performed
 int get currentReps;/// Percentage of 1RM being used
 double get percentOf1RM;/// Formula used (Epley, Brzycki, or Epley+Brzycki)
 String get formula;/// Confidence level (High, Medium, Low)
 String get confidence;/// Intensity zone
 IntensityZone get zone;
/// Create a copy of IntensityData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntensityDataCopyWith<IntensityData> get copyWith => _$IntensityDataCopyWithImpl<IntensityData>(this as IntensityData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntensityData&&(identical(other.estimated1RM, estimated1RM) || other.estimated1RM == estimated1RM)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.currentReps, currentReps) || other.currentReps == currentReps)&&(identical(other.percentOf1RM, percentOf1RM) || other.percentOf1RM == percentOf1RM)&&(identical(other.formula, formula) || other.formula == formula)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.zone, zone) || other.zone == zone));
}


@override
int get hashCode => Object.hash(runtimeType,estimated1RM,currentWeight,currentReps,percentOf1RM,formula,confidence,zone);

@override
String toString() {
  return 'IntensityData(estimated1RM: $estimated1RM, currentWeight: $currentWeight, currentReps: $currentReps, percentOf1RM: $percentOf1RM, formula: $formula, confidence: $confidence, zone: $zone)';
}


}

/// @nodoc
abstract mixin class $IntensityDataCopyWith<$Res>  {
  factory $IntensityDataCopyWith(IntensityData value, $Res Function(IntensityData) _then) = _$IntensityDataCopyWithImpl;
@useResult
$Res call({
 double estimated1RM, double currentWeight, int currentReps, double percentOf1RM, String formula, String confidence, IntensityZone zone
});




}
/// @nodoc
class _$IntensityDataCopyWithImpl<$Res>
    implements $IntensityDataCopyWith<$Res> {
  _$IntensityDataCopyWithImpl(this._self, this._then);

  final IntensityData _self;
  final $Res Function(IntensityData) _then;

/// Create a copy of IntensityData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? estimated1RM = null,Object? currentWeight = null,Object? currentReps = null,Object? percentOf1RM = null,Object? formula = null,Object? confidence = null,Object? zone = null,}) {
  return _then(_self.copyWith(
estimated1RM: null == estimated1RM ? _self.estimated1RM : estimated1RM // ignore: cast_nullable_to_non_nullable
as double,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,currentReps: null == currentReps ? _self.currentReps : currentReps // ignore: cast_nullable_to_non_nullable
as int,percentOf1RM: null == percentOf1RM ? _self.percentOf1RM : percentOf1RM // ignore: cast_nullable_to_non_nullable
as double,formula: null == formula ? _self.formula : formula // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as IntensityZone,
  ));
}

}


/// Adds pattern-matching-related methods to [IntensityData].
extension IntensityDataPatterns on IntensityData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntensityData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntensityData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntensityData value)  $default,){
final _that = this;
switch (_that) {
case _IntensityData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntensityData value)?  $default,){
final _that = this;
switch (_that) {
case _IntensityData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double estimated1RM,  double currentWeight,  int currentReps,  double percentOf1RM,  String formula,  String confidence,  IntensityZone zone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntensityData() when $default != null:
return $default(_that.estimated1RM,_that.currentWeight,_that.currentReps,_that.percentOf1RM,_that.formula,_that.confidence,_that.zone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double estimated1RM,  double currentWeight,  int currentReps,  double percentOf1RM,  String formula,  String confidence,  IntensityZone zone)  $default,) {final _that = this;
switch (_that) {
case _IntensityData():
return $default(_that.estimated1RM,_that.currentWeight,_that.currentReps,_that.percentOf1RM,_that.formula,_that.confidence,_that.zone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double estimated1RM,  double currentWeight,  int currentReps,  double percentOf1RM,  String formula,  String confidence,  IntensityZone zone)?  $default,) {final _that = this;
switch (_that) {
case _IntensityData() when $default != null:
return $default(_that.estimated1RM,_that.currentWeight,_that.currentReps,_that.percentOf1RM,_that.formula,_that.confidence,_that.zone);case _:
  return null;

}
}

}

/// @nodoc


class _IntensityData extends IntensityData {
  const _IntensityData({required this.estimated1RM, required this.currentWeight, required this.currentReps, required this.percentOf1RM, required this.formula, required this.confidence, required this.zone}): super._();
  

/// Estimated 1RM in kg
@override final  double estimated1RM;
/// Current working weight
@override final  double currentWeight;
/// Current reps performed
@override final  int currentReps;
/// Percentage of 1RM being used
@override final  double percentOf1RM;
/// Formula used (Epley, Brzycki, or Epley+Brzycki)
@override final  String formula;
/// Confidence level (High, Medium, Low)
@override final  String confidence;
/// Intensity zone
@override final  IntensityZone zone;

/// Create a copy of IntensityData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntensityDataCopyWith<_IntensityData> get copyWith => __$IntensityDataCopyWithImpl<_IntensityData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntensityData&&(identical(other.estimated1RM, estimated1RM) || other.estimated1RM == estimated1RM)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.currentReps, currentReps) || other.currentReps == currentReps)&&(identical(other.percentOf1RM, percentOf1RM) || other.percentOf1RM == percentOf1RM)&&(identical(other.formula, formula) || other.formula == formula)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.zone, zone) || other.zone == zone));
}


@override
int get hashCode => Object.hash(runtimeType,estimated1RM,currentWeight,currentReps,percentOf1RM,formula,confidence,zone);

@override
String toString() {
  return 'IntensityData(estimated1RM: $estimated1RM, currentWeight: $currentWeight, currentReps: $currentReps, percentOf1RM: $percentOf1RM, formula: $formula, confidence: $confidence, zone: $zone)';
}


}

/// @nodoc
abstract mixin class _$IntensityDataCopyWith<$Res> implements $IntensityDataCopyWith<$Res> {
  factory _$IntensityDataCopyWith(_IntensityData value, $Res Function(_IntensityData) _then) = __$IntensityDataCopyWithImpl;
@override @useResult
$Res call({
 double estimated1RM, double currentWeight, int currentReps, double percentOf1RM, String formula, String confidence, IntensityZone zone
});




}
/// @nodoc
class __$IntensityDataCopyWithImpl<$Res>
    implements _$IntensityDataCopyWith<$Res> {
  __$IntensityDataCopyWithImpl(this._self, this._then);

  final _IntensityData _self;
  final $Res Function(_IntensityData) _then;

/// Create a copy of IntensityData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? estimated1RM = null,Object? currentWeight = null,Object? currentReps = null,Object? percentOf1RM = null,Object? formula = null,Object? confidence = null,Object? zone = null,}) {
  return _then(_IntensityData(
estimated1RM: null == estimated1RM ? _self.estimated1RM : estimated1RM // ignore: cast_nullable_to_non_nullable
as double,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,currentReps: null == currentReps ? _self.currentReps : currentReps // ignore: cast_nullable_to_non_nullable
as int,percentOf1RM: null == percentOf1RM ? _self.percentOf1RM : percentOf1RM // ignore: cast_nullable_to_non_nullable
as double,formula: null == formula ? _self.formula : formula // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as String,zone: null == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as IntensityZone,
  ));
}


}

/// @nodoc
mixin _$ExerciseAnalyticsData {

/// Exercise identifier
 String get exerciseId;/// Exercise name for display
 String get exerciseName;/// Weight progression data points (for L1 chart)
 List<ChartDataPoint> get weightHistory;/// Volume progression data points
 List<ChartDataPoint> get volumeHistory;/// RPE history (separate for correlations)
 List<ChartDataPoint> get rpeHistory;/// Trend analysis result
 TrendAnalysis get trend;/// Progressive overload analysis
 ProgressiveOverloadData get overload;/// Intensity/1RM analysis
 IntensityData get intensity;/// Correlation results (cached - not recalculated on each access)
 CorrelationResults get correlations;/// Last updated timestamp
 DateTime get lastUpdated;/// Number of sessions analyzed
 int get sessionCount;/// Time span of data (in days)
 int get dataSpanDays;
/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseAnalyticsDataCopyWith<ExerciseAnalyticsData> get copyWith => _$ExerciseAnalyticsDataCopyWithImpl<ExerciseAnalyticsData>(this as ExerciseAnalyticsData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseAnalyticsData&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&const DeepCollectionEquality().equals(other.weightHistory, weightHistory)&&const DeepCollectionEquality().equals(other.volumeHistory, volumeHistory)&&const DeepCollectionEquality().equals(other.rpeHistory, rpeHistory)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.overload, overload) || other.overload == overload)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.correlations, correlations) || other.correlations == correlations)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.dataSpanDays, dataSpanDays) || other.dataSpanDays == dataSpanDays));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,const DeepCollectionEquality().hash(weightHistory),const DeepCollectionEquality().hash(volumeHistory),const DeepCollectionEquality().hash(rpeHistory),trend,overload,intensity,correlations,lastUpdated,sessionCount,dataSpanDays);

@override
String toString() {
  return 'ExerciseAnalyticsData(exerciseId: $exerciseId, exerciseName: $exerciseName, weightHistory: $weightHistory, volumeHistory: $volumeHistory, rpeHistory: $rpeHistory, trend: $trend, overload: $overload, intensity: $intensity, correlations: $correlations, lastUpdated: $lastUpdated, sessionCount: $sessionCount, dataSpanDays: $dataSpanDays)';
}


}

/// @nodoc
abstract mixin class $ExerciseAnalyticsDataCopyWith<$Res>  {
  factory $ExerciseAnalyticsDataCopyWith(ExerciseAnalyticsData value, $Res Function(ExerciseAnalyticsData) _then) = _$ExerciseAnalyticsDataCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String exerciseName, List<ChartDataPoint> weightHistory, List<ChartDataPoint> volumeHistory, List<ChartDataPoint> rpeHistory, TrendAnalysis trend, ProgressiveOverloadData overload, IntensityData intensity, CorrelationResults correlations, DateTime lastUpdated, int sessionCount, int dataSpanDays
});


$ProgressiveOverloadDataCopyWith<$Res> get overload;$IntensityDataCopyWith<$Res> get intensity;$CorrelationResultsCopyWith<$Res> get correlations;

}
/// @nodoc
class _$ExerciseAnalyticsDataCopyWithImpl<$Res>
    implements $ExerciseAnalyticsDataCopyWith<$Res> {
  _$ExerciseAnalyticsDataCopyWithImpl(this._self, this._then);

  final ExerciseAnalyticsData _self;
  final $Res Function(ExerciseAnalyticsData) _then;

/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? weightHistory = null,Object? volumeHistory = null,Object? rpeHistory = null,Object? trend = null,Object? overload = null,Object? intensity = null,Object? correlations = null,Object? lastUpdated = null,Object? sessionCount = null,Object? dataSpanDays = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,weightHistory: null == weightHistory ? _self.weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,volumeHistory: null == volumeHistory ? _self.volumeHistory : volumeHistory // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,rpeHistory: null == rpeHistory ? _self.rpeHistory : rpeHistory // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as TrendAnalysis,overload: null == overload ? _self.overload : overload // ignore: cast_nullable_to_non_nullable
as ProgressiveOverloadData,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as IntensityData,correlations: null == correlations ? _self.correlations : correlations // ignore: cast_nullable_to_non_nullable
as CorrelationResults,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,dataSpanDays: null == dataSpanDays ? _self.dataSpanDays : dataSpanDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressiveOverloadDataCopyWith<$Res> get overload {
  
  return $ProgressiveOverloadDataCopyWith<$Res>(_self.overload, (value) {
    return _then(_self.copyWith(overload: value));
  });
}/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntensityDataCopyWith<$Res> get intensity {
  
  return $IntensityDataCopyWith<$Res>(_self.intensity, (value) {
    return _then(_self.copyWith(intensity: value));
  });
}/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultsCopyWith<$Res> get correlations {
  
  return $CorrelationResultsCopyWith<$Res>(_self.correlations, (value) {
    return _then(_self.copyWith(correlations: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExerciseAnalyticsData].
extension ExerciseAnalyticsDataPatterns on ExerciseAnalyticsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseAnalyticsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseAnalyticsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseAnalyticsData value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseAnalyticsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseAnalyticsData value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseAnalyticsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  List<ChartDataPoint> weightHistory,  List<ChartDataPoint> volumeHistory,  List<ChartDataPoint> rpeHistory,  TrendAnalysis trend,  ProgressiveOverloadData overload,  IntensityData intensity,  CorrelationResults correlations,  DateTime lastUpdated,  int sessionCount,  int dataSpanDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseAnalyticsData() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.weightHistory,_that.volumeHistory,_that.rpeHistory,_that.trend,_that.overload,_that.intensity,_that.correlations,_that.lastUpdated,_that.sessionCount,_that.dataSpanDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  List<ChartDataPoint> weightHistory,  List<ChartDataPoint> volumeHistory,  List<ChartDataPoint> rpeHistory,  TrendAnalysis trend,  ProgressiveOverloadData overload,  IntensityData intensity,  CorrelationResults correlations,  DateTime lastUpdated,  int sessionCount,  int dataSpanDays)  $default,) {final _that = this;
switch (_that) {
case _ExerciseAnalyticsData():
return $default(_that.exerciseId,_that.exerciseName,_that.weightHistory,_that.volumeHistory,_that.rpeHistory,_that.trend,_that.overload,_that.intensity,_that.correlations,_that.lastUpdated,_that.sessionCount,_that.dataSpanDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String exerciseName,  List<ChartDataPoint> weightHistory,  List<ChartDataPoint> volumeHistory,  List<ChartDataPoint> rpeHistory,  TrendAnalysis trend,  ProgressiveOverloadData overload,  IntensityData intensity,  CorrelationResults correlations,  DateTime lastUpdated,  int sessionCount,  int dataSpanDays)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseAnalyticsData() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.weightHistory,_that.volumeHistory,_that.rpeHistory,_that.trend,_that.overload,_that.intensity,_that.correlations,_that.lastUpdated,_that.sessionCount,_that.dataSpanDays);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseAnalyticsData extends ExerciseAnalyticsData {
  const _ExerciseAnalyticsData({required this.exerciseId, required this.exerciseName, required final  List<ChartDataPoint> weightHistory, required final  List<ChartDataPoint> volumeHistory, required final  List<ChartDataPoint> rpeHistory, required this.trend, required this.overload, required this.intensity, required this.correlations, required this.lastUpdated, this.sessionCount = 0, this.dataSpanDays = 0}): _weightHistory = weightHistory,_volumeHistory = volumeHistory,_rpeHistory = rpeHistory,super._();
  

/// Exercise identifier
@override final  String exerciseId;
/// Exercise name for display
@override final  String exerciseName;
/// Weight progression data points (for L1 chart)
 final  List<ChartDataPoint> _weightHistory;
/// Weight progression data points (for L1 chart)
@override List<ChartDataPoint> get weightHistory {
  if (_weightHistory is EqualUnmodifiableListView) return _weightHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weightHistory);
}

/// Volume progression data points
 final  List<ChartDataPoint> _volumeHistory;
/// Volume progression data points
@override List<ChartDataPoint> get volumeHistory {
  if (_volumeHistory is EqualUnmodifiableListView) return _volumeHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_volumeHistory);
}

/// RPE history (separate for correlations)
 final  List<ChartDataPoint> _rpeHistory;
/// RPE history (separate for correlations)
@override List<ChartDataPoint> get rpeHistory {
  if (_rpeHistory is EqualUnmodifiableListView) return _rpeHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rpeHistory);
}

/// Trend analysis result
@override final  TrendAnalysis trend;
/// Progressive overload analysis
@override final  ProgressiveOverloadData overload;
/// Intensity/1RM analysis
@override final  IntensityData intensity;
/// Correlation results (cached - not recalculated on each access)
@override final  CorrelationResults correlations;
/// Last updated timestamp
@override final  DateTime lastUpdated;
/// Number of sessions analyzed
@override@JsonKey() final  int sessionCount;
/// Time span of data (in days)
@override@JsonKey() final  int dataSpanDays;

/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseAnalyticsDataCopyWith<_ExerciseAnalyticsData> get copyWith => __$ExerciseAnalyticsDataCopyWithImpl<_ExerciseAnalyticsData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseAnalyticsData&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&const DeepCollectionEquality().equals(other._weightHistory, _weightHistory)&&const DeepCollectionEquality().equals(other._volumeHistory, _volumeHistory)&&const DeepCollectionEquality().equals(other._rpeHistory, _rpeHistory)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.overload, overload) || other.overload == overload)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.correlations, correlations) || other.correlations == correlations)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.dataSpanDays, dataSpanDays) || other.dataSpanDays == dataSpanDays));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,const DeepCollectionEquality().hash(_weightHistory),const DeepCollectionEquality().hash(_volumeHistory),const DeepCollectionEquality().hash(_rpeHistory),trend,overload,intensity,correlations,lastUpdated,sessionCount,dataSpanDays);

@override
String toString() {
  return 'ExerciseAnalyticsData(exerciseId: $exerciseId, exerciseName: $exerciseName, weightHistory: $weightHistory, volumeHistory: $volumeHistory, rpeHistory: $rpeHistory, trend: $trend, overload: $overload, intensity: $intensity, correlations: $correlations, lastUpdated: $lastUpdated, sessionCount: $sessionCount, dataSpanDays: $dataSpanDays)';
}


}

/// @nodoc
abstract mixin class _$ExerciseAnalyticsDataCopyWith<$Res> implements $ExerciseAnalyticsDataCopyWith<$Res> {
  factory _$ExerciseAnalyticsDataCopyWith(_ExerciseAnalyticsData value, $Res Function(_ExerciseAnalyticsData) _then) = __$ExerciseAnalyticsDataCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String exerciseName, List<ChartDataPoint> weightHistory, List<ChartDataPoint> volumeHistory, List<ChartDataPoint> rpeHistory, TrendAnalysis trend, ProgressiveOverloadData overload, IntensityData intensity, CorrelationResults correlations, DateTime lastUpdated, int sessionCount, int dataSpanDays
});


@override $ProgressiveOverloadDataCopyWith<$Res> get overload;@override $IntensityDataCopyWith<$Res> get intensity;@override $CorrelationResultsCopyWith<$Res> get correlations;

}
/// @nodoc
class __$ExerciseAnalyticsDataCopyWithImpl<$Res>
    implements _$ExerciseAnalyticsDataCopyWith<$Res> {
  __$ExerciseAnalyticsDataCopyWithImpl(this._self, this._then);

  final _ExerciseAnalyticsData _self;
  final $Res Function(_ExerciseAnalyticsData) _then;

/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? weightHistory = null,Object? volumeHistory = null,Object? rpeHistory = null,Object? trend = null,Object? overload = null,Object? intensity = null,Object? correlations = null,Object? lastUpdated = null,Object? sessionCount = null,Object? dataSpanDays = null,}) {
  return _then(_ExerciseAnalyticsData(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,weightHistory: null == weightHistory ? _self._weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,volumeHistory: null == volumeHistory ? _self._volumeHistory : volumeHistory // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,rpeHistory: null == rpeHistory ? _self._rpeHistory : rpeHistory // ignore: cast_nullable_to_non_nullable
as List<ChartDataPoint>,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as TrendAnalysis,overload: null == overload ? _self.overload : overload // ignore: cast_nullable_to_non_nullable
as ProgressiveOverloadData,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as IntensityData,correlations: null == correlations ? _self.correlations : correlations // ignore: cast_nullable_to_non_nullable
as CorrelationResults,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,dataSpanDays: null == dataSpanDays ? _self.dataSpanDays : dataSpanDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressiveOverloadDataCopyWith<$Res> get overload {
  
  return $ProgressiveOverloadDataCopyWith<$Res>(_self.overload, (value) {
    return _then(_self.copyWith(overload: value));
  });
}/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntensityDataCopyWith<$Res> get intensity {
  
  return $IntensityDataCopyWith<$Res>(_self.intensity, (value) {
    return _then(_self.copyWith(intensity: value));
  });
}/// Create a copy of ExerciseAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultsCopyWith<$Res> get correlations {
  
  return $CorrelationResultsCopyWith<$Res>(_self.correlations, (value) {
    return _then(_self.copyWith(correlations: value));
  });
}
}

// dart format on
