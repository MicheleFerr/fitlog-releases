import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// A contextual menu that appears anchored to a target widget using LayerLink.
///
/// Features:
/// - Uses LayerLink for precise positioning that follows the target
/// - Automatically dismisses on tap outside
/// - Supports custom menu items with icons and actions
/// - Smooth entrance/exit animations
/// - Theme-aware styling
///
/// Example usage:
/// ```dart
/// final LayerLink _menuLink = LayerLink();
/// OverlayEntry? _menuOverlay;
///
/// // Wrap target with CompositedTransformTarget
/// CompositedTransformTarget(
///   link: _menuLink,
///   child: GestureDetector(
///     onLongPress: () => _showContextMenu(),
///     child: YourWidget(),
///   ),
/// )
///
/// void _showContextMenu() {
///   _menuOverlay = ContextualMenuOverlay.show(
///     context: context,
///     link: _menuLink,
///     items: [
///       ContextualMenuItem(
///         icon: AppIcons.edit,
///         label: 'Edit',
///         onTap: () => _handleEdit(),
///       ),
///       ContextualMenuItem(
///         icon: AppIcons.delete,
///         label: 'Delete',
///         color: context.colors.error,
///         onTap: () => _handleDelete(),
///       ),
///     ],
///     onDismiss: () => _menuOverlay = null,
///   );
/// }
/// ```
class ContextualMenuOverlay extends StatefulWidget {
  const ContextualMenuOverlay({
    super.key,
    required this.link,
    required this.items,
    required this.onDismiss,
    this.targetAnchor = Alignment.centerRight,
    this.followerAnchor = Alignment.centerLeft,
    this.offset = const Offset(8, 0),
    this.width = 180,
    this.backgroundColor,
    this.elevation = 8,
  });

  /// The LayerLink connected to the target widget
  final LayerLink link;

  /// Menu items to display
  final List<ContextualMenuItem> items;

  /// Callback when menu is dismissed
  final VoidCallback onDismiss;

  /// Where on the target widget to anchor (default: centerRight)
  final Alignment targetAnchor;

  /// Where on the menu to attach to target (default: centerLeft)
  final Alignment followerAnchor;

  /// Additional offset from anchor point
  final Offset offset;

  /// Menu width (default: 180)
  final double width;

  /// Background color (defaults to surface color)
  final Color? backgroundColor;

  /// Shadow elevation (default: 8)
  final double elevation;

  /// Shows the contextual menu and returns the OverlayEntry
  ///
  /// Remember to call entry.remove() to dismiss, or use onDismiss callback
  static OverlayEntry show({
    required BuildContext context,
    required LayerLink link,
    required List<ContextualMenuItem> items,
    required VoidCallback onDismiss,
    Alignment targetAnchor = Alignment.centerRight,
    Alignment followerAnchor = Alignment.centerLeft,
    Offset offset = const Offset(8, 0),
    double width = 180,
    Color? backgroundColor,
    double elevation = 8,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => ContextualMenuOverlay(
        link: link,
        items: items,
        onDismiss: onDismiss,
        targetAnchor: targetAnchor,
        followerAnchor: followerAnchor,
        offset: offset,
        width: width,
        backgroundColor: backgroundColor,
        elevation: elevation,
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }

  @override
  State<ContextualMenuOverlay> createState() => _ContextualMenuOverlayState();
}

class _ContextualMenuOverlayState extends State<ContextualMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.translucent,
      child: ColoredBox(
        color: Colors.transparent,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: widget.link,
              targetAnchor: widget.targetAnchor,
              followerAnchor: widget.followerAnchor,
              offset: widget.offset,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: widget.followerAnchor,
                  child: Material(
                    elevation: widget.elevation,
                    borderRadius: BorderRadius.circular(12),
                    color: widget.backgroundColor ?? context.colors.surface,
                    child: Container(
                      width: widget.width,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < widget.items.length; i++) ...[
                            _ContextualMenuItemWidget(
                              item: widget.items[i],
                              onTap: () {
                                widget.items[i].onTap();
                                _dismiss();
                              },
                            ),
                            if (widget.items[i].showDivider &&
                                i < widget.items.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: context.colors.outlineVariant,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single item in a contextual menu
class ContextualMenuItem {
  const ContextualMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showDivider = false,
  });

  /// Icon to display
  final IconData icon;

  /// Label text
  final String label;

  /// Action when tapped
  final VoidCallback onTap;

  /// Optional color override (e.g., red for delete)
  final Color? color;

  /// Whether to show a divider after this item
  final bool showDivider;
}

class _ContextualMenuItemWidget extends StatelessWidget {
  const _ContextualMenuItemWidget({
    required this.item,
    required this.onTap,
  });

  final ContextualMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = item.color ?? context.colors.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: effectiveColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
