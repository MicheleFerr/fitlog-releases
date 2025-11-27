// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AIInsight _$AIInsightFromJson(Map<String, dynamic> json) {
  return _AIInsight.fromJson(json);
}

/// @nodoc
mixin _$AIInsight {
  String get id => throw _privateConstructorUsedError;
  InsightType get type => throw _privateConstructorUsedError;
  InsightSeverity get severity => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get recommendation => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String? get affectedExercise => throw _privateConstructorUsedError;
  List<String>? get affectedTemplates => throw _privateConstructorUsedError;
  List<String>? get scientificStrategies => throw _privateConstructorUsedError;
  Map<String, dynamic>? get dataPoints => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this AIInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIInsightCopyWith<AIInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIInsightCopyWith<$Res> {
  factory $AIInsightCopyWith(AIInsight value, $Res Function(AIInsight) then) =
      _$AIInsightCopyWithImpl<$Res, AIInsight>;
  @useResult
  $Res call({
    String id,
    InsightType type,
    InsightSeverity severity,
    String title,
    String description,
    String recommendation,
    int priority,
    String? affectedExercise,
    List<String>? affectedTemplates,
    List<String>? scientificStrategies,
    Map<String, dynamic>? dataPoints,
    DateTime timestamp,
  });
}

/// @nodoc
class _$AIInsightCopyWithImpl<$Res, $Val extends AIInsight>
    implements $AIInsightCopyWith<$Res> {
  _$AIInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? title = null,
    Object? description = null,
    Object? recommendation = null,
    Object? priority = null,
    Object? affectedExercise = freezed,
    Object? affectedTemplates = freezed,
    Object? scientificStrategies = freezed,
    Object? dataPoints = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as InsightType,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as InsightSeverity,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendation: null == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            affectedExercise: freezed == affectedExercise
                ? _value.affectedExercise
                : affectedExercise // ignore: cast_nullable_to_non_nullable
                      as String?,
            affectedTemplates: freezed == affectedTemplates
                ? _value.affectedTemplates
                : affectedTemplates // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            scientificStrategies: freezed == scientificStrategies
                ? _value.scientificStrategies
                : scientificStrategies // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            dataPoints: freezed == dataPoints
                ? _value.dataPoints
                : dataPoints // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AIInsightImplCopyWith<$Res>
    implements $AIInsightCopyWith<$Res> {
  factory _$$AIInsightImplCopyWith(
    _$AIInsightImpl value,
    $Res Function(_$AIInsightImpl) then,
  ) = __$$AIInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    InsightType type,
    InsightSeverity severity,
    String title,
    String description,
    String recommendation,
    int priority,
    String? affectedExercise,
    List<String>? affectedTemplates,
    List<String>? scientificStrategies,
    Map<String, dynamic>? dataPoints,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$AIInsightImplCopyWithImpl<$Res>
    extends _$AIInsightCopyWithImpl<$Res, _$AIInsightImpl>
    implements _$$AIInsightImplCopyWith<$Res> {
  __$$AIInsightImplCopyWithImpl(
    _$AIInsightImpl _value,
    $Res Function(_$AIInsightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? severity = null,
    Object? title = null,
    Object? description = null,
    Object? recommendation = null,
    Object? priority = null,
    Object? affectedExercise = freezed,
    Object? affectedTemplates = freezed,
    Object? scientificStrategies = freezed,
    Object? dataPoints = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$AIInsightImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as InsightType,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as InsightSeverity,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendation: null == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        affectedExercise: freezed == affectedExercise
            ? _value.affectedExercise
            : affectedExercise // ignore: cast_nullable_to_non_nullable
                  as String?,
        affectedTemplates: freezed == affectedTemplates
            ? _value._affectedTemplates
            : affectedTemplates // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        scientificStrategies: freezed == scientificStrategies
            ? _value._scientificStrategies
            : scientificStrategies // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        dataPoints: freezed == dataPoints
            ? _value._dataPoints
            : dataPoints // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AIInsightImpl implements _AIInsight {
  const _$AIInsightImpl({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.priority,
    this.affectedExercise,
    final List<String>? affectedTemplates,
    final List<String>? scientificStrategies,
    final Map<String, dynamic>? dataPoints,
    required this.timestamp,
  }) : _affectedTemplates = affectedTemplates,
       _scientificStrategies = scientificStrategies,
       _dataPoints = dataPoints;

  factory _$AIInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIInsightImplFromJson(json);

  @override
  final String id;
  @override
  final InsightType type;
  @override
  final InsightSeverity severity;
  @override
  final String title;
  @override
  final String description;
  @override
  final String recommendation;
  @override
  final int priority;
  @override
  final String? affectedExercise;
  final List<String>? _affectedTemplates;
  @override
  List<String>? get affectedTemplates {
    final value = _affectedTemplates;
    if (value == null) return null;
    if (_affectedTemplates is EqualUnmodifiableListView)
      return _affectedTemplates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _scientificStrategies;
  @override
  List<String>? get scientificStrategies {
    final value = _scientificStrategies;
    if (value == null) return null;
    if (_scientificStrategies is EqualUnmodifiableListView)
      return _scientificStrategies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _dataPoints;
  @override
  Map<String, dynamic>? get dataPoints {
    final value = _dataPoints;
    if (value == null) return null;
    if (_dataPoints is EqualUnmodifiableMapView) return _dataPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'AIInsight(id: $id, type: $type, severity: $severity, title: $title, description: $description, recommendation: $recommendation, priority: $priority, affectedExercise: $affectedExercise, affectedTemplates: $affectedTemplates, scientificStrategies: $scientificStrategies, dataPoints: $dataPoints, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIInsightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.affectedExercise, affectedExercise) ||
                other.affectedExercise == affectedExercise) &&
            const DeepCollectionEquality().equals(
              other._affectedTemplates,
              _affectedTemplates,
            ) &&
            const DeepCollectionEquality().equals(
              other._scientificStrategies,
              _scientificStrategies,
            ) &&
            const DeepCollectionEquality().equals(
              other._dataPoints,
              _dataPoints,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    severity,
    title,
    description,
    recommendation,
    priority,
    affectedExercise,
    const DeepCollectionEquality().hash(_affectedTemplates),
    const DeepCollectionEquality().hash(_scientificStrategies),
    const DeepCollectionEquality().hash(_dataPoints),
    timestamp,
  );

  /// Create a copy of AIInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIInsightImplCopyWith<_$AIInsightImpl> get copyWith =>
      __$$AIInsightImplCopyWithImpl<_$AIInsightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIInsightImplToJson(this);
  }
}

abstract class _AIInsight implements AIInsight {
  const factory _AIInsight({
    required final String id,
    required final InsightType type,
    required final InsightSeverity severity,
    required final String title,
    required final String description,
    required final String recommendation,
    required final int priority,
    final String? affectedExercise,
    final List<String>? affectedTemplates,
    final List<String>? scientificStrategies,
    final Map<String, dynamic>? dataPoints,
    required final DateTime timestamp,
  }) = _$AIInsightImpl;

  factory _AIInsight.fromJson(Map<String, dynamic> json) =
      _$AIInsightImpl.fromJson;

  @override
  String get id;
  @override
  InsightType get type;
  @override
  InsightSeverity get severity;
  @override
  String get title;
  @override
  String get description;
  @override
  String get recommendation;
  @override
  int get priority;
  @override
  String? get affectedExercise;
  @override
  List<String>? get affectedTemplates;
  @override
  List<String>? get scientificStrategies;
  @override
  Map<String, dynamic>? get dataPoints;
  @override
  DateTime get timestamp;

  /// Create a copy of AIInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIInsightImplCopyWith<_$AIInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
