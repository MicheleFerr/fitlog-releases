// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overtraining_risk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OvertrainingRisk _$OvertrainingRiskFromJson(Map<String, dynamic> json) {
  return _OvertrainingRisk.fromJson(json);
}

/// @nodoc
mixin _$OvertrainingRisk {
  /// Overall risk level for overtraining
  RiskLevel get riskLevel => throw _privateConstructorUsedError;

  /// TSB (Training Stress Balance) score
  ///
  /// **Interpretation**:
  /// - TSB > 0: Fresh, well-recovered
  /// - TSB 0 to -10: Normal training load
  /// - TSB -10 to -20: Approaching overreaching
  /// - TSB < -20: Overtraining risk (deload needed)
  ///
  /// **Formula**: TSB = Chronic Training Load - Acute Training Load
  double get tsbScore => throw _privateConstructorUsedError;

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
  double get hrvDeviation => throw _privateConstructorUsedError;

  /// Human-readable recommendation based on risk assessment
  ///
  /// **Examples**:
  /// - "Well-recovered! Continue current training load."
  /// - "Monitor recovery. Consider reducing volume next week."
  /// - "High overtraining risk. Deload week recommended."
  /// - "Very high risk. Take 3-5 days complete rest."
  String get recommendation => throw _privateConstructorUsedError;

  /// Optional: Detailed breakdown of risk factors
  RiskFactors? get factors => throw _privateConstructorUsedError;

  /// Timestamp when risk was calculated
  DateTime? get calculatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OvertrainingRiskCopyWith<OvertrainingRisk> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OvertrainingRiskCopyWith<$Res> {
  factory $OvertrainingRiskCopyWith(
          OvertrainingRisk value, $Res Function(OvertrainingRisk) then) =
      _$OvertrainingRiskCopyWithImpl<$Res, OvertrainingRisk>;
  @useResult
  $Res call(
      {RiskLevel riskLevel,
      double tsbScore,
      double hrvDeviation,
      String recommendation,
      RiskFactors? factors,
      DateTime? calculatedAt});

  $RiskFactorsCopyWith<$Res>? get factors;
}

/// @nodoc
class _$OvertrainingRiskCopyWithImpl<$Res, $Val extends OvertrainingRisk>
    implements $OvertrainingRiskCopyWith<$Res> {
  _$OvertrainingRiskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskLevel = null,
    Object? tsbScore = null,
    Object? hrvDeviation = null,
    Object? recommendation = null,
    Object? factors = freezed,
    Object? calculatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as RiskLevel,
      tsbScore: null == tsbScore
          ? _value.tsbScore
          : tsbScore // ignore: cast_nullable_to_non_nullable
              as double,
      hrvDeviation: null == hrvDeviation
          ? _value.hrvDeviation
          : hrvDeviation // ignore: cast_nullable_to_non_nullable
              as double,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      factors: freezed == factors
          ? _value.factors
          : factors // ignore: cast_nullable_to_non_nullable
              as RiskFactors?,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RiskFactorsCopyWith<$Res>? get factors {
    if (_value.factors == null) {
      return null;
    }

    return $RiskFactorsCopyWith<$Res>(_value.factors!, (value) {
      return _then(_value.copyWith(factors: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OvertrainingRiskImplCopyWith<$Res>
    implements $OvertrainingRiskCopyWith<$Res> {
  factory _$$OvertrainingRiskImplCopyWith(_$OvertrainingRiskImpl value,
          $Res Function(_$OvertrainingRiskImpl) then) =
      __$$OvertrainingRiskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RiskLevel riskLevel,
      double tsbScore,
      double hrvDeviation,
      String recommendation,
      RiskFactors? factors,
      DateTime? calculatedAt});

  @override
  $RiskFactorsCopyWith<$Res>? get factors;
}

/// @nodoc
class __$$OvertrainingRiskImplCopyWithImpl<$Res>
    extends _$OvertrainingRiskCopyWithImpl<$Res, _$OvertrainingRiskImpl>
    implements _$$OvertrainingRiskImplCopyWith<$Res> {
  __$$OvertrainingRiskImplCopyWithImpl(_$OvertrainingRiskImpl _value,
      $Res Function(_$OvertrainingRiskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? riskLevel = null,
    Object? tsbScore = null,
    Object? hrvDeviation = null,
    Object? recommendation = null,
    Object? factors = freezed,
    Object? calculatedAt = freezed,
  }) {
    return _then(_$OvertrainingRiskImpl(
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as RiskLevel,
      tsbScore: null == tsbScore
          ? _value.tsbScore
          : tsbScore // ignore: cast_nullable_to_non_nullable
              as double,
      hrvDeviation: null == hrvDeviation
          ? _value.hrvDeviation
          : hrvDeviation // ignore: cast_nullable_to_non_nullable
              as double,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      factors: freezed == factors
          ? _value.factors
          : factors // ignore: cast_nullable_to_non_nullable
              as RiskFactors?,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OvertrainingRiskImpl extends _OvertrainingRisk {
  const _$OvertrainingRiskImpl(
      {required this.riskLevel,
      required this.tsbScore,
      required this.hrvDeviation,
      required this.recommendation,
      this.factors,
      this.calculatedAt = null})
      : super._();

  factory _$OvertrainingRiskImpl.fromJson(Map<String, dynamic> json) =>
      _$$OvertrainingRiskImplFromJson(json);

  /// Overall risk level for overtraining
  @override
  final RiskLevel riskLevel;

  /// TSB (Training Stress Balance) score
  ///
  /// **Interpretation**:
  /// - TSB > 0: Fresh, well-recovered
  /// - TSB 0 to -10: Normal training load
  /// - TSB -10 to -20: Approaching overreaching
  /// - TSB < -20: Overtraining risk (deload needed)
  ///
  /// **Formula**: TSB = Chronic Training Load - Acute Training Load
  @override
  final double tsbScore;

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
  @override
  final double hrvDeviation;

  /// Human-readable recommendation based on risk assessment
  ///
  /// **Examples**:
  /// - "Well-recovered! Continue current training load."
  /// - "Monitor recovery. Consider reducing volume next week."
  /// - "High overtraining risk. Deload week recommended."
  /// - "Very high risk. Take 3-5 days complete rest."
  @override
  final String recommendation;

  /// Optional: Detailed breakdown of risk factors
  @override
  final RiskFactors? factors;

  /// Timestamp when risk was calculated
  @override
  @JsonKey()
  final DateTime? calculatedAt;

  @override
  String toString() {
    return 'OvertrainingRisk(riskLevel: $riskLevel, tsbScore: $tsbScore, hrvDeviation: $hrvDeviation, recommendation: $recommendation, factors: $factors, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OvertrainingRiskImpl &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.tsbScore, tsbScore) ||
                other.tsbScore == tsbScore) &&
            (identical(other.hrvDeviation, hrvDeviation) ||
                other.hrvDeviation == hrvDeviation) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.factors, factors) || other.factors == factors) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, riskLevel, tsbScore,
      hrvDeviation, recommendation, factors, calculatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OvertrainingRiskImplCopyWith<_$OvertrainingRiskImpl> get copyWith =>
      __$$OvertrainingRiskImplCopyWithImpl<_$OvertrainingRiskImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OvertrainingRiskImplToJson(
      this,
    );
  }
}

abstract class _OvertrainingRisk extends OvertrainingRisk {
  const factory _OvertrainingRisk(
      {required final RiskLevel riskLevel,
      required final double tsbScore,
      required final double hrvDeviation,
      required final String recommendation,
      final RiskFactors? factors,
      final DateTime? calculatedAt}) = _$OvertrainingRiskImpl;
  const _OvertrainingRisk._() : super._();

  factory _OvertrainingRisk.fromJson(Map<String, dynamic> json) =
      _$OvertrainingRiskImpl.fromJson;

  @override

  /// Overall risk level for overtraining
  RiskLevel get riskLevel;
  @override

  /// TSB (Training Stress Balance) score
  ///
  /// **Interpretation**:
  /// - TSB > 0: Fresh, well-recovered
  /// - TSB 0 to -10: Normal training load
  /// - TSB -10 to -20: Approaching overreaching
  /// - TSB < -20: Overtraining risk (deload needed)
  ///
  /// **Formula**: TSB = Chronic Training Load - Acute Training Load
  double get tsbScore;
  @override

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
  double get hrvDeviation;
  @override

  /// Human-readable recommendation based on risk assessment
  ///
  /// **Examples**:
  /// - "Well-recovered! Continue current training load."
  /// - "Monitor recovery. Consider reducing volume next week."
  /// - "High overtraining risk. Deload week recommended."
  /// - "Very high risk. Take 3-5 days complete rest."
  String get recommendation;
  @override

  /// Optional: Detailed breakdown of risk factors
  RiskFactors? get factors;
  @override

  /// Timestamp when risk was calculated
  DateTime? get calculatedAt;
  @override
  @JsonKey(ignore: true)
  _$$OvertrainingRiskImplCopyWith<_$OvertrainingRiskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RiskFactors _$RiskFactorsFromJson(Map<String, dynamic> json) {
  return _RiskFactors.fromJson(json);
}

/// @nodoc
mixin _$RiskFactors {
  /// Acute Training Load (7-day average)
  ///
  /// **Calculation**: Sum of daily training stress scores (last 7 days)
  int get acuteTrainingLoad => throw _privateConstructorUsedError;

  /// Chronic Training Load (28-day average)
  ///
  /// **Calculation**: Sum of daily training stress scores (last 28 days)
  int get chronicTrainingLoad => throw _privateConstructorUsedError;

  /// HRV baseline (personal average from 20+ days)
  ///
  /// **Unit**: Milliseconds (ms)
  /// **Typical Range**: 40-90 ms (varies by individual)
  double get hrvBaseline => throw _privateConstructorUsedError;

  /// Current HRV (7-day average)
  ///
  /// **Unit**: Milliseconds (ms)
  /// **Comparison**: Compare to hrvBaseline for deviation %
  double get currentHrv => throw _privateConstructorUsedError;

  /// Optional: Sleep quality score (1-10)
  ///
  /// **Scale**:
  /// - 8-10: Excellent sleep
  /// - 6-7: Good sleep
  /// - 4-5: Poor sleep
  /// - 1-3: Very poor sleep
  int? get sleepQualityScore => throw _privateConstructorUsedError;

  /// Optional: Muscle soreness score (1-10)
  ///
  /// **Scale**:
  /// - 1-3: Minimal soreness
  /// - 4-6: Moderate soreness
  /// - 7-8: Significant soreness
  /// - 9-10: Severe soreness (DOMS)
  int? get muscleSorenessScore => throw _privateConstructorUsedError;

  /// Optional: Mood/energy score (1-10)
  ///
  /// **Scale**:
  /// - 8-10: High energy, positive mood
  /// - 6-7: Normal energy
  /// - 4-5: Low energy, irritability
  /// - 1-3: Fatigue, depression symptoms
  int? get moodEnergyScore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RiskFactorsCopyWith<RiskFactors> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RiskFactorsCopyWith<$Res> {
  factory $RiskFactorsCopyWith(
          RiskFactors value, $Res Function(RiskFactors) then) =
      _$RiskFactorsCopyWithImpl<$Res, RiskFactors>;
  @useResult
  $Res call(
      {int acuteTrainingLoad,
      int chronicTrainingLoad,
      double hrvBaseline,
      double currentHrv,
      int? sleepQualityScore,
      int? muscleSorenessScore,
      int? moodEnergyScore});
}

/// @nodoc
class _$RiskFactorsCopyWithImpl<$Res, $Val extends RiskFactors>
    implements $RiskFactorsCopyWith<$Res> {
  _$RiskFactorsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? acuteTrainingLoad = null,
    Object? chronicTrainingLoad = null,
    Object? hrvBaseline = null,
    Object? currentHrv = null,
    Object? sleepQualityScore = freezed,
    Object? muscleSorenessScore = freezed,
    Object? moodEnergyScore = freezed,
  }) {
    return _then(_value.copyWith(
      acuteTrainingLoad: null == acuteTrainingLoad
          ? _value.acuteTrainingLoad
          : acuteTrainingLoad // ignore: cast_nullable_to_non_nullable
              as int,
      chronicTrainingLoad: null == chronicTrainingLoad
          ? _value.chronicTrainingLoad
          : chronicTrainingLoad // ignore: cast_nullable_to_non_nullable
              as int,
      hrvBaseline: null == hrvBaseline
          ? _value.hrvBaseline
          : hrvBaseline // ignore: cast_nullable_to_non_nullable
              as double,
      currentHrv: null == currentHrv
          ? _value.currentHrv
          : currentHrv // ignore: cast_nullable_to_non_nullable
              as double,
      sleepQualityScore: freezed == sleepQualityScore
          ? _value.sleepQualityScore
          : sleepQualityScore // ignore: cast_nullable_to_non_nullable
              as int?,
      muscleSorenessScore: freezed == muscleSorenessScore
          ? _value.muscleSorenessScore
          : muscleSorenessScore // ignore: cast_nullable_to_non_nullable
              as int?,
      moodEnergyScore: freezed == moodEnergyScore
          ? _value.moodEnergyScore
          : moodEnergyScore // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RiskFactorsImplCopyWith<$Res>
    implements $RiskFactorsCopyWith<$Res> {
  factory _$$RiskFactorsImplCopyWith(
          _$RiskFactorsImpl value, $Res Function(_$RiskFactorsImpl) then) =
      __$$RiskFactorsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int acuteTrainingLoad,
      int chronicTrainingLoad,
      double hrvBaseline,
      double currentHrv,
      int? sleepQualityScore,
      int? muscleSorenessScore,
      int? moodEnergyScore});
}

/// @nodoc
class __$$RiskFactorsImplCopyWithImpl<$Res>
    extends _$RiskFactorsCopyWithImpl<$Res, _$RiskFactorsImpl>
    implements _$$RiskFactorsImplCopyWith<$Res> {
  __$$RiskFactorsImplCopyWithImpl(
      _$RiskFactorsImpl _value, $Res Function(_$RiskFactorsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? acuteTrainingLoad = null,
    Object? chronicTrainingLoad = null,
    Object? hrvBaseline = null,
    Object? currentHrv = null,
    Object? sleepQualityScore = freezed,
    Object? muscleSorenessScore = freezed,
    Object? moodEnergyScore = freezed,
  }) {
    return _then(_$RiskFactorsImpl(
      acuteTrainingLoad: null == acuteTrainingLoad
          ? _value.acuteTrainingLoad
          : acuteTrainingLoad // ignore: cast_nullable_to_non_nullable
              as int,
      chronicTrainingLoad: null == chronicTrainingLoad
          ? _value.chronicTrainingLoad
          : chronicTrainingLoad // ignore: cast_nullable_to_non_nullable
              as int,
      hrvBaseline: null == hrvBaseline
          ? _value.hrvBaseline
          : hrvBaseline // ignore: cast_nullable_to_non_nullable
              as double,
      currentHrv: null == currentHrv
          ? _value.currentHrv
          : currentHrv // ignore: cast_nullable_to_non_nullable
              as double,
      sleepQualityScore: freezed == sleepQualityScore
          ? _value.sleepQualityScore
          : sleepQualityScore // ignore: cast_nullable_to_non_nullable
              as int?,
      muscleSorenessScore: freezed == muscleSorenessScore
          ? _value.muscleSorenessScore
          : muscleSorenessScore // ignore: cast_nullable_to_non_nullable
              as int?,
      moodEnergyScore: freezed == moodEnergyScore
          ? _value.moodEnergyScore
          : moodEnergyScore // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RiskFactorsImpl implements _RiskFactors {
  const _$RiskFactorsImpl(
      {required this.acuteTrainingLoad,
      required this.chronicTrainingLoad,
      required this.hrvBaseline,
      required this.currentHrv,
      this.sleepQualityScore,
      this.muscleSorenessScore,
      this.moodEnergyScore});

  factory _$RiskFactorsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RiskFactorsImplFromJson(json);

  /// Acute Training Load (7-day average)
  ///
  /// **Calculation**: Sum of daily training stress scores (last 7 days)
  @override
  final int acuteTrainingLoad;

  /// Chronic Training Load (28-day average)
  ///
  /// **Calculation**: Sum of daily training stress scores (last 28 days)
  @override
  final int chronicTrainingLoad;

  /// HRV baseline (personal average from 20+ days)
  ///
  /// **Unit**: Milliseconds (ms)
  /// **Typical Range**: 40-90 ms (varies by individual)
  @override
  final double hrvBaseline;

  /// Current HRV (7-day average)
  ///
  /// **Unit**: Milliseconds (ms)
  /// **Comparison**: Compare to hrvBaseline for deviation %
  @override
  final double currentHrv;

  /// Optional: Sleep quality score (1-10)
  ///
  /// **Scale**:
  /// - 8-10: Excellent sleep
  /// - 6-7: Good sleep
  /// - 4-5: Poor sleep
  /// - 1-3: Very poor sleep
  @override
  final int? sleepQualityScore;

  /// Optional: Muscle soreness score (1-10)
  ///
  /// **Scale**:
  /// - 1-3: Minimal soreness
  /// - 4-6: Moderate soreness
  /// - 7-8: Significant soreness
  /// - 9-10: Severe soreness (DOMS)
  @override
  final int? muscleSorenessScore;

  /// Optional: Mood/energy score (1-10)
  ///
  /// **Scale**:
  /// - 8-10: High energy, positive mood
  /// - 6-7: Normal energy
  /// - 4-5: Low energy, irritability
  /// - 1-3: Fatigue, depression symptoms
  @override
  final int? moodEnergyScore;

  @override
  String toString() {
    return 'RiskFactors(acuteTrainingLoad: $acuteTrainingLoad, chronicTrainingLoad: $chronicTrainingLoad, hrvBaseline: $hrvBaseline, currentHrv: $currentHrv, sleepQualityScore: $sleepQualityScore, muscleSorenessScore: $muscleSorenessScore, moodEnergyScore: $moodEnergyScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RiskFactorsImpl &&
            (identical(other.acuteTrainingLoad, acuteTrainingLoad) ||
                other.acuteTrainingLoad == acuteTrainingLoad) &&
            (identical(other.chronicTrainingLoad, chronicTrainingLoad) ||
                other.chronicTrainingLoad == chronicTrainingLoad) &&
            (identical(other.hrvBaseline, hrvBaseline) ||
                other.hrvBaseline == hrvBaseline) &&
            (identical(other.currentHrv, currentHrv) ||
                other.currentHrv == currentHrv) &&
            (identical(other.sleepQualityScore, sleepQualityScore) ||
                other.sleepQualityScore == sleepQualityScore) &&
            (identical(other.muscleSorenessScore, muscleSorenessScore) ||
                other.muscleSorenessScore == muscleSorenessScore) &&
            (identical(other.moodEnergyScore, moodEnergyScore) ||
                other.moodEnergyScore == moodEnergyScore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      acuteTrainingLoad,
      chronicTrainingLoad,
      hrvBaseline,
      currentHrv,
      sleepQualityScore,
      muscleSorenessScore,
      moodEnergyScore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RiskFactorsImplCopyWith<_$RiskFactorsImpl> get copyWith =>
      __$$RiskFactorsImplCopyWithImpl<_$RiskFactorsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RiskFactorsImplToJson(
      this,
    );
  }
}

abstract class _RiskFactors implements RiskFactors {
  const factory _RiskFactors(
      {required final int acuteTrainingLoad,
      required final int chronicTrainingLoad,
      required final double hrvBaseline,
      required final double currentHrv,
      final int? sleepQualityScore,
      final int? muscleSorenessScore,
      final int? moodEnergyScore}) = _$RiskFactorsImpl;

  factory _RiskFactors.fromJson(Map<String, dynamic> json) =
      _$RiskFactorsImpl.fromJson;

  @override

  /// Acute Training Load (7-day average)
  ///
  /// **Calculation**: Sum of daily training stress scores (last 7 days)
  int get acuteTrainingLoad;
  @override

  /// Chronic Training Load (28-day average)
  ///
  /// **Calculation**: Sum of daily training stress scores (last 28 days)
  int get chronicTrainingLoad;
  @override

  /// HRV baseline (personal average from 20+ days)
  ///
  /// **Unit**: Milliseconds (ms)
  /// **Typical Range**: 40-90 ms (varies by individual)
  double get hrvBaseline;
  @override

  /// Current HRV (7-day average)
  ///
  /// **Unit**: Milliseconds (ms)
  /// **Comparison**: Compare to hrvBaseline for deviation %
  double get currentHrv;
  @override

  /// Optional: Sleep quality score (1-10)
  ///
  /// **Scale**:
  /// - 8-10: Excellent sleep
  /// - 6-7: Good sleep
  /// - 4-5: Poor sleep
  /// - 1-3: Very poor sleep
  int? get sleepQualityScore;
  @override

  /// Optional: Muscle soreness score (1-10)
  ///
  /// **Scale**:
  /// - 1-3: Minimal soreness
  /// - 4-6: Moderate soreness
  /// - 7-8: Significant soreness
  /// - 9-10: Severe soreness (DOMS)
  int? get muscleSorenessScore;
  @override

  /// Optional: Mood/energy score (1-10)
  ///
  /// **Scale**:
  /// - 8-10: High energy, positive mood
  /// - 6-7: Normal energy
  /// - 4-5: Low energy, irritability
  /// - 1-3: Fatigue, depression symptoms
  int? get moodEnergyScore;
  @override
  @JsonKey(ignore: true)
  _$$RiskFactorsImplCopyWith<_$RiskFactorsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
