// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddy_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuddyAction _$BuddyActionFromJson(Map<String, dynamic> json) {
  return _BuddyAction.fromJson(json);
}

/// @nodoc
mixin _$BuddyAction {
  String get id => throw _privateConstructorUsedError;
  String get fromUserId => throw _privateConstructorUsedError;
  String get toUserId => throw _privateConstructorUsedError;
  BuddyActionType get actionType => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError; // For reports
  ReportReason? get reportReason => throw _privateConstructorUsedError;
  String? get reportDescription =>
      throw _privateConstructorUsedError; // For super likes
  bool? get wasSuperLike =>
      throw _privateConstructorUsedError; // Matching result
  bool? get resultedInMatch => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BuddyActionCopyWith<BuddyAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyActionCopyWith<$Res> {
  factory $BuddyActionCopyWith(
          BuddyAction value, $Res Function(BuddyAction) then) =
      _$BuddyActionCopyWithImpl<$Res, BuddyAction>;
  @useResult
  $Res call(
      {String id,
      String fromUserId,
      String toUserId,
      BuddyActionType actionType,
      DateTime? createdAt,
      ReportReason? reportReason,
      String? reportDescription,
      bool? wasSuperLike,
      bool? resultedInMatch});
}

/// @nodoc
class _$BuddyActionCopyWithImpl<$Res, $Val extends BuddyAction>
    implements $BuddyActionCopyWith<$Res> {
  _$BuddyActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? actionType = null,
    Object? createdAt = freezed,
    Object? reportReason = freezed,
    Object? reportDescription = freezed,
    Object? wasSuperLike = freezed,
    Object? resultedInMatch = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as BuddyActionType,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reportReason: freezed == reportReason
          ? _value.reportReason
          : reportReason // ignore: cast_nullable_to_non_nullable
              as ReportReason?,
      reportDescription: freezed == reportDescription
          ? _value.reportDescription
          : reportDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      wasSuperLike: freezed == wasSuperLike
          ? _value.wasSuperLike
          : wasSuperLike // ignore: cast_nullable_to_non_nullable
              as bool?,
      resultedInMatch: freezed == resultedInMatch
          ? _value.resultedInMatch
          : resultedInMatch // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuddyActionImplCopyWith<$Res>
    implements $BuddyActionCopyWith<$Res> {
  factory _$$BuddyActionImplCopyWith(
          _$BuddyActionImpl value, $Res Function(_$BuddyActionImpl) then) =
      __$$BuddyActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fromUserId,
      String toUserId,
      BuddyActionType actionType,
      DateTime? createdAt,
      ReportReason? reportReason,
      String? reportDescription,
      bool? wasSuperLike,
      bool? resultedInMatch});
}

/// @nodoc
class __$$BuddyActionImplCopyWithImpl<$Res>
    extends _$BuddyActionCopyWithImpl<$Res, _$BuddyActionImpl>
    implements _$$BuddyActionImplCopyWith<$Res> {
  __$$BuddyActionImplCopyWithImpl(
      _$BuddyActionImpl _value, $Res Function(_$BuddyActionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? actionType = null,
    Object? createdAt = freezed,
    Object? reportReason = freezed,
    Object? reportDescription = freezed,
    Object? wasSuperLike = freezed,
    Object? resultedInMatch = freezed,
  }) {
    return _then(_$BuddyActionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as BuddyActionType,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reportReason: freezed == reportReason
          ? _value.reportReason
          : reportReason // ignore: cast_nullable_to_non_nullable
              as ReportReason?,
      reportDescription: freezed == reportDescription
          ? _value.reportDescription
          : reportDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      wasSuperLike: freezed == wasSuperLike
          ? _value.wasSuperLike
          : wasSuperLike // ignore: cast_nullable_to_non_nullable
              as bool?,
      resultedInMatch: freezed == resultedInMatch
          ? _value.resultedInMatch
          : resultedInMatch // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuddyActionImpl implements _BuddyAction {
  const _$BuddyActionImpl(
      {required this.id,
      required this.fromUserId,
      required this.toUserId,
      required this.actionType,
      this.createdAt,
      this.reportReason,
      this.reportDescription,
      this.wasSuperLike,
      this.resultedInMatch});

  factory _$BuddyActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyActionImplFromJson(json);

  @override
  final String id;
  @override
  final String fromUserId;
  @override
  final String toUserId;
  @override
  final BuddyActionType actionType;
  @override
  final DateTime? createdAt;
// For reports
  @override
  final ReportReason? reportReason;
  @override
  final String? reportDescription;
// For super likes
  @override
  final bool? wasSuperLike;
// Matching result
  @override
  final bool? resultedInMatch;

  @override
  String toString() {
    return 'BuddyAction(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, actionType: $actionType, createdAt: $createdAt, reportReason: $reportReason, reportDescription: $reportDescription, wasSuperLike: $wasSuperLike, resultedInMatch: $resultedInMatch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.reportReason, reportReason) ||
                other.reportReason == reportReason) &&
            (identical(other.reportDescription, reportDescription) ||
                other.reportDescription == reportDescription) &&
            (identical(other.wasSuperLike, wasSuperLike) ||
                other.wasSuperLike == wasSuperLike) &&
            (identical(other.resultedInMatch, resultedInMatch) ||
                other.resultedInMatch == resultedInMatch));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fromUserId,
      toUserId,
      actionType,
      createdAt,
      reportReason,
      reportDescription,
      wasSuperLike,
      resultedInMatch);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyActionImplCopyWith<_$BuddyActionImpl> get copyWith =>
      __$$BuddyActionImplCopyWithImpl<_$BuddyActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyActionImplToJson(
      this,
    );
  }
}

abstract class _BuddyAction implements BuddyAction {
  const factory _BuddyAction(
      {required final String id,
      required final String fromUserId,
      required final String toUserId,
      required final BuddyActionType actionType,
      final DateTime? createdAt,
      final ReportReason? reportReason,
      final String? reportDescription,
      final bool? wasSuperLike,
      final bool? resultedInMatch}) = _$BuddyActionImpl;

  factory _BuddyAction.fromJson(Map<String, dynamic> json) =
      _$BuddyActionImpl.fromJson;

  @override
  String get id;
  @override
  String get fromUserId;
  @override
  String get toUserId;
  @override
  BuddyActionType get actionType;
  @override
  DateTime? get createdAt;
  @override // For reports
  ReportReason? get reportReason;
  @override
  String? get reportDescription;
  @override // For super likes
  bool? get wasSuperLike;
  @override // Matching result
  bool? get resultedInMatch;
  @override
  @JsonKey(ignore: true)
  _$$BuddyActionImplCopyWith<_$BuddyActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
