// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_stress_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateStressAnalysis {

/// Template ID
 String get templateId;/// Template name for display
 String get templateName;/// Template icon (if set)
 String? get templateIcon;/// Stress this template would add (0-100)
 double get expectedStress;/// Current stress level before workout
 double get currentStress;/// Resulting total stress after workout (current + expected)
 double get resultingTotalStress;/// Readiness data for each muscle involved
 Map<String, MuscleReadinessData> get muscleReadiness;/// Primary muscles targeted by this template
 List<String> get primaryMuscles;/// Secondary muscles targeted by this template
 List<String> get secondaryMuscles;/// Under-recovered muscles that would be stressed
 List<String> get underRecoveredMuscles;/// Fatigued muscles (should avoid)
 List<String> get fatiguedMuscles;/// Overall recommendation
 TemplateRecommendation get recommendation;/// Human-readable rationale
 String get rationale;/// Optimality score (0-100) - higher is better
 double get optimalityScore;// === FACTORS THAT INFLUENCED THE RECOMMENDATION ===
/// Whether sleep data was considered
 bool get sleepDataUsed;/// Whether HRV data was considered
 bool get hrvDataUsed;/// Sleep hours if available
 double? get sleepHoursLastNight;/// HRV if available (ms)
 double? get hrvMs;
/// Create a copy of TemplateStressAnalysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateStressAnalysisCopyWith<TemplateStressAnalysis> get copyWith => _$TemplateStressAnalysisCopyWithImpl<TemplateStressAnalysis>(this as TemplateStressAnalysis, _$identity);

  /// Serializes this TemplateStressAnalysis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateStressAnalysis&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.templateIcon, templateIcon) || other.templateIcon == templateIcon)&&(identical(other.expectedStress, expectedStress) || other.expectedStress == expectedStress)&&(identical(other.currentStress, currentStress) || other.currentStress == currentStress)&&(identical(other.resultingTotalStress, resultingTotalStress) || other.resultingTotalStress == resultingTotalStress)&&const DeepCollectionEquality().equals(other.muscleReadiness, muscleReadiness)&&const DeepCollectionEquality().equals(other.primaryMuscles, primaryMuscles)&&const DeepCollectionEquality().equals(other.secondaryMuscles, secondaryMuscles)&&const DeepCollectionEquality().equals(other.underRecoveredMuscles, underRecoveredMuscles)&&const DeepCollectionEquality().equals(other.fatiguedMuscles, fatiguedMuscles)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.optimalityScore, optimalityScore) || other.optimalityScore == optimalityScore)&&(identical(other.sleepDataUsed, sleepDataUsed) || other.sleepDataUsed == sleepDataUsed)&&(identical(other.hrvDataUsed, hrvDataUsed) || other.hrvDataUsed == hrvDataUsed)&&(identical(other.sleepHoursLastNight, sleepHoursLastNight) || other.sleepHoursLastNight == sleepHoursLastNight)&&(identical(other.hrvMs, hrvMs) || other.hrvMs == hrvMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateId,templateName,templateIcon,expectedStress,currentStress,resultingTotalStress,const DeepCollectionEquality().hash(muscleReadiness),const DeepCollectionEquality().hash(primaryMuscles),const DeepCollectionEquality().hash(secondaryMuscles),const DeepCollectionEquality().hash(underRecoveredMuscles),const DeepCollectionEquality().hash(fatiguedMuscles),recommendation,rationale,optimalityScore,sleepDataUsed,hrvDataUsed,sleepHoursLastNight,hrvMs);

@override
String toString() {
  return 'TemplateStressAnalysis(templateId: $templateId, templateName: $templateName, templateIcon: $templateIcon, expectedStress: $expectedStress, currentStress: $currentStress, resultingTotalStress: $resultingTotalStress, muscleReadiness: $muscleReadiness, primaryMuscles: $primaryMuscles, secondaryMuscles: $secondaryMuscles, underRecoveredMuscles: $underRecoveredMuscles, fatiguedMuscles: $fatiguedMuscles, recommendation: $recommendation, rationale: $rationale, optimalityScore: $optimalityScore, sleepDataUsed: $sleepDataUsed, hrvDataUsed: $hrvDataUsed, sleepHoursLastNight: $sleepHoursLastNight, hrvMs: $hrvMs)';
}


}

/// @nodoc
abstract mixin class $TemplateStressAnalysisCopyWith<$Res>  {
  factory $TemplateStressAnalysisCopyWith(TemplateStressAnalysis value, $Res Function(TemplateStressAnalysis) _then) = _$TemplateStressAnalysisCopyWithImpl;
@useResult
$Res call({
 String templateId, String templateName, String? templateIcon, double expectedStress, double currentStress, double resultingTotalStress, Map<String, MuscleReadinessData> muscleReadiness, List<String> primaryMuscles, List<String> secondaryMuscles, List<String> underRecoveredMuscles, List<String> fatiguedMuscles, TemplateRecommendation recommendation, String rationale, double optimalityScore, bool sleepDataUsed, bool hrvDataUsed, double? sleepHoursLastNight, double? hrvMs
});




}
/// @nodoc
class _$TemplateStressAnalysisCopyWithImpl<$Res>
    implements $TemplateStressAnalysisCopyWith<$Res> {
  _$TemplateStressAnalysisCopyWithImpl(this._self, this._then);

  final TemplateStressAnalysis _self;
  final $Res Function(TemplateStressAnalysis) _then;

/// Create a copy of TemplateStressAnalysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateId = null,Object? templateName = null,Object? templateIcon = freezed,Object? expectedStress = null,Object? currentStress = null,Object? resultingTotalStress = null,Object? muscleReadiness = null,Object? primaryMuscles = null,Object? secondaryMuscles = null,Object? underRecoveredMuscles = null,Object? fatiguedMuscles = null,Object? recommendation = null,Object? rationale = null,Object? optimalityScore = null,Object? sleepDataUsed = null,Object? hrvDataUsed = null,Object? sleepHoursLastNight = freezed,Object? hrvMs = freezed,}) {
  return _then(_self.copyWith(
templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,templateIcon: freezed == templateIcon ? _self.templateIcon : templateIcon // ignore: cast_nullable_to_non_nullable
as String?,expectedStress: null == expectedStress ? _self.expectedStress : expectedStress // ignore: cast_nullable_to_non_nullable
as double,currentStress: null == currentStress ? _self.currentStress : currentStress // ignore: cast_nullable_to_non_nullable
as double,resultingTotalStress: null == resultingTotalStress ? _self.resultingTotalStress : resultingTotalStress // ignore: cast_nullable_to_non_nullable
as double,muscleReadiness: null == muscleReadiness ? _self.muscleReadiness : muscleReadiness // ignore: cast_nullable_to_non_nullable
as Map<String, MuscleReadinessData>,primaryMuscles: null == primaryMuscles ? _self.primaryMuscles : primaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryMuscles: null == secondaryMuscles ? _self.secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,underRecoveredMuscles: null == underRecoveredMuscles ? _self.underRecoveredMuscles : underRecoveredMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,fatiguedMuscles: null == fatiguedMuscles ? _self.fatiguedMuscles : fatiguedMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as TemplateRecommendation,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,optimalityScore: null == optimalityScore ? _self.optimalityScore : optimalityScore // ignore: cast_nullable_to_non_nullable
as double,sleepDataUsed: null == sleepDataUsed ? _self.sleepDataUsed : sleepDataUsed // ignore: cast_nullable_to_non_nullable
as bool,hrvDataUsed: null == hrvDataUsed ? _self.hrvDataUsed : hrvDataUsed // ignore: cast_nullable_to_non_nullable
as bool,sleepHoursLastNight: freezed == sleepHoursLastNight ? _self.sleepHoursLastNight : sleepHoursLastNight // ignore: cast_nullable_to_non_nullable
as double?,hrvMs: freezed == hrvMs ? _self.hrvMs : hrvMs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateStressAnalysis].
extension TemplateStressAnalysisPatterns on TemplateStressAnalysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateStressAnalysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateStressAnalysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateStressAnalysis value)  $default,){
final _that = this;
switch (_that) {
case _TemplateStressAnalysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateStressAnalysis value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateStressAnalysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String templateId,  String templateName,  String? templateIcon,  double expectedStress,  double currentStress,  double resultingTotalStress,  Map<String, MuscleReadinessData> muscleReadiness,  List<String> primaryMuscles,  List<String> secondaryMuscles,  List<String> underRecoveredMuscles,  List<String> fatiguedMuscles,  TemplateRecommendation recommendation,  String rationale,  double optimalityScore,  bool sleepDataUsed,  bool hrvDataUsed,  double? sleepHoursLastNight,  double? hrvMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateStressAnalysis() when $default != null:
return $default(_that.templateId,_that.templateName,_that.templateIcon,_that.expectedStress,_that.currentStress,_that.resultingTotalStress,_that.muscleReadiness,_that.primaryMuscles,_that.secondaryMuscles,_that.underRecoveredMuscles,_that.fatiguedMuscles,_that.recommendation,_that.rationale,_that.optimalityScore,_that.sleepDataUsed,_that.hrvDataUsed,_that.sleepHoursLastNight,_that.hrvMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String templateId,  String templateName,  String? templateIcon,  double expectedStress,  double currentStress,  double resultingTotalStress,  Map<String, MuscleReadinessData> muscleReadiness,  List<String> primaryMuscles,  List<String> secondaryMuscles,  List<String> underRecoveredMuscles,  List<String> fatiguedMuscles,  TemplateRecommendation recommendation,  String rationale,  double optimalityScore,  bool sleepDataUsed,  bool hrvDataUsed,  double? sleepHoursLastNight,  double? hrvMs)  $default,) {final _that = this;
switch (_that) {
case _TemplateStressAnalysis():
return $default(_that.templateId,_that.templateName,_that.templateIcon,_that.expectedStress,_that.currentStress,_that.resultingTotalStress,_that.muscleReadiness,_that.primaryMuscles,_that.secondaryMuscles,_that.underRecoveredMuscles,_that.fatiguedMuscles,_that.recommendation,_that.rationale,_that.optimalityScore,_that.sleepDataUsed,_that.hrvDataUsed,_that.sleepHoursLastNight,_that.hrvMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String templateId,  String templateName,  String? templateIcon,  double expectedStress,  double currentStress,  double resultingTotalStress,  Map<String, MuscleReadinessData> muscleReadiness,  List<String> primaryMuscles,  List<String> secondaryMuscles,  List<String> underRecoveredMuscles,  List<String> fatiguedMuscles,  TemplateRecommendation recommendation,  String rationale,  double optimalityScore,  bool sleepDataUsed,  bool hrvDataUsed,  double? sleepHoursLastNight,  double? hrvMs)?  $default,) {final _that = this;
switch (_that) {
case _TemplateStressAnalysis() when $default != null:
return $default(_that.templateId,_that.templateName,_that.templateIcon,_that.expectedStress,_that.currentStress,_that.resultingTotalStress,_that.muscleReadiness,_that.primaryMuscles,_that.secondaryMuscles,_that.underRecoveredMuscles,_that.fatiguedMuscles,_that.recommendation,_that.rationale,_that.optimalityScore,_that.sleepDataUsed,_that.hrvDataUsed,_that.sleepHoursLastNight,_that.hrvMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateStressAnalysis extends TemplateStressAnalysis {
  const _TemplateStressAnalysis({required this.templateId, required this.templateName, this.templateIcon, required this.expectedStress, required this.currentStress, required this.resultingTotalStress, required final  Map<String, MuscleReadinessData> muscleReadiness, required final  List<String> primaryMuscles, required final  List<String> secondaryMuscles, required final  List<String> underRecoveredMuscles, required final  List<String> fatiguedMuscles, required this.recommendation, required this.rationale, required this.optimalityScore, this.sleepDataUsed = false, this.hrvDataUsed = false, this.sleepHoursLastNight, this.hrvMs}): _muscleReadiness = muscleReadiness,_primaryMuscles = primaryMuscles,_secondaryMuscles = secondaryMuscles,_underRecoveredMuscles = underRecoveredMuscles,_fatiguedMuscles = fatiguedMuscles,super._();
  factory _TemplateStressAnalysis.fromJson(Map<String, dynamic> json) => _$TemplateStressAnalysisFromJson(json);

/// Template ID
@override final  String templateId;
/// Template name for display
@override final  String templateName;
/// Template icon (if set)
@override final  String? templateIcon;
/// Stress this template would add (0-100)
@override final  double expectedStress;
/// Current stress level before workout
@override final  double currentStress;
/// Resulting total stress after workout (current + expected)
@override final  double resultingTotalStress;
/// Readiness data for each muscle involved
 final  Map<String, MuscleReadinessData> _muscleReadiness;
/// Readiness data for each muscle involved
@override Map<String, MuscleReadinessData> get muscleReadiness {
  if (_muscleReadiness is EqualUnmodifiableMapView) return _muscleReadiness;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_muscleReadiness);
}

/// Primary muscles targeted by this template
 final  List<String> _primaryMuscles;
/// Primary muscles targeted by this template
@override List<String> get primaryMuscles {
  if (_primaryMuscles is EqualUnmodifiableListView) return _primaryMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryMuscles);
}

/// Secondary muscles targeted by this template
 final  List<String> _secondaryMuscles;
/// Secondary muscles targeted by this template
@override List<String> get secondaryMuscles {
  if (_secondaryMuscles is EqualUnmodifiableListView) return _secondaryMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryMuscles);
}

/// Under-recovered muscles that would be stressed
 final  List<String> _underRecoveredMuscles;
/// Under-recovered muscles that would be stressed
@override List<String> get underRecoveredMuscles {
  if (_underRecoveredMuscles is EqualUnmodifiableListView) return _underRecoveredMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_underRecoveredMuscles);
}

/// Fatigued muscles (should avoid)
 final  List<String> _fatiguedMuscles;
/// Fatigued muscles (should avoid)
@override List<String> get fatiguedMuscles {
  if (_fatiguedMuscles is EqualUnmodifiableListView) return _fatiguedMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fatiguedMuscles);
}

/// Overall recommendation
@override final  TemplateRecommendation recommendation;
/// Human-readable rationale
@override final  String rationale;
/// Optimality score (0-100) - higher is better
@override final  double optimalityScore;
// === FACTORS THAT INFLUENCED THE RECOMMENDATION ===
/// Whether sleep data was considered
@override@JsonKey() final  bool sleepDataUsed;
/// Whether HRV data was considered
@override@JsonKey() final  bool hrvDataUsed;
/// Sleep hours if available
@override final  double? sleepHoursLastNight;
/// HRV if available (ms)
@override final  double? hrvMs;

/// Create a copy of TemplateStressAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateStressAnalysisCopyWith<_TemplateStressAnalysis> get copyWith => __$TemplateStressAnalysisCopyWithImpl<_TemplateStressAnalysis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateStressAnalysisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateStressAnalysis&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.templateIcon, templateIcon) || other.templateIcon == templateIcon)&&(identical(other.expectedStress, expectedStress) || other.expectedStress == expectedStress)&&(identical(other.currentStress, currentStress) || other.currentStress == currentStress)&&(identical(other.resultingTotalStress, resultingTotalStress) || other.resultingTotalStress == resultingTotalStress)&&const DeepCollectionEquality().equals(other._muscleReadiness, _muscleReadiness)&&const DeepCollectionEquality().equals(other._primaryMuscles, _primaryMuscles)&&const DeepCollectionEquality().equals(other._secondaryMuscles, _secondaryMuscles)&&const DeepCollectionEquality().equals(other._underRecoveredMuscles, _underRecoveredMuscles)&&const DeepCollectionEquality().equals(other._fatiguedMuscles, _fatiguedMuscles)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&(identical(other.optimalityScore, optimalityScore) || other.optimalityScore == optimalityScore)&&(identical(other.sleepDataUsed, sleepDataUsed) || other.sleepDataUsed == sleepDataUsed)&&(identical(other.hrvDataUsed, hrvDataUsed) || other.hrvDataUsed == hrvDataUsed)&&(identical(other.sleepHoursLastNight, sleepHoursLastNight) || other.sleepHoursLastNight == sleepHoursLastNight)&&(identical(other.hrvMs, hrvMs) || other.hrvMs == hrvMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateId,templateName,templateIcon,expectedStress,currentStress,resultingTotalStress,const DeepCollectionEquality().hash(_muscleReadiness),const DeepCollectionEquality().hash(_primaryMuscles),const DeepCollectionEquality().hash(_secondaryMuscles),const DeepCollectionEquality().hash(_underRecoveredMuscles),const DeepCollectionEquality().hash(_fatiguedMuscles),recommendation,rationale,optimalityScore,sleepDataUsed,hrvDataUsed,sleepHoursLastNight,hrvMs);

@override
String toString() {
  return 'TemplateStressAnalysis(templateId: $templateId, templateName: $templateName, templateIcon: $templateIcon, expectedStress: $expectedStress, currentStress: $currentStress, resultingTotalStress: $resultingTotalStress, muscleReadiness: $muscleReadiness, primaryMuscles: $primaryMuscles, secondaryMuscles: $secondaryMuscles, underRecoveredMuscles: $underRecoveredMuscles, fatiguedMuscles: $fatiguedMuscles, recommendation: $recommendation, rationale: $rationale, optimalityScore: $optimalityScore, sleepDataUsed: $sleepDataUsed, hrvDataUsed: $hrvDataUsed, sleepHoursLastNight: $sleepHoursLastNight, hrvMs: $hrvMs)';
}


}

/// @nodoc
abstract mixin class _$TemplateStressAnalysisCopyWith<$Res> implements $TemplateStressAnalysisCopyWith<$Res> {
  factory _$TemplateStressAnalysisCopyWith(_TemplateStressAnalysis value, $Res Function(_TemplateStressAnalysis) _then) = __$TemplateStressAnalysisCopyWithImpl;
@override @useResult
$Res call({
 String templateId, String templateName, String? templateIcon, double expectedStress, double currentStress, double resultingTotalStress, Map<String, MuscleReadinessData> muscleReadiness, List<String> primaryMuscles, List<String> secondaryMuscles, List<String> underRecoveredMuscles, List<String> fatiguedMuscles, TemplateRecommendation recommendation, String rationale, double optimalityScore, bool sleepDataUsed, bool hrvDataUsed, double? sleepHoursLastNight, double? hrvMs
});




}
/// @nodoc
class __$TemplateStressAnalysisCopyWithImpl<$Res>
    implements _$TemplateStressAnalysisCopyWith<$Res> {
  __$TemplateStressAnalysisCopyWithImpl(this._self, this._then);

  final _TemplateStressAnalysis _self;
  final $Res Function(_TemplateStressAnalysis) _then;

/// Create a copy of TemplateStressAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateId = null,Object? templateName = null,Object? templateIcon = freezed,Object? expectedStress = null,Object? currentStress = null,Object? resultingTotalStress = null,Object? muscleReadiness = null,Object? primaryMuscles = null,Object? secondaryMuscles = null,Object? underRecoveredMuscles = null,Object? fatiguedMuscles = null,Object? recommendation = null,Object? rationale = null,Object? optimalityScore = null,Object? sleepDataUsed = null,Object? hrvDataUsed = null,Object? sleepHoursLastNight = freezed,Object? hrvMs = freezed,}) {
  return _then(_TemplateStressAnalysis(
templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,templateIcon: freezed == templateIcon ? _self.templateIcon : templateIcon // ignore: cast_nullable_to_non_nullable
as String?,expectedStress: null == expectedStress ? _self.expectedStress : expectedStress // ignore: cast_nullable_to_non_nullable
as double,currentStress: null == currentStress ? _self.currentStress : currentStress // ignore: cast_nullable_to_non_nullable
as double,resultingTotalStress: null == resultingTotalStress ? _self.resultingTotalStress : resultingTotalStress // ignore: cast_nullable_to_non_nullable
as double,muscleReadiness: null == muscleReadiness ? _self._muscleReadiness : muscleReadiness // ignore: cast_nullable_to_non_nullable
as Map<String, MuscleReadinessData>,primaryMuscles: null == primaryMuscles ? _self._primaryMuscles : primaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryMuscles: null == secondaryMuscles ? _self._secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,underRecoveredMuscles: null == underRecoveredMuscles ? _self._underRecoveredMuscles : underRecoveredMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,fatiguedMuscles: null == fatiguedMuscles ? _self._fatiguedMuscles : fatiguedMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as TemplateRecommendation,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,optimalityScore: null == optimalityScore ? _self.optimalityScore : optimalityScore // ignore: cast_nullable_to_non_nullable
as double,sleepDataUsed: null == sleepDataUsed ? _self.sleepDataUsed : sleepDataUsed // ignore: cast_nullable_to_non_nullable
as bool,hrvDataUsed: null == hrvDataUsed ? _self.hrvDataUsed : hrvDataUsed // ignore: cast_nullable_to_non_nullable
as bool,sleepHoursLastNight: freezed == sleepHoursLastNight ? _self.sleepHoursLastNight : sleepHoursLastNight // ignore: cast_nullable_to_non_nullable
as double?,hrvMs: freezed == hrvMs ? _self.hrvMs : hrvMs // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
