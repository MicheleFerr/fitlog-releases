// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'frequency_cap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FrequencyCap _$FrequencyCapFromJson(Map<String, dynamic> json) {
  return _FrequencyCap.fromJson(json);
}

/// @nodoc
mixin _$FrequencyCap {
  /// Maximum notifications per day
  /// Default: 3
  /// Range: 1-10
  int get maxPerDay => throw _privateConstructorUsedError;

  /// Maximum notifications per week
  /// Default: 5 (research-backed optimal)
  /// Research: >5/week → 64% quit risk (Localytics 2017)
  int get maxPerWeek => throw _privateConstructorUsedError;

  /// Minimum hours between notifications
  /// Default: 2 hours
  /// Prevents spam within same day
  int get minIntervalHours => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FrequencyCapCopyWith<FrequencyCap> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FrequencyCapCopyWith<$Res> {
  factory $FrequencyCapCopyWith(
          FrequencyCap value, $Res Function(FrequencyCap) then) =
      _$FrequencyCapCopyWithImpl<$Res, FrequencyCap>;
  @useResult
  $Res call({int maxPerDay, int maxPerWeek, int minIntervalHours});
}

/// @nodoc
class _$FrequencyCapCopyWithImpl<$Res, $Val extends FrequencyCap>
    implements $FrequencyCapCopyWith<$Res> {
  _$FrequencyCapCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxPerDay = null,
    Object? maxPerWeek = null,
    Object? minIntervalHours = null,
  }) {
    return _then(_value.copyWith(
      maxPerDay: null == maxPerDay
          ? _value.maxPerDay
          : maxPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      maxPerWeek: null == maxPerWeek
          ? _value.maxPerWeek
          : maxPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      minIntervalHours: null == minIntervalHours
          ? _value.minIntervalHours
          : minIntervalHours // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FrequencyCapImplCopyWith<$Res>
    implements $FrequencyCapCopyWith<$Res> {
  factory _$$FrequencyCapImplCopyWith(
          _$FrequencyCapImpl value, $Res Function(_$FrequencyCapImpl) then) =
      __$$FrequencyCapImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int maxPerDay, int maxPerWeek, int minIntervalHours});
}

/// @nodoc
class __$$FrequencyCapImplCopyWithImpl<$Res>
    extends _$FrequencyCapCopyWithImpl<$Res, _$FrequencyCapImpl>
    implements _$$FrequencyCapImplCopyWith<$Res> {
  __$$FrequencyCapImplCopyWithImpl(
      _$FrequencyCapImpl _value, $Res Function(_$FrequencyCapImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxPerDay = null,
    Object? maxPerWeek = null,
    Object? minIntervalHours = null,
  }) {
    return _then(_$FrequencyCapImpl(
      maxPerDay: null == maxPerDay
          ? _value.maxPerDay
          : maxPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      maxPerWeek: null == maxPerWeek
          ? _value.maxPerWeek
          : maxPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      minIntervalHours: null == minIntervalHours
          ? _value.minIntervalHours
          : minIntervalHours // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FrequencyCapImpl implements _FrequencyCap {
  const _$FrequencyCapImpl(
      {this.maxPerDay = 3, this.maxPerWeek = 5, this.minIntervalHours = 2});

  factory _$FrequencyCapImpl.fromJson(Map<String, dynamic> json) =>
      _$$FrequencyCapImplFromJson(json);

  /// Maximum notifications per day
  /// Default: 3
  /// Range: 1-10
  @override
  @JsonKey()
  final int maxPerDay;

  /// Maximum notifications per week
  /// Default: 5 (research-backed optimal)
  /// Research: >5/week → 64% quit risk (Localytics 2017)
  @override
  @JsonKey()
  final int maxPerWeek;

  /// Minimum hours between notifications
  /// Default: 2 hours
  /// Prevents spam within same day
  @override
  @JsonKey()
  final int minIntervalHours;

  @override
  String toString() {
    return 'FrequencyCap(maxPerDay: $maxPerDay, maxPerWeek: $maxPerWeek, minIntervalHours: $minIntervalHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrequencyCapImpl &&
            (identical(other.maxPerDay, maxPerDay) ||
                other.maxPerDay == maxPerDay) &&
            (identical(other.maxPerWeek, maxPerWeek) ||
                other.maxPerWeek == maxPerWeek) &&
            (identical(other.minIntervalHours, minIntervalHours) ||
                other.minIntervalHours == minIntervalHours));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, maxPerDay, maxPerWeek, minIntervalHours);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FrequencyCapImplCopyWith<_$FrequencyCapImpl> get copyWith =>
      __$$FrequencyCapImplCopyWithImpl<_$FrequencyCapImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FrequencyCapImplToJson(
      this,
    );
  }
}

abstract class _FrequencyCap implements FrequencyCap {
  const factory _FrequencyCap(
      {final int maxPerDay,
      final int maxPerWeek,
      final int minIntervalHours}) = _$FrequencyCapImpl;

  factory _FrequencyCap.fromJson(Map<String, dynamic> json) =
      _$FrequencyCapImpl.fromJson;

  @override

  /// Maximum notifications per day
  /// Default: 3
  /// Range: 1-10
  int get maxPerDay;
  @override

  /// Maximum notifications per week
  /// Default: 5 (research-backed optimal)
  /// Research: >5/week → 64% quit risk (Localytics 2017)
  int get maxPerWeek;
  @override

  /// Minimum hours between notifications
  /// Default: 2 hours
  /// Prevents spam within same day
  int get minIntervalHours;
  @override
  @JsonKey(ignore: true)
  _$$FrequencyCapImplCopyWith<_$FrequencyCapImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
