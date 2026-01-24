// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dropset_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DropsetTemplate {

 String get id; String get name;/// The exercise to perform (e.g., "Bicep Curl", "Leg Press")
 String get exerciseName;/// Number of drop sets (typically 2-4)
 int get drops;/// Starting reps before first drop (e.g., "8-10")
 String get initialReps;/// Weight reduction percentage per drop (e.g., 20 = reduce by 20% each drop)
 int get dropPercentage;/// Rest between drops in seconds (usually 0-10s, just enough to change weight)
 int get restBetweenDrops;/// Total sets of dropsets to perform
 int get totalSets;/// Rest between full dropset rounds in seconds
 int get restBetweenSets;/// Difficulty level
 DropsetDifficulty get difficulty;/// Estimated time in minutes for the complete dropset sequence
 int get estimatedTimeMinutes;/// Scientific basis for this dropset configuration
 String get scientificBasis;/// Additional notes or tips
 String? get notes;/// Time under tension pattern (e.g., "2-0-1" for eccentric-pause-concentric)
 String? get tut;/// Equipment needed
 List<String>? get equipmentRequired;/// Alternative equipment options
 List<String>? get equipmentAlternatives;/// Target muscles
 List<String>? get targetMuscles;/// Whether this is a custom user template
 bool get isCustom;/// Creation timestamp for custom templates
 DateTime? get createdAt;
/// Create a copy of DropsetTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DropsetTemplateCopyWith<DropsetTemplate> get copyWith => _$DropsetTemplateCopyWithImpl<DropsetTemplate>(this as DropsetTemplate, _$identity);

  /// Serializes this DropsetTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DropsetTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.drops, drops) || other.drops == drops)&&(identical(other.initialReps, initialReps) || other.initialReps == initialReps)&&(identical(other.dropPercentage, dropPercentage) || other.dropPercentage == dropPercentage)&&(identical(other.restBetweenDrops, restBetweenDrops) || other.restBetweenDrops == restBetweenDrops)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.restBetweenSets, restBetweenSets) || other.restBetweenSets == restBetweenSets)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTimeMinutes, estimatedTimeMinutes) || other.estimatedTimeMinutes == estimatedTimeMinutes)&&(identical(other.scientificBasis, scientificBasis) || other.scientificBasis == scientificBasis)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.tut, tut) || other.tut == tut)&&const DeepCollectionEquality().equals(other.equipmentRequired, equipmentRequired)&&const DeepCollectionEquality().equals(other.equipmentAlternatives, equipmentAlternatives)&&const DeepCollectionEquality().equals(other.targetMuscles, targetMuscles)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,exerciseName,drops,initialReps,dropPercentage,restBetweenDrops,totalSets,restBetweenSets,difficulty,estimatedTimeMinutes,scientificBasis,notes,tut,const DeepCollectionEquality().hash(equipmentRequired),const DeepCollectionEquality().hash(equipmentAlternatives),const DeepCollectionEquality().hash(targetMuscles),isCustom,createdAt]);

@override
String toString() {
  return 'DropsetTemplate(id: $id, name: $name, exerciseName: $exerciseName, drops: $drops, initialReps: $initialReps, dropPercentage: $dropPercentage, restBetweenDrops: $restBetweenDrops, totalSets: $totalSets, restBetweenSets: $restBetweenSets, difficulty: $difficulty, estimatedTimeMinutes: $estimatedTimeMinutes, scientificBasis: $scientificBasis, notes: $notes, tut: $tut, equipmentRequired: $equipmentRequired, equipmentAlternatives: $equipmentAlternatives, targetMuscles: $targetMuscles, isCustom: $isCustom, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DropsetTemplateCopyWith<$Res>  {
  factory $DropsetTemplateCopyWith(DropsetTemplate value, $Res Function(DropsetTemplate) _then) = _$DropsetTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String exerciseName, int drops, String initialReps, int dropPercentage, int restBetweenDrops, int totalSets, int restBetweenSets, DropsetDifficulty difficulty, int estimatedTimeMinutes, String scientificBasis, String? notes, String? tut, List<String>? equipmentRequired, List<String>? equipmentAlternatives, List<String>? targetMuscles, bool isCustom, DateTime? createdAt
});




}
/// @nodoc
class _$DropsetTemplateCopyWithImpl<$Res>
    implements $DropsetTemplateCopyWith<$Res> {
  _$DropsetTemplateCopyWithImpl(this._self, this._then);

  final DropsetTemplate _self;
  final $Res Function(DropsetTemplate) _then;

/// Create a copy of DropsetTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? exerciseName = null,Object? drops = null,Object? initialReps = null,Object? dropPercentage = null,Object? restBetweenDrops = null,Object? totalSets = null,Object? restBetweenSets = null,Object? difficulty = null,Object? estimatedTimeMinutes = null,Object? scientificBasis = null,Object? notes = freezed,Object? tut = freezed,Object? equipmentRequired = freezed,Object? equipmentAlternatives = freezed,Object? targetMuscles = freezed,Object? isCustom = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,drops: null == drops ? _self.drops : drops // ignore: cast_nullable_to_non_nullable
as int,initialReps: null == initialReps ? _self.initialReps : initialReps // ignore: cast_nullable_to_non_nullable
as String,dropPercentage: null == dropPercentage ? _self.dropPercentage : dropPercentage // ignore: cast_nullable_to_non_nullable
as int,restBetweenDrops: null == restBetweenDrops ? _self.restBetweenDrops : restBetweenDrops // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,restBetweenSets: null == restBetweenSets ? _self.restBetweenSets : restBetweenSets // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DropsetDifficulty,estimatedTimeMinutes: null == estimatedTimeMinutes ? _self.estimatedTimeMinutes : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [DropsetTemplate].
extension DropsetTemplatePatterns on DropsetTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DropsetTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DropsetTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DropsetTemplate value)  $default,){
final _that = this;
switch (_that) {
case _DropsetTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DropsetTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _DropsetTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String exerciseName,  int drops,  String initialReps,  int dropPercentage,  int restBetweenDrops,  int totalSets,  int restBetweenSets,  DropsetDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DropsetTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exerciseName,_that.drops,_that.initialReps,_that.dropPercentage,_that.restBetweenDrops,_that.totalSets,_that.restBetweenSets,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String exerciseName,  int drops,  String initialReps,  int dropPercentage,  int restBetweenDrops,  int totalSets,  int restBetweenSets,  DropsetDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _DropsetTemplate():
return $default(_that.id,_that.name,_that.exerciseName,_that.drops,_that.initialReps,_that.dropPercentage,_that.restBetweenDrops,_that.totalSets,_that.restBetweenSets,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String exerciseName,  int drops,  String initialReps,  int dropPercentage,  int restBetweenDrops,  int totalSets,  int restBetweenSets,  DropsetDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DropsetTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exerciseName,_that.drops,_that.initialReps,_that.dropPercentage,_that.restBetweenDrops,_that.totalSets,_that.restBetweenSets,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DropsetTemplate implements DropsetTemplate {
  const _DropsetTemplate({required this.id, required this.name, required this.exerciseName, required this.drops, required this.initialReps, required this.dropPercentage, required this.restBetweenDrops, required this.totalSets, required this.restBetweenSets, required this.difficulty, required this.estimatedTimeMinutes, required this.scientificBasis, this.notes, this.tut, final  List<String>? equipmentRequired, final  List<String>? equipmentAlternatives, final  List<String>? targetMuscles, this.isCustom = false, this.createdAt}): _equipmentRequired = equipmentRequired,_equipmentAlternatives = equipmentAlternatives,_targetMuscles = targetMuscles;
  factory _DropsetTemplate.fromJson(Map<String, dynamic> json) => _$DropsetTemplateFromJson(json);

@override final  String id;
@override final  String name;
/// The exercise to perform (e.g., "Bicep Curl", "Leg Press")
@override final  String exerciseName;
/// Number of drop sets (typically 2-4)
@override final  int drops;
/// Starting reps before first drop (e.g., "8-10")
@override final  String initialReps;
/// Weight reduction percentage per drop (e.g., 20 = reduce by 20% each drop)
@override final  int dropPercentage;
/// Rest between drops in seconds (usually 0-10s, just enough to change weight)
@override final  int restBetweenDrops;
/// Total sets of dropsets to perform
@override final  int totalSets;
/// Rest between full dropset rounds in seconds
@override final  int restBetweenSets;
/// Difficulty level
@override final  DropsetDifficulty difficulty;
/// Estimated time in minutes for the complete dropset sequence
@override final  int estimatedTimeMinutes;
/// Scientific basis for this dropset configuration
@override final  String scientificBasis;
/// Additional notes or tips
@override final  String? notes;
/// Time under tension pattern (e.g., "2-0-1" for eccentric-pause-concentric)
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

/// Create a copy of DropsetTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DropsetTemplateCopyWith<_DropsetTemplate> get copyWith => __$DropsetTemplateCopyWithImpl<_DropsetTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DropsetTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DropsetTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.drops, drops) || other.drops == drops)&&(identical(other.initialReps, initialReps) || other.initialReps == initialReps)&&(identical(other.dropPercentage, dropPercentage) || other.dropPercentage == dropPercentage)&&(identical(other.restBetweenDrops, restBetweenDrops) || other.restBetweenDrops == restBetweenDrops)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.restBetweenSets, restBetweenSets) || other.restBetweenSets == restBetweenSets)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTimeMinutes, estimatedTimeMinutes) || other.estimatedTimeMinutes == estimatedTimeMinutes)&&(identical(other.scientificBasis, scientificBasis) || other.scientificBasis == scientificBasis)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.tut, tut) || other.tut == tut)&&const DeepCollectionEquality().equals(other._equipmentRequired, _equipmentRequired)&&const DeepCollectionEquality().equals(other._equipmentAlternatives, _equipmentAlternatives)&&const DeepCollectionEquality().equals(other._targetMuscles, _targetMuscles)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,exerciseName,drops,initialReps,dropPercentage,restBetweenDrops,totalSets,restBetweenSets,difficulty,estimatedTimeMinutes,scientificBasis,notes,tut,const DeepCollectionEquality().hash(_equipmentRequired),const DeepCollectionEquality().hash(_equipmentAlternatives),const DeepCollectionEquality().hash(_targetMuscles),isCustom,createdAt]);

@override
String toString() {
  return 'DropsetTemplate(id: $id, name: $name, exerciseName: $exerciseName, drops: $drops, initialReps: $initialReps, dropPercentage: $dropPercentage, restBetweenDrops: $restBetweenDrops, totalSets: $totalSets, restBetweenSets: $restBetweenSets, difficulty: $difficulty, estimatedTimeMinutes: $estimatedTimeMinutes, scientificBasis: $scientificBasis, notes: $notes, tut: $tut, equipmentRequired: $equipmentRequired, equipmentAlternatives: $equipmentAlternatives, targetMuscles: $targetMuscles, isCustom: $isCustom, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DropsetTemplateCopyWith<$Res> implements $DropsetTemplateCopyWith<$Res> {
  factory _$DropsetTemplateCopyWith(_DropsetTemplate value, $Res Function(_DropsetTemplate) _then) = __$DropsetTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String exerciseName, int drops, String initialReps, int dropPercentage, int restBetweenDrops, int totalSets, int restBetweenSets, DropsetDifficulty difficulty, int estimatedTimeMinutes, String scientificBasis, String? notes, String? tut, List<String>? equipmentRequired, List<String>? equipmentAlternatives, List<String>? targetMuscles, bool isCustom, DateTime? createdAt
});




}
/// @nodoc
class __$DropsetTemplateCopyWithImpl<$Res>
    implements _$DropsetTemplateCopyWith<$Res> {
  __$DropsetTemplateCopyWithImpl(this._self, this._then);

  final _DropsetTemplate _self;
  final $Res Function(_DropsetTemplate) _then;

/// Create a copy of DropsetTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? exerciseName = null,Object? drops = null,Object? initialReps = null,Object? dropPercentage = null,Object? restBetweenDrops = null,Object? totalSets = null,Object? restBetweenSets = null,Object? difficulty = null,Object? estimatedTimeMinutes = null,Object? scientificBasis = null,Object? notes = freezed,Object? tut = freezed,Object? equipmentRequired = freezed,Object? equipmentAlternatives = freezed,Object? targetMuscles = freezed,Object? isCustom = null,Object? createdAt = freezed,}) {
  return _then(_DropsetTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,drops: null == drops ? _self.drops : drops // ignore: cast_nullable_to_non_nullable
as int,initialReps: null == initialReps ? _self.initialReps : initialReps // ignore: cast_nullable_to_non_nullable
as String,dropPercentage: null == dropPercentage ? _self.dropPercentage : dropPercentage // ignore: cast_nullable_to_non_nullable
as int,restBetweenDrops: null == restBetweenDrops ? _self.restBetweenDrops : restBetweenDrops // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,restBetweenSets: null == restBetweenSets ? _self.restBetweenSets : restBetweenSets // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as DropsetDifficulty,estimatedTimeMinutes: null == estimatedTimeMinutes ? _self.estimatedTimeMinutes : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
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
