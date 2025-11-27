// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pr_celebration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PRCelebration _$PRCelebrationFromJson(Map<String, dynamic> json) {
  return _PRCelebration.fromJson(json);
}

/// @nodoc
mixin _$PRCelebration {
  /// Unique celebration identifier
  String get id => throw _privateConstructorUsedError;

  /// User who achieved the PR
  String get userId => throw _privateConstructorUsedError;

  /// Personal record identifier
  String get prId => throw _privateConstructorUsedError;

  /// Type of personal record achieved
  PRType get prType => throw _privateConstructorUsedError;

  /// When the celebration was triggered
  DateTime get celebratedAt => throw _privateConstructorUsedError;

  /// How the user engaged with the celebration
  CelebrationEngagement get engagement => throw _privateConstructorUsedError;

  /// Previous personal record value
  double get previousValue => throw _privateConstructorUsedError;

  /// New personal record value
  double get newValue => throw _privateConstructorUsedError;

  /// Exercise name (optional for context)
  String? get exerciseName => throw _privateConstructorUsedError;

  /// Whether a push notification was sent
  bool get notificationSent => throw _privateConstructorUsedError;

  /// When the notification was sent (if applicable)
  DateTime? get notificationSentAt => throw _privateConstructorUsedError;

  /// Serializes this PRCelebration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PRCelebration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PRCelebrationCopyWith<PRCelebration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PRCelebrationCopyWith<$Res> {
  factory $PRCelebrationCopyWith(
    PRCelebration value,
    $Res Function(PRCelebration) then,
  ) = _$PRCelebrationCopyWithImpl<$Res, PRCelebration>;
  @useResult
  $Res call({
    String id,
    String userId,
    String prId,
    PRType prType,
    DateTime celebratedAt,
    CelebrationEngagement engagement,
    double previousValue,
    double newValue,
    String? exerciseName,
    bool notificationSent,
    DateTime? notificationSentAt,
  });
}

/// @nodoc
class _$PRCelebrationCopyWithImpl<$Res, $Val extends PRCelebration>
    implements $PRCelebrationCopyWith<$Res> {
  _$PRCelebrationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PRCelebration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? prId = null,
    Object? prType = null,
    Object? celebratedAt = null,
    Object? engagement = null,
    Object? previousValue = null,
    Object? newValue = null,
    Object? exerciseName = freezed,
    Object? notificationSent = null,
    Object? notificationSentAt = freezed,
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
            prId: null == prId
                ? _value.prId
                : prId // ignore: cast_nullable_to_non_nullable
                      as String,
            prType: null == prType
                ? _value.prType
                : prType // ignore: cast_nullable_to_non_nullable
                      as PRType,
            celebratedAt: null == celebratedAt
                ? _value.celebratedAt
                : celebratedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            engagement: null == engagement
                ? _value.engagement
                : engagement // ignore: cast_nullable_to_non_nullable
                      as CelebrationEngagement,
            previousValue: null == previousValue
                ? _value.previousValue
                : previousValue // ignore: cast_nullable_to_non_nullable
                      as double,
            newValue: null == newValue
                ? _value.newValue
                : newValue // ignore: cast_nullable_to_non_nullable
                      as double,
            exerciseName: freezed == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String?,
            notificationSent: null == notificationSent
                ? _value.notificationSent
                : notificationSent // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationSentAt: freezed == notificationSentAt
                ? _value.notificationSentAt
                : notificationSentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PRCelebrationImplCopyWith<$Res>
    implements $PRCelebrationCopyWith<$Res> {
  factory _$$PRCelebrationImplCopyWith(
    _$PRCelebrationImpl value,
    $Res Function(_$PRCelebrationImpl) then,
  ) = __$$PRCelebrationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String prId,
    PRType prType,
    DateTime celebratedAt,
    CelebrationEngagement engagement,
    double previousValue,
    double newValue,
    String? exerciseName,
    bool notificationSent,
    DateTime? notificationSentAt,
  });
}

/// @nodoc
class __$$PRCelebrationImplCopyWithImpl<$Res>
    extends _$PRCelebrationCopyWithImpl<$Res, _$PRCelebrationImpl>
    implements _$$PRCelebrationImplCopyWith<$Res> {
  __$$PRCelebrationImplCopyWithImpl(
    _$PRCelebrationImpl _value,
    $Res Function(_$PRCelebrationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PRCelebration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? prId = null,
    Object? prType = null,
    Object? celebratedAt = null,
    Object? engagement = null,
    Object? previousValue = null,
    Object? newValue = null,
    Object? exerciseName = freezed,
    Object? notificationSent = null,
    Object? notificationSentAt = freezed,
  }) {
    return _then(
      _$PRCelebrationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        prId: null == prId
            ? _value.prId
            : prId // ignore: cast_nullable_to_non_nullable
                  as String,
        prType: null == prType
            ? _value.prType
            : prType // ignore: cast_nullable_to_non_nullable
                  as PRType,
        celebratedAt: null == celebratedAt
            ? _value.celebratedAt
            : celebratedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        engagement: null == engagement
            ? _value.engagement
            : engagement // ignore: cast_nullable_to_non_nullable
                  as CelebrationEngagement,
        previousValue: null == previousValue
            ? _value.previousValue
            : previousValue // ignore: cast_nullable_to_non_nullable
                  as double,
        newValue: null == newValue
            ? _value.newValue
            : newValue // ignore: cast_nullable_to_non_nullable
                  as double,
        exerciseName: freezed == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String?,
        notificationSent: null == notificationSent
            ? _value.notificationSent
            : notificationSent // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationSentAt: freezed == notificationSentAt
            ? _value.notificationSentAt
            : notificationSentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PRCelebrationImpl implements _PRCelebration {
  const _$PRCelebrationImpl({
    required this.id,
    required this.userId,
    required this.prId,
    required this.prType,
    required this.celebratedAt,
    required this.engagement,
    required this.previousValue,
    required this.newValue,
    this.exerciseName,
    this.notificationSent = false,
    this.notificationSentAt,
  });

  factory _$PRCelebrationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PRCelebrationImplFromJson(json);

  /// Unique celebration identifier
  @override
  final String id;

  /// User who achieved the PR
  @override
  final String userId;

  /// Personal record identifier
  @override
  final String prId;

  /// Type of personal record achieved
  @override
  final PRType prType;

  /// When the celebration was triggered
  @override
  final DateTime celebratedAt;

  /// How the user engaged with the celebration
  @override
  final CelebrationEngagement engagement;

  /// Previous personal record value
  @override
  final double previousValue;

  /// New personal record value
  @override
  final double newValue;

  /// Exercise name (optional for context)
  @override
  final String? exerciseName;

  /// Whether a push notification was sent
  @override
  @JsonKey()
  final bool notificationSent;

  /// When the notification was sent (if applicable)
  @override
  final DateTime? notificationSentAt;

  @override
  String toString() {
    return 'PRCelebration(id: $id, userId: $userId, prId: $prId, prType: $prType, celebratedAt: $celebratedAt, engagement: $engagement, previousValue: $previousValue, newValue: $newValue, exerciseName: $exerciseName, notificationSent: $notificationSent, notificationSentAt: $notificationSentAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PRCelebrationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.prId, prId) || other.prId == prId) &&
            (identical(other.prType, prType) || other.prType == prType) &&
            (identical(other.celebratedAt, celebratedAt) ||
                other.celebratedAt == celebratedAt) &&
            (identical(other.engagement, engagement) ||
                other.engagement == engagement) &&
            (identical(other.previousValue, previousValue) ||
                other.previousValue == previousValue) &&
            (identical(other.newValue, newValue) ||
                other.newValue == newValue) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.notificationSent, notificationSent) ||
                other.notificationSent == notificationSent) &&
            (identical(other.notificationSentAt, notificationSentAt) ||
                other.notificationSentAt == notificationSentAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    prId,
    prType,
    celebratedAt,
    engagement,
    previousValue,
    newValue,
    exerciseName,
    notificationSent,
    notificationSentAt,
  );

  /// Create a copy of PRCelebration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PRCelebrationImplCopyWith<_$PRCelebrationImpl> get copyWith =>
      __$$PRCelebrationImplCopyWithImpl<_$PRCelebrationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PRCelebrationImplToJson(this);
  }
}

abstract class _PRCelebration implements PRCelebration {
  const factory _PRCelebration({
    required final String id,
    required final String userId,
    required final String prId,
    required final PRType prType,
    required final DateTime celebratedAt,
    required final CelebrationEngagement engagement,
    required final double previousValue,
    required final double newValue,
    final String? exerciseName,
    final bool notificationSent,
    final DateTime? notificationSentAt,
  }) = _$PRCelebrationImpl;

  factory _PRCelebration.fromJson(Map<String, dynamic> json) =
      _$PRCelebrationImpl.fromJson;

  /// Unique celebration identifier
  @override
  String get id;

  /// User who achieved the PR
  @override
  String get userId;

  /// Personal record identifier
  @override
  String get prId;

  /// Type of personal record achieved
  @override
  PRType get prType;

  /// When the celebration was triggered
  @override
  DateTime get celebratedAt;

  /// How the user engaged with the celebration
  @override
  CelebrationEngagement get engagement;

  /// Previous personal record value
  @override
  double get previousValue;

  /// New personal record value
  @override
  double get newValue;

  /// Exercise name (optional for context)
  @override
  String? get exerciseName;

  /// Whether a push notification was sent
  @override
  bool get notificationSent;

  /// When the notification was sent (if applicable)
  @override
  DateTime? get notificationSentAt;

  /// Create a copy of PRCelebration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PRCelebrationImplCopyWith<_$PRCelebrationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
