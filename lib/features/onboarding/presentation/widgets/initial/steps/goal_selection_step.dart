import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 2: Goal selection with visual cards (Yazio-inspired design)
class GoalSelectionStep extends ConsumerWidget {
  const GoalSelectionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initialOnboardingNotifierProvider);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Title - bigger and bolder
            Text(
              context.l10n.initialOnboardingGoalTitle,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle - larger text
            Text(
              context.l10n.initialOnboardingGoalSubtitle,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Goal options with increased spacing
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
      ),
    );
  }
}

/// Visual goal card with emoji, title, description and animated selection
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
    // Accessibility: Goal card with semantic label
    return Semantics(
      label: '$title${isSelected ? ', selected' : ''}',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.primary.withValues(alpha: 0.08),
                    context.colors.primary.withValues(alpha: 0.02),
                  ],
                )
              : null,
          color: isSelected ? null : context.colors.surface,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withValues(alpha: 0.3),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Emoji - larger container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
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

            // Animated checkmark
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                AppIcons.checkCircle,
                color: context.colors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
