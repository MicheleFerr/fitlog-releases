// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AchievementData {

/// Unique achievement identifier
 String get id;/// Display name (localization key)
 String get name;/// Description (localization key)
 String get description;/// Achievement category
 AchievementCategory get category;/// Rarity level
 AchievementRarity get rarity;/// Unlock condition description (localization key)
 String get conditionDescription;/// Icon identifier (maps to IconData)
 String get iconKey;/// Reward message shown on unlock (localization key)
 String get rewardMessage;/// Unlock timestamp (null if locked)
 DateTime? get unlockedAt;/// Progress towards unlock (0.0 - 1.0)
 double get progress;/// Whether achievement is hidden until unlocked
 bool get isHidden;/// Sort order for display
 int get sortOrder;
/// Create a copy of AchievementData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementDataCopyWith<AchievementData> get copyWith => _$AchievementDataCopyWithImpl<AchievementData>(this as AchievementData, _$identity);

  /// Serializes this AchievementData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.conditionDescription, conditionDescription) || other.conditionDescription == conditionDescription)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.rewardMessage, rewardMessage) || other.rewardMessage == rewardMessage)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,rarity,conditionDescription,iconKey,rewardMessage,unlockedAt,progress,isHidden,sortOrder);

@override
String toString() {
  return 'AchievementData(id: $id, name: $name, description: $description, category: $category, rarity: $rarity, conditionDescription: $conditionDescription, iconKey: $iconKey, rewardMessage: $rewardMessage, unlockedAt: $unlockedAt, progress: $progress, isHidden: $isHidden, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $AchievementDataCopyWith<$Res>  {
  factory $AchievementDataCopyWith(AchievementData value, $Res Function(AchievementData) _then) = _$AchievementDataCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, AchievementCategory category, AchievementRarity rarity, String conditionDescription, String iconKey, String rewardMessage, DateTime? unlockedAt, double progress, bool isHidden, int sortOrder
});




}
/// @nodoc
class _$AchievementDataCopyWithImpl<$Res>
    implements $AchievementDataCopyWith<$Res> {
  _$AchievementDataCopyWithImpl(this._self, this._then);

  final AchievementData _self;
  final $Res Function(AchievementData) _then;

/// Create a copy of AchievementData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? category = null,Object? rarity = null,Object? conditionDescription = null,Object? iconKey = null,Object? rewardMessage = null,Object? unlockedAt = freezed,Object? progress = null,Object? isHidden = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,conditionDescription: null == conditionDescription ? _self.conditionDescription : conditionDescription // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,rewardMessage: null == rewardMessage ? _self.rewardMessage : rewardMessage // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AchievementData].
extension AchievementDataPatterns on AchievementData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementData value)  $default,){
final _that = this;
switch (_that) {
case _AchievementData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementData value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  AchievementCategory category,  AchievementRarity rarity,  String conditionDescription,  String iconKey,  String rewardMessage,  DateTime? unlockedAt,  double progress,  bool isHidden,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementData() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.rarity,_that.conditionDescription,_that.iconKey,_that.rewardMessage,_that.unlockedAt,_that.progress,_that.isHidden,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  AchievementCategory category,  AchievementRarity rarity,  String conditionDescription,  String iconKey,  String rewardMessage,  DateTime? unlockedAt,  double progress,  bool isHidden,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _AchievementData():
return $default(_that.id,_that.name,_that.description,_that.category,_that.rarity,_that.conditionDescription,_that.iconKey,_that.rewardMessage,_that.unlockedAt,_that.progress,_that.isHidden,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  AchievementCategory category,  AchievementRarity rarity,  String conditionDescription,  String iconKey,  String rewardMessage,  DateTime? unlockedAt,  double progress,  bool isHidden,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _AchievementData() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.rarity,_that.conditionDescription,_that.iconKey,_that.rewardMessage,_that.unlockedAt,_that.progress,_that.isHidden,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AchievementData implements AchievementData {
  const _AchievementData({required this.id, required this.name, required this.description, required this.category, required this.rarity, required this.conditionDescription, required this.iconKey, required this.rewardMessage, this.unlockedAt, this.progress = 0.0, this.isHidden = false, this.sortOrder = 0});
  factory _AchievementData.fromJson(Map<String, dynamic> json) => _$AchievementDataFromJson(json);

/// Unique achievement identifier
@override final  String id;
/// Display name (localization key)
@override final  String name;
/// Description (localization key)
@override final  String description;
/// Achievement category
@override final  AchievementCategory category;
/// Rarity level
@override final  AchievementRarity rarity;
/// Unlock condition description (localization key)
@override final  String conditionDescription;
/// Icon identifier (maps to IconData)
@override final  String iconKey;
/// Reward message shown on unlock (localization key)
@override final  String rewardMessage;
/// Unlock timestamp (null if locked)
@override final  DateTime? unlockedAt;
/// Progress towards unlock (0.0 - 1.0)
@override@JsonKey() final  double progress;
/// Whether achievement is hidden until unlocked
@override@JsonKey() final  bool isHidden;
/// Sort order for display
@override@JsonKey() final  int sortOrder;

/// Create a copy of AchievementData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementDataCopyWith<_AchievementData> get copyWith => __$AchievementDataCopyWithImpl<_AchievementData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.conditionDescription, conditionDescription) || other.conditionDescription == conditionDescription)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.rewardMessage, rewardMessage) || other.rewardMessage == rewardMessage)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,rarity,conditionDescription,iconKey,rewardMessage,unlockedAt,progress,isHidden,sortOrder);

@override
String toString() {
  return 'AchievementData(id: $id, name: $name, description: $description, category: $category, rarity: $rarity, conditionDescription: $conditionDescription, iconKey: $iconKey, rewardMessage: $rewardMessage, unlockedAt: $unlockedAt, progress: $progress, isHidden: $isHidden, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$AchievementDataCopyWith<$Res> implements $AchievementDataCopyWith<$Res> {
  factory _$AchievementDataCopyWith(_AchievementData value, $Res Function(_AchievementData) _then) = __$AchievementDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, AchievementCategory category, AchievementRarity rarity, String conditionDescription, String iconKey, String rewardMessage, DateTime? unlockedAt, double progress, bool isHidden, int sortOrder
});




}
/// @nodoc
class __$AchievementDataCopyWithImpl<$Res>
    implements _$AchievementDataCopyWith<$Res> {
  __$AchievementDataCopyWithImpl(this._self, this._then);

  final _AchievementData _self;
  final $Res Function(_AchievementData) _then;

/// Create a copy of AchievementData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? category = null,Object? rarity = null,Object? conditionDescription = null,Object? iconKey = null,Object? rewardMessage = null,Object? unlockedAt = freezed,Object? progress = null,Object? isHidden = null,Object? sortOrder = null,}) {
  return _then(_AchievementData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,conditionDescription: null == conditionDescription ? _self.conditionDescription : conditionDescription // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,rewardMessage: null == rewardMessage ? _self.rewardMessage : rewardMessage // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
