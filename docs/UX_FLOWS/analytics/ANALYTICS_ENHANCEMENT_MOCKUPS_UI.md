# 📊 Analytics Enhancement - Detailed UI Mockups

> **Created**: 2025-01-22
> **Purpose**: Mockups dettagliati per nuove feature Analytics (Bar chart, Progressive Overload tab, Advanced filters)
> **Related**: `ANALYTICS_SYSTEM_OVERVIEW.md`, `MUSCLE_DISTRIBUTION_DOCUMENTATION.md`

---

## 📋 Indice

1. [Tab "Muscle Groups" Enhanced](#tab-muscle-groups-enhanced)
2. [Tab "Progressive Overload" (Nuovo)](#tab-progressive-overload-nuovo)
3. [Advanced Filters Component](#advanced-filters-component)
4. [Body Heatmap Visual](#body-heatmap-visual)
5. [Comparison Mode UI](#comparison-mode-ui)

---

## 1️⃣ Tab "Muscle Groups" Enhanced

### 🎨 Layout Completo

```
┌─────────────────────────────────────────────────────┐
│ 💪 Muscle Groups                        [Filter ⚙️] │ ← AppBar
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ PERIOD SELECTOR (Horizontal Chip Row)       │   │
│ │ [7d] [30d] [3m] [6m] [1y] [All]   ← Active │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ METRIC TOGGLE (Segmented Button)            │   │
│ │ [ Volume kg | % | Sets | Reps ]  ← Active   │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 🎯 RADAR CHART (Existing)                   │   │
│ │                                              │   │
│ │        Schiena                               │   │
│ │          /\                                  │   │
│ │    Petto   Spalle                           │   │
│ │     |  \ /  |                                │   │
│ │ Braccia─ ──Gambe                            │   │
│ │         \/                                   │   │
│ │       Addome                                 │   │
│ │                                              │   │
│ │ Color intensity: darker = more volume       │   │
│ │ Tap segment for details                     │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 📊 BAR CHART COMPARATIVO (NEW)              │   │
│ │                                              │   │
│ │ Total Volume: 15,200 kg (last 30d)          │   │
│ │                                              │   │
│ │ Petto      ████████████████ 4200kg (28%)    │   │
│ │            ↑ +12% vs prev period             │   │
│ │                                              │   │
│ │ Schiena    ██████████████ 3800kg (25%)      │   │
│ │            ↑ +8% vs prev period              │   │
│ │                                              │   │
│ │ Gambe      ████████████ 3200kg (21%)        │   │
│ │            ↓ -2% vs prev period              │   │
│ │                                              │   │
│ │ Spalle     ████████ 2400kg (16%)            │   │
│ │            → 0% vs prev period               │   │
│ │                                              │   │
│ │ Braccia    ████ 1600kg (11%)                │   │
│ │            ↑ +5% vs prev period              │   │
│ │                                              │   │
│ │ Addome     ██ 800kg (5%)                    │   │
│ │            ↑ +3% vs prev period              │   │
│ │                                              │   │
│ │ [Tap bar for detailed breakdown]            │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 📈 PROGRESSION LINE CHART (NEW)             │   │
│ │                                              │   │
│ │ Select muscle group:                         │   │
│ │ [Petto ▼] [Schiena] [Gambe] [Spalle] ...   │   │
│ │                                              │   │
│ │ Petto - 12 Week Progression                 │   │
│ │                                              │   │
│ │  Volume (kg)                                 │   │
│ │  5000│              ●─────●                  │   │
│ │      │         ●───●       │                 │   │
│ │  4000│    ●───●            │                 │   │
│ │      │●──●                 │                 │   │
│ │  3000│                     ●─                │   │
│ │      │                                       │   │
│ │  2000└──────────────────────────────────    │   │
│ │      W1  W3  W5  W7  W9  W11 (12 weeks)    │   │
│ │                                              │   │
│ │ 📊 Stats:                                    │   │
│ │ • Start: 3200kg (W1)                        │   │
│ │ • Current: 4200kg (W12)                     │   │
│ │ • Change: +1000kg (+31%) ✅                 │   │
│ │ • Trend: Positive progression               │   │
│ │                                              │   │
│ │ [Toggle: Volume | Sets | 1RM | Frequency]  │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ ⚖️ BALANCE INDICATORS (NEW)                 │   │
│ │                                              │   │
│ │ Push/Pull Ratio                              │   │
│ │ ┌──────────────────────────────────────┐    │   │
│ │ │ Push: 55% ████████                   │    │   │
│ │ │ Pull: 45% ██████  ⚠️ Squilibrio     │    │   │
│ │ └──────────────────────────────────────┘    │   │
│ │ Ideal: 50/50 | Current: 55/45 (+10% push)   │   │
│ │                                              │   │
│ │ Upper/Lower Split                            │   │
│ │ ┌──────────────────────────────────────┐    │   │
│ │ │ Upper: 62% ██████████                │    │   │
│ │ │ Lower: 38% ██████  ⚠️ Basso         │    │   │
│ │ └──────────────────────────────────────┘    │   │
│ │ Ideal: 60/40 | Current: 62/38 (OK)          │   │
│ │                                              │   │
│ │ Core Engagement                              │   │
│ │ ┌──────────────────────────────────────┐    │   │
│ │ │ Core: 8% ██  ⚠️ Sotto media          │    │   │
│ │ └──────────────────────────────────────┘    │   │
│ │ Target: 12-15% | Current: 8% (-4%)          │   │
│ │                                              │   │
│ │ [View Recommendations]                       │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 🎨 BODY HEATMAP (Optional)                  │   │
│ │                                              │   │
│ │         ○  ← Head                            │   │
│ │        /|\                                   │   │
│ │       / | \                                  │   │
│ │    🔴 🟠 🔴  ← Shoulders/Chest/Back         │   │
│ │       ║ ║                                    │   │
│ │      🟡 🟡  ← Arms                          │   │
│ │        |                                     │   │
│ │       🟢   ← Core (low)                     │   │
│ │       / \                                    │   │
│ │      🟠 🟠  ← Legs                          │   │
│ │                                              │   │
│ │ Legend:                                      │   │
│ │ 🔴 Very High (>30%)                         │   │
│ │ 🟠 High (20-30%)                            │   │
│ │ 🟡 Medium (10-20%)                          │   │
│ │ 🟢 Low (<10%)                               │   │
│ │                                              │   │
│ │ [Tap muscle for details]                    │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 🎯 Interaction Details

**Period Selector**:
- Chips horizontal scrollable
- Active chip: `primary color`, bold
- Inactive: `surfaceContainerHighest`, normal weight
- Tap → HapticFeedback.selectionClick() + reload data

**Metric Toggle**:
- SegmentedButton Material 3
- 4 segments: `Volume kg`, `%`, `Sets`, `Reps`
- Active: filled background
- Tap → Update all charts con animazione smooth (300ms)

**Bar Chart**:
- Each bar: `Container` con `LinearGradient` (light → dark primary color)
- Tap bar → Bottom sheet con:
  - Exercise breakdown (top 5 per muscle group)
  - Week-by-week detail
  - Export data option
- Comparison arrow:
  - Green ↑ se +% vs previous period
  - Red ↓ se -% vs previous period
  - Gray → se 0%

**Line Chart**:
- Dropdown muscle group selector (scrollable chips)
- Active muscle: bold + underline
- Line color: muscle-specific (Petto: red, Schiena: blue, etc.)
- Tap dot → Tooltip con dettagli week (W8: 4200kg, +12% vs W7)
- Animated curve drawing (500ms)

**Balance Indicators**:
- Progress bars orizzontali
- Green: optimal range
- Yellow/Orange: warning (±5-10%)
- Red: critical (>±10%)
- Tap → Modal con spiegazioni + recommendations

**Body Heatmap**:
- SVG anatomical diagram (simplified)
- Color intensity based on volume %
- Tap muscle → Highlight + show stats overlay
- Optional: 3D rotate gesture

---

## 2️⃣ Tab "Progressive Overload" (Nuovo)

### 🎨 Layout Completo

```
┌─────────────────────────────────────────────────────┐
│ 📈 Progressive Overload                 [Filter ⚙️] │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ PERIOD SELECTOR                              │   │
│ │ [4w] [8w] [12w] [6m] [1y]  ← Active: 12w   │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ METRIC SELECTOR (Tab Bar Style)              │   │
│ │ [ Volume | Intensity | Frequency ]  ← Active │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 🎯 POI SCORE SUMMARY (NEW)                  │   │
│ │                                              │   │
│ │ Progressive Overload Index (Last 12 Weeks)   │   │
│ │                                              │   │
│ │ Overall: +12.5% ✅ GOOD PROGRESS            │   │
│ │                                              │   │
│ │ ┌──────────────────────────────────────┐    │   │
│ │ │ Petto      +18% ████████████ ✅ Ottimo│   │   │
│ │ │ Schiena    +12% ████████  ✅ Buono  │    │   │
│ │ │ Gambe      +2%  ██  ⚠️ Lento        │    │   │
│ │ │ Spalle     -5%  ░░  ❌ Plateau      │    │   │
│ │ │ Braccia    +8%  ████  ✅ Buono      │    │   │
│ │ │ Addome     0%   ░░  ⚠️ Statico      │    │   │
│ │ └──────────────────────────────────────┘    │   │
│ │                                              │   │
│ │ Legend:                                      │   │
│ │ ✅ >+10%  Ottimo   (Green bars)             │   │
│ │ ✅ +5-10% Buono    (Light green)            │   │
│ │ ⚠️ 0-5%   Lento    (Yellow)                 │   │
│ │ ⚠️ -5-0%  Statico  (Orange)                 │   │
│ │ ❌ <-5%   Plateau  (Red)                    │   │
│ │                                              │   │
│ │ [Tap muscle for breakdown]                  │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 📉 MULTI-LINE PROGRESSION CHART (NEW)       │   │
│ │                                              │   │
│ │ Volume Progression (12 Weeks)                │   │
│ │                                              │   │
│ │  Volume                                      │   │
│ │  (kg)                                        │   │
│ │  5000│                    ●Petto            │   │
│ │      │               ●───●                   │   │
│ │  4000│          ●───●     ●Schiena          │   │
│ │      │     ●───●      ●───●                 │   │
│ │  3000│●───●      ●───●    ●Gambe            │   │
│ │      │      ●───●──────────●                │   │
│ │  2000│ ●───●───●───●───●  ●Spalle           │   │
│ │      │●───●───●───●───●   ●Braccia          │   │
│ │  1000│──────────●───●     ●Addome           │   │
│ │      │                                       │   │
│ │     0└──────────────────────────────────    │   │
│ │      W1  W3  W5  W7  W9  W11 (12 weeks)    │   │
│ │                                              │   │
│ │ [Toggle lines visibility]                   │   │
│ │ ☑️ Petto  ☑️ Schiena ☑️ Gambe              │   │
│ │ ☑️ Spalle ☑️ Braccia ☑️ Addome             │   │
│ │                                              │   │
│ │ [Pinch to zoom] [Pan to scroll timeline]    │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 🔍 DETAILED BREAKDOWN (Expandable Cards)    │   │
│ │                                              │   │
│ │ ▼ Petto (+18%) ✅                           │   │
│ │ ┌──────────────────────────────────────┐    │   │
│ │ │ Volume:     3200kg → 4200kg (+1000kg)│    │   │
│ │ │ Sets:       45 → 52 (+7 sets)        │    │   │
│ │ │ Avg Weight: 71kg → 81kg (+10kg)      │    │   │
│ │ │ Frequency:  2x/week (consistent)     │    │   │
│ │ │                                       │    │   │
│ │ │ Top exercises:                        │    │   │
│ │ │ 1. Bench Press    +15kg (80→95kg)    │    │   │
│ │ │ 2. Incline DB     +8kg (32→40kg)     │    │   │
│ │ │ 3. Cable Fly      +5kg (15→20kg)     │    │   │
│ │ └──────────────────────────────────────┘    │   │
│ │                                              │   │
│ │ ▶ Schiena (+12%) ✅                         │   │
│ │ ▶ Gambe (+2%) ⚠️                            │   │
│ │ ▶ Spalle (-5%) ❌                           │   │
│ │ ▶ Braccia (+8%) ✅                          │   │
│ │ ▶ Addome (0%) ⚠️                            │   │
│ │                                              │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 💡 AI INSIGHTS & RECOMMENDATIONS (NEW)      │   │
│ │                                              │   │
│ │ 🚨 Action Required:                          │   │
│ │ • Spalle in plateau da 3 settimane          │   │
│ │   → Aggiungi 1 set overhead press           │   │
│ │   → Prova cambio esercizio (DB vs BB)      │   │
│ │                                              │   │
│ │ ⚠️ Attenzione:                               │   │
│ │ • Gambe: progressione lenta (+2%)           │   │
│ │   → Frequenza bassa (1x/week)               │   │
│ │   → Considera split 2x/week                 │   │
│ │                                              │   │
│ │ ✅ Vai così:                                 │   │
│ │ • Petto: progressione ottima (+18%)         │   │
│ │   → Mantieni volume attuale                 │   │
│ │   → Considera deload week prossima          │   │
│ │                                              │   │
│ │ 📊 Pattern rilevati:                         │   │
│ │ • Peak performance: Martedì PM              │   │
│ │ • Volume trends: +12.5% avg (last 12w)     │   │
│ │ • Recovery: 48h optimal per upper body      │   │
│ │                                              │   │
│ │ [View Full Report]                           │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 🎯 Interaction Details

**POI Score Bars**:
- Horizontal progress bars con color coding
- Green: +10% o più (optimal)
- Light green: +5-10% (good)
- Yellow: 0-5% (slow progress)
- Orange: -5-0% (stagnant)
- Red: <-5% (plateau/regression)
- Tap → Expand detailed breakdown card

**Multi-line Chart**:
- 6 colored lines (one per muscle group)
- Tap legend checkbox → Toggle line visibility
- Pinch to zoom timeline
- Pan gesture to scroll weeks
- Tap dot → Tooltip with exact value (W8 Petto: 4200kg)
- Animated line drawing (800ms staggered per muscle)

**Expandable Cards**:
- Accordion-style expansion
- Tap header → Expand/collapse con animazione
- Shows:
  - Volume delta (start → current)
  - Sets delta
  - Avg weight progression
  - Frequency consistency
  - Top 3 exercises contributing to progress

**AI Insights**:
- Color-coded sections:
  - 🚨 Red: Action required (plateau detected)
  - ⚠️ Yellow: Attention needed (slow progress)
  - ✅ Green: Keep going (good progress)
- Pattern recognition:
  - Peak performance times
  - Optimal recovery windows
  - Volume trends
- Tap "View Full Report" → Full-screen modal con dettagli

---

## 3️⃣ Advanced Filters Component

### 🎨 Filter Modal UI

```
┌─────────────────────────────────────────────────────┐
│ ⚙️ Analytics Filters                  [Close X]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 📅 TIME PERIOD                               │   │
│ │                                              │   │
│ │ Quick Select:                                │   │
│ │ [7d] [30d] [3m] [6m] [1y] [All Time]        │   │
│ │                                              │   │
│ │ Custom Range:                                │   │
│ │ ┌──────────────┐  to  ┌──────────────┐      │   │
│ │ │ 2024-10-22   │      │ 2025-01-22   │      │   │
│ │ └──────────────┘      └──────────────┘      │   │
│ │                                              │   │
│ │ ☑️ Compare with Previous Period              │   │
│ │   (2024-07-24 to 2024-10-21)                │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 📊 METRICS                                   │   │
│ │                                              │   │
│ │ Primary Metric:                              │   │
│ │ ● Volume (kg)                                │   │
│ │ ○ Volume (%)                                 │   │
│ │ ○ Sets                                       │   │
│ │ ○ Reps                                       │   │
│ │ ○ Intensity (1RM)                            │   │
│ │ ○ Frequency (workouts/week)                  │   │
│ │                                              │   │
│ │ Secondary Metrics (Multi-select):            │   │
│ │ ☑️ Show trend arrows                         │   │
│ │ ☑️ Show % change                             │   │
│ │ ☐ Show exercise breakdown                    │   │
│ │ ☐ Show PRs                                   │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 💪 MUSCLE GROUPS                             │   │
│ │                                              │   │
│ │ [Select All] [Deselect All]                 │   │
│ │                                              │   │
│ │ ☑️ Petto    (4200kg, 28%)                   │   │
│ │ ☑️ Schiena  (3800kg, 25%)                   │   │
│ │ ☑️ Gambe    (3200kg, 21%)                   │   │
│ │ ☑️ Spalle   (2400kg, 16%)                   │   │
│ │ ☑️ Braccia  (1600kg, 11%)                   │   │
│ │ ☑️ Addome   (800kg, 5%)                     │   │
│ │                                              │   │
│ │ Show only:                                   │   │
│ │ ☐ Push muscles (Petto, Spalle, Triceps)     │   │
│ │ ☐ Pull muscles (Schiena, Biceps)            │   │
│ │ ☐ Legs muscles (Gambe, Glutes)              │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 🎨 VISUALIZATION                             │   │
│ │                                              │   │
│ │ Chart Type:                                  │   │
│ │ ● Combined (Radar + Bar + Line)             │   │
│ │ ○ Radar Chart only                           │   │
│ │ ○ Bar Chart only                             │   │
│ │ ○ Line Chart only                            │   │
│ │                                              │   │
│ │ Display Options:                             │   │
│ │ ☑️ Show labels                               │   │
│ │ ☑️ Show grid lines                           │   │
│ │ ☑️ Animate transitions                       │   │
│ │ ☐ Show exact values                          │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 💾 PRESETS                                   │   │
│ │                                              │   │
│ │ [Save Current as Preset]                     │   │
│ │                                              │   │
│ │ Saved Presets:                               │   │
│ │ • 📅 Last 30 Days - All Muscles - Volume    │   │
│ │ • 📊 12 Week Push/Pull Comparison           │   │
│ │ • 🏋️ Strength Focus (1RM)                   │   │
│ │                                              │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌───────────────────────────────┐                 │
│ │ [Reset to Default] [Apply]    │                 │
│ └───────────────────────────────┘                 │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 🎯 Filter Logic

**Period Selection**:
- Quick chips: 7d, 30d, 3m, 6m, 1y, All Time
- Custom date picker: MaterialDatePicker range selection
- Compare toggle: Automatically calculates previous period of same length
- Example: If 30d selected (2024-12-23 to 2025-01-22), previous = 2024-11-23 to 2024-12-22

**Metric Selection**:
- Radio buttons for primary metric (only one active)
- Checkboxes for secondary options (multi-select)
- Primary metric determines Y-axis of charts
- Secondary metrics shown as annotations/overlays

**Muscle Group Filters**:
- Individual checkboxes per muscle
- Quick filters: Push/Pull/Legs preset combinations
- Show current volume (kg) and percentage next to each muscle
- Deselecting muscle = hide from all charts

**Visualization Options**:
- Chart type toggle: Combined view vs individual charts
- Display toggles affect all charts globally
- Animate transitions: smooth 300ms animation when changing filters

**Presets**:
- Save button → Prompt for name → Store in local storage
- Tap preset → Apply all saved filter settings instantly
- Delete preset → Swipe left gesture

---

## 4️⃣ Body Heatmap Visual

### 🎨 Anatomical Diagram Mockup

```
┌─────────────────────────────────────────────────────┐
│ 🎨 Muscle Volume Heatmap              [3D View 🔄] │
├─────────────────────────────────────────────────────┤
│                                                     │
│              FRONT VIEW                             │
│                                                     │
│              ●  Head                                │
│             /│\                                     │
│            / │ \                                    │
│         🔴 🔴 🔴  Shoulders (2400kg, 16%)          │
│          │  │  │                                    │
│         🟠 🔴 🟠  Chest/Back (8000kg, 53%)         │
│          │  │  │                                    │
│         🟡 │ 🟡  Arms (1600kg, 11%)               │
│            ║                                        │
│           🟢    Core (800kg, 5%)                   │
│           / \                                       │
│          │   │                                      │
│        🟠   🟠  Legs (3200kg, 21%)                 │
│         │   │                                       │
│        🟠   🟠                                      │
│                                                     │
│         BACK VIEW (Tap to flip)                     │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ Color Legend:                                │   │
│ │ 🔴 Very High  (>25% total volume)           │   │
│ │ 🟠 High       (15-25%)                      │   │
│ │ 🟡 Medium     (10-15%)                      │   │
│ │ 🟢 Low        (<10%)                        │   │
│ │ ⚪ Inactive   (0%)                           │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ Selected: Petto 🔴                                  │
│ ┌─────────────────────────────────────────────┐   │
│ │ Volume: 4200kg (28% total)                  │   │
│ │ Sets: 52                                     │   │
│ │ Frequency: 2.5x/week                        │   │
│ │ Top exercise: Bench Press (1600kg)          │   │
│ │                                              │   │
│ │ [View Details] [Compare with Previous]      │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 🎯 Heatmap Features

**Visual Representation**:
- SVG anatomical diagram (simplified human figure)
- Color gradient based on % of total volume
- Tap muscle region → Highlight + show detail card
- Swipe left/right → Rotate to back view

**3D View Option**:
- Tap 3D button → Transition to rotatable 3D model
- Pinch to zoom
- Two-finger rotate gesture
- More detailed muscle breakdown (18 muscle groups vs 6)

**Interaction**:
- Long press → Freeze tooltip
- Double tap → Open full muscle detail screen
- Comparison overlay: Ghost outline of previous period with different color

---

## 5️⃣ Comparison Mode UI

### 🎨 Side-by-Side Comparison

```
┌─────────────────────────────────────────────────────┐
│ ⚖️ Period Comparison                  [Close X]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌───────────────────┐  vs  ┌───────────────────┐  │
│ │ Current Period     │      │ Previous Period   │  │
│ │ 2024-12-23 to      │      │ 2024-11-23 to     │  │
│ │ 2025-01-22 (30d)   │      │ 2024-12-22 (30d)  │  │
│ └───────────────────┘      └───────────────────┘  │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 📊 VOLUME COMPARISON                         │   │
│ │                                              │   │
│ │ Petto                                        │   │
│ │ ████████████████ 4200kg                     │   │
│ │ ██████████████ 3800kg ↑ +10.5%              │   │
│ │                                              │   │
│ │ Schiena                                      │   │
│ │ ██████████████ 3800kg                       │   │
│ │ ████████████ 3200kg ↑ +18.8%                │   │
│ │                                              │   │
│ │ Gambe                                        │   │
│ │ ████████████ 3200kg                         │   │
│ │ ████████████ 3150kg ↑ +1.6%                 │   │
│ │                                              │   │
│ │ Spalle                                       │   │
│ │ ████████ 2400kg                             │   │
│ │ ██████████ 2600kg ↓ -7.7%                   │   │
│ │                                              │   │
│ │ Braccia                                      │   │
│ │ ████ 1600kg                                 │   │
│ │ ████ 1550kg ↑ +3.2%                         │   │
│ │                                              │   │
│ │ Addome                                       │   │
│ │ ██ 800kg                                    │   │
│ │ ██ 850kg ↓ -5.9%                            │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 📈 SUMMARY DELTA                             │   │
│ │                                              │   │
│ │ Total Volume:                                │   │
│ │ 15,200kg vs 14,150kg = +1050kg (+7.4%) ✅   │   │
│ │                                              │   │
│ │ Total Sets:                                  │   │
│ │ 240 sets vs 228 sets = +12 sets (+5.3%) ✅  │   │
│ │                                              │   │
│ │ Workout Frequency:                           │   │
│ │ 18 workouts vs 16 workouts = +2 (+12.5%) ✅ │   │
│ │                                              │   │
│ │ Avg Workout Duration:                        │   │
│ │ 68min vs 72min = -4min (-5.6%)              │   │
│ │                                              │   │
│ │ PRs Set:                                     │   │
│ │ 8 new PRs vs 5 PRs = +3 (+60%) ✅           │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 💡 INSIGHTS                                  │   │
│ │                                              │   │
│ │ ✅ Strong improvements:                      │   │
│ │ • Schiena +18.8% (outstanding)              │   │
│ │ • Overall volume +7.4% (excellent)          │   │
│ │                                              │   │
│ │ ⚠️ Areas of concern:                         │   │
│ │ • Spalle -7.7% (regression detected)        │   │
│ │ • Addome -5.9% (below target)               │   │
│ │                                              │   │
│ │ 🎯 Recommendations:                          │   │
│ │ • Increase shoulder volume +10% next period │   │
│ │ • Add 2 core sets per workout               │   │
│ │ • Maintain chest/back progression           │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ [Export Comparison Report PDF]                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 🎯 Comparison Features

**Visual Comparison**:
- Dual-colored bars (current: primary color, previous: gray)
- Delta percentage with arrow (↑ green, ↓ red)
- Animated bar growth when opening modal

**Summary Delta**:
- Key metrics compared side-by-side
- Overall improvement score (weighted average)
- Color coding: green if improved, red if regressed

**Export**:
- Generate PDF with all comparison charts
- Email/share functionality
- Save to Files app

---

## 🎨 Design Tokens & Colors

### Color Palette

```dart
// Progressive Overload Colors
const excellentProgress = Color(0xFF4CAF50); // Green - >+10%
const goodProgress = Color(0xFF8BC34A);      // Light Green - +5-10%
const slowProgress = Color(0xFFFFC107);      // Yellow - 0-5%
const stagnantProgress = Color(0xFFFF9800);  // Orange - -5-0%
const plateauRegression = Color(0xFFF44336); // Red - <-5%

// Muscle Group Colors (for multi-line chart)
const pettoColor = Color(0xFFE53935);    // Red
const schienaColor = Color(0xFF1E88E5);  // Blue
const gambeColor = Color(0xFF43A047);    // Green
const spalleColor = Color(0xFFFB8C00);   // Orange
const bracciaColor = Color(0xFF8E24AA);  // Purple
const addomeColor = Color(0xFFFFB300);   // Amber

// Heatmap Gradient
const heatmapVeryHigh = Color(0xFFD32F2F); // Dark red
const heatmapHigh = Color(0xFFFF6F00);     // Orange
const heatmapMedium = Color(0xFFFDD835);   // Yellow
const heatmapLow = Color(0xFF66BB6A);      // Green
const heatmapInactive = Color(0xFFE0E0E0); // Gray
```

### Typography

```dart
// Chart Labels
final chartTitleStyle = context.textTheme.titleMedium?.copyWith(
  fontWeight: FontWeight.bold,
);

final chartAxisStyle = context.textTheme.bodySmall?.copyWith(
  color: context.colors.onSurfaceVariant,
);

final chartValueStyle = context.textTheme.labelLarge?.copyWith(
  fontWeight: FontWeight.w600,
);

// POI Score
final poiScoreStyle = context.textTheme.headlineLarge?.copyWith(
  fontWeight: FontWeight.bold,
  color: excellentProgress, // Dynamic based on score
);

// Insights
final insightTitleStyle = context.textTheme.titleSmall?.copyWith(
  fontWeight: FontWeight.w600,
);
```

### Spacing & Layout

```dart
// Consistent spacing
const cardPadding = EdgeInsets.all(16);
const chartHeight = 300.0;
const barHeight = 40.0;
const chipHeight = 32.0;

// Border radius
const cardBorderRadius = BorderRadius.all(Radius.circular(12));
const chipBorderRadius = BorderRadius.all(Radius.circular(16));
```

---

## 📱 Responsive Behavior

### Mobile (< 600px)

- Single column layout
- Charts stack vertically
- Period chips horizontal scroll
- Filters: Full-screen modal

### Tablet (600-900px)

- Two-column layout for comparison mode
- Charts side-by-side when space allows
- Filters: Bottom sheet modal (half-screen)

### Desktop (> 900px)

- Three-column layout
- Persistent filter sidebar (left)
- Charts grid layout (2x2 or 3x1)
- Tooltips on hover (no tap required)

---

## ♿ Accessibility

**Screen Reader Support**:
- All charts: semantic labels for data points
- POI scores: "Petto: plus 18 percent, excellent progress"
- Heatmap: "Petto muscle, very high volume, 28 percent of total"

**Color Blindness**:
- Pattern/texture overlays on bars (not just color)
- Deuteranopia-safe palette (avoid pure red/green)
- Labels always visible (don't rely on color alone)

**Touch Targets**:
- Minimum 48x48 dp for all interactive elements
- Chips: 32dp height but wider touch area (48dp)
- Chart dots: Visual 8dp but touch area 48dp

**Keyboard Navigation**:
- Tab order: Period → Metric → Charts → Filters
- Enter/Space: Activate/select
- Arrow keys: Navigate between chart data points

---

## 🎬 Animations

**Chart Loading**:
```dart
// Staggered bar animation
for (int i = 0; i < bars.length; i++) {
  await Future.delayed(Duration(milliseconds: 50 * i));
  animateBar(bars[i], duration: 300);
}
```

**Line Chart Drawing**:
```dart
// Animated path drawing (paint stroke)
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return CustomPaint(
      painter: LineChartPainter(
        progress: _animationController.value, // 0.0 to 1.0
      ),
    );
  },
)
```

**Filter Apply**:
```dart
// Fade out old data, fade in new
await Future.wait([
  _fadeOutAnimation.forward(),
  _dataUpdateFuture,
]);
await _fadeInAnimation.forward();
```

**POI Score Update**:
```dart
// Number counter animation (0 → target value)
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: poiScore),
  duration: Duration(milliseconds: 1500),
  builder: (context, value, child) {
    return Text('${value.toStringAsFixed(1)}%');
  },
)
```

---

## 📊 Performance Considerations

**Chart Rendering**:
- Use `RepaintBoundary` for each chart widget
- Lazy load data (only fetch visible period)
- Cache chart images when period doesn't change

**Large Datasets**:
- Downsample data for long periods (1y+ → weekly aggregates)
- Implement virtual scrolling for exercise lists
- Paginate detailed breakdowns (show top 10, "load more")

**Animations**:
- Disable animations if >100 data points
- Reduce animation duration on low-end devices
- Option to disable animations in settings

---

## 🧪 Testing Scenarios

1. **Empty State**: No workouts in period
2. **Single Muscle**: Only one muscle group trained
3. **Perfect Balance**: Equal volume across all muscles
4. **Extreme Imbalance**: 90% chest, 10% others
5. **Plateau**: Zero progress for 12 weeks
6. **Rapid Progress**: +50% volume in 4 weeks
7. **Comparison Edge Cases**:
   - Compare 30d vs 1y (different scales)
   - Compare with zero previous data
   - Compare identical periods (0% change)

---

## 📚 Related Documentation

- `ANALYTICS_SYSTEM_OVERVIEW.md` - Sistema completo
- `MUSCLE_DISTRIBUTION_DOCUMENTATION.md` - Radar chart esistente
- `DESIGN_GUIDELINES.md` - Design system tokens
- Technical specs: Vedi `ANALYTICS_TECHNICAL_SPECIFICATIONS.md` (next document)

---

**Next**: Create `ANALYTICS_TECHNICAL_SPECIFICATIONS.md` for POI calculation, balance indicators, and data models.
