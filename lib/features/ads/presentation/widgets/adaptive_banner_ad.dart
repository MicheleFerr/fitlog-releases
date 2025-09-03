/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/widgets
 * 🎯 Feature: ads
 * 🔧 Type: widget (banner ad)
 * 🌍 Localization: ❌ Not required (ad widget)
 * 🎨 Theme: ✅ Respects theme colors
 * 📱 Platform: Universal
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // DISABLED: AdMob not configured
import '../../domain/entities/ad_config.dart';
import '../../data/repositories/google_ad_repository.dart';
import '../providers/ad_manager_provider.dart';

// TEMPORARILY DISABLED: AdMob needs configuration
// This widget will be re-enabled once AdMob is properly configured with an App ID

class AdaptiveBannerAd extends ConsumerStatefulWidget {
  final String adUnitId;
  final AdPlacement placement;
  final BannerAdSize size;
  final EdgeInsets margin;
  final bool showLoadingIndicator;

  const AdaptiveBannerAd({
    super.key,
    required this.adUnitId,
    required this.placement,
    this.size = BannerAdSize.standard,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.showLoadingIndicator = true,
  });

  @override
  ConsumerState<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends ConsumerState<AdaptiveBannerAd> {
  @override
  Widget build(BuildContext context) {
    // Return empty container until AdMob is configured
    return const SizedBox.shrink();
  }
}

/* ORIGINAL CODE - TO BE RESTORED WHEN ADMOB IS CONFIGURED

class _AdaptiveBannerAdState extends ConsumerState<AdaptiveBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final adManager = ref.read(adManagerProvider.notifier);
    final adsEnabled = ref.read(adsEnabledProvider);
    
    if (!adsEnabled || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    final success = await adManager.loadBannerAd(
      adUnitId: widget.adUnitId,
      placement: widget.placement,
      size: widget.size,
    );

    if (mounted) {
      setState(() {
        _isLoaded = success;
        _isLoading = false;
      });
      
      if (success) {
        // Get the loaded banner ad from repository
        final repository = ref.read(adRepositoryProvider) as GoogleAdRepository;
        _bannerAd = repository.getBannerAd(widget.adUnitId);
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ads enabled state
    final adsEnabled = ref.watch(adsEnabledProvider);
    
    if (!adsEnabled) {
      return const SizedBox.shrink();
    }

    // Watch ad state for this specific ad
    final adState = ref.watch(adStateProvider(widget.adUnitId));
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: widget.margin,
      height: _isLoaded ? _getAdHeight() : 0,
      child: _buildAdContent(adState),
    );
  }

  Widget _buildAdContent(AdState adState) {
    if (adState.isLoading && widget.showLoadingIndicator) {
      return _buildLoadingIndicator();
    }

    if (adState.hasError) {
      return _buildErrorPlaceholder();
    }

    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return _buildAdWidget();
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: _getAdHeight(),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    // In production, return empty space instead of error message
    return const SizedBox.shrink();
  }

  Widget _buildAdWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  double _getAdHeight() {
    switch (widget.size) {
      case BannerAdSize.standard:
        return 50.0;
      case BannerAdSize.large:
        return 90.0;
      case BannerAdSize.mediumRectangle:
        return 250.0;
      case BannerAdSize.adaptiveBanner:
        return 60.0; // Will be adjusted dynamically
    }
  }
}

*/