// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'advanced_exercise_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdvancedExerciseTemplate _$AdvancedExerciseTemplateFromJson(
    Map<String, dynamic> json) {
  return _AdvancedExerciseTemplate.fromJson(json);
}

/// @nodoc
mixin _$AdvancedExerciseTemplate {
  /// Unique template ID (UUID)
  String get id => throw _privateConstructorUsedError;

  /// User ID who owns this template
  String get userId => throw _privateConstructorUsedError;

  /// User-defined template name
  String get name => throw _privateConstructorUsedError;

  /// Optional description
  String? get description => throw _privateConstructorUsedError;

  /// Type of advanced exercise
  AdvancedExerciseType get type => throw _privateConstructorUsedError;

  /// Configuration data based on type
  AdvancedExerciseConfig get config => throw _privateConstructorUsedError;

  /// Tags for organization
  List<String> get tags => throw _privateConstructorUsedError;

  /// Number of times this template has been used
  int get usageCount => throw _privateConstructorUsedError;

  /// Whether this is a favorite template
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Created timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last modified timestamp
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Last used timestamp
  DateTime? get lastUsedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdvancedExerciseTemplateCopyWith<AdvancedExerciseTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdvancedExerciseTemplateCopyWith<$Res> {
  factory $AdvancedExerciseTemplateCopyWith(AdvancedExerciseTemplate value,
          $Res Function(AdvancedExerciseTemplate) then) =
      _$AdvancedExerciseTemplateCopyWithImpl<$Res, AdvancedExerciseTemplate>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      AdvancedExerciseType type,
      AdvancedExerciseConfig config,
      List<String> tags,
      int usageCount,
      bool isFavorite,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? lastUsedAt});

  $AdvancedExerciseConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$AdvancedExerciseTemplateCopyWithImpl<$Res,
        $Val extends AdvancedExerciseTemplate>
    implements $AdvancedExerciseTemplateCopyWith<$Res> {
  _$AdvancedExerciseTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
    Object? config = null,
    Object? tags = null,
    Object? usageCount = null,
    Object? isFavorite = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastUsedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AdvancedExerciseType,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as AdvancedExerciseConfig,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUsedAt: freezed == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AdvancedExerciseConfigCopyWith<$Res> get config {
    return $AdvancedExerciseConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AdvancedExerciseTemplateImplCopyWith<$Res>
    implements $AdvancedExerciseTemplateCopyWith<$Res> {
  factory _$$AdvancedExerciseTemplateImplCopyWith(
          _$AdvancedExerciseTemplateImpl value,
          $Res Function(_$AdvancedExerciseTemplateImpl) then) =
      __$$AdvancedExerciseTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      AdvancedExerciseType type,
      AdvancedExerciseConfig config,
      List<String> tags,
      int usageCount,
      bool isFavorite,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? lastUsedAt});

  @override
  $AdvancedExerciseConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$AdvancedExerciseTemplateImplCopyWithImpl<$Res>
    extends _$AdvancedExerciseTemplateCopyWithImpl<$Res,
        _$AdvancedExerciseTemplateImpl>
    implements _$$AdvancedExerciseTemplateImplCopyWith<$Res> {
  __$$AdvancedExerciseTemplateImplCopyWithImpl(
      _$AdvancedExerciseTemplateImpl _value,
      $Res Function(_$AdvancedExerciseTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
    Object? config = null,
    Object? tags = null,
    Object? usageCount = null,
    Object? isFavorite = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastUsedAt = freezed,
  }) {
    return _then(_$AdvancedExerciseTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AdvancedExerciseType,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as AdvancedExerciseConfig,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUsedAt: freezed == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdvancedExerciseTemplateImpl extends _AdvancedExerciseTemplate {
  const _$AdvancedExerciseTemplateImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      required this.type,
      required this.config,
      final List<String> tags = const [],
      this.usageCount = 0,
      this.isFavorite = false,
      required this.createdAt,
      required this.updatedAt,
      this.lastUsedAt})
      : _tags = tags,
        super._();

  factory _$AdvancedExerciseTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdvancedExerciseTemplateImplFromJson(json);

  /// Unique template ID (UUID)
  @override
  final String id;

  /// User ID who owns this template
  @override
  final String userId;

  /// User-defined template name
  @override
  final String name;

  /// Optional description
  @override
  final String? description;

  /// Type of advanced exercise
  @override
  final AdvancedExerciseType type;

  /// Configuration data based on type
  @override
  final AdvancedExerciseConfig config;

  /// Tags for organization
  final List<String> _tags;

  /// Tags for organization
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Number of times this template has been used
  @override
  @JsonKey()
  final int usageCount;

  /// Whether this is a favorite template
  @override
  @JsonKey()
  final bool isFavorite;

  /// Created timestamp
  @override
  final DateTime createdAt;

  /// Last modified timestamp
  @override
  final DateTime updatedAt;

  /// Last used timestamp
  @override
  final DateTime? lastUsedAt;

  @override
  String toString() {
    return 'AdvancedExerciseTemplate(id: $id, userId: $userId, name: $name, description: $description, type: $type, config: $config, tags: $tags, usageCount: $usageCount, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt, lastUsedAt: $lastUsedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdvancedExerciseTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.config, config) || other.config == config) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      description,
      type,
      config,
      const DeepCollectionEquality().hash(_tags),
      usageCount,
      isFavorite,
      createdAt,
      updatedAt,
      lastUsedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AdvancedExerciseTemplateImplCopyWith<_$AdvancedExerciseTemplateImpl>
      get copyWith => __$$AdvancedExerciseTemplateImplCopyWithImpl<
          _$AdvancedExerciseTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdvancedExerciseTemplateImplToJson(
      this,
    );
  }
}

abstract class _AdvancedExerciseTemplate extends AdvancedExerciseTemplate {
  const factory _AdvancedExerciseTemplate(
      {required final String id,
      required final String userId,
      required final String name,
      final String? description,
      required final AdvancedExerciseType type,
      required final AdvancedExerciseConfig config,
      final List<String> tags,
      final int usageCount,
      final bool isFavorite,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? lastUsedAt}) = _$AdvancedExerciseTemplateImpl;
  const _AdvancedExerciseTemplate._() : super._();

  factory _AdvancedExerciseTemplate.fromJson(Map<String, dynamic> json) =
      _$AdvancedExerciseTemplateImpl.fromJson;

  @override

  /// Unique template ID (UUID)
  String get id;
  @override

  /// User ID who owns this template
  String get userId;
  @override

  /// User-defined template name
  String get name;
  @override

  /// Optional description
  String? get description;
  @override

  /// Type of advanced exercise
  AdvancedExerciseType get type;
  @override

  /// Configuration data based on type
  AdvancedExerciseConfig get config;
  @override

  /// Tags for organization
  List<String> get tags;
  @override

  /// Number of times this template has been used
  int get usageCount;
  @override

  /// Whether this is a favorite template
  bool get isFavorite;
  @override

  /// Created timestamp
  DateTime get createdAt;
  @override

  /// Last modified timestamp
  DateTime get updatedAt;
  @override

  /// Last used timestamp
  DateTime? get lastUsedAt;
  @override
  @JsonKey(ignore: true)
  _$$AdvancedExerciseTemplateImplCopyWith<_$AdvancedExerciseTemplateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AdvancedExerciseConfig _$AdvancedExerciseConfigFromJson(
    Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'superset':
      return SupersetConfig.fromJson(json);
    case 'dropSet':
      return DropSetConfig.fromJson(json);
    case 'restPause':
      return RestPauseConfig.fromJson(json);

    default:
      throw CheckedFromJsonException(
          json,
          'runtimeType',
          'AdvancedExerciseConfig',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$AdvancedExerciseConfig {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<String> exerciseNames,
            List<String> exerciseIds,
            int targetSets,
            int restBetweenExercises,
            int restBetweenRounds)
        superset,
    required TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)
        dropSet,
    required TResult Function(String exerciseName, String exerciseId,
            int miniSets, int restDuration, int? targetReps)
        restPause,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult? Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult? Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SupersetConfig value) superset,
    required TResult Function(DropSetConfig value) dropSet,
    required TResult Function(RestPauseConfig value) restPause,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SupersetConfig value)? superset,
    TResult? Function(DropSetConfig value)? dropSet,
    TResult? Function(RestPauseConfig value)? restPause,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SupersetConfig value)? superset,
    TResult Function(DropSetConfig value)? dropSet,
    TResult Function(RestPauseConfig value)? restPause,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdvancedExerciseConfigCopyWith<$Res> {
  factory $AdvancedExerciseConfigCopyWith(AdvancedExerciseConfig value,
          $Res Function(AdvancedExerciseConfig) then) =
      _$AdvancedExerciseConfigCopyWithImpl<$Res, AdvancedExerciseConfig>;
}

/// @nodoc
class _$AdvancedExerciseConfigCopyWithImpl<$Res,
        $Val extends AdvancedExerciseConfig>
    implements $AdvancedExerciseConfigCopyWith<$Res> {
  _$AdvancedExerciseConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SupersetConfigImplCopyWith<$Res> {
  factory _$$SupersetConfigImplCopyWith(_$SupersetConfigImpl value,
          $Res Function(_$SupersetConfigImpl) then) =
      __$$SupersetConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<String> exerciseNames,
      List<String> exerciseIds,
      int targetSets,
      int restBetweenExercises,
      int restBetweenRounds});
}

/// @nodoc
class __$$SupersetConfigImplCopyWithImpl<$Res>
    extends _$AdvancedExerciseConfigCopyWithImpl<$Res, _$SupersetConfigImpl>
    implements _$$SupersetConfigImplCopyWith<$Res> {
  __$$SupersetConfigImplCopyWithImpl(
      _$SupersetConfigImpl _value, $Res Function(_$SupersetConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseNames = null,
    Object? exerciseIds = null,
    Object? targetSets = null,
    Object? restBetweenExercises = null,
    Object? restBetweenRounds = null,
  }) {
    return _then(_$SupersetConfigImpl(
      exerciseNames: null == exerciseNames
          ? _value._exerciseNames
          : exerciseNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      exerciseIds: null == exerciseIds
          ? _value._exerciseIds
          : exerciseIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetSets: null == targetSets
          ? _value.targetSets
          : targetSets // ignore: cast_nullable_to_non_nullable
              as int,
      restBetweenExercises: null == restBetweenExercises
          ? _value.restBetweenExercises
          : restBetweenExercises // ignore: cast_nullable_to_non_nullable
              as int,
      restBetweenRounds: null == restBetweenRounds
          ? _value.restBetweenRounds
          : restBetweenRounds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupersetConfigImpl implements SupersetConfig {
  const _$SupersetConfigImpl(
      {required final List<String> exerciseNames,
      required final List<String> exerciseIds,
      required this.targetSets,
      this.restBetweenExercises = 0,
      this.restBetweenRounds = 90,
      final String? $type})
      : _exerciseNames = exerciseNames,
        _exerciseIds = exerciseIds,
        $type = $type ?? 'superset';

  factory _$SupersetConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupersetConfigImplFromJson(json);

  final List<String> _exerciseNames;
  @override
  List<String> get exerciseNames {
    if (_exerciseNames is EqualUnmodifiableListView) return _exerciseNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseNames);
  }

  final List<String> _exerciseIds;
  @override
  List<String> get exerciseIds {
    if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseIds);
  }

  @override
  final int targetSets;
  @override
  @JsonKey()
  final int restBetweenExercises;
  @override
  @JsonKey()
  final int restBetweenRounds;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'AdvancedExerciseConfig.superset(exerciseNames: $exerciseNames, exerciseIds: $exerciseIds, targetSets: $targetSets, restBetweenExercises: $restBetweenExercises, restBetweenRounds: $restBetweenRounds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupersetConfigImpl &&
            const DeepCollectionEquality()
                .equals(other._exerciseNames, _exerciseNames) &&
            const DeepCollectionEquality()
                .equals(other._exerciseIds, _exerciseIds) &&
            (identical(other.targetSets, targetSets) ||
                other.targetSets == targetSets) &&
            (identical(other.restBetweenExercises, restBetweenExercises) ||
                other.restBetweenExercises == restBetweenExercises) &&
            (identical(other.restBetweenRounds, restBetweenRounds) ||
                other.restBetweenRounds == restBetweenRounds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_exerciseNames),
      const DeepCollectionEquality().hash(_exerciseIds),
      targetSets,
      restBetweenExercises,
      restBetweenRounds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SupersetConfigImplCopyWith<_$SupersetConfigImpl> get copyWith =>
      __$$SupersetConfigImplCopyWithImpl<_$SupersetConfigImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<String> exerciseNames,
            List<String> exerciseIds,
            int targetSets,
            int restBetweenExercises,
            int restBetweenRounds)
        superset,
    required TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)
        dropSet,
    required TResult Function(String exerciseName, String exerciseId,
            int miniSets, int restDuration, int? targetReps)
        restPause,
  }) {
    return superset(exerciseNames, exerciseIds, targetSets,
        restBetweenExercises, restBetweenRounds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult? Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult? Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
  }) {
    return superset?.call(exerciseNames, exerciseIds, targetSets,
        restBetweenExercises, restBetweenRounds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
    required TResult orElse(),
  }) {
    if (superset != null) {
      return superset(exerciseNames, exerciseIds, targetSets,
          restBetweenExercises, restBetweenRounds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SupersetConfig value) superset,
    required TResult Function(DropSetConfig value) dropSet,
    required TResult Function(RestPauseConfig value) restPause,
  }) {
    return superset(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SupersetConfig value)? superset,
    TResult? Function(DropSetConfig value)? dropSet,
    TResult? Function(RestPauseConfig value)? restPause,
  }) {
    return superset?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SupersetConfig value)? superset,
    TResult Function(DropSetConfig value)? dropSet,
    TResult Function(RestPauseConfig value)? restPause,
    required TResult orElse(),
  }) {
    if (superset != null) {
      return superset(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SupersetConfigImplToJson(
      this,
    );
  }
}

abstract class SupersetConfig implements AdvancedExerciseConfig {
  const factory SupersetConfig(
      {required final List<String> exerciseNames,
      required final List<String> exerciseIds,
      required final int targetSets,
      final int restBetweenExercises,
      final int restBetweenRounds}) = _$SupersetConfigImpl;

  factory SupersetConfig.fromJson(Map<String, dynamic> json) =
      _$SupersetConfigImpl.fromJson;

  List<String> get exerciseNames;
  List<String> get exerciseIds;
  int get targetSets;
  int get restBetweenExercises;
  int get restBetweenRounds;
  @JsonKey(ignore: true)
  _$$SupersetConfigImplCopyWith<_$SupersetConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DropSetConfigImplCopyWith<$Res> {
  factory _$$DropSetConfigImplCopyWith(
          _$DropSetConfigImpl value, $Res Function(_$DropSetConfigImpl) then) =
      __$$DropSetConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String exerciseName,
      String exerciseId,
      int drops,
      List<double> percentageDrops,
      int restBetweenDrops});
}

/// @nodoc
class __$$DropSetConfigImplCopyWithImpl<$Res>
    extends _$AdvancedExerciseConfigCopyWithImpl<$Res, _$DropSetConfigImpl>
    implements _$$DropSetConfigImplCopyWith<$Res> {
  __$$DropSetConfigImplCopyWithImpl(
      _$DropSetConfigImpl _value, $Res Function(_$DropSetConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? exerciseId = null,
    Object? drops = null,
    Object? percentageDrops = null,
    Object? restBetweenDrops = null,
  }) {
    return _then(_$DropSetConfigImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      drops: null == drops
          ? _value.drops
          : drops // ignore: cast_nullable_to_non_nullable
              as int,
      percentageDrops: null == percentageDrops
          ? _value._percentageDrops
          : percentageDrops // ignore: cast_nullable_to_non_nullable
              as List<double>,
      restBetweenDrops: null == restBetweenDrops
          ? _value.restBetweenDrops
          : restBetweenDrops // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DropSetConfigImpl implements DropSetConfig {
  const _$DropSetConfigImpl(
      {required this.exerciseName,
      required this.exerciseId,
      required this.drops,
      required final List<double> percentageDrops,
      this.restBetweenDrops = 0,
      final String? $type})
      : _percentageDrops = percentageDrops,
        $type = $type ?? 'dropSet';

  factory _$DropSetConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$DropSetConfigImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final String exerciseId;
  @override
  final int drops;
  final List<double> _percentageDrops;
  @override
  List<double> get percentageDrops {
    if (_percentageDrops is EqualUnmodifiableListView) return _percentageDrops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_percentageDrops);
  }

  @override
  @JsonKey()
  final int restBetweenDrops;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'AdvancedExerciseConfig.dropSet(exerciseName: $exerciseName, exerciseId: $exerciseId, drops: $drops, percentageDrops: $percentageDrops, restBetweenDrops: $restBetweenDrops)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DropSetConfigImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.drops, drops) || other.drops == drops) &&
            const DeepCollectionEquality()
                .equals(other._percentageDrops, _percentageDrops) &&
            (identical(other.restBetweenDrops, restBetweenDrops) ||
                other.restBetweenDrops == restBetweenDrops));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, exerciseId, drops,
      const DeepCollectionEquality().hash(_percentageDrops), restBetweenDrops);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DropSetConfigImplCopyWith<_$DropSetConfigImpl> get copyWith =>
      __$$DropSetConfigImplCopyWithImpl<_$DropSetConfigImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<String> exerciseNames,
            List<String> exerciseIds,
            int targetSets,
            int restBetweenExercises,
            int restBetweenRounds)
        superset,
    required TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)
        dropSet,
    required TResult Function(String exerciseName, String exerciseId,
            int miniSets, int restDuration, int? targetReps)
        restPause,
  }) {
    return dropSet(
        exerciseName, exerciseId, drops, percentageDrops, restBetweenDrops);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult? Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult? Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
  }) {
    return dropSet?.call(
        exerciseName, exerciseId, drops, percentageDrops, restBetweenDrops);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
    required TResult orElse(),
  }) {
    if (dropSet != null) {
      return dropSet(
          exerciseName, exerciseId, drops, percentageDrops, restBetweenDrops);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SupersetConfig value) superset,
    required TResult Function(DropSetConfig value) dropSet,
    required TResult Function(RestPauseConfig value) restPause,
  }) {
    return dropSet(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SupersetConfig value)? superset,
    TResult? Function(DropSetConfig value)? dropSet,
    TResult? Function(RestPauseConfig value)? restPause,
  }) {
    return dropSet?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SupersetConfig value)? superset,
    TResult Function(DropSetConfig value)? dropSet,
    TResult Function(RestPauseConfig value)? restPause,
    required TResult orElse(),
  }) {
    if (dropSet != null) {
      return dropSet(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DropSetConfigImplToJson(
      this,
    );
  }
}

abstract class DropSetConfig implements AdvancedExerciseConfig {
  const factory DropSetConfig(
      {required final String exerciseName,
      required final String exerciseId,
      required final int drops,
      required final List<double> percentageDrops,
      final int restBetweenDrops}) = _$DropSetConfigImpl;

  factory DropSetConfig.fromJson(Map<String, dynamic> json) =
      _$DropSetConfigImpl.fromJson;

  String get exerciseName;
  String get exerciseId;
  int get drops;
  List<double> get percentageDrops;
  int get restBetweenDrops;
  @JsonKey(ignore: true)
  _$$DropSetConfigImplCopyWith<_$DropSetConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RestPauseConfigImplCopyWith<$Res> {
  factory _$$RestPauseConfigImplCopyWith(_$RestPauseConfigImpl value,
          $Res Function(_$RestPauseConfigImpl) then) =
      __$$RestPauseConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String exerciseName,
      String exerciseId,
      int miniSets,
      int restDuration,
      int? targetReps});
}

/// @nodoc
class __$$RestPauseConfigImplCopyWithImpl<$Res>
    extends _$AdvancedExerciseConfigCopyWithImpl<$Res, _$RestPauseConfigImpl>
    implements _$$RestPauseConfigImplCopyWith<$Res> {
  __$$RestPauseConfigImplCopyWithImpl(
      _$RestPauseConfigImpl _value, $Res Function(_$RestPauseConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? exerciseId = null,
    Object? miniSets = null,
    Object? restDuration = null,
    Object? targetReps = freezed,
  }) {
    return _then(_$RestPauseConfigImpl(
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      miniSets: null == miniSets
          ? _value.miniSets
          : miniSets // ignore: cast_nullable_to_non_nullable
              as int,
      restDuration: null == restDuration
          ? _value.restDuration
          : restDuration // ignore: cast_nullable_to_non_nullable
              as int,
      targetReps: freezed == targetReps
          ? _value.targetReps
          : targetReps // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestPauseConfigImpl implements RestPauseConfig {
  const _$RestPauseConfigImpl(
      {required this.exerciseName,
      required this.exerciseId,
      required this.miniSets,
      this.restDuration = 15,
      this.targetReps,
      final String? $type})
      : $type = $type ?? 'restPause';

  factory _$RestPauseConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestPauseConfigImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final String exerciseId;
  @override
  final int miniSets;
  @override
  @JsonKey()
  final int restDuration;
  @override
  final int? targetReps;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'AdvancedExerciseConfig.restPause(exerciseName: $exerciseName, exerciseId: $exerciseId, miniSets: $miniSets, restDuration: $restDuration, targetReps: $targetReps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestPauseConfigImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.miniSets, miniSets) ||
                other.miniSets == miniSets) &&
            (identical(other.restDuration, restDuration) ||
                other.restDuration == restDuration) &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseName, exerciseId,
      miniSets, restDuration, targetReps);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RestPauseConfigImplCopyWith<_$RestPauseConfigImpl> get copyWith =>
      __$$RestPauseConfigImplCopyWithImpl<_$RestPauseConfigImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<String> exerciseNames,
            List<String> exerciseIds,
            int targetSets,
            int restBetweenExercises,
            int restBetweenRounds)
        superset,
    required TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)
        dropSet,
    required TResult Function(String exerciseName, String exerciseId,
            int miniSets, int restDuration, int? targetReps)
        restPause,
  }) {
    return restPause(
        exerciseName, exerciseId, miniSets, restDuration, targetReps);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult? Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult? Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
  }) {
    return restPause?.call(
        exerciseName, exerciseId, miniSets, restDuration, targetReps);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<String> exerciseNames, List<String> exerciseIds,
            int targetSets, int restBetweenExercises, int restBetweenRounds)?
        superset,
    TResult Function(String exerciseName, String exerciseId, int drops,
            List<double> percentageDrops, int restBetweenDrops)?
        dropSet,
    TResult Function(String exerciseName, String exerciseId, int miniSets,
            int restDuration, int? targetReps)?
        restPause,
    required TResult orElse(),
  }) {
    if (restPause != null) {
      return restPause(
          exerciseName, exerciseId, miniSets, restDuration, targetReps);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SupersetConfig value) superset,
    required TResult Function(DropSetConfig value) dropSet,
    required TResult Function(RestPauseConfig value) restPause,
  }) {
    return restPause(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SupersetConfig value)? superset,
    TResult? Function(DropSetConfig value)? dropSet,
    TResult? Function(RestPauseConfig value)? restPause,
  }) {
    return restPause?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SupersetConfig value)? superset,
    TResult Function(DropSetConfig value)? dropSet,
    TResult Function(RestPauseConfig value)? restPause,
    required TResult orElse(),
  }) {
    if (restPause != null) {
      return restPause(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RestPauseConfigImplToJson(
      this,
    );
  }
}

abstract class RestPauseConfig implements AdvancedExerciseConfig {
  const factory RestPauseConfig(
      {required final String exerciseName,
      required final String exerciseId,
      required final int miniSets,
      final int restDuration,
      final int? targetReps}) = _$RestPauseConfigImpl;

  factory RestPauseConfig.fromJson(Map<String, dynamic> json) =
      _$RestPauseConfigImpl.fromJson;

  String get exerciseName;
  String get exerciseId;
  int get miniSets;
  int get restDuration;
  int? get targetReps;
  @JsonKey(ignore: true)
  _$$RestPauseConfigImplCopyWith<_$RestPauseConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
