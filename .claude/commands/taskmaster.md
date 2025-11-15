# /taskmaster - Generate Task Plan via task-master.dev

Use task-master.dev integration to decompose complex requests into manageable task plans.

## Usage

When user types `/taskmaster`, follow REGOLA #14 workflow from CLAUDE.md:

1. **Detect Complexity** (automatic - already triggered by slash command)
2. **Propose Planning** (skip - user explicitly requested via /taskmaster)
3. **WebFetch Call** → task-master.dev
4. **Generate Plan** → docs/plans/YYYY-MM-DD-{topic}-plan.md
5. **Create TodoWrite** → Smart grouping based on task count
6. **Update CONTEXT.md** (if 5+ milestones)
7. **Prompt Retrospective** (after milestone completion)

## Workflow

```
User: /taskmaster "Implement analytics system"
         ↓
Claude: "🎯 Using task-master.dev integration...

         Calling API with enriched Flutter context..."
         ↓
WebFetch(task-master.dev, prompt: enriched_request)
         ↓
Claude: "✅ Plan generated!

         📊 Riepilogo:
         - Total Tasks: 12
         - Estimated Time: ~5.5h
         - Complexity: HIGH

         Piano salvato: docs/plans/2025-01-15-analytics-system-plan.md

         Vuoi che crei TodoWrite basato su questo piano?"
         ↓
User: "Sì"
         ↓
Claude creates TodoWrite with smart grouping
         ↓
Claude: "✅ TodoWrite creato con 12 task!

         Procedo con l'implementazione?"
```

## Smart Detection Bypass

Using `/taskmaster` BYPASSES smart detection (user explicitly wants planning).

**Direct execution**:
- No complexity analysis needed
- No "Vuoi che usi task-master.dev?" prompt
- Directly to WebFetch call

## Fallback

If WebFetch fails:
- Offer retry OR manual planning
- Same as REGOLA #14 fallback strategy

## See Also

- `CLAUDE.md` - REGOLA #14 for full behavioral rules
- `scripts/taskmaster_plan.sh` - CLI alternative
- `docs/plans/CONTEXT.md` - Milestone tracking
- `docs/plans/LEARNINGS.md` - Pattern database
