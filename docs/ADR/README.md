# Architecture Decision Records (ADR)

This directory contains Architecture Decision Records for FitLog Pro.

## What is an ADR?

An ADR documents a significant architectural decision, including:
- **Context**: The situation that led to the decision
- **Decision**: What was decided
- **Consequences**: The trade-offs and implications

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [001](001-riverpod-over-bloc.md) | Riverpod over BLoC | Accepted | 2024-01 |
| [002](002-hive-over-sqlite.md) | Hive over SQLite | Accepted | 2024-01 |
| [003](003-hybrid-sync.md) | Local-first Hybrid Sync | Accepted | 2024-06 |
| [004](004-freezed-entities.md) | Freezed for Domain Entities | Accepted | 2024-01 |
| [005](005-clean-architecture.md) | Clean Architecture Pattern | Accepted | 2024-01 |

## Template

When adding a new ADR, use this template:

```markdown
# ADR-XXX: Title

## Status
Proposed | Accepted | Deprecated | Superseded

## Context
What is the issue that we're seeing that motivates this decision?

## Decision
What is the change that we're proposing?

## Consequences
What becomes easier or harder as a result?

### Pros
- ...

### Cons
- ...

## References
- Related docs
- External resources
```

## When to Write an ADR

Write an ADR when:
- Choosing between major technologies (database, state management, etc.)
- Changing the project structure significantly
- Making decisions that affect multiple features
- Deprecating existing patterns in favor of new ones
