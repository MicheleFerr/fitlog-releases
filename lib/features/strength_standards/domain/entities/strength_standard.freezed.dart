// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'strength_standard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StrengthStandard {

/// Unique identifier (e.g., "barbell_bench_press")
 String get id;/// Display name (e.g., "Barbell Bench Press")
 String get name;/// Search keywords for semantic matching (Italian + English)
 List<String> get keywords;/// Equipment type (e.g., "Bilanciere", "Manubri")
 String get equipment;/// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
 List<String> get muscleGroups;/// Data source identifier (e.g., "exrx_net", "estimated_from_benchmarks")
 String get dataSource;/// Bodyweight table: kg → level → 1RM (kg)
/// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
 Map<String, Map<String, double>> get bodyweightTable;/// Bodyweight multipliers: level → multiplier
/// Example: {"novice": 0.93, "intermediate": 1.13}
 Map<String, double> get bodyweightMultipliers;/// Whether this is bodyweight exercise (reps-based instead of weight)
 bool get isBodyweightExercise;
/// Create a copy of StrengthStandard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrengthStandardCopyWith<StrengthStandard> get copyWith => _$StrengthStandardCopyWithImpl<StrengthStandard>(this as StrengthStandard, _$identity);

  /// Serializes this StrengthStandard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrengthStandard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&const DeepCollectionEquality().equals(other.muscleGroups, muscleGroups)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&const DeepCollectionEquality().equals(other.bodyweightTable, bodyweightTable)&&const DeepCollectionEquality().equals(other.bodyweightMultipliers, bodyweightMultipliers)&&(identical(other.isBodyweightExercise, isBodyweightExercise) || other.isBodyweightExercise == isBodyweightExercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(keywords),equipment,const DeepCollectionEquality().hash(muscleGroups),dataSource,const DeepCollectionEquality().hash(bodyweightTable),const DeepCollectionEquality().hash(bodyweightMultipliers),isBodyweightExercise);

@override
String toString() {
  return 'StrengthStandard(id: $id, name: $name, keywords: $keywords, equipment: $equipment, muscleGroups: $muscleGroups, dataSource: $dataSource, bodyweightTable: $bodyweightTable, bodyweightMultipliers: $bodyweightMultipliers, isBodyweightExercise: $isBodyweightExercise)';
}


}

/// @nodoc
abstract mixin class $StrengthStandardCopyWith<$Res>  {
  factory $StrengthStandardCopyWith(StrengthStandard value, $Res Function(StrengthStandard) _then) = _$StrengthStandardCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> keywords, String equipment, List<String> muscleGroups, String dataSource, Map<String, Map<String, double>> bodyweightTable, Map<String, double> bodyweightMultipliers, bool isBodyweightExercise
});




}
/// @nodoc
class _$StrengthStandardCopyWithImpl<$Res>
    implements $StrengthStandardCopyWith<$Res> {
  _$StrengthStandardCopyWithImpl(this._self, this._then);

  final StrengthStandard _self;
  final $Res Function(StrengthStandard) _then;

/// Create a copy of StrengthStandard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? keywords = null,Object? equipment = null,Object? muscleGroups = null,Object? dataSource = null,Object? bodyweightTable = null,Object? bodyweightMultipliers = null,Object? isBodyweightExercise = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,muscleGroups: null == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>,dataSource: null == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String,bodyweightTable: null == bodyweightTable ? _self.bodyweightTable : bodyweightTable // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,bodyweightMultipliers: null == bodyweightMultipliers ? _self.bodyweightMultipliers : bodyweightMultipliers // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isBodyweightExercise: null == isBodyweightExercise ? _self.isBodyweightExercise : isBodyweightExercise // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StrengthStandard].
extension StrengthStandardPatterns on StrengthStandard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StrengthStandard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StrengthStandard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StrengthStandard value)  $default,){
final _that = this;
switch (_that) {
case _StrengthStandard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StrengthStandard value)?  $default,){
final _that = this;
switch (_that) {
case _StrengthStandard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> keywords,  String equipment,  List<String> muscleGroups,  String dataSource,  Map<String, Map<String, double>> bodyweightTable,  Map<String, double> bodyweightMultipliers,  bool isBodyweightExercise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StrengthStandard() when $default != null:
return $default(_that.id,_that.name,_that.keywords,_that.equipment,_that.muscleGroups,_that.dataSource,_that.bodyweightTable,_that.bodyweightMultipliers,_that.isBodyweightExercise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> keywords,  String equipment,  List<String> muscleGroups,  String dataSource,  Map<String, Map<String, double>> bodyweightTable,  Map<String, double> bodyweightMultipliers,  bool isBodyweightExercise)  $default,) {final _that = this;
switch (_that) {
case _StrengthStandard():
return $default(_that.id,_that.name,_that.keywords,_that.equipment,_that.muscleGroups,_that.dataSource,_that.bodyweightTable,_that.bodyweightMultipliers,_that.isBodyweightExercise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> keywords,  String equipment,  List<String> muscleGroups,  String dataSource,  Map<String, Map<String, double>> bodyweightTable,  Map<String, double> bodyweightMultipliers,  bool isBodyweightExercise)?  $default,) {final _that = this;
switch (_that) {
case _StrengthStandard() when $default != null:
return $default(_that.id,_that.name,_that.keywords,_that.equipment,_that.muscleGroups,_that.dataSource,_that.bodyweightTable,_that.bodyweightMultipliers,_that.isBodyweightExercise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StrengthStandard implements StrengthStandard {
  const _StrengthStandard({required this.id, required this.name, required final  List<String> keywords, required this.equipment, required final  List<String> muscleGroups, required this.dataSource, required final  Map<String, Map<String, double>> bodyweightTable, required final  Map<String, double> bodyweightMultipliers, this.isBodyweightExercise = false}): _keywords = keywords,_muscleGroups = muscleGroups,_bodyweightTable = bodyweightTable,_bodyweightMultipliers = bodyweightMultipliers;
  factory _StrengthStandard.fromJson(Map<String, dynamic> json) => _$StrengthStandardFromJson(json);

/// Unique identifier (e.g., "barbell_bench_press")
@override final  String id;
/// Display name (e.g., "Barbell Bench Press")
@override final  String name;
/// Search keywords for semantic matching (Italian + English)
 final  List<String> _keywords;
/// Search keywords for semantic matching (Italian + English)
@override List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

/// Equipment type (e.g., "Bilanciere", "Manubri")
@override final  String equipment;
/// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
 final  List<String> _muscleGroups;
/// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
@override List<String> get muscleGroups {
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleGroups);
}

/// Data source identifier (e.g., "exrx_net", "estimated_from_benchmarks")
@override final  String dataSource;
/// Bodyweight table: kg → level → 1RM (kg)
/// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
 final  Map<String, Map<String, double>> _bodyweightTable;
/// Bodyweight table: kg → level → 1RM (kg)
/// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
@override Map<String, Map<String, double>> get bodyweightTable {
  if (_bodyweightTable is EqualUnmodifiableMapView) return _bodyweightTable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodyweightTable);
}

/// Bodyweight multipliers: level → multiplier
/// Example: {"novice": 0.93, "intermediate": 1.13}
 final  Map<String, double> _bodyweightMultipliers;
/// Bodyweight multipliers: level → multiplier
/// Example: {"novice": 0.93, "intermediate": 1.13}
@override Map<String, double> get bodyweightMultipliers {
  if (_bodyweightMultipliers is EqualUnmodifiableMapView) return _bodyweightMultipliers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodyweightMultipliers);
}

/// Whether this is bodyweight exercise (reps-based instead of weight)
@override@JsonKey() final  bool isBodyweightExercise;

/// Create a copy of StrengthStandard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StrengthStandardCopyWith<_StrengthStandard> get copyWith => __$StrengthStandardCopyWithImpl<_StrengthStandard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StrengthStandardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StrengthStandard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._keywords, _keywords)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&const DeepCollectionEquality().equals(other._muscleGroups, _muscleGroups)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&const DeepCollectionEquality().equals(other._bodyweightTable, _bodyweightTable)&&const DeepCollectionEquality().equals(other._bodyweightMultipliers, _bodyweightMultipliers)&&(identical(other.isBodyweightExercise, isBodyweightExercise) || other.isBodyweightExercise == isBodyweightExercise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_keywords),equipment,const DeepCollectionEquality().hash(_muscleGroups),dataSource,const DeepCollectionEquality().hash(_bodyweightTable),const DeepCollectionEquality().hash(_bodyweightMultipliers),isBodyweightExercise);

@override
String toString() {
  return 'StrengthStandard(id: $id, name: $name, keywords: $keywords, equipment: $equipment, muscleGroups: $muscleGroups, dataSource: $dataSource, bodyweightTable: $bodyweightTable, bodyweightMultipliers: $bodyweightMultipliers, isBodyweightExercise: $isBodyweightExercise)';
}


}

/// @nodoc
abstract mixin class _$StrengthStandardCopyWith<$Res> implements $StrengthStandardCopyWith<$Res> {
  factory _$StrengthStandardCopyWith(_StrengthStandard value, $Res Function(_StrengthStandard) _then) = __$StrengthStandardCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> keywords, String equipment, List<String> muscleGroups, String dataSource, Map<String, Map<String, double>> bodyweightTable, Map<String, double> bodyweightMultipliers, bool isBodyweightExercise
});




}
/// @nodoc
class __$StrengthStandardCopyWithImpl<$Res>
    implements _$StrengthStandardCopyWith<$Res> {
  __$StrengthStandardCopyWithImpl(this._self, this._then);

  final _StrengthStandard _self;
  final $Res Function(_StrengthStandard) _then;

/// Create a copy of StrengthStandard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? keywords = null,Object? equipment = null,Object? muscleGroups = null,Object? dataSource = null,Object? bodyweightTable = null,Object? bodyweightMultipliers = null,Object? isBodyweightExercise = null,}) {
  return _then(_StrengthStandard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,muscleGroups: null == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>,dataSource: null == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String,bodyweightTable: null == bodyweightTable ? _self._bodyweightTable : bodyweightTable // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, double>>,bodyweightMultipliers: null == bodyweightMultipliers ? _self._bodyweightMultipliers : bodyweightMultipliers // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isBodyweightExercise: null == isBodyweightExercise ? _self.isBodyweightExercise : isBodyweightExercise // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
