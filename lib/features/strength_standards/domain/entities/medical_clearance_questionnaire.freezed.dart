// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_clearance_questionnaire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicalClearanceQuestionnaire {

// Core PAR-Q+ questions (simplified for app context)
/// Has doctor ever said you have heart condition?
 bool get hasHeartCondition;/// Do you feel pain in chest during physical activity?
 bool get hasChestPain;/// In past month, chest pain when NOT doing physical activity?
 bool get hasChestPainAtRest;/// Do you lose balance because of dizziness or consciousness?
 bool get hasDizzinessOrFainting;/// Bone or joint problem that could worsen with activity?
 bool get hasBoneJointProblem;/// Currently taking medication for blood pressure or heart?
 bool get takesHeartMedication;/// Any other reason you should not do physical activity?
 bool get hasOtherMedicalReason;// Additional ACSM screening
/// Age ≥45 for men, ≥55 for women (higher risk)
 bool get isHighRiskAge;/// Family history cardiovascular disease before age 55
 bool get hasFamilyHistory;/// Currently smoke or quit within 6 months
 bool get currentSmoker;/// BMI ≥30 or waist >102cm (men) or >88cm (women)
 bool get isObese;/// Diabetes (Type 1 or 2)
 bool get hasDiabetes;/// High blood pressure (≥140/90 or on medication)
 bool get hasHighBloodPressure;// Metadata
 DateTime? get completedAt; bool get userAcknowledgedRisks;
/// Create a copy of MedicalClearanceQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicalClearanceQuestionnaireCopyWith<MedicalClearanceQuestionnaire> get copyWith => _$MedicalClearanceQuestionnaireCopyWithImpl<MedicalClearanceQuestionnaire>(this as MedicalClearanceQuestionnaire, _$identity);

  /// Serializes this MedicalClearanceQuestionnaire to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicalClearanceQuestionnaire&&(identical(other.hasHeartCondition, hasHeartCondition) || other.hasHeartCondition == hasHeartCondition)&&(identical(other.hasChestPain, hasChestPain) || other.hasChestPain == hasChestPain)&&(identical(other.hasChestPainAtRest, hasChestPainAtRest) || other.hasChestPainAtRest == hasChestPainAtRest)&&(identical(other.hasDizzinessOrFainting, hasDizzinessOrFainting) || other.hasDizzinessOrFainting == hasDizzinessOrFainting)&&(identical(other.hasBoneJointProblem, hasBoneJointProblem) || other.hasBoneJointProblem == hasBoneJointProblem)&&(identical(other.takesHeartMedication, takesHeartMedication) || other.takesHeartMedication == takesHeartMedication)&&(identical(other.hasOtherMedicalReason, hasOtherMedicalReason) || other.hasOtherMedicalReason == hasOtherMedicalReason)&&(identical(other.isHighRiskAge, isHighRiskAge) || other.isHighRiskAge == isHighRiskAge)&&(identical(other.hasFamilyHistory, hasFamilyHistory) || other.hasFamilyHistory == hasFamilyHistory)&&(identical(other.currentSmoker, currentSmoker) || other.currentSmoker == currentSmoker)&&(identical(other.isObese, isObese) || other.isObese == isObese)&&(identical(other.hasDiabetes, hasDiabetes) || other.hasDiabetes == hasDiabetes)&&(identical(other.hasHighBloodPressure, hasHighBloodPressure) || other.hasHighBloodPressure == hasHighBloodPressure)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.userAcknowledgedRisks, userAcknowledgedRisks) || other.userAcknowledgedRisks == userAcknowledgedRisks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasHeartCondition,hasChestPain,hasChestPainAtRest,hasDizzinessOrFainting,hasBoneJointProblem,takesHeartMedication,hasOtherMedicalReason,isHighRiskAge,hasFamilyHistory,currentSmoker,isObese,hasDiabetes,hasHighBloodPressure,completedAt,userAcknowledgedRisks);

@override
String toString() {
  return 'MedicalClearanceQuestionnaire(hasHeartCondition: $hasHeartCondition, hasChestPain: $hasChestPain, hasChestPainAtRest: $hasChestPainAtRest, hasDizzinessOrFainting: $hasDizzinessOrFainting, hasBoneJointProblem: $hasBoneJointProblem, takesHeartMedication: $takesHeartMedication, hasOtherMedicalReason: $hasOtherMedicalReason, isHighRiskAge: $isHighRiskAge, hasFamilyHistory: $hasFamilyHistory, currentSmoker: $currentSmoker, isObese: $isObese, hasDiabetes: $hasDiabetes, hasHighBloodPressure: $hasHighBloodPressure, completedAt: $completedAt, userAcknowledgedRisks: $userAcknowledgedRisks)';
}


}

/// @nodoc
abstract mixin class $MedicalClearanceQuestionnaireCopyWith<$Res>  {
  factory $MedicalClearanceQuestionnaireCopyWith(MedicalClearanceQuestionnaire value, $Res Function(MedicalClearanceQuestionnaire) _then) = _$MedicalClearanceQuestionnaireCopyWithImpl;
@useResult
$Res call({
 bool hasHeartCondition, bool hasChestPain, bool hasChestPainAtRest, bool hasDizzinessOrFainting, bool hasBoneJointProblem, bool takesHeartMedication, bool hasOtherMedicalReason, bool isHighRiskAge, bool hasFamilyHistory, bool currentSmoker, bool isObese, bool hasDiabetes, bool hasHighBloodPressure, DateTime? completedAt, bool userAcknowledgedRisks
});




}
/// @nodoc
class _$MedicalClearanceQuestionnaireCopyWithImpl<$Res>
    implements $MedicalClearanceQuestionnaireCopyWith<$Res> {
  _$MedicalClearanceQuestionnaireCopyWithImpl(this._self, this._then);

  final MedicalClearanceQuestionnaire _self;
  final $Res Function(MedicalClearanceQuestionnaire) _then;

/// Create a copy of MedicalClearanceQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasHeartCondition = null,Object? hasChestPain = null,Object? hasChestPainAtRest = null,Object? hasDizzinessOrFainting = null,Object? hasBoneJointProblem = null,Object? takesHeartMedication = null,Object? hasOtherMedicalReason = null,Object? isHighRiskAge = null,Object? hasFamilyHistory = null,Object? currentSmoker = null,Object? isObese = null,Object? hasDiabetes = null,Object? hasHighBloodPressure = null,Object? completedAt = freezed,Object? userAcknowledgedRisks = null,}) {
  return _then(_self.copyWith(
hasHeartCondition: null == hasHeartCondition ? _self.hasHeartCondition : hasHeartCondition // ignore: cast_nullable_to_non_nullable
as bool,hasChestPain: null == hasChestPain ? _self.hasChestPain : hasChestPain // ignore: cast_nullable_to_non_nullable
as bool,hasChestPainAtRest: null == hasChestPainAtRest ? _self.hasChestPainAtRest : hasChestPainAtRest // ignore: cast_nullable_to_non_nullable
as bool,hasDizzinessOrFainting: null == hasDizzinessOrFainting ? _self.hasDizzinessOrFainting : hasDizzinessOrFainting // ignore: cast_nullable_to_non_nullable
as bool,hasBoneJointProblem: null == hasBoneJointProblem ? _self.hasBoneJointProblem : hasBoneJointProblem // ignore: cast_nullable_to_non_nullable
as bool,takesHeartMedication: null == takesHeartMedication ? _self.takesHeartMedication : takesHeartMedication // ignore: cast_nullable_to_non_nullable
as bool,hasOtherMedicalReason: null == hasOtherMedicalReason ? _self.hasOtherMedicalReason : hasOtherMedicalReason // ignore: cast_nullable_to_non_nullable
as bool,isHighRiskAge: null == isHighRiskAge ? _self.isHighRiskAge : isHighRiskAge // ignore: cast_nullable_to_non_nullable
as bool,hasFamilyHistory: null == hasFamilyHistory ? _self.hasFamilyHistory : hasFamilyHistory // ignore: cast_nullable_to_non_nullable
as bool,currentSmoker: null == currentSmoker ? _self.currentSmoker : currentSmoker // ignore: cast_nullable_to_non_nullable
as bool,isObese: null == isObese ? _self.isObese : isObese // ignore: cast_nullable_to_non_nullable
as bool,hasDiabetes: null == hasDiabetes ? _self.hasDiabetes : hasDiabetes // ignore: cast_nullable_to_non_nullable
as bool,hasHighBloodPressure: null == hasHighBloodPressure ? _self.hasHighBloodPressure : hasHighBloodPressure // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userAcknowledgedRisks: null == userAcknowledgedRisks ? _self.userAcknowledgedRisks : userAcknowledgedRisks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicalClearanceQuestionnaire].
extension MedicalClearanceQuestionnairePatterns on MedicalClearanceQuestionnaire {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicalClearanceQuestionnaire value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicalClearanceQuestionnaire() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicalClearanceQuestionnaire value)  $default,){
final _that = this;
switch (_that) {
case _MedicalClearanceQuestionnaire():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicalClearanceQuestionnaire value)?  $default,){
final _that = this;
switch (_that) {
case _MedicalClearanceQuestionnaire() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasHeartCondition,  bool hasChestPain,  bool hasChestPainAtRest,  bool hasDizzinessOrFainting,  bool hasBoneJointProblem,  bool takesHeartMedication,  bool hasOtherMedicalReason,  bool isHighRiskAge,  bool hasFamilyHistory,  bool currentSmoker,  bool isObese,  bool hasDiabetes,  bool hasHighBloodPressure,  DateTime? completedAt,  bool userAcknowledgedRisks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicalClearanceQuestionnaire() when $default != null:
return $default(_that.hasHeartCondition,_that.hasChestPain,_that.hasChestPainAtRest,_that.hasDizzinessOrFainting,_that.hasBoneJointProblem,_that.takesHeartMedication,_that.hasOtherMedicalReason,_that.isHighRiskAge,_that.hasFamilyHistory,_that.currentSmoker,_that.isObese,_that.hasDiabetes,_that.hasHighBloodPressure,_that.completedAt,_that.userAcknowledgedRisks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasHeartCondition,  bool hasChestPain,  bool hasChestPainAtRest,  bool hasDizzinessOrFainting,  bool hasBoneJointProblem,  bool takesHeartMedication,  bool hasOtherMedicalReason,  bool isHighRiskAge,  bool hasFamilyHistory,  bool currentSmoker,  bool isObese,  bool hasDiabetes,  bool hasHighBloodPressure,  DateTime? completedAt,  bool userAcknowledgedRisks)  $default,) {final _that = this;
switch (_that) {
case _MedicalClearanceQuestionnaire():
return $default(_that.hasHeartCondition,_that.hasChestPain,_that.hasChestPainAtRest,_that.hasDizzinessOrFainting,_that.hasBoneJointProblem,_that.takesHeartMedication,_that.hasOtherMedicalReason,_that.isHighRiskAge,_that.hasFamilyHistory,_that.currentSmoker,_that.isObese,_that.hasDiabetes,_that.hasHighBloodPressure,_that.completedAt,_that.userAcknowledgedRisks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasHeartCondition,  bool hasChestPain,  bool hasChestPainAtRest,  bool hasDizzinessOrFainting,  bool hasBoneJointProblem,  bool takesHeartMedication,  bool hasOtherMedicalReason,  bool isHighRiskAge,  bool hasFamilyHistory,  bool currentSmoker,  bool isObese,  bool hasDiabetes,  bool hasHighBloodPressure,  DateTime? completedAt,  bool userAcknowledgedRisks)?  $default,) {final _that = this;
switch (_that) {
case _MedicalClearanceQuestionnaire() when $default != null:
return $default(_that.hasHeartCondition,_that.hasChestPain,_that.hasChestPainAtRest,_that.hasDizzinessOrFainting,_that.hasBoneJointProblem,_that.takesHeartMedication,_that.hasOtherMedicalReason,_that.isHighRiskAge,_that.hasFamilyHistory,_that.currentSmoker,_that.isObese,_that.hasDiabetes,_that.hasHighBloodPressure,_that.completedAt,_that.userAcknowledgedRisks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicalClearanceQuestionnaire implements MedicalClearanceQuestionnaire {
  const _MedicalClearanceQuestionnaire({this.hasHeartCondition = false, this.hasChestPain = false, this.hasChestPainAtRest = false, this.hasDizzinessOrFainting = false, this.hasBoneJointProblem = false, this.takesHeartMedication = false, this.hasOtherMedicalReason = false, this.isHighRiskAge = false, this.hasFamilyHistory = false, this.currentSmoker = false, this.isObese = false, this.hasDiabetes = false, this.hasHighBloodPressure = false, this.completedAt, this.userAcknowledgedRisks = false});
  factory _MedicalClearanceQuestionnaire.fromJson(Map<String, dynamic> json) => _$MedicalClearanceQuestionnaireFromJson(json);

// Core PAR-Q+ questions (simplified for app context)
/// Has doctor ever said you have heart condition?
@override@JsonKey() final  bool hasHeartCondition;
/// Do you feel pain in chest during physical activity?
@override@JsonKey() final  bool hasChestPain;
/// In past month, chest pain when NOT doing physical activity?
@override@JsonKey() final  bool hasChestPainAtRest;
/// Do you lose balance because of dizziness or consciousness?
@override@JsonKey() final  bool hasDizzinessOrFainting;
/// Bone or joint problem that could worsen with activity?
@override@JsonKey() final  bool hasBoneJointProblem;
/// Currently taking medication for blood pressure or heart?
@override@JsonKey() final  bool takesHeartMedication;
/// Any other reason you should not do physical activity?
@override@JsonKey() final  bool hasOtherMedicalReason;
// Additional ACSM screening
/// Age ≥45 for men, ≥55 for women (higher risk)
@override@JsonKey() final  bool isHighRiskAge;
/// Family history cardiovascular disease before age 55
@override@JsonKey() final  bool hasFamilyHistory;
/// Currently smoke or quit within 6 months
@override@JsonKey() final  bool currentSmoker;
/// BMI ≥30 or waist >102cm (men) or >88cm (women)
@override@JsonKey() final  bool isObese;
/// Diabetes (Type 1 or 2)
@override@JsonKey() final  bool hasDiabetes;
/// High blood pressure (≥140/90 or on medication)
@override@JsonKey() final  bool hasHighBloodPressure;
// Metadata
@override final  DateTime? completedAt;
@override@JsonKey() final  bool userAcknowledgedRisks;

/// Create a copy of MedicalClearanceQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicalClearanceQuestionnaireCopyWith<_MedicalClearanceQuestionnaire> get copyWith => __$MedicalClearanceQuestionnaireCopyWithImpl<_MedicalClearanceQuestionnaire>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicalClearanceQuestionnaireToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicalClearanceQuestionnaire&&(identical(other.hasHeartCondition, hasHeartCondition) || other.hasHeartCondition == hasHeartCondition)&&(identical(other.hasChestPain, hasChestPain) || other.hasChestPain == hasChestPain)&&(identical(other.hasChestPainAtRest, hasChestPainAtRest) || other.hasChestPainAtRest == hasChestPainAtRest)&&(identical(other.hasDizzinessOrFainting, hasDizzinessOrFainting) || other.hasDizzinessOrFainting == hasDizzinessOrFainting)&&(identical(other.hasBoneJointProblem, hasBoneJointProblem) || other.hasBoneJointProblem == hasBoneJointProblem)&&(identical(other.takesHeartMedication, takesHeartMedication) || other.takesHeartMedication == takesHeartMedication)&&(identical(other.hasOtherMedicalReason, hasOtherMedicalReason) || other.hasOtherMedicalReason == hasOtherMedicalReason)&&(identical(other.isHighRiskAge, isHighRiskAge) || other.isHighRiskAge == isHighRiskAge)&&(identical(other.hasFamilyHistory, hasFamilyHistory) || other.hasFamilyHistory == hasFamilyHistory)&&(identical(other.currentSmoker, currentSmoker) || other.currentSmoker == currentSmoker)&&(identical(other.isObese, isObese) || other.isObese == isObese)&&(identical(other.hasDiabetes, hasDiabetes) || other.hasDiabetes == hasDiabetes)&&(identical(other.hasHighBloodPressure, hasHighBloodPressure) || other.hasHighBloodPressure == hasHighBloodPressure)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.userAcknowledgedRisks, userAcknowledgedRisks) || other.userAcknowledgedRisks == userAcknowledgedRisks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasHeartCondition,hasChestPain,hasChestPainAtRest,hasDizzinessOrFainting,hasBoneJointProblem,takesHeartMedication,hasOtherMedicalReason,isHighRiskAge,hasFamilyHistory,currentSmoker,isObese,hasDiabetes,hasHighBloodPressure,completedAt,userAcknowledgedRisks);

@override
String toString() {
  return 'MedicalClearanceQuestionnaire(hasHeartCondition: $hasHeartCondition, hasChestPain: $hasChestPain, hasChestPainAtRest: $hasChestPainAtRest, hasDizzinessOrFainting: $hasDizzinessOrFainting, hasBoneJointProblem: $hasBoneJointProblem, takesHeartMedication: $takesHeartMedication, hasOtherMedicalReason: $hasOtherMedicalReason, isHighRiskAge: $isHighRiskAge, hasFamilyHistory: $hasFamilyHistory, currentSmoker: $currentSmoker, isObese: $isObese, hasDiabetes: $hasDiabetes, hasHighBloodPressure: $hasHighBloodPressure, completedAt: $completedAt, userAcknowledgedRisks: $userAcknowledgedRisks)';
}


}

/// @nodoc
abstract mixin class _$MedicalClearanceQuestionnaireCopyWith<$Res> implements $MedicalClearanceQuestionnaireCopyWith<$Res> {
  factory _$MedicalClearanceQuestionnaireCopyWith(_MedicalClearanceQuestionnaire value, $Res Function(_MedicalClearanceQuestionnaire) _then) = __$MedicalClearanceQuestionnaireCopyWithImpl;
@override @useResult
$Res call({
 bool hasHeartCondition, bool hasChestPain, bool hasChestPainAtRest, bool hasDizzinessOrFainting, bool hasBoneJointProblem, bool takesHeartMedication, bool hasOtherMedicalReason, bool isHighRiskAge, bool hasFamilyHistory, bool currentSmoker, bool isObese, bool hasDiabetes, bool hasHighBloodPressure, DateTime? completedAt, bool userAcknowledgedRisks
});




}
/// @nodoc
class __$MedicalClearanceQuestionnaireCopyWithImpl<$Res>
    implements _$MedicalClearanceQuestionnaireCopyWith<$Res> {
  __$MedicalClearanceQuestionnaireCopyWithImpl(this._self, this._then);

  final _MedicalClearanceQuestionnaire _self;
  final $Res Function(_MedicalClearanceQuestionnaire) _then;

/// Create a copy of MedicalClearanceQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasHeartCondition = null,Object? hasChestPain = null,Object? hasChestPainAtRest = null,Object? hasDizzinessOrFainting = null,Object? hasBoneJointProblem = null,Object? takesHeartMedication = null,Object? hasOtherMedicalReason = null,Object? isHighRiskAge = null,Object? hasFamilyHistory = null,Object? currentSmoker = null,Object? isObese = null,Object? hasDiabetes = null,Object? hasHighBloodPressure = null,Object? completedAt = freezed,Object? userAcknowledgedRisks = null,}) {
  return _then(_MedicalClearanceQuestionnaire(
hasHeartCondition: null == hasHeartCondition ? _self.hasHeartCondition : hasHeartCondition // ignore: cast_nullable_to_non_nullable
as bool,hasChestPain: null == hasChestPain ? _self.hasChestPain : hasChestPain // ignore: cast_nullable_to_non_nullable
as bool,hasChestPainAtRest: null == hasChestPainAtRest ? _self.hasChestPainAtRest : hasChestPainAtRest // ignore: cast_nullable_to_non_nullable
as bool,hasDizzinessOrFainting: null == hasDizzinessOrFainting ? _self.hasDizzinessOrFainting : hasDizzinessOrFainting // ignore: cast_nullable_to_non_nullable
as bool,hasBoneJointProblem: null == hasBoneJointProblem ? _self.hasBoneJointProblem : hasBoneJointProblem // ignore: cast_nullable_to_non_nullable
as bool,takesHeartMedication: null == takesHeartMedication ? _self.takesHeartMedication : takesHeartMedication // ignore: cast_nullable_to_non_nullable
as bool,hasOtherMedicalReason: null == hasOtherMedicalReason ? _self.hasOtherMedicalReason : hasOtherMedicalReason // ignore: cast_nullable_to_non_nullable
as bool,isHighRiskAge: null == isHighRiskAge ? _self.isHighRiskAge : isHighRiskAge // ignore: cast_nullable_to_non_nullable
as bool,hasFamilyHistory: null == hasFamilyHistory ? _self.hasFamilyHistory : hasFamilyHistory // ignore: cast_nullable_to_non_nullable
as bool,currentSmoker: null == currentSmoker ? _self.currentSmoker : currentSmoker // ignore: cast_nullable_to_non_nullable
as bool,isObese: null == isObese ? _self.isObese : isObese // ignore: cast_nullable_to_non_nullable
as bool,hasDiabetes: null == hasDiabetes ? _self.hasDiabetes : hasDiabetes // ignore: cast_nullable_to_non_nullable
as bool,hasHighBloodPressure: null == hasHighBloodPressure ? _self.hasHighBloodPressure : hasHighBloodPressure // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userAcknowledgedRisks: null == userAcknowledgedRisks ? _self.userAcknowledgedRisks : userAcknowledgedRisks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
