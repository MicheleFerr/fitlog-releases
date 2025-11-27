// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserContext _$UserContextFromJson(Map<String, dynamic> json) {
  return _UserContext.fromJson(json);
}

/// @nodoc
mixin _$UserContext {
  String get userId => throw _privateConstructorUsedError;
  ExperienceLevel get experienceLevel => throw _privateConstructorUsedError;
  TrainingGoal get primaryGoal => throw _privateConstructorUsedError;
  int get weeklyAvailability =>
      throw _privateConstructorUsedError; // Number of workout days per week
  List<String>? get injuryHistory => throw _privateConstructorUsedError;
  List<String>? get preferredExercises => throw _privateConstructorUsedError;

  /// Serializes this UserContext to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserContextCopyWith<UserContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserContextCopyWith<$Res> {
  factory $UserContextCopyWith(
    UserContext value,
    $Res Function(UserContext) then,
  ) = _$UserContextCopyWithImpl<$Res, UserContext>;
  @useResult
  $Res call({
    String userId,
    ExperienceLevel experienceLevel,
    TrainingGoal primaryGoal,
    int weeklyAvailability,
    List<String>? injuryHistory,
    List<String>? preferredExercises,
  });
}

/// @nodoc
class _$UserContextCopyWithImpl<$Res, $Val extends UserContext>
    implements $UserContextCopyWith<$Res> {
  _$UserContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? experienceLevel = null,
    Object? primaryGoal = null,
    Object? weeklyAvailability = null,
    Object? injuryHistory = freezed,
    Object? preferredExercises = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            experienceLevel: null == experienceLevel
                ? _value.experienceLevel
                : experienceLevel // ignore: cast_nullable_to_non_nullable
                      as ExperienceLevel,
            primaryGoal: null == primaryGoal
                ? _value.primaryGoal
                : primaryGoal // ignore: cast_nullable_to_non_nullable
                      as TrainingGoal,
            weeklyAvailability: null == weeklyAvailability
                ? _value.weeklyAvailability
                : weeklyAvailability // ignore: cast_nullable_to_non_nullable
                      as int,
            injuryHistory: freezed == injuryHistory
                ? _value.injuryHistory
                : injuryHistory // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            preferredExercises: freezed == preferredExercises
                ? _value.preferredExercises
                : preferredExercises // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserContextImplCopyWith<$Res>
    implements $UserContextCopyWith<$Res> {
  factory _$$UserContextImplCopyWith(
    _$UserContextImpl value,
    $Res Function(_$UserContextImpl) then,
  ) = __$$UserContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    ExperienceLevel experienceLevel,
    TrainingGoal primaryGoal,
    int weeklyAvailability,
    List<String>? injuryHistory,
    List<String>? preferredExercises,
  });
}

/// @nodoc
class __$$UserContextImplCopyWithImpl<$Res>
    extends _$UserContextCopyWithImpl<$Res, _$UserContextImpl>
    implements _$$UserContextImplCopyWith<$Res> {
  __$$UserContextImplCopyWithImpl(
    _$UserContextImpl _value,
    $Res Function(_$UserContextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? experienceLevel = null,
    Object? primaryGoal = null,
    Object? weeklyAvailability = null,
    Object? injuryHistory = freezed,
    Object? preferredExercises = freezed,
  }) {
    return _then(
      _$UserContextImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        experienceLevel: null == experienceLevel
            ? _value.experienceLevel
            : experienceLevel // ignore: cast_nullable_to_non_nullable
                  as ExperienceLevel,
        primaryGoal: null == primaryGoal
            ? _value.primaryGoal
            : primaryGoal // ignore: cast_nullable_to_non_nullable
                  as TrainingGoal,
        weeklyAvailability: null == weeklyAvailability
            ? _value.weeklyAvailability
            : weeklyAvailability // ignore: cast_nullable_to_non_nullable
                  as int,
        injuryHistory: freezed == injuryHistory
            ? _value._injuryHistory
            : injuryHistory // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        preferredExercises: freezed == preferredExercises
            ? _value._preferredExercises
            : preferredExercises // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserContextImpl implements _UserContext {
  const _$UserContextImpl({
    required this.userId,
    required this.experienceLevel,
    required this.primaryGoal,
    required this.weeklyAvailability,
    final List<String>? injuryHistory,
    final List<String>? preferredExercises,
  }) : _injuryHistory = injuryHistory,
       _preferredExercises = preferredExercises;

  factory _$UserContextImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserContextImplFromJson(json);

  @override
  final String userId;
  @override
  final ExperienceLevel experienceLevel;
  @override
  final TrainingGoal primaryGoal;
  @override
  final int weeklyAvailability;
  // Number of workout days per week
  final List<String>? _injuryHistory;
  // Number of workout days per week
  @override
  List<String>? get injuryHistory {
    final value = _injuryHistory;
    if (value == null) return null;
    if (_injuryHistory is EqualUnmodifiableListView) return _injuryHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _preferredExercises;
  @override
  List<String>? get preferredExercises {
    final value = _preferredExercises;
    if (value == null) return null;
    if (_preferredExercises is EqualUnmodifiableListView)
      return _preferredExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'UserContext(userId: $userId, experienceLevel: $experienceLevel, primaryGoal: $primaryGoal, weeklyAvailability: $weeklyAvailability, injuryHistory: $injuryHistory, preferredExercises: $preferredExercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserContextImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.primaryGoal, primaryGoal) ||
                other.primaryGoal == primaryGoal) &&
            (identical(other.weeklyAvailability, weeklyAvailability) ||
                other.weeklyAvailability == weeklyAvailability) &&
            const DeepCollectionEquality().equals(
              other._injuryHistory,
              _injuryHistory,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredExercises,
              _preferredExercises,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    experienceLevel,
    primaryGoal,
    weeklyAvailability,
    const DeepCollectionEquality().hash(_injuryHistory),
    const DeepCollectionEquality().hash(_preferredExercises),
  );

  /// Create a copy of UserContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserContextImplCopyWith<_$UserContextImpl> get copyWith =>
      __$$UserContextImplCopyWithImpl<_$UserContextImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserContextImplToJson(this);
  }
}

abstract class _UserContext implements UserContext {
  const factory _UserContext({
    required final String userId,
    required final ExperienceLevel experienceLevel,
    required final TrainingGoal primaryGoal,
    required final int weeklyAvailability,
    final List<String>? injuryHistory,
    final List<String>? preferredExercises,
  }) = _$UserContextImpl;

  factory _UserContext.fromJson(Map<String, dynamic> json) =
      _$UserContextImpl.fromJson;

  @override
  String get userId;
  @override
  ExperienceLevel get experienceLevel;
  @override
  TrainingGoal get primaryGoal;
  @override
  int get weeklyAvailability; // Number of workout days per week
  @override
  List<String>? get injuryHistory;
  @override
  List<String>? get preferredExercises;

  /// Create a copy of UserContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserContextImplCopyWith<_$UserContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
