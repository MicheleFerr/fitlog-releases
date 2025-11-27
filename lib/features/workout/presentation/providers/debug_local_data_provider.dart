/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Debug provider to check local Hive data
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// Debug state for local data inspection
class LocalDataDebugState {
  
  LocalDataDebugState({
    this.totalWorkouts = 0,
    this.unsyncedWorkouts = 0,
    this.workoutSummaries = const [],
    this.debugInfo = const {},
    this.isLoading = true,
  });
  final int totalWorkouts;
  final int unsyncedWorkouts;
  final List<String> workoutSummaries;
  final Map<String, dynamic> debugInfo;
  final bool isLoading;
}

/// Debug provider to inspect local data
final localDataDebugProvider = NotifierProvider<LocalDataDebugNotifier, LocalDataDebugState>(LocalDataDebugNotifier.new);

class LocalDataDebugNotifier extends Notifier<LocalDataDebugState> {

  @override
  LocalDataDebugState build() {
    // Initialize dependencies
    final userProfile = ref.watch(unifiedUserProfileProvider);
    _userId = userProfile.value?.uid;
    _boxManager = ref.watch(hiveBoxManagerProvider);

    // Set up cleanup on dispose
    ref.onDispose(() {
      // MEMORY LEAK FIX: Close all Hive boxes opened by this provider
      final boxesToClose = [HiveBoxNames.workouts, HiveBoxNames.exerciseActivities, HiveBoxNames.workoutSummaries];

      for (final boxName in boxesToClose) {
        if (Hive.isBoxOpen(boxName)) {
          Hive.box<Map>(boxName).close().then((_) {
            if (kDebugMode) {
              debugPrint('✅ DebugLocalDataNotifier: Closed $boxName box');
            }
          }).catchError((e) {
            if (kDebugMode) {
              debugPrint('❌ Error closing $boxName box: $e');
            }
          });
        }
      }

      if (kDebugMode) {
        debugPrint('✅ DebugLocalDataNotifier disposed');
      }
    });

    if (_userId != null) {
      inspectLocalData();
    }

    return LocalDataDebugState();
  }

  String? _userId;
  late HiveBoxManagerEnhanced _boxManager;

  // Getter for userId (used in methods)
  String? get userId => _userId;
  
  Future<void> inspectLocalData() async {
    state = LocalDataDebugState(isLoading: true);

    try {
      final dataSource = HiveWorkoutDataSource(_boxManager);
      
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
      final workoutsBox = await _boxManager.openBox<Map>(HiveBoxNames.workouts);
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
      final activitiesBox = await _boxManager.openBox<Map>(HiveBoxNames.exerciseActivities);
      final summariesBox = await _boxManager.openBox<Map>(HiveBoxNames.workoutSummaries);
      
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
      if (kDebugMode) {
        debugPrint('🔍 LOCAL DATA DEBUG:');
      }
      if (kDebugMode) {
        debugPrint('Total workouts: ${allWorkouts.length}');
      }
      if (kDebugMode) {
        debugPrint('Unsynced workouts: ${unsyncedWorkouts.length}');
      }
      if (kDebugMode) {
        debugPrint('Debug info: $debugInfo');
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error inspecting local data: $e');
      }
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
      final workoutsBox = await _boxManager.openBox<Map>(HiveBoxNames.workouts);
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
      
      if (kDebugMode) {
        debugPrint('✅ Marked ${userKeys.length} workouts as unsynced');
      }
      await inspectLocalData(); // Refresh state
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error marking workouts as unsynced: $e');
      }
    }
  }
}