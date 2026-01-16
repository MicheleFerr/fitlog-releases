/// Shared Expandable Card Widget
///
/// Provides a consistent expandable card pattern with app-specific styling.
/// Wraps Flutter's ExpansionTile with design system compliance.
///
/// ## Usage
/// ```dart
/// SharedExpandableCard(
///   title: Text('My Section'),
///   subtitle: Text('3 items'),
///   leading: Icon(AppIcons.list),
///   trailing: StatusBadge('Active'),
///   initiallyExpanded: false,
///   children: [
///     ListTile(title: Text('Item 1')),
///     ListTile(title: Text('Item 2')),
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Configuration for the expandable card appearance
enum ExpandableCardStyle {
  /// Standard card with surface background
  standard,

  /// Elevated card with shadow
  elevated,

  /// Outlined card with border
  outlined,

  /// Filled card with primary color tint
  filled,
}

/// Shared expandable card widget with consistent design system styling
class SharedExpandableCard extends StatefulWidget {
  const SharedExpandableCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.children = const [],
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.style = ExpandableCardStyle.standard,
    this.maintainState = false,
    this.expandedCrossAxisAlignment = CrossAxisAlignment.center,
    this.childrenPadding,
    this.enableHapticFeedback = true,
    this.collapsedBackgroundColor,
    this.expandedBackgroundColor,
    this.iconColor,
    this.borderRadius,
    this.contentPadding,
  });

  /// The primary title widget
  final Widget title;

  /// Optional subtitle widget
  final Widget? subtitle;

  /// Optional leading widget (icon, avatar, etc.)
  final Widget? leading;

  /// Optional trailing widget (badge, icon, etc.)
  /// This appears before the expand/collapse icon
  final Widget? trailing;

  /// Children widgets shown when expanded
  final List<Widget> children;

  /// Whether the card starts expanded
  final bool initiallyExpanded;

  /// Callback when expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Visual style of the card
  final ExpandableCardStyle style;

  /// Whether to maintain state when off-screen
  final bool maintainState;

  /// Cross axis alignment for children
  final CrossAxisAlignment expandedCrossAxisAlignment;

  /// Padding around children
  final EdgeInsetsGeometry? childrenPadding;

  /// Whether to provide haptic feedback on tap
  final bool enableHapticFeedback;

  /// Background color when collapsed
  final Color? collapsedBackgroundColor;

  /// Background color when expanded
  final Color? expandedBackgroundColor;

  /// Color of the expand/collapse icon
  final Color? iconColor;

  /// Border radius of the card
  final BorderRadius? borderRadius;

  /// Padding for the title/leading/trailing area
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<SharedExpandableCard> createState() => _SharedExpandableCardState();
}

class _SharedExpandableCardState extends State<SharedExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SharedExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded) {
      _setExpanded(widget.initiallyExpanded);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool expanded) {
    setState(() {
      _isExpanded = expanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);

    // Style-specific properties
    BoxDecoration decoration;
    switch (widget.style) {
      case ExpandableCardStyle.standard:
        decoration = BoxDecoration(
          color: widget.collapsedBackgroundColor ?? colorScheme.surface,
          borderRadius: borderRadius,
        );
      case ExpandableCardStyle.elevated:
        decoration = BoxDecoration(
          color: widget.collapsedBackgroundColor ?? colorScheme.surface,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case ExpandableCardStyle.outlined:
        decoration = BoxDecoration(
          color: widget.collapsedBackgroundColor ?? colorScheme.surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        );
      case ExpandableCardStyle.filled:
        decoration = BoxDecoration(
          color: widget.collapsedBackgroundColor ??
              colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: borderRadius,
        );
    }

    return DecoratedBox(
      decoration: decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: _handleTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Leading
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DefaultTextStyle(
                          style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ) ??
                              const TextStyle(),
                          child: widget.title,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          DefaultTextStyle(
                            style: context.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ) ??
                                const TextStyle(),
                            child: widget.subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Trailing
                  if (widget.trailing != null) ...[
                    widget.trailing!,
                    const SizedBox(width: 8),
                  ],
                  // Expand icon
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      AppIcons.expandMore,
                      color: widget.iconColor ?? colorScheme.onSurfaceVariant,
                      size: AppIconSize.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Animated content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: widget.childrenPadding ??
                        const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                    child: Column(
                      crossAxisAlignment: widget.expandedCrossAxisAlignment,
                      children: widget.children,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Simple expandable section (no card styling)
///
/// For use within existing containers or lists
class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.titleStyle,
    this.dividerColor,
  });

  final String title;
  final Widget? trailing;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final TextStyle? titleStyle;
  final Color? dividerColor;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: widget.titleStyle ??
                        context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (widget.trailing != null) ...[
                  widget.trailing!,
                  const SizedBox(width: 8),
                ],
                RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    AppIcons.expandMore,
                    color: colorScheme.onSurfaceVariant,
                    size: AppIconSize.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.dividerColor != null)
          Divider(color: widget.dividerColor, height: 1),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded ? widget.child : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
