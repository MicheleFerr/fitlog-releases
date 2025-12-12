/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: provider
///
/// Provider for patch conflict detection
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/patch_conflict_detector.dart';

/// Provider for PatchConflictDetector service
final patchConflictDetectorProvider = Provider<PatchConflictDetector>((ref) {
  return PatchConflictDetector();
});

/// Provider for analyzing conflicts for a specific patch
///
/// **Usage** (Admin Review):
/// ```dart
/// final analysis = ref.watch(patchConflictAnalysisProvider(
///   patch: patch,
///   currentExercise: exercise,
///   pendingPatches: allPendingPatches,
/// ));
/// ```
final patchConflictAnalysisProvider = FutureProvider.autoDispose
    .family<ConflictAnalysis, PatchConflictAnalysisParams>((ref, params) async {
  final detector = ref.watch(patchConflictDetectorProvider);

  return await detector.analyzeConflicts(
    patch: params.patch,
    currentExercise: params.currentExercise,
    pendingPatches: params.pendingPatches,
  );
});

/// Parameters for conflict analysis
class PatchConflictAnalysisParams {
  const PatchConflictAnalysisParams({
    required this.patch,
    required this.currentExercise,
    this.pendingPatches = const [],
  });

  final ExercisePatch patch;
  final Exercise currentExercise;
  final List<ExercisePatch> pendingPatches;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchConflictAnalysisParams &&
          runtimeType == other.runtimeType &&
          patch.id == other.patch.id &&
          currentExercise.id == other.currentExercise.id &&
          pendingPatches.length == other.pendingPatches.length;

  @override
  int get hashCode =>
      patch.id.hashCode ^
      currentExercise.id.hashCode ^
      pendingPatches.length.hashCode;
}

/// Quick check provider for conflict badge (non-blocking)
///
/// **Usage**: Show badge in list if patch has conflicts
/// ```dart
/// final hasConflict = ref.watch(quickConflictCheckProvider(
///   patch: patch,
///   currentExercise: exercise,
/// ));
/// if (hasConflict) {
///   SemanticIcon(icon: AppAppIcons.warning, color: context.colors.warning, semanticLabel: 'Conflict')
/// }
/// ```
final quickConflictCheckProvider =
    Provider.autoDispose.family<bool, QuickConflictCheckParams>(
  (ref, params) {
    final detector = ref.watch(patchConflictDetectorProvider);
    return detector.hasConflicts(
      patch: params.patch,
      currentExercise: params.currentExercise,
    );
  },
);

/// Parameters for quick conflict check
class QuickConflictCheckParams {
  const QuickConflictCheckParams({
    required this.patch,
    required this.currentExercise,
  });

  final ExercisePatch patch;
  final Exercise currentExercise;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickConflictCheckParams &&
          runtimeType == other.runtimeType &&
          patch.id == other.patch.id &&
          currentExercise.id == other.currentExercise.id;

  @override
  int get hashCode => patch.id.hashCode ^ currentExercise.id.hashCode;
}
