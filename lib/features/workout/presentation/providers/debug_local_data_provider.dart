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
 * Debug provider to check local Hive data
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/unified_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';

/// Debug state for local data inspection
class LocalDataDebugState {
  final int totalWorkouts;
  final int unsyncedWorkouts;
  final List<String> workoutSummaries;
  final Map<String, dynamic> debugInfo;
  final bool isLoading;
  
  LocalDataDebugState({
    this.totalWorkouts = 0,
    this.unsyncedWorkouts = 0,
    this.workoutSummaries = const [],
    this.debugInfo = const {},
    this.isLoading = true,
  });
}

/// Debug provider to inspect local data
final localDataDebugProvider = StateNotifierProvider<LocalDataDebugNotifier, LocalDataDebugState>((ref) {
  final userProfile = ref.watch(unifiedUserProfileProvider);
  final userId = userProfile.value?.uid;
  
  return LocalDataDebugNotifier(userId);
});

class LocalDataDebugNotifier extends StateNotifier<LocalDataDebugState> {
  final String? userId;
  
  LocalDataDebugNotifier(this.userId) : super(LocalDataDebugState()) {
    if (userId != null) {
      inspectLocalData();
    }
  }
  
  Future<void> inspectLocalData() async {
    state = LocalDataDebugState(isLoading: true);
    
    try {
      final dataSource = HiveWorkoutDataSource();
      
      // Get all workouts
      final allWorkouts = await dataSource.getWorkouts(userId!);
      
      // Get unsynced workouts
      final unsyncedWorkouts = await dataSource.getUnsyncedWorkouts(userId!);
      
      // Create summaries
      final summaries = <String>[];
      final debugInfo = <String, dynamic>{};
      
      for (final workout in allWorkouts) {
        final syncStatus = workout.toJson()['syncStatus'] ?? 'unknown';
        final summary = '${workout.name} - ${workout.createdAt.toString().split(' ')[0]} - Status: ${workout.status} - Sync: $syncStatus';
        summaries.add(summary);
      }
      
      // Check raw Hive data
      final workoutsBox = await Hive.openBox<Map>('workouts');
      final userKeys = workoutsBox.keys
          .where((key) => key.toString().startsWith('${userId}_'))
          .toList();
      
      debugInfo['totalKeysInHive'] = userKeys.length;
      debugInfo['userIdUsed'] = userId;
      
      // Check if workouts have syncStatus field
      if (userKeys.isNotEmpty) {
        final firstKey = userKeys.first;
        final firstWorkout = workoutsBox.get(firstKey);
        debugInfo['sampleWorkoutFields'] = firstWorkout?.keys.toList() ?? [];
        debugInfo['sampleSyncStatus'] = firstWorkout?['syncStatus'];
        debugInfo['sampleLocalOnly'] = firstWorkout?['localOnly'];
      }
      
      // Check activities and summaries boxes
      final activitiesBox = await Hive.openBox<Map>('exercise_activities');
      final summariesBox = await Hive.openBox<Map>('workout_summaries');
      
      debugInfo['totalActivities'] = activitiesBox.length;
      debugInfo['totalSummaries'] = summariesBox.length;
      
      state = LocalDataDebugState(
        totalWorkouts: allWorkouts.length,
        unsyncedWorkouts: unsyncedWorkouts.length,
        workoutSummaries: summaries,
        debugInfo: debugInfo,
        isLoading: false,
      );
      
      // Print debug info to console
      print('🔍 LOCAL DATA DEBUG:');
      print('Total workouts: ${allWorkouts.length}');
      print('Unsynced workouts: ${unsyncedWorkouts.length}');
      print('Debug info: $debugInfo');
      
    } catch (e) {
      print('❌ Error inspecting local data: $e');
      state = LocalDataDebugState(
        isLoading: false,
        debugInfo: {'error': e.toString()},
      );
    }
  }
  
  /// Force mark all workouts as unsynced for testing
  Future<void> forceMarkAllAsUnsynced() async {
    if (userId == null) return;
    
    try {
      final workoutsBox = await Hive.openBox<Map>('workouts');
      final userKeys = workoutsBox.keys
          .where((key) => key.toString().startsWith('${userId}_'))
          .toList();
      
      for (final key in userKeys) {
        final data = workoutsBox.get(key);
        if (data != null) {
          data['syncStatus'] = 'pending';
          data['localOnly'] = true;
          await workoutsBox.put(key, data);
        }
      }
      
      print('✅ Marked ${userKeys.length} workouts as unsynced');
      await inspectLocalData(); // Refresh state
      
    } catch (e) {
      print('❌ Error marking workouts as unsynced: $e');
    }
  }
}