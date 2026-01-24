// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'superset_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupersetTemplate {

 String get id; String get name;/// Exercise IDs for database lookup (stored in JSON)
 List<String> get exerciseIds;/// Exercise names - populated at runtime from database lookup (localized)
/// Not stored in JSON, computed from exerciseIds
 List<String> get exerciseNames; int get rounds; String get repsRange; int get restAfterRound; int get restBetween; TemplateDifficulty get difficulty; int get estimatedTimeMinutes; String get scientificBasis; String? get notes; String? get tut; List<String>? get equipmentRequired; List<String>? get equipmentAlternatives; UserPersona? get targetPersona; List<String>? get targetMuscles; bool get isCustom; DateTime? get createdAt;
/// Create a copy of SupersetTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupersetTemplateCopyWith<SupersetTemplate> get copyWith => _$SupersetTemplateCopyWithImpl<SupersetTemplate>(this as SupersetTemplate, _$identity);

  /// Serializes this SupersetTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupersetTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.exerciseIds, exerciseIds)&&const DeepCollectionEquality().equals(other.exerciseNames, exerciseNames)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.repsRange, repsRange) || other.repsRange == repsRange)&&(identical(other.restAfterRound, restAfterRound) || other.restAfterRound == restAfterRound)&&(identical(other.restBetween, restBetween) || other.restBetween == restBetween)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTimeMinutes, estimatedTimeMinutes) || other.estimatedTimeMinutes == estimatedTimeMinutes)&&(identical(other.scientificBasis, scientificBasis) || other.scientificBasis == scientificBasis)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.tut, tut) || other.tut == tut)&&const DeepCollectionEquality().equals(other.equipmentRequired, equipmentRequired)&&const DeepCollectionEquality().equals(other.equipmentAlternatives, equipmentAlternatives)&&(identical(other.targetPersona, targetPersona) || other.targetPersona == targetPersona)&&const DeepCollectionEquality().equals(other.targetMuscles, targetMuscles)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,const DeepCollectionEquality().hash(exerciseIds),const DeepCollectionEquality().hash(exerciseNames),rounds,repsRange,restAfterRound,restBetween,difficulty,estimatedTimeMinutes,scientificBasis,notes,tut,const DeepCollectionEquality().hash(equipmentRequired),const DeepCollectionEquality().hash(equipmentAlternatives),targetPersona,const DeepCollectionEquality().hash(targetMuscles),isCustom,createdAt]);

@override
String toString() {
  return 'SupersetTemplate(id: $id, name: $name, exerciseIds: $exerciseIds, exerciseNames: $exerciseNames, rounds: $rounds, repsRange: $repsRange, restAfterRound: $restAfterRound, restBetween: $restBetween, difficulty: $difficulty, estimatedTimeMinutes: $estimatedTimeMinutes, scientificBasis: $scientificBasis, notes: $notes, tut: $tut, equipmentRequired: $equipmentRequired, equipmentAlternatives: $equipmentAlternatives, targetPersona: $targetPersona, targetMuscles: $targetMuscles, isCustom: $isCustom, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SupersetTemplateCopyWith<$Res>  {
  factory $SupersetTemplateCopyWith(SupersetTemplate value, $Res Function(SupersetTemplate) _then) = _$SupersetTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> exerciseIds, List<String> exerciseNames, int rounds, String repsRange, int restAfterRound, int restBetween, TemplateDifficulty difficulty, int estimatedTimeMinutes, String scientificBasis, String? notes, String? tut, List<String>? equipmentRequired, List<String>? equipmentAlternatives, UserPersona? targetPersona, List<String>? targetMuscles, bool isCustom, DateTime? createdAt
});




}
/// @nodoc
class _$SupersetTemplateCopyWithImpl<$Res>
    implements $SupersetTemplateCopyWith<$Res> {
  _$SupersetTemplateCopyWithImpl(this._self, this._then);

  final SupersetTemplate _self;
  final $Res Function(SupersetTemplate) _then;

/// Create a copy of SupersetTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? exerciseIds = null,Object? exerciseNames = null,Object? rounds = null,Object? repsRange = null,Object? restAfterRound = null,Object? restBetween = null,Object? difficulty = null,Object? estimatedTimeMinutes = null,Object? scientificBasis = null,Object? notes = freezed,Object? tut = freezed,Object? equipmentRequired = freezed,Object? equipmentAlternatives = freezed,Object? targetPersona = freezed,Object? targetMuscles = freezed,Object? isCustom = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exerciseIds: null == exerciseIds ? _self.exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,exerciseNames: null == exerciseNames ? _self.exerciseNames : exerciseNames // ignore: cast_nullable_to_non_nullable
as List<String>,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,repsRange: null == repsRange ? _self.repsRange : repsRange // ignore: cast_nullable_to_non_nullable
as String,restAfterRound: null == restAfterRound ? _self.restAfterRound : restAfterRound // ignore: cast_nullable_to_non_nullable
as int,restBetween: null == restBetween ? _self.restBetween : restBetween // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as TemplateDifficulty,estimatedTimeMinutes: null == estimatedTimeMinutes ? _self.estimatedTimeMinutes : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,scientificBasis: null == scientificBasis ? _self.scientificBasis : scientificBasis // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tut: freezed == tut ? _self.tut : tut // ignore: cast_nullable_to_non_nullable
as String?,equipmentRequired: freezed == equipmentRequired ? _self.equipmentRequired : equipmentRequired // ignore: cast_nullable_to_non_nullable
as List<String>?,equipmentAlternatives: freezed == equipmentAlternatives ? _self.equipmentAlternatives : equipmentAlternatives // ignore: cast_nullable_to_non_nullable
as List<String>?,targetPersona: freezed == targetPersona ? _self.targetPersona : targetPersona // ignore: cast_nullable_to_non_nullable
as UserPersona?,targetMuscles: freezed == targetMuscles ? _self.targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupersetTemplate].
extension SupersetTemplatePatterns on SupersetTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupersetTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupersetTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupersetTemplate value)  $default,){
final _that = this;
switch (_that) {
case _SupersetTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupersetTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _SupersetTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> exerciseIds,  List<String> exerciseNames,  int rounds,  String repsRange,  int restAfterRound,  int restBetween,  TemplateDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  UserPersona? targetPersona,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupersetTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exerciseIds,_that.exerciseNames,_that.rounds,_that.repsRange,_that.restAfterRound,_that.restBetween,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetPersona,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> exerciseIds,  List<String> exerciseNames,  int rounds,  String repsRange,  int restAfterRound,  int restBetween,  TemplateDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  UserPersona? targetPersona,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SupersetTemplate():
return $default(_that.id,_that.name,_that.exerciseIds,_that.exerciseNames,_that.rounds,_that.repsRange,_that.restAfterRound,_that.restBetween,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetPersona,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> exerciseIds,  List<String> exerciseNames,  int rounds,  String repsRange,  int restAfterRound,  int restBetween,  TemplateDifficulty difficulty,  int estimatedTimeMinutes,  String scientificBasis,  String? notes,  String? tut,  List<String>? equipmentRequired,  List<String>? equipmentAlternatives,  UserPersona? targetPersona,  List<String>? targetMuscles,  bool isCustom,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SupersetTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exerciseIds,_that.exerciseNames,_that.rounds,_that.repsRange,_that.restAfterRound,_that.restBetween,_that.difficulty,_that.estimatedTimeMinutes,_that.scientificBasis,_that.notes,_that.tut,_that.equipmentRequired,_that.equipmentAlternatives,_that.targetPersona,_that.targetMuscles,_that.isCustom,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupersetTemplate implements SupersetTemplate {
  const _SupersetTemplate({required this.id, required this.name, required final  List<String> exerciseIds, final  List<String> exerciseNames = const [], required this.rounds, required this.repsRange, required this.restAfterRound, required this.restBetween, required this.difficulty, required this.estimatedTimeMinutes, required this.scientificBasis, this.notes, this.tut, final  List<String>? equipmentRequired, final  List<String>? equipmentAlternatives, this.targetPersona, final  List<String>? targetMuscles, this.isCustom = false, this.createdAt}): _exerciseIds = exerciseIds,_exerciseNames = exerciseNames,_equipmentRequired = equipmentRequired,_equipmentAlternatives = equipmentAlternatives,_targetMuscles = targetMuscles;
  factory _SupersetTemplate.fromJson(Map<String, dynamic> json) => _$SupersetTemplateFromJson(json);

@override final  String id;
@override final  String name;
/// Exercise IDs for database lookup (stored in JSON)
 final  List<String> _exerciseIds;
/// Exercise IDs for database lookup (stored in JSON)
@override List<String> get exerciseIds {
  if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseIds);
}

/// Exercise names - populated at runtime from database lookup (localized)
/// Not stored in JSON, computed from exerciseIds
 final  List<String> _exerciseNames;
/// Exercise names - populated at runtime from database lookup (localized)
/// Not stored in JSON, computed from exerciseIds
@override@JsonKey() List<String> get exerciseNames {
  if (_exerciseNames is EqualUnmodifiableListView) return _exerciseNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseNames);
}

@override final  int rounds;
@override final  String repsRange;
@override final  int restAfterRound;
@override final  int restBetween;
@override final  TemplateDifficulty difficulty;
@override final  int estimatedTimeMinutes;
@override final  String scientificBasis;
@override final  String? notes;
@override final  String? tut;
 final  List<String>? _equipmentRequired;
@override List<String>? get equipmentRequired {
  final value = _equipmentRequired;
  if (value == null) return null;
  if (_equipmentRequired is EqualUnmodifiableListView) return _equipmentRequired;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _equipmentAlternatives;
@override List<String>? get equipmentAlternatives {
  final value = _equipmentAlternatives;
  if (value == null) return null;
  if (_equipmentAlternatives is EqualUnmodifiableListView) return _equipmentAlternatives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  UserPersona? targetPersona;
 final  List<String>? _targetMuscles;
@override List<String>? get targetMuscles {
  final value = _targetMuscles;
  if (value == null) return null;
  if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isCustom;
@override final  DateTime? createdAt;

/// Create a copy of SupersetTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupersetTemplateCopyWith<_SupersetTemplate> get copyWith => __$SupersetTemplateCopyWithImpl<_SupersetTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupersetTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupersetTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._exerciseIds, _exerciseIds)&&const DeepCollectionEquality().equals(other._exerciseNames, _exerciseNames)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.repsRange, repsRange) || other.repsRange == repsRange)&&(identical(other.restAfterRound, restAfterRound) || other.restAfterRound == restAfterRound)&&(identical(other.restBetween, restBetween) || other.restBetween == restBetween)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.estimatedTimeMinutes, estimatedTimeMinutes) || other.estimatedTimeMinutes == estimatedTimeMinutes)&&(identical(other.scientificBasis, scientificBasis) || other.scientificBasis == scientificBasis)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.tut, tut) || other.tut == tut)&&const DeepCollectionEquality().equals(other._equipmentRequired, _equipmentRequired)&&const DeepCollectionEquality().equals(other._equipmentAlternatives, _equipmentAlternatives)&&(identical(other.targetPersona, targetPersona) || other.targetPersona == targetPersona)&&const DeepCollectionEquality().equals(other._targetMuscles, _targetMuscles)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,const DeepCollectionEquality().hash(_exerciseIds),const DeepCollectionEquality().hash(_exerciseNames),rounds,repsRange,restAfterRound,restBetween,difficulty,estimatedTimeMinutes,scientificBasis,notes,tut,const DeepCollectionEquality().hash(_equipmentRequired),const DeepCollectionEquality().hash(_equipmentAlternatives),targetPersona,const DeepCollectionEquality().hash(_targetMuscles),isCustom,createdAt]);

@override
String toString() {
  return 'SupersetTemplate(id: $id, name: $name, exerciseIds: $exerciseIds, exerciseNames: $exerciseNames, rounds: $rounds, repsRange: $repsRange, restAfterRound: $restAfterRound, restBetween: $restBetween, difficulty: $difficulty, estimatedTimeMinutes: $estimatedTimeMinutes, scientificBasis: $scientificBasis, notes: $notes, tut: $tut, equipmentRequired: $equipmentRequired, equipmentAlternatives: $equipmentAlternatives, targetPersona: $targetPersona, targetMuscles: $targetMuscles, isCustom: $isCustom, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SupersetTemplateCopyWith<$Res> implements $SupersetTemplateCopyWith<$Res> {
  factory _$SupersetTemplateCopyWith(_SupersetTemplate value, $Res Function(_SupersetTemplate) _then) = __$SupersetTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> exerciseIds, List<String> exerciseNames, int rounds, String repsRange, int restAfterRound, int restBetween, TemplateDifficulty difficulty, int estimatedTimeMinutes, String scientificBasis, String? notes, String? tut, List<String>? equipmentRequired, List<String>? equipmentAlternatives, UserPersona? targetPersona, List<String>? targetMuscles, bool isCustom, DateTime? createdAt
});




}
/// @nodoc
class __$SupersetTemplateCopyWithImpl<$Res>
    implements _$SupersetTemplateCopyWith<$Res> {
  __$SupersetTemplateCopyWithImpl(this._self, this._then);

  final _SupersetTemplate _self;
  final $Res Function(_SupersetTemplate) _then;

/// Create a copy of SupersetTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? exerciseIds = null,Object? exerciseNames = null,Object? rounds = null,Object? repsRange = null,Object? restAfterRound = null,Object? restBetween = null,Object? difficulty = null,Object? estimatedTimeMinutes = null,Object? scientificBasis = null,Object? notes = freezed,Object? tut = freezed,Object? equipmentRequired = freezed,Object? equipmentAlternatives = freezed,Object? targetPersona = freezed,Object? targetMuscles = freezed,Object? isCustom = null,Object? createdAt = freezed,}) {
  return _then(_SupersetTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exerciseIds: null == exerciseIds ? _self._exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,exerciseNames: null == exerciseNames ? _self._exerciseNames : exerciseNames // ignore: cast_nullable_to_non_nullable
as List<String>,rounds: null == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int,repsRange: null == repsRange ? _self.repsRange : repsRange // ignore: cast_nullable_to_non_nullable
as String,restAfterRound: null == restAfterRound ? _self.restAfterRound : restAfterRound // ignore: cast_nullable_to_non_nullable
as int,restBetween: null == restBetween ? _self.restBetween : restBetween // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as TemplateDifficulty,estimatedTimeMinutes: null == estimatedTimeMinutes ? _self.estimatedTimeMinutes : estimatedTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,scientificBasis: null == scientificBasis ? _self.scientificBasis : scientificBasis // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tut: freezed == tut ? _self.tut : tut // ignore: cast_nullable_to_non_nullable
as String?,equipmentRequired: freezed == equipmentRequired ? _self._equipmentRequired : equipmentRequired // ignore: cast_nullable_to_non_nullable
as List<String>?,equipmentAlternatives: freezed == equipmentAlternatives ? _self._equipmentAlternatives : equipmentAlternatives // ignore: cast_nullable_to_non_nullable
as List<String>?,targetPersona: freezed == targetPersona ? _self.targetPersona : targetPersona // ignore: cast_nullable_to_non_nullable
as UserPersona?,targetMuscles: freezed == targetMuscles ? _self._targetMuscles : targetMuscles // ignore: cast_nullable_to_non_nullable
as List<String>?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
