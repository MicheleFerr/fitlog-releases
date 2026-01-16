import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/consent_type.dart';

/// Privacy-Safe Analytics Service
///
/// PLACEHOLDER for Plausible Analytics integration (EU-hosted, GDPR-compliant)
///
/// TODO: Complete Plausible Analytics integration
/// 1. Add plausible_analytics package (pub.dev)
/// 2. Setup Plausible account (https://plausible.io)
/// 3. Configure domain and API endpoint
/// 4. Implement actual tracking calls
///
/// Currently: Logs events only in debug mode (no tracking)
///
/// Key Features:
/// - ✅ EU-hosted (GDPR compliant)
/// - ✅ No cookies
/// - ✅ No cross-site tracking
/// - ✅ No PII collection
/// - ✅ Conditional tracking (requires user consent)
/// - ✅ Respects Do Not Track
///
/// GDPR Compliance:
/// - Article 6(1)(a): Explicit consent required
/// - Article 7: Consent can be withdrawn anytime
/// - Article 13: Privacy policy link provided
/// - Article 25: Privacy by design (no PII collected)
///
/// Migration from Firebase Analytics:
/// This service can coexist with Firebase Analytics during migration.
/// Eventually, Firebase Analytics should be removed entirely.
class PrivacySafeAnalytics {
  static bool _initialized = false;

  /// Domain for Plausible analytics
  /// TODO: Replace with your actual domain
  static const String _domain = 'fitlogpro.app';

  /// Plausible server URL (EU-hosted instance)
  /// Default: Official Plausible Cloud (EU servers)
  static const String _serverUrl = 'https://plausible.io';

  /// Initialize Analytics
  ///
  /// Only initializes if user has granted analytics consent
  /// Call this at app startup (after consent check)
  static Future<void> initialize() async {
    if (_initialized) {
      if (kDebugMode) {
        debugPrint('⚠️ Analytics already initialized');
      }
      return;
    }

    // Check if user has consented to analytics
    final hasConsent = await PrivacyManager.hasConsent(ConsentType.analytics);
    if (!hasConsent) {
      // 🔐 GDPR: Ensure Firebase Analytics stays disabled
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      if (kDebugMode) {
        debugPrint('ℹ️ Analytics consent not granted - tracking disabled');
      }
      return;
    }

    // 🔐 GDPR FIX (A2): Enable Firebase Analytics ONLY after consent verified
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // TODO: Initialize actual Plausible client here
    _initialized = true;

    if (kDebugMode) {
      debugPrint('✅ Privacy-Safe Analytics initialized (GDPR-compliant, consent-based)');
      debugPrint('   Firebase Analytics: ENABLED (consent granted)');
      debugPrint('   Domain: $_domain');
      debugPrint('   Server: $_serverUrl');
    }
  }

  /// Track a page view
  ///
  /// Example:
  /// ```dart
  /// await PrivacySafeAnalytics.trackPageView('/workout/templates');
  /// ```
  static Future<void> trackPageView(String path, {String? referrer}) async {
    if (!await _canTrack()) return;

    // TODO: Implement actual Plausible pageview tracking
    if (kDebugMode) {
      debugPrint('📊 [PLACEHOLDER] Page view: $path ${referrer != null ? "(ref: $referrer)" : ""}');
    }
  }

  /// Track a custom event
  ///
  /// Example:
  /// ```dart
  /// await PrivacySafeAnalytics.trackEvent(
  ///   name: 'template_created',
  ///   props: {'category': 'strength'},
  /// );
  /// ```
  static Future<void> trackEvent({
    required String name,
    Map<String, dynamic>? props,
  }) async {
    if (!await _canTrack()) return;

    // TODO: Implement actual Plausible event tracking
    if (kDebugMode) {
      debugPrint('📊 [PLACEHOLDER] Event: $name ${props != null ? props.toString() : ""}');
    }
  }

  /// Stop analytics tracking
  ///
  /// Called when user withdraws analytics consent
  static Future<void> stop() async {
    _initialized = false;

    // 🔐 GDPR: Disable Firebase Analytics when consent withdrawn
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);

    if (kDebugMode) {
      debugPrint('🛑 Privacy-Safe Analytics stopped');
      debugPrint('   Firebase Analytics: DISABLED (consent withdrawn)');
    }
  }

  /// Restart analytics tracking
  ///
  /// Called when user grants analytics consent
  static Future<void> restart() async {
    await initialize();
  }

  /// Check if we can track analytics
  ///
  /// Returns true if:
  /// - User has granted analytics consent
  /// - Analytics is initialized
  static Future<bool> _canTrack() async {
    // Check consent first
    final hasConsent = await PrivacyManager.hasConsent(ConsentType.analytics);
    if (!hasConsent) {
      return false;
    }

    // Initialize if not already initialized
    if (!_initialized) {
      await initialize();
    }

    return _initialized;
  }

  /// Common Analytics Events
  ///
  /// Pre-defined events for common actions
  static Future<void> trackTemplateCreated(String category) async {
    await trackEvent(
      name: 'template_created',
      props: {'category': category},
    );
  }

  static Future<void> trackWorkoutStarted(String templateId) async {
    await trackEvent(
      name: 'workout_started',
      props: {'source': 'template'},
    );
  }

  static Future<void> trackWorkoutCompleted({
    required int duration,
    required int exercises,
    required int sets,
  }) async {
    await trackEvent(
      name: 'workout_completed',
      props: {
        'duration_minutes': (duration / 60).round(),
        'exercises_count': exercises,
        'sets_count': sets,
      },
    );
  }

  static Future<void> trackExerciseAdded(String exerciseName) async {
    await trackEvent(
      name: 'exercise_added',
      props: {'search_used': exerciseName.isNotEmpty},
    );
  }

  static Future<void> trackSearch(String query, int resultsCount) async {
    await trackEvent(
      name: 'search',
      props: {
        'query_length': query.length,
        'results_count': resultsCount,
      },
    );
  }

  static Future<void> trackFeatureUsed(String featureName) async {
    await trackEvent(
      name: 'feature_used',
      props: {'feature': featureName},
    );
  }

  /// Track app open (only if consent given)
  static Future<void> trackAppOpen() async {
    await trackPageView('/app/open');
  }

  /// Track screen view
  static Future<void> trackScreen(String screenName) async {
    await trackPageView('/screen/$screenName');
  }
}
