# Contextual Onboarding System Redesign

**Generated**: 2025-11-27 (Mercoledì)
**Implementation**: Da fare il 2025-11-28 (Giovedì)
**Source**: Brainstorming session with research validation
**Complexity Score**: HIGH
**Estimated Implementation Time**: ~12-16h (2 sessioni da ~8h)
**Plan Version**: 1.0
**Status**: ⏳ READY FOR IMPLEMENTATION

---

## 📋 Executive Summary

Redesign completo del sistema onboarding da **3 sistemi frammentati** (Global Onboarding, Quick Start, Home Tour) a **un unico sistema contestuale** che spiega l'app just-in-time quando l'utente interagisce con le feature.

### Principi Chiave

1. **Zero Onboarding Upfront**: L'app parte direttamente, nessuna schermata di benvenuto
2. **Just-in-Time**: Tutorial appaiono quando servono, non prima
3. **Behavior-Triggered + Proactive Hints**: Combinazione di trigger su azione utente e suggerimenti proattivi
4. **Single Overlay Widget**: Un solo componente per tutti i tutorial
5. **Scalabilità**: Aggiungere nuovi tutorial = modificare 1 file

### Decisioni di Design

| Aspetto | Decisione | Motivazione |
|---------|-----------|-------------|
| Beginner/Expert | **RIMOSSO** | Inutile - tutti ricevono stesso sistema contestuale |
| Upfront onboarding | **ELIMINATO** | UX moderna = app si spiega da sola |
| 3 sistemi separati | **CONSOLIDATI** | Un solo sistema = manutenzione semplice |
| Overlay positioning | **LayerLink** | Performance migliore vs GlobalKey (research 2025) |
| Auto-hide duration | **5 secondi** | Standard UX research |

---

## 🏗️ SEZIONE 1: ARCHITETTURA

### Componenti Principali

```
┌─────────────────────────────────────────────────────────────────┐
│                         App Widgets                              │
│   (emettono TutorialEvent quando utente interagisce)            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ emit(TutorialEvent)
┌─────────────────────────────────────────────────────────────────┐
│                        TriggerEngine                             │
│   - Riceve eventi dal bus                                        │
│   - Consulta TutorialRegistry per trovare tutorial              │
│   - Verifica condizioni (già visto? cooldown?)                  │
│   - Coordina visualizzazione overlay                            │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ TutorialRegistry│ │TutorialState    │ │UnifiedContextual│
│                 │ │Notifier         │ │Overlay          │
│ - Definizioni   │ │                 │ │                 │
│ - Trigger map   │ │ - seenTutorials │ │ - Spotlight     │
│ - Condizioni    │ │ - dismissedHints│ │ - Tooltip       │
│                 │ │ - cooldowns     │ │ - Auto-position │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### TutorialState (Sostituisce OnboardingState)

```dart
@HiveType(typeId: 10) // Nuovo typeId per evitare conflitti migrazione
class TutorialState {
  const TutorialState({
    this.seenTutorials = const {},
    this.dismissedHints = const {},
    this.lastDismissTime = const {},
    this.totalWorkouts = 0,
    this.firstWorkoutDate,
  });

  @HiveField(0)
  final Set<String> seenTutorials;  // {'logging_set', 'rest_timer', ...}

  @HiveField(1)
  final Set<String> dismissedHints; // Hint proattivi dismissati

  @HiveField(2)
  final Map<String, DateTime> lastDismissTime; // Per cooldown 24h

  @HiveField(3)
  final int totalWorkouts; // Per trigger progressivi

  @HiveField(4)
  final DateTime? firstWorkoutDate;

  // Helper methods
  bool hasSeen(String tutorialId) => seenTutorials.contains(tutorialId);

  bool canShowHint(String hintId) {
    if (!dismissedHints.contains(hintId)) return true;
    final lastDismiss = lastDismissTime[hintId];
    if (lastDismiss == null) return true;
    return DateTime.now().difference(lastDismiss).inHours >= 24;
  }

  factory TutorialState.initial() => const TutorialState();

  TutorialState copyWith({
    Set<String>? seenTutorials,
    Set<String>? dismissedHints,
    Map<String, DateTime>? lastDismissTime,
    int? totalWorkouts,
    DateTime? firstWorkoutDate,
  }) {
    return TutorialState(
      seenTutorials: seenTutorials ?? this.seenTutorials,
      dismissedHints: dismissedHints ?? this.dismissedHints,
      lastDismissTime: lastDismissTime ?? this.lastDismissTime,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      firstWorkoutDate: firstWorkoutDate ?? this.firstWorkoutDate,
    );
  }
}
```

### TutorialEvent (Sealed Class)

```dart
sealed class TutorialEvent {
  const TutorialEvent();
}

// Workout events
class SetInputTapped extends TutorialEvent {
  const SetInputTapped();
}

class TimerStarted extends TutorialEvent {
  const TimerStarted();
}

class WorkoutOpened extends TutorialEvent {
  final int exerciseCount;
  const WorkoutOpened({required this.exerciseCount});
}

class WorkoutCompleted extends TutorialEvent {
  final int totalWorkouts;
  const WorkoutCompleted({required this.totalWorkouts});
}

// Exercise events
class ExerciseLongPressed extends TutorialEvent {
  final int exerciseIndex;
  const ExerciseLongPressed({required this.exerciseIndex});
}

// Analytics events
class AnalyticsTabOpened extends TutorialEvent {
  const AnalyticsTabOpened();
}

// Template events
class TemplateMenuOpened extends TutorialEvent {
  const TemplateMenuOpened();
}

// Advanced technique events
class AdvancedTechniqueSelected extends TutorialEvent {
  final String technique; // 'superset', 'dropset', 'restpause'
  const AdvancedTechniqueSelected({required this.technique});
}
```

---

## 📚 SEZIONE 2: DEFINIZIONE DEI 7 TUTORIAL

### Tutorial Registry

```dart
class TutorialRegistry {
  static final Map<Type, TutorialDefinition> _tutorials = {
    // 1. LOGGING SET
    SetInputTapped: TutorialDefinition(
      id: 'logging_set',
      titleKey: 'tutorial_logging_set_title',
      descriptionKey: 'tutorial_logging_set_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('logging_set'),
    ),

    // 2. REST TIMER
    TimerStarted: TutorialDefinition(
      id: 'rest_timer',
      titleKey: 'tutorial_rest_timer_title',
      descriptionKey: 'tutorial_rest_timer_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('rest_timer'),
    ),

    // 3. EXERCISE MANAGEMENT
    ExerciseLongPressed: TutorialDefinition(
      id: 'exercise_management',
      titleKey: 'tutorial_exercise_mgmt_title',
      descriptionKey: 'tutorial_exercise_mgmt_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('exercise_management'),
    ),

    // 4. WORKOUT COMPLETION
    WorkoutCompleted: TutorialDefinition(
      id: 'workout_completion',
      titleKey: 'tutorial_workout_complete_title',
      descriptionKey: 'tutorial_workout_complete_desc',
      type: TutorialType.behavior,
      condition: (state, event) {
        final e = event as WorkoutCompleted;
        return e.totalWorkouts == 1 && !state.hasSeen('workout_completion');
      },
    ),

    // 5. ANALYTICS INTRO (dopo 3 workout)
    AnalyticsTabOpened: TutorialDefinition(
      id: 'analytics_intro',
      titleKey: 'tutorial_analytics_title',
      descriptionKey: 'tutorial_analytics_desc',
      type: TutorialType.behavior,
      condition: (state, _) =>
        state.totalWorkouts >= 3 && !state.hasSeen('analytics_intro'),
    ),

    // 6. TEMPLATES
    TemplateMenuOpened: TutorialDefinition(
      id: 'templates_intro',
      titleKey: 'tutorial_templates_title',
      descriptionKey: 'tutorial_templates_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('templates_intro'),
    ),

    // 7. ADVANCED TECHNIQUES
    AdvancedTechniqueSelected: TutorialDefinition(
      id: 'advanced_techniques',
      titleKey: 'tutorial_advanced_title',
      descriptionKey: 'tutorial_advanced_desc',
      type: TutorialType.behavior,
      condition: (state, _) => !state.hasSeen('advanced_techniques'),
    ),
  };

  static TutorialDefinition? findTutorial(TutorialEvent event) {
    return _tutorials[event.runtimeType];
  }

  static List<TutorialDefinition> get allTutorials => _tutorials.values.toList();
}
```

### Anti-Spam Rules

| Regola | Valore | Motivo |
|--------|--------|--------|
| Cooldown tra tutorial | 2 minuti | Non sopraffare l'utente |
| Cooldown dopo dismiss | 24 ore | Rispetta la scelta utente |
| Max proactive/sessione | 1 | Hint non invasivi |
| Auto-hide duration | 5 secondi | Standard UX |

---

## 🎨 SEZIONE 3: UNIFIED CONTEXTUAL OVERLAY

### Widget Implementation

```dart
class UnifiedContextualOverlay extends StatefulWidget {
  const UnifiedContextualOverlay({
    super.key,
    required this.targetLink,
    required this.targetKey,
    required this.title,
    required this.description,
    required this.onDismiss,
    this.preferredPosition = OverlayPosition.below,
    this.actionLabel,
    this.onAction,
    this.autoHide = const Duration(seconds: 5),
    this.showPulse = true,
    this.showSpotlight = true,
  });

  final LayerLink targetLink;
  final GlobalKey targetKey;
  final OverlayPosition preferredPosition;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  final Duration autoHide;
  final bool showPulse;
  final bool showSpotlight;

  @override
  State<UnifiedContextualOverlay> createState() => _UnifiedContextualOverlayState();
}

class _UnifiedContextualOverlayState extends State<UnifiedContextualOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _autoHideTimer;
  late AnimationController _pulseController;
  Offset? _targetPosition;
  Size? _targetSize;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startAutoHideTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePosition());
  }

  void _calculatePosition() {
    try {
      final RenderBox? renderBox =
          widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox == null || !renderBox.hasSize) {
        _scheduleRetry();
        return;
      }

      setState(() {
        _targetPosition = renderBox.localToGlobal(Offset.zero);
        _targetSize = renderBox.size;
      });
    } catch (e) {
      _handlePositioningError(e);
    }
  }

  void _scheduleRetry() {
    if (_retryCount < 3) {
      _retryCount++;
      Future.delayed(Duration(milliseconds: 100 * _retryCount), () {
        if (mounted) _calculatePosition();
      });
    } else {
      _showFallbackSnackbar();
    }
  }

  void _startAutoHideTimer() {
    _autoHideTimer = Timer(widget.autoHide, widget.onDismiss);
  }

  void _handlePositioningError(Object error) {
    debugPrint('Tutorial overlay positioning failed: $error');
    _showFallbackSnackbar();
  }

  void _showFallbackSnackbar() {
    SnackBarService.showInfo(
      context,
      '${widget.title}: ${widget.description}',
      duration: widget.autoHide,
    );
    widget.onDismiss();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetPosition == null || _targetSize == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Scrim con spotlight
        if (widget.showSpotlight)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: CustomPaint(
                painter: SpotlightPainter(
                  targetRect: Rect.fromLTWH(
                    _targetPosition!.dx,
                    _targetPosition!.dy,
                    _targetSize!.width,
                    _targetSize!.height,
                  ),
                  spotlightPadding: 8.0,
                ),
              ),
            ),
          ),

        // Pulse animation sul target
        if (widget.showPulse)
          Positioned(
            left: _targetPosition!.dx - 4,
            top: _targetPosition!.dy - 4,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: _targetSize!.width + 8,
                height: _targetSize!.height + 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.primary.withOpacity(
                      0.3 + (_pulseController.value * 0.4),
                    ),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

        // Tooltip con CompositedTransformFollower
        CompositedTransformFollower(
          link: widget.targetLink,
          targetAnchor: _getTargetAnchor(),
          followerAnchor: _getFollowerAnchor(),
          offset: _getOffset(),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: context.colors.surface,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: context.textTheme.bodyMedium,
                  ),
                  if (widget.actionLabel != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          widget.onAction?.call();
                          widget.onDismiss();
                        },
                        child: Text(widget.actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Alignment _getTargetAnchor() {
    return switch (widget.preferredPosition) {
      OverlayPosition.above => Alignment.topCenter,
      OverlayPosition.below => Alignment.bottomCenter,
      OverlayPosition.left => Alignment.centerLeft,
      OverlayPosition.right => Alignment.centerRight,
    };
  }

  Alignment _getFollowerAnchor() {
    return switch (widget.preferredPosition) {
      OverlayPosition.above => Alignment.bottomCenter,
      OverlayPosition.below => Alignment.topCenter,
      OverlayPosition.left => Alignment.centerRight,
      OverlayPosition.right => Alignment.centerLeft,
    };
  }

  Offset _getOffset() {
    return switch (widget.preferredPosition) {
      OverlayPosition.above => const Offset(0, -8),
      OverlayPosition.below => const Offset(0, 8),
      OverlayPosition.left => const Offset(-8, 0),
      OverlayPosition.right => const Offset(8, 0),
    };
  }
}

enum OverlayPosition { above, below, left, right }
```

### SpotlightPainter (Performance Optimized)

```dart
class SpotlightPainter extends CustomPainter {
  SpotlightPainter({
    required this.targetRect,
    this.spotlightPadding = 8.0,
    this.scrimColor = const Color(0x99000000),
  });

  final Rect targetRect;
  final double spotlightPadding;
  final Color scrimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = scrimColor;

    // Usa PathFillType.evenOdd per performance ottimale
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        targetRect.inflate(spotlightPadding),
        const Radius.circular(8),
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
           spotlightPadding != oldDelegate.spotlightPadding;
  }
}
```

---

## ⚙️ SEZIONE 4: TRIGGER ENGINE & STATE MANAGEMENT

### TriggerEngine

```dart
class TriggerEngine {
  TriggerEngine({
    required this.stateNotifier,
    required this.overlayService,
  });

  final TutorialStateNotifier stateNotifier;
  final TutorialOverlayService overlayService;

  final StreamController<TutorialEvent> _eventController =
      StreamController<TutorialEvent>.broadcast();

  StreamSubscription? _subscription;
  DateTime? _lastTutorialShown;
  int _proactiveHintsThisSession = 0;
  final List<TutorialDefinition> _queue = [];

  static const _cooldownBetweenTutorials = Duration(minutes: 2);
  static const _maxProactivePerSession = 1;

  void initialize() {
    _subscription = _eventController.stream.listen(
      _handleEvent,
      onError: (e) => debugPrint('Tutorial event error: $e'),
      cancelOnError: false,
    );
  }

  void emit(TutorialEvent event) {
    if (_eventController.isClosed) return;

    try {
      _eventController.add(event);
    } catch (e) {
      debugPrint('Failed to emit tutorial event: $e');
    }
  }

  void _handleEvent(TutorialEvent event) {
    try {
      final tutorial = TutorialRegistry.findTutorial(event);
      if (tutorial == null) return;

      final state = stateNotifier.state;

      // Check condizione specifica del tutorial
      if (!tutorial.condition(state, event)) return;

      // Check cooldown globale
      if (!_canShowTutorial(tutorial)) {
        _queue.add(tutorial);
        return;
      }

      _showTutorial(tutorial);
    } catch (e, stack) {
      debugPrint('Error handling tutorial event: $e\n$stack');
    }
  }

  bool _canShowTutorial(TutorialDefinition tutorial) {
    // Check se overlay già visibile
    if (overlayService.isShowing) return false;

    // Check cooldown 2 minuti
    if (_lastTutorialShown != null) {
      final elapsed = DateTime.now().difference(_lastTutorialShown!);
      if (elapsed < _cooldownBetweenTutorials) return false;
    }

    // Check limite proactive
    if (tutorial.type == TutorialType.proactive) {
      if (_proactiveHintsThisSession >= _maxProactivePerSession) return false;
    }

    return true;
  }

  void _showTutorial(TutorialDefinition tutorial) {
    _lastTutorialShown = DateTime.now();

    if (tutorial.type == TutorialType.proactive) {
      _proactiveHintsThisSession++;
    }

    overlayService.show(
      tutorial: tutorial,
      onDismiss: () => _onTutorialDismissed(tutorial),
    );
  }

  void _onTutorialDismissed(TutorialDefinition tutorial) {
    stateNotifier.markTutorialSeen(tutorial.id);

    // Process queue
    if (_queue.isNotEmpty) {
      Future.delayed(_cooldownBetweenTutorials, () {
        if (_queue.isNotEmpty) {
          final next = _queue.removeAt(0);
          if (_canShowTutorial(next)) {
            _showTutorial(next);
          }
        }
      });
    }
  }

  int get queueLength => _queue.length;

  void dispose() {
    _subscription?.cancel();
    _eventController.close();
  }
}
```

### TutorialStateNotifier

```dart
class TutorialStateNotifier extends StateNotifier<TutorialState> {
  TutorialStateNotifier(this._repository) : super(TutorialState.initial()) {
    _loadState();
  }

  final TutorialRepository _repository;

  Future<void> _loadState() async {
    try {
      final saved = await _repository.loadState();
      if (saved != null) {
        state = saved;
      }
    } on HiveError catch (e) {
      debugPrint('Tutorial state corrupted, resetting: $e');
      await _repository.clearState();
      state = TutorialState.initial();
    } catch (e) {
      debugPrint('Failed to load tutorial state: $e');
    }
  }

  void markTutorialSeen(String tutorialId) {
    state = state.copyWith(
      seenTutorials: {...state.seenTutorials, tutorialId},
    );
    _persistWithRetry();
  }

  void dismissHint(String hintId) {
    state = state.copyWith(
      dismissedHints: {...state.dismissedHints, hintId},
      lastDismissTime: {
        ...state.lastDismissTime,
        hintId: DateTime.now(),
      },
    );
    _persistWithRetry();
  }

  void incrementWorkoutCount() {
    state = state.copyWith(
      totalWorkouts: state.totalWorkouts + 1,
      firstWorkoutDate: state.firstWorkoutDate ?? DateTime.now(),
    );
    _persistWithRetry();
  }

  Future<void> _persistWithRetry({int attempt = 1}) async {
    try {
      await _repository.saveState(state);
    } catch (e) {
      if (attempt < 3) {
        await Future.delayed(Duration(milliseconds: 100 * attempt));
        return _persistWithRetry(attempt: attempt + 1);
      }
      debugPrint('Failed to persist tutorial state after 3 attempts: $e');
    }
  }
}
```

### Riverpod Providers

```dart
// Repository provider
final tutorialRepositoryProvider = Provider<TutorialRepository>((ref) {
  return TutorialRepositoryImpl();
});

// State notifier provider
final tutorialStateProvider =
    StateNotifierProvider<TutorialStateNotifier, TutorialState>((ref) {
  return TutorialStateNotifier(ref.watch(tutorialRepositoryProvider));
});

// Trigger engine provider
final triggerEngineProvider = Provider<TriggerEngine>((ref) {
  final engine = TriggerEngine(
    stateNotifier: ref.watch(tutorialStateProvider.notifier),
    overlayService: ref.watch(tutorialOverlayServiceProvider),
  );
  engine.initialize();
  ref.onDispose(engine.dispose);
  return engine;
});

// Overlay service provider
final tutorialOverlayServiceProvider = Provider<TutorialOverlayService>((ref) {
  return TutorialOverlayService();
});
```

---

## 🗑️ SEZIONE 5: MIGRAZIONE E CLEANUP

### File da Eliminare

#### Global Onboarding System
```
lib/features/onboarding/presentation/screens/
├── global_onboarding_screen.dart        ❌ DELETE
├── onboarding_screen.dart               ❌ DELETE

lib/features/onboarding/presentation/widgets/steps/
├── 01_welcome_step.dart                 ❌ DELETE
├── 02_mode_selection_step.dart          ❌ DELETE
├── 03_toggle_panorama_step.dart         ❌ DELETE
├── 04_create_workout_step.dart          ❌ DELETE
├── 05_add_exercise_step.dart            ❌ DELETE
├── 06_execute_set_step.dart             ❌ DELETE
├── 07_timer_rest_step.dart              ❌ DELETE
├── 08_advanced_features_step.dart       ❌ DELETE
```

#### Quick Start System
```
lib/features/onboarding/presentation/screens/
├── quick_start_screen.dart              ❌ DELETE

lib/features/onboarding/presentation/widgets/
├── quick_start_*.dart                   ❌ DELETE (all)
```

#### Home Tour System
```
lib/features/onboarding/presentation/providers/
├── onboarding_tour_provider.dart        ❌ DELETE
```

#### Legacy Providers
```
lib/features/onboarding/presentation/providers/
├── onboarding_provider.dart             ❌ DELETE
├── onboarding_state_provider.dart       ❌ DELETE
```

#### Duplicate Overlay Widgets
```
lib/features/workout/presentation/widgets/
├── exercise_onboarding_overlay.dart     ❌ DELETE
├── template_onboarding_overlay.dart     ❌ DELETE

lib/features/onboarding/presentation/widgets/
├── contextual_overlay.dart              ❌ DELETE
├── spotlight_overlay.dart               ❌ DELETE
├── tooltip_overlay.dart                 ❌ DELETE
```

### File da Modificare

```
lib/features/onboarding/domain/entities/
├── onboarding_state.dart                🔄 REPLACE → tutorial_state.dart

lib/features/onboarding/data/repositories/
├── onboarding_repository.dart           🔄 SIMPLIFY → tutorial_repository.dart

lib/core/navigation/app_router.dart      🔄 REMOVE routes /onboarding, /quick-start
```

### Migration Service

```dart
class TutorialMigrationService {
  Future<MigrationResult> migrate() async {
    try {
      final legacyState = await _loadLegacyState();

      if (legacyState == null) {
        return MigrationResult.noLegacyData();
      }

      final newState = _convertState(legacyState);
      await _saveNewState(newState);

      return MigrationResult.success(newState);
    } on HiveError catch (e) {
      return MigrationResult.failed('Hive error: $e', canRetry: true);
    } on FormatException catch (e) {
      return MigrationResult.failed('Legacy corrupted: $e', shouldResetToDefault: true);
    } catch (e) {
      return MigrationResult.failed('Unexpected: $e', canRetry: true);
    }
  }

  TutorialState _convertState(OnboardingState legacy) {
    final seenTutorials = <String>{};

    if (legacy.hasSeenGlobalOnboarding) {
      seenTutorials.addAll(['logging_set', 'rest_timer', 'workout_completion']);
    }

    for (final overlay in legacy.seenOverlays) {
      final mapped = _mapLegacyOverlay(overlay);
      if (mapped != null) seenTutorials.add(mapped);
    }

    return TutorialState(
      seenTutorials: seenTutorials,
      dismissedHints: {},
      lastDismissTime: {},
      totalWorkouts: legacy.hasCompletedFirstWorkout ? 1 : 0,
      firstWorkoutDate: legacy.quickStartCompletedAt,
    );
  }

  String? _mapLegacyOverlay(String legacyId) {
    return switch (legacyId) {
      'addFirstExercise' => 'exercise_management',
      'completeFirstWorkout' => 'workout_completion',
      'restTimerExplanation' => 'rest_timer',
      _ => null,
    };
  }
}
```

### Impatto Stimato

| Categoria | File Eliminati | LOC Rimossi |
|-----------|----------------|-------------|
| Global Onboarding | ~10 | ~2,000 |
| Quick Start | ~5 | ~800 |
| Home Tour | ~3 | ~500 |
| Overlay Duplicati | ~5 | ~1,200 |
| Provider Legacy | ~3 | ~600 |
| **TOTALE** | **~26** | **~5,100** |

| Categoria | File Nuovi | LOC Aggiunti |
|-----------|------------|--------------|
| TutorialState | 1 | ~80 |
| TutorialStateNotifier | 1 | ~150 |
| TriggerEngine | 1 | ~200 |
| UnifiedContextualOverlay | 1 | ~350 |
| TutorialRegistry | 1 | ~180 |
| Migration Service | 1 | ~100 |
| **TOTALE** | **6** | **~1,060** |

**Riduzione netta: ~4,000 LOC**

---

## 🛡️ SEZIONE 6: ERROR HANDLING

### Principi

1. **Never Crash**: Errori tutorial non crashano mai l'app
2. **Graceful Degradation**: Fallback a snackbar se overlay fallisce
3. **Silent Recovery**: Utente non vede errori tecnici
4. **Optimistic Updates**: UI si aggiorna subito, persist in background
5. **Retry with Backoff**: 3 tentativi con delay crescente

### Matrice Errori

| Errore | Severità | Recovery | UX Impact |
|--------|----------|----------|-----------|
| Target non trovato | LOW | Retry 3x → snackbar | Minimo |
| Target fuori schermo | LOW | Chiudi silenziosamente | Nessuno |
| Hive corruption | MEDIUM | Reset stato | Rivede tutorial |
| Event stream error | LOW | Ignora, continua | Un tutorial skip |
| Migration failed | MEDIUM | Retry o reset | Rivede tutorial |

---

## 🧪 SEZIONE 7: TESTING STRATEGY

### Coverage Target

| Component | Unit | Widget | Integration |
|-----------|------|--------|-------------|
| TutorialState | 100% | - | - |
| TriggerEngine | 90% | - | ✅ |
| TutorialRegistry | 100% | - | - |
| TutorialStateNotifier | 90% | - | ✅ |
| UnifiedContextualOverlay | - | 85% | ✅ |
| Migration Service | 100% | - | - |

**Target complessivo: >85%**

### Test Files da Creare

```
test/features/onboarding/
├── domain/entities/
│   └── tutorial_state_test.dart
├── domain/services/
│   └── tutorial_registry_test.dart
├── data/repositories/
│   └── tutorial_repository_test.dart
├── data/services/
│   └── tutorial_migration_service_test.dart
├── presentation/providers/
│   ├── trigger_engine_test.dart
│   └── tutorial_state_notifier_test.dart
└── presentation/widgets/
    └── unified_contextual_overlay_test.dart

integration_test/
└── tutorial_flow_test.dart
```

---

## 🚀 SEZIONE 8: SCALABILITÀ

### Aggiungere Nuovo Tutorial (3 Step)

```dart
// STEP 1: Evento (se nuovo)
class NewFeatureOpened extends TutorialEvent {
  const NewFeatureOpened();
}

// STEP 2: Registra nel Registry
NewFeatureOpened: TutorialDefinition(
  id: 'new_feature_intro',
  titleKey: 'tutorial_new_feature_title',
  descriptionKey: 'tutorial_new_feature_desc',
  condition: (state, _) => !state.hasSeen('new_feature_intro'),
),

// STEP 3: Emetti nel widget
ref.read(triggerEngineProvider).emit(const NewFeatureOpened());
```

**Tempo stimato: ~5 minuti per tutorial**

### Scalabilità Numerica

| Tutorial | Performance |
|----------|-------------|
| 10 | ✅ Nessun impatto |
| 50 | ✅ Nessun impatto |
| 100 | ✅ O(1) lookup |
| 500+ | ⚠️ Lazy loading |

### Feature Future-Ready

- ✅ A/B Testing (condition legge flag)
- ✅ Remote Config (condition legge Firebase)
- ✅ Analytics tracking (eventi già tracciabili)
- ✅ Tutorial sequenze (hasSeen chain)
- ✅ User segmentation
- ✅ Seasonal/Promo tutorials

---

## 📋 IMPLEMENTATION CHECKLIST

### Fase 1: Setup Base (~3h)
- [ ] Creare `TutorialState` entity con Hive
- [ ] Creare `TutorialRepository`
- [ ] Creare `TutorialStateNotifier`
- [ ] Setup Riverpod providers

### Fase 2: Core System (~4h)
- [ ] Creare `TutorialEvent` sealed class
- [ ] Creare `TutorialDefinition` model
- [ ] Creare `TutorialRegistry`
- [ ] Creare `TriggerEngine`

### Fase 3: UI (~4h)
- [ ] Creare `UnifiedContextualOverlay`
- [ ] Creare `SpotlightPainter`
- [ ] Creare `TutorialOverlayService`
- [ ] Testare posizionamento auto

### Fase 4: Migration (~2h)
- [ ] Creare `TutorialMigrationService`
- [ ] Testare migrazione legacy → new
- [ ] Rimuovere route legacy da router

### Fase 5: Integration (~2h)
- [ ] Aggiungere emit() nei widget target
- [ ] Testare tutti i 7 tutorial
- [ ] Verificare anti-spam rules

### Fase 6: Cleanup (~2h)
- [ ] Eliminare file legacy (26 file)
- [ ] Rimuovere import orfani
- [ ] flutter analyze
- [ ] Test finali

### Fase 7: Localization
- [ ] Aggiungere chiavi app_en.arb
- [ ] Aggiungere chiavi app_it.arb
- [ ] flutter gen-l10n

---

## 📎 APPENDIX: Localization Keys

```json
// app_en.arb
{
  "tutorial_logging_set_title": "Log Your Set",
  "tutorial_logging_set_desc": "Tap to enter weight and reps. Swipe left to delete a set.",

  "tutorial_rest_timer_title": "Rest Timer",
  "tutorial_rest_timer_desc": "Timer starts automatically after completing a set. Tap to adjust rest time.",

  "tutorial_exercise_mgmt_title": "Exercise Options",
  "tutorial_exercise_mgmt_desc": "Long press an exercise for more options: reorder, superset, notes.",

  "tutorial_workout_complete_title": "First Workout Done!",
  "tutorial_workout_complete_desc": "Great job! Your progress is now being tracked.",

  "tutorial_analytics_title": "Your Progress",
  "tutorial_analytics_desc": "View charts, PRs, and training insights here.",

  "tutorial_templates_title": "Workout Templates",
  "tutorial_templates_desc": "Save your workouts as templates for quick access.",

  "tutorial_advanced_title": "Advanced Technique",
  "tutorial_advanced_desc": "Supersets, drop sets, and rest-pause available. Tap to learn more.",

  "tutorial_got_it": "Got it"
}
```

```json
// app_it.arb
{
  "tutorial_logging_set_title": "Registra la Serie",
  "tutorial_logging_set_desc": "Tocca per inserire peso e ripetizioni. Scorri a sinistra per eliminare.",

  "tutorial_rest_timer_title": "Timer di Recupero",
  "tutorial_rest_timer_desc": "Il timer parte automaticamente dopo ogni serie. Tocca per modificare.",

  "tutorial_exercise_mgmt_title": "Opzioni Esercizio",
  "tutorial_exercise_mgmt_desc": "Tieni premuto per riordinare, creare superset o aggiungere note.",

  "tutorial_workout_complete_title": "Primo Allenamento Fatto!",
  "tutorial_workout_complete_desc": "Ottimo lavoro! I tuoi progressi sono ora tracciati.",

  "tutorial_analytics_title": "I Tuoi Progressi",
  "tutorial_analytics_desc": "Visualizza grafici, record personali e statistiche.",

  "tutorial_templates_title": "Schede di Allenamento",
  "tutorial_templates_desc": "Salva i tuoi allenamenti come template per accesso rapido.",

  "tutorial_advanced_title": "Tecnica Avanzata",
  "tutorial_advanced_desc": "Superserie, drop set e rest-pause disponibili. Tocca per saperne di più.",

  "tutorial_got_it": "Capito"
}
```

---

*Document generated from brainstorming session with research validation (2025-11-27)*
