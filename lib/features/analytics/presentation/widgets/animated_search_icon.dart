import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AnimatedSearchIcon extends StatefulWidget {
  final VoidCallback onPressed;
  final bool showInitialAnimation;
  
  const AnimatedSearchIcon({
    super.key,
    required this.onPressed,
    this.showInitialAnimation = true,
  });

  @override
  State<AnimatedSearchIcon> createState() => _AnimatedSearchIconState();
}

class _AnimatedSearchIconState extends State<AnimatedSearchIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;
  
  bool _hasShownInitialAnimation = false;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation (continuous)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Bounce animation (initial attention grabber)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    if (widget.showInitialAnimation && !_hasShownInitialAnimation) {
      _startInitialAnimation();
    }
    
    // Start continuous pulse
    _pulseController.repeat(reverse: true);
  }
  
  void _startInitialAnimation() async {
    // Wait a bit for the screen to load
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      // Start bounce
      _bounceController.forward();
      
      // Glow effect during bounce
      _glowController.forward();
      await Future.delayed(const Duration(milliseconds: 750));
      _glowController.reverse();
      
      // Mark as shown
      _hasShownInitialAnimation = true;
      
      // After initial animation, pulse 3 times to draw attention
      for (int i = 0; i < 3; i++) {
        if (!mounted) break;
        await Future.delayed(const Duration(milliseconds: 500));
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Glow effect background
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Positioned(
              top: -8,
              right: -8,
              bottom: -8,
              left: -8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(
                        alpha: 0.3 * _glowAnimation.value,
                      ),
                      theme.colorScheme.primary.withValues(
                        alpha: 0.1 * _glowAnimation.value,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Ripple effect rings
        if (_hasShownInitialAnimation) ...[
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                top: 12 - (12 * (_pulseAnimation.value - 1)),
                right: 12 - (12 * (_pulseAnimation.value - 1)),
                bottom: 12 - (12 * (_pulseAnimation.value - 1)),
                left: 12 - (12 * (_pulseAnimation.value - 1)),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.2 * (2 - _pulseAnimation.value),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        
        // Main icon button
        AnimatedBuilder(
          animation: Listenable.merge([
            _bounceAnimation,
            _pulseAnimation,
          ]),
          builder: (context, child) {
            final scale = _bounceAnimation.value == 0 
                ? 1.0 
                : 0.9 + (_bounceAnimation.value * 0.1) + (_pulseAnimation.value - 1) * 0.1;
            
            return Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: _bounceAnimation.value * 0.1 * math.pi,
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onPressed();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  tooltip: 'Cerca Esercizio',
                ),
              ),
            );
          },
        ),
        
        // "NEW" badge (optional, for first time users)
        if (!_hasShownInitialAnimation && widget.showInitialAnimation)
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'NEW',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class PulsingSearchIcon extends StatefulWidget {
  final VoidCallback onPressed;
  
  const PulsingSearchIcon({
    super.key,
    required this.onPressed,
  });

  @override
  State<PulsingSearchIcon> createState() => _PulsingSearchIconState();
}

class _PulsingSearchIconState extends State<PulsingSearchIcon>
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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onPressed();
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(
                      red: theme.colorScheme.primary.red * 0.8,
                      green: theme.colorScheme.primary.green * 0.8,
                      blue: theme.colorScheme.primary.blue * 0.8,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Cerca nei tuoi esercizi',
          ),
        );
      },
    );
  }
}