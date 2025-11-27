// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIInsight {

 String get id; InsightType get type; InsightSeverity get severity; String get title; String get description; String get recommendation; int get priority; String? get affectedExercise; List<String>? get affectedTemplates; List<String>? get scientificStrategies; Map<String, dynamic>? get dataPoints; DateTime get timestamp;
/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIInsightCopyWith<AIInsight> get copyWith => _$AIInsightCopyWithImpl<AIInsight>(this as AIInsight, _$identity);

  /// Serializes this AIInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.affectedExercise, affectedExercise) || other.affectedExercise == affectedExercise)&&const DeepCollectionEquality().equals(other.affectedTemplates, affectedTemplates)&&const DeepCollectionEquality().equals(other.scientificStrategies, scientificStrategies)&&const DeepCollectionEquality().equals(other.dataPoints, dataPoints)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,severity,title,description,recommendation,priority,affectedExercise,const DeepCollectionEquality().hash(affectedTemplates),const DeepCollectionEquality().hash(scientificStrategies),const DeepCollectionEquality().hash(dataPoints),timestamp);

@override
String toString() {
  return 'AIInsight(id: $id, type: $type, severity: $severity, title: $title, description: $description, recommendation: $recommendation, priority: $priority, affectedExercise: $affectedExercise, affectedTemplates: $affectedTemplates, scientificStrategies: $scientificStrategies, dataPoints: $dataPoints, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $AIInsightCopyWith<$Res>  {
  factory $AIInsightCopyWith(AIInsight value, $Res Function(AIInsight) _then) = _$AIInsightCopyWithImpl;
@useResult
$Res call({
 String id, InsightType type, InsightSeverity severity, String title, String description, String recommendation, int priority, String? affectedExercise, List<String>? affectedTemplates, List<String>? scientificStrategies, Map<String, dynamic>? dataPoints, DateTime timestamp
});




}
/// @nodoc
class _$AIInsightCopyWithImpl<$Res>
    implements $AIInsightCopyWith<$Res> {
  _$AIInsightCopyWithImpl(this._self, this._then);

  final AIInsight _self;
  final $Res Function(AIInsight) _then;

/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? severity = null,Object? title = null,Object? description = null,Object? recommendation = null,Object? priority = null,Object? affectedExercise = freezed,Object? affectedTemplates = freezed,Object? scientificStrategies = freezed,Object? dataPoints = freezed,Object? timestamp = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as InsightSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,affectedExercise: freezed == affectedExercise ? _self.affectedExercise : affectedExercise // ignore: cast_nullable_to_non_nullable
as String?,affectedTemplates: freezed == affectedTemplates ? _self.affectedTemplates : affectedTemplates // ignore: cast_nullable_to_non_nullable
as List<String>?,scientificStrategies: freezed == scientificStrategies ? _self.scientificStrategies : scientificStrategies // ignore: cast_nullable_to_non_nullable
as List<String>?,dataPoints: freezed == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AIInsight].
extension AIInsightPatterns on AIInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIInsight value)  $default,){
final _that = this;
switch (_that) {
case _AIInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIInsight value)?  $default,){
final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  InsightType type,  InsightSeverity severity,  String title,  String description,  String recommendation,  int priority,  String? affectedExercise,  List<String>? affectedTemplates,  List<String>? scientificStrategies,  Map<String, dynamic>? dataPoints,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
return $default(_that.id,_that.type,_that.severity,_that.title,_that.description,_that.recommendation,_that.priority,_that.affectedExercise,_that.affectedTemplates,_that.scientificStrategies,_that.dataPoints,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  InsightType type,  InsightSeverity severity,  String title,  String description,  String recommendation,  int priority,  String? affectedExercise,  List<String>? affectedTemplates,  List<String>? scientificStrategies,  Map<String, dynamic>? dataPoints,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _AIInsight():
return $default(_that.id,_that.type,_that.severity,_that.title,_that.description,_that.recommendation,_that.priority,_that.affectedExercise,_that.affectedTemplates,_that.scientificStrategies,_that.dataPoints,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  InsightType type,  InsightSeverity severity,  String title,  String description,  String recommendation,  int priority,  String? affectedExercise,  List<String>? affectedTemplates,  List<String>? scientificStrategies,  Map<String, dynamic>? dataPoints,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _AIInsight() when $default != null:
return $default(_that.id,_that.type,_that.severity,_that.title,_that.description,_that.recommendation,_that.priority,_that.affectedExercise,_that.affectedTemplates,_that.scientificStrategies,_that.dataPoints,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIInsight implements AIInsight {
  const _AIInsight({required this.id, required this.type, required this.severity, required this.title, required this.description, required this.recommendation, required this.priority, this.affectedExercise, final  List<String>? affectedTemplates, final  List<String>? scientificStrategies, final  Map<String, dynamic>? dataPoints, required this.timestamp}): _affectedTemplates = affectedTemplates,_scientificStrategies = scientificStrategies,_dataPoints = dataPoints;
  factory _AIInsight.fromJson(Map<String, dynamic> json) => _$AIInsightFromJson(json);

@override final  String id;
@override final  InsightType type;
@override final  InsightSeverity severity;
@override final  String title;
@override final  String description;
@override final  String recommendation;
@override final  int priority;
@override final  String? affectedExercise;
 final  List<String>? _affectedTemplates;
@override List<String>? get affectedTemplates {
  final value = _affectedTemplates;
  if (value == null) return null;
  if (_affectedTemplates is EqualUnmodifiableListView) return _affectedTemplates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _scientificStrategies;
@override List<String>? get scientificStrategies {
  final value = _scientificStrategies;
  if (value == null) return null;
  if (_scientificStrategies is EqualUnmodifiableListView) return _scientificStrategies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _dataPoints;
@override Map<String, dynamic>? get dataPoints {
  final value = _dataPoints;
  if (value == null) return null;
  if (_dataPoints is EqualUnmodifiableMapView) return _dataPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime timestamp;

/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIInsightCopyWith<_AIInsight> get copyWith => __$AIInsightCopyWithImpl<_AIInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.affectedExercise, affectedExercise) || other.affectedExercise == affectedExercise)&&const DeepCollectionEquality().equals(other._affectedTemplates, _affectedTemplates)&&const DeepCollectionEquality().equals(other._scientificStrategies, _scientificStrategies)&&const DeepCollectionEquality().equals(other._dataPoints, _dataPoints)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,severity,title,description,recommendation,priority,affectedExercise,const DeepCollectionEquality().hash(_affectedTemplates),const DeepCollectionEquality().hash(_scientificStrategies),const DeepCollectionEquality().hash(_dataPoints),timestamp);

@override
String toString() {
  return 'AIInsight(id: $id, type: $type, severity: $severity, title: $title, description: $description, recommendation: $recommendation, priority: $priority, affectedExercise: $affectedExercise, affectedTemplates: $affectedTemplates, scientificStrategies: $scientificStrategies, dataPoints: $dataPoints, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$AIInsightCopyWith<$Res> implements $AIInsightCopyWith<$Res> {
  factory _$AIInsightCopyWith(_AIInsight value, $Res Function(_AIInsight) _then) = __$AIInsightCopyWithImpl;
@override @useResult
$Res call({
 String id, InsightType type, InsightSeverity severity, String title, String description, String recommendation, int priority, String? affectedExercise, List<String>? affectedTemplates, List<String>? scientificStrategies, Map<String, dynamic>? dataPoints, DateTime timestamp
});




}
/// @nodoc
class __$AIInsightCopyWithImpl<$Res>
    implements _$AIInsightCopyWith<$Res> {
  __$AIInsightCopyWithImpl(this._self, this._then);

  final _AIInsight _self;
  final $Res Function(_AIInsight) _then;

/// Create a copy of AIInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? severity = null,Object? title = null,Object? description = null,Object? recommendation = null,Object? priority = null,Object? affectedExercise = freezed,Object? affectedTemplates = freezed,Object? scientificStrategies = freezed,Object? dataPoints = freezed,Object? timestamp = null,}) {
  return _then(_AIInsight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as InsightSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,affectedExercise: freezed == affectedExercise ? _self.affectedExercise : affectedExercise // ignore: cast_nullable_to_non_nullable
as String?,affectedTemplates: freezed == affectedTemplates ? _self._affectedTemplates : affectedTemplates // ignore: cast_nullable_to_non_nullable
as List<String>?,scientificStrategies: freezed == scientificStrategies ? _self._scientificStrategies : scientificStrategies // ignore: cast_nullable_to_non_nullable
as List<String>?,dataPoints: freezed == dataPoints ? _self._dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
