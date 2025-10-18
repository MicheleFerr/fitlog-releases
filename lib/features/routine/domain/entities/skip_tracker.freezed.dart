// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skip_tracker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SkipEntry _$SkipEntryFromJson(Map<String, dynamic> json) {
  return _SkipEntry.fromJson(json);
}

/// @nodoc
mixin _$SkipEntry {
  DateTime get date => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get skippedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SkipEntryCopyWith<SkipEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkipEntryCopyWith<$Res> {
  factory $SkipEntryCopyWith(SkipEntry value, $Res Function(SkipEntry) then) =
      _$SkipEntryCopyWithImpl<$Res, SkipEntry>;
  @useResult
  $Res call({DateTime date, String? reason, String? notes, DateTime skippedAt});
}

/// @nodoc
class _$SkipEntryCopyWithImpl<$Res, $Val extends SkipEntry>
    implements $SkipEntryCopyWith<$Res> {
  _$SkipEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? skippedAt = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      skippedAt: null == skippedAt
          ? _value.skippedAt
          : skippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkipEntryImplCopyWith<$Res>
    implements $SkipEntryCopyWith<$Res> {
  factory _$$SkipEntryImplCopyWith(
          _$SkipEntryImpl value, $Res Function(_$SkipEntryImpl) then) =
      __$$SkipEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, String? reason, String? notes, DateTime skippedAt});
}

/// @nodoc
class __$$SkipEntryImplCopyWithImpl<$Res>
    extends _$SkipEntryCopyWithImpl<$Res, _$SkipEntryImpl>
    implements _$$SkipEntryImplCopyWith<$Res> {
  __$$SkipEntryImplCopyWithImpl(
      _$SkipEntryImpl _value, $Res Function(_$SkipEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? skippedAt = null,
  }) {
    return _then(_$SkipEntryImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      skippedAt: null == skippedAt
          ? _value.skippedAt
          : skippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkipEntryImpl implements _SkipEntry {
  const _$SkipEntryImpl(
      {required this.date, this.reason, this.notes, required this.skippedAt});

  factory _$SkipEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkipEntryImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String? reason;
  @override
  final String? notes;
  @override
  final DateTime skippedAt;

  @override
  String toString() {
    return 'SkipEntry(date: $date, reason: $reason, notes: $notes, skippedAt: $skippedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkipEntryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.skippedAt, skippedAt) ||
                other.skippedAt == skippedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, reason, notes, skippedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SkipEntryImplCopyWith<_$SkipEntryImpl> get copyWith =>
      __$$SkipEntryImplCopyWithImpl<_$SkipEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkipEntryImplToJson(
      this,
    );
  }
}

abstract class _SkipEntry implements SkipEntry {
  const factory _SkipEntry(
      {required final DateTime date,
      final String? reason,
      final String? notes,
      required final DateTime skippedAt}) = _$SkipEntryImpl;

  factory _SkipEntry.fromJson(Map<String, dynamic> json) =
      _$SkipEntryImpl.fromJson;

  @override
  DateTime get date;
  @override
  String? get reason;
  @override
  String? get notes;
  @override
  DateTime get skippedAt;
  @override
  @JsonKey(ignore: true)
  _$$SkipEntryImplCopyWith<_$SkipEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecoveryEntry _$RecoveryEntryFromJson(Map<String, dynamic> json) {
  return _RecoveryEntry.fromJson(json);
}

/// @nodoc
mixin _$RecoveryEntry {
  DateTime get originalDate =>
      throw _privateConstructorUsedError; // Date that was skipped
  DateTime get recoveryDate =>
      throw _privateConstructorUsedError; // Date when recovered
  String? get notes => throw _privateConstructorUsedError;
  DateTime get recoveredAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecoveryEntryCopyWith<RecoveryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecoveryEntryCopyWith<$Res> {
  factory $RecoveryEntryCopyWith(
          RecoveryEntry value, $Res Function(RecoveryEntry) then) =
      _$RecoveryEntryCopyWithImpl<$Res, RecoveryEntry>;
  @useResult
  $Res call(
      {DateTime originalDate,
      DateTime recoveryDate,
      String? notes,
      DateTime recoveredAt});
}

/// @nodoc
class _$RecoveryEntryCopyWithImpl<$Res, $Val extends RecoveryEntry>
    implements $RecoveryEntryCopyWith<$Res> {
  _$RecoveryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalDate = null,
    Object? recoveryDate = null,
    Object? notes = freezed,
    Object? recoveredAt = null,
  }) {
    return _then(_value.copyWith(
      originalDate: null == originalDate
          ? _value.originalDate
          : originalDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recoveryDate: null == recoveryDate
          ? _value.recoveryDate
          : recoveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveredAt: null == recoveredAt
          ? _value.recoveredAt
          : recoveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecoveryEntryImplCopyWith<$Res>
    implements $RecoveryEntryCopyWith<$Res> {
  factory _$$RecoveryEntryImplCopyWith(
          _$RecoveryEntryImpl value, $Res Function(_$RecoveryEntryImpl) then) =
      __$$RecoveryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime originalDate,
      DateTime recoveryDate,
      String? notes,
      DateTime recoveredAt});
}

/// @nodoc
class __$$RecoveryEntryImplCopyWithImpl<$Res>
    extends _$RecoveryEntryCopyWithImpl<$Res, _$RecoveryEntryImpl>
    implements _$$RecoveryEntryImplCopyWith<$Res> {
  __$$RecoveryEntryImplCopyWithImpl(
      _$RecoveryEntryImpl _value, $Res Function(_$RecoveryEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalDate = null,
    Object? recoveryDate = null,
    Object? notes = freezed,
    Object? recoveredAt = null,
  }) {
    return _then(_$RecoveryEntryImpl(
      originalDate: null == originalDate
          ? _value.originalDate
          : originalDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recoveryDate: null == recoveryDate
          ? _value.recoveryDate
          : recoveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      recoveredAt: null == recoveredAt
          ? _value.recoveredAt
          : recoveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecoveryEntryImpl implements _RecoveryEntry {
  const _$RecoveryEntryImpl(
      {required this.originalDate,
      required this.recoveryDate,
      this.notes,
      required this.recoveredAt});

  factory _$RecoveryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecoveryEntryImplFromJson(json);

  @override
  final DateTime originalDate;
// Date that was skipped
  @override
  final DateTime recoveryDate;
// Date when recovered
  @override
  final String? notes;
  @override
  final DateTime recoveredAt;

  @override
  String toString() {
    return 'RecoveryEntry(originalDate: $originalDate, recoveryDate: $recoveryDate, notes: $notes, recoveredAt: $recoveredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecoveryEntryImpl &&
            (identical(other.originalDate, originalDate) ||
                other.originalDate == originalDate) &&
            (identical(other.recoveryDate, recoveryDate) ||
                other.recoveryDate == recoveryDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.recoveredAt, recoveredAt) ||
                other.recoveredAt == recoveredAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, originalDate, recoveryDate, notes, recoveredAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecoveryEntryImplCopyWith<_$RecoveryEntryImpl> get copyWith =>
      __$$RecoveryEntryImplCopyWithImpl<_$RecoveryEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecoveryEntryImplToJson(
      this,
    );
  }
}

abstract class _RecoveryEntry implements RecoveryEntry {
  const factory _RecoveryEntry(
      {required final DateTime originalDate,
      required final DateTime recoveryDate,
      final String? notes,
      required final DateTime recoveredAt}) = _$RecoveryEntryImpl;

  factory _RecoveryEntry.fromJson(Map<String, dynamic> json) =
      _$RecoveryEntryImpl.fromJson;

  @override
  DateTime get originalDate;
  @override // Date that was skipped
  DateTime get recoveryDate;
  @override // Date when recovered
  String? get notes;
  @override
  DateTime get recoveredAt;
  @override
  @JsonKey(ignore: true)
  _$$RecoveryEntryImplCopyWith<_$RecoveryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkipTracker _$SkipTrackerFromJson(Map<String, dynamic> json) {
  return _SkipTracker.fromJson(json);
}

/// @nodoc
mixin _$SkipTracker {
  /// Map of date → skip entry
  Map<String, SkipEntry> get skippedDays =>
      throw _privateConstructorUsedError; // String key for JSON serialization
  /// Map of original date → recovery entry
  Map<String, RecoveryEntry> get recoveredDays =>
      throw _privateConstructorUsedError; // === ANALYTICS ===
  int get totalSkips => throw _privateConstructorUsedError;
  int get totalRecoveries => throw _privateConstructorUsedError;

  /// Consecutive skips (current)
  int get currentSkipStreak => throw _privateConstructorUsedError;

  /// Longest skip streak ever
  int get longestSkipStreak => throw _privateConstructorUsedError;

  /// Date of last skip
  DateTime? get lastSkipDate => throw _privateConstructorUsedError;

  /// Most common skip reason
  String? get mostCommonReason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SkipTrackerCopyWith<SkipTracker> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkipTrackerCopyWith<$Res> {
  factory $SkipTrackerCopyWith(
          SkipTracker value, $Res Function(SkipTracker) then) =
      _$SkipTrackerCopyWithImpl<$Res, SkipTracker>;
  @useResult
  $Res call(
      {Map<String, SkipEntry> skippedDays,
      Map<String, RecoveryEntry> recoveredDays,
      int totalSkips,
      int totalRecoveries,
      int currentSkipStreak,
      int longestSkipStreak,
      DateTime? lastSkipDate,
      String? mostCommonReason});
}

/// @nodoc
class _$SkipTrackerCopyWithImpl<$Res, $Val extends SkipTracker>
    implements $SkipTrackerCopyWith<$Res> {
  _$SkipTrackerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skippedDays = null,
    Object? recoveredDays = null,
    Object? totalSkips = null,
    Object? totalRecoveries = null,
    Object? currentSkipStreak = null,
    Object? longestSkipStreak = null,
    Object? lastSkipDate = freezed,
    Object? mostCommonReason = freezed,
  }) {
    return _then(_value.copyWith(
      skippedDays: null == skippedDays
          ? _value.skippedDays
          : skippedDays // ignore: cast_nullable_to_non_nullable
              as Map<String, SkipEntry>,
      recoveredDays: null == recoveredDays
          ? _value.recoveredDays
          : recoveredDays // ignore: cast_nullable_to_non_nullable
              as Map<String, RecoveryEntry>,
      totalSkips: null == totalSkips
          ? _value.totalSkips
          : totalSkips // ignore: cast_nullable_to_non_nullable
              as int,
      totalRecoveries: null == totalRecoveries
          ? _value.totalRecoveries
          : totalRecoveries // ignore: cast_nullable_to_non_nullable
              as int,
      currentSkipStreak: null == currentSkipStreak
          ? _value.currentSkipStreak
          : currentSkipStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestSkipStreak: null == longestSkipStreak
          ? _value.longestSkipStreak
          : longestSkipStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastSkipDate: freezed == lastSkipDate
          ? _value.lastSkipDate
          : lastSkipDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mostCommonReason: freezed == mostCommonReason
          ? _value.mostCommonReason
          : mostCommonReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkipTrackerImplCopyWith<$Res>
    implements $SkipTrackerCopyWith<$Res> {
  factory _$$SkipTrackerImplCopyWith(
          _$SkipTrackerImpl value, $Res Function(_$SkipTrackerImpl) then) =
      __$$SkipTrackerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, SkipEntry> skippedDays,
      Map<String, RecoveryEntry> recoveredDays,
      int totalSkips,
      int totalRecoveries,
      int currentSkipStreak,
      int longestSkipStreak,
      DateTime? lastSkipDate,
      String? mostCommonReason});
}

/// @nodoc
class __$$SkipTrackerImplCopyWithImpl<$Res>
    extends _$SkipTrackerCopyWithImpl<$Res, _$SkipTrackerImpl>
    implements _$$SkipTrackerImplCopyWith<$Res> {
  __$$SkipTrackerImplCopyWithImpl(
      _$SkipTrackerImpl _value, $Res Function(_$SkipTrackerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skippedDays = null,
    Object? recoveredDays = null,
    Object? totalSkips = null,
    Object? totalRecoveries = null,
    Object? currentSkipStreak = null,
    Object? longestSkipStreak = null,
    Object? lastSkipDate = freezed,
    Object? mostCommonReason = freezed,
  }) {
    return _then(_$SkipTrackerImpl(
      skippedDays: null == skippedDays
          ? _value._skippedDays
          : skippedDays // ignore: cast_nullable_to_non_nullable
              as Map<String, SkipEntry>,
      recoveredDays: null == recoveredDays
          ? _value._recoveredDays
          : recoveredDays // ignore: cast_nullable_to_non_nullable
              as Map<String, RecoveryEntry>,
      totalSkips: null == totalSkips
          ? _value.totalSkips
          : totalSkips // ignore: cast_nullable_to_non_nullable
              as int,
      totalRecoveries: null == totalRecoveries
          ? _value.totalRecoveries
          : totalRecoveries // ignore: cast_nullable_to_non_nullable
              as int,
      currentSkipStreak: null == currentSkipStreak
          ? _value.currentSkipStreak
          : currentSkipStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestSkipStreak: null == longestSkipStreak
          ? _value.longestSkipStreak
          : longestSkipStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastSkipDate: freezed == lastSkipDate
          ? _value.lastSkipDate
          : lastSkipDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mostCommonReason: freezed == mostCommonReason
          ? _value.mostCommonReason
          : mostCommonReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkipTrackerImpl implements _SkipTracker {
  const _$SkipTrackerImpl(
      {required final Map<String, SkipEntry> skippedDays,
      required final Map<String, RecoveryEntry> recoveredDays,
      this.totalSkips = 0,
      this.totalRecoveries = 0,
      this.currentSkipStreak = 0,
      this.longestSkipStreak = 0,
      this.lastSkipDate,
      this.mostCommonReason})
      : _skippedDays = skippedDays,
        _recoveredDays = recoveredDays;

  factory _$SkipTrackerImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkipTrackerImplFromJson(json);

  /// Map of date → skip entry
  final Map<String, SkipEntry> _skippedDays;

  /// Map of date → skip entry
  @override
  Map<String, SkipEntry> get skippedDays {
    if (_skippedDays is EqualUnmodifiableMapView) return _skippedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_skippedDays);
  }

// String key for JSON serialization
  /// Map of original date → recovery entry
  final Map<String, RecoveryEntry> _recoveredDays;
// String key for JSON serialization
  /// Map of original date → recovery entry
  @override
  Map<String, RecoveryEntry> get recoveredDays {
    if (_recoveredDays is EqualUnmodifiableMapView) return _recoveredDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_recoveredDays);
  }

// === ANALYTICS ===
  @override
  @JsonKey()
  final int totalSkips;
  @override
  @JsonKey()
  final int totalRecoveries;

  /// Consecutive skips (current)
  @override
  @JsonKey()
  final int currentSkipStreak;

  /// Longest skip streak ever
  @override
  @JsonKey()
  final int longestSkipStreak;

  /// Date of last skip
  @override
  final DateTime? lastSkipDate;

  /// Most common skip reason
  @override
  final String? mostCommonReason;

  @override
  String toString() {
    return 'SkipTracker(skippedDays: $skippedDays, recoveredDays: $recoveredDays, totalSkips: $totalSkips, totalRecoveries: $totalRecoveries, currentSkipStreak: $currentSkipStreak, longestSkipStreak: $longestSkipStreak, lastSkipDate: $lastSkipDate, mostCommonReason: $mostCommonReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkipTrackerImpl &&
            const DeepCollectionEquality()
                .equals(other._skippedDays, _skippedDays) &&
            const DeepCollectionEquality()
                .equals(other._recoveredDays, _recoveredDays) &&
            (identical(other.totalSkips, totalSkips) ||
                other.totalSkips == totalSkips) &&
            (identical(other.totalRecoveries, totalRecoveries) ||
                other.totalRecoveries == totalRecoveries) &&
            (identical(other.currentSkipStreak, currentSkipStreak) ||
                other.currentSkipStreak == currentSkipStreak) &&
            (identical(other.longestSkipStreak, longestSkipStreak) ||
                other.longestSkipStreak == longestSkipStreak) &&
            (identical(other.lastSkipDate, lastSkipDate) ||
                other.lastSkipDate == lastSkipDate) &&
            (identical(other.mostCommonReason, mostCommonReason) ||
                other.mostCommonReason == mostCommonReason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_skippedDays),
      const DeepCollectionEquality().hash(_recoveredDays),
      totalSkips,
      totalRecoveries,
      currentSkipStreak,
      longestSkipStreak,
      lastSkipDate,
      mostCommonReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SkipTrackerImplCopyWith<_$SkipTrackerImpl> get copyWith =>
      __$$SkipTrackerImplCopyWithImpl<_$SkipTrackerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkipTrackerImplToJson(
      this,
    );
  }
}

abstract class _SkipTracker implements SkipTracker {
  const factory _SkipTracker(
      {required final Map<String, SkipEntry> skippedDays,
      required final Map<String, RecoveryEntry> recoveredDays,
      final int totalSkips,
      final int totalRecoveries,
      final int currentSkipStreak,
      final int longestSkipStreak,
      final DateTime? lastSkipDate,
      final String? mostCommonReason}) = _$SkipTrackerImpl;

  factory _SkipTracker.fromJson(Map<String, dynamic> json) =
      _$SkipTrackerImpl.fromJson;

  @override

  /// Map of date → skip entry
  Map<String, SkipEntry> get skippedDays;
  @override // String key for JSON serialization
  /// Map of original date → recovery entry
  Map<String, RecoveryEntry> get recoveredDays;
  @override // === ANALYTICS ===
  int get totalSkips;
  @override
  int get totalRecoveries;
  @override

  /// Consecutive skips (current)
  int get currentSkipStreak;
  @override

  /// Longest skip streak ever
  int get longestSkipStreak;
  @override

  /// Date of last skip
  DateTime? get lastSkipDate;
  @override

  /// Most common skip reason
  String? get mostCommonReason;
  @override
  @JsonKey(ignore: true)
  _$$SkipTrackerImplCopyWith<_$SkipTrackerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
