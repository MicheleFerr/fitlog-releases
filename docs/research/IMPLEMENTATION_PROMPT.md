# Prompt di Implementazione - Statistiche UX P0 + P1

> Copia e incolla questo prompt in una nuova sessione Claude Code per implementare tutti i miglioramenti critici e ad alto impatto.

---

## IL PROMPT

```
Devo implementare i miglioramenti UX critici (P0) e ad alto impatto (P1) per la sezione Statistiche di FitLog Pro.

## CONTESTO

Leggi PRIMA questi file per il contesto completo:
- docs/research/STATS_UX_IMPROVEMENT_PLAN.md (piano completo)
- docs/research/PERSONA_ANALYSIS.md (analisi personas)
- docs/research/UX_BEST_PRACTICES.md (best practices)
- docs/research/COMPETITOR_ANALYSIS.md (analisi competitor)
- CLAUDE.md (regole progetto)

## ARCHITETTURA ESISTENTE

La sezione Statistiche e in `lib/features/analytics/`:
- **analytics_screen.dart** (~1600 righe) - Pagina principale lista esercizi
  - `_QuickStatsSummary` - 4 summary cards (Streak, Volume, Weekly, PR)
  - `_SortFilterChips` - Filtri (Preferiti/Piu usati/Recenti)
  - `_ExerciseHistoryCard` - Card singolo esercizio con trend %
  - `ProInsightsBadge` - Badge PRO
- **exercise_detail_screen.dart** (~1233 righe) - Dettaglio con grafici
  - Period selector (Week/Month/3M/Year/All)
  - Quick Answer Banner (trend + %)
  - Stats Summary Box (PR, Avg Weight, Avg Reps, Avg RPE)
  - Grafici riordinabili (Syncfusion Charts)
- **exercise_correlations_sheet.dart** (~979 righe) - Modal correlazioni
  - Weight vs RPE, Volume vs RPE con r, r2
  - Data quality card
  - Trend section
- **Grafici**: `charts/weight_line_chart.dart`, `volume_bar_chart.dart`, `reps_line_chart.dart`, `rpe_gauge_widget.dart` (Syncfusion)
- **Provider**: `exerciseHistoryStreamProvider`, `exerciseMetricsProvider`, `exerciseAnalyticsProvider`, `trainingPatternProvider`
- **Services**: `correlation_calculator.dart`, `trend_analyzer.dart`, `one_rm_calculator.dart`
- **Empty state**: `enhanced_empty_state.dart` (shared)

## COSA IMPLEMENTARE

### P0.1 - Riprogettare Correlazioni (CRITICO)
**File**: `exercise_correlations_sheet.dart`

La pagina Correlazioni e la peggiore dell'app (media 2.2/10). Implementare:

1. **Soglia sessioni**: Se l'esercizio ha < 5 sessioni con RPE, nascondere completamente la sezione correlazioni e mostrare solo:
   ```
   "Stiamo raccogliendo dati per trovare pattern.
    Ancora X sessioni per i primi insight!"
   [Progress bar: Y/5 sessioni]
   ```

2. **5-10 sessioni**: Mostrare insight in linguaggio naturale semplificato:
   ```
   "Primi pattern emergenti - allena ancora per confermare"
   ```

3. **10+ sessioni**: Tradurre r/r2 in linguaggio naturale:
   - r > 0.7: "Quando aumenti il peso, il tuo sforzo percepito (RPE) tende a salire proporzionalmente. Questo e normale."
   - r 0.3-0.7: "C'e una relazione moderata tra peso e sforzo percepito."
   - r < 0.3: "Il tuo sforzo percepito non sembra collegato al peso. Potresti avere buona gestione dell'intensita."

4. **Toggle "Vedi dati tecnici"**: Per utenti avanzati, mostrare r, r2, scatter plot (attuale UI) dietro un ExpansionTile.

5. **Fix bug**: Il banner "2 sessioni in 9537 giorni" ha un calcolo sbagliato dei giorni. Verificare la logica di calcolo del timespan.

### P0.2 - Sostituire "+0%" con Messaggi Contestuali
**File**: `analytics_screen.dart` (widget `_ExerciseHistoryCard`)

Nella lista esercizi, il trend "+0%" verde e demoralizzante. Cambiare la logica:

| Condizione | Attuale | Nuovo Display |
|-----------|---------|---------------|
| 1 sola sessione | +0% verde | Badge "Nuovo!" in blu |
| 2+ sessioni, delta = 0 | +0% verde | "Stabile" in grigio neutro |
| 2+ sessioni, delta > 0 | +X% verde | "+X% ↑" verde con icona freccia su |
| 2+ sessioni, delta < 0 | -X% | "-X% ↓" arancio (context.colors.warning) con freccia giu |
| Nessuna sessione recente (>14gg) | +0% verde | "Da riprendere" grigio con icona orologio |

Usare `context.l10n` per tutti i testi. Usare `context.colors` per tutti i colori. Usare `AppIcons` per le icone.

### P1.1 - Summary in Linguaggio Naturale
**File**: `analytics_screen.dart` - Aggiungere SOPRA `_QuickStatsSummary`

Creare un nuovo widget `WeeklySummaryBanner` che mostra un riepilogo testuale:

```dart
// Varianti basate sui dati della settimana:
// Settimana forte: "Settimana fantastica! X allenamenti, Y nuovi PR. Volume in crescita del Z%."
// Settimana normale: "Buona settimana! X allenamenti completati. Continua cosi!"
// Settimana debole: "Settimana tranquilla. X allenamento completato. Ogni sessione conta!"
// Prima settimana: "Benvenuto nelle tue statistiche! Completa il primo allenamento per iniziare."
// Nessun dato: "Inizia ad allenarti per vedere i tuoi progressi qui!"
```

Design: Card con bordo sinistro colorato (verde/blu/grigio in base al tono), icona contestuale, testo 2-3 righe, tappabile per espandere dettagli.

Provider necessario: Creare `weeklySummaryProvider` che aggrega dati dalla settimana corrente (workouts count, PR count, volume delta vs settimana precedente).

### P1.2 - Progressive Disclosure 2 Livelli
**File**: `analytics_screen.dart` + nuovo provider

Implementare toggle "Vista Semplice / Vista Dettagliata":

1. **Creare** `analyticsViewModeProvider` (StateProvider<bool>, persisted in SharedPreferences/Hive)
   - `false` = Vista Semplice (default)
   - `true` = Vista Dettagliata

2. **Vista Semplice** (default):
   - WeeklySummaryBanner (P1.1)
   - QuickStatsSummary (cards attuali MA con delta - vedi P1.4)
   - Lista esercizi con sparkline (P1.3) e messaggi contestuali (P0.2)
   - NASCONDERE: ProInsightsBadge, filtri metrica avanzati in detail

3. **Vista Dettagliata**:
   - Tutto della vista semplice +
   - ProInsightsBadge visibile
   - Correlazioni nel detail (con linguaggio naturale - P0.1)
   - Tutti i filtri metrica (Volume/Peso/1RM/PxR)
   - Stats box completo con RPE

4. **Toggle**: Icona nell'AppBar (es. icona livelli/slider) che switcha tra le due viste. Animazione smooth.

5. **Persistenza**: Salvare la preferenza dell'utente.

### P1.3 - Sparklines nella Lista Esercizi
**File**: `analytics_screen.dart` (widget `_ExerciseHistoryCard`)

Aggiungere una sparkline (mini grafico trend) in ogni card esercizio:

```
[avatar] Nome Esercizio        [sparkline ~~~↗] 85kg  +5% >
         CHEST · 12 sessioni
```

1. **Widget Sparkline**: Creare `ExerciseSparkline` widget (~50x20 pixel) che usa Syncfusion `SfSparkLineChart`:
   - Dati: ultime 8-12 sessioni, metrica = peso massimo per sessione
   - Colore: verde se trend positivo, arancio se negativo, grigio se stabile
   - Nessun asse, nessuna label, solo la linea con area gradient sotto
   - Ultimo punto evidenziato con dot

2. **Dati**: Usare i dati gia disponibili in `ExerciseHistory.sessions` (le sessioni sono gia caricate per il trend %)

3. **Performance**: La sparkline deve essere leggera. Usare `RepaintBoundary` per isolare i repaint. Max 12 data points.

### P1.4 - Delta/Confronto nelle Summary Cards
**File**: `analytics_screen.dart` (widget `_QuickStatsSummary` e relative modal)

Le 4 summary cards devono mostrare il confronto con il periodo precedente:

**Card Serie/Streak**:
- Attuale: "1 Giorno"
- Nuovo: "1 Giorno" + sotto: "vs 3gg sett. scorsa" (se peggiorato, arancio)

**Card Volume**:
- Attuale: "+0%"
- Nuovo: "4.5t" (valore assoluto) + sotto: "↑ +8% vs sett. scorsa" (verde se positivo)

**Card Settimana**:
- Attuale: "3/5 allenam..."
- Nuovo: "3/5" + sotto: "Obiettivo: ✓" (verde) o "Mancano 2" (neutro)

**Card PR**:
- Attuale: "16 nuovi"
- Nuovo: "2 nuovi" (ultimo 7gg) + sotto: "Panca, Squat" (nomi esercizi PR)

Ogni card deve mostrare: VALORE PRINCIPALE (grande) + DELTA/CONFRONTO (piccolo sotto) + CONTESTO.

### P1.5 - Tooltip Educativi su Metriche
**File**: `exercise_detail_screen.dart` (Stats Summary Box) + widget condiviso

1. **Creare** widget `MetricTooltipIcon` - icona `?` circolare piccola (16px) accanto al nome della metrica.

2. **Tap**: Apre bottom sheet `MetricExplanationSheet` con:
   - Nome metrica in italiano semplice
   - Spiegazione 1-2 frasi
   - Esempio pratico
   - "Perche e importante"

3. **Contenuti** (da localizzare con context.l10n):

   **RPE** → "Quanto e stato difficile - Scala da 1 a 10 che misura il tuo sforzo. RPE 7 = potevi fare altre 3 reps. RPE 10 = impossibile fare di piu."

   **1RM** → "Il tuo massimale stimato - Il peso massimo che potresti sollevare per una singola ripetizione. Calcolato dalle tue serie recenti."

   **Volume** → "Quanto lavoro totale - Peso × Ripetizioni × Serie. Piu volume = piu stimolo muscolare."

   **Peso Medio** → "Media dei pesi usati - Il peso medio che usi in questo esercizio nelle tue sessioni recenti."

   **Reps Medie** → "Ripetizioni per serie - Quante ripetizioni fai in media per ogni serie di questo esercizio."

4. I tooltip sono gia parzialmente presenti in `exercise_detail_screen.dart` (Stats Summary Box ha icone `?`). Verificare lo stato attuale e migliorare il contenuto.

### P1.6 - Empty States Motivanti
**File**: Multipli - ovunque ci siano empty states

1. **Lista esercizi vuota** (`analytics_screen.dart` - `_EmptyStateView`):
   ```
   [Illustrazione]
   "Le tue statistiche appariranno qui"
   "Completa il primo allenamento per iniziare a tracciare i progressi!"
   [Bottone: Inizia Allenamento]
   ```

2. **Grafici senza dati** (`charts/*.dart`):
   ```
   [Icona grafico stilizzata]
   "Il tuo grafico di progressione"
   ████████░░░░ 1/3 sessioni
   "Completa ancora 2 sessioni per vedere il trend"
   ```
   Usare progress bar che mostra quante sessioni mancano per sbloccare il grafico (minimo 3).

3. **Correlazioni senza dati** (gia gestito in P0.1)

4. **Detail screen senza dati sufficienti**:
   Mostrare il layout completo con placeholder shimmer + messaggio motivante.

Per OGNI empty state:
- MAI lasciare spazi vuoti
- SEMPRE mostrare quante sessioni mancano per sbloccare
- SEMPRE avere una CTA azionabile
- Usare `EnhancedEmptyState` widget dove possibile

## REGOLE IMPORTANTI

1. **Localizzazione**: TUTTI i testi con `context.l10n`. Aggiornare i file .arb (EN + IT).
2. **Colori**: SOLO `context.colors.*` - MAI `Colors.*`
3. **Icone**: SOLO `AppIcons.*` - MAI `Icons.*`
4. **Loading**: `LoadingIndicator()` - MAI `CircularProgressIndicator()`
5. **NO const con context.l10n** - iOS build error
6. **Provider THIN, Service FAT** - logica nei services
7. **Syncfusion Charts** per tutti i nuovi grafici (non fl_chart)
8. **Test**: `flutter analyze` deve passare dopo ogni modifica
9. **Performance**: Niente I/O in loop, batch ops, singleton per manager

## ORDINE DI IMPLEMENTAZIONE

Implementa in questo ordine (dipendenze):

1. **P0.3** - Fix bug 9537 giorni (5 min, zero dipendenze)
2. **P0.2** - Messaggi contestuali +0% (foundation per P1.3)
3. **P1.5** - Tooltip educativi (indipendente, quick win)
4. **P1.4** - Delta summary cards (indipendente, quick win)
5. **P1.6** - Empty states motivanti (indipendente)
6. **P0.1** - Riprogettare correlazioni (medio)
7. **P1.1** - Summary linguaggio naturale (necessita provider)
8. **P1.3** - Sparklines lista esercizi (modifica ExerciseHistoryCard)
9. **P1.2** - Progressive disclosure (dipende da P1.1 e P1.3)

Per ogni step:
1. Leggi il file coinvolto
2. Implementa la modifica
3. Verifica con `flutter analyze`
4. Genera localizzazioni con `flutter gen-l10n` se hai aggiunto testi
5. Passa al prossimo

Usa il skill /brainstorm prima di implementare se hai dubbi sul design di un componente. Usa /persona-check per validare le scelte UX.
```

---

## NOTE PER L'UTILIZZO

1. **Copia tutto il testo tra i backtick** (\`\`\`) sopra
2. **Incolla in una nuova sessione** Claude Code
3. Claude leggera automaticamente i file di contesto e iniziera ad implementare
4. L'ordine di implementazione e ottimizzato per dipendenze
5. Tempo stimato: 2-4 sessioni di lavoro

## STIMA EFFORT PER TASK

| Task | File Principali | Righe Stimate | Complessita |
|------|----------------|---------------|-------------|
| P0.3 Fix bug | correlations_sheet | ~5 | Banale |
| P0.2 Messaggi +0% | analytics_screen | ~80 | Bassa |
| P1.5 Tooltip | exercise_detail_screen + nuovo widget | ~150 | Bassa |
| P1.4 Delta cards | analytics_screen + modal | ~120 | Bassa |
| P1.6 Empty states | multipli (4-5 file) | ~200 | Media |
| P0.1 Correlazioni | correlations_sheet | ~300 | Media |
| P1.1 Summary NL | analytics_screen + nuovo provider | ~250 | Media |
| P1.3 Sparklines | analytics_screen + nuovo widget | ~180 | Media |
| P1.2 Progressive | analytics_screen + provider | ~200 | Media-Alta |
| **TOTALE** | | **~1485 righe** | |
