// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSummary {

 String get id; String get name; DateTime get completedAt; int? get durationMinutes; int? get exerciseCount;
/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSummaryCopyWith<WorkoutSummary> get copyWith => _$WorkoutSummaryCopyWithImpl<WorkoutSummary>(this as WorkoutSummary, _$identity);

  /// Serializes this WorkoutSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,completedAt,durationMinutes,exerciseCount);

@override
String toString() {
  return 'WorkoutSummary(id: $id, name: $name, completedAt: $completedAt, durationMinutes: $durationMinutes, exerciseCount: $exerciseCount)';
}


}

/// @nodoc
abstract mixin class $WorkoutSummaryCopyWith<$Res>  {
  factory $WorkoutSummaryCopyWith(WorkoutSummary value, $Res Function(WorkoutSummary) _then) = _$WorkoutSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime completedAt, int? durationMinutes, int? exerciseCount
});




}
/// @nodoc
class _$WorkoutSummaryCopyWithImpl<$Res>
    implements $WorkoutSummaryCopyWith<$Res> {
  _$WorkoutSummaryCopyWithImpl(this._self, this._then);

  final WorkoutSummary _self;
  final $Res Function(WorkoutSummary) _then;

/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? completedAt = null,Object? durationMinutes = freezed,Object? exerciseCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,exerciseCount: freezed == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSummary].
extension WorkoutSummaryPatterns on WorkoutSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSummary value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime completedAt,  int? durationMinutes,  int? exerciseCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
return $default(_that.id,_that.name,_that.completedAt,_that.durationMinutes,_that.exerciseCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime completedAt,  int? durationMinutes,  int? exerciseCount)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSummary():
return $default(_that.id,_that.name,_that.completedAt,_that.durationMinutes,_that.exerciseCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime completedAt,  int? durationMinutes,  int? exerciseCount)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSummary() when $default != null:
return $default(_that.id,_that.name,_that.completedAt,_that.durationMinutes,_that.exerciseCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSummary implements WorkoutSummary {
  const _WorkoutSummary({required this.id, required this.name, required this.completedAt, this.durationMinutes, this.exerciseCount});
  factory _WorkoutSummary.fromJson(Map<String, dynamic> json) => _$WorkoutSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime completedAt;
@override final  int? durationMinutes;
@override final  int? exerciseCount;

/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSummaryCopyWith<_WorkoutSummary> get copyWith => __$WorkoutSummaryCopyWithImpl<_WorkoutSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.exerciseCount, exerciseCount) || other.exerciseCount == exerciseCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,completedAt,durationMinutes,exerciseCount);

@override
String toString() {
  return 'WorkoutSummary(id: $id, name: $name, completedAt: $completedAt, durationMinutes: $durationMinutes, exerciseCount: $exerciseCount)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSummaryCopyWith<$Res> implements $WorkoutSummaryCopyWith<$Res> {
  factory _$WorkoutSummaryCopyWith(_WorkoutSummary value, $Res Function(_WorkoutSummary) _then) = __$WorkoutSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime completedAt, int? durationMinutes, int? exerciseCount
});




}
/// @nodoc
class __$WorkoutSummaryCopyWithImpl<$Res>
    implements _$WorkoutSummaryCopyWith<$Res> {
  __$WorkoutSummaryCopyWithImpl(this._self, this._then);

  final _WorkoutSummary _self;
  final $Res Function(_WorkoutSummary) _then;

/// Create a copy of WorkoutSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? completedAt = null,Object? durationMinutes = freezed,Object? exerciseCount = freezed,}) {
  return _then(_WorkoutSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,exerciseCount: freezed == exerciseCount ? _self.exerciseCount : exerciseCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AIContext {

 int get currentStreak; WorkoutSummary? get lastWorkout; Map<String, int> get top5OneRM; RecoveryStatus get recoveryStatus; String get userTier;
/// Create a copy of AIContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIContextCopyWith<AIContext> get copyWith => _$AIContextCopyWithImpl<AIContext>(this as AIContext, _$identity);

  /// Serializes this AIContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIContext&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.lastWorkout, lastWorkout) || other.lastWorkout == lastWorkout)&&const DeepCollectionEquality().equals(other.top5OneRM, top5OneRM)&&(identical(other.recoveryStatus, recoveryStatus) || other.recoveryStatus == recoveryStatus)&&(identical(other.userTier, userTier) || other.userTier == userTier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,lastWorkout,const DeepCollectionEquality().hash(top5OneRM),recoveryStatus,userTier);

@override
String toString() {
  return 'AIContext(currentStreak: $currentStreak, lastWorkout: $lastWorkout, top5OneRM: $top5OneRM, recoveryStatus: $recoveryStatus, userTier: $userTier)';
}


}

/// @nodoc
abstract mixin class $AIContextCopyWith<$Res>  {
  factory $AIContextCopyWith(AIContext value, $Res Function(AIContext) _then) = _$AIContextCopyWithImpl;
@useResult
$Res call({
 int currentStreak, WorkoutSummary? lastWorkout, Map<String, int> top5OneRM, RecoveryStatus recoveryStatus, String userTier
});


$WorkoutSummaryCopyWith<$Res>? get lastWorkout;

}
/// @nodoc
class _$AIContextCopyWithImpl<$Res>
    implements $AIContextCopyWith<$Res> {
  _$AIContextCopyWithImpl(this._self, this._then);

  final AIContext _self;
  final $Res Function(AIContext) _then;

/// Create a copy of AIContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? lastWorkout = freezed,Object? top5OneRM = null,Object? recoveryStatus = null,Object? userTier = null,}) {
  return _then(_self.copyWith(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,lastWorkout: freezed == lastWorkout ? _self.lastWorkout : lastWorkout // ignore: cast_nullable_to_non_nullable
as WorkoutSummary?,top5OneRM: null == top5OneRM ? _self.top5OneRM : top5OneRM // ignore: cast_nullable_to_non_nullable
as Map<String, int>,recoveryStatus: null == recoveryStatus ? _self.recoveryStatus : recoveryStatus // ignore: cast_nullable_to_non_nullable
as RecoveryStatus,userTier: null == userTier ? _self.userTier : userTier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AIContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSummaryCopyWith<$Res>? get lastWorkout {
    if (_self.lastWorkout == null) {
    return null;
  }

  return $WorkoutSummaryCopyWith<$Res>(_self.lastWorkout!, (value) {
    return _then(_self.copyWith(lastWorkout: value));
  });
}
}


/// Adds pattern-matching-related methods to [AIContext].
extension AIContextPatterns on AIContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIContext value)  $default,){
final _that = this;
switch (_that) {
case _AIContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIContext value)?  $default,){
final _that = this;
switch (_that) {
case _AIContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  WorkoutSummary? lastWorkout,  Map<String, int> top5OneRM,  RecoveryStatus recoveryStatus,  String userTier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIContext() when $default != null:
return $default(_that.currentStreak,_that.lastWorkout,_that.top5OneRM,_that.recoveryStatus,_that.userTier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  WorkoutSummary? lastWorkout,  Map<String, int> top5OneRM,  RecoveryStatus recoveryStatus,  String userTier)  $default,) {final _that = this;
switch (_that) {
case _AIContext():
return $default(_that.currentStreak,_that.lastWorkout,_that.top5OneRM,_that.recoveryStatus,_that.userTier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  WorkoutSummary? lastWorkout,  Map<String, int> top5OneRM,  RecoveryStatus recoveryStatus,  String userTier)?  $default,) {final _that = this;
switch (_that) {
case _AIContext() when $default != null:
return $default(_that.currentStreak,_that.lastWorkout,_that.top5OneRM,_that.recoveryStatus,_that.userTier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIContext extends AIContext {
  const _AIContext({required this.currentStreak, this.lastWorkout, required final  Map<String, int> top5OneRM, required this.recoveryStatus, required this.userTier}): _top5OneRM = top5OneRM,super._();
  factory _AIContext.fromJson(Map<String, dynamic> json) => _$AIContextFromJson(json);

@override final  int currentStreak;
@override final  WorkoutSummary? lastWorkout;
 final  Map<String, int> _top5OneRM;
@override Map<String, int> get top5OneRM {
  if (_top5OneRM is EqualUnmodifiableMapView) return _top5OneRM;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_top5OneRM);
}

@override final  RecoveryStatus recoveryStatus;
@override final  String userTier;

/// Create a copy of AIContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIContextCopyWith<_AIContext> get copyWith => __$AIContextCopyWithImpl<_AIContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIContext&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.lastWorkout, lastWorkout) || other.lastWorkout == lastWorkout)&&const DeepCollectionEquality().equals(other._top5OneRM, _top5OneRM)&&(identical(other.recoveryStatus, recoveryStatus) || other.recoveryStatus == recoveryStatus)&&(identical(other.userTier, userTier) || other.userTier == userTier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,lastWorkout,const DeepCollectionEquality().hash(_top5OneRM),recoveryStatus,userTier);

@override
String toString() {
  return 'AIContext(currentStreak: $currentStreak, lastWorkout: $lastWorkout, top5OneRM: $top5OneRM, recoveryStatus: $recoveryStatus, userTier: $userTier)';
}


}

/// @nodoc
abstract mixin class _$AIContextCopyWith<$Res> implements $AIContextCopyWith<$Res> {
  factory _$AIContextCopyWith(_AIContext value, $Res Function(_AIContext) _then) = __$AIContextCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, WorkoutSummary? lastWorkout, Map<String, int> top5OneRM, RecoveryStatus recoveryStatus, String userTier
});


@override $WorkoutSummaryCopyWith<$Res>? get lastWorkout;

}
/// @nodoc
class __$AIContextCopyWithImpl<$Res>
    implements _$AIContextCopyWith<$Res> {
  __$AIContextCopyWithImpl(this._self, this._then);

  final _AIContext _self;
  final $Res Function(_AIContext) _then;

/// Create a copy of AIContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? lastWorkout = freezed,Object? top5OneRM = null,Object? recoveryStatus = null,Object? userTier = null,}) {
  return _then(_AIContext(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,lastWorkout: freezed == lastWorkout ? _self.lastWorkout : lastWorkout // ignore: cast_nullable_to_non_nullable
as WorkoutSummary?,top5OneRM: null == top5OneRM ? _self._top5OneRM : top5OneRM // ignore: cast_nullable_to_non_nullable
as Map<String, int>,recoveryStatus: null == recoveryStatus ? _self.recoveryStatus : recoveryStatus // ignore: cast_nullable_to_non_nullable
as RecoveryStatus,userTier: null == userTier ? _self.userTier : userTier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AIContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSummaryCopyWith<$Res>? get lastWorkout {
    if (_self.lastWorkout == null) {
    return null;
  }

  return $WorkoutSummaryCopyWith<$Res>(_self.lastWorkout!, (value) {
    return _then(_self.copyWith(lastWorkout: value));
  });
}
}

// dart format on
