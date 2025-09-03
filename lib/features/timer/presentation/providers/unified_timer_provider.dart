import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/unified_notification_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/use_cases/schedule_notification_use_case.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';

/// Unified Timer Provider that consolidates all timer functionality
/// Replaces the 9 overlapping timer systems with a single, clean implementation
class UnifiedTimerProvider extends StateNotifier<UnifiedTimerState?> with WidgetsBindingObserver {
  final Ref ref;
  
  // Core components
  Timer? _ticker;
  AudioPlayer? _audioPlayer;
  FlutterLocalNotificationsPlugin? _notifications;
  
  // iOS platform channel
  static const _iosChannel = MethodChannel('com.gymbro.optimized_timer');
  
  // Performance tracking
  DateTime? _lastTick;
  int _accuracyErrorCount = 0;
  
  // Duration tracking
  String? _currentExerciseId;
  
  // State persistence
  static const String _storageKey = 'unified_timer_state';
  Box<Map>? _storage;

  UnifiedTimerProvider(this.ref) : super(null) {
    _initializeComponents();
    _restoreState();
    
    // Register as lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  /// Initialize all required components
  Future<void> _initializeComponents() async {
    try {
      // Initialize storage
      _storage = await Hive.openBox<Map>('timer_storage');
      
      // Initialize audio player
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setPlayerMode(PlayerMode.lowLatency);
      
      // Initialize notifications
      if (Platform.isAndroid) {
        _notifications = FlutterLocalNotificationsPlugin();
        await _initializeNotifications();
      }
      
      DebugLogger.log(LogCategory.timer, 'UnifiedTimerProvider: Initialized successfully');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'UnifiedTimerProvider init error: $e');
    }
  }

  /// Initialize notification system for Android
  Future<void> _initializeNotifications() async {
    if (_notifications == null) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    
    await _notifications!.initialize(settings);
    
    // Create notification channel for timer completion
    const channel = AndroidNotificationChannel(
      'timer_completion',
      'Timer Completion',
      description: 'Notifications for when workout timers complete',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('timer_complete'),
    );
    
    final androidPlugin = _notifications!.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Start a new timer with specified duration and context
  Future<void> startTimer({
    required int durationSeconds,
    TimerType type = TimerType.rest,
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    String? workoutId,
    String? exerciseId,  // Added for duration tracking
    String? customSound,
  }) async {
    try {
      // Cancel any existing timer
      await stopTimer();
      
      // Store exercise ID for duration tracking
      _currentExerciseId = exerciseId;
      print('🎯 Timer started with exerciseId: $exerciseId for $exerciseName');
      
      // Create new timer state
      final newState = UnifiedTimerState(
        type: type,
        totalDurationSeconds: durationSeconds,
        exerciseName: exerciseName,
        currentSet: currentSet,
        totalSets: totalSets,
        workoutId: workoutId,
        customSoundName: customSound,
        audioEnabled: ref.read(appConfigProvider).soundEnabled,
      );
      
      // Start the timer
      state = newState.start();
      
      // Start internal ticker
      _startTicker();
      DebugLogger.log(LogCategory.timer, '🚀 UNIFIED Timer started: ticker should be running every 1s');
      
      // Schedule completion notification
      await _scheduleCompletion();
      
      // Start Live Activity on iOS
      if (Platform.isIOS) {
        await _startLiveActivity();
      }
      
      // Persist state
      await _saveState();
      
      DebugLogger.log(LogCategory.timer, 
        'Timer started: ${durationSeconds}s, type: $type');
        
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Timer start error: $e');
    }
  }

  /// Pause the current timer
  Future<void> pauseTimer() async {
    if (state?.canPause != true) return;
    
    try {
      state = state!.pause();
      _stopTicker();
      
      // Cancel scheduled notifications
      await _cancelScheduledNotifications();
      
      // Update Live Activity
      if (Platform.isIOS) {
        await _updateLiveActivity();
      }
      
      await _saveState();
      DebugLogger.log(LogCategory.timer, 'Timer paused');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Pause timer error: $e');
    }
  }

  /// Resume the paused timer
  Future<void> resumeTimer() async {
    if (state?.isPaused != true) return;
    
    try {
      state = state!.resume();
      _startTicker();
      
      // Reschedule completion
      await _scheduleCompletion();
      
      // Update Live Activity
      if (Platform.isIOS) {
        await _updateLiveActivity();
      }
      
      await _saveState();
      DebugLogger.log(LogCategory.timer, 'Timer resumed');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Resume timer error: $e');
    }
  }

  /// Stop and reset the timer
  Future<void> stopTimer() async {
    if (state == null) return;
    
    try {
      _stopTicker();
      await _cancelScheduledNotifications();
      
      if (Platform.isIOS) {
        await _stopLiveActivity();
      }
      
      state = null;
      await _clearState();
      
      DebugLogger.log(LogCategory.timer, 'Timer stopped');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Stop timer error: $e');
    }
  }

  /// Reset timer to initial state
  Future<void> resetTimer() async {
    if (state == null) return;
    
    try {
      _stopTicker();
      await _cancelScheduledNotifications();
      
      state = state!.reset();
      
      if (Platform.isIOS) {
        await _updateLiveActivity();
      }
      
      await _saveState();
      DebugLogger.log(LogCategory.timer, 'Timer reset');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Reset timer error: $e');
    }
  }

  /// Add time to current timer
  Future<void> addTime(int seconds) async {
    if (state?.isActive != true) return;
    
    try {
      // Add the extra seconds to both remaining and total duration
      final newRemainingSeconds = state!.remainingSeconds + seconds;
      final newTotalDurationSeconds = state!.totalDurationSeconds + seconds;
      
      state = state!.copyWith(
        remainingSeconds: newRemainingSeconds,
        totalDurationSeconds: newTotalDurationSeconds,
        endTime: state!.endTime?.add(Duration(seconds: seconds)),
      );
      
      // Update Live Activity
      if (Platform.isIOS && state!.liveActivityActive) {
        await _updateLiveActivity();
      }
      
      await _saveState();
      DebugLogger.log(LogCategory.timer, 'Added $seconds seconds to timer');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Add time error: $e');
    }
  }

  /// Internal ticker for timer updates
  void _startTicker() {
    _stopTicker();
    _lastTick = DateTime.now();
    
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Handle timer tick
  void _onTick() {
    if (state?.isActive != true) return;
    
    // Debug: log every 5th tick to avoid spam
    if ((state!.tickCount % 5) == 0) {
      DebugLogger.log(LogCategory.timer, '🔥 UNIFIED Timer tick #${state!.tickCount}: ${state!.remainingSeconds}s remaining, active=${state!.isActive}');
    }
    
    // Check accuracy
    final now = DateTime.now();
    if (_lastTick != null) {
      final expectedInterval = const Duration(seconds: 1);
      final actualInterval = now.difference(_lastTick!);
      final error = (actualInterval - expectedInterval).inMilliseconds;
      
      if (error.abs() > 100) {  // More than 100ms error
        _accuracyErrorCount++;
        DebugLogger.log(LogCategory.timer, 
          'Timer accuracy error: ${error}ms (count: $_accuracyErrorCount)');
      }
    }
    _lastTick = now;
    
    // CRITICAL FIX: Calculate remaining time based on actual time, not ticks
    // This prevents desynchronization when app goes to background
    int newRemainingSeconds;
    if (state!.endTime != null) {
      // Use endTime for precise calculation (immune to background suspension)
      final timeLeft = state!.endTime!.difference(now).inSeconds;
      newRemainingSeconds = timeLeft > 0 ? timeLeft : 0;
    } else {
      // Fallback to tick-based (should not happen with proper endTime)
      newRemainingSeconds = state!.remainingSeconds - 1;
      if (newRemainingSeconds < 0) newRemainingSeconds = 0;
    }
    
    // Update timer state with calculated remaining time
    final newState = state!.copyWith(
      remainingSeconds: newRemainingSeconds,
      tickCount: state!.tickCount + 1,
    );
    state = newState;
    
    // Handle completion
    if (newState.isCompleted && !newState.audioPlayed) {
      _onTimerComplete();
    }
    
    // Update Live Activity
    if (Platform.isIOS && newState.liveActivityActive) {
      _updateLiveActivity();
    }
    
    // Auto-save state every 10 ticks
    if (newState.tickCount % 10 == 0) {
      _saveState();
    }
  }

  /// Handle timer completion
  Future<void> _onTimerComplete() async {
    if (state?.isCompleted != true || state!.audioPlayed) return;
    
    try {
      _stopTicker();
      
      // Notify duration tracker that rest timer has ended
      // This starts tracking for the next set
      if (_currentExerciseId != null && state?.currentSet != null) {
        final durationTracker = ref.read(setDurationTrackerProvider);
        final nextSetNumber = state!.currentSet! + 1;
        durationTracker.onRestTimerEnded();
        
        DebugLogger.log(LogCategory.timer, 
          '✅ Duration tracking: onRestTimerEnded called for set $nextSetNumber of exercise $_currentExerciseId');
        print('✅ TIMER COMPLETED: Called onRestTimerEnded for exercise ${_currentExerciseId}, set $nextSetNumber');
      } else {
        print('⚠️ TIMER COMPLETED: Missing exerciseId or currentSet - duration tracking NOT started');
        print('   exerciseId: $_currentExerciseId, currentSet: ${state?.currentSet}');
      }
      
      // Play completion sound
      await _playCompletionSound();
      
      // Send unified notification
      await _sendTimerCompletionNotification();
      
      // Mark audio as played
      state = state!.markAudioPlayed();
      
      // Update Live Activity
      if (Platform.isIOS) {
        await _updateLiveActivity();
      }
      
      await _saveState();
      
      DebugLogger.log(LogCategory.timer, 'Timer completed successfully');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Timer completion error: $e');
    }
  }

  /// Play completion sound using the best available method
  Future<void> _playCompletionSound() async {
    if (state?.audioEnabled != true) return;
    
    try {
      final soundName = state?.customSoundName ?? 'timer_complete';
      
      if (Platform.isIOS) {
        // Use iOS native audio for reliability
        await _iosChannel.invokeMethod('playCompletionSound', {
          'soundName': soundName,
        });
      } else if (_audioPlayer != null) {
        // Use AudioPlayer for Android
        await _audioPlayer!.play(AssetSource('sounds/$soundName.mp3'));
      }
      
      DebugLogger.log(LogCategory.timer, 'Completion sound played: $soundName');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Audio playback error: $e');
      
      // Fallback to system sound
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (fallbackError) {
        DebugLogger.log(LogCategory.timer, 'Fallback audio error: $fallbackError');
      }
    }
  }

  /// Schedule timer completion notification
  Future<void> _scheduleCompletion() async {
    if (state?.remainingSeconds == null) return;
    
    try {
      if (Platform.isIOS) {
        // Use iOS native scheduling for better reliability
        await _iosChannel.invokeMethod('scheduleCompletion', {
          'duration': state!.remainingSeconds,
          'soundName': state!.customSoundName ?? 'timer_complete',
          'title': _getNotificationTitle(),
          'body': _getNotificationBody(),
        });
      } else if (_notifications != null) {
        // Use flutter_local_notifications for Android
        // Simply show immediate notification for Android fallback
        await _notifications!.show(
          0,
          _getNotificationTitle(),
          'Timer will complete in ${state!.remainingSeconds} seconds',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'timer_completion',
              'Timer Completion',
              channelDescription: 'Timer completion notifications',
              importance: Importance.high,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('timer_complete'),
            ),
          ),
        );
      }
      
      state = state!.scheduleNotification();
      DebugLogger.log(LogCategory.timer, 'Completion notification scheduled');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Schedule notification error: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> _cancelScheduledNotifications() async {
    try {
      if (Platform.isIOS) {
        await _iosChannel.invokeMethod('cancelScheduledNotifications');
      } else if (_notifications != null) {
        await _notifications!.cancelAll();
      }
      
      DebugLogger.log(LogCategory.timer, 'Scheduled notifications cancelled');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Cancel notifications error: $e');
    }
  }

  /// Send timer completion notification using the unified notification system
  Future<void> _sendTimerCompletionNotification() async {
    if (state == null) return;
    
    try {
      final notificationProvider = ref.read(unifiedNotificationProvider.notifier);
      
      // Create notification parameters
      final params = ScheduleNotificationParams(
        type: NotificationType.timerComplete,
        title: _getNotificationTitle(),
        body: _getNotificationBody(),
        scheduledTime: DateTime.now(), // Send immediately
        priority: NotificationPriority.high,
        soundName: state!.customSoundName ?? 'timer_complete',
        workoutId: state!.workoutId,
        exerciseId: state!.exerciseName,
        payload: {
          'timerType': state!.type.name,
          'originalDuration': state!.totalDurationSeconds,
          'completedAt': DateTime.now().toIso8601String(),
          'currentSet': state!.currentSet,
          'totalSets': state!.totalSets,
        },
        iosConfig: IOSNotificationConfig(
          critical: false,
          categoryId: 'TIMER_COMPLETE',
          threadId: 'timer_${state!.workoutId ?? 'default'}',
        ),
        androidConfig: AndroidNotificationConfig(
          channelId: 'timer_complete',
          channelName: 'Timer Complete',
          channelDescription: 'Notifications when workout timers complete',
          autoCancel: true,
        ),
      );
      
      // Schedule the notification
      final result = await notificationProvider.scheduleNotification(params);
      
      if (result.isSuccess) {
        DebugLogger.log(LogCategory.timer, 'Unified timer notification sent: ${result.notificationId}');
      } else {
        DebugLogger.log(LogCategory.timer, 'Unified timer notification failed: ${result.error}');
      }
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Unified notification error: $e');
      // Continue execution even if notification fails
    }
  }

  /// Start iOS Live Activity
  Future<void> _startLiveActivity() async {
    if (state == null) return;
    
    try {
      await _iosChannel.invokeMethod('startLiveActivity', {
        'totalSeconds': state!.totalDurationSeconds,
        'remainingSeconds': state!.remainingSeconds,
        'exerciseName': state!.exerciseName ?? 'Rest Timer',
        'currentSet': state!.currentSet,
        'totalSets': state!.totalSets,
        'timerType': state!.type.name,
      });
      
      state = state!.activateLiveActivity();
      DebugLogger.log(LogCategory.timer, 'Live Activity started');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Live Activity start error: $e');
    }
  }

  /// Update iOS Live Activity
  Future<void> _updateLiveActivity() async {
    if (state?.liveActivityActive != true) return;
    
    try {
      await _iosChannel.invokeMethod('updateLiveActivity', {
        'remainingSeconds': state!.remainingSeconds,
        'status': state!.status.name,
        'isRunning': state!.isActive,
      });
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Live Activity update error: $e');
    }
  }

  /// Stop iOS Live Activity
  Future<void> _stopLiveActivity() async {
    try {
      await _iosChannel.invokeMethod('stopLiveActivity');
      DebugLogger.log(LogCategory.timer, 'Live Activity stopped');
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Live Activity stop error: $e');
    }
  }

  /// Restore timer state from storage
  Future<void> _restoreState() async {
    try {
      final stored = _storage?.get(_storageKey);
      if (stored != null) {
        final restoredState = UnifiedTimerState.fromJson(Map<String, dynamic>.from(stored));
        
        // Check if timer should still be running
        if (restoredState.isActive && restoredState.endTime != null) {
          final now = DateTime.now();
          final timeLeft = restoredState.endTime!.difference(now).inSeconds;
          
          if (timeLeft > 0) {
            // Timer still has time left
            state = restoredState.copyWith(remainingSeconds: timeLeft);
            _startTicker();
            
            if (Platform.isIOS) {
              await _startLiveActivity();
            }
            
            DebugLogger.log(LogCategory.timer, 'Timer state restored with ${timeLeft}s remaining');
          } else {
            // Timer should be completed
            state = restoredState.complete();
            await _onTimerComplete();
          }
        } else {
          // Timer was paused or idle
          state = restoredState;
          DebugLogger.log(LogCategory.timer, 'Timer state restored: ${restoredState.status}');
        }
      }
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'State restoration error: $e');
      await _clearState();
    }
  }

  /// Save current state to storage
  Future<void> _saveState() async {
    try {
      if (state != null && _storage != null) {
        await _storage!.put(_storageKey, state!.toJson());
      }
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'State save error: $e');
    }
  }

  /// Clear saved state
  Future<void> _clearState() async {
    try {
      await _storage?.delete(_storageKey);
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'State clear error: $e');
    }
  }

  /// Get notification title based on timer context
  String _getNotificationTitle() {
    if (state == null) return 'Timer Complete';
    
    switch (state!.type) {
      case TimerType.rest:
        return 'Rest Complete';
      case TimerType.workout:
        return 'Workout Complete';
      case TimerType.warmup:
        return 'Warmup Complete';
      case TimerType.cooldown:
        return 'Cooldown Complete';
    }
  }

  /// Get notification body based on timer context
  String _getNotificationBody() {
    if (state == null) return 'Your timer has finished';
    
    final exercise = state!.exerciseName ?? 'Timer';
    if (state!.currentSet != null && state!.totalSets != null) {
      return '$exercise - Set ${state!.currentSet}/${state!.totalSets} complete';
    }
    return '$exercise complete';
  }

  /// Get performance metrics for monitoring
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'accuracyErrors': _accuracyErrorCount,
      'tickCount': state?.tickCount ?? 0,
      'pauseCount': state?.pauseHistory.length ?? 0,
      'isActive': state?.isActive ?? false,
      'hasAudioPlayer': _audioPlayer != null,
      'hasNotifications': _notifications != null,
    };
  }

  /// Handle app lifecycle changes to maintain timer sync
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    DebugLogger.log(LogCategory.timer, 'App lifecycle changed to: $state');
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppGoingBackground();
        break;
      case AppLifecycleState.resumed:
        _handleAppReturningForeground();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Do nothing for these states
        break;
    }
  }
  
  /// Handle app going to background
  void _handleAppGoingBackground() {
    if (state?.isActive != true) return;
    
    // Store the exact time when app went to background
    final backgroundTime = DateTime.now();
    state = state!.copyWith(
      lastBackgroundTime: backgroundTime,
    );
    
    _saveState();
    DebugLogger.log(LogCategory.timer, 'Timer backgrounded at: $backgroundTime');
  }
  
  /// Handle app returning to foreground - sync with Live Activity time
  Future<void> _handleAppReturningForeground() async {
    if (state?.isActive != true) return;
    
    try {
      final now = DateTime.now();
      
      // CRITICAL FIX: Use endTime for precise sync instead of background duration
      // This prevents the 16-17 second desynchronization issue
      if (state!.endTime != null) {
        final actualRemaining = state!.endTime!.difference(now).inSeconds;
        
        DebugLogger.log(LogCategory.timer, 
          'Timer sync: endTime says ${actualRemaining}s remaining (was ${state!.remainingSeconds}s)');
        
        if (actualRemaining <= 0) {
          // Timer has completed while in background
          state = state!.copyWith(
            remainingSeconds: 0,
            status: TimerStatus.completed,
            completionTime: state!.endTime,
          );
          await _onTimerComplete();
          return;
        }
        
        // Update state with precise remaining time
        state = state!.copyWith(
          remainingSeconds: actualRemaining,
          lastBackgroundTime: null,
        );
        
        // Restart ticker if not already running
        if (_ticker == null || !_ticker!.isActive) {
          _startTicker();
        }
        
        // Sync with iOS Live Activity for double verification
        if (Platform.isIOS && state!.liveActivityActive) {
          // This will double-check our calculation against the native timer
          await _syncWithLiveActivity();
        }
      } else {
        // Fallback for edge cases where endTime is missing
        DebugLogger.log(LogCategory.timer, 'WARNING: No endTime available, using Live Activity sync');
        
        if (Platform.isIOS && state!.liveActivityActive) {
          await _syncWithLiveActivity();
        } else {
          // Last resort: estimate based on background time (less accurate)
          if (state!.lastBackgroundTime != null) {
            final backgroundDuration = now.difference(state!.lastBackgroundTime!).inSeconds;
            final estimatedRemaining = state!.remainingSeconds - backgroundDuration;
            
            if (estimatedRemaining <= 0) {
              await _onTimerComplete();
            } else {
              state = state!.copyWith(
                remainingSeconds: estimatedRemaining,
                endTime: now.add(Duration(seconds: estimatedRemaining)),
              );
              _startTicker();
            }
          }
        }
      }
      
      await _saveState();
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Foreground sync error: $e');
    }
  }
  
  /// Sync timer state with iOS Live Activity
  Future<void> _syncWithLiveActivity() async {
    try {
      // Query Live Activity for current state
      final result = await _iosChannel.invokeMethod('getLiveActivityState') as Map?;
      
      if (result != null) {
        final liveActivityRemaining = result['remainingSeconds'] as int?;
        final liveActivityIsRunning = result['isRunning'] as bool? ?? false;
        
        if (liveActivityRemaining != null) {
          // Compare with our endTime calculation for accuracy check
          final now = DateTime.now();
          final ourCalculation = state!.endTime?.difference(now).inSeconds ?? state!.remainingSeconds;
          final difference = (ourCalculation - liveActivityRemaining).abs();
          
          DebugLogger.log(LogCategory.timer, 
            'Live Activity: ${liveActivityRemaining}s, Our calc: ${ourCalculation}s, Diff: ${difference}s');
          
          // Use Live Activity value only if significantly different (>2 seconds)
          // Otherwise trust our endTime calculation which is more precise
          if (difference > 2) {
            DebugLogger.log(LogCategory.timer, 
              'Significant difference detected, syncing with Live Activity');
            
            if (liveActivityRemaining <= 0) {
              // Timer completed according to Live Activity
              state = state!.copyWith(
                remainingSeconds: 0,
                status: TimerStatus.completed,
                completionTime: now,
              );
              await _onTimerComplete();
            } else if (liveActivityIsRunning) {
              // Sync with Live Activity time
              state = state!.copyWith(
                remainingSeconds: liveActivityRemaining,
                endTime: now.add(Duration(seconds: liveActivityRemaining)),
              );
            }
          } else {
            DebugLogger.log(LogCategory.timer, 'Times are in sync (within 2s tolerance)');
          }
          
          return;
        }
      }
      
      // Live Activity query failed - rely on our endTime calculation
      DebugLogger.log(LogCategory.timer, 'Live Activity query failed, using endTime calculation');
      
      // Our endTime-based calculation in _handleAppReturningForeground
      // should have already handled this correctly
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Live Activity sync error: $e');
      // Continue with our endTime-based calculation
    }
  }

  @override
  void dispose() {
    DebugLogger.log(LogCategory.timer, 'UnifiedTimerProvider: Disposing...');
    
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    _stopTicker();
    _audioPlayer?.dispose();
    
    if (Platform.isIOS) {
      _stopLiveActivity();
    }
    
    super.dispose();
  }
}

// Provider instances
final unifiedTimerProvider = StateNotifierProvider<UnifiedTimerProvider, UnifiedTimerState?>((ref) {
  return UnifiedTimerProvider(ref);
});

// Selective providers to reduce rebuilds
final timerIsActiveProvider = Provider<bool>((ref) {
  return ref.watch(unifiedTimerProvider.select((state) => state?.isActive ?? false));
});

final timerRemainingSecondsProvider = Provider<int>((ref) {
  return ref.watch(unifiedTimerProvider.select((state) => state?.remainingSeconds ?? 0));
});

final timerProgressProvider = Provider<double>((ref) {
  return ref.watch(unifiedTimerProvider.select((state) => state?.progress ?? 0.0));
});

final timerStatusProvider = Provider<TimerStatus?>((ref) {
  return ref.watch(unifiedTimerProvider.select((state) => state?.status));
});