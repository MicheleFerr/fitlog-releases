/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/providers
/// Feature: analytics
/// Type: provider
///
/// Analytics View Mode Provider - User preference for simple/detailed view
///
/// **Purpose**: Manage view mode state (simple vs detailed)
/// **Features**:
/// - Persistent storage via SharedPreferences
/// - Default: simple mode
/// - Toggle between modes with haptic feedback
library;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';

/// View modes for analytics screen
enum AnalyticsViewMode {
  /// Simplified view (default) - Basic stats, no advanced features
  simple,

  /// Detailed view - All stats, Pro Insights, advanced filters
  detailed,
}

/// SharedPreferences key for view mode
const _kViewModeKey = 'analytics_view_mode';

/// Helper class for view mode persistence
class AnalyticsViewModeHelper {
  /// Load view mode from SharedPreferences
  static Future<AnalyticsViewMode> loadViewMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_kViewModeKey);

      return savedMode == 'detailed'
          ? AnalyticsViewMode.detailed
          : AnalyticsViewMode.simple;
    } catch (e) {
      return AnalyticsViewMode.simple; // Default
    }
  }

  /// Save view mode to SharedPreferences
  static Future<void> saveViewMode(AnalyticsViewMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kViewModeKey,
        mode == AnalyticsViewMode.detailed ? 'detailed' : 'simple',
      );
    } catch (e) {
      // Fail silently - state is still updated in memory
    }
  }
}

/// Provider for analytics view mode with persistence
final analyticsViewModeProvider =
    createStateProvider<AnalyticsViewMode>(AnalyticsViewMode.simple);

/// Initialize view mode from storage (call once at app start)
Future<AnalyticsViewMode> initializeAnalyticsViewMode() async {
  return await AnalyticsViewModeHelper.loadViewMode();
}
