# 🏗️ Architecture Refactoring Roadmap - GymBro Flutter

**Status**: In Progress (Phase 1 completata)
**Data inizio**: 2026-02-16
**Obiettivo**: Eliminare violazioni architetturali e cicli di dipendenze

---

## 📊 STATO ATTUALE (Post Phase 1)

### Metriche Before → After

| Metrica | Before (2026-02-16) | After Phase 1 | Target Finale |
|---------|---------------------|---------------|---------------|
| 🔴 Cicli cross-feature | **6** | **1** (-83%) | **0** |
| 🔴 Violazioni core←features | ??? | **83** | **0** |
| 🟡 God modules (>50 import) | ??? | **2** | **0** |
| 🟡 Features hub (dovrebbero essere in shared) | ??? | **3** | **0** |
| ⚠️ Presentation→Data (viola Clean Arch) | ??? | **110** | **<20** |

### ✅ Completato (Phase 1 - 2026-02-16)

| # | Ciclo Risolto | Soluzione | Commit |
|---|---------------|-----------|--------|
| 1 | Auth ↔ Progress | Estratto `auth_providers_shared.dart` | `1cbb1410` |
| 2 | App ↔ Router | Spostato `initialDeepLinkProvider` in shared | `1cbb1410` |
| 3 | Router ↔ Onboarding | Usa `context.go()` invece di `ref.read(appRouterProvider)` | `1cbb1410` |
| 4 | Timer ↔ Workout (×2) | Spostato `features/timer/` → `features/workout/timer/` | `1cbb1410` |

**File modificati**: 24
**Righe aggiunte**: 112
**Righe rimosse**: 494

---

## 🔴 PROBLEMI CRITICI DA RISOLVERE

### 1. Core ← Features (83 violazioni) - P0

**Problema**: Core dipende da features invece del contrario.

**Esempi critici**:
```
❌ core/auth/admin_status_provider.dart → features/auth/.../consolidated_user_provider.dart
❌ core/providers/analytics_initialization_provider.dart → features/auth/presentation/providers/auth_provider.dart
❌ core/providers/tier_entitlements_provider.dart → features/home/providers/user_xp_provider.dart
❌ core/navigation/main_shell.dart → features/onboarding/.../hint_peek.dart
```

**Soluzione**:
1. Spostare `consolidated_user_provider` → `shared/auth/providers/`
2. Spostare `user_xp_provider` → `shared/domain/user/`
3. Estrarre interface `IHintSystem` in `core/navigation/interfaces/`
4. Refactoring `admin_status_provider` per usare dependency injection

**Effort**: 1-2 giorni

---

### 2. Features Hub (3 entità usate ovunque) - P0

**Problema**: Entità core del dominio sono in features specifiche ma usate da 15+ features.

| File | Import IN | Dove dovrebbe stare |
|------|-----------|---------------------|
| `features/workout/domain/entities/exercise.dart` | **92** | `shared/domain/entities/` |
| `features/workout/domain/entities/workout.dart` | **58** | `shared/domain/entities/` |
| `features/workout/domain/entities/workout_template.dart` | **42** | `shared/domain/entities/` |

**Soluzione**:
```bash
# 1. Crea struttura shared
mkdir -p lib/shared/domain/entities/

# 2. Sposta entità
git mv lib/features/workout/domain/entities/exercise.dart \
       lib/shared/domain/entities/exercise.dart

git mv lib/features/workout/domain/entities/workout.dart \
       lib/shared/domain/entities/workout.dart

git mv lib/features/workout/domain/entities/workout_template.dart \
       lib/shared/domain/entities/workout_template.dart

# 3. Aggiorna import globalmente (92 + 58 + 42 = 192 file)
find lib test -name "*.dart" -exec sed -i '' \
  's|features/workout/domain/entities/exercise\.dart|shared/domain/entities/exercise.dart|g' {} \;

find lib test -name "*.dart" -exec sed -i '' \
  's|features/workout/domain/entities/workout\.dart|shared/domain/entities/workout.dart|g' {} \;

find lib test -name "*.dart" -exec sed -i '' \
  's|features/workout/domain/entities/workout_template\.dart|shared/domain/entities/workout_template.dart|g' {} \;

# 4. Verifica build
flutter analyze lib/
```

**Effort**: 2-3 ore + testing

---

### 3. God Modules (2 trovati) - P1

#### 3.1 `core/navigation/app_router.dart` (59 import, 47 cross-feature)

**Problema**: Router conosce tutte le feature screens direttamente.

**Soluzione - Lazy Loading Pattern**:

```dart
// PRIMA (import diretto)
import 'package:gymbro_flutter_new/features/analytics/presentation/analytics_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen.dart';
// ... 47 import

// DOPO (lazy con builder)
final routes = <String, RouteBuilder>{
  '/analytics': (_) => const AnalyticsScreen(),
  '/workout': (_) => const WorkoutScreen(),
  // ...
};

// O ancora meglio: route registry per feature
abstract class FeatureRoutes {
  Map<String, RouteBuilder> get routes;
}

// Ogni feature registra le sue route
class AnalyticsRoutes implements FeatureRoutes {
  @override
  Map<String, RouteBuilder> get routes => {
    '/analytics': (_) => const AnalyticsScreen(),
    '/analytics/exercise': (state) => ExerciseDetailScreen(...),
  };
}
```

**Effort**: 4-6 ore

#### 3.2 `features/workout/presentation/providers/workout_provider.dart` (52 import, 22 cross-feature)

**Problema**: Provider fa troppe cose (workout + timer + analytics + history).

**Soluzione - Split Provider**:

```dart
// Splittare in:
workout_state_provider.dart      // Stato workout corrente
workout_actions_provider.dart    // Azioni (start, pause, complete)
workout_timer_bridge.dart        // Bridge con timer (già in workout/timer/)
workout_analytics_sync.dart      // Sync con analytics
workout_history_sync.dart        // Sync con history
```

**Effort**: 1 giorno + testing

---

### 4. Cross-Feature Imports (11 features) - P1

**Top violatori** (importano da >5 altre features):

| Feature | Import cross-feature | Soluzione |
|---------|----------------------|-----------|
| `home` | **16** | Estrarre `shared/home_widgets/` per widget riutilizzabili |
| `workout` | **16** | Già in piano (entità in shared) |
| `auth` | **11** | Estrarre `shared/auth/` per provider base |
| `settings` | **10** | Estrarre `shared/settings/` per config comuni |
| `stress_index` | **9** | Estrarre calculators in `shared/domain/calculations/` |
| `analytics` | **9** | Estrarre metrics in `shared/domain/metrics/` |

**Pattern generale**:
1. Identifica codice riutilizzato da 3+ features
2. Sposta in `shared/{domain|presentation|utils}/`
3. Crea barrel export per facilità d'uso

**Effort**: 2-3 giorni

---

### 5. Presentation → Data (110 violazioni) - P2

**Problema**: Presentation layer accede direttamente a repositories/datasources.

**Esempi**:
```dart
// ❌ SBAGLIATO
class MyScreen extends ConsumerWidget {
  Widget build(context, ref) {
    final repo = ref.watch(myRepositoryProvider);
    final data = repo.getData(); // Presentation → Data diretto
  }
}

// ✅ CORRETTO
class MyScreen extends ConsumerWidget {
  Widget build(context, ref) {
    final dataState = ref.watch(myDataProvider); // Presentation → Provider
    // Provider internamente chiama use case/repository
  }
}
```

**Soluzione**:
- Wrappare tutti i repository in provider dedicati
- Usare pattern Repository → Provider → UI
- Mai importare `*_repository.dart` da presentation layer

**Effort**: 5+ giorni (110 violazioni da fixare)

---

## 🎯 PIANO DI ESECUZIONE PRIORITARIO

### Sprint 1: P0 - Violazioni Core (3 giorni)

**Giorno 1-2**:
- [ ] Spostare entità workout in `shared/domain/entities/`
- [ ] Aggiornare 192 import
- [ ] Test build + run app

**Giorno 2-3**:
- [ ] Spostare `consolidated_user_provider` in shared
- [ ] Spostare `user_xp_provider` in shared
- [ ] Fix top 10 violazioni core←features

**Deliverable**: 0 violazioni core←features critiche

---

### Sprint 2: P1 - God Modules & Cross-Feature (5 giorni)

**Giorno 4-5**:
- [ ] Refactoring `app_router` con lazy loading
- [ ] Ridurre import da 59 a <30

**Giorno 6-7**:
- [ ] Splittare `workout_provider` in 5 provider
- [ ] Test funzionalità workout

**Giorno 8**:
- [ ] Estrarre codice comune da top 5 features in shared
- [ ] Ridurre cross-feature imports del 50%

**Deliverable**: 0 god modules, cross-feature imports <50%

---

### Sprint 3: P2 - Clean Architecture (7+ giorni)

**Settimana 2**:
- [ ] Fix tutte le violazioni presentation→data
- [ ] Wrappare repositories in provider
- [ ] Pattern standardizzato Repository → Provider → UI

**Deliverable**: <20 violazioni presentation→data

---

## 📋 COMANDI UTILI

### Rigenerare grafo dipendenze

```bash
python3 << 'EOF'
import os, re
from collections import defaultdict

edges = []
for root, dirs, files in os.walk('lib'):
    dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'generated']]
    for f in files:
        if not f.endswith('.dart'): continue
        path = os.path.join(root, f)
        rel = os.path.relpath(path, 'lib')
        with open(path) as fh:
            for line in fh:
                m = re.match(r"import\s+'package:gymbro_flutter_new/(.*?)';", line)
                if m:
                    target = m.group(1)
                    if target.startswith('lib/'): target = target[4:]
                    edges.append((rel, target))

print("digraph G {")
print("  rankdir=LR;")
print("  node [shape=box];")
for s, t in edges:
    print(f'  "{s}" -> "{t}";')
print("}")
EOF
```

### Analizzare cicli

```bash
python3 analyze_cycles.py > /tmp/cycles_report.txt
cat /tmp/cycles_report.txt
```

### Verificare violazioni layering

```bash
grep -r "import.*features/" lib/core/ lib/shared/ | wc -l
```

---

## 📚 RIFERIMENTI

- **Commit refactoring Phase 1**: `1cbb1410`
- **Documentazione pattern**: `CLAUDE.md` (sezione "🔄 PREVENZIONE CICLI")
- **File analisi**: `/tmp/deps_new.dot` (grafo generato)
- **Conversazione originale**: Chat 2026-02-16 con analisi grafo SVG

---

## 🔧 TROUBLESHOOTING

### Import non trovati dopo spostamento file

```bash
# Verifica import rotti
flutter analyze lib/ 2>&1 | grep "Target of URI doesn't exist"

# Fix automatico (esempio per exercise.dart)
find lib test -name "*.dart" -exec sed -i '' \
  's|OLD_PATH|NEW_PATH|g' {} \;
```

### Build fallisce dopo refactoring

```bash
# Clean completo
flutter clean
rm -rf .dart_tool/
flutter pub get
flutter analyze
```

### Test rotti

```bash
# Rigenera mock
flutter pub run build_runner build --delete-conflicting-outputs

# Run test specifico
flutter test test/path/to/test.dart
```

---

## ✅ CHECKLIST PRIMA DI OGNI SPRINT

- [ ] Branch dedicato creato (`git checkout -b arch/sprint-N`)
- [ ] Backup commit corrente (`git tag backup-YYYY-MM-DD`)
- [ ] Tutti i test passano (`flutter test`)
- [ ] Build passa (`flutter build apk --debug`)
- [ ] Nessun file uncommitted (`git status`)

---

**Next Steps**: Inizia con Sprint 1 - P0 Violazioni Core
