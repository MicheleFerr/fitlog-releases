// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_database.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExerciseDatabase _$ExerciseDatabaseFromJson(Map<String, dynamic> json) {
  return _ExerciseDatabase.fromJson(json);
}

/// @nodoc
mixin _$ExerciseDatabase {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get equipment => throw _privateConstructorUsedError;
  List<String>? get primaryMuscleGroups => throw _privateConstructorUsedError;
  List<String>? get secondaryMuscleGroups => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  String? get instructions => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  bool? get isFavorite => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ExerciseDatabase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseDatabase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseDatabaseCopyWith<ExerciseDatabase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseDatabaseCopyWith<$Res> {
  factory $ExerciseDatabaseCopyWith(
    ExerciseDatabase value,
    $Res Function(ExerciseDatabase) then,
  ) = _$ExerciseDatabaseCopyWithImpl<$Res, ExerciseDatabase>;
  @useResult
  $Res call({
    String id,
    String name,
    String? category,
    String? equipment,
    List<String>? primaryMuscleGroups,
    List<String>? secondaryMuscleGroups,
    String? difficulty,
    String? instructions,
    String? imageUrl,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ExerciseDatabaseCopyWithImpl<$Res, $Val extends ExerciseDatabase>
    implements $ExerciseDatabaseCopyWith<$Res> {
  _$ExerciseDatabaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseDatabase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? equipment = freezed,
    Object? primaryMuscleGroups = freezed,
    Object? secondaryMuscleGroups = freezed,
    Object? difficulty = freezed,
    Object? instructions = freezed,
    Object? imageUrl = freezed,
    Object? isFavorite = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            equipment: freezed == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryMuscleGroups: freezed == primaryMuscleGroups
                ? _value.primaryMuscleGroups
                : primaryMuscleGroups // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            secondaryMuscleGroups: freezed == secondaryMuscleGroups
                ? _value.secondaryMuscleGroups
                : secondaryMuscleGroups // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            difficulty: freezed == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String?,
            instructions: freezed == instructions
                ? _value.instructions
                : instructions // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFavorite: freezed == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseDatabaseImplCopyWith<$Res>
    implements $ExerciseDatabaseCopyWith<$Res> {
  factory _$$ExerciseDatabaseImplCopyWith(
    _$ExerciseDatabaseImpl value,
    $Res Function(_$ExerciseDatabaseImpl) then,
  ) = __$$ExerciseDatabaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? category,
    String? equipment,
    List<String>? primaryMuscleGroups,
    List<String>? secondaryMuscleGroups,
    String? difficulty,
    String? instructions,
    String? imageUrl,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ExerciseDatabaseImplCopyWithImpl<$Res>
    extends _$ExerciseDatabaseCopyWithImpl<$Res, _$ExerciseDatabaseImpl>
    implements _$$ExerciseDatabaseImplCopyWith<$Res> {
  __$$ExerciseDatabaseImplCopyWithImpl(
    _$ExerciseDatabaseImpl _value,
    $Res Function(_$ExerciseDatabaseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseDatabase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? equipment = freezed,
    Object? primaryMuscleGroups = freezed,
    Object? secondaryMuscleGroups = freezed,
    Object? difficulty = freezed,
    Object? instructions = freezed,
    Object? imageUrl = freezed,
    Object? isFavorite = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ExerciseDatabaseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        equipment: freezed == equipment
            ? _value.equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryMuscleGroups: freezed == primaryMuscleGroups
            ? _value._primaryMuscleGroups
            : primaryMuscleGroups // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        secondaryMuscleGroups: freezed == secondaryMuscleGroups
            ? _value._secondaryMuscleGroups
            : secondaryMuscleGroups // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        difficulty: freezed == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String?,
        instructions: freezed == instructions
            ? _value.instructions
            : instructions // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFavorite: freezed == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseDatabaseImpl implements _ExerciseDatabase {
  const _$ExerciseDatabaseImpl({
    required this.id,
    required this.name,
    this.category,
    this.equipment,
    final List<String>? primaryMuscleGroups,
    final List<String>? secondaryMuscleGroups,
    this.difficulty,
    this.instructions,
    this.imageUrl,
    this.isFavorite,
    final Map<String, dynamic>? metadata,
  }) : _primaryMuscleGroups = primaryMuscleGroups,
       _secondaryMuscleGroups = secondaryMuscleGroups,
       _metadata = metadata;

  factory _$ExerciseDatabaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseDatabaseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? category;
  @override
  final String? equipment;
  final List<String>? _primaryMuscleGroups;
  @override
  List<String>? get primaryMuscleGroups {
    final value = _primaryMuscleGroups;
    if (value == null) return null;
    if (_primaryMuscleGroups is EqualUnmodifiableListView)
      return _primaryMuscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _secondaryMuscleGroups;
  @override
  List<String>? get secondaryMuscleGroups {
    final value = _secondaryMuscleGroups;
    if (value == null) return null;
    if (_secondaryMuscleGroups is EqualUnmodifiableListView)
      return _secondaryMuscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? difficulty;
  @override
  final String? instructions;
  @override
  final String? imageUrl;
  @override
  final bool? isFavorite;
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
  String toString() {
    return 'ExerciseDatabase(id: $id, name: $name, category: $category, equipment: $equipment, primaryMuscleGroups: $primaryMuscleGroups, secondaryMuscleGroups: $secondaryMuscleGroups, difficulty: $difficulty, instructions: $instructions, imageUrl: $imageUrl, isFavorite: $isFavorite, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseDatabaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            const DeepCollectionEquality().equals(
              other._primaryMuscleGroups,
              _primaryMuscleGroups,
            ) &&
            const DeepCollectionEquality().equals(
              other._secondaryMuscleGroups,
              _secondaryMuscleGroups,
            ) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    equipment,
    const DeepCollectionEquality().hash(_primaryMuscleGroups),
    const DeepCollectionEquality().hash(_secondaryMuscleGroups),
    difficulty,
    instructions,
    imageUrl,
    isFavorite,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ExerciseDatabase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseDatabaseImplCopyWith<_$ExerciseDatabaseImpl> get copyWith =>
      __$$ExerciseDatabaseImplCopyWithImpl<_$ExerciseDatabaseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseDatabaseImplToJson(this);
  }
}

abstract class _ExerciseDatabase implements ExerciseDatabase {
  const factory _ExerciseDatabase({
    required final String id,
    required final String name,
    final String? category,
    final String? equipment,
    final List<String>? primaryMuscleGroups,
    final List<String>? secondaryMuscleGroups,
    final String? difficulty,
    final String? instructions,
    final String? imageUrl,
    final bool? isFavorite,
    final Map<String, dynamic>? metadata,
  }) = _$ExerciseDatabaseImpl;

  factory _ExerciseDatabase.fromJson(Map<String, dynamic> json) =
      _$ExerciseDatabaseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get category;
  @override
  String? get equipment;
  @override
  List<String>? get primaryMuscleGroups;
  @override
  List<String>? get secondaryMuscleGroups;
  @override
  String? get difficulty;
  @override
  String? get instructions;
  @override
  String? get imageUrl;
  @override
  bool? get isFavorite;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ExerciseDatabase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseDatabaseImplCopyWith<_$ExerciseDatabaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
