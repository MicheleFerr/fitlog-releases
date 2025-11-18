// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomeState {
  String get greeting => throw _privateConstructorUsedError;
  WorkoutSection get workoutSection => throw _privateConstructorUsedError;
  AICoachSection get aiCoachSection => throw _privateConstructorUsedError;
  StreakSection get streakSection => throw _privateConstructorUsedError;
  LoadingPhase get loadingPhase => throw _privateConstructorUsedError;
  Map<String, Duration> get sectionLoadTimes =>
      throw _privateConstructorUsedError;
  DateTime? get lastRefresh => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {String greeting,
      WorkoutSection workoutSection,
      AICoachSection aiCoachSection,
      StreakSection streakSection,
      LoadingPhase loadingPhase,
      Map<String, Duration> sectionLoadTimes,
      DateTime? lastRefresh,
      bool hasError,
      String? errorMessage});

  $WorkoutSectionCopyWith<$Res> get workoutSection;
  $AICoachSectionCopyWith<$Res> get aiCoachSection;
  $StreakSectionCopyWith<$Res> get streakSection;
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? greeting = null,
    Object? workoutSection = null,
    Object? aiCoachSection = null,
    Object? streakSection = null,
    Object? loadingPhase = null,
    Object? sectionLoadTimes = null,
    Object? lastRefresh = freezed,
    Object? hasError = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      greeting: null == greeting
          ? _value.greeting
          : greeting // ignore: cast_nullable_to_non_nullable
              as String,
      workoutSection: null == workoutSection
          ? _value.workoutSection
          : workoutSection // ignore: cast_nullable_to_non_nullable
              as WorkoutSection,
      aiCoachSection: null == aiCoachSection
          ? _value.aiCoachSection
          : aiCoachSection // ignore: cast_nullable_to_non_nullable
              as AICoachSection,
      streakSection: null == streakSection
          ? _value.streakSection
          : streakSection // ignore: cast_nullable_to_non_nullable
              as StreakSection,
      loadingPhase: null == loadingPhase
          ? _value.loadingPhase
          : loadingPhase // ignore: cast_nullable_to_non_nullable
              as LoadingPhase,
      sectionLoadTimes: null == sectionLoadTimes
          ? _value.sectionLoadTimes
          : sectionLoadTimes // ignore: cast_nullable_to_non_nullable
              as Map<String, Duration>,
      lastRefresh: freezed == lastRefresh
          ? _value.lastRefresh
          : lastRefresh // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutSectionCopyWith<$Res> get workoutSection {
    return $WorkoutSectionCopyWith<$Res>(_value.workoutSection, (value) {
      return _then(_value.copyWith(workoutSection: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AICoachSectionCopyWith<$Res> get aiCoachSection {
    return $AICoachSectionCopyWith<$Res>(_value.aiCoachSection, (value) {
      return _then(_value.copyWith(aiCoachSection: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $StreakSectionCopyWith<$Res> get streakSection {
    return $StreakSectionCopyWith<$Res>(_value.streakSection, (value) {
      return _then(_value.copyWith(streakSection: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
          _$HomeStateImpl value, $Res Function(_$HomeStateImpl) then) =
      __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String greeting,
      WorkoutSection workoutSection,
      AICoachSection aiCoachSection,
      StreakSection streakSection,
      LoadingPhase loadingPhase,
      Map<String, Duration> sectionLoadTimes,
      DateTime? lastRefresh,
      bool hasError,
      String? errorMessage});

  @override
  $WorkoutSectionCopyWith<$Res> get workoutSection;
  @override
  $AICoachSectionCopyWith<$Res> get aiCoachSection;
  @override
  $StreakSectionCopyWith<$Res> get streakSection;
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
      _$HomeStateImpl _value, $Res Function(_$HomeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? greeting = null,
    Object? workoutSection = null,
    Object? aiCoachSection = null,
    Object? streakSection = null,
    Object? loadingPhase = null,
    Object? sectionLoadTimes = null,
    Object? lastRefresh = freezed,
    Object? hasError = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$HomeStateImpl(
      greeting: null == greeting
          ? _value.greeting
          : greeting // ignore: cast_nullable_to_non_nullable
              as String,
      workoutSection: null == workoutSection
          ? _value.workoutSection
          : workoutSection // ignore: cast_nullable_to_non_nullable
              as WorkoutSection,
      aiCoachSection: null == aiCoachSection
          ? _value.aiCoachSection
          : aiCoachSection // ignore: cast_nullable_to_non_nullable
              as AICoachSection,
      streakSection: null == streakSection
          ? _value.streakSection
          : streakSection // ignore: cast_nullable_to_non_nullable
              as StreakSection,
      loadingPhase: null == loadingPhase
          ? _value.loadingPhase
          : loadingPhase // ignore: cast_nullable_to_non_nullable
              as LoadingPhase,
      sectionLoadTimes: null == sectionLoadTimes
          ? _value._sectionLoadTimes
          : sectionLoadTimes // ignore: cast_nullable_to_non_nullable
              as Map<String, Duration>,
      lastRefresh: freezed == lastRefresh
          ? _value.lastRefresh
          : lastRefresh // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl(
      {required this.greeting,
      required this.workoutSection,
      required this.aiCoachSection,
      required this.streakSection,
      this.loadingPhase = LoadingPhase.initial,
      final Map<String, Duration> sectionLoadTimes = const {},
      this.lastRefresh,
      this.hasError = false,
      this.errorMessage})
      : _sectionLoadTimes = sectionLoadTimes;

  @override
  final String greeting;
  @override
  final WorkoutSection workoutSection;
  @override
  final AICoachSection aiCoachSection;
  @override
  final StreakSection streakSection;
  @override
  @JsonKey()
  final LoadingPhase loadingPhase;
  final Map<String, Duration> _sectionLoadTimes;
  @override
  @JsonKey()
  Map<String, Duration> get sectionLoadTimes {
    if (_sectionLoadTimes is EqualUnmodifiableMapView) return _sectionLoadTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sectionLoadTimes);
  }

  @override
  final DateTime? lastRefresh;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'HomeState(greeting: $greeting, workoutSection: $workoutSection, aiCoachSection: $aiCoachSection, streakSection: $streakSection, loadingPhase: $loadingPhase, sectionLoadTimes: $sectionLoadTimes, lastRefresh: $lastRefresh, hasError: $hasError, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.greeting, greeting) ||
                other.greeting == greeting) &&
            (identical(other.workoutSection, workoutSection) ||
                other.workoutSection == workoutSection) &&
            (identical(other.aiCoachSection, aiCoachSection) ||
                other.aiCoachSection == aiCoachSection) &&
            (identical(other.streakSection, streakSection) ||
                other.streakSection == streakSection) &&
            (identical(other.loadingPhase, loadingPhase) ||
                other.loadingPhase == loadingPhase) &&
            const DeepCollectionEquality()
                .equals(other._sectionLoadTimes, _sectionLoadTimes) &&
            (identical(other.lastRefresh, lastRefresh) ||
                other.lastRefresh == lastRefresh) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      greeting,
      workoutSection,
      aiCoachSection,
      streakSection,
      loadingPhase,
      const DeepCollectionEquality().hash(_sectionLoadTimes),
      lastRefresh,
      hasError,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState(
      {required final String greeting,
      required final WorkoutSection workoutSection,
      required final AICoachSection aiCoachSection,
      required final StreakSection streakSection,
      final LoadingPhase loadingPhase,
      final Map<String, Duration> sectionLoadTimes,
      final DateTime? lastRefresh,
      final bool hasError,
      final String? errorMessage}) = _$HomeStateImpl;

  @override
  String get greeting;
  @override
  WorkoutSection get workoutSection;
  @override
  AICoachSection get aiCoachSection;
  @override
  StreakSection get streakSection;
  @override
  LoadingPhase get loadingPhase;
  @override
  Map<String, Duration> get sectionLoadTimes;
  @override
  DateTime? get lastRefresh;
  @override
  bool get hasError;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WorkoutSection {
  bool get hasActiveWorkout => throw _privateConstructorUsedError;
  String? get workoutName => throw _privateConstructorUsedError;
  double? get progress => throw _privateConstructorUsedError;
  int? get exercisesCompleted => throw _privateConstructorUsedError;
  int? get totalExercises => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WorkoutSectionCopyWith<WorkoutSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSectionCopyWith<$Res> {
  factory $WorkoutSectionCopyWith(
          WorkoutSection value, $Res Function(WorkoutSection) then) =
      _$WorkoutSectionCopyWithImpl<$Res, WorkoutSection>;
  @useResult
  $Res call(
      {bool hasActiveWorkout,
      String? workoutName,
      double? progress,
      int? exercisesCompleted,
      int? totalExercises});
}

/// @nodoc
class _$WorkoutSectionCopyWithImpl<$Res, $Val extends WorkoutSection>
    implements $WorkoutSectionCopyWith<$Res> {
  _$WorkoutSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasActiveWorkout = null,
    Object? workoutName = freezed,
    Object? progress = freezed,
    Object? exercisesCompleted = freezed,
    Object? totalExercises = freezed,
  }) {
    return _then(_value.copyWith(
      hasActiveWorkout: null == hasActiveWorkout
          ? _value.hasActiveWorkout
          : hasActiveWorkout // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutName: freezed == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double?,
      exercisesCompleted: freezed == exercisesCompleted
          ? _value.exercisesCompleted
          : exercisesCompleted // ignore: cast_nullable_to_non_nullable
              as int?,
      totalExercises: freezed == totalExercises
          ? _value.totalExercises
          : totalExercises // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSectionImplCopyWith<$Res>
    implements $WorkoutSectionCopyWith<$Res> {
  factory _$$WorkoutSectionImplCopyWith(_$WorkoutSectionImpl value,
          $Res Function(_$WorkoutSectionImpl) then) =
      __$$WorkoutSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool hasActiveWorkout,
      String? workoutName,
      double? progress,
      int? exercisesCompleted,
      int? totalExercises});
}

/// @nodoc
class __$$WorkoutSectionImplCopyWithImpl<$Res>
    extends _$WorkoutSectionCopyWithImpl<$Res, _$WorkoutSectionImpl>
    implements _$$WorkoutSectionImplCopyWith<$Res> {
  __$$WorkoutSectionImplCopyWithImpl(
      _$WorkoutSectionImpl _value, $Res Function(_$WorkoutSectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasActiveWorkout = null,
    Object? workoutName = freezed,
    Object? progress = freezed,
    Object? exercisesCompleted = freezed,
    Object? totalExercises = freezed,
  }) {
    return _then(_$WorkoutSectionImpl(
      hasActiveWorkout: null == hasActiveWorkout
          ? _value.hasActiveWorkout
          : hasActiveWorkout // ignore: cast_nullable_to_non_nullable
              as bool,
      workoutName: freezed == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double?,
      exercisesCompleted: freezed == exercisesCompleted
          ? _value.exercisesCompleted
          : exercisesCompleted // ignore: cast_nullable_to_non_nullable
              as int?,
      totalExercises: freezed == totalExercises
          ? _value.totalExercises
          : totalExercises // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$WorkoutSectionImpl extends _WorkoutSection {
  const _$WorkoutSectionImpl(
      {required this.hasActiveWorkout,
      this.workoutName,
      this.progress,
      this.exercisesCompleted,
      this.totalExercises})
      : super._();

  @override
  final bool hasActiveWorkout;
  @override
  final String? workoutName;
  @override
  final double? progress;
  @override
  final int? exercisesCompleted;
  @override
  final int? totalExercises;

  @override
  String toString() {
    return 'WorkoutSection(hasActiveWorkout: $hasActiveWorkout, workoutName: $workoutName, progress: $progress, exercisesCompleted: $exercisesCompleted, totalExercises: $totalExercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSectionImpl &&
            (identical(other.hasActiveWorkout, hasActiveWorkout) ||
                other.hasActiveWorkout == hasActiveWorkout) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.exercisesCompleted, exercisesCompleted) ||
                other.exercisesCompleted == exercisesCompleted) &&
            (identical(other.totalExercises, totalExercises) ||
                other.totalExercises == totalExercises));
  }

  @override
  int get hashCode => Object.hash(runtimeType, hasActiveWorkout, workoutName,
      progress, exercisesCompleted, totalExercises);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSectionImplCopyWith<_$WorkoutSectionImpl> get copyWith =>
      __$$WorkoutSectionImplCopyWithImpl<_$WorkoutSectionImpl>(
          this, _$identity);
}

abstract class _WorkoutSection extends WorkoutSection {
  const factory _WorkoutSection(
      {required final bool hasActiveWorkout,
      final String? workoutName,
      final double? progress,
      final int? exercisesCompleted,
      final int? totalExercises}) = _$WorkoutSectionImpl;
  const _WorkoutSection._() : super._();

  @override
  bool get hasActiveWorkout;
  @override
  String? get workoutName;
  @override
  double? get progress;
  @override
  int? get exercisesCompleted;
  @override
  int? get totalExercises;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSectionImplCopyWith<_$WorkoutSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AICoachSection {
  String get message => throw _privateConstructorUsedError;
  String? get suggestion => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AICoachSectionCopyWith<AICoachSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AICoachSectionCopyWith<$Res> {
  factory $AICoachSectionCopyWith(
          AICoachSection value, $Res Function(AICoachSection) then) =
      _$AICoachSectionCopyWithImpl<$Res, AICoachSection>;
  @useResult
  $Res call({String message, String? suggestion, String? imageUrl});
}

/// @nodoc
class _$AICoachSectionCopyWithImpl<$Res, $Val extends AICoachSection>
    implements $AICoachSectionCopyWith<$Res> {
  _$AICoachSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? suggestion = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: freezed == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AICoachSectionImplCopyWith<$Res>
    implements $AICoachSectionCopyWith<$Res> {
  factory _$$AICoachSectionImplCopyWith(_$AICoachSectionImpl value,
          $Res Function(_$AICoachSectionImpl) then) =
      __$$AICoachSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? suggestion, String? imageUrl});
}

/// @nodoc
class __$$AICoachSectionImplCopyWithImpl<$Res>
    extends _$AICoachSectionCopyWithImpl<$Res, _$AICoachSectionImpl>
    implements _$$AICoachSectionImplCopyWith<$Res> {
  __$$AICoachSectionImplCopyWithImpl(
      _$AICoachSectionImpl _value, $Res Function(_$AICoachSectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? suggestion = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$AICoachSectionImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: freezed == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AICoachSectionImpl extends _AICoachSection {
  const _$AICoachSectionImpl(
      {required this.message, this.suggestion, this.imageUrl})
      : super._();

  @override
  final String message;
  @override
  final String? suggestion;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'AICoachSection(message: $message, suggestion: $suggestion, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AICoachSectionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.suggestion, suggestion) ||
                other.suggestion == suggestion) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, suggestion, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AICoachSectionImplCopyWith<_$AICoachSectionImpl> get copyWith =>
      __$$AICoachSectionImplCopyWithImpl<_$AICoachSectionImpl>(
          this, _$identity);
}

abstract class _AICoachSection extends AICoachSection {
  const factory _AICoachSection(
      {required final String message,
      final String? suggestion,
      final String? imageUrl}) = _$AICoachSectionImpl;
  const _AICoachSection._() : super._();

  @override
  String get message;
  @override
  String? get suggestion;
  @override
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$AICoachSectionImplCopyWith<_$AICoachSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StreakSection {
  int get currentStreak => throw _privateConstructorUsedError;
  int get bestStreak => throw _privateConstructorUsedError;
  DateTime? get lastWorkoutDate => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StreakSectionCopyWith<StreakSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakSectionCopyWith<$Res> {
  factory $StreakSectionCopyWith(
          StreakSection value, $Res Function(StreakSection) then) =
      _$StreakSectionCopyWithImpl<$Res, StreakSection>;
  @useResult
  $Res call({int currentStreak, int bestStreak, DateTime? lastWorkoutDate});
}

/// @nodoc
class _$StreakSectionCopyWithImpl<$Res, $Val extends StreakSection>
    implements $StreakSectionCopyWith<$Res> {
  _$StreakSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? bestStreak = null,
    Object? lastWorkoutDate = freezed,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakSectionImplCopyWith<$Res>
    implements $StreakSectionCopyWith<$Res> {
  factory _$$StreakSectionImplCopyWith(
          _$StreakSectionImpl value, $Res Function(_$StreakSectionImpl) then) =
      __$$StreakSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentStreak, int bestStreak, DateTime? lastWorkoutDate});
}

/// @nodoc
class __$$StreakSectionImplCopyWithImpl<$Res>
    extends _$StreakSectionCopyWithImpl<$Res, _$StreakSectionImpl>
    implements _$$StreakSectionImplCopyWith<$Res> {
  __$$StreakSectionImplCopyWithImpl(
      _$StreakSectionImpl _value, $Res Function(_$StreakSectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? bestStreak = null,
    Object? lastWorkoutDate = freezed,
  }) {
    return _then(_$StreakSectionImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$StreakSectionImpl extends _StreakSection {
  const _$StreakSectionImpl(
      {required this.currentStreak,
      required this.bestStreak,
      this.lastWorkoutDate})
      : super._();

  @override
  final int currentStreak;
  @override
  final int bestStreak;
  @override
  final DateTime? lastWorkoutDate;

  @override
  String toString() {
    return 'StreakSection(currentStreak: $currentStreak, bestStreak: $bestStreak, lastWorkoutDate: $lastWorkoutDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakSectionImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.bestStreak, bestStreak) ||
                other.bestStreak == bestStreak) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, currentStreak, bestStreak, lastWorkoutDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakSectionImplCopyWith<_$StreakSectionImpl> get copyWith =>
      __$$StreakSectionImplCopyWithImpl<_$StreakSectionImpl>(this, _$identity);
}

abstract class _StreakSection extends StreakSection {
  const factory _StreakSection(
      {required final int currentStreak,
      required final int bestStreak,
      final DateTime? lastWorkoutDate}) = _$StreakSectionImpl;
  const _StreakSection._() : super._();

  @override
  int get currentStreak;
  @override
  int get bestStreak;
  @override
  DateTime? get lastWorkoutDate;
  @override
  @JsonKey(ignore: true)
  _$$StreakSectionImplCopyWith<_$StreakSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
