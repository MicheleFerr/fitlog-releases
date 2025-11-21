/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: domain service
///
/// Service for detecting and analyzing patch conflicts
///
/// **Conflict Types**:
/// 1. **Stale Patch**: originalValue != current exercise value
/// 2. **Duplicate Field**: Multiple pending patches for same exercise field
/// 3. **Version Mismatch**: Exercise schema version changed
///
/// **Usage** (Admin Review):
/// ```dart
/// final conflicts = await conflictDetector.analyzeConflicts(patch);
/// if (conflicts.hasConflicts) {
///   // Show warning to admin
///   showConflictDialog(conflicts);
/// }
/// ```
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';

/// Conflict severity levels
enum ConflictSeverity {
  /// Low severity - can be auto-resolved
  low,

  /// Medium severity - requires admin attention
  medium,

  /// High severity - blocking, must be manually resolved
  high,
}

/// Type of conflict detected
enum ConflictType {
  /// Original value doesn't match current exercise value
  staleValue,

  /// Multiple pending patches for same field
  duplicateField,

  /// Exercise version changed since patch submitted
  versionMismatch,

  /// Exercise no longer exists
  exerciseDeleted,

  /// Field no longer exists in schema
  fieldRemoved,
}

/// Conflict analysis result
class PatchConflict {
  const PatchConflict({
    required this.type,
    required this.severity,
    required this.message,
    this.currentValue,
    this.recommendedAction,
    this.affectedPatches = const [],
  });

  final ConflictType type;
  final ConflictSeverity severity;
  final String message;
  final dynamic currentValue;
  final String? recommendedAction;
  final List<String> affectedPatches; // IDs of conflicting patches

  bool get isBlocking => severity == ConflictSeverity.high;

  bool get needsManualReview =>
      severity == ConflictSeverity.medium || severity == ConflictSeverity.high;
}

/// Conflict analysis result for a patch
class ConflictAnalysis {
  const ConflictAnalysis({
    required this.patch,
    required this.conflicts,
  });

  final ExercisePatch patch;
  final List<PatchConflict> conflicts;

  bool get hasConflicts => conflicts.isNotEmpty;

  bool get hasBlockingConflicts =>
      conflicts.any((c) => c.severity == ConflictSeverity.high);

  List<PatchConflict> get blockingConflicts =>
      conflicts.where((c) => c.isBlocking).toList();

  String get conflictSummary {
    if (conflicts.isEmpty) return 'No conflicts';
    if (conflicts.length == 1) return '1 conflict detected';
    return '${conflicts.length} conflicts detected';
  }
}

/// Service for detecting conflicts in exercise patches
class PatchConflictDetector {
  /// Analyze a patch for potential conflicts
  ///
  /// **Checks**:
  /// 1. Stale value (originalValue != current)
  /// 2. Version mismatch
  /// 3. Field existence
  ///
  /// Returns [ConflictAnalysis] with all detected conflicts
  Future<ConflictAnalysis> analyzeConflicts({
    required ExercisePatch patch,
    required Exercise currentExercise,
    List<ExercisePatch> pendingPatches = const [],
  }) async {
    final conflicts = <PatchConflict>[];

    // 1. Check stale value
    final currentFieldValue = _getCurrentFieldValue(
      currentExercise,
      patch.fieldName,
    );

    if (patch.isStale(currentFieldValue)) {
      conflicts.add(
        PatchConflict(
          type: ConflictType.staleValue,
          severity: ConflictSeverity.medium,
          message: 'Exercise field has been modified since patch submission',
          currentValue: currentFieldValue,
          recommendedAction:
              'Review current value and decide whether to force apply or reject',
        ),
      );
    }

    // 2. Check version mismatch (if Exercise has version field)
    // Note: Exercise entity doesn't currently have version field
    // This check is placeholder for future schema versioning
    // TODO: Implement when Exercise versioning is added
    /* if (patch.version != currentExercise.version) {
      conflicts.add(
        const PatchConflict(
          type: ConflictType.versionMismatch,
          severity: ConflictSeverity.low,
          message: 'Exercise schema version has changed',
          recommendedAction:
              'Verify patch is still valid for current schema',
        ),
      );
    } */

    // 3. Check duplicate field patches
    final duplicates = pendingPatches.where((p) =>
        p.id != patch.id &&
        p.exerciseId == patch.exerciseId &&
        p.fieldName == patch.fieldName &&
        p.isPending);

    if (duplicates.isNotEmpty) {
      conflicts.add(
        PatchConflict(
          type: ConflictType.duplicateField,
          severity: ConflictSeverity.high,
          message:
              '${duplicates.length} other pending patch(es) for same field',
          affectedPatches: duplicates.map((p) => p.id).toList(),
          recommendedAction:
              'Review all conflicting patches before approving any',
        ),
      );
    }

    return ConflictAnalysis(patch: patch, conflicts: conflicts);
  }

  /// Get current value of a field from exercise
  dynamic _getCurrentFieldValue(Exercise exercise, String fieldName) {
    switch (fieldName) {
      case 'nome':
        return exercise.nome;
      case 'noteTecniche':
        return exercise.noteTecniche ?? '';
      case 'attrezzatura':
        return exercise.attrezzatura;
      case 'focusDisplay':
        return exercise.focusDisplayName;
      case 'difficolta':
        return exercise.difficolta;
      case 'mobilitaPre':
        return exercise.mobilitaPre ?? '';
      case 'attivazionePre':
        return exercise.attivazionePre ?? '';
      case 'warmupSets':
        return exercise.warmupSets ?? '';
      case 'tempoWarmup':
        return exercise.tempoWarmup ?? '';
      default:
        return null;
    }
  }

  /// Quick check if patch has conflicts (without full analysis)
  ///
  /// **Use case**: Badge/indicator in list view
  bool hasConflicts({
    required ExercisePatch patch,
    required Exercise currentExercise,
  }) {
    final currentValue = _getCurrentFieldValue(
      currentExercise,
      patch.fieldName,
    );
    return patch.isStale(currentValue);
  }

  /// Get conflict severity color for UI
  ///
  /// Returns hex color string (e.g., "#FF0000" for high severity)
  String getConflictColor(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.low:
        return '#FFA500'; // Orange
      case ConflictSeverity.medium:
        return '#FF6B00'; // Dark orange
      case ConflictSeverity.high:
        return '#FF0000'; // Red
    }
  }

  /// Get recommended action for conflict type
  String getRecommendedAction(ConflictType type) {
    switch (type) {
      case ConflictType.staleValue:
        return 'Compare current and proposed values, decide manually';
      case ConflictType.duplicateField:
        return 'Review all conflicting patches together';
      case ConflictType.versionMismatch:
        return 'Verify patch still valid for current schema';
      case ConflictType.exerciseDeleted:
        return 'Reject patch - exercise no longer exists';
      case ConflictType.fieldRemoved:
        return 'Reject patch - field no longer exists';
    }
  }
}
