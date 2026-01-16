# Persona-Driven Decision Framework

**Trigger**: Automaticamente durante brainstorming, nuove feature, decisioni UX

---

## Workflow Obbligatorio

Per OGNI decisione su feature, UX, o modifica significativa:

### Step 1: Identifica l'Impatto

Leggi `docs/USER_PERSONAS.md` e valuta:

```
┌─────────────────────────────────────────────────────────────┐
│ PERSONA IMPACT ANALYSIS                                      │
├─────────────────────────────────────────────────────────────┤
│ Feature/Decisione: [descrizione]                            │
├──────────────┬──────────┬───────────────────────────────────┤
│ Persona      │ Impatto  │ Note                              │
├──────────────┼──────────┼───────────────────────────────────┤
│ Marco        │ +/0/-    │ [come lo aiuta o danneggia]       │
│ Chiara       │ +/0/-    │                                   │
│ Luca         │ +/0/-    │                                   │
│ Sofia        │ +/0/-    │                                   │
│ Roberto      │ +/0/-    │                                   │
├──────────────┴──────────┴───────────────────────────────────┤
│ VERDICT: [Procedi / Rivedi / Blocca]                        │
└─────────────────────────────────────────────────────────────┘
```

**Legenda Impatto:**
- `+++` = Feature chiave per questa persona
- `++` = Molto positivo
- `+` = Positivo
- `0` = Neutro
- `-` = Negativo (friction aggiunta)
- `--` = Molto negativo (potrebbe abbandonare)

### Step 2: Red Flags

**BLOCCA** se:
- Una persona primaria ha impatto `--`
- 3+ personas hanno impatto `-`
- Feature utile solo per 1 persona e danneggia le altre

**RIVEDI** se:
- Una persona primaria ha impatto `-`
- Feature ignora completamente 2+ personas primarie

### Step 3: Mitigazioni

Se impatto negativo, proponi mitigazioni:
- Può essere opt-in/opt-out?
- Può essere nascosta dietro Pro?
- Può essere semplificata per chi non la vuole?

---

## Quick Reference Personas

### Primarie (SEMPRE considerare)

| Persona | Core Need | Pain Point |
|---------|-----------|------------|
| **Marco** | Semplicità, guida | Confusione, troppi termini |
| **Chiara** | Velocità, flessibilità | Workout lunghi, setup complesso |
| **Luca** | Dati dettagliati, analytics | App troppo semplici |
| **Sofia** | Progressi visibili, estetica | Non vedere risultati |
| **Roberto** | Zero friction, integrazione | Troppi tap, complessità |

### Secondarie (considerare per feature specifiche)

| Persona | Quando considerare |
|---------|-------------------|
| **Andrea** (CrossFit) | Timer, WOD, varietà |
| **Giulia** (Wellness) | HealthKit, non-competitivo |
| **Davide** (Tech) | Export, widgets, automazione |
| **Martina** (Social) | Sharing, community |
| **Giuseppe** (Senior) | Accessibilità, semplicità |
| **Elena** (Competitiva) | Coach, periodizzazione |
| **Francesco** (Yo-Yo) | Re-onboarding, no shame |

---

## Esempi

### Esempio 1: "Aggiungiamo RPE obbligatorio per ogni set"

```
┌─────────────────────────────────────────────────────────────┐
│ PERSONA IMPACT ANALYSIS                                      │
├─────────────────────────────────────────────────────────────┤
│ Feature: RPE obbligatorio per ogni set                      │
├──────────────┬──────────┬───────────────────────────────────┤
│ Marco        │ --       │ Non sa cos'è RPE, confusione      │
│ Chiara       │ -        │ Un tap in più = friction          │
│ Luca         │ +++      │ Esattamente quello che vuole      │
│ Sofia        │ 0        │ Neutro, lo userebbe               │
│ Roberto      │ -        │ Più complessità = meno uso        │
├──────────────┴──────────┴───────────────────────────────────┤
│ VERDICT: RIVEDI - Marco ha --, problema serio               │
└─────────────────────────────────────────────────────────────┘

MITIGAZIONE: Rendere RPE opzionale, mostrare solo a chi lo abilita
nelle impostazioni o dopo X workout completati.
```

### Esempio 2: "Quick Start da ultimo workout"

```
┌─────────────────────────────────────────────────────────────┐
│ PERSONA IMPACT ANALYSIS                                      │
├─────────────────────────────────────────────────────────────┤
│ Feature: Button "Ripeti ultimo workout"                     │
├──────────────┬──────────┬───────────────────────────────────┤
│ Marco        │ ++       │ Non deve pensare, ottimo          │
│ Chiara       │ +++      │ Velocità massima, perfetto        │
│ Luca         │ +        │ Utile per deload weeks            │
│ Sofia        │ ++       │ Consistenza nella routine         │
│ Roberto      │ +++      │ Zero friction, ideale             │
├──────────────┴──────────┴───────────────────────────────────┤
│ VERDICT: PROCEDI - Impatto positivo su tutte le personas    │
└─────────────────────────────────────────────────────────────┘
```

---

## Automazione

Questo check deve essere eseguito:
1. **Automaticamente** durante brainstorming di nuove feature
2. **Su richiesta** con `/persona-check [feature]`
3. **Prima di ogni PR** per feature significative

Il formato tabellare è obbligatorio per tracciabilità.
