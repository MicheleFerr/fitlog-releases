# Analisi Collezioni Firestore GymBro

## COLLEZIONI DEFINITE NELLE RULES VS UTILIZZO EFFETTIVO

### ✅ COLLEZIONI ATTIVE (Utilizzate nel codice di produzione)

1. **users** - ✅ ATTIVA
   - Usata in: `auth_service.dart`, `user_profile_provider.dart`, `firebase_workout_datasource.dart`
   - Sottocollezioni attive: `notifications`, `workouts`
   - Ruolo: Gestione profili utente e autenticazione

2. **exerciseActivities** - ✅ ATTIVA
   - Usata in: `exercise_activity_repository.dart`, `firebase_workout_datasource.dart`, più provider
   - Ruolo: Salvataggio storico esercizi completati
   - Utilizzo massivo in: home, progress, notifications

3. **user_achievements** - ✅ ATTIVA
   - Usata in: `achievement_xp_provider.dart`, `optimized_achievement_xp_provider.dart`
   - Ruolo: Sistema achievement e XP

4. **user_preferences** - ✅ ATTIVA
   - Usata in: `home_customization_provider.dart`
   - Ruolo: Preferenze personalizzazione UI

5. **community_contributions** - ✅ ATTIVA
   - Usata in: `community_repository.dart`, `exercise_data_provider.dart`
   - Ruolo: Sistema community per miglioramenti esercizi

6. **user_contribution_stats** - ✅ ATTIVA
   - Usata in: `community_repository.dart`, `community_initializer.dart`
   - Ruolo: Statistiche contributi community

7. **contribution_reports** - ✅ ATTIVA
   - Usata in: `community_repository.dart`
   - Ruolo: Segnalazioni contenuti community

8. **personalRecords** - ✅ ATTIVA
   - Usata in: `pr_tracker.dart`
   - Ruolo: Tracking record personali (1RM, ecc.)

9. **workoutMetrics** - ✅ ATTIVA
   - Usata in: `workout_analytics_repository_impl.dart`
   - Ruolo: Metriche analytics allenamenti

10. **workoutSummaries** - ✅ ATTIVA (creata dinamicamente)
    - Usata in: `firebase_workout_datasource.dart`
    - Ruolo: Riassunti allenamenti completati

### ⚠️ COLLEZIONI PROBABILMENTE LEGACY (In rules ma uso limitato/dubbioso)

1. **workouts** (root level) - ⚠️ LEGACY?
   - Regole presenti ma il codice usa principalmente `users/{userId}/workouts`
   - Possibile utilizzo solo in vecchie versioni

2. **workoutTemplates** (duplicata) - ⚠️ LEGACY
   - Definita 3 volte nelle rules con regole diverse
   - Uso limitato, potrebbero essere versioni legacy

3. **exercises** vs **esercizi** - ⚠️ LEGACY
   - Due collezioni simili, `esercizi` sembra legacy italiana
   - `exercises` più moderna e internazionale

4. **attivitaEsercizi** - ⚠️ LEGACY
   - Nome italiano, probabilmente sostituita da `exerciseActivities`

### 🚫 COLLEZIONI NON TROVATE NEL CODICE (Candidate per eliminazione)

1. **workout_templates** (snake_case) - 🚫 NON USATA
   - Definita nelle rules, non trovata nel codice

2. **exercise_reports** + **suggestions** - 🚫 NON USATA
   - Sistema segnalazioni con sottocollezione, non implementato

3. **coach_delegations** - 🚫 NON USATA
   - Sistema coach/atleta, non implementato nell'app attuale

4. **coachNotifications** - 🚫 NON USATA
   - Notifiche coach, non implementato

5. **athleteNotifications** - 🚫 NON USATA
   - Notifiche atleta, non implementato

6. **templateAssignments** - 🚫 NON USATA
   - Assegnazione template coach, non implementato

7. **sessionWorkouts** - 🚫 NON USATA
   - Sessioni workout, non implementato

8. **dropSetActivity**, **supersetActivity**, **restPauseActivity** - 🚫 NON USATA
   - Tecniche avanzate, non implementate nell'app attuale

9. **dropSetsActivity**, **supersetsActivity** - 🚫 LEGACY
   - Versioni plurali legacy, solo lettura

10. **userMassimali** + sottocollezione - 🚫 NON USATA
    - Sistema massimali, non implementato

11. **schede** - 🚫 NON USATA
    - Sistema schede personalizzate, non implementato

12. **settings** (senza sottocollezioni specifiche) - 🚫 PARZIALE
    - Regole generiche, uso specifico non chiaro

13. **rpeHistory** - 🚫 NON USATA
    - Storico RPE, non implementato

14. **weeklyCheckIns** - 🚫 NON USATA
    - Check-in settimanali, non implementato

15. **cardioSessions** - 🚫 NON USATA
    - Sessioni cardio, non implementato

16. **programmingState** - 🚫 NON USATA
    - Stato programmazione, non implementato

17. **timings** - 🚫 NON USATA
    - Timing performance, non implementato

18. **exerciseFeedback** - 🚫 NON USATA
    - Feedback esercizi, non implementato

19. **userFeedbackStats** - 🚫 NON USATA
    - Statistiche feedback, non implementato

20. **workoutFeedback** - 🚫 NON USATA
    - Feedback allenamenti, non implementato

21. **completedWorkouts** - 🚫 NON USATA (?)
    - Potrebbe essere sostituita da altre collezioni

22. **workoutHistory** - 🚫 NON USATA
    - Storico allenamenti, non implementato

23. **communityPrograms** - 🚫 NON USATA
    - Programmi community, non implementato

24. **programDownloads** - 🚫 NON USATA
    - Download programmi, non implementato

### 📊 TEST E UTILITY

- **test_exercises** - Solo per testing, può rimanere
- **timers** (in test) - Solo per integration test

## RACCOMANDAZIONI

### 🔴 SICURAMENTE ELIMINABILI (Alta priorità)
- coach_delegations
- coachNotifications  
- athleteNotifications
- templateAssignments
- sessionWorkouts
- dropSetActivity, supersetActivity, restPauseActivity
- dropSetsActivity, supersetsActivity (legacy)
- userMassimali + sottocollezione
- schede
- rpeHistory
- weeklyCheckIns  
- cardioSessions
- programmingState
- timings
- exerciseFeedback
- userFeedbackStats
- workoutFeedback
- communityPrograms + reviews
- programDownloads

### 🟡 DA VERIFICARE (Media priorità)
- exercise_reports + suggestions
- workouts (root level vs subcollection)
- workoutTemplates (duplicazioni)
- exercises vs esercizi
- attivitaEsercizi vs exerciseActivities
- completedWorkouts
- workoutHistory

### ✅ DA MANTENERE (Attive)
- users + sottocollezioni
- exerciseActivities
- user_achievements
- user_preferences
- community_contributions
- user_contribution_stats
- contribution_reports
- personalRecords
- workoutMetrics
- workoutSummaries

## STIMA RISPARMIO

**Collezioni eliminabili**: ~25 collezioni principali + sottocollezioni
**Benefici**:
- Riduzione complessità rules (~50% meno righe)
- Miglior performance (meno controlli sicurezza)  
- Riduzione superficie attacco sicurezza
- Maggiore chiarezza architetturale
- Manutenzione semplificata