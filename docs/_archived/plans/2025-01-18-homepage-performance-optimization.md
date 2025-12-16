# Homepage Performance Optimization - Complete Design

**Generated**: 2025-01-18 10:15
**Target Performance**: <3s cold start, 60fps, <150ms interaction
**Architecture**: MVVM + Single Source of Truth (Riverpod) + Lazy Loading
**Version**: 1.0 FINAL

## 📊 Performance Targets

- **Cold Start**: <3 seconds (P95)
- **Warm Start**: <800ms (P95)
- **Frame Rate**: 60fps (no jank)
- **Time to Interactive**: <2 seconds
- **Memory Usage**: <150MB average
- **Cache Hit Rate**: >80%

## 🏗️ Section 1: MVVM Foundation

### Core Architecture

```dart
// lib/features/home/domain/viewmodels/home_viewmodel.dart
abstract class HomeViewModel {
  AsyncValue<HomeData> get homeData;
  AsyncValue<WorkoutStatus> get workoutStatus;
  AsyncValue<UserStats> get userStats;

  Future<void> loadInitialData();
  Future<void> refreshData();
  void startQuickWorkout();
  void openAnalytics();
  void dispose();
}

// lib/features/home/data/viewmodels/home_viewmodel_impl.dart
class HomeViewModelImpl implements HomeViewModel {
  final Ref _ref;
  final PerformanceLogger _logger;
  final MetricsCollector _metrics;

  @override
  AsyncValue<HomeData> get homeData => _ref.watch(homeDataProvider);

  @override
  AsyncValue<WorkoutStatus> get workoutStatus =>
    _ref.watch(workoutSectionProvider.select((data) => data.status));

  @override
  Future<void> loadInitialData() async {
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        _ref.read(homeDataProvider.notifier).load(),
        _ref.read(workoutSectionProvider.future),
      ]);

      _metrics.recordStartupTime(stopwatch.elapsed);
    } catch (e) {
      _logger.error('Failed to load initial data', e);
      rethrow;
    }
  }
}
```

### Family Providers for Parameterized Data

```dart
// Family provider for user-specific data
final userStatsProvider = FutureProvider.autoDispose.family<
  UserStats,
  String
>((ref, userId) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getStats(userId);
});

// Family provider for date range queries
final workoutHistoryProvider = FutureProvider.autoDispose.family<
  List<Workout>,
  DateRange
>((ref, dateRange) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getWorkoutsInRange(dateRange);
});
```

### AutoDispose Strategy

```dart
// Auto-dispose after 30 seconds of inactivity
final homeStateProvider = StateNotifierProvider.autoDispose<
  HomeStateNotifier,
  HomeState
>((ref) {
  // Set custom dispose delay
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

  return HomeStateNotifier(ref: ref);
});
```

### Micro-Providers Pattern

```dart
// Split large state into micro-providers
final greetingProvider = Provider.autoDispose<String>((ref) {
  final user = ref.watch(currentUserProvider);
  final hour = DateTime.now().hour;
  return _generateGreeting(user, hour);
});

final workoutBannerProvider = Provider.autoDispose<WorkoutBanner>((ref) {
  final workout = ref.watch(activeWorkoutProvider);
  final exercises = ref.watch(exercisesProvider);
  return WorkoutBanner.from(workout, exercises);
});

final quickActionsProvider = Provider.autoDispose<List<QuickAction>>((ref) {
  final hasActiveWorkout = ref.watch(
    activeWorkoutProvider.select((w) => w != null)
  );
  return _buildQuickActions(hasActiveWorkout);
});
```

### Performance Logging

```dart
class PerformanceLogger {
  final List<PerformanceEntry> _entries = [];

  void logProviderRebuild(String providerName, Duration rebuildTime) {
    _entries.add(PerformanceEntry(
      type: 'provider_rebuild',
      name: providerName,
      duration: rebuildTime,
      timestamp: DateTime.now(),
    ));
  }

  void logDataFetch(String source, Duration fetchTime, int dataSize) {
    _entries.add(PerformanceEntry(
      type: 'data_fetch',
      name: source,
      duration: fetchTime,
      metadata: {'dataSize': dataSize},
      timestamp: DateTime.now(),
    ));
  }

  Map<String, dynamic> generateReport() {
    return {
      'slowest_operations': _getSlowOperations(),
      'frequent_rebuilds': _getFrequentRebuilds(),
      'total_time': _getTotalTime(),
    };
  }
}
```

### Test Coverage Requirements

```dart
// test/features/home/viewmodels/home_viewmodel_test.dart
void main() {
  group('HomeViewModel', () {
    test('loads initial data within 3 seconds', () async {
      final container = ProviderContainer();
      final viewModel = container.read(homeViewModelProvider);

      final stopwatch = Stopwatch()..start();
      await viewModel.loadInitialData();
      stopwatch.stop();

      expect(stopwatch.elapsed.inSeconds, lessThan(3));
    });

    test('handles refresh with proper state transitions', () async {
      // Test loading -> success -> refresh -> success cycle
    });

    test('disposes resources properly', () async {
      // Test memory cleanup
    });
  });
}
```

## 🎯 Section 2: Provider Architecture

### State Management

```dart
// lib/features/home/presentation/providers/home_state.dart
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    required String greeting,
    required WorkoutSection workoutSection,
    required StatsSection statsSection,
    required List<QuickAction> actions,
    @Default(LoadingPhase.initial) LoadingPhase loadingPhase,
    @Default({}) Map<String, Duration> sectionLoadTimes,
    DateTime? lastRefresh,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _HomeState;
}

enum LoadingPhase {
  initial,
  loadingCritical,  // Greeting + active workout
  loadingSecondary, // Stats + quick actions
  loadingOptional,  // Recommendations + tips
  complete,
  error
}
```

### State Notifier with Granular Updates

```dart
class HomeStateNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  final PerformanceLogger _logger;
  final MetricsCollector _metrics;
  Timer? _refreshTimer;

  HomeStateNotifier({
    required Ref ref,
    required PerformanceLogger logger,
    required MetricsCollector metrics,
  }) : _ref = ref,
       _logger = logger,
       _metrics = metrics,
       super(const HomeState(
         greeting: '',
         workoutSection: WorkoutSection.empty(),
         statsSection: StatsSection.empty(),
         actions: [],
       ));

  Future<void> loadInitialData() async {
    state = state.copyWith(loadingPhase: LoadingPhase.loadingCritical);

    // Phase 1: Critical data (must show immediately)
    await _loadCriticalData();

    // Phase 2: Secondary data (nice to have)
    await _loadSecondaryData();

    // Phase 3: Optional enrichment
    _loadOptionalData(); // Fire and forget
  }

  Future<void> _loadCriticalData() async {
    final stopwatch = Stopwatch()..start();

    try {
      final results = await Future.wait([
        _loadGreeting(),
        _loadActiveWorkout(),
      ]);

      state = state.copyWith(
        greeting: results[0] as String,
        workoutSection: results[1] as WorkoutSection,
        loadingPhase: LoadingPhase.loadingSecondary,
        sectionLoadTimes: {
          'critical': stopwatch.elapsed,
        },
      );

      _metrics.recordSectionLoad('critical', stopwatch.elapsed);
    } catch (e) {
      _handleError(e, 'critical');
    }
  }
}
```

### Provider Structure with .select() Optimization

```dart
// Main provider
final homeStateProvider = StateNotifierProvider.autoDispose<
  HomeStateNotifier,
  HomeState
>((ref) {
  return HomeStateNotifier(
    ref: ref,
    logger: ref.watch(performanceLoggerProvider),
    metrics: ref.watch(metricsCollectorProvider),
  );
});

// Micro-providers with .select() for granular rebuilds
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

final loadingPhaseProvider = Provider.autoDispose<LoadingPhase>((ref) {
  return ref.watch(
    homeStateProvider.select((state) => state.loadingPhase)
  );
});

// Fine-grained selectors for specific UI elements
final hasActiveWorkoutProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(
    workoutSectionProvider.select((section) => section.hasActive)
  );
});

final workoutProgressProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(
    workoutSectionProvider.select((section) => section.progress)
  );
});
```

### Repository Providers with Retry Logic (FIXED)

```dart
class RepositoryWithRetry {
  static const _maxRetries = 3;
  static const _fixedTimeout = Duration(seconds: 10); // FIXED timeout
  static const _baseDelay = Duration(seconds: 1);

  Future<T> fetchWithRetry<T>({
    required Future<T> Function() fetcher,
    required String operationName,
    required MetricsCollector metrics,
  }) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final stopwatch = Stopwatch()..start();

      try {
        final result = await fetcher().timeout(_fixedTimeout); // Fixed timeout

        metrics.recordDataFetch(
          repository: operationName,
          latency: stopwatch.elapsed,
          attemptNumber: attempt,
          success: true,
        );

        return result;
      } catch (e) {
        stopwatch.stop();

        metrics.recordDataFetch(
          repository: operationName,
          latency: stopwatch.elapsed,
          attemptNumber: attempt,
          success: false,
          error: e.toString(),
        );

        if (attempt == _maxRetries) {
          throw RepositoryException(
            'Failed after $_maxRetries attempts',
            originalError: e,
            attempts: attempt,
          );
        }

        // Exponential backoff with jitter
        final delay = _baseDelay * pow(2, attempt - 1);
        final jitter = Random().nextInt(1000);
        await Future.delayed(delay + Duration(milliseconds: jitter));
      }
    }

    throw StateError('Should not reach here');
  }
}
```

### Enhanced Repository Metrics

```dart
class RepositoryMetrics {
  final Map<String, List<Duration>> _latencies = {};
  final Map<String, int> _dataSizes = {};
  final Map<String, int> _retryCount = {};
  final Map<String, QueryType> _queryTypes = {};
  final List<MemorySnapshot> _memorySnapshots = [];

  void recordDataFetch({
    required String repository,
    required String queryType, // 'single', 'list', 'stream', 'paginated'
    required Duration latency,
    required int dataSize,
    required DataSource source, // 'cache', 'network', 'fallback'
    required bool isRetry,
    required int attemptNumber,
  }) {
    _latencies.putIfAbsent(repository, () => []).add(latency);
    _dataSizes[repository] = dataSize;
    _queryTypes[repository] = QueryType.fromString(queryType);

    if (isRetry) {
      _retryCount.update(repository, (count) => count + 1, ifAbsent: () => 1);
    }

    // Take memory snapshot every 10 fetches
    if (_latencies.values.fold(0, (sum, list) => sum + list.length) % 10 == 0) {
      _captureMemorySnapshot();
    }
  }

  void _captureMemorySnapshot() {
    final info = ProcessInfo();
    _memorySnapshots.add(MemorySnapshot(
      timestamp: DateTime.now(),
      usedMemoryMB: info.currentRss / 1024 / 1024,
      maxMemoryMB: info.maxRss / 1024 / 1024,
    ));
  }

  // Calculate P50, P95, P99 percentiles
  Map<String, LatencyPercentiles> getLatencyPercentiles() {
    final result = <String, LatencyPercentiles>{};

    for (final entry in _latencies.entries) {
      final sorted = entry.value.toList()..sort();
      if (sorted.isEmpty) continue;

      result[entry.key] = LatencyPercentiles(
        p50: _getPercentile(sorted, 50),
        p95: _getPercentile(sorted, 95),
        p99: _getPercentile(sorted, 99),
        min: sorted.first,
        max: sorted.last,
        avg: sorted.reduce((a, b) => a + b) ~/ sorted.length,
      );
    }

    return result;
  }

  Duration _getPercentile(List<Duration> sorted, int percentile) {
    final index = (sorted.length * percentile / 100).round() - 1;
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  // Detect memory spikes
  List<MemorySpike> detectMemorySpikes({
    double thresholdMB = 20, // Spike if increases by 20MB
  }) {
    final spikes = <MemorySpike>[];

    for (int i = 1; i < _memorySnapshots.length; i++) {
      final prev = _memorySnapshots[i - 1];
      final curr = _memorySnapshots[i];
      final increase = curr.usedMemoryMB - prev.usedMemoryMB;

      if (increase > thresholdMB) {
        spikes.add(MemorySpike(
          timestamp: curr.timestamp,
          increaseMB: increase,
          beforeMB: prev.usedMemoryMB,
          afterMB: curr.usedMemoryMB,
        ));
      }
    }

    return spikes;
  }

  Map<String, dynamic> generateReport() {
    return {
      'latency_percentiles': getLatencyPercentiles(),
      'largest_payloads': _getLargestPayloads(),
      'retry_rate': _calculateRetryRate(),
      'query_distribution': _getQueryDistribution(),
      'memory_spikes': detectMemorySpikes(),
      'memory_usage': {
        'current_mb': _memorySnapshots.lastOrNull?.usedMemoryMB ?? 0,
        'peak_mb': _memorySnapshots.map((s) => s.usedMemoryMB).reduce(max),
        'average_mb': _calculateAverageMemory(),
      },
    };
  }
}

class LatencyPercentiles {
  final Duration p50;
  final Duration p95;
  final Duration p99;
  final Duration min;
  final Duration max;
  final Duration avg;

  const LatencyPercentiles({
    required this.p50,
    required this.p95,
    required this.p99,
    required this.min,
    required this.max,
    required this.avg,
  });
}

class MemorySnapshot {
  final DateTime timestamp;
  final double usedMemoryMB;
  final double maxMemoryMB;

  const MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.maxMemoryMB,
  });
}

class MemorySpike {
  final DateTime timestamp;
  final double increaseMB;
  final double beforeMB;
  final double afterMB;

  const MemorySpike({
    required this.timestamp,
    required this.increaseMB,
    required this.beforeMB,
    required this.afterMB,
  });
}
```

## 🚀 Section 3: Lazy Loading & Performance

### Priority-Based Loading System

```dart
enum LoadPriority {
  critical(0),   // Must load immediately (greeting, active workout)
  high(1),       // Load soon (stats, quick actions)
  medium(2),     // Load when idle (recommendations)
  low(3);        // Load eventually (tips, promotions)

  final int value;
  const LoadPriority(this.value);
}

class LazyLoadScheduler {
  final Queue<LoadTask> _criticalQueue = Queue();
  final Queue<LoadTask> _highQueue = Queue();
  final Queue<LoadTask> _mediumQueue = Queue();
  final Queue<LoadTask> _lowQueue = Queue();

  bool _isProcessing = false;

  void schedule(LoadTask task) {
    switch (task.priority) {
      case LoadPriority.critical:
        _criticalQueue.add(task);
        _processImmediately();
        break;
      case LoadPriority.high:
        _highQueue.add(task);
        _scheduleHighPriority();
        break;
      case LoadPriority.medium:
        _mediumQueue.add(task);
        _scheduleWhenIdle();
        break;
      case LoadPriority.low:
        _lowQueue.add(task);
        _scheduleEventually();
        break;
    }
  }

  Future<void> _processImmediately() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_criticalQueue.isNotEmpty) {
      final task = _criticalQueue.removeFirst();
      await _executeTask(task);
    }

    _isProcessing = false;
    _processNextPriority();
  }

  void _scheduleHighPriority() {
    Timer(const Duration(milliseconds: 100), () {
      _processQueue(_highQueue);
    });
  }

  void _scheduleWhenIdle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        _processQueue(_mediumQueue);
      }
    });
  }

  void _scheduleEventually() {
    Timer(const Duration(seconds: 2), () {
      _processQueue(_lowQueue);
    });
  }
}
```

### Cache Warm Tracking

```dart
class CacheWarmTracker {
  final Map<String, CacheWarmStatus> _cacheStatus = {};
  final Map<String, List<Duration>> _warmingLatencies = {};

  void recordCacheWarm({
    required String cacheKey,
    required Duration warmingTime,
    required int itemCount,
    required int sizeBytes,
  }) {
    _cacheStatus[cacheKey] = CacheWarmStatus(
      isWarm: true,
      warmingTime: warmingTime,
      itemCount: itemCount,
      sizeBytes: sizeBytes,
      timestamp: DateTime.now(),
    );

    _warmingLatencies.putIfAbsent(cacheKey, () => []).add(warmingTime);
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

  Duration getAverageWarmingTime() {
    final allLatencies = _warmingLatencies.values
        .expand((list) => list)
        .toList();

    if (allLatencies.isEmpty) return Duration.zero;

    final total = allLatencies.reduce((a, b) => a + b);
    return total ~/ allLatencies.length;
  }

  Map<String, dynamic> generateReport() {
    return {
      'cache_hit_rate': '${(getCacheHitRate() * 100).toStringAsFixed(1)}%',
      'warm_caches': _cacheStatus.values.where((s) => s.isWarm).length,
      'cold_caches': _cacheStatus.values.where((s) => !s.isWarm).length,
      'avg_warming_time': '${getAverageWarmingTime().inMilliseconds}ms',
      'largest_cache': _getLargestCache(),
      'oldest_warm_cache': _getOldestWarmCache(),
      'cache_efficiency': _calculateCacheEfficiency(),
    };
  }

  Map<String, dynamic> _calculateCacheEfficiency() {
    // Compare cache warming time vs network fetch time
    final warmingTimes = _warmingLatencies.values
        .expand((list) => list)
        .map((d) => d.inMilliseconds)
        .toList();

    if (warmingTimes.isEmpty) return {'status': 'no_data'};

    warmingTimes.sort();

    return {
      'p50_warming_ms': warmingTimes[warmingTimes.length ~/ 2],
      'p95_warming_ms': warmingTimes[(warmingTimes.length * 0.95).round()],
      'recommendation': warmingTimes.last > 500
          ? 'Consider reducing cache size or implementing partial loading'
          : 'Cache warming performance is optimal',
    };
  }
}

class CacheWarmStatus {
  final bool isWarm;
  final Duration? warmingTime;
  final int? itemCount;
  final int? sizeBytes;
  final DateTime timestamp;

  const CacheWarmStatus({
    required this.isWarm,
    this.warmingTime,
    this.itemCount,
    this.sizeBytes,
    required this.timestamp,
  });
}
```

### Optimized Widget Implementation

```dart
class OptimizedHomeScreen extends ConsumerStatefulWidget {
  const OptimizedHomeScreen({super.key});

  @override
  ConsumerState<OptimizedHomeScreen> createState() => _OptimizedHomeScreenState();
}

class _OptimizedHomeScreenState extends ConsumerState<OptimizedHomeScreen> {
  late final ScrollController _scrollController;
  late final LazyLoadScheduler _loadScheduler;
  final _visibleSections = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadScheduler = LazyLoadScheduler();

    // Schedule initial loads
    _scheduleCriticalLoads();

    // Listen to scroll for lazy loading
    _scrollController.addListener(_onScroll);

    // Schedule secondary loads after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleSecondaryLoads();
    });
  }

  void _scheduleCriticalLoads() {
    _loadScheduler.schedule(LoadTask(
      id: 'greeting',
      priority: LoadPriority.critical,
      loader: () => ref.read(greetingProvider),
    ));

    _loadScheduler.schedule(LoadTask(
      id: 'active_workout',
      priority: LoadPriority.critical,
      loader: () => ref.read(activeWorkoutProvider.future),
    ));
  }

  void _scheduleSecondaryLoads() {
    _loadScheduler.schedule(LoadTask(
      id: 'stats',
      priority: LoadPriority.high,
      loader: () => ref.read(userStatsProvider.future),
    ));

    _loadScheduler.schedule(LoadTask(
      id: 'quick_actions',
      priority: LoadPriority.high,
      loader: () => ref.read(quickActionsProvider),
    ));
  }

  void _onScroll() {
    // Implement visibility detection and lazy loading
    final metrics = _scrollController.position;
    final viewportHeight = metrics.viewportDimension;
    final scrollOffset = metrics.pixels;

    // Check which sections are visible
    _updateVisibleSections(scrollOffset, viewportHeight);

    // Load sections as they become visible
    _loadVisibleSections();
  }

  @override
  Widget build(BuildContext context) {
    final loadingPhase = ref.watch(loadingPhaseProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Critical section - always show
          SliverToBoxAdapter(
            child: _buildGreetingSection(),
          ),

          // Show skeleton or actual content based on loading phase
          if (loadingPhase.index >= LoadingPhase.loadingCritical.index)
            SliverToBoxAdapter(
              child: _buildWorkoutSection(),
            ),

          // Secondary sections with visibility detection
          if (loadingPhase.index >= LoadingPhase.loadingSecondary.index)
            SliverToBoxAdapter(
              child: VisibilityDetector(
                key: const Key('stats_section'),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction > 0.1) {
                    _loadScheduler.schedule(LoadTask(
                      id: 'detailed_stats',
                      priority: LoadPriority.medium,
                      loader: () => ref.read(detailedStatsProvider.future),
                    ));
                  }
                },
                child: _buildStatsSection(),
              ),
            ),
        ],
      ),
    );
  }
}
```

## 🎯 Section 4: Enhanced Performance Monitoring

### Complete Performance Timeline

```dart
class EnhancedPerformanceTimeline {
  final List<PerformanceEvent> _events = [];
  final Map<String, RepositoryMetrics> _repositoryMetrics = {};
  final CacheWarmTracker _cacheTracker = CacheWarmTracker();
  final MemoryMonitor _memoryMonitor = MemoryMonitor();

  void recordDataFetch({
    required String section,
    required String repository,
    required String queryType, // 'single', 'list', 'stream', 'paginated'
    required Duration latency,
    required int dataSize,
    required DataSource source, // 'cache', 'network', 'fallback'
    required bool isRetry,
    required int attemptNumber,
  }) {
    _events.add(PerformanceEvent(
      type: 'data_fetch',
      section: section,
      repository: repository,
      queryType: queryType,
      latency: latency,
      dataSize: dataSize,
      source: source,
      isRetry: isRetry,
      attemptNumber: attemptNumber,
      timestamp: DateTime.now(),
    ));

    // Update repository-specific metrics
    _repositoryMetrics.putIfAbsent(repository, () => RepositoryMetrics())
      ..recordDataFetch(
        repository: repository,
        queryType: queryType,
        latency: latency,
        dataSize: dataSize,
        source: source,
        isRetry: isRetry,
        attemptNumber: attemptNumber,
      );

    // Track cache warming
    if (source == DataSource.cache) {
      _cacheTracker.recordCacheWarm(
        cacheKey: '$repository:$queryType',
        warmingTime: latency,
        itemCount: dataSize ~/ 100, // Estimate
        sizeBytes: dataSize,
      );
    } else if (source == DataSource.network) {
      _cacheTracker.recordCacheMiss('$repository:$queryType');
    }

    // Monitor memory
    _memoryMonitor.checkMemory();
  }

  Map<String, dynamic> generateDetailedReport() {
    final repositoryReports = <String, dynamic>{};
    for (final entry in _repositoryMetrics.entries) {
      repositoryReports[entry.key] = entry.value.generateReport();
    }

    return {
      'performance_summary': {
        'total_events': _events.length,
        'total_time': _calculateTotalTime(),
        'cache_hit_rate': _cacheTracker.getCacheHitRate(),
        'memory_health': _memoryMonitor.getHealthStatus(),
      },
      'repository_metrics': repositoryReports,
      'latency_analysis': _analyzeLatencies(),
      'cache_performance': _cacheTracker.generateReport(),
      'memory_analysis': _memoryMonitor.generateReport(),
      'bottlenecks': _identifyBottlenecks(),
      'actionable_insights': _generateActionableInsights(),
    };
  }

  Map<String, dynamic> _analyzeLatencies() {
    final latenciesBySection = <String, List<Duration>>{};

    for (final event in _events) {
      latenciesBySection.putIfAbsent(event.section, () => [])
          .add(event.latency);
    }

    final analysis = <String, dynamic>{};
    for (final entry in latenciesBySection.entries) {
      final sorted = entry.value.toList()..sort();

      analysis[entry.key] = {
        'p50': _getPercentile(sorted, 50).inMilliseconds,
        'p95': _getPercentile(sorted, 95).inMilliseconds,
        'p99': _getPercentile(sorted, 99).inMilliseconds,
        'min': sorted.first.inMilliseconds,
        'max': sorted.last.inMilliseconds,
        'avg': (sorted.reduce((a, b) => a + b) ~/ sorted.length).inMilliseconds,
      };
    }

    return analysis;
  }

  List<Bottleneck> _identifyBottlenecks() {
    final bottlenecks = <Bottleneck>[];

    // Find slow operations (>2s)
    final slowOps = _events.where((e) => e.latency.inSeconds >= 2);
    for (final op in slowOps) {
      bottlenecks.add(Bottleneck(
        type: 'slow_operation',
        severity: op.latency.inSeconds >= 5 ? 'critical' : 'warning',
        description: '${op.repository} taking ${op.latency.inSeconds}s',
        recommendation: 'Consider caching or optimizing query',
      ));
    }

    // Find large payloads (>100KB)
    final largePayloads = _events.where((e) => e.dataSize > 100000);
    for (final payload in largePayloads) {
      bottlenecks.add(Bottleneck(
        type: 'large_payload',
        severity: payload.dataSize > 500000 ? 'critical' : 'warning',
        description: '${payload.repository} returning ${payload.dataSize ~/ 1024}KB',
        recommendation: 'Implement pagination or data reduction',
      ));
    }

    // Find high retry rates
    for (final entry in _repositoryMetrics.entries) {
      final retryRate = entry.value._calculateRetryRate();
      if (retryRate > 0.3) {
        bottlenecks.add(Bottleneck(
          type: 'high_retry_rate',
          severity: 'warning',
          description: '${entry.key} has ${(retryRate * 100).toInt()}% retry rate',
          recommendation: 'Investigate network stability or service health',
        ));
      }
    }

    // Find memory spikes
    final memorySpikes = _memoryMonitor.detectSpikes();
    for (final spike in memorySpikes) {
      bottlenecks.add(Bottleneck(
        type: 'memory_spike',
        severity: spike.increaseMB > 50 ? 'critical' : 'warning',
        description: 'Memory increased by ${spike.increaseMB.toStringAsFixed(1)}MB',
        recommendation: 'Check for memory leaks or optimize data structures',
      ));
    }

    return bottlenecks;
  }

  ActionableInsights _generateActionableInsights() {
    final bottlenecks = _identifyBottlenecks();
    final cacheReport = _cacheTracker.generateReport();
    final memoryReport = _memoryMonitor.generateReport();

    return ActionableInsights(
      immediateFixes: _getImmediateFixes(bottlenecks),
      longTermOptimizations: _getLongTermOptimizations(cacheReport, memoryReport),
      monitoringAlerts: _getActiveAlerts(bottlenecks),
      performanceScore: _calculatePerformanceScore(),
    );
  }

  List<Fix> _getImmediateFixes(List<Bottleneck> bottlenecks) {
    final fixes = <Fix>[];

    // Group by type and prioritize
    final critical = bottlenecks.where((b) => b.severity == 'critical');

    for (final bottleneck in critical) {
      switch (bottleneck.type) {
        case 'slow_operation':
          fixes.add(Fix(
            title: 'Cache slow operation',
            description: bottleneck.description,
            implementation: '''
// Add caching to repository
final cachedData = await _cache.get(key);
if (cachedData != null) return cachedData;
final data = await _fetchFromNetwork();
await _cache.set(key, data);
return data;
            ''',
            estimatedImpact: 'Reduce latency by 80%',
            priority: 'high',
          ));
          break;

        case 'large_payload':
          fixes.add(Fix(
            title: 'Implement pagination',
            description: bottleneck.description,
            implementation: '''
// Add pagination to query
final pageSize = 20;
final results = await repository.fetchPaginated(
  offset: currentPage * pageSize,
  limit: pageSize,
);
            ''',
            estimatedImpact: 'Reduce initial payload by 90%',
            priority: 'high',
          ));
          break;

        case 'memory_spike':
          fixes.add(Fix(
            title: 'Fix memory leak',
            description: bottleneck.description,
            implementation: '''
// Dispose controllers and subscriptions
@override
void dispose() {
  _subscription?.cancel();
  _controller?.dispose();
  super.dispose();
}
            ''',
            estimatedImpact: 'Reduce memory usage by 30%',
            priority: 'critical',
          ));
          break;
      }
    }

    return fixes;
  }
}

class ActionableInsights {
  final List<Fix> immediateFixes;
  final List<Optimization> longTermOptimizations;
  final List<Alert> monitoringAlerts;
  final PerformanceScore performanceScore;

  const ActionableInsights({
    required this.immediateFixes,
    required this.longTermOptimizations,
    required this.monitoringAlerts,
    required this.performanceScore,
  });
}

class Fix {
  final String title;
  final String description;
  final String implementation;
  final String estimatedImpact;
  final String priority;

  const Fix({
    required this.title,
    required this.description,
    required this.implementation,
    required this.estimatedImpact,
    required this.priority,
  });
}
```

### Memory Monitoring System

```dart
class MemoryMonitor {
  final List<MemorySnapshot> _snapshots = [];
  final List<MemorySpike> _spikes = [];
  static const _spikeThresholdMB = 20.0;
  static const _criticalThresholdMB = 200.0;

  void checkMemory() {
    final current = _getCurrentMemoryUsage();

    _snapshots.add(MemorySnapshot(
      timestamp: DateTime.now(),
      usedMemoryMB: current.usedMB,
      maxMemoryMB: current.maxMB,
    ));

    // Check for spikes
    if (_snapshots.length >= 2) {
      final prev = _snapshots[_snapshots.length - 2];
      final increase = current.usedMB - prev.usedMemoryMB;

      if (increase > _spikeThresholdMB) {
        _spikes.add(MemorySpike(
          timestamp: DateTime.now(),
          increaseMB: increase,
          beforeMB: prev.usedMemoryMB,
          afterMB: current.usedMB,
        ));

        // Send to Crashlytics if critical
        if (increase > _criticalThresholdMB) {
          _reportToCrashlytics(increase);
        }
      }
    }

    // Clean old snapshots (keep last 100)
    if (_snapshots.length > 100) {
      _snapshots.removeRange(0, _snapshots.length - 100);
    }
  }

  List<MemorySpike> detectSpikes() => List.from(_spikes);

  String getHealthStatus() {
    if (_snapshots.isEmpty) return 'unknown';

    final current = _snapshots.last.usedMemoryMB;
    if (current < 100) return 'excellent';
    if (current < 150) return 'good';
    if (current < 200) return 'warning';
    return 'critical';
  }

  Map<String, dynamic> generateReport() {
    if (_snapshots.isEmpty) {
      return {'status': 'no_data'};
    }

    final usedMemories = _snapshots.map((s) => s.usedMemoryMB).toList();
    usedMemories.sort();

    return {
      'current_mb': _snapshots.last.usedMemoryMB,
      'peak_mb': usedMemories.last,
      'average_mb': usedMemories.reduce((a, b) => a + b) / usedMemories.length,
      'p50_mb': usedMemories[usedMemories.length ~/ 2],
      'p95_mb': usedMemories[(usedMemories.length * 0.95).round()],
      'p99_mb': usedMemories[(usedMemories.length * 0.99).round()],
      'spike_count': _spikes.length,
      'largest_spike_mb': _spikes.isEmpty ? 0 :
          _spikes.map((s) => s.increaseMB).reduce(max),
      'health_status': getHealthStatus(),
      'recommendations': _getMemoryRecommendations(),
    };
  }

  List<String> _getMemoryRecommendations() {
    final recommendations = <String>[];

    if (_snapshots.isEmpty) return recommendations;

    final current = _snapshots.last.usedMemoryMB;

    if (current > 150) {
      recommendations.add('Consider implementing image caching with size limits');
    }

    if (_spikes.length > 5) {
      recommendations.add('Frequent memory spikes detected - check for leaks');
    }

    final avgSpike = _spikes.isEmpty ? 0 :
        _spikes.map((s) => s.increaseMB).reduce((a, b) => a + b) / _spikes.length;

    if (avgSpike > 30) {
      recommendations.add('Large average spike size - optimize data structures');
    }

    return recommendations;
  }

  _MemoryInfo _getCurrentMemoryUsage() {
    // Platform-specific implementation
    if (Platform.isIOS) {
      return _getIOSMemoryInfo();
    } else {
      return _getAndroidMemoryInfo();
    }
  }

  void _reportToCrashlytics(double increaseMB) {
    FirebaseCrashlytics.instance.recordError(
      'Critical memory spike',
      null,
      fatal: false,
      information: [
        'increase_mb: $increaseMB',
        'timestamp: ${DateTime.now().toIso8601String()}',
        'health_status: ${getHealthStatus()}',
      ],
    );
  }
}
```

### Firebase Crashlytics Integration

```dart
class ProductionPerformanceMonitor {
  static final _instance = ProductionPerformanceMonitor._();
  factory ProductionPerformanceMonitor() => _instance;
  ProductionPerformanceMonitor._();

  final _performanceTimeline = EnhancedPerformanceTimeline();
  Timer? _reportTimer;

  void initialize() {
    // Report performance metrics every 5 minutes
    _reportTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _reportToCrashlytics();
    });

    // Report on app lifecycle events
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));

    // Monitor frame drops
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _reportToCrashlytics() async {
    final report = _performanceTimeline.generateDetailedReport();

    // Send custom keys for monitoring
    await FirebaseCrashlytics.instance.setCustomKeys({
      'cache_hit_rate': report['performance_summary']['cache_hit_rate'],
      'memory_health': report['performance_summary']['memory_health'],
      'total_events': report['performance_summary']['total_events'],
    });

    // Log performance events
    await FirebaseCrashlytics.instance.log(
      'Performance Report: ${json.encode(report)}'
    );

    // Report critical issues
    final bottlenecks = report['bottlenecks'] as List<Bottleneck>;
    for (final bottleneck in bottlenecks) {
      if (bottleneck.severity == 'critical') {
        await FirebaseCrashlytics.instance.recordError(
          'Performance Bottleneck',
          null,
          fatal: false,
          information: [
            'type: ${bottleneck.type}',
            'description: ${bottleneck.description}',
            'recommendation: ${bottleneck.recommendation}',
          ],
        );
      }
    }

    // Send to Firebase Performance Monitoring
    final trace = FirebasePerformance.instance.newTrace('homepage_load');
    await trace.start();

    // Add metrics
    final latencies = report['latency_analysis'] as Map<String, dynamic>;
    for (final entry in latencies.entries) {
      final metrics = entry.value as Map<String, dynamic>;
      trace.putMetric('${entry.key}_p95', metrics['p95'] as int);
      trace.putMetric('${entry.key}_p99', metrics['p99'] as int);
    }

    await trace.stop();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration.inMilliseconds;
      final rasterDuration = timing.rasterDuration.inMilliseconds;
      final totalDuration = timing.totalSpan.inMilliseconds;

      // Report jank (frame took >16ms)
      if (totalDuration > 16) {
        FirebaseCrashlytics.instance.log(
          'Frame jank: build=${buildDuration}ms, raster=${rasterDuration}ms, total=${totalDuration}ms'
        );
      }

      // Report severe jank (frame took >100ms)
      if (totalDuration > 100) {
        FirebaseCrashlytics.instance.recordError(
          'Severe frame jank',
          null,
          fatal: false,
          information: [
            'build_ms: $buildDuration',
            'raster_ms: $rasterDuration',
            'total_ms: $totalDuration',
          ],
        );
      }
    }
  }

  void dispose() {
    _reportTimer?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final ProductionPerformanceMonitor monitor;

  _AppLifecycleObserver(this.monitor);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background - send report
      monitor._reportToCrashlytics();
    }
  }
}
```

### Performance Dashboard Widget

```dart
class PerformanceOverlay extends StatelessWidget {
  final Map<String, dynamic> performanceData;

  const PerformanceOverlay({
    super.key,
    required this.performanceData,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Performance',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white30),
            _buildMetric('Cache Hit',
              '${performanceData['cache_hit_rate']}%',
              _getColorForValue(performanceData['cache_hit_rate'], 80, 60)),
            _buildMetric('Memory',
              '${performanceData['memory_mb']}MB',
              _getColorForValue(150 - performanceData['memory_mb'], 50, 0)),
            _buildMetric('P95 Latency',
              '${performanceData['p95_latency']}ms',
              _getColorForValue(2000 - performanceData['p95_latency'], 1000, 0)),
            _buildMetric('Frame Rate',
              '${performanceData['fps']}fps',
              _getColorForValue(performanceData['fps'], 60, 30)),
            if (performanceData['bottlenecks'] > 0)
              _buildWarning('${performanceData['bottlenecks']} bottlenecks'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWarning(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.orange, fontSize: 11),
      ),
    );
  }

  Color _getColorForValue(num value, num good, num bad) {
    if (value >= good) return Colors.green;
    if (value >= bad) return Colors.orange;
    return Colors.red;
  }
}
```

## 📊 Implementation Checklist

### Phase 1: Foundation (2-3 hours)
- [ ] Create MVVM structure with ViewModels
- [ ] Implement HomeState with Freezed
- [ ] Set up StateNotifier with phases
- [ ] Add performance logger base
- [ ] Create micro-providers with .select()

### Phase 2: Data Layer (2-3 hours)
- [ ] Implement repository with retry logic (fixed timeout)
- [ ] Add caching layer with TTL
- [ ] Create metrics collector with P50/P95/P99
- [ ] Set up memory monitoring
- [ ] Add cache warm tracking

### Phase 3: UI Implementation (2-3 hours)
- [ ] Build OptimizedHomeScreen
- [ ] Implement lazy loading scheduler
- [ ] Add visibility detection
- [ ] Create loading skeletons
- [ ] Add performance overlay

### Phase 4: Monitoring (1-2 hours)
- [ ] Set up Firebase Crashlytics
- [ ] Implement production monitor
- [ ] Add frame timing callbacks
- [ ] Create performance dashboard
- [ ] Generate actionable insights

### Phase 5: Testing & Optimization (2 hours)
- [ ] Write performance tests
- [ ] Profile with DevTools
- [ ] Fix identified bottlenecks
- [ ] Validate <3s cold start
- [ ] Ensure 60fps scrolling

## 🎯 Success Metrics

### Critical Requirements
- ✅ Cold start <3 seconds (P95)
- ✅ 60fps during scroll
- ✅ Memory <150MB average
- ✅ Cache hit rate >80%
- ✅ No critical bottlenecks

### Monitoring Requirements
- ✅ P50/P95/P99 percentiles tracked
- ✅ Memory spikes detected
- ✅ Cache warming measured
- ✅ Actionable insights generated
- ✅ Crashlytics integration active

### Code Quality
- ✅ 80% test coverage
- ✅ No memory leaks
- ✅ Proper error handling
- ✅ Clean architecture
- ✅ Documentation complete

## 📚 References

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod Architecture Guide](https://riverpod.dev/docs/concepts/reading)
- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mon)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)
- Project Documentation: `docs/NAVIGATION/INDEX.md`

---

**Next Steps**:
1. Review and approve this design
2. Create implementation plan with superpowers:writing-plans
3. Set up git worktree for development
4. Begin Phase 1 implementation

This design addresses all 5 critical requirements:
- ✅ Cache warm tracking (CacheWarmTracker class)
- ✅ P50/P95/P99 percentiles (RepositoryMetrics.getLatencyPercentiles())
- ✅ Memory spike detection (MemoryMonitor.detectSpikes())
- ✅ Actionable insights (ActionableInsights with immediate fixes)
- ✅ Crashlytics for prod monitoring (ProductionPerformanceMonitor)