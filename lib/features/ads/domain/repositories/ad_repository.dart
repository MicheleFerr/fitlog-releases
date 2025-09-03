/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain/repositories
 * 🎯 Feature: ads
 * 🔧 Type: repository interface
 * 📱 Platform: Universal
 */

import '../entities/ad_config.dart';

/// Abstract repository for ad management
abstract class AdRepository {
  /// Initialize AdMob SDK
  Future<bool> initialize();

  /// Load banner ad
  Future<bool> loadBannerAd(AdUnitConfig config);

  /// Load interstitial ad
  Future<bool> loadInterstitialAd(AdUnitConfig config);

  /// Load native ad
  Future<bool> loadNativeAd(AdUnitConfig config);

  /// Show interstitial ad
  Future<bool> showInterstitialAd(String adUnitId);

  /// Dispose ad
  Future<void> disposeAd(String adUnitId);

  /// Get consent status for GDPR
  Future<bool> hasValidConsent();

  /// Request consent for GDPR
  Future<bool> requestConsent();

  /// Check if ads should be shown (respects premium status)
  Future<bool> shouldShowAds();

  /// Track ad impression for analytics
  Future<void> trackAdImpression({
    required String adUnitId,
    required AdType adType,
    required AdPlacement placement,
  });

  /// Track ad click for analytics
  Future<void> trackAdClick({
    required String adUnitId,
    required AdType adType,
    required AdPlacement placement,
  });
}