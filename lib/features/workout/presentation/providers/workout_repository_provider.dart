/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod
/// - Repository implementations
/// - Firebase
/// - Hive
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_workout_repository_impl.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_sync_service.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';

/// Provider for Hive workout data source
final hiveWorkoutDataSourceProvider = Provider<HiveWorkoutDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return HiveWorkoutDataSource(boxManager);
});

/// Provider for Firebase workout data source
final firebaseWorkoutDataSourceProvider = Provider<FirebaseWorkoutDataSource>((ref) {
  return FirebaseWorkoutDataSource(FirebaseFirestore.instance);
});

/// Provider for workout repository (hybrid implementation)
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final localDataSource = ref.watch(hiveWorkoutDataSourceProvider);
  final remoteDataSource = ref.watch(firebaseWorkoutDataSourceProvider);
  final auth = FirebaseAuth.instance;
  final analyticsRepository = ref.watch(analyticsRepositoryProvider);

  return HybridWorkoutRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    auth: auth,
    analyticsRepository: analyticsRepository,
  );
});

/// Provider for workout sync service (for premium users)
final workoutSyncServiceProvider = Provider<WorkoutSyncService>((ref) {
  final localDataSource = ref.watch(hiveWorkoutDataSourceProvider);
  final remoteDataSource = ref.watch(firebaseWorkoutDataSourceProvider);
  final auth = FirebaseAuth.instance;
  
  final service = WorkoutSyncService(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    auth: auth,
  );
  
  // Initialize the service
  service.initialize();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for sync status
final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatusState>(
  SyncStatusNotifier.new,
);

/// State for sync status
class SyncStatusState {

  const SyncStatusState({
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastSyncResult,
    this.isPremiumUser = false,
  });
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final SyncResult? lastSyncResult;
  final bool isPremiumUser;

  SyncStatusState copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
    SyncResult? lastSyncResult,
    bool? isPremiumUser,
  }) {
    return SyncStatusState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
    );
  }
}

/// Notifier for sync status
class SyncStatusNotifier extends Notifier<SyncStatusState> {

  @override
  SyncStatusState build() => const SyncStatusState();

  WorkoutSyncService get _syncService => ref.watch(workoutSyncServiceProvider);
  
  /// Trigger manual sync
  Future<void> syncNow() async {
    if (state.isSyncing) return;
    
    state = state.copyWith(isSyncing: true);
    
    try {
      final result = await _syncService.syncNow();
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        lastSyncResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncResult: SyncResult()
          ..success = false
          ..message = 'Sync failed: $e',
      );
    }
  }
  
  /// Update premium status
  void updatePremiumStatus(bool isPremium) {
    state = state.copyWith(isPremiumUser: isPremium);
  }
  
  /// Export all data
  Future<Map<String, dynamic>> exportData() async {
    return await _syncService.exportAllData();
  }
  
  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    await _syncService.importData(data);
    
    // Trigger sync if premium
    if (state.isPremiumUser) {
      await syncNow();
    }
  }
  
  /// Clear all local data
  Future<void> clearAllData() async {
    await _syncService.clearAllData();
  }
}