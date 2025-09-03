/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/providers
 * 🎯 Feature: admin
 * 🔧 Type: provider (admin analytics sync)
 * 
 * Admin-only reverse sync system to collect analytics from all users
 */

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../analytics/domain/entities/workout_metrics.dart';
import '../../../analytics/domain/entities/personal_record.dart';

/// Admin analytics sync state
class AdminAnalyticsSyncState {
  final bool isSyncing;
  final bool isCollecting;
  final String? lastSyncTime;
  final Map<String, UserAnalyticsData> collectedData;
  final List<String> syncErrors;
  final SyncProgress? currentProgress;
  final AnalyticsAggregates? aggregates;
  
  const AdminAnalyticsSyncState({
    this.isSyncing = false,
    this.isCollecting = false,
    this.lastSyncTime,
    this.collectedData = const {},
    this.syncErrors = const [],
    this.currentProgress,
    this.aggregates,
  });
  
  AdminAnalyticsSyncState copyWith({
    bool? isSyncing,
    bool? isCollecting,
    String? lastSyncTime,
    Map<String, UserAnalyticsData>? collectedData,
    List<String>? syncErrors,
    SyncProgress? currentProgress,
    AnalyticsAggregates? aggregates,
  }) {
    return AdminAnalyticsSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isCollecting: isCollecting ?? this.isCollecting,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      collectedData: collectedData ?? this.collectedData,
      syncErrors: syncErrors ?? this.syncErrors,
      currentProgress: currentProgress ?? this.currentProgress,
      aggregates: aggregates ?? this.aggregates,
    );
  }
}

/// User analytics data model
class UserAnalyticsData {
  final String userId;
  final String? userName;
  final String? userEmail;
  final String accountTier;
  final DateTime lastWorkout;
  final int totalWorkouts;
  final int totalVolume;
  final int totalSets;
  final double avgSessionDuration;
  final Map<String, int> exerciseFrequency;
  final Map<String, double> muscleGroupDistribution;
  final List<PersonalRecord> recentPRs;
  final WorkoutMetrics? lastMetrics;
  final Map<String, dynamic> insights;
  final DateTime syncedAt;
  
  UserAnalyticsData({
    required this.userId,
    this.userName,
    this.userEmail,
    required this.accountTier,
    required this.lastWorkout,
    required this.totalWorkouts,
    required this.totalVolume,
    required this.totalSets,
    required this.avgSessionDuration,
    required this.exerciseFrequency,
    required this.muscleGroupDistribution,
    required this.recentPRs,
    this.lastMetrics,
    required this.insights,
    required this.syncedAt,
  });
  
  factory UserAnalyticsData.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsData(
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      accountTier: json['accountTier'] ?? 'free',
      lastWorkout: DateTime.parse(json['lastWorkout']),
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalVolume: json['totalVolume'] ?? 0,
      totalSets: json['totalSets'] ?? 0,
      avgSessionDuration: (json['avgSessionDuration'] ?? 0).toDouble(),
      exerciseFrequency: Map<String, int>.from(json['exerciseFrequency'] ?? {}),
      muscleGroupDistribution: Map<String, double>.from(json['muscleGroupDistribution'] ?? {}),
      recentPRs: (json['recentPRs'] as List? ?? [])
          .map((pr) => PersonalRecord.fromJson(pr))
          .toList(),
      lastMetrics: json['lastMetrics'] != null 
          ? WorkoutMetrics.fromJson(json['lastMetrics'])
          : null,
      insights: json['insights'] ?? {},
      syncedAt: DateTime.parse(json['syncedAt']),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'accountTier': accountTier,
    'lastWorkout': lastWorkout.toIso8601String(),
    'totalWorkouts': totalWorkouts,
    'totalVolume': totalVolume,
    'totalSets': totalSets,
    'avgSessionDuration': avgSessionDuration,
    'exerciseFrequency': exerciseFrequency,
    'muscleGroupDistribution': muscleGroupDistribution,
    'recentPRs': recentPRs.map((pr) => pr.toJson()).toList(),
    'lastMetrics': lastMetrics?.toJson(),
    'insights': insights,
    'syncedAt': syncedAt.toIso8601String(),
  };
}

/// Sync progress tracking
class SyncProgress {
  final int totalUsers;
  final int syncedUsers;
  final int failedUsers;
  final String currentUser;
  final double percentage;
  
  SyncProgress({
    required this.totalUsers,
    required this.syncedUsers,
    required this.failedUsers,
    required this.currentUser,
  }) : percentage = totalUsers > 0 ? (syncedUsers / totalUsers) * 100 : 0;
}

/// Analytics aggregates
class AnalyticsAggregates {
  final int totalUsers;
  final int activeUsers;
  final int totalWorkouts;
  final double totalVolume;
  final Map<String, int> topExercises;
  final Map<String, double> avgMetricsByTier;
  final List<TrendData> volumeTrends;
  final List<TrendData> frequencyTrends;
  
  AnalyticsAggregates({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalWorkouts,
    required this.totalVolume,
    required this.topExercises,
    required this.avgMetricsByTier,
    required this.volumeTrends,
    required this.frequencyTrends,
  });
}

/// Trend data point
class TrendData {
  final DateTime date;
  final double value;
  final String label;
  
  TrendData({
    required this.date,
    required this.value,
    required this.label,
  });
}

/// Admin analytics sync notifier
class AdminAnalyticsSyncNotifier extends StateNotifier<AdminAnalyticsSyncState> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  Timer? _progressTimer;
  
  AdminAnalyticsSyncNotifier(this._ref) : super(const AdminAnalyticsSyncState()) {
    _loadLastSyncTime();
  }
  
  /// Load last sync time from preferences
  Future<void> _loadLastSyncTime() async {
    try {
      final box = await Hive.openBox('admin_preferences');
      final lastSync = box.get('last_analytics_sync');
      if (lastSync != null) {
        state = state.copyWith(lastSyncTime: lastSync);
      }
    } catch (e) {
      debugPrint('Failed to load last sync time: $e');
    }
  }
  
  /// Check if user is admin
  bool get isAdmin {
    final user = _ref.read(currentUserProvider).value;
    return user?.email?.contains('admin') ?? false;
  }
  
  /// Trigger reverse sync for all users (admin only)
  Future<void> triggerReverseSync() async {
    if (!isAdmin) {
      debugPrint('❌ Non-admin user attempted reverse sync');
      return;
    }
    
    state = state.copyWith(
      isSyncing: true,
      syncErrors: [],
      currentProgress: null,
    );
    
    try {
      debugPrint('🔄 Starting admin reverse sync...');
      
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      
      debugPrint('📊 Found $totalUsers users to sync');
      
      final collectedData = <String, UserAnalyticsData>{};
      final errors = <String>[];
      int syncedCount = 0;
      int failedCount = 0;
      
      // Start progress tracking
      _startProgressTracking();
      
      // Process each user
      for (final userDoc in usersSnapshot.docs) {
        try {
          state = state.copyWith(
            currentProgress: SyncProgress(
              totalUsers: totalUsers,
              syncedUsers: syncedCount,
              failedUsers: failedCount,
              currentUser: userDoc.data()['displayName'] ?? userDoc.id,
            ),
          );
          
          // Collect analytics for this user
          final analyticsData = await _collectUserAnalytics(userDoc);
          
          if (analyticsData != null) {
            collectedData[userDoc.id] = analyticsData;
            syncedCount++;
          } else {
            failedCount++;
          }
          
          // Update progress
          state = state.copyWith(
            collectedData: collectedData,
            currentProgress: SyncProgress(
              totalUsers: totalUsers,
              syncedUsers: syncedCount,
              failedUsers: failedCount,
              currentUser: userDoc.data()['displayName'] ?? userDoc.id,
            ),
          );
          
          // Small delay to prevent overwhelming Firestore
          await Future.delayed(const Duration(milliseconds: 100));
          
        } catch (e) {
          debugPrint('❌ Failed to sync user ${userDoc.id}: $e');
          errors.add('User ${userDoc.id}: $e');
          failedCount++;
        }
      }
      
      // Calculate aggregates
      final aggregates = _calculateAggregates(collectedData);
      
      // Save to admin collection
      await _saveAdminAnalytics(collectedData, aggregates);
      
      // Update last sync time
      final now = DateTime.now().toIso8601String();
      final box = await Hive.openBox('admin_preferences');
      await box.put('last_analytics_sync', now);
      
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: now,
        collectedData: collectedData,
        syncErrors: errors.toList(),
        aggregates: aggregates,
        currentProgress: SyncProgress(
          totalUsers: totalUsers,
          syncedUsers: syncedCount,
          failedUsers: failedCount,
          currentUser: 'Complete',
        ),
      );
      
      debugPrint('✅ Reverse sync complete: $syncedCount/$totalUsers users');
      
    } catch (e) {
      debugPrint('❌ Reverse sync failed: $e');
      state = state.copyWith(
        isSyncing: false,
        syncErrors: ['Sync failed: $e'],
      );
    } finally {
      _stopProgressTracking();
    }
  }
  
  /// Collect analytics for a specific user
  Future<UserAnalyticsData?> _collectUserAnalytics(DocumentSnapshot userDoc) async {
    try {
      final userId = userDoc.id;
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Get user's workouts
      final workoutsQuery = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(100)
          .get();
      
      if (workoutsQuery.docs.isEmpty) {
        return null; // Skip users with no workouts
      }
      
      // Calculate analytics
      int totalVolume = 0;
      int totalSets = 0;
      double totalDuration = 0;
      final exerciseFreq = <String, int>{};
      final muscleGroups = <String, double>{};
      
      for (final workout in workoutsQuery.docs) {
        final data = workout.data();
        
        // Volume
        totalVolume += (data['totalVolume'] ?? 0) as int;
        totalSets += (data['totalSets'] ?? 0) as int;
        
        // Duration
        if (data['duration'] != null) {
          totalDuration += (data['duration'] as num).toDouble();
        }
        
        // Exercise frequency
        final exercises = data['exercises'] as List? ?? [];
        for (final exercise in exercises) {
          final name = exercise['name'] ?? 'Unknown';
          exerciseFreq[name] = (exerciseFreq[name] ?? 0) + 1;
          
          // Muscle groups
          final muscleGroup = exercise['muscleGroup'] ?? 'Other';
          final volume = (exercise['volume'] ?? 0).toDouble();
          muscleGroups[muscleGroup] = (muscleGroups[muscleGroup] ?? 0) + volume;
        }
      }
      
      // Get personal records
      final prsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('personalRecords')
          .orderBy('achievedAt', descending: true)
          .limit(10)
          .get();
      
      final recentPRs = prsQuery.docs
          .map((doc) => PersonalRecord.fromJson(doc.data()))
          .toList();
      
      // Calculate averages
      final avgDuration = workoutsQuery.docs.isNotEmpty 
          ? totalDuration / workoutsQuery.docs.length 
          : 0.0;
      
      // Get last workout metrics
      WorkoutMetrics? lastMetrics;
      if (workoutsQuery.docs.isNotEmpty) {
        final lastWorkout = workoutsQuery.docs.first.data();
        if (lastWorkout['metrics'] != null) {
          lastMetrics = WorkoutMetrics.fromJson(lastWorkout['metrics']);
        }
      }
      
      return UserAnalyticsData(
        userId: userId,
        userName: userData['displayName'],
        userEmail: userData['email'],
        accountTier: userData['accountTier'] ?? 'free',
        lastWorkout: workoutsQuery.docs.first.data()['startTime']?.toDate() ?? DateTime.now(),
        totalWorkouts: workoutsQuery.docs.length,
        totalVolume: totalVolume,
        totalSets: totalSets,
        avgSessionDuration: avgDuration,
        exerciseFrequency: exerciseFreq,
        muscleGroupDistribution: muscleGroups,
        recentPRs: recentPRs,
        lastMetrics: lastMetrics,
        insights: _generateUserInsights(workoutsQuery.docs),
        syncedAt: DateTime.now(),
      );
      
    } catch (e) {
      debugPrint('Failed to collect analytics for user: $e');
      return null;
    }
  }
  
  /// Generate insights for a user
  Map<String, dynamic> _generateUserInsights(List<QueryDocumentSnapshot> workouts) {
    final insights = <String, dynamic>{};
    
    // Training frequency
    if (workouts.isNotEmpty) {
      final firstWorkout = workouts.last.data() as Map<String, dynamic>;
      final lastWorkout = workouts.first.data() as Map<String, dynamic>;
      final firstDate = firstWorkout['startTime']?.toDate() ?? DateTime.now();
      final lastDate = lastWorkout['startTime']?.toDate() ?? DateTime.now();
      final daysDiff = lastDate.difference(firstDate).inDays;
      
      if (daysDiff > 0) {
        insights['frequency'] = (workouts.length / daysDiff * 7).toStringAsFixed(1);
      }
    }
    
    // Volume trend
    final volumes = workouts.map((w) => (w.data() as Map)['totalVolume'] ?? 0).toList();
    if (volumes.length >= 2) {
      final recent = volumes.take(5).fold<num>(0, (a, b) => a + b) / 5;
      final older = volumes.skip(5).take(5).fold<num>(0, (a, b) => a + b) / 5;
      if (older > 0) {
        final trend = ((recent - older) / older * 100).toStringAsFixed(1);
        insights['volumeTrend'] = '$trend%';
      }
    }
    
    return insights;
  }
  
  /// Calculate aggregates from collected data
  AnalyticsAggregates _calculateAggregates(Map<String, UserAnalyticsData> data) {
    final activeThreshold = DateTime.now().subtract(const Duration(days: 7));
    
    // Count active users
    final activeUsers = data.values
        .where((u) => u.lastWorkout.isAfter(activeThreshold))
        .length;
    
    // Total workouts and volume
    var totalWorkouts = 0;
    var totalVolume = 0.0;
    
    // Exercise frequency across all users
    final globalExerciseFreq = <String, int>{};
    
    // Metrics by tier
    final tierMetrics = <String, List<double>>{
      'free': [],
      'premium': [],
      'pro': [],
    };
    
    for (final user in data.values) {
      totalWorkouts += user.totalWorkouts;
      totalVolume += user.totalVolume.toDouble();
      
      // Aggregate exercise frequency
      user.exerciseFrequency.forEach((exercise, count) {
        globalExerciseFreq[exercise] = (globalExerciseFreq[exercise] ?? 0) + count;
      });
      
      // Group by tier
      final tier = user.accountTier;
      if (tierMetrics.containsKey(tier)) {
        tierMetrics[tier]!.add(user.avgSessionDuration);
      }
    }
    
    // Calculate average metrics by tier
    final avgByTier = <String, double>{};
    tierMetrics.forEach((tier, durations) {
      if (durations.isNotEmpty) {
        avgByTier[tier] = durations.reduce((a, b) => a + b) / durations.length;
      }
    });
    
    // Get top 10 exercises
    final sortedExercises = globalExerciseFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topExercises = Map.fromEntries(sortedExercises.take(10));
    
    // Generate trends (mock data for now)
    final volumeTrends = List.generate(30, (i) {
      final date = DateTime.now().subtract(Duration(days: 30 - i));
      return TrendData(
        date: date,
        value: totalVolume / 30 * (0.8 + (i / 30) * 0.4),
        label: 'Day ${i + 1}',
      );
    });
    
    final frequencyTrends = List.generate(30, (i) {
      final date = DateTime.now().subtract(Duration(days: 30 - i));
      return TrendData(
        date: date,
        value: totalWorkouts / 30 * (0.9 + (i / 30) * 0.2),
        label: 'Day ${i + 1}',
      );
    });
    
    return AnalyticsAggregates(
      totalUsers: data.length,
      activeUsers: activeUsers,
      totalWorkouts: totalWorkouts,
      totalVolume: totalVolume,
      topExercises: topExercises,
      avgMetricsByTier: avgByTier,
      volumeTrends: volumeTrends,
      frequencyTrends: frequencyTrends,
    );
  }
  
  /// Save admin analytics to Firestore
  Future<void> _saveAdminAnalytics(
    Map<String, UserAnalyticsData> data,
    AnalyticsAggregates aggregates,
  ) async {
    try {
      // Save to admin collection
      await _firestore.collection('adminAnalytics').doc('latest').set({
        'syncedAt': FieldValue.serverTimestamp(),
        'totalUsers': aggregates.totalUsers,
        'activeUsers': aggregates.activeUsers,
        'totalWorkouts': aggregates.totalWorkouts,
        'totalVolume': aggregates.totalVolume,
        'topExercises': aggregates.topExercises,
        'avgMetricsByTier': aggregates.avgMetricsByTier,
        'userData': data.map((k, v) => MapEntry(k, v.toJson())),
      });
      
      debugPrint('✅ Admin analytics saved to Firestore');
      
    } catch (e) {
      debugPrint('❌ Failed to save admin analytics: $e');
      throw e;
    }
  }
  
  /// Start progress tracking
  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Progress is updated in real-time during sync
    });
  }
  
  /// Stop progress tracking
  void _stopProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }
  
  /// Sync exercises from Firestore to local for analytics
  Future<void> syncExercisesFromFirestore() async {
    if (!isAdmin) return;
    
    state = state.copyWith(
      isCollecting: true,
      syncErrors: [],
    );
    
    try {
      debugPrint('🔄 Syncing exercises from Firestore...');
      
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      int syncedExercises = 0;
      int syncedWorkouts = 0;
      
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        
        try {
          // Get user's workouts from Firestore
          final workoutsQuery = await _firestore
              .collection('workouts')
              .where('userId', isEqualTo: userId)
              .orderBy('startTime', descending: true)
              .limit(200) // Get more workouts for better analytics
              .get();
          
          if (workoutsQuery.docs.isNotEmpty) {
            syncedWorkouts += workoutsQuery.docs.length;
            
            // Count exercises
            for (final workout in workoutsQuery.docs) {
              final data = workout.data();
              final exercises = data['exercises'] as List? ?? [];
              syncedExercises += exercises.length;
            }
            
            debugPrint('✅ Synced ${workoutsQuery.docs.length} workouts for user $userId');
          }
          
        } catch (e) {
          debugPrint('⚠️ Failed to sync workouts for user $userId: $e');
        }
      }
      
      state = state.copyWith(
        isCollecting: false,
        lastSyncTime: DateTime.now().toIso8601String(),
      );
      
      debugPrint('✅ Exercise sync complete: $syncedWorkouts workouts, $syncedExercises exercises');
      
      // Show success message (removed undefined _syncEventController)
      
    } catch (e) {
      debugPrint('❌ Exercise sync failed: $e');
      state = state.copyWith(
        isCollecting: false,
        syncErrors: ['Exercise sync failed: $e'],
      );
    }
  }
  
  /// Trigger Cloud Function to collect analytics (alternative method)
  Future<void> triggerCloudAnalyticsCollection() async {
    if (!isAdmin) return;
    
    state = state.copyWith(isCollecting: true);
    
    try {
      // First sync exercises from Firestore
      await syncExercisesFromFirestore();
      
      final callable = _functions.httpsCallable('collectGlobalAnalytics');
      final result = await callable.call({
        'requestedBy': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      if (result.data['success'] == true) {
        debugPrint('✅ Cloud analytics collection triggered');
        
        // Wait for collection to complete
        await Future.delayed(const Duration(seconds: 5));
        
        // Load the collected data
        await loadCollectedAnalytics();
      }
      
    } catch (e) {
      debugPrint('❌ Cloud collection failed: $e');
      state = state.copyWith(
        isCollecting: false,
        syncErrors: ['Cloud collection failed: $e'],
      );
    }
  }
  
  /// Load previously collected analytics
  Future<void> loadCollectedAnalytics() async {
    try {
      final doc = await _firestore.collection('adminAnalytics').doc('latest').get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        // Parse user data
        final userData = <String, UserAnalyticsData>{};
        if (data['userData'] != null) {
          (data['userData'] as Map).forEach((key, value) {
            userData[key] = UserAnalyticsData.fromJson(value);
          });
        }
        
        // Parse aggregates
        final aggregates = AnalyticsAggregates(
          totalUsers: data['totalUsers'] ?? 0,
          activeUsers: data['activeUsers'] ?? 0,
          totalWorkouts: data['totalWorkouts'] ?? 0,
          totalVolume: (data['totalVolume'] ?? 0).toDouble(),
          topExercises: Map<String, int>.from(data['topExercises'] ?? {}),
          avgMetricsByTier: Map<String, double>.from(data['avgMetricsByTier'] ?? {}),
          volumeTrends: [], // Would need to parse from data
          frequencyTrends: [], // Would need to parse from data
        );
        
        state = state.copyWith(
          isCollecting: false,
          collectedData: userData,
          aggregates: aggregates,
          lastSyncTime: data['syncedAt']?.toDate().toIso8601String(),
        );
      }
      
    } catch (e) {
      debugPrint('Failed to load collected analytics: $e');
    }
  }
  
  @override
  void dispose() {
    _stopProgressTracking();
    super.dispose();
  }
}

/// Admin analytics sync provider
final adminAnalyticsSyncProvider = 
    StateNotifierProvider<AdminAnalyticsSyncNotifier, AdminAnalyticsSyncState>((ref) {
  return AdminAnalyticsSyncNotifier(ref);
});

/// Check if current user is admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.email?.contains('admin') ?? false;
});

/// Get sync progress
final syncProgressProvider = Provider<SyncProgress?>((ref) {
  return ref.watch(adminAnalyticsSyncProvider).currentProgress;
});

/// Get analytics aggregates
final analyticsAggregatesProvider = Provider<AnalyticsAggregates?>((ref) {
  return ref.watch(adminAnalyticsSyncProvider).aggregates;
});