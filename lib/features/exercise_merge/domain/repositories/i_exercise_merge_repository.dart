/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/domain/repositories
/// 🎯 Feature: exercise_merge
/// 🔧 Type: repository_interface
///
/// Interfaccia repository per operazioni di merge esercizi
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_preview.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Repository interface per merge esercizi
///
/// Definisce le operazioni necessarie per mergare esercizi custom
/// con esercizi del database ufficiale.
abstract class IExerciseMergeRepository {
  /// Esegue il merge dell'esercizio
  ///
  /// [userId] - ID utente
  /// [sourceExerciseName] - Nome esercizio custom da eliminare/mergare
  /// [targetExerciseId] - ID esercizio target nel database
  /// [targetExerciseName] - Nome esercizio target
  /// [targetMuscleGroup] - Muscle group dell'esercizio target
  ///
  /// Returns: [MergeResult] con dettagli del merge
  Future<Either<Failure, MergeResult>> executeMerge({
    required String userId,
    required String sourceExerciseName,
    required String targetExerciseId,
    required String targetExerciseName,
    required String targetMuscleGroup,
  });

  /// Esegue il merge con callback di progresso
  ///
  /// [onProgress] - Callback (progress 0.0-1.0, stepDescription)
  Future<Either<Failure, MergeResult>> executeMergeWithProgress({
    required String userId,
    required String sourceExerciseName,
    required String targetExerciseId,
    required String targetExerciseName,
    required String targetMuscleGroup,
    required void Function(double progress, String step) onProgress,
  });

  /// Conta le sessioni che verranno aggiornate
  Future<int> countSessionsToUpdate({
    required String userId,
    required String sourceExerciseName,
  });

  /// Conta i template che verranno aggiornati
  Future<int> countTemplatesToUpdate({
    required String userId,
    required String sourceExerciseName,
  });
}
