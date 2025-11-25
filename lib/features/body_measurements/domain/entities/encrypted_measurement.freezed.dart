// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EncryptedMeasurement _$EncryptedMeasurementFromJson(Map<String, dynamic> json) {
  return _EncryptedMeasurement.fromJson(json);
}

/// @nodoc
mixin _$EncryptedMeasurement {
  /// Measurement ID (same as original Measurement.id)
  String get id => throw _privateConstructorUsedError;

  /// User ID (Firebase Auth UID)
  String get userId => throw _privateConstructorUsedError;

  /// Metric type (stored unencrypted for querying)
  ///
  /// **Note**: MetricType is NOT sensitive PII, safe to store unencrypted.
  /// Allows efficient Firestore queries: "Get all weight measurements"
  String get metricType => throw _privateConstructorUsedError;

  /// Encrypted measurement data (base64 encoded)
  ///
  /// **Contains**: Measurement JSON serialized → encrypted → base64
  /// ```json
  /// {
  ///   "value": 75.5,
  ///   "unit": "kg",
  ///   "notes": "Morning weight after workout",
  ///   "source": "manual"
  /// }
  /// ```
  String get encryptedData => throw _privateConstructorUsedError;

  /// Initialization Vector (base64 encoded)
  ///
  /// **IV**: Randomly generated 12 bytes for AES-GCM.
  /// Must be unique per encryption operation (never reuse with same key).
  String get iv => throw _privateConstructorUsedError;

  /// Authentication tag (base64 encoded)
  ///
  /// **Tag**: 16-byte GCM tag for data integrity verification.
  /// Prevents tampering (decryption fails if data modified).
  String get tag => throw _privateConstructorUsedError;

  /// Timestamp (stored unencrypted for sorting/filtering)
  ///
  /// **Note**: Timestamp is NOT sensitive PII, safe to store unencrypted.
  /// Allows efficient queries: "Get measurements from last 30 days"
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// When this encrypted measurement was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When this encrypted measurement was last updated
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EncryptedMeasurementCopyWith<EncryptedMeasurement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EncryptedMeasurementCopyWith<$Res> {
  factory $EncryptedMeasurementCopyWith(EncryptedMeasurement value,
          $Res Function(EncryptedMeasurement) then) =
      _$EncryptedMeasurementCopyWithImpl<$Res, EncryptedMeasurement>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String metricType,
      String encryptedData,
      String iv,
      String tag,
      DateTime timestamp,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$EncryptedMeasurementCopyWithImpl<$Res,
        $Val extends EncryptedMeasurement>
    implements $EncryptedMeasurementCopyWith<$Res> {
  _$EncryptedMeasurementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? metricType = null,
    Object? encryptedData = null,
    Object? iv = null,
    Object? tag = null,
    Object? timestamp = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      metricType: null == metricType
          ? _value.metricType
          : metricType // ignore: cast_nullable_to_non_nullable
              as String,
      encryptedData: null == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String,
      iv: null == iv
          ? _value.iv
          : iv // ignore: cast_nullable_to_non_nullable
              as String,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EncryptedMeasurementImplCopyWith<$Res>
    implements $EncryptedMeasurementCopyWith<$Res> {
  factory _$$EncryptedMeasurementImplCopyWith(_$EncryptedMeasurementImpl value,
          $Res Function(_$EncryptedMeasurementImpl) then) =
      __$$EncryptedMeasurementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String metricType,
      String encryptedData,
      String iv,
      String tag,
      DateTime timestamp,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$EncryptedMeasurementImplCopyWithImpl<$Res>
    extends _$EncryptedMeasurementCopyWithImpl<$Res, _$EncryptedMeasurementImpl>
    implements _$$EncryptedMeasurementImplCopyWith<$Res> {
  __$$EncryptedMeasurementImplCopyWithImpl(_$EncryptedMeasurementImpl _value,
      $Res Function(_$EncryptedMeasurementImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? metricType = null,
    Object? encryptedData = null,
    Object? iv = null,
    Object? tag = null,
    Object? timestamp = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$EncryptedMeasurementImpl(
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
              as String,
      encryptedData: null == encryptedData
          ? _value.encryptedData
          : encryptedData // ignore: cast_nullable_to_non_nullable
              as String,
      iv: null == iv
          ? _value.iv
          : iv // ignore: cast_nullable_to_non_nullable
              as String,
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EncryptedMeasurementImpl implements _EncryptedMeasurement {
  const _$EncryptedMeasurementImpl(
      {required this.id,
      required this.userId,
      required this.metricType,
      required this.encryptedData,
      required this.iv,
      required this.tag,
      required this.timestamp,
      this.createdAt,
      this.updatedAt});

  factory _$EncryptedMeasurementImpl.fromJson(Map<String, dynamic> json) =>
      _$$EncryptedMeasurementImplFromJson(json);

  /// Measurement ID (same as original Measurement.id)
  @override
  final String id;

  /// User ID (Firebase Auth UID)
  @override
  final String userId;

  /// Metric type (stored unencrypted for querying)
  ///
  /// **Note**: MetricType is NOT sensitive PII, safe to store unencrypted.
  /// Allows efficient Firestore queries: "Get all weight measurements"
  @override
  final String metricType;

  /// Encrypted measurement data (base64 encoded)
  ///
  /// **Contains**: Measurement JSON serialized → encrypted → base64
  /// ```json
  /// {
  ///   "value": 75.5,
  ///   "unit": "kg",
  ///   "notes": "Morning weight after workout",
  ///   "source": "manual"
  /// }
  /// ```
  @override
  final String encryptedData;

  /// Initialization Vector (base64 encoded)
  ///
  /// **IV**: Randomly generated 12 bytes for AES-GCM.
  /// Must be unique per encryption operation (never reuse with same key).
  @override
  final String iv;

  /// Authentication tag (base64 encoded)
  ///
  /// **Tag**: 16-byte GCM tag for data integrity verification.
  /// Prevents tampering (decryption fails if data modified).
  @override
  final String tag;

  /// Timestamp (stored unencrypted for sorting/filtering)
  ///
  /// **Note**: Timestamp is NOT sensitive PII, safe to store unencrypted.
  /// Allows efficient queries: "Get measurements from last 30 days"
  @override
  final DateTime timestamp;

  /// When this encrypted measurement was created
  @override
  final DateTime? createdAt;

  /// When this encrypted measurement was last updated
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'EncryptedMeasurement(id: $id, userId: $userId, metricType: $metricType, encryptedData: $encryptedData, iv: $iv, tag: $tag, timestamp: $timestamp, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EncryptedMeasurementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.metricType, metricType) ||
                other.metricType == metricType) &&
            (identical(other.encryptedData, encryptedData) ||
                other.encryptedData == encryptedData) &&
            (identical(other.iv, iv) || other.iv == iv) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, metricType,
      encryptedData, iv, tag, timestamp, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EncryptedMeasurementImplCopyWith<_$EncryptedMeasurementImpl>
      get copyWith =>
          __$$EncryptedMeasurementImplCopyWithImpl<_$EncryptedMeasurementImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EncryptedMeasurementImplToJson(
      this,
    );
  }
}

abstract class _EncryptedMeasurement implements EncryptedMeasurement {
  const factory _EncryptedMeasurement(
      {required final String id,
      required final String userId,
      required final String metricType,
      required final String encryptedData,
      required final String iv,
      required final String tag,
      required final DateTime timestamp,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$EncryptedMeasurementImpl;

  factory _EncryptedMeasurement.fromJson(Map<String, dynamic> json) =
      _$EncryptedMeasurementImpl.fromJson;

  @override

  /// Measurement ID (same as original Measurement.id)
  String get id;
  @override

  /// User ID (Firebase Auth UID)
  String get userId;
  @override

  /// Metric type (stored unencrypted for querying)
  ///
  /// **Note**: MetricType is NOT sensitive PII, safe to store unencrypted.
  /// Allows efficient Firestore queries: "Get all weight measurements"
  String get metricType;
  @override

  /// Encrypted measurement data (base64 encoded)
  ///
  /// **Contains**: Measurement JSON serialized → encrypted → base64
  /// ```json
  /// {
  ///   "value": 75.5,
  ///   "unit": "kg",
  ///   "notes": "Morning weight after workout",
  ///   "source": "manual"
  /// }
  /// ```
  String get encryptedData;
  @override

  /// Initialization Vector (base64 encoded)
  ///
  /// **IV**: Randomly generated 12 bytes for AES-GCM.
  /// Must be unique per encryption operation (never reuse with same key).
  String get iv;
  @override

  /// Authentication tag (base64 encoded)
  ///
  /// **Tag**: 16-byte GCM tag for data integrity verification.
  /// Prevents tampering (decryption fails if data modified).
  String get tag;
  @override

  /// Timestamp (stored unencrypted for sorting/filtering)
  ///
  /// **Note**: Timestamp is NOT sensitive PII, safe to store unencrypted.
  /// Allows efficient queries: "Get measurements from last 30 days"
  DateTime get timestamp;
  @override

  /// When this encrypted measurement was created
  DateTime? get createdAt;
  @override

  /// When this encrypted measurement was last updated
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$EncryptedMeasurementImplCopyWith<_$EncryptedMeasurementImpl>
      get copyWith => throw _privateConstructorUsedError;
}

EncryptionMetadata _$EncryptionMetadataFromJson(Map<String, dynamic> json) {
  return _EncryptionMetadata.fromJson(json);
}

/// @nodoc
mixin _$EncryptionMetadata {
  /// Encryption key version (incremented on key rotation)
  ///
  /// **Key Rotation**: Every 90 days or on-demand.
  /// Old encrypted data is re-encrypted with new key.
  int get keyVersion => throw _privateConstructorUsedError;

  /// When encryption key was generated
  DateTime get keyGeneratedAt => throw _privateConstructorUsedError;

  /// When encryption key was last rotated
  DateTime? get keyLastRotated => throw _privateConstructorUsedError;

  /// Next scheduled key rotation date
  DateTime? get keyRotationScheduled => throw _privateConstructorUsedError;

  /// Encryption algorithm used
  /// Default: "AES-256-GCM"
  String get algorithm => throw _privateConstructorUsedError;

  /// Key derivation function (if applicable)
  /// Example: "PBKDF2-SHA256" for password-derived keys
  String? get keyDerivationFunction => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EncryptionMetadataCopyWith<EncryptionMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EncryptionMetadataCopyWith<$Res> {
  factory $EncryptionMetadataCopyWith(
          EncryptionMetadata value, $Res Function(EncryptionMetadata) then) =
      _$EncryptionMetadataCopyWithImpl<$Res, EncryptionMetadata>;
  @useResult
  $Res call(
      {int keyVersion,
      DateTime keyGeneratedAt,
      DateTime? keyLastRotated,
      DateTime? keyRotationScheduled,
      String algorithm,
      String? keyDerivationFunction});
}

/// @nodoc
class _$EncryptionMetadataCopyWithImpl<$Res, $Val extends EncryptionMetadata>
    implements $EncryptionMetadataCopyWith<$Res> {
  _$EncryptionMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyVersion = null,
    Object? keyGeneratedAt = null,
    Object? keyLastRotated = freezed,
    Object? keyRotationScheduled = freezed,
    Object? algorithm = null,
    Object? keyDerivationFunction = freezed,
  }) {
    return _then(_value.copyWith(
      keyVersion: null == keyVersion
          ? _value.keyVersion
          : keyVersion // ignore: cast_nullable_to_non_nullable
              as int,
      keyGeneratedAt: null == keyGeneratedAt
          ? _value.keyGeneratedAt
          : keyGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      keyLastRotated: freezed == keyLastRotated
          ? _value.keyLastRotated
          : keyLastRotated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      keyRotationScheduled: freezed == keyRotationScheduled
          ? _value.keyRotationScheduled
          : keyRotationScheduled // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      keyDerivationFunction: freezed == keyDerivationFunction
          ? _value.keyDerivationFunction
          : keyDerivationFunction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EncryptionMetadataImplCopyWith<$Res>
    implements $EncryptionMetadataCopyWith<$Res> {
  factory _$$EncryptionMetadataImplCopyWith(_$EncryptionMetadataImpl value,
          $Res Function(_$EncryptionMetadataImpl) then) =
      __$$EncryptionMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int keyVersion,
      DateTime keyGeneratedAt,
      DateTime? keyLastRotated,
      DateTime? keyRotationScheduled,
      String algorithm,
      String? keyDerivationFunction});
}

/// @nodoc
class __$$EncryptionMetadataImplCopyWithImpl<$Res>
    extends _$EncryptionMetadataCopyWithImpl<$Res, _$EncryptionMetadataImpl>
    implements _$$EncryptionMetadataImplCopyWith<$Res> {
  __$$EncryptionMetadataImplCopyWithImpl(_$EncryptionMetadataImpl _value,
      $Res Function(_$EncryptionMetadataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyVersion = null,
    Object? keyGeneratedAt = null,
    Object? keyLastRotated = freezed,
    Object? keyRotationScheduled = freezed,
    Object? algorithm = null,
    Object? keyDerivationFunction = freezed,
  }) {
    return _then(_$EncryptionMetadataImpl(
      keyVersion: null == keyVersion
          ? _value.keyVersion
          : keyVersion // ignore: cast_nullable_to_non_nullable
              as int,
      keyGeneratedAt: null == keyGeneratedAt
          ? _value.keyGeneratedAt
          : keyGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      keyLastRotated: freezed == keyLastRotated
          ? _value.keyLastRotated
          : keyLastRotated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      keyRotationScheduled: freezed == keyRotationScheduled
          ? _value.keyRotationScheduled
          : keyRotationScheduled // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      keyDerivationFunction: freezed == keyDerivationFunction
          ? _value.keyDerivationFunction
          : keyDerivationFunction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EncryptionMetadataImpl implements _EncryptionMetadata {
  const _$EncryptionMetadataImpl(
      {required this.keyVersion,
      required this.keyGeneratedAt,
      this.keyLastRotated,
      this.keyRotationScheduled,
      this.algorithm = 'AES-256-GCM',
      this.keyDerivationFunction});

  factory _$EncryptionMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EncryptionMetadataImplFromJson(json);

  /// Encryption key version (incremented on key rotation)
  ///
  /// **Key Rotation**: Every 90 days or on-demand.
  /// Old encrypted data is re-encrypted with new key.
  @override
  final int keyVersion;

  /// When encryption key was generated
  @override
  final DateTime keyGeneratedAt;

  /// When encryption key was last rotated
  @override
  final DateTime? keyLastRotated;

  /// Next scheduled key rotation date
  @override
  final DateTime? keyRotationScheduled;

  /// Encryption algorithm used
  /// Default: "AES-256-GCM"
  @override
  @JsonKey()
  final String algorithm;

  /// Key derivation function (if applicable)
  /// Example: "PBKDF2-SHA256" for password-derived keys
  @override
  final String? keyDerivationFunction;

  @override
  String toString() {
    return 'EncryptionMetadata(keyVersion: $keyVersion, keyGeneratedAt: $keyGeneratedAt, keyLastRotated: $keyLastRotated, keyRotationScheduled: $keyRotationScheduled, algorithm: $algorithm, keyDerivationFunction: $keyDerivationFunction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EncryptionMetadataImpl &&
            (identical(other.keyVersion, keyVersion) ||
                other.keyVersion == keyVersion) &&
            (identical(other.keyGeneratedAt, keyGeneratedAt) ||
                other.keyGeneratedAt == keyGeneratedAt) &&
            (identical(other.keyLastRotated, keyLastRotated) ||
                other.keyLastRotated == keyLastRotated) &&
            (identical(other.keyRotationScheduled, keyRotationScheduled) ||
                other.keyRotationScheduled == keyRotationScheduled) &&
            (identical(other.algorithm, algorithm) ||
                other.algorithm == algorithm) &&
            (identical(other.keyDerivationFunction, keyDerivationFunction) ||
                other.keyDerivationFunction == keyDerivationFunction));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, keyVersion, keyGeneratedAt,
      keyLastRotated, keyRotationScheduled, algorithm, keyDerivationFunction);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EncryptionMetadataImplCopyWith<_$EncryptionMetadataImpl> get copyWith =>
      __$$EncryptionMetadataImplCopyWithImpl<_$EncryptionMetadataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EncryptionMetadataImplToJson(
      this,
    );
  }
}

abstract class _EncryptionMetadata implements EncryptionMetadata {
  const factory _EncryptionMetadata(
      {required final int keyVersion,
      required final DateTime keyGeneratedAt,
      final DateTime? keyLastRotated,
      final DateTime? keyRotationScheduled,
      final String algorithm,
      final String? keyDerivationFunction}) = _$EncryptionMetadataImpl;

  factory _EncryptionMetadata.fromJson(Map<String, dynamic> json) =
      _$EncryptionMetadataImpl.fromJson;

  @override

  /// Encryption key version (incremented on key rotation)
  ///
  /// **Key Rotation**: Every 90 days or on-demand.
  /// Old encrypted data is re-encrypted with new key.
  int get keyVersion;
  @override

  /// When encryption key was generated
  DateTime get keyGeneratedAt;
  @override

  /// When encryption key was last rotated
  DateTime? get keyLastRotated;
  @override

  /// Next scheduled key rotation date
  DateTime? get keyRotationScheduled;
  @override

  /// Encryption algorithm used
  /// Default: "AES-256-GCM"
  String get algorithm;
  @override

  /// Key derivation function (if applicable)
  /// Example: "PBKDF2-SHA256" for password-derived keys
  String? get keyDerivationFunction;
  @override
  @JsonKey(ignore: true)
  _$$EncryptionMetadataImplCopyWith<_$EncryptionMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
