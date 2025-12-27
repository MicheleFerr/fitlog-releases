// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_calibration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalCalibration {

/// User ID for this calibration
 String get userId;// === FITNESS DECAY FACTORS (τ₁) ===
/// Age-based factor: 0.8-1.0
/// 20-30: 1.0, 40: 0.9, 50+: 0.8
 double get ageFactor;/// Training experience factor: 0.9-1.2
/// Novice: 1.2 (adapts faster), Advanced: 0.9
 double get trainingAgeFactor;/// Biological sex factor: 0.95-1.0
/// Male: 1.0, Female: 0.95 (hormonal differences)
 double get sexFactor;// === FATIGUE DECAY FACTORS (τ₂) ===
/// HRV-based factor: 0.8-1.3
/// High HRV (>70ms): 0.8 (fast recovery)
/// Low HRV (<40ms): 1.3 (slow recovery)
 double get hrvFactor;/// Sleep-based factor: 0.9-1.4
/// 7-9h: 1.0, <6h: 1.4 (slow recovery)
 double get sleepFactor;/// Injury-based factor: 1.0-1.3
/// None: 1.0, Active injury: 1.3
 double get injuryFactor;// === BASELINE VALUES ===
/// User's average HRV in milliseconds
/// Used to detect deviations from personal norm
 double? get baselineHrv;/// User's average sleep duration in hours
 double? get baselineSleepHours;/// User's resting heart rate
 double? get baselineRestingHr;// === METADATA ===
/// When calibration was last updated
 DateTime? get lastUpdated;/// How many data points were used for calibration
 int get dataPointsUsed;/// Confidence level: 0-1 (how reliable the calibration is)
 double get confidenceLevel;
/// Create a copy of PersonalCalibration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalCalibrationCopyWith<PersonalCalibration> get copyWith => _$PersonalCalibrationCopyWithImpl<PersonalCalibration>(this as PersonalCalibration, _$identity);

  /// Serializes this PersonalCalibration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalCalibration&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ageFactor, ageFactor) || other.ageFactor == ageFactor)&&(identical(other.trainingAgeFactor, trainingAgeFactor) || other.trainingAgeFactor == trainingAgeFactor)&&(identical(other.sexFactor, sexFactor) || other.sexFactor == sexFactor)&&(identical(other.hrvFactor, hrvFactor) || other.hrvFactor == hrvFactor)&&(identical(other.sleepFactor, sleepFactor) || other.sleepFactor == sleepFactor)&&(identical(other.injuryFactor, injuryFactor) || other.injuryFactor == injuryFactor)&&(identical(other.baselineHrv, baselineHrv) || other.baselineHrv == baselineHrv)&&(identical(other.baselineSleepHours, baselineSleepHours) || other.baselineSleepHours == baselineSleepHours)&&(identical(other.baselineRestingHr, baselineRestingHr) || other.baselineRestingHr == baselineRestingHr)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.dataPointsUsed, dataPointsUsed) || other.dataPointsUsed == dataPointsUsed)&&(identical(other.confidenceLevel, confidenceLevel) || other.confidenceLevel == confidenceLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,ageFactor,trainingAgeFactor,sexFactor,hrvFactor,sleepFactor,injuryFactor,baselineHrv,baselineSleepHours,baselineRestingHr,lastUpdated,dataPointsUsed,confidenceLevel);

@override
String toString() {
  return 'PersonalCalibration(userId: $userId, ageFactor: $ageFactor, trainingAgeFactor: $trainingAgeFactor, sexFactor: $sexFactor, hrvFactor: $hrvFactor, sleepFactor: $sleepFactor, injuryFactor: $injuryFactor, baselineHrv: $baselineHrv, baselineSleepHours: $baselineSleepHours, baselineRestingHr: $baselineRestingHr, lastUpdated: $lastUpdated, dataPointsUsed: $dataPointsUsed, confidenceLevel: $confidenceLevel)';
}


}

/// @nodoc
abstract mixin class $PersonalCalibrationCopyWith<$Res>  {
  factory $PersonalCalibrationCopyWith(PersonalCalibration value, $Res Function(PersonalCalibration) _then) = _$PersonalCalibrationCopyWithImpl;
@useResult
$Res call({
 String userId, double ageFactor, double trainingAgeFactor, double sexFactor, double hrvFactor, double sleepFactor, double injuryFactor, double? baselineHrv, double? baselineSleepHours, double? baselineRestingHr, DateTime? lastUpdated, int dataPointsUsed, double confidenceLevel
});




}
/// @nodoc
class _$PersonalCalibrationCopyWithImpl<$Res>
    implements $PersonalCalibrationCopyWith<$Res> {
  _$PersonalCalibrationCopyWithImpl(this._self, this._then);

  final PersonalCalibration _self;
  final $Res Function(PersonalCalibration) _then;

/// Create a copy of PersonalCalibration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? ageFactor = null,Object? trainingAgeFactor = null,Object? sexFactor = null,Object? hrvFactor = null,Object? sleepFactor = null,Object? injuryFactor = null,Object? baselineHrv = freezed,Object? baselineSleepHours = freezed,Object? baselineRestingHr = freezed,Object? lastUpdated = freezed,Object? dataPointsUsed = null,Object? confidenceLevel = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,ageFactor: null == ageFactor ? _self.ageFactor : ageFactor // ignore: cast_nullable_to_non_nullable
as double,trainingAgeFactor: null == trainingAgeFactor ? _self.trainingAgeFactor : trainingAgeFactor // ignore: cast_nullable_to_non_nullable
as double,sexFactor: null == sexFactor ? _self.sexFactor : sexFactor // ignore: cast_nullable_to_non_nullable
as double,hrvFactor: null == hrvFactor ? _self.hrvFactor : hrvFactor // ignore: cast_nullable_to_non_nullable
as double,sleepFactor: null == sleepFactor ? _self.sleepFactor : sleepFactor // ignore: cast_nullable_to_non_nullable
as double,injuryFactor: null == injuryFactor ? _self.injuryFactor : injuryFactor // ignore: cast_nullable_to_non_nullable
as double,baselineHrv: freezed == baselineHrv ? _self.baselineHrv : baselineHrv // ignore: cast_nullable_to_non_nullable
as double?,baselineSleepHours: freezed == baselineSleepHours ? _self.baselineSleepHours : baselineSleepHours // ignore: cast_nullable_to_non_nullable
as double?,baselineRestingHr: freezed == baselineRestingHr ? _self.baselineRestingHr : baselineRestingHr // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,dataPointsUsed: null == dataPointsUsed ? _self.dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as int,confidenceLevel: null == confidenceLevel ? _self.confidenceLevel : confidenceLevel // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalCalibration].
extension PersonalCalibrationPatterns on PersonalCalibration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalCalibration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalCalibration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalCalibration value)  $default,){
final _that = this;
switch (_that) {
case _PersonalCalibration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalCalibration value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalCalibration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  double ageFactor,  double trainingAgeFactor,  double sexFactor,  double hrvFactor,  double sleepFactor,  double injuryFactor,  double? baselineHrv,  double? baselineSleepHours,  double? baselineRestingHr,  DateTime? lastUpdated,  int dataPointsUsed,  double confidenceLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalCalibration() when $default != null:
return $default(_that.userId,_that.ageFactor,_that.trainingAgeFactor,_that.sexFactor,_that.hrvFactor,_that.sleepFactor,_that.injuryFactor,_that.baselineHrv,_that.baselineSleepHours,_that.baselineRestingHr,_that.lastUpdated,_that.dataPointsUsed,_that.confidenceLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  double ageFactor,  double trainingAgeFactor,  double sexFactor,  double hrvFactor,  double sleepFactor,  double injuryFactor,  double? baselineHrv,  double? baselineSleepHours,  double? baselineRestingHr,  DateTime? lastUpdated,  int dataPointsUsed,  double confidenceLevel)  $default,) {final _that = this;
switch (_that) {
case _PersonalCalibration():
return $default(_that.userId,_that.ageFactor,_that.trainingAgeFactor,_that.sexFactor,_that.hrvFactor,_that.sleepFactor,_that.injuryFactor,_that.baselineHrv,_that.baselineSleepHours,_that.baselineRestingHr,_that.lastUpdated,_that.dataPointsUsed,_that.confidenceLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  double ageFactor,  double trainingAgeFactor,  double sexFactor,  double hrvFactor,  double sleepFactor,  double injuryFactor,  double? baselineHrv,  double? baselineSleepHours,  double? baselineRestingHr,  DateTime? lastUpdated,  int dataPointsUsed,  double confidenceLevel)?  $default,) {final _that = this;
switch (_that) {
case _PersonalCalibration() when $default != null:
return $default(_that.userId,_that.ageFactor,_that.trainingAgeFactor,_that.sexFactor,_that.hrvFactor,_that.sleepFactor,_that.injuryFactor,_that.baselineHrv,_that.baselineSleepHours,_that.baselineRestingHr,_that.lastUpdated,_that.dataPointsUsed,_that.confidenceLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalCalibration extends PersonalCalibration {
  const _PersonalCalibration({required this.userId, this.ageFactor = 1.0, this.trainingAgeFactor = 1.0, this.sexFactor = 1.0, this.hrvFactor = 1.0, this.sleepFactor = 1.0, this.injuryFactor = 1.0, this.baselineHrv, this.baselineSleepHours, this.baselineRestingHr, this.lastUpdated, this.dataPointsUsed = 0, this.confidenceLevel = 0.5}): super._();
  factory _PersonalCalibration.fromJson(Map<String, dynamic> json) => _$PersonalCalibrationFromJson(json);

/// User ID for this calibration
@override final  String userId;
// === FITNESS DECAY FACTORS (τ₁) ===
/// Age-based factor: 0.8-1.0
/// 20-30: 1.0, 40: 0.9, 50+: 0.8
@override@JsonKey() final  double ageFactor;
/// Training experience factor: 0.9-1.2
/// Novice: 1.2 (adapts faster), Advanced: 0.9
@override@JsonKey() final  double trainingAgeFactor;
/// Biological sex factor: 0.95-1.0
/// Male: 1.0, Female: 0.95 (hormonal differences)
@override@JsonKey() final  double sexFactor;
// === FATIGUE DECAY FACTORS (τ₂) ===
/// HRV-based factor: 0.8-1.3
/// High HRV (>70ms): 0.8 (fast recovery)
/// Low HRV (<40ms): 1.3 (slow recovery)
@override@JsonKey() final  double hrvFactor;
/// Sleep-based factor: 0.9-1.4
/// 7-9h: 1.0, <6h: 1.4 (slow recovery)
@override@JsonKey() final  double sleepFactor;
/// Injury-based factor: 1.0-1.3
/// None: 1.0, Active injury: 1.3
@override@JsonKey() final  double injuryFactor;
// === BASELINE VALUES ===
/// User's average HRV in milliseconds
/// Used to detect deviations from personal norm
@override final  double? baselineHrv;
/// User's average sleep duration in hours
@override final  double? baselineSleepHours;
/// User's resting heart rate
@override final  double? baselineRestingHr;
// === METADATA ===
/// When calibration was last updated
@override final  DateTime? lastUpdated;
/// How many data points were used for calibration
@override@JsonKey() final  int dataPointsUsed;
/// Confidence level: 0-1 (how reliable the calibration is)
@override@JsonKey() final  double confidenceLevel;

/// Create a copy of PersonalCalibration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalCalibrationCopyWith<_PersonalCalibration> get copyWith => __$PersonalCalibrationCopyWithImpl<_PersonalCalibration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalCalibrationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalCalibration&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ageFactor, ageFactor) || other.ageFactor == ageFactor)&&(identical(other.trainingAgeFactor, trainingAgeFactor) || other.trainingAgeFactor == trainingAgeFactor)&&(identical(other.sexFactor, sexFactor) || other.sexFactor == sexFactor)&&(identical(other.hrvFactor, hrvFactor) || other.hrvFactor == hrvFactor)&&(identical(other.sleepFactor, sleepFactor) || other.sleepFactor == sleepFactor)&&(identical(other.injuryFactor, injuryFactor) || other.injuryFactor == injuryFactor)&&(identical(other.baselineHrv, baselineHrv) || other.baselineHrv == baselineHrv)&&(identical(other.baselineSleepHours, baselineSleepHours) || other.baselineSleepHours == baselineSleepHours)&&(identical(other.baselineRestingHr, baselineRestingHr) || other.baselineRestingHr == baselineRestingHr)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.dataPointsUsed, dataPointsUsed) || other.dataPointsUsed == dataPointsUsed)&&(identical(other.confidenceLevel, confidenceLevel) || other.confidenceLevel == confidenceLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,ageFactor,trainingAgeFactor,sexFactor,hrvFactor,sleepFactor,injuryFactor,baselineHrv,baselineSleepHours,baselineRestingHr,lastUpdated,dataPointsUsed,confidenceLevel);

@override
String toString() {
  return 'PersonalCalibration(userId: $userId, ageFactor: $ageFactor, trainingAgeFactor: $trainingAgeFactor, sexFactor: $sexFactor, hrvFactor: $hrvFactor, sleepFactor: $sleepFactor, injuryFactor: $injuryFactor, baselineHrv: $baselineHrv, baselineSleepHours: $baselineSleepHours, baselineRestingHr: $baselineRestingHr, lastUpdated: $lastUpdated, dataPointsUsed: $dataPointsUsed, confidenceLevel: $confidenceLevel)';
}


}

/// @nodoc
abstract mixin class _$PersonalCalibrationCopyWith<$Res> implements $PersonalCalibrationCopyWith<$Res> {
  factory _$PersonalCalibrationCopyWith(_PersonalCalibration value, $Res Function(_PersonalCalibration) _then) = __$PersonalCalibrationCopyWithImpl;
@override @useResult
$Res call({
 String userId, double ageFactor, double trainingAgeFactor, double sexFactor, double hrvFactor, double sleepFactor, double injuryFactor, double? baselineHrv, double? baselineSleepHours, double? baselineRestingHr, DateTime? lastUpdated, int dataPointsUsed, double confidenceLevel
});




}
/// @nodoc
class __$PersonalCalibrationCopyWithImpl<$Res>
    implements _$PersonalCalibrationCopyWith<$Res> {
  __$PersonalCalibrationCopyWithImpl(this._self, this._then);

  final _PersonalCalibration _self;
  final $Res Function(_PersonalCalibration) _then;

/// Create a copy of PersonalCalibration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? ageFactor = null,Object? trainingAgeFactor = null,Object? sexFactor = null,Object? hrvFactor = null,Object? sleepFactor = null,Object? injuryFactor = null,Object? baselineHrv = freezed,Object? baselineSleepHours = freezed,Object? baselineRestingHr = freezed,Object? lastUpdated = freezed,Object? dataPointsUsed = null,Object? confidenceLevel = null,}) {
  return _then(_PersonalCalibration(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,ageFactor: null == ageFactor ? _self.ageFactor : ageFactor // ignore: cast_nullable_to_non_nullable
as double,trainingAgeFactor: null == trainingAgeFactor ? _self.trainingAgeFactor : trainingAgeFactor // ignore: cast_nullable_to_non_nullable
as double,sexFactor: null == sexFactor ? _self.sexFactor : sexFactor // ignore: cast_nullable_to_non_nullable
as double,hrvFactor: null == hrvFactor ? _self.hrvFactor : hrvFactor // ignore: cast_nullable_to_non_nullable
as double,sleepFactor: null == sleepFactor ? _self.sleepFactor : sleepFactor // ignore: cast_nullable_to_non_nullable
as double,injuryFactor: null == injuryFactor ? _self.injuryFactor : injuryFactor // ignore: cast_nullable_to_non_nullable
as double,baselineHrv: freezed == baselineHrv ? _self.baselineHrv : baselineHrv // ignore: cast_nullable_to_non_nullable
as double?,baselineSleepHours: freezed == baselineSleepHours ? _self.baselineSleepHours : baselineSleepHours // ignore: cast_nullable_to_non_nullable
as double?,baselineRestingHr: freezed == baselineRestingHr ? _self.baselineRestingHr : baselineRestingHr // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,dataPointsUsed: null == dataPointsUsed ? _self.dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as int,confidenceLevel: null == confidenceLevel ? _self.confidenceLevel : confidenceLevel // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
