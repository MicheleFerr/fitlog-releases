// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserContext {

 String get userId; ExperienceLevel get experienceLevel; TrainingGoal get primaryGoal; int get weeklyAvailability;// Number of workout days per week
 List<String>? get injuryHistory; List<String>? get preferredExercises;
/// Create a copy of UserContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserContextCopyWith<UserContext> get copyWith => _$UserContextCopyWithImpl<UserContext>(this as UserContext, _$identity);

  /// Serializes this UserContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserContext&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.primaryGoal, primaryGoal) || other.primaryGoal == primaryGoal)&&(identical(other.weeklyAvailability, weeklyAvailability) || other.weeklyAvailability == weeklyAvailability)&&const DeepCollectionEquality().equals(other.injuryHistory, injuryHistory)&&const DeepCollectionEquality().equals(other.preferredExercises, preferredExercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,experienceLevel,primaryGoal,weeklyAvailability,const DeepCollectionEquality().hash(injuryHistory),const DeepCollectionEquality().hash(preferredExercises));

@override
String toString() {
  return 'UserContext(userId: $userId, experienceLevel: $experienceLevel, primaryGoal: $primaryGoal, weeklyAvailability: $weeklyAvailability, injuryHistory: $injuryHistory, preferredExercises: $preferredExercises)';
}


}

/// @nodoc
abstract mixin class $UserContextCopyWith<$Res>  {
  factory $UserContextCopyWith(UserContext value, $Res Function(UserContext) _then) = _$UserContextCopyWithImpl;
@useResult
$Res call({
 String userId, ExperienceLevel experienceLevel, TrainingGoal primaryGoal, int weeklyAvailability, List<String>? injuryHistory, List<String>? preferredExercises
});




}
/// @nodoc
class _$UserContextCopyWithImpl<$Res>
    implements $UserContextCopyWith<$Res> {
  _$UserContextCopyWithImpl(this._self, this._then);

  final UserContext _self;
  final $Res Function(UserContext) _then;

/// Create a copy of UserContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? experienceLevel = null,Object? primaryGoal = null,Object? weeklyAvailability = null,Object? injuryHistory = freezed,Object? preferredExercises = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,primaryGoal: null == primaryGoal ? _self.primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as TrainingGoal,weeklyAvailability: null == weeklyAvailability ? _self.weeklyAvailability : weeklyAvailability // ignore: cast_nullable_to_non_nullable
as int,injuryHistory: freezed == injuryHistory ? _self.injuryHistory : injuryHistory // ignore: cast_nullable_to_non_nullable
as List<String>?,preferredExercises: freezed == preferredExercises ? _self.preferredExercises : preferredExercises // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserContext].
extension UserContextPatterns on UserContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserContext value)  $default,){
final _that = this;
switch (_that) {
case _UserContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserContext value)?  $default,){
final _that = this;
switch (_that) {
case _UserContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  ExperienceLevel experienceLevel,  TrainingGoal primaryGoal,  int weeklyAvailability,  List<String>? injuryHistory,  List<String>? preferredExercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserContext() when $default != null:
return $default(_that.userId,_that.experienceLevel,_that.primaryGoal,_that.weeklyAvailability,_that.injuryHistory,_that.preferredExercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  ExperienceLevel experienceLevel,  TrainingGoal primaryGoal,  int weeklyAvailability,  List<String>? injuryHistory,  List<String>? preferredExercises)  $default,) {final _that = this;
switch (_that) {
case _UserContext():
return $default(_that.userId,_that.experienceLevel,_that.primaryGoal,_that.weeklyAvailability,_that.injuryHistory,_that.preferredExercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  ExperienceLevel experienceLevel,  TrainingGoal primaryGoal,  int weeklyAvailability,  List<String>? injuryHistory,  List<String>? preferredExercises)?  $default,) {final _that = this;
switch (_that) {
case _UserContext() when $default != null:
return $default(_that.userId,_that.experienceLevel,_that.primaryGoal,_that.weeklyAvailability,_that.injuryHistory,_that.preferredExercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserContext implements UserContext {
  const _UserContext({required this.userId, required this.experienceLevel, required this.primaryGoal, required this.weeklyAvailability, final  List<String>? injuryHistory, final  List<String>? preferredExercises}): _injuryHistory = injuryHistory,_preferredExercises = preferredExercises;
  factory _UserContext.fromJson(Map<String, dynamic> json) => _$UserContextFromJson(json);

@override final  String userId;
@override final  ExperienceLevel experienceLevel;
@override final  TrainingGoal primaryGoal;
@override final  int weeklyAvailability;
// Number of workout days per week
 final  List<String>? _injuryHistory;
// Number of workout days per week
@override List<String>? get injuryHistory {
  final value = _injuryHistory;
  if (value == null) return null;
  if (_injuryHistory is EqualUnmodifiableListView) return _injuryHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _preferredExercises;
@override List<String>? get preferredExercises {
  final value = _preferredExercises;
  if (value == null) return null;
  if (_preferredExercises is EqualUnmodifiableListView) return _preferredExercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UserContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserContextCopyWith<_UserContext> get copyWith => __$UserContextCopyWithImpl<_UserContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserContext&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.primaryGoal, primaryGoal) || other.primaryGoal == primaryGoal)&&(identical(other.weeklyAvailability, weeklyAvailability) || other.weeklyAvailability == weeklyAvailability)&&const DeepCollectionEquality().equals(other._injuryHistory, _injuryHistory)&&const DeepCollectionEquality().equals(other._preferredExercises, _preferredExercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,experienceLevel,primaryGoal,weeklyAvailability,const DeepCollectionEquality().hash(_injuryHistory),const DeepCollectionEquality().hash(_preferredExercises));

@override
String toString() {
  return 'UserContext(userId: $userId, experienceLevel: $experienceLevel, primaryGoal: $primaryGoal, weeklyAvailability: $weeklyAvailability, injuryHistory: $injuryHistory, preferredExercises: $preferredExercises)';
}


}

/// @nodoc
abstract mixin class _$UserContextCopyWith<$Res> implements $UserContextCopyWith<$Res> {
  factory _$UserContextCopyWith(_UserContext value, $Res Function(_UserContext) _then) = __$UserContextCopyWithImpl;
@override @useResult
$Res call({
 String userId, ExperienceLevel experienceLevel, TrainingGoal primaryGoal, int weeklyAvailability, List<String>? injuryHistory, List<String>? preferredExercises
});




}
/// @nodoc
class __$UserContextCopyWithImpl<$Res>
    implements _$UserContextCopyWith<$Res> {
  __$UserContextCopyWithImpl(this._self, this._then);

  final _UserContext _self;
  final $Res Function(_UserContext) _then;

/// Create a copy of UserContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? experienceLevel = null,Object? primaryGoal = null,Object? weeklyAvailability = null,Object? injuryHistory = freezed,Object? preferredExercises = freezed,}) {
  return _then(_UserContext(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,primaryGoal: null == primaryGoal ? _self.primaryGoal : primaryGoal // ignore: cast_nullable_to_non_nullable
as TrainingGoal,weeklyAvailability: null == weeklyAvailability ? _self.weeklyAvailability : weeklyAvailability // ignore: cast_nullable_to_non_nullable
as int,injuryHistory: freezed == injuryHistory ? _self._injuryHistory : injuryHistory // ignore: cast_nullable_to_non_nullable
as List<String>?,preferredExercises: freezed == preferredExercises ? _self._preferredExercises : preferredExercises // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
