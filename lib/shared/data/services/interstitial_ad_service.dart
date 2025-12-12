import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';

/// Interstitial Ad Service
///
/// Gestisce il caricamento e la visualizzazione degli interstitial ads
/// con frequency capping (max 1 ad ogni N minuti).
///
/// Features:
/// - Pre-loading intelligente
/// - Frequency capping
/// - Retry logic
/// - Callback per eventi
class InterstitialAdService {

  factory InterstitialAdService() => _instance;

  InterstitialAdService._internal();
  static final InterstitialAdService _instance =
      InterstitialAdService._internal();

  // ============================================================================
  // STATE
  // ============================================================================

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  DateTime? _lastAdShownTime;

  // Frequency capping: mostra max 1 ad ogni 3 minuti
  static const Duration _minTimeBetweenAds = Duration(minutes: 3);

  // SharedPreferences key
  static const String _lastAdTimestampKey = 'last_interstitial_ad_timestamp';

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Pre-load ad for workout complete screen
  Future<void> preloadWorkoutCompleteAd() async {
    if (_isAdReady) {
      if (kDebugMode) {
        debugPrint('✅ Interstitial ad already loaded');
      }
      return;
    }

    await _loadAd(AdMobConfig.interstitialWorkoutComplete);
  }

  /// Pre-load ad for navigation
  Future<void> preloadNavigationAd() async {
    if (_isAdReady) {
      if (kDebugMode) {
        debugPrint('✅ Interstitial ad already loaded');
      }
      return;
    }

    await _loadAd(AdMobConfig.interstitialNavigation);
  }

  /// Show interstitial ad (if ready and not in cooldown)
  ///
  /// Returns true if ad was shown, false otherwise
  Future<bool> showAdIfReady({
    VoidCallback? onAdClosed,
  }) async {
    // Check if enough time has passed since last ad
    if (!await _canShowAd()) {
      if (kDebugMode) {
        debugPrint('⏳ Interstitial ad in cooldown period');
      }
      return false;
    }

    if (!_isAdReady || _interstitialAd == null) {
      if (kDebugMode) {
        debugPrint('❌ Interstitial ad not ready');
      }
      return false;
    }

    // Set full screen content callback
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) {
          debugPrint('📱 Interstitial ad showed full screen content');
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) {
          debugPrint('📱 Interstitial ad dismissed');
        }
        ad.dispose();
        _isAdReady = false;
        _interstitialAd = null;

        // Update last shown time
        _updateLastAdShownTime();

        // Callback
        onAdClosed?.call();

        // Pre-load next ad
        preloadWorkoutCompleteAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          debugPrint('❌ Interstitial ad failed to show: $error');
        }
        ad.dispose();
        _isAdReady = false;
        _interstitialAd = null;

        // Callback
        onAdClosed?.call();
      },
    );

    await _interstitialAd!.show();
    return true;
  }

  /// Dispose current ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
  }

  /// Check if ad is ready to show
  bool get isAdReady => _isAdReady;

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  Future<void> _loadAd(String adUnitId) async {
    if (kDebugMode) {
      debugPrint('📥 Loading interstitial ad: $adUnitId');
    }

    // Check if we have consent to show ads
    final consentService = ConsentService();
    final canRequest = await consentService.canRequestAds();

    if (!canRequest) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot request ads - consent not granted');
      }
      return;
    }

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            debugPrint('✅ Interstitial ad loaded successfully');
          }
          _interstitialAd = ad;
          _isAdReady = true;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('❌ Interstitial ad failed to load: $error');
          }
          _isAdReady = false;
          _interstitialAd = null;

          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadAd(adUnitId);
          });
        },
      ),
    );
  }

  Future<bool> _canShowAd() async {
    // Load last ad timestamp from storage
    final prefs = await SharedPreferences.getInstance();
    final lastTimestamp = prefs.getInt(_lastAdTimestampKey);

    if (lastTimestamp == null) {
      return true; // Never shown an ad before
    }

    _lastAdShownTime = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
    final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);

    return timeSinceLastAd >= _minTimeBetweenAds;
  }

  Future<void> _updateLastAdShownTime() async {
    _lastAdShownTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastAdTimestampKey,
      _lastAdShownTime!.millisecondsSinceEpoch,
    );
  }

  /// Force reset cooldown (for testing)
  Future<void> resetCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAdTimestampKey);
    _lastAdShownTime = null;
    if (kDebugMode) {
      debugPrint('🔄 Interstitial ad cooldown reset');
    }
  }
}
