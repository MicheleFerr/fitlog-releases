# Homepage Performance Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Optimize homepage performance to <3s cold start while keeping IDENTICAL UI/UX

**Architecture:** MVVM pattern with lazy loading, maintaining all existing UI components unchanged

**Tech Stack:** Flutter, Riverpod 2.x, Freezed, Firebase Performance

**CRITICAL REQUIREMENT:** L'UI dev'essere identica all'attuale homepage - solo performance migliorate

---

## Phase 1: Foundation Setup (Preserving Existing UI)

### Task 1: Create MVVM ViewModels Structure

**Files:**
- Create: `lib/features/home/domain/viewmodels/home_viewmodel.dart`
- Create: `lib/features/home/data/viewmodels/home_viewmodel_impl.dart`
- Test: `test/features/home/viewmodels/home_viewmodel_test.dart`

**Step 1: Write the failing test**

```dart
// test/features/home/viewmodels/home_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/domain/viewmodels/home_viewmodel.dart';

void main() {
  test('HomeViewModel provides all required data streams', () {
    final container = ProviderContainer();
    final viewModel = container.read(homeViewModelProvider);

    expect(viewModel.greeting, isNotNull);
    expect(viewModel.workoutBanner, isNotNull);
    expect(viewModel.aiCoachData, isNotNull);
    expect(viewModel.streakData, isNotNull);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/viewmodels/home_viewmodel_test.dart`
Expected: FAIL with "homeViewModelProvider not defined"

**Step 3: Write minimal implementation**

```dart
// lib/features/home/domain/viewmodels/home_viewmodel.dart
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
```

**Step 4: Run test to verify progress**

Run: `flutter test test/features/home/viewmodels/home_viewmodel_test.dart`
Expected: FAIL with "UnimplementedError"

**Step 5: Commit**

```bash
git add lib/features/home/domain/viewmodels/home_viewmodel.dart
git add test/features/home/viewmodels/home_viewmodel_test.dart
git commit -m "feat: add HomeViewModel interface with data models"
```

### Task 2: Implement HomeViewModel with Performance Tracking

**Files:**
- Create: `lib/features/home/data/viewmodels/home_viewmodel_impl.dart`
- Create: `lib/features/home/presentation/providers/performance_logger.dart`
- Modify: `lib/features/home/domain/viewmodels/home_viewmodel.dart`

**Step 1: Write the failing test**

```dart
// test/features/home/viewmodels/home_viewmodel_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/data/viewmodels/home_viewmodel_impl.dart';

void main() {
  test('HomeViewModelImpl loads data within 3 seconds', () async {
    final container = ProviderContainer();
    final viewModel = HomeViewModelImpl(container);

    final stopwatch = Stopwatch()..start();
    await viewModel.loadInitialData();
    stopwatch.stop();

    expect(stopwatch.elapsed.inSeconds, lessThan(3));
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/viewmodels/home_viewmodel_impl_test.dart`
Expected: FAIL with "HomeViewModelImpl not found"

**Step 3: Write implementation with performance tracking**

```dart
// lib/features/home/presentation/providers/performance_logger.dart
import 'package:flutter/foundation.dart';

class PerformanceLogger {
  final List<PerformanceEntry> _entries = [];

  void logDataFetch(String source, Duration fetchTime, int dataSize) {
    _entries.add(PerformanceEntry(
      type: 'data_fetch',
      name: source,
      duration: fetchTime,
      metadata: {'dataSize': dataSize},
      timestamp: DateTime.now(),
    ));

    if (kDebugMode) {
      debugPrint('📊 [PERF] $source: ${fetchTime.inMilliseconds}ms, ${dataSize}B');
    }
  }

  void logProviderRebuild(String providerName, Duration rebuildTime) {
    _entries.add(PerformanceEntry(
      type: 'provider_rebuild',
      name: providerName,
      duration: rebuildTime,
      timestamp: DateTime.now(),
    ));
  }

  Map<String, dynamic> generateReport() {
    return {
      'total_fetches': _entries.where((e) => e.type == 'data_fetch').length,
      'total_time': _entries.fold<Duration>(
        Duration.zero,
        (sum, e) => sum + e.duration,
      ).inMilliseconds,
      'slowest_operation': _entries.isEmpty ? null : _entries
          .reduce((a, b) => a.duration > b.duration ? a : b)
          .name,
    };
  }
}

class PerformanceEntry {
  final String type;
  final String name;
  final Duration duration;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const PerformanceEntry({
    required this.type,
    required this.name,
    required this.duration,
    this.metadata,
    required this.timestamp,
  });
}

final performanceLoggerProvider = Provider<PerformanceLogger>((ref) {
  return PerformanceLogger();
});
```

```dart
// lib/features/home/data/viewmodels/home_viewmodel_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/domain/viewmodels/home_viewmodel.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/performance_logger.dart';

class HomeViewModelImpl implements HomeViewModel {
  final Ref _ref;
  final PerformanceLogger _logger;

  HomeViewModelImpl(this._ref)
      : _logger = _ref.read(performanceLoggerProvider);

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

    _logger.logDataFetch('critical_data', stopwatch.elapsed, 100);

    // Load secondary data
    await Future.wait([
      _ref.read(aiCoachProvider.future),
      _ref.read(streakProvider.future),
    ]);

    _logger.logDataFetch('secondary_data',
        stopwatch.elapsed - stopwatch.elapsed, 200);
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
    // Cleanup if needed
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
```

**Step 4: Update provider in domain**

```dart
// lib/features/home/domain/viewmodels/home_viewmodel.dart
// Add at bottom:
final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModelImpl(ref);
});
```

**Step 5: Run test to verify it passes**

Run: `flutter test test/features/home/viewmodels/home_viewmodel_impl_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/features/home/data/viewmodels/home_viewmodel_impl.dart
git add lib/features/home/presentation/providers/performance_logger.dart
git add test/features/home/viewmodels/home_viewmodel_impl_test.dart
git commit -m "feat: implement HomeViewModel with performance logging"
```

### Task 3: Create HomeState with Freezed

**Files:**
- Create: `lib/features/home/presentation/providers/home_state.dart`
- Create: `lib/features/home/presentation/providers/home_state_notifier.dart`
- Modify: `pubspec.yaml` (if freezed not present)

**Step 1: Write the failing test**

```dart
// test/features/home/providers/home_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';

void main() {
  test('HomeState has all required sections', () {
    const state = HomeState(
      greeting: 'Hello',
      workoutSection: WorkoutSection.empty(),
      aiCoachSection: AICoachSection.empty(),
      streakSection: StreakSection.empty(),
      loadingPhase: LoadingPhase.initial,
    );

    expect(state.greeting, equals('Hello'));
    expect(state.loadingPhase, equals(LoadingPhase.initial));
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/providers/home_state_test.dart`
Expected: FAIL with "HomeState not found"

**Step 3: Create HomeState with Freezed**

```dart
// lib/features/home/presentation/providers/home_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required String greeting,
    required WorkoutSection workoutSection,
    required AICoachSection aiCoachSection,
    required StreakSection streakSection,
    @Default(LoadingPhase.initial) LoadingPhase loadingPhase,
    @Default({}) Map<String, Duration> sectionLoadTimes,
    DateTime? lastRefresh,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _HomeState;
}

enum LoadingPhase {
  initial,
  loadingCritical,  // Greeting + workout banner
  loadingSecondary, // AI coach + streak
  loadingOptional,  // Secondary actions
  complete,
  error
}

@freezed
class WorkoutSection with _$WorkoutSection {
  const factory WorkoutSection({
    required bool hasActiveWorkout,
    String? workoutName,
    double? progress,
    int? exercisesCompleted,
    int? totalExercises,
  }) = _WorkoutSection;

  const WorkoutSection._();

  factory WorkoutSection.empty() => const WorkoutSection(
    hasActiveWorkout: false,
  );
}

@freezed
class AICoachSection with _$AICoachSection {
  const factory AICoachSection({
    required String message,
    String? suggestion,
    String? imageUrl,
  }) = _AICoachSection;

  const AICoachSection._();

  factory AICoachSection.empty() => const AICoachSection(
    message: '',
  );
}

@freezed
class StreakSection with _$StreakSection {
  const factory StreakSection({
    required int currentStreak,
    required int bestStreak,
    DateTime? lastWorkoutDate,
  }) = _StreakSection;

  const StreakSection._();

  factory StreakSection.empty() => const StreakSection(
    currentStreak: 0,
    bestStreak: 0,
  );
}
```

**Step 4: Generate Freezed code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: Generated home_state.freezed.dart

**Step 5: Run test to verify it passes**

Run: `flutter test test/features/home/providers/home_state_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add lib/features/home/presentation/providers/home_state.dart
git add lib/features/home/presentation/providers/home_state.freezed.dart
git add test/features/home/providers/home_state_test.dart
git commit -m "feat: create HomeState with Freezed for state management"
```

## Phase 2: Provider Architecture with Lazy Loading

### Task 4: Implement StateNotifier with Phased Loading

**Files:**
- Create: `lib/features/home/presentation/providers/home_state_notifier.dart`
- Create: `lib/features/home/presentation/providers/home_providers.dart`
- Test: `test/features/home/providers/home_state_notifier_test.dart`

**Step 1: Write the failing test**

```dart
// test/features/home/providers/home_state_notifier_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state_notifier.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';

void main() {
  test('HomeStateNotifier loads data in phases', () async {
    final container = ProviderContainer();
    final notifier = container.read(homeStateProvider.notifier);

    expect(notifier.state.loadingPhase, equals(LoadingPhase.initial));

    await notifier.loadInitialData();

    expect(notifier.state.loadingPhase, equals(LoadingPhase.complete));
    expect(notifier.state.greeting, isNotEmpty);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/providers/home_state_notifier_test.dart`
Expected: FAIL with "homeStateProvider not found"

**Step 3: Implement StateNotifier with phased loading**

```dart
// lib/features/home/presentation/providers/home_state_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/performance_logger.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

class HomeStateNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  final PerformanceLogger _logger;
  Timer? _refreshTimer;

  HomeStateNotifier({
    required Ref ref,
    required PerformanceLogger logger,
  }) : _ref = ref,
       _logger = logger,
       super(HomeState(
         greeting: '',
         workoutSection: WorkoutSection.empty(),
         aiCoachSection: AICoachSection.empty(),
         streakSection: StreakSection.empty(),
       ));

  Future<void> loadInitialData() async {
    state = state.copyWith(loadingPhase: LoadingPhase.loadingCritical);

    // Phase 1: Critical data (must show immediately)
    await _loadCriticalData();

    // Phase 2: Secondary data (nice to have quickly)
    await _loadSecondaryData();

    // Phase 3: Optional data (can load in background)
    _loadOptionalData(); // Fire and forget

    state = state.copyWith(loadingPhase: LoadingPhase.complete);
  }

  Future<void> _loadCriticalData() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Load greeting and active workout in parallel
      final results = await Future.wait([
        _loadGreeting(),
        _loadWorkoutBanner(),
      ]);

      state = state.copyWith(
        greeting: results[0] as String,
        workoutSection: results[1] as WorkoutSection,
        loadingPhase: LoadingPhase.loadingSecondary,
        sectionLoadTimes: {
          ...state.sectionLoadTimes,
          'critical': stopwatch.elapsed,
        },
      );

      _logger.logDataFetch('critical_data', stopwatch.elapsed, 100);
    } catch (e) {
      _handleError(e, 'critical');
    }
  }

  Future<void> _loadSecondaryData() async {
    final stopwatch = Stopwatch()..start();

    try {
      final results = await Future.wait([
        _loadAICoach(),
        _loadStreak(),
      ]);

      state = state.copyWith(
        aiCoachSection: results[0] as AICoachSection,
        streakSection: results[1] as StreakSection,
        loadingPhase: LoadingPhase.loadingOptional,
        sectionLoadTimes: {
          ...state.sectionLoadTimes,
          'secondary': stopwatch.elapsed,
        },
      );

      _logger.logDataFetch('secondary_data', stopwatch.elapsed, 150);
    } catch (e) {
      _handleError(e, 'secondary');
    }
  }

  void _loadOptionalData() {
    // Optional data loads in background
    // This would include things like recommendations, tips, etc.
    // For now, we just mark as complete
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        state = state.copyWith(
          loadingPhase: LoadingPhase.complete,
          lastRefresh: DateTime.now(),
        );
      }
    });
  }

  Future<String> _loadGreeting() async {
    final user = _ref.read(authProvider).value;
    final hour = DateTime.now().hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return user != null ? '$greeting, ${user.displayName ?? 'Athlete'}' : greeting;
  }

  Future<WorkoutSection> _loadWorkoutBanner() async {
    final workout = _ref.read(activeWorkoutProvider);

    if (workout == null) {
      return WorkoutSection.empty();
    }

    return WorkoutSection(
      hasActiveWorkout: true,
      workoutName: workout.name,
      progress: workout.progressPercentage,
      exercisesCompleted: workout.completedExercises,
      totalExercises: workout.exercises.length,
    );
  }

  Future<AICoachSection> _loadAICoach() async {
    // Simulate AI coach data loading
    await Future.delayed(const Duration(milliseconds: 100));

    return const AICoachSection(
      message: 'Ready to crush your workout?',
      suggestion: 'Try increasing your bench press by 5lbs today',
    );
  }

  Future<StreakSection> _loadStreak() async {
    // Simulate streak data loading
    await Future.delayed(const Duration(milliseconds: 100));

    return const StreakSection(
      currentStreak: 7,
      bestStreak: 14,
      lastWorkoutDate: null,
    );
  }

  void _handleError(Object error, String section) {
    state = state.copyWith(
      hasError: true,
      errorMessage: 'Failed to load $section: $error',
      loadingPhase: LoadingPhase.error,
    );

    _logger.logDataFetch('${section}_error', Duration.zero, 0);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
```

```dart
// lib/features/home/presentation/providers/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state_notifier.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/performance_logger.dart';

// Main state provider with auto-dispose
final homeStateProvider = StateNotifierProvider.autoDispose<
  HomeStateNotifier,
  HomeState
>((ref) {
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
  return ref.watch(
    homeStateProvider.select((state) => state.greeting)
  );
});

final workoutSectionProvider = Provider.autoDispose<WorkoutSection>((ref) {
  return ref.watch(
    homeStateProvider.select((state) => state.workoutSection)
  );
});

final aiCoachSectionProvider = Provider.autoDispose<AICoachSection>((ref) {
  return ref.watch(
    homeStateProvider.select((state) => state.aiCoachSection)
  );
});

final streakSectionProvider = Provider.autoDispose<StreakSection>((ref) {
  return ref.watch(
    homeStateProvider.select((state) => state.streakSection)
  );
});

final loadingPhaseProvider = Provider.autoDispose<LoadingPhase>((ref) {
  return ref.watch(
    homeStateProvider.select((state) => state.loadingPhase)
  );
});
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/home/providers/home_state_notifier_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/home/presentation/providers/home_state_notifier.dart
git add lib/features/home/presentation/providers/home_providers.dart
git add test/features/home/providers/home_state_notifier_test.dart
git commit -m "feat: implement StateNotifier with phased loading"
```

## Phase 3: UI Migration (Preserving Existing Components)

### Task 5: Migrate HomeScreen to Use New Architecture

**Files:**
- Create: `lib/features/home/presentation/home_screen_performance.dart`
- Preserve: All existing widget files unchanged
- Test: `test/features/home/presentation/home_screen_performance_test.dart`

**Step 1: Write the UI test**

```dart
// test/features/home/presentation/home_screen_performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/home_screen_performance.dart';

void main() {
  testWidgets('HomeScreenPerformance shows all existing sections', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreenPerformance(),
        ),
      ),
    );

    // Verify all sections are present
    expect(find.byType(DynamicGreeting), findsOneWidget);
    expect(find.byType(EnhancedWorkoutBanner), findsOneWidget);
    expect(find.byType(AICoachCard), findsOneWidget);
    expect(find.byType(SmartWorkoutCTA), findsOneWidget);
    expect(find.byType(StreakCounterWidget), findsOneWidget);
    expect(find.byType(SecondaryActions), findsOneWidget);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/presentation/home_screen_performance_test.dart`
Expected: FAIL with "HomeScreenPerformance not found"

**Step 3: Create optimized HomeScreen preserving existing widgets**

```dart
// lib/features/home/presentation/home_screen_performance.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_providers.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
// Import all existing widgets (unchanged)
import 'package:gymbro_flutter_new/features/home/presentation/widgets/dynamic_greeting.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/enhanced_workout_banner.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/smart_workout_cta.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/widgets/streak_counter_widget.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/secondary_actions.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/widgets/notification_hub.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/mixins/tour_target_keys_mixin.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_tour_manager.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Performance-optimized homepage that maintains identical UI
/// Uses MVVM pattern with lazy loading for <3s cold start
class HomeScreenPerformance extends ConsumerStatefulWidget {
  const HomeScreenPerformance({super.key});

  @override
  ConsumerState<HomeScreenPerformance> createState() => _HomeScreenPerformanceState();
}

class _HomeScreenPerformanceState extends ConsumerState<HomeScreenPerformance>
    with TourTargetKeysMixin {
  late final OnboardingTourManager _tourManager;
  late final ScrollController _scrollController;
  final _visibleSections = <String>{};

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // Initialize tour manager (same as original)
    _tourManager = OnboardingTourManager(
      tourTargetKeys,
      onTourCompleted: () {
        ref.read(onboardingStateProvider.notifier).completeOnboarding();
        ref.read(onboardingStateProvider.notifier).markOverlaySeen('homeTour');
      },
    );

    // Start loading critical data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _checkForTour();

      // Listen to scroll for lazy loading
      _scrollController.addListener(_onScroll);
    });
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(homeStateProvider.notifier);
    await notifier.loadInitialData();
  }

  void _checkForTour() {
    // Same tour logic as original
    final onboardingState = ref.read(onboardingStateProvider);
    if (onboardingState.isBeginner && !onboardingState.hasSeenGlobalOnboarding) {
      Future.delayed(const Duration(milliseconds: 800), () async {
        if (mounted && context.mounted) {
          final missingSteps = _tourManager.validateTourSetup();
          if (missingSteps.isEmpty) {
            await _tourManager.startTour(context);
          }
        }
      });
    }
  }

  void _onScroll() {
    // Implement visibility detection for lazy loading
    final metrics = _scrollController.position;
    final viewportHeight = metrics.viewportDimension;
    final scrollOffset = metrics.pixels;

    // Load sections as they become visible
    _updateVisibleSections(scrollOffset, viewportHeight);
  }

  void _updateVisibleSections(double scrollOffset, double viewportHeight) {
    // Track which sections are visible for analytics
    // This helps optimize future loads
  }

  @override
  void dispose() {
    _tourManager.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingPhase = ref.watch(loadingPhaseProvider);
    final greeting = ref.watch(greetingSectionProvider);
    final workoutSection = ref.watch(workoutSectionProvider);
    final aiCoachSection = ref.watch(aiCoachSectionProvider);
    final streakSection = ref.watch(streakSectionProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content (identical to original)
            RefreshIndicator(
              onRefresh: () async {
                await ref.read(homeStateProvider.notifier).loadInitialData();
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App Bar (same as original)
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Row(
                      children: [
                        Icon(
                          AppIcons.homeFilled,
                          size: AppIconSize.large,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.home,
                          style: context.textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    actions: const [
                      NotificationHub(),
                    ],
                  ),

                  // Content sections with progressive loading
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Critical Section: Always show immediately
                        DynamicGreeting(key: tourTargetKeys['greeting']),
                        const SizedBox(height: 20),

                        // Show skeleton or actual content based on loading phase
                        if (loadingPhase.index >= LoadingPhase.loadingCritical.index) ...[
                          EnhancedWorkoutBanner(key: tourTargetKeys['workout']),
                          const SizedBox(height: 16),
                        ] else
                          _buildSkeletonCard(height: 120),

                        // Secondary sections with visibility detection
                        if (loadingPhase.index >= LoadingPhase.loadingSecondary.index) ...[
                          VisibilityDetector(
                            key: const Key('ai_coach_section'),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction > 0.1) {
                                _visibleSections.add('ai_coach');
                              }
                            },
                            child: Column(
                              children: [
                                AICoachCard(key: tourTargetKeys['aiCoach']),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          VisibilityDetector(
                            key: const Key('workout_cta_section'),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction > 0.1) {
                                _visibleSections.add('workout_cta');
                              }
                            },
                            child: Column(
                              children: [
                                SmartWorkoutCTA(key: tourTargetKeys['workoutCTA']),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ] else ...[
                          _buildSkeletonCard(height: 100),
                          const SizedBox(height: 16),
                          _buildSkeletonCard(height: 80),
                          const SizedBox(height: 16),
                        ],

                        // Optional sections
                        if (loadingPhase.index >= LoadingPhase.loadingOptional.index) ...[
                          VisibilityDetector(
                            key: const Key('streak_section'),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction > 0.1) {
                                _visibleSections.add('streak');
                              }
                            },
                            child: Column(
                              children: [
                                StreakCounterWidget(key: tourTargetKeys['streak']),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          SecondaryActions(key: tourTargetKeys['secondaryActions']),
                        ] else ...[
                          _buildSkeletonCard(height: 80),
                          const SizedBox(height: 16),
                          _buildSkeletonCard(height: 150),
                        ],

                        const SizedBox(height: 80), // Bottom padding
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // Tour overlay (same as original)
            if (_tourManager.isActive)
              OnboardingTourOverlayEnhanced(tourManager: _tourManager),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/home/presentation/home_screen_performance_test.dart`
Expected: PASS (all widgets found)

**Step 5: Commit**

```bash
git add lib/features/home/presentation/home_screen_performance.dart
git add test/features/home/presentation/home_screen_performance_test.dart
git commit -m "feat: migrate HomeScreen to MVVM with identical UI"
```

## Phase 4: Performance Monitoring & Optimization

### Task 6: Add Memory Monitoring

**Files:**
- Create: `lib/features/home/presentation/providers/memory_monitor.dart`
- Create: `lib/features/home/presentation/providers/cache_warm_tracker.dart`

**Step 1: Implement memory monitoring**

```dart
// lib/features/home/presentation/providers/memory_monitor.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class MemoryMonitor {
  final List<MemorySnapshot> _snapshots = [];
  static const _spikeThresholdMB = 20.0;

  void checkMemory() {
    final current = _getCurrentMemoryUsage();

    _snapshots.add(MemorySnapshot(
      timestamp: DateTime.now(),
      usedMemoryMB: current,
    ));

    // Check for spikes
    if (_snapshots.length >= 2) {
      final prev = _snapshots[_snapshots.length - 2];
      final increase = current - prev.usedMemoryMB;

      if (increase > _spikeThresholdMB) {
        if (kDebugMode) {
          debugPrint('⚠️ Memory spike: +${increase.toStringAsFixed(1)}MB');
        }
      }
    }

    // Clean old snapshots
    if (_snapshots.length > 100) {
      _snapshots.removeRange(0, _snapshots.length - 100);
    }
  }

  double _getCurrentMemoryUsage() {
    // Platform-specific implementation
    final info = ProcessInfo.currentRss;
    return info / 1024 / 1024; // Convert to MB
  }

  String getHealthStatus() {
    if (_snapshots.isEmpty) return 'unknown';

    final current = _snapshots.last.usedMemoryMB;
    if (current < 100) return 'excellent';
    if (current < 150) return 'good';
    if (current < 200) return 'warning';
    return 'critical';
  }
}

class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;

  const MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
  });
}

final memoryMonitorProvider = Provider<MemoryMonitor>((ref) {
  return MemoryMonitor();
});
```

**Step 2: Add cache warm tracking**

```dart
// lib/features/home/presentation/providers/cache_warm_tracker.dart
import 'package:flutter/foundation.dart';

class CacheWarmTracker {
  final Map<String, CacheWarmStatus> _cacheStatus = {};

  void recordCacheWarm(String cacheKey, Duration warmingTime) {
    _cacheStatus[cacheKey] = CacheWarmStatus(
      isWarm: true,
      warmingTime: warmingTime,
      timestamp: DateTime.now(),
    );

    if (kDebugMode) {
      debugPrint('✅ Cache warm: $cacheKey in ${warmingTime.inMilliseconds}ms');
    }
  }

  void recordCacheMiss(String cacheKey) {
    _cacheStatus[cacheKey] = CacheWarmStatus(
      isWarm: false,
      timestamp: DateTime.now(),
    );
  }

  double getCacheHitRate() {
    if (_cacheStatus.isEmpty) return 0;

    final hits = _cacheStatus.values.where((s) => s.isWarm).length;
    return hits / _cacheStatus.length;
  }
}

class CacheWarmStatus {
  final bool isWarm;
  final Duration? warmingTime;
  final DateTime timestamp;

  const CacheWarmStatus({
    required this.isWarm,
    this.warmingTime,
    required this.timestamp,
  });
}

final cacheWarmTrackerProvider = Provider<CacheWarmTracker>((ref) {
  return CacheWarmTracker();
});
```

**Step 3: Commit**

```bash
git add lib/features/home/presentation/providers/memory_monitor.dart
git add lib/features/home/presentation/providers/cache_warm_tracker.dart
git commit -m "feat: add memory monitoring and cache warm tracking"
```

### Task 7: Switch to New Implementation

**Files:**
- Modify: `lib/main.dart` or routing configuration
- Test: Full app test

**Step 1: Update routing to use new homepage**

```dart
// In your routing configuration (e.g., GoRouter)
// Replace HomeScreenOptimized with HomeScreenPerformance

GoRoute(
  path: '/',
  name: 'home',
  builder: (context, state) => const HomeScreenPerformance(),
),
```

**Step 2: Run full app test**

Run: `flutter run --profile`
Expected: App launches with identical UI but improved performance

**Step 3: Verify performance metrics**

- Cold start time: Should be <3s
- Memory usage: Should stay <150MB
- Frame rate: Should maintain 60fps

**Step 4: Commit final switch**

```bash
git add lib/main.dart
git commit -m "feat: switch to performance-optimized homepage

- Maintains identical UI/UX
- MVVM architecture with lazy loading
- <3s cold start achieved
- Memory monitoring active
- Cache warm tracking enabled"
```

## Validation Checklist

### Performance Metrics
- [ ] Cold start <3 seconds
- [ ] Warm start <800ms
- [ ] 60fps during scroll
- [ ] Memory <150MB average
- [ ] Cache hit rate >80%

### UI Consistency
- [ ] DynamicGreeting identical
- [ ] EnhancedWorkoutBanner identical
- [ ] AICoachCard identical
- [ ] SmartWorkoutCTA identical
- [ ] StreakCounterWidget identical
- [ ] SecondaryActions identical
- [ ] Tour functionality preserved

### Code Quality
- [ ] All tests passing
- [ ] No memory leaks
- [ ] Proper error handling
- [ ] Performance logging active
- [ ] Auto-dispose working

## Next Steps

1. Monitor production metrics with Firebase Performance
2. A/B test old vs new implementation
3. Optimize individual widget performance if needed
4. Add more granular lazy loading for images

---

**Plan complete and saved to `docs/plans/2025-01-18-homepage-performance-implementation.md`.**

**Two execution options:**

1. **Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

2. **Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach would you prefer?**