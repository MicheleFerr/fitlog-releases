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
/// - Riverpod: ConsumerWidget
/// - Firebase: None
/// - Hive: None
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/matching_purpose.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class VerificationBadges extends ConsumerWidget {

  const VerificationBadges({
    super.key,
    required this.profile,
    this.size = 24,
    this.showText = false,
  });
  final BuddyProfile profile;
  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final badges = <Widget>[];

    // Main verification badge
    if (profile.isVerified) {
      badges.add(_buildBadge(
        context,
        icon: AppIcons.verified,
        color: const Color(0xFF1DA1F2), // Twitter blue
        text: AppLocalizations.of(context).verified,
        tooltip: 'Profilo verificato dal team GymBro',
      ));
    }

    // Instagram verification
    if (profile.hasInstagramVerification) {
      badges.add(_buildBadge(
        context,
        icon: AppIcons.camera,
        color: const Color(0xFFE4405F), // Instagram pink
        text: AppLocalizations.of(context).instagramVerified,
        tooltip: 'Account Instagram collegato e verificato',
      ));
    }

    // Photo verification
    if (profile.isPhotoVerified) {
      badges.add(_buildBadge(
        context,
        icon: Icons.photo_camera,
        color: context.successColor, // Success
        text: AppLocalizations.of(context).photoVerified,
        tooltip: 'Foto del profilo verificata',
      ));
    }

    // Boosted profile indicator
    if (profile.isCurrentlyBoosted) {
      badges.add(_buildBadge(
        context,
        icon: Icons.rocket_launch,
        color: context.warningColor, // Warning
        text: AppLocalizations.of(context).boosted,
        tooltip: 'Profilo in evidenza',
      ));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return showText 
        ? _buildBadgeList(badges)
        : _buildBadgeRow(badges);
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: showText
          ? _buildBadgeWithText(context, icon, color, text)
          : _buildBadgeIcon(context, icon, color),
    );
  }

  Widget _buildBadgeIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.6,
        color: context.colors.surface,
      ),
    );
  }

  Widget _buildBadgeWithText(BuildContext context, IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeRow(List<Widget> badges) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: badges
          .map((badge) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: badge,
              ))
          .toList(),
    );
  }

  Widget _buildBadgeList(List<Widget> badges) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: badges,
    );
  }
}

/// Trust score indicator with color-coded levels
class TrustScoreIndicator extends ConsumerWidget {

  const TrustScoreIndicator({
    super.key,
    required this.trustScore,
    this.showText = true,
    this.size = 32,
  });
  final double trustScore;
  final bool showText;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    Color getScoreColor() {
      if (trustScore >= 80) return context.successColor; // Success
      if (trustScore >= 60) return context.warningColor; // Warning
      if (trustScore >= 40) return context.warningColor; // Warning
      return context.errorColor; // Error
    }

    IconData getScoreIcon() {
      if (trustScore >= 80) return Icons.shield_outlined;
      if (trustScore >= 60) return AppIcons.verifiedUserOutlined;
      if (trustScore >= 40) return Icons.security;
      return AppIcons.reportProblemOutlined;
    }

    final color = getScoreColor();
    final icon = getScoreIcon();

    return Tooltip(
      message: 'Punteggio di fiducia basato su verifiche, recensioni e comportamento',
      child: Container(
        padding: showText 
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: size * 0.7,
              color: color,
            ),
            if (showText) ...[
              SizedBox(width: 4),
              Text(
                l10n.trustScore(trustScore.round()),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Connection type badges showing what user is looking for
class ConnectionTypeBadges extends ConsumerWidget {

  const ConnectionTypeBadges({
    super.key,
    required this.profile,
    this.compact = false,
  });
  final BuddyProfile profile;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final badges = <Widget>[];

    // Matching purpose badge
    badges.add(_buildConnectionBadge(
      context,
      emoji: profile.preferences.matchingPurpose.emoji,
      text: _getMatchingPurposeText(l10n, profile.preferences.matchingPurpose),
      color: colorScheme.primaryContainer,
      textColor: colorScheme.onPrimaryContainer,
    ));

    // Additional connection preferences
    if (profile.preferences.openToFriendship) {
      badges.add(_buildConnectionBadge(
        context,
        emoji: '🤝',
        text: compact ? '' : l10n.openToFriendship,
        color: context.successContainer,
        textColor: context.successColor,
      ));
    }

    if (profile.preferences.openToDating) {
      badges.add(_buildConnectionBadge(
        context,
        emoji: '❤️',
        text: compact ? '' : l10n.openToDating,
        color: context.errorContainer,
        textColor: context.errorColor,
      ));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: badges,
    );
  }

  Widget _buildConnectionBadge(
    BuildContext context, {
    required String emoji,
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: compact ? 12 : 14),
          ),
          if (text.isNotEmpty && !compact) ...[
            SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getMatchingPurposeText(AppLocalizations l10n, MatchingPurpose purpose) {
    switch (purpose) {
      case MatchingPurpose.workoutPartner:
        return l10n.matchingPurposeWorkoutPartner;
      case MatchingPurpose.gymBuddy:
        return l10n.matchingPurposeGymBuddy;
      case MatchingPurpose.both:
        return l10n.matchingPurposeBoth;
      case MatchingPurpose.openToEverything:
        return l10n.matchingPurposeOpenToEverything;
    }
  }
}
