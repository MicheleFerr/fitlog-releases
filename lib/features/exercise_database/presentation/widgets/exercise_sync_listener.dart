/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/widgets
/// 🎯 Feature: exercise_database
/// 🔧 Type: widget
///
/// Widget che ascolta gli eventi di sincronizzazione esercizi e mostra
/// notifiche SnackBar all'utente quando la sync completa (successo o errore).
///
/// **Usage**: Wrap your app or main screen with this widget to receive
/// sync notifications automatically.
///
/// ```dart
/// ExerciseSyncListener(
///   child: YourAppContent(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_sync_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Widget che mostra notifiche quando la sync degli esercizi completa
class ExerciseSyncListener extends ConsumerStatefulWidget {
  const ExerciseSyncListener({
    required this.child,
    this.showOnSuccess = true,
    this.showOnError = true,
    super.key,
  });

  final Widget child;

  /// Se mostrare notifica su sync completata con successo
  final bool showOnSuccess;

  /// Se mostrare notifica su sync fallita
  final bool showOnError;

  @override
  ConsumerState<ExerciseSyncListener> createState() => _ExerciseSyncListenerState();
}

class _ExerciseSyncListenerState extends ConsumerState<ExerciseSyncListener> {
  @override
  Widget build(BuildContext context) {
    // Ascolta gli eventi di sincronizzazione
    ref.listen<AsyncValue<SyncEvent>>(
      exerciseSyncEventsProvider,
      (previous, next) {
        next.whenData((event) {
          _handleSyncEvent(context, event);
        });
      },
    );

    return widget.child;
  }

  void _handleSyncEvent(BuildContext context, SyncEvent event) {
    switch (event.type) {
      case SyncEventType.completed:
        if (widget.showOnSuccess && event.result?.hasUpdates == true) {
          _showSuccessNotification(context, event);
        }
      case SyncEventType.failed:
        if (widget.showOnError) {
          _showErrorNotification(context, event);
        }
      case SyncEventType.started:
        // Non mostriamo notifiche per questo evento
        break;
    }
  }

  void _showSuccessNotification(BuildContext context, SyncEvent event) {
    final exerciseCount = event.result?.exerciseCount;
    final version = event.result?.remoteVersion;

    String message = context.l10n.exerciseDatabaseUpdated;
    if (exerciseCount != null) {
      message = context.l10n.exerciseDatabaseUpdatedWithCount(exerciseCount);
    }

    SnackBarService.showSuccess(
      context,
      message,
      actionLabel: version != null ? 'v$version' : null,
    );
  }

  void _showErrorNotification(BuildContext context, SyncEvent event) {
    SnackBarService.showError(
      context,
      context.l10n.exerciseSyncFailed,
    );
  }
}
