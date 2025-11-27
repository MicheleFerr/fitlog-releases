// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_consent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserConsent _$UserConsentFromJson(Map<String, dynamic> json) {
  return _UserConsent.fromJson(json);
}

/// @nodoc
mixin _$UserConsent {
  /// Unique consent record ID (UUID v4)
  String get id => throw _privateConstructorUsedError;

  /// User ID (Firebase Auth UID)
  String get userId => throw _privateConstructorUsedError;

  /// Consent state per metric group (Essential, Measurements, Vitals)
  ///
  /// **Just-in-Time Consent Flow**:
  /// - Essential: Requested during onboarding (weight, body fat)
  /// - Measurements: Requested when user taps "Track Body Measurements"
  /// - Vitals: Requested when user taps "Track Vitals"
  ///
  /// **GDPR**: Implements Privacy by Design (Article 25)
  /// - Default state: ConsentState.notAsked
  /// - User explicitly grants or denies each group
  /// - No implicit consent (asking = not granted)
  Map<MetricGroup, ConsentState> get groupConsents =>
      throw _privateConstructorUsedError;

  /// Privacy policy version accepted by user
  ///
  /// **GDPR**: When privacy policy updates, increment version.
  /// Users must re-consent to new policy version.
  ///
  /// Version history:
  /// - v1: Initial GDPR-compliant policy (2025-01-24)
  /// - v2: Future updates (prompt user to review and re-accept)
  int get consentVersion => throw _privateConstructorUsedError;

  /// When consent was granted (user's local time)
  DateTime get acceptedAt => throw _privateConstructorUsedError;

  /// IP address when consent was granted
  ///
  /// **GDPR Article 30**: Required for audit trail and compliance proof.
  /// Stored masked for privacy (last octet redacted: "192.168.1.***")
  String get ipAddress => throw _privateConstructorUsedError;

  /// When Essential metrics consent was granted
  /// (Separate timestamp for Just-in-Time consent tracking)
  DateTime? get essentialGrantedAt => throw _privateConstructorUsedError;

  /// When Measurements group consent was granted
  DateTime? get measurementsGrantedAt => throw _privateConstructorUsedError;

  /// When Vitals group consent was granted
  DateTime? get vitalsGrantedAt => throw _privateConstructorUsedError;

  /// When this consent record was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When this consent record was last updated
  /// (e.g., user revoked consent for Vitals group)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Whether this consent has been revoked
  /// (Soft-delete: keep record for audit trail)
  bool get isRevoked => throw _privateConstructorUsedError;

  /// When consent was revoked (if isRevoked = true)
  DateTime? get revokedAt => throw _privateConstructorUsedError;

  /// User agent string (browser/app version)
  /// Example: "FitLog Pro/1.0.0 iOS/17.2 (iPhone 14 Pro)"
  String? get userAgent => throw _privateConstructorUsedError;

  /// Serializes this UserConsent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserConsent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserConsentCopyWith<UserConsent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserConsentCopyWith<$Res> {
  factory $UserConsentCopyWith(
    UserConsent value,
    $Res Function(UserConsent) then,
  ) = _$UserConsentCopyWithImpl<$Res, UserConsent>;
  @useResult
  $Res call({
    String id,
    String userId,
    Map<MetricGroup, ConsentState> groupConsents,
    int consentVersion,
    DateTime acceptedAt,
    String ipAddress,
    DateTime? essentialGrantedAt,
    DateTime? measurementsGrantedAt,
    DateTime? vitalsGrantedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isRevoked,
    DateTime? revokedAt,
    String? userAgent,
  });
}

/// @nodoc
class _$UserConsentCopyWithImpl<$Res, $Val extends UserConsent>
    implements $UserConsentCopyWith<$Res> {
  _$UserConsentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserConsent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? groupConsents = null,
    Object? consentVersion = null,
    Object? acceptedAt = null,
    Object? ipAddress = null,
    Object? essentialGrantedAt = freezed,
    Object? measurementsGrantedAt = freezed,
    Object? vitalsGrantedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isRevoked = null,
    Object? revokedAt = freezed,
    Object? userAgent = freezed,
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
            groupConsents: null == groupConsents
                ? _value.groupConsents
                : groupConsents // ignore: cast_nullable_to_non_nullable
                      as Map<MetricGroup, ConsentState>,
            consentVersion: null == consentVersion
                ? _value.consentVersion
                : consentVersion // ignore: cast_nullable_to_non_nullable
                      as int,
            acceptedAt: null == acceptedAt
                ? _value.acceptedAt
                : acceptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            essentialGrantedAt: freezed == essentialGrantedAt
                ? _value.essentialGrantedAt
                : essentialGrantedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            measurementsGrantedAt: freezed == measurementsGrantedAt
                ? _value.measurementsGrantedAt
                : measurementsGrantedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            vitalsGrantedAt: freezed == vitalsGrantedAt
                ? _value.vitalsGrantedAt
                : vitalsGrantedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isRevoked: null == isRevoked
                ? _value.isRevoked
                : isRevoked // ignore: cast_nullable_to_non_nullable
                      as bool,
            revokedAt: freezed == revokedAt
                ? _value.revokedAt
                : revokedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            userAgent: freezed == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserConsentImplCopyWith<$Res>
    implements $UserConsentCopyWith<$Res> {
  factory _$$UserConsentImplCopyWith(
    _$UserConsentImpl value,
    $Res Function(_$UserConsentImpl) then,
  ) = __$$UserConsentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    Map<MetricGroup, ConsentState> groupConsents,
    int consentVersion,
    DateTime acceptedAt,
    String ipAddress,
    DateTime? essentialGrantedAt,
    DateTime? measurementsGrantedAt,
    DateTime? vitalsGrantedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isRevoked,
    DateTime? revokedAt,
    String? userAgent,
  });
}

/// @nodoc
class __$$UserConsentImplCopyWithImpl<$Res>
    extends _$UserConsentCopyWithImpl<$Res, _$UserConsentImpl>
    implements _$$UserConsentImplCopyWith<$Res> {
  __$$UserConsentImplCopyWithImpl(
    _$UserConsentImpl _value,
    $Res Function(_$UserConsentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserConsent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? groupConsents = null,
    Object? consentVersion = null,
    Object? acceptedAt = null,
    Object? ipAddress = null,
    Object? essentialGrantedAt = freezed,
    Object? measurementsGrantedAt = freezed,
    Object? vitalsGrantedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isRevoked = null,
    Object? revokedAt = freezed,
    Object? userAgent = freezed,
  }) {
    return _then(
      _$UserConsentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        groupConsents: null == groupConsents
            ? _value._groupConsents
            : groupConsents // ignore: cast_nullable_to_non_nullable
                  as Map<MetricGroup, ConsentState>,
        consentVersion: null == consentVersion
            ? _value.consentVersion
            : consentVersion // ignore: cast_nullable_to_non_nullable
                  as int,
        acceptedAt: null == acceptedAt
            ? _value.acceptedAt
            : acceptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        essentialGrantedAt: freezed == essentialGrantedAt
            ? _value.essentialGrantedAt
            : essentialGrantedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        measurementsGrantedAt: freezed == measurementsGrantedAt
            ? _value.measurementsGrantedAt
            : measurementsGrantedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        vitalsGrantedAt: freezed == vitalsGrantedAt
            ? _value.vitalsGrantedAt
            : vitalsGrantedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isRevoked: null == isRevoked
            ? _value.isRevoked
            : isRevoked // ignore: cast_nullable_to_non_nullable
                  as bool,
        revokedAt: freezed == revokedAt
            ? _value.revokedAt
            : revokedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        userAgent: freezed == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserConsentImpl implements _UserConsent {
  const _$UserConsentImpl({
    required this.id,
    required this.userId,
    required final Map<MetricGroup, ConsentState> groupConsents,
    required this.consentVersion,
    required this.acceptedAt,
    required this.ipAddress,
    this.essentialGrantedAt,
    this.measurementsGrantedAt,
    this.vitalsGrantedAt,
    this.createdAt,
    this.updatedAt,
    this.isRevoked = false,
    this.revokedAt,
    this.userAgent,
  }) : _groupConsents = groupConsents;

  factory _$UserConsentImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserConsentImplFromJson(json);

  /// Unique consent record ID (UUID v4)
  @override
  final String id;

  /// User ID (Firebase Auth UID)
  @override
  final String userId;

  /// Consent state per metric group (Essential, Measurements, Vitals)
  ///
  /// **Just-in-Time Consent Flow**:
  /// - Essential: Requested during onboarding (weight, body fat)
  /// - Measurements: Requested when user taps "Track Body Measurements"
  /// - Vitals: Requested when user taps "Track Vitals"
  ///
  /// **GDPR**: Implements Privacy by Design (Article 25)
  /// - Default state: ConsentState.notAsked
  /// - User explicitly grants or denies each group
  /// - No implicit consent (asking = not granted)
  final Map<MetricGroup, ConsentState> _groupConsents;

  /// Consent state per metric group (Essential, Measurements, Vitals)
  ///
  /// **Just-in-Time Consent Flow**:
  /// - Essential: Requested during onboarding (weight, body fat)
  /// - Measurements: Requested when user taps "Track Body Measurements"
  /// - Vitals: Requested when user taps "Track Vitals"
  ///
  /// **GDPR**: Implements Privacy by Design (Article 25)
  /// - Default state: ConsentState.notAsked
  /// - User explicitly grants or denies each group
  /// - No implicit consent (asking = not granted)
  @override
  Map<MetricGroup, ConsentState> get groupConsents {
    if (_groupConsents is EqualUnmodifiableMapView) return _groupConsents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_groupConsents);
  }

  /// Privacy policy version accepted by user
  ///
  /// **GDPR**: When privacy policy updates, increment version.
  /// Users must re-consent to new policy version.
  ///
  /// Version history:
  /// - v1: Initial GDPR-compliant policy (2025-01-24)
  /// - v2: Future updates (prompt user to review and re-accept)
  @override
  final int consentVersion;

  /// When consent was granted (user's local time)
  @override
  final DateTime acceptedAt;

  /// IP address when consent was granted
  ///
  /// **GDPR Article 30**: Required for audit trail and compliance proof.
  /// Stored masked for privacy (last octet redacted: "192.168.1.***")
  @override
  final String ipAddress;

  /// When Essential metrics consent was granted
  /// (Separate timestamp for Just-in-Time consent tracking)
  @override
  final DateTime? essentialGrantedAt;

  /// When Measurements group consent was granted
  @override
  final DateTime? measurementsGrantedAt;

  /// When Vitals group consent was granted
  @override
  final DateTime? vitalsGrantedAt;

  /// When this consent record was created
  @override
  final DateTime? createdAt;

  /// When this consent record was last updated
  /// (e.g., user revoked consent for Vitals group)
  @override
  final DateTime? updatedAt;

  /// Whether this consent has been revoked
  /// (Soft-delete: keep record for audit trail)
  @override
  @JsonKey()
  final bool isRevoked;

  /// When consent was revoked (if isRevoked = true)
  @override
  final DateTime? revokedAt;

  /// User agent string (browser/app version)
  /// Example: "FitLog Pro/1.0.0 iOS/17.2 (iPhone 14 Pro)"
  @override
  final String? userAgent;

  @override
  String toString() {
    return 'UserConsent(id: $id, userId: $userId, groupConsents: $groupConsents, consentVersion: $consentVersion, acceptedAt: $acceptedAt, ipAddress: $ipAddress, essentialGrantedAt: $essentialGrantedAt, measurementsGrantedAt: $measurementsGrantedAt, vitalsGrantedAt: $vitalsGrantedAt, createdAt: $createdAt, updatedAt: $updatedAt, isRevoked: $isRevoked, revokedAt: $revokedAt, userAgent: $userAgent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserConsentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._groupConsents,
              _groupConsents,
            ) &&
            (identical(other.consentVersion, consentVersion) ||
                other.consentVersion == consentVersion) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.essentialGrantedAt, essentialGrantedAt) ||
                other.essentialGrantedAt == essentialGrantedAt) &&
            (identical(other.measurementsGrantedAt, measurementsGrantedAt) ||
                other.measurementsGrantedAt == measurementsGrantedAt) &&
            (identical(other.vitalsGrantedAt, vitalsGrantedAt) ||
                other.vitalsGrantedAt == vitalsGrantedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isRevoked, isRevoked) ||
                other.isRevoked == isRevoked) &&
            (identical(other.revokedAt, revokedAt) ||
                other.revokedAt == revokedAt) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    const DeepCollectionEquality().hash(_groupConsents),
    consentVersion,
    acceptedAt,
    ipAddress,
    essentialGrantedAt,
    measurementsGrantedAt,
    vitalsGrantedAt,
    createdAt,
    updatedAt,
    isRevoked,
    revokedAt,
    userAgent,
  );

  /// Create a copy of UserConsent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserConsentImplCopyWith<_$UserConsentImpl> get copyWith =>
      __$$UserConsentImplCopyWithImpl<_$UserConsentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserConsentImplToJson(this);
  }
}

abstract class _UserConsent implements UserConsent {
  const factory _UserConsent({
    required final String id,
    required final String userId,
    required final Map<MetricGroup, ConsentState> groupConsents,
    required final int consentVersion,
    required final DateTime acceptedAt,
    required final String ipAddress,
    final DateTime? essentialGrantedAt,
    final DateTime? measurementsGrantedAt,
    final DateTime? vitalsGrantedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final bool isRevoked,
    final DateTime? revokedAt,
    final String? userAgent,
  }) = _$UserConsentImpl;

  factory _UserConsent.fromJson(Map<String, dynamic> json) =
      _$UserConsentImpl.fromJson;

  /// Unique consent record ID (UUID v4)
  @override
  String get id;

  /// User ID (Firebase Auth UID)
  @override
  String get userId;

  /// Consent state per metric group (Essential, Measurements, Vitals)
  ///
  /// **Just-in-Time Consent Flow**:
  /// - Essential: Requested during onboarding (weight, body fat)
  /// - Measurements: Requested when user taps "Track Body Measurements"
  /// - Vitals: Requested when user taps "Track Vitals"
  ///
  /// **GDPR**: Implements Privacy by Design (Article 25)
  /// - Default state: ConsentState.notAsked
  /// - User explicitly grants or denies each group
  /// - No implicit consent (asking = not granted)
  @override
  Map<MetricGroup, ConsentState> get groupConsents;

  /// Privacy policy version accepted by user
  ///
  /// **GDPR**: When privacy policy updates, increment version.
  /// Users must re-consent to new policy version.
  ///
  /// Version history:
  /// - v1: Initial GDPR-compliant policy (2025-01-24)
  /// - v2: Future updates (prompt user to review and re-accept)
  @override
  int get consentVersion;

  /// When consent was granted (user's local time)
  @override
  DateTime get acceptedAt;

  /// IP address when consent was granted
  ///
  /// **GDPR Article 30**: Required for audit trail and compliance proof.
  /// Stored masked for privacy (last octet redacted: "192.168.1.***")
  @override
  String get ipAddress;

  /// When Essential metrics consent was granted
  /// (Separate timestamp for Just-in-Time consent tracking)
  @override
  DateTime? get essentialGrantedAt;

  /// When Measurements group consent was granted
  @override
  DateTime? get measurementsGrantedAt;

  /// When Vitals group consent was granted
  @override
  DateTime? get vitalsGrantedAt;

  /// When this consent record was created
  @override
  DateTime? get createdAt;

  /// When this consent record was last updated
  /// (e.g., user revoked consent for Vitals group)
  @override
  DateTime? get updatedAt;

  /// Whether this consent has been revoked
  /// (Soft-delete: keep record for audit trail)
  @override
  bool get isRevoked;

  /// When consent was revoked (if isRevoked = true)
  @override
  DateTime? get revokedAt;

  /// User agent string (browser/app version)
  /// Example: "FitLog Pro/1.0.0 iOS/17.2 (iPhone 14 Pro)"
  @override
  String? get userAgent;

  /// Create a copy of UserConsent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserConsentImplCopyWith<_$UserConsentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) {
  return _AuditLog.fromJson(json);
}

/// @nodoc
mixin _$AuditLog {
  /// Unique audit log ID (UUID v4)
  String get id => throw _privateConstructorUsedError;

  /// User ID (Firebase Auth UID)
  String get userId => throw _privateConstructorUsedError;

  /// Action that was performed
  AuditAction get action => throw _privateConstructorUsedError;

  /// When action occurred (UTC timestamp)
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// IP address where action originated
  /// (Masked for privacy: "192.168.1.***")
  String get ipAddress => throw _privateConstructorUsedError;

  /// List of metrics affected by this action
  /// (e.g., [MetricType.weight] for "dataAccess" action)
  List<MetricType>? get affectedMetrics => throw _privateConstructorUsedError;

  /// Action details (e.g., "Exported 150 measurements to JSON")
  String? get actionDetails => throw _privateConstructorUsedError;

  /// Previous log entry hash (for tamper-evidence chain)
  ///
  /// **Integrity Verification**:
  /// - Each log has hash = SHA256(previousHash + userId + action + timestamp)
  /// - First log has previousHash = "GENESIS"
  /// - Chain verification detects tampered/deleted logs
  String? get previousHash => throw _privateConstructorUsedError;

  /// Hash of this log entry (SHA256)
  /// Computed as: SHA256(previousHash + userId + action + timestamp)
  String? get hash => throw _privateConstructorUsedError;

  /// User agent (browser/app version)
  String? get userAgent => throw _privateConstructorUsedError;

  /// Platform (iOS, Android, Web)
  String? get platform => throw _privateConstructorUsedError;

  /// App version when action occurred
  String? get appVersion => throw _privateConstructorUsedError;

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogCopyWith<AuditLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogCopyWith<$Res> {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) then) =
      _$AuditLogCopyWithImpl<$Res, AuditLog>;
  @useResult
  $Res call({
    String id,
    String userId,
    AuditAction action,
    DateTime timestamp,
    String ipAddress,
    List<MetricType>? affectedMetrics,
    String? actionDetails,
    String? previousHash,
    String? hash,
    String? userAgent,
    String? platform,
    String? appVersion,
  });
}

/// @nodoc
class _$AuditLogCopyWithImpl<$Res, $Val extends AuditLog>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? action = null,
    Object? timestamp = null,
    Object? ipAddress = null,
    Object? affectedMetrics = freezed,
    Object? actionDetails = freezed,
    Object? previousHash = freezed,
    Object? hash = freezed,
    Object? userAgent = freezed,
    Object? platform = freezed,
    Object? appVersion = freezed,
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
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as AuditAction,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            affectedMetrics: freezed == affectedMetrics
                ? _value.affectedMetrics
                : affectedMetrics // ignore: cast_nullable_to_non_nullable
                      as List<MetricType>?,
            actionDetails: freezed == actionDetails
                ? _value.actionDetails
                : actionDetails // ignore: cast_nullable_to_non_nullable
                      as String?,
            previousHash: freezed == previousHash
                ? _value.previousHash
                : previousHash // ignore: cast_nullable_to_non_nullable
                      as String?,
            hash: freezed == hash
                ? _value.hash
                : hash // ignore: cast_nullable_to_non_nullable
                      as String?,
            userAgent: freezed == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String?,
            platform: freezed == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String?,
            appVersion: freezed == appVersion
                ? _value.appVersion
                : appVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuditLogImplCopyWith<$Res>
    implements $AuditLogCopyWith<$Res> {
  factory _$$AuditLogImplCopyWith(
    _$AuditLogImpl value,
    $Res Function(_$AuditLogImpl) then,
  ) = __$$AuditLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    AuditAction action,
    DateTime timestamp,
    String ipAddress,
    List<MetricType>? affectedMetrics,
    String? actionDetails,
    String? previousHash,
    String? hash,
    String? userAgent,
    String? platform,
    String? appVersion,
  });
}

/// @nodoc
class __$$AuditLogImplCopyWithImpl<$Res>
    extends _$AuditLogCopyWithImpl<$Res, _$AuditLogImpl>
    implements _$$AuditLogImplCopyWith<$Res> {
  __$$AuditLogImplCopyWithImpl(
    _$AuditLogImpl _value,
    $Res Function(_$AuditLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? action = null,
    Object? timestamp = null,
    Object? ipAddress = null,
    Object? affectedMetrics = freezed,
    Object? actionDetails = freezed,
    Object? previousHash = freezed,
    Object? hash = freezed,
    Object? userAgent = freezed,
    Object? platform = freezed,
    Object? appVersion = freezed,
  }) {
    return _then(
      _$AuditLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as AuditAction,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        affectedMetrics: freezed == affectedMetrics
            ? _value._affectedMetrics
            : affectedMetrics // ignore: cast_nullable_to_non_nullable
                  as List<MetricType>?,
        actionDetails: freezed == actionDetails
            ? _value.actionDetails
            : actionDetails // ignore: cast_nullable_to_non_nullable
                  as String?,
        previousHash: freezed == previousHash
            ? _value.previousHash
            : previousHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        hash: freezed == hash
            ? _value.hash
            : hash // ignore: cast_nullable_to_non_nullable
                  as String?,
        userAgent: freezed == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String?,
        platform: freezed == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String?,
        appVersion: freezed == appVersion
            ? _value.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditLogImpl implements _AuditLog {
  const _$AuditLogImpl({
    required this.id,
    required this.userId,
    required this.action,
    required this.timestamp,
    required this.ipAddress,
    final List<MetricType>? affectedMetrics,
    this.actionDetails,
    this.previousHash,
    this.hash,
    this.userAgent,
    this.platform,
    this.appVersion,
  }) : _affectedMetrics = affectedMetrics;

  factory _$AuditLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogImplFromJson(json);

  /// Unique audit log ID (UUID v4)
  @override
  final String id;

  /// User ID (Firebase Auth UID)
  @override
  final String userId;

  /// Action that was performed
  @override
  final AuditAction action;

  /// When action occurred (UTC timestamp)
  @override
  final DateTime timestamp;

  /// IP address where action originated
  /// (Masked for privacy: "192.168.1.***")
  @override
  final String ipAddress;

  /// List of metrics affected by this action
  /// (e.g., [MetricType.weight] for "dataAccess" action)
  final List<MetricType>? _affectedMetrics;

  /// List of metrics affected by this action
  /// (e.g., [MetricType.weight] for "dataAccess" action)
  @override
  List<MetricType>? get affectedMetrics {
    final value = _affectedMetrics;
    if (value == null) return null;
    if (_affectedMetrics is EqualUnmodifiableListView) return _affectedMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Action details (e.g., "Exported 150 measurements to JSON")
  @override
  final String? actionDetails;

  /// Previous log entry hash (for tamper-evidence chain)
  ///
  /// **Integrity Verification**:
  /// - Each log has hash = SHA256(previousHash + userId + action + timestamp)
  /// - First log has previousHash = "GENESIS"
  /// - Chain verification detects tampered/deleted logs
  @override
  final String? previousHash;

  /// Hash of this log entry (SHA256)
  /// Computed as: SHA256(previousHash + userId + action + timestamp)
  @override
  final String? hash;

  /// User agent (browser/app version)
  @override
  final String? userAgent;

  /// Platform (iOS, Android, Web)
  @override
  final String? platform;

  /// App version when action occurred
  @override
  final String? appVersion;

  @override
  String toString() {
    return 'AuditLog(id: $id, userId: $userId, action: $action, timestamp: $timestamp, ipAddress: $ipAddress, affectedMetrics: $affectedMetrics, actionDetails: $actionDetails, previousHash: $previousHash, hash: $hash, userAgent: $userAgent, platform: $platform, appVersion: $appVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            const DeepCollectionEquality().equals(
              other._affectedMetrics,
              _affectedMetrics,
            ) &&
            (identical(other.actionDetails, actionDetails) ||
                other.actionDetails == actionDetails) &&
            (identical(other.previousHash, previousHash) ||
                other.previousHash == previousHash) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    action,
    timestamp,
    ipAddress,
    const DeepCollectionEquality().hash(_affectedMetrics),
    actionDetails,
    previousHash,
    hash,
    userAgent,
    platform,
    appVersion,
  );

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      __$$AuditLogImplCopyWithImpl<_$AuditLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogImplToJson(this);
  }
}

abstract class _AuditLog implements AuditLog {
  const factory _AuditLog({
    required final String id,
    required final String userId,
    required final AuditAction action,
    required final DateTime timestamp,
    required final String ipAddress,
    final List<MetricType>? affectedMetrics,
    final String? actionDetails,
    final String? previousHash,
    final String? hash,
    final String? userAgent,
    final String? platform,
    final String? appVersion,
  }) = _$AuditLogImpl;

  factory _AuditLog.fromJson(Map<String, dynamic> json) =
      _$AuditLogImpl.fromJson;

  /// Unique audit log ID (UUID v4)
  @override
  String get id;

  /// User ID (Firebase Auth UID)
  @override
  String get userId;

  /// Action that was performed
  @override
  AuditAction get action;

  /// When action occurred (UTC timestamp)
  @override
  DateTime get timestamp;

  /// IP address where action originated
  /// (Masked for privacy: "192.168.1.***")
  @override
  String get ipAddress;

  /// List of metrics affected by this action
  /// (e.g., [MetricType.weight] for "dataAccess" action)
  @override
  List<MetricType>? get affectedMetrics;

  /// Action details (e.g., "Exported 150 measurements to JSON")
  @override
  String? get actionDetails;

  /// Previous log entry hash (for tamper-evidence chain)
  ///
  /// **Integrity Verification**:
  /// - Each log has hash = SHA256(previousHash + userId + action + timestamp)
  /// - First log has previousHash = "GENESIS"
  /// - Chain verification detects tampered/deleted logs
  @override
  String? get previousHash;

  /// Hash of this log entry (SHA256)
  /// Computed as: SHA256(previousHash + userId + action + timestamp)
  @override
  String? get hash;

  /// User agent (browser/app version)
  @override
  String? get userAgent;

  /// Platform (iOS, Android, Web)
  @override
  String? get platform;

  /// App version when action occurred
  @override
  String? get appVersion;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
