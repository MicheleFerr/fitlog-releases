// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoutinePattern _$RoutinePatternFromJson(Map<String, dynamic> json) {
  return _RoutinePattern.fromJson(json);
}

/// @nodoc
mixin _$RoutinePattern {
// === PATTERN INFO ===
  String get name => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // === PATTERN SEQUENCE ===
  /// Sequence of template IDs or "rest" keyword
  /// Example: ["template-push-id", "template-pull-id", "rest", "template-legs-id"]
  List<String> get sequence =>
      throw _privateConstructorUsedError; // === PATTERN TYPE ===
  PatternType get type =>
      throw _privateConstructorUsedError; // === PATTERN SETTINGS ===
  /// How many times to repeat (only for fixed type)
  int get repetitions => throw _privateConstructorUsedError;

  /// Start from specific day of week (0 = Monday, 6 = Sunday)
  int? get startWeekday => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoutinePatternCopyWith<RoutinePattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutinePatternCopyWith<$Res> {
  factory $RoutinePatternCopyWith(
          RoutinePattern value, $Res Function(RoutinePattern) then) =
      _$RoutinePatternCopyWithImpl<$Res, RoutinePattern>;
  @useResult
  $Res call(
      {String name,
      String description,
      List<String> sequence,
      PatternType type,
      int repetitions,
      int? startWeekday});
}

/// @nodoc
class _$RoutinePatternCopyWithImpl<$Res, $Val extends RoutinePattern>
    implements $RoutinePatternCopyWith<$Res> {
  _$RoutinePatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? sequence = null,
    Object? type = null,
    Object? repetitions = null,
    Object? startWeekday = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PatternType,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      startWeekday: freezed == startWeekday
          ? _value.startWeekday
          : startWeekday // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutinePatternImplCopyWith<$Res>
    implements $RoutinePatternCopyWith<$Res> {
  factory _$$RoutinePatternImplCopyWith(_$RoutinePatternImpl value,
          $Res Function(_$RoutinePatternImpl) then) =
      __$$RoutinePatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String description,
      List<String> sequence,
      PatternType type,
      int repetitions,
      int? startWeekday});
}

/// @nodoc
class __$$RoutinePatternImplCopyWithImpl<$Res>
    extends _$RoutinePatternCopyWithImpl<$Res, _$RoutinePatternImpl>
    implements _$$RoutinePatternImplCopyWith<$Res> {
  __$$RoutinePatternImplCopyWithImpl(
      _$RoutinePatternImpl _value, $Res Function(_$RoutinePatternImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? sequence = null,
    Object? type = null,
    Object? repetitions = null,
    Object? startWeekday = freezed,
  }) {
    return _then(_$RoutinePatternImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _value._sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PatternType,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      startWeekday: freezed == startWeekday
          ? _value.startWeekday
          : startWeekday // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutinePatternImpl implements _RoutinePattern {
  const _$RoutinePatternImpl(
      {this.name = '',
      this.description = '',
      required final List<String> sequence,
      this.type = PatternType.repeating,
      this.repetitions = 1,
      this.startWeekday})
      : _sequence = sequence;

  factory _$RoutinePatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutinePatternImplFromJson(json);

// === PATTERN INFO ===
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
// === PATTERN SEQUENCE ===
  /// Sequence of template IDs or "rest" keyword
  /// Example: ["template-push-id", "template-pull-id", "rest", "template-legs-id"]
  final List<String> _sequence;
// === PATTERN SEQUENCE ===
  /// Sequence of template IDs or "rest" keyword
  /// Example: ["template-push-id", "template-pull-id", "rest", "template-legs-id"]
  @override
  List<String> get sequence {
    if (_sequence is EqualUnmodifiableListView) return _sequence;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sequence);
  }

// === PATTERN TYPE ===
  @override
  @JsonKey()
  final PatternType type;
// === PATTERN SETTINGS ===
  /// How many times to repeat (only for fixed type)
  @override
  @JsonKey()
  final int repetitions;

  /// Start from specific day of week (0 = Monday, 6 = Sunday)
  @override
  final int? startWeekday;

  @override
  String toString() {
    return 'RoutinePattern(name: $name, description: $description, sequence: $sequence, type: $type, repetitions: $repetitions, startWeekday: $startWeekday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutinePatternImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._sequence, _sequence) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.startWeekday, startWeekday) ||
                other.startWeekday == startWeekday));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      const DeepCollectionEquality().hash(_sequence),
      type,
      repetitions,
      startWeekday);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutinePatternImplCopyWith<_$RoutinePatternImpl> get copyWith =>
      __$$RoutinePatternImplCopyWithImpl<_$RoutinePatternImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutinePatternImplToJson(
      this,
    );
  }
}

abstract class _RoutinePattern implements RoutinePattern {
  const factory _RoutinePattern(
      {final String name,
      final String description,
      required final List<String> sequence,
      final PatternType type,
      final int repetitions,
      final int? startWeekday}) = _$RoutinePatternImpl;

  factory _RoutinePattern.fromJson(Map<String, dynamic> json) =
      _$RoutinePatternImpl.fromJson;

  @override // === PATTERN INFO ===
  String get name;
  @override
  String get description;
  @override // === PATTERN SEQUENCE ===
  /// Sequence of template IDs or "rest" keyword
  /// Example: ["template-push-id", "template-pull-id", "rest", "template-legs-id"]
  List<String> get sequence;
  @override // === PATTERN TYPE ===
  PatternType get type;
  @override // === PATTERN SETTINGS ===
  /// How many times to repeat (only for fixed type)
  int get repetitions;
  @override

  /// Start from specific day of week (0 = Monday, 6 = Sunday)
  int? get startWeekday;
  @override
  @JsonKey(ignore: true)
  _$$RoutinePatternImplCopyWith<_$RoutinePatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
