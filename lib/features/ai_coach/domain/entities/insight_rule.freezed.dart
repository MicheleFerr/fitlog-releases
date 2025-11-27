// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InsightRule {

 InsightType get insightType; int get minWeeks;// Minimum weeks of data required
 double get volumeThreshold;// ±% volume change to trigger
 Map<ExperienceLevel, PersonalizedThreshold> get personalizedThresholds;
/// Create a copy of InsightRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InsightRuleCopyWith<InsightRule> get copyWith => _$InsightRuleCopyWithImpl<InsightRule>(this as InsightRule, _$identity);

  /// Serializes this InsightRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InsightRule&&(identical(other.insightType, insightType) || other.insightType == insightType)&&(identical(other.minWeeks, minWeeks) || other.minWeeks == minWeeks)&&(identical(other.volumeThreshold, volumeThreshold) || other.volumeThreshold == volumeThreshold)&&const DeepCollectionEquality().equals(other.personalizedThresholds, personalizedThresholds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,insightType,minWeeks,volumeThreshold,const DeepCollectionEquality().hash(personalizedThresholds));

@override
String toString() {
  return 'InsightRule(insightType: $insightType, minWeeks: $minWeeks, volumeThreshold: $volumeThreshold, personalizedThresholds: $personalizedThresholds)';
}


}

/// @nodoc
abstract mixin class $InsightRuleCopyWith<$Res>  {
  factory $InsightRuleCopyWith(InsightRule value, $Res Function(InsightRule) _then) = _$InsightRuleCopyWithImpl;
@useResult
$Res call({
 InsightType insightType, int minWeeks, double volumeThreshold, Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds
});




}
/// @nodoc
class _$InsightRuleCopyWithImpl<$Res>
    implements $InsightRuleCopyWith<$Res> {
  _$InsightRuleCopyWithImpl(this._self, this._then);

  final InsightRule _self;
  final $Res Function(InsightRule) _then;

/// Create a copy of InsightRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? insightType = null,Object? minWeeks = null,Object? volumeThreshold = null,Object? personalizedThresholds = null,}) {
  return _then(_self.copyWith(
insightType: null == insightType ? _self.insightType : insightType // ignore: cast_nullable_to_non_nullable
as InsightType,minWeeks: null == minWeeks ? _self.minWeeks : minWeeks // ignore: cast_nullable_to_non_nullable
as int,volumeThreshold: null == volumeThreshold ? _self.volumeThreshold : volumeThreshold // ignore: cast_nullable_to_non_nullable
as double,personalizedThresholds: null == personalizedThresholds ? _self.personalizedThresholds : personalizedThresholds // ignore: cast_nullable_to_non_nullable
as Map<ExperienceLevel, PersonalizedThreshold>,
  ));
}

}


/// Adds pattern-matching-related methods to [InsightRule].
extension InsightRulePatterns on InsightRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InsightRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InsightRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InsightRule value)  $default,){
final _that = this;
switch (_that) {
case _InsightRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InsightRule value)?  $default,){
final _that = this;
switch (_that) {
case _InsightRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InsightType insightType,  int minWeeks,  double volumeThreshold,  Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InsightRule() when $default != null:
return $default(_that.insightType,_that.minWeeks,_that.volumeThreshold,_that.personalizedThresholds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InsightType insightType,  int minWeeks,  double volumeThreshold,  Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds)  $default,) {final _that = this;
switch (_that) {
case _InsightRule():
return $default(_that.insightType,_that.minWeeks,_that.volumeThreshold,_that.personalizedThresholds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InsightType insightType,  int minWeeks,  double volumeThreshold,  Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds)?  $default,) {final _that = this;
switch (_that) {
case _InsightRule() when $default != null:
return $default(_that.insightType,_that.minWeeks,_that.volumeThreshold,_that.personalizedThresholds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InsightRule implements InsightRule {
  const _InsightRule({required this.insightType, required this.minWeeks, required this.volumeThreshold, required final  Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds}): _personalizedThresholds = personalizedThresholds;
  factory _InsightRule.fromJson(Map<String, dynamic> json) => _$InsightRuleFromJson(json);

@override final  InsightType insightType;
@override final  int minWeeks;
// Minimum weeks of data required
@override final  double volumeThreshold;
// ±% volume change to trigger
 final  Map<ExperienceLevel, PersonalizedThreshold> _personalizedThresholds;
// ±% volume change to trigger
@override Map<ExperienceLevel, PersonalizedThreshold> get personalizedThresholds {
  if (_personalizedThresholds is EqualUnmodifiableMapView) return _personalizedThresholds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_personalizedThresholds);
}


/// Create a copy of InsightRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsightRuleCopyWith<_InsightRule> get copyWith => __$InsightRuleCopyWithImpl<_InsightRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InsightRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InsightRule&&(identical(other.insightType, insightType) || other.insightType == insightType)&&(identical(other.minWeeks, minWeeks) || other.minWeeks == minWeeks)&&(identical(other.volumeThreshold, volumeThreshold) || other.volumeThreshold == volumeThreshold)&&const DeepCollectionEquality().equals(other._personalizedThresholds, _personalizedThresholds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,insightType,minWeeks,volumeThreshold,const DeepCollectionEquality().hash(_personalizedThresholds));

@override
String toString() {
  return 'InsightRule(insightType: $insightType, minWeeks: $minWeeks, volumeThreshold: $volumeThreshold, personalizedThresholds: $personalizedThresholds)';
}


}

/// @nodoc
abstract mixin class _$InsightRuleCopyWith<$Res> implements $InsightRuleCopyWith<$Res> {
  factory _$InsightRuleCopyWith(_InsightRule value, $Res Function(_InsightRule) _then) = __$InsightRuleCopyWithImpl;
@override @useResult
$Res call({
 InsightType insightType, int minWeeks, double volumeThreshold, Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds
});




}
/// @nodoc
class __$InsightRuleCopyWithImpl<$Res>
    implements _$InsightRuleCopyWith<$Res> {
  __$InsightRuleCopyWithImpl(this._self, this._then);

  final _InsightRule _self;
  final $Res Function(_InsightRule) _then;

/// Create a copy of InsightRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? insightType = null,Object? minWeeks = null,Object? volumeThreshold = null,Object? personalizedThresholds = null,}) {
  return _then(_InsightRule(
insightType: null == insightType ? _self.insightType : insightType // ignore: cast_nullable_to_non_nullable
as InsightType,minWeeks: null == minWeeks ? _self.minWeeks : minWeeks // ignore: cast_nullable_to_non_nullable
as int,volumeThreshold: null == volumeThreshold ? _self.volumeThreshold : volumeThreshold // ignore: cast_nullable_to_non_nullable
as double,personalizedThresholds: null == personalizedThresholds ? _self._personalizedThresholds : personalizedThresholds // ignore: cast_nullable_to_non_nullable
as Map<ExperienceLevel, PersonalizedThreshold>,
  ));
}


}


/// @nodoc
mixin _$PersonalizedThreshold {

 double get mev;// Minimum Effective Volume (sets per week)
 double get mav;// Maximum Adaptive Volume (sets per week)
 double get mrv;
/// Create a copy of PersonalizedThreshold
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalizedThresholdCopyWith<PersonalizedThreshold> get copyWith => _$PersonalizedThresholdCopyWithImpl<PersonalizedThreshold>(this as PersonalizedThreshold, _$identity);

  /// Serializes this PersonalizedThreshold to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalizedThreshold&&(identical(other.mev, mev) || other.mev == mev)&&(identical(other.mav, mav) || other.mav == mav)&&(identical(other.mrv, mrv) || other.mrv == mrv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mev,mav,mrv);

@override
String toString() {
  return 'PersonalizedThreshold(mev: $mev, mav: $mav, mrv: $mrv)';
}


}

/// @nodoc
abstract mixin class $PersonalizedThresholdCopyWith<$Res>  {
  factory $PersonalizedThresholdCopyWith(PersonalizedThreshold value, $Res Function(PersonalizedThreshold) _then) = _$PersonalizedThresholdCopyWithImpl;
@useResult
$Res call({
 double mev, double mav, double mrv
});




}
/// @nodoc
class _$PersonalizedThresholdCopyWithImpl<$Res>
    implements $PersonalizedThresholdCopyWith<$Res> {
  _$PersonalizedThresholdCopyWithImpl(this._self, this._then);

  final PersonalizedThreshold _self;
  final $Res Function(PersonalizedThreshold) _then;

/// Create a copy of PersonalizedThreshold
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mev = null,Object? mav = null,Object? mrv = null,}) {
  return _then(_self.copyWith(
mev: null == mev ? _self.mev : mev // ignore: cast_nullable_to_non_nullable
as double,mav: null == mav ? _self.mav : mav // ignore: cast_nullable_to_non_nullable
as double,mrv: null == mrv ? _self.mrv : mrv // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalizedThreshold].
extension PersonalizedThresholdPatterns on PersonalizedThreshold {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalizedThreshold value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalizedThreshold() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalizedThreshold value)  $default,){
final _that = this;
switch (_that) {
case _PersonalizedThreshold():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalizedThreshold value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalizedThreshold() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double mev,  double mav,  double mrv)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalizedThreshold() when $default != null:
return $default(_that.mev,_that.mav,_that.mrv);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double mev,  double mav,  double mrv)  $default,) {final _that = this;
switch (_that) {
case _PersonalizedThreshold():
return $default(_that.mev,_that.mav,_that.mrv);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double mev,  double mav,  double mrv)?  $default,) {final _that = this;
switch (_that) {
case _PersonalizedThreshold() when $default != null:
return $default(_that.mev,_that.mav,_that.mrv);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalizedThreshold implements PersonalizedThreshold {
  const _PersonalizedThreshold({required this.mev, required this.mav, required this.mrv});
  factory _PersonalizedThreshold.fromJson(Map<String, dynamic> json) => _$PersonalizedThresholdFromJson(json);

@override final  double mev;
// Minimum Effective Volume (sets per week)
@override final  double mav;
// Maximum Adaptive Volume (sets per week)
@override final  double mrv;

/// Create a copy of PersonalizedThreshold
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalizedThresholdCopyWith<_PersonalizedThreshold> get copyWith => __$PersonalizedThresholdCopyWithImpl<_PersonalizedThreshold>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalizedThresholdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalizedThreshold&&(identical(other.mev, mev) || other.mev == mev)&&(identical(other.mav, mav) || other.mav == mav)&&(identical(other.mrv, mrv) || other.mrv == mrv));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mev,mav,mrv);

@override
String toString() {
  return 'PersonalizedThreshold(mev: $mev, mav: $mav, mrv: $mrv)';
}


}

/// @nodoc
abstract mixin class _$PersonalizedThresholdCopyWith<$Res> implements $PersonalizedThresholdCopyWith<$Res> {
  factory _$PersonalizedThresholdCopyWith(_PersonalizedThreshold value, $Res Function(_PersonalizedThreshold) _then) = __$PersonalizedThresholdCopyWithImpl;
@override @useResult
$Res call({
 double mev, double mav, double mrv
});




}
/// @nodoc
class __$PersonalizedThresholdCopyWithImpl<$Res>
    implements _$PersonalizedThresholdCopyWith<$Res> {
  __$PersonalizedThresholdCopyWithImpl(this._self, this._then);

  final _PersonalizedThreshold _self;
  final $Res Function(_PersonalizedThreshold) _then;

/// Create a copy of PersonalizedThreshold
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mev = null,Object? mav = null,Object? mrv = null,}) {
  return _then(_PersonalizedThreshold(
mev: null == mev ? _self.mev : mev // ignore: cast_nullable_to_non_nullable
as double,mav: null == mav ? _self.mav : mav // ignore: cast_nullable_to_non_nullable
as double,mrv: null == mrv ? _self.mrv : mrv // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
