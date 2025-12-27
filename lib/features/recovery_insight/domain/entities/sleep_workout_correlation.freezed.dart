// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_workout_correlation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SleepWorkoutCorrelation {

/// Volume change when sleeping >7h (e.g., +8%)
 double get volumeChangeAbove7h;/// Volume change when sleeping <6h (e.g., -15%)
 double get volumeChangeBelow6h;/// Number of workout sessions analyzed
 int get workoutSampleSize;/// Number of nights with sleep data
 int get sleepSampleSize;/// Whether correlation is statistically significant
/// (requires >10 data points in each category)
 bool get isSignificant;/// Period analyzed (in days)
 int get periodDays;/// Workouts with >7h sleep the night before
 int get workoutsWithGoodSleep;/// Workouts with <6h sleep the night before
 int get workoutsWithPoorSleep;/// User's detected sleep pattern
 SleepPattern get sleepPattern;/// Average sleep hours over the period
 double get averageSleepHours;/// Average workout volume (for stats display)
 double get averageVolume;
/// Create a copy of SleepWorkoutCorrelation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepWorkoutCorrelationCopyWith<SleepWorkoutCorrelation> get copyWith => _$SleepWorkoutCorrelationCopyWithImpl<SleepWorkoutCorrelation>(this as SleepWorkoutCorrelation, _$identity);

  /// Serializes this SleepWorkoutCorrelation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepWorkoutCorrelation&&(identical(other.volumeChangeAbove7h, volumeChangeAbove7h) || other.volumeChangeAbove7h == volumeChangeAbove7h)&&(identical(other.volumeChangeBelow6h, volumeChangeBelow6h) || other.volumeChangeBelow6h == volumeChangeBelow6h)&&(identical(other.workoutSampleSize, workoutSampleSize) || other.workoutSampleSize == workoutSampleSize)&&(identical(other.sleepSampleSize, sleepSampleSize) || other.sleepSampleSize == sleepSampleSize)&&(identical(other.isSignificant, isSignificant) || other.isSignificant == isSignificant)&&(identical(other.periodDays, periodDays) || other.periodDays == periodDays)&&(identical(other.workoutsWithGoodSleep, workoutsWithGoodSleep) || other.workoutsWithGoodSleep == workoutsWithGoodSleep)&&(identical(other.workoutsWithPoorSleep, workoutsWithPoorSleep) || other.workoutsWithPoorSleep == workoutsWithPoorSleep)&&(identical(other.sleepPattern, sleepPattern) || other.sleepPattern == sleepPattern)&&(identical(other.averageSleepHours, averageSleepHours) || other.averageSleepHours == averageSleepHours)&&(identical(other.averageVolume, averageVolume) || other.averageVolume == averageVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,volumeChangeAbove7h,volumeChangeBelow6h,workoutSampleSize,sleepSampleSize,isSignificant,periodDays,workoutsWithGoodSleep,workoutsWithPoorSleep,sleepPattern,averageSleepHours,averageVolume);

@override
String toString() {
  return 'SleepWorkoutCorrelation(volumeChangeAbove7h: $volumeChangeAbove7h, volumeChangeBelow6h: $volumeChangeBelow6h, workoutSampleSize: $workoutSampleSize, sleepSampleSize: $sleepSampleSize, isSignificant: $isSignificant, periodDays: $periodDays, workoutsWithGoodSleep: $workoutsWithGoodSleep, workoutsWithPoorSleep: $workoutsWithPoorSleep, sleepPattern: $sleepPattern, averageSleepHours: $averageSleepHours, averageVolume: $averageVolume)';
}


}

/// @nodoc
abstract mixin class $SleepWorkoutCorrelationCopyWith<$Res>  {
  factory $SleepWorkoutCorrelationCopyWith(SleepWorkoutCorrelation value, $Res Function(SleepWorkoutCorrelation) _then) = _$SleepWorkoutCorrelationCopyWithImpl;
@useResult
$Res call({
 double volumeChangeAbove7h, double volumeChangeBelow6h, int workoutSampleSize, int sleepSampleSize, bool isSignificant, int periodDays, int workoutsWithGoodSleep, int workoutsWithPoorSleep, SleepPattern sleepPattern, double averageSleepHours, double averageVolume
});




}
/// @nodoc
class _$SleepWorkoutCorrelationCopyWithImpl<$Res>
    implements $SleepWorkoutCorrelationCopyWith<$Res> {
  _$SleepWorkoutCorrelationCopyWithImpl(this._self, this._then);

  final SleepWorkoutCorrelation _self;
  final $Res Function(SleepWorkoutCorrelation) _then;

/// Create a copy of SleepWorkoutCorrelation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? volumeChangeAbove7h = null,Object? volumeChangeBelow6h = null,Object? workoutSampleSize = null,Object? sleepSampleSize = null,Object? isSignificant = null,Object? periodDays = null,Object? workoutsWithGoodSleep = null,Object? workoutsWithPoorSleep = null,Object? sleepPattern = null,Object? averageSleepHours = null,Object? averageVolume = null,}) {
  return _then(_self.copyWith(
volumeChangeAbove7h: null == volumeChangeAbove7h ? _self.volumeChangeAbove7h : volumeChangeAbove7h // ignore: cast_nullable_to_non_nullable
as double,volumeChangeBelow6h: null == volumeChangeBelow6h ? _self.volumeChangeBelow6h : volumeChangeBelow6h // ignore: cast_nullable_to_non_nullable
as double,workoutSampleSize: null == workoutSampleSize ? _self.workoutSampleSize : workoutSampleSize // ignore: cast_nullable_to_non_nullable
as int,sleepSampleSize: null == sleepSampleSize ? _self.sleepSampleSize : sleepSampleSize // ignore: cast_nullable_to_non_nullable
as int,isSignificant: null == isSignificant ? _self.isSignificant : isSignificant // ignore: cast_nullable_to_non_nullable
as bool,periodDays: null == periodDays ? _self.periodDays : periodDays // ignore: cast_nullable_to_non_nullable
as int,workoutsWithGoodSleep: null == workoutsWithGoodSleep ? _self.workoutsWithGoodSleep : workoutsWithGoodSleep // ignore: cast_nullable_to_non_nullable
as int,workoutsWithPoorSleep: null == workoutsWithPoorSleep ? _self.workoutsWithPoorSleep : workoutsWithPoorSleep // ignore: cast_nullable_to_non_nullable
as int,sleepPattern: null == sleepPattern ? _self.sleepPattern : sleepPattern // ignore: cast_nullable_to_non_nullable
as SleepPattern,averageSleepHours: null == averageSleepHours ? _self.averageSleepHours : averageSleepHours // ignore: cast_nullable_to_non_nullable
as double,averageVolume: null == averageVolume ? _self.averageVolume : averageVolume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SleepWorkoutCorrelation].
extension SleepWorkoutCorrelationPatterns on SleepWorkoutCorrelation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SleepWorkoutCorrelation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SleepWorkoutCorrelation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SleepWorkoutCorrelation value)  $default,){
final _that = this;
switch (_that) {
case _SleepWorkoutCorrelation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SleepWorkoutCorrelation value)?  $default,){
final _that = this;
switch (_that) {
case _SleepWorkoutCorrelation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double volumeChangeAbove7h,  double volumeChangeBelow6h,  int workoutSampleSize,  int sleepSampleSize,  bool isSignificant,  int periodDays,  int workoutsWithGoodSleep,  int workoutsWithPoorSleep,  SleepPattern sleepPattern,  double averageSleepHours,  double averageVolume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SleepWorkoutCorrelation() when $default != null:
return $default(_that.volumeChangeAbove7h,_that.volumeChangeBelow6h,_that.workoutSampleSize,_that.sleepSampleSize,_that.isSignificant,_that.periodDays,_that.workoutsWithGoodSleep,_that.workoutsWithPoorSleep,_that.sleepPattern,_that.averageSleepHours,_that.averageVolume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double volumeChangeAbove7h,  double volumeChangeBelow6h,  int workoutSampleSize,  int sleepSampleSize,  bool isSignificant,  int periodDays,  int workoutsWithGoodSleep,  int workoutsWithPoorSleep,  SleepPattern sleepPattern,  double averageSleepHours,  double averageVolume)  $default,) {final _that = this;
switch (_that) {
case _SleepWorkoutCorrelation():
return $default(_that.volumeChangeAbove7h,_that.volumeChangeBelow6h,_that.workoutSampleSize,_that.sleepSampleSize,_that.isSignificant,_that.periodDays,_that.workoutsWithGoodSleep,_that.workoutsWithPoorSleep,_that.sleepPattern,_that.averageSleepHours,_that.averageVolume);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double volumeChangeAbove7h,  double volumeChangeBelow6h,  int workoutSampleSize,  int sleepSampleSize,  bool isSignificant,  int periodDays,  int workoutsWithGoodSleep,  int workoutsWithPoorSleep,  SleepPattern sleepPattern,  double averageSleepHours,  double averageVolume)?  $default,) {final _that = this;
switch (_that) {
case _SleepWorkoutCorrelation() when $default != null:
return $default(_that.volumeChangeAbove7h,_that.volumeChangeBelow6h,_that.workoutSampleSize,_that.sleepSampleSize,_that.isSignificant,_that.periodDays,_that.workoutsWithGoodSleep,_that.workoutsWithPoorSleep,_that.sleepPattern,_that.averageSleepHours,_that.averageVolume);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SleepWorkoutCorrelation extends SleepWorkoutCorrelation {
  const _SleepWorkoutCorrelation({required this.volumeChangeAbove7h, required this.volumeChangeBelow6h, required this.workoutSampleSize, required this.sleepSampleSize, required this.isSignificant, this.periodDays = 30, this.workoutsWithGoodSleep = 0, this.workoutsWithPoorSleep = 0, this.sleepPattern = SleepPattern.unknown, this.averageSleepHours = 0.0, this.averageVolume = 0.0}): super._();
  factory _SleepWorkoutCorrelation.fromJson(Map<String, dynamic> json) => _$SleepWorkoutCorrelationFromJson(json);

/// Volume change when sleeping >7h (e.g., +8%)
@override final  double volumeChangeAbove7h;
/// Volume change when sleeping <6h (e.g., -15%)
@override final  double volumeChangeBelow6h;
/// Number of workout sessions analyzed
@override final  int workoutSampleSize;
/// Number of nights with sleep data
@override final  int sleepSampleSize;
/// Whether correlation is statistically significant
/// (requires >10 data points in each category)
@override final  bool isSignificant;
/// Period analyzed (in days)
@override@JsonKey() final  int periodDays;
/// Workouts with >7h sleep the night before
@override@JsonKey() final  int workoutsWithGoodSleep;
/// Workouts with <6h sleep the night before
@override@JsonKey() final  int workoutsWithPoorSleep;
/// User's detected sleep pattern
@override@JsonKey() final  SleepPattern sleepPattern;
/// Average sleep hours over the period
@override@JsonKey() final  double averageSleepHours;
/// Average workout volume (for stats display)
@override@JsonKey() final  double averageVolume;

/// Create a copy of SleepWorkoutCorrelation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SleepWorkoutCorrelationCopyWith<_SleepWorkoutCorrelation> get copyWith => __$SleepWorkoutCorrelationCopyWithImpl<_SleepWorkoutCorrelation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SleepWorkoutCorrelationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SleepWorkoutCorrelation&&(identical(other.volumeChangeAbove7h, volumeChangeAbove7h) || other.volumeChangeAbove7h == volumeChangeAbove7h)&&(identical(other.volumeChangeBelow6h, volumeChangeBelow6h) || other.volumeChangeBelow6h == volumeChangeBelow6h)&&(identical(other.workoutSampleSize, workoutSampleSize) || other.workoutSampleSize == workoutSampleSize)&&(identical(other.sleepSampleSize, sleepSampleSize) || other.sleepSampleSize == sleepSampleSize)&&(identical(other.isSignificant, isSignificant) || other.isSignificant == isSignificant)&&(identical(other.periodDays, periodDays) || other.periodDays == periodDays)&&(identical(other.workoutsWithGoodSleep, workoutsWithGoodSleep) || other.workoutsWithGoodSleep == workoutsWithGoodSleep)&&(identical(other.workoutsWithPoorSleep, workoutsWithPoorSleep) || other.workoutsWithPoorSleep == workoutsWithPoorSleep)&&(identical(other.sleepPattern, sleepPattern) || other.sleepPattern == sleepPattern)&&(identical(other.averageSleepHours, averageSleepHours) || other.averageSleepHours == averageSleepHours)&&(identical(other.averageVolume, averageVolume) || other.averageVolume == averageVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,volumeChangeAbove7h,volumeChangeBelow6h,workoutSampleSize,sleepSampleSize,isSignificant,periodDays,workoutsWithGoodSleep,workoutsWithPoorSleep,sleepPattern,averageSleepHours,averageVolume);

@override
String toString() {
  return 'SleepWorkoutCorrelation(volumeChangeAbove7h: $volumeChangeAbove7h, volumeChangeBelow6h: $volumeChangeBelow6h, workoutSampleSize: $workoutSampleSize, sleepSampleSize: $sleepSampleSize, isSignificant: $isSignificant, periodDays: $periodDays, workoutsWithGoodSleep: $workoutsWithGoodSleep, workoutsWithPoorSleep: $workoutsWithPoorSleep, sleepPattern: $sleepPattern, averageSleepHours: $averageSleepHours, averageVolume: $averageVolume)';
}


}

/// @nodoc
abstract mixin class _$SleepWorkoutCorrelationCopyWith<$Res> implements $SleepWorkoutCorrelationCopyWith<$Res> {
  factory _$SleepWorkoutCorrelationCopyWith(_SleepWorkoutCorrelation value, $Res Function(_SleepWorkoutCorrelation) _then) = __$SleepWorkoutCorrelationCopyWithImpl;
@override @useResult
$Res call({
 double volumeChangeAbove7h, double volumeChangeBelow6h, int workoutSampleSize, int sleepSampleSize, bool isSignificant, int periodDays, int workoutsWithGoodSleep, int workoutsWithPoorSleep, SleepPattern sleepPattern, double averageSleepHours, double averageVolume
});




}
/// @nodoc
class __$SleepWorkoutCorrelationCopyWithImpl<$Res>
    implements _$SleepWorkoutCorrelationCopyWith<$Res> {
  __$SleepWorkoutCorrelationCopyWithImpl(this._self, this._then);

  final _SleepWorkoutCorrelation _self;
  final $Res Function(_SleepWorkoutCorrelation) _then;

/// Create a copy of SleepWorkoutCorrelation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? volumeChangeAbove7h = null,Object? volumeChangeBelow6h = null,Object? workoutSampleSize = null,Object? sleepSampleSize = null,Object? isSignificant = null,Object? periodDays = null,Object? workoutsWithGoodSleep = null,Object? workoutsWithPoorSleep = null,Object? sleepPattern = null,Object? averageSleepHours = null,Object? averageVolume = null,}) {
  return _then(_SleepWorkoutCorrelation(
volumeChangeAbove7h: null == volumeChangeAbove7h ? _self.volumeChangeAbove7h : volumeChangeAbove7h // ignore: cast_nullable_to_non_nullable
as double,volumeChangeBelow6h: null == volumeChangeBelow6h ? _self.volumeChangeBelow6h : volumeChangeBelow6h // ignore: cast_nullable_to_non_nullable
as double,workoutSampleSize: null == workoutSampleSize ? _self.workoutSampleSize : workoutSampleSize // ignore: cast_nullable_to_non_nullable
as int,sleepSampleSize: null == sleepSampleSize ? _self.sleepSampleSize : sleepSampleSize // ignore: cast_nullable_to_non_nullable
as int,isSignificant: null == isSignificant ? _self.isSignificant : isSignificant // ignore: cast_nullable_to_non_nullable
as bool,periodDays: null == periodDays ? _self.periodDays : periodDays // ignore: cast_nullable_to_non_nullable
as int,workoutsWithGoodSleep: null == workoutsWithGoodSleep ? _self.workoutsWithGoodSleep : workoutsWithGoodSleep // ignore: cast_nullable_to_non_nullable
as int,workoutsWithPoorSleep: null == workoutsWithPoorSleep ? _self.workoutsWithPoorSleep : workoutsWithPoorSleep // ignore: cast_nullable_to_non_nullable
as int,sleepPattern: null == sleepPattern ? _self.sleepPattern : sleepPattern // ignore: cast_nullable_to_non_nullable
as SleepPattern,averageSleepHours: null == averageSleepHours ? _self.averageSleepHours : averageSleepHours // ignore: cast_nullable_to_non_nullable
as double,averageVolume: null == averageVolume ? _self.averageVolume : averageVolume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SleepWorkoutDataPoint {

/// Date of the workout
 DateTime get workoutDate;/// Sleep hours the night before
 double get sleepHours;/// Total workout volume (sets × reps × weight)
 double get workoutVolume;/// Workout duration in minutes
 int get workoutDurationMinutes;/// Number of exercises
 int get exerciseCount;/// Average RPE if available
 double? get averageRpe;
/// Create a copy of SleepWorkoutDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepWorkoutDataPointCopyWith<SleepWorkoutDataPoint> get copyWith => _$SleepWorkoutDataPointCopyWithImpl<SleepWorkoutDataPoint>(this as SleepWorkoutDataPoint, _$identity);

  /// Serializes this SleepWorkoutDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepWorkoutDataPoint&&(identical(other.workoutDate, workoutDate) || other.workoutDate == workoutDate)&&(identical(other.sleepHours, sleepHours) || other.sleepHours == sleepHours)&&(identical(other.workoutVolume, workoutVolume) || other.workoutVolume == workoutVolume)&&(identical(other.workoutDurationMinutes, workoutDurationMinutes) || other.workoutDurationMinutes == workoutDurationMinutes)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.averageRpe, averageRpe) || other.averageRpe == averageRpe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutDate,sleepHours,workoutVolume,workoutDurationMinutes,exerciseCount,averageRpe);

@override
String toString() {
  return 'SleepWorkoutDataPoint(workoutDate: $workoutDate, sleepHours: $sleepHours, workoutVolume: $workoutVolume, workoutDurationMinutes: $workoutDurationMinutes, exerciseCount: $exerciseCount, averageRpe: $averageRpe)';
}


}

/// @nodoc
abstract mixin class $SleepWorkoutDataPointCopyWith<$Res>  {
  factory $SleepWorkoutDataPointCopyWith(SleepWorkoutDataPoint value, $Res Function(SleepWorkoutDataPoint) _then) = _$SleepWorkoutDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime workoutDate, double sleepHours, double workoutVolume, int workoutDurationMinutes, int exerciseCount, double? averageRpe
});




}
/// @nodoc
class _$SleepWorkoutDataPointCopyWithImpl<$Res>
    implements $SleepWorkoutDataPointCopyWith<$Res> {
  _$SleepWorkoutDataPointCopyWithImpl(this._self, this._then);

  final SleepWorkoutDataPoint _self;
  final $Res Function(SleepWorkoutDataPoint) _then;

/// Create a copy of SleepWorkoutDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutDate = null,Object? sleepHours = null,Object? workoutVolume = null,Object? workoutDurationMinutes = null,Object? exerciseCount = null,Object? averageRpe = freezed,}) {
  return _then(_self.copyWith(
workoutDate: null == workoutDate ? _self.workoutDate : workoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,sleepHours: null == sleepHours ? _self.sleepHours : sleepHours // ignore: cast_nullable_to_non_nullable
as double,workoutVolume: null == workoutVolume ? _self.workoutVolume : workoutVolume // ignore: cast_nullable_to_non_nullable
as double,workoutDurationMinutes: null == workoutDurationMinutes ? _self.workoutDurationMinutes : workoutDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,averageRpe: freezed == averageRpe ? _self.averageRpe : averageRpe // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SleepWorkoutDataPoint].
extension SleepWorkoutDataPointPatterns on SleepWorkoutDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SleepWorkoutDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SleepWorkoutDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SleepWorkoutDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _SleepWorkoutDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SleepWorkoutDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _SleepWorkoutDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime workoutDate,  double sleepHours,  double workoutVolume,  int workoutDurationMinutes,  int exerciseCount,  double? averageRpe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SleepWorkoutDataPoint() when $default != null:
return $default(_that.workoutDate,_that.sleepHours,_that.workoutVolume,_that.workoutDurationMinutes,_that.exerciseCount,_that.averageRpe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime workoutDate,  double sleepHours,  double workoutVolume,  int workoutDurationMinutes,  int exerciseCount,  double? averageRpe)  $default,) {final _that = this;
switch (_that) {
case _SleepWorkoutDataPoint():
return $default(_that.workoutDate,_that.sleepHours,_that.workoutVolume,_that.workoutDurationMinutes,_that.exerciseCount,_that.averageRpe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime workoutDate,  double sleepHours,  double workoutVolume,  int workoutDurationMinutes,  int exerciseCount,  double? averageRpe)?  $default,) {final _that = this;
switch (_that) {
case _SleepWorkoutDataPoint() when $default != null:
return $default(_that.workoutDate,_that.sleepHours,_that.workoutVolume,_that.workoutDurationMinutes,_that.exerciseCount,_that.averageRpe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SleepWorkoutDataPoint extends SleepWorkoutDataPoint {
  const _SleepWorkoutDataPoint({required this.workoutDate, required this.sleepHours, required this.workoutVolume, required this.workoutDurationMinutes, required this.exerciseCount, this.averageRpe}): super._();
  factory _SleepWorkoutDataPoint.fromJson(Map<String, dynamic> json) => _$SleepWorkoutDataPointFromJson(json);

/// Date of the workout
@override final  DateTime workoutDate;
/// Sleep hours the night before
@override final  double sleepHours;
/// Total workout volume (sets × reps × weight)
@override final  double workoutVolume;
/// Workout duration in minutes
@override final  int workoutDurationMinutes;
/// Number of exercises
@override final  int exerciseCount;
/// Average RPE if available
@override final  double? averageRpe;

/// Create a copy of SleepWorkoutDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SleepWorkoutDataPointCopyWith<_SleepWorkoutDataPoint> get copyWith => __$SleepWorkoutDataPointCopyWithImpl<_SleepWorkoutDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SleepWorkoutDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SleepWorkoutDataPoint&&(identical(other.workoutDate, workoutDate) || other.workoutDate == workoutDate)&&(identical(other.sleepHours, sleepHours) || other.sleepHours == sleepHours)&&(identical(other.workoutVolume, workoutVolume) || other.workoutVolume == workoutVolume)&&(identical(other.workoutDurationMinutes, workoutDurationMinutes) || other.workoutDurationMinutes == workoutDurationMinutes)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.averageRpe, averageRpe) || other.averageRpe == averageRpe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutDate,sleepHours,workoutVolume,workoutDurationMinutes,exerciseCount,averageRpe);

@override
String toString() {
  return 'SleepWorkoutDataPoint(workoutDate: $workoutDate, sleepHours: $sleepHours, workoutVolume: $workoutVolume, workoutDurationMinutes: $workoutDurationMinutes, exerciseCount: $exerciseCount, averageRpe: $averageRpe)';
}


}

/// @nodoc
abstract mixin class _$SleepWorkoutDataPointCopyWith<$Res> implements $SleepWorkoutDataPointCopyWith<$Res> {
  factory _$SleepWorkoutDataPointCopyWith(_SleepWorkoutDataPoint value, $Res Function(_SleepWorkoutDataPoint) _then) = __$SleepWorkoutDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime workoutDate, double sleepHours, double workoutVolume, int workoutDurationMinutes, int exerciseCount, double? averageRpe
});




}
/// @nodoc
class __$SleepWorkoutDataPointCopyWithImpl<$Res>
    implements _$SleepWorkoutDataPointCopyWith<$Res> {
  __$SleepWorkoutDataPointCopyWithImpl(this._self, this._then);

  final _SleepWorkoutDataPoint _self;
  final $Res Function(_SleepWorkoutDataPoint) _then;

/// Create a copy of SleepWorkoutDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutDate = null,Object? sleepHours = null,Object? workoutVolume = null,Object? workoutDurationMinutes = null,Object? exerciseCount = null,Object? averageRpe = freezed,}) {
  return _then(_SleepWorkoutDataPoint(
workoutDate: null == workoutDate ? _self.workoutDate : workoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,sleepHours: null == sleepHours ? _self.sleepHours : sleepHours // ignore: cast_nullable_to_non_nullable
as double,workoutVolume: null == workoutVolume ? _self.workoutVolume : workoutVolume // ignore: cast_nullable_to_non_nullable
as double,workoutDurationMinutes: null == workoutDurationMinutes ? _self.workoutDurationMinutes : workoutDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,exerciseCount: null == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int,averageRpe: freezed == averageRpe ? _self.averageRpe : averageRpe // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
