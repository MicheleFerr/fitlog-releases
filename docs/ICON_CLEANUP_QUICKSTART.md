# 🚀 Icon Cleanup - Quick Start Guide

> **TL;DR**: Ridurre 441 icone → ~300 icone in 6-8 ore con script automatico + piano dettagliato

---

## ⚡ Quick Commands

### 1. Run Audit Script (5 min)

```bash
cd /Users/michele/gymbro_flutter_new

# Esegui audit automatico
./scripts/icon_cleanup_audit.sh

# Output: /tmp/icon_cleanup_audit/
# - all_icons_usage.txt      → Tutte le 441 icone con conteggio
# - rare_icons.txt            → 228 icone rare (≤2 usi)
# - single_use_icons.txt      → Icone usate 1 sola volta
# - detailed_audit.txt        → Report dettagliato con file locations
# - duplicate_variants.txt    → Famiglie icone con varianti
# - SUMMARY.txt               → Riepilogo
```

---

### 2. Review Output (10 min)

```bash
# Leggi summary
cat /tmp/icon_cleanup_audit/SUMMARY.txt

# Review detailed audit
less /tmp/icon_cleanup_audit/detailed_audit.txt

# Check duplicate variants
less /tmp/icon_cleanup_audit/duplicate_variants.txt
```

---

### 3. Start Refactoring (6-8 hours)

```bash
# Create feature branch
git checkout -b refactor/icon-cleanup

# Follow piano dettagliato
less docs/ICON_REFACTORING_PLAN.md

# Start Phase 1.1 (Timer icons - 30 min)
# Apri i 14 file listati nel piano
# Find & Replace: Icons.timer_outlined → AppIcons.timer
```

---

## 📋 Workflow Completo

### Step 1: Audit (5 min) ✅ FATTO
```bash
./scripts/icon_cleanup_audit.sh
```

**Output**:
- 228 icone rare identificate
- File locations per ogni icona
- Categorizzazione automatica (Debug/Test/Feature)

---

### Step 2: Plan Review (10 min)

```bash
# Leggi piano completo
less docs/ICON_REFACTORING_PLAN.md

# Checklist:
# - Fase 1: Varianti duplicate (3-4 ore)
# - Fase 2: Icone rare (2-3 ore)
# - Fase 3: Documentazione (1 ora)
# - Fase 4: Test (1 ora)
```

---

### Step 3: Execute Phase 1 (3-4 ore)

**Priorità**: Varianti duplicate (alto ROI, basso rischio)

#### 1.1 Timer Icons (30 min)
```bash
# 14 file da modificare
# Find & Replace in IDE:
#   Icons.timer_outlined → AppIcons.timer
#   Icons.timer_off_outlined → AppIcons.timerOff

# Test
flutter analyze
flutter test
```

#### 1.2 Analytics Icons (20 min)
```bash
# 13 file da modificare
# Find & Replace:
#   Icons.analytics_outlined → AppIcons.analytics
#   Icons.analytics_rounded → AppIcons.analytics
```

#### 1.3-1.8 Altri Variants (2-3 ore)
```bash
# Follow checklist nel piano:
# - Check/success icons
# - Star icons
# - Settings icons
# - Warning icons
# - Trend icons (semantic)
# - Fire icons (semantic)
```

**Commit dopo ogni gruppo**:
```bash
git add .
git commit -m "refactor(icons): standardize timer variants (14 files)"
```

---

### Step 4: Execute Phase 2 (2-3 ore)

**Rimuovi icone rare**

```bash
# Use detailed_audit.txt come guida
less /tmp/icon_cleanup_audit/detailed_audit.txt

# Per ogni icona:
# 1. Leggi file location
# 2. Verifica categoria (Debug/Test/Feature)
# 3. Decisione: REMOVE / KEEP / REPLACE
# 4. Esegui azione
# 5. Test
# 6. Commit ogni 10-15 icone
```

**Categorie automatiche**:
- 🔴 Debug/Tools → **LIKELY REMOVE**
- 🔴 Test → **REVIEW FOR REMOVAL**
- 🟡 Variant (_outlined, _rounded) → **CHECK FOR DUPLICATE**
- 🟢 Feature Code → **MANUAL REVIEW**

---

### Step 5: Execute Phase 3 (1 ora)

**Documenta guidelines**

```bash
# Il piano include già template completo
# Copia da ICON_REFACTORING_PLAN.md sezione 3.1

# Create file
touch docs/DESIGN_GUIDELINES/ICON_GUIDELINES.md

# Edit e incolla template dal piano
```

---

### Step 6: Execute Phase 4 (1 ora)

**Test & validation**

```bash
# Automated tests
flutter analyze
flutter test

# Visual regression (manual)
# - Home screen
# - Workout screen
# - Analytics screen
# - Settings screen
# - Dark/Light theme

# Bundle size check
flutter build apk --analyze-size
```

---

## 📊 Progress Tracking

### Checklist Interattiva

**Fase 1: Varianti Duplicate** (3-4 ore)
```
[ ] 1.1 Timer icons (14 file) - 30 min
[ ] 1.2 Analytics icons (13 file) - 20 min
[ ] 1.3 Check/success icons (16 file) - 30 min
[ ] 1.4 Star icons (15 file) - 20 min
[ ] 1.5 Settings icons (8 file) - 15 min
[ ] 1.6 Warning icons (20 file) - 25 min
[ ] 1.7 Trend icons (semantic) - 30 min
[ ] 1.8 Fire icons (semantic) - 20 min
```

**Fase 2: Icone Rare** (2-3 ore)
```
[ ] 2.1 Generate audit (già fatto ✓)
[ ] 2.2 Categorize icons - 1 ora
[ ] 2.3 Bulk removal - 1-2 ore
```

**Fase 3: Documentazione** (1 ora)
```
[ ] 3.1 Create ICON_GUIDELINES.md - 45 min
[ ] 3.2 Update DESIGN_GUIDELINES.md - 15 min
```

**Fase 4: Test** (1 ora)
```
[ ] 4.1 Automated tests - 15 min
[ ] 4.2 Visual regression - 30 min
[ ] 4.3 Bundle size check - 15 min
```

---

## 🎯 Tips per Efficienza

### Use IDE Multi-File Replace

**VS Code**:
```
1. Cmd+Shift+H (Replace in Files)
2. Search: Icons\.timer_outlined
3. Replace: AppIcons.timer
4. Files to include: lib/**/*.dart
5. Replace All
```

**IntelliJ/Android Studio**:
```
1. Cmd+Shift+R (Replace in Path)
2. Search pattern (regex): Icons\.timer_outlined
3. Replace: AppIcons.timer
4. Scope: Project Files
5. Replace
```

---

### Test Strategico (Non Tutto)

**Non serve testare 100+ screen**!

Test solo **rappresentativi**:
- ✅ Timer screen (timer icons)
- ✅ Analytics dashboard (analytics icons)
- ✅ Workout completion (check icons)
- ✅ Settings (settings icons)
- ✅ Achievement screen (star icons)

**5-10 screen = 80% coverage**

---

### Commit Frequente

```bash
# Ogni 15-20 file modificati → commit
git add .
git commit -m "refactor(icons): standardize timer icons batch 1/2"

# Se qualcosa rompe → easy rollback
git revert HEAD
```

---

## 🐛 Troubleshooting

### Error: AppIcons not defined

```dart
// Aggiungi import
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

---

### Error: Icon getter missing

```dart
// Apri app_icons.dart e aggiungi
static const IconData iconName = Icons.icon_name;
```

---

### Visual regression dopo refactor

```dart
// Verifica stile originale
// PRIMA: Icons.timer_outlined (outlined)
// DOPO: AppIcons.timer (potrebbe essere filled)

// Se necessario, mantieni variante
static const IconData timerOutlined = Icons.timer_outlined;
```

---

## 📈 Expected Results

### Before
- 441 icone uniche
- 228 icone rare (52%)
- 15+ varianti duplicate
- Bundle: ~450KB
- Refactoring time: High

### After
- ~300 icone uniche (-32%)
- 0 icone rare (-100%)
- 0 varianti duplicate
- Bundle: ~350KB (-22%)
- Refactoring time: Low (-75%)

---

## 🔗 Resources

| File | Description |
|------|-------------|
| `docs/ICON_REFACTORING_PLAN.md` | Piano dettagliato step-by-step |
| `docs/ICON_USAGE_REPORT.md` | Report analisi iniziale |
| `scripts/icon_cleanup_audit.sh` | Script audit automatico |
| `lib/shared/presentation/theme/app_icons.dart` | Icon system centralizzato |
| `/tmp/icon_cleanup_audit/` | Output audit script |

---

## ⏱️ Time Budget

| Phase | Time | Priority |
|-------|------|----------|
| Audit (script) | 5 min | ✅ Done |
| Phase 1 (variants) | 3-4 h | 🔴 High |
| Phase 2 (rare icons) | 2-3 h | 🟡 Medium |
| Phase 3 (docs) | 1 h | 🔴 High |
| Phase 4 (test) | 1 h | 🔴 High |
| **TOTAL** | **7-9 h** | |

**ROI**: Alto - Cleanup definitivo + refactoring facile forever

---

## 🚀 Ready to Start?

### Option A: Full Cleanup (7-9 hours)
```bash
# Run audit
./scripts/icon_cleanup_audit.sh

# Follow complete plan
less docs/ICON_REFACTORING_PLAN.md

# Start Phase 1.1
```

### Option B: Quick Wins Only (2-3 hours)
```bash
# Solo varianti duplicate (Fase 1)
# Skip icone rare (Fase 2)
# Massimo ROI, minimo effort

# Start with timer icons (30 min)
# Then analytics, check, star (2h)
```

### Option C: Review First
```bash
# Review detailed audit
less /tmp/icon_cleanup_audit/detailed_audit.txt

# Valuta scope
# Poi decidi: Full vs Quick Wins
```

---

**Raccomandazione**: Start con **Option B** (Quick Wins) per vedere risultati immediati, poi valuta se fare cleanup completo icone rare.

---

> **Created**: 2025-11-01
> **Status**: Ready to Execute
> **Next**: Run `./scripts/icon_cleanup_audit.sh`
