// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encrypted_measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EncryptedMeasurement {

/// Measurement ID (same as original Measurement.id)
 String get id;/// User ID (Firebase Auth UID)
 String get userId;/// Metric type (stored unencrypted for querying)
///
/// **Note**: MetricType is NOT sensitive PII, safe to store unencrypted.
/// Allows efficient Firestore queries: "Get all weight measurements"
 String get metricType;/// Encrypted measurement data (base64 encoded)
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
 String get encryptedData;/// Initialization Vector (base64 encoded)
///
/// **IV**: Randomly generated 12 bytes for AES-GCM.
/// Must be unique per encryption operation (never reuse with same key).
 String get iv;/// Authentication tag (base64 encoded)
///
/// **Tag**: 16-byte GCM tag for data integrity verification.
/// Prevents tampering (decryption fails if data modified).
 String get tag;/// Timestamp (stored unencrypted for sorting/filtering)
///
/// **Note**: Timestamp is NOT sensitive PII, safe to store unencrypted.
/// Allows efficient queries: "Get measurements from last 30 days"
 DateTime get timestamp;/// When this encrypted measurement was created
 DateTime? get createdAt;/// When this encrypted measurement was last updated
 DateTime? get updatedAt;
/// Create a copy of EncryptedMeasurement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncryptedMeasurementCopyWith<EncryptedMeasurement> get copyWith => _$EncryptedMeasurementCopyWithImpl<EncryptedMeasurement>(this as EncryptedMeasurement, _$identity);

  /// Serializes this EncryptedMeasurement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncryptedMeasurement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.encryptedData, encryptedData) || other.encryptedData == encryptedData)&&(identical(other.iv, iv) || other.iv == iv)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,metricType,encryptedData,iv,tag,timestamp,createdAt,updatedAt);

@override
String toString() {
  return 'EncryptedMeasurement(id: $id, userId: $userId, metricType: $metricType, encryptedData: $encryptedData, iv: $iv, tag: $tag, timestamp: $timestamp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EncryptedMeasurementCopyWith<$Res>  {
  factory $EncryptedMeasurementCopyWith(EncryptedMeasurement value, $Res Function(EncryptedMeasurement) _then) = _$EncryptedMeasurementCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String metricType, String encryptedData, String iv, String tag, DateTime timestamp, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$EncryptedMeasurementCopyWithImpl<$Res>
    implements $EncryptedMeasurementCopyWith<$Res> {
  _$EncryptedMeasurementCopyWithImpl(this._self, this._then);

  final EncryptedMeasurement _self;
  final $Res Function(EncryptedMeasurement) _then;

/// Create a copy of EncryptedMeasurement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? metricType = null,Object? encryptedData = null,Object? iv = null,Object? tag = null,Object? timestamp = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as String,encryptedData: null == encryptedData ? _self.encryptedData : encryptedData // ignore: cast_nullable_to_non_nullable
as String,iv: null == iv ? _self.iv : iv // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EncryptedMeasurement].
extension EncryptedMeasurementPatterns on EncryptedMeasurement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncryptedMeasurement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptedMeasurement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncryptedMeasurement value)  $default,){
final _that = this;
switch (_that) {
case _EncryptedMeasurement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncryptedMeasurement value)?  $default,){
final _that = this;
switch (_that) {
case _EncryptedMeasurement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String metricType,  String encryptedData,  String iv,  String tag,  DateTime timestamp,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptedMeasurement() when $default != null:
return $default(_that.id,_that.userId,_that.metricType,_that.encryptedData,_that.iv,_that.tag,_that.timestamp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String metricType,  String encryptedData,  String iv,  String tag,  DateTime timestamp,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EncryptedMeasurement():
return $default(_that.id,_that.userId,_that.metricType,_that.encryptedData,_that.iv,_that.tag,_that.timestamp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String metricType,  String encryptedData,  String iv,  String tag,  DateTime timestamp,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EncryptedMeasurement() when $default != null:
return $default(_that.id,_that.userId,_that.metricType,_that.encryptedData,_that.iv,_that.tag,_that.timestamp,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncryptedMeasurement implements EncryptedMeasurement {
  const _EncryptedMeasurement({required this.id, required this.userId, required this.metricType, required this.encryptedData, required this.iv, required this.tag, required this.timestamp, this.createdAt, this.updatedAt});
  factory _EncryptedMeasurement.fromJson(Map<String, dynamic> json) => _$EncryptedMeasurementFromJson(json);

/// Measurement ID (same as original Measurement.id)
@override final  String id;
/// User ID (Firebase Auth UID)
@override final  String userId;
/// Metric type (stored unencrypted for querying)
///
/// **Note**: MetricType is NOT sensitive PII, safe to store unencrypted.
/// Allows efficient Firestore queries: "Get all weight measurements"
@override final  String metricType;
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
@override final  String encryptedData;
/// Initialization Vector (base64 encoded)
///
/// **IV**: Randomly generated 12 bytes for AES-GCM.
/// Must be unique per encryption operation (never reuse with same key).
@override final  String iv;
/// Authentication tag (base64 encoded)
///
/// **Tag**: 16-byte GCM tag for data integrity verification.
/// Prevents tampering (decryption fails if data modified).
@override final  String tag;
/// Timestamp (stored unencrypted for sorting/filtering)
///
/// **Note**: Timestamp is NOT sensitive PII, safe to store unencrypted.
/// Allows efficient queries: "Get measurements from last 30 days"
@override final  DateTime timestamp;
/// When this encrypted measurement was created
@override final  DateTime? createdAt;
/// When this encrypted measurement was last updated
@override final  DateTime? updatedAt;

/// Create a copy of EncryptedMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptedMeasurementCopyWith<_EncryptedMeasurement> get copyWith => __$EncryptedMeasurementCopyWithImpl<_EncryptedMeasurement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncryptedMeasurementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncryptedMeasurement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.encryptedData, encryptedData) || other.encryptedData == encryptedData)&&(identical(other.iv, iv) || other.iv == iv)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,metricType,encryptedData,iv,tag,timestamp,createdAt,updatedAt);

@override
String toString() {
  return 'EncryptedMeasurement(id: $id, userId: $userId, metricType: $metricType, encryptedData: $encryptedData, iv: $iv, tag: $tag, timestamp: $timestamp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EncryptedMeasurementCopyWith<$Res> implements $EncryptedMeasurementCopyWith<$Res> {
  factory _$EncryptedMeasurementCopyWith(_EncryptedMeasurement value, $Res Function(_EncryptedMeasurement) _then) = __$EncryptedMeasurementCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String metricType, String encryptedData, String iv, String tag, DateTime timestamp, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$EncryptedMeasurementCopyWithImpl<$Res>
    implements _$EncryptedMeasurementCopyWith<$Res> {
  __$EncryptedMeasurementCopyWithImpl(this._self, this._then);

  final _EncryptedMeasurement _self;
  final $Res Function(_EncryptedMeasurement) _then;

/// Create a copy of EncryptedMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? metricType = null,Object? encryptedData = null,Object? iv = null,Object? tag = null,Object? timestamp = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_EncryptedMeasurement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as String,encryptedData: null == encryptedData ? _self.encryptedData : encryptedData // ignore: cast_nullable_to_non_nullable
as String,iv: null == iv ? _self.iv : iv // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EncryptionMetadata {

/// Encryption key version (incremented on key rotation)
///
/// **Key Rotation**: Every 90 days or on-demand.
/// Old encrypted data is re-encrypted with new key.
 int get keyVersion;/// When encryption key was generated
 DateTime get keyGeneratedAt;/// When encryption key was last rotated
 DateTime? get keyLastRotated;/// Next scheduled key rotation date
 DateTime? get keyRotationScheduled;/// Encryption algorithm used
/// Default: "AES-256-GCM"
 String get algorithm;/// Key derivation function (if applicable)
/// Example: "PBKDF2-SHA256" for password-derived keys
 String? get keyDerivationFunction;
/// Create a copy of EncryptionMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncryptionMetadataCopyWith<EncryptionMetadata> get copyWith => _$EncryptionMetadataCopyWithImpl<EncryptionMetadata>(this as EncryptionMetadata, _$identity);

  /// Serializes this EncryptionMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncryptionMetadata&&(identical(other.keyVersion, keyVersion) || other.keyVersion == keyVersion)&&(identical(other.keyGeneratedAt, keyGeneratedAt) || other.keyGeneratedAt == keyGeneratedAt)&&(identical(other.keyLastRotated, keyLastRotated) || other.keyLastRotated == keyLastRotated)&&(identical(other.keyRotationScheduled, keyRotationScheduled) || other.keyRotationScheduled == keyRotationScheduled)&&(identical(other.algorithm, algorithm) || other.algorithm == algorithm)&&(identical(other.keyDerivationFunction, keyDerivationFunction) || other.keyDerivationFunction == keyDerivationFunction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,keyVersion,keyGeneratedAt,keyLastRotated,keyRotationScheduled,algorithm,keyDerivationFunction);

@override
String toString() {
  return 'EncryptionMetadata(keyVersion: $keyVersion, keyGeneratedAt: $keyGeneratedAt, keyLastRotated: $keyLastRotated, keyRotationScheduled: $keyRotationScheduled, algorithm: $algorithm, keyDerivationFunction: $keyDerivationFunction)';
}


}

/// @nodoc
abstract mixin class $EncryptionMetadataCopyWith<$Res>  {
  factory $EncryptionMetadataCopyWith(EncryptionMetadata value, $Res Function(EncryptionMetadata) _then) = _$EncryptionMetadataCopyWithImpl;
@useResult
$Res call({
 int keyVersion, DateTime keyGeneratedAt, DateTime? keyLastRotated, DateTime? keyRotationScheduled, String algorithm, String? keyDerivationFunction
});




}
/// @nodoc
class _$EncryptionMetadataCopyWithImpl<$Res>
    implements $EncryptionMetadataCopyWith<$Res> {
  _$EncryptionMetadataCopyWithImpl(this._self, this._then);

  final EncryptionMetadata _self;
  final $Res Function(EncryptionMetadata) _then;

/// Create a copy of EncryptionMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyVersion = null,Object? keyGeneratedAt = null,Object? keyLastRotated = freezed,Object? keyRotationScheduled = freezed,Object? algorithm = null,Object? keyDerivationFunction = freezed,}) {
  return _then(_self.copyWith(
keyVersion: null == keyVersion ? _self.keyVersion : keyVersion // ignore: cast_nullable_to_non_nullable
as int,keyGeneratedAt: null == keyGeneratedAt ? _self.keyGeneratedAt : keyGeneratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,keyLastRotated: freezed == keyLastRotated ? _self.keyLastRotated : keyLastRotated // ignore: cast_nullable_to_non_nullable
as DateTime?,keyRotationScheduled: freezed == keyRotationScheduled ? _self.keyRotationScheduled : keyRotationScheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,algorithm: null == algorithm ? _self.algorithm : algorithm // ignore: cast_nullable_to_non_nullable
as String,keyDerivationFunction: freezed == keyDerivationFunction ? _self.keyDerivationFunction : keyDerivationFunction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EncryptionMetadata].
extension EncryptionMetadataPatterns on EncryptionMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncryptionMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptionMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncryptionMetadata value)  $default,){
final _that = this;
switch (_that) {
case _EncryptionMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncryptionMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _EncryptionMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int keyVersion,  DateTime keyGeneratedAt,  DateTime? keyLastRotated,  DateTime? keyRotationScheduled,  String algorithm,  String? keyDerivationFunction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptionMetadata() when $default != null:
return $default(_that.keyVersion,_that.keyGeneratedAt,_that.keyLastRotated,_that.keyRotationScheduled,_that.algorithm,_that.keyDerivationFunction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int keyVersion,  DateTime keyGeneratedAt,  DateTime? keyLastRotated,  DateTime? keyRotationScheduled,  String algorithm,  String? keyDerivationFunction)  $default,) {final _that = this;
switch (_that) {
case _EncryptionMetadata():
return $default(_that.keyVersion,_that.keyGeneratedAt,_that.keyLastRotated,_that.keyRotationScheduled,_that.algorithm,_that.keyDerivationFunction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int keyVersion,  DateTime keyGeneratedAt,  DateTime? keyLastRotated,  DateTime? keyRotationScheduled,  String algorithm,  String? keyDerivationFunction)?  $default,) {final _that = this;
switch (_that) {
case _EncryptionMetadata() when $default != null:
return $default(_that.keyVersion,_that.keyGeneratedAt,_that.keyLastRotated,_that.keyRotationScheduled,_that.algorithm,_that.keyDerivationFunction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncryptionMetadata implements EncryptionMetadata {
  const _EncryptionMetadata({required this.keyVersion, required this.keyGeneratedAt, this.keyLastRotated, this.keyRotationScheduled, this.algorithm = 'AES-256-GCM', this.keyDerivationFunction});
  factory _EncryptionMetadata.fromJson(Map<String, dynamic> json) => _$EncryptionMetadataFromJson(json);

/// Encryption key version (incremented on key rotation)
///
/// **Key Rotation**: Every 90 days or on-demand.
/// Old encrypted data is re-encrypted with new key.
@override final  int keyVersion;
/// When encryption key was generated
@override final  DateTime keyGeneratedAt;
/// When encryption key was last rotated
@override final  DateTime? keyLastRotated;
/// Next scheduled key rotation date
@override final  DateTime? keyRotationScheduled;
/// Encryption algorithm used
/// Default: "AES-256-GCM"
@override@JsonKey() final  String algorithm;
/// Key derivation function (if applicable)
/// Example: "PBKDF2-SHA256" for password-derived keys
@override final  String? keyDerivationFunction;

/// Create a copy of EncryptionMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptionMetadataCopyWith<_EncryptionMetadata> get copyWith => __$EncryptionMetadataCopyWithImpl<_EncryptionMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncryptionMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncryptionMetadata&&(identical(other.keyVersion, keyVersion) || other.keyVersion == keyVersion)&&(identical(other.keyGeneratedAt, keyGeneratedAt) || other.keyGeneratedAt == keyGeneratedAt)&&(identical(other.keyLastRotated, keyLastRotated) || other.keyLastRotated == keyLastRotated)&&(identical(other.keyRotationScheduled, keyRotationScheduled) || other.keyRotationScheduled == keyRotationScheduled)&&(identical(other.algorithm, algorithm) || other.algorithm == algorithm)&&(identical(other.keyDerivationFunction, keyDerivationFunction) || other.keyDerivationFunction == keyDerivationFunction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,keyVersion,keyGeneratedAt,keyLastRotated,keyRotationScheduled,algorithm,keyDerivationFunction);

@override
String toString() {
  return 'EncryptionMetadata(keyVersion: $keyVersion, keyGeneratedAt: $keyGeneratedAt, keyLastRotated: $keyLastRotated, keyRotationScheduled: $keyRotationScheduled, algorithm: $algorithm, keyDerivationFunction: $keyDerivationFunction)';
}


}

/// @nodoc
abstract mixin class _$EncryptionMetadataCopyWith<$Res> implements $EncryptionMetadataCopyWith<$Res> {
  factory _$EncryptionMetadataCopyWith(_EncryptionMetadata value, $Res Function(_EncryptionMetadata) _then) = __$EncryptionMetadataCopyWithImpl;
@override @useResult
$Res call({
 int keyVersion, DateTime keyGeneratedAt, DateTime? keyLastRotated, DateTime? keyRotationScheduled, String algorithm, String? keyDerivationFunction
});




}
/// @nodoc
class __$EncryptionMetadataCopyWithImpl<$Res>
    implements _$EncryptionMetadataCopyWith<$Res> {
  __$EncryptionMetadataCopyWithImpl(this._self, this._then);

  final _EncryptionMetadata _self;
  final $Res Function(_EncryptionMetadata) _then;

/// Create a copy of EncryptionMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyVersion = null,Object? keyGeneratedAt = null,Object? keyLastRotated = freezed,Object? keyRotationScheduled = freezed,Object? algorithm = null,Object? keyDerivationFunction = freezed,}) {
  return _then(_EncryptionMetadata(
keyVersion: null == keyVersion ? _self.keyVersion : keyVersion // ignore: cast_nullable_to_non_nullable
as int,keyGeneratedAt: null == keyGeneratedAt ? _self.keyGeneratedAt : keyGeneratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,keyLastRotated: freezed == keyLastRotated ? _self.keyLastRotated : keyLastRotated // ignore: cast_nullable_to_non_nullable
as DateTime?,keyRotationScheduled: freezed == keyRotationScheduled ? _self.keyRotationScheduled : keyRotationScheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,algorithm: null == algorithm ? _self.algorithm : algorithm // ignore: cast_nullable_to_non_nullable
as String,keyDerivationFunction: freezed == keyDerivationFunction ? _self.keyDerivationFunction : keyDerivationFunction // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
