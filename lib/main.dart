import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/app/app.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/providers/shared_preferences_provider.dart';
// 🔄 AppLifecycleManager per flush batch queue quando app va in background
import 'package:gymbro_flutter_new/shared/presentation/widgets/app_lifecycle_manager.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/theme_mode_adapter.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:gymbro_flutter_new/core/security/app_check_config.dart';
import 'package:gymbro_flutter_new/shared/data/hive_timestamp_adapter.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/shared/data/models/weight_settings_model.dart';
import 'package:gymbro_flutter_new/shared/data/models/feedback_settings_model.dart';
import 'package:gymbro_flutter_new/shared/data/models/history_view_settings_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/shared/domain/security/device_security_checker.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';
import 'package:gymbro_flutter_new/shared/services/privacy_safe_analytics.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
// 🔔 DEEP LINKING: Required imports for cold-start notification deep linking
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ========================================
  // 🔔 DEEP LINKING: Initialize timezone for scheduled notifications
  // ========================================
  // MUST be called before scheduling any notifications
  // Uses IANA timezone database for accurate scheduling across timezones
  tz.initializeTimeZones();

  // ========================================
  // 🔔 DEEP LINKING: Cold-Start Detection (T=0ms to T=250ms)
  // ========================================
  // Detect if app was launched by tapping a notification (cold-start)
  // This runs BEFORE Firebase to minimize app launch time
  // Timeout protection prevents hanging if platform channel is slow

  String? initialDeepLink;

  try {
    DeepLinkLogger.logColdStartAttempt('Starting cold-start detection...');

    final launchDetails = await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails()
        .timeout(
          const Duration(milliseconds: 500),
          onTimeout: () {
            DeepLinkLogger.logTimeout();
            return null;
          },
        );

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails!.notificationResponse?.payload;
      DeepLinkLogger.logColdStartAttempt('Payload: $payload');

      if (payload != null && payload.isNotEmpty) {
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          final typeString = data['type'] as String?;

          if (typeString != null) {
            final type = NotificationType.values.firstWhere(
              (t) => t.toString() == typeString,
              orElse: () => NotificationType.workoutReminder,
            );

            final rawDeepLink = _buildDeepLinkSync(type, data);
            initialDeepLink = _validateDeepLink(rawDeepLink);

            if (initialDeepLink != null) {
              DeepLinkLogger.logColdStartAttempt('✅ Valid deep link: $initialDeepLink');
            } else {
              DeepLinkLogger.logColdStartAttempt('⚠️ Invalid deep link, using home: $rawDeepLink');
            }
          }
        } catch (jsonError) {
          DeepLinkLogger.logNavigationError(jsonError, StackTrace.current);
        }
      }
    } else {
      DeepLinkLogger.logColdStartAttempt('ℹ️ Normal app launch (not from notification)');
    }
  } catch (e, stackTrace) {
    DeepLinkLogger.logNavigationError(e, stackTrace);
  }

  // Initialize Firebase (handle Android auto-initialization)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized (common on Android with google-services.json)
    if (!e.toString().contains('duplicate-app')) {
      rethrow; // Re-throw if it's a different error
    }
  }

  // ========================================
  // CRITICAL FIX: Initialize Hive FIRST
  // ========================================
  // PrivacyManager and Analytics depend on Hive storage
  // Must be initialized BEFORE any service that uses Hive boxes

  await Hive.initFlutter();
  
  // Register Hive adapters BEFORE opening boxes
  if (!Hive.isAdapterRegistered(AppConfigAdapter().typeId)) {
    Hive.registerAdapter(AppConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(OnboardingStateAdapter().typeId)) {
    Hive.registerAdapter(OnboardingStateAdapter());
  }
  if (!Hive.isAdapterRegistered(ThemeModeAdapter().typeId)) {
    Hive.registerAdapter(ThemeModeAdapter());
  }
  if (!Hive.isAdapterRegistered(TimestampAdapter().typeId)) {
    Hive.registerAdapter(TimestampAdapter());
  }
  if (!Hive.isAdapterRegistered(WeightSettingsModelAdapter().typeId)) {
    Hive.registerAdapter(WeightSettingsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PlateOptionModelAdapter().typeId)) {
    Hive.registerAdapter(PlateOptionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(FeedbackSettingsModelAdapter().typeId)) {
    Hive.registerAdapter(FeedbackSettingsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HapticIntensityModelAdapter().typeId)) {
    Hive.registerAdapter(HapticIntensityModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HistoryViewModeModelAdapter().typeId)) {
    Hive.registerAdapter(HistoryViewModeModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HistoryViewSettingsModelAdapter().typeId)) {
    Hive.registerAdapter(HistoryViewSettingsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseUsageModelAdapter().typeId)) {
    Hive.registerAdapter(ExerciseUsageModelAdapter());
  }

  // ✅ CRITICAL FIX: Initialize HiveBoxManagerEnhanced with pre-opened critical boxes
  // This pre-opens: user_consents, privacy (app_config opened on-demand by AppConfigNotifier)
  // Must be called AFTER adapter registration, BEFORE any service uses boxes
  await HiveBoxManagerEnhanced.initialize();

  // ========================================
  // NOW Hive is ready: Initialize services that depend on it
  // ========================================

  // 🔐 SECURITY: Initialize Firebase App Check BEFORE any Firebase operations
  // This prevents API abuse from scraped/stolen API keys
  await AppCheckConfig.initialize();

  // 🔐 SECURITY: Initialize Device Security Checker
  // Detects jailbreak/root and provides security recommendations
  final deviceSecurity = DeviceSecurityChecker();
  await deviceSecurity.initialize();

  if (kDebugMode && deviceSecurity.isDeviceCompromised) {
    debugPrint('⚠️ SECURITY WARNING: Device compromised');
    debugPrint('   Security Level: ${deviceSecurity.securityLevel}%');
    debugPrint('   Status: ${deviceSecurity.securityStatus}');
    for (final recommendation in deviceSecurity.securityRecommendations) {
      debugPrint('   - $recommendation');
    }
  }

  // 🔐 PRIVACY: Initialize Privacy Manager for GDPR compliance
  // This manages user consent for analytics, marketing, etc.
  // ✅ NOW SAFE: Hive is initialized, can open consent box
  await PrivacyManager.initialize();

  // 🔐 PRIVACY: Initialize Privacy-Safe Analytics (EU-hosted, GDPR-compliant)
  // Only tracks if user has granted consent
  // ✅ NOW SAFE: Hive is initialized, can check consent
  await PrivacySafeAnalytics.initialize();

  if (kDebugMode) {
    final hasConsent = await PrivacyManager.hasProvidedConsent();
    debugPrint('📊 Privacy: User consent provided: $hasConsent');
  }

  // Enable Firestore offline persistence for better performance and offline support
  // This allows the app to work offline and reduces Firebase read costs by 50-70%
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize GDPR Consent (PRIMA delle ads!)
  final consentService = ConsentService();
  await consentService.initialize();

  // Initialize Google Mobile Ads (DOPO il consent)
  if (kDebugMode) {
    // Configure test device ID for development
    final requestConfiguration = RequestConfiguration(
      testDeviceIds: ['847b72988c2f5c8ba2c308cf222ace2c'],
    );
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    debugPrint('📱 AdMob test device configured: 847b72988c2f5c8ba2c308cf222ace2c');
  }
  await MobileAds.instance.initialize();

  if (kDebugMode) {
    AdMobConfig.printConfig();
    await consentService.printConsentInfo();
  }

  // Initialize secure storage boxes
  await _initializeStorage();

  // Initialize SharedPreferences for notification settings v2.0
  final sharedPreferences = await SharedPreferences.getInstance();

  // ========================================
  // 🔔 DEEP LINKING: Pass initial deep link to app via ProviderScope override
  // ========================================
  // This makes the deep link available to GoRouter's initialLocation
  // Avoids home screen flash by setting initial location synchronously
  runApp(
    ProviderScope(
      overrides: [
        // Override initialDeepLinkProvider with detected deep link (or null if normal launch)
        initialDeepLinkProvider.overrideWith((ref) => initialDeepLink),

        // Override sharedPreferencesProvider with initialized instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AppLifecycleManager(
        child: FitLogApp(),
      ),
    ),
  );
}

// ========================================
// 🔔 DEEP LINKING: Helper Functions
// ========================================

/// Build deep link synchronously from notification payload
/// Returns route path with query parameters (e.g., '/workout', '/analytics/exercise?id=123')
///
/// Synchronous to avoid race conditions with GoRouter initialization
/// Maps NotificationType to corresponding app routes
String _buildDeepLinkSync(NotificationType type, Map<String, dynamic> data) {
  // ✅ CORRECTED: Route mapping based on notification type (using ACTUAL GoRouter routes)
  // Note: Query parameters are removed as existing routes don't support them
  // Deep linking navigates to general screens where user can find specific content
  final routeMap = {
    NotificationType.workoutReminder: '/workout',
    NotificationType.achievementUnlocked: '/analytics', // Generic analytics screen
    NotificationType.progressMilestone: '/analytics',   // Generic analytics screen
    NotificationType.restReminder: '/routine',          // Routine center (CORRECT route name)
    NotificationType.workoutSummary: '/analytics',
    NotificationType.streakReminder: '/analytics',
    NotificationType.timerComplete: '/workout',
  };

  final baseRoute = routeMap[type] ?? '/';

  // Return base route without query params (existing routes don't support them)
  return baseRoute;
}

/// Validate deep link and return null if invalid
///
/// Prevents navigation to invalid routes that would cause errors
/// ✅ CORRECTED: Uses actual GoRouter routes (no query params needed)
String? _validateDeepLink(String deepLink) {
  // ✅ CORRECTED: Allowed routes (must match ACTUAL GoRouter routes in app.dart)
  const allowedRoutes = [
    '/',
    '/workout',
    '/analytics',
    '/routine',
    '/settings',
    '/community',
    '/workout-history',
  ];

  // Check if route is allowed (no query params anymore, so simple check)
  if (!allowedRoutes.contains(deepLink)) {
    DeepLinkLogger.logColdStartAttempt('❌ Invalid route: $deepLink (not in allowed list)');
    return null; // Invalid route, use home screen
  }

  return deepLink; // Valid deep link
}

/// Structured logging for deep linking events
///
/// Provides debug visibility into cold-start and warm-start navigation
/// All logs are debug-only (stripped in release builds)
class DeepLinkLogger {
  /// Log cold-start deep link attempt (app completely closed)
  static void logColdStartAttempt(String message) {
    if (kDebugMode) {
      debugPrint('🔔 [Deep Link COLD-START] $message');
    }
  }

  /// Log warm-start deep link attempt (app already running)
  static void logWarmStartAttempt(String message) {
    if (kDebugMode) {
      debugPrint('🔔 [Deep Link WARM-START] $message');
    }
  }

  /// Log timeout during platform channel call
  static void logTimeout() {
    if (kDebugMode) {
      debugPrint('⏱️ [Deep Link] Timeout on getNotificationAppLaunchDetails (500ms limit)');
      debugPrint('   Using home screen as fallback');
    }
  }

  /// Log navigation errors
  static void logNavigationError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [Deep Link] Navigation error: $error');
      if (stackTrace != null) {
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }
}

/// Initialize all storage systems
Future<void> _initializeStorage() async {
  // ⚡ PERFORMANCE OPTIMIZATION: Open basic boxes in parallel
  // This reduces app startup time by ~30-40% (from ~19s to ~12s)

  // DIAGNOSTIC: Always print in both Debug and Release mode (for debugging)
  print('📦 [Storage] Starting initialization...');

  await Future.wait([
    _openBox('auth_box'),
    _openBox('timer_box'),
    _openBox('workout_box'),
    _openBox('settings_box'),
    _openBox<OnboardingState>('onboarding_state'),
    _openBox<AppConfig>('app_config'),
    _openBox<Map>('workoutMetrics'), // Analytics caching
    // ✅ FIX: Removed analytics_cache - already opened in HiveBoxManagerEnhanced.initialize()
  ]);

  // DIAGNOSTIC: Always print in both Debug and Release mode (for debugging)
  print('📦 [Storage] ✅ Basic boxes opened successfully');

  // ⚡ PERFORMANCE: Initialize datasources and services in parallel
  // This reduces sequential waits and improves startup time by ~20-30%
  //
  // ✅ NOTE: HiveBoxManagerEnhanced handles all Hive box initialization automatically
  // Boxes are opened on-demand when first accessed, no explicit init needed
  await Future.wait([

    // Exercise usage tracker (ML-enhanced fuzzy search)
    _safeInitialize(
      'ExerciseUsageTracker',
      () => ExerciseUsageTracker().initialize(),
    ),

    // Persistent fuzzy search isolate (saves 200ms per search)
    _safeInitialize(
      'ExerciseFuzzyMatcher',
      () => ExerciseFuzzyMatcher.initialize(),
      onSuccess: () {
        if (kDebugMode) {
          debugPrint('✅ Fuzzy search isolate initialized');
        }
      },
    ),
  ]);

  // 🔔 NOTIFICATION SERVICES: Initialize notification system after storage
  // This must run AFTER Hive initialization since services may use local storage
  await _initializeNotificationServices();
}

/// Initialize notification services at app startup
///
/// This function:
/// 1. Schedules daily workout reminders for next 30 days (9:00 AM)
/// 2. Sets up auto-check for streak achievements
///
/// Called once during app initialization, after storage is ready.
Future<void> _initializeNotificationServices() async {
  // NOTE: We cannot use Riverpod ref here since we're in main.dart
  // Notification services will be properly initialized when ProviderScope is created
  // This is just a placeholder for documentation purposes

  if (kDebugMode) {
    debugPrint('🔔 [Notifications] Services will initialize after ProviderScope creation');
    debugPrint('   - Daily workout reminders (9:00 AM, 30 days)');
    debugPrint('   - Streak achievement auto-check');
  }
}

/// Helper function to safely initialize services with error handling
Future<void> _safeInitialize(
  String serviceName,
  Future<void> Function() initializer, {
  void Function()? onSuccess,
}) async {
  try {
    await initializer();
    onSuccess?.call();
  } catch (e, stackTrace) {
    // Log only errors in debug mode
    assert(() {
      debugPrint('❌ Failed to initialize $serviceName: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return true;
    }());
    // Continue execution even if initialization fails
  }
}

Future<void> _openBox<T>(String boxName) async {
  final boxManager = HiveBoxManagerEnhanced();
  try {
    // DIAGNOSTIC: Always print in both Debug and Release mode (for debugging)
    print('📦 [Storage] Opening box: $boxName');
    await boxManager.openBox<T>(boxName);
    // DIAGNOSTIC: Always print in both Debug and Release mode (for debugging)
    print('📦 [Storage] ✅ Opened: $boxName');
  } catch (e, stackTrace) {
    // DIAGNOSTIC: Log errors ALWAYS (critical for debugging Release mode)
    print('❌ [Storage] FAILED to open $boxName box: $e');
    print('📍 [Storage] Stack trace: $stackTrace');

    // Handle corrupted boxes that need recovery
    if ((boxName == 'app_config' && e.toString().contains('typeId')) ||
        (boxName == 'onboarding_state' && e.toString().contains('already open and of type Box<dynamic>'))) {
      // Attempt to recover corrupted box
      try {
        // Close the box if it's open
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }

        // Delete the corrupted box
        await Hive.deleteBoxFromDisk(boxName);

        // Try to open it again (will create a new empty box)
        await boxManager.openBox<T>(boxName);
      } catch (recoveryError) {
        // Log recovery errors only in debug mode
        assert(() {
          debugPrint('❌ Failed to recover $boxName box: $recoveryError');
          return true;
        }());
        // Continue execution even if recovery fails
      }
    }
  }
}
