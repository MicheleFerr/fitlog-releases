/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Quick Action Chips
/// Type: Widget
///
/// M3-compliant action chips for quick navigation
/// with subtle press animation and haptic feedback.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Configuration for a quick action chip
class QuickActionConfig {
  const QuickActionConfig({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Leading icon
  final IconData icon;

  /// Chip label
  final String label;

  /// Tap callback
  final VoidCallback onTap;
}

/// Single quick action chip with M3 styling
///
/// Features:
/// - 48px height with centered content
/// - Scale animation on press
/// - Haptic feedback
/// - Optional expanded mode for grid layout
class QuickActionChip extends StatefulWidget {
  const QuickActionChip({
    required this.config,
    this.expanded = false,
    super.key,
  });

  final QuickActionConfig config;

  /// When true, chip expands to fill available width
  final bool expanded;

  @override
  State<QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<QuickActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.config.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.config.icon,
                size: 20,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                widget.config.label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2x2 grid of quick action chips
///
/// Displays 4 action chips in a 2x2 grid layout
/// with equal size for all chips.
class QuickActionChipsRow extends StatelessWidget {
  const QuickActionChipsRow({
    required this.actions,
    super.key,
  });

  /// List of action configurations (expects 4 items)
  final List<QuickActionConfig> actions;

  @override
  Widget build(BuildContext context) {
    // Ensure we have exactly 4 actions for 2x2 grid
    final gridActions = actions.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // First row
          Row(
            children: [
              if (gridActions.isNotEmpty)
                Expanded(
                  child: QuickActionChip(
                    config: gridActions[0],
                    expanded: true,
                  ),
                ),
              const SizedBox(width: 12),
              if (gridActions.length > 1)
                Expanded(
                  child: QuickActionChip(
                    config: gridActions[1],
                    expanded: true,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row
          Row(
            children: [
              if (gridActions.length > 2)
                Expanded(
                  child: QuickActionChip(
                    config: gridActions[2],
                    expanded: true,
                  ),
                ),
              const SizedBox(width: 12),
              if (gridActions.length > 3)
                Expanded(
                  child: QuickActionChip(
                    config: gridActions[3],
                    expanded: true,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Default quick actions for Profile Hub
///
/// Creates standard action chips for:
/// - Stats (Analytics)
/// - History (Workout History)
/// - Measures (Body Measurements)
/// - Calendar (Streak Calendar)
class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({
    required this.onStatsTap,
    required this.onHistoryTap,
    required this.onMeasuresTap,
    required this.onCalendarTap,
    super.key,
  });

  final VoidCallback onStatsTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onMeasuresTap;
  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return QuickActionChipsRow(
      actions: [
        QuickActionConfig(
          icon: AppIcons.analytics,
          label: context.l10n.statsAction,
          onTap: onStatsTap,
        ),
        QuickActionConfig(
          icon: AppIcons.history,
          label: context.l10n.historyAction,
          onTap: onHistoryTap,
        ),
        QuickActionConfig(
          icon: AppIcons.bodyMeasurements,
          label: context.l10n.measurementsAction,
          onTap: onMeasuresTap,
        ),
        QuickActionConfig(
          icon: AppIcons.calendar,
          label: context.l10n.calendarAction,
          onTap: onCalendarTap,
        ),
      ],
    );
  }
}
