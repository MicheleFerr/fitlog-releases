// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overtraining_risk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OvertrainingRisk {

/// Overall risk level for overtraining
 RiskLevel get riskLevel;/// TSB (Training Stress Balance) score
///
/// **Interpretation**:
/// - TSB > 0: Fresh, well-recovered
/// - TSB 0 to -10: Normal training load
/// - TSB -10 to -20: Approaching overreaching
/// - TSB < -20: Overtraining risk (deload needed)
///
/// **Formula**: TSB = Chronic Training Load - Acute Training Load
 double get tsbScore;/// HRV (Heart Rate Variability) deviation from baseline (%)
///
/// **Interpretation**:
/// - HRV deviation > +5%: Excellent recovery
/// - HRV deviation 0% to +5%: Good recovery
/// - HRV deviation -5% to 0%: Acceptable recovery
/// - HRV deviation -10% to -5%: Low recovery (monitor)
/// - HRV deviation < -10%: Very low recovery (rest needed)
///
/// **Note**: Negative values indicate HRV below personal baseline
 double get hrvDeviation;/// Human-readable recommendation based on risk assessment
///
/// **Examples**:
/// - "Well-recovered! Continue current training load."
/// - "Monitor recovery. Consider reducing volume next week."
/// - "High overtraining risk. Deload week recommended."
/// - "Very high risk. Take 3-5 days complete rest."
 String get recommendation;/// Optional: Detailed breakdown of risk factors
 RiskFactors? get factors;/// Timestamp when risk was calculated
 DateTime? get calculatedAt;
/// Create a copy of OvertrainingRisk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OvertrainingRiskCopyWith<OvertrainingRisk> get copyWith => _$OvertrainingRiskCopyWithImpl<OvertrainingRisk>(this as OvertrainingRisk, _$identity);

  /// Serializes this OvertrainingRisk to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OvertrainingRisk&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.tsbScore, tsbScore) || other.tsbScore == tsbScore)&&(identical(other.hrvDeviation, hrvDeviation) || other.hrvDeviation == hrvDeviation)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.factors, factors) || other.factors == factors)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,riskLevel,tsbScore,hrvDeviation,recommendation,factors,calculatedAt);

@override
String toString() {
  return 'OvertrainingRisk(riskLevel: $riskLevel, tsbScore: $tsbScore, hrvDeviation: $hrvDeviation, recommendation: $recommendation, factors: $factors, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class $OvertrainingRiskCopyWith<$Res>  {
  factory $OvertrainingRiskCopyWith(OvertrainingRisk value, $Res Function(OvertrainingRisk) _then) = _$OvertrainingRiskCopyWithImpl;
@useResult
$Res call({
 RiskLevel riskLevel, double tsbScore, double hrvDeviation, String recommendation, RiskFactors? factors, DateTime? calculatedAt
});


$RiskFactorsCopyWith<$Res>? get factors;

}
/// @nodoc
class _$OvertrainingRiskCopyWithImpl<$Res>
    implements $OvertrainingRiskCopyWith<$Res> {
  _$OvertrainingRiskCopyWithImpl(this._self, this._then);

  final OvertrainingRisk _self;
  final $Res Function(OvertrainingRisk) _then;

/// Create a copy of OvertrainingRisk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? riskLevel = null,Object? tsbScore = null,Object? hrvDeviation = null,Object? recommendation = null,Object? factors = freezed,Object? calculatedAt = freezed,}) {
  return _then(_self.copyWith(
riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as RiskLevel,tsbScore: null == tsbScore ? _self.tsbScore : tsbScore // ignore: cast_nullable_to_non_nullable
as double,hrvDeviation: null == hrvDeviation ? _self.hrvDeviation : hrvDeviation // ignore: cast_nullable_to_non_nullable
as double,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,factors: freezed == factors ? _self.factors : factors // ignore: cast_nullable_to_non_nullable
as RiskFactors?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of OvertrainingRisk
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RiskFactorsCopyWith<$Res>? get factors {
    if (_self.factors == null) {
    return null;
  }

  return $RiskFactorsCopyWith<$Res>(_self.factors!, (value) {
    return _then(_self.copyWith(factors: value));
  });
}
}


/// Adds pattern-matching-related methods to [OvertrainingRisk].
extension OvertrainingRiskPatterns on OvertrainingRisk {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OvertrainingRisk value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OvertrainingRisk() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OvertrainingRisk value)  $default,){
final _that = this;
switch (_that) {
case _OvertrainingRisk():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OvertrainingRisk value)?  $default,){
final _that = this;
switch (_that) {
case _OvertrainingRisk() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RiskLevel riskLevel,  double tsbScore,  double hrvDeviation,  String recommendation,  RiskFactors? factors,  DateTime? calculatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OvertrainingRisk() when $default != null:
return $default(_that.riskLevel,_that.tsbScore,_that.hrvDeviation,_that.recommendation,_that.factors,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RiskLevel riskLevel,  double tsbScore,  double hrvDeviation,  String recommendation,  RiskFactors? factors,  DateTime? calculatedAt)  $default,) {final _that = this;
switch (_that) {
case _OvertrainingRisk():
return $default(_that.riskLevel,_that.tsbScore,_that.hrvDeviation,_that.recommendation,_that.factors,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RiskLevel riskLevel,  double tsbScore,  double hrvDeviation,  String recommendation,  RiskFactors? factors,  DateTime? calculatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OvertrainingRisk() when $default != null:
return $default(_that.riskLevel,_that.tsbScore,_that.hrvDeviation,_that.recommendation,_that.factors,_that.calculatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OvertrainingRisk extends OvertrainingRisk {
  const _OvertrainingRisk({required this.riskLevel, required this.tsbScore, required this.hrvDeviation, required this.recommendation, this.factors, this.calculatedAt = null}): super._();
  factory _OvertrainingRisk.fromJson(Map<String, dynamic> json) => _$OvertrainingRiskFromJson(json);

/// Overall risk level for overtraining
@override final  RiskLevel riskLevel;
/// TSB (Training Stress Balance) score
///
/// **Interpretation**:
/// - TSB > 0: Fresh, well-recovered
/// - TSB 0 to -10: Normal training load
/// - TSB -10 to -20: Approaching overreaching
/// - TSB < -20: Overtraining risk (deload needed)
///
/// **Formula**: TSB = Chronic Training Load - Acute Training Load
@override final  double tsbScore;
/// HRV (Heart Rate Variability) deviation from baseline (%)
///
/// **Interpretation**:
/// - HRV deviation > +5%: Excellent recovery
/// - HRV deviation 0% to +5%: Good recovery
/// - HRV deviation -5% to 0%: Acceptable recovery
/// - HRV deviation -10% to -5%: Low recovery (monitor)
/// - HRV deviation < -10%: Very low recovery (rest needed)
///
/// **Note**: Negative values indicate HRV below personal baseline
@override final  double hrvDeviation;
/// Human-readable recommendation based on risk assessment
///
/// **Examples**:
/// - "Well-recovered! Continue current training load."
/// - "Monitor recovery. Consider reducing volume next week."
/// - "High overtraining risk. Deload week recommended."
/// - "Very high risk. Take 3-5 days complete rest."
@override final  String recommendation;
/// Optional: Detailed breakdown of risk factors
@override final  RiskFactors? factors;
/// Timestamp when risk was calculated
@override@JsonKey() final  DateTime? calculatedAt;

/// Create a copy of OvertrainingRisk
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OvertrainingRiskCopyWith<_OvertrainingRisk> get copyWith => __$OvertrainingRiskCopyWithImpl<_OvertrainingRisk>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OvertrainingRiskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OvertrainingRisk&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.tsbScore, tsbScore) || other.tsbScore == tsbScore)&&(identical(other.hrvDeviation, hrvDeviation) || other.hrvDeviation == hrvDeviation)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.factors, factors) || other.factors == factors)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,riskLevel,tsbScore,hrvDeviation,recommendation,factors,calculatedAt);

@override
String toString() {
  return 'OvertrainingRisk(riskLevel: $riskLevel, tsbScore: $tsbScore, hrvDeviation: $hrvDeviation, recommendation: $recommendation, factors: $factors, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class _$OvertrainingRiskCopyWith<$Res> implements $OvertrainingRiskCopyWith<$Res> {
  factory _$OvertrainingRiskCopyWith(_OvertrainingRisk value, $Res Function(_OvertrainingRisk) _then) = __$OvertrainingRiskCopyWithImpl;
@override @useResult
$Res call({
 RiskLevel riskLevel, double tsbScore, double hrvDeviation, String recommendation, RiskFactors? factors, DateTime? calculatedAt
});


@override $RiskFactorsCopyWith<$Res>? get factors;

}
/// @nodoc
class __$OvertrainingRiskCopyWithImpl<$Res>
    implements _$OvertrainingRiskCopyWith<$Res> {
  __$OvertrainingRiskCopyWithImpl(this._self, this._then);

  final _OvertrainingRisk _self;
  final $Res Function(_OvertrainingRisk) _then;

/// Create a copy of OvertrainingRisk
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? riskLevel = null,Object? tsbScore = null,Object? hrvDeviation = null,Object? recommendation = null,Object? factors = freezed,Object? calculatedAt = freezed,}) {
  return _then(_OvertrainingRisk(
riskLevel: null == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as RiskLevel,tsbScore: null == tsbScore ? _self.tsbScore : tsbScore // ignore: cast_nullable_to_non_nullable
as double,hrvDeviation: null == hrvDeviation ? _self.hrvDeviation : hrvDeviation // ignore: cast_nullable_to_non_nullable
as double,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,factors: freezed == factors ? _self.factors : factors // ignore: cast_nullable_to_non_nullable
as RiskFactors?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of OvertrainingRisk
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RiskFactorsCopyWith<$Res>? get factors {
    if (_self.factors == null) {
    return null;
  }

  return $RiskFactorsCopyWith<$Res>(_self.factors!, (value) {
    return _then(_self.copyWith(factors: value));
  });
}
}


/// @nodoc
mixin _$RiskFactors {

/// Acute Training Load (7-day average)
///
/// **Calculation**: Sum of daily training stress scores (last 7 days)
 int get acuteTrainingLoad;/// Chronic Training Load (28-day average)
///
/// **Calculation**: Sum of daily training stress scores (last 28 days)
 int get chronicTrainingLoad;/// HRV baseline (personal average from 20+ days)
///
/// **Unit**: Milliseconds (ms)
/// **Typical Range**: 40-90 ms (varies by individual)
 double get hrvBaseline;/// Current HRV (7-day average)
///
/// **Unit**: Milliseconds (ms)
/// **Comparison**: Compare to hrvBaseline for deviation %
 double get currentHrv;/// Optional: Sleep quality score (1-10)
///
/// **Scale**:
/// - 8-10: Excellent sleep
/// - 6-7: Good sleep
/// - 4-5: Poor sleep
/// - 1-3: Very poor sleep
 int? get sleepQualityScore;/// Optional: Muscle soreness score (1-10)
///
/// **Scale**:
/// - 1-3: Minimal soreness
/// - 4-6: Moderate soreness
/// - 7-8: Significant soreness
/// - 9-10: Severe soreness (DOMS)
 int? get muscleSorenessScore;/// Optional: Mood/energy score (1-10)
///
/// **Scale**:
/// - 8-10: High energy, positive mood
/// - 6-7: Normal energy
/// - 4-5: Low energy, irritability
/// - 1-3: Fatigue, depression symptoms
 int? get moodEnergyScore;
/// Create a copy of RiskFactors
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiskFactorsCopyWith<RiskFactors> get copyWith => _$RiskFactorsCopyWithImpl<RiskFactors>(this as RiskFactors, _$identity);

  /// Serializes this RiskFactors to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiskFactors&&(identical(other.acuteTrainingLoad, acuteTrainingLoad) || other.acuteTrainingLoad == acuteTrainingLoad)&&(identical(other.chronicTrainingLoad, chronicTrainingLoad) || other.chronicTrainingLoad == chronicTrainingLoad)&&(identical(other.hrvBaseline, hrvBaseline) || other.hrvBaseline == hrvBaseline)&&(identical(other.currentHrv, currentHrv) || other.currentHrv == currentHrv)&&(identical(other.sleepQualityScore, sleepQualityScore) || other.sleepQualityScore == sleepQualityScore)&&(identical(other.muscleSorenessScore, muscleSorenessScore) || other.muscleSorenessScore == muscleSorenessScore)&&(identical(other.moodEnergyScore, moodEnergyScore) || other.moodEnergyScore == moodEnergyScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acuteTrainingLoad,chronicTrainingLoad,hrvBaseline,currentHrv,sleepQualityScore,muscleSorenessScore,moodEnergyScore);

@override
String toString() {
  return 'RiskFactors(acuteTrainingLoad: $acuteTrainingLoad, chronicTrainingLoad: $chronicTrainingLoad, hrvBaseline: $hrvBaseline, currentHrv: $currentHrv, sleepQualityScore: $sleepQualityScore, muscleSorenessScore: $muscleSorenessScore, moodEnergyScore: $moodEnergyScore)';
}


}

/// @nodoc
abstract mixin class $RiskFactorsCopyWith<$Res>  {
  factory $RiskFactorsCopyWith(RiskFactors value, $Res Function(RiskFactors) _then) = _$RiskFactorsCopyWithImpl;
@useResult
$Res call({
 int acuteTrainingLoad, int chronicTrainingLoad, double hrvBaseline, double currentHrv, int? sleepQualityScore, int? muscleSorenessScore, int? moodEnergyScore
});




}
/// @nodoc
class _$RiskFactorsCopyWithImpl<$Res>
    implements $RiskFactorsCopyWith<$Res> {
  _$RiskFactorsCopyWithImpl(this._self, this._then);

  final RiskFactors _self;
  final $Res Function(RiskFactors) _then;

/// Create a copy of RiskFactors
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? acuteTrainingLoad = null,Object? chronicTrainingLoad = null,Object? hrvBaseline = null,Object? currentHrv = null,Object? sleepQualityScore = freezed,Object? muscleSorenessScore = freezed,Object? moodEnergyScore = freezed,}) {
  return _then(_self.copyWith(
acuteTrainingLoad: null == acuteTrainingLoad ? _self.acuteTrainingLoad : acuteTrainingLoad // ignore: cast_nullable_to_non_nullable
as int,chronicTrainingLoad: null == chronicTrainingLoad ? _self.chronicTrainingLoad : chronicTrainingLoad // ignore: cast_nullable_to_non_nullable
as int,hrvBaseline: null == hrvBaseline ? _self.hrvBaseline : hrvBaseline // ignore: cast_nullable_to_non_nullable
as double,currentHrv: null == currentHrv ? _self.currentHrv : currentHrv // ignore: cast_nullable_to_non_nullable
as double,sleepQualityScore: freezed == sleepQualityScore ? _self.sleepQualityScore : sleepQualityScore // ignore: cast_nullable_to_non_nullable
as int?,muscleSorenessScore: freezed == muscleSorenessScore ? _self.muscleSorenessScore : muscleSorenessScore // ignore: cast_nullable_to_non_nullable
as int?,moodEnergyScore: freezed == moodEnergyScore ? _self.moodEnergyScore : moodEnergyScore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RiskFactors].
extension RiskFactorsPatterns on RiskFactors {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiskFactors value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiskFactors() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiskFactors value)  $default,){
final _that = this;
switch (_that) {
case _RiskFactors():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiskFactors value)?  $default,){
final _that = this;
switch (_that) {
case _RiskFactors() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int acuteTrainingLoad,  int chronicTrainingLoad,  double hrvBaseline,  double currentHrv,  int? sleepQualityScore,  int? muscleSorenessScore,  int? moodEnergyScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiskFactors() when $default != null:
return $default(_that.acuteTrainingLoad,_that.chronicTrainingLoad,_that.hrvBaseline,_that.currentHrv,_that.sleepQualityScore,_that.muscleSorenessScore,_that.moodEnergyScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int acuteTrainingLoad,  int chronicTrainingLoad,  double hrvBaseline,  double currentHrv,  int? sleepQualityScore,  int? muscleSorenessScore,  int? moodEnergyScore)  $default,) {final _that = this;
switch (_that) {
case _RiskFactors():
return $default(_that.acuteTrainingLoad,_that.chronicTrainingLoad,_that.hrvBaseline,_that.currentHrv,_that.sleepQualityScore,_that.muscleSorenessScore,_that.moodEnergyScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int acuteTrainingLoad,  int chronicTrainingLoad,  double hrvBaseline,  double currentHrv,  int? sleepQualityScore,  int? muscleSorenessScore,  int? moodEnergyScore)?  $default,) {final _that = this;
switch (_that) {
case _RiskFactors() when $default != null:
return $default(_that.acuteTrainingLoad,_that.chronicTrainingLoad,_that.hrvBaseline,_that.currentHrv,_that.sleepQualityScore,_that.muscleSorenessScore,_that.moodEnergyScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiskFactors implements RiskFactors {
  const _RiskFactors({required this.acuteTrainingLoad, required this.chronicTrainingLoad, required this.hrvBaseline, required this.currentHrv, this.sleepQualityScore, this.muscleSorenessScore, this.moodEnergyScore});
  factory _RiskFactors.fromJson(Map<String, dynamic> json) => _$RiskFactorsFromJson(json);

/// Acute Training Load (7-day average)
///
/// **Calculation**: Sum of daily training stress scores (last 7 days)
@override final  int acuteTrainingLoad;
/// Chronic Training Load (28-day average)
///
/// **Calculation**: Sum of daily training stress scores (last 28 days)
@override final  int chronicTrainingLoad;
/// HRV baseline (personal average from 20+ days)
///
/// **Unit**: Milliseconds (ms)
/// **Typical Range**: 40-90 ms (varies by individual)
@override final  double hrvBaseline;
/// Current HRV (7-day average)
///
/// **Unit**: Milliseconds (ms)
/// **Comparison**: Compare to hrvBaseline for deviation %
@override final  double currentHrv;
/// Optional: Sleep quality score (1-10)
///
/// **Scale**:
/// - 8-10: Excellent sleep
/// - 6-7: Good sleep
/// - 4-5: Poor sleep
/// - 1-3: Very poor sleep
@override final  int? sleepQualityScore;
/// Optional: Muscle soreness score (1-10)
///
/// **Scale**:
/// - 1-3: Minimal soreness
/// - 4-6: Moderate soreness
/// - 7-8: Significant soreness
/// - 9-10: Severe soreness (DOMS)
@override final  int? muscleSorenessScore;
/// Optional: Mood/energy score (1-10)
///
/// **Scale**:
/// - 8-10: High energy, positive mood
/// - 6-7: Normal energy
/// - 4-5: Low energy, irritability
/// - 1-3: Fatigue, depression symptoms
@override final  int? moodEnergyScore;

/// Create a copy of RiskFactors
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiskFactorsCopyWith<_RiskFactors> get copyWith => __$RiskFactorsCopyWithImpl<_RiskFactors>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiskFactorsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiskFactors&&(identical(other.acuteTrainingLoad, acuteTrainingLoad) || other.acuteTrainingLoad == acuteTrainingLoad)&&(identical(other.chronicTrainingLoad, chronicTrainingLoad) || other.chronicTrainingLoad == chronicTrainingLoad)&&(identical(other.hrvBaseline, hrvBaseline) || other.hrvBaseline == hrvBaseline)&&(identical(other.currentHrv, currentHrv) || other.currentHrv == currentHrv)&&(identical(other.sleepQualityScore, sleepQualityScore) || other.sleepQualityScore == sleepQualityScore)&&(identical(other.muscleSorenessScore, muscleSorenessScore) || other.muscleSorenessScore == muscleSorenessScore)&&(identical(other.moodEnergyScore, moodEnergyScore) || other.moodEnergyScore == moodEnergyScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acuteTrainingLoad,chronicTrainingLoad,hrvBaseline,currentHrv,sleepQualityScore,muscleSorenessScore,moodEnergyScore);

@override
String toString() {
  return 'RiskFactors(acuteTrainingLoad: $acuteTrainingLoad, chronicTrainingLoad: $chronicTrainingLoad, hrvBaseline: $hrvBaseline, currentHrv: $currentHrv, sleepQualityScore: $sleepQualityScore, muscleSorenessScore: $muscleSorenessScore, moodEnergyScore: $moodEnergyScore)';
}


}

/// @nodoc
abstract mixin class _$RiskFactorsCopyWith<$Res> implements $RiskFactorsCopyWith<$Res> {
  factory _$RiskFactorsCopyWith(_RiskFactors value, $Res Function(_RiskFactors) _then) = __$RiskFactorsCopyWithImpl;
@override @useResult
$Res call({
 int acuteTrainingLoad, int chronicTrainingLoad, double hrvBaseline, double currentHrv, int? sleepQualityScore, int? muscleSorenessScore, int? moodEnergyScore
});




}
/// @nodoc
class __$RiskFactorsCopyWithImpl<$Res>
    implements _$RiskFactorsCopyWith<$Res> {
  __$RiskFactorsCopyWithImpl(this._self, this._then);

  final _RiskFactors _self;
  final $Res Function(_RiskFactors) _then;

/// Create a copy of RiskFactors
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? acuteTrainingLoad = null,Object? chronicTrainingLoad = null,Object? hrvBaseline = null,Object? currentHrv = null,Object? sleepQualityScore = freezed,Object? muscleSorenessScore = freezed,Object? moodEnergyScore = freezed,}) {
  return _then(_RiskFactors(
acuteTrainingLoad: null == acuteTrainingLoad ? _self.acuteTrainingLoad : acuteTrainingLoad // ignore: cast_nullable_to_non_nullable
as int,chronicTrainingLoad: null == chronicTrainingLoad ? _self.chronicTrainingLoad : chronicTrainingLoad // ignore: cast_nullable_to_non_nullable
as int,hrvBaseline: null == hrvBaseline ? _self.hrvBaseline : hrvBaseline // ignore: cast_nullable_to_non_nullable
as double,currentHrv: null == currentHrv ? _self.currentHrv : currentHrv // ignore: cast_nullable_to_non_nullable
as double,sleepQualityScore: freezed == sleepQualityScore ? _self.sleepQualityScore : sleepQualityScore // ignore: cast_nullable_to_non_nullable
as int?,muscleSorenessScore: freezed == muscleSorenessScore ? _self.muscleSorenessScore : muscleSorenessScore // ignore: cast_nullable_to_non_nullable
as int?,moodEnergyScore: freezed == moodEnergyScore ? _self.moodEnergyScore : moodEnergyScore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
