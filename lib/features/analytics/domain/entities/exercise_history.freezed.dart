// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseHistory _$ExerciseHistoryFromJson(Map<String, dynamic> json) {
  return _ExerciseHistory.fromJson(json);
}

/// @nodoc
mixin _$ExerciseHistory {
  /// Name of the exercise (e.g., "Bench Press", "Squat")
  String get exerciseName => throw _privateConstructorUsedError;

  /// All sessions performed for this exercise (sorted by date)
  List<ExerciseSession> get sessions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseHistoryCopyWith<ExerciseHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseHistoryCopyWith<$Res> {
  factory $ExerciseHistoryCopyWith(
          ExerciseHistory value, $Res Function(ExerciseHistory) then) =
      _$ExerciseHistoryCopyWithImpl<$Res, ExerciseHistory>;
  @useResult
  $Res call({String exerciseName, List<ExerciseSession> sessions});
}

/// @nodoc
class _$ExerciseHistoryCopyWithImpl<$Res, $Val extends ExerciseHistory>
    implements $ExerciseHistoryCopyWith<$Res> {
  _$ExerciseHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? sessions = null,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sessions: null == sessions
          ? _value.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSession>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseHistoryImplCopyWith<$Res>
    implements $ExerciseHistoryCopyWith<$Res> {
  factory _$$ExerciseHistoryImplCopyWith(_$ExerciseHistoryImpl value,
          $Res Function(_$ExerciseHistoryImpl) then) =
      __$$ExerciseHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String exerciseName, List<ExerciseSession> sessions});
}

/// @nodoc
class __$$ExerciseHistoryImplCopyWithImpl<$Res>
    extends _$ExerciseHistoryCopyWithImpl<$Res, _$ExerciseHistoryImpl>
    implements _$$ExerciseHistoryImplCopyWith<$Res> {
  __$$ExerciseHistoryImplCopyWithImpl(
      _$ExerciseHistoryImpl _value, $Res Function(_$ExerciseHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? sessions = null,
  }) {
    return _then(_$ExerciseHistoryImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      sessions: null == sessions
          ? _value._sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSession>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseHistoryImpl extends _ExerciseHistory {
  const _$ExerciseHistoryImpl(
      {required this.exerciseName,
      required final List<ExerciseSession> sessions})
      : _sessions = sessions,
        super._();

  factory _$ExerciseHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseHistoryImplFromJson(json);

  /// Name of the exercise (e.g., "Bench Press", "Squat")
  @override
  final String exerciseName;

  /// All sessions performed for this exercise (sorted by date)
  final List<ExerciseSession> _sessions;

  /// All sessions performed for this exercise (sorted by date)
  @override
  List<ExerciseSession> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  @override
  String toString() {
    return 'ExerciseHistory(exerciseName: $exerciseName, sessions: $sessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseHistoryImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName,
      const DeepCollectionEquality().hash(_sessions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseHistoryImplCopyWith<_$ExerciseHistoryImpl> get copyWith =>
      __$$ExerciseHistoryImplCopyWithImpl<_$ExerciseHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseHistoryImplToJson(
      this,
    );
  }
}

abstract class _ExerciseHistory extends ExerciseHistory {
  const factory _ExerciseHistory(
      {required final String exerciseName,
      required final List<ExerciseSession> sessions}) = _$ExerciseHistoryImpl;
  const _ExerciseHistory._() : super._();

  factory _ExerciseHistory.fromJson(Map<String, dynamic> json) =
      _$ExerciseHistoryImpl.fromJson;

  @override

  /// Name of the exercise (e.g., "Bench Press", "Squat")
  String get exerciseName;
  @override

  /// All sessions performed for this exercise (sorted by date)
  List<ExerciseSession> get sessions;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseHistoryImplCopyWith<_$ExerciseHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
