import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';

/// Animated icon widget that smoothly transitions between outlined and filled
/// variants based on press state.
///
/// Uses [AnimatedSwitcher] with [ScaleTransition] for smooth swap animation.
///
/// Usage:
/// ```dart
/// AnimatedIconSwap(
///   outlinedIcon: Icons.analytics_outlined,
///   filledIcon: Icons.analytics,
///   isPressed: _isPressed,
///   color: Colors.purple,
///   size: 28,
/// )
/// ```
class AnimatedIconSwap extends StatelessWidget {
  const AnimatedIconSwap({
    super.key,
    required this.outlinedIcon,
    required this.filledIcon,
    required this.isPressed,
    this.color,
    this.size,
  });

  /// Outlined icon variant (shown when not pressed)
  final IconData outlinedIcon;

  /// Filled icon variant (shown when pressed)
  final IconData filledIcon;

  /// Whether the icon should show filled variant
  final bool isPressed;

  /// Icon color (optional)
  final Color? color;

  /// Icon size (optional, defaults to theme size)
  final double? size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimations.iconSwap,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: Icon(
        isPressed ? filledIcon : outlinedIcon,
        key: ValueKey(isPressed),
        color: color,
        size: size ?? AppAnimations.iconSizeMedium,
      ),
    );
  }
}
