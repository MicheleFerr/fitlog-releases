import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
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
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart' as ExerciseDB;
import 'package:gymbro_flutter_new/shared/data/services/interstitial_ad_service.dart';

/// AI Coach card with modern design and animations
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

    // Animate on every build for consistent UX
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

  /// Calculate consistency percentage based on weekly frequency
  /// Target: 4 workouts/week = 100% consistency
  int _calculateConsistency(double weeklyFrequency) {
    // Cap at 100% for 4+ workouts/week
    final consistency = ((weeklyFrequency / 4.0) * 100).clamp(0, 100);
    return consistency.toInt();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ottimizzato: usa select per evitare rebuild inutili
    final quickStatsAsync = ref.watch(quickStatsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final frequencyAsync = ref.watch(weeklyFrequencyProvider);
    final primaryAdviceAsync = ref.watch(primaryAIAdviceProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.5,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.9),
            colorScheme.secondaryContainer.withValues(alpha: 0.7),
            colorScheme.tertiaryContainer.withValues(alpha: 0.5),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _showAIInsightsModal(context, ref),
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(l10n, theme, colorScheme),
                            const SizedBox(height: 20),
                            _buildAdviceSection(l10n, theme, colorScheme, primaryAdviceAsync),
                            const SizedBox(height: 20),
                            _buildInsightsSection(l10n, theme, colorScheme, quickStatsAsync, streakAsync, frequencyAsync),
                            const SizedBox(height: 12),
                            _buildTapHint(l10n, theme, colorScheme),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.8),
                colorScheme.secondary.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.psychology,
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.aiCoach,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                l10n.aiCoachPersonalized,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            l10n.aiBadge,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceSection(AppLocalizations l10n, ThemeData theme, ColorScheme colorScheme,
      AsyncValue<String> primaryAdviceAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: colorScheme.tertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: primaryAdviceAsync.when(
              data: (advice) => Text(
                advice,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
              loading: () => Text(
                l10n.loading,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.4,
                ),
              ),
              error: (_, __) => Text(
                l10n.aiCoachFirstWorkout,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(AppLocalizations l10n, ThemeData theme, ColorScheme colorScheme,
      AsyncValue<QuickStats?> quickStatsAsync, AsyncValue<int> streakAsync, AsyncValue<double> frequencyAsync) {
    return Row(
      children: [
        Expanded(
          child: _StaticAIInsight(
            icon: Icons.trending_up,
            value: quickStatsAsync.asData?.value?.formattedVolumeIncrease ?? '--',
            label: l10n.volume,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StaticAIInsight(
            icon: Icons.track_changes,
            value: frequencyAsync.asData != null
                ? '${_calculateConsistency(frequencyAsync.asData!.value)}%'
                : '--',
            label: l10n.consistency,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StaticAIInsight(
            icon: Icons.local_fire_department,
            value: '${streakAsync.asData?.value ?? 0}',
            label: l10n.streak,
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }


  Widget _buildTapHint(AppLocalizations l10n, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app,
          size: 16,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Text(
          l10n.aiCoachTapHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _showAIInsightsModal(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();

    // 📱 Mostra Interstitial Ad prima di aprire il modal
    final adService = InterstitialAdService();
    await adService.showAdIfReady();

    // Controlla se il widget è ancora montato dopo l'ad
    if (!context.mounted) return;

    await ModalService.showBottomSheet(
      context,
      child: const AIInsightsModal(),
    );
  }
}

class _StaticAIInsight extends StatelessWidget {

  const _StaticAIInsight({
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AIInsightsModal extends ConsumerStatefulWidget {
  const AIInsightsModal({super.key});

  @override
  ConsumerState<AIInsightsModal> createState() => _AIInsightsModalState();
}

class _AIInsightsModalState extends ConsumerState<AIInsightsModal> {
  // CRITICAL FIX: Track if replacement operation is in progress to prevent concurrent operations
  bool _isReplacingExercise = false;

  // Track disclaimer visibility (dismissible)
  bool _showDisclaimer = true;

  /// Get color based on severity level
  Color _getSeverityColor(InsightSeverity severity, ColorScheme colorScheme) {
    switch (severity) {
      case InsightSeverity.critical:
        return colorScheme.error; // 🔴 Red
      case InsightSeverity.warning:
        return Colors.orange; // 🟠 Orange
      case InsightSeverity.info:
        return colorScheme.primary; // 🔵 Blue
      case InsightSeverity.success:
        return Colors.green; // 🟢 Green
    }
  }

  /// Get icon based on severity level
  IconData _getSeverityIcon(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.critical:
        return Icons.error;
      case InsightSeverity.warning:
        return Icons.warning_amber;
      case InsightSeverity.info:
        return Icons.info;
      case InsightSeverity.success:
        return Icons.check_circle;
    }
  }

  /// Get badge label based on severity level
  String _getSeverityBadgeLabel(InsightSeverity severity, AppLocalizations l10n) {
    switch (severity) {
      case InsightSeverity.critical:
        return l10n.badgeCritical;
      case InsightSeverity.warning:
        return l10n.badgeWarning;
      case InsightSeverity.info:
        return l10n.badgeInfo;
      case InsightSeverity.success:
        return l10n.badgeSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    final WidgetRef ref = this.ref;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final insightsAsync = ref.watch(aiCoachInsightsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.aiCoachDetailed,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Button to view feedback history
                IconButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await ModalService.showBottomSheet(
                      context,
                      child: const FeedbackHistoryModal(),
                    );
                  },
                  icon: Icon(
                    Icons.history,
                    color: colorScheme.primary,
                  ),
                  tooltip: l10n.viewMyFeedback,
                ),
              ],
            ),
          ),
          Expanded(
            child: insightsAsync.when(
              data: (insights) => insights.isEmpty
                  ? _buildEmptyState(l10n, theme, colorScheme)
                  : _buildInsightsList(context, ref, insights, l10n, theme, colorScheme),
              loading: () => const LoadingIndicator(),
              error: (_, __) => _buildEmptyState(l10n, theme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aiCoachModalPlaceholder,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsList(BuildContext context, WidgetRef ref, List<dynamic> insights, AppLocalizations l10n, ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Dismissible disclaimer at the top
        if (_showDisclaimer)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: colorScheme.errorContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _showDisclaimer = false),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.aiCoachDisclaimer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Then show insights (all as expandable)
        ...insights.map((insight) => _buildCompactInsightCard(context, ref, insight, theme, colorScheme)),
      ],
    );
  }

  /// NEW: Unified compact insight card with progressive disclosure
  /// Shows ONLY icon + title + badges collapsed, everything else expandable
  Widget _buildCompactInsightCard(BuildContext context, WidgetRef ref, dynamic insight, ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);

    // Get severity-based color and icon
    final severity = insight.effectiveSeverity;
    final cardColor = _getSeverityColor(severity, colorScheme);
    final severityIcon = _getSeverityIcon(severity);

    // Type-specific icon (fallback to severity icon if not specified)
    IconData icon;
    switch (insight.type.toString()) {
      case 'InsightType.muscleGroupBalance':
        icon = Icons.balance;
        break;
      case 'InsightType.progressOverload':
        icon = Icons.trending_up;
        break;
      case 'InsightType.recoveryPattern':
        icon = Icons.bedtime;
        break;
      case 'InsightType.volumeOptimization':
        icon = Icons.tune;
        break;
      case 'InsightType.frequencyRecommendation':
        icon = Icons.schedule;
        break;
      case 'InsightType.plateauBreaker':
        icon = Icons.trending_flat;
        break;
      case 'InsightType.formWarning':
        icon = Icons.warning;
        break;
      case 'InsightType.motivational':
        icon = Icons.celebration;
        break;
      default:
        icon = severityIcon; // Fallback to severity icon
    }

    // Progressive disclosure: ALL content inside expansion
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: cardColor, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Severity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSeverityBadgeLabel(severity, l10n),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              // Data quality badge (if low confidence)
              if (insight.hasDataQualityIssues) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: l10n.dataQualityWarning,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_amber,
                      size: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
          children: [
            // Expanded content (progressive disclosure)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description (always visible when expanded)
                Text(
                  insight.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),

                // Recommendation box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.recommend, size: 16, color: cardColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight.recommendation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔽 EXPANDABLE SUBSECTIONS START 🔽

                // Detailed Analysis subsection (if exists)
                if (insight.detailedAnalysis != null) ...[
                  const SizedBox(height: 16),
                  _ExpandableSubsection(
                    title: l10n.whyThisMatters,
                    icon: Icons.analytics,
                    iconColor: cardColor,
                    theme: theme,
                    colorScheme: colorScheme,
                    child: Text(
                      insight.detailedAnalysis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                // Data Points subsection (if exists)
                if (insight.dataPoints != null && insight.dataPoints.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ExpandableSubsection(
                    title: l10n.yourData,
                    icon: Icons.bar_chart,
                    iconColor: cardColor,
                    theme: theme,
                    colorScheme: colorScheme,
                    backgroundColor: cardColor.withValues(alpha: 0.05),
                    borderColor: cardColor.withValues(alpha: 0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: insight.dataPoints.map<Widget>((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.fiber_manual_record, size: 8, color: cardColor),
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
                      )).toList(),
                    ),
                  ),
                ],

                // Strategies subsection (if exists)
                if (insight.strategies != null && insight.strategies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ExpandableSubsection(
                    title: '🎯 ${l10n.evidenceBasedSolutions}',
                    icon: Icons.psychology,
                    iconColor: cardColor,
                    theme: theme,
                    colorScheme: colorScheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: insight.strategies.map<Widget>((strategy) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildStrategyCard(
                          context,
                          strategy,
                          theme,
                          colorScheme,
                          cardColor,
                        ),
                      )).toList(),
                    ),
                  ),
                ],

                // Explainability subsection (always show - helps users understand AI logic)
                const SizedBox(height: 12),
                _ExpandableSubsection(
                  title: '🔍 Come l\'AI calcola',  // TODO: Localize
                  icon: Icons.science,
                  iconColor: colorScheme.secondary,
                  theme: theme,
                  colorScheme: colorScheme,
                  backgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.1),
                  borderColor: colorScheme.secondary.withValues(alpha: 0.2),
                  child: _buildExplainabilitySection(context, insight, theme, colorScheme),
                ),

                // 🔼 EXPANDABLE SUBSECTIONS END 🔼

                // Scientific Reference (always visible if exists)
                if (insight.scientificReference != null) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final refText = insight.scientificReference!;
                      Uri? uri;

                      // Extract DOI/PubMed/generic URL
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

                      // Launch URL
                      if (uri != null) {
                        try {
                          final canLaunch = await canLaunchUrl(uri);
                          if (canLaunch) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              SnackBarService.showError(
                                context,
                                'Cannot open link: ${uri.toString()}',
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            SnackBarService.showError(
                              context,
                              'Error opening link: $e',
                            );
                          }
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.science, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '📚 ${insight.scientificReference}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Icon(Icons.open_in_new, size: 14, color: colorScheme.primary.withValues(alpha: 0.7)),
                        ],
                      ),
                    ),
                  ),
                ],

                // Feedback widget (always visible)
                const SizedBox(height: 16),
                _buildFeedbackWidget(context, ref, insight, theme, colorScheme),

                // Action Button (always visible if exists)
                if (insight.hasAction) ...[
                  const SizedBox(height: 16),
                  _buildActionButton(context, ref, insight, theme, colorScheme, cardColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// DEPRECATED: Old method kept for reference, not called anymore
  Widget _buildInsightCard(BuildContext context, WidgetRef ref, dynamic insight, ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);

    // Get severity-based color and icon
    final severity = insight.effectiveSeverity;
    final cardColor = _getSeverityColor(severity, colorScheme);
    final severityIcon = _getSeverityIcon(severity);

    // Type-specific icon (fallback to severity icon if not specified)
    IconData icon;
    switch (insight.type.toString()) {
      case 'InsightType.muscleGroupBalance':
        icon = Icons.balance;
        break;
      case 'InsightType.progressOverload':
        icon = Icons.trending_up;
        break;
      case 'InsightType.recoveryPattern':
        icon = Icons.bedtime;
        break;
      case 'InsightType.volumeOptimization':
        icon = Icons.tune;
        break;
      case 'InsightType.frequencyRecommendation':
        icon = Icons.schedule;
        break;
      case 'InsightType.plateauBreaker':
        icon = Icons.trending_flat;
        break;
      case 'InsightType.formWarning':
        icon = Icons.warning;
        break;
      case 'InsightType.motivational':
        icon = Icons.celebration;
        break;
      default:
        icon = severityIcon; // Fallback to severity icon
    }

    // Check if insight has detailed analysis
    final hasDetails = insight.detailedAnalysis != null ||
                      (insight.strategies != null && insight.strategies.isNotEmpty);

    if (!hasDetails) {
      // Simple card without expansion
      return _buildSimpleInsightCard(insight, theme, colorScheme, icon, cardColor, l10n, severity);
    }

    // Expandable card with scientific details
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: cardColor, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Severity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSeverityBadgeLabel(severity, l10n),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              // Data quality badge (if low confidence)
              if (insight.hasDataQualityIssues) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: l10n.dataQualityWarning,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_amber,
                      size: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              insight.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          children: [
            _buildDetailedAnalysis(context, ref, insight, theme, colorScheme, cardColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInsightCard(
    dynamic insight,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    Color cardColor,
    AppLocalizations l10n,
    InsightSeverity severity,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              Expanded(
                child: Text(
                  insight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Severity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSeverityBadgeLabel(severity, l10n),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              // Data quality badge (if low confidence)
              if (insight.hasDataQualityIssues) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: l10n.dataQualityWarning,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_amber,
                      size: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.recommend, size: 16, color: cardColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.recommendation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Feedback widget
          _buildFeedbackWidget(context, ref, insight, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis(BuildContext context, WidgetRef ref, dynamic insight, ThemeData theme, ColorScheme colorScheme, Color cardColor) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detailed Analysis Section
        if (insight.detailedAnalysis != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, size: 18, color: cardColor),
                    const SizedBox(width: 8),
                    Text(
                      l10n.whyThisMatters,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  insight.detailedAnalysis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Data Points Section
        if (insight.dataPoints != null && insight.dataPoints.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cardColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, size: 18, color: cardColor),
                    const SizedBox(width: 8),
                    Text(
                      l10n.yourData,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...insight.dataPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.fiber_manual_record, size: 8, color: cardColor),
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
                )).toList(),
              ],
            ),
          ),
        ],

        // Scientific Strategies Section
        if (insight.strategies != null && insight.strategies.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '🎯 ${l10n.evidenceBasedSolutions}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...insight.strategies.map((strategy) => _buildStrategyCard(
            context,
            strategy,
            theme,
            colorScheme,
            cardColor,
          )).toList(),
        ],

        // Scientific Reference (clickable if contains DOI/URL)
        if (insight.scientificReference != null) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              // Extract DOI or URL from the reference
              final refText = insight.scientificReference!;
              Uri? uri;

              // Improved regex patterns for better URL extraction
              // Match URLs until whitespace or end of line (more reliable)
              if (refText.contains('doi.org/')) {
                // Match DOI URL: https://doi.org/10.1234/something
                final doiMatch = RegExp(r'https?://doi\.org/[^\s]+').firstMatch(refText);
                if (doiMatch != null) {
                  try {
                    uri = Uri.parse(doiMatch.group(0)!.trim());
                  } catch (e) {
                    // Invalid URI, skip
                  }
                }
              }
              // Check if it contains a PubMed link
              if (uri == null && refText.contains('pubmed')) {
                final pubmedMatch = RegExp(r'https?://pubmed\.ncbi\.nlm\.nih\.gov/[^\s]+').firstMatch(refText);
                if (pubmedMatch != null) {
                  try {
                    uri = Uri.parse(pubmedMatch.group(0)!.trim());
                  } catch (e) {
                    // Invalid URI, skip
                  }
                }
              }
              // Check for any http/https URL as fallback
              if (uri == null && refText.contains('http')) {
                final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(refText);
                if (urlMatch != null) {
                  try {
                    uri = Uri.parse(urlMatch.group(0)!.trim());
                  } catch (e) {
                    // Invalid URI, skip
                  }
                }
              }

              // Try to launch the URL
              if (uri != null) {
                try {
                  final canLaunch = await canLaunchUrl(uri);
                  if (canLaunch) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    // Show error if can't launch
                    if (context.mounted) {
                      SnackBarService.showError(
                        context,
                        'Cannot open link: ${uri.toString()}',
                      );
                    }
                  }
                } catch (e) {
                  // Show error on exception
                  if (context.mounted) {
                    SnackBarService.showError(
                      context,
                      'Error opening link: $e',
                    );
                  }
                }
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.science, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '📚 ${insight.scientificReference}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 14, color: colorScheme.primary.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
        ],

        // Feedback widget
        const SizedBox(height: 16),
        _buildFeedbackWidget(context, ref, insight, theme, colorScheme),

        // Action Button
        if (insight.hasAction) ...[
          const SizedBox(height: 16),
          _buildActionButton(context, ref, insight, theme, colorScheme, cardColor),
        ],
      ],
    );
  }

  Widget _buildStrategyCard(BuildContext context, dynamic strategy, ThemeData theme, ColorScheme colorScheme, Color cardColor) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strategy Title
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strategy.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            strategy.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // How to Implement
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_arrow, size: 16, color: cardColor),
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

          // Expected Outcome
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.timeline, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  strategy.expectedOutcome,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Scientific Basis
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '📖 ${strategy.scientificBasis}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, AIInsight insight, ThemeData theme, ColorScheme colorScheme, Color cardColor) {
    final l10n = AppLocalizations.of(context);

    // Determine button text based on insight type
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
        // CRITICAL FIX: Disable button during operation to prevent concurrent executions
        onPressed: _isReplacingExercise ? null : () async {
          // CRITICAL FIX: Set flag to prevent concurrent operations
          if (_isReplacingExercise) return;

          setState(() {
            _isReplacingExercise = true;
          });

          try {
            // Get exercise database
            final exerciseDb = await ref.read(allExercisesProvider.future);
            final exerciseMap = {for (var e in exerciseDb) e.nome: e};

            if (!mounted) return;

            // Show replacement dialog
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => ExerciseReplacementDialog(
                affectedExercise: insight.affectedExercise!,
                affectedTemplates: insight.affectedTemplates!,
                exerciseDatabase: exerciseMap,
              ),
            );

            if (result != null && mounted) {
              // Handle replacement
              await _handleExerciseReplacement(
                context,
                ref,
                result['replacement'],
                result['templateIds'],
                result['weightOption'],
                insight.affectedExercise!,
              );
            }
          } finally {
            // CRITICAL FIX: Always reset flag even if error occurs
            if (mounted) {
              setState(() {
                _isReplacingExercise = false;
              });
            }
          }
        },
        icon: _isReplacingExercise
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.swap_horiz),
        label: Text(_isReplacingExercise ? l10n.processing : buttonText),
        style: FilledButton.styleFrom(
          backgroundColor: cardColor,
          foregroundColor: _getTextColor(cardColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _handleExerciseReplacement(
    BuildContext context,
    WidgetRef ref,
    ExerciseDB.Exercise replacement,
    List<String> templateIds,
    String weightOption,
    String oldExerciseName,
  ) async {
    try {
      // Get template repository
      final templateRepository = TemplateRepository();

      // Replace exercise in templates
      await templateRepository.replaceExerciseInTemplates(
        templateIds: templateIds,
        oldExerciseName: oldExerciseName,
        newExerciseName: replacement.nome,
        weightOption: weightOption,
      );

      // CRITICAL FIX: Check mounted before using context after async operation
      if (!context.mounted) return;

      // CRITICAL FIX: Capture context-dependent values AFTER mounted check
      final l10n = AppLocalizations.of(context);

      SnackBarService.showSuccess(
        context,
        l10n.exerciseReplacedSuccess(templateIds.length),
      );

      // Refresh insights to update UI
      ref.invalidate(aiCoachInsightsProvider);
    } catch (e) {
      // CRITICAL FIX: Check mounted before using context in error handler
      if (!context.mounted) return;

      // CRITICAL FIX: Capture context-dependent values AFTER mounted check
      final l10n = AppLocalizations.of(context);

      // CRITICAL FIX: User-friendly error message based on error type
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

      SnackBarService.showError(
        context,
        errorMessage,
      );
    }
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if we need dark or light text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Build feedback widget (thumbs up/down buttons)
  Widget _buildFeedbackWidget(
    BuildContext context,
    WidgetRef ref,
    AIInsight insight,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context);
    final insightHash = insight.generateHash();
    final feedbackAsync = ref.watch(insightFeedbackProvider(insightHash));

    return feedbackAsync.when(
      data: (existingFeedback) {
        if (existingFeedback != null) {
          // User already gave feedback - show their choice
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  existingFeedback.isHelpful ? Icons.thumb_up : Icons.thumb_down,
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

        // No feedback yet - show buttons
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                l10n.feedbackQuestion,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              // Thumbs up button
              _buildFeedbackButton(
                context: context,
                ref: ref,
                insight: insight,
                isHelpful: true,
                icon: Icons.thumb_up_outlined,
                label: l10n.feedbackHelpful,
                theme: theme,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              // Thumbs down button
              _buildFeedbackButton(
                context: context,
                ref: ref,
                insight: insight,
                isHelpful: false,
                icon: Icons.thumb_down_outlined,
                label: l10n.feedbackNotHelpful,
                theme: theme,
                colorScheme: colorScheme,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(), // Hide during loading
      error: (_, __) => const SizedBox.shrink(), // Hide on error
    );
  }

  /// Build individual feedback button
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
          // Submit feedback
          await ref.read(insightFeedbackNotifierProvider.notifier).submitFeedback(
                insight: insight,
                isHelpful: isHelpful,
              );

          // Show confirmation snackbar
          if (context.mounted) {
            final l10n = AppLocalizations.of(context);
            SnackBarService.showSuccess(
              context,
              l10n.feedbackSubmitted,
            );
          }
        } catch (e) {
          // Show error snackbar
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

  /// Build explainability section showing how AI calculated this insight
  Widget _buildExplainabilitySection(
    BuildContext context,
    AIInsight insight,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Explanation text
        Text(
          'L\'AI Coach analizza i tuoi dati di allenamento usando algoritmi scientifici per identificare pattern e opportunità di miglioramento.', // TODO: Localize
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Threshold explanations
        _buildThresholdExplanation(
          context,
          'MEV',
          'Minimum Effective Volume: 10 sets/settimana',
          'Volume minimo per stimolare crescita muscolare',
          Colors.orange,
          theme,
          colorScheme,
        ),
        const SizedBox(height: 8),
        _buildThresholdExplanation(
          context,
          'MAV',
          'Maximum Adaptive Volume: 15-20 sets/settimana',
          'Range ottimale per massimizzare crescita',
          Colors.green,
          theme,
          colorScheme,
        ),
        const SizedBox(height: 8),
        _buildThresholdExplanation(
          context,
          'MRV',
          'Maximum Recoverable Volume: 25 sets/settimana',
          'Volume massimo recuperabile prima di overtraining',
          Colors.red,
          theme,
          colorScheme,
        ),
        const SizedBox(height: 16),

        // Data quality indicator
        if (insight.dataQualityConfidence != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall,
                      children: [
                        const TextSpan(
                          text: 'Affidabilità dati: ', // TODO: Localize
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${(insight.dataQualityConfidence! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: insight.dataQualityConfidence! >= 0.7
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build single threshold explanation
  Widget _buildThresholdExplanation(
    BuildContext context,
    String label,
    String value,
    String description,
    Color color,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Expandable subsection widget for AI insights
/// Used to create collapsible sections within the main insight card
class _ExpandableSubsection extends StatelessWidget {
  const _ExpandableSubsection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.theme,
    required this.colorScheme,
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Icon(icon, size: 18, color: iconColor),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          children: [
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
