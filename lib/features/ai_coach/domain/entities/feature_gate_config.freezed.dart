// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feature_gate_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeatureGateConfig _$FeatureGateConfigFromJson(Map<String, dynamic> json) {
  return _FeatureGateConfig.fromJson(json);
}

/// @nodoc
mixin _$FeatureGateConfig {
  /// Feature being gated
  AiCoachFeature get feature => throw _privateConstructorUsedError;

  /// Feature display name (localization key)
  String get displayNameKey => throw _privateConstructorUsedError;

  /// Feature description (localization key)
  String get descriptionKey => throw _privateConstructorUsedError;

  /// Gate rules (ALL must be satisfied)
  List<GateRule> get rules => throw _privateConstructorUsedError;

  /// Whether feature is globally enabled
  bool get isGloballyEnabled => throw _privateConstructorUsedError;

  /// Default enabled state if no rules apply
  bool get defaultEnabled => throw _privateConstructorUsedError;

  /// Whether user can manually toggle in settings
  bool get userConfigurable => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeatureGateConfigCopyWith<FeatureGateConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeatureGateConfigCopyWith<$Res> {
  factory $FeatureGateConfigCopyWith(
          FeatureGateConfig value, $Res Function(FeatureGateConfig) then) =
      _$FeatureGateConfigCopyWithImpl<$Res, FeatureGateConfig>;
  @useResult
  $Res call(
      {AiCoachFeature feature,
      String displayNameKey,
      String descriptionKey,
      List<GateRule> rules,
      bool isGloballyEnabled,
      bool defaultEnabled,
      bool userConfigurable});
}

/// @nodoc
class _$FeatureGateConfigCopyWithImpl<$Res, $Val extends FeatureGateConfig>
    implements $FeatureGateConfigCopyWith<$Res> {
  _$FeatureGateConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feature = null,
    Object? displayNameKey = null,
    Object? descriptionKey = null,
    Object? rules = null,
    Object? isGloballyEnabled = null,
    Object? defaultEnabled = null,
    Object? userConfigurable = null,
  }) {
    return _then(_value.copyWith(
      feature: null == feature
          ? _value.feature
          : feature // ignore: cast_nullable_to_non_nullable
              as AiCoachFeature,
      displayNameKey: null == displayNameKey
          ? _value.displayNameKey
          : displayNameKey // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionKey: null == descriptionKey
          ? _value.descriptionKey
          : descriptionKey // ignore: cast_nullable_to_non_nullable
              as String,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<GateRule>,
      isGloballyEnabled: null == isGloballyEnabled
          ? _value.isGloballyEnabled
          : isGloballyEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultEnabled: null == defaultEnabled
          ? _value.defaultEnabled
          : defaultEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      userConfigurable: null == userConfigurable
          ? _value.userConfigurable
          : userConfigurable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeatureGateConfigImplCopyWith<$Res>
    implements $FeatureGateConfigCopyWith<$Res> {
  factory _$$FeatureGateConfigImplCopyWith(_$FeatureGateConfigImpl value,
          $Res Function(_$FeatureGateConfigImpl) then) =
      __$$FeatureGateConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AiCoachFeature feature,
      String displayNameKey,
      String descriptionKey,
      List<GateRule> rules,
      bool isGloballyEnabled,
      bool defaultEnabled,
      bool userConfigurable});
}

/// @nodoc
class __$$FeatureGateConfigImplCopyWithImpl<$Res>
    extends _$FeatureGateConfigCopyWithImpl<$Res, _$FeatureGateConfigImpl>
    implements _$$FeatureGateConfigImplCopyWith<$Res> {
  __$$FeatureGateConfigImplCopyWithImpl(_$FeatureGateConfigImpl _value,
      $Res Function(_$FeatureGateConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feature = null,
    Object? displayNameKey = null,
    Object? descriptionKey = null,
    Object? rules = null,
    Object? isGloballyEnabled = null,
    Object? defaultEnabled = null,
    Object? userConfigurable = null,
  }) {
    return _then(_$FeatureGateConfigImpl(
      feature: null == feature
          ? _value.feature
          : feature // ignore: cast_nullable_to_non_nullable
              as AiCoachFeature,
      displayNameKey: null == displayNameKey
          ? _value.displayNameKey
          : displayNameKey // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionKey: null == descriptionKey
          ? _value.descriptionKey
          : descriptionKey // ignore: cast_nullable_to_non_nullable
              as String,
      rules: null == rules
          ? _value._rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<GateRule>,
      isGloballyEnabled: null == isGloballyEnabled
          ? _value.isGloballyEnabled
          : isGloballyEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultEnabled: null == defaultEnabled
          ? _value.defaultEnabled
          : defaultEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      userConfigurable: null == userConfigurable
          ? _value.userConfigurable
          : userConfigurable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeatureGateConfigImpl implements _FeatureGateConfig {
  const _$FeatureGateConfigImpl(
      {required this.feature,
      required this.displayNameKey,
      required this.descriptionKey,
      final List<GateRule> rules = const [],
      this.isGloballyEnabled = true,
      this.defaultEnabled = false,
      this.userConfigurable = true})
      : _rules = rules;

  factory _$FeatureGateConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeatureGateConfigImplFromJson(json);

  /// Feature being gated
  @override
  final AiCoachFeature feature;

  /// Feature display name (localization key)
  @override
  final String displayNameKey;

  /// Feature description (localization key)
  @override
  final String descriptionKey;

  /// Gate rules (ALL must be satisfied)
  final List<GateRule> _rules;

  /// Gate rules (ALL must be satisfied)
  @override
  @JsonKey()
  List<GateRule> get rules {
    if (_rules is EqualUnmodifiableListView) return _rules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rules);
  }

  /// Whether feature is globally enabled
  @override
  @JsonKey()
  final bool isGloballyEnabled;

  /// Default enabled state if no rules apply
  @override
  @JsonKey()
  final bool defaultEnabled;

  /// Whether user can manually toggle in settings
  @override
  @JsonKey()
  final bool userConfigurable;

  @override
  String toString() {
    return 'FeatureGateConfig(feature: $feature, displayNameKey: $displayNameKey, descriptionKey: $descriptionKey, rules: $rules, isGloballyEnabled: $isGloballyEnabled, defaultEnabled: $defaultEnabled, userConfigurable: $userConfigurable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeatureGateConfigImpl &&
            (identical(other.feature, feature) || other.feature == feature) &&
            (identical(other.displayNameKey, displayNameKey) ||
                other.displayNameKey == displayNameKey) &&
            (identical(other.descriptionKey, descriptionKey) ||
                other.descriptionKey == descriptionKey) &&
            const DeepCollectionEquality().equals(other._rules, _rules) &&
            (identical(other.isGloballyEnabled, isGloballyEnabled) ||
                other.isGloballyEnabled == isGloballyEnabled) &&
            (identical(other.defaultEnabled, defaultEnabled) ||
                other.defaultEnabled == defaultEnabled) &&
            (identical(other.userConfigurable, userConfigurable) ||
                other.userConfigurable == userConfigurable));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      feature,
      displayNameKey,
      descriptionKey,
      const DeepCollectionEquality().hash(_rules),
      isGloballyEnabled,
      defaultEnabled,
      userConfigurable);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeatureGateConfigImplCopyWith<_$FeatureGateConfigImpl> get copyWith =>
      __$$FeatureGateConfigImplCopyWithImpl<_$FeatureGateConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeatureGateConfigImplToJson(
      this,
    );
  }
}

abstract class _FeatureGateConfig implements FeatureGateConfig {
  const factory _FeatureGateConfig(
      {required final AiCoachFeature feature,
      required final String displayNameKey,
      required final String descriptionKey,
      final List<GateRule> rules,
      final bool isGloballyEnabled,
      final bool defaultEnabled,
      final bool userConfigurable}) = _$FeatureGateConfigImpl;

  factory _FeatureGateConfig.fromJson(Map<String, dynamic> json) =
      _$FeatureGateConfigImpl.fromJson;

  @override

  /// Feature being gated
  AiCoachFeature get feature;
  @override

  /// Feature display name (localization key)
  String get displayNameKey;
  @override

  /// Feature description (localization key)
  String get descriptionKey;
  @override

  /// Gate rules (ALL must be satisfied)
  List<GateRule> get rules;
  @override

  /// Whether feature is globally enabled
  bool get isGloballyEnabled;
  @override

  /// Default enabled state if no rules apply
  bool get defaultEnabled;
  @override

  /// Whether user can manually toggle in settings
  bool get userConfigurable;
  @override
  @JsonKey(ignore: true)
  _$$FeatureGateConfigImplCopyWith<_$FeatureGateConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GateRule _$GateRuleFromJson(Map<String, dynamic> json) {
  return _GateRule.fromJson(json);
}

/// @nodoc
mixin _$GateRule {
  /// Type of rule
  GateRuleType get type => throw _privateConstructorUsedError;

  /// Required value for rule (interpretation depends on type)
  dynamic get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GateRuleCopyWith<GateRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GateRuleCopyWith<$Res> {
  factory $GateRuleCopyWith(GateRule value, $Res Function(GateRule) then) =
      _$GateRuleCopyWithImpl<$Res, GateRule>;
  @useResult
  $Res call({GateRuleType type, dynamic value});
}

/// @nodoc
class _$GateRuleCopyWithImpl<$Res, $Val extends GateRule>
    implements $GateRuleCopyWith<$Res> {
  _$GateRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GateRuleType,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GateRuleImplCopyWith<$Res>
    implements $GateRuleCopyWith<$Res> {
  factory _$$GateRuleImplCopyWith(
          _$GateRuleImpl value, $Res Function(_$GateRuleImpl) then) =
      __$$GateRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GateRuleType type, dynamic value});
}

/// @nodoc
class __$$GateRuleImplCopyWithImpl<$Res>
    extends _$GateRuleCopyWithImpl<$Res, _$GateRuleImpl>
    implements _$$GateRuleImplCopyWith<$Res> {
  __$$GateRuleImplCopyWithImpl(
      _$GateRuleImpl _value, $Res Function(_$GateRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? value = freezed,
  }) {
    return _then(_$GateRuleImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GateRuleType,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GateRuleImpl implements _GateRule {
  const _$GateRuleImpl({required this.type, required this.value});

  factory _$GateRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$GateRuleImplFromJson(json);

  /// Type of rule
  @override
  final GateRuleType type;

  /// Required value for rule (interpretation depends on type)
  @override
  final dynamic value;

  @override
  String toString() {
    return 'GateRule(type: $type, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GateRuleImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GateRuleImplCopyWith<_$GateRuleImpl> get copyWith =>
      __$$GateRuleImplCopyWithImpl<_$GateRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GateRuleImplToJson(
      this,
    );
  }
}

abstract class _GateRule implements GateRule {
  const factory _GateRule(
      {required final GateRuleType type,
      required final dynamic value}) = _$GateRuleImpl;

  factory _GateRule.fromJson(Map<String, dynamic> json) =
      _$GateRuleImpl.fromJson;

  @override

  /// Type of rule
  GateRuleType get type;
  @override

  /// Required value for rule (interpretation depends on type)
  dynamic get value;
  @override
  @JsonKey(ignore: true)
  _$$GateRuleImplCopyWith<_$GateRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeatureGateStatus _$FeatureGateStatusFromJson(Map<String, dynamic> json) {
  return _FeatureGateStatus.fromJson(json);
}

/// @nodoc
mixin _$FeatureGateStatus {
  /// Feature being evaluated
  AiCoachFeature get feature => throw _privateConstructorUsedError;

  /// Whether feature is enabled for current user
  bool get isEnabled => throw _privateConstructorUsedError;

  /// Reason why feature is enabled/disabled
  String get reasonKey => throw _privateConstructorUsedError;

  /// Which rules passed
  List<GateRuleType> get passedRules => throw _privateConstructorUsedError;

  /// Which rules failed
  List<GateRuleType> get failedRules => throw _privateConstructorUsedError;

  /// When status was evaluated
  DateTime get evaluatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeatureGateStatusCopyWith<FeatureGateStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeatureGateStatusCopyWith<$Res> {
  factory $FeatureGateStatusCopyWith(
          FeatureGateStatus value, $Res Function(FeatureGateStatus) then) =
      _$FeatureGateStatusCopyWithImpl<$Res, FeatureGateStatus>;
  @useResult
  $Res call(
      {AiCoachFeature feature,
      bool isEnabled,
      String reasonKey,
      List<GateRuleType> passedRules,
      List<GateRuleType> failedRules,
      DateTime evaluatedAt});
}

/// @nodoc
class _$FeatureGateStatusCopyWithImpl<$Res, $Val extends FeatureGateStatus>
    implements $FeatureGateStatusCopyWith<$Res> {
  _$FeatureGateStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feature = null,
    Object? isEnabled = null,
    Object? reasonKey = null,
    Object? passedRules = null,
    Object? failedRules = null,
    Object? evaluatedAt = null,
  }) {
    return _then(_value.copyWith(
      feature: null == feature
          ? _value.feature
          : feature // ignore: cast_nullable_to_non_nullable
              as AiCoachFeature,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reasonKey: null == reasonKey
          ? _value.reasonKey
          : reasonKey // ignore: cast_nullable_to_non_nullable
              as String,
      passedRules: null == passedRules
          ? _value.passedRules
          : passedRules // ignore: cast_nullable_to_non_nullable
              as List<GateRuleType>,
      failedRules: null == failedRules
          ? _value.failedRules
          : failedRules // ignore: cast_nullable_to_non_nullable
              as List<GateRuleType>,
      evaluatedAt: null == evaluatedAt
          ? _value.evaluatedAt
          : evaluatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeatureGateStatusImplCopyWith<$Res>
    implements $FeatureGateStatusCopyWith<$Res> {
  factory _$$FeatureGateStatusImplCopyWith(_$FeatureGateStatusImpl value,
          $Res Function(_$FeatureGateStatusImpl) then) =
      __$$FeatureGateStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AiCoachFeature feature,
      bool isEnabled,
      String reasonKey,
      List<GateRuleType> passedRules,
      List<GateRuleType> failedRules,
      DateTime evaluatedAt});
}

/// @nodoc
class __$$FeatureGateStatusImplCopyWithImpl<$Res>
    extends _$FeatureGateStatusCopyWithImpl<$Res, _$FeatureGateStatusImpl>
    implements _$$FeatureGateStatusImplCopyWith<$Res> {
  __$$FeatureGateStatusImplCopyWithImpl(_$FeatureGateStatusImpl _value,
      $Res Function(_$FeatureGateStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feature = null,
    Object? isEnabled = null,
    Object? reasonKey = null,
    Object? passedRules = null,
    Object? failedRules = null,
    Object? evaluatedAt = null,
  }) {
    return _then(_$FeatureGateStatusImpl(
      feature: null == feature
          ? _value.feature
          : feature // ignore: cast_nullable_to_non_nullable
              as AiCoachFeature,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reasonKey: null == reasonKey
          ? _value.reasonKey
          : reasonKey // ignore: cast_nullable_to_non_nullable
              as String,
      passedRules: null == passedRules
          ? _value._passedRules
          : passedRules // ignore: cast_nullable_to_non_nullable
              as List<GateRuleType>,
      failedRules: null == failedRules
          ? _value._failedRules
          : failedRules // ignore: cast_nullable_to_non_nullable
              as List<GateRuleType>,
      evaluatedAt: null == evaluatedAt
          ? _value.evaluatedAt
          : evaluatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeatureGateStatusImpl implements _FeatureGateStatus {
  const _$FeatureGateStatusImpl(
      {required this.feature,
      required this.isEnabled,
      required this.reasonKey,
      final List<GateRuleType> passedRules = const [],
      final List<GateRuleType> failedRules = const [],
      required this.evaluatedAt})
      : _passedRules = passedRules,
        _failedRules = failedRules;

  factory _$FeatureGateStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeatureGateStatusImplFromJson(json);

  /// Feature being evaluated
  @override
  final AiCoachFeature feature;

  /// Whether feature is enabled for current user
  @override
  final bool isEnabled;

  /// Reason why feature is enabled/disabled
  @override
  final String reasonKey;

  /// Which rules passed
  final List<GateRuleType> _passedRules;

  /// Which rules passed
  @override
  @JsonKey()
  List<GateRuleType> get passedRules {
    if (_passedRules is EqualUnmodifiableListView) return _passedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_passedRules);
  }

  /// Which rules failed
  final List<GateRuleType> _failedRules;

  /// Which rules failed
  @override
  @JsonKey()
  List<GateRuleType> get failedRules {
    if (_failedRules is EqualUnmodifiableListView) return _failedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_failedRules);
  }

  /// When status was evaluated
  @override
  final DateTime evaluatedAt;

  @override
  String toString() {
    return 'FeatureGateStatus(feature: $feature, isEnabled: $isEnabled, reasonKey: $reasonKey, passedRules: $passedRules, failedRules: $failedRules, evaluatedAt: $evaluatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeatureGateStatusImpl &&
            (identical(other.feature, feature) || other.feature == feature) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.reasonKey, reasonKey) ||
                other.reasonKey == reasonKey) &&
            const DeepCollectionEquality()
                .equals(other._passedRules, _passedRules) &&
            const DeepCollectionEquality()
                .equals(other._failedRules, _failedRules) &&
            (identical(other.evaluatedAt, evaluatedAt) ||
                other.evaluatedAt == evaluatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      feature,
      isEnabled,
      reasonKey,
      const DeepCollectionEquality().hash(_passedRules),
      const DeepCollectionEquality().hash(_failedRules),
      evaluatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FeatureGateStatusImplCopyWith<_$FeatureGateStatusImpl> get copyWith =>
      __$$FeatureGateStatusImplCopyWithImpl<_$FeatureGateStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeatureGateStatusImplToJson(
      this,
    );
  }
}

abstract class _FeatureGateStatus implements FeatureGateStatus {
  const factory _FeatureGateStatus(
      {required final AiCoachFeature feature,
      required final bool isEnabled,
      required final String reasonKey,
      final List<GateRuleType> passedRules,
      final List<GateRuleType> failedRules,
      required final DateTime evaluatedAt}) = _$FeatureGateStatusImpl;

  factory _FeatureGateStatus.fromJson(Map<String, dynamic> json) =
      _$FeatureGateStatusImpl.fromJson;

  @override

  /// Feature being evaluated
  AiCoachFeature get feature;
  @override

  /// Whether feature is enabled for current user
  bool get isEnabled;
  @override

  /// Reason why feature is enabled/disabled
  String get reasonKey;
  @override

  /// Which rules passed
  List<GateRuleType> get passedRules;
  @override

  /// Which rules failed
  List<GateRuleType> get failedRules;
  @override

  /// When status was evaluated
  DateTime get evaluatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FeatureGateStatusImplCopyWith<_$FeatureGateStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
