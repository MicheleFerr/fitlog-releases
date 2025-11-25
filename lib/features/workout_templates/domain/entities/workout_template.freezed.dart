// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommunityWorkoutTemplate _$CommunityWorkoutTemplateFromJson(
    Map<String, dynamic> json) {
  return _CommunityWorkoutTemplate.fromJson(json);
}

/// @nodoc
mixin _$CommunityWorkoutTemplate {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<Exercise> get exercises => throw _privateConstructorUsedError;
  TemplateCategory get category => throw _privateConstructorUsedError;
  TemplateVisibility get visibility =>
      throw _privateConstructorUsedError; // Metadata
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Stats pubbliche
  int get downloadCount => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError; // Info autore
  String? get authorName => throw _privateConstructorUsedError;
  String? get authorPhotoUrl =>
      throw _privateConstructorUsedError; // Tags per ricerca
  List<String> get tags =>
      throw _privateConstructorUsedError; // Durata stimata in minuti
  int? get estimatedDurationMinutes =>
      throw _privateConstructorUsedError; // Livello difficoltà
  String? get difficultyLevel =>
      throw _privateConstructorUsedError; // beginner, intermediate, advanced, expert
// Equipment necessario
  List<String> get requiredEquipment =>
      throw _privateConstructorUsedError; // Muscoli target
  List<String> get targetMuscles => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityWorkoutTemplateCopyWith<CommunityWorkoutTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityWorkoutTemplateCopyWith<$Res> {
  factory $CommunityWorkoutTemplateCopyWith(CommunityWorkoutTemplate value,
          $Res Function(CommunityWorkoutTemplate) then) =
      _$CommunityWorkoutTemplateCopyWithImpl<$Res, CommunityWorkoutTemplate>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      List<Exercise> exercises,
      TemplateCategory category,
      TemplateVisibility visibility,
      DateTime createdAt,
      DateTime? updatedAt,
      int downloadCount,
      int likeCount,
      int reviewCount,
      double averageRating,
      String? authorName,
      String? authorPhotoUrl,
      List<String> tags,
      int? estimatedDurationMinutes,
      String? difficultyLevel,
      List<String> requiredEquipment,
      List<String> targetMuscles});
}

/// @nodoc
class _$CommunityWorkoutTemplateCopyWithImpl<$Res,
        $Val extends CommunityWorkoutTemplate>
    implements $CommunityWorkoutTemplateCopyWith<$Res> {
  _$CommunityWorkoutTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? exercises = null,
    Object? category = null,
    Object? visibility = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? downloadCount = null,
    Object? likeCount = null,
    Object? reviewCount = null,
    Object? averageRating = null,
    Object? authorName = freezed,
    Object? authorPhotoUrl = freezed,
    Object? tags = null,
    Object? estimatedDurationMinutes = freezed,
    Object? difficultyLevel = freezed,
    Object? requiredEquipment = null,
    Object? targetMuscles = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TemplateCategory,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as TemplateVisibility,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorPhotoUrl: freezed == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estimatedDurationMinutes: freezed == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      difficultyLevel: freezed == difficultyLevel
          ? _value.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredEquipment: null == requiredEquipment
          ? _value.requiredEquipment
          : requiredEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value.targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityWorkoutTemplateImplCopyWith<$Res>
    implements $CommunityWorkoutTemplateCopyWith<$Res> {
  factory _$$CommunityWorkoutTemplateImplCopyWith(
          _$CommunityWorkoutTemplateImpl value,
          $Res Function(_$CommunityWorkoutTemplateImpl) then) =
      __$$CommunityWorkoutTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      List<Exercise> exercises,
      TemplateCategory category,
      TemplateVisibility visibility,
      DateTime createdAt,
      DateTime? updatedAt,
      int downloadCount,
      int likeCount,
      int reviewCount,
      double averageRating,
      String? authorName,
      String? authorPhotoUrl,
      List<String> tags,
      int? estimatedDurationMinutes,
      String? difficultyLevel,
      List<String> requiredEquipment,
      List<String> targetMuscles});
}

/// @nodoc
class __$$CommunityWorkoutTemplateImplCopyWithImpl<$Res>
    extends _$CommunityWorkoutTemplateCopyWithImpl<$Res,
        _$CommunityWorkoutTemplateImpl>
    implements _$$CommunityWorkoutTemplateImplCopyWith<$Res> {
  __$$CommunityWorkoutTemplateImplCopyWithImpl(
      _$CommunityWorkoutTemplateImpl _value,
      $Res Function(_$CommunityWorkoutTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? exercises = null,
    Object? category = null,
    Object? visibility = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? downloadCount = null,
    Object? likeCount = null,
    Object? reviewCount = null,
    Object? averageRating = null,
    Object? authorName = freezed,
    Object? authorPhotoUrl = freezed,
    Object? tags = null,
    Object? estimatedDurationMinutes = freezed,
    Object? difficultyLevel = freezed,
    Object? requiredEquipment = null,
    Object? targetMuscles = null,
  }) {
    return _then(_$CommunityWorkoutTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TemplateCategory,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as TemplateVisibility,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorPhotoUrl: freezed == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estimatedDurationMinutes: freezed == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      difficultyLevel: freezed == difficultyLevel
          ? _value.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredEquipment: null == requiredEquipment
          ? _value._requiredEquipment
          : requiredEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value._targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityWorkoutTemplateImpl implements _CommunityWorkoutTemplate {
  const _$CommunityWorkoutTemplateImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      required final List<Exercise> exercises,
      required this.category,
      required this.visibility,
      required this.createdAt,
      this.updatedAt,
      this.downloadCount = 0,
      this.likeCount = 0,
      this.reviewCount = 0,
      this.averageRating = 0.0,
      this.authorName,
      this.authorPhotoUrl,
      final List<String> tags = const [],
      this.estimatedDurationMinutes,
      this.difficultyLevel,
      final List<String> requiredEquipment = const [],
      final List<String> targetMuscles = const []})
      : _exercises = exercises,
        _tags = tags,
        _requiredEquipment = requiredEquipment,
        _targetMuscles = targetMuscles;

  factory _$CommunityWorkoutTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityWorkoutTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  final List<Exercise> _exercises;
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final TemplateCategory category;
  @override
  final TemplateVisibility visibility;
// Metadata
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
// Stats pubbliche
  @override
  @JsonKey()
  final int downloadCount;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  @JsonKey()
  final double averageRating;
// Info autore
  @override
  final String? authorName;
  @override
  final String? authorPhotoUrl;
// Tags per ricerca
  final List<String> _tags;
// Tags per ricerca
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

// Durata stimata in minuti
  @override
  final int? estimatedDurationMinutes;
// Livello difficoltà
  @override
  final String? difficultyLevel;
// beginner, intermediate, advanced, expert
// Equipment necessario
  final List<String> _requiredEquipment;
// beginner, intermediate, advanced, expert
// Equipment necessario
  @override
  @JsonKey()
  List<String> get requiredEquipment {
    if (_requiredEquipment is EqualUnmodifiableListView)
      return _requiredEquipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredEquipment);
  }

// Muscoli target
  final List<String> _targetMuscles;
// Muscoli target
  @override
  @JsonKey()
  List<String> get targetMuscles {
    if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetMuscles);
  }

  @override
  String toString() {
    return 'CommunityWorkoutTemplate(id: $id, userId: $userId, name: $name, description: $description, exercises: $exercises, category: $category, visibility: $visibility, createdAt: $createdAt, updatedAt: $updatedAt, downloadCount: $downloadCount, likeCount: $likeCount, reviewCount: $reviewCount, averageRating: $averageRating, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, tags: $tags, estimatedDurationMinutes: $estimatedDurationMinutes, difficultyLevel: $difficultyLevel, requiredEquipment: $requiredEquipment, targetMuscles: $targetMuscles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityWorkoutTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorPhotoUrl, authorPhotoUrl) ||
                other.authorPhotoUrl == authorPhotoUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.difficultyLevel, difficultyLevel) ||
                other.difficultyLevel == difficultyLevel) &&
            const DeepCollectionEquality()
                .equals(other._requiredEquipment, _requiredEquipment) &&
            const DeepCollectionEquality()
                .equals(other._targetMuscles, _targetMuscles));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        name,
        description,
        const DeepCollectionEquality().hash(_exercises),
        category,
        visibility,
        createdAt,
        updatedAt,
        downloadCount,
        likeCount,
        reviewCount,
        averageRating,
        authorName,
        authorPhotoUrl,
        const DeepCollectionEquality().hash(_tags),
        estimatedDurationMinutes,
        difficultyLevel,
        const DeepCollectionEquality().hash(_requiredEquipment),
        const DeepCollectionEquality().hash(_targetMuscles)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityWorkoutTemplateImplCopyWith<_$CommunityWorkoutTemplateImpl>
      get copyWith => __$$CommunityWorkoutTemplateImplCopyWithImpl<
          _$CommunityWorkoutTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityWorkoutTemplateImplToJson(
      this,
    );
  }
}

abstract class _CommunityWorkoutTemplate implements CommunityWorkoutTemplate {
  const factory _CommunityWorkoutTemplate(
      {required final String id,
      required final String userId,
      required final String name,
      final String? description,
      required final List<Exercise> exercises,
      required final TemplateCategory category,
      required final TemplateVisibility visibility,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final int downloadCount,
      final int likeCount,
      final int reviewCount,
      final double averageRating,
      final String? authorName,
      final String? authorPhotoUrl,
      final List<String> tags,
      final int? estimatedDurationMinutes,
      final String? difficultyLevel,
      final List<String> requiredEquipment,
      final List<String> targetMuscles}) = _$CommunityWorkoutTemplateImpl;

  factory _CommunityWorkoutTemplate.fromJson(Map<String, dynamic> json) =
      _$CommunityWorkoutTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get description;
  @override
  List<Exercise> get exercises;
  @override
  TemplateCategory get category;
  @override
  TemplateVisibility get visibility;
  @override // Metadata
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override // Stats pubbliche
  int get downloadCount;
  @override
  int get likeCount;
  @override
  int get reviewCount;
  @override
  double get averageRating;
  @override // Info autore
  String? get authorName;
  @override
  String? get authorPhotoUrl;
  @override // Tags per ricerca
  List<String> get tags;
  @override // Durata stimata in minuti
  int? get estimatedDurationMinutes;
  @override // Livello difficoltà
  String? get difficultyLevel;
  @override // beginner, intermediate, advanced, expert
// Equipment necessario
  List<String> get requiredEquipment;
  @override // Muscoli target
  List<String> get targetMuscles;
  @override
  @JsonKey(ignore: true)
  _$$CommunityWorkoutTemplateImplCopyWith<_$CommunityWorkoutTemplateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TemplateReview _$TemplateReviewFromJson(Map<String, dynamic> json) {
  return _TemplateReview.fromJson(json);
}

/// @nodoc
mixin _$TemplateReview {
  String get id => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userPhotoUrl => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError; // 1-5 stelle
  String get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get helpfulCount => throw _privateConstructorUsedError;
  List<String> get helpfulVoters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TemplateReviewCopyWith<TemplateReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplateReviewCopyWith<$Res> {
  factory $TemplateReviewCopyWith(
          TemplateReview value, $Res Function(TemplateReview) then) =
      _$TemplateReviewCopyWithImpl<$Res, TemplateReview>;
  @useResult
  $Res call(
      {String id,
      String templateId,
      String userId,
      String userName,
      String? userPhotoUrl,
      double rating,
      String comment,
      DateTime createdAt,
      int helpfulCount,
      List<String> helpfulVoters});
}

/// @nodoc
class _$TemplateReviewCopyWithImpl<$Res, $Val extends TemplateReview>
    implements $TemplateReviewCopyWith<$Res> {
  _$TemplateReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? rating = null,
    Object? comment = null,
    Object? createdAt = null,
    Object? helpfulCount = null,
    Object? helpfulVoters = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      helpfulVoters: null == helpfulVoters
          ? _value.helpfulVoters
          : helpfulVoters // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TemplateReviewImplCopyWith<$Res>
    implements $TemplateReviewCopyWith<$Res> {
  factory _$$TemplateReviewImplCopyWith(_$TemplateReviewImpl value,
          $Res Function(_$TemplateReviewImpl) then) =
      __$$TemplateReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String templateId,
      String userId,
      String userName,
      String? userPhotoUrl,
      double rating,
      String comment,
      DateTime createdAt,
      int helpfulCount,
      List<String> helpfulVoters});
}

/// @nodoc
class __$$TemplateReviewImplCopyWithImpl<$Res>
    extends _$TemplateReviewCopyWithImpl<$Res, _$TemplateReviewImpl>
    implements _$$TemplateReviewImplCopyWith<$Res> {
  __$$TemplateReviewImplCopyWithImpl(
      _$TemplateReviewImpl _value, $Res Function(_$TemplateReviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? rating = null,
    Object? comment = null,
    Object? createdAt = null,
    Object? helpfulCount = null,
    Object? helpfulVoters = null,
  }) {
    return _then(_$TemplateReviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      helpfulVoters: null == helpfulVoters
          ? _value._helpfulVoters
          : helpfulVoters // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TemplateReviewImpl implements _TemplateReview {
  const _$TemplateReviewImpl(
      {required this.id,
      required this.templateId,
      required this.userId,
      required this.userName,
      this.userPhotoUrl,
      required this.rating,
      required this.comment,
      required this.createdAt,
      this.helpfulCount = 0,
      final List<String> helpfulVoters = const []})
      : _helpfulVoters = helpfulVoters;

  factory _$TemplateReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String templateId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userPhotoUrl;
  @override
  final double rating;
// 1-5 stelle
  @override
  final String comment;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int helpfulCount;
  final List<String> _helpfulVoters;
  @override
  @JsonKey()
  List<String> get helpfulVoters {
    if (_helpfulVoters is EqualUnmodifiableListView) return _helpfulVoters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_helpfulVoters);
  }

  @override
  String toString() {
    return 'TemplateReview(id: $id, templateId: $templateId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, rating: $rating, comment: $comment, createdAt: $createdAt, helpfulCount: $helpfulCount, helpfulVoters: $helpfulVoters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userPhotoUrl, userPhotoUrl) ||
                other.userPhotoUrl == userPhotoUrl) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.helpfulCount, helpfulCount) ||
                other.helpfulCount == helpfulCount) &&
            const DeepCollectionEquality()
                .equals(other._helpfulVoters, _helpfulVoters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      templateId,
      userId,
      userName,
      userPhotoUrl,
      rating,
      comment,
      createdAt,
      helpfulCount,
      const DeepCollectionEquality().hash(_helpfulVoters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateReviewImplCopyWith<_$TemplateReviewImpl> get copyWith =>
      __$$TemplateReviewImplCopyWithImpl<_$TemplateReviewImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateReviewImplToJson(
      this,
    );
  }
}

abstract class _TemplateReview implements TemplateReview {
  const factory _TemplateReview(
      {required final String id,
      required final String templateId,
      required final String userId,
      required final String userName,
      final String? userPhotoUrl,
      required final double rating,
      required final String comment,
      required final DateTime createdAt,
      final int helpfulCount,
      final List<String> helpfulVoters}) = _$TemplateReviewImpl;

  factory _TemplateReview.fromJson(Map<String, dynamic> json) =
      _$TemplateReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get templateId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userPhotoUrl;
  @override
  double get rating;
  @override // 1-5 stelle
  String get comment;
  @override
  DateTime get createdAt;
  @override
  int get helpfulCount;
  @override
  List<String> get helpfulVoters;
  @override
  @JsonKey(ignore: true)
  _$$TemplateReviewImplCopyWith<_$TemplateReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemplateComment _$TemplateCommentFromJson(Map<String, dynamic> json) {
  return _TemplateComment.fromJson(json);
}

/// @nodoc
mixin _$TemplateComment {
  String get id => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userPhotoUrl => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  List<String> get likedBy => throw _privateConstructorUsedError;
  String? get replyToId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TemplateCommentCopyWith<TemplateComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplateCommentCopyWith<$Res> {
  factory $TemplateCommentCopyWith(
          TemplateComment value, $Res Function(TemplateComment) then) =
      _$TemplateCommentCopyWithImpl<$Res, TemplateComment>;
  @useResult
  $Res call(
      {String id,
      String templateId,
      String userId,
      String userName,
      String? userPhotoUrl,
      String text,
      DateTime createdAt,
      int likeCount,
      List<String> likedBy,
      String? replyToId});
}

/// @nodoc
class _$TemplateCommentCopyWithImpl<$Res, $Val extends TemplateComment>
    implements $TemplateCommentCopyWith<$Res> {
  _$TemplateCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? text = null,
    Object? createdAt = null,
    Object? likeCount = null,
    Object? likedBy = null,
    Object? replyToId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      likedBy: null == likedBy
          ? _value.likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      replyToId: freezed == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TemplateCommentImplCopyWith<$Res>
    implements $TemplateCommentCopyWith<$Res> {
  factory _$$TemplateCommentImplCopyWith(_$TemplateCommentImpl value,
          $Res Function(_$TemplateCommentImpl) then) =
      __$$TemplateCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String templateId,
      String userId,
      String userName,
      String? userPhotoUrl,
      String text,
      DateTime createdAt,
      int likeCount,
      List<String> likedBy,
      String? replyToId});
}

/// @nodoc
class __$$TemplateCommentImplCopyWithImpl<$Res>
    extends _$TemplateCommentCopyWithImpl<$Res, _$TemplateCommentImpl>
    implements _$$TemplateCommentImplCopyWith<$Res> {
  __$$TemplateCommentImplCopyWithImpl(
      _$TemplateCommentImpl _value, $Res Function(_$TemplateCommentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? text = null,
    Object? createdAt = null,
    Object? likeCount = null,
    Object? likedBy = null,
    Object? replyToId = freezed,
  }) {
    return _then(_$TemplateCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      likedBy: null == likedBy
          ? _value._likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      replyToId: freezed == replyToId
          ? _value.replyToId
          : replyToId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TemplateCommentImpl implements _TemplateComment {
  const _$TemplateCommentImpl(
      {required this.id,
      required this.templateId,
      required this.userId,
      required this.userName,
      this.userPhotoUrl,
      required this.text,
      required this.createdAt,
      this.likeCount = 0,
      final List<String> likedBy = const [],
      this.replyToId})
      : _likedBy = likedBy;

  factory _$TemplateCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateCommentImplFromJson(json);

  @override
  final String id;
  @override
  final String templateId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userPhotoUrl;
  @override
  final String text;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int likeCount;
  final List<String> _likedBy;
  @override
  @JsonKey()
  List<String> get likedBy {
    if (_likedBy is EqualUnmodifiableListView) return _likedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedBy);
  }

  @override
  final String? replyToId;

  @override
  String toString() {
    return 'TemplateComment(id: $id, templateId: $templateId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, text: $text, createdAt: $createdAt, likeCount: $likeCount, likedBy: $likedBy, replyToId: $replyToId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userPhotoUrl, userPhotoUrl) ||
                other.userPhotoUrl == userPhotoUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            const DeepCollectionEquality().equals(other._likedBy, _likedBy) &&
            (identical(other.replyToId, replyToId) ||
                other.replyToId == replyToId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      templateId,
      userId,
      userName,
      userPhotoUrl,
      text,
      createdAt,
      likeCount,
      const DeepCollectionEquality().hash(_likedBy),
      replyToId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateCommentImplCopyWith<_$TemplateCommentImpl> get copyWith =>
      __$$TemplateCommentImplCopyWithImpl<_$TemplateCommentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateCommentImplToJson(
      this,
    );
  }
}

abstract class _TemplateComment implements TemplateComment {
  const factory _TemplateComment(
      {required final String id,
      required final String templateId,
      required final String userId,
      required final String userName,
      final String? userPhotoUrl,
      required final String text,
      required final DateTime createdAt,
      final int likeCount,
      final List<String> likedBy,
      final String? replyToId}) = _$TemplateCommentImpl;

  factory _TemplateComment.fromJson(Map<String, dynamic> json) =
      _$TemplateCommentImpl.fromJson;

  @override
  String get id;
  @override
  String get templateId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userPhotoUrl;
  @override
  String get text;
  @override
  DateTime get createdAt;
  @override
  int get likeCount;
  @override
  List<String> get likedBy;
  @override
  String? get replyToId;
  @override
  @JsonKey(ignore: true)
  _$$TemplateCommentImplCopyWith<_$TemplateCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
