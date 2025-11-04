/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: buddy_matching
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class InstagramLinkButton extends StatelessWidget {

  const InstagramLinkButton({
    super.key,
    required this.handle,
    this.compact = true,
  });
  final String handle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Remove @ if present
    final cleanHandle = handle.startsWith('@') ? handle.substring(1) : handle;

    return InkWell(
      onTap: () => _openInstagram(context, cleanHandle),
      borderRadius: BorderRadius.circular(compact ? 20 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 6 : 12,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF833AB4),
              Color(0xFFE1306C),
              Color(0xFFFCAF45),
            ],
          ),
          borderRadius: BorderRadius.circular(compact ? 20 : 12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF833AB4).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt,
              size: compact ? 16 : 20,
              color: context.colors.surface,
            ),
            const SizedBox(width: 6),
            if (compact) ...[
              Text(
                '@$cleanHandle',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.openInstagram,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: context.colors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '@$cleanHandle',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.surface.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openInstagram(BuildContext context, String handle) async {
    HapticFeedback.lightImpact();

    try {
      // Try to open Instagram app first
      final instagramAppUri = Uri.parse('instagram://user?username=$handle');
      
      if (await canLaunchUrl(instagramAppUri)) {
        await launchUrl(instagramAppUri);
      } else {
        // Fallback to web version
        final webUri = Uri.parse('https://www.instagram.com/$handle');
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impossibile aprire Instagram'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}