import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';

/// Adaptive Banner Ad Widget
///
/// Widget riutilizzabile per mostrare banner ads responsive.
/// Gestisce automaticamente:
/// - Caricamento
/// - Errori
/// - Dispose
/// - Sizing responsive
///
/// Usage:
/// ```dart
/// AdaptiveBannerAd(
///   adUnitId: AdMobConfig.bannerAnalytics,
/// )
/// ```
class AdaptiveBannerAd extends StatefulWidget { // Altezza custom (opzionale)

  const AdaptiveBannerAd({
    super.key,
    required this.adUnitId,
    this.height,
  });
  final String adUnitId;
  final double? height;

  @override
  State<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends State<AdaptiveBannerAd> {
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
      debugPrint('⚠️ Cannot request banner ads - consent not granted');
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
      debugPrint('❌ Unable to get adaptive banner size');
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
          debugPrint('✅ Banner ad loaded: ${widget.adUnitId}');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isError = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isError = true;
              _isLoaded = false;
            });
          }
        },
        onAdOpened: (ad) {
          debugPrint('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('📱 Banner ad closed');
        },
      ),
    );

    await _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
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
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
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
