/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: shared/domain/services
/// Feature: Device Detection Service
/// Type: Singleton Service
///
/// Detects device type (mobile/desktop) and platform for web routing decisions.
library;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for detecting device characteristics
///
/// Used primarily for web to determine if user is on mobile browser
/// and should be redirected to app stores.
class DeviceDetectionService {

  factory DeviceDetectionService() => _instance ??= DeviceDetectionService._();

  DeviceDetectionService._();
  static DeviceDetectionService? _instance;

  /// Check if running on web platform
  bool get isWeb => kIsWeb;

  /// Check if running on mobile web browser
  ///
  /// Uses viewport width as primary check (more reliable than user agent)
  /// Threshold: 1024px (tablets in landscape are considered desktop-like)
  bool isMobileWeb(double screenWidth) {
    if (!kIsWeb) return false;
    return screenWidth < 1024;
  }

  /// Check if user agent indicates mobile device
  ///
  /// Fallback detection using user agent string.
  /// Note: User agent can be spoofed, use with [isMobileWeb] for best results.
  bool isMobileUserAgent(String userAgent) {
    if (!kIsWeb) return false;
    final ua = userAgent.toLowerCase();
    return ua.contains('mobile') ||
        ua.contains('android') ||
        ua.contains('iphone') ||
        ua.contains('ipad') ||
        ua.contains('ipod');
  }

  /// Detect if user is likely on iOS device (for deep linking)
  bool isIOSUserAgent(String userAgent) {
    final ua = userAgent.toLowerCase();
    return ua.contains('iphone') ||
        ua.contains('ipad') ||
        ua.contains('ipod');
  }

  /// Detect if user is likely on Android device (for deep linking)
  bool isAndroidUserAgent(String userAgent) {
    final ua = userAgent.toLowerCase();
    return ua.contains('android');
  }

  /// Get the appropriate store URL based on user agent
  String getStoreUrl(String userAgent) {
    if (isIOSUserAgent(userAgent)) {
      return 'https://apps.apple.com/app/fitlog-pro/id123456789'; // TODO: Replace with actual App Store ID
    }
    if (isAndroidUserAgent(userAgent)) {
      return 'https://play.google.com/store/apps/details?id=com.gymbro.fitlog';
    }
    // Default to App Store for unknown
    return 'https://apps.apple.com/app/fitlog-pro/id123456789';
  }

  /// Get deep link URL to open the app if installed
  ///
  /// Uses Universal Links (iOS) and App Links (Android) format
  String getDeepLinkUrl(String userAgent) {
    // Universal format that works with both platforms
    return 'https://fitlog.app/open';
  }

  /// Get custom scheme deep link (fallback)
  ///
  /// Used when Universal Links fail
  String getCustomSchemeDeepLink() {
    return 'fitlog://open';
  }
}
