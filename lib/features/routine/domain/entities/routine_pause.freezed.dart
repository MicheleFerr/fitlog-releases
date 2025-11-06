// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_pause.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoutinePause _$RoutinePauseFromJson(Map<String, dynamic> json) {
  return _RoutinePause.fromJson(json);
}

/// @nodoc
mixin _$RoutinePause {
  /// Unique pause ID
  String get id => throw _privateConstructorUsedError;

  /// Routine being paused
  String get routineId => throw _privateConstructorUsedError;

  /// User who created the pause
  String get userId => throw _privateConstructorUsedError;

  /// Reason for pause
  PauseReason get reason => throw _privateConstructorUsedError;

  /// Start date (normalized to midnight local)
  @TimestampSerializer()
  DateTime get startDate => throw _privateConstructorUsedError;

  /// End date (normalized to midnight local)
  @TimestampSerializer()
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Optional notes (e.g., "Shoulder injury - avoid overhead pressing")
  String? get notes => throw _privateConstructorUsedError;

  /// Whether pause is currently active
  bool get isActive => throw _privateConstructorUsedError;

  /// When pause was created
  @TimestampSerializer()
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // === ANALYTICS FIELDS ===
  /// When pause was resumed (null if auto-resumed)
  @TimestampSerializer()
  DateTime? get resumedAt => throw _privateConstructorUsedError;

  /// Whether user manually resumed (vs auto-resume on endDate)
  bool get userInitiatedResume => throw _privateConstructorUsedError;

  /// Number of workouts skipped during this pause
  int get workoutsSkipped => throw _privateConstructorUsedError;

  /// IDs of workouts skipped (for audit trail)
  List<String> get skippedWorkoutIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoutinePauseCopyWith<RoutinePause> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutinePauseCopyWith<$Res> {
  factory $RoutinePauseCopyWith(
          RoutinePause value, $Res Function(RoutinePause) then) =
      _$RoutinePauseCopyWithImpl<$Res, RoutinePause>;
  @useResult
  $Res call(
      {String id,
      String routineId,
      String userId,
      PauseReason reason,
      @TimestampSerializer() DateTime startDate,
      @TimestampSerializer() DateTime endDate,
      String? notes,
      bool isActive,
      @TimestampSerializer() DateTime createdAt,
      @TimestampSerializer() DateTime? resumedAt,
      bool userInitiatedResume,
      int workoutsSkipped,
      List<String> skippedWorkoutIds});
}

/// @nodoc
class _$RoutinePauseCopyWithImpl<$Res, $Val extends RoutinePause>
    implements $RoutinePauseCopyWith<$Res> {
  _$RoutinePauseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? routineId = null,
    Object? userId = null,
    Object? reason = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? notes = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? resumedAt = freezed,
    Object? userInitiatedResume = null,
    Object? workoutsSkipped = null,
    Object? skippedWorkoutIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      routineId: null == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as PauseReason,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resumedAt: freezed == resumedAt
          ? _value.resumedAt
          : resumedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userInitiatedResume: null == userInitiatedResume
          ? _value.userInitiatedResume
          : userInitiatedResume // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutsSkipped: null == workoutsSkipped
          ? _value.workoutsSkipped
          : workoutsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      skippedWorkoutIds: null == skippedWorkoutIds
          ? _value.skippedWorkoutIds
          : skippedWorkoutIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutinePauseImplCopyWith<$Res>
    implements $RoutinePauseCopyWith<$Res> {
  factory _$$RoutinePauseImplCopyWith(
          _$RoutinePauseImpl value, $Res Function(_$RoutinePauseImpl) then) =
      __$$RoutinePauseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String routineId,
      String userId,
      PauseReason reason,
      @TimestampSerializer() DateTime startDate,
      @TimestampSerializer() DateTime endDate,
      String? notes,
      bool isActive,
      @TimestampSerializer() DateTime createdAt,
      @TimestampSerializer() DateTime? resumedAt,
      bool userInitiatedResume,
      int workoutsSkipped,
      List<String> skippedWorkoutIds});
}

/// @nodoc
class __$$RoutinePauseImplCopyWithImpl<$Res>
    extends _$RoutinePauseCopyWithImpl<$Res, _$RoutinePauseImpl>
    implements _$$RoutinePauseImplCopyWith<$Res> {
  __$$RoutinePauseImplCopyWithImpl(
      _$RoutinePauseImpl _value, $Res Function(_$RoutinePauseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? routineId = null,
    Object? userId = null,
    Object? reason = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? notes = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? resumedAt = freezed,
    Object? userInitiatedResume = null,
    Object? workoutsSkipped = null,
    Object? skippedWorkoutIds = null,
  }) {
    return _then(_$RoutinePauseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      routineId: null == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as PauseReason,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resumedAt: freezed == resumedAt
          ? _value.resumedAt
          : resumedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userInitiatedResume: null == userInitiatedResume
          ? _value.userInitiatedResume
          : userInitiatedResume // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutsSkipped: null == workoutsSkipped
          ? _value.workoutsSkipped
          : workoutsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      skippedWorkoutIds: null == skippedWorkoutIds
          ? _value._skippedWorkoutIds
          : skippedWorkoutIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutinePauseImpl extends _RoutinePause {
  const _$RoutinePauseImpl(
      {required this.id,
      required this.routineId,
      required this.userId,
      required this.reason,
      @TimestampSerializer() required this.startDate,
      @TimestampSerializer() required this.endDate,
      this.notes,
      this.isActive = true,
      @TimestampSerializer() required this.createdAt,
      @TimestampSerializer() this.resumedAt,
      this.userInitiatedResume = false,
      this.workoutsSkipped = 0,
      final List<String> skippedWorkoutIds = const []})
      : _skippedWorkoutIds = skippedWorkoutIds,
        super._();

  factory _$RoutinePauseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutinePauseImplFromJson(json);

  /// Unique pause ID
  @override
  final String id;

  /// Routine being paused
  @override
  final String routineId;

  /// User who created the pause
  @override
  final String userId;

  /// Reason for pause
  @override
  final PauseReason reason;

  /// Start date (normalized to midnight local)
  @override
  @TimestampSerializer()
  final DateTime startDate;

  /// End date (normalized to midnight local)
  @override
  @TimestampSerializer()
  final DateTime endDate;

  /// Optional notes (e.g., "Shoulder injury - avoid overhead pressing")
  @override
  final String? notes;

  /// Whether pause is currently active
  @override
  @JsonKey()
  final bool isActive;

  /// When pause was created
  @override
  @TimestampSerializer()
  final DateTime createdAt;
// === ANALYTICS FIELDS ===
  /// When pause was resumed (null if auto-resumed)
  @override
  @TimestampSerializer()
  final DateTime? resumedAt;

  /// Whether user manually resumed (vs auto-resume on endDate)
  @override
  @JsonKey()
  final bool userInitiatedResume;

  /// Number of workouts skipped during this pause
  @override
  @JsonKey()
  final int workoutsSkipped;

  /// IDs of workouts skipped (for audit trail)
  final List<String> _skippedWorkoutIds;

  /// IDs of workouts skipped (for audit trail)
  @override
  @JsonKey()
  List<String> get skippedWorkoutIds {
    if (_skippedWorkoutIds is EqualUnmodifiableListView)
      return _skippedWorkoutIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skippedWorkoutIds);
  }

  @override
  String toString() {
    return 'RoutinePause(id: $id, routineId: $routineId, userId: $userId, reason: $reason, startDate: $startDate, endDate: $endDate, notes: $notes, isActive: $isActive, createdAt: $createdAt, resumedAt: $resumedAt, userInitiatedResume: $userInitiatedResume, workoutsSkipped: $workoutsSkipped, skippedWorkoutIds: $skippedWorkoutIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutinePauseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resumedAt, resumedAt) ||
                other.resumedAt == resumedAt) &&
            (identical(other.userInitiatedResume, userInitiatedResume) ||
                other.userInitiatedResume == userInitiatedResume) &&
            (identical(other.workoutsSkipped, workoutsSkipped) ||
                other.workoutsSkipped == workoutsSkipped) &&
            const DeepCollectionEquality()
                .equals(other._skippedWorkoutIds, _skippedWorkoutIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      routineId,
      userId,
      reason,
      startDate,
      endDate,
      notes,
      isActive,
      createdAt,
      resumedAt,
      userInitiatedResume,
      workoutsSkipped,
      const DeepCollectionEquality().hash(_skippedWorkoutIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutinePauseImplCopyWith<_$RoutinePauseImpl> get copyWith =>
      __$$RoutinePauseImplCopyWithImpl<_$RoutinePauseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutinePauseImplToJson(
      this,
    );
  }
}

abstract class _RoutinePause extends RoutinePause {
  const factory _RoutinePause(
      {required final String id,
      required final String routineId,
      required final String userId,
      required final PauseReason reason,
      @TimestampSerializer() required final DateTime startDate,
      @TimestampSerializer() required final DateTime endDate,
      final String? notes,
      final bool isActive,
      @TimestampSerializer() required final DateTime createdAt,
      @TimestampSerializer() final DateTime? resumedAt,
      final bool userInitiatedResume,
      final int workoutsSkipped,
      final List<String> skippedWorkoutIds}) = _$RoutinePauseImpl;
  const _RoutinePause._() : super._();

  factory _RoutinePause.fromJson(Map<String, dynamic> json) =
      _$RoutinePauseImpl.fromJson;

  @override

  /// Unique pause ID
  String get id;
  @override

  /// Routine being paused
  String get routineId;
  @override

  /// User who created the pause
  String get userId;
  @override

  /// Reason for pause
  PauseReason get reason;
  @override

  /// Start date (normalized to midnight local)
  @TimestampSerializer()
  DateTime get startDate;
  @override

  /// End date (normalized to midnight local)
  @TimestampSerializer()
  DateTime get endDate;
  @override

  /// Optional notes (e.g., "Shoulder injury - avoid overhead pressing")
  String? get notes;
  @override

  /// Whether pause is currently active
  bool get isActive;
  @override

  /// When pause was created
  @TimestampSerializer()
  DateTime get createdAt;
  @override // === ANALYTICS FIELDS ===
  /// When pause was resumed (null if auto-resumed)
  @TimestampSerializer()
  DateTime? get resumedAt;
  @override

  /// Whether user manually resumed (vs auto-resume on endDate)
  bool get userInitiatedResume;
  @override

  /// Number of workouts skipped during this pause
  int get workoutsSkipped;
  @override

  /// IDs of workouts skipped (for audit trail)
  List<String> get skippedWorkoutIds;
  @override
  @JsonKey(ignore: true)
  _$$RoutinePauseImplCopyWith<_$RoutinePauseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
