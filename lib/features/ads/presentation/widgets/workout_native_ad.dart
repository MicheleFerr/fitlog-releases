/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/widgets
 * 🎯 Feature: ads
 * 🔧 Type: widget (native ad for workout lists)
 * 🌍 Localization: ❌ Not required (ad widget)
 * 🎨 Theme: ✅ Matches workout card design
 * 📱 Platform: Universal
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../domain/entities/ad_config.dart';
import '../../data/repositories/google_ad_repository.dart';
import '../providers/ad_manager_provider.dart';

class WorkoutNativeAd extends ConsumerStatefulWidget {
  final String adUnitId;
  final AdPlacement placement;
  final EdgeInsets margin;
  final String templateId;

  const WorkoutNativeAd({
    super.key,
    required this.adUnitId,
    required this.placement,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.templateId = 'medium',
  });

  @override
  ConsumerState<WorkoutNativeAd> createState() => _WorkoutNativeAdState();
}

class _WorkoutNativeAdState extends ConsumerState<WorkoutNativeAd> {
  NativeAd? _nativeAd;
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
    
    if (!adsEnabled) return;

    setState(() {
      _isLoading = true;
    });

    final success = await adManager.loadNativeAd(
      adUnitId: widget.adUnitId,
      placement: widget.placement,
      templateId: widget.templateId,
    );

    if (success && mounted) {
      // Get the loaded ad from repository
      final repository = ref.read(adRepositoryProvider) as GoogleAdRepository;
      _nativeAd = repository.getNativeAd(widget.adUnitId);
      
      setState(() {
        _isLoaded = _nativeAd != null;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsEnabled = ref.watch(adsEnabledProvider);
    
    if (!adsEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      child: _buildAdContent(context),
    );
  }

  Widget _buildAdContent(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard(context);
    }

    if (_isLoaded && _nativeAd != null) {
      return _buildNativeAdCard(context);
    }

    // Don't show anything if ad failed to load
    return const SizedBox.shrink();
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Simulated workout icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ad',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNativeAdCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Container(
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            // Native ad content
            SizedBox.expand(
              child: AdWidget(ad: _nativeAd!),
            ),
            // Ad indicator overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ad',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Native ad specifically for workout template lists
class WorkoutTemplateNativeAd extends ConsumerWidget {
  final int index;

  const WorkoutTemplateNativeAd({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkoutNativeAd(
      adUnitId: 'template_native_$index',
      placement: AdPlacement.templateListBetween,
      templateId: 'medium',
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
    );
  }
}

/// Native ad for exercise search results
class ExerciseSearchNativeAd extends ConsumerWidget {
  const ExerciseSearchNativeAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkoutNativeAd(
      adUnitId: 'exercise_search_native',
      placement: AdPlacement.exerciseSearchBottom,
      templateId: 'small',
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    );
  }
}

/// Upgrade prompt card that mimics native ad style but promotes premium
class UpgradePromptCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const UpgradePromptCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Premium icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Upgrade to SYNC Pro',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Remove ads, unlimited templates, and more!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Starting €0.99',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}