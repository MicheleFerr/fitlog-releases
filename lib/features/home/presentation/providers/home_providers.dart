import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state_notifier.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/performance_logger.dart';

// Main state provider with auto-dispose
final homeStateProvider = AutoDisposeNotifierProvider<
    HomeStateNotifier,
    HomeState>(HomeStateNotifier.new);

// Micro-providers for granular rebuilds
final greetingSectionProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(homeStateProvider.select((state) => state.greeting));
});

final workoutSectionProvider = Provider.autoDispose<WorkoutSection>((ref) {
  return ref.watch(homeStateProvider.select((state) => state.workoutSection));
});

final aiCoachSectionProvider = Provider.autoDispose<AICoachSection>((ref) {
  return ref.watch(homeStateProvider.select((state) => state.aiCoachSection));
});

final streakSectionProvider = Provider.autoDispose<StreakSection>((ref) {
  return ref.watch(homeStateProvider.select((state) => state.streakSection));
});

final loadingPhaseProvider = Provider.autoDispose<LoadingPhase>((ref) {
  return ref.watch(homeStateProvider.select((state) => state.loadingPhase));
});
