// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queued_sync.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QueuedSync _$QueuedSyncFromJson(Map<String, dynamic> json) {
  return _QueuedSync.fromJson(json);
}

/// @nodoc
mixin _$QueuedSync {
  /// Unique ID for this sync attempt
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;

  /// Timestamp when sync failed
  @HiveField(1)
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Health metrics that failed to sync
  @HiveField(2)
  Map<String, dynamic> get healthMetrics => throw _privateConstructorUsedError;

  /// Error message (for logging)
  @HiveField(3)
  String get error => throw _privateConstructorUsedError;

  /// Number of retry attempts (0 = first attempt)
  @HiveField(4)
  int get retryCount => throw _privateConstructorUsedError;

  /// Is this sync retryable (false for rate limit, quota errors)
  @HiveField(5)
  bool get retryable => throw _privateConstructorUsedError;

  /// Next retry time (calculated with exponential backoff)
  @HiveField(6)
  DateTime? get nextRetryAt => throw _privateConstructorUsedError;

  /// Serializes this QueuedSync to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QueuedSyncCopyWith<QueuedSync> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueuedSyncCopyWith<$Res> {
  factory $QueuedSyncCopyWith(
    QueuedSync value,
    $Res Function(QueuedSync) then,
  ) = _$QueuedSyncCopyWithImpl<$Res, QueuedSync>;
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) DateTime timestamp,
    @HiveField(2) Map<String, dynamic> healthMetrics,
    @HiveField(3) String error,
    @HiveField(4) int retryCount,
    @HiveField(5) bool retryable,
    @HiveField(6) DateTime? nextRetryAt,
  });
}

/// @nodoc
class _$QueuedSyncCopyWithImpl<$Res, $Val extends QueuedSync>
    implements $QueuedSyncCopyWith<$Res> {
  _$QueuedSyncCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? healthMetrics = null,
    Object? error = null,
    Object? retryCount = null,
    Object? retryable = null,
    Object? nextRetryAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            healthMetrics: null == healthMetrics
                ? _value.healthMetrics
                : healthMetrics // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            error: null == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String,
            retryCount: null == retryCount
                ? _value.retryCount
                : retryCount // ignore: cast_nullable_to_non_nullable
                      as int,
            retryable: null == retryable
                ? _value.retryable
                : retryable // ignore: cast_nullable_to_non_nullable
                      as bool,
            nextRetryAt: freezed == nextRetryAt
                ? _value.nextRetryAt
                : nextRetryAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QueuedSyncImplCopyWith<$Res>
    implements $QueuedSyncCopyWith<$Res> {
  factory _$$QueuedSyncImplCopyWith(
    _$QueuedSyncImpl value,
    $Res Function(_$QueuedSyncImpl) then,
  ) = __$$QueuedSyncImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) DateTime timestamp,
    @HiveField(2) Map<String, dynamic> healthMetrics,
    @HiveField(3) String error,
    @HiveField(4) int retryCount,
    @HiveField(5) bool retryable,
    @HiveField(6) DateTime? nextRetryAt,
  });
}

/// @nodoc
class __$$QueuedSyncImplCopyWithImpl<$Res>
    extends _$QueuedSyncCopyWithImpl<$Res, _$QueuedSyncImpl>
    implements _$$QueuedSyncImplCopyWith<$Res> {
  __$$QueuedSyncImplCopyWithImpl(
    _$QueuedSyncImpl _value,
    $Res Function(_$QueuedSyncImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? healthMetrics = null,
    Object? error = null,
    Object? retryCount = null,
    Object? retryable = null,
    Object? nextRetryAt = freezed,
  }) {
    return _then(
      _$QueuedSyncImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        healthMetrics: null == healthMetrics
            ? _value._healthMetrics
            : healthMetrics // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        error: null == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String,
        retryCount: null == retryCount
            ? _value.retryCount
            : retryCount // ignore: cast_nullable_to_non_nullable
                  as int,
        retryable: null == retryable
            ? _value.retryable
            : retryable // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextRetryAt: freezed == nextRetryAt
            ? _value.nextRetryAt
            : nextRetryAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QueuedSyncImpl implements _QueuedSync {
  const _$QueuedSyncImpl({
    @HiveField(0) required this.id,
    @HiveField(1) required this.timestamp,
    @HiveField(2) required final Map<String, dynamic> healthMetrics,
    @HiveField(3) required this.error,
    @HiveField(4) this.retryCount = 0,
    @HiveField(5) this.retryable = true,
    @HiveField(6) this.nextRetryAt,
  }) : _healthMetrics = healthMetrics;

  factory _$QueuedSyncImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueuedSyncImplFromJson(json);

  /// Unique ID for this sync attempt
  @override
  @HiveField(0)
  final String id;

  /// Timestamp when sync failed
  @override
  @HiveField(1)
  final DateTime timestamp;

  /// Health metrics that failed to sync
  final Map<String, dynamic> _healthMetrics;

  /// Health metrics that failed to sync
  @override
  @HiveField(2)
  Map<String, dynamic> get healthMetrics {
    if (_healthMetrics is EqualUnmodifiableMapView) return _healthMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_healthMetrics);
  }

  /// Error message (for logging)
  @override
  @HiveField(3)
  final String error;

  /// Number of retry attempts (0 = first attempt)
  @override
  @JsonKey()
  @HiveField(4)
  final int retryCount;

  /// Is this sync retryable (false for rate limit, quota errors)
  @override
  @JsonKey()
  @HiveField(5)
  final bool retryable;

  /// Next retry time (calculated with exponential backoff)
  @override
  @HiveField(6)
  final DateTime? nextRetryAt;

  @override
  String toString() {
    return 'QueuedSync(id: $id, timestamp: $timestamp, healthMetrics: $healthMetrics, error: $error, retryCount: $retryCount, retryable: $retryable, nextRetryAt: $nextRetryAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueuedSyncImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(
              other._healthMetrics,
              _healthMetrics,
            ) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.retryable, retryable) ||
                other.retryable == retryable) &&
            (identical(other.nextRetryAt, nextRetryAt) ||
                other.nextRetryAt == nextRetryAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    timestamp,
    const DeepCollectionEquality().hash(_healthMetrics),
    error,
    retryCount,
    retryable,
    nextRetryAt,
  );

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QueuedSyncImplCopyWith<_$QueuedSyncImpl> get copyWith =>
      __$$QueuedSyncImplCopyWithImpl<_$QueuedSyncImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueuedSyncImplToJson(this);
  }
}

abstract class _QueuedSync implements QueuedSync {
  const factory _QueuedSync({
    @HiveField(0) required final String id,
    @HiveField(1) required final DateTime timestamp,
    @HiveField(2) required final Map<String, dynamic> healthMetrics,
    @HiveField(3) required final String error,
    @HiveField(4) final int retryCount,
    @HiveField(5) final bool retryable,
    @HiveField(6) final DateTime? nextRetryAt,
  }) = _$QueuedSyncImpl;

  factory _QueuedSync.fromJson(Map<String, dynamic> json) =
      _$QueuedSyncImpl.fromJson;

  /// Unique ID for this sync attempt
  @override
  @HiveField(0)
  String get id;

  /// Timestamp when sync failed
  @override
  @HiveField(1)
  DateTime get timestamp;

  /// Health metrics that failed to sync
  @override
  @HiveField(2)
  Map<String, dynamic> get healthMetrics;

  /// Error message (for logging)
  @override
  @HiveField(3)
  String get error;

  /// Number of retry attempts (0 = first attempt)
  @override
  @HiveField(4)
  int get retryCount;

  /// Is this sync retryable (false for rate limit, quota errors)
  @override
  @HiveField(5)
  bool get retryable;

  /// Next retry time (calculated with exponential backoff)
  @override
  @HiveField(6)
  DateTime? get nextRetryAt;

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QueuedSyncImplCopyWith<_$QueuedSyncImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
