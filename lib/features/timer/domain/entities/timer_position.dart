import 'package:flutter/material.dart';

/// Posizioni fisse disponibili per il timer
enum TimerPosition {
  /// Timer in alto al centro
  top,
  
  /// Timer in basso al centro
  bottom,
  
  /// Timer a sinistra al centro
  left,
  
  /// Timer a destra al centro
  right,
}

/// Modalità di visualizzazione del timer
enum TimerDisplayMode {
  /// Modalità normale: timer completo con controlli
  normal,
  
  /// Modalità compatta: solo tempo rimanente
  compact,
}

/// Configurazione per il timer
class TimerDisplaySettings {
  final TimerPosition position;
  final TimerDisplayMode displayMode;
  final bool isVisible;

  const TimerDisplaySettings({
    this.position = TimerPosition.top,
    this.displayMode = TimerDisplayMode.normal,
    this.isVisible = true,
  });

  TimerDisplaySettings copyWith({
    TimerPosition? position,
    TimerDisplayMode? displayMode,
    bool? isVisible,
  }) {
    return TimerDisplaySettings(
      position: position ?? this.position,
      displayMode: displayMode ?? this.displayMode,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position.name,
      'displayMode': displayMode.name,
      'isVisible': isVisible,
    };
  }

  factory TimerDisplaySettings.fromJson(Map<String, dynamic> json) {
    return TimerDisplaySettings(
      position: TimerPosition.values.firstWhere(
        (e) => e.name == json['position'],
        orElse: () => TimerPosition.top,
      ),
      displayMode: TimerDisplayMode.values.firstWhere(
        (e) => e.name == json['displayMode'],
        orElse: () => TimerDisplayMode.normal,
      ),
      isVisible: json['isVisible'] ?? true,
    );
  }
}

/// Helper per calcolare posizione sullo schermo
class TimerPositionHelper {
  /// Calcola l'offset per una posizione specifica
  static Offset getOffsetForPosition(
    TimerPosition position, 
    Size screenSize, 
    Size timerSize,
  ) {
    const margin = 16.0;
    
    switch (position) {
      case TimerPosition.top:
        return Offset(
          (screenSize.width - timerSize.width) / 2,
          margin + 60, // Considera l'AppBar
        );
        
      case TimerPosition.bottom:
        return Offset(
          (screenSize.width - timerSize.width) / 2,
          screenSize.height - timerSize.height - margin - 80, // Considera FAB
        );
        
      case TimerPosition.left:
        return Offset(
          margin,
          (screenSize.height - timerSize.height) / 2,
        );
        
      case TimerPosition.right:
        return Offset(
          screenSize.width - timerSize.width - margin,
          (screenSize.height - timerSize.height) / 2,
        );
    }
  }

  /// Ottiene le dimensioni del timer per la modalità specifica
  static Size getSizeForMode(TimerDisplayMode mode) {
    switch (mode) {
      case TimerDisplayMode.normal:
        return const Size(320, 160); // Aumentato da 140 a 160
      case TimerDisplayMode.compact:
        return const Size(120, 50);
    }
  }

  /// Verifica se una posizione è orizzontale
  static bool isHorizontalPosition(TimerPosition position) {
    return position == TimerPosition.left || position == TimerPosition.right;
  }

  /// Verifica se una posizione è verticale
  static bool isVerticalPosition(TimerPosition position) {
    return position == TimerPosition.top || position == TimerPosition.bottom;
  }
}