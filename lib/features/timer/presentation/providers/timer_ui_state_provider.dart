import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';

/// Timer UI State Provider - Gestisce SOLO lo stato UI del timer
/// 
/// Separato dalla logica timer per rispettare CLAUDE.md (max 3 providers)
/// Gestisce: posizione, visibilità, espansione, animazioni
class TimerUIState {
  final Offset position;
  final bool isVisible;
  final bool isExpanded;
  final bool isMinimized;
  final bool isDragging;
  final double opacity;
  
  const TimerUIState({
    this.position = const Offset(20, 100),
    this.isVisible = false,
    this.isExpanded = false,
    this.isMinimized = false,
    this.isDragging = false,
    this.opacity = 1.0,
  });
  
  TimerUIState copyWith({
    Offset? position,
    bool? isVisible,
    bool? isExpanded,
    bool? isMinimized,
    bool? isDragging,
    double? opacity,
  }) {
    return TimerUIState(
      position: position ?? this.position,
      isVisible: isVisible ?? this.isVisible,
      isExpanded: isExpanded ?? this.isExpanded,
      isMinimized: isMinimized ?? this.isMinimized,
      isDragging: isDragging ?? this.isDragging,
      opacity: opacity ?? this.opacity,
    );
  }
}

class TimerUIStateNotifier extends StateNotifier<TimerUIState> {
  final Ref ref;
  SharedPreferences? _prefs;
  
  TimerUIStateNotifier(this.ref) : super(const TimerUIState()) {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final x = _prefs?.getDouble('timer_position_x') ?? 20;
    final y = _prefs?.getDouble('timer_position_y') ?? 100;
    state = state.copyWith(position: Offset(x, y));
  }
  
  Future<void> _savePosition() async {
    await _prefs?.setDouble('timer_position_x', state.position.dx);
    await _prefs?.setDouble('timer_position_y', state.position.dy);
  }
  
  void updatePosition(Offset newPosition) {
    state = state.copyWith(position: newPosition);
    _savePosition();
  }
  
  void startDragging() {
    state = state.copyWith(isDragging: true);
  }
  
  void stopDragging() {
    state = state.copyWith(isDragging: false);
  }
  
  void show() {
    state = state.copyWith(isVisible: true);
  }
  
  void hide() {
    state = state.copyWith(isVisible: false);
  }
  
  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }
  
  void expand() {
    state = state.copyWith(isExpanded: true, isMinimized: false);
  }
  
  void collapse() {
    state = state.copyWith(isExpanded: false);
  }
  
  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }
  
  void minimize() {
    state = state.copyWith(isMinimized: true, isExpanded: false);
  }
  
  void restore() {
    state = state.copyWith(isMinimized: false);
  }
  
  void setOpacity(double opacity) {
    state = state.copyWith(opacity: opacity.clamp(0.0, 1.0));
  }
  
  void fadeIn() {
    state = state.copyWith(opacity: 1.0);
  }
  
  void fadeOut() {
    state = state.copyWith(opacity: 0.0);
  }
}

/// Provider principale per lo stato UI del timer
final timerUIStateProvider = StateNotifierProvider<TimerUIStateNotifier, TimerUIState>((ref) {
  return TimerUIStateNotifier(ref);
});

/// Provider derivato per visibilità con logica timer attivo
final shouldShowTimerUIProvider = Provider<bool>((ref) {
  final uiState = ref.watch(timerUIStateProvider);
  final isTimerActive = ref.watch(
    unifiedTimerProvider.select((state) => state?.isActive ?? false)
  );
  
  return uiState.isVisible && isTimerActive;
});

/// Provider per animazioni fluide
final timerUIAnimationProvider = Provider<Map<String, double>>((ref) {
  final uiState = ref.watch(timerUIStateProvider);
  
  return {
    'scale': uiState.isDragging ? 1.05 : 1.0,
    'opacity': uiState.opacity,
    'expandProgress': uiState.isExpanded ? 1.0 : 0.0,
    'minimizeProgress': uiState.isMinimized ? 1.0 : 0.0,
  };
});

/// Provider per constraints di posizione
final timerPositionConstraintsProvider = Provider<BoxConstraints>((ref) {
  return const BoxConstraints(
    minWidth: 72,
    minHeight: 48,
    maxWidth: 280,
    maxHeight: 88,
  );
});