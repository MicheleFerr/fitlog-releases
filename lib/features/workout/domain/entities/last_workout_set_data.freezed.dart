// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'last_workout_set_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LastWorkoutSetData _$LastWorkoutSetDataFromJson(Map<String, dynamic> json) {
  return _LastWorkoutSetData.fromJson(json);
}

/// @nodoc
mixin _$LastWorkoutSetData {
  /// Weight used in the last workout (in kg)
  double get weight => throw _privateConstructorUsedError;

  /// Number of reps completed
  int get reps => throw _privateConstructorUsedError;

  /// RPE rating (1-10) if recorded
  int? get rpe => throw _privateConstructorUsedError;

  /// Date when this workout was completed
  DateTime get date => throw _privateConstructorUsedError;

  /// Name of the workout (e.g., "Push Day")
  String? get workoutName => throw _privateConstructorUsedError;

  /// Set number this data corresponds to
  int get setNumber => throw _privateConstructorUsedError;

  /// Exercise name for reference
  String get exerciseName => throw _privateConstructorUsedError;

  /// Serializes this LastWorkoutSetData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LastWorkoutSetData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LastWorkoutSetDataCopyWith<LastWorkoutSetData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LastWorkoutSetDataCopyWith<$Res> {
  factory $LastWorkoutSetDataCopyWith(
    LastWorkoutSetData value,
    $Res Function(LastWorkoutSetData) then,
  ) = _$LastWorkoutSetDataCopyWithImpl<$Res, LastWorkoutSetData>;
  @useResult
  $Res call({
    double weight,
    int reps,
    int? rpe,
    DateTime date,
    String? workoutName,
    int setNumber,
    String exerciseName,
  });
}

/// @nodoc
class _$LastWorkoutSetDataCopyWithImpl<$Res, $Val extends LastWorkoutSetData>
    implements $LastWorkoutSetDataCopyWith<$Res> {
  _$LastWorkoutSetDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LastWorkoutSetData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
    Object? date = null,
    Object? workoutName = freezed,
    Object? setNumber = null,
    Object? exerciseName = null,
  }) {
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
            rpe: freezed == rpe
                ? _value.rpe
                : rpe // ignore: cast_nullable_to_non_nullable
                      as int?,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            workoutName: freezed == workoutName
                ? _value.workoutName
                : workoutName // ignore: cast_nullable_to_non_nullable
                      as String?,
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            exerciseName: null == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LastWorkoutSetDataImplCopyWith<$Res>
    implements $LastWorkoutSetDataCopyWith<$Res> {
  factory _$$LastWorkoutSetDataImplCopyWith(
    _$LastWorkoutSetDataImpl value,
    $Res Function(_$LastWorkoutSetDataImpl) then,
  ) = __$$LastWorkoutSetDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double weight,
    int reps,
    int? rpe,
    DateTime date,
    String? workoutName,
    int setNumber,
    String exerciseName,
  });
}

/// @nodoc
class __$$LastWorkoutSetDataImplCopyWithImpl<$Res>
    extends _$LastWorkoutSetDataCopyWithImpl<$Res, _$LastWorkoutSetDataImpl>
    implements _$$LastWorkoutSetDataImplCopyWith<$Res> {
  __$$LastWorkoutSetDataImplCopyWithImpl(
    _$LastWorkoutSetDataImpl _value,
    $Res Function(_$LastWorkoutSetDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LastWorkoutSetData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weight = null,
    Object? reps = null,
    Object? rpe = freezed,
    Object? date = null,
    Object? workoutName = freezed,
    Object? setNumber = null,
    Object? exerciseName = null,
  }) {
    return _then(
      _$LastWorkoutSetDataImpl(
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        reps: null == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as int,
        rpe: freezed == rpe
            ? _value.rpe
            : rpe // ignore: cast_nullable_to_non_nullable
                  as int?,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        workoutName: freezed == workoutName
            ? _value.workoutName
            : workoutName // ignore: cast_nullable_to_non_nullable
                  as String?,
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LastWorkoutSetDataImpl implements _LastWorkoutSetData {
  const _$LastWorkoutSetDataImpl({
    required this.weight,
    required this.reps,
    this.rpe,
    required this.date,
    this.workoutName,
    required this.setNumber,
    required this.exerciseName,
  });

  factory _$LastWorkoutSetDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$LastWorkoutSetDataImplFromJson(json);

  /// Weight used in the last workout (in kg)
  @override
  final double weight;

  /// Number of reps completed
  @override
  final int reps;

  /// RPE rating (1-10) if recorded
  @override
  final int? rpe;

  /// Date when this workout was completed
  @override
  final DateTime date;

  /// Name of the workout (e.g., "Push Day")
  @override
  final String? workoutName;

  /// Set number this data corresponds to
  @override
  final int setNumber;

  /// Exercise name for reference
  @override
  final String exerciseName;

  @override
  String toString() {
    return 'LastWorkoutSetData(weight: $weight, reps: $reps, rpe: $rpe, date: $date, workoutName: $workoutName, setNumber: $setNumber, exerciseName: $exerciseName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LastWorkoutSetDataImpl &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    weight,
    reps,
    rpe,
    date,
    workoutName,
    setNumber,
    exerciseName,
  );

  /// Create a copy of LastWorkoutSetData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LastWorkoutSetDataImplCopyWith<_$LastWorkoutSetDataImpl> get copyWith =>
      __$$LastWorkoutSetDataImplCopyWithImpl<_$LastWorkoutSetDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LastWorkoutSetDataImplToJson(this);
  }
}

abstract class _LastWorkoutSetData implements LastWorkoutSetData {
  const factory _LastWorkoutSetData({
    required final double weight,
    required final int reps,
    final int? rpe,
    required final DateTime date,
    final String? workoutName,
    required final int setNumber,
    required final String exerciseName,
  }) = _$LastWorkoutSetDataImpl;

  factory _LastWorkoutSetData.fromJson(Map<String, dynamic> json) =
      _$LastWorkoutSetDataImpl.fromJson;

  /// Weight used in the last workout (in kg)
  @override
  double get weight;

  /// Number of reps completed
  @override
  int get reps;

  /// RPE rating (1-10) if recorded
  @override
  int? get rpe;

  /// Date when this workout was completed
  @override
  DateTime get date;

  /// Name of the workout (e.g., "Push Day")
  @override
  String? get workoutName;

  /// Set number this data corresponds to
  @override
  int get setNumber;

  /// Exercise name for reference
  @override
  String get exerciseName;

  /// Create a copy of LastWorkoutSetData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LastWorkoutSetDataImplCopyWith<_$LastWorkoutSetDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LastWorkoutSetParams _$LastWorkoutSetParamsFromJson(Map<String, dynamic> json) {
  return _LastWorkoutSetParams.fromJson(json);
}

/// @nodoc
mixin _$LastWorkoutSetParams {
  String get exerciseName => throw _privateConstructorUsedError;
  int get setNumber => throw _privateConstructorUsedError;

  /// Serializes this LastWorkoutSetParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LastWorkoutSetParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LastWorkoutSetParamsCopyWith<LastWorkoutSetParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LastWorkoutSetParamsCopyWith<$Res> {
  factory $LastWorkoutSetParamsCopyWith(
    LastWorkoutSetParams value,
    $Res Function(LastWorkoutSetParams) then,
  ) = _$LastWorkoutSetParamsCopyWithImpl<$Res, LastWorkoutSetParams>;
  @useResult
  $Res call({String exerciseName, int setNumber});
}

/// @nodoc
class _$LastWorkoutSetParamsCopyWithImpl<
  $Res,
  $Val extends LastWorkoutSetParams
>
    implements $LastWorkoutSetParamsCopyWith<$Res> {
  _$LastWorkoutSetParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LastWorkoutSetParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? exerciseName = null, Object? setNumber = null}) {
    return _then(
      _value.copyWith(
            exerciseName: null == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String,
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LastWorkoutSetParamsImplCopyWith<$Res>
    implements $LastWorkoutSetParamsCopyWith<$Res> {
  factory _$$LastWorkoutSetParamsImplCopyWith(
    _$LastWorkoutSetParamsImpl value,
    $Res Function(_$LastWorkoutSetParamsImpl) then,
  ) = __$$LastWorkoutSetParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String exerciseName, int setNumber});
}

/// @nodoc
class __$$LastWorkoutSetParamsImplCopyWithImpl<$Res>
    extends _$LastWorkoutSetParamsCopyWithImpl<$Res, _$LastWorkoutSetParamsImpl>
    implements _$$LastWorkoutSetParamsImplCopyWith<$Res> {
  __$$LastWorkoutSetParamsImplCopyWithImpl(
    _$LastWorkoutSetParamsImpl _value,
    $Res Function(_$LastWorkoutSetParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LastWorkoutSetParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? exerciseName = null, Object? setNumber = null}) {
    return _then(
      _$LastWorkoutSetParamsImpl(
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LastWorkoutSetParamsImpl implements _LastWorkoutSetParams {
  const _$LastWorkoutSetParamsImpl({
    required this.exerciseName,
    required this.setNumber,
  });

  factory _$LastWorkoutSetParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LastWorkoutSetParamsImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final int setNumber;

  @override
  String toString() {
    return 'LastWorkoutSetParams(exerciseName: $exerciseName, setNumber: $setNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LastWorkoutSetParamsImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, setNumber);

  /// Create a copy of LastWorkoutSetParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LastWorkoutSetParamsImplCopyWith<_$LastWorkoutSetParamsImpl>
  get copyWith =>
      __$$LastWorkoutSetParamsImplCopyWithImpl<_$LastWorkoutSetParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LastWorkoutSetParamsImplToJson(this);
  }
}

abstract class _LastWorkoutSetParams implements LastWorkoutSetParams {
  const factory _LastWorkoutSetParams({
    required final String exerciseName,
    required final int setNumber,
  }) = _$LastWorkoutSetParamsImpl;

  factory _LastWorkoutSetParams.fromJson(Map<String, dynamic> json) =
      _$LastWorkoutSetParamsImpl.fromJson;

  @override
  String get exerciseName;
  @override
  int get setNumber;

  /// Create a copy of LastWorkoutSetParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LastWorkoutSetParamsImplCopyWith<_$LastWorkoutSetParamsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
