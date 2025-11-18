// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiet_hours.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QuietHours _$QuietHoursFromJson(Map<String, dynamic> json) {
  return _QuietHours.fromJson(json);
}

/// @nodoc
mixin _$QuietHours {
  /// Start time (hour component 0-23, minute component 0-59)
  /// Example: DateTime(2024, 1, 1, 22, 0) = 22:00
  DateTime get startTime => throw _privateConstructorUsedError;

  /// End time (hour component 0-23, minute component 0-59)
  /// Example: DateTime(2024, 1, 1, 8, 0) = 08:00
  /// Note: If end < start, assumes overnight (e.g., 22:00 - 08:00)
  DateTime get endTime => throw _privateConstructorUsedError;

  /// Allow high-priority notifications to bypass quiet hours
  /// Default: true (critical alerts always allowed)
  bool get allowPriorityBypass => throw _privateConstructorUsedError;

  /// Days of week when quiet hours apply (1=Monday, 7=Sunday)
  /// Empty list = applies every day
  /// Example: [1,2,3,4,5] = weekdays only
  List<int> get daysOfWeek => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuietHoursCopyWith<QuietHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuietHoursCopyWith<$Res> {
  factory $QuietHoursCopyWith(
          QuietHours value, $Res Function(QuietHours) then) =
      _$QuietHoursCopyWithImpl<$Res, QuietHours>;
  @useResult
  $Res call(
      {DateTime startTime,
      DateTime endTime,
      bool allowPriorityBypass,
      List<int> daysOfWeek});
}

/// @nodoc
class _$QuietHoursCopyWithImpl<$Res, $Val extends QuietHours>
    implements $QuietHoursCopyWith<$Res> {
  _$QuietHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? allowPriorityBypass = null,
    Object? daysOfWeek = null,
  }) {
    return _then(_value.copyWith(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      allowPriorityBypass: null == allowPriorityBypass
          ? _value.allowPriorityBypass
          : allowPriorityBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      daysOfWeek: null == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuietHoursImplCopyWith<$Res>
    implements $QuietHoursCopyWith<$Res> {
  factory _$$QuietHoursImplCopyWith(
          _$QuietHoursImpl value, $Res Function(_$QuietHoursImpl) then) =
      __$$QuietHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime startTime,
      DateTime endTime,
      bool allowPriorityBypass,
      List<int> daysOfWeek});
}

/// @nodoc
class __$$QuietHoursImplCopyWithImpl<$Res>
    extends _$QuietHoursCopyWithImpl<$Res, _$QuietHoursImpl>
    implements _$$QuietHoursImplCopyWith<$Res> {
  __$$QuietHoursImplCopyWithImpl(
      _$QuietHoursImpl _value, $Res Function(_$QuietHoursImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
    Object? allowPriorityBypass = null,
    Object? daysOfWeek = null,
  }) {
    return _then(_$QuietHoursImpl(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      allowPriorityBypass: null == allowPriorityBypass
          ? _value.allowPriorityBypass
          : allowPriorityBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      daysOfWeek: null == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuietHoursImpl implements _QuietHours {
  const _$QuietHoursImpl(
      {required this.startTime,
      required this.endTime,
      this.allowPriorityBypass = true,
      final List<int> daysOfWeek = const []})
      : _daysOfWeek = daysOfWeek;

  factory _$QuietHoursImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuietHoursImplFromJson(json);

  /// Start time (hour component 0-23, minute component 0-59)
  /// Example: DateTime(2024, 1, 1, 22, 0) = 22:00
  @override
  final DateTime startTime;

  /// End time (hour component 0-23, minute component 0-59)
  /// Example: DateTime(2024, 1, 1, 8, 0) = 08:00
  /// Note: If end < start, assumes overnight (e.g., 22:00 - 08:00)
  @override
  final DateTime endTime;

  /// Allow high-priority notifications to bypass quiet hours
  /// Default: true (critical alerts always allowed)
  @override
  @JsonKey()
  final bool allowPriorityBypass;

  /// Days of week when quiet hours apply (1=Monday, 7=Sunday)
  /// Empty list = applies every day
  /// Example: [1,2,3,4,5] = weekdays only
  final List<int> _daysOfWeek;

  /// Days of week when quiet hours apply (1=Monday, 7=Sunday)
  /// Empty list = applies every day
  /// Example: [1,2,3,4,5] = weekdays only
  @override
  @JsonKey()
  List<int> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfWeek);
  }

  @override
  String toString() {
    return 'QuietHours(startTime: $startTime, endTime: $endTime, allowPriorityBypass: $allowPriorityBypass, daysOfWeek: $daysOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuietHoursImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.allowPriorityBypass, allowPriorityBypass) ||
                other.allowPriorityBypass == allowPriorityBypass) &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, startTime, endTime,
      allowPriorityBypass, const DeepCollectionEquality().hash(_daysOfWeek));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuietHoursImplCopyWith<_$QuietHoursImpl> get copyWith =>
      __$$QuietHoursImplCopyWithImpl<_$QuietHoursImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuietHoursImplToJson(
      this,
    );
  }
}

abstract class _QuietHours implements QuietHours {
  const factory _QuietHours(
      {required final DateTime startTime,
      required final DateTime endTime,
      final bool allowPriorityBypass,
      final List<int> daysOfWeek}) = _$QuietHoursImpl;

  factory _QuietHours.fromJson(Map<String, dynamic> json) =
      _$QuietHoursImpl.fromJson;

  @override

  /// Start time (hour component 0-23, minute component 0-59)
  /// Example: DateTime(2024, 1, 1, 22, 0) = 22:00
  DateTime get startTime;
  @override

  /// End time (hour component 0-23, minute component 0-59)
  /// Example: DateTime(2024, 1, 1, 8, 0) = 08:00
  /// Note: If end < start, assumes overnight (e.g., 22:00 - 08:00)
  DateTime get endTime;
  @override

  /// Allow high-priority notifications to bypass quiet hours
  /// Default: true (critical alerts always allowed)
  bool get allowPriorityBypass;
  @override

  /// Days of week when quiet hours apply (1=Monday, 7=Sunday)
  /// Empty list = applies every day
  /// Example: [1,2,3,4,5] = weekdays only
  List<int> get daysOfWeek;
  @override
  @JsonKey(ignore: true)
  _$$QuietHoursImplCopyWith<_$QuietHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
