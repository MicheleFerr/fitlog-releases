// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pattern_detection_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PatternDetectionResult _$PatternDetectionResultFromJson(
    Map<String, dynamic> json) {
  return _PatternDetectionResult.fromJson(json);
}

/// @nodoc
mixin _$PatternDetectionResult {
  /// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
  List<String> get pattern => throw _privateConstructorUsedError;

  /// Number of times the pattern repeats in workout history
  /// Must be >= 2 for valid pattern
  int get repetitions => throw _privateConstructorUsedError;

  /// Confidence score (0.0 - 1.0)
  /// Based on: repetitions, coverage, pattern length
  /// Typical range: 0.60-0.90
  double get confidence => throw _privateConstructorUsedError;

  /// Position of last completed workout in pattern (0-indexed)
  /// Used to predict next workout
  /// Example: lastPosition=1 means user just did pattern[1]
  int get lastPosition => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PatternDetectionResultCopyWith<PatternDetectionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatternDetectionResultCopyWith<$Res> {
  factory $PatternDetectionResultCopyWith(PatternDetectionResult value,
          $Res Function(PatternDetectionResult) then) =
      _$PatternDetectionResultCopyWithImpl<$Res, PatternDetectionResult>;
  @useResult
  $Res call(
      {List<String> pattern,
      int repetitions,
      double confidence,
      int lastPosition});
}

/// @nodoc
class _$PatternDetectionResultCopyWithImpl<$Res,
        $Val extends PatternDetectionResult>
    implements $PatternDetectionResultCopyWith<$Res> {
  _$PatternDetectionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pattern = null,
    Object? repetitions = null,
    Object? confidence = null,
    Object? lastPosition = null,
  }) {
    return _then(_value.copyWith(
      pattern: null == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as List<String>,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      lastPosition: null == lastPosition
          ? _value.lastPosition
          : lastPosition // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatternDetectionResultImplCopyWith<$Res>
    implements $PatternDetectionResultCopyWith<$Res> {
  factory _$$PatternDetectionResultImplCopyWith(
          _$PatternDetectionResultImpl value,
          $Res Function(_$PatternDetectionResultImpl) then) =
      __$$PatternDetectionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> pattern,
      int repetitions,
      double confidence,
      int lastPosition});
}

/// @nodoc
class __$$PatternDetectionResultImplCopyWithImpl<$Res>
    extends _$PatternDetectionResultCopyWithImpl<$Res,
        _$PatternDetectionResultImpl>
    implements _$$PatternDetectionResultImplCopyWith<$Res> {
  __$$PatternDetectionResultImplCopyWithImpl(
      _$PatternDetectionResultImpl _value,
      $Res Function(_$PatternDetectionResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pattern = null,
    Object? repetitions = null,
    Object? confidence = null,
    Object? lastPosition = null,
  }) {
    return _then(_$PatternDetectionResultImpl(
      pattern: null == pattern
          ? _value._pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as List<String>,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      lastPosition: null == lastPosition
          ? _value.lastPosition
          : lastPosition // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatternDetectionResultImpl extends _PatternDetectionResult {
  const _$PatternDetectionResultImpl(
      {required final List<String> pattern,
      required this.repetitions,
      required this.confidence,
      required this.lastPosition})
      : _pattern = pattern,
        super._();

  factory _$PatternDetectionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatternDetectionResultImplFromJson(json);

  /// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
  final List<String> _pattern;

  /// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
  @override
  List<String> get pattern {
    if (_pattern is EqualUnmodifiableListView) return _pattern;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pattern);
  }

  /// Number of times the pattern repeats in workout history
  /// Must be >= 2 for valid pattern
  @override
  final int repetitions;

  /// Confidence score (0.0 - 1.0)
  /// Based on: repetitions, coverage, pattern length
  /// Typical range: 0.60-0.90
  @override
  final double confidence;

  /// Position of last completed workout in pattern (0-indexed)
  /// Used to predict next workout
  /// Example: lastPosition=1 means user just did pattern[1]
  @override
  final int lastPosition;

  @override
  String toString() {
    return 'PatternDetectionResult(pattern: $pattern, repetitions: $repetitions, confidence: $confidence, lastPosition: $lastPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatternDetectionResultImpl &&
            const DeepCollectionEquality().equals(other._pattern, _pattern) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.lastPosition, lastPosition) ||
                other.lastPosition == lastPosition));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pattern),
      repetitions,
      confidence,
      lastPosition);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatternDetectionResultImplCopyWith<_$PatternDetectionResultImpl>
      get copyWith => __$$PatternDetectionResultImplCopyWithImpl<
          _$PatternDetectionResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatternDetectionResultImplToJson(
      this,
    );
  }
}

abstract class _PatternDetectionResult extends PatternDetectionResult {
  const factory _PatternDetectionResult(
      {required final List<String> pattern,
      required final int repetitions,
      required final double confidence,
      required final int lastPosition}) = _$PatternDetectionResultImpl;
  const _PatternDetectionResult._() : super._();

  factory _PatternDetectionResult.fromJson(Map<String, dynamic> json) =
      _$PatternDetectionResultImpl.fromJson;

  @override

  /// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
  List<String> get pattern;
  @override

  /// Number of times the pattern repeats in workout history
  /// Must be >= 2 for valid pattern
  int get repetitions;
  @override

  /// Confidence score (0.0 - 1.0)
  /// Based on: repetitions, coverage, pattern length
  /// Typical range: 0.60-0.90
  double get confidence;
  @override

  /// Position of last completed workout in pattern (0-indexed)
  /// Used to predict next workout
  /// Example: lastPosition=1 means user just did pattern[1]
  int get lastPosition;
  @override
  @JsonKey(ignore: true)
  _$$PatternDetectionResultImplCopyWith<_$PatternDetectionResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
