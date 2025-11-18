// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseSession _$ExerciseSessionFromJson(Map<String, dynamic> json) {
  return _ExerciseSession.fromJson(json);
}

/// @nodoc
mixin _$ExerciseSession {
  /// Name of the exercise (e.g., "Bench Press", "Squat")
  String get exerciseName => throw _privateConstructorUsedError;

  /// Target muscle group (e.g., "chest", "back", "legs")
  String get muscleGroup => throw _privateConstructorUsedError;

  /// All sets performed in this session
  List<AnalyticsSet> get sets => throw _privateConstructorUsedError;

  /// When the session was performed
  DateTime get date => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseSessionCopyWith<ExerciseSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSessionCopyWith<$Res> {
  factory $ExerciseSessionCopyWith(
          ExerciseSession value, $Res Function(ExerciseSession) then) =
      _$ExerciseSessionCopyWithImpl<$Res, ExerciseSession>;
  @useResult
  $Res call(
      {String exerciseName,
      String muscleGroup,
      List<AnalyticsSet> sets,
      DateTime date});
}

/// @nodoc
class _$ExerciseSessionCopyWithImpl<$Res, $Val extends ExerciseSession>
    implements $ExerciseSessionCopyWith<$Res> {
  _$ExerciseSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? muscleGroup = null,
    Object? sets = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsSet>,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseSessionImplCopyWith<$Res>
    implements $ExerciseSessionCopyWith<$Res> {
  factory _$$ExerciseSessionImplCopyWith(_$ExerciseSessionImpl value,
          $Res Function(_$ExerciseSessionImpl) then) =
      __$$ExerciseSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      String muscleGroup,
      List<AnalyticsSet> sets,
      DateTime date});
}

/// @nodoc
class __$$ExerciseSessionImplCopyWithImpl<$Res>
    extends _$ExerciseSessionCopyWithImpl<$Res, _$ExerciseSessionImpl>
    implements _$$ExerciseSessionImplCopyWith<$Res> {
  __$$ExerciseSessionImplCopyWithImpl(
      _$ExerciseSessionImpl _value, $Res Function(_$ExerciseSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? muscleGroup = null,
    Object? sets = null,
    Object? date = null,
  }) {
    return _then(_$ExerciseSessionImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsSet>,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseSessionImpl extends _ExerciseSession {
  const _$ExerciseSessionImpl(
      {required this.exerciseName,
      required this.muscleGroup,
      required final List<AnalyticsSet> sets,
      required this.date})
      : _sets = sets,
        super._();

  factory _$ExerciseSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseSessionImplFromJson(json);

  /// Name of the exercise (e.g., "Bench Press", "Squat")
  @override
  final String exerciseName;

  /// Target muscle group (e.g., "chest", "back", "legs")
  @override
  final String muscleGroup;

  /// All sets performed in this session
  final List<AnalyticsSet> _sets;

  /// All sets performed in this session
  @override
  List<AnalyticsSet> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  /// When the session was performed
  @override
  final DateTime date;

  @override
  String toString() {
    return 'ExerciseSession(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sets: $sets, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSessionImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, muscleGroup,
      const DeepCollectionEquality().hash(_sets), date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSessionImplCopyWith<_$ExerciseSessionImpl> get copyWith =>
      __$$ExerciseSessionImplCopyWithImpl<_$ExerciseSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseSessionImplToJson(
      this,
    );
  }
}

abstract class _ExerciseSession extends ExerciseSession {
  const factory _ExerciseSession(
      {required final String exerciseName,
      required final String muscleGroup,
      required final List<AnalyticsSet> sets,
      required final DateTime date}) = _$ExerciseSessionImpl;
  const _ExerciseSession._() : super._();

  factory _ExerciseSession.fromJson(Map<String, dynamic> json) =
      _$ExerciseSessionImpl.fromJson;

  @override

  /// Name of the exercise (e.g., "Bench Press", "Squat")
  String get exerciseName;
  @override

  /// Target muscle group (e.g., "chest", "back", "legs")
  String get muscleGroup;
  @override

  /// All sets performed in this session
  List<AnalyticsSet> get sets;
  @override

  /// When the session was performed
  DateTime get date;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseSessionImplCopyWith<_$ExerciseSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
