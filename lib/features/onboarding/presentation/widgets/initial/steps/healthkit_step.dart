import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 5: HealthKit permissions selection
class HealthKitStep extends ConsumerWidget {
  const HealthKitStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initialOnboardingNotifierProvider);
    final notifier = ref.read(initialOnboardingNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Title
          Text(
            context.l10n.initialOnboardingHealthKitTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            context.l10n.initialOnboardingHealthKitSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 32),

          // Health data options
          Expanded(
            child: ListView(
              children: [
                // Workouts (default ON, free)
                _HealthToggle(
                  type: HealthDataType.workout,
                  icon: AppIcons.workout,
                  title: context.l10n.initialOnboardingHealthKitWorkouts,
                  subtitle: context.l10n.initialOnboardingHealthKitWorkoutsDesc,
                  isSelected: state.selectedHealthTypes.contains(
                    HealthDataType.workout,
                  ),
                  isPro: false,
                  onToggle: () =>
                      notifier.toggleHealthType(HealthDataType.workout),
                ),

                const SizedBox(height: 12),

                // Body weight (default ON, free)
                _HealthToggle(
                  type: HealthDataType.bodyWeight,
                  icon: AppIcons.weight,
                  title: context.l10n.initialOnboardingHealthKitWeight,
                  subtitle: context.l10n.initialOnboardingHealthKitWeightDesc,
                  isSelected: state.selectedHealthTypes.contains(
                    HealthDataType.bodyWeight,
                  ),
                  isPro: false,
                  onToggle: () =>
                      notifier.toggleHealthType(HealthDataType.bodyWeight),
                ),

                const SizedBox(height: 12),

                // Sleep (PRO feature)
                _HealthToggle(
                  type: HealthDataType.sleep,
                  icon: AppIcons.bedtime,
                  title: context.l10n.initialOnboardingHealthKitSleep,
                  subtitle: context.l10n.initialOnboardingHealthKitSleepDesc,
                  isSelected: state.selectedHealthTypes.contains(
                    HealthDataType.sleep,
                  ),
                  isPro: true,
                  onToggle: () =>
                      notifier.toggleHealthType(HealthDataType.sleep),
                ),

                const SizedBox(height: 12),

                // Heart Rate (PRO feature)
                _HealthToggle(
                  type: HealthDataType.heartRate,
                  icon: AppIcons.favorite,
                  title: context.l10n.initialOnboardingHealthKitHrv,
                  subtitle: context.l10n.initialOnboardingHealthKitHrvDesc,
                  isSelected: state.selectedHealthTypes.contains(
                    HealthDataType.heartRate,
                  ),
                  isPro: true,
                  onToggle: () =>
                      notifier.toggleHealthType(HealthDataType.heartRate),
                ),
              ],
            ),
          ),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.lockOutline,
                  size: 20,
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.initialOnboardingHealthKitPrivacy,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Connect button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.selectedHealthTypes.isNotEmpty
                  ? () => _connectHealthKit(context, ref)
                  : null,
              icon: Icon(AppIcons.healthAndSafety),
              label: Text(
                context.l10n.initialOnboardingHealthKitConnect,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Skip button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => notifier.skipHealthKit(),
              child: Text(
                context.l10n.initialOnboardingHealthKitSkip,
                style: TextStyle(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _connectHealthKit(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(initialOnboardingNotifierProvider.notifier);

    // TODO: Implement actual HealthKit permission request
    // For now, mark as connected and proceed
    notifier.setHealthKitConnected(true);
    notifier.nextStep();
  }
}

/// Toggle switch for health data type
class _HealthToggle extends StatelessWidget {
  const _HealthToggle({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isPro,
    required this.onToggle,
  });

  final HealthDataType type;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isPro;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.5)
              : context.colors.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: context.colors.primary, size: 24),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRO',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch.adaptive(
            value: isSelected,
            onChanged: (_) => onToggle(),
            activeColor: context.colors.primary,
          ),
        ],
      ),
    );
  }
}
