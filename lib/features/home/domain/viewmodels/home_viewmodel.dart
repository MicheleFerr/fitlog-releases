/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/viewmodels
/// 🎯 Feature: home
/// 🔧 Type: viewmodel interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Abstract interface for Homepage ViewModel following MVVM pattern.
/// Provides data streams for homepage widgets with performance optimization.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/data/viewmodels/home_viewmodel_impl.dart';

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
  const WorkoutBannerData({
    required this.hasActiveWorkout,
    this.workoutName,
    this.progress,
  });

  final bool hasActiveWorkout;
  final String? workoutName;
  final double? progress;
}

class AICoachData {
  const AICoachData({
    required this.message,
    this.suggestion,
  });

  final String message;
  final String? suggestion;
}

class StreakData {
  const StreakData({
    required this.currentStreak,
    required this.bestStreak,
  });

  final int currentStreak;
  final int bestStreak;
}

// Provider
final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModelImpl(ref);
});
