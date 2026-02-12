# Performance Optimization - Code Examples

## PRIORITY 1: Timer Updates con Stream Pattern

### File: `unified_timer_provider.dart`

**CURRENT PROBLEM**:
```dart
void _onTick() {
  // Every tick updates entire state -> triggers all listeners
  state = state!.copyWith(
    remainingSeconds: newRemainingSeconds,
  );
}
```

**OPTIMIZED SOLUTION**:
```dart
class UnifiedTimerProvider extends Notifier<UnifiedTimerState?> {
  // NEW: ValueNotifier for high-frequency updates
  final ValueNotifier<int> remainingSecondsNotifier = ValueNotifier<int>(0);
  
  // NEW: Stream controller for timer ticks
  final _tickStreamController = StreamController<int>.broadcast();
  Stream<int> get tickStream => _tickStreamController.stream;
  
  void _onTick() {
    if (state?.isActive != true) return;
    
    final newRemainingSeconds = _calculateRemainingSeconds(DateTime.now());
    
    // OPTIMIZATION: Update ValueNotifier instead of state
    // This notifies ONLY widgets using ValueListenableBuilder
    remainingSecondsNotifier.value = newRemainingSeconds;
    
    // Emit to stream (for StreamBuilder consumers)
    _tickStreamController.add(newRemainingSeconds);
    
    // CRITICAL: Update state ONLY when important changes happen
    // (status change, completion, pause, etc)
    if (newRemainingSeconds == 0) {
      state = state!.copyWith(
        status: TimerStatus.completed,
        remainingSeconds: 0,
      );
    }
  }
  
  @override
  void dispose() {
    remainingSecondsNotifier.dispose();
    _tickStreamController.close();
    super.dispose();
  }
}
```

### File: `header_rest_timer.dart`

**CURRENT (10 separate watches)**:
```dart
final isTimerActive = ref.watch(
  unifiedTimerProvider.select((state) => state != null),
);
final isIdle = ref.watch(
  unifiedTimerProvider.select((state) => state == null || state.isIdle),
);
final isRunning = ref.watch(
  unifiedTimerProvider.select((state) => state?.isActive ?? false),
);
// ... 7 more watches
```

**OPTIMIZED (Consolidated state + StreamBuilder)**:
```dart
// 1. Consolidate related state into single watch
final timerState = ref.watch(
  unifiedTimerProvider.select((state) => state == null ? null : (
    isActive: state.isActive,
    isPaused: state.isPaused,
    isCompleted: state.isCompleted,
    type: state.type,
  )),
);

// 2. Use StreamBuilder for high-frequency updates (remainingSeconds)
@override
Widget build(BuildContext context) {
  final notifier = ref.read(unifiedTimerProvider.notifier);
  
  return RepaintBoundary(
    child: StreamBuilder<int>(
      stream: notifier.tickStream,
      initialData: timerState?.remainingSeconds ?? 0,
      builder: (context, snapshot) {
        final remainingSeconds = snapshot.data ?? 0;
        
        // Widget rebuilds ONLY for remainingSeconds changes
        // Other state changes don't trigger this builder
        return _buildTimerUI(remainingSeconds, timerState);
      },
    ),
  );
}
```

### File: `workout_mini_bar.dart`

**CURRENT (Local timer + setState)**:
```dart
class _WorkoutMiniBarState extends State<WorkoutMiniBar> {
  Timer? _timerUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {}); // REBUILDS ENTIRE WIDGET
    });
  }
}
```

**OPTIMIZED (ValueListenableBuilder)**:
```dart
class _WorkoutMiniBarState extends ConsumerState<WorkoutMiniBar> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(unifiedTimerProvider.notifier);
    
    return ValueListenableBuilder<int>(
      valueListenable: notifier.remainingSecondsNotifier,
      builder: (context, remainingSeconds, child) {
        // Rebuilds ONLY this widget when seconds change
        return Text(_formatTime(remainingSeconds));
      },
    );
  }
  
  // NO initState, NO Timer, NO dispose needed!
}
```

**Impact**: Riduce timer update overhead da ~60 full rebuilds/min a ~4/min (solo per status change)

---

## PRIORITY 2: List Rendering Optimization

### File: `exercise_list_item_orchestrator.dart`

**CURRENT PROBLEM**:
```dart
class _ExerciseListItemState extends ConsumerState<ExerciseListItem>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Keeps ALL items in memory
  
  // 9+ ref.watch calls
  final config = ref.watch(appConfigProvider);
  final isExpanded = ref.watch(exerciseExpansionProvider(widget.exercise.id));
  // ... etc
}
```

**OPTIMIZED SOLUTION**:

1. **Remove AutomaticKeepAlive** (let Flutter dispose offscreen items):
```dart
class _ExerciseListItemState extends ConsumerState<ExerciseListItem> {
  // REMOVED: AutomaticKeepAliveClientMixin
  
  // Cache expensive data at provider level, not widget level
  ExerciseActivity? _lastActivity;
  
  @override
  void initState() {
    super.initState();
    // Load cached data from provider (fast)
    _loadCachedActivity();
  }
  
  Future<void> _loadCachedActivity() async {
    // Provider-level cache (singleton, survives widget dispose)
    final cache = ref.read(exerciseDataCacheProvider);
    _lastActivity = await cache.getActivity(widget.exercise.id);
  }
}
```

2. **Consolidate ref.watch() with .select()**:
```dart
@override
Widget build(BuildContext context) {
  // BEFORE: 9 separate watches
  // final config = ref.watch(appConfigProvider);
  // final autoCollapse = config.autoCollapseCompleted;
  // final showCountdown = config.showCollapseCountdown;
  // ... etc
  
  // AFTER: 1 consolidated watch
  final uiConfig = ref.watch(
    appConfigProvider.select((c) => (
      autoCollapse: c.autoCollapseCompleted ?? false,
      showCountdown: c.showCollapseCountdown ?? false,
      autoAdjustRest: c.autoAdjustRestFromRpe ?? false,
      isProMode: c.isProMode ?? false,
    )),
  );
  
  // Expansion state (separate because updated frequently)
  final isExpanded = ref.watch(
    exerciseExpansionProvider(widget.exercise.id)
      .select((state) => state.isExpanded),
  );
}
```

3. **Lazy load GIF** (load only when expanded):
```dart
Widget _buildHeader() {
  return ExerciseListItemHeader(
    // Pass null if collapsed -> no GIF loaded
    gifUrl: isExpanded ? widget.exercise.gifUrl : null,
    exerciseName: widget.exercise.name,
  );
}
```

### File: `workout_view.dart`

**CURRENT**:
```dart
Widget _buildNormalList(BuildContext context, WidgetRef ref) {
  return MaterialScrollList(
    itemCount: widget.workout.exercises.length,
    itemBuilder: (context, index) {
      return RepaintBoundary(
        child: ExerciseListItem(...),
      );
    },
  );
}
```

**OPTIMIZED** (add caching hints):
```dart
Widget _buildNormalList(BuildContext context, WidgetRef ref) {
  return ListView.builder(
    itemCount: widget.workout.exercises.length,
    // OPTIMIZATION: Disable automatic keep alive
    // Let Flutter dispose offscreen items
    addAutomaticKeepAlives: false,
    // OPTIMIZATION: Reuse render objects when possible
    addRepaintBoundaries: true,
    // OPTIMIZATION: If item height is fixed, specify it
    // (skips expensive layout calculation)
    itemExtent: _isFixedHeight ? 120.0 : null,
    itemBuilder: (context, index) {
      final exercise = widget.workout.exercises[index];
      return RepaintBoundary(
        child: ExerciseListItem(
          key: ValueKey(exercise.id), // Reuse widget when reordered
          exercise: exercise,
          ...
        ),
      );
    },
  );
}
```

---

## PRIORITY 3: GIF Animation Optimization

### File: `exercise_gif_widget.dart`

**CURRENT PROBLEM**:
```dart
void _startAnimation() {
  _animationTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
    if (mounted) {
      setState(() {
        _currentFrame = (_currentFrame + 1) % 2;
      });
    }
  });
}
```

**OPTIMIZED SOLUTION**:

1. **Use AnimationController** (Flutter-native, more efficient):
```dart
class _ExerciseGifWidgetState extends State<ExerciseGifWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600), // 0.8s per frame
    )..addListener(() {
      // Update frame only at 0.0 and 0.5 progress
      final newFrame = (_controller.value * 2).floor() % 2;
      if (newFrame != _currentFrame) {
        setState(() => _currentFrame = newFrame);
      }
    });
    
    if (_isTwoFrameAnimation) {
      _controller.repeat();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

2. **Pause animation when offscreen** (Visibility + IntersectionObserver pattern):
```dart
import 'package:visibility_detector/visibility_detector.dart';

@override
Widget build(BuildContext context) {
  return VisibilityDetector(
    key: Key('gif_${widget.exercise.id}'),
    onVisibilityChanged: (info) {
      if (info.visibleFraction > 0.1) {
        // Item is visible -> resume animation
        _controller.repeat();
      } else {
        // Item is offscreen -> pause to save CPU
        _controller.stop();
      }
    },
    child: _buildGifImage(),
  );
}
```

3. **Add RepaintBoundary** (isolate from parent rebuilds):
```dart
@override
Widget build(BuildContext context) {
  return RepaintBoundary(
    child: GestureDetector(
      onTap: () => _showFullscreen(context),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: CachedNetworkImage(
          key: ValueKey(currentUrl),
          imageUrl: currentUrl,
          cacheManager: GifCacheManager.instance,
        ),
      ),
    ),
  );
}
```

---

## PRIORITY 4: Provider Watch Batch Conversion

**Script per trovare candidate**:
```bash
# Find all ref.watch without .select
grep -rn "ref\.watch(" lib/features/workout/presentation/widgets \
  --include="*.dart" | \
  grep -v "\.select" | \
  grep -v "// ignore" > /tmp/watch_candidates.txt

# Count per file
grep -rn "ref\.watch(" lib/features/workout/presentation/widgets \
  --include="*.dart" | \
  grep -v "\.select" | \
  cut -d: -f1 | \
  sort | \
  uniq -c | \
  sort -rn | \
  head -20
```

**Conversion Pattern**:
```dart
// PATTERN 1: Single field access
// BEFORE
final config = ref.watch(appConfigProvider);
if (config.showTimer) { ... }

// AFTER
final showTimer = ref.watch(appConfigProvider.select((c) => c.showTimer));
if (showTimer) { ... }

// PATTERN 2: Multiple fields from same provider
// BEFORE
final config = ref.watch(appConfigProvider);
final a = config.fieldA;
final b = config.fieldB;
final c = config.fieldC;

// AFTER
final (a, b, c) = ref.watch(
  appConfigProvider.select((c) => (c.fieldA, c.fieldB, c.fieldC)),
);

// PATTERN 3: Nested object access
// BEFORE
final workout = ref.watch(currentWorkoutProvider);
final exerciseCount = workout?.exercises.length ?? 0;

// AFTER
final exerciseCount = ref.watch(
  currentWorkoutProvider.select((w) => w?.exercises.length ?? 0),
);
```

---

## PRIORITY 5: RegExp Caching

### File: `input_validator.dart`

**CURRENT**:
```dart
class InputValidator {
  static bool isValidEmail(String email) {
    // Compiles RegExp EVERY call
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
```

**OPTIMIZED**:
```dart
class InputValidator {
  // Compile ONCE, reuse forever
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
  static final _nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}$');
  
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }
}
```

---

## Rebuild Counter Utility (for debugging)

Add to any widget to track rebuild frequency:
```dart
class _MyWidgetState extends State<MyWidget> {
  static int _buildCount = 0;
  
  @override
  Widget build(BuildContext context) {
    _buildCount++;
    if (kDebugMode && _buildCount % 10 == 0) {
      debugPrint('🔄 [MyWidget] Rebuild #$_buildCount');
    }
    
    return Container(...);
  }
}
```

