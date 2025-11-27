// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribution_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContributionFilters {

 List<String> get exerciseIds; String? get type;// correction, tip, warning, variant, translation, technique
 String? get difficulty;// beginner, intermediate, advanced
 String? get authorTier;// community, expert, admin
 DateTime? get dateFrom; DateTime? get dateTo; String get sortBy;
/// Create a copy of ContributionFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionFiltersCopyWith<ContributionFilters> get copyWith => _$ContributionFiltersCopyWithImpl<ContributionFilters>(this as ContributionFilters, _$identity);

  /// Serializes this ContributionFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionFilters&&const DeepCollectionEquality().equals(other.exerciseIds, exerciseIds)&&(identical(other.type, type) || other.type == type)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.authorTier, authorTier) || other.authorTier == authorTier)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(exerciseIds),type,difficulty,authorTier,dateFrom,dateTo,sortBy);

@override
String toString() {
  return 'ContributionFilters(exerciseIds: $exerciseIds, type: $type, difficulty: $difficulty, authorTier: $authorTier, dateFrom: $dateFrom, dateTo: $dateTo, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class $ContributionFiltersCopyWith<$Res>  {
  factory $ContributionFiltersCopyWith(ContributionFilters value, $Res Function(ContributionFilters) _then) = _$ContributionFiltersCopyWithImpl;
@useResult
$Res call({
 List<String> exerciseIds, String? type, String? difficulty, String? authorTier, DateTime? dateFrom, DateTime? dateTo, String sortBy
});




}
/// @nodoc
class _$ContributionFiltersCopyWithImpl<$Res>
    implements $ContributionFiltersCopyWith<$Res> {
  _$ContributionFiltersCopyWithImpl(this._self, this._then);

  final ContributionFilters _self;
  final $Res Function(ContributionFilters) _then;

/// Create a copy of ContributionFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseIds = null,Object? type = freezed,Object? difficulty = freezed,Object? authorTier = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? sortBy = null,}) {
  return _then(_self.copyWith(
exerciseIds: null == exerciseIds ? _self.exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,authorTier: freezed == authorTier ? _self.authorTier : authorTier // ignore: cast_nullable_to_non_nullable
as String?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributionFilters].
extension ContributionFiltersPatterns on ContributionFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionFilters value)  $default,){
final _that = this;
switch (_that) {
case _ContributionFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionFilters value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> exerciseIds,  String? type,  String? difficulty,  String? authorTier,  DateTime? dateFrom,  DateTime? dateTo,  String sortBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionFilters() when $default != null:
return $default(_that.exerciseIds,_that.type,_that.difficulty,_that.authorTier,_that.dateFrom,_that.dateTo,_that.sortBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> exerciseIds,  String? type,  String? difficulty,  String? authorTier,  DateTime? dateFrom,  DateTime? dateTo,  String sortBy)  $default,) {final _that = this;
switch (_that) {
case _ContributionFilters():
return $default(_that.exerciseIds,_that.type,_that.difficulty,_that.authorTier,_that.dateFrom,_that.dateTo,_that.sortBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> exerciseIds,  String? type,  String? difficulty,  String? authorTier,  DateTime? dateFrom,  DateTime? dateTo,  String sortBy)?  $default,) {final _that = this;
switch (_that) {
case _ContributionFilters() when $default != null:
return $default(_that.exerciseIds,_that.type,_that.difficulty,_that.authorTier,_that.dateFrom,_that.dateTo,_that.sortBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionFilters implements ContributionFilters {
  const _ContributionFilters({final  List<String> exerciseIds = const [], this.type, this.difficulty, this.authorTier, this.dateFrom, this.dateTo, this.sortBy = 'helpful'}): _exerciseIds = exerciseIds;
  factory _ContributionFilters.fromJson(Map<String, dynamic> json) => _$ContributionFiltersFromJson(json);

 final  List<String> _exerciseIds;
@override@JsonKey() List<String> get exerciseIds {
  if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseIds);
}

@override final  String? type;
// correction, tip, warning, variant, translation, technique
@override final  String? difficulty;
// beginner, intermediate, advanced
@override final  String? authorTier;
// community, expert, admin
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
@override@JsonKey() final  String sortBy;

/// Create a copy of ContributionFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionFiltersCopyWith<_ContributionFilters> get copyWith => __$ContributionFiltersCopyWithImpl<_ContributionFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionFilters&&const DeepCollectionEquality().equals(other._exerciseIds, _exerciseIds)&&(identical(other.type, type) || other.type == type)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.authorTier, authorTier) || other.authorTier == authorTier)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_exerciseIds),type,difficulty,authorTier,dateFrom,dateTo,sortBy);

@override
String toString() {
  return 'ContributionFilters(exerciseIds: $exerciseIds, type: $type, difficulty: $difficulty, authorTier: $authorTier, dateFrom: $dateFrom, dateTo: $dateTo, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class _$ContributionFiltersCopyWith<$Res> implements $ContributionFiltersCopyWith<$Res> {
  factory _$ContributionFiltersCopyWith(_ContributionFilters value, $Res Function(_ContributionFilters) _then) = __$ContributionFiltersCopyWithImpl;
@override @useResult
$Res call({
 List<String> exerciseIds, String? type, String? difficulty, String? authorTier, DateTime? dateFrom, DateTime? dateTo, String sortBy
});




}
/// @nodoc
class __$ContributionFiltersCopyWithImpl<$Res>
    implements _$ContributionFiltersCopyWith<$Res> {
  __$ContributionFiltersCopyWithImpl(this._self, this._then);

  final _ContributionFilters _self;
  final $Res Function(_ContributionFilters) _then;

/// Create a copy of ContributionFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseIds = null,Object? type = freezed,Object? difficulty = freezed,Object? authorTier = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? sortBy = null,}) {
  return _then(_ContributionFilters(
exerciseIds: null == exerciseIds ? _self._exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,authorTier: freezed == authorTier ? _self.authorTier : authorTier // ignore: cast_nullable_to_non_nullable
as String?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
