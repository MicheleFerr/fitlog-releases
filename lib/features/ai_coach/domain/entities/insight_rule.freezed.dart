// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InsightRule _$InsightRuleFromJson(Map<String, dynamic> json) {
  return _InsightRule.fromJson(json);
}

/// @nodoc
mixin _$InsightRule {
  InsightType get insightType => throw _privateConstructorUsedError;
  int get minWeeks =>
      throw _privateConstructorUsedError; // Minimum weeks of data required
  double get volumeThreshold =>
      throw _privateConstructorUsedError; // ±% volume change to trigger
  Map<ExperienceLevel, PersonalizedThreshold> get personalizedThresholds =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InsightRuleCopyWith<InsightRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsightRuleCopyWith<$Res> {
  factory $InsightRuleCopyWith(
          InsightRule value, $Res Function(InsightRule) then) =
      _$InsightRuleCopyWithImpl<$Res, InsightRule>;
  @useResult
  $Res call(
      {InsightType insightType,
      int minWeeks,
      double volumeThreshold,
      Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds});
}

/// @nodoc
class _$InsightRuleCopyWithImpl<$Res, $Val extends InsightRule>
    implements $InsightRuleCopyWith<$Res> {
  _$InsightRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? insightType = null,
    Object? minWeeks = null,
    Object? volumeThreshold = null,
    Object? personalizedThresholds = null,
  }) {
    return _then(_value.copyWith(
      insightType: null == insightType
          ? _value.insightType
          : insightType // ignore: cast_nullable_to_non_nullable
              as InsightType,
      minWeeks: null == minWeeks
          ? _value.minWeeks
          : minWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      volumeThreshold: null == volumeThreshold
          ? _value.volumeThreshold
          : volumeThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      personalizedThresholds: null == personalizedThresholds
          ? _value.personalizedThresholds
          : personalizedThresholds // ignore: cast_nullable_to_non_nullable
              as Map<ExperienceLevel, PersonalizedThreshold>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InsightRuleImplCopyWith<$Res>
    implements $InsightRuleCopyWith<$Res> {
  factory _$$InsightRuleImplCopyWith(
          _$InsightRuleImpl value, $Res Function(_$InsightRuleImpl) then) =
      __$$InsightRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {InsightType insightType,
      int minWeeks,
      double volumeThreshold,
      Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds});
}

/// @nodoc
class __$$InsightRuleImplCopyWithImpl<$Res>
    extends _$InsightRuleCopyWithImpl<$Res, _$InsightRuleImpl>
    implements _$$InsightRuleImplCopyWith<$Res> {
  __$$InsightRuleImplCopyWithImpl(
      _$InsightRuleImpl _value, $Res Function(_$InsightRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? insightType = null,
    Object? minWeeks = null,
    Object? volumeThreshold = null,
    Object? personalizedThresholds = null,
  }) {
    return _then(_$InsightRuleImpl(
      insightType: null == insightType
          ? _value.insightType
          : insightType // ignore: cast_nullable_to_non_nullable
              as InsightType,
      minWeeks: null == minWeeks
          ? _value.minWeeks
          : minWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      volumeThreshold: null == volumeThreshold
          ? _value.volumeThreshold
          : volumeThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      personalizedThresholds: null == personalizedThresholds
          ? _value._personalizedThresholds
          : personalizedThresholds // ignore: cast_nullable_to_non_nullable
              as Map<ExperienceLevel, PersonalizedThreshold>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InsightRuleImpl implements _InsightRule {
  const _$InsightRuleImpl(
      {required this.insightType,
      required this.minWeeks,
      required this.volumeThreshold,
      required final Map<ExperienceLevel, PersonalizedThreshold>
          personalizedThresholds})
      : _personalizedThresholds = personalizedThresholds;

  factory _$InsightRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsightRuleImplFromJson(json);

  @override
  final InsightType insightType;
  @override
  final int minWeeks;
// Minimum weeks of data required
  @override
  final double volumeThreshold;
// ±% volume change to trigger
  final Map<ExperienceLevel, PersonalizedThreshold> _personalizedThresholds;
// ±% volume change to trigger
  @override
  Map<ExperienceLevel, PersonalizedThreshold> get personalizedThresholds {
    if (_personalizedThresholds is EqualUnmodifiableMapView)
      return _personalizedThresholds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_personalizedThresholds);
  }

  @override
  String toString() {
    return 'InsightRule(insightType: $insightType, minWeeks: $minWeeks, volumeThreshold: $volumeThreshold, personalizedThresholds: $personalizedThresholds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsightRuleImpl &&
            (identical(other.insightType, insightType) ||
                other.insightType == insightType) &&
            (identical(other.minWeeks, minWeeks) ||
                other.minWeeks == minWeeks) &&
            (identical(other.volumeThreshold, volumeThreshold) ||
                other.volumeThreshold == volumeThreshold) &&
            const DeepCollectionEquality().equals(
                other._personalizedThresholds, _personalizedThresholds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      insightType,
      minWeeks,
      volumeThreshold,
      const DeepCollectionEquality().hash(_personalizedThresholds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InsightRuleImplCopyWith<_$InsightRuleImpl> get copyWith =>
      __$$InsightRuleImplCopyWithImpl<_$InsightRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InsightRuleImplToJson(
      this,
    );
  }
}

abstract class _InsightRule implements InsightRule {
  const factory _InsightRule(
      {required final InsightType insightType,
      required final int minWeeks,
      required final double volumeThreshold,
      required final Map<ExperienceLevel, PersonalizedThreshold>
          personalizedThresholds}) = _$InsightRuleImpl;

  factory _InsightRule.fromJson(Map<String, dynamic> json) =
      _$InsightRuleImpl.fromJson;

  @override
  InsightType get insightType;
  @override
  int get minWeeks;
  @override // Minimum weeks of data required
  double get volumeThreshold;
  @override // ±% volume change to trigger
  Map<ExperienceLevel, PersonalizedThreshold> get personalizedThresholds;
  @override
  @JsonKey(ignore: true)
  _$$InsightRuleImplCopyWith<_$InsightRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonalizedThreshold _$PersonalizedThresholdFromJson(
    Map<String, dynamic> json) {
  return _PersonalizedThreshold.fromJson(json);
}

/// @nodoc
mixin _$PersonalizedThreshold {
  double get mev =>
      throw _privateConstructorUsedError; // Minimum Effective Volume (sets per week)
  double get mav =>
      throw _privateConstructorUsedError; // Maximum Adaptive Volume (sets per week)
  double get mrv => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersonalizedThresholdCopyWith<PersonalizedThreshold> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonalizedThresholdCopyWith<$Res> {
  factory $PersonalizedThresholdCopyWith(PersonalizedThreshold value,
          $Res Function(PersonalizedThreshold) then) =
      _$PersonalizedThresholdCopyWithImpl<$Res, PersonalizedThreshold>;
  @useResult
  $Res call({double mev, double mav, double mrv});
}

/// @nodoc
class _$PersonalizedThresholdCopyWithImpl<$Res,
        $Val extends PersonalizedThreshold>
    implements $PersonalizedThresholdCopyWith<$Res> {
  _$PersonalizedThresholdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mev = null,
    Object? mav = null,
    Object? mrv = null,
  }) {
    return _then(_value.copyWith(
      mev: null == mev
          ? _value.mev
          : mev // ignore: cast_nullable_to_non_nullable
              as double,
      mav: null == mav
          ? _value.mav
          : mav // ignore: cast_nullable_to_non_nullable
              as double,
      mrv: null == mrv
          ? _value.mrv
          : mrv // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonalizedThresholdImplCopyWith<$Res>
    implements $PersonalizedThresholdCopyWith<$Res> {
  factory _$$PersonalizedThresholdImplCopyWith(
          _$PersonalizedThresholdImpl value,
          $Res Function(_$PersonalizedThresholdImpl) then) =
      __$$PersonalizedThresholdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double mev, double mav, double mrv});
}

/// @nodoc
class __$$PersonalizedThresholdImplCopyWithImpl<$Res>
    extends _$PersonalizedThresholdCopyWithImpl<$Res,
        _$PersonalizedThresholdImpl>
    implements _$$PersonalizedThresholdImplCopyWith<$Res> {
  __$$PersonalizedThresholdImplCopyWithImpl(_$PersonalizedThresholdImpl _value,
      $Res Function(_$PersonalizedThresholdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mev = null,
    Object? mav = null,
    Object? mrv = null,
  }) {
    return _then(_$PersonalizedThresholdImpl(
      mev: null == mev
          ? _value.mev
          : mev // ignore: cast_nullable_to_non_nullable
              as double,
      mav: null == mav
          ? _value.mav
          : mav // ignore: cast_nullable_to_non_nullable
              as double,
      mrv: null == mrv
          ? _value.mrv
          : mrv // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonalizedThresholdImpl implements _PersonalizedThreshold {
  const _$PersonalizedThresholdImpl(
      {required this.mev, required this.mav, required this.mrv});

  factory _$PersonalizedThresholdImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonalizedThresholdImplFromJson(json);

  @override
  final double mev;
// Minimum Effective Volume (sets per week)
  @override
  final double mav;
// Maximum Adaptive Volume (sets per week)
  @override
  final double mrv;

  @override
  String toString() {
    return 'PersonalizedThreshold(mev: $mev, mav: $mav, mrv: $mrv)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonalizedThresholdImpl &&
            (identical(other.mev, mev) || other.mev == mev) &&
            (identical(other.mav, mav) || other.mav == mav) &&
            (identical(other.mrv, mrv) || other.mrv == mrv));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, mev, mav, mrv);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonalizedThresholdImplCopyWith<_$PersonalizedThresholdImpl>
      get copyWith => __$$PersonalizedThresholdImplCopyWithImpl<
          _$PersonalizedThresholdImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonalizedThresholdImplToJson(
      this,
    );
  }
}

abstract class _PersonalizedThreshold implements PersonalizedThreshold {
  const factory _PersonalizedThreshold(
      {required final double mev,
      required final double mav,
      required final double mrv}) = _$PersonalizedThresholdImpl;

  factory _PersonalizedThreshold.fromJson(Map<String, dynamic> json) =
      _$PersonalizedThresholdImpl.fromJson;

  @override
  double get mev;
  @override // Minimum Effective Volume (sets per week)
  double get mav;
  @override // Maximum Adaptive Volume (sets per week)
  double get mrv;
  @override
  @JsonKey(ignore: true)
  _$$PersonalizedThresholdImplCopyWith<_$PersonalizedThresholdImpl>
      get copyWith => throw _privateConstructorUsedError;
}
