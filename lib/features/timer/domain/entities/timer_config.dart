import 'package:flutter/material.dart';

/// Configurazione per il timer minimizzabile
/// Permette di personalizzare comportamenti e aspetto

class TimerConfig {
  /// Soglia per snap ai bordi (distanza in pixel)
  static const double edgeSnapThreshold = 50.0;
  
  /// Margine dai bordi quando si fa snap
  static const double edgeMargin = 16.0;
  
  /// Soglia per pinch gesture (scala)
  static const double pinchInThreshold = 0.8;
  static const double pinchOutThreshold = 1.2;
  
  /// Durate delle animazioni
  static const Duration scaleAnimationDuration = Duration(milliseconds: 200);
  static const Duration positionAnimationDuration = Duration(milliseconds: 300);
  static const Duration modeTransitionDuration = Duration(milliseconds: 400);
  
  /// Haptic feedback settings
  static const bool enableHapticFeedback = true;
  
  /// Auto-hide timer in compact mode dopo inattività (secondi)
  static const int autoHideDelaySeconds = 30;
  
  /// Shadow elevation per drag
  static const double dragShadowElevation = 12.0;
  static const double normalShadowElevation = 8.0;
  
  /// Opacity per compact mode quando inattivo
  static const double compactInactiveOpacity = 0.7;
  
  /// Corner radius per ogni modalità
  static const double compactBorderRadius = 20.0;
  static const double normalBorderRadius = 16.0;
  static const double expandedBorderRadius = 20.0;
  
  /// Debug mode (mostra info posizione e gesture)
  static const bool debugMode = false;
}

/// Personalizzazioni colore per il timer
class TimerColors {
  /// Colori per stato normale
  static const List<Color> normalGradient = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];
  
  /// Colori per stato paused
  static const List<Color> pausedGradient = [
    Color(0xFFFF9800),
    Color(0xFFF57C00),
  ];
  
  /// Colori per stato completato
  static const List<Color> completedGradient = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];
  
  /// Colori per stato critico (< 30 secondi)
  static const List<Color> criticalGradient = [
    Color(0xFFF44336),
    Color(0xFFD32F2F),
  ];
  
  /// Colori per stato warning (< 60 secondi)
  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFF57C00),
  ];
}