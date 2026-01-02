// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateFolder {

/// Unique folder ID
 String get id;/// Owner user ID (coach)
 String get userId;/// Folder name
 String get name;/// Parent folder ID (null for root folders)
 String? get parentId;/// Folder color (hex string, e.g., 'FF5733')
 String? get color;/// Folder icon
 FolderIcon get icon;/// Sort order within parent
 int get sortOrder;/// Nested depth level (0 = root, max = kMaxFolderDepth - 1)
 int get depth;/// Creation timestamp
 DateTime get createdAt;/// Last update timestamp
 DateTime? get updatedAt;/// Number of templates in this folder (denormalized for UI)
 int get templateCount;/// Description/notes for the folder
 String? get description;
/// Create a copy of TemplateFolder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateFolderCopyWith<TemplateFolder> get copyWith => _$TemplateFolderCopyWithImpl<TemplateFolder>(this as TemplateFolder, _$identity);

  /// Serializes this TemplateFolder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.templateCount, templateCount) || other.templateCount == templateCount)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,parentId,color,icon,sortOrder,depth,createdAt,updatedAt,templateCount,description);

@override
String toString() {
  return 'TemplateFolder(id: $id, userId: $userId, name: $name, parentId: $parentId, color: $color, icon: $icon, sortOrder: $sortOrder, depth: $depth, createdAt: $createdAt, updatedAt: $updatedAt, templateCount: $templateCount, description: $description)';
}


}

/// @nodoc
abstract mixin class $TemplateFolderCopyWith<$Res>  {
  factory $TemplateFolderCopyWith(TemplateFolder value, $Res Function(TemplateFolder) _then) = _$TemplateFolderCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? parentId, String? color, FolderIcon icon, int sortOrder, int depth, DateTime createdAt, DateTime? updatedAt, int templateCount, String? description
});




}
/// @nodoc
class _$TemplateFolderCopyWithImpl<$Res>
    implements $TemplateFolderCopyWith<$Res> {
  _$TemplateFolderCopyWithImpl(this._self, this._then);

  final TemplateFolder _self;
  final $Res Function(TemplateFolder) _then;

/// Create a copy of TemplateFolder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? parentId = freezed,Object? color = freezed,Object? icon = null,Object? sortOrder = null,Object? depth = null,Object? createdAt = null,Object? updatedAt = freezed,Object? templateCount = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as FolderIcon,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,templateCount: null == templateCount ? _self.templateCount : templateCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateFolder].
extension TemplateFolderPatterns on TemplateFolder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateFolder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateFolder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateFolder value)  $default,){
final _that = this;
switch (_that) {
case _TemplateFolder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateFolder value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateFolder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? parentId,  String? color,  FolderIcon icon,  int sortOrder,  int depth,  DateTime createdAt,  DateTime? updatedAt,  int templateCount,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateFolder() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.parentId,_that.color,_that.icon,_that.sortOrder,_that.depth,_that.createdAt,_that.updatedAt,_that.templateCount,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? parentId,  String? color,  FolderIcon icon,  int sortOrder,  int depth,  DateTime createdAt,  DateTime? updatedAt,  int templateCount,  String? description)  $default,) {final _that = this;
switch (_that) {
case _TemplateFolder():
return $default(_that.id,_that.userId,_that.name,_that.parentId,_that.color,_that.icon,_that.sortOrder,_that.depth,_that.createdAt,_that.updatedAt,_that.templateCount,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? parentId,  String? color,  FolderIcon icon,  int sortOrder,  int depth,  DateTime createdAt,  DateTime? updatedAt,  int templateCount,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _TemplateFolder() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.parentId,_that.color,_that.icon,_that.sortOrder,_that.depth,_that.createdAt,_that.updatedAt,_that.templateCount,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateFolder implements TemplateFolder {
  const _TemplateFolder({required this.id, required this.userId, required this.name, this.parentId, this.color, this.icon = FolderIcon.folder, this.sortOrder = 0, this.depth = 0, required this.createdAt, this.updatedAt, this.templateCount = 0, this.description});
  factory _TemplateFolder.fromJson(Map<String, dynamic> json) => _$TemplateFolderFromJson(json);

/// Unique folder ID
@override final  String id;
/// Owner user ID (coach)
@override final  String userId;
/// Folder name
@override final  String name;
/// Parent folder ID (null for root folders)
@override final  String? parentId;
/// Folder color (hex string, e.g., 'FF5733')
@override final  String? color;
/// Folder icon
@override@JsonKey() final  FolderIcon icon;
/// Sort order within parent
@override@JsonKey() final  int sortOrder;
/// Nested depth level (0 = root, max = kMaxFolderDepth - 1)
@override@JsonKey() final  int depth;
/// Creation timestamp
@override final  DateTime createdAt;
/// Last update timestamp
@override final  DateTime? updatedAt;
/// Number of templates in this folder (denormalized for UI)
@override@JsonKey() final  int templateCount;
/// Description/notes for the folder
@override final  String? description;

/// Create a copy of TemplateFolder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateFolderCopyWith<_TemplateFolder> get copyWith => __$TemplateFolderCopyWithImpl<_TemplateFolder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateFolderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.templateCount, templateCount) || other.templateCount == templateCount)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,parentId,color,icon,sortOrder,depth,createdAt,updatedAt,templateCount,description);

@override
String toString() {
  return 'TemplateFolder(id: $id, userId: $userId, name: $name, parentId: $parentId, color: $color, icon: $icon, sortOrder: $sortOrder, depth: $depth, createdAt: $createdAt, updatedAt: $updatedAt, templateCount: $templateCount, description: $description)';
}


}

/// @nodoc
abstract mixin class _$TemplateFolderCopyWith<$Res> implements $TemplateFolderCopyWith<$Res> {
  factory _$TemplateFolderCopyWith(_TemplateFolder value, $Res Function(_TemplateFolder) _then) = __$TemplateFolderCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? parentId, String? color, FolderIcon icon, int sortOrder, int depth, DateTime createdAt, DateTime? updatedAt, int templateCount, String? description
});




}
/// @nodoc
class __$TemplateFolderCopyWithImpl<$Res>
    implements _$TemplateFolderCopyWith<$Res> {
  __$TemplateFolderCopyWithImpl(this._self, this._then);

  final _TemplateFolder _self;
  final $Res Function(_TemplateFolder) _then;

/// Create a copy of TemplateFolder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? parentId = freezed,Object? color = freezed,Object? icon = null,Object? sortOrder = null,Object? depth = null,Object? createdAt = null,Object? updatedAt = freezed,Object? templateCount = null,Object? description = freezed,}) {
  return _then(_TemplateFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as FolderIcon,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,templateCount: null == templateCount ? _self.templateCount : templateCount // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
