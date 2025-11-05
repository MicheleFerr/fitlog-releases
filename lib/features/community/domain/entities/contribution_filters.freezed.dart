// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribution_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ContributionFilters _$ContributionFiltersFromJson(Map<String, dynamic> json) {
  return _ContributionFilters.fromJson(json);
}

/// @nodoc
mixin _$ContributionFilters {
  List<String> get exerciseIds => throw _privateConstructorUsedError;
  String? get type =>
      throw _privateConstructorUsedError; // correction, tip, warning, variant, translation, technique
  String? get difficulty =>
      throw _privateConstructorUsedError; // beginner, intermediate, advanced
  String? get authorTier =>
      throw _privateConstructorUsedError; // community, expert, admin
  DateTime? get dateFrom => throw _privateConstructorUsedError;
  DateTime? get dateTo => throw _privateConstructorUsedError;
  String get sortBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ContributionFiltersCopyWith<ContributionFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContributionFiltersCopyWith<$Res> {
  factory $ContributionFiltersCopyWith(
          ContributionFilters value, $Res Function(ContributionFilters) then) =
      _$ContributionFiltersCopyWithImpl<$Res, ContributionFilters>;
  @useResult
  $Res call(
      {List<String> exerciseIds,
      String? type,
      String? difficulty,
      String? authorTier,
      DateTime? dateFrom,
      DateTime? dateTo,
      String sortBy});
}

/// @nodoc
class _$ContributionFiltersCopyWithImpl<$Res, $Val extends ContributionFilters>
    implements $ContributionFiltersCopyWith<$Res> {
  _$ContributionFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseIds = null,
    Object? type = freezed,
    Object? difficulty = freezed,
    Object? authorTier = freezed,
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? sortBy = null,
  }) {
    return _then(_value.copyWith(
      exerciseIds: null == exerciseIds
          ? _value.exerciseIds
          : exerciseIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      authorTier: freezed == authorTier
          ? _value.authorTier
          : authorTier // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFrom: freezed == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateTo: freezed == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContributionFiltersImplCopyWith<$Res>
    implements $ContributionFiltersCopyWith<$Res> {
  factory _$$ContributionFiltersImplCopyWith(_$ContributionFiltersImpl value,
          $Res Function(_$ContributionFiltersImpl) then) =
      __$$ContributionFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> exerciseIds,
      String? type,
      String? difficulty,
      String? authorTier,
      DateTime? dateFrom,
      DateTime? dateTo,
      String sortBy});
}

/// @nodoc
class __$$ContributionFiltersImplCopyWithImpl<$Res>
    extends _$ContributionFiltersCopyWithImpl<$Res, _$ContributionFiltersImpl>
    implements _$$ContributionFiltersImplCopyWith<$Res> {
  __$$ContributionFiltersImplCopyWithImpl(_$ContributionFiltersImpl _value,
      $Res Function(_$ContributionFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseIds = null,
    Object? type = freezed,
    Object? difficulty = freezed,
    Object? authorTier = freezed,
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? sortBy = null,
  }) {
    return _then(_$ContributionFiltersImpl(
      exerciseIds: null == exerciseIds
          ? _value._exerciseIds
          : exerciseIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      authorTier: freezed == authorTier
          ? _value.authorTier
          : authorTier // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFrom: freezed == dateFrom
          ? _value.dateFrom
          : dateFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateTo: freezed == dateTo
          ? _value.dateTo
          : dateTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContributionFiltersImpl implements _ContributionFilters {
  const _$ContributionFiltersImpl(
      {final List<String> exerciseIds = const [],
      this.type,
      this.difficulty,
      this.authorTier,
      this.dateFrom,
      this.dateTo,
      this.sortBy = 'helpful'})
      : _exerciseIds = exerciseIds;

  factory _$ContributionFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContributionFiltersImplFromJson(json);

  final List<String> _exerciseIds;
  @override
  @JsonKey()
  List<String> get exerciseIds {
    if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseIds);
  }

  @override
  final String? type;
// correction, tip, warning, variant, translation, technique
  @override
  final String? difficulty;
// beginner, intermediate, advanced
  @override
  final String? authorTier;
// community, expert, admin
  @override
  final DateTime? dateFrom;
  @override
  final DateTime? dateTo;
  @override
  @JsonKey()
  final String sortBy;

  @override
  String toString() {
    return 'ContributionFilters(exerciseIds: $exerciseIds, type: $type, difficulty: $difficulty, authorTier: $authorTier, dateFrom: $dateFrom, dateTo: $dateTo, sortBy: $sortBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContributionFiltersImpl &&
            const DeepCollectionEquality()
                .equals(other._exerciseIds, _exerciseIds) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.authorTier, authorTier) ||
                other.authorTier == authorTier) &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_exerciseIds),
      type,
      difficulty,
      authorTier,
      dateFrom,
      dateTo,
      sortBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContributionFiltersImplCopyWith<_$ContributionFiltersImpl> get copyWith =>
      __$$ContributionFiltersImplCopyWithImpl<_$ContributionFiltersImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContributionFiltersImplToJson(
      this,
    );
  }
}

abstract class _ContributionFilters implements ContributionFilters {
  const factory _ContributionFilters(
      {final List<String> exerciseIds,
      final String? type,
      final String? difficulty,
      final String? authorTier,
      final DateTime? dateFrom,
      final DateTime? dateTo,
      final String sortBy}) = _$ContributionFiltersImpl;

  factory _ContributionFilters.fromJson(Map<String, dynamic> json) =
      _$ContributionFiltersImpl.fromJson;

  @override
  List<String> get exerciseIds;
  @override
  String? get type;
  @override // correction, tip, warning, variant, translation, technique
  String? get difficulty;
  @override // beginner, intermediate, advanced
  String? get authorTier;
  @override // community, expert, admin
  DateTime? get dateFrom;
  @override
  DateTime? get dateTo;
  @override
  String get sortBy;
  @override
  @JsonKey(ignore: true)
  _$$ContributionFiltersImplCopyWith<_$ContributionFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
