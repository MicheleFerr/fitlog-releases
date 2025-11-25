/// 🏋️ Analytics Service Interface - DEPRECATED
///
/// **DEPRECATED**: This file is maintained for backward compatibility only.
///
/// **SSOT Location**: `lib/core/services/analytics/i_analytics_service.dart`
///
/// Migration guide:
/// ```dart
/// // Before (deprecated)
/// import 'package:gymbro_flutter_new/shared/domain/services/i_analytics_service.dart';
///
/// // After (SSOT)
/// import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
/// import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
/// ```
///
/// Note: The convenience methods (trackSearch, trackAutocompleteSelection,
/// trackPresetSelection) should be replaced with logEvent() calls:
/// ```dart
/// // Before
/// await analytics.trackSearch(query: 'bench', resultsCount: 10, ...);
///
/// // After
/// await analytics.logEvent(
///   name: 'exercise_search',
///   parameters: {'query': 'bench', 'results_count': 10, ...},
/// );
/// ```
library;

// Re-export from SSOT for backward compatibility
export 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// @deprecated Use IAnalyticsService from core/services/analytics/i_analytics_service.dart
///
/// This class is maintained for backward compatibility during migration.
/// Will be removed in a future version.
@Deprecated('Use IAnalyticsService from core/services/analytics/i_analytics_service.dart')
class NoOpAnalyticsService {
  const NoOpAnalyticsService();

  // Note: This stub class exists only for backward compatibility.
  // Use MockAnalyticsService from core/services/analytics/ instead.
}
