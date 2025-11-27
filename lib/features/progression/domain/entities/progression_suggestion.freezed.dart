// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progression_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProgressionSuggestion {

 String get exerciseName; double get currentWeight; double get suggestedWeight; int get targetReps; String get reason; ProgressionConfidence get confidence; String? get additionalNotes;
/// Create a copy of ProgressionSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressionSuggestionCopyWith<ProgressionSuggestion> get copyWith => _$ProgressionSuggestionCopyWithImpl<ProgressionSuggestion>(this as ProgressionSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressionSuggestion&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.additionalNotes, additionalNotes) || other.additionalNotes == additionalNotes));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,currentWeight,suggestedWeight,targetReps,reason,confidence,additionalNotes);

@override
String toString() {
  return 'ProgressionSuggestion(exerciseName: $exerciseName, currentWeight: $currentWeight, suggestedWeight: $suggestedWeight, targetReps: $targetReps, reason: $reason, confidence: $confidence, additionalNotes: $additionalNotes)';
}


}

/// @nodoc
abstract mixin class $ProgressionSuggestionCopyWith<$Res>  {
  factory $ProgressionSuggestionCopyWith(ProgressionSuggestion value, $Res Function(ProgressionSuggestion) _then) = _$ProgressionSuggestionCopyWithImpl;
@useResult
$Res call({
 String exerciseName, double currentWeight, double suggestedWeight, int targetReps, String reason, ProgressionConfidence confidence, String? additionalNotes
});




}
/// @nodoc
class _$ProgressionSuggestionCopyWithImpl<$Res>
    implements $ProgressionSuggestionCopyWith<$Res> {
  _$ProgressionSuggestionCopyWithImpl(this._self, this._then);

  final ProgressionSuggestion _self;
  final $Res Function(ProgressionSuggestion) _then;

/// Create a copy of ProgressionSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? currentWeight = null,Object? suggestedWeight = null,Object? targetReps = null,Object? reason = null,Object? confidence = null,Object? additionalNotes = freezed,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,suggestedWeight: null == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as ProgressionConfidence,additionalNotes: freezed == additionalNotes ? _self.additionalNotes : additionalNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressionSuggestion].
extension ProgressionSuggestionPatterns on ProgressionSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressionSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressionSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressionSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _ProgressionSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressionSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressionSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  double currentWeight,  double suggestedWeight,  int targetReps,  String reason,  ProgressionConfidence confidence,  String? additionalNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressionSuggestion() when $default != null:
return $default(_that.exerciseName,_that.currentWeight,_that.suggestedWeight,_that.targetReps,_that.reason,_that.confidence,_that.additionalNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  double currentWeight,  double suggestedWeight,  int targetReps,  String reason,  ProgressionConfidence confidence,  String? additionalNotes)  $default,) {final _that = this;
switch (_that) {
case _ProgressionSuggestion():
return $default(_that.exerciseName,_that.currentWeight,_that.suggestedWeight,_that.targetReps,_that.reason,_that.confidence,_that.additionalNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  double currentWeight,  double suggestedWeight,  int targetReps,  String reason,  ProgressionConfidence confidence,  String? additionalNotes)?  $default,) {final _that = this;
switch (_that) {
case _ProgressionSuggestion() when $default != null:
return $default(_that.exerciseName,_that.currentWeight,_that.suggestedWeight,_that.targetReps,_that.reason,_that.confidence,_that.additionalNotes);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressionSuggestion implements ProgressionSuggestion {
  const _ProgressionSuggestion({required this.exerciseName, required this.currentWeight, required this.suggestedWeight, required this.targetReps, required this.reason, required this.confidence, this.additionalNotes});
  

@override final  String exerciseName;
@override final  double currentWeight;
@override final  double suggestedWeight;
@override final  int targetReps;
@override final  String reason;
@override final  ProgressionConfidence confidence;
@override final  String? additionalNotes;

/// Create a copy of ProgressionSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressionSuggestionCopyWith<_ProgressionSuggestion> get copyWith => __$ProgressionSuggestionCopyWithImpl<_ProgressionSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressionSuggestion&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.additionalNotes, additionalNotes) || other.additionalNotes == additionalNotes));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,currentWeight,suggestedWeight,targetReps,reason,confidence,additionalNotes);

@override
String toString() {
  return 'ProgressionSuggestion(exerciseName: $exerciseName, currentWeight: $currentWeight, suggestedWeight: $suggestedWeight, targetReps: $targetReps, reason: $reason, confidence: $confidence, additionalNotes: $additionalNotes)';
}


}

/// @nodoc
abstract mixin class _$ProgressionSuggestionCopyWith<$Res> implements $ProgressionSuggestionCopyWith<$Res> {
  factory _$ProgressionSuggestionCopyWith(_ProgressionSuggestion value, $Res Function(_ProgressionSuggestion) _then) = __$ProgressionSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, double currentWeight, double suggestedWeight, int targetReps, String reason, ProgressionConfidence confidence, String? additionalNotes
});




}
/// @nodoc
class __$ProgressionSuggestionCopyWithImpl<$Res>
    implements _$ProgressionSuggestionCopyWith<$Res> {
  __$ProgressionSuggestionCopyWithImpl(this._self, this._then);

  final _ProgressionSuggestion _self;
  final $Res Function(_ProgressionSuggestion) _then;

/// Create a copy of ProgressionSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? currentWeight = null,Object? suggestedWeight = null,Object? targetReps = null,Object? reason = null,Object? confidence = null,Object? additionalNotes = freezed,}) {
  return _then(_ProgressionSuggestion(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,suggestedWeight: null == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double,targetReps: null == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as ProgressionConfidence,additionalNotes: freezed == additionalNotes ? _self.additionalNotes : additionalNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
