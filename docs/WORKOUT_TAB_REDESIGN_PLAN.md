# Workout Tab Redesign Plan

**Data**: 2026-02-16
**Status**: Da implementare
**Priorita**: Alta - UX critica per tutte le personas

---

## 1. Stato Attuale e Problemi

### 1.1 Architettura attuale

La tab Workout (`WorkoutScreen`) ha 3 stati:

```
WorkoutScreen (orchestrator)
  ├── WelcomeView     → Nessun workout attivo
  ├── PreloadedView   → Workout suggerito ma non avviato
  └── WorkoutView     → Workout attivo (in progress/paused)
```

**File coinvolti**:
- `lib/features/workout/presentation/workout_screen.dart` (orchestrator)
- `lib/features/workout/presentation/workout_screen/widgets/welcome_view.dart`
- `lib/features/workout/presentation/workout_screen/widgets/preloaded_view.dart`
- `lib/features/workout/presentation/workout_screen/widgets/workout_view.dart`
- `lib/features/workout/presentation/workout_screen/controllers/workout_screen_controller.dart`

### 1.2 Problemi identificati

| # | Problema | Severity | File |
|---|---------|----------|------|
| 1 | **BG nero in light mode** | CRITICO | `workout_screen.dart` - `Colors.transparent` su 3 Scaffold |
| 2 | **WelcomeView duplica la Home** | ALTO | `welcome_view.dart` - Stessi template + CTA |
| 3 | **PreloadedView aspetto prototipo** | ALTO | `preloaded_view.dart` - ListTile + CircleAvatar basici |
| 4 | **Back nav incoerente** | ALTO | `workout_screen.dart:791` - `goNamed('home')` cambia branch |
| 5 | **"Create Template" naviga fuori tab** | MEDIO | `workout_screen.dart:943` - `context.go('/templates')` |
| 6 | **Push vs Go inconsistente** | MEDIO | `start_workout_card.dart:70,108` - `context.push('/workout')` |
| 7 | **Nessun AppBar nella WelcomeView** | BASSO | `workout_screen.dart:319` - Scaffold senza AppBar |
| 8 | **Stile visivo diverso dalla Home** | BASSO | `welcome_view.dart:197` - BackdropFilter custom |

### 1.3 FIX gia applicato

Il problema #1 (BG nero) e stato fixato rimuovendo `backgroundColor: Colors.transparent` dai 3 Scaffold in `workout_screen.dart` (righe 320, 343, 414).

---

## 2. Ricerca UX - Best Practices Fitness App

### 2.1 Analisi Competitiva

| App | Workout Tab (empty state) | Template Access | Tap per iniziare |
|-----|---------------------------|-----------------|------------------|
| **Strong** | Minimalista: solo "Start Empty Workout" grande | Tab separata "Routines" | 2 tap |
| **Hevy** | Quick Start + ultimi 3-5 template | Combinato nel workout tab | 2 tap |
| **JEFIT** | Lista giornaliera filtrata | Tab "My Plans" separata | 3-4 tap |

**Pattern vincente** (Hevy): CTA grande + pochi template recenti + "See all"

### 2.2 Principi UX Evidence-Based

**Paradosso della Scelta (Barry Schwartz)**:
- Troppe opzioni (>7) → decision fatigue, abbandono
- Sweet spot: **3-5 opzioni** massimo
- 1 CTA primaria + 3-4 secondarie

**Cognitive Load (Nielsen Norman Group)**:
- Eliminare testo non necessario
- Smart defaults invece di scelta manuale
- Progressive disclosure (avanzate nascoste)

**Fitness App UX (Stormotion)**:
> "Minimize steps from goal to start workout to ideally under 60 seconds"

**Strong App philosophy**:
> "Think less, lift more" - rimuovere la decision paralysis

### 2.3 Metriche Target

| Metrica | Attuale (stimato) | Target |
|---------|-------------------|--------|
| Tap per iniziare workout | 3-5 | **1-2** |
| Tempo apertura → workout start | 12-15s | **<5s** |
| Template visibili contemporaneamente | Tutti (10+) | **3-5** |
| Decision points prima di iniziare | 3-4 | **0-1** |

---

## 3. Persona Impact Analysis

### 3.1 Impatto per Persona

| Persona | Problema Principale | Soluzione | Impatto |
|---------|-------------------|-----------|---------|
| **Marco** (Principiante) | Troppi template → "quale scelgo?" | Max 3-5 visibili + suggerimento AI | Decision paralysis -40% |
| **Chiara** (Busy mom) | Troppi tap per iniziare | Quick Start prominente + 1-tap su template | Friction -70% |
| **Luca** (Powerlifter) | Nessun ordine logico template | Ordinati per frequenza + last used badge | Organizzazione +50% |
| **Sofia** (Estetica-driven) | PreloadedView brutta | Card premium con preview | Appeal visivo +80% |
| **Roberto** (Professionista) | Nessun "resume last" | Smart suggestion + swipe shortcuts | Efficienza +60% |

### 3.2 Stato Attuale WelcomeView

**Marco**: `--` (cognitive overload, 10+ template visibili)
**Chiara**: `--` (troppi tap, friction alta)
**Luca**: `-` (nessun ordinamento)
**Sofia**: `-` (design inconsistente)
**Roberto**: `--` (inefficiente, nessun smart default)

### 3.3 Dopo Redesign (atteso)

**Marco**: `++` (3 template + suggerimento chiaro)
**Chiara**: `++` (1-2 tap, Quick Start prominente)
**Luca**: `+` (ordinamento per frequenza)
**Sofia**: `+` (design coerente col resto dell'app)
**Roberto**: `++` (AI suggestion + resume last)

---

## 4. Design Proposto

### 4.1 WelcomeView Redesign

**Principio**: Tab Workout = **Launcher Intelligente** (non template manager)

```
┌─────────────────────────────────────────────┐
│  WORKOUT TAB (no workout attivo)            │
│                                             │
│  AppBar: "Allenamento"    [gear icon]       │
│                                             │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │
│  ┃ ⚡ INIZIA SUBITO                       ┃  │  ← CTA primaria (2x)
│  ┃ Inizia immediatamente e aggiungi       ┃  │
│  ┃ esercizi al volo                        ┃  │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
│                                             │
│  ──────────────────────────────────────────│
│                                             │
│  💡 Suggerito per oggi                      │  ← AI suggestion
│  ┌────────────────────────────────────────┐ │     (templateSuggestionProvider)
│  │ UPPER POWER           6 giorni fa      │ │
│  │ ✓ Muscoli recuperati                   │ │
│  │ Panca, Distensioni, Rematore +5        │ │
│  │                            [INIZIA ▶]  │ │  ← 1-tap start
│  └────────────────────────────────────────┘ │
│                                             │
│  ──────────────────────────────────────────│
│                                             │
│  Ultimi usati                               │  ← Max 3 template
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐  │     + "Vedi tutti"
│  │LOWER │ │UPPER │ │LEG   │ │Vedi      │  │
│  │POWER │ │HYPER │ │DAY   │ │tutti (8) │  │
│  │  ▶   │ │  ▶   │ │  ▶   │ │   →      │  │
│  └──────┘ └──────┘ └──────┘ └──────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

### 4.2 Componenti Necessari

#### A. QuickStartCard (gia esiste, da ingrandire)
- File: `welcome_view.dart:92-189`
- Modifica: Padding e font size piu grandi

#### B. TodaysWorkoutCard (NUOVO)
- Riutilizza `templateSuggestionProvider` (gia in `lib/features/stress_index/`)
- Mostra il template migliore per oggi con bottone "Inizia" diretto
- Se tutti i muscoli affaticati → mostra "Rest Day" card

#### C. RecentTemplatesCarousel (NUOVO)
- Widget orizzontale scrollabile
- Mostra ultimi 3 template usati (ordinati per `lastUsedAt`)
- Ogni card ha bottone `[▶]` per tap-to-start
- Ultimo item: "Vedi tutti (N)" che naviga a `/templates`

#### D. EmptyState (per utenti senza template)
- Icona grande + testo motivazionale
- "Non hai template. Creane uno!" → bottone a `/templates`

### 4.3 PreloadedView Redesign

**Problema attuale**: ListTile basici con CircleAvatar → aspetto prototipo

**Redesign**: Riutilizzare le stesse exercise cards del WorkoutView ma in modalita read-only.

```
┌─────────────────────────────────────────────┐
│  AppBar: "UPPER POWER"  [Suggested badge]   │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │ Panca Piana con Bilanciere             │ │  ← Card come WorkoutView
│  │ 4 serie × 10 reps @ 80kg (suggerito)  │ │     ma non interattiva
│  └────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────┐ │
│  │ Distensioni Inclinato su Panca         │ │
│  │ 3 serie × 12 reps                     │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ... (altri esercizi)                       │
│                                             │
│  ChangeWorkoutBanner                        │
│                                             │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │
│  ┃ [▶ INIZIA WORKOUT]  (full width)      ┃  │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
└─────────────────────────────────────────────┘
```

---

## 5. Piano di Implementazione

### FASE 1: Fix Tecnici Critici (30 min)

> Prerequisiti: nessuno. Fix indipendenti.

#### Task 1.1: Fix sfondo nero ✅ COMPLETATO
- File: `workout_screen.dart`
- Azione: Rimosso `backgroundColor: Colors.transparent` dai 3 Scaffold

#### Task 1.2: Fix back navigation
- File: `workout_screen.dart:791-793`
- **Attuale**: `context.goNamed('home')` → cambia branch
- **Fix**: Se workout non attivo → `context.pop()` o non mostrare back button (e' un tab, non una pushed route)
- **Se workout attivo**: Mantieni dialog "Mettere in pausa?" poi `context.pop()`

#### Task 1.3: Fix "Create Template" navigation
- File: `workout_screen.dart:943`
- **Attuale**: `context.go('/templates')` → abbandona il tab Workout
- **Fix**: `context.push('/templates')` → push stack, back torna al Workout tab

#### Task 1.4: Fix push vs go dalla Home
- File: `start_workout_card.dart:70,108`
- File: `templates_carousel_compact.dart:251`
- **Attuale**: `context.push('/workout')` → push sulla stack
- **Fix**: Navigare al branch index 1 della shell:
  ```dart
  // Importare StatefulNavigationShell dal context
  // oppure usare context.go('/workout') che switcha branch
  ```

---

### FASE 2: WelcomeView Redesign (2-3 ore)

> Prerequisiti: Fase 1 completata.

#### Task 2.1: Creare widget `TodaysWorkoutCard`
- **Nuovo file**: `lib/features/workout/presentation/workout_screen/widgets/todays_workout_card.dart`
- Riutilizza `templateSuggestionProvider` da `lib/features/stress_index/presentation/providers/template_suggestion_provider.dart`
- Design: card con template name + motivazione + bottone "Inizia" diretto
- Gestire stati: loading (shimmer), no suggestion (nascosto), rest day (card alternativa)
- Il callback `onStartTemplate(template)` viene passato dal parent

#### Task 2.2: Creare widget `RecentTemplatesCarousel`
- **Nuovo file**: `lib/features/workout/presentation/workout_screen/widgets/recent_templates_carousel.dart`
- Logica: prendere ultimi 3 template usati (ordinati per `lastUsedAt` o `lastPerformedAt`)
- Provider da usare: `customWorkoutTemplatesProvider` (gia esiste), sorted by recency
- Layout: `SizedBox(height: 120)` con `ListView.builder(scrollDirection: Axis.horizontal)`
- Ogni card: template name + difficulty badge + durata stimata + bottone [▶]
- Ultimo item: "Vedi tutti (N)" che naviga a `/templates`
- Se nessun template: mostrare empty state con CTA "Crea il tuo primo template"

#### Task 2.3: Riscrivere `WelcomeView`
- **File**: `lib/features/workout/presentation/workout_screen/widgets/welcome_view.dart`
- **Rimuovere**: `_buildQuickStartList`, `_buildTemplateList`, `_buildCreateTemplateCard`, `_buildEmptyTemplateState`, `_SwipeHintWrapper`
- **Nuova struttura**:
  ```dart
  WelcomeView(
    onQuickStart,
    onStartTemplate,
  )

  build() → CustomScrollView con SliverList:
    1. QuickStartCard (gia esistente, ingrandito)
    2. TodaysWorkoutCard (nuovo, Task 2.1)
    3. RecentTemplatesCarousel (nuovo, Task 2.2)
    4. TabBarBottomPadding (per non sovrapporre alla nav bar)
  ```
- **Rimuovere callback non piu necessari**: `onShareTemplate`, `onDuplicateTemplate`, `onEditTemplate`, `onDeleteTemplate`, `onCreateTemplate`, `onScheduleTemplate`, `onRefreshTemplate`, `onViewTemplate` — queste azioni restano solo in `/templates`

#### Task 2.4: Aggiornare WorkoutScreen orchestrator
- **File**: `workout_screen.dart`
- Semplificare `_buildWelcomeView()` rimuovendo i callback rimossi
- Aggiungere AppBar minimal alla WelcomeView con titolo "Allenamento"
- Rimuovere metodi non piu necessari: `_editTemplateFromQuickStart`, `_shareTemplatePdf`, `_deleteTemplateFromQuickStart`, `_scheduleTemplate`, `_viewTemplate`, `_refreshTemplate`, `_duplicateTemplate`

---

### FASE 3: PreloadedView Redesign (1-2 ore)

> Prerequisiti: Fase 2 completata (o indipendente se si vuole parallelizzare).

#### Task 3.1: Ridisegnare PreloadedView
- **File**: `lib/features/workout/presentation/workout_screen/widgets/preloaded_view.dart`
- **Attuale**: `ListTile` + `CircleAvatar(child: Text('${i+1}'))` → aspetto prototipo
- **Nuovo design**: Card per ogni esercizio con:
  - Nome esercizio (Text bold)
  - Categoria/muscle group
  - Preview serie (es. "4 × 10 reps" o "4 × 10 @ 80kg" se peso suggerito)
  - Tempo stimato (se disponibile dalla `exerciseTemplate.estimatedDuration`)
  - Immagine thumbnail (se disponibile da exercise database)
- Layout: `ListView.builder` con card `Container` stylate come il resto dell'app
- Mantenere: `ChangeWorkoutBanner` in alto, bottone "Inizia Workout" in basso

---

### FASE 4: Polish e Consistency (1 ora)

> Prerequisiti: Fase 2 e 3 completate.

#### Task 4.1: Stile coerente
- Verificare che WelcomeView, PreloadedView e WorkoutView usino lo stesso design language
- Card style: stessi border radius, padding, shadow del resto dell'app
- Colori: solo `context.colors.*` (no `Colors.*` hardcoded)
- Icone: solo `AppIcons.*`
- Testi: solo `context.l10n.*`

#### Task 4.2: Localizzazione
- Aggiungere chiavi l10n per nuovi testi:
  - `suggestedForToday` → "Suggerito per oggi"
  - `recentlyUsed` → "Ultimi usati"
  - `viewAll` → "Vedi tutti"
  - `viewAllCount` → "Vedi tutti ({count})"
  - `musclesRecovered` → "Muscoli recuperati"
  - `restDaySuggestion` → "Oggi e ideale per il recupero"
  - `noTemplatesYet` → "Non hai ancora template"
  - `createFirstTemplateHint` → "Crea il tuo primo template per iniziare"
- Aggiornare `app_en.arb` e `app_it.arb`
- Eseguire `flutter gen-l10n`

#### Task 4.3: Performance check
- Eseguire `.claude/scripts/performance-check.sh lib/features/workout/presentation/`
- Verificare: no I/O in loop, provider con keepAlive se necessario, select() per rebuild granulari
- Il `templateSuggestionProvider` deve essere gia cached (verificare)

#### Task 4.4: Test
- Verificare che i test esistenti nella feature workout passino ancora
- Widget test per nuova WelcomeView con mock del `templateSuggestionProvider`
- Widget test per `RecentTemplatesCarousel` con 0, 1, 3, 5+ template

---

## 6. File da Creare

| File | Tipo | Descrizione |
|------|------|-------------|
| `lib/features/workout/presentation/workout_screen/widgets/todays_workout_card.dart` | Widget | Card suggerimento AI template |
| `lib/features/workout/presentation/workout_screen/widgets/recent_templates_carousel.dart` | Widget | Carousel orizzontale ultimi template |

## 7. File da Modificare

| File | Tipo Modifica | Note |
|------|---------------|------|
| `workout_screen.dart` | Semplificare | Rimuovere callback template management, fix back nav |
| `welcome_view.dart` | Riscrivere | Nuova struttura: QuickStart + AI + Carousel |
| `preloaded_view.dart` | Ridisegnare | Card premium invece di ListTile |
| `start_workout_card.dart` | Fix nav | `push` → `go` per branch switching |
| `templates_carousel_compact.dart` | Fix nav | Stesso fix navigazione |
| `app_en.arb` | Aggiungere | Nuove chiavi l10n |
| `app_it.arb` | Aggiungere | Nuove chiavi l10n |

## 8. File da NON Toccare

- `lib/features/workout/presentation/workout_screen/widgets/workout_view.dart` — funziona bene
- `lib/features/workout/presentation/workout_screen/controllers/workout_screen_controller.dart` — logica OK
- `lib/features/stress_index/presentation/providers/template_suggestion_provider.dart` — riusare as-is
- `ios/Runner/LiveActivityTimer/` — Swift nativo

## 9. Dipendenze Esistenti da Riutilizzare

| Componente | Path | Uso |
|------------|------|-----|
| `templateSuggestionProvider` | `lib/features/stress_index/presentation/providers/template_suggestion_provider.dart` | Suggerimento AI per TodaysWorkoutCard |
| `customWorkoutTemplatesProvider` | `lib/features/workout/presentation/providers/workout_template_provider.dart` | Lista template per carousel |
| `SwipeableTemplateCard` | `lib/features/workout/presentation/widgets/swipeable_template_card.dart` | Puo essere riutilizzata nel carousel in versione compact |
| `ChangeWorkoutBanner` | `lib/features/workout/presentation/workout_screen/widgets/change_workout_banner.dart` | Mantenere in PreloadedView |
| `ContextGatheringBottomSheet` | `lib/features/workout/presentation/widgets/quick_start/context_gathering_bottom_sheet.dart` | Quick Start flow |

## 10. Criteri di Accettazione

### Must Have (Fase 1-2)
- [ ] Sfondo non piu nero in light mode ✅ (gia fixato)
- [ ] WelcomeView mostra max 3-5 template recenti (non tutti)
- [ ] Suggerimento AI template visibile nella WelcomeView
- [ ] Quick Start CTA resta prominente e funzionante
- [ ] Back navigation non cambia branch (no `goNamed('home')`)
- [ ] "Vedi tutti" naviga a `/templates` correttamente
- [ ] Testi localizzati in IT e EN

### Should Have (Fase 3)
- [ ] PreloadedView con card premium (non ListTile)
- [ ] Preview serie/peso su ogni esercizio nella PreloadedView
- [ ] Stile visivo coerente con il resto dell'app

### Nice to Have (Fase 4)
- [ ] Widget test per nuova WelcomeView
- [ ] Widget test per RecentTemplatesCarousel
- [ ] Performance check passato senza warning

---

## 11. Note per l'Implementazione

### Attenzione al provider pattern
Il `templateSuggestionProvider` restituisce una `List<TemplateStressAnalysis>?` asincrono. Gestire i 3 stati:
- `loading` → shimmer/skeleton
- `error` o `null` → nascondere la card
- `data` → mostrare suggerimento

### Ordinamento template recenti
I template custom (`WorkoutTemplate`) hanno un campo `updatedAt` ma non necessariamente un `lastPerformedAt`. Per determinare "ultimi usati" potrebbe servire una query ai workout passati. Verificare se esiste gia un provider che mappa template → ultimo utilizzo, oppure ordinare per `updatedAt` come approssimazione.

### Test esistenti
Alcuni test pre-esistenti sono gia rotti (vedi MEMORY.md):
- `workout_analytics_repository_impl_test.dart`
- `volume_calculator_test.dart`
- `scientific_metrics_service_test.dart`
- `personal_record_test.dart`

Questi NON sono correlati al redesign. Non romperli ulteriormente, ma non e necessario fixarli.
