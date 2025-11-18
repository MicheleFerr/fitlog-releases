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
// === v1.0 Fields (Backward Compatible) ===
  bool get enableWorkoutReminders => throw _privateConstructorUsedError;
  bool get enableRecoveryAlerts => throw _privateConstructorUsedError;
  bool get enableStreakMotivation => throw _privateConstructorUsedError;
  bool get enableRestDayReminders => throw _privateConstructorUsedError;
  bool get enableSupplementReminders =>
      throw _privateConstructorUsedError; // Achievement notifications (v2.0 - Priority 2)
  bool get enablePRNotifications => throw _privateConstructorUsedError;
  bool get enableStreakAchievements => throw _privateConstructorUsedError;
  bool get enableGoalCompletions => throw _privateConstructorUsedError;
  bool get enableMilestones => throw _privateConstructorUsedError;
  NotificationTimePreference get preferredTime =>
      throw _privateConstructorUsedError;
  DateTime? get customTime => throw _privateConstructorUsedError;
  bool get enableSmartScheduling => throw _privateConstructorUsedError;
  bool get doNotDisturbEnabled => throw _privateConstructorUsedError;
  DateTime? get doNotDisturbStart => throw _privateConstructorUsedError;
  DateTime? get doNotDisturbEnd => throw _privateConstructorUsedError;
  int get reminderMinutesBefore =>
      throw _privateConstructorUsedError; // === v2.0 New Fields ===
  /// Custom time per notification type (e.g., workout reminders at 09:00, recovery at 18:00)
  /// Key: NotificationType.name (string), Value: DateTime (time component only)
  Map<String, DateTime> get customTimePerType =>
      throw _privateConstructorUsedError;

  /// Per-category quiet hours (e.g., workout reminders quiet 22:00-08:00)
  /// Key: NotificationType.name (string), Value: QuietHours configuration
  Map<String, QuietHours> get categoryQuietHours =>
      throw _privateConstructorUsedError;

  /// Global frequency cap preferences (research-backed: 3/day, 5/week)
  FrequencyCap? get frequencyCapPreferences =>
      throw _privateConstructorUsedError;

  /// Per-category frequency caps (override global)
  /// Key: NotificationType.name (string), Value: FrequencyCap configuration
  Map<String, FrequencyCap> get categoryFrequencyCaps =>
      throw _privateConstructorUsedError;

  /// GDPR Article 7.1: Timestamp when user gave explicit consent
  /// NULL = grandfathered user (assumed implicit consent)
  DateTime? get consentTimestamp => throw _privateConstructorUsedError;

  /// Version of consent agreement user agreed to (e.g., '1.0', '1.1', '2.0')
  /// Increment when consent terms change (requires re-consent)
  String get consentVersion => throw _privateConstructorUsedError;

  /// User opted in to analytics data collection
  /// Default: false (GDPR requires opt-in, not opt-out)
  bool get enableAnalytics => throw _privateConstructorUsedError;

  /// GDPR Article 5.1.e: Data retention period (in days)
  /// Default: 90 days (industry standard for notification history)
  /// Options: 30, 60, 90, 180, 365, or 9999 ('forever')
  int get dataRetentionDays => throw _privateConstructorUsedError;

  /// Cross-device sync: Last synced timestamp (Firestore server timestamp)
  /// NULL = never synced
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Cross-device sync: Device ID that last modified settings
  /// Format: '{platform}_{uuid}' (e.g., 'ios_abc123', 'android_def456')
  String? get deviceId => throw _privateConstructorUsedError;

  /// Schema version for migrations (1 = v1.0, 2 = v2.0)
  /// Used to detect when migration is needed
  int get settingsVersion => throw _privateConstructorUsedError;

  /// Migration metadata: Source system ('v1_sharedprefs', 'firestore', 'default')
  /// NULL = fresh v2.0 install
  String? get migrationSource => throw _privateConstructorUsedError;

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
      bool enableSupplementReminders,
      bool enablePRNotifications,
      bool enableStreakAchievements,
      bool enableGoalCompletions,
      bool enableMilestones,
      NotificationTimePreference preferredTime,
      DateTime? customTime,
      bool enableSmartScheduling,
      bool doNotDisturbEnabled,
      DateTime? doNotDisturbStart,
      DateTime? doNotDisturbEnd,
      int reminderMinutesBefore,
      Map<String, DateTime> customTimePerType,
      Map<String, QuietHours> categoryQuietHours,
      FrequencyCap? frequencyCapPreferences,
      Map<String, FrequencyCap> categoryFrequencyCaps,
      DateTime? consentTimestamp,
      String consentVersion,
      bool enableAnalytics,
      int dataRetentionDays,
      DateTime? lastSyncedAt,
      String? deviceId,
      int settingsVersion,
      String? migrationSource});

  $FrequencyCapCopyWith<$Res>? get frequencyCapPreferences;
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
    Object? enableSupplementReminders = null,
    Object? enablePRNotifications = null,
    Object? enableStreakAchievements = null,
    Object? enableGoalCompletions = null,
    Object? enableMilestones = null,
    Object? preferredTime = null,
    Object? customTime = freezed,
    Object? enableSmartScheduling = null,
    Object? doNotDisturbEnabled = null,
    Object? doNotDisturbStart = freezed,
    Object? doNotDisturbEnd = freezed,
    Object? reminderMinutesBefore = null,
    Object? customTimePerType = null,
    Object? categoryQuietHours = null,
    Object? frequencyCapPreferences = freezed,
    Object? categoryFrequencyCaps = null,
    Object? consentTimestamp = freezed,
    Object? consentVersion = null,
    Object? enableAnalytics = null,
    Object? dataRetentionDays = null,
    Object? lastSyncedAt = freezed,
    Object? deviceId = freezed,
    Object? settingsVersion = null,
    Object? migrationSource = freezed,
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
      enableSupplementReminders: null == enableSupplementReminders
          ? _value.enableSupplementReminders
          : enableSupplementReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePRNotifications: null == enablePRNotifications
          ? _value.enablePRNotifications
          : enablePRNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableStreakAchievements: null == enableStreakAchievements
          ? _value.enableStreakAchievements
          : enableStreakAchievements // ignore: cast_nullable_to_non_nullable
              as bool,
      enableGoalCompletions: null == enableGoalCompletions
          ? _value.enableGoalCompletions
          : enableGoalCompletions // ignore: cast_nullable_to_non_nullable
              as bool,
      enableMilestones: null == enableMilestones
          ? _value.enableMilestones
          : enableMilestones // ignore: cast_nullable_to_non_nullable
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
      customTimePerType: null == customTimePerType
          ? _value.customTimePerType
          : customTimePerType // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      categoryQuietHours: null == categoryQuietHours
          ? _value.categoryQuietHours
          : categoryQuietHours // ignore: cast_nullable_to_non_nullable
              as Map<String, QuietHours>,
      frequencyCapPreferences: freezed == frequencyCapPreferences
          ? _value.frequencyCapPreferences
          : frequencyCapPreferences // ignore: cast_nullable_to_non_nullable
              as FrequencyCap?,
      categoryFrequencyCaps: null == categoryFrequencyCaps
          ? _value.categoryFrequencyCaps
          : categoryFrequencyCaps // ignore: cast_nullable_to_non_nullable
              as Map<String, FrequencyCap>,
      consentTimestamp: freezed == consentTimestamp
          ? _value.consentTimestamp
          : consentTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      consentVersion: null == consentVersion
          ? _value.consentVersion
          : consentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      enableAnalytics: null == enableAnalytics
          ? _value.enableAnalytics
          : enableAnalytics // ignore: cast_nullable_to_non_nullable
              as bool,
      dataRetentionDays: null == dataRetentionDays
          ? _value.dataRetentionDays
          : dataRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      settingsVersion: null == settingsVersion
          ? _value.settingsVersion
          : settingsVersion // ignore: cast_nullable_to_non_nullable
              as int,
      migrationSource: freezed == migrationSource
          ? _value.migrationSource
          : migrationSource // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FrequencyCapCopyWith<$Res>? get frequencyCapPreferences {
    if (_value.frequencyCapPreferences == null) {
      return null;
    }

    return $FrequencyCapCopyWith<$Res>(_value.frequencyCapPreferences!,
        (value) {
      return _then(_value.copyWith(frequencyCapPreferences: value) as $Val);
    });
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
      bool enableSupplementReminders,
      bool enablePRNotifications,
      bool enableStreakAchievements,
      bool enableGoalCompletions,
      bool enableMilestones,
      NotificationTimePreference preferredTime,
      DateTime? customTime,
      bool enableSmartScheduling,
      bool doNotDisturbEnabled,
      DateTime? doNotDisturbStart,
      DateTime? doNotDisturbEnd,
      int reminderMinutesBefore,
      Map<String, DateTime> customTimePerType,
      Map<String, QuietHours> categoryQuietHours,
      FrequencyCap? frequencyCapPreferences,
      Map<String, FrequencyCap> categoryFrequencyCaps,
      DateTime? consentTimestamp,
      String consentVersion,
      bool enableAnalytics,
      int dataRetentionDays,
      DateTime? lastSyncedAt,
      String? deviceId,
      int settingsVersion,
      String? migrationSource});

  @override
  $FrequencyCapCopyWith<$Res>? get frequencyCapPreferences;
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
    Object? enableSupplementReminders = null,
    Object? enablePRNotifications = null,
    Object? enableStreakAchievements = null,
    Object? enableGoalCompletions = null,
    Object? enableMilestones = null,
    Object? preferredTime = null,
    Object? customTime = freezed,
    Object? enableSmartScheduling = null,
    Object? doNotDisturbEnabled = null,
    Object? doNotDisturbStart = freezed,
    Object? doNotDisturbEnd = freezed,
    Object? reminderMinutesBefore = null,
    Object? customTimePerType = null,
    Object? categoryQuietHours = null,
    Object? frequencyCapPreferences = freezed,
    Object? categoryFrequencyCaps = null,
    Object? consentTimestamp = freezed,
    Object? consentVersion = null,
    Object? enableAnalytics = null,
    Object? dataRetentionDays = null,
    Object? lastSyncedAt = freezed,
    Object? deviceId = freezed,
    Object? settingsVersion = null,
    Object? migrationSource = freezed,
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
      enableSupplementReminders: null == enableSupplementReminders
          ? _value.enableSupplementReminders
          : enableSupplementReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePRNotifications: null == enablePRNotifications
          ? _value.enablePRNotifications
          : enablePRNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableStreakAchievements: null == enableStreakAchievements
          ? _value.enableStreakAchievements
          : enableStreakAchievements // ignore: cast_nullable_to_non_nullable
              as bool,
      enableGoalCompletions: null == enableGoalCompletions
          ? _value.enableGoalCompletions
          : enableGoalCompletions // ignore: cast_nullable_to_non_nullable
              as bool,
      enableMilestones: null == enableMilestones
          ? _value.enableMilestones
          : enableMilestones // ignore: cast_nullable_to_non_nullable
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
      customTimePerType: null == customTimePerType
          ? _value._customTimePerType
          : customTimePerType // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      categoryQuietHours: null == categoryQuietHours
          ? _value._categoryQuietHours
          : categoryQuietHours // ignore: cast_nullable_to_non_nullable
              as Map<String, QuietHours>,
      frequencyCapPreferences: freezed == frequencyCapPreferences
          ? _value.frequencyCapPreferences
          : frequencyCapPreferences // ignore: cast_nullable_to_non_nullable
              as FrequencyCap?,
      categoryFrequencyCaps: null == categoryFrequencyCaps
          ? _value._categoryFrequencyCaps
          : categoryFrequencyCaps // ignore: cast_nullable_to_non_nullable
              as Map<String, FrequencyCap>,
      consentTimestamp: freezed == consentTimestamp
          ? _value.consentTimestamp
          : consentTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      consentVersion: null == consentVersion
          ? _value.consentVersion
          : consentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      enableAnalytics: null == enableAnalytics
          ? _value.enableAnalytics
          : enableAnalytics // ignore: cast_nullable_to_non_nullable
              as bool,
      dataRetentionDays: null == dataRetentionDays
          ? _value.dataRetentionDays
          : dataRetentionDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      settingsVersion: null == settingsVersion
          ? _value.settingsVersion
          : settingsVersion // ignore: cast_nullable_to_non_nullable
              as int,
      migrationSource: freezed == migrationSource
          ? _value.migrationSource
          : migrationSource // ignore: cast_nullable_to_non_nullable
              as String?,
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
      this.enableSupplementReminders = false,
      this.enablePRNotifications = false,
      this.enableStreakAchievements = false,
      this.enableGoalCompletions = false,
      this.enableMilestones = false,
      this.preferredTime = NotificationTimePreference.morning,
      this.customTime,
      this.enableSmartScheduling = true,
      this.doNotDisturbEnabled = false,
      this.doNotDisturbStart,
      this.doNotDisturbEnd,
      this.reminderMinutesBefore = 60,
      final Map<String, DateTime> customTimePerType = const {},
      final Map<String, QuietHours> categoryQuietHours = const {},
      this.frequencyCapPreferences,
      final Map<String, FrequencyCap> categoryFrequencyCaps = const {},
      this.consentTimestamp,
      this.consentVersion = '1.0',
      this.enableAnalytics = false,
      this.dataRetentionDays = 90,
      this.lastSyncedAt,
      this.deviceId,
      this.settingsVersion = 2,
      this.migrationSource})
      : _customTimePerType = customTimePerType,
        _categoryQuietHours = categoryQuietHours,
        _categoryFrequencyCaps = categoryFrequencyCaps;

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

// === v1.0 Fields (Backward Compatible) ===
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
  final bool enableSupplementReminders;
// Achievement notifications (v2.0 - Priority 2)
  @override
  @JsonKey()
  final bool enablePRNotifications;
  @override
  @JsonKey()
  final bool enableStreakAchievements;
  @override
  @JsonKey()
  final bool enableGoalCompletions;
  @override
  @JsonKey()
  final bool enableMilestones;
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
// === v2.0 New Fields ===
  /// Custom time per notification type (e.g., workout reminders at 09:00, recovery at 18:00)
  /// Key: NotificationType.name (string), Value: DateTime (time component only)
  final Map<String, DateTime> _customTimePerType;
// === v2.0 New Fields ===
  /// Custom time per notification type (e.g., workout reminders at 09:00, recovery at 18:00)
  /// Key: NotificationType.name (string), Value: DateTime (time component only)
  @override
  @JsonKey()
  Map<String, DateTime> get customTimePerType {
    if (_customTimePerType is EqualUnmodifiableMapView)
      return _customTimePerType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customTimePerType);
  }

  /// Per-category quiet hours (e.g., workout reminders quiet 22:00-08:00)
  /// Key: NotificationType.name (string), Value: QuietHours configuration
  final Map<String, QuietHours> _categoryQuietHours;

  /// Per-category quiet hours (e.g., workout reminders quiet 22:00-08:00)
  /// Key: NotificationType.name (string), Value: QuietHours configuration
  @override
  @JsonKey()
  Map<String, QuietHours> get categoryQuietHours {
    if (_categoryQuietHours is EqualUnmodifiableMapView)
      return _categoryQuietHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryQuietHours);
  }

  /// Global frequency cap preferences (research-backed: 3/day, 5/week)
  @override
  final FrequencyCap? frequencyCapPreferences;

  /// Per-category frequency caps (override global)
  /// Key: NotificationType.name (string), Value: FrequencyCap configuration
  final Map<String, FrequencyCap> _categoryFrequencyCaps;

  /// Per-category frequency caps (override global)
  /// Key: NotificationType.name (string), Value: FrequencyCap configuration
  @override
  @JsonKey()
  Map<String, FrequencyCap> get categoryFrequencyCaps {
    if (_categoryFrequencyCaps is EqualUnmodifiableMapView)
      return _categoryFrequencyCaps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryFrequencyCaps);
  }

  /// GDPR Article 7.1: Timestamp when user gave explicit consent
  /// NULL = grandfathered user (assumed implicit consent)
  @override
  final DateTime? consentTimestamp;

  /// Version of consent agreement user agreed to (e.g., '1.0', '1.1', '2.0')
  /// Increment when consent terms change (requires re-consent)
  @override
  @JsonKey()
  final String consentVersion;

  /// User opted in to analytics data collection
  /// Default: false (GDPR requires opt-in, not opt-out)
  @override
  @JsonKey()
  final bool enableAnalytics;

  /// GDPR Article 5.1.e: Data retention period (in days)
  /// Default: 90 days (industry standard for notification history)
  /// Options: 30, 60, 90, 180, 365, or 9999 ('forever')
  @override
  @JsonKey()
  final int dataRetentionDays;

  /// Cross-device sync: Last synced timestamp (Firestore server timestamp)
  /// NULL = never synced
  @override
  final DateTime? lastSyncedAt;

  /// Cross-device sync: Device ID that last modified settings
  /// Format: '{platform}_{uuid}' (e.g., 'ios_abc123', 'android_def456')
  @override
  final String? deviceId;

  /// Schema version for migrations (1 = v1.0, 2 = v2.0)
  /// Used to detect when migration is needed
  @override
  @JsonKey()
  final int settingsVersion;

  /// Migration metadata: Source system ('v1_sharedprefs', 'firestore', 'default')
  /// NULL = fresh v2.0 install
  @override
  final String? migrationSource;

  @override
  String toString() {
    return 'NotificationSettings(enableWorkoutReminders: $enableWorkoutReminders, enableRecoveryAlerts: $enableRecoveryAlerts, enableStreakMotivation: $enableStreakMotivation, enableRestDayReminders: $enableRestDayReminders, enableSupplementReminders: $enableSupplementReminders, enablePRNotifications: $enablePRNotifications, enableStreakAchievements: $enableStreakAchievements, enableGoalCompletions: $enableGoalCompletions, enableMilestones: $enableMilestones, preferredTime: $preferredTime, customTime: $customTime, enableSmartScheduling: $enableSmartScheduling, doNotDisturbEnabled: $doNotDisturbEnabled, doNotDisturbStart: $doNotDisturbStart, doNotDisturbEnd: $doNotDisturbEnd, reminderMinutesBefore: $reminderMinutesBefore, customTimePerType: $customTimePerType, categoryQuietHours: $categoryQuietHours, frequencyCapPreferences: $frequencyCapPreferences, categoryFrequencyCaps: $categoryFrequencyCaps, consentTimestamp: $consentTimestamp, consentVersion: $consentVersion, enableAnalytics: $enableAnalytics, dataRetentionDays: $dataRetentionDays, lastSyncedAt: $lastSyncedAt, deviceId: $deviceId, settingsVersion: $settingsVersion, migrationSource: $migrationSource)';
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
            (identical(other.enableSupplementReminders, enableSupplementReminders) ||
                other.enableSupplementReminders == enableSupplementReminders) &&
            (identical(other.enablePRNotifications, enablePRNotifications) ||
                other.enablePRNotifications == enablePRNotifications) &&
            (identical(other.enableStreakAchievements, enableStreakAchievements) ||
                other.enableStreakAchievements == enableStreakAchievements) &&
            (identical(other.enableGoalCompletions, enableGoalCompletions) ||
                other.enableGoalCompletions == enableGoalCompletions) &&
            (identical(other.enableMilestones, enableMilestones) ||
                other.enableMilestones == enableMilestones) &&
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
                other.reminderMinutesBefore == reminderMinutesBefore) &&
            const DeepCollectionEquality()
                .equals(other._customTimePerType, _customTimePerType) &&
            const DeepCollectionEquality()
                .equals(other._categoryQuietHours, _categoryQuietHours) &&
            (identical(other.frequencyCapPreferences, frequencyCapPreferences) ||
                other.frequencyCapPreferences == frequencyCapPreferences) &&
            const DeepCollectionEquality()
                .equals(other._categoryFrequencyCaps, _categoryFrequencyCaps) &&
            (identical(other.consentTimestamp, consentTimestamp) ||
                other.consentTimestamp == consentTimestamp) &&
            (identical(other.consentVersion, consentVersion) ||
                other.consentVersion == consentVersion) &&
            (identical(other.enableAnalytics, enableAnalytics) ||
                other.enableAnalytics == enableAnalytics) &&
            (identical(other.dataRetentionDays, dataRetentionDays) ||
                other.dataRetentionDays == dataRetentionDays) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.settingsVersion, settingsVersion) ||
                other.settingsVersion == settingsVersion) &&
            (identical(other.migrationSource, migrationSource) || other.migrationSource == migrationSource));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        enableWorkoutReminders,
        enableRecoveryAlerts,
        enableStreakMotivation,
        enableRestDayReminders,
        enableSupplementReminders,
        enablePRNotifications,
        enableStreakAchievements,
        enableGoalCompletions,
        enableMilestones,
        preferredTime,
        customTime,
        enableSmartScheduling,
        doNotDisturbEnabled,
        doNotDisturbStart,
        doNotDisturbEnd,
        reminderMinutesBefore,
        const DeepCollectionEquality().hash(_customTimePerType),
        const DeepCollectionEquality().hash(_categoryQuietHours),
        frequencyCapPreferences,
        const DeepCollectionEquality().hash(_categoryFrequencyCaps),
        consentTimestamp,
        consentVersion,
        enableAnalytics,
        dataRetentionDays,
        lastSyncedAt,
        deviceId,
        settingsVersion,
        migrationSource
      ]);

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
      final bool enableSupplementReminders,
      final bool enablePRNotifications,
      final bool enableStreakAchievements,
      final bool enableGoalCompletions,
      final bool enableMilestones,
      final NotificationTimePreference preferredTime,
      final DateTime? customTime,
      final bool enableSmartScheduling,
      final bool doNotDisturbEnabled,
      final DateTime? doNotDisturbStart,
      final DateTime? doNotDisturbEnd,
      final int reminderMinutesBefore,
      final Map<String, DateTime> customTimePerType,
      final Map<String, QuietHours> categoryQuietHours,
      final FrequencyCap? frequencyCapPreferences,
      final Map<String, FrequencyCap> categoryFrequencyCaps,
      final DateTime? consentTimestamp,
      final String consentVersion,
      final bool enableAnalytics,
      final int dataRetentionDays,
      final DateTime? lastSyncedAt,
      final String? deviceId,
      final int settingsVersion,
      final String? migrationSource}) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override // === v1.0 Fields (Backward Compatible) ===
  bool get enableWorkoutReminders;
  @override
  bool get enableRecoveryAlerts;
  @override
  bool get enableStreakMotivation;
  @override
  bool get enableRestDayReminders;
  @override
  bool get enableSupplementReminders;
  @override // Achievement notifications (v2.0 - Priority 2)
  bool get enablePRNotifications;
  @override
  bool get enableStreakAchievements;
  @override
  bool get enableGoalCompletions;
  @override
  bool get enableMilestones;
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
  @override // === v2.0 New Fields ===
  /// Custom time per notification type (e.g., workout reminders at 09:00, recovery at 18:00)
  /// Key: NotificationType.name (string), Value: DateTime (time component only)
  Map<String, DateTime> get customTimePerType;
  @override

  /// Per-category quiet hours (e.g., workout reminders quiet 22:00-08:00)
  /// Key: NotificationType.name (string), Value: QuietHours configuration
  Map<String, QuietHours> get categoryQuietHours;
  @override

  /// Global frequency cap preferences (research-backed: 3/day, 5/week)
  FrequencyCap? get frequencyCapPreferences;
  @override

  /// Per-category frequency caps (override global)
  /// Key: NotificationType.name (string), Value: FrequencyCap configuration
  Map<String, FrequencyCap> get categoryFrequencyCaps;
  @override

  /// GDPR Article 7.1: Timestamp when user gave explicit consent
  /// NULL = grandfathered user (assumed implicit consent)
  DateTime? get consentTimestamp;
  @override

  /// Version of consent agreement user agreed to (e.g., '1.0', '1.1', '2.0')
  /// Increment when consent terms change (requires re-consent)
  String get consentVersion;
  @override

  /// User opted in to analytics data collection
  /// Default: false (GDPR requires opt-in, not opt-out)
  bool get enableAnalytics;
  @override

  /// GDPR Article 5.1.e: Data retention period (in days)
  /// Default: 90 days (industry standard for notification history)
  /// Options: 30, 60, 90, 180, 365, or 9999 ('forever')
  int get dataRetentionDays;
  @override

  /// Cross-device sync: Last synced timestamp (Firestore server timestamp)
  /// NULL = never synced
  DateTime? get lastSyncedAt;
  @override

  /// Cross-device sync: Device ID that last modified settings
  /// Format: '{platform}_{uuid}' (e.g., 'ios_abc123', 'android_def456')
  String? get deviceId;
  @override

  /// Schema version for migrations (1 = v1.0, 2 = v2.0)
  /// Used to detect when migration is needed
  int get settingsVersion;
  @override

  /// Migration metadata: Source system ('v1_sharedprefs', 'firestore', 'default')
  /// NULL = fresh v2.0 install
  String? get migrationSource;
  @override
  @JsonKey(ignore: true)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
