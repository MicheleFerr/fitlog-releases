import 'dart:io';
import 'package:flutter/foundation.dart';

/// AdMob Configuration
///
/// Contiene tutti gli Ad Unit IDs per iOS e Android.
/// In DEBUG mode usa Test IDs, in RELEASE usa Production IDs.
class AdMobConfig {
  // ============================================================================
  // APP IDs
  // ============================================================================

  static const String _iosAppIdProduction =
      'ca-app-pub-5716120224398761~6339854350';
  static const String _androidAppIdProduction =
      'ca-app-pub-5716120224398761~4072675862';

  // Test App IDs (reference only - not used in code, but kept for documentation)
  // ignore: unused_field
  static const String _iosAppIdTest = 'ca-app-pub-3940256099942544~1458002511';
  // ignore: unused_field
  static const String _androidAppIdTest =
      'ca-app-pub-3940256099942544~3347511713';

  // ============================================================================
  // BANNER AD UNITS
  // ============================================================================

  // iOS Production
  static const String _iosBannerAnalyticsProduction =
      'ca-app-pub-5716120224398761/6451427198';
  static const String _iosBannerHistoryProduction =
      'ca-app-pub-5716120224398761/1358990411';
  static const String _iosBannerSettingsProduction =
      'ca-app-pub-5716120224398761/8447142940';

  // Android Production
  static const String _androidBannerAnalyticsProduction =
      'ca-app-pub-5716120224398761/9568652925';
  static const String _androidBannerHistoryProduction =
      'ca-app-pub-5716120224398761/7732827078';
  static const String _androidBannerSettingsProduction =
      'ca-app-pub-5716120224398761/8346962798';

  // Test Banner ID (uguale per iOS e Android)
  static const String _bannerTest = 'ca-app-pub-3940256099942544/6300978111';

  // ============================================================================
  // INTERSTITIAL AD UNITS
  // ============================================================================

  // iOS Production
  static const String _iosInterstitialWorkoutCompleteProduction =
      'ca-app-pub-5716120224398761/5820979602';
  static const String _iosInterstitialNavigationProduction =
      'ca-app-pub-5716120224398761/9045908741';

  // Android Production
  static const String _androidInterstitialWorkoutCompleteProduction =
      'ca-app-pub-5716120224398761/5242395108';
  static const String _androidInterstitialNavigationProduction =
      'ca-app-pub-5716120224398761/8235405863';

  // Test Interstitial ID
  static const String _interstitialTest =
      'ca-app-pub-3940256099942544/1033173712';

  // ============================================================================
  // REWARDED AD UNITS
  // ============================================================================

  // iOS Production
  static const String _iosRewardedUnlockPremiumProduction =
      'ca-app-pub-5716120224398761/8011920871';

  // Android Production
  static const String _androidRewardedUnlockPremiumProduction =
      'ca-app-pub-5716120224398761/1199100511';

  // Test Rewarded ID
  static const String _rewardedTest = 'ca-app-pub-3940256099942544/5224354917';

  // ============================================================================
  // NATIVE AD UNITS
  // ============================================================================

  // iOS Production
  static const String _iosNativeWorkoutListProduction =
      'ca-app-pub-5716120224398761/4507897931';

  // Android Production
  static const String _androidNativeWorkoutListProduction =
      'ca-app-pub-5716120224398761/5609242523';

  // Test Native ID
  static const String _nativeTest = 'ca-app-pub-3940256099942544/2247696110';

  // ============================================================================
  // PUBLIC GETTERS - App ID
  // ============================================================================

  /// Returns the AdMob App ID based on platform and build mode
  static String get appId {
    if (kDebugMode) {
      // In debug, Google consiglia di usare i production IDs
      // ma caricheremo Test Ad Unit IDs
      return Platform.isIOS ? _iosAppIdProduction : _androidAppIdProduction;
    }
    return Platform.isIOS ? _iosAppIdProduction : _androidAppIdProduction;
  }

  // ============================================================================
  // PUBLIC GETTERS - Banner Ads
  // ============================================================================

  static String get bannerAnalytics {
    if (kDebugMode || _forceTestAds) return _bannerTest;
    return Platform.isIOS
        ? _iosBannerAnalyticsProduction
        : _androidBannerAnalyticsProduction;
  }

  static String get bannerHistory {
    if (kDebugMode || _forceTestAds) return _bannerTest;
    return Platform.isIOS
        ? _iosBannerHistoryProduction
        : _androidBannerHistoryProduction;
  }

  static String get bannerSettings {
    if (kDebugMode || _forceTestAds) return _bannerTest;
    return Platform.isIOS
        ? _iosBannerSettingsProduction
        : _androidBannerSettingsProduction;
  }

  // ============================================================================
  // PUBLIC GETTERS - Interstitial Ads
  // ============================================================================

  /// Force test ads outside debug builds with:
  /// --dart-define=FORCE_TEST_ADS=true
  static const bool _forceTestAds = bool.fromEnvironment('FORCE_TEST_ADS');

  static String get interstitialWorkoutComplete {
    if (kDebugMode || _forceTestAds) return _interstitialTest;
    return Platform.isIOS
        ? _iosInterstitialWorkoutCompleteProduction
        : _androidInterstitialWorkoutCompleteProduction;
  }

  static String get interstitialNavigation {
    if (kDebugMode || _forceTestAds) return _interstitialTest;
    return Platform.isIOS
        ? _iosInterstitialNavigationProduction
        : _androidInterstitialNavigationProduction;
  }

  // ============================================================================
  // PUBLIC GETTERS - Rewarded Ads
  // ============================================================================

  static String get rewardedUnlockPremium {
    if (kDebugMode || _forceTestAds) return _rewardedTest;
    return Platform.isIOS
        ? _iosRewardedUnlockPremiumProduction
        : _androidRewardedUnlockPremiumProduction;
  }

  // ============================================================================
  // PUBLIC GETTERS - Native Ads
  // ============================================================================

  static String get nativeWorkoutList {
    if (kDebugMode || _forceTestAds) return _nativeTest;
    return Platform.isIOS
        ? _iosNativeWorkoutListProduction
        : _androidNativeWorkoutListProduction;
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Returns true if we're using test ads
  static bool get isTestMode => kDebugMode || _forceTestAds;

  /// Print current configuration (for debugging)
  static void printConfig() {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 AdMob Configuration:');
      debugPrint('  Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
      debugPrint('  kDebugMode: $kDebugMode');
      debugPrint('  Force Test Ads: $_forceTestAds');
      debugPrint('  Mode: ${isTestMode ? 'TEST' : 'PRODUCTION'}');
      if (kDebugMode) {
        debugPrint('  App ID: $appId');
      }
      if (kDebugMode) {
        debugPrint('  Banner Analytics: $bannerAnalytics');
      }
      if (kDebugMode) {
        debugPrint('  Interstitial Workout: $interstitialWorkoutComplete');
      }
      if (kDebugMode) {
        debugPrint('  Rewarded Premium: $rewardedUnlockPremium');
      }
      if (kDebugMode) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    }
  }
}
