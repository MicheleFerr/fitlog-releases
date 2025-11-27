/// Progress Arrow Widget for displaying workout progress indicators
///
/// Shows green/red arrows to indicate improvement or regression
/// compared to the last workout for the same exercise/set.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/set_progress_data.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Widget that displays progress arrows based on workout performance comparison
class ProgressArrowWidget extends StatelessWidget {
  const ProgressArrowWidget({
    super.key,
    required this.progressData,
    this.showDetails = false,
    this.compactMode = true,
    this.onTap,
  });

  /// The progress data to display
  final SetProgressData progressData;

  /// Whether to show detailed delta values
  final bool showDetails;

  /// Compact mode for inline display in set rows
  final bool compactMode;

  /// Optional callback when arrow is tapped (to show details)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = progressData.overallStatus;

    if (status == ProgressStatus.unchanged) {
      return const SizedBox.shrink();
    }

    if (compactMode) {
      return _buildCompactArrow(context, status);
    }

    return _buildDetailedArrow(context, status);
  }

  Widget _buildCompactArrow(BuildContext context, ProgressStatus status) {
    final (icon, color) = _getIconAndColor(context, status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(
          icon,
          size: AppIconSize.small,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailedArrow(BuildContext context, ProgressStatus status) {
    final (icon, color) = _getIconAndColor(context, status);
    final weightDelta = progressData.weightDelta;
    final repsDelta = progressData.repsDelta;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.small,
              color: color,
            ),
            if (showDetails) ...[
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (weightDelta != 0)
                    Text(
                      '${weightDelta > 0 ? '+' : ''}${weightDelta.toStringAsFixed(1)} kg',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (repsDelta != 0)
                    Text(
                      '${repsDelta > 0 ? '+' : ''}$repsDelta reps',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getIconAndColor(BuildContext context, ProgressStatus status) {
    switch (status) {
      case ProgressStatus.majorImprovement:
        return (AppIcons.trendingUp, context.colors.success);
      case ProgressStatus.improvement:
        return (AppIcons.arrowUpward, context.colors.success);
      case ProgressStatus.mixed:
        return (AppIcons.swapVert, context.colors.warning);
      case ProgressStatus.unchanged:
        return (AppIcons.remove, context.colors.onSurfaceVariant);
      case ProgressStatus.regression:
        return (AppIcons.arrowDownward, context.colors.error);
      case ProgressStatus.majorRegression:
        return (AppIcons.trendingDown, context.colors.error);
    }
  }
}

/// Animated version of ProgressArrowWidget with entrance animation
class AnimatedProgressArrow extends StatefulWidget {
  const AnimatedProgressArrow({
    super.key,
    required this.progressData,
    this.showDetails = false,
    this.compactMode = true,
    this.onTap,
    this.animationDelay = Duration.zero,
  });

  final SetProgressData progressData;
  final bool showDetails;
  final bool compactMode;
  final VoidCallback? onTap;
  final Duration animationDelay;

  @override
  State<AnimatedProgressArrow> createState() => _AnimatedProgressArrowState();
}

class _AnimatedProgressArrowState extends State<AnimatedProgressArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Delay animation start if specified
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: ProgressArrowWidget(
              progressData: widget.progressData,
              showDetails: widget.showDetails,
              compactMode: widget.compactMode,
              onTap: widget.onTap,
            ),
          ),
        );
      },
    );
  }
}

/// Progress indicator specifically for set rows (inline display)
class SetRowProgressIndicator extends StatelessWidget {
  const SetRowProgressIndicator({
    super.key,
    required this.progressData,
    this.onTap,
  });

  final SetProgressData? progressData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (progressData == null ||
        progressData!.overallStatus == ProgressStatus.unchanged) {
      return const SizedBox(width: 20);
    }

    return Tooltip(
      message: _getTooltipMessage(context),
      child: AnimatedProgressArrow(
        progressData: progressData!,
        compactMode: true,
        onTap: onTap ?? () => _showProgressDetails(context),
        animationDelay: const Duration(milliseconds: 100),
      ),
    );
  }

  String _getTooltipMessage(BuildContext context) {
    if (progressData == null) return '';

    final weightDelta = progressData!.weightDelta;
    final repsDelta = progressData!.repsDelta;
    final parts = <String>[];

    if (weightDelta != 0) {
      parts.add('${weightDelta > 0 ? '+' : ''}${weightDelta.toStringAsFixed(1)} kg');
    }
    if (repsDelta != 0) {
      parts.add('${repsDelta > 0 ? '+' : ''}$repsDelta reps');
    }

    return parts.isEmpty ? context.l10n.unchanged : parts.join(', ');
  }

  void _showProgressDetails(BuildContext context) {
    if (progressData == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProgressDetailsSheet(progressData: progressData!),
    );
  }
}

/// Bottom sheet showing detailed progress information
class ProgressDetailsSheet extends StatelessWidget {
  const ProgressDetailsSheet({
    super.key,
    required this.progressData,
  });

  final SetProgressData progressData;

  @override
  Widget build(BuildContext context) {
    final status = progressData.overallStatus;
    final color = _getStatusColor(context, status);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: color,
                  size: AppIconSize.large,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.progressComparison,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusLabel(context, status),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Current vs Last comparison
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  context,
                  context.l10n.lastWorkout,
                  '${progressData.lastWeight.toStringAsFixed(1)} kg',
                  '${progressData.lastReps} reps',
                  context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                AppIcons.arrowForwardIos,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonCard(
                  context,
                  context.l10n.current,
                  '${progressData.currentWeight.toStringAsFixed(1)} kg',
                  '${progressData.currentReps} reps',
                  context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Delta summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDeltaItem(
                  context,
                  context.l10n.weight,
                  progressData.weightDelta,
                  'kg',
                  color,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: color.withValues(alpha: 0.3),
                ),
                _buildDeltaItem(
                  context,
                  context.l10n.reps,
                  progressData.repsDelta.toDouble(),
                  '',
                  color,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    String title,
    String weight,
    String reps,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weight,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Text(
            reps,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeltaItem(
    BuildContext context,
    String label,
    double delta,
    String unit,
    Color color,
  ) {
    final isPositive = delta > 0;
    final displayDelta = delta.abs();
    final formattedDelta = unit == 'kg'
        ? displayDelta.toStringAsFixed(1)
        : displayDelta.toStringAsFixed(0);

    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (delta != 0)
              Icon(
                isPositive ? AppIcons.arrowUpward : AppIcons.arrowDownward,
                size: AppIconSize.tiny,
                color: color,
              ),
            Text(
              delta == 0 ? '0' : '${isPositive ? '+' : '-'}$formattedDelta$unit',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context, ProgressStatus status) {
    switch (status) {
      case ProgressStatus.majorImprovement:
      case ProgressStatus.improvement:
        return context.colors.success;
      case ProgressStatus.mixed:
        return context.colors.warning;
      case ProgressStatus.unchanged:
        return context.colors.onSurfaceVariant;
      case ProgressStatus.regression:
      case ProgressStatus.majorRegression:
        return context.colors.error;
    }
  }

  IconData _getStatusIcon(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.majorImprovement:
        return AppIcons.trendingUp;
      case ProgressStatus.improvement:
        return AppIcons.arrowUpward;
      case ProgressStatus.mixed:
        return AppIcons.swapVert;
      case ProgressStatus.unchanged:
        return AppIcons.remove;
      case ProgressStatus.regression:
        return AppIcons.arrowDownward;
      case ProgressStatus.majorRegression:
        return AppIcons.trendingDown;
    }
  }

  String _getStatusLabel(BuildContext context, ProgressStatus status) {
    switch (status) {
      case ProgressStatus.majorImprovement:
        return context.l10n.majorImprovement;
      case ProgressStatus.improvement:
        return context.l10n.improvement;
      case ProgressStatus.mixed:
        return context.l10n.mixedResults;
      case ProgressStatus.unchanged:
        return context.l10n.unchanged;
      case ProgressStatus.regression:
        return context.l10n.regression;
      case ProgressStatus.majorRegression:
        return context.l10n.majorRegression;
    }
  }
}
