// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_tour_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingTourStep {

/// Unique identifier for this step (e.g., 'aiCoach', 'fab', 'analytics')
 String get id;/// Localization key for the title (used in bottom sheet header)
 String get titleKey;/// Localization key for the description text
 String get descriptionKey;/// Optional localization keys for bullet points (used for COMPLEX steps)
 List<String> get bulletPointKeys;/// Step complexity type
 TourStepType get type;/// Auto-advance duration (null = user-controlled, only for COMPLEX steps)
 Duration? get autoAdvanceDuration;/// GlobalKey for the widget to spotlight
/// This key should be attached to the target widget in the UI
 String get targetWidgetKey;/// Step position in the tour (0-indexed)
 int get position;/// Total number of steps in the tour
 int get totalSteps;/// Bottom sheet position (bottom or top) - default is bottom
/// Use top for FAB to avoid obscuring it
 BottomSheetPosition get bottomSheetPosition;
/// Create a copy of OnboardingTourStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingTourStepCopyWith<OnboardingTourStep> get copyWith => _$OnboardingTourStepCopyWithImpl<OnboardingTourStep>(this as OnboardingTourStep, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingTourStep&&(identical(other.id, id) || other.id == id)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&const DeepCollectionEquality().equals(other.bulletPointKeys, bulletPointKeys)&&(identical(other.type, type) || other.type == type)&&(identical(other.autoAdvanceDuration, autoAdvanceDuration) || other.autoAdvanceDuration == autoAdvanceDuration)&&(identical(other.targetWidgetKey, targetWidgetKey) || other.targetWidgetKey == targetWidgetKey)&&(identical(other.position, position) || other.position == position)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&(identical(other.bottomSheetPosition, bottomSheetPosition) || other.bottomSheetPosition == bottomSheetPosition));
}


@override
int get hashCode => Object.hash(runtimeType,id,titleKey,descriptionKey,const DeepCollectionEquality().hash(bulletPointKeys),type,autoAdvanceDuration,targetWidgetKey,position,totalSteps,bottomSheetPosition);

@override
String toString() {
  return 'OnboardingTourStep(id: $id, titleKey: $titleKey, descriptionKey: $descriptionKey, bulletPointKeys: $bulletPointKeys, type: $type, autoAdvanceDuration: $autoAdvanceDuration, targetWidgetKey: $targetWidgetKey, position: $position, totalSteps: $totalSteps, bottomSheetPosition: $bottomSheetPosition)';
}


}

/// @nodoc
abstract mixin class $OnboardingTourStepCopyWith<$Res>  {
  factory $OnboardingTourStepCopyWith(OnboardingTourStep value, $Res Function(OnboardingTourStep) _then) = _$OnboardingTourStepCopyWithImpl;
@useResult
$Res call({
 String id, String titleKey, String descriptionKey, List<String> bulletPointKeys, TourStepType type, Duration? autoAdvanceDuration, String targetWidgetKey, int position, int totalSteps, BottomSheetPosition bottomSheetPosition
});




}
/// @nodoc
class _$OnboardingTourStepCopyWithImpl<$Res>
    implements $OnboardingTourStepCopyWith<$Res> {
  _$OnboardingTourStepCopyWithImpl(this._self, this._then);

  final OnboardingTourStep _self;
  final $Res Function(OnboardingTourStep) _then;

/// Create a copy of OnboardingTourStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleKey = null,Object? descriptionKey = null,Object? bulletPointKeys = null,Object? type = null,Object? autoAdvanceDuration = freezed,Object? targetWidgetKey = null,Object? position = null,Object? totalSteps = null,Object? bottomSheetPosition = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,bulletPointKeys: null == bulletPointKeys ? _self.bulletPointKeys : bulletPointKeys // ignore: cast_nullable_to_non_nullable
as List<String>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TourStepType,autoAdvanceDuration: freezed == autoAdvanceDuration ? _self.autoAdvanceDuration : autoAdvanceDuration // ignore: cast_nullable_to_non_nullable
as Duration?,targetWidgetKey: null == targetWidgetKey ? _self.targetWidgetKey : targetWidgetKey // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,bottomSheetPosition: null == bottomSheetPosition ? _self.bottomSheetPosition : bottomSheetPosition // ignore: cast_nullable_to_non_nullable
as BottomSheetPosition,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingTourStep].
extension OnboardingTourStepPatterns on OnboardingTourStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingTourStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingTourStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingTourStep value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingTourStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingTourStep value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingTourStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titleKey,  String descriptionKey,  List<String> bulletPointKeys,  TourStepType type,  Duration? autoAdvanceDuration,  String targetWidgetKey,  int position,  int totalSteps,  BottomSheetPosition bottomSheetPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingTourStep() when $default != null:
return $default(_that.id,_that.titleKey,_that.descriptionKey,_that.bulletPointKeys,_that.type,_that.autoAdvanceDuration,_that.targetWidgetKey,_that.position,_that.totalSteps,_that.bottomSheetPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titleKey,  String descriptionKey,  List<String> bulletPointKeys,  TourStepType type,  Duration? autoAdvanceDuration,  String targetWidgetKey,  int position,  int totalSteps,  BottomSheetPosition bottomSheetPosition)  $default,) {final _that = this;
switch (_that) {
case _OnboardingTourStep():
return $default(_that.id,_that.titleKey,_that.descriptionKey,_that.bulletPointKeys,_that.type,_that.autoAdvanceDuration,_that.targetWidgetKey,_that.position,_that.totalSteps,_that.bottomSheetPosition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titleKey,  String descriptionKey,  List<String> bulletPointKeys,  TourStepType type,  Duration? autoAdvanceDuration,  String targetWidgetKey,  int position,  int totalSteps,  BottomSheetPosition bottomSheetPosition)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingTourStep() when $default != null:
return $default(_that.id,_that.titleKey,_that.descriptionKey,_that.bulletPointKeys,_that.type,_that.autoAdvanceDuration,_that.targetWidgetKey,_that.position,_that.totalSteps,_that.bottomSheetPosition);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingTourStep extends OnboardingTourStep {
  const _OnboardingTourStep({required this.id, required this.titleKey, required this.descriptionKey, final  List<String> bulletPointKeys = const [], this.type = TourStepType.simple, this.autoAdvanceDuration, required this.targetWidgetKey, required this.position, required this.totalSteps, this.bottomSheetPosition = BottomSheetPosition.bottom}): _bulletPointKeys = bulletPointKeys,super._();
  

/// Unique identifier for this step (e.g., 'aiCoach', 'fab', 'analytics')
@override final  String id;
/// Localization key for the title (used in bottom sheet header)
@override final  String titleKey;
/// Localization key for the description text
@override final  String descriptionKey;
/// Optional localization keys for bullet points (used for COMPLEX steps)
 final  List<String> _bulletPointKeys;
/// Optional localization keys for bullet points (used for COMPLEX steps)
@override@JsonKey() List<String> get bulletPointKeys {
  if (_bulletPointKeys is EqualUnmodifiableListView) return _bulletPointKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bulletPointKeys);
}

/// Step complexity type
@override@JsonKey() final  TourStepType type;
/// Auto-advance duration (null = user-controlled, only for COMPLEX steps)
@override final  Duration? autoAdvanceDuration;
/// GlobalKey for the widget to spotlight
/// This key should be attached to the target widget in the UI
@override final  String targetWidgetKey;
/// Step position in the tour (0-indexed)
@override final  int position;
/// Total number of steps in the tour
@override final  int totalSteps;
/// Bottom sheet position (bottom or top) - default is bottom
/// Use top for FAB to avoid obscuring it
@override@JsonKey() final  BottomSheetPosition bottomSheetPosition;

/// Create a copy of OnboardingTourStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingTourStepCopyWith<_OnboardingTourStep> get copyWith => __$OnboardingTourStepCopyWithImpl<_OnboardingTourStep>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingTourStep&&(identical(other.id, id) || other.id == id)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&const DeepCollectionEquality().equals(other._bulletPointKeys, _bulletPointKeys)&&(identical(other.type, type) || other.type == type)&&(identical(other.autoAdvanceDuration, autoAdvanceDuration) || other.autoAdvanceDuration == autoAdvanceDuration)&&(identical(other.targetWidgetKey, targetWidgetKey) || other.targetWidgetKey == targetWidgetKey)&&(identical(other.position, position) || other.position == position)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&(identical(other.bottomSheetPosition, bottomSheetPosition) || other.bottomSheetPosition == bottomSheetPosition));
}


@override
int get hashCode => Object.hash(runtimeType,id,titleKey,descriptionKey,const DeepCollectionEquality().hash(_bulletPointKeys),type,autoAdvanceDuration,targetWidgetKey,position,totalSteps,bottomSheetPosition);

@override
String toString() {
  return 'OnboardingTourStep(id: $id, titleKey: $titleKey, descriptionKey: $descriptionKey, bulletPointKeys: $bulletPointKeys, type: $type, autoAdvanceDuration: $autoAdvanceDuration, targetWidgetKey: $targetWidgetKey, position: $position, totalSteps: $totalSteps, bottomSheetPosition: $bottomSheetPosition)';
}


}

/// @nodoc
abstract mixin class _$OnboardingTourStepCopyWith<$Res> implements $OnboardingTourStepCopyWith<$Res> {
  factory _$OnboardingTourStepCopyWith(_OnboardingTourStep value, $Res Function(_OnboardingTourStep) _then) = __$OnboardingTourStepCopyWithImpl;
@override @useResult
$Res call({
 String id, String titleKey, String descriptionKey, List<String> bulletPointKeys, TourStepType type, Duration? autoAdvanceDuration, String targetWidgetKey, int position, int totalSteps, BottomSheetPosition bottomSheetPosition
});




}
/// @nodoc
class __$OnboardingTourStepCopyWithImpl<$Res>
    implements _$OnboardingTourStepCopyWith<$Res> {
  __$OnboardingTourStepCopyWithImpl(this._self, this._then);

  final _OnboardingTourStep _self;
  final $Res Function(_OnboardingTourStep) _then;

/// Create a copy of OnboardingTourStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleKey = null,Object? descriptionKey = null,Object? bulletPointKeys = null,Object? type = null,Object? autoAdvanceDuration = freezed,Object? targetWidgetKey = null,Object? position = null,Object? totalSteps = null,Object? bottomSheetPosition = null,}) {
  return _then(_OnboardingTourStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,bulletPointKeys: null == bulletPointKeys ? _self._bulletPointKeys : bulletPointKeys // ignore: cast_nullable_to_non_nullable
as List<String>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TourStepType,autoAdvanceDuration: freezed == autoAdvanceDuration ? _self.autoAdvanceDuration : autoAdvanceDuration // ignore: cast_nullable_to_non_nullable
as Duration?,targetWidgetKey: null == targetWidgetKey ? _self.targetWidgetKey : targetWidgetKey // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,bottomSheetPosition: null == bottomSheetPosition ? _self.bottomSheetPosition : bottomSheetPosition // ignore: cast_nullable_to_non_nullable
as BottomSheetPosition,
  ));
}


}

// dart format on
