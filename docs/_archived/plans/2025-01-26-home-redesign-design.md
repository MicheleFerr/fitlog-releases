# Home Redesign - Design Document

**Data**: 2025-01-26
**Stato**: Approvato
**Autore**: Claude + Michele (brainstorming session)

---

## Obiettivo

Ridisegnare la home screen di FitLog Pro con focus su:
- **Minimal/Clean** - Meno elementi, più spazio
- **Dark Premium** - Estetica professionale
- **Data Tracking** - Focus esclusivo sul tracciamento dati
- **Usabilità** - Max 3 tap per iniziare workout

---

## Problemi Attuali (da risolvere)

1. **Troppo affollata** - Troppi widget, troppe informazioni
2. **Non abbastanza utile** - Widget che non servono davvero
3. **Design visivo** - Estetica non convincente
4. **Gamification eccessiva** - XP, badge, streak distraggono dal core

---

## Design Finale

### Struttura Home

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  FitLog Pro                                    [⚙️ Settings] │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                                                        │ │
│  │     🏋️                                                 │ │
│  │     START WORKOUT                                      │ │
│  │     Tap to begin tracking                              │ │
│  │                                                        │ │
│  │     [ Empty ]              [ From Template ]           │ │
│  │                                                        │ │
│  └────────────────────────────────────────────────────────┘ │
│       ↑ Hero card con gradient + glow                       │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  📋 Templates                              View all →  │ │
│  │  ┌──────┐ ┌──────┐ ┌──────┐                           │ │
│  │  │Push  │ │Pull  │ │Legs  │  ← Horizontal scroll      │ │
│  │  │Day   │ │Day   │ │Day   │                           │ │
│  │  └──────┘ └──────┘ └──────┘                           │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  🤖 AI Insights                              1 new →   │ │
│  │  📈 Ready to increase squat: try 87.5kg (+2.5kg)      │ │
│  │  Based on last 4 workouts                              │ │
│  └────────────────────────────────────────────────────────┘ │
│       ↑ Solo se ci sono insights (altrimenti nascosto)      │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  📖 Exercise Wiki                          View all →  │ │
│  │  3 tips to review • Earn points                        │ │
│  └────────────────────────────────────────────────────────┘ │
│       ↑ Compatto, espandibile on tap                        │
│                                                              │
│                         (spacer flex)                        │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│    [🏠]           [📊]           [📋]           [👤]        │
│    Home          Analytics      Templates       Profile      │
└──────────────────────────────────────────────────────────────┘
```

### Widget Inclusi (4 totali)

| Widget | Descrizione | Stato Backend |
|--------|-------------|---------------|
| **Start Workout** | Hero CTA per iniziare workout | ✅ `currentWorkoutProvider` |
| **Templates** | Carousel 3 template recenti | ✅ `templateProvider` |
| **AI Insights** | Suggerimenti basati su dati | ✅ `InsightsEngine` |
| **Exercise Wiki** | Contributi da revieware | ✅ `communityProvider` |

### Widget Rimossi

- ❌ Stats Card (XP, livello, achievements)
- ❌ Quick Actions grid
- ❌ Recent Workouts widget
- ❌ Weekly Goals
- ❌ Motivational Quote
- ❌ Streak Tracker
- ❌ Premium Unlock Card
- ❌ Banner Ads (spostati altrove)
- ❌ Greeting/saluto dinamico

### Rename

- "Community Hub" → **"Exercise Wiki"**

---

## Visual Style

### Palette Colori

```
BACKGROUND
├── Primary:    #0D0D0D (quasi nero)
├── Surface:    #1A1A1A (card background)
└── Elevated:   #242424 (modal, sheet)

ACCENT
├── Primary:    #6366F1 (indigo, CTA)
├── Gradient:   #6366F1 → #8B5CF6 (premium)
└── Glow:       #6366F1 @ 20% (subtle glow)

TEXT
├── Primary:    #FFFFFF (titoli)
├── Secondary:  #A1A1AA (descrizioni)
└── Muted:      #52525B (hint, disabled)

SEMANTIC
├── Success:    #22C55E (completato)
├── Warning:    #F59E0B (attenzione)
└── Error:      #EF4444 (errore)
```

### Tipografia

```
Titoli:      SF Pro Display / Bold / 24-32px
Sottotitoli: SF Pro Text / Semibold / 18-20px
Body:        SF Pro Text / Regular / 16px
Caption:     SF Pro Text / Regular / 14px / Secondary color
```

### Card Style

```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.06),
      width: 1,
    ),
  ),
)
```

### CTA Primaria (Start Workout)

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF6366F1).withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  ),
)
```

### Principi Visual

| Elemento | Regola |
|----------|--------|
| Spacing | 16px base, 24px tra sezioni |
| Border radius | 16px (card), 12px (bottoni interni) |
| Shadows | Solo su CTA primaria, molto sottili |
| Icone | Outline style, 24px, colore secondary |
| Animazioni | Fade 200ms, scale 150ms - subtle |

---

## Bottom Navigation

```
┌─────────────────────────────────────────────────────────────┐
│    [🏠]           [📊]           [📋]           [👤]       │
│    Home          Analytics      Templates       Profile     │
└─────────────────────────────────────────────────────────────┘
```

| Tab | Icona | Destinazione |
|-----|-------|--------------|
| Home | `AppIcons.home` | Home Screen (nuovo design) |
| Analytics | `AppIcons.analytics` | Dashboard analytics esistente |
| Templates | `AppIcons.listAlt` | Templates screen esistente |
| Profile | `AppIcons.person` | Profile/Settings |

### Style

```dart
NavigationBar(
  backgroundColor: Color(0xFF0D0D0D),
  indicatorColor: Color(0xFF6366F1).withOpacity(0.15),
  selectedIconColor: Color(0xFF6366F1),
  unselectedIconColor: Color(0xFF52525B),
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  height: 65,
)
```

---

## Interazioni & Animazioni

### Transizioni

| Azione | Animazione | Durata |
|--------|------------|--------|
| Tap card | Scale 0.98 + opacity 0.8 | 100ms |
| Page transition | Fade + slide up | 200ms |
| Widget appear | Fade in + slide from bottom | 300ms (staggered) |
| Bottom nav switch | Fade crossfade | 200ms |

### Micro-interactions

```dart
// Card tap feedback
onTapDown: scale to 0.98, opacity 0.8
onTapUp/Cancel: scale to 1.0, opacity 1.0
duration: 100ms
curve: Curves.easeOut

// Haptic feedback
onTap CTA primaria: HapticFeedback.mediumImpact()
onTap card secondaria: HapticFeedback.lightImpact()
```

---

## Dettaglio Widget

### 1. Start Workout (Hero Card)

**Stato: Nessun workout attivo**
```
┌─────────────────────────────────────────────┐
│                                             │
│     🏋️                                      │
│                                             │
│     Start Workout                           │
│     Tap to begin tracking                   │
│                                             │
│     [ Empty workout ]  [ From template ]    │
│                                             │
└─────────────────────────────────────────────┘
```

**Stato: Workout IN CORSO**
```
┌─────────────────────────────────────────────┐
│  ● LIVE                            01:23:45 │
│                                             │
│  Push Day                                   │
│  4 exercises • 12 sets completed            │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  ▶ RESUME                           │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  [ Finish ]              [ Discard ]        │
└─────────────────────────────────────────────┘
```

### 2. Templates (Quick Access)

```
┌─────────────────────────────────────────────┐
│  📋 Templates                    View all → │
├─────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │ Push    │ │ Pull    │ │ Legs    │       │
│  │ Day     │ │ Day     │ │ Day     │       │
│  │ 6 ex.   │ │ 5 ex.   │ │ 7 ex.   │       │
│  │ ~45min  │ │ ~40min  │ │ ~50min  │       │
│  └─────────┘ └─────────┘ └─────────┘       │
└─────────────────────────────────────────────┘
```

### 3. AI Insights (Contextual)

**Stato: Ci sono insights**
```
┌─────────────────────────────────────────────┐
│  🤖 AI Coach                     1 new →    │
├─────────────────────────────────────────────┤
│  📈 Squat Progression                       │
│  Ready to increase: try 87.5kg (+2.5kg)     │
│  Based on last 4 workouts                   │
└─────────────────────────────────────────────┘
```

**Stato: Nessun insight** → Widget NASCOSTO

### 4. Exercise Wiki (ex-Community)

```
┌─────────────────────────────────────────────┐
│  📖 Exercise Wiki                View all → │
├─────────────────────────────────────────────┤
│  3 tips to review • Earn points             │
└─────────────────────────────────────────────┘
```

---

## Fonti Best Practices

- [Stormotion - 15 Must-Have Fitness App Features](https://stormotion.io/blog/fitness-app-features/)
- [Eastern Peak - Fitness App Design Best Practices](https://easternpeak.com/blog/fitness-app-design-best-practices/)
- [Dataconomy - UX/UI Practices 2025](https://dataconomy.com/2025/11/11/best-ux-ui-practices-for-fitness-apps-retaining-and-re-engaging-users/)
- [Strong vs Hevy Comparison 2025](https://gymgod.app/blog/strong-vs-hevy)
- [Disco - Community Gamification 2025](https://www.disco.co/blog/the-power-of-community-gamification-how-to-gamify-your-community-in-2024)

---

## Note Implementative

1. **AI Insights** - Collegare al vero `InsightsEngine` (attualmente usa dati mock)
2. **Templates recenti** - Creare provider per "ultimi 3 template usati"
3. **Exercise Wiki** - Rename da "Community Hub" a "Exercise Wiki"
4. **Dark theme** - Verificare che tutti i colori funzionino anche in light mode (fallback)
