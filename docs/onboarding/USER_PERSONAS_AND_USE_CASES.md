# User Personas & Onboarding Use Cases

> **Scopo**: Definire le personas target e mappare gli use case per estendere l'onboarding a tutte le funzionalità necessarie.

---

## User Personas

### 1. Marco - Il Principiante Assoluto
**Profilo**: 28 anni, impiegato, mai fatto palestra seriamente
**Obiettivo**: Iniziare ad allenarsi con una guida strutturata
**Tech Level**: Medio (usa app quotidianamente)
**Pain Points**:
- Non sa quali esercizi fare
- Non conosce la terminologia (serie, ripetizioni, RPE)
- Si sente perso senza guida

**Cosa deve imparare**:
- [ ] Come funziona un allenamento (serie/ripetizioni)
- [ ] Come cercare e aggiungere esercizi
- [ ] Come registrare peso e ripetizioni
- [ ] Cos'è il timer di riposo e perché è importante
- [ ] Come usare i template predefiniti
- [ ] Come vedere i propri progressi

---

### 2. Laura - La Fitness Enthusiast
**Profilo**: 32 anni, 2 anni di palestra, passa da un'altra app
**Obiettivo**: Tracciare meglio i progressi e avere statistiche
**Tech Level**: Alto
**Pain Points**:
- Vuole importare i dati dalla vecchia app
- Cerca funzionalità avanzate (superset, drop set)
- Vuole statistiche dettagliate

**Cosa deve imparare**:
- [ ] Come importare dati da altre app
- [ ] Funzionalità avanzate (superset, drop set, rest-pause)
- [ ] Come creare template personalizzati
- [ ] Analytics e grafici dei progressi
- [ ] Come funzionano i PR e strength standards
- [ ] Stress Index e recovery insights

---

### 3. Alessandro - L'Atleta Avanzato
**Profilo**: 35 anni, 10+ anni di allenamento, compete
**Obiettivo**: Ottimizzare performance e periodizzazione
**Tech Level**: Alto
**Pain Points**:
- Vuole controllo totale sui dati
- Cerca integrazione con HealthKit
- Vuole export dati per analisi esterne

**Cosa deve imparare**:
- [ ] Integrazione Apple Health
- [ ] Export dati (GDPR)
- [ ] Stress Index per periodizzazione
- [ ] Recovery insight basato su sonno
- [ ] Predictive balance
- [ ] Custom exercises per esercizi specifici

---

### 4. Giulia - La Casual User
**Profilo**: 25 anni, va in palestra 2x/settimana
**Obiettivo**: Tenere traccia senza complicazioni
**Tech Level**: Medio-basso
**Pain Points**:
- Vuole semplicità
- Non vuole perdere tempo
- Usa solo funzionalità base

**Cosa deve imparare**:
- [ ] Quick start: iniziare workout velocemente
- [ ] Usare template esistenti
- [ ] Timer automatico
- [ ] Vedere streak e motivazione
- [ ] Live Activities per non aprire l'app

---

### 5. Roberto - Il Coach/PT
**Profilo**: 40 anni, personal trainer
**Obiettivo**: Usare l'app per i suoi clienti
**Tech Level**: Medio
**Pain Points**:
- Deve spiegare l'app ai clienti
- Vuole creare template per clienti
- Cerca funzionalità coach

**Cosa deve imparare**:
- [ ] Come creare template completi
- [ ] Funzionalità coach (se presente)
- [ ] Come condividere template
- [ ] Community features
- [ ] AI Coach per suggerimenti

---

## Onboarding Matrix

| Feature | Marco | Laura | Alessandro | Giulia | Roberto |
|---------|-------|-------|------------|--------|---------|
| **HOME SCREEN** |
| XP Progress | MUST | NICE | SKIP | NICE | SKIP |
| Activity Rings | NICE | MUST | MUST | SKIP | NICE |
| Start Workout | MUST | MUST | MUST | MUST | MUST |
| Templates Carousel | MUST | NICE | SKIP | MUST | MUST |
| Stress Prediction | SKIP | MUST | MUST | SKIP | NICE |
| Recovery Insight | SKIP | MUST | MUST | SKIP | NICE |
| **WORKOUT** |
| Add Exercise | MUST | MUST | MUST | MUST | MUST |
| Log Set | MUST | MUST | MUST | MUST | MUST |
| Rest Timer | MUST | MUST | MUST | NICE | MUST |
| Exercise Menu | NICE | MUST | MUST | SKIP | MUST |
| Reorder | SKIP | NICE | NICE | SKIP | MUST |
| Superset/DropSet | SKIP | MUST | MUST | SKIP | MUST |
| **EXERCISE SEARCH** |
| Search Bar | MUST | MUST | MUST | MUST | MUST |
| Filters | NICE | MUST | MUST | SKIP | MUST |
| Quick Filters | MUST | NICE | SKIP | MUST | NICE |
| **ADVANCED** |
| Analytics | SKIP | MUST | MUST | SKIP | NICE |
| PR Tracking | NICE | MUST | MUST | NICE | NICE |
| Strength Standards | SKIP | MUST | MUST | SKIP | NICE |
| Custom Exercises | SKIP | NICE | MUST | SKIP | MUST |
| Template Creation | SKIP | MUST | NICE | SKIP | MUST |
| **INTEGRATIONS** |
| Apple Health | SKIP | MUST | MUST | SKIP | SKIP |
| Data Export | SKIP | NICE | MUST | SKIP | SKIP |
| Data Import | SKIP | MUST | NICE | SKIP | SKIP |
| **SOCIAL** |
| Streak | NICE | NICE | SKIP | MUST | SKIP |
| Progress Photos | SKIP | MUST | NICE | SKIP | NICE |
| Community | SKIP | NICE | SKIP | SKIP | MUST |
| **PREMIUM** |
| AI Coach | NICE | NICE | NICE | SKIP | MUST |
| Live Activities | NICE | MUST | MUST | MUST | NICE |

---

## Onboarding Tours da Implementare

### Esistenti (3)
1. **Home Tour** - 10 step (generale)
2. **Workout Tutorial** - 6 step (core)
3. **Exercise Search Tutorial** - 5 step (core)

### Da Creare (Priorità Alta)

#### 4. Analytics Tour
**Target**: Laura, Alessandro
**Trigger**: Prima visita alla sezione Analytics
**Steps**:
1. Overview stats (totale workout, volume)
2. PR tracking e come funziona
3. Grafici progressi
4. Strength standards comparazione
5. Export dati

#### 5. Template Creation Tutorial
**Target**: Laura, Roberto
**Trigger**: Tap su "Crea Template"
**Steps**:
1. Nome e descrizione template
2. Aggiungere esercizi
3. Configurare serie/ripetizioni default
4. Salvare e condividere

#### 6. Timer & Live Activities Tour
**Target**: Tutti
**Trigger**: Primo utilizzo timer
**Steps**:
1. Timer automatico dopo set
2. Configurare durata default
3. Live Activities su lock screen
4. Personalizzare suoni

### Da Creare (Priorità Media)

#### 7. Advanced Techniques Tutorial
**Target**: Laura, Alessandro
**Trigger**: Menu esercizio > "Aggiungi tecnica"
**Steps**:
1. Cos'è un Superset
2. Come creare Drop Set
3. Rest-Pause technique
4. Giant Set

#### 8. Health Integration Tour
**Target**: Alessandro
**Trigger**: Settings > Health Sync
**Steps**:
1. Permessi Apple Health
2. Cosa viene sincronizzato
3. Come funziona la recovery insight
4. Privacy e dati

#### 9. Custom Exercise Tutorial
**Target**: Alessandro, Roberto
**Trigger**: Prima creazione esercizio custom
**Steps**:
1. Nome e descrizione
2. Gruppo muscolare
3. Attrezzatura richiesta
4. Video/immagine (opzionale)

### Da Creare (Priorità Bassa)

#### 10. Progress Photos Tour
**Target**: Laura
**Trigger**: Prima visita Progress Photos
**Steps**:
1. Come scattare foto consistenti
2. Confronto temporale
3. Privacy delle foto

#### 11. Data Import Tour
**Target**: Laura
**Trigger**: Settings > Import Data
**Steps**:
1. App supportate
2. Processo importazione
3. Verifica dati importati

#### 12. Streak & Gamification Tour
**Target**: Giulia, Marco
**Trigger**: Prima visita profilo
**Steps**:
1. Come funziona lo streak
2. Badge e achievements
3. XP e livelli

---

## Implementazione Suggerita

### Fase 1 - Core (Esistente)
- [x] Home Tour
- [x] Workout Tutorial
- [x] Exercise Search Tutorial

### Fase 2 - Essential Features
- [ ] Analytics Tour
- [ ] Template Creation Tutorial
- [ ] Timer & Live Activities Tour

### Fase 3 - Advanced Users
- [ ] Advanced Techniques Tutorial
- [ ] Health Integration Tour
- [ ] Custom Exercise Tutorial

### Fase 4 - Engagement
- [ ] Progress Photos Tour
- [ ] Data Import Tour
- [ ] Streak & Gamification Tour

---

## Trigger Points

| Tour | Trigger | Condizione |
|------|---------|------------|
| Home Tour | App start | `!hasCompletedHomeTour` |
| Workout Tutorial | Start workout | `!hasCompletedWorkoutTutorial` |
| Exercise Search | Open search | `!hasCompletedExerciseSearchTutorial` |
| Analytics Tour | Open analytics | `!hasCompletedAnalyticsTour && hasWorkouts >= 3` |
| Template Creation | Tap create | `!hasCompletedTemplatesTutorial` |
| Timer Tour | First timer use | `!hasCompletedTimerTour` |
| Advanced Techniques | Add technique | `!hasCompletedAdvancedTutorial` |
| Health Integration | Open health settings | `!hasCompletedHealthTour` |
| Custom Exercise | Create custom | `!hasCompletedCustomExerciseTour` |
| Progress Photos | Open photos | `!hasCompletedPhotosTour` |
| Import Tour | Open import | `!hasCompletedImportTour` |
| Streak Tour | View streak | `!hasCompletedStreakTour && streakDays >= 3` |

---

## Note Implementative

### Pattern da seguire
Ogni tour deve:
1. Usare `tutorial_coach_mark` package
2. Avere un `StateNotifierProvider` dedicato
3. Salvare stato completamento in `SharedPreferences`
4. Supportare scroll automatico ai target
5. Avere stringhe localizzate (EN + IT)
6. Permettere skip in qualsiasi momento

### File structure
```
lib/features/onboarding/domain/services/
├── home_tour_service.dart           ✅
├── workout_tutorial_service.dart    ✅
├── exercise_search_tutorial_service.dart ✅
├── analytics_tour_service.dart      TODO
├── template_tutorial_service.dart   TODO
├── timer_tour_service.dart          TODO
├── advanced_techniques_tutorial_service.dart TODO
├── health_integration_tour_service.dart TODO
├── custom_exercise_tutorial_service.dart TODO
├── progress_photos_tour_service.dart TODO
├── data_import_tour_service.dart    TODO
└── streak_tour_service.dart         TODO
```

---

## Metriche di Successo

| Metrica | Target |
|---------|--------|
| Completion rate Home Tour | > 70% |
| Completion rate Workout Tutorial | > 80% |
| User retention dopo onboarding | > 60% |
| First workout completato | < 5 minuti dall'install |
| Tutorial skipped | < 30% |
