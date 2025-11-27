// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExercisePreferencesModel _$ExercisePreferencesModelFromJson(
  Map<String, dynamic> json,
) {
  return _ExercisePreferencesModel.fromJson(json);
}

/// @nodoc
mixin _$ExercisePreferencesModel {
  /// Set of exercise names marked as favorite
  ///
  /// Stored as List in Firestore, converted to Set for O(1) lookup
  List<String> get favorites => throw _privateConstructorUsedError;

  /// Timestamp of last update
  ///
  /// Used for sync conflict resolution and cache invalidation
  @TimestampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this ExercisePreferencesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExercisePreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExercisePreferencesModelCopyWith<ExercisePreferencesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExercisePreferencesModelCopyWith<$Res> {
  factory $ExercisePreferencesModelCopyWith(
    ExercisePreferencesModel value,
    $Res Function(ExercisePreferencesModel) then,
  ) = _$ExercisePreferencesModelCopyWithImpl<$Res, ExercisePreferencesModel>;
  @useResult
  $Res call({
    List<String> favorites,
    @TimestampConverter() DateTime? lastUpdated,
  });
}

/// @nodoc
class _$ExercisePreferencesModelCopyWithImpl<
  $Res,
  $Val extends ExercisePreferencesModel
>
    implements $ExercisePreferencesModelCopyWith<$Res> {
  _$ExercisePreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExercisePreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? favorites = null, Object? lastUpdated = freezed}) {
    return _then(
      _value.copyWith(
            favorites: null == favorites
                ? _value.favorites
                : favorites // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExercisePreferencesModelImplCopyWith<$Res>
    implements $ExercisePreferencesModelCopyWith<$Res> {
  factory _$$ExercisePreferencesModelImplCopyWith(
    _$ExercisePreferencesModelImpl value,
    $Res Function(_$ExercisePreferencesModelImpl) then,
  ) = __$$ExercisePreferencesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> favorites,
    @TimestampConverter() DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$ExercisePreferencesModelImplCopyWithImpl<$Res>
    extends
        _$ExercisePreferencesModelCopyWithImpl<
          $Res,
          _$ExercisePreferencesModelImpl
        >
    implements _$$ExercisePreferencesModelImplCopyWith<$Res> {
  __$$ExercisePreferencesModelImplCopyWithImpl(
    _$ExercisePreferencesModelImpl _value,
    $Res Function(_$ExercisePreferencesModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExercisePreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? favorites = null, Object? lastUpdated = freezed}) {
    return _then(
      _$ExercisePreferencesModelImpl(
        favorites: null == favorites
            ? _value._favorites
            : favorites // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExercisePreferencesModelImpl extends _ExercisePreferencesModel {
  const _$ExercisePreferencesModelImpl({
    final List<String> favorites = const [],
    @TimestampConverter() this.lastUpdated,
  }) : _favorites = favorites,
       super._();

  factory _$ExercisePreferencesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExercisePreferencesModelImplFromJson(json);

  /// Set of exercise names marked as favorite
  ///
  /// Stored as List in Firestore, converted to Set for O(1) lookup
  final List<String> _favorites;

  /// Set of exercise names marked as favorite
  ///
  /// Stored as List in Firestore, converted to Set for O(1) lookup
  @override
  @JsonKey()
  List<String> get favorites {
    if (_favorites is EqualUnmodifiableListView) return _favorites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favorites);
  }

  /// Timestamp of last update
  ///
  /// Used for sync conflict resolution and cache invalidation
  @override
  @TimestampConverter()
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'ExercisePreferencesModel(favorites: $favorites, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExercisePreferencesModelImpl &&
            const DeepCollectionEquality().equals(
              other._favorites,
              _favorites,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_favorites),
    lastUpdated,
  );

  /// Create a copy of ExercisePreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExercisePreferencesModelImplCopyWith<_$ExercisePreferencesModelImpl>
  get copyWith =>
      __$$ExercisePreferencesModelImplCopyWithImpl<
        _$ExercisePreferencesModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExercisePreferencesModelImplToJson(this);
  }
}

abstract class _ExercisePreferencesModel extends ExercisePreferencesModel {
  const factory _ExercisePreferencesModel({
    final List<String> favorites,
    @TimestampConverter() final DateTime? lastUpdated,
  }) = _$ExercisePreferencesModelImpl;
  const _ExercisePreferencesModel._() : super._();

  factory _ExercisePreferencesModel.fromJson(Map<String, dynamic> json) =
      _$ExercisePreferencesModelImpl.fromJson;

  /// Set of exercise names marked as favorite
  ///
  /// Stored as List in Firestore, converted to Set for O(1) lookup
  @override
  List<String> get favorites;

  /// Timestamp of last update
  ///
  /// Used for sync conflict resolution and cache invalidation
  @override
  @TimestampConverter()
  DateTime? get lastUpdated;

  /// Create a copy of ExercisePreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExercisePreferencesModelImplCopyWith<_$ExercisePreferencesModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
