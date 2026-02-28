import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/initial_onboarding_style.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Step 4: Experience level selection (Yazio-inspired)
class ExperienceStep extends ConsumerWidget {
  const ExperienceStep({super.key});

  String _experienceAssetPath(ExperienceLevelUI level, BiologicalSex? sex) {
    final isFemale = sex == BiologicalSex.female;
    final isMale = sex == BiologicalSex.male;

    switch (level) {
      case ExperienceLevelUI.beginner:
        if (isFemale) return 'assets/images/female_beginner.png';
        if (isMale) return 'assets/images/male_beginner.png';
        return 'assets/images/male_beginner.png';
      case ExperienceLevelUI.someExperience:
        if (isFemale) return 'assets/images/female_some_experience.png';
        if (isMale) return 'assets/images/male_some_experience.png';
        return 'assets/images/male_some_experience.png';
      case ExperienceLevelUI.experienced:
        if (isFemale) return 'assets/images/female_experienced.png';
        if (isMale) return 'assets/images/male_experienced.png';
        return 'assets/images/male_experienced.png';
      case ExperienceLevelUI.athlete:
        if (isFemale) return 'assets/images/female_athlete.png';
        if (isMale) return 'assets/images/male_athlete.png';
        return 'assets/images/male_athlete.png';
    }
  }

  String _emojiForLevel(ExperienceLevelUI level, BiologicalSex? sex) {
    switch (level) {
      case ExperienceLevelUI.beginner:
        if (sex == BiologicalSex.female) return '🧍‍♀️';
        if (sex == BiologicalSex.male) return '🧍‍♂️';
        return ExperienceLevelUI.beginner.icon;
      case ExperienceLevelUI.someExperience:
        if (sex == BiologicalSex.female) return '🏋️‍♀️';
        if (sex == BiologicalSex.male) return '🏋️‍♂️';
        return ExperienceLevelUI.someExperience.icon;
      case ExperienceLevelUI.experienced:
        if (sex == BiologicalSex.female) return '💪🏻';
        if (sex == BiologicalSex.male) return '💪';
        return ExperienceLevelUI.experienced.icon;
      case ExperienceLevelUI.athlete:
        if (sex == BiologicalSex.female) return '🥇';
        if (sex == BiologicalSex.male) return '🏆';
        return ExperienceLevelUI.athlete.icon;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initialOnboardingNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: InitialOnboardingStyle.horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: InitialOnboardingStyle.topSpacing),

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
                  assetPath: _experienceAssetPath(
                    ExperienceLevelUI.beginner,
                    state.sex,
                  ),
                  emoji: _emojiForLevel(ExperienceLevelUI.beginner, state.sex),
                  title: context.l10n.initialOnboardingExperienceBeginner,
                  subtitle:
                      context.l10n.initialOnboardingExperienceBeginnerDesc,
                  isSelected: state.experience == ExperienceLevelUI.beginner,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setExperience(ExperienceLevelUI.beginner),
                ),
                const SizedBox(height: InitialOnboardingStyle.optionSpacing),
                _ExperienceCard(
                  level: ExperienceLevelUI.someExperience,
                  assetPath: _experienceAssetPath(
                    ExperienceLevelUI.someExperience,
                    state.sex,
                  ),
                  emoji: _emojiForLevel(
                    ExperienceLevelUI.someExperience,
                    state.sex,
                  ),
                  title: context.l10n.initialOnboardingExperienceSome,
                  subtitle: context.l10n.initialOnboardingExperienceSomeDesc,
                  isSelected:
                      state.experience == ExperienceLevelUI.someExperience,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setExperience(ExperienceLevelUI.someExperience),
                ),
                const SizedBox(height: InitialOnboardingStyle.optionSpacing),
                _ExperienceCard(
                  level: ExperienceLevelUI.experienced,
                  assetPath: _experienceAssetPath(
                    ExperienceLevelUI.experienced,
                    state.sex,
                  ),
                  emoji: _emojiForLevel(
                    ExperienceLevelUI.experienced,
                    state.sex,
                  ),
                  title: context.l10n.initialOnboardingExperienceExperienced,
                  subtitle:
                      context.l10n.initialOnboardingExperienceExperiencedDesc,
                  isSelected: state.experience == ExperienceLevelUI.experienced,
                  onTap: () => ref
                      .read(initialOnboardingNotifierProvider.notifier)
                      .setExperience(ExperienceLevelUI.experienced),
                ),
                const SizedBox(height: InitialOnboardingStyle.optionSpacing),
                _ExperienceCard(
                  level: ExperienceLevelUI.athlete,
                  assetPath: _experienceAssetPath(
                    ExperienceLevelUI.athlete,
                    state.sex,
                  ),
                  emoji: _emojiForLevel(ExperienceLevelUI.athlete, state.sex),
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
    required this.assetPath,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final ExperienceLevelUI level;
  final String assetPath;
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Accessibility: Experience level card with semantic label
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
                    errorBuilder: (_, __, ___) =>
                        Text(emoji, style: const TextStyle(fontSize: 52)),
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
      ),
    );
  }
}
