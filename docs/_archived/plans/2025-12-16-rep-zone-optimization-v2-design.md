# Rep Zone Optimization v2 - Design Document

**Data**: 2025-12-16
**Stato**: Approvato
**Feature**: Miglioramento UX ottimizzazione zone rep

---

## Problema

L'attuale sistema di ottimizzazione ha questi problemi:

1. **Ridondanza UX**: Step inutile di scelta modalita (swipe vs lista)
2. **Pochi suggerimenti**: Solo 5 suggerimenti, 2 per zona
3. **Motivazioni generiche**: Solo 3 tipi ("zona vuota", "zona trascurata", "bilanciare")
4. **Nessuna alternativa**: Un solo esercizio per suggerimento
5. **Logica basica**: Nessuna spiegazione del perche proprio quell'esercizio

---

## Soluzione

### User Flow Semplificato

```
[Premi "Ottimizza"]
       |
       v
[Sheet con card stack]  <-- Diretto, no selezione modalita
       |
       v
[Card compatta]
 +---------------------------+
 | FORZA                     | <-- Badge zona colorato
 | Panca Piana               | <-- Esercizio principale
 | "Manca forza al petto"    | <-- Motivazione breve
 | 3 alternative             | <-- Indicatore tap
 | <- SALTA    AGGIUNGI ->   | <-- Swipe hints
 +---------------------------+
       | TAP
       v
[Card espansa - Hero animation]
 +---------------------------+
 | FORZA (1-5 rep)           |
 | =======================   |
 | PANCA PIANA               |
 |                           |
 | PERCHE:                   |
 | - Compound: petto+tric    |
 | - 0% forza ultimi 30gg    |
 | - Template "Push" ideale  |
 |                           |
 | ALTERNATIVE:              |
 | [Dip] [Floor] [Incline]   | <-- Scroll orizzontale
 |                           |
 | 4x5 rep | 180s rest       |
 |                           |
 | [SALTA]     [AGGIUNGI]    |
 +---------------------------+
```

### Sistema di Scoring (0-100 punti)

| Criterio | Punti Max | Fonte Dati |
|----------|-----------|------------|
| Relevanza muscolare | 30 | `focus` + `muscoliSecondari` vs template |
| Tipo esercizio | 20 | `tipoEsercizio` (Compound/Isolation) |
| Attrezzatura | 15 | `attrezzatura` vs equipment in template |
| Difficolta match | 10 | `difficolta` vs `experienceLevel` utente |
| Varieta | 10 | `ExerciseHistory` - ultima esecuzione |

**Output:**
- Top 8-10 suggerimenti (invece di 5)
- Per ogni suggerimento: 3-4 alternative (score simile, stessa zona)
- Motivazione generata dal breakdown dello score

### Motivazioni Dettagliate

Ogni card mostra:

**Tecnico:**
- Tipo esercizio (Compound/Isolation) e muscoli attivati
- Pattern movimento e compatibilita zona
- Range rep naturale dell'esercizio

**Dati utente:**
- Percentuale zona negli ultimi 30 giorni
- Giorni dall'ultima esecuzione
- Compatibilita attrezzatura con template esistenti

---

## Implementazione Tecnica

### File da Modificare

```
lib/features/analytics/
  domain/
    entities/
      rep_zone_suggestion.dart        # Aggiungi alternatives + motivation + score
    services/
      rep_zone_suggestion_engine.dart # Nuovo scoring system
  presentation/
    widgets/
      rep_zone_optimization_sheet.dart  # Rimuovi mode selector
      rep_zone_suggestion_deck.dart     # Tap-to-expand cards
      rep_zone_suggestion_card.dart     # NUOVO: card espandibile
```

### File da Eliminare

```
lib/features/analytics/presentation/widgets/rep_zone_suggestion_list.dart
```

### Nuove Entita

```dart
class RepZoneSuggestion {
  // Esistenti
  final String exerciseId;
  final String exerciseName;
  final RepZone targetZone;
  final String targetTemplate;
  final String targetTemplateId;
  final int recommendedSets;
  final int recommendedReps;
  final int recommendedRestSeconds;
  final ExerciseDifficulty difficulty;
  final String equipment;
  final ExerciseCountingMode countingMode;

  // NUOVI
  final int score;                          // 0-100
  final ScoreBreakdown scoreBreakdown;      // Dettaglio punti
  final List<String> motivations;           // Lista motivi localizzati
  final List<AlternativeExercise> alternatives; // 3-4 alternative
}

class ScoreBreakdown {
  final int muscleRelevance;    // 0-30
  final int exerciseType;       // 0-20
  final int equipment;          // 0-15
  final int difficultyMatch;    // 0-10
  final int variety;            // 0-10

  int get total => muscleRelevance + exerciseType + equipment + difficultyMatch + variety;
}

class AlternativeExercise {
  final String exerciseId;
  final String exerciseName;
  final int score;
  final String shortReason; // "Stesso pattern, manubri"
}
```

### Localizzazioni Necessarie

```
// Nuove chiavi in app_en.arb / app_it.arb
optimizeTrainingDirect        // "Ecco i suggerimenti per bilanciare il tuo allenamento"
tapToExpand                   // "Tocca per dettagli"
alternativesCount             // "{count} alternative"
motivationTechnical           // "Tecnico"
motivationYourData            // "I tuoi dati"
scoreLabel                    // "Score: {score}/100"
compoundActivates             // "Compound - attiva {muscles}"
isolationTargets              // "Isolation - isola {muscle}"
zonePercentLast30Days         // "{percent}% {zone} negli ultimi 30 giorni"
notDoneSinceDays              // "Non fai questo esercizio da {days} giorni"
equipmentAlreadyOwned         // "Gia hai {equipment}"
naturalRepRange               // "Range rep naturale: {range}"
```

---

## Note

- Animazione Hero per espansione card (no flip)
- Swipe funziona sia su card compatta che espansa
- Alternative scrollabili orizzontalmente
- Score visibile solo in card espansa (non sovraccaricare UI)
