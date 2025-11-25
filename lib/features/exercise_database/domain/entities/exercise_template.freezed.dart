// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExerciseDefinitionTemplate _$ExerciseDefinitionTemplateFromJson(
    Map<String, dynamic> json) {
  return _ExerciseDefinitionTemplate.fromJson(json);
}

/// @nodoc
mixin _$ExerciseDefinitionTemplate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  ExerciseCategory get category => throw _privateConstructorUsedError;
  ExerciseType get type => throw _privateConstructorUsedError;
  List<String> get muscleGroups => throw _privateConstructorUsedError;
  List<String> get equipment => throw _privateConstructorUsedError;
  List<String>? get instructions => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseDefinitionTemplateCopyWith<ExerciseDefinitionTemplate>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseDefinitionTemplateCopyWith<$Res> {
  factory $ExerciseDefinitionTemplateCopyWith(ExerciseDefinitionTemplate value,
          $Res Function(ExerciseDefinitionTemplate) then) =
      _$ExerciseDefinitionTemplateCopyWithImpl<$Res,
          ExerciseDefinitionTemplate>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      ExerciseCategory category,
      ExerciseType type,
      List<String> muscleGroups,
      List<String> equipment,
      List<String>? instructions,
      String? imageUrl,
      String? videoUrl,
      String? difficulty,
      Map<String, dynamic>? metadata,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ExerciseDefinitionTemplateCopyWithImpl<$Res,
        $Val extends ExerciseDefinitionTemplate>
    implements $ExerciseDefinitionTemplateCopyWith<$Res> {
  _$ExerciseDefinitionTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? type = null,
    Object? muscleGroups = null,
    Object? equipment = null,
    Object? instructions = freezed,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? difficulty = freezed,
    Object? metadata = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExerciseCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      muscleGroups: null == muscleGroups
          ? _value.muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseDefinitionTemplateImplCopyWith<$Res>
    implements $ExerciseDefinitionTemplateCopyWith<$Res> {
  factory _$$ExerciseDefinitionTemplateImplCopyWith(
          _$ExerciseDefinitionTemplateImpl value,
          $Res Function(_$ExerciseDefinitionTemplateImpl) then) =
      __$$ExerciseDefinitionTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      ExerciseCategory category,
      ExerciseType type,
      List<String> muscleGroups,
      List<String> equipment,
      List<String>? instructions,
      String? imageUrl,
      String? videoUrl,
      String? difficulty,
      Map<String, dynamic>? metadata,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ExerciseDefinitionTemplateImplCopyWithImpl<$Res>
    extends _$ExerciseDefinitionTemplateCopyWithImpl<$Res,
        _$ExerciseDefinitionTemplateImpl>
    implements _$$ExerciseDefinitionTemplateImplCopyWith<$Res> {
  __$$ExerciseDefinitionTemplateImplCopyWithImpl(
      _$ExerciseDefinitionTemplateImpl _value,
      $Res Function(_$ExerciseDefinitionTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? type = null,
    Object? muscleGroups = null,
    Object? equipment = null,
    Object? instructions = freezed,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? difficulty = freezed,
    Object? metadata = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ExerciseDefinitionTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ExerciseCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      muscleGroups: null == muscleGroups
          ? _value._muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instructions: freezed == instructions
          ? _value._instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseDefinitionTemplateImpl implements _ExerciseDefinitionTemplate {
  const _$ExerciseDefinitionTemplateImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.category,
      required this.type,
      required final List<String> muscleGroups,
      required final List<String> equipment,
      final List<String>? instructions,
      this.imageUrl,
      this.videoUrl,
      this.difficulty,
      final Map<String, dynamic>? metadata,
      this.isActive = true,
      this.createdAt,
      this.updatedAt})
      : _muscleGroups = muscleGroups,
        _equipment = equipment,
        _instructions = instructions,
        _metadata = metadata;

  factory _$ExerciseDefinitionTemplateImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ExerciseDefinitionTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final ExerciseCategory category;
  @override
  final ExerciseType type;
  final List<String> _muscleGroups;
  @override
  List<String> get muscleGroups {
    if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscleGroups);
  }

  final List<String> _equipment;
  @override
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  final List<String>? _instructions;
  @override
  List<String>? get instructions {
    final value = _instructions;
    if (value == null) return null;
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? imageUrl;
  @override
  final String? videoUrl;
  @override
  final String? difficulty;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ExerciseDefinitionTemplate(id: $id, name: $name, description: $description, category: $category, type: $type, muscleGroups: $muscleGroups, equipment: $equipment, instructions: $instructions, imageUrl: $imageUrl, videoUrl: $videoUrl, difficulty: $difficulty, metadata: $metadata, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseDefinitionTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._muscleGroups, _muscleGroups) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality()
                .equals(other._instructions, _instructions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      category,
      type,
      const DeepCollectionEquality().hash(_muscleGroups),
      const DeepCollectionEquality().hash(_equipment),
      const DeepCollectionEquality().hash(_instructions),
      imageUrl,
      videoUrl,
      difficulty,
      const DeepCollectionEquality().hash(_metadata),
      isActive,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseDefinitionTemplateImplCopyWith<_$ExerciseDefinitionTemplateImpl>
      get copyWith => __$$ExerciseDefinitionTemplateImplCopyWithImpl<
          _$ExerciseDefinitionTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseDefinitionTemplateImplToJson(
      this,
    );
  }
}

abstract class _ExerciseDefinitionTemplate
    implements ExerciseDefinitionTemplate {
  const factory _ExerciseDefinitionTemplate(
      {required final String id,
      required final String name,
      required final String description,
      required final ExerciseCategory category,
      required final ExerciseType type,
      required final List<String> muscleGroups,
      required final List<String> equipment,
      final List<String>? instructions,
      final String? imageUrl,
      final String? videoUrl,
      final String? difficulty,
      final Map<String, dynamic>? metadata,
      final bool isActive,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$ExerciseDefinitionTemplateImpl;

  factory _ExerciseDefinitionTemplate.fromJson(Map<String, dynamic> json) =
      _$ExerciseDefinitionTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  ExerciseCategory get category;
  @override
  ExerciseType get type;
  @override
  List<String> get muscleGroups;
  @override
  List<String> get equipment;
  @override
  List<String>? get instructions;
  @override
  String? get imageUrl;
  @override
  String? get videoUrl;
  @override
  String? get difficulty;
  @override
  Map<String, dynamic>? get metadata;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseDefinitionTemplateImplCopyWith<_$ExerciseDefinitionTemplateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
