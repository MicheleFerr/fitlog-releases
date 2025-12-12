/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// PRO ANALYTICS SCREEN
/// Standalone screen for premium analytics with detailed charts and insights.
/// Accessible via /analytics/pro route.
///
/// Features:
/// - Rep zone distribution chart
/// - Volume progression over time
/// - Muscle balance analysis
/// - Premium-gated content with upgrade CTA for free users
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pro_analytics_section.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Pro Analytics Screen - Full-page view for premium analytics
///
/// Shows detailed analytics with interactive charts for premium users.
/// Free users see preview with upgrade CTA.
class ProAnalyticsScreen extends ConsumerWidget {
  const ProAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get current user ID
    final userId = ref.watch(currentUserIdProvider);

    // Watch exercise histories from analytics provider
    final exerciseHistoriesAsync = ref.watch(exerciseHistoryStreamProvider(userId!));

    return Scaffold(
      // Custom app bar with gradient
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, size: AppIconSize.medium),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            // PRO badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.tertiary,
                    colorScheme.tertiary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.premium,
                    size: AppIconSize.tiny,
                    color: colorScheme.onTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.proInsights),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
      ),
      body: exerciseHistoriesAsync.when(
        data: (exerciseHistories) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.proAnalyticsTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.proAnalyticsDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pro Analytics Section (full widget)
                ProAnalyticsSection(exerciseHistories: exerciseHistories),
              ],
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.error,
                  size: AppIconSize.xxlarge,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingData,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
