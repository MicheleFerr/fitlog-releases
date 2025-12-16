# Superset UX Redesign

**Data:** 2024-12-08
**Stato:** Approvato
**Autore:** Claude + Michele

---

## Problema

La creazione di superset ha troppa friction visiva:
1. Configurazione round troppo complessa (click "Add Round", poi configura ogni esercizio)
2. Scroll manuale per ogni round per configurare peso
3. Nessun modo veloce per creare superset da esercizi esistenti nel workout

## Soluzione

### Componenti

| Componente | Scopo |
|------------|-------|
| `SupersetConfigSheet` | Tabella compatta per configurare round (riusabile) |
| `SupersetLinkModal` | Quick-link da menu esercizio esistente |
| `SupersetBuilderWidget` | Refactor per usare ConfigSheet |

---

## Design: SupersetConfigSheet

Tabella compatta con:
- Colonna esercizi fissata (sempre visibile)
- Celle 48×48dp tappabili (Material Design touch target)
- Scroll orizzontale per 4+ round
- "Copia R1 → Tutti" per riempire rapidamente

```
┌──────────────────────────────────────────────────────┐
│  Rounds: [ - ]  3  [ + ]                            │
│                                                      │
│  ┌─────────────┬─────────┬─────────┬─────────┐      │
│  │             │   R1    │   R2    │   R3    │ →    │
│  ├─────────────┼─────────┼─────────┼─────────┤      │
│  │ Bench Press │ [80×10] │   ···   │   ···   │      │
│  ├─────────────┼─────────┼─────────┼─────────┤      │
│  │ Cable Fly   │ [15×12] │   ···   │   ···   │      │
│  └─────────────┴─────────┴─────────┴─────────┘      │
│                                                      │
│  [📋 R1 → Tutti]    [📈 Progressione...]            │
│                                                      │
│  Riposo dopo round: [  90s  ]                       │
└──────────────────────────────────────────────────────┘
```

### Interazione Cella

Tap su cella apre mini-picker:
- Peso con quick jumps (±2.5, ±5)
- Reps con presets (8, 10, 12, 15)
- "Applica a tutti i round" opzione

---

## Design: SupersetLinkModal

Accessibile da: Menu esercizio → "Crea Superset"

```
┌──────────────────────────────────────┐
│  🔗 Crea Superset                    │
│  con: [Nome esercizio corrente]      │
│                                       │
│  ┌───────────────┬──────────────┐    │
│  │ 📋 In Scheda  │  🔍 Dal DB   │    │
│  └───────────────┴──────────────┘    │
│                                       │
│  [Lista esercizi selezionabili]      │
│                                       │
│  Selezionati: N (min 2)              │
│  [   Continua → Configura   ]        │
└──────────────────────────────────────┘
```

### Flow

1. Esercizio corrente pre-selezionato (locked)
2. Tab "In Scheda": checkbox su altri esercizi workout
3. Tab "Dal DB": cerca e aggiungi nuovi
4. "Continua" → apre SupersetConfigSheet
5. Configura → Crea superset → Sostituisce esercizi originali

---

## Implementazione

### File da creare

1. `lib/features/workout/presentation/widgets/superset_config_sheet.dart`
2. `lib/features/workout/presentation/widgets/superset_link_modal.dart`
3. `lib/features/workout/presentation/widgets/superset_cell_picker.dart`

### File da modificare

1. `exercise_list_item_header.dart` - Aggiungere voce menu
2. `exercise_list_item_orchestrator.dart` - Handler per link modal
3. `superset_builder_widget.dart` - Usare ConfigSheet invece di UI custom

---

## Best Practices Applicate

Basato su ricerca UX:
- Touch targets 48×48dp (Material Design)
- Colonna fissata per tabelle mobile (NN/g)
- Riduzione data entry con "copia" e presets
- One action per screen (fitness app patterns)

**Fonti:**
- https://www.nngroup.com/articles/mobile-tables/
- https://www.smashingmagazine.com/2018/08/best-practices-for-mobile-form-design/
- https://stormotion.io/blog/fitness-app-ux/
