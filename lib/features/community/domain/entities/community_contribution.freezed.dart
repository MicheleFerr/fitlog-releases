// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommunityContribution _$CommunityContributionFromJson(
  Map<String, dynamic> json,
) {
  return _CommunityContribution.fromJson(json);
}

/// @nodoc
mixin _$CommunityContribution {
  String get id => throw _privateConstructorUsedError;
  String get exerciseId => throw _privateConstructorUsedError;
  String get exerciseName => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userAvatar => throw _privateConstructorUsedError;
  ContributionType get type => throw _privateConstructorUsedError;
  ContributionStatus get status => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get originalValue => throw _privateConstructorUsedError;
  String? get suggestedValue => throw _privateConstructorUsedError;
  int get upvotes => throw _privateConstructorUsedError;
  int get downvotes => throw _privateConstructorUsedError;
  List<String> get upvotedBy => throw _privateConstructorUsedError;
  List<String> get downvotedBy => throw _privateConstructorUsedError;
  List<ContributionComment> get comments => throw _privateConstructorUsedError;
  String? get reviewNote => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  int get trustScore =>
      throw _privateConstructorUsedError; // 0-100 basato su track record utente
  Map<String, dynamic>? get metadata =>
      throw _privateConstructorUsedError; // NEW: Discovery & Search fields
  List<String> get exerciseIds =>
      throw _privateConstructorUsedError; // Multiple exercises (was single exerciseId)
  String get difficulty =>
      throw _privateConstructorUsedError; // beginner, intermediate, advanced
  List<String> get tags =>
      throw _privateConstructorUsedError; // User-added tags (lowercase, max 5)
  List<String> get applicableTo =>
      throw _privateConstructorUsedError; // Goals: hypertrophy, strength, mobility
  String? get authorTier =>
      throw _privateConstructorUsedError; // community, expert, admin (nullable for backward compat)
  double get authorTrustScore => throw _privateConstructorUsedError; // 0-1
  double get qualityScore =>
      throw _privateConstructorUsedError; // 0-1 (aggregate score)
  int get saves => throw _privateConstructorUsedError; // How many users saved
  int get viewCount => throw _privateConstructorUsedError; // Track popularity
  DateTime? get lastActivityAt =>
      throw _privateConstructorUsedError; // For trending
  String? get sourceType =>
      throw _privateConstructorUsedError; // exerciseDb, userSubmitted
  List<String> get relatedExerciseIds => throw _privateConstructorUsedError;

  /// Serializes this CommunityContribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommunityContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityContributionCopyWith<CommunityContribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityContributionCopyWith<$Res> {
  factory $CommunityContributionCopyWith(
    CommunityContribution value,
    $Res Function(CommunityContribution) then,
  ) = _$CommunityContributionCopyWithImpl<$Res, CommunityContribution>;
  @useResult
  $Res call({
    String id,
    String exerciseId,
    String exerciseName,
    String userId,
    String userName,
    String? userAvatar,
    ContributionType type,
    ContributionStatus status,
    String title,
    String description,
    String? originalValue,
    String? suggestedValue,
    int upvotes,
    int downvotes,
    List<String> upvotedBy,
    List<String> downvotedBy,
    List<ContributionComment> comments,
    String? reviewNote,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime createdAt,
    DateTime? updatedAt,
    bool isFeatured,
    int trustScore,
    Map<String, dynamic>? metadata,
    List<String> exerciseIds,
    String difficulty,
    List<String> tags,
    List<String> applicableTo,
    String? authorTier,
    double authorTrustScore,
    double qualityScore,
    int saves,
    int viewCount,
    DateTime? lastActivityAt,
    String? sourceType,
    List<String> relatedExerciseIds,
  });
}

/// @nodoc
class _$CommunityContributionCopyWithImpl<
  $Res,
  $Val extends CommunityContribution
>
    implements $CommunityContributionCopyWith<$Res> {
  _$CommunityContributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? type = null,
    Object? status = null,
    Object? title = null,
    Object? description = null,
    Object? originalValue = freezed,
    Object? suggestedValue = freezed,
    Object? upvotes = null,
    Object? downvotes = null,
    Object? upvotedBy = null,
    Object? downvotedBy = null,
    Object? comments = null,
    Object? reviewNote = freezed,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isFeatured = null,
    Object? trustScore = null,
    Object? metadata = freezed,
    Object? exerciseIds = null,
    Object? difficulty = null,
    Object? tags = null,
    Object? applicableTo = null,
    Object? authorTier = freezed,
    Object? authorTrustScore = null,
    Object? qualityScore = null,
    Object? saves = null,
    Object? viewCount = null,
    Object? lastActivityAt = freezed,
    Object? sourceType = freezed,
    Object? relatedExerciseIds = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            exerciseId: null == exerciseId
                ? _value.exerciseId
                : exerciseId // ignore: cast_nullable_to_non_nullable
                      as String,
            exerciseName: null == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userAvatar: freezed == userAvatar
                ? _value.userAvatar
                : userAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ContributionType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ContributionStatus,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            originalValue: freezed == originalValue
                ? _value.originalValue
                : originalValue // ignore: cast_nullable_to_non_nullable
                      as String?,
            suggestedValue: freezed == suggestedValue
                ? _value.suggestedValue
                : suggestedValue // ignore: cast_nullable_to_non_nullable
                      as String?,
            upvotes: null == upvotes
                ? _value.upvotes
                : upvotes // ignore: cast_nullable_to_non_nullable
                      as int,
            downvotes: null == downvotes
                ? _value.downvotes
                : downvotes // ignore: cast_nullable_to_non_nullable
                      as int,
            upvotedBy: null == upvotedBy
                ? _value.upvotedBy
                : upvotedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            downvotedBy: null == downvotedBy
                ? _value.downvotedBy
                : downvotedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            comments: null == comments
                ? _value.comments
                : comments // ignore: cast_nullable_to_non_nullable
                      as List<ContributionComment>,
            reviewNote: freezed == reviewNote
                ? _value.reviewNote
                : reviewNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewedBy: freezed == reviewedBy
                ? _value.reviewedBy
                : reviewedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewedAt: freezed == reviewedAt
                ? _value.reviewedAt
                : reviewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
            trustScore: null == trustScore
                ? _value.trustScore
                : trustScore // ignore: cast_nullable_to_non_nullable
                      as int,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            exerciseIds: null == exerciseIds
                ? _value.exerciseIds
                : exerciseIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            applicableTo: null == applicableTo
                ? _value.applicableTo
                : applicableTo // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            authorTier: freezed == authorTier
                ? _value.authorTier
                : authorTier // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorTrustScore: null == authorTrustScore
                ? _value.authorTrustScore
                : authorTrustScore // ignore: cast_nullable_to_non_nullable
                      as double,
            qualityScore: null == qualityScore
                ? _value.qualityScore
                : qualityScore // ignore: cast_nullable_to_non_nullable
                      as double,
            saves: null == saves
                ? _value.saves
                : saves // ignore: cast_nullable_to_non_nullable
                      as int,
            viewCount: null == viewCount
                ? _value.viewCount
                : viewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastActivityAt: freezed == lastActivityAt
                ? _value.lastActivityAt
                : lastActivityAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sourceType: freezed == sourceType
                ? _value.sourceType
                : sourceType // ignore: cast_nullable_to_non_nullable
                      as String?,
            relatedExerciseIds: null == relatedExerciseIds
                ? _value.relatedExerciseIds
                : relatedExerciseIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityContributionImplCopyWith<$Res>
    implements $CommunityContributionCopyWith<$Res> {
  factory _$$CommunityContributionImplCopyWith(
    _$CommunityContributionImpl value,
    $Res Function(_$CommunityContributionImpl) then,
  ) = __$$CommunityContributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String exerciseId,
    String exerciseName,
    String userId,
    String userName,
    String? userAvatar,
    ContributionType type,
    ContributionStatus status,
    String title,
    String description,
    String? originalValue,
    String? suggestedValue,
    int upvotes,
    int downvotes,
    List<String> upvotedBy,
    List<String> downvotedBy,
    List<ContributionComment> comments,
    String? reviewNote,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime createdAt,
    DateTime? updatedAt,
    bool isFeatured,
    int trustScore,
    Map<String, dynamic>? metadata,
    List<String> exerciseIds,
    String difficulty,
    List<String> tags,
    List<String> applicableTo,
    String? authorTier,
    double authorTrustScore,
    double qualityScore,
    int saves,
    int viewCount,
    DateTime? lastActivityAt,
    String? sourceType,
    List<String> relatedExerciseIds,
  });
}

/// @nodoc
class __$$CommunityContributionImplCopyWithImpl<$Res>
    extends
        _$CommunityContributionCopyWithImpl<$Res, _$CommunityContributionImpl>
    implements _$$CommunityContributionImplCopyWith<$Res> {
  __$$CommunityContributionImplCopyWithImpl(
    _$CommunityContributionImpl _value,
    $Res Function(_$CommunityContributionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? type = null,
    Object? status = null,
    Object? title = null,
    Object? description = null,
    Object? originalValue = freezed,
    Object? suggestedValue = freezed,
    Object? upvotes = null,
    Object? downvotes = null,
    Object? upvotedBy = null,
    Object? downvotedBy = null,
    Object? comments = null,
    Object? reviewNote = freezed,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isFeatured = null,
    Object? trustScore = null,
    Object? metadata = freezed,
    Object? exerciseIds = null,
    Object? difficulty = null,
    Object? tags = null,
    Object? applicableTo = null,
    Object? authorTier = freezed,
    Object? authorTrustScore = null,
    Object? qualityScore = null,
    Object? saves = null,
    Object? viewCount = null,
    Object? lastActivityAt = freezed,
    Object? sourceType = freezed,
    Object? relatedExerciseIds = null,
  }) {
    return _then(
      _$CommunityContributionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userAvatar: freezed == userAvatar
            ? _value.userAvatar
            : userAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ContributionType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ContributionStatus,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        originalValue: freezed == originalValue
            ? _value.originalValue
            : originalValue // ignore: cast_nullable_to_non_nullable
                  as String?,
        suggestedValue: freezed == suggestedValue
            ? _value.suggestedValue
            : suggestedValue // ignore: cast_nullable_to_non_nullable
                  as String?,
        upvotes: null == upvotes
            ? _value.upvotes
            : upvotes // ignore: cast_nullable_to_non_nullable
                  as int,
        downvotes: null == downvotes
            ? _value.downvotes
            : downvotes // ignore: cast_nullable_to_non_nullable
                  as int,
        upvotedBy: null == upvotedBy
            ? _value._upvotedBy
            : upvotedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        downvotedBy: null == downvotedBy
            ? _value._downvotedBy
            : downvotedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        comments: null == comments
            ? _value._comments
            : comments // ignore: cast_nullable_to_non_nullable
                  as List<ContributionComment>,
        reviewNote: freezed == reviewNote
            ? _value.reviewNote
            : reviewNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewedBy: freezed == reviewedBy
            ? _value.reviewedBy
            : reviewedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewedAt: freezed == reviewedAt
            ? _value.reviewedAt
            : reviewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
        trustScore: null == trustScore
            ? _value.trustScore
            : trustScore // ignore: cast_nullable_to_non_nullable
                  as int,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        exerciseIds: null == exerciseIds
            ? _value._exerciseIds
            : exerciseIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        applicableTo: null == applicableTo
            ? _value._applicableTo
            : applicableTo // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        authorTier: freezed == authorTier
            ? _value.authorTier
            : authorTier // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorTrustScore: null == authorTrustScore
            ? _value.authorTrustScore
            : authorTrustScore // ignore: cast_nullable_to_non_nullable
                  as double,
        qualityScore: null == qualityScore
            ? _value.qualityScore
            : qualityScore // ignore: cast_nullable_to_non_nullable
                  as double,
        saves: null == saves
            ? _value.saves
            : saves // ignore: cast_nullable_to_non_nullable
                  as int,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastActivityAt: freezed == lastActivityAt
            ? _value.lastActivityAt
            : lastActivityAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sourceType: freezed == sourceType
            ? _value.sourceType
            : sourceType // ignore: cast_nullable_to_non_nullable
                  as String?,
        relatedExerciseIds: null == relatedExerciseIds
            ? _value._relatedExerciseIds
            : relatedExerciseIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityContributionImpl implements _CommunityContribution {
  const _$CommunityContributionImpl({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    this.originalValue,
    this.suggestedValue,
    this.upvotes = 0,
    this.downvotes = 0,
    final List<String> upvotedBy = const [],
    final List<String> downvotedBy = const [],
    final List<ContributionComment> comments = const [],
    this.reviewNote,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
    this.isFeatured = false,
    this.trustScore = 0,
    final Map<String, dynamic>? metadata,
    final List<String> exerciseIds = const [],
    this.difficulty = 'beginner',
    final List<String> tags = const [],
    final List<String> applicableTo = const [],
    this.authorTier,
    this.authorTrustScore = 0.5,
    this.qualityScore = 0.5,
    this.saves = 0,
    this.viewCount = 0,
    this.lastActivityAt,
    this.sourceType,
    final List<String> relatedExerciseIds = const [],
  }) : _upvotedBy = upvotedBy,
       _downvotedBy = downvotedBy,
       _comments = comments,
       _metadata = metadata,
       _exerciseIds = exerciseIds,
       _tags = tags,
       _applicableTo = applicableTo,
       _relatedExerciseIds = relatedExerciseIds;

  factory _$CommunityContributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityContributionImplFromJson(json);

  @override
  final String id;
  @override
  final String exerciseId;
  @override
  final String exerciseName;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userAvatar;
  @override
  final ContributionType type;
  @override
  final ContributionStatus status;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? originalValue;
  @override
  final String? suggestedValue;
  @override
  @JsonKey()
  final int upvotes;
  @override
  @JsonKey()
  final int downvotes;
  final List<String> _upvotedBy;
  @override
  @JsonKey()
  List<String> get upvotedBy {
    if (_upvotedBy is EqualUnmodifiableListView) return _upvotedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upvotedBy);
  }

  final List<String> _downvotedBy;
  @override
  @JsonKey()
  List<String> get downvotedBy {
    if (_downvotedBy is EqualUnmodifiableListView) return _downvotedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_downvotedBy);
  }

  final List<ContributionComment> _comments;
  @override
  @JsonKey()
  List<ContributionComment> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  final String? reviewNote;
  @override
  final String? reviewedBy;
  @override
  final DateTime? reviewedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final int trustScore;
  // 0-100 basato su track record utente
  final Map<String, dynamic>? _metadata;
  // 0-100 basato su track record utente
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // NEW: Discovery & Search fields
  final List<String> _exerciseIds;
  // NEW: Discovery & Search fields
  @override
  @JsonKey()
  List<String> get exerciseIds {
    if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseIds);
  }

  // Multiple exercises (was single exerciseId)
  @override
  @JsonKey()
  final String difficulty;
  // beginner, intermediate, advanced
  final List<String> _tags;
  // beginner, intermediate, advanced
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  // User-added tags (lowercase, max 5)
  final List<String> _applicableTo;
  // User-added tags (lowercase, max 5)
  @override
  @JsonKey()
  List<String> get applicableTo {
    if (_applicableTo is EqualUnmodifiableListView) return _applicableTo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_applicableTo);
  }

  // Goals: hypertrophy, strength, mobility
  @override
  final String? authorTier;
  // community, expert, admin (nullable for backward compat)
  @override
  @JsonKey()
  final double authorTrustScore;
  // 0-1
  @override
  @JsonKey()
  final double qualityScore;
  // 0-1 (aggregate score)
  @override
  @JsonKey()
  final int saves;
  // How many users saved
  @override
  @JsonKey()
  final int viewCount;
  // Track popularity
  @override
  final DateTime? lastActivityAt;
  // For trending
  @override
  final String? sourceType;
  // exerciseDb, userSubmitted
  final List<String> _relatedExerciseIds;
  // exerciseDb, userSubmitted
  @override
  @JsonKey()
  List<String> get relatedExerciseIds {
    if (_relatedExerciseIds is EqualUnmodifiableListView)
      return _relatedExerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedExerciseIds);
  }

  @override
  String toString() {
    return 'CommunityContribution(id: $id, exerciseId: $exerciseId, exerciseName: $exerciseName, userId: $userId, userName: $userName, userAvatar: $userAvatar, type: $type, status: $status, title: $title, description: $description, originalValue: $originalValue, suggestedValue: $suggestedValue, upvotes: $upvotes, downvotes: $downvotes, upvotedBy: $upvotedBy, downvotedBy: $downvotedBy, comments: $comments, reviewNote: $reviewNote, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt, isFeatured: $isFeatured, trustScore: $trustScore, metadata: $metadata, exerciseIds: $exerciseIds, difficulty: $difficulty, tags: $tags, applicableTo: $applicableTo, authorTier: $authorTier, authorTrustScore: $authorTrustScore, qualityScore: $qualityScore, saves: $saves, viewCount: $viewCount, lastActivityAt: $lastActivityAt, sourceType: $sourceType, relatedExerciseIds: $relatedExerciseIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityContributionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.originalValue, originalValue) ||
                other.originalValue == originalValue) &&
            (identical(other.suggestedValue, suggestedValue) ||
                other.suggestedValue == suggestedValue) &&
            (identical(other.upvotes, upvotes) || other.upvotes == upvotes) &&
            (identical(other.downvotes, downvotes) ||
                other.downvotes == downvotes) &&
            const DeepCollectionEquality().equals(
              other._upvotedBy,
              _upvotedBy,
            ) &&
            const DeepCollectionEquality().equals(
              other._downvotedBy,
              _downvotedBy,
            ) &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.reviewNote, reviewNote) ||
                other.reviewNote == reviewNote) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.trustScore, trustScore) ||
                other.trustScore == trustScore) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(
              other._exerciseIds,
              _exerciseIds,
            ) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._applicableTo,
              _applicableTo,
            ) &&
            (identical(other.authorTier, authorTier) ||
                other.authorTier == authorTier) &&
            (identical(other.authorTrustScore, authorTrustScore) ||
                other.authorTrustScore == authorTrustScore) &&
            (identical(other.qualityScore, qualityScore) ||
                other.qualityScore == qualityScore) &&
            (identical(other.saves, saves) || other.saves == saves) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            const DeepCollectionEquality().equals(
              other._relatedExerciseIds,
              _relatedExerciseIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    exerciseId,
    exerciseName,
    userId,
    userName,
    userAvatar,
    type,
    status,
    title,
    description,
    originalValue,
    suggestedValue,
    upvotes,
    downvotes,
    const DeepCollectionEquality().hash(_upvotedBy),
    const DeepCollectionEquality().hash(_downvotedBy),
    const DeepCollectionEquality().hash(_comments),
    reviewNote,
    reviewedBy,
    reviewedAt,
    createdAt,
    updatedAt,
    isFeatured,
    trustScore,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_exerciseIds),
    difficulty,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_applicableTo),
    authorTier,
    authorTrustScore,
    qualityScore,
    saves,
    viewCount,
    lastActivityAt,
    sourceType,
    const DeepCollectionEquality().hash(_relatedExerciseIds),
  ]);

  /// Create a copy of CommunityContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityContributionImplCopyWith<_$CommunityContributionImpl>
  get copyWith =>
      __$$CommunityContributionImplCopyWithImpl<_$CommunityContributionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityContributionImplToJson(this);
  }
}

abstract class _CommunityContribution implements CommunityContribution {
  const factory _CommunityContribution({
    required final String id,
    required final String exerciseId,
    required final String exerciseName,
    required final String userId,
    required final String userName,
    final String? userAvatar,
    required final ContributionType type,
    required final ContributionStatus status,
    required final String title,
    required final String description,
    final String? originalValue,
    final String? suggestedValue,
    final int upvotes,
    final int downvotes,
    final List<String> upvotedBy,
    final List<String> downvotedBy,
    final List<ContributionComment> comments,
    final String? reviewNote,
    final String? reviewedBy,
    final DateTime? reviewedAt,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final bool isFeatured,
    final int trustScore,
    final Map<String, dynamic>? metadata,
    final List<String> exerciseIds,
    final String difficulty,
    final List<String> tags,
    final List<String> applicableTo,
    final String? authorTier,
    final double authorTrustScore,
    final double qualityScore,
    final int saves,
    final int viewCount,
    final DateTime? lastActivityAt,
    final String? sourceType,
    final List<String> relatedExerciseIds,
  }) = _$CommunityContributionImpl;

  factory _CommunityContribution.fromJson(Map<String, dynamic> json) =
      _$CommunityContributionImpl.fromJson;

  @override
  String get id;
  @override
  String get exerciseId;
  @override
  String get exerciseName;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userAvatar;
  @override
  ContributionType get type;
  @override
  ContributionStatus get status;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get originalValue;
  @override
  String? get suggestedValue;
  @override
  int get upvotes;
  @override
  int get downvotes;
  @override
  List<String> get upvotedBy;
  @override
  List<String> get downvotedBy;
  @override
  List<ContributionComment> get comments;
  @override
  String? get reviewNote;
  @override
  String? get reviewedBy;
  @override
  DateTime? get reviewedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isFeatured;
  @override
  int get trustScore; // 0-100 basato su track record utente
  @override
  Map<String, dynamic>? get metadata; // NEW: Discovery & Search fields
  @override
  List<String> get exerciseIds; // Multiple exercises (was single exerciseId)
  @override
  String get difficulty; // beginner, intermediate, advanced
  @override
  List<String> get tags; // User-added tags (lowercase, max 5)
  @override
  List<String> get applicableTo; // Goals: hypertrophy, strength, mobility
  @override
  String? get authorTier; // community, expert, admin (nullable for backward compat)
  @override
  double get authorTrustScore; // 0-1
  @override
  double get qualityScore; // 0-1 (aggregate score)
  @override
  int get saves; // How many users saved
  @override
  int get viewCount; // Track popularity
  @override
  DateTime? get lastActivityAt; // For trending
  @override
  String? get sourceType; // exerciseDb, userSubmitted
  @override
  List<String> get relatedExerciseIds;

  /// Create a copy of CommunityContribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityContributionImplCopyWith<_$CommunityContributionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ContributionComment _$ContributionCommentFromJson(Map<String, dynamic> json) {
  return _ContributionComment.fromJson(json);
}

/// @nodoc
mixin _$ContributionComment {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userAvatar => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  List<String> get likedBy => throw _privateConstructorUsedError;

  /// Serializes this ContributionComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContributionComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContributionCommentCopyWith<ContributionComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContributionCommentCopyWith<$Res> {
  factory $ContributionCommentCopyWith(
    ContributionComment value,
    $Res Function(ContributionComment) then,
  ) = _$ContributionCommentCopyWithImpl<$Res, ContributionComment>;
  @useResult
  $Res call({
    String id,
    String userId,
    String userName,
    String? userAvatar,
    String text,
    DateTime createdAt,
    int likes,
    List<String> likedBy,
  });
}

/// @nodoc
class _$ContributionCommentCopyWithImpl<$Res, $Val extends ContributionComment>
    implements $ContributionCommentCopyWith<$Res> {
  _$ContributionCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContributionComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? text = null,
    Object? createdAt = null,
    Object? likes = null,
    Object? likedBy = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userAvatar: freezed == userAvatar
                ? _value.userAvatar
                : userAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            likes: null == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                      as int,
            likedBy: null == likedBy
                ? _value.likedBy
                : likedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContributionCommentImplCopyWith<$Res>
    implements $ContributionCommentCopyWith<$Res> {
  factory _$$ContributionCommentImplCopyWith(
    _$ContributionCommentImpl value,
    $Res Function(_$ContributionCommentImpl) then,
  ) = __$$ContributionCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String userName,
    String? userAvatar,
    String text,
    DateTime createdAt,
    int likes,
    List<String> likedBy,
  });
}

/// @nodoc
class __$$ContributionCommentImplCopyWithImpl<$Res>
    extends _$ContributionCommentCopyWithImpl<$Res, _$ContributionCommentImpl>
    implements _$$ContributionCommentImplCopyWith<$Res> {
  __$$ContributionCommentImplCopyWithImpl(
    _$ContributionCommentImpl _value,
    $Res Function(_$ContributionCommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContributionComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? text = null,
    Object? createdAt = null,
    Object? likes = null,
    Object? likedBy = null,
  }) {
    return _then(
      _$ContributionCommentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userAvatar: freezed == userAvatar
            ? _value.userAvatar
            : userAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        likes: null == likes
            ? _value.likes
            : likes // ignore: cast_nullable_to_non_nullable
                  as int,
        likedBy: null == likedBy
            ? _value._likedBy
            : likedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContributionCommentImpl implements _ContributionComment {
  const _$ContributionCommentImpl({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    final List<String> likedBy = const [],
  }) : _likedBy = likedBy;

  factory _$ContributionCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContributionCommentImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userAvatar;
  @override
  final String text;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int likes;
  final List<String> _likedBy;
  @override
  @JsonKey()
  List<String> get likedBy {
    if (_likedBy is EqualUnmodifiableListView) return _likedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedBy);
  }

  @override
  String toString() {
    return 'ContributionComment(id: $id, userId: $userId, userName: $userName, userAvatar: $userAvatar, text: $text, createdAt: $createdAt, likes: $likes, likedBy: $likedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContributionCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            const DeepCollectionEquality().equals(other._likedBy, _likedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userName,
    userAvatar,
    text,
    createdAt,
    likes,
    const DeepCollectionEquality().hash(_likedBy),
  );

  /// Create a copy of ContributionComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContributionCommentImplCopyWith<_$ContributionCommentImpl> get copyWith =>
      __$$ContributionCommentImplCopyWithImpl<_$ContributionCommentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContributionCommentImplToJson(this);
  }
}

abstract class _ContributionComment implements ContributionComment {
  const factory _ContributionComment({
    required final String id,
    required final String userId,
    required final String userName,
    final String? userAvatar,
    required final String text,
    required final DateTime createdAt,
    final int likes,
    final List<String> likedBy,
  }) = _$ContributionCommentImpl;

  factory _ContributionComment.fromJson(Map<String, dynamic> json) =
      _$ContributionCommentImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userAvatar;
  @override
  String get text;
  @override
  DateTime get createdAt;
  @override
  int get likes;
  @override
  List<String> get likedBy;

  /// Create a copy of ContributionComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContributionCommentImplCopyWith<_$ContributionCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserContributionStats _$UserContributionStatsFromJson(
  Map<String, dynamic> json,
) {
  return _UserContributionStats.fromJson(json);
}

/// @nodoc
mixin _$UserContributionStats {
  String get userId => throw _privateConstructorUsedError;
  int get totalContributions => throw _privateConstructorUsedError;
  int get approvedContributions => throw _privateConstructorUsedError;
  int get rejectedContributions => throw _privateConstructorUsedError;
  int get pendingContributions => throw _privateConstructorUsedError;
  int get totalVotes => throw _privateConstructorUsedError;
  int get totalPoints => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  List<ContributorBadge> get badges => throw _privateConstructorUsedError;
  DateTime? get lastContributionDate => throw _privateConstructorUsedError;
  Map<String, int> get contributionsByType =>
      throw _privateConstructorUsedError;
  double get approvalRate => throw _privateConstructorUsedError;
  int get weeklyRank => throw _privateConstructorUsedError;
  int get monthlyRank => throw _privateConstructorUsedError;
  int get allTimeRank => throw _privateConstructorUsedError;

  /// Serializes this UserContributionStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserContributionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserContributionStatsCopyWith<UserContributionStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserContributionStatsCopyWith<$Res> {
  factory $UserContributionStatsCopyWith(
    UserContributionStats value,
    $Res Function(UserContributionStats) then,
  ) = _$UserContributionStatsCopyWithImpl<$Res, UserContributionStats>;
  @useResult
  $Res call({
    String userId,
    int totalContributions,
    int approvedContributions,
    int rejectedContributions,
    int pendingContributions,
    int totalVotes,
    int totalPoints,
    int currentStreak,
    int longestStreak,
    String level,
    List<ContributorBadge> badges,
    DateTime? lastContributionDate,
    Map<String, int> contributionsByType,
    double approvalRate,
    int weeklyRank,
    int monthlyRank,
    int allTimeRank,
  });
}

/// @nodoc
class _$UserContributionStatsCopyWithImpl<
  $Res,
  $Val extends UserContributionStats
>
    implements $UserContributionStatsCopyWith<$Res> {
  _$UserContributionStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserContributionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalContributions = null,
    Object? approvedContributions = null,
    Object? rejectedContributions = null,
    Object? pendingContributions = null,
    Object? totalVotes = null,
    Object? totalPoints = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? level = null,
    Object? badges = null,
    Object? lastContributionDate = freezed,
    Object? contributionsByType = null,
    Object? approvalRate = null,
    Object? weeklyRank = null,
    Object? monthlyRank = null,
    Object? allTimeRank = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalContributions: null == totalContributions
                ? _value.totalContributions
                : totalContributions // ignore: cast_nullable_to_non_nullable
                      as int,
            approvedContributions: null == approvedContributions
                ? _value.approvedContributions
                : approvedContributions // ignore: cast_nullable_to_non_nullable
                      as int,
            rejectedContributions: null == rejectedContributions
                ? _value.rejectedContributions
                : rejectedContributions // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingContributions: null == pendingContributions
                ? _value.pendingContributions
                : pendingContributions // ignore: cast_nullable_to_non_nullable
                      as int,
            totalVotes: null == totalVotes
                ? _value.totalVotes
                : totalVotes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPoints: null == totalPoints
                ? _value.totalPoints
                : totalPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            badges: null == badges
                ? _value.badges
                : badges // ignore: cast_nullable_to_non_nullable
                      as List<ContributorBadge>,
            lastContributionDate: freezed == lastContributionDate
                ? _value.lastContributionDate
                : lastContributionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            contributionsByType: null == contributionsByType
                ? _value.contributionsByType
                : contributionsByType // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            approvalRate: null == approvalRate
                ? _value.approvalRate
                : approvalRate // ignore: cast_nullable_to_non_nullable
                      as double,
            weeklyRank: null == weeklyRank
                ? _value.weeklyRank
                : weeklyRank // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyRank: null == monthlyRank
                ? _value.monthlyRank
                : monthlyRank // ignore: cast_nullable_to_non_nullable
                      as int,
            allTimeRank: null == allTimeRank
                ? _value.allTimeRank
                : allTimeRank // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserContributionStatsImplCopyWith<$Res>
    implements $UserContributionStatsCopyWith<$Res> {
  factory _$$UserContributionStatsImplCopyWith(
    _$UserContributionStatsImpl value,
    $Res Function(_$UserContributionStatsImpl) then,
  ) = __$$UserContributionStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int totalContributions,
    int approvedContributions,
    int rejectedContributions,
    int pendingContributions,
    int totalVotes,
    int totalPoints,
    int currentStreak,
    int longestStreak,
    String level,
    List<ContributorBadge> badges,
    DateTime? lastContributionDate,
    Map<String, int> contributionsByType,
    double approvalRate,
    int weeklyRank,
    int monthlyRank,
    int allTimeRank,
  });
}

/// @nodoc
class __$$UserContributionStatsImplCopyWithImpl<$Res>
    extends
        _$UserContributionStatsCopyWithImpl<$Res, _$UserContributionStatsImpl>
    implements _$$UserContributionStatsImplCopyWith<$Res> {
  __$$UserContributionStatsImplCopyWithImpl(
    _$UserContributionStatsImpl _value,
    $Res Function(_$UserContributionStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserContributionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalContributions = null,
    Object? approvedContributions = null,
    Object? rejectedContributions = null,
    Object? pendingContributions = null,
    Object? totalVotes = null,
    Object? totalPoints = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? level = null,
    Object? badges = null,
    Object? lastContributionDate = freezed,
    Object? contributionsByType = null,
    Object? approvalRate = null,
    Object? weeklyRank = null,
    Object? monthlyRank = null,
    Object? allTimeRank = null,
  }) {
    return _then(
      _$UserContributionStatsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalContributions: null == totalContributions
            ? _value.totalContributions
            : totalContributions // ignore: cast_nullable_to_non_nullable
                  as int,
        approvedContributions: null == approvedContributions
            ? _value.approvedContributions
            : approvedContributions // ignore: cast_nullable_to_non_nullable
                  as int,
        rejectedContributions: null == rejectedContributions
            ? _value.rejectedContributions
            : rejectedContributions // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingContributions: null == pendingContributions
            ? _value.pendingContributions
            : pendingContributions // ignore: cast_nullable_to_non_nullable
                  as int,
        totalVotes: null == totalVotes
            ? _value.totalVotes
            : totalVotes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPoints: null == totalPoints
            ? _value.totalPoints
            : totalPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        badges: null == badges
            ? _value._badges
            : badges // ignore: cast_nullable_to_non_nullable
                  as List<ContributorBadge>,
        lastContributionDate: freezed == lastContributionDate
            ? _value.lastContributionDate
            : lastContributionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        contributionsByType: null == contributionsByType
            ? _value._contributionsByType
            : contributionsByType // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        approvalRate: null == approvalRate
            ? _value.approvalRate
            : approvalRate // ignore: cast_nullable_to_non_nullable
                  as double,
        weeklyRank: null == weeklyRank
            ? _value.weeklyRank
            : weeklyRank // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyRank: null == monthlyRank
            ? _value.monthlyRank
            : monthlyRank // ignore: cast_nullable_to_non_nullable
                  as int,
        allTimeRank: null == allTimeRank
            ? _value.allTimeRank
            : allTimeRank // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserContributionStatsImpl implements _UserContributionStats {
  const _$UserContributionStatsImpl({
    required this.userId,
    this.totalContributions = 0,
    this.approvedContributions = 0,
    this.rejectedContributions = 0,
    this.pendingContributions = 0,
    this.totalVotes = 0,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.level = 'Rookie',
    final List<ContributorBadge> badges = const [],
    this.lastContributionDate,
    final Map<String, int> contributionsByType = const {},
    this.approvalRate = 0.0,
    this.weeklyRank = 0,
    this.monthlyRank = 0,
    this.allTimeRank = 0,
  }) : _badges = badges,
       _contributionsByType = contributionsByType;

  factory _$UserContributionStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserContributionStatsImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int totalContributions;
  @override
  @JsonKey()
  final int approvedContributions;
  @override
  @JsonKey()
  final int rejectedContributions;
  @override
  @JsonKey()
  final int pendingContributions;
  @override
  @JsonKey()
  final int totalVotes;
  @override
  @JsonKey()
  final int totalPoints;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @JsonKey()
  final String level;
  final List<ContributorBadge> _badges;
  @override
  @JsonKey()
  List<ContributorBadge> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  @override
  final DateTime? lastContributionDate;
  final Map<String, int> _contributionsByType;
  @override
  @JsonKey()
  Map<String, int> get contributionsByType {
    if (_contributionsByType is EqualUnmodifiableMapView)
      return _contributionsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_contributionsByType);
  }

  @override
  @JsonKey()
  final double approvalRate;
  @override
  @JsonKey()
  final int weeklyRank;
  @override
  @JsonKey()
  final int monthlyRank;
  @override
  @JsonKey()
  final int allTimeRank;

  @override
  String toString() {
    return 'UserContributionStats(userId: $userId, totalContributions: $totalContributions, approvedContributions: $approvedContributions, rejectedContributions: $rejectedContributions, pendingContributions: $pendingContributions, totalVotes: $totalVotes, totalPoints: $totalPoints, currentStreak: $currentStreak, longestStreak: $longestStreak, level: $level, badges: $badges, lastContributionDate: $lastContributionDate, contributionsByType: $contributionsByType, approvalRate: $approvalRate, weeklyRank: $weeklyRank, monthlyRank: $monthlyRank, allTimeRank: $allTimeRank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserContributionStatsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalContributions, totalContributions) ||
                other.totalContributions == totalContributions) &&
            (identical(other.approvedContributions, approvedContributions) ||
                other.approvedContributions == approvedContributions) &&
            (identical(other.rejectedContributions, rejectedContributions) ||
                other.rejectedContributions == rejectedContributions) &&
            (identical(other.pendingContributions, pendingContributions) ||
                other.pendingContributions == pendingContributions) &&
            (identical(other.totalVotes, totalVotes) ||
                other.totalVotes == totalVotes) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.lastContributionDate, lastContributionDate) ||
                other.lastContributionDate == lastContributionDate) &&
            const DeepCollectionEquality().equals(
              other._contributionsByType,
              _contributionsByType,
            ) &&
            (identical(other.approvalRate, approvalRate) ||
                other.approvalRate == approvalRate) &&
            (identical(other.weeklyRank, weeklyRank) ||
                other.weeklyRank == weeklyRank) &&
            (identical(other.monthlyRank, monthlyRank) ||
                other.monthlyRank == monthlyRank) &&
            (identical(other.allTimeRank, allTimeRank) ||
                other.allTimeRank == allTimeRank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    totalContributions,
    approvedContributions,
    rejectedContributions,
    pendingContributions,
    totalVotes,
    totalPoints,
    currentStreak,
    longestStreak,
    level,
    const DeepCollectionEquality().hash(_badges),
    lastContributionDate,
    const DeepCollectionEquality().hash(_contributionsByType),
    approvalRate,
    weeklyRank,
    monthlyRank,
    allTimeRank,
  );

  /// Create a copy of UserContributionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserContributionStatsImplCopyWith<_$UserContributionStatsImpl>
  get copyWith =>
      __$$UserContributionStatsImplCopyWithImpl<_$UserContributionStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserContributionStatsImplToJson(this);
  }
}

abstract class _UserContributionStats implements UserContributionStats {
  const factory _UserContributionStats({
    required final String userId,
    final int totalContributions,
    final int approvedContributions,
    final int rejectedContributions,
    final int pendingContributions,
    final int totalVotes,
    final int totalPoints,
    final int currentStreak,
    final int longestStreak,
    final String level,
    final List<ContributorBadge> badges,
    final DateTime? lastContributionDate,
    final Map<String, int> contributionsByType,
    final double approvalRate,
    final int weeklyRank,
    final int monthlyRank,
    final int allTimeRank,
  }) = _$UserContributionStatsImpl;

  factory _UserContributionStats.fromJson(Map<String, dynamic> json) =
      _$UserContributionStatsImpl.fromJson;

  @override
  String get userId;
  @override
  int get totalContributions;
  @override
  int get approvedContributions;
  @override
  int get rejectedContributions;
  @override
  int get pendingContributions;
  @override
  int get totalVotes;
  @override
  int get totalPoints;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  String get level;
  @override
  List<ContributorBadge> get badges;
  @override
  DateTime? get lastContributionDate;
  @override
  Map<String, int> get contributionsByType;
  @override
  double get approvalRate;
  @override
  int get weeklyRank;
  @override
  int get monthlyRank;
  @override
  int get allTimeRank;

  /// Create a copy of UserContributionStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserContributionStatsImplCopyWith<_$UserContributionStatsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ContributorBadge _$ContributorBadgeFromJson(Map<String, dynamic> json) {
  return _ContributorBadge.fromJson(json);
}

/// @nodoc
mixin _$ContributorBadge {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  DateTime get earnedAt => throw _privateConstructorUsedError;
  bool get isRare => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  /// Serializes this ContributorBadge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContributorBadge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContributorBadgeCopyWith<ContributorBadge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContributorBadgeCopyWith<$Res> {
  factory $ContributorBadgeCopyWith(
    ContributorBadge value,
    $Res Function(ContributorBadge) then,
  ) = _$ContributorBadgeCopyWithImpl<$Res, ContributorBadge>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String icon,
    DateTime earnedAt,
    bool isRare,
    String? category,
  });
}

/// @nodoc
class _$ContributorBadgeCopyWithImpl<$Res, $Val extends ContributorBadge>
    implements $ContributorBadgeCopyWith<$Res> {
  _$ContributorBadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContributorBadge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? icon = null,
    Object? earnedAt = null,
    Object? isRare = null,
    Object? category = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            earnedAt: null == earnedAt
                ? _value.earnedAt
                : earnedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRare: null == isRare
                ? _value.isRare
                : isRare // ignore: cast_nullable_to_non_nullable
                      as bool,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContributorBadgeImplCopyWith<$Res>
    implements $ContributorBadgeCopyWith<$Res> {
  factory _$$ContributorBadgeImplCopyWith(
    _$ContributorBadgeImpl value,
    $Res Function(_$ContributorBadgeImpl) then,
  ) = __$$ContributorBadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String icon,
    DateTime earnedAt,
    bool isRare,
    String? category,
  });
}

/// @nodoc
class __$$ContributorBadgeImplCopyWithImpl<$Res>
    extends _$ContributorBadgeCopyWithImpl<$Res, _$ContributorBadgeImpl>
    implements _$$ContributorBadgeImplCopyWith<$Res> {
  __$$ContributorBadgeImplCopyWithImpl(
    _$ContributorBadgeImpl _value,
    $Res Function(_$ContributorBadgeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContributorBadge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? icon = null,
    Object? earnedAt = null,
    Object? isRare = null,
    Object? category = freezed,
  }) {
    return _then(
      _$ContributorBadgeImpl(
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
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        earnedAt: null == earnedAt
            ? _value.earnedAt
            : earnedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRare: null == isRare
            ? _value.isRare
            : isRare // ignore: cast_nullable_to_non_nullable
                  as bool,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContributorBadgeImpl implements _ContributorBadge {
  const _$ContributorBadgeImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedAt,
    this.isRare = false,
    this.category,
  });

  factory _$ContributorBadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContributorBadgeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String icon;
  @override
  final DateTime earnedAt;
  @override
  @JsonKey()
  final bool isRare;
  @override
  final String? category;

  @override
  String toString() {
    return 'ContributorBadge(id: $id, name: $name, description: $description, icon: $icon, earnedAt: $earnedAt, isRare: $isRare, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContributorBadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt) &&
            (identical(other.isRare, isRare) || other.isRare == isRare) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    icon,
    earnedAt,
    isRare,
    category,
  );

  /// Create a copy of ContributorBadge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContributorBadgeImplCopyWith<_$ContributorBadgeImpl> get copyWith =>
      __$$ContributorBadgeImplCopyWithImpl<_$ContributorBadgeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContributorBadgeImplToJson(this);
  }
}

abstract class _ContributorBadge implements ContributorBadge {
  const factory _ContributorBadge({
    required final String id,
    required final String name,
    required final String description,
    required final String icon,
    required final DateTime earnedAt,
    final bool isRare,
    final String? category,
  }) = _$ContributorBadgeImpl;

  factory _ContributorBadge.fromJson(Map<String, dynamic> json) =
      _$ContributorBadgeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get icon;
  @override
  DateTime get earnedAt;
  @override
  bool get isRare;
  @override
  String? get category;

  /// Create a copy of ContributorBadge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContributorBadgeImplCopyWith<_$ContributorBadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
