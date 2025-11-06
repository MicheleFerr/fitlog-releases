import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart' as core;
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart' as ext;
import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_ui_state_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Tier-1 Minimal Timer Overlay - Refactored for Consolidated Provider System
/// 
/// Features:
/// - Uses unifiedTimerProvider for timer data
/// - Uses unified_timer_extensions for compatibility
/// - Smooth fade animations and compact design
/// - Draggable with no glitches
/// - No dot before seconds (cleaner look)
/// - Tier-1 quality animations and interactions
class Tier1MinimalTimerOverlay extends ConsumerStatefulWidget {
  const Tier1MinimalTimerOverlay({super.key});

  @override
  ConsumerState<Tier1MinimalTimerOverlay> createState() => _Tier1MinimalTimerOverlayState();
}

class _Tier1MinimalTimerOverlayState extends ConsumerState<Tier1MinimalTimerOverlay>
    with SingleTickerProviderStateMixin {
  
  // Animation controllers for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _expandAnimation;
  
  // Positioning state
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;
  
  // Widget size constants
  static const Size _collapsedSize = Size(72, 48);
  static const Size _expandedSize = Size(280, 88);
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSavedPosition();
    
    // CRITICAL FIX: Animation controller is now only used for dragging scale
    // Fade and expand animations are handled separately in build method
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    // CRITICAL FIX: These animations are kept for potential future use
    // but expand/collapse and show/hide are now handled directly in build
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));
    
    // Scale animation is still used for dragging feedback
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));
  }
  
  void _loadSavedPosition() {
    // Load position from UI state provider
    final uiState = ref.read(timerUIStateProvider);
    _position = uiState.position;
  }
  
  void _savePosition() {
    // Save position to UI state provider
    ref.read(timerUIStateProvider.notifier).updatePosition(_position);
  }

  @override
  Widget build(BuildContext context) {
    // Watch timer data from unified providers
    final timerState = ref.watch(core.unifiedTimerProvider);
    final remainingSeconds = ref.watch(core.timerRemainingSecondsProvider);
    final progress = ref.watch(ext.timerProgressProvider);
    final isActive = ref.watch(ext.timerIsActiveProvider);
    final uiState = ref.watch(timerUIStateProvider);
    
    // Early return if should not show
    // Keep showing if timer exists but is completed (so user can see 00:00)
    if (timerState == null || !uiState.isVisible) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final screenPadding = MediaQuery.of(context).padding;
    
    // Use position from UI state if available, otherwise local state
    final position = uiState.position != Offset.zero ? uiState.position : _position;
    
    // Use expanded state from provider, not local state
    final isExpanded = uiState.isExpanded;
    
    final constrainedPosition = _getConstrainedPosition(
      position, 
      screenSize, 
      screenPadding,
      isExpanded: isExpanded,
    );

    return Positioned(
      left: constrainedPosition.dx,
      top: constrainedPosition.dy,
      child: Semantics(
        label: 'Timer',
        hint: isExpanded 
          ? 'Tap to collapse' 
          : 'Tap to expand',
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // CRITICAL FIX: Use isExpanded from provider directly for size calculation
            // Don't tie this to animation controller which is used only for fade-in
            final currentSize = Size.lerp(
              _collapsedSize, 
              _expandedSize, 
              isExpanded ? 1.0 : 0.0, // Direct boolean, not animation value
            )!;
            
            return AnimatedOpacity(
              // CRITICAL FIX: Keep opacity at 1.0 when visible, only use fade for show/hide
              opacity: uiState.isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Transform.scale(
                scale: _isDragging ? _scaleAnimation.value : 1.0,
                child: AnimatedContainer(
                  // CRITICAL FIX: Use AnimatedContainer for smooth size transitions
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutQuint,
                  width: currentSize.width,
                  height: currentSize.height,
                  child: GestureDetector(
                    onTap: _handleTap,
                    onLongPress: _handleLongPress,
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    child: DecoratedBox(
                      decoration: _buildDecoration(timerState, progress),
                      child: _buildContent(timerState, remainingSeconds, progress),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  // MARK: - Gesture Handlers
  
  void _handleTap() {
    // Toggle expanded state in provider
    ref.read(timerUIStateProvider.notifier).toggleExpanded();
    
    final isExpanded = ref.read(timerUIStateProvider).isExpanded;
    
    // CRITICAL FIX: Only animate expand/collapse, NOT fade
    // The fade animation should remain at 1.0 to keep widget visible
    // We'll handle expand animation separately in the build method
    
    HapticFeedback.selectionClick();
  }
  
  void _handleLongPress() {
    // Long press for quick actions
    _showQuickActions(context);
    HapticFeedback.mediumImpact();
  }
  
  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    HapticFeedback.lightImpact();
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }
  
  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    final screenSize = MediaQuery.of(context).size;
    final velocity = details.velocity.pixelsPerSecond;
    
    // Magnetismo ai bordi se velocità bassa
    if (velocity.distance < 100) {
      _snapToNearestEdge(screenSize);
    }
    
    _savePosition();
  }
  
  // MARK: - Visual Components
  
  BoxDecoration _buildDecoration(UnifiedTimerState timerState, double progress) {
    final colorValues = ref.watch(ext.timerColorProvider);
    final gradientColors = colorValues.map((colorInt) => Color(colorInt)).toList();
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: context.colors.onSurface.withValues(alpha: _isDragging ? 0.25 : 0.12),
          blurRadius: _isDragging ? 10 : 6,
          offset: const Offset(0, 3),
          spreadRadius: _isDragging ? 1 : 0,
        ),
      ],
      border: _isDragging 
        ? Border.all(color: context.colors.surface.withValues(alpha: 0.35), width: 1)
        : null,
    );
  }
  
  Widget _buildContent(UnifiedTimerState timerState, int remainingSeconds, double progress) {
    final isExpanded = ref.watch(timerUIStateProvider.select((state) => state.isExpanded));
    
    if (isExpanded) {
      return _buildExpandedContent(timerState, remainingSeconds, progress);
    } else {
      return _buildCollapsedContent(remainingSeconds);
    }
  }
  
  Widget _buildCollapsedContent(int remainingSeconds) {
    final timeText = _formatTime(remainingSeconds);
    
    return Center(
      child: Text(
        timeText,
        style: TextStyle(
          color: context.colors.surface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
          height: 1.0,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildExpandedContent(UnifiedTimerState timerState, int remainingSeconds, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Progress indicator - more compact
          _buildProgressIndicator(progress),
          
          SizedBox(width: 10),
          
          // Timer info - more compact layout
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(remainingSeconds),
                  style: TextStyle(
                    color: context.colors.surface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    height: 1.1,
                  ),
                ),
                if (timerState.exerciseName != null) ...[
                  SizedBox(height: 2),
                  Text(
                    timerState.exerciseName!,
                    style: TextStyle(
                      color: context.colors.surface.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Quick controls - more compact
          _buildQuickControls(timerState),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(double progress) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          // Background circle
          CustomPaint(
            size: const Size(28, 28),
            painter: _ProgressRingPainter(
              progress: 1.0,
              color: context.colors.surface.withValues(alpha: 0.25),
              strokeWidth: 2.5,
            ),
          ),
          // Progress circle
          CustomPaint(
            size: const Size(28, 28),
            painter: _ProgressRingPainter(
              progress: progress,
              color: context.colors.surface,
              strokeWidth: 2.5,
            ),
          ),
          // Center icon
          Center(
            child: Icon(
              AppIcons.timer,
              color: context.colors.surface,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickControls(UnifiedTimerState timerState) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(
          icon: timerState.isPaused ? AppIcons.playArrowRounded : AppIcons.pauseRounded,
          onPressed: () => _handlePauseResume(timerState),
          semanticLabel: timerState.isPaused 
            ? AppLocalizations.of(context).resume 
            : 'Pause',
        ),
        const SizedBox(width: 6),
        _buildControlButton(
          icon: AppIcons.skipNextRounded,
          onPressed: _handleSkip,
          semanticLabel: 'Skip',
        ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: context.colors.surface.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: context.colors.surface,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
  
  // MARK: - Helper Methods
  
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    // No dot before seconds - cleaner, more compact design
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  Offset _getConstrainedPosition(Offset position, Size screenSize, EdgeInsets padding, {bool? isExpanded}) {
    final currentSize = (isExpanded ?? false) ? _expandedSize : _collapsedSize;
    const minVisibleWidth = 48.0; // Sempre 48px visibili
    
    final maxLeft = screenSize.width - minVisibleWidth;
    final maxTop = screenSize.height - currentSize.height - padding.bottom;
    
    return Offset(
      position.dx.clamp(-currentSize.width + minVisibleWidth, maxLeft),
      position.dy.clamp(padding.top, maxTop),
    );
  }
  
  void _snapToNearestEdge(Size screenSize) {
    final screenCenter = screenSize.width / 2;
    
    setState(() {
      if (_position.dx < screenCenter) {
        // Snap to left edge
        _position = Offset(16, _position.dy);
      } else {
        // Snap to right edge
        _position = Offset(screenSize.width - _collapsedSize.width - 16, _position.dy);
      }
    });
    
    HapticFeedback.mediumImpact();
  }
  
  // MARK: - Action Handlers
  
  void _handlePauseResume(UnifiedTimerState timerState) async {
    final timerNotifier = ref.read(core.unifiedTimerProvider.notifier);
    
    if (timerState.isPaused) {
      await timerNotifier.resumeTimer();
    } else {
      await timerNotifier.pauseTimer();
    }
  }
  
  void _handleSkip() async {
    final timerNotifier = ref.read(core.unifiedTimerProvider.notifier);
    await timerNotifier.stopTimer();
  }
  
  void _showQuickActions(BuildContext context) {
    // TODO: Implementare bottom sheet con azioni veloci
    // - Add/Remove time
    // - Reset timer  
    // - Settings
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Custom painter per progress ring ottimizzato
class _ProgressRingPainter extends CustomPainter {

  const _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (progress >= 1.0) {
      // Draw full circle
      canvas.drawCircle(center, radius, paint);
    } else {
      // Draw arc
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
