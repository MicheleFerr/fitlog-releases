// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnalyticsSet _$AnalyticsSetFromJson(Map<String, dynamic> json) {
  return _AnalyticsSet.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsSet {
  /// Weight lifted in kg (must be > 0)
  double get weight => throw _privateConstructorUsedError;

  /// Number of repetitions performed (must be > 0)
  int get reps => throw _privateConstructorUsedError;

  /// When the set was performed
  DateTime get date => throw _privateConstructorUsedError;

  /// Serializes this AnalyticsSet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsSetCopyWith<AnalyticsSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsSetCopyWith<$Res> {
  factory $AnalyticsSetCopyWith(
    AnalyticsSet value,
    $Res Function(AnalyticsSet) then,
  ) = _$AnalyticsSetCopyWithImpl<$Res, AnalyticsSet>;
  @useResult
  $Res call({double weight, int reps, DateTime date});
}

/// @nodoc
class _$AnalyticsSetCopyWithImpl<$Res, $Val extends AnalyticsSet>
    implements $AnalyticsSetCopyWith<$Res> {
  _$AnalyticsSetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? weight = null, Object? reps = null, Object? date = null}) {
    return _then(
      _value.copyWith(
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            reps: null == reps
                ? _value.reps
                : reps // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnalyticsSetImplCopyWith<$Res>
    implements $AnalyticsSetCopyWith<$Res> {
  factory _$$AnalyticsSetImplCopyWith(
    _$AnalyticsSetImpl value,
    $Res Function(_$AnalyticsSetImpl) then,
  ) = __$$AnalyticsSetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double weight, int reps, DateTime date});
}

/// @nodoc
class __$$AnalyticsSetImplCopyWithImpl<$Res>
    extends _$AnalyticsSetCopyWithImpl<$Res, _$AnalyticsSetImpl>
    implements _$$AnalyticsSetImplCopyWith<$Res> {
  __$$AnalyticsSetImplCopyWithImpl(
    _$AnalyticsSetImpl _value,
    $Res Function(_$AnalyticsSetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalyticsSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? weight = null, Object? reps = null, Object? date = null}) {
    return _then(
      _$AnalyticsSetImpl(
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        reps: null == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsSetImpl extends _AnalyticsSet {
  const _$AnalyticsSetImpl({
    required this.weight,
    required this.reps,
    required this.date,
  }) : super._();

  factory _$AnalyticsSetImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsSetImplFromJson(json);

  /// Weight lifted in kg (must be > 0)
  @override
  final double weight;

  /// Number of repetitions performed (must be > 0)
  @override
  final int reps;

  /// When the set was performed
  @override
  final DateTime date;

  @override
  String toString() {
    return 'AnalyticsSet(weight: $weight, reps: $reps, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsSetImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, weight, reps, date);

  /// Create a copy of AnalyticsSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsSetImplCopyWith<_$AnalyticsSetImpl> get copyWith =>
      __$$AnalyticsSetImplCopyWithImpl<_$AnalyticsSetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsSetImplToJson(this);
  }
}

abstract class _AnalyticsSet extends AnalyticsSet {
  const factory _AnalyticsSet({
    required final double weight,
    required final int reps,
    required final DateTime date,
  }) = _$AnalyticsSetImpl;
  const _AnalyticsSet._() : super._();

  factory _AnalyticsSet.fromJson(Map<String, dynamic> json) =
      _$AnalyticsSetImpl.fromJson;

  /// Weight lifted in kg (must be > 0)
  @override
  double get weight;

  /// Number of repetitions performed (must be > 0)
  @override
  int get reps;

  /// When the set was performed
  @override
  DateTime get date;

  /// Create a copy of AnalyticsSet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsSetImplCopyWith<_$AnalyticsSetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
