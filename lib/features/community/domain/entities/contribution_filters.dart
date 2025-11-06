import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

part 'contribution_filters.freezed.dart';
part 'contribution_filters.g.dart';

@freezed
class ContributionFilters with _$ContributionFilters {
  const factory ContributionFilters({
    @Default([]) List<String> exerciseIds,
    String? type, // correction, tip, warning, variant, translation, technique
    String? difficulty, // beginner, intermediate, advanced
    String? authorTier, // community, expert, admin
    DateTime? dateFrom,
    DateTime? dateTo,
    @Default('helpful') String sortBy, // helpful, recent, saved, trending
  }) = _ContributionFilters;

  factory ContributionFilters.fromJson(Map<String, dynamic> json) =>
      _$ContributionFiltersFromJson(json);
}

enum SortOption {
  helpful,
  recent,
  saved,
  trending,
}

extension SortOptionExtension on SortOption {
  String get value {
    switch (this) {
      case SortOption.helpful:
        return 'helpful';
      case SortOption.recent:
        return 'recent';
      case SortOption.saved:
        return 'saved';
      case SortOption.trending:
        return 'trending';
    }
  }

  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case SortOption.helpful:
        return l10n.sortByHelpful;
      case SortOption.recent:
        return l10n.sortByRecent;
      case SortOption.saved:
        return l10n.sortBySaved;
      case SortOption.trending:
        return l10n.sortByTrending;
    }
  }
}
