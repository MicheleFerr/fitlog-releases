/// Recovery Insight Card
///
/// Compact card for home screen showing:
/// - Recovery score (0-100)
/// - Category indicator (5 dots)
/// - One-line recommendation
/// - Last night's sleep
///
/// **Always Visible**: Shows consent CTA if HealthKit not connected
/// **Tap Action**: Opens RecoveryInsightSheet with full details
library;

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/errors/healthkit_errors.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/presentation/extensions/recovery_category_l10n.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/presentation/extensions/recovery_recommendation_l10n.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/presentation/providers/recovery_insight_provider.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/presentation/widgets/recovery_insight_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Recovery Insight Card widget for home screen
class RecoveryInsightCard extends ConsumerStatefulWidget {
  const RecoveryInsightCard({super.key});

  @override
  ConsumerState<RecoveryInsightCard> createState() => _RecoveryInsightCardState();
}

class _RecoveryInsightCardState extends ConsumerState<RecoveryInsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insightAsync = ref.watch(recoveryInsightProvider);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: insightAsync.when(
            data: (insight) {
              // If no sleep data available, show the no-data card
              if (!insight.hasSleepData) {
                return _RecoveryInsightNoDataCard(
                  onRefresh: () => ref.invalidate(recoveryInsightProvider),
                );
              }
              return _RecoveryInsightCardContent(
                insight: insight,
                onTap: () => _showRecoverySheet(context),
              );
            },
            loading: () => _buildLoadingState(context),
            error: (e, _) => _buildErrorState(context, e),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: LoadingIndicator()),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    // Handle different error types with appropriate UI
    if (error is HealthKitNotAvailableError || error is HealthKitDisabledError) {
      // Platform not available - show info card
      return _RecoveryInsightPlatformCard();
    } else if (error is HealthKitNoDataError || error is HealthKitInvalidDataError) {
      // Connected but no data - show no data card
      return _RecoveryInsightNoDataCard(
        onRefresh: () => ref.invalidate(recoveryInsightProvider),
      );
    } else if (error is HealthKitSyncNetworkError ||
        error is HealthKitSyncTimeoutError ||
        error is HealthKitSyncServerError ||
        error is HealthKitSyncRateLimitError) {
      // Sync error - show retry card
      return _RecoveryInsightSyncErrorCard(
        onRetry: () => ref.invalidate(recoveryInsightProvider),
      );
    } else {
      // Permission errors or unknown - show connect card
      return _RecoveryInsightConnectCard(
        onConnect: () => _requestHealthKitPermissions(context),
      );
    }
  }

  Future<void> _requestHealthKitPermissions(BuildContext context) async {
    HapticFeedback.mediumImpact();

    if (!Platform.isIOS) {
      SnackBarService.showInfo(
        context,
        context.l10n.healthKitOnlyiOS,
      );
      return;
    }

    try {
      final datasource = ref.read(healthKitDatasourceProvider);
      await datasource.initialize();

      // Refresh the provider to get new data
      ref.invalidate(recoveryInsightProvider);

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.healthKitConnected,
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          context.l10n.healthKitPermissionDenied,
        );
      }
    }
  }

  Future<void> _showRecoverySheet(BuildContext context) async {
    HapticFeedback.lightImpact();

    // Use RecoveryInsightSheet.show() directly - it has its own DraggableScrollableSheet
    // Don't use ModalService.showBottomSheet which would create a double sheet
    await RecoveryInsightSheet.show(context);
  }
}

/// Card content with recovery insight data
class _RecoveryInsightCardContent extends StatelessWidget {
  const _RecoveryInsightCardContent({
    required this.insight,
    required this.onTap,
  });

  final RecoveryInsight insight;
  final VoidCallback onTap;

  Color _getCategoryColor(RecoveryCategory category, BuildContext context) {
    return switch (category) {
      RecoveryCategory.optimal => context.successColor,
      RecoveryCategory.good => context.successColor,
      RecoveryCategory.moderate => context.warningColor,
      RecoveryCategory.low => context.errorColor,
      RecoveryCategory.critical => context.errorColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final categoryColor = _getCategoryColor(insight.category, context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: Icon + Title + Score
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          AppIcons.bedtime,
                          color: categoryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recoveryInsight,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              insight.category.localizedName(context),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Score badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${insight.score}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress dots (5 dots showing category)
                  _buildProgressDots(context, categoryColor),
                  const SizedBox(height: 16),

                  // Recommendation text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.tip,
                          color: categoryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight.recommendation.localizedRecommendation(context),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sleep metrics row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        context,
                        icon: AppIcons.nightlight,
                        value: insight.formattedLastNight,
                        label: l10n.lastNight,
                        color: colorScheme.tertiary,
                      ),
                      _buildMetric(
                        context,
                        icon: AppIcons.barChart,
                        value: insight.formattedWeeklyAverage,
                        label: l10n.weeklyAverage,
                        color: colorScheme.secondary,
                      ),
                      if (insight.streakDays > 0)
                        _buildMetric(
                          context,
                          icon: AppIcons.streak,
                          value: '${insight.streakDays}',
                          label: l10n.streakDays,
                          color: context.successColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // View details hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.tapForDetails,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SemanticIcon(
                        icon: AppIcons.forward,
                        semanticLabel: 'View details',
                        size: AppIconSize.tiny,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots(BuildContext context, Color activeColor) {
    final colorScheme = Theme.of(context).colorScheme;
    final filledDots = insight.category.filledDots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isFilled = index < filledDots;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? activeColor
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: isFilled
                ? null
                : Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Card shown when HealthKit is not connected
/// Provides clear CTA to connect Apple Health
class _RecoveryInsightConnectCard extends StatelessWidget {
  const _RecoveryInsightConnectCard({
    required this.onConnect,
  });

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onConnect,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animated-like glow
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      AppIcons.bedtime,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    l10n.recoveryInsight,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    l10n.sleepTrackingDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Connect button
                  FilledButton.icon(
                    onPressed: onConnect,
                    icon: Icon(
                      Platform.isIOS ? AppIcons.apple : AppIcons.favorite,
                      size: 20,
                    ),
                    label: Text(l10n.connectAppleHealth),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Benefits row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBenefit(
                        context,
                        icon: AppIcons.nightlight,
                        label: l10n.sleepData,
                      ),
                      const SizedBox(width: 16),
                      _buildBenefit(
                        context,
                        icon: AppIcons.trendUp,
                        label: l10n.recoveryScore,
                      ),
                      const SizedBox(width: 16),
                      _buildBenefit(
                        context,
                        icon: AppIcons.tip,
                        label: l10n.personalizedTips,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Card shown when HealthKit is connected but has no sleep data
class _RecoveryInsightNoDataCard extends StatelessWidget {
  const _RecoveryInsightNoDataCard({
    required this.onRefresh,
  });

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.bedtime,
                color: colorScheme.tertiary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              l10n.recoveryInsight,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Description - HealthKit connected but no data
            Text(
              l10n.noSleepDataFound,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.tip,
                    color: colorScheme.tertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.trackSleepHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Refresh button
            TextButton.icon(
              onPressed: onRefresh,
              icon: const SemanticIcon(
                icon: AppIcons.refresh,
                semanticLabel: 'Refresh',
                size: AppIconSize.small,
              ),
              label: Text(l10n.refreshData),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card shown when HealthKit is not available on this platform
class _RecoveryInsightPlatformCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.bedtime,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              l10n.recoveryInsight,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              l10n.healthKitOnlyiOS,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card shown when there's a sync error
class _RecoveryInsightSyncErrorCard extends StatelessWidget {
  const _RecoveryInsightSyncErrorCard({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.wifiOff,
                color: colorScheme.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              l10n.recoveryInsight,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              l10n.syncErrorRetry,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Retry button
            FilledButton.icon(
              onPressed: onRetry,
              icon: const SemanticIcon(
                icon: AppIcons.refresh,
                semanticLabel: 'Retry',
                size: AppIconSize.small,
              ),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
