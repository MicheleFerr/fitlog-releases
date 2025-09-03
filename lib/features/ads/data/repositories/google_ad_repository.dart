/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data/repositories
 * 🎯 Feature: ads
 * 🔧 Type: repository implementation
 * 📱 Platform: Universal (iOS/Android)
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // DISABLED: AdMob not configured
import 'google_ad_stubs.dart'; // Temporary stub classes
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../domain/entities/ad_config.dart';
import '../../domain/repositories/ad_repository.dart';

class GoogleAdRepository implements AdRepository {
  final Ref _ref;
  final Map<String, BannerAd> _bannerAds = {};
  final Map<String, InterstitialAd> _interstitialAds = {};
  final Map<String, NativeAd> _nativeAds = {};

  GoogleAdRepository(this._ref);

  // Test ad unit IDs for development
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  // Production ad unit IDs (replace with your actual IDs)
  static const String _prodBannerAdUnitIdIOS = 'ca-app-pub-YOUR_APP_ID/banner_ios';
  static const String _prodInterstitialAdUnitIdIOS = 'ca-app-pub-YOUR_APP_ID/interstitial_ios';
  static const String _prodNativeAdUnitIdIOS = 'ca-app-pub-YOUR_APP_ID/native_ios';

  static const String _prodBannerAdUnitIdAndroid = 'ca-app-pub-YOUR_APP_ID/banner_android';
  static const String _prodInterstitialAdUnitIdAndroid = 'ca-app-pub-YOUR_APP_ID/interstitial_android';
  static const String _prodNativeAdUnitIdAndroid = 'ca-app-pub-YOUR_APP_ID/native_android';

  @override
  Future<bool> initialize() async {
    try {
      // TODO: Uncomment when AdMob is configured with valid app ID in Info.plist
      // Initialize Mobile Ads SDK
      // await MobileAds.instance.initialize();
      
      // Configure request settings
      // final requestConfiguration = RequestConfiguration(
      //   tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
      //   tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
      //   testDeviceIds: kDebugMode ? ['YOUR_TEST_DEVICE_ID'] : null,
      // );
      
      // await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      
      debugPrint('⚠️ AdMob SDK initialization disabled - no app ID configured');
      return false;
    } catch (e) {
      debugPrint('❌ AdMob initialization failed: $e');
      return false;
    }
  }

  @override
  Future<bool> loadBannerAd(AdUnitConfig config) async {
    try {
      final adUnitId = _getAdUnitId(config);
      
      // Dispose existing ad if any
      _bannerAds[config.id]?.dispose();
      
      final bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: _getBannerAdSize(config),
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ Banner ad loaded: ${config.id}');
            trackAdImpression(
              adUnitId: config.id,
              adType: AdType.banner,
              placement: _getPlacementFromId(config.id),
            );
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Banner ad failed to load: ${config.id}, error: $error');
            ad.dispose();
            _bannerAds.remove(config.id);
          },
          onAdClicked: (ad) {
            trackAdClick(
              adUnitId: config.id,
              adType: AdType.banner,
              placement: _getPlacementFromId(config.id),
            );
          },
        ),
      );

      await bannerAd.load();
      _bannerAds[config.id] = bannerAd;
      return true;
    } catch (e) {
      debugPrint('❌ Banner ad load error: $e');
      return false;
    }
  }

  @override
  Future<bool> loadInterstitialAd(AdUnitConfig config) async {
    try {
      final adUnitId = _getAdUnitId(config);
      
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Interstitial ad loaded: ${config.id}');
            _interstitialAds[config.id] = ad;
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint('📺 Interstitial ad showed: ${config.id}');
                trackAdImpression(
                  adUnitId: config.id,
                  adType: AdType.interstitial,
                  placement: _getPlacementFromId(config.id),
                );
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('❌ Interstitial ad dismissed: ${config.id}');
                ad.dispose();
                _interstitialAds.remove(config.id);
                // Preload next interstitial
                loadInterstitialAd(config);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('❌ Interstitial ad show failed: ${config.id}, error: $error');
                ad.dispose();
                _interstitialAds.remove(config.id);
              },
              onAdClicked: (ad) {
                trackAdClick(
                  adUnitId: config.id,
                  adType: AdType.interstitial,
                  placement: _getPlacementFromId(config.id),
                );
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ Interstitial ad failed to load: ${config.id}, error: $error');
          },
        ),
      );
      
      return true;
    } catch (e) {
      debugPrint('❌ Interstitial ad load error: $e');
      return false;
    }
  }

  @override
  Future<bool> loadNativeAd(AdUnitConfig config) async {
    try {
      final adUnitId = _getAdUnitId(config);
      
      // Dispose existing ad if any
      _nativeAds[config.id]?.dispose();
      
      final nativeAd = NativeAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        factoryId: config.config['templateId'] ?? 'medium',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ Native ad loaded: ${config.id}');
            trackAdImpression(
              adUnitId: config.id,
              adType: AdType.native,
              placement: _getPlacementFromId(config.id),
            );
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Native ad failed to load: ${config.id}, error: $error');
            ad.dispose();
            _nativeAds.remove(config.id);
          },
          onAdClicked: (ad) {
            trackAdClick(
              adUnitId: config.id,
              adType: AdType.native,
              placement: _getPlacementFromId(config.id),
            );
          },
        ),
      );

      await nativeAd.load();
      _nativeAds[config.id] = nativeAd;
      return true;
    } catch (e) {
      debugPrint('❌ Native ad load error: $e');
      return false;
    }
  }

  @override
  Future<bool> showInterstitialAd(String adUnitId) async {
    try {
      final ad = _interstitialAds[adUnitId];
      if (ad == null) {
        debugPrint('⚠️ No interstitial ad loaded for: $adUnitId');
        return false;
      }

      await ad.show();
      return true;
    } catch (e) {
      debugPrint('❌ Interstitial ad show error: $e');
      return false;
    }
  }

  @override
  Future<void> disposeAd(String adUnitId) async {
    _bannerAds[adUnitId]?.dispose();
    _bannerAds.remove(adUnitId);
    
    _interstitialAds[adUnitId]?.dispose();
    _interstitialAds.remove(adUnitId);
    
    _nativeAds[adUnitId]?.dispose();
    _nativeAds.remove(adUnitId);
  }

  @override
  Future<bool> hasValidConsent() async {
    // In production, integrate with Consent Management Platform (CMP)
    // For EU users, check GDPR consent
    if (kDebugMode) {
      return true; // Skip consent in debug mode
    }
    
    // TODO: Implement actual consent check
    // This would typically involve:
    // 1. Checking user's location (EU vs non-EU)
    // 2. Checking stored consent preferences
    // 3. Validating consent freshness
    
    return true;
  }

  @override
  Future<bool> requestConsent() async {
    // TODO: Implement consent request flow
    // This would show consent dialog for EU users
    return true;
  }

  @override
  Future<bool> shouldShowAds() async {
    try {
      // Check if user has premium subscription
      final userProfileAsync = _ref.read(userProfileProvider);
      final userProfile = userProfileAsync.value;
      
      if (userProfile?.isPremium == true) {
        debugPrint('🚫 Ads disabled for premium user');
        return false;
      }

      // Check GDPR consent
      final hasConsent = await hasValidConsent();
      if (!hasConsent) {
        debugPrint('🚫 Ads disabled due to missing consent');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error checking if ads should show: $e');
      return false;
    }
  }

  @override
  Future<void> trackAdImpression({
    required String adUnitId,
    required AdType adType,
    required AdPlacement placement,
  }) async {
    // TODO: Implement ad impression tracking
    // This could integrate with Firebase Analytics or custom analytics
    debugPrint('📊 Ad impression: $adType at $placement');
  }

  @override
  Future<void> trackAdClick({
    required String adUnitId,
    required AdType adType,
    required AdPlacement placement,
  }) async {
    // TODO: Implement ad click tracking
    debugPrint('🖱️ Ad click: $adType at $placement');
  }

  // Helper methods

  String _getAdUnitId(AdUnitConfig config) {
    if (config.isTestAd || kDebugMode) {
      switch (config.type) {
        case AdType.banner:
          return _testBannerAdUnitId;
        case AdType.interstitial:
          return _testInterstitialAdUnitId;
        case AdType.native:
          return _testNativeAdUnitId;
        case AdType.rewarded:
          return _testInterstitialAdUnitId; // Fallback
      }
    }

    // Production ad unit IDs
    if (Platform.isIOS) {
      switch (config.type) {
        case AdType.banner:
          return _prodBannerAdUnitIdIOS;
        case AdType.interstitial:
          return _prodInterstitialAdUnitIdIOS;
        case AdType.native:
          return _prodNativeAdUnitIdIOS;
        case AdType.rewarded:
          return _prodInterstitialAdUnitIdIOS; // Fallback
      }
    } else {
      switch (config.type) {
        case AdType.banner:
          return _prodBannerAdUnitIdAndroid;
        case AdType.interstitial:
          return _prodInterstitialAdUnitIdAndroid;
        case AdType.native:
          return _prodNativeAdUnitIdAndroid;
        case AdType.rewarded:
          return _prodInterstitialAdUnitIdAndroid; // Fallback
      }
    }
  }

  AdSize _getBannerAdSize(AdUnitConfig config) {
    final sizeConfig = config.config['size'] as BannerAdSize? ?? BannerAdSize.standard;
    
    switch (sizeConfig) {
      case BannerAdSize.standard:
        return AdSize.banner;
      case BannerAdSize.large:
        return AdSize.largeBanner;
      case BannerAdSize.mediumRectangle:
        return AdSize.mediumRectangle;
      case BannerAdSize.adaptiveBanner:
        // Use fullBanner as fallback for adaptive banner
        // In production, you would use AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width)
        // where width is the screen width obtained from MediaQuery
        return AdSize.fullBanner;
    }
  }

  AdPlacement _getPlacementFromId(String adUnitId) {
    // Map ad unit IDs to placements for analytics
    if (adUnitId.contains('home')) return AdPlacement.homeScreenBottom;
    if (adUnitId.contains('workout')) return AdPlacement.workoutListBetween;
    if (adUnitId.contains('analytics')) return AdPlacement.analyticsScreenTop;
    if (adUnitId.contains('exercise')) return AdPlacement.exerciseSearchBottom;
    if (adUnitId.contains('settings')) return AdPlacement.settingsBottom;
    if (adUnitId.contains('complete')) return AdPlacement.workoutComplete;
    return AdPlacement.homeScreenBottom; // Default
  }

  // Get banner ad widget
  BannerAd? getBannerAd(String adUnitId) {
    return _bannerAds[adUnitId];
  }

  // Get native ad widget
  NativeAd? getNativeAd(String adUnitId) {
    return _nativeAds[adUnitId];
  }
}