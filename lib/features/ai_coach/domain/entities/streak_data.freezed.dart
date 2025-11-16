// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakData _$StreakDataFromJson(Map<String, dynamic> json) {
  return _StreakData.fromJson(json);
}

/// @nodoc
mixin _$StreakData {
  /// Current consecutive workout days
  int get currentStreak => throw _privateConstructorUsedError;

  /// Longest streak ever achieved (all-time best)
  int get longestStreak => throw _privateConstructorUsedError;

  /// Last workout timestamp (null if never worked out)
  DateTime? get lastWorkoutDate => throw _privateConstructorUsedError;

  /// Whether user worked out today
  bool get workedOutToday => throw _privateConstructorUsedError;

  /// Streak milestones achieved (7, 14, 30, etc.)
  List<int> get milestonesAchieved => throw _privateConstructorUsedError;

  /// Total workouts completed (all-time)
  int get totalWorkouts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StreakDataCopyWith<StreakData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakDataCopyWith<$Res> {
  factory $StreakDataCopyWith(
          StreakData value, $Res Function(StreakData) then) =
      _$StreakDataCopyWithImpl<$Res, StreakData>;
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      DateTime? lastWorkoutDate,
      bool workedOutToday,
      List<int> milestonesAchieved,
      int totalWorkouts});
}

/// @nodoc
class _$StreakDataCopyWithImpl<$Res, $Val extends StreakData>
    implements $StreakDataCopyWith<$Res> {
  _$StreakDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastWorkoutDate = freezed,
    Object? workedOutToday = null,
    Object? milestonesAchieved = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      workedOutToday: null == workedOutToday
          ? _value.workedOutToday
          : workedOutToday // ignore: cast_nullable_to_non_nullable
              as bool,
      milestonesAchieved: null == milestonesAchieved
          ? _value.milestonesAchieved
          : milestonesAchieved // ignore: cast_nullable_to_non_nullable
              as List<int>,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakDataImplCopyWith<$Res>
    implements $StreakDataCopyWith<$Res> {
  factory _$$StreakDataImplCopyWith(
          _$StreakDataImpl value, $Res Function(_$StreakDataImpl) then) =
      __$$StreakDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      DateTime? lastWorkoutDate,
      bool workedOutToday,
      List<int> milestonesAchieved,
      int totalWorkouts});
}

/// @nodoc
class __$$StreakDataImplCopyWithImpl<$Res>
    extends _$StreakDataCopyWithImpl<$Res, _$StreakDataImpl>
    implements _$$StreakDataImplCopyWith<$Res> {
  __$$StreakDataImplCopyWithImpl(
      _$StreakDataImpl _value, $Res Function(_$StreakDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastWorkoutDate = freezed,
    Object? workedOutToday = null,
    Object? milestonesAchieved = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_$StreakDataImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      workedOutToday: null == workedOutToday
          ? _value.workedOutToday
          : workedOutToday // ignore: cast_nullable_to_non_nullable
              as bool,
      milestonesAchieved: null == milestonesAchieved
          ? _value._milestonesAchieved
          : milestonesAchieved // ignore: cast_nullable_to_non_nullable
              as List<int>,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakDataImpl implements _StreakData {
  const _$StreakDataImpl(
      {this.currentStreak = 0,
      this.longestStreak = 0,
      this.lastWorkoutDate,
      this.workedOutToday = false,
      final List<int> milestonesAchieved = const [],
      this.totalWorkouts = 0})
      : _milestonesAchieved = milestonesAchieved;

  factory _$StreakDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakDataImplFromJson(json);

  /// Current consecutive workout days
  @override
  @JsonKey()
  final int currentStreak;

  /// Longest streak ever achieved (all-time best)
  @override
  @JsonKey()
  final int longestStreak;

  /// Last workout timestamp (null if never worked out)
  @override
  final DateTime? lastWorkoutDate;

  /// Whether user worked out today
  @override
  @JsonKey()
  final bool workedOutToday;

  /// Streak milestones achieved (7, 14, 30, etc.)
  final List<int> _milestonesAchieved;

  /// Streak milestones achieved (7, 14, 30, etc.)
  @override
  @JsonKey()
  List<int> get milestonesAchieved {
    if (_milestonesAchieved is EqualUnmodifiableListView)
      return _milestonesAchieved;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_milestonesAchieved);
  }

  /// Total workouts completed (all-time)
  @override
  @JsonKey()
  final int totalWorkouts;

  @override
  String toString() {
    return 'StreakData(currentStreak: $currentStreak, longestStreak: $longestStreak, lastWorkoutDate: $lastWorkoutDate, workedOutToday: $workedOutToday, milestonesAchieved: $milestonesAchieved, totalWorkouts: $totalWorkouts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakDataImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate) &&
            (identical(other.workedOutToday, workedOutToday) ||
                other.workedOutToday == workedOutToday) &&
            const DeepCollectionEquality()
                .equals(other._milestonesAchieved, _milestonesAchieved) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStreak,
      longestStreak,
      lastWorkoutDate,
      workedOutToday,
      const DeepCollectionEquality().hash(_milestonesAchieved),
      totalWorkouts);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakDataImplCopyWith<_$StreakDataImpl> get copyWith =>
      __$$StreakDataImplCopyWithImpl<_$StreakDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakDataImplToJson(
      this,
    );
  }
}

abstract class _StreakData implements StreakData {
  const factory _StreakData(
      {final int currentStreak,
      final int longestStreak,
      final DateTime? lastWorkoutDate,
      final bool workedOutToday,
      final List<int> milestonesAchieved,
      final int totalWorkouts}) = _$StreakDataImpl;

  factory _StreakData.fromJson(Map<String, dynamic> json) =
      _$StreakDataImpl.fromJson;

  @override

  /// Current consecutive workout days
  int get currentStreak;
  @override

  /// Longest streak ever achieved (all-time best)
  int get longestStreak;
  @override

  /// Last workout timestamp (null if never worked out)
  DateTime? get lastWorkoutDate;
  @override

  /// Whether user worked out today
  bool get workedOutToday;
  @override

  /// Streak milestones achieved (7, 14, 30, etc.)
  List<int> get milestonesAchieved;
  @override

  /// Total workouts completed (all-time)
  int get totalWorkouts;
  @override
  @JsonKey(ignore: true)
  _$$StreakDataImplCopyWith<_$StreakDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
