/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/health_sync/presentation/providers
/// Feature: health_sync
/// Type: provider
///
/// Activity Rings Provider - Fetches Apple-style activity ring data
///
/// **iOS**: Uses native HKActivitySummaryQuery via method channel for REAL goals
/// **Android**: Uses health package with default goals
///
/// **Data Sources**:
/// - Move (Red): ACTIVE_ENERGY_BURNED - active calories
/// - Exercise (Green): EXERCISE_TIME - minutes of exercise
/// - Stand (Blue): APPLE_STAND_HOUR - stand hours (iOS only)
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:health/health.dart';

/// Activity ring data for a single day
class ActivityRingsData {
  const ActivityRingsData({
    required this.moveCalories,
    required this.moveGoal,
    required this.exerciseMinutes,
    required this.exerciseGoal,
    required this.standHours,
    required this.standGoal,
    required this.lastUpdated,
    this.errorMessage,
  });

  /// Create empty/loading state
  const ActivityRingsData.empty()
    : moveCalories = 0,
      moveGoal = 500,
      exerciseMinutes = 0,
      exerciseGoal = 30,
      standHours = 0,
      standGoal = 12,
      lastUpdated = null,
      errorMessage = null;

  /// Active calories burned today (Move ring)
  final double moveCalories;

  /// Move goal in calories (user configurable)
  final double moveGoal;

  /// Exercise minutes today (Exercise ring)
  final int exerciseMinutes;

  /// Exercise goal in minutes (default 30)
  final int exerciseGoal;

  /// Stand hours today (Stand ring - iOS only)
  final int standHours;

  /// Stand goal in hours (default 12)
  final int standGoal;

  /// Last data fetch timestamp
  final DateTime? lastUpdated;

  /// Error message if fetch failed
  final String? errorMessage;

  /// Progress percentages (0.0 - 1.0+, can exceed 1.0 if goal exceeded)
  double get moveProgress => moveGoal > 0 ? moveCalories / moveGoal : 0;
  double get exerciseProgress =>
      exerciseGoal > 0 ? exerciseMinutes / exerciseGoal : 0;
  double get standProgress => standGoal > 0 ? standHours / standGoal : 0;

  /// Check if data is loaded
  bool get hasData => lastUpdated != null;

  /// Check if there's an error
  bool get hasError => errorMessage != null;

  /// Check if all goals are met
  bool get allGoalsMet =>
      moveProgress >= 1.0 && exerciseProgress >= 1.0 && standProgress >= 1.0;

  ActivityRingsData copyWith({
    double? moveCalories,
    double? moveGoal,
    int? exerciseMinutes,
    int? exerciseGoal,
    int? standHours,
    int? standGoal,
    DateTime? lastUpdated,
    String? errorMessage,
  }) {
    return ActivityRingsData(
      moveCalories: moveCalories ?? this.moveCalories,
      moveGoal: moveGoal ?? this.moveGoal,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      exerciseGoal: exerciseGoal ?? this.exerciseGoal,
      standHours: standHours ?? this.standHours,
      standGoal: standGoal ?? this.standGoal,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for Activity Rings data
final activityRingsProvider =
    NotifierProvider<ActivityRingsNotifier, ActivityRingsData>(
      ActivityRingsNotifier.new,
    );

/// Notifier that manages Activity Rings state
class ActivityRingsNotifier extends Notifier<ActivityRingsData> {
  @override
  ActivityRingsData build() {
    return const ActivityRingsData.empty();
  }

  // Native method channel for iOS (HKActivitySummary with REAL goals)
  static const _iosChannel = MethodChannel(PlatformChannels.healthkitActivity);

  // Health package for Android fallback
  final Health _health = Health();
  bool _isHealthConfigured = false;

  /// Fetch today's activity data
  Future<void> fetchActivityData() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      state = state.copyWith(
        errorMessage: 'Platform not supported',
        lastUpdated: DateTime.now(),
      );
      return;
    }

    try {
      if (Platform.isIOS) {
        await _fetchFromNativeIOS();
      } else {
        await _fetchFromHealthPackage();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching activity data: $e');
      }
      state = state.copyWith(
        errorMessage: 'Failed to fetch activity data: $e',
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Fetch using native iOS HKActivitySummaryQuery (includes REAL goals)
  Future<void> _fetchFromNativeIOS() async {
    try {
      // Request permission first
      final permissionGranted = await _iosChannel.invokeMethod<bool>(
        'requestActivitySummaryPermission',
      );

      if (permissionGranted != true) {
        state = state.copyWith(
          errorMessage: 'Health permissions not granted',
          lastUpdated: DateTime.now(),
        );
        return;
      }

      // Get activity summary with real goals
      final result = await _iosChannel.invokeMethod<Map<Object?, Object?>>(
        'getActivitySummary',
      );

      if (result == null) {
        state = state.copyWith(
          errorMessage: 'No activity data returned',
          lastUpdated: DateTime.now(),
        );
        return;
      }

      // Parse native response
      final hasData = result['hasData'] as bool? ?? false;
      final moveCalories = (result['moveCalories'] as num?)?.toDouble() ?? 0.0;
      final moveGoal = (result['moveGoal'] as num?)?.toDouble() ?? 500.0;
      final exerciseMinutes = (result['exerciseMinutes'] as num?)?.toInt() ?? 0;
      final exerciseGoal = (result['exerciseGoal'] as num?)?.toInt() ?? 30;
      final standHours = (result['standHours'] as num?)?.toInt() ?? 0;
      final standGoal = (result['standGoal'] as num?)?.toInt() ?? 12;

      state = ActivityRingsData(
        moveCalories: moveCalories,
        moveGoal: moveGoal,
        exerciseMinutes: exerciseMinutes,
        exerciseGoal: exerciseGoal,
        standHours: standHours,
        standGoal: standGoal,
        lastUpdated: DateTime.now(),
      );

      if (kDebugMode) {
        debugPrint('Activity Rings (iOS Native):');
        debugPrint(
          '  Move: ${moveCalories.toInt()} / ${moveGoal.toInt()} kcal',
        );
        debugPrint('  Exercise: $exerciseMinutes / $exerciseGoal min');
        debugPrint('  Stand: $standHours / $standGoal hrs');
        debugPrint('  Has Data: $hasData');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('iOS native channel error: $e');
      }
      // Fallback to health package if native fails
      await _fetchFromHealthPackage();
    }
  }

  /// Fallback: Fetch using health package (Android or iOS fallback)
  Future<void> _fetchFromHealthPackage() async {
    try {
      // Configure health package
      if (!_isHealthConfigured) {
        await _health.configure();
        _isHealthConfigured = true;
      }

      // Request permissions
      final types = Platform.isIOS
          ? [
              HealthDataType.ACTIVE_ENERGY_BURNED,
              HealthDataType.EXERCISE_TIME,
              HealthDataType.APPLE_STAND_HOUR,
            ]
          : [HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.EXERCISE_TIME];

      final permissions = types.map((t) => HealthDataAccess.READ).toList();

      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (!granted) {
        state = state.copyWith(
          errorMessage: 'Health permissions not granted',
          lastUpdated: DateTime.now(),
        );
        return;
      }

      // Fetch data for today
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Fetch active energy burned (Move)
      double moveCalories = 0;
      try {
        final energyData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
          startTime: startOfDay,
          endTime: now,
        );

        for (final point in energyData) {
          final numericValue = point.value as NumericHealthValue;
          moveCalories += numericValue.numericValue.toDouble();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching active energy: $e');
        }
      }

      // Fetch exercise time (Exercise)
      int exerciseMinutes = 0;
      try {
        final exerciseData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.EXERCISE_TIME],
          startTime: startOfDay,
          endTime: now,
        );

        for (final point in exerciseData) {
          final numericValue = point.value as NumericHealthValue;
          exerciseMinutes += numericValue.numericValue.toInt();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching exercise time: $e');
        }
      }

      // Fetch stand hours (iOS only)
      int standHours = 0;
      if (Platform.isIOS) {
        try {
          final standData = await _health.getHealthDataFromTypes(
            types: [HealthDataType.APPLE_STAND_HOUR],
            startTime: startOfDay,
            endTime: now,
          );

          // Each data point represents 1 stand hour
          standHours = standData.length;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error fetching stand hours: $e');
          }
        }
      }

      // Use default goals for health package (no way to read real goals)
      state = ActivityRingsData(
        moveCalories: moveCalories,
        moveGoal: state.moveGoal, // Keep existing or default
        exerciseMinutes: exerciseMinutes,
        exerciseGoal: state.exerciseGoal,
        standHours: standHours,
        standGoal: state.standGoal,
        lastUpdated: DateTime.now(),
      );

      if (kDebugMode) {
        debugPrint('Activity Rings (Health Package):');
        debugPrint(
          '  Move: ${moveCalories.toInt()} / ${state.moveGoal.toInt()} kcal',
        );
        debugPrint('  Exercise: $exerciseMinutes / ${state.exerciseGoal} min');
        debugPrint('  Stand: $standHours / ${state.standGoal} hrs');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching from health package: $e');
      }
      state = state.copyWith(
        errorMessage: 'Failed to fetch activity data: $e',
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Update the Move goal (calories) - for manual override
  void setMoveGoal(double calories) {
    state = state.copyWith(moveGoal: calories);
  }

  /// Update the Exercise goal (minutes) - for manual override
  void setExerciseGoal(int minutes) {
    state = state.copyWith(exerciseGoal: minutes);
  }

  /// Update the Stand goal (hours) - for manual override
  void setStandGoal(int hours) {
    state = state.copyWith(standGoal: hours);
  }
}
