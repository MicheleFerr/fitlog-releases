import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';

/// TODO: Implement GoalsStep widget
/// This is a placeholder to fix compilation errors
class GoalsStep extends StatelessWidget {

  const GoalsStep({
    super.key,
    required this.selectedGoals,
    required this.onGoalsChanged,
    required this.onNext,
    required this.onBack,
  });
  final List<WorkoutGoal> selectedGoals;
  final void Function(List<WorkoutGoal>) onGoalsChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('TODO: GoalsStep implementation'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
