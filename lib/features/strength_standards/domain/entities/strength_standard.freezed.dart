// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'strength_standard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StrengthStandard _$StrengthStandardFromJson(Map<String, dynamic> json) {
  return _StrengthStandard.fromJson(json);
}

/// @nodoc
mixin _$StrengthStandard {
  /// Unique identifier (e.g., "barbell_bench_press")
  String get id => throw _privateConstructorUsedError;

  /// Display name (e.g., "Barbell Bench Press")
  String get name => throw _privateConstructorUsedError;

  /// Search keywords for semantic matching (Italian + English)
  List<String> get keywords => throw _privateConstructorUsedError;

  /// Equipment type (e.g., "Bilanciere", "Manubri")
  String get equipment => throw _privateConstructorUsedError;

  /// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
  List<String> get muscleGroups => throw _privateConstructorUsedError;

  /// Data source identifier (e.g., "exrx_net", "estimated_from_benchmarks")
  String get dataSource => throw _privateConstructorUsedError;

  /// Bodyweight table: kg → level → 1RM (kg)
  /// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
  Map<String, Map<String, double>> get bodyweightTable =>
      throw _privateConstructorUsedError;

  /// Bodyweight multipliers: level → multiplier
  /// Example: {"novice": 0.93, "intermediate": 1.13}
  Map<String, double> get bodyweightMultipliers =>
      throw _privateConstructorUsedError;

  /// Whether this is bodyweight exercise (reps-based instead of weight)
  bool get isBodyweightExercise => throw _privateConstructorUsedError;

  /// Serializes this StrengthStandard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StrengthStandard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrengthStandardCopyWith<StrengthStandard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrengthStandardCopyWith<$Res> {
  factory $StrengthStandardCopyWith(
    StrengthStandard value,
    $Res Function(StrengthStandard) then,
  ) = _$StrengthStandardCopyWithImpl<$Res, StrengthStandard>;
  @useResult
  $Res call({
    String id,
    String name,
    List<String> keywords,
    String equipment,
    List<String> muscleGroups,
    String dataSource,
    Map<String, Map<String, double>> bodyweightTable,
    Map<String, double> bodyweightMultipliers,
    bool isBodyweightExercise,
  });
}

/// @nodoc
class _$StrengthStandardCopyWithImpl<$Res, $Val extends StrengthStandard>
    implements $StrengthStandardCopyWith<$Res> {
  _$StrengthStandardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StrengthStandard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? keywords = null,
    Object? equipment = null,
    Object? muscleGroups = null,
    Object? dataSource = null,
    Object? bodyweightTable = null,
    Object? bodyweightMultipliers = null,
    Object? isBodyweightExercise = null,
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
            keywords: null == keywords
                ? _value.keywords
                : keywords // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            equipment: null == equipment
                ? _value.equipment
                : equipment // ignore: cast_nullable_to_non_nullable
                      as String,
            muscleGroups: null == muscleGroups
                ? _value.muscleGroups
                : muscleGroups // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dataSource: null == dataSource
                ? _value.dataSource
                : dataSource // ignore: cast_nullable_to_non_nullable
                      as String,
            bodyweightTable: null == bodyweightTable
                ? _value.bodyweightTable
                : bodyweightTable // ignore: cast_nullable_to_non_nullable
                      as Map<String, Map<String, double>>,
            bodyweightMultipliers: null == bodyweightMultipliers
                ? _value.bodyweightMultipliers
                : bodyweightMultipliers // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            isBodyweightExercise: null == isBodyweightExercise
                ? _value.isBodyweightExercise
                : isBodyweightExercise // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrengthStandardImplCopyWith<$Res>
    implements $StrengthStandardCopyWith<$Res> {
  factory _$$StrengthStandardImplCopyWith(
    _$StrengthStandardImpl value,
    $Res Function(_$StrengthStandardImpl) then,
  ) = __$$StrengthStandardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<String> keywords,
    String equipment,
    List<String> muscleGroups,
    String dataSource,
    Map<String, Map<String, double>> bodyweightTable,
    Map<String, double> bodyweightMultipliers,
    bool isBodyweightExercise,
  });
}

/// @nodoc
class __$$StrengthStandardImplCopyWithImpl<$Res>
    extends _$StrengthStandardCopyWithImpl<$Res, _$StrengthStandardImpl>
    implements _$$StrengthStandardImplCopyWith<$Res> {
  __$$StrengthStandardImplCopyWithImpl(
    _$StrengthStandardImpl _value,
    $Res Function(_$StrengthStandardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StrengthStandard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? keywords = null,
    Object? equipment = null,
    Object? muscleGroups = null,
    Object? dataSource = null,
    Object? bodyweightTable = null,
    Object? bodyweightMultipliers = null,
    Object? isBodyweightExercise = null,
  }) {
    return _then(
      _$StrengthStandardImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        keywords: null == keywords
            ? _value._keywords
            : keywords // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        equipment: null == equipment
            ? _value.equipment
            : equipment // ignore: cast_nullable_to_non_nullable
                  as String,
        muscleGroups: null == muscleGroups
            ? _value._muscleGroups
            : muscleGroups // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dataSource: null == dataSource
            ? _value.dataSource
            : dataSource // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyweightTable: null == bodyweightTable
            ? _value._bodyweightTable
            : bodyweightTable // ignore: cast_nullable_to_non_nullable
                  as Map<String, Map<String, double>>,
        bodyweightMultipliers: null == bodyweightMultipliers
            ? _value._bodyweightMultipliers
            : bodyweightMultipliers // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        isBodyweightExercise: null == isBodyweightExercise
            ? _value.isBodyweightExercise
            : isBodyweightExercise // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StrengthStandardImpl implements _StrengthStandard {
  const _$StrengthStandardImpl({
    required this.id,
    required this.name,
    required final List<String> keywords,
    required this.equipment,
    required final List<String> muscleGroups,
    required this.dataSource,
    required final Map<String, Map<String, double>> bodyweightTable,
    required final Map<String, double> bodyweightMultipliers,
    this.isBodyweightExercise = false,
  }) : _keywords = keywords,
       _muscleGroups = muscleGroups,
       _bodyweightTable = bodyweightTable,
       _bodyweightMultipliers = bodyweightMultipliers;

  factory _$StrengthStandardImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrengthStandardImplFromJson(json);

  /// Unique identifier (e.g., "barbell_bench_press")
  @override
  final String id;

  /// Display name (e.g., "Barbell Bench Press")
  @override
  final String name;

  /// Search keywords for semantic matching (Italian + English)
  final List<String> _keywords;

  /// Search keywords for semantic matching (Italian + English)
  @override
  List<String> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  /// Equipment type (e.g., "Bilanciere", "Manubri")
  @override
  final String equipment;

  /// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
  final List<String> _muscleGroups;

  /// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
  @override
  List<String> get muscleGroups {
    if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscleGroups);
  }

  /// Data source identifier (e.g., "exrx_net", "estimated_from_benchmarks")
  @override
  final String dataSource;

  /// Bodyweight table: kg → level → 1RM (kg)
  /// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
  final Map<String, Map<String, double>> _bodyweightTable;

  /// Bodyweight table: kg → level → 1RM (kg)
  /// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
  @override
  Map<String, Map<String, double>> get bodyweightTable {
    if (_bodyweightTable is EqualUnmodifiableMapView) return _bodyweightTable;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bodyweightTable);
  }

  /// Bodyweight multipliers: level → multiplier
  /// Example: {"novice": 0.93, "intermediate": 1.13}
  final Map<String, double> _bodyweightMultipliers;

  /// Bodyweight multipliers: level → multiplier
  /// Example: {"novice": 0.93, "intermediate": 1.13}
  @override
  Map<String, double> get bodyweightMultipliers {
    if (_bodyweightMultipliers is EqualUnmodifiableMapView)
      return _bodyweightMultipliers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bodyweightMultipliers);
  }

  /// Whether this is bodyweight exercise (reps-based instead of weight)
  @override
  @JsonKey()
  final bool isBodyweightExercise;

  @override
  String toString() {
    return 'StrengthStandard(id: $id, name: $name, keywords: $keywords, equipment: $equipment, muscleGroups: $muscleGroups, dataSource: $dataSource, bodyweightTable: $bodyweightTable, bodyweightMultipliers: $bodyweightMultipliers, isBodyweightExercise: $isBodyweightExercise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrengthStandardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            const DeepCollectionEquality().equals(
              other._muscleGroups,
              _muscleGroups,
            ) &&
            (identical(other.dataSource, dataSource) ||
                other.dataSource == dataSource) &&
            const DeepCollectionEquality().equals(
              other._bodyweightTable,
              _bodyweightTable,
            ) &&
            const DeepCollectionEquality().equals(
              other._bodyweightMultipliers,
              _bodyweightMultipliers,
            ) &&
            (identical(other.isBodyweightExercise, isBodyweightExercise) ||
                other.isBodyweightExercise == isBodyweightExercise));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_keywords),
    equipment,
    const DeepCollectionEquality().hash(_muscleGroups),
    dataSource,
    const DeepCollectionEquality().hash(_bodyweightTable),
    const DeepCollectionEquality().hash(_bodyweightMultipliers),
    isBodyweightExercise,
  );

  /// Create a copy of StrengthStandard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrengthStandardImplCopyWith<_$StrengthStandardImpl> get copyWith =>
      __$$StrengthStandardImplCopyWithImpl<_$StrengthStandardImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StrengthStandardImplToJson(this);
  }
}

abstract class _StrengthStandard implements StrengthStandard {
  const factory _StrengthStandard({
    required final String id,
    required final String name,
    required final List<String> keywords,
    required final String equipment,
    required final List<String> muscleGroups,
    required final String dataSource,
    required final Map<String, Map<String, double>> bodyweightTable,
    required final Map<String, double> bodyweightMultipliers,
    final bool isBodyweightExercise,
  }) = _$StrengthStandardImpl;

  factory _StrengthStandard.fromJson(Map<String, dynamic> json) =
      _$StrengthStandardImpl.fromJson;

  /// Unique identifier (e.g., "barbell_bench_press")
  @override
  String get id;

  /// Display name (e.g., "Barbell Bench Press")
  @override
  String get name;

  /// Search keywords for semantic matching (Italian + English)
  @override
  List<String> get keywords;

  /// Equipment type (e.g., "Bilanciere", "Manubri")
  @override
  String get equipment;

  /// Target muscle groups (codes + full names, e.g., ["PETT", "Pectorals"])
  @override
  List<String> get muscleGroups;

  /// Data source identifier (e.g., "exrx_net", "estimated_from_benchmarks")
  @override
  String get dataSource;

  /// Bodyweight table: kg → level → 1RM (kg)
  /// Example: {"60": {"novice": 57.5, "intermediate": 70.0}}
  @override
  Map<String, Map<String, double>> get bodyweightTable;

  /// Bodyweight multipliers: level → multiplier
  /// Example: {"novice": 0.93, "intermediate": 1.13}
  @override
  Map<String, double> get bodyweightMultipliers;

  /// Whether this is bodyweight exercise (reps-based instead of weight)
  @override
  bool get isBodyweightExercise;

  /// Create a copy of StrengthStandard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrengthStandardImplCopyWith<_$StrengthStandardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
