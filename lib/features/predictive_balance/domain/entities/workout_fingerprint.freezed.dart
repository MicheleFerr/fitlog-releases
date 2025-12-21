// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_fingerprint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutFingerprint {

/// Unique ID (hash of dominant muscles + category)
 String get id;/// Template name if workout was from a template
 String? get templateName;/// Template ID for navigation
 String? get templateId;/// Top 3 muscles by volume contribution
 List<String> get dominantMuscles;/// Inferred category based on muscle composition
 WorkoutCategory get category;/// Total volume (sets × reps × weight) for ranking
 double get totalVolume;/// Original workout date (for debugging)
 DateTime? get workoutDate;
/// Create a copy of WorkoutFingerprint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutFingerprintCopyWith<WorkoutFingerprint> get copyWith => _$WorkoutFingerprintCopyWithImpl<WorkoutFingerprint>(this as WorkoutFingerprint, _$identity);

  /// Serializes this WorkoutFingerprint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutFingerprint&&(identical(other.id, id) || other.id == id)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&const DeepCollectionEquality().equals(other.dominantMuscles, dominantMuscles)&&(identical(other.category, category) || other.category == category)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&(identical(other.workoutDate, workoutDate) || other.workoutDate == workoutDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateName,templateId,const DeepCollectionEquality().hash(dominantMuscles),category,totalVolume,workoutDate);

@override
String toString() {
  return 'WorkoutFingerprint(id: $id, templateName: $templateName, templateId: $templateId, dominantMuscles: $dominantMuscles, category: $category, totalVolume: $totalVolume, workoutDate: $workoutDate)';
}


}

/// @nodoc
abstract mixin class $WorkoutFingerprintCopyWith<$Res>  {
  factory $WorkoutFingerprintCopyWith(WorkoutFingerprint value, $Res Function(WorkoutFingerprint) _then) = _$WorkoutFingerprintCopyWithImpl;
@useResult
$Res call({
 String id, String? templateName, String? templateId, List<String> dominantMuscles, WorkoutCategory category, double totalVolume, DateTime? workoutDate
});




}
/// @nodoc
class _$WorkoutFingerprintCopyWithImpl<$Res>
    implements $WorkoutFingerprintCopyWith<$Res> {
  _$WorkoutFingerprintCopyWithImpl(this._self, this._then);

  final WorkoutFingerprint _self;
  final $Res Function(WorkoutFingerprint) _then;

/// Create a copy of WorkoutFingerprint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? templateName = freezed,Object? templateId = freezed,Object? dominantMuscles = null,Object? category = null,Object? totalVolume = null,Object? workoutDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,dominantMuscles: null == dominantMuscles ? _self.dominantMuscles : dominantMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as WorkoutCategory,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,workoutDate: freezed == workoutDate ? _self.workoutDate : workoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutFingerprint].
extension WorkoutFingerprintPatterns on WorkoutFingerprint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutFingerprint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutFingerprint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutFingerprint value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutFingerprint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutFingerprint value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutFingerprint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? templateName,  String? templateId,  List<String> dominantMuscles,  WorkoutCategory category,  double totalVolume,  DateTime? workoutDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutFingerprint() when $default != null:
return $default(_that.id,_that.templateName,_that.templateId,_that.dominantMuscles,_that.category,_that.totalVolume,_that.workoutDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? templateName,  String? templateId,  List<String> dominantMuscles,  WorkoutCategory category,  double totalVolume,  DateTime? workoutDate)  $default,) {final _that = this;
switch (_that) {
case _WorkoutFingerprint():
return $default(_that.id,_that.templateName,_that.templateId,_that.dominantMuscles,_that.category,_that.totalVolume,_that.workoutDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? templateName,  String? templateId,  List<String> dominantMuscles,  WorkoutCategory category,  double totalVolume,  DateTime? workoutDate)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutFingerprint() when $default != null:
return $default(_that.id,_that.templateName,_that.templateId,_that.dominantMuscles,_that.category,_that.totalVolume,_that.workoutDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutFingerprint extends WorkoutFingerprint {
  const _WorkoutFingerprint({required this.id, this.templateName, this.templateId, required final  List<String> dominantMuscles, required this.category, required this.totalVolume, this.workoutDate}): _dominantMuscles = dominantMuscles,super._();
  factory _WorkoutFingerprint.fromJson(Map<String, dynamic> json) => _$WorkoutFingerprintFromJson(json);

/// Unique ID (hash of dominant muscles + category)
@override final  String id;
/// Template name if workout was from a template
@override final  String? templateName;
/// Template ID for navigation
@override final  String? templateId;
/// Top 3 muscles by volume contribution
 final  List<String> _dominantMuscles;
/// Top 3 muscles by volume contribution
@override List<String> get dominantMuscles {
  if (_dominantMuscles is EqualUnmodifiableListView) return _dominantMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dominantMuscles);
}

/// Inferred category based on muscle composition
@override final  WorkoutCategory category;
/// Total volume (sets × reps × weight) for ranking
@override final  double totalVolume;
/// Original workout date (for debugging)
@override final  DateTime? workoutDate;

/// Create a copy of WorkoutFingerprint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutFingerprintCopyWith<_WorkoutFingerprint> get copyWith => __$WorkoutFingerprintCopyWithImpl<_WorkoutFingerprint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutFingerprintToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutFingerprint&&(identical(other.id, id) || other.id == id)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&const DeepCollectionEquality().equals(other._dominantMuscles, _dominantMuscles)&&(identical(other.category, category) || other.category == category)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&(identical(other.workoutDate, workoutDate) || other.workoutDate == workoutDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateName,templateId,const DeepCollectionEquality().hash(_dominantMuscles),category,totalVolume,workoutDate);

@override
String toString() {
  return 'WorkoutFingerprint(id: $id, templateName: $templateName, templateId: $templateId, dominantMuscles: $dominantMuscles, category: $category, totalVolume: $totalVolume, workoutDate: $workoutDate)';
}


}

/// @nodoc
abstract mixin class _$WorkoutFingerprintCopyWith<$Res> implements $WorkoutFingerprintCopyWith<$Res> {
  factory _$WorkoutFingerprintCopyWith(_WorkoutFingerprint value, $Res Function(_WorkoutFingerprint) _then) = __$WorkoutFingerprintCopyWithImpl;
@override @useResult
$Res call({
 String id, String? templateName, String? templateId, List<String> dominantMuscles, WorkoutCategory category, double totalVolume, DateTime? workoutDate
});




}
/// @nodoc
class __$WorkoutFingerprintCopyWithImpl<$Res>
    implements _$WorkoutFingerprintCopyWith<$Res> {
  __$WorkoutFingerprintCopyWithImpl(this._self, this._then);

  final _WorkoutFingerprint _self;
  final $Res Function(_WorkoutFingerprint) _then;

/// Create a copy of WorkoutFingerprint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? templateName = freezed,Object? templateId = freezed,Object? dominantMuscles = null,Object? category = null,Object? totalVolume = null,Object? workoutDate = freezed,}) {
  return _then(_WorkoutFingerprint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateName: freezed == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,dominantMuscles: null == dominantMuscles ? _self._dominantMuscles : dominantMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as WorkoutCategory,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,workoutDate: freezed == workoutDate ? _self.workoutDate : workoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
