# Ralph Loop Prompts for FitLog

Questa directory contiene prompt ottimizzati per Ralph Loop basati su best practice della community.

---

## 📁 Files

| File | Scopo |
|------|-------|
| `production-readiness-check.md` | **Prompt principale** - Production readiness completa (basato su PRODUCTION_READINESS.md) |
| `HOW_TO_START.md` | **Quick start guide** - Come avviare e monitorare Ralph Loop |
| `README.md` | Questo file - Overview della directory |

---

## 🚀 Quick Start

```bash
# Quando sei pronto per il production readiness check:
cd /Users/michele/gymbro_flutter_new
/ralph-loop "$(cat .claude/ralph-prompts/production-readiness-check.md)" --max-iterations 50 --completion-promise "PRODUCTION READY"
```

Dettagli completi in [`HOW_TO_START.md`](HOW_TO_START.md).

---

## 🧠 Philosophy

Questi prompt seguono i **Geoffrey Huntley Principles**:

1. ✅ **Fresh Context Is Reliability** - Ogni iterazione ricomincia da zero
2. ✅ **Backpressure Over Prescription** - Gates (tests/lints) respingono lavoro invalido
3. ✅ **Steer With Signals, Not Scripts** - Codebase è l'instruction manual
4. ✅ **Get Out of the Way** - Ralph decide autonomamente
5. ✅ **Prompts Evolve** - Osserva failure patterns e aggiusta

**Sources**:
- [Ralph Wiggum Technique](https://ghuntley.com/ralph/)
- [Ralph Orchestrator](https://github.com/mikeyobrien/ralph-orchestrator)
- [11 Tips for AI Coding with Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)

---

## 📋 Available Prompts

### 1. Production Readiness Check

**File**: `production-readiness-check.md`

**Goal**: Completare tutti i 165+ task da `docs/PRODUCTION_READINESS.md`

**Backpressure Gates**:
- `flutter analyze` → Zero errors
- `flutter test` → 100% pass
- `flutter build ios --release` → Build OK
- `flutter build apk --release` → Build OK
- `.claude/scripts/performance-check.sh` → Zero warnings
- `.claude/scripts/health-check.sh` → Zero duplicates

**Completion Promise**: `<promise>PRODUCTION READY</promise>`

**Estimated Iterations**: 20-50 (dipende da quanti issue ci sono)

**Time**: 3-8 ore (con blockers umani per auth/device testing)

---

## 🎯 Creating New Ralph Prompts

Se vuoi creare un nuovo prompt Ralph per altro task:

### Template Base

```markdown
# Ralph Loop: [Task Name]

**Goal**: [Clear, measurable goal]

---

## 🧠 Ralph Philosophy

[Include Huntley principles]

---

## 🚧 Backpressure Gates

[Define objective gates che respingono lavoro invalido]

```bash
# Gate 1: [Name]
[command]
# ❌ Se fallisce → [what to do]
```

---

## 🎯 Obiettivi Ralph Iteration

[Cosa Ralph deve fare ogni iterazione]

---

## ✅ Completion Promise

Output `<promise>[PROMISE TEXT]</promise>` quando:

✅ [Condition 1]
✅ [Condition 2]
...

---

## 🚫 Quando BLOCCARE

❌ [Condition requiring human]
→ OUTPUT: "[Clear blocker message]"

---

## 🔧 Commands Available

[Tools Ralph può usare]

---

## 🧠 Ralph Mindset

[Guidelines for Ralph behavior]
```

### Best Practices

1. **Clear Gates**: Definisci backpressure gates oggettivi (non "codice migliore", ma "flutter analyze passa")
2. **Autonomous**: Ralph decide quale task fare next, tu definisci solo le priorità
3. **Signals not Scripts**: Non prescrivere HOW, lascia che Ralph usi il codebase come guida
4. **Explicit Blockers**: Definisci chiaramente quando Ralph deve fermarsi e chiedere aiuto
5. **Completion Promise**: Chiara, testabile, non ambigua

---

## 📊 Success Metrics

Ralph Loop è considerato di successo quando:

✅ **Autonomy**: Ralph completa ≥70% dei task senza intervento umano
✅ **Quality**: Backpressure gates passano al 100%
✅ **Efficiency**: Tempo totale < 50% del tempo manuale equivalente
✅ **Completeness**: Completion promise raggiunta

---

## 🛟 Troubleshooting

### Ralph in Loop Infinito

**Sintomo**: Stessa iterazione ripetuta 5+ volte senza progress

**Fix**:
1. `/cancel-ralph`
2. Analizza ultimo output: cosa sta provando a fare?
3. Aggiorna prompt con "sign" più chiaro per quel caso
4. Riavvia Ralph

### Ralph Troppo Conservativo

**Sintomo**: Si blocca per ogni piccola decisione

**Fix**:
1. Aggiorna prompt: "Decidi autonomamente per task con basso rischio"
2. Definisci meglio quali decisioni richiedono human (es. "solo deploy production")

### Ralph Troppo Aggressivo

**Sintomo**: Fa modifiche rischiose senza conferma

**Fix**:
1. Aggiungi backpressure gate: "Commit max 20 file per iterazione"
2. Aggiungi blocker: "Se modifichi core system → BLOCCA e chiedi conferma"

---

## 📚 Learn More

- [Ralph Wiggum Original Post](https://ghuntley.com/ralph/)
- [How to Ralph Wiggum (GitHub)](https://github.com/ghuntley/how-to-ralph-wiggum)
- [Ralph Orchestrator](https://mikeyobrien.github.io/ralph-orchestrator/)
- [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [FitLog Production Readiness Doc](../docs/PRODUCTION_READINESS.md)

---

## 🎯 Next Steps

1. **Review Prompt**: Leggi `production-readiness-check.md`
2. **Read How-To**: Leggi `HOW_TO_START.md`
3. **Pre-Flight Check**: Git status clean, auth ready
4. **Launch Ralph**: `/ralph-loop "$(cat .claude/ralph-prompts/production-readiness-check.md)" --max-iterations 50 --completion-promise "PRODUCTION READY"`
5. **Monitor**: Prime 2-3 iterazioni, poi lascia lavorare
6. **Tune**: Se fallisce → aggiorna prompt con nuovo "sign"

Buon Ralph Loop! 🚀
