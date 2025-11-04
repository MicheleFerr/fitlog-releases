import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class SmartSuggestionChip extends StatefulWidget {
  
  const SmartSuggestionChip({
    super.key,
    required this.suggestion,
    required this.icon,
    required this.onTap,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 8),
    this.showBreathingAnimation = false,
    this.isMinimal = true,
  });
  final String suggestion;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;
  final Duration displayDuration;
  final bool showBreathingAnimation;
  final bool isMinimal;

  @override
  State<SmartSuggestionChip> createState() => _SmartSuggestionChipState();
}

class _SmartSuggestionChipState extends State<SmartSuggestionChip>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _breathingController;
  late AnimationController _dismissController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<Offset> _slideAnimation;
  
  Timer? _autoDismissTimer;
  bool _isVisible = true;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    
    // Fade in animation - slower and smoother
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    // Breathing animation
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Dismiss animation
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeInBack,
    ));
    
    // Start animations
    _fadeController.forward();
    if (widget.showBreathingAnimation) {
      _breathingController.repeat(reverse: true);
    }
    
    // Auto dismiss timer
    _autoDismissTimer = Timer(widget.displayDuration, _autoDismiss);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathingController.dispose();
    _dismissController.dispose();
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _autoDismiss() {
    if (mounted && _isVisible) {
      _dismiss();
    }
  }
  
  void _dismiss() {
    if (_isDismissing) return;
    
    setState(() {
      _isDismissing = true;
    });
    
    _dismissController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        widget.onDismiss?.call();
      }
    });
  }
  
  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: GestureDetector(
                onTap: _handleTap,
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 200) {
                    _dismiss();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isMinimal 
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    border: widget.isMinimal
                      ? Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        )
                      : null,
                    boxShadow: [
                      BoxShadow(
                        color: widget.isMinimal
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: widget.isMinimal ? 8 : 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        size: 18,
                        color: widget.isMinimal
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.suggestion,
                          style: TextStyle(
                            color: widget.isMinimal
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: widget.isMinimal
                          ? theme.colorScheme.primary.withValues(alpha: 0.7)
                          : theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  
  const _PulsingIcon({required this.icon});
  final IconData icon;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.surface.withValues(alpha: 0.2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing ring
              Transform.scale(
                scale: 1 + (_animation.value * 0.3),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.surface.withValues(alpha: 1 - _animation.value),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Icon
              Icon(
                widget.icon,
                size: 16,
                color: context.colors.surface,
              ),
            ],
          ),
        );
      },
    );
  }
}