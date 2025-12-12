import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_config.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_tour_step.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/utils/spotlight_positioning.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Manages the state and flow of the onboarding tour
///
/// Handles:
///   - Tour progression (start, next, previous, end)
///   - Auto-scrolling widgets into view
///   - Calculating spotlight bounds and positioning
///   - Managing animation states during transitions
///
/// Extends ChangeNotifier to notify listeners when state changes.
class OnboardingTourManager extends ChangeNotifier {

  OnboardingTourManager(
    this._targetKeys, {
    VoidCallback? onTourCompleted,
  }) : _onTourCompleted = onTourCompleted;
  /// Current step index (0-based)
  int _currentStepIndex = 0;

  /// Current target widget bounds in global coordinates
  Rect? _currentSpotlightBounds;

  /// Calculated offset for centering the spotlight
  Offset? _currentSpotlightOffset;

  /// Whether a transition animation is in progress
  bool _isTransitioning = false;

  /// Whether the tour is currently active
  bool _isActive = false;

  /// Map of target widget keys for lookup
  final Map<String, GlobalKey> _targetKeys;

  /// Timer for auto-advancing through SIMPLE steps
  Timer? _autoAdvanceTimer;

  /// Build context for timer callbacks (stored for async timer use)
  BuildContext? _tourContext;

  /// Callback invoked when tour is completed (for saving state)
  final VoidCallback? _onTourCompleted;

  // Getters
  int get currentStepIndex => _currentStepIndex;
  Rect? get currentSpotlightBounds => _currentSpotlightBounds;
  Offset? get currentSpotlightOffset => _currentSpotlightOffset;
  bool get isTransitioning => _isTransitioning;
  bool get isActive => _isActive;

  /// Current tour step
  OnboardingTourStep get currentStep {
    final step = OnboardingTourConfig.getStepByPosition(_currentStepIndex);
    assert(
      step != null,
      'Invalid step index: $_currentStepIndex',
    );
    return step!;
  }

  /// Total number of steps in tour
  int get totalSteps => OnboardingTourConfig.totalSteps;

  /// Progress percentage (0.0 to 1.0)
  double get progress => (_currentStepIndex + 1) / totalSteps;

  /// Whether we're on the last step
  bool get isLastStep => _currentStepIndex >= totalSteps - 1;

  /// Whether we're on the first step
  bool get isFirstStep => _currentStepIndex == 0;

  /// Starts the tour from the beginning
  ///
  /// Initializes tour state and shows the first step's spotlight.
  /// Uses provided context if available, otherwise uses saved _tourContext.
  Future<void> startTour([BuildContext? context]) async {
    _isActive = true;
    _currentStepIndex = 0;
    notifyListeners();

    // Use provided context or saved tour context
    final safeContext = context ?? _tourContext;
    if (safeContext != null) {
      // Show first step
      await showStepSpotlight(0, safeContext);
    }
  }

  /// Ends the tour and resets state
  ///
  /// Calls the onTourCompleted callback to save tour completion state.
  void endTour() {
    // Cancel any running auto-advance timer
    _cancelAutoAdvance();

    _isActive = false;
    _currentStepIndex = 0;
    _currentSpotlightBounds = null;
    _currentSpotlightOffset = null;
    _isTransitioning = false;
    _tourContext = null;
    notifyListeners();

    // Save tour completion state via callback
    _onTourCompleted?.call();
    if (kDebugMode) {
      debugPrint('✅ [TOUR] Tour completed and state saved');
    }
  }

  /// Advances to the next step
  ///
  /// If on last step, ends the tour instead.
  /// Uses saved _tourContext for safe async operations.
  Future<void> nextStep([BuildContext? context]) async {
    if (!_isActive) return;

    // Cancel auto-advance timer before moving to next step
    _cancelAutoAdvance();

    if (isLastStep) {
      endTour();
      return;
    }

    _currentStepIndex++;
    notifyListeners();

    // Use saved tour context (mounted and valid) instead of passed context
    final safeContext = _tourContext ?? context;
    if (safeContext != null) {
      await showStepSpotlight(_currentStepIndex, safeContext);
    }
  }

  /// Goes back to the previous step
  ///
  /// If on first step, does nothing.
  /// Uses saved _tourContext for safe async operations.
  Future<void> previousStep([BuildContext? context]) async {
    if (!_isActive || isFirstStep) return;

    // Cancel auto-advance timer before moving to previous step
    _cancelAutoAdvance();

    _currentStepIndex--;
    notifyListeners();

    // Use saved tour context (mounted and valid) instead of passed context
    final safeContext = _tourContext ?? context;
    if (safeContext != null) {
      await showStepSpotlight(_currentStepIndex, safeContext);
    }
  }

  /// Shows the spotlight for a specific step
  ///
  /// This is the main method that:
  ///   1. Gets the target widget key for the step
  ///   2. Auto-scrolls the widget into view
  ///   3. Calculates the widget's global bounds
  ///   4. Calculates centering offset
  ///   5. Notifies listeners to update UI
  ///
  /// Parameters:
  ///   - [stepIndex]: The step number to display (0-based)
  ///   - [context]: Build context for coordinate calculations
  ///
  /// Returns: A Future that completes when positioning is done
  Future<void> showStepSpotlight(int stepIndex, BuildContext context) async {
    try {
      _isTransitioning = true;
      notifyListeners();

      // Get the step definition
      final step = OnboardingTourConfig.getStepByPosition(stepIndex);
      if (step == null) {
        if (kDebugMode) {
          debugPrint('❌ [OnboardingTourManager] Invalid step index: $stepIndex');
        }
        _isTransitioning = false;
        notifyListeners();
        return;
      }

      // Get the target widget key
      final targetKey = _targetKeys[step.id];
      if (targetKey == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ [OnboardingTourManager] No target key for step: ${step.id}',
          );
        }
        _isTransitioning = false;
        notifyListeners();
        return;
      }

      // Get the widget's context and ensure it's in the widget tree
      final targetContext = targetKey.currentContext;
      if (targetContext == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ [OnboardingTourManager] Target widget not found: ${step.id}',
          );
        }
        _isTransitioning = false;
        notifyListeners();
        return;
      }

      // Auto-scroll the widget into view first
      await _scrollIntoView(targetContext);

      // Add a small delay to let scroll animation complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Get the global bounds of the target widget
      _currentSpotlightBounds = targetContext.globalPaintBounds;

      if (_currentSpotlightBounds == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ [OnboardingTourManager] Could not get bounds for: ${step.id}',
          );
        }
        _isTransitioning = false;
        notifyListeners();
        return;
      }

      // Validate the bounds (check context is still valid after async gap)
      if (!context.mounted) {
        if (kDebugMode) {
          debugPrint('⚠️ [OnboardingTourManager] Context no longer mounted');
        }
        return;
      }
      final screenSize = MediaQuery.of(context).size;
      if (!SpotlightPositioningUtil.validateBounds(
        _currentSpotlightBounds,
        screenSize,
      )) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [OnboardingTourManager] Bounds validation failed for: ${step.id}',
          );
        }
      }

      // Calculate centering offset
      _currentSpotlightOffset = SpotlightPositioningUtil.calculateCenteringOffset(
        targetBounds: _currentSpotlightBounds!,
        screenSize: screenSize,
      );

      if (kDebugMode) {
        debugPrint(
          '✅ [OnboardingTourManager] Showing step: ${step.id} '
          'at bounds: $_currentSpotlightBounds '
          'with offset: $_currentSpotlightOffset',
        );
      }

      // Store context for timer callbacks
      _tourContext = context;

      _isTransitioning = false;
      notifyListeners();

      // Start auto-advance timer if this is a SIMPLE step
      _startAutoAdvanceIfNeeded();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [OnboardingTourManager] Error showing spotlight: $e');
      }
      _isTransitioning = false;
      notifyListeners();
    }
  }

  /// Auto-scrolls the target widget into view, centered on screen
  ///
  /// Uses Scrollable.ensureVisible to scroll the widget so that:
  ///   - The widget is centered vertically in the viewport
  ///   - The scroll animation is smooth with easeInOut curve
  ///   - The animation takes 500ms to complete
  ///
  /// Parameters:
  ///   - [targetContext]: The build context of the target widget
  Future<void> _scrollIntoView(BuildContext targetContext) async {
    try {
      // Use Scrollable.ensureVisible to center widget on screen
      // alignment: 0.5 means center
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.5, // Center the widget
      );

      // Wait for scroll animation to complete
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [OnboardingTourManager] Scroll into view failed: $e');
      }
      // Don't fail entirely if scrolling fails
    }
  }

  /// Cancels the auto-advance timer (if active)
  void _cancelAutoAdvance() {
    if (_autoAdvanceTimer != null && _autoAdvanceTimer!.isActive) {
      if (kDebugMode) {
        debugPrint(
          '⏹️ [OnboardingTourManager] Cancelling auto-advance timer',
        );
      }
      _autoAdvanceTimer!.cancel();
      _autoAdvanceTimer = null;
    }
  }

  /// Starts the auto-advance timer if current step is SIMPLE
  ///
  /// SIMPLE steps auto-advance after their configured duration.
  /// COMPLEX steps do NOT auto-advance (user must manually advance).
  void _startAutoAdvanceIfNeeded() {
    // Cancel any existing timer first
    _cancelAutoAdvance();

    final step = currentStep;

    // Only start timer for SIMPLE steps
    if (step.type != TourStepType.simple || step.autoAdvanceDuration == null) {
      if (kDebugMode) {
        debugPrint(
          '⏸️ [OnboardingTourManager] Step ${step.id} is COMPLEX - waiting for user input',
        );
      }
      return;
    }

    // Store duration for logging
    final durationSeconds = step.autoAdvanceDuration!.inSeconds;

    if (kDebugMode) {
      debugPrint(
        '⏱️ [OnboardingTourManager] Starting auto-advance timer for ${step.id} '
        '(${durationSeconds}s)',
      );
    }

    _autoAdvanceTimer = Timer(step.autoAdvanceDuration!, () {
      if (kDebugMode) {
        debugPrint(
          '⏭️ [OnboardingTourManager] Auto-advancing from ${step.id} to next step',
        );
      }

      // Only advance if tour is still active and context is valid
      if (_isActive && _tourContext != null && _tourContext!.mounted) {
        // Advance to next step
        nextStep(_tourContext!);
      }
    });
  }

  /// Checks if all required steps have valid target widgets
  ///
  /// Useful for validating the tour configuration at startup.
  ///
  /// Returns: A list of missing step IDs, empty if all steps are valid
  List<String> validateTourSetup() {
    final missingSteps = <String>[];

    for (int i = 0; i < totalSteps; i++) {
      final step = OnboardingTourConfig.getStepByPosition(i);
      if (step == null) {
        missingSteps.add('Step at position $i');
        continue;
      }

      if (_targetKeys[step.id] == null) {
        missingSteps.add(step.id);
      }
    }

    if (missingSteps.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [OnboardingTourManager] Missing target keys: $missingSteps',
        );
      }
    }

    return missingSteps;
  }

  /// Gets the current step definition
  ///
  /// Useful for UI widgets that need to display step information.
  OnboardingTourStep? getStepAtIndex(int index) {
    return OnboardingTourConfig.getStepByPosition(index);
  }

  /// Jumps directly to a specific step (for testing or advanced features)
  ///
  /// Warning: This bypasses normal progression flow. Use with caution.
  /// Uses saved _tourContext for safe async operations.
  Future<void> jumpToStep(int stepIndex, [BuildContext? context]) async {
    if (stepIndex < 0 || stepIndex >= totalSteps) {
      if (kDebugMode) {
        debugPrint('❌ [OnboardingTourManager] Invalid jump index: $stepIndex');
      }
      return;
    }

    _currentStepIndex = stepIndex;
    notifyListeners();

    // Use saved tour context (mounted and valid) instead of passed context
    final safeContext = _tourContext ?? context;
    if (safeContext != null) {
      await showStepSpotlight(stepIndex, safeContext);
    }
  }

  @override
  void dispose() {
    // Cancel any running auto-advance timer
    _cancelAutoAdvance();

    _isActive = false;
    _tourContext = null;
    super.dispose();
  }
}
