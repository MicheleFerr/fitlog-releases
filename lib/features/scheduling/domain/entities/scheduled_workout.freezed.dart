// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScheduledWorkout _$ScheduledWorkoutFromJson(Map<String, dynamic> json) {
  return _ScheduledWorkout.fromJson(json);
}

/// @nodoc
mixin _$ScheduledWorkout {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// ID of the template this workout is based on
  String get templateId => throw _privateConstructorUsedError;

  /// Name of the template (cached for display)
  String get templateName => throw _privateConstructorUsedError;

  /// Date when the workout is scheduled
  DateTime get scheduledDate => throw _privateConstructorUsedError;

  /// Hour component of reminder time (0-23)
  int get reminderHour => throw _privateConstructorUsedError;

  /// Minute component of reminder time (0-59)
  int get reminderMinute => throw _privateConstructorUsedError;

  /// Current status of the scheduled workout
  ScheduleStatus get status => throw _privateConstructorUsedError;

  /// When the workout was completed (if applicable)
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// When this schedule was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// ID of the notification scheduled for this workout (for cancellation)
  String? get notificationId => throw _privateConstructorUsedError;

  /// Serializes this ScheduledWorkout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduledWorkoutCopyWith<ScheduledWorkout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduledWorkoutCopyWith<$Res> {
  factory $ScheduledWorkoutCopyWith(
    ScheduledWorkout value,
    $Res Function(ScheduledWorkout) then,
  ) = _$ScheduledWorkoutCopyWithImpl<$Res, ScheduledWorkout>;
  @useResult
  $Res call({
    String id,
    String templateId,
    String templateName,
    DateTime scheduledDate,
    int reminderHour,
    int reminderMinute,
    ScheduleStatus status,
    DateTime? completedAt,
    DateTime? createdAt,
    String? notificationId,
  });
}

/// @nodoc
class _$ScheduledWorkoutCopyWithImpl<$Res, $Val extends ScheduledWorkout>
    implements $ScheduledWorkoutCopyWith<$Res> {
  _$ScheduledWorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? templateName = null,
    Object? scheduledDate = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? status = null,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? notificationId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            templateId: null == templateId
                ? _value.templateId
                : templateId // ignore: cast_nullable_to_non_nullable
                      as String,
            templateName: null == templateName
                ? _value.templateName
                : templateName // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledDate: null == scheduledDate
                ? _value.scheduledDate
                : scheduledDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reminderHour: null == reminderHour
                ? _value.reminderHour
                : reminderHour // ignore: cast_nullable_to_non_nullable
                      as int,
            reminderMinute: null == reminderMinute
                ? _value.reminderMinute
                : reminderMinute // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ScheduleStatus,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notificationId: freezed == notificationId
                ? _value.notificationId
                : notificationId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduledWorkoutImplCopyWith<$Res>
    implements $ScheduledWorkoutCopyWith<$Res> {
  factory _$$ScheduledWorkoutImplCopyWith(
    _$ScheduledWorkoutImpl value,
    $Res Function(_$ScheduledWorkoutImpl) then,
  ) = __$$ScheduledWorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String templateId,
    String templateName,
    DateTime scheduledDate,
    int reminderHour,
    int reminderMinute,
    ScheduleStatus status,
    DateTime? completedAt,
    DateTime? createdAt,
    String? notificationId,
  });
}

/// @nodoc
class __$$ScheduledWorkoutImplCopyWithImpl<$Res>
    extends _$ScheduledWorkoutCopyWithImpl<$Res, _$ScheduledWorkoutImpl>
    implements _$$ScheduledWorkoutImplCopyWith<$Res> {
  __$$ScheduledWorkoutImplCopyWithImpl(
    _$ScheduledWorkoutImpl _value,
    $Res Function(_$ScheduledWorkoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? templateName = null,
    Object? scheduledDate = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? status = null,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? notificationId = freezed,
  }) {
    return _then(
      _$ScheduledWorkoutImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        templateId: null == templateId
            ? _value.templateId
            : templateId // ignore: cast_nullable_to_non_nullable
                  as String,
        templateName: null == templateName
            ? _value.templateName
            : templateName // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledDate: null == scheduledDate
            ? _value.scheduledDate
            : scheduledDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reminderHour: null == reminderHour
            ? _value.reminderHour
            : reminderHour // ignore: cast_nullable_to_non_nullable
                  as int,
        reminderMinute: null == reminderMinute
            ? _value.reminderMinute
            : reminderMinute // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ScheduleStatus,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notificationId: freezed == notificationId
            ? _value.notificationId
            : notificationId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduledWorkoutImpl extends _ScheduledWorkout {
  const _$ScheduledWorkoutImpl({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.scheduledDate,
    required this.reminderHour,
    required this.reminderMinute,
    this.status = ScheduleStatus.pending,
    this.completedAt,
    this.createdAt,
    this.notificationId,
  }) : super._();

  factory _$ScheduledWorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduledWorkoutImplFromJson(json);

  /// Unique identifier
  @override
  final String id;

  /// ID of the template this workout is based on
  @override
  final String templateId;

  /// Name of the template (cached for display)
  @override
  final String templateName;

  /// Date when the workout is scheduled
  @override
  final DateTime scheduledDate;

  /// Hour component of reminder time (0-23)
  @override
  final int reminderHour;

  /// Minute component of reminder time (0-59)
  @override
  final int reminderMinute;

  /// Current status of the scheduled workout
  @override
  @JsonKey()
  final ScheduleStatus status;

  /// When the workout was completed (if applicable)
  @override
  final DateTime? completedAt;

  /// When this schedule was created
  @override
  final DateTime? createdAt;

  /// ID of the notification scheduled for this workout (for cancellation)
  @override
  final String? notificationId;

  @override
  String toString() {
    return 'ScheduledWorkout(id: $id, templateId: $templateId, templateName: $templateName, scheduledDate: $scheduledDate, reminderHour: $reminderHour, reminderMinute: $reminderMinute, status: $status, completedAt: $completedAt, createdAt: $createdAt, notificationId: $notificationId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduledWorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.reminderHour, reminderHour) ||
                other.reminderHour == reminderHour) &&
            (identical(other.reminderMinute, reminderMinute) ||
                other.reminderMinute == reminderMinute) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    templateId,
    templateName,
    scheduledDate,
    reminderHour,
    reminderMinute,
    status,
    completedAt,
    createdAt,
    notificationId,
  );

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduledWorkoutImplCopyWith<_$ScheduledWorkoutImpl> get copyWith =>
      __$$ScheduledWorkoutImplCopyWithImpl<_$ScheduledWorkoutImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduledWorkoutImplToJson(this);
  }
}

abstract class _ScheduledWorkout extends ScheduledWorkout {
  const factory _ScheduledWorkout({
    required final String id,
    required final String templateId,
    required final String templateName,
    required final DateTime scheduledDate,
    required final int reminderHour,
    required final int reminderMinute,
    final ScheduleStatus status,
    final DateTime? completedAt,
    final DateTime? createdAt,
    final String? notificationId,
  }) = _$ScheduledWorkoutImpl;
  const _ScheduledWorkout._() : super._();

  factory _ScheduledWorkout.fromJson(Map<String, dynamic> json) =
      _$ScheduledWorkoutImpl.fromJson;

  /// Unique identifier
  @override
  String get id;

  /// ID of the template this workout is based on
  @override
  String get templateId;

  /// Name of the template (cached for display)
  @override
  String get templateName;

  /// Date when the workout is scheduled
  @override
  DateTime get scheduledDate;

  /// Hour component of reminder time (0-23)
  @override
  int get reminderHour;

  /// Minute component of reminder time (0-59)
  @override
  int get reminderMinute;

  /// Current status of the scheduled workout
  @override
  ScheduleStatus get status;

  /// When the workout was completed (if applicable)
  @override
  DateTime? get completedAt;

  /// When this schedule was created
  @override
  DateTime? get createdAt;

  /// ID of the notification scheduled for this workout (for cancellation)
  @override
  String? get notificationId;

  /// Create a copy of ScheduledWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduledWorkoutImplCopyWith<_$ScheduledWorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
