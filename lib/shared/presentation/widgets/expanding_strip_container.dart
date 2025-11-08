import 'package:flutter/material.dart';

/// Container with animated expanding left strip
///
/// **Core Responsibilities**:
/// - Receive Animation<double> from parent (InteractiveElement)
/// - Create derived stripAnimation in initState() (ONCE)
/// - Render strip + child with synchronized animations
///
/// **Pattern**: StatefulWidget (Opzione B) to prevent rebuild stutters.
/// The stripAnimation is created ONCE in initState() by wrapping the parent
/// animation with CurvedAnimation. This ensures frame-perfect synchronization
/// with the parent's scale animation.
///
/// **Why StatefulWidget?**
/// If this were StatelessWidget, the Tween would be recreated on every rebuild,
/// causing frame skips and stutters. StatefulWidget creates the animation ONCE
/// in initState(), ensuring smooth 60fps animation.
///
/// **Usage**:
/// ```dart
/// InteractiveElement(
///   builder: (context, animation) {
///     return ExpandingStripContainer(
///       animation: animation,  // ← From InteractiveElement
///       stripColor: context.colors.primary,
///       child: CardContent(),
///     );
///   },
/// )
/// ```
class ExpandingStripContainer extends StatefulWidget {
  const ExpandingStripContainer({
    super.key,
    required this.animation,
    required this.child,
    required this.stripColor,
    this.stripWidthCollapsed = 2.0,
    this.stripWidthExpanded = 4.0,
  });

  /// Animation from parent InteractiveElement
  ///
  /// This is the AnimationController from InteractiveElement,
  /// passed via builder pattern. We derive our stripAnimation
  /// from this to ensure perfect synchronization.
  final Animation<double> animation;

  /// Child widget (card content, button content, etc.)
  final Widget child;

  /// Strip color (category color, brand color, etc.)
  final Color stripColor;

  /// Strip width when collapsed (default: 2.0)
  final double stripWidthCollapsed;

  /// Strip width when expanded on press (default: 4.0)
  final double stripWidthExpanded;

  @override
  State<ExpandingStripContainer> createState() =>
      _ExpandingStripContainerState();
}

class _ExpandingStripContainerState extends State<ExpandingStripContainer> {
  late Animation<double> _stripAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ CRITICAL: Create animation ONCE, derived from parent animation
    // CurvedAnimation is a LISTENER, not a controller
    // This wraps the parent animation with a curve, ensuring perfect sync
    _stripAnimation = Tween<double>(
      begin: widget.stripWidthCollapsed,
      end: widget.stripWidthExpanded,
    ).animate(
      CurvedAnimation(
        parent: widget.animation, // ← Parent animation from InteractiveElement
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didUpdateWidget(ExpandingStripContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recreate stripAnimation if widths changed
    if (oldWidget.stripWidthCollapsed != widget.stripWidthCollapsed ||
        oldWidget.stripWidthExpanded != widget.stripWidthExpanded ||
        oldWidget.animation != widget.animation) {
      _stripAnimation = Tween<double>(
        begin: widget.stripWidthCollapsed,
        end: widget.stripWidthExpanded,
      ).animate(
        CurvedAnimation(
          parent: widget.animation,
          curve: Curves.easeOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    // ✅ CRITICAL: NO dispose of _stripAnimation
    // It's managed by the parent AnimationController in InteractiveElement
    // Disposing it here would cause errors since the parent still owns it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Animated strip (2pt → 4pt on press)
        AnimatedBuilder(
          animation: _stripAnimation,
          builder: (context, _) => Container(
            width: _stripAnimation.value,
            color: widget.stripColor,
            // Match parent container's border radius
            decoration: BoxDecoration(
              color: widget.stripColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
        ),

        // Child content (card, button, etc.)
        Expanded(child: widget.child),
      ],
    );
  }
}
