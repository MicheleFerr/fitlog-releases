// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainingPattern {
  /// Type of pattern detected
  PatternType get type => throw _privateConstructorUsedError;

  /// Severity level
  PatternSeverity get severity => throw _privateConstructorUsedError;

  /// Confidence score (0.0 to 1.0)
  /// Based on correlation strength and data points
  double get confidence => throw _privateConstructorUsedError;

  /// Localization key for title
  String get titleKey => throw _privateConstructorUsedError;

  /// Localization key for description
  String get descriptionKey => throw _privateConstructorUsedError;

  /// Localization key for recommendation
  String get recommendationKey => throw _privateConstructorUsedError;

  /// Scientific explanation key (for expanded view)
  String? get scienceKey => throw _privateConstructorUsedError;

  /// Number of sessions analyzed for this pattern
  int get sessionsAnalyzed => throw _privateConstructorUsedError;

  /// Raw metrics that triggered this pattern
  Map<String, double> get triggerMetrics => throw _privateConstructorUsedError;

  /// Create a copy of TrainingPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingPatternCopyWith<TrainingPattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPatternCopyWith<$Res> {
  factory $TrainingPatternCopyWith(
    TrainingPattern value,
    $Res Function(TrainingPattern) then,
  ) = _$TrainingPatternCopyWithImpl<$Res, TrainingPattern>;
  @useResult
  $Res call({
    PatternType type,
    PatternSeverity severity,
    double confidence,
    String titleKey,
    String descriptionKey,
    String recommendationKey,
    String? scienceKey,
    int sessionsAnalyzed,
    Map<String, double> triggerMetrics,
  });
}

/// @nodoc
class _$TrainingPatternCopyWithImpl<$Res, $Val extends TrainingPattern>
    implements $TrainingPatternCopyWith<$Res> {
  _$TrainingPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? severity = null,
    Object? confidence = null,
    Object? titleKey = null,
    Object? descriptionKey = null,
    Object? recommendationKey = null,
    Object? scienceKey = freezed,
    Object? sessionsAnalyzed = null,
    Object? triggerMetrics = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PatternType,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as PatternSeverity,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            titleKey: null == titleKey
                ? _value.titleKey
                : titleKey // ignore: cast_nullable_to_non_nullable
                      as String,
            descriptionKey: null == descriptionKey
                ? _value.descriptionKey
                : descriptionKey // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendationKey: null == recommendationKey
                ? _value.recommendationKey
                : recommendationKey // ignore: cast_nullable_to_non_nullable
                      as String,
            scienceKey: freezed == scienceKey
                ? _value.scienceKey
                : scienceKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            sessionsAnalyzed: null == sessionsAnalyzed
                ? _value.sessionsAnalyzed
                : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
                      as int,
            triggerMetrics: null == triggerMetrics
                ? _value.triggerMetrics
                : triggerMetrics // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainingPatternImplCopyWith<$Res>
    implements $TrainingPatternCopyWith<$Res> {
  factory _$$TrainingPatternImplCopyWith(
    _$TrainingPatternImpl value,
    $Res Function(_$TrainingPatternImpl) then,
  ) = __$$TrainingPatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PatternType type,
    PatternSeverity severity,
    double confidence,
    String titleKey,
    String descriptionKey,
    String recommendationKey,
    String? scienceKey,
    int sessionsAnalyzed,
    Map<String, double> triggerMetrics,
  });
}

/// @nodoc
class __$$TrainingPatternImplCopyWithImpl<$Res>
    extends _$TrainingPatternCopyWithImpl<$Res, _$TrainingPatternImpl>
    implements _$$TrainingPatternImplCopyWith<$Res> {
  __$$TrainingPatternImplCopyWithImpl(
    _$TrainingPatternImpl _value,
    $Res Function(_$TrainingPatternImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? severity = null,
    Object? confidence = null,
    Object? titleKey = null,
    Object? descriptionKey = null,
    Object? recommendationKey = null,
    Object? scienceKey = freezed,
    Object? sessionsAnalyzed = null,
    Object? triggerMetrics = null,
  }) {
    return _then(
      _$TrainingPatternImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PatternType,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as PatternSeverity,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        titleKey: null == titleKey
            ? _value.titleKey
            : titleKey // ignore: cast_nullable_to_non_nullable
                  as String,
        descriptionKey: null == descriptionKey
            ? _value.descriptionKey
            : descriptionKey // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendationKey: null == recommendationKey
            ? _value.recommendationKey
            : recommendationKey // ignore: cast_nullable_to_non_nullable
                  as String,
        scienceKey: freezed == scienceKey
            ? _value.scienceKey
            : scienceKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        sessionsAnalyzed: null == sessionsAnalyzed
            ? _value.sessionsAnalyzed
            : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
                  as int,
        triggerMetrics: null == triggerMetrics
            ? _value._triggerMetrics
            : triggerMetrics // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
      ),
    );
  }
}

/// @nodoc

class _$TrainingPatternImpl extends _TrainingPattern {
  const _$TrainingPatternImpl({
    required this.type,
    required this.severity,
    required this.confidence,
    required this.titleKey,
    required this.descriptionKey,
    required this.recommendationKey,
    this.scienceKey,
    this.sessionsAnalyzed = 0,
    final Map<String, double> triggerMetrics = const {},
  }) : _triggerMetrics = triggerMetrics,
       super._();

  /// Type of pattern detected
  @override
  final PatternType type;

  /// Severity level
  @override
  final PatternSeverity severity;

  /// Confidence score (0.0 to 1.0)
  /// Based on correlation strength and data points
  @override
  final double confidence;

  /// Localization key for title
  @override
  final String titleKey;

  /// Localization key for description
  @override
  final String descriptionKey;

  /// Localization key for recommendation
  @override
  final String recommendationKey;

  /// Scientific explanation key (for expanded view)
  @override
  final String? scienceKey;

  /// Number of sessions analyzed for this pattern
  @override
  @JsonKey()
  final int sessionsAnalyzed;

  /// Raw metrics that triggered this pattern
  final Map<String, double> _triggerMetrics;

  /// Raw metrics that triggered this pattern
  @override
  @JsonKey()
  Map<String, double> get triggerMetrics {
    if (_triggerMetrics is EqualUnmodifiableMapView) return _triggerMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_triggerMetrics);
  }

  @override
  String toString() {
    return 'TrainingPattern(type: $type, severity: $severity, confidence: $confidence, titleKey: $titleKey, descriptionKey: $descriptionKey, recommendationKey: $recommendationKey, scienceKey: $scienceKey, sessionsAnalyzed: $sessionsAnalyzed, triggerMetrics: $triggerMetrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPatternImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.titleKey, titleKey) ||
                other.titleKey == titleKey) &&
            (identical(other.descriptionKey, descriptionKey) ||
                other.descriptionKey == descriptionKey) &&
            (identical(other.recommendationKey, recommendationKey) ||
                other.recommendationKey == recommendationKey) &&
            (identical(other.scienceKey, scienceKey) ||
                other.scienceKey == scienceKey) &&
            (identical(other.sessionsAnalyzed, sessionsAnalyzed) ||
                other.sessionsAnalyzed == sessionsAnalyzed) &&
            const DeepCollectionEquality().equals(
              other._triggerMetrics,
              _triggerMetrics,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    severity,
    confidence,
    titleKey,
    descriptionKey,
    recommendationKey,
    scienceKey,
    sessionsAnalyzed,
    const DeepCollectionEquality().hash(_triggerMetrics),
  );

  /// Create a copy of TrainingPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPatternImplCopyWith<_$TrainingPatternImpl> get copyWith =>
      __$$TrainingPatternImplCopyWithImpl<_$TrainingPatternImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainingPattern extends TrainingPattern {
  const factory _TrainingPattern({
    required final PatternType type,
    required final PatternSeverity severity,
    required final double confidence,
    required final String titleKey,
    required final String descriptionKey,
    required final String recommendationKey,
    final String? scienceKey,
    final int sessionsAnalyzed,
    final Map<String, double> triggerMetrics,
  }) = _$TrainingPatternImpl;
  const _TrainingPattern._() : super._();

  /// Type of pattern detected
  @override
  PatternType get type;

  /// Severity level
  @override
  PatternSeverity get severity;

  /// Confidence score (0.0 to 1.0)
  /// Based on correlation strength and data points
  @override
  double get confidence;

  /// Localization key for title
  @override
  String get titleKey;

  /// Localization key for description
  @override
  String get descriptionKey;

  /// Localization key for recommendation
  @override
  String get recommendationKey;

  /// Scientific explanation key (for expanded view)
  @override
  String? get scienceKey;

  /// Number of sessions analyzed for this pattern
  @override
  int get sessionsAnalyzed;

  /// Raw metrics that triggered this pattern
  @override
  Map<String, double> get triggerMetrics;

  /// Create a copy of TrainingPattern
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingPatternImplCopyWith<_$TrainingPatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrainingPatternResults {
  /// All detected patterns, sorted by priority
  List<TrainingPattern> get patterns => throw _privateConstructorUsedError;

  /// The most significant pattern (highest priority)
  TrainingPattern? get primaryPattern => throw _privateConstructorUsedError;

  /// Overall training status summary
  TrainingStatus get overallStatus => throw _privateConstructorUsedError;

  /// Timestamp when patterns were analyzed
  DateTime get analyzedAt => throw _privateConstructorUsedError;

  /// Number of data points used
  int get dataPointsUsed => throw _privateConstructorUsedError;

  /// Create a copy of TrainingPatternResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingPatternResultsCopyWith<TrainingPatternResults> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPatternResultsCopyWith<$Res> {
  factory $TrainingPatternResultsCopyWith(
    TrainingPatternResults value,
    $Res Function(TrainingPatternResults) then,
  ) = _$TrainingPatternResultsCopyWithImpl<$Res, TrainingPatternResults>;
  @useResult
  $Res call({
    List<TrainingPattern> patterns,
    TrainingPattern? primaryPattern,
    TrainingStatus overallStatus,
    DateTime analyzedAt,
    int dataPointsUsed,
  });

  $TrainingPatternCopyWith<$Res>? get primaryPattern;
}

/// @nodoc
class _$TrainingPatternResultsCopyWithImpl<
  $Res,
  $Val extends TrainingPatternResults
>
    implements $TrainingPatternResultsCopyWith<$Res> {
  _$TrainingPatternResultsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingPatternResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patterns = null,
    Object? primaryPattern = freezed,
    Object? overallStatus = null,
    Object? analyzedAt = null,
    Object? dataPointsUsed = null,
  }) {
    return _then(
      _value.copyWith(
            patterns: null == patterns
                ? _value.patterns
                : patterns // ignore: cast_nullable_to_non_nullable
                      as List<TrainingPattern>,
            primaryPattern: freezed == primaryPattern
                ? _value.primaryPattern
                : primaryPattern // ignore: cast_nullable_to_non_nullable
                      as TrainingPattern?,
            overallStatus: null == overallStatus
                ? _value.overallStatus
                : overallStatus // ignore: cast_nullable_to_non_nullable
                      as TrainingStatus,
            analyzedAt: null == analyzedAt
                ? _value.analyzedAt
                : analyzedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dataPointsUsed: null == dataPointsUsed
                ? _value.dataPointsUsed
                : dataPointsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of TrainingPatternResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainingPatternCopyWith<$Res>? get primaryPattern {
    if (_value.primaryPattern == null) {
      return null;
    }

    return $TrainingPatternCopyWith<$Res>(_value.primaryPattern!, (value) {
      return _then(_value.copyWith(primaryPattern: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrainingPatternResultsImplCopyWith<$Res>
    implements $TrainingPatternResultsCopyWith<$Res> {
  factory _$$TrainingPatternResultsImplCopyWith(
    _$TrainingPatternResultsImpl value,
    $Res Function(_$TrainingPatternResultsImpl) then,
  ) = __$$TrainingPatternResultsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TrainingPattern> patterns,
    TrainingPattern? primaryPattern,
    TrainingStatus overallStatus,
    DateTime analyzedAt,
    int dataPointsUsed,
  });

  @override
  $TrainingPatternCopyWith<$Res>? get primaryPattern;
}

/// @nodoc
class __$$TrainingPatternResultsImplCopyWithImpl<$Res>
    extends
        _$TrainingPatternResultsCopyWithImpl<$Res, _$TrainingPatternResultsImpl>
    implements _$$TrainingPatternResultsImplCopyWith<$Res> {
  __$$TrainingPatternResultsImplCopyWithImpl(
    _$TrainingPatternResultsImpl _value,
    $Res Function(_$TrainingPatternResultsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingPatternResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patterns = null,
    Object? primaryPattern = freezed,
    Object? overallStatus = null,
    Object? analyzedAt = null,
    Object? dataPointsUsed = null,
  }) {
    return _then(
      _$TrainingPatternResultsImpl(
        patterns: null == patterns
            ? _value._patterns
            : patterns // ignore: cast_nullable_to_non_nullable
                  as List<TrainingPattern>,
        primaryPattern: freezed == primaryPattern
            ? _value.primaryPattern
            : primaryPattern // ignore: cast_nullable_to_non_nullable
                  as TrainingPattern?,
        overallStatus: null == overallStatus
            ? _value.overallStatus
            : overallStatus // ignore: cast_nullable_to_non_nullable
                  as TrainingStatus,
        analyzedAt: null == analyzedAt
            ? _value.analyzedAt
            : analyzedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dataPointsUsed: null == dataPointsUsed
            ? _value.dataPointsUsed
            : dataPointsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$TrainingPatternResultsImpl extends _TrainingPatternResults {
  const _$TrainingPatternResultsImpl({
    required final List<TrainingPattern> patterns,
    this.primaryPattern,
    required this.overallStatus,
    required this.analyzedAt,
    this.dataPointsUsed = 0,
  }) : _patterns = patterns,
       super._();

  /// All detected patterns, sorted by priority
  final List<TrainingPattern> _patterns;

  /// All detected patterns, sorted by priority
  @override
  List<TrainingPattern> get patterns {
    if (_patterns is EqualUnmodifiableListView) return _patterns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_patterns);
  }

  /// The most significant pattern (highest priority)
  @override
  final TrainingPattern? primaryPattern;

  /// Overall training status summary
  @override
  final TrainingStatus overallStatus;

  /// Timestamp when patterns were analyzed
  @override
  final DateTime analyzedAt;

  /// Number of data points used
  @override
  @JsonKey()
  final int dataPointsUsed;

  @override
  String toString() {
    return 'TrainingPatternResults(patterns: $patterns, primaryPattern: $primaryPattern, overallStatus: $overallStatus, analyzedAt: $analyzedAt, dataPointsUsed: $dataPointsUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPatternResultsImpl &&
            const DeepCollectionEquality().equals(other._patterns, _patterns) &&
            (identical(other.primaryPattern, primaryPattern) ||
                other.primaryPattern == primaryPattern) &&
            (identical(other.overallStatus, overallStatus) ||
                other.overallStatus == overallStatus) &&
            (identical(other.analyzedAt, analyzedAt) ||
                other.analyzedAt == analyzedAt) &&
            (identical(other.dataPointsUsed, dataPointsUsed) ||
                other.dataPointsUsed == dataPointsUsed));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_patterns),
    primaryPattern,
    overallStatus,
    analyzedAt,
    dataPointsUsed,
  );

  /// Create a copy of TrainingPatternResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPatternResultsImplCopyWith<_$TrainingPatternResultsImpl>
  get copyWith =>
      __$$TrainingPatternResultsImplCopyWithImpl<_$TrainingPatternResultsImpl>(
        this,
        _$identity,
      );
}

abstract class _TrainingPatternResults extends TrainingPatternResults {
  const factory _TrainingPatternResults({
    required final List<TrainingPattern> patterns,
    final TrainingPattern? primaryPattern,
    required final TrainingStatus overallStatus,
    required final DateTime analyzedAt,
    final int dataPointsUsed,
  }) = _$TrainingPatternResultsImpl;
  const _TrainingPatternResults._() : super._();

  /// All detected patterns, sorted by priority
  @override
  List<TrainingPattern> get patterns;

  /// The most significant pattern (highest priority)
  @override
  TrainingPattern? get primaryPattern;

  /// Overall training status summary
  @override
  TrainingStatus get overallStatus;

  /// Timestamp when patterns were analyzed
  @override
  DateTime get analyzedAt;

  /// Number of data points used
  @override
  int get dataPointsUsed;

  /// Create a copy of TrainingPatternResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingPatternResultsImplCopyWith<_$TrainingPatternResultsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
