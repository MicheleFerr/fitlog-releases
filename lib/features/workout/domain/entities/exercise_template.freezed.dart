// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseTemplate _$ExerciseTemplateFromJson(Map<String, dynamic> json) {
  return _ExerciseTemplate.fromJson(json);
}

/// @nodoc
mixin _$ExerciseTemplate {
  String get exerciseName => throw _privateConstructorUsedError;
  double get defaultWeight => throw _privateConstructorUsedError;
  int get defaultReps => throw _privateConstructorUsedError;
  int get defaultSets => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseTemplateCopyWith<ExerciseTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseTemplateCopyWith<$Res> {
  factory $ExerciseTemplateCopyWith(
          ExerciseTemplate value, $Res Function(ExerciseTemplate) then) =
      _$ExerciseTemplateCopyWithImpl<$Res, ExerciseTemplate>;
  @useResult
  $Res call(
      {String exerciseName,
      double defaultWeight,
      int defaultReps,
      int defaultSets,
      String? notes});
}

/// @nodoc
class _$ExerciseTemplateCopyWithImpl<$Res, $Val extends ExerciseTemplate>
    implements $ExerciseTemplateCopyWith<$Res> {
  _$ExerciseTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? defaultWeight = null,
    Object? defaultReps = null,
    Object? defaultSets = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultWeight: null == defaultWeight
          ? _value.defaultWeight
          : defaultWeight // ignore: cast_nullable_to_non_nullable
              as double,
      defaultReps: null == defaultReps
          ? _value.defaultReps
          : defaultReps // ignore: cast_nullable_to_non_nullable
              as int,
      defaultSets: null == defaultSets
          ? _value.defaultSets
          : defaultSets // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseTemplateImplCopyWith<$Res>
    implements $ExerciseTemplateCopyWith<$Res> {
  factory _$$ExerciseTemplateImplCopyWith(_$ExerciseTemplateImpl value,
          $Res Function(_$ExerciseTemplateImpl) then) =
      __$$ExerciseTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseName,
      double defaultWeight,
      int defaultReps,
      int defaultSets,
      String? notes});
}

/// @nodoc
class __$$ExerciseTemplateImplCopyWithImpl<$Res>
    extends _$ExerciseTemplateCopyWithImpl<$Res, _$ExerciseTemplateImpl>
    implements _$$ExerciseTemplateImplCopyWith<$Res> {
  __$$ExerciseTemplateImplCopyWithImpl(_$ExerciseTemplateImpl _value,
      $Res Function(_$ExerciseTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? defaultWeight = null,
    Object? defaultReps = null,
    Object? defaultSets = null,
    Object? notes = freezed,
  }) {
    return _then(_$ExerciseTemplateImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultWeight: null == defaultWeight
          ? _value.defaultWeight
          : defaultWeight // ignore: cast_nullable_to_non_nullable
              as double,
      defaultReps: null == defaultReps
          ? _value.defaultReps
          : defaultReps // ignore: cast_nullable_to_non_nullable
              as int,
      defaultSets: null == defaultSets
          ? _value.defaultSets
          : defaultSets // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseTemplateImpl extends _ExerciseTemplate {
  const _$ExerciseTemplateImpl(
      {required this.exerciseName,
      required this.defaultWeight,
      required this.defaultReps,
      required this.defaultSets,
      this.notes})
      : super._();

  factory _$ExerciseTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseTemplateImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final double defaultWeight;
  @override
  final int defaultReps;
  @override
  final int defaultSets;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ExerciseTemplate(exerciseName: $exerciseName, defaultWeight: $defaultWeight, defaultReps: $defaultReps, defaultSets: $defaultSets, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseTemplateImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.defaultWeight, defaultWeight) ||
                other.defaultWeight == defaultWeight) &&
            (identical(other.defaultReps, defaultReps) ||
                other.defaultReps == defaultReps) &&
            (identical(other.defaultSets, defaultSets) ||
                other.defaultSets == defaultSets) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, defaultWeight,
      defaultReps, defaultSets, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseTemplateImplCopyWith<_$ExerciseTemplateImpl> get copyWith =>
      __$$ExerciseTemplateImplCopyWithImpl<_$ExerciseTemplateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseTemplateImplToJson(
      this,
    );
  }
}

abstract class _ExerciseTemplate extends ExerciseTemplate {
  const factory _ExerciseTemplate(
      {required final String exerciseName,
      required final double defaultWeight,
      required final int defaultReps,
      required final int defaultSets,
      final String? notes}) = _$ExerciseTemplateImpl;
  const _ExerciseTemplate._() : super._();

  factory _ExerciseTemplate.fromJson(Map<String, dynamic> json) =
      _$ExerciseTemplateImpl.fromJson;

  @override
  String get exerciseName;
  @override
  double get defaultWeight;
  @override
  int get defaultReps;
  @override
  int get defaultSets;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseTemplateImplCopyWith<_$ExerciseTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
