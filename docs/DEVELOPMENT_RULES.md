# 📚 Development Rules - Regole Dettagliate

> **Questo file contiene le regole dettagliate di sviluppo. Per il quick reference, vedi [CLAUDE.md](../CLAUDE.md).**

---

## 🎯 ICON DESIGN SYSTEM (TIER-1)

> Sistema icone completo con centralizzazione, semantic sizing, colors, accessibility.

### 📐 1. AppIcons Centralizzate
**SEMPRE** `AppIcons.*` - MAI `Icons.*` | ~445 icone | Import: `app_icons.dart`
```dart
Icon(AppIcons.workout) // ✅ | Icon(Icons.fitness_center) // ❌
```

### 📏 2. AppIconSize
**SEMPRE** `AppIconSize.*` - MAI magic numbers | Sizes: tiny(16), small(20), medium(24), large(28), xlarge(32), xxlarge(48)
```dart
Icon(AppIcons.workout, size: AppIconSize.medium) // ✅ | size: 24 // ❌
```

### 🎨 3. Semantic Icon Colors
**SEMPRE** `context.icon*` - MAI hardcoded | Colors: Primary/Secondary/Tertiary, Success/Error/Warning/Info
```dart
Icon(AppIcons.workout, color: context.iconPrimary) // ✅ | Colors.blue // ❌
```

### ♿ 4. SemanticIcon - Accessibility
**SEMPRE** usa `SemanticIcon` per screen readers
```dart
SemanticIcon(icon: AppIcons.workout, semanticLabel: context.l10n.start) // ✅
AppIcons.workout.semantic(label: context.l10n.start) // ✅ shorthand
```

### 🎬 5. AnimatedIconPatterns
Patterns: `rotating()`, `pulsing()`, `bouncing()`, `fading()`, `shaking()`
```dart
AnimatedIconPatterns.rotating(icon: AppIcons.loading) // ✅
```

### 🔴 6. BadgedIcon
```dart
AppIcons.notifications.withBadge(count: 3) // ✅
```

### 📦 Imports Necessari
```dart
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
```

---

## 🔗 LISTENER CLEANUP (Memory Leak Prevention)

> Ogni `addListener` DEVE avere un corrispondente `removeListener` in `dispose()`.

### Pattern CORRETTO
```dart
class _MyWidgetState extends State<MyWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);  // ← SEMPRE rimuovere!
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() { /* ... */ }  // Metodo named, NON anonimo
}
```

### ❌ ERRORI COMUNI
```dart
// ❌ Listener anonimo - impossibile da rimuovere
_controller.addListener(() { setState(() {}); });

// ❌ removeListener mancante quando controller esterno
void dispose() {
  if (widget.controller == null) { _controller.dispose(); }
  // Manca removeListener! Memory leak se controller esterno
}
```

### ✅ ECCEZIONI (safe senza removeListener)
- `TabController` con listener anonimo → `dispose()` pulisce automaticamente
- `AnimationController` con `addStatusListener` → `dispose()` pulisce automaticamente
- Controller creato E posseduto dallo stesso widget → `dispose()` del controller basta

---

## 🎨 DESIGN SYSTEM (Comportamento Automatico)

Quando lavori su UI (widget, screen, dialog, card, button):

### PRIMA di Scrivere Codice
1. Leggi `docs/DESIGN_GUIDELINES.md` (sezione rilevante)
2. Identifica pattern standard da riutilizzare

### DURANTE l'Implementazione
**SEMPRE usa**:
- `context.colors.*` (MAI colori hardcoded)
- `context.textTheme.*` (MAI TextStyle hardcoded)
- `context.l10n.*` (MAI stringhe hardcoded)
- Spacing = multipli di 4 (4, 8, 12, 16, 20, 24, 32)
- Border radius = 8, 12, 16, 20, 24
- HapticFeedback su azioni interattive
- LoadingIndicator (MAI CircularProgressIndicator diretto)
- SnackBarService (MAI ScaffoldMessenger diretto)

### Pattern Standard Card
```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: /* Content */,
  ),
)
```

### Risorse
- **Guida completa**: `docs/DESIGN_GUIDELINES.md` (600+ righe)
- **Esempio reale**: `lib/features/routine/presentation/widgets/skip_recovery_dialog.dart`

---

## 🧩 COMPONENTI UNIFICATI

| Componente | Uso | Mai usare direttamente |
|------------|-----|------------------------|
| `LoadingIndicator` | Loading states | `CircularProgressIndicator` |
| `SnackBarService` | Messaggi | `ScaffoldMessenger.showSnackBar` |
| `ModalService` | Modals/dialogs | `showModalBottomSheet` |
| `MaterialScrollList` | Liste con card | `ListView.builder` |

### MaterialScrollList
```dart
MaterialScrollList(
  itemCount: items.length,
  itemBuilder: (context, index) => MyCardWidget(items[index]),
  effectIntensity: 1.0, // 0.0 (off) → 2.0 (forte)
)
```

---

## 📝 DOCUMENTAZIONE AUTOMATICA POST-IMPLEMENTAZIONE

Dopo ogni implementazione significativa, Claude:
1. **RILEVA** automaticamente nuovi file/modifiche significative
2. **CHIEDE**: "Vuoi che documenti questa implementazione?"
3. **GENERA**: Documentazione completa in `docs/UX_FLOWS/`
4. **INTERCONNETTE**: Aggiorna INDEX.md e CLAUDE.md
5. **COMMIT**: Salva tutto

**Regole di Rilevamento**:
| Condizione | Chiede documentazione |
|-----------|----------------------|
| Nuovi file in `lib/features/` | ✅ SÌ |
| Nuovi screen `*_screen.dart` | ✅ SÌ |
| Nuovi provider `*_provider.dart` | ✅ SÌ |
| Modifiche >100 righe | ✅ SÌ |
| Piccoli fix <50 righe | ❌ NO |

---

## 🔧 AUTOMAZIONE PRE-COMMIT

### CLAUDE.md Auto-Staging
CLAUDE.md viene **automaticamente staged** se modificato.

### Auto-Checkpoint System
```bash
./scripts/checkpoint.sh           # Commit immediato
./scripts/checkpoint.sh --watch   # Watch mode background
git checkpoint                    # Git alias
```

**Soglie Default**: 50+ righe modificate OPPURE 3+ file .dart

**Documentazione completa**: `scripts/CHECKPOINT_README.md`

---

## 🎯 SINGLE SOURCE OF TRUTH - I 10 MANTRA

### MANTRA 1: CERCA PRIMA DI CREARE
```
Prima di creare un nuovo file, CERCO se esiste già qualcosa di simile
```
```bash
grep -r "{nome}" lib/
```

### MANTRA 2: UN'ENTITÀ = UN FILE
Entità condivise vanno in `lib/shared/domain/entities/`

### MANTRA 3: UN REPOSITORY PER ENTITÀ
Se serve accesso da altra feature: Usa dependency injection, NON duplicare

### MANTRA 4: PROVIDER THIN, SERVICE FAT
Evita Provider con 500+ righe di business logic

### MANTRA 5: ESTENDI BASEHIBRIDREPOSITORY
```dart
class WorkoutRepositoryImpl extends BaseHybridRepository<Workout>
    implements WorkoutRepository { ... }
```

### MANTRA 6: NOMI UNIVOCI
| Tipo | Pattern |
|------|---------|
| Entity | `{Nome}` |
| Repository | `{Feature}{Nome}Repository` |
| Provider | `{feature}{nome}Provider` |
| Service | `{Feature}{Azione}Service` |

### MANTRA 7: DATASOURCE PATTERN
Repository → DataSource → Firestore/Hive

### MANTRA 8: UTILITY IN SHARED
Utility usati da 2+ feature vanno in `lib/shared/`

### MANTRA 9: VERIFICA IMPORTS
Usa SEMPRE la versione in `shared/` se esiste

### MANTRA 10: CONSOLIDA, NON DUPLICARE
Modifica esistente invece di creare "EnhancedXxxProvider"

### Comandi Verifica Duplicazioni
```bash
find lib -name "*_repository*.dart" | sort
find lib -name "*_provider*.dart" | sort
grep -rh "^class " lib/ | sort | uniq -d
```

---

## 🚦 NAVIGATION & ASYNC PATTERNS

### Navigation Guards
**✅ CORRETTO** - Global redirect in GoRouter provider:
```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) {
      if (authState != AuthState.authenticated) {
        return AppRoutes.loginPath;
      }
      return null;
    },
    routes: [...],
  );
});
```

### Async Error Handling
**✅ CORRETTO** - AsyncValue.guard():
```dart
Future<void> setWorkoutsPerWeek(int value) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    await _saveGoals(newGoals);
    return newGoals;
  });
}
```

### Timeout Pattern
**✅ CORRETTO** - .timeout(onTimeout:):
```dart
final serverValue = await serverFetch.timeout(
  Duration(seconds: 5),
  onTimeout: () => cacheFallback(),
);
```

### Golden Rules
```
NAVIGATION: Global redirect > Route-level guards
ASYNC: AsyncValue.guard() > Manual try/catch
TIMEOUT: .timeout(onTimeout:) > Future.any()
```

---

## 📚 Riferimenti

- **Icon System**: `app_icons.dart`, `app_icon_size.dart`, `app_icon_colors.dart`
- **Design Guidelines**: `docs/DESIGN_GUIDELINES.md`
- **Taskmaster Integration**: `docs/plans/TASKMASTER_GUIDE.md`
- **Checkpoint System**: `scripts/CHECKPOINT_README.md`
