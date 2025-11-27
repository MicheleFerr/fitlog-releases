// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recovery_tier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecoveryTierConfig {

/// The tier this configuration applies to
 RecoveryTier get tier;/// Minimum number of workouts required to unlock
///
/// **Values**:
/// - Basic: 6 workouts
/// - Intermediate: 12 workouts
/// - Advanced: 20 workouts
 int get minWorkouts;/// Minimum days of data required to unlock
///
/// **Values**:
/// - Basic: 14 days
/// - Intermediate: 28 days
/// - Advanced: 42 days
 int get minDays;
/// Create a copy of RecoveryTierConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryTierConfigCopyWith<RecoveryTierConfig> get copyWith => _$RecoveryTierConfigCopyWithImpl<RecoveryTierConfig>(this as RecoveryTierConfig, _$identity);

  /// Serializes this RecoveryTierConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveryTierConfig&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.minWorkouts, minWorkouts) || other.minWorkouts == minWorkouts)&&(identical(other.minDays, minDays) || other.minDays == minDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,minWorkouts,minDays);

@override
String toString() {
  return 'RecoveryTierConfig(tier: $tier, minWorkouts: $minWorkouts, minDays: $minDays)';
}


}

/// @nodoc
abstract mixin class $RecoveryTierConfigCopyWith<$Res>  {
  factory $RecoveryTierConfigCopyWith(RecoveryTierConfig value, $Res Function(RecoveryTierConfig) _then) = _$RecoveryTierConfigCopyWithImpl;
@useResult
$Res call({
 RecoveryTier tier, int minWorkouts, int minDays
});




}
/// @nodoc
class _$RecoveryTierConfigCopyWithImpl<$Res>
    implements $RecoveryTierConfigCopyWith<$Res> {
  _$RecoveryTierConfigCopyWithImpl(this._self, this._then);

  final RecoveryTierConfig _self;
  final $Res Function(RecoveryTierConfig) _then;

/// Create a copy of RecoveryTierConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? minWorkouts = null,Object? minDays = null,}) {
  return _then(_self.copyWith(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as RecoveryTier,minWorkouts: null == minWorkouts ? _self.minWorkouts : minWorkouts // ignore: cast_nullable_to_non_nullable
as int,minDays: null == minDays ? _self.minDays : minDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecoveryTierConfig].
extension RecoveryTierConfigPatterns on RecoveryTierConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveryTierConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveryTierConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveryTierConfig value)  $default,){
final _that = this;
switch (_that) {
case _RecoveryTierConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveryTierConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveryTierConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecoveryTier tier,  int minWorkouts,  int minDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveryTierConfig() when $default != null:
return $default(_that.tier,_that.minWorkouts,_that.minDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecoveryTier tier,  int minWorkouts,  int minDays)  $default,) {final _that = this;
switch (_that) {
case _RecoveryTierConfig():
return $default(_that.tier,_that.minWorkouts,_that.minDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecoveryTier tier,  int minWorkouts,  int minDays)?  $default,) {final _that = this;
switch (_that) {
case _RecoveryTierConfig() when $default != null:
return $default(_that.tier,_that.minWorkouts,_that.minDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecoveryTierConfig implements RecoveryTierConfig {
  const _RecoveryTierConfig({required this.tier, required this.minWorkouts, required this.minDays});
  factory _RecoveryTierConfig.fromJson(Map<String, dynamic> json) => _$RecoveryTierConfigFromJson(json);

/// The tier this configuration applies to
@override final  RecoveryTier tier;
/// Minimum number of workouts required to unlock
///
/// **Values**:
/// - Basic: 6 workouts
/// - Intermediate: 12 workouts
/// - Advanced: 20 workouts
@override final  int minWorkouts;
/// Minimum days of data required to unlock
///
/// **Values**:
/// - Basic: 14 days
/// - Intermediate: 28 days
/// - Advanced: 42 days
@override final  int minDays;

/// Create a copy of RecoveryTierConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryTierConfigCopyWith<_RecoveryTierConfig> get copyWith => __$RecoveryTierConfigCopyWithImpl<_RecoveryTierConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecoveryTierConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveryTierConfig&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.minWorkouts, minWorkouts) || other.minWorkouts == minWorkouts)&&(identical(other.minDays, minDays) || other.minDays == minDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,minWorkouts,minDays);

@override
String toString() {
  return 'RecoveryTierConfig(tier: $tier, minWorkouts: $minWorkouts, minDays: $minDays)';
}


}

/// @nodoc
abstract mixin class _$RecoveryTierConfigCopyWith<$Res> implements $RecoveryTierConfigCopyWith<$Res> {
  factory _$RecoveryTierConfigCopyWith(_RecoveryTierConfig value, $Res Function(_RecoveryTierConfig) _then) = __$RecoveryTierConfigCopyWithImpl;
@override @useResult
$Res call({
 RecoveryTier tier, int minWorkouts, int minDays
});




}
/// @nodoc
class __$RecoveryTierConfigCopyWithImpl<$Res>
    implements _$RecoveryTierConfigCopyWith<$Res> {
  __$RecoveryTierConfigCopyWithImpl(this._self, this._then);

  final _RecoveryTierConfig _self;
  final $Res Function(_RecoveryTierConfig) _then;

/// Create a copy of RecoveryTierConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? minWorkouts = null,Object? minDays = null,}) {
  return _then(_RecoveryTierConfig(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as RecoveryTier,minWorkouts: null == minWorkouts ? _self.minWorkouts : minWorkouts // ignore: cast_nullable_to_non_nullable
as int,minDays: null == minDays ? _self.minDays : minDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RecoveryTierStatus {

/// The tier this status applies to
 RecoveryTier get tier;/// Whether the tier is currently unlocked
 bool get isUnlocked;/// Current number of workouts user has logged
 int get currentWorkouts;/// Current number of days since user started tracking
 int get currentDays;/// Configuration defining unlock requirements
 RecoveryTierConfig get config;/// Optional: Timestamp when tier was unlocked
 DateTime? get unlockedAt;
/// Create a copy of RecoveryTierStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryTierStatusCopyWith<RecoveryTierStatus> get copyWith => _$RecoveryTierStatusCopyWithImpl<RecoveryTierStatus>(this as RecoveryTierStatus, _$identity);

  /// Serializes this RecoveryTierStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveryTierStatus&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.currentWorkouts, currentWorkouts) || other.currentWorkouts == currentWorkouts)&&(identical(other.currentDays, currentDays) || other.currentDays == currentDays)&&(identical(other.config, config) || other.config == config)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,isUnlocked,currentWorkouts,currentDays,config,unlockedAt);

@override
String toString() {
  return 'RecoveryTierStatus(tier: $tier, isUnlocked: $isUnlocked, currentWorkouts: $currentWorkouts, currentDays: $currentDays, config: $config, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class $RecoveryTierStatusCopyWith<$Res>  {
  factory $RecoveryTierStatusCopyWith(RecoveryTierStatus value, $Res Function(RecoveryTierStatus) _then) = _$RecoveryTierStatusCopyWithImpl;
@useResult
$Res call({
 RecoveryTier tier, bool isUnlocked, int currentWorkouts, int currentDays, RecoveryTierConfig config, DateTime? unlockedAt
});


$RecoveryTierConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$RecoveryTierStatusCopyWithImpl<$Res>
    implements $RecoveryTierStatusCopyWith<$Res> {
  _$RecoveryTierStatusCopyWithImpl(this._self, this._then);

  final RecoveryTierStatus _self;
  final $Res Function(RecoveryTierStatus) _then;

/// Create a copy of RecoveryTierStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tier = null,Object? isUnlocked = null,Object? currentWorkouts = null,Object? currentDays = null,Object? config = null,Object? unlockedAt = freezed,}) {
  return _then(_self.copyWith(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as RecoveryTier,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,currentWorkouts: null == currentWorkouts ? _self.currentWorkouts : currentWorkouts // ignore: cast_nullable_to_non_nullable
as int,currentDays: null == currentDays ? _self.currentDays : currentDays // ignore: cast_nullable_to_non_nullable
as int,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as RecoveryTierConfig,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RecoveryTierStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecoveryTierConfigCopyWith<$Res> get config {
  
  return $RecoveryTierConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecoveryTierStatus].
extension RecoveryTierStatusPatterns on RecoveryTierStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveryTierStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveryTierStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveryTierStatus value)  $default,){
final _that = this;
switch (_that) {
case _RecoveryTierStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveryTierStatus value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveryTierStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecoveryTier tier,  bool isUnlocked,  int currentWorkouts,  int currentDays,  RecoveryTierConfig config,  DateTime? unlockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveryTierStatus() when $default != null:
return $default(_that.tier,_that.isUnlocked,_that.currentWorkouts,_that.currentDays,_that.config,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecoveryTier tier,  bool isUnlocked,  int currentWorkouts,  int currentDays,  RecoveryTierConfig config,  DateTime? unlockedAt)  $default,) {final _that = this;
switch (_that) {
case _RecoveryTierStatus():
return $default(_that.tier,_that.isUnlocked,_that.currentWorkouts,_that.currentDays,_that.config,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecoveryTier tier,  bool isUnlocked,  int currentWorkouts,  int currentDays,  RecoveryTierConfig config,  DateTime? unlockedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecoveryTierStatus() when $default != null:
return $default(_that.tier,_that.isUnlocked,_that.currentWorkouts,_that.currentDays,_that.config,_that.unlockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecoveryTierStatus extends RecoveryTierStatus {
  const _RecoveryTierStatus({required this.tier, required this.isUnlocked, required this.currentWorkouts, required this.currentDays, required this.config, this.unlockedAt}): super._();
  factory _RecoveryTierStatus.fromJson(Map<String, dynamic> json) => _$RecoveryTierStatusFromJson(json);

/// The tier this status applies to
@override final  RecoveryTier tier;
/// Whether the tier is currently unlocked
@override final  bool isUnlocked;
/// Current number of workouts user has logged
@override final  int currentWorkouts;
/// Current number of days since user started tracking
@override final  int currentDays;
/// Configuration defining unlock requirements
@override final  RecoveryTierConfig config;
/// Optional: Timestamp when tier was unlocked
@override final  DateTime? unlockedAt;

/// Create a copy of RecoveryTierStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryTierStatusCopyWith<_RecoveryTierStatus> get copyWith => __$RecoveryTierStatusCopyWithImpl<_RecoveryTierStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecoveryTierStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveryTierStatus&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.currentWorkouts, currentWorkouts) || other.currentWorkouts == currentWorkouts)&&(identical(other.currentDays, currentDays) || other.currentDays == currentDays)&&(identical(other.config, config) || other.config == config)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tier,isUnlocked,currentWorkouts,currentDays,config,unlockedAt);

@override
String toString() {
  return 'RecoveryTierStatus(tier: $tier, isUnlocked: $isUnlocked, currentWorkouts: $currentWorkouts, currentDays: $currentDays, config: $config, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class _$RecoveryTierStatusCopyWith<$Res> implements $RecoveryTierStatusCopyWith<$Res> {
  factory _$RecoveryTierStatusCopyWith(_RecoveryTierStatus value, $Res Function(_RecoveryTierStatus) _then) = __$RecoveryTierStatusCopyWithImpl;
@override @useResult
$Res call({
 RecoveryTier tier, bool isUnlocked, int currentWorkouts, int currentDays, RecoveryTierConfig config, DateTime? unlockedAt
});


@override $RecoveryTierConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$RecoveryTierStatusCopyWithImpl<$Res>
    implements _$RecoveryTierStatusCopyWith<$Res> {
  __$RecoveryTierStatusCopyWithImpl(this._self, this._then);

  final _RecoveryTierStatus _self;
  final $Res Function(_RecoveryTierStatus) _then;

/// Create a copy of RecoveryTierStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? isUnlocked = null,Object? currentWorkouts = null,Object? currentDays = null,Object? config = null,Object? unlockedAt = freezed,}) {
  return _then(_RecoveryTierStatus(
tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as RecoveryTier,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,currentWorkouts: null == currentWorkouts ? _self.currentWorkouts : currentWorkouts // ignore: cast_nullable_to_non_nullable
as int,currentDays: null == currentDays ? _self.currentDays : currentDays // ignore: cast_nullable_to_non_nullable
as int,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as RecoveryTierConfig,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RecoveryTierStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecoveryTierConfigCopyWith<$Res> get config {
  
  return $RecoveryTierConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

// dart format on
