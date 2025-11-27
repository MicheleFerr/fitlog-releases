// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunityContribution {

 String get id; String get exerciseId; String get exerciseName; String get userId; String get userName; String? get userAvatar; ContributionType get type; ContributionStatus get status; String get title; String get description; String? get originalValue; String? get suggestedValue; int get upvotes; int get downvotes; List<String> get upvotedBy; List<String> get downvotedBy; List<ContributionComment> get comments; String? get reviewNote; String? get reviewedBy; DateTime? get reviewedAt; DateTime get createdAt; DateTime? get updatedAt; bool get isFeatured; int get trustScore;// 0-100 basato su track record utente
 Map<String, dynamic>? get metadata;// NEW: Discovery & Search fields
 List<String> get exerciseIds;// Multiple exercises (was single exerciseId)
 String get difficulty;// beginner, intermediate, advanced
 List<String> get tags;// User-added tags (lowercase, max 5)
 List<String> get applicableTo;// Goals: hypertrophy, strength, mobility
 String? get authorTier;// community, expert, admin (nullable for backward compat)
 double get authorTrustScore;// 0-1
 double get qualityScore;// 0-1 (aggregate score)
 int get saves;// How many users saved
 int get viewCount;// Track popularity
 DateTime? get lastActivityAt;// For trending
 String? get sourceType;// exerciseDb, userSubmitted
 List<String> get relatedExerciseIds;
/// Create a copy of CommunityContribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityContributionCopyWith<CommunityContribution> get copyWith => _$CommunityContributionCopyWithImpl<CommunityContribution>(this as CommunityContribution, _$identity);

  /// Serializes this CommunityContribution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.originalValue, originalValue) || other.originalValue == originalValue)&&(identical(other.suggestedValue, suggestedValue) || other.suggestedValue == suggestedValue)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&const DeepCollectionEquality().equals(other.upvotedBy, upvotedBy)&&const DeepCollectionEquality().equals(other.downvotedBy, downvotedBy)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.exerciseIds, exerciseIds)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.applicableTo, applicableTo)&&(identical(other.authorTier, authorTier) || other.authorTier == authorTier)&&(identical(other.authorTrustScore, authorTrustScore) || other.authorTrustScore == authorTrustScore)&&(identical(other.qualityScore, qualityScore) || other.qualityScore == qualityScore)&&(identical(other.saves, saves) || other.saves == saves)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&const DeepCollectionEquality().equals(other.relatedExerciseIds, relatedExerciseIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,exerciseName,userId,userName,userAvatar,type,status,title,description,originalValue,suggestedValue,upvotes,downvotes,const DeepCollectionEquality().hash(upvotedBy),const DeepCollectionEquality().hash(downvotedBy),const DeepCollectionEquality().hash(comments),reviewNote,reviewedBy,reviewedAt,createdAt,updatedAt,isFeatured,trustScore,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(exerciseIds),difficulty,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(applicableTo),authorTier,authorTrustScore,qualityScore,saves,viewCount,lastActivityAt,sourceType,const DeepCollectionEquality().hash(relatedExerciseIds)]);

@override
String toString() {
  return 'CommunityContribution(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, userId: $userId, userName: $userName, userAvatar: $userAvatar, type: $type, status: $status, title: $title, description: $description, originalValue: $originalValue, suggestedValue: $suggestedValue, upvotes: $upvotes, downvotes: $downvotes, upvotedBy: $upvotedBy, downvotedBy: $downvotedBy, comments: $comments, reviewNote: $reviewNote, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt, isFeatured: $isFeatured, trustScore: $trustScore, metadata: $metadata, exerciseIds: $exerciseIds, difficulty: $difficulty, tags: $tags, applicableTo: $applicableTo, authorTier: $authorTier, authorTrustScore: $authorTrustScore, qualityScore: $qualityScore, saves: $saves, viewCount: $viewCount, lastActivityAt: $lastActivityAt, sourceType: $sourceType, relatedExerciseIds: $relatedExerciseIds)';
}


}

/// @nodoc
abstract mixin class $CommunityContributionCopyWith<$Res>  {
  factory $CommunityContributionCopyWith(CommunityContribution value, $Res Function(CommunityContribution) _then) = _$CommunityContributionCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String exerciseName, String userId, String userName, String? userAvatar, ContributionType type, ContributionStatus status, String title, String description, String? originalValue, String? suggestedValue, int upvotes, int downvotes, List<String> upvotedBy, List<String> downvotedBy, List<ContributionComment> comments, String? reviewNote, String? reviewedBy, DateTime? reviewedAt, DateTime createdAt, DateTime? updatedAt, bool isFeatured, int trustScore, Map<String, dynamic>? metadata, List<String> exerciseIds, String difficulty, List<String> tags, List<String> applicableTo, String? authorTier, double authorTrustScore, double qualityScore, int saves, int viewCount, DateTime? lastActivityAt, String? sourceType, List<String> relatedExerciseIds
});




}
/// @nodoc
class _$CommunityContributionCopyWithImpl<$Res>
    implements $CommunityContributionCopyWith<$Res> {
  _$CommunityContributionCopyWithImpl(this._self, this._then);

  final CommunityContribution _self;
  final $Res Function(CommunityContribution) _then;

/// Create a copy of CommunityContribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? userId = null,Object? userName = null,Object? userAvatar = freezed,Object? type = null,Object? status = null,Object? title = null,Object? description = null,Object? originalValue = freezed,Object? suggestedValue = freezed,Object? upvotes = null,Object? downvotes = null,Object? upvotedBy = null,Object? downvotedBy = null,Object? comments = null,Object? reviewNote = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? isFeatured = null,Object? trustScore = null,Object? metadata = freezed,Object? exerciseIds = null,Object? difficulty = null,Object? tags = null,Object? applicableTo = null,Object? authorTier = freezed,Object? authorTrustScore = null,Object? qualityScore = null,Object? saves = null,Object? viewCount = null,Object? lastActivityAt = freezed,Object? sourceType = freezed,Object? relatedExerciseIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContributionType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,originalValue: freezed == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as String?,suggestedValue: freezed == suggestedValue ? _self.suggestedValue : suggestedValue // ignore: cast_nullable_to_non_nullable
as String?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,upvotedBy: null == upvotedBy ? _self.upvotedBy : upvotedBy // ignore: cast_nullable_to_non_nullable
as List<String>,downvotedBy: null == downvotedBy ? _self.downvotedBy : downvotedBy // ignore: cast_nullable_to_non_nullable
as List<String>,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<ContributionComment>,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,exerciseIds: null == exerciseIds ? _self.exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,applicableTo: null == applicableTo ? _self.applicableTo : applicableTo // ignore: cast_nullable_to_non_nullable
as List<String>,authorTier: freezed == authorTier ? _self.authorTier : authorTier // ignore: cast_nullable_to_non_nullable
as String?,authorTrustScore: null == authorTrustScore ? _self.authorTrustScore : authorTrustScore // ignore: cast_nullable_to_non_nullable
as double,qualityScore: null == qualityScore ? _self.qualityScore : qualityScore // ignore: cast_nullable_to_non_nullable
as double,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sourceType: freezed == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String?,relatedExerciseIds: null == relatedExerciseIds ? _self.relatedExerciseIds : relatedExerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityContribution].
extension CommunityContributionPatterns on CommunityContribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityContribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityContribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityContribution value)  $default,){
final _that = this;
switch (_that) {
case _CommunityContribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityContribution value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityContribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String userId,  String userName,  String? userAvatar,  ContributionType type,  ContributionStatus status,  String title,  String description,  String? originalValue,  String? suggestedValue,  int upvotes,  int downvotes,  List<String> upvotedBy,  List<String> downvotedBy,  List<ContributionComment> comments,  String? reviewNote,  String? reviewedBy,  DateTime? reviewedAt,  DateTime createdAt,  DateTime? updatedAt,  bool isFeatured,  int trustScore,  Map<String, dynamic>? metadata,  List<String> exerciseIds,  String difficulty,  List<String> tags,  List<String> applicableTo,  String? authorTier,  double authorTrustScore,  double qualityScore,  int saves,  int viewCount,  DateTime? lastActivityAt,  String? sourceType,  List<String> relatedExerciseIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityContribution() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.userId,_that.userName,_that.userAvatar,_that.type,_that.status,_that.title,_that.description,_that.originalValue,_that.suggestedValue,_that.upvotes,_that.downvotes,_that.upvotedBy,_that.downvotedBy,_that.comments,_that.reviewNote,_that.reviewedBy,_that.reviewedAt,_that.createdAt,_that.updatedAt,_that.isFeatured,_that.trustScore,_that.metadata,_that.exerciseIds,_that.difficulty,_that.tags,_that.applicableTo,_that.authorTier,_that.authorTrustScore,_that.qualityScore,_that.saves,_that.viewCount,_that.lastActivityAt,_that.sourceType,_that.relatedExerciseIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String exerciseName,  String userId,  String userName,  String? userAvatar,  ContributionType type,  ContributionStatus status,  String title,  String description,  String? originalValue,  String? suggestedValue,  int upvotes,  int downvotes,  List<String> upvotedBy,  List<String> downvotedBy,  List<ContributionComment> comments,  String? reviewNote,  String? reviewedBy,  DateTime? reviewedAt,  DateTime createdAt,  DateTime? updatedAt,  bool isFeatured,  int trustScore,  Map<String, dynamic>? metadata,  List<String> exerciseIds,  String difficulty,  List<String> tags,  List<String> applicableTo,  String? authorTier,  double authorTrustScore,  double qualityScore,  int saves,  int viewCount,  DateTime? lastActivityAt,  String? sourceType,  List<String> relatedExerciseIds)  $default,) {final _that = this;
switch (_that) {
case _CommunityContribution():
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.userId,_that.userName,_that.userAvatar,_that.type,_that.status,_that.title,_that.description,_that.originalValue,_that.suggestedValue,_that.upvotes,_that.downvotes,_that.upvotedBy,_that.downvotedBy,_that.comments,_that.reviewNote,_that.reviewedBy,_that.reviewedAt,_that.createdAt,_that.updatedAt,_that.isFeatured,_that.trustScore,_that.metadata,_that.exerciseIds,_that.difficulty,_that.tags,_that.applicableTo,_that.authorTier,_that.authorTrustScore,_that.qualityScore,_that.saves,_that.viewCount,_that.lastActivityAt,_that.sourceType,_that.relatedExerciseIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String exerciseName,  String userId,  String userName,  String? userAvatar,  ContributionType type,  ContributionStatus status,  String title,  String description,  String? originalValue,  String? suggestedValue,  int upvotes,  int downvotes,  List<String> upvotedBy,  List<String> downvotedBy,  List<ContributionComment> comments,  String? reviewNote,  String? reviewedBy,  DateTime? reviewedAt,  DateTime createdAt,  DateTime? updatedAt,  bool isFeatured,  int trustScore,  Map<String, dynamic>? metadata,  List<String> exerciseIds,  String difficulty,  List<String> tags,  List<String> applicableTo,  String? authorTier,  double authorTrustScore,  double qualityScore,  int saves,  int viewCount,  DateTime? lastActivityAt,  String? sourceType,  List<String> relatedExerciseIds)?  $default,) {final _that = this;
switch (_that) {
case _CommunityContribution() when $default != null:
return $default(_that.id,_that.exerciseId,_that.exerciseName,_that.userId,_that.userName,_that.userAvatar,_that.type,_that.status,_that.title,_that.description,_that.originalValue,_that.suggestedValue,_that.upvotes,_that.downvotes,_that.upvotedBy,_that.downvotedBy,_that.comments,_that.reviewNote,_that.reviewedBy,_that.reviewedAt,_that.createdAt,_that.updatedAt,_that.isFeatured,_that.trustScore,_that.metadata,_that.exerciseIds,_that.difficulty,_that.tags,_that.applicableTo,_that.authorTier,_that.authorTrustScore,_that.qualityScore,_that.saves,_that.viewCount,_that.lastActivityAt,_that.sourceType,_that.relatedExerciseIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityContribution implements CommunityContribution {
  const _CommunityContribution({required this.id, required this.exerciseId, required this.exerciseName, required this.userId, required this.userName, this.userAvatar, required this.type, required this.status, required this.title, required this.description, this.originalValue, this.suggestedValue, this.upvotes = 0, this.downvotes = 0, final  List<String> upvotedBy = const [], final  List<String> downvotedBy = const [], final  List<ContributionComment> comments = const [], this.reviewNote, this.reviewedBy, this.reviewedAt, required this.createdAt, this.updatedAt, this.isFeatured = false, this.trustScore = 0, final  Map<String, dynamic>? metadata, final  List<String> exerciseIds = const [], this.difficulty = 'beginner', final  List<String> tags = const [], final  List<String> applicableTo = const [], this.authorTier, this.authorTrustScore = 0.5, this.qualityScore = 0.5, this.saves = 0, this.viewCount = 0, this.lastActivityAt, this.sourceType, final  List<String> relatedExerciseIds = const []}): _upvotedBy = upvotedBy,_downvotedBy = downvotedBy,_comments = comments,_metadata = metadata,_exerciseIds = exerciseIds,_tags = tags,_applicableTo = applicableTo,_relatedExerciseIds = relatedExerciseIds;
  factory _CommunityContribution.fromJson(Map<String, dynamic> json) => _$CommunityContributionFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String exerciseName;
@override final  String userId;
@override final  String userName;
@override final  String? userAvatar;
@override final  ContributionType type;
@override final  ContributionStatus status;
@override final  String title;
@override final  String description;
@override final  String? originalValue;
@override final  String? suggestedValue;
@override@JsonKey() final  int upvotes;
@override@JsonKey() final  int downvotes;
 final  List<String> _upvotedBy;
@override@JsonKey() List<String> get upvotedBy {
  if (_upvotedBy is EqualUnmodifiableListView) return _upvotedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upvotedBy);
}

 final  List<String> _downvotedBy;
@override@JsonKey() List<String> get downvotedBy {
  if (_downvotedBy is EqualUnmodifiableListView) return _downvotedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_downvotedBy);
}

 final  List<ContributionComment> _comments;
@override@JsonKey() List<ContributionComment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@override final  String? reviewNote;
@override final  String? reviewedBy;
@override final  DateTime? reviewedAt;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isFeatured;
@override@JsonKey() final  int trustScore;
// 0-100 basato su track record utente
 final  Map<String, dynamic>? _metadata;
// 0-100 basato su track record utente
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// NEW: Discovery & Search fields
 final  List<String> _exerciseIds;
// NEW: Discovery & Search fields
@override@JsonKey() List<String> get exerciseIds {
  if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseIds);
}

// Multiple exercises (was single exerciseId)
@override@JsonKey() final  String difficulty;
// beginner, intermediate, advanced
 final  List<String> _tags;
// beginner, intermediate, advanced
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

// User-added tags (lowercase, max 5)
 final  List<String> _applicableTo;
// User-added tags (lowercase, max 5)
@override@JsonKey() List<String> get applicableTo {
  if (_applicableTo is EqualUnmodifiableListView) return _applicableTo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_applicableTo);
}

// Goals: hypertrophy, strength, mobility
@override final  String? authorTier;
// community, expert, admin (nullable for backward compat)
@override@JsonKey() final  double authorTrustScore;
// 0-1
@override@JsonKey() final  double qualityScore;
// 0-1 (aggregate score)
@override@JsonKey() final  int saves;
// How many users saved
@override@JsonKey() final  int viewCount;
// Track popularity
@override final  DateTime? lastActivityAt;
// For trending
@override final  String? sourceType;
// exerciseDb, userSubmitted
 final  List<String> _relatedExerciseIds;
// exerciseDb, userSubmitted
@override@JsonKey() List<String> get relatedExerciseIds {
  if (_relatedExerciseIds is EqualUnmodifiableListView) return _relatedExerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedExerciseIds);
}


/// Create a copy of CommunityContribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityContributionCopyWith<_CommunityContribution> get copyWith => __$CommunityContributionCopyWithImpl<_CommunityContribution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityContributionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.originalValue, originalValue) || other.originalValue == originalValue)&&(identical(other.suggestedValue, suggestedValue) || other.suggestedValue == suggestedValue)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&const DeepCollectionEquality().equals(other._upvotedBy, _upvotedBy)&&const DeepCollectionEquality().equals(other._downvotedBy, _downvotedBy)&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._exerciseIds, _exerciseIds)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._applicableTo, _applicableTo)&&(identical(other.authorTier, authorTier) || other.authorTier == authorTier)&&(identical(other.authorTrustScore, authorTrustScore) || other.authorTrustScore == authorTrustScore)&&(identical(other.qualityScore, qualityScore) || other.qualityScore == qualityScore)&&(identical(other.saves, saves) || other.saves == saves)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&const DeepCollectionEquality().equals(other._relatedExerciseIds, _relatedExerciseIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,exerciseName,userId,userName,userAvatar,type,status,title,description,originalValue,suggestedValue,upvotes,downvotes,const DeepCollectionEquality().hash(_upvotedBy),const DeepCollectionEquality().hash(_downvotedBy),const DeepCollectionEquality().hash(_comments),reviewNote,reviewedBy,reviewedAt,createdAt,updatedAt,isFeatured,trustScore,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_exerciseIds),difficulty,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_applicableTo),authorTier,authorTrustScore,qualityScore,saves,viewCount,lastActivityAt,sourceType,const DeepCollectionEquality().hash(_relatedExerciseIds)]);

@override
String toString() {
  return 'CommunityContribution(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, userId: $userId, userName: $userName, userAvatar: $userAvatar, type: $type, status: $status, title: $title, description: $description, originalValue: $originalValue, suggestedValue: $suggestedValue, upvotes: $upvotes, downvotes: $downvotes, upvotedBy: $upvotedBy, downvotedBy: $downvotedBy, comments: $comments, reviewNote: $reviewNote, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt, isFeatured: $isFeatured, trustScore: $trustScore, metadata: $metadata, exerciseIds: $exerciseIds, difficulty: $difficulty, tags: $tags, applicableTo: $applicableTo, authorTier: $authorTier, authorTrustScore: $authorTrustScore, qualityScore: $qualityScore, saves: $saves, viewCount: $viewCount, lastActivityAt: $lastActivityAt, sourceType: $sourceType, relatedExerciseIds: $relatedExerciseIds)';
}


}

/// @nodoc
abstract mixin class _$CommunityContributionCopyWith<$Res> implements $CommunityContributionCopyWith<$Res> {
  factory _$CommunityContributionCopyWith(_CommunityContribution value, $Res Function(_CommunityContribution) _then) = __$CommunityContributionCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String exerciseName, String userId, String userName, String? userAvatar, ContributionType type, ContributionStatus status, String title, String description, String? originalValue, String? suggestedValue, int upvotes, int downvotes, List<String> upvotedBy, List<String> downvotedBy, List<ContributionComment> comments, String? reviewNote, String? reviewedBy, DateTime? reviewedAt, DateTime createdAt, DateTime? updatedAt, bool isFeatured, int trustScore, Map<String, dynamic>? metadata, List<String> exerciseIds, String difficulty, List<String> tags, List<String> applicableTo, String? authorTier, double authorTrustScore, double qualityScore, int saves, int viewCount, DateTime? lastActivityAt, String? sourceType, List<String> relatedExerciseIds
});




}
/// @nodoc
class __$CommunityContributionCopyWithImpl<$Res>
    implements _$CommunityContributionCopyWith<$Res> {
  __$CommunityContributionCopyWithImpl(this._self, this._then);

  final _CommunityContribution _self;
  final $Res Function(_CommunityContribution) _then;

/// Create a copy of CommunityContribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? exerciseName = null,Object? userId = null,Object? userName = null,Object? userAvatar = freezed,Object? type = null,Object? status = null,Object? title = null,Object? description = null,Object? originalValue = freezed,Object? suggestedValue = freezed,Object? upvotes = null,Object? downvotes = null,Object? upvotedBy = null,Object? downvotedBy = null,Object? comments = null,Object? reviewNote = freezed,Object? reviewedBy = freezed,Object? reviewedAt = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? isFeatured = null,Object? trustScore = null,Object? metadata = freezed,Object? exerciseIds = null,Object? difficulty = null,Object? tags = null,Object? applicableTo = null,Object? authorTier = freezed,Object? authorTrustScore = null,Object? qualityScore = null,Object? saves = null,Object? viewCount = null,Object? lastActivityAt = freezed,Object? sourceType = freezed,Object? relatedExerciseIds = null,}) {
  return _then(_CommunityContribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContributionType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,originalValue: freezed == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as String?,suggestedValue: freezed == suggestedValue ? _self.suggestedValue : suggestedValue // ignore: cast_nullable_to_non_nullable
as String?,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,upvotedBy: null == upvotedBy ? _self._upvotedBy : upvotedBy // ignore: cast_nullable_to_non_nullable
as List<String>,downvotedBy: null == downvotedBy ? _self._downvotedBy : downvotedBy // ignore: cast_nullable_to_non_nullable
as List<String>,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<ContributionComment>,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,exerciseIds: null == exerciseIds ? _self._exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,applicableTo: null == applicableTo ? _self._applicableTo : applicableTo // ignore: cast_nullable_to_non_nullable
as List<String>,authorTier: freezed == authorTier ? _self.authorTier : authorTier // ignore: cast_nullable_to_non_nullable
as String?,authorTrustScore: null == authorTrustScore ? _self.authorTrustScore : authorTrustScore // ignore: cast_nullable_to_non_nullable
as double,qualityScore: null == qualityScore ? _self.qualityScore : qualityScore // ignore: cast_nullable_to_non_nullable
as double,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sourceType: freezed == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String?,relatedExerciseIds: null == relatedExerciseIds ? _self._relatedExerciseIds : relatedExerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ContributionComment {

 String get id; String get userId; String get userName; String? get userAvatar; String get text; DateTime get createdAt; int get likes; List<String> get likedBy;
/// Create a copy of ContributionComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionCommentCopyWith<ContributionComment> get copyWith => _$ContributionCommentCopyWithImpl<ContributionComment>(this as ContributionComment, _$identity);

  /// Serializes this ContributionComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionComment&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likes, likes) || other.likes == likes)&&const DeepCollectionEquality().equals(other.likedBy, likedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userAvatar,text,createdAt,likes,const DeepCollectionEquality().hash(likedBy));

@override
String toString() {
  return 'ContributionComment(id: $id, userId: $userId, userName: $userName, userAvatar: $userAvatar, text: $text, createdAt: $createdAt, likes: $likes, likedBy: $likedBy)';
}


}

/// @nodoc
abstract mixin class $ContributionCommentCopyWith<$Res>  {
  factory $ContributionCommentCopyWith(ContributionComment value, $Res Function(ContributionComment) _then) = _$ContributionCommentCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String userName, String? userAvatar, String text, DateTime createdAt, int likes, List<String> likedBy
});




}
/// @nodoc
class _$ContributionCommentCopyWithImpl<$Res>
    implements $ContributionCommentCopyWith<$Res> {
  _$ContributionCommentCopyWithImpl(this._self, this._then);

  final ContributionComment _self;
  final $Res Function(ContributionComment) _then;

/// Create a copy of ContributionComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userAvatar = freezed,Object? text = null,Object? createdAt = null,Object? likes = null,Object? likedBy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,likedBy: null == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributionComment].
extension ContributionCommentPatterns on ContributionComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionComment value)  $default,){
final _that = this;
switch (_that) {
case _ContributionComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionComment value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? userAvatar,  String text,  DateTime createdAt,  int likes,  List<String> likedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionComment() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userAvatar,_that.text,_that.createdAt,_that.likes,_that.likedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? userAvatar,  String text,  DateTime createdAt,  int likes,  List<String> likedBy)  $default,) {final _that = this;
switch (_that) {
case _ContributionComment():
return $default(_that.id,_that.userId,_that.userName,_that.userAvatar,_that.text,_that.createdAt,_that.likes,_that.likedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String userName,  String? userAvatar,  String text,  DateTime createdAt,  int likes,  List<String> likedBy)?  $default,) {final _that = this;
switch (_that) {
case _ContributionComment() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userAvatar,_that.text,_that.createdAt,_that.likes,_that.likedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionComment implements ContributionComment {
  const _ContributionComment({required this.id, required this.userId, required this.userName, this.userAvatar, required this.text, required this.createdAt, this.likes = 0, final  List<String> likedBy = const []}): _likedBy = likedBy;
  factory _ContributionComment.fromJson(Map<String, dynamic> json) => _$ContributionCommentFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String userName;
@override final  String? userAvatar;
@override final  String text;
@override final  DateTime createdAt;
@override@JsonKey() final  int likes;
 final  List<String> _likedBy;
@override@JsonKey() List<String> get likedBy {
  if (_likedBy is EqualUnmodifiableListView) return _likedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedBy);
}


/// Create a copy of ContributionComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionCommentCopyWith<_ContributionComment> get copyWith => __$ContributionCommentCopyWithImpl<_ContributionComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionComment&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatar, userAvatar) || other.userAvatar == userAvatar)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likes, likes) || other.likes == likes)&&const DeepCollectionEquality().equals(other._likedBy, _likedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userAvatar,text,createdAt,likes,const DeepCollectionEquality().hash(_likedBy));

@override
String toString() {
  return 'ContributionComment(id: $id, userId: $userId, userName: $userName, userAvatar: $userAvatar, text: $text, createdAt: $createdAt, likes: $likes, likedBy: $likedBy)';
}


}

/// @nodoc
abstract mixin class _$ContributionCommentCopyWith<$Res> implements $ContributionCommentCopyWith<$Res> {
  factory _$ContributionCommentCopyWith(_ContributionComment value, $Res Function(_ContributionComment) _then) = __$ContributionCommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String userName, String? userAvatar, String text, DateTime createdAt, int likes, List<String> likedBy
});




}
/// @nodoc
class __$ContributionCommentCopyWithImpl<$Res>
    implements _$ContributionCommentCopyWith<$Res> {
  __$ContributionCommentCopyWithImpl(this._self, this._then);

  final _ContributionComment _self;
  final $Res Function(_ContributionComment) _then;

/// Create a copy of ContributionComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userAvatar = freezed,Object? text = null,Object? createdAt = null,Object? likes = null,Object? likedBy = null,}) {
  return _then(_ContributionComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatar: freezed == userAvatar ? _self.userAvatar : userAvatar // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,likedBy: null == likedBy ? _self._likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$UserContributionStats {

 String get userId; int get totalContributions; int get approvedContributions; int get rejectedContributions; int get pendingContributions; int get totalVotes; int get totalPoints; int get currentStreak; int get longestStreak; String get level; List<ContributorBadge> get badges; DateTime? get lastContributionDate; Map<String, int> get contributionsByType; double get approvalRate; int get weeklyRank; int get monthlyRank; int get allTimeRank;
/// Create a copy of UserContributionStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserContributionStatsCopyWith<UserContributionStats> get copyWith => _$UserContributionStatsCopyWithImpl<UserContributionStats>(this as UserContributionStats, _$identity);

  /// Serializes this UserContributionStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserContributionStats&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalContributions, totalContributions) || other.totalContributions == totalContributions)&&(identical(other.approvedContributions, approvedContributions) || other.approvedContributions == approvedContributions)&&(identical(other.rejectedContributions, rejectedContributions) || other.rejectedContributions == rejectedContributions)&&(identical(other.pendingContributions, pendingContributions) || other.pendingContributions == pendingContributions)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.lastContributionDate, lastContributionDate) || other.lastContributionDate == lastContributionDate)&&const DeepCollectionEquality().equals(other.contributionsByType, contributionsByType)&&(identical(other.approvalRate, approvalRate) || other.approvalRate == approvalRate)&&(identical(other.weeklyRank, weeklyRank) || other.weeklyRank == weeklyRank)&&(identical(other.monthlyRank, monthlyRank) || other.monthlyRank == monthlyRank)&&(identical(other.allTimeRank, allTimeRank) || other.allTimeRank == allTimeRank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,totalContributions,approvedContributions,rejectedContributions,pendingContributions,totalVotes,totalPoints,currentStreak,longestStreak,level,const DeepCollectionEquality().hash(badges),lastContributionDate,const DeepCollectionEquality().hash(contributionsByType),approvalRate,weeklyRank,monthlyRank,allTimeRank);

@override
String toString() {
  return 'UserContributionStats(userId: $userId, totalContributions: $totalContributions, approvedContributions: $approvedContributions, rejectedContributions: $rejectedContributions, pendingContributions: $pendingContributions, totalVotes: $totalVotes, totalPoints: $totalPoints, currentStreak: $currentStreak, longestStreak: $longestStreak, level: $level, badges: $badges, lastContributionDate: $lastContributionDate, contributionsByType: $contributionsByType, approvalRate: $approvalRate, weeklyRank: $weeklyRank, monthlyRank: $monthlyRank, allTimeRank: $allTimeRank)';
}


}

/// @nodoc
abstract mixin class $UserContributionStatsCopyWith<$Res>  {
  factory $UserContributionStatsCopyWith(UserContributionStats value, $Res Function(UserContributionStats) _then) = _$UserContributionStatsCopyWithImpl;
@useResult
$Res call({
 String userId, int totalContributions, int approvedContributions, int rejectedContributions, int pendingContributions, int totalVotes, int totalPoints, int currentStreak, int longestStreak, String level, List<ContributorBadge> badges, DateTime? lastContributionDate, Map<String, int> contributionsByType, double approvalRate, int weeklyRank, int monthlyRank, int allTimeRank
});




}
/// @nodoc
class _$UserContributionStatsCopyWithImpl<$Res>
    implements $UserContributionStatsCopyWith<$Res> {
  _$UserContributionStatsCopyWithImpl(this._self, this._then);

  final UserContributionStats _self;
  final $Res Function(UserContributionStats) _then;

/// Create a copy of UserContributionStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? totalContributions = null,Object? approvedContributions = null,Object? rejectedContributions = null,Object? pendingContributions = null,Object? totalVotes = null,Object? totalPoints = null,Object? currentStreak = null,Object? longestStreak = null,Object? level = null,Object? badges = null,Object? lastContributionDate = freezed,Object? contributionsByType = null,Object? approvalRate = null,Object? weeklyRank = null,Object? monthlyRank = null,Object? allTimeRank = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalContributions: null == totalContributions ? _self.totalContributions : totalContributions // ignore: cast_nullable_to_non_nullable
as int,approvedContributions: null == approvedContributions ? _self.approvedContributions : approvedContributions // ignore: cast_nullable_to_non_nullable
as int,rejectedContributions: null == rejectedContributions ? _self.rejectedContributions : rejectedContributions // ignore: cast_nullable_to_non_nullable
as int,pendingContributions: null == pendingContributions ? _self.pendingContributions : pendingContributions // ignore: cast_nullable_to_non_nullable
as int,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<ContributorBadge>,lastContributionDate: freezed == lastContributionDate ? _self.lastContributionDate : lastContributionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contributionsByType: null == contributionsByType ? _self.contributionsByType : contributionsByType // ignore: cast_nullable_to_non_nullable
as Map<String, int>,approvalRate: null == approvalRate ? _self.approvalRate : approvalRate // ignore: cast_nullable_to_non_nullable
as double,weeklyRank: null == weeklyRank ? _self.weeklyRank : weeklyRank // ignore: cast_nullable_to_non_nullable
as int,monthlyRank: null == monthlyRank ? _self.monthlyRank : monthlyRank // ignore: cast_nullable_to_non_nullable
as int,allTimeRank: null == allTimeRank ? _self.allTimeRank : allTimeRank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserContributionStats].
extension UserContributionStatsPatterns on UserContributionStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserContributionStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserContributionStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserContributionStats value)  $default,){
final _that = this;
switch (_that) {
case _UserContributionStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserContributionStats value)?  $default,){
final _that = this;
switch (_that) {
case _UserContributionStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int totalContributions,  int approvedContributions,  int rejectedContributions,  int pendingContributions,  int totalVotes,  int totalPoints,  int currentStreak,  int longestStreak,  String level,  List<ContributorBadge> badges,  DateTime? lastContributionDate,  Map<String, int> contributionsByType,  double approvalRate,  int weeklyRank,  int monthlyRank,  int allTimeRank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserContributionStats() when $default != null:
return $default(_that.userId,_that.totalContributions,_that.approvedContributions,_that.rejectedContributions,_that.pendingContributions,_that.totalVotes,_that.totalPoints,_that.currentStreak,_that.longestStreak,_that.level,_that.badges,_that.lastContributionDate,_that.contributionsByType,_that.approvalRate,_that.weeklyRank,_that.monthlyRank,_that.allTimeRank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int totalContributions,  int approvedContributions,  int rejectedContributions,  int pendingContributions,  int totalVotes,  int totalPoints,  int currentStreak,  int longestStreak,  String level,  List<ContributorBadge> badges,  DateTime? lastContributionDate,  Map<String, int> contributionsByType,  double approvalRate,  int weeklyRank,  int monthlyRank,  int allTimeRank)  $default,) {final _that = this;
switch (_that) {
case _UserContributionStats():
return $default(_that.userId,_that.totalContributions,_that.approvedContributions,_that.rejectedContributions,_that.pendingContributions,_that.totalVotes,_that.totalPoints,_that.currentStreak,_that.longestStreak,_that.level,_that.badges,_that.lastContributionDate,_that.contributionsByType,_that.approvalRate,_that.weeklyRank,_that.monthlyRank,_that.allTimeRank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int totalContributions,  int approvedContributions,  int rejectedContributions,  int pendingContributions,  int totalVotes,  int totalPoints,  int currentStreak,  int longestStreak,  String level,  List<ContributorBadge> badges,  DateTime? lastContributionDate,  Map<String, int> contributionsByType,  double approvalRate,  int weeklyRank,  int monthlyRank,  int allTimeRank)?  $default,) {final _that = this;
switch (_that) {
case _UserContributionStats() when $default != null:
return $default(_that.userId,_that.totalContributions,_that.approvedContributions,_that.rejectedContributions,_that.pendingContributions,_that.totalVotes,_that.totalPoints,_that.currentStreak,_that.longestStreak,_that.level,_that.badges,_that.lastContributionDate,_that.contributionsByType,_that.approvalRate,_that.weeklyRank,_that.monthlyRank,_that.allTimeRank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserContributionStats implements UserContributionStats {
  const _UserContributionStats({required this.userId, this.totalContributions = 0, this.approvedContributions = 0, this.rejectedContributions = 0, this.pendingContributions = 0, this.totalVotes = 0, this.totalPoints = 0, this.currentStreak = 0, this.longestStreak = 0, this.level = 'Rookie', final  List<ContributorBadge> badges = const [], this.lastContributionDate, final  Map<String, int> contributionsByType = const {}, this.approvalRate = 0.0, this.weeklyRank = 0, this.monthlyRank = 0, this.allTimeRank = 0}): _badges = badges,_contributionsByType = contributionsByType;
  factory _UserContributionStats.fromJson(Map<String, dynamic> json) => _$UserContributionStatsFromJson(json);

@override final  String userId;
@override@JsonKey() final  int totalContributions;
@override@JsonKey() final  int approvedContributions;
@override@JsonKey() final  int rejectedContributions;
@override@JsonKey() final  int pendingContributions;
@override@JsonKey() final  int totalVotes;
@override@JsonKey() final  int totalPoints;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override@JsonKey() final  String level;
 final  List<ContributorBadge> _badges;
@override@JsonKey() List<ContributorBadge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

@override final  DateTime? lastContributionDate;
 final  Map<String, int> _contributionsByType;
@override@JsonKey() Map<String, int> get contributionsByType {
  if (_contributionsByType is EqualUnmodifiableMapView) return _contributionsByType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_contributionsByType);
}

@override@JsonKey() final  double approvalRate;
@override@JsonKey() final  int weeklyRank;
@override@JsonKey() final  int monthlyRank;
@override@JsonKey() final  int allTimeRank;

/// Create a copy of UserContributionStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserContributionStatsCopyWith<_UserContributionStats> get copyWith => __$UserContributionStatsCopyWithImpl<_UserContributionStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserContributionStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserContributionStats&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalContributions, totalContributions) || other.totalContributions == totalContributions)&&(identical(other.approvedContributions, approvedContributions) || other.approvedContributions == approvedContributions)&&(identical(other.rejectedContributions, rejectedContributions) || other.rejectedContributions == rejectedContributions)&&(identical(other.pendingContributions, pendingContributions) || other.pendingContributions == pendingContributions)&&(identical(other.totalVotes, totalVotes) || other.totalVotes == totalVotes)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.lastContributionDate, lastContributionDate) || other.lastContributionDate == lastContributionDate)&&const DeepCollectionEquality().equals(other._contributionsByType, _contributionsByType)&&(identical(other.approvalRate, approvalRate) || other.approvalRate == approvalRate)&&(identical(other.weeklyRank, weeklyRank) || other.weeklyRank == weeklyRank)&&(identical(other.monthlyRank, monthlyRank) || other.monthlyRank == monthlyRank)&&(identical(other.allTimeRank, allTimeRank) || other.allTimeRank == allTimeRank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,totalContributions,approvedContributions,rejectedContributions,pendingContributions,totalVotes,totalPoints,currentStreak,longestStreak,level,const DeepCollectionEquality().hash(_badges),lastContributionDate,const DeepCollectionEquality().hash(_contributionsByType),approvalRate,weeklyRank,monthlyRank,allTimeRank);

@override
String toString() {
  return 'UserContributionStats(userId: $userId, totalContributions: $totalContributions, approvedContributions: $approvedContributions, rejectedContributions: $rejectedContributions, pendingContributions: $pendingContributions, totalVotes: $totalVotes, totalPoints: $totalPoints, currentStreak: $currentStreak, longestStreak: $longestStreak, level: $level, badges: $badges, lastContributionDate: $lastContributionDate, contributionsByType: $contributionsByType, approvalRate: $approvalRate, weeklyRank: $weeklyRank, monthlyRank: $monthlyRank, allTimeRank: $allTimeRank)';
}


}

/// @nodoc
abstract mixin class _$UserContributionStatsCopyWith<$Res> implements $UserContributionStatsCopyWith<$Res> {
  factory _$UserContributionStatsCopyWith(_UserContributionStats value, $Res Function(_UserContributionStats) _then) = __$UserContributionStatsCopyWithImpl;
@override @useResult
$Res call({
 String userId, int totalContributions, int approvedContributions, int rejectedContributions, int pendingContributions, int totalVotes, int totalPoints, int currentStreak, int longestStreak, String level, List<ContributorBadge> badges, DateTime? lastContributionDate, Map<String, int> contributionsByType, double approvalRate, int weeklyRank, int monthlyRank, int allTimeRank
});




}
/// @nodoc
class __$UserContributionStatsCopyWithImpl<$Res>
    implements _$UserContributionStatsCopyWith<$Res> {
  __$UserContributionStatsCopyWithImpl(this._self, this._then);

  final _UserContributionStats _self;
  final $Res Function(_UserContributionStats) _then;

/// Create a copy of UserContributionStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? totalContributions = null,Object? approvedContributions = null,Object? rejectedContributions = null,Object? pendingContributions = null,Object? totalVotes = null,Object? totalPoints = null,Object? currentStreak = null,Object? longestStreak = null,Object? level = null,Object? badges = null,Object? lastContributionDate = freezed,Object? contributionsByType = null,Object? approvalRate = null,Object? weeklyRank = null,Object? monthlyRank = null,Object? allTimeRank = null,}) {
  return _then(_UserContributionStats(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalContributions: null == totalContributions ? _self.totalContributions : totalContributions // ignore: cast_nullable_to_non_nullable
as int,approvedContributions: null == approvedContributions ? _self.approvedContributions : approvedContributions // ignore: cast_nullable_to_non_nullable
as int,rejectedContributions: null == rejectedContributions ? _self.rejectedContributions : rejectedContributions // ignore: cast_nullable_to_non_nullable
as int,pendingContributions: null == pendingContributions ? _self.pendingContributions : pendingContributions // ignore: cast_nullable_to_non_nullable
as int,totalVotes: null == totalVotes ? _self.totalVotes : totalVotes // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<ContributorBadge>,lastContributionDate: freezed == lastContributionDate ? _self.lastContributionDate : lastContributionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contributionsByType: null == contributionsByType ? _self._contributionsByType : contributionsByType // ignore: cast_nullable_to_non_nullable
as Map<String, int>,approvalRate: null == approvalRate ? _self.approvalRate : approvalRate // ignore: cast_nullable_to_non_nullable
as double,weeklyRank: null == weeklyRank ? _self.weeklyRank : weeklyRank // ignore: cast_nullable_to_non_nullable
as int,monthlyRank: null == monthlyRank ? _self.monthlyRank : monthlyRank // ignore: cast_nullable_to_non_nullable
as int,allTimeRank: null == allTimeRank ? _self.allTimeRank : allTimeRank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ContributorBadge {

 String get id; String get name; String get description; String get icon; DateTime get earnedAt; bool get isRare; String? get category;
/// Create a copy of ContributorBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributorBadgeCopyWith<ContributorBadge> get copyWith => _$ContributorBadgeCopyWithImpl<ContributorBadge>(this as ContributorBadge, _$identity);

  /// Serializes this ContributorBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributorBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt)&&(identical(other.isRare, isRare) || other.isRare == isRare)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,icon,earnedAt,isRare,category);

@override
String toString() {
  return 'ContributorBadge(id: $id, name: $name, description: $description, icon: $icon, earnedAt: $earnedAt, isRare: $isRare, category: $category)';
}


}

/// @nodoc
abstract mixin class $ContributorBadgeCopyWith<$Res>  {
  factory $ContributorBadgeCopyWith(ContributorBadge value, $Res Function(ContributorBadge) _then) = _$ContributorBadgeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String icon, DateTime earnedAt, bool isRare, String? category
});




}
/// @nodoc
class _$ContributorBadgeCopyWithImpl<$Res>
    implements $ContributorBadgeCopyWith<$Res> {
  _$ContributorBadgeCopyWithImpl(this._self, this._then);

  final ContributorBadge _self;
  final $Res Function(ContributorBadge) _then;

/// Create a copy of ContributorBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? icon = null,Object? earnedAt = null,Object? isRare = null,Object? category = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,earnedAt: null == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRare: null == isRare ? _self.isRare : isRare // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributorBadge].
extension ContributorBadgePatterns on ContributorBadge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributorBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributorBadge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributorBadge value)  $default,){
final _that = this;
switch (_that) {
case _ContributorBadge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributorBadge value)?  $default,){
final _that = this;
switch (_that) {
case _ContributorBadge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String icon,  DateTime earnedAt,  bool isRare,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributorBadge() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.icon,_that.earnedAt,_that.isRare,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String icon,  DateTime earnedAt,  bool isRare,  String? category)  $default,) {final _that = this;
switch (_that) {
case _ContributorBadge():
return $default(_that.id,_that.name,_that.description,_that.icon,_that.earnedAt,_that.isRare,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String icon,  DateTime earnedAt,  bool isRare,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _ContributorBadge() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.icon,_that.earnedAt,_that.isRare,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributorBadge implements ContributorBadge {
  const _ContributorBadge({required this.id, required this.name, required this.description, required this.icon, required this.earnedAt, this.isRare = false, this.category});
  factory _ContributorBadge.fromJson(Map<String, dynamic> json) => _$ContributorBadgeFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String icon;
@override final  DateTime earnedAt;
@override@JsonKey() final  bool isRare;
@override final  String? category;

/// Create a copy of ContributorBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributorBadgeCopyWith<_ContributorBadge> get copyWith => __$ContributorBadgeCopyWithImpl<_ContributorBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributorBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributorBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt)&&(identical(other.isRare, isRare) || other.isRare == isRare)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,icon,earnedAt,isRare,category);

@override
String toString() {
  return 'ContributorBadge(id: $id, name: $name, description: $description, icon: $icon, earnedAt: $earnedAt, isRare: $isRare, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ContributorBadgeCopyWith<$Res> implements $ContributorBadgeCopyWith<$Res> {
  factory _$ContributorBadgeCopyWith(_ContributorBadge value, $Res Function(_ContributorBadge) _then) = __$ContributorBadgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String icon, DateTime earnedAt, bool isRare, String? category
});




}
/// @nodoc
class __$ContributorBadgeCopyWithImpl<$Res>
    implements _$ContributorBadgeCopyWith<$Res> {
  __$ContributorBadgeCopyWithImpl(this._self, this._then);

  final _ContributorBadge _self;
  final $Res Function(_ContributorBadge) _then;

/// Create a copy of ContributorBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? icon = null,Object? earnedAt = null,Object? isRare = null,Object? category = freezed,}) {
  return _then(_ContributorBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,earnedAt: null == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRare: null == isRare ? _self.isRare : isRare // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
