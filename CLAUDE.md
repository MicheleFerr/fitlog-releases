# 🤖 CLAUDE.md - FitLog Pro

**Framework**: Flutter | **Arch**: Clean Architecture + Riverpod | **Status**: 🧪 Testing Phase (1 user)

> Breaking changes OK. Refactoring aggressivi permessi.

---

## 📚 DOCUMENTATION FIRST

**Entry point**: [`docs/INDEX.md`](docs/INDEX.md) → documentazione essenziale

**Dettagli regole**: [`docs/DEVELOPMENT_RULES.md`](docs/DEVELOPMENT_RULES.md) | **Code patterns**: [`docs/CODE_PATTERNS.md`](docs/CODE_PATTERNS.md)

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
| User Personas | [`docs/USER_PERSONAS.md`](docs/USER_PERSONAS.md) |
| Architettura | [`docs/architecture/OVERVIEW.md`](docs/architecture/OVERVIEW.md) |
| Regole sviluppo | [`docs/DEVELOPMENT_RULES.md`](docs/DEVELOPMENT_RULES.md) |
| Pattern codice | [`docs/CODE_PATTERNS.md`](docs/CODE_PATTERNS.md) |
| Design system | [`docs/DESIGN_GUIDELINES.md`](docs/DESIGN_GUIDELINES.md) |
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
