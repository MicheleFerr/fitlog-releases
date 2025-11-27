// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_page_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AnalyticsPageFeedback _$AnalyticsPageFeedbackFromJson(
  Map<String, dynamic> json,
) {
  return _AnalyticsPageFeedback.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsPageFeedback {
  /// Unique identifier: {userId}_{timestamp}
  String get id => throw _privateConstructorUsedError;

  /// Firebase Auth UID dell'utente
  String get userId => throw _privateConstructorUsedError;

  /// Feedback positivo (true = 👍) o negativo (false = 👎)
  bool get isHelpful => throw _privateConstructorUsedError;

  /// Commento opzionale dell'utente
  String? get comment => throw _privateConstructorUsedError;

  /// Timestamp quando il feedback è stato dato
  DateTime get timestamp =>
      throw _privateConstructorUsedError; // ========================================
  // METADATA OPZIONALE PER ANALYTICS
  // ========================================
  /// Numero totale di workout visualizzati in Analytics
  /// (utile per capire quanto l'utente ha usato la feature)
  int? get totalWorkoutsViewed => throw _privateConstructorUsedError;

  /// Ultima sezione vista prima di dare feedback
  /// Valori: 'overview', 'progress', 'insights', 'routine'
  String? get lastViewedSection => throw _privateConstructorUsedError;

  /// Device info per analytics (es: "iOS 18.1", "Android 14")
  Map<String, dynamic>? get deviceInfo => throw _privateConstructorUsedError;

  /// Serializes this AnalyticsPageFeedback to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalyticsPageFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalyticsPageFeedbackCopyWith<AnalyticsPageFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsPageFeedbackCopyWith<$Res> {
  factory $AnalyticsPageFeedbackCopyWith(
    AnalyticsPageFeedback value,
    $Res Function(AnalyticsPageFeedback) then,
  ) = _$AnalyticsPageFeedbackCopyWithImpl<$Res, AnalyticsPageFeedback>;
  @useResult
  $Res call({
    String id,
    String userId,
    bool isHelpful,
    String? comment,
    DateTime timestamp,
    int? totalWorkoutsViewed,
    String? lastViewedSection,
    Map<String, dynamic>? deviceInfo,
  });
}

/// @nodoc
class _$AnalyticsPageFeedbackCopyWithImpl<
  $Res,
  $Val extends AnalyticsPageFeedback
>
    implements $AnalyticsPageFeedbackCopyWith<$Res> {
  _$AnalyticsPageFeedbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalyticsPageFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? isHelpful = null,
    Object? comment = freezed,
    Object? timestamp = null,
    Object? totalWorkoutsViewed = freezed,
    Object? lastViewedSection = freezed,
    Object? deviceInfo = freezed,
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
            isHelpful: null == isHelpful
                ? _value.isHelpful
                : isHelpful // ignore: cast_nullable_to_non_nullable
                      as bool,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalWorkoutsViewed: freezed == totalWorkoutsViewed
                ? _value.totalWorkoutsViewed
                : totalWorkoutsViewed // ignore: cast_nullable_to_non_nullable
                      as int?,
            lastViewedSection: freezed == lastViewedSection
                ? _value.lastViewedSection
                : lastViewedSection // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceInfo: freezed == deviceInfo
                ? _value.deviceInfo
                : deviceInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnalyticsPageFeedbackImplCopyWith<$Res>
    implements $AnalyticsPageFeedbackCopyWith<$Res> {
  factory _$$AnalyticsPageFeedbackImplCopyWith(
    _$AnalyticsPageFeedbackImpl value,
    $Res Function(_$AnalyticsPageFeedbackImpl) then,
  ) = __$$AnalyticsPageFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    bool isHelpful,
    String? comment,
    DateTime timestamp,
    int? totalWorkoutsViewed,
    String? lastViewedSection,
    Map<String, dynamic>? deviceInfo,
  });
}

/// @nodoc
class __$$AnalyticsPageFeedbackImplCopyWithImpl<$Res>
    extends
        _$AnalyticsPageFeedbackCopyWithImpl<$Res, _$AnalyticsPageFeedbackImpl>
    implements _$$AnalyticsPageFeedbackImplCopyWith<$Res> {
  __$$AnalyticsPageFeedbackImplCopyWithImpl(
    _$AnalyticsPageFeedbackImpl _value,
    $Res Function(_$AnalyticsPageFeedbackImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnalyticsPageFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? isHelpful = null,
    Object? comment = freezed,
    Object? timestamp = null,
    Object? totalWorkoutsViewed = freezed,
    Object? lastViewedSection = freezed,
    Object? deviceInfo = freezed,
  }) {
    return _then(
      _$AnalyticsPageFeedbackImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        isHelpful: null == isHelpful
            ? _value.isHelpful
            : isHelpful // ignore: cast_nullable_to_non_nullable
                  as bool,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalWorkoutsViewed: freezed == totalWorkoutsViewed
            ? _value.totalWorkoutsViewed
            : totalWorkoutsViewed // ignore: cast_nullable_to_non_nullable
                  as int?,
        lastViewedSection: freezed == lastViewedSection
            ? _value.lastViewedSection
            : lastViewedSection // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceInfo: freezed == deviceInfo
            ? _value._deviceInfo
            : deviceInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsPageFeedbackImpl implements _AnalyticsPageFeedback {
  const _$AnalyticsPageFeedbackImpl({
    required this.id,
    required this.userId,
    required this.isHelpful,
    this.comment,
    required this.timestamp,
    this.totalWorkoutsViewed,
    this.lastViewedSection,
    final Map<String, dynamic>? deviceInfo,
  }) : _deviceInfo = deviceInfo;

  factory _$AnalyticsPageFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsPageFeedbackImplFromJson(json);

  /// Unique identifier: {userId}_{timestamp}
  @override
  final String id;

  /// Firebase Auth UID dell'utente
  @override
  final String userId;

  /// Feedback positivo (true = 👍) o negativo (false = 👎)
  @override
  final bool isHelpful;

  /// Commento opzionale dell'utente
  @override
  final String? comment;

  /// Timestamp quando il feedback è stato dato
  @override
  final DateTime timestamp;
  // ========================================
  // METADATA OPZIONALE PER ANALYTICS
  // ========================================
  /// Numero totale di workout visualizzati in Analytics
  /// (utile per capire quanto l'utente ha usato la feature)
  @override
  final int? totalWorkoutsViewed;

  /// Ultima sezione vista prima di dare feedback
  /// Valori: 'overview', 'progress', 'insights', 'routine'
  @override
  final String? lastViewedSection;

  /// Device info per analytics (es: "iOS 18.1", "Android 14")
  final Map<String, dynamic>? _deviceInfo;

  /// Device info per analytics (es: "iOS 18.1", "Android 14")
  @override
  Map<String, dynamic>? get deviceInfo {
    final value = _deviceInfo;
    if (value == null) return null;
    if (_deviceInfo is EqualUnmodifiableMapView) return _deviceInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AnalyticsPageFeedback(id: $id, userId: $userId, isHelpful: $isHelpful, comment: $comment, timestamp: $timestamp, totalWorkoutsViewed: $totalWorkoutsViewed, lastViewedSection: $lastViewedSection, deviceInfo: $deviceInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsPageFeedbackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isHelpful, isHelpful) ||
                other.isHelpful == isHelpful) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.totalWorkoutsViewed, totalWorkoutsViewed) ||
                other.totalWorkoutsViewed == totalWorkoutsViewed) &&
            (identical(other.lastViewedSection, lastViewedSection) ||
                other.lastViewedSection == lastViewedSection) &&
            const DeepCollectionEquality().equals(
              other._deviceInfo,
              _deviceInfo,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    isHelpful,
    comment,
    timestamp,
    totalWorkoutsViewed,
    lastViewedSection,
    const DeepCollectionEquality().hash(_deviceInfo),
  );

  /// Create a copy of AnalyticsPageFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsPageFeedbackImplCopyWith<_$AnalyticsPageFeedbackImpl>
  get copyWith =>
      __$$AnalyticsPageFeedbackImplCopyWithImpl<_$AnalyticsPageFeedbackImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsPageFeedbackImplToJson(this);
  }
}

abstract class _AnalyticsPageFeedback implements AnalyticsPageFeedback {
  const factory _AnalyticsPageFeedback({
    required final String id,
    required final String userId,
    required final bool isHelpful,
    final String? comment,
    required final DateTime timestamp,
    final int? totalWorkoutsViewed,
    final String? lastViewedSection,
    final Map<String, dynamic>? deviceInfo,
  }) = _$AnalyticsPageFeedbackImpl;

  factory _AnalyticsPageFeedback.fromJson(Map<String, dynamic> json) =
      _$AnalyticsPageFeedbackImpl.fromJson;

  /// Unique identifier: {userId}_{timestamp}
  @override
  String get id;

  /// Firebase Auth UID dell'utente
  @override
  String get userId;

  /// Feedback positivo (true = 👍) o negativo (false = 👎)
  @override
  bool get isHelpful;

  /// Commento opzionale dell'utente
  @override
  String? get comment;

  /// Timestamp quando il feedback è stato dato
  @override
  DateTime get timestamp; // ========================================
  // METADATA OPZIONALE PER ANALYTICS
  // ========================================
  /// Numero totale di workout visualizzati in Analytics
  /// (utile per capire quanto l'utente ha usato la feature)
  @override
  int? get totalWorkoutsViewed;

  /// Ultima sezione vista prima di dare feedback
  /// Valori: 'overview', 'progress', 'insights', 'routine'
  @override
  String? get lastViewedSection;

  /// Device info per analytics (es: "iOS 18.1", "Android 14")
  @override
  Map<String, dynamic>? get deviceInfo;

  /// Create a copy of AnalyticsPageFeedback
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalyticsPageFeedbackImplCopyWith<_$AnalyticsPageFeedbackImpl>
  get copyWith => throw _privateConstructorUsedError;
}
