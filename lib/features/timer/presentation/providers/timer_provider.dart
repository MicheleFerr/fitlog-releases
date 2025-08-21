import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/rest_timer.dart';
import '../../domain/services/notification_service.dart';
import '../../../../shared/presentation/providers/app_config_provider.dart';
import '../../../../shared/domain/entities/timer_sound.dart';
import 'live_activity_provider.dart';
import '../../../../core/utils/debug_logger.dart';
import '../../../workout/presentation/providers/set_duration_tracker_provider.dart';

// Current active timer provider
final currentTimerProvider = StateNotifierProvider<TimerNotifier, RestTimer?>((ref) {
  return TimerNotifier(ref);
});

class TimerNotifier extends StateNotifier<RestTimer?> {
  TimerNotifier(this.ref) : super(null) {
    _loadTimerFromStorage();
    _initNotificationService();
    _setupAppLifecycleListener();
  }

  final Ref ref;
  Timer? _timer;
  Timer? _scheduledAudioTimer; // ⏰ Timer per audio programmato
  Box? _timerBox;
  String? _currentActivityId;
  NotificationService? _notificationService;
  AudioPlayer? _audioPlayer;
  DateTime? _backgroundTime;
  DateTime? _completionTime; // ⏰ Timestamp quando timer si completa
  String? _currentExerciseId; // Track current exercise for duration tracking
  
  // Live Activity interactive controls
  String? get currentActivityId => _currentActivityId;

  @override
  void dispose() {
    _timer?.cancel();
    _scheduledAudioTimer?.cancel(); // ⏰ Cancella audio programmato
    _audioPlayer?.dispose();
    super.dispose();
  }

  /// Initialize storage
  Future<void> _initStorage() async {
    _timerBox ??= await Hive.openBox('timer_box');
  }

  /// Initialize notification service
  Future<void> _initNotificationService() async {
    try {
      _notificationService = NotificationService();
      await _notificationService!.initialize();
      await _notificationService!.requestPermissions();
    } catch (e) {
      DebugLogger.error('Failed to initialize notifications', e);
    }
  }

  /// Load timer from persistent storage
  Future<void> _loadTimerFromStorage() async {
    try {
      await _initStorage();
      final timerData = _timerBox?.get('current_timer');
      if (timerData != null) {
        final timer = RestTimer.fromJson(Map<String, dynamic>.from(timerData));
        // Only restore if timer was running and not too old (max 1 hour)
        if (timer.isActive && timer.startTime != null) {
          final elapsed = DateTime.now().difference(timer.startTime!);
          if (elapsed.inHours < 1) {
            final adjustedTimer = _adjustTimerForElapsedTime(timer, elapsed);
            state = adjustedTimer;
            if (adjustedTimer.isRunning) {
              _startTicker();
            }
          }
        }
      }
    } catch (e) {
      // If loading fails, start fresh
      state = null;
    }
  }

  /// Adjust timer for time that passed while app was closed
  RestTimer _adjustTimerForElapsedTime(RestTimer timer, Duration elapsed) {
    final elapsedSeconds = elapsed.inSeconds;
    final newRemaining = (timer.remainingSeconds - elapsedSeconds).clamp(0, timer.totalDurationSeconds);
    
    if (newRemaining <= 0) {
      return timer.complete();
    }
    
    return timer.copyWith(remainingSeconds: newRemaining);
  }

  /// Save timer to persistent storage
  Future<void> _saveTimerToStorage() async {
    try {
      await _initStorage();
      if (state != null) {
        await _timerBox?.put('current_timer', state!.toJson());
      } else {
        await _timerBox?.delete('current_timer');
      }
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Setup app lifecycle listener for background/foreground sync + audio session
  void _setupAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      final timestamp = DateTime.now().toIso8601String();
      DebugLogger.log(LogCategory.lifecycle, '=== APP LIFECYCLE EVENT [$timestamp] ===');
      DebugLogger.log(LogCategory.lifecycle, 'Event: $msg');
      DebugLogger.log(LogCategory.lifecycle, 'Current timer state: ${state?.isRunning == true ? "RUNNING" : "NOT_RUNNING"}');
      DebugLogger.log(LogCategory.lifecycle, 'Background time: $_backgroundTime');
      
      switch (msg) {
        case 'AppLifecycleState.paused':
          DebugLogger.log(LogCategory.lifecycle, '🟡 APP GOING TO BACKGROUND');
          _backgroundTime = DateTime.now();
          DebugLogger.log(LogCategory.lifecycle, 'Background time set to: $_backgroundTime');
          
          // ⚡ CRITICAL FIX: Stop ticker when going to background to prevent double-tick
          if (state?.isRunning == true) {
            DebugLogger.log(LogCategory.lifecycle, '⚡ STOPPING TICKER before background (prevents double-tick)');
            _stopTicker();
          }
          
          // ✅ INFORM NOTIFICATION SERVICE OF BACKGROUND STATE
          _notificationService?.setBackgroundState(true);
          DebugLogger.log(LogCategory.lifecycle, '✅ NotificationService informed: BACKGROUND mode');
          
          // ✅ SILENT AUDIO DISABLED - Relying on timer and direct completion audio
          // if (state?.isRunning == true) {
          //   DebugLogger.log(LogCategory.background, 'Timer is running - starting silent audio for background...');
          //   await _startSilentAudioForBackground();
          //   DebugLogger.log(LogCategory.background, '✅ Silent audio started for background execution');
          // } else {
          //   DebugLogger.log(LogCategory.background, 'Timer not running - no need for background audio');
          // }
          DebugLogger.log(LogCategory.background, 'Silent audio disabled - timer will play completion sound directly');
          break;
          
        case 'AppLifecycleState.resumed':
          DebugLogger.log(LogCategory.lifecycle, '🟢 APP RESUMING FROM BACKGROUND');
          
          // ✅ INFORM NOTIFICATION SERVICE OF FOREGROUND STATE
          _notificationService?.setBackgroundState(false);
          DebugLogger.log(LogCategory.lifecycle, '✅ NotificationService informed: FOREGROUND mode');
          
          // ✅ SILENT AUDIO DISABLED - No need to stop
          // await _stopSilentAudio();
          // DebugLogger.log(LogCategory.background, '✅ Silent audio stopped (foreground mode)');
          
          if (_backgroundTime != null && state != null) {
            final backgroundDuration = DateTime.now().difference(_backgroundTime!);
            DebugLogger.log(LogCategory.sync, 'Background duration: ${backgroundDuration.inSeconds}s');
            DebugLogger.log(LogCategory.sync, 'Syncing with Live Activity timer...');
            await _syncWithLiveActivityTimer();
            DebugLogger.log(LogCategory.sync, '✅ Sync completed');
          } else {
            DebugLogger.log(LogCategory.sync, 'No background time or state - skipping sync');
          }
          break;
          
        case 'AppLifecycleState.inactive':
          DebugLogger.log(LogCategory.lifecycle, '🟠 APP BECOMING INACTIVE');
          break;
          
        case 'AppLifecycleState.detached':
          DebugLogger.log(LogCategory.lifecycle, '🔴 APP DETACHED');
          break;
          
        default:
          DebugLogger.log(LogCategory.lifecycle, '⚪ UNKNOWN LIFECYCLE EVENT: $msg');
          break;
      }
      
      DebugLogger.log(LogCategory.lifecycle, '=== END LIFECYCLE EVENT [$timestamp] ===');
      return null;
    });
  }

  /// ✅ Start silent audio ONLY when timer is active and app goes to background
  Future<void> _startSilentAudioForBackground() async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      DebugLogger.log(LogCategory.background, '=== STARTING SILENT AUDIO FOR BACKGROUND [$timestamp] ===');
      
      // Clean up any existing audio player
      if (_audioPlayer != null) {
        try {
          await _audioPlayer?.stop();
          await _audioPlayer?.dispose();
          DebugLogger.log(LogCategory.background, 'Previous audio player cleaned up');
        } catch (e) {
          DebugLogger.log(LogCategory.background, 'Warning: Error cleaning up previous player: $e');
        }
      }
      
      // Create new player for silent audio
      _audioPlayer = AudioPlayer();
      DebugLogger.log(LogCategory.background, 'New AudioPlayer created for silent audio');
      
      // Configure for background playback with music-friendly settings
      await _audioPlayer!.setPlayerMode(PlayerMode.mediaPlayer); // Use mediaPlayer for better music compatibility
      await _audioPlayer!.setVolume(0.001); // Very low volume but not zero (needed for iOS background)
      await _audioPlayer!.setReleaseMode(ReleaseMode.loop); // Loop to maintain background
      DebugLogger.log(LogCategory.background, 'AudioPlayer configured for silent background loop (music-friendly)');
      
      // Start playing silent audio to keep app active in background
      final silentSource = AssetSource('sounds/silent_1s.wav');
      await _audioPlayer!.play(silentSource);
      DebugLogger.log(LogCategory.background, '✅ Silent audio loop started - app will stay active in background');
      DebugLogger.log(LogCategory.background, '=== SILENT AUDIO STARTED SUCCESSFULLY ===');
      
    } catch (e) {
      DebugLogger.error('FAILED TO START SILENT AUDIO', e);
      DebugLogger.log(LogCategory.background, 'Timer may not work properly in background');
    }
  }
  
  /// ✅ Stop silent audio when not needed
  Future<void> _stopSilentAudio() async {
    if (_audioPlayer != null) {
      try {
        DebugLogger.log(LogCategory.background, 'Stopping silent audio...');
        await _audioPlayer?.stop();
        await _audioPlayer?.dispose();
        _audioPlayer = null;
        DebugLogger.log(LogCategory.background, '✅ Silent audio stopped and player disposed');
      } catch (e) {
        DebugLogger.log(LogCategory.background, 'Error stopping silent audio: $e');
      }
    }
  }

  /// Sync Flutter timer with Live Activity native timer when app resumes
  Future<void> _syncWithLiveActivityTimer() async {
    if (state == null || _backgroundTime == null) return;
    
    final now = DateTime.now();
    final backgroundDuration = now.difference(_backgroundTime!);
    
    DebugLogger.log(LogCategory.sync, '=== SYNC WITH LIVE ACTIVITY ===');
    DebugLogger.log(LogCategory.sync, 'Background duration: ${backgroundDuration.inSeconds}s');
    DebugLogger.log(LogCategory.sync, 'Timer state before sync: ${state!.isRunning ? "RUNNING" : state!.isCompleted ? "COMPLETED" : "OTHER"}');
    DebugLogger.log(LogCategory.sync, 'Remaining seconds before sync: ${state!.remainingSeconds}s');
    
    // ⚡ CRITICAL FIX: Only adjust timer if it was actually running
    // Don't adjust if timer was paused or already completed
    if (state!.isRunning && backgroundDuration.inSeconds > 2) {
      final adjustedTimer = _adjustTimerForElapsedTime(state!, backgroundDuration);
      
      DebugLogger.log(LogCategory.sync, 'Timer adjusted by ${backgroundDuration.inSeconds}s');
      DebugLogger.log(LogCategory.sync, 'Remaining seconds after sync: ${adjustedTimer.remainingSeconds}s');
      DebugLogger.log(LogCategory.sync, 'Timer state after sync: ${adjustedTimer.isRunning ? "RUNNING" : adjustedTimer.isCompleted ? "COMPLETED" : "OTHER"}');
      
      // Update state to match Live Activity timer
      state = adjustedTimer;
      await _saveTimerToStorage();
      
      // Update Live Activity with synced time
      if (_currentActivityId != null) {
        await _updateLiveActivity();
      }
      
      // ⏰ SMART TEMPORAL LOGIC: Check if timer completed during background
      if (adjustedTimer.isCompleted) {
        DebugLogger.log(LogCategory.sync, 'Timer completed during background - checking if audio already played');
        
        // Check if audio was already played (within last 5 seconds)
        bool audioAlreadyPlayed = false;
        if (adjustedTimer.completionTime != null) {
          final timeSinceCompletion = now.difference(adjustedTimer.completionTime!);
          audioAlreadyPlayed = timeSinceCompletion.inSeconds < 5;
          
          if (audioAlreadyPlayed) {
            DebugLogger.log(LogCategory.sync, 'Audio already played ${timeSinceCompletion.inSeconds}s ago - skipping');
          }
        }
        
        // Call completion handler with skipAudio flag
        _onTimerCompleted(skipAudio: audioAlreadyPlayed || adjustedTimer.audioAlreadyPlayed);
        
      } else if (adjustedTimer.isRunning) {
        DebugLogger.log(LogCategory.sync, 'Timer still running - restarting ticker');
        _startTicker();
        
        // ⏰ RE-SCHEDULE audio per il tempo rimanente
        final remainingSeconds = adjustedTimer.remainingSeconds;
        if (remainingSeconds > 0) {
          DebugLogger.log(LogCategory.sync, 'Re-scheduling audio for remaining ${remainingSeconds}s');
          _scheduleCompletionAudio(remainingSeconds);
          
          // FORCE Live Activity sync after background
          if (_currentActivityId != null) {
            debugPrint('🔄 FORCE syncing Live Activity after background resume');
            final liveActivityService = ref.read(liveActivityProvider);
            await liveActivityService.forceUpdateLiveActivity(
              activityId: _currentActivityId!,
              timer: adjustedTimer,
              currentSet: adjustedTimer.currentSet ?? 1,
              totalSets: adjustedTimer.totalSets ?? 1,
            );
          }
        }
      }
    } else {
      DebugLogger.log(LogCategory.sync, 'Background duration too short - skipping sync');
    }
    
    _backgroundTime = null;
    DebugLogger.log(LogCategory.sync, '=== END SYNC WITH LIVE ACTIVITY ===');
  }

  /// Start a new rest timer
  Future<void> startRestTimer({
    required String exerciseName,
    required int durationSeconds,
    int currentSet = 1,
    int totalSets = 4,
    String? workoutId,
    String? exerciseId,  // Add exercise ID for duration tracking
  }) async {
    // Reset iOS audio tracking for new timer
    try {
      const platform = MethodChannel('com.gymbro.timer/audio');
      await platform.invokeMethod('resetAudioTracking');
      debugPrint('🔄 iOS audio tracking reset for new timer');
    } catch (e) {
      debugPrint('⚠️ Could not reset iOS audio tracking: $e');
    }
    
    // Stop any existing timer
    await stopTimer();

    // ⏰ RESET COMPLETION TIMESTAMP per nuovo timer
    _completionTime = null;
    DebugLogger.log(LogCategory.timer, 'NEW TIMER: Completion timestamp reset');
    
    // Store exercise ID for duration tracking when timer completes
    _currentExerciseId = exerciseId;

    // Create new timer
    final timer = RestTimer(
      type: TimerType.rest,
      totalDurationSeconds: durationSeconds,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workoutId,
    ).start();

    state = timer;
    await _saveTimerToStorage();
    
    debugPrint('🚀 === TIMER STARTED ===');
    debugPrint('🚀 Duration: ${durationSeconds}s');
    debugPrint('🚀 Exercise: $exerciseName');
    
    _startTicker();

    // ⏰ PROGRAMMA L'AUDIO per suonare ESATTAMENTE dopo durationSeconds
    debugPrint('🚀 Scheduling completion audio...');
    _scheduleCompletionAudio(durationSeconds);
    debugPrint('🚀 Audio scheduling complete');
    
    // Removed scheduled notifications - too complex and causing errors
    // Let iOS handle notifications through BackgroundAudioManager

    // Start Live Activity if available
    await _startLiveActivity();
    debugPrint('🚀 Timer fully initialized and running');
    
    // Live Activities showing timer only - no sync needed
  }

  /// Start a rest timer based on exercise type
  Future<void> startSmartRestTimer({
    required String exerciseName,
    required int reps,
    int currentSet = 1,
    int totalSets = 4,
    String? workoutId,
    String? exerciseId,  // Add exercise ID for duration tracking
  }) async {
    // Temporary: Use simple rest time logic until AppConfig is updated
    int restSeconds;
    if (reps <= 5) {
      // Strength training
      restSeconds = 180; // 3 minutes
    } else if (reps <= 12) {
      // Hypertrophy
      restSeconds = 90; // 1.5 minutes
    } else {
      // Endurance
      restSeconds = 60; // 1 minute
    }

    await startRestTimer(
      exerciseName: exerciseName,
      durationSeconds: restSeconds,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workoutId,
      exerciseId: exerciseId,
    );
  }

  /// Pause the current timer
  Future<void> pauseTimer() async {
    if (state?.isRunning == true) {
      // Cancel scheduled audio when pausing
      _cancelScheduledAudio();
      
      state = state!.pause();
      await _saveTimerToStorage();
      _stopTicker();
      
      // CRITICAL: Force update Live Activity for state change
      if (_currentActivityId != null) {
        debugPrint('⏸️ FORCE updating Live Activity for pause (bypasses throttling)');
        final liveActivityService = ref.read(liveActivityProvider);
        await liveActivityService.forceUpdateLiveActivity(
          activityId: _currentActivityId!,
          timer: state!,
          currentSet: state!.currentSet ?? 1,
          totalSets: state!.totalSets ?? 1,
        );
      }
    }
  }

  /// Resume the current timer
  Future<void> resumeTimer() async {
    if (state?.isPaused == true) {
      state = state!.resume();
      await _saveTimerToStorage();
      _startTicker();
      
      // Re-schedule audio with remaining time
      if (state!.remainingSeconds > 0) {
        debugPrint('🔊 Re-scheduling audio for resumed timer: ${state!.remainingSeconds}s');
        _scheduleCompletionAudio(state!.remainingSeconds);
      }
      
      // CRITICAL: Force update Live Activity for state change
      if (_currentActivityId != null) {
        debugPrint('▶️ FORCE updating Live Activity for resume (bypasses throttling)');
        final liveActivityService = ref.read(liveActivityProvider);
        await liveActivityService.forceUpdateLiveActivity(
          activityId: _currentActivityId!,
          timer: state!,
          currentSet: state!.currentSet ?? 1,
          totalSets: state!.totalSets ?? 1,
        );
      }
    }
  }

  /// Stop the current timer
  Future<void> stopTimer() async {
    if (state != null) {
      _stopTicker();
      _cancelScheduledAudio(); // ⏰ Cancella audio programmato
      // await _stopSilentAudio(); // ✅ SILENT AUDIO DISABLED
      state = null;
      
      // ⏹️ RESET COMPLETION TIMESTAMP when timer stopped
      _completionTime = null;
      DebugLogger.log(LogCategory.timer, 'STOP TIMER: Completion timestamp reset');
      
      await _saveTimerToStorage();
      await _endLiveActivity();
    }
  }

  /// Skip the current timer (complete immediately)
  Future<void> skipTimer() async {
    if (state != null) {
      state = state!.skip();
      await _saveTimerToStorage();
      _stopTicker();
      _cancelScheduledAudio(); // ⏰ Cancella audio programmato
      // await _stopSilentAudio(); // ✅ SILENT AUDIO DISABLED
      
      // v3.0.2 TEMP: Let iOS native handle audio when skipping
      DebugLogger.log(LogCategory.timer, 'SKIP TIMER - Triggering iOS native audio...');
      // await _playScheduledCompletionAudio();
      
      // Schedule iOS audio to play immediately
      const platform = MethodChannel('com.gymbro.timer/audio');
      await platform.invokeMethod('scheduleTimerSound', {
        'duration': 0.1,  // Play almost immediately
        'soundName': 'timer_complete',
      });
      
      await _endLiveActivity();
      
      // Auto-clear after 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (state?.isCompleted == true) {
          state = null;
          _saveTimerToStorage();
        }
      });
    }
  }

  /// Test audio method (for debugging)
  Future<void> testAudio() async {
    DebugLogger.debug('=== TEST AUDIO COMPLETO ===');
    DebugLogger.debug('FOREGROUND + BACKGROUND + NOTIFICATION + AVAudioSession');
    
    // Test 1: Verifica configurazione AudioSession
    DebugLogger.debug('Test 1: Verifica AudioSession setup...');
    await _testAudioSessionConfiguration();
    
    await Future.delayed(const Duration(seconds: 1));
    
    // Test 2: Test diretto di tutti i suoni disponibili
    DebugLogger.debug('Test 2: Testing all available sounds...');
    for (final sound in TimerSound.values) {
      debugPrint('🔊 Testing sound: ${sound.fileName}');
      try {
        final testPlayer = AudioPlayer();
        await testPlayer.setPlayerMode(PlayerMode.mediaPlayer);
        await testPlayer.setVolume(1.0);
        
        final assetPath = 'sounds/${sound.fileName}.wav';
        debugPrint('🔊 Playing: assets/$assetPath');
        
        await testPlayer.play(AssetSource(assetPath));
        await Future.delayed(const Duration(seconds: 2));
        await testPlayer.dispose();
        
        debugPrint('🔊 ✅ Sound ${sound.fileName} played successfully');
      } catch (e) {
        debugPrint('🔊 ❌ Error playing ${sound.fileName}: $e');
      }
    }
    
    // Test 3: Audio diretto in app (DISABLED - using iOS native)
    DebugLogger.debug('Test 3: Audio diretto nell\'app... (SKIPPED - using iOS native)');
    // await _playCompletionSound();
    
    // Aspetta un po' prima del quarto test
    await Future.delayed(const Duration(seconds: 3));
    
    // Test 4: Notifica con audio
    DebugLogger.debug('Test 4: Notifica con audio...');
    await _sendCompletionNotification();
  }
  
  /// ✅ Test configurazione AVAudioSession (diagnostico) - Semplificato
  Future<void> _testAudioSessionConfiguration() async {
    try {
      DebugLogger.debug('=== DIAGNOSI AVAUDIOSESSION ===');
      
      // Test semplice per verificare che non ci siano conflitti
      final testPlayer = AudioPlayer();
      
      // Solo PlayerMode - AppDelegate gestisce AVAudioSession
      await testPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      DebugLogger.debug('✅ PlayerMode OK - AppDelegate gestisce AVAudioSession');
      
      await testPlayer.dispose();
      DebugLogger.debug('=== FINE DIAGNOSI ===');
      
    } catch (e) {
      DebugLogger.error('Errore test configurazione', e);
    }
  }

  /// Add time to the current timer
  Future<void> addTime(int seconds) async {
    if (state?.isActive == true) {
      // Cancel old scheduled audio before changing duration
      _cancelScheduledAudio();
      
      state = state!.addTime(seconds);
      await _saveTimerToStorage();
      
      // Re-schedule audio with new duration
      if (state!.isRunning) {
        debugPrint('🔊 Re-scheduling audio after adding ${seconds}s');
        _scheduleCompletionAudio(state!.remainingSeconds);
      }
      
      // CRITICAL: Force update Live Activity with new total duration
      if (_currentActivityId != null) {
        debugPrint('📱 FORCE updating Live Activity with new duration (bypasses throttling)');
        final liveActivityService = ref.read(liveActivityProvider);
        await liveActivityService.forceUpdateLiveActivity(
          activityId: _currentActivityId!,
          timer: state!,
          currentSet: state!.currentSet ?? 1,
          totalSets: state!.totalSets ?? 1,
        );
      }
    }
  }

  /// Reset the current timer
  Future<void> resetTimer() async {
    if (state != null) {
      _stopTicker();
      _cancelScheduledAudio(); // ⏰ Cancella audio programmato
      // await _stopSilentAudio(); // ✅ SILENT AUDIO DISABLED
      state = state!.reset();
      
      // 🔄 RESET COMPLETION TIMESTAMP when timer reset
      _completionTime = null;
      DebugLogger.log(LogCategory.timer, 'RESET TIMER: Completion timestamp reset');
      
      await _saveTimerToStorage();
      await _updateLiveActivity();
      
      // ⏰ RE-SCHEDULE audio per il nuovo reset
      if (state!.isRunning) {
        DebugLogger.log(LogCategory.timer, 'Re-scheduling audio after reset');
        _scheduleCompletionAudio(state!.totalDurationSeconds);
      }
    }
  }

  /// Start the internal ticker
  void _startTicker() {
    _stopTicker(); // Ensure no duplicate timers
    debugPrint('⏱️ === STARTING TICKER ===');
    debugPrint('⏱️ Initial state: ${state?.remainingSeconds}s remaining');
    
    // ⚡ CRITICAL: Track tick timing to diagnose fast timer issue
    DateTime? lastTickTime;
    int tickCount = 0;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state?.isRunning == true) {
        // ⚡ TIMING DIAGNOSTIC
        final now = DateTime.now();
        if (lastTickTime != null) {
          final elapsed = now.difference(lastTickTime!).inMilliseconds;
          if (elapsed < 900 || elapsed > 1100) {
            debugPrint('⚡ WARNING: Abnormal tick interval: ${elapsed}ms (should be ~1000ms)');
          }
        }
        lastTickTime = now;
        tickCount++;
        
        final previousRemaining = state!.remainingSeconds;
        state = state!.tick();
        final newRemaining = state!.remainingSeconds;
        
        // Log every 10 seconds or when near completion
        if (newRemaining % 10 == 0 || newRemaining <= 5) {
          debugPrint('⏱️ TICK #$tickCount: ${newRemaining}s remaining (was ${previousRemaining}s) at ${now.toIso8601String()}');
        }
        
        _saveTimerToStorage();
        
        // Check if timer completed
        if (state!.isCompleted) {
          debugPrint('⏱️ 🎯 TIMER COMPLETION DETECTED!');
          debugPrint('⏱️ - isCompleted: ${state!.isCompleted}');
          debugPrint('⏱️ - remainingSeconds: ${state!.remainingSeconds}');
          debugPrint('⏱️ - Calling _onTimerCompleted()...');
          
          DebugLogger.log(LogCategory.timer, 'TIMER COMPLETED! (remainingSeconds: ${state!.remainingSeconds})');
          _updateLiveActivity(); // Update finale prima di completare
          _onTimerCompleted();
        } else {
          // Update Live Activity every second
          _updateLiveActivity();
        }
      } else {
        debugPrint('⏱️ Ticker running but timer not active (isRunning: ${state?.isRunning})');
      }
    });
    
    debugPrint('⏱️ ✅ Ticker started successfully');
  }

  /// Stop the internal ticker
  void _stopTicker() {
    _timer?.cancel();
    _timer = null;
  }

  /// ⏰ PROGRAMMA AUDIO per suonare ESATTAMENTE dopo X secondi - iOS Background Fix
  void _scheduleCompletionAudio(int durationSeconds) {
    // Cancella qualsiasi audio già programmato
    _cancelScheduledAudio();
    
    debugPrint('🔊 === SCHEDULING COMPLETION AUDIO ===');
    debugPrint('🔊 Duration: ${durationSeconds}s');
    debugPrint('🔊 Expected completion: ${DateTime.now().add(Duration(seconds: durationSeconds))}');
    
    DebugLogger.log(LogCategory.audio, '=== SCHEDULING COMPLETION AUDIO (iOS BG FIX) ===');
    DebugLogger.log(LogCategory.audio, 'Audio will play in: ${durationSeconds}s');
    DebugLogger.log(LogCategory.audio, 'Expected completion time: ${DateTime.now().add(Duration(seconds: durationSeconds))}');
    
    // 🚀 NUOVO: Usa il bridge nativo per iOS (funziona SEMPRE in background)
    _scheduleCompletionAudioNative(durationSeconds);
    
    debugPrint('🔊 ✅ Audio scheduled to play in ${durationSeconds}s');
    DebugLogger.log(LogCategory.audio, '✅ iOS native audio scheduled (notification-based for >10s)');
    DebugLogger.log(LogCategory.audio, '=== END SCHEDULING COMPLETION AUDIO ===');
  }

  /// 🚀 NUOVO: Usa il sistema nativo iOS per audio affidabile in background
  Future<void> _scheduleCompletionAudioNative(int durationSeconds) async {
    try {
      const platform = MethodChannel('com.gymbro.timer/audio');
      
      // Get selected sound from settings
      final appConfig = ref.read(appConfigProvider);
      final selectedSound = appConfig.timerSound;
      
      debugPrint('🎯 === NATIVE AUDIO SCHEDULING ===');
      debugPrint('🎯 Requesting native iOS to handle timer audio');
      debugPrint('🎯 Duration: ${durationSeconds}s');
      debugPrint('🎯 Sound: $selectedSound');
      
      // Chiama il bridge nativo iOS con il suono selezionato
      await platform.invokeMethod('scheduleTimerSound', {
        'duration': durationSeconds.toDouble(),
        'soundName': selectedSound,
      });
      
      debugPrint('🎯 ✅ Native iOS timer scheduled with sound: $selectedSound');
      DebugLogger.log(LogCategory.audio, '✅ Native iOS handling timer audio with $selectedSound');
      
      // Mantieni anche un timer locale per aggiornare UI e stato
      _scheduledAudioTimer = Timer(Duration(seconds: durationSeconds), () {
        debugPrint('⏰ Local timer completed - audio should have been played by native');
        _completionTime = DateTime.now();
        // Lo stato viene già aggiornato dal ticker
      });
      
    } catch (e) {
      debugPrint('❌ Failed to schedule native audio: $e');
      DebugLogger.error('Native audio scheduling failed', e);
      
      // Fallback al vecchio sistema
      _scheduleCompletionAudioWithSilentTrack(durationSeconds);
    }
  }

  /// 🔧 iOS BACKGROUND FIX: Schedule completion audio with enhanced reliability (FALLBACK)
  Future<void> _scheduleCompletionAudioWithSilentTrack(int durationSeconds) async {
    try {
      debugPrint('🎵 === SCHEDULING AUDIO TIMER ===');
      debugPrint('🎵 Creating Timer for ${durationSeconds} seconds');
      
      DebugLogger.log(LogCategory.audio, '=== SCHEDULING COMPLETION AUDIO ===');
      DebugLogger.log(LogCategory.audio, 'Timer will complete in ${durationSeconds} seconds');
      
      // Cancel any existing scheduled timer
      _cancelScheduledAudio();
      
      // Schedule primary timer to play completion audio
      _scheduledAudioTimer = Timer(Duration(seconds: durationSeconds), () async {
        final completionTimestamp = DateTime.now().toIso8601String();
        debugPrint('🎵 🔔 SCHEDULED TIMER FIRED! [${completionTimestamp}]');
        debugPrint('🎵 Attempting to play completion audio...');
        
        DebugLogger.log(LogCategory.timer, '=== TIMER COMPLETED [${completionTimestamp}] ===');
        
        // v3.0.2 TEMP: Disabled Flutter audio - using only iOS system sounds
        // try {
        //   await _playScheduledCompletionAudio();
        // } catch (e) {
        //   debugPrint('🎵 ❌ Primary audio playback failed: $e');
        //   DebugLogger.error('Primary audio playback failed', e);
        //   // Fallback to notification
        //   await _sendCompletionNotification();
        // }
        
        // Now just log that timer completed - iOS handles audio
        debugPrint('🎵 Timer completed - iOS native should have played audio');
      });
      
      debugPrint('🎵 ✅ Timer scheduled successfully - will fire in ${durationSeconds}s');
      DebugLogger.log(LogCategory.audio, '✅ Completion audio scheduled for ${durationSeconds}s from now');
      
      // v3.0.2 TEMP: Disabled backup notification - iOS native handles everything
      // // Also set up a backup notification (in case audio fails)
      // if (durationSeconds > 5) {
      //   Timer(Duration(seconds: durationSeconds + 1), () {
      //     // Check if audio already played
      //     if (state?.isCompleted == true && _completionTime == null) {
      //       DebugLogger.log(LogCategory.audio, 'Backup: Audio may have failed, sending notification');
      //       _sendCompletionNotification();
      //     }
      //   });
      // }
      
      DebugLogger.log(LogCategory.audio, 'Note: Silent audio will only be used if app goes to background');
      
    } catch (e) {
      DebugLogger.error('Failed to schedule completion audio', e);
      // Fallback to notification-only approach
      _scheduleCompletionAudioWithNotificationFallback(durationSeconds);
    }
  }
  
  /// 🔧 NOTIFICATION FALLBACK per quando silent audio fallisce
  void _scheduleCompletionAudioWithNotificationFallback(int durationSeconds) {
    DebugLogger.log(LogCategory.audio, '=== NOTIFICATION FALLBACK STRATEGY ===');
    DebugLogger.log(LogCategory.audio, 'Silent audio failed - using notification-only approach');
    
    _scheduledAudioTimer = Timer(Duration(seconds: durationSeconds), () async {
      final completionTimestamp = DateTime.now().toIso8601String();
      DebugLogger.log(LogCategory.notification, '=== NOTIFICATION FALLBACK TRIGGERED ===');
      
      // v3.0.2 TEMP: Disabled Flutter audio - using only iOS system sounds
      // try {
      //   await _playScheduledCompletionAudio();
      // } catch (e) {
      //   DebugLogger.log(LogCategory.notification, 'Audio failed, using notification: \$e');
      //   await _sendCompletionNotification();
      // }
      
      // v3.0.2 TEMP: iOS native already handles notifications and audio
      // await _sendCompletionNotification();
      debugPrint('🎵 iOS native handles all timer audio');
    });
  }
  
  /// 🔧 Fallback timer method (original behavior)
  void _scheduleCompletionAudioFallback(int durationSeconds) {
    DebugLogger.log(LogCategory.audio, 'Using fallback Timer method (may not work in background)');
    
    _scheduledAudioTimer = Timer(Duration(seconds: durationSeconds), () {
      final completionTimestamp = DateTime.now().toIso8601String();
      DebugLogger.log(LogCategory.timer, '=== FALLBACK TIMER TRIGGERED ===');
      // v3.0.2 TEMP: Disabled Flutter audio
      // _playScheduledCompletionAudio();
      debugPrint('🎵 Timer completed - relying on iOS native audio');
    });
  }

  /// ⏰ CANCELLA audio programmato
  void _cancelScheduledAudio() {
    if (_scheduledAudioTimer != null) {
      DebugLogger.log(LogCategory.audio, 'Cancelling previously scheduled audio timer');
      _scheduledAudioTimer!.cancel();
      _scheduledAudioTimer = null;
      
      // 🚀 NUOVO: Cancella anche l'audio nativo iOS
      try {
        const platform = MethodChannel('com.gymbro.timer/audio');
        platform.invokeMethod('cancelTimerSound');
        debugPrint('🎯 Native iOS timer cancelled');
      } catch (e) {
        debugPrint('⚠️ Could not cancel native timer: $e');
      }
      DebugLogger.log(LogCategory.audio, '✅ Scheduled audio timer cancelled');
    }
  }

  /// ⏰ SUONA l'audio di completamento programmato - Enhanced for iOS Background
  Future<void> _playScheduledCompletionAudio() async {
    final timestamp = DateTime.now().toIso8601String();
    final isBackground = _backgroundTime != null;
    
    try {
      DebugLogger.log(LogCategory.audio, '=== SCHEDULED AUDIO PLAYBACK START ===');
      DebugLogger.log(LogCategory.audio, 'Background mode: \${isBackground ? "YES" : "NO"}');
      DebugLogger.log(LogCategory.audio, 'This is the EXACT moment the timer should complete');
      
      // 🎵 ATTIVA SESSION per suonare in background/silenzioso
      if (isBackground) {
        // In background, usa il metodo semplificato che evita conflitti
        try {
          debugPrint('🔊 BACKGROUND: Activating audio session for playback...');
          const platform = MethodChannel('com.gymbro.audio/session');
          // Usa il nuovo metodo semplificato per background
          await platform.invokeMethod('activateForBackground');
          debugPrint('🔊 ✅ Audio session activated for background playback');
        } catch (e) {
          debugPrint('🔊 ⚠️ Could not activate audio session: $e');
          // Try fallback with enableDucking
          try {
            debugPrint('🔊 Trying fallback with enableDucking...');
            const platform = MethodChannel('com.gymbro.audio/session');
            await platform.invokeMethod('enableDucking');
            debugPrint('🔊 ✅ Fallback successful');
          } catch (e2) {
            debugPrint('🔊 ⚠️ Fallback also failed: $e2');
          }
        }
      } else {
        // In foreground, attiva ducking normalmente
        await _enableTemporaryDucking();
      }
      
      // Ottieni il suono selezionato dalle impostazioni
      final appConfig = ref.read(appConfigProvider);
      final selectedSound = appConfig.timerSound;
      final sound = TimerSound.fromFileName(selectedSound);
      
      DebugLogger.log(LogCategory.audio, 'Sound selection: \$selectedSound');
      debugPrint('🔊 Sound file: ${sound.fileName}');
      
      // 🔧 SIMPLIFIED: Always create a new player for completion sound
      debugPrint('🔊 Creating new AudioPlayer for completion sound');
      final completionPlayer = AudioPlayer();
      
      // Configure for playback (works in both foreground and background)
      // Use lowLatency in foreground for immediate response, mediaPlayer in background for reliability
      final playerMode = isBackground ? PlayerMode.mediaPlayer : PlayerMode.lowLatency;
      await completionPlayer.setPlayerMode(playerMode);
      await completionPlayer.setVolume(1.0); // Full volume for completion sound
      await completionPlayer.setReleaseMode(ReleaseMode.release); // Play once
      
      // Log player configuration
      debugPrint('🔊 Player configuration:');
      debugPrint('🔊 - Mode: ${playerMode == PlayerMode.mediaPlayer ? "mediaPlayer (background)" : "lowLatency (foreground)"}');
      debugPrint('🔊 - Volume: 1.0 (max)');
      debugPrint('🔊 - ReleaseMode: release');
      
      DebugLogger.log(LogCategory.audio, '✅ Completion player configured');
      debugPrint('🔊 Context: ${isBackground ? "BACKGROUND" : "FOREGROUND"}');
      
      // Setup listeners
      completionPlayer.onPlayerStateChanged.listen((playerState) {
        final listenerTimestamp = DateTime.now().toIso8601String();
        debugPrint('🔊 EVENT [$listenerTimestamp]: Completion player state: $playerState');
        if (playerState == PlayerState.playing) {
          DebugLogger.log(LogCategory.audio, '🎵 COMPLETION AUDIO IS NOW PLAYING\!');
        }
      });
      
      completionPlayer.onPlayerComplete.listen((_) async {
        final completeTimestamp = DateTime.now().toIso8601String();
        DebugLogger.log(LogCategory.audio, '✅ COMPLETION AUDIO FINISHED\!');
        
        // 🎵 RIPRISTINA AUDIO NORMALE dopo il completion sound
        if (isBackground) {
          // In background, disattiva ducking per ripristinare il mix normale
          try {
            const platform = MethodChannel('com.gymbro.audio/session');
            await platform.invokeMethod('disableDucking');
            debugPrint('🔊 ✅ Background audio session restored to normal');
          } catch (e) {
            debugPrint('🔊 ⚠️ Could not restore audio session: $e');
          }
        } else {
          // In foreground, disattiva ducking normalmente
          await _disableTemporaryDucking();
        }
        
        // Cleanup completion player
        try {
          await completionPlayer.dispose();
          debugPrint('🔊 ✅ Completion player disposed');
        } catch (e) {
          debugPrint('🔊 ⚠️ Error disposing completion player: $e');
        }
      });
      
      // Play the completion audio with retry logic
      final assetPath = 'sounds/${sound.fileName}.wav';
      debugPrint('🔊 Asset path: $assetPath');
      debugPrint('🔊 Sound fileName: ${sound.fileName}');
      debugPrint('🔊 Full asset path expected: assets/$assetPath');
      
      final audioSource = AssetSource(assetPath);
      DebugLogger.log(LogCategory.audio, '🎵 PLAYING COMPLETION AUDIO...');
      DebugLogger.log(LogCategory.audio, 'Asset path: $assetPath');
      
      // Try to play with retry logic
      var playAttempts = 0;
      var playSuccess = false;
      
      while (playAttempts < 3 && !playSuccess) {
        try {
          playAttempts++;
          DebugLogger.log(LogCategory.audio, 'Play attempt $playAttempts/3');
          
          debugPrint('🔊 Attempting to play: ${audioSource.path}');
          await completionPlayer.play(audioSource);
          debugPrint('🔊 Play command sent to AudioPlayer');
          
          // Wait a bit and verify
          await Future.delayed(const Duration(milliseconds: 200));
          final currentState = completionPlayer.state;
          
          if (currentState == PlayerState.playing) {
            playSuccess = true;
            DebugLogger.log(LogCategory.audio, '✅ COMPLETION AUDIO PLAY SUCCESS on attempt $playAttempts');
          } else {
            DebugLogger.log(LogCategory.audio, '⚠️ Play attempt $playAttempts failed, state: $currentState');
            if (playAttempts < 3) {
              // Reset player before retry
              await completionPlayer.stop();
              await Future.delayed(const Duration(milliseconds: 100));
            }
          }
        } catch (e) {
          DebugLogger.log(LogCategory.audio, '⚠️ Play attempt $playAttempts error: $e');
        }
      }
      
      final playTimestamp = DateTime.now().toIso8601String();
      DebugLogger.log(LogCategory.audio, '✅ COMPLETION AUDIO PLAY ATTEMPTS FINISHED');
      DebugLogger.log(LogCategory.audio, 'Context: \${isBackground ? "BACKGROUND" : "FOREGROUND"}');
      
      // Final validation
      final currentState = completionPlayer.state;
      debugPrint('🔊 Final completion player state: $currentState');
      
      if (currentState == PlayerState.playing) {
        DebugLogger.log(LogCategory.audio, '🎉 SUCCESS: Completion audio is playing\!');
        
        // 🔧 If in background, also send notification as backup
        if (isBackground) {
          DebugLogger.log(LogCategory.audio, 'BACKGROUND: Sending backup notification');
          await _sendCompletionNotification();
        }
      } else {
        debugPrint('🔊 ⚠️ WARNING: Completion audio state is: $currentState');
        
        // Fallback to notification if audio fails
        debugPrint('🔊 FALLBACK: Using notification for audio');
        await _sendCompletionNotification();
      }
      
      DebugLogger.log(LogCategory.audio, '=== SCHEDULED AUDIO PLAYBACK END ===');
      
    } catch (e) {
      final errorTimestamp = DateTime.now().toIso8601String();
      DebugLogger.error('=== SCHEDULED AUDIO FAILED [$errorTimestamp] ===');
      DebugLogger.error('Background mode: ${isBackground ? "YES" : "NO"}');
      DebugLogger.error('Error: $e');
      DebugLogger.error('Error type: ${e.runtimeType}');
      
      // Emergency fallback: always send notification if audio fails
      try {
        DebugLogger.error('EMERGENCY FALLBACK: Notification-only audio');
        await _sendCompletionNotification();
      } catch (e2) {
        DebugLogger.error('CRITICAL: All audio methods failed: $e2');
      }
      
      DebugLogger.error('=== END SCHEDULED AUDIO ERROR ===');
    }
  }

  /// Handle timer completion with Timestamp Tracking
  void _onTimerCompleted({bool skipAudio = false}) {
    final now = DateTime.now();
    final timestamp = now.toIso8601String();
    final isBackground = _backgroundTime != null;
    
    debugPrint('🏁 === TIMER COMPLETION HANDLER CALLED ===');
    debugPrint('🏁 Timestamp: $timestamp');
    debugPrint('🏁 Background mode: ${isBackground ? "YES" : "NO"}');
    debugPrint('🏁 Skip audio: ${skipAudio ? "YES" : "NO"}');
    debugPrint('🏁 Scheduled audio timer: ${_scheduledAudioTimer != null ? "EXISTS" : "NULL"}');
    
    DebugLogger.log(LogCategory.timer, '=== TIMER COMPLETION HANDLER ===');
    DebugLogger.log(LogCategory.timer, 'Background mode: ${isBackground ? "YES" : "NO"}');
    DebugLogger.log(LogCategory.timer, 'Skip audio: $skipAudio');
    
    // ⏰ TIMESTAMP TRACKING: Salva quando il timer si completa
    _completionTime = now;
    debugPrint('🏁 Completion time saved: $_completionTime');
    DebugLogger.log(LogCategory.timer, 'Completion time saved: $_completionTime');
    
    // Update state with completion time and audio flag
    if (state != null) {
      state = state!.copyWith(
        completionTime: now,
        audioAlreadyPlayed: skipAudio,  // Mark if audio was already played
      );
      _saveTimerToStorage();
    }
    
    // Notify duration tracker that rest timer has ended
    // This marks the start of the next set execution
    final durationTracker = ref.read(setDurationTrackerProvider);
    durationTracker.onRestTimerEnded();
    
    // If we have the exercise ID and current set, mark the next set as starting
    if (_currentExerciseId != null && state?.currentSet != null) {
      final nextSetNumber = state!.currentSet!;
      durationTracker.startSet(_currentExerciseId!, nextSetNumber);
      debugPrint('🏁 Set $nextSetNumber started for exercise $_currentExerciseId');
    }
    
    debugPrint('🏁 Duration tracker notified of rest timer end');
    DebugLogger.log(LogCategory.timer, 'Duration tracker notified of rest timer end');
    
    debugPrint('🏁 ⚠️ IMPORTANT: Audio should be triggered by scheduled timer, not here');
    debugPrint('🏁 If no audio plays, the scheduled timer may not have fired');
    DebugLogger.log(LogCategory.timer, 'Timer reached 00:00 - sending notification for audio');
    
    _stopTicker();
    debugPrint('🏁 Ticker stopped');
    
    // 🔊 ONLY send notification if audio hasn't been played yet
    if (!skipAudio) {
      debugPrint('🏁 Sending completion notification...');
      _sendCompletionNotification().then((_) {
        debugPrint('🏁 ✅ Completion notification sent');
        // Mark audio as played after sending notification
        if (state != null) {
          state = state!.copyWith(audioAlreadyPlayed: true);
          _saveTimerToStorage();
        }
      }).catchError((error) {
        debugPrint('🏁 ❌ Failed to send notification: $error');
      });
    } else {
      debugPrint('🏁 ⏭️ Skipping audio - already played in background');
    }
    
    _transitionToRPEMode();       // ✅ Transizione a modalità RPE nelle Live Activities esistenti
    debugPrint('🏁 Transitioned to RPE mode');
    
    debugPrint('🏁 === END TIMER COMPLETION HANDLER ===');
    DebugLogger.log(LogCategory.timer, '=== END TIMER COMPLETION ===');
    
    // Non auto-clear finché RPE non è completato
    // Il clear avverrà quando l'utente conferma RPE
  }

  /// 🔥 DUAL AUDIO SYSTEM: Primary AudioPlayer + Backup Notification
  Future<void> _executeDualAudioSystem(bool isBackground) async {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('🔥 === DUAL AUDIO SYSTEM START [$timestamp] ===');
    debugPrint('🔥 Background mode: ${isBackground ? "YES" : "NO"}');
    
    if (isBackground) {
      debugPrint('🔥 BACKGROUND MODE: Using notification-first strategy');
      
      // Strategy per background: Notification prima, poi AudioPlayer
      try {
        debugPrint('🔥 STEP 1: Immediate notification (most reliable in background)');
        await _sendCompletionNotification();
        
        // v3.0.2 TEMP: Disabled Flutter AudioPlayer
        // debugPrint('🔥 STEP 2: AudioPlayer attempt (may fail in deep background)');
        // await _playCompletionSound();
        
        debugPrint('🔥 ✅ Background notification sent (iOS handles audio)');
      } catch (e) {
        debugPrint('🔥 ❌ Background notification failed: $e');
      }
      
    } else {
      debugPrint('🔥 FOREGROUND MODE: Flutter notification + native system sounds');
      
      // v3.0.2: Send Flutter notification for UI feedback
      // iOS native handles system sounds (1005, 1016)
      try {
        debugPrint('🔥 Sending Flutter notification for foreground');
        await _sendCompletionNotification();
        debugPrint('🔥 ✅ Notification sent (native handles system sounds)');
      } catch (e) {
        debugPrint('🔥 ❌ Foreground notification failed: $e');
      }
    }
    
    debugPrint('🔥 === DUAL AUDIO SYSTEM END ===');
  }

  /// ✅ Transizione a modalità RPE nella Live Activity esistente
  Future<void> _transitionToRPEMode() async {
    if (state == null || _currentActivityId == null) {
      DebugLogger.log(LogCategory.liveActivity, 'Nessuna Live Activity attiva per RPE');
      _fallbackClearTimer();
      return;
    }
    
    final liveActivityService = ref.read(liveActivityProvider);
    
    try {
      DebugLogger.log(LogCategory.timer, 'TRANSITIONING TO RPE MODE...');
      
      // Aggiorna lo stato del timer per modalità RPE
      state = state!.awaitRPE();
      await _saveTimerToStorage();
      
      // Aggiorna la Live Activity esistente per mostrare RPE interface
      final success = await liveActivityService.updateLiveActivity(
        activityId: _currentActivityId!,
        timer: state!, // Timer ora in stato awaitingRPE
        currentSet: state!.currentSet ?? 1,
        totalSets: state!.totalSets ?? 1,
        targetReps: 10, // TODO: Ottenere dal set corrente
        weight: 20.0, // TODO: Ottenere dal set corrente
        actualReps: 10, // Default alle reps target
        selectedRPE: null, // Ancora da selezionare
      );
      
      if (success) {
        debugPrint('✅ Live Activity aggiornata per modalità RPE');
        // Setup callbacks per gestire risposte da Live Activity
        liveActivityService.setupRPECallbacks(
          onRPEConfirmed: (actualReps, rpe, notes) {
            _handleRPEConfirmed(actualReps, rpe, notes);
          },
          onRPECancelled: () {
            _handleRPECancelled();
          },
          onRepsModified: (newReps) {
            _handleRepsModified(newReps);
          },
        );
      } else {
        DebugLogger.error('Fallback: Update Live Activity fallito');
        _fallbackClearTimer();
      }
      
    } catch (e) {
      DebugLogger.error('Errore transizione RPE: $e');
      _fallbackClearTimer();
    }
  }

  /// Gestisce conferma RPE da Live Activity
  void _handleRPEConfirmed(int actualReps, int rpe, String? notes) {
    debugPrint('✅ RPE CONFERMATO: $actualReps reps, RPE: $rpe, note: $notes');
    
    // TODO: Salvare dati RPE nel workout corrente
    // TODO: Aggiornare ExerciseSet con actualReps, rpe, completedAt
    
    // Clear timer ora che RPE è completato
    state = null;
    
    // ✅ RESET COMPLETION TIMESTAMP after RPE confirmed
    _completionTime = null;
    debugPrint('✅ RPE CONFIRMED: Completion timestamp reset for next timer');
    
    _saveTimerToStorage();
    
    // TODO: Triggerare prossimo set se disponibile
    debugPrint('🔄 Set completato, pronto per il prossimo');
  }

  /// Gestisce cancellazione RPE
  void _handleRPECancelled() {
    DebugLogger.error('RPE CANCELLATO dall\'utente');
    _fallbackClearTimer();
  }

  /// Gestisce modifica reps da Live Activity
  void _handleRepsModified(int newReps) {
    debugPrint('🔄 REPS MODIFICATE: $newReps');
    // TODO: Aggiornare UI o stato se necessario
  }

  /// Fallback: clear timer se RPE non disponibile
  void _fallbackClearTimer() {
    debugPrint('🔄 FALLBACK: Clearing timer automaticamente');
    
    // Auto-clear dopo 3 secondi come backup
    Timer(const Duration(seconds: 3), () {
      if (state?.isCompleted == true) {
        state = null;
        
        // 🔄 RESET COMPLETION TIMESTAMP anche nel fallback
        _completionTime = null;
        debugPrint('🔄 FALLBACK: Completion timestamp reset');
        
        _saveTimerToStorage();
      }
    });
  }

  /// Play completion sound directly in app (more reliable than notifications)
  Future<void> _playCompletionSound() async {
    final timestamp = DateTime.now().toIso8601String();
    final isBackground = _backgroundTime != null;
    
    try {
      debugPrint('🔊 === AUDIO COMPLETION START [$timestamp] ===');
      DebugLogger.log(LogCategory.audio, 'Background mode: \${isBackground ? "YES" : "NO"}');
      debugPrint('🔊 Background time: $_backgroundTime');
      
      // Ottieni il suono selezionato dalle impostazioni
      final appConfig = ref.read(appConfigProvider);
      final selectedSound = appConfig.timerSound;
      final sound = TimerSound.fromFileName(selectedSound);
      
      DebugLogger.log(LogCategory.audio, 'Sound selection: \$selectedSound');
      debugPrint('🔊 Sound file: ${sound.fileName}');
      debugPrint('🔊 Asset path: sounds/${sound.fileName}.wav');
      
      // STEP 1: Cleanup existing player
      debugPrint('🔊 STEP 1: Cleaning up existing AudioPlayer...');
      if (_audioPlayer != null) {
        try {
          await _audioPlayer?.stop();
          await _audioPlayer?.dispose();
          debugPrint('🔊 ✅ Previous player cleaned up successfully');
        } catch (e) {
          debugPrint('🔊 ⚠️ Error cleaning previous player: $e');
        }
      } else {
        debugPrint('🔊 ✅ No previous player to cleanup');
      }
      
      // STEP 2: Create new player
      debugPrint('🔊 STEP 2: Creating new AudioPlayer...');
      _audioPlayer = AudioPlayer();
      debugPrint('🔊 ✅ New AudioPlayer instance created');
      
      // STEP 3: Configure player mode
      debugPrint('🔊 STEP 3: Configuring PlayerMode...');
      await _audioPlayer!.setPlayerMode(PlayerMode.lowLatency);
      debugPrint('🔊 ✅ PlayerMode.lowLatency configured');
      debugPrint('🔊 ℹ️ AVAudioSession managed by AppDelegate');
      
      // STEP 4: Set volume
      debugPrint('🔊 STEP 4: Setting volume...');
      await _audioPlayer!.setVolume(1.0);
      debugPrint('🔊 ✅ Volume set to maximum (1.0)');
      
      // STEP 5: Setup listeners BEFORE play
      debugPrint('🔊 STEP 5: Setting up event listeners...');
      _audioPlayer!.onPlayerStateChanged.listen((state) {
        final listenerTimestamp = DateTime.now().toIso8601String();
        debugPrint('🔊 EVENT [$listenerTimestamp]: Player state changed to: $state');
        if (state == PlayerState.playing) {
          debugPrint('🔊 🎵 AUDIO IS NOW PLAYING!');
        } else if (state == PlayerState.stopped) {
          debugPrint('🔊 ⏹️ AUDIO STOPPED');
        } else if (state == PlayerState.paused) {
          debugPrint('🔊 ⏸️ AUDIO PAUSED');
        }
      });
      
      _audioPlayer!.onDurationChanged.listen((duration) {
        final listenerTimestamp = DateTime.now().toIso8601String();
        debugPrint('🔊 EVENT [$listenerTimestamp]: Duration detected: $duration');
      });
      
      _audioPlayer!.onPlayerComplete.listen((_) {
        final listenerTimestamp = DateTime.now().toIso8601String();
        debugPrint('🔊 EVENT [$listenerTimestamp]: ✅ AUDIO PLAYBACK COMPLETED SUCCESSFULLY!');
      });
      
      _audioPlayer!.onLog.listen((message) {
        final listenerTimestamp = DateTime.now().toIso8601String();
        debugPrint('🔊 AUDIOPLAYER LOG [$listenerTimestamp]: $message');
      });
      
      debugPrint('🔊 ✅ Event listeners configured');
      
      // STEP 6: Attempt playback
      debugPrint('🔊 STEP 6: Starting audio playback...');
      final audioSource = AssetSource('sounds/${sound.fileName}.wav');
      debugPrint('🔊 Audio source created: ${audioSource.path}');
      
      debugPrint('🔊 🎵 EXECUTING PLAY COMMAND...');
      await _audioPlayer!.play(audioSource);
      
      final playTimestamp = DateTime.now().toIso8601String();
      debugPrint('🔊 ✅ PLAY COMMAND EXECUTED SUCCESSFULLY [$playTimestamp]');
      debugPrint('🔊 Background context: ${isBackground ? "IN BACKGROUND" : "IN FOREGROUND"}');
      
      // STEP 7: Post-play validation
      debugPrint('🔊 STEP 7: Post-play validation...');
      await Future.delayed(const Duration(milliseconds: 100));
      
      try {
        final currentState = _audioPlayer!.state;
        debugPrint('🔊 Current player state after play: $currentState');
        
        if (currentState == PlayerState.playing) {
          debugPrint('🔊 🎉 SUCCESS: Audio is actively playing!');
        } else {
          debugPrint('🔊 ⚠️ WARNING: Audio play command sent but player state is: $currentState');
        }
      } catch (e) {
        debugPrint('🔊 ⚠️ Could not validate player state: $e');
      }
      
      debugPrint('🔊 === AUDIO COMPLETION END [$timestamp] ===');
      
    } catch (e) {
      final errorTimestamp = DateTime.now().toIso8601String();
      DebugLogger.error('=== AUDIO COMPLETION FAILED [$errorTimestamp] ===');
      DebugLogger.error('Background mode: ${isBackground ? "YES" : "NO"}');
      DebugLogger.error('Error: $e');
      DebugLogger.error('Error type: ${e.runtimeType}');
      DebugLogger.error('Stack trace: ${e.toString()}');
      DebugLogger.error('=== END AUDIO ERROR ===');
    }
  }

  /// Send completion notification (backup/primary for background)
  Future<void> _sendCompletionNotification() async {
    final timestamp = DateTime.now().toIso8601String();
    final isBackground = _backgroundTime != null;
    
    DebugLogger.log(LogCategory.notification, '=== NOTIFICATION AUDIO START ===');
    DebugLogger.log(LogCategory.notification, 'Background mode: ${isBackground ? "YES" : "NO"}');
    DebugLogger.log(LogCategory.notification, 'NotificationService: AVAILABLE');
    DebugLogger.log(LogCategory.notification, 'Timer state: AVAILABLE');
    
    if (_notificationService == null) {
      debugPrint('📱 ❌ NotificationService not initialized');
      return;
    }
    
    if (state == null) {
      debugPrint('📱 ❌ Timer state is null');
      return;
    }
    
    try {
      // Ottieni il suono selezionato dalle impostazioni
      final appConfig = ref.read(appConfigProvider);
      final selectedSound = appConfig.timerSound;
      
      DebugLogger.log(LogCategory.notification, 'Sound file: $selectedSound');
      DebugLogger.log(LogCategory.notification, 'Exercise: ${state?.exerciseName ?? "N/A"}');
      DebugLogger.log(LogCategory.notification, 'Set: ${state?.currentSet}/${state?.totalSets}');
      DebugLogger.log(LogCategory.notification, 'Workout: N/A');
      
      DebugLogger.log(LogCategory.notification, 'SENDING notification with audio...');
      await _notificationService!.sendTimerCompletionNotification(
        exerciseName: state!.exerciseName ?? 'Exercise',
        currentSet: state!.currentSet ?? 1,
        totalSets: state!.totalSets ?? 1,
        workoutName: state!.workoutId,
        customSoundFile: selectedSound,
      );
      
      final successTimestamp = DateTime.now().toIso8601String();
      DebugLogger.log(LogCategory.notification, '✅ NOTIFICATION SENT SUCCESSFULLY');
      debugPrint('📱 Priority: ${isBackground ? "HIGH (Background)" : "NORMAL (Foreground)"}');
      
    } catch (e) {
      final errorTimestamp = DateTime.now().toIso8601String();
      debugPrint('📱 ❌ NOTIFICATION FAILED [$errorTimestamp]: $e');
      debugPrint('📱 Error type: ${e.runtimeType}');
      debugPrint('📱 Stack trace: ${e.toString()}');
    }
    
    DebugLogger.log(LogCategory.notification, '=== NOTIFICATION AUDIO END ===');
  }

  /// Start Live Activity (iOS only)
  Future<void> _startLiveActivity() async {
    if (state == null) return;
    
    final liveActivityService = ref.read(liveActivityProvider);
    
    try {
      _currentActivityId = await liveActivityService.startLiveActivity(
        exerciseName: state!.exerciseName ?? 'Rest Timer',
        timerType: state!.type.name,
        totalSeconds: state!.totalDurationSeconds,
        currentSet: state!.currentSet ?? 1,
        totalSets: state!.totalSets ?? 1,
        workoutName: state!.workoutId,
      );
    } catch (e) {
      // Live Activities not available or failed
      debugPrint('Failed to start Live Activity: $e');
    }
  }

  /// Update Live Activity
  Future<void> _updateLiveActivity({bool forceUpdate = false}) async {
    if (state == null || _currentActivityId == null) return;
    
    final liveActivityService = ref.read(liveActivityProvider);
    
    try {
      // For force updates (like when duration changes), use special update method
      if (forceUpdate) {
        await liveActivityService.updateLiveActivityDuration(
          activityId: _currentActivityId!,
          timer: state!,
          currentSet: state!.currentSet ?? 1,
          totalSets: state!.totalSets ?? 1,
        );
      } else {
        await liveActivityService.updateLiveActivity(
          activityId: _currentActivityId!,
          timer: state!,
          currentSet: state!.currentSet ?? 1,
          totalSets: state!.totalSets ?? 1,
        );
      }
    } catch (e) {
      // Live Activities not available or failed
      debugPrint('Failed to update Live Activity: $e');
    }
  }

  /// End Live Activity
  Future<void> _endLiveActivity() async {
    if (_currentActivityId == null) return;
    
    final liveActivityService = ref.read(liveActivityProvider);
    
    try {
      await liveActivityService.endLiveActivity(
        activityId: _currentActivityId!,
        dismissalPolicy: 'immediate',
      );
      _currentActivityId = null;
    } catch (e) {
      // Live Activities not available or failed
      debugPrint('Failed to end Live Activity: $e');
    }
  }

  /// 🎵 Attiva temporaneamente il ducking per far sentire meglio il suono di completamento
  Future<void> _enableTemporaryDucking() async {
    try {
      debugPrint('🎵 Enabling temporary audio ducking for completion sound...');
      const platform = MethodChannel('com.gymbro.audio/session');
      await platform.invokeMethod('enableDucking');
      debugPrint('🎵 ✅ Audio ducking enabled - other music will lower volume');
    } catch (e) {
      debugPrint('🎵 ⚠️ Could not enable ducking: $e');
      // Non critico - continua comunque
    }
  }
  
  /// 🎵 Disabilita il ducking e ripristina il mix normale con altre app audio
  Future<void> _disableTemporaryDucking() async {
    try {
      debugPrint('🎵 Disabling audio ducking - restoring normal music volume...');
      const platform = MethodChannel('com.gymbro.audio/session');
      await platform.invokeMethod('disableDucking');
      debugPrint('🎵 ✅ Audio ducking disabled - music returned to normal');
    } catch (e) {
      debugPrint('🎵 ⚠️ Could not disable ducking: $e');
      // Non critico - continua comunque
    }
  }

  // MARK: - Simplified Live Activities (display only, no interactive controls)
}

// Timer settings provider (simplified version)
final timerSettingsProvider = Provider<TimerSettings>((ref) {
  return const TimerSettings(
    strengthRestTime: 180,     // 3 minutes
    hypertrophyRestTime: 90,   // 1.5 minutes
    enduranceRestTime: 60,     // 1 minute
    autoStartTimer: true,
    soundEnabled: true,
    vibrationEnabled: true,
  );
});

class TimerSettings {
  final int strengthRestTime;
  final int hypertrophyRestTime;
  final int enduranceRestTime;
  final bool autoStartTimer;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const TimerSettings({
    required this.strengthRestTime,
    required this.hypertrophyRestTime,
    required this.enduranceRestTime,
    required this.autoStartTimer,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  /// Get rest time for specific rep count
  int getRestTimeForReps(int reps) {
    if (reps <= 5) return strengthRestTime;
    if (reps <= 12) return hypertrophyRestTime;
    return enduranceRestTime;
  }
}

// Timer history provider (for analytics)
final timerHistoryProvider = StateNotifierProvider<TimerHistoryNotifier, List<RestTimer>>((ref) {
  return TimerHistoryNotifier();
});

class TimerHistoryNotifier extends StateNotifier<List<RestTimer>> {
  TimerHistoryNotifier() : super([]);

  void addCompletedTimer(RestTimer timer) {
    if (timer.isCompleted) {
      state = [timer, ...state];
      // Keep only last 100 timers
      if (state.length > 100) {
        state = state.take(100).toList();
      }
    }
  }

  void clearHistory() {
    state = [];
  }

  List<RestTimer> getTimersForWorkout(String workoutId) {
    return state.where((timer) => timer.workoutId == workoutId).toList();
  }

  Duration getAverageRestTime() {
    if (state.isEmpty) return const Duration(seconds: 120);
    
    final totalSeconds = state.fold<int>(
      0, 
      (sum, timer) => sum + timer.totalDurationSeconds,
    );
    
    return Duration(seconds: totalSeconds ~/ state.length);
  }
}