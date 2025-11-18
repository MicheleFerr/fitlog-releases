// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_records.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseRecords _$ExerciseRecordsFromJson(Map<String, dynamic> json) {
  return _ExerciseRecords.fromJson(json);
}

/// @nodoc
mixin _$ExerciseRecords {
  /// Exercise name (matches ExerciseHistory.exerciseName)
  String get exerciseName => throw _privateConstructorUsedError;

  /// Personal Records
  double get maxWeightRecord =>
      throw _privateConstructorUsedError; // Heaviest single set weight (kg)
  double get estimated1RM =>
      throw _privateConstructorUsedError; // Estimated 1 rep max (Epley formula)
  double get totalVolumeRecord =>
      throw _privateConstructorUsedError; // Highest single-workout volume (kg)
  int get totalSetsRecord =>
      throw _privateConstructorUsedError; // Most sets in single workout
  /// Recent Activity
  DateTime get lastWorkoutDate =>
      throw _privateConstructorUsedError; // Most recent workout date
  double get weeklyFrequency =>
      throw _privateConstructorUsedError; // Avg workouts per week (last 4 weeks)
  /// Time Range
  DateTime get firstWorkoutDate =>
      throw _privateConstructorUsedError; // First recorded workout
  int get totalWorkouts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseRecordsCopyWith<ExerciseRecords> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseRecordsCopyWith<$Res> {
  factory $ExerciseRecordsCopyWith(
          ExerciseRecords value, $Res Function(ExerciseRecords) then) =
      _$ExerciseRecordsCopyWithImpl<$Res, ExerciseRecords>;
  @useResult
  $Res call(
      {String exerciseName,
      double maxWeightRecord,
      double estimated1RM,
      double totalVolumeRecord,
      int totalSetsRecord,
      DateTime lastWorkoutDate,
      double weeklyFrequency,
      DateTime firstWorkoutDate,
      int totalWorkouts});
}

/// @nodoc
class _$ExerciseRecordsCopyWithImpl<$Res, $Val extends ExerciseRecords>
    implements $ExerciseRecordsCopyWith<$Res> {
  _$ExerciseRecordsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? maxWeightRecord = null,
    Object? estimated1RM = null,
    Object? totalVolumeRecord = null,
    Object? totalSetsRecord = null,
    Object? lastWorkoutDate = null,
    Object? weeklyFrequency = null,
    Object? firstWorkoutDate = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      maxWeightRecord: null == maxWeightRecord
          ? _value.maxWeightRecord
          : maxWeightRecord // ignore: cast_nullable_to_non_nullable
              as double,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      totalVolumeRecord: null == totalVolumeRecord
          ? _value.totalVolumeRecord
          : totalVolumeRecord // ignore: cast_nullable_to_non_nullable
              as double,
      totalSetsRecord: null == totalSetsRecord
          ? _value.totalSetsRecord
          : totalSetsRecord // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: null == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weeklyFrequency: null == weeklyFrequency
          ? _value.weeklyFrequency
          : weeklyFrequency // ignore: cast_nullable_to_non_nullable
              as double,
      firstWorkoutDate: null == firstWorkoutDate
          ? _value.firstWorkoutDate
          : firstWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseRecordsImplCopyWith<$Res>
    implements $ExerciseRecordsCopyWith<$Res> {
  factory _$$ExerciseRecordsImplCopyWith(_$ExerciseRecordsImpl value,
          $Res Function(_$ExerciseRecordsImpl) then) =
      __$$ExerciseRecordsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      double maxWeightRecord,
      double estimated1RM,
      double totalVolumeRecord,
      int totalSetsRecord,
      DateTime lastWorkoutDate,
      double weeklyFrequency,
      DateTime firstWorkoutDate,
      int totalWorkouts});
}

/// @nodoc
class __$$ExerciseRecordsImplCopyWithImpl<$Res>
    extends _$ExerciseRecordsCopyWithImpl<$Res, _$ExerciseRecordsImpl>
    implements _$$ExerciseRecordsImplCopyWith<$Res> {
  __$$ExerciseRecordsImplCopyWithImpl(
      _$ExerciseRecordsImpl _value, $Res Function(_$ExerciseRecordsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? maxWeightRecord = null,
    Object? estimated1RM = null,
    Object? totalVolumeRecord = null,
    Object? totalSetsRecord = null,
    Object? lastWorkoutDate = null,
    Object? weeklyFrequency = null,
    Object? firstWorkoutDate = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_$ExerciseRecordsImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      maxWeightRecord: null == maxWeightRecord
          ? _value.maxWeightRecord
          : maxWeightRecord // ignore: cast_nullable_to_non_nullable
              as double,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      totalVolumeRecord: null == totalVolumeRecord
          ? _value.totalVolumeRecord
          : totalVolumeRecord // ignore: cast_nullable_to_non_nullable
              as double,
      totalSetsRecord: null == totalSetsRecord
          ? _value.totalSetsRecord
          : totalSetsRecord // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: null == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weeklyFrequency: null == weeklyFrequency
          ? _value.weeklyFrequency
          : weeklyFrequency // ignore: cast_nullable_to_non_nullable
              as double,
      firstWorkoutDate: null == firstWorkoutDate
          ? _value.firstWorkoutDate
          : firstWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseRecordsImpl implements _ExerciseRecords {
  const _$ExerciseRecordsImpl(
      {required this.exerciseName,
      required this.maxWeightRecord,
      required this.estimated1RM,
      required this.totalVolumeRecord,
      required this.totalSetsRecord,
      required this.lastWorkoutDate,
      required this.weeklyFrequency,
      required this.firstWorkoutDate,
      required this.totalWorkouts});

  factory _$ExerciseRecordsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseRecordsImplFromJson(json);

  /// Exercise name (matches ExerciseHistory.exerciseName)
  @override
  final String exerciseName;

  /// Personal Records
  @override
  final double maxWeightRecord;
// Heaviest single set weight (kg)
  @override
  final double estimated1RM;
// Estimated 1 rep max (Epley formula)
  @override
  final double totalVolumeRecord;
// Highest single-workout volume (kg)
  @override
  final int totalSetsRecord;
// Most sets in single workout
  /// Recent Activity
  @override
  final DateTime lastWorkoutDate;
// Most recent workout date
  @override
  final double weeklyFrequency;
// Avg workouts per week (last 4 weeks)
  /// Time Range
  @override
  final DateTime firstWorkoutDate;
// First recorded workout
  @override
  final int totalWorkouts;

  @override
  String toString() {
    return 'ExerciseRecords(exerciseName: $exerciseName, maxWeightRecord: $maxWeightRecord, estimated1RM: $estimated1RM, totalVolumeRecord: $totalVolumeRecord, totalSetsRecord: $totalSetsRecord, lastWorkoutDate: $lastWorkoutDate, weeklyFrequency: $weeklyFrequency, firstWorkoutDate: $firstWorkoutDate, totalWorkouts: $totalWorkouts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseRecordsImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.maxWeightRecord, maxWeightRecord) ||
                other.maxWeightRecord == maxWeightRecord) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.totalVolumeRecord, totalVolumeRecord) ||
                other.totalVolumeRecord == totalVolumeRecord) &&
            (identical(other.totalSetsRecord, totalSetsRecord) ||
                other.totalSetsRecord == totalSetsRecord) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate) &&
            (identical(other.weeklyFrequency, weeklyFrequency) ||
                other.weeklyFrequency == weeklyFrequency) &&
            (identical(other.firstWorkoutDate, firstWorkoutDate) ||
                other.firstWorkoutDate == firstWorkoutDate) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      exerciseName,
      maxWeightRecord,
      estimated1RM,
      totalVolumeRecord,
      totalSetsRecord,
      lastWorkoutDate,
      weeklyFrequency,
      firstWorkoutDate,
      totalWorkouts);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseRecordsImplCopyWith<_$ExerciseRecordsImpl> get copyWith =>
      __$$ExerciseRecordsImplCopyWithImpl<_$ExerciseRecordsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseRecordsImplToJson(
      this,
    );
  }
}

abstract class _ExerciseRecords implements ExerciseRecords {
  const factory _ExerciseRecords(
      {required final String exerciseName,
      required final double maxWeightRecord,
      required final double estimated1RM,
      required final double totalVolumeRecord,
      required final int totalSetsRecord,
      required final DateTime lastWorkoutDate,
      required final double weeklyFrequency,
      required final DateTime firstWorkoutDate,
      required final int totalWorkouts}) = _$ExerciseRecordsImpl;

  factory _ExerciseRecords.fromJson(Map<String, dynamic> json) =
      _$ExerciseRecordsImpl.fromJson;

  @override

  /// Exercise name (matches ExerciseHistory.exerciseName)
  String get exerciseName;
  @override

  /// Personal Records
  double get maxWeightRecord;
  @override // Heaviest single set weight (kg)
  double get estimated1RM;
  @override // Estimated 1 rep max (Epley formula)
  double get totalVolumeRecord;
  @override // Highest single-workout volume (kg)
  int get totalSetsRecord;
  @override // Most sets in single workout
  /// Recent Activity
  DateTime get lastWorkoutDate;
  @override // Most recent workout date
  double get weeklyFrequency;
  @override // Avg workouts per week (last 4 weeks)
  /// Time Range
  DateTime get firstWorkoutDate;
  @override // First recorded workout
  int get totalWorkouts;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseRecordsImplCopyWith<_$ExerciseRecordsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
