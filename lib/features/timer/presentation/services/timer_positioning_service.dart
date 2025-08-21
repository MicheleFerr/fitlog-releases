import 'package:flutter/material.dart';

/// Service per gestione posizionamento avanzato del timer minimizzato
/// 
/// Features:
/// - Boundary calculation che garantisce sempre minima visibilità
/// - Support per diverse dimensioni schermo (iPhone, iPad, Android)
/// - Edge detection con soglie configurabili
/// - Safe positioning per evitare overlap con UI nativa
/// - Performance ottimizzato con calcoli cached
class TimerPositioningService {
  // Costanti per calcoli di posizionamento
  static const double _minTapTargetSize = 44.0; // iOS Human Interface Guidelines
  static const double _androidMinTapTarget = 48.0; // Material Design Guidelines
  static const double _defaultEdgeMargin = 16.0;
  static const double _safeAreaBuffer = 8.0;
  
  /// Calcola posizione vincolata che mantiene sempre area minima visibile
  /// 
  /// [position] - Posizione desiderata
  /// [screenSize] - Dimensioni dello schermo
  /// [widgetSize] - Dimensioni del widget timer
  /// [screenPadding] - Safe area insets (notch, status bar, etc.)
  /// [minVisibleArea] - Area minima che deve rimanere visibile
  /// [edgeMargin] - Margine dai bordi schermo
  static Offset getConstrainedPosition({
    required Offset position,
    required Size screenSize,
    required Size widgetSize,
    required EdgeInsets screenPadding,
    required Size minVisibleArea,
    double edgeMargin = _defaultEdgeMargin,
  }) {
    // Calcola bounds disponibili considerando safe areas
    final availableRect = Rect.fromLTWH(
      screenPadding.left + edgeMargin,
      screenPadding.top + edgeMargin,
      screenSize.width - screenPadding.horizontal - (edgeMargin * 2),
      screenSize.height - screenPadding.vertical - (edgeMargin * 2),
    );
    
    // Calcola limiti che garantiscono visibilità minima
    final minVisibleConstraints = _calculateMinVisibilityConstraints(
      availableRect: availableRect,
      widgetSize: widgetSize,
      minVisibleArea: minVisibleArea,
    );
    
    // Applica constraints alla posizione
    final constrainedX = position.dx.clamp(
      minVisibleConstraints.left,
      minVisibleConstraints.right,
    );
    
    final constrainedY = position.dy.clamp(
      minVisibleConstraints.top,
      minVisibleConstraints.bottom,
    );
    
    return Offset(constrainedX, constrainedY);
  }
  
  /// Calcola constraints che garantiscono visibilità minima del widget
  static Rect _calculateMinVisibilityConstraints({
    required Rect availableRect,
    required Size widgetSize,
    required Size minVisibleArea,
  }) {
    // Calcola quanto del widget può uscire dai bordi mantenendo l'area minima visibile
    final maxHiddenWidth = widgetSize.width - minVisibleArea.width;
    final maxHiddenHeight = widgetSize.height - minVisibleArea.height;
    
    // Definisce i limiti per la posizione top-left del widget
    final left = availableRect.left - maxHiddenWidth;
    final top = availableRect.top - maxHiddenHeight;
    final right = availableRect.right - minVisibleArea.width;
    final bottom = availableRect.bottom - minVisibleArea.height;
    
    return Rect.fromLTRB(left, top, right, bottom);
  }
  
  /// Verifica se il timer è vicino a un bordo dello schermo
  /// 
  /// [position] - Posizione corrente del timer
  /// [screenSize] - Dimensioni schermo
  /// [widgetSize] - Dimensioni widget
  /// [threshold] - Distanza soglia in pixel per considerare "vicino"
  static bool isNearScreenEdge({
    required Offset position,
    required Size screenSize,
    required Size widgetSize,
    double threshold = 50.0,
  }) {
    final distanceToEdges = _calculateDistancesToEdges(
      position: position,
      screenSize: screenSize,
      widgetSize: widgetSize,
    );
    
    return distanceToEdges.any((distance) => distance < threshold);
  }
  
  /// Calcola distanze dai quattro bordi dello schermo
  static List<double> _calculateDistancesToEdges({
    required Offset position,
    required Size screenSize,
    required Size widgetSize,
  }) {
    final distanceToLeft = position.dx;
    final distanceToTop = position.dy;
    final distanceToRight = screenSize.width - position.dx - widgetSize.width;
    final distanceToBottom = screenSize.height - position.dy - widgetSize.height;
    
    return [distanceToLeft, distanceToTop, distanceToRight, distanceToBottom];
  }
  
  /// Ottiene la posizione del bordo più vicino per snap magnetico
  /// 
  /// [position] - Posizione corrente
  /// [screenSize] - Dimensioni schermo
  /// [widgetSize] - Dimensioni widget
  /// [padding] - Safe area padding
  /// [edgeMargin] - Margine dal bordo
  static Offset getNearestEdgePosition({
    required Offset position,
    required Size screenSize,
    required Size widgetSize,
    required EdgeInsets padding,
    double edgeMargin = _defaultEdgeMargin,
  }) {
    final distancesToEdges = _calculateDistancesToEdges(
      position: position,
      screenSize: screenSize,
      widgetSize: widgetSize,
    );
    
    // Trova l'indice del bordo più vicino
    double minDistance = distancesToEdges[0];
    int nearestEdgeIndex = 0;
    
    for (int i = 1; i < distancesToEdges.length; i++) {
      if (distancesToEdges[i] < minDistance) {
        minDistance = distancesToEdges[i];
        nearestEdgeIndex = i;
      }
    }
    
    // Calcola posizione snap basata sul bordo più vicino
    switch (nearestEdgeIndex) {
      case 0: // Left edge
        return Offset(
          padding.left + edgeMargin,
          position.dy,
        );
      case 1: // Top edge
        return Offset(
          position.dx,
          padding.top + edgeMargin,
        );
      case 2: // Right edge
        return Offset(
          screenSize.width - widgetSize.width - padding.right - edgeMargin,
          position.dy,
        );
      case 3: // Bottom edge
        return Offset(
          position.dx,
          screenSize.height - widgetSize.height - padding.bottom - edgeMargin,
        );
      default:
        return position;
    }
  }
  
  /// Verifica se una posizione è completamente visibile sullo schermo
  /// 
  /// [position] - Posizione da verificare
  /// [widgetSize] - Dimensioni widget
  /// [screenSize] - Dimensioni schermo
  /// [screenPadding] - Safe area insets
  /// [minVisibleThreshold] - Soglia percentuale di visibilità (0.0-1.0)
  static bool isPositionFullyVisible({
    required Offset position,
    required Size widgetSize,
    required Size screenSize,
    required EdgeInsets screenPadding,
    double minVisibleThreshold = 0.8,
  }) {
    // Calcola area del widget
    final widgetRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      widgetSize.width,
      widgetSize.height,
    );
    
    // Calcola area visibile dello schermo
    final visibleScreenRect = Rect.fromLTWH(
      screenPadding.left,
      screenPadding.top,
      screenSize.width - screenPadding.horizontal,
      screenSize.height - screenPadding.vertical,
    );
    
    // Calcola intersezione tra widget e area visibile
    final intersection = widgetRect.intersect(visibleScreenRect);
    
    if (intersection.isEmpty) {
      return false;
    }
    
    // Calcola percentuale di widget visibile
    final widgetArea = widgetSize.width * widgetSize.height;
    final visibleArea = intersection.width * intersection.height;
    final visibilityRatio = visibleArea / widgetArea;
    
    return visibilityRatio >= minVisibleThreshold;
  }
  
  /// Ottiene una posizione sicura al centro dello schermo
  /// 
  /// [screenSize] - Dimensioni schermo
  /// [widgetSize] - Dimensioni widget
  /// [screenPadding] - Safe area insets
  static Offset getSafeCenterPosition({
    required Size screenSize,
    required Size widgetSize,
    required EdgeInsets screenPadding,
  }) {
    // Calcola area disponibile
    final availableWidth = screenSize.width - screenPadding.horizontal;
    final availableHeight = screenSize.height - screenPadding.vertical;
    
    // Posizione centrata nell'area disponibile
    final centerX = screenPadding.left + (availableWidth - widgetSize.width) / 2;
    final centerY = screenPadding.top + (availableHeight - widgetSize.height) / 2;
    
    return Offset(centerX, centerY);
  }
  
  /// Ottiene posizione di default basata sulle preferenze utente e dimensioni schermo
  /// 
  /// [screenSize] - Dimensioni schermo
  /// [widgetSize] - Dimensioni widget
  /// [screenPadding] - Safe area insets
  /// [preferredPosition] - Posizione preferita dall'utente (opzionale)
  static Offset getDefaultPosition({
    required Size screenSize,
    required Size widgetSize,
    required EdgeInsets screenPadding,
    TimerDefaultPosition? preferredPosition,
  }) {
    const margin = _defaultEdgeMargin;
    
    switch (preferredPosition ?? TimerDefaultPosition.topRight) {
      case TimerDefaultPosition.topLeft:
        return Offset(
          screenPadding.left + margin,
          screenPadding.top + margin,
        );
      case TimerDefaultPosition.topRight:
        return Offset(
          screenSize.width - widgetSize.width - screenPadding.right - margin,
          screenPadding.top + margin,
        );
      case TimerDefaultPosition.bottomLeft:
        return Offset(
          screenPadding.left + margin,
          screenSize.height - widgetSize.height - screenPadding.bottom - margin,
        );
      case TimerDefaultPosition.bottomRight:
        return Offset(
          screenSize.width - widgetSize.width - screenPadding.right - margin,
          screenSize.height - widgetSize.height - screenPadding.bottom - margin,
        );
      case TimerDefaultPosition.center:
        return getSafeCenterPosition(
          screenSize: screenSize,
          widgetSize: widgetSize,
          screenPadding: screenPadding,
        );
    }
  }
  
  /// Validates position per device-specific constraints
  /// 
  /// [position] - Posizione da validare
  /// [screenSize] - Dimensioni schermo
  /// [widgetSize] - Dimensioni widget
  /// [deviceType] - Tipo di device per constraints specifici
  static Offset validatePositionForDevice({
    required Offset position,
    required Size screenSize,
    required Size widgetSize,
    required DeviceType deviceType,
  }) {
    double minTapTarget;
    switch (deviceType) {
      case DeviceType.iPhone:
        minTapTarget = _minTapTargetSize;
        break;
      case DeviceType.android:
        minTapTarget = _androidMinTapTarget;
        break;
      case DeviceType.tablet:
        minTapTarget = _minTapTargetSize; // Use iOS guidelines for tablets
        break;
    }
    
    // Assicura che almeno la tap target area sia visibile
    final minVisibleArea = Size(minTapTarget, minTapTarget);
    
    return getConstrainedPosition(
      position: position,
      screenSize: screenSize,
      widgetSize: widgetSize,
      screenPadding: EdgeInsets.zero, // Sarà fornito dal caller
      minVisibleArea: minVisibleArea,
    );
  }
  
  /// Calcola area di "dead zone" dove il timer non dovrebbe mai essere posizionato
  /// (es: sopra keyboard, sopra notch estremo, etc.)
  static List<Rect> getDeadZones({
    required Size screenSize,
    required EdgeInsets screenPadding,
    bool keyboardVisible = false,
    double keyboardHeight = 0,
  }) {
    final deadZones = <Rect>[];
    
    // Dead zone per tastiera
    if (keyboardVisible && keyboardHeight > 0) {
      deadZones.add(Rect.fromLTWH(
        0,
        screenSize.height - keyboardHeight,
        screenSize.width,
        keyboardHeight,
      ));
    }
    
    // Dead zone estrema nel notch (per iPhone X+)
    if (screenPadding.top > 20) {  // Likely a device with notch
      deadZones.add(Rect.fromLTWH(
        0,
        0,
        screenSize.width,
        screenPadding.top,
      ));
    }
    
    return deadZones;
  }
  
  /// Verifica se una posizione interseca con dead zones
  static bool isPositionInDeadZone({
    required Offset position,
    required Size widgetSize,
    required List<Rect> deadZones,
  }) {
    final widgetRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      widgetSize.width,
      widgetSize.height,
    );
    
    return deadZones.any((deadZone) => deadZone.overlaps(widgetRect));
  }
}

/// Posizioni di default per il timer
enum TimerDefaultPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

/// Tipi di device per constraints specifici
enum DeviceType {
  iPhone,
  android,
  tablet,
}

/// Extension per identificare device type
extension DeviceTypeExtension on BuildContext {
  DeviceType get deviceType {
    final size = MediaQuery.of(this).size;
    final diagonal = (size.width * size.width + size.height * size.height);
    
    // Rough heuristic per device type
    if (diagonal > 1000000) { // ~1000x1000 equivalent
      return DeviceType.tablet;
    }
    
    // Check platform specifics se disponibili
    // Per ora default ad Android, può essere esteso con platform detection
    return DeviceType.android;
  }
}

/// Utility class per calcoli di positioning cached
class PositioningCache {
  static final Map<String, Offset> _positionCache = {};
  static final Map<String, bool> _visibilityCache = {};
  
  /// Generates cache key from parameters
  static String _generateKey(List<dynamic> params) {
    return params.map((e) => e.toString()).join('_');
  }
  
  /// Cache position calculation
  static Offset? getCachedPosition(String key) {
    return _positionCache[key];
  }
  
  /// Store position in cache
  static void cachePosition(String key, Offset position) {
    _positionCache[key] = position;
    
    // Keep cache size reasonable
    if (_positionCache.length > 50) {
      final firstKey = _positionCache.keys.first;
      _positionCache.remove(firstKey);
    }
  }
  
  /// Clear cache (call on screen rotation or major layout changes)
  static void clearCache() {
    _positionCache.clear();
    _visibilityCache.clear();
  }
}