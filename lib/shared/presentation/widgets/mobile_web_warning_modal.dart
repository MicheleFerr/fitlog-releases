/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: shared/presentation/widgets
/// Feature: Mobile Web Warning Modal
/// Type: Widget (Dialog)
///
/// Modal shown to mobile web users informing them the web version
/// is optimized for desktop, with deep links to native apps.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/domain/services/device_detection_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/device_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Modal dialog warning mobile web users
///
/// Shows:
/// - Message about desktop optimization
/// - Deep link button to open app (if installed)
/// - Store links
/// - Option to continue to landing page
class MobileWebWarningModal extends ConsumerWidget {
  const MobileWebWarningModal({super.key});

  /// Show the modal dialog
  static Future<void> show(BuildContext context) async {
    if (!kIsWeb) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MobileWebWarningModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceService = DeviceDetectionService();
    final mobileState = ref.watch(mobileWebProvider);
    final isIOS = deviceService.isIOSUserAgent(mobileState.userAgent);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.smartphone,
              size: 40,
              color: context.colors.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            context.l10n.mobileWebWarningTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            context.l10n.mobileWebWarningDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Primary CTA - Open App (deep link)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _tryOpenApp(context, deviceService),
              icon: const Icon(AppIcons.openExternal),
              label: Text(context.l10n.openInApp),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Download from store
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openStore(context, isIOS: isIOS),
              icon: Icon(isIOS ? AppIcons.apple : AppIcons.android),
              label: Text(
                isIOS
                    ? context.l10n.downloadOnAppStore
                    : context.l10n.getItOnGooglePlay,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Secondary - Continue to landing
          TextButton(
            onPressed: () {
              ref.read(mobileWebProvider.notifier).markWarningSeen();
              Navigator.of(context).pop();
              context.go(AppRoutes.webLandingPath);
            },
            child: Text(
              context.l10n.continueToWebsite,
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Try to open the app using deep link
  Future<void> _tryOpenApp(
    BuildContext context,
    DeviceDetectionService deviceService,
  ) async {
    // Try Universal Link first
    final universalLink = Uri.parse(deviceService.getDeepLinkUrl(''));

    try {
      final launched = await launchUrl(
        universalLink,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback to custom scheme
        final customScheme = Uri.parse(deviceService.getCustomSchemeDeepLink());
        await launchUrl(
          customScheme,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // App not installed, open store instead
      if (context.mounted) {
        await _openStore(
          context,
          isIOS: deviceService.isIOSUserAgent(''),
        );
      }
    }
  }

  /// Open the appropriate app store
  Future<void> _openStore(BuildContext context, {required bool isIOS}) async {
    final url = isIOS
        ? 'https://apps.apple.com/app/fitlog-pro/id123456789' // TODO: Real App Store ID
        : 'https://play.google.com/store/apps/details?id=com.gymbro.fitlog';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
