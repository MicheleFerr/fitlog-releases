/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: shared
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Premium action button per sostituire i FAB extended brutti
/// Design Tier 1 con animazioni fluide
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class PremiumActionButton extends StatefulWidget {
  
  const PremiumActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.isCompact = false,
    this.showShadow = true,
    this.width,
    this.isHighlightedInTour = false,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isCompact;
  final bool showShadow;
  final double? width;
  final bool isHighlightedInTour;
  
  @override
  State<PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<PremiumActionButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Press animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Tour highlight pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse if highlighted in tour
    if (widget.isHighlightedInTour) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start/stop pulse based on highlight state
    if (widget.isHighlightedInTour && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isHighlightedInTour && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0.0; // Reset to beginning
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(_) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }
  
  void _handleTapUp(_) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }
  
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use muted surface color instead of flashy primary for softer look
    final backgroundColor = widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final foregroundColor = widget.foregroundColor ?? colorScheme.primary;

    // Combine press animation + pulse animation
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        // Combine both animations: press scale * pulse scale
        final combinedScale = _scaleAnimation.value * _pulseAnimation.value;

        return Transform.scale(
          scale: combinedScale,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Subtle neutral shadow instead of colored glow
              boxShadow: widget.showShadow ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: _isPressed ? 0.15 : 0.25),
                  blurRadius: _isPressed ? 4 : 8,
                  offset: Offset(0, _isPressed ? 1 : 2),
                ),
              ] : null,
            ),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onPressed();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCompact ? 16 : 20,
                    vertical: widget.isCompact ? 12 : 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: foregroundColor,
                        size: widget.isCompact ? 20 : 24,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w600,
                            fontSize: widget.isCompact ? 14 : 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Versione più compatta per spazi ridotti
class CompactActionButton extends StatelessWidget {
  
  const CompactActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.showBadge = false,
    this.badgeText,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBadge;
  final String? badgeText;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use muted surface color instead of flashy primary for softer look
    final backgroundColor = this.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final foregroundColor = this.foregroundColor ?? colorScheme.primary;
    
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onPressed();
              },
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  icon,
                  color: foregroundColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        if (showBadge && badgeText != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  badgeText!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bottom action bar per azioni multiple (alternativa al FAB)
class PremiumBottomActionBar extends StatelessWidget {
  
  const PremiumBottomActionBar({
    super.key,
    required this.actions,
    this.backgroundColor,
  });
  final List<ActionItem> actions;
  final Color? backgroundColor;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: actions.map((action) {
            if (action.isPrimary) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PremiumActionButton(
                    onPressed: action.onPressed,
                    icon: action.icon,
                    label: action.label,
                    backgroundColor: action.backgroundColor,
                    isCompact: true,
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CompactActionButton(
                  onPressed: action.onPressed,
                  icon: action.icon,
                  tooltip: action.label,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0),
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}

class ActionItem {
  
  const ActionItem({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.backgroundColor,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final Color? backgroundColor;
}