import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 4: Experience level selection (Yazio-inspired)
class ExperienceStep extends ConsumerWidget {
  const ExperienceStep({super.key});

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
            context.l10n.initialOnboardingExperienceTitle,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            context.l10n.initialOnboardingExperienceSubtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 32),

          // Experience options
          Expanded(
            child: ListView(
              children: [
                _ExperienceCard(
                  level: ExperienceLevelUI.beginner,
                  emoji: ExperienceLevelUI.beginner.icon,
                  title: context.l10n.initialOnboardingExperienceBeginner,
                  subtitle: context.l10n.initialOnboardingExperienceBeginnerDesc,
                  isSelected: state.experience == ExperienceLevelUI.beginner,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setExperience(ExperienceLevelUI.beginner),
                ),
                const SizedBox(height: 16),
                _ExperienceCard(
                  level: ExperienceLevelUI.someExperience,
                  emoji: ExperienceLevelUI.someExperience.icon,
                  title: context.l10n.initialOnboardingExperienceSome,
                  subtitle: context.l10n.initialOnboardingExperienceSomeDesc,
                  isSelected: state.experience == ExperienceLevelUI.someExperience,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setExperience(ExperienceLevelUI.someExperience),
                ),
                const SizedBox(height: 16),
                _ExperienceCard(
                  level: ExperienceLevelUI.experienced,
                  emoji: ExperienceLevelUI.experienced.icon,
                  title: context.l10n.initialOnboardingExperienceExperienced,
                  subtitle: context.l10n.initialOnboardingExperienceExperiencedDesc,
                  isSelected: state.experience == ExperienceLevelUI.experienced,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setExperience(ExperienceLevelUI.experienced),
                ),
                const SizedBox(height: 16),
                _ExperienceCard(
                  level: ExperienceLevelUI.athlete,
                  emoji: ExperienceLevelUI.athlete.icon,
                  title: context.l10n.initialOnboardingExperienceAthlete,
                  subtitle: context.l10n.initialOnboardingExperienceAthleteDesc,
                  isSelected: state.experience == ExperienceLevelUI.athlete,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setExperience(ExperienceLevelUI.athlete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Experience level card (Yazio-inspired with gradient and animated checkmark)
class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.level,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final ExperienceLevelUI level;
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
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0.1),
                    context.colors.primary.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : context.colors.surface,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Emoji container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
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
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Animated checkmark
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                AppIcons.checkCircle,
                color: context.colors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
