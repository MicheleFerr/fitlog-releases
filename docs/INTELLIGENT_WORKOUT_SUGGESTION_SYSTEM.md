# Intelligent Workout Day Suggestion System - Design Document

**Versione**: 1.0
**Data**: 2026-02-16
**Status**: Design Complete - Ready for Implementation

---

## Indice

1. [Executive Summary](#1-executive-summary)
2. [Analisi Sistema Attuale](#2-analisi-sistema-attuale)
3. [Fondamenti Scientifici](#3-fondamenti-scientifici)
4. [Competitor Analysis](#4-competitor-analysis)
5. [Algorithm Design](#5-algorithm-design)
6. [Rest Day Detection](#6-rest-day-detection)
7. [Adattamento per Livello Utente](#7-adattamento-per-livello-utente)
8. [Data Requirements](#8-data-requirements)
9. [UX Design](#9-ux-design)
10. [Implementation Roadmap](#10-implementation-roadmap)
11. [Validation Strategy](#11-validation-strategy)
12. [Riferimenti Bibliografici](#12-riferimenti-bibliografici)

---

## 1. Executive Summary

### Problema
L'attuale sistema di suggerimento mostra "Rest Day" troppo spesso perche:
- Si basa solo sulla readiness del **muscolo meno recuperato** del template
- Non considera il volume settimanale accumulato (MEV/MAV)
- Non integra pattern storici dell'utente
- Non differenzia tra "non ottimale" e "da evitare"
- La soglia OPTIMAL (>90%) e troppo stringente

### Soluzione Proposta
Un **sistema ibrido a 3 livelli** che combina:
1. **Multi-Factor Template Scoring** (sostituisce il ranking attuale)
2. **Smart Rest Day Detection** (decision tree multi-fattore)
3. **Adaptive Personalization** (pesi che si adattano al comportamento)

### Vincoli Tecnici
- On-device (Dart/Flutter), <100ms calcolo
- Offline-first, nessuna API esterna
- Privacy: zero dati inviati a server

---

## 2. Analisi Sistema Attuale

### Architettura Esistente (gia implementata)

```
templateSuggestionProvider
  -> TemplateStressAnalyzer.analyzeAllTemplates()
     -> Per ogni template:
        1. Estrai muscoli (focus + muscoliSecondari)
        2. Calcola muscle readiness (FFM model + HealthKit)
        3. Genera TemplateRecommendation (optimal/acceptable/suboptimal/avoid)
        4. Calcola optimalityScore (0-100)
     -> Ordina per score decrescente
```

### Componenti Gia Disponibili

| Componente | File | Cosa Fa |
|---|---|---|
| FFM Model | `fitness_fatigue_service.dart` | Performance(t) = 100 + Fitness(t) - Fatigue(t) |
| Calibration | `calibration_service.dart` | Fattori personali (eta, sesso, HRV, sleep, injury) |
| Recovery Constants | `stress_index_constants.dart` | 72h grandi, 48h medi, 24h piccoli |
| HealthKit Integration | `health_data_snapshot_provider` | Sleep, HRV, RHR (solo iOS) |
| NeglectedMuscleDetector | `neglected_muscle_detector.dart` | 13 muscoli, severity scoring, antagonist pairs |
| Split Detection | `split_detection_service.dart` | Pattern ultimi 21 giorni |
| Next Workout Suggestion | `next_workout_suggestion_provider.dart` | Combina split + recovery |

### Gap Identificati

| Gap | Impatto | Priorita |
|---|---|---|
| **RPE non usato** nel calcolo stress | Volume puro ignora l'intensita percepita | ALTA |
| **No volume tracking settimanale** per muscolo | Non sa se mancano set al MEV/MAV | ALTA |
| **Soglie troppo stringenti** (optimal >90%) | Troppi "Rest Day" falsi | CRITICA |
| **No deload detection** | Mai suggerisce settimane leggere | MEDIA |
| **Split detection solo 21gg** | Perde pattern mensili | BASSA |
| **Rest Day binario** | Nessuna via di mezzo (light day) | MEDIA |
| **NeglectedMuscleDetector disconnesso** dal suggestion | Muscoli trascurati non influenzano il ranking | ALTA |

---

## 3. Fondamenti Scientifici

### 3.1 Recovery Time per Gruppo Muscolare

La letteratura scientifica indica tempi di recupero diversi dalla regola semplicistica "grande = lento":

| Gruppo Muscolare | Recovery (ore) | Fonte | Note |
|---|---|---|---|
| Quadricipiti | 36-48 | UNI ScholarWorks | Rapidi nonostante dimensione (bassa attivazione volontaria) |
| Polpacci | 24-36 | MIKOLO Research | Tra i piu rapidi in assoluto |
| Petto | 48-72 | Beardsley 2022 | Piu lento dopo compound pesanti |
| Dorsali | 48-72 | Beardsley 2022 | Leggermente piu lento del petto |
| Spalle (Deltoidi) | 36-48 | Strength Crew | Recupero moderato |
| Bicipiti | 36-48 | UNI ScholarWorks | Fast-twitch dominant = piu lento del previsto |
| Tricipiti | 36-48 | UNI ScholarWorks | Simile ai bicipiti |
| Hamstrings | 48-72 | Beardsley 2022 | Medio-lungo |
| Glutes | 48-72 | Beardsley 2022 | Grandi e coinvolti in compound |
| Core | 24-36 | ACSM Guidelines | Recupero rapido, alta frequenza ok |
| Trapezio | 36-48 | Beardsley 2022 | Medio |
| Avambracci | 24-36 | MIKOLO Research | Piccoli, alta endurance |
| Lower Back | 48-72 | NSCA Guidelines | Coinvolto in quasi tutti i compound |

**Raccomandazione**: Aggiornare `muscleRecoveryHours` in `stress_index_constants.dart` con questi valori evidence-based. I quads attualmente hanno 72h (troppo), dovrebbero essere 48h.

### 3.2 Curva di Supercompensazione (Yakovlev)

```
Performance
    ^
    |         ___
    |        /   \        Supercompensazione
    |       /     \       (finestra ottimale)
100%|------/       \----- Baseline
    |     /         \
    |    /           detraining...
    |   / Recupero
    |  /
    | / Fatica
    +---------------------------------> Tempo (ore)
    0   12   24   36   48   72   96  120  144  168
```

**Fasi:**
1. **Fatica** (0-12h): Performance sotto baseline
2. **Recupero** (12-36h): Ritorno graduale a baseline
3. **Supercompensazione** (36-72h): **FINESTRA OTTIMALE** - allenare qui
4. **Involuzione** (>96h): Ritorno a baseline, benefici persi

**Sintesi Proteica Muscolare (MPS):**
- Picco: +109% a 24h post-allenamento (Phillips 1997, PubMed 8563679)
- Durata: max 48h nei soggetti allenati, fino a 72h nei principianti
- Implicazione: frequenza 2-3x/settimana per muscolo e ottimale

### 3.3 Volume Landmarks (Israetel/RP)

Set diretti per settimana per gruppo muscolare:

| Muscolo | MV | MEV | MAV (low) | MAV (high) | MRV |
|---|---|---|---|---|---|
| Petto | 6 | 10 | 14 | 20 | 22 |
| Dorsali | 6 | 12 | 16 | 24 | 28 |
| Spalle | 4 | 10 | 14 | 20 | 22 |
| Bicipiti | 4 | 8 | 12 | 18 | 22 |
| Tricipiti | 4 | 8 | 12 | 18 | 22 |
| Quadricipiti | 6 | 10 | 14 | 20 | 24 |
| Hamstrings | 4 | 8 | 12 | 18 | 22 |
| Polpacci | 4 | 10 | 14 | 18 | 20 |
| Core | 0 | 0 | 6 | 12 | 16 |

Dove:
- **MV** = Maintenance Volume (mantieni massa)
- **MEV** = Minimum Effective Volume (crescita minima)
- **MAV** = Maximum Adaptive Volume (range ottimale)
- **MRV** = Maximum Recoverable Volume (limite fatica)

**Key insight (Schoenfeld 2019)**: Il volume totale settimanale conta piu della frequenza. 10 set in 2 sessioni = 10 set in 3 sessioni.

### 3.4 CNS Fatigue Proxy

Non misurabile direttamente senza hardware, ma stimabile tramite proxy:

```
CNS_Fatigue_Score = w1 * compound_heavy_sessions_last_3_days
                  + w2 * avg_rpe_last_3_sessions
                  + w3 * total_volume_last_7_days / MRV_sum
                  + w4 * (1 - hrv_ratio)  // se disponibile
```

Dove:
- `compound_heavy_sessions`: deadlift, squat, bench con >80% 1RM
- `avg_rpe`: media RPE ultimi 3 allenamenti (se tracciato)
- `volume_ratio`: quanto vicino al MRV totale
- `hrv_ratio`: HRV attuale / baseline 7gg

### 3.5 Deload Protocol

**Frequenza raccomandata** (Delphi Consensus, PMC10511399):

| Livello | Ogni N settimane | Durata |
|---|---|---|
| Principiante | 8-10 | 5-7 giorni |
| Intermedio | 4-6 | 5-7 giorni |
| Avanzato | 3-5 | 5-7 giorni |

**Trigger reattivi** (suggerisci deload quando):
- Performance stalla per 2+ sessioni consecutive
- RPE medio >8.5 per 2+ settimane
- Volume settimanale >90% MRV per 3+ settimane consecutive
- HRV costantemente sotto baseline per 5+ giorni

**Implementazione deload**:
- Volume: -50% (dimezza i set)
- Intensita: 70% del normale
- Frequenza: invariata

---

## 4. Competitor Analysis

| Feature | Fitbod | Hevy | Strong | **FitLog (Target)** |
|---|---|---|---|---|
| Recovery tracking | ML (2B+ sets) | No | No | **FFM + HealthKit + Volume** |
| Workout suggestion | Black-box scoring | ChatGPT | No | **Transparent scoring** |
| Volume tracking | Si | Basico | Basico | **MEV/MAV/MRV tracking** |
| Deload detection | No | No | No | **Auto-detection** |
| Rationale spiegato | No | No | No | **Si (differenziatore)** |
| Offline | Si | Si | Si | **Si** |

**Differenziatore chiave**: FitLog spiega PERCHE suggerisce un template. Fitbod e una black-box. Questo e un vantaggio competitivo enorme per trust e retention.

---

## 5. Algorithm Design

### 5.1 Architettura Complessiva

```
┌─────────────────────────────────────────────────────────────┐
│                 INTELLIGENT SUGGESTION ENGINE                │
│                                                             │
│  Input:                                                     │
│  ├── User Templates[]                                       │
│  ├── Workout History (60 days)                              │
│  ├── Muscle Recovery State (existing FFM)                   │
│  ├── Weekly Volume Tracker (NEW)                            │
│  ├── NeglectedMuscleDetector results (existing)             │
│  ├── Split Pattern (existing)                               │
│  ├── User Level (XP tier)                                   │
│  └── HealthKit data (iOS, existing)                         │
│                                                             │
│  Pipeline:                                                  │
│  1. PRE-FILTER  → Elimina template "avoid"                  │
│  2. SCORE       → Multi-factor scoring per template         │
│  3. REST CHECK  → Decision tree: serve rest day?            │
│  4. RANK        → Ordina per score composito                │
│  5. EXPLAIN     → Genera rationale leggibile                │
│                                                             │
│  Output:                                                    │
│  ├── SuggestionResult                                       │
│  │   ├── type: workout | rest_day | deload                  │
│  │   ├── templates: List<RankedTemplate> (max 3)            │
│  │   ├── rationale: String (human-readable)                 │
│  │   └── confidence: 0.0-1.0                                │
│  └── Debug info (per analytics)                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Step 1: Pre-Filter

```dart
List<WorkoutTemplate> preFilter(List<WorkoutTemplate> templates, MuscleRecoveryState recovery) {
  return templates.where((t) {
    final muscles = extractMuscles(t);
    final primaryRecovery = muscles.primary.map((m) => recovery[m]?.percent ?? 100);
    final minPrimaryRecovery = primaryRecovery.min;

    // Rimuovi SOLO se il muscolo primario e ancora in fase di fatica acuta
    // Soglia ABBASSATA da 50% a 30% - molto meno aggressiva
    return minPrimaryRecovery >= 30.0;
  }).toList();
}
```

**Cambio chiave**: La soglia di "avoid" scende da 50% a 30%. Solo muscoli in fatica acuta (<30%) causano il filtraggio. Questo riduce drasticamente i falsi "Rest Day".

### 5.3 Step 2: Multi-Factor Template Scoring

Formula composita per ogni template:

```
Score(template) = w_recovery  * RecoveryScore
               + w_volume    * VolumeNeedScore
               + w_neglected * NeglectedScore
               + w_pattern   * PatternScore
               + w_variety   * VarietyScore
               + w_balance   * BalanceScore
```

#### Pesi per Fattore

| Fattore | Peso | Razionale |
|---|---|---|
| `w_recovery` | 0.25 | Muscoli recuperati = puo allenarsi |
| `w_volume` | 0.25 | Prioritizza muscoli sotto-MEV settimanale |
| `w_neglected` | 0.20 | NeglectedMuscleDetector gia calcola severity |
| `w_pattern` | 0.15 | Rispetta abitudini utente (lun=gambe, etc.) |
| `w_variety` | 0.10 | Non ripetere lo stesso template 2gg consecutivi |
| `w_balance` | 0.05 | Push/pull ratio, antagonist balance |

#### Calcolo RecoveryScore (0-100)

```dart
double recoveryScore(WorkoutTemplate template, MuscleRecoveryState recovery) {
  final muscles = extractMuscles(template);

  // Media pesata: primari contano 70%, secondari 30%
  final primaryScores = muscles.primary.map((m) {
    final r = recovery[m]?.percent ?? 100.0;
    // Curva sigmoidale: massimizza punteggio nella finestra di supercompensazione
    return _supercompensationCurve(r);
  });

  final secondaryScores = muscles.secondary.map((m) {
    final r = recovery[m]?.percent ?? 100.0;
    return _supercompensationCurve(r);
  });

  return primaryScores.average * 0.7 + secondaryScores.average * 0.3;
}

/// Curva che premia la finestra di supercompensazione (70-100%)
/// invece del recupero lineare
double _supercompensationCurve(double recoveryPercent) {
  if (recoveryPercent >= 90) return 95.0;   // Supercompensato - quasi ottimale
  if (recoveryPercent >= 70) return 100.0;  // FINESTRA OTTIMALE - punteggio max!
  if (recoveryPercent >= 50) return 70.0;   // Recuperato parzialmente - ok
  if (recoveryPercent >= 30) return 40.0;   // Ancora affaticato - subottimale
  return 10.0;                               // Fatica acuta - evitare
}
```

**Key insight**: Recovery 70-90% e MEGLIO di 100%. A 100% il muscolo sta gia tornando a baseline (involuzione). La finestra di supercompensazione e il momento ideale.

#### Calcolo VolumeNeedScore (0-100)

```dart
double volumeNeedScore(WorkoutTemplate template, WeeklyVolumeTracker volumes) {
  final muscles = extractPrimaryMuscles(template);

  double totalNeed = 0;
  for (final muscle in muscles) {
    final currentSets = volumes.setsThisWeek(muscle);
    final mev = volumeLandmarks[muscle]!.mev;
    final mav = volumeLandmarks[muscle]!.mavHigh;

    if (currentSets < mev) {
      // Sotto MEV: urgente - questo muscolo non sta crescendo
      totalNeed += 100.0 * (1 - currentSets / mev);
    } else if (currentSets < mav) {
      // Tra MEV e MAV: c'e spazio per volume
      totalNeed += 50.0 * (1 - (currentSets - mev) / (mav - mev));
    } else {
      // Sopra MAV: rischio overtraining per questo muscolo
      totalNeed += 0.0;
    }
  }

  return (totalNeed / muscles.length).clamp(0, 100);
}
```

#### Calcolo NeglectedScore (0-100)

```dart
double neglectedScore(WorkoutTemplate template, List<NeglectedMuscle> neglected) {
  final templateMuscles = extractAllMuscles(template);

  double score = 0;
  for (final n in neglected) {
    if (templateMuscles.contains(n.muscleKey)) {
      // Template copre un muscolo trascurato
      score += n.priority * 10; // priority e 0-10
    }
  }

  return score.clamp(0, 100);
}
```

#### Calcolo PatternScore (0-100)

```dart
double patternScore(WorkoutTemplate template, WorkoutHistory history) {
  final today = DateTime.now().weekday; // 1=Mon, 7=Sun
  final templateMuscles = extractPrimaryMuscleCategories(template);

  // Analizza ultimi 60 giorni: quante volte questo tipo di split
  // e stato fatto in questo giorno della settimana?
  final matchCount = history.workouts
    .where((w) => w.completedAt.weekday == today)
    .where((w) => _categoriesOverlap(w.muscleCategories, templateMuscles))
    .length;

  final totalOnThisDay = history.workouts
    .where((w) => w.completedAt.weekday == today)
    .length;

  if (totalOnThisDay == 0) return 50.0; // No pattern, neutro

  return (matchCount / totalOnThisDay * 100).clamp(0, 100);
}
```

#### Calcolo VarietyScore (0-100)

```dart
double varietyScore(WorkoutTemplate template, WorkoutHistory history) {
  final lastWorkout = history.mostRecent;
  if (lastWorkout == null) return 100.0;

  // Penalizza se template identico usato nell'ultimo workout
  if (lastWorkout.templateId == template.id) return 10.0;

  // Penalizza se stessi muscoli primari dell'ultimo workout
  final lastMuscles = extractPrimaryMuscles(lastWorkout);
  final thisMuscles = extractPrimaryMuscles(template);
  final overlap = lastMuscles.intersection(thisMuscles).length;
  final overlapRatio = overlap / thisMuscles.length;

  return ((1 - overlapRatio) * 100).clamp(0, 100);
}
```

#### Calcolo BalanceScore (0-100)

```dart
double balanceScore(WorkoutTemplate template, WeeklyVolumeTracker volumes) {
  // Antagonist pairs ratios (target: ~1.0)
  final pairs = [
    ('chest', 'back'),         // Push/Pull upper
    ('quads', 'hamstrings'),   // Push/Pull lower
    ('biceps', 'triceps'),     // Arms
    ('shoulders', 'back'),     // Overhead/Pull
  ];

  double imbalanceTotal = 0;
  int pairsChecked = 0;

  for (final (a, b) in pairs) {
    final volA = volumes.setsThisWeek(a);
    final volB = volumes.setsThisWeek(b);
    if (volA + volB == 0) continue;

    final ratio = volA / max(volB, 1);
    final deviation = (ratio - 1.0).abs();
    imbalanceTotal += deviation;
    pairsChecked++;
  }

  if (pairsChecked == 0) return 50.0;

  final avgImbalance = imbalanceTotal / pairsChecked;

  // Template che bilancia la coppia piu squilibrata riceve bonus
  // ...logica per verificare se template aiuta il bilancio

  return ((1 - avgImbalance) * 100).clamp(0, 100);
}
```

### 5.4 Step 3: Score Composito

```dart
class TemplateSuggestionEngine {
  static const _weights = {
    'recovery': 0.25,
    'volume': 0.25,
    'neglected': 0.20,
    'pattern': 0.15,
    'variety': 0.10,
    'balance': 0.05,
  };

  double computeScore(WorkoutTemplate template, SuggestionContext ctx) {
    final scores = {
      'recovery': recoveryScore(template, ctx.muscleRecovery),
      'volume': volumeNeedScore(template, ctx.weeklyVolumes),
      'neglected': neglectedScore(template, ctx.neglectedMuscles),
      'pattern': patternScore(template, ctx.history),
      'variety': varietyScore(template, ctx.history),
      'balance': balanceScore(template, ctx.weeklyVolumes),
    };

    double total = 0;
    for (final entry in scores.entries) {
      total += _weights[entry.key]! * entry.value;
    }

    return total; // 0-100
  }
}
```

### 5.5 Step 4: Rank & Select

```dart
SuggestionResult generateSuggestion(List<WorkoutTemplate> templates, SuggestionContext ctx) {
  // 1. Pre-filter
  final viable = preFilter(templates, ctx.muscleRecovery);

  // 2. Score each
  final scored = viable.map((t) => RankedTemplate(
    template: t,
    score: computeScore(t, ctx),
    breakdown: computeScoreBreakdown(t, ctx), // per UI debug
  )).toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  // 3. Rest Day check
  final restDayDecision = checkRestDay(ctx);

  if (restDayDecision.shouldRest) {
    return SuggestionResult(
      type: restDayDecision.isDeload
        ? SuggestionType.deload
        : SuggestionType.restDay,
      templates: [],
      rationale: restDayDecision.rationale,
      confidence: restDayDecision.confidence,
    );
  }

  // 4. Return top 3
  final top3 = scored.take(3).toList();

  return SuggestionResult(
    type: SuggestionType.workout,
    templates: top3,
    rationale: generateRationale(top3.first, ctx),
    confidence: top3.first.score / 100.0,
  );
}
```

---

## 6. Rest Day Detection

### 6.1 Decision Tree

```
                    ┌──────────────────┐
                    │  Start Check     │
                    └────────┬─────────┘
                             │
                    ┌────────v─────────┐
                    │ Deload Needed?   │──── YES ──> DELOAD WEEK
                    │ (consecutive     │          (confidence: 0.9)
                    │  weeks > limit)  │
                    └────────┬─────────┘
                             │ NO
                    ┌────────v──────────────┐
                    │ Systemic Fatigue?     │──── YES ──> REST DAY
                    │ CNS score > threshold │          (confidence: 0.85)
                    │ AND trained 3+        │
                    │ consecutive days      │
                    └────────┬──────────────┘
                             │ NO
                    ┌────────v──────────────┐
                    │ Any template scored   │──── NO ──> REST DAY
                    │ > 40 after scoring?   │          (confidence: 0.7)
                    └────────┬──────────────┘
                             │ YES
                    ┌────────v──────────────┐
                    │ Already trained today?│──── YES ──> REST DAY
                    └────────┬──────────────┘          (confidence: 1.0)
                             │ NO
                             v
                        SUGGEST WORKOUT
```

### 6.2 Implementazione

```dart
class RestDayDecision {
  final bool shouldRest;
  final bool isDeload;
  final String rationale;
  final double confidence;
}

RestDayDecision checkRestDay(SuggestionContext ctx) {
  // CHECK 1: Deload needed?
  final consecutiveWeeks = ctx.history.consecutiveTrainingWeeks;
  final deloadThreshold = _deloadThresholdForLevel(ctx.userLevel);

  if (consecutiveWeeks >= deloadThreshold) {
    final lastDeload = ctx.history.lastDeloadDate;
    if (lastDeload == null || lastDeload.daysSinceNow > deloadThreshold * 7) {
      return RestDayDecision(
        shouldRest: true,
        isDeload: true,
        rationale: 'You\'ve trained ${consecutiveWeeks} weeks straight. '
          'A deload week helps your body fully recover and come back stronger.',
        confidence: 0.9,
      );
    }
  }

  // CHECK 2: Systemic fatigue
  final cnsFatigue = _calculateCNSFatigue(ctx);
  final consecutiveDays = ctx.history.consecutiveTrainingDays;

  if (cnsFatigue > 0.75 && consecutiveDays >= 3) {
    return RestDayDecision(
      shouldRest: true,
      isDeload: false,
      rationale: 'You\'ve trained ${consecutiveDays} days in a row '
        'with high intensity. A rest day will optimize your next session.',
      confidence: 0.85,
    );
  }

  // CHECK 3: No viable template
  // (handled by caller - if all templates scored < 40)

  // CHECK 4: Already trained today
  if (ctx.history.trainedToday) {
    return RestDayDecision(
      shouldRest: true,
      isDeload: false,
      rationale: 'You already trained today. Rest and recover!',
      confidence: 1.0,
    );
  }

  // CHECK 5: Weekly frequency exceeded
  final weeklyTarget = _weeklyFrequencyForLevel(ctx.userLevel);
  final sessionsThisWeek = ctx.history.sessionsThisWeek;

  if (sessionsThisWeek >= weeklyTarget) {
    return RestDayDecision(
      shouldRest: true,
      isDeload: false,
      rationale: 'You\'ve hit your ${weeklyTarget}x/week target. '
        'An extra rest day ensures quality over quantity.',
      confidence: 0.6, // Bassa - suggerimento soft, non blocco
    );
  }

  return RestDayDecision(shouldRest: false, isDeload: false, rationale: '', confidence: 0);
}
```

### 6.3 CNS Fatigue Score

```dart
double _calculateCNSFatigue(SuggestionContext ctx) {
  double score = 0;

  // A: Heavy compound sessions ultimi 3 giorni (0-0.4)
  final recentHeavy = ctx.history.workoutsInLastDays(3)
    .where((w) => _hasHeavyCompound(w))
    .length;
  score += (recentHeavy / 3.0) * 0.4;

  // B: Average RPE ultimi 3 allenamenti (0-0.3)
  final recentRPE = ctx.history.workoutsInLastDays(7)
    .take(3)
    .map((w) => w.averageRPE)
    .where((rpe) => rpe > 0);
  if (recentRPE.isNotEmpty) {
    score += (recentRPE.average / 10.0) * 0.3;
  }

  // C: Volume vs MRV ratio (0-0.2)
  final volumeRatio = ctx.weeklyVolumes.totalVolumeRatio; // vs sum of MRV
  score += volumeRatio.clamp(0, 1) * 0.2;

  // D: HRV deficit (0-0.1)
  if (ctx.healthData?.hrvRatio != null) {
    final hrvDeficit = (1 - ctx.healthData!.hrvRatio).clamp(0, 1);
    score += hrvDeficit * 0.1;
  }

  return score.clamp(0, 1); // 0 = fresco, 1 = esausto
}
```

---

## 7. Adattamento per Livello Utente

### 7.1 Configurazione per Livello

```dart
class LevelConfig {
  final int weeklyFrequency;       // Target sessioni/settimana
  final int deloadWeeks;           // Ogni N settimane
  final double recoveryMultiplier; // Moltiplicatore tempi recupero
  final int maxConsecutiveDays;    // Max giorni consecutivi
  final double restDayThreshold;   // Score minimo per suggerire workout

  static const beginner = LevelConfig(
    weeklyFrequency: 3,
    deloadWeeks: 10,
    recoveryMultiplier: 1.3,    // +30% tempo recupero
    maxConsecutiveDays: 2,
    restDayThreshold: 50,       // Piu conservativo
  );

  static const intermediate = LevelConfig(
    weeklyFrequency: 4,
    deloadWeeks: 6,
    recoveryMultiplier: 1.0,    // Baseline
    maxConsecutiveDays: 3,
    restDayThreshold: 40,
  );

  static const advanced = LevelConfig(
    weeklyFrequency: 5,
    deloadWeeks: 4,
    recoveryMultiplier: 0.85,   // -15% recupero (piu adattato)
    maxConsecutiveDays: 5,
    restDayThreshold: 30,       // Piu aggressivo
  );
}
```

### 7.2 Mapping da UserTier a LevelConfig

```dart
LevelConfig configForTier(UserTier tier) {
  switch (tier) {
    case UserTier.starter:
    case UserTier.bronze:
      return LevelConfig.beginner;
    case UserTier.silver:
      return LevelConfig.intermediate;
    case UserTier.gold:
    case UserTier.platinum:
      return LevelConfig.advanced;
  }
}
```

---

## 8. Data Requirements

### 8.1 Nuovi Dati Necessari

| Dato | Esiste? | Azione |
|---|---|---|
| Weekly volume per muscle group | NO | **Creare `WeeklyVolumeTracker`** - calcola set/settimana per muscolo dalla history |
| Consecutive training days | Parziale | Estrarre da history (semplice query) |
| Consecutive training weeks | NO | **Creare tracker** - conta settimane con >=1 workout |
| Last deload date | NO | **Aggiungere campo** o inferire da history (settimana con volume <50%) |
| Template-day-of-week correlation | NO | **Calcolare on-the-fly** dalla history |
| User ignored suggestion count | NO | **Opzionale Fase 3** - per adaptive weights |

### 8.2 WeeklyVolumeTracker (Nuovo Componente)

```dart
class WeeklyVolumeTracker {
  final Map<String, int> _setsThisWeek; // muscle -> set count

  factory WeeklyVolumeTracker.fromHistory(
    List<WorkoutHistoryDetail> history,
    Map<String, ExerciseDefinition> exerciseDB,
  ) {
    final weekStart = _startOfWeek(DateTime.now());
    final thisWeekWorkouts = history
      .where((w) => w.completedAt.isAfter(weekStart));

    final sets = <String, int>{};
    for (final workout in thisWeekWorkouts) {
      for (final exercise in workout.exercises) {
        final def = exerciseDB[exercise.exerciseId];
        if (def == null) continue;

        final primaryMuscle = def.focus;
        sets[primaryMuscle] = (sets[primaryMuscle] ?? 0) + exercise.sets.length;

        // Secondari contano 0.5 set (volume indiretto)
        for (final sec in def.muscoliSecondari) {
          sets[sec] = (sets[sec] ?? 0); // Non contare secondari come set diretti
          // Ma tieni traccia per il balance score
        }
      }
    }

    return WeeklyVolumeTracker._(sets);
  }

  int setsThisWeek(String muscle) => _setsThisWeek[muscle] ?? 0;

  double get totalVolumeRatio {
    double totalCurrent = 0;
    double totalMRV = 0;
    for (final entry in volumeLandmarks.entries) {
      totalCurrent += setsThisWeek(entry.key);
      totalMRV += entry.value.mrv;
    }
    return totalMRV > 0 ? totalCurrent / totalMRV : 0;
  }
}
```

### 8.3 Storage Requirements

Nessun storage aggiuntivo. Tutti i nuovi dati sono **calcolati on-the-fly** dalla history esistente. Complessita: O(W * E) dove W = workout ultimi 7 giorni (~5), E = esercizi per workout (~8). Tempo stimato: <5ms.

---

## 9. UX Design

### 9.1 Principi UX

1. **One-tap to start**: Il suggerimento principale e il default, un tap per iniziare
2. **Transparency**: Ogni suggerimento ha un "perche" leggibile
3. **Autonomy**: L'utente puo sempre scegliere altro o ignorare
4. **Max 3 opzioni**: Template principale + 2 alternative + "Browse all"
5. **Soft nudge**: Rest Day e un suggerimento, non un blocco

### 9.2 Card Design

#### Workout Suggerito (Primary)
```
┌─────────────────────────────────────────┐
│ 💡 Suggested for today                  │
│                                         │
│ 🏋️ Push Day - Chest & Triceps          │
│                                         │
│ "Your chest is in the optimal recovery  │
│  window and needs 8 more sets this week"│
│                                         │
│ ████████████░░ 85% match                │
│                                         │
│ [ Start Workout ]          [ See Why ]  │
└─────────────────────────────────────────┘
```

#### Alternative (Collapsed)
```
│ Also good today:                        │
│ • Pull Day (78%)  • Legs (72%)          │
```

#### Rest Day (quando necessario)
```
┌─────────────────────────────────────────┐
│ 🛏️ Rest Day Recommended                │
│                                         │
│ "You've trained 4 days straight with    │
│  high intensity. A rest day today will  │
│  boost your next workout performance."  │
│                                         │
│ [ Got it ]        [ Train anyway → ]    │
└─────────────────────────────────────────┘
```

**Key**: "Train anyway" permette all'utente di ignorare il suggerimento (autonomia). Il sistema non blocca mai.

#### Deload Week
```
┌─────────────────────────────────────────┐
│ 📉 Deload Week Suggested               │
│                                         │
│ "You've been training hard for 5 weeks. │
│  This week, use 50% fewer sets to let   │
│  your body fully recover."              │
│                                         │
│ [ Start Light Workout ]   [ Skip ]      │
└─────────────────────────────────────────┘
```

### 9.3 Rationale Generation

```dart
String generateRationale(RankedTemplate top, SuggestionContext ctx) {
  final parts = <String>[];
  final breakdown = top.breakdown;

  // Trova il fattore dominante
  final topFactor = breakdown.entries
    .reduce((a, b) => a.value > b.value ? a : b);

  switch (topFactor.key) {
    case 'recovery':
      final muscles = top.template.primaryMuscles.take(2).join(' and ');
      parts.add('Your $muscles are in the optimal recovery window');
      break;
    case 'volume':
      final deficit = _biggestVolumeDeficit(top.template, ctx);
      parts.add('Your ${deficit.muscle} needs ${deficit.sets} more sets this week');
      break;
    case 'neglected':
      final neglected = _topNeglectedInTemplate(top.template, ctx);
      parts.add('Your ${neglected} has been undertrained recently');
      break;
    case 'pattern':
      final day = DateFormat('EEEE').format(DateTime.now());
      parts.add('You usually train this split on ${day}s');
      break;
  }

  return parts.join('. ') + '.';
}
```

### 9.4 Persona Impact Analysis

| Persona | Impatto | Note |
|---|---|---|
| **Marco** (principiante) | ++ | Meno "Rest Day" confusionari, rationale spiega tutto |
| **Chiara** (busy mom) | ++ | One-tap start, meno friction, "Train anyway" per flessibilita |
| **Luca** (powerlifter) | + | Scoring trasparente, deload detection, volume tracking |
| **Sofia** (estetica) | + | Neglected muscle priority, balanced physique |
| **Roberto** (busy pro) | ++ | Suggerimento veloce e affidabile, zero decision fatigue |

Nessuna persona ha impatto negativo. Marco e Roberto sono i piu beneficiati.

---

## 10. Implementation Roadmap

### Fase 1: Smart Scoring MVP (Settimana 1)

**Goal**: Ridurre i falsi "Rest Day" del 70%+

**Tasks**:
1. Creare `WeeklyVolumeTracker` service
2. Creare `VolumeLandmarks` constants (tabella MEV/MAV/MRV)
3. Creare `TemplateSuggestionEngine` con i 6 fattori di scoring
4. Abbassare soglia pre-filter da 50% a 30%
5. Implementare `_supercompensationCurve()` per RecoveryScore
6. Integrare `NeglectedMuscleDetector` results nello scoring
7. Aggiornare `templateSuggestionProvider` per usare il nuovo engine
8. Aggiornare `TodaysWorkoutCard` per mostrare rationale e confidence
9. Test unitari per ogni fattore di scoring

**Files da creare**:
- `lib/features/stress_index/domain/services/template_suggestion_engine.dart`
- `lib/features/stress_index/domain/services/weekly_volume_tracker.dart`
- `lib/features/stress_index/domain/constants/volume_landmarks.dart`

**Files da modificare**:
- `lib/features/stress_index/presentation/providers/template_suggestion_provider.dart`
- `lib/features/stress_index/domain/constants/stress_index_constants.dart` (recovery times)
- `lib/features/workout/presentation/workout_screen/widgets/todays_workout_card.dart`

**Stima**: 4-5 giorni

### Fase 2: Smart Rest Day + Deload (Settimana 2)

**Goal**: Rest Day intelligente e deload auto-detection

**Tasks**:
1. Implementare `RestDayDecisionTree`
2. Implementare `CNSFatigueEstimator` (proxy-based)
3. Implementare `DeloadDetector` (consecutive weeks + triggers)
4. Implementare `LevelConfig` con mapping da UserTier
5. Aggiornare UI per rest day con "Train anyway" e deload card
6. Aggiungere rationale per rest day/deload
7. Integrare RPE medio nel CNS fatigue (se RPE tracciato)
8. Test unitari per decision tree

**Files da creare**:
- `lib/features/stress_index/domain/services/rest_day_decision_service.dart`
- `lib/features/stress_index/domain/services/cns_fatigue_estimator.dart`
- `lib/features/stress_index/domain/services/deload_detector.dart`
- `lib/features/stress_index/domain/models/level_config.dart`

**Stima**: 3-4 giorni

### Fase 3: Personalization & Pattern Learning (Settimana 3)

**Goal**: Sistema si adatta all'utente

**Tasks**:
1. Implementare `PatternAnalyzer` (correlazione template-giorno_settimana, finestra 60gg)
2. Implementare tracking "suggestion accepted/ignored"
3. Adaptive weights: se utente ignora suggerimenti tipo X, abbassa peso di quel fattore
4. Aggiornare `muscleRecoveryHours` con valori evidence-based
5. Aggiungere alternative suggestions (top 2-3 con score)
6. Polish UI: score breakdown, alternative collapsed
7. Integration test end-to-end
8. Performance benchmark (<100ms)

**Files da creare**:
- `lib/features/stress_index/domain/services/pattern_analyzer.dart`
- `lib/features/stress_index/domain/services/adaptive_weight_service.dart`

**Stima**: 4-5 giorni

---

## 11. Validation Strategy

### 11.1 Metriche di Successo

| Metrica | Baseline Attuale | Target Fase 1 | Target Fase 3 |
|---|---|---|---|
| % sessioni con "Rest Day" mostrato | ~60% (stimato) | <25% | <15% |
| Suggestion acceptance rate | Non tracciato | >50% | >70% |
| Template match (utente segue suggerimento) | Non tracciato | >40% | >60% |
| Calcolo time | ~200ms | <100ms | <50ms |
| User satisfaction (qualitative) | "Mostra sempre rest day" | "Suggerimenti sensati" | "Sembra che mi conosca" |

### 11.2 Testing Approach

**Unit Tests** (per ogni fattore):
```dart
// test: RecoveryScore premia supercompensazione
test('recoveryScore peaks in 70-90% range', () {
  expect(recoveryScore(template, recovery_at_80), greaterThan(recoveryScore(template, recovery_at_100)));
  expect(recoveryScore(template, recovery_at_80), greaterThan(recoveryScore(template, recovery_at_50)));
});

// test: VolumeNeedScore urgente sotto MEV
test('volumeNeedScore high when under MEV', () {
  expect(volumeNeedScore(chestTemplate, {chest: 4}), greaterThan(80));
  expect(volumeNeedScore(chestTemplate, {chest: 14}), lessThan(30));
});

// test: Rest Day solo quando veramente necessario
test('restDay not triggered with adequate recovery', () {
  final ctx = createContext(
    consecutiveDays: 1,
    cnsFatigue: 0.3,
    bestTemplateScore: 65,
  );
  expect(checkRestDay(ctx).shouldRest, false);
});
```

**Scenario Tests** (dati fittizi realistici):
- Utente che allena solo petto: sistema priorizza gambe/schiena
- Utente 5gg consecutivi: sistema suggerisce rest day
- Utente principiante dopo 1 workout: sistema NON mostra rest day
- Tutti i muscoli al 60%: sistema suggerisce il template con muscoli piu vicini a supercompensazione

### 11.3 Qualitative Validation

- Dog-fooding con l'utente beta attuale
- Confronto suggerimenti vs cosa un coach suggerirebbe
- Log dei suggerimenti per review manuale
- Feedback diretto (thumbs up/down su suggerimento) - Fase 3

---

## 12. Riferimenti Bibliografici

### Scienza del Training

1. Phillips SM et al. (1997). "Mixed muscle protein synthesis and breakdown after resistance exercise in humans." *Am J Physiol.* PubMed: 8563679
2. Schoenfeld BJ et al. (2016). "Effects of Resistance Training Frequency on Measures of Muscle Hypertrophy: A Systematic Review and Meta-Analysis." *Sports Med.* PubMed: 27102172
3. Schoenfeld BJ et al. (2019). "How many times per week should a muscle be trained to maximize muscle hypertrophy?" *J Sports Sci.* PubMed: 30558493
4. ACSM (2009). "Progression Models in Resistance Training for Healthy Adults." *Medicine & Science in Sports & Exercise.* PubMed: 19204579
5. Israetel M et al. "Training Volume Landmarks for Muscle Growth." *RP Strength.*
6. Pritchard HJ et al. (2023). "International Delphi Consensus on Deloading." PMC10511399
7. Latella C et al. (2024). "Deloading Practices in Strength Training." PMC10948666

### CNS Fatigue

8. Taylor JL et al. (2016). "Neural Contributions to Muscle Fatigue." *Medicine & Science in Sports & Exercise.* PMC4723165
9. Wan JJ et al. (2022). "Muscle Fatigue: General Understanding and Treatment." *Exp Mol Med.* PMC8997532

### UX & Behavior

10. Kirwan M et al. (2019). "User Engagement and Attrition in Fitness Apps." *JMIR.* PMC6906621
11. Jimenez-Zazo F et al. (2022). "Determinants of Dropout from Physical Activity Programs." PMC9165469
12. Tzirakis P et al. (2023). "Keeping People Active and Healthy at Home." *IJCAI 2023.*

### Competitor Analysis

13. Fitbod Algorithm Blog. https://fitbod.me/blog/fitbod-algorithm/
14. Fitbod Muscle Recovery. https://fitbod.zendesk.com/hc/en-us/articles/360006269014
15. Nike Engineering. "Personalized Workout Recommendations." https://medium.com/nikeengineering/

---

## Appendice A: Esempio Completo con Dati Fittizi

### Scenario

**Utente**: Intermedio (Silver tier), allena 4x/settimana

**Oggi**: Mercoledi

**Ultimi workout**:
- Lunedi: Push Day (petto 12 set, tricipiti 6 set, spalle 4 set)
- Martedi: Pull Day (dorsali 14 set, bicipiti 6 set, trap 4 set)

**Template disponibili**:
1. "Leg Day" (quads, hamstrings, glutes, calves)
2. "Push Day" (chest, triceps, shoulders)
3. "Pull Day" (back, biceps, traps)
4. "Upper Body" (chest, back, shoulders, arms)
5. "Full Body" (all)

### Calcolo Scores

**Recovery State** (mercoledi sera, ~36h da push, ~24h da pull):

| Muscolo | Ultimo Allenamento | Ore | Recovery% |
|---|---|---|---|
| Chest | Lunedi | 48 | 80% (supercompensazione!) |
| Triceps | Lunedi | 48 | 92% |
| Shoulders | Lunedi | 48 | 100% |
| Back | Martedi | 24 | 40% |
| Biceps | Martedi | 24 | 50% |
| Traps | Martedi | 24 | 50% |
| Quads | 5 giorni fa | 120 | 100% |
| Hamstrings | 5 giorni fa | 120 | 100% |
| Glutes | 5 giorni fa | 120 | 100% |
| Calves | 7 giorni fa | 168 | 100% |

**Volume questa settimana**:

| Muscolo | Set fatti | MEV | MAV | Status |
|---|---|---|---|---|
| Chest | 12 | 10 | 20 | In MAV range |
| Back | 14 | 12 | 24 | In MAV range |
| Quads | 0 | 10 | 20 | **SOTTO MEV!** |
| Hamstrings | 0 | 8 | 18 | **SOTTO MEV!** |

**Scoring per template**:

| Template | Recovery | Volume | Neglected | Pattern | Variety | Balance | **TOTAL** |
|---|---|---|---|---|---|---|---|
| **Leg Day** | 95 (tutto >100%) | 100 (sotto MEV) | 60 (legs neglected) | 80 (mercoledi=legs) | 100 (diverso) | 70 | **91.5** |
| Push Day | 100 (supercomp!) | 20 (gia in MAV) | 10 | 30 | 10 (appena fatto) | 30 | **38.5** |
| Pull Day | 40 (back 40%) | 30 (in MAV) | 10 | 20 | 10 (ieri) | 30 | **26.5** |
| Upper Body | 60 (mix) | 25 | 10 | 20 | 50 | 50 | **36.0** |
| Full Body | 70 (mix) | 60 | 30 | 30 | 80 | 60 | **56.5** |

**Risultato**: "Leg Day" vince con 91.5/100

**Rationale generato**: "Your legs are fully recovered and need 10+ more sets this week. You usually train legs on Wednesdays."

### Controllo Rest Day

- Consecutive days: 2 (lun + mar) < 3 threshold -> NO rest
- CNS fatigue: ~0.35 (volume moderato, 2 giorni) < 0.75 -> NO rest
- Best score: 91.5 > 40 threshold -> NO rest
- Trained today: NO -> NO rest

**Verdict**: SUGGEST WORKOUT (Leg Day)

---

## Appendice B: Volume Landmarks Constants (Dart)

```dart
/// Volume landmarks per gruppo muscolare (set diretti/settimana)
/// Fonte: Israetel et al., RP Strength
class VolumeLandmarks {
  final int mv;      // Maintenance Volume
  final int mev;     // Minimum Effective Volume
  final int mavLow;  // Maximum Adaptive Volume (low end)
  final int mavHigh; // Maximum Adaptive Volume (high end)
  final int mrv;     // Maximum Recoverable Volume

  const VolumeLandmarks({
    required this.mv,
    required this.mev,
    required this.mavLow,
    required this.mavHigh,
    required this.mrv,
  });
}

const volumeLandmarks = <String, VolumeLandmarks>{
  'PETT': VolumeLandmarks(mv: 6,  mev: 10, mavLow: 14, mavHigh: 20, mrv: 22),
  'LAT':  VolumeLandmarks(mv: 6,  mev: 12, mavLow: 16, mavHigh: 24, mrv: 28),
  'DORS': VolumeLandmarks(mv: 6,  mev: 12, mavLow: 16, mavHigh: 24, mrv: 28),
  'DELT': VolumeLandmarks(mv: 4,  mev: 10, mavLow: 14, mavHigh: 20, mrv: 22),
  'BICI': VolumeLandmarks(mv: 4,  mev: 8,  mavLow: 12, mavHigh: 18, mrv: 22),
  'TRIC': VolumeLandmarks(mv: 4,  mev: 8,  mavLow: 12, mavHigh: 18, mrv: 22),
  'QUAD': VolumeLandmarks(mv: 6,  mev: 10, mavLow: 14, mavHigh: 20, mrv: 24),
  'FEMO': VolumeLandmarks(mv: 4,  mev: 8,  mavLow: 12, mavHigh: 18, mrv: 22),
  'GLUT': VolumeLandmarks(mv: 4,  mev: 8,  mavLow: 12, mavHigh: 18, mrv: 22),
  'POLP': VolumeLandmarks(mv: 4,  mev: 10, mavLow: 14, mavHigh: 18, mrv: 20),
  'CORE': VolumeLandmarks(mv: 0,  mev: 0,  mavLow: 6,  mavHigh: 12, mrv: 16),
  'TRAP': VolumeLandmarks(mv: 4,  mev: 8,  mavLow: 12, mavHigh: 18, mrv: 22),
  'AVA':  VolumeLandmarks(mv: 2,  mev: 4,  mavLow: 8,  mavHigh: 14, mrv: 18),
  'LOMB': VolumeLandmarks(mv: 4,  mev: 6,  mavLow: 10, mavHigh: 14, mrv: 18),
};
```

## Appendice C: Updated Recovery Hours (Evidence-Based)

```dart
/// Tempi di recupero aggiornati basati su letteratura scientifica
/// Fonte: Beardsley 2022, UNI ScholarWorks, ACSM Guidelines
const muscleRecoveryHoursV2 = <String, double>{
  // Grandi - recupero moderato (NON tutti uguali!)
  'QUAD': 48,    // ERA 72 - quads recuperano piu velocemente
  'GLUT': 60,    // ERA 72 - ridotto leggermente
  'FEMO': 60,    // ERA 72 - ridotto leggermente
  'LAT':  60,    // ERA 72 - ridotto leggermente
  'PETT': 60,    // ERA 72 - ridotto
  'LOMB': 72,    // Invariato - molto coinvolto in compound

  // Medi - invariati (erano gia corretti)
  'DELT': 48,
  'DELT_ANT': 48,
  'DELT_LAT': 48,
  'DELT_POST': 48,
  'TRAP': 48,
  'BICI': 48,    // Piu lento del previsto per le dimensioni
  'TRIC': 48,
  'CORE': 36,    // ERA 48 - core recupera piu veloce

  // Piccoli
  'AVA':  36,    // ERA 48 - avambracci recuperano veloce
  'POLP': 36,    // ERA 48 - polpacci recuperano veloce
  'COLL': 24,    // Invariato
};
```
