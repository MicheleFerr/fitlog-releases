// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'correlation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CorrelationResult {

/// Pearson correlation coefficient (-1 to +1)
/// - +1: Perfect positive correlation
/// - 0: No correlation
/// - -1: Perfect negative correlation
 double get r;/// Coefficient of determination (0 to 1)
/// - Shows how much variance in Y is explained by X
/// - 0.72 means 72% of variance explained
 double get rSquared;/// Strength classification
 CorrelationStrength get strength;/// Human-readable interpretation
 String get interpretation;/// Number of data points used
 int get dataPoints;/// Whether the result is statistically significant
 bool get isSignificant;
/// Create a copy of CorrelationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorrelationResultCopyWith<CorrelationResult> get copyWith => _$CorrelationResultCopyWithImpl<CorrelationResult>(this as CorrelationResult, _$identity);

  /// Serializes this CorrelationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorrelationResult&&(identical(other.r, r) || other.r == r)&&(identical(other.rSquared, rSquared) || other.rSquared == rSquared)&&(identical(other.strength, strength) || other.strength == strength)&&(identical(other.interpretation, interpretation) || other.interpretation == interpretation)&&(identical(other.dataPoints, dataPoints) || other.dataPoints == dataPoints)&&(identical(other.isSignificant, isSignificant) || other.isSignificant == isSignificant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,r,rSquared,strength,interpretation,dataPoints,isSignificant);

@override
String toString() {
  return 'CorrelationResult(r: $r, rSquared: $rSquared, strength: $strength, interpretation: $interpretation, dataPoints: $dataPoints, isSignificant: $isSignificant)';
}


}

/// @nodoc
abstract mixin class $CorrelationResultCopyWith<$Res>  {
  factory $CorrelationResultCopyWith(CorrelationResult value, $Res Function(CorrelationResult) _then) = _$CorrelationResultCopyWithImpl;
@useResult
$Res call({
 double r, double rSquared, CorrelationStrength strength, String interpretation, int dataPoints, bool isSignificant
});




}
/// @nodoc
class _$CorrelationResultCopyWithImpl<$Res>
    implements $CorrelationResultCopyWith<$Res> {
  _$CorrelationResultCopyWithImpl(this._self, this._then);

  final CorrelationResult _self;
  final $Res Function(CorrelationResult) _then;

/// Create a copy of CorrelationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? r = null,Object? rSquared = null,Object? strength = null,Object? interpretation = null,Object? dataPoints = null,Object? isSignificant = null,}) {
  return _then(_self.copyWith(
r: null == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as double,rSquared: null == rSquared ? _self.rSquared : rSquared // ignore: cast_nullable_to_non_nullable
as double,strength: null == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as CorrelationStrength,interpretation: null == interpretation ? _self.interpretation : interpretation // ignore: cast_nullable_to_non_nullable
as String,dataPoints: null == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as int,isSignificant: null == isSignificant ? _self.isSignificant : isSignificant // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CorrelationResult].
extension CorrelationResultPatterns on CorrelationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorrelationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorrelationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorrelationResult value)  $default,){
final _that = this;
switch (_that) {
case _CorrelationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorrelationResult value)?  $default,){
final _that = this;
switch (_that) {
case _CorrelationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double r,  double rSquared,  CorrelationStrength strength,  String interpretation,  int dataPoints,  bool isSignificant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorrelationResult() when $default != null:
return $default(_that.r,_that.rSquared,_that.strength,_that.interpretation,_that.dataPoints,_that.isSignificant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double r,  double rSquared,  CorrelationStrength strength,  String interpretation,  int dataPoints,  bool isSignificant)  $default,) {final _that = this;
switch (_that) {
case _CorrelationResult():
return $default(_that.r,_that.rSquared,_that.strength,_that.interpretation,_that.dataPoints,_that.isSignificant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double r,  double rSquared,  CorrelationStrength strength,  String interpretation,  int dataPoints,  bool isSignificant)?  $default,) {final _that = this;
switch (_that) {
case _CorrelationResult() when $default != null:
return $default(_that.r,_that.rSquared,_that.strength,_that.interpretation,_that.dataPoints,_that.isSignificant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CorrelationResult extends CorrelationResult {
  const _CorrelationResult({required this.r, required this.rSquared, required this.strength, required this.interpretation, this.dataPoints = 0, this.isSignificant = false}): super._();
  factory _CorrelationResult.fromJson(Map<String, dynamic> json) => _$CorrelationResultFromJson(json);

/// Pearson correlation coefficient (-1 to +1)
/// - +1: Perfect positive correlation
/// - 0: No correlation
/// - -1: Perfect negative correlation
@override final  double r;
/// Coefficient of determination (0 to 1)
/// - Shows how much variance in Y is explained by X
/// - 0.72 means 72% of variance explained
@override final  double rSquared;
/// Strength classification
@override final  CorrelationStrength strength;
/// Human-readable interpretation
@override final  String interpretation;
/// Number of data points used
@override@JsonKey() final  int dataPoints;
/// Whether the result is statistically significant
@override@JsonKey() final  bool isSignificant;

/// Create a copy of CorrelationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorrelationResultCopyWith<_CorrelationResult> get copyWith => __$CorrelationResultCopyWithImpl<_CorrelationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorrelationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorrelationResult&&(identical(other.r, r) || other.r == r)&&(identical(other.rSquared, rSquared) || other.rSquared == rSquared)&&(identical(other.strength, strength) || other.strength == strength)&&(identical(other.interpretation, interpretation) || other.interpretation == interpretation)&&(identical(other.dataPoints, dataPoints) || other.dataPoints == dataPoints)&&(identical(other.isSignificant, isSignificant) || other.isSignificant == isSignificant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,r,rSquared,strength,interpretation,dataPoints,isSignificant);

@override
String toString() {
  return 'CorrelationResult(r: $r, rSquared: $rSquared, strength: $strength, interpretation: $interpretation, dataPoints: $dataPoints, isSignificant: $isSignificant)';
}


}

/// @nodoc
abstract mixin class _$CorrelationResultCopyWith<$Res> implements $CorrelationResultCopyWith<$Res> {
  factory _$CorrelationResultCopyWith(_CorrelationResult value, $Res Function(_CorrelationResult) _then) = __$CorrelationResultCopyWithImpl;
@override @useResult
$Res call({
 double r, double rSquared, CorrelationStrength strength, String interpretation, int dataPoints, bool isSignificant
});




}
/// @nodoc
class __$CorrelationResultCopyWithImpl<$Res>
    implements _$CorrelationResultCopyWith<$Res> {
  __$CorrelationResultCopyWithImpl(this._self, this._then);

  final _CorrelationResult _self;
  final $Res Function(_CorrelationResult) _then;

/// Create a copy of CorrelationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? r = null,Object? rSquared = null,Object? strength = null,Object? interpretation = null,Object? dataPoints = null,Object? isSignificant = null,}) {
  return _then(_CorrelationResult(
r: null == r ? _self.r : r // ignore: cast_nullable_to_non_nullable
as double,rSquared: null == rSquared ? _self.rSquared : rSquared // ignore: cast_nullable_to_non_nullable
as double,strength: null == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as CorrelationStrength,interpretation: null == interpretation ? _self.interpretation : interpretation // ignore: cast_nullable_to_non_nullable
as String,dataPoints: null == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as int,isSignificant: null == isSignificant ? _self.isSignificant : isSignificant // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CorrelationResults {

/// Weight vs RPE correlation
 CorrelationResult get weightRpe;/// Volume vs RPE correlation
 CorrelationResult get volumeRpe;/// Weight vs Volume correlation (optional)
 CorrelationResult? get weightVolume;
/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorrelationResultsCopyWith<CorrelationResults> get copyWith => _$CorrelationResultsCopyWithImpl<CorrelationResults>(this as CorrelationResults, _$identity);

  /// Serializes this CorrelationResults to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorrelationResults&&(identical(other.weightRpe, weightRpe) || other.weightRpe == weightRpe)&&(identical(other.volumeRpe, volumeRpe) || other.volumeRpe == volumeRpe)&&(identical(other.weightVolume, weightVolume) || other.weightVolume == weightVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weightRpe,volumeRpe,weightVolume);

@override
String toString() {
  return 'CorrelationResults(weightRpe: $weightRpe, volumeRpe: $volumeRpe, weightVolume: $weightVolume)';
}


}

/// @nodoc
abstract mixin class $CorrelationResultsCopyWith<$Res>  {
  factory $CorrelationResultsCopyWith(CorrelationResults value, $Res Function(CorrelationResults) _then) = _$CorrelationResultsCopyWithImpl;
@useResult
$Res call({
 CorrelationResult weightRpe, CorrelationResult volumeRpe, CorrelationResult? weightVolume
});


$CorrelationResultCopyWith<$Res> get weightRpe;$CorrelationResultCopyWith<$Res> get volumeRpe;$CorrelationResultCopyWith<$Res>? get weightVolume;

}
/// @nodoc
class _$CorrelationResultsCopyWithImpl<$Res>
    implements $CorrelationResultsCopyWith<$Res> {
  _$CorrelationResultsCopyWithImpl(this._self, this._then);

  final CorrelationResults _self;
  final $Res Function(CorrelationResults) _then;

/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weightRpe = null,Object? volumeRpe = null,Object? weightVolume = freezed,}) {
  return _then(_self.copyWith(
weightRpe: null == weightRpe ? _self.weightRpe : weightRpe // ignore: cast_nullable_to_non_nullable
as CorrelationResult,volumeRpe: null == volumeRpe ? _self.volumeRpe : volumeRpe // ignore: cast_nullable_to_non_nullable
as CorrelationResult,weightVolume: freezed == weightVolume ? _self.weightVolume : weightVolume // ignore: cast_nullable_to_non_nullable
as CorrelationResult?,
  ));
}
/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultCopyWith<$Res> get weightRpe {
  
  return $CorrelationResultCopyWith<$Res>(_self.weightRpe, (value) {
    return _then(_self.copyWith(weightRpe: value));
  });
}/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultCopyWith<$Res> get volumeRpe {
  
  return $CorrelationResultCopyWith<$Res>(_self.volumeRpe, (value) {
    return _then(_self.copyWith(volumeRpe: value));
  });
}/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultCopyWith<$Res>? get weightVolume {
    if (_self.weightVolume == null) {
    return null;
  }

  return $CorrelationResultCopyWith<$Res>(_self.weightVolume!, (value) {
    return _then(_self.copyWith(weightVolume: value));
  });
}
}


/// Adds pattern-matching-related methods to [CorrelationResults].
extension CorrelationResultsPatterns on CorrelationResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorrelationResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorrelationResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorrelationResults value)  $default,){
final _that = this;
switch (_that) {
case _CorrelationResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorrelationResults value)?  $default,){
final _that = this;
switch (_that) {
case _CorrelationResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CorrelationResult weightRpe,  CorrelationResult volumeRpe,  CorrelationResult? weightVolume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorrelationResults() when $default != null:
return $default(_that.weightRpe,_that.volumeRpe,_that.weightVolume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CorrelationResult weightRpe,  CorrelationResult volumeRpe,  CorrelationResult? weightVolume)  $default,) {final _that = this;
switch (_that) {
case _CorrelationResults():
return $default(_that.weightRpe,_that.volumeRpe,_that.weightVolume);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CorrelationResult weightRpe,  CorrelationResult volumeRpe,  CorrelationResult? weightVolume)?  $default,) {final _that = this;
switch (_that) {
case _CorrelationResults() when $default != null:
return $default(_that.weightRpe,_that.volumeRpe,_that.weightVolume);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CorrelationResults extends CorrelationResults {
  const _CorrelationResults({required this.weightRpe, required this.volumeRpe, this.weightVolume}): super._();
  factory _CorrelationResults.fromJson(Map<String, dynamic> json) => _$CorrelationResultsFromJson(json);

/// Weight vs RPE correlation
@override final  CorrelationResult weightRpe;
/// Volume vs RPE correlation
@override final  CorrelationResult volumeRpe;
/// Weight vs Volume correlation (optional)
@override final  CorrelationResult? weightVolume;

/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorrelationResultsCopyWith<_CorrelationResults> get copyWith => __$CorrelationResultsCopyWithImpl<_CorrelationResults>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorrelationResultsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorrelationResults&&(identical(other.weightRpe, weightRpe) || other.weightRpe == weightRpe)&&(identical(other.volumeRpe, volumeRpe) || other.volumeRpe == volumeRpe)&&(identical(other.weightVolume, weightVolume) || other.weightVolume == weightVolume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weightRpe,volumeRpe,weightVolume);

@override
String toString() {
  return 'CorrelationResults(weightRpe: $weightRpe, volumeRpe: $volumeRpe, weightVolume: $weightVolume)';
}


}

/// @nodoc
abstract mixin class _$CorrelationResultsCopyWith<$Res> implements $CorrelationResultsCopyWith<$Res> {
  factory _$CorrelationResultsCopyWith(_CorrelationResults value, $Res Function(_CorrelationResults) _then) = __$CorrelationResultsCopyWithImpl;
@override @useResult
$Res call({
 CorrelationResult weightRpe, CorrelationResult volumeRpe, CorrelationResult? weightVolume
});


@override $CorrelationResultCopyWith<$Res> get weightRpe;@override $CorrelationResultCopyWith<$Res> get volumeRpe;@override $CorrelationResultCopyWith<$Res>? get weightVolume;

}
/// @nodoc
class __$CorrelationResultsCopyWithImpl<$Res>
    implements _$CorrelationResultsCopyWith<$Res> {
  __$CorrelationResultsCopyWithImpl(this._self, this._then);

  final _CorrelationResults _self;
  final $Res Function(_CorrelationResults) _then;

/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weightRpe = null,Object? volumeRpe = null,Object? weightVolume = freezed,}) {
  return _then(_CorrelationResults(
weightRpe: null == weightRpe ? _self.weightRpe : weightRpe // ignore: cast_nullable_to_non_nullable
as CorrelationResult,volumeRpe: null == volumeRpe ? _self.volumeRpe : volumeRpe // ignore: cast_nullable_to_non_nullable
as CorrelationResult,weightVolume: freezed == weightVolume ? _self.weightVolume : weightVolume // ignore: cast_nullable_to_non_nullable
as CorrelationResult?,
  ));
}

/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultCopyWith<$Res> get weightRpe {
  
  return $CorrelationResultCopyWith<$Res>(_self.weightRpe, (value) {
    return _then(_self.copyWith(weightRpe: value));
  });
}/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultCopyWith<$Res> get volumeRpe {
  
  return $CorrelationResultCopyWith<$Res>(_self.volumeRpe, (value) {
    return _then(_self.copyWith(volumeRpe: value));
  });
}/// Create a copy of CorrelationResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorrelationResultCopyWith<$Res>? get weightVolume {
    if (_self.weightVolume == null) {
    return null;
  }

  return $CorrelationResultCopyWith<$Res>(_self.weightVolume!, (value) {
    return _then(_self.copyWith(weightVolume: value));
  });
}
}

// dart format on
