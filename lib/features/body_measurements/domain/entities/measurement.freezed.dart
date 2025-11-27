// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Measurement {

/// Unique identifier (UUID v4)
 String get id;/// User ID (Firebase Auth UID)
/// GDPR: Required for data isolation and deletion
 String get userId;/// Type of measurement (weight, body fat, circumference, etc.)
 MetricType get metricType;/// Numeric value of the measurement
/// NOTE: Stored encrypted in data layer (AES-256-GCM)
 double get value;/// Unit of measurement (kg, cm, %, etc.)
/// Defaults to MetricType.defaultUnit
 String get unit;/// When the measurement was taken (user's local time)
/// NOTE: NOT when it was synced to Firestore
 DateTime get timestamp;/// Where the data came from (manual, HealthKit, calculated, etc.)
 MeasurementSource get source;/// Optional user notes (encrypted in data layer)
/// Max length: 500 characters
 String? get notes;/// When this measurement was created in the app
/// Used for sync conflict resolution (latest wins)
 DateTime? get createdAt;/// When this measurement was last modified
/// Used for sync conflict resolution
 DateTime? get updatedAt;/// Whether this measurement is marked for deletion
/// GDPR: Soft-delete with 30-day retention before permanent deletion
 bool get isDeleted;/// When this measurement was soft-deleted (if isDeleted = true)
/// After 30 days from this timestamp, data is permanently deleted
 DateTime? get deletedAt;
/// Create a copy of Measurement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementCopyWith<Measurement> get copyWith => _$MeasurementCopyWithImpl<Measurement>(this as Measurement, _$identity);

  /// Serializes this Measurement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Measurement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.source, source) || other.source == source)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,metricType,value,unit,timestamp,source,notes,createdAt,updatedAt,isDeleted,deletedAt);

@override
String toString() {
  return 'Measurement(id: $id, userId: $userId, metricType: $metricType, value: $value, unit: $unit, timestamp: $timestamp, source: $source, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $MeasurementCopyWith<$Res>  {
  factory $MeasurementCopyWith(Measurement value, $Res Function(Measurement) _then) = _$MeasurementCopyWithImpl;
@useResult
$Res call({
 String id, String userId, MetricType metricType, double value, String unit, DateTime timestamp, MeasurementSource source, String? notes, DateTime? createdAt, DateTime? updatedAt, bool isDeleted, DateTime? deletedAt
});




}
/// @nodoc
class _$MeasurementCopyWithImpl<$Res>
    implements $MeasurementCopyWith<$Res> {
  _$MeasurementCopyWithImpl(this._self, this._then);

  final Measurement _self;
  final $Res Function(Measurement) _then;

/// Create a copy of Measurement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? metricType = null,Object? value = null,Object? unit = null,Object? timestamp = null,Object? source = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isDeleted = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as MetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MeasurementSource,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Measurement].
extension MeasurementPatterns on Measurement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Measurement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Measurement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Measurement value)  $default,){
final _that = this;
switch (_that) {
case _Measurement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Measurement value)?  $default,){
final _that = this;
switch (_that) {
case _Measurement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  MetricType metricType,  double value,  String unit,  DateTime timestamp,  MeasurementSource source,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  bool isDeleted,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Measurement() when $default != null:
return $default(_that.id,_that.userId,_that.metricType,_that.value,_that.unit,_that.timestamp,_that.source,_that.notes,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  MetricType metricType,  double value,  String unit,  DateTime timestamp,  MeasurementSource source,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  bool isDeleted,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Measurement():
return $default(_that.id,_that.userId,_that.metricType,_that.value,_that.unit,_that.timestamp,_that.source,_that.notes,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  MetricType metricType,  double value,  String unit,  DateTime timestamp,  MeasurementSource source,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  bool isDeleted,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Measurement() when $default != null:
return $default(_that.id,_that.userId,_that.metricType,_that.value,_that.unit,_that.timestamp,_that.source,_that.notes,_that.createdAt,_that.updatedAt,_that.isDeleted,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Measurement implements Measurement {
  const _Measurement({required this.id, required this.userId, required this.metricType, required this.value, required this.unit, required this.timestamp, required this.source, this.notes, this.createdAt, this.updatedAt, this.isDeleted = false, this.deletedAt});
  factory _Measurement.fromJson(Map<String, dynamic> json) => _$MeasurementFromJson(json);

/// Unique identifier (UUID v4)
@override final  String id;
/// User ID (Firebase Auth UID)
/// GDPR: Required for data isolation and deletion
@override final  String userId;
/// Type of measurement (weight, body fat, circumference, etc.)
@override final  MetricType metricType;
/// Numeric value of the measurement
/// NOTE: Stored encrypted in data layer (AES-256-GCM)
@override final  double value;
/// Unit of measurement (kg, cm, %, etc.)
/// Defaults to MetricType.defaultUnit
@override final  String unit;
/// When the measurement was taken (user's local time)
/// NOTE: NOT when it was synced to Firestore
@override final  DateTime timestamp;
/// Where the data came from (manual, HealthKit, calculated, etc.)
@override final  MeasurementSource source;
/// Optional user notes (encrypted in data layer)
/// Max length: 500 characters
@override final  String? notes;
/// When this measurement was created in the app
/// Used for sync conflict resolution (latest wins)
@override final  DateTime? createdAt;
/// When this measurement was last modified
/// Used for sync conflict resolution
@override final  DateTime? updatedAt;
/// Whether this measurement is marked for deletion
/// GDPR: Soft-delete with 30-day retention before permanent deletion
@override@JsonKey() final  bool isDeleted;
/// When this measurement was soft-deleted (if isDeleted = true)
/// After 30 days from this timestamp, data is permanently deleted
@override final  DateTime? deletedAt;

/// Create a copy of Measurement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementCopyWith<_Measurement> get copyWith => __$MeasurementCopyWithImpl<_Measurement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Measurement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.source, source) || other.source == source)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,metricType,value,unit,timestamp,source,notes,createdAt,updatedAt,isDeleted,deletedAt);

@override
String toString() {
  return 'Measurement(id: $id, userId: $userId, metricType: $metricType, value: $value, unit: $unit, timestamp: $timestamp, source: $source, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$MeasurementCopyWith<$Res> implements $MeasurementCopyWith<$Res> {
  factory _$MeasurementCopyWith(_Measurement value, $Res Function(_Measurement) _then) = __$MeasurementCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, MetricType metricType, double value, String unit, DateTime timestamp, MeasurementSource source, String? notes, DateTime? createdAt, DateTime? updatedAt, bool isDeleted, DateTime? deletedAt
});




}
/// @nodoc
class __$MeasurementCopyWithImpl<$Res>
    implements _$MeasurementCopyWith<$Res> {
  __$MeasurementCopyWithImpl(this._self, this._then);

  final _Measurement _self;
  final $Res Function(_Measurement) _then;

/// Create a copy of Measurement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? metricType = null,Object? value = null,Object? unit = null,Object? timestamp = null,Object? source = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? isDeleted = null,Object? deletedAt = freezed,}) {
  return _then(_Measurement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as MetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MeasurementSource,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MeasurementMetadata {

/// Device info (anonymized)
/// Example: "iOS 17.2, iPhone 14 Pro"
 String? get deviceInfo;/// App version when measurement was created
/// Example: "1.0.0+49"
 String? get appVersion;/// Sync status (pending, synced, conflict)
 SyncStatus get syncStatus;/// Last sync attempt timestamp
 DateTime? get lastSyncAttempt;/// Sync error message (if sync failed)
 String? get syncError;/// Whether this measurement was validated
 bool get isValidated;/// Validation errors (if any)
 List<String>? get validationErrors;
/// Create a copy of MeasurementMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementMetadataCopyWith<MeasurementMetadata> get copyWith => _$MeasurementMetadataCopyWithImpl<MeasurementMetadata>(this as MeasurementMetadata, _$identity);

  /// Serializes this MeasurementMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementMetadata&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.lastSyncAttempt, lastSyncAttempt) || other.lastSyncAttempt == lastSyncAttempt)&&(identical(other.syncError, syncError) || other.syncError == syncError)&&(identical(other.isValidated, isValidated) || other.isValidated == isValidated)&&const DeepCollectionEquality().equals(other.validationErrors, validationErrors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceInfo,appVersion,syncStatus,lastSyncAttempt,syncError,isValidated,const DeepCollectionEquality().hash(validationErrors));

@override
String toString() {
  return 'MeasurementMetadata(deviceInfo: $deviceInfo, appVersion: $appVersion, syncStatus: $syncStatus, lastSyncAttempt: $lastSyncAttempt, syncError: $syncError, isValidated: $isValidated, validationErrors: $validationErrors)';
}


}

/// @nodoc
abstract mixin class $MeasurementMetadataCopyWith<$Res>  {
  factory $MeasurementMetadataCopyWith(MeasurementMetadata value, $Res Function(MeasurementMetadata) _then) = _$MeasurementMetadataCopyWithImpl;
@useResult
$Res call({
 String? deviceInfo, String? appVersion, SyncStatus syncStatus, DateTime? lastSyncAttempt, String? syncError, bool isValidated, List<String>? validationErrors
});




}
/// @nodoc
class _$MeasurementMetadataCopyWithImpl<$Res>
    implements $MeasurementMetadataCopyWith<$Res> {
  _$MeasurementMetadataCopyWithImpl(this._self, this._then);

  final MeasurementMetadata _self;
  final $Res Function(MeasurementMetadata) _then;

/// Create a copy of MeasurementMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceInfo = freezed,Object? appVersion = freezed,Object? syncStatus = null,Object? lastSyncAttempt = freezed,Object? syncError = freezed,Object? isValidated = null,Object? validationErrors = freezed,}) {
  return _then(_self.copyWith(
deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncAttempt: freezed == lastSyncAttempt ? _self.lastSyncAttempt : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncError: freezed == syncError ? _self.syncError : syncError // ignore: cast_nullable_to_non_nullable
as String?,isValidated: null == isValidated ? _self.isValidated : isValidated // ignore: cast_nullable_to_non_nullable
as bool,validationErrors: freezed == validationErrors ? _self.validationErrors : validationErrors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementMetadata].
extension MeasurementMetadataPatterns on MeasurementMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementMetadata value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? deviceInfo,  String? appVersion,  SyncStatus syncStatus,  DateTime? lastSyncAttempt,  String? syncError,  bool isValidated,  List<String>? validationErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementMetadata() when $default != null:
return $default(_that.deviceInfo,_that.appVersion,_that.syncStatus,_that.lastSyncAttempt,_that.syncError,_that.isValidated,_that.validationErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? deviceInfo,  String? appVersion,  SyncStatus syncStatus,  DateTime? lastSyncAttempt,  String? syncError,  bool isValidated,  List<String>? validationErrors)  $default,) {final _that = this;
switch (_that) {
case _MeasurementMetadata():
return $default(_that.deviceInfo,_that.appVersion,_that.syncStatus,_that.lastSyncAttempt,_that.syncError,_that.isValidated,_that.validationErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? deviceInfo,  String? appVersion,  SyncStatus syncStatus,  DateTime? lastSyncAttempt,  String? syncError,  bool isValidated,  List<String>? validationErrors)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementMetadata() when $default != null:
return $default(_that.deviceInfo,_that.appVersion,_that.syncStatus,_that.lastSyncAttempt,_that.syncError,_that.isValidated,_that.validationErrors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeasurementMetadata implements MeasurementMetadata {
  const _MeasurementMetadata({this.deviceInfo, this.appVersion, this.syncStatus = SyncStatus.pending, this.lastSyncAttempt, this.syncError, this.isValidated = false, final  List<String>? validationErrors}): _validationErrors = validationErrors;
  factory _MeasurementMetadata.fromJson(Map<String, dynamic> json) => _$MeasurementMetadataFromJson(json);

/// Device info (anonymized)
/// Example: "iOS 17.2, iPhone 14 Pro"
@override final  String? deviceInfo;
/// App version when measurement was created
/// Example: "1.0.0+49"
@override final  String? appVersion;
/// Sync status (pending, synced, conflict)
@override@JsonKey() final  SyncStatus syncStatus;
/// Last sync attempt timestamp
@override final  DateTime? lastSyncAttempt;
/// Sync error message (if sync failed)
@override final  String? syncError;
/// Whether this measurement was validated
@override@JsonKey() final  bool isValidated;
/// Validation errors (if any)
 final  List<String>? _validationErrors;
/// Validation errors (if any)
@override List<String>? get validationErrors {
  final value = _validationErrors;
  if (value == null) return null;
  if (_validationErrors is EqualUnmodifiableListView) return _validationErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MeasurementMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementMetadataCopyWith<_MeasurementMetadata> get copyWith => __$MeasurementMetadataCopyWithImpl<_MeasurementMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementMetadata&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.lastSyncAttempt, lastSyncAttempt) || other.lastSyncAttempt == lastSyncAttempt)&&(identical(other.syncError, syncError) || other.syncError == syncError)&&(identical(other.isValidated, isValidated) || other.isValidated == isValidated)&&const DeepCollectionEquality().equals(other._validationErrors, _validationErrors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceInfo,appVersion,syncStatus,lastSyncAttempt,syncError,isValidated,const DeepCollectionEquality().hash(_validationErrors));

@override
String toString() {
  return 'MeasurementMetadata(deviceInfo: $deviceInfo, appVersion: $appVersion, syncStatus: $syncStatus, lastSyncAttempt: $lastSyncAttempt, syncError: $syncError, isValidated: $isValidated, validationErrors: $validationErrors)';
}


}

/// @nodoc
abstract mixin class _$MeasurementMetadataCopyWith<$Res> implements $MeasurementMetadataCopyWith<$Res> {
  factory _$MeasurementMetadataCopyWith(_MeasurementMetadata value, $Res Function(_MeasurementMetadata) _then) = __$MeasurementMetadataCopyWithImpl;
@override @useResult
$Res call({
 String? deviceInfo, String? appVersion, SyncStatus syncStatus, DateTime? lastSyncAttempt, String? syncError, bool isValidated, List<String>? validationErrors
});




}
/// @nodoc
class __$MeasurementMetadataCopyWithImpl<$Res>
    implements _$MeasurementMetadataCopyWith<$Res> {
  __$MeasurementMetadataCopyWithImpl(this._self, this._then);

  final _MeasurementMetadata _self;
  final $Res Function(_MeasurementMetadata) _then;

/// Create a copy of MeasurementMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceInfo = freezed,Object? appVersion = freezed,Object? syncStatus = null,Object? lastSyncAttempt = freezed,Object? syncError = freezed,Object? isValidated = null,Object? validationErrors = freezed,}) {
  return _then(_MeasurementMetadata(
deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncAttempt: freezed == lastSyncAttempt ? _self.lastSyncAttempt : lastSyncAttempt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncError: freezed == syncError ? _self.syncError : syncError // ignore: cast_nullable_to_non_nullable
as String?,isValidated: null == isValidated ? _self.isValidated : isValidated // ignore: cast_nullable_to_non_nullable
as bool,validationErrors: freezed == validationErrors ? _self._validationErrors : validationErrors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
