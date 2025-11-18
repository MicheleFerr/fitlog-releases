// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ExerciseSessionModel {
  /// Name of the exercise (e.g., "Bench Press", "Squat")
  String get exerciseName => throw _privateConstructorUsedError;

  /// Target muscle group (e.g., "chest", "back", "legs")
  String get muscleGroup => throw _privateConstructorUsedError;

  /// All sets performed in this session
  List<AnalyticsSetModel> get sets => throw _privateConstructorUsedError;

  /// When the session was performed (Firestore Timestamp)
  DateTime get date => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExerciseSessionModelCopyWith<ExerciseSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSessionModelCopyWith<$Res> {
  factory $ExerciseSessionModelCopyWith(ExerciseSessionModel value,
          $Res Function(ExerciseSessionModel) then) =
      _$ExerciseSessionModelCopyWithImpl<$Res, ExerciseSessionModel>;
  @useResult
  $Res call(
      {String exerciseName,
      String muscleGroup,
      List<AnalyticsSetModel> sets,
      DateTime date});
}

/// @nodoc
class _$ExerciseSessionModelCopyWithImpl<$Res,
        $Val extends ExerciseSessionModel>
    implements $ExerciseSessionModelCopyWith<$Res> {
  _$ExerciseSessionModelCopyWithImpl(this._value, this._then);

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
              as List<AnalyticsSetModel>,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseSessionModelImplCopyWith<$Res>
    implements $ExerciseSessionModelCopyWith<$Res> {
  factory _$$ExerciseSessionModelImplCopyWith(_$ExerciseSessionModelImpl value,
          $Res Function(_$ExerciseSessionModelImpl) then) =
      __$$ExerciseSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      String muscleGroup,
      List<AnalyticsSetModel> sets,
      DateTime date});
}

/// @nodoc
class __$$ExerciseSessionModelImplCopyWithImpl<$Res>
    extends _$ExerciseSessionModelCopyWithImpl<$Res, _$ExerciseSessionModelImpl>
    implements _$$ExerciseSessionModelImplCopyWith<$Res> {
  __$$ExerciseSessionModelImplCopyWithImpl(_$ExerciseSessionModelImpl _value,
      $Res Function(_$ExerciseSessionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? muscleGroup = null,
    Object? sets = null,
    Object? date = null,
  }) {
    return _then(_$ExerciseSessionModelImpl(
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
              as List<AnalyticsSetModel>,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$ExerciseSessionModelImpl extends _ExerciseSessionModel {
  const _$ExerciseSessionModelImpl(
      {required this.exerciseName,
      required this.muscleGroup,
      required final List<AnalyticsSetModel> sets,
      required this.date})
      : _sets = sets,
        super._();

  /// Name of the exercise (e.g., "Bench Press", "Squat")
  @override
  final String exerciseName;

  /// Target muscle group (e.g., "chest", "back", "legs")
  @override
  final String muscleGroup;

  /// All sets performed in this session
  final List<AnalyticsSetModel> _sets;

  /// All sets performed in this session
  @override
  List<AnalyticsSetModel> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  /// When the session was performed (Firestore Timestamp)
  @override
  final DateTime date;

  @override
  String toString() {
    return 'ExerciseSessionModel(exerciseName: $exerciseName, muscleGroup: $muscleGroup, sets: $sets, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSessionModelImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, muscleGroup,
      const DeepCollectionEquality().hash(_sets), date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSessionModelImplCopyWith<_$ExerciseSessionModelImpl>
      get copyWith =>
          __$$ExerciseSessionModelImplCopyWithImpl<_$ExerciseSessionModelImpl>(
              this, _$identity);
}

abstract class _ExerciseSessionModel extends ExerciseSessionModel {
  const factory _ExerciseSessionModel(
      {required final String exerciseName,
      required final String muscleGroup,
      required final List<AnalyticsSetModel> sets,
      required final DateTime date}) = _$ExerciseSessionModelImpl;
  const _ExerciseSessionModel._() : super._();

  @override

  /// Name of the exercise (e.g., "Bench Press", "Squat")
  String get exerciseName;
  @override

  /// Target muscle group (e.g., "chest", "back", "legs")
  String get muscleGroup;
  @override

  /// All sets performed in this session
  List<AnalyticsSetModel> get sets;
  @override

  /// When the session was performed (Firestore Timestamp)
  DateTime get date;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseSessionModelImplCopyWith<_$ExerciseSessionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
