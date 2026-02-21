// ignore_for_file: sort_constructors_first

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Manager del ciclo di vita dell'app per gestire operazioni critiche
/// durante transizioni di stato (foreground/background).
///
/// **RESPONSABILITÀ**:
/// - Flush batch queue quando app va in background
/// - Cleanup risorse prima di suspend
/// - Salvare stato corrente prima di terminate
/// - Schedule "workout forgotten" notification when background + active workout
/// - Cancel notification when returning to foreground
///
/// **INTEGRAZIONE**:
/// Wrappare l'app principale in main.dart:
/// ```dart
/// runApp(
///   ProviderScope(
///     child: AppLifecycleManager(
///       child: MyApp(),
///     ),
///   ),
/// );
/// ```
///
/// **EVENTI GESTITI**:
/// - AppLifecycleState.paused: App in background (flush batch, schedule notification)
/// - AppLifecycleState.inactive: App sta perdendo focus (pre-flush)
/// - AppLifecycleState.resumed: App torna in foreground (cancel notification)
/// - AppLifecycleState.detached: App sta terminando (cleanup finale)
library;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:gymbro_flutter_new/features/settings/presentation/providers/cloud_sync_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_session_la_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/watch_connectivity_provider.dart';

/// Widget che gestisce il ciclo di vita dell'app
///
/// Monitora i cambiamenti di stato (foreground/background) e
/// esegue operazioni critiche come flush della batch queue.
class AppLifecycleManager extends ConsumerStatefulWidget {
  /// Widget child da wrappare (tipicamente MaterialApp)
  final Widget child;

  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager>
    with WidgetsBindingObserver {
  /// Track if we've already checked for draft recovery this session
  bool _hasCheckedDraftRecovery = false;

  /// Track if we've already synced from cloud this session
  bool _hasTriggeredCloudSync = false;

  @override
  void initState() {
    super.initState();
    // Registra observer per eventi lifecycle
    WidgetsBinding.instance.addObserver(this);

    if (kDebugMode) {
      debugPrint('📱 [AppLifecycle] Manager initialized');
    }

    // 💾 FIX: Check for recoverable workout draft on app startup (GLOBAL)
    // This ensures draft recovery happens regardless of which screen opens first.
    //
    // TIMING FIX: Use Future.microtask instead of addPostFrameCallback.
    // addPostFrameCallback runs AFTER the first frame is painted, which can cause
    // race conditions where other providers initialize and potentially start a
    // new workout before we've had a chance to recover the draft.
    // Future.microtask runs in the same event loop iteration but after the current
    // synchronous code completes, giving us earlier execution priority.
    Future.microtask(() {
      if (mounted) {
        _checkAndRecoverDraftGlobally();
        // 🔄 FIX: Cloud sync is now triggered via didChangeDependencies when auth is ready
        // Don't call _syncWorkoutsFromCloudOnStartup() here - auth isn't initialized yet
      }
    });
  }

  @override
  void dispose() {
    // Rimuovi observer prima del dispose
    WidgetsBinding.instance.removeObserver(this);

    if (kDebugMode) {
      debugPrint('📱 [AppLifecycle] Manager disposed');
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (kDebugMode) {
      debugPrint('📱 [AppLifecycle] State changed: ${state.name}');
    }

    // TRIGGER 3: Flush quando app va in background
    //
    // Esegue flush della batch queue in 2 scenari:
    // 1. paused: App completamente in background (lockscreen, home button)
    // 2. inactive: App sta perdendo focus (notifica, control center)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final batchWriter = ref.read(firestoreBatchWriterProvider.notifier);

      if (kDebugMode) {
        debugPrint(
          '📱 [AppLifecycle] App going to background (${state.name}), '
          'flushing batch queue',
        );
      }

      // Fire-and-forget flush
      // Non possiamo await in didChangeAppLifecycleState
      batchWriter.forceFlush().catchError((error) {
        if (kDebugMode) {
          debugPrint('❌ [AppLifecycle] Flush on background failed: $error');
        }
      });

      // 💾 FIX: Emergency save current workout (GLOBAL)
      // This ensures workout is saved regardless of which screen is visible
      _emergencySaveCurrentWorkout();
    }

    // 💾 Save template cache only on paused (actual background, not transient inactive)
    // - avoids double-call (inactive fires before paused every time)
    // - avoids calling before cache is initialized (first inactive often too early)
    if (state == AppLifecycleState.paused) {
      _saveTemplateCacheOnBackground();
    }

    // TRIGGER 4: Schedule "workout forgotten" notification when going to background
    // Only on paused (actual background), not inactive (control center, notifications)
    if (state == AppLifecycleState.paused) {
      _scheduleWorkoutForgottenIfNeeded();
    }

    // App torna in foreground
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        debugPrint('📱 [AppLifecycle] App resumed to foreground');
      }
      // Cancel workout forgotten notification when returning to app
      _cancelWorkoutForgottenNotification();

      // 📱 FIX: Check for pending Live Activity events on iOS
      // When app is suspended, Darwin notifications from LA button taps
      // (like +30s) may not be delivered. Check UserDefaults for missed events.
      if (Platform.isIOS) {
        _checkPendingLiveActivityEvents();

        // ⌚ FIX: Check for pending Watch commands on iOS
        // When app is suspended and Watch sends endWorkout, the message may be lost.
        // Check UserDefaults for pending commands and process them.
        _checkPendingWatchCommands();
      }
    }

    // App sta terminando (detached)
    if (state == AppLifecycleState.detached) {
      if (kDebugMode) {
        debugPrint('📱 [AppLifecycle] App detaching, performing final cleanup');
      }
      // FIX: Emergency save on detached — iOS may kill without passing through paused
      _emergencySaveCurrentWorkout();
    }
  }

  /// Schedule workout forgotten notification if there's an active workout
  void _scheduleWorkoutForgottenIfNeeded() {
    // Check if notifications are initialized
    final isInitialized = ref.read(notificationInitializedProvider);
    if (!isInitialized) {
      if (kDebugMode) {
        debugPrint('📱 [AppLifecycle] Notifications not initialized, skipping');
      }
      return;
    }

    // Check if there's an active workout
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) {
      if (kDebugMode) {
        debugPrint('📱 [AppLifecycle] No active workout, skipping notification');
      }
      return;
    }

    // Get l10n without context using provider
    final l10n = ref.read(appLocalizationsProvider);

    // Schedule the notification
    final scheduler = ref.read(notificationSchedulerProvider);
    scheduler.scheduleWorkoutForgotten(l10n).catchError((error) {
      if (kDebugMode) {
        debugPrint('❌ [AppLifecycle] Failed to schedule workout forgotten: $error');
      }
    });

    if (kDebugMode) {
      debugPrint('📱 [AppLifecycle] Scheduled workout forgotten notification');
    }
  }

  /// Cancel workout forgotten notification when returning to app
  void _cancelWorkoutForgottenNotification() {
    // Check if notifications are initialized
    final isInitialized = ref.read(notificationInitializedProvider);
    if (!isInitialized) return;

    final scheduler = ref.read(notificationSchedulerProvider);
    scheduler.cancelWorkoutForgotten().catchError((error) {
      if (kDebugMode) {
        debugPrint('❌ [AppLifecycle] Failed to cancel workout forgotten: $error');
      }
    });

    if (kDebugMode) {
      debugPrint('📱 [AppLifecycle] Canceled workout forgotten notification');
    }
  }

  /// 📱 FIX: Check for pending Live Activity events on app resume
  ///
  /// When the app is suspended (screen locked), Darwin notifications from Live Activity
  /// button taps (like +30s) may not wake the app. This method checks UserDefaults
  /// for any pending events and processes them.
  ///
  /// This fixes the bug where pressing +30s on the Live Activity while the phone
  /// is locked doesn't update the Flutter timer.
  void _checkPendingLiveActivityEvents() {
    // Only check if there's an active workout
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) {
      if (kDebugMode) {
        debugPrint('📱 [AppLifecycle] No active workout, skipping LA event check');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('📱 [AppLifecycle] Checking for pending Live Activity events...');
    }

    // Fire-and-forget - the check will trigger event handling through the normal flow
    ref.read(workoutSessionLAProvider.notifier).checkPendingEventsOnResume().catchError((error) {
      if (kDebugMode) {
        debugPrint('❌ [AppLifecycle] Failed to check pending LA events: $error');
      }
    });
  }

  /// ⌚ FIX: Check for pending Watch commands on app resume
  ///
  /// When the app is suspended (in background) and Watch sends critical commands like
  /// endWorkout, the Flutter engine may not receive them. The native iOS side saves
  /// these commands to UserDefaults, and this method processes them on resume.
  ///
  /// This fixes the bug where ending workout from Watch while iPhone is in background
  /// causes the workout data to be lost.
  void _checkPendingWatchCommands() {
    if (kDebugMode) {
      debugPrint('⌚ [AppLifecycle] Checking for pending Watch commands...');
    }

    // Fire-and-forget - the check will trigger event handling through callbacks
    ref.read(watchConnectivityProvider.notifier).processPendingWatchCommands().then((processed) {
      if (processed && kDebugMode) {
        debugPrint('⌚ [AppLifecycle] ✅ Processed pending Watch commands');
      }
    }).catchError((error) {
      if (kDebugMode) {
        debugPrint('❌ [AppLifecycle] Failed to check pending Watch commands: $error');
      }
    });
  }

  /// 💾 FIX: Emergency save current workout when app goes to background (GLOBAL)
  ///
  /// This method is called from AppLifecycleManager (not WorkoutScreen) to ensure
  /// the workout is saved regardless of which screen is currently visible.
  /// Previously, emergency save only happened if WorkoutScreen was mounted.
  ///
  /// FIX #3: Now uses iOS background task to ensure save completes before termination.
  void _emergencySaveCurrentWorkout() {
    // Read current workout - with keepAlive() fix, provider should never be disposed unexpectedly
    final currentWorkout = ref.read(currentWorkoutProvider);

    if (currentWorkout == null) {
      if (kDebugMode) {
        // NOTE: If this logs frequently when there WAS an active workout,
        // it means the provider was disposed (check ref.keepAlive() in workout_provider.dart)
        debugPrint('💾 [AppLifecycle] No active workout to save (provider returned null)');
      }
      return;
    }

    // Only save if workout is active (in progress or paused)
    // BUG FIX: isActive only checks for inProgress, but we also need to save paused workouts!
    final isActiveOrPaused = currentWorkout.status == WorkoutStatus.inProgress ||
        currentWorkout.status == WorkoutStatus.paused;
    if (!isActiveOrPaused) {
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Workout not active/paused (status: ${currentWorkout.status}), skipping save');
      }
      return;
    }

    // FIX #3: Request iOS background task to extend time for save
    // iOS gives apps ~5 seconds by default, background task extends this to ~30 seconds
    if (Platform.isIOS) {
      _requestIOSBackgroundTaskForSave(currentWorkout);
    } else {
      _performEmergencySave(currentWorkout);
    }
  }

  /// FIX #3: Request iOS background task and perform save
  void _requestIOSBackgroundTaskForSave(Workout workout) {
    const channel = MethodChannel(PlatformChannels.unified);

    // Request background task from iOS
    channel.invokeMethod('beginBackgroundTask', {
      'name': 'emergency_workout_save',
    }).then((taskId) {
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] iOS background task started: $taskId');
      }

      // Perform the save
      _performEmergencySave(workout).then((_) {
        // End background task after save completes
        channel.invokeMethod('endBackgroundTask', {'taskId': taskId}).catchError((e) {
          if (kDebugMode) {
            debugPrint('⚠️ [AppLifecycle] Failed to end background task: $e');
          }
        });
      });
    }).catchError((error) {
      // If background task request fails, still try to save
      if (kDebugMode) {
        debugPrint('⚠️ [AppLifecycle] Background task request failed: $error, saving anyway');
      }
      _performEmergencySave(workout);
    });
  }

  /// Perform the actual emergency save
  Future<void> _performEmergencySave(Workout workout) async {
    try {
      final autoSave = ref.read(workoutAutoSaveProvider.notifier);
      await autoSave.emergencySave(workout);

      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Emergency saved active workout: ${workout.name}');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('❌ [AppLifecycle] Emergency save failed: $error');
      }
    }
  }

  /// 💾 Save template cache when app goes to background (centralized)
  ///
  /// Moved from WorkoutScreen to centralize lifecycle handling.
  /// This ensures template cache is saved regardless of current screen.
  void _saveTemplateCacheOnBackground() {
    try {
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      cacheService.forceSave();

      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Force saved template cache');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AppLifecycle] Template cache save failed: $e');
      }
    }
  }

  /// 💾 FIX: Check for and recover workout draft on app startup (GLOBAL)
  ///
  /// This is the CRITICAL fix for the workout loss bug. Previously, draft recovery
  /// only happened when the user navigated to WorkoutScreen. Now it happens
  /// globally on app startup, regardless of which screen opens first.
  ///
  /// Flow:
  /// 1. App starts → AppLifecycleManager.initState
  /// 2. Check if there's a recoverable draft (has completed sets, not stale)
  /// 3. If yes, show recovery dialog
  /// 4. If user accepts, restore workout and navigate to WorkoutScreen
  Future<void> _checkAndRecoverDraftGlobally() async {
    // Only check once per session
    if (_hasCheckedDraftRecovery) return;
    _hasCheckedDraftRecovery = true;

    if (!mounted) return;

    // Skip if there's already an active workout
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout != null) {
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Active workout exists, skipping draft recovery');
      }
      return;
    }

    // Check if there's a recoverable draft
    final autoSave = ref.read(workoutAutoSaveProvider.notifier);
    final hasDraft = await autoSave.hasRecoverableDraft();

    if (!hasDraft) {
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] No recoverable draft found');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('💾 [AppLifecycle] Found recoverable draft! Waiting for Navigator...');
    }

    // 📸 Try to get Watch snapshot for merge (runs in parallel with navigator wait)
    // The Watch may have more recent data than the Hive draft (up to 30s stale)
    Workout? draftWorkout;
    try {
      draftWorkout = await autoSave.recoverDraft();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Failed to load draft for merge: $e');
      }
    }

    if (draftWorkout != null && Platform.isIOS) {
      draftWorkout = await _requestAndMergeWatchSnapshot(draftWorkout);
    }

    // Get localization
    final l10n = ref.read(appLocalizationsProvider);

    // CRITICAL FIX: Wait for Navigator to be ready before showing dialog.
    // AppLifecycleManager wraps MaterialApp, so Navigator doesn't exist until
    // MaterialApp is fully mounted. We use a retry loop with postFrameCallback.
    await _showRecoveryDialogWhenReady(l10n, autoSave, mergedDraft: draftWorkout);
  }

  /// Helper: Wait for Navigator to be ready, then show recovery dialog.
  /// Uses retry loop with postFrameCallback to handle the case where
  /// Navigator isn't available immediately at app startup.
  ///
  /// CRITICAL FIX: Uses AppRoutes.rootNavigatorKey instead of Navigator.maybeOf(context).
  /// AppLifecycleManager wraps MaterialApp, so its context is ABOVE the Navigator.
  /// We need to use the global navigator key that go_router creates INSIDE MaterialApp.
  Future<void> _showRecoveryDialogWhenReady(
    AppLocalizations l10n,
    dynamic autoSave, {
    int retryCount = 0,
    Workout? mergedDraft,
  }) async {
    // Total wait: up to ~5s with exponential backoff (50ms → 100ms → 200ms → 400ms → 800ms → 800ms*N)
    const maxRetries = 20;
    const maxDelayMs = 800;

    if (!mounted) return;

    // CRITICAL FIX: Use rootNavigatorKey instead of Navigator.maybeOf(context)
    // AppLifecycleManager wraps MaterialApp, so context is ABOVE Navigator.
    // rootNavigatorKey is passed to GoRouter and has valid state once router is mounted.
    final navigatorState = AppRoutes.rootNavigatorKey.currentState;
    final navigatorContext = AppRoutes.rootNavigatorKey.currentContext;

    if (navigatorState == null || navigatorContext == null) {
      // Navigator not ready yet
      if (retryCount >= maxRetries) {
        if (kDebugMode) {
          debugPrint('💾 [AppLifecycle] Navigator not available after $maxRetries retries (~5s), giving up');
        }
        return;
      }

      // Exponential backoff: 50ms → 100ms → 200ms → 400ms → 800ms (capped)
      final delayMs = (50 * (1 << retryCount.clamp(0, 4))).clamp(50, maxDelayMs);
      await Future<void>.delayed(Duration(milliseconds: delayMs));
      if (mounted) {
        _showRecoveryDialogWhenReady(l10n, autoSave, retryCount: retryCount + 1, mergedDraft: mergedDraft);
      }
      return;
    }

    // Navigator is ready, show dialog
    if (kDebugMode) {
      debugPrint('💾 [AppLifecycle] Navigator ready (via rootNavigatorKey), showing recovery dialog');
    }

    try {
      // Use the context from rootNavigatorKey, not AppLifecycleManager's context
      final choice = await _showRecoveryDialog(navigatorContext, l10n);
      // Re-check contexts are still valid after async gap
      if (mounted && navigatorContext.mounted) {
        await _handleRecoveryChoice(choice, autoSave, l10n, navigatorContext, mergedDraft: mergedDraft);
      }
    } catch (e, stack) {
      // Catch any remaining Navigator errors (e.g., context became invalid)
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Error showing recovery dialog: $e');
        debugPrint('$stack');
      }
    }
  }

  /// Show recovery dialog with 3 buttons: Discard / Not now / Resume
  Future<_RecoveryChoice?> _showRecoveryDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    return showDialog<_RecoveryChoice>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.recoverWorkout),
        content: Text(l10n.recoverWorkoutMessage),
        actions: [
          // "Scarta" — red, actually deletes draft
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_RecoveryChoice.discard),
            child: Text(
              l10n.discard,
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
          // "Non ora" — neutral, keeps draft in Hive
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_RecoveryChoice.notNow),
            child: Text(l10n.recoveryNotNow),
          ),
          // "Riprendi" — primary, restores workout
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(_RecoveryChoice.resume),
            child: Text(l10n.recover),
          ),
        ],
      ),
    );
  }

  /// Handle recovery choice (resume, not now, or discard)
  ///
  /// CRITICAL FIX: Uses navigatorContext from rootNavigatorKey for navigation,
  /// not AppLifecycleManager's context (which is above MaterialApp).
  Future<void> _handleRecoveryChoice(
    _RecoveryChoice? choice,
    dynamic autoSave,
    AppLocalizations l10n,
    BuildContext navigatorContext, {
    Workout? mergedDraft,
  }) async {
    switch (choice) {
      case _RecoveryChoice.resume:
        // Use pre-loaded merged draft if available, otherwise recover from storage
        final recoveredWorkout = mergedDraft ?? await autoSave.recoverDraft();
        // Check both widget mounted and navigator context still valid after async gap
        if (recoveredWorkout != null && mounted && navigatorContext.mounted) {
          ref.read(currentWorkoutProvider.notifier).restoreFromDraft(recoveredWorkout);

          if (kDebugMode) {
            debugPrint('💾 [AppLifecycle] Draft recovered successfully!');
          }

          SnackBarService.showSuccess(
            navigatorContext,
            l10n.workoutRecovered,
          );

          navigatorContext.go('/workout');
        }

      case _RecoveryChoice.notNow:
        // Draft stays in Hive — user can resume later from Quick Actions "+"
        if (kDebugMode) {
          debugPrint('💾 [AppLifecycle] Draft kept for later (Not now)');
        }

      case _RecoveryChoice.discard:
        await autoSave.discardDraft();
        if (kDebugMode) {
          debugPrint('💾 [AppLifecycle] Draft discarded by user');
        }

      case null:
        // Dialog dismissed without choice — treat as "not now"
        break;
    }
  }

  /// 📸 Request a full workout snapshot from Watch and merge with draft.
  ///
  /// Uses a 2-message pattern (request → separate response) because the Watch
  /// discards the replyHandler. Waits up to 3 seconds for the Watch response.
  /// If Watch is unreachable or times out, returns the draft unchanged.
  Future<Workout> _requestAndMergeWatchSnapshot(Workout draft) async {
    try {
      final watchNotifier = ref.read(watchConnectivityProvider.notifier);

      // Setup Completer to receive async snapshot
      final completer = Completer<Map<String, dynamic>?>();
      Timer? timeoutTimer;

      // Register one-shot callback
      final previousCallback = watchNotifier.onFullWorkoutSnapshotFromWatch;
      watchNotifier.onFullWorkoutSnapshotFromWatch = (snapshot) {
        timeoutTimer?.cancel();
        watchNotifier.onFullWorkoutSnapshotFromWatch = previousCallback;
        if (!completer.isCompleted) {
          completer.complete(snapshot);
        }
      };

      // Send request to Watch
      final sent = await watchNotifier.requestWatchWorkoutSnapshot();
      if (!sent) {
        // Watch not reachable, restore callback and return draft as-is
        watchNotifier.onFullWorkoutSnapshotFromWatch = previousCallback;
        if (kDebugMode) {
          debugPrint('📸 [AppLifecycle] Watch not reachable, using draft as-is');
        }
        return draft;
      }

      // Start timeout
      timeoutTimer = Timer(const Duration(seconds: 3), () {
        watchNotifier.onFullWorkoutSnapshotFromWatch = previousCallback;
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      final snapshot = await completer.future;

      if (snapshot == null || snapshot['hasActiveWorkout'] != true) {
        if (kDebugMode) {
          debugPrint('📸 [AppLifecycle] No active Watch workout, using draft as-is');
        }
        return draft;
      }

      if (kDebugMode) {
        debugPrint('📸 [AppLifecycle] Got Watch snapshot, merging with draft...');
      }

      return _mergeWatchSnapshotIntoDraft(snapshot, draft);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📸 [AppLifecycle] Watch snapshot error: $e, using draft as-is');
      }
      return draft;
    }
  }

  /// Merge Watch workout snapshot into Hive draft.
  ///
  /// The Watch knows which sets are completed (via its allSetsTargets).
  /// The draft has the full Workout model. We update the draft's sets
  /// based on Watch data for the current exercise.
  Workout _mergeWatchSnapshotIntoDraft(
    Map<String, dynamic> snapshot,
    Workout draft,
  ) {
    try {
      final exerciseIndex = snapshot['currentExerciseIndex'] as int? ?? 0;
      final exerciseName = snapshot['currentExerciseName'] as String?;
      final watchSets = snapshot['allSetsTargets'] as List<dynamic>?;

      if (watchSets == null || watchSets.isEmpty) {
        if (kDebugMode) {
          debugPrint('📸 [Merge] No Watch sets data, returning draft');
        }
        return draft;
      }

      // Validate exercise index is within bounds
      if (exerciseIndex < 0 || exerciseIndex >= draft.exercises.length) {
        if (kDebugMode) {
          debugPrint('📸 [Merge] Exercise index $exerciseIndex out of bounds (${draft.exercises.length}), skipping');
        }
        return draft;
      }

      final draftExercise = draft.exercises[exerciseIndex];

      // Cross-check exercise name if available
      if (exerciseName != null && draftExercise.name != exerciseName) {
        if (kDebugMode) {
          debugPrint('📸 [Merge] Exercise name mismatch: Watch="$exerciseName" vs Draft="${draftExercise.name}", skipping');
        }
        return draft;
      }

      // Merge sets: for each Watch set marked as completed, update draft
      final updatedSets = List<ExerciseSet>.from(draftExercise.sets);
      var mergeCount = 0;

      for (var i = 0; i < watchSets.length && i < updatedSets.length; i++) {
        final watchSet = watchSets[i] as Map<dynamic, dynamic>?;
        if (watchSet == null) continue;

        final watchCompleted = watchSet['isCompleted'] as bool? ?? false;
        if (watchCompleted && !updatedSets[i].isCompleted) {
          // Watch says completed but draft says not — update from Watch
          final actualReps = (watchSet['actualReps'] as num?)?.toInt();
          updatedSets[i] = updatedSets[i].copyWith(
            isCompleted: true,
            actualReps: actualReps ?? updatedSets[i].reps,
          );
          mergeCount++;
        }
      }

      if (mergeCount == 0) {
        if (kDebugMode) {
          debugPrint('📸 [Merge] No new completions from Watch, draft is up-to-date');
        }
        return draft;
      }

      // Build updated exercise
      final updatedExercise = draftExercise.copyWith(sets: updatedSets);

      // Build updated exercises list
      final updatedExercises = List<Exercise>.from(draft.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;

      if (kDebugMode) {
        debugPrint('📸 [Merge] Merged $mergeCount set completions from Watch for "${draftExercise.name}"');
      }

      return draft.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📸 [Merge] Error during merge: $e, returning draft');
      }
      return draft;
    }
  }

  /// 🔄 FIX: Sync workouts from Firestore to local Hive on app startup
  ///
  /// This fixes the AI Coach "0 0 0" bug where progress providers read from
  /// an empty local Hive box. Without this sync, only NEW workouts after the
  /// Hive migration would appear in progress stats.
  ///
  /// The sync runs in background and doesn't block app startup.
  /// After sync completes, it invalidates progress providers to refresh the UI.
  Future<void> _syncWorkoutsFromCloudOnStartup() async {
    try {
      // Check if user is authenticated
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('🔄 [AppLifecycle] No user logged in, skipping cloud sync');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('🔄 [AppLifecycle] Starting background cloud sync for user: ${currentUser.email}');
      }

      // Trigger cloud sync in background (non-blocking)
      final cloudSync = ref.read(cloudSyncProvider.notifier);
      await cloudSync.syncFromCloud();

      final state = ref.read(cloudSyncProvider);
      if (kDebugMode) {
        if (state.lastSyncSummary != null) {
          debugPrint('🔄 [AppLifecycle] Cloud sync complete: ${state.lastSyncSummary!.workoutsSynced} workouts synced');
        }
      }

      // ✅ FIX: Invalidate progress providers AFTER sync completes
      // This forces the AI Coach card and other UI to re-read from updated Hive data
      if (state.lastSyncSummary != null && state.lastSyncSummary!.workoutsSynced > 0) {
        if (kDebugMode) {
          debugPrint('🔄 [AppLifecycle] Invalidating progress providers to refresh UI...');
        }

        // Import progress providers and invalidate them
        // This triggers a rebuild of the AI Coach card with fresh data
        ref.invalidate(completedWorkoutsCountProvider);
        ref.invalidate(currentStreakProvider);
        ref.invalidate(weeklyFrequencyProvider);

        if (kDebugMode) {
          debugPrint('✅ [AppLifecycle] Progress providers invalidated - UI will refresh');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AppLifecycle] Cloud sync failed: $e');
      }
      // Non-critical error - don't crash app
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔄 FIX: Listen to auth state changes and trigger cloud sync when user is available
    // This fixes the timing issue where currentUser was null during initState
    // because Firebase Auth hadn't initialized yet.
    ref.listen<AsyncValue<User?>>(firebaseUserProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && !_hasTriggeredCloudSync) {
          _hasTriggeredCloudSync = true;
          if (kDebugMode) {
            debugPrint('🔄 [AppLifecycle] Auth ready - triggering cloud sync for: ${user.email}');
          }
          // Trigger sync now that we know user is authenticated
          _syncWorkoutsFromCloudOnStartup();
        }
      });
    });

    // Passa attraverso il child senza modifiche
    return widget.child;
  }
}

/// Recovery dialog user choice
enum _RecoveryChoice { resume, notNow, discard }
