/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// PRO INSIGHTS BADGE
/// Compact, clickable badge for Pro Analytics section.
/// Replaces inline ProAnalyticsSection in analytics overview.
///
/// Design:
/// - FREE users: Lock badge + "Unlock" text + tap to upgrade
/// - PREMIUM users: PRO badge + quick preview + tap to view details
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Compact Pro Insights Badge - Clickable card with PRO badge
///
/// Shows different content based on premium status:
/// - Free: Lock icon + upgrade CTA
/// - Premium: Quick stats preview + "View Details"
class ProInsightsBadge extends ConsumerWidget {
  const ProInsightsBadge({
    super.key,
    required this.exerciseHistories,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumUserProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    // Calculate quick stats for preview
    final stats = _calculateQuickStats();

    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (isPremium) {
          // Navigate to Pro Analytics screen
          context.push(AppRoutes.proAnalyticsPath);
        } else {
          // Navigate to premium purchase
          context.push(AppRoutes.premiumPath);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.tertiaryContainer.withValues(alpha: 0.4),
              colorScheme.secondaryContainer.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.tertiary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Left side: PRO badge + icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.tertiary,
                    colorScheme.tertiary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.tertiary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isPremium ? AppIcons.premium : AppIcons.lock,
                    size: AppIconSize.large,
                    color: colorScheme.onTertiary,
                  ),
                  const SizedBox(height: 4),
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
            const SizedBox(width: 16),

            // Center: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    l10n.proInsights,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle (different for free/premium)
                  if (isPremium) ...[
                    // Premium: Show quick stats
                    Text(
                      l10n.proInsightsPreview(
                        stats.strengthPercent,
                        stats.hypertrophyPercent,
                        stats.endurancePercent,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    // Free: Show unlock message
                    Text(
                      l10n.proInsightsSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right side: Arrow icon
            Icon(
              AppIcons.chevronRight,
              size: AppIconSize.medium,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate quick stats for preview
  _QuickStats _calculateQuickStats() {
    if (exerciseHistories.isEmpty) {
      return _QuickStats.empty();
    }

    // Calculate rep zone distribution (simplified)
    int strengthSets = 0; // 1-5 reps
    int hypertrophySets = 0; // 6-12 reps
    int enduranceSets = 0; // 13+ reps
    int totalSets = 0;

    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        for (final set in session.sets) {
          totalSets++;
          if (set.reps <= 5) {
            strengthSets++;
          } else if (set.reps <= 12) {
            hypertrophySets++;
          } else {
            enduranceSets++;
          }
        }
      }
    }

    return _QuickStats(
      strengthPercent:
          totalSets > 0 ? (strengthSets / totalSets * 100).round() : 33,
      hypertrophyPercent:
          totalSets > 0 ? (hypertrophySets / totalSets * 100).round() : 34,
      endurancePercent:
          totalSets > 0 ? (enduranceSets / totalSets * 100).round() : 33,
    );
  }
}

/// Quick stats for badge preview
class _QuickStats {
  const _QuickStats({
    required this.strengthPercent,
    required this.hypertrophyPercent,
    required this.endurancePercent,
  });

  factory _QuickStats.empty() => const _QuickStats(
        strengthPercent: 33,
        hypertrophyPercent: 34,
        endurancePercent: 33,
      );

  final int strengthPercent;
  final int hypertrophyPercent;
  final int endurancePercent;
}
