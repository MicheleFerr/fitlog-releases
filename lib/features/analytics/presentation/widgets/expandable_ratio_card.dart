/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Expandable Ratio Card - Interactive card showing ratio with exercise breakdown
///
/// **Design Research**:
/// - AnimatedSize for smooth dynamic height transitions
/// - AnimatedRotation for chevron indicator
/// - DraggableScrollableSheet for fullscreen expansion
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/ratio_breakdown.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/ratio_breakdown_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Expandable Ratio Card Widget
///
/// Displays a ratio metric with the ability to expand inline
/// or open fullscreen to show exercise breakdown.
///
/// **Features**:
/// - Tap to expand inline (80% height)
/// - Drag to fullscreen (100%)
/// - Chevron rotation animation
/// - Volume bars for each exercise
class ExpandableRatioCard extends StatefulWidget {
  const ExpandableRatioCard({
    super.key,
    required this.icon,
    required this.title,
    required this.ratio,
    required this.hasWarning,
    required this.description,
    required this.firstCategory,
    required this.secondCategory,
    required this.firstCategoryName,
    required this.secondCategoryName,
  });

  final IconData icon;
  final String title;
  final double ratio;
  final bool hasWarning;
  final String description;
  final CategoryBreakdown firstCategory;
  final CategoryBreakdown secondCategory;
  final String firstCategoryName;
  final String secondCategoryName;

  @override
  State<ExpandableRatioCard> createState() => _ExpandableRatioCardState();
}

class _ExpandableRatioCardState extends State<ExpandableRatioCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _chevronController;
  late Animation<double> _chevronAnimation;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _chevronAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _chevronController.forward();
      } else {
        _chevronController.reverse();
      }
    });
  }

  void _openFullScreenSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
      builder: (context) => RatioBreakdownSheet(
        title: widget.title,
        firstCategory: widget.firstCategory,
        secondCategory: widget.secondCategory,
        firstCategoryName: widget.firstCategoryName,
        secondCategoryName: widget.secondCategoryName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    final ratioColor = widget.hasWarning
        ? colorScheme.error
        : colorScheme.primary;
    final hasData =
        widget.firstCategory.hasData || widget.secondCategory.hasData;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ratioColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Always visible, tappable
          InkWell(
            onTap: hasData ? _toggleExpanded : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ratioColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: ratioColor,
                          size: AppIconSize.medium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.description,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${widget.ratio.toStringAsFixed(2)}:1',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ratioColor,
                                ),
                              ),
                              if (widget.hasWarning) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  AppIcons.warning,
                                  size: AppIconSize.small,
                                  color: colorScheme.error,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            l10n.optimalRatio('1.0:1'),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (hasData) ...[
                        const SizedBox(width: 8),
                        RotationTransition(
                          turns: _chevronAnimation,
                          child: Icon(
                            AppIcons.expandMore,
                            color: colorScheme.onSurfaceVariant,
                            size: AppIconSize.medium,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Visual ratio bar
                  _buildRatioBar(context, ratioColor),
                  // Hint text
                  if (hasData && !_isExpanded) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        l10n.tapForDetails,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? _buildExpandedContent(context, colorScheme)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioBar(BuildContext context, Color color) {
    final colorScheme = context.colors;

    // Calculate position (1.0 = center, <1.0 = left, >1.0 = right)
    final normalizedRatio = widget.ratio.clamp(0.5, 2.0);
    final position = (normalizedRatio - 0.5) / 1.5; // 0.0 to 1.0

    return Column(
      children: [
        Stack(
          children: [
            // Background bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Center marker (optimal 1.0)
            Positioned(
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 2,
                  height: 8,
                  color: colorScheme.primary,
                ),
              ),
            ),
            // Current position marker
            Positioned(
              left: 0,
              right: 0,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: position,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0.5:1',
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '1.0:1',
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '2.0:1',
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, ColorScheme colorScheme) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 8),

          // First category preview
          _buildCategoryPreview(
            context,
            widget.firstCategoryName,
            widget.firstCategory,
            colorScheme.primary,
          ),
          const SizedBox(height: 16),

          // Second category preview
          _buildCategoryPreview(
            context,
            widget.secondCategoryName,
            widget.secondCategory,
            colorScheme.secondary,
          ),
          const SizedBox(height: 12),

          // Expand to fullscreen button
          Center(
            child: TextButton.icon(
              onPressed: _openFullScreenSheet,
              icon: const Icon(AppIcons.fullscreen, size: AppIconSize.small),
              label: Text(l10n.dragToExpand),
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPreview(
    BuildContext context,
    String categoryName,
    CategoryBreakdown category,
    Color accentColor,
  ) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final topExercises = category.topExercises(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_formatVolume(category.totalVolume)} kg',
              style: context.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (topExercises.isEmpty)
          Text(
            l10n.noExercisesInCategory,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...topExercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildExerciseBar(
                context,
                exercise.exerciseName,
                exercise.percentage,
                accentColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseBar(
    BuildContext context,
    String name,
    double percentage,
    Color color,
  ) {
    final colorScheme = context.colors;
    final normalizedPercentage = percentage.clamp(0, 100) / 100;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            name,
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: normalizedPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    }
    return volume.toStringAsFixed(0);
  }
}
