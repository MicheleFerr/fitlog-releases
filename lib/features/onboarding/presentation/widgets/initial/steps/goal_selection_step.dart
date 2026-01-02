import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 2: Goal selection with visual cards
class GoalSelectionStep extends ConsumerWidget {
  const GoalSelectionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initialOnboardingNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Title
          Text(
            context.l10n.initialOnboardingGoalTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            context.l10n.initialOnboardingGoalSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 32),

          // Goal options
          Expanded(
            child: ListView(
              children: [
                _GoalCard(
                  goal: TrainingGoalUI.buildMuscle,
                  emoji: TrainingGoalUI.buildMuscle.icon,
                  title: context.l10n.initialOnboardingGoalBuildMuscle,
                  subtitle: context.l10n.initialOnboardingGoalBuildMuscleDesc,
                  isSelected: state.goal == TrainingGoalUI.buildMuscle,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setGoal(TrainingGoalUI.buildMuscle),
                ),
                const SizedBox(height: 12),
                _GoalCard(
                  goal: TrainingGoalUI.getStronger,
                  emoji: TrainingGoalUI.getStronger.icon,
                  title: context.l10n.initialOnboardingGoalGetStronger,
                  subtitle: context.l10n.initialOnboardingGoalGetStrongerDesc,
                  isSelected: state.goal == TrainingGoalUI.getStronger,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setGoal(TrainingGoalUI.getStronger),
                ),
                const SizedBox(height: 12),
                _GoalCard(
                  goal: TrainingGoalUI.endurance,
                  emoji: TrainingGoalUI.endurance.icon,
                  title: context.l10n.initialOnboardingGoalEndurance,
                  subtitle: context.l10n.initialOnboardingGoalEnduranceDesc,
                  isSelected: state.goal == TrainingGoalUI.endurance,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setGoal(TrainingGoalUI.endurance),
                ),
                const SizedBox(height: 12),
                _GoalCard(
                  goal: TrainingGoalUI.stayFit,
                  emoji: TrainingGoalUI.stayFit.icon,
                  title: context.l10n.initialOnboardingGoalStayFit,
                  subtitle: context.l10n.initialOnboardingGoalStayFitDesc,
                  isSelected: state.goal == TrainingGoalUI.stayFit,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setGoal(TrainingGoalUI.stayFit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual goal card with emoji, title and description
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final TrainingGoalUI goal;
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.surface,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
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

            // Selection indicator
            if (isSelected)
              Icon(
                AppIcons.checkCircle,
                color: context.colors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
