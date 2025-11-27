// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'advanced_exercise_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdvancedExerciseTemplate {

/// Unique template ID (UUID)
 String get id;/// User ID who owns this template
 String get userId;/// User-defined template name
 String get name;/// Optional description
 String? get description;/// Type of advanced exercise
 AdvancedExerciseType get type;/// Configuration data based on type
 AdvancedExerciseConfig get config;/// Tags for organization
 List<String> get tags;/// Number of times this template has been used
 int get usageCount;/// Whether this is a favorite template
 bool get isFavorite;/// Created timestamp
 DateTime get createdAt;/// Last modified timestamp
 DateTime get updatedAt;/// Last used timestamp
 DateTime? get lastUsedAt;
/// Create a copy of AdvancedExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdvancedExerciseTemplateCopyWith<AdvancedExerciseTemplate> get copyWith => _$AdvancedExerciseTemplateCopyWithImpl<AdvancedExerciseTemplate>(this as AdvancedExerciseTemplate, _$identity);

  /// Serializes this AdvancedExerciseTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvancedExerciseTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,type,config,const DeepCollectionEquality().hash(tags),usageCount,isFavorite,createdAt,updatedAt,lastUsedAt);

@override
String toString() {
  return 'AdvancedExerciseTemplate(id: $id, userId: $userId, name: $name, description: $description, type: $type, config: $config, tags: $tags, usageCount: $usageCount, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class $AdvancedExerciseTemplateCopyWith<$Res>  {
  factory $AdvancedExerciseTemplateCopyWith(AdvancedExerciseTemplate value, $Res Function(AdvancedExerciseTemplate) _then) = _$AdvancedExerciseTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? description, AdvancedExerciseType type, AdvancedExerciseConfig config, List<String> tags, int usageCount, bool isFavorite, DateTime createdAt, DateTime updatedAt, DateTime? lastUsedAt
});


$AdvancedExerciseConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$AdvancedExerciseTemplateCopyWithImpl<$Res>
    implements $AdvancedExerciseTemplateCopyWith<$Res> {
  _$AdvancedExerciseTemplateCopyWithImpl(this._self, this._then);

  final AdvancedExerciseTemplate _self;
  final $Res Function(AdvancedExerciseTemplate) _then;

/// Create a copy of AdvancedExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? type = null,Object? config = null,Object? tags = null,Object? usageCount = null,Object? isFavorite = null,Object? createdAt = null,Object? updatedAt = null,Object? lastUsedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdvancedExerciseType,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as AdvancedExerciseConfig,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of AdvancedExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdvancedExerciseConfigCopyWith<$Res> get config {
  
  return $AdvancedExerciseConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdvancedExerciseTemplate].
extension AdvancedExerciseTemplatePatterns on AdvancedExerciseTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdvancedExerciseTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdvancedExerciseTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdvancedExerciseTemplate value)  $default,){
final _that = this;
switch (_that) {
case _AdvancedExerciseTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdvancedExerciseTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _AdvancedExerciseTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  AdvancedExerciseType type,  AdvancedExerciseConfig config,  List<String> tags,  int usageCount,  bool isFavorite,  DateTime createdAt,  DateTime updatedAt,  DateTime? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdvancedExerciseTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.type,_that.config,_that.tags,_that.usageCount,_that.isFavorite,_that.createdAt,_that.updatedAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  AdvancedExerciseType type,  AdvancedExerciseConfig config,  List<String> tags,  int usageCount,  bool isFavorite,  DateTime createdAt,  DateTime updatedAt,  DateTime? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _AdvancedExerciseTemplate():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.type,_that.config,_that.tags,_that.usageCount,_that.isFavorite,_that.createdAt,_that.updatedAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? description,  AdvancedExerciseType type,  AdvancedExerciseConfig config,  List<String> tags,  int usageCount,  bool isFavorite,  DateTime createdAt,  DateTime updatedAt,  DateTime? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _AdvancedExerciseTemplate() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.type,_that.config,_that.tags,_that.usageCount,_that.isFavorite,_that.createdAt,_that.updatedAt,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdvancedExerciseTemplate extends AdvancedExerciseTemplate {
  const _AdvancedExerciseTemplate({required this.id, required this.userId, required this.name, this.description, required this.type, required this.config, final  List<String> tags = const [], this.usageCount = 0, this.isFavorite = false, required this.createdAt, required this.updatedAt, this.lastUsedAt}): _tags = tags,super._();
  factory _AdvancedExerciseTemplate.fromJson(Map<String, dynamic> json) => _$AdvancedExerciseTemplateFromJson(json);

/// Unique template ID (UUID)
@override final  String id;
/// User ID who owns this template
@override final  String userId;
/// User-defined template name
@override final  String name;
/// Optional description
@override final  String? description;
/// Type of advanced exercise
@override final  AdvancedExerciseType type;
/// Configuration data based on type
@override final  AdvancedExerciseConfig config;
/// Tags for organization
 final  List<String> _tags;
/// Tags for organization
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Number of times this template has been used
@override@JsonKey() final  int usageCount;
/// Whether this is a favorite template
@override@JsonKey() final  bool isFavorite;
/// Created timestamp
@override final  DateTime createdAt;
/// Last modified timestamp
@override final  DateTime updatedAt;
/// Last used timestamp
@override final  DateTime? lastUsedAt;

/// Create a copy of AdvancedExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdvancedExerciseTemplateCopyWith<_AdvancedExerciseTemplate> get copyWith => __$AdvancedExerciseTemplateCopyWithImpl<_AdvancedExerciseTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdvancedExerciseTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdvancedExerciseTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,type,config,const DeepCollectionEquality().hash(_tags),usageCount,isFavorite,createdAt,updatedAt,lastUsedAt);

@override
String toString() {
  return 'AdvancedExerciseTemplate(id: $id, userId: $userId, name: $name, description: $description, type: $type, config: $config, tags: $tags, usageCount: $usageCount, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$AdvancedExerciseTemplateCopyWith<$Res> implements $AdvancedExerciseTemplateCopyWith<$Res> {
  factory _$AdvancedExerciseTemplateCopyWith(_AdvancedExerciseTemplate value, $Res Function(_AdvancedExerciseTemplate) _then) = __$AdvancedExerciseTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? description, AdvancedExerciseType type, AdvancedExerciseConfig config, List<String> tags, int usageCount, bool isFavorite, DateTime createdAt, DateTime updatedAt, DateTime? lastUsedAt
});


@override $AdvancedExerciseConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$AdvancedExerciseTemplateCopyWithImpl<$Res>
    implements _$AdvancedExerciseTemplateCopyWith<$Res> {
  __$AdvancedExerciseTemplateCopyWithImpl(this._self, this._then);

  final _AdvancedExerciseTemplate _self;
  final $Res Function(_AdvancedExerciseTemplate) _then;

/// Create a copy of AdvancedExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? type = null,Object? config = null,Object? tags = null,Object? usageCount = null,Object? isFavorite = null,Object? createdAt = null,Object? updatedAt = null,Object? lastUsedAt = freezed,}) {
  return _then(_AdvancedExerciseTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdvancedExerciseType,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as AdvancedExerciseConfig,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of AdvancedExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdvancedExerciseConfigCopyWith<$Res> get config {
  
  return $AdvancedExerciseConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

AdvancedExerciseConfig _$AdvancedExerciseConfigFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'superset':
          return SupersetConfig.fromJson(
            json
          );
                case 'dropSet':
          return DropSetConfig.fromJson(
            json
          );
                case 'restPause':
          return RestPauseConfig.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'AdvancedExerciseConfig',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$AdvancedExerciseConfig {



  /// Serializes this AdvancedExerciseConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvancedExerciseConfig);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AdvancedExerciseConfig()';
}


}

/// @nodoc
class $AdvancedExerciseConfigCopyWith<$Res>  {
$AdvancedExerciseConfigCopyWith(AdvancedExerciseConfig _, $Res Function(AdvancedExerciseConfig) __);
}


/// Adds pattern-matching-related methods to [AdvancedExerciseConfig].
extension AdvancedExerciseConfigPatterns on AdvancedExerciseConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SupersetConfig value)?  superset,TResult Function( DropSetConfig value)?  dropSet,TResult Function( RestPauseConfig value)?  restPause,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SupersetConfig() when superset != null:
return superset(_that);case DropSetConfig() when dropSet != null:
return dropSet(_that);case RestPauseConfig() when restPause != null:
return restPause(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SupersetConfig value)  superset,required TResult Function( DropSetConfig value)  dropSet,required TResult Function( RestPauseConfig value)  restPause,}){
final _that = this;
switch (_that) {
case SupersetConfig():
return superset(_that);case DropSetConfig():
return dropSet(_that);case RestPauseConfig():
return restPause(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SupersetConfig value)?  superset,TResult? Function( DropSetConfig value)?  dropSet,TResult? Function( RestPauseConfig value)?  restPause,}){
final _that = this;
switch (_that) {
case SupersetConfig() when superset != null:
return superset(_that);case DropSetConfig() when dropSet != null:
return dropSet(_that);case RestPauseConfig() when restPause != null:
return restPause(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> exerciseNames,  List<String> exerciseIds,  int targetSets,  int restBetweenExercises,  int restBetweenRounds)?  superset,TResult Function( String exerciseName,  String exerciseId,  int drops,  List<double> percentageDrops,  int restBetweenDrops)?  dropSet,TResult Function( String exerciseName,  String exerciseId,  int miniSets,  int restDuration,  int? targetReps)?  restPause,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SupersetConfig() when superset != null:
return superset(_that.exerciseNames,_that.exerciseIds,_that.targetSets,_that.restBetweenExercises,_that.restBetweenRounds);case DropSetConfig() when dropSet != null:
return dropSet(_that.exerciseName,_that.exerciseId,_that.drops,_that.percentageDrops,_that.restBetweenDrops);case RestPauseConfig() when restPause != null:
return restPause(_that.exerciseName,_that.exerciseId,_that.miniSets,_that.restDuration,_that.targetReps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> exerciseNames,  List<String> exerciseIds,  int targetSets,  int restBetweenExercises,  int restBetweenRounds)  superset,required TResult Function( String exerciseName,  String exerciseId,  int drops,  List<double> percentageDrops,  int restBetweenDrops)  dropSet,required TResult Function( String exerciseName,  String exerciseId,  int miniSets,  int restDuration,  int? targetReps)  restPause,}) {final _that = this;
switch (_that) {
case SupersetConfig():
return superset(_that.exerciseNames,_that.exerciseIds,_that.targetSets,_that.restBetweenExercises,_that.restBetweenRounds);case DropSetConfig():
return dropSet(_that.exerciseName,_that.exerciseId,_that.drops,_that.percentageDrops,_that.restBetweenDrops);case RestPauseConfig():
return restPause(_that.exerciseName,_that.exerciseId,_that.miniSets,_that.restDuration,_that.targetReps);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> exerciseNames,  List<String> exerciseIds,  int targetSets,  int restBetweenExercises,  int restBetweenRounds)?  superset,TResult? Function( String exerciseName,  String exerciseId,  int drops,  List<double> percentageDrops,  int restBetweenDrops)?  dropSet,TResult? Function( String exerciseName,  String exerciseId,  int miniSets,  int restDuration,  int? targetReps)?  restPause,}) {final _that = this;
switch (_that) {
case SupersetConfig() when superset != null:
return superset(_that.exerciseNames,_that.exerciseIds,_that.targetSets,_that.restBetweenExercises,_that.restBetweenRounds);case DropSetConfig() when dropSet != null:
return dropSet(_that.exerciseName,_that.exerciseId,_that.drops,_that.percentageDrops,_that.restBetweenDrops);case RestPauseConfig() when restPause != null:
return restPause(_that.exerciseName,_that.exerciseId,_that.miniSets,_that.restDuration,_that.targetReps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class SupersetConfig implements AdvancedExerciseConfig {
  const SupersetConfig({required final  List<String> exerciseNames, required final  List<String> exerciseIds, required this.targetSets, this.restBetweenExercises = 0, this.restBetweenRounds = 90, final  String? $type}): _exerciseNames = exerciseNames,_exerciseIds = exerciseIds,$type = $type ?? 'superset';
  factory SupersetConfig.fromJson(Map<String, dynamic> json) => _$SupersetConfigFromJson(json);

 final  List<String> _exerciseNames;
 List<String> get exerciseNames {
  if (_exerciseNames is EqualUnmodifiableListView) return _exerciseNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseNames);
}

 final  List<String> _exerciseIds;
 List<String> get exerciseIds {
  if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseIds);
}

 final  int targetSets;
@JsonKey() final  int restBetweenExercises;
@JsonKey() final  int restBetweenRounds;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of AdvancedExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupersetConfigCopyWith<SupersetConfig> get copyWith => _$SupersetConfigCopyWithImpl<SupersetConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupersetConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupersetConfig&&const DeepCollectionEquality().equals(other._exerciseNames, _exerciseNames)&&const DeepCollectionEquality().equals(other._exerciseIds, _exerciseIds)&&(identical(other.targetSets, targetSets) || other.targetSets == targetSets)&&(identical(other.restBetweenExercises, restBetweenExercises) || other.restBetweenExercises == restBetweenExercises)&&(identical(other.restBetweenRounds, restBetweenRounds) || other.restBetweenRounds == restBetweenRounds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_exerciseNames),const DeepCollectionEquality().hash(_exerciseIds),targetSets,restBetweenExercises,restBetweenRounds);

@override
String toString() {
  return 'AdvancedExerciseConfig.superset(exerciseNames: $exerciseNames, exerciseIds: $exerciseIds, targetSets: $targetSets, restBetweenExercises: $restBetweenExercises, restBetweenRounds: $restBetweenRounds)';
}


}

/// @nodoc
abstract mixin class $SupersetConfigCopyWith<$Res> implements $AdvancedExerciseConfigCopyWith<$Res> {
  factory $SupersetConfigCopyWith(SupersetConfig value, $Res Function(SupersetConfig) _then) = _$SupersetConfigCopyWithImpl;
@useResult
$Res call({
 List<String> exerciseNames, List<String> exerciseIds, int targetSets, int restBetweenExercises, int restBetweenRounds
});




}
/// @nodoc
class _$SupersetConfigCopyWithImpl<$Res>
    implements $SupersetConfigCopyWith<$Res> {
  _$SupersetConfigCopyWithImpl(this._self, this._then);

  final SupersetConfig _self;
  final $Res Function(SupersetConfig) _then;

/// Create a copy of AdvancedExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exerciseNames = null,Object? exerciseIds = null,Object? targetSets = null,Object? restBetweenExercises = null,Object? restBetweenRounds = null,}) {
  return _then(SupersetConfig(
exerciseNames: null == exerciseNames ? _self._exerciseNames : exerciseNames // ignore: cast_nullable_to_non_nullable
as List<String>,exerciseIds: null == exerciseIds ? _self._exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,targetSets: null == targetSets ? _self.targetSets : targetSets // ignore: cast_nullable_to_non_nullable
as int,restBetweenExercises: null == restBetweenExercises ? _self.restBetweenExercises : restBetweenExercises // ignore: cast_nullable_to_non_nullable
as int,restBetweenRounds: null == restBetweenRounds ? _self.restBetweenRounds : restBetweenRounds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DropSetConfig implements AdvancedExerciseConfig {
  const DropSetConfig({required this.exerciseName, required this.exerciseId, required this.drops, required final  List<double> percentageDrops, this.restBetweenDrops = 0, final  String? $type}): _percentageDrops = percentageDrops,$type = $type ?? 'dropSet';
  factory DropSetConfig.fromJson(Map<String, dynamic> json) => _$DropSetConfigFromJson(json);

 final  String exerciseName;
 final  String exerciseId;
 final  int drops;
 final  List<double> _percentageDrops;
 List<double> get percentageDrops {
  if (_percentageDrops is EqualUnmodifiableListView) return _percentageDrops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_percentageDrops);
}

@JsonKey() final  int restBetweenDrops;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of AdvancedExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DropSetConfigCopyWith<DropSetConfig> get copyWith => _$DropSetConfigCopyWithImpl<DropSetConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DropSetConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DropSetConfig&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.drops, drops) || other.drops == drops)&&const DeepCollectionEquality().equals(other._percentageDrops, _percentageDrops)&&(identical(other.restBetweenDrops, restBetweenDrops) || other.restBetweenDrops == restBetweenDrops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,exerciseId,drops,const DeepCollectionEquality().hash(_percentageDrops),restBetweenDrops);

@override
String toString() {
  return 'AdvancedExerciseConfig.dropSet(exerciseName: $exerciseName, exerciseId: $exerciseId, drops: $drops, percentageDrops: $percentageDrops, restBetweenDrops: $restBetweenDrops)';
}


}

/// @nodoc
abstract mixin class $DropSetConfigCopyWith<$Res> implements $AdvancedExerciseConfigCopyWith<$Res> {
  factory $DropSetConfigCopyWith(DropSetConfig value, $Res Function(DropSetConfig) _then) = _$DropSetConfigCopyWithImpl;
@useResult
$Res call({
 String exerciseName, String exerciseId, int drops, List<double> percentageDrops, int restBetweenDrops
});




}
/// @nodoc
class _$DropSetConfigCopyWithImpl<$Res>
    implements $DropSetConfigCopyWith<$Res> {
  _$DropSetConfigCopyWithImpl(this._self, this._then);

  final DropSetConfig _self;
  final $Res Function(DropSetConfig) _then;

/// Create a copy of AdvancedExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? exerciseId = null,Object? drops = null,Object? percentageDrops = null,Object? restBetweenDrops = null,}) {
  return _then(DropSetConfig(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,drops: null == drops ? _self.drops : drops // ignore: cast_nullable_to_non_nullable
as int,percentageDrops: null == percentageDrops ? _self._percentageDrops : percentageDrops // ignore: cast_nullable_to_non_nullable
as List<double>,restBetweenDrops: null == restBetweenDrops ? _self.restBetweenDrops : restBetweenDrops // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RestPauseConfig implements AdvancedExerciseConfig {
  const RestPauseConfig({required this.exerciseName, required this.exerciseId, required this.miniSets, this.restDuration = 15, this.targetReps, final  String? $type}): $type = $type ?? 'restPause';
  factory RestPauseConfig.fromJson(Map<String, dynamic> json) => _$RestPauseConfigFromJson(json);

 final  String exerciseName;
 final  String exerciseId;
 final  int miniSets;
@JsonKey() final  int restDuration;
 final  int? targetReps;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of AdvancedExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestPauseConfigCopyWith<RestPauseConfig> get copyWith => _$RestPauseConfigCopyWithImpl<RestPauseConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RestPauseConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestPauseConfig&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.miniSets, miniSets) || other.miniSets == miniSets)&&(identical(other.restDuration, restDuration) || other.restDuration == restDuration)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,exerciseId,miniSets,restDuration,targetReps);

@override
String toString() {
  return 'AdvancedExerciseConfig.restPause(exerciseName: $exerciseName, exerciseId: $exerciseId, miniSets: $miniSets, restDuration: $restDuration, targetReps: $targetReps)';
}


}

/// @nodoc
abstract mixin class $RestPauseConfigCopyWith<$Res> implements $AdvancedExerciseConfigCopyWith<$Res> {
  factory $RestPauseConfigCopyWith(RestPauseConfig value, $Res Function(RestPauseConfig) _then) = _$RestPauseConfigCopyWithImpl;
@useResult
$Res call({
 String exerciseName, String exerciseId, int miniSets, int restDuration, int? targetReps
});




}
/// @nodoc
class _$RestPauseConfigCopyWithImpl<$Res>
    implements $RestPauseConfigCopyWith<$Res> {
  _$RestPauseConfigCopyWithImpl(this._self, this._then);

  final RestPauseConfig _self;
  final $Res Function(RestPauseConfig) _then;

/// Create a copy of AdvancedExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? exerciseId = null,Object? miniSets = null,Object? restDuration = null,Object? targetReps = freezed,}) {
  return _then(RestPauseConfig(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,miniSets: null == miniSets ? _self.miniSets : miniSets // ignore: cast_nullable_to_non_nullable
as int,restDuration: null == restDuration ? _self.restDuration : restDuration // ignore: cast_nullable_to_non_nullable
as int,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
