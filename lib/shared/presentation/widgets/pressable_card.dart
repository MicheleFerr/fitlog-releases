import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Reusable wrapper widget that provides minimal flat card styling with
/// standardized press animations and haptic feedback.
///
/// Features:
/// - Minimal flat design (no glassmorphism/blur)
/// - Scale animation on press (0.97x)
/// - Optional accent color overlay (8% opacity)
/// - Optional accent color border (30% opacity)
/// - Haptic feedback on press
/// - Theme-aware colors
///
/// Usage:
/// ```dart
/// PressableCard(
///   accentColor: Colors.purple,
///   onTap: () => context.goNamed('analytics'),
///   child: Column(
///     children: [
///       Icon(AppIcons.analytics),
///       Text('Analytics'),
///     ],
///   ),
/// )
/// ```
class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.accentColor,
    this.showBorder = false,
    this.enableHaptics = true,
  });

  /// Content to display inside the card
  final Widget child;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Accent color for pressed state (overlay, border, etc.)
  /// If null, uses theme primary color
  final Color? accentColor;

  /// Whether to show accent color border on press
  final bool showBorder;

  /// Enable haptic feedback on press
  final bool enableHaptics;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Single animation controller for scale
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standard,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.cardPressScale,
    ).animate(_curvedAnimation);
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final effectiveAccentColor = widget.accentColor ?? colorScheme.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          curve: AppAnimations.standard,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: _isPressed && widget.showBorder
                ? Border.all(
                    color: effectiveAccentColor.withValues(
                      alpha: AppAnimations.pressedBorderOpacity,
                    ),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Child content
              widget.child,

              // Overlay when pressed
              if (_isPressed)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: AppAnimations.fast,
                    curve: AppAnimations.standard,
                    decoration: BoxDecoration(
                      color: effectiveAccentColor.withValues(
                        alpha: AppAnimations.pressOverlayOpacity,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
