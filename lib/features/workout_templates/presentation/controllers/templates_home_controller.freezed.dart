// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'templates_home_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplatesHomeState {

 bool get isGridView; bool get isMetricsMinimized; bool get isSaving; bool get isSupersetsExpanded; bool get isDropsetsExpanded; bool get isRestPauseExpanded; String? get selectedCategory; int get discoverSubTabIndex;
/// Create a copy of TemplatesHomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplatesHomeStateCopyWith<TemplatesHomeState> get copyWith => _$TemplatesHomeStateCopyWithImpl<TemplatesHomeState>(this as TemplatesHomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplatesHomeState&&(identical(other.isGridView, isGridView) || other.isGridView == isGridView)&&(identical(other.isMetricsMinimized, isMetricsMinimized) || other.isMetricsMinimized == isMetricsMinimized)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSupersetsExpanded, isSupersetsExpanded) || other.isSupersetsExpanded == isSupersetsExpanded)&&(identical(other.isDropsetsExpanded, isDropsetsExpanded) || other.isDropsetsExpanded == isDropsetsExpanded)&&(identical(other.isRestPauseExpanded, isRestPauseExpanded) || other.isRestPauseExpanded == isRestPauseExpanded)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.discoverSubTabIndex, discoverSubTabIndex) || other.discoverSubTabIndex == discoverSubTabIndex));
}


@override
int get hashCode => Object.hash(runtimeType,isGridView,isMetricsMinimized,isSaving,isSupersetsExpanded,isDropsetsExpanded,isRestPauseExpanded,selectedCategory,discoverSubTabIndex);

@override
String toString() {
  return 'TemplatesHomeState(isGridView: $isGridView, isMetricsMinimized: $isMetricsMinimized, isSaving: $isSaving, isSupersetsExpanded: $isSupersetsExpanded, isDropsetsExpanded: $isDropsetsExpanded, isRestPauseExpanded: $isRestPauseExpanded, selectedCategory: $selectedCategory, discoverSubTabIndex: $discoverSubTabIndex)';
}


}

/// @nodoc
abstract mixin class $TemplatesHomeStateCopyWith<$Res>  {
  factory $TemplatesHomeStateCopyWith(TemplatesHomeState value, $Res Function(TemplatesHomeState) _then) = _$TemplatesHomeStateCopyWithImpl;
@useResult
$Res call({
 bool isGridView, bool isMetricsMinimized, bool isSaving, bool isSupersetsExpanded, bool isDropsetsExpanded, bool isRestPauseExpanded, String? selectedCategory, int discoverSubTabIndex
});




}
/// @nodoc
class _$TemplatesHomeStateCopyWithImpl<$Res>
    implements $TemplatesHomeStateCopyWith<$Res> {
  _$TemplatesHomeStateCopyWithImpl(this._self, this._then);

  final TemplatesHomeState _self;
  final $Res Function(TemplatesHomeState) _then;

/// Create a copy of TemplatesHomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isGridView = null,Object? isMetricsMinimized = null,Object? isSaving = null,Object? isSupersetsExpanded = null,Object? isDropsetsExpanded = null,Object? isRestPauseExpanded = null,Object? selectedCategory = freezed,Object? discoverSubTabIndex = null,}) {
  return _then(_self.copyWith(
isGridView: null == isGridView ? _self.isGridView : isGridView // ignore: cast_nullable_to_non_nullable
as bool,isMetricsMinimized: null == isMetricsMinimized ? _self.isMetricsMinimized : isMetricsMinimized // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSupersetsExpanded: null == isSupersetsExpanded ? _self.isSupersetsExpanded : isSupersetsExpanded // ignore: cast_nullable_to_non_nullable
as bool,isDropsetsExpanded: null == isDropsetsExpanded ? _self.isDropsetsExpanded : isDropsetsExpanded // ignore: cast_nullable_to_non_nullable
as bool,isRestPauseExpanded: null == isRestPauseExpanded ? _self.isRestPauseExpanded : isRestPauseExpanded // ignore: cast_nullable_to_non_nullable
as bool,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String?,discoverSubTabIndex: null == discoverSubTabIndex ? _self.discoverSubTabIndex : discoverSubTabIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplatesHomeState].
extension TemplatesHomeStatePatterns on TemplatesHomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplatesHomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplatesHomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplatesHomeState value)  $default,){
final _that = this;
switch (_that) {
case _TemplatesHomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplatesHomeState value)?  $default,){
final _that = this;
switch (_that) {
case _TemplatesHomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isGridView,  bool isMetricsMinimized,  bool isSaving,  bool isSupersetsExpanded,  bool isDropsetsExpanded,  bool isRestPauseExpanded,  String? selectedCategory,  int discoverSubTabIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplatesHomeState() when $default != null:
return $default(_that.isGridView,_that.isMetricsMinimized,_that.isSaving,_that.isSupersetsExpanded,_that.isDropsetsExpanded,_that.isRestPauseExpanded,_that.selectedCategory,_that.discoverSubTabIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isGridView,  bool isMetricsMinimized,  bool isSaving,  bool isSupersetsExpanded,  bool isDropsetsExpanded,  bool isRestPauseExpanded,  String? selectedCategory,  int discoverSubTabIndex)  $default,) {final _that = this;
switch (_that) {
case _TemplatesHomeState():
return $default(_that.isGridView,_that.isMetricsMinimized,_that.isSaving,_that.isSupersetsExpanded,_that.isDropsetsExpanded,_that.isRestPauseExpanded,_that.selectedCategory,_that.discoverSubTabIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isGridView,  bool isMetricsMinimized,  bool isSaving,  bool isSupersetsExpanded,  bool isDropsetsExpanded,  bool isRestPauseExpanded,  String? selectedCategory,  int discoverSubTabIndex)?  $default,) {final _that = this;
switch (_that) {
case _TemplatesHomeState() when $default != null:
return $default(_that.isGridView,_that.isMetricsMinimized,_that.isSaving,_that.isSupersetsExpanded,_that.isDropsetsExpanded,_that.isRestPauseExpanded,_that.selectedCategory,_that.discoverSubTabIndex);case _:
  return null;

}
}

}

/// @nodoc


class _TemplatesHomeState implements TemplatesHomeState {
  const _TemplatesHomeState({this.isGridView = true, this.isMetricsMinimized = false, this.isSaving = false, this.isSupersetsExpanded = false, this.isDropsetsExpanded = false, this.isRestPauseExpanded = false, this.selectedCategory = null, this.discoverSubTabIndex = 0});
  

@override@JsonKey() final  bool isGridView;
@override@JsonKey() final  bool isMetricsMinimized;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isSupersetsExpanded;
@override@JsonKey() final  bool isDropsetsExpanded;
@override@JsonKey() final  bool isRestPauseExpanded;
@override@JsonKey() final  String? selectedCategory;
@override@JsonKey() final  int discoverSubTabIndex;

/// Create a copy of TemplatesHomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplatesHomeStateCopyWith<_TemplatesHomeState> get copyWith => __$TemplatesHomeStateCopyWithImpl<_TemplatesHomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplatesHomeState&&(identical(other.isGridView, isGridView) || other.isGridView == isGridView)&&(identical(other.isMetricsMinimized, isMetricsMinimized) || other.isMetricsMinimized == isMetricsMinimized)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isSupersetsExpanded, isSupersetsExpanded) || other.isSupersetsExpanded == isSupersetsExpanded)&&(identical(other.isDropsetsExpanded, isDropsetsExpanded) || other.isDropsetsExpanded == isDropsetsExpanded)&&(identical(other.isRestPauseExpanded, isRestPauseExpanded) || other.isRestPauseExpanded == isRestPauseExpanded)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.discoverSubTabIndex, discoverSubTabIndex) || other.discoverSubTabIndex == discoverSubTabIndex));
}


@override
int get hashCode => Object.hash(runtimeType,isGridView,isMetricsMinimized,isSaving,isSupersetsExpanded,isDropsetsExpanded,isRestPauseExpanded,selectedCategory,discoverSubTabIndex);

@override
String toString() {
  return 'TemplatesHomeState(isGridView: $isGridView, isMetricsMinimized: $isMetricsMinimized, isSaving: $isSaving, isSupersetsExpanded: $isSupersetsExpanded, isDropsetsExpanded: $isDropsetsExpanded, isRestPauseExpanded: $isRestPauseExpanded, selectedCategory: $selectedCategory, discoverSubTabIndex: $discoverSubTabIndex)';
}


}

/// @nodoc
abstract mixin class _$TemplatesHomeStateCopyWith<$Res> implements $TemplatesHomeStateCopyWith<$Res> {
  factory _$TemplatesHomeStateCopyWith(_TemplatesHomeState value, $Res Function(_TemplatesHomeState) _then) = __$TemplatesHomeStateCopyWithImpl;
@override @useResult
$Res call({
 bool isGridView, bool isMetricsMinimized, bool isSaving, bool isSupersetsExpanded, bool isDropsetsExpanded, bool isRestPauseExpanded, String? selectedCategory, int discoverSubTabIndex
});




}
/// @nodoc
class __$TemplatesHomeStateCopyWithImpl<$Res>
    implements _$TemplatesHomeStateCopyWith<$Res> {
  __$TemplatesHomeStateCopyWithImpl(this._self, this._then);

  final _TemplatesHomeState _self;
  final $Res Function(_TemplatesHomeState) _then;

/// Create a copy of TemplatesHomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isGridView = null,Object? isMetricsMinimized = null,Object? isSaving = null,Object? isSupersetsExpanded = null,Object? isDropsetsExpanded = null,Object? isRestPauseExpanded = null,Object? selectedCategory = freezed,Object? discoverSubTabIndex = null,}) {
  return _then(_TemplatesHomeState(
isGridView: null == isGridView ? _self.isGridView : isGridView // ignore: cast_nullable_to_non_nullable
as bool,isMetricsMinimized: null == isMetricsMinimized ? _self.isMetricsMinimized : isMetricsMinimized // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isSupersetsExpanded: null == isSupersetsExpanded ? _self.isSupersetsExpanded : isSupersetsExpanded // ignore: cast_nullable_to_non_nullable
as bool,isDropsetsExpanded: null == isDropsetsExpanded ? _self.isDropsetsExpanded : isDropsetsExpanded // ignore: cast_nullable_to_non_nullable
as bool,isRestPauseExpanded: null == isRestPauseExpanded ? _self.isRestPauseExpanded : isRestPauseExpanded // ignore: cast_nullable_to_non_nullable
as bool,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as String?,discoverSubTabIndex: null == discoverSubTabIndex ? _self.discoverSubTabIndex : discoverSubTabIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
