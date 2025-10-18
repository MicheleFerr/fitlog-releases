// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutNotification _$WorkoutNotificationFromJson(Map<String, dynamic> json) {
  return _WorkoutNotification.fromJson(json);
}

/// @nodoc
mixin _$WorkoutNotification {
  int get id => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get scheduledTime => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  String? get routineId => throw _privateConstructorUsedError;
  String? get workoutName => throw _privateConstructorUsedError;
  int? get daysToRecover => throw _privateConstructorUsedError;
  bool? get isDelivered => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutNotificationCopyWith<WorkoutNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutNotificationCopyWith<$Res> {
  factory $WorkoutNotificationCopyWith(
          WorkoutNotification value, $Res Function(WorkoutNotification) then) =
      _$WorkoutNotificationCopyWithImpl<$Res, WorkoutNotification>;
  @useResult
  $Res call(
      {int id,
      NotificationType type,
      String title,
      String body,
      DateTime scheduledTime,
      NotificationPriority priority,
      String? routineId,
      String? workoutName,
      int? daysToRecover,
      bool? isDelivered,
      DateTime? deliveredAt,
      Map<String, dynamic>? payload});
}

/// @nodoc
class _$WorkoutNotificationCopyWithImpl<$Res, $Val extends WorkoutNotification>
    implements $WorkoutNotificationCopyWith<$Res> {
  _$WorkoutNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? scheduledTime = null,
    Object? priority = null,
    Object? routineId = freezed,
    Object? workoutName = freezed,
    Object? daysToRecover = freezed,
    Object? isDelivered = freezed,
    Object? deliveredAt = freezed,
    Object? payload = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      routineId: freezed == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutName: freezed == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String?,
      daysToRecover: freezed == daysToRecover
          ? _value.daysToRecover
          : daysToRecover // ignore: cast_nullable_to_non_nullable
              as int?,
      isDelivered: freezed == isDelivered
          ? _value.isDelivered
          : isDelivered // ignore: cast_nullable_to_non_nullable
              as bool?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      payload: freezed == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutNotificationImplCopyWith<$Res>
    implements $WorkoutNotificationCopyWith<$Res> {
  factory _$$WorkoutNotificationImplCopyWith(_$WorkoutNotificationImpl value,
          $Res Function(_$WorkoutNotificationImpl) then) =
      __$$WorkoutNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      NotificationType type,
      String title,
      String body,
      DateTime scheduledTime,
      NotificationPriority priority,
      String? routineId,
      String? workoutName,
      int? daysToRecover,
      bool? isDelivered,
      DateTime? deliveredAt,
      Map<String, dynamic>? payload});
}

/// @nodoc
class __$$WorkoutNotificationImplCopyWithImpl<$Res>
    extends _$WorkoutNotificationCopyWithImpl<$Res, _$WorkoutNotificationImpl>
    implements _$$WorkoutNotificationImplCopyWith<$Res> {
  __$$WorkoutNotificationImplCopyWithImpl(_$WorkoutNotificationImpl _value,
      $Res Function(_$WorkoutNotificationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? scheduledTime = null,
    Object? priority = null,
    Object? routineId = freezed,
    Object? workoutName = freezed,
    Object? daysToRecover = freezed,
    Object? isDelivered = freezed,
    Object? deliveredAt = freezed,
    Object? payload = freezed,
  }) {
    return _then(_$WorkoutNotificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      routineId: freezed == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutName: freezed == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String?,
      daysToRecover: freezed == daysToRecover
          ? _value.daysToRecover
          : daysToRecover // ignore: cast_nullable_to_non_nullable
              as int?,
      isDelivered: freezed == isDelivered
          ? _value.isDelivered
          : isDelivered // ignore: cast_nullable_to_non_nullable
              as bool?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      payload: freezed == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutNotificationImpl implements _WorkoutNotification {
  const _$WorkoutNotificationImpl(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.scheduledTime,
      required this.priority,
      this.routineId,
      this.workoutName,
      this.daysToRecover,
      this.isDelivered,
      this.deliveredAt,
      final Map<String, dynamic>? payload})
      : _payload = payload;

  factory _$WorkoutNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutNotificationImplFromJson(json);

  @override
  final int id;
  @override
  final NotificationType type;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime scheduledTime;
  @override
  final NotificationPriority priority;
  @override
  final String? routineId;
  @override
  final String? workoutName;
  @override
  final int? daysToRecover;
  @override
  final bool? isDelivered;
  @override
  final DateTime? deliveredAt;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'WorkoutNotification(id: $id, type: $type, title: $title, body: $body, scheduledTime: $scheduledTime, priority: $priority, routineId: $routineId, workoutName: $workoutName, daysToRecover: $daysToRecover, isDelivered: $isDelivered, deliveredAt: $deliveredAt, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.daysToRecover, daysToRecover) ||
                other.daysToRecover == daysToRecover) &&
            (identical(other.isDelivered, isDelivered) ||
                other.isDelivered == isDelivered) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            const DeepCollectionEquality().equals(other._payload, _payload));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      body,
      scheduledTime,
      priority,
      routineId,
      workoutName,
      daysToRecover,
      isDelivered,
      deliveredAt,
      const DeepCollectionEquality().hash(_payload));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutNotificationImplCopyWith<_$WorkoutNotificationImpl> get copyWith =>
      __$$WorkoutNotificationImplCopyWithImpl<_$WorkoutNotificationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutNotificationImplToJson(
      this,
    );
  }
}

abstract class _WorkoutNotification implements WorkoutNotification {
  const factory _WorkoutNotification(
      {required final int id,
      required final NotificationType type,
      required final String title,
      required final String body,
      required final DateTime scheduledTime,
      required final NotificationPriority priority,
      final String? routineId,
      final String? workoutName,
      final int? daysToRecover,
      final bool? isDelivered,
      final DateTime? deliveredAt,
      final Map<String, dynamic>? payload}) = _$WorkoutNotificationImpl;

  factory _WorkoutNotification.fromJson(Map<String, dynamic> json) =
      _$WorkoutNotificationImpl.fromJson;

  @override
  int get id;
  @override
  NotificationType get type;
  @override
  String get title;
  @override
  String get body;
  @override
  DateTime get scheduledTime;
  @override
  NotificationPriority get priority;
  @override
  String? get routineId;
  @override
  String? get workoutName;
  @override
  int? get daysToRecover;
  @override
  bool? get isDelivered;
  @override
  DateTime? get deliveredAt;
  @override
  Map<String, dynamic>? get payload;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutNotificationImplCopyWith<_$WorkoutNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  bool get enableWorkoutReminders => throw _privateConstructorUsedError;
  bool get enableRecoveryAlerts => throw _privateConstructorUsedError;
  bool get enableStreakMotivation => throw _privateConstructorUsedError;
  bool get enableRestDayReminders => throw _privateConstructorUsedError;
  NotificationTimePreference get preferredTime =>
      throw _privateConstructorUsedError;
  DateTime? get customTime => throw _privateConstructorUsedError;
  bool get enableSmartScheduling => throw _privateConstructorUsedError;
  bool get doNotDisturbEnabled => throw _privateConstructorUsedError;
  DateTime? get doNotDisturbStart => throw _privateConstructorUsedError;
  DateTime? get doNotDisturbEnd => throw _privateConstructorUsedError;
  int get reminderMinutesBefore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(NotificationSettings value,
          $Res Function(NotificationSettings) then) =
      _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call(
      {bool enableWorkoutReminders,
      bool enableRecoveryAlerts,
      bool enableStreakMotivation,
      bool enableRestDayReminders,
      NotificationTimePreference preferredTime,
      DateTime? customTime,
      bool enableSmartScheduling,
      bool doNotDisturbEnabled,
      DateTime? doNotDisturbStart,
      DateTime? doNotDisturbEnd,
      int reminderMinutesBefore});
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res,
        $Val extends NotificationSettings>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableWorkoutReminders = null,
    Object? enableRecoveryAlerts = null,
    Object? enableStreakMotivation = null,
    Object? enableRestDayReminders = null,
    Object? preferredTime = null,
    Object? customTime = freezed,
    Object? enableSmartScheduling = null,
    Object? doNotDisturbEnabled = null,
    Object? doNotDisturbStart = freezed,
    Object? doNotDisturbEnd = freezed,
    Object? reminderMinutesBefore = null,
  }) {
    return _then(_value.copyWith(
      enableWorkoutReminders: null == enableWorkoutReminders
          ? _value.enableWorkoutReminders
          : enableWorkoutReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRecoveryAlerts: null == enableRecoveryAlerts
          ? _value.enableRecoveryAlerts
          : enableRecoveryAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      enableStreakMotivation: null == enableStreakMotivation
          ? _value.enableStreakMotivation
          : enableStreakMotivation // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRestDayReminders: null == enableRestDayReminders
          ? _value.enableRestDayReminders
          : enableRestDayReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredTime: null == preferredTime
          ? _value.preferredTime
          : preferredTime // ignore: cast_nullable_to_non_nullable
              as NotificationTimePreference,
      customTime: freezed == customTime
          ? _value.customTime
          : customTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      enableSmartScheduling: null == enableSmartScheduling
          ? _value.enableSmartScheduling
          : enableSmartScheduling // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbEnabled: null == doNotDisturbEnabled
          ? _value.doNotDisturbEnabled
          : doNotDisturbEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbStart: freezed == doNotDisturbStart
          ? _value.doNotDisturbStart
          : doNotDisturbStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      doNotDisturbEnd: freezed == doNotDisturbEnd
          ? _value.doNotDisturbEnd
          : doNotDisturbEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reminderMinutesBefore: null == reminderMinutesBefore
          ? _value.reminderMinutesBefore
          : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(_$NotificationSettingsImpl value,
          $Res Function(_$NotificationSettingsImpl) then) =
      __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enableWorkoutReminders,
      bool enableRecoveryAlerts,
      bool enableStreakMotivation,
      bool enableRestDayReminders,
      NotificationTimePreference preferredTime,
      DateTime? customTime,
      bool enableSmartScheduling,
      bool doNotDisturbEnabled,
      DateTime? doNotDisturbStart,
      DateTime? doNotDisturbEnd,
      int reminderMinutesBefore});
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(_$NotificationSettingsImpl _value,
      $Res Function(_$NotificationSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableWorkoutReminders = null,
    Object? enableRecoveryAlerts = null,
    Object? enableStreakMotivation = null,
    Object? enableRestDayReminders = null,
    Object? preferredTime = null,
    Object? customTime = freezed,
    Object? enableSmartScheduling = null,
    Object? doNotDisturbEnabled = null,
    Object? doNotDisturbStart = freezed,
    Object? doNotDisturbEnd = freezed,
    Object? reminderMinutesBefore = null,
  }) {
    return _then(_$NotificationSettingsImpl(
      enableWorkoutReminders: null == enableWorkoutReminders
          ? _value.enableWorkoutReminders
          : enableWorkoutReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRecoveryAlerts: null == enableRecoveryAlerts
          ? _value.enableRecoveryAlerts
          : enableRecoveryAlerts // ignore: cast_nullable_to_non_nullable
              as bool,
      enableStreakMotivation: null == enableStreakMotivation
          ? _value.enableStreakMotivation
          : enableStreakMotivation // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRestDayReminders: null == enableRestDayReminders
          ? _value.enableRestDayReminders
          : enableRestDayReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredTime: null == preferredTime
          ? _value.preferredTime
          : preferredTime // ignore: cast_nullable_to_non_nullable
              as NotificationTimePreference,
      customTime: freezed == customTime
          ? _value.customTime
          : customTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      enableSmartScheduling: null == enableSmartScheduling
          ? _value.enableSmartScheduling
          : enableSmartScheduling // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbEnabled: null == doNotDisturbEnabled
          ? _value.doNotDisturbEnabled
          : doNotDisturbEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbStart: freezed == doNotDisturbStart
          ? _value.doNotDisturbStart
          : doNotDisturbStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      doNotDisturbEnd: freezed == doNotDisturbEnd
          ? _value.doNotDisturbEnd
          : doNotDisturbEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reminderMinutesBefore: null == reminderMinutesBefore
          ? _value.reminderMinutesBefore
          : reminderMinutesBefore // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl(
      {this.enableWorkoutReminders = true,
      this.enableRecoveryAlerts = true,
      this.enableStreakMotivation = false,
      this.enableRestDayReminders = false,
      this.preferredTime = NotificationTimePreference.morning,
      this.customTime,
      this.enableSmartScheduling = true,
      this.doNotDisturbEnabled = false,
      this.doNotDisturbStart,
      this.doNotDisturbEnd,
      this.reminderMinutesBefore = 60});

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool enableWorkoutReminders;
  @override
  @JsonKey()
  final bool enableRecoveryAlerts;
  @override
  @JsonKey()
  final bool enableStreakMotivation;
  @override
  @JsonKey()
  final bool enableRestDayReminders;
  @override
  @JsonKey()
  final NotificationTimePreference preferredTime;
  @override
  final DateTime? customTime;
  @override
  @JsonKey()
  final bool enableSmartScheduling;
  @override
  @JsonKey()
  final bool doNotDisturbEnabled;
  @override
  final DateTime? doNotDisturbStart;
  @override
  final DateTime? doNotDisturbEnd;
  @override
  @JsonKey()
  final int reminderMinutesBefore;

  @override
  String toString() {
    return 'NotificationSettings(enableWorkoutReminders: $enableWorkoutReminders, enableRecoveryAlerts: $enableRecoveryAlerts, enableStreakMotivation: $enableStreakMotivation, enableRestDayReminders: $enableRestDayReminders, preferredTime: $preferredTime, customTime: $customTime, enableSmartScheduling: $enableSmartScheduling, doNotDisturbEnabled: $doNotDisturbEnabled, doNotDisturbStart: $doNotDisturbStart, doNotDisturbEnd: $doNotDisturbEnd, reminderMinutesBefore: $reminderMinutesBefore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.enableWorkoutReminders, enableWorkoutReminders) ||
                other.enableWorkoutReminders == enableWorkoutReminders) &&
            (identical(other.enableRecoveryAlerts, enableRecoveryAlerts) ||
                other.enableRecoveryAlerts == enableRecoveryAlerts) &&
            (identical(other.enableStreakMotivation, enableStreakMotivation) ||
                other.enableStreakMotivation == enableStreakMotivation) &&
            (identical(other.enableRestDayReminders, enableRestDayReminders) ||
                other.enableRestDayReminders == enableRestDayReminders) &&
            (identical(other.preferredTime, preferredTime) ||
                other.preferredTime == preferredTime) &&
            (identical(other.customTime, customTime) ||
                other.customTime == customTime) &&
            (identical(other.enableSmartScheduling, enableSmartScheduling) ||
                other.enableSmartScheduling == enableSmartScheduling) &&
            (identical(other.doNotDisturbEnabled, doNotDisturbEnabled) ||
                other.doNotDisturbEnabled == doNotDisturbEnabled) &&
            (identical(other.doNotDisturbStart, doNotDisturbStart) ||
                other.doNotDisturbStart == doNotDisturbStart) &&
            (identical(other.doNotDisturbEnd, doNotDisturbEnd) ||
                other.doNotDisturbEnd == doNotDisturbEnd) &&
            (identical(other.reminderMinutesBefore, reminderMinutesBefore) ||
                other.reminderMinutesBefore == reminderMinutesBefore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enableWorkoutReminders,
      enableRecoveryAlerts,
      enableStreakMotivation,
      enableRestDayReminders,
      preferredTime,
      customTime,
      enableSmartScheduling,
      doNotDisturbEnabled,
      doNotDisturbStart,
      doNotDisturbEnd,
      reminderMinutesBefore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith =>
          __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings(
      {final bool enableWorkoutReminders,
      final bool enableRecoveryAlerts,
      final bool enableStreakMotivation,
      final bool enableRestDayReminders,
      final NotificationTimePreference preferredTime,
      final DateTime? customTime,
      final bool enableSmartScheduling,
      final bool doNotDisturbEnabled,
      final DateTime? doNotDisturbStart,
      final DateTime? doNotDisturbEnd,
      final int reminderMinutesBefore}) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override
  bool get enableWorkoutReminders;
  @override
  bool get enableRecoveryAlerts;
  @override
  bool get enableStreakMotivation;
  @override
  bool get enableRestDayReminders;
  @override
  NotificationTimePreference get preferredTime;
  @override
  DateTime? get customTime;
  @override
  bool get enableSmartScheduling;
  @override
  bool get doNotDisturbEnabled;
  @override
  DateTime? get doNotDisturbStart;
  @override
  DateTime? get doNotDisturbEnd;
  @override
  int get reminderMinutesBefore;
  @override
  @JsonKey(ignore: true)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
