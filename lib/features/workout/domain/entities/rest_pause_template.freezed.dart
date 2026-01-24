// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rest_pause_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RestPauseTemplate {

 String get id; String get name;/// The exercise to perform (e.g., "Bench Press", "Leg Extension")
 String get exerciseName;/// Initial reps to perform before first pause (e.g., "6-8")
 String get initialReps;/// Number of rest-pause clusters (typically 2-3)
 int get clusters;/// Target reps per cluster after initial set (e.g., "2-4")
 String get clusterReps;/// Rest duration between clusters in seconds (typically 10-20s)
 int get pauseDuration;/// Total sets of rest-pause to perform
 int get totalSets;/// Rest between full rest-pause sets in seconds
 int get restBetweenSets;/// Difficulty level
 RestPauseDifficulty get difficulty;/// Estimated time in minutes for the complete rest-pause sequence
 int get estimatedTimeMinutes;/// Scientific basis for this rest-pause configuration
 String get scientificBasis;/// Additional notes or tips
 String? get notes;/// Time under tension pattern (e.g., "2-0-1")
 String? get tut;/// Equipment needed
 List<String>? get equipmentRequired;/// Alternative equipment options
 List<String>? get equipmentAlternatives;/// Target muscles
 List<String>? get targetMuscles;/// Whether this is a custom user template
 bool get isCustom;/// Creation timestamp for custom templates
 DateTime? get createdAt;
/// Create a copy of RestPauseTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestPauseTemplateCopyWith<RestPauseTemplate> get copyWith => _$RestPauseTemplateCopyWithImpl<RestPauseTemplate>(this as RestPauseTemplate, _$identity);

  /// Serializes this RestPauseTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestPauseTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.initialReps, initialReps) || other.initialReps == initialReps)&&(identical(other.clusters, clusters) || other.clusters == clusters)&&(identical(other.clusterReps, clusterReps) || other.clusterReps == clusterReps)&&(identical(other.pauseDuration, pauseDuration) || other.pauseDuration == pauseDuration)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.restBetweenSets, restBetweenSets) || other.restBetweenSets == restBetweenSets)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTimeMinutes, estimatedTimeMinutes) || other.estimatedTimeMinutes == estimatedTimeMinutes)&&(identical(other.scientificBasis, scientificBasis) || other.scientificBasis == scientificBasis)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.tut, tut) || other.tut == tut)&&const DeepCollectionEquality().equals(other.equipmentRequired, equipmentRequired)&&const DeepCollectionEquality().equals(other.equipmentAlternatives, equipmentAlternatives)&&const DeepCollectionEquality().equals(other.targetMuscles, targetMuscles)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,exerciseName,initialReps,clusters,clusterReps,pauseDuration,totalSets,restBetweenSets,difficulty,estimatedTimeMinutes,scientificBasis,notes,tut,const DeepCollectionEquality().hash(equipmentRequired),const DeepCollectionEquality().hash(equipmentAlternatives),const DeepCollectionEquality().hash(targetMuscles),isCustom,createdAt]);

@override
String toString() {
  return 'RestPauseTemplate(id: $id, name: $name, exerciseName: $exerciseName, initialReps: $initialReps, clusters: $clusters, clusterReps: $clusterReps, pauseDuration: $pauseDuration, totalSets: $totalSets, restBetweenSets: $restBetweenSets, difficulty: $difficulty, estimatedTimeMinutes: $estimatedTimeMinutes, scientificBasis: $scientificBasis, notes: $notes, tut: $tut, equipmentRequired: $equipmentRequired, equipmentAlternatives: $equipmentAlternatives, targetMuscles: $targetMuscles, isCustom: $isCustom, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RestPauseTemplateCopyWith<$Res>  {
  factory $RestPauseTemplateCopyWith(RestPauseTemplate value, $Res Function(RestPauseTemplate) _then) = _$RestPauseTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String exerciseName, String initialReps, int clusters, String clusterReps, int pauseDuration, int totalSets, int restBetweenSets, RestPauseDifficulty difficulty, int estimatedTimeMinutes, String scientificBasis, String? notes, String? tut, List<String>? equipmentRequired, List<String>? equipmentAlternatives, List<String>? targetMuscles, bool isCustom, DateTime? createdAt
});




}
/// @nodoc
class _$RestPauseTemplateCopyWithImpl<$Res>
    implements $RestPauseTemplateCopyWith<$Res> {
  _$RestPauseTemplateCopyWithImpl(this._self, this._then);

  final RestPauseTemplate _self;
  final $Res Function(RestPauseTemplate) _then;

/// Create a copy of RestPauseTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? exerciseName = null,Object? initialReps = null,Object? clusters = null,Object? clusterReps = null,Object? pauseDuration = null,Object? totalSets = null,Object? restBetweenSets = null,Object? difficulty = null,Object? estimatedTimeMinutes = null,Object? scientificBasis = null,Object? notes = freezed,Object? tut = freezed,Object? equipmentRequired = freezed,Object? equipmentAlternatives = freezed,Object? targetMuscles = freezed,Object? isCustom = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,initialReps: null == initialReps ? _self.initialReps : initialReps // ignore: cast_nullable_to_non_nullable
as String,clusters: null == clusters ? _self.clusters : clusters // ignore: cast_nullable_to_non_nullable
as int,clusterReps: null == clusterReps ? _self.clusterReps : clusterReps // ignore: cast_nullable_to_non_nullable
as String,pauseDuration: null == pauseDuration ? _self.pauseDuration : pauseDuration // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,restBetweenSets: null == restBetweenSets ? _self.restBetweenSets : restBetweenSets // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as RestPauseDifficulty,estimatedTimeMinutes: null == estimatedTimeMinutes ? _self.estimatedTimeMinutes : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,scientificBasis: null == scientificBasis ? _self.scientificBasis : scientificBasis // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tut: freezed == tut ? _self.tut : tut // ignore: cast_nullable_to_non_nullable
as String?,equipmentRequired: freezed == equipmentRequired ? _self.equipmentRequired : equipmentRequired // ignore: cast_nullable_to_non_nullable
as List<String>?,equipmentAlternatives: freezed == equipmentAlternatives ? _self.equipmentAlternatives : equipmentAlternatives // ignore: cast_nullable_to_non_nullable
as List<String>?,targetMuscles: freezed == targetMuscles ? _self.targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RestPauseTemplate].
extension RestPauseTemplatePatterns on RestPauseTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestPauseTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestPauseTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestPauseTemplate value)  $default,){
final _that = this;
switch (_that) {
case _RestPauseTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestPauseTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _RestPauseTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String exerciseName,  String initialReps,  int clusters,  String clusterReps,  int pauseDuration,  int totalSets,  int restBetweenSets,  RestPauseDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestPauseTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exerciseName,_that.initialReps,_that.clusters,_that.clusterReps,_that.pauseDuration,_that.totalSets,_that.restBetweenSets,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String exerciseName,  String initialReps,  int clusters,  String clusterReps,  int pauseDuration,  int totalSets,  int restBetweenSets,  RestPauseDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RestPauseTemplate():
return $default(_that.id,_that.name,_that.exerciseName,_that.initialReps,_that.clusters,_that.clusterReps,_that.pauseDuration,_that.totalSets,_that.restBetweenSets,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String exerciseName,  String initialReps,  int clusters,  String clusterReps,  int pauseDuration,  int totalSets,  int restBetweenSets,  RestPauseDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RestPauseTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exerciseName,_that.initialReps,_that.clusters,_that.clusterReps,_that.pauseDuration,_that.totalSets,_that.restBetweenSets,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RestPauseTemplate implements RestPauseTemplate {
  const _RestPauseTemplate({required this.id, required this.name, required this.exerciseName, required this.initialReps, required this.clusters, required this.clusterReps, required this.pauseDuration, required this.totalSets, required this.restBetweenSets, required this.difficulty, required this.estimatedTimeMinutes, required this.scientificBasis, this.notes, this.tut, final  List<String>? equipmentRequired, final  List<String>? equipmentAlternatives, final  List<String>? targetMuscles, this.isCustom = false, this.createdAt}): _equipmentRequired = equipmentRequired,_equipmentAlternatives = equipmentAlternatives,_targetMuscles = targetMuscles;
  factory _RestPauseTemplate.fromJson(Map<String, dynamic> json) => _$RestPauseTemplateFromJson(json);

@override final  String id;
@override final  String name;
/// The exercise to perform (e.g., "Bench Press", "Leg Extension")
@override final  String exerciseName;
/// Initial reps to perform before first pause (e.g., "6-8")
@override final  String initialReps;
/// Number of rest-pause clusters (typically 2-3)
@override final  int clusters;
/// Target reps per cluster after initial set (e.g., "2-4")
@override final  String clusterReps;
/// Rest duration between clusters in seconds (typically 10-20s)
@override final  int pauseDuration;
/// Total sets of rest-pause to perform
@override final  int totalSets;
/// Rest between full rest-pause sets in seconds
@override final  int restBetweenSets;
/// Difficulty level
@override final  RestPauseDifficulty difficulty;
/// Estimated time in minutes for the complete rest-pause sequence
@override final  int estimatedTimeMinutes;
/// Scientific basis for this rest-pause configuration
@override final  String scientificBasis;
/// Additional notes or tips
@override final  String? notes;
/// Time under tension pattern (e.g., "2-0-1")
@override final  String? tut;
/// Equipment needed
 final  List<String>? _equipmentRequired;
/// Equipment needed
@override List<String>? get equipmentRequired {
  final value = _equipmentRequired;
  if (value == null) return null;
  if (_equipmentRequired is EqualUnmodifiableListView) return _equipmentRequired;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Alternative equipment options
 final  List<String>? _equipmentAlternatives;
/// Alternative equipment options
@override List<String>? get equipmentAlternatives {
  final value = _equipmentAlternatives;
  if (value == null) return null;
  if (_equipmentAlternatives is EqualUnmodifiableListView) return _equipmentAlternatives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Target muscles
 final  List<String>? _targetMuscles;
/// Target muscles
@override List<String>? get targetMuscles {
  final value = _targetMuscles;
  if (value == null) return null;
  if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Whether this is a custom user template
@override@JsonKey() final  bool isCustom;
/// Creation timestamp for custom templates
@override final  DateTime? createdAt;

/// Create a copy of RestPauseTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestPauseTemplateCopyWith<_RestPauseTemplate> get copyWith => __$RestPauseTemplateCopyWithImpl<_RestPauseTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RestPauseTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestPauseTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.initialReps, initialReps) || other.initialReps == initialReps)&&(identical(other.clusters, clusters) || other.clusters == clusters)&&(identical(other.clusterReps, clusterReps) || other.clusterReps == clusterReps)&&(identical(other.pauseDuration, pauseDuration) || other.pauseDuration == pauseDuration)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.restBetweenSets, restBetweenSets) || other.restBetweenSets == restBetweenSets)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTimeMinutes, estimatedTimeMinutes) || other.estimatedTimeMinutes == estimatedTimeMinutes)&&(identical(other.scientificBasis, scientificBasis) || other.scientificBasis == scientificBasis)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.tut, tut) || other.tut == tut)&&const DeepCollectionEquality().equals(other._equipmentRequired, _equipmentRequired)&&const DeepCollectionEquality().equals(other._equipmentAlternatives, _equipmentAlternatives)&&const DeepCollectionEquality().equals(other._targetMuscles, _targetMuscles)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,exerciseName,initialReps,clusters,clusterReps,pauseDuration,totalSets,restBetweenSets,difficulty,estimatedTimeMinutes,scientificBasis,notes,tut,const DeepCollectionEquality().hash(_equipmentRequired),const DeepCollectionEquality().hash(_equipmentAlternatives),const DeepCollectionEquality().hash(_targetMuscles),isCustom,createdAt]);

@override
String toString() {
  return 'RestPauseTemplate(id: $id, name: $name, exerciseName: $exerciseName, initialReps: $initialReps, clusters: $clusters, clusterReps: $clusterReps, pauseDuration: $pauseDuration, totalSets: $totalSets, restBetweenSets: $restBetweenSets, difficulty: $difficulty, estimatedTimeMinutes: $estimatedTimeMinutes, scientificBasis: $scientificBasis, notes: $notes, tut: $tut, equipmentRequired: $equipmentRequired, equipmentAlternatives: $equipmentAlternatives, targetMuscles: $targetMuscles, isCustom: $isCustom, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RestPauseTemplateCopyWith<$Res> implements $RestPauseTemplateCopyWith<$Res> {
  factory _$RestPauseTemplateCopyWith(_RestPauseTemplate value, $Res Function(_RestPauseTemplate) _then) = __$RestPauseTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String exerciseName, String initialReps, int clusters, String clusterReps, int pauseDuration, int totalSets, int restBetweenSets, RestPauseDifficulty difficulty, int estimatedTimeMinutes, String scientificBasis, String? notes, String? tut, List<String>? equipmentRequired, List<String>? equipmentAlternatives, List<String>? targetMuscles, bool isCustom, DateTime? createdAt
});




}
/// @nodoc
class __$RestPauseTemplateCopyWithImpl<$Res>
    implements _$RestPauseTemplateCopyWith<$Res> {
  __$RestPauseTemplateCopyWithImpl(this._self, this._then);

  final _RestPauseTemplate _self;
  final $Res Function(_RestPauseTemplate) _then;

/// Create a copy of RestPauseTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? exerciseName = null,Object? initialReps = null,Object? clusters = null,Object? clusterReps = null,Object? pauseDuration = null,Object? totalSets = null,Object? restBetweenSets = null,Object? difficulty = null,Object? estimatedTimeMinutes = null,Object? scientificBasis = null,Object? notes = freezed,Object? tut = freezed,Object? equipmentRequired = freezed,Object? equipmentAlternatives = freezed,Object? targetMuscles = freezed,Object? isCustom = null,Object? createdAt = freezed,}) {
  return _then(_RestPauseTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,initialReps: null == initialReps ? _self.initialReps : initialReps // ignore: cast_nullable_to_non_nullable
as String,clusters: null == clusters ? _self.clusters : clusters // ignore: cast_nullable_to_non_nullable
as int,clusterReps: null == clusterReps ? _self.clusterReps : clusterReps // ignore: cast_nullable_to_non_nullable
as String,pauseDuration: null == pauseDuration ? _self.pauseDuration : pauseDuration // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,restBetweenSets: null == restBetweenSets ? _self.restBetweenSets : restBetweenSets // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as RestPauseDifficulty,estimatedTimeMinutes: null == estimatedTimeMinutes ? _self.estimatedTimeMinutes : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,scientificBasis: null == scientificBasis ? _self.scientificBasis : scientificBasis // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tut: freezed == tut ? _self.tut : tut // ignore: cast_nullable_to_non_nullable
as String?,equipmentRequired: freezed == equipmentRequired ? _self._equipmentRequired : equipmentRequired // ignore: cast_nullable_to_non_nullable
as List<String>?,equipmentAlternatives: freezed == equipmentAlternatives ? _self._equipmentAlternatives : equipmentAlternatives // ignore: cast_nullable_to_non_nullable
as List<String>?,targetMuscles: freezed == targetMuscles ? _self._targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
