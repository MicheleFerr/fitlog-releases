/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// PRO ANALYTICS TABBED SCREEN
/// Premium analytics with tabbed interface for better organization.
///
/// Features:
/// - Tab 1: Rep Zone Distribution (Strength/Hypertrophy/Endurance)
/// - Tab 2: Volume Progression (Weekly trends)
/// - Tab 3: Muscle Balance (Push/Pull, Heatmap)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/rep_zone_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/volume_progression_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/muscle_balance_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/stress_index_tab.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Pro Analytics Tabbed Screen
///
/// Shows detailed analytics organized in tabs for easy navigation.
/// Premium users see full content, free users see preview with upgrade CTA.
class ProAnalyticsTabbedScreen extends ConsumerStatefulWidget {
  const ProAnalyticsTabbedScreen({super.key});

  @override
  ConsumerState<ProAnalyticsTabbedScreen> createState() =>
      _ProAnalyticsTabbedScreenState();
}

class _ProAnalyticsTabbedScreenState
    extends ConsumerState<ProAnalyticsTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;
    final isPremium = ref.watch(isPremiumUserProvider);

    // Get current user ID
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.proInsights)),
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    // Watch exercise histories
    final exerciseHistoriesAsync =
        ref.watch(exerciseHistoryStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.arrowBack, size: AppIconSize.medium),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Refresh button - clears cache and reloads analytics
          IconButton(
            icon: const Icon(AppIcons.refresh, size: AppIconSize.medium),
            tooltip: l10n.refreshData,
            onPressed: () async {
              await HapticFeedback.mediumImpact();

              // 1. Clear analytics cache
              final cacheService = ref.read(analyticsCacheServiceProvider);
              await cacheService.clear();

              // 2. Refresh analytics data
              ref.read(analyticsRefreshProvider)();

              // 3. Invalidate stress index for fresh calculation
              ref.invalidate(stressIndexNotifierProvider);

              // 4. Invalidate exercise history stream to refresh UI
              ref.invalidate(exerciseHistoryStreamProvider(userId));

              // 5. Show confirmation
              if (context.mounted) {
                SnackBarService.showSuccess(
                  context,
                  l10n.refreshed,
                );
              }
            },
          ),
        ],
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
                    style: context.textTheme.labelSmall?.copyWith(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => HapticFeedback.selectionClick(),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.tertiary.withValues(alpha: 0.2),
                    colorScheme.tertiary.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
              labelColor: colorScheme.tertiary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: context.textTheme.labelMedium,
              dividerColor: colorScheme.surface.withValues(alpha: 0),
              tabs: [
                _buildPremiumTab(
                  icon: AppIcons.barChart,
                  label: l10n.repZones,
                ),
                _buildPremiumTab(
                  icon: AppIcons.trendUp,
                  label: l10n.volume,
                ),
                _buildPremiumTab(
                  icon: AppIcons.accessibility,
                  label: l10n.muscleBalance,
                ),
                _buildPremiumTab(
                  icon: AppIcons.bolt,
                  label: l10n.stressIndex,
                ),
              ],
            ),
          ),
        ),
      ),
      body: exerciseHistoriesAsync.when(
        data: (exerciseHistories) {
          // Check if user is premium
          if (!isPremium) {
            return _buildPremiumGate(context);
          }

          // Get exercise muscle map for weighted distribution (70% primary, 30% secondary)
          final exerciseMuscleMapAsync = ref.watch(exerciseMuscleMapProvider);
          final exerciseMuscleMap = exerciseMuscleMapAsync.valueOrNull;

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Rep Zone Distribution
              RepZoneTab(exerciseHistories: exerciseHistories),

              // Tab 2: Volume Progression (with EMG-based distribution)
              VolumeProgressionTab(
                exerciseHistories: exerciseHistories,
                exerciseMuscleMap: exerciseMuscleMap,
              ),

              // Tab 3: Muscle Balance (with EMG-based distribution)
              MuscleBalanceTab(
                exerciseHistories: exerciseHistories,
                exerciseMuscleMap: exerciseMuscleMap,
              ),

              // Tab 4: Stress Index
              const StressIndexTab(),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildPremiumGate(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.lock,
                size: AppIconSize.xxlarge,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.unlockProAnalytics,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.proAnalyticsDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push(AppRoutes.premiumPath);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: colorScheme.onTertiary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(AppIcons.premium, size: AppIconSize.small),
              label: Text(
                l10n.upgradeToPro,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Center(
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
              style: context.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build premium-styled tab with icon and text inline
  Widget _buildPremiumTab({
    required IconData icon,
    required String label,
  }) {
    return Tab(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSize.small),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
