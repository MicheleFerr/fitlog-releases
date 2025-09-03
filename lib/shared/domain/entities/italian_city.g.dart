// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'italian_city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItalianCityImpl _$$ItalianCityImplFromJson(Map<String, dynamic> json) =>
    _$ItalianCityImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zones:
          (json['zones'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      population: (json['population'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ItalianCityImplToJson(_$ItalianCityImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'region': instance.region,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'zones': instance.zones,
      'population': instance.population,
    };
