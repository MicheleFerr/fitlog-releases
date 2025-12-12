import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Adaptive Banner Ad Widget
///
/// Widget riutilizzabile per mostrare banner ads responsive.
/// Gestisce automaticamente:
/// - Caricamento
/// - Errori
/// - Dispose
/// - Sizing responsive
/// - Nasconde ads per utenti premium
///
/// Usage:
/// ```dart
/// AdaptiveBannerAd(
///   adUnitId: AdMobConfig.bannerAnalytics,
/// )
/// ```
class AdaptiveBannerAd extends ConsumerStatefulWidget { // Altezza custom (opzionale)

  const AdaptiveBannerAd({
    super.key,
    required this.adUnitId,
    this.height,
  });
  final String adUnitId;
  final double? height;

  @override
  ConsumerState<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends ConsumerState<AdaptiveBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    // Check if we have consent to show ads
    final consentService = ConsentService();
    final canRequest = await consentService.canRequestAds();

    if (!canRequest) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot request banner ads - consent not granted');
      }
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
      return;
    }

    // Get adaptive banner size
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      if (kDebugMode) {
        debugPrint('❌ Unable to get adaptive banner size');
      }
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            debugPrint('✅ Banner ad loaded: ${widget.adUnitId}');
          }
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isError = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint('❌ Banner ad failed to load: $error');
          }
          ad.dispose();
          if (mounted) {
            setState(() {
              _isError = true;
              _isLoaded = false;
            });
          }
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            debugPrint('📱 Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            debugPrint('📱 Banner ad closed');
          }
        },
      ),
    );

    await _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    // Hide ads for premium users (paid subscription)
    final isPremium = ref.watch(isPremiumUserProvider);
    if (isPremium) {
      return const SizedBox.shrink();
    }

    // Hide ads for Platinum tier users (earned through XP)
    final shouldShowAds = ref.watch(shouldShowAdsProvider);
    if (!shouldShowAds) {
      return const SizedBox.shrink();
    }

    // Show error placeholder
    if (_isError) {
      return const SizedBox.shrink();
    }

    // Show loading placeholder
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        height: widget.height ?? 50,
        color: Colors.transparent,
        child: const Center(
          child: LoadingIndicator(size: 20),
        ),
      );
    }

    // Show ad
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: widget.height ?? _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
