/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// STEP INDICATOR WIDGET - Multi-Step Progress Indicator
///
/// Features:
/// - Display current step and total steps
/// - Visual step dots (completed, current, upcoming)
/// - Descriptive text (e.g., "Step 1 of 2")
/// - Theme-aware colors
/// - Material 3 design system compliance
/// - Used in RoutineCreationStep1Screen and RoutineCreationStep2Screen
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Step Indicator - Show progress through multi-step wizard
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  }) : assert(currentStep >= 1 && currentStep <= totalSteps, 'currentStep must be between 1 and totalSteps');

  /// Current step number (1-indexed)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step dots row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalSteps,
            (index) {
              final stepNumber = index + 1;
              return _StepDot(
                stepNumber: stepNumber,
                currentStep: currentStep,
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Step text (e.g., "Step 1 of 2")
        Text(
          '${context.l10n.step} $currentStep ${context.l10n.outOf} $totalSteps',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Individual step dot widget
class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.stepNumber,
    required this.currentStep,
  });

  final int stepNumber;
  final int currentStep;

  /// Step state: completed, current, or upcoming
  StepState get state {
    if (stepNumber < currentStep) return StepState.completed;
    if (stepNumber == currentStep) return StepState.current;
    return StepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == StepState.completed;
    final isCurrent = state == StepState.current;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: isCurrent ? 32 : 24,
        height: isCurrent ? 32 : 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted || isCurrent
              ? context.colors.primary
              : context.colors.surfaceContainerHighest,
          border: isCurrent
              ? Border.all(
                  color: context.colors.primary,
                  width: 2,
                )
              : null,
        ),
        child: Center(
          child: isCompleted
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: context.colors.onPrimary,
                )
              : Text(
                  stepNumber.toString(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isCurrent
                        ? context.colors.onPrimary
                        : context.colors.onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Step state enum
enum StepState {
  /// Step is completed (before current)
  completed,

  /// Step is current (active)
  current,

  /// Step is upcoming (after current)
  upcoming,
}
