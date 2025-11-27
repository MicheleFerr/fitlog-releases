/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/migration/presentation/providers
/// 🎯 Feature: Data Migration State Management
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Provider per gestire lo stato della migrazione dati
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/migration/data_migration_script.dart';

/// Stati possibili della migrazione
enum MigrationStatus {
  initial,
  analyzing,
  analyzed,
  migrating,
  completed,
  error,
}

/// Stato della migrazione
class MigrationState {

  const MigrationState({
    this.status = MigrationStatus.initial,
    this.result,
    this.currentMessage,
    this.progress = 0.0,
    this.hasDataToMigrate = false,
    this.options = const MigrationOptions(),
  });
  final MigrationStatus status;
  final MigrationResult? result;
  final String? currentMessage;
  final double progress;
  final bool hasDataToMigrate;
  final MigrationOptions options;

  MigrationState copyWith({
    MigrationStatus? status,
    MigrationResult? result,
    String? currentMessage,
    double? progress,
    bool? hasDataToMigrate,
    MigrationOptions? options,
  }) {
    return MigrationState(
      status: status ?? this.status,
      result: result ?? this.result,
      currentMessage: currentMessage ?? this.currentMessage,
      progress: progress ?? this.progress,
      hasDataToMigrate: hasDataToMigrate ?? this.hasDataToMigrate,
      options: options ?? this.options,
    );
  }

  bool get isLoading => status == MigrationStatus.analyzing || status == MigrationStatus.migrating;
  bool get canExecute => status == MigrationStatus.analyzed && hasDataToMigrate;
  bool get isCompleted => status == MigrationStatus.completed;
  bool get hasError => status == MigrationStatus.error;
}

/// Provider per il servizio di migrazione
final migrationServiceProvider = Provider<WorkoutMigrationService>((ref) {
  return WorkoutMigrationService();
});

/// Notifier per gestire lo stato della migrazione
class MigrationNotifier extends Notifier<MigrationState> {

  late final WorkoutMigrationService _service;

  @override
  MigrationState build() {
    _service = ref.watch(migrationServiceProvider);
    _checkIfHasDataToMigrate();
    return const MigrationState();
  }

  /// Verifica se ci sono dati da migrare
  Future<void> _checkIfHasDataToMigrate() async {
    try {
      final hasData = await _service.hasDataToMigrate();
      state = state.copyWith(hasDataToMigrate: hasData);
    } catch (e) {
      debugPrint('Errore verifica dati da migrare: $e');
    }
  }

  /// Aggiorna le opzioni di migrazione
  void updateOptions(MigrationOptions options) {
    state = state.copyWith(options: options);
  }

  /// Esegue l'anteprima della migrazione
  Future<void> previewMigration() async {
    if (state.isLoading) return;

    state = state.copyWith(
      status: MigrationStatus.analyzing,
      progress: 0.0,
      currentMessage: null,
    );

    try {
      final result = await _service.previewMigration(
        options: state.options,
        onProgress: _updateProgress,
      );

      state = state.copyWith(
        status: result.success ? MigrationStatus.analyzed : MigrationStatus.error,
        result: result,
        progress: 1.0,
        currentMessage: result.success
            ? 'Analisi completata: ${result.totalWorkouts} allenamenti trovati'
            : 'Errore durante l\'analisi',
      );
    } catch (e) {
      state = state.copyWith(
        status: MigrationStatus.error,
        currentMessage: 'Errore: $e',
        progress: 0.0,
      );
    }
  }

  /// Esegue la migrazione effettiva
  Future<void> executeMigration() async {
    if (state.isLoading || !state.canExecute) return;

    state = state.copyWith(
      status: MigrationStatus.migrating,
      progress: 0.0,
      currentMessage: null,
    );

    try {
      final options = state.options.copyWith(dryRun: false);

      final result = await _service.executeMigration(
        options: options,
        onProgress: _updateProgress,
      );

      state = state.copyWith(
        status: result.success ? MigrationStatus.completed : MigrationStatus.error,
        result: result,
        progress: 1.0,
        currentMessage: result.success
            ? 'Migrazione completata: ${result.migratedWorkouts} allenamenti migrati'
            : 'Errore durante la migrazione',
      );

      // Se completata con successo, aggiorna il flag hasDataToMigrate
      if (result.success) {
        state = state.copyWith(hasDataToMigrate: false);
      }
    } catch (e) {
      state = state.copyWith(
        status: MigrationStatus.error,
        currentMessage: 'Errore: $e',
        progress: 0.0,
      );
    }
  }

  /// Reset dello stato
  void reset() {
    state = state.copyWith(
      status: MigrationStatus.initial,
      result: null,
      currentMessage: null,
      progress: 0.0,
    );
    _checkIfHasDataToMigrate();
  }

  /// Callback per aggiornamenti di progresso
  void _updateProgress(String message, double progress) {
    state = state.copyWith(
      currentMessage: message,
      progress: progress,
    );
  }
}

/// Provider per lo stato della migrazione
final migrationProvider = NotifierProvider<MigrationNotifier, MigrationState>(MigrationNotifier.new);

/// Extension per aggiungere copyWith a MigrationOptions
extension MigrationOptionsExt on MigrationOptions {
  MigrationOptions copyWith({
    int? timeWindowHours,
    int? minExercisesPerWorkout,
    bool? createBackup,
    bool? deleteOriginals,
    bool? dryRun,
    int? batchSize,
  }) {
    return MigrationOptions(
      timeWindowHours: timeWindowHours ?? this.timeWindowHours,
      minExercisesPerWorkout: minExercisesPerWorkout ?? this.minExercisesPerWorkout,
      createBackup: createBackup ?? this.createBackup,
      deleteOriginals: deleteOriginals ?? this.deleteOriginals,
      dryRun: dryRun ?? this.dryRun,
      batchSize: batchSize ?? this.batchSize,
    );
  }
}