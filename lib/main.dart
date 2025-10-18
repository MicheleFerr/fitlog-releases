import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gymbro_flutter_new/app/app.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
// 🔄 AppLifecycleManager per flush batch queue quando app va in background
import 'package:gymbro_flutter_new/shared/presentation/widgets/app_lifecycle_manager.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/theme_mode_adapter.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/fitness_profile_local_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/questionnaire_analytics_datasource.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';
import 'package:gymbro_flutter_new/shared/data/hive_timestamp_adapter.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/shared/data/models/weight_settings_model.dart';
import 'package:gymbro_flutter_new/shared/data/models/feedback_settings_model.dart';
import 'package:gymbro_flutter_new/shared/data/models/history_view_settings_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize Hive for local storage
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

  // Initialize secure storage boxes
  await _initializeStorage();

  runApp(
    const ProviderScope(
      child: AppLifecycleManager(
        child: FitLogApp(),
      ),
    ),
  );
}

/// Initialize all storage systems
Future<void> _initializeStorage() async {
  await _openBox('auth_box');
  await _openBox('timer_box');
  await _openBox('workout_box');
  await _openBox('settings_box');
  await _openBox<OnboardingState>('onboarding_state');
  await _openBox<AppConfig>('app_config');

  // 🔧 Open workoutMetrics box for analytics caching (as Map type)
  await _openBox<Map>('workoutMetrics');

  // Initialize workout-specific Hive storage
  try {
    await HiveWorkoutDataSource.initialize();
  } catch (e, stackTrace) {
    // Log only errors in debug mode
    assert(() {
      debugPrint('❌ Failed to initialize HiveWorkoutDataSource: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return true;
    }());
    // Continue execution even if workout storage fails
  }

  // Initialize fitness profile Hive storage
  try {
    await FitnessProfileLocalDataSource.initialize();
  } catch (e, stackTrace) {
    assert(() {
      debugPrint('❌ Failed to initialize FitnessProfileLocalDataSource: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return true;
    }());
  }

  // Initialize questionnaire analytics Hive storage
  try {
    await QuestionnaireAnalyticsDataSource.initialize();
  } catch (e, stackTrace) {
    assert(() {
      debugPrint('❌ Failed to initialize QuestionnaireAnalyticsDataSource: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return true;
    }());
  }

  // Initialize exercise usage tracker (ML-enhanced fuzzy search)
  try {
    await ExerciseUsageTracker().initialize();
  } catch (e, stackTrace) {
    assert(() {
      debugPrint('❌ Failed to initialize ExerciseUsageTracker: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return true;
    }());
  }

  // 🚀 PERFORMANCE: Initialize persistent fuzzy search isolate
  // This pre-creates the isolate once at app start, saving 200ms per search
  try {
    await ExerciseFuzzyMatcher.initialize();
    if (kDebugMode) {
      debugPrint('✅ Fuzzy search isolate initialized');
    }
  } catch (e, stackTrace) {
    assert(() {
      debugPrint('❌ Failed to initialize fuzzy search isolate: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return true;
    }());
  }
}

Future<void> _openBox<T>(String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
  } catch (e, stackTrace) {
    // Log errors only in debug mode
    assert(() {
      debugPrint('❌ Failed to open $boxName box: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return true;
    }());

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
        await Hive.openBox<T>(boxName);
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
