// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Measurement _$MeasurementFromJson(Map<String, dynamic> json) {
  return _Measurement.fromJson(json);
}

/// @nodoc
mixin _$Measurement {
  /// Unique identifier (UUID v4)
  String get id => throw _privateConstructorUsedError;

  /// User ID (Firebase Auth UID)
  /// GDPR: Required for data isolation and deletion
  String get userId => throw _privateConstructorUsedError;

  /// Type of measurement (weight, body fat, circumference, etc.)
  MetricType get metricType => throw _privateConstructorUsedError;

  /// Numeric value of the measurement
  /// NOTE: Stored encrypted in data layer (AES-256-GCM)
  double get value => throw _privateConstructorUsedError;

  /// Unit of measurement (kg, cm, %, etc.)
  /// Defaults to MetricType.defaultUnit
  String get unit => throw _privateConstructorUsedError;

  /// When the measurement was taken (user's local time)
  /// NOTE: NOT when it was synced to Firestore
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Where the data came from (manual, HealthKit, calculated, etc.)
  MeasurementSource get source => throw _privateConstructorUsedError;

  /// Optional user notes (encrypted in data layer)
  /// Max length: 500 characters
  String? get notes => throw _privateConstructorUsedError;

  /// When this measurement was created in the app
  /// Used for sync conflict resolution (latest wins)
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When this measurement was last modified
  /// Used for sync conflict resolution
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Whether this measurement is marked for deletion
  /// GDPR: Soft-delete with 30-day retention before permanent deletion
  bool get isDeleted => throw _privateConstructorUsedError;

  /// When this measurement was soft-deleted (if isDeleted = true)
  /// After 30 days from this timestamp, data is permanently deleted
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this Measurement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Measurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementCopyWith<Measurement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementCopyWith<$Res> {
  factory $MeasurementCopyWith(
    Measurement value,
    $Res Function(Measurement) then,
  ) = _$MeasurementCopyWithImpl<$Res, Measurement>;
  @useResult
  $Res call({
    String id,
    String userId,
    MetricType metricType,
    double value,
    String unit,
    DateTime timestamp,
    MeasurementSource source,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$MeasurementCopyWithImpl<$Res, $Val extends Measurement>
    implements $MeasurementCopyWith<$Res> {
  _$MeasurementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Measurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? metricType = null,
    Object? value = null,
    Object? unit = null,
    Object? timestamp = null,
    Object? source = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            metricType: null == metricType
                ? _value.metricType
                : metricType // ignore: cast_nullable_to_non_nullable
                      as MetricType,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as MeasurementSource,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementImplCopyWith<$Res>
    implements $MeasurementCopyWith<$Res> {
  factory _$$MeasurementImplCopyWith(
    _$MeasurementImpl value,
    $Res Function(_$MeasurementImpl) then,
  ) = __$$MeasurementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    MetricType metricType,
    double value,
    String unit,
    DateTime timestamp,
    MeasurementSource source,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$MeasurementImplCopyWithImpl<$Res>
    extends _$MeasurementCopyWithImpl<$Res, _$MeasurementImpl>
    implements _$$MeasurementImplCopyWith<$Res> {
  __$$MeasurementImplCopyWithImpl(
    _$MeasurementImpl _value,
    $Res Function(_$MeasurementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Measurement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? metricType = null,
    Object? value = null,
    Object? unit = null,
    Object? timestamp = null,
    Object? source = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$MeasurementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        metricType: null == metricType
            ? _value.metricType
            : metricType // ignore: cast_nullable_to_non_nullable
                  as MetricType,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as MeasurementSource,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MeasurementImpl implements _Measurement {
  const _$MeasurementImpl({
    required this.id,
    required this.userId,
    required this.metricType,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.source,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory _$MeasurementImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeasurementImplFromJson(json);

  /// Unique identifier (UUID v4)
  @override
  final String id;

  /// User ID (Firebase Auth UID)
  /// GDPR: Required for data isolation and deletion
  @override
  final String userId;

  /// Type of measurement (weight, body fat, circumference, etc.)
  @override
  final MetricType metricType;

  /// Numeric value of the measurement
  /// NOTE: Stored encrypted in data layer (AES-256-GCM)
  @override
  final double value;

  /// Unit of measurement (kg, cm, %, etc.)
  /// Defaults to MetricType.defaultUnit
  @override
  final String unit;

  /// When the measurement was taken (user's local time)
  /// NOTE: NOT when it was synced to Firestore
  @override
  final DateTime timestamp;

  /// Where the data came from (manual, HealthKit, calculated, etc.)
  @override
  final MeasurementSource source;

  /// Optional user notes (encrypted in data layer)
  /// Max length: 500 characters
  @override
  final String? notes;

  /// When this measurement was created in the app
  /// Used for sync conflict resolution (latest wins)
  @override
  final DateTime? createdAt;

  /// When this measurement was last modified
  /// Used for sync conflict resolution
  @override
  final DateTime? updatedAt;

  /// Whether this measurement is marked for deletion
  /// GDPR: Soft-delete with 30-day retention before permanent deletion
  @override
  @JsonKey()
  final bool isDeleted;

  /// When this measurement was soft-deleted (if isDeleted = true)
  /// After 30 days from this timestamp, data is permanently deleted
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'Measurement(id: $id, userId: $userId, metricType: $metricType, value: $value, unit: $unit, timestamp: $timestamp, source: $source, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.metricType, metricType) ||
                other.metricType == metricType) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    metricType,
    value,
    unit,
    timestamp,
    source,
    notes,
    createdAt,
    updatedAt,
    isDeleted,
    deletedAt,
  );

  /// Create a copy of Measurement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementImplCopyWith<_$MeasurementImpl> get copyWith =>
      __$$MeasurementImplCopyWithImpl<_$MeasurementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeasurementImplToJson(this);
  }
}

abstract class _Measurement implements Measurement {
  const factory _Measurement({
    required final String id,
    required final String userId,
    required final MetricType metricType,
    required final double value,
    required final String unit,
    required final DateTime timestamp,
    required final MeasurementSource source,
    final String? notes,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final bool isDeleted,
    final DateTime? deletedAt,
  }) = _$MeasurementImpl;

  factory _Measurement.fromJson(Map<String, dynamic> json) =
      _$MeasurementImpl.fromJson;

  /// Unique identifier (UUID v4)
  @override
  String get id;

  /// User ID (Firebase Auth UID)
  /// GDPR: Required for data isolation and deletion
  @override
  String get userId;

  /// Type of measurement (weight, body fat, circumference, etc.)
  @override
  MetricType get metricType;

  /// Numeric value of the measurement
  /// NOTE: Stored encrypted in data layer (AES-256-GCM)
  @override
  double get value;

  /// Unit of measurement (kg, cm, %, etc.)
  /// Defaults to MetricType.defaultUnit
  @override
  String get unit;

  /// When the measurement was taken (user's local time)
  /// NOTE: NOT when it was synced to Firestore
  @override
  DateTime get timestamp;

  /// Where the data came from (manual, HealthKit, calculated, etc.)
  @override
  MeasurementSource get source;

  /// Optional user notes (encrypted in data layer)
  /// Max length: 500 characters
  @override
  String? get notes;

  /// When this measurement was created in the app
  /// Used for sync conflict resolution (latest wins)
  @override
  DateTime? get createdAt;

  /// When this measurement was last modified
  /// Used for sync conflict resolution
  @override
  DateTime? get updatedAt;

  /// Whether this measurement is marked for deletion
  /// GDPR: Soft-delete with 30-day retention before permanent deletion
  @override
  bool get isDeleted;

  /// When this measurement was soft-deleted (if isDeleted = true)
  /// After 30 days from this timestamp, data is permanently deleted
  @override
  DateTime? get deletedAt;

  /// Create a copy of Measurement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementImplCopyWith<_$MeasurementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeasurementMetadata _$MeasurementMetadataFromJson(Map<String, dynamic> json) {
  return _MeasurementMetadata.fromJson(json);
}

/// @nodoc
mixin _$MeasurementMetadata {
  /// Device info (anonymized)
  /// Example: "iOS 17.2, iPhone 14 Pro"
  String? get deviceInfo => throw _privateConstructorUsedError;

  /// App version when measurement was created
  /// Example: "1.0.0+49"
  String? get appVersion => throw _privateConstructorUsedError;

  /// Sync status (pending, synced, conflict)
  SyncStatus get syncStatus => throw _privateConstructorUsedError;

  /// Last sync attempt timestamp
  DateTime? get lastSyncAttempt => throw _privateConstructorUsedError;

  /// Sync error message (if sync failed)
  String? get syncError => throw _privateConstructorUsedError;

  /// Whether this measurement was validated
  bool get isValidated => throw _privateConstructorUsedError;

  /// Validation errors (if any)
  List<String>? get validationErrors => throw _privateConstructorUsedError;

  /// Serializes this MeasurementMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementMetadataCopyWith<MeasurementMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementMetadataCopyWith<$Res> {
  factory $MeasurementMetadataCopyWith(
    MeasurementMetadata value,
    $Res Function(MeasurementMetadata) then,
  ) = _$MeasurementMetadataCopyWithImpl<$Res, MeasurementMetadata>;
  @useResult
  $Res call({
    String? deviceInfo,
    String? appVersion,
    SyncStatus syncStatus,
    DateTime? lastSyncAttempt,
    String? syncError,
    bool isValidated,
    List<String>? validationErrors,
  });
}

/// @nodoc
class _$MeasurementMetadataCopyWithImpl<$Res, $Val extends MeasurementMetadata>
    implements $MeasurementMetadataCopyWith<$Res> {
  _$MeasurementMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceInfo = freezed,
    Object? appVersion = freezed,
    Object? syncStatus = null,
    Object? lastSyncAttempt = freezed,
    Object? syncError = freezed,
    Object? isValidated = null,
    Object? validationErrors = freezed,
  }) {
    return _then(
      _value.copyWith(
            deviceInfo: freezed == deviceInfo
                ? _value.deviceInfo
                : deviceInfo // ignore: cast_nullable_to_non_nullable
                      as String?,
            appVersion: freezed == appVersion
                ? _value.appVersion
                : appVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            syncStatus: null == syncStatus
                ? _value.syncStatus
                : syncStatus // ignore: cast_nullable_to_non_nullable
                      as SyncStatus,
            lastSyncAttempt: freezed == lastSyncAttempt
                ? _value.lastSyncAttempt
                : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            syncError: freezed == syncError
                ? _value.syncError
                : syncError // ignore: cast_nullable_to_non_nullable
                      as String?,
            isValidated: null == isValidated
                ? _value.isValidated
                : isValidated // ignore: cast_nullable_to_non_nullable
                      as bool,
            validationErrors: freezed == validationErrors
                ? _value.validationErrors
                : validationErrors // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementMetadataImplCopyWith<$Res>
    implements $MeasurementMetadataCopyWith<$Res> {
  factory _$$MeasurementMetadataImplCopyWith(
    _$MeasurementMetadataImpl value,
    $Res Function(_$MeasurementMetadataImpl) then,
  ) = __$$MeasurementMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? deviceInfo,
    String? appVersion,
    SyncStatus syncStatus,
    DateTime? lastSyncAttempt,
    String? syncError,
    bool isValidated,
    List<String>? validationErrors,
  });
}

/// @nodoc
class __$$MeasurementMetadataImplCopyWithImpl<$Res>
    extends _$MeasurementMetadataCopyWithImpl<$Res, _$MeasurementMetadataImpl>
    implements _$$MeasurementMetadataImplCopyWith<$Res> {
  __$$MeasurementMetadataImplCopyWithImpl(
    _$MeasurementMetadataImpl _value,
    $Res Function(_$MeasurementMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceInfo = freezed,
    Object? appVersion = freezed,
    Object? syncStatus = null,
    Object? lastSyncAttempt = freezed,
    Object? syncError = freezed,
    Object? isValidated = null,
    Object? validationErrors = freezed,
  }) {
    return _then(
      _$MeasurementMetadataImpl(
        deviceInfo: freezed == deviceInfo
            ? _value.deviceInfo
            : deviceInfo // ignore: cast_nullable_to_non_nullable
                  as String?,
        appVersion: freezed == appVersion
            ? _value.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        syncStatus: null == syncStatus
            ? _value.syncStatus
            : syncStatus // ignore: cast_nullable_to_non_nullable
                  as SyncStatus,
        lastSyncAttempt: freezed == lastSyncAttempt
            ? _value.lastSyncAttempt
            : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        syncError: freezed == syncError
            ? _value.syncError
            : syncError // ignore: cast_nullable_to_non_nullable
                  as String?,
        isValidated: null == isValidated
            ? _value.isValidated
            : isValidated // ignore: cast_nullable_to_non_nullable
                  as bool,
        validationErrors: freezed == validationErrors
            ? _value._validationErrors
            : validationErrors // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MeasurementMetadataImpl implements _MeasurementMetadata {
  const _$MeasurementMetadataImpl({
    this.deviceInfo,
    this.appVersion,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncAttempt,
    this.syncError,
    this.isValidated = false,
    final List<String>? validationErrors,
  }) : _validationErrors = validationErrors;

  factory _$MeasurementMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeasurementMetadataImplFromJson(json);

  /// Device info (anonymized)
  /// Example: "iOS 17.2, iPhone 14 Pro"
  @override
  final String? deviceInfo;

  /// App version when measurement was created
  /// Example: "1.0.0+49"
  @override
  final String? appVersion;

  /// Sync status (pending, synced, conflict)
  @override
  @JsonKey()
  final SyncStatus syncStatus;

  /// Last sync attempt timestamp
  @override
  final DateTime? lastSyncAttempt;

  /// Sync error message (if sync failed)
  @override
  final String? syncError;

  /// Whether this measurement was validated
  @override
  @JsonKey()
  final bool isValidated;

  /// Validation errors (if any)
  final List<String>? _validationErrors;

  /// Validation errors (if any)
  @override
  List<String>? get validationErrors {
    final value = _validationErrors;
    if (value == null) return null;
    if (_validationErrors is EqualUnmodifiableListView)
      return _validationErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MeasurementMetadata(deviceInfo: $deviceInfo, appVersion: $appVersion, syncStatus: $syncStatus, lastSyncAttempt: $lastSyncAttempt, syncError: $syncError, isValidated: $isValidated, validationErrors: $validationErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementMetadataImpl &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.lastSyncAttempt, lastSyncAttempt) ||
                other.lastSyncAttempt == lastSyncAttempt) &&
            (identical(other.syncError, syncError) ||
                other.syncError == syncError) &&
            (identical(other.isValidated, isValidated) ||
                other.isValidated == isValidated) &&
            const DeepCollectionEquality().equals(
              other._validationErrors,
              _validationErrors,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deviceInfo,
    appVersion,
    syncStatus,
    lastSyncAttempt,
    syncError,
    isValidated,
    const DeepCollectionEquality().hash(_validationErrors),
  );

  /// Create a copy of MeasurementMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementMetadataImplCopyWith<_$MeasurementMetadataImpl> get copyWith =>
      __$$MeasurementMetadataImplCopyWithImpl<_$MeasurementMetadataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MeasurementMetadataImplToJson(this);
  }
}

abstract class _MeasurementMetadata implements MeasurementMetadata {
  const factory _MeasurementMetadata({
    final String? deviceInfo,
    final String? appVersion,
    final SyncStatus syncStatus,
    final DateTime? lastSyncAttempt,
    final String? syncError,
    final bool isValidated,
    final List<String>? validationErrors,
  }) = _$MeasurementMetadataImpl;

  factory _MeasurementMetadata.fromJson(Map<String, dynamic> json) =
      _$MeasurementMetadataImpl.fromJson;

  /// Device info (anonymized)
  /// Example: "iOS 17.2, iPhone 14 Pro"
  @override
  String? get deviceInfo;

  /// App version when measurement was created
  /// Example: "1.0.0+49"
  @override
  String? get appVersion;

  /// Sync status (pending, synced, conflict)
  @override
  SyncStatus get syncStatus;

  /// Last sync attempt timestamp
  @override
  DateTime? get lastSyncAttempt;

  /// Sync error message (if sync failed)
  @override
  String? get syncError;

  /// Whether this measurement was validated
  @override
  bool get isValidated;

  /// Validation errors (if any)
  @override
  List<String>? get validationErrors;

  /// Create a copy of MeasurementMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementMetadataImplCopyWith<_$MeasurementMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
