/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// AI Coach Card - main UI component integrating all AI insights widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_insights_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/expandable_insight_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Main AI Coach Card displayed on home screen
///
/// Integrates:
/// - InsightSeverityIndicator (badges)
/// - ExpandableInsightCard (expandable insights)
/// - InsightTrendChart (optional charts)
/// - Riverpod state management
///
/// Features:
/// - Loading state (LoadingIndicator)
/// - Error state with retry
/// - Empty state when no insights
/// - List of expandable insight cards
/// - Critical insights badge
///
/// Usage:
/// ```dart
/// AICoachCard() // ConsumerWidget - auto-watches providers
/// ```
class AICoachCard extends ConsumerWidget {
  const AICoachCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(aiInsightsProvider);
    final criticalCount = ref.watch(criticalInsightsCountProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, criticalCount),

          // Content (insights list)
          insightsAsync.when(
            data: (insights) => _buildInsightsList(context, insights),
            loading: () => _buildLoading(),
            error: (error, stack) => _buildError(context, ref),
          ),
        ],
      ),
    );
  }

  /// Build header with title and critical badge
  Widget _buildHeader(BuildContext context, int criticalCount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon
          SemanticIcon(
            icon: AppIcons.lightbulb,
            semanticLabel: context.l10n.aiCoach,
            size: AppIconSize.large,
            color: context.colors.primary,
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              context.l10n.aiCoach,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Critical insights badge (if any)
          if (criticalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: AppIcons.warning,
                    semanticLabel: context.l10n.criticalInsights(criticalCount),
                    size: AppIconSize.small,
                    color: context.colors.onError,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    criticalCount.toString(),
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colors.onError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build insights list
  Widget _buildInsightsList(BuildContext context, List<AIInsight> insights) {
    if (insights.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        const Divider(height: 1),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: insights.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final insight = insights[index];
            return ExpandableInsightCard(
              insight: insight,
              initiallyExpanded: index == 0, // First insight expanded
            );
          },
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 32),
          SemanticIcon(
            icon: AppIcons.checkCircle,
            semanticLabel: context.l10n.noInsights,
            size: 64,
            color: context.colors.success,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noInsights,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.noInsightsDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: LoadingIndicator(),
      ),
    );
  }

  /// Build error state with retry
  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 32),
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.error,
            size: 64,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.errorLoadingInsights,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.refresh(aiInsightsProvider),
            icon: SemanticIcon(
              icon: AppIcons.refresh,
              semanticLabel: context.l10n.retry,
              size: AppIconSize.medium,
            ),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
