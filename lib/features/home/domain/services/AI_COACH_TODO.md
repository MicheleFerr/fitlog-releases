# AI Coach - TODO & Improvements

## 🚨 STATO ATTUALE: DISABILITATO
L'AI Coach è stato temporaneamente disabilitato per problemi di accuratezza scientifica e sicurezza.

## ❌ PROBLEMI CRITICI IDENTIFICATI

### 1. Calcolo Volume Errato (CRITICO)
- **Problema**: Calcola serie per allenamento invece che per muscolo per settimana
- **Impatto**: Consigli potenzialmente dannosi (sovrallenamento)
- **Fix richiesto**: Implementare calcolo volume per gruppo muscolare settimanale

### 2. Testi Hardcoded (FIXATO PARZIALMENTE)
- **Problema**: Alcuni testi erano in inglese hardcoded
- **Status**: Fixato in `_analyzeFormWarnings`
- **TODO**: Verificare tutto il codice per altri testi hardcoded

### 3. Manca Differenziazione per Esperienza
- **Problema**: Stessi consigli per principianti e avanzati
- **Impatto**: Consigli inappropriati per il livello
- **Fix richiesto**: Implementare `TrainingAge` detection

### 4. Categorizzazione Esercizi Primitiva
- **Problema**: Usa string matching invece del database esercizi
- **Fix richiesto**: Integrare con `assets/data/exercises.json`

## ✅ IMPLEMENTAZIONI RICHIESTE PER RIATTIVAZIONE

### TIER 1: FIX MINIMI (Obbligatori)
- [ ] Ricalcolare volume per muscolo per settimana
- [ ] Usare database esercizi esistente
- [ ] Aggiungere training age detection basico
- [ ] Migliorare recovery patterns (distinguere gruppi muscolari)

### TIER 2: MIGLIORAMENTI (Consigliati)
- [ ] Implementare MEV/MAV/MRV (Minimum/Maximum Volume landmarks)
- [ ] Aggiungere periodizzazione awareness
- [ ] Considerare RPE/intensità
- [ ] Deload detection e raccomandazioni
- [ ] Movement pattern analysis (push/pull/legs)

### TIER 3: FEATURES AVANZATE (Opzionali)
- [ ] Injury risk assessment
- [ ] Nutrition context integration
- [ ] Exercise-specific progression strategies
- [ ] Personalized recovery recommendations
- [ ] Integration with wearables data

## 📊 IMPLEMENTAZIONE CORRETTA DEL VOLUME

```dart
// ESEMPIO DI CALCOLO CORRETTO
Map<String, int> calculateWeeklyVolumePerMuscle(List<ExerciseActivity> activities) {
  final weekActivities = activities.where((a) =>
    a.createdAt.isAfter(DateTime.now().subtract(Duration(days: 7)))
  );

  final muscleVolume = <String, int>{};
  for (final activity in weekActivities) {
    // Use exercise database to get muscle groups
    final muscles = getTargetedMuscles(activity.exerciseName);
    for (final muscle in muscles) {
      muscleVolume[muscle] = (muscleVolume[muscle] ?? 0) + activity.sets.length;
    }
  }
  return muscleVolume;
}

// VOLUME GUIDELINES CORRETTE
// Principiante: 10-15 sets/muscolo/settimana
// Intermedio: 15-20 sets/muscolo/settimana
// Avanzato: 20-25+ sets/muscolo/settimana
```

## 🎯 TRAINING AGE DETECTION

```dart
enum TrainingAge { beginner, intermediate, advanced }

TrainingAge detectTrainingAge(List<ExerciseActivity> activities) {
  final totalDays = // calcola giorni totali di training
  final avgFrequency = // calcola frequenza media
  final strengthProgress = // analizza progressi di forza

  if (totalDays < 365) return TrainingAge.beginner;
  if (totalDays < 1095) return TrainingAge.intermediate;
  return TrainingAge.advanced;
}
```

## 🔧 INTEGRAZIONE DATABASE ESERCIZI

```dart
// Invece di string matching, usare:
final exerciseData = await loadExerciseDatabase();
final exercise = exerciseData.findByName(activityName);
final targetMuscles = exercise.primaryMuscles + exercise.secondaryMuscles;
```

## 📝 NOTE PER GLI SVILUPPATORI

1. **Prima di riattivare**: Implementare almeno tutti i fix TIER 1
2. **Testing richiesto**: Testare con profili principiante/intermedio/avanzato
3. **Peer review**: Far revisionare da esperto fitness prima del rilascio
4. **Documentazione**: Aggiornare docs con spiegazione algoritmi
5. **Disclaimer legale**: Mantenere sempre il disclaimer visibile

## 🚀 QUANDO RIATTIVARE

L'AI Coach può essere riattivato quando:
1. ✅ Volume calcolato per muscolo per settimana
2. ✅ Training age detection implementato
3. ✅ Database esercizi integrato
4. ✅ Test con almeno 10 profili diversi
5. ✅ Review da esperto fitness completata

## 📞 CONTATTI

Per domande sull'implementazione:
- Consultare l'esperto fitness del team
- Riferirsi alla letteratura scientifica (Brad Schoenfeld, Mike Israetel)
- Testare con utenti reali prima del rilascio

---
Ultimo aggiornamento: 2025-09-29
Status: DISABILITATO - In attesa di fix scientifici