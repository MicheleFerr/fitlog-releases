/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/screens/onboarding
/// 🎯 Feature: ai_coach
/// 🔧 Type: screen
///
/// Onboarding Experience Level Screen - Step 1 of 4
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Onboarding Step 1: Experience Level Selection
///
/// Allows user to select their training experience level:
/// - Beginner (0-6 months)
/// - Intermediate (6-24 months)
/// - Advanced (2+ years)
///
/// Features:
/// - Visual cards with icons and descriptions
/// - Single selection
/// - Progress indicator (1/4)
/// - Localized content
/// - Theme-aware colors
///
/// Navigation:
/// - Back: Close onboarding (confirm dialog)
/// - Next: OnboardingGoalScreen (Step 2)
class OnboardingExperienceScreen extends ConsumerStatefulWidget {
  const OnboardingExperienceScreen({super.key});

  @override
  ConsumerState<OnboardingExperienceScreen> createState() =>
      _OnboardingExperienceScreenState();
}

class _OnboardingExperienceScreenState
    extends ConsumerState<OnboardingExperienceScreen> {
  ExperienceLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.onboardingTitle),
        leading: IconButton(
          icon: SemanticIcon(
            icon: AppIcons.close,
            semanticLabel: context.l10n.close,
            size: AppIconSize.medium,
          ),
          onPressed: () => _onBackPressed(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Title
              Text(
                context.l10n.onboardingExperienceTitle,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                context.l10n.onboardingExperienceSubtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Experience level cards
              Expanded(
                child: ListView(
                  children: [
                    _buildLevelCard(
                      level: ExperienceLevel.beginner,
                      icon: AppIcons.education,
                      title: context.l10n.beginnerLevel,
                      description: context.l10n.beginnerLevelDescription,
                    ),
                    const SizedBox(height: 16),
                    _buildLevelCard(
                      level: ExperienceLevel.intermediate,
                      icon: AppIcons.trendingUp,
                      title: context.l10n.intermediateLevel,
                      description: context.l10n.intermediateLevelDescription,
                    ),
                    const SizedBox(height: 16),
                    _buildLevelCard(
                      level: ExperienceLevel.advanced,
                      icon: AppIcons.stars,
                      title: context.l10n.advancedLevel,
                      description: context.l10n.advancedLevelDescription,
                    ),
                  ],
                ),
              ),

              // Next button
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _selectedLevel != null ? _onNextPressed : null,
                child: Text(context.l10n.next),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build progress indicator (1/4)
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
            color: index == 0
                ? context.colors.primary
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Build experience level card
  Widget _buildLevelCard({
    required ExperienceLevel level,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedLevel == level;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: context.colors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedLevel = level),
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

  /// Handle back button press
  Future<void> _onBackPressed(BuildContext context) async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.onboardingExitTitle),
        content: Text(context.l10n.onboardingExitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );

    if (shouldClose == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Handle next button press
  void _onNextPressed() {
    if (_selectedLevel == null) return;

    // TODO: Navigate to OnboardingGoalScreen (Step 2)
    // TODO: Save selected experience level to provider
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (context) => OnboardingGoalScreen(
    //     selectedExperience: _selectedLevel!,
    //   ),
    // ));
  }
}
