// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flexible_routine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FlexibleRoutine _$FlexibleRoutineFromJson(Map<String, dynamic> json) {
  return _FlexibleRoutine.fromJson(json);
}

/// @nodoc
mixin _$FlexibleRoutine {
  /// Unique routine identifier (Firestore document ID)
  String get id => throw _privateConstructorUsedError;

  /// User who owns this routine (for multi-user support)
  String get userId => throw _privateConstructorUsedError;

  /// Routine name (user-defined, e.g., "My PPL Routine")
  String get name => throw _privateConstructorUsedError;

  /// Optional description/notes
  String get description => throw _privateConstructorUsedError;

  /// Preset type (ppl6Day, upperLower4Day, etc.)
  /// Determines default training days and template suggestions
  RoutinePreset get presetType => throw _privateConstructorUsedError;

  /// Training days as Set of weekday integers
  /// Monday = 1, Sunday = 7
  /// Example: {1, 2, 3, 4, 5, 6} for 6-day routine
  Set<int> get trainingDays => throw _privateConstructorUsedError;

  /// Workout schedule mapping day → template ID
  /// Key: weekday (1-7), Value: template ID (Firestore ref)
  /// Example: {1: "template_123", 2: "template_456", ...}
  Map<int, String> get workoutSchedule => throw _privateConstructorUsedError;

  /// Whether this routine is currently active
  /// Only one routine can be active per user at a time
  bool get isActive => throw _privateConstructorUsedError;

  /// Completed workout days (ISO 8601 date strings)
  /// Example: {"2025-01-20", "2025-01-22", ...}
  /// Used for streak tracking and analytics
  Set<String> get completedDays => throw _privateConstructorUsedError;

  /// Total number of workouts completed in this routine
  /// Incremented each time a workout is marked complete
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Routine creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp (modified whenever routine changes)
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FlexibleRoutineCopyWith<FlexibleRoutine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlexibleRoutineCopyWith<$Res> {
  factory $FlexibleRoutineCopyWith(
          FlexibleRoutine value, $Res Function(FlexibleRoutine) then) =
      _$FlexibleRoutineCopyWithImpl<$Res, FlexibleRoutine>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String description,
      RoutinePreset presetType,
      Set<int> trainingDays,
      Map<int, String> workoutSchedule,
      bool isActive,
      Set<String> completedDays,
      int totalWorkouts,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$FlexibleRoutineCopyWithImpl<$Res, $Val extends FlexibleRoutine>
    implements $FlexibleRoutineCopyWith<$Res> {
  _$FlexibleRoutineCopyWithImpl(this._value, this._then);

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
    Object? description = null,
    Object? presetType = null,
    Object? trainingDays = null,
    Object? workoutSchedule = null,
    Object? isActive = null,
    Object? completedDays = null,
    Object? totalWorkouts = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      presetType: null == presetType
          ? _value.presetType
          : presetType // ignore: cast_nullable_to_non_nullable
              as RoutinePreset,
      trainingDays: null == trainingDays
          ? _value.trainingDays
          : trainingDays // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      workoutSchedule: null == workoutSchedule
          ? _value.workoutSchedule
          : workoutSchedule // ignore: cast_nullable_to_non_nullable
              as Map<int, String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      completedDays: null == completedDays
          ? _value.completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FlexibleRoutineImplCopyWith<$Res>
    implements $FlexibleRoutineCopyWith<$Res> {
  factory _$$FlexibleRoutineImplCopyWith(_$FlexibleRoutineImpl value,
          $Res Function(_$FlexibleRoutineImpl) then) =
      __$$FlexibleRoutineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String description,
      RoutinePreset presetType,
      Set<int> trainingDays,
      Map<int, String> workoutSchedule,
      bool isActive,
      Set<String> completedDays,
      int totalWorkouts,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$FlexibleRoutineImplCopyWithImpl<$Res>
    extends _$FlexibleRoutineCopyWithImpl<$Res, _$FlexibleRoutineImpl>
    implements _$$FlexibleRoutineImplCopyWith<$Res> {
  __$$FlexibleRoutineImplCopyWithImpl(
      _$FlexibleRoutineImpl _value, $Res Function(_$FlexibleRoutineImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = null,
    Object? presetType = null,
    Object? trainingDays = null,
    Object? workoutSchedule = null,
    Object? isActive = null,
    Object? completedDays = null,
    Object? totalWorkouts = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$FlexibleRoutineImpl(
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      presetType: null == presetType
          ? _value.presetType
          : presetType // ignore: cast_nullable_to_non_nullable
              as RoutinePreset,
      trainingDays: null == trainingDays
          ? _value._trainingDays
          : trainingDays // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      workoutSchedule: null == workoutSchedule
          ? _value._workoutSchedule
          : workoutSchedule // ignore: cast_nullable_to_non_nullable
              as Map<int, String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      completedDays: null == completedDays
          ? _value._completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlexibleRoutineImpl implements _FlexibleRoutine {
  const _$FlexibleRoutineImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.description = '',
      required this.presetType,
      required final Set<int> trainingDays,
      required final Map<int, String> workoutSchedule,
      this.isActive = true,
      final Set<String> completedDays = const {},
      this.totalWorkouts = 0,
      required this.createdAt,
      required this.updatedAt})
      : _trainingDays = trainingDays,
        _workoutSchedule = workoutSchedule,
        _completedDays = completedDays;

  factory _$FlexibleRoutineImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlexibleRoutineImplFromJson(json);

  /// Unique routine identifier (Firestore document ID)
  @override
  final String id;

  /// User who owns this routine (for multi-user support)
  @override
  final String userId;

  /// Routine name (user-defined, e.g., "My PPL Routine")
  @override
  final String name;

  /// Optional description/notes
  @override
  @JsonKey()
  final String description;

  /// Preset type (ppl6Day, upperLower4Day, etc.)
  /// Determines default training days and template suggestions
  @override
  final RoutinePreset presetType;

  /// Training days as Set of weekday integers
  /// Monday = 1, Sunday = 7
  /// Example: {1, 2, 3, 4, 5, 6} for 6-day routine
  final Set<int> _trainingDays;

  /// Training days as Set of weekday integers
  /// Monday = 1, Sunday = 7
  /// Example: {1, 2, 3, 4, 5, 6} for 6-day routine
  @override
  Set<int> get trainingDays {
    if (_trainingDays is EqualUnmodifiableSetView) return _trainingDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_trainingDays);
  }

  /// Workout schedule mapping day → template ID
  /// Key: weekday (1-7), Value: template ID (Firestore ref)
  /// Example: {1: "template_123", 2: "template_456", ...}
  final Map<int, String> _workoutSchedule;

  /// Workout schedule mapping day → template ID
  /// Key: weekday (1-7), Value: template ID (Firestore ref)
  /// Example: {1: "template_123", 2: "template_456", ...}
  @override
  Map<int, String> get workoutSchedule {
    if (_workoutSchedule is EqualUnmodifiableMapView) return _workoutSchedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_workoutSchedule);
  }

  /// Whether this routine is currently active
  /// Only one routine can be active per user at a time
  @override
  @JsonKey()
  final bool isActive;

  /// Completed workout days (ISO 8601 date strings)
  /// Example: {"2025-01-20", "2025-01-22", ...}
  /// Used for streak tracking and analytics
  final Set<String> _completedDays;

  /// Completed workout days (ISO 8601 date strings)
  /// Example: {"2025-01-20", "2025-01-22", ...}
  /// Used for streak tracking and analytics
  @override
  @JsonKey()
  Set<String> get completedDays {
    if (_completedDays is EqualUnmodifiableSetView) return _completedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_completedDays);
  }

  /// Total number of workouts completed in this routine
  /// Incremented each time a workout is marked complete
  @override
  @JsonKey()
  final int totalWorkouts;

  /// Routine creation timestamp
  @override
  final DateTime createdAt;

  /// Last update timestamp (modified whenever routine changes)
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FlexibleRoutine(id: $id, userId: $userId, name: $name, description: $description, presetType: $presetType, trainingDays: $trainingDays, workoutSchedule: $workoutSchedule, isActive: $isActive, completedDays: $completedDays, totalWorkouts: $totalWorkouts, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlexibleRoutineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.presetType, presetType) ||
                other.presetType == presetType) &&
            const DeepCollectionEquality()
                .equals(other._trainingDays, _trainingDays) &&
            const DeepCollectionEquality()
                .equals(other._workoutSchedule, _workoutSchedule) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._completedDays, _completedDays) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
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
      userId,
      name,
      description,
      presetType,
      const DeepCollectionEquality().hash(_trainingDays),
      const DeepCollectionEquality().hash(_workoutSchedule),
      isActive,
      const DeepCollectionEquality().hash(_completedDays),
      totalWorkouts,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FlexibleRoutineImplCopyWith<_$FlexibleRoutineImpl> get copyWith =>
      __$$FlexibleRoutineImplCopyWithImpl<_$FlexibleRoutineImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlexibleRoutineImplToJson(
      this,
    );
  }
}

abstract class _FlexibleRoutine implements FlexibleRoutine {
  const factory _FlexibleRoutine(
      {required final String id,
      required final String userId,
      required final String name,
      final String description,
      required final RoutinePreset presetType,
      required final Set<int> trainingDays,
      required final Map<int, String> workoutSchedule,
      final bool isActive,
      final Set<String> completedDays,
      final int totalWorkouts,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$FlexibleRoutineImpl;

  factory _FlexibleRoutine.fromJson(Map<String, dynamic> json) =
      _$FlexibleRoutineImpl.fromJson;

  @override

  /// Unique routine identifier (Firestore document ID)
  String get id;
  @override

  /// User who owns this routine (for multi-user support)
  String get userId;
  @override

  /// Routine name (user-defined, e.g., "My PPL Routine")
  String get name;
  @override

  /// Optional description/notes
  String get description;
  @override

  /// Preset type (ppl6Day, upperLower4Day, etc.)
  /// Determines default training days and template suggestions
  RoutinePreset get presetType;
  @override

  /// Training days as Set of weekday integers
  /// Monday = 1, Sunday = 7
  /// Example: {1, 2, 3, 4, 5, 6} for 6-day routine
  Set<int> get trainingDays;
  @override

  /// Workout schedule mapping day → template ID
  /// Key: weekday (1-7), Value: template ID (Firestore ref)
  /// Example: {1: "template_123", 2: "template_456", ...}
  Map<int, String> get workoutSchedule;
  @override

  /// Whether this routine is currently active
  /// Only one routine can be active per user at a time
  bool get isActive;
  @override

  /// Completed workout days (ISO 8601 date strings)
  /// Example: {"2025-01-20", "2025-01-22", ...}
  /// Used for streak tracking and analytics
  Set<String> get completedDays;
  @override

  /// Total number of workouts completed in this routine
  /// Incremented each time a workout is marked complete
  int get totalWorkouts;
  @override

  /// Routine creation timestamp
  DateTime get createdAt;
  @override

  /// Last update timestamp (modified whenever routine changes)
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$FlexibleRoutineImplCopyWith<_$FlexibleRoutineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
