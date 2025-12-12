// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stress_index_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StressIndexState {

/// Latest stress index result (from most recent workout)
 StressIndexResult? get latestResult;/// Current recovery status for all worked muscles
 Map<String, MuscleRecoveryStatus> get muscleRecovery;/// History of stress index results (last 7 days)
 List<StressIndexResult> get history;
/// Create a copy of StressIndexState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StressIndexStateCopyWith<StressIndexState> get copyWith => _$StressIndexStateCopyWithImpl<StressIndexState>(this as StressIndexState, _$identity);

  /// Serializes this StressIndexState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StressIndexState&&(identical(other.latestResult, latestResult) || other.latestResult == latestResult)&&const DeepCollectionEquality().equals(other.muscleRecovery, muscleRecovery)&&const DeepCollectionEquality().equals(other.history, history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestResult,const DeepCollectionEquality().hash(muscleRecovery),const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'StressIndexState(latestResult: $latestResult, muscleRecovery: $muscleRecovery, history: $history)';
}


}

/// @nodoc
abstract mixin class $StressIndexStateCopyWith<$Res>  {
  factory $StressIndexStateCopyWith(StressIndexState value, $Res Function(StressIndexState) _then) = _$StressIndexStateCopyWithImpl;
@useResult
$Res call({
 StressIndexResult? latestResult, Map<String, MuscleRecoveryStatus> muscleRecovery, List<StressIndexResult> history
});


$StressIndexResultCopyWith<$Res>? get latestResult;

}
/// @nodoc
class _$StressIndexStateCopyWithImpl<$Res>
    implements $StressIndexStateCopyWith<$Res> {
  _$StressIndexStateCopyWithImpl(this._self, this._then);

  final StressIndexState _self;
  final $Res Function(StressIndexState) _then;

/// Create a copy of StressIndexState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latestResult = freezed,Object? muscleRecovery = null,Object? history = null,}) {
  return _then(_self.copyWith(
latestResult: freezed == latestResult ? _self.latestResult : latestResult // ignore: cast_nullable_to_non_nullable
as StressIndexResult?,muscleRecovery: null == muscleRecovery ? _self.muscleRecovery : muscleRecovery // ignore: cast_nullable_to_non_nullable
as Map<String, MuscleRecoveryStatus>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<StressIndexResult>,
  ));
}
/// Create a copy of StressIndexState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StressIndexResultCopyWith<$Res>? get latestResult {
    if (_self.latestResult == null) {
    return null;
  }

  return $StressIndexResultCopyWith<$Res>(_self.latestResult!, (value) {
    return _then(_self.copyWith(latestResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [StressIndexState].
extension StressIndexStatePatterns on StressIndexState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StressIndexState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StressIndexState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StressIndexState value)  $default,){
final _that = this;
switch (_that) {
case _StressIndexState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StressIndexState value)?  $default,){
final _that = this;
switch (_that) {
case _StressIndexState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StressIndexResult? latestResult,  Map<String, MuscleRecoveryStatus> muscleRecovery,  List<StressIndexResult> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StressIndexState() when $default != null:
return $default(_that.latestResult,_that.muscleRecovery,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StressIndexResult? latestResult,  Map<String, MuscleRecoveryStatus> muscleRecovery,  List<StressIndexResult> history)  $default,) {final _that = this;
switch (_that) {
case _StressIndexState():
return $default(_that.latestResult,_that.muscleRecovery,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StressIndexResult? latestResult,  Map<String, MuscleRecoveryStatus> muscleRecovery,  List<StressIndexResult> history)?  $default,) {final _that = this;
switch (_that) {
case _StressIndexState() when $default != null:
return $default(_that.latestResult,_that.muscleRecovery,_that.history);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StressIndexState extends StressIndexState {
  const _StressIndexState({this.latestResult, required final  Map<String, MuscleRecoveryStatus> muscleRecovery, required final  List<StressIndexResult> history}): _muscleRecovery = muscleRecovery,_history = history,super._();
  factory _StressIndexState.fromJson(Map<String, dynamic> json) => _$StressIndexStateFromJson(json);

/// Latest stress index result (from most recent workout)
@override final  StressIndexResult? latestResult;
/// Current recovery status for all worked muscles
 final  Map<String, MuscleRecoveryStatus> _muscleRecovery;
/// Current recovery status for all worked muscles
@override Map<String, MuscleRecoveryStatus> get muscleRecovery {
  if (_muscleRecovery is EqualUnmodifiableMapView) return _muscleRecovery;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_muscleRecovery);
}

/// History of stress index results (last 7 days)
 final  List<StressIndexResult> _history;
/// History of stress index results (last 7 days)
@override List<StressIndexResult> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of StressIndexState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StressIndexStateCopyWith<_StressIndexState> get copyWith => __$StressIndexStateCopyWithImpl<_StressIndexState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StressIndexStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StressIndexState&&(identical(other.latestResult, latestResult) || other.latestResult == latestResult)&&const DeepCollectionEquality().equals(other._muscleRecovery, _muscleRecovery)&&const DeepCollectionEquality().equals(other._history, _history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestResult,const DeepCollectionEquality().hash(_muscleRecovery),const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'StressIndexState(latestResult: $latestResult, muscleRecovery: $muscleRecovery, history: $history)';
}


}

/// @nodoc
abstract mixin class _$StressIndexStateCopyWith<$Res> implements $StressIndexStateCopyWith<$Res> {
  factory _$StressIndexStateCopyWith(_StressIndexState value, $Res Function(_StressIndexState) _then) = __$StressIndexStateCopyWithImpl;
@override @useResult
$Res call({
 StressIndexResult? latestResult, Map<String, MuscleRecoveryStatus> muscleRecovery, List<StressIndexResult> history
});


@override $StressIndexResultCopyWith<$Res>? get latestResult;

}
/// @nodoc
class __$StressIndexStateCopyWithImpl<$Res>
    implements _$StressIndexStateCopyWith<$Res> {
  __$StressIndexStateCopyWithImpl(this._self, this._then);

  final _StressIndexState _self;
  final $Res Function(_StressIndexState) _then;

/// Create a copy of StressIndexState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latestResult = freezed,Object? muscleRecovery = null,Object? history = null,}) {
  return _then(_StressIndexState(
latestResult: freezed == latestResult ? _self.latestResult : latestResult // ignore: cast_nullable_to_non_nullable
as StressIndexResult?,muscleRecovery: null == muscleRecovery ? _self._muscleRecovery : muscleRecovery // ignore: cast_nullable_to_non_nullable
as Map<String, MuscleRecoveryStatus>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<StressIndexResult>,
  ));
}

/// Create a copy of StressIndexState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StressIndexResultCopyWith<$Res>? get latestResult {
    if (_self.latestResult == null) {
    return null;
  }

  return $StressIndexResultCopyWith<$Res>(_self.latestResult!, (value) {
    return _then(_self.copyWith(latestResult: value));
  });
}
}

// dart format on
