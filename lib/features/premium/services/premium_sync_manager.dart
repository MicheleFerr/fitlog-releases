/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: services
/// 🎯 Feature: premium
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Timer for periodic sync
/// - Connectivity monitoring
/// - Battery optimization
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_sync_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/hybrid_template_repository.dart';

/// Manages all premium sync operations with optimized timing
class PremiumSyncManager {
  
  PremiumSyncManager({
    required WorkoutSyncService workoutSyncService,
    required HybridTemplateRepository templateRepository,
  }) : _workoutSyncService = workoutSyncService,
       _templateRepository = templateRepository {
    _initialize();
  }
  final WorkoutSyncService _workoutSyncService;
  final HybridTemplateRepository _templateRepository;
  
  // Sync timers
  Timer? _activeSyncTimer;
  Timer? _backgroundSyncTimer;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _batterySubscription;
  
  // Sync configuration
  static const Duration _activeSyncInterval = Duration(minutes: 5);
  static const Duration _backgroundSyncInterval = Duration(minutes: 30);
  static const Duration _maxSyncAge = Duration(hours: 1);
  static const int _minBatteryLevel = 20;
  
  // Sync state
  DateTime? _lastSyncTime;
  bool _isSyncing = false;
  bool _isAppActive = true;
  bool _hasConnection = true;
  int _batteryLevel = 100;
  
  // Sync statistics
  final _syncStats = SyncStatistics();
  
  /// Initialize sync manager
  void _initialize() {
    // Monitor connectivity
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _hasConnection = result != ConnectivityResult.none;
      
      // Trigger sync when connection restored
      if (_hasConnection && _shouldSync()) {
        syncNow(reason: SyncReason.connectionRestored);
      }
    });
    
    // Monitor battery
    _batterySubscription = Battery().onBatteryStateChanged.listen((state) async {
      _batteryLevel = await Battery().batteryLevel;
      
      // Pause sync if battery too low
      if (_batteryLevel < _minBatteryLevel && !_isCharging(state)) {
        pauseSync();
      }
    });
  }
  
  /// Start premium sync
  void startPremiumSync() {
    debugPrint('🔄 Starting premium sync service');
    
    // Initial sync
    syncNow(reason: SyncReason.appStarted);
    
    // Setup periodic sync
    _setupPeriodicSync();
  }
  
  /// Setup periodic sync based on app state
  void _setupPeriodicSync() {
    _cancelTimers();
    
    if (_isAppActive) {
      // Active sync every 5 minutes
      _activeSyncTimer = Timer.periodic(_activeSyncInterval, (_) {
        if (_shouldSync()) {
          syncNow(reason: SyncReason.periodic);
        }
      });
    } else {
      // Background sync every 30 minutes
      _backgroundSyncTimer = Timer.periodic(_backgroundSyncInterval, (_) {
        if (_shouldSync()) {
          syncNow(reason: SyncReason.background);
        }
      });
    }
  }
  
  /// Check if sync should run
  bool _shouldSync() {
    // Don't sync if already syncing
    if (_isSyncing) return false;
    
    // Don't sync without connection
    if (!_hasConnection) return false;
    
    // Don't sync on low battery (unless charging)
    if (_batteryLevel < _minBatteryLevel) return false;
    
    // Check if sync is needed based on last sync time
    if (_lastSyncTime != null) {
      final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
      if (timeSinceLastSync < const Duration(minutes: 1)) {
        return false; // Too soon
      }
    }
    
    return true;
  }
  
  /// Perform sync now
  Future<SyncResult> syncNow({
    required SyncReason reason,
    bool force = false,
  }) async {
    if (_isSyncing && !force) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }
    
    debugPrint('🔄 Starting sync: $reason');
    _isSyncing = true;
    _syncStats.syncStarted(reason);
    
    final result = SyncResult();
    final stopwatch = Stopwatch()..start();
    
    try {
      // 1. Sync workouts
      final workoutResult = await _workoutSyncService.syncNow();
      // TODO: Implement SyncResult.merge() method
      // result.merge(workoutResult);
      
      // 2. Sync templates
      await _templateRepository.processSyncQueue();
      
      // 3. Update last sync time
      _lastSyncTime = DateTime.now();
      
      result.success = true;
      result.message = 'Sync completed successfully';
      
      debugPrint('✅ Sync completed in ${stopwatch.elapsedMilliseconds}ms');
      
    } catch (e) {
      result.success = false;
      result.message = 'Sync failed: $e';
      debugPrint('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
      stopwatch.stop();
      _syncStats.syncCompleted(result, stopwatch.elapsed);
    }
    
    return result;
  }
  
  /// Sync after workout completion (immediate)
  Future<void> syncAfterWorkout() async {
    // Wait a moment for data to be saved
    await Future.delayed(const Duration(seconds: 2));
    
    // Force sync even if recently synced
    await syncNow(reason: SyncReason.workoutCompleted, force: true);
  }
  
  /// Handle app lifecycle changes
  void onAppLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppActive = true;
        
        // Check if sync needed when app resumes
        if (_lastSyncTime != null) {
          final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
          if (timeSinceLastSync > _maxSyncAge) {
            syncNow(reason: SyncReason.appResumed);
          }
        }
        
        _setupPeriodicSync();
        break;
        
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _isAppActive = false;
        _setupPeriodicSync();
        break;
        
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        pauseSync();
        break;
    }
  }
  
  /// Pause all sync operations
  void pauseSync() {
    debugPrint('⏸️ Pausing sync');
    _cancelTimers();
  }
  
  /// Resume sync operations
  void resumeSync() {
    debugPrint('▶️ Resuming sync');
    _setupPeriodicSync();
    
    // Sync if needed
    if (_shouldSync()) {
      syncNow(reason: SyncReason.resumed);
    }
  }
  
  /// Cancel all timers
  void _cancelTimers() {
    _activeSyncTimer?.cancel();
    _backgroundSyncTimer?.cancel();
    _activeSyncTimer = null;
    _backgroundSyncTimer = null;
  }
  
  /// Check if device is charging
  bool _isCharging(BatteryState state) {
    return state == BatteryState.charging || state == BatteryState.full;
  }
  
  /// Get sync status
  SyncStatus getSyncStatus() {
    return SyncStatus(
      lastSyncTime: _lastSyncTime,
      isSyncing: _isSyncing,
      isEnabled: _activeSyncTimer != null || _backgroundSyncTimer != null,
      hasConnection: _hasConnection,
      batteryLevel: _batteryLevel,
      statistics: _syncStats.toMap(),
    );
  }
  
  /// Get optimal sync configuration
  static SyncConfiguration getOptimalConfiguration() {
    return const SyncConfiguration(
      activeSyncInterval: _activeSyncInterval,
      backgroundSyncInterval: _backgroundSyncInterval,
      minBatteryLevel: _minBatteryLevel,
      wifiOnlyForLargeSync: true,
      maxRetries: 3,
      retryDelay: Duration(minutes: 1),
    );
  }
  
  /// Dispose resources
  void dispose() {
    _cancelTimers();
    _connectivitySubscription?.cancel();
    _batterySubscription?.cancel();
  }
}

/// Sync status information
class SyncStatus {
  
  SyncStatus({
    this.lastSyncTime,
    required this.isSyncing,
    required this.isEnabled,
    required this.hasConnection,
    required this.batteryLevel,
    required this.statistics,
  });
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final bool isEnabled;
  final bool hasConnection;
  final int batteryLevel;
  final Map<String, dynamic> statistics;
  
  String get statusMessage {
    if (isSyncing) return 'Syncing...';
    if (!isEnabled) return 'Sync disabled';
    if (!hasConnection) return 'Waiting for connection';
    if (batteryLevel < 20) return 'Low battery - sync paused';
    if (lastSyncTime != null) {
      final ago = DateTime.now().difference(lastSyncTime!);
      if (ago.inMinutes < 1) return 'Just synced';
      if (ago.inHours < 1) return 'Synced ${ago.inMinutes}m ago';
      if (ago.inDays < 1) return 'Synced ${ago.inHours}h ago';
      return 'Synced ${ago.inDays}d ago';
    }
    return 'Not synced yet';
  }
}

/// Reasons for sync
enum SyncReason {
  appStarted,
  appResumed,
  periodic,
  background,
  manual,
  workoutCompleted,
  connectionRestored,
  resumed,
}

/// Sync configuration
class SyncConfiguration {
  
  const SyncConfiguration({
    required this.activeSyncInterval,
    required this.backgroundSyncInterval,
    required this.minBatteryLevel,
    required this.wifiOnlyForLargeSync,
    required this.maxRetries,
    required this.retryDelay,
  });
  final Duration activeSyncInterval;
  final Duration backgroundSyncInterval;
  final int minBatteryLevel;
  final bool wifiOnlyForLargeSync;
  final int maxRetries;
  final Duration retryDelay;
}

/// Sync statistics tracking
class SyncStatistics {
  int totalSyncs = 0;
  int successfulSyncs = 0;
  int failedSyncs = 0;
  Duration totalSyncTime = Duration.zero;
  final Map<SyncReason, int> syncsByReason = {};
  DateTime? firstSyncTime;
  DateTime? lastSuccessfulSync;
  
  void syncStarted(SyncReason reason) {
    totalSyncs++;
    syncsByReason[reason] = (syncsByReason[reason] ?? 0) + 1;
    firstSyncTime ??= DateTime.now();
  }
  
  void syncCompleted(SyncResult result, Duration duration) {
    if (result.success) {
      successfulSyncs++;
      lastSuccessfulSync = DateTime.now();
    } else {
      failedSyncs++;
    }
    totalSyncTime += duration;
  }
  
  double get successRate => totalSyncs > 0 ? successfulSyncs / totalSyncs : 0;
  
  Duration get averageSyncTime => totalSyncs > 0 
      ? Duration(milliseconds: totalSyncTime.inMilliseconds ~/ totalSyncs)
      : Duration.zero;
  
  Map<String, dynamic> toMap() => {
    'totalSyncs': totalSyncs,
    'successfulSyncs': successfulSyncs,
    'failedSyncs': failedSyncs,
    'successRate': '${(successRate * 100).toStringAsFixed(1)}%',
    'averageSyncTime': '${averageSyncTime.inSeconds}s',
    'lastSuccessfulSync': lastSuccessfulSync?.toIso8601String(),
  };
}