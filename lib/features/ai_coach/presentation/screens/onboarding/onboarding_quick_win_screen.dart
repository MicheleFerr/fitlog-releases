/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/screens/onboarding
/// 🎯 Feature: ai_coach
/// 🔧 Type: screen
///
/// Onboarding Quick Win Screen - Step 3 of 4
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Onboarding Step 3: Quick Win
///
/// Analyzes user's existing workout data and shows 1 immediate insight
/// to demonstrate AI Coach value before final step.
///
/// Features:
/// - Analyzes existing workout history
/// - Shows personalized quick win insight
/// - Visual feedback with icon and description
/// - Progress indicator (3/4)
/// - Loading state during analysis
/// - Empty state if no data to analyze
///
/// Navigation:
/// - Back: OnboardingGoalScreen (Step 2)
/// - Next: OnboardingNotificationsScreen (Step 4)
class OnboardingQuickWinScreen extends ConsumerStatefulWidget {
  const OnboardingQuickWinScreen({
    required this.selectedExperience,
    required this.selectedGoal,
    super.key,
  });

  final ExperienceLevel selectedExperience;
  final TrainingGoal selectedGoal;

  @override
  ConsumerState<OnboardingQuickWinScreen> createState() =>
      _OnboardingQuickWinScreenState();
}

class _OnboardingQuickWinScreenState
    extends ConsumerState<OnboardingQuickWinScreen> {
  bool _isAnalyzing = true;
  AIInsight? _quickWinInsight;

  @override
  void initState() {
    super.initState();
    // Simulate analysis delay (in production, this would call analyzer)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _generateQuickWinInsight();
      }
    });
  }

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
              // Progress indicator (3/4)
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // Title
              Text(
                context.l10n.onboardingQuickWinTitle,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                context.l10n.onboardingQuickWinSubtitle,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Content
              Expanded(
                child: _isAnalyzing
                    ? _buildAnalyzingState()
                    : _quickWinInsight != null
                        ? _buildInsightCard()
                        : _buildEmptyState(),
              ),

              // Next button
              const SizedBox(height: 24),
              FilledButton(
                onPressed: !_isAnalyzing ? _onNextPressed : null,
                child: Text(context.l10n.next),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build progress indicator (3/4)
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
            color: index <= 2
                ? context.colors.primary
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Build analyzing state with loading indicator
  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 24),
          Text(
            context.l10n.analyzingWorkouts,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build insight card showing quick win
  Widget _buildInsightCard() {
    if (_quickWinInsight == null) return const SizedBox.shrink();

    final insight = _quickWinInsight!;

    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SemanticIcon(
                      icon: _getInsightIcon(insight.type),
                      semanticLabel: insight.title,
                      size: 40,
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  insight.title,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  insight.description,
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Recommendation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SemanticIcon(
                        icon: AppIcons.lightbulb,
                        semanticLabel: context.l10n.recommendation,
                        size: AppIconSize.medium,
                        color: context.colors.tertiary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight.recommendation,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state (no workouts to analyze)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.info,
            semanticLabel: context.l10n.noWorkoutsYet,
            size: 64,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.noWorkoutsYet,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.noWorkoutsYetDescription,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get icon for insight type
  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.muscleGroupBalance:
        return AppIcons.balance;
      case InsightType.progressOverload:
        return AppIcons.trendingUp;
      case InsightType.recoveryPattern:
        return AppIcons.timer;
      case InsightType.volumeOptimization:
        return AppIcons.trendingUp;
      case InsightType.frequencyRecommendation:
        return AppIcons.calendar;
      case InsightType.plateauBreaker:
        return AppIcons.trendingFlat;
      case InsightType.formWarning:
        return AppIcons.error;
      case InsightType.motivational:
        return AppIcons.stars;
      case InsightType.cnsFatigue:
        return AppIcons.warning;
      case InsightType.periodization:
        return AppIcons.calendar;
      case InsightType.mobility:
        return AppIcons.accessibility;
    }
  }

  /// Generate quick win insight based on user context
  void _generateQuickWinInsight() {
    // In production, this would analyze actual workout data
    // For onboarding, we show a generic insight based on experience level

    final insight = _getDefaultInsightForExperience();

    setState(() {
      _isAnalyzing = false;
      _quickWinInsight = insight;
    });
  }

  /// Get default insight based on experience level
  AIInsight _getDefaultInsightForExperience() {
    switch (widget.selectedExperience) {
      case ExperienceLevel.beginner:
        return AIInsight(
          id: 'onboarding-quick-win',
          type: InsightType.motivational,
          severity: InsightSeverity.low,
          title: context.l10n.beginnerQuickWinTitle,
          description: context.l10n.beginnerQuickWinDescription,
          recommendation: context.l10n.beginnerQuickWinRecommendation,
          timestamp: DateTime.now(),
          priority: 1,
        );

      case ExperienceLevel.intermediate:
        return AIInsight(
          id: 'onboarding-quick-win',
          type: InsightType.muscleGroupBalance,
          severity: InsightSeverity.medium,
          title: context.l10n.intermediateQuickWinTitle,
          description: context.l10n.intermediateQuickWinDescription,
          recommendation: context.l10n.intermediateQuickWinRecommendation,
          timestamp: DateTime.now(),
          priority: 2,
        );

      case ExperienceLevel.advanced:
        return AIInsight(
          id: 'onboarding-quick-win',
          type: InsightType.plateauBreaker,
          severity: InsightSeverity.critical,
          title: context.l10n.advancedQuickWinTitle,
          description: context.l10n.advancedQuickWinDescription,
          recommendation: context.l10n.advancedQuickWinRecommendation,
          timestamp: DateTime.now(),
          priority: 3,
        );
    }
  }

  /// Handle next button press
  void _onNextPressed() {
    // TODO: Navigate to OnboardingNotificationsScreen (Step 4)
    // TODO: Save quick win insight shown to provider
  }
}
