---
active: true
iteration: 3
max_iterations: 0
completion_promise: null
started_at: "2026-02-03T14:27:01Z"
---

--prompt ONBOARDING SYSTEM OPTIMIZATION - Autonomous Multi-Task Analysis & Implementation

## CONTEXT
FitLog Pro fitness app con sistema onboarding complesso:
- Initial onboarding: 6 step (Welcome→Goal→Personal→Body→Experience→Frequency)
- Contextual tours: 8 tour types gestiti da OnboardingOrchestrator
- Progressive disclosure: 3 learning phases (Core/Discovery/Advanced)
- State management: Hive + SharedPreferences (21 HiveField)

## CRITICAL BUGS TO FIX (P0)
1. Rimuovere 'suggerimento del giorno' dall'onboarding iniziale
2. Fix tour 'add exercise' che si blocca quando si apre modal e riparte quando si chiude invece di continuare

## COMPREHENSIVE TASKS (Execute in Order)

### ITERATION 1: Bug Fixes + Initial Analysis
**Goal**: Fix critical bugs + understand current system
**Tasks**:
1. Fix bug suggerimento giorno:
   - Cerca in lib/features/onboarding/presentation/screens/initial/* e widgets/initial/steps/*
   - Rimuovi qualsiasi riferimento a workoutSuggestion/dailyTip
   - Verifica ARB files per stringhe da rimuovere
2. Fix bug tour add exercise:
   - Analizza lib/features/onboarding/domain/services/workout_tutorial_service.dart
   - Implementa persistenza tour state attraverso modal navigation
   - Aggiungi flag resumeAfterModal in OnboardingTourStep
3. Documenta findings in ITERATION_1_REPORT.md

### ITERATION 2: System Architecture Audit
**Goal**: Deep dive architettura + identificare inconsistenze
**Tasks**:
1. Audit OnboardingOrchestrator (lib/features/onboarding/domain/services/onboarding_orchestrator.dart):
   - Verificare progressive disclosure logic
   - Testare session step limit (max 10)
   - Analizzare cooldown e priority queue
2. Flow analysis initial onboarding:
   - Mappare tutti 6 step con dependencies
   - Identificare friction points
   - Verificare validazione e back navigation
3. Tour inventory completo:
   - Elencare tutti 8 tour con trigger conditions
   - Creare matrice sovrapposizioni/conflitti
   - Verificare GlobalKeys targets
4. Documenta findings in ITERATION_2_REPORT.md con diagrammi

### ITERATION 3: UX Research & Best Practices
**Goal**: Ricerca competitive + academic guidelines
**Tasks**:
1. Ricerca online (usa WebSearch):
   - 'mobile app onboarding best practices 2025'
   - 'fitness app onboarding user retention'
   - 'progressive disclosure mobile UX'
   - 'contextual onboarding vs upfront tutorial'
2. Analizza patterns da:
   - Nielsen Norman Group guidelines
   - Material Design onboarding
   - Apple HIG first launch experience
3. Sintetizza findings in ITERATION_3_BEST_PRACTICES.md:
   - Optimal step count (quantitative data)
   - Permission request timing
   - Progressive disclosure strategies
   - Anti-patterns da evitare

### ITERATION 4: Bug Hunt & Edge Cases
**Goal**: Trovare tutti bug nascosti + gestire edge cases
**Tasks**:
1. State management bugs:
   - Testare kill app mid-onboarding
   - Verificare Hive serialization tutti 21 field
   - Controllare race conditions in _loadState()
2. UI/UX bugs:
   - Verificare touch targets (min 44pt iOS)
   - Testare tastiera copre input
   - Controllare animazioni jank
3. Edge cases critici:
   - Permission denied (HealthKit, notifications)
   - Multi-device sync conflicts
   - Offline onboarding
   - Data recovery dopo errori
4. Documenta in ITERATION_4_BUGS.md con severity + reproduce steps

### ITERATION 5: Personas Impact Analysis
**Goal**: Analizzare onboarding da prospettiva ogni persona
**Tasks**:
1. Per ogni persona (Marco/Chiara/Luca/Sofia/Roberto):
   - Identificare friction points specifici
   - Testare time-to-value
   - Verificare terminologia accessibile
2. Analizzare trade-offs cross-persona
3. Proporre adaptive onboarding basato su experience level
4. Documenta in ITERATION_5_PERSONAS.md con impact matrix

### ITERATION 6: Security & Privacy Audit
**Goal**: GDPR compliance + secure data handling
**Tasks**:
1. Data collection transparency:
   - Verificare consent screens chiari
   - Controllare hasAcceptedLegalDisclaimer
   - Testare opt-out paths
2. Secure storage:
   - Verificare Hive encryption per PII
   - Audit Firestore security rules
   - Controllare log non contengono dati sensibili
3. Permission handling:
   - Verificare iOS Info.plist descriptions
   - Controllare granular HealthKit permissions
4. Documenta in ITERATION_6_SECURITY.md con compliance checklist

### ITERATION 7: Performance Optimization
**Goal**: <2s launch + 60fps + <100MB memory
**Tasks**:
1. Profile app launch to onboarding:
   - Misurare _loadState() duration
   - Ottimizzare Hive/SharedPreferences reads
   - Lazy load assets
2. Memory footprint:
   - Controllare memory leaks (PageController, GlobalKeys)
   - Ottimizzare image assets (WebP)
3. Run performance-check.sh:
   - .claude/scripts/performance-check.sh lib/features/onboarding/
   - Fix anti-patterns trovati
4. Documenta in ITERATION_7_PERFORMANCE.md con profiling data

### ITERATION 8: Implementation & Testing
**Goal**: Implementare tutti fix + comprehensive tests
**Tasks**:
1. Implementare P0 fixes da tutte iterations
2. Scrivere tests:
   - Unit tests OnboardingOrchestrator + OnboardingState
   - Widget tests per ogni step
   - Integration tests E2E con Patrol (se disponibile)
3. Localization:
   - Aggiungere stringhe mancanti app_en.arb + app_it.arb
   - Run flutter gen-l10n
   - Verificare no hardcoded strings
4. Code review con CLAUDE.md checklist
5. Documenta in ITERATION_8_IMPLEMENTATION.md

### ITERATION 9: Documentation & Finalization
**Goal**: Doc completa + production ready
**Tasks**:
1. Creare docs/ONBOARDING_SYSTEM.md:
   - Flow diagram completo
   - Tour inventory
   - Best practices implementation
   - Edge cases handling
   - Troubleshooting guide
2. Aggiornare docs/INDEX.md
3. Scrivere ADR per decisioni architetturali
4. Creare FINAL_SUMMARY.md con:
   - Tutti bug risolti
   - Improvements implementati
   - Metrics pre/post optimization
   - Recommended next steps

## SUCCESS CRITERIA
- ✅ Bug critici (1-2) risolti e testati
- ✅ No P0/P1 findings non risolti
- ✅ Test coverage >80%
- ✅ Performance: <2s launch, 60fps, <100MB
- ✅ Security/Privacy audit passa
- ✅ Documentazione completa

## EXECUTION RULES
1. Ogni iteration crea un report markdown dettagliato
2. Se trovi bug critici, documenta e procedi (no blocco)
3. Usa WebSearch per ricerca external best practices
4. Usa Read/Grep/Glob per analisi codebase
5. Quando implementi fix, rispetta regole CLAUDE.md
6. Esegui flutter analyze dopo modifiche
7. Crea commit checkpoint dopo ogni iteration
8. Se iterazione fallisce, documenta e passa a successiva

## OUTPUT STRUCTURE
Alla fine di ogni iteration, crea:
- ITERATION_N_REPORT.md con findings
- Commit con messaggio 'feat(onboarding): iteration N - <summary>'

IMPORTANT: Lavora autonomamente, non chiedere conferme tra iterations.
