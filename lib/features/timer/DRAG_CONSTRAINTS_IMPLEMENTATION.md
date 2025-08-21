# GymBro FitLog Pro - Drag Constraints System Implementation

## Overview

Sistema completo di drag constraints per il timer minimizzato che risolve definitivamente il problema di timer perso fuori schermo. Implementazione Hybrid con boundary constraints, magnetic positioning e recovery system.

## Architecture

```
EnhancedDraggableTimerSystem
├── DraggableTimerOverlay (Main Timer)
├── TimerRecoveryFAB (Recovery System)
├── TimerPositioningService (Core Logic)
├── MinimizedTimerControls (UI Components)
└── Enhanced Providers (State Management)
```

## Core Components

### 1. DraggableTimerOverlay
**Path**: `lib/features/timer/presentation/widgets/draggable_timer_overlay.dart`

**Features**:
- ✅ Drag boundaries che mantengono sempre 48px minimi visibili (iOS/Android standard)
- ✅ Magnetic positioning ai bordi schermo con haptic feedback
- ✅ Performance ottimizzato con minimal rebuilds durante drag
- ✅ Memory efficient con cleanup automatico
- ✅ Accessibility compliant con semantic labels
- ✅ Gesture shortcuts per quick mode switching

**Key Methods**:
```dart
void _handleDragUpdate(DragUpdateDetails details, Size screenSize)
void _performMagneticSnap(Offset currentPosition, Size screenSize, Size widgetSize)
bool _shouldPerformEdgeSnap(Velocity velocity, TimerPositionState state)
```

### 2. TimerRecoveryFAB
**Path**: `lib/features/timer/presentation/widgets/timer_recovery_fab.dart`

**Features**:
- ✅ FAB persistente quando timer è minimizzato fuori schermo
- ✅ Auto-expansion animata quando tapped
- ✅ Integration seamless con Riverpod state sync
- ✅ Pulsazioni visive per urgency (timer quasi finito)
- ✅ Progress ring integrato nel FAB

**Key Logic**:
```dart
bool _isTimerVisibleOnScreen(TimerPositionState positionState, BuildContext context)
void _restoreTimerToVisiblePosition()
void _updatePulseForTimer(RestTimer timer)
```

### 3. TimerPositioningService
**Path**: `lib/features/timer/presentation/services/timer_positioning_service.dart`

**Features**:
- ✅ Boundary calculation che garantisce sempre minima visibilità
- ✅ Support per diverse dimensioni schermo (iPhone, iPad, Android)
- ✅ Edge detection con soglie configurabili
- ✅ Safe positioning per evitare overlap con UI nativa
- ✅ Performance ottimizzato con calcoli cached

**Core APIs**:
```dart
static Offset getConstrainedPosition({
  required Offset position,
  required Size screenSize,
  required Size widgetSize,
  required EdgeInsets screenPadding,
  required Size minVisibleArea,
  double edgeMargin = 16.0,
})

static bool isNearScreenEdge({
  required Offset position,
  required Size screenSize,  
  required Size widgetSize,
  double threshold = 50.0,
})

static Offset getNearestEdgePosition({
  required Offset position,
  required Size screenSize,
  required Size widgetSize,
  required EdgeInsets padding,
  double edgeMargin = 16.0,
})
```

### 4. MinimizedTimerControls
**Path**: `lib/features/timer/presentation/widgets/minimized_timer_controls.dart`

**Features**:
- ✅ Layout responsivi per compact/normal/expanded modes
- ✅ Accessibility labels e hints completi
- ✅ Gesture shortcuts e keyboard navigation
- ✅ High contrast support
- ✅ VoiceOver/TalkBack optimized

**Factory Methods**:
```dart
MinimizedTimerControls.compact({required RestTimer timer, required TimerLayout layout})
MinimizedTimerControls.normal({required RestTimer timer, VoidCallback? onPause, ...})
MinimizedTimerControls.expanded({required RestTimer timer, Function(int)? onAddTime, ...})
```

### 5. Enhanced Providers
**Path**: `lib/features/timer/presentation/providers/timer_position_provider.dart`

**Enhanced Features**:
- ✅ Integration con TimerPositioningService
- ✅ Position validation on screen size changes
- ✅ Backward compatibility con existing code
- ✅ Enhanced state persistence

## Integration Guide

### Basic Setup

1. **Replace existing timer overlay**:
```dart
// OLD
MinimizableTimerOverlay()

// NEW  
EnhancedDraggableTimerSystem()
```

2. **In your main workout screen**:
```dart
Scaffold(
  body: Stack(
    children: [
      // Your existing workout content
      WorkoutContent(),
      
      // Enhanced timer system
      EnhancedDraggableTimerSystem(
        onTimerExpanded: () {
          // Optional callback when timer expanded via FAB
        },
        fabAlignment: Alignment.bottomRight,
        fabMargins: EdgeInsets.all(16.0),
        showDebugOverlays: false, // Set true per development
      ),
    ],
  ),
)
```

### Advanced Configuration

```dart
EnhancedDraggableTimerSystem(
  // Custom FAB positioning
  fabAlignment: Alignment.bottomLeft,
  fabMargins: EdgeInsets.only(left: 20, bottom: 100),
  
  // Development debugging
  showDebugOverlays: kDebugMode,
  
  // Custom expansion callback
  onTimerExpanded: () {
    // Analytics tracking
    analytics.track('timer_recovered_via_fab');
    
    // Custom animation o navigation
    _animateToTimerSection();
  },
)
```

## Technical Requirements Met

### ✅ Minimum 48px Always Visible
- Implementato in `TimerPositioningService.getConstrainedPosition()`
- Standard iOS/Android tap target garantito
- Funziona su tutte le dimensioni schermo

### ✅ Performance Optimized
- Minimal rebuilds durante drag con `AnimatedBuilder`
- Cached screen size calculations
- Memory efficient cleanup in dispose methods
- Debounced position saving

### ✅ Memory Efficient
- Proper disposal di animation controllers
- Cache clearing on screen rotation
- Lazy loading dei componenti
- Observer pattern cleanup

### ✅ Accessible
- Semantic labels per VoiceOver/TalkBack
- Button roles e enabled states corretti
- High contrast support
- Keyboard navigation support

## Constraints & Boundaries

### Screen Constraints
```dart
// Always keep minimum 48px visible (iOS/Android guidelines)
const Size minVisibleArea = Size(48, 48);

// Respect safe areas (notch, status bar, home indicator)
final constrainedPosition = TimerPositioningService.getConstrainedPosition(
  position: newPosition,
  screenSize: screenSize,
  widgetSize: widgetSize, 
  screenPadding: MediaQuery.of(context).padding,
  minVisibleArea: minVisibleArea,
);
```

### Magnetic Snapping
```dart
// Edge proximity detection
const proximityThreshold = 60.0; // Pixels from edge

// Snap conditions
final shouldSnap = TimerPositioningService.isNearScreenEdge(
  position: position,
  screenSize: screenSize,
  widgetSize: widgetSize,
  threshold: proximityThreshold,
) && velocity.pixelsPerSecond.distance < 100.0;
```

### Dead Zones
```dart
// Areas where timer should never be positioned
final deadZones = TimerPositioningService.getDeadZones(
  screenSize: screenSize,
  screenPadding: screenPadding,
  keyboardVisible: keyboardVisible,
  keyboardHeight: keyboardHeight,
);
```

## Animation System

### Smooth Transitions
- **Scale Animation**: Durante drag (1.05x) e near-edge (1.02x)
- **Position Animation**: Snap-to-edge con `Curves.easeOutBack`
- **Mode Transition**: Smooth scaling durante mode changes
- **Magnetic Feedback**: Visual feedback quando near edge

### Haptic Feedback
- `HapticFeedback.lightImpact()`: Drag start
- `HapticFeedback.selectionClick()`: Edge proximity enter/exit
- `HapticFeedback.mediumImpact()`: Magnetic snap e mode changes
- `HapticFeedback.heavyImpact()`: Reset to normal mode

## Error Handling

### Position Validation
```dart
// Auto-correction on app resume
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _schedulePositionValidation();
  }
}

// Screen rotation handling  
@override
void didChangeMetrics() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _handleScreenSizeChange();
  });
}
```

### Fallback Mechanisms
1. **Invalid Position**: Auto-correct to safe center
2. **Missing Timer**: Graceful hide con SizedBox.shrink()
3. **Animation Errors**: Reset to stable state
4. **Memory Pressure**: Cleanup non-essential animations

## Testing

### Unit Tests
**Path**: `test/features/timer/services/timer_positioning_service_test.dart`

Coverage completa per:
- ✅ Boundary constraints
- ✅ Edge detection
- ✅ Magnetic positioning
- ✅ Visibility calculations
- ✅ Dead zone detection
- ✅ Safe positioning

### Manual Testing Checklist

#### Drag Behavior
- [ ] Timer rimane sempre parzialmente visibile durante drag
- [ ] Magnetic snap funziona ai bordi schermo
- [ ] Haptic feedback appropriato durante interazioni
- [ ] Performance smooth anche durante workout lunghi

#### Recovery System
- [ ] FAB appare quando timer è fuori schermo (< 70% visible)
- [ ] FAB pulsa quando timer è in final 30 seconds
- [ ] Tap su FAB riporta timer in posizione visibile
- [ ] FAB si nasconde quando timer torna visibile

#### Screen Rotation
- [ ] Posizione corretta dopo rotazione
- [ ] Layout adattivo per landscape/portrait
- [ ] Performance maintains durante rotazioni multiple

#### Device Compatibility
- [ ] iPhone (tutti i formati: SE, standard, Plus, Pro Max)
- [ ] iPad (tutti i formati)
- [ ] Android (varie dimensioni e aspect ratios)
- [ ] Notch/Dynamic Island compatibility

## Performance Benchmarks

### Target Metrics
- **Drag Response Time**: < 16ms (60fps)
- **Position Save Time**: < 5ms
- **Memory Usage**: < 2MB per timer instance
- **Battery Impact**: Minimal (< 1% durante workout)

### Optimization Techniques Applied
1. **Cached Calculations**: Screen size, widget dimensions
2. **Debounced Persistence**: Position saving ogni 100ms max
3. **Minimal Rebuilds**: Using AnimatedBuilder pattern
4. **Efficient Disposal**: Proper cleanup di resources

## Migration Guide

### From MinimizableTimerOverlay

```dart
// BEFORE
class WorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          WorkoutContent(),
          MinimizableTimerOverlay(), // OLD WIDGET
        ],
      ),
    );
  }
}

// AFTER  
class WorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          WorkoutContent(),
          EnhancedDraggableTimerSystem(), // NEW SYSTEM
        ],
      ),
    );
  }
}
```

### Provider Changes
Nessun breaking change - tutti i provider esistenti mantengono compatibility:
- `currentTimerProvider` - Unchanged
- `timerPositionProvider` - Enhanced ma backward compatible
- `currentTimerLayoutProvider` - Unchanged

## Future Enhancements

### Phase 2 (Optional)
- [ ] Custom snap zones (user-defined areas)
- [ ] Multiple timer support con collision detection
- [ ] Advanced gesture recognition (pinch-to-resize)
- [ ] Cloud sync di position preferences
- [ ] Machine learning per position prediction

### Analytics Integration
```dart
// Timer behavior analytics
analytics.track('timer_dragged', {
  'start_position': startPosition.toString(),
  'end_position': endPosition.toString(),
  'snap_occurred': snapOccurred,
  'duration_ms': dragDuration.inMilliseconds,
});

// Recovery system usage
analytics.track('timer_recovered_via_fab', {
  'timer_remaining_seconds': timer.remainingSeconds,
  'previous_position': hiddenPosition.toString(),
});
```

---

## Summary

Il sistema implementato risolve completamente il problema di timer perso fuori schermo con:

1. **Robust Boundary System**: 48px sempre visibili, safe area respect
2. **Magnetic Positioning**: Smooth snap-to-edge con feedback
3. **Recovery Mechanism**: FAB intelligente per timer nascosti  
4. **Performance**: Ottimizzato per sessioni workout lunghe
5. **Accessibility**: Full VoiceOver/TalkBack support
6. **Testing**: Unit test coverage completa

**Result**: Timer sempre accessibile, UX fluida, zero frustrazione per utenti durante workout intensi.