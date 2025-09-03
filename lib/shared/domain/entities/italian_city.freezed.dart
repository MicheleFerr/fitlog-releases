// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'italian_city.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ItalianCity _$ItalianCityFromJson(Map<String, dynamic> json) {
  return _ItalianCity.fromJson(json);
}

/// @nodoc
mixin _$ItalianCity {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  List<String> get zones => throw _privateConstructorUsedError;
  int get population => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItalianCityCopyWith<ItalianCity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItalianCityCopyWith<$Res> {
  factory $ItalianCityCopyWith(
          ItalianCity value, $Res Function(ItalianCity) then) =
      _$ItalianCityCopyWithImpl<$Res, ItalianCity>;
  @useResult
  $Res call(
      {String code,
      String name,
      String region,
      double latitude,
      double longitude,
      List<String> zones,
      int population});
}

/// @nodoc
class _$ItalianCityCopyWithImpl<$Res, $Val extends ItalianCity>
    implements $ItalianCityCopyWith<$Res> {
  _$ItalianCityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? region = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? zones = null,
    Object? population = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      zones: null == zones
          ? _value.zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<String>,
      population: null == population
          ? _value.population
          : population // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItalianCityImplCopyWith<$Res>
    implements $ItalianCityCopyWith<$Res> {
  factory _$$ItalianCityImplCopyWith(
          _$ItalianCityImpl value, $Res Function(_$ItalianCityImpl) then) =
      __$$ItalianCityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      String name,
      String region,
      double latitude,
      double longitude,
      List<String> zones,
      int population});
}

/// @nodoc
class __$$ItalianCityImplCopyWithImpl<$Res>
    extends _$ItalianCityCopyWithImpl<$Res, _$ItalianCityImpl>
    implements _$$ItalianCityImplCopyWith<$Res> {
  __$$ItalianCityImplCopyWithImpl(
      _$ItalianCityImpl _value, $Res Function(_$ItalianCityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? region = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? zones = null,
    Object? population = null,
  }) {
    return _then(_$ItalianCityImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      zones: null == zones
          ? _value._zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<String>,
      population: null == population
          ? _value.population
          : population // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItalianCityImpl implements _ItalianCity {
  const _$ItalianCityImpl(
      {required this.code,
      required this.name,
      required this.region,
      required this.latitude,
      required this.longitude,
      final List<String> zones = const [],
      this.population = 0})
      : _zones = zones;

  factory _$ItalianCityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItalianCityImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final String region;
  @override
  final double latitude;
  @override
  final double longitude;
  final List<String> _zones;
  @override
  @JsonKey()
  List<String> get zones {
    if (_zones is EqualUnmodifiableListView) return _zones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_zones);
  }

  @override
  @JsonKey()
  final int population;

  @override
  String toString() {
    return 'ItalianCity(code: $code, name: $name, region: $region, latitude: $latitude, longitude: $longitude, zones: $zones, population: $population)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItalianCityImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(other._zones, _zones) &&
            (identical(other.population, population) ||
                other.population == population));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, region, latitude,
      longitude, const DeepCollectionEquality().hash(_zones), population);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItalianCityImplCopyWith<_$ItalianCityImpl> get copyWith =>
      __$$ItalianCityImplCopyWithImpl<_$ItalianCityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItalianCityImplToJson(
      this,
    );
  }
}

abstract class _ItalianCity implements ItalianCity {
  const factory _ItalianCity(
      {required final String code,
      required final String name,
      required final String region,
      required final double latitude,
      required final double longitude,
      final List<String> zones,
      final int population}) = _$ItalianCityImpl;

  factory _ItalianCity.fromJson(Map<String, dynamic> json) =
      _$ItalianCityImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  String get region;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  List<String> get zones;
  @override
  int get population;
  @override
  @JsonKey(ignore: true)
  _$$ItalianCityImplCopyWith<_$ItalianCityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
