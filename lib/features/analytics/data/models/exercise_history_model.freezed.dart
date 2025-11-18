// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ExerciseHistoryModel {
  /// Name of the exercise (also the document ID)
  String get exerciseName => throw _privateConstructorUsedError;

  /// Target muscle group (e.g., "chest", "back", "legs")
  String get muscleGroup => throw _privateConstructorUsedError;

  /// All sessions for this exercise (sorted by date descending)
  List<ExerciseSessionModel> get sessions => throw _privateConstructorUsedError;

  /// When this document was last updated (for cache invalidation)
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExerciseHistoryModelCopyWith<ExerciseHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseHistoryModelCopyWith<$Res> {
  factory $ExerciseHistoryModelCopyWith(ExerciseHistoryModel value,
          $Res Function(ExerciseHistoryModel) then) =
      _$ExerciseHistoryModelCopyWithImpl<$Res, ExerciseHistoryModel>;
  @useResult
  $Res call(
      {String exerciseName,
      String muscleGroup,
      List<ExerciseSessionModel> sessions,
      DateTime lastUpdated});
}

/// @nodoc
class _$ExerciseHistoryModelCopyWithImpl<$Res,
        $Val extends ExerciseHistoryModel>
    implements $ExerciseHistoryModelCopyWith<$Res> {
  _$ExerciseHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? muscleGroup = null,
    Object? sessions = null,
    Object? lastUpdated = null,
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
      sessions: null == sessions
          ? _value.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSessionModel>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseHistoryModelImplCopyWith<$Res>
    implements $ExerciseHistoryModelCopyWith<$Res> {
  factory _$$ExerciseHistoryModelImplCopyWith(_$ExerciseHistoryModelImpl value,
          $Res Function(_$ExerciseHistoryModelImpl) then) =
      __$$ExerciseHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      String muscleGroup,
      List<ExerciseSessionModel> sessions,
      DateTime lastUpdated});
}

/// @nodoc
class __$$ExerciseHistoryModelImplCopyWithImpl<$Res>
    extends _$ExerciseHistoryModelCopyWithImpl<$Res, _$ExerciseHistoryModelImpl>
    implements _$$ExerciseHistoryModelImplCopyWith<$Res> {
  __$$ExerciseHistoryModelImplCopyWithImpl(_$ExerciseHistoryModelImpl _value,
      $Res Function(_$ExerciseHistoryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? muscleGroup = null,
    Object? sessions = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$ExerciseHistoryModelImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      sessions: null == sessions
          ? _value._sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<ExerciseSessionModel>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$ExerciseHistoryModelImpl extends _ExerciseHistoryModel {
  const _$ExerciseHistoryModelImpl(
      {required this.exerciseName,
      required this.muscleGroup,
      required final List<ExerciseSessionModel> sessions,
      required this.lastUpdated})
      : _sessions = sessions,
        super._();

  /// Name of the exercise (also the document ID)
  @override
  final String exerciseName;

  /// Target muscle group (e.g., "chest", "back", "legs")
  @override
  final String muscleGroup;

  /// All sessions for this exercise (sorted by date descending)
  final List<ExerciseSessionModel> _sessions;

  /// All sessions for this exercise (sorted by date descending)
  @override
  List<ExerciseSessionModel> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  /// When this document was last updated (for cache invalidation)
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'ExerciseHistoryModel(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sessions: $sessions, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseHistoryModelImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, muscleGroup,
      const DeepCollectionEquality().hash(_sessions), lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseHistoryModelImplCopyWith<_$ExerciseHistoryModelImpl>
      get copyWith =>
          __$$ExerciseHistoryModelImplCopyWithImpl<_$ExerciseHistoryModelImpl>(
              this, _$identity);
}

abstract class _ExerciseHistoryModel extends ExerciseHistoryModel {
  const factory _ExerciseHistoryModel(
      {required final String exerciseName,
      required final String muscleGroup,
      required final List<ExerciseSessionModel> sessions,
      required final DateTime lastUpdated}) = _$ExerciseHistoryModelImpl;
  const _ExerciseHistoryModel._() : super._();

  @override

  /// Name of the exercise (also the document ID)
  String get exerciseName;
  @override

  /// Target muscle group (e.g., "chest", "back", "legs")
  String get muscleGroup;
  @override

  /// All sessions for this exercise (sorted by date descending)
  List<ExerciseSessionModel> get sessions;
  @override

  /// When this document was last updated (for cache invalidation)
  DateTime get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseHistoryModelImplCopyWith<_$ExerciseHistoryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
