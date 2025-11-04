// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return _Workout.fromJson(json);
}

/// @nodoc
mixin _$Workout {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<Exercise> get exercises => throw _privateConstructorUsedError;
  WorkoutStatus get status => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get templateId =>
      throw _privateConstructorUsedError; // 🆕 Pre-load management
  bool get isPreloaded => throw _privateConstructorUsedError;
  DateTime? get preloadExpiry => throw _privateConstructorUsedError;
  bool? get exercisesModified =>
      throw _privateConstructorUsedError; // 🆕 Analytics tracking
  String? get sessionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutCopyWith<Workout> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCopyWith<$Res> {
  factory $WorkoutCopyWith(Workout value, $Res Function(Workout) then) =
      _$WorkoutCopyWithImpl<$Res, Workout>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<Exercise> exercises,
      WorkoutStatus status,
      DateTime? startTime,
      DateTime? endTime,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      String? templateId,
      bool isPreloaded,
      DateTime? preloadExpiry,
      bool? exercisesModified,
      String? sessionId});
}

/// @nodoc
class _$WorkoutCopyWithImpl<$Res, $Val extends Workout>
    implements $WorkoutCopyWith<$Res> {
  _$WorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? exercises = null,
    Object? status = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? templateId = freezed,
    Object? isPreloaded = null,
    Object? preloadExpiry = freezed,
    Object? exercisesModified = freezed,
    Object? sessionId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPreloaded: null == isPreloaded
          ? _value.isPreloaded
          : isPreloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      preloadExpiry: freezed == preloadExpiry
          ? _value.preloadExpiry
          : preloadExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exercisesModified: freezed == exercisesModified
          ? _value.exercisesModified
          : exercisesModified // ignore: cast_nullable_to_non_nullable
              as bool?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutImplCopyWith<$Res> implements $WorkoutCopyWith<$Res> {
  factory _$$WorkoutImplCopyWith(
          _$WorkoutImpl value, $Res Function(_$WorkoutImpl) then) =
      __$$WorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<Exercise> exercises,
      WorkoutStatus status,
      DateTime? startTime,
      DateTime? endTime,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      String? templateId,
      bool isPreloaded,
      DateTime? preloadExpiry,
      bool? exercisesModified,
      String? sessionId});
}

/// @nodoc
class __$$WorkoutImplCopyWithImpl<$Res>
    extends _$WorkoutCopyWithImpl<$Res, _$WorkoutImpl>
    implements _$$WorkoutImplCopyWith<$Res> {
  __$$WorkoutImplCopyWithImpl(
      _$WorkoutImpl _value, $Res Function(_$WorkoutImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? exercises = null,
    Object? status = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? templateId = freezed,
    Object? isPreloaded = null,
    Object? preloadExpiry = freezed,
    Object? exercisesModified = freezed,
    Object? sessionId = freezed,
  }) {
    return _then(_$WorkoutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WorkoutStatus,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPreloaded: null == isPreloaded
          ? _value.isPreloaded
          : isPreloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      preloadExpiry: freezed == preloadExpiry
          ? _value.preloadExpiry
          : preloadExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exercisesModified: freezed == exercisesModified
          ? _value.exercisesModified
          : exercisesModified // ignore: cast_nullable_to_non_nullable
              as bool?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutImpl extends _Workout {
  const _$WorkoutImpl(
      {required this.id,
      required this.name,
      final List<Exercise> exercises = const [],
      this.status = WorkoutStatus.planned,
      this.startTime,
      this.endTime,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.templateId,
      this.isPreloaded = false,
      this.preloadExpiry,
      this.exercisesModified,
      this.sessionId})
      : _exercises = exercises,
        super._();

  factory _$WorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<Exercise> _exercises;
  @override
  @JsonKey()
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  @JsonKey()
  final WorkoutStatus status;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? templateId;
// 🆕 Pre-load management
  @override
  @JsonKey()
  final bool isPreloaded;
  @override
  final DateTime? preloadExpiry;
  @override
  final bool? exercisesModified;
// 🆕 Analytics tracking
  @override
  final String? sessionId;

  @override
  String toString() {
    return 'Workout(id: $id, name: $name, exercises: $exercises, status: $status, startTime: $startTime, endTime: $endTime, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, templateId: $templateId, isPreloaded: $isPreloaded, preloadExpiry: $preloadExpiry, exercisesModified: $exercisesModified, sessionId: $sessionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.isPreloaded, isPreloaded) ||
                other.isPreloaded == isPreloaded) &&
            (identical(other.preloadExpiry, preloadExpiry) ||
                other.preloadExpiry == preloadExpiry) &&
            (identical(other.exercisesModified, exercisesModified) ||
                other.exercisesModified == exercisesModified) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_exercises),
      status,
      startTime,
      endTime,
      notes,
      createdAt,
      updatedAt,
      templateId,
      isPreloaded,
      preloadExpiry,
      exercisesModified,
      sessionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      __$$WorkoutImplCopyWithImpl<_$WorkoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutImplToJson(
      this,
    );
  }
}

abstract class _Workout extends Workout {
  const factory _Workout(
      {required final String id,
      required final String name,
      final List<Exercise> exercises,
      final WorkoutStatus status,
      final DateTime? startTime,
      final DateTime? endTime,
      final String? notes,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? templateId,
      final bool isPreloaded,
      final DateTime? preloadExpiry,
      final bool? exercisesModified,
      final String? sessionId}) = _$WorkoutImpl;
  const _Workout._() : super._();

  factory _Workout.fromJson(Map<String, dynamic> json) = _$WorkoutImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<Exercise> get exercises;
  @override
  WorkoutStatus get status;
  @override
  DateTime? get startTime;
  @override
  DateTime? get endTime;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get templateId;
  @override // 🆕 Pre-load management
  bool get isPreloaded;
  @override
  DateTime? get preloadExpiry;
  @override
  bool? get exercisesModified;
  @override // 🆕 Analytics tracking
  String? get sessionId;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
