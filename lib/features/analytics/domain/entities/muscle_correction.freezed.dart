// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_correction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MuscleCorrection _$MuscleCorrectionFromJson(Map<String, dynamic> json) {
  return _MuscleCorrection.fromJson(json);
}

/// @nodoc
mixin _$MuscleCorrection {
  /// Exercise name (e.g., "Bench Press", "Squat")
  String get exerciseName => throw _privateConstructorUsedError;

  /// Original muscle group (e.g., "Chest", "Back")
  String get oldMuscleGroup => throw _privateConstructorUsedError;

  /// Corrected muscle group (e.g., "Shoulders", "Legs")
  String get newMuscleGroup => throw _privateConstructorUsedError;

  /// When the correction was made (local timestamp)
  DateTime get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MuscleCorrectionCopyWith<MuscleCorrection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleCorrectionCopyWith<$Res> {
  factory $MuscleCorrectionCopyWith(
          MuscleCorrection value, $Res Function(MuscleCorrection) then) =
      _$MuscleCorrectionCopyWithImpl<$Res, MuscleCorrection>;
  @useResult
  $Res call(
      {String exerciseName,
      String oldMuscleGroup,
      String newMuscleGroup,
      DateTime timestamp});
}

/// @nodoc
class _$MuscleCorrectionCopyWithImpl<$Res, $Val extends MuscleCorrection>
    implements $MuscleCorrectionCopyWith<$Res> {
  _$MuscleCorrectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? oldMuscleGroup = null,
    Object? newMuscleGroup = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      oldMuscleGroup: null == oldMuscleGroup
          ? _value.oldMuscleGroup
          : oldMuscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      newMuscleGroup: null == newMuscleGroup
          ? _value.newMuscleGroup
          : newMuscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MuscleCorrectionImplCopyWith<$Res>
    implements $MuscleCorrectionCopyWith<$Res> {
  factory _$$MuscleCorrectionImplCopyWith(_$MuscleCorrectionImpl value,
          $Res Function(_$MuscleCorrectionImpl) then) =
      __$$MuscleCorrectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      String oldMuscleGroup,
      String newMuscleGroup,
      DateTime timestamp});
}

/// @nodoc
class __$$MuscleCorrectionImplCopyWithImpl<$Res>
    extends _$MuscleCorrectionCopyWithImpl<$Res, _$MuscleCorrectionImpl>
    implements _$$MuscleCorrectionImplCopyWith<$Res> {
  __$$MuscleCorrectionImplCopyWithImpl(_$MuscleCorrectionImpl _value,
      $Res Function(_$MuscleCorrectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? oldMuscleGroup = null,
    Object? newMuscleGroup = null,
    Object? timestamp = null,
  }) {
    return _then(_$MuscleCorrectionImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      oldMuscleGroup: null == oldMuscleGroup
          ? _value.oldMuscleGroup
          : oldMuscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      newMuscleGroup: null == newMuscleGroup
          ? _value.newMuscleGroup
          : newMuscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleCorrectionImpl implements _MuscleCorrection {
  const _$MuscleCorrectionImpl(
      {required this.exerciseName,
      required this.oldMuscleGroup,
      required this.newMuscleGroup,
      required this.timestamp});

  factory _$MuscleCorrectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleCorrectionImplFromJson(json);

  /// Exercise name (e.g., "Bench Press", "Squat")
  @override
  final String exerciseName;

  /// Original muscle group (e.g., "Chest", "Back")
  @override
  final String oldMuscleGroup;

  /// Corrected muscle group (e.g., "Shoulders", "Legs")
  @override
  final String newMuscleGroup;

  /// When the correction was made (local timestamp)
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'MuscleCorrection(exerciseName: $exerciseName, oldMuscleGroup: $oldMuscleGroup, newMuscleGroup: $newMuscleGroup, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleCorrectionImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.oldMuscleGroup, oldMuscleGroup) ||
                other.oldMuscleGroup == oldMuscleGroup) &&
            (identical(other.newMuscleGroup, newMuscleGroup) ||
                other.newMuscleGroup == newMuscleGroup) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, exerciseName, oldMuscleGroup, newMuscleGroup, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleCorrectionImplCopyWith<_$MuscleCorrectionImpl> get copyWith =>
      __$$MuscleCorrectionImplCopyWithImpl<_$MuscleCorrectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleCorrectionImplToJson(
      this,
    );
  }
}

abstract class _MuscleCorrection implements MuscleCorrection {
  const factory _MuscleCorrection(
      {required final String exerciseName,
      required final String oldMuscleGroup,
      required final String newMuscleGroup,
      required final DateTime timestamp}) = _$MuscleCorrectionImpl;

  factory _MuscleCorrection.fromJson(Map<String, dynamic> json) =
      _$MuscleCorrectionImpl.fromJson;

  @override

  /// Exercise name (e.g., "Bench Press", "Squat")
  String get exerciseName;
  @override

  /// Original muscle group (e.g., "Chest", "Back")
  String get oldMuscleGroup;
  @override

  /// Corrected muscle group (e.g., "Shoulders", "Legs")
  String get newMuscleGroup;
  @override

  /// When the correction was made (local timestamp)
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$MuscleCorrectionImplCopyWith<_$MuscleCorrectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
