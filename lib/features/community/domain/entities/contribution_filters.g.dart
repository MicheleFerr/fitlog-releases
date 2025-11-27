// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContributionFilters _$ContributionFiltersFromJson(Map<String, dynamic> json) =>
    _ContributionFilters(
      exerciseIds:
          (json['exerciseIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      type: json['type'] as String?,
      difficulty: json['difficulty'] as String?,
      authorTier: json['authorTier'] as String?,
      dateFrom: json['dateFrom'] == null
          ? null
          : DateTime.parse(json['dateFrom'] as String),
      dateTo: json['dateTo'] == null
          ? null
          : DateTime.parse(json['dateTo'] as String),
      sortBy: json['sortBy'] as String? ?? 'helpful',
    );

Map<String, dynamic> _$ContributionFiltersToJson(
  _ContributionFilters instance,
) => <String, dynamic>{
  'exerciseIds': instance.exerciseIds,
  'type': instance.type,
  'difficulty': instance.difficulty,
  'authorTier': instance.authorTier,
  'dateFrom': instance.dateFrom?.toIso8601String(),
  'dateTo': instance.dateTo?.toIso8601String(),
  'sortBy': instance.sortBy,
};
