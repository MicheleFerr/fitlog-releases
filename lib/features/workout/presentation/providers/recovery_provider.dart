/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/providers
 * 🎯 Feature: workout
 * 🔧 Type: provider
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Provider to recover workouts from Firestore to local storage
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/unified_user_provider.dart';
import 'package:flutter/foundation.dart';

/// State for recovery operation
class RecoveryState {
  final bool isRecovering;
  final int workoutsFound;
  final int workoutsRecovered;
  final String? currentOperation;
  final String? error;
  
  RecoveryState({
    this.isRecovering = false,
    this.workoutsFound = 0,
    this.workoutsRecovered = 0,
    this.currentOperation,
    this.error,
  });
}

/// Provider to recover workouts from Firestore
final workoutRecoveryProvider = StateNotifierProvider<WorkoutRecoveryNotifier, RecoveryState>((ref) {
  final userProfile = ref.watch(unifiedUserProfileProvider);
  final userId = userProfile.value?.uid;
  
  return WorkoutRecoveryNotifier(userId);
});

class WorkoutRecoveryNotifier extends StateNotifier<RecoveryState> {
  final String? userId;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  WorkoutRecoveryNotifier(this.userId) : super(RecoveryState());
  
  /// Clear all local workouts before recovery
  Future<void> clearLocalWorkouts() async {
    if (userId == null) return;
    
    try {
      final localDataSource = HiveWorkoutDataSource();
      final box = await Hive.openBox<Map>('workouts');
      
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
  
  /// Recover all workouts from Firestore to local storage
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
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) {
        throw Exception('User not authenticated');
      }
      
      debugPrint('🔄 Starting recovery for user: $userEmail (uid: $userId)');
      debugPrint('📧 Searching with email: ${userEmail.toLowerCase().trim()}');
      
      // 1. Try to fetch from exercise_activities collection (newer format)
      state = RecoveryState(
        isRecovering: true,
        currentOperation: 'Fetching workout data...',
      );
      
      // First try exerciseActivities (correct collection name)
      // Order by createdAt to avoid index requirement
      List<QueryDocumentSnapshot> allActivities = [];
      
      // Try with exact email match first
      debugPrint('🔍 Querying with email field = $userEmail');
      final activitiesQuery = await _firestore
          .collection('exerciseActivities')
          .where('email', isEqualTo: userEmail)
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();
      
      debugPrint('📦 Found ${activitiesQuery.docs.length} exercise activities with email field');
      allActivities.addAll(activitiesQuery.docs);
      
      // If no results, try with userEmail field
      if (allActivities.isEmpty) {
        debugPrint('🔍 Trying with userEmail field = $userEmail');
        final altQuery = await _firestore
            .collection('exerciseActivities')
            .where('userEmail', isEqualTo: userEmail)
            .orderBy('createdAt', descending: true)
            .limit(500)
            .get();
        
        debugPrint('📦 Found ${altQuery.docs.length} activities with userEmail field');
        allActivities.addAll(altQuery.docs);
      }
      
      // If still no results, try without email filter to debug
      if (allActivities.isEmpty) {
        debugPrint('⚠️ No activities found for user. Checking if collection has data...');
        final sampleQuery = await _firestore
            .collection('exerciseActivities')
            .limit(5)
            .get();
        
        debugPrint('📊 Collection has ${sampleQuery.docs.length} sample documents');
        if (sampleQuery.docs.isNotEmpty) {
          final sampleDoc = sampleQuery.docs.first.data() as Map<String, dynamic>;
          debugPrint('📄 Sample document fields: ${sampleDoc.keys.join(', ')}');
          if (sampleDoc.containsKey('email')) {
            debugPrint('📧 Sample email value: ${sampleDoc['email']}');
          }
          if (sampleDoc.containsKey('userEmail')) {
            debugPrint('📧 Sample userEmail value: ${sampleDoc['userEmail']}');
          }
        }
      }
      
      state = RecoveryState(
        isRecovering: true,
        workoutsFound: allActivities.length,
        currentOperation: 'Processing activities...',
      );
      
      // 2. Group activities by workout
      final workoutGroups = <String, List<QueryDocumentSnapshot>>{};
      
      for (final doc in allActivities) {
        final data = doc.data() as Map<String, dynamic>;
        final workoutId = data['workoutId'] ?? 
                         data['workoutName']?.replaceAll(' ', '_') ?? 
                         'workout_${data['createdAt']?.toDate().millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';
        
        if (!workoutGroups.containsKey(workoutId)) {
          workoutGroups[workoutId] = [];
        }
        workoutGroups[workoutId]!.add(doc);
      }
      
      debugPrint('📊 Grouped into ${workoutGroups.length} workouts');
      
      // 3. Reconstruct and save workouts
      final localDataSource = HiveWorkoutDataSource();
      int recovered = 0;
      
      for (final entry in workoutGroups.entries) {
        try {
          final workoutId = entry.key;
          final activities = entry.value;
          
          // Reconstruct workout from activities
          final workout = _reconstructWorkoutFromActivities(
            workoutId: workoutId,
            activities: activities,
          );
          
          if (workout != null) {
            // Save to local storage
            await localDataSource.saveWorkout(workout, userId!);
            recovered++;
            
            state = RecoveryState(
              isRecovering: true,
              workoutsRecovered: recovered,
              workoutsFound: workoutGroups.length,
              currentOperation: 'Recovered $recovered/${workoutGroups.length} workouts',
            );
            
            debugPrint('✅ Recovered workout: ${workout.name}');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to recover workout: $e');
          // Continue with next workout
        }
      }
      
      state = RecoveryState(
        isRecovering: false,
        workoutsFound: workoutGroups.length,
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
            final volume = set.weight * set.reps;
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