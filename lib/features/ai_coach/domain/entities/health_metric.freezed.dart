// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_metric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthMetric _$HealthMetricFromJson(Map<String, dynamic> json) {
  return _HealthMetric.fromJson(json);
}

/// @nodoc
mixin _$HealthMetric {
  /// Metric type (steps, heart rate, etc.)
  HealthMetricType get type => throw _privateConstructorUsedError;

  /// Numeric value (e.g., 8500 steps, 72 BPM)
  double get value => throw _privateConstructorUsedError;

  /// Unit of measurement (count, bpm, kcal, minutes)
  String get unit => throw _privateConstructorUsedError;

  /// Start timestamp for metric collection
  DateTime get dateFrom => throw _privateConstructorUsedError;

  /// End timestamp for metric collection
  DateTime get dateTo => throw _privateConstructorUsedError;

  /// Source device (optional)
  String? get sourceDevice => throw _privateConstructorUsedError;

  /// Source app (optional)
  String? get sourceApp => throw _privateConstructorUsedError;

  /// Workout type (for HealthMetricType.workout only)
  String? get workoutType => throw _privateConstructorUsedError;

  /// Workout duration (seconds, for HealthMetricType.workout only)
  int? get workoutDuration => throw _privateConstructorUsedError;

  /// Workout distance (meters, for HealthMetricType.workout only)
  double? get workoutDistance => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthMetricCopyWith<HealthMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthMetricCopyWith<$Res> {
  factory $HealthMetricCopyWith(
          HealthMetric value, $Res Function(HealthMetric) then) =
      _$HealthMetricCopyWithImpl<$Res, HealthMetric>;
  @useResult
  $Res call(
      {HealthMetricType type,
      double value,
      String unit,
      DateTime dateFrom,
      DateTime dateTo,
      String? sourceDevice,
      String? sourceApp,
      String? workoutType,
      int? workoutDuration,
      double? workoutDistance});
}

/// @nodoc
class _$HealthMetricCopyWithImpl<$Res, $Val extends HealthMetric>
    implements $HealthMetricCopyWith<$Res> {
  _$HealthMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? dateFrom = null,
    Object? dateTo = null,
    Object? sourceDevice = freezed,
    Object? sourceApp = freezed,
    Object? workoutType = freezed,
    Object? workoutDuration = freezed,
    Object? workoutDistance = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HealthMetricType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sourceDevice: freezed == sourceDevice
          ? _value.sourceDevice
          : sourceDevice // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceApp: freezed == sourceApp
          ? _value.sourceApp
          : sourceApp // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutType: freezed == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutDuration: freezed == workoutDuration
          ? _value.workoutDuration
          : workoutDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      workoutDistance: freezed == workoutDistance
          ? _value.workoutDistance
          : workoutDistance // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthMetricImplCopyWith<$Res>
    implements $HealthMetricCopyWith<$Res> {
  factory _$$HealthMetricImplCopyWith(
          _$HealthMetricImpl value, $Res Function(_$HealthMetricImpl) then) =
      __$$HealthMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {HealthMetricType type,
      double value,
      String unit,
      DateTime dateFrom,
      DateTime dateTo,
      String? sourceDevice,
      String? sourceApp,
      String? workoutType,
      int? workoutDuration,
      double? workoutDistance});
}

/// @nodoc
class __$$HealthMetricImplCopyWithImpl<$Res>
    extends _$HealthMetricCopyWithImpl<$Res, _$HealthMetricImpl>
    implements _$$HealthMetricImplCopyWith<$Res> {
  __$$HealthMetricImplCopyWithImpl(
      _$HealthMetricImpl _value, $Res Function(_$HealthMetricImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? dateFrom = null,
    Object? dateTo = null,
    Object? sourceDevice = freezed,
    Object? sourceApp = freezed,
    Object? workoutType = freezed,
    Object? workoutDuration = freezed,
    Object? workoutDistance = freezed,
  }) {
    return _then(_$HealthMetricImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HealthMetricType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      dateFrom: null == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dateTo: null == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sourceDevice: freezed == sourceDevice
          ? _value.sourceDevice
          : sourceDevice // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceApp: freezed == sourceApp
          ? _value.sourceApp
          : sourceApp // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutType: freezed == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutDuration: freezed == workoutDuration
          ? _value.workoutDuration
          : workoutDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      workoutDistance: freezed == workoutDistance
          ? _value.workoutDistance
          : workoutDistance // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthMetricImpl implements _HealthMetric {
  const _$HealthMetricImpl(
      {required this.type,
      required this.value,
      required this.unit,
      required this.dateFrom,
      required this.dateTo,
      this.sourceDevice,
      this.sourceApp,
      this.workoutType,
      this.workoutDuration,
      this.workoutDistance});

  factory _$HealthMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthMetricImplFromJson(json);

  /// Metric type (steps, heart rate, etc.)
  @override
  final HealthMetricType type;

  /// Numeric value (e.g., 8500 steps, 72 BPM)
  @override
  final double value;

  /// Unit of measurement (count, bpm, kcal, minutes)
  @override
  final String unit;

  /// Start timestamp for metric collection
  @override
  final DateTime dateFrom;

  /// End timestamp for metric collection
  @override
  final DateTime dateTo;

  /// Source device (optional)
  @override
  final String? sourceDevice;

  /// Source app (optional)
  @override
  final String? sourceApp;

  /// Workout type (for HealthMetricType.workout only)
  @override
  final String? workoutType;

  /// Workout duration (seconds, for HealthMetricType.workout only)
  @override
  final int? workoutDuration;

  /// Workout distance (meters, for HealthMetricType.workout only)
  @override
  final double? workoutDistance;

  @override
  String toString() {
    return 'HealthMetric(type: $type, value: $value, unit: $unit, dateFrom: $dateFrom, dateTo: $dateTo, sourceDevice: $sourceDevice, sourceApp: $sourceApp, workoutType: $workoutType, workoutDuration: $workoutDuration, workoutDistance: $workoutDistance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthMetricImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            (identical(other.sourceDevice, sourceDevice) ||
                other.sourceDevice == sourceDevice) &&
            (identical(other.sourceApp, sourceApp) ||
                other.sourceApp == sourceApp) &&
            (identical(other.workoutType, workoutType) ||
                other.workoutType == workoutType) &&
            (identical(other.workoutDuration, workoutDuration) ||
                other.workoutDuration == workoutDuration) &&
            (identical(other.workoutDistance, workoutDistance) ||
                other.workoutDistance == workoutDistance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      value,
      unit,
      dateFrom,
      dateTo,
      sourceDevice,
      sourceApp,
      workoutType,
      workoutDuration,
      workoutDistance);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthMetricImplCopyWith<_$HealthMetricImpl> get copyWith =>
      __$$HealthMetricImplCopyWithImpl<_$HealthMetricImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthMetricImplToJson(
      this,
    );
  }
}

abstract class _HealthMetric implements HealthMetric {
  const factory _HealthMetric(
      {required final HealthMetricType type,
      required final double value,
      required final String unit,
      required final DateTime dateFrom,
      required final DateTime dateTo,
      final String? sourceDevice,
      final String? sourceApp,
      final String? workoutType,
      final int? workoutDuration,
      final double? workoutDistance}) = _$HealthMetricImpl;

  factory _HealthMetric.fromJson(Map<String, dynamic> json) =
      _$HealthMetricImpl.fromJson;

  @override

  /// Metric type (steps, heart rate, etc.)
  HealthMetricType get type;
  @override

  /// Numeric value (e.g., 8500 steps, 72 BPM)
  double get value;
  @override

  /// Unit of measurement (count, bpm, kcal, minutes)
  String get unit;
  @override

  /// Start timestamp for metric collection
  DateTime get dateFrom;
  @override

  /// End timestamp for metric collection
  DateTime get dateTo;
  @override

  /// Source device (optional)
  String? get sourceDevice;
  @override

  /// Source app (optional)
  String? get sourceApp;
  @override

  /// Workout type (for HealthMetricType.workout only)
  String? get workoutType;
  @override

  /// Workout duration (seconds, for HealthMetricType.workout only)
  int? get workoutDuration;
  @override

  /// Workout distance (meters, for HealthMetricType.workout only)
  double? get workoutDistance;
  @override
  @JsonKey(ignore: true)
  _$$HealthMetricImplCopyWith<_$HealthMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthMetricSummary _$HealthMetricSummaryFromJson(Map<String, dynamic> json) {
  return _HealthMetricSummary.fromJson(json);
}

/// @nodoc
mixin _$HealthMetricSummary {
  /// Metric type being summarized
  HealthMetricType get metricType => throw _privateConstructorUsedError;

  /// Total/sum of all values in period
  double get totalValue => throw _privateConstructorUsedError;

  /// Average value per day
  double get averageValue => throw _privateConstructorUsedError;

  /// Minimum value in period
  double get minValue => throw _privateConstructorUsedError;

  /// Maximum value in period
  double get maxValue => throw _privateConstructorUsedError;

  /// Number of data points
  int get dataPoints => throw _privateConstructorUsedError;

  /// Period start
  DateTime get periodStart => throw _privateConstructorUsedError;

  /// Period end
  DateTime get periodEnd => throw _privateConstructorUsedError;

  /// Unit of measurement
  String get unit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthMetricSummaryCopyWith<HealthMetricSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthMetricSummaryCopyWith<$Res> {
  factory $HealthMetricSummaryCopyWith(
          HealthMetricSummary value, $Res Function(HealthMetricSummary) then) =
      _$HealthMetricSummaryCopyWithImpl<$Res, HealthMetricSummary>;
  @useResult
  $Res call(
      {HealthMetricType metricType,
      double totalValue,
      double averageValue,
      double minValue,
      double maxValue,
      int dataPoints,
      DateTime periodStart,
      DateTime periodEnd,
      String unit});
}

/// @nodoc
class _$HealthMetricSummaryCopyWithImpl<$Res, $Val extends HealthMetricSummary>
    implements $HealthMetricSummaryCopyWith<$Res> {
  _$HealthMetricSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metricType = null,
    Object? totalValue = null,
    Object? averageValue = null,
    Object? minValue = null,
    Object? maxValue = null,
    Object? dataPoints = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? unit = null,
  }) {
    return _then(_value.copyWith(
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as HealthMetricType,
      totalValue: null == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double,
      averageValue: null == averageValue
          ? _value.averageValue
          : averageValue // ignore: cast_nullable_to_non_nullable
              as double,
      minValue: null == minValue
          ? _value.minValue
          : minValue // ignore: cast_nullable_to_non_nullable
              as double,
      maxValue: null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as double,
      dataPoints: null == dataPoints
          ? _value.dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthMetricSummaryImplCopyWith<$Res>
    implements $HealthMetricSummaryCopyWith<$Res> {
  factory _$$HealthMetricSummaryImplCopyWith(_$HealthMetricSummaryImpl value,
          $Res Function(_$HealthMetricSummaryImpl) then) =
      __$$HealthMetricSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {HealthMetricType metricType,
      double totalValue,
      double averageValue,
      double minValue,
      double maxValue,
      int dataPoints,
      DateTime periodStart,
      DateTime periodEnd,
      String unit});
}

/// @nodoc
class __$$HealthMetricSummaryImplCopyWithImpl<$Res>
    extends _$HealthMetricSummaryCopyWithImpl<$Res, _$HealthMetricSummaryImpl>
    implements _$$HealthMetricSummaryImplCopyWith<$Res> {
  __$$HealthMetricSummaryImplCopyWithImpl(_$HealthMetricSummaryImpl _value,
      $Res Function(_$HealthMetricSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metricType = null,
    Object? totalValue = null,
    Object? averageValue = null,
    Object? minValue = null,
    Object? maxValue = null,
    Object? dataPoints = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? unit = null,
  }) {
    return _then(_$HealthMetricSummaryImpl(
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as HealthMetricType,
      totalValue: null == totalValue
          ? _value.totalValue
          : totalValue // ignore: cast_nullable_to_non_nullable
              as double,
      averageValue: null == averageValue
          ? _value.averageValue
          : averageValue // ignore: cast_nullable_to_non_nullable
              as double,
      minValue: null == minValue
          ? _value.minValue
          : minValue // ignore: cast_nullable_to_non_nullable
              as double,
      maxValue: null == maxValue
          ? _value.maxValue
          : maxValue // ignore: cast_nullable_to_non_nullable
              as double,
      dataPoints: null == dataPoints
          ? _value.dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthMetricSummaryImpl implements _HealthMetricSummary {
  const _$HealthMetricSummaryImpl(
      {required this.metricType,
      required this.totalValue,
      required this.averageValue,
      required this.minValue,
      required this.maxValue,
      required this.dataPoints,
      required this.periodStart,
      required this.periodEnd,
      required this.unit});

  factory _$HealthMetricSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthMetricSummaryImplFromJson(json);

  /// Metric type being summarized
  @override
  final HealthMetricType metricType;

  /// Total/sum of all values in period
  @override
  final double totalValue;

  /// Average value per day
  @override
  final double averageValue;

  /// Minimum value in period
  @override
  final double minValue;

  /// Maximum value in period
  @override
  final double maxValue;

  /// Number of data points
  @override
  final int dataPoints;

  /// Period start
  @override
  final DateTime periodStart;

  /// Period end
  @override
  final DateTime periodEnd;

  /// Unit of measurement
  @override
  final String unit;

  @override
  String toString() {
    return 'HealthMetricSummary(metricType: $metricType, totalValue: $totalValue, averageValue: $averageValue, minValue: $minValue, maxValue: $maxValue, dataPoints: $dataPoints, periodStart: $periodStart, periodEnd: $periodEnd, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthMetricSummaryImpl &&
            (identical(other.metricType, metricType) ||
                other.metricType == metricType) &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue) &&
            (identical(other.averageValue, averageValue) ||
                other.averageValue == averageValue) &&
            (identical(other.minValue, minValue) ||
                other.minValue == minValue) &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue) &&
            (identical(other.dataPoints, dataPoints) ||
                other.dataPoints == dataPoints) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      metricType,
      totalValue,
      averageValue,
      minValue,
      maxValue,
      dataPoints,
      periodStart,
      periodEnd,
      unit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthMetricSummaryImplCopyWith<_$HealthMetricSummaryImpl> get copyWith =>
      __$$HealthMetricSummaryImplCopyWithImpl<_$HealthMetricSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthMetricSummaryImplToJson(
      this,
    );
  }
}

abstract class _HealthMetricSummary implements HealthMetricSummary {
  const factory _HealthMetricSummary(
      {required final HealthMetricType metricType,
      required final double totalValue,
      required final double averageValue,
      required final double minValue,
      required final double maxValue,
      required final int dataPoints,
      required final DateTime periodStart,
      required final DateTime periodEnd,
      required final String unit}) = _$HealthMetricSummaryImpl;

  factory _HealthMetricSummary.fromJson(Map<String, dynamic> json) =
      _$HealthMetricSummaryImpl.fromJson;

  @override

  /// Metric type being summarized
  HealthMetricType get metricType;
  @override

  /// Total/sum of all values in period
  double get totalValue;
  @override

  /// Average value per day
  double get averageValue;
  @override

  /// Minimum value in period
  double get minValue;
  @override

  /// Maximum value in period
  double get maxValue;
  @override

  /// Number of data points
  int get dataPoints;
  @override

  /// Period start
  DateTime get periodStart;
  @override

  /// Period end
  DateTime get periodEnd;
  @override

  /// Unit of measurement
  String get unit;
  @override
  @JsonKey(ignore: true)
  _$$HealthMetricSummaryImplCopyWith<_$HealthMetricSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
