// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedbackData _$FeedbackDataFromJson(Map<String, dynamic> json) {
  return _FeedbackData.fromJson(json);
}

/// @nodoc
mixin _$FeedbackData {
  /// Unique feedback ID
  String get id => throw _privateConstructorUsedError;

  /// User ID who provided feedback
  String get userId => throw _privateConstructorUsedError;

  /// Insight ID that received feedback
  String get insightId => throw _privateConstructorUsedError;

  /// Type of insight that received feedback
  String get insightType => throw _privateConstructorUsedError;

  /// Category of insight that received feedback
  String get insightCategory => throw _privateConstructorUsedError;

  /// Type of feedback provided
  FeedbackType get feedbackType => throw _privateConstructorUsedError;

  /// Reason for dismissing (if feedbackType is notHelpful/dismissed)
  DismissReason? get dismissReason => throw _privateConstructorUsedError;

  /// Optional text comment from user
  String? get comment => throw _privateConstructorUsedError;

  /// When feedback was provided
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// How long insight was shown before feedback (in seconds)
  int get viewDurationSeconds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedbackDataCopyWith<FeedbackData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackDataCopyWith<$Res> {
  factory $FeedbackDataCopyWith(
          FeedbackData value, $Res Function(FeedbackData) then) =
      _$FeedbackDataCopyWithImpl<$Res, FeedbackData>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String insightId,
      String insightType,
      String insightCategory,
      FeedbackType feedbackType,
      DismissReason? dismissReason,
      String? comment,
      DateTime timestamp,
      int viewDurationSeconds});
}

/// @nodoc
class _$FeedbackDataCopyWithImpl<$Res, $Val extends FeedbackData>
    implements $FeedbackDataCopyWith<$Res> {
  _$FeedbackDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? insightId = null,
    Object? insightType = null,
    Object? insightCategory = null,
    Object? feedbackType = null,
    Object? dismissReason = freezed,
    Object? comment = freezed,
    Object? timestamp = null,
    Object? viewDurationSeconds = null,
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
      insightId: null == insightId
          ? _value.insightId
          : insightId // ignore: cast_nullable_to_non_nullable
              as String,
      insightType: null == insightType
          ? _value.insightType
          : insightType // ignore: cast_nullable_to_non_nullable
              as String,
      insightCategory: null == insightCategory
          ? _value.insightCategory
          : insightCategory // ignore: cast_nullable_to_non_nullable
              as String,
      feedbackType: null == feedbackType
          ? _value.feedbackType
          : feedbackType // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      dismissReason: freezed == dismissReason
          ? _value.dismissReason
          : dismissReason // ignore: cast_nullable_to_non_nullable
              as DismissReason?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      viewDurationSeconds: null == viewDurationSeconds
          ? _value.viewDurationSeconds
          : viewDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedbackDataImplCopyWith<$Res>
    implements $FeedbackDataCopyWith<$Res> {
  factory _$$FeedbackDataImplCopyWith(
          _$FeedbackDataImpl value, $Res Function(_$FeedbackDataImpl) then) =
      __$$FeedbackDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String insightId,
      String insightType,
      String insightCategory,
      FeedbackType feedbackType,
      DismissReason? dismissReason,
      String? comment,
      DateTime timestamp,
      int viewDurationSeconds});
}

/// @nodoc
class __$$FeedbackDataImplCopyWithImpl<$Res>
    extends _$FeedbackDataCopyWithImpl<$Res, _$FeedbackDataImpl>
    implements _$$FeedbackDataImplCopyWith<$Res> {
  __$$FeedbackDataImplCopyWithImpl(
      _$FeedbackDataImpl _value, $Res Function(_$FeedbackDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? insightId = null,
    Object? insightType = null,
    Object? insightCategory = null,
    Object? feedbackType = null,
    Object? dismissReason = freezed,
    Object? comment = freezed,
    Object? timestamp = null,
    Object? viewDurationSeconds = null,
  }) {
    return _then(_$FeedbackDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      insightId: null == insightId
          ? _value.insightId
          : insightId // ignore: cast_nullable_to_non_nullable
              as String,
      insightType: null == insightType
          ? _value.insightType
          : insightType // ignore: cast_nullable_to_non_nullable
              as String,
      insightCategory: null == insightCategory
          ? _value.insightCategory
          : insightCategory // ignore: cast_nullable_to_non_nullable
              as String,
      feedbackType: null == feedbackType
          ? _value.feedbackType
          : feedbackType // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      dismissReason: freezed == dismissReason
          ? _value.dismissReason
          : dismissReason // ignore: cast_nullable_to_non_nullable
              as DismissReason?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      viewDurationSeconds: null == viewDurationSeconds
          ? _value.viewDurationSeconds
          : viewDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackDataImpl implements _FeedbackData {
  const _$FeedbackDataImpl(
      {required this.id,
      required this.userId,
      required this.insightId,
      required this.insightType,
      required this.insightCategory,
      required this.feedbackType,
      this.dismissReason,
      this.comment,
      required this.timestamp,
      this.viewDurationSeconds = 0});

  factory _$FeedbackDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackDataImplFromJson(json);

  /// Unique feedback ID
  @override
  final String id;

  /// User ID who provided feedback
  @override
  final String userId;

  /// Insight ID that received feedback
  @override
  final String insightId;

  /// Type of insight that received feedback
  @override
  final String insightType;

  /// Category of insight that received feedback
  @override
  final String insightCategory;

  /// Type of feedback provided
  @override
  final FeedbackType feedbackType;

  /// Reason for dismissing (if feedbackType is notHelpful/dismissed)
  @override
  final DismissReason? dismissReason;

  /// Optional text comment from user
  @override
  final String? comment;

  /// When feedback was provided
  @override
  final DateTime timestamp;

  /// How long insight was shown before feedback (in seconds)
  @override
  @JsonKey()
  final int viewDurationSeconds;

  @override
  String toString() {
    return 'FeedbackData(id: $id, userId: $userId, insightId: $insightId, insightType: $insightType, insightCategory: $insightCategory, feedbackType: $feedbackType, dismissReason: $dismissReason, comment: $comment, timestamp: $timestamp, viewDurationSeconds: $viewDurationSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.insightId, insightId) ||
                other.insightId == insightId) &&
            (identical(other.insightType, insightType) ||
                other.insightType == insightType) &&
            (identical(other.insightCategory, insightCategory) ||
                other.insightCategory == insightCategory) &&
            (identical(other.feedbackType, feedbackType) ||
                other.feedbackType == feedbackType) &&
            (identical(other.dismissReason, dismissReason) ||
                other.dismissReason == dismissReason) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.viewDurationSeconds, viewDurationSeconds) ||
                other.viewDurationSeconds == viewDurationSeconds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      insightId,
      insightType,
      insightCategory,
      feedbackType,
      dismissReason,
      comment,
      timestamp,
      viewDurationSeconds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackDataImplCopyWith<_$FeedbackDataImpl> get copyWith =>
      __$$FeedbackDataImplCopyWithImpl<_$FeedbackDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackDataImplToJson(
      this,
    );
  }
}

abstract class _FeedbackData implements FeedbackData {
  const factory _FeedbackData(
      {required final String id,
      required final String userId,
      required final String insightId,
      required final String insightType,
      required final String insightCategory,
      required final FeedbackType feedbackType,
      final DismissReason? dismissReason,
      final String? comment,
      required final DateTime timestamp,
      final int viewDurationSeconds}) = _$FeedbackDataImpl;

  factory _FeedbackData.fromJson(Map<String, dynamic> json) =
      _$FeedbackDataImpl.fromJson;

  @override

  /// Unique feedback ID
  String get id;
  @override

  /// User ID who provided feedback
  String get userId;
  @override

  /// Insight ID that received feedback
  String get insightId;
  @override

  /// Type of insight that received feedback
  String get insightType;
  @override

  /// Category of insight that received feedback
  String get insightCategory;
  @override

  /// Type of feedback provided
  FeedbackType get feedbackType;
  @override

  /// Reason for dismissing (if feedbackType is notHelpful/dismissed)
  DismissReason? get dismissReason;
  @override

  /// Optional text comment from user
  String? get comment;
  @override

  /// When feedback was provided
  DateTime get timestamp;
  @override

  /// How long insight was shown before feedback (in seconds)
  int get viewDurationSeconds;
  @override
  @JsonKey(ignore: true)
  _$$FeedbackDataImplCopyWith<_$FeedbackDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedbackStats _$FeedbackStatsFromJson(Map<String, dynamic> json) {
  return _FeedbackStats.fromJson(json);
}

/// @nodoc
mixin _$FeedbackStats {
  /// Insight type or category
  String get identifier => throw _privateConstructorUsedError;

  /// Total feedback received
  int get totalFeedback => throw _privateConstructorUsedError;

  /// Helpful feedback count
  int get helpfulCount => throw _privateConstructorUsedError;

  /// Not helpful feedback count
  int get notHelpfulCount => throw _privateConstructorUsedError;

  /// Dismissed feedback count
  int get dismissedCount => throw _privateConstructorUsedError;

  /// Acted upon feedback count
  int get actedUponCount => throw _privateConstructorUsedError;

  /// Average view duration in seconds
  double get avgViewDuration => throw _privateConstructorUsedError;

  /// When stats were last updated
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedbackStatsCopyWith<FeedbackStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackStatsCopyWith<$Res> {
  factory $FeedbackStatsCopyWith(
          FeedbackStats value, $Res Function(FeedbackStats) then) =
      _$FeedbackStatsCopyWithImpl<$Res, FeedbackStats>;
  @useResult
  $Res call(
      {String identifier,
      int totalFeedback,
      int helpfulCount,
      int notHelpfulCount,
      int dismissedCount,
      int actedUponCount,
      double avgViewDuration,
      DateTime? lastUpdated});
}

/// @nodoc
class _$FeedbackStatsCopyWithImpl<$Res, $Val extends FeedbackStats>
    implements $FeedbackStatsCopyWith<$Res> {
  _$FeedbackStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? totalFeedback = null,
    Object? helpfulCount = null,
    Object? notHelpfulCount = null,
    Object? dismissedCount = null,
    Object? actedUponCount = null,
    Object? avgViewDuration = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      totalFeedback: null == totalFeedback
          ? _value.totalFeedback
          : totalFeedback // ignore: cast_nullable_to_non_nullable
              as int,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      notHelpfulCount: null == notHelpfulCount
          ? _value.notHelpfulCount
          : notHelpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      dismissedCount: null == dismissedCount
          ? _value.dismissedCount
          : dismissedCount // ignore: cast_nullable_to_non_nullable
              as int,
      actedUponCount: null == actedUponCount
          ? _value.actedUponCount
          : actedUponCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgViewDuration: null == avgViewDuration
          ? _value.avgViewDuration
          : avgViewDuration // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedbackStatsImplCopyWith<$Res>
    implements $FeedbackStatsCopyWith<$Res> {
  factory _$$FeedbackStatsImplCopyWith(
          _$FeedbackStatsImpl value, $Res Function(_$FeedbackStatsImpl) then) =
      __$$FeedbackStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String identifier,
      int totalFeedback,
      int helpfulCount,
      int notHelpfulCount,
      int dismissedCount,
      int actedUponCount,
      double avgViewDuration,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$FeedbackStatsImplCopyWithImpl<$Res>
    extends _$FeedbackStatsCopyWithImpl<$Res, _$FeedbackStatsImpl>
    implements _$$FeedbackStatsImplCopyWith<$Res> {
  __$$FeedbackStatsImplCopyWithImpl(
      _$FeedbackStatsImpl _value, $Res Function(_$FeedbackStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? totalFeedback = null,
    Object? helpfulCount = null,
    Object? notHelpfulCount = null,
    Object? dismissedCount = null,
    Object? actedUponCount = null,
    Object? avgViewDuration = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$FeedbackStatsImpl(
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      totalFeedback: null == totalFeedback
          ? _value.totalFeedback
          : totalFeedback // ignore: cast_nullable_to_non_nullable
              as int,
      helpfulCount: null == helpfulCount
          ? _value.helpfulCount
          : helpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      notHelpfulCount: null == notHelpfulCount
          ? _value.notHelpfulCount
          : notHelpfulCount // ignore: cast_nullable_to_non_nullable
              as int,
      dismissedCount: null == dismissedCount
          ? _value.dismissedCount
          : dismissedCount // ignore: cast_nullable_to_non_nullable
              as int,
      actedUponCount: null == actedUponCount
          ? _value.actedUponCount
          : actedUponCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgViewDuration: null == avgViewDuration
          ? _value.avgViewDuration
          : avgViewDuration // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackStatsImpl implements _FeedbackStats {
  const _$FeedbackStatsImpl(
      {required this.identifier,
      this.totalFeedback = 0,
      this.helpfulCount = 0,
      this.notHelpfulCount = 0,
      this.dismissedCount = 0,
      this.actedUponCount = 0,
      this.avgViewDuration = 0.0,
      this.lastUpdated});

  factory _$FeedbackStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackStatsImplFromJson(json);

  /// Insight type or category
  @override
  final String identifier;

  /// Total feedback received
  @override
  @JsonKey()
  final int totalFeedback;

  /// Helpful feedback count
  @override
  @JsonKey()
  final int helpfulCount;

  /// Not helpful feedback count
  @override
  @JsonKey()
  final int notHelpfulCount;

  /// Dismissed feedback count
  @override
  @JsonKey()
  final int dismissedCount;

  /// Acted upon feedback count
  @override
  @JsonKey()
  final int actedUponCount;

  /// Average view duration in seconds
  @override
  @JsonKey()
  final double avgViewDuration;

  /// When stats were last updated
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'FeedbackStats(identifier: $identifier, totalFeedback: $totalFeedback, helpfulCount: $helpfulCount, notHelpfulCount: $notHelpfulCount, dismissedCount: $dismissedCount, actedUponCount: $actedUponCount, avgViewDuration: $avgViewDuration, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackStatsImpl &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier) &&
            (identical(other.totalFeedback, totalFeedback) ||
                other.totalFeedback == totalFeedback) &&
            (identical(other.helpfulCount, helpfulCount) ||
                other.helpfulCount == helpfulCount) &&
            (identical(other.notHelpfulCount, notHelpfulCount) ||
                other.notHelpfulCount == notHelpfulCount) &&
            (identical(other.dismissedCount, dismissedCount) ||
                other.dismissedCount == dismissedCount) &&
            (identical(other.actedUponCount, actedUponCount) ||
                other.actedUponCount == actedUponCount) &&
            (identical(other.avgViewDuration, avgViewDuration) ||
                other.avgViewDuration == avgViewDuration) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      identifier,
      totalFeedback,
      helpfulCount,
      notHelpfulCount,
      dismissedCount,
      actedUponCount,
      avgViewDuration,
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackStatsImplCopyWith<_$FeedbackStatsImpl> get copyWith =>
      __$$FeedbackStatsImplCopyWithImpl<_$FeedbackStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackStatsImplToJson(
      this,
    );
  }
}

abstract class _FeedbackStats implements FeedbackStats {
  const factory _FeedbackStats(
      {required final String identifier,
      final int totalFeedback,
      final int helpfulCount,
      final int notHelpfulCount,
      final int dismissedCount,
      final int actedUponCount,
      final double avgViewDuration,
      final DateTime? lastUpdated}) = _$FeedbackStatsImpl;

  factory _FeedbackStats.fromJson(Map<String, dynamic> json) =
      _$FeedbackStatsImpl.fromJson;

  @override

  /// Insight type or category
  String get identifier;
  @override

  /// Total feedback received
  int get totalFeedback;
  @override

  /// Helpful feedback count
  int get helpfulCount;
  @override

  /// Not helpful feedback count
  int get notHelpfulCount;
  @override

  /// Dismissed feedback count
  int get dismissedCount;
  @override

  /// Acted upon feedback count
  int get actedUponCount;
  @override

  /// Average view duration in seconds
  double get avgViewDuration;
  @override

  /// When stats were last updated
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$FeedbackStatsImplCopyWith<_$FeedbackStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
