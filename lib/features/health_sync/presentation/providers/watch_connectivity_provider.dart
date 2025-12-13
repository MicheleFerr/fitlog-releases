/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/health_sync/presentation/providers
/// Feature: health_sync
/// Type: provider
///
/// Apple Watch Connectivity Provider - Manages Watch connection state and communication
///
/// **iOS Only**: Uses WatchConnectivity framework via method channel
/// **Android**: Returns unavailable state
///
/// **Responsibilities**:
/// - Monitor watch connection/reachability status
/// - Send workout templates to Watch
/// - Receive completed workouts from Watch
/// - Stream connection state changes
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';

/// Watch connectivity state
enum WatchConnectionState {
  /// Watch is not paired with iPhone
  notPaired,

  /// Watch is paired but app is not installed
  appNotInstalled,

  /// Watch app is installed but not reachable
  notReachable,

  /// Watch is connected and reachable
  connected,

  /// Platform does not support Apple Watch (Android)
  unavailable,

  /// Loading/checking status
  checking,
}

/// Watch connectivity data model
class WatchConnectivityData {
  const WatchConnectivityData({
    required this.state,
    this.errorMessage,
    this.lastSyncTime,
    this.templatesCount = 0,
    // ⌚ Health metrics from Apple Watch
    this.currentHeartRate = 0,
    this.currentCalories = 0,
    this.currentElapsedTime = 0,
    this.lastHealthMetricsUpdate,
  });

  /// Create initial checking state
  const WatchConnectivityData.checking()
      : state = WatchConnectionState.checking,
        errorMessage = null,
        lastSyncTime = null,
        templatesCount = 0,
        currentHeartRate = 0,
        currentCalories = 0,
        currentElapsedTime = 0,
        lastHealthMetricsUpdate = null;

  /// Create unavailable state (Android)
  const WatchConnectivityData.unavailable()
      : state = WatchConnectionState.unavailable,
        errorMessage = 'Apple Watch not supported on this platform',
        lastSyncTime = null,
        templatesCount = 0,
        currentHeartRate = 0,
        currentCalories = 0,
        currentElapsedTime = 0,
        lastHealthMetricsUpdate = null;

  final WatchConnectionState state;
  final String? errorMessage;
  final DateTime? lastSyncTime;
  final int templatesCount;

  // ⌚ Health metrics from Apple Watch
  final double currentHeartRate;
  final double currentCalories;
  final double currentElapsedTime;
  final DateTime? lastHealthMetricsUpdate;

  bool get isConnected => state == WatchConnectionState.connected;
  bool get isPaired => state != WatchConnectionState.notPaired;
  bool get isAppInstalled =>
      state != WatchConnectionState.appNotInstalled &&
      state != WatchConnectionState.notPaired;

  /// Check if we have recent health metrics (within last 30 seconds)
  bool get hasRecentHealthMetrics {
    if (lastHealthMetricsUpdate == null) return false;
    return DateTime.now().difference(lastHealthMetricsUpdate!).inSeconds < 30;
  }

  WatchConnectivityData copyWith({
    WatchConnectionState? state,
    String? errorMessage,
    DateTime? lastSyncTime,
    int? templatesCount,
    double? currentHeartRate,
    double? currentCalories,
    double? currentElapsedTime,
    DateTime? lastHealthMetricsUpdate,
  }) {
    return WatchConnectivityData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      templatesCount: templatesCount ?? this.templatesCount,
      currentHeartRate: currentHeartRate ?? this.currentHeartRate,
      currentCalories: currentCalories ?? this.currentCalories,
      currentElapsedTime: currentElapsedTime ?? this.currentElapsedTime,
      lastHealthMetricsUpdate: lastHealthMetricsUpdate ?? this.lastHealthMetricsUpdate,
    );
  }
}

/// Provider for Watch connectivity state
final watchConnectivityProvider =
    StateNotifierProvider<WatchConnectivityNotifier, WatchConnectivityData>((ref) {
  return WatchConnectivityNotifier();
});

/// Callback for when Watch completes a set
/// - effort: Optional effort value (RPE 6-10 or RIR 0-4)
/// - effortScale: "rpe" or "rir"
typedef OnSetCompletedFromWatch = void Function({int? effort, String? effortScale});

/// Callback for when Watch skips rest
typedef OnSkipRestFromWatch = void Function();

/// Callback for when Watch sends health metrics (HR, calories)
typedef OnHealthMetricsFromWatch = void Function(double heartRate, double calories, double elapsedTime);

/// Callback for when Watch requests to end the workout
/// - [save]: true to save the workout, false to discard
typedef OnEndWorkoutFromWatch = void Function({bool save});

/// Callback for when Watch requests to pause the workout
typedef OnPauseWorkoutFromWatch = void Function();

/// Callback for when Watch modifies next set (weight/reps)
typedef OnSetModificationFromWatch = void Function(double weight, int reps);

/// Callback for when Watch extends the rest timer
typedef OnExtendTimerFromWatch = void Function(int seconds);

/// Notifier that manages Apple Watch connectivity
class WatchConnectivityNotifier extends StateNotifier<WatchConnectivityData> {
  WatchConnectivityNotifier() : super(const WatchConnectivityData.checking()) {
    _initialize();
  }

  // Method channel for iOS Watch Connectivity
  static const _channel = MethodChannel('com.gymbro/watch_connectivity');

  StreamSubscription<dynamic>? _stateChangesSubscription;
  StreamSubscription<dynamic>? _workoutReceivedSubscription;

  // Callbacks for Watch events
  OnSetCompletedFromWatch? onSetCompletedFromWatch;
  OnSkipRestFromWatch? onSkipRestFromWatch;
  OnHealthMetricsFromWatch? onHealthMetricsFromWatch;
  OnEndWorkoutFromWatch? onEndWorkoutFromWatch;
  OnPauseWorkoutFromWatch? onPauseWorkoutFromWatch;
  OnSetModificationFromWatch? onSetModificationFromWatch;
  OnExtendTimerFromWatch? onExtendTimerFromWatch;

  /// Initialize watch connectivity
  Future<void> _initialize() async {
    if (!Platform.isIOS) {
      state = const WatchConnectivityData.unavailable();
      return;
    }

    try {
      // Setup method call handler for events FROM native
      _channel.setMethodCallHandler(_handleNativeCall);

      // Check initial state
      await checkWatchStatus();

      // Listen for state changes
      _listenToStateChanges();

      // Listen for incoming workouts
      _listenToWorkoutReceived();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing watch connectivity: $e');
      }
      state = state.copyWith(
        state: WatchConnectionState.notReachable,
        errorMessage: 'Failed to initialize: $e',
      );
    }
  }

  /// Handle method calls from native iOS
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    print('⌚ [FLUTTER] Received from native: ${call.method}');

    switch (call.method) {
      case 'onSetCompletedFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final effort = args?['effort'] as int?;
        final effortScale = args?['effortScale'] as String?;
        if (effort != null) {
          print('⌚ [FLUTTER] ✅ Set completed from Watch with ${effortScale?.toUpperCase() ?? "RPE"}: $effort');
        } else {
          print('⌚ [FLUTTER] ✅ Set completed from Watch (no effort)');
        }
        onSetCompletedFromWatch?.call(effort: effort, effortScale: effortScale);
        return true;

      case 'onSkipRestFromWatch':
        print('⌚ [FLUTTER] ⏭️ Rest skipped from Watch!');
        onSkipRestFromWatch?.call();
        return true;

      case 'onHealthMetricsFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final heartRate = (args['heartRate'] as num?)?.toDouble() ?? 0;
          final calories = (args['calories'] as num?)?.toDouble() ?? 0;
          final elapsedTime = (args['elapsedTime'] as num?)?.toDouble() ?? 0;
          print('⌚ [FLUTTER] ❤️ Health metrics received: HR=${heartRate.toInt()} BPM, Cal=${calories.toInt()} kcal, Time=${elapsedTime.toInt()}s');

          // Update state with latest health metrics
          state = state.copyWith(
            currentHeartRate: heartRate,
            currentCalories: calories,
            currentElapsedTime: elapsedTime,
            lastHealthMetricsUpdate: DateTime.now(),
          );

          // Also notify callback for additional processing
          onHealthMetricsFromWatch?.call(heartRate, calories, elapsedTime);
        }
        return true;

      case 'onWatchStateChanged':
        // Handle state changes
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final isReachable = args['isReachable'] as bool? ?? false;
          final isPaired = args['isPaired'] as bool? ?? false;
          final isInstalled = args['isWatchAppInstalled'] as bool? ?? false;

          WatchConnectionState newState;
          if (!isPaired) {
            newState = WatchConnectionState.notPaired;
          } else if (!isInstalled) {
            newState = WatchConnectionState.appNotInstalled;
          } else if (!isReachable) {
            newState = WatchConnectionState.notReachable;
          } else {
            newState = WatchConnectionState.connected;
          }

          state = state.copyWith(state: newState);
          print('⌚ [FLUTTER] Watch state updated: $newState');
        }
        return true;

      case 'onEndWorkoutFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final save = args?['save'] as bool? ?? true;
        print('⌚ [FLUTTER] 🏁 End workout requested from Watch (save: $save)');
        onEndWorkoutFromWatch?.call(save: save);
        return true;

      case 'onPauseWorkoutFromWatch':
        print('⌚ [FLUTTER] ⏸️ Pause workout requested from Watch!');
        onPauseWorkoutFromWatch?.call();
        return true;

      case 'onSetModificationFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final weight = (args['weight'] as num?)?.toDouble() ?? 0;
          final reps = (args['reps'] as num?)?.toInt() ?? 0;
          print('⌚ [FLUTTER] ✏️ Set modification from Watch: ${weight}kg × $reps reps');
          onSetModificationFromWatch?.call(weight, reps);
        }
        return true;

      case 'onExtendTimerFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final seconds = (args['seconds'] as num?)?.toInt() ?? 0;
          print('⌚ [FLUTTER] ⏱️ Timer extension from Watch: +${seconds}s');
          onExtendTimerFromWatch?.call(seconds);
        }
        return true;

      default:
        print('⌚ [FLUTTER] Unknown method: ${call.method}');
        return null;
    }
  }

  /// Check current watch status
  Future<void> checkWatchStatus() async {
    if (!Platform.isIOS) {
      state = const WatchConnectivityData.unavailable();
      return;
    }

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('checkWatchStatus');

      if (result == null) {
        state = state.copyWith(
          state: WatchConnectionState.notReachable,
          errorMessage: 'No response from watch connectivity',
        );
        return;
      }

      final isPaired = result['isPaired'] as bool? ?? false;
      final isAppInstalled = result['isAppInstalled'] as bool? ?? false;
      final isReachable = result['isReachable'] as bool? ?? false;

      WatchConnectionState newState;
      if (!isPaired) {
        newState = WatchConnectionState.notPaired;
      } else if (!isAppInstalled) {
        newState = WatchConnectionState.appNotInstalled;
      } else if (!isReachable) {
        newState = WatchConnectionState.notReachable;
      } else {
        newState = WatchConnectionState.connected;
      }

      state = state.copyWith(state: newState, errorMessage: null);

      if (kDebugMode) {
        debugPrint('Watch Status:');
        debugPrint('  Paired: $isPaired');
        debugPrint('  App Installed: $isAppInstalled');
        debugPrint('  Reachable: $isReachable');
        debugPrint('  State: $newState');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Platform exception checking watch status: $e');
      }
      state = state.copyWith(
        state: WatchConnectionState.notReachable,
        errorMessage: e.message ?? 'Unknown error',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking watch status: $e');
      }
      state = state.copyWith(
        state: WatchConnectionState.notReachable,
        errorMessage: 'Error: $e',
      );
    }
  }

  /// Listen for watch state changes
  /// Note: EventChannel not yet implemented on iOS - silently fails
  void _listenToStateChanges() {
    try {
      const stateChannel = EventChannel('com.gymbro/watch_connectivity_state');
      _stateChangesSubscription = stateChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            final isPaired = event['isPaired'] as bool? ?? false;
            final isAppInstalled = event['isAppInstalled'] as bool? ?? false;
            final isReachable = event['isReachable'] as bool? ?? false;

            WatchConnectionState newState;
            if (!isPaired) {
              newState = WatchConnectionState.notPaired;
            } else if (!isAppInstalled) {
              newState = WatchConnectionState.appNotInstalled;
            } else if (!isReachable) {
              newState = WatchConnectionState.notReachable;
            } else {
              newState = WatchConnectionState.connected;
            }

            state = state.copyWith(state: newState);
            print('Watch state changed: $newState');
          }
        },
        onError: (error) {
          // EventChannel not implemented - this is expected
          print('⌚ Watch state EventChannel not available (expected)');
        },
      );
    } catch (e) {
      // EventChannel not implemented on iOS - this is fine
      print('⌚ Watch state EventChannel setup failed (expected): $e');
    }
  }

  /// Listen for workout completion events from watch
  /// Note: EventChannel not yet implemented on iOS - silently fails
  void _listenToWorkoutReceived() {
    try {
      const workoutChannel = EventChannel('com.gymbro/watch_workout_received');
      _workoutReceivedSubscription = workoutChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            print('Received workout from watch: $event');
            // The watch_workout_sync_service will handle the actual conversion
          }
        },
        onError: (error) {
          // EventChannel not implemented - this is expected
          print('⌚ Watch workout EventChannel not available (expected)');
        },
      );
    } catch (e) {
      // EventChannel not implemented on iOS - this is fine
      print('⌚ Watch workout EventChannel setup failed (expected): $e');
    }
  }

  /// Send workout templates to Watch
  Future<bool> sendTemplatesToWatch(List<CommunityWorkoutTemplate> templates) async {
    if (!Platform.isIOS) {
      if (kDebugMode) {
        debugPrint('Cannot send templates: Platform not supported');
      }
      return false;
    }

    if (!state.isConnected) {
      if (kDebugMode) {
        debugPrint('Cannot send templates: Watch not connected');
      }
      return false;
    }

    try {
      // Convert templates to JSON format for native side
      final templatesJson = templates.map((t) => {
        'id': t.id,
        'name': t.name,
        'description': t.description ?? '',
        'exercises': t.exercises.map((e) => {
          'id': e.id,
          'name': e.name,
          'sets': e.sets.length,
          'category': e.category.toString(),
        }).toList(),
        'category': t.category.toString(),
        'estimatedDurationMinutes': t.estimatedDurationMinutes ?? 0,
      }).toList();

      final success = await _channel.invokeMethod<bool>(
        'sendTemplatesToWatch',
        {'templates': templatesJson},
      ) ?? false;

      if (success) {
        state = state.copyWith(
          templatesCount: templates.length,
          lastSyncTime: DateTime.now(),
        );

        if (kDebugMode) {
          debugPrint('Successfully sent ${templates.length} templates to watch');
        }
      }

      return success;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send templates to watch: $e');
      }
      state = state.copyWith(
        errorMessage: 'Failed to send templates: ${e.message}',
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending templates to watch: $e');
      }
      state = state.copyWith(
        errorMessage: 'Error sending templates: $e',
      );
      return false;
    }
  }

  /// Open Watch app settings (system Settings app)
  Future<void> openWatchSettings() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('openWatchSettings');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to open watch settings: $e');
      }
    }
  }

  // ============================================================
  // WORKOUT COMPANION API - Notify Watch about workout state
  // ============================================================

  /// Notify Watch that a workout has started on iPhone
  /// - rpeTrackingEnabled: Whether RPE/RIR tracking is enabled in app settings
  /// - effortScale: "rpe" (6-10 scale) or "rir" (0-4 scale)
  /// - locale: App locale ("en" or "it") for Watch UI strings
  /// - formCues: Persistent technique reminders for the exercise
  /// - tut: Time Under Tension (e.g., "3-1-2-0") for tempo guidance
  Future<void> notifyWorkoutStarted({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    double? targetWeight,
    int? targetReps,
    int setsCompleted = 0,
    bool rpeTrackingEnabled = false,
    String effortScale = 'rpe',
    String locale = 'en',
    String? formCues,
    String? tut, // ⌚ BUG FIX #3: Time Under Tension
  }) async {
    // 🔍 DEBUG: Log entry and state check (using print for release mode visibility)
    print('⌚ [PROVIDER DEBUG] notifyWorkoutStarted called');
    print('⌚ [PROVIDER DEBUG] Platform.isIOS: ${Platform.isIOS}');
    print('⌚ [PROVIDER DEBUG] state.isConnected: ${state.isConnected}');
    print('⌚ [PROVIDER DEBUG] state.state: ${state.state}');
    print('⌚ [PROVIDER DEBUG] rpeTrackingEnabled: $rpeTrackingEnabled, effortScale: $effortScale, locale: $locale');

    if (!Platform.isIOS) {
      print('⌚ [PROVIDER DEBUG] ❌ Not iOS, returning');
      return;
    }

    if (!state.isConnected) {
      print('⌚ [PROVIDER DEBUG] ⚠️ Watch not connected, but attempting anyway...');
      // DON'T return - try anyway, native side has fallback
    }

    try {
      print('⌚ [PROVIDER DEBUG] Calling _channel.invokeMethod(notifyWorkoutStarted)');
      await _channel.invokeMethod('notifyWorkoutStarted', {
        'exerciseName': exerciseName,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'targetWeight': targetWeight ?? 0.0,
        'targetReps': targetReps ?? 0,
        'setsCompleted': setsCompleted,
        'rpeTrackingEnabled': rpeTrackingEnabled,
        'effortScale': effortScale,
        'locale': locale,
        'formCues': formCues ?? '',
        'tut': tut ?? '', // ⌚ BUG FIX #3: Time Under Tension
      });

      print('⌚ [PROVIDER DEBUG] ✅ invokeMethod completed successfully');
      print('🏋️ Notified Watch: workout started - $exerciseName (RPE: $rpeTrackingEnabled, locale: $locale, TUT: ${tut ?? "none"})');
    } on PlatformException catch (e) {
      print('⌚ [PROVIDER DEBUG] ❌ PlatformException: $e');
    }
  }

  /// Notify Watch that workout has ended
  Future<void> notifyWorkoutEnded() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('notifyWorkoutEnded');

      if (kDebugMode) {
        debugPrint('🏁 Notified Watch: workout ended');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to notify Watch of workout end: $e');
      }
    }
  }

  /// Send workout update (exercise/set changed)
  /// Uses sendMessage for immediate delivery when reachable
  /// - rpeTrackingEnabled: Whether RPE/RIR tracking is enabled in app settings
  /// - effortScale: "rpe" (6-10 scale) or "rir" (0-4 scale)
  /// - locale: App locale ("en" or "it") for Watch UI strings
  /// - formCues: Persistent technique reminders for the exercise
  /// - tut: Time Under Tension (e.g., "3-1-2-0") for tempo guidance
  Future<void> sendWorkoutUpdate({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    double? targetWeight,
    int? targetReps,
    int setsCompleted = 0,
    bool rpeTrackingEnabled = false,
    String effortScale = 'rpe',
    String locale = 'en',
    String? formCues,
    String? tut, // ⌚ BUG FIX #3: Time Under Tension
  }) async {
    if (!Platform.isIOS) return;

    // Note: This uses sendMessage which requires reachability
    // For reliability, we could add applicationContext fallback on iOS side
    try {
      await _channel.invokeMethod('sendWorkoutUpdate', {
        'exerciseName': exerciseName,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'targetWeight': targetWeight ?? 0.0,
        'targetReps': targetReps ?? 0,
        'setsCompleted': setsCompleted,
        'rpeTrackingEnabled': rpeTrackingEnabled,
        'effortScale': effortScale,
        'locale': locale,
        'formCues': formCues ?? '',
        'tut': tut ?? '', // ⌚ BUG FIX #3: Time Under Tension
      });
      print('⌚ Sent workout update: $exerciseName Set $currentSet/$totalSets (TUT: ${tut ?? "none"})');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send workout update to Watch: $e');
      }
    }
  }

  /// Notify Watch that rest timer started
  /// Uses applicationContext for reliable delivery (works even when Watch not reachable)
  Future<void> sendRestTimerStarted(int durationSeconds) async {
    if (!Platform.isIOS) return;

    // ✅ FIX: Remove isConnected check - iOS uses applicationContext which
    // delivers reliably even when Watch is not directly reachable
    try {
      await _channel.invokeMethod('sendRestTimerStarted', {
        'duration': durationSeconds,
      });

      print('⏱️ Notified Watch: rest timer ${durationSeconds}s');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to notify Watch of rest timer: $e');
      }
    }
  }

  /// Notify Watch that rest was skipped
  Future<void> sendRestTimerSkipped() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('sendRestTimerSkipped');

      if (kDebugMode) {
        debugPrint('⏭️ Notified Watch: rest skipped');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to notify Watch of rest skip: $e');
      }
    }
  }

  /// Notify Watch that rest timer was paused
  Future<void> sendRestTimerPaused(int remainingSeconds) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('sendRestTimerPaused', {
        'remainingTime': remainingSeconds,
      });

      if (kDebugMode) {
        debugPrint('⏸️ Notified Watch: rest paused (${remainingSeconds}s remaining)');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to notify Watch of rest pause: $e');
      }
    }
  }

  /// Notify Watch that rest timer was resumed
  Future<void> sendRestTimerResumed(int remainingSeconds) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('sendRestTimerResumed', {
        'remainingTime': remainingSeconds,
      });

      if (kDebugMode) {
        debugPrint('▶️ Notified Watch: rest resumed (${remainingSeconds}s remaining)');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to notify Watch of rest resume: $e');
      }
    }
  }

  @override
  void dispose() {
    _stateChangesSubscription?.cancel();
    _workoutReceivedSubscription?.cancel();
    super.dispose();
  }
}

/// Convenience getter for watch reachability
final isWatchReachableProvider = Provider<bool>((ref) {
  return ref.watch(watchConnectivityProvider).isConnected;
});

/// Convenience getter for watch app installed
final isWatchAppInstalledProvider = Provider<bool>((ref) {
  return ref.watch(watchConnectivityProvider).isAppInstalled;
});
