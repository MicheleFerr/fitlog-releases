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
 List<String> get targetMuscles;
/// Create a copy of CommunityWorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityWorkoutTemplateCopyWith<CommunityWorkoutTemplate> get copyWith => _$CommunityWorkoutTemplateCopyWithImpl<CommunityWorkoutTemplate>(this as CommunityWorkoutTemplate, _$identity);

  /// Serializes this CommunityWorkoutTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityWorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.category, category) || other.category == category)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorPhotoUrl, authorPhotoUrl) || other.authorPhotoUrl == authorPhotoUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.difficultyLevel, difficultyLevel) || other.difficultyLevel == difficultyLevel)&&const DeepCollectionEquality().equals(other.requiredEquipment, requiredEquipment)&&const DeepCollectionEquality().equals(other.targetMuscles, targetMuscles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,description,const DeepCollectionEquality().hash(exercises),category,visibility,createdAt,updatedAt,downloadCount,likeCount,reviewCount,averageRating,authorName,authorPhotoUrl,const DeepCollectionEquality().hash(tags),folderId,estimatedDurationMinutes,difficultyLevel,const DeepCollectionEquality().hash(requiredEquipment),const DeepCollectionEquality().hash(targetMuscles)]);

@override
String toString() {
  return 'CommunityWorkoutTemplate(id: $id, userId: $userId, name: $name, description: $description, exercises: $exercises, category: $category, visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt, downloadCount: $downloadCount, likeCount: $likeCount, reviewCount: $reviewCount, averageRating: $averageRating, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, tags: $tags, folderId: $folderId, estimatedDurationMinutes: $estimatedDurationMinutes, difficultyLevel: $difficultyLevel, requiredEquipment: $requiredEquipment, targetMuscles: $targetMuscles)';
}


}

/// @nodoc
abstract mixin class $CommunityWorkoutTemplateCopyWith<$Res>  {
  factory $CommunityWorkoutTemplateCopyWith(CommunityWorkoutTemplate value, $Res Function(CommunityWorkoutTemplate) _then) = _$CommunityWorkoutTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? description, List<Exercise> exercises, TemplateCategory category, TemplateVisibility visibility, DateTime createdAt, DateTime? updatedAt, int downloadCount, int likeCount, int reviewCount, double averageRating, String? authorName, String? authorPhotoUrl, List<String> tags, String? folderId, int? estimatedDurationMinutes, String? difficultyLevel, List<String> requiredEquipment, List<String> targetMuscles
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? category = null,Object? visibility = null,Object? createdAt = null,Object? updatedAt = freezed,Object? downloadCount = null,Object? likeCount = null,Object? reviewCount = null,Object? averageRating = null,Object? authorName = freezed,Object? authorPhotoUrl = freezed,Object? tags = null,Object? folderId = freezed,Object? estimatedDurationMinutes = freezed,Object? difficultyLevel = freezed,Object? requiredEquipment = null,Object? targetMuscles = null,}) {
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
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  List<Exercise> exercises,  TemplateCategory category,  TemplateVisibility visibility,  DateTime createdAt,  DateTime? updatedAt,  int downloadCount,  int likeCount,  int reviewCount,  double averageRating,  String? authorName,  String? authorPhotoUrl,  List<String> tags,  String? folderId,  int? estimatedDurationMinutes,  String? difficultyLevel,  List<String> requiredEquipment,  List<String> targetMuscles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.exercises,_that.category,_that.visibility,_that.createdAt,_that.updatedAt,_that.downloadCount,_that.likeCount,_that.reviewCount,_that.averageRating,_that.authorName,_that.authorPhotoUrl,_that.tags,_that.folderId,_that.estimatedDurationMinutes,_that.difficultyLevel,_that.requiredEquipment,_that.targetMuscles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  List<Exercise> exercises,  TemplateCategory category,  TemplateVisibility visibility,  DateTime createdAt,  DateTime? updatedAt,  int downloadCount,  int likeCount,  int reviewCount,  double averageRating,  String? authorName,  String? authorPhotoUrl,  List<String> tags,  String? folderId,  int? estimatedDurationMinutes,  String? difficultyLevel,  List<String> requiredEquipment,  List<String> targetMuscles)  $default,) {final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.exercises,_that.category,_that.visibility,_that.createdAt,_that.updatedAt,_that.downloadCount,_that.likeCount,_that.reviewCount,_that.averageRating,_that.authorName,_that.authorPhotoUrl,_that.tags,_that.folderId,_that.estimatedDurationMinutes,_that.difficultyLevel,_that.requiredEquipment,_that.targetMuscles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? description,  List<Exercise> exercises,  TemplateCategory category,  TemplateVisibility visibility,  DateTime createdAt,  DateTime? updatedAt,  int downloadCount,  int likeCount,  int reviewCount,  double averageRating,  String? authorName,  String? authorPhotoUrl,  List<String> tags,  String? folderId,  int? estimatedDurationMinutes,  String? difficultyLevel,  List<String> requiredEquipment,  List<String> targetMuscles)?  $default,) {final _that = this;
switch (_that) {
case _CommunityWorkoutTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.exercises,_that.category,_that.visibility,_that.createdAt,_that.updatedAt,_that.downloadCount,_that.likeCount,_that.reviewCount,_that.averageRating,_that.authorName,_that.authorPhotoUrl,_that.tags,_that.folderId,_that.estimatedDurationMinutes,_that.difficultyLevel,_that.requiredEquipment,_that.targetMuscles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityWorkoutTemplate implements CommunityWorkoutTemplate {
  const _CommunityWorkoutTemplate({required this.id, required this.userId, required this.name, this.description, required final  List<Exercise> exercises, this.category = TemplateCategory.custom, this.visibility = TemplateVisibility.private, required this.createdAt, this.updatedAt, this.downloadCount = 0, this.likeCount = 0, this.reviewCount = 0, this.averageRating = 0.0, this.authorName, this.authorPhotoUrl, final  List<String> tags = const [], this.folderId, this.estimatedDurationMinutes, this.difficultyLevel, final  List<String> requiredEquipment = const [], final  List<String> targetMuscles = const []}): _exercises = exercises,_tags = tags,_requiredEquipment = requiredEquipment,_targetMuscles = targetMuscles;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityWorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.category, category) || other.category == category)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorPhotoUrl, authorPhotoUrl) || other.authorPhotoUrl == authorPhotoUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.difficultyLevel, difficultyLevel) || other.difficultyLevel == difficultyLevel)&&const DeepCollectionEquality().equals(other._requiredEquipment, _requiredEquipment)&&const DeepCollectionEquality().equals(other._targetMuscles, _targetMuscles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,description,const DeepCollectionEquality().hash(_exercises),category,visibility,createdAt,updatedAt,downloadCount,likeCount,reviewCount,averageRating,authorName,authorPhotoUrl,const DeepCollectionEquality().hash(_tags),folderId,estimatedDurationMinutes,difficultyLevel,const DeepCollectionEquality().hash(_requiredEquipment),const DeepCollectionEquality().hash(_targetMuscles)]);

@override
String toString() {
  return 'CommunityWorkoutTemplate(id: $id, userId: $userId, name: $name, description: $description, exercises: $exercises, category: $category, visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt, downloadCount: $downloadCount, likeCount: $likeCount, reviewCount: $reviewCount, averageRating: $averageRating, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, tags: $tags, folderId: $folderId, estimatedDurationMinutes: $estimatedDurationMinutes, difficultyLevel: $difficultyLevel, requiredEquipment: $requiredEquipment, targetMuscles: $targetMuscles)';
}


}

/// @nodoc
abstract mixin class _$CommunityWorkoutTemplateCopyWith<$Res> implements $CommunityWorkoutTemplateCopyWith<$Res> {
  factory _$CommunityWorkoutTemplateCopyWith(_CommunityWorkoutTemplate value, $Res Function(_CommunityWorkoutTemplate) _then) = __$CommunityWorkoutTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? description, List<Exercise> exercises, TemplateCategory category, TemplateVisibility visibility, DateTime createdAt, DateTime? updatedAt, int downloadCount, int likeCount, int reviewCount, double averageRating, String? authorName, String? authorPhotoUrl, List<String> tags, String? folderId, int? estimatedDurationMinutes, String? difficultyLevel, List<String> requiredEquipment, List<String> targetMuscles
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? exercises = null,Object? category = null,Object? visibility = null,Object? createdAt = null,Object? updatedAt = freezed,Object? downloadCount = null,Object? likeCount = null,Object? reviewCount = null,Object? averageRating = null,Object? authorName = freezed,Object? authorPhotoUrl = freezed,Object? tags = null,Object? folderId = freezed,Object? estimatedDurationMinutes = freezed,Object? difficultyLevel = freezed,Object? requiredEquipment = null,Object? targetMuscles = null,}) {
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
as List<String>,
  ));
}


}


/// @nodoc
mixin _$TemplateReview {

 String get id; String get templateId; String get userId; String get userName; String? get userPhotoUrl; double get rating;// 1-5 stelle
 String get comment; DateTime get createdAt; int get helpfulCount; List<String> get helpfulVoters;
/// Create a copy of TemplateReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateReviewCopyWith<TemplateReview> get copyWith => _$TemplateReviewCopyWithImpl<TemplateReview>(this as TemplateReview, _$identity);

  /// Serializes this TemplateReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateReview&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.helpfulCount, helpfulCount) || other.helpfulCount == helpfulCount)&&const DeepCollectionEquality().equals(other.helpfulVoters, helpfulVoters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateId,userId,userName,userPhotoUrl,rating,comment,createdAt,helpfulCount,const DeepCollectionEquality().hash(helpfulVoters));

@override
String toString() {
  return 'TemplateReview(id: $id, templateId: $templateId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, rating: $rating, comment: $comment, createdAt: $createdAt, helpfulCount: $helpfulCount, helpfulVoters: $helpfulVoters)';
}


}

/// @nodoc
abstract mixin class $TemplateReviewCopyWith<$Res>  {
  factory $TemplateReviewCopyWith(TemplateReview value, $Res Function(TemplateReview) _then) = _$TemplateReviewCopyWithImpl;
@useResult
$Res call({
 String id, String templateId, String userId, String userName, String? userPhotoUrl, double rating, String comment, DateTime createdAt, int helpfulCount, List<String> helpfulVoters
});




}
/// @nodoc
class _$TemplateReviewCopyWithImpl<$Res>
    implements $TemplateReviewCopyWith<$Res> {
  _$TemplateReviewCopyWithImpl(this._self, this._then);

  final TemplateReview _self;
  final $Res Function(TemplateReview) _then;

/// Create a copy of TemplateReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? templateId = null,Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? rating = null,Object? comment = null,Object? createdAt = null,Object? helpfulCount = null,Object? helpfulVoters = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,helpfulCount: null == helpfulCount ? _self.helpfulCount : helpfulCount // ignore: cast_nullable_to_non_nullable
as int,helpfulVoters: null == helpfulVoters ? _self.helpfulVoters : helpfulVoters // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateReview].
extension TemplateReviewPatterns on TemplateReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateReview value)  $default,){
final _that = this;
switch (_that) {
case _TemplateReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateReview value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String templateId,  String userId,  String userName,  String? userPhotoUrl,  double rating,  String comment,  DateTime createdAt,  int helpfulCount,  List<String> helpfulVoters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateReview() when $default != null:
return $default(_that.id,_that.templateId,_that.userId,_that.userName,_that.userPhotoUrl,_that.rating,_that.comment,_that.createdAt,_that.helpfulCount,_that.helpfulVoters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String templateId,  String userId,  String userName,  String? userPhotoUrl,  double rating,  String comment,  DateTime createdAt,  int helpfulCount,  List<String> helpfulVoters)  $default,) {final _that = this;
switch (_that) {
case _TemplateReview():
return $default(_that.id,_that.templateId,_that.userId,_that.userName,_that.userPhotoUrl,_that.rating,_that.comment,_that.createdAt,_that.helpfulCount,_that.helpfulVoters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String templateId,  String userId,  String userName,  String? userPhotoUrl,  double rating,  String comment,  DateTime createdAt,  int helpfulCount,  List<String> helpfulVoters)?  $default,) {final _that = this;
switch (_that) {
case _TemplateReview() when $default != null:
return $default(_that.id,_that.templateId,_that.userId,_that.userName,_that.userPhotoUrl,_that.rating,_that.comment,_that.createdAt,_that.helpfulCount,_that.helpfulVoters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateReview implements TemplateReview {
  const _TemplateReview({required this.id, required this.templateId, required this.userId, required this.userName, this.userPhotoUrl, required this.rating, required this.comment, required this.createdAt, this.helpfulCount = 0, final  List<String> helpfulVoters = const []}): _helpfulVoters = helpfulVoters;
  factory _TemplateReview.fromJson(Map<String, dynamic> json) => _$TemplateReviewFromJson(json);

@override final  String id;
@override final  String templateId;
@override final  String userId;
@override final  String userName;
@override final  String? userPhotoUrl;
@override final  double rating;
// 1-5 stelle
@override final  String comment;
@override final  DateTime createdAt;
@override@JsonKey() final  int helpfulCount;
 final  List<String> _helpfulVoters;
@override@JsonKey() List<String> get helpfulVoters {
  if (_helpfulVoters is EqualUnmodifiableListView) return _helpfulVoters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_helpfulVoters);
}


/// Create a copy of TemplateReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateReviewCopyWith<_TemplateReview> get copyWith => __$TemplateReviewCopyWithImpl<_TemplateReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateReview&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.helpfulCount, helpfulCount) || other.helpfulCount == helpfulCount)&&const DeepCollectionEquality().equals(other._helpfulVoters, _helpfulVoters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateId,userId,userName,userPhotoUrl,rating,comment,createdAt,helpfulCount,const DeepCollectionEquality().hash(_helpfulVoters));

@override
String toString() {
  return 'TemplateReview(id: $id, templateId: $templateId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, rating: $rating, comment: $comment, createdAt: $createdAt, helpfulCount: $helpfulCount, helpfulVoters: $helpfulVoters)';
}


}

/// @nodoc
abstract mixin class _$TemplateReviewCopyWith<$Res> implements $TemplateReviewCopyWith<$Res> {
  factory _$TemplateReviewCopyWith(_TemplateReview value, $Res Function(_TemplateReview) _then) = __$TemplateReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String templateId, String userId, String userName, String? userPhotoUrl, double rating, String comment, DateTime createdAt, int helpfulCount, List<String> helpfulVoters
});




}
/// @nodoc
class __$TemplateReviewCopyWithImpl<$Res>
    implements _$TemplateReviewCopyWith<$Res> {
  __$TemplateReviewCopyWithImpl(this._self, this._then);

  final _TemplateReview _self;
  final $Res Function(_TemplateReview) _then;

/// Create a copy of TemplateReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? templateId = null,Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? rating = null,Object? comment = null,Object? createdAt = null,Object? helpfulCount = null,Object? helpfulVoters = null,}) {
  return _then(_TemplateReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,helpfulCount: null == helpfulCount ? _self.helpfulCount : helpfulCount // ignore: cast_nullable_to_non_nullable
as int,helpfulVoters: null == helpfulVoters ? _self._helpfulVoters : helpfulVoters // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$TemplateComment {

 String get id; String get templateId; String get userId; String get userName; String? get userPhotoUrl; String get text; DateTime get createdAt; int get likeCount; List<String> get likedBy; String? get replyToId;
/// Create a copy of TemplateComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateCommentCopyWith<TemplateComment> get copyWith => _$TemplateCommentCopyWithImpl<TemplateComment>(this as TemplateComment, _$identity);

  /// Serializes this TemplateComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateComment&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&const DeepCollectionEquality().equals(other.likedBy, likedBy)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateId,userId,userName,userPhotoUrl,text,createdAt,likeCount,const DeepCollectionEquality().hash(likedBy),replyToId);

@override
String toString() {
  return 'TemplateComment(id: $id, templateId: $templateId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, text: $text, createdAt: $createdAt, likeCount: $likeCount, likedBy: $likedBy, replyToId: $replyToId)';
}


}

/// @nodoc
abstract mixin class $TemplateCommentCopyWith<$Res>  {
  factory $TemplateCommentCopyWith(TemplateComment value, $Res Function(TemplateComment) _then) = _$TemplateCommentCopyWithImpl;
@useResult
$Res call({
 String id, String templateId, String userId, String userName, String? userPhotoUrl, String text, DateTime createdAt, int likeCount, List<String> likedBy, String? replyToId
});




}
/// @nodoc
class _$TemplateCommentCopyWithImpl<$Res>
    implements $TemplateCommentCopyWith<$Res> {
  _$TemplateCommentCopyWithImpl(this._self, this._then);

  final TemplateComment _self;
  final $Res Function(TemplateComment) _then;

/// Create a copy of TemplateComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? templateId = null,Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? text = null,Object? createdAt = null,Object? likeCount = null,Object? likedBy = null,Object? replyToId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,likedBy: null == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateComment].
extension TemplateCommentPatterns on TemplateComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateComment value)  $default,){
final _that = this;
switch (_that) {
case _TemplateComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateComment value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String templateId,  String userId,  String userName,  String? userPhotoUrl,  String text,  DateTime createdAt,  int likeCount,  List<String> likedBy,  String? replyToId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateComment() when $default != null:
return $default(_that.id,_that.templateId,_that.userId,_that.userName,_that.userPhotoUrl,_that.text,_that.createdAt,_that.likeCount,_that.likedBy,_that.replyToId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String templateId,  String userId,  String userName,  String? userPhotoUrl,  String text,  DateTime createdAt,  int likeCount,  List<String> likedBy,  String? replyToId)  $default,) {final _that = this;
switch (_that) {
case _TemplateComment():
return $default(_that.id,_that.templateId,_that.userId,_that.userName,_that.userPhotoUrl,_that.text,_that.createdAt,_that.likeCount,_that.likedBy,_that.replyToId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String templateId,  String userId,  String userName,  String? userPhotoUrl,  String text,  DateTime createdAt,  int likeCount,  List<String> likedBy,  String? replyToId)?  $default,) {final _that = this;
switch (_that) {
case _TemplateComment() when $default != null:
return $default(_that.id,_that.templateId,_that.userId,_that.userName,_that.userPhotoUrl,_that.text,_that.createdAt,_that.likeCount,_that.likedBy,_that.replyToId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateComment implements TemplateComment {
  const _TemplateComment({required this.id, required this.templateId, required this.userId, required this.userName, this.userPhotoUrl, required this.text, required this.createdAt, this.likeCount = 0, final  List<String> likedBy = const [], this.replyToId}): _likedBy = likedBy;
  factory _TemplateComment.fromJson(Map<String, dynamic> json) => _$TemplateCommentFromJson(json);

@override final  String id;
@override final  String templateId;
@override final  String userId;
@override final  String userName;
@override final  String? userPhotoUrl;
@override final  String text;
@override final  DateTime createdAt;
@override@JsonKey() final  int likeCount;
 final  List<String> _likedBy;
@override@JsonKey() List<String> get likedBy {
  if (_likedBy is EqualUnmodifiableListView) return _likedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedBy);
}

@override final  String? replyToId;

/// Create a copy of TemplateComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateCommentCopyWith<_TemplateComment> get copyWith => __$TemplateCommentCopyWithImpl<_TemplateComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateComment&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&const DeepCollectionEquality().equals(other._likedBy, _likedBy)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateId,userId,userName,userPhotoUrl,text,createdAt,likeCount,const DeepCollectionEquality().hash(_likedBy),replyToId);

@override
String toString() {
  return 'TemplateComment(id: $id, templateId: $templateId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, text: $text, createdAt: $createdAt, likeCount: $likeCount, likedBy: $likedBy, replyToId: $replyToId)';
}


}

/// @nodoc
abstract mixin class _$TemplateCommentCopyWith<$Res> implements $TemplateCommentCopyWith<$Res> {
  factory _$TemplateCommentCopyWith(_TemplateComment value, $Res Function(_TemplateComment) _then) = __$TemplateCommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String templateId, String userId, String userName, String? userPhotoUrl, String text, DateTime createdAt, int likeCount, List<String> likedBy, String? replyToId
});




}
/// @nodoc
class __$TemplateCommentCopyWithImpl<$Res>
    implements _$TemplateCommentCopyWith<$Res> {
  __$TemplateCommentCopyWithImpl(this._self, this._then);

  final _TemplateComment _self;
  final $Res Function(_TemplateComment) _then;

/// Create a copy of TemplateComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? templateId = null,Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? text = null,Object? createdAt = null,Object? likeCount = null,Object? likedBy = null,Object? replyToId = freezed,}) {
  return _then(_TemplateComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,likedBy: null == likedBy ? _self._likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
