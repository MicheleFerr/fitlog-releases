# Profile Hub Redesign - Modern Apple Fitness+ Style

**Generated**: 2025-11-26
**Style Reference**: Apple Fitness+ (minimal, focus metriche, animazioni sottili)
**Complexity**: MEDIUM
**Estimated Time**: ~6-8h

---

## Overview

Redesign completo della schermata Profile Hub per modernizzare l'aspetto dell'app, passando da un layout "datato" a uno stile Apple Fitness+ con focus su metriche, gamification e UX fluida.

### Goals
- Design moderno e minimale stile Apple Fitness+
- Gamification con avatar sbloccabili
- Metriche visibili con ring cards interattive
- Quick actions compatte e M3-compliant
- Workout feed con preview esercizi

---

## Design Specification

### 1. Header Compatto

**Layout**: Orizzontale (avatar sinistra, info destra)

```
┌─────────────────────────────────────────────────────────┐
│                                           ⚙️  ✏️       │
│   ┌──────┐    Michele                                   │
│   │ 🏆   │    🔥 12 giorni streak                       │
│   │ tier │    💪 47 workout totali                      │
│   └──────┘    [████░░░░] Bronzo → Oro                   │
└─────────────────────────────────────────────────────────┘
```

**Specifiche**:
| Proprietà | Valore |
|-----------|--------|
| Avatar size | 56x56 |
| Avatar style | Icona predefinita con bordo gradiente tier |
| Nome font | `headlineSmall`, bold |
| Stats font | `bodyMedium` |
| Icons (settings, edit) | 24px, `onSurfaceVariant` |
| Streak icon | 🔥 arancione (color psychology: energia) |
| Tier progress | LinearProgressIndicator, 4px height |

**Avatar Sbloccabili**:
- Collegati al sistema achievements esistente
- ~8-10 icone diverse (medaglie, trofei, animali atletici)
- Tier: Grigio → Bronzo → Argento → Oro → Platino
- Bordo gradiente indica tier corrente

**Best Practice Sources**:
- [Dataconomy](https://dataconomy.com/2025/11/11/best-ux-ui-practices-for-fitness-apps-retaining-and-re-engaging-users/)
- [ZFort](https://www.zfort.com/blog/How-to-Design-a-Fitness-App-UX-UI-Best-Practices-for-Engagement-and-Retention)

---

### 2. Ring Cards (Metriche)

**Layout**: 3 anelli circolari in riga

```
┌─────────┐   ┌─────────┐   ┌─────────┐
│  ╭───╮  │   │  ╭───╮  │   │  ╭───╮  │
│  │4/5│  │   │  │3/4│  │   │  │75%│  │
│  ╰───╯  │   │  ╰───╯  │   │  ╰───╯  │
│ Streak  │   │Workout  │   │ Volume  │
│ Weeks   │   │ Week    │   │  Goal   │
└─────────┘   └─────────┘   └─────────┘
```

**Metriche**:
| Ring | Descrizione | Colore | Logica |
|------|-------------|--------|--------|
| Streak Weeks | Settimane consecutive con obiettivo raggiunto | Verde | N settimane / obiettivo |
| Workout Week | Workout questa settimana | Blu | N / obiettivo settimanale |
| Volume Goal | Tonnellaggio vs target | Arancione | % volume mensile |

**Interazione (Tap on Ring)**:
1. Tap ring → Apre bottom sheet con dettagli
2. "Modifica Obiettivo" button nel sheet
3. Slider/stepper per modificare (es. workout/settimana: 1-7, default 2)

**Specifiche**:
| Proprietà | Valore |
|-----------|--------|
| Ring size | 80px diameter |
| Stroke width | 8px |
| Card height | ~120px |
| Gap between | 12px |
| Animation | Fill animation on load (0.8s) |
| Glow effect | Su ring 100% completato |

**Default obiettivo settimanale**: 2 workout/settimana (se non impostato)

**Best Practice Sources**:
- [Apple Support - Activity Rings](https://support.apple.com/guide/watch/adjust-your-activity-ring-goals-apd29b30023c/watchos)
- [Stormotion](https://stormotion.io/blog/fitness-app-ux/)

---

### 3. Quick Actions (Chips)

**Layout**: 4 chips orizzontali, tutte visibili

```
┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐
│ 📊 Stats   │ │ 📅 Storia  │ │ 📏 Misure  │ │ 🗓 Calendario│
└────────────┘ └────────────┘ └────────────┘ └────────────┘
```

**Azioni**:
1. **Stats** → `AppRoutes.analyticsName`
2. **Storia** → `AppRoutes.workoutHistoryName`
3. **Misure** → `AppRoutes.bodyMeasurementsName`
4. **Calendario** → `AppRoutes.streakCalendarName`

**Specifiche M3-Compliant**:
| Proprietà | Valore |
|-----------|--------|
| Altezza visiva | 32px |
| Touch target | 48px (padding automatico) |
| Icon size | 18px, leading |
| Font | `labelLarge` (14px) |
| Spacing | 8px gap |
| Color idle | `surfaceContainerHigh` + border `outlineVariant` |
| Color pressed | `primaryContainer` |
| Border radius | 8px |
| Layout | `Wrap` con `spacing: 8` |

**Animazione**: Scale 0.95 al tap + HapticFeedback.lightImpact()

**Best Practice Sources**:
- [Material 3 Chips Guidelines](https://m3.material.io/components/chips/guidelines)
- [Mobbin](https://mobbin.com/glossary/chip)
- [UX Stack Exchange](https://ux.stackexchange.com/questions/1795/when-to-use-icons-vs-icons-with-text-vs-just-text-links)

---

### 4. Recent Workouts Feed

**Layout**: Cards moderne con exercise preview

```
┌───────────────────────────────────────────────────────┐
│                                                       │
│  🏋️ Push Day                              45 min    │
│  📅 Oggi, 14:30                                       │
│                                                       │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                 │
│  │Bench    │ │Shoulder │ │Triceps  │    +2 altri ↗   │
│  └─────────┘ └─────────┘ └─────────┘                 │
│                                                       │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  💪        │
│                                                       │
└───────────────────────────────────────────────────────┘
```

**Elementi Card**:
| Elemento | Descrizione |
|----------|-------------|
| Workout emoji | 🏋️ Push, 🦵 Leg, 🔙 Pull, etc. |
| Nome workout | `titleMedium`, bold |
| Durata | `titleMedium`, bold, allineata a destra |
| Data relativa | "Oggi", "Ieri", "2 giorni fa" |
| Exercise chips | Max 3 visibili, nome abbreviato (8 char max) |
| "+N altri" | Se >3 esercizi, con freccia |
| Progress bar | Linea orizzontale, indica intensità |
| Badge intensità | 💪 normale, 🔥 intenso, ⚡ PR |

**Exercise Chip Specs**:
| Proprietà | Valore |
|-----------|--------|
| Height | 24px |
| Font | `labelSmall` |
| Color | `surfaceContainerLow` + border sottile |
| Max width | Ellipsis su nomi lunghi |

**Interazione**:
- Tap anywhere on card → Navigate to workout detail
- Detail mostra lista completa esercizi con set/rep/peso

**Animazione**:
- Fade-in staggered (0.1s delay tra cards)

**Best Practice Sources**:
- [Halo Lab - Card UI Design](https://www.halo-lab.com/blog/card-ui-design)
- [DesignRush - Fitness App Design](https://www.designrush.com/best-designs/apps/trends/fitness-app-design-examples)

---

## Implementation Checklist

### Phase 1: Header Refactor
- [ ] Creare `_CompactProfileHeader` widget
- [ ] Layout orizzontale (Row) con avatar e info
- [ ] Rimuovere email, aggiungere streak inline
- [ ] Implementare tier progress indicator
- [ ] Spostare icone azioni in alto a destra

### Phase 2: Avatar System
- [ ] Creare `AvatarIcon` enum con ~10 icone
- [ ] Collegare al sistema achievements esistente
- [ ] Implementare tier border gradient
- [ ] Creare `ProfileAvatarWidget`

### Phase 3: Ring Cards
- [ ] Creare `MetricRingCard` widget
- [ ] Implementare `CircularProgressIndicator` custom
- [ ] Creare provider per obiettivi (workout/week, volume)
- [ ] Implementare bottom sheet per modifica obiettivo
- [ ] Animazione fill on load

### Phase 4: Quick Actions
- [ ] Sostituire `_QuickActionsGrid` con `_QuickActionsChips`
- [ ] Implementare M3 `ActionChip` style
- [ ] Layout `Wrap` con spacing 8px
- [ ] HapticFeedback su tap

### Phase 5: Workout Feed
- [ ] Creare `_ModernWorkoutCard` widget
- [ ] Implementare exercise preview chips
- [ ] Data relativa con `timeago` o custom logic
- [ ] Badge intensità logic
- [ ] Staggered fade-in animation

### Phase 6: Testing & Polish
- [ ] Test dark/light mode
- [ ] Test accessibility (screen reader labels)
- [ ] Test su diversi screen sizes
- [ ] Performance check (rebuild optimization)

---

## File Changes

| File | Azione |
|------|--------|
| `profile_hub_screen.dart` | Refactor completo |
| `profile_avatar_widget.dart` | Nuovo |
| `metric_ring_card.dart` | Nuovo |
| `quick_action_chips.dart` | Nuovo |
| `modern_workout_card.dart` | Nuovo |
| `user_goals_provider.dart` | Nuovo (obiettivi settimanali) |
| `app_en.arb` / `app_it.arb` | Nuove chiavi localizzazione |

---

## Localization Keys Needed

```json
{
  "streakWeeks": "Streak Weeks",
  "workoutWeek": "Workout Week",
  "volumeGoal": "Volume Goal",
  "stats": "Stats",
  "history": "Storia",
  "measurements": "Misure",
  "calendar": "Calendario",
  "todayAt": "Oggi, {time}",
  "yesterdayAt": "Ieri, {time}",
  "daysAgo": "{days} giorni fa",
  "andNMore": "+{count} altri",
  "modifyGoal": "Modifica Obiettivo",
  "workoutsPerWeek": "Workout a settimana",
  "weeklyVolumeTarget": "Volume settimanale target"
}
```

---

## Design Validation Sources

- [Dataconomy - Best UX/UI Practices 2025](https://dataconomy.com/2025/11/11/best-ux-ui-practices-for-fitness-apps-retaining-and-re-engaging-users/)
- [Stormotion - Fitness App UX](https://stormotion.io/blog/fitness-app-ux/)
- [ZFort - Fitness App Best Practices](https://www.zfort.com/blog/How-to-Design-a-Fitness-App-UX-UI-Best-Practices-for-Engagement-and-Retention)
- [Material 3 Chips](https://m3.material.io/components/chips/guidelines)
- [Apple Support - Activity Rings](https://support.apple.com/guide/watch/adjust-your-activity-ring-goals-apd29b30023c/watchos)
- [Halo Lab - Card UI Design](https://www.halo-lab.com/blog/card-ui-design)
- [DesignRush - Fitness App Examples](https://www.designrush.com/best-designs/apps/trends/fitness-app-design-examples)
