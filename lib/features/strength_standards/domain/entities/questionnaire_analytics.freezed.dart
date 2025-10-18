// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'questionnaire_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QuestionnaireAnalytics _$QuestionnaireAnalyticsFromJson(
    Map<String, dynamic> json) {
  return _QuestionnaireAnalytics.fromJson(json);
}

/// @nodoc
mixin _$QuestionnaireAnalytics {
  /// User ID for aggregation
  String get userId => throw _privateConstructorUsedError;

  /// Timestamp when questionnaire was started
  DateTime get startedAt => throw _privateConstructorUsedError;

  /// Timestamp when completed (null if abandoned)
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Last step user reached before abandoning/completing
  int get lastStepReached => throw _privateConstructorUsedError;

  /// Total steps in questionnaire (usually 7: 0-6)
  int get totalSteps => throw _privateConstructorUsedError;

  /// Time spent on each step (step index → seconds)
  Map<int, int> get stepDurations => throw _privateConstructorUsedError;

  /// Whether user abandoned (true) or completed (false)
  bool? get wasAbandoned => throw _privateConstructorUsedError;

  /// Feedback ratings for each step (1-5 scale, null if not rated)
  Map<int, int?> get stepFeedback => throw _privateConstructorUsedError;

  /// Total time from start to completion/abandon (seconds)
  int? get totalDurationSeconds => throw _privateConstructorUsedError;

  /// Device/platform info for analytics
  String? get platform => throw _privateConstructorUsedError;

  /// App version
  String? get appVersion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestionnaireAnalyticsCopyWith<QuestionnaireAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionnaireAnalyticsCopyWith<$Res> {
  factory $QuestionnaireAnalyticsCopyWith(QuestionnaireAnalytics value,
          $Res Function(QuestionnaireAnalytics) then) =
      _$QuestionnaireAnalyticsCopyWithImpl<$Res, QuestionnaireAnalytics>;
  @useResult
  $Res call(
      {String userId,
      DateTime startedAt,
      DateTime? completedAt,
      int lastStepReached,
      int totalSteps,
      Map<int, int> stepDurations,
      bool? wasAbandoned,
      Map<int, int?> stepFeedback,
      int? totalDurationSeconds,
      String? platform,
      String? appVersion});
}

/// @nodoc
class _$QuestionnaireAnalyticsCopyWithImpl<$Res,
        $Val extends QuestionnaireAnalytics>
    implements $QuestionnaireAnalyticsCopyWith<$Res> {
  _$QuestionnaireAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? lastStepReached = null,
    Object? totalSteps = null,
    Object? stepDurations = null,
    Object? wasAbandoned = freezed,
    Object? stepFeedback = null,
    Object? totalDurationSeconds = freezed,
    Object? platform = freezed,
    Object? appVersion = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastStepReached: null == lastStepReached
          ? _value.lastStepReached
          : lastStepReached // ignore: cast_nullable_to_non_nullable
              as int,
      totalSteps: null == totalSteps
          ? _value.totalSteps
          : totalSteps // ignore: cast_nullable_to_non_nullable
              as int,
      stepDurations: null == stepDurations
          ? _value.stepDurations
          : stepDurations // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      wasAbandoned: freezed == wasAbandoned
          ? _value.wasAbandoned
          : wasAbandoned // ignore: cast_nullable_to_non_nullable
              as bool?,
      stepFeedback: null == stepFeedback
          ? _value.stepFeedback
          : stepFeedback // ignore: cast_nullable_to_non_nullable
              as Map<int, int?>,
      totalDurationSeconds: freezed == totalDurationSeconds
          ? _value.totalDurationSeconds
          : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      platform: freezed == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String?,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionnaireAnalyticsImplCopyWith<$Res>
    implements $QuestionnaireAnalyticsCopyWith<$Res> {
  factory _$$QuestionnaireAnalyticsImplCopyWith(
          _$QuestionnaireAnalyticsImpl value,
          $Res Function(_$QuestionnaireAnalyticsImpl) then) =
      __$$QuestionnaireAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime startedAt,
      DateTime? completedAt,
      int lastStepReached,
      int totalSteps,
      Map<int, int> stepDurations,
      bool? wasAbandoned,
      Map<int, int?> stepFeedback,
      int? totalDurationSeconds,
      String? platform,
      String? appVersion});
}

/// @nodoc
class __$$QuestionnaireAnalyticsImplCopyWithImpl<$Res>
    extends _$QuestionnaireAnalyticsCopyWithImpl<$Res,
        _$QuestionnaireAnalyticsImpl>
    implements _$$QuestionnaireAnalyticsImplCopyWith<$Res> {
  __$$QuestionnaireAnalyticsImplCopyWithImpl(
      _$QuestionnaireAnalyticsImpl _value,
      $Res Function(_$QuestionnaireAnalyticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? lastStepReached = null,
    Object? totalSteps = null,
    Object? stepDurations = null,
    Object? wasAbandoned = freezed,
    Object? stepFeedback = null,
    Object? totalDurationSeconds = freezed,
    Object? platform = freezed,
    Object? appVersion = freezed,
  }) {
    return _then(_$QuestionnaireAnalyticsImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastStepReached: null == lastStepReached
          ? _value.lastStepReached
          : lastStepReached // ignore: cast_nullable_to_non_nullable
              as int,
      totalSteps: null == totalSteps
          ? _value.totalSteps
          : totalSteps // ignore: cast_nullable_to_non_nullable
              as int,
      stepDurations: null == stepDurations
          ? _value._stepDurations
          : stepDurations // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      wasAbandoned: freezed == wasAbandoned
          ? _value.wasAbandoned
          : wasAbandoned // ignore: cast_nullable_to_non_nullable
              as bool?,
      stepFeedback: null == stepFeedback
          ? _value._stepFeedback
          : stepFeedback // ignore: cast_nullable_to_non_nullable
              as Map<int, int?>,
      totalDurationSeconds: freezed == totalDurationSeconds
          ? _value.totalDurationSeconds
          : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      platform: freezed == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String?,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionnaireAnalyticsImpl implements _QuestionnaireAnalytics {
  const _$QuestionnaireAnalyticsImpl(
      {required this.userId,
      required this.startedAt,
      this.completedAt,
      this.lastStepReached = 0,
      this.totalSteps = 7,
      final Map<int, int> stepDurations = const {},
      this.wasAbandoned,
      final Map<int, int?> stepFeedback = const {},
      this.totalDurationSeconds,
      this.platform,
      this.appVersion})
      : _stepDurations = stepDurations,
        _stepFeedback = stepFeedback;

  factory _$QuestionnaireAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionnaireAnalyticsImplFromJson(json);

  /// User ID for aggregation
  @override
  final String userId;

  /// Timestamp when questionnaire was started
  @override
  final DateTime startedAt;

  /// Timestamp when completed (null if abandoned)
  @override
  final DateTime? completedAt;

  /// Last step user reached before abandoning/completing
  @override
  @JsonKey()
  final int lastStepReached;

  /// Total steps in questionnaire (usually 7: 0-6)
  @override
  @JsonKey()
  final int totalSteps;

  /// Time spent on each step (step index → seconds)
  final Map<int, int> _stepDurations;

  /// Time spent on each step (step index → seconds)
  @override
  @JsonKey()
  Map<int, int> get stepDurations {
    if (_stepDurations is EqualUnmodifiableMapView) return _stepDurations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stepDurations);
  }

  /// Whether user abandoned (true) or completed (false)
  @override
  final bool? wasAbandoned;

  /// Feedback ratings for each step (1-5 scale, null if not rated)
  final Map<int, int?> _stepFeedback;

  /// Feedback ratings for each step (1-5 scale, null if not rated)
  @override
  @JsonKey()
  Map<int, int?> get stepFeedback {
    if (_stepFeedback is EqualUnmodifiableMapView) return _stepFeedback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stepFeedback);
  }

  /// Total time from start to completion/abandon (seconds)
  @override
  final int? totalDurationSeconds;

  /// Device/platform info for analytics
  @override
  final String? platform;

  /// App version
  @override
  final String? appVersion;

  @override
  String toString() {
    return 'QuestionnaireAnalytics(userId: $userId, startedAt: $startedAt, completedAt: $completedAt, lastStepReached: $lastStepReached, totalSteps: $totalSteps, stepDurations: $stepDurations, wasAbandoned: $wasAbandoned, stepFeedback: $stepFeedback, totalDurationSeconds: $totalDurationSeconds, platform: $platform, appVersion: $appVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionnaireAnalyticsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.lastStepReached, lastStepReached) ||
                other.lastStepReached == lastStepReached) &&
            (identical(other.totalSteps, totalSteps) ||
                other.totalSteps == totalSteps) &&
            const DeepCollectionEquality()
                .equals(other._stepDurations, _stepDurations) &&
            (identical(other.wasAbandoned, wasAbandoned) ||
                other.wasAbandoned == wasAbandoned) &&
            const DeepCollectionEquality()
                .equals(other._stepFeedback, _stepFeedback) &&
            (identical(other.totalDurationSeconds, totalDurationSeconds) ||
                other.totalDurationSeconds == totalDurationSeconds) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      startedAt,
      completedAt,
      lastStepReached,
      totalSteps,
      const DeepCollectionEquality().hash(_stepDurations),
      wasAbandoned,
      const DeepCollectionEquality().hash(_stepFeedback),
      totalDurationSeconds,
      platform,
      appVersion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionnaireAnalyticsImplCopyWith<_$QuestionnaireAnalyticsImpl>
      get copyWith => __$$QuestionnaireAnalyticsImplCopyWithImpl<
          _$QuestionnaireAnalyticsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionnaireAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _QuestionnaireAnalytics implements QuestionnaireAnalytics {
  const factory _QuestionnaireAnalytics(
      {required final String userId,
      required final DateTime startedAt,
      final DateTime? completedAt,
      final int lastStepReached,
      final int totalSteps,
      final Map<int, int> stepDurations,
      final bool? wasAbandoned,
      final Map<int, int?> stepFeedback,
      final int? totalDurationSeconds,
      final String? platform,
      final String? appVersion}) = _$QuestionnaireAnalyticsImpl;

  factory _QuestionnaireAnalytics.fromJson(Map<String, dynamic> json) =
      _$QuestionnaireAnalyticsImpl.fromJson;

  @override

  /// User ID for aggregation
  String get userId;
  @override

  /// Timestamp when questionnaire was started
  DateTime get startedAt;
  @override

  /// Timestamp when completed (null if abandoned)
  DateTime? get completedAt;
  @override

  /// Last step user reached before abandoning/completing
  int get lastStepReached;
  @override

  /// Total steps in questionnaire (usually 7: 0-6)
  int get totalSteps;
  @override

  /// Time spent on each step (step index → seconds)
  Map<int, int> get stepDurations;
  @override

  /// Whether user abandoned (true) or completed (false)
  bool? get wasAbandoned;
  @override

  /// Feedback ratings for each step (1-5 scale, null if not rated)
  Map<int, int?> get stepFeedback;
  @override

  /// Total time from start to completion/abandon (seconds)
  int? get totalDurationSeconds;
  @override

  /// Device/platform info for analytics
  String? get platform;
  @override

  /// App version
  String? get appVersion;
  @override
  @JsonKey(ignore: true)
  _$$QuestionnaireAnalyticsImplCopyWith<_$QuestionnaireAnalyticsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
