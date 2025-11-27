// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseDefinitionTemplate {

 String get id; String get name; String get description; ExerciseCategory get category; ExerciseType get type; List<String> get muscleGroups; List<String> get equipment; List<String>? get instructions; String? get imageUrl; String? get videoUrl; String? get difficulty; Map<String, dynamic>? get metadata; bool get isActive; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ExerciseDefinitionTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseDefinitionTemplateCopyWith<ExerciseDefinitionTemplate> get copyWith => _$ExerciseDefinitionTemplateCopyWithImpl<ExerciseDefinitionTemplate>(this as ExerciseDefinitionTemplate, _$identity);

  /// Serializes this ExerciseDefinitionTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseDefinitionTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.muscleGroups, muscleGroups)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&const DeepCollectionEquality().equals(other.instructions, instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,type,const DeepCollectionEquality().hash(muscleGroups),const DeepCollectionEquality().hash(equipment),const DeepCollectionEquality().hash(instructions),imageUrl,videoUrl,difficulty,const DeepCollectionEquality().hash(metadata),isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ExerciseDefinitionTemplate(id: $id, name: $name, description: $description, category: $category, type: $type, muscleGroups: $muscleGroups, equipment: $equipment, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl, difficulty: $difficulty, metadata: $metadata, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ExerciseDefinitionTemplateCopyWith<$Res>  {
  factory $ExerciseDefinitionTemplateCopyWith(ExerciseDefinitionTemplate value, $Res Function(ExerciseDefinitionTemplate) _then) = _$ExerciseDefinitionTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, ExerciseCategory category, ExerciseType type, List<String> muscleGroups, List<String> equipment, List<String>? instructions, String? imageUrl, String? videoUrl, String? difficulty, Map<String, dynamic>? metadata, bool isActive, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ExerciseDefinitionTemplateCopyWithImpl<$Res>
    implements $ExerciseDefinitionTemplateCopyWith<$Res> {
  _$ExerciseDefinitionTemplateCopyWithImpl(this._self, this._then);

  final ExerciseDefinitionTemplate _self;
  final $Res Function(ExerciseDefinitionTemplate) _then;

/// Create a copy of ExerciseDefinitionTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? category = null,Object? type = null,Object? muscleGroups = null,Object? equipment = null,Object? instructions = freezed,Object? imageUrl = freezed,Object? videoUrl = freezed,Object? difficulty = freezed,Object? metadata = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExerciseType,muscleGroups: null == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseDefinitionTemplate].
extension ExerciseDefinitionTemplatePatterns on ExerciseDefinitionTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseDefinitionTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseDefinitionTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseDefinitionTemplate value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseDefinitionTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseDefinitionTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseDefinitionTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  ExerciseCategory category,  ExerciseType type,  List<String> muscleGroups,  List<String> equipment,  List<String>? instructions,  String? imageUrl,  String? videoUrl,  String? difficulty,  Map<String, dynamic>? metadata,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseDefinitionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.type,_that.muscleGroups,_that.equipment,_that.instructions,_that.imageUrl,_that.videoUrl,_that.difficulty,_that.metadata,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  ExerciseCategory category,  ExerciseType type,  List<String> muscleGroups,  List<String> equipment,  List<String>? instructions,  String? imageUrl,  String? videoUrl,  String? difficulty,  Map<String, dynamic>? metadata,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ExerciseDefinitionTemplate():
return $default(_that.id,_that.name,_that.description,_that.category,_that.type,_that.muscleGroups,_that.equipment,_that.instructions,_that.imageUrl,_that.videoUrl,_that.difficulty,_that.metadata,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  ExerciseCategory category,  ExerciseType type,  List<String> muscleGroups,  List<String> equipment,  List<String>? instructions,  String? imageUrl,  String? videoUrl,  String? difficulty,  Map<String, dynamic>? metadata,  bool isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseDefinitionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.type,_that.muscleGroups,_that.equipment,_that.instructions,_that.imageUrl,_that.videoUrl,_that.difficulty,_that.metadata,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseDefinitionTemplate implements ExerciseDefinitionTemplate {
  const _ExerciseDefinitionTemplate({required this.id, required this.name, required this.description, required this.category, required this.type, required final  List<String> muscleGroups, required final  List<String> equipment, final  List<String>? instructions, this.imageUrl, this.videoUrl, this.difficulty, final  Map<String, dynamic>? metadata, this.isActive = true, this.createdAt, this.updatedAt}): _muscleGroups = muscleGroups,_equipment = equipment,_instructions = instructions,_metadata = metadata;
  factory _ExerciseDefinitionTemplate.fromJson(Map<String, dynamic> json) => _$ExerciseDefinitionTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  ExerciseCategory category;
@override final  ExerciseType type;
 final  List<String> _muscleGroups;
@override List<String> get muscleGroups {
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleGroups);
}

 final  List<String> _equipment;
@override List<String> get equipment {
  if (_equipment is EqualUnmodifiableListView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_equipment);
}

 final  List<String>? _instructions;
@override List<String>? get instructions {
  final value = _instructions;
  if (value == null) return null;
  if (_instructions is EqualUnmodifiableListView) return _instructions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? imageUrl;
@override final  String? videoUrl;
@override final  String? difficulty;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ExerciseDefinitionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseDefinitionTemplateCopyWith<_ExerciseDefinitionTemplate> get copyWith => __$ExerciseDefinitionTemplateCopyWithImpl<_ExerciseDefinitionTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseDefinitionTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseDefinitionTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._muscleGroups, _muscleGroups)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&const DeepCollectionEquality().equals(other._instructions, _instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,type,const DeepCollectionEquality().hash(_muscleGroups),const DeepCollectionEquality().hash(_equipment),const DeepCollectionEquality().hash(_instructions),imageUrl,videoUrl,difficulty,const DeepCollectionEquality().hash(_metadata),isActive,createdAt,updatedAt);

@override
String toString() {
  return 'ExerciseDefinitionTemplate(id: $id, name: $name, description: $description, category: $category, type: $type, muscleGroups: $muscleGroups, equipment: $equipment, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl, difficulty: $difficulty, metadata: $metadata, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ExerciseDefinitionTemplateCopyWith<$Res> implements $ExerciseDefinitionTemplateCopyWith<$Res> {
  factory _$ExerciseDefinitionTemplateCopyWith(_ExerciseDefinitionTemplate value, $Res Function(_ExerciseDefinitionTemplate) _then) = __$ExerciseDefinitionTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, ExerciseCategory category, ExerciseType type, List<String> muscleGroups, List<String> equipment, List<String>? instructions, String? imageUrl, String? videoUrl, String? difficulty, Map<String, dynamic>? metadata, bool isActive, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ExerciseDefinitionTemplateCopyWithImpl<$Res>
    implements _$ExerciseDefinitionTemplateCopyWith<$Res> {
  __$ExerciseDefinitionTemplateCopyWithImpl(this._self, this._then);

  final _ExerciseDefinitionTemplate _self;
  final $Res Function(_ExerciseDefinitionTemplate) _then;

/// Create a copy of ExerciseDefinitionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? category = null,Object? type = null,Object? muscleGroups = null,Object? equipment = null,Object? instructions = freezed,Object? imageUrl = freezed,Object? videoUrl = freezed,Object? difficulty = freezed,Object? metadata = freezed,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ExerciseDefinitionTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExerciseType,muscleGroups: null == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>,equipment: null == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>,instructions: freezed == instructions ? _self._instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
