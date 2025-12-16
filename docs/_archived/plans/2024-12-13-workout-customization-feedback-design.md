# Design: Feedback Migliorato Personalizzazione Workout

**Data:** 2024-12-13
**Status:** Approvato

---

## Problema Originale

Quando l'utente modifica toggle nel modal "Personalizza" durante una sessione workout, non riceve feedback immediato delle modifiche. Deve scrollare manualmente per verificare che i cambiamenti siano stati applicati.

---

## Soluzioni Approvate

### 1. Feedback alla Chiusura Modal

**Comportamento:**
- Toast alla chiusura che riassume le modifiche (es. "3 impostazioni modificate")
- Auto-scroll alla prima card esercizio (se presenti esercizi)
- Se 0 modifiche → nessun toast

**Implementazione:**
- Tracciare valori iniziali in `initState`
- Confrontare al close
- Usare `SnackBarService.showInfo()`
- Scroll con `ScrollController.animateTo(0)`

---

### 2. Toggle Non Collegati - Fix

#### A) `showExerciseNotes` - Note Esercizio

**Status:** Toggle esiste ma UI mancante

**Design:**
- Sezione note collassabile sotto header esercizio
- Due tipi: Routine Notes (persistenti) + Workout Notes (sessione)
- Espandibile con tap

**UI:**
```
┌─────────────────────────────────────┐
│ 🏋️ Squat                      ⋮   │
│ ├ 3/4 sets • 25kg × 10            │
│ └ 📝 "Focus gomiti, schiena dritta"│
│ [Set 1] [Set 2] [Set 3] [Set 4]   │
└─────────────────────────────────────┘
```

#### B) `plateCalculator` - Calcolatore Dischi

**Status:** Solo in quick_edit_overlay, non accessibile facilmente

**Opzioni considerate:**
1. ❌ Sopra tastiera (come Hevy) - troppo complesso
2. ✅ Icona calcolatrice nel campo peso
3. ✅ FAB flottante durante workout
4. ✅ Sezione espandibile nella card

**Decisione:** Da definire in implementazione

#### C) `setDurationTracking` → TUT

**Status:** Toggle confuso - NON traccia durata set, dovrebbe mostrare TUT

**Problema trovato:** I file JSON splittati (`assets/data/exercises/*.json`) non hanno il campo `tempoEsecuzione`

**Soluzione:**
1. Aggiungere `tempoEsecuzione` ai file splittati via script merge
2. Creare `TutDecoderService` per decodificare automaticamente
3. NON serve `tempoNote` - generato automaticamente

---

## TUT Decoder Service

### Pattern TUT Trovati

| Codice | Significato |
|--------|-------------|
| `2-1-2-0` | 2s discesa, 1s pausa, 2s salita |
| `2-0-1-0` | 2s discesa, esplosivo su |
| `3-1-1-0` | 3s discesa, 1s pausa, esplosivo |
| `EXP` | Movimento esplosivo |
| `ISO` | Isometrico |

### Formato

`X-Y-Z-W` dove:
- X = secondi fase eccentrica (discesa)
- Y = secondi pausa in basso
- Z = secondi fase concentrica (salita, ≤1 = esplosivo)
- W = secondi pausa in alto

### API

```dart
class TutDecoderService {
  static String decode(String tut);           // "2-1-2-0" → "2s discesa, 1s pausa..."
  static String decodeShort(String tut);      // "2-1-2-0" → "2↓ 1⏸ 2↑"
  static List<TutPhase> parsePhases(String);  // Per visualizzazione grafica
}
```

---

## Script Merge TUT

**Source:** `exercises_with_tut.json` (1087 esercizi con TUT)
**Target:** `assets/data/exercises/*.json`

**Logica:**
1. Carica source e tutti i target
2. Match per `id` esercizio
3. Copia solo `tempoEsecuzione` (no `tempoNote`)
4. Salva file aggiornati

---

## Azioni Implementative

1. [x] Design documento
2. [x] `TutDecoderService` in `lib/features/exercise_database/domain/services/`
3. [x] Script `merge_tut_data.dart` in `scripts/`
4. [x] Eseguire merge (81 esercizi aggiornati, matching per nome)
5. [x] Verificare chip TUT funzionante
6. [ ] Feedback modal (fase successiva)
7. [ ] Note esercizio (fase successiva)
