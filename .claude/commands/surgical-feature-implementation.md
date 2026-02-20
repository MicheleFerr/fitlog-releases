---
name: surgical-feature-implementation
description: Implementazione chirurgica di feature con ricerca UX best practices e analisi personas obbligatoria. Zero rework, codice production-ready al primo commit.
---

# Surgical Feature Implementation

**Use for:** New features, significant modifications, UX-impacting changes.
**Not for:** Bug fixes (use `systematic-debug`), typos, minor fixes (<10 lines).

**Time split:** RESEARCH 15% > DESIGN 35% > CODE 30% > VERIFY 15% > DOC 5%

---

## Pre-Implementation Checklist

Before starting, verify ALL items:

```
[ ] Describe feature (what it does, why it's needed)
[ ] Research UX best practices (2-3 WebSearch queries)
[ ] Persona Impact Analysis (table below)
[ ] Search codebase for existing patterns (glob/grep)
[ ] Check episodic-memory for similar past work
[ ] Check recent git changes (git log --since="1 week ago" --oneline)
[ ] List files to modify/create (minimize new files)
```

---

## Phase 0: Research & Context (15%)

### 0.1 UX Best Practices Research

Execute 2-3 WebSearch queries based on feature type. Extract:
- Industry standards (what top apps do)
- Common patterns (what users expect)
- Anti-patterns (what to avoid)
- Accessibility and mobile-specific considerations

Summarize findings in 5-10 bullet points with sources.

### 0.2 Project Context Loading

```
[ ] git status --short (uncommitted changes?)
[ ] Search similar code in lib/features/*/
[ ] Check lib/shared/presentation/widgets/ for reusable components
[ ] Check episodic-memory for lessons learned
```

---

## Phase 1: Surgical Design (35%)

### 1.1 Persona Impact Analysis (MANDATORY)

Create this table for EVERY feature:

```
Feature: [name]
| Persona            | Impact | Rationale                    |
|--------------------|--------|------------------------------|
| Marco (Beginner)   | +/0/-  | [how it helps/hurts]         |
| Chiara (Busy Mom)  | +/0/-  | [time-saving? friction?]     |
| Luca (Powerlifter) | +/0/-  | [detailed data? analytics?]  |
| Sofia (Aesthetic)   | +/0/-  | [visible progress?]          |
| Roberto (Busy Pro) | +/0/-  | [efficiency? integration?]   |

VERDICT: [Proceed / Revise / Block]
```

**Decision rules:**
- BLOCK if any persona has "--" or 3+ have "-"
- REVISE if any primary persona has "-" or feature ignores 2+ personas
- PROCEED if no "--", max 1-2 "-" with mitigations, positive for 3+

**Mitigation options:** opt-in/opt-out, progressive disclosure, tutorial, simplify for beginners.

### 1.2 Architecture Design

```
[ ] Identify Clean Architecture layers needed (Domain/Data/Presentation)
[ ] Find similar patterns in codebase to reuse
[ ] Document pattern choice + rationale
[ ] Follow: Provider THIN + Service FAT, BaseHybridRepository, DataSource pattern
```

Refer to CLAUDE.md for pattern templates and performance rules.

### 1.3 File Inventory

```
[ ] Files to MODIFY (prefer over creating new)
[ ] Files to CREATE (only if >100 lines of new code)
[ ] Files to READ (for reference)
```

Minimize principle: edit existing files when possible. No premature "helper" or "util" files.

### 1.4 Design Approval

Present to user before coding:
- UX research key insights
- Persona impact summary
- Architecture pattern + file plan
- Estimated complexity (Low/Medium/High)

**Wait for user confirmation before Phase 2.**

---

## Phase 2: Surgical Coding (30%)

### 2.1 Incremental Commits (bottom-up)

```
Commit 1: Data Layer   → service/repository
Commit 2: Domain Layer  → entities/use cases
Commit 3: Presentation  → providers/state
Commit 4: UI            → widgets/screens
```

One feature = one branch, multiple small commits.

### 2.2 Coding Principles

Follow all rules from CLAUDE.md (icons, l10n, colors, performance). Additionally:

**Zero over-engineering:**
- No "future-proofing" abstractions (YAGNI)
- No helper files for single use (inline it)
- No features not requested (scope creep)
- No premature optimization (optimize when proven slow)
- Comment only non-obvious logic

**Pattern reuse:**
- If a pattern exists in the codebase, USE IT
- No new "Helper", "Utils", or "Manager" classes unless justified
- Delegate logic to services (fat service), keep providers thin

---

## Phase 3: Quality Gates (15%)

### 3.1 Automated Checks (ALL must pass)

```
[ ] flutter analyze → zero errors and warnings
[ ] .claude/scripts/performance-check.sh lib/features/<modified>/
[ ] flutter gen-l10n (if added translations)
[ ] grep for hardcoded strings in new files
```

Fix immediately if any check fails. Do not defer.

### 3.2 Build Verification

```
[ ] flutter build ios --debug
[ ] flutter build apk --debug
```

### 3.3 Manual Testing

```
Happy path:
[ ] Primary user flow on iOS + Android
[ ] Dark mode, Italian + English locale

Edge cases:
[ ] Empty state, error state, loading state
[ ] Maximum data (100+ items)
[ ] Rapid taps (debouncing)

Personas:
[ ] Marco: understandable? Chiara: quick? Luca: detailed?
[ ] Sofia: visual? Roberto: smooth?

Regression:
[ ] Existing features still work
```

---

## Phase 4: Documentation (5%)

```
[ ] Update docs/INDEX.md with new feature entry
[ ] Create ADR if architectural decision was made (docs/ADR/YYYYMMDD-<title>.md)
[ ] Commit with descriptive message + Co-Authored-By
```

---

## Golden Rules

1. **RESEARCH before DESIGN** -- WebSearch reveals what users expect
2. **PERSONAS before CODE** -- Every feature evaluated with 5 personas
3. **APPROVAL before IMPLEMENTATION** -- Design confirmed before coding
4. **PATTERNS before REINVENTION** -- Reuse beats reinvent
5. **CHECKS before COMMIT** -- Automated gates prevent rework
6. **DOCUMENT with CODE** -- Documentation = part of deliverable

The goal is not to code fast, but to code RIGHT the first time.
