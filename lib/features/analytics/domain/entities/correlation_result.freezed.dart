// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'correlation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CorrelationResult _$CorrelationResultFromJson(Map<String, dynamic> json) {
  return _CorrelationResult.fromJson(json);
}

/// @nodoc
mixin _$CorrelationResult {
  /// Pearson correlation coefficient (-1 to +1)
  /// - +1: Perfect positive correlation
  /// - 0: No correlation
  /// - -1: Perfect negative correlation
  double get r => throw _privateConstructorUsedError;

  /// Coefficient of determination (0 to 1)
  /// - Shows how much variance in Y is explained by X
  /// - 0.72 means 72% of variance explained
  double get rSquared => throw _privateConstructorUsedError;

  /// Strength classification
  CorrelationStrength get strength => throw _privateConstructorUsedError;

  /// Human-readable interpretation
  String get interpretation => throw _privateConstructorUsedError;

  /// Number of data points used
  int get dataPoints => throw _privateConstructorUsedError;

  /// Whether the result is statistically significant
  bool get isSignificant => throw _privateConstructorUsedError;

  /// Serializes this CorrelationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CorrelationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CorrelationResultCopyWith<CorrelationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CorrelationResultCopyWith<$Res> {
  factory $CorrelationResultCopyWith(
    CorrelationResult value,
    $Res Function(CorrelationResult) then,
  ) = _$CorrelationResultCopyWithImpl<$Res, CorrelationResult>;
  @useResult
  $Res call({
    double r,
    double rSquared,
    CorrelationStrength strength,
    String interpretation,
    int dataPoints,
    bool isSignificant,
  });
}

/// @nodoc
class _$CorrelationResultCopyWithImpl<$Res, $Val extends CorrelationResult>
    implements $CorrelationResultCopyWith<$Res> {
  _$CorrelationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CorrelationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? r = null,
    Object? rSquared = null,
    Object? strength = null,
    Object? interpretation = null,
    Object? dataPoints = null,
    Object? isSignificant = null,
  }) {
    return _then(
      _value.copyWith(
            r: null == r
                ? _value.r
                : r // ignore: cast_nullable_to_non_nullable
                      as double,
            rSquared: null == rSquared
                ? _value.rSquared
                : rSquared // ignore: cast_nullable_to_non_nullable
                      as double,
            strength: null == strength
                ? _value.strength
                : strength // ignore: cast_nullable_to_non_nullable
                      as CorrelationStrength,
            interpretation: null == interpretation
                ? _value.interpretation
                : interpretation // ignore: cast_nullable_to_non_nullable
                      as String,
            dataPoints: null == dataPoints
                ? _value.dataPoints
                : dataPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            isSignificant: null == isSignificant
                ? _value.isSignificant
                : isSignificant // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CorrelationResultImplCopyWith<$Res>
    implements $CorrelationResultCopyWith<$Res> {
  factory _$$CorrelationResultImplCopyWith(
    _$CorrelationResultImpl value,
    $Res Function(_$CorrelationResultImpl) then,
  ) = __$$CorrelationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double r,
    double rSquared,
    CorrelationStrength strength,
    String interpretation,
    int dataPoints,
    bool isSignificant,
  });
}

/// @nodoc
class __$$CorrelationResultImplCopyWithImpl<$Res>
    extends _$CorrelationResultCopyWithImpl<$Res, _$CorrelationResultImpl>
    implements _$$CorrelationResultImplCopyWith<$Res> {
  __$$CorrelationResultImplCopyWithImpl(
    _$CorrelationResultImpl _value,
    $Res Function(_$CorrelationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CorrelationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? r = null,
    Object? rSquared = null,
    Object? strength = null,
    Object? interpretation = null,
    Object? dataPoints = null,
    Object? isSignificant = null,
  }) {
    return _then(
      _$CorrelationResultImpl(
        r: null == r
            ? _value.r
            : r // ignore: cast_nullable_to_non_nullable
                  as double,
        rSquared: null == rSquared
            ? _value.rSquared
            : rSquared // ignore: cast_nullable_to_non_nullable
                  as double,
        strength: null == strength
            ? _value.strength
            : strength // ignore: cast_nullable_to_non_nullable
                  as CorrelationStrength,
        interpretation: null == interpretation
            ? _value.interpretation
            : interpretation // ignore: cast_nullable_to_non_nullable
                  as String,
        dataPoints: null == dataPoints
            ? _value.dataPoints
            : dataPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        isSignificant: null == isSignificant
            ? _value.isSignificant
            : isSignificant // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CorrelationResultImpl extends _CorrelationResult {
  const _$CorrelationResultImpl({
    required this.r,
    required this.rSquared,
    required this.strength,
    required this.interpretation,
    this.dataPoints = 0,
    this.isSignificant = false,
  }) : super._();

  factory _$CorrelationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CorrelationResultImplFromJson(json);

  /// Pearson correlation coefficient (-1 to +1)
  /// - +1: Perfect positive correlation
  /// - 0: No correlation
  /// - -1: Perfect negative correlation
  @override
  final double r;

  /// Coefficient of determination (0 to 1)
  /// - Shows how much variance in Y is explained by X
  /// - 0.72 means 72% of variance explained
  @override
  final double rSquared;

  /// Strength classification
  @override
  final CorrelationStrength strength;

  /// Human-readable interpretation
  @override
  final String interpretation;

  /// Number of data points used
  @override
  @JsonKey()
  final int dataPoints;

  /// Whether the result is statistically significant
  @override
  @JsonKey()
  final bool isSignificant;

  @override
  String toString() {
    return 'CorrelationResult(r: $r, rSquared: $rSquared, strength: $strength, interpretation: $interpretation, dataPoints: $dataPoints, isSignificant: $isSignificant)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CorrelationResultImpl &&
            (identical(other.r, r) || other.r == r) &&
            (identical(other.rSquared, rSquared) ||
                other.rSquared == rSquared) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.interpretation, interpretation) ||
                other.interpretation == interpretation) &&
            (identical(other.dataPoints, dataPoints) ||
                other.dataPoints == dataPoints) &&
            (identical(other.isSignificant, isSignificant) ||
                other.isSignificant == isSignificant));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    r,
    rSquared,
    strength,
    interpretation,
    dataPoints,
    isSignificant,
  );

  /// Create a copy of CorrelationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CorrelationResultImplCopyWith<_$CorrelationResultImpl> get copyWith =>
      __$$CorrelationResultImplCopyWithImpl<_$CorrelationResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CorrelationResultImplToJson(this);
  }
}

abstract class _CorrelationResult extends CorrelationResult {
  const factory _CorrelationResult({
    required final double r,
    required final double rSquared,
    required final CorrelationStrength strength,
    required final String interpretation,
    final int dataPoints,
    final bool isSignificant,
  }) = _$CorrelationResultImpl;
  const _CorrelationResult._() : super._();

  factory _CorrelationResult.fromJson(Map<String, dynamic> json) =
      _$CorrelationResultImpl.fromJson;

  /// Pearson correlation coefficient (-1 to +1)
  /// - +1: Perfect positive correlation
  /// - 0: No correlation
  /// - -1: Perfect negative correlation
  @override
  double get r;

  /// Coefficient of determination (0 to 1)
  /// - Shows how much variance in Y is explained by X
  /// - 0.72 means 72% of variance explained
  @override
  double get rSquared;

  /// Strength classification
  @override
  CorrelationStrength get strength;

  /// Human-readable interpretation
  @override
  String get interpretation;

  /// Number of data points used
  @override
  int get dataPoints;

  /// Whether the result is statistically significant
  @override
  bool get isSignificant;

  /// Create a copy of CorrelationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CorrelationResultImplCopyWith<_$CorrelationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CorrelationResults _$CorrelationResultsFromJson(Map<String, dynamic> json) {
  return _CorrelationResults.fromJson(json);
}

/// @nodoc
mixin _$CorrelationResults {
  /// Weight vs RPE correlation
  CorrelationResult get weightRpe => throw _privateConstructorUsedError;

  /// Volume vs RPE correlation
  CorrelationResult get volumeRpe => throw _privateConstructorUsedError;

  /// Weight vs Volume correlation (optional)
  CorrelationResult? get weightVolume => throw _privateConstructorUsedError;

  /// Serializes this CorrelationResults to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CorrelationResultsCopyWith<CorrelationResults> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CorrelationResultsCopyWith<$Res> {
  factory $CorrelationResultsCopyWith(
    CorrelationResults value,
    $Res Function(CorrelationResults) then,
  ) = _$CorrelationResultsCopyWithImpl<$Res, CorrelationResults>;
  @useResult
  $Res call({
    CorrelationResult weightRpe,
    CorrelationResult volumeRpe,
    CorrelationResult? weightVolume,
  });

  $CorrelationResultCopyWith<$Res> get weightRpe;
  $CorrelationResultCopyWith<$Res> get volumeRpe;
  $CorrelationResultCopyWith<$Res>? get weightVolume;
}

/// @nodoc
class _$CorrelationResultsCopyWithImpl<$Res, $Val extends CorrelationResults>
    implements $CorrelationResultsCopyWith<$Res> {
  _$CorrelationResultsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weightRpe = null,
    Object? volumeRpe = null,
    Object? weightVolume = freezed,
  }) {
    return _then(
      _value.copyWith(
            weightRpe: null == weightRpe
                ? _value.weightRpe
                : weightRpe // ignore: cast_nullable_to_non_nullable
                      as CorrelationResult,
            volumeRpe: null == volumeRpe
                ? _value.volumeRpe
                : volumeRpe // ignore: cast_nullable_to_non_nullable
                      as CorrelationResult,
            weightVolume: freezed == weightVolume
                ? _value.weightVolume
                : weightVolume // ignore: cast_nullable_to_non_nullable
                      as CorrelationResult?,
          )
          as $Val,
    );
  }

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CorrelationResultCopyWith<$Res> get weightRpe {
    return $CorrelationResultCopyWith<$Res>(_value.weightRpe, (value) {
      return _then(_value.copyWith(weightRpe: value) as $Val);
    });
  }

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CorrelationResultCopyWith<$Res> get volumeRpe {
    return $CorrelationResultCopyWith<$Res>(_value.volumeRpe, (value) {
      return _then(_value.copyWith(volumeRpe: value) as $Val);
    });
  }

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CorrelationResultCopyWith<$Res>? get weightVolume {
    if (_value.weightVolume == null) {
      return null;
    }

    return $CorrelationResultCopyWith<$Res>(_value.weightVolume!, (value) {
      return _then(_value.copyWith(weightVolume: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CorrelationResultsImplCopyWith<$Res>
    implements $CorrelationResultsCopyWith<$Res> {
  factory _$$CorrelationResultsImplCopyWith(
    _$CorrelationResultsImpl value,
    $Res Function(_$CorrelationResultsImpl) then,
  ) = __$$CorrelationResultsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CorrelationResult weightRpe,
    CorrelationResult volumeRpe,
    CorrelationResult? weightVolume,
  });

  @override
  $CorrelationResultCopyWith<$Res> get weightRpe;
  @override
  $CorrelationResultCopyWith<$Res> get volumeRpe;
  @override
  $CorrelationResultCopyWith<$Res>? get weightVolume;
}

/// @nodoc
class __$$CorrelationResultsImplCopyWithImpl<$Res>
    extends _$CorrelationResultsCopyWithImpl<$Res, _$CorrelationResultsImpl>
    implements _$$CorrelationResultsImplCopyWith<$Res> {
  __$$CorrelationResultsImplCopyWithImpl(
    _$CorrelationResultsImpl _value,
    $Res Function(_$CorrelationResultsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weightRpe = null,
    Object? volumeRpe = null,
    Object? weightVolume = freezed,
  }) {
    return _then(
      _$CorrelationResultsImpl(
        weightRpe: null == weightRpe
            ? _value.weightRpe
            : weightRpe // ignore: cast_nullable_to_non_nullable
                  as CorrelationResult,
        volumeRpe: null == volumeRpe
            ? _value.volumeRpe
            : volumeRpe // ignore: cast_nullable_to_non_nullable
                  as CorrelationResult,
        weightVolume: freezed == weightVolume
            ? _value.weightVolume
            : weightVolume // ignore: cast_nullable_to_non_nullable
                  as CorrelationResult?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CorrelationResultsImpl extends _CorrelationResults {
  const _$CorrelationResultsImpl({
    required this.weightRpe,
    required this.volumeRpe,
    this.weightVolume,
  }) : super._();

  factory _$CorrelationResultsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CorrelationResultsImplFromJson(json);

  /// Weight vs RPE correlation
  @override
  final CorrelationResult weightRpe;

  /// Volume vs RPE correlation
  @override
  final CorrelationResult volumeRpe;

  /// Weight vs Volume correlation (optional)
  @override
  final CorrelationResult? weightVolume;

  @override
  String toString() {
    return 'CorrelationResults(weightRpe: $weightRpe, volumeRpe: $volumeRpe, weightVolume: $weightVolume)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CorrelationResultsImpl &&
            (identical(other.weightRpe, weightRpe) ||
                other.weightRpe == weightRpe) &&
            (identical(other.volumeRpe, volumeRpe) ||
                other.volumeRpe == volumeRpe) &&
            (identical(other.weightVolume, weightVolume) ||
                other.weightVolume == weightVolume));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, weightRpe, volumeRpe, weightVolume);

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CorrelationResultsImplCopyWith<_$CorrelationResultsImpl> get copyWith =>
      __$$CorrelationResultsImplCopyWithImpl<_$CorrelationResultsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CorrelationResultsImplToJson(this);
  }
}

abstract class _CorrelationResults extends CorrelationResults {
  const factory _CorrelationResults({
    required final CorrelationResult weightRpe,
    required final CorrelationResult volumeRpe,
    final CorrelationResult? weightVolume,
  }) = _$CorrelationResultsImpl;
  const _CorrelationResults._() : super._();

  factory _CorrelationResults.fromJson(Map<String, dynamic> json) =
      _$CorrelationResultsImpl.fromJson;

  /// Weight vs RPE correlation
  @override
  CorrelationResult get weightRpe;

  /// Volume vs RPE correlation
  @override
  CorrelationResult get volumeRpe;

  /// Weight vs Volume correlation (optional)
  @override
  CorrelationResult? get weightVolume;

  /// Create a copy of CorrelationResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CorrelationResultsImplCopyWith<_$CorrelationResultsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
