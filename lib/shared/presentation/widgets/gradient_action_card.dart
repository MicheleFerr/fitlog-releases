import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/animated_icon_swap.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Gradient action card with personality and accessibility
///
/// Features:
/// - Radial gradient background (WCAG AA compliant)
/// - Centered icon + title layout
/// - Press animations (scale 0.97, 150ms)
/// - Staggered icon animation (100ms)
/// - Haptic feedback
/// - Reduced motion support (MediaQuery.disableAnimations)
/// - Memory leak prevention (dispose lifecycle)
/// - Impeller-safe shadow animation (alpha-only)
///
/// Usage:
/// ```dart
/// GradientActionCard(
///   outlinedIcon: AppAppIcons.analytics,
///   filledIcon: AppAppIcons.analyticsRounded,
///   title: context.l10n.analytics,
///   gradient: RadialGradient(...),
///   accentColor: theme.colorScheme.primary,
///   onTap: () => context.goNamed('analytics'),
/// )
/// ```
class GradientActionCard extends StatefulWidget {
  const GradientActionCard({
    super.key,
    required this.outlinedIcon,
    required this.filledIcon,
    required this.title,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
  });

  /// Outlined icon variant (shown when not pressed)
  final IconData outlinedIcon;

  /// Filled icon variant (shown when pressed)
  final IconData filledIcon;

  /// Card title (centered below icon)
  final String title;

  /// Radial gradient for card background
  final RadialGradient gradient;

  /// Accent color for shadow and ripple
  final Color accentColor;

  /// Callback when card is tapped
  final VoidCallback onTap;

  @override
  State<GradientActionCard> createState() => _GradientActionCardState();
}

class _GradientActionCardState extends State<GradientActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  bool _prefersReducedMotion = false;

  @override
  void initState() {
    super.initState();

    // Check accessibility preference
    _prefersReducedMotion = MediaQuery.of(context).disableAnimations;

    // Single controller for performance (SingleTickerProviderStateMixin)
    _controller = AnimationController(
      duration: _prefersReducedMotion
          ? Duration.zero
          : AppAnimations.fast, // 150ms
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.cardPressScale, // 0.97
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.standard, // Curves.easeOut
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ CRITICAL: prevent memory leak
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!_prefersReducedMotion) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (!_prefersReducedMotion) {
      _controller.reverse();
    }
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (!_prefersReducedMotion) {
      _controller.reverse();
    }
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(
                  alpha: _isPressed ? 0.15 : 0.25, // Alpha-only (Impeller-safe)
                ),
                blurRadius: 10, // Static blur (no animation)
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: widget.accentColor.withValues(
                alpha: 0.2,
              ), // Theme-aware
              highlightColor: widget.accentColor.withValues(alpha: 0.1),
              child: Stack(
                children: [
                  // Content - Positioned.fill ensures proper centering
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        // Icon with animation (uses AppAnimations.iconSwap internally)
                        AnimatedIconSwap(
                          outlinedIcon: widget.outlinedIcon,
                          filledIcon: widget.filledIcon,
                          isPressed: _isPressed,
                          color: context.colors.surface,
                          size: 48,
                        ),

                        const SizedBox(height: 16),

                        // Title (centered)
                        Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.surface,
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                  // Overlay when pressed
                  if (_isPressed)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
