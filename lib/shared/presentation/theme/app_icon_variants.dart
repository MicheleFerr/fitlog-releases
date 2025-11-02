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
  final IconData filled;
  final IconData? outlined;
  final IconData? rounded;

  const AppIconVariant({
    required this.filled,
    this.outlined,
    this.rounded,
  });

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
    filled: Icons.info, // ignore: design-system-infrastructure
    outlined: AppIcons.info, // Already outlined
  );

  /// Error icons
  static const error = AppIconVariant(
    filled: Icons.error, // ignore: design-system-infrastructure
    outlined: AppIcons.error, // Already outlined
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ACTION ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Add circle
  static const addCircle = AppIconVariant(
    filled: Icons.add_circle, // ignore: design-system-infrastructure
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
    outlined: Icons.thumb_up_outlined, // ignore: design-system-infrastructure
  );

  /// Thumb down/dislike
  static const thumbDown = AppIconVariant(
    filled: AppIcons.thumbDown,
    outlined: Icons.thumb_down_outlined, // ignore: design-system-infrastructure
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MEDIA ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Play circle
  static const playCircle = AppIconVariant(
    filled: Icons.play_circle_filled, // ignore: design-system-infrastructure
    outlined: Icons.play_circle_outline, // ignore: design-system-infrastructure
  );

  /// Pause circle
  static const pauseCircle = AppIconVariant(
    filled: Icons.pause_circle_filled, // ignore: design-system-infrastructure
    outlined: Icons.pause_circle_outline, // ignore: design-system-infrastructure
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // NAVIGATION ICONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Home
  static const home = AppIconVariant(
    filled: AppIcons.home,
    outlined: Icons.home_outlined, // ignore: design-system-infrastructure
  );

  /// Settings
  static const settings = AppIconVariant(
    filled: AppIcons.settings,
    outlined: Icons.settings_outlined, // ignore: design-system-infrastructure
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
      Icons.add_circle.codePoint: AppIcons.addCircleOutline, // ignore: inline-icons
      Icons.info.codePoint: AppIcons.info, // ignore: inline-icons
      Icons.error.codePoint: AppIcons.error, // ignore: inline-icons
      Icons.home.codePoint: Icons.home_outlined, // ignore: inline-icons
      Icons.settings.codePoint: Icons.settings_outlined, // ignore: inline-icons
      Icons.play_circle_filled.codePoint: Icons.play_circle_outline, // ignore: inline-icons
      Icons.pause_circle_filled.codePoint: Icons.pause_circle_outline, // ignore: inline-icons
      AppIcons.thumbUp.codePoint: Icons.thumb_up_outlined, // ignore: inline-icons
      AppIcons.thumbDown.codePoint: Icons.thumb_down_outlined, // ignore: inline-icons
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
      AppIcons.addCircleOutline.codePoint: Icons.add_circle, // ignore: inline-icons
      Icons.home_outlined.codePoint: AppIcons.home, // ignore: inline-icons
      Icons.settings_outlined.codePoint: AppIcons.settings, // ignore: inline-icons
      Icons.play_circle_outline.codePoint: Icons.play_circle_filled, // ignore: inline-icons
      Icons.pause_circle_outline.codePoint: Icons.pause_circle_filled, // ignore: inline-icons
      Icons.thumb_up_outlined.codePoint: AppIcons.thumbUp, // ignore: inline-icons
      Icons.thumb_down_outlined.codePoint: AppIcons.thumbDown, // ignore: inline-icons
    };

    return filledMap[codePoint];
  }

  /// Toggle between filled and outlined
  IconData get toggled {
    return outlined ?? filled ?? this;
  }
}

/// Helper to create toggle-able icon widgets
class ToggleIcon extends StatelessWidget {
  final bool isActive;
  final AppIconVariant variant;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;

  const ToggleIcon({
    super.key,
    required this.isActive,
    required this.variant,
    this.size,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isActive ? variant.filled : variant.outlinedOrFilled,
      size: size,
      color: isActive ? activeColor : inactiveColor,
    );
  }
}
