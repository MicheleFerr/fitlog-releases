/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: UI component
/// 🌍 Localization: ✅ Full (context.l10n)
/// 🎨 Theme: ✅ Theme-aware (context.colors)
/// 📱 Platform: Universal
///
/// ✅ PREVIOUS_DATA: Widget per mostrare dati sessione precedente
/// - Mostra previous weight e reps
/// - Badge con data ultima sessione
/// - Design compatto e discreto
/// - Fade-in animation
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';

/// Widget per mostrare i dati della sessione precedente
///
/// Display compatto che mostra:
/// - Previous weight e reps
/// - Giorni dall'ultima sessione
/// - Icona history
///
/// Example usage:
/// ```dart
/// PreviousDataIndicator(
///   previousWeight: 90.0,
///   previousReps: 10,
///   daysSinceLastSession: 5,
/// )
/// ```
class PreviousDataIndicator extends StatelessWidget {
  const PreviousDataIndicator({
    super.key,
    required this.previousWeight,
    required this.previousReps,
    required this.daysSinceLastSession,
    this.dataSource = 'cache', // 'cache' | 'firestore'
    this.isLoading = false,
    this.onTap, // ✅ AUTOFILL: Callback per auto-fill quando tappato
  });

  final double previousWeight;
  final int previousReps;
  final int daysSinceLastSession;
  final String dataSource; // 'cache' (fast) | 'firestore' (slow)
  final bool isLoading;
  final VoidCallback? onTap; // ✅ AUTOFILL

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: onTap, // ✅ AUTOFILL: Tap to copy previous data to all sets
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: onTap != null
                ? context.colors.primaryContainer.withValues(alpha: 0.3) // ✅ More visible when tappable
                : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: onTap != null // ✅ Highlight border if tappable
                  ? context.colors.primary.withValues(alpha: 0.5) // Increased from 0.3 for better visibility
                  : context.colors.outline.withValues(alpha: 0.2),
              width: onTap != null ? 1.5 : 1, // ✅ Thicker border when tappable
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // History icon
              Icon(
                AppIcons.history,
                size: AppIconSize.small,
                color: context.iconSecondary,
              ),
              const SizedBox(width: 4),

              // Previous data text
              Flexible(
                child: Text(
                  _buildDataText(context),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ✅ AUTOFILL: Copy icon if tappable
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  AppIcons.copy,
                  size: AppIconSize.small, // Increased from tiny to small for visibility
                  color: context.iconPrimary, // Removed alpha for better visibility
                ),
              ],

              // Data source badge (solo se da Firestore - per indicare che era un query lento)
              if (dataSource == 'firestore') ...[
                const SizedBox(width: 4),
                Icon(
                  AppIcons.cloud,
                  size: AppIconSize.tiny,
                  color: context.iconTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppIconSize.small,
            height: AppIconSize.small,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.secondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.loading,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _buildDataText(BuildContext context) {
    // Format: "Last: 90kg x 10 (5d ago)"
    final weightStr = previousWeight.toStringAsFixed(1).replaceAll('.0', '');
    final daysStr = _formatDaysAgo(context, daysSinceLastSession);

    return 'Last: ${weightStr}kg × $previousReps ($daysStr)';
  }

  String _formatDaysAgo(BuildContext context, int days) {
    if (days == 0) {
      return context.l10n.today;
    } else if (days == 1) {
      return context.l10n.yesterday;
    } else if (days <= 7) {
      return '$days${context.l10n.daysAgoShort}'; // "5d ago"
    } else if (days <= 30) {
      final weeks = (days / 7).floor();
      return '$weeks${context.l10n.weeksAgoShort}'; // "2w ago"
    } else {
      final months = (days / 30).floor();
      return '$months${context.l10n.monthsAgoShort}'; // "2mo ago"
    }
  }
}

/// Compact badge variant - even smaller for dense UIs
///
/// Example:
/// ```dart
/// PreviousDataBadge(
///   previousWeight: 90.0,
///   previousReps: 10,
/// )
/// ```
class PreviousDataBadge extends StatelessWidget {
  const PreviousDataBadge({
    super.key,
    required this.previousWeight,
    required this.previousReps,
  });

  final double previousWeight;
  final int previousReps;

  @override
  Widget build(BuildContext context) {
    final weightStr = previousWeight.toStringAsFixed(1).replaceAll('.0', '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.history,
            size: AppIconSize.tiny,
            color: context.iconSecondary,
          ),
          const SizedBox(width: 2),
          Text(
            '${weightStr}kg×$previousReps',
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: context.colors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no previous data is available
///
/// Example:
/// ```dart
/// NoPreviousDataIndicator(
///   isFirstWorkout: true,
/// )
/// ```
class NoPreviousDataIndicator extends StatelessWidget {
  const NoPreviousDataIndicator({
    super.key,
    this.isFirstWorkout = false,
  });

  final bool isFirstWorkout;

  @override
  Widget build(BuildContext context) {
    if (!isFirstWorkout) {
      return const SizedBox.shrink(); // Don't show anything if not first workout
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.newReleases,
            size: AppIconSize.small,
            color: context.iconPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.firstWorkout, // "First workout!"
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
