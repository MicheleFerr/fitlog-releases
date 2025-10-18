/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/data/utils
/// 🎯 Feature: smart_notifications
/// 🔧 Type: utility
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// TIMEZONE HELPER - Initialize timezone database for notifications
library;

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Helper class for timezone initialization
class TimezoneHelper {
  static bool _isInitialized = false;

  /// Initialize timezone database
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Set local timezone
      // On real devices, this should be detected automatically
      // For now, we use a default location
      final String timeZoneName = DateTime.now().timeZoneName;
      
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        // Fallback to UTC if timezone is not found
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      _isInitialized = true;
    } catch (e) {
      // If initialization fails, fallback to UTC
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('UTC'));
        _isInitialized = true;
      } catch (_) {
        // Ignore errors in fallback
      }
    }
  }

  /// Check if timezone is initialized
  static bool get isInitialized => _isInitialized;

  /// Get current timezone location
  static tz.Location? get localLocation {
    try {
      return tz.local;
    } catch (e) {
      return null;
    }
  }
}
