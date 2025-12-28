// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachTemplate {

/// Unique template ID
 String get id;/// Coach who owns this template
 String get coachId;/// Template name
 String get name;/// Optional description
 String? get description;/// List of exercises in this template
@ExerciseTemplateListConverter() List<ExerciseTemplate> get exercises;/// Estimated workout duration in minutes
 int get estimatedDuration;/// Tags for categorization (e.g., "push", "pull", "legs")
 List<String> get tags;/// Difficulty level (beginner, intermediate, advanced)
 String? get difficulty;/// When the template was created
 DateTime get createdAt;/// When the template was last updated
 DateTime get updatedAt;/// List of athlete IDs this template is assigned to
 List<String> get assignedTo;/// Whether this template is archived
 bool get isArchived;/// Optional notes for the coach
 String? get coachNotes;
/// Create a copy of CoachTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachTemplateCopyWith<CoachTemplate> get copyWith => _$CoachTemplateCopyWithImpl<CoachTemplate>(this as CoachTemplate, _$identity);

  /// Serializes this CoachTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.assignedTo, assignedTo)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.coachNotes, coachNotes) || other.coachNotes == coachNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachId,name,description,const DeepCollectionEquality().hash(exercises),estimatedDuration,const DeepCollectionEquality().hash(tags),difficulty,createdAt,updatedAt,const DeepCollectionEquality().hash(assignedTo),isArchived,coachNotes);

@override
String toString() {
  return 'CoachTemplate(id: $id, coachId: $coachId, name: $name, description: $description, exercises: $exercises, estimatedDuration: $estimatedDuration, tags: $tags, difficulty: $difficulty, createdAt: $createdAt, updatedAt: $updatedAt, assignedTo: $assignedTo, isArchived: $isArchived, coachNotes: $coachNotes)';
}


}

/// @nodoc
abstract mixin class $CoachTemplateCopyWith<$Res>  {
  factory $CoachTemplateCopyWith(CoachTemplate value, $Res Function(CoachTemplate) _then) = _$CoachTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String coachId, String name, String? description,@ExerciseTemplateListConverter() List<ExerciseTemplate> exercises, int estimatedDuration, List<String> tags, String? difficulty, DateTime createdAt, DateTime updatedAt, List<String> assignedTo, bool isArchived, String? coachNotes
});




}
/// @nodoc
class _$CoachTemplateCopyWithImpl<$Res>
    implements $CoachTemplateCopyWith<$Res> {
  _$CoachTemplateCopyWithImpl(this._self, this._then);

  final CoachTemplate _self;
  final $Res Function(CoachTemplate) _then;

/// Create a copy of CoachTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coachId = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? estimatedDuration = null,Object? tags = null,Object? difficulty = freezed,Object? createdAt = null,Object? updatedAt = null,Object? assignedTo = null,Object? isArchived = null,Object? coachNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExerciseTemplate>,estimatedDuration: null == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedTo: null == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as List<String>,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,coachNotes: freezed == coachNotes ? _self.coachNotes : coachNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachTemplate].
extension CoachTemplatePatterns on CoachTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachTemplate value)  $default,){
final _that = this;
switch (_that) {
case _CoachTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _CoachTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String coachId,  String name,  String? description, @ExerciseTemplateListConverter()  List<ExerciseTemplate> exercises,  int estimatedDuration,  List<String> tags,  String? difficulty,  DateTime createdAt,  DateTime updatedAt,  List<String> assignedTo,  bool isArchived,  String? coachNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachTemplate() when $default != null:
return $default(_that.id,_that.coachId,_that.name,_that.description,_that.exercises,_that.estimatedDuration,_that.tags,_that.difficulty,_that.createdAt,_that.updatedAt,_that.assignedTo,_that.isArchived,_that.coachNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String coachId,  String name,  String? description, @ExerciseTemplateListConverter()  List<ExerciseTemplate> exercises,  int estimatedDuration,  List<String> tags,  String? difficulty,  DateTime createdAt,  DateTime updatedAt,  List<String> assignedTo,  bool isArchived,  String? coachNotes)  $default,) {final _that = this;
switch (_that) {
case _CoachTemplate():
return $default(_that.id,_that.coachId,_that.name,_that.description,_that.exercises,_that.estimatedDuration,_that.tags,_that.difficulty,_that.createdAt,_that.updatedAt,_that.assignedTo,_that.isArchived,_that.coachNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String coachId,  String name,  String? description, @ExerciseTemplateListConverter()  List<ExerciseTemplate> exercises,  int estimatedDuration,  List<String> tags,  String? difficulty,  DateTime createdAt,  DateTime updatedAt,  List<String> assignedTo,  bool isArchived,  String? coachNotes)?  $default,) {final _that = this;
switch (_that) {
case _CoachTemplate() when $default != null:
return $default(_that.id,_that.coachId,_that.name,_that.description,_that.exercises,_that.estimatedDuration,_that.tags,_that.difficulty,_that.createdAt,_that.updatedAt,_that.assignedTo,_that.isArchived,_that.coachNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachTemplate extends CoachTemplate {
  const _CoachTemplate({required this.id, required this.coachId, required this.name, this.description, @ExerciseTemplateListConverter() final  List<ExerciseTemplate> exercises = const [], this.estimatedDuration = 45, final  List<String> tags = const [], this.difficulty, required this.createdAt, required this.updatedAt, final  List<String> assignedTo = const [], this.isArchived = false, this.coachNotes}): _exercises = exercises,_tags = tags,_assignedTo = assignedTo,super._();
  factory _CoachTemplate.fromJson(Map<String, dynamic> json) => _$CoachTemplateFromJson(json);

/// Unique template ID
@override final  String id;
/// Coach who owns this template
@override final  String coachId;
/// Template name
@override final  String name;
/// Optional description
@override final  String? description;
/// List of exercises in this template
 final  List<ExerciseTemplate> _exercises;
/// List of exercises in this template
@override@JsonKey()@ExerciseTemplateListConverter() List<ExerciseTemplate> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

/// Estimated workout duration in minutes
@override@JsonKey() final  int estimatedDuration;
/// Tags for categorization (e.g., "push", "pull", "legs")
 final  List<String> _tags;
/// Tags for categorization (e.g., "push", "pull", "legs")
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Difficulty level (beginner, intermediate, advanced)
@override final  String? difficulty;
/// When the template was created
@override final  DateTime createdAt;
/// When the template was last updated
@override final  DateTime updatedAt;
/// List of athlete IDs this template is assigned to
 final  List<String> _assignedTo;
/// List of athlete IDs this template is assigned to
@override@JsonKey() List<String> get assignedTo {
  if (_assignedTo is EqualUnmodifiableListView) return _assignedTo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignedTo);
}

/// Whether this template is archived
@override@JsonKey() final  bool isArchived;
/// Optional notes for the coach
@override final  String? coachNotes;

/// Create a copy of CoachTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachTemplateCopyWith<_CoachTemplate> get copyWith => __$CoachTemplateCopyWithImpl<_CoachTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._assignedTo, _assignedTo)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.coachNotes, coachNotes) || other.coachNotes == coachNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachId,name,description,const DeepCollectionEquality().hash(_exercises),estimatedDuration,const DeepCollectionEquality().hash(_tags),difficulty,createdAt,updatedAt,const DeepCollectionEquality().hash(_assignedTo),isArchived,coachNotes);

@override
String toString() {
  return 'CoachTemplate(id: $id, coachId: $coachId, name: $name, description: $description, exercises: $exercises, estimatedDuration: $estimatedDuration, tags: $tags, difficulty: $difficulty, createdAt: $createdAt, updatedAt: $updatedAt, assignedTo: $assignedTo, isArchived: $isArchived, coachNotes: $coachNotes)';
}


}

/// @nodoc
abstract mixin class _$CoachTemplateCopyWith<$Res> implements $CoachTemplateCopyWith<$Res> {
  factory _$CoachTemplateCopyWith(_CoachTemplate value, $Res Function(_CoachTemplate) _then) = __$CoachTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String coachId, String name, String? description,@ExerciseTemplateListConverter() List<ExerciseTemplate> exercises, int estimatedDuration, List<String> tags, String? difficulty, DateTime createdAt, DateTime updatedAt, List<String> assignedTo, bool isArchived, String? coachNotes
});




}
/// @nodoc
class __$CoachTemplateCopyWithImpl<$Res>
    implements _$CoachTemplateCopyWith<$Res> {
  __$CoachTemplateCopyWithImpl(this._self, this._then);

  final _CoachTemplate _self;
  final $Res Function(_CoachTemplate) _then;

/// Create a copy of CoachTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coachId = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? estimatedDuration = null,Object? tags = null,Object? difficulty = freezed,Object? createdAt = null,Object? updatedAt = null,Object? assignedTo = null,Object? isArchived = null,Object? coachNotes = freezed,}) {
  return _then(_CoachTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ExerciseTemplate>,estimatedDuration: null == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedTo: null == assignedTo ? _self._assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as List<String>,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,coachNotes: freezed == coachNotes ? _self.coachNotes : coachNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
