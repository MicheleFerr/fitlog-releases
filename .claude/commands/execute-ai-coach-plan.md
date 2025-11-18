# Execute AI Coach Optimizations Plan

You are about to execute the comprehensive AI Coach Optimizations implementation plan located at:
`docs/plans/2025-11-16-ai-coach-optimizations-plan.md`

## Your Mission

Implement the **53-task plan** for AI Coach feature optimizations following this workflow:

### Phase 1: Setup & Planning (5 min)

1. **Read the plan document**:
   ```
   Read: docs/plans/2025-11-16-ai-coach-optimizations-plan.md
   ```

2. **Create TodoWrite with all 53 tasks** organized by:
   - P0 Week 1-2: 12 tasks (Firebase, Polling, Unlock Timing)
   - P1 Week 3-4: 20 tasks (HealthKit, Health Connect)
   - P1 Week 5-6: 21 tasks (Recovery, GDPR, Consent)

3. **Git branch setup**:
   ```bash
   git checkout -b feature/ai-coach-p0-optimizations
   ```

### Phase 2: P0 Implementation (Start with Task 1.1)

**IMMEDIATELY start implementing Task 1.1: Firebase Architecture Optimization**

**File to modify**: `lib/features/ai_coach/data/datasources/firebase_coach_datasource.dart`

**Code Prompt** (from plan document Task 1.1):
```dart
// Refactor subcollection pattern → single document + map
// BEFORE (8 reads):
collection('users').doc(userId).collection('featureGates').doc('workoutSuggestions')

// AFTER (1 read):
collection('users').doc(userId).set({
  'features': {
    'workoutSuggestions': true,
    'advancedAnalytics': false,
    'recoveryInsights': false,
    'exerciseLibrary': true,
    'performanceCharts': false,
    'formAnalysis': false,
    'nutritionTracking': false,
    'programBuilder': false,
  },
  'featuresMetadata': {...}
}, SetOptions(merge: true));
```

**Verification Criteria** (before marking Task 1.1 complete):
- ✅ Profiler shows 1 Firestore read on app startup (was 8)
- ✅ All existing tests pass: `flutter test lib/features/ai_coach/`
- ✅ `flutter analyze` clean (0 errors)

### Phase 3: Incremental Progress

After Task 1.1 completion:
1. **Mark task complete** in TodoWrite
2. **Update plan document** (checkbox ✓ + timestamp)
3. **Create checkpoint commit**:
   ```bash
   git add .
   git commit -m "feat(ai-coach): Task 1.1 - optimize Firebase reads (8→1)"
   ```
4. **Move to Task 1.2** (Update repository layer)

### Workflow Rules (CRITICAL)

**ALWAYS follow**:
- ✅ Read task details from plan document before implementing
- ✅ Use Code Prompt provided in each task
- ✅ Verify with Verification Criteria before marking complete
- ✅ Update plan document + TodoWrite after each task
- ✅ Commit after each task (atomic commits)

**NEVER**:
- ❌ Skip verification steps
- ❌ Mark task complete without testing
- ❌ Implement multiple tasks without committing in between
- ❌ Modify files outside of task scope

### Project Context

**Framework**: Flutter 3.16.0
**Architecture**: Clean Architecture (Domain/Data/Presentation)
**State Management**: Riverpod 2.4.9
**Current Branch**: feature/ai-coach-p0-optimizations
**Plan Document**: docs/plans/2025-11-16-ai-coach-optimizations-plan.md

**Mandatory Rules** (from CLAUDE.md):
- ✅ All text: `context.l10n.*` (NO hardcoded strings)
- ✅ All colors: `context.colors.*` (NO hardcoded Colors.*)
- ✅ All icons: `AppIcons.*` with `AppIconSize.*` (NO Icons.* or magic numbers)
- ✅ `flutter analyze` must pass before commit
- ✅ NO `const` with `context.l10n` (iOS build compliance)

### Success Metrics (Day 1 Target)

**Minimum**:
- ✅ Task 1.1 complete + verified
- ✅ Tests passing
- ✅ Checkpoint commit created

**Ideal**:
- ✅ Task 1.1-1.4 complete (all P0 Firebase optimization)
- ✅ Profiler screenshot saved
- ✅ Plan document updated with timestamps

---

## 🚀 READY TO START?

**Your first action**: Read the plan document, create TodoWrite, setup git branch, then IMMEDIATELY implement Task 1.1 following the code prompt above.

**Estimated Time Today**: 3-4 hours for P0 Firebase optimization (Task 1.1-1.4)

**Next Steps**: After P0 complete → Move to Polling Strategy (Task 2.1-2.3)

GO! 🏃‍♂️
