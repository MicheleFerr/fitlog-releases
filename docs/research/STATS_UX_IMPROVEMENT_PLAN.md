# Piano di Miglioramento UX - Sezione Statistiche FitLog Pro

> **Data**: 2026-02-12
> **Sintesi di**: Analisi Competitor + Best Practices UX + Analisi Personas
> **Reports fonte**: [COMPETITOR_ANALYSIS.md](COMPETITOR_ANALYSIS.md) | [UX_BEST_PRACTICES.md](UX_BEST_PRACTICES.md) | [PERSONA_ANALYSIS.md](PERSONA_ANALYSIS.md)

---

## Executive Summary

La sezione Statistiche di FitLog ha **fondamenta solide** (grafici riordinabili, correlazioni uniche, Pro Insights) ma soffre di **3 problemi strutturali** che impattano tutte le personas:

1. **Manca un "Come sto andando?" immediato** - La domanda universale non trova risposta in <5 secondi
2. **Complessita esposta senza filtro** - Terminologia tecnica e correlazioni statistiche visibili a tutti
3. **Nulla da condividere** - Zero viralita, zero export per trainer, zero celebrazioni memorabili

**Stato vs competitor**: FitLog e AVANTI su analisi avanzata (correlazioni, plateau detection, muscle balance) ma INDIETRO su engagement, sharing e accessibilita.

---

## 1. Gap Analysis Consolidata

### Dove FitLog e GIA AVANTI (Difendere)

| Vantaggio | Competitor piu vicino | Note |
|-----------|----------------------|------|
| Correlazioni (Peso/Volume vs RPE) | Nessuno | Unico nel settore - va migliorato, non rimosso |
| Plateau Detection | Nessuno | Feature sofisticata, va resa piu visibile |
| Muscle Balance Analysis | JEFIT (parziale) | Analisi bilanciamento avanzata |
| Rep Zone Suggestions | Nessuno | Suggerimenti zona rep unici |
| Grafici riordinabili D&D | Nessuno | Personalizzazione rara |
| Training Pattern Detection | Nessuno | Pattern analysis avanzata |
| Neglected Muscle Detector | JEFIT/Fitbod (parziali) | Feature differenziante |

### Dove FitLog e INDIETRO (Colmare)

| Gap | Leader | Impatto | Sorgente |
|-----|--------|---------|----------|
| **Shareable Stats Cards** | Hevy | Viralita organica, retention | Competitor |
| **Live PR Notification** | Hevy/Strong | Dopamina in-workout | Competitor |
| **Monthly Report** | Hevy | Riflessione periodica | Competitor |
| **Strength Score (0-100)** | Fitbod | Metrica sintetica motivante | Competitor |
| **Summary in linguaggio naturale** | - | Risposta universale "Come va?" | Personas (5/5) |
| **Progressive disclosure** | - | Riduce intimidazione | Best Practices + Personas |
| **Empty states motivanti** | Best practice | Retention primi 7 giorni | Best Practices |
| **Sparklines nella lista** | Best practice | Glanceability | Best Practices |
| **Confronto periodo-vs-periodo** | Nessuno (opportunita!) | Visualizzare progresso | Competitor + Personas |

### Opportunita Uniche (Nessun competitor le fa bene)

1. **Confronto periodi esplicito** - Nessun competitor offre overlay "Mese X vs Mese Y"
2. **AI Correlazioni in linguaggio naturale** - Nessuno traduce r/r2 in frasi comprensibili
3. **Progressive disclosure adattiva** - Nessuno adatta automaticamente la complessita all'utente

---

## 2. Piano d'Azione Prioritizzato

### Legenda Priorita

| Tag | Significato |
|-----|-------------|
| **P0** | Critico - Impatta negativamente l'esperienza attuale |
| **P1** | Alto - Miglioramento significativo, alto ROI |
| **P2** | Medio - Nice-to-have con buon impatto |
| **P3** | Basso - Polish e power features |

---

### P0 - CRITICAL (Risolvere subito)

#### P0.1 - Riprogettare la Pagina Correlazioni
**Score**: Personas -6/13 (peggior feature) | 4/5 personas negative
**Effort**: Medio | **Impatto**: Eliminare il peggior detractor

**Problema attuale**:
- "r=0.00, r2=0%" incomprensibile per Marco, Chiara, Sofia, Roberto
- "2 sessioni in 9537 giorni" - bug/dato assurdo nel banner
- Pagina con media 2.2/10 tra le personas

**Soluzione**:
```
SE sessioni < 5:
  Nascondere completamente la sezione Correlazioni

SE sessioni 5-10:
  Mostrare: "Stiamo raccogliendo dati per trovare pattern nel tuo allenamento.
             Ancora X sessioni per i primi insight!"
  [Progress bar: 7/10 sessioni]

SE sessioni > 10:
  Mostrare insight in linguaggio naturale:
  "Quando aumenti il peso, il tuo sforzo percepito (RPE) tende a salire
   proporzionalmente. Questo e normale e indica che stai dosando bene."

  [Link "Vedi dati tecnici" per Luca] -> r, r2, scatter plot
```

**File coinvolti**: Correlazioni modal/sheet, logica soglia sessioni

---

#### P0.2 - Sostituire "+0%" con Messaggi Contestuali
**Score**: Personas 3/5 negative | Best Practices: anti-pattern empty state
**Effort**: Basso | **Impatto**: Eliminare demoralizzazione lista esercizi

**Problema attuale**: Tutti gli esercizi nella lista mostrano "+0%" in verde, che e:
- Demoralizzante per principianti (Marco: "non miglioro")
- Confuso (verde = positivo? Ma e 0%)
- Inutile per chi ha pochi dati

**Soluzione**:

| Condizione | Attuale | Nuovo |
|-----------|---------|-------|
| 1 sessione | +0% verde | "Nuovo!" badge |
| 2 sessioni, stabile | +0% verde | "Stabile" grigio neutro |
| 2 sessioni, migliorato | +X% verde | "+X%" verde con freccia su |
| 2 sessioni, peggiorato | -X% | "-X%" arancio con freccia giu |
| Nessuna recente (>2 sett) | +0% verde | "Da riprendere" grigio |

**File coinvolti**: Widget lista esercizi, provider calcolo trend

---

#### P0.3 - Fixare "2 sessioni in 9537 giorni"
**Effort**: Bassissimo | **Impatto**: Credibilita

Il banner rosso mostra "2 sessioni in 9537 giorni" - chiaramente un bug di calcolo (9537 giorni = ~26 anni). Da fixare immediatamente.

---

### P1 - HIGH (Miglioramenti ad alto impatto)

#### P1.1 - Summary Intelligente in Linguaggio Naturale
**Score**: Personas 5/5 | Best Practices: glanceability | Competitor gap
**Effort**: Medio | **Impatto**: Risponde alla domanda universale

**Descrizione**: Blocco testuale dinamico in cima alla pagina Lista Statistiche (P1) che risponde a "Come sto andando?"

**Design**:
```
┌─────────────────────────────────────────────────┐
│  Riepilogo Settimana                     [>]    │
│                                                 │
│  Settimana positiva! 3 allenamenti su 5,       │
│  2 nuovi record personali.                      │
│  Volume in crescita del 8%.                     │
│                                                 │
│  Continua cosi! 💪                              │
└─────────────────────────────────────────────────┘
```

**Varianti per contesto**:
- Settimana forte: tono celebrativo + highlight PR
- Settimana normale: tono incoraggiante + prossimo obiettivo
- Settimana debole: tono supportivo + suggerimento leggero
- Prima settimana: onboarding + guida

**Personas**:
- Marco: Capisce senza terminologia
- Chiara: Risposta in 2 secondi
- Luca: Header utile prima di approfondire
- Sofia: Frase motivante da screenshottare
- Roberto: Executive summary

---

#### P1.2 - Progressive Disclosure a 2 Livelli
**Score**: Personas 4/5 | Best Practices: NN/g, progressive disclosure
**Effort**: Medio-Alto | **Impatto**: Risolve conflitto semplicita vs profondita

**Vista Semplice (Default)**:
- Summary testuale (P1.1)
- 3-4 summary cards essenziali con delta vs periodo precedente
- Lista esercizi con sparkline + trend emoji (freccia su/giu/stabile)
- Banner progresso per esercizi migliorati

**Vista Dettagliata (Toggle)**:
- Tutto cio che c'e nella vista semplice +
- Pro Insights espanso
- Metriche complete (1RM, RPE, Volume, PxR)
- Correlazioni (in linguaggio naturale)
- Grafici interattivi avanzati
- Filtri granulari

**Implementazione**: Toggle in header "Semplice | Dettagliato", preferenza salvata per utente. La ricerca NN/g conferma: max 2 livelli di disclosure.

---

#### P1.3 - Sparklines nella Lista Esercizi
**Score**: Best Practices top 1 | Competitor: nessuno lo fa cosi
**Effort**: Medio | **Impatto**: Glanceability +300%

**Design**:
```
┌──────────────────────────────────────────────────┐
│ [icon] Panca Piana          [~~~↗] 85kg  +5%  > │
│        CHEST · 12 sessioni                       │
├──────────────────────────────────────────────────┤
│ [icon] Squat                [~~~↗] 120kg +2%  > │
│        LEGS · 8 sessioni                         │
├──────────────────────────────────────────────────┤
│ [icon] Stacco               [~~~↘] 140kg -1%  > │
│        BACK · 6 sessioni                         │
└──────────────────────────────────────────────────┘
```

La sparkline mostra trend ultime 8-12 sessioni. L'utente vede immediatamente se il trend e positivo/negativo/stabile senza aprire il dettaglio.

---

#### P1.4 - Delta/Confronto nelle Summary Cards
**Score**: Best Practices: KPI cards | Competitor: Hevy/Fitbod
**Effort**: Basso | **Impatto**: Contesto temporale immediato

**Attuale**:
```
Serie: 1 Giorno | Volume: +0% | Settimana: 3/5 | PR: 16 nuovi
```

**Proposto**:
```
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Serie         │ │ Volume       │ │ Settimana    │ │ PR (7gg)     │
│ 24  ↑12%     │ │ 4.5t ↑8%    │ │ 3/5 ✓       │ │ 2 nuovi 🏆  │
│ vs sett.scorsa│ │ vs sett.scorsa│ │ obiettivo OK│ │ Panca, Squat │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

Ogni card mostra: valore + delta + periodo di confronto. Tappabile per drill-down.

---

#### P1.5 - Tooltip Educativi su Metriche
**Score**: Personas 3/5 | Best Practices: onboarding +50% retention
**Effort**: Basso | **Impatto**: Riduce barrier-to-entry

Icona `?` accanto a ogni termine tecnico. Tap apre bottom sheet con:
- Nome metrica in italiano semplice
- Spiegazione 1-2 frasi
- Esempio pratico
- "Perche e importante per te"

**Esempio RPE**:
> **RPE - Quanto e stato difficile**
> Scala da 1 a 10: quanto ti sei sforzato.
> RPE 7 = "Potevo fare altre 3 ripetizioni"
> RPE 10 = "Non potevo fare neanche una in piu"

---

#### P1.6 - Empty States Motivanti
**Score**: Best Practices top 2 | Competitor: Hevy/Fitbod
**Effort**: Basso-Medio | **Impatto**: Retention primi 7 giorni

Per ogni sezione con dati insufficienti:

```
┌─────────────────────────────────────────────────┐
│  [Illustrazione grafico che si costruisce]      │
│                                                 │
│  "Il tuo grafico di progressione apparira qui"  │
│                                                 │
│  ████████░░░░ 3/5 allenamenti                   │
│  Completa ancora 2 sessioni per vedere          │
│  il trend di questo esercizio.                  │
│                                                 │
│  [Inizia allenamento]                           │
└─────────────────────────────────────────────────┘
```

**Regole**:
- MAI lasciare spazi vuoti
- MAI mostrare grafici con solo assi e zero dati
- SEMPRE progress bar verso sblocco
- SEMPRE CTA azionabile

---

### P2 - MEDIUM (Nice-to-have ad alto ROI)

#### P2.1 - Shareable Stats Cards
**Source**: Competitor (Hevy) | Personas 5/5
**Effort**: Alto | **Impatto**: Viralita organica, unica feature con potenziale marketing gratuito

3 template:
1. **"Celebra"** (Sofia/Marco): PR + trend + colori vivaci, formato Instagram Story
2. **"Report"** (Roberto/Luca): tabella esercizi + grafici, formato PDF/WhatsApp
3. **"Milestone"** (tutti): "100 allenamenti!", formato social

**Feature chiave**:
- Opzione "Solo progressi %" (non peso assoluto) per privacy di Marco
- Sfondi personalizzabili (chiaro/scuro/trasparente)
- Branding FitLog watermark leggero

---

#### P2.2 - Celebrazione PR Animata
**Source**: Best Practices + Competitor (Hevy)
**Effort**: Basso-Medio | **Impatto**: Dopamina e engagement

Quando l'utente visualizza un nuovo PR nella sezione stats:
- Micro-animazione confetti/glow sulla card
- Badge dorato accanto all'esercizio nella lista
- Counter animato (count-up) sul nuovo valore
- Haptic feedback

In-workout (Live PR Notification - futuro):
- Banner animato "Nuovo Record!" quando completa un set che supera il PR
- Haptic feedback
- Opzione share immediata

---

#### P2.3 - Confronto Periodo-vs-Periodo
**Source**: Competitor (gap - nessuno lo fa bene) | Personas 4/5
**Effort**: Medio | **Impatto**: Differenziazione unica

Overlay su grafici: "Questo mese vs mese scorso"
- Linea solida = periodo corrente
- Linea tratteggiata = periodo di confronto
- Delta evidenziato con area colorata
- Selector: Sett vs sett / Mese vs mese / Custom

---

#### P2.4 - Grafici Interattivi
**Source**: Best Practices + Personas (Luca)
**Effort**: Medio | **Impatto**: Profondita per power users

- **Tap su datapoint**: tooltip con data + valore + contesto
- **Long press**: confronto tra 2 punti
- **Gradient fill** sotto la curva (piu bello)
- **Skeleton loading** durante caricamento

---

#### P2.5 - Heatmap Consistenza Allenamento
**Source**: Competitor (Hevy monthly report) | Best Practices
**Effort**: Medio | **Impatto**: Motivazione visiva per consistenza

Calendario heatmap stile GitHub:
- Colore piu intenso = piu volume quel giorno
- Vista mensile nella dashboard
- Vista annuale nel profilo/stats
- Particolarmente motivante per streaks

---

#### P2.6 - Monthly Report Automatico
**Source**: Competitor (Hevy) | Personas 4/5
**Effort**: Medio-Alto | **Impatto**: Riflessione periodica + retention

Report auto a inizio mese:
- Calendario heatmap del mese
- Volume totale + confronto vs mese precedente
- Lista PR raggiunti
- Top 3 esercizi piu eseguiti
- Distribuzione muscolare
- Opzione share (collegata a P2.1)

---

### P3 - LOW (Polish e power features)

| # | Feature | Effort | Source |
|---|---------|--------|--------|
| P3.1 | **Strength Score sintetico 0-100** (ispirato Fitbod) | Alto | Competitor |
| P3.2 | **Export CSV/PDF** per analisi esterna e trainer | Medio | Personas (Luca, Roberto) |
| P3.3 | **Metriche avanzate opzionali** (e1RM, tonnage, INOL) | Medio | Personas (Luca) |
| P3.4 | **Year in Review** - recap annuale condivisibile | Medio | Competitor (JEFIT) |
| P3.5 | **Widget iOS** con stats rapide | Medio | Personas (Roberto) |
| P3.6 | **Weekly Digest push notification** | Medio | Personas (Chiara, Roberto) |
| P3.7 | **Seasonal Best** - PR per anno/stagione | Basso | Competitor (RepCount) |
| P3.8 | **Strength Level Benchmarking** vs standard | Medio-Alto | Competitor (Hevy) |
| P3.9 | **Recovery Heatmap** - % recupero per muscolo | Alto | Competitor (Fitbod) |
| P3.10 | **Saved Views / Preset Dashboard** | Medio | Best Practices |

---

## 3. Roadmap Suggerita

### Sprint 1 - "Fix the Broken" (P0)
- [ ] P0.1 - Riprogettare Correlazioni (nascondere/linguaggio naturale)
- [ ] P0.2 - Sostituire "+0%" con messaggi contestuali
- [ ] P0.3 - Fix bug "9537 giorni"

### Sprint 2 - "Answer the Question" (P1 Quick Wins)
- [ ] P1.1 - Summary in linguaggio naturale
- [ ] P1.4 - Delta nelle summary cards
- [ ] P1.5 - Tooltip educativi
- [ ] P1.6 - Empty states motivanti

### Sprint 3 - "Show, Don't Tell" (P1 Core)
- [ ] P1.2 - Progressive disclosure 2 livelli
- [ ] P1.3 - Sparklines nella lista esercizi
- [ ] P2.2 - Celebrazione PR animata

### Sprint 4 - "Go Viral" (P2 Engagement)
- [ ] P2.1 - Shareable stats cards
- [ ] P2.5 - Heatmap consistenza
- [ ] P2.6 - Monthly report

### Sprint 5 - "Power Up" (P2 Advanced)
- [ ] P2.3 - Confronto periodo-vs-periodo
- [ ] P2.4 - Grafici interattivi
- [ ] P3.2 - Export CSV/PDF

### Sprint 6+ - "Polish & Differentiate" (P3)
- [ ] P3.1 - Strength Score
- [ ] P3.3 - Metriche avanzate
- [ ] P3.4 - Year in Review
- [ ] Resto P3

---

## 4. Impatto Atteso per Persona

### Dopo Sprint 1-3 (P0 + P1)

| Persona | Voto Attuale (media) | Voto Atteso | Miglioramento |
|---------|---------------------|-------------|---------------|
| Marco | 3.5/10 | 7/10 | +100% (terminologia risolta, summary, tooltip) |
| Chiara | 4.3/10 | 7.5/10 | +75% (summary rapido, meno tap, sparklines) |
| Luca | 5.8/10 | 7/10 | +21% (grafici migliorati, progressive disclosure) |
| Sofia | 4.5/10 | 7/10 | +56% (design migliorato, celebrazioni, empty states) |
| Roberto | 4.3/10 | 7.5/10 | +75% (executive summary, meno rumore) |

### Dopo Sprint 4-5 (P2)

| Persona | Voto Sprint 3 | Voto Atteso | Miglioramento |
|---------|--------------|-------------|---------------|
| Marco | 7/10 | 8/10 | Heatmap motivante, monthly report |
| Chiara | 7.5/10 | 8.5/10 | Share rapido, monthly digest |
| Luca | 7/10 | 8.5/10 | Grafici interattivi, confronto periodi, export |
| Sofia | 7/10 | 9/10 | Share cards, celebrazioni, visual delight |
| Roberto | 7.5/10 | 9/10 | Monthly report, export trainer |

---

## 5. Metriche di Successo

| Metrica | Baseline | Target Sprint 3 | Target Sprint 5 |
|---------|----------|-----------------|-----------------|
| **Tempo su pagina Stats** | Da misurare | +30% | +50% |
| **% utenti che aprono Stats/settimana** | Da misurare | +20% | +40% |
| **Tap su dettaglio esercizio** | Da misurare | +15% | +25% |
| **Share stats (nuova feature)** | 0 | 5% utenti/mese | 15% utenti/mese |
| **Retention 30-day** | Da misurare | +10% | +20% |
| **NPS sezione Stats** | Da misurare | 7+ | 8+ |

---

## Fonti Complete

Tutti i dettagli e le fonti sono disponibili nei 3 report di ricerca:

1. **[COMPETITOR_ANALYSIS.md](COMPETITOR_ANALYSIS.md)** - Analisi di 7 competitor (Strong, Hevy, JEFIT, Fitbod, Alpha Progression, RepCount, GymStreak) con 30+ fonti
2. **[UX_BEST_PRACTICES.md](UX_BEST_PRACTICES.md)** - Best practices da NN/g, Material Design 3, Apple HIG, ricerche accademiche (30+ fonti)
3. **[PERSONA_ANALYSIS.md](PERSONA_ANALYSIS.md)** - Analisi 5 personas con journey maps, pain points, desideri (15+ fonti)

---

*Piano generato il 2026-02-12 dal team stats-ux-research.*
