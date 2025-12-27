/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/presentation/providers
/// 🎯 Feature: exercise_merge
/// 🔧 Type: Riverpod providers
///
/// Provider per gestione merge esercizi
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/data/repositories/exercise_merge_repository_impl.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_preview.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/repositories/i_exercise_merge_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/services/exercise_merge_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

// ====================
// REPOSITORY PROVIDER
// ====================

/// Provider per repository merge esercizi
final exerciseMergeRepositoryProvider = Provider<IExerciseMergeRepository>((ref) {
  return ExerciseMergeRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
});

// ====================
// MERGE CANDIDATES PROVIDER
// ====================

/// Provider per candidati di merge (esercizi custom con match nel database)
///
/// Restituisce lista di esercizi custom che potrebbero essere consolidati
/// con esercizi del database ufficiale.
final mergeCandidatesProvider =
    FutureProvider.autoDispose<List<MergeCandidate>>((ref) async {
  // Get current user ID
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return [];
  }

  // Get exercise history
  final historyAsync = ref.watch(exerciseHistoryStreamProvider(userId));
  final exerciseHistories = historyAsync.valueOrNull ?? [];

  if (exerciseHistories.isEmpty) {
    return [];
  }

  // Get database exercises
  final databaseExercisesAsync = ref.watch(allExercisesProvider);
  final databaseExercises = databaseExercisesAsync.valueOrNull ?? [];

  if (databaseExercises.isEmpty) {
    return [];
  }

  // Find merge candidates
  return ExerciseMergeService.findMergeCandidates(
    exerciseHistories: exerciseHistories,
    databaseExercises: databaseExercises,
  );
});

/// Provider per conteggio candidati (per widget home)
final mergeCandidatesCountProvider = Provider.autoDispose<int>((ref) {
  final candidatesAsync = ref.watch(mergeCandidatesProvider);
  return candidatesAsync.valueOrNull?.length ?? 0;
});

/// Provider per solo candidati high quality (>75% match)
final highQualityMergeCandidatesProvider =
    Provider.autoDispose<List<MergeCandidate>>((ref) {
  final candidatesAsync = ref.watch(mergeCandidatesProvider);
  final candidates = candidatesAsync.valueOrNull ?? [];
  return ExerciseMergeService.filterHighQualityCandidates(candidates);
});

// ====================
// MERGE PREVIEW PROVIDER
// ====================

/// Parametri per generare preview merge
typedef MergePreviewParams = ({
  String sourceExerciseName,
  String targetExerciseId,
});

/// Provider per generare preview del merge
final mergePreviewProvider = FutureProvider.autoDispose
    .family<MergePreview?, MergePreviewParams>((ref, params) async {
  // Get user ID
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  // Get exercise histories
  final historyAsync = ref.watch(exerciseHistoryStreamProvider(userId));
  final exerciseHistories = historyAsync.valueOrNull ?? [];

  // Get database exercises
  final databaseExercisesAsync = ref.watch(allExercisesProvider);
  final databaseExercises = databaseExercisesAsync.valueOrNull ?? [];

  // Find target exercise
  final targetExercise = databaseExercises.firstWhere(
    (e) => e.id == params.targetExerciseId,
    orElse: () => throw Exception('Target exercise not found'),
  );

  // Get templates
  final templatesAsync = ref.watch(allWorkoutTemplatesProvider);
  final templates = templatesAsync.valueOrNull ?? [];

  return ExerciseMergeService.generateMergePreview(
    sourceExerciseName: params.sourceExerciseName,
    targetExercise: targetExercise,
    exerciseHistories: exerciseHistories,
    templates: templates,
  );
});

// ====================
// MERGE EXECUTION PROVIDER
// ====================

/// State per esecuzione merge
enum MergeState {
  idle,
  loading,
  success,
  error,
}

/// Progresso del merge con percentuale
class MergeProgress {
  const MergeProgress({
    this.state = MergeState.idle,
    this.progress = 0.0,
    this.currentStep = '',
    this.result,
    this.error,
  });

  final MergeState state;
  final double progress; // 0.0 - 1.0
  final String currentStep;
  final MergeResult? result;
  final String? error;

  MergeProgress copyWith({
    MergeState? state,
    double? progress,
    String? currentStep,
    MergeResult? result,
    String? error,
  }) {
    return MergeProgress(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }

  int get progressPercent => (progress * 100).round();
}

/// Notifier per gestire l'esecuzione del merge con progresso
class MergeExecutionNotifier extends StateNotifier<MergeProgress> {
  MergeExecutionNotifier(this._ref) : super(const MergeProgress());

  final Ref _ref;

  /// Esegue il merge con tracking del progresso
  Future<bool> executeMerge({
    required String sourceExerciseName,
    required String targetExerciseId,
    required String targetExerciseName,
    required String targetMuscleGroup,
  }) async {
    state = const MergeProgress(
      state: MergeState.loading,
      progress: 0.0,
      currentStep: 'Preparazione...',
    );

    try {
      final userId = _ref.read(currentUserIdProvider);
      if (userId == null) {
        state = const MergeProgress(
          state: MergeState.error,
          error: 'User not logged in',
        );
        return false;
      }

      final repository = _ref.read(exerciseMergeRepositoryProvider);

      // Callback per aggiornare il progresso
      void onProgress(double progress, String step) {
        state = state.copyWith(
          progress: progress,
          currentStep: step,
        );
      }

      final result = await repository.executeMergeWithProgress(
        userId: userId,
        sourceExerciseName: sourceExerciseName,
        targetExerciseId: targetExerciseId,
        targetExerciseName: targetExerciseName,
        targetMuscleGroup: targetMuscleGroup,
        onProgress: onProgress,
      );

      return await result.fold(
        (failure) async {
          state = MergeProgress(
            state: MergeState.error,
            error: failure.message,
          );
          return false;
        },
        (mergeResult) async {
          // Step: Aggiornamento cache (85%)
          state = state.copyWith(
            progress: 0.85,
            currentStep: 'Aggiornamento dati...',
          );

          // Invalida cache per refresh dei dati
          _ref.invalidate(exerciseHistoryStreamProvider(userId));

          // Piccola pausa per permettere la propagazione
          await Future<void>.delayed(const Duration(milliseconds: 300));

          state = state.copyWith(
            progress: 0.90,
            currentStep: 'Ricaricamento lista...',
          );

          // Invalida candidati merge
          _ref.invalidate(mergeCandidatesProvider);

          // Attendi che i nuovi dati siano effettivamente disponibili
          // IMPORTANTE: Dobbiamo aspettare che LO STREAM abbia emesso,
          // non solo che candidates abbia un valore (potrebbe essere []
          // se lo stream è ancora in loading)
          var attempts = 0;
          const maxAttempts = 30; // Max 6 secondi (30 * 200ms)

          while (attempts < maxAttempts) {
            await Future<void>.delayed(const Duration(milliseconds: 200));
            attempts++;

            // Aggiorna progresso durante l'attesa (90% -> 99%)
            final progressDelta = 0.09 * (attempts / maxAttempts);
            state = state.copyWith(
              progress: 0.90 + progressDelta,
            );

            // Controlla che ENTRAMBI siano pronti:
            // 1. Lo stream deve aver emesso dati (non loading)
            // 2. I candidates devono avere un valore
            final historyState =
                _ref.read(exerciseHistoryStreamProvider(userId));
            final candidatesState = _ref.read(mergeCandidatesProvider);

            // Stream pronto E candidates pronto
            final streamReady = historyState.hasValue || historyState.hasError;
            final candidatesReady =
                candidatesState.hasValue || candidatesState.hasError;

            if (streamReady && candidatesReady) {
              break;
            }
          }

          state = MergeProgress(
            state: MergeState.success,
            progress: 1.0,
            currentStep: 'Completato!',
            result: mergeResult,
          );

          return true;
        },
      );
    } catch (e) {
      state = MergeProgress(
        state: MergeState.error,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset stato
  void reset() {
    state = const MergeProgress();
  }
}

/// Provider per notifier esecuzione merge
final mergeExecutionProvider =
    StateNotifierProvider.autoDispose<MergeExecutionNotifier, MergeProgress>(
        (ref) {
  return MergeExecutionNotifier(ref);
});
