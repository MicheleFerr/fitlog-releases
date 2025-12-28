// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_relationship.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachPermissions {

/// Can view athlete's workout dashboard
 bool get canViewDashboard;/// Can edit/assign workouts
 bool get canEditWorkout;/// Can view health questionnaire (PAR-Q)
 bool get canViewHealth;/// Can view body measurements
 bool get canViewMeasurements;
/// Create a copy of CoachPermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachPermissionsCopyWith<CoachPermissions> get copyWith => _$CoachPermissionsCopyWithImpl<CoachPermissions>(this as CoachPermissions, _$identity);

  /// Serializes this CoachPermissions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachPermissions&&(identical(other.canViewDashboard, canViewDashboard) || other.canViewDashboard == canViewDashboard)&&(identical(other.canEditWorkout, canEditWorkout) || other.canEditWorkout == canEditWorkout)&&(identical(other.canViewHealth, canViewHealth) || other.canViewHealth == canViewHealth)&&(identical(other.canViewMeasurements, canViewMeasurements) || other.canViewMeasurements == canViewMeasurements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canViewDashboard,canEditWorkout,canViewHealth,canViewMeasurements);

@override
String toString() {
  return 'CoachPermissions(canViewDashboard: $canViewDashboard, canEditWorkout: $canEditWorkout, canViewHealth: $canViewHealth, canViewMeasurements: $canViewMeasurements)';
}


}

/// @nodoc
abstract mixin class $CoachPermissionsCopyWith<$Res>  {
  factory $CoachPermissionsCopyWith(CoachPermissions value, $Res Function(CoachPermissions) _then) = _$CoachPermissionsCopyWithImpl;
@useResult
$Res call({
 bool canViewDashboard, bool canEditWorkout, bool canViewHealth, bool canViewMeasurements
});




}
/// @nodoc
class _$CoachPermissionsCopyWithImpl<$Res>
    implements $CoachPermissionsCopyWith<$Res> {
  _$CoachPermissionsCopyWithImpl(this._self, this._then);

  final CoachPermissions _self;
  final $Res Function(CoachPermissions) _then;

/// Create a copy of CoachPermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canViewDashboard = null,Object? canEditWorkout = null,Object? canViewHealth = null,Object? canViewMeasurements = null,}) {
  return _then(_self.copyWith(
canViewDashboard: null == canViewDashboard ? _self.canViewDashboard : canViewDashboard // ignore: cast_nullable_to_non_nullable
as bool,canEditWorkout: null == canEditWorkout ? _self.canEditWorkout : canEditWorkout // ignore: cast_nullable_to_non_nullable
as bool,canViewHealth: null == canViewHealth ? _self.canViewHealth : canViewHealth // ignore: cast_nullable_to_non_nullable
as bool,canViewMeasurements: null == canViewMeasurements ? _self.canViewMeasurements : canViewMeasurements // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachPermissions].
extension CoachPermissionsPatterns on CoachPermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachPermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachPermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachPermissions value)  $default,){
final _that = this;
switch (_that) {
case _CoachPermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachPermissions value)?  $default,){
final _that = this;
switch (_that) {
case _CoachPermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canViewDashboard,  bool canEditWorkout,  bool canViewHealth,  bool canViewMeasurements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachPermissions() when $default != null:
return $default(_that.canViewDashboard,_that.canEditWorkout,_that.canViewHealth,_that.canViewMeasurements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canViewDashboard,  bool canEditWorkout,  bool canViewHealth,  bool canViewMeasurements)  $default,) {final _that = this;
switch (_that) {
case _CoachPermissions():
return $default(_that.canViewDashboard,_that.canEditWorkout,_that.canViewHealth,_that.canViewMeasurements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canViewDashboard,  bool canEditWorkout,  bool canViewHealth,  bool canViewMeasurements)?  $default,) {final _that = this;
switch (_that) {
case _CoachPermissions() when $default != null:
return $default(_that.canViewDashboard,_that.canEditWorkout,_that.canViewHealth,_that.canViewMeasurements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachPermissions extends CoachPermissions {
  const _CoachPermissions({this.canViewDashboard = true, this.canEditWorkout = true, this.canViewHealth = false, this.canViewMeasurements = false}): super._();
  factory _CoachPermissions.fromJson(Map<String, dynamic> json) => _$CoachPermissionsFromJson(json);

/// Can view athlete's workout dashboard
@override@JsonKey() final  bool canViewDashboard;
/// Can edit/assign workouts
@override@JsonKey() final  bool canEditWorkout;
/// Can view health questionnaire (PAR-Q)
@override@JsonKey() final  bool canViewHealth;
/// Can view body measurements
@override@JsonKey() final  bool canViewMeasurements;

/// Create a copy of CoachPermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachPermissionsCopyWith<_CoachPermissions> get copyWith => __$CoachPermissionsCopyWithImpl<_CoachPermissions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachPermissionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachPermissions&&(identical(other.canViewDashboard, canViewDashboard) || other.canViewDashboard == canViewDashboard)&&(identical(other.canEditWorkout, canEditWorkout) || other.canEditWorkout == canEditWorkout)&&(identical(other.canViewHealth, canViewHealth) || other.canViewHealth == canViewHealth)&&(identical(other.canViewMeasurements, canViewMeasurements) || other.canViewMeasurements == canViewMeasurements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,canViewDashboard,canEditWorkout,canViewHealth,canViewMeasurements);

@override
String toString() {
  return 'CoachPermissions(canViewDashboard: $canViewDashboard, canEditWorkout: $canEditWorkout, canViewHealth: $canViewHealth, canViewMeasurements: $canViewMeasurements)';
}


}

/// @nodoc
abstract mixin class _$CoachPermissionsCopyWith<$Res> implements $CoachPermissionsCopyWith<$Res> {
  factory _$CoachPermissionsCopyWith(_CoachPermissions value, $Res Function(_CoachPermissions) _then) = __$CoachPermissionsCopyWithImpl;
@override @useResult
$Res call({
 bool canViewDashboard, bool canEditWorkout, bool canViewHealth, bool canViewMeasurements
});




}
/// @nodoc
class __$CoachPermissionsCopyWithImpl<$Res>
    implements _$CoachPermissionsCopyWith<$Res> {
  __$CoachPermissionsCopyWithImpl(this._self, this._then);

  final _CoachPermissions _self;
  final $Res Function(_CoachPermissions) _then;

/// Create a copy of CoachPermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canViewDashboard = null,Object? canEditWorkout = null,Object? canViewHealth = null,Object? canViewMeasurements = null,}) {
  return _then(_CoachPermissions(
canViewDashboard: null == canViewDashboard ? _self.canViewDashboard : canViewDashboard // ignore: cast_nullable_to_non_nullable
as bool,canEditWorkout: null == canEditWorkout ? _self.canEditWorkout : canEditWorkout // ignore: cast_nullable_to_non_nullable
as bool,canViewHealth: null == canViewHealth ? _self.canViewHealth : canViewHealth // ignore: cast_nullable_to_non_nullable
as bool,canViewMeasurements: null == canViewMeasurements ? _self.canViewMeasurements : canViewMeasurements // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CoachRelationship {

/// Unique ID (Firestore document ID)
 String get id;/// Athlete's user ID
 String get athleteId;/// Athlete's email (for legacy compatibility)
 String? get athleteEmail;/// Athlete's display name (denormalized for list display)
 String? get athleteName;/// Coach's user ID
 String? get coachId;/// Coach's email (required by current schema)
 String get coachEmail;/// Coach's display name (denormalized)
 String? get coachName;/// Relationship status
 RelationshipStatus get status;/// Whether athlete has the app installed
 bool get athleteHasApp;/// Permissions granted to coach
 CoachPermissions get permissions;/// When the relationship was created
 DateTime get createdAt;/// When the athlete accepted (null if pending)
 DateTime? get connectedAt;/// When the relationship ended (null if active)
 DateTime? get endedAt;/// Optional notes from coach
 String? get coachNotes;
/// Create a copy of CoachRelationship
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachRelationshipCopyWith<CoachRelationship> get copyWith => _$CoachRelationshipCopyWithImpl<CoachRelationship>(this as CoachRelationship, _$identity);

  /// Serializes this CoachRelationship to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachRelationship&&(identical(other.id, id) || other.id == id)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.athleteEmail, athleteEmail) || other.athleteEmail == athleteEmail)&&(identical(other.athleteName, athleteName) || other.athleteName == athleteName)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.coachEmail, coachEmail) || other.coachEmail == coachEmail)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.status, status) || other.status == status)&&(identical(other.athleteHasApp, athleteHasApp) || other.athleteHasApp == athleteHasApp)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.coachNotes, coachNotes) || other.coachNotes == coachNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,athleteId,athleteEmail,athleteName,coachId,coachEmail,coachName,status,athleteHasApp,permissions,createdAt,connectedAt,endedAt,coachNotes);

@override
String toString() {
  return 'CoachRelationship(id: $id, athleteId: $athleteId, athleteEmail: $athleteEmail, athleteName: $athleteName, coachId: $coachId, coachEmail: $coachEmail, coachName: $coachName, status: $status, athleteHasApp: $athleteHasApp, permissions: $permissions, createdAt: $createdAt, connectedAt: $connectedAt, endedAt: $endedAt, coachNotes: $coachNotes)';
}


}

/// @nodoc
abstract mixin class $CoachRelationshipCopyWith<$Res>  {
  factory $CoachRelationshipCopyWith(CoachRelationship value, $Res Function(CoachRelationship) _then) = _$CoachRelationshipCopyWithImpl;
@useResult
$Res call({
 String id, String athleteId, String? athleteEmail, String? athleteName, String? coachId, String coachEmail, String? coachName, RelationshipStatus status, bool athleteHasApp, CoachPermissions permissions, DateTime createdAt, DateTime? connectedAt, DateTime? endedAt, String? coachNotes
});


$CoachPermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class _$CoachRelationshipCopyWithImpl<$Res>
    implements $CoachRelationshipCopyWith<$Res> {
  _$CoachRelationshipCopyWithImpl(this._self, this._then);

  final CoachRelationship _self;
  final $Res Function(CoachRelationship) _then;

/// Create a copy of CoachRelationship
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? athleteId = null,Object? athleteEmail = freezed,Object? athleteName = freezed,Object? coachId = freezed,Object? coachEmail = null,Object? coachName = freezed,Object? status = null,Object? athleteHasApp = null,Object? permissions = null,Object? createdAt = null,Object? connectedAt = freezed,Object? endedAt = freezed,Object? coachNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,athleteEmail: freezed == athleteEmail ? _self.athleteEmail : athleteEmail // ignore: cast_nullable_to_non_nullable
as String?,athleteName: freezed == athleteName ? _self.athleteName : athleteName // ignore: cast_nullable_to_non_nullable
as String?,coachId: freezed == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String?,coachEmail: null == coachEmail ? _self.coachEmail : coachEmail // ignore: cast_nullable_to_non_nullable
as String,coachName: freezed == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RelationshipStatus,athleteHasApp: null == athleteHasApp ? _self.athleteHasApp : athleteHasApp // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as CoachPermissions,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,coachNotes: freezed == coachNotes ? _self.coachNotes : coachNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CoachRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoachPermissionsCopyWith<$Res> get permissions {
  
  return $CoachPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoachRelationship].
extension CoachRelationshipPatterns on CoachRelationship {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachRelationship value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachRelationship() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachRelationship value)  $default,){
final _that = this;
switch (_that) {
case _CoachRelationship():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachRelationship value)?  $default,){
final _that = this;
switch (_that) {
case _CoachRelationship() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String athleteId,  String? athleteEmail,  String? athleteName,  String? coachId,  String coachEmail,  String? coachName,  RelationshipStatus status,  bool athleteHasApp,  CoachPermissions permissions,  DateTime createdAt,  DateTime? connectedAt,  DateTime? endedAt,  String? coachNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachRelationship() when $default != null:
return $default(_that.id,_that.athleteId,_that.athleteEmail,_that.athleteName,_that.coachId,_that.coachEmail,_that.coachName,_that.status,_that.athleteHasApp,_that.permissions,_that.createdAt,_that.connectedAt,_that.endedAt,_that.coachNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String athleteId,  String? athleteEmail,  String? athleteName,  String? coachId,  String coachEmail,  String? coachName,  RelationshipStatus status,  bool athleteHasApp,  CoachPermissions permissions,  DateTime createdAt,  DateTime? connectedAt,  DateTime? endedAt,  String? coachNotes)  $default,) {final _that = this;
switch (_that) {
case _CoachRelationship():
return $default(_that.id,_that.athleteId,_that.athleteEmail,_that.athleteName,_that.coachId,_that.coachEmail,_that.coachName,_that.status,_that.athleteHasApp,_that.permissions,_that.createdAt,_that.connectedAt,_that.endedAt,_that.coachNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String athleteId,  String? athleteEmail,  String? athleteName,  String? coachId,  String coachEmail,  String? coachName,  RelationshipStatus status,  bool athleteHasApp,  CoachPermissions permissions,  DateTime createdAt,  DateTime? connectedAt,  DateTime? endedAt,  String? coachNotes)?  $default,) {final _that = this;
switch (_that) {
case _CoachRelationship() when $default != null:
return $default(_that.id,_that.athleteId,_that.athleteEmail,_that.athleteName,_that.coachId,_that.coachEmail,_that.coachName,_that.status,_that.athleteHasApp,_that.permissions,_that.createdAt,_that.connectedAt,_that.endedAt,_that.coachNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachRelationship extends CoachRelationship {
  const _CoachRelationship({required this.id, required this.athleteId, this.athleteEmail, this.athleteName, this.coachId, required this.coachEmail, this.coachName, this.status = RelationshipStatus.pending, this.athleteHasApp = true, this.permissions = const CoachPermissions(), required this.createdAt, this.connectedAt, this.endedAt, this.coachNotes}): super._();
  factory _CoachRelationship.fromJson(Map<String, dynamic> json) => _$CoachRelationshipFromJson(json);

/// Unique ID (Firestore document ID)
@override final  String id;
/// Athlete's user ID
@override final  String athleteId;
/// Athlete's email (for legacy compatibility)
@override final  String? athleteEmail;
/// Athlete's display name (denormalized for list display)
@override final  String? athleteName;
/// Coach's user ID
@override final  String? coachId;
/// Coach's email (required by current schema)
@override final  String coachEmail;
/// Coach's display name (denormalized)
@override final  String? coachName;
/// Relationship status
@override@JsonKey() final  RelationshipStatus status;
/// Whether athlete has the app installed
@override@JsonKey() final  bool athleteHasApp;
/// Permissions granted to coach
@override@JsonKey() final  CoachPermissions permissions;
/// When the relationship was created
@override final  DateTime createdAt;
/// When the athlete accepted (null if pending)
@override final  DateTime? connectedAt;
/// When the relationship ended (null if active)
@override final  DateTime? endedAt;
/// Optional notes from coach
@override final  String? coachNotes;

/// Create a copy of CoachRelationship
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachRelationshipCopyWith<_CoachRelationship> get copyWith => __$CoachRelationshipCopyWithImpl<_CoachRelationship>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachRelationshipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachRelationship&&(identical(other.id, id) || other.id == id)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.athleteEmail, athleteEmail) || other.athleteEmail == athleteEmail)&&(identical(other.athleteName, athleteName) || other.athleteName == athleteName)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.coachEmail, coachEmail) || other.coachEmail == coachEmail)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.status, status) || other.status == status)&&(identical(other.athleteHasApp, athleteHasApp) || other.athleteHasApp == athleteHasApp)&&(identical(other.permissions, permissions) || other.permissions == permissions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.coachNotes, coachNotes) || other.coachNotes == coachNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,athleteId,athleteEmail,athleteName,coachId,coachEmail,coachName,status,athleteHasApp,permissions,createdAt,connectedAt,endedAt,coachNotes);

@override
String toString() {
  return 'CoachRelationship(id: $id, athleteId: $athleteId, athleteEmail: $athleteEmail, athleteName: $athleteName, coachId: $coachId, coachEmail: $coachEmail, coachName: $coachName, status: $status, athleteHasApp: $athleteHasApp, permissions: $permissions, createdAt: $createdAt, connectedAt: $connectedAt, endedAt: $endedAt, coachNotes: $coachNotes)';
}


}

/// @nodoc
abstract mixin class _$CoachRelationshipCopyWith<$Res> implements $CoachRelationshipCopyWith<$Res> {
  factory _$CoachRelationshipCopyWith(_CoachRelationship value, $Res Function(_CoachRelationship) _then) = __$CoachRelationshipCopyWithImpl;
@override @useResult
$Res call({
 String id, String athleteId, String? athleteEmail, String? athleteName, String? coachId, String coachEmail, String? coachName, RelationshipStatus status, bool athleteHasApp, CoachPermissions permissions, DateTime createdAt, DateTime? connectedAt, DateTime? endedAt, String? coachNotes
});


@override $CoachPermissionsCopyWith<$Res> get permissions;

}
/// @nodoc
class __$CoachRelationshipCopyWithImpl<$Res>
    implements _$CoachRelationshipCopyWith<$Res> {
  __$CoachRelationshipCopyWithImpl(this._self, this._then);

  final _CoachRelationship _self;
  final $Res Function(_CoachRelationship) _then;

/// Create a copy of CoachRelationship
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? athleteId = null,Object? athleteEmail = freezed,Object? athleteName = freezed,Object? coachId = freezed,Object? coachEmail = null,Object? coachName = freezed,Object? status = null,Object? athleteHasApp = null,Object? permissions = null,Object? createdAt = null,Object? connectedAt = freezed,Object? endedAt = freezed,Object? coachNotes = freezed,}) {
  return _then(_CoachRelationship(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,athleteEmail: freezed == athleteEmail ? _self.athleteEmail : athleteEmail // ignore: cast_nullable_to_non_nullable
as String?,athleteName: freezed == athleteName ? _self.athleteName : athleteName // ignore: cast_nullable_to_non_nullable
as String?,coachId: freezed == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String?,coachEmail: null == coachEmail ? _self.coachEmail : coachEmail // ignore: cast_nullable_to_non_nullable
as String,coachName: freezed == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RelationshipStatus,athleteHasApp: null == athleteHasApp ? _self.athleteHasApp : athleteHasApp // ignore: cast_nullable_to_non_nullable
as bool,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as CoachPermissions,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,coachNotes: freezed == coachNotes ? _self.coachNotes : coachNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CoachRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoachPermissionsCopyWith<$Res> get permissions {
  
  return $CoachPermissionsCopyWith<$Res>(_self.permissions, (value) {
    return _then(_self.copyWith(permissions: value));
  });
}
}

// dart format on
