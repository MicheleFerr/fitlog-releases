import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../providers/timer_provider.dart';
import '../providers/timer_position_provider.dart';
import '../services/timer_positioning_service.dart';
import '../../domain/entities/rest_timer.dart';
import '../../domain/entities/timer_display_mode.dart';
import 'minimized_timer_controls.dart';

/// Widget timer draggable con constraints robusti per GymBro FitLog Pro
/// 
/// Features:
/// - Drag boundaries che mantengono sempre 48px minimi visibili (iOS/Android standard)
/// - Magnetic positioning ai bordi schermo con haptic feedback
/// - State management persistente per posizione
/// - Performance ottimizzato con minimal rebuilds
/// - Accessibility compliant con semantic labels
/// - Memory efficient cleanup system
class DraggableTimerOverlay extends ConsumerStatefulWidget {
  const DraggableTimerOverlay({super.key});

  @override
  ConsumerState<DraggableTimerOverlay> createState() => _DraggableTimerOverlayState();
}

class _DraggableTimerOverlayState extends ConsumerState<DraggableTimerOverlay>
    with TickerProviderStateMixin {
  
  // Animation controllers for smooth UX
  late AnimationController _scaleController;
  late AnimationController _snapController;
  late AnimationController _modeTransitionController;
  late AnimationController _magneticController;
  
  // Gesture tracking state
  Offset _dragStartPosition = Offset.zero;
  Offset _lastKnownPosition = Offset.zero;
  bool _isDragActive = false;
  bool _isNearEdge = false;
  
  // Performance optimization - reduce rebuilds
  Size? _cachedScreenSize;
  Size? _cachedWidgetSize;
  
  // Accessibility
  final GlobalKey _timerWidgetKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _schedulePositionValidation();
  }
  
  /// Initialize all animation controllers with optimized durations
  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _snapController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _magneticController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }
  
  /// Schedule position validation on next frame to ensure correct screen dimensions
  void _schedulePositionValidation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAndCorrectPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(currentTimerProvider);
    final positionState = ref.watch(timerPositionProvider);
    final layout = ref.watch(currentTimerLayoutProvider);
    
    // Early return if no active timer
    if (timer == null || !timer.isActive) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final screenPadding = MediaQuery.of(context).padding;
    
    // Cache sizes for performance
    _cachedScreenSize = screenSize;
    _cachedWidgetSize = _calculateWidgetSize(positionState.mode, screenSize, layout);
    
    // Get constrained position with minimum visibility requirements
    final constrainedPosition = TimerPositioningService.getConstrainedPosition(
      position: positionState.position,
      screenSize: screenSize,
      widgetSize: _cachedWidgetSize!,
      screenPadding: screenPadding,
      minVisibleArea: const Size(48, 48), // iOS/Android standard tap target
    );

    return Positioned(
      left: constrainedPosition.dx,
      top: constrainedPosition.dy,
      child: Semantics(
        label: 'Draggable Rest Timer',
        hint: 'Double tap to cycle modes, drag to reposition',
        child: GestureDetector(
          key: _timerWidgetKey,
          
          // Pan gestures for dragging with constraints
          onPanStart: _handleDragStart,
          onPanUpdate: (details) => _handleDragUpdate(details, screenSize),
          onPanEnd: _handleDragEnd,
          
          // Tap gestures for mode cycling
          onTap: _handleSingleTap,
          onDoubleTap: _handleDoubleTap,
          onLongPress: _handleLongPress,
          
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleController,
              _snapController,
              _modeTransitionController,
              _magneticController,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _calculateAnimatedScale(positionState),
                child: Container(
                  width: _cachedWidgetSize!.width,
                  height: _cachedWidgetSize!.height,
                  decoration: _buildTimerDecoration(timer, positionState),
                  child: _buildTimerContent(timer, positionState, layout),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  // MARK: - Drag Gesture Handlers
  
  void _handleDragStart(DragStartDetails details) {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    
    _isDragActive = true;
    _dragStartPosition = details.globalPosition;
    _lastKnownPosition = ref.read(timerPositionProvider).position;
    
    positionNotifier.setDragging(true);
    _scaleController.forward();
    
    // Haptic feedback for drag start
    HapticFeedback.lightImpact();
    
    // Performance: Cache current state
    _updateCachedSizes();
  }
  
  void _handleDragUpdate(DragUpdateDetails details, Size screenSize) {
    if (!_isDragActive || _cachedWidgetSize == null) return;
    
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final currentPosition = ref.read(timerPositionProvider).position;
    
    // Calculate new position from drag delta
    final newPosition = currentPosition + details.delta;
    
    // Apply boundary constraints with minimum visibility
    final constrainedPosition = TimerPositioningService.getConstrainedPosition(
      position: newPosition,
      screenSize: screenSize,
      widgetSize: _cachedWidgetSize!,
      screenPadding: MediaQuery.of(context).padding,
      minVisibleArea: const Size(48, 48), // Always keep 48px visible
    );
    
    // Update position if changed
    if (constrainedPosition != currentPosition) {
      positionNotifier.updatePosition(constrainedPosition);
    }
    
    // Check proximity to edges for magnetic feedback
    _checkEdgeProximityAndFeedback(constrainedPosition, screenSize);
  }
  
  void _handleDragEnd(DragEndDetails details) {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final currentState = ref.read(timerPositionProvider);
    
    _isDragActive = false;
    positionNotifier.setDragging(false);
    _scaleController.reverse();
    
    // Calculate if we should snap to edge based on velocity and proximity
    final shouldSnapToEdge = _shouldPerformEdgeSnap(details.velocity, currentState);
    
    if (shouldSnapToEdge && _cachedScreenSize != null && _cachedWidgetSize != null) {
      _performMagneticSnap(currentState.position, _cachedScreenSize!, _cachedWidgetSize!);
    } else {
      // Save position immediately if no snap needed
      positionNotifier.saveAllState();
    }
    
    // Reset edge proximity state
    _isNearEdge = false;
    positionNotifier.setSnapToEdge(false);
  }
  
  // MARK: - Tap Gesture Handlers
  
  void _handleSingleTap() {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    positionNotifier.cycleToNextMode();
    _triggerModeTransition();
    HapticFeedback.selectionClick();
  }
  
  void _handleDoubleTap() {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final currentMode = ref.read(timerPositionProvider).mode;
    
    // Double tap resets to normal mode
    if (currentMode != TimerDisplayMode.normal) {
      positionNotifier.updateMode(TimerDisplayMode.normal);
      _triggerModeTransition();
      HapticFeedback.mediumImpact();
    }
  }
  
  void _handleLongPress() {
    // Long press cycles to compact mode for minimal interference
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    positionNotifier.updateMode(TimerDisplayMode.compact);
    _triggerModeTransition();
    HapticFeedback.heavyImpact();
  }
  
  // MARK: - Edge Detection & Magnetic Snapping
  
  void _checkEdgeProximityAndFeedback(Offset position, Size screenSize) {
    if (_cachedWidgetSize == null) return;
    
    const proximityThreshold = 60.0; // Pixels from edge to trigger magnetic feedback
    
    final isNearEdgeNow = TimerPositioningService.isNearScreenEdge(
      position: position,
      screenSize: screenSize,
      widgetSize: _cachedWidgetSize!,
      threshold: proximityThreshold,
    );
    
    // Provide haptic feedback when entering/leaving magnetic zone
    if (isNearEdgeNow && !_isNearEdge) {
      _isNearEdge = true;
      ref.read(timerPositionProvider.notifier).setSnapToEdge(true);
      _magneticController.forward();
      HapticFeedback.selectionClick();
    } else if (!isNearEdgeNow && _isNearEdge) {
      _isNearEdge = false;
      ref.read(timerPositionProvider.notifier).setSnapToEdge(false);
      _magneticController.reverse();
    }
  }
  
  bool _shouldPerformEdgeSnap(Velocity velocity, TimerPositionState state) {
    const velocityThreshold = 100.0; // Low velocity indicates intentional positioning
    const proximityThreshold = 80.0; // Close enough to edge to warrant snapping
    
    final isLowVelocity = velocity.pixelsPerSecond.distance < velocityThreshold;
    final isNearEdge = state.isSnappedToEdge || 
        (_cachedScreenSize != null && _cachedWidgetSize != null &&
         TimerPositioningService.isNearScreenEdge(
           position: state.position,
           screenSize: _cachedScreenSize!,
           widgetSize: _cachedWidgetSize!,
           threshold: proximityThreshold,
         ));
    
    // Only snap if velocity is low AND we're near an edge
    return isLowVelocity && isNearEdge;
  }
  
  void _performMagneticSnap(Offset currentPosition, Size screenSize, Size widgetSize) {
    final snapPosition = TimerPositioningService.getNearestEdgePosition(
      position: currentPosition,
      screenSize: screenSize,
      widgetSize: widgetSize,
      padding: MediaQuery.of(context).padding,
      edgeMargin: 16.0,
    );
    
    _animateToPosition(snapPosition);
    HapticFeedback.mediumImpact();
  }
  
  // MARK: - Animation Helpers
  
  void _animateToPosition(Offset targetPosition) {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final startPosition = ref.read(timerPositionProvider).position;
    
    final animation = Tween<Offset>(
      begin: startPosition,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutBack,
    ));
    
    animation.addListener(() {
      positionNotifier.updatePosition(animation.value);
    });
    
    _snapController.forward().then((_) {
      _snapController.reset();
      // Save position after successful snap animation
      positionNotifier.saveAllState();
    });
  }
  
  void _triggerModeTransition() {
    _modeTransitionController.forward().then((_) {
      _modeTransitionController.reset();
    });
    
    // Update cached sizes for new mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCachedSizes();
    });
  }
  
  double _calculateAnimatedScale(TimerPositionState state) {
    final baseScale = 1.0;
    final dragScale = state.isDragging ? 1.05 : 1.0;
    final magneticScale = _isNearEdge ? 1.02 : 1.0;
    final transitionScale = 0.95 + (0.05 * Curves.easeOutCubic.transform(_modeTransitionController.value));
    
    return baseScale * dragScale * magneticScale * transitionScale;
  }
  
  // MARK: - Visual Components
  
  BoxDecoration _buildTimerDecoration(RestTimer timer, TimerPositionState state) {
    final layout = TimerLayoutManager.getLayout(state.mode);
    final colors = _getTimerGradientColors(timer);
    
    // Enhanced visual feedback for edge proximity
    final shadowBlurRadius = _isNearEdge ? 12.0 : 8.0;
    final shadowOpacity = _isNearEdge ? 0.3 : 0.15;
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(layout.borderRadius),
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(shadowOpacity),
          blurRadius: shadowBlurRadius,
          offset: const Offset(0, 4),
        ),
      ],
      // Subtle border when near edge for magnetic feedback
      border: _isNearEdge ? Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.0,
      ) : null,
    );
  }
  
  List<Color> _getTimerGradientColors(RestTimer timer) {
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
        Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ];
    }
  }
  
  Widget _buildTimerContent(RestTimer timer, TimerPositionState state, TimerLayout layout) {
    switch (state.mode) {
      case TimerDisplayMode.compact:
        return MinimizedTimerControls.compact(
          timer: timer,
          layout: layout,
        );
      case TimerDisplayMode.normal:
        return MinimizedTimerControls.normal(
          timer: timer,
          layout: layout,
          onPause: () => ref.read(currentTimerProvider.notifier).pauseTimer(),
          onResume: () => ref.read(currentTimerProvider.notifier).resumeTimer(),
          onSkip: () => ref.read(currentTimerProvider.notifier).skipTimer(),
        );
      case TimerDisplayMode.expanded:
        return MinimizedTimerControls.expanded(
          timer: timer,
          layout: layout,
          onPause: () => ref.read(currentTimerProvider.notifier).pauseTimer(),
          onResume: () => ref.read(currentTimerProvider.notifier).resumeTimer(),
          onSkip: () => ref.read(currentTimerProvider.notifier).skipTimer(),
          onAddTime: (seconds) => ref.read(currentTimerProvider.notifier).addTime(seconds),
          onReset: () => ref.read(currentTimerProvider.notifier).resetTimer(),
        );
    }
  }
  
  // MARK: - Helper Methods
  
  Size _calculateWidgetSize(TimerDisplayMode mode, Size screenSize, TimerLayout layout) {
    if (mode == TimerDisplayMode.expanded) {
      // Expanded mode uses full width minus margins
      return Size(screenSize.width - 32, layout.height);
    }
    return Size(layout.width, layout.height);
  }
  
  void _updateCachedSizes() {
    if (mounted && _cachedScreenSize != null) {
      final positionState = ref.read(timerPositionProvider);
      final layout = ref.read(currentTimerLayoutProvider);
      _cachedWidgetSize = _calculateWidgetSize(positionState.mode, _cachedScreenSize!, layout);
    }
  }
  
  /// Validates current position and corrects if outside valid bounds
  void _validateAndCorrectPosition() {
    if (!mounted || _cachedScreenSize == null) return;
    
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final currentState = ref.read(timerPositionProvider);
    final layout = ref.read(currentTimerLayoutProvider);
    
    final widgetSize = _calculateWidgetSize(currentState.mode, _cachedScreenSize!, layout);
    final correctedPosition = TimerPositioningService.getConstrainedPosition(
      position: currentState.position,
      screenSize: _cachedScreenSize!,
      widgetSize: widgetSize,
      screenPadding: MediaQuery.of(context).padding,
      minVisibleArea: const Size(48, 48),
    );
    
    // Only update if position needs correction
    if (correctedPosition != currentState.position) {
      positionNotifier.updatePosition(correctedPosition);
      positionNotifier.saveAllState();
    }
  }
  
  // MARK: - Memory Management
  
  @override
  void dispose() {
    _scaleController.dispose();
    _snapController.dispose();
    _modeTransitionController.dispose();
    _magneticController.dispose();
    
    // Clear cached values
    _cachedScreenSize = null;
    _cachedWidgetSize = null;
    
    super.dispose();
  }
}