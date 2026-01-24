---
name: systematic-debug
description: Enterprise-grade debugging framework per FitLog - RCA metodico, distributed tracing, performance analysis. Use per QUALSIASI bug complesso o ricorrente.
---

# 🔬 Systematic Debug - FitLog Enterprise Framework

**Use questo skill per:**
- ✅ Bug complessi multi-layer (workout + timer + firebase)
- ✅ Bug intermittenti o timing-dependent
- ✅ Regressioni dopo deploy
- ✅ Performance issues (freeze, rebuild, memory)
- ✅ Bug iOS-specific (Live Activity, background, audio)
- ✅ Dati inconsistenti tra Hive/Firestore
- ❌ Typo o fix ovvi (usa flutter-debugger per quelli)

---

## 🎯 MANDATORY: Pre-Debug Checklist

**BEFORE investigating, Claude MUST create TodoWrite per OGNI item:**

```
☐ DESCRIVI sintomi osservabili (cosa vede l'utente?)
☐ IDENTIFICA feature/layer impattato (workout/analytics/timer/etc)
☐ VERIFICA riproducibilità (sempre/intermittente/random?)
☐ RACCOGLI context (device, OS, app version, user actions)
☐ CHECK git recent changes (git log --since="1 week ago" --oneline)
☐ SEARCH issue simili in episodic-memory o GitHub issues
```

**Why TodoWrite:** Debugging senza checklist = passi saltati = tempo sprecato.

---

## 🔭 Phase 0: Proactive Debugging (Prevention > Cure)

**PHILOSOPHY:** Catch bugs BEFORE they reach users

### Strategy 0.1: Observability Setup

```bash
# TodoWrite task: "Setup observability infrastructure"

# MONITORING STACK FOR FITLOG:
☐ Firebase Crashlytics (crashes)
☐ Firebase Performance Monitoring (slow screens)
☐ Sentry (error tracking + context)
☐ Firebase Analytics (user behavior)
☐ Custom metrics (workout completion rate, timer accuracy)

# KEY METRICS TO MONITOR:
┌──────────────────────────────────────────────────┐
│ Crash-free rate: Should be >99.5%               │
│ ANR rate: Should be <0.1% (Android)              │
│ Slow frames: Should be <1% of frames            │
│ API errors: Should be <0.5% of requests         │
│ Timer drift: Should be <100ms per hour          │
│ Workout completion: Should be >80%              │
└──────────────────────────────────────────────────┘

# ALERTS TO CONFIGURE:
☐ Email when crash rate >1% in 1 hour
☐ Slack when API error rate >5% in 15min
☐ PagerDuty when P0 bug affects >50% users

# CUSTOM ERROR BOUNDARY:
class FitLogErrorHandler {
  static void init() {
    FlutterError.onError = (details) {
      // Log to Crashlytics
      FirebaseCrashlytics.instance.recordFlutterError(details);

      // Add breadcrumbs
      Sentry.addBreadcrumb(Breadcrumb(
        message: 'Flutter Error: ${details.exception}',
        level: SentryLevel.error,
      ));

      // Log locally for debugging
      debugPrint('[ERROR] ${details.exception}\n${details.stack}');
    };

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
      return true;
    };
  }
}
```

### Strategy 0.2: Canary Deployments

```bash
# TodoWrite task: "Setup canary deployment pipeline"

# CONCEPT: Deploy to small % of users first, monitor, then rollout

# FITLOG CANARY STRATEGY:
Stage 1: Internal testing (1 user - you!)
  ↓ 24h monitoring
Stage 2: Beta group (10 users)
  ↓ 48h monitoring, crash rate <0.5%
Stage 3: 10% rollout (100 users)
  ↓ 72h monitoring, all metrics green
Stage 4: 50% rollout (500 users)
  ↓ 48h monitoring
Stage 5: 100% rollout (all users)

# ROLLBACK CRITERIA (auto or manual):
- Crash rate >2x baseline
- API error rate >3x baseline
- User reports >10 in 1 hour
- Memory leak detected (GC events spike)

# FIREBASE REMOTE CONFIG FOR FEATURE FLAGS:
const FeatureFlags = {
  'new_analytics_chart': false,  // Canary: enable for 10%
  'timer_v2': false,              // Testing internally
  'workout_ai_suggestions': true, // Fully rolled out
};

// In code:
if (RemoteConfig.instance.getBool('new_analytics_chart')) {
  return NewAnalyticsChart();
} else {
  return OldAnalyticsChart();
}
```

### Strategy 0.3: Automated Smoke Tests

```bash
# TodoWrite task: "Setup automated smoke test suite"

# SMOKE TESTS: Quick sanity checks after deploy

# test/smoke/critical_paths_test.dart
void main() {
  group('Critical User Paths', () {
    testWidgets('User can start and complete workout', (tester) async {
      await tester.pumpWidget(MyApp());

      // Navigate to workout
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      // Start workout
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Complete exercise
      await tester.tap(find.text('Complete Set'));
      await tester.pumpAndSettle();

      // Verify saved
      expect(find.text('Workout Saved'), findsOneWidget);
    });

    testWidgets('Analytics screen loads without crash', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    // More critical paths...
  });
}

# RUN IN CI/CD PIPELINE:
# .github/workflows/deploy.yml
- name: Run smoke tests
  run: flutter test test/smoke/
  timeout-minutes: 5

- name: Deploy only if smoke tests pass
  if: success()
  run: flutter build apk --release
```

### Strategy 0.4: Error Budget & SLOs

```bash
# TodoWrite task: "Define Service Level Objectives (SLOs)"

# ERROR BUDGET: 0.5% allowed downtime = 99.5% uptime SLO

# FITLOG SLOs (Service Level Objectives):
┌────────────────────────────────────────────────────┐
│ Availability: 99.5% (2.2h downtime/month allowed)  │
│ Crash-free sessions: 99.5%                         │
│ API latency p95: <500ms                            │
│ Screen load time p95: <1s                          │
│ Timer accuracy: ±100ms                             │
│ Data sync delay: <5s when online                   │
└────────────────────────────────────────────────────┘

# ERROR BUDGET TRACKING:
Week 1: 3 crashes (0.1% budget used) → GREEN
Week 2: 15 crashes (0.5% budget used) → YELLOW
Week 3: 25 crashes (1.0% budget EXCEEDED) → RED

# ACTIONS WHEN BUDGET EXCEEDED:
RED Status:
  - Freeze feature development
  - All hands on stability
  - Root cause analysis mandatory
  - Deploy fixes only

YELLOW Status:
  - Reduce feature velocity 50%
  - Extra code review scrutiny
  - Increase test coverage

GREEN Status:
  - Normal feature development
  - Invest in tech debt
```

**Proactive Debugging Resources:**
- [Observability Primer](https://opentelemetry.io/docs/concepts/observability-primer/)
- [Error Budget SRE](https://cloud.google.com/blog/products/devops-sre/sre-error-budgets-and-maintenance-windows)

---

## 📋 Phase 1: Isolation & Reproduction (30% effort)

### Step 1.1: Reproduce Deterministically

**Goal:** Bug riproducibile = bug risolvibile

```bash
# TodoWrite task: "Reproduce bug with precise steps"

# Checklist per reproduction:
☐ Minimal steps to reproduce (A → B → C)
☐ Preconditions (dati esistenti, stato app)
☐ Expected vs Actual behavior
☐ Screenshot/video se UI bug
☐ Logs/stack trace se crash
```

**FitLog-specific reproduction strategies:**

| Bug Type | Reproduction Technique |
|----------|------------------------|
| **Workout session** | Fresh install → create workout → start session → reproduce |
| **Timer/LA** | Background app → foreground → check Live Activity state |
| **Analytics** | Specific workout data → open analytics → check calculations |
| **Firebase sync** | Offline → make changes → go online → verify sync |

### Step 1.2: Binary Search in Code

**Goal:** Isolate al modulo/feature minimo

```bash
# TodoWrite task: "Binary search to isolate failing module"

# Strategy:
☐ Disable half features via feature flags/comments
☐ Bug persists? → Problem in active half
☐ Bug gone? → Problem in disabled half
☐ Iterate until single module isolated
```

**FitLog modules to test:**
```dart
// Esempio: Timer bug
lib/features/
├── workout/        # Bug here?
├── timer/          # Or here?
├── live_activity/  # Or native iOS?
└── analytics/      # Or data layer?
```

### Step 1.3: Git Bisect for Regressions

**Goal:** Find exact commit che ha introdotto il bug

```bash
# TodoWrite task: "Run git bisect to find regression commit"

git bisect start
git bisect bad                    # Current version has bug
git bisect good <last-known-good> # Known working version
# Git will checkout commits, test each:
# - flutter run → test bug → git bisect good/bad
git bisect reset                  # When done
```

**CRITICAL:** Save bisect results in TodoWrite notes!

---

## 🔍 Phase 2: Root Cause Analysis (40% effort)

### Step 2.1: 5 Whys Framework

**Goal:** Trace dal symptom alla root cause

```bash
# TodoWrite task: "Execute 5 Whys analysis"

# Template:
BUG: [describe symptom]
├─ Why? → [immediate cause]
  ├─ Why? → [underlying cause]
    ├─ Why? → [deeper cause]
      ├─ Why? → [root system issue]
        └─ Why? → [ROOT CAUSE - design/arch decision]
```

**Example - Timer bug:**
```
BUG: Timer continua dopo workout completato
├─ Why? → dispose() non chiamato
  ├─ Why? → Provider non disposed correttamente
    ├─ Why? → ref.onDispose() mancante
      ├─ Why? → Pattern non seguito in questo provider
        └─ ROOT: Manca linter rule per enforce dispose pattern
```

### Step 2.2: Fishbone Diagram (Multiple Causes)

**Use quando:** Bug ha fattori multipli (timing + data + UI)

```bash
# TodoWrite task: "Create Fishbone diagram for multi-factor bug"

# Categories FitLog:
┌─ People/Human: User actions, race conditions
├─ Process/Method: Lifecycle, state management
├─ Platform/Environment: iOS vs Android, native bridge
├─ Data/Database: Firestore sync, Hive cache
├─ Code/Method: Provider logic, repository pattern
└─ Performance: Rebuild, memory, async timing
```

### Step 2.3: Distributed Tracing (Multi-Layer Bugs)

**Goal:** Follow data flow attraverso layers

```bash
# TodoWrite task: "Trace bug through architecture layers"

# FitLog Clean Architecture layers:
Presentation (UI/Provider)
    ↓
Domain (Use Cases/Entities)
    ↓
Data (Repository/DataSource)
    ↓
External (Firestore/Hive/iOS Native)

# Add debug prints at EACH layer:
debugPrint('[PRESENTATION] WorkoutProvider.startTimer called');
debugPrint('[DOMAIN] StartTimerUseCase executing');
debugPrint('[DATA] TimerRepository.start with duration: $d');
debugPrint('[NATIVE] LiveActivityHandler.startTimer iOS call');
```

**IMPORTANT:** Remove debug prints dopo il fix!

---

## 🛠️ Phase 3: Data Collection Tools

### Tool 3.1: Flutter DevTools (Advanced)

```bash
# TodoWrite task: "Analyze with Flutter DevTools"

# CRITICAL: Use --profile mode, NOT debug!
flutter run --profile  # Optimized + observability

# Enable widget rebuild tracking:
# In main.dart (temporary, remove after debugging):
import 'package:flutter/rendering.dart';
void main() {
  debugProfileBuildsEnabled = true;        // Track ALL builds
  debugProfileBuildsEnabledUserWidgets = true; // Track user widgets only
  runApp(MyApp());
}

# Steps:
☐ Open DevTools → Performance tab
☐ Enable "Track Widget Builds" option
☐ Record session durante bug reproduction
☐ Analyze frame timeline:
   - Frames > 16ms = janky (red in timeline)
   - UI thread vs Raster thread time
   - Shader compilation jank (first run)

☐ Check Widget Rebuild tab:
   - Which widgets rebuild too often?
   - Unnecessary parent rebuilds?
   - Missing const constructors?

☐ Memory tab:
   - GC events frequency (too frequent = leak)
   - Snapshot diff (before/after action)
   - Retained objects after dispose

☐ Network tab:
   - Firebase query count/duration
   - Duplicate requests?
   - Large payloads (>100KB)?

# Performance Optimization Hints:
☐ Add RepaintBoundary for expensive widgets:
   RepaintBoundary(child: ExpensiveChart())

☐ Use ListView.builder for long lists (NOT ListView)

☐ Check DevTools "Frame analysis" tab for hints:
   - Expensive operations detected
   - Shader compilation warnings
   - Layout/paint bottlenecks
```

**Flutter DevTools Best Practices:**
- Use `--profile` mode (not debug, not release)
- Record 10-30 seconds max per session (context limit)
- Compare before/after optimization
- [Official guide](https://docs.flutter.dev/tools/devtools/performance)

### Tool 3.2: iOS Instruments (Native Bugs & Memory Leaks)

```bash
# TodoWrite task: "Profile with Xcode Instruments"

# SETUP:
☐ Open ios/Runner.xcworkspace in Xcode
☐ Product → Profile (⌘I) → Choose template:

# TEMPLATE SELECTION:
┌─────────────────────────────────────────────────────┐
│ Allocations → Memory leaks, retain cycles          │
│ Time Profiler → CPU hotspots, slow methods         │
│ Leaks → Automatic leak detection                   │
│ Network → API calls, Firebase queries              │
│ System Trace → Background tasks, thread activity   │
│ Energy Log → Battery drain analysis                │
└─────────────────────────────────────────────────────┘

# MEMORY LEAK DETECTION (iOS):
☐ Run Allocations + Leaks templates together
☐ Record session durante bug reproduction
☐ Look for:
   - Red leak indicators in timeline
   - Retain cycles (strong reference loops)
   - Abandoned memory (not leaked but not freed)

☐ Analyze leak stack trace:
   - Click leak → Call Tree → Invert
   - Find your code (FitLog classes)
   - Check for:
     * Closures capturing self strongly: { self.doSomething() }
     * Delegates not marked weak
     * NSTimer not invalidated
     * NotificationCenter observers not removed

# RETAIN CYCLE FIX PATTERN (Swift):
// ❌ Retain cycle:
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    self.updateUI()  // Strong reference to self!
}

// ✅ Break cycle:
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    guard let self = self else { return }
    self.updateUI()
}

# INSTRUMENTS PRO TIPS:
☐ Filter by "FitLog" module in Call Tree (hide system)
☐ Use "Mark Generation" to snapshot memory before/after
☐ Check "VM Tracker" for excessive memory regions
☐ Export .trace file for later analysis
```

**iOS Memory Debugging Resources:**
- [iOS Memory Leaks Detection](https://www.nimbleappgenie.com/blogs/what-are-ios-memory-leaks-how-to-detect-them/)
- [Xcode Instruments Guide](https://reintech.io/blog/debugging-profiling-ios-apps-optimal-performance)

### Tool 3.2b: Android Memory Profiler & LeakCanary

```bash
# TodoWrite task: "Detect memory leaks on Android"

# METHOD 1: Android Studio Memory Profiler
☐ Run app in debug mode
☐ Android Studio → Profiler → Memory
☐ Record session durante bug reproduction
☐ Manually trigger GC (garbage bin icon)
☐ Heap dump → Analyze retained objects
☐ Look for:
   - Activities/Fragments not GC'd after navigation
   - Static references holding contexts
   - Listeners/callbacks not unregistered

# METHOD 2: LeakCanary (Automatic Detection)
☐ Add to build.gradle (if not present):
   debugImplementation 'com.squareup.leakcanary:leakcanary-android:2.12'

☐ Run app in debug → LeakCanary auto-detects leaks
☐ Notification appears when leak detected
☐ Open LeakCanary app → View leak trace
☐ Analyze reference chain to root cause

# COMMON ANDROID LEAK PATTERNS:
// ❌ Leak: Static reference to Activity
class MyClass {
  static Activity activity; // NEVER do this!
}

// ✅ Fix: Use WeakReference or ApplicationContext
class MyClass {
  WeakReference<Activity> activityRef;
}

// ❌ Leak: Anonymous inner class in long-lived object
class WorkoutManager {
  Handler handler = new Handler() {
    @Override void handleMessage(Message msg) {
      // Implicitly holds WorkoutManager reference
    }
  };
}

// ✅ Fix: Static inner class + WeakReference
class WorkoutManager {
  static class MyHandler extends Handler {
    WeakReference<WorkoutManager> ref;
    MyHandler(WorkoutManager manager) { ref = new WeakReference<>(manager); }
  }
  Handler handler = new MyHandler(this);
}

# HEAP DUMP ANALYSIS:
☐ Capture heap dump in Memory Profiler
☐ Arrange by "Arrange by package" → find FitLog classes
☐ Check "Shallow Size" (direct memory) vs "Retained Size" (total)
☐ Look for duplicates (same class, many instances)
☐ Export to .hprof for deeper analysis (Eclipse MAT)
```

**Android Memory Resources:**
- [LeakCanary by Square](https://urancompany.com/blog/fix-memory-leaks-in-ios-and-android)
- [Memory Profiler Guide](https://developer.android.com/studio/profile/memory-profiler)

### Tool 3.3: Firebase Console + Crashlytics

```bash
# TodoWrite task: "Check Firebase logs and crash reports"

☐ Firebase Console → Crashlytics → Check recent crashes
☐ Firestore → Usage tab → Check query patterns
☐ Performance Monitoring → Check slow traces
☐ Look for patterns:
   - Spike in errors at specific time?
   - Specific device/OS versions?
   - Query timeout patterns?
```

### Tool 3.4: Git Analysis

```bash
# TodoWrite task: "Analyze git history for clues"

# Who modified this file recently?
git log --follow -p -- lib/path/to/buggy_file.dart

# What changed in this area last week?
git log --since="1 week ago" --oneline -- lib/features/workout/

# Find commits mentioning keywords:
git log --all --grep="timer" --grep="dispose" --oneline

# Compare with last known good version:
git diff <good-commit> <bad-commit> -- lib/features/timer/
```

### Tool 3.5: AI-Assisted Debugging (2025 Trend)

```bash
# TodoWrite task: "Leverage AI tools for debugging acceleration"

# TECHNIQUE 1: AI Log Analysis
☐ Collect logs from bug reproduction:
   flutter run --verbose > debug.log 2>&1

☐ Use Claude Code to analyze patterns:
   "Analyze this log for error patterns, correlate with recent deploys"

☐ AI identifies:
   - Error spike timestamps
   - Correlation with code changes
   - Common stack traces
   - Resource exhaustion patterns

# TECHNIQUE 2: AI-Powered Root Cause Analysis
☐ Provide AI with context:
   - Bug symptoms
   - Stack traces
   - Recent git commits (git log --since="1 week ago" -p)
   - Environment (iOS 17.2, Flutter 3.16, etc.)

☐ Ask AI to:
   - Generate hypotheses (5 Whys)
   - Suggest investigation steps
   - Identify similar resolved bugs
   - Recommend tools/techniques

# TECHNIQUE 3: AI Code Review for Bug Prevention
☐ Before committing fix, ask AI:
   "Review this fix for:
   - Potential side effects
   - Edge cases not covered
   - Performance implications
   - Test coverage gaps"

# TECHNIQUE 4: Episodic Memory Search
☐ Search past debugging sessions:
   Use episodic-memory MCP to find similar bugs solved before

☐ Query: "timer not stopping bug" or "Firebase sync conflict"

☐ Learn from past solutions instead of reinventing
```

**AI Debugging Best Practices:**
- Provide full context (don't just paste error)
- Ask for multiple hypotheses, not single answer
- Verify AI suggestions (don't blindly apply)
- Use AI to accelerate, not replace investigation
- [AI Debugging Techniques 2026](https://wearebrain.com/blog/10-effective-debugging-techniques-for-developers/)

### Tool 3.6: Distributed Tracing (OpenTelemetry Pattern)

```bash
# TodoWrite task: "Implement structured distributed tracing"

# CONCEPT: Track request flow across layers with Trace IDs

# MANUAL IMPLEMENTATION (for FitLog):
# Add trace_id to all log statements for correlation

# 1. Generate unique trace ID per operation
class TraceContext {
  static String current = '';

  static String generate() {
    current = Uuid().v4();
    return current;
  }
}

# 2. Pass trace_id through all layers
// Presentation
final traceId = TraceContext.generate();
debugPrint('[$traceId][PRESENTATION] Starting workout');

await workoutProvider.startWorkout(traceId);

// Provider
debugPrint('[$traceId][PROVIDER] Calling repository');
await repository.saveWorkout(workout, traceId);

// Repository
debugPrint('[$traceId][REPOSITORY] Firestore write');
await firestore.collection('workouts').add(workout);

// Result: All logs for this operation have same trace_id!
// Easy to filter: grep "abc-123-def" debug.log

# ADVANCED: OpenTelemetry Integration (Future)
☐ Add opentelemetry package (when available for Flutter)
☐ Instrument critical paths:
   - Workout start/end
   - Firebase sync operations
   - Timer lifecycle
   - Analytics calculations

☐ Export traces to backend (Jaeger/Zipkin)
☐ Visualize request flow with flamegraphs
```

**Distributed Tracing Benefits:**
- [Reduces debugging time from hours to minutes](https://www.multiplayer.app/observability-framework/distributed-tracing/)
- Find exact bottleneck in multi-layer systems
- Correlate logs across services/layers
- [OpenTelemetry Guide](https://opentelemetry.io/docs/concepts/observability-primer/)

### Tool 3.7: Test-Driven Debugging (TDD for Bugs)

```bash
# TodoWrite task: "Apply TDD methodology to debugging"

# PHILOSOPHY: Write test that FAILS before fixing bug
# This ensures:
# 1. Bug is actually reproducible in test
# 2. Fix actually solves the problem (test passes)
# 3. Regression prevention (test stays in suite)

# WORKFLOW:
# RED: Write test that fails (reproduces bug)
test('should cancel timer on workout completion', () {
  final provider = WorkoutProvider();
  provider.startTimer();

  provider.completeWorkout();

  // This FAILS before fix (timer still running)
  expect(provider.timer, isNull);
});

# Run test: flutter test → FAILS ✗

# GREEN: Fix the bug (minimum change)
class WorkoutProvider {
  void completeWorkout() {
    timer?.cancel();  // Add this line
    timer = null;
  }
}

# Run test: flutter test → PASSES ✓

# REFACTOR: Clean up if needed (while test still passes)
# - Better naming
# - Extract methods
# - Optimize performance

# Run test again: flutter test → Still PASSES ✓

# COMMIT: Test + fix together
git add test/ lib/
git commit -m "fix(workout): cancel timer on completion

- Added test to reproduce timer leak
- Fixed by adding timer.cancel() in completeWorkout()
- Prevents memory leak from orphaned timers"
```

**TDD Debugging Benefits:**
- Proves bug exists (not just assumption)
- Proves fix works (not just manual testing)
- Prevents regression (test catches future breaks)
- [Testing Best Practices](https://www.2am.tech/blog/software-development-best-practices)

---

## 💡 Phase 4: Solution Strategies

### Strategy 4.1: Hotfix vs Structural Fix

**Decision Matrix:**

| Criteria | Hotfix (Quick) | Structural Fix (Proper) |
|----------|----------------|--------------------------|
| **Impact** | 🔴 Critical (app unusable) | 🟡 Medium (workaround exists) |
| **Scope** | 1-5 lines changed | 10+ files, refactoring |
| **Risk** | Low (surgical change) | Medium (architecture change) |
| **Timeline** | Hours | Days/Weeks |
| **Tests** | Manual + smoke tests | Full TDD + integration |

**FitLog-specific hotfix pattern:**
```dart
// ✅ Hotfix: Add null check
if (workout?.exercises != null && workout!.exercises.isNotEmpty) {
  // ... existing logic ...
}

// ❌ DON'T do during hotfix:
// "Let me refactor the entire workout data model..."
```

### Strategy 4.2: Performance Optimization Pattern

**Use `.claude/scripts/performance-check.sh` BEFORE AND AFTER fix!**

```bash
# TodoWrite task: "Run performance check pre/post fix"

# Before fix:
.claude/scripts/performance-check.sh lib/features/<affected>/
# Save output

# Implement fix

# After fix:
.claude/scripts/performance-check.sh lib/features/<affected>/
# Compare: warnings reduced?
```

**Common FitLog performance anti-patterns:**
- ❌ `openBox()` inside loops → ✅ Open once, reuse
- ❌ Sequential `await` → ✅ `Future.wait()`
- ❌ `setState()` in build → ✅ Proper state management
- ❌ No `const` constructors → ✅ Add `const` where possible

### Strategy 4.3: iOS Native Bridge Bugs

**Pattern:** Flutter ↔ Swift communication issues

```bash
# TodoWrite task: "Debug platform channel communication"

# Flutter side:
debugPrint('[FLUTTER] Calling method channel: $methodName');
debugPrint('[FLUTTER] Arguments: $arguments');

# Swift side (ios/Runner/):
print("[SWIFT] Received call: \(call.method)")
print("[SWIFT] Arguments: \(call.arguments)")
```

**Common issues:**
- Type mismatch (Int vs Double, String vs Int)
- Missing null safety handling
- Async completion not called
- Main thread blocking

---

## ✅ Phase 5: Verification & Prevention

### Step 5.1: Regression Test Suite

```bash
# TodoWrite task: "Create regression test for this bug"

# Test structure:
test('should not crash when workout.exercises is null', () {
  // Arrange: Setup conditions that caused bug
  final workout = Workout(exercises: null);

  // Act: Execute the code that was buggy
  final result = workoutProvider.startSession(workout);

  // Assert: Verify fix works
  expect(result, isNotNull);
  expect(() => result, isNot(throwsException));
});
```

### Step 5.2: Linter Rules (Prevent Future Bugs)

```bash
# TodoWrite task: "Add linter rule if applicable"

# Example: Enforce dispose pattern
# analysis_options.yaml
linter:
  rules:
    - cancel_subscriptions  # Timer.cancel() in dispose
    - close_sinks           # StreamController.close()
    - always_use_package_imports
```

### Step 5.3: Documentation (ADR)

```bash
# TodoWrite task: "Document decision in ADR if architectural"

# Create docs/ADR/YYYYMMDD-<bug-title>.md if:
☐ Bug revealed design flaw
☐ Fix required architectural decision
☐ Trade-offs were considered
☐ Team should know rationale

# Template in docs/ADR/TEMPLATE.md
```

### Step 5.4: Post-Mortem Blameless

**Goal:** Learn, don't blame

```bash
# TodoWrite task: "Write post-mortem for critical bugs"

# Template:
## Incident Summary
- Date/Time: When discovered
- Duration: How long users impacted
- Severity: P0/P1/P2
- User Impact: N users affected, M reports

## Root Cause
- [From 5 Whys analysis]
- Contributing factors: [From Fishbone]

## Timeline
- T+0: Bug introduced (commit hash)
- T+X: Bug discovered (how? user report? monitoring?)
- T+Y: Investigation started
- T+Z: Fix deployed
- T+W: Verified resolved

## Resolution
- Immediate fix: [what was done]
- Long-term fix: [planned improvements]
- Preventive measures: [linter rules, tests, monitoring]

## Lessons Learned
- What went well?
  * Fast root cause identification
  * Good team collaboration
- What could improve?
  * Earlier detection (add monitoring)
  * Faster deployment pipeline
- Action items (with owners):
  * [@owner] Add linter rule by [date]
  * [@owner] Improve test coverage by [date]
  * [@owner] Update runbook by [date]

## Related Incidents
- Similar bugs in past: [links]
- Pattern across team: [if applicable]
```

### Step 5.5: Debugging Retrospectives (Team Learning)

**Goal:** Share knowledge, reduce time-to-resolution for recurring patterns

```bash
# TodoWrite task: "Schedule debugging retrospective session"

# WHAT: Monthly 1-hour team meeting to share interesting bugs

# FORMAT:
┌─────────────────────────────────────────────────────┐
│ 1. Each engineer shares 1 interesting bug (10min)  │
│    - What was the symptom?                          │
│    - How did you debug it?                          │
│    - What was the root cause?                       │
│    - What did you learn?                            │
│                                                      │
│ 2. Identify patterns (20min)                        │
│    - Similar bugs across features?                  │
│    - Common root causes?                            │
│    - Tooling gaps?                                  │
│                                                      │
│ 3. Action items (10min)                             │
│    - Linter rules to add                            │
│    - Documentation to update                        │
│    - Training needs                                 │
│                                                      │
│ 4. Bug pattern database (20min)                     │
│    - Document in docs/COMMON_BUGS.md                │
│    - Update this skill with new patterns            │
└─────────────────────────────────────────────────────┘

# BENEFITS:
- [Teams reduce time-to-resolution](https://wearebrain.com/blog/10-effective-debugging-techniques-for-developers/) for recurring patterns
- Cross-pollination of debugging techniques
- Junior engineers learn from senior patterns
- Proactive bug prevention

# EXAMPLE BUG PATTERN DATABASE:
# docs/COMMON_BUGS.md

## Timer Leaks (Category: State Management)
**Pattern:** Timer continues after widget dispose
**Root Cause:** Missing timer.cancel() in dispose()
**Detection:** DevTools Memory Profiler shows Timer not GC'd
**Fix Pattern:** Always use ref.onDispose() in Riverpod
**Prevention:** Linter rule `cancel_subscriptions`
**Occurrences:** 3 times in workout, timer, recovery features
**First Seen:** 2025-01-15 (commit abc123)
**Solved By:** @engineer1

## Firestore Offline Await (Category: Data Sync)
**Pattern:** Promise hangs when offline
**Root Cause:** Awaiting Firestore write while offline
**Detection:** App freezes, no error thrown
**Fix Pattern:** Don't await writes, use snapshots() instead
**Prevention:** Code review checklist item
**Occurrences:** 2 times in analytics, history
**First Seen:** 2025-01-10
**Solved By:** @engineer2
```

### Step 5.6: Bug Tracking Integration

```bash
# TodoWrite task: "Integrate with bug tracking system"

# CREATE GITHUB ISSUE (FitLog uses GitHub)
gh issue create --title "Bug: Timer continues after workout" \
  --label "bug,p1,workout" \
  --body "$(cat <<EOF
## Symptom
Timer continues running after workout completion

## Reproduce
1. Start workout
2. Complete workout
3. Observe timer still running

## Expected
Timer should stop and be disposed

## Actual
Timer continues, memory leak

## Environment
- iOS 17.2
- Flutter 3.16
- App v1.2.3

## Root Cause
Missing timer.cancel() in WorkoutProvider.completeWorkout()

## Fix
PR #123

## Tests
test/features/workout/workout_provider_test.dart

## Related
- Closes #456
- Similar to #234
EOF
)"

# LINK FIX COMMIT TO ISSUE
git commit -m "fix(workout): cancel timer on completion

Fixes #789

- Added timer.cancel() in completeWorkout()
- Prevents memory leak from orphaned timers
- Added regression test"

# PRIORITY MATRIX (for triage):
| Severity | Users Impacted | Priority | SLA      |
|----------|----------------|----------|----------|
| Critical | >50%           | P0       | 2 hours  |
| High     | 10-50%         | P1       | 1 day    |
| Medium   | 1-10%          | P2       | 1 week   |
| Low      | <1%            | P3       | Backlog  |

# AUTOMATED TRACKING:
☐ Crashlytics auto-creates issues for crashes
☐ Firebase Performance auto-flags slow traces
☐ CI/CD fails link to issue on regression
```

**Bug Tracking Best Practices:**
- One bug = one issue (granular tracking)
- Use labels for filtering (bug, p0-p3, feature-area)
- Link commits to issues ("Fixes #123")
- Close issues only when verified fixed
- [Software Development Best Practices](https://www.2am.tech/blog/software-development-best-practices)

---

## 🚨 FitLog-Specific Debug Patterns

### Pattern A: Riverpod State Issues

**Symptoms:** Widget not rebuilding, stale data, wrong state

**Debug checklist:**
```dart
// TodoWrite task: "Debug Riverpod state management"

☐ Check provider definition:
   - AutoDisposeProvider? (should dispose)
   - KeepAlive needed? (for expensive resources)

☐ Check dependencies:
   - ref.watch() vs ref.read() vs ref.listen()
   - Watching correct provider?

☐ Check mutation:
   - Using state = newState? (StateProvider)
   - Using state.update()? (AsyncNotifier)

☐ Check disposal:
   - ref.onDispose() called?
   - Timers/streams cancelled?

☐ Check select optimization:
   - ref.watch(provider.select((s) => s.field))?
   - Prevents unnecessary rebuilds
```

### Pattern B: Firebase Sync Issues (Advanced)

**Symptoms:** Data not saving, stale data, sync conflicts, "Firestore already started" error

**Debug checklist:**
```bash
# TodoWrite task: "Debug Firebase synchronization"

☐ Check Firestore rules (firestore.rules):
   - Has user permission to write?
   - Rules rejecting silently?
   - Test with Firebase Console → Rules Playground

☐ Check network connectivity:
   - await connectivity.checkConnectivity()
   - Offline persistence enabled?
   - Check Firebase Console → Usage → Network errors

☐ Check batch operations:
   - Using batch.commit() not individual writes?
   - Batch size < 500 operations? (hard limit)
   - Batch writes are atomic (all-or-nothing)

☐ Check listeners:
   - Stream subscription cancelled properly?
   - Memory leaks from uncancelled subscriptions?
   - Use ref.onDispose() in Riverpod to cancel

☐ Check repository pattern:
   - DataSource → Repository → Provider
   - Not mixing Firestore calls in Provider
```

**COMMON FIRESTORE ERRORS & FIXES:**

**1. "Firestore has already been started and persistence can no longer be enabled"**
```dart
// ❌ WRONG: Enabling persistence after Firestore used
final firestore = FirebaseFirestore.instance;
await firestore.collection('test').get(); // Firestore started!
await firestore.enablePersistence(); // ERROR!

// ✅ CORRECT: Enable persistence BEFORE any usage
Future<void> initFirestore() async {
  final firestore = FirebaseFirestore.instance;
  await firestore.enablePersistence(); // First thing!
  // Now use Firestore normally
}
```

**2. Multiple Tab Issues (Web only)**
```dart
// Error: "failed-precondition" when multiple tabs open
try {
  await FirebaseFirestore.instance.enablePersistence();
} catch (e) {
  if (e.code == 'failed-precondition') {
    // Multiple tabs open, persistence enabled in one only
    print('Persistence already enabled in another tab');
  }
}
```

**3. Database Lock (Android)**
```dart
// If using Firestore from multiple processes:
// Only enable persistence in ONE process!
// Check if main process:
if (isMainProcess()) {
  await FirebaseFirestore.instance.enablePersistence();
}
```

**4. Avoid `await` on Offline Operations**
```dart
// ❌ WRONG: Promise never resolves offline
try {
  await firestore.collection('workouts').add(workout); // Hangs offline!
} catch (e) {
  // Never caught offline
}

// ✅ CORRECT: Don't await, handle eventual sync
firestore.collection('workouts').add(workout).then((_) {
  print('Synced when online');
}).catchError((e) {
  print('Sync failed: $e');
});

// OR use onSnapshot for real-time sync status
firestore.collection('workouts').doc(id).snapshots().listen((snap) {
  if (snap.metadata.hasPendingWrites) {
    print('Pending sync...');
  } else {
    print('Synced!');
  }
});
```

**5. Cache Size Management**
```dart
// Set cache size limit (default 40MB)
final settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: 100 * 1024 * 1024, // 100MB
);
FirebaseFirestore.instance.settings = settings;

// Or unlimited (use with caution!)
cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
```

**6. Last Write Wins (Conflict Resolution)**
```
Device A offline: Sets workout.name = "Morning"
Device B offline: Sets workout.name = "Evening"
Both come online → Last write wins! (no merge)

Solution: Use Firestore Transactions for critical updates
```

```dart
// ✅ Safe update with transaction
await firestore.runTransaction((transaction) async {
  final snap = await transaction.get(workoutRef);
  final currentVersion = snap.data()?['version'] ?? 0;

  transaction.update(workoutRef, {
    'name': newName,
    'version': currentVersion + 1, // Optimistic locking
  });
});
```

**Firestore Debugging Resources:**
- [Offline Persistence Guide](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Common Gotchas](https://dev.to/blarzhernandez/a-few-gotchas-to-consider-when-working-with-firestore-s-offline-mode-and-react-native-42al)
- [Offline Sync Best Practices](https://bootstrapped.app/guide/how-to-use-firebase-firestores-offline-capabilities-with-synchronization)

### Pattern C: iOS Live Activity Bugs

**Symptoms:** LA not updating, stuck on old data, not appearing

**Debug checklist:**
```bash
# TodoWrite task: "Debug iOS Live Activity integration"

☐ Check entitlements (Runner.entitlements):
   - Push notification enabled?
   - Background modes configured?

☐ Check Swift bridge:
   - ios/Runner/LiveActivityHandler.swift
   - Method channel communication working?
   - Error handling in completion handlers?

☐ Check update frequency:
   - Not updating too frequently (rate limit)?
   - Using push token vs local updates?

☐ Check ActivityKit lifecycle:
   - Activity started before update?
   - Activity.end() called on completion?

☐ Check iOS version support:
   - iOS 16.1+ required for Live Activities
   - Fallback for older versions?
```

### Pattern D: Timer Precision Issues

**Symptoms:** Timer drift, wrong duration, not stopping

**Debug checklist:**
```dart
// TodoWrite task: "Debug timer precision and lifecycle"

☐ Check Timer.periodic vs Duration:
   - Using Timer.periodic correctly?
   - Duration calculation accurate?

☐ Check background execution:
   - Audio session configured? (iOS)
   - Background task registered? (iOS)
   - Foreground service? (Android)

☐ Check timer disposal:
   - timer?.cancel() in dispose()?
   - No memory leaks from orphaned timers?

☐ Check UI updates:
   - Using ValueNotifier or Riverpod?
   - Not calling setState() 60 times/sec?

☐ Check system sleep:
   - Wakelock acquired during workout?
   - Timer pauses when app backgrounds?
```

---

## 📊 Success Metrics

**After debugging session, verify:**

```bash
# TodoWrite task: "Verify fix meets quality criteria"

☐ Bug reproduced → Bug no longer reproducible
☐ Root cause documented (5 Whys or Fishbone)
☐ Regression test written and passing
☐ Performance check passed (no new anti-patterns)
☐ flutter analyze passes (no new warnings)
☐ Manual testing on target devices (iOS + Android)
☐ Git commit with descriptive message + "Fixes #XXX"
☐ ADR written if architectural decision
☐ Team notified via Slack/PR review
```

---

## 🎓 Common FitLog Bug Categories

### Category 1: State Management (35% of bugs)

**Root causes:**
- Provider not disposing resources
- Using `ref.read()` instead of `ref.watch()`
- Stale state after navigation
- No `.select()` optimization causing rebuilds

**Tools:** Flutter DevTools → Performance → Rebuild tracking

### Category 2: Data Persistence (25% of bugs)

**Root causes:**
- Firestore rules blocking writes
- Hive box not initialized
- Race condition in sync
- Data model mismatch (server vs local)

**Tools:** Firebase Console → Firestore → Usage, Crashlytics

### Category 3: iOS Native (20% of bugs)

**Root causes:**
- Platform channel type mismatch
- Audio session conflicts
- Background task not configured
- Live Activity lifecycle errors

**Tools:** Xcode Instruments, Console.app logs

### Category 4: Performance (15% of bugs)

**Root causes:**
- Resource opened in loop
- No batch operations (Firebase/Hive)
- Expensive computation in build()
- No debouncing on rapid events

**Tools:** `.claude/scripts/performance-check.sh`, DevTools

### Category 5: UI/Layout (5% of bugs)

**Root causes:**
- Missing localization (hardcoded strings)
- Wrong theme colors (not using `context.colors`)
- Icon size not using `AppIconSize`
- Const constructor issues with `context.l10n`

**Tools:** Linter rules, visual inspection

---

## 🔄 Integration with Other Skills

**This skill works WITH:**

- `/fitlog` → Suggests this skill for complex bugs
- `/context` → Loads git history + recent changes
- `flutter-debugger` → For quick runtime errors
- `ios-specialist` → For Swift/native deep dive
- `firebase-expert` → For Firestore/sync issues
- `performance-optimizer` → For rebuild/memory problems

**Workflow:**
```
User reports complex bug
    ↓
/fitlog analyze → Suggests systematic-debug skill
    ↓
/systematic-debug → Executes this framework
    ↓
Identifies layer → Calls specialized skill if needed
    ↓
Fix implemented → Verification phase
    ↓
ADR + regression test → Prevention
```

---

## ⚡ Quick Start Examples

### Example 1: "Timer non si ferma"

```bash
# Claude executes:
/systematic-debug

# Phase 1: Isolation
- Reproduce: Start workout → complete → timer still runs ✅
- Binary search: Problem in timer/ or workout/ provider?
- Git bisect: Find commit that broke it

# Phase 2: RCA
- 5 Whys: timer?.cancel() not called → dispose() missing

# Phase 3: Tools
- DevTools: Memory leak confirmed (Timer not GC'd)

# Phase 4: Fix
- Add ref.onDispose(() => timer?.cancel())

# Phase 5: Verification
- Regression test written
- Performance check passed
```

### Example 2: "Dati analytics sbagliati"

```bash
# Claude executes:
/systematic-debug

# Phase 1: Isolation
- Reproduce: Specific workout → open analytics → wrong volume
- Trace: UI → Provider → Repository → Firestore query

# Phase 2: RCA
- Fishbone: Multiple causes (query filter + data mapping)

# Phase 3: Tools
- Firebase Console: Query fetching wrong exercises
- Git log: Recent changes to analytics calculation

# Phase 4: Fix
- Fix Firestore query filter
- Add data validation in mapper

# Phase 5: Verification
- Unit test for calculation logic
- Integration test for query
```

---

## 📚 Resources

**Internal FitLog docs:**
- `docs/DEVELOPMENT_RULES.md` - Coding standards
- `docs/CODE_PATTERNS.md` - Repository/Provider patterns
- `docs/architecture/OVERVIEW.md` - Clean Architecture
- `.claude/scripts/performance-check.sh` - Anti-pattern detector
- `docs/COMMON_BUGS.md` - Bug pattern database (create dopo retrospective)

**External resources - Debugging Methodology:**
- [RCA Guide - Splunk](https://www.splunk.com/en_us/blog/learn/root-cause-analysis.html)
- [Debugging Distributed Systems](https://maximilianmichels.com/2020/debugging-distributed-systems/)
- [Systematic Debugging Approach](https://ntietz.com/blog/how-i-debug-2023/)
- [AI Debugging Techniques 2026](https://wearebrain.com/blog/10-effective-debugging-techniques-for-developers/)
- [Software Development Best Practices](https://www.2am.tech/blog/software-development-best-practices)

**Flutter & Mobile Performance:**
- [Flutter DevTools Performance Guide](https://docs.flutter.dev/tools/devtools/performance)
- [Flutter Performance Profiling](https://docs.flutter.dev/perf/ui-performance)
- [DevTools Performance Debugging](https://www.nascenture.com/blog/flutter-devtools-performance-debugging/)
- [Debugging with Flutter DevTools](https://medium.com/easy-flutter/debugging-with-flutter-devtools-a-comprehensive-guide-301f6da6b9d6)

**iOS Memory Leaks:**
- [iOS Memory Leaks Detection](https://www.nimbleappgenie.com/blogs/what-are-ios-memory-leaks-how-to-detect-them/)
- [Debugging & Profiling iOS Apps](https://reintech.io/blog/debugging-profiling-ios-apps-optimal-performance)
- [Xcode Instruments Guide](https://developer.apple.com/documentation/xcode/gathering-information-about-memory-use)

**Android Memory:**
- [LeakCanary by Square](https://urancompany.com/blog/fix-memory-leaks-in-ios-and-android)
- [Memory Profiler Guide](https://developer.android.com/studio/profile/memory-profiler)
- [Hunting Memory Leaks](https://blog.nativescript.org/hunting-memory-leaks-with-android-studio-and-xcode/)

**Firebase & Firestore:**
- [Firestore Offline Persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firestore Offline Gotchas](https://dev.to/blarzhernandez/a-few-gotchas-to-consider-when-working-with-firestore-s-offline-mode-and-react-native-42al)
- [Offline Sync Best Practices](https://bootstrapped.app/guide/how-to-use-firebase-firestores-offline-capabilities-with-synchronization)

**Observability & Tracing:**
- [OpenTelemetry Observability Primer](https://opentelemetry.io/docs/concepts/observability-primer/)
- [Distributed Tracing Tutorial](https://www.withcoherence.com/articles/opentelemetry-distributed-tracing-tutorial-and-best-practices)
- [OpenTelemetry Tracing Guide](https://coralogix.com/guides/opentelemetry/opentelemetry-tracing-how-it-works-tutorial-and-best-practices/)
- [Distributed Tracing Best Practices](https://www.multiplayer.app/observability-framework/distributed-tracing/)

---

## 🎯 Golden Rules

```
╔════════════════════════════════════════════════════════╗
║  1. REPRODUCE prima di toccare codice                 ║
║     → Se non è riproducibile, non è debuggabile       ║
║                                                        ║
║  2. ISOLA al layer minimo                             ║
║     → Presentation? Domain? Data? Native?             ║
║                                                        ║
║  3. ROOT CAUSE, non symptoms                          ║
║     → 5 Whys fino alla causa architettturale          ║
║                                                        ║
║  4. FIX minimale per hotfix                           ║
║     → Refactoring ≠ Bug fixing                        ║
║                                                        ║
║  5. PREVENT con tests + linter + ADR                  ║
║     → Il bug migliore è quello mai committato         ║
╚════════════════════════════════════════════════════════╝
```

---

**END OF SKILL**

Remember: Debugging is 20% fixing, 80% understanding. Take time to investigate properly.
