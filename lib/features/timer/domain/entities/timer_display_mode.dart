enum TimerDisplayMode {
  /// Compact mode: solo tempo rimanente (80x40px)
  /// Perfetto per non occupare spazio durante allenamento
  compact,
  
  /// Normal mode: timer + controlli base (280x120px)
  /// Modalità standard con progress ring e controlli principali
  normal,
  
  /// Expanded mode: timer + controlli avanzati + stats (full width x 200px)
  /// Modalità completa con tutte le funzionalità e statistiche
  expanded,
}

/// Layout configuration per ogni modalità display
class TimerLayout {
  final double width;
  final double height;
  final bool showProgress;
  final bool showControls;
  final bool showExtras;
  final double borderRadius;
  final double fontSize;

  const TimerLayout({
    required this.width,
    required this.height,
    required this.showProgress,
    required this.showControls,
    this.showExtras = false,
    this.borderRadius = 16,
    this.fontSize = 16,
  });
}

/// Manager per layouts dei diversi stati del timer
class TimerLayoutManager {
  /// Layout configurations per ogni modalità
  static const Map<TimerDisplayMode, TimerLayout> _layouts = {
    TimerDisplayMode.compact: TimerLayout(
      width: 80,
      height: 40,
      showProgress: false,
      showControls: false,
      borderRadius: 20,
      fontSize: 16,
    ),
    TimerDisplayMode.normal: TimerLayout(
      width: 280,
      height: 120,
      showProgress: true,
      showControls: true,
      borderRadius: 16,
      fontSize: 24,
    ),
    TimerDisplayMode.expanded: TimerLayout(
      width: 360, // Sarà adattato a full width nel widget
      height: 200,
      showProgress: true,
      showControls: true,
      showExtras: true,
      borderRadius: 20,
      fontSize: 36,
    ),
  };

  /// Ottiene il layout per una specifica modalità
  static TimerLayout getLayout(TimerDisplayMode mode) {
    return _layouts[mode] ?? _layouts[TimerDisplayMode.normal]!;
  }

  /// Ottiene la modalità successiva nel ciclo (per tap gesture)
  static TimerDisplayMode getNextMode(TimerDisplayMode currentMode) {
    switch (currentMode) {
      case TimerDisplayMode.compact:
        return TimerDisplayMode.normal;
      case TimerDisplayMode.normal:
        return TimerDisplayMode.expanded;
      case TimerDisplayMode.expanded:
        return TimerDisplayMode.compact;
    }
  }

  /// Ottiene la modalità basata su scale gesture
  static TimerDisplayMode getModeFromScale(double scale, TimerDisplayMode currentMode) {
    if (scale < 0.8) {
      return TimerDisplayMode.compact;
    } else if (scale > 1.2) {
      return TimerDisplayMode.expanded;
    }
    return currentMode;
  }

  /// Verifica se una modalità dovrebbe snap ai bordi
  static bool shouldSnapToEdge(TimerDisplayMode mode) {
    return mode == TimerDisplayMode.compact;
  }
}