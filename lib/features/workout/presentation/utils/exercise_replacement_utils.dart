library;

import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

/// Builds the replacement exercise while preserving the existing workout slot.
///
/// The selected replacement provides the new exercise identity and metadata,
/// while the current exercise keeps the workout programming already configured
/// on that slot: ids, sets, rest settings, TUT and counting mode.
Exercise buildReplacementExercise({
  required Exercise currentExercise,
  required Exercise replacementExercise,
  bool preserveWorkoutSlotIdentity = true,
}) {
  final replacementStableId = replacementExercise.stableExerciseId;

  return replacementExercise.copyWith(
    id: preserveWorkoutSlotIdentity ? currentExercise.id : replacementStableId,
    databaseExerciseId: replacementStableId,
    sets: currentExercise.sets.map((set) => set.copyWith()).toList(),
    notes: currentExercise.notes,
    restTime: currentExercise.restTime,
    clearRestTime: currentExercise.restTime == null,
    restAfterExercise: currentExercise.restAfterExercise,
    clearRestAfterExercise: currentExercise.restAfterExercise == null,
    tut: currentExercise.tut,
    autoAdjustmentType: currentExercise.autoAdjustmentType,
    targetRPEMin: currentExercise.targetRPEMin,
    targetRPEMax: currentExercise.targetRPEMax,
    targetRIR: currentExercise.targetRIR,
    countingMode: currentExercise.countingMode,
    updatedAt: DateTime.now(),
  );
}
