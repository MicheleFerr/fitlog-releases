import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/timer_provider.dart';
import '../providers/timer_position_provider.dart';
import 'draggable_timer_overlay.dart';
import 'timer_recovery_fab.dart';

/// Sistema completo di timer draggable per GymBro FitLog Pro
/// 
/// Combina tutti i componenti per la gestione drag constraints:
/// - DraggableTimerOverlay: Timer principale con constraints
/// - TimerRecoveryFAB: FAB per recupero timer fuori schermo
/// - State management integrato con Riverpod
/// - Performance ottimizzato per workout sessions lunghe
/// 
/// Usage:
/// ```dart
/// // In your main workout screen
/// Scaffold(
///   body: Stack(
///     children: [
///       // Your main workout content
///       WorkoutContent(),
///       
///       // Enhanced timer system
///       EnhancedDraggableTimerSystem(),
///     ],
///   ),
/// )
/// ```
class EnhancedDraggableTimerSystem extends ConsumerStatefulWidget {
  /// Callback chiamato quando timer viene espanso tramite FAB
  final VoidCallback? onTimerExpanded;
  
  /// Custom positioning per FAB recovery
  final Alignment fabAlignment;
  
  /// Margins per FAB recovery
  final EdgeInsets fabMargins;
  
  /// Enable/disable debug overlays per sviluppo
  final bool showDebugOverlays;
  
  const EnhancedDraggableTimerSystem({
    super.key,
    this.onTimerExpanded,
    this.fabAlignment = Alignment.bottomRight,
    this.fabMargins = const EdgeInsets.all(16.0),
    this.showDebugOverlays = false,
  });

  @override
  ConsumerState<EnhancedDraggableTimerSystem> createState() => _EnhancedDraggableTimerSystemState();
}

class _EnhancedDraggableTimerSystemState extends ConsumerState<EnhancedDraggableTimerSystem>
    with WidgetsBindingObserver {
  
  // Performance tracking
  int _rebuildsCount = 0;
  DateTime? _lastRebuildTime;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedulePositionValidation();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  /// Schedule position validation on next frame
  void _schedulePositionValidation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateTimerPosition();
    });
  }
  
  /// Handle device rotation and screen size changes
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Clear positioning cache on screen changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleScreenSizeChange();
    });
  }
  
  /// Handle app lifecycle changes for memory management
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        // App going to background - save state
        _saveCurrentState();
        break;
      case AppLifecycleState.resumed:
        // App returning from background - validate position
        _schedulePositionValidation();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Performance tracking per debug
    if (widget.showDebugOverlays) {
      _rebuildsCount++;
      _lastRebuildTime = DateTime.now();
    }
    
    final timer = ref.watch(currentTimerProvider);
    
    // Early return se nessun timer attivo
    if (timer == null || !timer.isActive) {
      return const SizedBox.shrink();
    }
    
    return Stack(
      children: [
        // Main draggable timer overlay
        const DraggableTimerOverlay(),
        
        // Recovery FAB (appare quando timer è fuori schermo)
        TimerRecoveryFAB(
          onExpand: widget.onTimerExpanded,
          fabAlignment: widget.fabAlignment,
          margins: widget.fabMargins,
        ),
        
        // Debug overlays se abilitati
        if (widget.showDebugOverlays)
          _buildDebugOverlays(context),
      ],
    );
  }
  
  // MARK: - Position Management
  
  /// Valida e corregge posizione timer se necessario
  void _validateTimerPosition() {
    if (!mounted) return;
    
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    final screenSize = MediaQuery.of(context).size;
    final screenPadding = MediaQuery.of(context).padding;
    final currentState = ref.read(timerPositionProvider);
    final layout = ref.read(currentTimerLayoutProvider);
    
    // Calcola dimensioni widget per modalità corrente
    final widgetSize = Size(
      currentState.mode.name == 'expanded' 
          ? screenSize.width - 32 
          : layout.width,
      layout.height,
    );
    
    // Valida e correggi posizione se necessario
    positionNotifier.validateAndCorrectPosition(
      screenSize,
      widgetSize,
      screenPadding,
    );
  }
  
  /// Gestisce cambi di dimensione schermo (rotazione, etc.)
  void _handleScreenSizeChange() {
    if (!mounted) return;
    
    // Clear any positioning caches
    // PositioningCache.clearCache(); // Se implementato
    
    // Re-validate position for new screen size
    _validateTimerPosition();
    
    // Force rebuild per aggiornare layout
    if (mounted) {
      setState(() {});
    }
  }
  
  /// Salva stato corrente per persistenza
  void _saveCurrentState() {
    final positionNotifier = ref.read(timerPositionProvider.notifier);
    positionNotifier.saveAllState();
  }
  
  // MARK: - Debug Overlays
  
  Widget _buildDebugOverlays(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Timer System Debug',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _buildDebugLine('Rebuilds', _rebuildsCount.toString()),
            _buildDebugLine('Last Rebuild', 
              _lastRebuildTime?.toString().split('.')[0] ?? 'N/A'),
            _buildDebugLine('Screen Size', 
              '${MediaQuery.of(context).size.width.round()}x${MediaQuery.of(context).size.height.round()}'),
            Consumer(
              builder: (context, ref, child) {
                final positionState = ref.watch(timerPositionProvider);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDebugLine('Position', 
                      '(${positionState.position.dx.round()}, ${positionState.position.dy.round()})'),
                    _buildDebugLine('Mode', positionState.mode.name),
                    _buildDebugLine('Dragging', positionState.isDragging.toString()),
                    _buildDebugLine('Snapped', positionState.isSnappedToEdge.toString()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDebugLine(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontFamily: 'monospace',
      ),
    );
  }
}

/// Provider computed per stato del sistema timer
final timerSystemStateProvider = Provider<TimerSystemState>((ref) {
  final timer = ref.watch(currentTimerProvider);
  final positionState = ref.watch(timerPositionProvider);
  
  return TimerSystemState(
    hasActiveTimer: timer != null && timer.isActive,
    isTimerVisible: true, // Sarà calcolato dal widget
    currentMode: positionState.mode,
    isDragging: positionState.isDragging,
    isSnappedToEdge: positionState.isSnappedToEdge,
  );
});

/// Stato del sistema timer per provider computed
class TimerSystemState {
  final bool hasActiveTimer;
  final bool isTimerVisible;
  final TimerDisplayMode currentMode;
  final bool isDragging;
  final bool isSnappedToEdge;
  
  const TimerSystemState({
    required this.hasActiveTimer,
    required this.isTimerVisible,
    required this.currentMode,
    required this.isDragging,
    required this.isSnappedToEdge,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerSystemState &&
        other.hasActiveTimer == hasActiveTimer &&
        other.isTimerVisible == isTimerVisible &&
        other.currentMode == currentMode &&
        other.isDragging == isDragging &&
        other.isSnappedToEdge == isSnappedToEdge;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      hasActiveTimer,
      isTimerVisible,
      currentMode,
      isDragging,
      isSnappedToEdge,
    );
  }
}

/// Extension per easy access a timer system state
extension TimerSystemStateX on WidgetRef {
  TimerSystemState get timerSystemState => read(timerSystemStateProvider);
}