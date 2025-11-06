/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: shared
/// 🔧 Type: widget helper
///
/// Helper per mostrare feedback UI durante il salvataggio workout con sync cloud.
/// Usa SnackBarService centralizzato per consistenza UX.
///
/// **STATI SUPPORTATI**:
/// - Saving: "Salvataggio allenamento..." (info)
/// - Saved Locally: "Allenamento salvato localmente" (success)
/// - Syncing: "Sincronizzazione cloud..." (info)
/// - Sync Complete: "Sincronizzazione completata" (success)
/// - Sync Queued: "In coda per sincronizzazione" (warning)
/// - Save Failed: "Salvataggio fallito" (error)
/// - Retrying: "Nuovo tentativo di sincronizzazione..." (warning)
/// - Local Save Failed: "Salvataggio locale fallito" (error)
///
/// **ESEMPIO UTILIZZO**:
/// ```dart
/// // In workout_provider dopo local save
/// SyncStatusToast.showWorkoutSavedLocally(context);
///
/// // Durante cloud sync
/// SyncStatusToast.showSyncingToCloud(context);
///
/// // Al completamento
/// SyncStatusToast.showCloudSyncComplete(context);
///
/// // In caso di errore
/// SyncStatusToast.showLocalSaveFailed(
///   context,
///   onRetry: () => retryLocalSave(),
///   onExport: () => exportWorkoutData(),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Helper per feedback UI durante workout save flow
class SyncStatusToast {
  /// Mostra "Salvataggio allenamento..." (fase iniziale)
  ///
  /// Usare quando si inizia il processo di salvataggio.
  /// Tipo: Info (blu) - operazione in corso
  static void showSavingWorkout(BuildContext context) {
    SnackBarService.showInfo(
      context,
      context.l10n.savingWorkout,
      duration: const Duration(seconds: 2),
    );
  }

  /// Mostra "Allenamento salvato!" (successo generico)
  ///
  /// Usare quando workout è salvato con successo (local + cloud).
  /// Tipo: Success (verde)
  static void showWorkoutSaved(BuildContext context) {
    SnackBarService.showSuccess(
      context,
      context.l10n.workoutSaved,
      duration: const Duration(seconds: 3),
    );
  }

  /// Mostra "Sincronizzazione cloud..." (sync in corso)
  ///
  /// Usare quando il batch writer sta sincronizzando con cloud.
  /// Tipo: Info (blu) - operazione in corso
  static void showSyncingToCloud(BuildContext context) {
    SnackBarService.showInfo(
      context,
      context.l10n.syncingToCloud,
      duration: const Duration(seconds: 2),
    );
  }

  /// Mostra "Allenamento salvato localmente" (local save success)
  ///
  /// Usare quando local save (Hive) ha successo ma cloud sync ancora pending.
  /// Tipo: Success (verde) - dati al sicuro localmente
  static void showWorkoutSavedLocally(BuildContext context) {
    SnackBarService.showSuccess(
      context,
      context.l10n.workoutSavedLocally,
      duration: const Duration(seconds: 3),
    );
  }

  /// Mostra "Sincronizzazione completata" (cloud sync success)
  ///
  /// Usare quando batch writer ha completato sync con Firestore.
  /// Tipo: Success (verde)
  static void showCloudSyncComplete(BuildContext context) {
    SnackBarService.showSuccess(
      context,
      context.l10n.cloudSyncComplete,
      duration: const Duration(seconds: 2),
    );
  }

  /// Mostra "In coda per sincronizzazione" (queued for batch)
  ///
  /// Usare quando operazione è accodata nel batch writer (non immediata).
  /// Tipo: Warning (arancione) - sync differito
  static void showCloudSyncQueued(BuildContext context) {
    SnackBarService.showWarning(
      context,
      context.l10n.cloudSyncQueued,
      duration: const Duration(seconds: 3),
    );
  }

  /// Mostra "Salvataggio fallito" (errore generico)
  ///
  /// Usare per errori generici di save (non critici).
  /// Tipo: Error (rosso)
  static void showSaveFailed(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    SnackBarService.showError(
      context,
      context.l10n.saveFailed,
      duration: const Duration(seconds: 5),
      actionLabel: onRetry != null ? 'RETRY' : null,
      onAction: onRetry,
    );
  }

  /// Mostra "Nuovo tentativo di sincronizzazione..." (retry in corso)
  ///
  /// Usare quando RetryQueueService sta ritentando sync fallito.
  /// Tipo: Warning (arancione) - retry automatico
  static void showRetryingSync(BuildContext context) {
    SnackBarService.showWarning(
      context,
      context.l10n.retryingSync,
      duration: const Duration(seconds: 3),
    );
  }

  /// Mostra "Salvataggio locale fallito" (CRITICO)
  ///
  /// Usare quando local save (Hive) fallisce - situazione critica!
  /// Tipo: Error (rosso) con azioni obbligatorie
  ///
  /// **IMPORTANTE**: Local save failure significa dati persi se non si risolve.
  /// SEMPRE fornire onRetry e onExport per dare opzioni all'utente.
  static void showLocalSaveFailed(
    BuildContext context, {
    required VoidCallback onRetry,
    required VoidCallback onExport,
  }) {
    // 1. Show immediate error toast with RETRY action
    SnackBarService.showError(
      context,
      '${context.l10n.localSaveFailed}\n${context.l10n.retryOrExport}',
      duration: const Duration(seconds: 8), // Durata lunga per azione critica
      actionLabel: 'RETRY',
      onAction: onRetry,
    );

    // 2. Show modal dialog with RETRY and EXPORT actions
    // Dialog provides more prominent UI for critical error with export option
    ModalService.showActionDialog(
      context,
      title: context.l10n.localSaveFailed,
      message: context.l10n.retryOrExport,
      icon: AppIcons.error,
      actions: [
        DialogAction(
          label: 'RETRY',
          onPressed: onRetry,
          isPrimary: true,
        ),
        DialogAction(
          label: 'EXPORT',
          onPressed: onExport,
          isDangerous: true,
        ),
      ],
      barrierDismissible: false, // Force user to choose action
    );
  }

  /// Chiudi tutti i toast di sync attivi
  ///
  /// Utile per cleanup quando si naviga via dalla schermata workout.
  static void dismissAll(BuildContext context) {
    SnackBarService.dismiss(context);
  }
}

/// Mixin per aggiungere metodi helper di sync toast ai widget
///
/// Esempio:
/// ```dart
/// class WorkoutScreen extends ConsumerWidget with SyncStatusToastMixin {
///   Future<void> saveWorkout() async {
///     showSavingWorkout(context);
///     // ... save logic
///     showWorkoutSavedLocally(context);
///   }
/// }
/// ```
mixin SyncStatusToastMixin {
  void showSavingWorkout(BuildContext context) {
    SyncStatusToast.showSavingWorkout(context);
  }

  void showWorkoutSaved(BuildContext context) {
    SyncStatusToast.showWorkoutSaved(context);
  }

  void showSyncingToCloud(BuildContext context) {
    SyncStatusToast.showSyncingToCloud(context);
  }

  void showWorkoutSavedLocally(BuildContext context) {
    SyncStatusToast.showWorkoutSavedLocally(context);
  }

  void showCloudSyncComplete(BuildContext context) {
    SyncStatusToast.showCloudSyncComplete(context);
  }

  void showCloudSyncQueued(BuildContext context) {
    SyncStatusToast.showCloudSyncQueued(context);
  }

  void showSaveFailed(BuildContext context, {VoidCallback? onRetry}) {
    SyncStatusToast.showSaveFailed(context, onRetry: onRetry);
  }

  void showRetryingSync(BuildContext context) {
    SyncStatusToast.showRetryingSync(context);
  }

  void showLocalSaveFailed(
    BuildContext context, {
    required VoidCallback onRetry,
    required VoidCallback onExport,
  }) {
    SyncStatusToast.showLocalSaveFailed(
      context,
      onRetry: onRetry,
      onExport: onExport,
    );
  }

  void dismissAllSyncToasts(BuildContext context) {
    SyncStatusToast.dismissAll(context);
  }
}
