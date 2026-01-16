/// Status Badge Widget
///
/// Reusable badge widgets for displaying status, labels, and tags
/// across the application with consistent styling.
///
/// ## Widgets
/// - `StatusBadge` - Primary status indicator badge
/// - `LabelBadge` - Simple text label badge
/// - `CountBadge` - Numeric count badge (notification style)
/// - `IconBadge` - Badge with icon
/// - `ProBadge` - Premium/Pro indicator
///
/// ## Usage
/// ```dart
/// StatusBadge(
///   status: BadgeStatus.success,
///   label: 'Active',
/// )
///
/// CountBadge(
///   count: 5,
///   maxCount: 99,
/// )
///
/// ProBadge()
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Status variants for badges
enum BadgeStatus {
  /// Green - success, active, completed
  success,

  /// Yellow/Amber - warning, pending
  warning,

  /// Red - error, failed, inactive
  error,

  /// Blue - info, neutral active
  info,

  /// Gray - inactive, disabled
  neutral,

  /// Purple/Tertiary - premium, special
  premium,
}

/// Size variants for badges
enum BadgeSize {
  /// Small: 20px height, 10px font
  small,

  /// Medium: 24px height, 12px font (default)
  medium,

  /// Large: 32px height, 14px font
  large,
}

/// Primary status indicator badge
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.icon,
    this.size = BadgeSize.medium,
    this.outlined = false,
  });

  /// Status determines color scheme
  final BadgeStatus status;

  /// Badge text
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Size variant
  final BadgeSize size;

  /// Whether to use outlined style
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    // Get status-specific colors
    final (backgroundColor, foregroundColor) = _getColors(colorScheme);

    // Size-specific dimensions
    final (height, fontSize, iconSize, horizontalPadding) = switch (size) {
      BadgeSize.small => (20.0, 10.0, 12.0, 8.0),
      BadgeSize.medium => (24.0, 12.0, 14.0, 10.0),
      BadgeSize.large => (32.0, 14.0, 18.0, 12.0),
    };

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: outlined
            ? Border.all(color: foregroundColor)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: foregroundColor,
            ),
            SizedBox(width: fontSize * 0.4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  (Color background, Color foreground) _getColors(ColorScheme colorScheme) {
    return switch (status) {
      BadgeStatus.success => (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
        ),
      BadgeStatus.warning => (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
        ),
      BadgeStatus.error => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
        ),
      BadgeStatus.info => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
      BadgeStatus.neutral => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
      BadgeStatus.premium => (
          colorScheme.tertiaryContainer,
          colorScheme.tertiary,
        ),
    };
  }
}

/// Simple text label badge
class LabelBadge extends StatelessWidget {
  const LabelBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.size = BadgeSize.medium,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    final (height, fontSize, horizontalPadding) = switch (size) {
      BadgeSize.small => (20.0, 10.0, 8.0),
      BadgeSize.medium => (24.0, 12.0, 10.0),
      BadgeSize.large => (32.0, 14.0, 12.0),
    };

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: foregroundColor ?? colorScheme.onSurfaceVariant,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// Numeric count badge (notification style)
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.backgroundColor,
    this.foregroundColor,
    this.size = BadgeSize.small,
    this.showZero = false,
  });

  final int count;
  final int maxCount;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BadgeSize size;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) {
      return const SizedBox.shrink();
    }

    final colorScheme = context.colors;

    final (minSize, fontSize) = switch (size) {
      BadgeSize.small => (16.0, 10.0),
      BadgeSize.medium => (20.0, 11.0),
      BadgeSize.large => (24.0, 12.0),
    };

    final displayCount = count > maxCount ? '$maxCount+' : '$count';

    return Container(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.error,
        borderRadius: BorderRadius.circular(minSize / 2),
      ),
      child: Center(
        child: Text(
          displayCount,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: foregroundColor ?? colorScheme.onError,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

/// Badge with icon only
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.status = BadgeStatus.neutral,
    this.size = BadgeSize.medium,
    this.tooltip,
  });

  final IconData icon;
  final BadgeStatus status;
  final BadgeSize size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    final (background, foreground) = _getColors(colorScheme);

    final (dimension, iconSize) = switch (size) {
      BadgeSize.small => (20.0, 12.0),
      BadgeSize.medium => (28.0, 16.0),
      BadgeSize.large => (36.0, 20.0),
    };

    final badge = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(dimension / 2),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: foreground,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: badge,
      );
    }

    return badge;
  }

  (Color background, Color foreground) _getColors(ColorScheme colorScheme) {
    return switch (status) {
      BadgeStatus.success => (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
        ),
      BadgeStatus.warning => (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
        ),
      BadgeStatus.error => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
        ),
      BadgeStatus.info => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
      BadgeStatus.neutral => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
      BadgeStatus.premium => (
          colorScheme.tertiaryContainer,
          colorScheme.tertiary,
        ),
    };
  }
}

/// Premium/Pro indicator badge
class ProBadge extends StatelessWidget {
  const ProBadge({
    super.key,
    this.size = BadgeSize.small,
    this.showIcon = true,
    this.gradient = true,
  });

  final BadgeSize size;
  final bool showIcon;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    final (height, fontSize, iconSize, horizontalPadding) = switch (size) {
      BadgeSize.small => (18.0, 9.0, 10.0, 6.0),
      BadgeSize.medium => (22.0, 10.0, 12.0, 8.0),
      BadgeSize.large => (28.0, 12.0, 14.0, 10.0),
    };

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        gradient: gradient
            ? LinearGradient(
                colors: [
                  colorScheme.tertiary,
                  colorScheme.tertiary.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: gradient ? null : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: gradient
            ? [
                BoxShadow(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              AppIcons.premium,
              size: iconSize,
              color: gradient ? colorScheme.onTertiary : colorScheme.tertiary,
            ),
            SizedBox(width: fontSize * 0.3),
          ],
          Text(
            'PRO',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: gradient ? colorScheme.onTertiary : colorScheme.tertiary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dot indicator badge (minimal)
class DotBadge extends StatelessWidget {
  const DotBadge({
    super.key,
    this.status = BadgeStatus.neutral,
    this.size = 8,
    this.pulsing = false,
  });

  final BadgeStatus status;
  final double size;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    final color = switch (status) {
      BadgeStatus.success => colorScheme.primary,
      BadgeStatus.warning => colorScheme.tertiary,
      BadgeStatus.error => colorScheme.error,
      BadgeStatus.info => colorScheme.secondary,
      BadgeStatus.neutral => colorScheme.outline,
      BadgeStatus.premium => colorScheme.tertiary,
    };

    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (pulsing) {
      return _PulsingDot(color: color, size: size);
    }

    return dot;
  }
}

/// Pulsing dot animation
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: widget.size * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
