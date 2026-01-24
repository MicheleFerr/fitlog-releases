# 🔬 Systematic Debug - Flusso Completo Enterprise

Questo documento spiega come un team di ingegneri enterprise userebbe la skill `systematic-debug` per risolvere un bug complesso in FitLog.

---

## 🎯 Overview del Framework

```
┌─────────────────────────────────────────────────────────┐
│              SYSTEMATIC DEBUG FRAMEWORK                 │
│                                                         │
│  Phase 0: PROACTIVE (Prevention)                       │
│  ├─ Observability & Monitoring                         │
│  ├─ Canary Deployments                                 │
│  ├─ Automated Smoke Tests                              │
│  └─ Error Budget & SLOs                                │
│                                                         │
│  Phase 1: ISOLATION (30% effort)                       │
│  ├─ Reproduce Deterministically                        │
│  ├─ Binary Search in Code                              │
│  └─ Git Bisect for Regressions                         │
│                                                         │
│  Phase 2: ROOT CAUSE ANALYSIS (40% effort)             │
│  ├─ 5 Whys Framework                                   │
│  ├─ Fishbone Diagram (multi-cause)                     │
│  └─ Distributed Tracing (multi-layer)                  │
│                                                         │
│  Phase 3: DATA COLLECTION (Advanced Tools)             │
│  ├─ Flutter DevTools (rebuild tracking)                │
│  ├─ iOS Instruments (memory leaks)                     │
│  ├─ Android LeakCanary + Profiler                      │
│  ├─ Firebase Console + Crashlytics                     │
│  ├─ AI-Assisted Analysis                               │
│  ├─ Distributed Tracing (OpenTelemetry)                │
│  └─ Test-Driven Debugging (TDD)                        │
│                                                         │
│  Phase 4: SOLUTION STRATEGIES                          │
│  ├─ Hotfix vs Structural Fix                           │
│  ├─ Performance Optimization                           │
│  └─ iOS Native Bridge Debugging                        │
│                                                         │
│  Phase 5: VERIFICATION & PREVENTION                    │
│  ├─ Regression Test Suite                              │
│  ├─ Linter Rules                                       │
│  ├─ ADR Documentation                                  │
│  ├─ Blameless Post-Mortem                              │
│  ├─ Debugging Retrospectives (team learning)           │
│  └─ Bug Tracking Integration                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Esempio Pratico: "Timer Continua Dopo Workout"

### **Scenario Iniziale**

```
User Report:
"Il timer non si ferma quando completo l'allenamento.
Continua a contare anche dopo aver chiuso la schermata workout."

Environment:
- iOS 17.2, iPhone 14 Pro
- FitLog v1.3.0
- Succede sempre dopo 3+ esercizi
```

---

## 📋 FLUSSO COMPLETO

### **STEP 0: Check Proactive Monitoring (Phase 0)**

```bash
# Prima di tutto: il bug era rilevabile dai monitor?

1. Firebase Crashlytics → No crash, just behavior bug
2. Performance Monitoring → No slow traces
3. User Analytics → Workout completion rate normale (80%)
4. Custom Metrics → Timer accuracy drift NOT monitored! ⚠️

ACTION: Aggiungi custom metric per timer accuracy
```

**Lesson:** Monitoring non ha catturato questo bug → serve metrica custom timer.

---

### **STEP 1: Pre-Debug Checklist (Mandatory TodoWrite)**

Claude crea automaticamente TodoWrite tasks:

```
☐ DESCRIVI sintomi: Timer continua dopo workout completion
☐ IDENTIFICA feature: workout + timer layers
☐ VERIFICA riproducibilità: Sempre dopo 3+ esercizi ✅
☐ RACCOGLI context: iOS 17.2, v1.3.0, 100% reproducible
☐ CHECK git: git log --since="1 week ago" --oneline
☐ SEARCH episodic-memory: "timer not stopping bug"
```

**Output:**
- Episodic memory trova bug simile risolto 2 mesi fa (timer leak in analytics)
- Git log mostra recente refactor di WorkoutProvider (commit abc123)
- HYPOTHESIS: Refactor ha rotto dispose logic

---

### **STEP 2: Phase 1 - Isolation (30% effort)**

#### **1.1 Reproduce Deterministically**

```dart
// TodoWrite task: "Create minimal reproduction"

Steps:
1. Fresh install ✅
2. Create workout con 3 esercizi ✅
3. Start workout → timer begins ✅
4. Complete workout → timer SHOULD stop ❌
5. Navigate away → timer STILL running ❌
6. Check DevTools → Timer object not disposed ❌

Result: 100% reproducible, minimal steps confirmed
```

#### **1.2 Binary Search**

```bash
# TodoWrite task: "Binary search to isolate module"

Test 1: Disable Live Activity → Bug persists ✅
  → Not Live Activity issue

Test 2: Comment out WorkoutProvider timer logic → Bug gone ✅
  → Problem in WorkoutProvider!

Test 3: Revert recent WorkoutProvider changes → Bug gone ✅
  → Problem in commit abc123 refactor

Isolated: lib/features/workout/presentation/providers/workout_provider.dart
```

#### **1.3 Git Bisect**

```bash
# TodoWrite task: "Run git bisect"

git bisect start
git bisect bad HEAD              # Current has bug
git bisect good v1.2.9           # Known working

# Git checks out commit abc123
flutter run → test → Bug appears!
git bisect bad

# Result: Bug introduced in commit abc123
# "refactor(workout): extract timer logic to mixin"
```

**Finding:** Refactor extracted timer to mixin, but forgot to call dispose!

---

### **STEP 3: Phase 2 - Root Cause Analysis (40% effort)**

#### **2.1 Five Whys**

```bash
# TodoWrite task: "Execute 5 Whys"

BUG: Timer continues after workout completion
├─ Why? → dispose() method not called on timer
  ├─ Why? → WorkoutProvider.dispose() doesn't call timer.cancel()
    ├─ Why? → Timer logic moved to mixin, dispose not overridden
      ├─ Why? → Refactor didn't update disposal chain
        └─ ROOT CAUSE: Missing test for dispose behavior
                       (would have caught this in refactor)
```

#### **2.2 Distributed Tracing (Manual)**

```dart
// TodoWrite task: "Add trace logging"

// Generate trace ID
final traceId = Uuid().v4(); // "abc-123-def"

// Presentation layer
debugPrint('[$traceId][PRESENTATION] Complete workout called');

// Provider layer
debugPrint('[$traceId][PROVIDER] Disposing workout session');
debugPrint('[$traceId][PROVIDER] Timer cancel called: $timerCancelled'); // FALSE!

// Result: Timer never cancelled in disposal chain
```

---

### **STEP 4: Phase 3 - Data Collection**

#### **3.1 Flutter DevTools**

```bash
# TodoWrite task: "Analyze with DevTools"

flutter run --profile

# Enable widget build tracking:
debugProfileBuildsEnabled = true;

# DevTools → Memory tab:
☐ Record session
☐ Complete workout
☐ Snapshot diff

Result:
- Timer object retained (not GC'd) ✅ LEAK CONFIRMED
- WorkoutProvider still in memory after navigate away ✅
- 5 Timer instances after 5 workouts ✅ ACCUMULATING LEAK
```

#### **3.2 iOS Instruments**

```bash
# TodoWrite task: "Profile with Instruments"

Xcode → Product → Profile → Leaks template

Result:
- Leak detected in Timer.periodic callback ✅
- Retain cycle: Timer → Closure → self (WorkoutProvider)
- Stack trace shows WorkoutProvider.startTimer:42
```

#### **3.3 AI-Assisted Analysis**

```bash
# TodoWrite task: "Use AI for pattern analysis"

Prompt to Claude:
"Analyze this git diff for potential dispose issues:

[paste commit abc123 diff]

Context: Timer continues after dispose. What's wrong?"

AI Response:
"The refactor moved timer logic to TimerMixin, but:
1. TimerMixin.dispose() is not called from WorkoutProvider.dispose()
2. Missing mixin disposal in cleanup chain
3. Suggest: Add super.dispose() or explicit mixin.dispose() call"
```

#### **3.4 Test-Driven Debugging**

```dart
// TodoWrite task: "Write failing test BEFORE fixing"

// RED: Test that FAILS (reproduces bug)
test('should dispose timer on provider disposal', () {
  final provider = WorkoutProvider();

  provider.startTimer();
  provider.dispose();

  // This FAILS before fix
  expect(provider.timer, isNull);
  expect(provider.isTimerActive, isFalse);
});

// Run: flutter test → FAILS ✗
```

---

### **STEP 5: Phase 4 - Solution Strategy**

#### **4.1 Hotfix vs Structural**

```bash
# TodoWrite task: "Choose fix strategy"

Decision Matrix:
- Impact: HIGH (memory leak, battery drain)
- Users: 100% affected
- Workaround: None
- Complexity: Low (1-line fix)

→ HOTFIX chosen (deploy today)
```

#### **4.2 Implement Fix**

```dart
// lib/features/workout/presentation/providers/workout_provider.dart

class WorkoutProvider extends StateNotifier<WorkoutState>
    with TimerMixin {  // Mixin added in refactor

  @override
  void dispose() {
    // FIX: Call mixin disposal
    disposeTimer();  // ← ADD THIS LINE

    super.dispose();
  }
}

// TimerMixin
mixin TimerMixin {
  Timer? _timer;

  void disposeTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
```

#### **4.3 Verify Test Passes**

```bash
# GREEN: Test now PASSES with fix
flutter test

# Output:
✓ should dispose timer on provider disposal (52ms)

# All tests pass ✓
```

---

### **STEP 6: Phase 5 - Verification & Prevention**

#### **5.1 Performance Check**

```bash
# TodoWrite task: "Run performance check"

.claude/scripts/performance-check.sh lib/features/workout/

# Output:
✓ No anti-patterns detected
✓ Dispose patterns correct
✓ No resources in loops
```

#### **5.2 Manual Testing**

```bash
# TodoWrite task: "Test on real device"

☐ iOS 17.2 (iPhone 14 Pro) → PASS ✓
☐ iOS 16.4 (iPhone 12) → PASS ✓
☐ Android 13 (Pixel 7) → PASS ✓

# DevTools memory check:
☐ Start 5 workouts → complete all
☐ Memory stable (no accumulation) ✓
☐ GC cleans up Timer objects ✓
```

#### **5.3 Regression Test**

```dart
// test/features/workout/workout_provider_test.dart

group('Timer Disposal', () {
  test('should cancel timer on workout completion', () {
    final provider = WorkoutProvider();
    provider.startTimer();

    provider.completeWorkout();

    expect(provider.timer, isNull);
  });

  test('should cancel timer on provider disposal', () {
    final provider = WorkoutProvider();
    provider.startTimer();

    provider.dispose();

    expect(provider.timer, isNull);
    expect(provider.isTimerActive, isFalse);
  });

  test('should not leak memory after multiple workouts', () async {
    for (int i = 0; i < 10; i++) {
      final provider = WorkoutProvider();
      provider.startTimer();
      await Future.delayed(Duration(seconds: 1));
      provider.dispose();
    }

    // If leaking, this would fail due to memory growth
    expect(true, isTrue); // Placeholder for memory assertion
  });
});
```

#### **5.4 Linter Rule**

```yaml
# analysis_options.yaml

linter:
  rules:
    - cancel_subscriptions  # Enforce Timer.cancel() in dispose
    - close_sinks           # Enforce StreamController.close()

# This would have caught the bug during refactor!
```

#### **5.5 ADR Documentation**

```markdown
# docs/ADR/20260122-timer-disposal-pattern.md

## Context
Timer leak discovered after refactoring timer logic to mixin.
Provider.dispose() did not call mixin.dispose().

## Decision
Enforce pattern: ALL mixins with resources MUST have dispose method.
Provider.dispose() MUST call all mixin dispose methods.

## Consequences
- Positive: Prevents future leaks in mixins
- Negative: Boilerplate (manual dispose calls)
- Mitigation: Add linter rule + code review checklist

## Alternatives Considered
- Code generator for auto-disposal (too complex)
- Single responsibility (no mixins) (limits reusability)
```

#### **5.6 Blameless Post-Mortem**

```markdown
# Post-Mortem: Timer Leak Bug (2026-01-22)

## Incident Summary
- Date: 2026-01-22 10:00 UTC
- Duration: 3 days in production
- Severity: P1 (High)
- User Impact: 100% users, battery drain + memory leak

## Root Cause
Refactoring timer logic to mixin broke disposal chain.
Missing test for dispose behavior allowed bug to ship.

## Timeline
- T+0 (Jan 19): Commit abc123 deployed (refactor)
- T+48h (Jan 21): User report received
- T+52h (Jan 21): Bug reproduced + root cause found
- T+54h (Jan 21): Hotfix deployed
- T+72h (Jan 22): Verified resolved, no new reports

## Resolution
- Immediate: Added disposeTimer() call in dispose() (1 line)
- Long-term: Added linter rule, regression tests, ADR
- Preventive: Updated refactoring checklist with "dispose audit"

## Lessons Learned
✓ What went well:
  - Rapid root cause analysis (<2h)
  - Effective use of DevTools + Instruments
  - AI-assisted diff analysis accelerated investigation

✗ What could improve:
  - Missing test coverage for dispose behavior
  - No automated memory leak detection in CI
  - Refactor code review didn't catch disposal issue

## Action Items
- [@engineer1] Add LeakCanary to debug builds (by Jan 25)
- [@engineer2] Write "Refactoring Checklist" doc (by Jan 26)
- [@tech-lead] Add memory leak check to CI pipeline (by Feb 1)
- [@team] Schedule debugging retrospective (Jan 29)
```

#### **5.7 Debugging Retrospective**

```bash
# Team Meeting (Jan 29, 1 hour)

Engineer 1 shares:
"Timer leak bug - forgot mixin disposal after refactor.
Learned: Always write dispose test BEFORE refactoring.
Pattern: TDD for refactoring, not just new features."

Engineer 2 shares:
"Similar bug in analytics 2 months ago.
We should document in COMMON_BUGS.md.
Let's create linter rule to prevent class."

Actions:
☐ Add to docs/COMMON_BUGS.md:
  - Pattern: Mixin with resources missing dispose
  - Detection: DevTools Memory Profiler
  - Fix: Explicit mixin.dispose() calls
  - Prevention: Linter + test coverage

☐ Update systematic-debug skill with this pattern
☐ Add to code review checklist: "Disposal chain complete?"
```

#### **5.8 Bug Tracking**

```bash
# Create GitHub Issue (for tracking)
gh issue create \
  --title "Bug: Timer leak after workout completion" \
  --label "bug,p1,workout,memory-leak" \
  --body "See docs/POST_MORTEM_20260122.md"

# Commit with issue link
git add lib/ test/ docs/
git commit -m "fix(workout): dispose timer in mixin cleanup

Fixes #234

- Added disposeTimer() call in WorkoutProvider.dispose()
- Prevents memory leak from undisposed Timer instances
- Added regression tests for disposal behavior
- Documented in ADR and post-mortem

Root cause: Refactor moved timer to mixin but forgot disposal chain
Impact: 100% users, 3 days in prod, battery drain + memory leak
Prevention: Linter rule + test coverage + refactoring checklist
"

# Deploy hotfix
git push origin hotfix/timer-leak
gh pr create --fill
```

---

## 📊 Metriche di Successo

```
┌────────────────────────────────────────────────────┐
│ BEFORE FIX:                                        │
│ - Memory growth: +50MB per workout                 │
│ - Timer instances: 10+ after 10 workouts           │
│ - Battery drain: Reported by users                 │
│ - Crash rate: 0.5% (indirect - OOM on old devices) │
│                                                     │
│ AFTER FIX:                                         │
│ - Memory growth: Stable (GC works correctly)       │
│ - Timer instances: 0-1 at any time ✓               │
│ - Battery drain: Resolved ✓                        │
│ - Crash rate: 0.1% (baseline) ✓                    │
│                                                     │
│ TIME METRICS:                                      │
│ - Bug discovered → Root cause: 2 hours ✓           │
│ - Root cause → Fix deployed: 2 hours ✓             │
│ - Total MTTR: 4 hours (P1 SLA: 1 day) ✓           │
│                                                     │
│ PREVENTION METRICS:                                │
│ - Regression tests added: 3 tests ✓                │
│ - Linter rules: 2 rules (cancel_subscriptions) ✓   │
│ - ADR documented: Yes ✓                            │
│ - Team learned: 100% (retrospective done) ✓        │
└────────────────────────────────────────────────────┘
```

---

## 🎓 Lessons & Patterns

### **Pattern Discovered:**

```markdown
# docs/COMMON_BUGS.md

## Timer/Resource Leaks in Mixins
**Category:** Memory Management
**Severity:** P1 (High)
**Frequency:** 2 occurrences in 3 months

**Symptom:**
Memory grows after repeated operations, Timer/Stream not disposed

**Root Cause:**
Mixin with resources (Timer, Stream, Subscription) missing dispose.
Provider.dispose() doesn't call mixin disposal methods.

**Detection:**
- DevTools Memory Profiler: Objects not GC'd
- iOS Instruments: Leak detection
- User reports: Battery drain, app slow

**Fix Pattern:**
```dart
// Mixin with resources
mixin TimerMixin {
  Timer? _timer;

  void disposeTimer() {  // Explicit disposal method
    _timer?.cancel();
    _timer = null;
  }
}

// Provider using mixin
class MyProvider with TimerMixin {
  @override
  void dispose() {
    disposeTimer();  // ← MUST call mixin disposal
    super.dispose();
  }
}
```

**Prevention:**
- Linter rule: `cancel_subscriptions`
- Test coverage: Always test dispose behavior
- Code review checklist: "All mixins with resources have dispose?"
- Refactoring checklist: "Disposal chain still complete?"

**Related:**
- Timer leak in WorkoutProvider (2026-01-22)
- Stream leak in AnalyticsProvider (2025-11-15)
```

---

## 🚀 Key Takeaways

```
╔════════════════════════════════════════════════════════╗
║  SYSTEMATIC DEBUG SUCCESS FACTORS:                    ║
║                                                        ║
║  1. PROACTIVE MONITORING prevented P0 escalation      ║
║     → Caught early via user report, not crash spike   ║
║                                                        ║
║  2. METHODICAL ISOLATION found root cause in <2h      ║
║     → Binary search + git bisect pinpointed commit    ║
║                                                        ║
║  3. MULTI-TOOL ANALYSIS confirmed hypothesis          ║
║     → DevTools + Instruments + AI converged on issue  ║
║                                                        ║
║  4. TEST-DRIVEN FIX ensured correctness               ║
║     → Red → Green → Refactor prevented re-break       ║
║                                                        ║
║  5. PREVENTION LAYERS stopped recurrence              ║
║     → Tests + Linter + ADR + Team Learning            ║
║                                                        ║
║  6. RETROSPECTIVE shared knowledge                    ║
║     → Pattern documented, team-wide improvement       ║
╚════════════════════════════════════════════════════════╝
```

---

**END OF FLOW DOCUMENT**

This is how a professional engineering team uses `systematic-debug` to solve complex bugs with enterprise-grade methodology.
