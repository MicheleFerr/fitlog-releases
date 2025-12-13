# Simplified Analytics Dashboard Design

**Data:** 2024-12-14
**Status:** Approvato
**Autore:** Claude + Michele

---

## Problema

L'attuale schermata Stats mostra troppi dati sparsi senza una visione chiara di "cosa ho fatto questa settimana". Gli utenti si perdono tra tab, grafici e metriche senza capire il quadro generale.

## Soluzione

Dashboard semplificata con 4 sezioni chiare, basata su ricerca competitor (Hevy, Strong) e best practice UX.

---

## Design Approvato

### Layout Generale

```
┌─────────────────────────────────────────┐
│  SEZIONE 1: Hero Statement              │  ~120dp
├─────────────────────────────────────────┤
│  SEZIONE 2: Stats + Body Heatmap        │  ~260dp
├─────────────────────────────────────────┤
│  SEZIONE 3: Esercizi più allenati       │  ~300dp
├─────────────────────────────────────────┤
│  SEZIONE 4: Attività Recente            │  ~280dp
└─────────────────────────────────────────┘
```

---

## Sezione 1: Hero Statement

**Obiettivo:** Comunicare immediatamente il progresso settimanale.

```
┌─────────────────────────────────────────┐
│                                         │
│     4 workout                           │
│     questa settimana                    │
│                                         │
│     ↑ +2 rispetto alla scorsa           │
│       ━━━━━━━━━━━━━━ 80% goal           │
│                                         │
└─────────────────────────────────────────┘
```

**Specifiche:**
- Numero grande (48-56sp) centrale, bold
- Sottotitolo "questa settimana" in grigio (16sp)
- Delta indicator con freccia colorata:
  - Verde ↑ = migliorato
  - Rosso ↓ = peggiorato
  - Grigio → = uguale
- Progress bar opzionale verso weekly goal
- Tap action: apre dettaglio settimana

---

## Sezione 2: Stats Bar + Body Heatmap

**Obiettivo:** Vista immediata di "cosa ho allenato" + KPI chiave.

```
┌─────────────────────────────────────────┐
│  📊 12.4k    🔥 5 days    🏆 2 PR       │  ← Stats orizzontali
├─────────────────────────────────────────┤
│                                         │
│      ╭───╮              ╭───╮           │
│      │ ● │              │ ○ │           │
│     ╭┴───┴╮            ╭┴───┴╮          │
│     │█   █│            │ ███ │          │  ← Body FRONT + BACK
│     │ ███ │            │█   █│          │
│     ╰┬───┬╯            ╰┬───┬╯          │
│      │   │              │   │           │
│      FRONT              BACK            │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 👆 Tap per analisi dettagliata  │   │  ← CTA (PRO gate)
│  │    ⭐ PRO                        │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**Stats Bar (3 KPI):**

| Stat | Icona | Esempio |
|------|-------|---------|
| Volume | 📊 | 12.4k kg |
| Streak | 🔥 | 5 giorni |
| PR | 🏆 | 2 questa sett |

**Body Heatmap:**
- Riutilizza `AnatomicalBodyHeatmap` esistente
- Vista FRONT + BACK affiancate
- Tap → se Premium: `MuscleBalanceTab`, else: Premium modal

---

## Sezione 3: Esercizi più allenati

**Obiettivo:** Mostrare esercizi con contesto di progressive overload.

```
┌─────────────────────────────────────────┐
│  💪 I tuoi esercizi            7gg ▼   │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🏋️ Bench Press                 │   │
│  │ 4 sessioni • Ultimo: 80kg x 8  │   │
│  │ ↑ +2.5kg vs settimana scorsa   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🦵 Squat                        │   │
│  │ 3 sessioni • Ultimo: 100kg x 5 │   │
│  │ → stesso peso                   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 💪 Barbell Row                  │   │
│  │ 2 sessioni • Ultimo: 60kg x 10 │   │
│  │ 🏆 PR questa settimana!         │   │
│  └─────────────────────────────────┘   │
│                                         │
│        Vedi tutti (12) →               │
└─────────────────────────────────────────┘
```

**Specifiche:**
- Card height: ~70dp
- Max visibili: 3-4 (poi "Vedi tutti")
- Trend indicators:
  - 🟢 ↑ = peso aumentato
  - 🔴 ↓ = peso diminuito
  - ⚪ → = stesso peso
  - 🏆 = nuovo PR
- Tap: naviga a ExerciseDetailScreen

---

## Sezione 4: Attività Recente

**Obiettivo:** Quick access agli ultimi workout.

```
┌─────────────────────────────────────────┐
│  📅 Questa settimana           Filtra ▼ │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🟢 OGGI                         │   │
│  │ 🏋️ Push Day           45 min   │   │
│  │ Petto • Spalle • Tricipiti     │   │
│  │ 📊 8 esercizi  ⚖️ 12.4k kg     │   │
│  │ 🏆 2 PR                         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ ⚪ IERI                         │   │
│  │ 🦵 Leg Day             52 min   │   │
│  │ Quadricipiti • Glutei • Polpacci│   │
│  │ 📊 6 esercizi  ⚖️ 18.2k kg     │   │
│  └─────────────────────────────────┘   │
│                                         │
│        Vedi cronologia completa →       │
└─────────────────────────────────────────┘
```

**Specifiche:**
- Status dot: 🟢 oggi, ⚪ passato
- Timestamp: Bold, CAPS, relativo
- Muscle tags come chip o testo con •
- PR badge solo se presenti
- Tap: apre WorkoutDetailModal
- Long press: menu contestuale

---

## Componenti da Riutilizzare

| Componente Esistente | Dove Usarlo |
|---------------------|-------------|
| `AnatomicalBodyHeatmap` | Sezione 2 (compact mode) |
| `MuscleBalanceTab` | Destinazione tap heatmap (premium) |
| `WorkoutDetailModal` | Tap su workout card |
| `ExerciseDetailScreen` | Tap su exercise card |

---

## Implementazione

### Feature Flag per Rollback

```dart
// In AppConfig o FeatureFlags
static const bool useNewAnalyticsDashboard = true;

// In analytics_screen.dart
if (FeatureFlags.useNewAnalyticsDashboard) {
  return SimplifiedAnalyticsDashboard();
} else {
  return TabbedAnalyticsScreen(); // vecchia implementazione
}
```

### File da Creare

1. `lib/features/analytics/presentation/screens/simplified_analytics_dashboard.dart`
2. `lib/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart`
3. `lib/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart`
4. `lib/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart`
5. `lib/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart`

### File da Modificare

1. `lib/features/analytics/presentation/widgets/anatomical_body_heatmap.dart` - aggiungere `compact` mode
2. `lib/core/navigation/app_router.dart` - routing condizionale

---

## Research Sources

- [Hevy Gym Performance Features](https://www.hevyapp.com/features/gym-performance/)
- [Activity Feed Design - GetStream](https://getstream.io/blog/activity-feed-design/)
- [Dashboard UX Patterns - Pencil & Paper](https://www.pencilandpaper.io/articles/ux-pattern-analysis-data-dashboards)
- [Best Workout Tracker App Reddit](https://setgraph.app/ai-blog/best-workout-tracker-app-reddit)
- [Fitness App UI Design - Stormotion](https://stormotion.io/blog/fitness-app-ux/)
