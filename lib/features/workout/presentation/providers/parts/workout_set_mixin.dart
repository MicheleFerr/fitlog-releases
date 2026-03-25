part of '../workout_provider.dart';

mixin WorkoutSetMixin
    on
        Notifier<Workout?>,
        WorkoutCoreMixin,
        WorkoutHelpersMixin,
        WorkoutWatchNotifyMixin,
        WorkoutWatchTypeMixin {
  void completeSet(String exerciseId, String setId) {
    debugPrint(
      '🏋️ [completeSet] Called with exerciseId=$exerciseId, setId=$setId',
    );
    if (state == null) {
      debugPrint('🏋️ [completeSet] ❌ state is null, returning early');
      return;
    }
    debugPrint('🏋️ [completeSet] ✅ state exists, proceeding...');

    // SESSION: Record activity to prevent auto-logout during workout
    ref.read(sessionActivityRecorderProvider);

    try {
      // Track which exercise and set were completed for auto-timer
      Exercise? targetExercise;
      int completedSetNumber = 0;
      int totalSets = 0;
      ExerciseSet? completedSet;

      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          targetExercise = exercise;
          totalSets = exercise.sets.length;

          final updatedSets = exercise.sets.map((set) {
            if (set.id == setId) {
              completedSetNumber = set.setNumber;
              completedSet = set;
              return set.copyWith(
                isCompleted: true,
                completedAt: DateTime.now(),
              );
            }
            return set;
          }).toList();
          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      // WEIGHT CARRY-FORWARD: Propagate weight to subsequent incomplete sets
      if (completedSet != null &&
          completedSet!.weight != null &&
          completedSet!.weight! > 0) {
        final completedWeight = completedSet!.weight!;

        final exercisesWithCarryForward = state!.exercises.map((exercise) {
          if (exercise.id == exerciseId) {
            var weightUpdated = false;
            final updatedSets = exercise.sets.map((set) {
              // Only update sets AFTER the completed one that have 0 or null weight
              if (set.setNumber > completedSetNumber &&
                  !set.isCompleted &&
                  (set.weight == null || set.weight == 0)) {
                weightUpdated = true;
                return set.copyWith(weight: completedWeight);
              }
              return set;
            }).toList();

            if (weightUpdated && kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🔄 [WEIGHT-CARRY] Propagated ${completedWeight}kg from set $completedSetNumber to subsequent sets',
              );
            }

            return exercise.copyWith(sets: updatedSets);
          }
          return exercise;
        }).toList();

        state = state!.copyWith(exercises: exercisesWithCarryForward);
      }

      // Track set completed
      if (targetExercise != null && completedSet != null) {
        final analytics = ref.read(analyticsServiceProvider);
        final tracker = WorkoutEventTracker(analytics);

        tracker.trackSetCompleted(
          workoutId: state!.id,
          exerciseId: targetExercise!.id,
          setNumber: completedSetNumber,
          reps: completedSet!.reps ?? 0,
          weight: completedSet!.weight?.toDouble(),
          rpe: completedSet!.rpe,
        );
      }

      _autoSaveIfNeeded();

      // Notify Apple Watch about set completion
      _notifyWatchWorkoutUpdate();

      // DEBUG: Log timer decision parameters
      debugPrint(
        '⏰ [TIMER DEBUG] completeSet finished - checking timer conditions:',
      );
      debugPrint(
        '⏰ [TIMER DEBUG] targetExercise: ${targetExercise?.name ?? "NULL"}',
      );
      debugPrint('⏰ [TIMER DEBUG] completedSetNumber: $completedSetNumber');
      debugPrint('⏰ [TIMER DEBUG] totalSets: $totalSets');

      final autoRestTimerEnabled = ref
          .read(appConfigProvider)
          .isAutoRestTimerEnabled;
      if (!autoRestTimerEnabled) {
        debugPrint(
          '⏰ [TIMER DEBUG] Auto rest timer disabled - skipping automatic timer start',
        );
        _updateLiveActivityIfActive();
        return;
      }

      // BUG FIX: Auto-start rest timer after completing a set
      if (targetExercise != null && completedSetNumber > 0) {
        // Check if not the last set
        final isLastSet = completedSetNumber >= totalSets;
        debugPrint('⏰ [TIMER DEBUG] isLastSet: $isLastSet');

        if (!isLastSet) {
          // Get rest time from exercise (default 90 seconds)
          final baseRestTime = targetExercise!.restTime ?? 90;
          final nextSetNumber = completedSetNumber + 1;

          // RPE-based rest time adjustment (when enabled)
          // If user completed set with RPE and autoAdjustRestFromRpe is enabled,
          // adjust rest time based on perceived exertion
          int restTime = baseRestTime;
          final config = ref.read(appConfigProvider);
          if ((config.autoAdjustRestFromRpe ?? false) &&
              completedSet?.rpe != null) {
            final adjustment =
                RPEAutoregulationService.calculateRestTimeAdjustment(
                  baseRestSeconds: baseRestTime,
                  actualRPE: completedSet!.rpe!.toDouble(),
                );
            restTime = adjustment.adjustedRestSeconds;

            if (adjustment.hasAdjustment) {
              debugPrint(
                '🔄 [RPE Rest Adjustment] ${adjustment.reason} '
                '(${baseRestTime}s → ${restTime}s)',
              );
            }
          }

          debugPrint(
            '⏰ [TIMER] 🚀 Starting rest timer: ${restTime}s for set $nextSetNumber/$totalSets',
          );

          // Start the timer automatically
          ref
              .read(unifiedTimerProvider.notifier)
              .startTimer(
                durationSeconds: restTime,
                exerciseName: targetExercise!.name,
                currentSet: nextSetNumber,
                totalSets: totalSets,
                exerciseId: targetExercise!.id,
                completedSetId:
                    setId, // Rest Timer Tracking: pass completed set ID
              );

          debugPrint('⏰ [TIMER] ✅ Timer start called!');

          // iOS 17+: Transition Live Activity to rest mode
          if (Platform.isIOS) {
            final laState = ref.read(workoutSessionLAProvider);
            debugPrint(
              '[WorkoutProvider] 📱 LA state before transition: isActive=${laState.isActive}, activityId=${laState.activityId}',
            );

            ref
                .read(workoutSessionLAProvider.notifier)
                .transitionToRest(
                  restDurationSeconds: restTime,
                  nextExercise: targetExercise!,
                  nextSetIndex: nextSetNumber,
                );
          }
        } else {
          // Last set of this exercise - check for inter-exercise timer
          final nextExercise = _getNextIncompleteExercise(
            state!,
            targetExercise!,
          );

          if (nextExercise != null) {
            // Start inter-exercise rest timer
            final interExerciseRest = _resolveInterExerciseRest(
              targetExercise!,
            );
            final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

            debugPrint(
              '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer: ${interExerciseRest}s before ${nextExercise.name}',
            );

            ref
                .read(unifiedTimerProvider.notifier)
                .startTimer(
                  durationSeconds: interExerciseRest,
                  type: TimerType.interExercise,
                  exerciseName: nextExercise.name,
                  currentSet: 1,
                  totalSets: nextExerciseTotalSets,
                  exerciseId: nextExercise.id,
                  completedSetId:
                      setId, // Rest Timer Tracking: pass completed set ID
                );

            // iOS 17+: Transition Live Activity to inter-exercise rest mode
            if (Platform.isIOS) {
              ref
                  .read(workoutSessionLAProvider.notifier)
                  .transitionToRest(
                    restDurationSeconds: interExerciseRest,
                    nextExercise: nextExercise,
                    nextSetIndex: 1,
                  );
            }
          } else {
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⏰ [AUTO-TIMER] Last exercise completed - workout finished!',
              );
            }
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error completing set: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExerciseSet(String exerciseId, ExerciseSet updatedSet) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final updatedSets = exercise.sets.map((set) {
            if (set.id == updatedSet.id) {
              return updatedSet;
            }
            return set;
          }).toList();
          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      // Auto-save modifications
      _autoSaveIfNeeded();

      // BUG FIX: Notify Watch when set completion state changes
      // This ensures deselecting a set (marking incomplete) syncs to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating exercise set: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Rest Timer Tracking: Update a completed set with rest timer data.
  /// Called by unified_timer_provider when the rest timer completes or is skipped.
  void updateSetRestTimerData({
    required String exerciseId,
    required String setId,
    required bool restTimerSkipped,
    int? restTimerSecondsRemaining,
    int? restTimerSecondsAdded,
    int? actualRestSeconds,
  }) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final updatedSets = exercise.sets.map((set) {
            if (set.id == setId) {
              return set.copyWith(
                restTimerSkipped: restTimerSkipped,
                restTimerSecondsRemaining: restTimerSecondsRemaining,
                restTimerSecondsAdded: restTimerSecondsAdded,
                actualRestSeconds: actualRestSeconds,
              );
            }
            return set;
          }).toList();
          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      if (kDebugMode) {
        debugPrint(
          '⏱️ [REST-TIMER] Updated set $setId: skipped=$restTimerSkipped, remaining=${restTimerSecondsRemaining}s, added=${restTimerSecondsAdded}s, actual=${actualRestSeconds}s',
        );
      }

      // Auto-save modifications
      _autoSaveIfNeeded();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating set rest timer data: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
    }
  }

  void updateSupersetSet(String exerciseId, SupersetSet updatedSupersetSet) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId && exercise is SupersetExercise) {
          final updatedSupersetSets = exercise.supersetSets.map((set) {
            // FIX: Use setNumber instead of id to identify rounds
            // All rounds created together have the same ID (timestamp),
            // but setNumber is unique (1, 2, 3, etc.)
            if (set.setNumber == updatedSupersetSet.setNumber) {
              return updatedSupersetSet;
            }
            return set;
          }).toList();
          return exercise.copyWith(supersetSets: updatedSupersetSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating superset set: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void addSetToExercise(String exerciseId) {
    if (state == null) return;

    // SESSION: Record activity to prevent auto-logout during workout
    ref.read(sessionActivityRecorderProvider);

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final newSetNumber = exercise.sets.length + 1;
          final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;

          final newSet = ExerciseSet(
            setNumber: newSetNumber,
            weight: lastSet?.weight ?? 0,
            reps: lastSet?.reps ?? 10,
          );

          return exercise.copyWith(sets: [...exercise.sets, newSet]);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error adding set to exercise: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void removeSetFromExercise(String exerciseId, String setId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final updatedSets = exercise.sets
              .where((set) => set.id != setId)
              .toList();

          // Prevent removing last set
          if (updatedSets.isEmpty) {
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Cannot remove last set from exercise',
              );
            }
            return exercise;
          }

          // Renumber sets
          for (int i = 0; i < updatedSets.length; i++) {
            updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
          }

          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error removing set from exercise: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Adds a new round to a superset
  void addRoundToSuperset(String supersetId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == supersetId && exercise is SupersetExercise) {
          final newRoundNumber = exercise.supersetSets.length + 1;
          final lastRound = exercise.supersetSets.isNotEmpty
              ? exercise.supersetSets.last
              : null;

          // Create exerciseData for all exercises in the superset
          final Map<String, SupersetExerciseData> exerciseData = {};

          for (final ex in exercise.exercises) {
            // Use data from the last round as template, or default values
            final lastData = lastRound?.exerciseData[ex.id];
            exerciseData[ex.id] = SupersetExerciseData(
              exerciseId: ex.id,
              exerciseName: ex.name,
              targetWeight:
                  lastData?.targetWeight ?? lastData?.actualWeight ?? 0.0,
              targetReps: lastData?.targetReps ?? lastData?.actualReps ?? 10,
              actualWeight: null,
              actualReps: null,
              rpe: null,
              isCompleted: false,
              notes: null,
            );
          }

          // FIX: Generate unique ID for the new round
          final newRound = SupersetSet(
            id: 'superset_round_${DateTime.now().millisecondsSinceEpoch}_$newRoundNumber',
            setNumber: newRoundNumber,
            exerciseData: exerciseData,
            isCompleted: false,
          );

          return exercise.copyWith(
            supersetSets: [...exercise.supersetSets, newRound],
          );
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error adding round to superset: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Removes a round from a superset
  void removeRoundFromSuperset(String supersetId, String roundId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == supersetId && exercise is SupersetExercise) {
          final updatedRounds = exercise.supersetSets
              .where((round) => round.id != roundId)
              .toList();

          // Prevent removing last round
          if (updatedRounds.isEmpty) {
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Cannot remove last round from superset',
              );
            }
            return exercise;
          }

          // Renumber rounds
          for (int i = 0; i < updatedRounds.length; i++) {
            updatedRounds[i] = updatedRounds[i].copyWith(setNumber: i + 1);
          }

          return exercise.copyWith(supersetSets: updatedRounds);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error removing round from superset: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }
}
