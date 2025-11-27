// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_clearance_questionnaire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MedicalClearanceQuestionnaire _$MedicalClearanceQuestionnaireFromJson(
  Map<String, dynamic> json,
) {
  return _MedicalClearanceQuestionnaire.fromJson(json);
}

/// @nodoc
mixin _$MedicalClearanceQuestionnaire {
  // Core PAR-Q+ questions (simplified for app context)
  /// Has doctor ever said you have heart condition?
  bool get hasHeartCondition => throw _privateConstructorUsedError;

  /// Do you feel pain in chest during physical activity?
  bool get hasChestPain => throw _privateConstructorUsedError;

  /// In past month, chest pain when NOT doing physical activity?
  bool get hasChestPainAtRest => throw _privateConstructorUsedError;

  /// Do you lose balance because of dizziness or consciousness?
  bool get hasDizzinessOrFainting => throw _privateConstructorUsedError;

  /// Bone or joint problem that could worsen with activity?
  bool get hasBoneJointProblem => throw _privateConstructorUsedError;

  /// Currently taking medication for blood pressure or heart?
  bool get takesHeartMedication => throw _privateConstructorUsedError;

  /// Any other reason you should not do physical activity?
  bool get hasOtherMedicalReason =>
      throw _privateConstructorUsedError; // Additional ACSM screening
  /// Age ≥45 for men, ≥55 for women (higher risk)
  bool get isHighRiskAge => throw _privateConstructorUsedError;

  /// Family history cardiovascular disease before age 55
  bool get hasFamilyHistory => throw _privateConstructorUsedError;

  /// Currently smoke or quit within 6 months
  bool get currentSmoker => throw _privateConstructorUsedError;

  /// BMI ≥30 or waist >102cm (men) or >88cm (women)
  bool get isObese => throw _privateConstructorUsedError;

  /// Diabetes (Type 1 or 2)
  bool get hasDiabetes => throw _privateConstructorUsedError;

  /// High blood pressure (≥140/90 or on medication)
  bool get hasHighBloodPressure =>
      throw _privateConstructorUsedError; // Metadata
  DateTime? get completedAt => throw _privateConstructorUsedError;
  bool get userAcknowledgedRisks => throw _privateConstructorUsedError;

  /// Serializes this MedicalClearanceQuestionnaire to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicalClearanceQuestionnaire
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicalClearanceQuestionnaireCopyWith<MedicalClearanceQuestionnaire>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicalClearanceQuestionnaireCopyWith<$Res> {
  factory $MedicalClearanceQuestionnaireCopyWith(
    MedicalClearanceQuestionnaire value,
    $Res Function(MedicalClearanceQuestionnaire) then,
  ) =
      _$MedicalClearanceQuestionnaireCopyWithImpl<
        $Res,
        MedicalClearanceQuestionnaire
      >;
  @useResult
  $Res call({
    bool hasHeartCondition,
    bool hasChestPain,
    bool hasChestPainAtRest,
    bool hasDizzinessOrFainting,
    bool hasBoneJointProblem,
    bool takesHeartMedication,
    bool hasOtherMedicalReason,
    bool isHighRiskAge,
    bool hasFamilyHistory,
    bool currentSmoker,
    bool isObese,
    bool hasDiabetes,
    bool hasHighBloodPressure,
    DateTime? completedAt,
    bool userAcknowledgedRisks,
  });
}

/// @nodoc
class _$MedicalClearanceQuestionnaireCopyWithImpl<
  $Res,
  $Val extends MedicalClearanceQuestionnaire
>
    implements $MedicalClearanceQuestionnaireCopyWith<$Res> {
  _$MedicalClearanceQuestionnaireCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicalClearanceQuestionnaire
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasHeartCondition = null,
    Object? hasChestPain = null,
    Object? hasChestPainAtRest = null,
    Object? hasDizzinessOrFainting = null,
    Object? hasBoneJointProblem = null,
    Object? takesHeartMedication = null,
    Object? hasOtherMedicalReason = null,
    Object? isHighRiskAge = null,
    Object? hasFamilyHistory = null,
    Object? currentSmoker = null,
    Object? isObese = null,
    Object? hasDiabetes = null,
    Object? hasHighBloodPressure = null,
    Object? completedAt = freezed,
    Object? userAcknowledgedRisks = null,
  }) {
    return _then(
      _value.copyWith(
            hasHeartCondition: null == hasHeartCondition
                ? _value.hasHeartCondition
                : hasHeartCondition // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasChestPain: null == hasChestPain
                ? _value.hasChestPain
                : hasChestPain // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasChestPainAtRest: null == hasChestPainAtRest
                ? _value.hasChestPainAtRest
                : hasChestPainAtRest // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasDizzinessOrFainting: null == hasDizzinessOrFainting
                ? _value.hasDizzinessOrFainting
                : hasDizzinessOrFainting // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasBoneJointProblem: null == hasBoneJointProblem
                ? _value.hasBoneJointProblem
                : hasBoneJointProblem // ignore: cast_nullable_to_non_nullable
                      as bool,
            takesHeartMedication: null == takesHeartMedication
                ? _value.takesHeartMedication
                : takesHeartMedication // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasOtherMedicalReason: null == hasOtherMedicalReason
                ? _value.hasOtherMedicalReason
                : hasOtherMedicalReason // ignore: cast_nullable_to_non_nullable
                      as bool,
            isHighRiskAge: null == isHighRiskAge
                ? _value.isHighRiskAge
                : isHighRiskAge // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasFamilyHistory: null == hasFamilyHistory
                ? _value.hasFamilyHistory
                : hasFamilyHistory // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentSmoker: null == currentSmoker
                ? _value.currentSmoker
                : currentSmoker // ignore: cast_nullable_to_non_nullable
                      as bool,
            isObese: null == isObese
                ? _value.isObese
                : isObese // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasDiabetes: null == hasDiabetes
                ? _value.hasDiabetes
                : hasDiabetes // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasHighBloodPressure: null == hasHighBloodPressure
                ? _value.hasHighBloodPressure
                : hasHighBloodPressure // ignore: cast_nullable_to_non_nullable
                      as bool,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            userAcknowledgedRisks: null == userAcknowledgedRisks
                ? _value.userAcknowledgedRisks
                : userAcknowledgedRisks // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicalClearanceQuestionnaireImplCopyWith<$Res>
    implements $MedicalClearanceQuestionnaireCopyWith<$Res> {
  factory _$$MedicalClearanceQuestionnaireImplCopyWith(
    _$MedicalClearanceQuestionnaireImpl value,
    $Res Function(_$MedicalClearanceQuestionnaireImpl) then,
  ) = __$$MedicalClearanceQuestionnaireImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool hasHeartCondition,
    bool hasChestPain,
    bool hasChestPainAtRest,
    bool hasDizzinessOrFainting,
    bool hasBoneJointProblem,
    bool takesHeartMedication,
    bool hasOtherMedicalReason,
    bool isHighRiskAge,
    bool hasFamilyHistory,
    bool currentSmoker,
    bool isObese,
    bool hasDiabetes,
    bool hasHighBloodPressure,
    DateTime? completedAt,
    bool userAcknowledgedRisks,
  });
}

/// @nodoc
class __$$MedicalClearanceQuestionnaireImplCopyWithImpl<$Res>
    extends
        _$MedicalClearanceQuestionnaireCopyWithImpl<
          $Res,
          _$MedicalClearanceQuestionnaireImpl
        >
    implements _$$MedicalClearanceQuestionnaireImplCopyWith<$Res> {
  __$$MedicalClearanceQuestionnaireImplCopyWithImpl(
    _$MedicalClearanceQuestionnaireImpl _value,
    $Res Function(_$MedicalClearanceQuestionnaireImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicalClearanceQuestionnaire
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasHeartCondition = null,
    Object? hasChestPain = null,
    Object? hasChestPainAtRest = null,
    Object? hasDizzinessOrFainting = null,
    Object? hasBoneJointProblem = null,
    Object? takesHeartMedication = null,
    Object? hasOtherMedicalReason = null,
    Object? isHighRiskAge = null,
    Object? hasFamilyHistory = null,
    Object? currentSmoker = null,
    Object? isObese = null,
    Object? hasDiabetes = null,
    Object? hasHighBloodPressure = null,
    Object? completedAt = freezed,
    Object? userAcknowledgedRisks = null,
  }) {
    return _then(
      _$MedicalClearanceQuestionnaireImpl(
        hasHeartCondition: null == hasHeartCondition
            ? _value.hasHeartCondition
            : hasHeartCondition // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasChestPain: null == hasChestPain
            ? _value.hasChestPain
            : hasChestPain // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasChestPainAtRest: null == hasChestPainAtRest
            ? _value.hasChestPainAtRest
            : hasChestPainAtRest // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasDizzinessOrFainting: null == hasDizzinessOrFainting
            ? _value.hasDizzinessOrFainting
            : hasDizzinessOrFainting // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasBoneJointProblem: null == hasBoneJointProblem
            ? _value.hasBoneJointProblem
            : hasBoneJointProblem // ignore: cast_nullable_to_non_nullable
                  as bool,
        takesHeartMedication: null == takesHeartMedication
            ? _value.takesHeartMedication
            : takesHeartMedication // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasOtherMedicalReason: null == hasOtherMedicalReason
            ? _value.hasOtherMedicalReason
            : hasOtherMedicalReason // ignore: cast_nullable_to_non_nullable
                  as bool,
        isHighRiskAge: null == isHighRiskAge
            ? _value.isHighRiskAge
            : isHighRiskAge // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasFamilyHistory: null == hasFamilyHistory
            ? _value.hasFamilyHistory
            : hasFamilyHistory // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentSmoker: null == currentSmoker
            ? _value.currentSmoker
            : currentSmoker // ignore: cast_nullable_to_non_nullable
                  as bool,
        isObese: null == isObese
            ? _value.isObese
            : isObese // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasDiabetes: null == hasDiabetes
            ? _value.hasDiabetes
            : hasDiabetes // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasHighBloodPressure: null == hasHighBloodPressure
            ? _value.hasHighBloodPressure
            : hasHighBloodPressure // ignore: cast_nullable_to_non_nullable
                  as bool,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        userAcknowledgedRisks: null == userAcknowledgedRisks
            ? _value.userAcknowledgedRisks
            : userAcknowledgedRisks // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicalClearanceQuestionnaireImpl
    implements _MedicalClearanceQuestionnaire {
  const _$MedicalClearanceQuestionnaireImpl({
    this.hasHeartCondition = false,
    this.hasChestPain = false,
    this.hasChestPainAtRest = false,
    this.hasDizzinessOrFainting = false,
    this.hasBoneJointProblem = false,
    this.takesHeartMedication = false,
    this.hasOtherMedicalReason = false,
    this.isHighRiskAge = false,
    this.hasFamilyHistory = false,
    this.currentSmoker = false,
    this.isObese = false,
    this.hasDiabetes = false,
    this.hasHighBloodPressure = false,
    this.completedAt,
    this.userAcknowledgedRisks = false,
  });

  factory _$MedicalClearanceQuestionnaireImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MedicalClearanceQuestionnaireImplFromJson(json);

  // Core PAR-Q+ questions (simplified for app context)
  /// Has doctor ever said you have heart condition?
  @override
  @JsonKey()
  final bool hasHeartCondition;

  /// Do you feel pain in chest during physical activity?
  @override
  @JsonKey()
  final bool hasChestPain;

  /// In past month, chest pain when NOT doing physical activity?
  @override
  @JsonKey()
  final bool hasChestPainAtRest;

  /// Do you lose balance because of dizziness or consciousness?
  @override
  @JsonKey()
  final bool hasDizzinessOrFainting;

  /// Bone or joint problem that could worsen with activity?
  @override
  @JsonKey()
  final bool hasBoneJointProblem;

  /// Currently taking medication for blood pressure or heart?
  @override
  @JsonKey()
  final bool takesHeartMedication;

  /// Any other reason you should not do physical activity?
  @override
  @JsonKey()
  final bool hasOtherMedicalReason;
  // Additional ACSM screening
  /// Age ≥45 for men, ≥55 for women (higher risk)
  @override
  @JsonKey()
  final bool isHighRiskAge;

  /// Family history cardiovascular disease before age 55
  @override
  @JsonKey()
  final bool hasFamilyHistory;

  /// Currently smoke or quit within 6 months
  @override
  @JsonKey()
  final bool currentSmoker;

  /// BMI ≥30 or waist >102cm (men) or >88cm (women)
  @override
  @JsonKey()
  final bool isObese;

  /// Diabetes (Type 1 or 2)
  @override
  @JsonKey()
  final bool hasDiabetes;

  /// High blood pressure (≥140/90 or on medication)
  @override
  @JsonKey()
  final bool hasHighBloodPressure;
  // Metadata
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final bool userAcknowledgedRisks;

  @override
  String toString() {
    return 'MedicalClearanceQuestionnaire(hasHeartCondition: $hasHeartCondition, hasChestPain: $hasChestPain, hasChestPainAtRest: $hasChestPainAtRest, hasDizzinessOrFainting: $hasDizzinessOrFainting, hasBoneJointProblem: $hasBoneJointProblem, takesHeartMedication: $takesHeartMedication, hasOtherMedicalReason: $hasOtherMedicalReason, isHighRiskAge: $isHighRiskAge, hasFamilyHistory: $hasFamilyHistory, currentSmoker: $currentSmoker, isObese: $isObese, hasDiabetes: $hasDiabetes, hasHighBloodPressure: $hasHighBloodPressure, completedAt: $completedAt, userAcknowledgedRisks: $userAcknowledgedRisks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicalClearanceQuestionnaireImpl &&
            (identical(other.hasHeartCondition, hasHeartCondition) ||
                other.hasHeartCondition == hasHeartCondition) &&
            (identical(other.hasChestPain, hasChestPain) ||
                other.hasChestPain == hasChestPain) &&
            (identical(other.hasChestPainAtRest, hasChestPainAtRest) ||
                other.hasChestPainAtRest == hasChestPainAtRest) &&
            (identical(other.hasDizzinessOrFainting, hasDizzinessOrFainting) ||
                other.hasDizzinessOrFainting == hasDizzinessOrFainting) &&
            (identical(other.hasBoneJointProblem, hasBoneJointProblem) ||
                other.hasBoneJointProblem == hasBoneJointProblem) &&
            (identical(other.takesHeartMedication, takesHeartMedication) ||
                other.takesHeartMedication == takesHeartMedication) &&
            (identical(other.hasOtherMedicalReason, hasOtherMedicalReason) ||
                other.hasOtherMedicalReason == hasOtherMedicalReason) &&
            (identical(other.isHighRiskAge, isHighRiskAge) ||
                other.isHighRiskAge == isHighRiskAge) &&
            (identical(other.hasFamilyHistory, hasFamilyHistory) ||
                other.hasFamilyHistory == hasFamilyHistory) &&
            (identical(other.currentSmoker, currentSmoker) ||
                other.currentSmoker == currentSmoker) &&
            (identical(other.isObese, isObese) || other.isObese == isObese) &&
            (identical(other.hasDiabetes, hasDiabetes) ||
                other.hasDiabetes == hasDiabetes) &&
            (identical(other.hasHighBloodPressure, hasHighBloodPressure) ||
                other.hasHighBloodPressure == hasHighBloodPressure) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.userAcknowledgedRisks, userAcknowledgedRisks) ||
                other.userAcknowledgedRisks == userAcknowledgedRisks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hasHeartCondition,
    hasChestPain,
    hasChestPainAtRest,
    hasDizzinessOrFainting,
    hasBoneJointProblem,
    takesHeartMedication,
    hasOtherMedicalReason,
    isHighRiskAge,
    hasFamilyHistory,
    currentSmoker,
    isObese,
    hasDiabetes,
    hasHighBloodPressure,
    completedAt,
    userAcknowledgedRisks,
  );

  /// Create a copy of MedicalClearanceQuestionnaire
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicalClearanceQuestionnaireImplCopyWith<
    _$MedicalClearanceQuestionnaireImpl
  >
  get copyWith =>
      __$$MedicalClearanceQuestionnaireImplCopyWithImpl<
        _$MedicalClearanceQuestionnaireImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicalClearanceQuestionnaireImplToJson(this);
  }
}

abstract class _MedicalClearanceQuestionnaire
    implements MedicalClearanceQuestionnaire {
  const factory _MedicalClearanceQuestionnaire({
    final bool hasHeartCondition,
    final bool hasChestPain,
    final bool hasChestPainAtRest,
    final bool hasDizzinessOrFainting,
    final bool hasBoneJointProblem,
    final bool takesHeartMedication,
    final bool hasOtherMedicalReason,
    final bool isHighRiskAge,
    final bool hasFamilyHistory,
    final bool currentSmoker,
    final bool isObese,
    final bool hasDiabetes,
    final bool hasHighBloodPressure,
    final DateTime? completedAt,
    final bool userAcknowledgedRisks,
  }) = _$MedicalClearanceQuestionnaireImpl;

  factory _MedicalClearanceQuestionnaire.fromJson(Map<String, dynamic> json) =
      _$MedicalClearanceQuestionnaireImpl.fromJson;

  // Core PAR-Q+ questions (simplified for app context)
  /// Has doctor ever said you have heart condition?
  @override
  bool get hasHeartCondition;

  /// Do you feel pain in chest during physical activity?
  @override
  bool get hasChestPain;

  /// In past month, chest pain when NOT doing physical activity?
  @override
  bool get hasChestPainAtRest;

  /// Do you lose balance because of dizziness or consciousness?
  @override
  bool get hasDizzinessOrFainting;

  /// Bone or joint problem that could worsen with activity?
  @override
  bool get hasBoneJointProblem;

  /// Currently taking medication for blood pressure or heart?
  @override
  bool get takesHeartMedication;

  /// Any other reason you should not do physical activity?
  @override
  bool get hasOtherMedicalReason; // Additional ACSM screening
  /// Age ≥45 for men, ≥55 for women (higher risk)
  @override
  bool get isHighRiskAge;

  /// Family history cardiovascular disease before age 55
  @override
  bool get hasFamilyHistory;

  /// Currently smoke or quit within 6 months
  @override
  bool get currentSmoker;

  /// BMI ≥30 or waist >102cm (men) or >88cm (women)
  @override
  bool get isObese;

  /// Diabetes (Type 1 or 2)
  @override
  bool get hasDiabetes;

  /// High blood pressure (≥140/90 or on medication)
  @override
  bool get hasHighBloodPressure; // Metadata
  @override
  DateTime? get completedAt;
  @override
  bool get userAcknowledgedRisks;

  /// Create a copy of MedicalClearanceQuestionnaire
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicalClearanceQuestionnaireImplCopyWith<
    _$MedicalClearanceQuestionnaireImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
