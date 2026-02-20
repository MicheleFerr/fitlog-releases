// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunityWorkoutTemplate {

 String get id; String get userId; String get name; String? get description; List<Exercise> get exercises;// Default to 'custom' for templates created before category was added
 TemplateCategory get category;// Default to 'private' for templates created before visibility was added
 TemplateVisibility get visibility;// Metadata
 DateTime get createdAt; DateTime? get updatedAt;// Stats pubbliche
 int get downloadCount; int get likeCount; int get reviewCount; double get averageRating;// Info autore
 String? get authorName; String? get authorPhotoUrl;// Tags per ricerca
 List<String> get tags;// Folder organization (P2-3)
 String? get folderId;// Durata stimata in minuti
 int? get estimatedDurationMinutes;// Livello difficoltà
 String? get difficultyLevel;// beginner, intermediate, advanced, expert
// Equipment necessario
 List<String> get requiredEquipment;// Muscoli target
 List<String> get targetMuscles;// GDPR: Pubblicazione anonima
 bool get isAnonymous;// Fork attribution
 String? get forkedFromTemplateId; String? get originalAuthorName;
/// Create a copy of CommunityWorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityWorkoutTemplateCopyWith<CommunityWorkoutTemplate> get copyWith => _$CommunityWorkoutTemplateCopyWithImpl<CommunityWorkoutTemplate>(this as CommunityWorkoutTemplate, _$identity);

  /// Serializes this CommunityWorkoutTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityWorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.category, category) || other.category == category)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorPhotoUrl, authorPhotoUrl) || other.authorPhotoUrl == authorPhotoUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.difficultyLevel, difficultyLevel) || other.difficultyLevel == difficultyLevel)&&const DeepCollectionEquality().equals(other.requiredEquipment, requiredEquipment)&&const DeepCollectionEquality().equals(other.targetMuscles, targetMuscles)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.forkedFromTemplateId, forkedFromTemplateId) || other.forkedFromTemplateId == forkedFromTemplateId)&&(identical(other.originalAuthorName, originalAuthorName) || other.originalAuthorName == originalAuthorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,description,const DeepCollectionEquality().hash(exercises),category,visibility,createdAt,updatedAt,downloadCount,likeCount,reviewCount,averageRating,authorName,authorPhotoUrl,const DeepCollectionEquality().hash(tags),folderId,estimatedDurationMinutes,difficultyLevel,const DeepCollectionEquality().hash(requiredEquipment),const DeepCollectionEquality().hash(targetMuscles),isAnonymous,forkedFromTemplateId,originalAuthorName]);

@override
String toString() {
  return 'CommunityWorkoutTemplate(id: $id, userId: $userId, name: $name, description: $description, exercises: $exercises, category: $category, visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt, downloadCount: $downloadCount, likeCount: $likeCount, reviewCount: $reviewCount, averageRating: $averageRating, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, tags: $tags, folderId: $folderId, estimatedDurationMinutes: $estimatedDurationMinutes, difficultyLevel: $difficultyLevel, requiredEquipment: $requiredEquipment, targetMuscles: $targetMuscles, isAnonymous: $isAnonymous, forkedFromTemplateId: $forkedFromTemplateId, originalAuthorName: $originalAuthorName)';
}


}

/// @nodoc
abstract mixin class $CommunityWorkoutTemplateCopyWith<$Res>  {
  factory $CommunityWorkoutTemplateCopyWith(CommunityWorkoutTemplate value, $Res Function(CommunityWorkoutTemplate) _then) = _$CommunityWorkoutTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? description, List<Exercise> exercises, TemplateCategory category, TemplateVisibility visibility, DateTime createdAt, DateTime? updatedAt, int downloadCount, int likeCount, int reviewCount, double averageRating, String? authorName, String? authorPhotoUrl, List<String> tags, String? folderId, int? estimatedDurationMinutes, String? difficultyLevel, List<String> requiredEquipment, List<String> targetMuscles, bool isAnonymous, String? forkedFromTemplateId, String? originalAuthorName
});




}
/// @nodoc
class _$CommunityWorkoutTemplateCopyWithImpl<$Res>
    implements $CommunityWorkoutTemplateCopyWith<$Res> {
  _$CommunityWorkoutTemplateCopyWithImpl(this._self, this._then);

  final CommunityWorkoutTemplate _self;
  final $Res Function(CommunityWorkoutTemplate) _then;

/// Create a copy of CommunityWorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? category = null,Object? visibility = null,Object? createdAt = null,Object? updatedAt = freezed,Object? downloadCount = null,Object? likeCount = null,Object? reviewCount = null,Object? averageRating = null,Object? authorName = freezed,Object? authorPhotoUrl = freezed,Object? tags = null,Object? folderId = freezed,Object? estimatedDurationMinutes = freezed,Object? difficultyLevel = freezed,Object? requiredEquipment = null,Object? targetMuscles = null,Object? isAnonymous = null,Object? forkedFromTemplateId = freezed,Object? originalAuthorName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TemplateCategory,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as TemplateVisibility,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,authorPhotoUrl: freezed == authorPhotoUrl ? _self.authorPhotoUrl : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,difficultyLevel: freezed == difficultyLevel ? _self.difficultyLevel : difficultyLevel // ignore: cast_nullable_to_non_nullable
as String?,requiredEquipment: null == requiredEquipment ? _self.requiredEquipment : requiredEquipment // ignore: cast_nullable_to_non_nullable
as List<String>,targetMuscles: null == targetMuscles ? _self.targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,forkedFromTemplateId: freezed == forkedFromTemplateId ? _self.forkedFromTemplateId : forkedFromTemplateId // ignore: cast_nullable_to_non_nullable
as String?,originalAuthorName: freezed == originalAuthorName ? _self.originalAuthorName : originalAuthorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityWorkoutTemplate].
extension CommunityWorkoutTemplatePatterns on CommunityWorkoutTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityWorkoutTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityWorkoutTemplate value)  $default,){
final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityWorkoutTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  List<Exercise> exercises,  TemplateCategory category,  TemplateVisibility visibility,  DateTime createdAt,  DateTime? updatedAt,  int downloadCount,  int likeCount,  int reviewCount,  double averageRating,  String? authorName,  String? authorPhotoUrl,  List<String> tags,  String? folderId,  int? estimatedDurationMinutes,  String? difficultyLevel,  List<String> requiredEquipment,  List<String> targetMuscles,  bool isAnonymous,  String? forkedFromTemplateId,  String? originalAuthorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.exercises,_that.category,_that.visibility,_that.createdAt,_that.updatedAt,_that.downloadCount,_that.likeCount,_that.reviewCount,_that.averageRating,_that.authorName,_that.authorPhotoUrl,_that.tags,_that.folderId,_that.estimatedDurationMinutes,_that.difficultyLevel,_that.requiredEquipment,_that.targetMuscles,_that.isAnonymous,_that.forkedFromTemplateId,_that.originalAuthorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  List<Exercise> exercises,  TemplateCategory category,  TemplateVisibility visibility,  DateTime createdAt,  DateTime? updatedAt,  int downloadCount,  int likeCount,  int reviewCount,  double averageRating,  String? authorName,  String? authorPhotoUrl,  List<String> tags,  String? folderId,  int? estimatedDurationMinutes,  String? difficultyLevel,  List<String> requiredEquipment,  List<String> targetMuscles,  bool isAnonymous,  String? forkedFromTemplateId,  String? originalAuthorName)  $default,) {final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.exercises,_that.category,_that.visibility,_that.createdAt,_that.updatedAt,_that.downloadCount,_that.likeCount,_that.reviewCount,_that.averageRating,_that.authorName,_that.authorPhotoUrl,_that.tags,_that.folderId,_that.estimatedDurationMinutes,_that.difficultyLevel,_that.requiredEquipment,_that.targetMuscles,_that.isAnonymous,_that.forkedFromTemplateId,_that.originalAuthorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? description,  List<Exercise> exercises,  TemplateCategory category,  TemplateVisibility visibility,  DateTime createdAt,  DateTime? updatedAt,  int downloadCount,  int likeCount,  int reviewCount,  double averageRating,  String? authorName,  String? authorPhotoUrl,  List<String> tags,  String? folderId,  int? estimatedDurationMinutes,  String? difficultyLevel,  List<String> requiredEquipment,  List<String> targetMuscles,  bool isAnonymous,  String? forkedFromTemplateId,  String? originalAuthorName)?  $default,) {final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.exercises,_that.category,_that.visibility,_that.createdAt,_that.updatedAt,_that.downloadCount,_that.likeCount,_that.reviewCount,_that.averageRating,_that.authorName,_that.authorPhotoUrl,_that.tags,_that.folderId,_that.estimatedDurationMinutes,_that.difficultyLevel,_that.requiredEquipment,_that.targetMuscles,_that.isAnonymous,_that.forkedFromTemplateId,_that.originalAuthorName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityWorkoutTemplate implements CommunityWorkoutTemplate {
  const _CommunityWorkoutTemplate({required this.id, required this.userId, required this.name, this.description, required final  List<Exercise> exercises, this.category = TemplateCategory.custom, this.visibility = TemplateVisibility.private, required this.createdAt, this.updatedAt, this.downloadCount = 0, this.likeCount = 0, this.reviewCount = 0, this.averageRating = 0.0, this.authorName, this.authorPhotoUrl, final  List<String> tags = const [], this.folderId, this.estimatedDurationMinutes, this.difficultyLevel, final  List<String> requiredEquipment = const [], final  List<String> targetMuscles = const [], this.isAnonymous = false, this.forkedFromTemplateId, this.originalAuthorName}): _exercises = exercises,_tags = tags,_requiredEquipment = requiredEquipment,_targetMuscles = targetMuscles;
  factory _CommunityWorkoutTemplate.fromJson(Map<String, dynamic> json) => _$CommunityWorkoutTemplateFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String? description;
 final  List<Exercise> _exercises;
@override List<Exercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

// Default to 'custom' for templates created before category was added
@override@JsonKey() final  TemplateCategory category;
// Default to 'private' for templates created before visibility was added
@override@JsonKey() final  TemplateVisibility visibility;
// Metadata
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
// Stats pubbliche
@override@JsonKey() final  int downloadCount;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int reviewCount;
@override@JsonKey() final  double averageRating;
// Info autore
@override final  String? authorName;
@override final  String? authorPhotoUrl;
// Tags per ricerca
 final  List<String> _tags;
// Tags per ricerca
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

// Folder organization (P2-3)
@override final  String? folderId;
// Durata stimata in minuti
@override final  int? estimatedDurationMinutes;
// Livello difficoltà
@override final  String? difficultyLevel;
// beginner, intermediate, advanced, expert
// Equipment necessario
 final  List<String> _requiredEquipment;
// beginner, intermediate, advanced, expert
// Equipment necessario
@override@JsonKey() List<String> get requiredEquipment {
  if (_requiredEquipment is EqualUnmodifiableListView) return _requiredEquipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredEquipment);
}

// Muscoli target
 final  List<String> _targetMuscles;
// Muscoli target
@override@JsonKey() List<String> get targetMuscles {
  if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetMuscles);
}

// GDPR: Pubblicazione anonima
@override@JsonKey() final  bool isAnonymous;
// Fork attribution
@override final  String? forkedFromTemplateId;
@override final  String? originalAuthorName;

/// Create a copy of CommunityWorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityWorkoutTemplateCopyWith<_CommunityWorkoutTemplate> get copyWith => __$CommunityWorkoutTemplateCopyWithImpl<_CommunityWorkoutTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityWorkoutTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityWorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.category, category) || other.category == category)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorPhotoUrl, authorPhotoUrl) || other.authorPhotoUrl == authorPhotoUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.difficultyLevel, difficultyLevel) || other.difficultyLevel == difficultyLevel)&&const DeepCollectionEquality().equals(other._requiredEquipment, _requiredEquipment)&&const DeepCollectionEquality().equals(other._targetMuscles, _targetMuscles)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.forkedFromTemplateId, forkedFromTemplateId) || other.forkedFromTemplateId == forkedFromTemplateId)&&(identical(other.originalAuthorName, originalAuthorName) || other.originalAuthorName == originalAuthorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,description,const DeepCollectionEquality().hash(_exercises),category,visibility,createdAt,updatedAt,downloadCount,likeCount,reviewCount,averageRating,authorName,authorPhotoUrl,const DeepCollectionEquality().hash(_tags),folderId,estimatedDurationMinutes,difficultyLevel,const DeepCollectionEquality().hash(_requiredEquipment),const DeepCollectionEquality().hash(_targetMuscles),isAnonymous,forkedFromTemplateId,originalAuthorName]);

@override
String toString() {
  return 'CommunityWorkoutTemplate(id: $id, userId: $userId, name: $name, description: $description, exercises: $exercises, category: $category, visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt, downloadCount: $downloadCount, likeCount: $likeCount, reviewCount: $reviewCount, averageRating: $averageRating, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, tags: $tags, folderId: $folderId, estimatedDurationMinutes: $estimatedDurationMinutes, difficultyLevel: $difficultyLevel, requiredEquipment: $requiredEquipment, targetMuscles: $targetMuscles, isAnonymous: $isAnonymous, forkedFromTemplateId: $forkedFromTemplateId, originalAuthorName: $originalAuthorName)';
}


}

/// @nodoc
abstract mixin class _$CommunityWorkoutTemplateCopyWith<$Res> implements $CommunityWorkoutTemplateCopyWith<$Res> {
  factory _$CommunityWorkoutTemplateCopyWith(_CommunityWorkoutTemplate value, $Res Function(_CommunityWorkoutTemplate) _then) = __$CommunityWorkoutTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? description, List<Exercise> exercises, TemplateCategory category, TemplateVisibility visibility, DateTime createdAt, DateTime? updatedAt, int downloadCount, int likeCount, int reviewCount, double averageRating, String? authorName, String? authorPhotoUrl, List<String> tags, String? folderId, int? estimatedDurationMinutes, String? difficultyLevel, List<String> requiredEquipment, List<String> targetMuscles, bool isAnonymous, String? forkedFromTemplateId, String? originalAuthorName
});




}
/// @nodoc
class __$CommunityWorkoutTemplateCopyWithImpl<$Res>
    implements _$CommunityWorkoutTemplateCopyWith<$Res> {
  __$CommunityWorkoutTemplateCopyWithImpl(this._self, this._then);

  final _CommunityWorkoutTemplate _self;
  final $Res Function(_CommunityWorkoutTemplate) _then;

/// Create a copy of CommunityWorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? category = null,Object? visibility = null,Object? createdAt = null,Object? updatedAt = freezed,Object? downloadCount = null,Object? likeCount = null,Object? reviewCount = null,Object? averageRating = null,Object? authorName = freezed,Object? authorPhotoUrl = freezed,Object? tags = null,Object? folderId = freezed,Object? estimatedDurationMinutes = freezed,Object? difficultyLevel = freezed,Object? requiredEquipment = null,Object? targetMuscles = null,Object? isAnonymous = null,Object? forkedFromTemplateId = freezed,Object? originalAuthorName = freezed,}) {
  return _then(_CommunityWorkoutTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TemplateCategory,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as TemplateVisibility,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,authorPhotoUrl: freezed == authorPhotoUrl ? _self.authorPhotoUrl : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,difficultyLevel: freezed == difficultyLevel ? _self.difficultyLevel : difficultyLevel // ignore: cast_nullable_to_non_nullable
as String?,requiredEquipment: null == requiredEquipment ? _self._requiredEquipment : requiredEquipment // ignore: cast_nullable_to_non_nullable
as List<String>,targetMuscles: null == targetMuscles ? _self._targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,forkedFromTemplateId: freezed == forkedFromTemplateId ? _self.forkedFromTemplateId : forkedFromTemplateId // ignore: cast_nullable_to_non_nullable
as String?,originalAuthorName: freezed == originalAuthorName ? _self.originalAuthorName : originalAuthorName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
