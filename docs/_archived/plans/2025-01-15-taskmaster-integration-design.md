# task-master.dev Integration - Complete Design

**Generated**: 2025-01-15
**Source**: Brainstorming + Progressive Integration Design
**Target**: Multi-project Flutter development (starting with FitLog Pro)
**Scope**: Solo developer with 5+ milestone complex features

---

## 🎯 Executive Summary

Integration of task-master.dev into Flutter development workflow to decompose complex projects into manageable tasks. Uses **Progressive Integration** approach (3 phases) with smart auto-triggering, persistent documentation, and TodoWrite integration.

**Key Features**:
- ✅ Smart complexity detection (auto-suggests task-master.dev)
- ✅ WebFetch-based (no API key needed for Fase 1)
- ✅ Persistent plan documents in `docs/plans/`
- ✅ Automatic TodoWrite generation
- ✅ Milestone chain tracking with CONTEXT.md
- ✅ Auto-populated LEARNINGS.md from retrospectives
- ✅ 8 advanced error handling scenarios

---

## 📐 Architecture Overview (Fase 1)

### Components

**1. Smart Detection System**
- Triggers on: >50 words, keywords ("implement", "refactor", "migrate"), multi-layer mentions
- Proposes task-master.dev planning automatically
- User can accept/decline/preview

**2. Task-Master Bridge**
- Uses `WebFetch` to task-master.dev (no API key needed)
- Converts response to structured task list
- Enriches with Flutter/FitLog Pro specifics

**3. Plan Document Generator**
- Template: `docs/plans/YYYY-MM-DD-<topic>-plan.md`
- Auto-commits to git
- Includes metadata, validation, retrospective sections

**4. TodoWrite Converter**
- Parses plan tasks → TodoWrite format
- Smart grouping (<10 tasks: all, 10-20: categories, >20: milestones)
- Two-way sync (TodoWrite ↔ Plan document)

**5. Milestone Chain Tracker** (NEW)
- `docs/plans/CONTEXT.md` for cross-milestone dependencies
- Prevents rework from missing context
- Tracks tech debt and key decisions

**6. Learning System** (NEW)
- `docs/plans/LEARNINGS.md` auto-populated from retrospectives
- Improves future estimates and patterns
- Solo developer knowledge base

---

## 📋 Plan Document Template (v2.0 - Final)

```markdown
# {Topic Title} - Task Plan

**Generated**: {YYYY-MM-DD HH:mm}
**Source**: task-master.dev (WebFetch) / Claude Code (manual fallback)
**Complexity Score**: {HIGH/MEDIUM/LOW}
**Reason**: {Brief explanation}
**Total Tasks**: {Count}
**Estimated Time**: {Hours/Days}
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: {version from pubspec.yaml}
- Key Packages: riverpod ^{version}, firebase_core ^{version}, etc.
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: #{numbers}
- Parent Milestone: None / {M1, M2, etc.}

---

## 📋 Original Request

> {User's original request verbatim}

---

## 🔗 Cross-Milestone Dependencies (if applicable)

**Inherited from Previous Milestones**:
- [ ] **Design Decision**: {Description} (locked in Milestone X, Task Y)
- [ ] **Code Artifacts**: {Files/modules created} (from Milestone X)
- [ ] **Tech Debt**: {Known issues carried forward}

**Important**: If Milestone {X} not completed, this plan will fail.
**Dependency chain**: M{X}.{Y} → M{X}.{Z} → M{current}.{1} (CRITICAL PATH)

**Refer to**: `docs/plans/CONTEXT.md` for full milestone chain

---

## 🎯 Task Breakdown

### 1. {Task Category - e.g., Domain Layer}

- [ ] **Task 1.1**: {Description}
  - **Layer**: Domain / Data / Presentation / Shared
  - **Files**: `lib/features/{feature}/domain/entities/{file}.dart`
  - **Dependencies**: None / Task X.Y
  - **Est. Time**: 30 min (HARD LIMIT: 1.5h)
  - **Blocking**: Yes (blocks Task 2.1, 2.2) / No
  - **Verification**: {How to verify completion}
  - **Code Prompt**:
    ```
    Create {EntityName} entity in lib/features/{feature}/domain/entities/
    following existing entity patterns. Include freezed + json_serializable.
    ```

- [ ] **Task 1.2**: {Description}
  - **Layer**: Domain
  - **Files**: `lib/features/{feature}/domain/repositories/{file}.dart`
  - **Dependencies**: Task 1.1
  - **Est. Time**: 20 min
  - **Blocking**: No
  - **Verification**: Abstract repository interface defined
  - **Timeout Warning**: ⚠️ If exceeds 30 min (est + 50%), SPLIT immediately
  - **Code Prompt**:
    ```
    Create abstract {RepositoryName} in domain/repositories/
    with methods: {list methods}
    ```

### 2. {Task Category - e.g., Data Layer}
... (continue pattern)

---

## 📊 Implementation Order

**MUST DO FIRST** (blocking tasks):
→ Task 1.1, 1.2 (domain foundation) - ~50 min
→ **Critical Path**: Blocks 80% of remaining tasks

**THEN** (parallel workable):
→ Task 2.1, 2.2 (data layer) - ~1.5h
→ Task 3.1 (provider setup) - ~45 min

**FINALLY** (depends on above):
→ Task 4.1, 4.2, 4.3 (UI + integration) - ~2h
→ Task 5.1 (polish + testing) - ~1h

**Total Critical Path**: ~5.5h
**Parallelizable**: ~2h (Tasks 2.1, 2.2, 3.1 can run concurrently if careful)

---

## 🔌 Technical Dependencies

**Packages Required**:
- [ ] `{package_name}`: ^{version} → {reason}
- [ ] Check conflicts: `flutter pub outdated`

**Firebase/Backend**:
- [ ] Firestore collections: `{collection_names}`
- [ ] Security rules updates: Yes/No → {describe}
- [ ] Cloud functions: None / {function_names}

**Assets/Resources**:
- [ ] New icons: {list} (check `AppIcons.*` first)
- [ ] Localization keys: ~{count} new strings ({prefixes_*})
- [ ] Theme tokens: No new colors (use `context.colors.*`)

---

## 🔗 Related Documentation

**Must Read Before Starting**:
- `docs/NAVIGATION/INDEX.md` → Navigate to {feature} section
- `docs/DESIGN_GUIDELINES.md` → {Relevant patterns}
- `docs/{related-feature}/DOCUMENTATION.md` → Integration points

**Related Plans**:
- `docs/plans/YYYY-MM-DD-{related-plan}.md` (if exists)

---

## 🧪 Testing Checklist

**Unit Tests** (target: 80% coverage for business logic):
- [ ] Domain entities: `test/features/{feature}/domain/entities/`
- [ ] Repositories: `test/features/{feature}/data/repositories/`
- [ ] Providers: `test/features/{feature}/presentation/providers/`

**Widget Tests**:
- [ ] Critical screens: {ScreenNames}
- [ ] Custom widgets: {WidgetNames}

**Integration Tests**:
- [ ] User flow: {Describe flow}
- [ ] Firebase integration: {Specific scenario}

**Manual Testing**:
- [ ] iOS (physical device + simulator)
- [ ] Dark/Light theme (toggle in settings)
- [ ] Locale switching (EN ↔ IT via settings)
- [ ] Edge cases: {list specific to feature}

---

## ⚠️ Rollback Strategy

**Git Strategy**:
- Branch: `feature/{feature-name}`
- Merge into: `main` / `develop`
- Rollback point: Current HEAD `{hash}` before starting

**Feature Flags** (if applicable):
- [ ] Wrap feature with `if (FeatureFlags.{featureName})`
- [ ] Default: `false` until fully tested

**Breaking Changes**:
- Database migrations: None / {describe Firestore schema changes}
- API changes: None / {describe new endpoints}
- User data impact: None / {describe data migration needed}

---

## 🚨 Validation Gates (Pre-requisite Checks)

**Before starting blocking tasks**, auto-verify dependencies:

- [ ] **Task 2.2**: {Description}
  - 🔒 Blocks: Task 3.1, 3.2
  - **Pre-flight Check**:
    ```bash
    flutter analyze lib/features/{feature}/domain/ (0 errors)
    flutter test test/features/{feature}/domain/
    ```
  - **If check fails**:
    - Show last passing commit for blocking task
    - Options: "Revert and retry?" / "Debug now?" / "Skip (dangerous)"

---

## ⏱️ Task Timeout Rules

**Per ogni task**:
- Estimated time: 15 min - 1.5 hours (HARD LIMIT)
- **Auto-trigger**: If actual time > estimated + 50%

**If timeout exceeded**:
1. PAUSE current task
2. Log timeout in Notes & Decisions
3. Propose split:
   ```
   Original Task X.Y (2h estimated, 3h actual):
   → Split into:
     - Task X.Ya: {Subtask 1} (30 min)
     - Task X.Yb: {Subtask 2} (30 min)
     - Task X.Yc: {Subtask 3} (20 min)
   ```
4. Resume with new granularity

---

## 🔄 Task Rework Protocol

**If you need to restart a task**:

1. **Rename current attempt**:
   - Original: `lib/features/{feature}/domain/service.dart`
   - Backup: `lib/features/{feature}/domain/service.v1.dart`

2. **Log rework in plan**:
   ```
   - [ ] **Task 3.2**: Implement {Service}
     - **Attempt 1**: ❌ Failed (reason: too generic requirements)
     - **Attempt 2**: 🔄 In progress (enriched from Task 3.1 learnings)
     - **Version**: service.dart (v2, canonical)
   ```

3. **Post-rework review**:
   - `git diff service.v1.dart service.dart`
   - Keep best parts from v1 if applicable
   - Document why v2 is better (add to LEARNINGS.md)

4. **Final decision**:
   - Keep v2 + delete v1
   - OR merge improvements from v1 into v2

---

## ✅ Completion Criteria

### Code Complete:
- [ ] All tasks marked complete in TodoWrite
- [ ] `flutter analyze` passes (0 errors, 0 warnings)
- [ ] No `// TODO` or `// FIXME` comments remaining
- [ ] All imports absolute (`package:...`, no `../`)

### Quality Gates:
- [ ] Tests written and passing (see Testing Checklist)
- [ ] Performance: No jank on mid-range devices (DevTools)
- [ ] Memory: No leaks detected (DevTools profiler)
- [ ] Build succeeds: iOS + Android release builds

### Design System Compliance (Flutter-specific):
- [ ] No hardcoded `Colors.*` (use `context.colors.*`)
- [ ] No hardcoded strings (use `context.l10n.*`)
- [ ] No hardcoded `Icons.*` (use `AppIcons.*` if available)
- [ ] AppIconSize.* used (no magic numbers 24, 28)
- [ ] Tested in dark AND light themes

### Documentation Auto-Triggers:
- [ ] **If new feature**: Auto-prompt triggers for docs generation
- [ ] **If API changes**: Update `docs/API_REFERENCE.md`
- [ ] **If UI changes**: Screenshots + update `docs/UI_PATTERNS.md`

### Deployment Ready:
- [ ] Localization complete (app_en.arb + app_it.arb)
- [ ] `flutter gen-l10n` executed successfully
- [ ] Changelog entry added (if maintained)
- [ ] Version bump committed (if release)

---

## 📋 Plan Version History

| Version | Date | Changes | Status |
|---------|------|---------|--------|
| 1.0 | {YYYY-MM-DD HH:mm} | Initial plan ({count} tasks) | 🔄 Current |

**Delta Log** (updated when plan modified):
```
v1.0 → v1.1 (example):
+ Task 12: Verify theme compliance [NEW]
+ Task 13: Performance profiling [NEW]
- Task 8: Manual testing (merged into Task 13)
```

**Current task set**: v1.0
**Previously completed**: None (new plan)

---

## 📝 Notes & Decisions

{Claude adds timestamped notes here during implementation}

- **{YYYY-MM-DD HH:mm}**: Decision to use X instead of Y because...
- **{YYYY-MM-DD HH:mm}**: Encountered issue Z, solved by...
- **{YYYY-MM-DD HH:mm}**: Refactored Task 3.2 approach after testing feedback

---

## 📊 Post-Milestone Retrospective

{Filled AFTER milestone completion - template below}

**Execution**:
- Estimated: {X}h → Actual: {Y}h ({%} of estimate)
- Reason: {Why over/under estimate}

**Quality**:
- Test coverage: {%} (target: 80%) {✅/❌}
- flutter analyze: {count} errors {✅/❌}
- Code review: {count} issues found

**Learnings**:
1. {Learning 1 - technical}
2. {Learning 2 - process}
3. {Learning 3 - estimation}

**Adjustments for Next Milestone**:
- {Adjustment 1}
- {Adjustment 2}

**Carry-forward**:
- Good: {What worked well}
- Bad: {What to avoid next time}

**→ Auto-copied to**: `docs/plans/LEARNINGS.md`

---

## 📝 Version History

### v1.0 - {YYYY-MM-DD HH:mm}

**Initial plan generation** via task-master.dev (WebFetch) / Claude Code (manual fallback)

**Total Tasks**: {count}
**Estimated Time**: ~{X}h
**Complexity**: {HIGH/MEDIUM/LOW}

---

{Version updates auto-appended here when plan is modified}

{Example v1.1 entry - only appears if plan modified}:
{
### v1.1 - {YYYY-MM-DD HH:mm}

**Changes**:
- ✏️ Modified task {X.Y}: {Description of change} (+{time} added)
- ➕ Added new task {X.Y}: {Description}
- 🗑️ Removed task {X.Y}: {Reason}
- 🔄 Reordered tasks: {X.Y} now blocks {X.Z} (dependency added)
- 📊 Updated time estimate: {old}h → {new}h (+{delta}h)

**Reason**: {Why plan was modified - e.g., "User feedback after M1 completion", "Discovered missing dependency", "Scope change"}

**Modified by**: Claude Code (automatic version increment)

**CONTEXT.md Updated**: Yes (milestone table row updated with new version)
}

---

## 🔧 Generation Metadata

**task-master.dev Call**:
- Timestamp: {YYYY-MM-DDTHH:mm:ssZ}
- Prompt sent: "{User request}"
- Response time: {X.X}s
- Tasks generated: {count}
- Tasks after enrichment: {count} (+{delta} Flutter best practices)

**Validation Results**:
- ✓ All tasks have descriptions
- ✓ Dependencies valid (no circular)
- ✓ File paths follow Flutter conventions
- ⚠️ Warnings: {list}

**Claude Modifications**:
- Merged {count} duplicate tasks
- Added mandatory: localization, testing, theme check
- Enriched {count} generic task descriptions with Flutter specifics

---

**Generated by**: Claude Code + task-master.dev
**Framework Version**: 2.0 (with 8 advanced error handling scenarios)
**Last Updated**: {Auto-updated timestamp}
```

---

## 📁 CONTEXT.md Structure

**Location**: `docs/plans/CONTEXT.md`

**Purpose**: Track milestone chains, cross-dependencies, and tech debt for complex features (5+ milestones)

```markdown
# Milestone Chain Context

Auto-updated context for multi-milestone features. Prevents rework from missing dependencies.

---

## 🎯 Current Active Milestones

| Milestone | Feature | Status | Started | ETA | Depends On |
|-----------|---------|--------|---------|-----|------------|
| M3 | Analytics UI | ⏳ In Progress | 2025-01-15 | 2025-01-16 | M2 Complete |
| M2 | Analytics Core | ✅ Complete | 2025-01-14 | 2025-01-15 | M1 Complete |
| M1 | Analytics Foundation | ✅ Complete | 2025-01-13 | 2025-01-14 | None |

---

## 📦 Milestone 1: Analytics Foundation (✅ Complete)

**Plan**: [2025-01-13-analytics-foundation-plan.md](./2025-01-13-analytics-foundation-plan.md)
**Completed**: 2025-01-14 16:30
**Actual Time**: 2.5h (estimated: 2h)

**Key Decisions** (inherited by M2, M3):
- ✅ Analytics data structure: `Map<String, List<WorkoutMetric>>`
- ✅ Firestore collection: `analytics_data` (schema locked)
- ✅ Repository pattern: `AnalyticsRepositoryImpl` with caching

**Artifacts Created**:
- `lib/features/analytics/domain/entities/analytics_data.dart`
- `lib/features/analytics/domain/repositories/analytics_repository.dart`
- `lib/features/analytics/data/repositories/analytics_repository_impl.dart`

**Tech Debt Introduced**:
- Manual JSON serialization (MEDIUM severity) → Cleanup in M3
- No caching expiration logic (LOW severity) → M4 if needed

**Blocks**: M2 (Analytics Core Logic)

---

## 📦 Milestone 2: Analytics Core Logic (✅ Complete)

**Plan**: [2025-01-14-analytics-core-plan.md](./2025-01-14-analytics-core-plan.md)
**Completed**: 2025-01-15 10:00
**Actual Time**: 3h (estimated: 2.5h)

**Key Decisions** (inherited by M3):
- ✅ Metrics calculation: Real-time (no batch processing)
- ✅ Provider state: Separate provider per metric type (not unified)

**Artifacts Created**:
- `lib/features/analytics/domain/services/metrics_calculator.dart`
- `lib/features/analytics/presentation/providers/analytics_provider.dart`

**Dependencies from M1**:
- ✓ Used `AnalyticsRepository` from M1.3
- ✓ Consumed `AnalyticsData` entity from M1.1

**Tech Debt Introduced**:
- N+1 query pattern in MetricsCalculator (HIGH severity) → FIX in M2.4 (CRITICAL)

**Blocks**: M3 (Analytics UI)

---

## 📦 Milestone 3: Analytics UI (⏳ In Progress)

**Plan**: [2025-01-15-analytics-ui-plan.md](./2025-01-15-analytics-ui-plan.md)
**Started**: 2025-01-15 11:00
**Estimated**: 2h

**Dependencies from M1 & M2**:
- ✓ M1: `AnalyticsRepository`, `AnalyticsData` entity
- ✓ M2: `AnalyticsProvider`, `MetricsCalculator`
- ⚠️ M2 tech debt: N+1 queries (must fix before UI stress-testing)

**Critical Path**:
```
M1.1 (Entity) → M1.3 (Repository) → M2.1 (Service) → M2.3 (Provider) → M3.1 (UI Screen)
```

**If M1 or M2 incomplete**: This milestone will FAIL

---

## ⚠️ Known Technical Debt Register

| Debt | Origin | Severity | Impact | Scheduled Cleanup | Status |
|------|--------|----------|--------|-------------------|--------|
| Manual JSON serialization | M1.1 | MEDIUM | Verbose code, error-prone | M3.5 | ⏹️ Pending |
| N+1 query in MetricsCalculator | M2.2 | HIGH | Performance bottleneck | M2.4 (URGENT) | 🔄 In progress |
| No cache expiration | M1.3 | LOW | Stale data possible | M4 (if needed) | ⏹️ Deferred |

**Rule**: Before starting new milestone, pick 1-2 MEDIUM+ debts to refactor

---

## 🔄 Dependency Chain Visualization

```
Analytics Feature (5 Milestones total)

M1 Foundation
├── Entity definition
├── Repository interface
└── ✅ Status: Complete
    └── Blocks: M2

M2 Core Logic
├── Metrics calculator
├── Provider setup
└── ✅ Status: Complete
    └── Blocks: M3

M3 UI (CURRENT)
├── Analytics screen
├── Chart widgets
└── ⏳ Status: In Progress
    └── Blocks: M4

M4 Optimization (NOT STARTED)
├── Query optimization
├── Cache tuning
└── ⏹️ Status: Pending
    └── Blocks: M5

M5 Polish (NOT STARTED)
├── Animations
├── Edge cases
└── ⏹️ Status: Pending
```

---

**Auto-updated by**: Claude Code
**Last sync**: {Auto-timestamp}
```

---

## 📚 LEARNINGS.md Structure

**Location**: `docs/plans/LEARNINGS.md`

**Purpose**: Auto-populated knowledge base from milestone retrospectives

```markdown
# Development Learnings

Auto-populated from milestone retrospectives. Solo developer knowledge base for improving estimates and patterns.

---

## 🎯 Estimation Patterns

**Learned from**: Multiple milestones

| Task Type | Initial Estimate | Actual Average | Adjustment Factor |
|-----------|------------------|----------------|-------------------|
| Firebase setup | 30 min | 45 min | +50% (+15 min) |
| Entity creation (freezed) | 20 min | 25 min | +25% (+5 min) |
| Widget with charts | 1h | 1.5h | +50% (+30 min) |
| Repository implementation | 45 min | 40 min | -10% (-5 min) |

**Rule**: Apply adjustment factors to future estimates automatically

---

## 🔍 Common Pitfalls

**Learned from**: Milestone retrospectives

### Firebase Security Rules Always Take Longer
- **Origin**: M1 Analytics Foundation (2025-01-14)
- **Issue**: Estimated 30 min, took 45 min
- **Why**: Rule testing + debugging is unpredictable
- **Solution**: Always add +15 min buffer to Firebase tasks

### Read Existing Providers Before Creating New Ones
- **Origin**: M2 Analytics Core (2025-01-15)
- **Issue**: Recreated pattern already solved in WorkoutProvider
- **Why**: Didn't review related code first
- **Solution**: Always check `lib/features/*/presentation/providers/` before Task 3.1

### Freezed Generation Can Fail Silently
- **Origin**: M1 Analytics Foundation (2025-01-14)
- **Issue**: `build_runner` succeeded but no .freezed.dart file
- **Why**: Syntax error in annotation
- **Solution**: Always verify `.freezed.dart` + `.g.dart` exist after generation

---

## ✅ What Works Well

**Learned from**: Successful patterns

### Task Ordering by Layer (Domain → Data → Presentation)
- **Origin**: M1-M3 Analytics (all milestones)
- **Why it works**: No blocking issues, clean dependency flow
- **Keep doing**: Always order tasks by architectural layer

### Pre-Reading Related Documentation
- **Origin**: M2 Analytics Core (2025-01-15)
- **Impact**: Saved ~30 min by reading `WORKOUT_SYSTEM_OVERVIEW.md` first
- **Keep doing**: Add "Must Read" section to every plan

### Using `select()` for Provider Optimization Early
- **Origin**: M2 Analytics Core (2025-01-15)
- **Impact**: Avoided rebuild issues from the start
- **Keep doing**: Add `select()` pattern to all provider tasks

---

## 📊 Milestone Performance Trends

| Milestone | Estimated | Actual | Accuracy | Trend |
|-----------|-----------|--------|----------|-------|
| M1 Foundation | 2h | 2.5h | 80% | 📈 Over |
| M2 Core Logic | 2.5h | 3h | 83% | 📈 Over |
| M3 UI | 2h | {TBD} | {TBD} | ⏳ In progress |

**Pattern detected**: Consistently 20% over estimate
**Adjustment**: Add 25% buffer to all future milestone estimates

---

## 🔧 Tech Stack Insights

**Flutter/Riverpod Specific**:

### Riverpod 2.x Family Pattern
- **Learned**: 2025-01-15 (M2)
- **Pattern**: Use `.family` + `AutoDisposeAsyncNotifierProvider` for parameterized state
- **Example**: `analyticsProvider.family<String, MetricType>`
- **Works well for**: Dynamic metric types, user-specific data

### fl_chart Performance
- **Learned**: 2025-01-15 (M3 - in progress)
- **Issue**: Large datasets (>100 points) cause jank
- **Solution**: Downsample to 50 points max, use `LineChart.swapAnimationDuration: Duration.zero`

---

**Auto-populated by**: Claude Code from retrospectives
**Last update**: {Auto-timestamp}
**Total learnings**: {count}
```

---

## 🚨 Advanced Error Handling Matrix (Complete)

| Error Type | Detection | Recovery | User Impact | Priority |
|------------|-----------|----------|-------------|----------|
| **API Unavailable** | WebFetch timeout | Manual fallback | Slight delay | P2 |
| **Vague Request** | Keyword analysis | Ask clarification | One question | P1 |
| **Generic Plan** | Quality check | Auto-enrich | Zero (transparent) | P1 |
| **Duplicates** | Text similarity (>80%) | Auto-merge | Zero (transparent) | P2 |
| **Missing Steps** | Requirements check | Auto-append Flutter tasks | Zero (transparent) | P1 |
| **Too Large Plan** | Task count > 25 | Split milestones + CONTEXT.md | Better organization | P1 |
| **Invalid Paths** | Pattern validation | Auto-fix to Flutter conventions | Zero (transparent) | P2 |
| **Task Timeout** | Time > est + 50% | Auto-split sub-tasks | Better granularity | P1 (NEW) |
| **State Pollution** | Tech debt detection | Auto-register in CONTEXT.md | Visibility + tracking | P1 (NEW) |
| **Cascading Failure** | Validate deps before task | Gate blocking with pre-flight | Catch early | P1 (NEW) |
| **Plan Versioning** | User modifies plan | Version control + delta log | Clarity on changes | P2 (NEW) |
| **Task Rework** | User restarts task | Rework protocol (v1 backup) | Learning + history | P2 (NEW) |
| **Context Loss** | 5+ milestone feature | CONTEXT.md chain tracking | Zero rework | P0 (NEW - CRITICAL) |
| **No Retrospective** | Milestone complete | Auto-prompt for learnings | Better future estimates | P1 (NEW) |
| **Missed Learnings** | Pattern not documented | Auto-populate LEARNINGS.md | Knowledge retention | P1 (NEW) |

**Legend**:
- P0: CRITICAL - Must have for 5+ milestone features
- P1: High - Core functionality
- P2: Medium - Quality of life improvements

---

## 📅 Implementation Roadmap

### Fase 1: Quick Start (Implement Now - P0/P1 items)

**Goal**: Get task-master.dev working with WebFetch + basic plan generation

**Tasks**:
1. ✅ Design complete (this document)
2. ⏹️ Create plan template generator function
3. ⏹️ Implement smart detection logic (>50 words, keywords)
4. ⏹️ WebFetch integration with task-master.dev
5. ⏹️ Plan document save to `docs/plans/`
6. ⏹️ TodoWrite conversion (basic)
7. ⏹️ Auto-commit plan document
8. ⏹️ CONTEXT.md creation (for 5+ milestones)
9. ⏹️ LEARNINGS.md initialization

**Estimated**: ~3-4 hours
**Deliverable**: Working Fase 1 with CONTEXT/LEARNINGS support

---

### Fase 2: CLI Automation (After Fase 1 validation)

**Goal**: Script-based automation with API integration

**Tasks**:
1. Create `./scripts/taskmaster_plan.sh <description>`
2. API key configuration (user's own key)
3. Parse API response to plan format
4. Git alias: `git plan "implement analytics"`
5. Enhanced TodoWrite grouping (milestones)
6. Retrospective prompt after milestone completion

**Estimated**: ~2-3 hours
**Deliverable**: CLI script + git alias

---

### Fase 3: Full Integration (If Fase 2 proves valuable)

**Goal**: Pre-commit hook integration + checkpoint system

**Tasks**:
1. Pre-commit detection (complex commit messages)
2. Checkpoint system integration for retrospectives
3. Slash command `/taskmaster`
4. Plan versioning automation
5. LEARNINGS.md auto-extraction from git history

**Estimated**: ~3-4 hours
**Deliverable**: Fully automated workflow

---

## ✅ Design Complete - Ready for Implementation

**Total Sections**: 6 (Architecture, Template, CONTEXT, LEARNINGS, Error Handling, Roadmap)
**Total Error Scenarios**: 15 (8 new advanced + 7 original)
**Solo Developer Optimizations**: ✅ (Skip concurrency, focus on learnings)
**5+ Milestone Support**: ✅ (CONTEXT.md + chain tracking)

**Next Steps**:
1. Save this design document
2. Create CONTEXT.md + LEARNINGS.md templates
3. Auto-commit design docs
4. Create TodoWrite for Fase 1 implementation
5. Begin Fase 1 implementation

---

**Design Status**: ✅ COMPLETE
**Approved for Implementation**: Pending user confirmation
