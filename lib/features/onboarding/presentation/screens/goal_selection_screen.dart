import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/user_goal.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// P4 Onboarding: Goal Selection Screen
///
/// First step in retention-focused onboarding flow
/// Lets user choose primary fitness goal
/// Part of P4 (+10-15% completion improvement)
class GoalSelectionScreen extends ConsumerWidget {
  const GoalSelectionScreen({
    this.onGoalSelected,
    super.key,
  });

  final void Function(GoalType goal)? onGoalSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'What is your goal?',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your primary fitness objective',
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            _buildGoalButton(
              context,
              ref,
              'Build Muscle',
              GoalType.buildMuscle,
            ),
            const SizedBox(height: 16),
            _buildGoalButton(
              context,
              ref,
              'Lose Weight',
              GoalType.loseWeight,
            ),
            const SizedBox(height: 16),
            _buildGoalButton(
              context,
              ref,
              'Get Stronger',
              GoalType.getStronger,
            ),
            const SizedBox(height: 16),
            _buildGoalButton(
              context,
              ref,
              'Stay Fit',
              GoalType.stayFit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    GoalType goalType,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          // Map GoalType enum to string
          final goalString = _mapGoalTypeToString(goalType);

          // Get default weekly workout target based on goal
          final weeklyTarget = _getDefaultWeeklyTarget(goalType);

          // Save goal selection to OnboardingState via provider
          await ref.read(onboardingStateProvider.notifier).selectGoal(
                goalString,
                weeklyTarget,
              );

          // Call optional callback for custom handling
          onGoalSelected?.call(goalType);
        },
        child: Text(label),
      ),
    );
  }

  /// Map GoalType enum to string format for storage
  String _mapGoalTypeToString(GoalType goalType) {
    switch (goalType) {
      case GoalType.buildMuscle:
        return 'buildMuscle';
      case GoalType.loseWeight:
        return 'loseWeight';
      case GoalType.getStronger:
        return 'getStronger';
      case GoalType.stayFit:
        return 'stayFit';
    }
  }

  /// Get default weekly workout target based on goal type
  /// Evidence-based defaults from fitness research
  int _getDefaultWeeklyTarget(GoalType goalType) {
    switch (goalType) {
      case GoalType.buildMuscle:
        return 4; // Hypertrophy optimal: 4-5x/week
      case GoalType.loseWeight:
        return 4; // Fat loss optimal: 4-5x/week with deficit
      case GoalType.getStronger:
        return 3; // Strength optimal: 3-4x/week with recovery
      case GoalType.stayFit:
        return 3; // General fitness: 3x/week minimum
    }
  }
}
