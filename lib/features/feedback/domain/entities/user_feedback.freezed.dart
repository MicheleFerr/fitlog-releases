// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserFeedback _$UserFeedbackFromJson(Map<String, dynamic> json) {
  return _UserFeedback.fromJson(json);
}

/// @nodoc
mixin _$UserFeedback {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  FeedbackCategory get category => throw _privateConstructorUsedError;
  FeedbackStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int? get rating => throw _privateConstructorUsedError; // 1-5 stars (optional)
  String? get userEmail => throw _privateConstructorUsedError;
  String? get userDisplayName => throw _privateConstructorUsedError;
  String? get deviceInfo => throw _privateConstructorUsedError;
  String? get appVersion => throw _privateConstructorUsedError;
  String? get screenshotUrl =>
      throw _privateConstructorUsedError; // Firebase Storage URL (future)
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError; // Admin user ID
  String? get adminNotes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserFeedbackCopyWith<UserFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFeedbackCopyWith<$Res> {
  factory $UserFeedbackCopyWith(
          UserFeedback value, $Res Function(UserFeedback) then) =
      _$UserFeedbackCopyWithImpl<$Res, UserFeedback>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String message,
      FeedbackCategory category,
      FeedbackStatus status,
      DateTime createdAt,
      int? rating,
      String? userEmail,
      String? userDisplayName,
      String? deviceInfo,
      String? appVersion,
      String? screenshotUrl,
      DateTime? reviewedAt,
      String? reviewedBy,
      String? adminNotes});
}

/// @nodoc
class _$UserFeedbackCopyWithImpl<$Res, $Val extends UserFeedback>
    implements $UserFeedbackCopyWith<$Res> {
  _$UserFeedbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? message = null,
    Object? category = null,
    Object? status = null,
    Object? createdAt = null,
    Object? rating = freezed,
    Object? userEmail = freezed,
    Object? userDisplayName = freezed,
    Object? deviceInfo = freezed,
    Object? appVersion = freezed,
    Object? screenshotUrl = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? adminNotes = freezed,
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
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FeedbackCategory,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeedbackStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userDisplayName: freezed == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserFeedbackImplCopyWith<$Res>
    implements $UserFeedbackCopyWith<$Res> {
  factory _$$UserFeedbackImplCopyWith(
          _$UserFeedbackImpl value, $Res Function(_$UserFeedbackImpl) then) =
      __$$UserFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String message,
      FeedbackCategory category,
      FeedbackStatus status,
      DateTime createdAt,
      int? rating,
      String? userEmail,
      String? userDisplayName,
      String? deviceInfo,
      String? appVersion,
      String? screenshotUrl,
      DateTime? reviewedAt,
      String? reviewedBy,
      String? adminNotes});
}

/// @nodoc
class __$$UserFeedbackImplCopyWithImpl<$Res>
    extends _$UserFeedbackCopyWithImpl<$Res, _$UserFeedbackImpl>
    implements _$$UserFeedbackImplCopyWith<$Res> {
  __$$UserFeedbackImplCopyWithImpl(
      _$UserFeedbackImpl _value, $Res Function(_$UserFeedbackImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? message = null,
    Object? category = null,
    Object? status = null,
    Object? createdAt = null,
    Object? rating = freezed,
    Object? userEmail = freezed,
    Object? userDisplayName = freezed,
    Object? deviceInfo = freezed,
    Object? appVersion = freezed,
    Object? screenshotUrl = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? adminNotes = freezed,
  }) {
    return _then(_$UserFeedbackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FeedbackCategory,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FeedbackStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userDisplayName: freezed == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserFeedbackImpl implements _UserFeedback {
  const _$UserFeedbackImpl(
      {required this.id,
      required this.userId,
      required this.message,
      required this.category,
      required this.status,
      required this.createdAt,
      this.rating,
      this.userEmail,
      this.userDisplayName,
      this.deviceInfo,
      this.appVersion,
      this.screenshotUrl,
      this.reviewedAt,
      this.reviewedBy,
      this.adminNotes});

  factory _$UserFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserFeedbackImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String message;
  @override
  final FeedbackCategory category;
  @override
  final FeedbackStatus status;
  @override
  final DateTime createdAt;
  @override
  final int? rating;
// 1-5 stars (optional)
  @override
  final String? userEmail;
  @override
  final String? userDisplayName;
  @override
  final String? deviceInfo;
  @override
  final String? appVersion;
  @override
  final String? screenshotUrl;
// Firebase Storage URL (future)
  @override
  final DateTime? reviewedAt;
  @override
  final String? reviewedBy;
// Admin user ID
  @override
  final String? adminNotes;

  @override
  String toString() {
    return 'UserFeedback(id: $id, userId: $userId, message: $message, category: $category, status: $status, createdAt: $createdAt, rating: $rating, userEmail: $userEmail, userDisplayName: $userDisplayName, deviceInfo: $deviceInfo, appVersion: $appVersion, screenshotUrl: $screenshotUrl, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, adminNotes: $adminNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFeedbackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName) &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.screenshotUrl, screenshotUrl) ||
                other.screenshotUrl == screenshotUrl) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      message,
      category,
      status,
      createdAt,
      rating,
      userEmail,
      userDisplayName,
      deviceInfo,
      appVersion,
      screenshotUrl,
      reviewedAt,
      reviewedBy,
      adminNotes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFeedbackImplCopyWith<_$UserFeedbackImpl> get copyWith =>
      __$$UserFeedbackImplCopyWithImpl<_$UserFeedbackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserFeedbackImplToJson(
      this,
    );
  }
}

abstract class _UserFeedback implements UserFeedback {
  const factory _UserFeedback(
      {required final String id,
      required final String userId,
      required final String message,
      required final FeedbackCategory category,
      required final FeedbackStatus status,
      required final DateTime createdAt,
      final int? rating,
      final String? userEmail,
      final String? userDisplayName,
      final String? deviceInfo,
      final String? appVersion,
      final String? screenshotUrl,
      final DateTime? reviewedAt,
      final String? reviewedBy,
      final String? adminNotes}) = _$UserFeedbackImpl;

  factory _UserFeedback.fromJson(Map<String, dynamic> json) =
      _$UserFeedbackImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get message;
  @override
  FeedbackCategory get category;
  @override
  FeedbackStatus get status;
  @override
  DateTime get createdAt;
  @override
  int? get rating;
  @override // 1-5 stars (optional)
  String? get userEmail;
  @override
  String? get userDisplayName;
  @override
  String? get deviceInfo;
  @override
  String? get appVersion;
  @override
  String? get screenshotUrl;
  @override // Firebase Storage URL (future)
  DateTime? get reviewedAt;
  @override
  String? get reviewedBy;
  @override // Admin user ID
  String? get adminNotes;
  @override
  @JsonKey(ignore: true)
  _$$UserFeedbackImplCopyWith<_$UserFeedbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
