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
/// Note: Domain layer uses const colors since BuildContext isn't available.
/// These semantic colors match the app's theme for consistency.
class TimerColors {
  // Semantic const colors for domain layer (no BuildContext access)
  // These match the app's semantic color system:
  // - Info: Blue for normal/running state
  // - Warning: Orange for paused/low time state
  // - Success: Green for completed state
  // - Error: Red for critical state

  /// Info state colors (timer running normally)
  static const Color infoLight = Color(0xFF2196F3);  // Blue 500
  static const Color infoDark = Color(0xFF1976D2);   // Blue 700

  /// Warning state colors (paused or time running low)
  static const Color warningLight = Color(0xFFFF9800); // Orange 500
  static const Color warningDark = Color(0xFFF57C00);  // Orange 800

  /// Success state colors (timer completed)
  static const Color successLight = Color(0xFF4CAF50); // Green 500
  static const Color successDark = Color(0xFF388E3C);  // Green 700

  /// Error/Critical state colors (very low time remaining)
  static const Color errorLight = Color(0xFFF44336); // Red 500
  static const Color errorDark = Color(0xFFD32F2F);  // Red 700

  /// Colori per stato normale (info)
  static const List<Color> normalGradient = [
    infoLight,
    infoDark,
  ];

  /// Colori per stato paused (warning)
  static const List<Color> pausedGradient = [
    warningLight,
    warningDark,
  ];

  /// Colori per stato completato (success)
  static const List<Color> completedGradient = [
    successLight,
    successDark,
  ];

  /// Colori per stato critico (error - < 30 secondi)
  static const List<Color> criticalGradient = [
    errorLight,
    errorDark,
  ];

  /// Colori per stato warning (< 60 secondi)
  static const List<Color> warningGradient = [
    warningLight,
    warningDark,
  ];
}