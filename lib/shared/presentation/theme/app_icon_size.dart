/// Icon sizing system following Material Design 3 conventions
///
/// Provides semantic size constants for consistent icon sizing across the app.
/// All sizes are in logical pixels (dp).
///
/// Usage:
/// ```dart
/// Icon(
///   AppIcons.workout,
///   size: AppIconSize.buttonPrimary,
/// )
/// ```
class AppIconSize {
  AppIconSize._(); // Private constructor to prevent instantiation

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📏 SEMANTIC SIZES (Material Design 3 Guidelines)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// 🔹 Tiny - 16dp
  /// Use for: Badges, indicators, inline text icons
  static const double tiny = 16.0;

  /// 🔸 Small - 20dp
  /// Use for: Compact UI, chips, dense lists, small buttons
  static const double small = 20.0;

  /// 🔶 Medium - 24dp (Material Design standard)
  /// Use for: Standard buttons, list items, default icons
  static const double medium = 24.0;

  /// 🔷 Large - 28dp
  /// Use for: Highlighted actions, card icons, important UI elements
  static const double large = 28.0;

  /// 🟦 XLarge - 32dp
  /// Use for: Feature icons, section headers, prominent actions
  static const double xlarge = 32.0;

  /// 🟪 XXLarge - 48dp
  /// Use for: Hero sections, empty states, splash screens
  static const double xxlarge = 48.0;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎯 CONTEXT-SPECIFIC SIZES (Self-Documenting)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// TabBar navigation icons
  static const double tabBar = small;

  /// Bottom navigation bar icons
  static const double bottomNavBar = medium;

  /// AppBar leading/action icons
  static const double appBar = medium;

  /// Primary action button icons (FAB, prominent buttons)
  static const double buttonPrimary = medium;

  /// Secondary/tertiary button icons
  static const double buttonSecondary = small;

  /// Card header/leading icons
  static const double card = large;

  /// List tile leading icons
  static const double listTile = medium;

  /// Chip icons (tags, filters)
  static const double chip = small;

  /// Badge/notification indicator icons
  static const double badge = tiny;

  /// Dialog title icons
  static const double dialog = large;

  /// Empty state illustrations
  static const double emptyState = xxlarge;

  /// Loading indicators
  static const double loading = medium;

  /// Avatar icons (if using icon instead of image)
  static const double avatar = xlarge;

  /// Form input prefix/suffix icons
  static const double input = small;

  /// Snackbar action icons
  static const double snackbar = small;

  /// Menu item icons
  static const double menuItem = small;

  /// Workout-specific sizes
  static const double exerciseCard = large;
  static const double workoutTimer = xxlarge;
  static const double restTimer = xlarge;
  static const double setCounter = medium;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📐 UTILITY METHODS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get responsive icon size based on screen width
  ///
  /// Scales up icons on larger screens (tablets, desktop)
  /// while maintaining visual hierarchy.
  static double responsive(double baseSize, double screenWidth) {
    if (screenWidth >= 1200) {
      return baseSize * 1.25; // Desktop: 25% larger
    } else if (screenWidth >= 600) {
      return baseSize * 1.15; // Tablet: 15% larger
    }
    return baseSize; // Mobile: base size
  }

  /// Get icon size for touch target (min 48dp for accessibility)
  ///
  /// Returns the icon size, but ensures the touch target is at least 48dp.
  /// Use this for interactive icons (buttons, toggles).
  static double forTouchTarget(double iconSize) {
    const minTouchTarget = 48.0;
    return iconSize < minTouchTarget ? minTouchTarget : iconSize;
  }

  /// Get all available sizes as a map (for debug/showcase purposes)
  static Map<String, double> get allSizes => {
        'tiny': tiny,
        'small': small,
        'medium': medium,
        'large': large,
        'xlarge': xlarge,
        'xxlarge': xxlarge,
      };

  /// Get all context-specific sizes (for documentation)
  static Map<String, double> get contextSizes => {
        'tabBar': tabBar,
        'bottomNavBar': bottomNavBar,
        'appBar': appBar,
        'buttonPrimary': buttonPrimary,
        'buttonSecondary': buttonSecondary,
        'card': card,
        'listTile': listTile,
        'chip': chip,
        'badge': badge,
        'dialog': dialog,
        'emptyState': emptyState,
        'loading': loading,
        'avatar': avatar,
        'input': input,
        'snackbar': snackbar,
        'menuItem': menuItem,
        'exerciseCard': exerciseCard,
        'workoutTimer': workoutTimer,
        'restTimer': restTimer,
        'setCounter': setCounter,
      };
}
