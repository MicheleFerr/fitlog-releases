// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assigned_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssignedTemplate {

/// Unique ID for this assignment
 String get id;/// Reference to the coach's template
 String get coachTemplateId;/// Coach who assigned this template
 String get coachId;/// When this template was assigned
 DateTime get assignedAt;/// When the template was last synced (for detecting updates)
 DateTime get lastSyncedAt;/// Optional notes from the athlete (local to their copy)
 String? get athleteNotes;// Denormalized fields for display (avoids extra reads)
/// Template name (cached from coach template)
 String? get templateName;/// Coach name (cached for display)
 String? get coachName;/// Number of exercises (cached for display)
 int? get exerciseCount;/// Estimated duration (cached for display)
 int? get estimatedDuration;
/// Create a copy of AssignedTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignedTemplateCopyWith<AssignedTemplate> get copyWith => _$AssignedTemplateCopyWithImpl<AssignedTemplate>(this as AssignedTemplate, _$identity);

  /// Serializes this AssignedTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignedTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.coachTemplateId, coachTemplateId) || other.coachTemplateId == coachTemplateId)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.athleteNotes, athleteNotes) || other.athleteNotes == athleteNotes)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachTemplateId,coachId,assignedAt,lastSyncedAt,athleteNotes,templateName,coachName,exerciseCount,estimatedDuration);

@override
String toString() {
  return 'AssignedTemplate(id: $id, coachTemplateId: $coachTemplateId, coachId: $coachId, assignedAt: $assignedAt, lastSyncedAt: $lastSyncedAt, athleteNotes: $athleteNotes, templateName: $templateName, coachName: $coachName, exerciseCount: $exerciseCount, estimatedDuration: $estimatedDuration)';
}


}

/// @nodoc
abstract mixin class $AssignedTemplateCopyWith<$Res>  {
  factory $AssignedTemplateCopyWith(AssignedTemplate value, $Res Function(AssignedTemplate) _then) = _$AssignedTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String coachTemplateId, String coachId, DateTime assignedAt, DateTime lastSyncedAt, String? athleteNotes, String? templateName, String? coachName, int? exerciseCount, int? estimatedDuration
});




}
/// @nodoc
class _$AssignedTemplateCopyWithImpl<$Res>
    implements $AssignedTemplateCopyWith<$Res> {
  _$AssignedTemplateCopyWithImpl(this._self, this._then);

  final AssignedTemplate _self;
  final $Res Function(AssignedTemplate) _then;

/// Create a copy of AssignedTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coachTemplateId = null,Object? coachId = null,Object? assignedAt = null,Object? lastSyncedAt = null,Object? athleteNotes = freezed,Object? templateName = freezed,Object? coachName = freezed,Object? exerciseCount = freezed,Object? estimatedDuration = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachTemplateId: null == coachTemplateId ? _self.coachTemplateId : coachTemplateId // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSyncedAt: null == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime,athleteNotes: freezed == athleteNotes ? _self.athleteNotes : athleteNotes // ignore: cast_nullable_to_non_nullable
as String?,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,coachName: freezed == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String?,exerciseCount: freezed == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int?,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignedTemplate].
extension AssignedTemplatePatterns on AssignedTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignedTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignedTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignedTemplate value)  $default,){
final _that = this;
switch (_that) {
case _AssignedTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignedTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _AssignedTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String coachTemplateId,  String coachId,  DateTime assignedAt,  DateTime lastSyncedAt,  String? athleteNotes,  String? templateName,  String? coachName,  int? exerciseCount,  int? estimatedDuration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignedTemplate() when $default != null:
return $default(_that.id,_that.coachTemplateId,_that.coachId,_that.assignedAt,_that.lastSyncedAt,_that.athleteNotes,_that.templateName,_that.coachName,_that.exerciseCount,_that.estimatedDuration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String coachTemplateId,  String coachId,  DateTime assignedAt,  DateTime lastSyncedAt,  String? athleteNotes,  String? templateName,  String? coachName,  int? exerciseCount,  int? estimatedDuration)  $default,) {final _that = this;
switch (_that) {
case _AssignedTemplate():
return $default(_that.id,_that.coachTemplateId,_that.coachId,_that.assignedAt,_that.lastSyncedAt,_that.athleteNotes,_that.templateName,_that.coachName,_that.exerciseCount,_that.estimatedDuration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String coachTemplateId,  String coachId,  DateTime assignedAt,  DateTime lastSyncedAt,  String? athleteNotes,  String? templateName,  String? coachName,  int? exerciseCount,  int? estimatedDuration)?  $default,) {final _that = this;
switch (_that) {
case _AssignedTemplate() when $default != null:
return $default(_that.id,_that.coachTemplateId,_that.coachId,_that.assignedAt,_that.lastSyncedAt,_that.athleteNotes,_that.templateName,_that.coachName,_that.exerciseCount,_that.estimatedDuration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignedTemplate extends AssignedTemplate {
  const _AssignedTemplate({required this.id, required this.coachTemplateId, required this.coachId, required this.assignedAt, required this.lastSyncedAt, this.athleteNotes, this.templateName, this.coachName, this.exerciseCount, this.estimatedDuration}): super._();
  factory _AssignedTemplate.fromJson(Map<String, dynamic> json) => _$AssignedTemplateFromJson(json);

/// Unique ID for this assignment
@override final  String id;
/// Reference to the coach's template
@override final  String coachTemplateId;
/// Coach who assigned this template
@override final  String coachId;
/// When this template was assigned
@override final  DateTime assignedAt;
/// When the template was last synced (for detecting updates)
@override final  DateTime lastSyncedAt;
/// Optional notes from the athlete (local to their copy)
@override final  String? athleteNotes;
// Denormalized fields for display (avoids extra reads)
/// Template name (cached from coach template)
@override final  String? templateName;
/// Coach name (cached for display)
@override final  String? coachName;
/// Number of exercises (cached for display)
@override final  int? exerciseCount;
/// Estimated duration (cached for display)
@override final  int? estimatedDuration;

/// Create a copy of AssignedTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignedTemplateCopyWith<_AssignedTemplate> get copyWith => __$AssignedTemplateCopyWithImpl<_AssignedTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignedTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignedTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.coachTemplateId, coachTemplateId) || other.coachTemplateId == coachTemplateId)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.athleteNotes, athleteNotes) || other.athleteNotes == athleteNotes)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachTemplateId,coachId,assignedAt,lastSyncedAt,athleteNotes,templateName,coachName,exerciseCount,estimatedDuration);

@override
String toString() {
  return 'AssignedTemplate(id: $id, coachTemplateId: $coachTemplateId, coachId: $coachId, assignedAt: $assignedAt, lastSyncedAt: $lastSyncedAt, athleteNotes: $athleteNotes, templateName: $templateName, coachName: $coachName, exerciseCount: $exerciseCount, estimatedDuration: $estimatedDuration)';
}


}

/// @nodoc
abstract mixin class _$AssignedTemplateCopyWith<$Res> implements $AssignedTemplateCopyWith<$Res> {
  factory _$AssignedTemplateCopyWith(_AssignedTemplate value, $Res Function(_AssignedTemplate) _then) = __$AssignedTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String coachTemplateId, String coachId, DateTime assignedAt, DateTime lastSyncedAt, String? athleteNotes, String? templateName, String? coachName, int? exerciseCount, int? estimatedDuration
});




}
/// @nodoc
class __$AssignedTemplateCopyWithImpl<$Res>
    implements _$AssignedTemplateCopyWith<$Res> {
  __$AssignedTemplateCopyWithImpl(this._self, this._then);

  final _AssignedTemplate _self;
  final $Res Function(_AssignedTemplate) _then;

/// Create a copy of AssignedTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coachTemplateId = null,Object? coachId = null,Object? assignedAt = null,Object? lastSyncedAt = null,Object? athleteNotes = freezed,Object? templateName = freezed,Object? coachName = freezed,Object? exerciseCount = freezed,Object? estimatedDuration = freezed,}) {
  return _then(_AssignedTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachTemplateId: null == coachTemplateId ? _self.coachTemplateId : coachTemplateId // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,assignedAt: null == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSyncedAt: null == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime,athleteNotes: freezed == athleteNotes ? _self.athleteNotes : athleteNotes // ignore: cast_nullable_to_non_nullable
as String?,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,coachName: freezed == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String?,exerciseCount: freezed == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int?,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
