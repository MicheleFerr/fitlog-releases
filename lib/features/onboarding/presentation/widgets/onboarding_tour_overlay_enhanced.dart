import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_tour_manager.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/dynamic_spotlight_overlay.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/tour_bottom_sheet.dart';

/// Enhanced onboarding tour overlay using advanced positioning system
///
/// This is the new implementation that uses:
///   - OnboardingTourManager for state management and auto-scrolling
///   - DynamicSpotlightOverlay for animated spotlight effect
///   - GlobalPaintBoundsExtension for precise coordinate calculations
///   - SpotlightPositioningUtil for centering and validation
///
/// Improvements over original OnboardingTourOverlay:
///   - Auto-centering with calculated offsets
///   - More reliable bounds detection
///   - Better animation control
///   - Built-in error handling for missing widgets
class OnboardingTourOverlayEnhanced extends StatefulWidget {
  const OnboardingTourOverlayEnhanced({
    required this.manager,
    super.key,
  });

  /// Tour manager that handles state and positioning
  final OnboardingTourManager manager;

  @override
  State<OnboardingTourOverlayEnhanced> createState() =>
      _OnboardingTourOverlayEnhancedState();
}

class _OnboardingTourOverlayEnhancedState
    extends State<OnboardingTourOverlayEnhanced> {
  @override
  void initState() {
    super.initState();
    // Listen to manager state changes
    widget.manager.addListener(_onManagerStateChanged);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerStateChanged);
    super.dispose();
  }

  /// Rebuilds when manager state changes
  void _onManagerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show overlay if tour is not active
    if (!widget.manager.isActive) {
      return const SizedBox.shrink();
    }

    // Get current spotlight bounds from manager
    final spotlightBounds = widget.manager.currentSpotlightBounds;
    final spotlightOffset = widget.manager.currentSpotlightOffset;

    // If bounds not yet calculated, show nothing
    if (spotlightBounds == null) {
      debugPrint(
        '⚠️ [OnboardingTourOverlayEnhanced] Waiting for spotlight bounds...',
      );
      return const SizedBox.shrink();
    }

    // Get current step for bottom sheet
    final currentStep = widget.manager.currentStep;

    debugPrint(
      '✅ [OnboardingTourOverlayEnhanced] Rendering spotlight '
      'at: $spotlightBounds with offset: $spotlightOffset',
    );

    return DynamicSpotlightOverlay(
      spotlightBounds: spotlightBounds,
      offset: spotlightOffset,
      minOpacity: 0.4,
      maxOpacity: 0.8,
      animationDuration: const Duration(milliseconds: 800),
      spotlightBorderRadius: 12.0,
      spotlightPadding: 12.0,
      overlayColor: Colors.black.withValues(alpha: 0.8),
      child: TourBottomSheet(step: currentStep, manager: widget.manager),
    );
  }
}
