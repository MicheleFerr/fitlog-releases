// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unified_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UnifiedFeedback _$UnifiedFeedbackFromJson(Map<String, dynamic> json) {
  return _UnifiedFeedback.fromJson(json);
}

/// @nodoc
mixin _$UnifiedFeedback {
  /// Unique feedback ID (Firestore document ID)
  String get id => throw _privateConstructorUsedError;

  /// User who submitted feedback (Firebase Auth UID)
  String get userId => throw _privateConstructorUsedError;

  /// Type of feedback (discriminator)
  UnifiedFeedbackType get type => throw _privateConstructorUsedError;

  /// Current status in review workflow
  UnifiedFeedbackStatus get status => throw _privateConstructorUsedError;

  /// Severity level (for prioritization)
  FeedbackSeverity get severity => throw _privateConstructorUsedError;

  /// Main feedback message/description
  String get message => throw _privateConstructorUsedError;

  /// When feedback was submitted
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp (status change, admin note, etc.)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// When feedback was marked resolved/dismissed (if applicable)
  DateTime? get resolvedAt =>
      throw _privateConstructorUsedError; // ========================================
// ADMIN REVIEW FIELDS
// ========================================
  /// Admin user ID who reviewed this feedback
  String? get reviewedBy => throw _privateConstructorUsedError;

  /// Admin notes/comments (visible to user if status is resolved)
  String? get adminNotes =>
      throw _privateConstructorUsedError; // ========================================
// TYPE-SPECIFIC METADATA
// ========================================
  /// Type-specific data stored as Map
  ///
  /// **Exercise Feedback**:
  /// - exerciseId: String
  /// - exerciseName: String
  /// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
  /// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
  ///
  /// **AI Insight Feedback**:
  /// - insightId: String
  /// - insightType: String (e.g., "overtraining", "progression")
  /// - insightCategory: String (e.g., "recovery", "performance")
  /// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
  /// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
  /// - viewDurationSeconds: int (time insight was visible before feedback)
  ///
  /// **Analytics Feedback**:
  /// - isHelpful: bool (true = 👍, false = 👎)
  /// - lastViewedSection: String? (overview/progress/insights/routine)
  /// - totalWorkoutsViewed: int? (user engagement metric)
  ///
  /// **Buddy Report**:
  /// - targetUserId: String (reported user ID)
  /// - targetUserName: String (reported user display name)
  /// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
  ///
  /// **General Feedback**:
  /// - category: String (bug/feature/improvement/praise/other)
  /// - rating: int? (1-5 stars, optional)
  /// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
  /// - appVersion: String? (e.g., "1.2.3")
  /// - screenshotUrl: String? (Firebase Storage URL, future)
  Map<String, dynamic> get metadata =>
      throw _privateConstructorUsedError; // ========================================
// USER INFO (OPTIONAL - FOR ADMIN)
// ========================================
  /// User email (for admin contact)
  String? get userEmail => throw _privateConstructorUsedError;

  /// User display name (for admin reference)
  String? get userDisplayName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UnifiedFeedbackCopyWith<UnifiedFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedFeedbackCopyWith<$Res> {
  factory $UnifiedFeedbackCopyWith(
          UnifiedFeedback value, $Res Function(UnifiedFeedback) then) =
      _$UnifiedFeedbackCopyWithImpl<$Res, UnifiedFeedback>;
  @useResult
  $Res call(
      {String id,
      String userId,
      UnifiedFeedbackType type,
      UnifiedFeedbackStatus status,
      FeedbackSeverity severity,
      String message,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? resolvedAt,
      String? reviewedBy,
      String? adminNotes,
      Map<String, dynamic> metadata,
      String? userEmail,
      String? userDisplayName});
}

/// @nodoc
class _$UnifiedFeedbackCopyWithImpl<$Res, $Val extends UnifiedFeedback>
    implements $UnifiedFeedbackCopyWith<$Res> {
  _$UnifiedFeedbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
    Object? severity = null,
    Object? message = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? resolvedAt = freezed,
    Object? reviewedBy = freezed,
    Object? adminNotes = freezed,
    Object? metadata = null,
    Object? userEmail = freezed,
    Object? userDisplayName = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UnifiedFeedbackType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UnifiedFeedbackStatus,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as FeedbackSeverity,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userDisplayName: freezed == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnifiedFeedbackImplCopyWith<$Res>
    implements $UnifiedFeedbackCopyWith<$Res> {
  factory _$$UnifiedFeedbackImplCopyWith(_$UnifiedFeedbackImpl value,
          $Res Function(_$UnifiedFeedbackImpl) then) =
      __$$UnifiedFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      UnifiedFeedbackType type,
      UnifiedFeedbackStatus status,
      FeedbackSeverity severity,
      String message,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? resolvedAt,
      String? reviewedBy,
      String? adminNotes,
      Map<String, dynamic> metadata,
      String? userEmail,
      String? userDisplayName});
}

/// @nodoc
class __$$UnifiedFeedbackImplCopyWithImpl<$Res>
    extends _$UnifiedFeedbackCopyWithImpl<$Res, _$UnifiedFeedbackImpl>
    implements _$$UnifiedFeedbackImplCopyWith<$Res> {
  __$$UnifiedFeedbackImplCopyWithImpl(
      _$UnifiedFeedbackImpl _value, $Res Function(_$UnifiedFeedbackImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? status = null,
    Object? severity = null,
    Object? message = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? resolvedAt = freezed,
    Object? reviewedBy = freezed,
    Object? adminNotes = freezed,
    Object? metadata = null,
    Object? userEmail = freezed,
    Object? userDisplayName = freezed,
  }) {
    return _then(_$UnifiedFeedbackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UnifiedFeedbackType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UnifiedFeedbackStatus,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as FeedbackSeverity,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userDisplayName: freezed == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UnifiedFeedbackImpl implements _UnifiedFeedback {
  const _$UnifiedFeedbackImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.status,
      required this.severity,
      required this.message,
      required this.createdAt,
      this.updatedAt,
      this.resolvedAt,
      this.reviewedBy,
      this.adminNotes,
      final Map<String, dynamic> metadata = const {},
      this.userEmail,
      this.userDisplayName})
      : _metadata = metadata;

  factory _$UnifiedFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnifiedFeedbackImplFromJson(json);

  /// Unique feedback ID (Firestore document ID)
  @override
  final String id;

  /// User who submitted feedback (Firebase Auth UID)
  @override
  final String userId;

  /// Type of feedback (discriminator)
  @override
  final UnifiedFeedbackType type;

  /// Current status in review workflow
  @override
  final UnifiedFeedbackStatus status;

  /// Severity level (for prioritization)
  @override
  final FeedbackSeverity severity;

  /// Main feedback message/description
  @override
  final String message;

  /// When feedback was submitted
  @override
  final DateTime createdAt;

  /// Last update timestamp (status change, admin note, etc.)
  @override
  final DateTime? updatedAt;

  /// When feedback was marked resolved/dismissed (if applicable)
  @override
  final DateTime? resolvedAt;
// ========================================
// ADMIN REVIEW FIELDS
// ========================================
  /// Admin user ID who reviewed this feedback
  @override
  final String? reviewedBy;

  /// Admin notes/comments (visible to user if status is resolved)
  @override
  final String? adminNotes;
// ========================================
// TYPE-SPECIFIC METADATA
// ========================================
  /// Type-specific data stored as Map
  ///
  /// **Exercise Feedback**:
  /// - exerciseId: String
  /// - exerciseName: String
  /// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
  /// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
  ///
  /// **AI Insight Feedback**:
  /// - insightId: String
  /// - insightType: String (e.g., "overtraining", "progression")
  /// - insightCategory: String (e.g., "recovery", "performance")
  /// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
  /// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
  /// - viewDurationSeconds: int (time insight was visible before feedback)
  ///
  /// **Analytics Feedback**:
  /// - isHelpful: bool (true = 👍, false = 👎)
  /// - lastViewedSection: String? (overview/progress/insights/routine)
  /// - totalWorkoutsViewed: int? (user engagement metric)
  ///
  /// **Buddy Report**:
  /// - targetUserId: String (reported user ID)
  /// - targetUserName: String (reported user display name)
  /// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
  ///
  /// **General Feedback**:
  /// - category: String (bug/feature/improvement/praise/other)
  /// - rating: int? (1-5 stars, optional)
  /// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
  /// - appVersion: String? (e.g., "1.2.3")
  /// - screenshotUrl: String? (Firebase Storage URL, future)
  final Map<String, dynamic> _metadata;
// ========================================
// TYPE-SPECIFIC METADATA
// ========================================
  /// Type-specific data stored as Map
  ///
  /// **Exercise Feedback**:
  /// - exerciseId: String
  /// - exerciseName: String
  /// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
  /// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
  ///
  /// **AI Insight Feedback**:
  /// - insightId: String
  /// - insightType: String (e.g., "overtraining", "progression")
  /// - insightCategory: String (e.g., "recovery", "performance")
  /// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
  /// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
  /// - viewDurationSeconds: int (time insight was visible before feedback)
  ///
  /// **Analytics Feedback**:
  /// - isHelpful: bool (true = 👍, false = 👎)
  /// - lastViewedSection: String? (overview/progress/insights/routine)
  /// - totalWorkoutsViewed: int? (user engagement metric)
  ///
  /// **Buddy Report**:
  /// - targetUserId: String (reported user ID)
  /// - targetUserName: String (reported user display name)
  /// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
  ///
  /// **General Feedback**:
  /// - category: String (bug/feature/improvement/praise/other)
  /// - rating: int? (1-5 stars, optional)
  /// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
  /// - appVersion: String? (e.g., "1.2.3")
  /// - screenshotUrl: String? (Firebase Storage URL, future)
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

// ========================================
// USER INFO (OPTIONAL - FOR ADMIN)
// ========================================
  /// User email (for admin contact)
  @override
  final String? userEmail;

  /// User display name (for admin reference)
  @override
  final String? userDisplayName;

  @override
  String toString() {
    return 'UnifiedFeedback(id: $id, userId: $userId, type: $type, status: $status, severity: $severity, message: $message, createdAt: $createdAt, updatedAt: $updatedAt, resolvedAt: $resolvedAt, reviewedBy: $reviewedBy, adminNotes: $adminNotes, metadata: $metadata, userEmail: $userEmail, userDisplayName: $userDisplayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnifiedFeedbackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      type,
      status,
      severity,
      message,
      createdAt,
      updatedAt,
      resolvedAt,
      reviewedBy,
      adminNotes,
      const DeepCollectionEquality().hash(_metadata),
      userEmail,
      userDisplayName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnifiedFeedbackImplCopyWith<_$UnifiedFeedbackImpl> get copyWith =>
      __$$UnifiedFeedbackImplCopyWithImpl<_$UnifiedFeedbackImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnifiedFeedbackImplToJson(
      this,
    );
  }
}

abstract class _UnifiedFeedback implements UnifiedFeedback {
  const factory _UnifiedFeedback(
      {required final String id,
      required final String userId,
      required final UnifiedFeedbackType type,
      required final UnifiedFeedbackStatus status,
      required final FeedbackSeverity severity,
      required final String message,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final DateTime? resolvedAt,
      final String? reviewedBy,
      final String? adminNotes,
      final Map<String, dynamic> metadata,
      final String? userEmail,
      final String? userDisplayName}) = _$UnifiedFeedbackImpl;

  factory _UnifiedFeedback.fromJson(Map<String, dynamic> json) =
      _$UnifiedFeedbackImpl.fromJson;

  @override

  /// Unique feedback ID (Firestore document ID)
  String get id;
  @override

  /// User who submitted feedback (Firebase Auth UID)
  String get userId;
  @override

  /// Type of feedback (discriminator)
  UnifiedFeedbackType get type;
  @override

  /// Current status in review workflow
  UnifiedFeedbackStatus get status;
  @override

  /// Severity level (for prioritization)
  FeedbackSeverity get severity;
  @override

  /// Main feedback message/description
  String get message;
  @override

  /// When feedback was submitted
  DateTime get createdAt;
  @override

  /// Last update timestamp (status change, admin note, etc.)
  DateTime? get updatedAt;
  @override

  /// When feedback was marked resolved/dismissed (if applicable)
  DateTime? get resolvedAt;
  @override // ========================================
// ADMIN REVIEW FIELDS
// ========================================
  /// Admin user ID who reviewed this feedback
  String? get reviewedBy;
  @override

  /// Admin notes/comments (visible to user if status is resolved)
  String? get adminNotes;
  @override // ========================================
// TYPE-SPECIFIC METADATA
// ========================================
  /// Type-specific data stored as Map
  ///
  /// **Exercise Feedback**:
  /// - exerciseId: String
  /// - exerciseName: String
  /// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
  /// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
  ///
  /// **AI Insight Feedback**:
  /// - insightId: String
  /// - insightType: String (e.g., "overtraining", "progression")
  /// - insightCategory: String (e.g., "recovery", "performance")
  /// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
  /// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
  /// - viewDurationSeconds: int (time insight was visible before feedback)
  ///
  /// **Analytics Feedback**:
  /// - isHelpful: bool (true = 👍, false = 👎)
  /// - lastViewedSection: String? (overview/progress/insights/routine)
  /// - totalWorkoutsViewed: int? (user engagement metric)
  ///
  /// **Buddy Report**:
  /// - targetUserId: String (reported user ID)
  /// - targetUserName: String (reported user display name)
  /// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
  ///
  /// **General Feedback**:
  /// - category: String (bug/feature/improvement/praise/other)
  /// - rating: int? (1-5 stars, optional)
  /// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
  /// - appVersion: String? (e.g., "1.2.3")
  /// - screenshotUrl: String? (Firebase Storage URL, future)
  Map<String, dynamic> get metadata;
  @override // ========================================
// USER INFO (OPTIONAL - FOR ADMIN)
// ========================================
  /// User email (for admin contact)
  String? get userEmail;
  @override

  /// User display name (for admin reference)
  String? get userDisplayName;
  @override
  @JsonKey(ignore: true)
  _$$UnifiedFeedbackImplCopyWith<_$UnifiedFeedbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
