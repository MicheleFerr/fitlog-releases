import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/timer_display_mode.dart';
import '../services/timer_positioning_service.dart';

/// Stato per posizione e modalità del timer
class TimerPositionState {
  final Offset position;
  final TimerDisplayMode mode;
  final bool isSnappedToEdge;
  final bool isDragging;
  final double scale;

  const TimerPositionState({
    required this.position,
    required this.mode,
    this.isSnappedToEdge = false,
    this.isDragging = false,
    this.scale = 1.0,
  });

  TimerPositionState copyWith({
    Offset? position,
    TimerDisplayMode? mode,
    bool? isSnappedToEdge,
    bool? isDragging,
    double? scale,
  }) {
    return TimerPositionState(
      position: position ?? this.position,
      mode: mode ?? this.mode,
      isSnappedToEdge: isSnappedToEdge ?? this.isSnappedToEdge,
      isDragging: isDragging ?? this.isDragging,
      scale: scale ?? this.scale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerPositionState &&
        other.position == position &&
        other.mode == mode &&
        other.isSnappedToEdge == isSnappedToEdge &&
        other.isDragging == isDragging &&
        other.scale == scale;
  }

  @override
  int get hashCode {
    return Object.hash(position, mode, isSnappedToEdge, isDragging, scale);
  }
}

/// Notifier per gestire posizione e stato del timer
class TimerPositionNotifier extends StateNotifier<TimerPositionState> {
  TimerPositionNotifier() : super(
    const TimerPositionState(
      position: Offset(20, 100),
      mode: TimerDisplayMode.normal,
    ),
  ) {
    _loadSavedState();
  }

  static const String _positionXKey = 'timer_position_x';
  static const String _positionYKey = 'timer_position_y';
  static const String _modeKey = 'timer_display_mode';
  static const String _scaleKey = 'timer_scale';

  /// Aggiorna la posizione del timer
  Future<void> updatePosition(Offset newPosition) async {
    state = state.copyWith(position: newPosition);
    await _savePosition();
  }

  /// Aggiorna la modalità display del timer
  Future<void> updateMode(TimerDisplayMode newMode) async {
    if (state.mode != newMode) {
      state = state.copyWith(mode: newMode);
      await _saveMode();
    }
  }

  /// Cicla alla modalità successiva (per tap gesture)
  Future<void> cycleToNextMode() async {
    final nextMode = TimerLayoutManager.getNextMode(state.mode);
    await updateMode(nextMode);
  }

  /// Aggiorna modalità basata su scale gesture
  Future<void> updateModeFromScale(double scale) async {
    final newMode = TimerLayoutManager.getModeFromScale(scale, state.mode);
    if (newMode != state.mode) {
      await updateMode(newMode);
    }
  }

  /// Imposta stato di snap ai bordi
  void setSnapToEdge(bool snapped) {
    if (state.isSnappedToEdge != snapped) {
      state = state.copyWith(isSnappedToEdge: snapped);
    }
  }

  /// Imposta stato di dragging
  void setDragging(bool dragging) {
    if (state.isDragging != dragging) {
      state = state.copyWith(isDragging: dragging);
    }
  }

  /// Aggiorna la scala durante gesture
  void updateScale(double scale) {
    if (state.scale != scale) {
      state = state.copyWith(scale: scale);
    }
  }

  /// Resetta la scala a 1.0
  void resetScale() {
    if (state.scale != 1.0) {
      state = state.copyWith(scale: 1.0);
    }
  }

  /// Calcola posizione vincolata ai bordi dello schermo con enhanced constraints
  Offset constrainToScreen(Offset position, Size screenSize, Size widgetSize, [EdgeInsets? padding]) {
    final screenPadding = padding ?? EdgeInsets.zero;
    
    return TimerPositioningService.getConstrainedPosition(
      position: position,
      screenSize: screenSize,
      widgetSize: widgetSize,
      screenPadding: screenPadding,
      minVisibleArea: const Size(48, 48), // iOS/Android standard
    );
  }

  /// Calcola distanza dal bordo più vicino usando service avanzato
  double getDistanceToNearestEdge(Offset position, Size screenSize, Size widgetSize) {
    return TimerPositioningService.isNearScreenEdge(
      position: position,
      screenSize: screenSize,
      widgetSize: widgetSize,
    ) ? 0.0 : 50.0; // Simplified per backward compatibility
  }

  /// Calcola posizione del bordo più vicino usando service avanzato
  Offset getNearestEdgePosition(Offset position, Size screenSize, Size widgetSize, [EdgeInsets? padding]) {
    final screenPadding = padding ?? EdgeInsets.zero;
    
    return TimerPositioningService.getNearestEdgePosition(
      position: position,
      screenSize: screenSize,
      widgetSize: widgetSize,
      padding: screenPadding,
    );
  }

  /// Verifica se il timer è vicino a un bordo usando service avanzato
  bool isNearEdge(Size screenSize, Size widgetSize, {double threshold = 40.0}) {
    return TimerPositioningService.isNearScreenEdge(
      position: state.position,
      screenSize: screenSize,
      widgetSize: widgetSize,
      threshold: threshold,
    );
  }

  /// Carica stato salvato dalle preferenze con validazione enhanced
  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final x = prefs.getDouble(_positionXKey) ?? 20.0;
      final y = prefs.getDouble(_positionYKey) ?? 100.0;
      final modeIndex = prefs.getInt(_modeKey) ?? TimerDisplayMode.normal.index;
      final scale = prefs.getDouble(_scaleKey) ?? 1.0;
      
      // Assicurati che l'indice sia valido
      final mode = modeIndex < TimerDisplayMode.values.length 
          ? TimerDisplayMode.values[modeIndex]
          : TimerDisplayMode.normal;
      
      // Valida posizione caricata (potrebbe essere da schermo diverso)
      final loadedPosition = Offset(x, y);
      
      state = TimerPositionState(
        position: loadedPosition,
        mode: mode,
        scale: scale,
      );
      
      // Pianifica validazione posizione al prossimo frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _validateLoadedPosition();
      });
    } catch (e) {
      // In caso di errore, usa valori di default
      debugPrint('Errore nel caricamento stato timer: $e');
      _setDefaultPosition();
    }
  }

  /// Salva posizione nelle preferenze
  Future<void> _savePosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setDouble(_positionXKey, state.position.dx),
        prefs.setDouble(_positionYKey, state.position.dy),
      ]);
    } catch (e) {
      debugPrint('Errore nel salvataggio posizione timer: $e');
    }
  }

  /// Salva modalità nelle preferenze
  Future<void> _saveMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_modeKey, state.mode.index);
    } catch (e) {
      debugPrint('Errore nel salvataggio modalità timer: $e');
    }
  }

  /// Salva scala nelle preferenze
  Future<void> _saveScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_scaleKey, state.scale);
    } catch (e) {
      debugPrint('Errore nel salvataggio scala timer: $e');
    }
  }

  /// Salva tutto lo stato
  Future<void> saveAllState() async {
    await Future.wait([
      _savePosition(),
      _saveMode(),
      _saveScale(),
    ]);
  }
  
  /// Valida posizione caricata e corregge se necessario
  void _validateLoadedPosition() {
    // Segna che la posizione è stata caricata e potrebbe necessitare validazione
    // La validazione effettiva avverrà quando il widget avrà accesso alle dimensioni schermo
    _needsValidation = true;
  }
  
  // Flag per sapere se la posizione necessita validazione
  bool _needsValidation = false;
  
  /// Verifica se la posizione necessita validazione
  bool get needsValidation => _needsValidation;
  
  /// Reset completo della posizione del timer alla posizione di default
  Future<void> resetToDefaultPosition() async {
    debugPrint('Resetting timer position to default');
    
    // Elimina i valori salvati
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_positionXKey),
        prefs.remove(_positionYKey),
        prefs.remove(_modeKey),
        prefs.remove(_scaleKey),
      ]);
    } catch (e) {
      debugPrint('Error clearing timer position preferences: $e');
    }
    
    // Ripristina stato di default
    state = const TimerPositionState(
      position: Offset(20, 100),
      mode: TimerDisplayMode.normal,
      scale: 1.0,
    );
    
    _needsValidation = false;
  }
  
  /// Imposta posizione di default sicura
  void _setDefaultPosition() {
    state = TimerPositionState(
      position: const Offset(20, 100), // Default safe position
      mode: TimerDisplayMode.normal,
      scale: 1.0,
    );
  }
  
  /// Metodo per validazione posizione da widget (con accesso alle dimensioni)
  Future<void> validateAndCorrectPosition(Size screenSize, Size widgetSize, EdgeInsets padding) async {
    // Verifica se la posizione è completamente fuori schermo
    final isVisible = TimerPositioningService.isPositionFullyVisible(
      position: state.position,
      widgetSize: widgetSize,
      screenSize: screenSize,
      screenPadding: padding,
      minVisibleThreshold: 0.2, // Anche solo 20% visibile è accettabile
    );
    
    if (!isVisible) {
      // Se completamente fuori schermo, riporta al centro sicuro
      final safePosition = TimerPositioningService.getSafeCenterPosition(
        screenSize: screenSize,
        widgetSize: widgetSize,
        screenPadding: padding,
      );
      
      debugPrint('Timer was completely off-screen, resetting to safe center: $safePosition');
      await updatePosition(safePosition);
    } else {
      // Altrimenti applica solo constraints normali
      final correctedPosition = TimerPositioningService.getConstrainedPosition(
        position: state.position,
        screenSize: screenSize,
        widgetSize: widgetSize,
        screenPadding: padding,
        minVisibleArea: const Size(48, 48),
      );
      
      if (correctedPosition != state.position) {
        await updatePosition(correctedPosition);
      }
    }
    
    // Reset flag validazione
    _needsValidation = false;
  }
}

/// Provider per lo stato di posizione del timer
final timerPositionProvider = StateNotifierProvider<TimerPositionNotifier, TimerPositionState>(
  (ref) => TimerPositionNotifier(),
);

/// Provider computed per verificare se il timer dovrebbe fare snap ai bordi
final timerShouldSnapProvider = Provider<bool>((ref) {
  final positionState = ref.watch(timerPositionProvider);
  return TimerLayoutManager.shouldSnapToEdge(positionState.mode);
});

/// Provider computed per il layout corrente del timer
final currentTimerLayoutProvider = Provider<TimerLayout>((ref) {
  final positionState = ref.watch(timerPositionProvider);
  return TimerLayoutManager.getLayout(positionState.mode);
});