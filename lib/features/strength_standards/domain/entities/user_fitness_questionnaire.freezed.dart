// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_fitness_questionnaire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserFitnessQuestionnaire {

// Step 1: Demographics
/// User's bodyweight in kg
 double get bodyweightKg;/// User's age
 int get age;/// User's height in cm
 double get heightCm;/// User's biological sex (affects strength standards)
 BiologicalSex get sex;// Step 2: Experience Level
/// Self-reported experience level
 ExperienceLevel get experienceLevel;/// Months of consistent training (optional, helps validate experience level)
 int? get monthsOfTraining;// Step 3: Max Lifts (Optional - improves accuracy)
/// Bench press 1RM or estimated from reps (kg)
 double? get benchPressMax;/// Squat 1RM or estimated from reps (kg)
 double? get squatMax;/// Deadlift 1RM or estimated from reps (kg)
 double? get deadliftMax;/// Overhead press 1RM or estimated from reps (kg)
 double? get overheadPressMax;// Step 4: Lifestyle Factors
/// Training goal affects weight suggestion (hypertrophy, strength, endurance)
 TrainingGoal get trainingGoal;/// Injury history or limitations (affects conservative suggestions)
 bool get hasInjuryHistory;/// Specific injury details (Sciascia 2015: detailed screening recommended)
 InjuryDetails? get injuryDetails;/// Current pain or discomfort during training (0-10 scale)
 int get currentPainLevel;// Step 5: Preferences
/// Prefer conservative or aggressive weight suggestions
 SuggestionStyle get suggestionStyle;/// Timestamp when questionnaire was completed
 DateTime? get completedAt;/// Whether user wants to update suggestions periodically
 bool get allowPeriodicUpdates;/// Self-reported accuracy calibration (Aandstad 2023: over-reporting bias)
/// User's honesty about their actual performance vs perceived
 SelfReportCalibration get selfReportCalibration;
/// Create a copy of UserFitnessQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFitnessQuestionnaireCopyWith<UserFitnessQuestionnaire> get copyWith => _$UserFitnessQuestionnaireCopyWithImpl<UserFitnessQuestionnaire>(this as UserFitnessQuestionnaire, _$identity);

  /// Serializes this UserFitnessQuestionnaire to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFitnessQuestionnaire&&(identical(other.bodyweightKg, bodyweightKg) || other.bodyweightKg == bodyweightKg)&&(identical(other.age, age) || other.age == age)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.monthsOfTraining, monthsOfTraining) || other.monthsOfTraining == monthsOfTraining)&&(identical(other.benchPressMax, benchPressMax) || other.benchPressMax == benchPressMax)&&(identical(other.squatMax, squatMax) || other.squatMax == squatMax)&&(identical(other.deadliftMax, deadliftMax) || other.deadliftMax == deadliftMax)&&(identical(other.overheadPressMax, overheadPressMax) || other.overheadPressMax == overheadPressMax)&&(identical(other.trainingGoal, trainingGoal) || other.trainingGoal == trainingGoal)&&(identical(other.hasInjuryHistory, hasInjuryHistory) || other.hasInjuryHistory == hasInjuryHistory)&&(identical(other.injuryDetails, injuryDetails) || other.injuryDetails == injuryDetails)&&(identical(other.currentPainLevel, currentPainLevel) || other.currentPainLevel == currentPainLevel)&&(identical(other.suggestionStyle, suggestionStyle) || other.suggestionStyle == suggestionStyle)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.allowPeriodicUpdates, allowPeriodicUpdates) || other.allowPeriodicUpdates == allowPeriodicUpdates)&&(identical(other.selfReportCalibration, selfReportCalibration) || other.selfReportCalibration == selfReportCalibration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bodyweightKg,age,heightCm,sex,experienceLevel,monthsOfTraining,benchPressMax,squatMax,deadliftMax,overheadPressMax,trainingGoal,hasInjuryHistory,injuryDetails,currentPainLevel,suggestionStyle,completedAt,allowPeriodicUpdates,selfReportCalibration);

@override
String toString() {
  return 'UserFitnessQuestionnaire(bodyweightKg: $bodyweightKg, age: $age, heightCm: $heightCm, sex: $sex, experienceLevel: $experienceLevel, monthsOfTraining: $monthsOfTraining, benchPressMax: $benchPressMax, squatMax: $squatMax, deadliftMax: $deadliftMax, overheadPressMax: $overheadPressMax, trainingGoal: $trainingGoal, hasInjuryHistory: $hasInjuryHistory, injuryDetails: $injuryDetails, currentPainLevel: $currentPainLevel, suggestionStyle: $suggestionStyle, completedAt: $completedAt, allowPeriodicUpdates: $allowPeriodicUpdates, selfReportCalibration: $selfReportCalibration)';
}


}

/// @nodoc
abstract mixin class $UserFitnessQuestionnaireCopyWith<$Res>  {
  factory $UserFitnessQuestionnaireCopyWith(UserFitnessQuestionnaire value, $Res Function(UserFitnessQuestionnaire) _then) = _$UserFitnessQuestionnaireCopyWithImpl;
@useResult
$Res call({
 double bodyweightKg, int age, double heightCm, BiologicalSex sex, ExperienceLevel experienceLevel, int? monthsOfTraining, double? benchPressMax, double? squatMax, double? deadliftMax, double? overheadPressMax, TrainingGoal trainingGoal, bool hasInjuryHistory, InjuryDetails? injuryDetails, int currentPainLevel, SuggestionStyle suggestionStyle, DateTime? completedAt, bool allowPeriodicUpdates, SelfReportCalibration selfReportCalibration
});


$InjuryDetailsCopyWith<$Res>? get injuryDetails;

}
/// @nodoc
class _$UserFitnessQuestionnaireCopyWithImpl<$Res>
    implements $UserFitnessQuestionnaireCopyWith<$Res> {
  _$UserFitnessQuestionnaireCopyWithImpl(this._self, this._then);

  final UserFitnessQuestionnaire _self;
  final $Res Function(UserFitnessQuestionnaire) _then;

/// Create a copy of UserFitnessQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bodyweightKg = null,Object? age = null,Object? heightCm = null,Object? sex = null,Object? experienceLevel = null,Object? monthsOfTraining = freezed,Object? benchPressMax = freezed,Object? squatMax = freezed,Object? deadliftMax = freezed,Object? overheadPressMax = freezed,Object? trainingGoal = null,Object? hasInjuryHistory = null,Object? injuryDetails = freezed,Object? currentPainLevel = null,Object? suggestionStyle = null,Object? completedAt = freezed,Object? allowPeriodicUpdates = null,Object? selfReportCalibration = null,}) {
  return _then(_self.copyWith(
bodyweightKg: null == bodyweightKg ? _self.bodyweightKg : bodyweightKg // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as BiologicalSex,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,monthsOfTraining: freezed == monthsOfTraining ? _self.monthsOfTraining : monthsOfTraining // ignore: cast_nullable_to_non_nullable
as int?,benchPressMax: freezed == benchPressMax ? _self.benchPressMax : benchPressMax // ignore: cast_nullable_to_non_nullable
as double?,squatMax: freezed == squatMax ? _self.squatMax : squatMax // ignore: cast_nullable_to_non_nullable
as double?,deadliftMax: freezed == deadliftMax ? _self.deadliftMax : deadliftMax // ignore: cast_nullable_to_non_nullable
as double?,overheadPressMax: freezed == overheadPressMax ? _self.overheadPressMax : overheadPressMax // ignore: cast_nullable_to_non_nullable
as double?,trainingGoal: null == trainingGoal ? _self.trainingGoal : trainingGoal // ignore: cast_nullable_to_non_nullable
as TrainingGoal,hasInjuryHistory: null == hasInjuryHistory ? _self.hasInjuryHistory : hasInjuryHistory // ignore: cast_nullable_to_non_nullable
as bool,injuryDetails: freezed == injuryDetails ? _self.injuryDetails : injuryDetails // ignore: cast_nullable_to_non_nullable
as InjuryDetails?,currentPainLevel: null == currentPainLevel ? _self.currentPainLevel : currentPainLevel // ignore: cast_nullable_to_non_nullable
as int,suggestionStyle: null == suggestionStyle ? _self.suggestionStyle : suggestionStyle // ignore: cast_nullable_to_non_nullable
as SuggestionStyle,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allowPeriodicUpdates: null == allowPeriodicUpdates ? _self.allowPeriodicUpdates : allowPeriodicUpdates // ignore: cast_nullable_to_non_nullable
as bool,selfReportCalibration: null == selfReportCalibration ? _self.selfReportCalibration : selfReportCalibration // ignore: cast_nullable_to_non_nullable
as SelfReportCalibration,
  ));
}
/// Create a copy of UserFitnessQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryDetailsCopyWith<$Res>? get injuryDetails {
    if (_self.injuryDetails == null) {
    return null;
  }

  return $InjuryDetailsCopyWith<$Res>(_self.injuryDetails!, (value) {
    return _then(_self.copyWith(injuryDetails: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserFitnessQuestionnaire].
extension UserFitnessQuestionnairePatterns on UserFitnessQuestionnaire {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFitnessQuestionnaire value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFitnessQuestionnaire() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFitnessQuestionnaire value)  $default,){
final _that = this;
switch (_that) {
case _UserFitnessQuestionnaire():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFitnessQuestionnaire value)?  $default,){
final _that = this;
switch (_that) {
case _UserFitnessQuestionnaire() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double bodyweightKg,  int age,  double heightCm,  BiologicalSex sex,  ExperienceLevel experienceLevel,  int? monthsOfTraining,  double? benchPressMax,  double? squatMax,  double? deadliftMax,  double? overheadPressMax,  TrainingGoal trainingGoal,  bool hasInjuryHistory,  InjuryDetails? injuryDetails,  int currentPainLevel,  SuggestionStyle suggestionStyle,  DateTime? completedAt,  bool allowPeriodicUpdates,  SelfReportCalibration selfReportCalibration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFitnessQuestionnaire() when $default != null:
return $default(_that.bodyweightKg,_that.age,_that.heightCm,_that.sex,_that.experienceLevel,_that.monthsOfTraining,_that.benchPressMax,_that.squatMax,_that.deadliftMax,_that.overheadPressMax,_that.trainingGoal,_that.hasInjuryHistory,_that.injuryDetails,_that.currentPainLevel,_that.suggestionStyle,_that.completedAt,_that.allowPeriodicUpdates,_that.selfReportCalibration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double bodyweightKg,  int age,  double heightCm,  BiologicalSex sex,  ExperienceLevel experienceLevel,  int? monthsOfTraining,  double? benchPressMax,  double? squatMax,  double? deadliftMax,  double? overheadPressMax,  TrainingGoal trainingGoal,  bool hasInjuryHistory,  InjuryDetails? injuryDetails,  int currentPainLevel,  SuggestionStyle suggestionStyle,  DateTime? completedAt,  bool allowPeriodicUpdates,  SelfReportCalibration selfReportCalibration)  $default,) {final _that = this;
switch (_that) {
case _UserFitnessQuestionnaire():
return $default(_that.bodyweightKg,_that.age,_that.heightCm,_that.sex,_that.experienceLevel,_that.monthsOfTraining,_that.benchPressMax,_that.squatMax,_that.deadliftMax,_that.overheadPressMax,_that.trainingGoal,_that.hasInjuryHistory,_that.injuryDetails,_that.currentPainLevel,_that.suggestionStyle,_that.completedAt,_that.allowPeriodicUpdates,_that.selfReportCalibration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double bodyweightKg,  int age,  double heightCm,  BiologicalSex sex,  ExperienceLevel experienceLevel,  int? monthsOfTraining,  double? benchPressMax,  double? squatMax,  double? deadliftMax,  double? overheadPressMax,  TrainingGoal trainingGoal,  bool hasInjuryHistory,  InjuryDetails? injuryDetails,  int currentPainLevel,  SuggestionStyle suggestionStyle,  DateTime? completedAt,  bool allowPeriodicUpdates,  SelfReportCalibration selfReportCalibration)?  $default,) {final _that = this;
switch (_that) {
case _UserFitnessQuestionnaire() when $default != null:
return $default(_that.bodyweightKg,_that.age,_that.heightCm,_that.sex,_that.experienceLevel,_that.monthsOfTraining,_that.benchPressMax,_that.squatMax,_that.deadliftMax,_that.overheadPressMax,_that.trainingGoal,_that.hasInjuryHistory,_that.injuryDetails,_that.currentPainLevel,_that.suggestionStyle,_that.completedAt,_that.allowPeriodicUpdates,_that.selfReportCalibration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserFitnessQuestionnaire implements UserFitnessQuestionnaire {
  const _UserFitnessQuestionnaire({required this.bodyweightKg, required this.age, required this.heightCm, required this.sex, required this.experienceLevel, this.monthsOfTraining, this.benchPressMax, this.squatMax, this.deadliftMax, this.overheadPressMax, this.trainingGoal = TrainingGoal.hypertrophy, this.hasInjuryHistory = false, this.injuryDetails, this.currentPainLevel = 0, this.suggestionStyle = SuggestionStyle.balanced, this.completedAt, this.allowPeriodicUpdates = true, this.selfReportCalibration = SelfReportCalibration.realistic});
  factory _UserFitnessQuestionnaire.fromJson(Map<String, dynamic> json) => _$UserFitnessQuestionnaireFromJson(json);

// Step 1: Demographics
/// User's bodyweight in kg
@override final  double bodyweightKg;
/// User's age
@override final  int age;
/// User's height in cm
@override final  double heightCm;
/// User's biological sex (affects strength standards)
@override final  BiologicalSex sex;
// Step 2: Experience Level
/// Self-reported experience level
@override final  ExperienceLevel experienceLevel;
/// Months of consistent training (optional, helps validate experience level)
@override final  int? monthsOfTraining;
// Step 3: Max Lifts (Optional - improves accuracy)
/// Bench press 1RM or estimated from reps (kg)
@override final  double? benchPressMax;
/// Squat 1RM or estimated from reps (kg)
@override final  double? squatMax;
/// Deadlift 1RM or estimated from reps (kg)
@override final  double? deadliftMax;
/// Overhead press 1RM or estimated from reps (kg)
@override final  double? overheadPressMax;
// Step 4: Lifestyle Factors
/// Training goal affects weight suggestion (hypertrophy, strength, endurance)
@override@JsonKey() final  TrainingGoal trainingGoal;
/// Injury history or limitations (affects conservative suggestions)
@override@JsonKey() final  bool hasInjuryHistory;
/// Specific injury details (Sciascia 2015: detailed screening recommended)
@override final  InjuryDetails? injuryDetails;
/// Current pain or discomfort during training (0-10 scale)
@override@JsonKey() final  int currentPainLevel;
// Step 5: Preferences
/// Prefer conservative or aggressive weight suggestions
@override@JsonKey() final  SuggestionStyle suggestionStyle;
/// Timestamp when questionnaire was completed
@override final  DateTime? completedAt;
/// Whether user wants to update suggestions periodically
@override@JsonKey() final  bool allowPeriodicUpdates;
/// Self-reported accuracy calibration (Aandstad 2023: over-reporting bias)
/// User's honesty about their actual performance vs perceived
@override@JsonKey() final  SelfReportCalibration selfReportCalibration;

/// Create a copy of UserFitnessQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFitnessQuestionnaireCopyWith<_UserFitnessQuestionnaire> get copyWith => __$UserFitnessQuestionnaireCopyWithImpl<_UserFitnessQuestionnaire>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserFitnessQuestionnaireToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFitnessQuestionnaire&&(identical(other.bodyweightKg, bodyweightKg) || other.bodyweightKg == bodyweightKg)&&(identical(other.age, age) || other.age == age)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.monthsOfTraining, monthsOfTraining) || other.monthsOfTraining == monthsOfTraining)&&(identical(other.benchPressMax, benchPressMax) || other.benchPressMax == benchPressMax)&&(identical(other.squatMax, squatMax) || other.squatMax == squatMax)&&(identical(other.deadliftMax, deadliftMax) || other.deadliftMax == deadliftMax)&&(identical(other.overheadPressMax, overheadPressMax) || other.overheadPressMax == overheadPressMax)&&(identical(other.trainingGoal, trainingGoal) || other.trainingGoal == trainingGoal)&&(identical(other.hasInjuryHistory, hasInjuryHistory) || other.hasInjuryHistory == hasInjuryHistory)&&(identical(other.injuryDetails, injuryDetails) || other.injuryDetails == injuryDetails)&&(identical(other.currentPainLevel, currentPainLevel) || other.currentPainLevel == currentPainLevel)&&(identical(other.suggestionStyle, suggestionStyle) || other.suggestionStyle == suggestionStyle)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.allowPeriodicUpdates, allowPeriodicUpdates) || other.allowPeriodicUpdates == allowPeriodicUpdates)&&(identical(other.selfReportCalibration, selfReportCalibration) || other.selfReportCalibration == selfReportCalibration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bodyweightKg,age,heightCm,sex,experienceLevel,monthsOfTraining,benchPressMax,squatMax,deadliftMax,overheadPressMax,trainingGoal,hasInjuryHistory,injuryDetails,currentPainLevel,suggestionStyle,completedAt,allowPeriodicUpdates,selfReportCalibration);

@override
String toString() {
  return 'UserFitnessQuestionnaire(bodyweightKg: $bodyweightKg, age: $age, heightCm: $heightCm, sex: $sex, experienceLevel: $experienceLevel, monthsOfTraining: $monthsOfTraining, benchPressMax: $benchPressMax, squatMax: $squatMax, deadliftMax: $deadliftMax, overheadPressMax: $overheadPressMax, trainingGoal: $trainingGoal, hasInjuryHistory: $hasInjuryHistory, injuryDetails: $injuryDetails, currentPainLevel: $currentPainLevel, suggestionStyle: $suggestionStyle, completedAt: $completedAt, allowPeriodicUpdates: $allowPeriodicUpdates, selfReportCalibration: $selfReportCalibration)';
}


}

/// @nodoc
abstract mixin class _$UserFitnessQuestionnaireCopyWith<$Res> implements $UserFitnessQuestionnaireCopyWith<$Res> {
  factory _$UserFitnessQuestionnaireCopyWith(_UserFitnessQuestionnaire value, $Res Function(_UserFitnessQuestionnaire) _then) = __$UserFitnessQuestionnaireCopyWithImpl;
@override @useResult
$Res call({
 double bodyweightKg, int age, double heightCm, BiologicalSex sex, ExperienceLevel experienceLevel, int? monthsOfTraining, double? benchPressMax, double? squatMax, double? deadliftMax, double? overheadPressMax, TrainingGoal trainingGoal, bool hasInjuryHistory, InjuryDetails? injuryDetails, int currentPainLevel, SuggestionStyle suggestionStyle, DateTime? completedAt, bool allowPeriodicUpdates, SelfReportCalibration selfReportCalibration
});


@override $InjuryDetailsCopyWith<$Res>? get injuryDetails;

}
/// @nodoc
class __$UserFitnessQuestionnaireCopyWithImpl<$Res>
    implements _$UserFitnessQuestionnaireCopyWith<$Res> {
  __$UserFitnessQuestionnaireCopyWithImpl(this._self, this._then);

  final _UserFitnessQuestionnaire _self;
  final $Res Function(_UserFitnessQuestionnaire) _then;

/// Create a copy of UserFitnessQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bodyweightKg = null,Object? age = null,Object? heightCm = null,Object? sex = null,Object? experienceLevel = null,Object? monthsOfTraining = freezed,Object? benchPressMax = freezed,Object? squatMax = freezed,Object? deadliftMax = freezed,Object? overheadPressMax = freezed,Object? trainingGoal = null,Object? hasInjuryHistory = null,Object? injuryDetails = freezed,Object? currentPainLevel = null,Object? suggestionStyle = null,Object? completedAt = freezed,Object? allowPeriodicUpdates = null,Object? selfReportCalibration = null,}) {
  return _then(_UserFitnessQuestionnaire(
bodyweightKg: null == bodyweightKg ? _self.bodyweightKg : bodyweightKg // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as BiologicalSex,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,monthsOfTraining: freezed == monthsOfTraining ? _self.monthsOfTraining : monthsOfTraining // ignore: cast_nullable_to_non_nullable
as int?,benchPressMax: freezed == benchPressMax ? _self.benchPressMax : benchPressMax // ignore: cast_nullable_to_non_nullable
as double?,squatMax: freezed == squatMax ? _self.squatMax : squatMax // ignore: cast_nullable_to_non_nullable
as double?,deadliftMax: freezed == deadliftMax ? _self.deadliftMax : deadliftMax // ignore: cast_nullable_to_non_nullable
as double?,overheadPressMax: freezed == overheadPressMax ? _self.overheadPressMax : overheadPressMax // ignore: cast_nullable_to_non_nullable
as double?,trainingGoal: null == trainingGoal ? _self.trainingGoal : trainingGoal // ignore: cast_nullable_to_non_nullable
as TrainingGoal,hasInjuryHistory: null == hasInjuryHistory ? _self.hasInjuryHistory : hasInjuryHistory // ignore: cast_nullable_to_non_nullable
as bool,injuryDetails: freezed == injuryDetails ? _self.injuryDetails : injuryDetails // ignore: cast_nullable_to_non_nullable
as InjuryDetails?,currentPainLevel: null == currentPainLevel ? _self.currentPainLevel : currentPainLevel // ignore: cast_nullable_to_non_nullable
as int,suggestionStyle: null == suggestionStyle ? _self.suggestionStyle : suggestionStyle // ignore: cast_nullable_to_non_nullable
as SuggestionStyle,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allowPeriodicUpdates: null == allowPeriodicUpdates ? _self.allowPeriodicUpdates : allowPeriodicUpdates // ignore: cast_nullable_to_non_nullable
as bool,selfReportCalibration: null == selfReportCalibration ? _self.selfReportCalibration : selfReportCalibration // ignore: cast_nullable_to_non_nullable
as SelfReportCalibration,
  ));
}

/// Create a copy of UserFitnessQuestionnaire
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryDetailsCopyWith<$Res>? get injuryDetails {
    if (_self.injuryDetails == null) {
    return null;
  }

  return $InjuryDetailsCopyWith<$Res>(_self.injuryDetails!, (value) {
    return _then(_self.copyWith(injuryDetails: value));
  });
}
}


/// @nodoc
mixin _$InjuryDetails {

/// Type of injury (e.g., "Lower back strain", "Shoulder impingement")
 String get injuryType;/// Body region affected
 InjuryRegion get region;/// How long ago injury occurred (months)
 int get monthsSinceInjury;/// Whether fully recovered
 bool get fullyRecovered;/// Whether currently in rehabilitation
 bool get inRehabilitation;/// Activities that aggravate the injury
 List<String> get aggravatingActivities;
/// Create a copy of InjuryDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InjuryDetailsCopyWith<InjuryDetails> get copyWith => _$InjuryDetailsCopyWithImpl<InjuryDetails>(this as InjuryDetails, _$identity);

  /// Serializes this InjuryDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InjuryDetails&&(identical(other.injuryType, injuryType) || other.injuryType == injuryType)&&(identical(other.region, region) || other.region == region)&&(identical(other.monthsSinceInjury, monthsSinceInjury) || other.monthsSinceInjury == monthsSinceInjury)&&(identical(other.fullyRecovered, fullyRecovered) || other.fullyRecovered == fullyRecovered)&&(identical(other.inRehabilitation, inRehabilitation) || other.inRehabilitation == inRehabilitation)&&const DeepCollectionEquality().equals(other.aggravatingActivities, aggravatingActivities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,injuryType,region,monthsSinceInjury,fullyRecovered,inRehabilitation,const DeepCollectionEquality().hash(aggravatingActivities));

@override
String toString() {
  return 'InjuryDetails(injuryType: $injuryType, region: $region, monthsSinceInjury: $monthsSinceInjury, fullyRecovered: $fullyRecovered, inRehabilitation: $inRehabilitation, aggravatingActivities: $aggravatingActivities)';
}


}

/// @nodoc
abstract mixin class $InjuryDetailsCopyWith<$Res>  {
  factory $InjuryDetailsCopyWith(InjuryDetails value, $Res Function(InjuryDetails) _then) = _$InjuryDetailsCopyWithImpl;
@useResult
$Res call({
 String injuryType, InjuryRegion region, int monthsSinceInjury, bool fullyRecovered, bool inRehabilitation, List<String> aggravatingActivities
});




}
/// @nodoc
class _$InjuryDetailsCopyWithImpl<$Res>
    implements $InjuryDetailsCopyWith<$Res> {
  _$InjuryDetailsCopyWithImpl(this._self, this._then);

  final InjuryDetails _self;
  final $Res Function(InjuryDetails) _then;

/// Create a copy of InjuryDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? injuryType = null,Object? region = null,Object? monthsSinceInjury = null,Object? fullyRecovered = null,Object? inRehabilitation = null,Object? aggravatingActivities = null,}) {
  return _then(_self.copyWith(
injuryType: null == injuryType ? _self.injuryType : injuryType // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as InjuryRegion,monthsSinceInjury: null == monthsSinceInjury ? _self.monthsSinceInjury : monthsSinceInjury // ignore: cast_nullable_to_non_nullable
as int,fullyRecovered: null == fullyRecovered ? _self.fullyRecovered : fullyRecovered // ignore: cast_nullable_to_non_nullable
as bool,inRehabilitation: null == inRehabilitation ? _self.inRehabilitation : inRehabilitation // ignore: cast_nullable_to_non_nullable
as bool,aggravatingActivities: null == aggravatingActivities ? _self.aggravatingActivities : aggravatingActivities // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [InjuryDetails].
extension InjuryDetailsPatterns on InjuryDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InjuryDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InjuryDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InjuryDetails value)  $default,){
final _that = this;
switch (_that) {
case _InjuryDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InjuryDetails value)?  $default,){
final _that = this;
switch (_that) {
case _InjuryDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String injuryType,  InjuryRegion region,  int monthsSinceInjury,  bool fullyRecovered,  bool inRehabilitation,  List<String> aggravatingActivities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InjuryDetails() when $default != null:
return $default(_that.injuryType,_that.region,_that.monthsSinceInjury,_that.fullyRecovered,_that.inRehabilitation,_that.aggravatingActivities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String injuryType,  InjuryRegion region,  int monthsSinceInjury,  bool fullyRecovered,  bool inRehabilitation,  List<String> aggravatingActivities)  $default,) {final _that = this;
switch (_that) {
case _InjuryDetails():
return $default(_that.injuryType,_that.region,_that.monthsSinceInjury,_that.fullyRecovered,_that.inRehabilitation,_that.aggravatingActivities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String injuryType,  InjuryRegion region,  int monthsSinceInjury,  bool fullyRecovered,  bool inRehabilitation,  List<String> aggravatingActivities)?  $default,) {final _that = this;
switch (_that) {
case _InjuryDetails() when $default != null:
return $default(_that.injuryType,_that.region,_that.monthsSinceInjury,_that.fullyRecovered,_that.inRehabilitation,_that.aggravatingActivities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InjuryDetails implements InjuryDetails {
  const _InjuryDetails({required this.injuryType, required this.region, required this.monthsSinceInjury, this.fullyRecovered = false, this.inRehabilitation = false, final  List<String> aggravatingActivities = const []}): _aggravatingActivities = aggravatingActivities;
  factory _InjuryDetails.fromJson(Map<String, dynamic> json) => _$InjuryDetailsFromJson(json);

/// Type of injury (e.g., "Lower back strain", "Shoulder impingement")
@override final  String injuryType;
/// Body region affected
@override final  InjuryRegion region;
/// How long ago injury occurred (months)
@override final  int monthsSinceInjury;
/// Whether fully recovered
@override@JsonKey() final  bool fullyRecovered;
/// Whether currently in rehabilitation
@override@JsonKey() final  bool inRehabilitation;
/// Activities that aggravate the injury
 final  List<String> _aggravatingActivities;
/// Activities that aggravate the injury
@override@JsonKey() List<String> get aggravatingActivities {
  if (_aggravatingActivities is EqualUnmodifiableListView) return _aggravatingActivities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aggravatingActivities);
}


/// Create a copy of InjuryDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InjuryDetailsCopyWith<_InjuryDetails> get copyWith => __$InjuryDetailsCopyWithImpl<_InjuryDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InjuryDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InjuryDetails&&(identical(other.injuryType, injuryType) || other.injuryType == injuryType)&&(identical(other.region, region) || other.region == region)&&(identical(other.monthsSinceInjury, monthsSinceInjury) || other.monthsSinceInjury == monthsSinceInjury)&&(identical(other.fullyRecovered, fullyRecovered) || other.fullyRecovered == fullyRecovered)&&(identical(other.inRehabilitation, inRehabilitation) || other.inRehabilitation == inRehabilitation)&&const DeepCollectionEquality().equals(other._aggravatingActivities, _aggravatingActivities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,injuryType,region,monthsSinceInjury,fullyRecovered,inRehabilitation,const DeepCollectionEquality().hash(_aggravatingActivities));

@override
String toString() {
  return 'InjuryDetails(injuryType: $injuryType, region: $region, monthsSinceInjury: $monthsSinceInjury, fullyRecovered: $fullyRecovered, inRehabilitation: $inRehabilitation, aggravatingActivities: $aggravatingActivities)';
}


}

/// @nodoc
abstract mixin class _$InjuryDetailsCopyWith<$Res> implements $InjuryDetailsCopyWith<$Res> {
  factory _$InjuryDetailsCopyWith(_InjuryDetails value, $Res Function(_InjuryDetails) _then) = __$InjuryDetailsCopyWithImpl;
@override @useResult
$Res call({
 String injuryType, InjuryRegion region, int monthsSinceInjury, bool fullyRecovered, bool inRehabilitation, List<String> aggravatingActivities
});




}
/// @nodoc
class __$InjuryDetailsCopyWithImpl<$Res>
    implements _$InjuryDetailsCopyWith<$Res> {
  __$InjuryDetailsCopyWithImpl(this._self, this._then);

  final _InjuryDetails _self;
  final $Res Function(_InjuryDetails) _then;

/// Create a copy of InjuryDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? injuryType = null,Object? region = null,Object? monthsSinceInjury = null,Object? fullyRecovered = null,Object? inRehabilitation = null,Object? aggravatingActivities = null,}) {
  return _then(_InjuryDetails(
injuryType: null == injuryType ? _self.injuryType : injuryType // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as InjuryRegion,monthsSinceInjury: null == monthsSinceInjury ? _self.monthsSinceInjury : monthsSinceInjury // ignore: cast_nullable_to_non_nullable
as int,fullyRecovered: null == fullyRecovered ? _self.fullyRecovered : fullyRecovered // ignore: cast_nullable_to_non_nullable
as bool,inRehabilitation: null == inRehabilitation ? _self.inRehabilitation : inRehabilitation // ignore: cast_nullable_to_non_nullable
as bool,aggravatingActivities: null == aggravatingActivities ? _self._aggravatingActivities : aggravatingActivities // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
