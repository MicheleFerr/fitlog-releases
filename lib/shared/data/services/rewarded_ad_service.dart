import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Rewarded Ad Service
///
/// Gestisce le rewarded ads per unlock temporaneo del premium.
///
/// Rewards:
/// - 24 ore senza ads
/// - Accesso temporaneo features premium
class RewardedAdService {

  factory RewardedAdService() => _instance;

  RewardedAdService._internal();
  static final RewardedAdService _instance = RewardedAdService._internal();

  // ============================================================================
  // STATE
  // ============================================================================

  RewardedAd? _rewardedAd;
  bool _isAdReady = false;

  // 🔐 User-scoped SharedPreferences keys
  String get _premiumUnlockTimestampKey =>
      userCacheKeys.userScopedKey('rewarded_premium_unlock_timestamp');
  String get _adsRemovedTimestampKey =>
      userCacheKeys.userScopedKey('rewarded_ads_removed_timestamp');

  // Reward duration
  static const Duration _rewardDuration = Duration(hours: 24);

  // ============================================================================
  // PUBLIC API - Loading
  // ============================================================================

  /// Pre-load rewarded ad
  Future<void> preloadRewardedAd() async {
    if (_isAdReady) {
      if (kDebugMode) {
        debugPrint('✅ Rewarded ad already loaded');
      }
      return;
    }

    await _loadAd();
  }

  /// Show rewarded ad
  ///
  /// Returns true if user watched full ad and earned reward
  Future<bool> showRewardedAd({
    required Function(int amount, String type) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) async {
    if (!_isAdReady || _rewardedAd == null) {
      if (kDebugMode) {
        debugPrint('❌ Rewarded ad not ready');
      }
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) {
          debugPrint('📱 Rewarded ad showed full screen content');
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) {
          debugPrint('📱 Rewarded ad dismissed');
        }
        ad.dispose();
        _isAdReady = false;
        _rewardedAd = null;

        // Callback
        onAdClosed?.call();

        // Pre-load next ad
        preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          debugPrint('❌ Rewarded ad failed to show: $error');
        }
        ad.dispose();
        _isAdReady = false;
        _rewardedAd = null;

        // Callback
        onAdClosed?.call();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (kDebugMode) {
          debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
        }
        rewardEarned = true;
        onUserEarnedReward(reward.amount.toInt(), reward.type);
      },
    );

    return rewardEarned;
  }

  /// Dispose current ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
  }

  /// Check if ad is ready to show
  bool get isAdReady => _isAdReady;

  // ============================================================================
  // PUBLIC API - Rewards Management
  // ============================================================================

  /// Unlock premium for 24 hours
  Future<void> unlockPremiumTemporarily() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _premiumUnlockTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    if (kDebugMode) {
      debugPrint('🎁 Premium unlocked for 24 hours');
    }
  }

  /// Remove ads for 24 hours
  Future<void> removeAdsTemporarily() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _adsRemovedTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    if (kDebugMode) {
      debugPrint('🎁 Ads removed for 24 hours');
    }
  }

  /// Check if premium is unlocked (via reward)
  Future<bool> isPremiumUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_premiumUnlockTimestampKey);

    if (timestamp == null) return false;

    final unlockTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final elapsed = DateTime.now().difference(unlockTime);

    return elapsed < _rewardDuration;
  }

  /// Check if ads are removed (via reward)
  Future<bool> areAdsRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_adsRemovedTimestampKey);

    if (timestamp == null) return false;

    final unlockTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final elapsed = DateTime.now().difference(unlockTime);

    return elapsed < _rewardDuration;
  }

  /// Get remaining time for premium unlock
  Future<Duration?> getPremiumRemainingTime() async {
    if (!await isPremiumUnlocked()) return null;

    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_premiumUnlockTimestampKey)!;
    final unlockTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expiryTime = unlockTime.add(_rewardDuration);

    return expiryTime.difference(DateTime.now());
  }

  /// Get remaining time for ads removal
  Future<Duration?> getAdsRemovalRemainingTime() async {
    if (!await areAdsRemoved()) return null;

    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_adsRemovedTimestampKey)!;
    final unlockTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expiryTime = unlockTime.add(_rewardDuration);

    return expiryTime.difference(DateTime.now());
  }

  /// Clear all rewards (for testing)
  Future<void> clearAllRewards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_premiumUnlockTimestampKey);
    await prefs.remove(_adsRemovedTimestampKey);
    if (kDebugMode) {
      debugPrint('🔄 All rewards cleared');
    }
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  Future<void> _loadAd() async {
    if (kDebugMode) {
      debugPrint('📥 Loading rewarded ad');
    }

    // Check if we have consent to show ads
    final consentService = ConsentService();
    final canRequest = await consentService.canRequestAds();

    if (!canRequest) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot request rewarded ads - consent not granted');
      }
      return;
    }

    await RewardedAd.load(
      adUnitId: AdMobConfig.rewardedUnlockPremium,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            debugPrint('✅ Rewarded ad loaded successfully');
          }
          _rewardedAd = ad;
          _isAdReady = true;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('❌ Rewarded ad failed to load: $error');
          }
          _isAdReady = false;
          _rewardedAd = null;

          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadAd();
          });
        },
      ),
    );
  }
}
