// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_recovery_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MuscleRecoveryData _$MuscleRecoveryDataFromJson(Map<String, dynamic> json) {
  return _MuscleRecoveryData.fromJson(json);
}

/// @nodoc
mixin _$MuscleRecoveryData {
  /// Map of muscle group to recovery status
  ///
  /// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
  /// **Values**: MuscleRecoveryStatus with detailed metrics
  Map<MuscleGroup, MuscleRecoveryStatus> get muscleGroups =>
      throw _privateConstructorUsedError;

  /// Overall recovery score (0-100)
  ///
  /// **Calculation**: Average of all muscle group recovery scores
  /// - 90-100: All muscles fully recovered
  /// - 75-89: Most muscles recovered
  /// - 60-74: Mixed recovery status
  /// - 40-59: Multiple muscles fatigued
  /// - 0-39: Significant fatigue across muscles
  int get overallRecoveryScore => throw _privateConstructorUsedError;

  /// Timestamp when data was calculated
  DateTime? get calculatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MuscleRecoveryDataCopyWith<MuscleRecoveryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleRecoveryDataCopyWith<$Res> {
  factory $MuscleRecoveryDataCopyWith(
          MuscleRecoveryData value, $Res Function(MuscleRecoveryData) then) =
      _$MuscleRecoveryDataCopyWithImpl<$Res, MuscleRecoveryData>;
  @useResult
  $Res call(
      {Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,
      int overallRecoveryScore,
      DateTime? calculatedAt});
}

/// @nodoc
class _$MuscleRecoveryDataCopyWithImpl<$Res, $Val extends MuscleRecoveryData>
    implements $MuscleRecoveryDataCopyWith<$Res> {
  _$MuscleRecoveryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroups = null,
    Object? overallRecoveryScore = null,
    Object? calculatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      muscleGroups: null == muscleGroups
          ? _value.muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, MuscleRecoveryStatus>,
      overallRecoveryScore: null == overallRecoveryScore
          ? _value.overallRecoveryScore
          : overallRecoveryScore // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MuscleRecoveryDataImplCopyWith<$Res>
    implements $MuscleRecoveryDataCopyWith<$Res> {
  factory _$$MuscleRecoveryDataImplCopyWith(_$MuscleRecoveryDataImpl value,
          $Res Function(_$MuscleRecoveryDataImpl) then) =
      __$$MuscleRecoveryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,
      int overallRecoveryScore,
      DateTime? calculatedAt});
}

/// @nodoc
class __$$MuscleRecoveryDataImplCopyWithImpl<$Res>
    extends _$MuscleRecoveryDataCopyWithImpl<$Res, _$MuscleRecoveryDataImpl>
    implements _$$MuscleRecoveryDataImplCopyWith<$Res> {
  __$$MuscleRecoveryDataImplCopyWithImpl(_$MuscleRecoveryDataImpl _value,
      $Res Function(_$MuscleRecoveryDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroups = null,
    Object? overallRecoveryScore = null,
    Object? calculatedAt = freezed,
  }) {
    return _then(_$MuscleRecoveryDataImpl(
      muscleGroups: null == muscleGroups
          ? _value._muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, MuscleRecoveryStatus>,
      overallRecoveryScore: null == overallRecoveryScore
          ? _value.overallRecoveryScore
          : overallRecoveryScore // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleRecoveryDataImpl extends _MuscleRecoveryData {
  const _$MuscleRecoveryDataImpl(
      {required final Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,
      required this.overallRecoveryScore,
      this.calculatedAt = null})
      : _muscleGroups = muscleGroups,
        super._();

  factory _$MuscleRecoveryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleRecoveryDataImplFromJson(json);

  /// Map of muscle group to recovery status
  ///
  /// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
  /// **Values**: MuscleRecoveryStatus with detailed metrics
  final Map<MuscleGroup, MuscleRecoveryStatus> _muscleGroups;

  /// Map of muscle group to recovery status
  ///
  /// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
  /// **Values**: MuscleRecoveryStatus with detailed metrics
  @override
  Map<MuscleGroup, MuscleRecoveryStatus> get muscleGroups {
    if (_muscleGroups is EqualUnmodifiableMapView) return _muscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_muscleGroups);
  }

  /// Overall recovery score (0-100)
  ///
  /// **Calculation**: Average of all muscle group recovery scores
  /// - 90-100: All muscles fully recovered
  /// - 75-89: Most muscles recovered
  /// - 60-74: Mixed recovery status
  /// - 40-59: Multiple muscles fatigued
  /// - 0-39: Significant fatigue across muscles
  @override
  final int overallRecoveryScore;

  /// Timestamp when data was calculated
  @override
  @JsonKey()
  final DateTime? calculatedAt;

  @override
  String toString() {
    return 'MuscleRecoveryData(muscleGroups: $muscleGroups, overallRecoveryScore: $overallRecoveryScore, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleRecoveryDataImpl &&
            const DeepCollectionEquality()
                .equals(other._muscleGroups, _muscleGroups) &&
            (identical(other.overallRecoveryScore, overallRecoveryScore) ||
                other.overallRecoveryScore == overallRecoveryScore) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_muscleGroups),
      overallRecoveryScore,
      calculatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleRecoveryDataImplCopyWith<_$MuscleRecoveryDataImpl> get copyWith =>
      __$$MuscleRecoveryDataImplCopyWithImpl<_$MuscleRecoveryDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleRecoveryDataImplToJson(
      this,
    );
  }
}

abstract class _MuscleRecoveryData extends MuscleRecoveryData {
  const factory _MuscleRecoveryData(
      {required final Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,
      required final int overallRecoveryScore,
      final DateTime? calculatedAt}) = _$MuscleRecoveryDataImpl;
  const _MuscleRecoveryData._() : super._();

  factory _MuscleRecoveryData.fromJson(Map<String, dynamic> json) =
      _$MuscleRecoveryDataImpl.fromJson;

  @override

  /// Map of muscle group to recovery status
  ///
  /// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
  /// **Values**: MuscleRecoveryStatus with detailed metrics
  Map<MuscleGroup, MuscleRecoveryStatus> get muscleGroups;
  @override

  /// Overall recovery score (0-100)
  ///
  /// **Calculation**: Average of all muscle group recovery scores
  /// - 90-100: All muscles fully recovered
  /// - 75-89: Most muscles recovered
  /// - 60-74: Mixed recovery status
  /// - 40-59: Multiple muscles fatigued
  /// - 0-39: Significant fatigue across muscles
  int get overallRecoveryScore;
  @override

  /// Timestamp when data was calculated
  DateTime? get calculatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MuscleRecoveryDataImplCopyWith<_$MuscleRecoveryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MuscleRecoveryStatus _$MuscleRecoveryStatusFromJson(Map<String, dynamic> json) {
  return _MuscleRecoveryStatus.fromJson(json);
}

/// @nodoc
mixin _$MuscleRecoveryStatus {
  /// Muscle group this status applies to
  MuscleGroup get group => throw _privateConstructorUsedError;

  /// Current recovery status
  RecoveryStatus get status => throw _privateConstructorUsedError;

  /// Days since last workout for this muscle
  int get daysSinceLastWorkout => throw _privateConstructorUsedError;

  /// Total volume load in last 7 days (sets × reps × weight)
  ///
  /// Used to assess training intensity per muscle
  int get volumeLoad => throw _privateConstructorUsedError;

  /// Human-readable recommendation
  ///
  /// **Examples**:
  /// - "Ready for high volume training" (Fully Recovered)
  /// - "Ready for normal training" (Recovered)
  /// - "Light training recommended" (Partially Recovered)
  /// - "Rest or alternative muscle groups" (Fatigued)
  String get recommendedAction => throw _privateConstructorUsedError;

  /// Optional: Estimated hours until fully recovered
  ///
  /// **Calculation**: Based on 48-72h recovery window
  /// - <24h: 24-48h remaining
  /// - 24-48h: 0-24h remaining
  /// - 48h+: 0h (fully recovered)
  int? get hoursUntilFullyRecovered => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MuscleRecoveryStatusCopyWith<MuscleRecoveryStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleRecoveryStatusCopyWith<$Res> {
  factory $MuscleRecoveryStatusCopyWith(MuscleRecoveryStatus value,
          $Res Function(MuscleRecoveryStatus) then) =
      _$MuscleRecoveryStatusCopyWithImpl<$Res, MuscleRecoveryStatus>;
  @useResult
  $Res call(
      {MuscleGroup group,
      RecoveryStatus status,
      int daysSinceLastWorkout,
      int volumeLoad,
      String recommendedAction,
      int? hoursUntilFullyRecovered});
}

/// @nodoc
class _$MuscleRecoveryStatusCopyWithImpl<$Res,
        $Val extends MuscleRecoveryStatus>
    implements $MuscleRecoveryStatusCopyWith<$Res> {
  _$MuscleRecoveryStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group = null,
    Object? status = null,
    Object? daysSinceLastWorkout = null,
    Object? volumeLoad = null,
    Object? recommendedAction = null,
    Object? hoursUntilFullyRecovered = freezed,
  }) {
    return _then(_value.copyWith(
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as MuscleGroup,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RecoveryStatus,
      daysSinceLastWorkout: null == daysSinceLastWorkout
          ? _value.daysSinceLastWorkout
          : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
              as int,
      volumeLoad: null == volumeLoad
          ? _value.volumeLoad
          : volumeLoad // ignore: cast_nullable_to_non_nullable
              as int,
      recommendedAction: null == recommendedAction
          ? _value.recommendedAction
          : recommendedAction // ignore: cast_nullable_to_non_nullable
              as String,
      hoursUntilFullyRecovered: freezed == hoursUntilFullyRecovered
          ? _value.hoursUntilFullyRecovered
          : hoursUntilFullyRecovered // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MuscleRecoveryStatusImplCopyWith<$Res>
    implements $MuscleRecoveryStatusCopyWith<$Res> {
  factory _$$MuscleRecoveryStatusImplCopyWith(_$MuscleRecoveryStatusImpl value,
          $Res Function(_$MuscleRecoveryStatusImpl) then) =
      __$$MuscleRecoveryStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MuscleGroup group,
      RecoveryStatus status,
      int daysSinceLastWorkout,
      int volumeLoad,
      String recommendedAction,
      int? hoursUntilFullyRecovered});
}

/// @nodoc
class __$$MuscleRecoveryStatusImplCopyWithImpl<$Res>
    extends _$MuscleRecoveryStatusCopyWithImpl<$Res, _$MuscleRecoveryStatusImpl>
    implements _$$MuscleRecoveryStatusImplCopyWith<$Res> {
  __$$MuscleRecoveryStatusImplCopyWithImpl(_$MuscleRecoveryStatusImpl _value,
      $Res Function(_$MuscleRecoveryStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group = null,
    Object? status = null,
    Object? daysSinceLastWorkout = null,
    Object? volumeLoad = null,
    Object? recommendedAction = null,
    Object? hoursUntilFullyRecovered = freezed,
  }) {
    return _then(_$MuscleRecoveryStatusImpl(
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as MuscleGroup,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RecoveryStatus,
      daysSinceLastWorkout: null == daysSinceLastWorkout
          ? _value.daysSinceLastWorkout
          : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
              as int,
      volumeLoad: null == volumeLoad
          ? _value.volumeLoad
          : volumeLoad // ignore: cast_nullable_to_non_nullable
              as int,
      recommendedAction: null == recommendedAction
          ? _value.recommendedAction
          : recommendedAction // ignore: cast_nullable_to_non_nullable
              as String,
      hoursUntilFullyRecovered: freezed == hoursUntilFullyRecovered
          ? _value.hoursUntilFullyRecovered
          : hoursUntilFullyRecovered // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleRecoveryStatusImpl extends _MuscleRecoveryStatus {
  const _$MuscleRecoveryStatusImpl(
      {required this.group,
      required this.status,
      required this.daysSinceLastWorkout,
      required this.volumeLoad,
      required this.recommendedAction,
      this.hoursUntilFullyRecovered})
      : super._();

  factory _$MuscleRecoveryStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleRecoveryStatusImplFromJson(json);

  /// Muscle group this status applies to
  @override
  final MuscleGroup group;

  /// Current recovery status
  @override
  final RecoveryStatus status;

  /// Days since last workout for this muscle
  @override
  final int daysSinceLastWorkout;

  /// Total volume load in last 7 days (sets × reps × weight)
  ///
  /// Used to assess training intensity per muscle
  @override
  final int volumeLoad;

  /// Human-readable recommendation
  ///
  /// **Examples**:
  /// - "Ready for high volume training" (Fully Recovered)
  /// - "Ready for normal training" (Recovered)
  /// - "Light training recommended" (Partially Recovered)
  /// - "Rest or alternative muscle groups" (Fatigued)
  @override
  final String recommendedAction;

  /// Optional: Estimated hours until fully recovered
  ///
  /// **Calculation**: Based on 48-72h recovery window
  /// - <24h: 24-48h remaining
  /// - 24-48h: 0-24h remaining
  /// - 48h+: 0h (fully recovered)
  @override
  final int? hoursUntilFullyRecovered;

  @override
  String toString() {
    return 'MuscleRecoveryStatus(group: $group, status: $status, daysSinceLastWorkout: $daysSinceLastWorkout, volumeLoad: $volumeLoad, recommendedAction: $recommendedAction, hoursUntilFullyRecovered: $hoursUntilFullyRecovered)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleRecoveryStatusImpl &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.daysSinceLastWorkout, daysSinceLastWorkout) ||
                other.daysSinceLastWorkout == daysSinceLastWorkout) &&
            (identical(other.volumeLoad, volumeLoad) ||
                other.volumeLoad == volumeLoad) &&
            (identical(other.recommendedAction, recommendedAction) ||
                other.recommendedAction == recommendedAction) &&
            (identical(
                    other.hoursUntilFullyRecovered, hoursUntilFullyRecovered) ||
                other.hoursUntilFullyRecovered == hoursUntilFullyRecovered));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      group,
      status,
      daysSinceLastWorkout,
      volumeLoad,
      recommendedAction,
      hoursUntilFullyRecovered);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleRecoveryStatusImplCopyWith<_$MuscleRecoveryStatusImpl>
      get copyWith =>
          __$$MuscleRecoveryStatusImplCopyWithImpl<_$MuscleRecoveryStatusImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleRecoveryStatusImplToJson(
      this,
    );
  }
}

abstract class _MuscleRecoveryStatus extends MuscleRecoveryStatus {
  const factory _MuscleRecoveryStatus(
      {required final MuscleGroup group,
      required final RecoveryStatus status,
      required final int daysSinceLastWorkout,
      required final int volumeLoad,
      required final String recommendedAction,
      final int? hoursUntilFullyRecovered}) = _$MuscleRecoveryStatusImpl;
  const _MuscleRecoveryStatus._() : super._();

  factory _MuscleRecoveryStatus.fromJson(Map<String, dynamic> json) =
      _$MuscleRecoveryStatusImpl.fromJson;

  @override

  /// Muscle group this status applies to
  MuscleGroup get group;
  @override

  /// Current recovery status
  RecoveryStatus get status;
  @override

  /// Days since last workout for this muscle
  int get daysSinceLastWorkout;
  @override

  /// Total volume load in last 7 days (sets × reps × weight)
  ///
  /// Used to assess training intensity per muscle
  int get volumeLoad;
  @override

  /// Human-readable recommendation
  ///
  /// **Examples**:
  /// - "Ready for high volume training" (Fully Recovered)
  /// - "Ready for normal training" (Recovered)
  /// - "Light training recommended" (Partially Recovered)
  /// - "Rest or alternative muscle groups" (Fatigued)
  String get recommendedAction;
  @override

  /// Optional: Estimated hours until fully recovered
  ///
  /// **Calculation**: Based on 48-72h recovery window
  /// - <24h: 24-48h remaining
  /// - 24-48h: 0-24h remaining
  /// - 48h+: 0h (fully recovered)
  int? get hoursUntilFullyRecovered;
  @override
  @JsonKey(ignore: true)
  _$$MuscleRecoveryStatusImplCopyWith<_$MuscleRecoveryStatusImpl>
      get copyWith => throw _privateConstructorUsedError;
}
