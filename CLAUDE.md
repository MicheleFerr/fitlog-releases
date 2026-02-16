# 🤖 CLAUDE.md - FitLog Pro

**Framework**: Flutter | **Arch**: Clean Architecture + Riverpod | **Status**: 🧪 Testing Phase (1 user)

> Breaking changes OK. Refactoring aggressivi permessi.

---

## 📚 DOCUMENTATION FIRST

**Entry point**: [`docs/INDEX.md`](docs/INDEX.md) → documentazione essenziale

**Regole e patterns**: Documentati in questo file e in [`docs/INDEX.md`](docs/INDEX.md)

---

## 🛡️ REGOLE CRITICHE (Pre-commit enforced)

| Regola | Corretto | Sbagliato |
|--------|----------|-----------|
| **Icone** | `AppIcons.*` | `Icons.*` |
| **Testi** | `context.l10n.*` | `'Hardcoded'` |
| **Colori** | `context.colors.*` | `Colors.blue` |
| **Loading** | `LoadingIndicator()` | `CircularProgressIndicator()` |
| **Snackbar** | `SnackBarService.*` | `ScaffoldMessenger.*` |
| **Icon Size** | `AppIconSize.medium` | `24` |

---

## 🏗️ iOS BUILD COMPLIANCE (CRITICAL)

```dart
Text(context.l10n.title)        // ✅
const Text(context.l10n.title)  // ❌ iOS build error!
```

- `context.l10n` solo in **Presentation layer** (widgets/screens)
- **MAI** in providers/domain/data → usa stringhe hardcoded
- Import: `hide Either, Right, Left` se usi fpdart

---

## 🎨 TEMA & COLORI

```dart
context.colors.primary    // invece di Colors.blue
context.colors.success    // invece di Colors.green
context.colors.error      // invece di Colors.red
context.colors.warning    // invece di Colors.amber
```

Import: `build_context_extensions.dart` + `color_scheme_extensions.dart`

---

## 📐 UI LAYOUT & NAVIGATION BAR

**CRITICAL**: MainShell usa `extendBody: true` e inietta padding bottom dinamico tramite MediaQuery.

### SafeArea Bottom Padding

```dart
// ✅ CORRETTO - Nuove pagine nella shell navigation
return SafeArea(
  bottom: false,  // Preserva padding MediaQuery per tab bar
  child: YourContent(),
);

// ❌ SBAGLIATO - Consuma il padding, contenuto copre tab bar
return SafeArea(
  child: YourContent(),
);
```

### ListView/ScrollView Padding

```dart
// ✅ CORRETTO - Usa padding dinamico dal MediaQuery
ListView.builder(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
  ),
  // ...
);

// ❌ SBAGLIATO - Valore fisso non si adatta a iOS/Android
ListView.builder(
  padding: const EdgeInsets.only(bottom: 80),
  // ...
);
```

**Perché?**
- `MainShell` calcola altezza tab bar dinamicamente (iOS vs Android)
- Inietta padding via `MediaQuery.copyWith(padding: bottom)`
- `SafeArea(bottom: false)` preserva questo padding
- Content scrollabile aggiunge `MediaQuery.padding.bottom + margine`

**Quando usare**:
- ✅ Tutte le pagine dentro `StatefulNavigationShell` (Home, Workout, Profile)
- ❌ Pagine fullscreen senza tab bar (Onboarding, modal, etc.)

---

## 🧩 ARCHITETTURA

```
lib/features/{name}/
├── domain/     # Entities, Repository interfaces
├── data/       # Repository impl, DataSources
└── presentation/ # Providers, Screens, Widgets
```

- **Provider THIN, Service FAT** - logica nel service
- **Repository estende BaseHybridRepository**
- **DataSource pattern** - repository NON tocca Firestore diretto

---

## 💳 TIER SYSTEM - DUAL ARCHITECTURE

**CRITICAL**: FitLog ha DUE sistemi tier SEPARATI:

### 1️⃣ **UserTier** (XP-based) - ✅ ATTIVO

```dart
enum UserTier {
  starter,   // 0 XP
  bronze,    // 100 XP
  silver,    // 500 XP
  gold,      // 1500 XP
  platinum,  // 5000 XP
}
```

**Fonte**: Progressione XP da allenamenti/achievements
**Usato per**: Determinare limiti custom exercises/templates
**Provider**: `userTierProvider` in `user_xp_provider.dart`

### 2️⃣ **AccountTier** (Subscription) - ⚠️ NON IMPLEMENTATO

```dart
enum AccountTier {
  free,     // Default (TUTTI gli utenti)
  premium,  // SOLO per testing (non rilasciato)
}
```

**Status**: Codice preparatorio per monetizzazione futura
**Attualmente**: Tutti gli utenti sono `AccountTier.free`
**Usato per**: Testing limiti nel debug screen admin-only

### ⚠️ REGOLE SVILUPPO

```dart
// ✅ CORRETTO - Usa UserTier (XP)
final tier = ref.watch(userTierProvider);
final maxExercises = tier.maxCustomSingleExercises;

// ❌ SBAGLIATO - Non usare AccountTier in produzione
if (accountTier == AccountTier.premium) { ... }  // Mai true!

// ✅ OK - Solo nel debug screen
final testAccount = AccountTier.premium;  // Per testing admin
```

### 📊 Logica Consolidamento

`TierEntitlements` prende il **massimo** tra XP tier e Account tier:

```dart
// UserTier.starter (4 templates) + AccountTier.premium (999)
// Result: 999 templates (premium vince)

// UserTier.platinum (30) + AccountTier.free (4)
// Result: 30 templates (XP tier vince)
```

**Quando sarà implementato premium**: Logica già pronta, basta attivare IAP.

---

## 🔄 PREVENZIONE CICLI DI DIPENDENZE

### ❌ VIETATO (Cross-feature cycles)
- Feature A importa Feature B + Feature B importa Feature A
- `core/navigation` importa `features/*`
- `shared/` importa `features/*`

### ✅ PERMESSO
- Features importano Core/Shared (one-way)
- Provider importa Service (one-way)
- Cicli intra-feature (same feature OK, monitorare)

### 🛠️ PATTERN SE SERVE ROMPERE UN CICLO

1. **Extract Shared Provider**: Sposta provider base in file `_shared.dart`
2. **Use context.go()**: Per navigazione, usa GoRouter context extension invece di `ref.read(routerProvider)`
3. **Move to correct feature**: Se un modulo è usato solo da 1 feature, spostalo in quella feature
4. **Re-export per backward compat**: `export 'new_file.dart' show Symbol;`

### ⚠️ CICLI RESIDUI NOTI (accettabili)
- `analytics ↔ workout` (workout_analytics_provider) - da risolvere in futuro
- Cicli intra-feature (same feature) - monitorare ma OK

---

## ⚡ PERFORMANCE RULES (MANDATORY)

### 🤖 CLAUDE - AUTOMATIC CHECK BEFORE CODING

**BEFORE writing ANY provider/service/repository code, Claude MUST:**

```bash
# 1. Check performance patterns in CLAUDE.md (questo file)
# 2. Use template from line 99-116 for services with resources
# 3. After editing, run:
.claude/scripts/performance-check.sh lib/features/<feature>/
```

**Git hook attivo**: Pre-commit blocca se trova anti-pattern.

---

### Loop & I/O

| Pattern | Sbagliato | Corretto |
|---------|-----------|----------|
| **Risorse in loop** | `for (x) { await openBox() }` | `box = await openBox(); for (x) { box.get() }` |
| **Batch ops** | `for (x) { await box.put() }` | `await box.putAll(entries)` |
| **Log in loop** | `for (x) { debugPrint(x) }` | `debugPrint('${items.length} items')` |

### Provider & Service

| Pattern | Sbagliato | Corretto |
|---------|-----------|----------|
| **Manager/Limiter** | `RateLimiter()` ogni chiamata | `static final _limiter = RateLimiter()` |
| **Async init** | `service.init()` fire-and-forget | Lock interno + `ref.onDispose()` |
| **Risorse costose** | Provider senza `keepAlive` | `ref.keepAlive()` se Hive/Firebase |

### Async & Cache

| Pattern | Sbagliato | Corretto |
|---------|-----------|----------|
| **Sequenziale** | `await a(); await b();` | `await Future.wait([a(), b()])` |
| **Letture duplicate** | `getCount()` + `getAll()` stesso dato | `final all = await getAll(); all.length` |
| **Eventi rapidi** | Handler diretto | `Timer` debounce 100ms |

### Template Service Singleton

```dart
class MyService {
  static MyService? _instance;
  factory MyService() => _instance ??= MyService._();
  MyService._();

  bool _initialized = false;
  final _initLock = Lock();

  Future<void> initialize() async {
    await _initLock.synchronized(() async {
      if (_initialized) return;
      // ... init ...
      _initialized = true;
    });
  }
}
```

---

## ✅ CHECKLIST RAPIDA

**UI/Styling:**
- [ ] `AppIcons.*` (no `Icons.*`)
- [ ] `context.l10n.*` (no hardcoded)
- [ ] `context.colors.*` (no `Colors.*`)
- [ ] NO `const` con `context.l10n`

**Performance:**
- [ ] No `openBox()`/I/O dentro loop
- [ ] Batch ops (`putAll`) invece di loop `put()`
- [ ] Manager/Limiter sono singleton
- [ ] `Future.wait()` per async indipendenti
- [ ] Debounce su event handlers rapidi

**Build:**
- [ ] `flutter analyze` passa
- [ ] `flutter gen-l10n` se nuove traduzioni

---

## 🚫 NON TOCCARE

- `ios/Runner/LiveActivityTimer/` - Swift nativo
- `ios/Runner/BackgroundTaskManager/` - Swift nativo
- `lib/shared/presentation/l10n/generated/` - Auto-generati
- `.dart_tool/`, `build/`, `firebase_options.dart`

---

## 🚀 FITLOG COPILOT

Comandi intelligenti per migliorare il workflow:

| Comando | Cosa fa |
|---------|---------|
| `/fitlog <task>` | Suggerisce l'agente/comando giusto per il task |
| `/context` | Carica contesto sessione (git, file recenti, TODO) |
| `/cleanup` | Trova file zombie (duplicati, orfani, stale) |

### Agenti Specializzati

| Agente | Quando usarlo |
|--------|---------------|
| `flutter-architect` | Nuove feature, architettura |
| `flutter-debugger` | Errori runtime, crash |
| `ios-specialist` | Live Activities, Swift |
| `timer-live-activity-specialist` | Timer, notifiche |
| `firebase-expert` | Firestore, auth, sync |
| `performance-optimizer` | Rebuild, memoria |

### Rules Enforcer (automatico)

Hook attivo su ogni Edit/Write che blocca violazioni:
- `Icons.*` → usa `AppIcons.*`
- `Colors.*` → usa `context.colors.*`
- Hardcoded strings → usa `context.l10n.*`
- `CircularProgressIndicator` → usa `LoadingIndicator()`

---

## 🔧 COMANDI UTILI

```bash
flutter gen-l10n              # Rigenera traduzioni
flutter analyze               # Check errori
./scripts/checkpoint.sh       # Auto-commit checkpoint
.claude/scripts/health-check.sh  # Check file zombie
.claude/scripts/gather-context.sh # Carica contesto
.claude/scripts/performance-check.sh [path]  # Check anti-pattern performance
```

### Post-Feature Checklist (OBBLIGATORIO per Claude)

Dopo OGNI modifica significativa o nuova feature, Claude DEVE eseguire:

```bash
.claude/scripts/performance-check.sh lib/features/<feature_modificata>/
```

Se vengono trovati warning, valutare e fixare prima di considerare la task completa.

---

## 👥 USER PERSONAS (MANDATORY Decision Framework)

**OBBLIGO**: Per OGNI decisione su feature/UX, eseguire Persona Impact Analysis.

| Persona | Profilo | Core Need |
|---------|---------|-----------|
| **Marco** | Principiante intimidito | Semplicità, guida |
| **Chiara** | Mamma multitasking | Velocità, zero friction |
| **Luca** | Powerlifter serio | Dati dettagliati |
| **Sofia** | Estetica-driven | Progressi visibili |
| **Roberto** | Professionista busy | Efficienza massima |

### Workflow Automatico

```
┌─────────────────────────────────────────────────┐
│ Prima di OGNI feature/decisione UX:            │
│                                                 │
│ 1. Identifica impatto per ogni persona (+/0/-) │
│ 2. BLOCCA se persona primaria ha "--"          │
│ 3. RIVEDI se 3+ personas hanno "-"             │
│ 4. Proponi mitigazioni per impatti negativi    │
└─────────────────────────────────────────────────┘
```

**Comando**: `/persona-check [feature]` per analisi completa

**Docs**: [`docs/USER_PERSONAS.md`](docs/USER_PERSONAS.md) | [`.claude/commands/persona-check.md`](.claude/commands/persona-check.md)

---

## 📖 DOCUMENTAZIONE

| Argomento | File |
|-----------|------|
| Entry point | [`docs/INDEX.md`](docs/INDEX.md) |
| **Template Cloud Sync** | [`docs/TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md`](docs/TEMPLATE_CLOUD_SYNC_DOCUMENTATION.md) ⭐ |
| **AI Coach Documents** | [`docs/AI_COACH_DOCUMENTS_IMPLEMENTATION.md`](docs/AI_COACH_DOCUMENTS_IMPLEMENTATION.md) ✅ |
| User Personas | [`docs/USER_PERSONAS.md`](docs/USER_PERSONAS.md) |
| Beta checklist | [`docs/BETA_LAUNCH_CHECKLIST.md`](docs/BETA_LAUNCH_CHECKLIST.md) |
| ADR | [`docs/ADR/`](docs/ADR/) |

> Documentazione precedente archiviata in `docs/_archived/`

---

## 🎯 GOLDEN RULES

```
╔═══════════════════════════════════════════════════════════╗
║  CERCA prima di creare. CONSOLIDA invece di duplicare.   ║
║  Se esiste → ESTENDI. Se serve in 2+ feature → SHARED.   ║
╚═══════════════════════════════════════════════════════════╝
```
