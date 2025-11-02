import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

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
  static AppIconCategory? categoryFor(IconData icon) {
    for (final category in AppIconCategory.values) {
      if (category.contains(icon)) {
        return category;
      }
    }
    return null;
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
