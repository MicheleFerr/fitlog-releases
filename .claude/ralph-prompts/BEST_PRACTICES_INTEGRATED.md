# 🎯 Ralph Loop Best Practices - Integrated

**Data**: 2026-02-02
**Fonti**: Reddit, Medium, DEV Community, GitHub, blog personali

Questo documento riassume i **nuovi insights** integrati nel prompt `production-readiness-check.md` dopo research community.

---

## 🆕 Nuovi Insights Aggiunti

### 1. **HITL vs AFK Operating Modes** 🎮

**Source**: [11 Tips for AI Coding with Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)

| Mode | Quando | Come | Perché |
|------|--------|------|--------|
| **HITL** (Human-in-the-Loop) | Prime 2-3 run | Monitora ogni iterazione | Learn Ralph, optimize prompts, build confidence |
| **AFK** (Away From Keyboard) | Dopo prompts stabili | Set & forget | True leverage - puoi fare altro |

**Critical**: SEMPRE usa `--max-iterations` in AFK mode (primary safety mechanism).

**Integrated in**: Sezione "🎯 HITL vs AFK Modes" del prompt.

---

### 2. **Plans Are Disposable** 🗑️

**Source**: [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)

```
"A plan that drifts is cheaper to regenerate than to salvage."
"Don't fight stale state."
```

**Implicazione**: Se Ralph fallisce 2+ volte stesso task → NON provare a fixare il piano, RIGENERALO.

**Integrated in**: Blocker condition "Stesso error 2+ volte → REGEN plan".

---

### 3. **Permission Boundaries** 🔒

**Source**: [Medium - Ralph Production Patterns](https://medium.com/@ValentinNagacevschi/the-ralph-loop-when-your-prd-becomes-the-steering-wheel-5abf6b1345c0)

**Problem**: "Agent can edit everything" → wake up to refactor dell'intero repo.

**Solution**: Definisci scope espliciti:

| Permission Level | Files | Rationale |
|-----------------|-------|-----------|
| ✅ **Full access** | `lib/features/`, `test/`, `docs/` | Safe to modify without risk |
| ⚠️ **Requires check** | `lib/main.dart`, `firestore.rules`, `functions/src/` | Critical but Ralph can propose changes |
| ❌ **Blocked** | `ios/Runner/`, `android/app/`, `.git/`, `.env` | Native code or secrets - human only |

**Integrated in**: Sezione "🔒 Permission Boundaries" del prompt.

---

### 4. **3-Phase Workflow** 📊

**Source**: [Awesome Ralph](https://awesomeclaude.ai/ralph-wiggum)

```
Phase 1: Requirements Analysis (Iteration 1-2)
         → Understand state, define "done"

Phase 2: Planning Mode (Iteration 3-5)
         → Task-by-task implementation plan

Phase 3: Building Mode (Iteration 6-50)
         → Implement + iterate until completion
```

**Benefit**: Struttura chiara invece di "just iterate".

**Integrated in**: Sezione "🔄 3-Phase Workflow" del prompt.

---

### 5. **Stop Conditions** (Anti-Loop-Infinito) 🛑

**Source**: [Ralph Playbook](https://claytonfarr.github.io/ralph-playbook/)

```
⚠️ "If tests fail in the same way twice → force re-plan or human check"
⚠️ "Infinite loops are not persistence, they're a space heater"
```

**Critical**: Max iterations NON è optional, è **primary safety mechanism**.

**Integrated in**: Blocker "Stesso error 2+ volte" nel prompt.

---

### 6. **Manageable Change Sets** 📦

**Source**: [Everything Is Ralph Loop](https://ghuntley.com/loop/)

```
"Waking up to one small refactor every morning > waking up to 50"
"Run ONCE on a cron overnight, merge small iterations over time"
```

**For existing codebases**: Batch mode - pause ogni 10-20 iterazioni per human review.

**Integrated in**: Sezione "📦 Manageable Change Sets" con batch strategy.

---

### 7. **Cost Data** 💰

**Source**: [Ralph Tips](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)

| Metric | Value |
|--------|-------|
| Burn rate | $10.42 USD/ora (Sonnet 3.5) |
| Success story | $50k contract → $297 USD total |
| **FitLog estimate** | 50 iter x 4min = ~3.5h = **~$36 USD** |
| Manual equivalent | ~25h human work |
| **ROI** | **~700% time savings** |

**Integrated in**: Sezione "💰 Cost Estimate" del prompt.

---

## 📊 Comparison: Before vs After Integration

| Aspect | Before (Original Prompt) | After (Integrated Best Practices) |
|--------|--------------------------|-----------------------------------|
| **Operating Model** | Not specified | HITL (learn) → AFK (leverage) |
| **Stop Conditions** | Basic blockers | +Same error 2x → regen plan |
| **Permissions** | Implicit | Explicit boundaries (3 levels) |
| **Workflow** | Linear iteration | 3-Phase structured (Req → Plan → Build) |
| **Change Management** | All-at-once | Batch mode for safety |
| **Cost Visibility** | Unknown | $36 USD estimated, 700% ROI |
| **Plan Management** | Fix when stale | Disposable - regen when drift |

---

## 🎯 Key Takeaways

### ✅ **Do's**

1. ✅ **Start HITL** - Prime 2-3 run monitorate per tune prompt
2. ✅ **Use --max-iterations** - Primary safety (50 per FitLog)
3. ✅ **Define permission boundaries** - Prevent unwanted refactors
4. ✅ **Batch mode** - Per codebase esistenti, piccole iterazioni
5. ✅ **Regen stale plans** - Don't fight drift, regenerate
6. ✅ **Track costs** - ~$10/ora Sonnet, budget accordingly

### ❌ **Don'ts**

1. ❌ **No infinite loops** - Max iterations è mandatory
2. ❌ **Don't salvage stale plans** - Cheaper to regen
3. ❌ **Don't give full filesystem access** - Permission boundaries critical
4. ❌ **Don't skip HITL** - Learn before AFK
5. ❌ **Don't ignore same error 2x** - Force re-plan or human check

---

## 📚 Community Resources Used

### Primary Sources

| Resource | What We Learned | Link |
|----------|-----------------|------|
| **Geoffrey Huntley's Blog** | Philosophy, original technique | [ghuntley.com/ralph](https://ghuntley.com/ralph/) |
| **Ralph Orchestrator** | Production patterns, implementation | [GitHub](https://github.com/mikeyobrien/ralph-orchestrator) |
| **11 Tips for Ralph** | HITL/AFK modes, cost data | [aihero.dev](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) |
| **Ralph Playbook** | Plans are disposable, stop conditions | [GitHub](https://github.com/ClaytonFarr/ralph-playbook) |
| **Everything Is Ralph Loop** | Manageable change sets, overnight runs | [ghuntley.com/loop](https://ghuntley.com/loop/) |
| **Awesome Ralph** | 3-Phase workflow, community resources | [GitHub](https://github.com/snwfdhmp/awesome-ralph) |
| **Medium - Ralph Patterns** | Permission boundaries, production safety | [Medium](https://medium.com/@ValentinNagacevschi/the-ralph-loop-when-your-prd-becomes-the-steering-wheel-5abf6b1345c0) |

### Secondary Sources

- [DEV Community - 2026 Year of Ralph](https://dev.to/alexandergekov/2026-the-year-of-the-ralph-loop-agent-1gkj)
- [Ralph Wiggum Breakdown](https://dev.to/ibrahimpima/the-ralf-wiggum-breakdown-3mko)
- [Awesome Claude - Ralph Wiggum](https://awesomeclaude.ai/ralph-wiggum)
- [The Register - Ralph Loops Claude](https://www.theregister.com/2026/01/27/ralph_wiggum_claude_loops/)
- [HumanLayer - Brief History of Ralph](https://www.humanlayer.dev/blog/brief-history-of-ralph)

---

## 🚀 Next Steps

### For You (Michele)

1. **Review updated prompt**: Leggi `.claude/ralph-prompts/production-readiness-check.md`
2. **Understand modes**: HITL per prime run, poi AFK
3. **Check permission boundaries**: Verifica che siano OK per FitLog
4. **Budget**: ~$36 USD per 50 iterazioni (affordable)
5. **Launch when ready**: Al lavoro, con tempo per monitorare HITL

### For Ralph (Automated)

1. **Phase 1** (Iter 1-2): Requirements analysis + gap analysis
2. **Phase 2** (Iter 3-5): Planning mode + prioritized TODO
3. **Phase 3** (Iter 6-50): Building mode + iterate to completion
4. **Stop conditions**: Max 50 iter, same error 2x → regen, human blockers → wait

---

## 💡 Final Thoughts

**Before Integration**:
- Prompt funzionale ma generico
- Mancavano safety mechanisms community-tested
- Nessuna guidance su operating modes

**After Integration**:
- ✅ HITL/AFK operating model chiaro
- ✅ Permission boundaries per safety
- ✅ 3-Phase workflow strutturato
- ✅ Stop conditions anti-infinite-loop
- ✅ Batch mode per codebase esistenti
- ✅ Cost visibility + ROI calculation
- ✅ "Plans are disposable" philosophy

**Result**: Prompt **production-grade** basato su community wisdom di 100+ developers che usano Ralph in real projects.

---

**Last Updated**: 2026-02-02
**Integrated by**: Claude Sonnet 4.5
**For**: FitLog Pro Production Readiness Check
