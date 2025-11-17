import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Near PR Encouragement Widget
///
/// Displays motivational banner when user is close to achieving a personal record.
/// Shown during workout when current performance is within 5-10% of PR.
///
/// Features:
/// - Progress bar showing proximity to PR
/// - Motivational message
/// - Theme-aware design
/// - Smooth animations
///
/// Usage:
/// ```dart
/// if (isNearPR) {
///   NearPREncouragementWidget(
///     exerciseName: 'Bench Press',
///     currentValue: 85.0,
///     prValue: 90.0,
///     proximityPercentage: 94.4,
///   )
/// }
/// ```
class NearPREncouragementWidget extends StatefulWidget {
  const NearPREncouragementWidget({
    required this.exerciseName,
    required this.currentValue,
    required this.prValue,
    required this.proximityPercentage,
    this.unit = 'kg',
    super.key,
  });

  final String exerciseName;
  final double currentValue;
  final double prValue;
  final double proximityPercentage; // 0-100%
  final String unit;

  @override
  State<NearPREncouragementWidget> createState() =>
      _NearPREncouragementWidgetState();
}

class _NearPREncouragementWidgetState
    extends State<NearPREncouragementWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulsing animation for fire icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getMotivationalMessage() {
    if (widget.proximityPercentage >= 95) {
      return context.l10n.near_pr_so_close;
    } else if (widget.proximityPercentage >= 90) {
      return context.l10n.near_pr_almost_there;
    } else {
      return context.l10n.near_pr_keep_pushing;
    }
  }

  Color _getIntensityColor() {
    if (widget.proximityPercentage >= 95) {
      return context.colors.error; // Red for very close
    } else if (widget.proximityPercentage >= 90) {
      return context.colors.secondary; // Orange for close
    } else {
      return context.colors.primary; // Blue for approaching
    }
  }

  @override
  Widget build(BuildContext context) {
    final intensityColor = _getIntensityColor();
    final remaining = widget.prValue - widget.currentValue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: intensityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: intensityColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with fire icon + message
          Row(
            children: [
              // Pulsing fire icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  AppIcons.streak,
                  color: intensityColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // Motivational message
              Expanded(
                child: Text(
                  _getMotivationalMessage(),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: intensityColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Exercise name + values
          Text(
            widget.exerciseName,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // Current vs PR values
          Row(
            children: [
              Text(
                '${widget.currentValue.toStringAsFixed(1)} ${widget.unit}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                ' / ',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '${widget.prValue.toStringAsFixed(1)} ${widget.unit}',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: intensityColor,
                ),
              ),
              const Spacer(),
              // Remaining to PR
              Text(
                '${remaining.toStringAsFixed(1)} ${widget.unit} ${context.l10n.near_pr_to_go}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          Stack(
            children: [
              // Background
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Progress fill
              FractionallySizedBox(
                widthFactor: widget.proximityPercentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: intensityColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: intensityColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Percentage indicator
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.proximityPercentage.toStringAsFixed(1)}% of PR',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: intensityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
