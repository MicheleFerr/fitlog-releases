import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class HomeViewModel {
  AsyncValue<String> get greeting;
  AsyncValue<WorkoutBannerData> get workoutBanner;
  AsyncValue<AICoachData> get aiCoachData;
  AsyncValue<StreakData> get streakData;

  Future<void> loadInitialData();
  Future<void> refreshData();
  void dispose();
}

class WorkoutBannerData {
  final bool hasActiveWorkout;
  final String? workoutName;
  final double? progress;

  const WorkoutBannerData({
    required this.hasActiveWorkout,
    this.workoutName,
    this.progress,
  });
}

class AICoachData {
  final String message;
  final String? suggestion;

  const AICoachData({
    required this.message,
    this.suggestion,
  });
}

class StreakData {
  final int currentStreak;
  final int bestStreak;

  const StreakData({
    required this.currentStreak,
    required this.bestStreak,
  });
}

// Provider
final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  throw UnimplementedError('Implement in data layer');
});
