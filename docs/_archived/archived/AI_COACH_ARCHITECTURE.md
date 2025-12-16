# 🧠 AI Coach Architecture - GymBro TrackLog

## 📋 Overview

L'AI Coach è un sistema intelligente che analizza i dati di allenamento dell'utente e fornisce insights personalizzati basati su ricerca scientifica evidence-based.

## 🎯 Obiettivi

1. **Scientificamente Accurato**: Calcoli basati su linee guida scientifiche (MEV, MAV, MRV)
2. **Actionable**: Consigli pratici e implementabili immediatamente
3. **Personalizzato**: Analisi specifica sui dati dell'utente
4. **Performante**: Ottimizzato per minimizzare rebuild e chiamate DB

## 🏗️ Architettura

### Layer Structure

```
presentation/
├── widgets/
│   └── ai_coach_card.dart          # UI Component
├── providers/
│   └── ai_coach_provider.dart      # Data Provider

domain/
└── services/
    ├── ai_coach_service.dart       # Business Logic
    └── ai_volume_calculator.dart   # Scientific Calculations
```

### Key Components

#### 1. AIVolumeCalculator
**Responsabilità**: Calcolo scientifico del volume per muscle group

**Metodi Principali**:
- `calculateWeeklyVolumeByMuscleGroup()`: Calcola volume settimanale per muscolo
- `findImbalancedMuscles()`: Identifica muscoli sotto MEV (< 10 sets/week)
- `findOvertrainedMuscles()`: Identifica muscoli sopra MRV (> 25 sets/week)

**Linee Guida Scientifiche Implementate**:
- **MEV** (Minimum Effective Volume): 10 sets/muscle/week
- **MAV** (Maximum Adaptive Volume): 15-20 sets/muscle/week ← OPTIMAL
- **MRV** (Maximum Recoverable Volume): 25 sets/muscle/week

**Nota Importante**:
Il calcolo considera:
- Muscoli primari (peso 100%)
- Muscoli secondari (peso 50%)
- Mappatura dal database esercizi
- Fallback su categorizzazione basica se esercizio non trovato

#### 2. AICoachService
**Responsabilità**: Generazione insights intelligenti

**Tipi di Insights Generati**:

1. **Muscle Group Balance**
   - Rileva sbilanciamenti muscolari
   - Priorità: ALTA se < 10 sets/week

2. **Progressive Overload**
   - Rileva plateau nei carichi
   - Consiglia aumenti progressivi

3. **Recovery Patterns**
   - Analizza tempo dall'ULTIMO workout (non media tra workout passati)
   - Alert "insufficient recovery" se < 1 giorno dall'ultimo workout
   - Alert "long recovery" se > 4 giorni dall'ultimo workout

4. **Training Frequency**
   - Basato su ultimi 30 giorni di attività
   - Alert "low frequency" solo se < 1 workout/settimana (troppo basso per progressi)
   - Alert "high frequency" se > 6 workout/settimana (rischio overtraining)

5. **Volume Plateau**
   - Usa regressione lineare per trend
   - Rileva stagnazione < 10% crescita/mese

6. **Form Warnings**
   - Alert se aumento peso > 15% tra sessioni
   - Prevenzione infortuni

#### 3. AICoachProvider
**Responsabilità**: Gestione stato e data fetching

**Ottimizzazioni**:
- `autoDispose`: Cleanup automatico
- Exercise database caching
- Error logging dettagliato
- Repository disposal

**Dependencies**:
```dart
- ExerciseActivityRepository (workout data)
- HybridExerciseRepository (exercise database)
- ProgressProvider (stats)
- AppLocalizations (i18n)
```

## 🔄 Data Flow

```
User Workout Data
    ↓
ExerciseActivityRepository
    ↓
AICoachProvider (Orchestrator)
    ├→ Fetch Exercise Database
    ├→ Fetch Progress Stats
    └→ Fetch User Activities
        ↓
AIVolumeCalculator
    ├→ Map exercises to muscle groups
    ├→ Calculate weekly volume
    └→ Classify MEV/MAV/MRV
        ↓
AICoachService
    ├→ Analyze volume balance
    ├→ Check progressive overload
    ├→ Detect plateaus
    ├→ Validate form safety
    └→ Generate insights (priority sorted)
        ↓
UI (AICoachCard)
    ├→ Display primary advice
    └→ Modal with detailed insights
```

## 📊 Esempio Pratico

### Input
```dart
Ultima settimana workout:
- Lunedì: Squat 3x10 @ 100kg
- Mercoledì: Leg Press 4x12 @ 200kg
- Venerdì: Leg Extension 3x15 @ 50kg

Total QUAD sets: 10 (sotto MEV!)
```

### Processing
```dart
AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup()
  → QUAD: 10 sets (classification: belowMEV)

AICoachService.generateInsights()
  → Insight generato:
     Type: muscleGroupBalance
     Priority: 2 (ALTA)
     Title: "Muscle Group Imbalance"
     Description: "Quadricipiti under-trained (10 sets/week)"
     Recommendation: "Add 5 more sets of quad work"
```

### Output (UI)
```
🏋️ AI Coach
─────────────────
💡 Muscle Imbalance Detected
   Quadricipiti is under-trained

Recommendation:
→ Add 5 more quad sets this week
→ Target: 15 sets for optimal growth

📊 Your Stats:
├─ Volume: +12%
├─ Consistency: 75%
└─ Streak: 5 days
```

## 🎯 Best Practices

### Per Developer

1. **Sempre passare exercise database**
   ```dart
   // ✅ CORRETTO
   AICoachService.generateInsights(
     activities,
     stats,
     streak,
     frequency,
     l10n,
     exerciseDatabase, // ← REQUIRED
   );
   ```

2. **Validare input utente**
   ```dart
   // ✅ CORRETTO
   if (currentUser?.email == null) {
     return [];
   }
   ```

3. **Gestire errori gracefully**
   ```dart
   // ✅ CORRETTO
   try {
     return await generateInsights(...);
   } catch (e, stackTrace) {
     print('❌ AI Coach Error: $e');
     return []; // Fallback sicuro
   }
   ```

### Per Insights Accuracy

1. **Sempre calcolare per muscle group**
   - ❌ WRONG: 20 sets per workout
   - ✅ RIGHT: 15 sets per muscle per week

2. **Considerare compound exercises**
   - Squat → QUAD (primary) + GLUT (secondary 50%)
   - Bench Press → PETT (primary) + TRIC (secondary 50%)

3. **Prioritizzare insights**
   - Priority 1: Rischi (overtraining)
   - Priority 2: Sbilanciamenti critici
   - Priority 3: Ottimizzazioni

## 🔧 Configurazione

### Soglie Personalizzabili
```dart
// In ai_volume_calculator.dart

// Per principianti
const MIN_SETS = 8;
const OPTIMAL_MIN = 12;
const OPTIMAL_MAX = 18;
const MAX_SETS = 22;

// Per avanzati
const MIN_SETS = 12;
const OPTIMAL_MIN = 18;
const OPTIMAL_MAX = 25;
const MAX_SETS = 30;
```

### Localizzazione
Tutte le stringhe in `assets/i18n/app_*.arb`:
```json
{
  "aiInsightMuscleImbalance": "Muscle Group Imbalance",
  "aiInsightMuscleImbalanceDesc": "{muscle} is under-trained",
  "aiInsightMuscleImbalanceRec": "Add more {muscle} exercises"
}
```

## 📈 Metriche di Successo

1. **Accuratezza**: > 90% consigli scientificamente validi
2. **Engagement**: > 60% utenti cliccano su insights
3. **Actionability**: > 70% utenti implementano consigli
4. **Performance**: < 500ms generation time

## 🚀 Future Enhancements

1. **Machine Learning Integration**
   - Pattern recognition personalizzato
   - Predizione plateau
   - Suggerimenti periodizzazione

2. **Advanced Analytics**
   - Analisi velocità barra
   - Fatigue monitoring
   - Readiness score

3. **Social Features**
   - Confronto con utenti simili
   - Community insights
   - Coach marketplace integration

## 📚 References

- Renaissance Periodization: Volume Landmarks
- Mike Israetel: Scientific Principles of Hypertrophy
- Brad Schoenfeld: Mechanisms of Hypertrophy
- Stronger By Science: Training Volume Meta-Analysis

---

## 🔧 Bug Fixes & Improvements

### v2.0.1 - Critical Bug Fixes
**Recovery Pattern Bug**
- ❌ Problema: Calcolava media recovery TRA workout passati, ignorando tempo dall'ultimo workout
- ✅ Fix: Ora controlla giorni dall'ULTIMO workout (usa `.inHours / 24.0` per precisione)

**Frequency Warning Bug**
- ❌ Problema: Threshold < 2.0 troppo aggressivo
- ✅ Fix: Cambiato a < 1.0 workout/settimana

### v2.1.0 - Enhanced Intelligence (Latest)

**1. Consistency Calculation Fixed**
- ❌ Problema: Formula `(frequency / 4 * 100)` produceva risultati errati
- ✅ Fix: Ora usa `min((frequency / 4.0) * 100, 100)` con cap al 100%
- Esempio: 3x/week → 75% consistency ✓

**2. Localization Compliance**
- ❌ Problema: Testo "AI" hardcoded nel badge
- ✅ Fix: Aggiunta chiave `aiBadge` localizzata in EN/IT

**3. Smart Form Warnings**
- ❌ Problema: 15% threshold troppo aggressivo per tutti i casi
- ✅ Fix: Adaptive thresholds:
  - Pesi < 20kg: 40% threshold (es. 5→7.5kg OK)
  - Pesi > 20kg: 25% threshold
  - Skip primi 4 workout (fase iniziale)
  - Richiede aumento assoluto > 5kg

**4. Improved Plateau Detection**
- ❌ Problema: Check `==` troppo rigido (100, 102, 100 = NO plateau)
- ✅ Fix: Range-based detection (< 5% variazione = plateau)
- Esempio: 100, 102, 100 → range 2kg / avg 100.67 = 1.98% → Plateau! ✓

**5. New User Experience**
- ❌ Problema: Analytics avanzate su utenti con 1-3 workout totali
- ✅ Fix: Messaggio motivazionale dedicato per 1-3 workout
- "Ottimo Inizio! Completa 5+ allenamenti per sbloccare analisi avanzata"

**6. Positive Reinforcement**
- ❌ Problema: Solo warning negativi, nessun feedback positivo
- ✅ Fix: Insight celebrativo per volume ottimale (15-20 sets/muscle/week)
- "Volume Perfetto! Sei nel punto ideale per la crescita muscolare"

---

### v2.2.0 - Interactive Scientific Coach (Latest)

**🎯 Dynamic Expandable Insights**
- ✅ Click to expand any insight for detailed analysis
- ✅ Shows "Why This Matters" section with scientific explanation
- ✅ "Your Data" section with specific numbers (e.g., last 3 session weights)
- ✅ Evidence-based solutions with 3-5 strategies per issue

**📚 Scientific Strategies System**

Each insight now includes **ScientificStrategy** objects with:
- **Title**: Strategy name (e.g., "Increase Training Volume")
- **Description**: What it is and why it works
- **How to Implement**: Concrete action steps
- **Expected Outcome**: Results timeline
- **Scientific Basis**: Paper citation (e.g., "Schoenfeld et al. 2017")

**Example - Plateau Insight:**
```
📊 Your Data:
• Session 1: 100.0kg
• Session 2: 100.0kg
• Session 3: 102.0kg
• Variation: 2.0kg (1.98%)

🎯 Evidence-Based Solutions:
1. Increase Training Volume
   → Add 1-2 sets per week
   → Expected: New growth in 2-4 weeks
   → Research: Schoenfeld et al. (2017)

2. Vary Rep Ranges
   → Alternate 4-6, 8-12, 15-20 reps
   → Expected: Enhanced fiber recruitment
   → Research: Schoenfeld et al. (2021)

[3 more strategies...]
```

**🔬 Scientific References Included:**
- Schoenfeld et al. (2017) - Volume & Hypertrophy
- Schoenfeld et al. (2019) - Training Frequency
- Schoenfeld et al. (2021) - Rep Range Effects
- Fink et al. (2018) - Drop Sets
- Fonseca et al. (2014) - Exercise Variation
- Pritchard et al. (2015) - Deloading
- Simão et al. (2012) - Exercise Order
- Paoli et al. (2017) - Isolation vs Compound
- Williams et al. (2017) - Periodization
- Dattilo et al. (2011) - Sleep & Recovery

**📱 UX Improvements:**
- Expandable ExpansionTile for insights with details
- Simple cards for basic insights (motivational)
- Color-coded strategies per insight type
- Monospace font for data points (better readability)
- Green highlights for expected outcomes
- Reference chips at bottom with 📚 icon

---

**Last Updated**: January 2025
**Version**: 2.2.0 (Interactive Scientific Coach)
**Status**: Production Ready ✅
