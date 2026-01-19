# Web Progress Page Enhancements - Design Document

> **Created**: 2025-01-19
> **Status**: Approved
> **Platform**: Web (responsive, works on mobile too)

---

## Overview

5 enhancements to the Progress/Analytics page for better data visualization and user engagement.

---

## Feature 1: e1RM Tracker - Clickable with History

### User Story
As a user, I want to tap on an exercise in the e1RM tracker to see its historical progression and understand how the calculation was made.

### Design Decision
**Combination view**: Line chart on top + chronological list below

### UI Specification

```
┌─────────────────────────────────────────────────────┐
│ e1RM History: Bench Press              [Close X]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 📈 PROGRESSION CHART                        │    │
│ │                                              │    │
│ │  e1RM (kg)                                   │    │
│ │  110│                    ●────●              │    │
│ │     │               ●────●                   │    │
│ │  100│          ●────●                        │    │
│ │     │     ●────●                             │    │
│ │   90│●────●                                  │    │
│ │     └────────────────────────────────────   │    │
│ │      Jan  Feb  Mar  Apr  May  Jun           │    │
│ │                                              │    │
│ │ Current e1RM: 107.5 kg (+19% from start)   │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 📋 CALCULATION HISTORY                      │    │
│ │                                              │    │
│ │ ┌─────────────────────────────────────────┐ │    │
│ │ │ 🏆 Jan 15, 2025 (Latest)                │ │    │
│ │ │ e1RM: 107.5 kg                          │ │    │
│ │ │                                          │ │    │
│ │ │ Based on: 95 kg × 5 reps                │ │    │
│ │ │ Formula: Brzycki (weighted avg)         │ │    │
│ │ │                                          │ │    │
│ │ │ 📊 Calculation breakdown:               │ │    │
│ │ │ • Brzycki:  107.1 kg                    │ │    │
│ │ │ • Epley:    109.3 kg                    │ │    │
│ │ │ • Lombardi: 106.8 kg                    │ │    │
│ │ │ • Average:  107.5 kg ✓                  │ │    │
│ │ │                                          │ │    │
│ │ │ [View Session]                          │ │    │
│ │ └─────────────────────────────────────────┘ │    │
│ │                                              │    │
│ │ ┌─────────────────────────────────────────┐ │    │
│ │ │ Dec 28, 2024                            │ │    │
│ │ │ e1RM: 105.2 kg                          │ │    │
│ │ │ Based on: 92 kg × 5 reps                │ │    │
│ │ │ [View Session]                          │ │    │
│ │ └─────────────────────────────────────────┘ │    │
│ │                                              │    │
│ │ ... (scrollable list)                       │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Persona Impact
| Persona | Impact | Notes |
|---------|--------|-------|
| Marco (Principiante) | ⚠️ | Tooltips explain formulas |
| Chiara (Busy) | 0 | Neutral |
| Luca (Powerlifter) | ⭐⭐⭐ | CRITICAL - wants all data |
| Sofia (Estetica) | ⭐⭐ | Useful for tracking |
| Roberto (Pro) | ⭐ | Nice to have |

### Technical Notes
- Reuse `OneRMCalculator` service for formula breakdown
- Chart: Syncfusion `SfCartesianChart` with line series
- Data source: `ExerciseHistory.sessions` with e1RM calculation per session

---

## Feature 2: Volume Trend - Fullscreen with Zoom

### User Story
As a user, I want to view the volume trend in fullscreen, zoom in/out, and tap on data points to see session details.

### Design Decision
**Tooltip + Preview card**: Shows data + mini session preview, with "View Session" button

### UI Specification

```
┌─────────────────────────────────────────────────────┐
│ Volume Trend                    [Export] [Close X]  │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 📊 INTERACTIVE CHART (Zoomable)             │    │
│ │                                              │    │
│ │  Volume (kg)      [Pinch to zoom]           │    │
│ │  8000│                         ●            │    │
│ │      │                    ●────┤            │    │
│ │  6000│               ●────     │            │    │
│ │      │          ●────          │            │    │
│ │  4000│     ●────               │            │    │
│ │      │●────                    │            │    │
│ │  2000│                         │            │    │
│ │      └─────────────────────────────────────│    │
│ │      W1  W2  W3  W4  W5  W6  W7  W8        │    │
│ │                                              │    │
│ │  [Pan left/right to navigate]               │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 📋 TOOLTIP + SESSION PREVIEW (on tap)       │    │
│ │                                              │    │
│ │ ┌───────────────────────────────────────┐   │    │
│ │ │ 📅 January 12, 2025                   │   │    │
│ │ │ Volume: 7,250 kg (+8% vs prev)        │   │    │
│ │ │                                        │   │    │
│ │ │ Session Preview:                       │   │    │
│ │ │ • Bench Press: 3×8 @ 85kg             │   │    │
│ │ │ • Incline DB: 3×10 @ 32kg             │   │    │
│ │ │ • Cable Fly: 3×12 @ 15kg              │   │    │
│ │ │ + 2 more exercises                     │   │    │
│ │ │                                        │   │    │
│ │ │ [View Full Session →]                  │   │    │
│ │ └───────────────────────────────────────┘   │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ Period: [1M] [3M] [6M] [1Y] [All]                  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Interactions
- **Pinch/scroll**: Zoom in/out on timeline
- **Pan**: Navigate through time
- **Tap point**: Show tooltip with session preview
- **Tap "View Full Session"**: Navigate to workout detail screen

### Persona Impact
| Persona | Impact | Notes |
|---------|--------|-------|
| Marco | 0 | Neutral |
| Chiara | ⭐ | Quick overview |
| Luca | ⭐⭐⭐ | CRITICAL - deep analysis |
| Sofia | ⭐⭐⭐ | CRITICAL - volume tracking |
| Roberto | ⭐⭐ | Useful overview |

### Technical Notes
- Syncfusion `SfCartesianChart` with `ZoomPanBehavior`
- `trackballBehavior` for interactive tooltips
- Session preview: fetch top 3 exercises from session

---

## Feature 3: Volume Export

### User Story
As a user, I want to export my volume data as CSV for spreadsheets and PDF for sharing/printing.

### Design Decision
**CSV + PDF report**

### Export Formats

**CSV Structure:**
```csv
Date,Total Volume (kg),Sets,Exercises,Session Duration
2025-01-15,7250,24,"Bench Press,Incline DB,Cable Fly",68
2025-01-12,6800,22,"Squat,Leg Press,Lunges",72
...
```

**PDF Report:**
- Header with user name + date range
- Summary stats (total volume, avg per session, trend %)
- Volume chart (embedded image)
- Top exercises by volume
- PR achievements in period

### UI Specification
```
┌─────────────────────────────┐
│ Export Volume Data          │
├─────────────────────────────┤
│                             │
│ Period: [Last 30 days ▼]    │
│                             │
│ Format:                     │
│ ○ CSV (Spreadsheet)         │
│ ● PDF Report                │
│                             │
│ Include:                    │
│ ☑ Volume chart              │
│ ☑ Exercise breakdown        │
│ ☑ PR achievements           │
│ ☐ Session details           │
│                             │
│ [Cancel]  [Export]          │
│                             │
└─────────────────────────────┘
```

### Persona Impact
| Persona | Impact | Notes |
|---------|--------|-------|
| Marco | 0 | Won't use |
| Chiara | 0 | Neutral |
| Luca | ⭐⭐⭐ | CRITICAL - data portability |
| Sofia | ⭐ | Nice for sharing |
| Roberto | ⭐⭐ | Business reports |

### Technical Notes
- CSV: Use `csv` package
- PDF: Use `pdf` + `printing` packages
- Web: Download via `html.AnchorElement`
- Mobile: Share via `share_plus`

---

## Feature 4: Exercise Images in PR & e1RM Tracker

### User Story
As a user, I want to see exercise images next to PR and e1RM entries to quickly identify exercises.

### Design Decision
**Avatar circolare 48px** - Modern, compact, industry standard (Strong, Fitbod)

### UI Specification

```
PR Card (Before):
┌─────────────────────────────────────┐
│ 🏆 Bench Press                      │
│ 100 kg × 5 reps = 112.5 kg e1RM    │
│ Today                               │
└─────────────────────────────────────┘

PR Card (After):
┌─────────────────────────────────────┐
│ ┌────┐                              │
│ │ 🖼️ │ 🏆 Bench Press               │
│ │48px│ 100 kg × 5 reps              │
│ └────┘ Today • e1RM: 112.5 kg       │
└─────────────────────────────────────┘

e1RM Tracker Item:
┌─────────────────────────────────────┐
│ ┌────┐                              │
│ │ 🖼️ │ Squat                        │
│ │48px│ e1RM: 140 kg (+5%)           │
│ └────┘ ▲ Trending up                │
└─────────────────────────────────────┘
```

### Image Source
- Primary: Exercise `imageUrl` from Firestore
- Fallback: Muscle group icon (chest, back, legs, etc.)
- Placeholder: Generic dumbbell icon

### Persona Impact
| Persona | Impact | Notes |
|---------|--------|-------|
| Marco | ⭐⭐⭐ | CRITICAL - visual recognition |
| Chiara | ⭐⭐ | Quick visual scan |
| Luca | ⭐ | Nice, already knows exercises |
| Sofia | ⭐⭐ | Visual appeal |
| Roberto | ⭐ | Nice to have |

### Technical Notes
- Use `CachedNetworkImage` with circular clip
- Fallback chain: imageUrl → muscleGroupIcon → defaultIcon
- Size: 48×48 logical pixels (96×96 physical @2x)

---

## Feature 5: PR Recenti Cliccabili

### User Story
As a user, I want to tap on a recent PR to see when it was achieved and optionally view the full session.

### Design Decision
**Bottom sheet (mobile) / Dialog (desktop)** - Responsive, maintains context

### UI Specification

**Mobile (Bottom Sheet):**
```
┌─────────────────────────────────────────────────────┐
│ ═══════════════════ (drag handle)                   │
│                                                     │
│ 🏆 Personal Record Details                          │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌────┐                                              │
│ │ 🖼️ │ Bench Press                                  │
│ │48px│ Weight PR                                    │
│ └────┘                                              │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 🎯 Record Value                              │    │
│ │                                              │    │
│ │ 100 kg × 5 reps                             │    │
│ │ e1RM: 112.5 kg                              │    │
│ │                                              │    │
│ │ Previous best: 95 kg × 5 (Nov 2024)        │    │
│ │ Improvement: +5 kg (+5.3%)                  │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 📅 When                                      │    │
│ │                                              │    │
│ │ January 15, 2025 at 18:42                   │    │
│ │ Session: "Push Day"                         │    │
│ │ Duration: 68 minutes                        │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 📋 Session Summary                           │    │
│ │                                              │    │
│ │ • Bench Press: 4×5 @ 100kg ← PR set         │    │
│ │ • Incline DB Press: 3×10 @ 32kg             │    │
│ │ • Cable Fly: 3×12 @ 15kg                    │    │
│ │ • Tricep Pushdown: 3×12 @ 25kg              │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│ [View Full Session →]                              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Desktop (Dialog):**
```
┌─────────────────────────────────────────────────────┐
│ 🏆 Personal Record Details                 [X]      │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌──────────────────┐  ┌──────────────────────────┐ │
│ │                  │  │ 📅 January 15, 2025      │ │
│ │    [Exercise     │  │ Session: "Push Day"      │ │
│ │     Image]       │  │                          │ │
│ │                  │  │ 🎯 100 kg × 5 reps       │ │
│ │  Bench Press     │  │ e1RM: 112.5 kg           │ │
│ │                  │  │                          │ │
│ │  Weight PR       │  │ Previous: 95 kg (+5.3%)  │ │
│ └──────────────────┘  └──────────────────────────┘ │
│                                                     │
│ ┌─────────────────────────────────────────────┐    │
│ │ 📋 Session Exercises                         │    │
│ │                                              │    │
│ │ • Bench Press: 4×5 @ 100kg ← PR             │    │
│ │ • Incline DB Press: 3×10 @ 32kg             │    │
│ │ • Cable Fly: 3×12 @ 15kg                    │    │
│ │ • Tricep Pushdown: 3×12 @ 25kg              │    │
│ └─────────────────────────────────────────────┘    │
│                                                     │
│              [Cancel]  [View Full Session →]        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Interactions
- **Tap PR card** → Open bottom sheet (mobile) / dialog (desktop)
- **Tap "View Full Session"** → Navigate to workout detail screen
- **Swipe down / click X** → Close

### Persona Impact
| Persona | Impact | Notes |
|---------|--------|-------|
| Marco | ⭐⭐ | Motivating to see progress |
| Chiara | ⭐ | Curious occasionally |
| Luca | ⭐⭐⭐ | CRITICAL - wants full context |
| Sofia | ⭐⭐ | Motivating |
| Roberto | ⭐ | Nice to have |

### Technical Notes
- Use `showModalBottomSheet` on mobile
- Use `showDialog` on desktop (check `kIsWeb` or screen width)
- Breakpoint: 600px (tablet/desktop threshold)

---

## Competitive Alignment

| Feature | Strong | Hevy | FitLog (New) |
|---------|--------|------|--------------|
| e1RM history chart | ✓ | ✓ | ✓ + formula breakdown |
| Volume fullscreen | ✓ | ✓ | ✓ + session preview |
| Export | CSV only | CSV | CSV + PDF |
| Exercise images | 44px circle | 48px square | 48px circle |
| PR detail modal | ✓ | ✓ | ✓ + responsive |

---

## Implementation Priority

1. **Exercise images** (lowest effort, high impact for Marco)
2. **PR cliccabili** (medium effort, enables other features)
3. **e1RM tracker history** (medium effort, reuses existing calculator)
4. **Volume fullscreen + zoom** (medium effort, Syncfusion ready)
5. **Export** (higher effort, new dependency)

---

## Files to Modify/Create

### Modify
- `lib/features/analytics/presentation/widgets/pr_modal.dart` - Add images, make clickable
- `lib/features/analytics/presentation/screens/exercise_detail_screen.dart` - Add e1RM history tab
- `lib/features/analytics/presentation/widgets/charts/volume_bar_chart.dart` - Add fullscreen + zoom

### Create
- `lib/features/analytics/presentation/widgets/e1rm_history_dialog.dart`
- `lib/features/analytics/presentation/widgets/pr_detail_sheet.dart`
- `lib/features/analytics/presentation/widgets/volume_fullscreen_dialog.dart`
- `lib/features/analytics/domain/services/volume_export_service.dart`
- `lib/features/analytics/presentation/widgets/exercise_avatar.dart`

---

## Acceptance Criteria

### Feature 1: e1RM Tracker
- [ ] Tap exercise → opens dialog/sheet
- [ ] Shows line chart with e1RM progression
- [ ] Shows chronological list with calculation breakdown
- [ ] Each entry shows formula used (Brzycki, Epley, etc.)
- [ ] "View Session" button navigates to workout

### Feature 2: Volume Fullscreen
- [ ] Fullscreen button on volume chart
- [ ] Pinch to zoom works
- [ ] Pan to navigate timeline works
- [ ] Tap point shows tooltip with session preview
- [ ] "View Full Session" navigates to workout

### Feature 3: Export
- [ ] Export button visible in fullscreen view
- [ ] CSV export works (downloads/shares file)
- [ ] PDF export works with chart + stats
- [ ] Period selector works

### Feature 4: Exercise Images
- [ ] PR cards show exercise avatar (48px circle)
- [ ] e1RM tracker shows exercise avatar
- [ ] Fallback to muscle group icon works
- [ ] Images load from cache

### Feature 5: PR Cliccabili
- [ ] Tap PR card opens detail view
- [ ] Mobile: bottom sheet
- [ ] Desktop: centered dialog
- [ ] Shows record value, date, previous best
- [ ] Shows session summary
- [ ] "View Full Session" navigates to workout

---

**Document approved**: 2025-01-19
**Ready for implementation**: Yes
