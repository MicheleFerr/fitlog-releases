/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets/onboarding
/// 🎯 Feature: flexible_routine
/// 🔧 Type: onboarding screen
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// ROUTINE ONBOARDING SCREEN - First-time tutorial for routine feature
///
/// Features:
/// - Multi-page explanation with visuals
/// - Interactive examples
/// - Skip option
/// - Mark as completed in preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Onboarding screen for routine feature
class RoutineOnboardingScreen extends ConsumerStatefulWidget {

  const RoutineOnboardingScreen({
    super.key,
    required this.onComplete,
  });
  final VoidCallback onComplete;

  @override
  ConsumerState<RoutineOnboardingScreen> createState() =>
      _RoutineOnboardingScreenState();
}

class _RoutineOnboardingScreenState
    extends ConsumerState<RoutineOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? context.colors.primary
                              : context.colors.outlineVariant
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      context.l10n.routineOnboardingSkip,
                      style: TextStyle(color: context.colors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(context),
                  _buildWhatIsRoutinePage(context),
                  _buildHowItWorksPage(context),
                  _buildBenefitsPage(context),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: context.colors.primary),
                        ),
                        child: Text(context.l10n.routineOnboardingBack),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                      ),
                      child: Text(
                        _currentPage == 3 ? context.l10n.routineOnboardingGetStarted : context.l10n.routineOnboardingNext,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month,
              size: 80,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            context.l10n.routineOnboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            context.l10n.routineOnboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsRoutinePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            context.l10n.routineOnboardingWhatIsTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 24),

          // Definition
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              context.l10n.routineOnboardingWhatIsDescription,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Features
          _buildFeatureItem(
            context,
            icon: Icons.calendar_today,
            title: context.l10n.routineOnboardingFeatureScheduled,
            description: context.l10n.routineOnboardingFeatureScheduledDesc,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.fitness_center,
            title: context.l10n.routineOnboardingFeatureTemplates,
            description: context.l10n.routineOnboardingFeatureTemplatesDesc,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.repeat,
            title: context.l10n.routineOnboardingFeatureProgression,
            description: context.l10n.routineOnboardingFeatureProgressionDesc,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            icon: Icons.show_chart,
            title: context.l10n.routineOnboardingFeatureTracking,
            description: context.l10n.routineOnboardingFeatureTrackingDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            context.l10n.routineOnboardingHowItWorksTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 32),

          // Steps
          _buildStepItem(
            context,
            number: 1,
            title: context.l10n.routineOnboardingStep1Title,
            description: context.l10n.routineOnboardingStep1Desc,
            icon: Icons.create,
          ),
          const SizedBox(height: 24),
          _buildStepItem(
            context,
            number: 2,
            title: context.l10n.routineOnboardingStep2Title,
            description: context.l10n.routineOnboardingStep2Desc,
            icon: Icons.assignment,
          ),
          const SizedBox(height: 24),
          _buildStepItem(
            context,
            number: 3,
            title: context.l10n.routineOnboardingStep3Title,
            description: context.l10n.routineOnboardingStep3Desc,
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            context.l10n.routineOnboardingBenefitsTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 32),

          // Benefits
          _buildBenefitCard(
            context,
            icon: Icons.track_changes,
            title: context.l10n.routineOnboardingBenefit1Title,
            description: context.l10n.routineOnboardingBenefit1Desc,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildBenefitCard(
            context,
            icon: Icons.insights,
            title: context.l10n.routineOnboardingBenefit2Title,
            description: context.l10n.routineOnboardingBenefit2Desc,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildBenefitCard(
            context,
            icon: Icons.auto_awesome,
            title: context.l10n.routineOnboardingBenefit3Title,
            description: context.l10n.routineOnboardingBenefit3Desc,
            color: Colors.orange,
          ),
          const SizedBox(height: 32),

          // CTA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary.withValues(alpha: 0.2),
                  context.colors.secondary.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.rocket_launch, color: context.colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.routineOnboardingReadyCTA,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.colors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number badge
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: context.colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - complete onboarding
      widget.onComplete();
    }
  }

  void _handleSkip() {
    widget.onComplete();
  }
}
