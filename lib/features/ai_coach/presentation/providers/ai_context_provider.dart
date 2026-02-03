/// AI Context Provider
///
/// Aggregates user analytics data for AI Coach context.
/// Fetches from existing analytics, streak, recovery providers.
///
/// **Layer**: Presentation - Provider
/// **Feature**: AI Coach
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_context_provider.g.dart';

/// AI context provider - aggregates user data
@riverpod
Future<AIContext> aiContext(Ref ref) async {
  // TODO: Wire actual providers in post-MVP
  // This is a placeholder implementation
  //
  // Real implementation will aggregate:
  // - final streak = ref.watch(streakProvider).value?.currentStreak ?? 0;
  // - final lastWorkout = await ref.watch(recentWorkoutsProvider(limit: 1).future);
  // - final top5OneRM = await ref.watch(top5OneRMProvider.future);
  // - final recovery = ref.watch(recoveryStatusProvider).value;
  // - final tier = ref.watch(userTierProvider);

  return const AIContext(
    currentStreak: 0,
    lastWorkout: null,
    top5OneRM: {},
    recoveryStatus: RecoveryStatus.green,
    userTier: 'free',
  );
}
