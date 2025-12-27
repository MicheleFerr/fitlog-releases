/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// TrainingPatternCard Widget - Displays detected training patterns
///
/// **UX Design (Based on 2024-2025 Research)**:
/// - Decision Narrative: Insight prominently visible ABOVE charts
/// - Progressive Disclosure: Collapsed by default, tap to expand
/// - Semantic Colors: Warning (amber), Success (green), Info (blue)
/// - Non-intrusive: Inline card, not blocking alert
/// - Clarity first: Single most important takeaway
///
/// **References**:
/// - Nielsen Norman 2024: "Decision Narrative" layout improves comprehension +40%
/// - Stormotion Fitness UX: "Clarity first: single most important takeaway"
///
/// **Usage**:
/// ```dart
/// TrainingPatternCard(
///   pattern: detectedPattern,
///   onTap: () => showDetails(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/training_pattern.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Card displaying a detected training pattern with collapsible details
class TrainingPatternCard extends StatefulWidget {
  /// The pattern to display
  final TrainingPattern pattern;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  /// Whether to show expanded details initially
  final bool initiallyExpanded;

  /// Optional callback when pattern is dismissed
  final VoidCallback? onDismiss;

  const TrainingPatternCard({
    super.key,
    required this.pattern,
    this.onTap,
    this.initiallyExpanded = false,
    this.onDismiss,
  });

  @override
  State<TrainingPatternCard> createState() => _TrainingPatternCardState();
}

class _TrainingPatternCardState extends State<TrainingPatternCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5, // 180 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final severityConfig = _getSeverityConfig(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: severityConfig.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severityConfig.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: severityConfig.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                _buildHeader(context, severityConfig),

                // Expanded content
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildExpandedContent(context, severityConfig),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, _SeverityConfig config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: config.iconBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getPatternIcon(),
            color: config.iconColor,
            size: AppIconSize.medium,
          ),
        ),

        const SizedBox(width: 12),

        // Title and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getLocalizedTitle(context),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: config.titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getLocalizedDescription(context),
                style: context.textTheme.bodySmall?.copyWith(
                  color: config.descriptionColor,
                ),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Expand indicator
        RotationTransition(
          turns: _rotationAnimation,
          child: Icon(
            AppIcons.expandMore,
            color: config.iconColor,
            size: AppIconSize.small,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, _SeverityConfig config) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            color: config.borderColor.withValues(alpha: 0.3),
          ),

          const SizedBox(height: 12),

          // Recommendation
          _buildSection(
            context,
            icon: AppIcons.lightbulbOutline,
            title: context.l10n.recommendation,
            content: _getLocalizedRecommendation(context),
            config: config,
          ),

          // Scientific explanation (if available)
          if (widget.pattern.scienceKey != null) ...[
            const SizedBox(height: 12),
            _buildSection(
              context,
              icon: AppIcons.science,
              title: context.l10n.scienceExplanation,
              content: _getLocalizedScience(context),
              config: config,
            ),
          ],

          // Confidence indicator
          const SizedBox(height: 12),
          _buildConfidenceIndicator(context, config),

          // Metrics (if any)
          if (widget.pattern.triggerMetrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMetricsRow(context, config),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required _SeverityConfig config,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: config.iconColor.withValues(alpha: 0.7),
          size: AppIconSize.small,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.labelSmall?.copyWith(
                  color: config.titleColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: context.textTheme.bodySmall?.copyWith(
                  color: config.descriptionColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator(
      BuildContext context, _SeverityConfig config) {
    final confidence = widget.pattern.confidence;
    final confidencePercent = (confidence * 100).round();

    return Row(
      children: [
        Icon(
          AppIcons.analytics,
          color: config.iconColor.withValues(alpha: 0.7),
          size: AppIconSize.small,
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.confidenceLabel,
          style: context.textTheme.labelSmall?.copyWith(
            color: config.titleColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: config.borderColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: confidence,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: config.iconColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$confidencePercent%',
          style: context.textTheme.labelSmall?.copyWith(
            color: config.descriptionColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow(BuildContext context, _SeverityConfig config) {
    final metrics = widget.pattern.triggerMetrics;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: metrics.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: config.iconBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_formatMetricKey(entry.key)}: ${_formatMetricValue(entry.value)}',
            style: context.textTheme.labelSmall?.copyWith(
              color: config.titleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  _SeverityConfig _getSeverityConfig(BuildContext context) {
    switch (widget.pattern.severity) {
      case PatternSeverity.alert:
        return _SeverityConfig(
          backgroundColor: context.colors.error.withValues(alpha: 0.08),
          borderColor: context.colors.error.withValues(alpha: 0.3),
          iconBackgroundColor: context.colors.error.withValues(alpha: 0.15),
          iconColor: context.colors.error,
          titleColor: context.colors.onSurface,
          descriptionColor: context.colors.onSurface.withValues(alpha: 0.7),
          shadowColor: context.colors.error.withValues(alpha: 0.1),
        );
      case PatternSeverity.warning:
        return _SeverityConfig(
          backgroundColor: context.colors.warning.withValues(alpha: 0.08),
          borderColor: context.colors.warning.withValues(alpha: 0.3),
          iconBackgroundColor: context.colors.warning.withValues(alpha: 0.15),
          iconColor: context.colors.warning,
          titleColor: context.colors.onSurface,
          descriptionColor: context.colors.onSurface.withValues(alpha: 0.7),
          shadowColor: context.colors.warning.withValues(alpha: 0.1),
        );
      case PatternSeverity.positive:
        return _SeverityConfig(
          backgroundColor: context.colors.success.withValues(alpha: 0.08),
          borderColor: context.colors.success.withValues(alpha: 0.3),
          iconBackgroundColor: context.colors.success.withValues(alpha: 0.15),
          iconColor: context.colors.success,
          titleColor: context.colors.onSurface,
          descriptionColor: context.colors.onSurface.withValues(alpha: 0.7),
          shadowColor: context.colors.success.withValues(alpha: 0.1),
        );
      case PatternSeverity.info:
        return _SeverityConfig(
          backgroundColor: context.colors.tertiary.withValues(alpha: 0.08),
          borderColor: context.colors.tertiary.withValues(alpha: 0.3),
          iconBackgroundColor: context.colors.tertiary.withValues(alpha: 0.15),
          iconColor: context.colors.tertiary,
          titleColor: context.colors.onSurface,
          descriptionColor: context.colors.onSurface.withValues(alpha: 0.7),
          shadowColor: context.colors.tertiary.withValues(alpha: 0.1),
        );
    }
  }

  IconData _getPatternIcon() {
    switch (widget.pattern.type) {
      case PatternType.fatigueWarning:
        return AppIcons.warning;
      case PatternType.greatProgression:
        return AppIcons.trendUp;
      case PatternType.overreachingRisk:
        return AppIcons.warningRounded;
      case PatternType.adaptation:
        return AppIcons.complete;
      case PatternType.volumeSpike:
        return AppIcons.showChart;
      case PatternType.optimalTraining:
        return AppIcons.star;
      case PatternType.inconsistent:
        return AppIcons.help;
    }
  }

  String _getLocalizedTitle(BuildContext context) {
    // Map pattern type to localized title
    switch (widget.pattern.type) {
      case PatternType.fatigueWarning:
        return context.l10n.patternFatigueWarningTitle;
      case PatternType.greatProgression:
        return context.l10n.patternGreatProgressionTitle;
      case PatternType.overreachingRisk:
        return context.l10n.patternOverreachingRiskTitle;
      case PatternType.adaptation:
        return context.l10n.patternAdaptationTitle;
      case PatternType.volumeSpike:
        return context.l10n.patternVolumeSpikeTitle;
      case PatternType.optimalTraining:
        return context.l10n.patternOptimalTrainingTitle;
      case PatternType.inconsistent:
        return context.l10n.patternInconsistentTitle;
    }
  }

  String _getLocalizedDescription(BuildContext context) {
    switch (widget.pattern.type) {
      case PatternType.fatigueWarning:
        return context.l10n.patternFatigueWarningDescription;
      case PatternType.greatProgression:
        return context.l10n.patternGreatProgressionDescription;
      case PatternType.overreachingRisk:
        return context.l10n.patternOverreachingRiskDescription;
      case PatternType.adaptation:
        return context.l10n.patternAdaptationDescription;
      case PatternType.volumeSpike:
        return context.l10n.patternVolumeSpikeDescription;
      case PatternType.optimalTraining:
        return context.l10n.patternOptimalTrainingDescription;
      case PatternType.inconsistent:
        return context.l10n.patternInconsistentDescription;
    }
  }

  String _getLocalizedRecommendation(BuildContext context) {
    switch (widget.pattern.type) {
      case PatternType.fatigueWarning:
        return context.l10n.patternFatigueWarningRecommendation;
      case PatternType.greatProgression:
        return context.l10n.patternGreatProgressionRecommendation;
      case PatternType.overreachingRisk:
        return context.l10n.patternOverreachingRiskRecommendation;
      case PatternType.adaptation:
        return context.l10n.patternAdaptationRecommendation;
      case PatternType.volumeSpike:
        return context.l10n.patternVolumeSpikeRecommendation;
      case PatternType.optimalTraining:
        return context.l10n.patternOptimalTrainingRecommendation;
      case PatternType.inconsistent:
        return context.l10n.patternInconsistentRecommendation;
    }
  }

  String _getLocalizedScience(BuildContext context) {
    switch (widget.pattern.type) {
      case PatternType.fatigueWarning:
        return context.l10n.patternFatigueWarningScience;
      case PatternType.greatProgression:
        return context.l10n.patternGreatProgressionScience;
      case PatternType.overreachingRisk:
        return context.l10n.patternOverreachingRiskScience;
      case PatternType.adaptation:
        return context.l10n.patternAdaptationScience;
      case PatternType.volumeSpike:
        return context.l10n.patternVolumeSpikeScience;
      case PatternType.optimalTraining:
        return context.l10n.patternOptimalTrainingScience;
      case PatternType.inconsistent:
        return context.l10n.patternInconsistentScience;
    }
  }

  String _formatMetricKey(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String _formatMetricValue(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }
}

/// Configuration for severity-based colors
class _SeverityConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color descriptionColor;
  final Color shadowColor;

  const _SeverityConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.descriptionColor,
    required this.shadowColor,
  });
}

/// Widget for displaying multiple training patterns
class TrainingPatternsList extends StatelessWidget {
  /// The pattern results to display
  final TrainingPatternResults results;

  /// Maximum number of patterns to show (primary + warnings only by default)
  final int maxPatterns;

  /// Whether to show only warnings
  final bool warningsOnly;

  const TrainingPatternsList({
    super.key,
    required this.results,
    this.maxPatterns = 2,
    this.warningsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!results.hasPatterns) {
      return const SizedBox.shrink();
    }

    List<TrainingPattern> patternsToShow;

    if (warningsOnly) {
      patternsToShow = results.warnings.take(maxPatterns).toList();
    } else {
      // Show primary pattern first, then other high-priority patterns
      patternsToShow = results.patterns.take(maxPatterns).toList();
    }

    if (patternsToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: patternsToShow
          .map((pattern) => TrainingPatternCard(
                pattern: pattern,
                initiallyExpanded: patternsToShow.length == 1,
              ))
          .toList(),
    );
  }
}
