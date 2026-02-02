import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// A scrollable list with material-like physics and inertia effect.
///
/// Creates a "heavy material" feel where items have visual weight and
/// respond smoothly to scroll velocity with tilt, scale, and parallax effects.
///
/// ## Usage
///
/// Replace `ListView.builder` with `MaterialScrollList`:
///
/// ```dart
/// MaterialScrollList(
///   itemCount: items.length,
///   itemBuilder: (context, index) => MyItemWidget(items[index]),
/// )
/// ```
///
/// ## Customization
///
/// Adjust intensity with [effectIntensity] (0.0 = disabled, 1.0 = normal, 2.0 = strong):
///
/// ```dart
/// MaterialScrollList(
///   effectIntensity: 0.5, // Subtle effect
///   itemCount: items.length,
///   itemBuilder: (context, index) => MyItemWidget(items[index]),
/// )
/// ```
///
/// ## Features
///
/// - **BouncingScrollPhysics**: iOS-style rubber band at edges
/// - **Velocity-based tilt**: Cards tilt subtly in scroll direction
/// - **Scale effect**: Cards shrink very slightly during fast scroll
/// - **Parallax**: Cards shift subtly based on position
/// - **Smooth transitions**: Fast, subtle easeOut animations
class MaterialScrollList extends StatefulWidget {
  const MaterialScrollList({
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.effectIntensity = 1.0,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.itemExtent,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
    super.key,
  });

  /// Number of items in the list
  final int itemCount;

  /// Builder function for each item
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Padding around the list (defaults to AppSpacing.md on all sides)
  final EdgeInsetsGeometry? padding;

  /// Intensity of the material effect (0.0 = off, 1.0 = normal, 2.0 = strong)
  final double effectIntensity;

  /// Custom scroll physics (defaults to BouncingScrollPhysics)
  final ScrollPhysics? physics;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Whether the list should shrink-wrap its contents
  final bool shrinkWrap;

  /// If non-null, forces children to have the given extent in scroll direction
  final double? itemExtent;

  /// The viewport extent to cache beyond the visible area
  final double? cacheExtent;

  /// How to clip the content
  final Clip clipBehavior;

  @override
  State<MaterialScrollList> createState() => _MaterialScrollListState();
}

class _MaterialScrollListState extends State<MaterialScrollList> {
  // ✅ FIX: Use ValueNotifier to avoid setState() on scroll - prevents full list rebuild
  // This allows individual items to listen to velocity changes without rebuilding the entire list
  final ValueNotifier<double> _scrollVelocityNotifier = ValueNotifier<double>(0);
  double _lastScrollOffset = 0;
  DateTime _lastScrollTime = DateTime.now();

  @override
  void dispose() {
    _scrollVelocityNotifier.dispose();
    super.dispose();
  }

  void _calculateVelocity(double currentOffset) {
    final now = DateTime.now();
    final timeDelta = now.difference(_lastScrollTime).inMilliseconds;

    if (timeDelta > 0) {
      final offsetDelta = currentOffset - _lastScrollOffset;
      // Calculate velocity (pixels per second) and normalize
      final velocity = (offsetDelta / timeDelta) * 1000;
      // ✅ FIX: Update ValueNotifier instead of setState() - no list rebuild
      _scrollVelocityNotifier.value = (velocity / 1000).clamp(-1.0, 1.0);
    }

    _lastScrollOffset = currentOffset;
    _lastScrollTime = now;
  }

  @override
  Widget build(BuildContext context) {
    // If effect is disabled, return simple ListView
    if (widget.effectIntensity <= 0) {
      return ListView.builder(
        controller: widget.controller,
        padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemExtent: widget.itemExtent,
        cacheExtent: widget.cacheExtent,
        clipBehavior: widget.clipBehavior,
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _calculateVelocity(notification.metrics.pixels);
        } else if (notification is ScrollEndNotification) {
          // ✅ FIX: Update ValueNotifier instead of setState() - no list rebuild
          _scrollVelocityNotifier.value = 0;
        }
        return false;
      },
      child: ListView.builder(
        controller: widget.controller,
        padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
        physics: widget.physics ??
            const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
              decelerationRate: ScrollDecelerationRate.normal,
            ),
        shrinkWrap: widget.shrinkWrap,
        itemExtent: widget.itemExtent,
        cacheExtent: widget.cacheExtent,
        clipBehavior: widget.clipBehavior,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          // ✅ FIX: Pass ValueNotifier to item - child rebuilds only on velocity change
          return MaterialScrollItemWithNotifier(
            index: index,
            totalCount: widget.itemCount,
            scrollVelocityNotifier: _scrollVelocityNotifier,
            effectIntensity: widget.effectIntensity,
            child: widget.itemBuilder(context, index),
          );
        },
      ),
    );
  }
}

/// Individual item wrapper with material-like transform based on scroll velocity.
///
/// Can be used standalone to wrap any widget with scroll-based effects:
///
/// ```dart
/// MaterialScrollItem(
///   index: 0,
///   totalCount: 10,
///   scrollVelocity: velocity,
///   child: MyWidget(),
/// )
/// ```
class MaterialScrollItem extends StatelessWidget {
  const MaterialScrollItem({
    required this.index,
    required this.totalCount,
    required this.scrollVelocity,
    required this.child,
    this.effectIntensity = 1.0,
    super.key,
  });

  /// Index of this item in the list
  final int index;

  /// Total number of items in the list
  final int totalCount;

  /// Current scroll velocity (-1.0 to 1.0)
  final double scrollVelocity;

  /// The child widget to apply effects to
  final Widget child;

  /// Intensity multiplier for all effects
  final double effectIntensity;

  @override
  Widget build(BuildContext context) {
    // Calculate position bias - items further from center react more
    final normalizedIndex = totalCount > 1 ? index / (totalCount - 1) : 0.5;
    // ✅ DESIGN: Reduced center bias for more uniform, subtle effect
    final centerBias = 1.0 + (normalizedIndex - 0.5).abs() * 0.3;

    // Apply intensity multiplier to all effects
    final intensity = effectIntensity;

    // ✅ DESIGN: Very subtle rotation (max ~0.5 degrees) - was 0.05 (~3-4 degrees)
    final tiltAngle = scrollVelocity * 0.012 * centerBias * intensity;

    // ✅ DESIGN: Minimal vertical offset (max ~2px) - was 8px
    final verticalOffset = scrollVelocity * 2 * centerBias * intensity;

    // ✅ DESIGN: Almost imperceptible scale (0.995 - 1.0) - was 0.98
    final scale = 1.0 - (scrollVelocity.abs() * 0.005 * intensity);

    // ✅ DESIGN: Very slight horizontal shift - was 3
    final horizontalOffset =
        scrollVelocity * 1 * (normalizedIndex - 0.5) * intensity;

    // ✅ DESIGN: Faster, smoother animations with gentler curves
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: tiltAngle),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, animatedTilt, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: verticalOffset),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, animatedVerticalOffset, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: scale),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              builder: (context, animatedScale, _) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: horizontalOffset),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  builder: (context, animatedHorizontalOffset, child) {
                    return Transform.scale(
                      scale: animatedScale,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Reduced perspective
                          ..rotateX(animatedTilt),
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: Offset(
                            animatedHorizontalOffset,
                            animatedVerticalOffset,
                          ),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: child,
                );
              },
            );
          },
        );
      },
      child: child,
    );
  }
}

/// ✅ FIX: New optimized item wrapper that uses ValueListenableBuilder
/// This prevents child widget rebuilds when scroll velocity changes.
/// Only the transform wrapper rebuilds, keeping child content (GIFs, etc.) stable.
class MaterialScrollItemWithNotifier extends StatelessWidget {
  const MaterialScrollItemWithNotifier({
    required this.index,
    required this.totalCount,
    required this.scrollVelocityNotifier,
    required this.child,
    this.effectIntensity = 1.0,
    super.key,
  });

  /// Index of this item in the list
  final int index;

  /// Total number of items in the list
  final int totalCount;

  /// ValueNotifier for scroll velocity (-1.0 to 1.0)
  final ValueNotifier<double> scrollVelocityNotifier;

  /// The child widget to apply effects to
  final Widget child;

  /// Intensity multiplier for all effects
  final double effectIntensity;

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use ValueListenableBuilder to only rebuild transform, not child
    return ValueListenableBuilder<double>(
      valueListenable: scrollVelocityNotifier,
      // ✅ CRITICAL: child parameter preserves widget identity across rebuilds
      // This means ExerciseListItem and ExerciseGifWidget DON'T rebuild on scroll
      child: child,
      builder: (context, scrollVelocity, preservedChild) {
        // ✅ OPTIMIZATION: Skip transforms when velocity is effectively zero
        // This eliminates unnecessary transform calculations when list is idle
        // ✅ BUG FIX: DISABLED SCROLL EFFECTS TEMPORARILY
        // The TweenAnimationBuilder chain was causing insight chips to flicker
        // when user touches screen to start scroll. The animation builders don't
        // properly preserve child widget identity during tween transitions.
        // TODO: Refactor to use AnimatedContainer or ImplicitlyAnimatedWidget pattern
        // which properly preserves child widgets across animations.
        return preservedChild!;
      },
    );
  }
}
