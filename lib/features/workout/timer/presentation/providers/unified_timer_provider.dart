import 'dart:async'
    show Completer, StreamController, TimeoutException, Timer, unawaited;
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:gymbro_flutter_new/features/workout/timer/domain/models/timer_event.dart';
import 'package:gymbro_flutter_new/features/workout/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_session_la_provider.dart';
// ✅ FIX: Added explicit import for workoutSessionLAServiceProvider
import 'package:gymbro_flutter_new/features/workout/data/services/workout_session_la_service.dart'
    show WorkoutSessionMode;
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/metronome_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart'
    show WorkoutStatus;
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider.dart';
import 'package:gymbro_flutter_new/features/workout/timer/domain/services/notification_service.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:gymbro_flutter_new/shared/data/services/local_notifications_bootstrap.dart';
import 'package:gymbro_flutter_new/shared/data/services/local_timezone_service.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

// ⌚ Apple Watch Connectivity for rest timer sync
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/watch_connectivity_provider.dart';

/// Unified Timer Provider that consolidates all timer functionality
/// Replaces the 9 overlapping timer systems with a single, clean implementation
class UnifiedTimerProvider extends Notifier<UnifiedTimerState?>
    with WidgetsBindingObserver {
  @override
  UnifiedTimerState? build() {
    // CRITICAL FIX: Initialize asynchronously with proper completion tracking
    _initCompleter = Completer<void>();
    _initializeAsync();

    // Register as lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // FIX C10: Extracted to dedicated method to prevent re-registration on rebuild.
    _unifiedChannel.setMethodCallHandler(_handleIOSMethodCall);

    // Setup disposal callback
    ref.onDispose(() {
      _disposeResources();
    });

    return null;
  }

  /// Handles method calls from the native iOS side.
  /// Extracted from build() to prevent re-registration on every Riverpod rebuild (FIX C10).
  Future<dynamic> _handleIOSMethodCall(MethodCall call) async {
    if (_isDisposed) return null;

    if (!_isInitialized) {
      try {
        await _ensureInitialized();
      } catch (e) {
        return null;
      }
    }

    if (call.method == 'nativeNotificationDeepLink') {
      final payload = call.arguments is Map
          ? (call.arguments as Map)['payload'] as String?
          : null;
      final deepLink = extractNotificationDeepLink(payload);
      if (deepLink != null &&
          ref.read(pendingNotificationDeepLinkProvider) != deepLink) {
        ref.read(pendingNotificationDeepLinkProvider.notifier).state = deepLink;
      }

      try {
        await _unifiedChannel.invokeMethod<void>(
          'clearPendingNotificationPayload',
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [UnifiedTimer] Failed to clear native notification payload: $e',
          );
        }
      }

      return null;
    }

    if (call.method == 'nativeDebugLog') {
      if (kDebugMode) {
        final arguments = call.arguments;
        if (arguments is Map) {
          final category = arguments['category'];
          final message = arguments['message'];
          debugPrint('🍎 [NATIVE DEBUG][$category] $message');
        } else {
          debugPrint('🍎 [NATIVE DEBUG] ${call.arguments}');
        }
      }
      return null;
    }

    // Route metronome tick events from the native iOS side to MetronomeNotifier.
    if (call.method == 'metronomeTick') {
      final seconds = call.arguments as int? ?? 0;
      try {
        ref.read(metronomeProvider.notifier).updateFromNative(seconds);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[Metronome] Error updating from native: $e');
        }
      }
    }

    // FIX: Handle iOS memory warning — emergency save workout to prevent data loss
    if (call.method == 'onMemoryWarning') {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [MEMORY WARNING] iOS memory pressure — emergency saving workout',
        );
      }
      try {
        final currentWorkout = ref.read(currentWorkoutProvider);
        if (currentWorkout != null &&
            (currentWorkout.status == WorkoutStatus.inProgress ||
                currentWorkout.status == WorkoutStatus.paused)) {
          final autoSave = ref.read(workoutAutoSaveProvider.notifier);
          await autoSave.emergencySave(currentWorkout);
          if (kDebugMode) {
            debugPrint('✅ [MEMORY WARNING] Emergency save completed');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [MEMORY WARNING] Emergency save failed: $e');
        }
      }
      return null;
    }

    return null;
  }

  // Core components
  Timer? _ticker;
  AudioPlayer? _audioPlayer;
  FlutterLocalNotificationsPlugin? _notifications;

  // PERF: ValueNotifier for high-frequency updates (1Hz countdown)
  // Isolates per-second updates from Riverpod state notifications
  ValueNotifier<int>? _remainingSecondsNotifier;
  ValueNotifier<int> get remainingSecondsNotifier {
    _remainingSecondsNotifier ??= ValueNotifier<int>(
      state?.remainingSeconds ?? 0,
    );
    return _remainingSecondsNotifier!;
  }

  // PERF: Stream for discrete timer events (started, paused, completed)
  StreamController<TimerEvent>? _eventController;
  Stream<TimerEvent> get eventStream {
    _eventController ??= StreamController<TimerEvent>.broadcast();
    return _eventController!.stream;
  }

  // SINGLE unified platform channel - all timer operations go through here
  // This prevents race conditions and duplicate audio issues
  static const _unifiedChannel = MethodChannel(PlatformChannels.unified);

  // Performance tracking
  DateTime? _lastTick;
  int _accuracyErrorCount = 0;

  // Duration tracking
  String? _currentExerciseId;

  // ✅ Rest Timer Tracking: ID del set completato che precede questo rest timer
  // Usato per aggiornare il set con i dati del rest timer quando completa/skip
  String? _completedSetId;

  // PERFORMANCE OPTIMIZATION: UI update throttling
  DateTime? _lastUIUpdate;
  int _internalTickCount = 0;

  // PERFORMANCE OPTIMIZATION: Cached endTime for faster calculations
  DateTime? _cachedEndTime;

  // PERFORMANCE OPTIMIZATION: State persistence debouncing
  Timer? _saveDebounceTimer;
  Map<String, dynamic>? _pendingSaveData;

  // PERFORMANCE OPTIMIZATION: Live Activity update tracking
  Future<void>? _pendingLiveActivityUpdate;

  // CRITICAL: Atomic completion flag to prevent race conditions
  bool _completionInProgress = false;

  // CRITICAL: Atomic audio flag to prevent duplicate audio
  bool _audioInProgress = false;

  // CRITICAL FIX: Track recent local audio to avoid duplicate foreground playback.
  DateTime? _lastAudioPlayTime;

  // CRITICAL: Atomic state persistence to prevent corruption
  bool _stateWriteInProgress = false;

  // CRITICAL: Disposal flag to prevent operations after dispose
  bool _isDisposed = false;

  // FIX BUG-7: Debounce rapid +15s from Live Activity (second defense layer)
  DateTime? _lastAddTimeFromLA;

  // CRITICAL: Initialization state to prevent operations before ready
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  // CRITICAL FIX: Track initialization failures to prevent infinite retry
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3;

  // 🔐 User-scoped state persistence key
  String get _storageKey => userCacheKeys.userScopedKey('unified_timer_state');
  Box<Map>? _storage;

  /// 🔧 FIX: Ensure storage box is open before I/O operations
  /// This prevents "Box has already been closed" errors when the provider
  /// is recreated or when hot reload causes the box to be closed.
  Future<bool> _ensureStorageOpen() async {
    if (_storage != null && _storage!.isOpen) {
      return true;
    }

    // Box is closed or null - try to reopen
    try {
      final boxManager = ref.read(hiveBoxManagerProvider);
      _storage = await boxManager.openBox<Map>('timer_storage');
      if (kDebugMode) {
        debugPrint('🔧 [UnifiedTimer] Reopened closed timer_storage box');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [UnifiedTimer] Failed to reopen timer_storage: $e');
      }
      return false;
    }
  }

  /// CRITICAL FIX: Async initialization method that properly completes initialization
  Future<void> _initializeAsync() async {
    try {
      // Starting UnifiedTimerProvider async initialization (attempt $_initRetryCount)

      // Initialize all components in sequence
      await _initializeComponents();
      await _restoreState();

      // Mark as initialized
      _isInitialized = true;

      // CRITICAL FIX: Reset retry count on successful initialization
      _initRetryCount = 0;

      _initCompleter?.complete();

      // UnifiedTimerProvider initialization completed successfully
    } catch (e, stackTrace) {
      // Initialization failed (attempt $_initRetryCount): $e

      // Complete with error to prevent hanging
      _initCompleter?.completeError(e, stackTrace);
    }
  }

  /// CRITICAL FIX: Ensure initialization is complete before operations
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    // CRITICAL FIX: Prevent infinite retry loops
    if (_initRetryCount >= _maxInitRetries) {
      throw Exception(
        'UnifiedTimerProvider initialization failed after $_maxInitRetries attempts',
      );
    }

    if (_initCompleter != null) {
      try {
        // CRITICAL FIX: Add timeout to prevent indefinite waiting
        await _initCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException(
              'Timer initialization timeout after 10 seconds',
            );
          },
        );
      } catch (e) {
        _initRetryCount++;
        // Initialization failed (attempt $_initRetryCount/$_maxInitRetries), retrying

        // If initialization failed, try again with new completer
        _initCompleter = Completer<void>();
        await _initializeAsync();
      }
    } else {
      // Fallback: if no completer exists, initialize now
      _initRetryCount++;
      _initCompleter = Completer<void>();
      await _initializeAsync();
    }
  }

  /// Initialize all required components
  Future<void> _initializeComponents() async {
    try {
      // Initialize storage
      final boxManager = ref.read(hiveBoxManagerProvider);
      _storage = await boxManager.openBox<Map>('timer_storage');

      // FIX: Only initialize AudioPlayer on non-iOS platforms.
      // iOS uses ONLY the native bridge for audio (see _playTimerAudio).
      // Initializing AudioPlayer on iOS sets AVAudioSession category to .playback
      // WITHOUT .mixWithOthers, which stops any background music the user is listening to.
      if (!Platform.isIOS) {
        // Configure global audio context BEFORE creating any player instance
        // to ensure mixWithOthers is set and we don't steal audio focus.
        unawaited(
          AudioPlayer.global.setAudioContext(
            AudioContext(
              iOS: AudioContextIOS(
                category: AVAudioSessionCategory.ambient,
                options: const {AVAudioSessionOptions.mixWithOthers},
              ),
              android: const AudioContextAndroid(
                audioFocus: AndroidAudioFocus.none,
                contentType: AndroidContentType.sonification,
                usageType: AndroidUsageType.assistanceSonification,
              ),
            ),
          ),
        );
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setPlayerMode(PlayerMode.lowLatency);
      }

      // CRITICAL FIX: COMPLETELY DISABLE flutter_local_notifications on iOS
      // iOS uses ONLY native notifications to prevent duplicates and enable custom sounds
      if (Platform.isAndroid) {
        _notifications = FlutterLocalNotificationsPlugin();
        await _initializeNotifications();
        // Flutter notifications initialized for Android
      } else {
        // iOS: NO flutter_local_notifications - use only native bridge
        _notifications = null;
        // iOS notifications disabled - using native bridge only
      }

      // UnifiedTimerProvider initialized successfully
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Initialize notification system for Android
  Future<void> _initializeNotifications() async {
    if (_notifications == null) return;

    await LocalTimezoneService.ensureInitialized();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await LocalNotificationsBootstrap.ensureInitialized(
      plugin: _notifications!,
      settings: settings,
    );

    // Create notification channel for timer completion
    const channel = AndroidNotificationChannel(
      'timer_completion',
      'Timer Completion',
      description: 'Notifications for when workout timers complete',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('sound'),
    );

    final androidPlugin = _notifications!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
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
    String? exerciseId, // Added for duration tracking
    String? customSound,
    String?
    completedSetId, // ✅ Rest Timer Tracking: ID del set appena completato
  }) async {
    try {
      // CRITICAL FIX: Ensure initialization is complete before timer operations
      await _ensureInitialized();

      // Disposal check after initialization to ensure we're still valid
      if (_isDisposed) {
        // Cannot start timer: provider disposed
        return;
      }

      // CRITICAL FIX: If there's an active timer, SKIP it (not just stop)
      // This prevents the old timer from playing audio
      if (state != null) {
        // Existing timer detected - skipping it to prevent audio overlap

        if (Platform.isIOS) {
          try {
            await _unifiedChannel.invokeMethod('cancelScheduledCompletion');
          } catch (e) {
            // Continue cleanup even if native cancellation fails.
          }
        }

        // Stop ticker and cancel notifications
        _stopTicker();
        await _cancelScheduledNotifications();

        // End Live Activity for old timer
        if (Platform.isIOS && state!.liveActivityActive) {
          try {
            await _stopLiveActivity();
            // Old Live Activity ended
          } catch (e) {
            // Continue even if this fails
          }
        }

        // Clear state (no need to mark as completed/skipped since we're replacing it)
        state = null;
        await _clearState();

        // Previous timer cancelled - starting new one

        await Future.delayed(const Duration(milliseconds: 150));
      }

      // Store exercise ID for duration tracking
      _currentExerciseId = exerciseId;
      // ✅ Rest Timer Tracking: Store completed set ID for updating when timer ends
      _completedSetId = completedSetId;
      // Timer started with exerciseId: $exerciseId, completedSetId: $completedSetId

      // DEBUG: Log what custom sound is being set
      if (kDebugMode) {
        final currentConfig = ref.read(appConfigProvider);
        debugPrint('🔊 [TIMER SOUND DEBUG 2] Creating timer state:');
        debugPrint('  - customSound parameter received: "$customSound"');
        if (kDebugMode) {
          debugPrint(
            '  - AppConfig.timerSound current value: "${currentConfig.timerSound}"',
          );
        }
        if (kDebugMode) {
          debugPrint(
            '  - AppConfig.soundEnabled: ${currentConfig.soundEnabled}',
          );
        }
        if (kDebugMode) {
          debugPrint(
            '  - completionSoundName will be resolved once at arm time',
          );
        }
      }

      final resolvedCompletionSoundName =
          (customSound != null && customSound.trim().isNotEmpty)
          ? customSound.trim()
          : ref.read(appConfigProvider).timerSound.trim();

      // Create new timer state
      final newState = UnifiedTimerState(
        type: type,
        totalDurationSeconds: durationSeconds,
        exerciseName: exerciseName,
        currentSet: currentSet,
        totalSets: totalSets,
        workoutId: workoutId,
        customSoundName: customSound,
        completionSoundName: resolvedCompletionSoundName,
        completionDeliveryStrategy:
            TimerCompletionDeliveryStrategy.foregroundAudio,
        audioEnabled: true,
      );

      // Start the timer
      state = newState.start();
      _debugLogIOSCompletionTrace(
        'startTimer:stateStarted',
        extra: {
          'durationSeconds': durationSeconds,
          'type': type.name,
          'exerciseName': exerciseName,
          'currentSet': currentSet,
          'totalSets': totalSets,
        },
      );

      // PERF: Initialize ValueNotifier with starting value
      _remainingSecondsNotifier?.value = durationSeconds;

      // PERF: Emit start event
      _eventController?.add(
        TimerEvent.started(Duration(seconds: durationSeconds)),
      );

      // OPTIMIZATION: Cache endTime for faster tick calculations
      _cachedEndTime = state!.endTime;
      _internalTickCount = 0;
      _lastUIUpdate = null;

      // Start internal ticker
      _startTicker();

      if (Platform.isIOS) {
        await _applyIOSCompletionDeliveryStrategy();
      }

      // Start Live Activity on iOS
      if (Platform.isIOS) {
        await _startLiveActivity();
      }

      // ⌚ Notify Apple Watch about rest timer start
      if (Platform.isIOS && type == TimerType.rest) {
        unawaited(
          ref
              .read(watchConnectivityProvider.notifier)
              .sendRestTimerStarted(durationSeconds),
        );
        if (kDebugMode) {
          debugPrint(
            '⌚ [WATCH] Rest timer started notification sent: ${durationSeconds}s',
          );
        }
      }

      // Persist state
      await _saveState();

      // Timer started: ${durationSeconds}s
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Pause the current timer
  Future<void> pauseTimer() async {
    // CRITICAL FIX: Ensure initialization is complete before timer operations
    await _ensureInitialized();

    if (_isDisposed || state?.canPause != true) return;

    try {
      final remainingSeconds = state!.remainingSeconds;
      state = state!.pause();
      _stopTicker();

      // PERF: Emit pause event
      _eventController?.add(TimerEvent.paused());

      // Cancel scheduled notifications
      await _cancelScheduledNotifications();

      // Update Live Activity based on which system is active
      if (Platform.isIOS) {
        // Check if WorkoutSession Live Activity is active
        bool workoutSessionLAActive = false;
        try {
          final wsLAState = ref.read(workoutSessionLAProvider);
          workoutSessionLAActive =
              wsLAState.isActive && wsLAState.mode == WorkoutSessionMode.rest;
        } catch (e) {
          // Provider not available
        }

        if (workoutSessionLAActive) {
          // Pause WorkoutSession Live Activity
          debugPrint(
            '[UnifiedTimer] ⏸️ Pausing WorkoutSession LA with $remainingSeconds seconds',
          );
          final wsLAService = ref.read(workoutSessionLAServiceProvider);
          await wsLAService.pauseRestTimer(remainingSeconds);
        } else {
          await _updateLiveActivity();
        }
      }

      // ⌚ Notify Apple Watch about rest timer pause
      if (Platform.isIOS && state?.type == TimerType.rest) {
        unawaited(
          ref
              .read(watchConnectivityProvider.notifier)
              .sendRestTimerPaused(state!.remainingSeconds),
        );
        if (kDebugMode) {
          debugPrint(
            '⌚ [WATCH] Rest timer paused notification sent: ${state!.remainingSeconds}s remaining',
          );
        }
      }

      await _saveState();
      // Timer paused
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Resume the paused timer
  Future<void> resumeTimer() async {
    // CRITICAL FIX: Ensure initialization is complete before timer operations
    await _ensureInitialized();

    if (_isDisposed || state?.isPaused != true) return;

    try {
      final remainingSeconds = state!.remainingSeconds;
      state = state!.resume();
      _debugLogIOSCompletionTrace(
        'resumeTimer:stateResumed',
        extra: {'remainingSecondsBeforeResume': remainingSeconds},
      );
      _startTicker();

      // PERF: Emit resume event
      _eventController?.add(TimerEvent.resumed());

      if (Platform.isIOS) {
        await _applyIOSCompletionDeliveryStrategy();
      }

      // Update Live Activity based on which system is active
      if (Platform.isIOS) {
        // Check if WorkoutSession Live Activity is active
        bool workoutSessionLAActive = false;
        try {
          final wsLAState = ref.read(workoutSessionLAProvider);
          workoutSessionLAActive =
              wsLAState.isActive && wsLAState.mode == WorkoutSessionMode.rest;
        } catch (e) {
          // Provider not available
        }

        if (workoutSessionLAActive) {
          // Resume WorkoutSession Live Activity
          debugPrint(
            '[UnifiedTimer] ▶️ Resuming WorkoutSession LA with $remainingSeconds seconds',
          );
          final wsLAService = ref.read(workoutSessionLAServiceProvider);
          await wsLAService.resumeRestTimer(remainingSeconds);
        } else {
          await _updateLiveActivity();
        }
      }

      // ⌚ Notify Apple Watch about rest timer resume
      if (Platform.isIOS && state?.type == TimerType.rest) {
        unawaited(
          ref
              .read(watchConnectivityProvider.notifier)
              .sendRestTimerResumed(state!.remainingSeconds),
        );
        if (kDebugMode) {
          debugPrint(
            '⌚ [WATCH] Rest timer resumed notification sent: ${state!.remainingSeconds}s remaining',
          );
        }
      }

      await _saveState();
      // Timer resumed
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Stop and reset the timer
  Future<void> stopTimer() async {
    // CRITICAL FIX: Ensure initialization is complete before timer operations
    await _ensureInitialized();

    if (_isDisposed || state == null) return;

    try {
      _stopTicker();
      await _cancelScheduledNotifications();

      if (Platform.isIOS) {
        // Cancel through unified channel
        await _unifiedChannel.invokeMethod('stopTimer');
        await _stopLiveActivity();
      }

      state = null;
      await _clearState();

      // Timer stopped
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Reset timer to initial state
  Future<void> resetTimer() async {
    // CRITICAL FIX: Ensure initialization is complete before timer operations
    await _ensureInitialized();

    if (_isDisposed || state == null) return;

    try {
      _stopTicker();
      await _cancelScheduledNotifications();

      state = state!.reset();

      // PERF: Reset ValueNotifier
      _remainingSecondsNotifier?.value = 0;

      if (Platform.isIOS) {
        await _updateLiveActivity();
      }

      await _saveState();
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Add time to current timer
  ///
  /// This method updates Flutter state and syncs to Live Activity + Watch.
  /// The sync behavior depends on which Live Activity system is active:
  /// - Workout Session LA: Updates via workoutSessionLAService + Watch notification
  /// - Legacy timer LA: Updates via _updateLiveActivity()
  ///
  /// [fromLiveActivity] - Set to true when called from Live Activity button tap.
  /// This prevents double-updating the LA since the AppIntent already updated it.
  Future<void> addTime(int seconds, {bool fromLiveActivity = false}) async {
    if (kDebugMode) {
      debugPrint(
        '[UnifiedTimer] ⏰ addTime called: +$seconds seconds, fromLiveActivity=$fromLiveActivity',
      );
    }

    // FIX BUG-7: Debounce rapid taps from Live Activity (<800ms apart)
    if (fromLiveActivity) {
      final now = DateTime.now();
      if (_lastAddTimeFromLA != null &&
          now.difference(_lastAddTimeFromLA!).inMilliseconds < 800) {
        if (kDebugMode) {
          debugPrint('[UnifiedTimer] ⚠️ addTime debounced — too soon from LA');
        }
        return;
      }
      _lastAddTimeFromLA = now;
    }

    // CRITICAL FIX: Ensure initialization is complete before timer operations
    await _ensureInitialized();

    if (_isDisposed) {
      if (kDebugMode) {
        debugPrint('[UnifiedTimer] ❌ addTime: provider is disposed');
      }
      return;
    }

    if (state == null) {
      if (kDebugMode) {
        debugPrint('[UnifiedTimer] ❌ addTime: state is null');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[UnifiedTimer] 📊 Current state: isActive=${state!.isActive}, remaining=${state!.remainingSeconds}s, total=${state!.totalDurationSeconds}s',
      );
    }

    try {
      // Add the extra seconds to both remaining and total duration
      final newRemainingSeconds = state!.remainingSeconds + seconds;
      final newTotalDurationSeconds = state!.totalDurationSeconds + seconds;
      // ✅ Rest Timer Tracking: accumulate seconds added
      final newSecondsAdded = state!.secondsAdded + seconds;

      state = state!.copyWith(
        remainingSeconds: newRemainingSeconds,
        totalDurationSeconds: newTotalDurationSeconds,
        endTime: state!.endTime?.add(Duration(seconds: seconds)),
        secondsAdded: newSecondsAdded, // ✅ Track cumulative added time
      );
      _debugLogIOSCompletionTrace(
        'addTime:stateUpdated',
        extra: {
          'secondsAddedNow': seconds,
          'newRemainingSeconds': newRemainingSeconds,
          'newTotalDurationSeconds': newTotalDurationSeconds,
          'fromLiveActivity': fromLiveActivity,
        },
      );

      // CRITICAL FIX: Update _cachedEndTime to match the new endTime
      // Without this, _calculateRemainingSeconds() uses stale cached value
      // and the next tick overwrites the added time!
      _cachedEndTime = state!.endTime;

      // PERF: Sync ValueNotifier with new remaining seconds
      _remainingSecondsNotifier?.value = newRemainingSeconds;

      if (kDebugMode) {
        debugPrint(
          '[UnifiedTimer] ✅ Time added: newRemaining=${newRemainingSeconds}s, newTotal=${newTotalDurationSeconds}s, secondsAdded=${newSecondsAdded}s, cachedEndTime updated',
        );
      }

      if (Platform.isIOS) {
        try {
          await _applyIOSCompletionDeliveryStrategy();
          if (kDebugMode) {
            debugPrint(
              '[UnifiedTimer] ✅ Rescheduled iOS completion for +${seconds}s extension',
            );
          }
        } catch (e) {
          debugPrint('[UnifiedTimer] ⚠️ Failed to reschedule completion: $e');
        }
      }

      // Sync to Live Activity + Watch
      if (Platform.isIOS) {
        // Check which Live Activity system is active
        bool workoutSessionLAActive = false;
        try {
          final wsLAState = ref.read(workoutSessionLAProvider);
          workoutSessionLAActive = wsLAState.isActive;
          if (kDebugMode) {
            debugPrint(
              '[UnifiedTimer] 📊 Workout Session LA active: $workoutSessionLAActive',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[UnifiedTimer] ⚠️ Could not read workoutSessionLAProvider: $e',
            );
          }
          // Provider not available, use legacy system
        }

        // Sync Live Activity
        if (workoutSessionLAActive) {
          final newEndTime = state!.endTime;
          if (newEndTime != null) {
            if (kDebugMode) {
              debugPrint(
                '[UnifiedTimer] 📡 Syncing absolute end time to LA: $newEndTime',
              );
            }
            final wsLAService = ref.read(workoutSessionLAServiceProvider);
            await wsLAService.syncRestEndTime(newEndTime);
            if (kDebugMode) {
              debugPrint('[UnifiedTimer] ✅ LA end time synced');
            }
          }
        } else if (state!.liveActivityActive) {
          if (kDebugMode) {
            debugPrint('[UnifiedTimer] 📡 Using legacy LA update');
          }
          await _updateLiveActivity();
        }

        // FIX: Always notify Apple Watch, regardless of Live Activity state.
        // Previously Watch sync only happened inside workoutSessionLAActive block,
        // so Watch would not get the extension if no LA was active.
        await ref
            .read(watchConnectivityProvider.notifier)
            .sendRestTimerExtended(seconds, newRemainingSeconds);
        if (kDebugMode) {
          debugPrint(
            '[UnifiedTimer] ⌚ Watch notified: +${seconds}s (remaining=${newRemainingSeconds}s)',
          );
        }
      }

      await _saveState();
      if (kDebugMode) {
        debugPrint('[UnifiedTimer] ✅ addTime completed successfully');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[UnifiedTimer] ❌ addTime error: $e');
        debugPrint('[UnifiedTimer] ❌ Stack trace: $stack');
      }
    }
  }

  /// Skip the current timer (complete immediately without audio)
  Future<void> skipTimer() async {
    // CRITICAL FIX: Ensure initialization is complete before timer operations
    await _ensureInitialized();

    if (_isDisposed || state == null) return;

    try {
      if (Platform.isIOS) {
        await _cancelScheduledNotifications();
      }

      // ⌚ Notify Apple Watch that rest was skipped
      if (Platform.isIOS && state!.type == TimerType.rest) {
        unawaited(
          ref.read(watchConnectivityProvider.notifier).sendRestTimerSkipped(),
        );
        if (kDebugMode) {
          debugPrint('⌚ [WATCH] Rest timer skipped notification sent');
        }
      }

      _stopTicker();
      if (!Platform.isIOS) {
        await _cancelScheduledNotifications();
      }

      // Mark timer as skipped - this prevents audio playback
      state = state!.skip();

      // PERF: Update ValueNotifier and emit skip event
      _remainingSecondsNotifier?.value = 0;
      _eventController?.add(TimerEvent.skipped());

      // Update Live Activity with skipped state
      if (Platform.isIOS) {
        // ✅ FIX: Check if WorkoutSession LA is active - transition it instead of stopping
        try {
          final laState = ref.read(workoutSessionLAProvider);
          if (laState.isActive && laState.mode == WorkoutSessionMode.rest) {
            // WorkoutSession LA is in REST mode - transition to EXERCISE
            if (kDebugMode) {
              debugPrint(
                '⏭️ [SKIP-FIX] WorkoutSession LA is in REST - transitioning to EXERCISE',
              );
            }
            final workout = ref.read(currentWorkoutProvider);
            if (workout != null) {
              for (final exercise in workout.exercises) {
                final incompleteSetIndex = exercise.sets.indexWhere(
                  (set) => !set.isCompleted,
                );
                if (incompleteSetIndex != -1) {
                  final completedExercises = workout.exercises
                      .where((e) => e.sets.every((s) => s.isCompleted))
                      .length;
                  await ref
                      .read(workoutSessionLAProvider.notifier)
                      .transitionToExercise(
                        exercise: exercise,
                        setIndex: incompleteSetIndex + 1,
                        completedExercises: completedExercises,
                        totalExercises: workout.exercises.length,
                      );
                  if (kDebugMode) {
                    debugPrint(
                      '✅ [SKIP-FIX] LA transitioned to EXERCISE: ${exercise.name} set ${incompleteSetIndex + 1}',
                    );
                  }
                  break;
                }
              }
            }
          } else if (state!.liveActivityActive) {
            // Timer's own LA was started - stop it
            await _updateLiveActivity();
            await _stopLiveActivity();
          }
        } catch (e) {
          // Fallback: only stop if timer LA was actually active
          if (state!.liveActivityActive) {
            await _updateLiveActivity();
            await _stopLiveActivity();
          }
        }
      }

      // ✅ Rest Timer Tracking: Update the completed set with rest timer data (skipped)
      if (_currentExerciseId != null && _completedSetId != null) {
        try {
          // Calculate actual rest time from the original duration minus remaining
          final configuredDuration =
              state!.totalDurationSeconds - state!.secondsAdded;
          final actualRestSeconds =
              configuredDuration - state!.remainingSeconds;

          ref
              .read(currentWorkoutProvider.notifier)
              .updateSetRestTimerData(
                exerciseId: _currentExerciseId!,
                setId: _completedSetId!,
                restTimerSkipped: true, // Timer was skipped
                restTimerSecondsRemaining: state!.remainingSeconds > 0
                    ? state!.remainingSeconds
                    : null,
                restTimerSecondsAdded: state!.secondsAdded > 0
                    ? state!.secondsAdded
                    : null,
                actualRestSeconds: actualRestSeconds > 0
                    ? actualRestSeconds
                    : 0,
              );

          if (kDebugMode) {
            debugPrint(
              '⏱️ [REST-TIMER] Set $_completedSetId updated: skipped=true, remaining=${state!.remainingSeconds}s, added=${state!.secondsAdded}s, actual=${actualRestSeconds}s',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ [REST-TIMER] Error updating set rest timer data: $e');
          }
        }
      }

      // ✅ FIX: Start duration tracking for NEXT set when timer is skipped
      // Without this, the set duration would include the rest timer time
      if (_currentExerciseId != null && state?.currentSet != null) {
        try {
          final durationTracker = ref.read(setDurationTrackerProvider);
          final nextSetNumber = state!.currentSet! + 1;
          durationTracker.startSet(_currentExerciseId!, nextSetNumber);
          if (kDebugMode) {
            debugPrint(
              '✅ [TIMER SKIP] Called startSet for exercise $_currentExerciseId, set $nextSetNumber (after skipping timer for set ${state!.currentSet})',
            );
          }
        } catch (durationError) {
          if (kDebugMode) {
            debugPrint('❌ [TIMER SKIP] Error calling startSet: $durationError');
          }
        }
      }

      await _saveState(
        immediate: true,
      ); // FIX C13: skip must persist immediately

      // Timer skipped - no audio will play
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Internal ticker for timer updates
  void _startTicker() {
    // CRITICAL: Ensure no duplicate tickers can exist
    if (_ticker != null) {
      // Ticker already running - stopping old ticker first
      _stopTicker();
    }

    _lastTick = DateTime.now();

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Safety check: prevent ticks if disposed
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      _onTick();
    });

    // Ticker started
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Handle timer tick - OPTIMIZED for minimal UI updates
  void _onTick() {
    if (state?.isActive != true) return;

    final now = DateTime.now();
    _internalTickCount++;

    // OPTIMIZATION: Accuracy tracking only in debug mode
    if (kDebugMode && _internalTickCount % 10 == 0) {
      _trackAccuracy(now);
    }

    // OPTIMIZATION: Calculate remaining time using cached endTime
    final newRemainingSeconds = _calculateRemainingSeconds(now);

    // OPTIMIZATION 1: Skip update if value hasn't changed (reduces rebuilds by 80%)
    if (newRemainingSeconds == state!.remainingSeconds) {
      return;
    }

    // OPTIMIZATION 2: Throttle UI updates to 100ms intervals for smooth animation
    if (_shouldThrottleUpdate(now)) {
      return;
    }

    // OPTIMIZATION 3: Drift correction only every 10 ticks instead of every tick
    if (_internalTickCount % 10 == 0) {
      _applyDriftCorrectionIfNeeded(now);
    }

    // PERF: Update ValueNotifier for high-frequency UI updates (no Riverpod rebuild)
    _remainingSecondsNotifier?.value = newRemainingSeconds;

    // Internal tracking (no Riverpod notification)
    _internalTickCount;

    // State update ONLY for structural changes (every 30 seconds for auto-save)
    if (_internalTickCount % 30 == 0) {
      state = state!.copyWith(
        remainingSeconds: newRemainingSeconds,
        tickCount: _internalTickCount,
      );
    }

    if (kDebugMode && _internalTickCount % 10 == 0) {
      debugPrint('⏱️ [TIMER TICK] ${newRemainingSeconds}s remaining');
    }

    // CRITICAL: Handle completion IMMEDIATELY and SYNCHRONOUSLY
    // Use newRemainingSeconds directly since state may not be updated every tick
    if (newRemainingSeconds <= 0 &&
        !(_completionInProgress || (state!.audioPlayed))) {
      // FIX C12: Set flag HERE before calling to close the check-and-set gap.
      // In Dart's single-threaded model the window is theoretical, but setting it
      // early makes the intent explicit and protects against any future refactoring.
      _completionInProgress = true;
      // Sync state for completion
      state = state!.copyWith(
        remainingSeconds: 0,
        tickCount: _internalTickCount,
        status: TimerStatus.completed,
      );
      unawaited(_onTimerComplete());
    }

    // OPTIMIZATION: Batch Live Activity updates to prevent queue buildup
    if (Platform.isIOS &&
        state!.liveActivityActive &&
        _internalTickCount % 5 == 0) {
      _scheduleLiveActivityUpdate();
    }

    // OPTIMIZATION: Debounced auto-save (saves only after inactivity)
    if (_internalTickCount % 30 == 0) {
      _saveState();
    }
  }

  /// OPTIMIZATION: Calculate remaining seconds using cached endTime
  int _calculateRemainingSeconds(DateTime now) {
    // Use cached endTime for performance
    _cachedEndTime ??= state!.endTime;

    if (_cachedEndTime != null) {
      // Direct calculation without drift correction overhead
      final millisRemaining = _cachedEndTime!.difference(now).inMilliseconds;
      return (millisRemaining / 1000).ceil().clamp(
        0,
        state!.totalDurationSeconds,
      );
    }

    // Fallback to tick-based calculation
    return (state!.remainingSeconds - 1).clamp(0, state!.totalDurationSeconds);
  }

  /// OPTIMIZATION: Throttle UI updates to reduce rebuilds
  bool _shouldThrottleUpdate(DateTime now) {
    if (_lastUIUpdate == null) {
      _lastUIUpdate = now;
      return false;
    }

    // Allow update every 100ms for smooth animation without excessive rebuilds
    if (now.difference(_lastUIUpdate!).inMilliseconds < 100) {
      return true;
    }

    _lastUIUpdate = now;
    return false;
  }

  /// OPTIMIZATION: Apply drift correction only when significant (>2 seconds)
  void _applyDriftCorrectionIfNeeded(DateTime now) {
    if (_cachedEndTime == null) return;

    final actualRemaining = _cachedEndTime!.difference(now).inSeconds;
    final drift = (actualRemaining - state!.remainingSeconds).abs();

    // Only correct if drift is significant (>2 seconds)
    if (drift > 2) {
      state = state!.copyWith(remainingSeconds: actualRemaining);
      if (kDebugMode) {
        debugPrint('⏱️ Drift correction applied: ${drift}s');
      }
    }
  }

  /// OPTIMIZATION: Track accuracy only in debug mode
  void _trackAccuracy(DateTime now) {
    if (_lastTick == null) {
      _lastTick = now;
      return;
    }

    const expectedInterval = Duration(seconds: 10);
    final actualInterval = now.difference(_lastTick!);
    final error = (actualInterval - expectedInterval).inMilliseconds;

    if (error.abs() > 1000) {
      _accuracyErrorCount++;
      if (kDebugMode) {
        debugPrint('⚠️ Timer accuracy drift: ${error}ms over 10 ticks');
      }
    }

    _lastTick = now;
  }

  /// OPTIMIZATION: Schedule Live Activity update without queue buildup
  void _scheduleLiveActivityUpdate() {
    // Skip if update already in progress
    if (_pendingLiveActivityUpdate != null) {
      return;
    }

    _pendingLiveActivityUpdate = _updateLiveActivity()
        .then((_) {
          _pendingLiveActivityUpdate = null;
        })
        .catchError((e) {
          _pendingLiveActivityUpdate = null;
        });
  }

  /// Handle timer completion with atomic protection against race conditions
  Future<void> _onTimerComplete() async {
    // MEMORY LEAK PROTECTION: Check if disposed
    if (_isDisposed) {
      // Timer completion called after dispose
      return;
    }

    // NOTE: _completionInProgress is set by the caller (_onTick) before invoking this.
    // The audioPlayed guard below is the idempotency safety net for the restoration path.

    if (state?.isCompleted != true) {
      // Timer not completed yet
      return;
    }

    if (state!.audioPlayed) {
      // Audio already played - preventing duplicate
      return;
    }

    // Idempotent set: already true when called from _onTick(), but needed for
    // the restoration path which calls this directly without pre-setting.
    _completionInProgress = true;
    _debugLogIOSCompletionTrace('_onTimerComplete:start');

    // CRITICAL FIX: Mark audio as played IMMEDIATELY to prevent race conditions
    state = state!.markAudioPlayed();
    _debugLogIOSCompletionTrace('_onTimerComplete:audioMarkedPlayed');

    // PERF: Update ValueNotifier and emit completion event
    _remainingSecondsNotifier?.value = 0;
    _eventController?.add(TimerEvent.completed());

    // FIX C13: immediate=true bypasses 500ms debounce — audioPlayed flag must
    // be persisted before the app can be backgrounded or terminated.
    await _saveState(immediate: true);

    // DOUBLE CHECK: Ensure the audioPlayed flag is truly persisted
    // Audio flag set: audioPlayed=${state!.audioPlayed}

    try {
      _stopTicker();

      // ✅ FIX: ALWAYS call duration tracking FIRST (before audio/notifications)
      // This ensures startSet() is called even if timer was skipped or audio fails
      if (kDebugMode) {
        debugPrint(
          '🔍 [TIMER COMPLETION] Checking duration tracking conditions:',
        );
      }
      if (kDebugMode) {
        debugPrint('  _currentExerciseId: $_currentExerciseId');
      }
      if (kDebugMode) {
        debugPrint('  state?.currentSet: ${state?.currentSet}');
      }
      if (kDebugMode) {
        debugPrint('  state?.skipped: ${state?.skipped}');
      }
      if (kDebugMode) {
        debugPrint(
          '  Should call startSet: ${_currentExerciseId != null && state?.currentSet != null}',
        );
      }

      if (_currentExerciseId != null && state?.currentSet != null) {
        try {
          final durationTracker = ref.read(setDurationTrackerProvider);
          // NOTE: currentSet is the COMPLETED set, so we track the NEXT set (currentSet + 1)
          final nextSetNumber = state!.currentSet! + 1;

          // Start tracking the set execution from the exact moment rest ends
          durationTracker.startSet(_currentExerciseId!, nextSetNumber);

          if (kDebugMode) {
            debugPrint(
              '✅ [TIMER COMPLETION] Called startSet for exercise $_currentExerciseId, set $nextSetNumber (after completing set ${state!.currentSet})',
            );
          }
        } catch (durationError) {
          if (kDebugMode) {
            debugPrint(
              '❌ [TIMER COMPLETION] Error calling startSet: $durationError',
            );
          }
          // Continue with completion even if duration tracking fails
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [TIMER COMPLETION] Missing exerciseId or currentSet for duration tracking',
          );
        }
      }

      // ✅ Rest Timer Tracking: Update the completed set with rest timer data
      if (_currentExerciseId != null &&
          _completedSetId != null &&
          state != null) {
        try {
          // Calculate actual rest time: totalDuration - 0 (completed) + secondsAdded
          final actualRestSeconds = state!.totalDurationSeconds;

          ref
              .read(currentWorkoutProvider.notifier)
              .updateSetRestTimerData(
                exerciseId: _currentExerciseId!,
                setId: _completedSetId!,
                restTimerSkipped: false, // Timer completed normally
                restTimerSecondsRemaining: null, // null = not skipped
                restTimerSecondsAdded: state!.secondsAdded > 0
                    ? state!.secondsAdded
                    : null,
                actualRestSeconds: actualRestSeconds,
              );

          if (kDebugMode) {
            debugPrint(
              '⏱️ [REST-TIMER] Set $_completedSetId updated: skipped=false, added=${state!.secondsAdded}s, actual=${actualRestSeconds}s',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ [REST-TIMER] Error updating set rest timer data: $e');
          }
        }
      }

      // ✅ FIX: Only play audio and send notifications if NOT skipped
      if (!state!.skipped) {
        if (kDebugMode) {
          debugPrint(
            '🔊 [TIMER COMPLETION] Playing completion sound (not skipped)',
          );
        }
        // Try local audio first. If it succeeds, cancel the scheduled
        // notification to avoid double sound. If it fails (e.g. locked screen
        // where AVAudioSession can't activate), the notification handles it.
        final isNotificationOwned = Platform.isIOS &&
            state?.completionDeliveryStrategy ==
                TimerCompletionDeliveryStrategy.notificationOwned;

        _debugLogIOSCompletionTrace(
          '_onTimerComplete:willPlayLocalAudio',
        );
        try {
          await _playCompletionSound();
          // Audio succeeded — cancel notification to avoid double sound
          if (isNotificationOwned) {
            await _unifiedChannel
                .invokeMethod<void>('cancelScheduledCompletion');
            if (kDebugMode) {
              debugPrint(
                '🔊 [TIMER COMPLETION] Local audio played, cancelled scheduled notification',
              );
            }
          }
        } catch (audioError) {
          // Audio failed (locked screen) — notification will handle sound
          if (kDebugMode) {
            debugPrint(
              '⚠️ [TIMER COMPLETION] Local audio failed, relying on notification: $audioError',
            );
          }
        }

        if (!Platform.isIOS) {
          try {
            final hasLiveActivity = await _checkActiveLiveActivities();
            await _sendTimerCompletionNotification(
              hasLiveActivity: hasLiveActivity,
            );
          } catch (notificationError) {
            if (kDebugMode) {
              debugPrint(
                '❌ [TIMER COMPLETION] Notification error: $notificationError',
              );
            }
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '⏭️ [TIMER COMPLETION] Timer was skipped - no audio/notification',
          );
        }
      }

      // Update Live Activity
      if (Platform.isIOS) {
        try {
          await _updateLiveActivity();
          // Live Activity updated

          // Auto-dismiss Live Activity after 5 seconds for clean UX
          await _stopLiveActivityWithDelay();
          // Live Activity will auto-dismiss
        } catch (liveActivityError) {
          // Live Activity failure is not critical
        }
      }

      await _saveState();
      _debugLogIOSCompletionTrace('_onTimerComplete:finished');

      // Timer completion finished
    } catch (e) {
      // CRITICAL: Even if completion fails, ensure user knows timer finished
      try {
        await _sendEmergencyCompletionNotification(e.toString());
      } catch (emergencyError) {
        // At this point, log to crash analytics or similar
      }
    } finally {
      // ATOMIC: Always unlock completion process
      _completionInProgress = false;
      // Timer completion unlocked
    }
  }

  /// Send emergency notification when all other completion methods fail
  Future<void> _sendEmergencyCompletionNotification(String error) async {
    if (Platform.isIOS) {
      try {
        // Use iOS system notification as absolute last resort
        await _unifiedChannel.invokeMethod('sendEmergencyNotification', {
          'title': 'Timer Complete',
          'body': 'Your timer finished but had technical issues',
          'error': error,
        });
      } catch (e, stackTrace) {
        debugPrint('⚠️ [UnifiedTimer] Error: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }
    } else {
      try {
        // Use Android local notification as absolute last resort
        if (_notifications != null) {
          await _notifications!.show(
            999, // Emergency notification ID
            'Timer Complete (Emergency)',
            'Your timer finished but encountered errors: $error',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'emergency_timer',
                'Emergency Timer',
                channelDescription:
                    'Emergency notifications when timer system fails',
                importance: Importance.max,
                priority: Priority.max,
              ),
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('⚠️ [UnifiedTimer] Error: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }
    }
  }

  /// Play completion sound using the best available method
  String _resolveCurrentTimerSoundName() {
    final configuredSound = ref.read(appConfigProvider).timerSound.trim();
    final stateSound =
        state?.completionSoundName?.trim() ?? state?.customSoundName?.trim();

    final hasConfiguredSound = configuredSound.isNotEmpty;
    final hasStateSound = stateSound != null && stateSound.isNotEmpty;

    if (!hasStateSound ||
        stateSound == 'sound' ||
        stateSound == 'timer_complete') {
      if (hasConfiguredSound) {
        if (kDebugMode && stateSound != configuredSound) {
          debugPrint(
            '🔧 [TIMER SOUND FIX] Resolving timer sound from AppConfig:',
          );
          debugPrint(
            '  - state?.completionSoundName = ${state?.completionSoundName}',
          );
          debugPrint('  - AppConfig.timerSound = $configuredSound');
          debugPrint('  - Final soundName = $configuredSound');
        }
        return configuredSound;
      }
    }

    if (hasStateSound) {
      return stateSound;
    }

    return 'timer_complete';
  }

  void _debugLogIOSCompletionTrace(
    String context, {
    Map<String, Object?> extra = const {},
  }) {
    if (!kDebugMode || !Platform.isIOS) {
      return;
    }

    final currentState = state;
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    final resolvedSoundName = _resolveCurrentTimerSoundName();
    final extras = extra.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('\n');

    final buffer = StringBuffer()
      ..writeln('🍎 [IOS TIMER TRACE] $context')
      ..writeln('  lifecycleState=$lifecycleState')
      ..writeln('  appInForeground=${_isAppInForeground()}')
      ..writeln('  hasState=${currentState != null}')
      ..writeln('  status=${currentState?.status}')
      ..writeln('  isActive=${currentState?.isActive}')
      ..writeln('  isPaused=${currentState?.isPaused}')
      ..writeln('  isCompleted=${currentState?.isCompleted}')
      ..writeln('  skipped=${currentState?.skipped}')
      ..writeln('  audioPlayed=${currentState?.audioPlayed}')
      ..writeln('  remainingSeconds=${currentState?.remainingSeconds}')
      ..writeln('  totalDurationSeconds=${currentState?.totalDurationSeconds}')
      ..writeln('  endTime=${currentState?.endTime?.toIso8601String()}')
      ..writeln('  cachedEndTime=${_cachedEndTime?.toIso8601String()}')
      ..writeln(
        '  completionDeliveryStrategy=${currentState?.completionDeliveryStrategy}',
      )
      ..writeln('  completionSoundName=${currentState?.completionSoundName}')
      ..writeln('  customSoundName=${currentState?.customSoundName}')
      ..writeln('  resolvedSoundName=$resolvedSoundName')
      ..writeln('  liveActivityActive=${currentState?.liveActivityActive}')
      ..writeln('  completionInProgress=$_completionInProgress')
      ..writeln('  audioInProgress=$_audioInProgress')
      ..writeln('  lastAudioPlayTime=${_lastAudioPlayTime?.toIso8601String()}');

    if (extras.isNotEmpty) {
      buffer
        ..writeln('  extra:')
        ..writeln(extras.split('\n').map((line) => '    $line').join('\n'));
    }

    debugPrint(buffer.toString());
  }

  Future<void> _applyIOSCompletionDeliveryStrategy() async {
    if (!Platform.isIOS || state == null || !state!.isActive) {
      return;
    }

    final soundName = _resolveCurrentTimerSoundName();
    _debugLogIOSCompletionTrace(
      '_applyIOSCompletionDeliveryStrategy:start',
      extra: {'soundName': soundName},
    );

    try {
      if (_isAppInForeground()) {
        await _unifiedChannel.invokeMethod<void>('cancelScheduledCompletion');
        state = state!.copyWith(
          completionDeliveryStrategy:
              TimerCompletionDeliveryStrategy.foregroundAudio,
          completionSoundName: soundName,
        );
        _debugLogIOSCompletionTrace(
          '_applyIOSCompletionDeliveryStrategy:foregroundAudio',
          extra: {'soundName': soundName},
        );
      } else {
        await _unifiedChannel.invokeMethod<String>('scheduleCompletion', {
          'duration': state!.remainingSeconds,
          'soundName': soundName,
          'title': _getNotificationTitle(),
          'body': _getNotificationBody(),
        });
        state = state!.copyWith(
          completionDeliveryStrategy:
              TimerCompletionDeliveryStrategy.notificationOwned,
          completionSoundName: soundName,
        );
        _debugLogIOSCompletionTrace(
          '_applyIOSCompletionDeliveryStrategy:notificationOwned',
          extra: {
            'soundName': soundName,
            'scheduledDuration': state!.remainingSeconds,
            'notificationSoundStrategy': 'system_default',
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [UnifiedTimer] Failed to update iOS completion delivery strategy: $e',
        );
      }
      state = state!.copyWith(
        completionDeliveryStrategy:
            TimerCompletionDeliveryStrategy.foregroundAudio,
        completionSoundName: soundName,
      );
      _debugLogIOSCompletionTrace(
        '_applyIOSCompletionDeliveryStrategy:error',
        extra: {'soundName': soundName, 'error': e.toString()},
      );
    }
  }

  Future<void> _playCompletionSound() async {
    // MEMORY LEAK PROTECTION: Check if disposed
    if (_isDisposed) {
      return;
    }

    // ATOMIC: Prevent multiple simultaneous audio playback attempts
    if (_audioInProgress) {
      return;
    }

    // Check for recent audio playback (3 second window)
    if (_lastAudioPlayTime != null &&
        DateTime.now().difference(_lastAudioPlayTime!).inSeconds < 3) {
      return;
    }

    // CRITICAL FIX: Check real-time audio setting, not cached value
    final currentAudioEnabled = ref.read(appConfigProvider).soundEnabled;
    if (!currentAudioEnabled) {
      return;
    }

    // ATOMIC: Lock audio process
    _audioInProgress = true;

    // FIX #1: SINGLE SOURCE OF TRUTH for audio playback
    // iOS: Use ONLY native audio (no Flutter AudioPlayer)
    // Android: Use ONLY Flutter AudioPlayer

    try {
      final soundName = _resolveCurrentTimerSoundName();
      _debugLogIOSCompletionTrace(
        '_playCompletionSound:start',
        extra: {'soundName': soundName},
      );

      // DEBUG: Log what sound is being played
      if (kDebugMode) {
        debugPrint('🔊 [TIMER SOUND DEBUG 3] Playing completion sound:');
        debugPrint(
          '  - state?.completionSoundName = ${state?.completionSoundName}',
        );
        debugPrint('  - Final soundName = $soundName');
      }

      if (Platform.isIOS) {
        try {
          if (kDebugMode) {
            debugPrint('🔊 [TIMER SOUND DEBUG 4] Sending to iOS:');
            debugPrint('  - soundName parameter = $soundName');
          }

          final played =
              await _unifiedChannel.invokeMethod<bool>('playCompletionSound', {
                'soundName': soundName,
              }) ??
              false;

          if (!played) {
            throw Exception(
              'Native iOS timer sound playback returned false for "$soundName"',
            );
          }

          if (kDebugMode) {
            debugPrint(
              '🔊 [TIMER SOUND DEBUG 5] Native iOS playback confirmed for $soundName',
            );
          }
          _debugLogIOSCompletionTrace(
            '_playCompletionSound:nativeConfirmed',
            extra: {'soundName': soundName},
          );
        } catch (iosError) {
          if (kDebugMode) {
            debugPrint(
              '❌ [TIMER SOUND DEBUG 5] Native iOS playback failed: $iosError',
            );
          }
          _debugLogIOSCompletionTrace(
            '_playCompletionSound:nativeFailed',
            extra: {'soundName': soundName, 'error': iosError.toString()},
          );
          rethrow;
        }
      } else {
        // Android + Desktop/Web: Use Flutter AudioPlayer
        try {
          await _playWithAudioPlayer(soundName);
        } catch (audioError) {
          // Send notification as backup for all non-iOS platforms
          await _sendAudioErrorNotification();
        }
      }
    } catch (e) {
      // Send notification as final backup
      await _sendAudioErrorNotification();
    } finally {
      // ATOMIC: Always unlock audio process and mark play time
      _audioInProgress = false;
      _lastAudioPlayTime = DateTime.now();
    }
  }

  /// Play audio using Flutter AudioPlayer with proper error handling
  Future<void> _playWithAudioPlayer(String soundName) async {
    if (_audioPlayer == null) {
      throw Exception('AudioPlayer not initialized');
    }

    try {
      // CRITICAL FIX: Use .wav extension instead of .mp3
      await _audioPlayer!.play(AssetSource('sounds/$soundName.wav'));
    } catch (e) {
      rethrow;
    }
  }

  /// Send notification when audio fails completely
  Future<void> _sendAudioErrorNotification() async {
    try {
      // Use timer's notification service for fallback
      await NotificationService().sendWorkoutReminder(
        title: 'Timer Complete',
        body: 'Your timer has finished (audio failed)',
      );
    } catch (e) {
      // Notification failed silently
    }
  }

  /// Cancel all scheduled notifications
  Future<void> _cancelScheduledNotifications() async {
    try {
      _debugLogIOSCompletionTrace('_cancelScheduledNotifications:start');
      if (Platform.isIOS) {
        await _unifiedChannel.invokeMethod('cancelScheduledCompletion');
      } else if (Platform.isAndroid && _notifications != null) {
        await _notifications!.cancelAll();
      }

      if (state != null) {
        state = state!.copyWith(
          completionDeliveryStrategy:
              TimerCompletionDeliveryStrategy.foregroundAudio,
        );
      }
      _debugLogIOSCompletionTrace('_cancelScheduledNotifications:end');
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      _debugLogIOSCompletionTrace(
        '_cancelScheduledNotifications:error',
        extra: {'error': e.toString()},
      );
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Send timer completion notification using the unified notification system
  /// [hasLiveActivity] indicates if Live Activities are currently active
  Future<void> _sendTimerCompletionNotification({
    bool hasLiveActivity = false,
  }) async {
    if (state == null) return;

    try {
      if (Platform.isIOS) {
        return;
      }

      await NotificationService().sendTimerCompletionNotification(
        exerciseName: state!.exerciseName ?? 'Exercise',
        currentSet: state!.currentSet ?? 1,
        totalSets: state!.totalSets ?? 1,
        workoutName: state!.workoutId,
        customSoundFile: _resolveCurrentTimerSoundName(),
      );
    } catch (e) {
      // Continue execution even if notification fails
    }
  }

  /// Start iOS Live Activity (OLD timer-based system)
  /// NOTE: Workout timers now use ONLY the iOS 17+ WorkoutSession Live Activity.
  /// The legacy timer-based Live Activity is intentionally disabled for workouts.
  Future<void> _clearLegacyLiveActivityState() async {
    if (state == null) return;
    if (!state!.liveActivityActive && state!.liveActivityId == null) return;

    state = state!.copyWith(liveActivityActive: false, liveActivityId: null);
    await _saveState();
  }

  Future<void> _startLiveActivity() async {
    if (state == null || !Platform.isIOS) return;

    try {
      // Workout timers should always flow through the unified WorkoutSession LA.
      final laService = ref.read(workoutSessionLAServiceProvider);
      final laNotifier = ref.read(workoutSessionLAProvider.notifier);
      final workout = ref.read(currentWorkoutProvider);

      if (workout == null) {
        if (kDebugMode) {
          debugPrint(
            '[TIMER-LA] ⚠️ No active workout found - skipping Live Activity start',
          );
        }
        await _clearLegacyLiveActivityState();
        return;
      }

      if (!laService.isActive) {
        if (kDebugMode) {
          debugPrint(
            '[TIMER-LA] ♻️ WorkoutSession LA missing - attempting restore',
          );
        }
        await laNotifier.reconcileWithCurrentWorkout(recreateIfMissing: true);
      }

      if (!laService.isActive) {
        if (kDebugMode) {
          debugPrint(
            '[TIMER-LA] ❌ WorkoutSession LA unavailable - legacy fallback disabled',
          );
        }
        await _clearLegacyLiveActivityState();
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '[TIMER-LA] 📱 Using WorkoutSession LA only - transitioning to REST mode',
        );
      }

      Exercise? targetExercise;
      if (state!.exerciseName != null) {
        targetExercise = workout.exercises
            .where((e) => e.name == state!.exerciseName)
            .firstOrNull;
      }
      targetExercise ??= workout.exercises.firstOrNull;

      if (targetExercise == null) {
        if (kDebugMode) {
          debugPrint(
            '[TIMER-LA] ⚠️ Could not resolve target exercise - skipping LA sync',
          );
        }
        await _clearLegacyLiveActivityState();
        return;
      }

      await laNotifier.transitionToRest(
        restDurationSeconds: state!.totalDurationSeconds,
        nextExercise: targetExercise,
        nextSetIndex: state!.currentSet ?? 1,
      );

      await _clearLegacyLiveActivityState();

      if (kDebugMode) {
        debugPrint(
          '[TIMER-LA] ✅ WorkoutSession LA transitioned to REST: ${state!.totalDurationSeconds}s',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TIMER-LA] ❌ Failed to sync WorkoutSession LA: $e');
      }
      await _clearLegacyLiveActivityState();
    }
  }

  /// Update iOS Live Activity (OLD timer-based system)
  Future<void> _updateLiveActivity() async {
    if (state?.liveActivityActive != true) {
      return;
    }

    // 🚫 SKIP: If WorkoutSession Live Activity is active
    // Use service directly to avoid circular dependency with workoutSessionLAProvider
    final laService = ref.read(workoutSessionLAServiceProvider);
    if (laService.isActive) {
      return;
    }

    try {
      // Use the correct channel for Live Activities updates
      await _unifiedChannel.invokeMethod('updateLiveActivity', {
        'activityId':
            state!.liveActivityId ?? 'current', // Use saved ID or fallback
        'remainingSeconds': state!.remainingSeconds,
        'totalSeconds': state!.totalDurationSeconds,
        'isRunning': state!.isActive,
        'currentSet': state!.currentSet ?? 1,
        'totalSets': state!.totalSets ?? 1,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'skipped': state!.skipped, // Send skip status to iOS
        'soundName': _resolveCurrentTimerSoundName(),
      });
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Stop iOS Live Activity
  Future<void> _stopLiveActivity({String dismissalPolicy = 'immediate'}) async {
    // Guard: skip if no Live Activity is active or no valid ID
    if (state?.liveActivityActive != true || state?.liveActivityId == null) {
      debugPrint('ℹ️ [UnifiedTimer] No active Live Activity to stop');
      // Still clear state in case of stale flags
      if (state != null && state!.liveActivityActive) {
        state = state!.copyWith(
          liveActivityActive: false,
          liveActivityId: null,
        );
        await _saveState();
      }
      return;
    }

    try {
      // Use the correct channel for Live Activities
      await _unifiedChannel.invokeMethod('endLiveActivity', {
        'activityId': state!.liveActivityId,
        'dismissalPolicy': dismissalPolicy,
      });

      // Clear the activity ID from state
      state = state!.copyWith(liveActivityActive: false, liveActivityId: null);
      await _saveState();
    } catch (e, stackTrace) {
      // ACTIVITY_NOT_FOUND is expected when activity was already cleaned up by iOS
      final isActivityNotFound =
          e is PlatformException && e.code == 'ACTIVITY_NOT_FOUND';
      if (isActivityNotFound) {
        debugPrint('ℹ️ [UnifiedTimer] Live Activity already ended (expected)');
      } else {
        debugPrint('⚠️ [UnifiedTimer] Error stopping Live Activity: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }
      // Always clear state regardless of error
      if (state != null) {
        state = state!.copyWith(
          liveActivityActive: false,
          liveActivityId: null,
        );
        await _saveState();
      }
    }
  }

  /// Stop Live Activity with auto-dismissal after 5 seconds (for completed timers)
  Future<void> _stopLiveActivityWithDelay() async {
    await _stopLiveActivity(dismissalPolicy: 'after_5s');
  }

  /// Restore timer state from storage with corruption protection
  Future<void> _restoreState() async {
    try {
      // 🔧 FIX: Ensure box is open before reading
      if (!await _ensureStorageOpen()) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [UnifiedTimer] Cannot restore state - storage unavailable',
          );
        }
        return;
      }

      final stored = _storage?.get(_storageKey);
      if (stored != null) {
        // VALIDATION: Ensure stored data integrity before restoration
        final stateMap = Map<String, dynamic>.from(stored);

        // Validate critical fields exist
        if (!stateMap.containsKey('totalDurationSeconds') ||
            !stateMap.containsKey('remainingSeconds') ||
            !stateMap.containsKey('status')) {
          throw Exception('Corrupted state: missing critical fields');
        }

        // Validate time consistency
        final totalDuration = stateMap['totalDurationSeconds'] as int?;
        final remainingSeconds = stateMap['remainingSeconds'] as int?;

        if (totalDuration == null ||
            remainingSeconds == null ||
            totalDuration < 0 ||
            remainingSeconds < 0 ||
            remainingSeconds > totalDuration) {
          throw Exception('Corrupted state: invalid time values');
        }

        // Validate endTime if present
        if (stateMap.containsKey('endTime') && stateMap['endTime'] != null) {
          try {
            DateTime.parse(stateMap['endTime'] as String);
          } catch (e) {
            throw Exception('Corrupted state: invalid endTime format');
          }
        }

        final restoredState = UnifiedTimerState.fromJson(stateMap);

        // DEBUG: Log customSoundName when restoring
        if (kDebugMode) {
          debugPrint('📂 [TIMER RESTORE] Restoring timer state:');
          debugPrint('  - customSoundName: ${restoredState.customSoundName}');
          debugPrint('  - remainingSeconds: ${restoredState.remainingSeconds}');
        }

        // Check if timer should still be running
        if (restoredState.isActive && restoredState.endTime != null) {
          final now = DateTime.now();
          final timeLeft = restoredState.endTime!.difference(now).inSeconds;

          if (timeLeft > 0) {
            // Timer still has time left
            state = restoredState.copyWith(remainingSeconds: timeLeft);
            // PERF: Sync ValueNotifier with restored state
            _remainingSecondsNotifier?.value = timeLeft;
            _startTicker();

            if (Platform.isIOS) {
              await _applyIOSCompletionDeliveryStrategy();
              await _startLiveActivity();
            }
          } else {
            if (restoredState.audioPlayed ||
                (Platform.isIOS &&
                    restoredState.completionDeliveryStrategy ==
                        TimerCompletionDeliveryStrategy.notificationOwned)) {
              state = restoredState.copyWith(
                status: TimerStatus.completed,
                remainingSeconds: 0,
                audioPlayed: true,
                completionDeliveryStrategy:
                    TimerCompletionDeliveryStrategy.foregroundAudio,
              );
              await _saveState();
            } else {
              state = restoredState.complete();
              await _onTimerComplete();
            }
          }
        } else {
          // Timer was paused or idle
          state = restoredState;
        }
      }
    } catch (e) {
      // Try emergency backup state recovery
      try {
        // 🔧 FIX: Try to reopen storage before emergency recovery
        await _ensureStorageOpen();

        final emergencyStored = _storage?.get('${_storageKey}_emergency');

        if (emergencyStored != null) {
          final emergencyMap = Map<String, dynamic>.from(emergencyStored);

          // Basic validation for emergency state
          if (emergencyMap.containsKey('totalDurationSeconds') &&
              emergencyMap.containsKey('remainingSeconds') &&
              emergencyMap.containsKey('status')) {
            // Create minimal state from emergency backup
            final totalSeconds = emergencyMap['totalDurationSeconds'] as int;
            final remaining = emergencyMap['remainingSeconds'] as int;

            state = UnifiedTimerState(
              totalDurationSeconds: totalSeconds,
              remainingSeconds: remaining,
            );

            // Clean up emergency state and re-save proper state
            await _storage?.delete('${_storageKey}_emergency');
            await _saveState();

            return;
          }
        }
      } catch (emergencyError, stackTrace) {
        debugPrint(
          '⚠️ [UnifiedTimer] Emergency state recovery failed: $emergencyError',
        );
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            emergencyError,
            stackTrace,
            reason: 'UnifiedTimer emergency state recovery failed',
            fatal: false,
          ),
        );
      }

      // Complete failure - clear corrupted state and log for debugging
      await _clearState();
    }
  }

  /// OPTIMIZED: Save state with debouncing to reduce I/O operations.
  ///
  /// Pass [immediate] = true for critical events (completion, audioPlayed, skip)
  /// to bypass the 500ms debounce window and prevent data loss on app termination.
  Future<void> _saveState({bool immediate = false}) async {
    if (state == null || _storage == null) return;

    _pendingSaveData = state!.toJson();

    // FIX C13: Critical events must persist synchronously — debounce risks losing
    // audioPlayed=true if the app goes to background within 500ms of completion.
    if (immediate) {
      _saveDebounceTimer?.cancel();
      _saveDebounceTimer = null;
      await _performActualSave();
      return;
    }

    // OPTIMIZATION: Debounce saves - wait 500ms for rapid changes to settle
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(_performActualSave());
    });
  }

  /// Perform the actual state save operation
  Future<void> _performActualSave() async {
    if (_pendingSaveData == null || _stateWriteInProgress) {
      return;
    }

    // 🔧 FIX: Ensure box is open before writing
    if (!await _ensureStorageOpen()) {
      if (kDebugMode) {
        debugPrint('⚠️ [UnifiedTimer] Cannot save state - storage unavailable');
      }
      return;
    }

    _stateWriteInProgress = true;
    final dataToSave = _pendingSaveData!;
    _pendingSaveData = null;

    try {
      // VALIDATION: Ensure state data integrity before saving
      if (dataToSave['totalDurationSeconds'] == null ||
          dataToSave['remainingSeconds'] == null ||
          dataToSave['status'] == null) {
        throw Exception('Invalid state data: missing critical fields');
      }

      // Validate time consistency
      final totalDuration = dataToSave['totalDurationSeconds'] as int;
      final remainingSeconds = dataToSave['remainingSeconds'] as int;

      if (totalDuration < 0 ||
          remainingSeconds < 0 ||
          remainingSeconds > totalDuration) {
        throw Exception('Invalid state data: time inconsistency');
      }

      // DEBUG: Log customSoundName when saving
      if (kDebugMode && dataToSave.containsKey('customSoundName')) {
        if (kDebugMode) {
          debugPrint('💾 [TIMER SAVE] Saving timer state:');
        }
        if (kDebugMode) {
          debugPrint('  - customSoundName: ${dataToSave['customSoundName']}');
        }
        if (kDebugMode) {
          debugPrint('  - remainingSeconds: $remainingSeconds');
        }
      }

      // ATOMIC WRITE: Save validated state
      await _storage!.put(_storageKey, dataToSave);
    } catch (e) {
      // Try emergency backup save with minimal data
      try {
        final emergencyState = {
          'totalDurationSeconds': dataToSave['totalDurationSeconds'],
          'remainingSeconds': dataToSave['remainingSeconds'],
          'status': dataToSave['status'],
          'emergency': true,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        await _storage!.put('${_storageKey}_emergency', emergencyState);
      } catch (emergencyError) {
        if (kDebugMode) {
          debugPrint('❌ Emergency state save failed: $emergencyError');
        }
      }
    } finally {
      _stateWriteInProgress = false;
    }
  }

  /// Clear saved state
  Future<void> _clearState() async {
    try {
      // 🔧 FIX: Ensure box is open before deleting
      if (!await _ensureStorageOpen()) {
        return;
      }
      await _storage?.delete(_storageKey);
    } catch (e, stackTrace) {
      debugPrint('⚠️ [UnifiedTimer] Error: $e');
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'UnifiedTimer operation failed',
          fatal: false,
        ),
      );
    }
  }

  /// Get notification title based on timer context with proper localization
  String _getNotificationTitle() {
    if (state == null) {
      return _getLocalizedString('timerFinished', fallback: 'Timer Complete');
    }

    switch (state!.type) {
      case TimerType.rest:
        return _getLocalizedString('restComplete', fallback: 'Rest Complete');
      case TimerType.workout:
        return _getLocalizedString(
          'workoutComplete',
          fallback: 'Workout Complete',
        );
      case TimerType.warmup:
        return _getLocalizedString(
          'warmupComplete',
          fallback: 'Warmup Complete',
        );
      case TimerType.cooldown:
        return _getLocalizedString(
          'cooldownComplete',
          fallback: 'Cooldown Complete',
        );
      case TimerType.interExercise:
        return _getLocalizedString(
          'restBetweenExercisesComplete',
          fallback: 'Ready for Next Exercise',
        );
    }
  }

  /// Get notification body based on timer context with proper localization
  String _getNotificationBody() {
    if (state == null) {
      return _getLocalizedString(
        'timerFinished',
        fallback: 'Your timer has finished',
      );
    }

    final exercise = state!.exerciseName ?? 'Timer';
    if (state!.currentSet != null && state!.totalSets != null) {
      final template = _getLocalizedString(
        'setComplete',
        fallback: '{exercise} - Set {currentSet}/{totalSets} complete',
      );
      return template
          .replaceAll('{exercise}', exercise)
          .replaceAll('{currentSet}', state!.currentSet.toString())
          .replaceAll('{totalSets}', state!.totalSets.toString());
    }
    final template = _getLocalizedString(
      'exerciseComplete',
      fallback: '{exercise} complete',
    );
    return template.replaceAll('{exercise}', exercise);
  }

  /// Helper method to get localized strings using the current locale
  String _getLocalizedString(String key, {required String fallback}) {
    try {
      final locale = ref.read(localeProvider);

      // Basic localization lookup based on locale
      if (locale.languageCode == 'it') {
        switch (key) {
          case 'restComplete':
            return 'Riposo Completato';
          case 'workoutComplete':
            return 'Allenamento Completato';
          case 'warmupComplete':
            return 'Riscaldamento Completato';
          case 'cooldownComplete':
            return 'Defaticamento Completato';
          // FIX #15: Missing Italian translation for inter-exercise rest timer.
          case 'restBetweenExercisesComplete':
            return 'Pronto per il Prossimo Esercizio';
          case 'timerFinished':
            return 'Il tuo timer è terminato';
          case 'setComplete':
            return '{exercise} - Serie {currentSet}/{totalSets} completata';
          case 'exerciseComplete':
            return '{exercise} completato';
        }
      }

      // Fallback to English for unknown keys or non-Italian locales
      return fallback;
    } catch (e) {
      // If anything fails, use fallback
      return fallback;
    }
  }

  /// Check if there are active Live Activities on iOS
  /// Returns true if Live Activities are active, false otherwise
  Future<bool> _checkActiveLiveActivities() async {
    if (!Platform.isIOS) {
      return false; // Live Activities are iOS-only
    }

    try {
      final activities = await _unifiedChannel.invokeMethod(
        'getActiveLiveActivities',
      );

      if (activities == null) {
        return false;
      }

      // If activities is a Map, check if it has any entries
      if (activities is Map) {
        final hasActive = activities.isNotEmpty;
        // Log Live Activity status for debugging
        if (hasActive) {
          // Live Activities detected: ${activities.keys.join(', ')}
        }
        return hasActive;
      }

      return false;
    } catch (e) {
      // If Live Activity check fails, assume none active to be safe
      // This ensures notifications still work if the check fails
      return false;
    }
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

  void _disposeResources() {
    // CRITICAL: Mark as disposed immediately to prevent async operations
    _isDisposed = true;

    // MEMORY LEAK FIX: Complete resource cleanup to prevent memory leaks

    try {
      // 1. Remove lifecycle observer with null check
      try {
        WidgetsBinding.instance.removeObserver(this);
      } catch (e, stackTrace) {
        debugPrint('⚠️ [UnifiedTimer] Error: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }

      // 2. Stop and cleanup timer with comprehensive error handling
      try {
        _stopTicker();
        _ticker = null;
      } catch (e) {
        // Force null to prevent memory leaks even if stop failed
        _ticker = null;
      }

      // 2.3. OPTIMIZATION: Cancel debounce timer and flush pending save
      try {
        _saveDebounceTimer?.cancel();
        _saveDebounceTimer = null;

        // Flush pending data synchronously before dispose
        if (_pendingSaveData != null && _storage != null) {
          _storage!.put(_storageKey, _pendingSaveData!);
        }
        _pendingSaveData = null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error flushing pending save data: $e');
        }
      }

      // 2.4. PERF: Dispose ValueNotifier and StreamController
      try {
        _remainingSecondsNotifier?.dispose();
        _remainingSecondsNotifier = null;
      } catch (e) {
        _remainingSecondsNotifier = null;
      }

      try {
        _eventController?.close();
        _eventController = null;
      } catch (e) {
        _eventController = null;
      }

      // 2.5. OPTIMIZATION: Clear cached data
      _cachedEndTime = null;
      _lastUIUpdate = null;
      _internalTickCount = 0;
      _pendingLiveActivityUpdate = null;

      // 2.5. Reset all atomic flags to prevent hanging locks
      _completionInProgress = false;
      _audioInProgress = false;
      _stateWriteInProgress = false;

      // MEMORY LEAK FIX: Cleanup initialization state
      try {
        _isInitialized = false;
        if (_initCompleter != null && !_initCompleter!.isCompleted) {
          _initCompleter!.completeError(
            'Provider disposed during initialization',
          );
        }
        _initCompleter = null;
      } catch (e) {
        _initCompleter = null; // Force null
      }

      // 3. Cleanup audio player with comprehensive error handling
      try {
        if (_audioPlayer != null) {
          // Use unawaited for dispose as it must be synchronous
          unawaited(
            _audioPlayer!
                .stop()
                .timeout(const Duration(seconds: 1))
                .catchError((e) {}),
          );

          unawaited(
            _audioPlayer!
                .dispose()
                .timeout(const Duration(seconds: 1))
                .catchError((e) {}),
          );

          _audioPlayer = null;
        }
      } catch (e) {
        // Force null to prevent memory leaks even if dispose failed
        _audioPlayer = null;
      }

      // 4. MEMORY LEAK FIX: Properly cleanup FlutterLocalNotificationsPlugin
      try {
        if (_notifications != null) {
          // Cancel all notifications before cleanup
          unawaited(
            _notifications!.cancelAll().timeout(
              const Duration(seconds: 2),
              onTimeout: () {},
            ),
          );

          // FlutterLocalNotificationsPlugin doesn't have a dispose method
          // but we should null the reference to prevent memory leaks
          _notifications = null;
        }
      } catch (e) {
        _notifications = null; // Force null
      }

      // 5. Cleanup iOS specific resources
      if (Platform.isIOS) {
        try {
          // Stop Live Activity immediately with timeout
          unawaited(
            _stopLiveActivity(
              dismissalPolicy: 'immediate',
            ).timeout(const Duration(seconds: 2), onTimeout: () {}),
          );

          // Cleanup iOS method channel handlers with timeout
          unawaited(
            _unifiedChannel
                .invokeMethod('cleanup')
                .timeout(const Duration(seconds: 1), onTimeout: () {})
                .catchError((e) {}),
          );
        } catch (e, stackTrace) {
          debugPrint('⚠️ [UnifiedTimer] Error: $e');
          unawaited(
            FirebaseCrashlytics.instance.recordError(
              e,
              stackTrace,
              reason: 'UnifiedTimer operation failed',
              fatal: false,
            ),
          );
        }
      }

      // 6. MEMORY LEAK FIX: Clear method channel handler safely
      try {
        _unifiedChannel.setMethodCallHandler(null);
      } catch (e, stackTrace) {
        debugPrint('⚠️ [UnifiedTimer] Error: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }

      // 7. Enhanced Hive box lifecycle management with proper error handling
      try {
        if (_storage != null) {
          // Check if box is still open before attempting to close
          if (!_storage!.isOpen) {
            _storage = null;
          } else {
            // Fire-and-forget close with timeout (dispose must be synchronous)
            unawaited(
              _storage!
                  .close()
                  .timeout(
                    const Duration(seconds: 2),
                    onTimeout: () {
                      return;
                    },
                  )
                  .then((_) {})
                  .catchError((e) {}),
            );
            _storage = null;
          }
        }
      } catch (e) {
        // Force null assignment even if close failed to prevent memory leaks
        _storage = null;
      }

      // 8. MEMORY LEAK FIX: Cancel any pending async operations
      try {
        // Log pending operations for debugging
        if (_completionInProgress) {}
        if (_audioInProgress) {}
        if (_stateWriteInProgress) {}
      } catch (e, stackTrace) {
        debugPrint('⚠️ [UnifiedTimer] Error: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }

      // 9. MEMORY LEAK FIX: Clear all references to prevent memory leaks
      try {
        _lastAudioPlayTime = null;
        _currentExerciseId = null;
        _lastTick = null;
        _accuracyErrorCount = 0;
      } catch (e, stackTrace) {
        debugPrint('⚠️ [UnifiedTimer] Error: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }

      // 10. CRITICAL: Null out state LAST to prevent accessing null state
      try {
        state = null;
      } catch (e, stackTrace) {
        debugPrint('⚠️ [UnifiedTimer] Error: $e');
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            e,
            stackTrace,
            reason: 'UnifiedTimer operation failed',
            fatal: false,
          ),
        );
      }
    } catch (e) {
      // CRITICAL: Even if disposal fails, log the error and continue

      // Force all critical nullifications to prevent memory leaks
      _ticker = null;
      _audioPlayer = null;
      _notifications = null;
      _storage = null;
      _initCompleter = null;
      _lastAudioPlayTime = null;
      _currentExerciseId = null;
      _lastTick = null;
      state = null;
    }
  }

  // SIMPLIFIED APP LIFECYCLE: Only handle critical state for iOS
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    super.didChangeAppLifecycleState(state);
    _debugLogIOSCompletionTrace(
      'didChangeAppLifecycleState',
      extra: {'nextLifecycleState': state.name},
    );

    if (state == AppLifecycleState.resumed) {
      unawaited(_handleIOSResume());
    } else if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused) &&
        this.state?.isActive == true &&
        Platform.isIOS) {
      unawaited(_handleIOSAppMovedToBackground());
    }
  }

  Future<void> _handleIOSResume() async {
    _debugLogIOSCompletionTrace('_handleIOSResume:start');
    await _syncTimerStateAfterResume();

    if (state?.isActive == true && Platform.isIOS) {
      await _handleIOSAppBecameForeground();
    }
    _debugLogIOSCompletionTrace('_handleIOSResume:end');
  }

  Future<void> _handleIOSAppBecameForeground() async {
    try {
      _debugLogIOSCompletionTrace('_handleIOSAppBecameForeground:start');
      await _applyIOSCompletionDeliveryStrategy();
      await _saveState(immediate: true);
      _debugLogIOSCompletionTrace('_handleIOSAppBecameForeground:end');
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [UnifiedTimer] Failed to switch iOS timer back to foreground audio: $e',
        );
      }
      _debugLogIOSCompletionTrace(
        '_handleIOSAppBecameForeground:error',
        extra: {'error': e.toString()},
      );
    }
  }

  Future<void> _handleIOSAppMovedToBackground() async {
    try {
      _debugLogIOSCompletionTrace('_handleIOSAppMovedToBackground:start');
      await _applyIOSCompletionDeliveryStrategy();
      await _saveState(immediate: true);
      _debugLogIOSCompletionTrace('_handleIOSAppMovedToBackground:end');
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [UnifiedTimer] Failed to arm iOS notification-owned completion: $e',
        );
      }
      _debugLogIOSCompletionTrace(
        '_handleIOSAppMovedToBackground:error',
        extra: {'error': e.toString()},
      );
    }
  }

  Future<void> _syncTimerStateAfterResume() async {
    final currentState = state;
    if (currentState == null || !currentState.isActive) return;

    final endTime = _cachedEndTime ?? currentState.endTime;
    if (endTime == null) return;

    final now = DateTime.now();
    final remaining = endTime.difference(now).inSeconds;
    _debugLogIOSCompletionTrace(
      '_syncTimerStateAfterResume:computedRemaining',
      extra: {
        'now': now.toIso8601String(),
        'remaining': remaining,
        'endTime': endTime.toIso8601String(),
      },
    );

    if (remaining <= 0) {
      if (!currentState.audioPlayed && !_completionInProgress) {
        _stopTicker();
        _cachedEndTime = null;
        _remainingSecondsNotifier?.value = 0;

        var completionState = currentState.copyWith(
          status: TimerStatus.completed,
          remainingSeconds: 0,
        );

        if (Platform.isIOS) {
          final notificationOwnedBySystem =
              currentState.completionDeliveryStrategy ==
              TimerCompletionDeliveryStrategy.notificationOwned;

          if (notificationOwnedBySystem) {
            bool notificationDelivered = false;

            try {
              notificationDelivered =
                  await _unifiedChannel.invokeMethod<bool>(
                    'wasScheduledCompletionDelivered',
                  ) ??
                  false;
              _debugLogIOSCompletionTrace(
                '_syncTimerStateAfterResume:notificationDeliveryChecked',
                extra: {'notificationDelivered': notificationDelivered},
              );
            } catch (e) {
              if (kDebugMode) {
                debugPrint(
                  '⚠️ [UnifiedTimer] Could not verify delivered iOS completion notification after resume: $e',
                );
              }
              _debugLogIOSCompletionTrace(
                '_syncTimerStateAfterResume:notificationDeliveryCheckFailed',
                extra: {'error': e.toString()},
              );
            }

            if (!notificationDelivered) {
              try {
                await _unifiedChannel.invokeMethod<void>(
                  'cancelScheduledCompletion',
                );
              } catch (e) {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ [UnifiedTimer] Could not cancel stale iOS completion notification on resume: $e',
                  );
                }
              }
              _debugLogIOSCompletionTrace(
                '_syncTimerStateAfterResume:switchedToForegroundFallback',
                extra: {'notificationDelivered': notificationDelivered},
              );

              completionState = completionState.copyWith(
                completionDeliveryStrategy:
                    TimerCompletionDeliveryStrategy.foregroundAudio,
              );
            }
          }
        }

        state = completionState;
        _debugLogIOSCompletionTrace(
          '_syncTimerStateAfterResume:stateMarkedCompleted',
        );
        await _onTimerComplete();
      }
    } else {
      _remainingSecondsNotifier?.value = remaining;
      state = currentState.copyWith(remainingSeconds: remaining);
      _debugLogIOSCompletionTrace(
        '_syncTimerStateAfterResume:stateAdjusted',
        extra: {'remaining': remaining},
      );
    }
  }

  bool _isAppInForeground() {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    return lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed;
  }
}

// Provider instances
final unifiedTimerProvider =
    NotifierProvider<UnifiedTimerProvider, UnifiedTimerState?>(
      UnifiedTimerProvider.new,
    );

// Selective providers to reduce rebuilds
final timerIsActiveProvider = Provider<bool>((ref) {
  return ref.watch(
    unifiedTimerProvider.select((state) => state?.isActive ?? false),
  );
});

final timerRemainingSecondsProvider = Provider<int>((ref) {
  return ref.watch(
    unifiedTimerProvider.select((state) => state?.remainingSeconds ?? 0),
  );
});

final timerProgressProvider = Provider<double>((ref) {
  return ref.watch(
    unifiedTimerProvider.select((state) => state?.progress ?? 0.0),
  );
});

final timerStatusProvider = Provider<TimerStatus?>((ref) {
  return ref.watch(unifiedTimerProvider.select((state) => state?.status));
});
