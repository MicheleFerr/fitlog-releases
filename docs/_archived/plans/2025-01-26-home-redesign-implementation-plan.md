# Home Redesign - Implementation Plan

**Data**: 2025-01-26
**Design Doc**: [2025-01-26-home-redesign-design.md](./2025-01-26-home-redesign-design.md)
**Complessità**: MEDIUM (refactoring esistente, no nuove feature)
**Stima**: ~8-10 ore
**Breaking Changes**: Sì (ma solo 1 utente = OK)

---

## Task Breakdown

### Fase 1: Preparazione (1h)

#### Task 1.1: Creare branch dedicato
```bash
git checkout -b feat/home-redesign
```
- **File**: N/A
- **Tempo**: 5 min

#### Task 1.2: Backup configurazione widget attuale
- **File**: `lib/features/home/domain/models/home_widget_config.dart`
- **Azione**: Commentare vecchia config, creare nuova minimal
- **Tempo**: 15 min

#### Task 1.3: Aggiornare palette colori tema
- **File**: `lib/shared/presentation/theme/app_theme.dart`
- **Azione**: Aggiungere colori dark premium se non esistono
- **Tempo**: 30 min
- **Colori da aggiungere**:
  ```dart
  static const darkPremiumBackground = Color(0xFF0D0D0D);
  static const darkPremiumSurface = Color(0xFF1A1A1A);
  static const darkPremiumAccent = Color(0xFF6366F1);
  ```

---

### Fase 2: Nuova Home Screen (3h)

#### Task 2.1: Creare `minimal_home_screen.dart`
- **File**: `lib/features/home/presentation/minimal_home_screen.dart`
- **Azione**: Nuovo screen con struttura minimal
- **Tempo**: 1h
- **Contenuto**:
  - Scaffold con sfondo #0D0D0D
  - AppBar minimal (logo + settings)
  - Body con 4 widget
  - Bottom NavigationBar

#### Task 2.2: Creare widget `StartWorkoutCard`
- **File**: `lib/features/home/presentation/widgets/start_workout_card.dart`
- **Azione**: Hero card con gradient + glow
- **Tempo**: 45 min
- **Stati**:
  - Nessun workout attivo → "Start Workout"
  - Workout in corso → "Resume" con stats

#### Task 2.3: Creare widget `TemplatesCarouselCompact`
- **File**: `lib/features/home/presentation/widgets/templates_carousel_compact.dart`
- **Azione**: Carousel orizzontale 3 template recenti
- **Tempo**: 45 min
- **Note**: Riutilizzare `templateProvider`, ordinare per `lastUsed`

#### Task 2.4: Refactor `AIInsightsCard` (collegare a InsightsEngine)
- **File**: `lib/features/home/presentation/widgets/ai_coach_card.dart`
- **Azione**: Collegare a `InsightsEngine` reale invece di dati mock
- **Tempo**: 30 min
- **Provider**: `analyticsProvider` → `InsightsEngine.generateInsights()`

---

### Fase 3: Rename Community → Wiki (30 min)

#### Task 3.1: Rename widget e label
- **File**: `lib/features/home/presentation/widgets/community_pulse_card.dart`
- **Azione**:
  - Rename title "Community Hub" → "Exercise Wiki"
  - Update subtitle/description
- **Tempo**: 15 min

#### Task 3.2: Creare versione compatta
- **File**: `lib/features/home/presentation/widgets/exercise_wiki_card_compact.dart`
- **Azione**: Versione minimal del widget wiki (solo badge + 1 riga)
- **Tempo**: 15 min

---

### Fase 4: Bottom Navigation (1h)

#### Task 4.1: Creare/Aggiornare NavigationBar
- **File**: `lib/shared/presentation/widgets/app_bottom_navigation.dart`
- **Azione**: 4 tab (Home, Analytics, Templates, Profile)
- **Tempo**: 30 min
- **Style**: Dark premium come da design

#### Task 4.2: Aggiornare routing
- **File**: `lib/core/navigation/app_router.dart`
- **Azione**: Verificare che le 4 destinazioni siano corrette
- **Tempo**: 30 min

---

### Fase 5: Animazioni & Micro-interactions (1h)

#### Task 5.1: Creare `TapScaleWrapper` widget
- **File**: `lib/shared/presentation/widgets/tap_scale_wrapper.dart`
- **Azione**: Widget riutilizzabile per tap feedback (scale + opacity)
- **Tempo**: 20 min

#### Task 5.2: Applicare animazioni alle card
- **File**: Vari widget home
- **Azione**: Wrap card con `TapScaleWrapper` + `HapticFeedback`
- **Tempo**: 40 min

---

### Fase 6: Cleanup & Testing (2h)

#### Task 6.1: Rimuovere widget non usati da config
- **File**: `lib/features/home/domain/models/home_widget_config.dart`
- **Azione**: Commentare/rimuovere widget eliminati
- **Tempo**: 15 min

#### Task 6.2: Aggiornare localizzazioni
- **File**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`
- **Azione**: Aggiungere nuove chiavi, rimuovere inutilizzate
- **Tempo**: 30 min
- **Chiavi nuove**:
  - `startWorkout`, `tapToBeginTracking`
  - `emptyWorkout`, `fromTemplate`
  - `exerciseWiki`, `tipsToReview`, `earnPoints`

#### Task 6.3: Test manuale
- **Azione**:
  - [ ] Home si carica correttamente
  - [ ] Start workout funziona (empty + template)
  - [ ] Template carousel mostra 3 recenti
  - [ ] AI Insights mostra dati reali (se presenti)
  - [ ] Exercise Wiki mostra contributi
  - [ ] Bottom nav naviga correttamente
  - [ ] Dark mode funziona
  - [ ] Light mode fallback funziona
- **Tempo**: 45 min

#### Task 6.4: `flutter analyze` + fix
- **Tempo**: 30 min

---

### Fase 7: Commit & PR (30 min)

#### Task 7.1: Commit changes
```bash
git add -A
git commit -m "feat(home): redesign with minimal dark premium style

- Replace customizable home with minimal 4-widget layout
- Add StartWorkoutCard with gradient hero CTA
- Add TemplatesCarouselCompact for quick access
- Connect AI Insights to real InsightsEngine
- Rename Community to Exercise Wiki
- Update bottom navigation to 4 tabs
- Add tap animations and haptic feedback
- Remove unused widgets (stats, streak, goals, quotes)

BREAKING CHANGE: Home layout completely redesigned
(acceptable as only 1 test user)
"
```

#### Task 7.2: Test su device fisico
- **Tempo**: 15 min

---

## Ordine Esecuzione

```
[Fase 1] Preparazione
    ↓
[Fase 2] Nuova Home Screen (può essere parallelizzata)
    ├── Task 2.1 (screen base)
    ├── Task 2.2 (StartWorkoutCard)
    ├── Task 2.3 (TemplatesCarousel)
    └── Task 2.4 (AI Insights)
    ↓
[Fase 3] Rename Community → Wiki
    ↓
[Fase 4] Bottom Navigation
    ↓
[Fase 5] Animazioni
    ↓
[Fase 6] Cleanup & Testing
    ↓
[Fase 7] Commit
```

---

## File Toccati (Summary)

### Nuovi File
- `lib/features/home/presentation/minimal_home_screen.dart`
- `lib/features/home/presentation/widgets/start_workout_card.dart`
- `lib/features/home/presentation/widgets/templates_carousel_compact.dart`
- `lib/features/home/presentation/widgets/exercise_wiki_card_compact.dart`
- `lib/shared/presentation/widgets/tap_scale_wrapper.dart`

### File Modificati
- `lib/features/home/domain/models/home_widget_config.dart`
- `lib/features/home/presentation/widgets/ai_coach_card.dart`
- `lib/features/home/presentation/widgets/community_pulse_card.dart`
- `lib/shared/presentation/theme/app_theme.dart`
- `lib/shared/presentation/widgets/app_bottom_navigation.dart` (se esiste)
- `lib/core/navigation/app_router.dart`
- `assets/i18n/app_en.arb`
- `assets/i18n/app_it.arb`

### File Potenzialmente Rimossi/Deprecati
- `lib/features/home/presentation/customizable_home_screen.dart` (deprecato)
- `lib/features/home/presentation/home_screen_optimized.dart` (deprecato)
- `lib/features/home/presentation/home_screen_performance.dart` (deprecato)

---

## Rischi & Mitigazioni

| Rischio | Mitigazione |
|---------|-------------|
| InsightsEngine non ha dati | Widget nascosto se `insights.isEmpty` |
| Template provider lento | Skeleton loading mentre carica |
| Breaking existing routes | Verificare `app_router.dart` |
| Light mode broken | Testare fallback con `context.colors` |

---

## Checklist Pre-Commit

- [ ] `flutter analyze` passa (0 errori)
- [ ] Nessun testo hardcoded (solo `context.l10n.*`)
- [ ] Nessun colore hardcoded (solo `context.colors.*`)
- [ ] Usa `AppIcons.*` (no `Icons.*` inline)
- [ ] Testato in dark mode
- [ ] Testato in light mode
- [ ] `flutter gen-l10n` eseguito
- [ ] App non crasha all'avvio
