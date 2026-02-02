# 🚀 Come Avviare Ralph Loop - Production Readiness

**Quando sei pronto** (es. al lavoro con tempo per monitorare), segui questi step:

---

## ✅ Pre-Flight Checklist (1 minuto)

Prima di avviare Ralph, assicurati:

```bash
# 1. Sei nella directory giusta
cd /Users/michele/gymbro_flutter_new

# 2. Git status pulito (o almeno noto)
git status

# 3. Hai tempo di monitorare (almeno 30 min - 1h prima iterazione)
# Ralph può girare per ore, ma le prime iterazioni vanno monitorate

# 4. Firebase auth OK (se devi deployare)
firebase projects:list
# Se chiede login → firebase login

# 5. Device iOS/Android disponibili? (per test fisici)
# Opzionale: Ralph può documentare cosa serve testare manualmente
```

---

## 🚀 Avvia Ralph Loop

### Comando Base

```bash
/ralph-loop "$(cat .claude/ralph-prompts/production-readiness-check.md)" --max-iterations 50 --completion-promise "PRODUCTION READY"
```

**Cosa fa**:
- Carica il prompt da `production-readiness-check.md`
- Max 50 iterazioni (sicurezza, evita loop infinito)
- Si ferma quando output `<promise>PRODUCTION READY</promise>`

### Comando Alternativo (se preferisci file path)

```bash
# Crea symlink per comodità
ln -s .claude/ralph-prompts/production-readiness-check.md RALPH_PROMPT.md

# Poi avvia
/ralph-loop "$(cat RALPH_PROMPT.md)" --max-iterations 50 --completion-promise "PRODUCTION READY"
```

---

## 👀 Cosa Aspettarsi

### **Iteration 1** (5-10 min)
Ralph:
1. Legge `PRODUCTION_READINESS.md`
2. Legge `CLAUDE.md`, `CODE_PATTERNS.md`
3. Run backpressure gates (analyze, test, health-check, performance-check)
4. Identifica first blocker (probabilmente "146 file non committati")
5. Commit o chiede decisione

**Tu**: Monitora. Se chiede auth/decisione → fornisci.

### **Iteration 2-5** (30 min - 1h)
Ralph:
- Fixa blockers critici (Firestore rules deploy, Functions deploy)
- Se richiede auth → si blocca e chiede
- Fix duplicati, performance anti-pattern, hardcoded strings

**Tu**: Rispondi a blockers umani (auth, decisioni), lascia lavorare per il resto.

### **Iteration 6-20** (2-4h)
Ralph:
- Fix warnings (test coverage, localization, docs)
- Ricerca proattiva anti-pattern
- Incrementa test coverage
- Cleanup codebase

**Tu**: Check progress ogni tanto, commit significativi.

### **Iteration 20-50** (variabile)
Ralph:
- Nice-to-have tasks
- Final polish
- Verifica finale backpressure gates
- Output `<promise>PRODUCTION READY</promise>`

**Tu**: Review finale, decide se accettare o iterare ancora.

---

## ⏸️ Pause/Resume Ralph

### Pause Temporanea

Se devi stoppare Ralph temporaneamente (es. meeting, pranzo):

```bash
/cancel-ralph
```

Poi **quando torni**:

```bash
# Ralph riprende da dove aveva lasciato (vede i file modificati)
/ralph-loop "$(cat .claude/ralph-prompts/production-readiness-check.md)" --max-iterations 50 --completion-promise "PRODUCTION READY"
```

**Nota**: Ralph ricomincia con fresh context, MA vede tutto il lavoro fatto (git diff, file modificati). Questo è IL PUNTO DI FORZA di Ralph.

---

## 🚨 Gestione Blockers

### Blocker Tipo 1: Auth Richiesta

**Ralph output**:
```
BLOCKER: Firebase deploy requires authentication.
Run 'firebase login' manually.
```

**Tu fai**:
```bash
firebase login
# Poi replica nella chat: "Auth done, continua"
```

Ralph vedrà che auth è OK e procederà.

### Blocker Tipo 2: Device Fisico

**Ralph output**:
```
BLOCKER: iOS Live Activity test requires physical iPhone.
Cannot test in simulator.
```

**Tu fai**:
- Connetti iPhone
- Testa manualmente Live Activity
- Replica: "Live Activity testato su iPhone 14 Pro, funziona OK"

Ralph documenterà e procederà.

### Blocker Tipo 3: Decisione Umana

**Ralph output**:
```
DECISION NEEDED: Found 9 duplicate files. Options:
A) Delete older versions (risky)
B) Rename with _legacy suffix (safe)
C) Manual review one-by-one

Which approach?
```

**Tu fai**:
```
Replica: "Option B - rename with _legacy"
```

Ralph esegue.

---

## 📊 Monitoraggio Progress

### Durante Ralph Loop

Ogni iterazione Ralph output:
```markdown
## Iteration N Progress

### Completed This Iteration
- ✅ Committed 146 staged files
- ✅ Fixed 12 instances of Icons.* usage

### Issues Found & Fixed
- 🐛 Performance anti-pattern in workout_provider.dart:145 → fixed with singleton pattern

### Still TODO
- [ ] Deploy Firestore rules (auth required)
- [ ] Test iOS Live Activity on device

### Blockers
- BLOCKER: Firebase auth needed

### Next Iteration Plan
- Wait for auth → deploy rules
- Fix remaining Icons.* in analytics feature
```

**Tu**: Leggi "Blockers", risolvi se necessario, lascia continuare.

### Check Progress Mid-Loop

```bash
# Vedi cosa ha modificato
git status
git diff

# Vedi commit fatti da Ralph
git log --oneline -10

# Check backpressure gates status
flutter analyze
flutter test
.claude/scripts/health-check.sh
```

---

## ✅ Completion

### Quando Ralph Output `<promise>PRODUCTION READY</promise>`

**Ralph ha completato**:
1. ✅ Tutti i blockers fixati
2. ✅ Tutti i warnings addressati
3. ✅ Zero anti-pattern
4. ✅ Backpressure gates passano
5. ✅ Codebase production-ready

**Tu fai**:
1. **Review finale**:
   ```bash
   git log --oneline --since="6 hours ago"  # Vedi tutto fatto da Ralph
   git diff HEAD~50  # Vedi tutte le modifiche aggregate
   ```

2. **Acceptance test**:
   ```bash
   flutter test
   flutter build ios --release
   flutter build apk --release
   ```

3. **Deploy se tutto OK**:
   ```bash
   cd functions && npm run build && firebase deploy --only functions
   firebase deploy --only firestore:rules
   ```

4. **Tag release**:
   ```bash
   git tag -a v1.0.0-beta -m "Production ready via Ralph Loop"
   git push origin v1.0.0-beta
   ```

---

## 🛟 Emergency Stop

Se Ralph va in loop infinito o fa danni:

```bash
# 1. Stop Ralph
/cancel-ralph

# 2. Revert changes (se necessario)
git status
git diff  # Vedi cosa ha modificato

# Opzione A: Stash tutto
git stash save "Ralph WIP - reverting"

# Opzione B: Revert selettivo
git checkout -- path/to/file  # Revert singolo file

# Opzione C: Hard reset (PERICOLOSO)
git reset --hard HEAD  # Perde TUTTO il lavoro non committato!

# 3. Analizza cosa è andato storto
# 4. Aggiorna prompt in production-readiness-check.md
# 5. Riprova
```

---

## 💡 Tips per Massimizzare Efficienza

### 1. Lascia Lavorare Ralph
**❌ BAD**: Interrompi ogni 5 min per controllare
**✅ GOOD**: Avvia, controlla dopo 30-60 min, lascia iterare

### 2. Risolvi Blockers Velocemente
Quando Ralph si blocca per auth/decisione → rispondi ASAP, non farlo aspettare.

### 3. Commit Frequenti (automatico)
Ralph committa frequentemente. Se vuoi squash commits:
```bash
git rebase -i HEAD~20  # Squash ultimi 20 commit
```

### 4. Monitor con Dashboard
Apri in tab separati:
- Terminal con Ralph
- Browser con Firebase Console
- IDE con git diff
- DevTools Performance (se test device)

### 5. Tune Prompt Se Ralph Fallisce
Se Ralph fallisce ripetutamente sullo stesso task → aggiorna `production-readiness-check.md` con "sign" più chiaro.

---

## 📚 Resources

- [Ralph Wiggum Technique](https://ghuntley.com/ralph/)
- [Ralph Orchestrator Docs](https://mikeyobrien.github.io/ralph-orchestrator/)
- [11 Tips for Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)
- [FitLog PRODUCTION_READINESS.md](../docs/PRODUCTION_READINESS.md)

---

## 🎯 Ready to Ralph!

Quando sei pronto:

```bash
cd /Users/michele/gymbro_flutter_new
/ralph-loop "$(cat .claude/ralph-prompts/production-readiness-check.md)" --max-iterations 50 --completion-promise "PRODUCTION READY"
```

Buona fortuna! 🚀

---

_Pro tip: Le prime volte monitora attentamente. Dopo 2-3 run capirai il pattern e potrai lasciare Ralph lavorare per ore._
