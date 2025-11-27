// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_tour_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingTourStep {
  /// Unique identifier for this step (e.g., 'aiCoach', 'fab', 'analytics')
  String get id => throw _privateConstructorUsedError;

  /// Localization key for the title (used in bottom sheet header)
  String get titleKey => throw _privateConstructorUsedError;

  /// Localization key for the description text
  String get descriptionKey => throw _privateConstructorUsedError;

  /// Optional localization keys for bullet points (used for COMPLEX steps)
  List<String> get bulletPointKeys => throw _privateConstructorUsedError;

  /// Step complexity type
  TourStepType get type => throw _privateConstructorUsedError;

  /// Auto-advance duration (null = user-controlled, only for COMPLEX steps)
  Duration? get autoAdvanceDuration => throw _privateConstructorUsedError;

  /// GlobalKey for the widget to spotlight
  /// This key should be attached to the target widget in the UI
  String get targetWidgetKey => throw _privateConstructorUsedError;

  /// Step position in the tour (0-indexed)
  int get position => throw _privateConstructorUsedError;

  /// Total number of steps in the tour
  int get totalSteps => throw _privateConstructorUsedError;

  /// Bottom sheet position (bottom or top) - default is bottom
  /// Use top for FAB to avoid obscuring it
  BottomSheetPosition get bottomSheetPosition =>
      throw _privateConstructorUsedError;

  /// Create a copy of OnboardingTourStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingTourStepCopyWith<OnboardingTourStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingTourStepCopyWith<$Res> {
  factory $OnboardingTourStepCopyWith(
    OnboardingTourStep value,
    $Res Function(OnboardingTourStep) then,
  ) = _$OnboardingTourStepCopyWithImpl<$Res, OnboardingTourStep>;
  @useResult
  $Res call({
    String id,
    String titleKey,
    String descriptionKey,
    List<String> bulletPointKeys,
    TourStepType type,
    Duration? autoAdvanceDuration,
    String targetWidgetKey,
    int position,
    int totalSteps,
    BottomSheetPosition bottomSheetPosition,
  });
}

/// @nodoc
class _$OnboardingTourStepCopyWithImpl<$Res, $Val extends OnboardingTourStep>
    implements $OnboardingTourStepCopyWith<$Res> {
  _$OnboardingTourStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingTourStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titleKey = null,
    Object? descriptionKey = null,
    Object? bulletPointKeys = null,
    Object? type = null,
    Object? autoAdvanceDuration = freezed,
    Object? targetWidgetKey = null,
    Object? position = null,
    Object? totalSteps = null,
    Object? bottomSheetPosition = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titleKey: null == titleKey
                ? _value.titleKey
                : titleKey // ignore: cast_nullable_to_non_nullable
                      as String,
            descriptionKey: null == descriptionKey
                ? _value.descriptionKey
                : descriptionKey // ignore: cast_nullable_to_non_nullable
                      as String,
            bulletPointKeys: null == bulletPointKeys
                ? _value.bulletPointKeys
                : bulletPointKeys // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TourStepType,
            autoAdvanceDuration: freezed == autoAdvanceDuration
                ? _value.autoAdvanceDuration
                : autoAdvanceDuration // ignore: cast_nullable_to_non_nullable
                      as Duration?,
            targetWidgetKey: null == targetWidgetKey
                ? _value.targetWidgetKey
                : targetWidgetKey // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSteps: null == totalSteps
                ? _value.totalSteps
                : totalSteps // ignore: cast_nullable_to_non_nullable
                      as int,
            bottomSheetPosition: null == bottomSheetPosition
                ? _value.bottomSheetPosition
                : bottomSheetPosition // ignore: cast_nullable_to_non_nullable
                      as BottomSheetPosition,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingTourStepImplCopyWith<$Res>
    implements $OnboardingTourStepCopyWith<$Res> {
  factory _$$OnboardingTourStepImplCopyWith(
    _$OnboardingTourStepImpl value,
    $Res Function(_$OnboardingTourStepImpl) then,
  ) = __$$OnboardingTourStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String titleKey,
    String descriptionKey,
    List<String> bulletPointKeys,
    TourStepType type,
    Duration? autoAdvanceDuration,
    String targetWidgetKey,
    int position,
    int totalSteps,
    BottomSheetPosition bottomSheetPosition,
  });
}

/// @nodoc
class __$$OnboardingTourStepImplCopyWithImpl<$Res>
    extends _$OnboardingTourStepCopyWithImpl<$Res, _$OnboardingTourStepImpl>
    implements _$$OnboardingTourStepImplCopyWith<$Res> {
  __$$OnboardingTourStepImplCopyWithImpl(
    _$OnboardingTourStepImpl _value,
    $Res Function(_$OnboardingTourStepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingTourStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titleKey = null,
    Object? descriptionKey = null,
    Object? bulletPointKeys = null,
    Object? type = null,
    Object? autoAdvanceDuration = freezed,
    Object? targetWidgetKey = null,
    Object? position = null,
    Object? totalSteps = null,
    Object? bottomSheetPosition = null,
  }) {
    return _then(
      _$OnboardingTourStepImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titleKey: null == titleKey
            ? _value.titleKey
            : titleKey // ignore: cast_nullable_to_non_nullable
                  as String,
        descriptionKey: null == descriptionKey
            ? _value.descriptionKey
            : descriptionKey // ignore: cast_nullable_to_non_nullable
                  as String,
        bulletPointKeys: null == bulletPointKeys
            ? _value._bulletPointKeys
            : bulletPointKeys // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TourStepType,
        autoAdvanceDuration: freezed == autoAdvanceDuration
            ? _value.autoAdvanceDuration
            : autoAdvanceDuration // ignore: cast_nullable_to_non_nullable
                  as Duration?,
        targetWidgetKey: null == targetWidgetKey
            ? _value.targetWidgetKey
            : targetWidgetKey // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSteps: null == totalSteps
            ? _value.totalSteps
            : totalSteps // ignore: cast_nullable_to_non_nullable
                  as int,
        bottomSheetPosition: null == bottomSheetPosition
            ? _value.bottomSheetPosition
            : bottomSheetPosition // ignore: cast_nullable_to_non_nullable
                  as BottomSheetPosition,
      ),
    );
  }
}

/// @nodoc

class _$OnboardingTourStepImpl extends _OnboardingTourStep {
  const _$OnboardingTourStepImpl({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    final List<String> bulletPointKeys = const [],
    this.type = TourStepType.simple,
    this.autoAdvanceDuration,
    required this.targetWidgetKey,
    required this.position,
    required this.totalSteps,
    this.bottomSheetPosition = BottomSheetPosition.bottom,
  }) : _bulletPointKeys = bulletPointKeys,
       super._();

  /// Unique identifier for this step (e.g., 'aiCoach', 'fab', 'analytics')
  @override
  final String id;

  /// Localization key for the title (used in bottom sheet header)
  @override
  final String titleKey;

  /// Localization key for the description text
  @override
  final String descriptionKey;

  /// Optional localization keys for bullet points (used for COMPLEX steps)
  final List<String> _bulletPointKeys;

  /// Optional localization keys for bullet points (used for COMPLEX steps)
  @override
  @JsonKey()
  List<String> get bulletPointKeys {
    if (_bulletPointKeys is EqualUnmodifiableListView) return _bulletPointKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bulletPointKeys);
  }

  /// Step complexity type
  @override
  @JsonKey()
  final TourStepType type;

  /// Auto-advance duration (null = user-controlled, only for COMPLEX steps)
  @override
  final Duration? autoAdvanceDuration;

  /// GlobalKey for the widget to spotlight
  /// This key should be attached to the target widget in the UI
  @override
  final String targetWidgetKey;

  /// Step position in the tour (0-indexed)
  @override
  final int position;

  /// Total number of steps in the tour
  @override
  final int totalSteps;

  /// Bottom sheet position (bottom or top) - default is bottom
  /// Use top for FAB to avoid obscuring it
  @override
  @JsonKey()
  final BottomSheetPosition bottomSheetPosition;

  @override
  String toString() {
    return 'OnboardingTourStep(id: $id, titleKey: $titleKey, descriptionKey: $descriptionKey, bulletPointKeys: $bulletPointKeys, type: $type, autoAdvanceDuration: $autoAdvanceDuration, targetWidgetKey: $targetWidgetKey, position: $position, totalSteps: $totalSteps, bottomSheetPosition: $bottomSheetPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingTourStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titleKey, titleKey) ||
                other.titleKey == titleKey) &&
            (identical(other.descriptionKey, descriptionKey) ||
                other.descriptionKey == descriptionKey) &&
            const DeepCollectionEquality().equals(
              other._bulletPointKeys,
              _bulletPointKeys,
            ) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.autoAdvanceDuration, autoAdvanceDuration) ||
                other.autoAdvanceDuration == autoAdvanceDuration) &&
            (identical(other.targetWidgetKey, targetWidgetKey) ||
                other.targetWidgetKey == targetWidgetKey) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.totalSteps, totalSteps) ||
                other.totalSteps == totalSteps) &&
            (identical(other.bottomSheetPosition, bottomSheetPosition) ||
                other.bottomSheetPosition == bottomSheetPosition));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titleKey,
    descriptionKey,
    const DeepCollectionEquality().hash(_bulletPointKeys),
    type,
    autoAdvanceDuration,
    targetWidgetKey,
    position,
    totalSteps,
    bottomSheetPosition,
  );

  /// Create a copy of OnboardingTourStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingTourStepImplCopyWith<_$OnboardingTourStepImpl> get copyWith =>
      __$$OnboardingTourStepImplCopyWithImpl<_$OnboardingTourStepImpl>(
        this,
        _$identity,
      );
}

abstract class _OnboardingTourStep extends OnboardingTourStep {
  const factory _OnboardingTourStep({
    required final String id,
    required final String titleKey,
    required final String descriptionKey,
    final List<String> bulletPointKeys,
    final TourStepType type,
    final Duration? autoAdvanceDuration,
    required final String targetWidgetKey,
    required final int position,
    required final int totalSteps,
    final BottomSheetPosition bottomSheetPosition,
  }) = _$OnboardingTourStepImpl;
  const _OnboardingTourStep._() : super._();

  /// Unique identifier for this step (e.g., 'aiCoach', 'fab', 'analytics')
  @override
  String get id;

  /// Localization key for the title (used in bottom sheet header)
  @override
  String get titleKey;

  /// Localization key for the description text
  @override
  String get descriptionKey;

  /// Optional localization keys for bullet points (used for COMPLEX steps)
  @override
  List<String> get bulletPointKeys;

  /// Step complexity type
  @override
  TourStepType get type;

  /// Auto-advance duration (null = user-controlled, only for COMPLEX steps)
  @override
  Duration? get autoAdvanceDuration;

  /// GlobalKey for the widget to spotlight
  /// This key should be attached to the target widget in the UI
  @override
  String get targetWidgetKey;

  /// Step position in the tour (0-indexed)
  @override
  int get position;

  /// Total number of steps in the tour
  @override
  int get totalSteps;

  /// Bottom sheet position (bottom or top) - default is bottom
  /// Use top for FAB to avoid obscuring it
  @override
  BottomSheetPosition get bottomSheetPosition;

  /// Create a copy of OnboardingTourStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingTourStepImplCopyWith<_$OnboardingTourStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
