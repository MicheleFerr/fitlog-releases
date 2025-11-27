// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationRecord _$NotificationRecordFromJson(Map<String, dynamic> json) {
  return _NotificationRecord.fromJson(json);
}

/// @nodoc
mixin _$NotificationRecord {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// Type of notification sent
  NotificationType get type => throw _privateConstructorUsedError;

  /// When the notification was scheduled/sent
  DateTime get sentAt => throw _privateConstructorUsedError;

  /// When the notification was opened (null if not opened)
  DateTime? get openedAt => throw _privateConstructorUsedError;

  /// The message that was sent (for rotation tracking)
  String get messageKey => throw _privateConstructorUsedError;

  /// Additional context (e.g., exercise name for PR)
  String? get context => throw _privateConstructorUsedError;

  /// For inactivity: which day in sequence (3, 7, or 14)
  int? get inactivityDay => throw _privateConstructorUsedError;

  /// Whether this notification was canceled before delivery
  bool get wasCanceled => throw _privateConstructorUsedError;

  /// Serializes this NotificationRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationRecordCopyWith<NotificationRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationRecordCopyWith<$Res> {
  factory $NotificationRecordCopyWith(
    NotificationRecord value,
    $Res Function(NotificationRecord) then,
  ) = _$NotificationRecordCopyWithImpl<$Res, NotificationRecord>;
  @useResult
  $Res call({
    String id,
    NotificationType type,
    DateTime sentAt,
    DateTime? openedAt,
    String messageKey,
    String? context,
    int? inactivityDay,
    bool wasCanceled,
  });
}

/// @nodoc
class _$NotificationRecordCopyWithImpl<$Res, $Val extends NotificationRecord>
    implements $NotificationRecordCopyWith<$Res> {
  _$NotificationRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? sentAt = null,
    Object? openedAt = freezed,
    Object? messageKey = null,
    Object? context = freezed,
    Object? inactivityDay = freezed,
    Object? wasCanceled = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            sentAt: null == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            openedAt: freezed == openedAt
                ? _value.openedAt
                : openedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            messageKey: null == messageKey
                ? _value.messageKey
                : messageKey // ignore: cast_nullable_to_non_nullable
                      as String,
            context: freezed == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as String?,
            inactivityDay: freezed == inactivityDay
                ? _value.inactivityDay
                : inactivityDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            wasCanceled: null == wasCanceled
                ? _value.wasCanceled
                : wasCanceled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationRecordImplCopyWith<$Res>
    implements $NotificationRecordCopyWith<$Res> {
  factory _$$NotificationRecordImplCopyWith(
    _$NotificationRecordImpl value,
    $Res Function(_$NotificationRecordImpl) then,
  ) = __$$NotificationRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    NotificationType type,
    DateTime sentAt,
    DateTime? openedAt,
    String messageKey,
    String? context,
    int? inactivityDay,
    bool wasCanceled,
  });
}

/// @nodoc
class __$$NotificationRecordImplCopyWithImpl<$Res>
    extends _$NotificationRecordCopyWithImpl<$Res, _$NotificationRecordImpl>
    implements _$$NotificationRecordImplCopyWith<$Res> {
  __$$NotificationRecordImplCopyWithImpl(
    _$NotificationRecordImpl _value,
    $Res Function(_$NotificationRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? sentAt = null,
    Object? openedAt = freezed,
    Object? messageKey = null,
    Object? context = freezed,
    Object? inactivityDay = freezed,
    Object? wasCanceled = null,
  }) {
    return _then(
      _$NotificationRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        sentAt: null == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        openedAt: freezed == openedAt
            ? _value.openedAt
            : openedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        messageKey: null == messageKey
            ? _value.messageKey
            : messageKey // ignore: cast_nullable_to_non_nullable
                  as String,
        context: freezed == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as String?,
        inactivityDay: freezed == inactivityDay
            ? _value.inactivityDay
            : inactivityDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        wasCanceled: null == wasCanceled
            ? _value.wasCanceled
            : wasCanceled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationRecordImpl extends _NotificationRecord {
  const _$NotificationRecordImpl({
    required this.id,
    required this.type,
    required this.sentAt,
    this.openedAt,
    required this.messageKey,
    this.context,
    this.inactivityDay,
    this.wasCanceled = false,
  }) : super._();

  factory _$NotificationRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationRecordImplFromJson(json);

  /// Unique identifier
  @override
  final String id;

  /// Type of notification sent
  @override
  final NotificationType type;

  /// When the notification was scheduled/sent
  @override
  final DateTime sentAt;

  /// When the notification was opened (null if not opened)
  @override
  final DateTime? openedAt;

  /// The message that was sent (for rotation tracking)
  @override
  final String messageKey;

  /// Additional context (e.g., exercise name for PR)
  @override
  final String? context;

  /// For inactivity: which day in sequence (3, 7, or 14)
  @override
  final int? inactivityDay;

  /// Whether this notification was canceled before delivery
  @override
  @JsonKey()
  final bool wasCanceled;

  @override
  String toString() {
    return 'NotificationRecord(id: $id, type: $type, sentAt: $sentAt, openedAt: $openedAt, messageKey: $messageKey, context: $context, inactivityDay: $inactivityDay, wasCanceled: $wasCanceled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.messageKey, messageKey) ||
                other.messageKey == messageKey) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.inactivityDay, inactivityDay) ||
                other.inactivityDay == inactivityDay) &&
            (identical(other.wasCanceled, wasCanceled) ||
                other.wasCanceled == wasCanceled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    sentAt,
    openedAt,
    messageKey,
    context,
    inactivityDay,
    wasCanceled,
  );

  /// Create a copy of NotificationRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationRecordImplCopyWith<_$NotificationRecordImpl> get copyWith =>
      __$$NotificationRecordImplCopyWithImpl<_$NotificationRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationRecordImplToJson(this);
  }
}

abstract class _NotificationRecord extends NotificationRecord {
  const factory _NotificationRecord({
    required final String id,
    required final NotificationType type,
    required final DateTime sentAt,
    final DateTime? openedAt,
    required final String messageKey,
    final String? context,
    final int? inactivityDay,
    final bool wasCanceled,
  }) = _$NotificationRecordImpl;
  const _NotificationRecord._() : super._();

  factory _NotificationRecord.fromJson(Map<String, dynamic> json) =
      _$NotificationRecordImpl.fromJson;

  /// Unique identifier
  @override
  String get id;

  /// Type of notification sent
  @override
  NotificationType get type;

  /// When the notification was scheduled/sent
  @override
  DateTime get sentAt;

  /// When the notification was opened (null if not opened)
  @override
  DateTime? get openedAt;

  /// The message that was sent (for rotation tracking)
  @override
  String get messageKey;

  /// Additional context (e.g., exercise name for PR)
  @override
  String? get context;

  /// For inactivity: which day in sequence (3, 7, or 14)
  @override
  int? get inactivityDay;

  /// Whether this notification was canceled before delivery
  @override
  bool get wasCanceled;

  /// Create a copy of NotificationRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationRecordImplCopyWith<_$NotificationRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationStats _$NotificationStatsFromJson(Map<String, dynamic> json) {
  return _NotificationStats.fromJson(json);
}

/// @nodoc
mixin _$NotificationStats {
  /// Total notifications sent
  int get totalSent => throw _privateConstructorUsedError;

  /// How many were opened
  int get totalOpened => throw _privateConstructorUsedError;

  /// How many consecutive ignores (for stop-after-ignore logic)
  int get consecutiveIgnores => throw _privateConstructorUsedError;

  /// Last notification sent timestamp
  DateTime? get lastSentAt => throw _privateConstructorUsedError;

  /// Last message key used (for rotation)
  String? get lastMessageKey => throw _privateConstructorUsedError;

  /// Serializes this NotificationStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationStatsCopyWith<NotificationStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationStatsCopyWith<$Res> {
  factory $NotificationStatsCopyWith(
    NotificationStats value,
    $Res Function(NotificationStats) then,
  ) = _$NotificationStatsCopyWithImpl<$Res, NotificationStats>;
  @useResult
  $Res call({
    int totalSent,
    int totalOpened,
    int consecutiveIgnores,
    DateTime? lastSentAt,
    String? lastMessageKey,
  });
}

/// @nodoc
class _$NotificationStatsCopyWithImpl<$Res, $Val extends NotificationStats>
    implements $NotificationStatsCopyWith<$Res> {
  _$NotificationStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSent = null,
    Object? totalOpened = null,
    Object? consecutiveIgnores = null,
    Object? lastSentAt = freezed,
    Object? lastMessageKey = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalSent: null == totalSent
                ? _value.totalSent
                : totalSent // ignore: cast_nullable_to_non_nullable
                      as int,
            totalOpened: null == totalOpened
                ? _value.totalOpened
                : totalOpened // ignore: cast_nullable_to_non_nullable
                      as int,
            consecutiveIgnores: null == consecutiveIgnores
                ? _value.consecutiveIgnores
                : consecutiveIgnores // ignore: cast_nullable_to_non_nullable
                      as int,
            lastSentAt: freezed == lastSentAt
                ? _value.lastSentAt
                : lastSentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastMessageKey: freezed == lastMessageKey
                ? _value.lastMessageKey
                : lastMessageKey // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationStatsImplCopyWith<$Res>
    implements $NotificationStatsCopyWith<$Res> {
  factory _$$NotificationStatsImplCopyWith(
    _$NotificationStatsImpl value,
    $Res Function(_$NotificationStatsImpl) then,
  ) = __$$NotificationStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalSent,
    int totalOpened,
    int consecutiveIgnores,
    DateTime? lastSentAt,
    String? lastMessageKey,
  });
}

/// @nodoc
class __$$NotificationStatsImplCopyWithImpl<$Res>
    extends _$NotificationStatsCopyWithImpl<$Res, _$NotificationStatsImpl>
    implements _$$NotificationStatsImplCopyWith<$Res> {
  __$$NotificationStatsImplCopyWithImpl(
    _$NotificationStatsImpl _value,
    $Res Function(_$NotificationStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSent = null,
    Object? totalOpened = null,
    Object? consecutiveIgnores = null,
    Object? lastSentAt = freezed,
    Object? lastMessageKey = freezed,
  }) {
    return _then(
      _$NotificationStatsImpl(
        totalSent: null == totalSent
            ? _value.totalSent
            : totalSent // ignore: cast_nullable_to_non_nullable
                  as int,
        totalOpened: null == totalOpened
            ? _value.totalOpened
            : totalOpened // ignore: cast_nullable_to_non_nullable
                  as int,
        consecutiveIgnores: null == consecutiveIgnores
            ? _value.consecutiveIgnores
            : consecutiveIgnores // ignore: cast_nullable_to_non_nullable
                  as int,
        lastSentAt: freezed == lastSentAt
            ? _value.lastSentAt
            : lastSentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastMessageKey: freezed == lastMessageKey
            ? _value.lastMessageKey
            : lastMessageKey // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationStatsImpl extends _NotificationStats {
  const _$NotificationStatsImpl({
    required this.totalSent,
    required this.totalOpened,
    required this.consecutiveIgnores,
    this.lastSentAt,
    this.lastMessageKey,
  }) : super._();

  factory _$NotificationStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationStatsImplFromJson(json);

  /// Total notifications sent
  @override
  final int totalSent;

  /// How many were opened
  @override
  final int totalOpened;

  /// How many consecutive ignores (for stop-after-ignore logic)
  @override
  final int consecutiveIgnores;

  /// Last notification sent timestamp
  @override
  final DateTime? lastSentAt;

  /// Last message key used (for rotation)
  @override
  final String? lastMessageKey;

  @override
  String toString() {
    return 'NotificationStats(totalSent: $totalSent, totalOpened: $totalOpened, consecutiveIgnores: $consecutiveIgnores, lastSentAt: $lastSentAt, lastMessageKey: $lastMessageKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationStatsImpl &&
            (identical(other.totalSent, totalSent) ||
                other.totalSent == totalSent) &&
            (identical(other.totalOpened, totalOpened) ||
                other.totalOpened == totalOpened) &&
            (identical(other.consecutiveIgnores, consecutiveIgnores) ||
                other.consecutiveIgnores == consecutiveIgnores) &&
            (identical(other.lastSentAt, lastSentAt) ||
                other.lastSentAt == lastSentAt) &&
            (identical(other.lastMessageKey, lastMessageKey) ||
                other.lastMessageKey == lastMessageKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalSent,
    totalOpened,
    consecutiveIgnores,
    lastSentAt,
    lastMessageKey,
  );

  /// Create a copy of NotificationStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationStatsImplCopyWith<_$NotificationStatsImpl> get copyWith =>
      __$$NotificationStatsImplCopyWithImpl<_$NotificationStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationStatsImplToJson(this);
  }
}

abstract class _NotificationStats extends NotificationStats {
  const factory _NotificationStats({
    required final int totalSent,
    required final int totalOpened,
    required final int consecutiveIgnores,
    final DateTime? lastSentAt,
    final String? lastMessageKey,
  }) = _$NotificationStatsImpl;
  const _NotificationStats._() : super._();

  factory _NotificationStats.fromJson(Map<String, dynamic> json) =
      _$NotificationStatsImpl.fromJson;

  /// Total notifications sent
  @override
  int get totalSent;

  /// How many were opened
  @override
  int get totalOpened;

  /// How many consecutive ignores (for stop-after-ignore logic)
  @override
  int get consecutiveIgnores;

  /// Last notification sent timestamp
  @override
  DateTime? get lastSentAt;

  /// Last message key used (for rotation)
  @override
  String? get lastMessageKey;

  /// Create a copy of NotificationStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationStatsImplCopyWith<_$NotificationStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
