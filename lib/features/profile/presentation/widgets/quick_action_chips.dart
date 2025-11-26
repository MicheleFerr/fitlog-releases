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
/// - 32px visual height, 48px touch target
/// - Scale animation on press
/// - Haptic feedback
class QuickActionChip extends StatefulWidget {
  const QuickActionChip({
    required this.config,
    super.key,
  });

  final QuickActionConfig config;

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
          // 48px touch target with 32px visual height
          constraints: const BoxConstraints(
            minHeight: 48,
          ),
          child: Center(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.config.icon,
                    size: 18,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.config.label,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of quick action chips with wrap layout
///
/// Displays 4 action chips in a single row with automatic
/// wrapping on smaller screens.
class QuickActionChipsRow extends StatelessWidget {
  const QuickActionChipsRow({
    required this.actions,
    super.key,
  });

  /// List of action configurations
  final List<QuickActionConfig> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.map((action) {
          return QuickActionChip(config: action);
        }).toList(),
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
