import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/ai_coach_provider.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/insight_feedback_provider.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/exercise_replacement_dialog.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/feedback_history_modal.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_coach_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as exercise_db;
import 'package:gymbro_flutter_new/shared/data/services/interstitial_ad_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/chat_modal_content.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// AI Coach card with minimal design (progressive disclosure pattern)
///
/// **UX Pattern**: Similar to ConsistencyScoreWidget
/// - Compact homepage card (~150px)
/// - Primary action: Open chatbot (prominent button)
/// - Secondary action: View detailed insights (tap card or button)
/// - Progressive disclosure: Minimal info → Details modal → Full insight modal
class AICoachCard extends ConsumerStatefulWidget {
  const AICoachCard({super.key});

  @override
  ConsumerState<AICoachCard> createState() => _AICoachCardState();
}

class _AICoachCardState extends ConsumerState<AICoachCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Simple fade-in animation
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
    // Fetch data with select to avoid unnecessary rebuilds
    final quickStatsAsync = ref.watch(quickStatsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final frequencyAsync = ref.watch(weeklyFrequencyProvider);
    final primaryAdviceAsync = ref.watch(primaryAIAdviceProvider);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _MinimalAICoachCard(
            primaryAdviceAsync: primaryAdviceAsync,
            quickStatsAsync: quickStatsAsync,
            frequencyAsync: frequencyAsync,
            streakAsync: streakAsync,
            onChatTap: () => _openChatbot(context),
            onDetailsTap: () => _showInsightsModal(context, ref),
          ),
        );
      },
    );
  }

  /// Open AI Coach chatbot modal
  Future<void> _openChatbot(BuildContext context) async {
    HapticFeedback.lightImpact();

    await ModalService.showBottomSheet(
      context,
      child: const ChatModalContent(),
    );
  }

  /// Show AI Insights modal (Level 1: compact insights list)
  Future<void> _showInsightsModal(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();

    // Show Ad (disabled in debug by service)
    final adService = InterstitialAdService();
    await adService.showAdIfReady();

    if (!context.mounted) return;

    await ModalService.showBottomSheet(
      context,
      child: const AIInsightsModal(),
    );
  }
}

/// Minimal AI Coach Card (homepage)
///
/// Design: One-line primary advice + 3 mini metrics + 2 buttons
/// Height: ~150px (vs previous ~300px)
class _MinimalAICoachCard extends StatelessWidget {
  const _MinimalAICoachCard({
    required this.primaryAdviceAsync,
    required this.quickStatsAsync,
    required this.frequencyAsync,
    required this.streakAsync,
    required this.onChatTap,
    required this.onDetailsTap,
  });

  final AsyncValue<String> primaryAdviceAsync;
  final AsyncValue<QuickStats?> quickStatsAsync;
  final AsyncValue<double> frequencyAsync;
  final AsyncValue<int> streakAsync;
  final VoidCallback onChatTap;
  final VoidCallback onDetailsTap;

  int _calculateConsistency(double weeklyFrequency) {
    final consistency = ((weeklyFrequency / 4.0) * 100).clamp(0, 100);
    return consistency.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.5,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 1.0),
            colorScheme.secondaryContainer.withValues(alpha: 0.9),
            colorScheme.tertiaryContainer.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.colors.surface.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Icon + Title + Badge
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.8),
                            colorScheme.secondary.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        AppIcons.ai,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.aiCoach,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: AppSpacing.chip,
                      decoration: BoxDecoration(
                        color: context.infoContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.aiBadge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: context.infoColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Primary Advice (one line)
                Row(
                  children: [
                    Icon(
                      AppIcons.tip,
                      color: colorScheme.tertiary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: primaryAdviceAsync.when(
                        data: (advice) => Text(
                          advice,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => Text(
                          l10n.loading,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        error: (_, __) => Text(
                          l10n.aiCoachFirstWorkout,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3 Mini Metrics (compact)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniMetric(
                      icon: AppIcons.trendUp,
                      value: quickStatsAsync.asData?.value?.formattedVolumeIncrease ?? '--',
                      label: l10n.volume,
                      color: colorScheme.primary,
                    ),
                    _MiniMetric(
                      icon: AppIcons.trackChanges,
                      value: frequencyAsync.asData != null
                          ? '${_calculateConsistency(frequencyAsync.asData!.value)}%'
                          : '--',
                      label: l10n.consistency,
                      color: colorScheme.secondary,
                    ),
                    _MiniMetric(
                      icon: AppIcons.streak,
                      value: '${streakAsync.asData?.value ?? 0}d',
                      label: l10n.streak,
                      color: colorScheme.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Two Buttons: Chat (primary) + Details (secondary)
                Row(
                  children: [
                    // Primary: Chat button (prominent)
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: onChatTap,
                        icon: const SemanticIcon(
  icon: AppIcons.chat,
  semanticLabel: 'Chat',
  size: AppIconSize.small,
),
                        label: Text(l10n.aiCoach),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Secondary: Details button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDetailsTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          l10n.details,
                          style: context.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini metric widget (compact)
class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// AI Insights Modal (Level 1: Compact insights list)
///
/// Design: Lista insights compatta (NO expansion on this level)
/// Tap insight → Opens Level 2 modal with full details
class AIInsightsModal extends ConsumerStatefulWidget {
  const AIInsightsModal({super.key});

  @override
  ConsumerState<AIInsightsModal> createState() => _AIInsightsModalState();
}

class _AIInsightsModalState extends ConsumerState<AIInsightsModal> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final insightsAsync = ref.watch(aiCoachInsightsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              Icon(
                AppIcons.psychology,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.aiCoachDetailed,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Chat button
              IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  await ModalService.showBottomSheet(
                    context,
                    child: const ChatModalContent(),
                  );
                },
                icon: Icon(
                  AppIcons.chat,
                  color: colorScheme.primary,
                ),
                tooltip: l10n.aiCoach,
              ),
              // Feedback history button
              IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await ModalService.showBottomSheet(
                    context,
                    child: const FeedbackHistoryModal(),
                  );
                },
                icon: Icon(
                  AppIcons.history,
                  color: colorScheme.primary,
                ),
                tooltip: l10n.viewMyFeedback,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: insightsAsync.when(
              data: (insights) {
                return insights.isEmpty
                    ? _buildEmptyState(l10n, theme, colorScheme)
                    : _buildCompactInsightsList(context, ref, insights, l10n, theme, colorScheme);
              },
              loading: () => const LoadingIndicator(),
              error: (e, s) => _buildEmptyState(l10n, theme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic l10n, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.analytics,
  semanticLabel: 'Analytics',
  size: AppIconSize.medium,
  color: colorScheme.primary.withValues(alpha: 0.8,
),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aiCoachModalPlaceholder,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              await ModalService.showBottomSheet(
                context,
                child: const ChatModalContent(),
              );
            },
            icon: const SemanticIcon(
  icon: AppIcons.chat,
  semanticLabel: 'Chat',
),
            label: Text(l10n.aiCoach),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact insights list (NO expansion, just tap to open Level 2 modal)
  Widget _buildCompactInsightsList(
    BuildContext context,
    WidgetRef ref,
    List<AIInsight> insights,
    dynamic l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        return _CompactInsightCard(
          insight: insight,
          onTap: () => _openInsightDetailsModal(context, ref, insight),
        );
      },
    );
  }

  /// Open Level 2 modal with full insight details
  Future<void> _openInsightDetailsModal(
    BuildContext context,
    WidgetRef ref,
    AIInsight insight,
  ) async {
    HapticFeedback.lightImpact();

    await ModalService.showBottomSheet(
      context,
      child: InsightDetailsModal(insight: insight),
    );
  }
}

/// Compact Insight Card (Level 1: Lista compatta)
///
/// Design: Icon + Title + Badge + Key Metric
/// No expansion, tap opens Level 2 modal
class _CompactInsightCard extends StatelessWidget {
  const _CompactInsightCard({
    required this.insight,
    required this.onTap,
  });

  final AIInsight insight;
  final VoidCallback onTap;

  Color _getSeverityColor(InsightSeverity severity, ColorScheme colorScheme, BuildContext context) {
    return switch (severity) {
      InsightSeverity.critical => context.errorColor,
      InsightSeverity.warning => context.warningColor,
      InsightSeverity.info => context.infoColor,
      InsightSeverity.success => context.successColor,
    };
  }

  IconData _getInsightTypeIcon(InsightType type) {
    return switch (type) {
      InsightType.muscleGroupBalance => AppIcons.balance,
      InsightType.progressOverload => AppIcons.trendingUp,
      InsightType.recoveryPattern => AppIcons.bedtime,
      InsightType.volumeOptimization => AppIcons.tune,
      InsightType.frequencyRecommendation => AppIcons.schedule,
      InsightType.plateauBreaker => AppIcons.trendingFlat,
      InsightType.formWarning => AppIcons.warning,
      InsightType.motivational => AppIcons.celebration,
    };
  }

  String _getSeverityLabel(InsightSeverity severity, dynamic l10n) {
    return switch (severity) {
      InsightSeverity.critical => l10n.badgeCritical,
      InsightSeverity.warning => l10n.badgeWarning,
      InsightSeverity.info => l10n.badgeInfo,
      InsightSeverity.success => l10n.badgeSuccess,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final severity = insight.effectiveSeverity;
    final cardColor = _getSeverityColor(severity, colorScheme, context);
    final icon = _getInsightTypeIcon(insight.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: cardColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Title + Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getSeverityLabel(severity, l10n),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Forward arrow
                SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
  size: AppIconSize.tiny,
  color: colorScheme.onSurface.withValues(alpha: 0.4,
),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Insight Details Modal (Level 2: Full details)
///
/// Contains all the detailed information from original ExpansionTile
class InsightDetailsModal extends ConsumerStatefulWidget {
  const InsightDetailsModal({
    super.key,
    required this.insight,
  });

  final AIInsight insight;

  @override
  ConsumerState<InsightDetailsModal> createState() => _InsightDetailsModalState();
}

class _InsightDetailsModalState extends ConsumerState<InsightDetailsModal> {
  bool _isReplacingExercise = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final insight = widget.insight;
    final severity = insight.effectiveSeverity;
    final cardColor = _getSeverityColor(severity, colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content (scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    insight.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recommendation box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        SemanticIcon(
  icon: AppIcons.recommend,
  semanticLabel: 'Recommend',
  size: AppIconSize.small,
  color: cardColor,
),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            insight.recommendation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Additional sections (if available)
                  if (insight.detailedAnalysis != null) ...[
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      l10n.whyThisMatters,
                      insight.detailedAnalysis!,
                      AppIcons.analytics,
                      cardColor,
                    ),
                  ],

                  if (insight.dataPoints != null && insight.dataPoints!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildDataPointsSection(
                      context,
                      l10n.yourData,
                      insight.dataPoints!,
                      cardColor,
                    ),
                  ],

                  if (insight.strategies != null && insight.strategies!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildStrategiesSection(
                      context,
                      l10n.evidenceBasedSolutions,
                      insight.strategies!,
                      cardColor,
                    ),
                  ],

                  if (insight.scientificReference != null) ...[
                    const SizedBox(height: 20),
                    _buildScientificReference(
                      context,
                      insight.scientificReference!,
                      cardColor,
                    ),
                  ],

                  // Feedback widget
                  const SizedBox(height: 20),
                  _buildFeedbackWidget(context, ref, insight, theme, colorScheme),

                  // Action button (if applicable)
                  if (insight.hasAction) ...[
                    const SizedBox(height: 20),
                    _buildActionButton(context, ref, insight, l10n, cardColor),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDataPointsSection(
    BuildContext context,
    String title,
    List<String> dataPoints,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
  icon: AppIcons.barChart,
  semanticLabel: 'Chart',
  size: AppIconSize.small,
  color: color,
),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...dataPoints.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticIcon(
  icon: AppIcons.fiberManualRecord,
  semanticLabel: 'Fiber manual record',
  size: AppIconSize.medium,
  color: color,
),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildStrategiesSection(
    BuildContext context,
    String title,
    List<ScientificStrategy> strategies,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
  icon: AppIcons.ai,
  semanticLabel: 'Ai',
  size: AppIconSize.small,
  color: color,
),
            const SizedBox(width: 8),
            Text(
              '🎯 $title',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...strategies.map((strategy) => _buildStrategyCard(
              context,
              strategy,
              color,
            )),
      ],
    );
  }

  Widget _buildStrategyCard(
    BuildContext context,
    ScientificStrategy strategy,
    Color color,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strategy.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strategy.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SemanticIcon(
  icon: AppIcons.playArrow,
  semanticLabel: 'Play arrow',
  size: AppIconSize.tiny,
  color: color,
),
                    const SizedBox(width: 6),
                    Text(
                      l10n.howToImplement,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  strategy.howToImplement,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SemanticIcon(
  icon: AppIcons.timeline,
  semanticLabel: 'Timeline',
  size: AppIconSize.tiny,
  color: context.successColor,
),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  strategy.expectedOutcome,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScientificReference(
    BuildContext context,
    String reference,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _launchReference(context, reference),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            SemanticIcon(
  icon: AppIcons.science,
  semanticLabel: 'Science',
  size: AppIconSize.small,
  color: colorScheme.primary,
),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '📚 $reference',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SemanticIcon(
  icon: AppIcons.openInNew,
  semanticLabel: 'Open in new',
  size: AppIconSize.tiny,
  color: colorScheme.primary,
),
          ],
        ),
      ),
    );
  }

  Future<void> _launchReference(BuildContext context, String refText) async {
    Uri? uri;

    // Extract DOI/PubMed/URL
    if (refText.contains('doi.org/')) {
      final doiMatch = RegExp(r'https?://doi\.org/[^\s]+').firstMatch(refText);
      if (doiMatch != null) {
        try {
          uri = Uri.parse(doiMatch.group(0)!.trim());
        } catch (e) {
          // Invalid URI
        }
      }
    }
    if (uri == null && refText.contains('pubmed')) {
      final pubmedMatch = RegExp(r'https?://pubmed\.ncbi\.nlm\.nih\.gov/[^\s]+').firstMatch(refText);
      if (pubmedMatch != null) {
        try {
          uri = Uri.parse(pubmedMatch.group(0)!.trim());
        } catch (e) {
          // Invalid URI
        }
      }
    }
    if (uri == null && refText.contains('http')) {
      final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(refText);
      if (urlMatch != null) {
        try {
          uri = Uri.parse(urlMatch.group(0)!.trim());
        } catch (e) {
          // Invalid URI
        }
      }
    }

    if (uri != null) {
      try {
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            SnackBarService.showError(
              context,
              context.l10n.cannotOpenLink,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarService.showError(
            context,
            context.l10n.errorOpeningLink,
          );
        }
      }
    }
  }

  Widget _buildFeedbackWidget(
    BuildContext context,
    WidgetRef ref,
    AIInsight insight,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = context.l10n;
    final insightHash = insight.generateHash();
    final feedbackAsync = ref.watch(insightFeedbackProvider(insightHash));

    return feedbackAsync.when(
      data: (existingFeedback) {
        if (existingFeedback != null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  existingFeedback.isHelpful ? AppIcons.thumbUp : AppIcons.thumbDown,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.feedbackThankYou,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                l10n.feedbackQuestion,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeedbackButton(
                    context: context,
                    ref: ref,
                    insight: insight,
                    isHelpful: true,
                    icon: AppIcons.thumbUpOutlined,
                    label: l10n.feedbackHelpful,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 12),
                  _buildFeedbackButton(
                    context: context,
                    ref: ref,
                    insight: insight,
                    isHelpful: false,
                    icon: AppIcons.thumbDownOutlined,
                    label: l10n.feedbackNotHelpful,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFeedbackButton({
    required BuildContext context,
    required WidgetRef ref,
    required AIInsight insight,
    required bool isHelpful,
    required IconData icon,
    required String label,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return OutlinedButton.icon(
      onPressed: () async {
        HapticFeedback.lightImpact();

        try {
          await ref.read(insightFeedbackNotifierProvider.notifier).submitFeedback(
                insight: insight,
                isHelpful: isHelpful,
              );

          if (context.mounted) {
            final l10n = context.l10n;
            SnackBarService.showSuccess(
              context,
              l10n.feedbackSubmitted,
            );
          }
        } catch (e) {
          if (context.mounted) {
            SnackBarService.showError(
              context,
              'Failed to submit feedback',
            );
          }
        }
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    AIInsight insight,
    dynamic l10n,
    Color cardColor,
  ) {
    String buttonText;
    String reason;

    if (insight.type == InsightType.progressOverload) {
      reason = l10n.plateauDetected;
    } else if (insight.type == InsightType.formWarning) {
      reason = l10n.formRisk;
    } else {
      reason = '';
    }

    buttonText = l10n.replaceExerciseReason(insight.affectedExercise ?? '', reason);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isReplacingExercise ? null : () => _handleReplaceExercise(context, ref, insight),
        icon: _isReplacingExercise
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const SemanticIcon(
  icon: AppIcons.swapHoriz,
  semanticLabel: 'Swap horiz',
),
        label: Text(_isReplacingExercise ? l10n.processing : buttonText),
        style: FilledButton.styleFrom(
          backgroundColor: cardColor,
          foregroundColor: _getTextColor(context, cardColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _handleReplaceExercise(
    BuildContext context,
    WidgetRef ref,
    AIInsight insight,
  ) async {
    if (_isReplacingExercise) return;

    setState(() => _isReplacingExercise = true);

    try {
      final exerciseDb = await ref.read(allExercisesProvider.future);
      final exerciseMap = {for (var e in exerciseDb) e.nome: e};

      if (!mounted) return;

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => ExerciseReplacementDialog(
          affectedExercise: insight.affectedExercise!,
          affectedTemplates: insight.affectedTemplates!,
          exerciseDatabase: exerciseMap,
        ),
      );

      if (result != null && mounted) {
        await _performReplacement(
          context,
          ref,
          result['replacement'],
          result['templateIds'],
          result['weightOption'],
          insight.affectedExercise!,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReplacingExercise = false);
      }
    }
  }

  Future<void> _performReplacement(
    BuildContext context,
    WidgetRef ref,
    exercise_db.Exercise replacement,
    List<String> templateIds,
    String weightOption,
    String oldExerciseName,
  ) async {
    try {
      final templateRepository = TemplateRepository();

      await templateRepository.replaceExerciseInTemplates(
        templateIds: templateIds,
        oldExerciseName: oldExerciseName,
        newExerciseName: replacement.nome,
        weightOption: weightOption,
      );

      if (!context.mounted) return;

      final l10n = context.l10n;

      SnackBarService.showSuccess(
        context,
        l10n.exerciseReplacedSuccess(templateIds.length),
      );

      ref.invalidate(aiCoachInsightsProvider);
    } catch (e) {
      if (!context.mounted) return;

      final l10n = context.l10n;

      String errorMessage;
      if (e.toString().contains('User not authenticated')) {
        errorMessage = l10n.errorAuthenticationRequired;
      } else if (e.toString().contains('Cannot modify template')) {
        errorMessage = l10n.errorCannotModifyTemplate;
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = l10n.errorNetworkConnection;
      } else {
        errorMessage = l10n.errorUnexpected;
      }

      SnackBarService.showError(context, errorMessage);
    }
  }

  Color _getSeverityColor(InsightSeverity severity, ColorScheme colorScheme) {
    return switch (severity) {
      InsightSeverity.critical => context.errorColor,
      InsightSeverity.warning => context.warningColor,
      InsightSeverity.info => context.infoColor,
      InsightSeverity.success => context.successColor,
    };
  }

  Color _getTextColor(BuildContext context, Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    final colorScheme = Theme.of(context).colorScheme;
    return luminance > 0.5 ? colorScheme.onSurface.withValues(alpha: 0.87) : colorScheme.surface;
  }
}
