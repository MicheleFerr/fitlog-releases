# Stress Index Premium - Personal Calibration Design

**Date**: 2025-01-21
**Status**: Draft
**Author**: Claude + Michele

---

## Overview

Transform the Stress Index feature from a fixed-constant "indicative" metric (~60% accuracy) into a premium-worthy personalized system (~85% accuracy) that competes with Apple Watch Training Load and Garmin.

### Problem Statement

Current implementation uses fixed Banister FFM constants:
- τ₁ = 42 days (fitness decay)
- τ₂ = 10 days (fatigue decay)

Scientific research shows these constants are **individual-specific** and should be calibrated based on:
- Age (recovery slows with age)
- Training experience (novices adapt faster)
- Biological sex (hormonal differences)
- Sleep quality (affects recovery speed)
- HRV (correlates with recovery capacity)

### Competitive Analysis

| Feature | Apple Watch (FREE) | Garmin (FREE) | FitLog FREE | FitLog Premium |
|---------|-------------------|---------------|-------------|----------------|
| Training Load | ✅ | ✅ | ✅ Basic | ✅ Personal |
| Predictions | ❌ | ⚠️ Limited | ❌ | ✅ |
| Recommendations | ❌ | ⚠️ Generic | ❌ | ✅ Specific |
| Personal Calibration | ❌ | ❌ | ❌ | ✅ |
| Sleep Correlation | ❌ | ⚠️ | ❌ | ✅ |

---

## Architecture

### Calibration System

```
┌─────────────────────────────────────────────────────────┐
│                CALIBRATION ENGINE                        │
├─────────────────────────────────────────────────────────┤
│  1. ProfileCalibrator                                   │
│     └── Age, sex, experience → baseline τ₁/τ₂          │
│                                                         │
│  2. HealthKitCalibrator                                 │
│     └── HRV, sleep, recovery → adjustment factors      │
│                                                         │
│  3. HistoryCalibrator                                   │
│     └── Workout patterns → response curve fitting      │
│                                                         │
│  4. PersonalParametersProvider                          │
│     └── Combines 3 calibrators → τ₁_personal/τ₂_personal│
└─────────────────────────────────────────────────────────┘
```

### Calibration Formula

```
τ₁_personal = τ₁_base × age_factor × training_age_factor × sex_factor
τ₂_personal = τ₂_base × hrv_factor × sleep_factor × injury_factor
```

Where:
- `τ₁_base` = 42 days (1008 hours)
- `τ₂_base` = 10 days (240 hours)
- Factors range from 0.7 to 1.4

---

## Calibration Factors

### Fitness Decay Factors (τ₁)

| Factor | Source | Range | Logic |
|--------|--------|-------|-------|
| Age | UserFitnessQuestionnaire.age | 0.8–1.0 | 20-30: 1.0, 40: 0.9, 50+: 0.8 |
| Training Age | experienceLevel | 0.9–1.2 | Novice: 1.2, Advanced: 0.9 |
| Sex | BiologicalSex | 0.95–1.0 | Male: 1.0, Female: 0.95 |

### Fatigue Decay Factors (τ₂)

| Factor | Source | Range | Logic |
|--------|--------|-------|-------|
| HRV | HealthKit resting HR variance | 0.8–1.3 | >70ms: 0.8, <40ms: 1.3 |
| Sleep | HealthKit sleep data | 0.9–1.4 | 7-9h: 1.0, <6h: 1.4 |
| Injury | injuryDetails | 1.0–1.3 | None: 1.0, Active: 1.3 |

---

## Prediction Model

### Formula

```
Stress_tomorrow = Stress_today × decay_factor

Where:
- decay_factor = e^(-24h / τ₂_personal)
- If workout today: Stress_tomorrow += workout_stress × intensity_factor
```

### Output

```dart
@freezed
class StressInsight with _$StressInsight {
  const factory StressInsight({
    required double currentStress,           // 0-100
    required double predictedTomorrow,       // If rest
    required double predictedIfWorkout,      // If train
    required RecoveryRecommendation recommendation,
    required String rationale,               // Human-readable explanation
    required Map<String, double> factors,    // Contributing factors
  }) = _StressInsight;
}
```

---

## Recommendations Engine

### Thresholds

| Stress Range | Recommendation | Icon |
|--------------|----------------|------|
| 0-30 | Ready for hard session | 🟢 |
| 30-50 | Moderate session recommended | 🟡 |
| 50-70 | Light work only | 🟠 |
| 70-85 | Active recovery or rest | 🔴 |
| 85+ | Rest required | ⛔ |

### Rationale Examples

```
"High stress (78). Based on: 5.2h sleep (below 7h optimal) +
HRV 42ms (below your average 58ms). Recommend rest or light
mobility work. Expected recovery to 62 by tomorrow if resting."
```

---

## File Structure

```
lib/features/stress_index/
├── domain/
│   ├── entities/
│   │   ├── personal_calibration.dart      // NEW
│   │   ├── calibration_factors.dart       // NEW
│   │   └── stress_insight.dart            // NEW
│   ├── services/
│   │   ├── stress_index_calculator.dart   // MODIFY
│   │   ├── calibration_service.dart       // NEW
│   │   └── prediction_service.dart        // NEW
│   └── constants/
│       └── stress_index_constants.dart    // MODIFY
│
├── data/
│   ├── repositories/
│   │   └── calibration_repository.dart    // NEW
│   └── datasources/
│       └── calibration_local_ds.dart      // NEW (Hive)
│
└── presentation/
    ├── providers/
    │   ├── stress_calibration_provider.dart  // NEW
    │   └── stress_insight_provider.dart      // NEW
    └── widgets/
        ├── stress_prediction_card.dart       // NEW
        ├── stress_insight_widget.dart        // NEW
        └── calibration_wizard.dart           // NEW
```

---

## Dependencies

### Existing Infrastructure (Reuse)

1. **UserFitnessQuestionnaire** (strength_standards)
   - age, sex, experienceLevel, injuryDetails

2. **HealthKitDatasource** (ai_coach)
   - getSleepLastNight(), getSleepThisWeek()
   - getRestingHeartRate()

3. **WorkoutRepository** (workout)
   - Workout history for pattern analysis

### New Dependencies

None - all infrastructure exists.

---

## Data Flow

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│ UserFitness      │    │ HealthKit        │    │ Workout          │
│ Questionnaire    │    │ Datasource       │    │ Repository       │
└────────┬─────────┘    └────────┬─────────┘    └────────┬─────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │ CalibrationService     │
                    │ - calculateFactors()   │
                    │ - getPersonalParams()  │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ PredictionService      │
                    │ - predictTomorrow()    │
                    │ - getRecommendation()  │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ StressInsightProvider  │
                    │ - watchStressInsight() │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ StressPredictionCard   │
                    │ (UI Widget)            │
                    └────────────────────────┘
```

---

## UI/UX

### Home Screen Preview (Free)

```
┌──────────────────────────────────┐
│ 💪 Stress Index          🔒 Pro │
│                                  │
│     ████████████░░░░ 78         │
│            Alto                  │
│                                  │
│ [Sblocca previsioni →]          │
└──────────────────────────────────┘
```

### Home Screen Preview (Premium)

```
┌──────────────────────────────────┐
│ 💪 Stress Index           ⭐ Pro│
│                                  │
│     ████████████░░░░ 78         │
│            Alto                  │
│                                  │
│ 📉 Domani (riposo): 62 (-16)    │
│ 📈 Domani (allenamento): 89     │
│                                  │
│ 💡 Consiglio: Active recovery   │
│    5.2h sonno + HRV sotto media │
└──────────────────────────────────┘
```

### Detailed Screen (Premium)

- Current stress with breakdown by muscle group
- 7-day prediction chart
- Contributing factors (sleep, HRV, workouts)
- Personalized recommendations
- Calibration settings

---

## Implementation Phases

### Phase 1: Core Calibration (2-3 days)
- [ ] Create calibration entities
- [ ] Implement CalibrationService
- [ ] Add personal parameters to StressIndexCalculator
- [ ] Unit tests

### Phase 2: Predictions (1-2 days)
- [ ] Implement PredictionService
- [ ] Add prediction formulas
- [ ] Create StressInsight entity
- [ ] Unit tests

### Phase 3: Recommendations (1 day)
- [ ] Implement recommendation engine
- [ ] Add rationale generation
- [ ] Localization (IT/EN)

### Phase 4: UI (2 days)
- [ ] StressPredictionCard widget
- [ ] Updated home screen preview
- [ ] Detailed stress screen
- [ ] Premium gate logic

### Phase 5: Polish (1 day)
- [ ] Edge cases handling
- [ ] Performance optimization
- [ ] Documentation

---

## Premium Gating

### Free Features
- Current stress score (fixed constants)
- Basic stress level (Low/Medium/High/Very High)
- Muscle group breakdown

### Premium Features
- Personal calibration
- Tomorrow predictions
- Actionable recommendations
- Contributing factors breakdown
- Historical trend analysis
- Calibration wizard

---

## Success Metrics

1. **Accuracy**: Predicted vs actual recovery correlation >0.7
2. **Engagement**: 60%+ premium users check stress daily
3. **Retention**: Premium churn <5% monthly
4. **Satisfaction**: Feature rating >4.5 stars

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| HealthKit permission denied | Medium | Fallback to profile-only calibration |
| Insufficient workout history | Low | Use experience level as proxy |
| Model inaccuracy | High | A/B test with control group |
| Performance impact | Low | Cache calibration factors |

---

## References

1. Banister EW (1975) "A systems model of training for athletic performance"
2. Morton RH (1990) "Modeling human performance in running"
3. Res PT et al. "Sleep deprivation and muscle protein synthesis"
4. Knowles OE et al. "Sleep restriction and strength performance"
5. AASM/Sleep Research Society "7-9h recommendation"
