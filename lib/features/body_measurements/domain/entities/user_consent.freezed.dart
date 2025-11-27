// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_consent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserConsent {

/// Unique consent record ID (UUID v4)
 String get id;/// User ID (Firebase Auth UID)
 String get userId;/// Consent state per metric group (Essential, Measurements, Vitals)
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
 Map<MetricGroup, ConsentState> get groupConsents;/// Privacy policy version accepted by user
///
/// **GDPR**: When privacy policy updates, increment version.
/// Users must re-consent to new policy version.
///
/// Version history:
/// - v1: Initial GDPR-compliant policy (2025-01-24)
/// - v2: Future updates (prompt user to review and re-accept)
 int get consentVersion;/// When consent was granted (user's local time)
 DateTime get acceptedAt;/// IP address when consent was granted
///
/// **GDPR Article 30**: Required for audit trail and compliance proof.
/// Stored masked for privacy (last octet redacted: "192.168.1.***")
 String get ipAddress;/// When Essential metrics consent was granted
/// (Separate timestamp for Just-in-Time consent tracking)
 DateTime? get essentialGrantedAt;/// When Measurements group consent was granted
 DateTime? get measurementsGrantedAt;/// When Vitals group consent was granted
 DateTime? get vitalsGrantedAt;/// When this consent record was created
 DateTime? get createdAt;/// When this consent record was last updated
/// (e.g., user revoked consent for Vitals group)
 DateTime? get updatedAt;/// Whether this consent has been revoked
/// (Soft-delete: keep record for audit trail)
 bool get isRevoked;/// When consent was revoked (if isRevoked = true)
 DateTime? get revokedAt;/// User agent string (browser/app version)
/// Example: "FitLog Pro/1.0.0 iOS/17.2 (iPhone 14 Pro)"
 String? get userAgent;
/// Create a copy of UserConsent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserConsentCopyWith<UserConsent> get copyWith => _$UserConsentCopyWithImpl<UserConsent>(this as UserConsent, _$identity);

  /// Serializes this UserConsent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserConsent&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.groupConsents, groupConsents)&&(identical(other.consentVersion, consentVersion) || other.consentVersion == consentVersion)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.essentialGrantedAt, essentialGrantedAt) || other.essentialGrantedAt == essentialGrantedAt)&&(identical(other.measurementsGrantedAt, measurementsGrantedAt) || other.measurementsGrantedAt == measurementsGrantedAt)&&(identical(other.vitalsGrantedAt, vitalsGrantedAt) || other.vitalsGrantedAt == vitalsGrantedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isRevoked, isRevoked) || other.isRevoked == isRevoked)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(groupConsents),consentVersion,acceptedAt,ipAddress,essentialGrantedAt,measurementsGrantedAt,vitalsGrantedAt,createdAt,updatedAt,isRevoked,revokedAt,userAgent);

@override
String toString() {
  return 'UserConsent(id: $id, userId: $userId, groupConsents: $groupConsents, consentVersion: $consentVersion, acceptedAt: $acceptedAt, ipAddress: $ipAddress, essentialGrantedAt: $essentialGrantedAt, measurementsGrantedAt: $measurementsGrantedAt, vitalsGrantedAt: $vitalsGrantedAt, createdAt: $createdAt, updatedAt: $updatedAt, isRevoked: $isRevoked, revokedAt: $revokedAt, userAgent: $userAgent)';
}


}

/// @nodoc
abstract mixin class $UserConsentCopyWith<$Res>  {
  factory $UserConsentCopyWith(UserConsent value, $Res Function(UserConsent) _then) = _$UserConsentCopyWithImpl;
@useResult
$Res call({
 String id, String userId, Map<MetricGroup, ConsentState> groupConsents, int consentVersion, DateTime acceptedAt, String ipAddress, DateTime? essentialGrantedAt, DateTime? measurementsGrantedAt, DateTime? vitalsGrantedAt, DateTime? createdAt, DateTime? updatedAt, bool isRevoked, DateTime? revokedAt, String? userAgent
});




}
/// @nodoc
class _$UserConsentCopyWithImpl<$Res>
    implements $UserConsentCopyWith<$Res> {
  _$UserConsentCopyWithImpl(this._self, this._then);

  final UserConsent _self;
  final $Res Function(UserConsent) _then;

/// Create a copy of UserConsent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? groupConsents = null,Object? consentVersion = null,Object? acceptedAt = null,Object? ipAddress = null,Object? essentialGrantedAt = freezed,Object? measurementsGrantedAt = freezed,Object? vitalsGrantedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isRevoked = null,Object? revokedAt = freezed,Object? userAgent = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupConsents: null == groupConsents ? _self.groupConsents : groupConsents // ignore: cast_nullable_to_non_nullable
as Map<MetricGroup, ConsentState>,consentVersion: null == consentVersion ? _self.consentVersion : consentVersion // ignore: cast_nullable_to_non_nullable
as int,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,essentialGrantedAt: freezed == essentialGrantedAt ? _self.essentialGrantedAt : essentialGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,measurementsGrantedAt: freezed == measurementsGrantedAt ? _self.measurementsGrantedAt : measurementsGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vitalsGrantedAt: freezed == vitalsGrantedAt ? _self.vitalsGrantedAt : vitalsGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRevoked: null == isRevoked ? _self.isRevoked : isRevoked // ignore: cast_nullable_to_non_nullable
as bool,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserConsent].
extension UserConsentPatterns on UserConsent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserConsent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserConsent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserConsent value)  $default,){
final _that = this;
switch (_that) {
case _UserConsent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserConsent value)?  $default,){
final _that = this;
switch (_that) {
case _UserConsent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  Map<MetricGroup, ConsentState> groupConsents,  int consentVersion,  DateTime acceptedAt,  String ipAddress,  DateTime? essentialGrantedAt,  DateTime? measurementsGrantedAt,  DateTime? vitalsGrantedAt,  DateTime? createdAt,  DateTime? updatedAt,  bool isRevoked,  DateTime? revokedAt,  String? userAgent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserConsent() when $default != null:
return $default(_that.id,_that.userId,_that.groupConsents,_that.consentVersion,_that.acceptedAt,_that.ipAddress,_that.essentialGrantedAt,_that.measurementsGrantedAt,_that.vitalsGrantedAt,_that.createdAt,_that.updatedAt,_that.isRevoked,_that.revokedAt,_that.userAgent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  Map<MetricGroup, ConsentState> groupConsents,  int consentVersion,  DateTime acceptedAt,  String ipAddress,  DateTime? essentialGrantedAt,  DateTime? measurementsGrantedAt,  DateTime? vitalsGrantedAt,  DateTime? createdAt,  DateTime? updatedAt,  bool isRevoked,  DateTime? revokedAt,  String? userAgent)  $default,) {final _that = this;
switch (_that) {
case _UserConsent():
return $default(_that.id,_that.userId,_that.groupConsents,_that.consentVersion,_that.acceptedAt,_that.ipAddress,_that.essentialGrantedAt,_that.measurementsGrantedAt,_that.vitalsGrantedAt,_that.createdAt,_that.updatedAt,_that.isRevoked,_that.revokedAt,_that.userAgent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  Map<MetricGroup, ConsentState> groupConsents,  int consentVersion,  DateTime acceptedAt,  String ipAddress,  DateTime? essentialGrantedAt,  DateTime? measurementsGrantedAt,  DateTime? vitalsGrantedAt,  DateTime? createdAt,  DateTime? updatedAt,  bool isRevoked,  DateTime? revokedAt,  String? userAgent)?  $default,) {final _that = this;
switch (_that) {
case _UserConsent() when $default != null:
return $default(_that.id,_that.userId,_that.groupConsents,_that.consentVersion,_that.acceptedAt,_that.ipAddress,_that.essentialGrantedAt,_that.measurementsGrantedAt,_that.vitalsGrantedAt,_that.createdAt,_that.updatedAt,_that.isRevoked,_that.revokedAt,_that.userAgent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserConsent implements UserConsent {
  const _UserConsent({required this.id, required this.userId, required final  Map<MetricGroup, ConsentState> groupConsents, required this.consentVersion, required this.acceptedAt, required this.ipAddress, this.essentialGrantedAt, this.measurementsGrantedAt, this.vitalsGrantedAt, this.createdAt, this.updatedAt, this.isRevoked = false, this.revokedAt, this.userAgent}): _groupConsents = groupConsents;
  factory _UserConsent.fromJson(Map<String, dynamic> json) => _$UserConsentFromJson(json);

/// Unique consent record ID (UUID v4)
@override final  String id;
/// User ID (Firebase Auth UID)
@override final  String userId;
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
 final  Map<MetricGroup, ConsentState> _groupConsents;
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
@override Map<MetricGroup, ConsentState> get groupConsents {
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
@override final  int consentVersion;
/// When consent was granted (user's local time)
@override final  DateTime acceptedAt;
/// IP address when consent was granted
///
/// **GDPR Article 30**: Required for audit trail and compliance proof.
/// Stored masked for privacy (last octet redacted: "192.168.1.***")
@override final  String ipAddress;
/// When Essential metrics consent was granted
/// (Separate timestamp for Just-in-Time consent tracking)
@override final  DateTime? essentialGrantedAt;
/// When Measurements group consent was granted
@override final  DateTime? measurementsGrantedAt;
/// When Vitals group consent was granted
@override final  DateTime? vitalsGrantedAt;
/// When this consent record was created
@override final  DateTime? createdAt;
/// When this consent record was last updated
/// (e.g., user revoked consent for Vitals group)
@override final  DateTime? updatedAt;
/// Whether this consent has been revoked
/// (Soft-delete: keep record for audit trail)
@override@JsonKey() final  bool isRevoked;
/// When consent was revoked (if isRevoked = true)
@override final  DateTime? revokedAt;
/// User agent string (browser/app version)
/// Example: "FitLog Pro/1.0.0 iOS/17.2 (iPhone 14 Pro)"
@override final  String? userAgent;

/// Create a copy of UserConsent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserConsentCopyWith<_UserConsent> get copyWith => __$UserConsentCopyWithImpl<_UserConsent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserConsentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserConsent&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._groupConsents, _groupConsents)&&(identical(other.consentVersion, consentVersion) || other.consentVersion == consentVersion)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.essentialGrantedAt, essentialGrantedAt) || other.essentialGrantedAt == essentialGrantedAt)&&(identical(other.measurementsGrantedAt, measurementsGrantedAt) || other.measurementsGrantedAt == measurementsGrantedAt)&&(identical(other.vitalsGrantedAt, vitalsGrantedAt) || other.vitalsGrantedAt == vitalsGrantedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isRevoked, isRevoked) || other.isRevoked == isRevoked)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(_groupConsents),consentVersion,acceptedAt,ipAddress,essentialGrantedAt,measurementsGrantedAt,vitalsGrantedAt,createdAt,updatedAt,isRevoked,revokedAt,userAgent);

@override
String toString() {
  return 'UserConsent(id: $id, userId: $userId, groupConsents: $groupConsents, consentVersion: $consentVersion, acceptedAt: $acceptedAt, ipAddress: $ipAddress, essentialGrantedAt: $essentialGrantedAt, measurementsGrantedAt: $measurementsGrantedAt, vitalsGrantedAt: $vitalsGrantedAt, createdAt: $createdAt, updatedAt: $updatedAt, isRevoked: $isRevoked, revokedAt: $revokedAt, userAgent: $userAgent)';
}


}

/// @nodoc
abstract mixin class _$UserConsentCopyWith<$Res> implements $UserConsentCopyWith<$Res> {
  factory _$UserConsentCopyWith(_UserConsent value, $Res Function(_UserConsent) _then) = __$UserConsentCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, Map<MetricGroup, ConsentState> groupConsents, int consentVersion, DateTime acceptedAt, String ipAddress, DateTime? essentialGrantedAt, DateTime? measurementsGrantedAt, DateTime? vitalsGrantedAt, DateTime? createdAt, DateTime? updatedAt, bool isRevoked, DateTime? revokedAt, String? userAgent
});




}
/// @nodoc
class __$UserConsentCopyWithImpl<$Res>
    implements _$UserConsentCopyWith<$Res> {
  __$UserConsentCopyWithImpl(this._self, this._then);

  final _UserConsent _self;
  final $Res Function(_UserConsent) _then;

/// Create a copy of UserConsent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? groupConsents = null,Object? consentVersion = null,Object? acceptedAt = null,Object? ipAddress = null,Object? essentialGrantedAt = freezed,Object? measurementsGrantedAt = freezed,Object? vitalsGrantedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isRevoked = null,Object? revokedAt = freezed,Object? userAgent = freezed,}) {
  return _then(_UserConsent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupConsents: null == groupConsents ? _self._groupConsents : groupConsents // ignore: cast_nullable_to_non_nullable
as Map<MetricGroup, ConsentState>,consentVersion: null == consentVersion ? _self.consentVersion : consentVersion // ignore: cast_nullable_to_non_nullable
as int,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,essentialGrantedAt: freezed == essentialGrantedAt ? _self.essentialGrantedAt : essentialGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,measurementsGrantedAt: freezed == measurementsGrantedAt ? _self.measurementsGrantedAt : measurementsGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vitalsGrantedAt: freezed == vitalsGrantedAt ? _self.vitalsGrantedAt : vitalsGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRevoked: null == isRevoked ? _self.isRevoked : isRevoked // ignore: cast_nullable_to_non_nullable
as bool,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AuditLog {

/// Unique audit log ID (UUID v4)
 String get id;/// User ID (Firebase Auth UID)
 String get userId;/// Action that was performed
 AuditAction get action;/// When action occurred (UTC timestamp)
 DateTime get timestamp;/// IP address where action originated
/// (Masked for privacy: "192.168.1.***")
 String get ipAddress;/// List of metrics affected by this action
/// (e.g., [MetricType.weight] for "dataAccess" action)
 List<MetricType>? get affectedMetrics;/// Action details (e.g., "Exported 150 measurements to JSON")
 String? get actionDetails;/// Previous log entry hash (for tamper-evidence chain)
///
/// **Integrity Verification**:
/// - Each log has hash = SHA256(previousHash + userId + action + timestamp)
/// - First log has previousHash = "GENESIS"
/// - Chain verification detects tampered/deleted logs
 String? get previousHash;/// Hash of this log entry (SHA256)
/// Computed as: SHA256(previousHash + userId + action + timestamp)
 String? get hash;/// User agent (browser/app version)
 String? get userAgent;/// Platform (iOS, Android, Web)
 String? get platform;/// App version when action occurred
 String? get appVersion;
/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogCopyWith<AuditLog> get copyWith => _$AuditLogCopyWithImpl<AuditLog>(this as AuditLog, _$identity);

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.action, action) || other.action == action)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&const DeepCollectionEquality().equals(other.affectedMetrics, affectedMetrics)&&(identical(other.actionDetails, actionDetails) || other.actionDetails == actionDetails)&&(identical(other.previousHash, previousHash) || other.previousHash == previousHash)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,action,timestamp,ipAddress,const DeepCollectionEquality().hash(affectedMetrics),actionDetails,previousHash,hash,userAgent,platform,appVersion);

@override
String toString() {
  return 'AuditLog(id: $id, userId: $userId, action: $action, timestamp: $timestamp, ipAddress: $ipAddress, affectedMetrics: $affectedMetrics, actionDetails: $actionDetails, previousHash: $previousHash, hash: $hash, userAgent: $userAgent, platform: $platform, appVersion: $appVersion)';
}


}

/// @nodoc
abstract mixin class $AuditLogCopyWith<$Res>  {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) _then) = _$AuditLogCopyWithImpl;
@useResult
$Res call({
 String id, String userId, AuditAction action, DateTime timestamp, String ipAddress, List<MetricType>? affectedMetrics, String? actionDetails, String? previousHash, String? hash, String? userAgent, String? platform, String? appVersion
});




}
/// @nodoc
class _$AuditLogCopyWithImpl<$Res>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._self, this._then);

  final AuditLog _self;
  final $Res Function(AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? action = null,Object? timestamp = null,Object? ipAddress = null,Object? affectedMetrics = freezed,Object? actionDetails = freezed,Object? previousHash = freezed,Object? hash = freezed,Object? userAgent = freezed,Object? platform = freezed,Object? appVersion = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,affectedMetrics: freezed == affectedMetrics ? _self.affectedMetrics : affectedMetrics // ignore: cast_nullable_to_non_nullable
as List<MetricType>?,actionDetails: freezed == actionDetails ? _self.actionDetails : actionDetails // ignore: cast_nullable_to_non_nullable
as String?,previousHash: freezed == previousHash ? _self.previousHash : previousHash // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLog].
extension AuditLogPatterns on AuditLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLog value)  $default,){
final _that = this;
switch (_that) {
case _AuditLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLog value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  AuditAction action,  DateTime timestamp,  String ipAddress,  List<MetricType>? affectedMetrics,  String? actionDetails,  String? previousHash,  String? hash,  String? userAgent,  String? platform,  String? appVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.userId,_that.action,_that.timestamp,_that.ipAddress,_that.affectedMetrics,_that.actionDetails,_that.previousHash,_that.hash,_that.userAgent,_that.platform,_that.appVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  AuditAction action,  DateTime timestamp,  String ipAddress,  List<MetricType>? affectedMetrics,  String? actionDetails,  String? previousHash,  String? hash,  String? userAgent,  String? platform,  String? appVersion)  $default,) {final _that = this;
switch (_that) {
case _AuditLog():
return $default(_that.id,_that.userId,_that.action,_that.timestamp,_that.ipAddress,_that.affectedMetrics,_that.actionDetails,_that.previousHash,_that.hash,_that.userAgent,_that.platform,_that.appVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  AuditAction action,  DateTime timestamp,  String ipAddress,  List<MetricType>? affectedMetrics,  String? actionDetails,  String? previousHash,  String? hash,  String? userAgent,  String? platform,  String? appVersion)?  $default,) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.userId,_that.action,_that.timestamp,_that.ipAddress,_that.affectedMetrics,_that.actionDetails,_that.previousHash,_that.hash,_that.userAgent,_that.platform,_that.appVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLog implements AuditLog {
  const _AuditLog({required this.id, required this.userId, required this.action, required this.timestamp, required this.ipAddress, final  List<MetricType>? affectedMetrics, this.actionDetails, this.previousHash, this.hash, this.userAgent, this.platform, this.appVersion}): _affectedMetrics = affectedMetrics;
  factory _AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);

/// Unique audit log ID (UUID v4)
@override final  String id;
/// User ID (Firebase Auth UID)
@override final  String userId;
/// Action that was performed
@override final  AuditAction action;
/// When action occurred (UTC timestamp)
@override final  DateTime timestamp;
/// IP address where action originated
/// (Masked for privacy: "192.168.1.***")
@override final  String ipAddress;
/// List of metrics affected by this action
/// (e.g., [MetricType.weight] for "dataAccess" action)
 final  List<MetricType>? _affectedMetrics;
/// List of metrics affected by this action
/// (e.g., [MetricType.weight] for "dataAccess" action)
@override List<MetricType>? get affectedMetrics {
  final value = _affectedMetrics;
  if (value == null) return null;
  if (_affectedMetrics is EqualUnmodifiableListView) return _affectedMetrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Action details (e.g., "Exported 150 measurements to JSON")
@override final  String? actionDetails;
/// Previous log entry hash (for tamper-evidence chain)
///
/// **Integrity Verification**:
/// - Each log has hash = SHA256(previousHash + userId + action + timestamp)
/// - First log has previousHash = "GENESIS"
/// - Chain verification detects tampered/deleted logs
@override final  String? previousHash;
/// Hash of this log entry (SHA256)
/// Computed as: SHA256(previousHash + userId + action + timestamp)
@override final  String? hash;
/// User agent (browser/app version)
@override final  String? userAgent;
/// Platform (iOS, Android, Web)
@override final  String? platform;
/// App version when action occurred
@override final  String? appVersion;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogCopyWith<_AuditLog> get copyWith => __$AuditLogCopyWithImpl<_AuditLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.action, action) || other.action == action)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&const DeepCollectionEquality().equals(other._affectedMetrics, _affectedMetrics)&&(identical(other.actionDetails, actionDetails) || other.actionDetails == actionDetails)&&(identical(other.previousHash, previousHash) || other.previousHash == previousHash)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,action,timestamp,ipAddress,const DeepCollectionEquality().hash(_affectedMetrics),actionDetails,previousHash,hash,userAgent,platform,appVersion);

@override
String toString() {
  return 'AuditLog(id: $id, userId: $userId, action: $action, timestamp: $timestamp, ipAddress: $ipAddress, affectedMetrics: $affectedMetrics, actionDetails: $actionDetails, previousHash: $previousHash, hash: $hash, userAgent: $userAgent, platform: $platform, appVersion: $appVersion)';
}


}

/// @nodoc
abstract mixin class _$AuditLogCopyWith<$Res> implements $AuditLogCopyWith<$Res> {
  factory _$AuditLogCopyWith(_AuditLog value, $Res Function(_AuditLog) _then) = __$AuditLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, AuditAction action, DateTime timestamp, String ipAddress, List<MetricType>? affectedMetrics, String? actionDetails, String? previousHash, String? hash, String? userAgent, String? platform, String? appVersion
});




}
/// @nodoc
class __$AuditLogCopyWithImpl<$Res>
    implements _$AuditLogCopyWith<$Res> {
  __$AuditLogCopyWithImpl(this._self, this._then);

  final _AuditLog _self;
  final $Res Function(_AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? action = null,Object? timestamp = null,Object? ipAddress = null,Object? affectedMetrics = freezed,Object? actionDetails = freezed,Object? previousHash = freezed,Object? hash = freezed,Object? userAgent = freezed,Object? platform = freezed,Object? appVersion = freezed,}) {
  return _then(_AuditLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,affectedMetrics: freezed == affectedMetrics ? _self._affectedMetrics : affectedMetrics // ignore: cast_nullable_to_non_nullable
as List<MetricType>?,actionDetails: freezed == actionDetails ? _self.actionDetails : actionDetails // ignore: cast_nullable_to_non_nullable
as String?,previousHash: freezed == previousHash ? _self.previousHash : previousHash // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
