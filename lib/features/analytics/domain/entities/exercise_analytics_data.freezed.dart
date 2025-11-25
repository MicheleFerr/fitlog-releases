// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_analytics_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChartDataPoint {
  /// Date of the data point
  DateTime get date => throw _privateConstructorUsedError;

  /// Primary value (weight, volume, etc.)
  double get value => throw _privateConstructorUsedError;

  /// Optional RPE for this data point
  int? get rpe => throw _privateConstructorUsedError;

  /// Optional reps count
  int? get reps => throw _privateConstructorUsedError;

  /// Optional session index (1, 2, 3...)
  int? get sessionIndex => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChartDataPointCopyWith<ChartDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartDataPointCopyWith<$Res> {
  factory $ChartDataPointCopyWith(
          ChartDataPoint value, $Res Function(ChartDataPoint) then) =
      _$ChartDataPointCopyWithImpl<$Res, ChartDataPoint>;
  @useResult
  $Res call(
      {DateTime date, double value, int? rpe, int? reps, int? sessionIndex});
}

/// @nodoc
class _$ChartDataPointCopyWithImpl<$Res, $Val extends ChartDataPoint>
    implements $ChartDataPointCopyWith<$Res> {
  _$ChartDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
    Object? rpe = freezed,
    Object? reps = freezed,
    Object? sessionIndex = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionIndex: freezed == sessionIndex
          ? _value.sessionIndex
          : sessionIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChartDataPointImplCopyWith<$Res>
    implements $ChartDataPointCopyWith<$Res> {
  factory _$$ChartDataPointImplCopyWith(_$ChartDataPointImpl value,
          $Res Function(_$ChartDataPointImpl) then) =
      __$$ChartDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date, double value, int? rpe, int? reps, int? sessionIndex});
}

/// @nodoc
class __$$ChartDataPointImplCopyWithImpl<$Res>
    extends _$ChartDataPointCopyWithImpl<$Res, _$ChartDataPointImpl>
    implements _$$ChartDataPointImplCopyWith<$Res> {
  __$$ChartDataPointImplCopyWithImpl(
      _$ChartDataPointImpl _value, $Res Function(_$ChartDataPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
    Object? rpe = freezed,
    Object? reps = freezed,
    Object? sessionIndex = freezed,
  }) {
    return _then(_$ChartDataPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      rpe: freezed == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionIndex: freezed == sessionIndex
          ? _value.sessionIndex
          : sessionIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ChartDataPointImpl extends _ChartDataPoint {
  const _$ChartDataPointImpl(
      {required this.date,
      required this.value,
      this.rpe,
      this.reps,
      this.sessionIndex})
      : super._();

  /// Date of the data point
  @override
  final DateTime date;

  /// Primary value (weight, volume, etc.)
  @override
  final double value;

  /// Optional RPE for this data point
  @override
  final int? rpe;

  /// Optional reps count
  @override
  final int? reps;

  /// Optional session index (1, 2, 3...)
  @override
  final int? sessionIndex;

  @override
  String toString() {
    return 'ChartDataPoint(date: $date, value: $value, rpe: $rpe, reps: $reps, sessionIndex: $sessionIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartDataPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.sessionIndex, sessionIndex) ||
                other.sessionIndex == sessionIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, date, value, rpe, reps, sessionIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartDataPointImplCopyWith<_$ChartDataPointImpl> get copyWith =>
      __$$ChartDataPointImplCopyWithImpl<_$ChartDataPointImpl>(
          this, _$identity);
}

abstract class _ChartDataPoint extends ChartDataPoint {
  const factory _ChartDataPoint(
      {required final DateTime date,
      required final double value,
      final int? rpe,
      final int? reps,
      final int? sessionIndex}) = _$ChartDataPointImpl;
  const _ChartDataPoint._() : super._();

  @override

  /// Date of the data point
  DateTime get date;
  @override

  /// Primary value (weight, volume, etc.)
  double get value;
  @override

  /// Optional RPE for this data point
  int? get rpe;
  @override

  /// Optional reps count
  int? get reps;
  @override

  /// Optional session index (1, 2, 3...)
  int? get sessionIndex;
  @override
  @JsonKey(ignore: true)
  _$$ChartDataPointImplCopyWith<_$ChartDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProgressiveOverloadData {
  /// Current weekly progression percentage
  double get currentPercent => throw _privateConstructorUsedError;

  /// Target min-max range for user's level
  double get targetMin => throw _privateConstructorUsedError;
  double get targetMax => throw _privateConstructorUsedError;

  /// Status classification
  OverloadStatus get status => throw _privateConstructorUsedError;

  /// User's experience level used for calculation
  String get userLevel => throw _privateConstructorUsedError;

  /// Current volume
  double get currentVolume => throw _privateConstructorUsedError;

  /// Previous volume (for comparison)
  double get previousVolume => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProgressiveOverloadDataCopyWith<ProgressiveOverloadData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressiveOverloadDataCopyWith<$Res> {
  factory $ProgressiveOverloadDataCopyWith(ProgressiveOverloadData value,
          $Res Function(ProgressiveOverloadData) then) =
      _$ProgressiveOverloadDataCopyWithImpl<$Res, ProgressiveOverloadData>;
  @useResult
  $Res call(
      {double currentPercent,
      double targetMin,
      double targetMax,
      OverloadStatus status,
      String userLevel,
      double currentVolume,
      double previousVolume});
}

/// @nodoc
class _$ProgressiveOverloadDataCopyWithImpl<$Res,
        $Val extends ProgressiveOverloadData>
    implements $ProgressiveOverloadDataCopyWith<$Res> {
  _$ProgressiveOverloadDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPercent = null,
    Object? targetMin = null,
    Object? targetMax = null,
    Object? status = null,
    Object? userLevel = null,
    Object? currentVolume = null,
    Object? previousVolume = null,
  }) {
    return _then(_value.copyWith(
      currentPercent: null == currentPercent
          ? _value.currentPercent
          : currentPercent // ignore: cast_nullable_to_non_nullable
              as double,
      targetMin: null == targetMin
          ? _value.targetMin
          : targetMin // ignore: cast_nullable_to_non_nullable
              as double,
      targetMax: null == targetMax
          ? _value.targetMax
          : targetMax // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OverloadStatus,
      userLevel: null == userLevel
          ? _value.userLevel
          : userLevel // ignore: cast_nullable_to_non_nullable
              as String,
      currentVolume: null == currentVolume
          ? _value.currentVolume
          : currentVolume // ignore: cast_nullable_to_non_nullable
              as double,
      previousVolume: null == previousVolume
          ? _value.previousVolume
          : previousVolume // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressiveOverloadDataImplCopyWith<$Res>
    implements $ProgressiveOverloadDataCopyWith<$Res> {
  factory _$$ProgressiveOverloadDataImplCopyWith(
          _$ProgressiveOverloadDataImpl value,
          $Res Function(_$ProgressiveOverloadDataImpl) then) =
      __$$ProgressiveOverloadDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double currentPercent,
      double targetMin,
      double targetMax,
      OverloadStatus status,
      String userLevel,
      double currentVolume,
      double previousVolume});
}

/// @nodoc
class __$$ProgressiveOverloadDataImplCopyWithImpl<$Res>
    extends _$ProgressiveOverloadDataCopyWithImpl<$Res,
        _$ProgressiveOverloadDataImpl>
    implements _$$ProgressiveOverloadDataImplCopyWith<$Res> {
  __$$ProgressiveOverloadDataImplCopyWithImpl(
      _$ProgressiveOverloadDataImpl _value,
      $Res Function(_$ProgressiveOverloadDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPercent = null,
    Object? targetMin = null,
    Object? targetMax = null,
    Object? status = null,
    Object? userLevel = null,
    Object? currentVolume = null,
    Object? previousVolume = null,
  }) {
    return _then(_$ProgressiveOverloadDataImpl(
      currentPercent: null == currentPercent
          ? _value.currentPercent
          : currentPercent // ignore: cast_nullable_to_non_nullable
              as double,
      targetMin: null == targetMin
          ? _value.targetMin
          : targetMin // ignore: cast_nullable_to_non_nullable
              as double,
      targetMax: null == targetMax
          ? _value.targetMax
          : targetMax // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OverloadStatus,
      userLevel: null == userLevel
          ? _value.userLevel
          : userLevel // ignore: cast_nullable_to_non_nullable
              as String,
      currentVolume: null == currentVolume
          ? _value.currentVolume
          : currentVolume // ignore: cast_nullable_to_non_nullable
              as double,
      previousVolume: null == previousVolume
          ? _value.previousVolume
          : previousVolume // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$ProgressiveOverloadDataImpl extends _ProgressiveOverloadData {
  const _$ProgressiveOverloadDataImpl(
      {required this.currentPercent,
      required this.targetMin,
      required this.targetMax,
      required this.status,
      required this.userLevel,
      required this.currentVolume,
      required this.previousVolume})
      : super._();

  /// Current weekly progression percentage
  @override
  final double currentPercent;

  /// Target min-max range for user's level
  @override
  final double targetMin;
  @override
  final double targetMax;

  /// Status classification
  @override
  final OverloadStatus status;

  /// User's experience level used for calculation
  @override
  final String userLevel;

  /// Current volume
  @override
  final double currentVolume;

  /// Previous volume (for comparison)
  @override
  final double previousVolume;

  @override
  String toString() {
    return 'ProgressiveOverloadData(currentPercent: $currentPercent, targetMin: $targetMin, targetMax: $targetMax, status: $status, userLevel: $userLevel, currentVolume: $currentVolume, previousVolume: $previousVolume)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressiveOverloadDataImpl &&
            (identical(other.currentPercent, currentPercent) ||
                other.currentPercent == currentPercent) &&
            (identical(other.targetMin, targetMin) ||
                other.targetMin == targetMin) &&
            (identical(other.targetMax, targetMax) ||
                other.targetMax == targetMax) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.userLevel, userLevel) ||
                other.userLevel == userLevel) &&
            (identical(other.currentVolume, currentVolume) ||
                other.currentVolume == currentVolume) &&
            (identical(other.previousVolume, previousVolume) ||
                other.previousVolume == previousVolume));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentPercent, targetMin,
      targetMax, status, userLevel, currentVolume, previousVolume);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressiveOverloadDataImplCopyWith<_$ProgressiveOverloadDataImpl>
      get copyWith => __$$ProgressiveOverloadDataImplCopyWithImpl<
          _$ProgressiveOverloadDataImpl>(this, _$identity);
}

abstract class _ProgressiveOverloadData extends ProgressiveOverloadData {
  const factory _ProgressiveOverloadData(
      {required final double currentPercent,
      required final double targetMin,
      required final double targetMax,
      required final OverloadStatus status,
      required final String userLevel,
      required final double currentVolume,
      required final double previousVolume}) = _$ProgressiveOverloadDataImpl;
  const _ProgressiveOverloadData._() : super._();

  @override

  /// Current weekly progression percentage
  double get currentPercent;
  @override

  /// Target min-max range for user's level
  double get targetMin;
  @override
  double get targetMax;
  @override

  /// Status classification
  OverloadStatus get status;
  @override

  /// User's experience level used for calculation
  String get userLevel;
  @override

  /// Current volume
  double get currentVolume;
  @override

  /// Previous volume (for comparison)
  double get previousVolume;
  @override
  @JsonKey(ignore: true)
  _$$ProgressiveOverloadDataImplCopyWith<_$ProgressiveOverloadDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IntensityData {
  /// Estimated 1RM in kg
  double get estimated1RM => throw _privateConstructorUsedError;

  /// Current working weight
  double get currentWeight => throw _privateConstructorUsedError;

  /// Current reps performed
  int get currentReps => throw _privateConstructorUsedError;

  /// Percentage of 1RM being used
  double get percentOf1RM => throw _privateConstructorUsedError;

  /// Formula used (Epley, Brzycki, or Epley+Brzycki)
  String get formula => throw _privateConstructorUsedError;

  /// Confidence level (High, Medium, Low)
  String get confidence => throw _privateConstructorUsedError;

  /// Intensity zone
  IntensityZone get zone => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IntensityDataCopyWith<IntensityData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntensityDataCopyWith<$Res> {
  factory $IntensityDataCopyWith(
          IntensityData value, $Res Function(IntensityData) then) =
      _$IntensityDataCopyWithImpl<$Res, IntensityData>;
  @useResult
  $Res call(
      {double estimated1RM,
      double currentWeight,
      int currentReps,
      double percentOf1RM,
      String formula,
      String confidence,
      IntensityZone zone});
}

/// @nodoc
class _$IntensityDataCopyWithImpl<$Res, $Val extends IntensityData>
    implements $IntensityDataCopyWith<$Res> {
  _$IntensityDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimated1RM = null,
    Object? currentWeight = null,
    Object? currentReps = null,
    Object? percentOf1RM = null,
    Object? formula = null,
    Object? confidence = null,
    Object? zone = null,
  }) {
    return _then(_value.copyWith(
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double,
      currentReps: null == currentReps
          ? _value.currentReps
          : currentReps // ignore: cast_nullable_to_non_nullable
              as int,
      percentOf1RM: null == percentOf1RM
          ? _value.percentOf1RM
          : percentOf1RM // ignore: cast_nullable_to_non_nullable
              as double,
      formula: null == formula
          ? _value.formula
          : formula // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as String,
      zone: null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as IntensityZone,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IntensityDataImplCopyWith<$Res>
    implements $IntensityDataCopyWith<$Res> {
  factory _$$IntensityDataImplCopyWith(
          _$IntensityDataImpl value, $Res Function(_$IntensityDataImpl) then) =
      __$$IntensityDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double estimated1RM,
      double currentWeight,
      int currentReps,
      double percentOf1RM,
      String formula,
      String confidence,
      IntensityZone zone});
}

/// @nodoc
class __$$IntensityDataImplCopyWithImpl<$Res>
    extends _$IntensityDataCopyWithImpl<$Res, _$IntensityDataImpl>
    implements _$$IntensityDataImplCopyWith<$Res> {
  __$$IntensityDataImplCopyWithImpl(
      _$IntensityDataImpl _value, $Res Function(_$IntensityDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimated1RM = null,
    Object? currentWeight = null,
    Object? currentReps = null,
    Object? percentOf1RM = null,
    Object? formula = null,
    Object? confidence = null,
    Object? zone = null,
  }) {
    return _then(_$IntensityDataImpl(
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double,
      currentReps: null == currentReps
          ? _value.currentReps
          : currentReps // ignore: cast_nullable_to_non_nullable
              as int,
      percentOf1RM: null == percentOf1RM
          ? _value.percentOf1RM
          : percentOf1RM // ignore: cast_nullable_to_non_nullable
              as double,
      formula: null == formula
          ? _value.formula
          : formula // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as String,
      zone: null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as IntensityZone,
    ));
  }
}

/// @nodoc

class _$IntensityDataImpl extends _IntensityData {
  const _$IntensityDataImpl(
      {required this.estimated1RM,
      required this.currentWeight,
      required this.currentReps,
      required this.percentOf1RM,
      required this.formula,
      required this.confidence,
      required this.zone})
      : super._();

  /// Estimated 1RM in kg
  @override
  final double estimated1RM;

  /// Current working weight
  @override
  final double currentWeight;

  /// Current reps performed
  @override
  final int currentReps;

  /// Percentage of 1RM being used
  @override
  final double percentOf1RM;

  /// Formula used (Epley, Brzycki, or Epley+Brzycki)
  @override
  final String formula;

  /// Confidence level (High, Medium, Low)
  @override
  final String confidence;

  /// Intensity zone
  @override
  final IntensityZone zone;

  @override
  String toString() {
    return 'IntensityData(estimated1RM: $estimated1RM, currentWeight: $currentWeight, currentReps: $currentReps, percentOf1RM: $percentOf1RM, formula: $formula, confidence: $confidence, zone: $zone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntensityDataImpl &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.currentReps, currentReps) ||
                other.currentReps == currentReps) &&
            (identical(other.percentOf1RM, percentOf1RM) ||
                other.percentOf1RM == percentOf1RM) &&
            (identical(other.formula, formula) || other.formula == formula) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.zone, zone) || other.zone == zone));
  }

  @override
  int get hashCode => Object.hash(runtimeType, estimated1RM, currentWeight,
      currentReps, percentOf1RM, formula, confidence, zone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IntensityDataImplCopyWith<_$IntensityDataImpl> get copyWith =>
      __$$IntensityDataImplCopyWithImpl<_$IntensityDataImpl>(this, _$identity);
}

abstract class _IntensityData extends IntensityData {
  const factory _IntensityData(
      {required final double estimated1RM,
      required final double currentWeight,
      required final int currentReps,
      required final double percentOf1RM,
      required final String formula,
      required final String confidence,
      required final IntensityZone zone}) = _$IntensityDataImpl;
  const _IntensityData._() : super._();

  @override

  /// Estimated 1RM in kg
  double get estimated1RM;
  @override

  /// Current working weight
  double get currentWeight;
  @override

  /// Current reps performed
  int get currentReps;
  @override

  /// Percentage of 1RM being used
  double get percentOf1RM;
  @override

  /// Formula used (Epley, Brzycki, or Epley+Brzycki)
  String get formula;
  @override

  /// Confidence level (High, Medium, Low)
  String get confidence;
  @override

  /// Intensity zone
  IntensityZone get zone;
  @override
  @JsonKey(ignore: true)
  _$$IntensityDataImplCopyWith<_$IntensityDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExerciseAnalyticsData {
  /// Exercise identifier
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name for display
  String get exerciseName => throw _privateConstructorUsedError;

  /// Weight progression data points (for L1 chart)
  List<ChartDataPoint> get weightHistory => throw _privateConstructorUsedError;

  /// Volume progression data points
  List<ChartDataPoint> get volumeHistory => throw _privateConstructorUsedError;

  /// RPE history (separate for correlations)
  List<ChartDataPoint> get rpeHistory => throw _privateConstructorUsedError;

  /// Trend analysis result
  TrendAnalysis get trend => throw _privateConstructorUsedError;

  /// Progressive overload analysis
  ProgressiveOverloadData get overload => throw _privateConstructorUsedError;

  /// Intensity/1RM analysis
  IntensityData get intensity => throw _privateConstructorUsedError;

  /// Correlation results (cached - not recalculated on each access)
  CorrelationResults get correlations => throw _privateConstructorUsedError;

  /// Last updated timestamp
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Number of sessions analyzed
  int get sessionCount => throw _privateConstructorUsedError;

  /// Time span of data (in days)
  int get dataSpanDays => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExerciseAnalyticsDataCopyWith<ExerciseAnalyticsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseAnalyticsDataCopyWith<$Res> {
  factory $ExerciseAnalyticsDataCopyWith(ExerciseAnalyticsData value,
          $Res Function(ExerciseAnalyticsData) then) =
      _$ExerciseAnalyticsDataCopyWithImpl<$Res, ExerciseAnalyticsData>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      List<ChartDataPoint> weightHistory,
      List<ChartDataPoint> volumeHistory,
      List<ChartDataPoint> rpeHistory,
      TrendAnalysis trend,
      ProgressiveOverloadData overload,
      IntensityData intensity,
      CorrelationResults correlations,
      DateTime lastUpdated,
      int sessionCount,
      int dataSpanDays});

  $ProgressiveOverloadDataCopyWith<$Res> get overload;
  $IntensityDataCopyWith<$Res> get intensity;
  $CorrelationResultsCopyWith<$Res> get correlations;
}

/// @nodoc
class _$ExerciseAnalyticsDataCopyWithImpl<$Res,
        $Val extends ExerciseAnalyticsData>
    implements $ExerciseAnalyticsDataCopyWith<$Res> {
  _$ExerciseAnalyticsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? weightHistory = null,
    Object? volumeHistory = null,
    Object? rpeHistory = null,
    Object? trend = null,
    Object? overload = null,
    Object? intensity = null,
    Object? correlations = null,
    Object? lastUpdated = null,
    Object? sessionCount = null,
    Object? dataSpanDays = null,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weightHistory: null == weightHistory
          ? _value.weightHistory
          : weightHistory // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      volumeHistory: null == volumeHistory
          ? _value.volumeHistory
          : volumeHistory // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      rpeHistory: null == rpeHistory
          ? _value.rpeHistory
          : rpeHistory // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TrendAnalysis,
      overload: null == overload
          ? _value.overload
          : overload // ignore: cast_nullable_to_non_nullable
              as ProgressiveOverloadData,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as IntensityData,
      correlations: null == correlations
          ? _value.correlations
          : correlations // ignore: cast_nullable_to_non_nullable
              as CorrelationResults,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      dataSpanDays: null == dataSpanDays
          ? _value.dataSpanDays
          : dataSpanDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProgressiveOverloadDataCopyWith<$Res> get overload {
    return $ProgressiveOverloadDataCopyWith<$Res>(_value.overload, (value) {
      return _then(_value.copyWith(overload: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $IntensityDataCopyWith<$Res> get intensity {
    return $IntensityDataCopyWith<$Res>(_value.intensity, (value) {
      return _then(_value.copyWith(intensity: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CorrelationResultsCopyWith<$Res> get correlations {
    return $CorrelationResultsCopyWith<$Res>(_value.correlations, (value) {
      return _then(_value.copyWith(correlations: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExerciseAnalyticsDataImplCopyWith<$Res>
    implements $ExerciseAnalyticsDataCopyWith<$Res> {
  factory _$$ExerciseAnalyticsDataImplCopyWith(
          _$ExerciseAnalyticsDataImpl value,
          $Res Function(_$ExerciseAnalyticsDataImpl) then) =
      __$$ExerciseAnalyticsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      List<ChartDataPoint> weightHistory,
      List<ChartDataPoint> volumeHistory,
      List<ChartDataPoint> rpeHistory,
      TrendAnalysis trend,
      ProgressiveOverloadData overload,
      IntensityData intensity,
      CorrelationResults correlations,
      DateTime lastUpdated,
      int sessionCount,
      int dataSpanDays});

  @override
  $ProgressiveOverloadDataCopyWith<$Res> get overload;
  @override
  $IntensityDataCopyWith<$Res> get intensity;
  @override
  $CorrelationResultsCopyWith<$Res> get correlations;
}

/// @nodoc
class __$$ExerciseAnalyticsDataImplCopyWithImpl<$Res>
    extends _$ExerciseAnalyticsDataCopyWithImpl<$Res,
        _$ExerciseAnalyticsDataImpl>
    implements _$$ExerciseAnalyticsDataImplCopyWith<$Res> {
  __$$ExerciseAnalyticsDataImplCopyWithImpl(_$ExerciseAnalyticsDataImpl _value,
      $Res Function(_$ExerciseAnalyticsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? weightHistory = null,
    Object? volumeHistory = null,
    Object? rpeHistory = null,
    Object? trend = null,
    Object? overload = null,
    Object? intensity = null,
    Object? correlations = null,
    Object? lastUpdated = null,
    Object? sessionCount = null,
    Object? dataSpanDays = null,
  }) {
    return _then(_$ExerciseAnalyticsDataImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weightHistory: null == weightHistory
          ? _value._weightHistory
          : weightHistory // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      volumeHistory: null == volumeHistory
          ? _value._volumeHistory
          : volumeHistory // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      rpeHistory: null == rpeHistory
          ? _value._rpeHistory
          : rpeHistory // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TrendAnalysis,
      overload: null == overload
          ? _value.overload
          : overload // ignore: cast_nullable_to_non_nullable
              as ProgressiveOverloadData,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as IntensityData,
      correlations: null == correlations
          ? _value.correlations
          : correlations // ignore: cast_nullable_to_non_nullable
              as CorrelationResults,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      dataSpanDays: null == dataSpanDays
          ? _value.dataSpanDays
          : dataSpanDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ExerciseAnalyticsDataImpl extends _ExerciseAnalyticsData {
  const _$ExerciseAnalyticsDataImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required final List<ChartDataPoint> weightHistory,
      required final List<ChartDataPoint> volumeHistory,
      required final List<ChartDataPoint> rpeHistory,
      required this.trend,
      required this.overload,
      required this.intensity,
      required this.correlations,
      required this.lastUpdated,
      this.sessionCount = 0,
      this.dataSpanDays = 0})
      : _weightHistory = weightHistory,
        _volumeHistory = volumeHistory,
        _rpeHistory = rpeHistory,
        super._();

  /// Exercise identifier
  @override
  final String exerciseId;

  /// Exercise name for display
  @override
  final String exerciseName;

  /// Weight progression data points (for L1 chart)
  final List<ChartDataPoint> _weightHistory;

  /// Weight progression data points (for L1 chart)
  @override
  List<ChartDataPoint> get weightHistory {
    if (_weightHistory is EqualUnmodifiableListView) return _weightHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weightHistory);
  }

  /// Volume progression data points
  final List<ChartDataPoint> _volumeHistory;

  /// Volume progression data points
  @override
  List<ChartDataPoint> get volumeHistory {
    if (_volumeHistory is EqualUnmodifiableListView) return _volumeHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_volumeHistory);
  }

  /// RPE history (separate for correlations)
  final List<ChartDataPoint> _rpeHistory;

  /// RPE history (separate for correlations)
  @override
  List<ChartDataPoint> get rpeHistory {
    if (_rpeHistory is EqualUnmodifiableListView) return _rpeHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rpeHistory);
  }

  /// Trend analysis result
  @override
  final TrendAnalysis trend;

  /// Progressive overload analysis
  @override
  final ProgressiveOverloadData overload;

  /// Intensity/1RM analysis
  @override
  final IntensityData intensity;

  /// Correlation results (cached - not recalculated on each access)
  @override
  final CorrelationResults correlations;

  /// Last updated timestamp
  @override
  final DateTime lastUpdated;

  /// Number of sessions analyzed
  @override
  @JsonKey()
  final int sessionCount;

  /// Time span of data (in days)
  @override
  @JsonKey()
  final int dataSpanDays;

  @override
  String toString() {
    return 'ExerciseAnalyticsData(exerciseId: $exerciseId, exerciseName: $exerciseName, weightHistory: $weightHistory, volumeHistory: $volumeHistory, rpeHistory: $rpeHistory, trend: $trend, overload: $overload, intensity: $intensity, correlations: $correlations, lastUpdated: $lastUpdated, sessionCount: $sessionCount, dataSpanDays: $dataSpanDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseAnalyticsDataImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            const DeepCollectionEquality()
                .equals(other._weightHistory, _weightHistory) &&
            const DeepCollectionEquality()
                .equals(other._volumeHistory, _volumeHistory) &&
            const DeepCollectionEquality()
                .equals(other._rpeHistory, _rpeHistory) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.overload, overload) ||
                other.overload == overload) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.correlations, correlations) ||
                other.correlations == correlations) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.dataSpanDays, dataSpanDays) ||
                other.dataSpanDays == dataSpanDays));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      exerciseId,
      exerciseName,
      const DeepCollectionEquality().hash(_weightHistory),
      const DeepCollectionEquality().hash(_volumeHistory),
      const DeepCollectionEquality().hash(_rpeHistory),
      trend,
      overload,
      intensity,
      correlations,
      lastUpdated,
      sessionCount,
      dataSpanDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseAnalyticsDataImplCopyWith<_$ExerciseAnalyticsDataImpl>
      get copyWith => __$$ExerciseAnalyticsDataImplCopyWithImpl<
          _$ExerciseAnalyticsDataImpl>(this, _$identity);
}

abstract class _ExerciseAnalyticsData extends ExerciseAnalyticsData {
  const factory _ExerciseAnalyticsData(
      {required final String exerciseId,
      required final String exerciseName,
      required final List<ChartDataPoint> weightHistory,
      required final List<ChartDataPoint> volumeHistory,
      required final List<ChartDataPoint> rpeHistory,
      required final TrendAnalysis trend,
      required final ProgressiveOverloadData overload,
      required final IntensityData intensity,
      required final CorrelationResults correlations,
      required final DateTime lastUpdated,
      final int sessionCount,
      final int dataSpanDays}) = _$ExerciseAnalyticsDataImpl;
  const _ExerciseAnalyticsData._() : super._();

  @override

  /// Exercise identifier
  String get exerciseId;
  @override

  /// Exercise name for display
  String get exerciseName;
  @override

  /// Weight progression data points (for L1 chart)
  List<ChartDataPoint> get weightHistory;
  @override

  /// Volume progression data points
  List<ChartDataPoint> get volumeHistory;
  @override

  /// RPE history (separate for correlations)
  List<ChartDataPoint> get rpeHistory;
  @override

  /// Trend analysis result
  TrendAnalysis get trend;
  @override

  /// Progressive overload analysis
  ProgressiveOverloadData get overload;
  @override

  /// Intensity/1RM analysis
  IntensityData get intensity;
  @override

  /// Correlation results (cached - not recalculated on each access)
  CorrelationResults get correlations;
  @override

  /// Last updated timestamp
  DateTime get lastUpdated;
  @override

  /// Number of sessions analyzed
  int get sessionCount;
  @override

  /// Time span of data (in days)
  int get dataSpanDays;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseAnalyticsDataImplCopyWith<_$ExerciseAnalyticsDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
