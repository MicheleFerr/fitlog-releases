import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state_notifier.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/performance_logger.dart';

// Main state provider with auto-dispose
final homeStateProvider = StateNotifierProvider.autoDispose<
    HomeStateNotifier,
    HomeState>((ref) {
  final logger = ref.watch(performanceLoggerProvider);

  // Keep alive for 30 seconds after last listener disconnects
  ref.keepAlive();
  Timer? timer;

  ref.onCancel(() {
    timer = Timer(const Duration(seconds: 30), () {
      ref.invalidateSelf();
    });
  });

  ref.onResume(() {
    timer?.cancel();
  });

  ref.onDispose(() {
    timer?.cancel();
  });

  return HomeStateNotifier(
    ref: ref,
    logger: logger,
  );
});

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
