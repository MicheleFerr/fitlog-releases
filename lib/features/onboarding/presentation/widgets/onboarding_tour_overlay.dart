import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_tour_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/spotlight_overlay.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/tour_bottom_sheet.dart';

/// Main overlay widget for the onboarding tour
///
/// Displays a spotlight effect on the target widget with a bottom sheet
/// containing step information and navigation controls.
///
/// This widget should be placed as an Overlay in the widget tree,
/// typically in a Stack above the main content.
class OnboardingTourOverlay extends ConsumerStatefulWidget {
  const OnboardingTourOverlay({
    required this.targetKeys,
    super.key,
  });

  /// Map of target widget keys for each tour step
  /// Key = step ID (e.g., 'aiCoach', 'fab', etc.)
  /// Value = GlobalKey for the widget
  final Map<String, GlobalKey> targetKeys;

  @override
  ConsumerState<OnboardingTourOverlay> createState() => _OnboardingTourOverlayState();
}

class _OnboardingTourOverlayState extends ConsumerState<OnboardingTourOverlay> {
  int? _previousStepPosition;

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(onboardingTourProvider);

    // Don't show overlay if tour is not active
    if (!tourState.isActive) {
      _previousStepPosition = null;
      return const SizedBox.shrink();
    }

    final currentStep = tourState.currentStep;
    final targetKey = widget.targetKeys[currentStep.id];

    // If target key not found, skip this step
    if (targetKey == null) {
      // Auto-advance to next step
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(onboardingTourProvider.notifier).nextStep();
      });
      return const SizedBox.shrink();
    }

    // Auto-scroll to target widget when step changes
    if (_previousStepPosition != tourState.currentStepPosition) {
      _previousStepPosition = tourState.currentStepPosition;
      _ensureTargetVisible(targetKey);
    }

    return SpotlightOverlay(
      targetKey: targetKey,
      child: TourBottomSheet(step: currentStep),
    );
  }

  /// Ensure target widget is visible in viewport
  void _ensureTargetVisible(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context == null || !mounted) return;

      // Ensure widget is scrolled into view (centered in viewport)
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    });
  }
}
