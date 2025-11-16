/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Expandable Insight Card - progressive disclosure for AI insights
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/insight_severity_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Expandable card for displaying AI insight with progressive disclosure
///
/// Features:
/// - Collapsed: Title + severity indicator
/// - Expanded: Full description, recommendation, scientific strategies
/// - Smooth animation
/// - Haptic feedback
/// - Accessibility support
///
/// Usage:
/// ```dart
/// ExpandableInsightCard(
///   insight: aiInsight,
///   initiallyExpanded: false,
/// )
/// ```
class ExpandableInsightCard extends StatefulWidget {
  const ExpandableInsightCard({
    required this.insight,
    this.initiallyExpanded = false,
    this.onTap,
    super.key,
  });

  /// Insight to display
  final AIInsight insight;

  /// Whether card starts expanded
  final bool initiallyExpanded;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  @override
  State<ExpandableInsightCard> createState() => _ExpandableInsightCardState();
}

class _ExpandableInsightCardState extends State<ExpandableInsightCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    // Animation controller for expand/collapse
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    // Haptic feedback
    HapticFeedback.selectionClick();

    // Optional callback
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Severity + Expand Icon
              Row(
                children: [
                  // Severity indicator
                  SeverityBadge(severity: widget.insight.severity),
                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Text(
                      widget.insight.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Expand/Collapse icon
                  RotationTransition(
                    turns: Tween<double>(begin: 0.0, end: 0.5)
                        .animate(_expandAnimation),
                    child: SemanticIcon(
                      icon: AppIcons.expandMore,
                      semanticLabel: _isExpanded
                          ? context.l10n.collapse
                          : context.l10n.expand,
                      size: AppIconSize.medium,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Collapsed preview: Short description
              if (!_isExpanded) ...[
                const SizedBox(height: 8),
                Text(
                  _truncate(widget.insight.description, 100),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Expanded content
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Full description
                    _buildSection(
                      title: context.l10n.description,
                      content: widget.insight.description,
                    ),

                    const SizedBox(height: 16),

                    // Recommendation
                    _buildSection(
                      title: context.l10n.recommendation,
                      content: widget.insight.recommendation,
                      icon: AppIcons.lightbulb,
                    ),

                    // Scientific strategies (if available)
                    if (widget.insight.scientificStrategies != null &&
                        widget.insight.scientificStrategies!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildStrategiesSection(
                        widget.insight.scientificStrategies!,
                      ),
                    ],

                    // Data points (if available)
                    if (widget.insight.dataPoints != null &&
                        widget.insight.dataPoints!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDataPointsSection(
                        widget.insight.dataPoints!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a section with title and content
  Widget _buildSection({
    required String title,
    required String content,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              SemanticIcon(
                icon: icon,
                semanticLabel: title,
                size: AppIconSize.small,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Build scientific strategies section (bulleted list)
  Widget _buildStrategiesSection(List<String> strategies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.science,
              semanticLabel: context.l10n.scientificStrategies,
              size: AppIconSize.small,
              color: context.colors.tertiary,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.scientificStrategies,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...strategies.map((strategy) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      strategy,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// Build data points section (key-value pairs)
  Widget _buildDataPointsSection(Map<String, dynamic> dataPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.analytics,
              semanticLabel: context.l10n.dataPoints,
              size: AppIconSize.small,
              color: context.colors.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.dataPoints,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: dataPoints.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatKey(entry.key),
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value.toString(),
                        style: context.textTheme.bodySmall,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Truncate text to max length
  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Format camelCase key to Title Case
  String _formatKey(String key) {
    // Insert space before capital letters
    return key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    ).replaceFirst(key[0], key[0].toUpperCase());
  }
}
