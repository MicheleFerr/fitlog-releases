/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Workout Tutorial
/// Type: Service
///
/// Interactive tutorial service for the workout screen.
/// Shows contextual hints as user completes actions.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Tutorial steps in order
enum WorkoutTutorialStep {
  /// Step 1: Welcome and orientation to workout screen
  welcome,

  /// Step 2: Highlight the FAB to add first exercise
  addExercise,

  /// Step 3: Explain browsing the exercise database
  browseDatabase,

  /// Step 4: Explain filters, variants and custom exercise creation
  filtersAndCustom,

  /// Step 5: Exercise-level customization (rest/counting/between exercises)
  customizeExercise,

  /// Step 6: Workout-level settings (tracking and appearance)
  workoutSettings,

  /// Step 7: Set editing gestures and apply/copy actions
  editSetGestures,

  /// Step 8: Set completion with RPE and weight verification
  completeSetRpe,

  /// Tutorial completed
  completed,
}

/// State for the interactive tutorial
class WorkoutTutorialState {
  const WorkoutTutorialState({
    required this.isActive,
    required this.currentStep,
    required this.hasCompletedTutorial,
    required this.hasStartedTutorial,
    this.isPaused = false,
  });

  /// Whether the tutorial is currently running
  final bool isActive;

  /// Current step in the tutorial
  final WorkoutTutorialStep currentStep;

  /// Whether user has completed the full tutorial before
  final bool hasCompletedTutorial;

  /// Whether user has started the tutorial at least once (even if not completed)
  /// This prevents the tutorial from auto-showing repeatedly if user dismisses it
  final bool hasStartedTutorial;

  /// Whether tutorial is paused (e.g., during modal navigation)
  /// When paused, overlay is hidden but state is preserved
  final bool isPaused;

  WorkoutTutorialState copyWith({
    bool? isActive,
    WorkoutTutorialStep? currentStep,
    bool? hasCompletedTutorial,
    bool? hasStartedTutorial,
    bool? isPaused,
  }) {
    return WorkoutTutorialState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
      hasStartedTutorial: hasStartedTutorial ?? this.hasStartedTutorial,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// Notifier for managing interactive tutorial state
class WorkoutTutorialNotifier extends Notifier<WorkoutTutorialState> {
  // ✅ FIX: Static cache to survive provider rebuilds (background/foreground transitions)
  // This prevents tutorial from restarting when app resumes
  static WorkoutTutorialState? _cachedState;

  // ✅ FIX: Track when state has been loaded from SharedPreferences
  // This prevents race condition where tutorial starts before prefs are loaded
  static bool _isLoaded = false;
  static Completer<void>? _loadCompleter;

  /// Reset static cache between tests to avoid cross-test state leakage.
  static void clearCacheForTesting() {
    _cachedState = null;
    _isLoaded = false;
    _loadCompleter = null;
  }

  @override
  WorkoutTutorialState build() {
    // Load from SharedPreferences if no cache available
    if (_cachedState == null) {
      _loadState();
    }
    return _cachedState ??
        const WorkoutTutorialState(
          isActive: false,
          currentStep: WorkoutTutorialStep.welcome,
          hasCompletedTutorial: false,
          hasStartedTutorial: false,
        );
  }

  static const String _completedKey = 'workout_tutorial_completed';
  static const String _startedKey = 'workout_tutorial_started';
  TutorialCoachMark? _currentTutorial;

  /// Whether the state has been loaded from SharedPreferences
  /// Use this to prevent race conditions when checking tutorial state
  bool get isLoaded => _isLoaded;

  /// Wait for state to be loaded from SharedPreferences
  /// Call this before checking hasStartedTutorial or hasCompletedTutorial
  Future<void> waitForLoad() async {
    if (_isLoaded) return;
    if (_loadCompleter != null) {
      await _loadCompleter!.future;
    }
  }

  Future<void> _loadState() async {
    // Prevent multiple concurrent loads
    if (_loadCompleter != null) return;
    _loadCompleter = Completer<void>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_completedKey) ?? false;
      final started = prefs.getBool(_startedKey) ?? false;
      state = state.copyWith(
        hasCompletedTutorial: completed,
        hasStartedTutorial: started,
      );
      // ✅ FIX: Update cache after loading from SharedPreferences
      _cachedState = state;
      _isLoaded = true;
    } finally {
      _loadCompleter?.complete();
      _loadCompleter = null;
    }
  }

  /// Start the interactive tutorial
  Future<void> startTutorial() async {
    // Mark tutorial as started (prevents auto-showing again)
    if (!state.hasStartedTutorial) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_startedKey, true);
    }

    state = state.copyWith(
      isActive: true,
      currentStep: WorkoutTutorialStep.welcome,
      hasStartedTutorial: true,
    );
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Stop/cancel the tutorial
  void stopTutorial() {
    _currentTutorial?.finish();
    _currentTutorial = null;
    state = state.copyWith(isActive: false);
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Pause the tutorial (e.g., when modal opens)
  /// Preserves tutorial state but hides overlay
  void pauseTutorial() {
    _currentTutorial?.finish();
    state = state.copyWith(isPaused: true);
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Resume the tutorial after pause (e.g., when modal closes)
  /// Re-shows the overlay at current step
  void resumeTutorial() {
    state = state.copyWith(isPaused: false);
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Move to the next step
  void advanceToStep(WorkoutTutorialStep step) {
    if (!state.isActive) return;
    state = state.copyWith(currentStep: step);
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Mark tutorial as completed
  Future<void> completeTutorial() async {
    // NOTE: Do NOT call _currentTutorial?.finish() here!
    // This would trigger onFinish callback again, causing infinite loop.
    // The tutorial is already finished when this method is called from onComplete callback.
    _currentTutorial = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: true,
      currentStep: WorkoutTutorialStep.completed,
    );
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Reset tutorial (for testing)
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
    await prefs.remove(_startedKey);
    state = state.copyWith(
      isActive: false,
      hasCompletedTutorial: false,
      hasStartedTutorial: false,
      currentStep: WorkoutTutorialStep.welcome,
    );
    // ✅ FIX: Update cache after state change
    _cachedState = state;
  }

  /// Show the current step's overlay
  void showCurrentStep({
    required BuildContext context,
    required GlobalKey targetKey,
    VoidCallback? onComplete,
    bool onCompleteFallbackAfterNext = false,
  }) {
    if (!state.isActive) return;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Check if target exists
    if (targetKey.currentContext == null) {
      debugPrint('⚠️ [Tutorial] Target not found for ${state.currentStep}');
      return;
    }

    final stepConfig = _getStepConfig(state.currentStep, l10n);
    if (stepConfig == null) return;
    var didComplete = false;

    void completeOnce() {
      if (didComplete) return;
      didComplete = true;
      onComplete?.call();
    }

    final target = TargetFocus(
      identify: state.currentStep.name,
      keyTarget: targetKey,
      alignSkip: Alignment.topRight,
      // Keep action flow consistent: primary CTA drives guided actions.
      enableTargetTab: false,
      enableOverlayTab: false,
      shape: stepConfig.shape,
      radius: stepConfig.radius,
      paddingFocus: 10,
      contents: [
        TargetContent(
          align: stepConfig.contentAlign,
          builder: (context, controller) => _buildContent(
            context: context,
            title: stepConfig.title,
            message: stepConfig.message,
            stepNumber: state.currentStep.index + 1,
            totalSteps:
                WorkoutTutorialStep.values.length - 1, // exclude 'completed'
            onNext: () {
              controller.next();
              if (onCompleteFallbackAfterNext) {
                // Optional fallback for route/sheet transitions where onFinish
                // can be dropped on some devices.
                unawaited(
                  Future<void>.delayed(
                    const Duration(milliseconds: 420),
                    completeOnce,
                  ),
                );
              }
            },
            onSkip: () {
              controller.skip();
              stopTutorial();
            },
            colors: colors,
            isLast: state.currentStep == WorkoutTutorialStep.completeSetRpe,
            contentAlign: stepConfig.contentAlign,
            primaryButtonLabel: stepConfig.primaryButtonLabel,
          ),
        ),
      ],
    );

    _currentTutorial = TutorialCoachMark(
      targets: [target],
      colorShadow: colors.surface,
      opacityShadow: 0.85,
      textSkip: l10n.skip,
      textStyleSkip: textTheme.labelMedium!.copyWith(
        color: colors.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
      paddingFocus: 10,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      hideSkip: true, // Skip button is already in custom dialog content
      onFinish: () {
        completeOnce();
      },
      onSkip: () {
        stopTutorial();
        return true;
      },
    );

    _currentTutorial!.show(context: context);
  }

  /// Dismiss only the currently displayed overlay without changing tutorial state.
  /// Useful when a guided action must open another route/sheet deterministically.
  void dismissCurrentStepOverlay() {
    _currentTutorial?.removeOverlayEntry();
    _currentTutorial = null;
  }

  /// Get configuration for a step
  _StepConfig? _getStepConfig(WorkoutTutorialStep step, AppLocalizations l10n) {
    final content = _localizedStepContent(step, l10n);
    if (content == null) return null;

    switch (step) {
      case WorkoutTutorialStep.welcome:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          // Welcome step targets the FAB (bottom-right), so keep content above it
          // to avoid overlap with the persistent bottom tab bar.
          contentAlign: ContentAlign.top,
        );
      case WorkoutTutorialStep.addExercise:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
          primaryButtonLabel: l10n.localeName.toLowerCase().startsWith('it')
              ? 'Apri aggiungi esercizio'
              : 'Open add exercise',
        );
      case WorkoutTutorialStep.browseDatabase:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          contentAlign: ContentAlign.top,
          primaryButtonLabel: l10n.localeName.toLowerCase().startsWith('it')
              ? 'Sfoglia database'
              : 'Browse database',
        );
      case WorkoutTutorialStep.filtersAndCustom:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          // Target is in the top app bar: keep content below it.
          contentAlign: ContentAlign.bottom,
          primaryButtonLabel: l10n.localeName.toLowerCase().startsWith('it')
              ? 'Apri filtri'
              : 'Open filters',
        );
      case WorkoutTutorialStep.customizeExercise:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.Circle,
          radius: 8,
          contentAlign: ContentAlign.bottom,
          primaryButtonLabel: l10n.localeName.toLowerCase().startsWith('it')
              ? 'Continua nel workout'
              : 'Continue to workout',
        );
      case WorkoutTutorialStep.workoutSettings:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.Circle,
          radius: 8,
          contentAlign: ContentAlign.bottom,
          primaryButtonLabel: l10n.localeName.toLowerCase().startsWith('it')
              ? 'Apri impostazioni'
              : 'Open settings',
        );
      case WorkoutTutorialStep.editSetGestures:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.bottom,
          primaryButtonLabel: l10n.localeName.toLowerCase().startsWith('it')
              ? 'Apri modifica set'
              : 'Open set editor',
        );
      case WorkoutTutorialStep.completeSetRpe:
        return _StepConfig(
          title: content.title,
          message: content.message,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contentAlign: ContentAlign.bottom,
          primaryButtonLabel: l10n.localeName.toLowerCase().startsWith('it')
              ? 'Apri conferma RPE'
              : 'Open RPE confirmation',
        );
      case WorkoutTutorialStep.completed:
        return null;
    }
  }

  _StepContent? _localizedStepContent(
    WorkoutTutorialStep step,
    AppLocalizations l10n,
  ) {
    final isItalian = l10n.localeName.toLowerCase().startsWith('it');

    switch (step) {
      case WorkoutTutorialStep.welcome:
        return _StepContent(
          title: isItalian
              ? 'Benvenuto nella schermata Workout'
              : 'Welcome to the Workout screen',
          message: isItalian
              ? 'Qui costruisci e tracci il tuo allenamento in tempo reale.'
              : 'This is where you build and track your workout in real time.',
        );
      case WorkoutTutorialStep.addExercise:
        return _StepContent(
          title: isItalian
              ? 'Aggiungi il primo esercizio'
              : 'Add your first exercise',
          message: isItalian
              ? 'Usa il tasto + per inserire un esercizio nel workout.'
              : 'Use the + button to add an exercise to the workout.',
        );
      case WorkoutTutorialStep.browseDatabase:
        return _StepContent(
          title: isItalian ? 'Scegli dal database' : 'Pick from the database',
          message: isItalian
              ? 'Apri il database esercizi e seleziona uno degli esercizi esistenti.'
              : 'Open the exercise database and choose one of the existing exercises.',
        );
      case WorkoutTutorialStep.filtersAndCustom:
        return _StepContent(
          title: isItalian
              ? 'Filtri, varianti e custom'
              : 'Filters, variants and custom',
          message: isItalian
              ? 'Usa i filtri per trovare piu velocemente, scegli varianti o crea un esercizio custom se non esiste.'
              : 'Use filters to find exercises faster, select variants, or create a custom exercise if needed.',
        );
      case WorkoutTutorialStep.customizeExercise:
        return _StepContent(
          title: isItalian
              ? 'Personalizza l esercizio'
              : 'Customize the exercise',
          message: isItalian
              ? 'Nella schermata Personalizza imposta counting mode, timer recupero e riposo tra esercizi.'
              : 'In the Customize screen set counting mode, rest timer, and rest between exercises.',
        );
      case WorkoutTutorialStep.workoutSettings:
        return _StepContent(
          title: isItalian ? 'Impostazioni workout' : 'Workout settings',
          message: isItalian
              ? 'Apri il menu in alto a destra per configurare tracking e aspetto della schermata workout.'
              : 'Open the top-right menu to configure workout tracking and screen appearance.',
        );
      case WorkoutTutorialStep.editSetGestures:
        return _StepContent(
          title: isItalian
              ? 'Modifica set e gesture'
              : 'Edit sets and gestures',
          message: isItalian
              ? 'Per modificare un set, tocca la matita. Poi usa le gesture per copiare dal precedente o applicare a tutti.'
              : 'To edit a set, tap the pencil icon. Then use gestures to copy from previous or apply changes to all sets.',
        );
      case WorkoutTutorialStep.completeSetRpe:
        return _StepContent(
          title: isItalian ? 'Completa set con RPE' : 'Complete sets with RPE',
          message: isItalian
              ? 'Quando completi un set, conferma peso/ripetizioni e inserisci RPE per un tracciamento preciso.'
              : 'When completing a set, verify weight/reps and provide RPE for accurate tracking.',
        );
      case WorkoutTutorialStep.completed:
        return null;
    }
  }

  /// Build content widget for a tutorial step
  static Widget _buildContent({
    required BuildContext context,
    required String title,
    required String message,
    required int stepNumber,
    required int totalSteps,
    required VoidCallback onNext,
    required VoidCallback onSkip,
    required ColorScheme colors,
    required ContentAlign contentAlign,
    String? primaryButtonLabel,
    bool isLast = false,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final bottomSafeInset = mediaQuery.viewPadding.bottom;
    final bottomBarOffset = contentAlign == ContentAlign.bottom
        ? (kBottomNavigationBarHeight + bottomSafeInset + 20)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomBarOffset),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with step indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$stepNumber/$totalSteps',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    AppLocalizations.of(context).skip,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  primaryButtonLabel ??
                      (isLast
                          ? AppLocalizations.of(context).tutorialGotIt
                          : AppLocalizations.of(context).tutorialNext),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Configuration for a tutorial step
class _StepConfig {
  const _StepConfig({
    required this.title,
    required this.message,
    required this.shape,
    required this.radius,
    required this.contentAlign,
    this.primaryButtonLabel,
  });

  final String title;
  final String message;
  final ShapeLightFocus shape;
  final double radius;
  final ContentAlign contentAlign;
  final String? primaryButtonLabel;
}

class _StepContent {
  const _StepContent({required this.title, required this.message});

  final String title;
  final String message;
}

/// Provider for the workout tutorial state
final workoutTutorialProvider =
    NotifierProvider<WorkoutTutorialNotifier, WorkoutTutorialState>(
      WorkoutTutorialNotifier.new,
    );

/// Provider for checking if tutorial is completed
final workoutTutorialCompletedProvider = Provider<bool>((ref) {
  return ref.watch(workoutTutorialProvider).hasCompletedTutorial;
});
