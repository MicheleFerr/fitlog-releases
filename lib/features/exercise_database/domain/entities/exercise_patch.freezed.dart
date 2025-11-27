// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_patch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExercisePatch {

/// Unique patch ID (Firestore document ID)
 String get id;/// ID of the exercise being patched
 String get exerciseId;/// User ID who submitted the patch
 String get userId;/// Name of the field being modified (e.g., "nome", "difficolta", "noteTecniche")
 String get fieldName;/// Original value before user's modification (from Firestore)
 dynamic get oldValue;/// New value proposed by user
 dynamic get newValue;/// Server value at time of patch creation (for conflict detection)
/// If this differs from current Firestore value, patch is stale
 dynamic get originalValue;/// User's explanation for the change (required, min 10 chars)
 String get reason;/// Current status of the patch
 PatchStatus get status;/// Language version ('it' or 'en')
 String get language;/// When patch was created
 DateTime get createdAt;/// When patch will expire (createdAt + 30 days)
 DateTime get expiresAt;/// Exercise version at time of patch creation
/// Used to detect if exercise was updated before patch approval
 int get version;/// When patch was approved (null if not approved)
 DateTime? get approvedAt;/// Admin user ID who approved the patch
 String? get approvedBy;/// When patch was rejected (null if not rejected)
 DateTime? get rejectedAt;/// Reason for rejection (null if approved or pending)
 String? get rejectReason;/// Additional notes from admin
 String? get adminNote;/// Whether patch was auto-expired by TTL cleanup (Cloud Function)
 bool get autoExpired;/// User email (for admin notification)
 String? get userEmail;/// User display name (for admin UI)
 String? get userDisplayName;
/// Create a copy of ExercisePatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExercisePatchCopyWith<ExercisePatch> get copyWith => _$ExercisePatchCopyWithImpl<ExercisePatch>(this as ExercisePatch, _$identity);

  /// Serializes this ExercisePatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExercisePatch&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fieldName, fieldName) || other.fieldName == fieldName)&&const DeepCollectionEquality().equals(other.oldValue, oldValue)&&const DeepCollectionEquality().equals(other.newValue, newValue)&&const DeepCollectionEquality().equals(other.originalValue, originalValue)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.rejectedAt, rejectedAt) || other.rejectedAt == rejectedAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.autoExpired, autoExpired) || other.autoExpired == autoExpired)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,userId,fieldName,const DeepCollectionEquality().hash(oldValue),const DeepCollectionEquality().hash(newValue),const DeepCollectionEquality().hash(originalValue),reason,status,language,createdAt,expiresAt,version,approvedAt,approvedBy,rejectedAt,rejectReason,adminNote,autoExpired,userEmail,userDisplayName]);

@override
String toString() {
  return 'ExercisePatch(id: $id, exerciseId: $exerciseId, userId: $userId, fieldName: $fieldName, oldValue: $oldValue, newValue: $newValue, originalValue: $originalValue, reason: $reason, status: $status, language: $language, createdAt: $createdAt, expiresAt: $expiresAt, version: $version, approvedAt: $approvedAt, approvedBy: $approvedBy, rejectedAt: $rejectedAt, rejectReason: $rejectReason, adminNote: $adminNote, autoExpired: $autoExpired, userEmail: $userEmail, userDisplayName: $userDisplayName)';
}


}

/// @nodoc
abstract mixin class $ExercisePatchCopyWith<$Res>  {
  factory $ExercisePatchCopyWith(ExercisePatch value, $Res Function(ExercisePatch) _then) = _$ExercisePatchCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String userId, String fieldName, dynamic oldValue, dynamic newValue, dynamic originalValue, String reason, PatchStatus status, String language, DateTime createdAt, DateTime expiresAt, int version, DateTime? approvedAt, String? approvedBy, DateTime? rejectedAt, String? rejectReason, String? adminNote, bool autoExpired, String? userEmail, String? userDisplayName
});




}
/// @nodoc
class _$ExercisePatchCopyWithImpl<$Res>
    implements $ExercisePatchCopyWith<$Res> {
  _$ExercisePatchCopyWithImpl(this._self, this._then);

  final ExercisePatch _self;
  final $Res Function(ExercisePatch) _then;

/// Create a copy of ExercisePatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? userId = null,Object? fieldName = null,Object? oldValue = freezed,Object? newValue = freezed,Object? originalValue = freezed,Object? reason = null,Object? status = null,Object? language = null,Object? createdAt = null,Object? expiresAt = null,Object? version = null,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? rejectedAt = freezed,Object? rejectReason = freezed,Object? adminNote = freezed,Object? autoExpired = null,Object? userEmail = freezed,Object? userDisplayName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fieldName: null == fieldName ? _self.fieldName : fieldName // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as dynamic,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as dynamic,originalValue: freezed == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as dynamic,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PatchStatus,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,autoExpired: null == autoExpired ? _self.autoExpired : autoExpired // ignore: cast_nullable_to_non_nullable
as bool,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExercisePatch].
extension ExercisePatchPatterns on ExercisePatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExercisePatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExercisePatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExercisePatch value)  $default,){
final _that = this;
switch (_that) {
case _ExercisePatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExercisePatch value)?  $default,){
final _that = this;
switch (_that) {
case _ExercisePatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String userId,  String fieldName,  dynamic oldValue,  dynamic newValue,  dynamic originalValue,  String reason,  PatchStatus status,  String language,  DateTime createdAt,  DateTime expiresAt,  int version,  DateTime? approvedAt,  String? approvedBy,  DateTime? rejectedAt,  String? rejectReason,  String? adminNote,  bool autoExpired,  String? userEmail,  String? userDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExercisePatch() when $default != null:
return $default(_that.id,_that.exerciseId,_that.userId,_that.fieldName,_that.oldValue,_that.newValue,_that.originalValue,_that.reason,_that.status,_that.language,_that.createdAt,_that.expiresAt,_that.version,_that.approvedAt,_that.approvedBy,_that.rejectedAt,_that.rejectReason,_that.adminNote,_that.autoExpired,_that.userEmail,_that.userDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String userId,  String fieldName,  dynamic oldValue,  dynamic newValue,  dynamic originalValue,  String reason,  PatchStatus status,  String language,  DateTime createdAt,  DateTime expiresAt,  int version,  DateTime? approvedAt,  String? approvedBy,  DateTime? rejectedAt,  String? rejectReason,  String? adminNote,  bool autoExpired,  String? userEmail,  String? userDisplayName)  $default,) {final _that = this;
switch (_that) {
case _ExercisePatch():
return $default(_that.id,_that.exerciseId,_that.userId,_that.fieldName,_that.oldValue,_that.newValue,_that.originalValue,_that.reason,_that.status,_that.language,_that.createdAt,_that.expiresAt,_that.version,_that.approvedAt,_that.approvedBy,_that.rejectedAt,_that.rejectReason,_that.adminNote,_that.autoExpired,_that.userEmail,_that.userDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String userId,  String fieldName,  dynamic oldValue,  dynamic newValue,  dynamic originalValue,  String reason,  PatchStatus status,  String language,  DateTime createdAt,  DateTime expiresAt,  int version,  DateTime? approvedAt,  String? approvedBy,  DateTime? rejectedAt,  String? rejectReason,  String? adminNote,  bool autoExpired,  String? userEmail,  String? userDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _ExercisePatch() when $default != null:
return $default(_that.id,_that.exerciseId,_that.userId,_that.fieldName,_that.oldValue,_that.newValue,_that.originalValue,_that.reason,_that.status,_that.language,_that.createdAt,_that.expiresAt,_that.version,_that.approvedAt,_that.approvedBy,_that.rejectedAt,_that.rejectReason,_that.adminNote,_that.autoExpired,_that.userEmail,_that.userDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExercisePatch implements ExercisePatch {
  const _ExercisePatch({required this.id, required this.exerciseId, required this.userId, required this.fieldName, required this.oldValue, required this.newValue, required this.originalValue, required this.reason, required this.status, required this.language, required this.createdAt, required this.expiresAt, required this.version, this.approvedAt, this.approvedBy, this.rejectedAt, this.rejectReason, this.adminNote, this.autoExpired = false, this.userEmail, this.userDisplayName});
  factory _ExercisePatch.fromJson(Map<String, dynamic> json) => _$ExercisePatchFromJson(json);

/// Unique patch ID (Firestore document ID)
@override final  String id;
/// ID of the exercise being patched
@override final  String exerciseId;
/// User ID who submitted the patch
@override final  String userId;
/// Name of the field being modified (e.g., "nome", "difficolta", "noteTecniche")
@override final  String fieldName;
/// Original value before user's modification (from Firestore)
@override final  dynamic oldValue;
/// New value proposed by user
@override final  dynamic newValue;
/// Server value at time of patch creation (for conflict detection)
/// If this differs from current Firestore value, patch is stale
@override final  dynamic originalValue;
/// User's explanation for the change (required, min 10 chars)
@override final  String reason;
/// Current status of the patch
@override final  PatchStatus status;
/// Language version ('it' or 'en')
@override final  String language;
/// When patch was created
@override final  DateTime createdAt;
/// When patch will expire (createdAt + 30 days)
@override final  DateTime expiresAt;
/// Exercise version at time of patch creation
/// Used to detect if exercise was updated before patch approval
@override final  int version;
/// When patch was approved (null if not approved)
@override final  DateTime? approvedAt;
/// Admin user ID who approved the patch
@override final  String? approvedBy;
/// When patch was rejected (null if not rejected)
@override final  DateTime? rejectedAt;
/// Reason for rejection (null if approved or pending)
@override final  String? rejectReason;
/// Additional notes from admin
@override final  String? adminNote;
/// Whether patch was auto-expired by TTL cleanup (Cloud Function)
@override@JsonKey() final  bool autoExpired;
/// User email (for admin notification)
@override final  String? userEmail;
/// User display name (for admin UI)
@override final  String? userDisplayName;

/// Create a copy of ExercisePatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExercisePatchCopyWith<_ExercisePatch> get copyWith => __$ExercisePatchCopyWithImpl<_ExercisePatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExercisePatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExercisePatch&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fieldName, fieldName) || other.fieldName == fieldName)&&const DeepCollectionEquality().equals(other.oldValue, oldValue)&&const DeepCollectionEquality().equals(other.newValue, newValue)&&const DeepCollectionEquality().equals(other.originalValue, originalValue)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.version, version) || other.version == version)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.rejectedAt, rejectedAt) || other.rejectedAt == rejectedAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.autoExpired, autoExpired) || other.autoExpired == autoExpired)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userDisplayName, userDisplayName) || other.userDisplayName == userDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,userId,fieldName,const DeepCollectionEquality().hash(oldValue),const DeepCollectionEquality().hash(newValue),const DeepCollectionEquality().hash(originalValue),reason,status,language,createdAt,expiresAt,version,approvedAt,approvedBy,rejectedAt,rejectReason,adminNote,autoExpired,userEmail,userDisplayName]);

@override
String toString() {
  return 'ExercisePatch(id: $id, exerciseId: $exerciseId, userId: $userId, fieldName: $fieldName, oldValue: $oldValue, newValue: $newValue, originalValue: $originalValue, reason: $reason, status: $status, language: $language, createdAt: $createdAt, expiresAt: $expiresAt, version: $version, approvedAt: $approvedAt, approvedBy: $approvedBy, rejectedAt: $rejectedAt, rejectReason: $rejectReason, adminNote: $adminNote, autoExpired: $autoExpired, userEmail: $userEmail, userDisplayName: $userDisplayName)';
}


}

/// @nodoc
abstract mixin class _$ExercisePatchCopyWith<$Res> implements $ExercisePatchCopyWith<$Res> {
  factory _$ExercisePatchCopyWith(_ExercisePatch value, $Res Function(_ExercisePatch) _then) = __$ExercisePatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String userId, String fieldName, dynamic oldValue, dynamic newValue, dynamic originalValue, String reason, PatchStatus status, String language, DateTime createdAt, DateTime expiresAt, int version, DateTime? approvedAt, String? approvedBy, DateTime? rejectedAt, String? rejectReason, String? adminNote, bool autoExpired, String? userEmail, String? userDisplayName
});




}
/// @nodoc
class __$ExercisePatchCopyWithImpl<$Res>
    implements _$ExercisePatchCopyWith<$Res> {
  __$ExercisePatchCopyWithImpl(this._self, this._then);

  final _ExercisePatch _self;
  final $Res Function(_ExercisePatch) _then;

/// Create a copy of ExercisePatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? userId = null,Object? fieldName = null,Object? oldValue = freezed,Object? newValue = freezed,Object? originalValue = freezed,Object? reason = null,Object? status = null,Object? language = null,Object? createdAt = null,Object? expiresAt = null,Object? version = null,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? rejectedAt = freezed,Object? rejectReason = freezed,Object? adminNote = freezed,Object? autoExpired = null,Object? userEmail = freezed,Object? userDisplayName = freezed,}) {
  return _then(_ExercisePatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fieldName: null == fieldName ? _self.fieldName : fieldName // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as dynamic,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as dynamic,originalValue: freezed == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as dynamic,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PatchStatus,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,autoExpired: null == autoExpired ? _self.autoExpired : autoExpired // ignore: cast_nullable_to_non_nullable
as bool,userEmail: freezed == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String?,userDisplayName: freezed == userDisplayName ? _self.userDisplayName : userDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
