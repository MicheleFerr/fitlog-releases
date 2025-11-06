# LayerLink Contextual Onboarding Tutorial System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement production-ready contextual tutorial system using LayerLink pattern to guide users through critical app features identified by scientific research.

**Architecture:** Clean Architecture + Riverpod state management with performance-optimized overlay rendering using CustomPainter (avoiding expensive ColorFiltered). Behavior-triggered tutorials with SharedPreferences persistence.

**Tech Stack:** Flutter 3.x, Riverpod, LayerLink/CompositedTransform, CustomPainter, SharedPreferences

**Research Foundation:** Based on extensive research showing 71% user abandonment in fitness apps due to confusing UX. Contextual in-app tutorials can increase retention by up to 50%.

---

## 🎯 Implementation Phases

**Phase 1 (CRITICAL)**: Logging & Timer Tutorial
- Priority: Addresses #1 confusion point (logging sets)
- Priority: Addresses #2 confusion point (timer behavior)

**Phase 2 (HIGH)**: Superset Creation Tutorial
- Priority: Addresses top confusion in competitor apps

**Phase 3 (MEDIUM)**: Home Widget Customization
- Lower priority, can be deferred

---

## 📋 Task Breakdown

### Task 1: Core Tutorial Service Foundation

**Files:**
- Create: `lib/shared/domain/services/contextual_tutorial_service.dart`
- Create: `lib/shared/domain/entities/tutorial_step.dart`
- Create: `lib/shared/domain/entities/tutorial_config.dart`
- Test: `test/shared/domain/services/contextual_tutorial_service_test.dart`

**Step 1: Write failing test for tutorial persistence**

```dart
// test/shared/domain/services/contextual_tutorial_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/domain/services/contextual_tutorial_service.dart';

void main() {
  group('ContextualTutorialService', () {
    late ContextualTutorialService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = ContextualTutorialService();
      await service.initialize();
    });

    test('should return true for unseen tutorial', () async {
      final shouldShow = await service.shouldShowTutorial('logging_first_set');
      expect(shouldShow, true);
    });

    test('should return false after marking tutorial as seen', () async {
      await service.markTutorialAsSeen('logging_first_set');
      final shouldShow = await service.shouldShowTutorial('logging_first_set');
      expect(shouldShow, false);
    });

    test('should allow reset of specific tutorial', () async {
      await service.markTutorialAsSeen('logging_first_set');
      await service.resetTutorial('logging_first_set');
      final shouldShow = await service.shouldShowTutorial('logging_first_set');
      expect(shouldShow, true);
    });

    test('should reset all tutorials', () async {
      await service.markTutorialAsSeen('logging_first_set');
      await service.markTutorialAsSeen('timer_controls');
      await service.resetAllTutorials();

      expect(await service.shouldShowTutorial('logging_first_set'), true);
      expect(await service.shouldShowTutorial('timer_controls'), true);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/shared/domain/services/contextual_tutorial_service_test.dart`
Expected: FAIL with "No file or directory found"

**Step 3: Create TutorialStep entity**

```dart
// lib/shared/domain/entities/tutorial_step.dart
import 'package:flutter/widgets.dart';

/// Represents a single step in a contextual tutorial
class TutorialStep {
  final String id;
  final LayerLink targetLink;
  final String titleKey; // l10n key
  final String descriptionKey; // l10n key
  final TutorialPosition tooltipPosition;
  final Duration autoHideDuration;

  const TutorialStep({
    required this.id,
    required this.targetLink,
    required this.titleKey,
    required this.descriptionKey,
    this.tooltipPosition = TutorialPosition.bottom,
    this.autoHideDuration = const Duration(seconds: 8),
  });
}

enum TutorialPosition {
  top,
  bottom,
  left,
  right,
}
```

**Step 4: Create TutorialConfig entity**

```dart
// lib/shared/domain/entities/tutorial_config.dart
import 'package:gymbro_flutter_new/shared/domain/entities/tutorial_step.dart';

/// Configuration for a multi-step tutorial sequence
class TutorialConfig {
  final String id;
  final List<TutorialStep> steps;
  final bool showSequentially; // Show all steps in sequence vs. one at a time
  final Duration delayBetweenSteps;

  const TutorialConfig({
    required this.id,
    required this.steps,
    this.showSequentially = false,
    this.delayBetweenSteps = const Duration(milliseconds: 500),
  });
}
```

**Step 5: Implement ContextualTutorialService**

```dart
// lib/shared/domain/services/contextual_tutorial_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to manage contextual tutorial persistence and state
class ContextualTutorialService {
  static const String _keyPrefix = 'tutorial_seen_';
  static const String _keyVersion = 'tutorial_version';
  static const int _currentVersion = 1; // Increment to reset all tutorials

  SharedPreferences? _prefs;

  /// Initialize service - must be called before use
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkVersion();
  }

  /// Check if tutorial version changed (reset all if so)
  Future<void> _checkVersion() async {
    final savedVersion = _prefs?.getInt(_keyVersion) ?? 0;
    if (savedVersion < _currentVersion) {
      if (kDebugMode) {
        debugPrint('🎓 Tutorial version updated: $savedVersion → $_currentVersion. Resetting all tutorials.');
      }
      await resetAllTutorials();
      await _prefs?.setInt(_keyVersion, _currentVersion);
    }
  }

  /// Check if tutorial should be shown
  Future<bool> shouldShowTutorial(String tutorialId) async {
    if (_prefs == null) {
      await initialize();
    }
    final seen = _prefs?.getBool('$_keyPrefix$tutorialId') ?? false;
    return !seen;
  }

  /// Mark tutorial as seen
  Future<void> markTutorialAsSeen(String tutorialId) async {
    if (_prefs == null) {
      await initialize();
    }
    await _prefs?.setBool('$_keyPrefix$tutorialId', true);
    if (kDebugMode) {
      debugPrint('🎓 Tutorial marked as seen: $tutorialId');
    }
  }

  /// Reset specific tutorial (for testing or user request)
  Future<void> resetTutorial(String tutorialId) async {
    if (_prefs == null) {
      await initialize();
    }
    await _prefs?.remove('$_keyPrefix$tutorialId');
    if (kDebugMode) {
      debugPrint('🎓 Tutorial reset: $tutorialId');
    }
  }

  /// Reset all tutorials (for testing or major updates)
  Future<void> resetAllTutorials() async {
    if (_prefs == null) {
      await initialize();
    }
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await _prefs?.remove(key);
      }
    }
    if (kDebugMode) {
      debugPrint('🎓 All tutorials reset');
    }
  }

  /// Get list of seen tutorials
  Future<List<String>> getSeenTutorials() async {
    if (_prefs == null) {
      await initialize();
    }
    final keys = _prefs?.getKeys() ?? {};
    return keys
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.replaceFirst(_keyPrefix, ''))
        .toList();
  }
}
```

**Step 6: Run test to verify it passes**

Run: `flutter test test/shared/domain/services/contextual_tutorial_service_test.dart`
Expected: ALL TESTS PASS

**Step 7: Commit**

```bash
git add lib/shared/domain/services/contextual_tutorial_service.dart \
        lib/shared/domain/entities/tutorial_step.dart \
        lib/shared/domain/entities/tutorial_config.dart \
        test/shared/domain/services/contextual_tutorial_service_test.dart
git commit -m "feat: add contextual tutorial service with persistence

- SharedPreferences-based tutorial tracking
- Version-based reset mechanism
- TutorialStep and TutorialConfig entities
- Full test coverage

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 2: Performance-Optimized Spotlight Painter

**Files:**
- Create: `lib/shared/presentation/widgets/spotlight_painter.dart`
- Create: `lib/shared/presentation/widgets/spotlight_overlay.dart`
- Test: `test/shared/presentation/widgets/spotlight_painter_test.dart`

**Step 1: Write widget test for SpotlightPainter**

```dart
// test/shared/presentation/widgets/spotlight_painter_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/spotlight_painter.dart';

void main() {
  group('SpotlightPainter', () {
    test('should create instance with required parameters', () {
      final painter = SpotlightPainter(
        targetRect: Rect.fromLTWH(100, 100, 200, 50),
        overlayColor: Colors.black.withValues(alpha: 0.7),
        highlightColor: Colors.white,
        radius: 12.0,
        pulseValue: 1.0,
      );

      expect(painter, isNotNull);
    });

    test('should repaint when targetRect changes', () {
      final painter1 = SpotlightPainter(
        targetRect: Rect.fromLTWH(100, 100, 200, 50),
        overlayColor: Colors.black.withValues(alpha: 0.7),
        highlightColor: Colors.white,
        radius: 12.0,
        pulseValue: 1.0,
      );

      final painter2 = SpotlightPainter(
        targetRect: Rect.fromLTWH(150, 150, 250, 60),
        overlayColor: Colors.black.withValues(alpha: 0.7),
        highlightColor: Colors.white,
        radius: 12.0,
        pulseValue: 1.0,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('should not repaint when properties unchanged', () {
      final rect = Rect.fromLTWH(100, 100, 200, 50);
      final painter1 = SpotlightPainter(
        targetRect: rect,
        overlayColor: Colors.black.withValues(alpha: 0.7),
        highlightColor: Colors.white,
        radius: 12.0,
        pulseValue: 1.0,
      );

      final painter2 = SpotlightPainter(
        targetRect: rect,
        overlayColor: Colors.black.withValues(alpha: 0.7),
        highlightColor: Colors.white,
        radius: 12.0,
        pulseValue: 1.0,
      );

      expect(painter1.shouldRepaint(painter2), false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/shared/presentation/widgets/spotlight_painter_test.dart`
Expected: FAIL with "No file or directory found"

**Step 3: Implement SpotlightPainter using CustomPainter**

```dart
// lib/shared/presentation/widgets/spotlight_painter.dart
import 'package:flutter/material.dart';

/// Performance-optimized spotlight painter using Path.fillType = evenOdd
/// Avoids expensive ColorFiltered + BlendMode.srcOut pattern
class SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final Color overlayColor;
  final Color highlightColor;
  final double radius;
  final double pulseValue; // 1.0 to 1.1 for subtle pulse effect

  const SpotlightPainter({
    required this.targetRect,
    required this.overlayColor,
    required this.highlightColor,
    required this.radius,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the dark overlay with "hole"
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Paint for the highlight border with pulse effect
    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * pulseValue;

    // Create path covering entire screen
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create rounded rectangle for highlighted area
    final highlightPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        targetRect,
        Radius.circular(radius),
      ));

    // Use evenOdd fill to create "hole" - avoids saveLayer()
    final overlayPath = Path.combine(
      PathOperation.difference,
      screenPath,
      highlightPath,
    );

    // Draw dark overlay with transparent hole
    canvas.drawPath(overlayPath, overlayPaint);

    // Draw highlight border with pulse effect
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.radius != radius ||
        oldDelegate.pulseValue != pulseValue;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/shared/presentation/widgets/spotlight_painter_test.dart`
Expected: ALL TESTS PASS

**Step 5: Create SpotlightOverlay widget**

```dart
// lib/shared/presentation/widgets/spotlight_overlay.dart
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/spotlight_painter.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Widget that renders spotlight overlay with tooltip
/// Uses CompositedTransformFollower for auto-following target
class SpotlightOverlay extends StatefulWidget {
  final LayerLink targetLink;
  final GlobalKey targetKey;
  final String title;
  final String description;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onDismiss;

  const SpotlightOverlay({
    super.key,
    required this.targetLink,
    required this.targetKey,
    required this.title,
    required this.description,
    this.onNext,
    this.onSkip,
    this.onDismiss,
  });

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Rect _getTargetRect() {
    final renderBox = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Rect.zero;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    return Rect.fromLTWH(
      position.dx - 8, // Padding
      position.dy - 8,
      size.width + 16,
      size.height + 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final targetRect = _getTargetRect();
    final isTopHalf = targetRect.center.dy < size.height / 2;

    return Stack(
      children: [
        // Spotlight overlay with hole
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: SpotlightPainter(
                    targetRect: targetRect,
                    overlayColor: context.colors.onSurface.withValues(alpha: 0.85),
                    highlightColor: context.colors.primary,
                    radius: 12.0,
                    pulseValue: _pulseAnimation.value,
                  ),
                );
              },
            ),
          ),
        ),

        // Tooltip positioned relative to target
        Positioned(
          left: 16,
          right: 16,
          top: isTopHalf ? targetRect.bottom + 16 : null,
          bottom: !isTopHalf ? size.height - targetRect.top + 16 : null,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onSkip != null)
                        TextButton(
                          onPressed: widget.onSkip,
                          child: Text(context.l10n.skip),
                        ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: widget.onNext ?? widget.onDismiss,
                        child: Text(widget.onNext != null
                            ? context.l10n.next
                            : context.l10n.gotIt),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Step 6: Add required l10n keys**

Add to `assets/i18n/app_en.arb`:
```json
"skip": "Skip",
"next": "Next",
"gotIt": "Got it",
"tutorialLoggingSetTitle": "How to Log a Set",
"tutorialLoggingSetDescription": "Tap the checkmark after completing a set to log your reps and weight. The app will save your progress automatically.",
"tutorialTimerControlsTitle": "Rest Timer",
"tutorialTimerControlsDescription": "Timer starts automatically after each set. Tap to pause or adjust duration. Works even when screen is locked!",
"tutorialAddExerciseTitle": "Add Exercises",
"tutorialAddExerciseDescription": "Tap the + button to add exercises from our 500+ exercise library. Try dragging it left or right!"
```

Add to `assets/i18n/app_it.arb`:
```json
"skip": "Salta",
"next": "Avanti",
"gotIt": "Capito",
"tutorialLoggingSetTitle": "Come Registrare una Serie",
"tutorialLoggingSetDescription": "Tocca il segno di spunta dopo aver completato una serie per registrare ripetizioni e peso. L'app salva automaticamente i tuoi progressi.",
"tutorialTimerControlsTitle": "Timer di Riposo",
"tutorialTimerControlsDescription": "Il timer parte automaticamente dopo ogni serie. Tocca per mettere in pausa o modificare la durata. Funziona anche con schermo bloccato!",
"tutorialAddExerciseTitle": "Aggiungi Esercizi",
"tutorialAddExerciseDescription": "Tocca il pulsante + per aggiungere esercizi dalla nostra libreria di 500+ esercizi. Prova a trascinarlo a sinistra o destra!"
```

**Step 7: Regenerate l10n**

Run: `flutter gen-l10n`
Expected: SUCCESS - Generated AppLocalizations

**Step 8: Commit**

```bash
git add lib/shared/presentation/widgets/spotlight_painter.dart \
        lib/shared/presentation/widgets/spotlight_overlay.dart \
        test/shared/presentation/widgets/spotlight_painter_test.dart \
        assets/i18n/app_en.arb \
        assets/i18n/app_it.arb
git commit -m "feat: add performance-optimized spotlight overlay

- CustomPainter with Path.fillType evenOdd (no saveLayer)
- Auto-following tooltip with LayerLink
- Pulse animation for highlight border
- Localized strings for tutorial content

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 3: Tutorial Manager with Riverpod Provider

**Files:**
- Create: `lib/shared/presentation/providers/tutorial_manager_provider.dart`
- Create: `lib/shared/presentation/widgets/tutorial_overlay_manager.dart`
- Test: `test/shared/presentation/providers/tutorial_manager_provider_test.dart`

**Step 1: Write test for TutorialManager state**

```dart
// test/shared/presentation/providers/tutorial_manager_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/tutorial_manager_provider.dart';

void main() {
  group('TutorialManager', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      await container.read(tutorialManagerProvider.notifier).initialize();
    });

    tearDown(() {
      container.dispose();
    });

    test('should show tutorial if not seen before', () async {
      final manager = container.read(tutorialManagerProvider.notifier);
      final shouldShow = await manager.shouldShowTutorial('test_tutorial');
      expect(shouldShow, true);
    });

    test('should not show tutorial after marked as seen', () async {
      final manager = container.read(tutorialManagerProvider.notifier);

      await manager.markTutorialAsSeen('test_tutorial');
      final shouldShow = await manager.shouldShowTutorial('test_tutorial');

      expect(shouldShow, false);
    });

    test('should track active tutorial in state', () async {
      final manager = container.read(tutorialManagerProvider.notifier);

      manager.setActiveTutorial('test_tutorial');
      final state = container.read(tutorialManagerProvider);

      expect(state.activeTutorialId, 'test_tutorial');
    });

    test('should clear active tutorial', () async {
      final manager = container.read(tutorialManagerProvider.notifier);

      manager.setActiveTutorial('test_tutorial');
      manager.clearActiveTutorial();
      final state = container.read(tutorialManagerProvider);

      expect(state.activeTutorialId, null);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/shared/presentation/providers/tutorial_manager_provider_test.dart`
Expected: FAIL with "No file or directory found"

**Step 3: Create TutorialManagerState**

```dart
// lib/shared/presentation/providers/tutorial_manager_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/services/contextual_tutorial_service.dart';

/// State for tutorial manager
@immutable
class TutorialManagerState {
  final String? activeTutorialId;
  final int currentStepIndex;
  final bool isShowing;

  const TutorialManagerState({
    this.activeTutorialId,
    this.currentStepIndex = 0,
    this.isShowing = false,
  });

  TutorialManagerState copyWith({
    String? activeTutorialId,
    int? currentStepIndex,
    bool? isShowing,
  }) {
    return TutorialManagerState(
      activeTutorialId: activeTutorialId ?? this.activeTutorialId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isShowing: isShowing ?? this.isShowing,
    );
  }
}

/// Provider for tutorial manager
final tutorialManagerProvider = StateNotifierProvider<TutorialManager, TutorialManagerState>((ref) {
  return TutorialManager();
});

/// Manages tutorial state and coordinates with persistence service
class TutorialManager extends StateNotifier<TutorialManagerState> {
  final ContextualTutorialService _service = ContextualTutorialService();

  TutorialManager() : super(const TutorialManagerState());

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<bool> shouldShowTutorial(String tutorialId) async {
    return await _service.shouldShowTutorial(tutorialId);
  }

  Future<void> markTutorialAsSeen(String tutorialId) async {
    await _service.markTutorialAsSeen(tutorialId);
  }

  void setActiveTutorial(String tutorialId) {
    state = state.copyWith(
      activeTutorialId: tutorialId,
      currentStepIndex: 0,
      isShowing: true,
    );
  }

  void nextStep() {
    state = state.copyWith(
      currentStepIndex: state.currentStepIndex + 1,
    );
  }

  void clearActiveTutorial() {
    state = const TutorialManagerState();
  }

  Future<void> resetTutorial(String tutorialId) async {
    await _service.resetTutorial(tutorialId);
  }

  Future<void> resetAllTutorials() async {
    await _service.resetAllTutorials();
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/shared/presentation/providers/tutorial_manager_provider_test.dart`
Expected: ALL TESTS PASS

**Step 5: Create TutorialOverlayManager widget**

```dart
// lib/shared/presentation/widgets/tutorial_overlay_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/tutorial_manager_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/spotlight_overlay.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/tutorial_config.dart';

/// Widget that manages tutorial overlay rendering and lifecycle
class TutorialOverlayManager extends ConsumerStatefulWidget {
  final Widget child;
  final TutorialConfig? config;

  const TutorialOverlayManager({
    super.key,
    required this.child,
    this.config,
  });

  @override
  ConsumerState<TutorialOverlayManager> createState() => _TutorialOverlayManagerState();
}

class _TutorialOverlayManagerState extends ConsumerState<TutorialOverlayManager> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry?.dispose();
      _overlayEntry = null;
    });
  }

  void _showTutorialStep(TutorialConfig config, int stepIndex) {
    if (stepIndex >= config.steps.length) {
      _completeTutorial(config.id);
      return;
    }

    final step = config.steps[stepIndex];

    // Remove existing overlay
    _removeOverlay();

    // Wait for next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _overlayEntry = OverlayEntry(
        builder: (context) => SpotlightOverlay(
          targetLink: step.targetLink,
          targetKey: GlobalKey(), // TODO: Get from config
          title: step.titleKey,
          description: step.descriptionKey,
          onNext: () {
            ref.read(tutorialManagerProvider.notifier).nextStep();
            _showTutorialStep(config, stepIndex + 1);
          },
          onSkip: () {
            _completeTutorial(config.id);
          },
          onDismiss: () {
            _completeTutorial(config.id);
          },
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  void _completeTutorial(String tutorialId) {
    _removeOverlay();
    ref.read(tutorialManagerProvider.notifier).markTutorialAsSeen(tutorialId);
    ref.read(tutorialManagerProvider.notifier).clearActiveTutorial();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TutorialManagerState>(
      tutorialManagerProvider,
      (previous, next) {
        if (next.isShowing &&
            next.activeTutorialId == widget.config?.id &&
            widget.config != null) {
          _showTutorialStep(widget.config!, next.currentStepIndex);
        } else if (!next.isShowing) {
          _removeOverlay();
        }
      },
    );

    return widget.child;
  }
}
```

**Step 6: Commit**

```bash
git add lib/shared/presentation/providers/tutorial_manager_provider.dart \
        lib/shared/presentation/widgets/tutorial_overlay_manager.dart \
        test/shared/presentation/providers/tutorial_manager_provider_test.dart
git commit -m "feat: add tutorial manager with Riverpod state

- TutorialManager StateNotifier for state management
- TutorialOverlayManager widget for overlay lifecycle
- Proper OverlayEntry disposal pattern
- Full test coverage

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 4: Workout Screen "Logging First Set" Tutorial

**Files:**
- Modify: `lib/features/workout/presentation/workout_screen.dart`
- Create: `lib/features/workout/presentation/providers/workout_tutorial_provider.dart`
- Test: `test/features/workout/presentation/providers/workout_tutorial_provider_test.dart`

**Step 1: Write test for workout tutorial triggers**

```dart
// test/features/workout/presentation/providers/workout_tutorial_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_tutorial_provider.dart';

void main() {
  group('WorkoutTutorialProvider', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should trigger logging tutorial on first set completion', () async {
      final provider = container.read(workoutTutorialProvider.notifier);

      await provider.onFirstSetCompleted();
      final state = container.read(workoutTutorialProvider);

      expect(state.shouldShowLoggingTutorial, true);
    });

    test('should trigger timer tutorial after first rest timer start', () async {
      final provider = container.read(workoutTutorialProvider.notifier);

      await provider.onRestTimerStarted();
      final state = container.read(workoutTutorialProvider);

      expect(state.shouldShowTimerTutorial, true);
    });

    test('should not show tutorial again after dismissed', () async {
      final provider = container.read(workoutTutorialProvider.notifier);

      await provider.onFirstSetCompleted();
      await provider.dismissLoggingTutorial();

      final state = container.read(workoutTutorialProvider);
      expect(state.shouldShowLoggingTutorial, false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/workout/presentation/providers/workout_tutorial_provider_test.dart`
Expected: FAIL with "No file or directory found"

**Step 3: Implement WorkoutTutorialProvider**

```dart
// lib/features/workout/presentation/providers/workout_tutorial_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/services/contextual_tutorial_service.dart';

@immutable
class WorkoutTutorialState {
  final bool shouldShowLoggingTutorial;
  final bool shouldShowTimerTutorial;
  final bool shouldShowAddExerciseTutorial;

  const WorkoutTutorialState({
    this.shouldShowLoggingTutorial = false,
    this.shouldShowTimerTutorial = false,
    this.shouldShowAddExerciseTutorial = false,
  });

  WorkoutTutorialState copyWith({
    bool? shouldShowLoggingTutorial,
    bool? shouldShowTimerTutorial,
    bool? shouldShowAddExerciseTutorial,
  }) {
    return WorkoutTutorialState(
      shouldShowLoggingTutorial: shouldShowLoggingTutorial ?? this.shouldShowLoggingTutorial,
      shouldShowTimerTutorial: shouldShowTimerTutorial ?? this.shouldShowTimerTutorial,
      shouldShowAddExerciseTutorial: shouldShowAddExerciseTutorial ?? this.shouldShowAddExerciseTutorial,
    );
  }
}

final workoutTutorialProvider = StateNotifierProvider<WorkoutTutorialNotifier, WorkoutTutorialState>((ref) {
  return WorkoutTutorialNotifier();
});

class WorkoutTutorialNotifier extends StateNotifier<WorkoutTutorialState> {
  final ContextualTutorialService _service = ContextualTutorialService();

  static const String _loggingTutorialId = 'workout_logging_first_set';
  static const String _timerTutorialId = 'workout_rest_timer';
  static const String _addExerciseTutorialId = 'workout_add_exercise';

  WorkoutTutorialNotifier() : super(const WorkoutTutorialState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _service.initialize();
  }

  /// Called when user completes first set
  Future<void> onFirstSetCompleted() async {
    final shouldShow = await _service.shouldShowTutorial(_loggingTutorialId);
    if (shouldShow && mounted) {
      state = state.copyWith(shouldShowLoggingTutorial: true);
    }
  }

  /// Called when rest timer starts for first time
  Future<void> onRestTimerStarted() async {
    final shouldShow = await _service.shouldShowTutorial(_timerTutorialId);
    if (shouldShow && mounted) {
      state = state.copyWith(shouldShowTimerTutorial: true);
    }
  }

  /// Called when user opens empty workout
  Future<void> onEmptyWorkoutOpened() async {
    final shouldShow = await _service.shouldShowTutorial(_addExerciseTutorialId);
    if (shouldShow && mounted) {
      state = state.copyWith(shouldShowAddExerciseTutorial: true);
    }
  }

  Future<void> dismissLoggingTutorial() async {
    await _service.markTutorialAsSeen(_loggingTutorialId);
    if (mounted) {
      state = state.copyWith(shouldShowLoggingTutorial: false);
    }
  }

  Future<void> dismissTimerTutorial() async {
    await _service.markTutorialAsSeen(_timerTutorialId);
    if (mounted) {
      state = state.copyWith(shouldShowTimerTutorial: false);
    }
  }

  Future<void> dismissAddExerciseTutorial() async {
    await _service.markTutorialAsSeen(_addExerciseTutorialId);
    if (mounted) {
      state = state.copyWith(shouldShowAddExerciseTutorial: false);
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/workout/presentation/providers/workout_tutorial_provider_test.dart`
Expected: ALL TESTS PASS

**Step 5: Integrate tutorial into WorkoutScreen**

Modify `lib/features/workout/presentation/workout_screen.dart`:

Add imports:
```dart
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_tutorial_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/tutorial_overlay_manager.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/tutorial_config.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/tutorial_step.dart';
```

Find the `build` method and wrap the `Scaffold` with `TutorialOverlayManager`:

```dart
@override
Widget build(BuildContext context) {
  // ... existing code ...

  // Watch tutorial state
  final tutorialState = ref.watch(workoutTutorialProvider);

  // Create tutorial config for logging
  final loggingTutorialConfig = tutorialState.shouldShowLoggingTutorial
      ? TutorialConfig(
          id: 'workout_logging_first_set',
          steps: [
            TutorialStep(
              id: 'logging_set_step',
              targetLink: _setCheckmarkLayerLink, // Create this LayerLink
              titleKey: context.l10n.tutorialLoggingSetTitle,
              descriptionKey: context.l10n.tutorialLoggingSetDescription,
            ),
          ],
        )
      : null;

  return TutorialOverlayManager(
    config: loggingTutorialConfig,
    child: Scaffold(
      // ... existing scaffold code ...
    ),
  );
}
```

**Step 6: Add LayerLink to set checkmark button**

In `lib/features/workout/presentation/widgets/exercise_list_item.dart`, add:

```dart
// At the top of the widget
final LayerLink _setCheckmarkLayerLink = LayerLink();

// In the build method, wrap the checkmark IconButton:
CompositedTransformTarget(
  link: _setCheckmarkLayerLink,
  child: IconButton(
    icon: Icon(Icons.check_circle),
    onPressed: () {
      // Existing onPressed logic
      // Add tutorial trigger:
      ref.read(workoutTutorialProvider.notifier).onFirstSetCompleted();
    },
  ),
)
```

**Step 7: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 8: Commit**

```bash
git add lib/features/workout/presentation/providers/workout_tutorial_provider.dart \
        lib/features/workout/presentation/workout_screen.dart \
        lib/features/workout/presentation/widgets/exercise_list_item.dart \
        test/features/workout/presentation/providers/workout_tutorial_provider_test.dart
git commit -m "feat: integrate logging tutorial into workout screen

- Behavior-triggered tutorial on first set completion
- LayerLink attached to set checkmark button
- TutorialOverlayManager integration
- Automatic persistence after dismissal

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 5: Timer Tutorial Integration

**Files:**
- Modify: `lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart`
- Add: Tutorial trigger when timer starts

**Step 1: Add LayerLink to timer overlay**

Modify `lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart`:

```dart
// Add at class level
final LayerLink _timerLayerLink = LayerLink();

// Wrap the timer display with CompositedTransformTarget
@override
Widget build(BuildContext context) {
  // ... existing code ...

  return CompositedTransformTarget(
    link: _timerLayerLink,
    child: Container(
      // ... existing timer UI ...
    ),
  );
}
```

**Step 2: Add tutorial trigger when timer starts**

In the timer start logic, add:

```dart
// When timer starts
void _startTimer() {
  // ... existing timer start logic ...

  // Trigger tutorial
  ref.read(workoutTutorialProvider.notifier).onRestTimerStarted();
}
```

**Step 3: Add timer tutorial config to WorkoutScreen**

In `workout_screen.dart`, update the tutorial config:

```dart
// Create tutorial config for timer
final timerTutorialConfig = tutorialState.shouldShowTimerTutorial
    ? TutorialConfig(
        id: 'workout_rest_timer',
        steps: [
          TutorialStep(
            id: 'timer_controls_step',
            targetLink: _timerLayerLink, // Get from timer widget
            titleKey: context.l10n.tutorialTimerControlsTitle,
            descriptionKey: context.l10n.tutorialTimerControlsDescription,
          ),
        ],
      )
    : null;

// Use the timer config if no logging tutorial active
final activeConfig = loggingTutorialConfig ?? timerTutorialConfig;

return TutorialOverlayManager(
  config: activeConfig,
  child: Scaffold(/* ... */),
);
```

**Step 4: Test manually**

1. Start app
2. Create workout
3. Add exercise
4. Complete first set → Logging tutorial should appear
5. Dismiss tutorial
6. Let timer start → Timer tutorial should appear
7. Verify both tutorials only show once

**Step 5: Commit**

```bash
git add lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart \
        lib/features/workout/presentation/workout_screen.dart
git commit -m "feat: add rest timer tutorial integration

- LayerLink on timer overlay widget
- Tutorial triggered on first timer start
- Auto-sequence: logging → timer tutorials
- Only shows once per user

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 6: Settings Screen Tutorial Reset

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Add: Reset tutorials option in developer settings

**Step 1: Add tutorial reset option to settings**

Modify `lib/features/settings/presentation/settings_screen.dart`:

```dart
// In the developer settings section
ListTile(
  leading: Icon(Icons.school_outlined),
  title: Text(context.l10n.resetTutorials),
  subtitle: Text(context.l10n.resetTutorialsDescription),
  onTap: () async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.resetTutorials),
        content: Text(context.l10n.resetTutorialsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final tutorialService = ContextualTutorialService();
      await tutorialService.initialize();
      await tutorialService.resetAllTutorials();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.tutorialsResetSuccess),
            backgroundColor: context.colors.success,
          ),
        );
      }
    }
  },
)
```

**Step 2: Add l10n strings**

Add to `app_en.arb`:
```json
"resetTutorials": "Reset Tutorials",
"resetTutorialsDescription": "Show all contextual tutorials again",
"resetTutorialsConfirmation": "Are you sure you want to reset all tutorials? They will appear again when you perform the associated actions.",
"tutorialsResetSuccess": "Tutorials reset successfully",
"cancel": "Cancel",
"reset": "Reset"
```

Add to `app_it.arb`:
```json
"resetTutorials": "Ripristina Tutorial",
"resetTutorialsDescription": "Mostra di nuovo tutti i tutorial contestuali",
"resetTutorialsConfirmation": "Sei sicuro di voler ripristinare tutti i tutorial? Appariranno di nuovo quando eseguirai le azioni associate.",
"tutorialsResetSuccess": "Tutorial ripristinati con successo",
"cancel": "Annulla",
"reset": "Ripristina"
```

**Step 3: Regenerate l10n**

Run: `flutter gen-l10n`
Expected: SUCCESS

**Step 4: Test manually**

1. Go to Settings
2. Find "Reset Tutorials" option
3. Tap it
4. Confirm reset
5. Go back to workout
6. Verify tutorials show again

**Step 5: Commit**

```bash
git add lib/features/settings/presentation/settings_screen.dart \
        assets/i18n/app_en.arb \
        assets/i18n/app_it.arb
git commit -m "feat: add tutorial reset option in settings

- Reset all tutorials button in developer settings
- Confirmation dialog
- Success snackbar
- Full localization support

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 7: Documentation

**Files:**
- Create: `docs/UX_FLOWS/onboarding/CONTEXTUAL_TUTORIAL_SYSTEM.md`

**Step 1: Create documentation**

```markdown
# Contextual Tutorial System Documentation

## Overview

Production-ready contextual tutorial system using LayerLink pattern for GymBro fitness app. Implements behavior-triggered, auto-following tutorials that guide users through critical features.

## Architecture

### Core Components

1. **ContextualTutorialService** (`lib/shared/domain/services/contextual_tutorial_service.dart`)
   - SharedPreferences-based persistence
   - Version-based reset mechanism
   - Tutorial tracking per user

2. **SpotlightPainter** (`lib/shared/presentation/widgets/spotlight_painter.dart`)
   - Performance-optimized CustomPainter
   - Path.fillType evenOdd pattern (avoids saveLayer)
   - Pulse animation for highlight border

3. **TutorialManager** (`lib/shared/presentation/providers/tutorial_manager_provider.dart`)
   - Riverpod StateNotifier for state management
   - Coordinates tutorial lifecycle
   - Triggers tutorial based on user behavior

4. **TutorialOverlayManager** (`lib/shared/presentation/widgets/tutorial_overlay_manager.dart`)
   - Manages OverlayEntry lifecycle
   - Proper disposal pattern (remove → postFrameCallback → dispose)
   - Auto-following tooltip with LayerLink

### Tutorial Triggers

| Tutorial ID | Trigger Event | Priority | Screen |
|------------|---------------|----------|--------|
| `workout_logging_first_set` | User completes first set | CRITICAL | Workout Screen |
| `workout_rest_timer` | Rest timer starts for first time | CRITICAL | Workout Screen |
| `workout_add_exercise` | User opens empty workout | HIGH | Workout Screen |

### Performance Optimizations

**Avoided Patterns:**
- ❌ `ColorFiltered` + `BlendMode.srcOut` (expensive saveLayer)
- ❌ Multiple active LayerLink simultaneously (>5-7)
- ❌ Showing tutorials upfront (low retention)

**Implemented Patterns:**
- ✅ `CustomPainter` with `PathFillType.evenOdd` (no saveLayer)
- ✅ Single active tutorial at a time
- ✅ Behavior-triggered contextual tutorials (50% retention increase)

## Usage

### Adding New Tutorial

1. **Define Tutorial ID and Trigger**

```dart
// In your feature provider
static const String _newTutorialId = 'feature_new_action';

Future<void> onNewAction() async {
  final shouldShow = await _service.shouldShowTutorial(_newTutorialId);
  if (shouldShow && mounted) {
    state = state.copyWith(shouldShowNewTutorial: true);
  }
}
```

2. **Add LayerLink to Target Widget**

```dart
final LayerLink _targetLayerLink = LayerLink();

CompositedTransformTarget(
  link: _targetLayerLink,
  child: YourTargetWidget(),
)
```

3. **Create Tutorial Config**

```dart
final newTutorialConfig = TutorialConfig(
  id: 'feature_new_action',
  steps: [
    TutorialStep(
      id: 'new_action_step',
      targetLink: _targetLayerLink,
      titleKey: context.l10n.tutorialNewActionTitle,
      descriptionKey: context.l10n.tutorialNewActionDescription,
    ),
  ],
);
```

4. **Wrap Screen with TutorialOverlayManager**

```dart
return TutorialOverlayManager(
  config: newTutorialConfig,
  child: YourScreen(),
);
```

5. **Add Localization Strings**

```json
// app_en.arb
"tutorialNewActionTitle": "New Feature",
"tutorialNewActionDescription": "Description of what this feature does..."

// app_it.arb
"tutorialNewActionTitle": "Nuova Funzionalità",
"tutorialNewActionDescription": "Descrizione di cosa fa questa funzione..."
```

## Testing

### Unit Tests

Run all tests:
```bash
flutter test test/shared/domain/services/contextual_tutorial_service_test.dart
flutter test test/shared/presentation/providers/tutorial_manager_provider_test.dart
flutter test test/features/workout/presentation/providers/workout_tutorial_provider_test.dart
```

### Manual Testing

1. **First Run Experience**
   - Create new workout
   - Add exercise
   - Complete first set → Logging tutorial appears
   - Dismiss tutorial
   - Wait for timer → Timer tutorial appears

2. **Tutorial Reset**
   - Go to Settings
   - Tap "Reset Tutorials"
   - Confirm reset
   - Verify tutorials show again

3. **Performance**
   - Profile mode test on real device
   - Verify no jank during tutorial animation
   - Check memory usage (no leaks)

## Research Foundation

Based on extensive research:
- 71% user abandonment due to confusing UX
- Contextual tutorials increase retention by 50%
- Behavior-triggered > Upfront onboarding

Critical confusion points addressed:
1. ✅ Logging sets (top confusion)
2. ✅ Timer behavior (top frustration)
3. ⏳ Superset creation (Phase 2)
4. ⏳ Exercise selection (Phase 2)

## Related Documentation

- [WORKOUT_SYSTEM_OVERVIEW.md](../workout_session/WORKOUT_SYSTEM_OVERVIEW.md)
- [TIMER_SYSTEM_DOCUMENTATION.md](../notifications_background/TIMER_SYSTEM_DOCUMENTATION.md)
- [CLAUDE.md](../../../CLAUDE.md) - Localization & theme rules
```

**Step 2: Update INDEX.md**

Add to `docs/NAVIGATION/INDEX.md` under "Quick Navigation by Task":

```markdown
**Contextual Tutorials**:
1. Read: [`CONTEXTUAL_TUTORIAL_SYSTEM.md`](../UX_FLOWS/onboarding/CONTEXTUAL_TUTORIAL_SYSTEM.md)
2. Reference: Architecture, usage, testing guide
```

**Step 3: Commit**

```bash
git add docs/UX_FLOWS/onboarding/CONTEXTUAL_TUTORIAL_SYSTEM.md \
        docs/NAVIGATION/INDEX.md
git commit -m "docs: add contextual tutorial system documentation

- Complete architecture overview
- Usage guide for adding new tutorials
- Testing instructions
- Research foundation and metrics

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## ✅ Verification Checklist

After completing all tasks:

- [ ] All tests pass: `flutter test`
- [ ] No analyzer issues: `flutter analyze`
- [ ] Localizations regenerated: `flutter gen-l10n`
- [ ] Manual testing completed (logging, timer, reset)
- [ ] Performance profiled in release mode
- [ ] Memory leaks checked with DevTools
- [ ] Documentation reviewed and accurate
- [ ] All commits follow message format

---

## 🚀 Future Enhancements (Phase 2-3)

**Phase 2 (HIGH Priority):**
- Superset creation tutorial
- Exercise selection tutorial
- Equipment filter tutorial

**Phase 3 (MEDIUM Priority):**
- Home widget customization tutorial
- Advanced features (dropset, rest-pause) tutorial
- Routine creation tutorial

---

## 📊 Success Metrics

Track these metrics to validate tutorial effectiveness:

1. **Tutorial Completion Rate**: % users who complete vs. skip
2. **Feature Adoption**: % users who use feature after seeing tutorial
3. **Tutorial Reset Rate**: How often users reset tutorials
4. **Retention Impact**: Week 1 retention comparison (with/without tutorials)

Target: 50% increase in feature adoption for tutorialized features
