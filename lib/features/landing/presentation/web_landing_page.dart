/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/landing/presentation
/// Feature: Web Landing Page
/// Type: Screen
///
/// Landing page for web users, especially mobile web visitors.
/// Provides app download links and feature highlights.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gymbro_flutter_new/shared/domain/services/device_detection_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Web landing page with app download CTAs
///
/// This page is:
/// - The only page accessible to mobile web users
/// - Shown to desktop web users as an option
/// - Contains deep links to native apps
class WebLandingPage extends ConsumerWidget {
  const WebLandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceService = DeviceDetectionService();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = kIsWeb && deviceService.isMobileWeb(screenWidth);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      AppIcons.workout,
                      size: 64,
                      color: context.colors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  Text(
                    'FitLog Pro',
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Tagline
                  Text(
                    context.l10n.appTagline,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Mobile-specific message
                  if (isMobile) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            AppIcons.smartphone,
                            size: 48,
                            color: context.colors.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            context.l10n.webMobileMessage,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            context.l10n.webMobileSubtitle,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Download buttons
                  _buildDownloadButtons(context),

                  const SizedBox(height: AppSpacing.xxl),

                  // Features list
                  _buildFeaturesList(context),

                  const SizedBox(height: AppSpacing.xxl),

                  // Desktop hint
                  if (!isMobile && kIsWeb)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Navigate to web app when ready
                      },
                      icon: const Icon(AppIcons.desktop),
                      label: Text(context.l10n.continueOnDesktop),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButtons(BuildContext context) {
    return Column(
      children: [
        // iOS App Store
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _launchStore(context, isIOS: true),
            icon: const Icon(AppIcons.apple),
            label: Text(context.l10n.downloadOnAppStore),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Google Play Store
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _launchStore(context, isIOS: false),
            icon: const Icon(AppIcons.android),
            label: Text(context.l10n.getItOnGooglePlay),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      (AppIcons.workout, context.l10n.featureTrackWorkouts),
      (AppIcons.analytics, context.l10n.featureAnalytics),
      (AppIcons.timer, context.l10n.featureRestTimer),
      (AppIcons.cloud, context.l10n.featureCloudSync),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.whyFitLog,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Icon(feature.$1, size: 24, color: context.colors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(feature.$2, style: context.textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchStore(BuildContext context, {required bool isIOS}) async {
    final url = isIOS
        ? 'https://apps.apple.com/app/fitlog-pro/id123456789' // TODO: Real App Store ID
        : 'https://play.google.com/store/apps/details?id=com.gymbro.fitlog';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
