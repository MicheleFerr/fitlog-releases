# Onboarding Strategy 2025 - FitLog Pro

> **Basato su**: Ricerca UX 2025 da NN/Group, Appcues, UXCam, e best practices fitness app

---

## Principi Chiave

### 1. Progressive Disclosure
> "Introduce features gradually as the user navigates the app"

- **NON** mostrare tutto upfront
- Rivela funzionalità quando l'utente ne ha bisogno
- Riduci il cognitive load

### 2. Contextual Help
> "Provide guidance at the right moment"

- Tutorial contestuali > tutorial iniziali lunghi
- Tooltip quando servono
- Help on-demand

### 3. Time to Value
> "Users decide whether to stay within the first 20 seconds"

- **Target**: primo workout in < 60 secondi
- Mostra valore immediato
- Skip sempre disponibile

### 4. One Action Per Screen
> "One button, one decision, one goal"

- Ogni step del tutorial = 1 concetto
- Bottoni grandi per uso in movimento
- Niente distrazioni

### 5. Gamification
> "Small wins drive momentum"

- Celebra completamenti
- Badge per tutorial completati
- Streak di apprendimento (opzionale)

---

## Trigger Matrix

### Principio: "Just-in-Time Learning"

| Tour | Trigger | Condizioni | Rationale |
|------|---------|------------|-----------|
| **Home Tour** | App launch | `!completed && firstLaunch` | Orienta l'utente, mostra valore |
| **Workout Tutorial** | Start workout | `!completed && exercises == 0` | Momento di bisogno, utente motivato |
| **Exercise Search** | Open search | `!completed && fromWorkout` | Contestuale all'azione |
| **Analytics Tour** | Open analytics | `!completed && workouts >= 3` | Ha dati da vedere, contesto rilevante |
| **Timer Tour** | First timer start | `!completed && setCompleted` | Momento esatto di bisogno |
| **Template Tutorial** | Tap "Create Template" | `!completed` | Intento chiaro |
| **Advanced Techniques** | Tap exercise menu | `!completed && workouts >= 5` | Utente esperto pronto |

### Anti-Pattern da Evitare

❌ Mostrare tour al primo launch senza contesto
❌ Interrompere flusso critico (es. durante set)
❌ Tour lunghi (> 6 step)
❌ Nessuna opzione skip
❌ Tour che bloccano l'uso dell'app

---

## Tour Specifications

### 1. Home Tour (Esistente)
**Quando**: Primo launch dopo onboarding iniziale
**Durata**: 10 step (lungo, considerare riduzione)
**Goal**: Overview completa della home

**Miglioramenti suggeriti**:
- Ridurre a 5-6 step essenziali
- Offrire "Tour completo" vs "Tour rapido"

---

### 2. Workout Tutorial (Esistente)
**Quando**: Primo workout con 0 esercizi
**Durata**: 6 step
**Goal**: Completare primo esercizio

**Flow ottimale**:
1. "Aggiungi esercizio" → Tap FAB
2. [Utente cerca e aggiunge]
3. "Registra serie" → Tap set
4. [Utente inserisce dati]
5. "Completa" → Celebrazione!

---

### 3. Exercise Search Tutorial (Esistente)
**Quando**: Prima apertura search da workout
**Durata**: 5 step
**Goal**: Trovare e aggiungere esercizio

---

### 4. Analytics Tour (Implementato)
**Quando**: Prima visita analytics CON almeno 3 workout
**Durata**: 6 step
**Goal**: Capire come leggere i progressi

**Rationale**: Senza workout non ha senso mostrare analytics

---

### 5. Timer Tour (Da implementare)
**Quando**: Primo timer che parte dopo set completato
**Durata**: 4 step
**Goal**: Capire timer e Live Activities

**Steps**:
1. Timer automatico - "Il timer parte automaticamente!"
2. Durata personalizzabile - "Tieni premuto per cambiare"
3. Live Activity - "Vedi il timer anche a schermo bloccato"
4. Suono completamento - "Ti avvisiamo quando è ora"

**Condizioni trigger**:
```dart
trigger: setCompleted && !timerTourCompleted && timerStarted
```

---

### 6. Template Tutorial (Da implementare)
**Quando**: Tap su "Crea Template" o "Salva come Template"
**Durata**: 5 step
**Goal**: Creare primo template

**Steps**:
1. Nome template - "Dai un nome riconoscibile"
2. Aggiungi esercizi - "Costruisci la tua routine"
3. Configura default - "Imposta serie/rep di default"
4. Salva - "Pronto per il prossimo uso!"
5. Usa template - "Tap per iniziare subito"

**Condizioni trigger**:
```dart
trigger: (tapCreateTemplate || tapSaveAsTemplate) && !templateTutorialCompleted
```

---

## Onboarding Orchestrator

### Responsabilità
1. **Gestione conflitti** - Un solo tour attivo alla volta
2. **Priority queue** - Tour critici prima di quelli opzionali
3. **Stato globale** - Sincronizza completion across tours
4. **Analytics** - Traccia completion rates

### Priority Levels
```
P0 - Critici (bloccano uso): Workout Tutorial
P1 - Importanti (core features): Home Tour, Exercise Search
P2 - Utili (enhance experience): Analytics, Timer, Template
P3 - Opzionali (power users): Advanced Techniques
```

### State Machine
```
IDLE → QUEUED → ACTIVE → COMPLETED
                  ↓
               SKIPPED
```

---

## Metriche di Successo

| Metrica | Target | Attuale |
|---------|--------|---------|
| Home Tour Completion | > 70% | TBD |
| Workout Tutorial Completion | > 85% | TBD |
| Time to First Workout | < 60s | TBD |
| Skip Rate (tutti i tour) | < 25% | TBD |
| Day 1 Retention | > 40% | TBD |
| Day 7 Retention | > 25% | TBD |

---

## Implementazione Tecnica

### File Structure
```
lib/features/onboarding/
├── domain/
│   ├── entities/
│   │   └── onboarding_state.dart
│   └── services/
│       ├── onboarding_orchestrator.dart  # NEW
│       ├── home_tour_service.dart
│       ├── workout_tutorial_service.dart
│       ├── exercise_search_tutorial_service.dart
│       ├── analytics_tour_service.dart
│       ├── timer_tour_service.dart        # NEW
│       └── template_tutorial_service.dart # NEW
├── data/
│   └── repositories/
│       └── onboarding_repository.dart     # SharedPrefs wrapper
└── presentation/
    └── providers/
        └── onboarding_providers.dart      # Riverpod providers
```

### Provider Architecture
```dart
// Central orchestrator
final onboardingOrchestratorProvider =
    StateNotifierProvider<OnboardingOrchestrator, OnboardingState>(...);

// Individual tours
final homeTourProvider = ...
final workoutTutorialProvider = ...
// etc.

// Computed providers
final shouldShowHomeTourProvider = Provider<bool>((ref) {
  final orchestrator = ref.watch(onboardingOrchestratorProvider);
  final homeTour = ref.watch(homeTourProvider);
  return !homeTour.hasCompletedTour &&
         !orchestrator.hasActiveTour &&
         orchestrator.isFirstLaunch;
});
```

---

## References

- [NN/Group - Mobile App Onboarding](https://www.nngroup.com/articles/mobile-app-onboarding/)
- [Appcues - Mobile Onboarding Best Practices](https://www.appcues.com/blog/mobile-onboarding-best-practices)
- [UXCam - Top 10 Onboarding Examples](https://uxcam.com/blog/10-apps-with-great-user-onboarding/)
- [Dataconomy - Fitness App UX 2025](https://dataconomy.com/2025/11/11/best-ux-ui-practices-for-fitness-apps-retaining-and-re-engaging-users/)
