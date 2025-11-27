/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/datasources
/// 🎯 Feature: workout
/// 🔧 Type: utility
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Utility to fix sync status for existing workouts
library;

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

class SyncStatusFixer {
  static const String _workoutsBoxName = 'workouts';

  /// Fix all workouts to have proper sync status
  static Future<int> fixAllWorkoutsSyncStatus(String userId, {HiveBoxManagerEnhanced? boxManager}) async {
    final manager = boxManager ?? HiveBoxManagerEnhanced();
    final box = await manager.openBox<Map>(_workoutsBoxName);
    
    final userKeys = box.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .toList();
    
    int fixedCount = 0;
    
    for (final key in userKeys) {
      final data = box.get(key);
      if (data != null) {
        // Check if syncStatus is missing or if it's marked as 'synced' but shouldn't be
        final currentSyncStatus = data['syncStatus'];
        final hasCloudId = data['cloudId'] != null;
        
        if (currentSyncStatus == null || 
            (currentSyncStatus == 'synced' && !hasCloudId) ||
            data['localOnly'] == true) {
          // Mark as pending sync
          data['syncStatus'] = 'pending';
          data['localOnly'] = true;
          data['localLastModified'] = DateTime.now().toIso8601String();
          
          await box.put(key, data);
          fixedCount++;
          
          if (kDebugMode) {
            debugPrint('Fixed workout: $key - set syncStatus to pending');
          }
        }
      }
    }
    
    if (kDebugMode) {
      debugPrint('✅ Fixed $fixedCount workouts out of ${userKeys.length} total');
    }
    return fixedCount;
  }
  
  /// Get stats about current sync status
  static Future<Map<String, int>> getSyncStats(String userId, {HiveBoxManagerEnhanced? boxManager}) async {
    final manager = boxManager ?? HiveBoxManagerEnhanced();
    final box = await manager.openBox<Map>(_workoutsBoxName);
    
    final userKeys = box.keys
        .where((key) => key.toString().startsWith('${userId}_'))
        .toList();
    
    int pending = 0;
    int synced = 0;
    int noStatus = 0;
    int localOnly = 0;
    
    for (final key in userKeys) {
      final data = box.get(key);
      if (data != null) {
        final syncStatus = data['syncStatus'];
        
        if (syncStatus == 'pending') {
          pending++;
        } else if (syncStatus == 'synced') synced++;
        else noStatus++;
        
        if (data['localOnly'] == true) localOnly++;
      }
    }
    
    return {
      'total': userKeys.length,
      'pending': pending,
      'synced': synced,
      'noStatus': noStatus,
      'localOnly': localOnly,
    };
  }

  /// MEMORY LEAK FIX: Close workouts box to free memory
  /// Note: This utility opens boxes in static methods.
  /// Call this when utility is no longer needed (e.g., app shutdown)
  static Future<void> dispose() async {
    try {
      if (Hive.isBoxOpen(_workoutsBoxName)) {
        await Hive.box<Map>(_workoutsBoxName).close();
        if (kDebugMode) {
          debugPrint('✅ SyncStatusFixer: Closed workouts box');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing SyncStatusFixer: $e');
      }
    }
  }
}