import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../providers/timer_provider.dart';
import '../providers/timer_position_provider.dart';
import '../services/timer_positioning_service.dart';
import '../../domain/entities/rest_timer.dart';
import '../../domain/entities/timer_display_mode.dart';

/// FAB System per recupero timer quando è fuori schermo
/// 
/// Features:
/// - Appare automaticamente quando timer è fuori bounds visibili
/// - Auto-expansion animata quando tapped
/// - Integration seamless con Riverpod state
/// - Pulsazioni visive per urgency (quando timer è quasi finito)
/// - Memory efficient con lazy loading
class TimerRecoveryFAB extends ConsumerStatefulWidget {
  /// Callback chiamato quando FAB viene tapped per espandere timer
  final VoidCallback? onExpand;
  
  /// Posizione preferita per FAB (default: bottom-right)
  final Alignment fabAlignment;
  
  /// Margins dal bordo schermo
  final EdgeInsets margins;
  
  const TimerRecoveryFAB({
    super.key,
    this.onExpand,
    this.fabAlignment = Alignment.bottomRight,
    this.margins = const EdgeInsets.all(16.0),
  });

  @override
  ConsumerState<TimerRecoveryFAB> createState() => _TimerRecoveryFABState();
}

class _TimerRecoveryFABState extends ConsumerState<TimerRecoveryFAB>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State tracking
  bool _isVisible = false;
  bool _wasTimerVisible = true;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    // Pulse animation for urgency (when timer is almost done)
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
    
    // Scale animation for tap feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Slide animation for show/hide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 2), // Slide from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(currentTimerProvider);
    final positionState = ref.watch(timerPositionProvider);
    
    // Early return if no active timer
    if (timer == null || !timer.isActive) {
      _hideIfVisible();
      return const SizedBox.shrink();
    }
    
    // Check if timer is visible on screen
    final isTimerVisible = _isTimerVisibleOnScreen(positionState, context);
    
    // Show/hide FAB based on timer visibility
    _updateVisibility(isTimerVisible, timer);
    
    if (!_isVisible) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: widget.margins.bottom,
      right: widget.margins.right,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _pulseAnimation.value,
              child: _buildFABContent(timer),
            );
          },
        ),
      ),
    );
  }
  
  // MARK: - Visibility Logic
  
  bool _isTimerVisibleOnScreen(TimerPositionState positionState, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final layout = TimerLayoutManager.getLayout(positionState.mode);
    final widgetSize = Size(
      positionState.mode == TimerDisplayMode.expanded 
          ? screenSize.width - 32 
          : layout.width,
      layout.height,
    );
    
    return TimerPositioningService.isPositionFullyVisible(
      position: positionState.position,
      widgetSize: widgetSize,
      screenSize: screenSize,
      screenPadding: MediaQuery.of(context).padding,
      minVisibleThreshold: 0.7, // 70% del timer deve essere visibile
    );
  }
  
  void _updateVisibility(bool isTimerVisible, RestTimer timer) {
    // Show FAB when timer becomes invisible
    if (!isTimerVisible && _wasTimerVisible) {
      _showFAB();
      _startPulseIfUrgent(timer);
    }
    // Hide FAB when timer becomes visible again
    else if (isTimerVisible && !_wasTimerVisible) {
      _hideFAB();
      _stopPulse();
    }
    // Update pulse state for urgent timers
    else if (!isTimerVisible) {
      _updatePulseForTimer(timer);
    }
    
    _wasTimerVisible = isTimerVisible;
  }
  
  void _showFAB() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _slideController.forward();
      HapticFeedback.lightImpact();
    }
  }
  
  void _hideFAB() {
    if (_isVisible) {
      _slideController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
      _stopPulse();
    }
  }
  
  void _hideIfVisible() {
    if (_isVisible) {
      _hideFAB();
    }
  }
  
  // MARK: - Pulse Animation Logic
  
  void _startPulseIfUrgent(RestTimer timer) {
    if (_shouldPulseForTimer(timer)) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  void _updatePulseForTimer(RestTimer timer) {
    final shouldPulse = _shouldPulseForTimer(timer);
    
    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!shouldPulse && _pulseController.isAnimating) {
      _stopPulse();
    }
  }
  
  bool _shouldPulseForTimer(RestTimer timer) {
    // Pulse when timer is in final 30 seconds or completed
    return timer.remainingSeconds <= 30 || timer.isCompleted;
  }
  
  void _stopPulse() {
    if (_pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }
  
  // MARK: - FAB Content
  
  Widget _buildFABContent(RestTimer timer) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: () => _handleFABTap(timer),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getFABGradient(timer),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background circle for progress
            Positioned.fill(
              child: CircularProgressIndicator(
                value: timer.progress,
                strokeWidth: 3,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            
            // Main icon
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFABIcon(timer),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timer.formattedTimeShort,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            
            // Urgent indicator (red dot)
            if (timer.remainingSeconds <= 10)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  LinearGradient _getFABGradient(RestTimer timer) {
    List<Color> colors;
    
    if (timer.isCompleted) {
      colors = [Colors.green.shade600, Colors.green.shade800];
    } else if (timer.isPaused) {
      colors = [Colors.orange.shade600, Colors.orange.shade800];
    } else if (timer.remainingSeconds <= 30) {
      colors = [Colors.red.shade600, Colors.red.shade800];
    } else {
      colors = [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ];
    }
    
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  IconData _getFABIcon(RestTimer timer) {
    if (timer.isCompleted) {
      return Icons.check;
    } else if (timer.isPaused) {
      return Icons.pause;
    } else {
      return Icons.timer;
    }
  }
  
  // MARK: - Interaction Handlers
  
  void _handleFABTap(RestTimer timer) {
    HapticFeedback.mediumImpact();
    
    // Primary action: restore timer to visible position
    _restoreTimerToVisiblePosition();
    
    // Call optional expand callback
    widget.onExpand?.call();
    
    // Hide FAB since timer is now visible
    _hideFAB();
  }
  
  void _restoreTimerToVisiblePosition() {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final screenSize = MediaQuery.of(context).size;
    final positionState = ref.read(timerPositionProvider);
    final layout = TimerLayoutManager.getLayout(positionState.mode);
    
    final widgetSize = Size(
      positionState.mode == TimerDisplayMode.expanded 
          ? screenSize.width - 32 
          : layout.width,
      layout.height,
    );
    
    // Calculate safe center position
    final safePosition = TimerPositioningService.getSafeCenterPosition(
      screenSize: screenSize,
      widgetSize: widgetSize,
      screenPadding: MediaQuery.of(context).padding,
    );
    
    // Animate to safe position
    positionNotifier.updatePosition(safePosition);
    positionNotifier.saveAllState();
  }
  
  // MARK: - Memory Management
  
  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}

/// Extension per formato tempo compatto nel FAB
extension RestTimerFABExtension on RestTimer {
  String get formattedTimeShort {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds}s';
    }
  }
}