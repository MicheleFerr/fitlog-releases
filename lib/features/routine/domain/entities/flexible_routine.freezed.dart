// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flexible_routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduledDay _$ScheduledDayFromJson(Map<String, dynamic> json) {
  return _ScheduledDay.fromJson(json);
}

/// @nodoc
mixin _$ScheduledDay {
  DateTime get date => throw _privateConstructorUsedError;
  DayStatus get status => throw _privateConstructorUsedError;

  /// Template ID if workout day, null if rest
  String? get templateId => throw _privateConstructorUsedError;

  /// Workout ID if completed
  String? get workoutId => throw _privateConstructorUsedError;

  /// Skip reason if skipped
  String? get skipReason => throw _privateConstructorUsedError;

  /// Original date if this is a recovery day
  DateTime? get originalDate => throw _privateConstructorUsedError;

  /// Notes for this day
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduledDayCopyWith<ScheduledDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduledDayCopyWith<$Res> {
  factory $ScheduledDayCopyWith(
          ScheduledDay value, $Res Function(ScheduledDay) then) =
      _$ScheduledDayCopyWithImpl<$Res, ScheduledDay>;
  @useResult
  $Res call(
      {DateTime date,
      DayStatus status,
      String? templateId,
      String? workoutId,
      String? skipReason,
      DateTime? originalDate,
      String? notes});
}

/// @nodoc
class _$ScheduledDayCopyWithImpl<$Res, $Val extends ScheduledDay>
    implements $ScheduledDayCopyWith<$Res> {
  _$ScheduledDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? status = null,
    Object? templateId = freezed,
    Object? workoutId = freezed,
    Object? skipReason = freezed,
    Object? originalDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DayStatus,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutId: freezed == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String?,
      skipReason: freezed == skipReason
          ? _value.skipReason
          : skipReason // ignore: cast_nullable_to_non_nullable
              as String?,
      originalDate: freezed == originalDate
          ? _value.originalDate
          : originalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduledDayImplCopyWith<$Res>
    implements $ScheduledDayCopyWith<$Res> {
  factory _$$ScheduledDayImplCopyWith(
          _$ScheduledDayImpl value, $Res Function(_$ScheduledDayImpl) then) =
      __$$ScheduledDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      DayStatus status,
      String? templateId,
      String? workoutId,
      String? skipReason,
      DateTime? originalDate,
      String? notes});
}

/// @nodoc
class __$$ScheduledDayImplCopyWithImpl<$Res>
    extends _$ScheduledDayCopyWithImpl<$Res, _$ScheduledDayImpl>
    implements _$$ScheduledDayImplCopyWith<$Res> {
  __$$ScheduledDayImplCopyWithImpl(
      _$ScheduledDayImpl _value, $Res Function(_$ScheduledDayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? status = null,
    Object? templateId = freezed,
    Object? workoutId = freezed,
    Object? skipReason = freezed,
    Object? originalDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$ScheduledDayImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DayStatus,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutId: freezed == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String?,
      skipReason: freezed == skipReason
          ? _value.skipReason
          : skipReason // ignore: cast_nullable_to_non_nullable
              as String?,
      originalDate: freezed == originalDate
          ? _value.originalDate
          : originalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduledDayImpl implements _ScheduledDay {
  const _$ScheduledDayImpl(
      {required this.date,
      required this.status,
      this.templateId,
      this.workoutId,
      this.skipReason,
      this.originalDate,
      this.notes});

  factory _$ScheduledDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduledDayImplFromJson(json);

  @override
  final DateTime date;
  @override
  final DayStatus status;

  /// Template ID if workout day, null if rest
  @override
  final String? templateId;

  /// Workout ID if completed
  @override
  final String? workoutId;

  /// Skip reason if skipped
  @override
  final String? skipReason;

  /// Original date if this is a recovery day
  @override
  final DateTime? originalDate;

  /// Notes for this day
  @override
  final String? notes;

  @override
  String toString() {
    return 'ScheduledDay(date: $date, status: $status, templateId: $templateId, workoutId: $workoutId, skipReason: $skipReason, originalDate: $originalDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduledDayImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.skipReason, skipReason) ||
                other.skipReason == skipReason) &&
            (identical(other.originalDate, originalDate) ||
                other.originalDate == originalDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, status, templateId,
      workoutId, skipReason, originalDate, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduledDayImplCopyWith<_$ScheduledDayImpl> get copyWith =>
      __$$ScheduledDayImplCopyWithImpl<_$ScheduledDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduledDayImplToJson(
      this,
    );
  }
}

abstract class _ScheduledDay implements ScheduledDay {
  const factory _ScheduledDay(
      {required final DateTime date,
      required final DayStatus status,
      final String? templateId,
      final String? workoutId,
      final String? skipReason,
      final DateTime? originalDate,
      final String? notes}) = _$ScheduledDayImpl;

  factory _ScheduledDay.fromJson(Map<String, dynamic> json) =
      _$ScheduledDayImpl.fromJson;

  @override
  DateTime get date;
  @override
  DayStatus get status;
  @override

  /// Template ID if workout day, null if rest
  String? get templateId;
  @override

  /// Workout ID if completed
  String? get workoutId;
  @override

  /// Skip reason if skipped
  String? get skipReason;
  @override

  /// Original date if this is a recovery day
  DateTime? get originalDate;
  @override

  /// Notes for this day
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$ScheduledDayImplCopyWith<_$ScheduledDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecoverySettings _$RecoverySettingsFromJson(Map<String, dynamic> json) {
  return _RecoverySettings.fromJson(json);
}

/// @nodoc
mixin _$RecoverySettings {
  /// Allow automatic recovery suggestions
  bool get suggestRecovery => throw _privateConstructorUsedError;

  /// Allow recovery on rest days
  bool get allowRecoveryOnRestDays => throw _privateConstructorUsedError;

  /// Maximum days to suggest recovery for
  int get maxRecoveryDays => throw _privateConstructorUsedError;

  /// Notify user about skipped workouts
  bool get notifyOnSkip => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecoverySettingsCopyWith<RecoverySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecoverySettingsCopyWith<$Res> {
  factory $RecoverySettingsCopyWith(
          RecoverySettings value, $Res Function(RecoverySettings) then) =
      _$RecoverySettingsCopyWithImpl<$Res, RecoverySettings>;
  @useResult
  $Res call(
      {bool suggestRecovery,
      bool allowRecoveryOnRestDays,
      int maxRecoveryDays,
      bool notifyOnSkip});
}

/// @nodoc
class _$RecoverySettingsCopyWithImpl<$Res, $Val extends RecoverySettings>
    implements $RecoverySettingsCopyWith<$Res> {
  _$RecoverySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestRecovery = null,
    Object? allowRecoveryOnRestDays = null,
    Object? maxRecoveryDays = null,
    Object? notifyOnSkip = null,
  }) {
    return _then(_value.copyWith(
      suggestRecovery: null == suggestRecovery
          ? _value.suggestRecovery
          : suggestRecovery // ignore: cast_nullable_to_non_nullable
              as bool,
      allowRecoveryOnRestDays: null == allowRecoveryOnRestDays
          ? _value.allowRecoveryOnRestDays
          : allowRecoveryOnRestDays // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRecoveryDays: null == maxRecoveryDays
          ? _value.maxRecoveryDays
          : maxRecoveryDays // ignore: cast_nullable_to_non_nullable
              as int,
      notifyOnSkip: null == notifyOnSkip
          ? _value.notifyOnSkip
          : notifyOnSkip // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecoverySettingsImplCopyWith<$Res>
    implements $RecoverySettingsCopyWith<$Res> {
  factory _$$RecoverySettingsImplCopyWith(_$RecoverySettingsImpl value,
          $Res Function(_$RecoverySettingsImpl) then) =
      __$$RecoverySettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool suggestRecovery,
      bool allowRecoveryOnRestDays,
      int maxRecoveryDays,
      bool notifyOnSkip});
}

/// @nodoc
class __$$RecoverySettingsImplCopyWithImpl<$Res>
    extends _$RecoverySettingsCopyWithImpl<$Res, _$RecoverySettingsImpl>
    implements _$$RecoverySettingsImplCopyWith<$Res> {
  __$$RecoverySettingsImplCopyWithImpl(_$RecoverySettingsImpl _value,
      $Res Function(_$RecoverySettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestRecovery = null,
    Object? allowRecoveryOnRestDays = null,
    Object? maxRecoveryDays = null,
    Object? notifyOnSkip = null,
  }) {
    return _then(_$RecoverySettingsImpl(
      suggestRecovery: null == suggestRecovery
          ? _value.suggestRecovery
          : suggestRecovery // ignore: cast_nullable_to_non_nullable
              as bool,
      allowRecoveryOnRestDays: null == allowRecoveryOnRestDays
          ? _value.allowRecoveryOnRestDays
          : allowRecoveryOnRestDays // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRecoveryDays: null == maxRecoveryDays
          ? _value.maxRecoveryDays
          : maxRecoveryDays // ignore: cast_nullable_to_non_nullable
              as int,
      notifyOnSkip: null == notifyOnSkip
          ? _value.notifyOnSkip
          : notifyOnSkip // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecoverySettingsImpl implements _RecoverySettings {
  const _$RecoverySettingsImpl(
      {this.suggestRecovery = true,
      this.allowRecoveryOnRestDays = true,
      this.maxRecoveryDays = 7,
      this.notifyOnSkip = true});

  factory _$RecoverySettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecoverySettingsImplFromJson(json);

  /// Allow automatic recovery suggestions
  @override
  @JsonKey()
  final bool suggestRecovery;

  /// Allow recovery on rest days
  @override
  @JsonKey()
  final bool allowRecoveryOnRestDays;

  /// Maximum days to suggest recovery for
  @override
  @JsonKey()
  final int maxRecoveryDays;

  /// Notify user about skipped workouts
  @override
  @JsonKey()
  final bool notifyOnSkip;

  @override
  String toString() {
    return 'RecoverySettings(suggestRecovery: $suggestRecovery, allowRecoveryOnRestDays: $allowRecoveryOnRestDays, maxRecoveryDays: $maxRecoveryDays, notifyOnSkip: $notifyOnSkip)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecoverySettingsImpl &&
            (identical(other.suggestRecovery, suggestRecovery) ||
                other.suggestRecovery == suggestRecovery) &&
            (identical(
                    other.allowRecoveryOnRestDays, allowRecoveryOnRestDays) ||
                other.allowRecoveryOnRestDays == allowRecoveryOnRestDays) &&
            (identical(other.maxRecoveryDays, maxRecoveryDays) ||
                other.maxRecoveryDays == maxRecoveryDays) &&
            (identical(other.notifyOnSkip, notifyOnSkip) ||
                other.notifyOnSkip == notifyOnSkip));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, suggestRecovery,
      allowRecoveryOnRestDays, maxRecoveryDays, notifyOnSkip);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecoverySettingsImplCopyWith<_$RecoverySettingsImpl> get copyWith =>
      __$$RecoverySettingsImplCopyWithImpl<_$RecoverySettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecoverySettingsImplToJson(
      this,
    );
  }
}

abstract class _RecoverySettings implements RecoverySettings {
  const factory _RecoverySettings(
      {final bool suggestRecovery,
      final bool allowRecoveryOnRestDays,
      final int maxRecoveryDays,
      final bool notifyOnSkip}) = _$RecoverySettingsImpl;

  factory _RecoverySettings.fromJson(Map<String, dynamic> json) =
      _$RecoverySettingsImpl.fromJson;

  @override

  /// Allow automatic recovery suggestions
  bool get suggestRecovery;
  @override

  /// Allow recovery on rest days
  bool get allowRecoveryOnRestDays;
  @override

  /// Maximum days to suggest recovery for
  int get maxRecoveryDays;
  @override

  /// Notify user about skipped workouts
  bool get notifyOnSkip;
  @override
  @JsonKey(ignore: true)
  _$$RecoverySettingsImplCopyWith<_$RecoverySettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FlexibleRoutine _$FlexibleRoutineFromJson(Map<String, dynamic> json) {
  return _FlexibleRoutine.fromJson(json);
}

/// @nodoc
mixin _$FlexibleRoutine {
// === CORE IDENTIFIER ===
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError; // === BASIC INFO ===
  String get name => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // === ROUTINE PERIOD ===
  RoutineType get type => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate =>
      throw _privateConstructorUsedError; // === PATTERN & SCHEDULING ===
  RoutinePattern get pattern => throw _privateConstructorUsedError;

  /// Map of date → scheduled day details
  Map<String, ScheduledDay> get schedule =>
      throw _privateConstructorUsedError; // String key for JSON serialization
// === SKIP & RECOVERY TRACKING ===
  SkipTracker get skipTracker => throw _privateConstructorUsedError;
  RecoverySettings get recoverySettings =>
      throw _privateConstructorUsedError; // === ROUTINE STATE ===
  bool get isActive =>
      throw _privateConstructorUsedError; // Is this the current active routine
  bool get isArchived =>
      throw _privateConstructorUsedError; // Archived routines
  bool get isCompleted =>
      throw _privateConstructorUsedError; // Routine period ended
// === METADATA ===
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // === STATISTICS ===
  int get totalWorkoutDays =>
      throw _privateConstructorUsedError; // Total scheduled workouts in period
  int get completedDays => throw _privateConstructorUsedError; // Days completed
  DateTime? get lastWorkoutDate =>
      throw _privateConstructorUsedError; // Last time user completed a workout
// === SYNC FLAGS ===
  bool get isSyncPending => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FlexibleRoutineCopyWith<FlexibleRoutine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlexibleRoutineCopyWith<$Res> {
  factory $FlexibleRoutineCopyWith(
          FlexibleRoutine value, $Res Function(FlexibleRoutine) then) =
      _$FlexibleRoutineCopyWithImpl<$Res, FlexibleRoutine>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String description,
      RoutineType type,
      DateTime startDate,
      DateTime endDate,
      RoutinePattern pattern,
      Map<String, ScheduledDay> schedule,
      SkipTracker skipTracker,
      RecoverySettings recoverySettings,
      bool isActive,
      bool isArchived,
      bool isCompleted,
      DateTime createdAt,
      DateTime? updatedAt,
      int totalWorkoutDays,
      int completedDays,
      DateTime? lastWorkoutDate,
      bool isSyncPending});

  $RoutinePatternCopyWith<$Res> get pattern;
  $SkipTrackerCopyWith<$Res> get skipTracker;
  $RecoverySettingsCopyWith<$Res> get recoverySettings;
}

/// @nodoc
class _$FlexibleRoutineCopyWithImpl<$Res, $Val extends FlexibleRoutine>
    implements $FlexibleRoutineCopyWith<$Res> {
  _$FlexibleRoutineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? pattern = null,
    Object? schedule = null,
    Object? skipTracker = null,
    Object? recoverySettings = null,
    Object? isActive = null,
    Object? isArchived = null,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? totalWorkoutDays = null,
    Object? completedDays = null,
    Object? lastWorkoutDate = freezed,
    Object? isSyncPending = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoutineType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pattern: null == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as RoutinePattern,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as Map<String, ScheduledDay>,
      skipTracker: null == skipTracker
          ? _value.skipTracker
          : skipTracker // ignore: cast_nullable_to_non_nullable
              as SkipTracker,
      recoverySettings: null == recoverySettings
          ? _value.recoverySettings
          : recoverySettings // ignore: cast_nullable_to_non_nullable
              as RecoverySettings,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalWorkoutDays: null == totalWorkoutDays
          ? _value.totalWorkoutDays
          : totalWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
      completedDays: null == completedDays
          ? _value.completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSyncPending: null == isSyncPending
          ? _value.isSyncPending
          : isSyncPending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RoutinePatternCopyWith<$Res> get pattern {
    return $RoutinePatternCopyWith<$Res>(_value.pattern, (value) {
      return _then(_value.copyWith(pattern: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SkipTrackerCopyWith<$Res> get skipTracker {
    return $SkipTrackerCopyWith<$Res>(_value.skipTracker, (value) {
      return _then(_value.copyWith(skipTracker: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $RecoverySettingsCopyWith<$Res> get recoverySettings {
    return $RecoverySettingsCopyWith<$Res>(_value.recoverySettings, (value) {
      return _then(_value.copyWith(recoverySettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FlexibleRoutineImplCopyWith<$Res>
    implements $FlexibleRoutineCopyWith<$Res> {
  factory _$$FlexibleRoutineImplCopyWith(_$FlexibleRoutineImpl value,
          $Res Function(_$FlexibleRoutineImpl) then) =
      __$$FlexibleRoutineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String description,
      RoutineType type,
      DateTime startDate,
      DateTime endDate,
      RoutinePattern pattern,
      Map<String, ScheduledDay> schedule,
      SkipTracker skipTracker,
      RecoverySettings recoverySettings,
      bool isActive,
      bool isArchived,
      bool isCompleted,
      DateTime createdAt,
      DateTime? updatedAt,
      int totalWorkoutDays,
      int completedDays,
      DateTime? lastWorkoutDate,
      bool isSyncPending});

  @override
  $RoutinePatternCopyWith<$Res> get pattern;
  @override
  $SkipTrackerCopyWith<$Res> get skipTracker;
  @override
  $RecoverySettingsCopyWith<$Res> get recoverySettings;
}

/// @nodoc
class __$$FlexibleRoutineImplCopyWithImpl<$Res>
    extends _$FlexibleRoutineCopyWithImpl<$Res, _$FlexibleRoutineImpl>
    implements _$$FlexibleRoutineImplCopyWith<$Res> {
  __$$FlexibleRoutineImplCopyWithImpl(
      _$FlexibleRoutineImpl _value, $Res Function(_$FlexibleRoutineImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? pattern = null,
    Object? schedule = null,
    Object? skipTracker = null,
    Object? recoverySettings = null,
    Object? isActive = null,
    Object? isArchived = null,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? totalWorkoutDays = null,
    Object? completedDays = null,
    Object? lastWorkoutDate = freezed,
    Object? isSyncPending = null,
  }) {
    return _then(_$FlexibleRoutineImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoutineType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pattern: null == pattern
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as RoutinePattern,
      schedule: null == schedule
          ? _value._schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as Map<String, ScheduledDay>,
      skipTracker: null == skipTracker
          ? _value.skipTracker
          : skipTracker // ignore: cast_nullable_to_non_nullable
              as SkipTracker,
      recoverySettings: null == recoverySettings
          ? _value.recoverySettings
          : recoverySettings // ignore: cast_nullable_to_non_nullable
              as RecoverySettings,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalWorkoutDays: null == totalWorkoutDays
          ? _value.totalWorkoutDays
          : totalWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
      completedDays: null == completedDays
          ? _value.completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isSyncPending: null == isSyncPending
          ? _value.isSyncPending
          : isSyncPending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlexibleRoutineImpl implements _FlexibleRoutine {
  const _$FlexibleRoutineImpl(
      {required this.id,
      required this.userId,
      this.name = 'My Routine',
      this.description = '',
      required this.type,
      required this.startDate,
      required this.endDate,
      required this.pattern,
      required final Map<String, ScheduledDay> schedule,
      required this.skipTracker,
      required this.recoverySettings,
      this.isActive = true,
      this.isArchived = false,
      this.isCompleted = false,
      required this.createdAt,
      this.updatedAt,
      this.totalWorkoutDays = 0,
      this.completedDays = 0,
      this.lastWorkoutDate,
      this.isSyncPending = false})
      : _schedule = schedule;

  factory _$FlexibleRoutineImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlexibleRoutineImplFromJson(json);

// === CORE IDENTIFIER ===
  @override
  final String id;
  @override
  final String userId;
// === BASIC INFO ===
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
// === ROUTINE PERIOD ===
  @override
  final RoutineType type;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
// === PATTERN & SCHEDULING ===
  @override
  final RoutinePattern pattern;

  /// Map of date → scheduled day details
  final Map<String, ScheduledDay> _schedule;

  /// Map of date → scheduled day details
  @override
  Map<String, ScheduledDay> get schedule {
    if (_schedule is EqualUnmodifiableMapView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_schedule);
  }

// String key for JSON serialization
// === SKIP & RECOVERY TRACKING ===
  @override
  final SkipTracker skipTracker;
  @override
  final RecoverySettings recoverySettings;
// === ROUTINE STATE ===
  @override
  @JsonKey()
  final bool isActive;
// Is this the current active routine
  @override
  @JsonKey()
  final bool isArchived;
// Archived routines
  @override
  @JsonKey()
  final bool isCompleted;
// Routine period ended
// === METADATA ===
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// === STATISTICS ===
  @override
  @JsonKey()
  final int totalWorkoutDays;
// Total scheduled workouts in period
  @override
  @JsonKey()
  final int completedDays;
// Days completed
  @override
  final DateTime? lastWorkoutDate;
// Last time user completed a workout
// === SYNC FLAGS ===
  @override
  @JsonKey()
  final bool isSyncPending;

  @override
  String toString() {
    return 'FlexibleRoutine(id: $id, userId: $userId, name: $name, description: $description, type: $type, startDate: $startDate, endDate: $endDate, pattern: $pattern, schedule: $schedule, skipTracker: $skipTracker, recoverySettings: $recoverySettings, isActive: $isActive, isArchived: $isArchived, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt, totalWorkoutDays: $totalWorkoutDays, completedDays: $completedDays, lastWorkoutDate: $lastWorkoutDate, isSyncPending: $isSyncPending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlexibleRoutineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            (identical(other.skipTracker, skipTracker) ||
                other.skipTracker == skipTracker) &&
            (identical(other.recoverySettings, recoverySettings) ||
                other.recoverySettings == recoverySettings) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.totalWorkoutDays, totalWorkoutDays) ||
                other.totalWorkoutDays == totalWorkoutDays) &&
            (identical(other.completedDays, completedDays) ||
                other.completedDays == completedDays) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate) &&
            (identical(other.isSyncPending, isSyncPending) ||
                other.isSyncPending == isSyncPending));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        name,
        description,
        type,
        startDate,
        endDate,
        pattern,
        const DeepCollectionEquality().hash(_schedule),
        skipTracker,
        recoverySettings,
        isActive,
        isArchived,
        isCompleted,
        createdAt,
        updatedAt,
        totalWorkoutDays,
        completedDays,
        lastWorkoutDate,
        isSyncPending
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FlexibleRoutineImplCopyWith<_$FlexibleRoutineImpl> get copyWith =>
      __$$FlexibleRoutineImplCopyWithImpl<_$FlexibleRoutineImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlexibleRoutineImplToJson(
      this,
    );
  }
}

abstract class _FlexibleRoutine implements FlexibleRoutine {
  const factory _FlexibleRoutine(
      {required final String id,
      required final String userId,
      final String name,
      final String description,
      required final RoutineType type,
      required final DateTime startDate,
      required final DateTime endDate,
      required final RoutinePattern pattern,
      required final Map<String, ScheduledDay> schedule,
      required final SkipTracker skipTracker,
      required final RecoverySettings recoverySettings,
      final bool isActive,
      final bool isArchived,
      final bool isCompleted,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final int totalWorkoutDays,
      final int completedDays,
      final DateTime? lastWorkoutDate,
      final bool isSyncPending}) = _$FlexibleRoutineImpl;

  factory _FlexibleRoutine.fromJson(Map<String, dynamic> json) =
      _$FlexibleRoutineImpl.fromJson;

  @override // === CORE IDENTIFIER ===
  String get id;
  @override
  String get userId;
  @override // === BASIC INFO ===
  String get name;
  @override
  String get description;
  @override // === ROUTINE PERIOD ===
  RoutineType get type;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override // === PATTERN & SCHEDULING ===
  RoutinePattern get pattern;
  @override

  /// Map of date → scheduled day details
  Map<String, ScheduledDay> get schedule;
  @override // String key for JSON serialization
// === SKIP & RECOVERY TRACKING ===
  SkipTracker get skipTracker;
  @override
  RecoverySettings get recoverySettings;
  @override // === ROUTINE STATE ===
  bool get isActive;
  @override // Is this the current active routine
  bool get isArchived;
  @override // Archived routines
  bool get isCompleted;
  @override // Routine period ended
// === METADATA ===
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override // === STATISTICS ===
  int get totalWorkoutDays;
  @override // Total scheduled workouts in period
  int get completedDays;
  @override // Days completed
  DateTime? get lastWorkoutDate;
  @override // Last time user completed a workout
// === SYNC FLAGS ===
  bool get isSyncPending;
  @override
  @JsonKey(ignore: true)
  _$$FlexibleRoutineImplCopyWith<_$FlexibleRoutineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
