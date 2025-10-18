// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_workout_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UnifiedWorkoutTemplate {
// === CORE IDENTIFIER ===
  String get id => throw _privateConstructorUsedError; // === BASIC INFO ===
  String get name => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // === EXERCISES - CRITICAL: Support multiple formats ===
  List<dynamic> get exercisesRaw =>
      throw _privateConstructorUsedError; // Can be Exercise, ExerciseTemplate, or JSON
// === LEGACY COMPATIBILITY FIELDS ===
// These ensure old code continues working
  bool get isCustom =>
      throw _privateConstructorUsedError; // Legacy: user created vs predefined
  bool get isPublic =>
      throw _privateConstructorUsedError; // Legacy: public sharing
  int get usageCount =>
      throw _privateConstructorUsedError; // Legacy: tracking usage
  String? get imageUrl =>
      throw _privateConstructorUsedError; // Legacy: template image
  String? get userId =>
      throw _privateConstructorUsedError; // Legacy: creator ID
  String? get authorName =>
      throw _privateConstructorUsedError; // Legacy: creator name
  int get downloadCount =>
      throw _privateConstructorUsedError; // Legacy: social stats
  double get averageRating =>
      throw _privateConstructorUsedError; // Legacy: social stats
  int get reviewCount =>
      throw _privateConstructorUsedError; // Legacy: social stats
  String? get difficulty =>
      throw _privateConstructorUsedError; // Legacy: difficulty string
// === MODERN FEATURES ===
  UnifiedTemplateVisibility get visibility =>
      throw _privateConstructorUsedError; // Modern: enum-based visibility
  UnifiedTemplateCategory get category =>
      throw _privateConstructorUsedError; // Modern: structured categories
  int get likeCount =>
      throw _privateConstructorUsedError; // Modern: social engagement
  String? get authorPhotoUrl =>
      throw _privateConstructorUsedError; // Modern: author avatar
  List<String> get requiredEquipment =>
      throw _privateConstructorUsedError; // Modern: equipment tracking
  List<String> get targetMuscles =>
      throw _privateConstructorUsedError; // Modern: muscle targeting
// === SMART/AI FEATURES ===
  Map<String, dynamic>? get adaptiveParameters =>
      throw _privateConstructorUsedError; // Smart: AI adaptation data
  Map<String, int>? get muscleGroupVolume =>
      throw _privateConstructorUsedError; // Smart: volume tracking
  List<String> get alternatives =>
      throw _privateConstructorUsedError; // Smart: alternative exercises
// === METADATA ===
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<String> get tags =>
      throw _privateConstructorUsedError; // === DURATION - Support both legacy and modern formats ===
  int get estimatedDuration =>
      throw _privateConstructorUsedError; // Legacy: minutes
  int? get estimatedDurationMinutes =>
      throw _privateConstructorUsedError; // Modern: explicit minutes
// === EXERCISE FORMAT TRACKING ===
  ExerciseFormat get exerciseFormat =>
      throw _privateConstructorUsedError; // Format of exercisesRaw
  TemplateSource get source =>
      throw _privateConstructorUsedError; // Origin tracking
// === IMPORT METADATA ===
  String? get importSource =>
      throw _privateConstructorUsedError; // Source URL/app for imports
  DateTime? get importDate =>
      throw _privateConstructorUsedError; // When imported
// === ADDITIONAL FEATURES ===
  int get useCount =>
      throw _privateConstructorUsedError; // Times used for workouts
  bool get supportsSuperset =>
      throw _privateConstructorUsedError; // Legacy compatibility
  bool get requiresPremium =>
      throw _privateConstructorUsedError; // Premium feature flag
  bool get allowComments =>
      throw _privateConstructorUsedError; // Community features
  bool get allowRating =>
      throw _privateConstructorUsedError; // Community features
  double? get rating => throw _privateConstructorUsedError; // Average rating
// === CLEANUP SAFETY FLAGS ===
  bool get isBeingDeleted =>
      throw _privateConstructorUsedError; // Prevents race conditions
  bool get isSyncInProgress =>
      throw _privateConstructorUsedError; // Prevents concurrent sync
  String? get lastModifiedBy =>
      throw _privateConstructorUsedError; // Conflict resolution
  int? get version => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UnifiedWorkoutTemplateCopyWith<UnifiedWorkoutTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedWorkoutTemplateCopyWith<$Res> {
  factory $UnifiedWorkoutTemplateCopyWith(UnifiedWorkoutTemplate value,
          $Res Function(UnifiedWorkoutTemplate) then) =
      _$UnifiedWorkoutTemplateCopyWithImpl<$Res, UnifiedWorkoutTemplate>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<dynamic> exercisesRaw,
      bool isCustom,
      bool isPublic,
      int usageCount,
      String? imageUrl,
      String? userId,
      String? authorName,
      int downloadCount,
      double averageRating,
      int reviewCount,
      String? difficulty,
      UnifiedTemplateVisibility visibility,
      UnifiedTemplateCategory category,
      int likeCount,
      String? authorPhotoUrl,
      List<String> requiredEquipment,
      List<String> targetMuscles,
      Map<String, dynamic>? adaptiveParameters,
      Map<String, int>? muscleGroupVolume,
      List<String> alternatives,
      DateTime createdAt,
      DateTime? updatedAt,
      List<String> tags,
      int estimatedDuration,
      int? estimatedDurationMinutes,
      ExerciseFormat exerciseFormat,
      TemplateSource source,
      String? importSource,
      DateTime? importDate,
      int useCount,
      bool supportsSuperset,
      bool requiresPremium,
      bool allowComments,
      bool allowRating,
      double? rating,
      bool isBeingDeleted,
      bool isSyncInProgress,
      String? lastModifiedBy,
      int? version});
}

/// @nodoc
class _$UnifiedWorkoutTemplateCopyWithImpl<$Res,
        $Val extends UnifiedWorkoutTemplate>
    implements $UnifiedWorkoutTemplateCopyWith<$Res> {
  _$UnifiedWorkoutTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? exercisesRaw = null,
    Object? isCustom = null,
    Object? isPublic = null,
    Object? usageCount = null,
    Object? imageUrl = freezed,
    Object? userId = freezed,
    Object? authorName = freezed,
    Object? downloadCount = null,
    Object? averageRating = null,
    Object? reviewCount = null,
    Object? difficulty = freezed,
    Object? visibility = null,
    Object? category = null,
    Object? likeCount = null,
    Object? authorPhotoUrl = freezed,
    Object? requiredEquipment = null,
    Object? targetMuscles = null,
    Object? adaptiveParameters = freezed,
    Object? muscleGroupVolume = freezed,
    Object? alternatives = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? estimatedDuration = null,
    Object? estimatedDurationMinutes = freezed,
    Object? exerciseFormat = null,
    Object? source = null,
    Object? importSource = freezed,
    Object? importDate = freezed,
    Object? useCount = null,
    Object? supportsSuperset = null,
    Object? requiresPremium = null,
    Object? allowComments = null,
    Object? allowRating = null,
    Object? rating = freezed,
    Object? isBeingDeleted = null,
    Object? isSyncInProgress = null,
    Object? lastModifiedBy = freezed,
    Object? version = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      exercisesRaw: null == exercisesRaw
          ? _value.exercisesRaw
          : exercisesRaw // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as UnifiedTemplateVisibility,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as UnifiedTemplateCategory,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      authorPhotoUrl: freezed == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredEquipment: null == requiredEquipment
          ? _value.requiredEquipment
          : requiredEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value.targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      adaptiveParameters: freezed == adaptiveParameters
          ? _value.adaptiveParameters
          : adaptiveParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      muscleGroupVolume: freezed == muscleGroupVolume
          ? _value.muscleGroupVolume
          : muscleGroupVolume // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      alternatives: null == alternatives
          ? _value.alternatives
          : alternatives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedDurationMinutes: freezed == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      exerciseFormat: null == exerciseFormat
          ? _value.exerciseFormat
          : exerciseFormat // ignore: cast_nullable_to_non_nullable
              as ExerciseFormat,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as TemplateSource,
      importSource: freezed == importSource
          ? _value.importSource
          : importSource // ignore: cast_nullable_to_non_nullable
              as String?,
      importDate: freezed == importDate
          ? _value.importDate
          : importDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      useCount: null == useCount
          ? _value.useCount
          : useCount // ignore: cast_nullable_to_non_nullable
              as int,
      supportsSuperset: null == supportsSuperset
          ? _value.supportsSuperset
          : supportsSuperset // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresPremium: null == requiresPremium
          ? _value.requiresPremium
          : requiresPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      allowComments: null == allowComments
          ? _value.allowComments
          : allowComments // ignore: cast_nullable_to_non_nullable
              as bool,
      allowRating: null == allowRating
          ? _value.allowRating
          : allowRating // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      isBeingDeleted: null == isBeingDeleted
          ? _value.isBeingDeleted
          : isBeingDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncInProgress: null == isSyncInProgress
          ? _value.isSyncInProgress
          : isSyncInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      lastModifiedBy: freezed == lastModifiedBy
          ? _value.lastModifiedBy
          : lastModifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnifiedWorkoutTemplateImplCopyWith<$Res>
    implements $UnifiedWorkoutTemplateCopyWith<$Res> {
  factory _$$UnifiedWorkoutTemplateImplCopyWith(
          _$UnifiedWorkoutTemplateImpl value,
          $Res Function(_$UnifiedWorkoutTemplateImpl) then) =
      __$$UnifiedWorkoutTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<dynamic> exercisesRaw,
      bool isCustom,
      bool isPublic,
      int usageCount,
      String? imageUrl,
      String? userId,
      String? authorName,
      int downloadCount,
      double averageRating,
      int reviewCount,
      String? difficulty,
      UnifiedTemplateVisibility visibility,
      UnifiedTemplateCategory category,
      int likeCount,
      String? authorPhotoUrl,
      List<String> requiredEquipment,
      List<String> targetMuscles,
      Map<String, dynamic>? adaptiveParameters,
      Map<String, int>? muscleGroupVolume,
      List<String> alternatives,
      DateTime createdAt,
      DateTime? updatedAt,
      List<String> tags,
      int estimatedDuration,
      int? estimatedDurationMinutes,
      ExerciseFormat exerciseFormat,
      TemplateSource source,
      String? importSource,
      DateTime? importDate,
      int useCount,
      bool supportsSuperset,
      bool requiresPremium,
      bool allowComments,
      bool allowRating,
      double? rating,
      bool isBeingDeleted,
      bool isSyncInProgress,
      String? lastModifiedBy,
      int? version});
}

/// @nodoc
class __$$UnifiedWorkoutTemplateImplCopyWithImpl<$Res>
    extends _$UnifiedWorkoutTemplateCopyWithImpl<$Res,
        _$UnifiedWorkoutTemplateImpl>
    implements _$$UnifiedWorkoutTemplateImplCopyWith<$Res> {
  __$$UnifiedWorkoutTemplateImplCopyWithImpl(
      _$UnifiedWorkoutTemplateImpl _value,
      $Res Function(_$UnifiedWorkoutTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? exercisesRaw = null,
    Object? isCustom = null,
    Object? isPublic = null,
    Object? usageCount = null,
    Object? imageUrl = freezed,
    Object? userId = freezed,
    Object? authorName = freezed,
    Object? downloadCount = null,
    Object? averageRating = null,
    Object? reviewCount = null,
    Object? difficulty = freezed,
    Object? visibility = null,
    Object? category = null,
    Object? likeCount = null,
    Object? authorPhotoUrl = freezed,
    Object? requiredEquipment = null,
    Object? targetMuscles = null,
    Object? adaptiveParameters = freezed,
    Object? muscleGroupVolume = freezed,
    Object? alternatives = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? tags = null,
    Object? estimatedDuration = null,
    Object? estimatedDurationMinutes = freezed,
    Object? exerciseFormat = null,
    Object? source = null,
    Object? importSource = freezed,
    Object? importDate = freezed,
    Object? useCount = null,
    Object? supportsSuperset = null,
    Object? requiresPremium = null,
    Object? allowComments = null,
    Object? allowRating = null,
    Object? rating = freezed,
    Object? isBeingDeleted = null,
    Object? isSyncInProgress = null,
    Object? lastModifiedBy = freezed,
    Object? version = freezed,
  }) {
    return _then(_$UnifiedWorkoutTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      exercisesRaw: null == exercisesRaw
          ? _value._exercisesRaw
          : exercisesRaw // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as UnifiedTemplateVisibility,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as UnifiedTemplateCategory,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      authorPhotoUrl: freezed == authorPhotoUrl
          ? _value.authorPhotoUrl
          : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredEquipment: null == requiredEquipment
          ? _value._requiredEquipment
          : requiredEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value._targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      adaptiveParameters: freezed == adaptiveParameters
          ? _value._adaptiveParameters
          : adaptiveParameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      muscleGroupVolume: freezed == muscleGroupVolume
          ? _value._muscleGroupVolume
          : muscleGroupVolume // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      alternatives: null == alternatives
          ? _value._alternatives
          : alternatives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedDurationMinutes: freezed == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      exerciseFormat: null == exerciseFormat
          ? _value.exerciseFormat
          : exerciseFormat // ignore: cast_nullable_to_non_nullable
              as ExerciseFormat,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as TemplateSource,
      importSource: freezed == importSource
          ? _value.importSource
          : importSource // ignore: cast_nullable_to_non_nullable
              as String?,
      importDate: freezed == importDate
          ? _value.importDate
          : importDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      useCount: null == useCount
          ? _value.useCount
          : useCount // ignore: cast_nullable_to_non_nullable
              as int,
      supportsSuperset: null == supportsSuperset
          ? _value.supportsSuperset
          : supportsSuperset // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresPremium: null == requiresPremium
          ? _value.requiresPremium
          : requiresPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      allowComments: null == allowComments
          ? _value.allowComments
          : allowComments // ignore: cast_nullable_to_non_nullable
              as bool,
      allowRating: null == allowRating
          ? _value.allowRating
          : allowRating // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      isBeingDeleted: null == isBeingDeleted
          ? _value.isBeingDeleted
          : isBeingDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncInProgress: null == isSyncInProgress
          ? _value.isSyncInProgress
          : isSyncInProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      lastModifiedBy: freezed == lastModifiedBy
          ? _value.lastModifiedBy
          : lastModifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$UnifiedWorkoutTemplateImpl
    with DiagnosticableTreeMixin
    implements _UnifiedWorkoutTemplate {
  const _$UnifiedWorkoutTemplateImpl(
      {required this.id,
      required this.name,
      this.description = '',
      required final List<dynamic> exercisesRaw,
      this.isCustom = true,
      this.isPublic = false,
      this.usageCount = 0,
      this.imageUrl,
      this.userId,
      this.authorName,
      this.downloadCount = 0,
      this.averageRating = 0.0,
      this.reviewCount = 0,
      this.difficulty,
      this.visibility = UnifiedTemplateVisibility.private,
      this.category = UnifiedTemplateCategory.custom,
      this.likeCount = 0,
      this.authorPhotoUrl,
      final List<String> requiredEquipment = const [],
      final List<String> targetMuscles = const [],
      final Map<String, dynamic>? adaptiveParameters,
      final Map<String, int>? muscleGroupVolume,
      final List<String> alternatives = const [],
      required this.createdAt,
      this.updatedAt,
      final List<String> tags = const [],
      this.estimatedDuration = 45,
      this.estimatedDurationMinutes,
      this.exerciseFormat = ExerciseFormat.legacy,
      this.source = TemplateSource.legacy,
      this.importSource,
      this.importDate,
      this.useCount = 0,
      this.supportsSuperset = false,
      this.requiresPremium = false,
      this.allowComments = false,
      this.allowRating = false,
      this.rating,
      this.isBeingDeleted = false,
      this.isSyncInProgress = false,
      this.lastModifiedBy,
      this.version})
      : _exercisesRaw = exercisesRaw,
        _requiredEquipment = requiredEquipment,
        _targetMuscles = targetMuscles,
        _adaptiveParameters = adaptiveParameters,
        _muscleGroupVolume = muscleGroupVolume,
        _alternatives = alternatives,
        _tags = tags;

// === CORE IDENTIFIER ===
  @override
  final String id;
// === BASIC INFO ===
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
// === EXERCISES - CRITICAL: Support multiple formats ===
  final List<dynamic> _exercisesRaw;
// === EXERCISES - CRITICAL: Support multiple formats ===
  @override
  List<dynamic> get exercisesRaw {
    if (_exercisesRaw is EqualUnmodifiableListView) return _exercisesRaw;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercisesRaw);
  }

// Can be Exercise, ExerciseTemplate, or JSON
// === LEGACY COMPATIBILITY FIELDS ===
// These ensure old code continues working
  @override
  @JsonKey()
  final bool isCustom;
// Legacy: user created vs predefined
  @override
  @JsonKey()
  final bool isPublic;
// Legacy: public sharing
  @override
  @JsonKey()
  final int usageCount;
// Legacy: tracking usage
  @override
  final String? imageUrl;
// Legacy: template image
  @override
  final String? userId;
// Legacy: creator ID
  @override
  final String? authorName;
// Legacy: creator name
  @override
  @JsonKey()
  final int downloadCount;
// Legacy: social stats
  @override
  @JsonKey()
  final double averageRating;
// Legacy: social stats
  @override
  @JsonKey()
  final int reviewCount;
// Legacy: social stats
  @override
  final String? difficulty;
// Legacy: difficulty string
// === MODERN FEATURES ===
  @override
  @JsonKey()
  final UnifiedTemplateVisibility visibility;
// Modern: enum-based visibility
  @override
  @JsonKey()
  final UnifiedTemplateCategory category;
// Modern: structured categories
  @override
  @JsonKey()
  final int likeCount;
// Modern: social engagement
  @override
  final String? authorPhotoUrl;
// Modern: author avatar
  final List<String> _requiredEquipment;
// Modern: author avatar
  @override
  @JsonKey()
  List<String> get requiredEquipment {
    if (_requiredEquipment is EqualUnmodifiableListView)
      return _requiredEquipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredEquipment);
  }

// Modern: equipment tracking
  final List<String> _targetMuscles;
// Modern: equipment tracking
  @override
  @JsonKey()
  List<String> get targetMuscles {
    if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetMuscles);
  }

// Modern: muscle targeting
// === SMART/AI FEATURES ===
  final Map<String, dynamic>? _adaptiveParameters;
// Modern: muscle targeting
// === SMART/AI FEATURES ===
  @override
  Map<String, dynamic>? get adaptiveParameters {
    final value = _adaptiveParameters;
    if (value == null) return null;
    if (_adaptiveParameters is EqualUnmodifiableMapView)
      return _adaptiveParameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Smart: AI adaptation data
  final Map<String, int>? _muscleGroupVolume;
// Smart: AI adaptation data
  @override
  Map<String, int>? get muscleGroupVolume {
    final value = _muscleGroupVolume;
    if (value == null) return null;
    if (_muscleGroupVolume is EqualUnmodifiableMapView)
      return _muscleGroupVolume;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Smart: volume tracking
  final List<String> _alternatives;
// Smart: volume tracking
  @override
  @JsonKey()
  List<String> get alternatives {
    if (_alternatives is EqualUnmodifiableListView) return _alternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternatives);
  }

// Smart: alternative exercises
// === METADATA ===
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

// === DURATION - Support both legacy and modern formats ===
  @override
  @JsonKey()
  final int estimatedDuration;
// Legacy: minutes
  @override
  final int? estimatedDurationMinutes;
// Modern: explicit minutes
// === EXERCISE FORMAT TRACKING ===
  @override
  @JsonKey()
  final ExerciseFormat exerciseFormat;
// Format of exercisesRaw
  @override
  @JsonKey()
  final TemplateSource source;
// Origin tracking
// === IMPORT METADATA ===
  @override
  final String? importSource;
// Source URL/app for imports
  @override
  final DateTime? importDate;
// When imported
// === ADDITIONAL FEATURES ===
  @override
  @JsonKey()
  final int useCount;
// Times used for workouts
  @override
  @JsonKey()
  final bool supportsSuperset;
// Legacy compatibility
  @override
  @JsonKey()
  final bool requiresPremium;
// Premium feature flag
  @override
  @JsonKey()
  final bool allowComments;
// Community features
  @override
  @JsonKey()
  final bool allowRating;
// Community features
  @override
  final double? rating;
// Average rating
// === CLEANUP SAFETY FLAGS ===
  @override
  @JsonKey()
  final bool isBeingDeleted;
// Prevents race conditions
  @override
  @JsonKey()
  final bool isSyncInProgress;
// Prevents concurrent sync
  @override
  final String? lastModifiedBy;
// Conflict resolution
  @override
  final int? version;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UnifiedWorkoutTemplate(id: $id, name: $name, description: $description, exercisesRaw: $exercisesRaw, isCustom: $isCustom, isPublic: $isPublic, usageCount: $usageCount, imageUrl: $imageUrl, userId: $userId, authorName: $authorName, downloadCount: $downloadCount, averageRating: $averageRating, reviewCount: $reviewCount, difficulty: $difficulty, visibility: $visibility, category: $category, likeCount: $likeCount, authorPhotoUrl: $authorPhotoUrl, requiredEquipment: $requiredEquipment, targetMuscles: $targetMuscles, adaptiveParameters: $adaptiveParameters, muscleGroupVolume: $muscleGroupVolume, alternatives: $alternatives, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, estimatedDuration: $estimatedDuration, estimatedDurationMinutes: $estimatedDurationMinutes, exerciseFormat: $exerciseFormat, source: $source, importSource: $importSource, importDate: $importDate, useCount: $useCount, supportsSuperset: $supportsSuperset, requiresPremium: $requiresPremium, allowComments: $allowComments, allowRating: $allowRating, rating: $rating, isBeingDeleted: $isBeingDeleted, isSyncInProgress: $isSyncInProgress, lastModifiedBy: $lastModifiedBy, version: $version)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UnifiedWorkoutTemplate'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('exercisesRaw', exercisesRaw))
      ..add(DiagnosticsProperty('isCustom', isCustom))
      ..add(DiagnosticsProperty('isPublic', isPublic))
      ..add(DiagnosticsProperty('usageCount', usageCount))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('authorName', authorName))
      ..add(DiagnosticsProperty('downloadCount', downloadCount))
      ..add(DiagnosticsProperty('averageRating', averageRating))
      ..add(DiagnosticsProperty('reviewCount', reviewCount))
      ..add(DiagnosticsProperty('difficulty', difficulty))
      ..add(DiagnosticsProperty('visibility', visibility))
      ..add(DiagnosticsProperty('category', category))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('authorPhotoUrl', authorPhotoUrl))
      ..add(DiagnosticsProperty('requiredEquipment', requiredEquipment))
      ..add(DiagnosticsProperty('targetMuscles', targetMuscles))
      ..add(DiagnosticsProperty('adaptiveParameters', adaptiveParameters))
      ..add(DiagnosticsProperty('muscleGroupVolume', muscleGroupVolume))
      ..add(DiagnosticsProperty('alternatives', alternatives))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('estimatedDuration', estimatedDuration))
      ..add(DiagnosticsProperty(
          'estimatedDurationMinutes', estimatedDurationMinutes))
      ..add(DiagnosticsProperty('exerciseFormat', exerciseFormat))
      ..add(DiagnosticsProperty('source', source))
      ..add(DiagnosticsProperty('importSource', importSource))
      ..add(DiagnosticsProperty('importDate', importDate))
      ..add(DiagnosticsProperty('useCount', useCount))
      ..add(DiagnosticsProperty('supportsSuperset', supportsSuperset))
      ..add(DiagnosticsProperty('requiresPremium', requiresPremium))
      ..add(DiagnosticsProperty('allowComments', allowComments))
      ..add(DiagnosticsProperty('allowRating', allowRating))
      ..add(DiagnosticsProperty('rating', rating))
      ..add(DiagnosticsProperty('isBeingDeleted', isBeingDeleted))
      ..add(DiagnosticsProperty('isSyncInProgress', isSyncInProgress))
      ..add(DiagnosticsProperty('lastModifiedBy', lastModifiedBy))
      ..add(DiagnosticsProperty('version', version));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnifiedWorkoutTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._exercisesRaw, _exercisesRaw) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.authorPhotoUrl, authorPhotoUrl) ||
                other.authorPhotoUrl == authorPhotoUrl) &&
            const DeepCollectionEquality()
                .equals(other._requiredEquipment, _requiredEquipment) &&
            const DeepCollectionEquality()
                .equals(other._targetMuscles, _targetMuscles) &&
            const DeepCollectionEquality()
                .equals(other._adaptiveParameters, _adaptiveParameters) &&
            const DeepCollectionEquality()
                .equals(other._muscleGroupVolume, _muscleGroupVolume) &&
            const DeepCollectionEquality()
                .equals(other._alternatives, _alternatives) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.exerciseFormat, exerciseFormat) ||
                other.exerciseFormat == exerciseFormat) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.importSource, importSource) ||
                other.importSource == importSource) &&
            (identical(other.importDate, importDate) ||
                other.importDate == importDate) &&
            (identical(other.useCount, useCount) ||
                other.useCount == useCount) &&
            (identical(other.supportsSuperset, supportsSuperset) ||
                other.supportsSuperset == supportsSuperset) &&
            (identical(other.requiresPremium, requiresPremium) ||
                other.requiresPremium == requiresPremium) &&
            (identical(other.allowComments, allowComments) ||
                other.allowComments == allowComments) &&
            (identical(other.allowRating, allowRating) ||
                other.allowRating == allowRating) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.isBeingDeleted, isBeingDeleted) ||
                other.isBeingDeleted == isBeingDeleted) &&
            (identical(other.isSyncInProgress, isSyncInProgress) ||
                other.isSyncInProgress == isSyncInProgress) &&
            (identical(other.lastModifiedBy, lastModifiedBy) ||
                other.lastModifiedBy == lastModifiedBy) &&
            (identical(other.version, version) || other.version == version));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        const DeepCollectionEquality().hash(_exercisesRaw),
        isCustom,
        isPublic,
        usageCount,
        imageUrl,
        userId,
        authorName,
        downloadCount,
        averageRating,
        reviewCount,
        difficulty,
        visibility,
        category,
        likeCount,
        authorPhotoUrl,
        const DeepCollectionEquality().hash(_requiredEquipment),
        const DeepCollectionEquality().hash(_targetMuscles),
        const DeepCollectionEquality().hash(_adaptiveParameters),
        const DeepCollectionEquality().hash(_muscleGroupVolume),
        const DeepCollectionEquality().hash(_alternatives),
        createdAt,
        updatedAt,
        const DeepCollectionEquality().hash(_tags),
        estimatedDuration,
        estimatedDurationMinutes,
        exerciseFormat,
        source,
        importSource,
        importDate,
        useCount,
        supportsSuperset,
        requiresPremium,
        allowComments,
        allowRating,
        rating,
        isBeingDeleted,
        isSyncInProgress,
        lastModifiedBy,
        version
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnifiedWorkoutTemplateImplCopyWith<_$UnifiedWorkoutTemplateImpl>
      get copyWith => __$$UnifiedWorkoutTemplateImplCopyWithImpl<
          _$UnifiedWorkoutTemplateImpl>(this, _$identity);
}

abstract class _UnifiedWorkoutTemplate implements UnifiedWorkoutTemplate {
  const factory _UnifiedWorkoutTemplate(
      {required final String id,
      required final String name,
      final String description,
      required final List<dynamic> exercisesRaw,
      final bool isCustom,
      final bool isPublic,
      final int usageCount,
      final String? imageUrl,
      final String? userId,
      final String? authorName,
      final int downloadCount,
      final double averageRating,
      final int reviewCount,
      final String? difficulty,
      final UnifiedTemplateVisibility visibility,
      final UnifiedTemplateCategory category,
      final int likeCount,
      final String? authorPhotoUrl,
      final List<String> requiredEquipment,
      final List<String> targetMuscles,
      final Map<String, dynamic>? adaptiveParameters,
      final Map<String, int>? muscleGroupVolume,
      final List<String> alternatives,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final List<String> tags,
      final int estimatedDuration,
      final int? estimatedDurationMinutes,
      final ExerciseFormat exerciseFormat,
      final TemplateSource source,
      final String? importSource,
      final DateTime? importDate,
      final int useCount,
      final bool supportsSuperset,
      final bool requiresPremium,
      final bool allowComments,
      final bool allowRating,
      final double? rating,
      final bool isBeingDeleted,
      final bool isSyncInProgress,
      final String? lastModifiedBy,
      final int? version}) = _$UnifiedWorkoutTemplateImpl;

  @override // === CORE IDENTIFIER ===
  String get id;
  @override // === BASIC INFO ===
  String get name;
  @override
  String get description;
  @override // === EXERCISES - CRITICAL: Support multiple formats ===
  List<dynamic> get exercisesRaw;
  @override // Can be Exercise, ExerciseTemplate, or JSON
// === LEGACY COMPATIBILITY FIELDS ===
// These ensure old code continues working
  bool get isCustom;
  @override // Legacy: user created vs predefined
  bool get isPublic;
  @override // Legacy: public sharing
  int get usageCount;
  @override // Legacy: tracking usage
  String? get imageUrl;
  @override // Legacy: template image
  String? get userId;
  @override // Legacy: creator ID
  String? get authorName;
  @override // Legacy: creator name
  int get downloadCount;
  @override // Legacy: social stats
  double get averageRating;
  @override // Legacy: social stats
  int get reviewCount;
  @override // Legacy: social stats
  String? get difficulty;
  @override // Legacy: difficulty string
// === MODERN FEATURES ===
  UnifiedTemplateVisibility get visibility;
  @override // Modern: enum-based visibility
  UnifiedTemplateCategory get category;
  @override // Modern: structured categories
  int get likeCount;
  @override // Modern: social engagement
  String? get authorPhotoUrl;
  @override // Modern: author avatar
  List<String> get requiredEquipment;
  @override // Modern: equipment tracking
  List<String> get targetMuscles;
  @override // Modern: muscle targeting
// === SMART/AI FEATURES ===
  Map<String, dynamic>? get adaptiveParameters;
  @override // Smart: AI adaptation data
  Map<String, int>? get muscleGroupVolume;
  @override // Smart: volume tracking
  List<String> get alternatives;
  @override // Smart: alternative exercises
// === METADATA ===
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  List<String> get tags;
  @override // === DURATION - Support both legacy and modern formats ===
  int get estimatedDuration;
  @override // Legacy: minutes
  int? get estimatedDurationMinutes;
  @override // Modern: explicit minutes
// === EXERCISE FORMAT TRACKING ===
  ExerciseFormat get exerciseFormat;
  @override // Format of exercisesRaw
  TemplateSource get source;
  @override // Origin tracking
// === IMPORT METADATA ===
  String? get importSource;
  @override // Source URL/app for imports
  DateTime? get importDate;
  @override // When imported
// === ADDITIONAL FEATURES ===
  int get useCount;
  @override // Times used for workouts
  bool get supportsSuperset;
  @override // Legacy compatibility
  bool get requiresPremium;
  @override // Premium feature flag
  bool get allowComments;
  @override // Community features
  bool get allowRating;
  @override // Community features
  double? get rating;
  @override // Average rating
// === CLEANUP SAFETY FLAGS ===
  bool get isBeingDeleted;
  @override // Prevents race conditions
  bool get isSyncInProgress;
  @override // Prevents concurrent sync
  String? get lastModifiedBy;
  @override // Conflict resolution
  int? get version;
  @override
  @JsonKey(ignore: true)
  _$$UnifiedWorkoutTemplateImplCopyWith<_$UnifiedWorkoutTemplateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
