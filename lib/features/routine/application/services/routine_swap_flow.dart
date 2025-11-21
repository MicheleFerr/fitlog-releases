import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_matching_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';

/// Gestisce il flow di swap: mostra dialog, ottiene la decisione dell'utente,
/// esegue lo swap su Firestore
///
/// ⚠️ **v2.0 STUB**: This service is temporarily stubbed out for v2.0 simplified schema.
/// The v1.0 complex features (day swapping, schedule mutations) don't exist in v2.0.
/// TODO: Reimplement when v2.0 adds advanced tracking features.
class RoutineSwapFlow {
  const RoutineSwapFlow({required this.repository});

  final FlexibleRoutineRepository repository;

  /// Mostra il dialog di conferma swap e gestisce la decisione
  ///
  /// **v2.0 STUB**: Always returns null (no swap) - swap feature not implemented in v2.0
  Future<SwapDecision?> showAndHandleSwapDialog({
    required BuildContext context,
    required RoutineSwapOpportunity swapOpportunity,
    required FlexibleRoutine activeRoutine,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🔄 [SwapFlow v2.0 STUB] showAndHandleSwapDialog called - returning null (feature not implemented in v2.0)',
      );
    }

    // v2.0 simplified schema doesn't support day-level swapping
    return null;
  }
}

/// Rappresenta la decisione dell'utente nel dialog di swap
///
/// **v2.0 STUB**: This enum is kept for compatibility but never used in v2.0
enum SwapDecision {
  continueNormal, // User wants to continue with today's template
  swapDays, // User wants to swap today with future day
  cancel, // User cancelled
}
