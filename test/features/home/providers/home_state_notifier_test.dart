import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_providers.dart';

void main() {
  test('HomeStateNotifier loads data in phases', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(homeStateProvider.notifier);

    expect(notifier.state.loadingPhase, equals(LoadingPhase.initial));

    await notifier.loadInitialData();

    expect(notifier.state.loadingPhase, equals(LoadingPhase.complete));
    expect(notifier.state.greeting, isNotEmpty);
  });

  test('HomeStateNotifier transitions through loading phases correctly', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(homeStateProvider.notifier);
    final phases = <LoadingPhase>[];

    // Listen to state changes
    container.listen<HomeState>(
      homeStateProvider,
      (previous, next) {
        phases.add(next.loadingPhase);
      },
      fireImmediately: true,
    );

    await notifier.loadInitialData();

    // Verify phased loading transitions
    expect(phases, contains(LoadingPhase.initial));
    expect(phases, contains(LoadingPhase.loadingCritical));
    expect(phases, contains(LoadingPhase.loadingSecondary));
    expect(phases.last, equals(LoadingPhase.complete));
  });

  test('HomeStateNotifier loads greeting correctly', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(homeStateProvider.notifier);

    await notifier.loadInitialData();

    expect(notifier.state.greeting, isNotEmpty);
    expect(notifier.state.greeting, contains(RegExp(r'Good (morning|afternoon|evening)')));
  });

  test('Micro-providers provide granular access to state sections', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Verify all micro-providers are accessible
    expect(() => container.read(greetingSectionProvider), returnsNormally);
    expect(() => container.read(workoutSectionProvider), returnsNormally);
    expect(() => container.read(aiCoachSectionProvider), returnsNormally);
    expect(() => container.read(streakSectionProvider), returnsNormally);
    expect(() => container.read(loadingPhaseProvider), returnsNormally);
  });
}
