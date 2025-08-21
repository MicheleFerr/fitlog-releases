import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class AnimatedXPBar extends StatefulWidget {
  final int currentXP;
  final int previousXP;
  final int xpGained;
  final int currentLevel;
  final VoidCallback? onAnimationComplete;
  
  const AnimatedXPBar({
    super.key,
    required this.currentXP,
    required this.previousXP,
    required this.xpGained,
    required this.currentLevel,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedXPBar> createState() => _AnimatedXPBarState();
}

class _AnimatedXPBarState extends State<AnimatedXPBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _levelUpController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  final List<_Particle> _particles = [];
  Timer? _particleTimer;
  
  bool _didLevelUp = false;
  int _displayXP = 0;
  int _displayLevel = 0;
  
  @override
  void initState() {
    super.initState();
    
    _displayXP = widget.previousXP;
    _displayLevel = widget.currentLevel;
    
    // Check if leveled up
    final previousLevel = (widget.previousXP / 500).floor() + 1;
    final newLevel = (widget.currentXP / 500).floor() + 1;
    _didLevelUp = newLevel > previousLevel;
    
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Level up animation
    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Setup animations
    _progressAnimation = Tween<double>(
      begin: (widget.previousXP % 500) / 500,
      end: (widget.currentXP % 500) / 500,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.elasticOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: _getLevelColor(widget.currentLevel),
      end: _getLevelColor(widget.currentLevel).withValues(alpha: 0.8),
    ).animate(_glowController);
    
    // Start animations
    _startAnimations();
  }
  
  void _startAnimations() async {
    // Start particle generation
    _startParticleGeneration();
    
    // Animate XP counter
    _animateXPCounter();
    
    // Start progress bar animation
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
    
    // If leveled up, trigger level up animation
    if (_didLevelUp) {
      _progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _levelUpController.forward();
          setState(() {
            _displayLevel = (widget.currentXP / 500).floor() + 1;
          });
        }
      });
    }
    
    // Complete animation
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onAnimationComplete?.call();
        });
      }
    });
  }
  
  void _animateXPCounter() {
    final duration = const Duration(milliseconds: 2000);
    final stepTime = duration.inMilliseconds ~/ widget.xpGained;
    
    Timer.periodic(Duration(milliseconds: stepTime.clamp(10, 100)), (timer) {
      if (_displayXP >= widget.currentXP) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _displayXP = (_displayXP + 1).clamp(0, widget.currentXP);
      });
    });
  }
  
  void _startParticleGeneration() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_particles.length < 20) {
        _particles.add(_Particle(
          position: Offset(
            math.Random().nextDouble() * 300,
            200 + math.Random().nextDouble() * 50,
          ),
          velocity: Offset(
            (math.Random().nextDouble() - 0.5) * 2,
            -math.Random().nextDouble() * 3 - 1,
          ),
          size: math.Random().nextDouble() * 6 + 2,
          color: _getParticleColor(),
          lifespan: 1.0,
        ));
      }
      
      // Update particles
      setState(() {
        _particles.removeWhere((p) => p.lifespan <= 0);
        for (final particle in _particles) {
          particle.update();
        }
      });
    });
  }
  
  Color _getParticleColor() {
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.amber,
      Colors.yellowAccent,
      const Color(0xFFFFD700), // Gold
    ];
    return colors[math.Random().nextInt(colors.length)];
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _levelUpController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLevelXP = _displayXP % 500;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // XP Gained Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.9),
                        Colors.orange.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.xpGained} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          // Level Badge with animation
          AnimatedBuilder(
            animation: _levelUpController,
            builder: (context, child) {
              return Transform.scale(
                scale: _didLevelUp ? _scaleAnimation.value : 1.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _colorAnimation.value!.withValues(alpha: 0.6 * _glowAnimation.value),
                                blurRadius: 30 + (10 * _glowAnimation.value),
                                spreadRadius: 10 + (5 * _glowAnimation.value),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Level badge
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _getLevelColor(_displayLevel),
                            _getLevelColor(_displayLevel).withValues(alpha: 0.7),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LV',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$_displayLevel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // XP Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bolt,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Text(
                      '$_displayXP XP',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar with particles
          SizedBox(
            height: 80,
            child: Stack(
              children: [
                // Particles
                ...(_particles.map((particle) => Positioned(
                  left: particle.position.dx,
                  top: particle.position.dy,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: particle.color.withValues(alpha: particle.lifespan),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: particle.color.withValues(alpha: 0.5 * particle.lifespan),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ))),
                
                // Progress bar
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Livello $_displayLevel',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$currentLevelXP / 500 XP',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Livello ${_displayLevel + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: theme.colorScheme.surfaceContainerHighest,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              // Animated progress fill
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    widthFactor: _progressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getLevelColor(_displayLevel),
                                            _getLevelColor(_displayLevel).withValues(alpha: 0.8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              // Shimmer effect
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    widthFactor: _progressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withValues(alpha: 0.3),
                                            Colors.transparent,
                                          ],
                                          stops: [
                                            (_progressController.value - 0.3).clamp(0.0, 1.0),
                                            _progressController.value.clamp(0.0, 1.0),
                                            (_progressController.value + 0.3).clamp(0.0, 1.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Level up text
          if (_didLevelUp)
            AnimatedBuilder(
              animation: _levelUpController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _levelUpController.value,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        '🎉 LEVEL UP! 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  
  Color _getLevelColor(int level) {
    if (level >= 20) return Colors.purple;
    if (level >= 15) return Colors.deepOrange;
    if (level >= 10) return Colors.orange;
    if (level >= 5) return Colors.blue;
    return Colors.green;
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double lifespan;
  
  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.lifespan,
  });
  
  void update() {
    position = position + velocity;
    velocity = Offset(velocity.dx * 0.98, velocity.dy + 0.1); // Gravity
    lifespan -= 0.05;
  }
}