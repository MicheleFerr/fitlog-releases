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
/// - AppLifecycleState.paused: App in background (flush batch)
/// - AppLifecycleState.inactive: App sta perdendo focus (pre-flush)
/// - AppLifecycleState.resumed: App torna in foreground (nessuna azione)
/// - AppLifecycleState.detached: App sta terminando (cleanup finale)
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';

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

    // App torna in foreground
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        debugPrint('📱 [AppLifecycle] App resumed to foreground');
      }
      // Nessuna azione necessaria per resumed
      // Il batch writer riprenderà normalmente
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

  @override
  Widget build(BuildContext context) {
    // Passa attraverso il child senza modifiche
    return widget.child;
  }
}
