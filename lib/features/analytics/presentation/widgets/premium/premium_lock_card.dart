import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Premium Lock Card
///
/// Shown to non-premium users with preview of premium features
class PremiumLockCard extends StatelessWidget {

  const PremiumLockCard({
    super.key,
    required this.workouts,
  });
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Preview cards (blurred/locked)
        _buildLockedPreview(
          context,
          l10n.repContinuum,
          l10n.repContinuumPreview,
          AppIcons.analytics,
        ),
        const SizedBox(height: 16),

        _buildLockedPreview(
          context,
          l10n.volumeLandmarks,
          l10n.volumeLandmarksPreview,
          AppIcons.lineChart,
        ),
        const SizedBox(height: 24),

        // Unlock CTA
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                AppIcons.autoAwesome,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.unlockPremiumAnalytics,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.premiumAnalyticsDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Features list
              _buildFeatureItem(
                context,
                AppIcons.analytics,
                l10n.repContinuumFeature,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                AppIcons.timeline,
                l10n.volumeLandmarksFeature,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                AppIcons.speed,
                l10n.tutVelocityFeature,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                context,
                AppIcons.verified,
                l10n.dataConfidenceFeature,
              ),
              const SizedBox(height: 24),

              // Unlock button
              FilledButton.icon(
                onPressed: () {
                  // TODO: Navigate to premium subscription screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.premiumComingSoon),
                    ),
                  );
                },
                icon: const Icon(AppIcons.unlock),
                label: Text(l10n.unlockPremium),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedPreview(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              // Blurred chart preview
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        // Lock overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                AppIcons.lock,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          AppIcons.complete,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
