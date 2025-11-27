// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSuggestion {

/// Suggestion level (pattern/routine/frequency/dayBased)
 SuggestionLevel get level;/// Predicted workout name
///
/// Examples: "Push", "Pull", "Legs", "franco", "ciccio", "paolo"
 String get workoutName;/// Confidence score (0.0 - 1.0)
///
/// - Pattern: 0.70 - 0.95 (viability checked)
/// - Routine: 0.80 - 0.90 (active routine exists)
/// - Frequency: 0.50 - 0.70 (based on frequency)
/// - DayBased: 0.30 - 0.50 (fallback default)
 double get confidence;/// Human-readable reason for this suggestion
///
/// Examples:
/// - "Detected pattern: Push → Pull → Legs (85% confidence)"
/// - "Your routine schedule says: Upper Body"
/// - "You do Push most often (5 times last month)"
/// - "It's Monday - you usually do Franco"
 String get reason;/// Optional pattern information (only for pattern-based suggestions)
///
/// Example: "You completed Push yesterday"
 String? get patternInfo;/// Optional template ID (only for routine-based suggestions)
 String? get routineTemplateId;/// Optional frequency data (only for frequency-based suggestions)
///
/// Example: "5 times in last 30 days"
 String? get frequencyData;/// Optional scheduled date for routine-based suggestions
///
/// When provided, indicates the date when this workout is scheduled
/// in the active routine. Used to display "This is the workout you should
/// do on dd/mm/yyyy" in the UI.
///
/// Example: DateTime(2025, 11, 8) → "08/11/2025"
 DateTime? get scheduledDate;/// Timestamp when this suggestion was generated
 DateTime? get generatedAt;/// ✅ NEW: Is this a recovery suggestion for a missed workout?
 bool get isRecovery;/// ✅ NEW: Date of the missed workout being recovered
 DateTime? get recoveryDate;
/// Create a copy of WorkoutSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSuggestionCopyWith<WorkoutSuggestion> get copyWith => _$WorkoutSuggestionCopyWithImpl<WorkoutSuggestion>(this as WorkoutSuggestion, _$identity);

  /// Serializes this WorkoutSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSuggestion&&(identical(other.level, level) || other.level == level)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.patternInfo, patternInfo) || other.patternInfo == patternInfo)&&(identical(other.routineTemplateId, routineTemplateId) || other.routineTemplateId == routineTemplateId)&&(identical(other.frequencyData, frequencyData) || other.frequencyData == frequencyData)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.isRecovery, isRecovery) || other.isRecovery == isRecovery)&&(identical(other.recoveryDate, recoveryDate) || other.recoveryDate == recoveryDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,workoutName,confidence,reason,patternInfo,routineTemplateId,frequencyData,scheduledDate,generatedAt,isRecovery,recoveryDate);

@override
String toString() {
  return 'WorkoutSuggestion(level: $level, workoutName: $workoutName, confidence: $confidence, reason: $reason, patternInfo: $patternInfo, routineTemplateId: $routineTemplateId, frequencyData: $frequencyData, scheduledDate: $scheduledDate, generatedAt: $generatedAt, isRecovery: $isRecovery, recoveryDate: $recoveryDate)';
}


}

/// @nodoc
abstract mixin class $WorkoutSuggestionCopyWith<$Res>  {
  factory $WorkoutSuggestionCopyWith(WorkoutSuggestion value, $Res Function(WorkoutSuggestion) _then) = _$WorkoutSuggestionCopyWithImpl;
@useResult
$Res call({
 SuggestionLevel level, String workoutName, double confidence, String reason, String? patternInfo, String? routineTemplateId, String? frequencyData, DateTime? scheduledDate, DateTime? generatedAt, bool isRecovery, DateTime? recoveryDate
});




}
/// @nodoc
class _$WorkoutSuggestionCopyWithImpl<$Res>
    implements $WorkoutSuggestionCopyWith<$Res> {
  _$WorkoutSuggestionCopyWithImpl(this._self, this._then);

  final WorkoutSuggestion _self;
  final $Res Function(WorkoutSuggestion) _then;

/// Create a copy of WorkoutSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? workoutName = null,Object? confidence = null,Object? reason = null,Object? patternInfo = freezed,Object? routineTemplateId = freezed,Object? frequencyData = freezed,Object? scheduledDate = freezed,Object? generatedAt = freezed,Object? isRecovery = null,Object? recoveryDate = freezed,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as SuggestionLevel,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,patternInfo: freezed == patternInfo ? _self.patternInfo : patternInfo // ignore: cast_nullable_to_non_nullable
as String?,routineTemplateId: freezed == routineTemplateId ? _self.routineTemplateId : routineTemplateId // ignore: cast_nullable_to_non_nullable
as String?,frequencyData: freezed == frequencyData ? _self.frequencyData : frequencyData // ignore: cast_nullable_to_non_nullable
as String?,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,generatedAt: freezed == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRecovery: null == isRecovery ? _self.isRecovery : isRecovery // ignore: cast_nullable_to_non_nullable
as bool,recoveryDate: freezed == recoveryDate ? _self.recoveryDate : recoveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSuggestion].
extension WorkoutSuggestionPatterns on WorkoutSuggestion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSuggestion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSuggestion():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSuggestion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SuggestionLevel level,  String workoutName,  double confidence,  String reason,  String? patternInfo,  String? routineTemplateId,  String? frequencyData,  DateTime? scheduledDate,  DateTime? generatedAt,  bool isRecovery,  DateTime? recoveryDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSuggestion() when $default != null:
return $default(_that.level,_that.workoutName,_that.confidence,_that.reason,_that.patternInfo,_that.routineTemplateId,_that.frequencyData,_that.scheduledDate,_that.generatedAt,_that.isRecovery,_that.recoveryDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SuggestionLevel level,  String workoutName,  double confidence,  String reason,  String? patternInfo,  String? routineTemplateId,  String? frequencyData,  DateTime? scheduledDate,  DateTime? generatedAt,  bool isRecovery,  DateTime? recoveryDate)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSuggestion():
return $default(_that.level,_that.workoutName,_that.confidence,_that.reason,_that.patternInfo,_that.routineTemplateId,_that.frequencyData,_that.scheduledDate,_that.generatedAt,_that.isRecovery,_that.recoveryDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SuggestionLevel level,  String workoutName,  double confidence,  String reason,  String? patternInfo,  String? routineTemplateId,  String? frequencyData,  DateTime? scheduledDate,  DateTime? generatedAt,  bool isRecovery,  DateTime? recoveryDate)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSuggestion() when $default != null:
return $default(_that.level,_that.workoutName,_that.confidence,_that.reason,_that.patternInfo,_that.routineTemplateId,_that.frequencyData,_that.scheduledDate,_that.generatedAt,_that.isRecovery,_that.recoveryDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSuggestion extends WorkoutSuggestion {
  const _WorkoutSuggestion({required this.level, required this.workoutName, required this.confidence, required this.reason, this.patternInfo, this.routineTemplateId, this.frequencyData, this.scheduledDate, this.generatedAt = null, this.isRecovery = false, this.recoveryDate}): super._();
  factory _WorkoutSuggestion.fromJson(Map<String, dynamic> json) => _$WorkoutSuggestionFromJson(json);

/// Suggestion level (pattern/routine/frequency/dayBased)
@override final  SuggestionLevel level;
/// Predicted workout name
///
/// Examples: "Push", "Pull", "Legs", "franco", "ciccio", "paolo"
@override final  String workoutName;
/// Confidence score (0.0 - 1.0)
///
/// - Pattern: 0.70 - 0.95 (viability checked)
/// - Routine: 0.80 - 0.90 (active routine exists)
/// - Frequency: 0.50 - 0.70 (based on frequency)
/// - DayBased: 0.30 - 0.50 (fallback default)
@override final  double confidence;
/// Human-readable reason for this suggestion
///
/// Examples:
/// - "Detected pattern: Push → Pull → Legs (85% confidence)"
/// - "Your routine schedule says: Upper Body"
/// - "You do Push most often (5 times last month)"
/// - "It's Monday - you usually do Franco"
@override final  String reason;
/// Optional pattern information (only for pattern-based suggestions)
///
/// Example: "You completed Push yesterday"
@override final  String? patternInfo;
/// Optional template ID (only for routine-based suggestions)
@override final  String? routineTemplateId;
/// Optional frequency data (only for frequency-based suggestions)
///
/// Example: "5 times in last 30 days"
@override final  String? frequencyData;
/// Optional scheduled date for routine-based suggestions
///
/// When provided, indicates the date when this workout is scheduled
/// in the active routine. Used to display "This is the workout you should
/// do on dd/mm/yyyy" in the UI.
///
/// Example: DateTime(2025, 11, 8) → "08/11/2025"
@override final  DateTime? scheduledDate;
/// Timestamp when this suggestion was generated
@override@JsonKey() final  DateTime? generatedAt;
/// ✅ NEW: Is this a recovery suggestion for a missed workout?
@override@JsonKey() final  bool isRecovery;
/// ✅ NEW: Date of the missed workout being recovered
@override final  DateTime? recoveryDate;

/// Create a copy of WorkoutSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSuggestionCopyWith<_WorkoutSuggestion> get copyWith => __$WorkoutSuggestionCopyWithImpl<_WorkoutSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSuggestion&&(identical(other.level, level) || other.level == level)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.patternInfo, patternInfo) || other.patternInfo == patternInfo)&&(identical(other.routineTemplateId, routineTemplateId) || other.routineTemplateId == routineTemplateId)&&(identical(other.frequencyData, frequencyData) || other.frequencyData == frequencyData)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.isRecovery, isRecovery) || other.isRecovery == isRecovery)&&(identical(other.recoveryDate, recoveryDate) || other.recoveryDate == recoveryDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level,workoutName,confidence,reason,patternInfo,routineTemplateId,frequencyData,scheduledDate,generatedAt,isRecovery,recoveryDate);

@override
String toString() {
  return 'WorkoutSuggestion(level: $level, workoutName: $workoutName, confidence: $confidence, reason: $reason, patternInfo: $patternInfo, routineTemplateId: $routineTemplateId, frequencyData: $frequencyData, scheduledDate: $scheduledDate, generatedAt: $generatedAt, isRecovery: $isRecovery, recoveryDate: $recoveryDate)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSuggestionCopyWith<$Res> implements $WorkoutSuggestionCopyWith<$Res> {
  factory _$WorkoutSuggestionCopyWith(_WorkoutSuggestion value, $Res Function(_WorkoutSuggestion) _then) = __$WorkoutSuggestionCopyWithImpl;
@override @useResult
$Res call({
 SuggestionLevel level, String workoutName, double confidence, String reason, String? patternInfo, String? routineTemplateId, String? frequencyData, DateTime? scheduledDate, DateTime? generatedAt, bool isRecovery, DateTime? recoveryDate
});




}
/// @nodoc
class __$WorkoutSuggestionCopyWithImpl<$Res>
    implements _$WorkoutSuggestionCopyWith<$Res> {
  __$WorkoutSuggestionCopyWithImpl(this._self, this._then);

  final _WorkoutSuggestion _self;
  final $Res Function(_WorkoutSuggestion) _then;

/// Create a copy of WorkoutSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? workoutName = null,Object? confidence = null,Object? reason = null,Object? patternInfo = freezed,Object? routineTemplateId = freezed,Object? frequencyData = freezed,Object? scheduledDate = freezed,Object? generatedAt = freezed,Object? isRecovery = null,Object? recoveryDate = freezed,}) {
  return _then(_WorkoutSuggestion(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as SuggestionLevel,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,patternInfo: freezed == patternInfo ? _self.patternInfo : patternInfo // ignore: cast_nullable_to_non_nullable
as String?,routineTemplateId: freezed == routineTemplateId ? _self.routineTemplateId : routineTemplateId // ignore: cast_nullable_to_non_nullable
as String?,frequencyData: freezed == frequencyData ? _self.frequencyData : frequencyData // ignore: cast_nullable_to_non_nullable
as String?,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,generatedAt: freezed == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRecovery: null == isRecovery ? _self.isRecovery : isRecovery // ignore: cast_nullable_to_non_nullable
as bool,recoveryDate: freezed == recoveryDate ? _self.recoveryDate : recoveryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
