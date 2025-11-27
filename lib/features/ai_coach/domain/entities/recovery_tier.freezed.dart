// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recovery_tier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecoveryTierConfig _$RecoveryTierConfigFromJson(Map<String, dynamic> json) {
  return _RecoveryTierConfig.fromJson(json);
}

/// @nodoc
mixin _$RecoveryTierConfig {
  /// The tier this configuration applies to
  RecoveryTier get tier => throw _privateConstructorUsedError;

  /// Minimum number of workouts required to unlock
  ///
  /// **Values**:
  /// - Basic: 6 workouts
  /// - Intermediate: 12 workouts
  /// - Advanced: 20 workouts
  int get minWorkouts => throw _privateConstructorUsedError;

  /// Minimum days of data required to unlock
  ///
  /// **Values**:
  /// - Basic: 14 days
  /// - Intermediate: 28 days
  /// - Advanced: 42 days
  int get minDays => throw _privateConstructorUsedError;

  /// Serializes this RecoveryTierConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecoveryTierConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecoveryTierConfigCopyWith<RecoveryTierConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecoveryTierConfigCopyWith<$Res> {
  factory $RecoveryTierConfigCopyWith(
    RecoveryTierConfig value,
    $Res Function(RecoveryTierConfig) then,
  ) = _$RecoveryTierConfigCopyWithImpl<$Res, RecoveryTierConfig>;
  @useResult
  $Res call({RecoveryTier tier, int minWorkouts, int minDays});
}

/// @nodoc
class _$RecoveryTierConfigCopyWithImpl<$Res, $Val extends RecoveryTierConfig>
    implements $RecoveryTierConfigCopyWith<$Res> {
  _$RecoveryTierConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecoveryTierConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? minWorkouts = null,
    Object? minDays = null,
  }) {
    return _then(
      _value.copyWith(
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as RecoveryTier,
            minWorkouts: null == minWorkouts
                ? _value.minWorkouts
                : minWorkouts // ignore: cast_nullable_to_non_nullable
                      as int,
            minDays: null == minDays
                ? _value.minDays
                : minDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecoveryTierConfigImplCopyWith<$Res>
    implements $RecoveryTierConfigCopyWith<$Res> {
  factory _$$RecoveryTierConfigImplCopyWith(
    _$RecoveryTierConfigImpl value,
    $Res Function(_$RecoveryTierConfigImpl) then,
  ) = __$$RecoveryTierConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RecoveryTier tier, int minWorkouts, int minDays});
}

/// @nodoc
class __$$RecoveryTierConfigImplCopyWithImpl<$Res>
    extends _$RecoveryTierConfigCopyWithImpl<$Res, _$RecoveryTierConfigImpl>
    implements _$$RecoveryTierConfigImplCopyWith<$Res> {
  __$$RecoveryTierConfigImplCopyWithImpl(
    _$RecoveryTierConfigImpl _value,
    $Res Function(_$RecoveryTierConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecoveryTierConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? minWorkouts = null,
    Object? minDays = null,
  }) {
    return _then(
      _$RecoveryTierConfigImpl(
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as RecoveryTier,
        minWorkouts: null == minWorkouts
            ? _value.minWorkouts
            : minWorkouts // ignore: cast_nullable_to_non_nullable
                  as int,
        minDays: null == minDays
            ? _value.minDays
            : minDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecoveryTierConfigImpl implements _RecoveryTierConfig {
  const _$RecoveryTierConfigImpl({
    required this.tier,
    required this.minWorkouts,
    required this.minDays,
  });

  factory _$RecoveryTierConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecoveryTierConfigImplFromJson(json);

  /// The tier this configuration applies to
  @override
  final RecoveryTier tier;

  /// Minimum number of workouts required to unlock
  ///
  /// **Values**:
  /// - Basic: 6 workouts
  /// - Intermediate: 12 workouts
  /// - Advanced: 20 workouts
  @override
  final int minWorkouts;

  /// Minimum days of data required to unlock
  ///
  /// **Values**:
  /// - Basic: 14 days
  /// - Intermediate: 28 days
  /// - Advanced: 42 days
  @override
  final int minDays;

  @override
  String toString() {
    return 'RecoveryTierConfig(tier: $tier, minWorkouts: $minWorkouts, minDays: $minDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecoveryTierConfigImpl &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.minWorkouts, minWorkouts) ||
                other.minWorkouts == minWorkouts) &&
            (identical(other.minDays, minDays) || other.minDays == minDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tier, minWorkouts, minDays);

  /// Create a copy of RecoveryTierConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecoveryTierConfigImplCopyWith<_$RecoveryTierConfigImpl> get copyWith =>
      __$$RecoveryTierConfigImplCopyWithImpl<_$RecoveryTierConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecoveryTierConfigImplToJson(this);
  }
}

abstract class _RecoveryTierConfig implements RecoveryTierConfig {
  const factory _RecoveryTierConfig({
    required final RecoveryTier tier,
    required final int minWorkouts,
    required final int minDays,
  }) = _$RecoveryTierConfigImpl;

  factory _RecoveryTierConfig.fromJson(Map<String, dynamic> json) =
      _$RecoveryTierConfigImpl.fromJson;

  /// The tier this configuration applies to
  @override
  RecoveryTier get tier;

  /// Minimum number of workouts required to unlock
  ///
  /// **Values**:
  /// - Basic: 6 workouts
  /// - Intermediate: 12 workouts
  /// - Advanced: 20 workouts
  @override
  int get minWorkouts;

  /// Minimum days of data required to unlock
  ///
  /// **Values**:
  /// - Basic: 14 days
  /// - Intermediate: 28 days
  /// - Advanced: 42 days
  @override
  int get minDays;

  /// Create a copy of RecoveryTierConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecoveryTierConfigImplCopyWith<_$RecoveryTierConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecoveryTierStatus _$RecoveryTierStatusFromJson(Map<String, dynamic> json) {
  return _RecoveryTierStatus.fromJson(json);
}

/// @nodoc
mixin _$RecoveryTierStatus {
  /// The tier this status applies to
  RecoveryTier get tier => throw _privateConstructorUsedError;

  /// Whether the tier is currently unlocked
  bool get isUnlocked => throw _privateConstructorUsedError;

  /// Current number of workouts user has logged
  int get currentWorkouts => throw _privateConstructorUsedError;

  /// Current number of days since user started tracking
  int get currentDays => throw _privateConstructorUsedError;

  /// Configuration defining unlock requirements
  RecoveryTierConfig get config => throw _privateConstructorUsedError;

  /// Optional: Timestamp when tier was unlocked
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  /// Serializes this RecoveryTierStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecoveryTierStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecoveryTierStatusCopyWith<RecoveryTierStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecoveryTierStatusCopyWith<$Res> {
  factory $RecoveryTierStatusCopyWith(
    RecoveryTierStatus value,
    $Res Function(RecoveryTierStatus) then,
  ) = _$RecoveryTierStatusCopyWithImpl<$Res, RecoveryTierStatus>;
  @useResult
  $Res call({
    RecoveryTier tier,
    bool isUnlocked,
    int currentWorkouts,
    int currentDays,
    RecoveryTierConfig config,
    DateTime? unlockedAt,
  });

  $RecoveryTierConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$RecoveryTierStatusCopyWithImpl<$Res, $Val extends RecoveryTierStatus>
    implements $RecoveryTierStatusCopyWith<$Res> {
  _$RecoveryTierStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecoveryTierStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? isUnlocked = null,
    Object? currentWorkouts = null,
    Object? currentDays = null,
    Object? config = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as RecoveryTier,
            isUnlocked: null == isUnlocked
                ? _value.isUnlocked
                : isUnlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentWorkouts: null == currentWorkouts
                ? _value.currentWorkouts
                : currentWorkouts // ignore: cast_nullable_to_non_nullable
                      as int,
            currentDays: null == currentDays
                ? _value.currentDays
                : currentDays // ignore: cast_nullable_to_non_nullable
                      as int,
            config: null == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as RecoveryTierConfig,
            unlockedAt: freezed == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of RecoveryTierStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecoveryTierConfigCopyWith<$Res> get config {
    return $RecoveryTierConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecoveryTierStatusImplCopyWith<$Res>
    implements $RecoveryTierStatusCopyWith<$Res> {
  factory _$$RecoveryTierStatusImplCopyWith(
    _$RecoveryTierStatusImpl value,
    $Res Function(_$RecoveryTierStatusImpl) then,
  ) = __$$RecoveryTierStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RecoveryTier tier,
    bool isUnlocked,
    int currentWorkouts,
    int currentDays,
    RecoveryTierConfig config,
    DateTime? unlockedAt,
  });

  @override
  $RecoveryTierConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$RecoveryTierStatusImplCopyWithImpl<$Res>
    extends _$RecoveryTierStatusCopyWithImpl<$Res, _$RecoveryTierStatusImpl>
    implements _$$RecoveryTierStatusImplCopyWith<$Res> {
  __$$RecoveryTierStatusImplCopyWithImpl(
    _$RecoveryTierStatusImpl _value,
    $Res Function(_$RecoveryTierStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecoveryTierStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tier = null,
    Object? isUnlocked = null,
    Object? currentWorkouts = null,
    Object? currentDays = null,
    Object? config = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(
      _$RecoveryTierStatusImpl(
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as RecoveryTier,
        isUnlocked: null == isUnlocked
            ? _value.isUnlocked
            : isUnlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentWorkouts: null == currentWorkouts
            ? _value.currentWorkouts
            : currentWorkouts // ignore: cast_nullable_to_non_nullable
                  as int,
        currentDays: null == currentDays
            ? _value.currentDays
            : currentDays // ignore: cast_nullable_to_non_nullable
                  as int,
        config: null == config
            ? _value.config
            : config // ignore: cast_nullable_to_non_nullable
                  as RecoveryTierConfig,
        unlockedAt: freezed == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecoveryTierStatusImpl extends _RecoveryTierStatus {
  const _$RecoveryTierStatusImpl({
    required this.tier,
    required this.isUnlocked,
    required this.currentWorkouts,
    required this.currentDays,
    required this.config,
    this.unlockedAt,
  }) : super._();

  factory _$RecoveryTierStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecoveryTierStatusImplFromJson(json);

  /// The tier this status applies to
  @override
  final RecoveryTier tier;

  /// Whether the tier is currently unlocked
  @override
  final bool isUnlocked;

  /// Current number of workouts user has logged
  @override
  final int currentWorkouts;

  /// Current number of days since user started tracking
  @override
  final int currentDays;

  /// Configuration defining unlock requirements
  @override
  final RecoveryTierConfig config;

  /// Optional: Timestamp when tier was unlocked
  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'RecoveryTierStatus(tier: $tier, isUnlocked: $isUnlocked, currentWorkouts: $currentWorkouts, currentDays: $currentDays, config: $config, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecoveryTierStatusImpl &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.currentWorkouts, currentWorkouts) ||
                other.currentWorkouts == currentWorkouts) &&
            (identical(other.currentDays, currentDays) ||
                other.currentDays == currentDays) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tier,
    isUnlocked,
    currentWorkouts,
    currentDays,
    config,
    unlockedAt,
  );

  /// Create a copy of RecoveryTierStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecoveryTierStatusImplCopyWith<_$RecoveryTierStatusImpl> get copyWith =>
      __$$RecoveryTierStatusImplCopyWithImpl<_$RecoveryTierStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecoveryTierStatusImplToJson(this);
  }
}

abstract class _RecoveryTierStatus extends RecoveryTierStatus {
  const factory _RecoveryTierStatus({
    required final RecoveryTier tier,
    required final bool isUnlocked,
    required final int currentWorkouts,
    required final int currentDays,
    required final RecoveryTierConfig config,
    final DateTime? unlockedAt,
  }) = _$RecoveryTierStatusImpl;
  const _RecoveryTierStatus._() : super._();

  factory _RecoveryTierStatus.fromJson(Map<String, dynamic> json) =
      _$RecoveryTierStatusImpl.fromJson;

  /// The tier this status applies to
  @override
  RecoveryTier get tier;

  /// Whether the tier is currently unlocked
  @override
  bool get isUnlocked;

  /// Current number of workouts user has logged
  @override
  int get currentWorkouts;

  /// Current number of days since user started tracking
  @override
  int get currentDays;

  /// Configuration defining unlock requirements
  @override
  RecoveryTierConfig get config;

  /// Optional: Timestamp when tier was unlocked
  @override
  DateTime? get unlockedAt;

  /// Create a copy of RecoveryTierStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecoveryTierStatusImplCopyWith<_$RecoveryTierStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
