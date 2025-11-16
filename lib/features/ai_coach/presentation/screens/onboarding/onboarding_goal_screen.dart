/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/screens/onboarding
/// 🎯 Feature: ai_coach
/// 🔧 Type: screen
///
/// Onboarding Goal Selection Screen - Step 2 of 4
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Onboarding Step 2: Training Goal Selection
///
/// Allows user to select their primary training goal:
/// - Hypertrophy (muscle growth)
/// - Strength (max strength)
/// - Endurance (muscular endurance)
///
/// Navigation:
/// - Back: OnboardingExperienceScreen (Step 1)
/// - Next: OnboardingQuickWinScreen (Step 3)
class OnboardingGoalScreen extends ConsumerStatefulWidget {
  const OnboardingGoalScreen({
    required this.selectedExperience,
    super.key,
  });

  final ExperienceLevel selectedExperience;

  @override
  ConsumerState<OnboardingGoalScreen> createState() =>
      _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends ConsumerState<OnboardingGoalScreen> {
  TrainingGoal? _selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.onboardingTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator (2/4)
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Title
              Text(
                context.l10n.onboardingGoalTitle,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                context.l10n.onboardingGoalSubtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Goal cards
              Expanded(
                child: ListView(
                  children: [
                    _buildGoalCard(
                      goal: TrainingGoal.hypertrophy,
                      icon: AppIcons.trendingUp,
                      title: context.l10n.hypertrophyGoal,
                      description: context.l10n.hypertrophyGoalDescription,
                    ),
                    const SizedBox(height: 16),
                    _buildGoalCard(
                      goal: TrainingGoal.strength,
                      icon: AppIcons.workout,
                      title: context.l10n.strengthGoal,
                      description: context.l10n.strengthGoalDescription,
                    ),
                    const SizedBox(height: 16),
                    _buildGoalCard(
                      goal: TrainingGoal.endurance,
                      icon: AppIcons.timer,
                      title: context.l10n.enduranceGoal,
                      description: context.l10n.enduranceGoalDescription,
                    ),
                  ],
                ),
              ),

              // Next button
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _selectedGoal != null ? _onNextPressed : null,
                child: Text(context.l10n.next),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build progress indicator (2/4)
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: index <= 1
                ? context.colors.primary
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Build training goal card
  Widget _buildGoalCard({
    required TrainingGoal goal,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedGoal == goal;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: context.colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedGoal = goal),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primaryContainer
                      : context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SemanticIcon(
                    icon: icon,
                    semanticLabel: title,
                    size: AppIconSize.large,
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                SemanticIcon(
                  icon: AppIcons.checkCircle,
                  semanticLabel: context.l10n.selected,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle next button press
  void _onNextPressed() {
    if (_selectedGoal == null) return;

    // TODO: Navigate to OnboardingQuickWinScreen (Step 3)
    // TODO: Save selected goal to provider
  }
}
