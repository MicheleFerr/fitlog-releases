/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/providers
 * 🎯 Feature: ads
 * 🔧 Type: provider (ad management)
 * 📱 Platform: Universal
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ad_config.dart';
import '../../domain/entities/ad_state.dart';
import '../../domain/repositories/ad_repository.dart';
import '../../data/repositories/google_ad_repository.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';

/// Ad repository provider
final adRepositoryProvider = Provider<AdRepository>((ref) {
  return GoogleAdRepository(ref);
});

/// Ad manager state notifier
class AdManagerNotifier extends StateNotifier<AdManagerState> {
  final AdRepository _adRepository;
  final Ref _ref;

  AdManagerNotifier(this._adRepository, this._ref) 
      : super(AdManagerState(sessionStartTime: DateTime.now())) {
    // TODO: Uncomment when AdMob is configured with valid app ID
    // _initialize();
  }

  /// Initialize ad manager
  Future<void> _initialize() async {
    try {
      debugPrint('🔄 Initializing AdMob...');
      
      // Check if ads should be enabled
      final shouldShow = await _adRepository.shouldShowAds();
      if (!shouldShow) {
        debugPrint('🚫 Ads disabled (premium user or no consent)');
        state = state.copyWith(
          isInitialized: true,
          adsEnabled: false,
        );
        return;
      }

      // Initialize SDK
      final initialized = await _adRepository.initialize();
      
      // Check consent
      final hasConsent = await _adRepository.hasValidConsent();
      
      state = state.copyWith(
        isInitialized: initialized,
        adsEnabled: shouldShow,
        hasConsent: hasConsent,
        isTestMode: kDebugMode,
      );

      if (initialized && hasConsent) {
        debugPrint('✅ AdMob initialized successfully');
        await _preloadAds();
      } else {
        debugPrint('❌ AdMob initialization failed or consent missing');
      }
    } catch (e) {
      debugPrint('❌ AdMob initialization error: $e');
      state = state.copyWith(isInitialized: false);
    }
  }

  /// Preload essential ads
  Future<void> _preloadAds() async {
    if (!state.shouldShowAds) return;

    // Preload home screen banner
    await loadBannerAd(
      adUnitId: 'home_banner',
      placement: AdPlacement.homeScreenBottom,
    );

    // Preload workout completion interstitial
    await loadInterstitialAd(
      adUnitId: 'workout_complete',
      placement: AdPlacement.workoutComplete,
    );
  }

  /// Load banner ad
  Future<bool> loadBannerAd({
    required String adUnitId,
    required AdPlacement placement,
    BannerAdSize size = BannerAdSize.standard,
  }) async {
    if (!state.shouldShowAds) return false;

    try {
      _updateAdState(adUnitId, (current) => current.copyWith(isLoading: true));

      final config = AdUnitConfig.banner(
        id: adUnitId,
        isTestAd: state.isTestMode,
        size: size,
      );

      final success = await _adRepository.loadBannerAd(config);

      _updateAdState(adUnitId, (current) => current.copyWith(
        isLoading: false,
        isLoaded: success,
        error: success ? null : 'Failed to load banner ad',
      ));

      return success;
    } catch (e) {
      debugPrint('❌ Banner ad load error: $e');
      _updateAdState(adUnitId, (current) => current.copyWith(
        isLoading: false,
        isLoaded: false,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Load interstitial ad
  Future<bool> loadInterstitialAd({
    required String adUnitId,
    required AdPlacement placement,
  }) async {
    if (!state.shouldShowAds) return false;

    try {
      _updateAdState(adUnitId, (current) => current.copyWith(isLoading: true));

      final config = AdUnitConfig.interstitial(
        id: adUnitId,
        isTestAd: state.isTestMode,
      );

      final success = await _adRepository.loadInterstitialAd(config);

      _updateAdState(adUnitId, (current) => current.copyWith(
        isLoading: false,
        isLoaded: success,
        error: success ? null : 'Failed to load interstitial ad',
      ));

      return success;
    } catch (e) {
      debugPrint('❌ Interstitial ad load error: $e');
      _updateAdState(adUnitId, (current) => current.copyWith(
        isLoading: false,
        isLoaded: false,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Load native ad
  Future<bool> loadNativeAd({
    required String adUnitId,
    required AdPlacement placement,
    String templateId = 'medium',
  }) async {
    if (!state.shouldShowAds) return false;

    try {
      _updateAdState(adUnitId, (current) => current.copyWith(isLoading: true));

      final config = AdUnitConfig.native(
        id: adUnitId,
        isTestAd: state.isTestMode,
        templateId: templateId,
      );

      final success = await _adRepository.loadNativeAd(config);

      _updateAdState(adUnitId, (current) => current.copyWith(
        isLoading: false,
        isLoaded: success,
        error: success ? null : 'Failed to load native ad',
      ));

      return success;
    } catch (e) {
      debugPrint('❌ Native ad load error: $e');
      _updateAdState(adUnitId, (current) => current.copyWith(
        isLoading: false,
        isLoaded: false,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Show interstitial ad with timing checks
  Future<bool> showInterstitialAd({
    required String adUnitId,
    required AdPlacement placement,
  }) async {
    if (!state.shouldShowAds) return false;

    final adState = state.getAdState(adUnitId);
    
    // Check if we can show the ad based on timing rules
    final policy = AdDisplayPolicy.fitnessOptimized();
    if (!adState.canShowInterstitial(
      minInterval: policy.minTimeBetweenInterstitials,
      maxPerSession: policy.maxInterstitialsPerSession,
    )) {
      debugPrint('🚫 Interstitial ad blocked by timing rules');
      return false;
    }

    // Check session limits
    if (state.sessionInterstitialCount >= policy.maxInterstitialsPerSession) {
      debugPrint('🚫 Interstitial ad blocked by session limit');
      return false;
    }

    try {
      _updateAdState(adUnitId, (current) => current.copyWith(isShowing: true));

      final success = await _adRepository.showInterstitialAd(adUnitId);

      if (success) {
        // Update states after successful show
        _updateAdState(adUnitId, (current) => current.copyWith(
          isShowing: false,
          isLoaded: false, // Will be disposed by callback
          lastShown: DateTime.now(),
          impressionCount: current.impressionCount + 1,
        ));

        state = state.copyWith(
          sessionInterstitialCount: state.sessionInterstitialCount + 1,
        );
      } else {
        _updateAdState(adUnitId, (current) => current.copyWith(isShowing: false));
      }

      return success;
    } catch (e) {
      debugPrint('❌ Interstitial ad show error: $e');
      _updateAdState(adUnitId, (current) => current.copyWith(
        isShowing: false,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Check if ads are enabled for current user
  Future<void> refreshAdSettings() async {
    final shouldShow = await _adRepository.shouldShowAds();
    state = state.copyWith(adsEnabled: shouldShow);
    
    if (shouldShow && state.isInitialized) {
      await _preloadAds();
    }
  }

  /// Handle workout state changes (disable interstitials during active workout)
  void onWorkoutStateChanged({required bool isWorkoutActive}) {
    // This could disable certain ad types during workout
    debugPrint('🏋️ Workout state changed: active=$isWorkoutActive');
  }

  /// Update ad state helper
  void _updateAdState(String adUnitId, AdState Function(AdState) updater) {
    final currentState = state.getAdState(adUnitId);
    final newState = updater(currentState);
    
    final newAdStates = Map<String, AdState>.from(state.adStates);
    newAdStates[adUnitId] = newState;
    
    state = state.copyWith(adStates: newAdStates);
  }

  /// Dispose all ads
  Future<void> dispose() async {
    for (final adUnitId in state.adStates.keys) {
      await _adRepository.disposeAd(adUnitId);
    }
  }
}

/// Ad manager provider
final adManagerProvider = StateNotifierProvider<AdManagerNotifier, AdManagerState>((ref) {
  final repository = ref.read(adRepositoryProvider);
  return AdManagerNotifier(repository, ref);
});

/// Convenient providers for UI

/// Check if ads are enabled
final adsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(adManagerProvider.select((state) => state.shouldShowAds));
});

/// Get specific ad state
Provider<AdState> adStateProvider(String adUnitId) {
  return Provider<AdState>((ref) {
    return ref.watch(adManagerProvider.select((state) => state.getAdState(adUnitId)));
  });
}

/// Check if interstitial can be shown
Provider<bool> canShowInterstitialProvider(String adUnitId) {
  return Provider<bool>((ref) {
    final state = ref.watch(adManagerProvider);
    final adState = state.getAdState(adUnitId);
    final policy = AdDisplayPolicy.fitnessOptimized();
    
    return state.shouldShowAds && 
           adState.canShowInterstitial(
             minInterval: policy.minTimeBetweenInterstitials,
             maxPerSession: policy.maxInterstitialsPerSession,
           ) &&
           state.sessionInterstitialCount < policy.maxInterstitialsPerSession;
  });
}