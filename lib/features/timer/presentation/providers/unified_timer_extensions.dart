import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_ui_state_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Extensions per UnifiedTimerProvider con funzionalità tier-1
/// 
/// Aggiunge funzionalità avanzate senza creare nuovi provider
/// Rispetta CLAUDE.md: estende invece di stratificare
extension Tier1TimerExtensions on StateNotifier<UnifiedTimerState?> {
  
  /// Start rest timer con UI automatica
  Future<void> startRestTimerWithUI({
    required int seconds,
    required Ref ref,
    String? exerciseName,
    String? exerciseId,
    int? currentSet,
    int? totalSets,
  }) async {
    // Get timer sound preference from app config
    final config = ref.read(appConfigProvider);
    
    // Start timer logic - cast to access methods
    final controller = this as dynamic;
    await controller.startTimer(
      durationSeconds: seconds,
      type: TimerType.rest,
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      currentSet: currentSet,
      totalSets: totalSets,
      customSound: config.timerSound, // Pass user's sound preference
    );
    
    // Show UI automatically
    ref.read(timerUIStateProvider.notifier).show();
  }
  
  /// Stop timer e nascondi UI
  Future<void> stopTimerWithUI(Ref ref) async {
    final controller = this as dynamic;
    await controller.stopTimer();
    ref.read(timerUIStateProvider.notifier).hide();
  }
  
  /// Quick rest timer presets
  Future<void> startQuickRest(int seconds, Ref ref) async {
    await startRestTimerWithUI(
      seconds: seconds,
      ref: ref,
      exerciseName: 'Quick Rest',
    );
  }
}

/// Provider per azioni tier-1 rapide (backward compatibility)
final tier1TimerActionsProvider = Provider<Tier1TimerActions>((ref) {
  return Tier1TimerActions(ref);
});

/// Helper class per azioni comuni tier-1
class Tier1TimerActions {
  
  Tier1TimerActions(this.ref);
  final Ref ref;
  
  /// Start rest timer con UI
  Future<void> startExerciseRest({
    required int seconds,
    required String exerciseName,
    String? exerciseId,
    int? currentSet,
    int? totalSets,
  }) async {
    final controller = ref.read(unifiedTimerProvider.notifier);
    
    await controller.startRestTimerWithUI(
      seconds: seconds,
      ref: ref,
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      currentSet: currentSet,
      totalSets: totalSets,
    );
  }
  
  /// Stop timer corrente
  Future<void> stopCurrentTimer() async {
    final controller = ref.read(unifiedTimerProvider.notifier);
    await controller.stopTimerWithUI(ref);
  }
  
  /// Toggle visibilità UI
  void toggleTimerVisibility() {
    ref.read(timerUIStateProvider.notifier).toggleVisibility();
  }
  
  /// Smart rest basato su reps
  int calculateSmartRestTime(int reps) {
    if (reps <= 5) return 180;  // 3 min for strength
    if (reps <= 8) return 120;  // 2 min for hypertrophy
    if (reps <= 12) return 90;  // 90s for moderate
    return 60;  // 60s for endurance
  }
  
  /// Start smart rest
  Future<void> startSmartRest({
    required int reps,
    required String exerciseName,
    String? exerciseId,
    int? currentSet,
    int? totalSets,
  }) async {
    final seconds = calculateSmartRestTime(reps);
    
    await startExerciseRest(
      seconds: seconds,
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      currentSet: currentSet,
      totalSets: totalSets,
    );
  }
}

/// Provider per compatibilità con vecchio shouldShowTier1TimerProvider
final shouldShowTier1TimerProvider = Provider<bool>((ref) {
  return ref.watch(shouldShowTimerUIProvider);
});

/// Provider helper per stato timer attivo
final timerIsActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(unifiedTimerProvider);
  return state?.isActive ?? false;
});

/// Provider per tempo rimanente formattato
final timerRemainingFormattedProvider = Provider<String>((ref) {
  final state = ref.watch(unifiedTimerProvider);
  if (state == null) return '00:00';
  
  final minutes = (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (state.remainingSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
});

/// Provider per progresso timer (0.0 to 1.0)
final timerProgressProvider = Provider<double>((ref) {
  final state = ref.watch(unifiedTimerProvider);
  if (state == null || state.totalDurationSeconds == 0) return 0.0;
  
  return (state.totalDurationSeconds - state.remainingSeconds) / state.totalDurationSeconds;
});

/// Provider per colore dinamico basato su stato
final timerColorProvider = Provider<List<int>>((ref) {
  final state = ref.watch(unifiedTimerProvider);
  if (state == null) return [0xFF6B5FCD, 0xFF8B7FDD]; // Default purple
  
  if (state.isPaused) {
    return [0xFFFFA726, 0xFFFFB74D]; // Orange for paused
  }
  
  if (state.remainingSeconds <= 10) {
    return [0xFFEF5350, 0xFFE57373]; // Red for final countdown
  }
  
  if (state.remainingSeconds <= 30) {
    return [0xFFFFA726, 0xFFFFB74D]; // Orange for warning
  }
  
  return [0xFF66BB6A, 0xFF81C784]; // Green for running
});