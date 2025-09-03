// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ice_breaker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IceBreaker _$IceBreakerFromJson(Map<String, dynamic> json) {
  return _IceBreaker.fromJson(json);
}

/// @nodoc
mixin _$IceBreaker {
  String get id => throw _privateConstructorUsedError;
  String get messageTemplate => throw _privateConstructorUsedError;
  IceBreakerCategory get category => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IceBreakerCopyWith<IceBreaker> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IceBreakerCopyWith<$Res> {
  factory $IceBreakerCopyWith(
          IceBreaker value, $Res Function(IceBreaker) then) =
      _$IceBreakerCopyWithImpl<$Res, IceBreaker>;
  @useResult
  $Res call(
      {String id,
      String messageTemplate,
      IceBreakerCategory category,
      List<String> tags,
      bool isActive,
      int usageCount});
}

/// @nodoc
class _$IceBreakerCopyWithImpl<$Res, $Val extends IceBreaker>
    implements $IceBreakerCopyWith<$Res> {
  _$IceBreakerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageTemplate = null,
    Object? category = null,
    Object? tags = null,
    Object? isActive = null,
    Object? usageCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageTemplate: null == messageTemplate
          ? _value.messageTemplate
          : messageTemplate // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as IceBreakerCategory,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IceBreakerImplCopyWith<$Res>
    implements $IceBreakerCopyWith<$Res> {
  factory _$$IceBreakerImplCopyWith(
          _$IceBreakerImpl value, $Res Function(_$IceBreakerImpl) then) =
      __$$IceBreakerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String messageTemplate,
      IceBreakerCategory category,
      List<String> tags,
      bool isActive,
      int usageCount});
}

/// @nodoc
class __$$IceBreakerImplCopyWithImpl<$Res>
    extends _$IceBreakerCopyWithImpl<$Res, _$IceBreakerImpl>
    implements _$$IceBreakerImplCopyWith<$Res> {
  __$$IceBreakerImplCopyWithImpl(
      _$IceBreakerImpl _value, $Res Function(_$IceBreakerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageTemplate = null,
    Object? category = null,
    Object? tags = null,
    Object? isActive = null,
    Object? usageCount = null,
  }) {
    return _then(_$IceBreakerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      messageTemplate: null == messageTemplate
          ? _value.messageTemplate
          : messageTemplate // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as IceBreakerCategory,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IceBreakerImpl implements _IceBreaker {
  const _$IceBreakerImpl(
      {required this.id,
      required this.messageTemplate,
      required this.category,
      final List<String> tags = const [],
      this.isActive = true,
      this.usageCount = 0})
      : _tags = tags;

  factory _$IceBreakerImpl.fromJson(Map<String, dynamic> json) =>
      _$$IceBreakerImplFromJson(json);

  @override
  final String id;
  @override
  final String messageTemplate;
  @override
  final IceBreakerCategory category;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int usageCount;

  @override
  String toString() {
    return 'IceBreaker(id: $id, messageTemplate: $messageTemplate, category: $category, tags: $tags, isActive: $isActive, usageCount: $usageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IceBreakerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageTemplate, messageTemplate) ||
                other.messageTemplate == messageTemplate) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, messageTemplate, category,
      const DeepCollectionEquality().hash(_tags), isActive, usageCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IceBreakerImplCopyWith<_$IceBreakerImpl> get copyWith =>
      __$$IceBreakerImplCopyWithImpl<_$IceBreakerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IceBreakerImplToJson(
      this,
    );
  }
}

abstract class _IceBreaker implements IceBreaker {
  const factory _IceBreaker(
      {required final String id,
      required final String messageTemplate,
      required final IceBreakerCategory category,
      final List<String> tags,
      final bool isActive,
      final int usageCount}) = _$IceBreakerImpl;

  factory _IceBreaker.fromJson(Map<String, dynamic> json) =
      _$IceBreakerImpl.fromJson;

  @override
  String get id;
  @override
  String get messageTemplate;
  @override
  IceBreakerCategory get category;
  @override
  List<String> get tags;
  @override
  bool get isActive;
  @override
  int get usageCount;
  @override
  @JsonKey(ignore: true)
  _$$IceBreakerImplCopyWith<_$IceBreakerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
