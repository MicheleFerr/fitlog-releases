/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/widgets
 * 🎯 Feature: ads
 * 🔧 Type: helper (interstitial ad management)
 * 🌍 Localization: ❌ Not required
 * 🎨 Theme: ❌ Not applicable
 * 📱 Platform: Universal
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ad_config.dart';
import '../providers/ad_manager_provider.dart';

/// Helper class for managing interstitial ads at strategic moments
class InterstitialAdHelper {
  static const String _workoutCompleteAdId = 'workout_complete_interstitial';
  static const String _templateSaveAdId = 'template_save_interstitial';
  static const String _analyticsViewAdId = 'analytics_view_interstitial';
  static const String _exerciseSearchAdId = 'exercise_search_interstitial';

  /// Show ad after workout completion (natural break)
  static Future<bool> showWorkoutCompleteAd(WidgetRef ref) async {
    return _showInterstitialWithChecks(
      ref,
      adUnitId: _workoutCompleteAdId,
      placement: AdPlacement.workoutComplete,
      context: 'workout_complete',
    );
  }

  /// Show ad when saving a workout template (natural break)
  static Future<bool> showTemplateSaveAd(WidgetRef ref) async {
    return _showInterstitialWithChecks(
      ref,
      adUnitId: _templateSaveAdId,
      placement: AdPlacement.templateListBetween,
      context: 'template_save',
    );
  }

  /// Show ad when opening analytics for extended viewing (natural transition)
  static Future<bool> showAnalyticsViewAd(WidgetRef ref) async {
    return _showInterstitialWithChecks(
      ref,
      adUnitId: _analyticsViewAdId,
      placement: AdPlacement.analyticsScreenTop,
      context: 'analytics_view',
    );
  }

  /// Show ad during exercise search after user selects an exercise (natural break)
  static Future<bool> showExerciseSelectionAd(WidgetRef ref) async {
    return _showInterstitialWithChecks(
      ref,
      adUnitId: _exerciseSearchAdId,
      placement: AdPlacement.exerciseSearchBottom,
      context: 'exercise_selection',
    );
  }

  /// Internal method to show interstitial with all checks
  static Future<bool> _showInterstitialWithChecks(
    WidgetRef ref, {
    required String adUnitId,
    required AdPlacement placement,
    required String context,
  }) async {
    try {
      // Check if ads are enabled
      final adsEnabled = ref.read(adsEnabledProvider);
      if (!adsEnabled) {
        debugPrint('🚫 Interstitial blocked: ads disabled');
        return false;
      }

      // Check if we can show this specific ad
      final canShow = ref.read(canShowInterstitialProvider(adUnitId));
      if (!canShow) {
        debugPrint('🚫 Interstitial blocked: timing/limit rules for $context');
        return false;
      }

      // Get ad manager
      final adManager = ref.read(adManagerProvider.notifier);

      // Ensure ad is loaded (load if not already loaded)
      await _ensureAdLoaded(adManager, adUnitId, placement);

      // Show the ad
      final shown = await adManager.showInterstitialAd(
        adUnitId: adUnitId,
        placement: placement,
      );

      if (shown) {
        debugPrint('✅ Interstitial shown successfully: $context');
      } else {
        debugPrint('❌ Interstitial show failed: $context');
      }

      return shown;
    } catch (e) {
      debugPrint('❌ Interstitial error for $context: $e');
      return false;
    }
  }

  /// Ensure ad is loaded before trying to show
  static Future<void> _ensureAdLoaded(
    AdManagerNotifier adManager,
    String adUnitId,
    AdPlacement placement,
  ) async {
    // Check if ad is already loaded
    // If not, load it (this might cause a delay but ensures we have an ad)
    await adManager.loadInterstitialAd(
      adUnitId: adUnitId,
      placement: placement,
    );
  }

  /// Preload all interstitial ads at app start
  static Future<void> preloadInterstitialAds(WidgetRef ref) async {
    final adManager = ref.read(adManagerProvider.notifier);
    final adsEnabled = ref.read(adsEnabledProvider);
    
    if (!adsEnabled) return;

    debugPrint('🔄 Preloading interstitial ads...');

    // Preload workout complete ad (most important)
    await adManager.loadInterstitialAd(
      adUnitId: _workoutCompleteAdId,
      placement: AdPlacement.workoutComplete,
    );

    // Preload template save ad
    await adManager.loadInterstitialAd(
      adUnitId: _templateSaveAdId,
      placement: AdPlacement.templateListBetween,
    );

    // Preload analytics view ad
    await adManager.loadInterstitialAd(
      adUnitId: _analyticsViewAdId,
      placement: AdPlacement.analyticsScreenTop,
    );

    // Preload exercise search ad
    await adManager.loadInterstitialAd(
      adUnitId: _exerciseSearchAdId,
      placement: AdPlacement.exerciseSearchBottom,
    );

    debugPrint('✅ Interstitial ads preloaded');
  }
}

/// Strategic interstitial ad triggers for different user flows
class AdTriggerStrategy {
  /// Determine if we should show an ad based on user behavior
  static bool shouldTriggerAdForWorkoutComplete({
    required int workoutDuration,
    required int exerciseCount,
    required bool isFirstWorkoutToday,
  }) {
    // Show ad for substantial workouts (prevents spam for quick tests)
    if (workoutDuration < 300) return false; // Less than 5 minutes
    if (exerciseCount < 3) return false; // Less than 3 exercises
    
    // More likely to show for first workout of the day
    if (isFirstWorkoutToday) return true;
    
    // Standard trigger for good workouts
    return workoutDuration >= 600; // 10+ minute workouts
  }

  /// Determine if we should show an ad for template operations
  static bool shouldTriggerAdForTemplateSave({
    required bool isCustomTemplate,
    required int exerciseCount,
  }) {
    // Show ad for user-created templates (they invested effort)
    if (isCustomTemplate && exerciseCount >= 4) return true;
    
    // Don't show for simple templates
    return false;
  }

  /// Determine if we should show an ad for analytics viewing
  static bool shouldTriggerAdForAnalytics({
    required bool isExtendedSession,
    required int previousAnalyticsViews,
  }) {
    // Show ad for users who spend time in analytics (engaged users)
    if (isExtendedSession && previousAnalyticsViews <= 2) return true;
    
    return false;
  }

  /// Determine if we should show an ad during exercise selection
  static bool shouldTriggerAdForExerciseSelection({
    required int exercisesAddedToday,
    required bool isLongSearchSession,
  }) {
    // Show ad after user has added several exercises (active session)
    if (exercisesAddedToday >= 5 && isLongSearchSession) return true;
    
    return false;
  }
}

/// Ad frequency manager to prevent ad fatigue
class AdFrequencyManager {
  static const int _maxAdsPerHour = 3;
  static const int _maxAdsPerDay = 15;
  static const Duration _minTimeBetweenSameAdType = Duration(minutes: 10);

  static final Map<String, DateTime> _lastAdShown = {};
  static final Map<String, int> _adsShownToday = {};

  /// Check if we can show an ad based on frequency rules
  static bool canShowAdType(String adType) {
    final now = DateTime.now();
    
    // Check minimum time between same ad type
    final lastShown = _lastAdShown[adType];
    if (lastShown != null) {
      final timeSinceLastShown = now.difference(lastShown);
      if (timeSinceLastShown < _minTimeBetweenSameAdType) {
        debugPrint('🚫 Ad blocked: too soon since last $adType ad');
        return false;
      }
    }

    // Check daily limits
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final adsToday = _adsShownToday[todayKey] ?? 0;
    if (adsToday >= _maxAdsPerDay) {
      debugPrint('🚫 Ad blocked: daily limit reached');
      return false;
    }

    // Check hourly limits
    final hourKey = '${todayKey}-${now.hour}';
    final adsThisHour = _adsShownToday[hourKey] ?? 0;
    if (adsThisHour >= _maxAdsPerHour) {
      debugPrint('🚫 Ad blocked: hourly limit reached');
      return false;
    }

    return true;
  }

  /// Record that an ad was shown
  static void recordAdShown(String adType) {
    final now = DateTime.now();
    _lastAdShown[adType] = now;
    
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final hourKey = '${todayKey}-${now.hour}';
    
    _adsShownToday[todayKey] = (_adsShownToday[todayKey] ?? 0) + 1;
    _adsShownToday[hourKey] = (_adsShownToday[hourKey] ?? 0) + 1;
    
    debugPrint('📊 Ad frequency: $adType shown (daily: ${_adsShownToday[todayKey]}, hourly: ${_adsShownToday[hourKey]})');
  }

  /// Reset daily counters (call at midnight)
  static void resetDailyCounters() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    
    // Remove old day entries
    _adsShownToday.removeWhere((key, value) => !key.startsWith(todayKey));
  }
}