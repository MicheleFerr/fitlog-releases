import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Icon with badge/counter overlay
///
/// Provides a consistent way to display badges/counters on icons across the app.
/// Common use cases:
/// - Notification count
/// - Unread messages
/// - Shopping cart items
/// - Pending actions
///
/// **Usage:**
/// ```dart
/// // Notification with count
/// BadgedIcon(
///   icon: AppIcons.notifications,
///   badge: '3',
///   badgeColor: context.colors.error,
/// )
///
/// // Simple dot indicator
/// BadgedIcon(
///   icon: AppIcons.mail,
///   showBadge: hasUnread,
/// )
/// ```
///
/// See also:
/// - [SemanticIcon] for accessible icons
/// - [AppIconSize] for sizing constants
class BadgedIcon extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// Badge text to display (number or custom text)
  ///
  /// If null, displays a simple dot indicator.
  /// For counts > 99, consider showing "99+" for better UX.
  final String? badge;

  /// Badge background color
  ///
  /// Defaults to error color (red) for notifications.
  final Color? badgeColor;

  /// Badge text color
  ///
  /// Defaults to white for contrast.
  final Color? badgeTextColor;

  /// Whether to show the badge
  ///
  /// Useful for conditional badge display without rebuilding widget.
  final bool showBadge;

  /// Icon size
  final double iconSize;

  /// Icon color
  final Color? iconColor;

  /// Badge size
  ///
  /// Automatically calculated if null:
  /// - Dot badge: 8dp
  /// - Single digit: 16dp
  /// - Double digit: 20dp
  final double? badgeSize;

  /// Badge position offset from top-right
  ///
  /// Use this to fine-tune badge position for specific icons.
  final Offset badgeOffset;

  /// Optional semantic label for the entire widget
  ///
  /// Should describe both icon and badge state.
  /// Example: "Notifications, 3 unread"
  final String? semanticLabel;

  /// Badge border width
  ///
  /// Set to 0 to remove border.
  final double badgeBorderWidth;

  /// Badge border color
  ///
  /// Defaults to surface color for separation from background.
  final Color? badgeBorderColor;

  const BadgedIcon({
    super.key,
    required this.icon,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    this.showBadge = true,
    this.iconSize = AppIconSize.medium,
    this.iconColor,
    this.badgeSize,
    this.badgeOffset = Offset.zero,
    this.semanticLabel,
    this.badgeBorderWidth = 1.5,
    this.badgeBorderColor,
  });

  /// Factory constructor for notification icons
  ///
  /// Pre-configured for common notification badge styling.
  factory BadgedIcon.notification({
    Key? key,
    required IconData icon,
    int? count,
    bool showBadge = true,
    double iconSize = AppIconSize.medium,
    Color? iconColor,
    String? semanticLabel,
  }) {
    // Format count display (max 99+)
    final String? badgeText = count != null && count > 0
        ? (count > 99 ? '99+' : count.toString())
        : null;

    return BadgedIcon(
      key: key,
      icon: icon,
      badge: badgeText,
      showBadge: showBadge && count != null && count > 0,
      iconSize: iconSize,
      iconColor: iconColor,
      semanticLabel: semanticLabel,
    );
  }

  /// Factory constructor for simple dot indicator
  ///
  /// Shows a small dot without text.
  factory BadgedIcon.dot({
    Key? key,
    required IconData icon,
    required bool showDot,
    Color? dotColor,
    double iconSize = AppIconSize.medium,
    Color? iconColor,
    String? semanticLabel,
  }) {
    return BadgedIcon(
      key: key,
      icon: icon,
      badge: null, // No text, just dot
      badgeColor: dotColor,
      showBadge: showDot,
      iconSize: iconSize,
      iconColor: iconColor,
      badgeSize: 8.0,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate badge size if not specified
    final double effectiveBadgeSize = badgeSize ??
        (badge == null
            ? 8.0 // Dot
            : badge!.length == 1
                ? 16.0 // Single digit
                : 20.0); // Multi digit

    // Determine badge position
    final bool isDot = badge == null;
    final double badgeTop = isDot ? 0 : -2;
    final double badgeRight = isDot ? 0 : -4;

    return Semantics(
      label: semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main icon
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? context.colors.onSurface,
            semanticLabel: null, // Handled by outer Semantics
          ),

          // Badge overlay
          if (showBadge)
            Positioned(
              top: badgeTop + badgeOffset.dy,
              right: badgeRight + badgeOffset.dx,
              child: Container(
                width: effectiveBadgeSize,
                height: effectiveBadgeSize,
                decoration: BoxDecoration(
                  color: badgeColor ?? context.colors.error,
                  shape: BoxShape.circle,
                  border: badgeBorderWidth > 0
                      ? Border.all(
                          color: badgeBorderColor ?? context.colors.surface,
                          width: badgeBorderWidth,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: badge != null
                    ? Text(
                        badge!,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: badgeTextColor ?? Colors.white,
                          fontSize: badge!.length > 2 ? 9 : 10,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : null, // Just a dot, no text
              ),
            ),
        ],
      ),
    );
  }
}

/// Extension to create BadgedIcon from IconData
///
/// Provides syntactic sugar for creating BadgedIcon instances.
///
/// Usage:
/// ```dart
/// AppIcons.notifications.withBadge(
///   count: 5,
///   context: context,
/// )
/// ```
extension IconDataBadge on IconData {
  /// Create a BadgedIcon from this IconData with count
  BadgedIcon withBadge({
    Key? key,
    required int count,
    Color? badgeColor,
    double iconSize = AppIconSize.medium,
    Color? iconColor,
    String? semanticLabel,
  }) {
    return BadgedIcon.notification(
      key: key,
      icon: this,
      count: count,
      iconSize: iconSize,
      iconColor: iconColor,
      semanticLabel: semanticLabel,
    );
  }

  /// Create a BadgedIcon with simple dot indicator
  BadgedIcon withDot({
    Key? key,
    required bool showDot,
    Color? dotColor,
    double iconSize = AppIconSize.medium,
    Color? iconColor,
    String? semanticLabel,
  }) {
    return BadgedIcon.dot(
      key: key,
      icon: this,
      showDot: showDot,
      dotColor: dotColor,
      iconSize: iconSize,
      iconColor: iconColor,
      semanticLabel: semanticLabel,
    );
  }
}
