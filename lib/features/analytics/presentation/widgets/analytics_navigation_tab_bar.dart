library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Shared top-level analytics navigation tabs.
///
/// This keeps geometry stable across states and avoids the "selected tab grows"
/// effect caused by intrinsic width changes.
class AnalyticsNavigationTabBar extends StatelessWidget {
  const AnalyticsNavigationTabBar({
    required this.controller,
    required this.labels,
    super.key,
  });

  static const double preferredHeight = 60;

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final labelStyle = context.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: TabBar(
          controller: controller,
          onTap: (_) => HapticFeedback.selectionClick(),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          splashBorderRadius: AppBorderRadius.smRadius,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.12),
            borderRadius: AppBorderRadius.smRadius,
            border: Border.all(
              color: colorScheme.tertiary.withValues(alpha: 0.24),
            ),
          ),
          indicatorPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          labelColor: colorScheme.tertiary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: labelStyle,
          unselectedLabelStyle: labelStyle,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.tertiary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.tertiary.withValues(alpha: 0.04);
            }
            return null;
          }),
          tabs: [
            for (final label in labels) _AnalyticsNavigationTab(label: label),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsNavigationTab extends StatelessWidget {
  const _AnalyticsNavigationTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 44,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 88),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}

List<String> buildAnalyticsNavigationLabels(BuildContext context) {
  final l10n = context.l10n;
  final isItalian = Localizations.localeOf(context).languageCode == 'it';

  return [
    l10n.repZones,
    l10n.volume,
    isItalian ? 'Equilibrio' : 'Balance',
    isItalian ? l10n.stressIndex : 'Stress',
    l10n.analyticsTrendPlateau,
  ];
}
