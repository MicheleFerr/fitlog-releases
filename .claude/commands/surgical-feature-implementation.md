---
name: surgical-feature-implementation
description: Implementazione chirurgica di feature con ricerca UX best practices e analisi personas obbligatoria. Zero rework, codice production-ready al primo commit.
---

# 🔬 Surgical Feature Implementation - FitLog Framework

**Use questo skill per:**
- ✅ Implementare QUALSIASI nuova feature (UI, analytics, data, integrations)
- ✅ Modifiche significative a feature esistenti (refactoring, enhancement)
- ✅ Feature che impattano UX o dati utente
- ✅ Quando vuoi codice production-ready al primo colpo
- ❌ Bug fixes (usa `systematic-debug` per quelli)
- ❌ Typo o fix minori (<10 righe)

---

## 🎯 PHILOSOPHY: Measure Twice, Cut Once

```
╔═══════════════════════════════════════════════════════════╗
║  RESEARCH 15% → DESIGN 35% → CODE 30% → VERIFY 15% → DOC 5% ║
║                                                            ║
║  Spending MORE time thinking = LESS time fixing           ║
║  Production-ready code at first commit, not after 3 PRs   ║
╚═══════════════════════════════════════════════════════════╝
```

**Core Principles:**
1. **Research First**: Best practices UX da internet PRIMA di progettare
2. **Personas First**: Ogni feature valutata con tutte le personas
3. **Patterns First**: Riusa codice esistente, non reinventare
4. **Quality First**: Auto-checks prevengono problemi, non li scoprono dopo
5. **Document First**: Documentazione = parte del deliverable, non afterthought

---

## 📋 MANDATORY: Pre-Implementation Checklist

**BEFORE starting, Claude MUST create TodoWrite per OGNI item:**

```
☐ DESCRIVI feature richiesta (cosa deve fare?)
☐ IDENTIFICA user story (perché serve? quale persona?)
☐ RICERCA best practices UX su internet (2-3 query mirate)
☐ ANALIZZA impatto su 5 personas primarie (tabella obbligatoria)
☐ CERCA pattern esistenti nel codebase (glob/grep)
☐ VERIFICA episodic-memory per features simili
☐ CHECK git recent changes (git log --since="1 week ago" --oneline)
☐ LISTA file da modificare/creare (minimize new files)
```

**Why TodoWrite:** Feature implementation senza checklist = over-engineering garantito.

---

## 🔍 Phase 0: Research & Context Loading (15% effort)

### Step 0.1: Automatic UX Best Practices Research

**Goal:** Informarsi PRIMA di progettare, non dopo aver codato male

```bash
# TodoWrite task: "Research UX best practices for [feature]"

# MANDATORY: Claude MUST execute 2-3 WebSearch queries
# basate sul tipo di feature

# Query template per tipo di feature:
┌─────────────────────────────────────────────────────────┐
│ Feature Type          │ Example Queries                 │
├───────────────────────┼─────────────────────────────────┤
│ Timer/Countdown       │ "workout timer UX best          │
│                       │  practices 2026"                │
│                       │ "mobile timer design patterns"  │
│                       │ "rest timer user experience"    │
├───────────────────────┼─────────────────────────────────┤
│ Analytics/Charts      │ "fitness progress charts UX"    │
│                       │ "mobile data visualization"     │
│                       │ "analytics screen design"       │
├───────────────────────┼─────────────────────────────────┤
│ Onboarding/Tutorial   │ "mobile app onboarding UX 2026" │
│                       │ "fitness app tutorial flow"     │
│                       │ "progressive disclosure UX"     │
├───────────────────────┼─────────────────────────────────┤
│ Social/Sharing        │ "workout sharing UX patterns"   │
│                       │ "social fitness features"       │
│                       │ "community features mobile"     │
├───────────────────────┼─────────────────────────────────┤
│ Workout Tracking      │ "exercise logging UX"           │
│                       │ "workout tracker interface"     │
│                       │ "set tracking best practices"   │
├───────────────────────┼─────────────────────────────────┤
│ Profile/Settings      │ "user profile UX fitness app"   │
│                       │ "settings screen design"        │
│                       │ "account management UX"         │
└───────────────────────┴─────────────────────────────────┘

# PROCESS:
☐ Identify feature category (timer, analytics, social, etc.)
☐ Execute 2-3 WebSearch queries (use WebSearch tool)
☐ Extract key insights:
   - Industry standards (what do top apps do?)
   - Common patterns (what users expect?)
   - Anti-patterns (what to avoid?)
   - Accessibility requirements
   - Mobile-specific considerations
☐ Summarize findings in 5-10 bullet points
☐ Keep sources for documentation later

# EXAMPLE OUTPUT:
Feature: Workout Timer with Live Activity
Research Findings:
├─ Industry Standard: Rest timer between sets (Hevy, Strong, FitNotes)
├─ Pattern: Countdown + skip option always visible
├─ Anti-pattern: Auto-start rest without confirmation
├─ Accessibility: Large tap targets (min 44x44pt), haptic feedback
├─ Mobile: Background execution critical for trust
└─ Sources: [links from WebSearch]
```

**Critical:** Non assumere di conoscere le best practices. La ricerca rivela:
- Cosa fanno i competitor di successo
- Errori comuni da evitare
- Standard di accessibilità
- Aspettative degli utenti (es. swipe gestures, tap patterns)

### Step 0.2: Project Context Loading

**Goal:** Capire cosa esiste già nel codebase

```bash
# TodoWrite task: "Load project context for [feature area]"

☐ Git status: git status --short (uncommitted changes?)
☐ Recent changes: git log --since="1 week ago" --oneline (modifiche recenti?)
☐ Search similar code:
   - Glob for related screens: lib/features/*/presentation/*_screen.dart
   - Grep for similar logic: grep -r "similar_pattern" lib/
☐ Check episodic-memory:
   Use episodic-memory MCP to search for:
   - Similar features implemented before
   - Lessons learned from past implementations
   - Architectural decisions (ADRs)
☐ Identify reusable components:
   - Existing widgets in lib/shared/presentation/widgets/
   - Existing services in lib/features/*/data/services/
   - Existing repositories in lib/features/*/data/repositories/
```

**Pattern Library Reference:**
- `docs/CODE_PATTERNS.md` - Repository/Provider patterns
- `lib/shared/` - Shared widgets/utils
- `docs/architecture/OVERVIEW.md` - Clean Architecture layers

---

## 🎨 Phase 1: Surgical Design (35% effort - MOST CRITICAL)

### Step 1.1: MANDATORY Persona Impact Analysis

**Goal:** Ogni feature DEVE essere valutata con tutte le 5 personas primarie

```bash
# TodoWrite task: "Execute Persona Impact Analysis for [feature]"

# MANDATORY TABLE - Copy to TodoWrite notes:

┌─────────────────────────────────────────────────────────────┐
│ PERSONA IMPACT ANALYSIS                                      │
├─────────────────────────────────────────────────────────────┤
│ Feature: [descrizione breve]                                │
├──────────────┬──────────┬───────────────────────────────────┤
│ Persona      │ Impatto  │ Rationale                         │
├──────────────┼──────────┼───────────────────────────────────┤
│ Marco        │ +/0/-    │ [come lo aiuta/danneggia]         │
│ (Beginner)   │          │ [basato su research UX]           │
├──────────────┼──────────┼───────────────────────────────────┤
│ Chiara       │ +/0/-    │ [considera time-saving]           │
│ (Busy Mom)   │          │ [friction aggiunta?]              │
├──────────────┼──────────┼───────────────────────────────────┤
│ Luca         │ +/0/-    │ [dati dettagliati?]               │
│ (Powerlifter)│          │ [analytics?]                      │
├──────────────┼──────────┼───────────────────────────────────┤
│ Sofia        │ +/0/-    │ [progressi visibili?]             │
│ (Aesthetic)  │          │ [muscle group relevant?]          │
├──────────────┼──────────┼───────────────────────────────────┤
│ Roberto      │ +/0/-    │ [integrazione ecosystem?]         │
│ (Busy Pro)   │          │ [zero friction?]                  │
├──────────────┴──────────┴───────────────────────────────────┤
│ VERDICT: [Procedi / Rivedi / Blocca]                        │
│ MITIGATION: [se impatti negativi, come mitigarli?]          │
└─────────────────────────────────────────────────────────────┘

# IMPACT LEGEND:
+++  Feature chiave per questa persona (make or break)
++   Molto positivo (strong value)
+    Positivo (nice to have)
0    Neutro (doesn't affect)
-    Negativo (adds friction)
--   Molto negativo (potrebbe abbandonare app)

# DECISION RULES:
🚫 BLOCCA se:
   - Una persona primaria ha impatto "--"
   - 3+ personas hanno impatto "-"
   - Feature utile solo per 1 persona e danneggia altre

⚠️ RIVEDI se:
   - Una persona primaria ha impatto "-"
   - Feature ignora completamente 2+ personas
   - Rationale non chiaro per qualche persona

✅ PROCEDI se:
   - Nessun impatto "--"
   - Max 1-2 impatti "-" con mitigazioni chiare
   - Impatto positivo su almeno 3 personas

# MITIGATION STRATEGIES:
Se impatti negativi:
☐ Può essere opt-in/opt-out? (Settings toggle)
☐ Può essere nascosta dietro Pro tier?
☐ Può essere semplificata per principianti?
☐ Può essere progressive disclosure? (mostra dopo N workout)
☐ Può avere tutorial/onboarding dedicato?
```

**CRITICAL:** Non procedere senza tabella persona completa!

**Persona Quick Reference (dal docs/USER_PERSONAS.md):**
```
Marco (Beginner):      Semplicità, guida, no termini complessi
Chiara (Busy Mom):     Velocità, zero friction, quick start
Luca (Powerlifter):    Dati dettagliati, PR tracking, analytics
Sofia (Aesthetic):     Progressi visibili, muscle groups, photos
Roberto (Busy Pro):    Integrazione, efficienza, Apple ecosystem
```

### Step 1.2: Pattern Selection & Architecture Design

**Goal:** Riusare pattern esistenti, non reinventare

```bash
# TodoWrite task: "Design architecture for [feature]"

☐ Identify Clean Architecture layers needed:
   ┌─────────────────────────────────────────────────┐
   │ Presentation (UI/Providers)                     │
   │ ├─ Screens: lib/features/X/presentation/       │
   │ ├─ Providers: .../presentation/providers/      │
   │ └─ Widgets: .../presentation/widgets/          │
   │                                                  │
   │ Domain (Business Logic)                         │
   │ ├─ Entities: lib/features/X/domain/entities/   │
   │ ├─ Services: .../domain/services/              │
   │ └─ Repository Interfaces                       │
   │                                                  │
   │ Data (Implementation)                           │
   │ ├─ Repositories: lib/features/X/data/repos/    │
   │ ├─ DataSources: .../data/datasources/         │
   │ └─ Services: .../data/services/                │
   │                                                  │
   │ Shared (Cross-cutting)                          │
   │ └─ lib/shared/presentation/widgets/            │
   └─────────────────────────────────────────────────┘

☐ Find similar patterns in codebase:
   # Examples:
   - Timer feature → Check lib/features/timer/
   - Analytics charts → Check lib/features/analytics/presentation/widgets/
   - Firestore sync → Check existing repositories

☐ Document pattern choice:
   Pattern: [name]
   Location: [existing code to reference]
   Rationale: [why this pattern fits]
   Modifications: [what needs to be adapted]

☐ FitLog-specific patterns to follow:
   - Provider THIN, Service FAT (logic in service, not provider)
   - Repository extends BaseHybridRepository (Hive + Firestore)
   - DataSource pattern (repo doesn't touch Firestore directly)
   - Singleton services with Lock-based initialization
   - ref.keepAlive() for providers with expensive resources
```

**Reference:** `docs/CODE_PATTERNS.md` for standard FitLog patterns.

### Step 1.3: File Inventory (Minimize New Files!)

**Goal:** Plan esatto di quali file toccare PRIMA di codare

```bash
# TodoWrite task: "Create file modification inventory"

☐ Files to MODIFY (prefer this over creating new):
   [ ] lib/features/workout/presentation/workout_screen.dart
       └─ Add: Quick export button
   [ ] lib/features/workout/presentation/providers/workout_provider.dart
       └─ Add: Export method call

☐ Files to CREATE (only if absolutely necessary):
   [ ] lib/features/workout/presentation/widgets/export_pdf_button.dart
       └─ New widget for PDF export UI
   [ ] lib/features/workout/data/services/pdf_export_service.dart
       └─ PDF generation logic (fat service)

☐ Files to READ (for context):
   [ ] lib/features/analytics/presentation/widgets/export_csv_button.dart
       └─ Reference implementation

# MINIMIZE PRINCIPLE:
- ✅ Edit existing files when possible
- ✅ Create new file only if >100 lines of NEW code
- ❌ Don't create file for 10-20 lines (add to existing)
- ❌ Don't create "helper" or "util" files prematurely

# NAMING CONVENTION CHECK:
- Screens: *_screen.dart
- Providers: *_provider.dart
- Widgets: descriptive_name.dart
- Services: *_service.dart
- Repositories: *_repository.dart
```

### Step 1.4: Performance Pre-Check

**Goal:** Prevent anti-patterns BEFORE writing code

```bash
# TodoWrite task: "Pre-check performance anti-patterns"

☐ Review CLAUDE.md performance rules (line 99-116)
☐ Check planned logic against anti-patterns:

# ANTI-PATTERNS TO AVOID:
┌──────────────────────────────────────────────────────────┐
│ ❌ WRONG                    │ ✅ CORRECT                  │
├────────────────────────────┼─────────────────────────────┤
│ for (x) { await box.put() }│ await box.putAll(entries)   │
│ for (x) { openBox() }      │ box = openBox(); for...     │
│ await a(); await b();      │ await Future.wait([a(), b()])│
│ Timer() ogni call          │ static final _timer         │
│ debugPrint in loop         │ debugPrint summary          │
│ setState in build          │ Provider state management   │
│ No const                   │ const where possible        │
└────────────────────────────┴─────────────────────────────┘

☐ Document planned optimizations:
   - Batch operations: [where]
   - Singleton managers: [which]
   - Parallel async: [what]
   - Debouncing: [where needed]
```

### Step 1.5: Design Approval (ASK USER!)

**Goal:** Get buy-in BEFORE coding

```bash
# TodoWrite task: "Get design approval from user"

# MANDATORY: Use AskUserQuestion tool or text to confirm design

# Present to user:
┌─────────────────────────────────────────────────────────┐
│ DESIGN SUMMARY                                          │
├─────────────────────────────────────────────────────────┤
│ Feature: [name]                                         │
│                                                          │
│ UX Research Insights:                                   │
│ - [key finding 1]                                       │
│ - [key finding 2]                                       │
│ - [key finding 3]                                       │
│                                                          │
│ Persona Impact: [summary of verdicts]                   │
│ ✅ Positive for: Marco, Chiara, Roberto                │
│ ⚠️ Neutral for: Luca, Sofia                            │
│ ❌ Negative for: None                                   │
│                                                          │
│ Architecture:                                           │
│ - Pattern: [name]                                       │
│ - Files to modify: [count]                             │
│ - Files to create: [count]                             │
│                                                          │
│ Performance:                                            │
│ - [optimization 1]                                      │
│ - [optimization 2]                                      │
│                                                          │
│ Estimated Complexity: [Low/Medium/High]                 │
└─────────────────────────────────────────────────────────┘

QUESTION: "Procedo con questo design?"

# Wait for user confirmation before Phase 2
```

---

## 💻 Phase 2: Surgical Coding (30% effort - Zero Over-Engineering)

### Step 2.1: Incremental Commits Strategy

**Goal:** Small, testable, reversible commits

```bash
# TodoWrite task: "Plan incremental commit strategy"

# COMMIT STRATEGY (bottom-up implementation):
Commit 1: Data Layer
   └─ Add service/repository
   └─ Message: "feat(feature): add data layer for X"

Commit 2: Domain Layer
   └─ Add entities/use cases if needed
   └─ Message: "feat(feature): add domain logic for X"

Commit 3: Presentation Layer - Logic
   └─ Add provider/state management
   └─ Message: "feat(feature): add state management for X"

Commit 4: Presentation Layer - UI
   └─ Add widgets/screens
   └─ Message: "feat(feature): add UI for X"

# ONE FEATURE = ONE BRANCH, MULTIPLE COMMITS
# NOT: one giant commit at the end
```

### Step 2.2: MANDATORY Rules Enforcement

**Goal:** Zero violations of CLAUDE.md rules

```bash
# TodoWrite task: "Verify MANDATORY rules compliance"

# AUTO-CHECK BEFORE EVERY FILE EDIT:
☐ Icons: AppIcons.* (NOT Icons.*)
☐ Text: context.l10n.* (NOT hardcoded strings)
☐ Colors: context.colors.* (NOT Colors.blue)
☐ Loading: LoadingIndicator() (NOT CircularProgressIndicator())
☐ Snackbar: SnackBarService.* (NOT ScaffoldMessenger)
☐ Icon Size: AppIconSize.medium (NOT hardcoded 24)

# iOS BUILD COMPLIANCE:
☐ NO const with context.l10n (causes iOS build error!)
   ❌ const Text(context.l10n.title)
   ✅ Text(context.l10n.title)

☐ context.l10n ONLY in Presentation layer
   ❌ Using in providers/domain/data
   ✅ Using only in widgets/screens

# IMPORTS:
☐ Use `hide Either, Right, Left` if using fpdart
☐ Import context extensions:
   - build_context_extensions.dart
   - color_scheme_extensions.dart
```

### Step 2.3: Follow Existing Patterns (NO New Abstractions)

**Goal:** Codice coerente con il resto del progetto

```dart
// TodoWrite task: "Implement following existing patterns"

// ✅ CORRECT: Follow FitLog patterns

// Provider Pattern (THIN):
@riverpod
class FeatureProvider extends _$FeatureProvider {
  @override
  FutureOr<FeatureState> build() async {
    ref.keepAlive(); // If expensive resources
    return FeatureState.initial();
  }

  Future<void> doSomething() async {
    // Delegate to service (FAT service pattern)
    final result = await ref.read(featureServiceProvider).execute();
    state = AsyncValue.data(result);
  }
}

// Service Pattern (FAT with singleton):
class FeatureService {
  static FeatureService? _instance;
  factory FeatureService() => _instance ??= FeatureService._();
  FeatureService._();

  bool _initialized = false;
  final _initLock = Lock();

  Future<void> initialize() async {
    await _initLock.synchronized(() async {
      if (_initialized) return;
      // ... initialization ...
      _initialized = true;
    });
  }

  Future<Result> execute() async {
    // Fat logic here, not in provider
  }
}

// Repository Pattern (BaseHybridRepository):
class FeatureRepository extends BaseHybridRepository<Feature> {
  FeatureRepository(super.firestore, super.hive);

  // Don't touch Firestore directly, use DataSource
  final _dataSource = FeatureDataSource();

  Future<List<Feature>> getAll() async {
    return await _dataSource.getAll();
  }
}

// ❌ WRONG: Don't create new patterns
class FeatureHelper { } // NO "helper" classes
class FeatureUtils { }   // NO "utils" for one-off use
class FeatureManager { } // NO redundant "manager" abstraction
```

**GOLDEN RULE:** If a pattern exists in the codebase, USE IT. Don't reinvent.

### Step 2.4: Zero Over-Engineering

**Goal:** Minimal code for current requirements

```bash
# TodoWrite task: "Avoid over-engineering"

# STOP YOURSELF FROM:
❌ Adding "future-proofing" abstractions
   "Let me create an interface for this in case we need multiple implementations..."
   → YAGNI (You Ain't Gonna Need It)

❌ Creating helpers for single use
   "Let me create a helper function in utils/"
   → Just inline it if used once

❌ Adding features not requested
   "While I'm here, let me also add..."
   → Scope creep, focus on requested feature only

❌ Premature optimization
   "Let me cache this in case it's slow..."
   → Optimize when proven slow, not before

❌ Over-commenting
   "Let me add docstrings to every method..."
   → Only comment non-obvious logic

# DO INSTEAD:
✅ Write minimum code to satisfy requirements
✅ Use existing abstractions
✅ Add features when requested, not "just in case"
✅ Optimize when performance-check.sh finds issues
✅ Comment only complex/non-obvious logic
```

---

## ✅ Phase 3: Quality Gates (15% effort - Zero Rework)

### Step 3.1: Automated Checks (Run Locally)

**Goal:** Catch issues BEFORE commit

```bash
# TodoWrite task: "Run all automated quality checks"

# MANDATORY CHECKS (in order):
☐ flutter analyze
   → MUST pass with zero errors
   → MUST pass with zero warnings (or document why warning is OK)

☐ performance-check.sh
   → Run: .claude/scripts/performance-check.sh lib/features/<modified>/
   → MUST show no new anti-patterns
   → If warnings found, fix BEFORE committing

☐ flutter gen-l10n (if added translations)
   → Regenerate localizations
   → Verify new keys in app_en.arb and app_it.arb

☐ Localization check (if added UI)
   → No hardcoded strings (grep for literals in new files)
   → All user-visible text uses context.l10n.*

# IF ANY CHECK FAILS:
   → FIX immediately, don't defer
   → Re-run checks after fix
   → Don't proceed to next step until GREEN
```

### Step 3.2: Build Verification (iOS + Android)

**Goal:** Ensure it compiles on both platforms

```bash
# TodoWrite task: "Verify builds on iOS and Android"

# iOS BUILD:
☐ flutter build ios --debug
   → Check for build errors
   → Special attention to const + context.l10n errors
   → Verify no Swift bridge issues if touching native

# ANDROID BUILD:
☐ flutter build apk --debug
   → Check for build errors
   → Verify no Kotlin/Java issues if touching native

# IF BUILD FAILS:
   → Check error message carefully
   → Common iOS issue: const Text(context.l10n.*)
   → Common Android issue: missing permissions in AndroidManifest.xml
   → Fix and re-build
```

### Step 3.3: Manual Testing Checklist

**Goal:** Test happy path + edge cases

```bash
# TodoWrite task: "Execute manual testing checklist"

# HAPPY PATH:
☐ Test primary user flow
☐ Test on iOS simulator/device
☐ Test on Android emulator/device
☐ Test with dark mode (if applicable)
☐ Test with Italian locale (if UI text)
☐ Test with English locale

# EDGE CASES:
☐ Test with empty state (no data)
☐ Test with error state (network off)
☐ Test with loading state
☐ Test with maximum data (100+ items if list)
☐ Test rapid taps (debouncing working?)

# PERSONAS VALIDATION:
☐ Would Marco understand this? (beginner-friendly?)
☐ Would Chiara find it quick? (no friction?)
☐ Would Luca get the data he needs? (detailed enough?)
☐ Would Sofia see progress? (visual feedback?)
☐ Would Roberto integrate smoothly? (Apple ecosystem?)

# REGRESSION CHECK:
☐ Open existing features (workout, analytics, timer)
☐ Verify nothing broke
☐ Check for unexpected side effects
```

### Step 3.4: Performance Validation

**Goal:** Ensure no performance regression

```bash
# TodoWrite task: "Validate performance metrics"

# POST-IMPLEMENTATION:
☐ Re-run performance-check.sh on modified files
☐ Compare with pre-implementation (saved earlier)
☐ Check for new warnings

# FLUTTER DEVTOOLS (optional for complex features):
☐ Open Flutter DevTools → Performance
☐ Record 10-second session using the feature
☐ Check for:
   - Frames > 16ms (jank)
   - Excessive rebuilds
   - Memory leaks (GC events spike)

# METRICS TO WATCH:
- Build method calls: Should be minimal for unchanged state
- Memory usage: Should not grow unbounded
- Frame rendering: Should be <16ms (60fps)

# IF REGRESSION FOUND:
   → Apply performance patterns from CLAUDE.md
   → Re-test until metrics are acceptable
```

---

## 📚 Phase 4: Auto-Documentation (5% effort)

### Step 4.1: Update INDEX.md

**Goal:** Documentazione sempre aggiornata

```bash
# TodoWrite task: "Update documentation automatically"

# PROCESS:
☐ Open docs/INDEX.md
☐ Add entry for new feature:
   - In appropriate section (Features, Analytics, etc.)
   - Link to any new docs created
   - Brief description (1 line)

# EXAMPLE:
## Features
- [Workout Tracking](features/WORKOUT_TRACKING.md)
- [Timer & Live Activities](features/TIMER_LIVE_ACTIVITIES.md)
- [PDF Export](features/PDF_EXPORT.md) ← NEW
  └─ Export workout history as PDF with charts

☐ Update CLAUDE.md feature mapping if significant:
   - Add to feature list
   - Add to persona-feature matrix if applicable
```

### Step 4.2: ADR if Architectural Decision

**Goal:** Document "why" for future reference

```bash
# TodoWrite task: "Create ADR if architectural decision made"

# CREATE ADR ONLY IF:
☐ Made architectural choice (pattern, library, approach)
☐ Trade-offs were considered
☐ Decision impacts future development
☐ Team should know rationale

# TEMPLATE: docs/ADR/TEMPLATE.md
# NAMING: docs/ADR/YYYYMMDD-<title>.md

# Example:
docs/ADR/20260124-pdf-export-library-choice.md

# Status: Accepted
# Context: Need to export workout history as PDF
# Decision: Use pdf package from pub.dev
# Rationale:
  - Widely used (8k+ likes)
  - Pure Dart (no native dependencies)
  - Supports charts via pdf_widgets
# Consequences:
  - Positive: Easy to maintain, cross-platform
  - Negative: Limited styling compared to native
  - Neutral: Need to handle large files (>10MB)
```

### Step 4.3: Git Commit with Co-Authored-By

**Goal:** Professional commit history

```bash
# TodoWrite task: "Create final commit(s)"

# COMMIT MESSAGE TEMPLATE:
git commit -m "$(cat <<'EOF'
feat(feature-area): brief description

- Detailed point 1 (what changed)
- Detailed point 2 (why changed)
- Detailed point 3 (impact)

Closes #issue-number

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# COMMIT TYPE:
feat:     New feature
fix:      Bug fix
docs:     Documentation only
style:    Formatting changes
refactor: Code restructuring
test:     Test additions/changes
chore:    Maintenance tasks

# EXAMPLES:
feat(workout): add PDF export functionality

- Added PDFExportService for workout history
- Created export button in workout history screen
- Integrated with existing analytics charts
- Supports both light/dark mode rendering

Persona Impact: ✅ Luca ++, Sofia +, Roberto +
Performance: No regressions, batch operations used

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## 🎯 Complete Workflow Example

### Example: "Add Superset Linking Feature"

```bash
═══════════════════════════════════════════════════════════
PHASE 0: RESEARCH & CONTEXT (15%)
═══════════════════════════════════════════════════════════

[UX Research]
Query 1: "superset workout tracking UX best practices 2026"
Query 2: "exercise pairing interface mobile apps"
Query 3: "workout superset visualization design"

Key Findings:
├─ Industry Standard: Visual connection line between exercises (Hevy, Strong)
├─ Pattern: Tap-to-pair + visual indicator (bracket or line)
├─ Anti-pattern: Complex multi-step setup (users abandon)
├─ Accessibility: Clear visual + haptic feedback on link
├─ Mobile: Drag-to-connect too fiddly, prefer tap

[Persona Analysis]
┌─────────────────────────────────────────────────────────────┐
│ PERSONA IMPACT ANALYSIS                                      │
├──────────────┬──────────┬───────────────────────────────────┤
│ Marco        │ 0        │ Won't use early, but not confusing│
│ Chiara       │ ++       │ Faster workouts with supersets   │
│ Luca         │ +++      │ Advanced training technique       │
│ Sofia        │ ++       │ Efficient for hypertrophy         │
│ Roberto      │ +        │ Time-efficient training           │
├──────────────┴──────────┴───────────────────────────────────┤
│ VERDICT: ✅ PROCEDI - Strong positive impact               │
└─────────────────────────────────────────────────────────────┘

[Pattern Search]
Found: lib/features/workout/presentation/widgets/exercise_list_item.dart
Reuse: Visual connection pattern from existing UI

[File Inventory]
MODIFY (2):
  - lib/features/workout/presentation/workout_screen.dart
  - lib/features/workout/presentation/providers/workout_provider.dart

CREATE (2):
  - lib/features/workout/presentation/widgets/superset_link_modal.dart
  - lib/features/workout/domain/entities/superset_group.dart

═══════════════════════════════════════════════════════════
PHASE 1: DESIGN (35%)
═══════════════════════════════════════════════════════════

[Architecture Decision]
Pattern: Modal dialog for pairing (follows FitLog pattern)
Layers:
  └─ Domain: SupersetGroup entity
  └─ Presentation: Link modal + provider logic
  └─ Data: Save in existing workout entity

[Performance Pre-Check]
✅ No loops with I/O
✅ Single modal open (no nested modals)
✅ Visual update uses Riverpod (no setState)

[Design Approval]
→ Ask user: "Procedo con modal-based pairing + visual bracket?"
→ User confirms: "Yes, proceed"

═══════════════════════════════════════════════════════════
PHASE 2: CODING (30%)
═══════════════════════════════════════════════════════════

[Commit 1: Domain]
feat(workout): add superset domain entity
- Created SupersetGroup entity
- Added to workout model

[Commit 2: UI Modal]
feat(workout): add superset linking modal
- Created superset_link_modal.dart
- Uses AppIcons, context.l10n, context.colors ✅
- No const with context.l10n ✅

[Commit 3: Integration]
feat(workout): integrate superset UI in workout screen
- Added link button to exercise items
- Visual bracket rendering
- Provider logic for pairing

═══════════════════════════════════════════════════════════
PHASE 3: QUALITY GATES (15%)
═══════════════════════════════════════════════════════════

[Automated Checks]
✅ flutter analyze → 0 errors, 0 warnings
✅ performance-check.sh → No anti-patterns found
✅ flutter gen-l10n → Updated localizations

[Build Verification]
✅ iOS build → Success
✅ Android build → Success

[Manual Testing]
✅ Happy path: Link 2 exercises → Visual bracket appears
✅ Edge case: Unlink exercises → Bracket disappears
✅ Regression: Existing workout features work
✅ Persona check: Chiara finds it quick, Luca loves it

[Performance]
✅ No frame drops
✅ No memory leaks
✅ Rebuilds minimal

═══════════════════════════════════════════════════════════
PHASE 4: DOCUMENTATION (5%)
═══════════════════════════════════════════════════════════

[INDEX.md Updated]
## Features
- [Superset Linking](features/SUPERSET_LINKING.md)
  └─ Link exercises into supersets with visual indicators

[Git Commit]
feat(workout): add superset linking feature

- Users can pair exercises into supersets via modal
- Visual bracket indicator shows linked exercises
- Saves in workout entity, syncs to Firestore
- Follows industry UX patterns (tap-to-pair)

Persona Impact: ✅ Luca +++, Chiara ++, Sofia ++
UX Research: Based on Hevy/Strong patterns
Performance: No regressions

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>

═══════════════════════════════════════════════════════════
RESULT: Production-ready feature in ~45 minutes
═══════════════════════════════════════════════════════════
```

---

## 🎓 Integration with Other Skills

**This skill works WITH:**

| Skill | When to Use Together |
|-------|---------------------|
| `/fitlog` | Suggests surgical-feature-implementation for new features |
| `/context` | Phase 0: Load git history + recent changes |
| `/persona-check` | Phase 1: Deep persona analysis if complex UX |
| `flutter-architect` | Phase 1: Complex architecture decisions |
| `performance-optimizer` | Phase 3: If performance issues found |
| `ios-specialist` | Phase 2/3: iOS native integrations |
| `firebase-expert` | Phase 2/3: Firestore/sync features |
| `systematic-debug` | If issues found during implementation |

**Workflow:**
```
User requests feature
    ↓
/fitlog analyze → "Use surgical-feature-implementation"
    ↓
/surgical-feature-implementation
    ↓
Phase 0: Research (WebSearch + episodic-memory)
    ↓
Phase 1: Design (Persona analysis + architecture)
    ↓
Phase 2: Code (Following patterns)
    ↓
Phase 3: Verify (Auto-checks)
    ↓
Phase 4: Document (INDEX.md + commit)
    ↓
Production-ready feature ✅
```

---

## 🚫 Anti-Patterns to Avoid

**DON'T:**
- ❌ Skip UX research ("I know what's best")
- ❌ Skip persona analysis ("It's obvious this is good")
- ❌ Code before design approval ("I'll show them code")
- ❌ Create files without inventory ("I'll refactor later")
- ❌ Skip automated checks ("I tested manually")
- ❌ Defer documentation ("I'll do it later")

**DO:**
- ✅ Research industry standards BEFORE designing
- ✅ Analyze ALL 5 personas (even if seems obvious)
- ✅ Get approval on design summary
- ✅ Plan file changes before coding
- ✅ Run all automated checks before committing
- ✅ Document as part of implementation, not after

---

## 📊 Success Metrics

**Feature is considered "surgical" if:**

```bash
☐ Zero rework after initial implementation
☐ Zero violations of CLAUDE.md rules
☐ Zero performance regressions
☐ Zero build errors on first try
☐ Positive impact on 3+ personas
☐ Documentation updated same commit
☐ All automated checks passed
☐ Manual testing completed (happy + edge cases)
☐ User approved design before coding
☐ Incremental commits (not one giant commit)
```

**Typical Timeline:**
- Simple feature (1 screen, 1 widget): 30-45 min
- Medium feature (2-3 screens, data layer): 60-90 min
- Complex feature (multi-layer, native integration): 2-3 hours

**Time Breakdown (target):**
- Research: 10-15 min (WebSearch + context loading)
- Design: 20-30 min (personas + architecture + approval)
- Coding: 20-40 min (following patterns, incremental)
- Quality: 10-15 min (checks + manual testing)
- Documentation: 5 min (INDEX.md + commit)

---

## 🔗 Resources

**Internal FitLog docs:**
- `docs/INDEX.md` - Entry point
- `docs/USER_PERSONAS.md` - All 12 personas detailed ⭐
- `docs/DEVELOPMENT_RULES.md` - MANDATORY rules
- `docs/CODE_PATTERNS.md` - Repository/Provider patterns
- `docs/architecture/OVERVIEW.md` - Clean Architecture
- `CLAUDE.md` - Quick reference + performance rules
- `.claude/commands/persona-check.md` - Persona analysis framework

**External resources - UX Best Practices:**
- [Mobile UX Design Principles](https://www.nngroup.com/articles/mobile-ux/)
- [Fitness App UX Patterns](https://www.smashingmagazine.com/category/ux-design)
- [Material Design Guidelines](https://m3.material.io/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

**External resources - Feature Implementation:**
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Feature-First Architecture](https://codewithandrea.com/articles/flutter-project-structure/)
- [Incremental Development](https://martinfowler.com/articles/continuousIntegration.html)

---

## 🎯 Golden Rules

```
╔════════════════════════════════════════════════════════════╗
║  1. RESEARCH before DESIGN                                ║
║     → WebSearch reveals what users expect                 ║
║                                                            ║
║  2. PERSONAS before CODE                                  ║
║     → Every feature evaluated with 5 personas             ║
║                                                            ║
║  3. APPROVAL before IMPLEMENTATION                        ║
║     → Design summary confirmed before coding              ║
║                                                            ║
║  4. PATTERNS before REINVENTION                           ║
║     → Reuse beats reinvent, always                        ║
║                                                            ║
║  5. CHECKS before COMMIT                                  ║
║     → Automated quality gates prevent rework              ║
║                                                            ║
║  6. DOCUMENT with CODE                                    ║
║     → Documentation = part of deliverable                 ║
╚════════════════════════════════════════════════════════════╝
```

**Remember:** The goal is NOT to code fast, but to code RIGHT the first time.

Spending 20 minutes on design saves 2 hours of debugging and rework.

---

**END OF SKILL**

*"Measure twice, cut once. Research first, code last."*
