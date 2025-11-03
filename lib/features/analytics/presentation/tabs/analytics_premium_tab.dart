import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/premium/rep_continuum_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/premium/volume_landmarks_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/premium/rpe_intensity_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/premium/premium_lock_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Premium Analytics Tab
///
/// Science-based advanced analytics for serious athletes:
/// - Rep Continuum Analysis (Schoenfeld 2021)
/// - Volume Landmarks (Bernárdez-Vázquez 2022)
/// - RPE & Intensity Distribution (Helms 2018, Zourdos 2016)
/// - TUT & Velocity (coming soon)
/// - Data Confidence Score (coming soon)
class AnalyticsPremiumTab extends ConsumerWidget {

  const AnalyticsPremiumTab({
    super.key,
    required this.workouts,
    required this.isPremium,
  });
  final List<Workout> workouts;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (!isPremium) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PremiumLockCard(workouts: workouts),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            l10n.premiumAnalytics,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scienceBasedInsights,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Module 1: Rep Continuum
          RepContinuumCard(workouts: workouts),
          const SizedBox(height: 16),

          // Module 2: Volume Landmarks
          VolumeLandmarksCard(workouts: workouts),
          const SizedBox(height: 16),

          // Module 3: RPE & Intensity
          RPEIntensityCard(workouts: workouts),
          const SizedBox(height: 16),

          // Coming soon modules
          _buildComingSoonCard(
            context,
            l10n.tutVelocityAnalytics,
            l10n.tutVelocityDesc,
            AppIcons.timer,
          ),
          const SizedBox(height: 16),

          _buildComingSoonCard(
            context,
            l10n.dataConfidenceScore,
            l10n.dataConfidenceDesc,
            AppIcons.verifiedOutlined,
          ),
          const SizedBox(height: 16),

          _buildComingSoonCard(
            context,
            l10n.anabolicSignals,
            l10n.anabolicSignalsDesc,
            Icons.show_chart,
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            AppIcons.lockClock,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
