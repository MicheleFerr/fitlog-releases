---
name: systematic-debug
description: Systematic debugging framework for FitLog - RCA, isolation, tracing, verification. Use for complex or recurring bugs.
---

# Systematic Debug - FitLog Framework

**Use for:** Multi-layer bugs, intermittent issues, regressions, performance problems, iOS native bugs, data sync issues.
**NOT for:** Typos or obvious fixes (use flutter-debugger).

---

## Pre-Debug Checklist

Before investigating, answer ALL of these:

```
[ ] SYMPTOMS: What does the user see? (screenshot/video/logs)
[ ] LAYER: Which feature/layer? (workout/analytics/timer/live-activity/sync)
[ ] REPRODUCIBILITY: Always / intermittent / random?
[ ] CONTEXT: Device, OS, app version, user actions before bug
[ ] RECENT CHANGES: git log --since="1 week ago" --oneline -- lib/features/<area>/
[ ] PAST BUGS: Search episodic-memory for similar issues
```

---

## Phase 1: Isolation & Reproduction (30% of effort)

### 1.1 Reproduce Deterministically

Bug riproducibile = bug risolvibile.

```
[ ] Minimal steps to reproduce (A -> B -> C)
[ ] Preconditions (existing data, app state)
[ ] Expected vs Actual behavior
[ ] Screenshot/video if UI, stack trace if crash
```

| Bug Type | Reproduction Technique |
|----------|------------------------|
| Workout session | Fresh install -> create workout -> start session -> reproduce |
| Timer/LA | Background app -> foreground -> check Live Activity state |
| Analytics | Specific workout data -> open analytics -> check calculations |
| Firebase sync | Offline -> make changes -> go online -> verify sync |

### 1.2 Binary Search in Code

```
[ ] Disable half features (comments/flags)
[ ] Bug persists? Problem in active half
[ ] Bug gone? Problem in disabled half
[ ] Iterate until single module isolated
```

### 1.3 Git Bisect for Regressions

```bash
git bisect start
git bisect bad                    # Current version has bug
git bisect good <last-known-good> # Known working version
# Test each checkout, mark good/bad
git bisect reset                  # When done
```

---

## Phase 2: Root Cause Analysis (40% of effort)

### 2.1 Five Whys

```
BUG: [symptom]
|- Why? -> [immediate cause]
  |- Why? -> [underlying cause]
    |- Why? -> [deeper cause]
      |- Why? -> [system issue]
        |- Why? -> [ROOT CAUSE]
```

### 2.2 Fishbone Diagram (Multi-Factor Bugs)

When bug has multiple contributing factors, categorize: People/Human (race conditions), Process/Lifecycle (state management, disposal), Platform (iOS vs Android, native bridge), Data (Firestore sync, Hive cache), Code (provider/repository logic), Performance (rebuild, memory, async timing).

### 2.3 Layer Tracing

Follow data through: Presentation -> Domain -> Data -> External (Firestore/Hive/iOS Native). Add temporary `debugPrint` at each layer boundary with `[LAYER]` prefix. **Remove after fix.**

---

## Phase 3: Data Collection Tools

### 3.1 Flutter DevTools

```bash
flutter run --profile  # NOT debug, NOT release

# Temporary in main.dart (remove after):
debugProfileBuildsEnabled = true;
debugProfileBuildsEnabledUserWidgets = true;
```

**Checklist:**
```
[ ] Performance tab: Frames > 16ms = jank (red)
[ ] Widget Rebuild tab: Which widgets rebuild too often?
[ ] Memory tab: GC frequency, snapshot diff before/after action
[ ] Network tab: Firebase query count, duplicate requests, large payloads
```

### 3.2 Xcode Instruments (iOS Native)

Open `ios/Runner.xcworkspace` -> Product -> Profile (Cmd+I)

| Template | Use For |
|----------|---------|
| Allocations | Memory leaks, retain cycles |
| Time Profiler | CPU hotspots |
| Leaks | Automatic leak detection |
| Energy Log | Battery drain |

Filter by "FitLog" in Call Tree. Use "Mark Generation" for memory snapshots.

### 3.3 Firebase Console

```
[ ] Crashlytics: Recent crashes, device/OS patterns
[ ] Firestore Usage: Query patterns, timeouts
[ ] Performance Monitoring: Slow traces
```

### 3.4 Git Analysis

```bash
git log --follow -p -- lib/path/to/buggy_file.dart
git log --since="1 week ago" --oneline -- lib/features/<area>/
git log --all --grep="<keyword>" --oneline
git diff <good-commit> <bad-commit> -- lib/features/<area>/
```

---

## Phase 4: Solution Strategy

### Hotfix vs Structural Fix

| Criteria | Hotfix | Structural Fix |
|----------|--------|----------------|
| Impact | Critical, app unusable | Medium, workaround exists |
| Scope | 1-5 lines | 10+ files |
| Timeline | Hours | Days |
| Tests | Manual + smoke | Full TDD + integration |

**Rule:** During hotfix, do NOT refactor. Surgical change only.

### TDD for Bug Fixes

```
1. RED:   Write test that reproduces the bug (FAILS)
2. GREEN: Fix with minimum change (PASSES)
3. REFACTOR: Clean up while test still passes
4. COMMIT: Test + fix together
```

---

## Phase 5: Verification & Prevention

```
[ ] Bug no longer reproducible
[ ] Root cause documented (5 Whys or Fishbone)
[ ] Regression test written and passing
[ ] .claude/scripts/performance-check.sh lib/features/<area>/ (no new anti-patterns)
[ ] flutter analyze passes
[ ] Manual test on target device
[ ] Git commit with "Fixes #XXX" if applicable
[ ] ADR written if architectural decision was made (docs/ADR/)
```

Add linter rules to prevent recurrence: `cancel_subscriptions`, `close_sinks`, etc.

---

## FitLog-Specific Debug Patterns

### Pattern A: Riverpod State Issues

**Symptoms:** Widget not rebuilding, stale data, wrong state

```
[ ] ref.watch() vs ref.read() vs ref.listen() — correct usage?
[ ] AutoDispose vs keepAlive — appropriate for this resource?
[ ] ref.onDispose() — timers/streams cancelled?
[ ] .select() optimization — preventing unnecessary rebuilds?
[ ] state = newState mutation — correct pattern for provider type?
```

### Pattern B: Firebase Sync Issues

**Symptoms:** Data not saving, stale data, sync conflicts

```
[ ] Firestore rules — permission to write? Test in Rules Playground
[ ] Network connectivity — offline persistence enabled?
[ ] Batch size — under 500 operations?
[ ] Stream subscriptions — cancelled in ref.onDispose()?
[ ] DataSource pattern — not mixing Firestore calls in Provider?
```

**Key gotchas:**
- Enable persistence BEFORE any Firestore usage
- Do NOT `await` Firestore writes when offline (hangs forever) — use `.then()`
- Last-write-wins conflicts: use Transactions for critical updates

### Pattern C: iOS Live Activity Bugs

**Symptoms:** LA not updating, stuck on old data, not appearing

```
[ ] Entitlements: Push notification + background modes configured?
[ ] Swift bridge: Method channel communication working?
[ ] Update frequency: Not exceeding rate limits?
[ ] ActivityKit lifecycle: Activity started before update? .end() on completion?
[ ] iOS version: 16.1+ required, fallback for older?
```

### Pattern D: Timer Precision Issues

**Symptoms:** Timer drift, wrong duration, not stopping

```
[ ] Timer.periodic + Duration — correct usage?
[ ] Background execution — audio session (iOS) / foreground service (Android)?
[ ] timer?.cancel() in dispose — no orphaned timers?
[ ] UI updates — not setState() 60x/sec, using ValueNotifier/Riverpod?
[ ] System sleep — wakelock acquired during workout?
```

### Pattern E: Platform Channel (Flutter <-> Swift)

```
[ ] Type matching: Int vs Double, String vs Int
[ ] Null safety handling on both sides
[ ] Async completion handler called in all paths
[ ] Main thread not blocked
```

Debug with `debugPrint` on Flutter side and `print` on Swift side at channel boundaries.

---

## Golden Rules

```
1. REPRODUCE before touching code
   -> If not reproducible, not debuggable

2. ISOLATE to the minimum layer
   -> Presentation? Domain? Data? Native?

3. ROOT CAUSE, not symptoms
   -> 5 Whys to the architectural cause

4. MINIMAL FIX for hotfix
   -> Refactoring != Bug fixing

5. PREVENT with tests + linter + ADR
   -> Best bug is one never committed
```

---

Debugging is 20% fixing, 80% understanding. Take time to investigate properly.
