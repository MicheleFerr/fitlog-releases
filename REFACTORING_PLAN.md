# 🚀 Piano di Refactoring Completo - GymBro TrackLog

**Obiettivo**: Code quality tier-1 con enforcement automatico
**Timeline**: 4-5 giorni
**Status**: 🟡 IN PROGRESS

---

## 📊 Baseline (Before)

```
❌ 1322 compilation errors (production)
❌ 743 test errors
❌ 92 broken import paths
❌ 218 files with hardcoded colors (2032 occurrences)
❌ ~100+ hardcoded strings in critical UI
❌ 40 files with raw CircularProgressIndicator
```

---

## 🎯 Target (After)

```
✅ 0 compilation errors
✅ 0 broken imports
✅ 0 hardcoded strings in user-facing UI
✅ <50 hardcoded colors (critical paths only)
✅ All components use unified services
✅ Pre-commit hooks active
✅ CI/CD quality gates active
```

---

## 📅 PHASE 1: Critical Blockers (Day 1)

**Obiettivo**: App compilabile, features principali funzionanti
**Effort**: 8 hours

### Task 1.1: Fix Import Paths (2-3h)

**Problem**: 92 broken import paths blocking compilation

```bash
# Files affected
lib/features/buddy_matching/**/*.dart (21 files)
lib/features/workout_templates/**/*.dart (15 files)
```

**Actions**:
- [ ] Find correct path for `app_localizations.dart`
- [ ] Recreate or move `italian_city.dart`
- [ ] Fix onboarding widget imports
- [ ] Convert all relative imports to absolute

**Script**:
```bash
# Auto-fix relative imports
find lib -name "*.dart" -type f -exec sed -i '' \
  "s|import '\.\./\.\./\.\./shared/|import 'package:gymbro_flutter_new/shared/|g" {} \;
```

**Success Criteria**:
```bash
flutter analyze | grep "Target of URI doesn't exist" | wc -l
# Target: 0
```

---

### Task 1.2: Import Missing Enums (30min)

**Problem**: 200+ errors from undefined enums

```dart
// Add imports
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart'; // ExerciseCategory, ExerciseType
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/volume_progress_chart_3d.dart'; // VolumeChartType
```

**Files to fix**:
- [ ] enhanced_volume_progress_chart.dart → import VolumeChartType
- [ ] smart_workout_templates_service.dart → import ExerciseCategory, ExerciseType
- [ ] All analytics widgets → import chart types

**Success Criteria**:
```bash
flutter analyze | grep "Undefined name 'ExerciseCategory'" | wc -l
# Target: 0
```

---

### Task 1.3: Fix Enhanced Volume Chart (1-2h)

**File**: `lib/features/analytics/presentation/widgets/enhanced_volume_progress_chart.dart`
**Errors**: 69

**Actions**:
- [ ] Add missing imports (VolumeChartType, VolumeRange)
- [ ] Fix constructor parameter mismatches
- [ ] Test analytics screen compilation

**Success Criteria**:
```bash
flutter analyze enhanced_volume_progress_chart.dart
# Target: 0 errors
```

---

### Task 1.4: Fix Smart Templates Service (3-4h)

**File**: `lib/features/smart_training/domain/services/smart_workout_templates_service.dart`
**Errors**: 54

**Problem**: Exercise constructor requires `category` and `type` parameters

**Actions**:
- [ ] Add `category: ExerciseCategory.strength` to all Exercise constructors
- [ ] Add `type: ExerciseType.compound` appropriately
- [ ] Import ExerciseCategory and ExerciseType enums
- [ ] Review business logic for correct category assignment

**Success Criteria**:
```bash
flutter analyze smart_workout_templates_service.dart
# Target: 0 errors
```

---

### Task 1.5: Create Missing Enums (1-2h)

**Enums to create**:

```dart
// lib/shared/domain/entities/pr_type.dart
enum PRType {
  weight,
  volume,
  reps,
  duration,
}

// lib/features/notifications/domain/entities/notification_type.dart
enum NotificationType {
  workout,
  achievement,
  social,
  reminder,
  system,
}

// lib/features/analytics/domain/entities/volume_range.dart
class VolumeRange {
  final double min;
  final double max;
  final String label;

  const VolumeRange({
    required this.min,
    required this.max,
    required this.label,
  });
}

// lib/features/timer/domain/entities/timer_state.dart
enum TimerState {
  idle,
  running,
  paused,
  completed,
}

// lib/features/workout_templates/domain/entities/import_parsing_result.dart
class ImportParsingResult {
  final bool success;
  final String? errorMessage;
  final dynamic data;

  const ImportParsingResult({
    required this.success,
    this.errorMessage,
    this.data,
  });
}
```

**Success Criteria**:
```bash
flutter analyze | grep "Undefined name 'PRType'" | wc -l
# Target: 0
```

---

### Phase 1 Completion Check

```bash
flutter analyze | grep "error •" | grep -v "test/" | wc -l
# Target: <300 errors (from 1322)
```

---

## 📅 PHASE 2: UX Critical - Hardcoded Strings (Day 2)

**Obiettivo**: App multilingua-compliant
**Effort**: 8 hours

### Task 2.1: Top 5 Critical UI Files (2h)

**Priority Files**:
1. `lib/features/workout/presentation/screens/edit_template_screen.dart`
2. `lib/features/workout/presentation/workout_screen.dart`
3. `lib/features/premium/presentation/screens/premium_upgrade_screen.dart`
4. `lib/features/buddy_matching/presentation/screens/buddy_matching_screen.dart`
5. `lib/features/home/presentation/widgets/*.dart` (main widgets)

**Process per file**:
```bash
# 1. Find hardcoded strings
grep "Text(" file.dart | grep -v "context.l10n" | grep -v "//"

# 2. Add to app_en.arb
{
  "templateNameRequired": "Template name is required",
  "@templateNameRequired": {
    "description": "Error when template name is empty"
  }
}

# 3. Translate to app_it.arb
{
  "templateNameRequired": "Il nome del template è obbligatorio"
}

# 4. Regenerate
flutter gen-l10n

# 5. Replace in code
Text('Il nome del template è obbligatorio')
→ Text(context.l10n.templateNameRequired)

# 6. Add import if missing
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
```

**Success Criteria**:
- [ ] Top 5 files have 0 hardcoded strings
- [ ] All added keys have EN + IT translations
- [ ] `flutter gen-l10n` runs without errors

---

### Task 2.2: Systematic Scan & Fix (6h)

**Strategy**: Feature-by-feature approach

```bash
# For each feature
for feature in workout analytics premium buddy_matching home; do
  echo "Processing: $feature"

  # Find all hardcoded strings
  grep -r "Text(" lib/features/$feature --include="*.dart" \
    | grep -v "context.l10n" \
    | grep -v "AppLocalizations" \
    | grep -v "//" > /tmp/${feature}_strings.txt

  # Fix manually with l10n keys
  # ...
done
```

**Features Priority**:
1. ✅ workout (main feature)
2. ✅ home (first screen)
3. ✅ premium (monetization)
4. ✅ analytics (engagement)
5. ✅ buddy_matching (social)
6. settings
7. notifications
8. admin (low priority)

**Success Criteria**:
```bash
./scripts/find_hardcoded_strings.sh | grep "Hardcoded string found" | wc -l
# Target: <10 (only debug/non-UI strings)
```

---

## 📅 PHASE 3: Theme Compliance (Day 3)

**Obiettivo**: Tema scuro/chiaro supportato correttamente
**Effort**: 6-8 hours

### Task 3.1: Create Auto-Migration Script (1h)

```bash
#!/bin/bash
# scripts/fix_hardcoded_colors.sh

# Common patterns
sed -i '' 's/Colors\.blue/context.colors.primary/g' $1
sed -i '' 's/Colors\.red/context.colors.error/g' $1
sed -i '' 's/Colors\.green/context.colors.primary/g' $1
sed -i '' 's/Colors\.grey/context.colors.onSurface.withOpacity(0.6)/g' $1
sed -i '' 's/Colors\.black/context.colors.onBackground/g' $1
sed -i '' 's/Colors\.white/context.colors.background/g' $1

# Add import if not present
if ! grep -q "build_context_extensions.dart" $1; then
  sed -i '' "1i\\
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';\\
" $1
fi

echo "Fixed: $1"
```

**Actions**:
- [ ] Create script
- [ ] Test on sample file
- [ ] Validate output compiles

---

### Task 3.2: Run on Top 50 Files (4-5h)

**Strategy**: Prioritize high-visibility screens

```bash
# Get top files with hardcoded colors
grep -r "Colors\." lib/features --include="*.dart" -l \
  | xargs -I {} bash -c 'echo "$(grep -c "Colors\." {}) {}"' \
  | sort -rn \
  | head -50 \
  > /tmp/top_color_files.txt

# Run auto-fix
while read count file; do
  ./scripts/fix_hardcoded_colors.sh "$file"
  flutter analyze "$file"  # Check still compiles
done < /tmp/top_color_files.txt
```

**Manual Review Required**:
- Gradient colors
- Shadow colors
- Custom brand colors
- Conditional colors (success/error states)

**Success Criteria**:
```bash
grep -r "Colors\." lib/features --include="*.dart" | \
  grep -v "Colors.transparent" | wc -l
# Target: <200 (from 2032)
```

---

### Task 3.3: Visual Testing (1-2h)

**Test Checklist**:
- [ ] Switch to dark theme → no white text on white background
- [ ] Switch to light theme → no black text on black background
- [ ] Test all main screens in both themes
- [ ] Check contrast ratios (accessibility)

---

## 📅 PHASE 4: Component Unification (Day 4)

**Obiettivo**: Eliminate component duplication
**Effort**: 4-6 hours

### Task 4.1: Replace CircularProgressIndicator (1-2h)

```bash
# Find all occurrences
grep -r "CircularProgressIndicator()" lib/features --include="*.dart" -n

# Replace pattern
# BEFORE:
Center(child: CircularProgressIndicator())

# AFTER:
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
LoadingIndicator()
```

**Files to fix**: 40

**Success Criteria**:
```bash
grep -r "CircularProgressIndicator()" lib/features --include="*.dart" | wc -l
# Target: 0
```

---

### Task 4.2: Replace ScaffoldMessenger (1-2h)

```bash
# Pattern
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('...')),
)

# Replace with
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
SnackBarService.showSuccess(context, context.l10n.message)
```

**Success Criteria**:
```bash
grep -r "ScaffoldMessenger.of(context)" lib/features --include="*.dart" | wc -l
# Target: <5 (complex cases only)
```

---

### Task 4.3: Replace showDialog/showModalBottomSheet (2h)

```bash
# Pattern
showDialog(
  context: context,
  builder: (_) => AlertDialog(...),
)

# Replace with
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
await ModalService.showConfirmDialog(
  context,
  title: context.l10n.title,
  message: context.l10n.message,
)
```

**Success Criteria**:
```bash
grep -r "showDialog(" lib/features --include="*.dart" | wc -l
# Target: <10 (complex custom dialogs only)
```

---

## 📅 PHASE 5: Automation & CI/CD (Day 5)

**Obiettivo**: Prevent regressions
**Effort**: 2-3 hours

### Task 5.1: Setup Pre-Commit Hooks (30min)

```bash
# Install hook
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Test
git add .
git commit -m "test"
# Should run all checks
```

**Success Criteria**:
- [ ] Hook runs on commit
- [ ] Blocks commit if errors found
- [ ] Shows warnings for quality issues

---

### Task 5.2: Setup GitHub Actions CI (1h)

**File**: `.github/workflows/code_quality.yml`

```yaml
name: Code Quality
on: [pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: ./scripts/find_hardcoded_strings.sh
      - run: ./scripts/quality_dashboard.sh
```

**Success Criteria**:
- [ ] CI runs on every PR
- [ ] Fails PR if errors found
- [ ] Posts quality dashboard to PR comments

---

### Task 5.3: Documentation & Training (1h)

**Actions**:
- [ ] Update README with quality rules link
- [ ] Create CONTRIBUTING.md with checklist
- [ ] Add badge to README (code quality score)
- [ ] Record quick video tutorial (5min)

---

## 📊 Progress Tracking

### Daily Checkpoints

**End of Day 1**:
```bash
flutter analyze | grep "error •" | grep -v "test/" | wc -l
# Target: <300 (from 1322)
```

**End of Day 2**:
```bash
./scripts/find_hardcoded_strings.sh | grep "Hardcoded string found" | wc -l
# Target: <10
```

**End of Day 3**:
```bash
grep -r "Colors\." lib/features --include="*.dart" | wc -l
# Target: <200
```

**End of Day 4**:
```bash
grep -r "CircularProgressIndicator()" lib/features --include="*.dart" | wc -l
# Target: 0
```

**End of Day 5**:
```bash
./scripts/quality_dashboard.sh
# All metrics in green
```

---

## 🎯 Definition of Done

### Must Have (Blocking)

- ✅ 0 compilation errors in production code
- ✅ 0 broken import paths
- ✅ Pre-commit hooks installed and working
- ✅ Top 10 UI files have 0 hardcoded strings
- ✅ CI/CD pipeline active

### Should Have (High Priority)

- ✅ All user-facing screens use context.l10n.*
- ✅ Top 50 files migrated to context.colors.*
- ✅ All CircularProgressIndicator replaced
- ✅ Quality dashboard < 50 total issues

### Nice to Have (Optional)

- 100% hardcoded strings removed
- 100% hardcoded colors removed
- All modals use ModalService
- Test errors fixed

---

## 🚀 Execution Command

```bash
# Start refactoring
git checkout -b refactoring/code-quality-tier1

# Phase 1
./scripts/phase1_fix_imports.sh
./scripts/phase1_fix_enums.sh
./scripts/phase1_fix_analytics.sh
./scripts/phase1_fix_templates.sh

# Phase 2
./scripts/phase2_top5_strings.sh
./scripts/phase2_systematic_strings.sh

# Phase 3
./scripts/phase3_fix_colors.sh

# Phase 4
./scripts/phase4_unify_components.sh

# Phase 5
./scripts/phase5_setup_automation.sh

# Verify
./scripts/quality_dashboard.sh

# Commit & PR
git add .
git commit -m "refactor: migrate to tier-1 code quality standards"
git push origin refactoring/code-quality-tier1
```

---

## 📞 Support

**Questions?** Check:
1. `CODE_QUALITY_RULES.md` - Regole stringenti
2. `CLAUDE.md` - Guidelines progetto
3. `DETAILED_ANALYSIS_REPORT.md` - Analisi dettagliata

**Ready to start?** 🚀

