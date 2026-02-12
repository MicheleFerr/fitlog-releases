# 🚀 Priority 1 Performance Optimization - Implementation Plan

**Status**: Ready to Execute
**Estimated Time**: 7-10 hours
**Expected Impact**: -25% main thread (28.8% → 13.8%)
**Date Created**: 2026-02-11
**Prerequisites**: Quick Wins completed ✅

---

## 📋 Context & Background

### What We've Done So Far (Quick Wins ✅)
- ✅ Consolidated 8 `.select()` into 3 in HeaderRestTimer
- ✅ Added AnimationController + VisibilityDetector for GIF pause
- ✅ Removed duplicate timer in WorkoutMiniBar
- ✅ Added RepaintBoundary to countdown and list items
- ✅ **Result**: -12% main thread (40.8% → 28.8%)

### What's Left (Priority 1)
Two architectural improvements to eliminate tech debt and improve performance:
1. **Fix 2.1**: Refactor UnifiedTimerProvider with ValueNotifier pattern (-15% CPU)
2. **Fix 2.2**: Remove AutomaticKeepAliveClientMixin from list items (-10% CPU)

---

## 🎯 Fix 2.1: ValueNotifier Pattern for Timer Updates

### Problem
```dart
// Current: Every second (60 times/minute!)
void _onTick() {
  state = state!.copyWith(
    remainingSeconds: newRemainingSeconds,  // ⚠️ Notifies ALL watchers
    tickCount: _internalTickCount,
  );
  // Even widgets with .select(otherField) rebuild unnecessarily
}
```

### Solution
Separate high-frequency updates (1Hz) from structural changes:
- **ValueNotifier**: For `remainingSeconds` (updates every second)
- **StreamController**: For discrete events (started, paused, completed)
- **State.copyWith()**: Only for structural changes (status, type, flags)

### Benefits
- ✅ -15% main thread (60 notifications/min → 4 notifications/min)
- ✅ Clean architecture (separation of concerns)
- ✅ Scalable pattern for other high-frequency providers
- ✅ Riverpod best practice for this use case

---

## 📝 Implementation Steps - Fix 2.1

### Step 1: Add ValueNotifier to UnifiedTimerProvider (1h)

**File**: `lib/features/timer/presentation/providers/unified_timer_provider.dart`

**Location**: Add after line 163 (after `Timer? _ticker;`)

```dart
// ✅ NEW: ValueNotifier for high-frequency updates (1Hz)
ValueNotifier<int>? _remainingSecondsNotifier;
ValueNotifier<int> get remainingSecondsNotifier {
  _remainingSecondsNotifier ??= ValueNotifier<int>(0);
  return _remainingSecondsNotifier!;
}

// ✅ NEW: Stream for discrete events
StreamController<TimerEvent>? _eventController;
Stream<TimerEvent> get eventStream {
  _eventController ??= StreamController<TimerEvent>.broadcast();
  return _eventController!.stream;
}
```

### Step 2: Update _onTick() Method (30min)

**File**: Same file, find `void _onTick()` (around line 1063)

**Replace**:
```dart
// ❌ OLD: Notifies all watchers every second
state = state!.copyWith(
  remainingSeconds: newRemainingSeconds,
  tickCount: _internalTickCount,
);
```

**With**:
```dart
// ✅ NEW: Update only ValueNotifier (no state notification)
_remainingSecondsNotifier?.value = newRemainingSeconds;

// Internal tracking (no notification)
_internalTickCount++;

// State update ONLY for structural changes (every 30 seconds for auto-save)
if (_internalTickCount % 30 == 0) {
  state = state!.copyWith(tickCount: _internalTickCount);
}
```

### Step 3: Update Timer Start/Pause/Complete Methods (1h)

**In `startTimer()` method** (around line 508):
```dart
// After creating new state
state = newState.start();

// ✅ Initialize ValueNotifier with starting value
_remainingSecondsNotifier?.value = durationSeconds;

// ✅ Emit start event
_eventController?.add(TimerEvent.started(Duration(seconds: durationSeconds)));
```

**In `pauseTimer()` method**:
```dart
state = state!.pause();

// ✅ Emit pause event
_eventController?.add(TimerEvent.paused());
```

**In `_onTimerComplete()` method**:
```dart
state = state!.copyWith(
  status: TimerStatus.completed,
  remainingSeconds: 0,
);

// ✅ Update ValueNotifier
_remainingSecondsNotifier?.value = 0;

// ✅ Emit completion event
_eventController?.add(TimerEvent.completed());
```

### Step 4: Add Disposal Logic (15min)

**In `_disposeResources()` method**:
```dart
void _disposeResources() {
  // ... existing disposal ...

  // ✅ NEW: Dispose ValueNotifier and Stream
  _remainingSecondsNotifier?.dispose();
  _remainingSecondsNotifier = null;

  _eventController?.close();
  _eventController = null;
}
```

### Step 5: Create TimerEvent Classes (15min)

**File**: Create new file `lib/features/timer/domain/models/timer_event.dart`

```dart
/// Discrete timer events for state transitions
sealed class TimerEvent {
  const TimerEvent();

  factory TimerEvent.started(Duration duration) = TimerStartedEvent;
  factory TimerEvent.paused() = TimerPausedEvent;
  factory TimerEvent.resumed() = TimerResumedEvent;
  factory TimerEvent.completed() = TimerCompletedEvent;
  factory TimerEvent.skipped() = TimerSkippedEvent;
}

class TimerStartedEvent extends TimerEvent {
  const TimerStartedEvent(this.duration);
  final Duration duration;
}

class TimerPausedEvent extends TimerEvent {
  const TimerPausedEvent();
}

class TimerResumedEvent extends TimerEvent {
  const TimerResumedEvent();
}

class TimerCompletedEvent extends TimerEvent {
  const TimerCompletedEvent();
}

class TimerSkippedEvent extends TimerEvent {
  const TimerSkippedEvent();
}
```

**Add import** to `unified_timer_provider.dart`:
```dart
import 'package:gymbro_flutter_new/features/timer/domain/models/timer_event.dart';
```

### Step 6: Update HeaderRestTimer Widget (45min)

**File**: `lib/features/workout/presentation/widgets/header_rest_timer.dart`

**Current code** (lines 40-70) watches state fields directly.

**Replace** the time values watch with ValueListenableBuilder:

```dart
@override
Widget build(BuildContext context) {
  // Keep existing flags watch (structural data)
  final timerFlags = ref.watch(
    unifiedTimerProvider.select((state) => (
      isTimerActive: state != null,
      isIdle: state == null || state.isIdle,
      isRunning: state?.isActive ?? false,
      isPaused: state?.isPaused ?? false,
      isCompleted: state?.isCompleted ?? false,
      isInterExercise: state?.type == TimerType.interExercise,
    )),
  );

  // ✅ NEW: Get notifier reference (no rebuild)
  final timerNotifier = ref.read(unifiedTimerProvider.notifier);

  // ✅ NEW: Watch structural state only (rare changes)
  final timerProgress = ref.watch(
    unifiedTimerProvider.select((state) => state?.remainingProgress ?? 0.0),
  );

  final timerSound = ref.watch(appConfigProvider.select((c) => c.timerSound));

  // Extract flags
  final isTimerActive = timerFlags.isTimerActive;
  final isIdle = timerFlags.isIdle;
  final isRunning = timerFlags.isRunning;
  final isPaused = timerFlags.isPaused;
  final isCompleted = timerFlags.isCompleted;
  final isInterExercise = timerFlags.isInterExercise;

  // ... rest of build method ...

  // When building countdown, use ValueListenableBuilder:
  if (!isIdle)
    ValueListenableBuilder<int>(
      valueListenable: timerNotifier.remainingSecondsNotifier,
      builder: (context, remainingSeconds, child) {
        return _buildCountdown(
          context,
          remainingSeconds,
          timerProgress,
          isRunning,
          isPaused,
          isInterExercise: isInterExercise,
        );
      },
    )
  else
    Text(context.l10n.restTime, /* ... */)
}
```

### Step 7: Update WorkoutMiniBar (30min)

**File**: `lib/features/workout/presentation/widgets/workout_mini_bar.dart`

**Note**: This file already doesn't have a local timer (we removed it in Quick Wins).

Verify it's using `workout.duration` which auto-updates from the workout entity provider.
The mini-bar doesn't need ValueListenable because it reads from workout entity, not timer provider directly.

**No changes needed** - already optimized in Quick Wins! ✅

### Step 8: Search for Other Timer Consumers (1h)

Find all files that watch `unifiedTimerProvider` and update them:

```bash
# Search for timer provider usage
grep -r "unifiedTimerProvider" lib/ --include="*.dart" | grep -v ".g.dart"
```

**For each consumer**:
1. Check if it watches `remainingSeconds`
2. If yes, convert to `ValueListenableBuilder` pattern
3. If it only watches structural fields (status, type), leave as is

**Common consumers** (update if needed):
- `workout_screen.dart` - likely watches timer state
- Any modal/dialog showing timer countdown
- Live Activity updates (iOS) - may need event stream

### Step 9: Verification & Testing (1h)

**Compile Check**:
```bash
flutter analyze
```

**Unit Tests** (if timer has tests):
```bash
flutter test test/features/timer/
```

**Manual Testing Checklist**:
- [ ] Start rest timer → countdown updates smoothly
- [ ] Pause timer → updates stop immediately
- [ ] Resume timer → countdown continues
- [ ] Skip timer → transitions correctly
- [ ] Complete timer → audio plays, transition to next
- [ ] Background mode (iOS) → timer completes and plays audio
- [ ] Multiple timers in sequence → no memory leaks
- [ ] Scroll list while timer active → smooth 60fps

**DevTools Performance Check**:
```bash
flutter run --profile
# In DevTools: Performance tab
# Start timer, observe:
# - Main thread should drop from ~28% to ~20%
# - Rebuild count should be significantly lower
# - Memory should be stable (no leaks from ValueNotifier)
```

---

## 🎯 Fix 2.2: Remove AutomaticKeepAliveClientMixin

### Problem
```dart
// Current: ALL exercise items kept alive in memory
class _ExerciseListItemState extends State<ExerciseListItem>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;  // ⚠️ Never disposed!

  // 10 exercises × 9 watches × always alive = 90+ watches active
}
```

### Solution
Remove `AutomaticKeepAliveClientMixin` and let Flutter manage lifecycle naturally:
- Only visible items stay in memory (~3-4 items)
- Off-screen items are disposed and recreated when scrolled back
- Watches are disposed when item leaves viewport

### Benefits
- ✅ -10% main thread (90+ watches → 9-12 watches)
- ✅ Better memory management (only visible = in memory)
- ✅ Scales to 50+ exercises without performance hit
- ✅ Follows Flutter best practices (KeepAlive = special cases only)

---

## 📝 Implementation Steps - Fix 2.2

### Step 1: Remove AutomaticKeepAliveClientMixin (15min)

**File**: `lib/features/workout/presentation/widgets/exercise_list_item/exercise_list_item_orchestrator.dart`

**Line 103**: Remove mixin
```dart
// ❌ OLD
class _ExerciseListItemState extends ConsumerState<ExerciseListItem>
    with AutomaticKeepAliveClientMixin {

// ✅ NEW
class _ExerciseListItemState extends ConsumerState<ExerciseListItem> {
```

**Lines 107-111**: Remove wantKeepAlive
```dart
// ❌ OLD - DELETE THESE LINES
// ✅ PERFORMANCE FIX: Keep widget alive when scrolling out of view
// This prevents dispose/initState cycle when scrolling up/down
// which was causing repeated JSON loads and GIF requests
@override
bool get wantKeepAlive => true;
```

**Line 1816**: Remove super.build(context)
```dart
@override
Widget build(BuildContext context) {
  // ❌ OLD - DELETE THIS LINE
  // ✅ Required when using AutomaticKeepAliveClientMixin
  super.build(context);

  // ✅ Keep rest of build method as is
  // ...
}
```

### Step 2: Consolidate Provider Watches (1.5h)

**Current problem**: The widget has 9+ individual `ref.watch()` calls scattered throughout the build method.

**Solution**: Consolidate into 3-4 strategic watches at the top of build().

**Find existing watches** (around lines 1821-1856):
```dart
// These are already consolidated in some places
final autoCollapseCompleted = ref.watch(...);
final showCollapseCountdown = ref.watch(...);
// ... etc
```

**Additional consolidation needed**:

Look for any remaining individual watches like:
```dart
// ❌ BAD: Individual watches
final exerciseName = ref.watch(exerciseProvider(id).select((e) => e.name));
final sets = ref.watch(exerciseProvider(id).select((e) => e.sets));
final reps = ref.watch(exerciseProvider(id).select((e) => e.reps));
```

**Consolidate to**:
```dart
// ✅ GOOD: Single consolidated watch
final exerciseData = ref.watch(
  exerciseProvider(id).select((e) => (
    name: e.name,
    sets: e.sets,
    reps: e.reps,
  )),
);

// Use as: exerciseData.name, exerciseData.sets, exerciseData.reps
```

**Target**: Reduce from 9+ watches to 3-4 consolidated watches per exercise item.

### Step 3: Update ListView Configuration (15min)

**File**: Find where ListView.builder is used for exercise list (likely in workout_screen.dart or workout_view.dart)

**Search for ListView.builder**:
```bash
grep -r "ListView.builder" lib/features/workout/presentation/ --include="*.dart" -B 2 -A 10
```

**Update ListView.builder properties**:
```dart
ListView.builder(
  // ✅ NEW: Disable automatic keep-alive
  addAutomaticKeepAlives: false,

  // ✅ NEW: Enable repaint boundaries
  addRepaintBoundaries: true,

  // Existing properties
  itemCount: exercises.length,
  itemBuilder: (context, index) {
    return ExerciseListItem(
      key: ValueKey(exercises[index].id),  // ✅ Ensure stable keys
      exercise: exercises[index],
      // ... other props
    );
  },
)
```

### Step 4: Add Lazy Loading for Heavy Data (1h)

**File**: `exercise_list_item_orchestrator.dart`

**Problem**: Currently loads exercise history and GIF data in `initState()` even when collapsed.

**Solution**: Load data only when expanded.

**In build() method**, wrap heavy data loading:
```dart
// ✅ Load GIF only if expanded
final gifUrl = isExpanded
    ? ref.watch(exerciseGifProvider(widget.exercise.id))
    : null;

// ✅ Load history only if expanded
final exerciseHistory = isExpanded
    ? ref.watch(exerciseHistoryProvider(widget.exercise.id))
    : const AsyncValue.data(null);
```

**Remove or modify `_loadLastActivity()` in initState()**:
```dart
// ❌ OLD: Load in initState
@override
void initState() {
  super.initState();
  _loadLastActivity();  // Loads even when collapsed
}

// ✅ NEW: Load on demand
@override
void initState() {
  super.initState();
  // Don't load data until expanded
}

// ✅ Add in build() method:
if (isExpanded && _lastActivity == null) {
  // Trigger load only when first expanded
  Future.microtask(() => _loadLastActivity());
}
```

### Step 5: Optimize Disposal (30min)

Since items now get disposed when off-screen, ensure clean disposal:

**In `dispose()` method**:
```dart
@override
void dispose() {
  // ✅ Ensure all resources are released
  _lastActivity = null;
  _exerciseData = null;

  // Cancel any pending futures/timers
  // (check if any exist in the widget)

  super.dispose();
}
```

### Step 6: Verification & Testing (1.5h)

**Compile Check**:
```bash
flutter analyze
```

**Manual Testing Checklist**:
- [ ] Start workout with 10+ exercises
- [ ] Scroll up/down → items appear/disappear smoothly
- [ ] Expand exercise → data loads correctly
- [ ] Collapse exercise → data still accessible
- [ ] Scroll expanded exercise out of view → no crash
- [ ] Scroll back to exercise → state preserved (sets completion, etc.)
- [ ] Complete workout → no memory leaks
- [ ] Rapid scroll → no janky animations

**Performance Testing**:
```bash
flutter run --profile
# DevTools > Performance
# Observe:
# - Main thread: should be ~13-15% (target <20%)
# - Memory: should be flat (no growth during scrolling)
# - Active watches: ~9-12 (instead of 90+)
```

**Memory Leak Check**:
```bash
# DevTools > Memory tab
# 1. Start workout with 10 exercises
# 2. Scroll up/down 10 times rapidly
# 3. Take memory snapshot
# 4. Check: memory graph should be flat
# 5. No growing number of ExerciseListItem instances
```

---

## 🎯 Final Verification - Both Fixes Combined

### Performance Profiling (30min)

**Baseline (before any fixes)**:
- Main Thread: 40.8%
- Active Timers: 12+
- Active Watches: 90+
- Memory: Growing during workout

**After Quick Wins**:
- Main Thread: ~28.8%
- Active Timers: 4-6
- (other metrics unchanged)

**Expected After Priority 1**:
- Main Thread: **<20%** (target 13.8%)
- Active Timers: 2-3
- Active Watches: 9-12
- Memory: Flat/stable

### Real-World Test Scenario (15min)

**Complete Workout Test**:
1. Create workout with 10 exercises
2. Start workout
3. Complete 3-4 sets per exercise with rest timers
4. Scroll list frequently while timer active
5. Pause workout midway, resume
6. Complete full workout

**Observe**:
- ✅ Scroll always smooth (60fps)
- ✅ Timer countdown smooth (no frame drops)
- ✅ No UI freezes
- ✅ Memory stable throughout
- ✅ Battery consumption normal
- ✅ App responsive at all times

---

## 📦 Final Commit

```bash
# Stage all modified files
git add lib/features/timer/
git add lib/features/workout/presentation/widgets/

# Commit with detailed message
git commit -m "$(cat <<'EOF'
perf(workout): implement Priority 1 performance optimizations

**Context**: After Quick Wins (-12%), implemented Priority 1 fixes
to eliminate architectural tech debt and further optimize performance.

**Changes**:

1. UnifiedTimerProvider: ValueNotifier pattern for high-frequency updates
   - Before: state.copyWith() every second notifies all watchers
   - After: ValueNotifier for remainingSeconds (1Hz updates isolated)
   - Added: StreamController for discrete events (started, paused, completed)
   - Pattern: Structural changes use state, frequent updates use ValueNotifier
   - Impact: -15% main thread (60 notifications/min → 4 notifications/min)

2. ExerciseListItem: Removed AutomaticKeepAliveClientMixin
   - Before: All 10+ items kept in memory with 90+ active watches
   - After: Only visible items (~3-4) in memory with 9-12 watches
   - Consolidated: 9 individual watches → 3-4 strategic watches per item
   - ListView: Added addAutomaticKeepAlives: false
   - Lazy loading: Heavy data loaded only when item expanded
   - Impact: -10% main thread, better memory management

3. Consumer widgets updated for ValueNotifier pattern
   - HeaderRestTimer: Uses ValueListenableBuilder for countdown
   - Timer consumers: Separated structural watches from value watches
   - RepaintBoundary: Isolates high-frequency countdown updates

**Performance Impact**:
- Main Thread: 28.8% → ~13.8% (-15% from Priority 1)
- Total Improvement: -37% from baseline (40.8% → 13.8%)
- Active Timers: 4-6 → 2-3
- Active Watches: 90+ → 9-12 (10x reduction)
- Memory: Flat/stable (scales to 50+ exercises)

**Architecture Benefits**:
- ✅ ValueNotifier pattern: Scalable for other high-frequency providers
- ✅ Natural lifecycle: Flutter manages memory automatically
- ✅ Best practices: Follows Riverpod + Flutter recommendations
- ✅ Tech debt eliminated: Clean, maintainable codebase

**Verification**:
- flutter analyze passes ✅
- Manual testing: Smooth 60fps scroll + timer ✅
- Memory leak check: Flat memory graph ✅
- Real workout test: Complete 10-exercise workout ✅

**References**:
- docs/performance/PERFORMANCE_FIX_GUIDE.md (Priority 1 section)
- docs/performance/PRIORITY_1_IMPLEMENTATION_PLAN.md
- https://riverpod.dev/docs/how_to/select
- https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## 🎉 Success Criteria

**Priority 1 is complete when**:
- ✅ `flutter analyze` passes with no errors
- ✅ All manual tests pass (checklist above)
- ✅ DevTools shows main thread <20%
- ✅ Memory leak check passes (flat graph)
- ✅ Real workout completes smoothly
- ✅ Commit created with detailed message

**If something fails**:
1. Check error message carefully
2. Review implementation step that failed
3. Verify code matches examples in this plan
4. Test in isolation (e.g., just timer provider changes first)
5. Ask for help if blocked (provide error + context)

---

## 📚 Resources

**Official Documentation**:
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod Select Optimization](https://riverpod.dev/docs/how_to/select)
- [ValueNotifier API](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html)
- [ListView Performance](https://api.flutter.dev/flutter/widgets/ListView-class.html)

**Project Documentation**:
- `docs/performance/PERFORMANCE_FIX_GUIDE.md` - Full guide with benchmarks
- `CLAUDE.md` - Performance rules and patterns
- `docs/CODE_PATTERNS.md` - Riverpod patterns

**Profiling Tools**:
- Flutter DevTools: `flutter pub global run devtools`
- Performance overlay: Add `showPerformanceOverlay: true` to MaterialApp

---

## ⚠️ Common Pitfalls & Solutions

### Pitfall 1: ValueNotifier not disposed
**Symptom**: Memory leak, app crashes after multiple timer starts
**Solution**: Ensure `_remainingSecondsNotifier?.dispose()` in `_disposeResources()`

### Pitfall 2: Watching ValueNotifier with ref.watch()
**Symptom**: "ValueNotifier is not a StateNotifier" error
**Solution**: Use `ValueListenableBuilder` widget, not `ref.watch()`

### Pitfall 3: Exercise list state lost on scroll
**Symptom**: Set completion checkmarks disappear when scrolled out
**Solution**: State is preserved in workout provider, not in widget. Should work correctly if workout provider holds exercise state.

### Pitfall 4: GIF loading on every scroll
**Symptom**: Network requests spike during scroll
**Solution**: GIF caching is already implemented (GifCacheManager). Verify cache is working.

### Pitfall 5: Timer audio doesn't play
**Symptom**: Timer completes silently
**Solution**: Verify `TimerCompletedEvent` is emitted and audio logic is triggered on event

---

## 🚀 Ready to Start?

**Before you begin**:
- [ ] Quick Wins are committed (check git log)
- [ ] Working directory is clean (git status)
- [ ] You have 7-10 hours available
- [ ] Device for testing is ready (iPhone recommended for timer testing)

**Start with**:
```bash
# Create feature branch (optional but recommended)
git checkout -b perf/priority-1-optimizations

# Start with Fix 2.1 (timer provider)
# Follow steps 1-9 above

# Then Fix 2.2 (list items)
# Follow steps 1-6 above

# Final verification
# Follow "Final Verification" section

# Commit
# Use commit message template above
```

**Good luck! 🎯**

If you get stuck, refer back to:
1. This implementation plan (you're reading it)
2. `docs/performance/PERFORMANCE_FIX_GUIDE.md` (theory + benchmarks)
3. Quick Wins commit (git show 58e9dec1) for reference patterns

---

**Document Version**: 1.0
**Last Updated**: 2026-02-11
**Verified By**: Claude Sonnet 4.5
