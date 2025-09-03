/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/providers
 * 🎯 Feature: settings
 * 🔧 Type: provider (cloud sync management)
 * 
 * Handles syncing user data from cloud to local device
 * Essential for premium users with multiple devices
 */

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';

/// Cloud sync state
class CloudSyncState {
  final bool isSyncing;
  final String? lastSyncTime;
  final SyncProgress? progress;
  final List<String> errors;
  final SyncSummary? lastSyncSummary;
  
  const CloudSyncState({
    this.isSyncing = false,
    this.lastSyncTime,
    this.progress,
    this.errors = const [],
    this.lastSyncSummary,
  });
  
  CloudSyncState copyWith({
    bool? isSyncing,
    String? lastSyncTime,
    SyncProgress? progress,
    List<String>? errors,
    SyncSummary? lastSyncSummary,
  }) {
    return CloudSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      progress: progress ?? this.progress,
      errors: errors ?? this.errors,
      lastSyncSummary: lastSyncSummary ?? this.lastSyncSummary,
    );
  }
}

/// Sync progress tracking
class SyncProgress {
  final String currentItem;
  final int totalItems;
  final int syncedItems;
  final double percentage;
  
  SyncProgress({
    required this.currentItem,
    required this.totalItems,
    required this.syncedItems,
  }) : percentage = totalItems > 0 ? (syncedItems / totalItems) * 100 : 0;
}

/// Sync summary
class SyncSummary {
  final int workoutsSynced;
  final int templatesSynced;
  final int exercisesSynced;
  final int settingsSynced;
  final int personalRecordsSynced;
  final DateTime syncedAt;
  final bool success;
  
  SyncSummary({
    required this.workoutsSynced,
    required this.templatesSynced,
    required this.exercisesSynced,
    required this.settingsSynced,
    required this.personalRecordsSynced,
    required this.syncedAt,
    required this.success,
  });
  
  int get totalItemsSynced => 
      workoutsSynced + templatesSynced + exercisesSynced + settingsSynced + personalRecordsSynced;
}

/// Cloud sync provider
class CloudSyncNotifier extends StateNotifier<CloudSyncState> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  CloudSyncNotifier(this._ref) : super(const CloudSyncState()) {
    _loadLastSyncTime();
  }
  
  /// Load last sync time from local storage
  Future<void> _loadLastSyncTime() async {
    try {
      final box = await Hive.openBox('sync_preferences');
      final lastSync = box.get('last_cloud_sync_time');
      if (lastSync != null) {
        state = state.copyWith(lastSyncTime: lastSync);
      }
    } catch (e) {
      debugPrint('Failed to load last sync time: $e');
    }
  }
  
  /// Save last sync time to local storage
  Future<void> _saveLastSyncTime(String time) async {
    try {
      final box = await Hive.openBox('sync_preferences');
      await box.put('last_cloud_sync_time', time);
    } catch (e) {
      debugPrint('Failed to save last sync time: $e');
    }
  }
  
  /// Sync all user data from cloud to local device
  Future<void> syncFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = state.copyWith(
        errors: ['User not authenticated'],
      );
      return;
    }
    
    state = state.copyWith(
      isSyncing: true,
      errors: [],
      progress: null,
    );
    
    try {
      debugPrint('🔄 Starting cloud sync for user: ${user.email}');
      
      int workoutsSynced = 0;
      int templatesSynced = 0;
      int exercisesSynced = 0;
      int settingsSynced = 0;
      int personalRecordsSynced = 0;
      
      // 1. Sync Workouts
      state = state.copyWith(
        progress: SyncProgress(
          currentItem: 'Syncing workouts...',
          totalItems: 100,
          syncedItems: 0,
        ),
      );
      workoutsSynced = await _syncWorkouts(user.uid);
      
      // 2. Sync Templates
      state = state.copyWith(
        progress: SyncProgress(
          currentItem: 'Syncing templates...',
          totalItems: 100,
          syncedItems: 20,
        ),
      );
      templatesSynced = await _syncTemplates(user.uid);
      
      // 3. Sync Custom Exercises
      state = state.copyWith(
        progress: SyncProgress(
          currentItem: 'Syncing exercises...',
          totalItems: 100,
          syncedItems: 40,
        ),
      );
      exercisesSynced = await _syncExercises(user.uid);
      
      // 4. Sync Personal Records
      state = state.copyWith(
        progress: SyncProgress(
          currentItem: 'Syncing personal records...',
          totalItems: 100,
          syncedItems: 60,
        ),
      );
      personalRecordsSynced = await _syncPersonalRecords(user.uid);
      
      // 5. Sync User Settings/Profile
      state = state.copyWith(
        progress: SyncProgress(
          currentItem: 'Syncing settings...',
          totalItems: 100,
          syncedItems: 80,
        ),
      );
      settingsSynced = await _syncUserSettings(user.uid);
      
      // Create summary
      final summary = SyncSummary(
        workoutsSynced: workoutsSynced,
        templatesSynced: templatesSynced,
        exercisesSynced: exercisesSynced,
        settingsSynced: settingsSynced,
        personalRecordsSynced: personalRecordsSynced,
        syncedAt: DateTime.now(),
        success: true,
      );
      
      // Save sync time
      final syncTime = DateTime.now().toIso8601String();
      await _saveLastSyncTime(syncTime);
      
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: syncTime,
        lastSyncSummary: summary,
        progress: SyncProgress(
          currentItem: 'Sync complete!',
          totalItems: 100,
          syncedItems: 100,
        ),
      );
      
      debugPrint('✅ Cloud sync complete: ${summary.totalItemsSynced} items synced');
      
    } catch (e) {
      debugPrint('❌ Cloud sync failed: $e');
      state = state.copyWith(
        isSyncing: false,
        errors: ['Sync failed: $e'],
      );
    }
  }
  
  /// Sync workouts from Firestore to local
  Future<int> _syncWorkouts(String userId) async {
    try {
      final box = await Hive.openBox<Map>('workouts_data');
      
      // Get workouts from Firestore
      final snapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(500) // Limit to prevent memory issues
          .get();
      
      debugPrint('📥 Found ${snapshot.docs.length} workouts in cloud');
      
      int synced = 0;
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id; // Ensure ID is included
        
        // Convert Timestamps to ISO strings for Hive storage
        _convertTimestampsToStrings(data);
        
        // Save to local storage
        final key = '${userId}_${doc.id}';
        await box.put(key, data);
        synced++;
        
        // Update progress
        if (synced % 10 == 0) {
          state = state.copyWith(
            progress: SyncProgress(
              currentItem: 'Syncing workouts... ($synced/${snapshot.docs.length})',
              totalItems: snapshot.docs.length,
              syncedItems: synced,
            ),
          );
        }
      }
      
      debugPrint('✅ Synced $synced workouts to local storage');
      return synced;
      
    } catch (e) {
      debugPrint('❌ Failed to sync workouts: $e');
      return 0;
    }
  }
  
  /// Sync templates from Firestore to local
  Future<int> _syncTemplates(String userId) async {
    try {
      final box = await Hive.openBox<Map>('templates_data');
      
      // Get user's templates
      final snapshot = await _firestore
          .collection('templates')
          .where('userId', isEqualTo: userId)
          .get();
      
      // Also get public templates
      final publicSnapshot = await _firestore
          .collection('templates')
          .where('isPublic', isEqualTo: true)
          .limit(100)
          .get();
      
      final allTemplates = [...snapshot.docs, ...publicSnapshot.docs];
      debugPrint('📥 Found ${allTemplates.length} templates in cloud');
      
      int synced = 0;
      for (final doc in allTemplates) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        
        // Convert Timestamps to ISO strings for Hive storage
        _convertTimestampsToStrings(data);
        
        // Save to local storage
        final key = doc.id;
        await box.put(key, data);
        synced++;
      }
      
      debugPrint('✅ Synced $synced templates to local storage');
      return synced;
      
    } catch (e) {
      debugPrint('❌ Failed to sync templates: $e');
      return 0;
    }
  }
  
  /// Sync custom exercises from Firestore to local
  Future<int> _syncExercises(String userId) async {
    try {
      final box = await Hive.openBox<Map>('exercises_data');
      
      // Get user's custom exercises
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('customExercises')
          .get();
      
      debugPrint('📥 Found ${snapshot.docs.length} custom exercises in cloud');
      
      int synced = 0;
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        
        // Convert Timestamps to ISO strings for Hive storage (recursive)
        _convertTimestampsToStrings(data);
        
        // Save to local storage
        final key = '${userId}_${doc.id}';
        await box.put(key, data);
        synced++;
      }
      
      debugPrint('✅ Synced $synced exercises to local storage');
      return synced;
      
    } catch (e) {
      debugPrint('❌ Failed to sync exercises: $e');
      return 0;
    }
  }
  
  /// Sync personal records from Firestore to local
  Future<int> _syncPersonalRecords(String userId) async {
    try {
      final box = await Hive.openBox<Map>('personal_records_data');
      
      // Get user's PRs
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('personalRecords')
          .get();
      
      debugPrint('📥 Found ${snapshot.docs.length} personal records in cloud');
      
      int synced = 0;
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        
        // Convert Timestamps to ISO strings for Hive storage (recursive)
        _convertTimestampsToStrings(data);
        
        // Save to local storage
        final key = '${userId}_${doc.id}';
        await box.put(key, data);
        synced++;
      }
      
      debugPrint('✅ Synced $synced personal records to local storage');
      return synced;
      
    } catch (e) {
      debugPrint('❌ Failed to sync personal records: $e');
      return 0;
    }
  }
  
  /// Sync user settings from Firestore to local
  Future<int> _syncUserSettings(String userId) async {
    try {
      // Get user profile
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        
        // Convert all Timestamps to ISO strings before saving to Hive
        final profileData = Map<String, dynamic>.from(data);
        _convertTimestampsToStrings(profileData);
        
        // Save profile to local cache
        final profileBox = await Hive.openBox<Map>('user_profile_cache');
        await profileBox.put('profile', {
          'profile': profileData,
          'cacheTime': DateTime.now().toIso8601String(),
        });
        
        // Save settings if present
        if (data['settings'] != null) {
          final settingsBox = await Hive.openBox('app_settings');
          final settings = data['settings'] as Map<String, dynamic>;
          
          // Save each setting
          for (final entry in settings.entries) {
            await settingsBox.put(entry.key, entry.value);
          }
        }
        
        debugPrint('✅ Synced user settings and profile');
        return 1;
      }
      
      return 0;
      
    } catch (e) {
      debugPrint('❌ Failed to sync user settings: $e');
      return 0;
    }
  }
  
  /// Clear all local data (useful before fresh sync)
  Future<void> clearLocalData() async {
    try {
      debugPrint('🗑️ Clearing local data...');
      
      // Clear workout data
      final workoutsBox = await Hive.openBox<Map>('workouts_data');
      await workoutsBox.clear();
      
      // Clear templates
      final templatesBox = await Hive.openBox<Map>('templates_data');
      await templatesBox.clear();
      
      // Clear exercises
      final exercisesBox = await Hive.openBox<Map>('exercises_data');
      await exercisesBox.clear();
      
      // Clear personal records
      final prsBox = await Hive.openBox<Map>('personal_records_data');
      await prsBox.clear();
      
      debugPrint('✅ Local data cleared');
      
    } catch (e) {
      debugPrint('❌ Failed to clear local data: $e');
    }
  }
  
  /// Check if user can sync (premium or admin)
  bool get canSync {
    final profileAsync = _ref.read(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    if (profile == null) return false;
    
    // Admin always can sync
    if (profile.email.contains('michele.cozzolino93@gmail.com') ||
        profile.email.contains('admin@')) {
      return true;
    }
    
    // Premium users can sync
    return profile.isPremium;
  }
  
  /// Get sync status message
  String getSyncStatusMessage() {
    if (state.isSyncing) {
      return state.progress?.currentItem ?? 'Syncing...';
    }
    
    if (state.lastSyncTime != null) {
      final lastSync = DateTime.parse(state.lastSyncTime!);
      final diff = DateTime.now().difference(lastSync);
      
      if (diff.inMinutes < 1) {
        return 'Synced just now';
      } else if (diff.inHours < 1) {
        return 'Synced ${diff.inMinutes} minutes ago';
      } else if (diff.inDays < 1) {
        return 'Synced ${diff.inHours} hours ago';
      } else {
        return 'Synced ${diff.inDays} days ago';
      }
    }
    
    return 'Never synced';
  }
  
  /// Convert all Timestamp fields to ISO strings recursively
  void _convertTimestampsToStrings(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value is Timestamp) {
        data[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        // Recursively convert nested maps
        final nestedMap = Map<String, dynamic>.from(value);
        _convertTimestampsToStrings(nestedMap);
        data[key] = nestedMap;
      } else if (value is List) {
        // Handle lists that might contain maps with Timestamps
        data[key] = value.map((item) {
          if (item is Map) {
            final itemMap = Map<String, dynamic>.from(item);
            _convertTimestampsToStrings(itemMap);
            return itemMap;
          }
          return item;
        }).toList();
      }
    });
  }
}

/// Cloud sync provider
final cloudSyncProvider = StateNotifierProvider<CloudSyncNotifier, CloudSyncState>((ref) {
  return CloudSyncNotifier(ref);
});

/// Check if user can sync
final canSyncProvider = Provider<bool>((ref) {
  final syncNotifier = ref.read(cloudSyncProvider.notifier);
  return syncNotifier.canSync;
});

/// Get sync status message
final syncStatusMessageProvider = Provider<String>((ref) {
  final syncNotifier = ref.read(cloudSyncProvider.notifier);
  return syncNotifier.getSyncStatusMessage();
});