import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../providers/timer_provider.dart';
import '../providers/timer_position_provider.dart';
import '../../domain/entities/rest_timer.dart';
import '../../domain/entities/timer_display_mode.dart';

/// Widget timer minimizzabile con gesture iOS-style
class MinimizableTimerOverlay extends ConsumerStatefulWidget {
  const MinimizableTimerOverlay({super.key});

  @override
  ConsumerState<MinimizableTimerOverlay> createState() => _MinimizableTimerOverlayState();
}

class _MinimizableTimerOverlayState extends ConsumerState<MinimizableTimerOverlay>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _scaleController;
  late AnimationController _positionController;
  late AnimationController _modeTransitionController;
  
  // Gesture state
  Offset _panStartPosition = Offset.zero;
  double _baseScale = 1.0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(currentTimerProvider);
    final positionState = ref.watch(timerPositionProvider);
    final layout = ref.watch(currentTimerLayoutProvider);
    
    if (timer == null || !timer.isActive) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final widgetSize = Size(
      positionState.mode == TimerDisplayMode.expanded 
          ? screenSize.width - 32 
          : layout.width,
      layout.height,
    );

    return Positioned(
      left: positionState.position.dx,
      top: positionState.position.dy,
      child: GestureDetector(
        // Scale Gesture (include anche drag quando scale = 1.0)
        onScaleStart: _handleScaleStart,
        onScaleUpdate: (details) => _handleScaleUpdate(details, screenSize, widgetSize),
        onScaleEnd: _handleScaleEnd,
        
        // Tap Gestures per cambio modalità
        onTap: _handleTap,
        onDoubleTap: _handleDoubleTap,
        
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleController,
            _modeTransitionController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _getScaleForAnimation(positionState),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: widgetSize.width,
                height: widgetSize.height,
                decoration: _getDecorationForMode(timer, positionState),
                child: _buildTimerContent(timer, positionState, layout),
              ),
            );
          },
        ),
      ),
    );
  }
  
  // MARK: - Gesture Handlers
  
  void _handleScaleStart(ScaleStartDetails details) {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    positionNotifier.setDragging(true);
    _baseScale = ref.read(timerPositionProvider).scale;
    _panStartPosition = details.focalPoint;
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }
  
  void _handleScaleUpdate(ScaleUpdateDetails details, Size screenSize, Size widgetSize) {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    
    // Handle dragging (quando scale è ~1.0)
    if ((details.scale - 1.0).abs() < 0.1) {
      final currentPosition = ref.read(timerPositionProvider).position;
      final deltaPosition = details.focalPoint - _panStartPosition;
      final newPosition = currentPosition + deltaPosition;
      
      final constrainedPosition = positionNotifier.constrainToScreen(
        newPosition, 
        screenSize, 
        widgetSize,
      );
      
      positionNotifier.updatePosition(constrainedPosition);
      _panStartPosition = details.focalPoint;
      
      // Edge magnetism feedback
      final edgeDistance = positionNotifier.getDistanceToNearestEdge(
        constrainedPosition, 
        screenSize, 
        widgetSize,
      );
      
      final shouldSnap = edgeDistance < 50;
      final currentlySnapped = ref.read(timerPositionProvider).isSnappedToEdge;
      
      if (shouldSnap && !currentlySnapped) {
        positionNotifier.setSnapToEdge(true);
        HapticFeedback.selectionClick();
      } else if (!shouldSnap && currentlySnapped) {
        positionNotifier.setSnapToEdge(false);
      }
    }
    
    // Handle scaling (quando scale è diverso da 1.0)
    else {
      final newScale = (_baseScale * details.scale).clamp(0.5, 2.0);
      positionNotifier.updateScale(newScale);
      
      // Modalità cambio basato su scala
      if (details.scale > 1.2) {
        positionNotifier.updateModeFromScale(1.5);
        HapticFeedback.mediumImpact();
      } else if (details.scale < 0.8) {
        positionNotifier.updateModeFromScale(0.5);
        HapticFeedback.lightImpact();
      }
    }
  }
  
  void _handleScaleEnd(ScaleEndDetails details) {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final currentState = ref.read(timerPositionProvider);
    
    positionNotifier.setDragging(false);
    positionNotifier.resetScale();
    _scaleController.reverse();
    _baseScale = 1.0;
    
    // Auto-snap ai bordi se vicino (solo dopo drag, non dopo scale)
    if ((details.velocity.pixelsPerSecond.distance) < 100) {
      final edgeDistance = positionNotifier.getDistanceToNearestEdge(
        currentState.position, 
        MediaQuery.of(context).size, 
        Size(TimerLayoutManager.getLayout(currentState.mode).width, 
             TimerLayoutManager.getLayout(currentState.mode).height),
      );
      
      if (edgeDistance < 80) {
        final edgePosition = positionNotifier.getNearestEdgePosition(
          currentState.position, 
          MediaQuery.of(context).size, 
          Size(TimerLayoutManager.getLayout(currentState.mode).width, 
               TimerLayoutManager.getLayout(currentState.mode).height),
        );
        _animateToPosition(edgePosition);
        HapticFeedback.mediumImpact();
      }
    }
    
    positionNotifier.saveAllState();
  }
  
  void _handleTap() {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    positionNotifier.cycleToNextMode();
    _triggerModeTransition();
    HapticFeedback.selectionClick();
  }
  
  void _handleDoubleTap() {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final currentMode = ref.read(timerPositionProvider).mode;
    
    if (currentMode != TimerDisplayMode.normal) {
      positionNotifier.updateMode(TimerDisplayMode.normal);
      _triggerModeTransition();
      HapticFeedback.heavyImpact();
    }
  }
  
  // MARK: - Animation Helpers
  
  double _getScaleForAnimation(TimerPositionState positionState) {
    final baseScale = positionState.isDragging ? 1.05 : 1.0;
    final gestureScale = positionState.scale;
    final transitionScale = Curves.easeOutBack.transform(_modeTransitionController.value);
    
    return baseScale * gestureScale * (0.95 + 0.05 * transitionScale);
  }
  
  void _triggerModeTransition() {
    _modeTransitionController.forward().then((_) {
      _modeTransitionController.reset();
    });
  }
  
  void _animateToPosition(Offset targetPosition) {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final startPosition = ref.read(timerPositionProvider).position;
    
    final animation = Tween<Offset>(
      begin: startPosition,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutBack,
    ));
    
    animation.addListener(() {
      positionNotifier.updatePosition(animation.value);
    });
    
    _positionController.forward().then((_) {
      _positionController.reset();
    });
  }
  
  // MARK: - Visual Styling
  
  BoxDecoration _getDecorationForMode(RestTimer timer, TimerPositionState positionState) {
    final layout = TimerLayoutManager.getLayout(positionState.mode);
    final colors = _getGradientColors(timer);
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(layout.borderRadius),
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
  
  List<Color> _getGradientColors(RestTimer timer) {
    if (timer.isCompleted) {
      return [Colors.green.shade600, Colors.green.shade800];
    } else if (timer.isPaused) {
      return [Colors.orange.shade600, Colors.orange.shade800];
    } else if (timer.remainingSeconds <= 30) {
      return [Colors.red.shade600, Colors.red.shade800];
    } else if (timer.remainingSeconds <= 60) {
      return [Colors.orange.shade600, Colors.orange.shade800];
    } else {
      return [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary.withRed(
          (Theme.of(context).colorScheme.primary.red * 0.8).round(),
        ),
      ];
    }
  }
  
  // MARK: - Content Builders
  
  Widget _buildTimerContent(RestTimer timer, TimerPositionState positionState, TimerLayout layout) {
    switch (positionState.mode) {
      case TimerDisplayMode.compact:
        return _buildCompactContent(timer, layout);
      case TimerDisplayMode.normal:
        return _buildNormalContent(timer, layout);
      case TimerDisplayMode.expanded:
        return _buildExpandedContent(timer, layout);
    }
  }
  
  Widget _buildCompactContent(RestTimer timer, TimerLayout layout) {
    return Center(
      child: Text(
        timer.formattedTime,
        style: TextStyle(
          color: Colors.white,
          fontSize: layout.fontSize,
          fontWeight: FontWeight.bold,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
  
  Widget _buildNormalContent(RestTimer timer, TimerLayout layout) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Progress Ring
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(50, 50),
                  painter: ProgressRingPainter(
                    progress: 0.0,
                    strokeWidth: 3,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    progressColor: Colors.transparent,
                  ),
                ),
                CustomPaint(
                  size: const Size(50, 50),
                  painter: ProgressRingPainter(
                    progress: timer.progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.transparent,
                    progressColor: Colors.white,
                  ),
                ),
                Center(
                  child: Icon(
                    timer.isPaused ? Icons.pause : Icons.timer,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Timer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timer.formattedTime,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: layout.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (timer.exerciseName != null)
                  Text(
                    timer.exerciseName!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // Quick Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickActionButton(
                icon: timer.isPaused ? Icons.play_arrow : Icons.pause,
                onPressed: () => timer.isPaused 
                  ? ref.read(currentTimerProvider.notifier).resumeTimer()
                  : ref.read(currentTimerProvider.notifier).pauseTimer(),
              ),
              const SizedBox(width: 8),
              _buildQuickActionButton(
                icon: Icons.skip_next,
                onPressed: () => ref.read(currentTimerProvider.notifier).skipTimer(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandedContent(RestTimer timer, TimerLayout layout) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(
                _getTimerIcon(timer.status),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rest Timer',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (timer.exerciseName != null)
                      Text(
                        timer.exerciseName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (timer.currentSet != null && timer.totalSets != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Set ${timer.currentSet}/${timer.totalSets}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Timer Display con Progress Ring Grande
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: ProgressRingPainter(
                        progress: 0.0,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        progressColor: Colors.transparent,
                      ),
                    ),
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: ProgressRingPainter(
                        progress: timer.progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        progressColor: Colors.white,
                      ),
                    ),
                    Center(
                      child: Icon(
                        timer.isPaused ? Icons.pause : Icons.timer,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timer.formattedTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(timer),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Extended Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildExtendedActionButton(
                icon: Icons.remove,
                label: '-30s',
                onPressed: () => ref.read(currentTimerProvider.notifier).addTime(-30),
              ),
              _buildExtendedActionButton(
                icon: timer.isPaused ? Icons.play_arrow : Icons.pause,
                label: timer.isPaused ? 'Resume' : 'Pause',
                onPressed: () => timer.isPaused 
                  ? ref.read(currentTimerProvider.notifier).resumeTimer()
                  : ref.read(currentTimerProvider.notifier).pauseTimer(),
              ),
              _buildExtendedActionButton(
                icon: Icons.add,
                label: '+30s',
                onPressed: () => ref.read(currentTimerProvider.notifier).addTime(30),
              ),
              _buildExtendedActionButton(
                icon: Icons.skip_next,
                label: 'Skip',
                onPressed: () => ref.read(currentTimerProvider.notifier).skipTimer(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          LinearProgressIndicator(
            value: timer.progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
  
  // MARK: - Action Buttons
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
  
  Widget _buildExtendedActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // MARK: - Helper Methods
  
  IconData _getTimerIcon(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return Icons.timer;
      case TimerStatus.paused:
        return Icons.pause_circle;
      case TimerStatus.completed:
        return Icons.check_circle;
      case TimerStatus.idle:
        return Icons.timer_outlined;
    }
  }
  
  String _getStatusText(RestTimer timer) {
    if (timer.isCompleted) {
      return 'Rest complete! Ready for next set';
    } else if (timer.isPaused) {
      return 'Timer paused';
    } else if (timer.remainingSeconds <= 30) {
      return 'Get ready...';
    } else {
      return 'Rest time';
    }
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _positionController.dispose();
    _modeTransitionController.dispose();
    super.dispose();
  }
}

/// Custom painter per progress ring (riutilizzato dal widget originale)
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    if (backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Progress arc
    if (progressColor != Colors.transparent && progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.progressColor != progressColor;
  }
}