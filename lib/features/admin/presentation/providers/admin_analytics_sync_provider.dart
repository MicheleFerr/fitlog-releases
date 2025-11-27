/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider (admin analytics sync)
/// 
/// Admin-only reverse sync system to collect analytics from all users
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/personal_record.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/auth/admin_status_provider.dart';

/// Admin analytics sync state
class AdminAnalyticsSyncState {
  
  const AdminAnalyticsSyncState({
    this.isSyncing = false,
    this.isCollecting = false,
    this.lastSyncTime,
    this.collectedData = const {},
    this.syncErrors = const [],
    this.currentProgress,
    this.aggregates,
  });
  final bool isSyncing;
  final bool isCollecting;
  final String? lastSyncTime;
  final Map<String, UserAnalyticsData> collectedData;
  final List<String> syncErrors;
  final SyncProgress? currentProgress;
  final AnalyticsAggregates? aggregates;
  
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
  
  SyncProgress({
    required this.totalUsers,
    required this.syncedUsers,
    required this.failedUsers,
    required this.currentUser,
  }) : percentage = totalUsers > 0 ? (syncedUsers / totalUsers) * 100 : 0;
  final int totalUsers;
  final int syncedUsers;
  final int failedUsers;
  final String currentUser;
  final double percentage;
}

/// Analytics aggregates
class AnalyticsAggregates {
  
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
  final int totalUsers;
  final int activeUsers;
  final int totalWorkouts;
  final double totalVolume;
  final Map<String, int> topExercises;
  final Map<String, double> avgMetricsByTier;
  final List<TrendData> volumeTrends;
  final List<TrendData> frequencyTrends;
}

/// Trend data point
class TrendData {
  
  TrendData({
    required this.date,
    required this.value,
    required this.label,
  });
  final DateTime date;
  final double value;
  final String label;
}

/// Admin analytics sync notifier
class AdminAnalyticsSyncNotifier extends Notifier<AdminAnalyticsSyncState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  Timer? _progressTimer;

  // GOLD STANDARD: Initialization tracking
  bool _isInitialized = false;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3;
  Box? _adminPrefsBox;

  @override
  AdminAnalyticsSyncState build() {
    _initCompleter = Completer<void>();
    _initialize();

    // Cleanup on dispose
    ref.onDispose(() {
      if (kDebugMode) {
        debugPrint('🧹 [AdminAnalytics] Starting disposal');
      }

      _isDisposed = true;

      try {
        // Cancel progress timer
        _stopProgressTracking();

        // Close Hive box if open
        if (_adminPrefsBox != null && _adminPrefsBox!.isOpen) {
          _adminPrefsBox!.close();
          if (kDebugMode) {
            debugPrint('✅ [AdminAnalytics] Closed Hive box');
          }
        }
        _adminPrefsBox = null;

        // Null out completer
        _initCompleter = null;

        if (kDebugMode) {
          debugPrint('✅ [AdminAnalytics] Disposal completed');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [AdminAnalytics] Error during disposal: $e');
          debugPrint('📍 Stack trace: $stackTrace');
        }
      }
    });

    return const AdminAnalyticsSyncState();
  }
  
  /// Initialize with retry logic
  Future<void> _initialize() async {
    try {
      if (kDebugMode) {
        debugPrint('📍 [AdminAnalytics] Initializing AdminAnalyticsSyncNotifier...');
      }

      // Open Hive box with timeout
      final boxManager = ref.read(hiveBoxManagerProvider);
      _adminPrefsBox = await boxManager.openBox('admin_preferences').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ [AdminAnalytics] Hive box open timeout');
          }
          throw TimeoutException('Failed to open admin preferences box');
        },
      );

      // Load last sync time
      final lastSync = _adminPrefsBox!.get('last_analytics_sync');
      if (lastSync != null) {
        state = state.copyWith(lastSyncTime: lastSync);
        if (kDebugMode) {
          debugPrint('✅ [AdminAnalytics] Loaded last sync time: $lastSync');
        }
      }

      _isInitialized = true;
      _initRetryCount = 0;
      _initCompleter?.complete();

      if (kDebugMode) {
        debugPrint('✅ [AdminAnalytics] Initialization complete');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AdminAnalytics] Initialization error: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }

      if (_initRetryCount < _maxInitRetries) {
        _initRetryCount++;
        if (kDebugMode) {
          debugPrint('🔄 [AdminAnalytics] Retrying initialization (attempt $_initRetryCount/$_maxInitRetries)');
        }
        await Future.delayed(Duration(seconds: _initRetryCount));
        await _initialize();
      } else {
        _initCompleter?.completeError(e, stackTrace);
      }
    }
  }

  /// Ensure initialized before operations
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initRetryCount >= _maxInitRetries) {
      throw Exception('AdminAnalyticsSyncNotifier initialization failed after $_maxInitRetries attempts');
    }
    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⚠️ [AdminAnalytics] Initialization timeout');
            }
            throw TimeoutException('Initialization timeout');
          },
        );
      } catch (e) {
        _initRetryCount++;
        _initCompleter = Completer<void>();
        await _initialize();
      }
    }
  }
  
  /// Check if user is admin (via custom claims)
  ///
  /// 🔐 SECURITY: Uses Firebase Custom Claims (server-validated)
  /// REPLACED: user?.email?.contains('admin') (insecure)
  bool get isAdmin {
    return ref.read(isAdminProvider);
  }
  
  /// Trigger reverse sync for all users (admin only)
  Future<void> triggerReverseSync() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) {
        if (kDebugMode) {
          debugPrint('⚠️ [AdminAnalytics] triggerReverseSync: Provider is disposed');
        }
        return;
      }

      if (!isAdmin) {
        if (kDebugMode) {
          debugPrint('❌ [AdminAnalytics] Non-admin user attempted reverse sync');
        }
        return;
      }

      state = state.copyWith(
        isSyncing: true,
        syncErrors: [],
        currentProgress: null,
      );

      if (kDebugMode) {
        debugPrint('🔄 [AdminAnalytics] Starting admin reverse sync...');
      }
      
      // Get all users with timeout
      final usersSnapshot = await _firestore.collection('users').get().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ [AdminAnalytics] Users query timeout');
          }
          throw TimeoutException('Failed to fetch users list');
        },
      );
      final totalUsers = usersSnapshot.docs.length;

      if (kDebugMode) {
        debugPrint('📊 [AdminAnalytics] Found $totalUsers users to sync');
      }
      
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
          if (kDebugMode) {
            debugPrint('❌ [AdminAnalytics] Failed to sync user ${userDoc.id}: $e');
          }
          errors.add('User ${userDoc.id}: $e');
          failedCount++;
        }
      }
      
      // Calculate aggregates
      final aggregates = _calculateAggregates(collectedData);
      
      // Save to admin collection
      await _saveAdminAnalytics(collectedData, aggregates);

      // Update last sync time using tracked box
      final now = DateTime.now().toIso8601String();
      if (_adminPrefsBox != null && _adminPrefsBox!.isOpen) {
        await _adminPrefsBox!.put('last_analytics_sync', now);
      }

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

      if (kDebugMode) {
        debugPrint('✅ [AdminAnalytics] Reverse sync complete: $syncedCount/$totalUsers users');
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AdminAnalytics] Reverse sync failed: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
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
      
      // Get user's workouts with timeout
      final workoutsQuery = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(100)
          .get()
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('⚠️ [AdminAnalytics] Workouts query timeout for user $userId');
              }
              throw TimeoutException('Workouts query timeout');
            },
          );

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
      
      // Get personal records with timeout
      final prsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('personalRecords')
          .orderBy('achievedAt', descending: true)
          .limit(10)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('⚠️ [AdminAnalytics] PRs query timeout for user $userId');
              }
              throw TimeoutException('Personal records query timeout');
            },
          );

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

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AdminAnalytics] Failed to collect analytics for user: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
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
      // Save to admin collection with timeout
      await _firestore.collection('adminAnalytics').doc('latest').set({
        'syncedAt': FieldValue.serverTimestamp(),
        'totalUsers': aggregates.totalUsers,
        'activeUsers': aggregates.activeUsers,
        'totalWorkouts': aggregates.totalWorkouts,
        'totalVolume': aggregates.totalVolume,
        'topExercises': aggregates.topExercises,
        'avgMetricsByTier': aggregates.avgMetricsByTier,
        'userData': data.map((k, v) => MapEntry(k, v.toJson())),
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ [AdminAnalytics] Firestore write timeout');
          }
          throw TimeoutException('Failed to save admin analytics');
        },
      );

      if (kDebugMode) {
        debugPrint('✅ [AdminAnalytics] Admin analytics saved to Firestore');
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AdminAnalytics] Failed to save admin analytics: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      rethrow;
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
    try {
      await _ensureInitialized();
      if (_isDisposed) {
        if (kDebugMode) {
          debugPrint('⚠️ [AdminAnalytics] syncExercisesFromFirestore: Provider is disposed');
        }
        return;
      }

      if (!isAdmin) return;

      state = state.copyWith(
        isCollecting: true,
        syncErrors: [],
      );

      if (kDebugMode) {
        debugPrint('🔄 [AdminAnalytics] Syncing exercises from Firestore...');
      }

      // Get all users with timeout
      final usersSnapshot = await _firestore.collection('users').get().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ [AdminAnalytics] Users query timeout in syncExercises');
          }
          throw TimeoutException('Failed to fetch users list');
        },
      );
      int syncedExercises = 0;
      int syncedWorkouts = 0;
      
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        
        try {
          // Get user's workouts from Firestore with timeout
          final workoutsQuery = await _firestore
              .collection('workouts')
              .where('userId', isEqualTo: userId)
              .orderBy('startTime', descending: true)
              .limit(200) // Get more workouts for better analytics
              .get()
              .timeout(
                const Duration(seconds: 20),
                onTimeout: () {
                  if (kDebugMode) {
                    debugPrint('⚠️ [AdminAnalytics] Workouts query timeout for user $userId in syncExercises');
                  }
                  throw TimeoutException('Workouts query timeout');
                },
              );

          if (workoutsQuery.docs.isNotEmpty) {
            syncedWorkouts += workoutsQuery.docs.length;

            // Count exercises
            for (final workout in workoutsQuery.docs) {
              final data = workout.data();
              final exercises = data['exercises'] as List? ?? [];
              syncedExercises += exercises.length;
            }

            if (kDebugMode) {
              debugPrint('✅ [AdminAnalytics] Synced ${workoutsQuery.docs.length} workouts for user $userId');
            }
          }

        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ [AdminAnalytics] Failed to sync workouts for user $userId: $e');
          }
        }
      }
      
      state = state.copyWith(
        isCollecting: false,
        lastSyncTime: DateTime.now().toIso8601String(),
      );

      if (kDebugMode) {
        debugPrint('✅ [AdminAnalytics] Exercise sync complete: $syncedWorkouts workouts, $syncedExercises exercises');
      }

      // Show success message (removed undefined _syncEventController)

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AdminAnalytics] Exercise sync failed: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(
        isCollecting: false,
        syncErrors: ['Exercise sync failed: $e'],
      );
    }
  }
  
  /// Trigger Cloud Function to collect analytics (alternative method)
  Future<void> triggerCloudAnalyticsCollection() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) {
        if (kDebugMode) {
          debugPrint('⚠️ [AdminAnalytics] triggerCloudAnalyticsCollection: Provider is disposed');
        }
        return;
      }

      if (!isAdmin) return;

      state = state.copyWith(isCollecting: true);

      // First sync exercises from Firestore
      await syncExercisesFromFirestore();

      final callable = _functions.httpsCallable('collectGlobalAnalytics');
      final result = await callable.call({
        'requestedBy': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': DateTime.now().toIso8601String(),
      }).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ [AdminAnalytics] Cloud function call timeout');
          }
          throw TimeoutException('Cloud function timeout');
        },
      );

      if (result.data['success'] == true) {
        if (kDebugMode) {
          debugPrint('✅ [AdminAnalytics] Cloud analytics collection triggered');
        }

        // Wait for collection to complete
        await Future.delayed(const Duration(seconds: 5));

        // Load the collected data
        await loadCollectedAnalytics();
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AdminAnalytics] Cloud collection failed: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      state = state.copyWith(
        isCollecting: false,
        syncErrors: ['Cloud collection failed: $e'],
      );
    }
  }
  
  /// Load previously collected analytics
  Future<void> loadCollectedAnalytics() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) {
        if (kDebugMode) {
          debugPrint('⚠️ [AdminAnalytics] loadCollectedAnalytics: Provider is disposed');
        }
        return;
      }

      final doc = await _firestore.collection('adminAnalytics').doc('latest').get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ [AdminAnalytics] Firestore read timeout in loadCollectedAnalytics');
          }
          throw TimeoutException('Failed to load analytics');
        },
      );

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

        if (kDebugMode) {
          debugPrint('✅ [AdminAnalytics] Loaded analytics: ${userData.length} users');
        }
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AdminAnalytics] Failed to load collected analytics: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }
  
}

/// Admin analytics sync provider
final adminAnalyticsSyncProvider =
    NotifierProvider<AdminAnalyticsSyncNotifier, AdminAnalyticsSyncState>(
  AdminAnalyticsSyncNotifier.new,
);

/// 🔐 SECURITY: Check if current user is admin
/// Import from core/auth/admin_status_provider.dart (global provider using Custom Claims)
/// REMOVED: Local duplicate provider with insecure email check

/// Get sync progress
final syncProgressProvider = Provider<SyncProgress?>((ref) {
  return ref.watch(adminAnalyticsSyncProvider).currentProgress;
});

/// Get analytics aggregates
final analyticsAggregatesProvider = Provider<AnalyticsAggregates?>((ref) {
  return ref.watch(adminAnalyticsSyncProvider).aggregates;
});