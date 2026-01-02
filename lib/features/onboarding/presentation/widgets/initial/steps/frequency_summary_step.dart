import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Step 6: Workout frequency + Summary
class FrequencySummaryStep extends ConsumerWidget {
  const FrequencySummaryStep({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

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
            context.l10n.initialOnboardingFrequencyTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            context.l10n.initialOnboardingFrequencySubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 32),

          // Frequency selector
          _FrequencySelector(
            value: state.workoutsPerWeek,
            onChanged: (value) => notifier.setWorkoutsPerWeek(value),
          ),

          const SizedBox(height: 32),

          // Divider
          Divider(
            color: context.colors.outline.withValues(alpha: 0.3),
          ),

          const SizedBox(height: 16),

          // Summary section
          Text(
            context.l10n.initialOnboardingSummaryTitle,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // Summary items
          _SummaryItem(
            label: context.l10n.initialOnboardingSummaryGoal,
            value: state.goal != null
                ? '${state.goal!.icon} ${_getGoalLabel(context, state.goal!)}'
                : '-',
          ),
          const SizedBox(height: 12),
          _SummaryItem(
            label: context.l10n.initialOnboardingSummaryWeight,
            value: state.bodyweightKg != null
                ? '${state.bodyweightKg!.toStringAsFixed(0)} kg'
                : '-',
          ),
          const SizedBox(height: 12),
          _SummaryItem(
            label: context.l10n.initialOnboardingSummaryExperience,
            value: state.experience != null
                ? '${state.experience!.icon} ${_getExperienceLabel(context, state.experience!)}'
                : '-',
          ),
          const SizedBox(height: 12),
          _SummaryItem(
            label: context.l10n.initialOnboardingSummaryFrequency,
            value: '${state.workoutsPerWeek}x / ${context.l10n.initialOnboardingWeek}',
          ),
          const SizedBox(height: 12),
          _SummaryItem(
            label: context.l10n.initialOnboardingSummaryHealth,
            value: state.healthKitConnected
                ? context.l10n.initialOnboardingConnected
                : context.l10n.initialOnboardingNotConnected,
            valueColor: state.healthKitConnected
                ? context.colors.success
                : context.colors.onSurface.withValues(alpha: 0.5),
          ),

          const Spacer(),

          // Error message
          if (state.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.errorOutline,
                    size: 20,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Complete button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isCompleting || !state.isComplete
                  ? null
                  : onComplete,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isCompleting
                  ? const LoadingIndicator(size: 24)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '\u{1F680}', // 🚀
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.initialOnboardingComplete,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Info text
          Text(
            context.l10n.initialOnboardingCompleteInfo,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getGoalLabel(BuildContext context, dynamic goal) {
    // Match the goal enum to localized string
    switch (goal.toString()) {
      case 'TrainingGoalUI.buildMuscle':
        return context.l10n.initialOnboardingGoalBuildMuscle;
      case 'TrainingGoalUI.getStronger':
        return context.l10n.initialOnboardingGoalGetStronger;
      case 'TrainingGoalUI.endurance':
        return context.l10n.initialOnboardingGoalEndurance;
      case 'TrainingGoalUI.stayFit':
        return context.l10n.initialOnboardingGoalStayFit;
      default:
        return '-';
    }
  }

  String _getExperienceLabel(BuildContext context, dynamic experience) {
    switch (experience.toString()) {
      case 'ExperienceLevelUI.beginner':
        return context.l10n.initialOnboardingExperienceBeginner;
      case 'ExperienceLevelUI.someExperience':
        return context.l10n.initialOnboardingExperienceSome;
      case 'ExperienceLevelUI.experienced':
        return context.l10n.initialOnboardingExperienceExperienced;
      case 'ExperienceLevelUI.athlete':
        return context.l10n.initialOnboardingExperienceAthlete;
      default:
        return '-';
    }
  }
}

/// Frequency selector (1-7 days)
class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final day = index + 1;
        final isSelected = day == value;

        return GestureDetector(
          onTap: () => onChanged(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? context.colors.onPrimary
                      : context.colors.onSurface,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Summary item row
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? context.colors.onSurface,
          ),
        ),
      ],
    );
  }
}
