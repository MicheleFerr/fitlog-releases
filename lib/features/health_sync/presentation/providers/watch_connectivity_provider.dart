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
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';

/// P2-14 FIX: Debug-only logging helper
/// Flutter's debugPrint prints even in release mode, unlike Swift's print
void _watchLog(String message) {
  // ignore: avoid_print
  if (kDebugMode) debugPrint(message);
}

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
      lastHealthMetricsUpdate:
          lastHealthMetricsUpdate ?? this.lastHealthMetricsUpdate,
    );
  }
}

/// Provider for Watch connectivity state
final watchConnectivityProvider =
    NotifierProvider<WatchConnectivityNotifier, WatchConnectivityData>(
      WatchConnectivityNotifier.new,
    );

/// Callback for when Watch completes a set
/// - effort: Optional effort value (RPE 6-10 or RIR 0-4)
/// - effortScale: "rpe" or "rir"
/// - actualReps: Optional actual reps performed (from rep range picker on Watch)
typedef OnSetCompletedFromWatch =
    void Function({int? effort, String? effortScale, int? actualReps});

/// Callback for when Watch skips rest
typedef OnSkipRestFromWatch = void Function();

/// Callback for when Watch sends health metrics (HR, calories)
typedef OnHealthMetricsFromWatch =
    void Function(double heartRate, double calories, double elapsedTime);

/// Callback for when Watch requests to end the workout
/// - [save]: true to save the workout, false to discard
typedef OnEndWorkoutFromWatch = void Function({bool save});

/// Callback for when Watch requests to pause the workout
typedef OnPauseWorkoutFromWatch = void Function();

/// Callback for when Watch modifies a set (weight/reps)
/// [setNumber] is 1-indexed set number being modified
/// [exerciseIndexInSuperset] is 0-indexed, only provided for superset exercises
typedef OnSetModificationFromWatch =
    void Function(
      double weight,
      int reps, {
      required int setNumber,
      bool isSuperset,
      int? exerciseIndexInSuperset,
    });

/// Callback for when Watch extends the rest timer
typedef OnExtendTimerFromWatch = void Function(int seconds);

/// Callback for when Watch requests to edit a SPECIFIC completed set's reps
/// - setIndex: 0-indexed position of the set to edit (0 = first completed set)
/// - reps: New reps value
typedef OnEditCompletedSetRepsFromWatch = void Function(int setIndex, int reps);

/// Callback for when Watch requests to uncomplete (undo) a completed set
/// - setIndex: 0-indexed position of the set to uncomplete
typedef OnUncompleteSetFromWatch = void Function(int setIndex);

/// Callback for when Watch requests the current workout state (e.g., on reconnect)
/// Note: iOS native layer responds directly, this is informational for Flutter
typedef OnWorkoutStateRequested = void Function();

/// Callback for when Watch requests to jump to a specific exercise
/// - exerciseIndex: 0-indexed position of the exercise to navigate to
typedef OnJumpToExerciseFromWatch = void Function(int exerciseIndex);

/// Callback for when Watch requests to jump to a specific set
/// - setNumber: 1-indexed set number to navigate to
typedef OnJumpToSetFromWatch = void Function(int setNumber);

/// Callback for when Watch requests to copy weight/reps to all sets
/// - weight: Weight value to apply to all sets
/// - reps: Reps value to apply to all sets
typedef OnCopyToAllSetsFromWatch = void Function(double weight, int reps);

/// Callback for when Watch requests to copy from previous set
typedef OnCopyFromPreviousSetFromWatch = void Function();

/// Callback for when Watch requests to start a new timer with specific duration
/// - duration: Timer duration in seconds
typedef OnStartNewTimerFromWatch = void Function(int duration);

/// 🔥 SUPERSET: Callback for when Watch completes an entire superset round
/// - roundNumber: 1-indexed round number completed
/// - totalRounds: Total rounds in the superset
/// - exercises: List of exercise names in the round
/// - effort: Optional effort value (RPE 6-10 or RIR 0-4) for the entire round
/// - effortScale: "rpe" or "rir"
typedef OnSupersetRoundCompletedFromWatch =
    void Function({
      required int roundNumber,
      required int totalRounds,
      required List<String> exercises,
      int? effort,
      String? effortScale,
    });

/// 🔥 DROPSET: Callback for when Watch completes a single dropset stage
/// - stageIndex: 0-indexed stage number
/// - totalStages: Total stages in the dropset
/// - actualReps: Actual reps performed
/// - effort: Optional effort value (RPE 6-10 or RIR 0-4)
/// - effortScale: "rpe" or "rir"
typedef OnDropsetStageCompletedFromWatch =
    void Function({
      required int stageIndex,
      required int totalStages,
      required int actualReps,
      int? effort,
      String? effortScale,
    });

/// 🔥 DROPSET: Callback for when Watch completes entire dropset (all stages)
/// - totalStages: Total stages completed
/// - effort: Optional effort value for entire dropset
/// - effortScale: "rpe" or "rir"
typedef OnDropsetCompletedFromWatch =
    void Function({required int totalStages, int? effort, String? effortScale});

/// 🔥 REST-PAUSE: Callback for when Watch completes a single rest-pause mini-set
/// - setIndex: 0-indexed set number
/// - totalSets: Total mini-sets in the rest-pause
/// - actualReps: Actual reps performed
/// - weight: Weight used
/// - effort: Optional effort value (RPE 6-10 or RIR 0-4)
/// - effortScale: "rpe" or "rir"
typedef OnRestPauseSetCompletedFromWatch =
    void Function({
      required int setIndex,
      required int totalSets,
      required int actualReps,
      required double weight,
      int? effort,
      String? effortScale,
    });

/// 🔥 REST-PAUSE: Callback for when Watch completes entire rest-pause (all mini-sets)
/// - totalSets: Total mini-sets completed
/// - weight: Weight used
/// - effort: Optional effort value for entire rest-pause
/// - effortScale: "rpe" or "rir"
typedef OnRestPauseCompletedFromWatch =
    void Function({
      required int totalSets,
      required double weight,
      int? effort,
      String? effortScale,
    });

/// 📸 Recovery: Callback for full workout snapshot from Watch (crash recovery)
typedef OnFullWorkoutSnapshotFromWatch = void Function(Map<String, dynamic> snapshot);

/// Notifier that manages Apple Watch connectivity
class WatchConnectivityNotifier extends Notifier<WatchConnectivityData> {
  @override
  WatchConnectivityData build() {
    _initialize();
    return const WatchConnectivityData.checking();
  }

  // Method channel for iOS Watch Connectivity
  static const _channel = MethodChannel(PlatformChannels.watchConnectivity);

  // Note: EventChannel subscriptions removed - state changes are handled via
  // MethodChannel callbacks (onWatchStateChanged, etc.) which are properly
  // implemented on iOS side. EventChannels were causing MissingPluginException.

  // Callbacks for Watch events
  OnSetCompletedFromWatch? onSetCompletedFromWatch;
  OnSkipRestFromWatch? onSkipRestFromWatch;
  OnHealthMetricsFromWatch? onHealthMetricsFromWatch;
  OnEndWorkoutFromWatch? onEndWorkoutFromWatch;
  OnPauseWorkoutFromWatch? onPauseWorkoutFromWatch;
  OnSetModificationFromWatch? onSetModificationFromWatch;
  OnExtendTimerFromWatch? onExtendTimerFromWatch;
  OnEditCompletedSetRepsFromWatch? onEditCompletedSetRepsFromWatch;
  OnUncompleteSetFromWatch? onUncompleteSetFromWatch;
  OnWorkoutStateRequested? onWorkoutStateRequested;
  OnSupersetRoundCompletedFromWatch? onSupersetRoundCompletedFromWatch;
  // 🔄 Navigation & Copy callbacks (from Watch)
  OnJumpToExerciseFromWatch? onJumpToExerciseFromWatch;
  OnJumpToSetFromWatch? onJumpToSetFromWatch;
  OnCopyToAllSetsFromWatch? onCopyToAllSetsFromWatch;
  OnCopyFromPreviousSetFromWatch? onCopyFromPreviousSetFromWatch;
  OnStartNewTimerFromWatch? onStartNewTimerFromWatch;
  // 🔥 DROPSET callbacks
  OnDropsetStageCompletedFromWatch? onDropsetStageCompletedFromWatch;
  OnDropsetCompletedFromWatch? onDropsetCompletedFromWatch;
  // 🔥 REST-PAUSE callbacks
  OnRestPauseSetCompletedFromWatch? onRestPauseSetCompletedFromWatch;
  OnRestPauseCompletedFromWatch? onRestPauseCompletedFromWatch;
  // 📸 Recovery callback
  OnFullWorkoutSnapshotFromWatch? onFullWorkoutSnapshotFromWatch;

  /// Initialize watch connectivity
  Future<void> _initialize() async {
    if (!Platform.isIOS) {
      state = const WatchConnectivityData.unavailable();
      return;
    }

    try {
      // Setup method call handler for events FROM native
      // State changes come via MethodChannel callbacks (onWatchStateChanged, etc.)
      _channel.setMethodCallHandler(_handleNativeCall);

      // Check initial state
      await checkWatchStatus();

      // Note: EventChannel listeners removed - iOS uses MethodChannel callbacks
      // for state changes (onWatchStateChanged) which are more reliable
    } catch (e) {
      if (kDebugMode) {
        _watchLog('Error initializing watch connectivity: $e');
      }
      state = state.copyWith(
        state: WatchConnectionState.notReachable,
        errorMessage: 'Failed to initialize: $e',
      );
    }
  }

  /// Handle method calls from native iOS
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    _watchLog('⌚ [FLUTTER] Received from native: ${call.method}');

    switch (call.method) {
      case 'onSetCompletedFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final effort = args?['effort'] as int?;
        final effortScale = args?['effortScale'] as String?;
        final actualReps = args?['actualReps'] as int?;
        if (effort != null) {
          _watchLog(
            '⌚ [FLUTTER] ✅ Set completed from Watch with ${effortScale?.toUpperCase() ?? "RPE"}: $effort${actualReps != null ? ", actualReps: $actualReps" : ""}',
          );
        } else {
          _watchLog('⌚ [FLUTTER] ✅ Set completed from Watch (no effort)${actualReps != null ? ", actualReps: $actualReps" : ""}');
        }
        onSetCompletedFromWatch?.call(effort: effort, effortScale: effortScale, actualReps: actualReps);
        return true;

      case 'onSkipRestFromWatch':
        _watchLog('⌚ [FLUTTER] ⏭️ Rest skipped from Watch!');
        onSkipRestFromWatch?.call();
        return true;

      case 'onHealthMetricsFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final heartRate = (args['heartRate'] as num?)?.toDouble() ?? 0;
          final calories = (args['calories'] as num?)?.toDouble() ?? 0;
          final elapsedTime = (args['elapsedTime'] as num?)?.toDouble() ?? 0;
          _watchLog(
            '⌚ [FLUTTER] ❤️ Health metrics received: HR=${heartRate.toInt()} BPM, Cal=${calories.toInt()} kcal, Time=${elapsedTime.toInt()}s',
          );

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
          _watchLog('⌚ [FLUTTER] Watch state updated: $newState');
        }
        return true;

      case 'onEndWorkoutFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final save = args?['save'] as bool? ?? true;
        _watchLog(
          '⌚ [FLUTTER] 🏁 End workout requested from Watch (save: $save)',
        );
        onEndWorkoutFromWatch?.call(save: save);
        return true;

      case 'onPauseWorkoutFromWatch':
        _watchLog('⌚ [FLUTTER] ⏸️ Pause workout requested from Watch!');
        onPauseWorkoutFromWatch?.call();
        return true;

      case 'onSetModificationFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final weight = (args['weight'] as num?)?.toDouble() ?? 0;
          final reps = (args['reps'] as num?)?.toInt() ?? 0;
          // ✅ FIX: Extract setNumber to modify the correct set (1-indexed)
          final setNumber = (args['setNumber'] as num?)?.toInt() ?? 1;
          // 🔥 SUPERSET: Extract superset context if present
          final isSuperset = args['isSuperset'] as bool? ?? false;
          final exerciseIndexInSuperset =
              args['exerciseIndexInSuperset'] as int?;
          _watchLog(
            '⌚ [FLUTTER] ✏️ Set modification from Watch: Set #$setNumber → ${weight}kg × $reps reps (superset: $isSuperset, exerciseIndex: $exerciseIndexInSuperset)',
          );
          onSetModificationFromWatch?.call(
            weight,
            reps,
            setNumber: setNumber,
            isSuperset: isSuperset,
            exerciseIndexInSuperset: exerciseIndexInSuperset,
          );
        }
        return true;

      case 'onExtendTimerFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final seconds = (args['seconds'] as num?)?.toInt() ?? 0;
          _watchLog('⌚ [FLUTTER] ⏱️ Timer extension from Watch: +${seconds}s');
          onExtendTimerFromWatch?.call(seconds);
        }
        return true;

      case 'onEditCompletedSetRepsFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final setIndex =
              (args['setIndex'] as num?)?.toInt() ?? 0; // 0-indexed
          final reps = (args['reps'] as num?)?.toInt() ?? 0;
          _watchLog(
            '⌚ [FLUTTER] ✏️ Edit completed set ${setIndex + 1} from Watch: $reps reps',
          );
          onEditCompletedSetRepsFromWatch?.call(setIndex, reps);
        }
        return true;

      case 'onUncompleteSetFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final setIndex =
              (args['setIndex'] as num?)?.toInt() ?? 0; // 0-indexed
          _watchLog(
            '⌚ [FLUTTER] ↩️ Uncomplete set ${setIndex + 1} from Watch',
          );
          onUncompleteSetFromWatch?.call(setIndex);
        }
        return true;

      case 'onWorkoutStateRequested':
        // Watch requested current workout state (e.g., on reconnect)
        // iOS native layer already responded with cached state
        _watchLog(
          '⌚ [FLUTTER] 🔄 Watch requested workout state (iOS responded)',
        );
        onWorkoutStateRequested?.call();
        return true;

      case 'onSupersetRoundCompletedFromWatch':
        // 🔥 SUPERSET: Watch completed an entire round
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final roundNumber = (args['roundNumber'] as num?)?.toInt() ?? 1;
          final totalRounds = (args['totalRounds'] as num?)?.toInt() ?? 1;
          final exercises =
              (args['exercises'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          final effort = args['effort'] as int?;
          final effortScale = args['effortScale'] as String?;

          if (effort != null) {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Superset round $roundNumber/$totalRounds completed from Watch with ${effortScale?.toUpperCase() ?? "RPE"}: $effort',
            );
          } else {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Superset round $roundNumber/$totalRounds completed from Watch (no effort)',
            );
          }

          onSupersetRoundCompletedFromWatch?.call(
            roundNumber: roundNumber,
            totalRounds: totalRounds,
            exercises: exercises,
            effort: effort,
            effortScale: effortScale,
          );
        }
        return true;

      // 🔥 DROPSET: Handle stage and completion events
      case 'onDropsetStageCompletedFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final stageIndex = (args['stageIndex'] as num?)?.toInt() ?? 0;
          final totalStages = (args['totalStages'] as num?)?.toInt() ?? 0;
          final actualReps = (args['actualReps'] as num?)?.toInt() ?? 0;
          final effort = args['effort'] as int?;
          final effortScale = args['effortScale'] as String?;

          if (effort != null) {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Dropset stage ${stageIndex + 1}/$totalStages completed: $actualReps reps, ${effortScale?.toUpperCase() ?? "RPE"}: $effort',
            );
          } else {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Dropset stage ${stageIndex + 1}/$totalStages completed: $actualReps reps',
            );
          }

          onDropsetStageCompletedFromWatch?.call(
            stageIndex: stageIndex,
            totalStages: totalStages,
            actualReps: actualReps,
            effort: effort,
            effortScale: effortScale,
          );
        }
        return true;

      case 'onDropsetCompletedFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final totalStages = (args['totalStages'] as num?)?.toInt() ?? 0;
          final effort = args['effort'] as int?;
          final effortScale = args['effortScale'] as String?;

          if (effort != null) {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Dropset completed ($totalStages stages) with ${effortScale?.toUpperCase() ?? "RPE"}: $effort',
            );
          } else {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Dropset completed ($totalStages stages)',
            );
          }

          onDropsetCompletedFromWatch?.call(
            totalStages: totalStages,
            effort: effort,
            effortScale: effortScale,
          );
        }
        return true;

      // 🔥 REST-PAUSE: Handle set and completion events
      case 'onRestPauseSetCompletedFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final setIndex = (args['setIndex'] as num?)?.toInt() ?? 0;
          final totalSets = (args['totalSets'] as num?)?.toInt() ?? 0;
          final actualReps = (args['actualReps'] as num?)?.toInt() ?? 0;
          final weight = (args['weight'] as num?)?.toDouble() ?? 0;
          final effort = args['effort'] as int?;
          final effortScale = args['effortScale'] as String?;

          if (effort != null) {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Rest-Pause set ${setIndex + 1}/$totalSets completed: ${weight}kg × $actualReps, ${effortScale?.toUpperCase() ?? "RPE"}: $effort',
            );
          } else {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Rest-Pause set ${setIndex + 1}/$totalSets completed: ${weight}kg × $actualReps',
            );
          }

          onRestPauseSetCompletedFromWatch?.call(
            setIndex: setIndex,
            totalSets: totalSets,
            actualReps: actualReps,
            weight: weight,
            effort: effort,
            effortScale: effortScale,
          );
        }
        return true;

      case 'onRestPauseCompletedFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final totalSets = (args['totalSets'] as num?)?.toInt() ?? 0;
          final weight = (args['weight'] as num?)?.toDouble() ?? 0;
          final effort = args['effort'] as int?;
          final effortScale = args['effortScale'] as String?;

          if (effort != null) {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Rest-Pause completed ($totalSets sets, ${weight}kg) with ${effortScale?.toUpperCase() ?? "RPE"}: $effort',
            );
          } else {
            _watchLog(
              '⌚ [FLUTTER] 🔥 Rest-Pause completed ($totalSets sets, ${weight}kg)',
            );
          }

          onRestPauseCompletedFromWatch?.call(
            totalSets: totalSets,
            weight: weight,
            effort: effort,
            effortScale: effortScale,
          );
        }
        return true;

      // 🔄 Navigation & Copy actions from Watch
      case 'onJumpToExerciseFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final exerciseIndex = (args['exerciseIndex'] as num?)?.toInt() ?? 0;
          _watchLog(
            '⌚ [FLUTTER] ↔️ Jump to exercise $exerciseIndex from Watch',
          );
          onJumpToExerciseFromWatch?.call(exerciseIndex);
        }
        return true;

      case 'onJumpToSetFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final setNumber = (args['setNumber'] as num?)?.toInt() ?? 1;
          _watchLog('⌚ [FLUTTER] ↕️ Jump to set $setNumber from Watch');
          onJumpToSetFromWatch?.call(setNumber);
        }
        return true;

      case 'onCopyToAllSetsFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final weight = (args['weight'] as num?)?.toDouble() ?? 0;
          final reps = (args['reps'] as num?)?.toInt() ?? 0;
          _watchLog(
            '⌚ [FLUTTER] 📄 Copy to all sets from Watch: ${weight}kg × $reps',
          );
          onCopyToAllSetsFromWatch?.call(weight, reps);
        }
        return true;

      case 'onCopyFromPreviousSetFromWatch':
        _watchLog('⌚ [FLUTTER] 📋 Copy from previous set from Watch');
        onCopyFromPreviousSetFromWatch?.call();
        return true;

      case 'onStartNewTimerFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final duration = (args['duration'] as num?)?.toInt() ?? 60;
          _watchLog('⌚ [FLUTTER] ⏱️ Start new timer from Watch: ${duration}s');
          onStartNewTimerFromWatch?.call(duration);
        }
        return true;

      case 'onFullWorkoutSnapshotFromWatch':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final snapshot = Map<String, dynamic>.from(args);
          _watchLog('⌚ [FLUTTER] 📸 Full workout snapshot from Watch (hasActive: ${snapshot['hasActiveWorkout']})');
          onFullWorkoutSnapshotFromWatch?.call(snapshot);
        }
        return true;

      case 'onBackgroundDataReceived':
        // FIX: Handle transferUserInfo messages from Watch that arrived while app was dead.
        // These are queued by WCSession and delivered when app restarts.
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final type = args['type'] as String?;
          _watchLog(
            '⌚ [FLUTTER] 📦 Background data received from Watch: type=$type',
          );
          // Re-dispatch based on message type to the appropriate handler
          switch (type) {
            case 'setCompleted':
              final effort = args['effort'] as int?;
              final effortScale = args['effortScale'] as String?;
              final actualReps = args['actualReps'] as int?;
              onSetCompletedFromWatch?.call(
                effort: effort,
                effortScale: effortScale,
                actualReps: actualReps,
              );
            case 'endWorkout':
              final save = args['save'] as bool? ?? true;
              onEndWorkoutFromWatch?.call(save: save);
            case 'setModification':
              final weight = (args['weight'] as num?)?.toDouble() ?? 0;
              final reps = (args['reps'] as num?)?.toInt() ?? 0;
              final setNumber = (args['setNumber'] as num?)?.toInt() ?? 1;
              onSetModificationFromWatch?.call(weight, reps, setNumber: setNumber);
            case 'skipRest':
              onSkipRestFromWatch?.call();
            case 'pauseWorkout':
              onPauseWorkoutFromWatch?.call();
            default:
              _watchLog(
                '⌚ [FLUTTER] 📦 Unhandled background data type: $type',
              );
          }
        }
        return true;

      default:
        _watchLog('⌚ [FLUTTER] Unknown method: ${call.method}');
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
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'checkWatchStatus',
      );

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
        _watchLog('Watch Status:');
        _watchLog('  Paired: $isPaired');
        _watchLog('  App Installed: $isAppInstalled');
        _watchLog('  Reachable: $isReachable');
        _watchLog('  State: $newState');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Platform exception checking watch status: $e');
      }
      state = state.copyWith(
        state: WatchConnectionState.notReachable,
        errorMessage: e.message ?? 'Unknown error',
      );
    } catch (e) {
      if (kDebugMode) {
        _watchLog('Error checking watch status: $e');
      }
      state = state.copyWith(
        state: WatchConnectionState.notReachable,
        errorMessage: 'Error: $e',
      );
    }
  }

  /// Send workout templates to Watch
  Future<bool> sendTemplatesToWatch(
    List<CommunityWorkoutTemplate> templates,
  ) async {
    if (!Platform.isIOS) {
      if (kDebugMode) {
        _watchLog('Cannot send templates: Platform not supported');
      }
      return false;
    }

    if (!state.isConnected) {
      if (kDebugMode) {
        _watchLog('Cannot send templates: Watch not connected');
      }
      return false;
    }

    try {
      // Convert templates to JSON format for native side
      final templatesJson = templates
          .map(
            (t) => {
              'id': t.id,
              'name': t.name,
              'description': t.description ?? '',
              'exercises': t.exercises
                  .map(
                    (e) => {
                      'id': e.id,
                      'name': e.name,
                      'sets': e.sets.length,
                      'category': e.category.toString(),
                    },
                  )
                  .toList(),
              'category': t.category.toString(),
              'estimatedDurationMinutes': t.estimatedDurationMinutes ?? 0,
            },
          )
          .toList();

      final success =
          await _channel.invokeMethod<bool>('sendTemplatesToWatch', {
            'templates': templatesJson,
          }) ??
          false;

      if (success) {
        state = state.copyWith(
          templatesCount: templates.length,
          lastSyncTime: DateTime.now(),
        );

        if (kDebugMode) {
          _watchLog(
            'Successfully sent ${templates.length} templates to watch',
          );
        }
      }

      return success;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to send templates to watch: $e');
      }
      state = state.copyWith(
        errorMessage: 'Failed to send templates: ${e.message}',
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        _watchLog('Error sending templates to watch: $e');
      }
      state = state.copyWith(errorMessage: 'Error sending templates: $e');
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
        _watchLog('Failed to open watch settings: $e');
      }
    }
  }

  /// Request a full workout snapshot from Watch for crash recovery.
  /// Returns true if the request was sent (Watch is reachable).
  /// The actual snapshot arrives asynchronously via [onFullWorkoutSnapshotFromWatch].
  Future<bool> requestWatchWorkoutSnapshot() async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>(
        'requestWatchWorkoutSnapshot',
      );
      _watchLog('⌚ [FLUTTER] Snapshot request result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      _watchLog('⌚ [FLUTTER] Snapshot request failed: $e');
      return false;
    } catch (e) {
      _watchLog('⌚ [FLUTTER] Snapshot request error: $e');
      return false;
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
  /// - setsCompletedInExercise: Sets completed in CURRENT exercise (for edit UI)
  /// - lastCompletedReps: Actual reps of last completed set (for edit UI)
  /// - allSets: List of all sets in exercise with weight/reps for navigation
  /// - isSuperset: Whether current exercise is part of a superset
  /// - supersetName: Name of the superset (if isSuperset is true)
  /// - supersetExercises: List of exercise names in the superset
  /// - currentExerciseInSuperset: 1-indexed position in superset
  /// - totalExercisesInSuperset: Total exercises in superset
  /// - supersetRound: Current round (1-indexed)
  /// - totalSupersetRounds: Total rounds to complete
  Future<void> notifyWorkoutStarted({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    double? targetWeight,
    int? targetReps,
    int? minReps, // ⌚ Rep range support
    int? maxReps, // ⌚ Rep range support
    int setsCompleted = 0,
    int setsCompletedInExercise = 0, // ✅ NEW
    int? lastCompletedReps, // ✅ NEW
    bool rpeTrackingEnabled = false,
    String effortScale = 'rpe',
    String locale = 'en',
    String? formCues,
    String? tut, // ⌚ BUG FIX #3: Time Under Tension
    List<Map<String, dynamic>>? allSets, // ✅ FIX: All sets for navigation
    // 🔄 Exercise navigation support
    List<String>? exerciseNames, // All exercise names in workout
    int currentExerciseIndex = 0, // 0-indexed current exercise position
    // 🔥 SUPERSET SUPPORT
    bool isSuperset = false,
    String? supersetName,
    List<String>? supersetExercises,
    int currentExerciseInSuperset = 0,
    int totalExercisesInSuperset = 0,
    int supersetRound = 0,
    int totalSupersetRounds = 0,
    // 🔥 DROPSET SUPPORT
    bool isDropset = false,
    List<Map<String, dynamic>>? dropsetStages,
    int currentDropsetStage = 0,
    int totalDropsetStages = 0,
    // 🔥 REST-PAUSE SUPPORT
    bool isRestPause = false,
    double? restPauseWeight,
    int? restPauseTargetReps,
    List<Map<String, dynamic>>? restPauseSets,
    int currentRestPauseSet = 0,
    int totalRestPauseSets = 0,
  }) async {
    // 🔍 DEBUG: Log entry and state check (using debugPrint for release mode visibility)
    _watchLog('⌚ [PROVIDER DEBUG] notifyWorkoutStarted called');
    _watchLog('⌚ [PROVIDER DEBUG] Platform.isIOS: ${Platform.isIOS}');
    _watchLog('⌚ [PROVIDER DEBUG] state.isConnected: ${state.isConnected}');
    _watchLog('⌚ [PROVIDER DEBUG] state.state: ${state.state}');
    _watchLog(
      '⌚ [PROVIDER DEBUG] rpeTrackingEnabled: $rpeTrackingEnabled, effortScale: $effortScale, locale: $locale',
    );

    if (!Platform.isIOS) {
      _watchLog('⌚ [PROVIDER DEBUG] ❌ Not iOS, returning');
      return;
    }

    if (!state.isConnected) {
      _watchLog(
        '⌚ [PROVIDER DEBUG] ⚠️ Watch not connected, but attempting anyway...',
      );
      // DON'T return - try anyway, native side has fallback
    }

    try {
      _watchLog(
        '⌚ [PROVIDER DEBUG] Calling _channel.invokeMethod(notifyWorkoutStarted)',
      );
      await _channel.invokeMethod('notifyWorkoutStarted', {
        'exerciseName': exerciseName,
        'currentSet': currentSet,
        'totalSets': totalSets,
        'targetWeight': targetWeight ?? 0.0,
        'targetReps': targetReps ?? 0,
        if (minReps != null) 'minReps': minReps, // ⌚ Rep range support
        if (maxReps != null) 'maxReps': maxReps, // ⌚ Rep range support
        'setsCompleted': setsCompleted,
        'setsCompletedInExercise': setsCompletedInExercise, // ✅ NEW
        'lastCompletedReps': lastCompletedReps ?? 0, // ✅ NEW
        'rpeTrackingEnabled': rpeTrackingEnabled,
        'effortScale': effortScale,
        'locale': locale,
        'formCues': formCues ?? '',
        'tut': tut ?? '', // ⌚ BUG FIX #3: Time Under Tension
        'allSets': allSets ?? [], // ✅ FIX: All sets for Watch navigation
        // 🔄 Exercise navigation support
        'exerciseNames': exerciseNames ?? [],
        'currentExerciseIndex': currentExerciseIndex,
        // 🔥 SUPERSET SUPPORT
        'isSuperset': isSuperset,
        'supersetName': supersetName ?? '',
        'supersetExercises': supersetExercises ?? [],
        'currentExerciseInSuperset': currentExerciseInSuperset,
        'totalExercisesInSuperset': totalExercisesInSuperset,
        'supersetRound': supersetRound,
        'totalSupersetRounds': totalSupersetRounds,
        // 🔥 DROPSET SUPPORT
        'isDropset': isDropset,
        'dropsetStages': dropsetStages ?? [],
        'currentDropsetStage': currentDropsetStage,
        'totalDropsetStages': totalDropsetStages,
        // 🔥 REST-PAUSE SUPPORT
        'isRestPause': isRestPause,
        'restPauseWeight': restPauseWeight ?? 0.0,
        'restPauseTargetReps': restPauseTargetReps ?? 0,
        'restPauseSets': restPauseSets ?? [],
        'currentRestPauseSet': currentRestPauseSet,
        'totalRestPauseSets': totalRestPauseSets,
      });

      _watchLog('⌚ [PROVIDER DEBUG] ✅ invokeMethod completed successfully');
      if (isSuperset) {
        _watchLog(
          '🏋️ Notified Watch: SUPERSET started - $supersetName (Ex $currentExerciseInSuperset/$totalExercisesInSuperset, Round $supersetRound/$totalSupersetRounds)',
        );
      } else {
        _watchLog(
          '🏋️ Notified Watch: workout started - $exerciseName (RPE: $rpeTrackingEnabled, locale: $locale, TUT: ${tut ?? "none"}, allSets: ${allSets?.length ?? 0})',
        );
      }
    } on PlatformException catch (e) {
      _watchLog('⌚ [PROVIDER DEBUG] ❌ PlatformException: $e');
    }
  }

  /// Notify Watch that workout has ended
  Future<void> notifyWorkoutEnded() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('notifyWorkoutEnded');

      if (kDebugMode) {
        _watchLog('🏁 Notified Watch: workout ended');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to notify Watch of workout end: $e');
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
  /// - setsCompletedInExercise: Sets completed in CURRENT exercise (for edit UI)
  /// - lastCompletedReps: Actual reps of last completed set (for edit UI)
  /// - allSets: List of all sets in exercise with weight/reps for navigation
  /// - isSuperset: Whether current exercise is part of a superset
  /// - supersetName: Name of the superset (if isSuperset is true)
  /// - supersetExercises: List of exercise names in the superset
  /// - currentExerciseInSuperset: 1-indexed position in superset
  /// - totalExercisesInSuperset: Total exercises in superset
  /// - supersetRound: Current round (1-indexed)
  /// - totalSupersetRounds: Total rounds to complete
  Future<void> sendWorkoutUpdate({
    required String exerciseName,
    required int currentSet,
    required int totalSets,
    double? targetWeight,
    int? targetReps,
    int? minReps, // ⌚ Rep range support
    int? maxReps, // ⌚ Rep range support
    int setsCompleted = 0,
    int setsCompletedInExercise = 0, // ✅ NEW
    int? lastCompletedReps, // ✅ NEW
    bool rpeTrackingEnabled = false,
    String effortScale = 'rpe',
    String locale = 'en',
    String? formCues,
    String? tut, // ⌚ BUG FIX #3: Time Under Tension
    List<Map<String, dynamic>>? allSets, // ✅ FIX: All sets for navigation
    // 🔄 Exercise navigation support
    List<String>? exerciseNames, // All exercise names in workout
    int currentExerciseIndex = 0, // 0-indexed current exercise position
    // ✅ FIX: Rest time for optimistic timer on Watch
    int? restTime, // Rest time in seconds for current exercise
    // 🔥 SUPERSET SUPPORT
    bool isSuperset = false,
    String? supersetName,
    List<String>? supersetExercises,
    int currentExerciseInSuperset = 0,
    int totalExercisesInSuperset = 0,
    int supersetRound = 0,
    int totalSupersetRounds = 0,
    // 🔥 DROPSET SUPPORT
    bool isDropset = false,
    List<Map<String, dynamic>>? dropsetStages,
    int currentDropsetStage = 0,
    int totalDropsetStages = 0,
    // 🔥 REST-PAUSE SUPPORT
    bool isRestPause = false,
    double? restPauseWeight,
    int? restPauseTargetReps,
    List<Map<String, dynamic>>? restPauseSets,
    int currentRestPauseSet = 0,
    int totalRestPauseSets = 0,
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
        if (minReps != null) 'minReps': minReps, // ⌚ Rep range support
        if (maxReps != null) 'maxReps': maxReps, // ⌚ Rep range support
        'setsCompleted': setsCompleted,
        'setsCompletedInExercise': setsCompletedInExercise, // ✅ NEW
        'lastCompletedReps': lastCompletedReps ?? 0, // ✅ NEW
        'rpeTrackingEnabled': rpeTrackingEnabled,
        'effortScale': effortScale,
        'locale': locale,
        'formCues': formCues ?? '',
        'tut': tut ?? '', // ⌚ BUG FIX #3: Time Under Tension
        'allSets': allSets ?? [], // ✅ FIX: All sets for Watch navigation
        // 🔄 Exercise navigation support
        'exerciseNames': exerciseNames ?? [],
        'currentExerciseIndex': currentExerciseIndex,
        // ✅ FIX: Rest time for optimistic timer on Watch
        'restTime': restTime ?? 0,
        // 🔥 SUPERSET SUPPORT
        'isSuperset': isSuperset,
        'supersetName': supersetName ?? '',
        'supersetExercises': supersetExercises ?? [],
        'currentExerciseInSuperset': currentExerciseInSuperset,
        'totalExercisesInSuperset': totalExercisesInSuperset,
        'supersetRound': supersetRound,
        'totalSupersetRounds': totalSupersetRounds,
        // 🔥 DROPSET SUPPORT
        'isDropset': isDropset,
        'dropsetStages': dropsetStages ?? [],
        'currentDropsetStage': currentDropsetStage,
        'totalDropsetStages': totalDropsetStages,
        // 🔥 REST-PAUSE SUPPORT
        'isRestPause': isRestPause,
        'restPauseWeight': restPauseWeight ?? 0.0,
        'restPauseTargetReps': restPauseTargetReps ?? 0,
        'restPauseSets': restPauseSets ?? [],
        'currentRestPauseSet': currentRestPauseSet,
        'totalRestPauseSets': totalRestPauseSets,
      });
      if (isDropset) {
        _watchLog(
          '⌚ Sent DROPSET update: $exerciseName (Stage $currentDropsetStage/$totalDropsetStages)',
        );
      } else if (isRestPause) {
        _watchLog(
          '⌚ Sent REST-PAUSE update: $exerciseName (Set $currentRestPauseSet/$totalRestPauseSets)',
        );
      } else if (isSuperset) {
        _watchLog(
          '⌚ Sent SUPERSET update: $supersetName - $exerciseName (Ex $currentExerciseInSuperset/$totalExercisesInSuperset, Round $supersetRound/$totalSupersetRounds)',
        );
      } else {
        _watchLog(
          '⌚ Sent workout update: $exerciseName Set $currentSet/$totalSets (TUT: ${tut ?? "none"}, allSets: ${allSets?.length ?? 0}, exercises: ${exerciseNames?.length ?? 0})',
        );
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to send workout update to Watch: $e');
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

      _watchLog('⏱️ Notified Watch: rest timer ${durationSeconds}s');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to notify Watch of rest timer: $e');
      }
    }
  }

  /// Notify Watch that rest was skipped
  Future<void> sendRestTimerSkipped() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('sendRestTimerSkipped');

      if (kDebugMode) {
        _watchLog('⏭️ Notified Watch: rest skipped');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to notify Watch of rest skip: $e');
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
        _watchLog(
          '⏸️ Notified Watch: rest paused (${remainingSeconds}s remaining)',
        );
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to notify Watch of rest pause: $e');
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
        _watchLog(
          '▶️ Notified Watch: rest resumed (${remainingSeconds}s remaining)',
        );
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to notify Watch of rest resume: $e');
      }
    }
  }

  /// Notify Watch that rest timer was extended (+30s from LA or app)
  Future<void> sendRestTimerExtended(int addedSeconds, int newDuration) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('sendRestTimerExtended', {
        'addedSeconds': addedSeconds,
        'newDuration': newDuration,
      });

      _watchLog(
        '⏱️ Notified Watch: rest timer extended +${addedSeconds}s (total: ${newDuration}s)',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to notify Watch of rest timer extension: $e');
      }
    }
  }

  // MARK: - Pending Commands (Background Safety Fix)

  /// Check for pending Watch commands that were saved while app was in background
  /// Returns list of pending commands to process
  /// ✅ FIX: Prevents data loss when Watch sends endWorkout while iPhone app is in background
  Future<List<Map<String, dynamic>>> checkPendingWatchCommands() async {
    if (!Platform.isIOS) return [];

    try {
      final result = await _channel.invokeMethod('checkPendingWatchCommands');
      if (result == null) return [];

      // Convert to List<Map<String, dynamic>>
      final pending = (result as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (pending.isNotEmpty) {
        _watchLog(
          '⌚ [FLUTTER] 📥 Found ${pending.length} pending Watch commands',
        );
      }

      return pending;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to check pending Watch commands: $e');
      }
      return [];
    }
  }

  /// Clear pending Watch commands after processing
  Future<void> clearPendingWatchCommands() async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod('clearPendingWatchCommands');
      _watchLog('⌚ [FLUTTER] 🧹 Cleared pending Watch commands');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        _watchLog('Failed to clear pending Watch commands: $e');
      }
    }
  }

  /// Process pending Watch commands (called on app resume)
  /// Returns true if any commands were processed
  Future<bool> processPendingWatchCommands() async {
    final pending = await checkPendingWatchCommands();
    if (pending.isEmpty) return false;

    var processed = false;

    for (final command in pending) {
      final type = command['type'] as String?;
      _watchLog('⌚ [FLUTTER] 🔄 Processing pending command: $type');

      switch (type) {
        case 'endWorkout':
          final save = command['save'] as bool? ?? true;
          _watchLog('⌚ [FLUTTER] 🏁 Pending endWorkout (save: $save)');
          // Call the registered callback
          onEndWorkoutFromWatch?.call(save: save);
          processed = true;
          break;

        default:
          _watchLog('⌚ [FLUTTER] ⚠️ Unknown pending command type: $type');
      }
    }

    // Clear pending commands after processing
    await clearPendingWatchCommands();

    return processed;
  }

  // Note: Riverpod 3.0 no longer uses dispose() in Notifier classes
  // Cleanup is handled automatically by Riverpod when the provider is disposed
}

/// Convenience getter for watch reachability
final isWatchReachableProvider = Provider<bool>((ref) {
  return ref.watch(watchConnectivityProvider).isConnected;
});

/// Convenience getter for watch app installed
final isWatchAppInstalledProvider = Provider<bool>((ref) {
  return ref.watch(watchConnectivityProvider).isAppInstalled;
});
