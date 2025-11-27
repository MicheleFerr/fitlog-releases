// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_mapping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExerciseMapping _$ExerciseMappingFromJson(Map<String, dynamic> json) {
  return _ExerciseMapping.fromJson(json);
}

/// @nodoc
mixin _$ExerciseMapping {
  /// GymBro exercise ID
  String get gymbroId => throw _privateConstructorUsedError;

  /// GymBro exercise name
  String get gymbroName => throw _privateConstructorUsedError;

  /// GymBro equipment type
  String get gymbroEquipment => throw _privateConstructorUsedError;

  /// GymBro muscle focus (e.g., "PETT, TRIC") - nullable for exercises without defined focus
  String? get gymbroFocus => throw _privateConstructorUsedError;

  /// Semantic similarity confidence (0.0-1.0)
  double get confidence => throw _privateConstructorUsedError;

  /// Mapping status: "auto", "review", or "fallback"
  MappingStatus get status => throw _privateConstructorUsedError;

  /// Strength standard ID (null if fallback)
  String? get standardId => throw _privateConstructorUsedError;

  /// Strength standard name (null if fallback)
  String? get standardName => throw _privateConstructorUsedError;

  /// Strength standard equipment (null if fallback)
  String? get standardEquipment => throw _privateConstructorUsedError;

  /// Data source (null if fallback)
  String? get dataSource => throw _privateConstructorUsedError;

  /// Fallback reason (only for fallback status)
  String? get fallbackReason => throw _privateConstructorUsedError;

  /// Serializes this ExerciseMapping to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseMapping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseMappingCopyWith<ExerciseMapping> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseMappingCopyWith<$Res> {
  factory $ExerciseMappingCopyWith(
    ExerciseMapping value,
    $Res Function(ExerciseMapping) then,
  ) = _$ExerciseMappingCopyWithImpl<$Res, ExerciseMapping>;
  @useResult
  $Res call({
    String gymbroId,
    String gymbroName,
    String gymbroEquipment,
    String? gymbroFocus,
    double confidence,
    MappingStatus status,
    String? standardId,
    String? standardName,
    String? standardEquipment,
    String? dataSource,
    String? fallbackReason,
  });
}

/// @nodoc
class _$ExerciseMappingCopyWithImpl<$Res, $Val extends ExerciseMapping>
    implements $ExerciseMappingCopyWith<$Res> {
  _$ExerciseMappingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseMapping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gymbroId = null,
    Object? gymbroName = null,
    Object? gymbroEquipment = null,
    Object? gymbroFocus = freezed,
    Object? confidence = null,
    Object? status = null,
    Object? standardId = freezed,
    Object? standardName = freezed,
    Object? standardEquipment = freezed,
    Object? dataSource = freezed,
    Object? fallbackReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            gymbroId: null == gymbroId
                ? _value.gymbroId
                : gymbroId // ignore: cast_nullable_to_non_nullable
                      as String,
            gymbroName: null == gymbroName
                ? _value.gymbroName
                : gymbroName // ignore: cast_nullable_to_non_nullable
                      as String,
            gymbroEquipment: null == gymbroEquipment
                ? _value.gymbroEquipment
                : gymbroEquipment // ignore: cast_nullable_to_non_nullable
                      as String,
            gymbroFocus: freezed == gymbroFocus
                ? _value.gymbroFocus
                : gymbroFocus // ignore: cast_nullable_to_non_nullable
                      as String?,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MappingStatus,
            standardId: freezed == standardId
                ? _value.standardId
                : standardId // ignore: cast_nullable_to_non_nullable
                      as String?,
            standardName: freezed == standardName
                ? _value.standardName
                : standardName // ignore: cast_nullable_to_non_nullable
                      as String?,
            standardEquipment: freezed == standardEquipment
                ? _value.standardEquipment
                : standardEquipment // ignore: cast_nullable_to_non_nullable
                      as String?,
            dataSource: freezed == dataSource
                ? _value.dataSource
                : dataSource // ignore: cast_nullable_to_non_nullable
                      as String?,
            fallbackReason: freezed == fallbackReason
                ? _value.fallbackReason
                : fallbackReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseMappingImplCopyWith<$Res>
    implements $ExerciseMappingCopyWith<$Res> {
  factory _$$ExerciseMappingImplCopyWith(
    _$ExerciseMappingImpl value,
    $Res Function(_$ExerciseMappingImpl) then,
  ) = __$$ExerciseMappingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String gymbroId,
    String gymbroName,
    String gymbroEquipment,
    String? gymbroFocus,
    double confidence,
    MappingStatus status,
    String? standardId,
    String? standardName,
    String? standardEquipment,
    String? dataSource,
    String? fallbackReason,
  });
}

/// @nodoc
class __$$ExerciseMappingImplCopyWithImpl<$Res>
    extends _$ExerciseMappingCopyWithImpl<$Res, _$ExerciseMappingImpl>
    implements _$$ExerciseMappingImplCopyWith<$Res> {
  __$$ExerciseMappingImplCopyWithImpl(
    _$ExerciseMappingImpl _value,
    $Res Function(_$ExerciseMappingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseMapping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gymbroId = null,
    Object? gymbroName = null,
    Object? gymbroEquipment = null,
    Object? gymbroFocus = freezed,
    Object? confidence = null,
    Object? status = null,
    Object? standardId = freezed,
    Object? standardName = freezed,
    Object? standardEquipment = freezed,
    Object? dataSource = freezed,
    Object? fallbackReason = freezed,
  }) {
    return _then(
      _$ExerciseMappingImpl(
        gymbroId: null == gymbroId
            ? _value.gymbroId
            : gymbroId // ignore: cast_nullable_to_non_nullable
                  as String,
        gymbroName: null == gymbroName
            ? _value.gymbroName
            : gymbroName // ignore: cast_nullable_to_non_nullable
                  as String,
        gymbroEquipment: null == gymbroEquipment
            ? _value.gymbroEquipment
            : gymbroEquipment // ignore: cast_nullable_to_non_nullable
                  as String,
        gymbroFocus: freezed == gymbroFocus
            ? _value.gymbroFocus
            : gymbroFocus // ignore: cast_nullable_to_non_nullable
                  as String?,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MappingStatus,
        standardId: freezed == standardId
            ? _value.standardId
            : standardId // ignore: cast_nullable_to_non_nullable
                  as String?,
        standardName: freezed == standardName
            ? _value.standardName
            : standardName // ignore: cast_nullable_to_non_nullable
                  as String?,
        standardEquipment: freezed == standardEquipment
            ? _value.standardEquipment
            : standardEquipment // ignore: cast_nullable_to_non_nullable
                  as String?,
        dataSource: freezed == dataSource
            ? _value.dataSource
            : dataSource // ignore: cast_nullable_to_non_nullable
                  as String?,
        fallbackReason: freezed == fallbackReason
            ? _value.fallbackReason
            : fallbackReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseMappingImpl implements _ExerciseMapping {
  const _$ExerciseMappingImpl({
    required this.gymbroId,
    required this.gymbroName,
    required this.gymbroEquipment,
    this.gymbroFocus,
    required this.confidence,
    required this.status,
    this.standardId,
    this.standardName,
    this.standardEquipment,
    this.dataSource,
    this.fallbackReason,
  });

  factory _$ExerciseMappingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseMappingImplFromJson(json);

  /// GymBro exercise ID
  @override
  final String gymbroId;

  /// GymBro exercise name
  @override
  final String gymbroName;

  /// GymBro equipment type
  @override
  final String gymbroEquipment;

  /// GymBro muscle focus (e.g., "PETT, TRIC") - nullable for exercises without defined focus
  @override
  final String? gymbroFocus;

  /// Semantic similarity confidence (0.0-1.0)
  @override
  final double confidence;

  /// Mapping status: "auto", "review", or "fallback"
  @override
  final MappingStatus status;

  /// Strength standard ID (null if fallback)
  @override
  final String? standardId;

  /// Strength standard name (null if fallback)
  @override
  final String? standardName;

  /// Strength standard equipment (null if fallback)
  @override
  final String? standardEquipment;

  /// Data source (null if fallback)
  @override
  final String? dataSource;

  /// Fallback reason (only for fallback status)
  @override
  final String? fallbackReason;

  @override
  String toString() {
    return 'ExerciseMapping(gymbroId: $gymbroId, gymbroName: $gymbroName, gymbroEquipment: $gymbroEquipment, gymbroFocus: $gymbroFocus, confidence: $confidence, status: $status, standardId: $standardId, standardName: $standardName, standardEquipment: $standardEquipment, dataSource: $dataSource, fallbackReason: $fallbackReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseMappingImpl &&
            (identical(other.gymbroId, gymbroId) ||
                other.gymbroId == gymbroId) &&
            (identical(other.gymbroName, gymbroName) ||
                other.gymbroName == gymbroName) &&
            (identical(other.gymbroEquipment, gymbroEquipment) ||
                other.gymbroEquipment == gymbroEquipment) &&
            (identical(other.gymbroFocus, gymbroFocus) ||
                other.gymbroFocus == gymbroFocus) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.standardId, standardId) ||
                other.standardId == standardId) &&
            (identical(other.standardName, standardName) ||
                other.standardName == standardName) &&
            (identical(other.standardEquipment, standardEquipment) ||
                other.standardEquipment == standardEquipment) &&
            (identical(other.dataSource, dataSource) ||
                other.dataSource == dataSource) &&
            (identical(other.fallbackReason, fallbackReason) ||
                other.fallbackReason == fallbackReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gymbroId,
    gymbroName,
    gymbroEquipment,
    gymbroFocus,
    confidence,
    status,
    standardId,
    standardName,
    standardEquipment,
    dataSource,
    fallbackReason,
  );

  /// Create a copy of ExerciseMapping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseMappingImplCopyWith<_$ExerciseMappingImpl> get copyWith =>
      __$$ExerciseMappingImplCopyWithImpl<_$ExerciseMappingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseMappingImplToJson(this);
  }
}

abstract class _ExerciseMapping implements ExerciseMapping {
  const factory _ExerciseMapping({
    required final String gymbroId,
    required final String gymbroName,
    required final String gymbroEquipment,
    final String? gymbroFocus,
    required final double confidence,
    required final MappingStatus status,
    final String? standardId,
    final String? standardName,
    final String? standardEquipment,
    final String? dataSource,
    final String? fallbackReason,
  }) = _$ExerciseMappingImpl;

  factory _ExerciseMapping.fromJson(Map<String, dynamic> json) =
      _$ExerciseMappingImpl.fromJson;

  /// GymBro exercise ID
  @override
  String get gymbroId;

  /// GymBro exercise name
  @override
  String get gymbroName;

  /// GymBro equipment type
  @override
  String get gymbroEquipment;

  /// GymBro muscle focus (e.g., "PETT, TRIC") - nullable for exercises without defined focus
  @override
  String? get gymbroFocus;

  /// Semantic similarity confidence (0.0-1.0)
  @override
  double get confidence;

  /// Mapping status: "auto", "review", or "fallback"
  @override
  MappingStatus get status;

  /// Strength standard ID (null if fallback)
  @override
  String? get standardId;

  /// Strength standard name (null if fallback)
  @override
  String? get standardName;

  /// Strength standard equipment (null if fallback)
  @override
  String? get standardEquipment;

  /// Data source (null if fallback)
  @override
  String? get dataSource;

  /// Fallback reason (only for fallback status)
  @override
  String? get fallbackReason;

  /// Create a copy of ExerciseMapping
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseMappingImplCopyWith<_$ExerciseMappingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
