part of '../workout_provider.dart';

/// Core mixin that holds shared fields and the auto-save helper.
///
/// All other workout mixins declare `on Notifier<Workout?>, WorkoutCoreMixin`
/// so they can access `_autoSaveIfNeeded`, `_currentTemplateId`, and
/// the other instance fields without compiler errors.
mixin WorkoutCoreMixin on Notifier<Workout?> {
  // CRITICAL FIX: Track disposal state to prevent operations after dispose
  bool _isDisposed = false;

  // 💾 Track current template ID for auto-save
  String? _currentTemplateId;

  // 🧹 Cleanup timer fields
  Timer? _cleanupTimer;
  bool _timerPaused = false;

  // ⌚ Debounce for Watch set completion (prevents duplicate processing)
  DateTime? _lastWatchSetCompletion;
  String? _lastCompletedSetId;

  // 💾 Helper method to auto-save modifications
  void _autoSaveIfNeeded() {
    // Save to template cache (for template modifications)
    if (_currentTemplateId != null && state != null) {
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      cacheService.saveWorkoutModifications(
        templateId: _currentTemplateId!,
        workout: state!,
      );
    }

    // 💾 BUG FIX #5: Also save to draft repository for crash recovery
    // This prevents losing workout data if app crashes or is killed
    if (state != null && state!.status == WorkoutStatus.inProgress) {
      ref.read(workoutAutoSaveProvider.notifier).triggerSave(state!);
    }
  }
}
