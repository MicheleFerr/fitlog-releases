/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Provider to recover workouts from Firestore to local storage
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// State for recovery operation
class RecoveryState {
  
  RecoveryState({
    this.isRecovering = false,
    this.workoutsFound = 0,
    this.workoutsRecovered = 0,
    this.currentOperation,
    this.error,
  });
  final bool isRecovering;
  final int workoutsFound;
  final int workoutsRecovered;
  final String? currentOperation;
  final String? error;
}

/// Provider to recover workouts from Firestore
final workoutRecoveryProvider = NotifierProvider<WorkoutRecoveryNotifier, RecoveryState>(WorkoutRecoveryNotifier.new);

class WorkoutRecoveryNotifier extends Notifier<RecoveryState> {

  @override
  RecoveryState build() {
    // Initialize dependencies
    final userProfile = ref.watch(unifiedUserProfileProvider);
    _userId = userProfile.value?.uid;
    _boxManager = ref.watch(hiveBoxManagerProvider);

    // Set up cleanup on dispose
    ref.onDispose(() {
      // MEMORY LEAK FIX: Close workouts box if opened by this provider
      if (Hive.isBoxOpen('workouts')) {
        Hive.box<Map>('workouts').close().then((_) {
          if (kDebugMode) {
            debugPrint('✅ WorkoutRecoveryNotifier: Closed workouts box');
          }
        }).catchError((e) {
          if (kDebugMode) {
            debugPrint('❌ Error closing workouts box: $e');
          }
        });
      }

      if (kDebugMode) {
        debugPrint('✅ WorkoutRecoveryNotifier disposed');
      }
    });

    return RecoveryState();
  }

  String? _userId;
  late HiveBoxManagerEnhanced _boxManager;
  final _firestore = FirebaseFirestore.instance;

  // Getter for userId (used in methods)
  String? get userId => _userId;
  
  /// Clear all local workouts before recovery
  Future<void> clearLocalWorkouts() async {
    if (userId == null) return;

    try {
      final box = await _boxManager.openBox<Map>(HiveBoxNames.workouts);
      
      // Remove all workouts for this user
      final keysToRemove = box.keys
          .where((key) => key.toString().startsWith('${userId}_'))
          .toList();
      
      for (final key in keysToRemove) {
        await box.delete(key);
      }
      
      debugPrint('🗑️ Cleared ${keysToRemove.length} local workouts');
    } catch (e) {
      debugPrint('❌ Failed to clear local workouts: $e');
    }
  }
  
  /// ✅ MIGRATED: Recover all workouts from Firestore 'workouts' collection to local storage
  /// Much simpler now - workouts are already complete, no need to reconstruct!
  Future<void> recoverWorkoutsFromCloud() async {
    if (state.isRecovering || userId == null) return;

    state = RecoveryState(
      isRecovering: true,
      currentOperation: 'Clearing old data...',
    );

    // Clear existing local workouts first
    await clearLocalWorkouts();

    state = RecoveryState(
      isRecovering: true,
      currentOperation: 'Connecting to Firestore...',
    );

    try {
      debugPrint('🔄 [MIGRATED] Starting recovery for user: $userId');

      // ✅ MIGRATED: Read from 'workouts' collection instead of exerciseActivities
      state = RecoveryState(
        isRecovering: true,
        currentOperation: 'Fetching workout data...',
      );

      debugPrint('🔍 [MIGRATED] Querying users/$userId/workouts collection');
      final workoutsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      debugPrint('📦 Found ${workoutsQuery.docs.length} complete workouts');

      state = RecoveryState(
        isRecovering: true,
        workoutsFound: workoutsQuery.docs.length,
        currentOperation: 'Saving workouts...',
      );

      // ✅ SIMPLIFIED: No need to reconstruct - workouts are already complete!
      final localDataSource = HiveWorkoutDataSource(_boxManager);
      int recovered = 0;

      for (final doc in workoutsQuery.docs) {
        try {
          final data = doc.data();

          // Parse workout directly from Firestore
          final workout = WorkoutModel.fromJson(data);

          // Save to local storage
          await localDataSource.saveWorkout(workout, userId!);
          recovered++;

          state = RecoveryState(
            isRecovering: true,
            workoutsRecovered: recovered,
            workoutsFound: workoutsQuery.docs.length,
            currentOperation: 'Recovered $recovered/${workoutsQuery.docs.length} workouts',
          );

          debugPrint('✅ Recovered workout: ${workout.name}');
        } catch (e) {
          debugPrint('⚠️ Failed to recover workout: $e');
          // Continue with next workout
        }
      }

      state = RecoveryState(
        isRecovering: false,
        workoutsFound: workoutsQuery.docs.length,
        workoutsRecovered: recovered,
        currentOperation: 'Recovery complete!',
      );

      debugPrint('🎉 Recovery complete: $recovered workouts recovered');

    } catch (e) {
      debugPrint('❌ Recovery failed: $e');
      state = RecoveryState(
        isRecovering: false,
        error: e.toString(),
      );
    }
  }
  
  /// Reconstruct a workout from exercise activities
  WorkoutModel? _reconstructWorkoutFromActivities({
    required String workoutId,
    required List<QueryDocumentSnapshot> activities,
  }) {
    try {
      if (activities.isEmpty) return null;
      
      // Get first activity for metadata
      final firstActivity = activities.first.data() as Map<String, dynamic>;
      
      // Use 'createdAt' field for actual workout date
      DateTime workoutDate;
      
      // First check if createdAt exists and is valid
      if (firstActivity['createdAt'] != null) {
        try {
          if (firstActivity['createdAt'] is Timestamp) {
            workoutDate = (firstActivity['createdAt'] as Timestamp).toDate();
            debugPrint('📅 Using createdAt from Timestamp: $workoutDate');
          } else if (firstActivity['createdAt'] is String) {
            workoutDate = DateTime.parse(firstActivity['createdAt'] as String);
            debugPrint('📅 Using createdAt from String: $workoutDate');
          } else {
            // Fallback to current date if format unknown
            workoutDate = DateTime.now();
            debugPrint('⚠️ Unknown createdAt format, using current date');
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing createdAt: $e');
          workoutDate = DateTime.now();
        }
      } else {
        // No createdAt field found, use current date
        workoutDate = DateTime.now();
        debugPrint('⚠️ No createdAt field found, using current date');
      }
      
      final workoutName = firstActivity['workoutName'] ?? 'Recovered Workout';
      
      // Create exercises from activities
      final exercises = <ExerciseModel>[];
      
      for (final activityDoc in activities) {
        final data = activityDoc.data() as Map<String, dynamic>;
        
        // Create sets from activity data
        final sets = <ExerciseSetModel>[];
        final activitySets = data['sets'] as List<dynamic>? ?? [];
        
        for (int i = 0; i < activitySets.length; i++) {
          final setData = activitySets[i] as Map<String, dynamic>;
          sets.add(ExerciseSetModel(
            id: '${data['exerciseId']}_set_${i + 1}',
            setNumber: i + 1,
            reps: int.tryParse(setData['reps']?.toString() ?? '0') ?? 0,
            weight: double.tryParse(setData['weight']?.toString() ?? '0') ?? 0,
            volume: 0, // Will be calculated
            isCompleted: setData['done'] ?? false,
            restTime: 90, // Default rest
            rpe: setData['rpe'] != null ? int.tryParse(setData['rpe'].toString()) : null,
            notes: setData['notes'],
            completedAt: null,
          ));
        }
        
        // Calculate total volume for the exercise
        double totalVolume = 0;
        for (final set in sets) {
          if (set.isCompleted) {
            final volume = ((set.weight ?? 0.0) * (set.reps ?? 0)).toDouble();
            totalVolume += volume;
            // Update set volume
            sets[sets.indexOf(set)] = ExerciseSetModel(
              id: set.id,
              setNumber: set.setNumber,
              reps: set.reps,
              weight: set.weight,
              volume: volume,
              isCompleted: set.isCompleted,
              restTime: set.restTime,
              rpe: set.rpe,
              notes: set.notes,
              completedAt: set.completedAt,
            );
          }
        }
        
        exercises.add(ExerciseModel(
          id: data['exerciseId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: data['exerciseName'] ?? 'Unknown Exercise',
          type: 'single', // Default type
          category: data['category'] ?? 'chest', // Default category
          sets: sets,
          restTime: 90,
          notes: data['notes'],
          isCompleted: sets.any((s) => s.isCompleted),
          totalVolume: totalVolume,
          completedAt: sets.any((s) => s.isCompleted) ? workoutDate : null,
          createdAt: workoutDate,
        ));
      }
      
      // Return the reconstructed workout
      return WorkoutModel(
        id: workoutId,
        name: workoutName,
        exercises: exercises,
        status: 'completed',
        startTime: workoutDate,
        endTime: workoutDate.add(const Duration(hours: 1)), // Estimate 1 hour workout
        notes: 'Recovered from cloud',
        createdAt: workoutDate,
        updatedAt: workoutDate, // Use same date to preserve historical accuracy
      );
      
    } catch (e) {
      debugPrint('Failed to reconstruct workout: $e');
      return null;
    }
  }

}