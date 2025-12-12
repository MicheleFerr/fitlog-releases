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

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
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
import 'package:gymbro_flutter_new/features/home/presentation/providers/ai_coach_provider.dart';

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

      // 💾 Save template cache (moved from WorkoutScreen for centralization)
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
    }

    // App sta terminando (detached)
    if (state == AppLifecycleState.detached) {
      if (kDebugMode) {
        debugPrint('📱 [AppLifecycle] App detaching, performing final cleanup');
      }
      // Final cleanup se necessario
      // Il dispose del provider gestirà il flush finale
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
    const channel = MethodChannel('com.gymbro.timer/unified');

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

    // Get localization
    final l10n = ref.read(appLocalizationsProvider);

    // CRITICAL FIX: Wait for Navigator to be ready before showing dialog.
    // AppLifecycleManager wraps MaterialApp, so Navigator doesn't exist until
    // MaterialApp is fully mounted. We use a retry loop with postFrameCallback.
    await _showRecoveryDialogWhenReady(l10n, autoSave);
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
  }) async {
    const maxRetries = 20; // Max ~1s wait (20 frames at 60fps) - increased for cold starts

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
          debugPrint('💾 [AppLifecycle] Navigator not available after $maxRetries retries, giving up');
          debugPrint('💾 [AppLifecycle] rootNavigatorKey.currentState: $navigatorState');
          debugPrint('💾 [AppLifecycle] rootNavigatorKey.currentContext: $navigatorContext');
        }
        return;
      }

      // Retry on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showRecoveryDialogWhenReady(l10n, autoSave, retryCount: retryCount + 1);
        }
      });
      return;
    }

    // Navigator is ready, show dialog
    if (kDebugMode) {
      debugPrint('💾 [AppLifecycle] Navigator ready (via rootNavigatorKey), showing recovery dialog');
    }

    try {
      // Use the context from rootNavigatorKey, not AppLifecycleManager's context
      final shouldRecover = await _showRecoveryDialog(navigatorContext, l10n);
      // Re-check contexts are still valid after async gap
      if (mounted && navigatorContext.mounted) {
        await _handleRecoveryChoice(shouldRecover, autoSave, l10n, navigatorContext);
      }
    } catch (e, stack) {
      // Catch any remaining Navigator errors (e.g., context became invalid)
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Error showing recovery dialog: $e');
        debugPrint('$stack');
      }
    }
  }

  /// Show recovery dialog helper
  Future<bool?> _showRecoveryDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.recoverWorkout),
        content: Text(l10n.recoverWorkoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.discard),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.recover),
          ),
        ],
      ),
    );
  }

  /// Handle recovery choice (recover or discard draft)
  ///
  /// CRITICAL FIX: Uses navigatorContext from rootNavigatorKey for navigation,
  /// not AppLifecycleManager's context (which is above MaterialApp).
  Future<void> _handleRecoveryChoice(
    bool? shouldRecover,
    dynamic autoSave,
    AppLocalizations l10n,
    BuildContext navigatorContext,
  ) async {
    if (shouldRecover == true) {
      // Recover the draft
      final recoveredWorkout = await autoSave.recoverDraft();
      // Check both widget mounted and navigator context still valid after async gap
      if (recoveredWorkout != null && mounted && navigatorContext.mounted) {
        ref.read(currentWorkoutProvider.notifier).restoreFromDraft(recoveredWorkout);

        if (kDebugMode) {
          debugPrint('💾 [AppLifecycle] Draft recovered successfully!');
        }

        // Show success snackbar using navigator context
        SnackBarService.showSuccess(
          navigatorContext,
          l10n.workoutRecovered,
        );

        // Navigate to workout screen using navigator context
        navigatorContext.go('/workout');
      }
    } else {
      // Discard the draft
      await autoSave.discardDraft();
      if (kDebugMode) {
        debugPrint('💾 [AppLifecycle] Draft discarded by user');
      }
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
        ref.invalidate(aiCoachInsightsProvider);
        ref.invalidate(primaryAIAdviceProvider);

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
