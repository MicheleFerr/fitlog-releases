/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: provider
///
/// Provider per gestire dialog aggiornamenti database esercizi
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hybrid_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_update_dialog.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart' show isAdminCachedProvider;
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// Stato del dialog di aggiornamento
class ExerciseUpdateState {

  const ExerciseUpdateState({
    this.isChecking = false,
    this.hasUpdate = false,
    this.isDownloading = false,
    this.dialogShown = false,
    this.error,
  });
  final bool isChecking;
  final bool hasUpdate;
  final bool isDownloading;
  final bool dialogShown;
  final String? error;

  ExerciseUpdateState copyWith({
    bool? isChecking,
    bool? hasUpdate,
    bool? isDownloading,
    bool? dialogShown,
    String? error,
    bool clearError = false,
  }) {
    return ExerciseUpdateState(
      isChecking: isChecking ?? this.isChecking,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      isDownloading: isDownloading ?? this.isDownloading,
      dialogShown: dialogShown ?? this.dialogShown,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Notifier per gestire aggiornamenti esercizi
class ExerciseUpdateNotifier extends StateNotifier<ExerciseUpdateState> {

  ExerciseUpdateNotifier(this._repository, this._ref) : super(const ExerciseUpdateState());
  final HybridExerciseRepository _repository;
  final Ref _ref;
  Timer? _delayTimer;

  /// Controlla aggiornamenti all'avvio app (con delay di 30s)
  void checkForUpdatesOnAppStart(BuildContext context) {
    // Solo per utenti normali, non admin
    final isAdmin = _ref.read(isAdminCachedProvider);
    if (isAdmin) return;

    _delayTimer = Timer(const Duration(seconds: 30), () {
      _checkAndShowUpdateDialog(context);
    });
  }

  /// Controlla aggiornamenti e mostra dialog se necessario
  Future<void> _checkAndShowUpdateDialog(BuildContext context) async {
    if (state.dialogShown) return;

    state = state.copyWith(isChecking: true, clearError: true);

    try {
      final hasUpdates = await _repository.checkAndApplyUpdates();

      if (hasUpdates && context.mounted) {
        state = state.copyWith(
          hasUpdate: true,
          isChecking: false,
        );

        // Mostra dialog
        _showUpdateDialog(context);
      } else {
        state = state.copyWith(
          hasUpdate: false,
          isChecking: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        error: e.toString(),
      );
    }
  }

  /// Mostra il dialog di aggiornamento
  void _showUpdateDialog(BuildContext context) {
    if (state.dialogShown) return;

    state = state.copyWith(dialogShown: true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExerciseUpdateDialog(
        isLoading: state.isDownloading,
        onDownload: () => _downloadUpdate(context),
      ),
    );
  }

  /// Download aggiornamento
  Future<void> _downloadUpdate(BuildContext context) async {
    state = state.copyWith(isDownloading: true, clearError: true);

    try {
      final success = await _repository.forceSyncFromFirebase();

      if (success) {
        state = state.copyWith(
          isDownloading: false,
          hasUpdate: false,
        );

        // Chiudi dialog
        if (context.mounted) {
          Navigator.of(context).pop();

          // Mostra snackbar di successo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Database esercizi aggiornato!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        state = state.copyWith(
          isDownloading: false,
          error: 'Download fallito. Riprova più tardi.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: e.toString(),
      );
    }
  }

  /// Forza controllo aggiornamenti (per admin)
  Future<void> forceCheckUpdates() async {
    state = state.copyWith(isChecking: true, clearError: true);

    try {
      final hasUpdates = await _repository.checkAndApplyUpdates();
      state = state.copyWith(
        hasUpdate: hasUpdates,
        isChecking: false,
      );
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        error: e.toString(),
      );
    }
  }

  /// Cancella delay timer
  void cancelDelayTimer() {
    _delayTimer?.cancel();
    _delayTimer = null;
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }
}

/// Provider per Exercise Update
final exerciseUpdateProvider = StateNotifierProvider<ExerciseUpdateNotifier, ExerciseUpdateState>((ref) {
  final repository = ref.watch(hybridExerciseRepositoryProvider);
  return ExerciseUpdateNotifier(repository, ref);
});

/// Provider per il repository (da definire dove appropriato)
final hybridExerciseRepositoryProvider = Provider<HybridExerciseRepository>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  final locale = ref.watch(localeProvider);
  return HybridExerciseRepository(
    boxManager: boxManager,
    locale: locale,
  );
});