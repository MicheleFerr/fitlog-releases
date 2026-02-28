# Watch Companion Mockup v2 (3 schermate)

Obiettivo: ridurre tap e carico cognitivo, mantenendo modifiche set veloci durante il workout.

## Flusso

1. **Workout (default)**: azione principale `Complete`, con edit rapido in-place.
2. **Rest**: timer e azioni immediate (`Resume` / `Skip`).
3. **Stats**: metriche e uscita workout.

---

## Screen 1 - Workout (Default)

```text
┌──────────────────────────┐
│ ♥ 132                    │
│ Bench Press              │
│ Set 3/5 ▾                │
│                          │
│ 80 × 8-10                │
│ tap to edit              │
│                          │
│            ✅            │
└──────────────────────────┘
```

### Interazioni
- Tap `Set 3/5 ▾` -> apre **Set Picker** (1 tap).
- Tap `80 × 8-10` -> apre **Quick Edit** (1 tap).
- Tap `✅` -> completa serie (0 frizione).

### Regole UX
- `Set X/Y` deve essere sempre visibile (evita navigazione extra).
- Hint piccolo e costante (`tap to edit`) per ridurre ambiguita'.
- CTA primaria unica (check verde) per evitare conflitti decisionali.

---

## Modal - Set Picker

```text
┌──────────────────────────┐
│ Select Set               │
│ ○ Set 1                  │
│ ○ Set 2                  │
│ ● Set 3 (current)        │
│ ○ Set 4                  │
│ ○ Set 5                  │
│ [Cancel]        [Go]     │
└──────────────────────────┘
```

### Interazioni
- Selezione + `Go` -> `jumpToSet(setNumber)`.
- `Cancel` chiude senza side effects.

---

## Modal - Quick Edit

```text
┌──────────────────────────┐
│ Quick Edit               │
│ Weight   80.0 kg         │
│ Reps     8-10            │
│ [Cancel]      [Apply]    │
└──────────────────────────┘
```

### Interazioni
- `Apply` salva target set corrente.
- Chiusura rapida e ritorno su Workout screen.

---

## Screen 2 - Rest

```text
┌──────────────────────────┐
│ REST                     │
│ 01:25                    │
│ Next: 82.5kg × 8         │
│                          │
│ [Skip]   (or) [Resume]   │
└──────────────────────────┘
```

### Interazioni
- Stato normale: `Skip` visibile.
- Stato paused: `Resume` primario + `Skip` secondario.

---

## Screen 3 - Stats

```text
┌──────────────────────────┐
│ HR 132   Zone 3          │
│ kcal 210   time 24m      │
│ sets 9                   │
│                          │
│ [End Workout]            │
└──────────────────────────┘
```

### Interazioni
- Unica azione distruttiva: `End Workout` con conferma successiva.

---

## Note di validazione rapida (test in mano)

Scenario base da testare in 60 secondi:
1. Apri workout, cambia set, modifica reps, completa serie.
2. Vai in rest, pausa/riprendi, poi skip.
3. Apri stats, verifica leggibilita' numeri e distanza tap target.

KPI pratici:
- Tap per `change set`: da ~3-4 a **1-2**.
- Tempo medio per `change set + edit reps`: target < **6s**.
- Errori di navigazione (swipe involontari): target in riduzione netta.
