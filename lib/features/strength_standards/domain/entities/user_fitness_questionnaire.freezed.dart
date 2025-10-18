// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_fitness_questionnaire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserFitnessQuestionnaire _$UserFitnessQuestionnaireFromJson(
    Map<String, dynamic> json) {
  return _UserFitnessQuestionnaire.fromJson(json);
}

/// @nodoc
mixin _$UserFitnessQuestionnaire {
// Step 1: Demographics
  /// User's bodyweight in kg
  double get bodyweightKg => throw _privateConstructorUsedError;

  /// User's age
  int get age => throw _privateConstructorUsedError;

  /// User's biological sex (affects strength standards)
  BiologicalSex get sex =>
      throw _privateConstructorUsedError; // Step 2: Experience Level
  /// Self-reported experience level
  ExperienceLevel get experienceLevel => throw _privateConstructorUsedError;

  /// Months of consistent training (optional, helps validate experience level)
  int? get monthsOfTraining =>
      throw _privateConstructorUsedError; // Step 3: Max Lifts (Optional - improves accuracy)
  /// Bench press 1RM or estimated from reps (kg)
  double? get benchPressMax => throw _privateConstructorUsedError;

  /// Squat 1RM or estimated from reps (kg)
  double? get squatMax => throw _privateConstructorUsedError;

  /// Deadlift 1RM or estimated from reps (kg)
  double? get deadliftMax => throw _privateConstructorUsedError;

  /// Overhead press 1RM or estimated from reps (kg)
  double? get overheadPressMax =>
      throw _privateConstructorUsedError; // Step 4: Lifestyle Factors
  /// Training goal affects weight suggestion (hypertrophy, strength, endurance)
  TrainingGoal get trainingGoal => throw _privateConstructorUsedError;

  /// Injury history or limitations (affects conservative suggestions)
  bool get hasInjuryHistory => throw _privateConstructorUsedError;

  /// Specific injury details (Sciascia 2015: detailed screening recommended)
  InjuryDetails? get injuryDetails => throw _privateConstructorUsedError;

  /// Current pain or discomfort during training (0-10 scale)
  int get currentPainLevel =>
      throw _privateConstructorUsedError; // Step 5: Preferences
  /// Prefer conservative or aggressive weight suggestions
  SuggestionStyle get suggestionStyle => throw _privateConstructorUsedError;

  /// Timestamp when questionnaire was completed
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Whether user wants to update suggestions periodically
  bool get allowPeriodicUpdates => throw _privateConstructorUsedError;

  /// Self-reported accuracy calibration (Aandstad 2023: over-reporting bias)
  /// User's honesty about their actual performance vs perceived
  SelfReportCalibration get selfReportCalibration =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserFitnessQuestionnaireCopyWith<UserFitnessQuestionnaire> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFitnessQuestionnaireCopyWith<$Res> {
  factory $UserFitnessQuestionnaireCopyWith(UserFitnessQuestionnaire value,
          $Res Function(UserFitnessQuestionnaire) then) =
      _$UserFitnessQuestionnaireCopyWithImpl<$Res, UserFitnessQuestionnaire>;
  @useResult
  $Res call(
      {double bodyweightKg,
      int age,
      BiologicalSex sex,
      ExperienceLevel experienceLevel,
      int? monthsOfTraining,
      double? benchPressMax,
      double? squatMax,
      double? deadliftMax,
      double? overheadPressMax,
      TrainingGoal trainingGoal,
      bool hasInjuryHistory,
      InjuryDetails? injuryDetails,
      int currentPainLevel,
      SuggestionStyle suggestionStyle,
      DateTime? completedAt,
      bool allowPeriodicUpdates,
      SelfReportCalibration selfReportCalibration});

  $InjuryDetailsCopyWith<$Res>? get injuryDetails;
}

/// @nodoc
class _$UserFitnessQuestionnaireCopyWithImpl<$Res,
        $Val extends UserFitnessQuestionnaire>
    implements $UserFitnessQuestionnaireCopyWith<$Res> {
  _$UserFitnessQuestionnaireCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bodyweightKg = null,
    Object? age = null,
    Object? sex = null,
    Object? experienceLevel = null,
    Object? monthsOfTraining = freezed,
    Object? benchPressMax = freezed,
    Object? squatMax = freezed,
    Object? deadliftMax = freezed,
    Object? overheadPressMax = freezed,
    Object? trainingGoal = null,
    Object? hasInjuryHistory = null,
    Object? injuryDetails = freezed,
    Object? currentPainLevel = null,
    Object? suggestionStyle = null,
    Object? completedAt = freezed,
    Object? allowPeriodicUpdates = null,
    Object? selfReportCalibration = null,
  }) {
    return _then(_value.copyWith(
      bodyweightKg: null == bodyweightKg
          ? _value.bodyweightKg
          : bodyweightKg // ignore: cast_nullable_to_non_nullable
              as double,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      sex: null == sex
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as BiologicalSex,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      monthsOfTraining: freezed == monthsOfTraining
          ? _value.monthsOfTraining
          : monthsOfTraining // ignore: cast_nullable_to_non_nullable
              as int?,
      benchPressMax: freezed == benchPressMax
          ? _value.benchPressMax
          : benchPressMax // ignore: cast_nullable_to_non_nullable
              as double?,
      squatMax: freezed == squatMax
          ? _value.squatMax
          : squatMax // ignore: cast_nullable_to_non_nullable
              as double?,
      deadliftMax: freezed == deadliftMax
          ? _value.deadliftMax
          : deadliftMax // ignore: cast_nullable_to_non_nullable
              as double?,
      overheadPressMax: freezed == overheadPressMax
          ? _value.overheadPressMax
          : overheadPressMax // ignore: cast_nullable_to_non_nullable
              as double?,
      trainingGoal: null == trainingGoal
          ? _value.trainingGoal
          : trainingGoal // ignore: cast_nullable_to_non_nullable
              as TrainingGoal,
      hasInjuryHistory: null == hasInjuryHistory
          ? _value.hasInjuryHistory
          : hasInjuryHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      injuryDetails: freezed == injuryDetails
          ? _value.injuryDetails
          : injuryDetails // ignore: cast_nullable_to_non_nullable
              as InjuryDetails?,
      currentPainLevel: null == currentPainLevel
          ? _value.currentPainLevel
          : currentPainLevel // ignore: cast_nullable_to_non_nullable
              as int,
      suggestionStyle: null == suggestionStyle
          ? _value.suggestionStyle
          : suggestionStyle // ignore: cast_nullable_to_non_nullable
              as SuggestionStyle,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      allowPeriodicUpdates: null == allowPeriodicUpdates
          ? _value.allowPeriodicUpdates
          : allowPeriodicUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      selfReportCalibration: null == selfReportCalibration
          ? _value.selfReportCalibration
          : selfReportCalibration // ignore: cast_nullable_to_non_nullable
              as SelfReportCalibration,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $InjuryDetailsCopyWith<$Res>? get injuryDetails {
    if (_value.injuryDetails == null) {
      return null;
    }

    return $InjuryDetailsCopyWith<$Res>(_value.injuryDetails!, (value) {
      return _then(_value.copyWith(injuryDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserFitnessQuestionnaireImplCopyWith<$Res>
    implements $UserFitnessQuestionnaireCopyWith<$Res> {
  factory _$$UserFitnessQuestionnaireImplCopyWith(
          _$UserFitnessQuestionnaireImpl value,
          $Res Function(_$UserFitnessQuestionnaireImpl) then) =
      __$$UserFitnessQuestionnaireImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double bodyweightKg,
      int age,
      BiologicalSex sex,
      ExperienceLevel experienceLevel,
      int? monthsOfTraining,
      double? benchPressMax,
      double? squatMax,
      double? deadliftMax,
      double? overheadPressMax,
      TrainingGoal trainingGoal,
      bool hasInjuryHistory,
      InjuryDetails? injuryDetails,
      int currentPainLevel,
      SuggestionStyle suggestionStyle,
      DateTime? completedAt,
      bool allowPeriodicUpdates,
      SelfReportCalibration selfReportCalibration});

  @override
  $InjuryDetailsCopyWith<$Res>? get injuryDetails;
}

/// @nodoc
class __$$UserFitnessQuestionnaireImplCopyWithImpl<$Res>
    extends _$UserFitnessQuestionnaireCopyWithImpl<$Res,
        _$UserFitnessQuestionnaireImpl>
    implements _$$UserFitnessQuestionnaireImplCopyWith<$Res> {
  __$$UserFitnessQuestionnaireImplCopyWithImpl(
      _$UserFitnessQuestionnaireImpl _value,
      $Res Function(_$UserFitnessQuestionnaireImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bodyweightKg = null,
    Object? age = null,
    Object? sex = null,
    Object? experienceLevel = null,
    Object? monthsOfTraining = freezed,
    Object? benchPressMax = freezed,
    Object? squatMax = freezed,
    Object? deadliftMax = freezed,
    Object? overheadPressMax = freezed,
    Object? trainingGoal = null,
    Object? hasInjuryHistory = null,
    Object? injuryDetails = freezed,
    Object? currentPainLevel = null,
    Object? suggestionStyle = null,
    Object? completedAt = freezed,
    Object? allowPeriodicUpdates = null,
    Object? selfReportCalibration = null,
  }) {
    return _then(_$UserFitnessQuestionnaireImpl(
      bodyweightKg: null == bodyweightKg
          ? _value.bodyweightKg
          : bodyweightKg // ignore: cast_nullable_to_non_nullable
              as double,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      sex: null == sex
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as BiologicalSex,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
      monthsOfTraining: freezed == monthsOfTraining
          ? _value.monthsOfTraining
          : monthsOfTraining // ignore: cast_nullable_to_non_nullable
              as int?,
      benchPressMax: freezed == benchPressMax
          ? _value.benchPressMax
          : benchPressMax // ignore: cast_nullable_to_non_nullable
              as double?,
      squatMax: freezed == squatMax
          ? _value.squatMax
          : squatMax // ignore: cast_nullable_to_non_nullable
              as double?,
      deadliftMax: freezed == deadliftMax
          ? _value.deadliftMax
          : deadliftMax // ignore: cast_nullable_to_non_nullable
              as double?,
      overheadPressMax: freezed == overheadPressMax
          ? _value.overheadPressMax
          : overheadPressMax // ignore: cast_nullable_to_non_nullable
              as double?,
      trainingGoal: null == trainingGoal
          ? _value.trainingGoal
          : trainingGoal // ignore: cast_nullable_to_non_nullable
              as TrainingGoal,
      hasInjuryHistory: null == hasInjuryHistory
          ? _value.hasInjuryHistory
          : hasInjuryHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      injuryDetails: freezed == injuryDetails
          ? _value.injuryDetails
          : injuryDetails // ignore: cast_nullable_to_non_nullable
              as InjuryDetails?,
      currentPainLevel: null == currentPainLevel
          ? _value.currentPainLevel
          : currentPainLevel // ignore: cast_nullable_to_non_nullable
              as int,
      suggestionStyle: null == suggestionStyle
          ? _value.suggestionStyle
          : suggestionStyle // ignore: cast_nullable_to_non_nullable
              as SuggestionStyle,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      allowPeriodicUpdates: null == allowPeriodicUpdates
          ? _value.allowPeriodicUpdates
          : allowPeriodicUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      selfReportCalibration: null == selfReportCalibration
          ? _value.selfReportCalibration
          : selfReportCalibration // ignore: cast_nullable_to_non_nullable
              as SelfReportCalibration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserFitnessQuestionnaireImpl implements _UserFitnessQuestionnaire {
  const _$UserFitnessQuestionnaireImpl(
      {required this.bodyweightKg,
      required this.age,
      required this.sex,
      required this.experienceLevel,
      this.monthsOfTraining,
      this.benchPressMax,
      this.squatMax,
      this.deadliftMax,
      this.overheadPressMax,
      this.trainingGoal = TrainingGoal.hypertrophy,
      this.hasInjuryHistory = false,
      this.injuryDetails,
      this.currentPainLevel = 0,
      this.suggestionStyle = SuggestionStyle.balanced,
      this.completedAt,
      this.allowPeriodicUpdates = true,
      this.selfReportCalibration = SelfReportCalibration.realistic});

  factory _$UserFitnessQuestionnaireImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserFitnessQuestionnaireImplFromJson(json);

// Step 1: Demographics
  /// User's bodyweight in kg
  @override
  final double bodyweightKg;

  /// User's age
  @override
  final int age;

  /// User's biological sex (affects strength standards)
  @override
  final BiologicalSex sex;
// Step 2: Experience Level
  /// Self-reported experience level
  @override
  final ExperienceLevel experienceLevel;

  /// Months of consistent training (optional, helps validate experience level)
  @override
  final int? monthsOfTraining;
// Step 3: Max Lifts (Optional - improves accuracy)
  /// Bench press 1RM or estimated from reps (kg)
  @override
  final double? benchPressMax;

  /// Squat 1RM or estimated from reps (kg)
  @override
  final double? squatMax;

  /// Deadlift 1RM or estimated from reps (kg)
  @override
  final double? deadliftMax;

  /// Overhead press 1RM or estimated from reps (kg)
  @override
  final double? overheadPressMax;
// Step 4: Lifestyle Factors
  /// Training goal affects weight suggestion (hypertrophy, strength, endurance)
  @override
  @JsonKey()
  final TrainingGoal trainingGoal;

  /// Injury history or limitations (affects conservative suggestions)
  @override
  @JsonKey()
  final bool hasInjuryHistory;

  /// Specific injury details (Sciascia 2015: detailed screening recommended)
  @override
  final InjuryDetails? injuryDetails;

  /// Current pain or discomfort during training (0-10 scale)
  @override
  @JsonKey()
  final int currentPainLevel;
// Step 5: Preferences
  /// Prefer conservative or aggressive weight suggestions
  @override
  @JsonKey()
  final SuggestionStyle suggestionStyle;

  /// Timestamp when questionnaire was completed
  @override
  final DateTime? completedAt;

  /// Whether user wants to update suggestions periodically
  @override
  @JsonKey()
  final bool allowPeriodicUpdates;

  /// Self-reported accuracy calibration (Aandstad 2023: over-reporting bias)
  /// User's honesty about their actual performance vs perceived
  @override
  @JsonKey()
  final SelfReportCalibration selfReportCalibration;

  @override
  String toString() {
    return 'UserFitnessQuestionnaire(bodyweightKg: $bodyweightKg, age: $age, sex: $sex, experienceLevel: $experienceLevel, monthsOfTraining: $monthsOfTraining, benchPressMax: $benchPressMax, squatMax: $squatMax, deadliftMax: $deadliftMax, overheadPressMax: $overheadPressMax, trainingGoal: $trainingGoal, hasInjuryHistory: $hasInjuryHistory, injuryDetails: $injuryDetails, currentPainLevel: $currentPainLevel, suggestionStyle: $suggestionStyle, completedAt: $completedAt, allowPeriodicUpdates: $allowPeriodicUpdates, selfReportCalibration: $selfReportCalibration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFitnessQuestionnaireImpl &&
            (identical(other.bodyweightKg, bodyweightKg) ||
                other.bodyweightKg == bodyweightKg) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.sex, sex) || other.sex == sex) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.monthsOfTraining, monthsOfTraining) ||
                other.monthsOfTraining == monthsOfTraining) &&
            (identical(other.benchPressMax, benchPressMax) ||
                other.benchPressMax == benchPressMax) &&
            (identical(other.squatMax, squatMax) ||
                other.squatMax == squatMax) &&
            (identical(other.deadliftMax, deadliftMax) ||
                other.deadliftMax == deadliftMax) &&
            (identical(other.overheadPressMax, overheadPressMax) ||
                other.overheadPressMax == overheadPressMax) &&
            (identical(other.trainingGoal, trainingGoal) ||
                other.trainingGoal == trainingGoal) &&
            (identical(other.hasInjuryHistory, hasInjuryHistory) ||
                other.hasInjuryHistory == hasInjuryHistory) &&
            (identical(other.injuryDetails, injuryDetails) ||
                other.injuryDetails == injuryDetails) &&
            (identical(other.currentPainLevel, currentPainLevel) ||
                other.currentPainLevel == currentPainLevel) &&
            (identical(other.suggestionStyle, suggestionStyle) ||
                other.suggestionStyle == suggestionStyle) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.allowPeriodicUpdates, allowPeriodicUpdates) ||
                other.allowPeriodicUpdates == allowPeriodicUpdates) &&
            (identical(other.selfReportCalibration, selfReportCalibration) ||
                other.selfReportCalibration == selfReportCalibration));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bodyweightKg,
      age,
      sex,
      experienceLevel,
      monthsOfTraining,
      benchPressMax,
      squatMax,
      deadliftMax,
      overheadPressMax,
      trainingGoal,
      hasInjuryHistory,
      injuryDetails,
      currentPainLevel,
      suggestionStyle,
      completedAt,
      allowPeriodicUpdates,
      selfReportCalibration);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFitnessQuestionnaireImplCopyWith<_$UserFitnessQuestionnaireImpl>
      get copyWith => __$$UserFitnessQuestionnaireImplCopyWithImpl<
          _$UserFitnessQuestionnaireImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserFitnessQuestionnaireImplToJson(
      this,
    );
  }
}

abstract class _UserFitnessQuestionnaire implements UserFitnessQuestionnaire {
  const factory _UserFitnessQuestionnaire(
          {required final double bodyweightKg,
          required final int age,
          required final BiologicalSex sex,
          required final ExperienceLevel experienceLevel,
          final int? monthsOfTraining,
          final double? benchPressMax,
          final double? squatMax,
          final double? deadliftMax,
          final double? overheadPressMax,
          final TrainingGoal trainingGoal,
          final bool hasInjuryHistory,
          final InjuryDetails? injuryDetails,
          final int currentPainLevel,
          final SuggestionStyle suggestionStyle,
          final DateTime? completedAt,
          final bool allowPeriodicUpdates,
          final SelfReportCalibration selfReportCalibration}) =
      _$UserFitnessQuestionnaireImpl;

  factory _UserFitnessQuestionnaire.fromJson(Map<String, dynamic> json) =
      _$UserFitnessQuestionnaireImpl.fromJson;

  @override // Step 1: Demographics
  /// User's bodyweight in kg
  double get bodyweightKg;
  @override

  /// User's age
  int get age;
  @override

  /// User's biological sex (affects strength standards)
  BiologicalSex get sex;
  @override // Step 2: Experience Level
  /// Self-reported experience level
  ExperienceLevel get experienceLevel;
  @override

  /// Months of consistent training (optional, helps validate experience level)
  int? get monthsOfTraining;
  @override // Step 3: Max Lifts (Optional - improves accuracy)
  /// Bench press 1RM or estimated from reps (kg)
  double? get benchPressMax;
  @override

  /// Squat 1RM or estimated from reps (kg)
  double? get squatMax;
  @override

  /// Deadlift 1RM or estimated from reps (kg)
  double? get deadliftMax;
  @override

  /// Overhead press 1RM or estimated from reps (kg)
  double? get overheadPressMax;
  @override // Step 4: Lifestyle Factors
  /// Training goal affects weight suggestion (hypertrophy, strength, endurance)
  TrainingGoal get trainingGoal;
  @override

  /// Injury history or limitations (affects conservative suggestions)
  bool get hasInjuryHistory;
  @override

  /// Specific injury details (Sciascia 2015: detailed screening recommended)
  InjuryDetails? get injuryDetails;
  @override

  /// Current pain or discomfort during training (0-10 scale)
  int get currentPainLevel;
  @override // Step 5: Preferences
  /// Prefer conservative or aggressive weight suggestions
  SuggestionStyle get suggestionStyle;
  @override

  /// Timestamp when questionnaire was completed
  DateTime? get completedAt;
  @override

  /// Whether user wants to update suggestions periodically
  bool get allowPeriodicUpdates;
  @override

  /// Self-reported accuracy calibration (Aandstad 2023: over-reporting bias)
  /// User's honesty about their actual performance vs perceived
  SelfReportCalibration get selfReportCalibration;
  @override
  @JsonKey(ignore: true)
  _$$UserFitnessQuestionnaireImplCopyWith<_$UserFitnessQuestionnaireImpl>
      get copyWith => throw _privateConstructorUsedError;
}

InjuryDetails _$InjuryDetailsFromJson(Map<String, dynamic> json) {
  return _InjuryDetails.fromJson(json);
}

/// @nodoc
mixin _$InjuryDetails {
  /// Type of injury (e.g., "Lower back strain", "Shoulder impingement")
  String get injuryType => throw _privateConstructorUsedError;

  /// Body region affected
  InjuryRegion get region => throw _privateConstructorUsedError;

  /// How long ago injury occurred (months)
  int get monthsSinceInjury => throw _privateConstructorUsedError;

  /// Whether fully recovered
  bool get fullyRecovered => throw _privateConstructorUsedError;

  /// Whether currently in rehabilitation
  bool get inRehabilitation => throw _privateConstructorUsedError;

  /// Activities that aggravate the injury
  List<String> get aggravatingActivities => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InjuryDetailsCopyWith<InjuryDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InjuryDetailsCopyWith<$Res> {
  factory $InjuryDetailsCopyWith(
          InjuryDetails value, $Res Function(InjuryDetails) then) =
      _$InjuryDetailsCopyWithImpl<$Res, InjuryDetails>;
  @useResult
  $Res call(
      {String injuryType,
      InjuryRegion region,
      int monthsSinceInjury,
      bool fullyRecovered,
      bool inRehabilitation,
      List<String> aggravatingActivities});
}

/// @nodoc
class _$InjuryDetailsCopyWithImpl<$Res, $Val extends InjuryDetails>
    implements $InjuryDetailsCopyWith<$Res> {
  _$InjuryDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? injuryType = null,
    Object? region = null,
    Object? monthsSinceInjury = null,
    Object? fullyRecovered = null,
    Object? inRehabilitation = null,
    Object? aggravatingActivities = null,
  }) {
    return _then(_value.copyWith(
      injuryType: null == injuryType
          ? _value.injuryType
          : injuryType // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as InjuryRegion,
      monthsSinceInjury: null == monthsSinceInjury
          ? _value.monthsSinceInjury
          : monthsSinceInjury // ignore: cast_nullable_to_non_nullable
              as int,
      fullyRecovered: null == fullyRecovered
          ? _value.fullyRecovered
          : fullyRecovered // ignore: cast_nullable_to_non_nullable
              as bool,
      inRehabilitation: null == inRehabilitation
          ? _value.inRehabilitation
          : inRehabilitation // ignore: cast_nullable_to_non_nullable
              as bool,
      aggravatingActivities: null == aggravatingActivities
          ? _value.aggravatingActivities
          : aggravatingActivities // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InjuryDetailsImplCopyWith<$Res>
    implements $InjuryDetailsCopyWith<$Res> {
  factory _$$InjuryDetailsImplCopyWith(
          _$InjuryDetailsImpl value, $Res Function(_$InjuryDetailsImpl) then) =
      __$$InjuryDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String injuryType,
      InjuryRegion region,
      int monthsSinceInjury,
      bool fullyRecovered,
      bool inRehabilitation,
      List<String> aggravatingActivities});
}

/// @nodoc
class __$$InjuryDetailsImplCopyWithImpl<$Res>
    extends _$InjuryDetailsCopyWithImpl<$Res, _$InjuryDetailsImpl>
    implements _$$InjuryDetailsImplCopyWith<$Res> {
  __$$InjuryDetailsImplCopyWithImpl(
      _$InjuryDetailsImpl _value, $Res Function(_$InjuryDetailsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? injuryType = null,
    Object? region = null,
    Object? monthsSinceInjury = null,
    Object? fullyRecovered = null,
    Object? inRehabilitation = null,
    Object? aggravatingActivities = null,
  }) {
    return _then(_$InjuryDetailsImpl(
      injuryType: null == injuryType
          ? _value.injuryType
          : injuryType // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as InjuryRegion,
      monthsSinceInjury: null == monthsSinceInjury
          ? _value.monthsSinceInjury
          : monthsSinceInjury // ignore: cast_nullable_to_non_nullable
              as int,
      fullyRecovered: null == fullyRecovered
          ? _value.fullyRecovered
          : fullyRecovered // ignore: cast_nullable_to_non_nullable
              as bool,
      inRehabilitation: null == inRehabilitation
          ? _value.inRehabilitation
          : inRehabilitation // ignore: cast_nullable_to_non_nullable
              as bool,
      aggravatingActivities: null == aggravatingActivities
          ? _value._aggravatingActivities
          : aggravatingActivities // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InjuryDetailsImpl implements _InjuryDetails {
  const _$InjuryDetailsImpl(
      {required this.injuryType,
      required this.region,
      required this.monthsSinceInjury,
      this.fullyRecovered = false,
      this.inRehabilitation = false,
      final List<String> aggravatingActivities = const []})
      : _aggravatingActivities = aggravatingActivities;

  factory _$InjuryDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$InjuryDetailsImplFromJson(json);

  /// Type of injury (e.g., "Lower back strain", "Shoulder impingement")
  @override
  final String injuryType;

  /// Body region affected
  @override
  final InjuryRegion region;

  /// How long ago injury occurred (months)
  @override
  final int monthsSinceInjury;

  /// Whether fully recovered
  @override
  @JsonKey()
  final bool fullyRecovered;

  /// Whether currently in rehabilitation
  @override
  @JsonKey()
  final bool inRehabilitation;

  /// Activities that aggravate the injury
  final List<String> _aggravatingActivities;

  /// Activities that aggravate the injury
  @override
  @JsonKey()
  List<String> get aggravatingActivities {
    if (_aggravatingActivities is EqualUnmodifiableListView)
      return _aggravatingActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aggravatingActivities);
  }

  @override
  String toString() {
    return 'InjuryDetails(injuryType: $injuryType, region: $region, monthsSinceInjury: $monthsSinceInjury, fullyRecovered: $fullyRecovered, inRehabilitation: $inRehabilitation, aggravatingActivities: $aggravatingActivities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InjuryDetailsImpl &&
            (identical(other.injuryType, injuryType) ||
                other.injuryType == injuryType) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.monthsSinceInjury, monthsSinceInjury) ||
                other.monthsSinceInjury == monthsSinceInjury) &&
            (identical(other.fullyRecovered, fullyRecovered) ||
                other.fullyRecovered == fullyRecovered) &&
            (identical(other.inRehabilitation, inRehabilitation) ||
                other.inRehabilitation == inRehabilitation) &&
            const DeepCollectionEquality()
                .equals(other._aggravatingActivities, _aggravatingActivities));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      injuryType,
      region,
      monthsSinceInjury,
      fullyRecovered,
      inRehabilitation,
      const DeepCollectionEquality().hash(_aggravatingActivities));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InjuryDetailsImplCopyWith<_$InjuryDetailsImpl> get copyWith =>
      __$$InjuryDetailsImplCopyWithImpl<_$InjuryDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InjuryDetailsImplToJson(
      this,
    );
  }
}

abstract class _InjuryDetails implements InjuryDetails {
  const factory _InjuryDetails(
      {required final String injuryType,
      required final InjuryRegion region,
      required final int monthsSinceInjury,
      final bool fullyRecovered,
      final bool inRehabilitation,
      final List<String> aggravatingActivities}) = _$InjuryDetailsImpl;

  factory _InjuryDetails.fromJson(Map<String, dynamic> json) =
      _$InjuryDetailsImpl.fromJson;

  @override

  /// Type of injury (e.g., "Lower back strain", "Shoulder impingement")
  String get injuryType;
  @override

  /// Body region affected
  InjuryRegion get region;
  @override

  /// How long ago injury occurred (months)
  int get monthsSinceInjury;
  @override

  /// Whether fully recovered
  bool get fullyRecovered;
  @override

  /// Whether currently in rehabilitation
  bool get inRehabilitation;
  @override

  /// Activities that aggravate the injury
  List<String> get aggravatingActivities;
  @override
  @JsonKey(ignore: true)
  _$$InjuryDetailsImplCopyWith<_$InjuryDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
