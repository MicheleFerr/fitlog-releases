/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/viewmodels
/// 🎯 Feature: home
/// 🔧 Type: viewmodel implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Concrete implementation of HomeViewModel with performance tracking.
/// Loads homepage data in optimized phases (<3s target).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/domain/viewmodels/home_viewmodel.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/performance_logger.dart';

class HomeViewModelImpl implements HomeViewModel {
  HomeViewModelImpl(this._ref)
      : _logger = _ref.read(performanceLoggerProvider);

  final Ref _ref;
  final PerformanceLogger _logger;

  @override
  AsyncValue<String> get greeting => _ref.watch(greetingProvider);

  @override
  AsyncValue<WorkoutBannerData> get workoutBanner =>
      _ref.watch(workoutBannerProvider);

  @override
  AsyncValue<AICoachData> get aiCoachData =>
      _ref.watch(aiCoachProvider);

  @override
  AsyncValue<StreakData> get streakData =>
      _ref.watch(streakProvider);

  @override
  Future<void> loadInitialData() async {
    final stopwatch = Stopwatch()..start();

    // Load critical data first (greeting + active workout)
    await Future.wait([
      _ref.read(greetingProvider.future),
      _ref.read(workoutBannerProvider.future),
    ]);

    final criticalTime = stopwatch.elapsed;
    _logger.logDataFetch('critical_data', criticalTime, 100);

    // Load secondary data
    await Future.wait([
      _ref.read(aiCoachProvider.future),
      _ref.read(streakProvider.future),
    ]);

    final secondaryTime = stopwatch.elapsed - criticalTime;
    _logger.logDataFetch('secondary_data', secondaryTime, 150);
  }

  @override
  Future<void> refreshData() async {
    _ref.invalidate(greetingProvider);
    _ref.invalidate(workoutBannerProvider);
    _ref.invalidate(aiCoachProvider);
    _ref.invalidate(streakProvider);

    await loadInitialData();
  }

  @override
  void dispose() {
    // No resources to clean up - data providers are managed by Riverpod
  }
}

// Placeholder providers - will be implemented next
final greetingProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 'Good morning';
});

final workoutBannerProvider = FutureProvider<WorkoutBannerData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return const WorkoutBannerData(hasActiveWorkout: false);
});

final aiCoachProvider = FutureProvider<AICoachData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  return const AICoachData(message: 'Ready for today?');
});

final streakProvider = FutureProvider<StreakData>((ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return const StreakData(currentStreak: 5, bestStreak: 10);
});
