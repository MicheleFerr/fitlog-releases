/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/repositories
/// 🎯 Feature: analytics
/// 🔧 Type: repository (LOCAL FIRST)
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: iOS/Android/Universal
/// 
/// 💰 COST OPTIMIZATION: Local-first with periodic sync
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SkipAnalyticsLocalRepository {
  static const String _boxName = 'skip_analytics';
  static const String _pendingSkipsKey = 'pending_skips';
  static const String _localAnalyticsKey = 'local_analytics';
  static const String _lastSyncKey = 'last_sync';
  
  late Box _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Sync threshold - sync to Firebase after X skips or Y hours
  static const int _syncAfterSkips = 10;
  static const Duration _syncInterval = Duration(hours: 24);
  
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }
  
  // 📱 LOCAL SAVE (Immediate, no cost)
  Future<void> saveSkipLocally({
    required String exerciseName,
    required String reason,
    required DateTime timestamp,
  }) async {
    try {
      // Get pending skips
      final pendingSkips = _getPendingSkips();
      
      // Add new skip
      pendingSkips.add({
        'exerciseName': exerciseName,
        'reason': reason,
        'timestamp': timestamp.toIso8601String(),
        'hour': timestamp.hour,
        'dayOfWeek': timestamp.weekday,
      });
      
      // Save to local storage
      await _box.put(_pendingSkipsKey, pendingSkips);
      
      // Update local analytics immediately
      await _updateLocalAnalytics(exerciseName, reason, timestamp);
      
      // Check if we should sync
      if (await _shouldSync(pendingSkips.length)) {
        await syncToFirebase();
      }
      
      if (kDebugMode) {
        debugPrint('📱 Skip saved locally. Pending: ${pendingSkips.length}');
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving skip locally: $e');
      }
    }
  }
  
  // 📊 UPDATE LOCAL ANALYTICS (for immediate UI updates)
  Future<void> _updateLocalAnalytics(
    String exerciseName, 
    String reason,
    DateTime timestamp,
  ) async {
    final analytics = getLocalAnalytics();
    
    // Update reason counts
    analytics['reasonCounts'] ??= {};
    analytics['reasonCounts'][reason] = 
        (analytics['reasonCounts'][reason] ?? 0) + 1;
    
    // Update exercise counts
    analytics['exerciseCounts'] ??= {};
    analytics['exerciseCounts'][exerciseName] = 
        (analytics['exerciseCounts'][exerciseName] ?? 0) + 1;
    
    // Update time patterns
    final hour = timestamp.hour.toString();
    analytics['hourlyPatterns'] ??= {};
    analytics['hourlyPatterns'][hour] ??= {};
    analytics['hourlyPatterns'][hour][reason] = 
        (analytics['hourlyPatterns'][hour][reason] ?? 0) + 1;
    
    // Update day patterns
    final day = timestamp.weekday.toString();
    analytics['dayPatterns'] ??= {};
    analytics['dayPatterns'][day] ??= {};
    analytics['dayPatterns'][day][reason] = 
        (analytics['dayPatterns'][day][reason] ?? 0) + 1;
    
    // Update totals
    analytics['totalSkips'] = (analytics['totalSkips'] ?? 0) + 1;
    analytics['lastSkipDate'] = timestamp.toIso8601String();
    
    await _box.put(_localAnalyticsKey, analytics);
  }
  
  // 🔄 CHECK IF SYNC NEEDED
  Future<bool> _shouldSync(int pendingCount) async {
    // Sync if we have enough pending skips
    if (pendingCount >= _syncAfterSkips) return true;
    
    // Sync if enough time has passed
    final lastSync = _box.get(_lastSyncKey);
    if (lastSync == null) return true;
    
    final lastSyncDate = DateTime.parse(lastSync);
    final timeSinceSync = DateTime.now().difference(lastSyncDate);
    
    return timeSinceSync > _syncInterval;
  }
  
  // ☁️ SYNC TO FIREBASE (Batch operation, cost-efficient)
  Future<void> syncToFirebase({String? userId}) async {
    try {
      if (userId == null) {
        if (kDebugMode) {
          debugPrint('No user ID for sync');
        }
        return;
      }
      
      final pendingSkips = _getPendingSkips();
      if (pendingSkips.isEmpty) {
        if (kDebugMode) {
          debugPrint('No pending skips to sync');
        }
        return;
      }
      
      if (kDebugMode) {
        debugPrint('☁️ Syncing ${pendingSkips.length} skips to Firebase...');
      }
      
      // Aggregate data for efficient storage
      final aggregatedData = _aggregateSkipData(pendingSkips);
      
      // Single Firestore write (cost = 1 write)
      // We need to merge the counts manually since FieldValue.increment doesn't work with maps
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc('skip_data')
          .get();
      
      final existingData = doc.exists ? doc.data() ?? {} : {};
      
      // Merge reason counts
      final mergedReasonCounts = Map<String, int>.from(existingData['skipReasonCounts'] ?? {});
      (aggregatedData['reasonCounts'] as Map<String, int>).forEach((reason, count) {
        mergedReasonCounts[reason] = (mergedReasonCounts[reason] ?? 0) + count;
      });
      
      // Merge exercise counts
      final mergedExerciseCounts = Map<String, int>.from(existingData['exerciseSkipCounts'] ?? {});
      (aggregatedData['exerciseCounts'] as Map<String, int>).forEach((exercise, count) {
        mergedExerciseCounts[exercise] = (mergedExerciseCounts[exercise] ?? 0) + count;
      });
      
      // Merge hourly patterns
      final mergedHourlyPatterns = Map<String, Map<String, int>>.from(existingData['hourlyPatterns'] ?? {});
      (aggregatedData['hourlyPatterns'] as Map<String, Map<String, int>>).forEach((hour, patterns) {
        if (!mergedHourlyPatterns.containsKey(hour)) {
          mergedHourlyPatterns[hour] = {};
        }
        patterns.forEach((reason, count) {
          mergedHourlyPatterns[hour]![reason] = (mergedHourlyPatterns[hour]![reason] ?? 0) + count;
        });
      });
      
      // Merge day patterns
      final mergedDayPatterns = Map<String, Map<String, int>>.from(existingData['dayPatterns'] ?? {});
      (aggregatedData['dayPatterns'] as Map<String, Map<String, int>>).forEach((day, patterns) {
        if (!mergedDayPatterns.containsKey(day)) {
          mergedDayPatterns[day] = {};
        }
        patterns.forEach((reason, count) {
          mergedDayPatterns[day]![reason] = (mergedDayPatterns[day]![reason] ?? 0) + count;
        });
      });
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc('skip_data')
          .set({
        'skipReasonCounts': mergedReasonCounts,
        'exerciseSkipCounts': mergedExerciseCounts,
        'hourlyPatterns': mergedHourlyPatterns,
        'dayPatterns': mergedDayPatterns,
        'totalSkips': (existingData['totalSkips'] ?? 0) + pendingSkips.length,
        'lastSkipDate': aggregatedData['lastSkipDate'],
        'lastSync': FieldValue.serverTimestamp(),
        'syncedSkips': FieldValue.arrayUnion(pendingSkips),
      }, SetOptions(merge: true));
      
      // Clear pending skips after successful sync
      await _box.put(_pendingSkipsKey, []);
      await _box.put(_lastSyncKey, DateTime.now().toIso8601String());
      
      if (kDebugMode) {
        debugPrint('✅ Sync complete! Cleared ${pendingSkips.length} pending skips');
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sync failed: $e');
      }
      // Keep pending skips for next sync attempt
    }
  }
  
  // 📊 AGGREGATE DATA for efficient storage
  Map<String, dynamic> _aggregateSkipData(List<dynamic> skips) {
    final reasonCounts = <String, int>{};
    final exerciseCounts = <String, int>{};
    final hourlyPatterns = <String, Map<String, int>>{};
    final dayPatterns = <String, Map<String, int>>{};
    DateTime? lastSkipDate;
    
    for (final skip in skips) {
      final reason = skip['reason'] as String;
      final exercise = skip['exerciseName'] as String;
      final hour = skip['hour'].toString();
      final day = skip['dayOfWeek'].toString();
      final timestamp = DateTime.parse(skip['timestamp']);
      
      // Count reasons
      reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
      
      // Count exercises
      exerciseCounts[exercise] = (exerciseCounts[exercise] ?? 0) + 1;
      
      // Hour patterns
      hourlyPatterns[hour] ??= {};
      hourlyPatterns[hour]![reason] = (hourlyPatterns[hour]![reason] ?? 0) + 1;
      
      // Day patterns
      dayPatterns[day] ??= {};
      dayPatterns[day]![reason] = (dayPatterns[day]![reason] ?? 0) + 1;
      
      // Track latest skip
      if (lastSkipDate == null || timestamp.isAfter(lastSkipDate)) {
        lastSkipDate = timestamp;
      }
    }
    
    return {
      'reasonCounts': reasonCounts,
      'exerciseCounts': exerciseCounts,
      'hourlyPatterns': hourlyPatterns,
      'dayPatterns': dayPatterns,
      'lastSkipDate': lastSkipDate?.toIso8601String(),
    };
  }
  
  // 📱 GET LOCAL ANALYTICS (for immediate UI updates)
  Map<String, dynamic> getLocalAnalytics() {
    return Map<String, dynamic>.from(_box.get(_localAnalyticsKey) ?? {});
  }
  
  // 📱 GET PENDING SKIPS
  List<dynamic> _getPendingSkips() {
    return List<dynamic>.from(_box.get(_pendingSkipsKey) ?? []);
  }
  
  // 🧹 CLEAR LOCAL DATA (after successful sync)
  Future<void> clearLocalData() async {
    await _box.put(_pendingSkipsKey, []);
    await _box.put(_localAnalyticsKey, {});
  }
  
  // 📊 GET INSIGHTS (from local data for instant feedback)
  Map<String, dynamic> getLocalInsights() {
    final analytics = getLocalAnalytics();
    
    // Most common skip reason
    String mostCommonReason = 'No data';
    if (analytics['reasonCounts'] != null) {
      final reasons = Map<String, int>.from(analytics['reasonCounts']);
      if (reasons.isNotEmpty) {
        final sorted = reasons.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        mostCommonReason = sorted.first.key;
      }
    }
    
    // Most skipped exercise
    String mostSkippedExercise = 'No data';
    if (analytics['exerciseCounts'] != null) {
      final exercises = Map<String, int>.from(analytics['exerciseCounts']);
      if (exercises.isNotEmpty) {
        final sorted = exercises.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        mostSkippedExercise = sorted.first.key;
      }
    }
    
    // Peak skip hour
    int peakHour = -1;
    if (analytics['hourlyPatterns'] != null) {
      final hourly = Map<String, dynamic>.from(analytics['hourlyPatterns']);
      int maxSkips = 0;
      
      hourly.forEach((hour, reasons) {
        final total = (reasons as Map).values
            .fold<int>(0, (sum, count) => sum + (count as int));
        if (total > maxSkips) {
          maxSkips = total;
          peakHour = int.parse(hour);
        }
      });
    }
    
    return {
      'mostCommonReason': mostCommonReason,
      'mostSkippedExercise': mostSkippedExercise,
      'peakHour': peakHour,
      'totalSkips': analytics['totalSkips'] ?? 0,
      'pendingSync': _getPendingSkips().length,
    };
  }
  
  // 🔄 MANUAL SYNC (user triggered)
  Future<void> forceSync(String userId) async {
    await syncToFirebase(userId: userId);
  }
}