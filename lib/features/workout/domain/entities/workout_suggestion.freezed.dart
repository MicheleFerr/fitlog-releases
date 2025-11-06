// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutSuggestion _$WorkoutSuggestionFromJson(Map<String, dynamic> json) {
  return _WorkoutSuggestion.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSuggestion {
  /// Suggestion level (pattern/routine/frequency/dayBased)
  SuggestionLevel get level => throw _privateConstructorUsedError;

  /// Predicted workout name
  ///
  /// Examples: "Push", "Pull", "Legs", "franco", "ciccio", "paolo"
  String get workoutName => throw _privateConstructorUsedError;

  /// Confidence score (0.0 - 1.0)
  ///
  /// - Pattern: 0.70 - 0.95 (viability checked)
  /// - Routine: 0.80 - 0.90 (active routine exists)
  /// - Frequency: 0.50 - 0.70 (based on frequency)
  /// - DayBased: 0.30 - 0.50 (fallback default)
  double get confidence => throw _privateConstructorUsedError;

  /// Human-readable reason for this suggestion
  ///
  /// Examples:
  /// - "Detected pattern: Push → Pull → Legs (85% confidence)"
  /// - "Your routine schedule says: Upper Body"
  /// - "You do Push most often (5 times last month)"
  /// - "It's Monday - you usually do Franco"
  String get reason => throw _privateConstructorUsedError;

  /// Optional pattern information (only for pattern-based suggestions)
  ///
  /// Example: "You completed Push yesterday"
  String? get patternInfo => throw _privateConstructorUsedError;

  /// Optional template ID (only for routine-based suggestions)
  String? get routineTemplateId => throw _privateConstructorUsedError;

  /// Optional frequency data (only for frequency-based suggestions)
  ///
  /// Example: "5 times in last 30 days"
  String? get frequencyData => throw _privateConstructorUsedError;

  /// Optional scheduled date for routine-based suggestions
  ///
  /// When provided, indicates the date when this workout is scheduled
  /// in the active routine. Used to display "This is the workout you should
  /// do on dd/mm/yyyy" in the UI.
  ///
  /// Example: DateTime(2025, 11, 8) → "08/11/2025"
  DateTime? get scheduledDate => throw _privateConstructorUsedError;

  /// Timestamp when this suggestion was generated
  DateTime? get generatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutSuggestionCopyWith<WorkoutSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSuggestionCopyWith<$Res> {
  factory $WorkoutSuggestionCopyWith(
          WorkoutSuggestion value, $Res Function(WorkoutSuggestion) then) =
      _$WorkoutSuggestionCopyWithImpl<$Res, WorkoutSuggestion>;
  @useResult
  $Res call(
      {SuggestionLevel level,
      String workoutName,
      double confidence,
      String reason,
      String? patternInfo,
      String? routineTemplateId,
      String? frequencyData,
      DateTime? scheduledDate,
      DateTime? generatedAt});
}

/// @nodoc
class _$WorkoutSuggestionCopyWithImpl<$Res, $Val extends WorkoutSuggestion>
    implements $WorkoutSuggestionCopyWith<$Res> {
  _$WorkoutSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? workoutName = null,
    Object? confidence = null,
    Object? reason = null,
    Object? patternInfo = freezed,
    Object? routineTemplateId = freezed,
    Object? frequencyData = freezed,
    Object? scheduledDate = freezed,
    Object? generatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as SuggestionLevel,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      patternInfo: freezed == patternInfo
          ? _value.patternInfo
          : patternInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      routineTemplateId: freezed == routineTemplateId
          ? _value.routineTemplateId
          : routineTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      frequencyData: freezed == frequencyData
          ? _value.frequencyData
          : frequencyData // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSuggestionImplCopyWith<$Res>
    implements $WorkoutSuggestionCopyWith<$Res> {
  factory _$$WorkoutSuggestionImplCopyWith(_$WorkoutSuggestionImpl value,
          $Res Function(_$WorkoutSuggestionImpl) then) =
      __$$WorkoutSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SuggestionLevel level,
      String workoutName,
      double confidence,
      String reason,
      String? patternInfo,
      String? routineTemplateId,
      String? frequencyData,
      DateTime? scheduledDate,
      DateTime? generatedAt});
}

/// @nodoc
class __$$WorkoutSuggestionImplCopyWithImpl<$Res>
    extends _$WorkoutSuggestionCopyWithImpl<$Res, _$WorkoutSuggestionImpl>
    implements _$$WorkoutSuggestionImplCopyWith<$Res> {
  __$$WorkoutSuggestionImplCopyWithImpl(_$WorkoutSuggestionImpl _value,
      $Res Function(_$WorkoutSuggestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? workoutName = null,
    Object? confidence = null,
    Object? reason = null,
    Object? patternInfo = freezed,
    Object? routineTemplateId = freezed,
    Object? frequencyData = freezed,
    Object? scheduledDate = freezed,
    Object? generatedAt = freezed,
  }) {
    return _then(_$WorkoutSuggestionImpl(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as SuggestionLevel,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      patternInfo: freezed == patternInfo
          ? _value.patternInfo
          : patternInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      routineTemplateId: freezed == routineTemplateId
          ? _value.routineTemplateId
          : routineTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      frequencyData: freezed == frequencyData
          ? _value.frequencyData
          : frequencyData // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSuggestionImpl extends _WorkoutSuggestion {
  const _$WorkoutSuggestionImpl(
      {required this.level,
      required this.workoutName,
      required this.confidence,
      required this.reason,
      this.patternInfo,
      this.routineTemplateId,
      this.frequencyData,
      this.scheduledDate,
      this.generatedAt = null})
      : super._();

  factory _$WorkoutSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSuggestionImplFromJson(json);

  /// Suggestion level (pattern/routine/frequency/dayBased)
  @override
  final SuggestionLevel level;

  /// Predicted workout name
  ///
  /// Examples: "Push", "Pull", "Legs", "franco", "ciccio", "paolo"
  @override
  final String workoutName;

  /// Confidence score (0.0 - 1.0)
  ///
  /// - Pattern: 0.70 - 0.95 (viability checked)
  /// - Routine: 0.80 - 0.90 (active routine exists)
  /// - Frequency: 0.50 - 0.70 (based on frequency)
  /// - DayBased: 0.30 - 0.50 (fallback default)
  @override
  final double confidence;

  /// Human-readable reason for this suggestion
  ///
  /// Examples:
  /// - "Detected pattern: Push → Pull → Legs (85% confidence)"
  /// - "Your routine schedule says: Upper Body"
  /// - "You do Push most often (5 times last month)"
  /// - "It's Monday - you usually do Franco"
  @override
  final String reason;

  /// Optional pattern information (only for pattern-based suggestions)
  ///
  /// Example: "You completed Push yesterday"
  @override
  final String? patternInfo;

  /// Optional template ID (only for routine-based suggestions)
  @override
  final String? routineTemplateId;

  /// Optional frequency data (only for frequency-based suggestions)
  ///
  /// Example: "5 times in last 30 days"
  @override
  final String? frequencyData;

  /// Optional scheduled date for routine-based suggestions
  ///
  /// When provided, indicates the date when this workout is scheduled
  /// in the active routine. Used to display "This is the workout you should
  /// do on dd/mm/yyyy" in the UI.
  ///
  /// Example: DateTime(2025, 11, 8) → "08/11/2025"
  @override
  final DateTime? scheduledDate;

  /// Timestamp when this suggestion was generated
  @override
  @JsonKey()
  final DateTime? generatedAt;

  @override
  String toString() {
    return 'WorkoutSuggestion(level: $level, workoutName: $workoutName, confidence: $confidence, reason: $reason, patternInfo: $patternInfo, routineTemplateId: $routineTemplateId, frequencyData: $frequencyData, scheduledDate: $scheduledDate, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSuggestionImpl &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.patternInfo, patternInfo) ||
                other.patternInfo == patternInfo) &&
            (identical(other.routineTemplateId, routineTemplateId) ||
                other.routineTemplateId == routineTemplateId) &&
            (identical(other.frequencyData, frequencyData) ||
                other.frequencyData == frequencyData) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      level,
      workoutName,
      confidence,
      reason,
      patternInfo,
      routineTemplateId,
      frequencyData,
      scheduledDate,
      generatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSuggestionImplCopyWith<_$WorkoutSuggestionImpl> get copyWith =>
      __$$WorkoutSuggestionImplCopyWithImpl<_$WorkoutSuggestionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSuggestionImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSuggestion extends WorkoutSuggestion {
  const factory _WorkoutSuggestion(
      {required final SuggestionLevel level,
      required final String workoutName,
      required final double confidence,
      required final String reason,
      final String? patternInfo,
      final String? routineTemplateId,
      final String? frequencyData,
      final DateTime? scheduledDate,
      final DateTime? generatedAt}) = _$WorkoutSuggestionImpl;
  const _WorkoutSuggestion._() : super._();

  factory _WorkoutSuggestion.fromJson(Map<String, dynamic> json) =
      _$WorkoutSuggestionImpl.fromJson;

  @override

  /// Suggestion level (pattern/routine/frequency/dayBased)
  SuggestionLevel get level;
  @override

  /// Predicted workout name
  ///
  /// Examples: "Push", "Pull", "Legs", "franco", "ciccio", "paolo"
  String get workoutName;
  @override

  /// Confidence score (0.0 - 1.0)
  ///
  /// - Pattern: 0.70 - 0.95 (viability checked)
  /// - Routine: 0.80 - 0.90 (active routine exists)
  /// - Frequency: 0.50 - 0.70 (based on frequency)
  /// - DayBased: 0.30 - 0.50 (fallback default)
  double get confidence;
  @override

  /// Human-readable reason for this suggestion
  ///
  /// Examples:
  /// - "Detected pattern: Push → Pull → Legs (85% confidence)"
  /// - "Your routine schedule says: Upper Body"
  /// - "You do Push most often (5 times last month)"
  /// - "It's Monday - you usually do Franco"
  String get reason;
  @override

  /// Optional pattern information (only for pattern-based suggestions)
  ///
  /// Example: "You completed Push yesterday"
  String? get patternInfo;
  @override

  /// Optional template ID (only for routine-based suggestions)
  String? get routineTemplateId;
  @override

  /// Optional frequency data (only for frequency-based suggestions)
  ///
  /// Example: "5 times in last 30 days"
  String? get frequencyData;
  @override

  /// Optional scheduled date for routine-based suggestions
  ///
  /// When provided, indicates the date when this workout is scheduled
  /// in the active routine. Used to display "This is the workout you should
  /// do on dd/mm/yyyy" in the UI.
  ///
  /// Example: DateTime(2025, 11, 8) → "08/11/2025"
  DateTime? get scheduledDate;
  @override

  /// Timestamp when this suggestion was generated
  DateTime? get generatedAt;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSuggestionImplCopyWith<_$WorkoutSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
