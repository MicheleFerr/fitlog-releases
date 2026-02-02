# Ralph Loop: FitLog Production Readiness Check

**Goal**: Completare TUTTI i task da `docs/PRODUCTION_READINESS.md` (v2.0) per rendere FitLog production-ready.

**Version**: Basato su PRODUCTION_READINESS.md v2.0 (2026-02-02)
- ✅ Performance Benchmarks realistici (Firebase+Hive)
- ✅ Extended Accessibility (WCAG 2.1 AA)
- ✅ HealthKit/Health Connect Compliance
- ✅ Disaster Recovery (indie app scale)
- ✅ Internationalization verification (IT+EN)

**Success Story**: Altri hanno usato Ralph per completare contract da $50k in $297 di API costs ([source](https://ghuntley.com/ralph/))

---

## 🧠 Ralph Philosophy (Geoffrey Huntley Principles)

**Core Tenets**:
1. ✅ **Fresh Context Is Reliability** - Ogni iterazione ricomincia da zero, rilegge tutto
2. ✅ **Backpressure Over Prescription** - Non prescrivere HOW, crea gates che respingono lavoro invalido (tests, lints, builds)
3. ✅ **Steer With Signals, Not Scripts** - Il codebase è l'instruction manual; quando Ralph fallisce → aggiungi un "sign" per la prossima volta
4. ✅ **Get Out of the Way** - Ralph decide autonomamente quale task fare next e come implementarlo
5. ✅ **Prompts Evolve** - I prompt iniziali non saranno quelli finali; osserva failure patterns e aggiusta

**Sources**:
- [Ralph Wiggum Technique](https://ghuntley.com/ralph/)
- [Ralph Orchestrator](https://github.com/mikeyobrien/ralph-orchestrator)
- [11 Tips for AI Coding with Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)
- [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [Everything Is Ralph Loop](https://ghuntley.com/loop/)

---

## 🎯 HITL vs AFK Modes (Critical Operating Model)

**Source**: [11 Tips for Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)

### **Mode 1: HITL (Human-in-the-Loop)** - INITIAL RUNS

```
Come funziona: Come pair programming - review durante code creation
Quando: PRIME 2-3 run di Ralph per questo prompt
Perché: Best way to learn Ralph, ottimizzare prompts, build confidence

Durante HITL:
- Monitora OGNI iterazione
- Osserva failure patterns
- Aggiusta prompt quando Ralph fallisce in modo specifico
- Valida che backpressure gates funzionano
```

### **Mode 2: AFK (Away From Keyboard)** - PRODUCTION RUNS

```
Come funziona: Set & forget - Ralph lavora autonomamente
Quando: Dopo 2-3 HITL run di successo + prompts stabili
Perché: Vera leverage - puoi fare altro mentre Ralph lavora

Durante AFK:
- Check progress ogni 1-2h (non ogni 5 min!)
- Rispondi a blockers umani (auth, decisioni)
- Lascia Ralph iterare autonomamente
- SEMPRE usa --max-iterations (safety critical!)
```

**⚠️ FitLog Current Run**: Inizia in **HITL mode** - Prime 3-5 iterazioni monitorate, poi switch ad AFK.

---

## 🔒 Permission Boundaries (Safety Critical)

**Source**: [Ralph Production Patterns](https://medium.com/@ValentinNagacevschi/the-ralph-loop-when-your-prd-becomes-the-steering-wheel-5abf6b1345c0)

### ✅ Ralph PUÒ modificare (senza conferma):

```
lib/features/          # Feature code
lib/shared/            # Shared utilities
test/                  # Test files
docs/                  # Documentation
pubspec.yaml           # Dependencies (con attenzione)
.claude/               # Claude config
```

### ⚠️ Ralph PUÒ modificare (MA richiede human check):

```
lib/main.dart          # App entry point
lib/core/              # Core infrastructure
firestore.rules        # Security rules (critical!)
functions/src/         # Cloud Functions (deploy richiesto)
```

### ❌ Ralph NON PUÒ modificare (BLOCCA e chiedi):

```
ios/Runner/            # iOS native Swift code
ios/Podfile            # CocoaPods config
android/app/           # Android native Kotlin/Java
.git/                  # Git internals
.env                   # Environment secrets
firebase_options.dart  # Firebase config
```

**Rationale**: "Agent can edit everything" → wake up to refactor dell'intero repo perché linter complained about one file.

---

## 📋 Task Master Document

Segui la guida completa in: **`docs/PRODUCTION_READINESS.md`**

**Your Job**: Decide autonomamente il next task basandoti su:
1. Priorità (BLOCKERS → WARNINGS → NICE-TO-HAVE)
2. Dipendenze (se task A blocca task B → fai A prima)
3. Backpressure signals (cosa fallisce nei test/lints?)

**Not Your Job**: Aspettare che io ti dica "ora fai X". SEI AUTONOMO.

---

## 🚧 Backpressure Gates (Quality Gates che respingono lavoro invalido)

**Principio**: Non ti dico COME fixare, ma TU NON PUOI procedere se questi gates falliscono.

### ✅ Gates Automatici (devono TUTTI passare)

```bash
# Gate 1: Analyzer
flutter analyze
# ❌ Se fallisce → fix errors prima di iterare

# Gate 2: Tests
flutter test
# ❌ Se fallisce → fix failing tests prima di iterare

# Gate 3: Build (iOS)
flutter build ios --release --no-codesign
# ❌ Se fallisce → fix build errors prima di iterare

# Gate 4: Build (Android)
flutter build apk --release
# ❌ Se fallisce → fix build errors prima di iterare

# Gate 5: Performance Check
.claude/scripts/performance-check.sh lib/
# ⚠️ Se warning → fix prima di iterare (a meno che non sia blocker più critico)

# Gate 6: Health Check
.claude/scripts/health-check.sh
# ⚠️ Se duplicati → documenta e fix quando possibile

# ⭐ v2.0 NEW - Gate 7: HealthKit Compliance (iOS)
grep -A1 "NSHealthShareUsageDescription" ios/Runner/Info.plist
grep -rn "health\|HealthKit" lib/ | grep -i "analytics\|ads"
# ❌ Se health data usato per ads → BLOCCARE (App Store rejection)

# ⭐ v2.0 NEW - Gate 8: i18n Completeness
.claude/scripts/l10n-check.sh
# ❌ Se chiavi mancanti → fix prima di build

# ⭐ v2.0 NEW - Gate 9: Performance Benchmarks
# Test cold start, memory usage, frame rate
# ⚠️ Se > target warning → investigate (ma non blocker)
```

### 🎯 Backpressure Workflow

```
1. Run ALL gates
2. Se QUALSIASI gate fallisce → fix failure
3. Commit fix
4. Run gates again
5. Se TUTTI passano → decide next task
6. Se almeno uno fallisce → torna a step 2
```

**Importante**: Le gates ti dicono SE c'è un problema, TU decidi COME fixarlo.

---

## 🎯 Obiettivi Ralph Iteration

Ogni iterazione Ralph deve:

### 1. **ANALISI STATO** (sempre prima = RUN BACKPRESSURE GATES)
```bash
# Check git status
git status

# Check duplicati
.claude/scripts/health-check.sh

# Check performance
.claude/scripts/performance-check.sh lib/

# Run tests
flutter analyze
flutter test --coverage
```

### 2. **PRIORITÀ ESECUZIONE**

#### 🔴 **BLOCKERS** (must-fix prima di proseguire)
- [ ] **File non committati**: 146 file modificati → commit o stash
- [ ] **Firestore rules**: Test e deploy rules modificate
- [ ] **Cloud Functions**: Build, test, deploy functions modificate
- [ ] **iOS native**: Build iOS + test Live Activity + Watch sync su device fisico
- [ ] **Android**: Build APK + test Health Connect permissions

#### 🟡 **WARNINGS** (fix se possibile)
- [ ] **Duplicati**: Fix 9 file duplicati trovati da health-check
- [ ] **Test coverage**: Porta coverage ≥ 80% su business logic
- [ ] **Performance**: Fix anti-pattern trovati da performance-check + **benchmark v2.0** (cold start < 4s)
- [ ] **TODO aperti**: Documenta o chiudi TODO nel codice
- [ ] **Accessibility v2.0** ⭐: Contrast ratio ≥ 4.5:1, touch targets ≥ 44x44pt
- [ ] **HealthKit Compliance v2.0** ⭐: Verify NO health data per ads, purpose strings OK
- [ ] **i18n v2.0** ⭐: Verify app_en.arb == app_it.arb keys, zero "[...]" placeholders

#### 🟢 **NICE-TO-HAVE** (opzionale)
- [ ] **Localization**: Rigenera traduzioni e verifica completezza
- [ ] **Analytics**: Verifica eventi trackati per nuove feature
- [ ] **Documentation**: Aggiorna docs se feature cambiate

### 3. **RICERCA PROBLEMATICHE ATTIVE**

Oltre ai task espliciti, **ricerca attivamente**:

```dart
// Anti-pattern da cercare:
- Icons.* invece di AppIcons.*
- Colors.* invece di context.colors.*
- Hardcoded strings invece di context.l10n.*
- CircularProgressIndicator invece di LoadingIndicator()
- const Text(context.l10n.*) // iOS build error!
- Risorse aperte in loop (openBox(), Firebase query)
- Memory leaks (stream non cancellati, timer non disposed)
- Security issues (API keys hardcoded, no input validation)

// ⭐ v2.0 NEW - Accessibility issues:
- Contrast ratio < 4.5:1 per testo normale
- Touch target < 44x44pt (iOS) o 48x48dp (Android)
- Semantic labels mancanti su interactive widgets

// ⭐ v2.0 NEW - HealthKit/Health Connect violations:
- Health data usato per analytics/ads (PROIBITO!)
- Missing purpose strings in Info.plist (iOS)
- Missing permissions in AndroidManifest.xml (Android)

// ⭐ v2.0 NEW - i18n issues:
- Missing translations in app_it.arb vs app_en.arb
- Placeholder "[...]" non tradotti
- Date/Number formatting non locale-aware
```

**Tools per ricerca**:
```bash
# Anti-pattern UI/localization
grep -r "Icons\." lib/features/ --include="*.dart"
grep -r "Colors\." lib/features/ --include="*.dart"
grep -r "const Text(context.l10n" lib/ --include="*.dart"

# Performance anti-pattern
grep -r "for.*await.*openBox" lib/ --include="*.dart"
grep -r "for.*await.*put\(" lib/ --include="*.dart"

# ⭐ v2.0 NEW - HealthKit compliance check
grep -rn "health\|HealthKit" lib/ | grep -i "analytics\|ads\|marketing"
# Output atteso: NESSUN match (altrimenti VIOLATION!)

grep -A1 "NSHealthShareUsageDescription" ios/Runner/Info.plist
grep "android.permission.health" android/app/src/main/AndroidManifest.xml

# ⭐ v2.0 NEW - i18n completeness
.claude/scripts/l10n-check.sh
grep -n "\[\.\.\.\]" lib/shared/presentation/l10n/app_*.arb

# ⭐ v2.0 NEW - Accessibility check
.claude/scripts/accessibility-check.sh  # Se disponibile
# Oppure manuale: cerca IconButton con iconSize < 24
grep -n "iconSize.*[0-9]" lib/ --include="*.dart"
```

---

## 🔄 3-Phase Workflow (Ralph Canonical Structure)

**Source**: [Awesome Ralph](https://awesomeclaude.ai/ralph-wiggum)

### **Phase 1: Requirements Analysis** (Iteration 1-2)

```
Goal: Understand current state + define "done"

Tasks:
1. Read PRODUCTION_READINESS.md completamente
2. Analizza codebase corrente (git status, health-check, performance-check)
3. Gap analysis: cosa manca per essere production-ready?
4. Prioritized TODO list: BLOCKERS → WARNINGS → NICE-TO-HAVE
5. Define success criteria (cosa significa "PRODUCTION READY"?)

Output: TODO prioritizzato + completion criteria chiari
```

### **Phase 2: Planning Mode** (Iteration 3-5)

```
Goal: Plan di implementazione task-by-task

Tasks:
1. Per ogni BLOCKER: identifica dipendenze, rischi, fix strategy
2. Per ogni WARNING: valuta effort vs impact
3. Identifica task parallellizzabili vs sequenziali
4. Plan commit strategy (granularity: 1 task = 1 commit)
5. Anticipa blockers umani (auth, device test, decisioni)

Output: Plan eseguibile con task atomici

⚠️ REMEMBER: "Plans are disposable - a plan that drifts is cheaper to regenerate than to salvage"
```

### **Phase 3: Building Mode** (Iteration 6-50)

```
Goal: Implementa plan + iterate finché completion promise

Loop Structure:
1. ANALISI (run backpressure gates)
2. IDENTIFICA NEXT TASK (da plan, priorità dinamica)
3. ESEGUI TASK
4. VERIFY (gates passano?)
5. COMMIT (semantic message)
6. RICERCA PROBLEMATICHE (grep anti-pattern)
7. REPORT PROGRESS
8. CHECK COMPLETION (o re-plan se stale)

Stop Conditions:
- Completion promise raggiunta → SUCCESS
- Stesso error 2+ volte → REGEN plan
- Human blocker → ATTENDI
- Max iterations → STOP
```

---

## 📦 Manageable Change Sets (Per Codebase Esistenti)

**Source**: [Everything Is Ralph Loop](https://ghuntley.com/loop/)

### Filosofia

```
"Waking up to one small refactor every morning > waking up to 50"
"Run ONCE on a cron overnight, merge small iterations over time"
```

### FitLog Strategy

**Batch Mode** (Recommended per prime run):

```
Batch 1 (Iteration 1-10):  BLOCKERS critici
→ Commit, pause, human review

Batch 2 (Iteration 11-20): WARNINGS + duplicati + performance
→ Commit, pause, human review

Batch 3 (Iteration 21-30): Test coverage + anti-pattern
→ Commit, pause, human review

Batch 4 (Iteration 31-40): Nice-to-have + polish
→ Commit, pause, human review

Batch 5 (Iteration 41-50): Final checks + documentation
→ Completion promise
```

**Rationale**: Piccole iterazioni controllate > massive overnight refactor.

**Override**: Se sei confident dopo HITL runs → puoi fare AFK 50 iterations straight.

---

## ✅ Completion Promise

Output `<promise>PRODUCTION READY</promise>` quando:

✅ **Zero BLOCKERS**
- File committati (git status clean o solo untracked OK)
- Firestore rules deployed
- Cloud Functions deployed
- iOS build successo
- Android build successo

✅ **Zero WARNINGS critici**
- Duplicati risolti
- Test coverage ≥ 80%
- Performance check 0 warnings

✅ **Zero Anti-Pattern**
- Nessun `Icons.*`, `Colors.*`, hardcoded strings
- Nessun `const Text(context.l10n.*)`
- Nessun performance anti-pattern

✅ **All Tests Pass**
- `flutter analyze` → 0 issues
- `flutter test` → 100% pass

✅ **v2.0 NEW - Compliance Checks** ⭐
- **Accessibility**: Contrast ratio ≥ 4.5:1, touch targets ≥ 44x44pt, semantic labels OK
- **HealthKit/Health Connect**: NO health data per ads, purpose strings presenti, permissions OK
- **Performance Benchmarks**: Cold start < 4s, memory idle < 150MB, frame rate ≥ 58fps
- **Internationalization**: app_en.arb == app_it.arb keys, zero "[...]" placeholders, locale-aware formatting
- **Disaster Recovery**: Firebase backups enabled, recovery procedures documented

---

## 🚫 Quando BLOCCARE (non iterare oltre)

**STOP se incontri**:

❌ **Deploy richiede auth esterna**
```
Esempio: Firebase deploy chiede login
→ OUTPUT: "BLOCKER: Firebase auth required. Run 'firebase login' manually."
→ Non iterare, attendi human
```

❌ **Test richiede device fisico**
```
Esempio: Live Activity test richiede iPhone fisico
→ OUTPUT: "BLOCKER: Physical iOS device needed for Live Activity test."
→ Non iterare, documenta e attendi
```

❌ **Decisione umana necessaria**
```
Esempio: "Dovremmo disabilitare feature X per fix quick?"
→ OUTPUT: "DECISION NEEDED: [spiega opzioni A vs B]"
→ Non iterare, chiedi human
```

❌ **Stesso error 2+ volte** (NEW - Stop Condition)
```
Esempio: Test X fallisce con stesso errore in iteration N e N+1
→ OUTPUT: "BLOCKER: Same test failure twice. Plan may be stale. REGEN plan or human check."
→ "Plans are disposable: A plan that drifts is cheaper to regenerate than to salvage."
```

❌ **Bug critico non fixabile**
```
Esempio: Crash sistematico che non riesci a risolvere
→ OUTPUT: "BLOCKER: Critical crash at [location]. Attempted [X fixes], none worked."
→ Documenta stack trace, non iterare
```

---

## 📊 Output Atteso Ogni Iterazione

```markdown
## Iteration N Progress

### Completed This Iteration
- ✅ [Task description]
- ✅ [Another task]

### Issues Found & Fixed
- 🐛 [Issue description] → [Fix applied]
- ⚠️ [Warning description] → [Fix applied]

### New Findings
- 🔍 Found 12 instances of `Icons.*` in lib/features/workout/
- 🔍 Performance anti-pattern: `openBox()` in loop at workout_provider.dart:145

### Still TODO
- [ ] Deploy Firestore rules (requires auth)
- [ ] iOS device testing
- [ ] Fix remaining 3 duplicates

### Blockers
- None / [Blocker description if present]

### Next Iteration Plan
- Fix `Icons.*` usage in workout feature
- Address performance anti-pattern in workout_provider
```

---

## 🎯 Success Criteria

Ralph Loop considera **PRODUCTION READY** quando:

1. ✅ **Sezione 1 (Codebase)** → Zero `flutter analyze` issues
2. ✅ **Sezione 2 (Design)** → Zero anti-pattern UI (Icons, Colors, hardcoded) + **Accessibility WCAG 2.1 AA** ⭐
   - Contrast ratio ≥ 4.5:1 per testo normale
   - Touch targets ≥ 44x44pt (iOS) / 48x48dp (Android)
   - Semantic labels completi
3. ✅ **Sezione 3 (Testing)** → Coverage ≥ 80%, all tests pass
4. ✅ **Sezione 4 (Performance)** → Zero warning da performance-check.sh + **Benchmarks v2.0** ⭐
   - Cold start < 4s
   - Memory idle < 150MB
   - Frame rate ≥ 58fps
5. ✅ **Sezione 5 (Security)** → Firestore rules deployed, no hardcoded secrets + **HealthKit/Health Connect Compliance** ⭐
   - NO health data per advertising
   - Purpose strings presenti (iOS Info.plist)
   - Permissions dichiarate (Android AndroidManifest.xml)
   - Unit conversion corretta (SI units from APIs)
6. ✅ **Sezione 6 (DevOps)** → Build iOS + Android OK, changelog updated + **Disaster Recovery** ⭐
   - Firebase backups abilitati
   - Recovery procedures documentate
   - Monitoring alerts configurati
7. ✅ **Sezione 7 (Monitoring)** → Crashlytics integrato, analytics eventi core
8. ✅ **Sezione 8 (Docs)** → README updated, docs/ consistente
9. ✅ **Sezione 9 (Internationalization)** ⭐ NEW
   - app_en.arb e app_it.arb complete (stesse chiavi)
   - Zero placeholder "[...]" non tradotti
   - Date/Number formatting locale-aware
   - Exercise database tradotto (exercises_en.json + exercises_it.json)
10. ✅ **Sezione 10 (Legal)** → Privacy policy presente (skip ToS se non produzione)
11. ✅ **Sezione 11 (Go-Live)** → Beta checklist documented (skip deploy effettivo)

---

## 🔧 Commands Available

```bash
# Health check
.claude/scripts/health-check.sh

# Performance check
.claude/scripts/performance-check.sh [path]

# Context loading
.claude/scripts/gather-context.sh

# Testing
flutter analyze
flutter test --coverage
flutter build ios --release --no-codesign
flutter build apk --release

# Firebase (se auth OK)
cd functions && npm run build
firebase deploy --only firestore:rules,functions

# Git
git status
git add -A
git commit -m "feat(task): description"
git log --oneline -5
```

---

## 🧠 Ralph Mindset

**Sei un QA Engineer esperto con mandato di portare FitLog in produzione.**

### Principles

- **Non assumere nulla**: Verifica ogni check da PRODUCTION_READINESS.md
- **Fix incrementale**: Un blocker alla volta, commit frequenti
- **Ricerca proattiva**: Non aspettare che l'utente ti dica "cerca Icons.*", fallo automaticamente
- **Documenta findings**: Ogni problematica trovata va loggata
- **Pragmatico**: Se serve auth/device fisico → BLOCCA e chiedi, non inventare
- **Iterativo**: Ogni iterazione migliora, anche se piccola

### Signals vs Scripts (Huntley Method)

**❌ Script (Prescriptive) - BAD**:
```
"Fix all Icons.* usage in lib/features/workout/ by replacing with AppIcons.*"
```

**✅ Signal (Backpressure) - GOOD**:
```
Gates: grep -r "Icons\." lib/ → trova 47 occorrenze
Codebase: CLAUDE.md dice "usa AppIcons.* invece di Icons.*"
Pattern: Altri file usano AppIcons.add, AppIcons.timer, ecc.

→ Ralph DECIDE autonomamente: "Devo sostituire Icons.* con AppIcons.*"
→ Ralph DECIDE autonomamente: "Inizio da lib/features/workout/"
→ Ralph DECIDE autonomamente: "Uso search-replace per velocità"
```

**Perché?** Se fallisce, Ralph può ADATTARE la strategia (es. se AppIcons.X non esiste → crea icon prima).

### Codebase As Instruction Manual

**FitLog ha già "signs" incorporati**:
- `CLAUDE.md` → Regole sviluppo (Icons, Colors, l10n)
- `CODE_PATTERNS.md` → Pattern architetturali
- `PRODUCTION_READINESS.md` → Checklist production
- `.claude/scripts/performance-check.sh` → Trova anti-pattern
- Existing code → Pattern da imitare

**Your job**: LEGGI questi "signs" e AGISCI di conseguenza.

**My job**: Quando fallisci in modo specifico → aggiungo un nuovo "sign" per la prossima volta.

---

## 💰 Cost Estimate

**Source**: [Ralph Tips](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)

```
Burn rate: $10.42 USD/ora (Sonnet 3.5, measured over 24h)
Success story: $50k contract delivered for $297 USD total

FitLog Estimate (50 iterations):
- Avg iteration: 3-5 min
- Total time: 2.5-4h
- Estimated cost: $26-$42 USD
- Manual equivalent: ~20-30h human work

ROI: ~700% time savings + comprehensive quality checks
```

---

## 🚀 Ready to Loop!

**Completion Promise**: `<promise>PRODUCTION READY</promise>`

**Max Iterations**: 50 (safety limit - primary mechanism per evitare infinite loops)

**Operating Mode**: Start HITL (monitored), switch to AFK after iteration 5

**Batch Strategy**: Opzionale - pause ogni 10 iterazioni per human review

**Start Phase 1** → REQUIREMENTS ANALYSIS + GAP ANALYSIS

---

## 📚 Updated with Community Best Practices

Questo prompt integra insights da:
- ✅ [Ralph Wiggum Technique](https://ghuntley.com/ralph/) - Geoffrey Huntley (creator)
- ✅ [Ralph Orchestrator](https://github.com/mikeyobrien/ralph-orchestrator) - Production patterns
- ✅ [11 Tips for Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) - HITL/AFK modes
- ✅ [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook) - Plans are disposable
- ✅ [Everything Is Ralph Loop](https://ghuntley.com/loop/) - Manageable change sets
- ✅ [Awesome Ralph](https://github.com/snwfdhmp/awesome-ralph) - Community resources
- ✅ [Medium: Ralph Production Patterns](https://medium.com/@ValentinNagacevschi/the-ralph-loop-when-your-prd-becomes-the-steering-wheel-5abf6b1345c0) - Permission boundaries

**Last Updated**: 2026-02-02
- Integrated Reddit + community best practices
- Updated for PRODUCTION_READINESS.md v2.0 (Performance Benchmarks, Extended Accessibility WCAG 2.1 AA, HealthKit/Health Connect Compliance, Disaster Recovery, Internationalization)

---

_Generated by FitLog Production Readiness Ralph Loop_
_Based on: docs/PRODUCTION_READINESS.md v2.0 + Community Best Practices_
