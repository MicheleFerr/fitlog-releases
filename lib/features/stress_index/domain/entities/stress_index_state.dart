/// Stress Index State Entity
///
/// Represents the complete stress index state for the UI.
/// Combines latest result, muscle recovery status, and history.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_recovery_status.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';

part 'stress_index_state.freezed.dart';
part 'stress_index_state.g.dart';

@freezed
abstract class StressIndexState with _$StressIndexState {
  const factory StressIndexState({
    /// Latest stress index result (from most recent workout)
    StressIndexResult? latestResult,

    /// Current recovery status for all worked muscles
    required Map<String, MuscleRecoveryStatus> muscleRecovery,

    /// History of stress index results (last 7 days)
    required List<StressIndexResult> history,
  }) = _StressIndexState;

  const StressIndexState._();

  factory StressIndexState.fromJson(Map<String, dynamic> json) =>
      _$StressIndexStateFromJson(json);

  /// Create empty initial state
  factory StressIndexState.empty() => const StressIndexState(
    latestResult: null,
    muscleRecovery: {},
    history: [],
  );

  /// Check if there's any data
  bool get hasData => latestResult != null || history.isNotEmpty;

  /// Get muscles that are fully recovered
  List<MuscleRecoveryStatus> get fullyRecoveredMuscles => muscleRecovery.values
      .where((m) => m.state == RecoveryState.fullyRecovered)
      .toList();

  /// Get muscles that need more rest
  List<MuscleRecoveryStatus> get fatiguedMuscles => muscleRecovery.values
      .where(
        (m) =>
            m.state == RecoveryState.fatigued ||
            m.state == RecoveryState.exhausted,
      )
      .toList();

  /// Get muscles that are almost ready
  List<MuscleRecoveryStatus> get almostReadyMuscles => muscleRecovery.values
      .where((m) => m.state == RecoveryState.almostReady)
      .toList();

  /// Get average recovery percentage across all muscles
  double get averageRecoveryPercentage {
    if (muscleRecovery.isEmpty) return 100.0;
    final total = muscleRecovery.values.fold<double>(
      0,
      (sum, m) => sum + m.recoveryPercentage,
    );
    return total / muscleRecovery.length;
  }
}
