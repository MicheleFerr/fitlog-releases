// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Insight _$InsightFromJson(Map<String, dynamic> json) {
  return _Insight.fromJson(json);
}

/// @nodoc
mixin _$Insight {
  /// Unique insight identifier
  String get id => throw _privateConstructorUsedError;

  /// User this insight belongs to
  String get userId => throw _privateConstructorUsedError;

  /// Type of insight
  InsightType get type => throw _privateConstructorUsedError;

  /// Priority level
  InsightPriority get priority => throw _privateConstructorUsedError;

  /// Insight title (localized)
  String get title => throw _privateConstructorUsedError;

  /// Insight message/description (localized)
  String get message => throw _privateConstructorUsedError;

  /// Recommended action (localized)
  String get recommendation => throw _privateConstructorUsedError;

  /// When the insight was generated
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Additional metadata (exercise names, metrics, etc.)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// User's engagement with this insight (if any)
  InsightEngagement? get engagement => throw _privateConstructorUsedError;

  /// Specific action the user took (e.g., "started_workout", "adjusted_volume")
  String? get actionTaken => throw _privateConstructorUsedError;

  /// When the user dismissed the insight
  DateTime? get dismissedAt => throw _privateConstructorUsedError;

  /// When the user first viewed the insight
  DateTime? get viewedAt => throw _privateConstructorUsedError;

  /// When action was taken (if applicable)
  DateTime? get actionTakenAt => throw _privateConstructorUsedError;

  /// Serializes this Insight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Insight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InsightCopyWith<Insight> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsightCopyWith<$Res> {
  factory $InsightCopyWith(Insight value, $Res Function(Insight) then) =
      _$InsightCopyWithImpl<$Res, Insight>;
  @useResult
  $Res call({
    String id,
    String userId,
    InsightType type,
    InsightPriority priority,
    String title,
    String message,
    String recommendation,
    DateTime generatedAt,
    Map<String, dynamic> metadata,
    InsightEngagement? engagement,
    String? actionTaken,
    DateTime? dismissedAt,
    DateTime? viewedAt,
    DateTime? actionTakenAt,
  });
}

/// @nodoc
class _$InsightCopyWithImpl<$Res, $Val extends Insight>
    implements $InsightCopyWith<$Res> {
  _$InsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Insight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? priority = null,
    Object? title = null,
    Object? message = null,
    Object? recommendation = null,
    Object? generatedAt = null,
    Object? metadata = null,
    Object? engagement = freezed,
    Object? actionTaken = freezed,
    Object? dismissedAt = freezed,
    Object? viewedAt = freezed,
    Object? actionTakenAt = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as InsightType,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as InsightPriority,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendation: null == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as String,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            engagement: freezed == engagement
                ? _value.engagement
                : engagement // ignore: cast_nullable_to_non_nullable
                      as InsightEngagement?,
            actionTaken: freezed == actionTaken
                ? _value.actionTaken
                : actionTaken // ignore: cast_nullable_to_non_nullable
                      as String?,
            dismissedAt: freezed == dismissedAt
                ? _value.dismissedAt
                : dismissedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            viewedAt: freezed == viewedAt
                ? _value.viewedAt
                : viewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actionTakenAt: freezed == actionTakenAt
                ? _value.actionTakenAt
                : actionTakenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InsightImplCopyWith<$Res> implements $InsightCopyWith<$Res> {
  factory _$$InsightImplCopyWith(
    _$InsightImpl value,
    $Res Function(_$InsightImpl) then,
  ) = __$$InsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    InsightType type,
    InsightPriority priority,
    String title,
    String message,
    String recommendation,
    DateTime generatedAt,
    Map<String, dynamic> metadata,
    InsightEngagement? engagement,
    String? actionTaken,
    DateTime? dismissedAt,
    DateTime? viewedAt,
    DateTime? actionTakenAt,
  });
}

/// @nodoc
class __$$InsightImplCopyWithImpl<$Res>
    extends _$InsightCopyWithImpl<$Res, _$InsightImpl>
    implements _$$InsightImplCopyWith<$Res> {
  __$$InsightImplCopyWithImpl(
    _$InsightImpl _value,
    $Res Function(_$InsightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Insight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? priority = null,
    Object? title = null,
    Object? message = null,
    Object? recommendation = null,
    Object? generatedAt = null,
    Object? metadata = null,
    Object? engagement = freezed,
    Object? actionTaken = freezed,
    Object? dismissedAt = freezed,
    Object? viewedAt = freezed,
    Object? actionTakenAt = freezed,
  }) {
    return _then(
      _$InsightImpl(
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
                  as InsightType,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as InsightPriority,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendation: null == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as String,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        engagement: freezed == engagement
            ? _value.engagement
            : engagement // ignore: cast_nullable_to_non_nullable
                  as InsightEngagement?,
        actionTaken: freezed == actionTaken
            ? _value.actionTaken
            : actionTaken // ignore: cast_nullable_to_non_nullable
                  as String?,
        dismissedAt: freezed == dismissedAt
            ? _value.dismissedAt
            : dismissedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        viewedAt: freezed == viewedAt
            ? _value.viewedAt
            : viewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actionTakenAt: freezed == actionTakenAt
            ? _value.actionTakenAt
            : actionTakenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InsightImpl implements _Insight {
  const _$InsightImpl({
    required this.id,
    required this.userId,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.generatedAt,
    final Map<String, dynamic> metadata = const {},
    this.engagement,
    this.actionTaken,
    this.dismissedAt,
    this.viewedAt,
    this.actionTakenAt,
  }) : _metadata = metadata;

  factory _$InsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsightImplFromJson(json);

  /// Unique insight identifier
  @override
  final String id;

  /// User this insight belongs to
  @override
  final String userId;

  /// Type of insight
  @override
  final InsightType type;

  /// Priority level
  @override
  final InsightPriority priority;

  /// Insight title (localized)
  @override
  final String title;

  /// Insight message/description (localized)
  @override
  final String message;

  /// Recommended action (localized)
  @override
  final String recommendation;

  /// When the insight was generated
  @override
  final DateTime generatedAt;

  /// Additional metadata (exercise names, metrics, etc.)
  final Map<String, dynamic> _metadata;

  /// Additional metadata (exercise names, metrics, etc.)
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  /// User's engagement with this insight (if any)
  @override
  final InsightEngagement? engagement;

  /// Specific action the user took (e.g., "started_workout", "adjusted_volume")
  @override
  final String? actionTaken;

  /// When the user dismissed the insight
  @override
  final DateTime? dismissedAt;

  /// When the user first viewed the insight
  @override
  final DateTime? viewedAt;

  /// When action was taken (if applicable)
  @override
  final DateTime? actionTakenAt;

  @override
  String toString() {
    return 'Insight(id: $id, userId: $userId, type: $type, priority: $priority, title: $title, message: $message, recommendation: $recommendation, generatedAt: $generatedAt, metadata: $metadata, engagement: $engagement, actionTaken: $actionTaken, dismissedAt: $dismissedAt, viewedAt: $viewedAt, actionTakenAt: $actionTakenAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.engagement, engagement) ||
                other.engagement == engagement) &&
            (identical(other.actionTaken, actionTaken) ||
                other.actionTaken == actionTaken) &&
            (identical(other.dismissedAt, dismissedAt) ||
                other.dismissedAt == dismissedAt) &&
            (identical(other.viewedAt, viewedAt) ||
                other.viewedAt == viewedAt) &&
            (identical(other.actionTakenAt, actionTakenAt) ||
                other.actionTakenAt == actionTakenAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    type,
    priority,
    title,
    message,
    recommendation,
    generatedAt,
    const DeepCollectionEquality().hash(_metadata),
    engagement,
    actionTaken,
    dismissedAt,
    viewedAt,
    actionTakenAt,
  );

  /// Create a copy of Insight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InsightImplCopyWith<_$InsightImpl> get copyWith =>
      __$$InsightImplCopyWithImpl<_$InsightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InsightImplToJson(this);
  }
}

abstract class _Insight implements Insight {
  const factory _Insight({
    required final String id,
    required final String userId,
    required final InsightType type,
    required final InsightPriority priority,
    required final String title,
    required final String message,
    required final String recommendation,
    required final DateTime generatedAt,
    final Map<String, dynamic> metadata,
    final InsightEngagement? engagement,
    final String? actionTaken,
    final DateTime? dismissedAt,
    final DateTime? viewedAt,
    final DateTime? actionTakenAt,
  }) = _$InsightImpl;

  factory _Insight.fromJson(Map<String, dynamic> json) = _$InsightImpl.fromJson;

  /// Unique insight identifier
  @override
  String get id;

  /// User this insight belongs to
  @override
  String get userId;

  /// Type of insight
  @override
  InsightType get type;

  /// Priority level
  @override
  InsightPriority get priority;

  /// Insight title (localized)
  @override
  String get title;

  /// Insight message/description (localized)
  @override
  String get message;

  /// Recommended action (localized)
  @override
  String get recommendation;

  /// When the insight was generated
  @override
  DateTime get generatedAt;

  /// Additional metadata (exercise names, metrics, etc.)
  @override
  Map<String, dynamic> get metadata;

  /// User's engagement with this insight (if any)
  @override
  InsightEngagement? get engagement;

  /// Specific action the user took (e.g., "started_workout", "adjusted_volume")
  @override
  String? get actionTaken;

  /// When the user dismissed the insight
  @override
  DateTime? get dismissedAt;

  /// When the user first viewed the insight
  @override
  DateTime? get viewedAt;

  /// When action was taken (if applicable)
  @override
  DateTime? get actionTakenAt;

  /// Create a copy of Insight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InsightImplCopyWith<_$InsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
