import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/adapters/notification_platform_adapter.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/adapters/ios_notification_adapter.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/adapters/android_notification_adapter.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/adapters/null_notification_adapter.dart';
import 'package:flutter/foundation.dart';

/// Factory class for creating platform-specific notification adapters
/// Automatically detects the platform and returns the appropriate adapter
class NotificationPlatformAdapterFactory {
  /// Create the appropriate platform adapter based on the current platform
  static NotificationPlatformAdapter create() {
    if (Platform.isIOS) {
      // CRITICAL FIX: Use NullNotificationAdapter for iOS to prevent duplicate notifications
      // iOS uses native DirectNotificationManager instead of flutter_local_notifications
      return NullNotificationAdapter();
    } else if (Platform.isAndroid) {
      return AndroidNotificationAdapter();
    } else {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }
  }

  /// Create adapter with specific platform override (useful for testing)
  static NotificationPlatformAdapter createForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return IOSNotificationAdapter();
      case 'android':
        return AndroidNotificationAdapter();
      default:
        throw UnsupportedError('Unsupported platform: $platform');
    }
  }

  /// Get platform name for the current platform
  static String getCurrentPlatformName() {
    if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else {
      return 'Unknown';
    }
  }

  /// Check if the current platform supports advanced notification features
  static bool supportsAdvancedFeatures() {
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Check if the current platform supports Live Activities
  static bool supportsLiveActivities() {
    return Platform.isIOS;
  }

  /// Check if the current platform supports notification channels
  static bool supportsNotificationChannels() {
    return Platform.isAndroid;
  }

  /// Check if the current platform supports critical alerts
  static bool supportsCriticalAlerts() {
    return Platform.isIOS;
  }

  /// Check if the current platform supports heads-up notifications
  static bool supportsHeadsUpNotifications() {
    return Platform.isAndroid;
  }

  /// Get platform-specific capabilities
  static Map<String, bool> getPlatformCapabilities() {
    return {
      'advancedFeatures': supportsAdvancedFeatures(),
      'liveActivities': supportsLiveActivities(),
      'notificationChannels': supportsNotificationChannels(),
      'criticalAlerts': supportsCriticalAlerts(),
      'headsUpNotifications': supportsHeadsUpNotifications(),
      'badgeSupport': Platform.isIOS,
      'groupingSupport': Platform.isAndroid,
      'customSounds': true,
      'richMedia': true,
      'actionButtons': true,
      'scheduling': true,
      'backgroundSync': true,
    };
  }

  /// Get recommended configuration for the current platform
  static Map<String, dynamic> getRecommendedConfiguration() {
    if (Platform.isIOS) {
      return {
        'requestCriticalAlerts': false, // Request only when needed
        'useLiveActivities': true,
        'enableBadgeCount': true,
        'defaultSoundEnabled': true,
        'interruptionLevels': {
          'low': 'passive',
          'normal': 'active',
          'high': 'timeSensitive',
          'critical': 'critical',
        },
      };
    } else if (Platform.isAndroid) {
      return {
        'createChannelsImmediately': true,
        'enableHeadsUpNotifications': true,
        'useNotificationGrouping': true,
        'enableVibration': true,
        'channelImportanceLevels': {
          'low': 'low',
          'normal': 'default',
          'high': 'high',
          'critical': 'max',
        },
      };
    } else {
      return {};
    }
  }

  /// Validate platform compatibility for specific features
  static List<String> validateFeatureCompatibility(List<String> requestedFeatures) {
    final unsupportedFeatures = <String>[];
    final capabilities = getPlatformCapabilities();

    for (final feature in requestedFeatures) {
      switch (feature) {
        case 'liveActivities':
          if (!capabilities['liveActivities']!) {
            unsupportedFeatures.add('Live Activities not supported on ${getCurrentPlatformName()}');
          }
          break;
        case 'criticalAlerts':
          if (!capabilities['criticalAlerts']!) {
            unsupportedFeatures.add('Critical alerts not supported on ${getCurrentPlatformName()}');
          }
          break;
        case 'notificationChannels':
          if (!capabilities['notificationChannels']!) {
            unsupportedFeatures.add('Notification channels not supported on ${getCurrentPlatformName()}');
          }
          break;
        case 'headsUpNotifications':
          if (!capabilities['headsUpNotifications']!) {
            unsupportedFeatures.add('Heads-up notifications not supported on ${getCurrentPlatformName()}');
          }
          break;
        case 'badgeCount':
          if (!capabilities['badgeSupport']!) {
            unsupportedFeatures.add('Badge count not supported on ${getCurrentPlatformName()}');
          }
          break;
        case 'notificationGrouping':
          if (!capabilities['groupingSupport']!) {
            unsupportedFeatures.add('Notification grouping limited on ${getCurrentPlatformName()}');
          }
          break;
      }
    }

    return unsupportedFeatures;
  }

  /// Get platform-specific optimization recommendations
  static List<String> getOptimizationRecommendations() {
    final recommendations = <String>[];

    if (Platform.isIOS) {
      recommendations.addAll([
        'Use Live Activities for long-running processes like workout timers',
        'Implement proper interruption levels for different notification types',
        'Use thread identifiers to group related notifications',
        'Consider requesting critical alert permissions only for emergency notifications',
        'Optimize badge count updates to avoid excessive battery usage',
      ]);
    } else if (Platform.isAndroid) {
      recommendations.addAll([
        'Create specific notification channels for each notification type',
        'Use notification grouping to prevent notification spam',
        'Implement heads-up notifications for time-sensitive alerts',
        'Optimize notification channel importance levels based on user preferences',
        'Use foreground services for background processing',
      ]);
    }

    recommendations.addAll([
      'Implement proper permission handling and graceful degradation',
      'Use local caching for offline notification management',
      'Implement proper cleanup for expired notifications',
      'Monitor notification delivery rates and performance metrics',
      'Provide user-friendly notification preference controls',
    ]);

    return recommendations;
  }
}

/// Riverpod provider for the platform-specific notification adapter
/// Automatically creates and initializes the correct adapter for the current platform
final notificationPlatformAdapterProvider = Provider<NotificationPlatformAdapter>((ref) {
  final adapter = NotificationPlatformAdapterFactory.create();
  
  // Initialize the adapter when first created
  adapter.initialize().catchError((error) {
    if (kDebugMode) {
      debugPrint('Failed to initialize notification platform adapter: $error');
    }
  });

  // Dispose when the provider is disposed
  ref.onDispose(() {
    adapter.dispose().catchError((error) {
      if (kDebugMode) {
        debugPrint('Failed to dispose notification platform adapter: $error');
      }
    });
  });

  return adapter;
});

/// Provider for platform capabilities information
final platformCapabilitiesProvider = Provider<Map<String, bool>>((ref) {
  return NotificationPlatformAdapterFactory.getPlatformCapabilities();
});

/// Provider for platform name
final currentPlatformNameProvider = Provider<String>((ref) {
  return NotificationPlatformAdapterFactory.getCurrentPlatformName();
});

/// Provider for recommended platform configuration
final recommendedPlatformConfigProvider = Provider<Map<String, dynamic>>((ref) {
  return NotificationPlatformAdapterFactory.getRecommendedConfiguration();
});

/// Provider for platform optimization recommendations
final platformOptimizationRecommendationsProvider = Provider<List<String>>((ref) {
  return NotificationPlatformAdapterFactory.getOptimizationRecommendations();
});