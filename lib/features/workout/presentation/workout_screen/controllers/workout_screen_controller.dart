import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_time_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_save_dialog.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_completion_celebration.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_time_edit_sheet.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/shared/data/services/interstitial_ad_service.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'workout_screen_controller.freezed.dart';

/// State for WorkoutScreen UI
@freezed
abstract class WorkoutScreenState with _$WorkoutScreenState {
  const factory WorkoutScreenState({
    /// Whether exercise reorder mode is active
    @Default(false) bool isReorderMode,

    /// Currently selected template ID for workout creation
    String? selectedTemplateId,

    /// Whether to show the welcome view
    @Default(false) bool showWelcome,

    /// Whether to show the "Change Workout" banner
    @Default(false) bool showChangeWorkoutBanner,
  }) = _WorkoutScreenState;
}

/// Controller for WorkoutScreen business logic
///
/// This controller encapsulates all workout screen operations including:
/// - Starting/stopping workouts
/// - Managing exercises (add, remove, reorder)
/// - Template selection
/// - Timer integration
/// - Navigation
///
/// It separates business logic from UI, making the screen more testable
/// and maintainable.
class WorkoutScreenController extends Notifier<WorkoutScreenState> {
  @override
  WorkoutScreenState build() => const WorkoutScreenState();

  final _interstitialAdService = InterstitialAdService();

  /// Start a new workout from a template or empty
  ///
  /// If [template] is provided, creates workout with template exercises.
  /// Otherwise creates empty workout for manual exercise addition.
  Future<void> startWorkout({
    required BuildContext context,
    wt.WorkoutTemplate? template,
    String? sessionId,
  }) async {
    if (kDebugMode) {
      debugPrint('🏋️ [WorkoutScreenController] Starting workout${template != null ? ' from template: ${template.name}' : ' (empty)'}');
    }

    try {
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);

      if (template != null) {
        // Start from template
        // Convert template exercises to workout exercises
        final exercises = template.exercises.map((et) => et.toWorkoutExercise()).toList();

        await workoutNotifier.createWorkoutFromRoutine(
          routineName: template.name,
          exercises: exercises,
          sessionId: sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          templateId: template.id,
        );
      } else {
        // Start empty workout
        workoutNotifier.createWorkout('Quick Workout');
      }

      // Activate workout
      workoutNotifier.startWorkout();

      // Clear template selection
      state = state.copyWith(selectedTemplateId: null);

      // Haptic feedback
      unawaited(HapticFeedback.mediumImpact());

      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] Workout started successfully');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutScreenController] Error starting workout: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// End current workout and save
  ///
  /// Completes the workout, tracks analytics, shows PR celebrations if any,
  /// and navigates back to home after showing completion ad.
  ///
  /// If the workout was started from a template and has modifications,
  /// shows a dialog to let user choose: update template, save as new, or keep original.
  Future<void> endWorkout({
    required BuildContext context,
  }) async {
    if (kDebugMode) {
      debugPrint('🏁 [WorkoutScreenController] Ending workout');
    }

    try {
      // Track first workout completion for onboarding
      final onboardingState = ref.read(onboardingProvider);
      if (onboardingState.isInGuidedFirstWorkout) {
        unawaited(ref.read(onboardingProvider.notifier).markFirstWorkoutCompleted());

        if (kDebugMode) {
          debugPrint('🎉 [WorkoutScreenController] First workout completed! Onboarding Phase 2 complete');
        }
      }

      // Check if workout duration seems suspiciously short
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout != null && context.mounted) {
        final timeMetrics = WorkoutTimeCalculator.getTimeMetrics(currentWorkout);

        if (timeMetrics.isSuspicious) {
          if (kDebugMode) {
            debugPrint('⏱️ [WorkoutScreenController] Workout time suspicious: '
                '${timeMetrics.actualDurationFormatted} < ${timeMetrics.totalRestTimeFormatted}');
          }

          // Show time edit sheet
          final newDuration = await WorkoutTimeEditSheet.show(
            context: context,
            workout: currentWorkout,
          );

          // If user selected new duration, update workout
          if (newDuration != null && context.mounted) {
            ref.read(currentWorkoutProvider.notifier).updateWorkoutDuration(newDuration);

            if (kDebugMode) {
              debugPrint('✅ [WorkoutScreenController] Workout duration updated to: $newDuration');
            }
          }
        }
      }

      // Re-read workout after potential duration update
      final workoutForCelebration = ref.read(currentWorkoutProvider);
      if (workoutForCelebration == null || !context.mounted) return;

      // 🎉 Show celebration overlay FIRST - let user review before saving
      final celebrationResult = await showWorkoutCompletionCelebration(
        context,
        workoutForCelebration,
      );

      // If user cancelled, return to workout screen to modify
      if (celebrationResult == CelebrationResult.cancelled) {
        if (kDebugMode) {
          debugPrint('↩️ [WorkoutScreenController] User cancelled - returning to workout screen');
        }
        return; // Don't save, user can modify the workout
      }

      // User confirmed - now check template and save
      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] User confirmed - proceeding with save');
      }

      // Re-read workout after potential modifications
      final updatedWorkout = ref.read(currentWorkoutProvider);

      // Check if workout was started from a template
      if (updatedWorkout != null &&
          updatedWorkout.templateId != null &&
          updatedWorkout.templateId!.isNotEmpty &&
          context.mounted) {
        // Fetch original template
        final originalTemplate = await ref.read(
          templateByIdProvider(updatedWorkout.templateId!).future,
        );

        if (originalTemplate != null && context.mounted) {
          if (kDebugMode) {
            debugPrint('📝 [WorkoutScreenController] Workout from template, showing save dialog');
          }

          // Show template save dialog
          await showTemplateSaveDialog(
            context: context,
            completedWorkout: updatedWorkout,
            originalTemplate: originalTemplate,
          );

          if (kDebugMode) {
            debugPrint('📝 [WorkoutScreenController] Template save dialog completed');
          }
        }
      }

      // Complete workout (saves to database) - NOW after user confirmed
      if (context.mounted) {
        ref.read(currentWorkoutProvider.notifier).completeWorkout(context);
      }

      // Haptic feedback
      unawaited(HapticFeedback.mediumImpact());

      // Check for newly detected PRs and show celebration
      final newPRs = ref.read(newlyDetectedPRsProvider);
      if (newPRs.isNotEmpty && context.mounted) {
        unawaited(_showPRCelebration(context, newPRs.first));
        ref.read(newlyDetectedPRsProvider.notifier).state = [];
      }

      // Show interstitial ad after workout completion (only for non-premium users)
      final isPremium = ref.read(isPremiumUserProvider);
      if (!isPremium && context.mounted) {
        await Future.delayed(const Duration(milliseconds: 500));

        unawaited(_interstitialAdService.showAdIfReady(
          onAdClosed: () {
            ref.read(currentWorkoutProvider.notifier).clearWorkout();
            if (context.mounted) {
              context.goNamed('home');
            }
          },
        ));

        // Fallback navigation if ad doesn't show
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            final stillCompleted = ref.read(currentWorkoutProvider);
            if (stillCompleted != null && stillCompleted.isCompleted) {
              ref.read(currentWorkoutProvider.notifier).clearWorkout();
              context.goNamed('home');
            }
          }
        });
      } else if (context.mounted) {
        // Premium user - navigate directly
        ref.read(currentWorkoutProvider.notifier).clearWorkout();
        context.goNamed('home');
      }

      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] Workout ended successfully');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutScreenController] Error ending workout: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// Discard current workout without saving
  ///
  /// Clears workout state and navigates back.
  /// Should show confirmation dialog before calling this.
  Future<void> discardWorkout({
    required BuildContext context,
  }) async {
    if (kDebugMode) {
      debugPrint('🗑️ [WorkoutScreenController] Discarding workout');
    }

    try {
      ref.read(currentWorkoutProvider.notifier).clearWorkout();

      if (context.mounted) {
        context.goNamed('home');
      }

      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] Workout discarded');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutScreenController] Error discarding workout: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// Save current workout (pause state)
  ///
  /// Saves workout to local storage without completing.
  Future<void> saveWorkout() async {
    if (kDebugMode) {
      debugPrint('💾 [WorkoutScreenController] Saving workout');
    }

    try {
      ref.read(currentWorkoutProvider.notifier).pauseWorkout();

      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] Workout saved');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutScreenController] Error saving workout: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// Toggle exercise reorder mode
  ///
  /// Enables/disables drag-and-drop reordering of exercises in workout.
  void toggleReorderMode() {
    if (kDebugMode) {
      debugPrint('🔄 [WorkoutScreenController] Toggling reorder mode: ${!state.isReorderMode}');
    }

    state = state.copyWith(isReorderMode: !state.isReorderMode);
  }

  /// Add exercise to current workout
  ///
  /// Adds the exercise to the end of the workout's exercise list.
  Future<void> addExercise(Exercise exercise) async {
    debugPrint('➕ [WorkoutScreenController] Adding exercise: ${exercise.name}, countingMode=${exercise.countingMode}');

    try {
      ref.read(currentWorkoutProvider.notifier).addExercise(exercise);

      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] Exercise added');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutScreenController] Error adding exercise: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// Remove exercise from workout by exercise ID
  ///
  /// Removes the exercise with the given [exerciseId] from current workout.
  Future<void> removeExercise(String exerciseId) async {
    if (kDebugMode) {
      debugPrint('➖ [WorkoutScreenController] Removing exercise: $exerciseId');
    }

    try {
      ref.read(currentWorkoutProvider.notifier).removeExercise(exerciseId);

      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] Exercise removed');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutScreenController] Error removing exercise: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// Reorder exercises in workout
  ///
  /// Moves exercise from [oldIndex] to [newIndex] in the exercise list.
  Future<void> reorderExercises(int oldIndex, int newIndex) async {
    if (kDebugMode) {
      debugPrint('🔀 [WorkoutScreenController] Reordering: $oldIndex → $newIndex');
    }

    try {
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout == null) return;

      final exercises = List<Exercise>.from(currentWorkout.exercises);

      // Adjust indices for drag-and-drop behavior
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final exercise = exercises.removeAt(oldIndex);
      exercises.insert(newIndex, exercise);

      // Update workout with reordered exercises
      final updatedWorkout = currentWorkout.copyWith(exercises: exercises);
      ref.read(currentWorkoutProvider.notifier).state = updatedWorkout;

      if (kDebugMode) {
        debugPrint('✅ [WorkoutScreenController] Exercises reordered');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutScreenController] Error reordering exercises: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// Select a template for workout creation
  ///
  /// Stores the template ID for later use when starting workout.
  void selectTemplate(String templateId) {
    if (kDebugMode) {
      debugPrint('📋 [WorkoutScreenController] Selected template: $templateId');
    }

    state = state.copyWith(selectedTemplateId: templateId);
  }

  /// Clear selected template
  void clearTemplate() {
    if (kDebugMode) {
      debugPrint('🗑️ [WorkoutScreenController] Cleared template selection');
    }

    state = state.copyWith(selectedTemplateId: null);
  }

  /// Toggle welcome view visibility
  void toggleWelcome(bool show) {
    state = state.copyWith(showWelcome: show);
  }

  /// Toggle change workout banner visibility
  void toggleChangeWorkoutBanner(bool show) {
    state = state.copyWith(showChangeWorkoutBanner: show);
  }

  /// Show PR celebration for completed workout
  ///
  /// Displays PR celebration and tracks engagement analytics.
  /// This is called internally after workout completion.
  Future<void> _showPRCelebration(
    BuildContext context,
    PRCelebration celebration,
  ) async {
    if (!context.mounted) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [WorkoutScreenController] Cannot show PR celebration: user not authenticated');
      }
      return;
    }

    // Track engagement
    final celebrationRepo = ref.read(prCelebrationRepositoryProvider);
    unawaited(celebrationRepo.trackEngagement(
      userId,
      celebration.prId,
      CelebrationEngagement.viewed,
    ));

    // TODO: Implement PRCelebrationOverlay UI component
    // For now, this is a placeholder for the celebration display logic
    if (kDebugMode) {
      debugPrint('🏆 [WorkoutScreenController] PR Celebration: ${celebration.exerciseName}');
    }
  }

  /// Preload interstitial ad for workout completion
  ///
  /// Call this in initState to ensure ad is ready when workout completes.
  void preloadCompletionAd() {
    _interstitialAdService.preloadWorkoutCompleteAd();
  }

  // Note: Notifier doesn't have dispose() - cleanup handled automatically
}

/// Provider for WorkoutScreenController
final workoutScreenControllerProvider =
    NotifierProvider<WorkoutScreenController, WorkoutScreenState>(WorkoutScreenController.new);
