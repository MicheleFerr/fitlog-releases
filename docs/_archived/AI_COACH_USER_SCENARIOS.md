# 🏋️‍♂️ AI Coach Feature Gating - User Scenarios & Use Cases

**Document Version**: 1.0
**Created**: 2025-01-16
**Audience**: Product Managers, UX Designers, Business Analysts, Fitness Domain Experts
**Purpose**: Comprehensive user scenarios for AI Coach progressive feature unlock system

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [User Personas](#user-personas)
3. [Feature Unlock Progression](#feature-unlock-progression)
4. [Detailed Use Cases](#detailed-use-cases)
5. [User Journeys](#user-journeys)
6. [Edge Cases](#edge-cases)
7. [UI/UX Considerations](#uiux-considerations)
8. [Success Metrics](#success-metrics)

---

## Overview

### What Is This?

AI Coach Feature Gating è un sistema di **progressive unlock** che sblocca funzionalità AI Coach in base a:
- **Esperienza utente** (Beginner → Intermediate → Advanced)
- **Workout completati** (0, 3, 5, 10, 20+)
- **Giorni dall'iscrizione** (per features future)
- **Preferenze utente** (on/off toggle opzionali)

### Why Progressive Unlock?

**Problema**: Mostrare 8 features AI complesse a un beginner il primo giorno = **cognitive overload** + confusione

**Soluzione**: Sbloccare gradualmente features man mano che l'utente:
1. ✅ Dimostra impegno (workout completati)
2. ✅ Guadagna esperienza (skill level up)
3. ✅ Capisce le basi (onboarding completato)

**Benefici**:
- 📈 **Retention**: Unlock = micro-achievement = dopamina = engagement
- 🎓 **Learning curve**: Utente impara features semplici prima di quelle complesse
- 🎯 **Personalization**: Features rilevanti per livello utente
- 🚀 **Activation**: First-time user experience non sopraffacente

---

## User Personas

### 👤 Persona 1: Marco - "Il Principiante Motivato"

**Background**:
- 28 anni, sedentario da 2 anni
- Obiettivo: perdere 10kg, tonificare
- Esperienza palestra: ZERO
- Tech-savvy: Medio (usa app fitness)

**Caratteristiche**:
- ✅ Motivato ma facilmente scoraggiato
- ❌ Non sa cosa sia "progressive overload"
- ❌ Si confonde con troppi numeri/grafici
- ✅ Apprezza feedback positivo immediato

**Needs**:
- Onboarding semplice, passo-passo
- Suggerimenti chiari ("Fai 3 serie da 10 ripetizioni")
- Celebrate small wins (badge, streak)
- NO advanced analytics (lo spaventerebbero)

---

### 👤 Persona 2: Sofia - "L'Intermedia Costante"

**Background**:
- 32 anni, si allena 3x/settimana da 6 mesi
- Obiettivo: aumentare massa muscolare
- Esperienza palestra: 6 mesi
- Tech-savvy: Alto (ama tracciare tutto)

**Caratteristiche**:
- ✅ Vuole vedere progressi (grafici)
- ✅ Capisce concetti come "volume settimanale"
- ✅ Usa app per tracking (MyFitnessPal, Strava)
- ❌ Non ha ancora coach personale

**Needs**:
- Analytics dettagliate (volume, intensità)
- Suggerimenti workout personalizzati
- Recovery insights (sovrallenamento?)
- Compare progress over time

---

### 👤 Persona 3: Luca - "L'Avanzato Esperto"

**Background**:
- 40 anni, si allena 5x/settimana da 5 anni
- Obiettivo: ottimizzare performance, evitare plateau
- Esperienza palestra: 5+ anni
- Tech-savvy: Medio (preferisce simplicità)

**Caratteristiche**:
- ✅ Conosce anatomia, biomeccanica
- ✅ Ha provato periodization, deload weeks
- ✅ Vuole AI coach per fine-tuning
- ❌ Non vuole feature "giocattolo" (no badge inutili)

**Needs**:
- Form corrections (tecnica esecuzione)
- Advanced periodization suggestions
- Injury prevention insights
- Minimal UI clutter (solo info rilevanti)

---

## Feature Unlock Progression

### 📊 Progression Table

| Feature | Beginner (0 workout) | Beginner (3+ workout) | Intermediate (5+ workout) | Intermediate (10+ workout) | Advanced (20+ workout) |
|---------|---------------------|----------------------|--------------------------|---------------------------|----------------------|
| **Insights** | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled |
| **Notifications** | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled |
| **Achievements** | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled |
| **Streak Tracking** | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled | ✅ Enabled |
| **Workout Suggestions** | ❌ Locked | ✅ **UNLOCKED** | ✅ Enabled | ✅ Enabled | ✅ Enabled |
| **Advanced Analytics** | ❌ Locked | ❌ Locked | ✅ **UNLOCKED** | ✅ Enabled | ✅ Enabled |
| **Recovery Insights** | ❌ Locked | ❌ Locked | ❌ Locked | ✅ **UNLOCKED** | ✅ Enabled |
| **Form Corrections** | ❌ Disabled | ❌ Disabled | ❌ Disabled | ❌ Disabled | ❌ Disabled* |

*Form Corrections globally disabled (future feature, requires camera/AI)

### 🎯 Unlock Milestones

**Milestone 1: First Workout** (Day 1)
- Trigger: Complete first workout
- Unlock: None (already have 4 core features)
- Message: "Ottimo inizio! Completa 2 allenamenti in più per sbloccare Suggerimenti Personalizzati!"

**Milestone 2: Third Workout** (Week 1-2)
- Trigger: Complete 3rd workout
- Unlock: **Workout Suggestions** ✨
- Message: "🎉 Nuovo sblocco! Ora puoi ricevere suggerimenti personalizzati per i prossimi allenamenti!"

**Milestone 3: Intermediate Level + 5 Workouts** (Month 1-2)
- Trigger: User sets experience to Intermediate + 5 workouts completed
- Unlock: **Advanced Analytics** ✨
- Message: "🎉 Analytics Avanzate sbloccate! Scopri grafici dettagliati dei tuoi progressi!"

**Milestone 4: Intermediate Level + 10 Workouts** (Month 2-3)
- Trigger: User at Intermediate + 10 workouts completed
- Unlock: **Recovery Insights** ✨
- Message: "🎉 Recovery Insights disponibili! L'AI Coach ti aiuterà a evitare sovrallenamento!"

---

## Detailed Use Cases

### Use Case 1: Marco's First Day (Day 1, Workout #0)

**Context**: Marco apre l'app per la prima volta dopo onboarding

**Feature Gate Evaluation**:
```
User Context:
- experienceLevel: BEGINNER
- workoutCount: 0
- daysSinceRegistration: 1

Feature Evaluation:
✅ Insights: Enabled (default enabled, no rules)
✅ Notifications: Enabled (default enabled, no rules)
✅ Achievements: Enabled (always enabled)
✅ Streak Tracking: Enabled (always enabled)
❌ Workout Suggestions: LOCKED (need 3+ workouts)
❌ Advanced Analytics: LOCKED (need Intermediate + 5 workouts)
❌ Recovery Insights: LOCKED (need Intermediate + 10 workouts)
❌ Form Corrections: DISABLED (globally disabled)
```

**UI Shown**:

**AI Coach Dashboard**:
```
┌─────────────────────────────────────┐
│ 🤖 AI Coach                         │
├─────────────────────────────────────┤
│ ✅ Consigli Durante Allenamento     │
│    Ricevi suggerimenti real-time    │
│                                     │
│ ✅ Notifiche Intelligenti          │
│    Reminder ottimizzati per te      │
│                                     │
│ ✅ Traguardi & Badge                │
│    Celebra ogni vittoria            │
│                                     │
│ ✅ Traccia Streak                   │
│    Mantieni la costanza             │
│                                     │
│ 🔒 Suggerimenti Allenamento         │
│    📊 Completa 3 workout per        │
│       sbloccare questa feature      │
│                                     │
│ 🔒 Analytics Avanzate               │
│    📈 Passa a Intermediate + 5      │
│       workout per sbloccare         │
│                                     │
│ 🔒 Recovery Insights                │
│    💪 Passa a Intermediate + 10     │
│       workout per sbloccare         │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "Ok, 4 features sono gestibili"
- ✅ "Vedo cosa devo fare per sbloccare le altre (gamification)"
- ✅ "Non sono sopraffatto da troppe opzioni"

---

### Use Case 2: Marco After 3rd Workout (Week 2, Workout #3)

**Context**: Marco completa il 3° workout, app mostra celebration screen

**Feature Gate Re-Evaluation**:
```
User Context:
- experienceLevel: BEGINNER
- workoutCount: 3  ← CHANGED
- daysSinceRegistration: 14

Feature Evaluation:
✅ Workout Suggestions: NOW ENABLED! (rule passed: minWorkoutCount >= 3)
```

**UI Shown**:

**Unlock Celebration Modal**:
```
┌─────────────────────────────────────┐
│          🎉 NUOVO SBLOCCO!          │
├─────────────────────────────────────┤
│                                     │
│    🎯 Suggerimenti Allenamento      │
│                                     │
│  Hai completato 3 allenamenti!      │
│  L'AI Coach ora può suggerirti      │
│  workout personalizzati in base     │
│  ai tuoi progressi.                 │
│                                     │
│  Prova ora:                         │
│  - "Cosa dovrei allenare oggi?"     │
│  - "Suggerisci workout per gambe"   │
│                                     │
│     [Scopri Suggerimenti]           │
│     [Dopo]                          │
└─────────────────────────────────────┘
```

**AI Coach Dashboard (Updated)**:
```
┌─────────────────────────────────────┐
│ 🤖 AI Coach                         │
├─────────────────────────────────────┤
│ ... (4 core features) ...           │
│                                     │
│ ✅ Suggerimenti Allenamento  🆕     │
│    Workout personalizzati AI        │
│    [Prova ora]                      │
│                                     │
│ 🔒 Analytics Avanzate               │
│    📈 2/2 regole mancanti:          │
│    • Passa a Intermediate           │
│    • Completa 5 workout (3/5 ✅)    │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "Wow, ho sbloccato qualcosa! Dopamina +10"
- ✅ "Voglio provare i suggerimenti personalizzati"
- ✅ "Vedo che mancano 2 workout per la prossima unlock (progress bar mentale)"

---

### Use Case 3: Sofia Upgrades to Intermediate (Month 2, Workout #5)

**Context**: Sofia aggiorna profilo da Beginner → Intermediate dopo 5 workout

**Feature Gate Re-Evaluation**:
```
User Context:
- experienceLevel: INTERMEDIATE  ← CHANGED
- workoutCount: 5
- daysSinceRegistration: 45

Feature Evaluation:
✅ Advanced Analytics: NOW ENABLED! (both rules passed)
   - minExperienceLevel: intermediate ✅
   - minWorkoutCount: 5 ✅
```

**UI Shown**:

**Double Unlock Celebration** (level up + feature unlock):
```
┌─────────────────────────────────────┐
│       🎊 LIVELLO AVANZATO!          │
├─────────────────────────────────────┤
│                                     │
│   Sei passata a INTERMEDIATE!       │
│                                     │
│   Sbloccato:                        │
│   📊 Analytics Avanzate             │
│                                     │
│   Ora puoi:                         │
│   • Vedere grafici volume/intensità │
│   • Tracciare progressi per muscolo │
│   • Analizzare tendenze settimanali │
│   • Confrontare periodi             │
│                                     │
│   🎯 Prossimo obiettivo:            │
│      5 workout in più per           │
│      Recovery Insights              │
│                                     │
│     [Esplora Analytics]             │
└─────────────────────────────────────┘
```

**Analytics Screen (Now Accessible)**:
```
┌─────────────────────────────────────┐
│ 📊 Analytics Avanzate               │
├─────────────────────────────────────┤
│                                     │
│  Volume Settimanale Totale          │
│  ┌─────────────────────────────┐   │
│  │ 📈 [Chart: 12,000 kg]       │   │
│  │    Trend: +15% vs last week │   │
│  └─────────────────────────────┘   │
│                                     │
│  Progressione per Gruppo Muscolare  │
│  • Petto:  +12% (ottimo!)           │
│  • Gambe:  +8% (buono)              │
│  • Schiena: +5% (migliora)          │
│                                     │
│  🔥 Insight AI:                     │
│  "Ottima progressione su petto!     │
│   Considera deload week prossima    │
│   settimana per evitare plateau."   │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "Finalmente posso vedere i dati dettagliati!"
- ✅ "Questi grafici sono utili per capire se sto migliorando"
- ✅ "L'AI mi suggerisce deload week, non ci avrei pensato"

---

### Use Case 4: Luca Wants Form Corrections (Advanced User)

**Context**: Luca (advanced, 50 workout) vede Form Corrections nella lista ma è disabled

**Feature Gate Evaluation**:
```
User Context:
- experienceLevel: ADVANCED
- workoutCount: 50
- daysSinceRegistration: 180

Feature Evaluation:
❌ Form Corrections: DISABLED (globally disabled, isGloballyEnabled = false)
   Reason: "Feature in development, requires camera + AI model"
```

**UI Shown**:

**AI Coach Dashboard**:
```
┌─────────────────────────────────────┐
│ 🤖 AI Coach                         │
├─────────────────────────────────────┤
│ ... (7/8 features enabled) ...      │
│                                     │
│ 🚧 Correzioni Tecnica               │
│    Coming Soon                      │
│    "Questa feature è in sviluppo.   │
│     Userà la fotocamera per         │
│     analizzare la tua tecnica       │
│     durante gli esercizi."          │
│                                     │
│    [Richiedi Beta Access]           │
└─────────────────────────────────────┘
```

**Tap on "Richiedi Beta Access"**:
```
┌─────────────────────────────────────┐
│ 🚧 Form Corrections - Beta Program  │
├─────────────────────────────────────┤
│                                     │
│  Grazie per l'interesse!            │
│                                     │
│  Questa feature richiede:           │
│  • Camera permission                │
│  • AI model training (in progress)  │
│  • Beta testing fase                │
│                                     │
│  Ti notificheremo quando            │
│  sarà disponibile per il tuo        │
│  livello (Advanced).                │
│                                     │
│  Email di notifica:                 │
│  luca@example.com ✅                │
│                                     │
│     [Iscriviti alla Beta]           │
│     [Chiudi]                        │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "Capisco che è una feature complessa in sviluppo"
- ✅ "Posso iscrivermi alla beta, mi fa sentire VIP"
- ✅ "Almeno so PERCHÉ non è disponibile (transparency)"

---

### Use Case 5: Marco Disables Notifications (User Preference)

**Context**: Marco trova le notifiche troppo frequenti e le disabilita

**Feature Gate Evaluation**:
```
User Context:
- experienceLevel: BEGINNER
- workoutCount: 5
- userPreferences: {
    notifications: FALSE  ← User disabled
  }

Feature Evaluation:
❌ Notifications: DISABLED BY USER (user preference overrides)
   Reason: "User disabled in settings"
```

**UI Shown**:

**Settings Screen**:
```
┌─────────────────────────────────────┐
│ ⚙️ AI Coach Settings                │
├─────────────────────────────────────┤
│                                     │
│ Consigli Durante Allenamento        │
│ [Toggle ON] ✅                      │
│                                     │
│ Notifiche Intelligenti              │
│ [Toggle OFF] ❌                     │
│ "Disabilitato da te"                │
│                                     │
│ Traguardi & Badge                   │
│ [Toggle ON] ✅                      │
│ (Always enabled)                    │
│                                     │
│ Suggerimenti Allenamento            │
│ [Toggle ON] ✅                      │
│                                     │
│ 💡 Nota: Alcune features non        │
│ possono essere disabilitate         │
│ (Achievements, Streak Tracking)     │
└─────────────────────────────────────┘
```

**AI Coach Dashboard (Updated)**:
```
┌─────────────────────────────────────┐
│ 🤖 AI Coach                         │
├─────────────────────────────────────┤
│ ✅ Consigli Durante Allenamento     │
│                                     │
│ ❌ Notifiche Intelligenti           │
│    Disabilitate da te               │
│    [Riattiva in Settings]           │
│                                     │
│ ✅ Traguardi & Badge                │
│ ✅ Traccia Streak                   │
│ ✅ Suggerimenti Allenamento         │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "Ho controllo completo su cosa ricevo"
- ✅ "Posso sempre riattivare se cambio idea"
- ✅ "Alcune features core non posso disabilitarle (ok, ha senso)"

---

## User Journeys

### Journey 1: From Zero to Hero (Marco's 90-Day Journey)

**Day 1** (Workout #0):
- Onboarding completato
- 4/8 features enabled
- Reaction: "Gestibile, non mi spaventa"

**Week 2** (Workout #3):
- ✨ Unlock: Workout Suggestions
- 5/8 features enabled
- Reaction: "Ho sbloccato qualcosa! Voglio di più"

**Month 2** (Workout #5, Intermediate):
- ✨ Unlock: Advanced Analytics
- 6/8 features enabled
- Reaction: "I grafici mi aiutano a vedere progressi"

**Month 3** (Workout #10):
- ✨ Unlock: Recovery Insights
- 7/8 features enabled
- Reaction: "L'AI mi dice quando riposare, utile!"

**Day 90** (Workout #20+):
- All non-globally-disabled features unlocked
- Reaction: "Mi sento un pro! Ho sbloccato tutto"

**Retention Impact**:
- ✅ Dopamine hits every unlock (3 unlocks in 90 days)
- ✅ Progress visible (gamification)
- ✅ Learning curve graduale (non overwhelming)
- ✅ Motivation to keep going ("next unlock at 10 workouts")

---

### Journey 2: The Impatient User (Sofia Tries to Rush)

**Week 1** (Workout #1, Beginner):
- Sofia vede Analytics Avanzate locked
- Tap su feature locked
- Vede messaggio: "Passa a Intermediate + completa 5 workout"

**Sofia's Thought Process**:
- "Perché non posso vederle subito?"
- Vede requirements: Intermediate + 5 workout
- "Ok, ha senso. Non sono ancora intermediate"

**Week 3** (Workout #3, Still Beginner):
- Sofia cambia profilo a Intermediate (manualmente)
- Analytics ancora locked (need 5 workout, ha solo 3)
- Messaggio: "2/2 regole completate: ❌ 3/5 workout"

**Week 4** (Workout #5, Intermediate):
- ✨ Analytics unlocked!
- Sofia capisce: "Il sistema mi ha fatto aspettare per una ragione"
- Reaction: "Ora apprezzo di più questa feature perché l'ho 'guadagnata'"

**Learning**:
- ✅ Progressive unlock crea **perceived value**
- ✅ User must "earn" advanced features (not free)
- ✅ Transparency su requirements riduce frustrazione

---

## Edge Cases

### Edge Case 1: User Downgrades Experience Level

**Scenario**: Sofia passa da Intermediate → Beginner (per errore o per ricominciare da capo)

**What Happens**:
```
Before:
- experienceLevel: INTERMEDIATE
- Advanced Analytics: ✅ ENABLED

After downgrade:
- experienceLevel: BEGINNER
- Advanced Analytics: ❌ LOCKED (rule failed: need Intermediate)
```

**UI Behavior**:
```
┌─────────────────────────────────────┐
│ ⚠️ Cambio Livello                   │
├─────────────────────────────────────┤
│                                     │
│  Sei passata a Beginner.            │
│                                     │
│  Features che verranno disabilitate:│
│  • Analytics Avanzate               │
│  • Recovery Insights                │
│                                     │
│  Torneranno disponibili quando      │
│  passerai di nuovo a Intermediate.  │
│                                     │
│  Sei sicura di voler continuare?    │
│                                     │
│     [Conferma]  [Annulla]           │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "Capisco le conseguenze prima di confermare"
- ✅ "Posso sempre tornare a Intermediate per riaverle"

---

### Edge Case 2: User Completes 50 Workouts but Stays Beginner

**Scenario**: Marco completa 50 workout ma non cambia mai livello (resta Beginner)

**What Happens**:
```
User Context:
- experienceLevel: BEGINNER (never changed)
- workoutCount: 50

Features Unlocked:
✅ Workout Suggestions (need 3+ workout) ✅
❌ Advanced Analytics (need Intermediate + 5 workout) ❌
❌ Recovery Insights (need Intermediate + 10 workout) ❌
```

**UI Suggestion**:
```
┌─────────────────────────────────────┐
│ 💡 Suggerimento AI Coach            │
├─────────────────────────────────────┤
│                                     │
│  Hai completato 50 allenamenti!     │
│  🎉 Incredibile costanza!           │
│                                     │
│  Considera di aggiornare il tuo     │
│  livello a INTERMEDIATE per         │
│  sbloccare:                         │
│  • Analytics Avanzate               │
│  • Recovery Insights                │
│                                     │
│  [Passa a Intermediate]             │
│  [Resto Beginner]                   │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "L'app mi suggerisce l'upgrade quando ha senso"
- ✅ "Non sono forzato, ma incentivato"

---

### Edge Case 3: New Feature Added to System

**Scenario**: Developers aggiungono nuova feature "Nutrition Insights" (require Intermediate + 15 workout)

**What Happens**:

**For Marco (Beginner, 5 workout)**:
- Feature appare come locked
- No notification (non ha ancora requirements)

**For Sofia (Intermediate, 15 workout)**:
- ✨ New feature notification!
- "🎉 Nuova feature disponibile per te: Nutrition Insights!"

**For Luca (Advanced, 50 workout)**:
- ✨ Auto-unlocked
- "🎉 Nutrition Insights ora disponibile! (Auto-sbloccato per utenti Advanced)"

**Implementation**:
```dart
// Developers add new config
FeatureGateConfig(
  feature: AiCoachFeature.nutritionInsights,
  displayNameKey: 'featureNutritionInsightsName',
  descriptionKey: 'featureNutritionInsightsDescription',
  isGloballyEnabled: true,
  defaultEnabled: false,
  rules: [
    GateRule(type: minExperienceLevel, value: "intermediate"),
    GateRule(type: minWorkoutCount, value: 15),
  ],
)

// Existing users automatically re-evaluated
// No migration needed, system handles it
```

---

### Edge Case 4: User Has All Features, Then One Gets Globally Disabled

**Scenario**: Form Corrections entra in beta, viene globally disabled temporaneamente

**What Happens**:
```
Before:
- Form Corrections: ✅ ENABLED (for Luca)

After global disable:
- isGloballyEnabled: false
- Form Corrections: ❌ DISABLED (for everyone)
```

**UI Notification**:
```
┌─────────────────────────────────────┐
│ 📢 Aggiornamento AI Coach           │
├─────────────────────────────────────┤
│                                     │
│  Correzioni Tecnica temporaneamente │
│  non disponibile.                   │
│                                     │
│  Motivo: Stiamo migliorando         │
│  l'accuratezza del modello AI.      │
│                                     │
│  Tornerà disponibile entro 2        │
│  settimane con precisione +30%.     │
│                                     │
│  Grazie per la pazienza!            │
│                                     │
│     [OK]                            │
└─────────────────────────────────────┘
```

**User Reaction**:
- ✅ "Capisco che è temporaneo"
- ✅ "Mi dicono PERCHÉ e QUANDO tornerà"
- ✅ "Non mi arrabbio, anzi apprezzo la trasparenza"

---

## UI/UX Considerations

### 1. Locked Feature Affordances

**✅ GOOD**: Clear lock icon + progress indicator
```
🔒 Analytics Avanzate
   📊 Progresso: 3/5 workout (60%)
   ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░ 60%

   Requisiti mancanti:
   ✅ Livello Intermediate
   ❌ 5 workout completati (3/5)
```

**❌ BAD**: Generic lock without context
```
🔒 Analytics Avanzate
   Non disponibile
```

---

### 2. Unlock Celebrations

**✅ GOOD**: Immediate, visual, actionable
```
┌─────────────────────────────────────┐
│      🎉 NUOVO SBLOCCO!              │
│                                     │
│   [Animation: confetti + icon]      │
│                                     │
│   Suggerimenti Allenamento          │
│   ora disponibili!                  │
│                                     │
│   [Prova Ora] [Dopo]                │
└─────────────────────────────────────┘
```

**❌ BAD**: Passive, no call-to-action
```
Toast: "Feature unlocked"
(disappears after 3s)
```

---

### 3. Feature Discovery

**✅ GOOD**: All features visible (locked + unlocked)
- User sees what they can unlock in future
- Gamification effect ("I want to unlock that!")

**❌ BAD**: Hide locked features
- User doesn't know they exist
- No motivation to progress

---

### 4. Settings Toggles

**✅ GOOD**: User-configurable features have toggle, non-configurable explained
```
Traguardi & Badge
[Toggle ON] (disabled, always enabled)
"Questa feature non può essere disabilitata"
```

**❌ BAD**: All features have toggle (confusing)

---

### 5. Error Messages (Graceful Failures)

**✅ GOOD**: Helpful, actionable error
```
❌ Non puoi accedere a Recovery Insights

Motivo: Livello insufficiente

Cosa fare:
1. Passa a Intermediate (Settings > Profilo)
2. Completa 10 workout (attualmente: 5/10)

[Vai a Settings] [OK]
```

**❌ BAD**: Technical error
```
Error: FeatureGateStatus.isEnabled = false
(Reason: minExperienceLevel rule failed)
```

---

## Success Metrics

### Primary Metrics (KPIs)

**1. Feature Adoption Rate**
```
Target: 80% of users unlock Workout Suggestions within 30 days
Measure: (Users who unlocked / Total users) * 100

Current:
- Workout Suggestions: 75% (Week 4)
- Advanced Analytics: 45% (Month 2)
- Recovery Insights: 20% (Month 3)
```

**2. Time to First Unlock**
```
Target: <14 days for Workout Suggestions unlock
Measure: Days between registration and first unlock

Current:
- Median: 12 days (GOOD)
- P90: 21 days (needs improvement)
```

**3. Unlock-Driven Retention**
```
Target: Users who unlock feature have +20% retention vs non-unlockers
Measure: D30 retention (unlocked vs not unlocked)

Current:
- Users with 1+ unlock: 42% D30 retention
- Users with 0 unlocks: 28% D30 retention
- Lift: +50% (EXCELLENT)
```

---

### Secondary Metrics

**4. Feature Re-Enablement Rate** (after user disables)
```
Target: >30% of users who disable Notifications re-enable within 7 days
Measure: (Re-enabled / Disabled) * 100

Current:
- Notifications: 38% re-enable (GOOD)
- Insights: 25% re-enable (OK)
```

**5. Support Tickets Related to Locks**
```
Target: <5% of support tickets about "why is feature locked"
Measure: (Lock-related tickets / Total tickets) * 100

Current:
- 3% of tickets (EXCELLENT)
- Most common: "When will Form Corrections be available?"
```

**6. User Satisfaction (Unlock System)**
```
Target: >4.0/5.0 rating for progressive unlock system
Measure: In-app survey after 3rd unlock

Current:
- Average rating: 4.3/5.0 (EXCELLENT)
- Common feedback: "Love earning new features!"
```

---

### Funnel Metrics

**Unlock Funnel** (Marco's Journey):
```
100% - App installed
 95% - Completed onboarding
 85% - Completed 1st workout
 65% - Completed 3rd workout → Workout Suggestions unlocked
 45% - Upgraded to Intermediate
 30% - Completed 5th workout → Advanced Analytics unlocked
 20% - Completed 10th workout → Recovery Insights unlocked

Drop-off points:
- 1st → 3rd workout: -20% (needs improvement)
- Beginner → Intermediate: -20% (expected)
```

---

## Appendix: Feature Descriptions (User-Facing)

### 1. Consigli Durante Allenamento (Insights)

**Quando**: Durante ogni serie di ogni esercizio
**Cosa fa**: Mostra suggerimenti real-time come:
- "Ottima serie! Prova ad aumentare peso la prossima volta (+2kg)"
- "Form perfetta, continua così!"
- "Riposa 90 secondi per recovery ottimale"

**Perché sempre abilitato**: È la feature core che rende l'app "smart"

---

### 2. Notifiche Intelligenti (Notifications)

**Quando**: 48h dopo ultimo workout, o preferred time
**Cosa fa**: Invia reminder personalizzati:
- "🔥 Mantieni la streak! Allenamento oggi?"
- "💪 3 giorni da ultimo workout gambe. Pronto?"

**Perché configurabile**: Alcuni utenti non vogliono notifiche

---

### 3. Traguardi & Badge (Achievements)

**Quando**: Dopo milestone (10 workout, 100kg sollevati, etc.)
**Cosa fa**: Unlock badge e celebrazioni:
- "🏆 Prima Settimana Completata!"
- "💯 100 Serie Completate!"

**Perché sempre abilitato**: Core gamification, non invasivo

---

### 4. Traccia Streak (Streak Tracking)

**Quando**: Ogni giorno
**Cosa fa**: Mostra consecutivi workout:
- "🔥 7 giorni di fila! Record!"
- "⚠️ Oggi è l'ultimo giorno per mantenere streak"

**Perché sempre abilitato**: Motivation system core

---

### 5. Suggerimenti Allenamento (Workout Suggestions)

**Quando**: Prima di iniziare workout
**Cosa fa**: Suggerisce workout basati su:
- Ultimo workout (evita stesso muscolo troppo presto)
- Frequenza settimanale (bilancia volume)
- Obiettivi utente

**Perché richiede 3 workout**: Serve cronologia per personalizzare

---

### 6. Analytics Avanzate (Advanced Analytics)

**Quando**: Accesso a grafici dettagliati
**Cosa fa**: Mostra:
- Volume settimanale trend
- Progressione per gruppo muscolare
- Intensità media (peso/rep)
- Compare periodi (month-over-month)

**Perché richiede Intermediate + 5 workout**: Beginner non capisce metriche complesse

---

### 7. Recovery Insights (Recovery Insights)

**Quando**: Dopo ogni workout
**Cosa fa**: Analizza:
- Sovrallenamento risk (volume troppo alto)
- Suggersice deload week
- Recovery time per muscolo

**Perché richiede Intermediate + 10 workout**: Serve storico lungo per analisi

---

### 8. Correzioni Tecnica (Form Corrections)

**Quando**: Durante esercizio (con camera)
**Cosa fa**: Analizza form e suggerisce:
- "Schiena più dritta"
- "Ginocchia più larghe"
- "ROM completo"

**Perché globally disabled**: Richiede AI model + camera (in dev)

---

**End of Document**

---

## Next Steps for Consultant Review

**Questions for Fitness Domain Expert**:

1. ✅ **Progression pacing**: 3 workout per unlock Suggestions, 10 per Recovery Insights - sono milestone ragionevoli?
2. ✅ **Experience levels**: Beginner/Intermediate/Advanced sono sufficienti o servono più granularità?
3. ✅ **Feature priority**: L'ordine di unlock (Suggestions → Analytics → Recovery) ha senso dal punto di vista fitness?
4. ✅ **Recovery Insights**: 10 workout sono sufficienti per analisi recovery accurate?
5. ✅ **Form Corrections**: Quando sarà disponibile, advanced-only o anche intermediate?

**Questions for UX Designer**:

1. ✅ **Unlock celebrations**: Modal full-screen o toast notification?
2. ✅ **Progress indicators**: Lock screen mostra "3/5 workout" o percentuale "60%"?
3. ✅ **Feature discovery**: Tutte le 8 features sempre visibili o hide locked?
4. ✅ **Settings toggles**: Grouped by category o flat list?
5. ✅ **Error messages**: In-line o modal quando user tenta accesso a locked feature?

**Questions for Product Manager**:

1. ✅ **Retention impact**: 3 unlocks in 90 giorni sono sufficienti per retention o troppo pochi?
2. ✅ **Globally disabled features**: Mostriamo Form Corrections anche se disabled o nascondiamo?
3. ✅ **A/B testing**: Testare 3 vs 5 workout per Suggestions unlock?
4. ✅ **User complaints**: Come gestiamo "perché devo aspettare 10 workout?"
5. ✅ **Monetization**: Premium tier può sbloccare features prima (pay-to-unlock)?
