part of '../workout_provider.dart';

mixin WorkoutSaveMixin on Notifier<Workout?>, WorkoutCoreMixin, WorkoutSaveCloudMixin {
  /// Save the completed workout locally and to Firestore.
  ///
  /// Pass [context] to show sync status toasts during save flow.
  /// If [context] is null, saves silently without UI feedback.
  Future<void> _saveCompletedWorkoutToFirestore([BuildContext? context]) async {
    final workout = state;
    if (workout == null || !workout.isCompleted) {
      return;
    }

    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    // FIX CASE 3: Don't return early if user not authenticated
    // Instead, use a fallback userId for local save (workout won't be lost)
    // Firebase sync will be skipped, but local save will work
    final effectiveUserId = currentUser?.uid ?? 'anonymous_${workout.id}';
    final isAuthenticated = currentUser != null;

    if (!isAuthenticated && kDebugMode) {
      debugLog(
        LogCategory.workout,
        '⚠️ [WorkoutProvider] User not authenticated - workout will be saved locally only',
      );
    }

    // UI Feedback: Show "Saving workout..." toast
    if (context != null) {
      SyncStatusToast.showSavingWorkout(context);
    }

    try {
      // SECURITY: Sanitize user input to prevent XSS/injection attacks
      final sanitizedWorkoutName = InputValidator.sanitizeName(workout.name);
      final sanitizedWorkoutNotes = InputValidator.sanitizeText(
        workout.notes ?? '',
      );

      // Validate workout data before save
      final validation = InputValidator.validateWorkoutData(
        workoutName: sanitizedWorkoutName,
        notes: sanitizedWorkoutNotes,
        exerciseNames: workout.exercises.map((e) => e.name).toList(),
      );

      if (!validation.isValid) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Validation failed: ${validation.errors.join(', ')}',
        );
        // Don't throw - log error but continue with sanitized data
      }

      // 1. Convert Workout to WorkoutHistoryDetail (with sanitized data)
      final exercisesHistory = workout.exercises.map((exercise) {
        // Sanitize exercise data
        final sanitizedExerciseName = InputValidator.sanitizeName(
          exercise.name,
        );
        final sanitizedExerciseNotes = InputValidator.sanitizeText(
          exercise.notes ?? '',
          maxLength: 500,
        );

        final setsHistory = exercise.sets.map((set) {
          // Sanitize set notes
          final sanitizedSetNotes = set.notes != null
              ? InputValidator.sanitizeText(set.notes!, maxLength: 200)
              : null;

          return SetHistoryDetail(
            setNumber: set.setNumber,
            weight: double.tryParse(set.weight.toString()) ?? 0.0,
            reps: int.tryParse(set.reps.toString()) ?? 0,
            rpe: set.rpe ?? 0,
            notes: sanitizedSetNotes,
            isWarmup: set.isWarmup,
            // TUT & Advanced Tracking Fields
            setDurationMillis: set.setDurationMillis,
            setStartedAt: set.setStartedAt,
            completedAt: set.completedAt,
            actualReps: set.actualReps,
          );
        }).toList();

        return ExerciseHistoryDetail(
          id: exercise.id,
          name: sanitizedExerciseName,
          category: exercise.category.name,
          notes: sanitizedExerciseNotes,
          sets: setsHistory,
          exerciseData: {
            // FIX: Preserve countingMode for bodyweight volume calculation
            'countingMode': exercise.countingMode.name,
          },
        );
      }).toList();

      final workoutHistoryDetail = WorkoutHistoryDetail(
        id: workout.id,
        userId: effectiveUserId,
        name: sanitizedWorkoutName,
        description: sanitizedWorkoutNotes,
        createdAt: workout.createdAt,
        startedAt: workout.startTime ?? workout.createdAt,
        completedAt: workout.endTime ?? DateTime.now(),
        updatedAt: workout.updatedAt,
        duration: workout.duration ?? Duration.zero,
        exercises: exercisesHistory,
        metadata: {'source': 'app_completion'},
        templateId: workout
            .templateId, // CRITICAL FIX: Pass templateId for routine auto-detection
      );

      // 2. Always save locally FIRST (blocking but fast ~50ms)
      // This guarantees data is persistent even if cloud sync fails
      // FIX CASE 3: Now saves ALWAYS, even without authenticated user
      try {
        final hiveDataSource = ref.read(hiveWorkoutDataSourceProvider);
        // Use effectiveUserId instead of FirebaseAuth check - workout ALWAYS saved locally
        final workoutModel = WorkoutModel.fromDomain(workout);
        await hiveDataSource.saveWorkout(workoutModel, effectiveUserId);

        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '✅ [WorkoutProvider] Workout saved to Hive local storage',
          );
        }

        // HISTORY: Also save to workout_history_enhanced box for history view
        // FIX: History reads from this box, not from 'workouts'
        // Without this, workout won't appear in history until Firebase sync
        // FIX: Key format MUST match repository format: workout_{userId}_{workoutId}
        // Without userId in key, repository's _getLocalWorkouts() won't find it!
        try {
          final boxManager = ref.read(hiveBoxManagerProvider);
          final historyBox = await boxManager.openBox(
            'workout_history_enhanced',
          );
          final historyKey =
              'workout_${effectiveUserId}_${workoutHistoryDetail.id}';
          await historyBox.put(historyKey, workoutHistoryDetail.toMap());

          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '✅ [WorkoutProvider] Workout saved to history box (key: $historyKey)',
            );
          }

          // FIX: Notify history provider that new workout was added
          // Without this, UI won't update until Firebase sync completes
          try {
            final historyRepo = ref.read(workoutHistoryRepositoryProvider);
            await historyRepo.notifyLocalWorkoutAdded();
          } catch (notifyError) {
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Failed to notify history: $notifyError',
              );
            }
          }
        } catch (historyBoxError) {
          // Non-critical: history will be populated from Firebase sync
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to save to history box: $historyBoxError',
            );
          }
        }

        // ANALYTICS: Update analytics collection for each exercise
        // Uses WorkoutToAnalyticsConverter utility to centralize conversion logic
        // This populates users/{userId}/analytics/{exerciseName} for efficient querying
        try {
          final analyticsRepo = ref.read(analyticsRepositoryProvider);

          // Get user body weight for bodyweight exercise volume calculation
          double? userBodyWeightKg;
          try {
            final weightMeasurements = await ref.read(
              bodyMeasurementsProvider(HealthDataType.bodyWeight).future,
            );
            if (weightMeasurements.isNotEmpty) {
              final latestWeight = weightMeasurements.first;
              userBodyWeightKg = latestWeight.unit == MeasurementUnit.pounds
                  ? latestWeight.value * 0.453592 // lbs to kg
                  : latestWeight.value;
              if (kDebugMode) {
                debugLog(
                  LogCategory.workout,
                  '📏 [WorkoutProvider] User body weight for analytics: ${userBodyWeightKg.toStringAsFixed(1)}kg',
                );
              }
            }
          } catch (weightError) {
            // Non-critical: bodyweight exercises will have volume = 0
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '⚠️ [WorkoutProvider] Could not fetch body weight: $weightError',
              );
            }
          }

          final analyticsData = WorkoutToAnalyticsConverter.convert(
            workout,
            userBodyWeightKg: userBodyWeightKg,
          );

          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '📊 [WorkoutProvider] Converting ${analyticsData.length} exercises to analytics',
            );
          }

          // Update analytics for each exercise
          for (final data in analyticsData) {
            await analyticsRepo.updateExerciseHistory(
              userId: effectiveUserId,
              exerciseId: data.exerciseId,
              exerciseName: data.exerciseName,
              muscleGroup: data.muscleGroup,
              session: data.session,
            );
          }

          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '✅ [WorkoutProvider] Analytics updated for ${analyticsData.length} exercises',
            );
          }
        } catch (analyticsError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to update analytics: $analyticsError',
            );
          }
        }

        // CACHING: Invalidate analytics cache after workout completion
        try {
          final analyticsRepo = ref.read(workoutAnalyticsRepositoryProvider);
          if (analyticsRepo is WorkoutAnalyticsRepositoryImpl) {
            await analyticsRepo.invalidateAnalyticsCache(effectiveUserId);
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🗑️ [WorkoutProvider] Analytics cache invalidated for user: $effectiveUserId',
              );
            }
          }
        } catch (cacheError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to invalidate analytics cache: $cacheError',
            );
          }
        }

        // CACHING: Clear exercise records cache for Exercise Detail Screen
        try {
          clearRecordsCache();
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '🗑️ [WorkoutProvider] Exercise records cache cleared (Exercise Detail Screen will refresh)',
            );
          }
        } catch (recordsCacheError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to clear exercise records cache: $recordsCacheError',
            );
          }
        }

        // REFRESH: Invalidate historical workouts provider so exercise
        // progress metrics are recalculated with the new workout data.
        // Without this, exerciseMetricsProvider returns stale data (null for
        // new exercises) and ExerciseDetailScreen falls back to old Firebase data.
        ref.invalidate(historicalWorkoutsProvider);

        // UI Feedback: Show "Workout saved locally" toast
        if (context != null && context.mounted) {
          SyncStatusToast.showWorkoutSavedLocally(context);
        }

        // HEALTHKIT: Export workout to Apple Fitness / Activity rings
        // This enables the workout to count toward the Exercise ring
        if (Platform.isIOS &&
            workout.startTime != null &&
            workout.endTime != null) {
          try {
            final healthRepo = ref.read(healthRepositoryProvider);
            final result = await healthRepo.writeWorkout(
              startTime: workout.startTime!,
              endTime: workout.endTime!,
              workoutName: workout.name,
            );

            result.fold(
              (failure) {
                // Write failed via repository error handling
                if (kDebugMode) {
                  debugLog(
                    LogCategory.workout,
                    '🍎 [WorkoutProvider] ⚠️ HealthKit export failed: ${failure.message}',
                  );
                }
                if (context != null && context.mounted) {
                  SyncStatusToast.showHealthKitSyncFailed(context);
                }
              },
              (success) {
                if (success) {
                  if (kDebugMode) {
                    debugLog(
                      LogCategory.workout,
                      '🍎 [WorkoutProvider] ✅ Workout exported to Apple Fitness',
                    );
                  }
                  if (context != null && context.mounted) {
                    SyncStatusToast.showHealthKitSyncSuccess(context);
                  }
                } else {
                  if (kDebugMode) {
                    debugLog(
                      LogCategory.workout,
                      '🍎 [WorkoutProvider] ⚠️ Failed to export workout to Apple Fitness',
                    );
                  }
                  if (context != null && context.mounted) {
                    SyncStatusToast.showHealthKitSyncFailed(context);
                  }
                }
              },
            );
          } catch (healthKitError) {
            // Non-critical: HealthKit export failure shouldn't affect workout save
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🍎 [WorkoutProvider] ⚠️ HealthKit export error: $healthKitError',
              );
            }
            if (context != null && context.mounted) {
              SyncStatusToast.showHealthKitSyncFailed(context);
            }
          }
        }

        // PR CELEBRATION: Check for new personal records after successful save
        // Records PRs to repository for future celebration and tracking
        bool hasNewPersonalRecords = false; // Tracked for XP bonus
        try {
          final prTracker = ref.read(prTrackerProvider);
          final prCelebrationRepo = ref.read(prCelebrationRepositoryProvider);
          final allNewPRs = <service_pr.PersonalRecord>[];

          // Check each exercise for new PRs
          for (final exercise in workout.exercises) {
            // Skip exercises with no completed sets
            if (!exercise.sets.any((s) => s.isCompleted)) continue;

            // Convert Exercise to ExerciseActivity
            final activity = ExerciseActivity.fromExercise(
              exercise: exercise,
              userEmail: currentUser?.email ?? effectiveUserId,
              workoutName: workout.name,
              workoutDate: workout.endTime ?? DateTime.now(),
            );

            // Check for PRs in this exercise
            // FIX: Pass Firebase UID for correct Firestore permissions
            final exercisePRs = await prTracker.checkAndUpdatePRs(
              activity,
              userId: effectiveUserId,
            );
            allNewPRs.addAll(exercisePRs);
          }

          if (allNewPRs.isNotEmpty) {
            hasNewPersonalRecords = true; // For XP bonus calculation
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🎉 [WorkoutProvider] ${allNewPRs.length} new PR(s) detected!',
              );
              for (final pr in allNewPRs) {
                debugLog(
                  LogCategory.workout,
                  '   - ${pr.exerciseName}: ${pr.type.name} = ${pr.value}',
                );
              }
            }

            // Record celebrations for all PRs and prepare for UI display
            final celebrations = <PRCelebration>[];

            for (final pr in allNewPRs) {
              // Convert service PR to domain PR for repository
              final domainPR = domain_pr.PersonalRecord(
                id: pr.id,
                exerciseName: pr.exerciseName,
                exerciseId: pr.exerciseId,
                type: _mapSharedPRTypeToDomain(pr.type),
                value: pr.value,
                reps: null,
                weight: null,
                achievedAt: pr.achievedAt,
                workoutId: workout.id,
              );

              // Record celebration to Firestore
              await prCelebrationRepo.recordCelebration(
                effectiveUserId,
                domainPR,
              );

              // Create PRCelebration object for UI display
              // Note: previousValue will be fetched from repository in recordCelebration
              final celebration = PRCelebration(
                id: '${effectiveUserId}_${pr.id}_${DateTime.now().millisecondsSinceEpoch}',
                userId: effectiveUserId,
                prId: pr.id,
                prType: pr.type, // Already shared PRType
                celebratedAt: DateTime.now(),
                engagement: CelebrationEngagement.viewed, // Default to viewed
                previousValue: pr.previousValue ?? 0.0,
                newValue: pr.value,
                exerciseName: pr.exerciseName,
              );

              celebrations.add(celebration);
            }

            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '✅ [WorkoutProvider] ${celebrations.length} PR celebrations recorded to Firestore',
              );
            }

            // Populate newly detected PRs for UI to display celebration modal
            ref.read(newlyDetectedPRsProvider.notifier).state = celebrations;

            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '✅ [WorkoutProvider] PR celebrations ready for UI display',
              );
            }

            // NOTIFICATIONS: Schedule PR notification for first PR in list
            // Only schedule for the first PR to avoid notification spam
            try {
              final isNotificationInitialized = ref.read(
                notificationInitializedProvider,
              );
              if (isNotificationInitialized && allNewPRs.isNotEmpty) {
                final scheduler = ref.read(notificationSchedulerProvider);
                final l10n = ref.read(appLocalizationsProvider);
                await scheduler.schedulePrNotification(
                  exerciseName: allNewPRs.first.exerciseName,
                  l10n: l10n,
                );
                if (kDebugMode) {
                  debugLog(
                    LogCategory.workout,
                    '🔔 [WorkoutProvider] PR notification scheduled for ${allNewPRs.first.exerciseName}',
                  );
                }
              }
            } catch (notificationError) {
              if (kDebugMode) {
                debugLog(
                  LogCategory.workout,
                  '⚠️ [WorkoutProvider] Failed to schedule PR notification: $notificationError',
                );
              }
            }
          } else if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              'ℹ️ [WorkoutProvider] No new PRs detected',
            );
          }
        } catch (prError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to check PR achievements: $prError',
            );
          }
        }

        // NOTIFICATIONS: Reset inactivity sequence after successful workout completion
        // This ensures user won't get inactivity reminders after completing a workout
        try {
          final isNotificationInitialized = ref.read(
            notificationInitializedProvider,
          );
          if (isNotificationInitialized) {
            final scheduler = ref.read(notificationSchedulerProvider);
            await scheduler.resetInactivitySequence();
            if (kDebugMode) {
              debugLog(
                LogCategory.workout,
                '🔔 [WorkoutProvider] Inactivity notification sequence reset',
              );
            }
          }
        } catch (notificationError) {
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to reset inactivity sequence: $notificationError',
            );
          }
        }

        // STRESS INDEX: Calculate and save training stress for this workout
        // Non-critical feature - failure won't affect workout save
        try {
          final stressNotifier = ref.read(stressIndexNotifierProvider.notifier);
          final stressResult = await stressNotifier.calculateAndSave(workout);

          if (stressResult != null && kDebugMode) {
            debugLog(
              LogCategory.workout,
              '📈 [WorkoutProvider] Stress index calculated: ${stressResult.displayScore.toStringAsFixed(0)} '
              '(${stressResult.stressLevel.name}, ${(stressResult.confidence * 100).toStringAsFixed(0)}% confidence)',
            );
          }
        } catch (stressError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to calculate stress index: $stressError',
            );
          }
        }

        // XP AWARDING: Calculate and award XP for completed workout
        // Non-critical feature - failure won't affect workout save
        try {
          // Calculate total volume (weight × reps for all completed sets)
          double totalVolume = 0;
          for (final exercise in workout.exercises) {
            for (final set in exercise.sets) {
              if (set.isCompleted) {
                final weight = double.tryParse(set.weight.toString()) ?? 0;
                final reps = int.tryParse(set.reps.toString()) ?? 0;
                totalVolume += weight * reps;
              }
            }
          }

          // Get workout duration in minutes
          final durationMinutes = workout.duration?.inMinutes ?? 0;

          // Get current streak from progress provider
          final streakAsync = ref.read(currentStreakProvider);
          final streakDays = streakAsync.value ?? 0;

          // Award XP through central provider
          final xpAwarded = await ref
              .read(userXPProvider.notifier)
              .addWorkoutXP(
                workoutId: workout.id,
                durationMinutes: durationMinutes,
                exerciseCount: workout.exercises.length,
                totalVolume: totalVolume,
                isPersonalRecord: hasNewPersonalRecords,
                streakDays: streakDays,
              );

          if (kDebugMode && xpAwarded > 0) {
            debugLog(
              LogCategory.workout,
              '🎮 [WorkoutProvider] XP awarded: +$xpAwarded XP '
              '(duration: ${durationMinutes}min, exercises: ${workout.exercises.length}, '
              'volume: ${totalVolume.toStringAsFixed(0)}kg, PR: $hasNewPersonalRecords, streak: $streakDays)',
            );
          }
        } catch (xpError) {
          // Non-critical error - log but don't fail workout save
          if (kDebugMode) {
            debugLog(
              LogCategory.workout,
              '⚠️ [WorkoutProvider] Failed to award XP: $xpError',
            );
          }
        }
      } catch (saveError, stackTrace) {
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '❌ [WorkoutProvider] CRITICAL: Failed to save workout locally: $saveError',
          );
          debugLog(
            LogCategory.workout,
            '📍 [WorkoutProvider] Stack trace: $stackTrace',
          );
        }

        // UI Feedback: Show CRITICAL error toast with retry/export options
        if (context != null && context.mounted) {
          SyncStatusToast.showLocalSaveFailed(
            context,
            onRetry: () {
              // Retry local save
              _saveCompletedWorkoutToFirestore(context);
            },
            onExport: () async {
              // Export workout data to JSON and share
              try {
                await _exportWorkoutData(workout);
                if (kDebugMode) {
                  debugLog(
                    LogCategory.workout,
                    '✅ [WorkoutProvider] Workout data exported successfully',
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  debugLog(
                    LogCategory.workout,
                    '❌ [WorkoutProvider] Failed to export workout data: $e',
                  );
                }
              }
            },
          );
        }

        // CRITICAL: If local save fails, rethrow the error
        // We cannot allow workout data to be lost
        rethrow;
      }

      // CRITICAL FIX: Check disposal after local save
      if (_isDisposed) {
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Provider disposed after local save - aborting cloud sync',
          );
        }
        return;
      }

      // FIX CASE 3: Only run Firebase operations if user is authenticated
      // Unauthenticated workouts are saved locally and will sync when user logs in
      if (!isAuthenticated) {
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Skipping cloud sync - user not authenticated',
          );
        }
        // Show success toast for local-only save
        if (context != null && context.mounted) {
          SyncStatusToast.showWorkoutCompletedWithMotivation(context);
        }
        return; // Skip all Firebase operations
      }

      // 3 & 4. Track and queue for cloud sync (extracted to WorkoutSaveCloudMixin)
      await _syncWorkoutToCloud(
        workoutHistoryDetail: workoutHistoryDetail,
        context: context,
      );

      // 5. Update user stats with transaction to prevent lost updates
      // Note: currentUser is guaranteed non-null here because of isAuthenticated check above
      await _updateUserFirestoreStats(
        userId: currentUser.uid,
        workoutHistoryDetail: workoutHistoryDetail,
      );

      // CRITICAL FIX: Check disposal after stats update
      if (_isDisposed) {
        debugLog(
          LogCategory.workout,
          '⚠️ [WorkoutProvider] Provider disposed after stats update - aborting remaining operations',
        );
        return;
      }

      // 6. Update cached progress stats
      try {
        final cacheRepo = ref.read(progressCacheRepositoryProvider);
        final workoutDate = workout.startTime ?? DateTime.now();
        final dateKey =
            '${workoutDate.year}-${workoutDate.month.toString().padLeft(2, '0')}-${workoutDate.day.toString().padLeft(2, '0')}';
        await cacheRepo.incrementWorkout(dateKey);
        ref.invalidate(cachedProgressProvider);
      } catch (cacheError) {
        ref.invalidate(cachedProgressProvider);
      }

      // 7. Navigation is handled by WorkoutScreenController (not provider)
      // Provider should not perform UI navigation (anti-pattern)
    } catch (e, stackTrace) {
      debugLog(LogCategory.workout, '❌ Critical error saving workout: $e');
      debugLog(LogCategory.workout, 'Stack: $stackTrace');
    }
  }

}
