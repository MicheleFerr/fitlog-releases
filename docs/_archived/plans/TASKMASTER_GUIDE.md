# 🎯 Task-Master.dev Integration Guide

> **COMPORTAMENTO AUTOMATICO**: Claude rileva richieste complesse e propone task-master.dev planning.

---

## 🧠 Smart Detection Logic

Quando ricevi una richiesta, Claude analizza automaticamente:

1. ✓ Lunghezza > 50 parole?
2. ✓ Keyword presente? ("implement", "refactor", "migrate", "create system")
3. ✓ Multi-layer mention? ("domain + data + presentation")
4. ✓ Milestone mention? ("fase 1", "milestone 2")

**Se 2+ condizioni → propone task-master.dev**

### Trigger Keywords
- `implement`, `implementa`, `create`, `crea`
- `refactor`, `migrate`, `migra`
- `system`, `sistema`, `feature`
- `add`, `aggiungi`, `build`, `costruisci`
- `milestone`, `fase`, `phase`, `step`

### Esempi
- ✅ "Implement analytics system with charts" → TRIGGER
- ✅ "Refactor workout timer to use background tasks" → TRIGGER
- ❌ "Fix typo in button text" → NO TRIGGER
- ❌ "Update color to blue" → NO TRIGGER

---

## 💬 Automatic Proposal

Quando triggered:

```
🤖 Ho rilevato una richiesta complessa:
   - Lunghezza: {word_count} parole
   - Keyword rilevata: '{keyword}'
   - Stima complessità: {HIGH/MEDIUM}

   Vuoi che usi task-master.dev per decomporre questo progetto?

   [Sì] → Genero piano dettagliato
   [No] → Implemento direttamente
   [Preview] → Mostro cosa farebbe
```

---

## 🌐 WebFetch Integration

### Step 1: Prepare Prompt
```
Break down the following Flutter/Dart development task into
manageable, atomic tasks following Clean Architecture pattern:

Task: {original_request}

Context:
- Framework: Flutter
- Architecture: Clean Architecture (Domain/Data/Presentation)
- State Management: Riverpod 2.x
- Platforms: iOS 14+, Android 8+
- Key requirements: Localization (EN/IT), Theme support (dark/light)

Output format:
- Task list with category grouping
- Estimated time per task (15min - 1.5h max)
- Dependencies between tasks
- Verification criteria per task

Provide 8-15 tasks total.
```

### Step 2: Execute
```dart
WebFetch(
  url: "https://www.task-master.dev/",
  prompt: enriched_prompt
)
```

### Step 3: Enrich Response
- Add "Localization" task if missing
- Add "Theme compliance" task if missing
- Add "flutter analyze" task if missing
- Add file paths (`lib/features/{feature}/`)
- Add test tasks if missing

### Fallback Strategy
Se WebFetch fallisce:
- A) Riprova tra 30 secondi
- B) Genera piano manualmente (Claude autonomo)
- C) Procedi diretto senza planning

---

## 📄 Plan Template

### Header
```markdown
# {Topic Title} - Task Plan

**Generated**: {YYYY-MM-DD HH:mm}
**Source**: task-master.dev (WebFetch)
**Complexity Score**: HIGH/MEDIUM/LOW
**Total Tasks**: {count}
**Estimated Time**: ~{hours}h
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: {from pubspec.yaml}
- Key Packages: riverpod, firebase_core
- Target Platforms: iOS 14+, Android 8+
```

### Task Breakdown
```markdown
## 🎯 Task Breakdown

### 1. Domain Layer

- [ ] **Task 1.1**: Create {Entity} entity
  - **Layer**: Domain
  - **Files**: `lib/features/{feature}/domain/entities/{entity}.dart`
  - **Dependencies**: None
  - **Est. Time**: 30 min
  - **Blocking**: Yes (blocks Task 1.2, 2.1)
  - **Verification**: Entity compiles + freezed code generated
```

### Implementation Order
```markdown
## 📊 Implementation Order

**MUST DO FIRST** (blocking tasks):
→ Task 1.1, 1.2 (domain foundation)

**THEN** (parallel workable):
→ Task 2.1, 2.2 (data layer)

**FINALLY**:
→ Task 4.1-4.3 (UI)
→ Task 5.1 (testing)
```

---

## 💾 Save Workflow

### Filename Format
```
YYYY-MM-DD-{topic-slug}-plan.md

Examples:
- 2025-01-15-analytics-system-plan.md
- 2025-01-15-workout-timer-refactor-plan.md
```

### Location
```
docs/plans/{filename}
```

**Note**: `docs/plans/` è in `.gitignore` → file restano locali

---

## 📝 TodoWrite Conversion

### Smart Grouping
| Task Count | Strategy |
|------------|----------|
| <10 tasks | Direct mapping (1:1) |
| 10-20 tasks | Category grouping |
| >20 tasks | Milestone grouping |

### Format Mapping
```dart
// Plan task:
- [ ] **Task 1.1**: Create AnalyticsData entity

// TodoWrite item:
{
  content: "Create AnalyticsData entity (Domain layer)",
  activeForm: "Creating AnalyticsData entity",
  status: "pending"
}
```

---

## 📦 CONTEXT.md Auto-Update

Per feature con 5+ milestones:

```markdown
## 📦 Milestone {X}: {Feature Name} (✅ Complete)

**Plan**: [YYYY-MM-DD-{topic}-plan.md](./plan.md)
**Completed**: {timestamp}
**Actual Time**: {hours}h (estimated: {est_hours}h)

**Key Decisions** (inherited by M{X+1}):
- ✅ {Decision 1}
- ✅ {Decision 2}

**Artifacts Created**:
- `lib/features/{feature}/{layer}/{file}.dart`

**Tech Debt Introduced**:
- {Debt description} → Cleanup in M{X+1}

**Blocks**: M{X+1}
```

---

## 📚 LEARNINGS.md Auto-Population

### Estimation Patterns
```markdown
| Task Type | Initial | Actual | Adjustment |
|-----------|---------|--------|------------|
| Entity creation | 30 min | 45 min | +50% |
```

### Common Pitfalls
```markdown
### Firebase Security Rules Always Take Longer
- **Origin**: M1 Analytics
- **Issue**: Estimated 30 min, took 45 min
- **Solution**: Add +15 min buffer
```

### Successful Patterns
```markdown
### Task Ordering by Layer
- **Origin**: M1-M3 Analytics
- **Keep doing**: Order tasks Domain → Data → Presentation
```

---

## 📦 Plan Versioning

### Version Detection
```markdown
**Plan Version**: 1.0  →  **Plan Version**: 1.1
```

### Version History
```markdown
## 📝 Version History

### v1.1 - {YYYY-MM-DD HH:MM}
**Changes**:
- ✏️ Modified task 3.2: Added Firebase security
- ➕ Added new task 4.1: Integration testing
- 📊 Updated time: 4.5h → 5.5h

### v1.0 - {YYYY-MM-DD HH:MM}
**Initial plan generation**
```

### When to Increment
| Scenario | Increment |
|----------|-----------|
| Task added/removed | MINOR (1.0 → 1.1) |
| Task modified | MINOR |
| Dependencies changed | MINOR |
| Time estimate >30% change | MINOR |
| Architecture changed | MAJOR (1.0 → 2.0) |
| Typo fixes | NO INCREMENT |

---

## 🎯 Golden Rules

1. **SEMPRE rileva complessità** prima di implementare
2. **SEMPRE proponi** task-master.dev se triggered
3. **SEMPRE arricchisci** con Flutter/FitLog Pro requirements
4. **SEMPRE valida** plan quality prima di salvare
5. **SEMPRE salva** plan in docs/plans/ (local)
6. **SEMPRE crea** TodoWrite dopo plan save
7. **MAI skip** proposal step

**Quando in dubbio**: Proponi task-master.dev. È meglio over-plan che under-plan.
