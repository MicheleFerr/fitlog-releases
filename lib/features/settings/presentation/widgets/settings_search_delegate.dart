/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/settings/presentation/widgets
/// Feature: Settings Search
/// Type: Widget
///
/// Search delegate for finding settings quickly.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Represents a searchable settings item
class SettingsSearchItem {
  const SettingsSearchItem({
    required this.title,
    required this.section,
    required this.keywords,
    required this.onTap,
  });

  final String title;
  final String section;
  final List<String> keywords;
  final VoidCallback onTap;
}

/// Search delegate for settings
class SettingsSearchDelegate extends SearchDelegate<SettingsSearchItem?> {
  SettingsSearchDelegate({
    required this.items,
    required this.searchHint,
    required this.emptySearchMessage,
    required this.noResultsMessage,
  });

  final List<SettingsSearchItem> items;
  final String searchHint;
  final String emptySearchMessage;
  final String noResultsMessage;

  @override
  String get searchFieldLabel => searchHint;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(AppIcons.close),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(AppIcons.back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.search,
              size: 48,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              emptySearchMessage,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final queryLower = query.toLowerCase();
    final results = items.where((item) {
      return item.title.toLowerCase().contains(queryLower) ||
          item.section.toLowerCase().contains(queryLower) ||
          item.keywords.any((k) => k.toLowerCase().contains(queryLower));
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.searchOff,
              size: 48,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$noResultsMessage "$query"',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Icon(
            AppIcons.settings,
            color: context.colors.primary,
          ),
          title: Text(item.title),
          subtitle: Text(
            item.section,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          trailing: const Icon(AppIcons.chevronRight),
          onTap: () {
            close(context, item);
            item.onTap();
          },
        );
      },
    );
  }
}
