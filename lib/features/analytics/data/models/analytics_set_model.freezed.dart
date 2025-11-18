// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_set_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AnalyticsSetModel {
  /// Weight lifted in kg
  double get weight => throw _privateConstructorUsedError;

  /// Number of repetitions performed
  int get reps => throw _privateConstructorUsedError;

  /// When the set was performed (Firestore Timestamp)
  DateTime get date => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AnalyticsSetModelCopyWith<AnalyticsSetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsSetModelCopyWith<$Res> {
  factory $AnalyticsSetModelCopyWith(
          AnalyticsSetModel value, $Res Function(AnalyticsSetModel) then) =
      _$AnalyticsSetModelCopyWithImpl<$Res, AnalyticsSetModel>;
  @useResult
  $Res call({double weight, int reps, DateTime date});
}

/// @nodoc
class _$AnalyticsSetModelCopyWithImpl<$Res, $Val extends AnalyticsSetModel>
    implements $AnalyticsSetModelCopyWith<$Res> {
  _$AnalyticsSetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnalyticsSetModelImplCopyWith<$Res>
    implements $AnalyticsSetModelCopyWith<$Res> {
  factory _$$AnalyticsSetModelImplCopyWith(_$AnalyticsSetModelImpl value,
          $Res Function(_$AnalyticsSetModelImpl) then) =
      __$$AnalyticsSetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double weight, int reps, DateTime date});
}

/// @nodoc
class __$$AnalyticsSetModelImplCopyWithImpl<$Res>
    extends _$AnalyticsSetModelCopyWithImpl<$Res, _$AnalyticsSetModelImpl>
    implements _$$AnalyticsSetModelImplCopyWith<$Res> {
  __$$AnalyticsSetModelImplCopyWithImpl(_$AnalyticsSetModelImpl _value,
      $Res Function(_$AnalyticsSetModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? date = null,
  }) {
    return _then(_$AnalyticsSetModelImpl(
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
    ));
  }
}

/// @nodoc

class _$AnalyticsSetModelImpl extends _AnalyticsSetModel {
  const _$AnalyticsSetModelImpl(
      {required this.weight, required this.reps, required this.date})
      : super._();

  /// Weight lifted in kg
  @override
  final double weight;

  /// Number of repetitions performed
  @override
  final int reps;

  /// When the set was performed (Firestore Timestamp)
  @override
  final DateTime date;

  @override
  String toString() {
    return 'AnalyticsSetModel(weight: $weight, reps: $reps, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsSetModelImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(runtimeType, weight, reps, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsSetModelImplCopyWith<_$AnalyticsSetModelImpl> get copyWith =>
      __$$AnalyticsSetModelImplCopyWithImpl<_$AnalyticsSetModelImpl>(
          this, _$identity);
}

abstract class _AnalyticsSetModel extends AnalyticsSetModel {
  const factory _AnalyticsSetModel(
      {required final double weight,
      required final int reps,
      required final DateTime date}) = _$AnalyticsSetModelImpl;
  const _AnalyticsSetModel._() : super._();

  @override

  /// Weight lifted in kg
  double get weight;
  @override

  /// Number of repetitions performed
  int get reps;
  @override

  /// When the set was performed (Firestore Timestamp)
  DateTime get date;
  @override
  @JsonKey(ignore: true)
  _$$AnalyticsSetModelImplCopyWith<_$AnalyticsSetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
