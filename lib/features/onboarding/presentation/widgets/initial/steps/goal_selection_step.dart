import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/initial_onboarding_style.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 2: Goal selection with visual cards (Yazio-inspired design)
class GoalSelectionStep extends ConsumerWidget {
  const GoalSelectionStep({super.key});

  String _goalAssetPath(TrainingGoalUI goal) {
    switch (goal) {
      case TrainingGoalUI.buildMuscle:
        return 'assets/images/build_muscle.png';
      case TrainingGoalUI.getStronger:
        return 'assets/images/get_stronger.png';
      case TrainingGoalUI.endurance:
        return 'assets/images/endurance.png';
      case TrainingGoalUI.stayFit:
        return 'assets/images/stay_fit.png';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initialOnboardingNotifierProvider);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: InitialOnboardingStyle.horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: InitialOnboardingStyle.topSpacing),

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
                    assetPath: _goalAssetPath(TrainingGoalUI.buildMuscle),
                    fallbackEmoji: TrainingGoalUI.buildMuscle.icon,
                    title: context.l10n.initialOnboardingGoalBuildMuscle,
                    subtitle: context.l10n.initialOnboardingGoalBuildMuscleDesc,
                    isSelected: state.goal == TrainingGoalUI.buildMuscle,
                    onTap: () => ref
                        .read(initialOnboardingNotifierProvider.notifier)
                        .setGoal(TrainingGoalUI.buildMuscle),
                  ),
                  const SizedBox(height: InitialOnboardingStyle.optionSpacing),
                  _GoalCard(
                    goal: TrainingGoalUI.getStronger,
                    assetPath: _goalAssetPath(TrainingGoalUI.getStronger),
                    fallbackEmoji: TrainingGoalUI.getStronger.icon,
                    title: context.l10n.initialOnboardingGoalGetStronger,
                    subtitle: context.l10n.initialOnboardingGoalGetStrongerDesc,
                    isSelected: state.goal == TrainingGoalUI.getStronger,
                    onTap: () => ref
                        .read(initialOnboardingNotifierProvider.notifier)
                        .setGoal(TrainingGoalUI.getStronger),
                  ),
                  const SizedBox(height: InitialOnboardingStyle.optionSpacing),
                  _GoalCard(
                    goal: TrainingGoalUI.endurance,
                    assetPath: _goalAssetPath(TrainingGoalUI.endurance),
                    fallbackEmoji: TrainingGoalUI.endurance.icon,
                    title: context.l10n.initialOnboardingGoalEndurance,
                    subtitle: context.l10n.initialOnboardingGoalEnduranceDesc,
                    isSelected: state.goal == TrainingGoalUI.endurance,
                    onTap: () => ref
                        .read(initialOnboardingNotifierProvider.notifier)
                        .setGoal(TrainingGoalUI.endurance),
                  ),
                  const SizedBox(height: InitialOnboardingStyle.optionSpacing),
                  _GoalCard(
                    goal: TrainingGoalUI.stayFit,
                    assetPath: _goalAssetPath(TrainingGoalUI.stayFit),
                    fallbackEmoji: TrainingGoalUI.stayFit.icon,
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
    required this.assetPath,
    required this.fallbackEmoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final TrainingGoalUI goal;
  final String assetPath;
  final String fallbackEmoji;
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
          padding: const EdgeInsets.all(InitialOnboardingStyle.cardPadding),
          decoration: InitialOnboardingStyle.optionCardDecoration(
            context,
            selected: isSelected,
          ),
          child: Row(
            children: [
              // Transparent image, centered, no background container
              SizedBox(
                width: 86,
                height: 86,
                child: Center(
                  child: Image.asset(
                    assetPath,
                    width: 78,
                    height: 78,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      fallbackEmoji,
                      style: const TextStyle(fontSize: 52),
                    ),
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
