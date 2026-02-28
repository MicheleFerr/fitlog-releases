import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; // 🔐 GDPR: Analytics consent
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/app/app.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/interface_size.dart';
import 'package:gymbro_flutter_new/shared/providers/shared_preferences_provider.dart';
// 🔄 AppLifecycleManager per flush batch queue quando app va in background
import 'package:gymbro_flutter_new/shared/presentation/widgets/app_lifecycle_manager.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/theme_mode_adapter.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:gymbro_flutter_new/core/config/environment_config.dart'; // 🔐 SECURITY: Environment variables
import 'package:gymbro_flutter_new/core/security/app_check_config.dart';
import 'package:gymbro_flutter_new/shared/domain/services/secure_logger.dart'; // 🔐 SECURITY: Secure logging
import 'package:gymbro_flutter_new/shared/data/hive_timestamp_adapter.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/shared/data/models/weight_settings_model.dart';
import 'package:gymbro_flutter_new/shared/data/models/feedback_settings_model.dart';
import 'package:gymbro_flutter_new/shared/data/models/history_view_settings_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
// Removed: exercise_fuzzy_matcher.dart - overengineered, deleted
import 'package:gymbro_flutter_new/shared/domain/security/device_security_checker.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';
import 'package:gymbro_flutter_new/shared/services/privacy_safe_analytics.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_migration_service.dart'; // 🔐 SECURITY: Hive encryption migration
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 🔔 Deep linking cold-start
import 'package:voo_logging/voo_logging.dart'; // 🔍 Unified logging + HTTP inspector
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart'; // google_sign_in 7.x init
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_draft.dart'; // 💾 Workout Draft for auto-save
import 'package:gymbro_flutter_new/features/workout/data/models/user_exercise_preferences.dart'; // 📝 Form Cues for exercises
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart'; // 🏋️ Custom Exercises
import 'package:gymbro_flutter_new/features/scheduling/data/models/scheduled_workout_model.dart'; // 📅 Scheduled Workouts
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart'; // 🔧 Pre-load AppConfig
import 'package:gymbro_flutter_new/features/workout/data/services/template_cloud_sync_service.dart'; // 🔄 Template Cloud Sync with exponential backoff
import 'package:gymbro_flutter_new/features/ai_coach/data/models/scientific_paper_model.dart'; // 🤖 AI Coach Documents
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/document_local_datasource.dart'; // 🤖 AI Coach Document Cache
// 🤖 AI Coach Document Sync
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_card_settings.dart'; // 🎨 Exercise Card Settings
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart'; // 🏋️ Gym Equipment Profiles
import 'package:gymbro_flutter_new/shared/data/models/exercise_popularity_hive_model.dart'; // 📊 Exercise Popularity
import 'package:gymbro_flutter_new/shared/data/services/exercise_popularity_cache.dart';
import 'package:gymbro_flutter_new/shared/data/services/exercise_popularity_bundle_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  // 🚀 SPLASH: Preserve native splash screen during initialization
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ========================================
  // 🔍 LOGGING: Initialize VooLogger
  // ========================================
  // Unified logging with HTTP monitoring (replaces alice)
  // Only enabled in debug mode
  if (kDebugMode) {
    await VooLogger.initialize();
    debugPrint('✅ VooLogger initialized (debug mode)');
  }

  // NOTE: Timezone initialized by LocalNotificationDatasource.initialize()

  // ========================================
  // 🔐 SECURITY: Load Environment Variables from .env
  // ========================================
  // MUST be called before Firebase.initializeApp()
  // Loads sensitive Firebase API keys from .env file (not in version control)
  try {
    await EnvironmentConfig.load();
    if (kDebugMode) {
      debugPrint('✅ Environment configuration loaded successfully');
    }
  } catch (e) {
    // Critical: Cannot proceed without environment config
    if (kDebugMode) {
      debugPrint('❌ FATAL: Failed to load .env file');
      debugPrint('   Error: $e');
      debugPrint('   Make sure .env exists (copy from .env.example)');
    }
    rethrow; // Cannot continue without environment config
  }

  // ========================================
  // 🔔 DEEP LINKING: Cold-Start Detection (T=0ms to T=250ms)
  // ========================================
  // Detect if app was launched by tapping a notification.
  // Parse the payload to extract the deep link path for GoRouter.
  String? initialDeepLink;
  try {
    final notificationLaunchDetails = await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails();
    if (notificationLaunchDetails?.didNotificationLaunchApp == true) {
      final payload = notificationLaunchDetails!.notificationResponse?.payload;
      if (payload != null) {
        final parts = payload.split(':');
        if (parts.length >= 3) {
          initialDeepLink = parts.sublist(2).join(':');
          if (kDebugMode) {
            debugPrint(
              '🔔 [DeepLink] Cold-start from notification → $initialDeepLink',
            );
          }
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ [DeepLink] Failed to get launch details: $e');
    }
  }

  // Initialize Firebase only once (iOS AppDelegate/Android may already initialize)
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // AppDelegate/SDK may have already configured [DEFAULT] before Dart boot.
      final isDuplicateApp = e is FirebaseException
          ? e.code == 'duplicate-app'
          : e.toString().contains('duplicate-app');
      if (!isDuplicateApp) {
        rethrow;
      }
    }
  }

  // ========================================
  // 🔍 CRASHLYTICS: Error Tracking & Crash Reports
  // ========================================
  // Capture Flutter framework errors
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Capture errors outside Flutter (async errors, platform errors)
  // FIX: Use fatal: false — these are unhandled async errors, not actual crashes.
  // fatal: true was making all errors appear as crashes in Crashlytics, masking real issues.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    return true;
  };
  if (kDebugMode) {
    debugPrint('✅ Firebase Crashlytics initialized');
  }

  // ========================================
  // 🔐 GDPR FIX (A2): Disable Analytics IMMEDIATELY after Firebase init
  // ========================================
  // Analytics collection must be OFF by default until consent is verified.
  // This prevents any data collection before user grants consent.
  // Re-enabled later in PrivacySafeAnalytics.initialize() if consent exists.
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  if (kDebugMode) {
    debugPrint('🔐 GDPR: Firebase Analytics disabled (pending consent)');
  }

  // ========================================
  // 🔐 GOOGLE SIGN-IN: Initialize (google_sign_in 7.x)
  // ========================================
  // Must be called after Firebase init, before any auth operations
  try {
    await AuthService.initializeGoogleSignIn();
    if (kDebugMode) {
      debugPrint('✅ GoogleSignIn initialized (7.x singleton)');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ GoogleSignIn initialization failed: $e');
    }
    // Non-fatal: auth will reinitialize when needed
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
  if (!Hive.isAdapterRegistered(InterfaceSizeAdapter().typeId)) {
    Hive.registerAdapter(InterfaceSizeAdapter());
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
  // 💾 Workout Draft adapter for auto-save functionality
  if (!Hive.isAdapterRegistered(WorkoutDraftAdapter().typeId)) {
    Hive.registerAdapter(WorkoutDraftAdapter());
  }
  // 📝 User Exercise Preferences adapter for Form Cues
  if (!Hive.isAdapterRegistered(UserExercisePreferencesAdapter().typeId)) {
    Hive.registerAdapter(UserExercisePreferencesAdapter());
  }
  // 🏋️ Custom Exercise adapter for user-created exercises
  if (!Hive.isAdapterRegistered(CustomExerciseAdapter().typeId)) {
    Hive.registerAdapter(CustomExerciseAdapter());
  }

  // 📅 Scheduled Workout adapters for workout planning
  if (!Hive.isAdapterRegistered(ScheduleStatusModelAdapter().typeId)) {
    Hive.registerAdapter(ScheduleStatusModelAdapter());
  }
  if (!Hive.isAdapterRegistered(ScheduledWorkoutModelAdapter().typeId)) {
    Hive.registerAdapter(ScheduledWorkoutModelAdapter());
  }

  // 🤖 AI Coach Documents adapter for scientific papers cache
  if (!Hive.isAdapterRegistered(ScientificPaperModelAdapter().typeId)) {
    Hive.registerAdapter(ScientificPaperModelAdapter());
  }

  // 🎨 Exercise Card Settings adapters
  if (!Hive.isAdapterRegistered(ExerciseGifSizeAdapter().typeId)) {
    Hive.registerAdapter(ExerciseGifSizeAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseCardDensityAdapter().typeId)) {
    Hive.registerAdapter(ExerciseCardDensityAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseFooterElementAdapter().typeId)) {
    Hive.registerAdapter(ExerciseFooterElementAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseCardSettingsAdapter().typeId)) {
    Hive.registerAdapter(ExerciseCardSettingsAdapter());
  }

  // 🏋️ Gym Equipment Profiles adapter for plate calculator
  if (!Hive.isAdapterRegistered(GymEquipmentProfileAdapter().typeId)) {
    Hive.registerAdapter(GymEquipmentProfileAdapter());
  }

  // 📊 Exercise Popularity adapter for search ranking boost
  if (!Hive.isAdapterRegistered(ExercisePopularityHiveModelAdapter().typeId)) {
    Hive.registerAdapter(ExercisePopularityHiveModelAdapter());
  }

  // ✅ CRITICAL FIX: Initialize HiveBoxManagerEnhanced with pre-opened critical boxes
  // This pre-opens: user_consents, privacy (app_config opened on-demand by AppConfigNotifier)
  // Must be called AFTER adapter registration, BEFORE any service uses boxes
  await HiveBoxManagerEnhanced.initialize();

  // ========================================
  // 🔐 SECURITY: One-Time Migration to Encrypted Hive Boxes
  // ========================================
  // Migrates 4 sensitive boxes from unencrypted to AES-256 encrypted:
  // - user_consents (GDPR consent data)
  // - privacy (privacy settings)
  // - app_config (user preferences)
  // - user_profile_cache (PII: email, displayName)
  //
  // This runs ONCE on app update. Uses SharedPreferences flag to prevent re-running.
  // MUST run AFTER Hive.initFlutter() and adapter registration
  // MUST run BEFORE any service that uses these boxes (PrivacyManager, etc.)

  try {
    final prefs = await SharedPreferences.getInstance();
    const migrationKey = 'hive_encryption_migrated_v1';
    final alreadyMigrated = prefs.getBool(migrationKey) ?? false;

    if (!alreadyMigrated) {
      if (kDebugMode) {
        debugPrint(
          '🔐 [Security] Starting one-time Hive encryption migration...',
        );
        debugPrint('   Migrating 4 sensitive boxes to AES-256 encryption');
      }

      // Run migration for all sensitive boxes
      final results = await HiveMigrationService.migrateAllSensitiveBoxes();

      if (kDebugMode) {
        debugPrint('🔐 [Security] Migration results:');
        results.forEach((boxName, migrated) {
          final status = migrated
              ? '✅ Migrated'
              : '⚠️ Skipped (already encrypted or missing)';
          debugPrint('   - $boxName: $status');
        });
      }

      // Mark migration as complete (even if some boxes were skipped)
      // This prevents re-running migration on every app launch
      await prefs.setBool(migrationKey, true);

      if (kDebugMode) {
        final migratedCount = results.values.where((v) => v).length;
        debugPrint(
          '🔐 [Security] ✅ Migration complete: $migratedCount/${results.length} boxes encrypted',
        );
        debugPrint('   Flag set: $migrationKey = true');
      }

      // ✅ ADDED: Track migration success in production
      final migratedCount = results.values.where((v) => v).length;
      await FirebaseCrashlytics.instance.log(
        '✅ Hive encryption migration: $migratedCount/${results.length} boxes migrated',
      );
    } else {
      if (kDebugMode) {
        debugPrint(
          '🔐 [Security] Encryption already applied (skipping migration)',
        );
      }
    }
  } catch (e, stackTrace) {
    // CRITICAL: Log migration errors but DON'T crash the app
    // Users can still use the app even if migration fails (boxes will remain unencrypted)
    if (kDebugMode) {
      debugPrint('❌ [Security] Hive encryption migration failed: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      debugPrint(
        '⚠️ App will continue with unencrypted boxes (user data at risk!)',
      );
    }

    // ✅ ADDED: Track migration failures in production
    await FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      reason: 'Hive encryption migration failed',
      fatal: false,
    );
  }

  // ========================================
  // NOW Hive is ready: Initialize services that depend on it
  // ========================================

  // 🔐 SECURITY: Initialize Firebase App Check BEFORE any Firebase operations
  // This prevents API abuse from scraped/stolen API keys
  final appCheckReady = await AppCheckConfig.initialize();
  if (!appCheckReady && !kDebugMode) {
    throw StateError(
      'Critical security initialization failed: Firebase App Check is required in production.',
    );
  }

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

  // 🤖 AI COACH: Initialize Document Local DataSource for offline caching
  // This ensures Hive boxes for scientific papers are opened before sync
  // ✅ NOW SAFE: Hive is initialized and adapter registered
  final documentLocalDataSource = DocumentLocalDataSource();
  await documentLocalDataSource.initialize();

  if (kDebugMode) {
    debugPrint('🤖 AI Coach: Document cache initialized');
  }

  // Enable Firestore offline persistence for better performance and offline support
  // This allows the app to work offline and reduces Firebase read costs by 50-70%
  // FIX: Limit cache to 100MB to prevent unbounded memory growth causing iOS jettison
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 100 * 1024 * 1024, // 100MB (was CACHE_SIZE_UNLIMITED)
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
    unawaited(
      MobileAds.instance.updateRequestConfiguration(requestConfiguration),
    );
    debugPrint(
      '📱 AdMob test device configured: 847b72988c2f5c8ba2c308cf222ace2c',
    );
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
  // 📊 EXERCISE POPULARITY RANKING: Initialize cache and sync bundle
  // ========================================
  // Background sync of popularity data for search ranking boost
  // Fire-and-forget: app works without it (graceful degradation)
  await _initPopularitySystem();

  // ========================================
  // 🔧 CRITICAL FIX: Pre-load AppConfig from Hive BEFORE app starts
  // ========================================
  // This prevents the router from seeing initialOnboardingCompleted=false
  // before Hive has finished loading the actual config.
  // Without this, users who completed onboarding would see it again.
  await _preloadAppConfig();

  // 🚀 SPLASH: Remove splash screen now that initialization is complete
  FlutterNativeSplash.remove();

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
      // App lifecycle manager handles background/foreground transitions
      child: const AppLifecycleManager(child: FitLogApp()),
    ),
  );
}

// ========================================
// 🔔 DEEP LINKING: Implemented via notification payload parsing
// ========================================
// Cold-start: initialDeepLink parsed above → passed to GoRouter initialLocation
// Warm-start: pendingNotificationDeepLinkProvider in notification_provider.dart

/// Initialize all storage systems
Future<void> _initializeStorage() async {
  // ⚡ PERFORMANCE OPTIMIZATION: Open basic boxes in parallel
  // This reduces app startup time by ~30-40% (from ~19s to ~12s)

  // 🔐 SECURITY: Use SecureLogger (debug-only, no production logs)
  SecureLogger.debug('Starting storage initialization');

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

  // 🔐 SECURITY: Use SecureLogger (debug-only, no production logs)
  SecureLogger.debug('Basic boxes opened successfully');

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

    // 🔄 Template Cloud Sync Service with exponential backoff retry logic
    // Enables automatic retry of failed Cloud Function calls: 3s, 6s, 12s, 24s, 48s
    _safeInitialize(
      'TemplateCloudSyncService',
      () => TemplateCloudSyncService.initialize(),
    ),

    // Removed: ExerciseFuzzyMatcher - overengineered, simple token matching is sufficient
  ]);

  // NOTE: Notification services initialized in app.dart via notificationInitProvider
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
    // 🔐 SECURITY: Use SecureLogger (debug-only, no production logs)
    SecureLogger.debug('Opening box', data: {'boxName': boxName});
    await boxManager.openBox<T>(boxName);
    SecureLogger.debug('Box opened successfully', data: {'boxName': boxName});
  } catch (e, stackTrace) {
    // 🔐 SECURITY: Use SecureLogger with structured error data
    SecureLogger.error(
      'Failed to open box',
      error: e,
      stackTrace: stackTrace,
      data: {'boxName': boxName},
    );

    // Handle corrupted boxes that need recovery
    if ((boxName == 'app_config' && e.toString().contains('typeId')) ||
        (boxName == 'onboarding_state' &&
            e.toString().contains('already open and of type Box<dynamic>'))) {
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

/// Pre-load AppConfig from Hive to populate the static cache
/// This ensures the router sees the correct initialOnboardingCompleted value
/// BEFORE making redirect decisions.
Future<void> _preloadAppConfig() async {
  try {
    final boxManager = HiveBoxManagerEnhanced();
    final configBox = await boxManager.openBox<AppConfig>('app_config');
    final savedConfig = configBox.get('config');

    if (savedConfig != null) {
      // Pre-populate the static cache in AppConfigNotifier
      AppConfigNotifier.preloadCache(savedConfig);
      if (kDebugMode) {
        debugPrint(
          '✅ [main] Pre-loaded AppConfig (initialOnboardingCompleted: ${savedConfig.initialOnboardingCompleted})',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint('ℹ️ [main] No saved AppConfig found (new user)');
      }
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('⚠️ [main] Failed to pre-load AppConfig: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
    // Continue - AppConfigNotifier will handle initialization
  }
}

/// Initialize exercise popularity ranking system
///
/// Steps:
/// 1. Open Hive cache box
/// 2. Background sync bundle from Storage (fire-and-forget)
///
/// Graceful degradation: App works without this
/// (search just won't have popularity boost)
Future<void> _initPopularitySystem() async {
  try {
    if (kDebugMode) {
      debugPrint('📊 Initializing exercise popularity system...');
    }

    // 1. Initialize cache (opens Hive box)
    final cache = ExercisePopularityCache();
    await cache.init();

    if (kDebugMode) {
      debugPrint('✅ Exercise popularity cache initialized');
    }

    // 2. Sync bundle in background (non-blocking)
    final service = ExercisePopularityBundleService(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      cache: cache,
    );

    // Fire-and-forget: don't block app startup
    unawaited(service.syncPopularityData());

    if (kDebugMode) {
      debugPrint('✅ Exercise popularity bundle sync started (background)');
    }
  } catch (e, stackTrace) {
    // Graceful degradation: log error but don't throw
    if (kDebugMode) {
      debugPrint('⚠️ Exercise popularity system init failed: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      debugPrint('ℹ️ App will continue without popularity boost');
    }
  }
}
