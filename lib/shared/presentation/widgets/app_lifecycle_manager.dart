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

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

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
  @override
  void initState() {
    super.initState();
    // Registra observer per eventi lifecycle
    WidgetsBinding.instance.addObserver(this);

    if (kDebugMode) {
      debugPrint('📱 [AppLifecycle] Manager initialized');
    }
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

  @override
  Widget build(BuildContext context) {
    // Passa attraverso il child senza modifiche
    return widget.child;
  }
}
