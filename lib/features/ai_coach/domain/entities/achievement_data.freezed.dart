// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AchievementData _$AchievementDataFromJson(Map<String, dynamic> json) {
  return _AchievementData.fromJson(json);
}

/// @nodoc
mixin _$AchievementData {
  /// Unique achievement identifier
  String get id => throw _privateConstructorUsedError;

  /// Display name (localization key)
  String get name => throw _privateConstructorUsedError;

  /// Description (localization key)
  String get description => throw _privateConstructorUsedError;

  /// Achievement category
  AchievementCategory get category => throw _privateConstructorUsedError;

  /// Rarity level
  AchievementRarity get rarity => throw _privateConstructorUsedError;

  /// Unlock condition description (localization key)
  String get conditionDescription => throw _privateConstructorUsedError;

  /// Icon identifier (maps to IconData)
  String get iconKey => throw _privateConstructorUsedError;

  /// Reward message shown on unlock (localization key)
  String get rewardMessage => throw _privateConstructorUsedError;

  /// Unlock timestamp (null if locked)
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  /// Progress towards unlock (0.0 - 1.0)
  double get progress => throw _privateConstructorUsedError;

  /// Whether achievement is hidden until unlocked
  bool get isHidden => throw _privateConstructorUsedError;

  /// Sort order for display
  int get sortOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AchievementDataCopyWith<AchievementData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementDataCopyWith<$Res> {
  factory $AchievementDataCopyWith(
          AchievementData value, $Res Function(AchievementData) then) =
      _$AchievementDataCopyWithImpl<$Res, AchievementData>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      AchievementCategory category,
      AchievementRarity rarity,
      String conditionDescription,
      String iconKey,
      String rewardMessage,
      DateTime? unlockedAt,
      double progress,
      bool isHidden,
      int sortOrder});
}

/// @nodoc
class _$AchievementDataCopyWithImpl<$Res, $Val extends AchievementData>
    implements $AchievementDataCopyWith<$Res> {
  _$AchievementDataCopyWithImpl(this._value, this._then);

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
    Object? rarity = null,
    Object? conditionDescription = null,
    Object? iconKey = null,
    Object? rewardMessage = null,
    Object? unlockedAt = freezed,
    Object? progress = null,
    Object? isHidden = null,
    Object? sortOrder = null,
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
              as AchievementCategory,
      rarity: null == rarity
          ? _value.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as AchievementRarity,
      conditionDescription: null == conditionDescription
          ? _value.conditionDescription
          : conditionDescription // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: null == iconKey
          ? _value.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String,
      rewardMessage: null == rewardMessage
          ? _value.rewardMessage
          : rewardMessage // ignore: cast_nullable_to_non_nullable
              as String,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementDataImplCopyWith<$Res>
    implements $AchievementDataCopyWith<$Res> {
  factory _$$AchievementDataImplCopyWith(_$AchievementDataImpl value,
          $Res Function(_$AchievementDataImpl) then) =
      __$$AchievementDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      AchievementCategory category,
      AchievementRarity rarity,
      String conditionDescription,
      String iconKey,
      String rewardMessage,
      DateTime? unlockedAt,
      double progress,
      bool isHidden,
      int sortOrder});
}

/// @nodoc
class __$$AchievementDataImplCopyWithImpl<$Res>
    extends _$AchievementDataCopyWithImpl<$Res, _$AchievementDataImpl>
    implements _$$AchievementDataImplCopyWith<$Res> {
  __$$AchievementDataImplCopyWithImpl(
      _$AchievementDataImpl _value, $Res Function(_$AchievementDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? category = null,
    Object? rarity = null,
    Object? conditionDescription = null,
    Object? iconKey = null,
    Object? rewardMessage = null,
    Object? unlockedAt = freezed,
    Object? progress = null,
    Object? isHidden = null,
    Object? sortOrder = null,
  }) {
    return _then(_$AchievementDataImpl(
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
              as AchievementCategory,
      rarity: null == rarity
          ? _value.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as AchievementRarity,
      conditionDescription: null == conditionDescription
          ? _value.conditionDescription
          : conditionDescription // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: null == iconKey
          ? _value.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String,
      rewardMessage: null == rewardMessage
          ? _value.rewardMessage
          : rewardMessage // ignore: cast_nullable_to_non_nullable
              as String,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementDataImpl implements _AchievementData {
  const _$AchievementDataImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.category,
      required this.rarity,
      required this.conditionDescription,
      required this.iconKey,
      required this.rewardMessage,
      this.unlockedAt,
      this.progress = 0.0,
      this.isHidden = false,
      this.sortOrder = 0});

  factory _$AchievementDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementDataImplFromJson(json);

  /// Unique achievement identifier
  @override
  final String id;

  /// Display name (localization key)
  @override
  final String name;

  /// Description (localization key)
  @override
  final String description;

  /// Achievement category
  @override
  final AchievementCategory category;

  /// Rarity level
  @override
  final AchievementRarity rarity;

  /// Unlock condition description (localization key)
  @override
  final String conditionDescription;

  /// Icon identifier (maps to IconData)
  @override
  final String iconKey;

  /// Reward message shown on unlock (localization key)
  @override
  final String rewardMessage;

  /// Unlock timestamp (null if locked)
  @override
  final DateTime? unlockedAt;

  /// Progress towards unlock (0.0 - 1.0)
  @override
  @JsonKey()
  final double progress;

  /// Whether achievement is hidden until unlocked
  @override
  @JsonKey()
  final bool isHidden;

  /// Sort order for display
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'AchievementData(id: $id, name: $name, description: $description, category: $category, rarity: $rarity, conditionDescription: $conditionDescription, iconKey: $iconKey, rewardMessage: $rewardMessage, unlockedAt: $unlockedAt, progress: $progress, isHidden: $isHidden, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.rarity, rarity) || other.rarity == rarity) &&
            (identical(other.conditionDescription, conditionDescription) ||
                other.conditionDescription == conditionDescription) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.rewardMessage, rewardMessage) ||
                other.rewardMessage == rewardMessage) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isHidden, isHidden) ||
                other.isHidden == isHidden) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      category,
      rarity,
      conditionDescription,
      iconKey,
      rewardMessage,
      unlockedAt,
      progress,
      isHidden,
      sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementDataImplCopyWith<_$AchievementDataImpl> get copyWith =>
      __$$AchievementDataImplCopyWithImpl<_$AchievementDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementDataImplToJson(
      this,
    );
  }
}

abstract class _AchievementData implements AchievementData {
  const factory _AchievementData(
      {required final String id,
      required final String name,
      required final String description,
      required final AchievementCategory category,
      required final AchievementRarity rarity,
      required final String conditionDescription,
      required final String iconKey,
      required final String rewardMessage,
      final DateTime? unlockedAt,
      final double progress,
      final bool isHidden,
      final int sortOrder}) = _$AchievementDataImpl;

  factory _AchievementData.fromJson(Map<String, dynamic> json) =
      _$AchievementDataImpl.fromJson;

  @override

  /// Unique achievement identifier
  String get id;
  @override

  /// Display name (localization key)
  String get name;
  @override

  /// Description (localization key)
  String get description;
  @override

  /// Achievement category
  AchievementCategory get category;
  @override

  /// Rarity level
  AchievementRarity get rarity;
  @override

  /// Unlock condition description (localization key)
  String get conditionDescription;
  @override

  /// Icon identifier (maps to IconData)
  String get iconKey;
  @override

  /// Reward message shown on unlock (localization key)
  String get rewardMessage;
  @override

  /// Unlock timestamp (null if locked)
  DateTime? get unlockedAt;
  @override

  /// Progress towards unlock (0.0 - 1.0)
  double get progress;
  @override

  /// Whether achievement is hidden until unlocked
  bool get isHidden;
  @override

  /// Sort order for display
  int get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$AchievementDataImplCopyWith<_$AchievementDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
