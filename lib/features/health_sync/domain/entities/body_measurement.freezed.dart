// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BodyMeasurement _$BodyMeasurementFromJson(Map<String, dynamic> json) {
  return _BodyMeasurement.fromJson(json);
}

/// @nodoc
mixin _$BodyMeasurement {
  /// Numeric value of the measurement
  double get value => throw _privateConstructorUsedError;

  /// Unit of measurement (kg, lbs, percent, etc.)
  MeasurementUnit get unit => throw _privateConstructorUsedError;

  /// When the measurement was recorded (timestamp)
  DateTime get recordedAt => throw _privateConstructorUsedError;

  /// Type of health data this measurement represents
  HealthDataType get dataType => throw _privateConstructorUsedError;

  /// Source of the measurement
  /// - 'FitLog': Manual entry in app
  /// - 'HealthKit': Synced from Apple Health (iOS)
  /// - 'Health Connect': Synced from Health Connect (Android)
  String? get source => throw _privateConstructorUsedError;

  /// Serializes this BodyMeasurement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BodyMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BodyMeasurementCopyWith<BodyMeasurement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyMeasurementCopyWith<$Res> {
  factory $BodyMeasurementCopyWith(
    BodyMeasurement value,
    $Res Function(BodyMeasurement) then,
  ) = _$BodyMeasurementCopyWithImpl<$Res, BodyMeasurement>;
  @useResult
  $Res call({
    double value,
    MeasurementUnit unit,
    DateTime recordedAt,
    HealthDataType dataType,
    String? source,
  });
}

/// @nodoc
class _$BodyMeasurementCopyWithImpl<$Res, $Val extends BodyMeasurement>
    implements $BodyMeasurementCopyWith<$Res> {
  _$BodyMeasurementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BodyMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? unit = null,
    Object? recordedAt = null,
    Object? dataType = null,
    Object? source = freezed,
  }) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as MeasurementUnit,
            recordedAt: null == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dataType: null == dataType
                ? _value.dataType
                : dataType // ignore: cast_nullable_to_non_nullable
                      as HealthDataType,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BodyMeasurementImplCopyWith<$Res>
    implements $BodyMeasurementCopyWith<$Res> {
  factory _$$BodyMeasurementImplCopyWith(
    _$BodyMeasurementImpl value,
    $Res Function(_$BodyMeasurementImpl) then,
  ) = __$$BodyMeasurementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double value,
    MeasurementUnit unit,
    DateTime recordedAt,
    HealthDataType dataType,
    String? source,
  });
}

/// @nodoc
class __$$BodyMeasurementImplCopyWithImpl<$Res>
    extends _$BodyMeasurementCopyWithImpl<$Res, _$BodyMeasurementImpl>
    implements _$$BodyMeasurementImplCopyWith<$Res> {
  __$$BodyMeasurementImplCopyWithImpl(
    _$BodyMeasurementImpl _value,
    $Res Function(_$BodyMeasurementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BodyMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? unit = null,
    Object? recordedAt = null,
    Object? dataType = null,
    Object? source = freezed,
  }) {
    return _then(
      _$BodyMeasurementImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as MeasurementUnit,
        recordedAt: null == recordedAt
            ? _value.recordedAt
            : recordedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dataType: null == dataType
            ? _value.dataType
            : dataType // ignore: cast_nullable_to_non_nullable
                  as HealthDataType,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyMeasurementImpl implements _BodyMeasurement {
  const _$BodyMeasurementImpl({
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.dataType,
    this.source,
  });

  factory _$BodyMeasurementImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyMeasurementImplFromJson(json);

  /// Numeric value of the measurement
  @override
  final double value;

  /// Unit of measurement (kg, lbs, percent, etc.)
  @override
  final MeasurementUnit unit;

  /// When the measurement was recorded (timestamp)
  @override
  final DateTime recordedAt;

  /// Type of health data this measurement represents
  @override
  final HealthDataType dataType;

  /// Source of the measurement
  /// - 'FitLog': Manual entry in app
  /// - 'HealthKit': Synced from Apple Health (iOS)
  /// - 'Health Connect': Synced from Health Connect (Android)
  @override
  final String? source;

  @override
  String toString() {
    return 'BodyMeasurement(value: $value, unit: $unit, recordedAt: $recordedAt, dataType: $dataType, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyMeasurementImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.dataType, dataType) ||
                other.dataType == dataType) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, value, unit, recordedAt, dataType, source);

  /// Create a copy of BodyMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyMeasurementImplCopyWith<_$BodyMeasurementImpl> get copyWith =>
      __$$BodyMeasurementImplCopyWithImpl<_$BodyMeasurementImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyMeasurementImplToJson(this);
  }
}

abstract class _BodyMeasurement implements BodyMeasurement {
  const factory _BodyMeasurement({
    required final double value,
    required final MeasurementUnit unit,
    required final DateTime recordedAt,
    required final HealthDataType dataType,
    final String? source,
  }) = _$BodyMeasurementImpl;

  factory _BodyMeasurement.fromJson(Map<String, dynamic> json) =
      _$BodyMeasurementImpl.fromJson;

  /// Numeric value of the measurement
  @override
  double get value;

  /// Unit of measurement (kg, lbs, percent, etc.)
  @override
  MeasurementUnit get unit;

  /// When the measurement was recorded (timestamp)
  @override
  DateTime get recordedAt;

  /// Type of health data this measurement represents
  @override
  HealthDataType get dataType;

  /// Source of the measurement
  /// - 'FitLog': Manual entry in app
  /// - 'HealthKit': Synced from Apple Health (iOS)
  /// - 'Health Connect': Synced from Health Connect (Android)
  @override
  String? get source;

  /// Create a copy of BodyMeasurement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BodyMeasurementImplCopyWith<_$BodyMeasurementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
