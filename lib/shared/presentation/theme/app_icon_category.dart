import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Type-safe icon category system
///
/// Provides compile-time safety for icon organization and discovery.
/// Categories help developers find the right icon quickly and ensure
/// consistent icon usage across features.
///
/// **Usage:**
/// ```dart
/// // Get all workout icons
/// final workoutIcons = AppIconCategory.workout.icons;
///
/// // Check if icon belongs to category
/// final isWorkout = AppIconCategory.workout.contains(AppIcons.workout);
///
/// // Iterate all categories
/// for (final category in AppIconCategory.values) {
///   print('${category.name}: ${category.icons.length} icons');
/// }
/// ```
enum AppIconCategory {
  /// Workout and exercise icons
  /// Examples: workout, cardio, gymnastics, flexibility
  workout(
    displayName: 'Workout',
    description: 'Exercise and training related icons',
  ),

  /// Timer and scheduling icons
  /// Examples: timer, schedule, history, clock
  timer(
    displayName: 'Timer',
    description: 'Time tracking and scheduling icons',
  ),

  /// Analytics and chart icons
  /// Examples: analytics, barChart, lineChart, trendUp
  analytics(
    displayName: 'Analytics',
    description: 'Data visualization and metrics icons',
  ),

  /// Status and state indicators
  /// Examples: complete, error, info, warning
  status(
    displayName: 'Status',
    description: 'State and feedback indicator icons',
  ),

  /// Action and CRUD operations
  /// Examples: add, edit, delete, save, refresh
  action(
    displayName: 'Action',
    description: 'User action and operation icons',
  ),

  /// Navigation and directional icons
  /// Examples: home, close, back, forward, expand
  navigation(
    displayName: 'Navigation',
    description: 'Navigation and directional icons',
  ),

  /// Social and user-related icons
  /// Examples: person, people, verified, star
  social(
    displayName: 'Social',
    description: 'Social and user interaction icons',
  ),

  /// Settings and configuration icons
  /// Examples: settings, admin, lock, notifications
  settings(
    displayName: 'Settings',
    description: 'Configuration and settings icons',
  ),

  /// Premium and special features
  /// Examples: premium, gift, rocket
  premium(
    displayName: 'Premium',
    description: 'Premium features and special icons',
  ),

  /// Media controls
  /// Examples: play, pause, stop, camera
  media(
    displayName: 'Media',
    description: 'Media playback and capture icons',
  ),

  /// Miscellaneous utilities
  /// Examples: search, filter, share, download
  misc(
    displayName: 'Misc',
    description: 'Utility and miscellaneous icons',
  );

  final String displayName;
  final String description;

  const AppIconCategory({
    required this.displayName,
    required this.description,
  });

  /// Get all icons in this category
  Map<String, IconData> get icons {
    switch (this) {
      case AppIconCategory.workout:
        return {
          'workout': AppIcons.workout,
          'cardio': AppIcons.cardio,
          'gymnastics': AppIcons.gymnastics,
          'sportsGymnastics': AppIcons.sportsGymnastics,
          'flexibility': AppIcons.flexibility,
          'accessibility': AppIcons.accessibility,
        };

      case AppIconCategory.timer:
        return {
          'timer': AppIcons.timer,
          'timerOff': AppIcons.timerOff,
          'schedule': AppIcons.schedule,
          'clock': AppIcons.clock,
          'history': AppIcons.history,
        };

      case AppIconCategory.analytics:
        return {
          'analytics': AppIcons.analytics,
          'barChart': AppIcons.barChart,
          'lineChart': AppIcons.lineChart,
          'insights': AppIcons.insights,
          'speed': AppIcons.speed,
          'trendUp': AppIcons.trendUp,
          'trendDown': AppIcons.trendDown,
          'trendFlat': AppIcons.trendFlat,
        };

      case AppIconCategory.status:
        return {
          'complete': AppIcons.complete,
          'completeOutline': AppIcons.completeOutline,
          'check': AppIcons.check,
          'allDone': AppIcons.allDone,
          'doneAll': AppIcons.doneAll,
          'error': AppIcons.error,
          'info': AppIcons.info,
          'warning': AppIcons.warning,
        };

      case AppIconCategory.action:
        return {
          'add': AppIcons.add,
          'addCircleOutline': AppIcons.addCircleOutline,
          'edit': AppIcons.edit,
          'delete': AppIcons.delete,
          'deleteOutline': AppIcons.deleteOutline,
          'save': AppIcons.save,
          'copy': AppIcons.copy,
          'paste': AppIcons.paste,
          'undo': AppIcons.undo,
          'redo': AppIcons.redo,
          'refresh': AppIcons.refresh,
        };

      case AppIconCategory.navigation:
        return {
          'home': AppIcons.home,
          'close': AppIcons.close,
          'back': AppIcons.back,
          'forward': AppIcons.forward,
          'forwardIos': AppIcons.forwardIos,
          'expandMore': AppIcons.expandMore,
          'expandLess': AppIcons.expandLess,
          'chevronRight': AppIcons.chevronRight,
          'chevronLeft': AppIcons.chevronLeft,
          'clear': AppIcons.clear,
          'remove': AppIcons.remove,
        };

      case AppIconCategory.social:
        return {
          'person': AppIcons.person,
          'people': AppIcons.people,
          'peopleOutline': AppIcons.peopleOutline,
          'verified': AppIcons.verified,
          'handshake': AppIcons.handshake,
          'star': AppIcons.star,
          'starOutline': AppIcons.starOutline,
          'achievement': AppIcons.achievement,
          'streak': AppIcons.streak,
          'celebration': AppIcons.celebration,
          'thumbUp': AppIcons.thumbUp,
          'thumbDown': AppIcons.thumbDown,
        };

      case AppIconCategory.settings:
        return {
          'settings': AppIcons.settings,
          'admin': AppIcons.admin,
          'lock': AppIcons.lock,
          'unlock': AppIcons.unlock,
          'notifications': AppIcons.notifications,
          'theme': AppIcons.theme,
          'language': AppIcons.language,
        };

      case AppIconCategory.premium:
        return {
          'premium': AppIcons.premium,
          'gift': AppIcons.gift,
          'rocket': AppIcons.rocket,
          'autoAwesome': AppIcons.autoAwesome,
        };

      case AppIconCategory.media:
        return {
          'play': AppIcons.play,
          'pause': AppIcons.pause,
          'stop': AppIcons.stop,
          'skipNext': AppIcons.skipNext,
          'repeat': AppIcons.repeat,
          'camera': AppIcons.camera,
          'image': AppIcons.image,
        };

      case AppIconCategory.misc:
        return {
          'search': AppIcons.search,
          'searchOff': AppIcons.searchOff,
          'filter': AppIcons.filter,
          'share': AppIcons.share,
          'download': AppIcons.download,
          'upload': AppIcons.upload,
          'document': AppIcons.document,
          'link': AppIcons.link,
          'email': AppIcons.email,
          'location': AppIcons.location,
          'cloud': AppIcons.cloud,
          'cloudSync': AppIcons.cloudSync,
          'chat': AppIcons.chat,
          'menu': AppIcons.menu,
          'moreVert': AppIcons.moreVert,
          'moreHoriz': AppIcons.moreHoriz,
          'visibility': AppIcons.visibility,
          'visibilityOff': AppIcons.visibilityOff,
          'lightMode': AppIcons.lightMode,
          'darkMode': AppIcons.darkMode,
          'colorLens': AppIcons.colorLens,
        };
    }
  }

  /// Check if icon belongs to this category
  bool contains(IconData icon) {
    return icons.values.contains(icon);
  }

  /// Get category for an icon (returns null if not found)
  ///
  /// Uses lazy-initialized cache for O(1) lookup performance.
  /// Cache is built on first access and reused for subsequent calls.
  static AppIconCategory? categoryFor(IconData icon) {
    _buildCategoryMapIfNeeded();
    return _categoryMap?[icon];
  }

  /// Lazy-initialized category lookup map for O(1) performance
  static Map<IconData, AppIconCategory>? _categoryMap;

  /// Build category map on first access (lazy initialization)
  static void _buildCategoryMapIfNeeded() {
    if (_categoryMap != null) return;

    final map = <IconData, AppIconCategory>{};
    for (final category in AppIconCategory.values) {
      for (final icon in category.icons.values) {
        map[icon] = category;
      }
    }
    _categoryMap = map;
  }

  /// Get all icons across all categories
  static Map<String, IconData> get allIcons {
    final Map<String, IconData> all = {};
    for (final category in AppIconCategory.values) {
      all.addAll(category.icons);
    }
    return all;
  }

  /// Get icon count for this category
  int get count => icons.length;

  /// Get total icon count across all categories
  static int get totalCount {
    return AppIconCategory.values.fold(0, (sum, cat) => sum + cat.count);
  }
}

/// Extension to get category from IconData
extension IconDataCategory on IconData {
  /// Get the category this icon belongs to
  AppIconCategory? get category => AppIconCategory.categoryFor(this);

  /// Check if this icon is in a specific category
  bool isInCategory(AppIconCategory category) => category.contains(this);
}

/// Semantic helpers for conditional logic based on category type
///
/// Useful for applying different styles or behaviors based on icon semantics.
/// Example: Apply different colors to action icons vs status icons.
extension AppIconCategoryHelpers on AppIconCategory {
  /// Icons representing user actions (navigation, CRUD operations)
  bool get isAction =>
      this == AppIconCategory.action || this == AppIconCategory.navigation;

  /// Icons for data visualization and analytics
  bool get isVisualization => this == AppIconCategory.analytics;

  /// Icons representing state or feedback
  bool get isState => this == AppIconCategory.status;

  /// Icons for social interactions and user engagement
  bool get isSocial => this == AppIconCategory.social;

  /// Icons for content and media
  bool get isContent => this == AppIconCategory.media;

  /// Icons for configuration and preferences
  bool get isConfiguration => this == AppIconCategory.settings;

  /// Icons for time-related features
  bool get isTemporal =>
      this == AppIconCategory.timer || this == AppIconCategory.workout;

  /// Get suggested icon color based on category semantics
  ///
  /// Returns context-aware color that matches category intent:
  /// - Action/Navigation → Primary (brand color)
  /// - Visualization → Secondary (accent)
  /// - State → Varies by state (success/error/warning)
  /// - Social → Tertiary (community feel)
  /// - Default → OnSurface (neutral)
  Color suggestedColor(BuildContext context) {
    return switch (this) {
      AppIconCategory.workout => context.colors.primary,
      AppIconCategory.analytics => context.colors.secondary,
      AppIconCategory.timer => context.colors.secondary,
      AppIconCategory.status => context.colors.tertiary,
      AppIconCategory.action => context.colors.primary,
      AppIconCategory.navigation => context.colors.primary,
      AppIconCategory.social => context.colors.tertiary,
      AppIconCategory.settings => context.colors.onSurface,
      AppIconCategory.premium => context.colors.secondary,
      AppIconCategory.media => context.colors.tertiary,
      AppIconCategory.misc => context.colors.onSurface,
    };
  }

  /// Get suggested icon size based on category importance
  ///
  /// Returns semantic size that reflects typical usage:
  /// - Premium/Workout → Large (featured content)
  /// - Navigation/Action → Medium (standard UI)
  /// - Status/Misc → Small (secondary indicators)
  double get suggestedSize {
    return switch (this) {
      AppIconCategory.premium => AppIconSize.xlarge,
      AppIconCategory.workout => AppIconSize.large,
      AppIconCategory.analytics => AppIconSize.large,
      AppIconCategory.navigation => AppIconSize.medium,
      AppIconCategory.action => AppIconSize.medium,
      AppIconCategory.timer => AppIconSize.medium,
      AppIconCategory.social => AppIconSize.medium,
      AppIconCategory.media => AppIconSize.medium,
      AppIconCategory.status => AppIconSize.small,
      AppIconCategory.settings => AppIconSize.small,
      AppIconCategory.misc => AppIconSize.small,
    };
  }
}
