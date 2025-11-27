// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrainingPattern {

/// Type of pattern detected
 PatternType get type;/// Severity level
 PatternSeverity get severity;/// Confidence score (0.0 to 1.0)
/// Based on correlation strength and data points
 double get confidence;/// Localization key for title
 String get titleKey;/// Localization key for description
 String get descriptionKey;/// Localization key for recommendation
 String get recommendationKey;/// Scientific explanation key (for expanded view)
 String? get scienceKey;/// Number of sessions analyzed for this pattern
 int get sessionsAnalyzed;/// Raw metrics that triggered this pattern
 Map<String, double> get triggerMetrics;
/// Create a copy of TrainingPattern
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingPatternCopyWith<TrainingPattern> get copyWith => _$TrainingPatternCopyWithImpl<TrainingPattern>(this as TrainingPattern, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingPattern&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&(identical(other.recommendationKey, recommendationKey) || other.recommendationKey == recommendationKey)&&(identical(other.scienceKey, scienceKey) || other.scienceKey == scienceKey)&&(identical(other.sessionsAnalyzed, sessionsAnalyzed) || other.sessionsAnalyzed == sessionsAnalyzed)&&const DeepCollectionEquality().equals(other.triggerMetrics, triggerMetrics));
}


@override
int get hashCode => Object.hash(runtimeType,type,severity,confidence,titleKey,descriptionKey,recommendationKey,scienceKey,sessionsAnalyzed,const DeepCollectionEquality().hash(triggerMetrics));

@override
String toString() {
  return 'TrainingPattern(type: $type, severity: $severity, confidence: $confidence, titleKey: $titleKey, descriptionKey: $descriptionKey, recommendationKey: $recommendationKey, scienceKey: $scienceKey, sessionsAnalyzed: $sessionsAnalyzed, triggerMetrics: $triggerMetrics)';
}


}

/// @nodoc
abstract mixin class $TrainingPatternCopyWith<$Res>  {
  factory $TrainingPatternCopyWith(TrainingPattern value, $Res Function(TrainingPattern) _then) = _$TrainingPatternCopyWithImpl;
@useResult
$Res call({
 PatternType type, PatternSeverity severity, double confidence, String titleKey, String descriptionKey, String recommendationKey, String? scienceKey, int sessionsAnalyzed, Map<String, double> triggerMetrics
});




}
/// @nodoc
class _$TrainingPatternCopyWithImpl<$Res>
    implements $TrainingPatternCopyWith<$Res> {
  _$TrainingPatternCopyWithImpl(this._self, this._then);

  final TrainingPattern _self;
  final $Res Function(TrainingPattern) _then;

/// Create a copy of TrainingPattern
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? severity = null,Object? confidence = null,Object? titleKey = null,Object? descriptionKey = null,Object? recommendationKey = null,Object? scienceKey = freezed,Object? sessionsAnalyzed = null,Object? triggerMetrics = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PatternType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as PatternSeverity,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,recommendationKey: null == recommendationKey ? _self.recommendationKey : recommendationKey // ignore: cast_nullable_to_non_nullable
as String,scienceKey: freezed == scienceKey ? _self.scienceKey : scienceKey // ignore: cast_nullable_to_non_nullable
as String?,sessionsAnalyzed: null == sessionsAnalyzed ? _self.sessionsAnalyzed : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
as int,triggerMetrics: null == triggerMetrics ? _self.triggerMetrics : triggerMetrics // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingPattern].
extension TrainingPatternPatterns on TrainingPattern {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingPattern value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingPattern() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingPattern value)  $default,){
final _that = this;
switch (_that) {
case _TrainingPattern():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingPattern value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingPattern() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PatternType type,  PatternSeverity severity,  double confidence,  String titleKey,  String descriptionKey,  String recommendationKey,  String? scienceKey,  int sessionsAnalyzed,  Map<String, double> triggerMetrics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingPattern() when $default != null:
return $default(_that.type,_that.severity,_that.confidence,_that.titleKey,_that.descriptionKey,_that.recommendationKey,_that.scienceKey,_that.sessionsAnalyzed,_that.triggerMetrics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PatternType type,  PatternSeverity severity,  double confidence,  String titleKey,  String descriptionKey,  String recommendationKey,  String? scienceKey,  int sessionsAnalyzed,  Map<String, double> triggerMetrics)  $default,) {final _that = this;
switch (_that) {
case _TrainingPattern():
return $default(_that.type,_that.severity,_that.confidence,_that.titleKey,_that.descriptionKey,_that.recommendationKey,_that.scienceKey,_that.sessionsAnalyzed,_that.triggerMetrics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PatternType type,  PatternSeverity severity,  double confidence,  String titleKey,  String descriptionKey,  String recommendationKey,  String? scienceKey,  int sessionsAnalyzed,  Map<String, double> triggerMetrics)?  $default,) {final _that = this;
switch (_that) {
case _TrainingPattern() when $default != null:
return $default(_that.type,_that.severity,_that.confidence,_that.titleKey,_that.descriptionKey,_that.recommendationKey,_that.scienceKey,_that.sessionsAnalyzed,_that.triggerMetrics);case _:
  return null;

}
}

}

/// @nodoc


class _TrainingPattern extends TrainingPattern {
  const _TrainingPattern({required this.type, required this.severity, required this.confidence, required this.titleKey, required this.descriptionKey, required this.recommendationKey, this.scienceKey, this.sessionsAnalyzed = 0, final  Map<String, double> triggerMetrics = const {}}): _triggerMetrics = triggerMetrics,super._();
  

/// Type of pattern detected
@override final  PatternType type;
/// Severity level
@override final  PatternSeverity severity;
/// Confidence score (0.0 to 1.0)
/// Based on correlation strength and data points
@override final  double confidence;
/// Localization key for title
@override final  String titleKey;
/// Localization key for description
@override final  String descriptionKey;
/// Localization key for recommendation
@override final  String recommendationKey;
/// Scientific explanation key (for expanded view)
@override final  String? scienceKey;
/// Number of sessions analyzed for this pattern
@override@JsonKey() final  int sessionsAnalyzed;
/// Raw metrics that triggered this pattern
 final  Map<String, double> _triggerMetrics;
/// Raw metrics that triggered this pattern
@override@JsonKey() Map<String, double> get triggerMetrics {
  if (_triggerMetrics is EqualUnmodifiableMapView) return _triggerMetrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_triggerMetrics);
}


/// Create a copy of TrainingPattern
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingPatternCopyWith<_TrainingPattern> get copyWith => __$TrainingPatternCopyWithImpl<_TrainingPattern>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingPattern&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&(identical(other.recommendationKey, recommendationKey) || other.recommendationKey == recommendationKey)&&(identical(other.scienceKey, scienceKey) || other.scienceKey == scienceKey)&&(identical(other.sessionsAnalyzed, sessionsAnalyzed) || other.sessionsAnalyzed == sessionsAnalyzed)&&const DeepCollectionEquality().equals(other._triggerMetrics, _triggerMetrics));
}


@override
int get hashCode => Object.hash(runtimeType,type,severity,confidence,titleKey,descriptionKey,recommendationKey,scienceKey,sessionsAnalyzed,const DeepCollectionEquality().hash(_triggerMetrics));

@override
String toString() {
  return 'TrainingPattern(type: $type, severity: $severity, confidence: $confidence, titleKey: $titleKey, descriptionKey: $descriptionKey, recommendationKey: $recommendationKey, scienceKey: $scienceKey, sessionsAnalyzed: $sessionsAnalyzed, triggerMetrics: $triggerMetrics)';
}


}

/// @nodoc
abstract mixin class _$TrainingPatternCopyWith<$Res> implements $TrainingPatternCopyWith<$Res> {
  factory _$TrainingPatternCopyWith(_TrainingPattern value, $Res Function(_TrainingPattern) _then) = __$TrainingPatternCopyWithImpl;
@override @useResult
$Res call({
 PatternType type, PatternSeverity severity, double confidence, String titleKey, String descriptionKey, String recommendationKey, String? scienceKey, int sessionsAnalyzed, Map<String, double> triggerMetrics
});




}
/// @nodoc
class __$TrainingPatternCopyWithImpl<$Res>
    implements _$TrainingPatternCopyWith<$Res> {
  __$TrainingPatternCopyWithImpl(this._self, this._then);

  final _TrainingPattern _self;
  final $Res Function(_TrainingPattern) _then;

/// Create a copy of TrainingPattern
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? severity = null,Object? confidence = null,Object? titleKey = null,Object? descriptionKey = null,Object? recommendationKey = null,Object? scienceKey = freezed,Object? sessionsAnalyzed = null,Object? triggerMetrics = null,}) {
  return _then(_TrainingPattern(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PatternType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as PatternSeverity,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,recommendationKey: null == recommendationKey ? _self.recommendationKey : recommendationKey // ignore: cast_nullable_to_non_nullable
as String,scienceKey: freezed == scienceKey ? _self.scienceKey : scienceKey // ignore: cast_nullable_to_non_nullable
as String?,sessionsAnalyzed: null == sessionsAnalyzed ? _self.sessionsAnalyzed : sessionsAnalyzed // ignore: cast_nullable_to_non_nullable
as int,triggerMetrics: null == triggerMetrics ? _self._triggerMetrics : triggerMetrics // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

/// @nodoc
mixin _$TrainingPatternResults {

/// All detected patterns, sorted by priority
 List<TrainingPattern> get patterns;/// The most significant pattern (highest priority)
 TrainingPattern? get primaryPattern;/// Overall training status summary
 TrainingStatus get overallStatus;/// Timestamp when patterns were analyzed
 DateTime get analyzedAt;/// Number of data points used
 int get dataPointsUsed;
/// Create a copy of TrainingPatternResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingPatternResultsCopyWith<TrainingPatternResults> get copyWith => _$TrainingPatternResultsCopyWithImpl<TrainingPatternResults>(this as TrainingPatternResults, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingPatternResults&&const DeepCollectionEquality().equals(other.patterns, patterns)&&(identical(other.primaryPattern, primaryPattern) || other.primaryPattern == primaryPattern)&&(identical(other.overallStatus, overallStatus) || other.overallStatus == overallStatus)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.dataPointsUsed, dataPointsUsed) || other.dataPointsUsed == dataPointsUsed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(patterns),primaryPattern,overallStatus,analyzedAt,dataPointsUsed);

@override
String toString() {
  return 'TrainingPatternResults(patterns: $patterns, primaryPattern: $primaryPattern, overallStatus: $overallStatus, analyzedAt: $analyzedAt, dataPointsUsed: $dataPointsUsed)';
}


}

/// @nodoc
abstract mixin class $TrainingPatternResultsCopyWith<$Res>  {
  factory $TrainingPatternResultsCopyWith(TrainingPatternResults value, $Res Function(TrainingPatternResults) _then) = _$TrainingPatternResultsCopyWithImpl;
@useResult
$Res call({
 List<TrainingPattern> patterns, TrainingPattern? primaryPattern, TrainingStatus overallStatus, DateTime analyzedAt, int dataPointsUsed
});


$TrainingPatternCopyWith<$Res>? get primaryPattern;

}
/// @nodoc
class _$TrainingPatternResultsCopyWithImpl<$Res>
    implements $TrainingPatternResultsCopyWith<$Res> {
  _$TrainingPatternResultsCopyWithImpl(this._self, this._then);

  final TrainingPatternResults _self;
  final $Res Function(TrainingPatternResults) _then;

/// Create a copy of TrainingPatternResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patterns = null,Object? primaryPattern = freezed,Object? overallStatus = null,Object? analyzedAt = null,Object? dataPointsUsed = null,}) {
  return _then(_self.copyWith(
patterns: null == patterns ? _self.patterns : patterns // ignore: cast_nullable_to_non_nullable
as List<TrainingPattern>,primaryPattern: freezed == primaryPattern ? _self.primaryPattern : primaryPattern // ignore: cast_nullable_to_non_nullable
as TrainingPattern?,overallStatus: null == overallStatus ? _self.overallStatus : overallStatus // ignore: cast_nullable_to_non_nullable
as TrainingStatus,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,dataPointsUsed: null == dataPointsUsed ? _self.dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TrainingPatternResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainingPatternCopyWith<$Res>? get primaryPattern {
    if (_self.primaryPattern == null) {
    return null;
  }

  return $TrainingPatternCopyWith<$Res>(_self.primaryPattern!, (value) {
    return _then(_self.copyWith(primaryPattern: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrainingPatternResults].
extension TrainingPatternResultsPatterns on TrainingPatternResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingPatternResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingPatternResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingPatternResults value)  $default,){
final _that = this;
switch (_that) {
case _TrainingPatternResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingPatternResults value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingPatternResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TrainingPattern> patterns,  TrainingPattern? primaryPattern,  TrainingStatus overallStatus,  DateTime analyzedAt,  int dataPointsUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingPatternResults() when $default != null:
return $default(_that.patterns,_that.primaryPattern,_that.overallStatus,_that.analyzedAt,_that.dataPointsUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TrainingPattern> patterns,  TrainingPattern? primaryPattern,  TrainingStatus overallStatus,  DateTime analyzedAt,  int dataPointsUsed)  $default,) {final _that = this;
switch (_that) {
case _TrainingPatternResults():
return $default(_that.patterns,_that.primaryPattern,_that.overallStatus,_that.analyzedAt,_that.dataPointsUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TrainingPattern> patterns,  TrainingPattern? primaryPattern,  TrainingStatus overallStatus,  DateTime analyzedAt,  int dataPointsUsed)?  $default,) {final _that = this;
switch (_that) {
case _TrainingPatternResults() when $default != null:
return $default(_that.patterns,_that.primaryPattern,_that.overallStatus,_that.analyzedAt,_that.dataPointsUsed);case _:
  return null;

}
}

}

/// @nodoc


class _TrainingPatternResults extends TrainingPatternResults {
  const _TrainingPatternResults({required final  List<TrainingPattern> patterns, this.primaryPattern, required this.overallStatus, required this.analyzedAt, this.dataPointsUsed = 0}): _patterns = patterns,super._();
  

/// All detected patterns, sorted by priority
 final  List<TrainingPattern> _patterns;
/// All detected patterns, sorted by priority
@override List<TrainingPattern> get patterns {
  if (_patterns is EqualUnmodifiableListView) return _patterns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_patterns);
}

/// The most significant pattern (highest priority)
@override final  TrainingPattern? primaryPattern;
/// Overall training status summary
@override final  TrainingStatus overallStatus;
/// Timestamp when patterns were analyzed
@override final  DateTime analyzedAt;
/// Number of data points used
@override@JsonKey() final  int dataPointsUsed;

/// Create a copy of TrainingPatternResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingPatternResultsCopyWith<_TrainingPatternResults> get copyWith => __$TrainingPatternResultsCopyWithImpl<_TrainingPatternResults>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingPatternResults&&const DeepCollectionEquality().equals(other._patterns, _patterns)&&(identical(other.primaryPattern, primaryPattern) || other.primaryPattern == primaryPattern)&&(identical(other.overallStatus, overallStatus) || other.overallStatus == overallStatus)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.dataPointsUsed, dataPointsUsed) || other.dataPointsUsed == dataPointsUsed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_patterns),primaryPattern,overallStatus,analyzedAt,dataPointsUsed);

@override
String toString() {
  return 'TrainingPatternResults(patterns: $patterns, primaryPattern: $primaryPattern, overallStatus: $overallStatus, analyzedAt: $analyzedAt, dataPointsUsed: $dataPointsUsed)';
}


}

/// @nodoc
abstract mixin class _$TrainingPatternResultsCopyWith<$Res> implements $TrainingPatternResultsCopyWith<$Res> {
  factory _$TrainingPatternResultsCopyWith(_TrainingPatternResults value, $Res Function(_TrainingPatternResults) _then) = __$TrainingPatternResultsCopyWithImpl;
@override @useResult
$Res call({
 List<TrainingPattern> patterns, TrainingPattern? primaryPattern, TrainingStatus overallStatus, DateTime analyzedAt, int dataPointsUsed
});


@override $TrainingPatternCopyWith<$Res>? get primaryPattern;

}
/// @nodoc
class __$TrainingPatternResultsCopyWithImpl<$Res>
    implements _$TrainingPatternResultsCopyWith<$Res> {
  __$TrainingPatternResultsCopyWithImpl(this._self, this._then);

  final _TrainingPatternResults _self;
  final $Res Function(_TrainingPatternResults) _then;

/// Create a copy of TrainingPatternResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patterns = null,Object? primaryPattern = freezed,Object? overallStatus = null,Object? analyzedAt = null,Object? dataPointsUsed = null,}) {
  return _then(_TrainingPatternResults(
patterns: null == patterns ? _self._patterns : patterns // ignore: cast_nullable_to_non_nullable
as List<TrainingPattern>,primaryPattern: freezed == primaryPattern ? _self.primaryPattern : primaryPattern // ignore: cast_nullable_to_non_nullable
as TrainingPattern?,overallStatus: null == overallStatus ? _self.overallStatus : overallStatus // ignore: cast_nullable_to_non_nullable
as TrainingStatus,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,dataPointsUsed: null == dataPointsUsed ? _self.dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TrainingPatternResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrainingPatternCopyWith<$Res>? get primaryPattern {
    if (_self.primaryPattern == null) {
    return null;
  }

  return $TrainingPatternCopyWith<$Res>(_self.primaryPattern!, (value) {
    return _then(_self.copyWith(primaryPattern: value));
  });
}
}

// dart format on
