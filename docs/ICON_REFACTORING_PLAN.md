# 🧹 Material Icons Cleanup - Piano di Refactoring

> **Obiettivo**: Ridurre 441 icone Material → ~300 icone standardizzate
> **Tempo stimato**: 6-8 ore totali
> **ROI**: Alto - Codebase pulito, refactoring facile, -100KB bundle

---

## 📊 Executive Summary

| Metrica | Attuale | Target | Beneficio |
|---------|---------|--------|-----------|
| **Icone uniche** | 441 | ~300 | -141 icone (-32%) |
| **Icone rare (≤2 usi)** | 228 | 0 | Cleanup completo |
| **Varianti duplicate** | 15+ gruppi | 0 | Consistency |
| **Bundle size** | ~450KB | ~350KB | -100KB |
| **Refactoring time** | Alta (4+ varianti) | Bassa (1 costante) | -75% effort |

---

## 🎯 Fase 1: Standardizza Varianti Duplicate (Priorità Alta)

**Tempo stimato**: 3-4 ore

### 1.1 Timer Icons (14 file da modificare)

**File coinvolti**:
```
lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart
lib/features/workout/presentation/screens/workout_completion_summary_screen.dart
lib/features/workout/presentation/widgets/edit_exercise_modal.dart
lib/features/workout/presentation/widgets/tut_selector.dart
lib/features/workout/presentation/widgets/tut_info_dialog.dart
lib/features/workout/presentation/widgets/zen_mode_settings_dialog.dart
lib/features/workout/presentation/widgets/exercise_list_item.dart
lib/features/workout/presentation/widgets/exercise_info_bar.dart
lib/features/workout/presentation/widgets/workout_customization_modal_v2.dart
lib/features/workout/presentation/workout_screen.dart
lib/features/onboarding/presentation/widgets/steps/04_create_workout_step.dart
lib/features/onboarding/presentation/widgets/steps/07_timer_rest_step.dart
lib/features/analytics/presentation/tabs/analytics_premium_tab.dart
lib/shared/presentation/theme/app_icons.dart
```

**Refactor**:
```dart
// ❌ PRIMA (4 varianti inconsistenti)
Icons.timer                  // 56 usi
Icons.timer_outlined         // 16 usi
Icons.timer_off              // 5 usi
Icons.timer_off_outlined     // 1 uso

// ✅ DOPO (2 varianti semantiche chiare)
AppIcons.timer               // Default (attivo)
AppIcons.timerOff            // Paused/disabled

// Eliminati: timer_outlined, timer_off_outlined
```

**Steps**:
1. Apri `lib/shared/presentation/theme/app_icons.dart`
2. Verifica che esista già:
   ```dart
   static const IconData timer = Icons.timer;
   static const IconData timerOff = Icons.timer_off;
   ```
3. Find & Replace in 14 file:
   ```
   Icons.timer_outlined → AppIcons.timer
   Icons.timer_off_outlined → AppIcons.timerOff
   ```
4. Test: `flutter analyze` + visual regression test timer UI

**Tempo**: 30 min

---

### 1.2 Analytics Icons (13 file da modificare)

**File coinvolti**:
```
lib/features/settings/presentation/settings_screen.dart
lib/features/home/presentation/widgets/ai_coach_card.dart
lib/features/home/presentation/widgets/secondary_actions.dart
lib/features/admin/presentation/screens/admin_analytics_screen.dart
lib/features/workout/presentation/screens/workout_completion_summary_screen.dart
lib/features/workout/presentation/screens/workout_exercise_detail_screen.dart
lib/features/workout/presentation/widgets/zen_mode_settings_dialog.dart
lib/features/workout/presentation/widgets/exercise_history_bottom_sheet.dart
lib/features/premium/presentation/screens/premium_purchase_screen_v2.dart
lib/features/analytics/presentation/enhanced_statistics_dashboard.dart
lib/features/analytics/presentation/widgets/one_rm_progression_chart.dart
lib/features/analytics/presentation/widgets/workout_comparison_widget.dart
lib/features/analytics/presentation/widgets/premium/premium_lock_card.dart
```

**Refactor**:
```dart
// ❌ PRIMA (3 varianti)
Icons.analytics              // 23 usi
Icons.analytics_outlined     // 11 usi
Icons.analytics_rounded      // 2 usi

// ✅ DOPO (1 variante standard)
AppIcons.analytics           // Default (Icons.analytics)

// Eliminati: analytics_outlined, analytics_rounded
```

**Steps**:
1. Find & Replace in 13 file:
   ```
   Icons.analytics_outlined → AppIcons.analytics
   Icons.analytics_rounded → AppIcons.analytics
   ```
2. Test: Visual check analytics screens

**Tempo**: 20 min

---

### 1.3 Check/Success Icons (16 file da modificare)

**File coinvolti**:
```
lib/features/home/presentation/widgets/widget_customization_menu.dart
lib/features/routine/presentation/widgets/skip_recovery_dialog.dart
lib/features/routine/presentation/widgets/dialogs/recovery_picker_dialog.dart
lib/features/admin/presentation/screens/missing_exercises_requests_screen.dart
lib/features/exercise_database/presentation/widgets/exercise_sync_status_widget.dart
lib/features/community/presentation/screens/community_hub_screen.dart
lib/features/community/presentation/widgets/create_contribution_modal.dart
lib/features/workout/presentation/widgets/auto_adjustment_modal.dart
lib/features/workout/presentation/widgets/quick_edit_overlay_v2.dart
lib/features/workout/presentation/widgets/exercise_replacement_modal.dart
lib/features/workout/presentation/widgets/premium_workout_gestures.dart
lib/features/premium/presentation/screens/premium_purchase_screen_v2.dart
lib/features/onboarding/presentation/widgets/steps/06_execute_set_step.dart
lib/features/analytics/presentation/tabs/analytics_insights_tab.dart
lib/features/analytics/presentation/widgets/workout_analytics_bar.dart
lib/shared/presentation/theme/app_icons.dart
```

**Refactor**:
```dart
// ❌ PRIMA (5 varianti)
Icons.check                      // 35 usi
Icons.check_circle               // 124 usi
Icons.check_circle_outline       // 13 usi
Icons.check_rounded              // 1 uso
Icons.check_circle_outline_rounded // 1 uso

// ✅ DOPO (3 varianti semantiche)
AppIcons.complete                // Filled circle (workout/set completato)
AppIcons.completeOutline         // Outline circle (in progress)
AppIcons.check                   // Simple check (azione generica)

// Eliminati: check_rounded, check_circle_outline_rounded
```

**Steps**:
1. Find & Replace in 16 file:
   ```
   Icons.check_rounded → AppIcons.check
   Icons.check_circle_outline_rounded → AppIcons.completeOutline
   ```
2. Test: Visual regression check/complete UI

**Tempo**: 30 min

---

### 1.4 Star Icons (15 file da modificare)

**Refactor**:
```dart
// ❌ PRIMA (5 varianti)
Icons.star               // 52 usi
Icons.star_border        // 4 usi
Icons.star_outline       // 1 uso  ← Duplica star_border
Icons.star_rounded       // 1 uso
Icons.star_half          // 2 usi

// ✅ DOPO (3 varianti semantiche)
AppIcons.star            // Filled (rating pieno)
AppIcons.starOutline     // Border (rating vuoto)
AppIcons.starHalf        // Half (rating parziale)

// Eliminati: star_outline (duplica star_border), star_rounded
```

**Steps**:
1. Find & Replace:
   ```
   Icons.star_outline → AppIcons.starOutline
   Icons.star_rounded → AppIcons.star
   ```
2. Test: Rating widgets

**Tempo**: 20 min

---

### 1.5 Settings Icons (8 file da modificare)

**Refactor**:
```dart
// ❌ PRIMA (4 varianti)
Icons.settings               // 14 usi
Icons.settings_outlined      // 1 uso
Icons.settings_rounded       // 1 uso
Icons.settings_applications  // 1 uso

// ✅ DOPO (1 variante)
AppIcons.settings            // Default

// Eliminati: settings_outlined, settings_rounded, settings_applications
```

**Steps**:
1. Find & Replace:
   ```
   Icons.settings_outlined → AppIcons.settings
   Icons.settings_rounded → AppIcons.settings
   Icons.settings_applications → AppIcons.settings
   ```
2. Test: Settings screen

**Tempo**: 15 min

---

### 1.6 Warning Icons (20 file da modificare)

**Refactor**:
```dart
// ❌ PRIMA (4 varianti)
Icons.warning                // 21 usi
Icons.warning_amber          // 11 usi
Icons.warning_outlined       // 2 usi
Icons.warning_rounded        // 1 uso

// ✅ DOPO (2 varianti semantiche)
AppIcons.warning             // Default (Icons.warning)
AppIcons.warningAmber        // Amber color variant (Icons.warning_amber)

// Eliminati: warning_outlined, warning_rounded
```

**Steps**:
1. Find & Replace:
   ```
   Icons.warning_outlined → AppIcons.warning
   Icons.warning_rounded → AppIcons.warning
   ```
2. Test: Warning states

**Tempo**: 25 min

---

### 1.7 Trend Icons (Semantic Overlap Fix)

**Refactor**:
```dart
// ❌ PRIMA (3 icone per stesso concetto)
Icons.trending_up    // 102 usi ← Principale
Icons.arrow_upward   // 8 usi   ← Simile
Icons.north          // 2 usi   ← Simile

// ✅ DOPO (1 icona semantica)
AppIcons.trendUp     // SOLO per progressione metriche

// Sostituiti: arrow_upward, north → trendUp
```

**Steps**:
1. Audit manuale 10 usi di `arrow_upward` e `north`
2. Se rappresentano "trend up" → sostituisci con `AppIcons.trendUp`
3. Se rappresentano "navigation up" → mantieni
4. Test: Analytics charts

**Tempo**: 30 min

---

### 1.8 Fire Icons (Semantic Clarification)

**Refactor**:
```dart
// ❌ PRIMA (2 icone simili)
Icons.local_fire_department  // 36 usi ← Streak
Icons.whatshot               // 12 usi ← Hype/trending?

// ✅ DOPO (2 icone con semantic mapping chiaro)
AppIcons.streak              // SOLO per streak days (local_fire_department)
AppIcons.hype                // SOLO per trending content (whatshot)
```

**Steps**:
1. Audit manuale 12 usi di `whatshot`
2. Verifica semantic: streak vs hype/trending
3. Sostituisci di conseguenza
4. Documenta in `ICON_GUIDELINES.md`

**Tempo**: 20 min

---

## 🗑️ Fase 2: Rimuovi Icone Rare (Priorità Media)

**Tempo stimato**: 2-3 ore

### 2.1 Generate Audit Report (5 min)

**Script**:
```bash
cd /Users/michele/gymbro_flutter_new

# Genera lista icone single-use
grep -rh "Icons\." lib/ --include="*.dart" | \
  grep -o "Icons\.[a-z_]*" | \
  sort | uniq -c | \
  awk '$1 == 1' > /tmp/single_use_icons.txt

# Mostra con file location
while read -r line; do
  icon=$(echo "$line" | awk '{print $2}')
  echo "=== $icon ==="
  grep -rn "$icon" lib/ --include="*.dart" | head -3
  echo ""
done < /tmp/single_use_icons.txt > /tmp/rare_icons_audit.txt

# Review
less /tmp/rare_icons_audit.txt
```

---

### 2.2 Categorize Rare Icons (1 ora)

**Categorie**:

#### A. **Debug/Test Icons** (RIMUOVI SUBITO)
```
Icons.airline_seat_flat          → lib/tools/debug_screen.dart
Icons.zoom_out_map               → lib/test/gesture_test_widget.dart
Icons.workspaces                 → lib/debug/layout_inspector.dart
```

**Action**: Rimuovi codice debug se non necessario

---

#### B. **Legacy Icons** (RIMUOVI SE OBSOLETI)
```
Icons.accessible                 → Usa accessibility_new invece (15 usi)
Icons.wifi_off                   → Network indicator mai usato?
Icons.battery_alert              → Battery status mai implementato?
```

**Action**:
1. Verifica feature associata
2. Se legacy/abandoned → rimuovi
3. Se duplicato → sostituisci con principale

---

#### C. **Potentially Useful** (VALUTA CASO PER CASO)
```
Icons.architecture               → UX flow diagram?
Icons.calculate_outlined         → Calcolatore 1RM (feature pianificata)?
Icons.school_outlined            → Education content?
```

**Action**: Chiedi conferma utente prima di rimuovere

---

### 2.3 Bulk Removal (1-2 ore)

**Process per ogni icona**:

1. **Trova file**:
   ```bash
   grep -rn "Icons.airline_seat_flat" lib/
   ```

2. **Apri file** e verifica contesto

3. **Decisione**:
   - Debug code → Rimuovi intero blocco
   - Legacy feature → Rimuovi feature (se confermato)
   - Test mock → Rimuovi test se obsoleto
   - Duplicato → Sostituisci con icona principale

4. **Test**:
   ```bash
   flutter analyze
   flutter test
   ```

5. **Commit**:
   ```bash
   git add .
   git commit -m "refactor(icons): remove unused icon Icons.airline_seat_flat from debug screen"
   ```

**Batch Commit Strategy**:
- Ogni 10-15 icone rimosse → 1 commit
- Messaggio: `refactor(icons): cleanup rare icons batch 1/N (removed 15 icons)`

---

## 📖 Fase 3: Documenta Guidelines (Priorità Alta)

**Tempo stimato**: 1 ora

### 3.1 Create ICON_GUIDELINES.md

**File**: `docs/DESIGN_GUIDELINES/ICON_GUIDELINES.md`

**Contenuto**:

```markdown
# Icon Usage Guidelines - GymBro

> **Sistema centralizzato**: Usa SEMPRE `AppIcons.*` (mai `Icons.*` diretto)
> **Location**: `lib/shared/presentation/theme/app_icons.dart`

---

## 🏋️ Core Fitness Icons

### Workout/Exercise
```dart
AppIcons.workout          // fitness_center - Icona principale esercizio
AppIcons.cardio           // directions_run - Cardio/running
AppIcons.gymnastics       // sports_gymnastics - Bodyweight
```

**Quando usare**:
- `workout`: Lista esercizi, workout card, exercise chip
- `cardio`: Filtro cardio exercises
- `gymnastics`: Bodyweight exercises

---

## ⏱️ Timer Icons

### Timer States
```dart
AppIcons.timer            // Timer attivo (rest, workout)
AppIcons.timerOff         // Timer paused/completed
```

**Quando usare**:
- `timer`: Rest timer running, workout timer active
- `timerOff`: Timer disabled state, timer ended

**NON usare**:
- ❌ `Icons.timer_outlined` (deprecato)
- ❌ `Icons.timer_off_outlined` (deprecato)

---

## ✅ Success & Validation Icons

### Completion States
```dart
AppIcons.complete         // check_circle - Workout/set completato
AppIcons.completeOutline  // check_circle_outline - In progress
AppIcons.check            // check - Azione generica confermata
```

**Quando usare**:
- `complete`: Serie salvata, workout finito (filled circle = done)
- `completeOutline`: Serie in corso, workout started (outline = pending)
- `check`: Conferma azione, toggle selected

**NON usare**:
- ❌ `Icons.check_rounded` (deprecato)
- ❌ `Icons.check_circle_outline_rounded` (deprecato)

---

## 📈 Progress & Analytics Icons

### Trend Indicators
```dart
AppIcons.trendUp          // trending_up - Progressione positiva
AppIcons.trendDown        // trending_down - Declino
AppIcons.trendFlat        // trending_flat - Stabile
```

**Quando usare**:
- `trendUp`: Volume aumentato, 1RM migliorato, PR raggiunto
- `trendDown`: Volume diminuito, deload
- `trendFlat`: Metriche stabili

**NON usare per trend**:
- ❌ `Icons.arrow_upward` (usa per navigation, non trend)
- ❌ `Icons.north` (usa per direction, non trend)

### Analytics
```dart
AppIcons.analytics        // analytics - Dashboard, statistiche
AppIcons.barChart         // bar_chart - Grafici a barre
AppIcons.lineChart        // show_chart - Grafici linea
```

**NON usare**:
- ❌ `Icons.analytics_outlined` (deprecato)
- ❌ `Icons.analytics_rounded` (deprecato)

---

## 🎮 Gamification Icons

### Achievement & Rewards
```dart
AppIcons.star             // star - Rating pieno
AppIcons.starOutline      // star_border - Rating vuoto
AppIcons.achievement      // emoji_events - Trophy, achievement
AppIcons.streak           // local_fire_department - Streak days
```

**Quando usare**:
- `streak`: SOLO per streak counter (giorni consecutivi)
- `achievement`: Trophies, milestones unlocked

**NON usare per streak**:
- ❌ `Icons.whatshot` (usa per trending content, non streak)

---

## ⚙️ Settings & Admin

### Settings
```dart
AppIcons.settings         // settings - Impostazioni
AppIcons.admin            // admin_panel_settings - Admin dashboard
```

**NON usare**:
- ❌ `Icons.settings_outlined` (deprecato)
- ❌ `Icons.settings_rounded` (deprecato)

---

## ℹ️ Info & Feedback

### Warning States
```dart
AppIcons.warning          // warning - Warning generale
AppIcons.warningAmber     // warning_amber - Warning meno critico
AppIcons.error            // error_outline - Errore
```

**Quando usare**:
- `warning`: Azione irreversibile (delete workout)
- `warningAmber`: Attenzione non critica (form incomplete)
- `error`: Errore validazione, network error

**NON usare**:
- ❌ `Icons.warning_outlined` (deprecato)
- ❌ `Icons.warning_rounded` (deprecato)

---

## 🚫 Deprecation List

### Icone NON PIÙ USARE (Sostituisci con AppIcons)

| Deprecato | Sostituto | Ragione |
|-----------|-----------|---------|
| `Icons.timer_outlined` | `AppIcons.timer` | Duplicato inutile |
| `Icons.analytics_outlined` | `AppIcons.analytics` | Inconsistenza stile |
| `Icons.check_rounded` | `AppIcons.check` | Variante ridondante |
| `Icons.star_outline` | `AppIcons.starOutline` | Duplica star_border |
| `Icons.settings_rounded` | `AppIcons.settings` | Variante inutile |
| `Icons.arrow_upward` (per trend) | `AppIcons.trendUp` | Semantic clarity |

---

## 📦 Adding New Icons

### Process

1. **Verifica esistenza**:
   ```bash
   # Cerca se esiste già variante simile
   grep -r "IconData.*description" lib/shared/presentation/theme/app_icons.dart
   ```

2. **Aggiungi a AppIcons**:
   ```dart
   /// 📝 Description (emoji + contesto)
   /// Usato per: [use case 1], [use case 2]
   static const IconData newIcon = Icons.new_icon;
   ```

3. **Documenta in ICON_GUIDELINES.md**:
   ```markdown
   ## New Category
   ### NewIcon
   - Quando usare: ...
   - NON usare per: ...
   ```

4. **Test**:
   ```bash
   flutter analyze
   flutter test
   ```

---

## 🎨 Best Practices

### DO ✅

1. **Centralizza SEMPRE**:
   ```dart
   Icon(AppIcons.workout)  // ✅ Refactorable
   ```

2. **Semantic naming**:
   ```dart
   AppIcons.streak  // ✅ Chiaro: streak days
   ```

3. **Documenta uso**:
   ```dart
   /// Usato per: Lista esercizi, workout card
   ```

### DON'T ❌

1. **Import diretto**:
   ```dart
   Icon(Icons.fitness_center)  // ❌ No refactoring
   ```

2. **Varianti multiple**:
   ```dart
   Icons.timer          // ❌
   Icons.timer_outlined // ❌ Scegli 1 variante
   ```

3. **Semantic overlap**:
   ```dart
   Icons.trending_up vs Icons.arrow_upward  // ❌ Confuso
   ```

---

## 🔍 Audit Commands

### Find Icon Usage
```bash
# Conta usi di icona specifica
grep -r "AppIcons.timer" lib/ | wc -l

# Trova tutte le icone Material dirette (da rifattorizzare)
grep -r "Icons\.[a-z_]*" lib/ --include="*.dart" | grep -v "app_icons.dart"
```

### Bundle Size Analysis
```bash
# Check bundle size impact
flutter build apk --analyze-size
```

---

> **Ultima modifica**: 2025-11-01
> **Reviewed by**: Claude Code
> **Next review**: Dopo ogni nuovo icon aggiunto
```

---

### 3.2 Update DESIGN_GUIDELINES.md

**Aggiungi sezione**:

```markdown
## 🎨 Icon System

GymBro usa un sistema centralizzato di icone per:
- ✅ Refactoring facile (1 riga → intera app)
- ✅ Consistency visiva
- ✅ Semantic clarity

**Riferimento completo**: `docs/DESIGN_GUIDELINES/ICON_GUIDELINES.md`

**Quick reference**:
```dart
import 'package:gymbro/shared/presentation/theme/app_icons.dart';

// ✅ SEMPRE
Icon(AppIcons.workout)

// ❌ MAI
Icon(Icons.fitness_center)
```
```

---

## ✅ Fase 4: Test & Validation (Priorità Alta)

**Tempo stimato**: 1 ora

### 4.1 Automated Tests

```bash
# Lint check
flutter analyze

# Unit tests
flutter test

# Widget tests (se presenti)
flutter test test/features/workout/presentation/widgets/

# Integration tests (se presenti)
flutter test integration_test/
```

---

### 4.2 Visual Regression Test

**Checklist manuale**:

- [ ] Home screen → Verifica icone workout card
- [ ] Workout screen → Verifica timer icons
- [ ] Analytics screen → Verifica trend icons
- [ ] Settings screen → Verifica settings icons
- [ ] Achievement screen → Verifica star/trophy icons
- [ ] Streak widget → Verifica flame icon
- [ ] Success states → Verifica check icons
- [ ] Error states → Verifica warning icons

**Device matrix**:
- [ ] iOS Simulator (iPhone 14)
- [ ] Android Emulator (Pixel 5)
- [ ] Dark theme
- [ ] Light theme

---

### 4.3 Bundle Size Check

```bash
# Before cleanup
flutter build apk --analyze-size > /tmp/bundle_before.txt

# After cleanup (alla fine refactoring)
flutter build apk --analyze-size > /tmp/bundle_after.txt

# Compare
diff /tmp/bundle_before.txt /tmp/bundle_after.txt
```

**Expected**: -50KB to -100KB reduction

---

## 📊 Progress Tracking

### Checklist Completa

#### Fase 1: Varianti Duplicate (3-4 ore)
- [ ] 1.1 Timer icons (14 file) - 30 min
- [ ] 1.2 Analytics icons (13 file) - 20 min
- [ ] 1.3 Check/success icons (16 file) - 30 min
- [ ] 1.4 Star icons (15 file) - 20 min
- [ ] 1.5 Settings icons (8 file) - 15 min
- [ ] 1.6 Warning icons (20 file) - 25 min
- [ ] 1.7 Trend icons (semantic) - 30 min
- [ ] 1.8 Fire icons (semantic) - 20 min

**Subtotale**: 3 ore 10 min

---

#### Fase 2: Icone Rare (2-3 ore)
- [ ] 2.1 Generate audit report - 5 min
- [ ] 2.2 Categorize rare icons - 1 ora
- [ ] 2.3 Bulk removal (228 icons) - 1-2 ore

**Subtotale**: 2-3 ore

---

#### Fase 3: Documentazione (1 ora)
- [ ] 3.1 Create ICON_GUIDELINES.md - 45 min
- [ ] 3.2 Update DESIGN_GUIDELINES.md - 15 min

**Subtotale**: 1 ora

---

#### Fase 4: Test & Validation (1 ora)
- [ ] 4.1 Automated tests - 15 min
- [ ] 4.2 Visual regression test - 30 min
- [ ] 4.3 Bundle size check - 15 min

**Subtotale**: 1 ora

---

**TOTALE**: 7-8 ore

---

## 🚀 Getting Started

### Quick Start Commands

```bash
cd /Users/michele/gymbro_flutter_new

# 1. Create feature branch
git checkout -b refactor/icon-cleanup

# 2. Generate rare icons audit
grep -rh "Icons\." lib/ --include="*.dart" | \
  grep -o "Icons\.[a-z_]*" | \
  sort | uniq -c | \
  awk '$1 == 1' > /tmp/single_use_icons.txt

# 3. Start with Phase 1.1 (Timer icons)
# Open first file
code lib/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart

# Find & Replace:
# Icons.timer_outlined → AppIcons.timer
# Icons.timer_off_outlined → AppIcons.timerOff

# 4. Test after each batch
flutter analyze
flutter test

# 5. Commit frequently
git add .
git commit -m "refactor(icons): standardize timer icons (14 files)"

# 6. Repeat for next icon group
```

---

## 💡 Tips & Best Practices

### Refactoring Strategy

1. **Batch by icon type** (non per feature)
   - ✅ Tutti i timer icons insieme (14 file)
   - ❌ Tutti gli icons in workout screen (mescolato)

2. **Test dopo ogni batch** (max 20 file)
   - Evita debug nightmare se qualcosa rompe

3. **Commit frequentemente** (ogni 15-20 icone)
   - Easy rollback se necessario

4. **Use IDE Find & Replace** (multi-file)
   - VS Code: `Cmd+Shift+H` → Replace in Files
   - Regex per pattern complessi

5. **Visual regression test** (sample)
   - Non serve testare tutti i 100+ screen
   - Testa 5-10 screen rappresentativi

---

## 🐛 Common Issues & Solutions

### Issue 1: Import Missing

**Error**:
```
Error: 'AppIcons' isn't defined
```

**Solution**:
```dart
// Aggiungi import
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

---

### Issue 2: Icon Not Defined in AppIcons

**Error**:
```
Error: The getter 'timerOutlined' isn't defined for the class 'AppIcons'
```

**Solution**:
1. Apri `lib/shared/presentation/theme/app_icons.dart`
2. Aggiungi costante:
   ```dart
   static const IconData timerOutlined = Icons.timer_outlined;
   ```
3. Poi refactorizza via `timerOutlined` con `timer`

---

### Issue 3: Visual Regression

**Issue**: Icona cambia aspetto dopo refactor

**Solution**:
1. Verifica stile originale:
   ```dart
   // PRIMA
   Icons.timer_outlined  // Outlined style

   // DOPO
   AppIcons.timer        // Potrebbe essere filled
   ```
2. Se necessario, mantieni variante outlined:
   ```dart
   // app_icons.dart
   static const IconData timerOutlined = Icons.timer_outlined;
   ```

---

## 📈 Success Metrics

### Before vs After

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Total icons** | 441 | ~300 | -32% |
| **Rare icons (≤2)** | 228 | 0 | -100% |
| **Timer variants** | 4 | 2 | -50% |
| **Analytics variants** | 3 | 1 | -66% |
| **Check variants** | 5 | 3 | -40% |
| **Bundle size** | ~450KB | ~350KB | -22% |
| **Refactor time** | High | Low | -75% |
| **Documentation** | None | Complete | +100% |

---

## 🔗 Resources

- **Icon Report**: `docs/ICON_USAGE_REPORT.md`
- **App Icons**: `lib/shared/presentation/theme/app_icons.dart`
- **Guidelines**: `docs/DESIGN_GUIDELINES/ICON_GUIDELINES.md` (da creare)
- **Material Icons**: https://fonts.google.com/icons

---

## 📞 Questions?

**Stuck durante refactoring?**

1. Check guidelines: `docs/DESIGN_GUIDELINES/ICON_GUIDELINES.md`
2. Search icon usage: `grep -r "AppIcons.iconName" lib/`
3. Ask team: Slack #dev-questions

---

> **Created**: 2025-11-01
> **Author**: Claude Code
> **Status**: Ready to Execute
> **Next Action**: Start Phase 1.1 (Timer Icons)
