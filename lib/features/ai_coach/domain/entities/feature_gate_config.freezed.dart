// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feature_gate_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeatureGateConfig {

/// Feature being gated
 AiCoachFeature get feature;/// Feature display name (localization key)
 String get displayNameKey;/// Feature description (localization key)
 String get descriptionKey;/// Gate rules (ALL must be satisfied)
 List<GateRule> get rules;/// Whether feature is globally enabled
 bool get isGloballyEnabled;/// Default enabled state if no rules apply
 bool get defaultEnabled;/// Whether user can manually toggle in settings
 bool get userConfigurable;
/// Create a copy of FeatureGateConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureGateConfigCopyWith<FeatureGateConfig> get copyWith => _$FeatureGateConfigCopyWithImpl<FeatureGateConfig>(this as FeatureGateConfig, _$identity);

  /// Serializes this FeatureGateConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeatureGateConfig&&(identical(other.feature, feature) || other.feature == feature)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&const DeepCollectionEquality().equals(other.rules, rules)&&(identical(other.isGloballyEnabled, isGloballyEnabled) || other.isGloballyEnabled == isGloballyEnabled)&&(identical(other.defaultEnabled, defaultEnabled) || other.defaultEnabled == defaultEnabled)&&(identical(other.userConfigurable, userConfigurable) || other.userConfigurable == userConfigurable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,feature,displayNameKey,descriptionKey,const DeepCollectionEquality().hash(rules),isGloballyEnabled,defaultEnabled,userConfigurable);

@override
String toString() {
  return 'FeatureGateConfig(feature: $feature, displayNameKey: $displayNameKey, descriptionKey: $descriptionKey, rules: $rules, isGloballyEnabled: $isGloballyEnabled, defaultEnabled: $defaultEnabled, userConfigurable: $userConfigurable)';
}


}

/// @nodoc
abstract mixin class $FeatureGateConfigCopyWith<$Res>  {
  factory $FeatureGateConfigCopyWith(FeatureGateConfig value, $Res Function(FeatureGateConfig) _then) = _$FeatureGateConfigCopyWithImpl;
@useResult
$Res call({
 AiCoachFeature feature, String displayNameKey, String descriptionKey, List<GateRule> rules, bool isGloballyEnabled, bool defaultEnabled, bool userConfigurable
});




}
/// @nodoc
class _$FeatureGateConfigCopyWithImpl<$Res>
    implements $FeatureGateConfigCopyWith<$Res> {
  _$FeatureGateConfigCopyWithImpl(this._self, this._then);

  final FeatureGateConfig _self;
  final $Res Function(FeatureGateConfig) _then;

/// Create a copy of FeatureGateConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? feature = null,Object? displayNameKey = null,Object? descriptionKey = null,Object? rules = null,Object? isGloballyEnabled = null,Object? defaultEnabled = null,Object? userConfigurable = null,}) {
  return _then(_self.copyWith(
feature: null == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as AiCoachFeature,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<GateRule>,isGloballyEnabled: null == isGloballyEnabled ? _self.isGloballyEnabled : isGloballyEnabled // ignore: cast_nullable_to_non_nullable
as bool,defaultEnabled: null == defaultEnabled ? _self.defaultEnabled : defaultEnabled // ignore: cast_nullable_to_non_nullable
as bool,userConfigurable: null == userConfigurable ? _self.userConfigurable : userConfigurable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FeatureGateConfig].
extension FeatureGateConfigPatterns on FeatureGateConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeatureGateConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeatureGateConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeatureGateConfig value)  $default,){
final _that = this;
switch (_that) {
case _FeatureGateConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeatureGateConfig value)?  $default,){
final _that = this;
switch (_that) {
case _FeatureGateConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AiCoachFeature feature,  String displayNameKey,  String descriptionKey,  List<GateRule> rules,  bool isGloballyEnabled,  bool defaultEnabled,  bool userConfigurable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeatureGateConfig() when $default != null:
return $default(_that.feature,_that.displayNameKey,_that.descriptionKey,_that.rules,_that.isGloballyEnabled,_that.defaultEnabled,_that.userConfigurable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AiCoachFeature feature,  String displayNameKey,  String descriptionKey,  List<GateRule> rules,  bool isGloballyEnabled,  bool defaultEnabled,  bool userConfigurable)  $default,) {final _that = this;
switch (_that) {
case _FeatureGateConfig():
return $default(_that.feature,_that.displayNameKey,_that.descriptionKey,_that.rules,_that.isGloballyEnabled,_that.defaultEnabled,_that.userConfigurable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AiCoachFeature feature,  String displayNameKey,  String descriptionKey,  List<GateRule> rules,  bool isGloballyEnabled,  bool defaultEnabled,  bool userConfigurable)?  $default,) {final _that = this;
switch (_that) {
case _FeatureGateConfig() when $default != null:
return $default(_that.feature,_that.displayNameKey,_that.descriptionKey,_that.rules,_that.isGloballyEnabled,_that.defaultEnabled,_that.userConfigurable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeatureGateConfig implements FeatureGateConfig {
  const _FeatureGateConfig({required this.feature, required this.displayNameKey, required this.descriptionKey, final  List<GateRule> rules = const [], this.isGloballyEnabled = true, this.defaultEnabled = false, this.userConfigurable = true}): _rules = rules;
  factory _FeatureGateConfig.fromJson(Map<String, dynamic> json) => _$FeatureGateConfigFromJson(json);

/// Feature being gated
@override final  AiCoachFeature feature;
/// Feature display name (localization key)
@override final  String displayNameKey;
/// Feature description (localization key)
@override final  String descriptionKey;
/// Gate rules (ALL must be satisfied)
 final  List<GateRule> _rules;
/// Gate rules (ALL must be satisfied)
@override@JsonKey() List<GateRule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

/// Whether feature is globally enabled
@override@JsonKey() final  bool isGloballyEnabled;
/// Default enabled state if no rules apply
@override@JsonKey() final  bool defaultEnabled;
/// Whether user can manually toggle in settings
@override@JsonKey() final  bool userConfigurable;

/// Create a copy of FeatureGateConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureGateConfigCopyWith<_FeatureGateConfig> get copyWith => __$FeatureGateConfigCopyWithImpl<_FeatureGateConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeatureGateConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureGateConfig&&(identical(other.feature, feature) || other.feature == feature)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&const DeepCollectionEquality().equals(other._rules, _rules)&&(identical(other.isGloballyEnabled, isGloballyEnabled) || other.isGloballyEnabled == isGloballyEnabled)&&(identical(other.defaultEnabled, defaultEnabled) || other.defaultEnabled == defaultEnabled)&&(identical(other.userConfigurable, userConfigurable) || other.userConfigurable == userConfigurable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,feature,displayNameKey,descriptionKey,const DeepCollectionEquality().hash(_rules),isGloballyEnabled,defaultEnabled,userConfigurable);

@override
String toString() {
  return 'FeatureGateConfig(feature: $feature, displayNameKey: $displayNameKey, descriptionKey: $descriptionKey, rules: $rules, isGloballyEnabled: $isGloballyEnabled, defaultEnabled: $defaultEnabled, userConfigurable: $userConfigurable)';
}


}

/// @nodoc
abstract mixin class _$FeatureGateConfigCopyWith<$Res> implements $FeatureGateConfigCopyWith<$Res> {
  factory _$FeatureGateConfigCopyWith(_FeatureGateConfig value, $Res Function(_FeatureGateConfig) _then) = __$FeatureGateConfigCopyWithImpl;
@override @useResult
$Res call({
 AiCoachFeature feature, String displayNameKey, String descriptionKey, List<GateRule> rules, bool isGloballyEnabled, bool defaultEnabled, bool userConfigurable
});




}
/// @nodoc
class __$FeatureGateConfigCopyWithImpl<$Res>
    implements _$FeatureGateConfigCopyWith<$Res> {
  __$FeatureGateConfigCopyWithImpl(this._self, this._then);

  final _FeatureGateConfig _self;
  final $Res Function(_FeatureGateConfig) _then;

/// Create a copy of FeatureGateConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? feature = null,Object? displayNameKey = null,Object? descriptionKey = null,Object? rules = null,Object? isGloballyEnabled = null,Object? defaultEnabled = null,Object? userConfigurable = null,}) {
  return _then(_FeatureGateConfig(
feature: null == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as AiCoachFeature,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<GateRule>,isGloballyEnabled: null == isGloballyEnabled ? _self.isGloballyEnabled : isGloballyEnabled // ignore: cast_nullable_to_non_nullable
as bool,defaultEnabled: null == defaultEnabled ? _self.defaultEnabled : defaultEnabled // ignore: cast_nullable_to_non_nullable
as bool,userConfigurable: null == userConfigurable ? _self.userConfigurable : userConfigurable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GateRule {

/// Type of rule
 GateRuleType get type;/// Required value for rule (interpretation depends on type)
 dynamic get value;
/// Create a copy of GateRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GateRuleCopyWith<GateRule> get copyWith => _$GateRuleCopyWithImpl<GateRule>(this as GateRule, _$identity);

  /// Serializes this GateRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GateRule&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'GateRule(type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class $GateRuleCopyWith<$Res>  {
  factory $GateRuleCopyWith(GateRule value, $Res Function(GateRule) _then) = _$GateRuleCopyWithImpl;
@useResult
$Res call({
 GateRuleType type, dynamic value
});




}
/// @nodoc
class _$GateRuleCopyWithImpl<$Res>
    implements $GateRuleCopyWith<$Res> {
  _$GateRuleCopyWithImpl(this._self, this._then);

  final GateRule _self;
  final $Res Function(GateRule) _then;

/// Create a copy of GateRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GateRuleType,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [GateRule].
extension GateRulePatterns on GateRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GateRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GateRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GateRule value)  $default,){
final _that = this;
switch (_that) {
case _GateRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GateRule value)?  $default,){
final _that = this;
switch (_that) {
case _GateRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GateRuleType type,  dynamic value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GateRule() when $default != null:
return $default(_that.type,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GateRuleType type,  dynamic value)  $default,) {final _that = this;
switch (_that) {
case _GateRule():
return $default(_that.type,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GateRuleType type,  dynamic value)?  $default,) {final _that = this;
switch (_that) {
case _GateRule() when $default != null:
return $default(_that.type,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GateRule implements GateRule {
  const _GateRule({required this.type, required this.value});
  factory _GateRule.fromJson(Map<String, dynamic> json) => _$GateRuleFromJson(json);

/// Type of rule
@override final  GateRuleType type;
/// Required value for rule (interpretation depends on type)
@override final  dynamic value;

/// Create a copy of GateRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GateRuleCopyWith<_GateRule> get copyWith => __$GateRuleCopyWithImpl<_GateRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GateRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GateRule&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'GateRule(type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class _$GateRuleCopyWith<$Res> implements $GateRuleCopyWith<$Res> {
  factory _$GateRuleCopyWith(_GateRule value, $Res Function(_GateRule) _then) = __$GateRuleCopyWithImpl;
@override @useResult
$Res call({
 GateRuleType type, dynamic value
});




}
/// @nodoc
class __$GateRuleCopyWithImpl<$Res>
    implements _$GateRuleCopyWith<$Res> {
  __$GateRuleCopyWithImpl(this._self, this._then);

  final _GateRule _self;
  final $Res Function(_GateRule) _then;

/// Create a copy of GateRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? value = freezed,}) {
  return _then(_GateRule(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GateRuleType,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}


/// @nodoc
mixin _$FeatureGateStatus {

/// Feature being evaluated
 AiCoachFeature get feature;/// Whether feature is enabled for current user
 bool get isEnabled;/// Reason why feature is enabled/disabled
 String get reasonKey;/// Which rules passed
 List<GateRuleType> get passedRules;/// Which rules failed
 List<GateRuleType> get failedRules;/// When status was evaluated
 DateTime get evaluatedAt;
/// Create a copy of FeatureGateStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureGateStatusCopyWith<FeatureGateStatus> get copyWith => _$FeatureGateStatusCopyWithImpl<FeatureGateStatus>(this as FeatureGateStatus, _$identity);

  /// Serializes this FeatureGateStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeatureGateStatus&&(identical(other.feature, feature) || other.feature == feature)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.reasonKey, reasonKey) || other.reasonKey == reasonKey)&&const DeepCollectionEquality().equals(other.passedRules, passedRules)&&const DeepCollectionEquality().equals(other.failedRules, failedRules)&&(identical(other.evaluatedAt, evaluatedAt) || other.evaluatedAt == evaluatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,feature,isEnabled,reasonKey,const DeepCollectionEquality().hash(passedRules),const DeepCollectionEquality().hash(failedRules),evaluatedAt);

@override
String toString() {
  return 'FeatureGateStatus(feature: $feature, isEnabled: $isEnabled, reasonKey: $reasonKey, passedRules: $passedRules, failedRules: $failedRules, evaluatedAt: $evaluatedAt)';
}


}

/// @nodoc
abstract mixin class $FeatureGateStatusCopyWith<$Res>  {
  factory $FeatureGateStatusCopyWith(FeatureGateStatus value, $Res Function(FeatureGateStatus) _then) = _$FeatureGateStatusCopyWithImpl;
@useResult
$Res call({
 AiCoachFeature feature, bool isEnabled, String reasonKey, List<GateRuleType> passedRules, List<GateRuleType> failedRules, DateTime evaluatedAt
});




}
/// @nodoc
class _$FeatureGateStatusCopyWithImpl<$Res>
    implements $FeatureGateStatusCopyWith<$Res> {
  _$FeatureGateStatusCopyWithImpl(this._self, this._then);

  final FeatureGateStatus _self;
  final $Res Function(FeatureGateStatus) _then;

/// Create a copy of FeatureGateStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? feature = null,Object? isEnabled = null,Object? reasonKey = null,Object? passedRules = null,Object? failedRules = null,Object? evaluatedAt = null,}) {
  return _then(_self.copyWith(
feature: null == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as AiCoachFeature,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,reasonKey: null == reasonKey ? _self.reasonKey : reasonKey // ignore: cast_nullable_to_non_nullable
as String,passedRules: null == passedRules ? _self.passedRules : passedRules // ignore: cast_nullable_to_non_nullable
as List<GateRuleType>,failedRules: null == failedRules ? _self.failedRules : failedRules // ignore: cast_nullable_to_non_nullable
as List<GateRuleType>,evaluatedAt: null == evaluatedAt ? _self.evaluatedAt : evaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FeatureGateStatus].
extension FeatureGateStatusPatterns on FeatureGateStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeatureGateStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeatureGateStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeatureGateStatus value)  $default,){
final _that = this;
switch (_that) {
case _FeatureGateStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeatureGateStatus value)?  $default,){
final _that = this;
switch (_that) {
case _FeatureGateStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AiCoachFeature feature,  bool isEnabled,  String reasonKey,  List<GateRuleType> passedRules,  List<GateRuleType> failedRules,  DateTime evaluatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeatureGateStatus() when $default != null:
return $default(_that.feature,_that.isEnabled,_that.reasonKey,_that.passedRules,_that.failedRules,_that.evaluatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AiCoachFeature feature,  bool isEnabled,  String reasonKey,  List<GateRuleType> passedRules,  List<GateRuleType> failedRules,  DateTime evaluatedAt)  $default,) {final _that = this;
switch (_that) {
case _FeatureGateStatus():
return $default(_that.feature,_that.isEnabled,_that.reasonKey,_that.passedRules,_that.failedRules,_that.evaluatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AiCoachFeature feature,  bool isEnabled,  String reasonKey,  List<GateRuleType> passedRules,  List<GateRuleType> failedRules,  DateTime evaluatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FeatureGateStatus() when $default != null:
return $default(_that.feature,_that.isEnabled,_that.reasonKey,_that.passedRules,_that.failedRules,_that.evaluatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeatureGateStatus implements FeatureGateStatus {
  const _FeatureGateStatus({required this.feature, required this.isEnabled, required this.reasonKey, final  List<GateRuleType> passedRules = const [], final  List<GateRuleType> failedRules = const [], required this.evaluatedAt}): _passedRules = passedRules,_failedRules = failedRules;
  factory _FeatureGateStatus.fromJson(Map<String, dynamic> json) => _$FeatureGateStatusFromJson(json);

/// Feature being evaluated
@override final  AiCoachFeature feature;
/// Whether feature is enabled for current user
@override final  bool isEnabled;
/// Reason why feature is enabled/disabled
@override final  String reasonKey;
/// Which rules passed
 final  List<GateRuleType> _passedRules;
/// Which rules passed
@override@JsonKey() List<GateRuleType> get passedRules {
  if (_passedRules is EqualUnmodifiableListView) return _passedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_passedRules);
}

/// Which rules failed
 final  List<GateRuleType> _failedRules;
/// Which rules failed
@override@JsonKey() List<GateRuleType> get failedRules {
  if (_failedRules is EqualUnmodifiableListView) return _failedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failedRules);
}

/// When status was evaluated
@override final  DateTime evaluatedAt;

/// Create a copy of FeatureGateStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureGateStatusCopyWith<_FeatureGateStatus> get copyWith => __$FeatureGateStatusCopyWithImpl<_FeatureGateStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeatureGateStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureGateStatus&&(identical(other.feature, feature) || other.feature == feature)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.reasonKey, reasonKey) || other.reasonKey == reasonKey)&&const DeepCollectionEquality().equals(other._passedRules, _passedRules)&&const DeepCollectionEquality().equals(other._failedRules, _failedRules)&&(identical(other.evaluatedAt, evaluatedAt) || other.evaluatedAt == evaluatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,feature,isEnabled,reasonKey,const DeepCollectionEquality().hash(_passedRules),const DeepCollectionEquality().hash(_failedRules),evaluatedAt);

@override
String toString() {
  return 'FeatureGateStatus(feature: $feature, isEnabled: $isEnabled, reasonKey: $reasonKey, passedRules: $passedRules, failedRules: $failedRules, evaluatedAt: $evaluatedAt)';
}


}

/// @nodoc
abstract mixin class _$FeatureGateStatusCopyWith<$Res> implements $FeatureGateStatusCopyWith<$Res> {
  factory _$FeatureGateStatusCopyWith(_FeatureGateStatus value, $Res Function(_FeatureGateStatus) _then) = __$FeatureGateStatusCopyWithImpl;
@override @useResult
$Res call({
 AiCoachFeature feature, bool isEnabled, String reasonKey, List<GateRuleType> passedRules, List<GateRuleType> failedRules, DateTime evaluatedAt
});




}
/// @nodoc
class __$FeatureGateStatusCopyWithImpl<$Res>
    implements _$FeatureGateStatusCopyWith<$Res> {
  __$FeatureGateStatusCopyWithImpl(this._self, this._then);

  final _FeatureGateStatus _self;
  final $Res Function(_FeatureGateStatus) _then;

/// Create a copy of FeatureGateStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? feature = null,Object? isEnabled = null,Object? reasonKey = null,Object? passedRules = null,Object? failedRules = null,Object? evaluatedAt = null,}) {
  return _then(_FeatureGateStatus(
feature: null == feature ? _self.feature : feature // ignore: cast_nullable_to_non_nullable
as AiCoachFeature,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,reasonKey: null == reasonKey ? _self.reasonKey : reasonKey // ignore: cast_nullable_to_non_nullable
as String,passedRules: null == passedRules ? _self._passedRules : passedRules // ignore: cast_nullable_to_non_nullable
as List<GateRuleType>,failedRules: null == failedRules ? _self._failedRules : failedRules // ignore: cast_nullable_to_non_nullable
as List<GateRuleType>,evaluatedAt: null == evaluatedAt ? _self.evaluatedAt : evaluatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
