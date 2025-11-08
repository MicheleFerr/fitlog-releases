import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Icon variant system for outlined/filled alternatives
///
/// Provides compile-time safe access to icon variants (filled, outlined, rounded).
/// Useful for toggling icon styles without hardcoding multiple IconData references.
///
/// **Usage:**
/// ```dart
/// // Get variant dynamically
/// final icon = AppIconVariants.checkCircle.filled; // or .outlined
///
/// // Use in toggle states
/// Icon(
///   isActive
///     ? AppIconVariants.star.filled
///     : AppIconVariants.star.outlined
/// )
///
/// // Check if variant exists
/// if (AppIconVariants.star.hasOutlined) {
///   // Use outlined variant
/// }
/// ```
class AppIconVariant {

  const AppIconVariant({
    required this.filled,
    this.outlined,
    this.rounded,
  });
  final IconData filled;
  final IconData? outlined;
  final IconData? rounded;

  /// Whether this icon has an outlined variant
  bool get hasOutlined => outlined != null;

  /// Whether this icon has a rounded variant
  bool get hasRounded => rounded != null;

  /// Get outlined variant, fallback to filled
  IconData get outlinedOrFilled => outlined ?? filled;

  /// Get rounded variant, fallback to filled
  IconData get roundedOrFilled => rounded ?? filled;
}

/// Centralized icon variant definitions
///
/// Contains all icons with multiple variants (filled/outlined/rounded).
/// Only includes icons where variants actually exist in Material Icons.
class AppIconVariants {
  AppIconVariants._();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATUS ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Check circle (complete/done)
  static const checkCircle = AppIconVariant(
    filled: AppIcons.complete,
    outlined: AppIcons.completeOutline,
  );

  /// Star (favorites/rating)
  static const star = AppIconVariant(
    filled: AppIcons.star,
    outlined: AppIcons.starOutline,
  );

  /// Info icons
  static const info = AppIconVariant(
    filled: AppIcons.info, // ignore: design-system-infrastructure
    outlined: AppIcons.info, // Already outlined
  );

  /// Error icons
  static const error = AppIconVariant(
    filled: AppIcons.error, // ignore: design-system-infrastructure
    outlined: AppIcons.error, // Already outlined
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ACTION ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Add circle
  static const addCircle = AppIconVariant(
    filled: AppIcons.addCircle, // ignore: design-system-infrastructure
    outlined: AppIcons.addCircleOutline,
  );

  /// Delete/trash
  static const delete = AppIconVariant(
    filled: AppIcons.delete,
    outlined: AppIcons.deleteOutline,
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SOCIAL ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// People/group
  static const people = AppIconVariant(
    filled: AppIcons.people,
    outlined: AppIcons.peopleOutline,
  );

  /// Thumb up/like
  static const thumbUp = AppIconVariant(
    filled: AppIcons.thumbUp,
    outlined: AppIcons.thumbUpOutlined, // ignore: design-system-infrastructure
  );

  /// Thumb down/dislike
  static const thumbDown = AppIconVariant(
    filled: AppIcons.thumbDown,
    outlined: AppIcons.thumbDownOutlined, // ignore: design-system-infrastructure
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MEDIA ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Play circle
  static const playCircle = AppIconVariant(
    filled: AppIcons.playCircleFilled, // ignore: design-system-infrastructure
    outlined: AppIcons.playCircleOutline, // ignore: design-system-infrastructure
  );

  /// Pause circle
  static const pauseCircle = AppIconVariant(
    filled: AppIcons.pauseCircleFilled, // ignore: design-system-infrastructure
    outlined: AppIcons.pauseCircleOutline, // ignore: design-system-infrastructure
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // NAVIGATION ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Home
  static const home = AppIconVariant(
    filled: AppIcons.home,
    outlined: AppIcons.homeOutlined, // ignore: design-system-infrastructure
  );

  /// Settings
  static const settings = AppIconVariant(
    filled: AppIcons.settings,
    outlined: AppIcons.settingsOutlined, // ignore: design-system-infrastructure
  );

  /// Get all variants as list
  static List<AppIconVariant> get all => [
        checkCircle,
        star,
        info,
        error,
        addCircle,
        delete,
        people,
        thumbUp,
        thumbDown,
        playCircle,
        pauseCircle,
        home,
        settings,
      ];
}

/// Extension to easily get variants from IconData
extension IconDataVariants on IconData {
  /// Try to get outlined variant (returns null if not found)
  IconData? get outlined {
    // Map common filled icons to their outlined variants
    // ignore: design-system-infrastructure
    final Map<int, IconData> outlinedMap = {
      AppIcons.complete.codePoint: AppIcons.completeOutline,
      AppIcons.star.codePoint: AppIcons.starOutline,
      AppIcons.people.codePoint: AppIcons.peopleOutline,
      AppIcons.delete.codePoint: AppIcons.deleteOutline,
      AppIcons.addCircle.codePoint: AppIcons.addCircleOutline, // ignore: inline-icons
      AppIcons.info.codePoint: AppIcons.info, // ignore: inline-icons
      AppIcons.error.codePoint: AppIcons.error, // ignore: inline-icons
      AppIcons.home.codePoint: AppIcons.homeOutlined, // ignore: inline-icons
      AppIcons.settings.codePoint: AppIcons.settingsOutlined, // ignore: inline-icons
      AppIcons.playCircleFilled.codePoint: AppIcons.playCircleOutline, // ignore: inline-icons
      AppIcons.pauseCircleFilled.codePoint: AppIcons.pauseCircleOutline, // ignore: inline-icons
      AppIcons.thumbUp.codePoint: AppIcons.thumbUpOutlined, // ignore: inline-icons
      AppIcons.thumbDown.codePoint: AppIcons.thumbDownOutlined, // ignore: inline-icons
    };

    return outlinedMap[codePoint];
  }

  /// Try to get filled variant (returns null if not found)
  IconData? get filled {
    // Map common outlined icons to their filled variants
    // ignore: design-system-infrastructure
    final Map<int, IconData> filledMap = {
      AppIcons.completeOutline.codePoint: AppIcons.complete,
      AppIcons.starOutline.codePoint: AppIcons.star,
      AppIcons.peopleOutline.codePoint: AppIcons.people,
      AppIcons.deleteOutline.codePoint: AppIcons.delete,
      AppIcons.addCircleOutline.codePoint: AppIcons.addCircle, // ignore: inline-icons
      AppIcons.homeOutlined.codePoint: AppIcons.home, // ignore: inline-icons
      AppIcons.settingsOutlined.codePoint: AppIcons.settings, // ignore: inline-icons
      AppIcons.playCircleOutline.codePoint: AppIcons.playCircleFilled, // ignore: inline-icons
      AppIcons.pauseCircleOutline.codePoint: AppIcons.pauseCircleFilled, // ignore: inline-icons
      AppIcons.thumbUpOutlined.codePoint: AppIcons.thumbUp, // ignore: inline-icons
      AppIcons.thumbDownOutlined.codePoint: AppIcons.thumbDown, // ignore: inline-icons
    };

    return filledMap[codePoint];
  }

  /// Toggle between filled and outlined
  IconData get toggled {
    return outlined ?? filled ?? this;
  }
}

/// Helper to create toggle-able icon widgets with smooth animation
///
/// Uses AnimatedSwitcher for fluid transitions between active/inactive states.
/// Includes scale animation (300ms) for polished UX.
class ToggleIcon extends StatelessWidget {

  const ToggleIcon({
    super.key,
    required this.isActive,
    required this.variant,
    this.size,
    this.activeColor,
    this.inactiveColor,
    this.duration = const Duration(milliseconds: 300),
    this.onTap,
  });
  final bool isActive;
  final AppIconVariant variant;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      isActive ? variant.filled : variant.outlinedOrFilled,
      size: size,
      color: isActive ? activeColor : inactiveColor,
      key: ValueKey(isActive), // Key ensures AnimatedSwitcher detects change
    );

    final animatedIcon = AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        // Scale transition for smooth appearance
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: icon,
    );

    // Wrap in GestureDetector if onTap provided
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: animatedIcon,
      );
    }

    return animatedIcon;
  }
}
