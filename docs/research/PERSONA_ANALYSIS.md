# Analisi Personas - Pagine Statistiche FitLog Pro

**Data**: 2026-02-12
**Autore**: UX Research Agent
**Versione**: 1.0
**Scope**: Analisi delle 4 pagine Statistiche attraverso le 5 personas dell'app

---

## Indice

1. [Analisi per Persona](#1-analisi-per-persona)
2. [Matrice di Impatto](#2-matrice-di-impatto)
3. [Pain Points Cross-Persona](#3-pain-points-cross-persona)
4. [Feature Request Prioritizzate](#4-feature-request-prioritizzate)
5. [Conflitti tra Personas](#5-conflitti-tra-personas)
6. [Top 10 Raccomandazioni](#6-top-10-raccomandazioni)

---

## Contesto: Pagine Statistiche Attuali

| Pagina | Contenuto Chiave |
|--------|-----------------|
| **P1 - Lista Statistiche** | Summary cards (Serie, Volume, Settimana, PR), Tab filtri (Preferiti/Piu usati/Recenti), Pro Insights badge, Lista esercizi con trend |
| **P2 - Grafici Esercizio** | Filtri metrica (Volume/Peso/1RM/Peso x Rip), Line chart, Date asse X |
| **P3 - Correlazioni** | Sheet modale, Insight chiave, Alert dati insufficienti, Cards correlazione (Peso vs RPE, Volume vs RPE) |
| **P4 - Dettaglio Esercizio** | Filtri temporali, Banner progresso, Stats box (PR/Peso Medio/Reps/RPE), Grafici riordinabili, Insight testuale |

---

## 1. Analisi per Persona

### 1.1 Marco - Il Principiante Intimidito

#### Journey Map nella pagina Stats

```
Apre Statistiche
    |
    v
Vede Summary Cards -----> "Serie? Volume? PR? Cosa significano?" (CONFUSIONE)
    |
    v
Scorre lista esercizi --> Vede "+0%" ovunque, nomi troncati (FRUSTRAZIONE)
    |
    v
Tap su esercizio -------> P4: Banner verde "+38%!" (PRIMO MOMENTO POSITIVO)
    |
    v
Vede Stats box ----------> "1RM? RPE? Non so cosa sono" (ABBANDONO)
    |
    v
Tap icona correlazioni --> P3: "r=0.00, r2=0%..." (PANICO, CHIUDE SUBITO)
```

**Primo sguardo**: Le summary cards. Ma non capisce la terminologia.
**Dove si perde**: Alla P3 (Correlazioni) e nella terminologia tecnica di P4.
**Cosa ignora**: Pro Insights badge, Correlazioni, filtri metrica avanzati.

#### Pain Points (Top 5)

| # | Pain Point | Severita | Evidenza |
|---|-----------|----------|----------|
| 1 | **Terminologia tecnica senza spiegazione** - RPE, 1RM, Volume, Correlazioni sono incomprensibili | Critica | Ricerca: 48% principianti si sentono intimiditi dalla quantita di opzioni disponibili |
| 2 | **Troppi numeri nella schermata iniziale** - 4 summary cards + lista con % + Pro Insights travolgono | Alta | Ricerca: utenti decidono se restare entro 20 secondi; information overload causa 40% di abbandono |
| 3 | **Nessun onboarding/tooltip** - Zero spiegazioni su cosa significano le metriche | Alta | Ricerca: onboarding semplificato aumenta retention del 50% |
| 4 | **Trend "+0%" su tutti gli esercizi** - Sembra che non stia facendo progressi anche se li sta facendo | Media | Mancanza di feedback positivo per principianti con poco storico |
| 5 | **Pagina Correlazioni completamente incomprensibile** - r, r2, coefficienti di correlazione | Critica | Gergo statistico di livello universitario presentato senza contesto |

#### Desideri (Top 5)

| # | Desiderio | Impatto |
|---|-----------|---------|
| 1 | **"Stai migliorando!"** - Messaggi semplici in linguaggio naturale, non numeri | Altissimo |
| 2 | **Tooltip "Cos'e?"** - Tap su qualsiasi metrica per spiegazione in italiano semplice | Alto |
| 3 | **Vista "Principiante"** - Modalita semplificata con meno metriche e piu contesto | Alto |
| 4 | **Confronto "Prima vs Dopo"** - "2 settimane fa sollevavi 40kg, ora 50kg!" | Alto |
| 5 | **Suggerimenti actionable** - "Prova ad aumentare di 2.5kg la prossima volta" | Medio |

#### Quick Wins

1. Aggiungere tooltip informativi su RPE, 1RM, Volume (tap sull'icona `?`)
2. Sostituire "+0%" con "Primo allenamento!" o "Continua cosi!" per chi ha pochi dati
3. Nascondere la sezione Correlazioni per utenti con meno di 10 sessioni
4. Tradurre "Pro Insights" in linguaggio comprensibile ("Come ti alleni")

#### Voti Pagine

| Pagina | Voto | Motivazione |
|--------|------|-------------|
| P1 - Lista | 4/10 | Troppa terminologia, nessuna guida, "+0%" demoralizzante |
| P2 - Grafici | 3/10 | Grafico vuoto/piatto senza contesto, "1RM (Stim.)" incomprensibile |
| P3 - Correlazioni | 1/10 | Completamente inaccessibile, genera ansia e sensazione di inadeguatezza |
| P4 - Dettaglio | 6/10 | Il banner verde motivazionale funziona bene, ma RPE medio e Stats box confondono |

---

### 1.2 Chiara - La Mamma Multitasking

#### Journey Map nella pagina Stats

```
Apre Statistiche (ha 30 secondi)
    |
    v
Summary Cards -----------> "3/5 allenamenti" OK! "Volume +0%?" (SKIP)
    |
    v
Cerca risposta rapida --> "Sto migliorando si o no?" (NON TROVA RISPOSTA CHIARA)
    |
    v
Scorre lista esercizi --> Nomi troncati, tutto "+0%" (FRUSTRAZIONE)
    |
    v
Tap su esercizio -------> P4: TROPPI PASSAGGI per arrivare qui
    |
    v
Vede banner verde ------> Finalmente! Ma ha gia speso 45 secondi (ABBANDONA)
```

**Primo sguardo**: Summary card "Settimana 3/5" - e l'unica info che cerca.
**Dove si perde**: Nella lista esercizi, cercando una risposta che non trova rapidamente.
**Cosa ignora**: Pro Insights, Correlazioni, filtri metrica. Tutto cio che richiede piu di 1 tap.

#### Pain Points (Top 5)

| # | Pain Point | Severita | Evidenza |
|---|-----------|----------|----------|
| 1 | **Troppi tap per vedere il progresso** - Deve aprire Stats > scorrere > tap esercizio > scorrere ancora | Critica | Ricerca: donne con responsabilita familiari cercano guidance comparabile a un personal trainer in formato rapido |
| 2 | **Nessun "summary at a glance"** - Manca un riepilogo tipo "Questa settimana: tutto bene!" | Alta | Ricerca: l'home screen dovrebbe mostrare attivita recente e progresso verso un obiettivo specifico |
| 3 | **Informazioni disperse su piu pagine** - Per avere un quadro completo serve navigare 3+ schermate | Alta | Utenti time-constrained hanno bisogno di routine setup e info in un unico posto |
| 4 | **Nomi esercizi troncati** - Non riesce a identificare rapidamente l'esercizio che cerca | Media | Friction nella ricerca = tempo sprecato |
| 5 | **Nessun confronto settimanale rapido** - "Questa settimana vs la scorsa" non esiste | Media | Chiara pensa in settimane, non in mesi o periodi personalizzati |

#### Desideri (Top 5)

| # | Desiderio | Impatto |
|---|-----------|---------|
| 1 | **Dashboard "5 secondi"** - Un singolo schermo con: allenamenti/settimana, trend positivi, prossimo obiettivo | Altissimo |
| 2 | **Weekly digest** - Notifica/card: "Settimana fantastica! 3 allenamenti, peso medio +5%" | Alto |
| 3 | **Quick stats su Home** - Senza dover navigare alla tab Statistiche | Alto |
| 4 | **Ricerca esercizio veloce** - Barra di ricerca prominente, non solo icona | Medio |
| 5 | **Confronto "Questa settimana vs scorsa"** - Una card semplice, non un grafico complesso | Medio |

#### Quick Wins

1. Aggiungere un summary testuale in cima: "Settimana positiva: 3 allenamenti, 2 PR!"
2. Rendere tappabili le summary cards per drill-down diretto
3. Mostrare nomi esercizi completi (2 righe se necessario)
4. Aggiungere filtro "Questa settimana" ai grafici di P4

#### Voti Pagine

| Pagina | Voto | Motivazione |
|--------|------|-------------|
| P1 - Lista | 5/10 | Summary cards utili ma insufficienti; troppo scroll per trovare info |
| P2 - Grafici | 4/10 | Un click extra che poteva essere evitato |
| P3 - Correlazioni | 2/10 | Completamente irrilevante per i suoi bisogni |
| P4 - Dettaglio | 6/10 | Banner verde buono, ma troppo sforzo per arrivarci |

---

### 1.3 Luca - Il Powerlifter Serio

#### Journey Map nella pagina Stats

```
Apre Statistiche (sessione di analisi settimanale)
    |
    v
Summary Cards -----------> "Solo 4 metriche? Mancano frequency, tonnage, INOL" (DELUSIONE)
    |
    v
Pro Insights ------------> "Forza 36%, Ipertrofia 61%" OK ma superficiale
    |
    v
Tap esercizio (Squat) --> P4: Stats box con PR, Peso Medio, Reps, RPE (BUON INIZIO)
    |
    v
Grafici -----------------> "Non posso zoomare? Non posso vedere per ciclo?" (FRUSTRAZIONE)
    |
    v
Correlazioni ------------> P3: "r=0.00 - Dati insufficienti" (INFORMAZIONE UTILE MA LIMITATA)
    |
    v
Cerca export/compare ----> NON ESISTE (ABBANDONO verso Excel/Sheets)
```

**Primo sguardo**: Pro Insights e summary cards - valuta subito se i dati sono sufficienti.
**Dove si perde**: Non si perde, ma si frustra per la mancanza di profondita.
**Cosa ignora**: Nulla - vuole vedere tutto, ma trova tutto superficiale.

#### Pain Points (Top 5)

| # | Pain Point | Severita | Evidenza |
|---|-----------|----------|----------|
| 1 | **Grafici non interattivi** - Non puo zoomare, pinch, selezionare range, confrontare periodi | Critica | Ricerca: utenti avanzati vogliono "dive deep into stats and charts" |
| 2 | **Mancanza di metriche avanzate** - No INOL, tonnage per muscle group, frequency, e1RM trend | Critica | Ricerca: RPE/RiR, progressive overload tracking, periodization sono must-have |
| 3 | **Impossibilita di export** - Non puo esportare CSV/PDF per analisi esterna o condivisione con coach | Alta | Ricerca: export e condivisione con trainer sono features core delle app per avanzati |
| 4 | **Nessun confronto tra periodi/cicli** - Non puo sovrapporre "Settimana 1 vs Settimana 8" di un programma | Alta | Fondamentale per valutare efficacia dei mesocicli |
| 5 | **Correlazioni troppo basiche** - Solo Peso vs RPE e Volume vs RPE; manca Volume vs Performance, Frequency vs PR | Media | Il framework c'e ma i dati mostrati sono insufficienti per un'analisi seria |

#### Desideri (Top 5)

| # | Desiderio | Impatto |
|---|-----------|---------|
| 1 | **Grafici interattivi** - Zoom, pinch, tap su datapoint per dettagli, overlay di periodi | Altissimo |
| 2 | **Metriche powerlifting** - e1RM trend, Wilks/DOTS score, tonnage, training density | Altissimo |
| 3 | **Export dati** - CSV per analisi su Sheets, PDF per il coach, immagine per i social | Alto |
| 4 | **Confronto mesocicli** - Overlay grafico di 2+ periodi per valutare progressione | Alto |
| 5 | **PR History timeline** - Non solo "ultimo PR" ma storia completa con date e contesto | Alto |

#### Quick Wins

1. Rendere i grafici tappabili (tap su punto per vedere data + valore esatto)
2. Aggiungere e1RM ai filtri metrica disponibili (gia calcolato dal `one_rm_calculator.dart`)
3. Aggiungere un pulsante "Export" (anche solo screenshot/share del grafico)
4. Mostrare la data esatta dei PR nella Stats box

#### Voti Pagine

| Pagina | Voto | Motivazione |
|--------|------|-------------|
| P1 - Lista | 6/10 | Buon punto di partenza ma metriche superficiali |
| P2 - Grafici | 5/10 | Grafico esistente ma non interattivo ne profondo |
| P3 - Correlazioni | 5/10 | Concetto giusto ma esecuzione limitata |
| P4 - Dettaglio | 7/10 | La pagina migliore; banner progresso e stats box utili, ma manca profondita |

---

### 1.4 Sofia - L'Estetica-Driven

#### Journey Map nella pagina Stats

```
Apre Statistiche (vuole qualcosa da condividere)
    |
    v
Summary Cards -----------> Design accettabile ma non "Instagram-worthy" (NEUTRO)
    |
    v
Cerca achievements ------> Non li trova qui (CONFUSIONE)
    |
    v
Tap esercizio ------------> P4: Banner verde "+38%!" (MOMENTO POSITIVO)
    |
    v
Tap share ----------------> P2: Icona share su grafico (PROVA)
    |
    v
Risultato share ----------> Grafico brutto/basic per social (DELUSIONE)
    |
    v
Cerca foto progressi ----> NON ESISTE nella sezione Stats (ABBANDONO)
```

**Primo sguardo**: Il visual design complessivo e il Pro Insights badge.
**Dove si perde**: Cercando contenuto "shareable" e visual.
**Cosa ignora**: Correlazioni, dettagli tecnici, filtri metrica.

#### Pain Points (Top 5)

| # | Pain Point | Severita | Evidenza |
|---|-----------|----------|----------|
| 1 | **Nulla di "shareable"** - Grafici brutti per social, nessun template stories/post | Critica | Ricerca: social sharing di achievements e progress e feature core per engagement |
| 2 | **Design dei grafici troppo basic** - Line chart minimale senza appeal visivo | Alta | Ricerca: design premium e un requisito per utenti estetica-driven |
| 3 | **Mancano badges/achievements nella view stats** - Non vede i suoi traguardi in modo visivo | Alta | Ricerca: badges, streaks e milestones devono essere visibili nel dashboard |
| 4 | **Nessuna foto progressi integrata** - Vorrebbe vedere trasformazione fisica accanto ai numeri | Media | Collegamento body-transformation con dati di allenamento |
| 5 | **Colori e visual language monotoni** - Dark theme senza gradients, animazioni, o visual delight | Media | L'aspetto complessivo non e "premium" abbastanza |

#### Desideri (Top 5)

| # | Desiderio | Impatto |
|---|-----------|---------|
| 1 | **Share cards personalizzate** - Template belli per Instagram Stories con stats e branding | Altissimo |
| 2 | **Achievement showcase** - Sezione visiva con badges guadagnati, streak counter, milestone | Alto |
| 3 | **Grafici con animazioni** - Transizioni fluide, gradient, effetti quando si raggiungono PR | Alto |
| 4 | **Progress photos timeline** - Foto affiancate a dati numerici per vedere trasformazione | Medio |
| 5 | **Temi/personalizzazione** - Poter scegliere colori dei grafici o temi per le stats | Medio |

#### Quick Wins

1. Migliorare il design delle share cards (grafico + logo + stats in formato story)
2. Aggiungere mini-badge/icone accanto ai PR nelle stats
3. Aggiungere animazione al banner verde di P4 (confetti/pulse quando c'e un miglioramento)
4. Gradient sui grafici invece di linee piatte

#### Voti Pagine

| Pagina | Voto | Motivazione |
|--------|------|-------------|
| P1 - Lista | 5/10 | Design clean ma non emozionante; mancano visual rewards |
| P2 - Grafici | 4/10 | Grafico troppo minimal per sharing; manca "wow factor" |
| P3 - Correlazioni | 2/10 | Completamente irrilevante e brutta esteticamente |
| P4 - Dettaglio | 7/10 | Banner verde motivante, stats box ok, ma manca visual delight |

---

### 1.5 Roberto - Il Professionista Busy

#### Journey Map nella pagina Stats

```
Apre Statistiche (check rapido settimanale)
    |
    v
Summary Cards -----------> "3/5 allenamenti" - capito (1 SECONDO)
    |
    v
Cerca "sono a posto?" --> Scorre... (TROPPO SCROLL)
    |
    v
Vuole mandare al trainer -> Cerca export/share (NON TROVA)
    |
    v
Tap esercizio ------------> P4: Info dettagliate (PIU DI QUANTO SERVE)
    |
    v
Torna indietro -----------> Chiude, manda screenshot al trainer su WhatsApp
```

**Primo sguardo**: Summary card "Settimana 3/5" - l'unica cosa che gli interessa.
**Dove si perde**: Non si perde ma non trova un "summary executive" rapido.
**Cosa ignora**: Pro Insights, Correlazioni, qualsiasi cosa che richieda analisi.

#### Pain Points (Top 5)

| # | Pain Point | Severita | Evidenza |
|---|-----------|----------|----------|
| 1 | **Manca un "executive summary"** - Non c'e un riepilogo "vai bene/non vai bene" in 2 secondi | Alta | Ricerca: utenti busy vogliono dashboard "glanceable" |
| 2 | **Nessun export per il trainer** - Deve fare screenshot e mandare su WhatsApp | Alta | Ricerca: export PDF e condivisione con trainer sono features essenziali |
| 3 | **Troppa navigazione** - Per vedere le info di base serve navigare in profondita | Media | Ogni tap extra e tempo sprecato per Roberto |
| 4 | **Informazioni non prioritizzate** - Tutto ha lo stesso peso visivo; nulla emerge come "importante" | Media | Manca gerarchia visiva che evidenzi cosa conta |
| 5 | **Nessun reporting automatico** - Vorrebbe un digest settimanale senza dover aprire la app | Bassa | Push notification con summary o widget iOS |

#### Desideri (Top 5)

| # | Desiderio | Impatto |
|---|-----------|---------|
| 1 | **Dashboard "executive"** - Tutto su uno schermo: compliance, trend, prossimo step | Altissimo |
| 2 | **Export PDF per il trainer** - Report settimanale formattato professionalmente | Alto |
| 3 | **Widget iOS** - Stats principali senza aprire l'app | Alto |
| 4 | **Digest settimanale push** - "Questa settimana: 3/4 allenamenti, +5% volume. Bravo!" | Medio |
| 5 | **Quick actions** - Shortcut 3D Touch per "Vedi stats settimanali" | Basso |

#### Quick Wins

1. Summary testuale in cima: "Settimana: 3/5 OK | Trend: positivo | Focus: Push"
2. Bottone "Condividi con trainer" che genera un report formattato
3. Collapsare sezioni avanzate (Correlazioni, Pro Insights) di default
4. Aggiungere un "traffic light" visivo (verde/giallo/rosso) per stato generale

#### Voti Pagine

| Pagina | Voto | Motivazione |
|--------|------|-------------|
| P1 - Lista | 5/10 | Summary cards utili ma insufficienti; lista esercizi e rumore |
| P2 - Grafici | 5/10 | Utile quando serve, ma troppi passaggi per arrivarci |
| P3 - Correlazioni | 1/10 | Zero valore; spreco di tempo se ci arriva per errore |
| P4 - Dettaglio | 6/10 | Info utili ma troppe per un check rapido |

---

## 2. Matrice di Impatto

### Feature attuali vs Personas

| Feature | Marco | Chiara | Luca | Sofia | Roberto | Score |
|---------|-------|--------|------|-------|---------|-------|
| **Summary Cards (Serie/Volume/Settimana/PR)** | - | + | 0 | 0 | + | +1 |
| **Tab Filtri (Preferiti/Piu usati/Recenti)** | 0 | 0 | + | 0 | 0 | +1 |
| **Pro Insights Badge (Forza/Ipertrofia/Resistenza)** | -- | 0 | + | 0 | 0 | -1 |
| **Lista Esercizi con Trend %** | - | - | + | 0 | 0 | -1 |
| **Line Chart (P2)** | - | 0 | + | - | 0 | -1 |
| **Filtri Metrica (Volume/Peso/1RM/PxR)** | -- | - | ++ | 0 | 0 | -1 |
| **Correlazioni (P3)** | -- | -- | + | -- | -- | -6 |
| **Banner Progresso Verde (P4)** | ++ | ++ | + | ++ | + | +8 |
| **Stats Box (PR/Peso/Reps/RPE)** | - | 0 | ++ | 0 | 0 | +1 |
| **Filtri Temporali (Sett/Mese/3M/Anno/Tutti)** | 0 | 0 | ++ | 0 | + | +3 |
| **Grafici Riordinabili (Drag)** | 0 | 0 | ++ | 0 | 0 | +2 |
| **Insight Testuale** | ++ | + | + | + | + | +6 |
| **Share Button (P2)** | 0 | 0 | 0 | + | + | +2 |

### Legenda

- `++` = Molto positivo (feature chiave per questa persona)
- `+` = Positivo
- `0` = Neutro / Non rilevante
- `-` = Negativo (confonde, rallenta, o frustra)
- `--` = Molto negativo (BLOCKER - genera ansia, abbandono, o frustrazione critica)

### Osservazioni Chiave

1. **Correlazioni (P3) e la feature con peggior score** (-6): negativa per 4 personas su 5
2. **Banner Progresso e la feature con miglior score** (+8): positiva per tutte le 5 personas
3. **Insight Testuale** (+6): molto apprezzato trasversalmente
4. **Pro Insights Badge** e **Filtri Metrica** hanno score negativo: servono solo a Luca

---

## 3. Pain Points Cross-Persona

Pain points condivisi da 3 o piu personas, ordinati per gravita e frequenza.

### P1: Mancanza di un "Quick Summary" comprensibile (5/5 personas)

**Personas coinvolte**: Marco, Chiara, Luca, Sofia, Roberto

| Persona | Manifestazione |
|---------|---------------|
| Marco | "Non capisco se sto migliorando" |
| Chiara | "Devo scorrere troppo per trovare la risposta" |
| Luca | "Le metriche aggregate sono superficiali" |
| Sofia | "Non c'e nulla di emozionante da vedere subito" |
| Roberto | "Manca un semaforo verde/giallo/rosso" |

**Impatto**: La pagina Lista (P1) non risponde alla domanda universale: "Come sto andando?"
**Evidenza ricerca**: L'home screen deve mostrare progresso verso un obiettivo specifico e riassumere l'esperienza utente. Utenti decidono se restare entro 20 secondi.

### P2: Pagina Correlazioni inaccessibile e inutile (4/5 personas)

**Personas coinvolte**: Marco, Chiara, Sofia, Roberto (negativamente); Luca (parzialmente positivo)

| Persona | Manifestazione |
|---------|---------------|
| Marco | "r=0.00? r2=0%? Panico, chiudo" |
| Chiara | "Non ho tempo per questa roba" |
| Sofia | "E brutta e incomprensibile" |
| Roberto | "Zero valore aggiunto" |
| Luca | "Concetto giusto ma esecuzione troppo basica" |

**Impatto**: La pagina Correlazioni e attualmente un detractor netto per l'esperienza.
**Raccomandazione**: Nascondere di default o trasformare in linguaggio naturale.

### P3: Assenza di Export/Condivisione significativa (4/5 personas)

**Personas coinvolte**: Luca, Sofia, Roberto, Chiara

| Persona | Manifestazione |
|---------|---------------|
| Luca | "Devo esportare su Sheets per analisi seria" |
| Sofia | "Nulla di bello da postare sui social" |
| Roberto | "Devo fare screenshot per il trainer" |
| Chiara | "Vorrei mandare al marito/amica per accountability" |

**Impatto**: Perdita di engagement e di possibilita di crescita virale.
**Evidenza ricerca**: Social sharing e export PDF sono features core delle app fitness di successo.

### P4: Troppi passaggi per informazioni essenziali (4/5 personas)

**Personas coinvolte**: Marco, Chiara, Roberto, Sofia

| Persona | Manifestazione |
|---------|---------------|
| Marco | "Mi perdo nella navigazione" |
| Chiara | "Troppi tap, non ho tempo" |
| Roberto | "Perche non e tutto su uno schermo?" |
| Sofia | "Il contenuto bello (banner verde) e sepolto troppo in profondita" |

**Impatto**: Il contenuto piu apprezzato (Banner progresso P4, Insight testuale) richiede 3+ tap per essere raggiunto.
**Evidenza ricerca**: Apps che attivano utenti entro 3 minuti vedono quasi 2x retention.

### P5: Terminologia tecnica senza contesto (3/5 personas)

**Personas coinvolte**: Marco (critico), Chiara (moderato), Sofia (lieve)

| Persona | Manifestazione |
|---------|---------------|
| Marco | "RPE, 1RM, Volume - non so cosa significano" |
| Chiara | "Non ho tempo di imparare gergo fitness" |
| Sofia | "Mi interessa il risultato, non la formula" |

**Impatto**: Barrier to entry per la maggioranza degli utenti non-avanzati.
**Evidenza ricerca**: 70% degli utenti fitness app abbandonano entro 90 giorni; semplificare l'onboarding aumenta retention del 50%.

### P6: Trend "+0%" demoralizzante per utenti con pochi dati (3/5 personas)

**Personas coinvolte**: Marco, Chiara, Sofia

| Persona | Manifestazione |
|---------|---------------|
| Marco | "Tutti i miei esercizi dicono +0%, mi sento inutile" |
| Chiara | "Non vedo progressi, forse non serve a nulla" |
| Sofia | "Nessuna soddisfazione visiva" |

**Impatto**: Per utenti nuovi o con pochi dati, la lista di "+0%" e attivamente demoralizzante.
**Raccomandazione**: Sostituire con "Primo allenamento registrato!" o nascondere il trend fino a 3+ sessioni.

---

## 4. Feature Request Prioritizzate

Ordinate per impatto cross-persona e fattibilita.

| Priorita | Feature | Marco | Chiara | Luca | Sofia | Roberto | Cross-Impact | Fattibilita |
|----------|---------|-------|--------|------|-------|---------|--------------|-------------|
| **1** | **Summary intelligente in linguaggio naturale** - "Settimana ottima: 3 allenamenti, 2 PR, peso medio +5%!" | ++ | ++ | + | ++ | ++ | 5/5 | Alta |
| **2** | **Progressive disclosure** - Vista semplice di default, "Mostra dettagli" per utenti avanzati | ++ | ++ | 0 | + | ++ | 4/5 | Alta |
| **3** | **Share cards personalizzate** - Template belli per social/WhatsApp con stats | + | + | + | ++ | ++ | 5/5 | Media |
| **4** | **Tooltip educativi** - Tap `?` su qualsiasi metrica per spiegazione | ++ | + | 0 | + | 0 | 3/5 | Alta |
| **5** | **Grafici interattivi** - Zoom, tap datapoint, overlay periodi | 0 | 0 | ++ | + | + | 3/5 | Media |
| **6** | **Export dati (CSV/PDF)** - Per analisi esterna e condivisione con trainer | 0 | 0 | ++ | 0 | ++ | 2/5 | Media |
| **7** | **Weekly digest** - Push notification con riassunto settimanale | + | ++ | 0 | + | ++ | 4/5 | Media |
| **8** | **Metriche avanzate opzionali** - e1RM trend, tonnage, frequency (nascoste di default) | 0 | 0 | ++ | 0 | + | 2/5 | Alta |
| **9** | **Achievement showcase nella Stats** - Badges, streak, milestone visivi | ++ | + | 0 | ++ | 0 | 3/5 | Media |
| **10** | **Confronto periodi** - Overlay "Questo mese vs mese scorso" | 0 | + | ++ | + | + | 4/5 | Media |
| **11** | **Correlazioni in linguaggio naturale** - "Quando il peso sale, il tuo RPE tende a salire" | ++ | + | + | + | + | 5/5 | Alta |
| **12** | **Progress photos timeline** - Foto affiancate ai dati | + | 0 | 0 | ++ | 0 | 2/5 | Bassa |
| **13** | **Widget iOS** - Stats rapide senza aprire app | 0 | + | 0 | 0 | ++ | 2/5 | Media |
| **14** | **PR History completa** - Timeline con date e contesto per ogni record | + | 0 | ++ | + | 0 | 3/5 | Alta |
| **15** | **Dashboard personalizzabile** - Drag-and-drop per scegliere cosa vedere | 0 | + | ++ | + | + | 4/5 | Bassa |

---

## 5. Conflitti tra Personas

### Conflitto 1: Semplicita vs Profondita dei Dati

| | Vuole semplicita | Vuole profondita |
|---|-----------------|------------------|
| **Marco** | Fortemente | - |
| **Chiara** | Fortemente | - |
| **Roberto** | Fortemente | - |
| **Sofia** | Moderatamente | - |
| **Luca** | - | Fortemente |

**Conflitto**: Marco/Chiara/Roberto vogliono meno metriche; Luca ne vuole di piu.

**Mitigazione: Progressive Disclosure a 2 livelli**
- **Livello 1 (Default)**: Summary in linguaggio naturale, banner progresso, 3 metriche chiave
- **Livello 2 (Espandi)**: Tutte le metriche, correlazioni, filtri avanzati, grafici interattivi

Implementazione: toggle "Vista semplice / Vista dettagliata" o sezioni collassabili. Ricordare la preferenza dell'utente. La ricerca UX conferma che oltre 2 livelli di disclosure degradano l'usabilita.

### Conflitto 2: Estetica vs Funzionalita

| | Priorita estetica | Priorita funzionale |
|---|-------------------|---------------------|
| **Sofia** | Fortemente | Moderata |
| **Luca** | Bassa | Fortemente |
| **Roberto** | Bassa | Alta |

**Conflitto**: Sofia vuole grafici belli con animazioni; Luca vuole grafici densi di dati; Roberto vuole grafici rapidi da leggere.

**Mitigazione: Design "Beautiful & Functional"**
- Grafici con gradient e animazioni sottili (soddisfa Sofia) che sono anche informativi (soddisfa Luca)
- Tap su datapoint per dettagli (funzionalita per Luca, non impatta Roberto)
- Animazione confetti solo sui PR (visual delight senza rallentare)

### Conflitto 3: Gamification vs Professionalita

| | Vuole gamification | Vuole professionalita |
|---|-------------------|----------------------|
| **Marco** | Moderatamente | - |
| **Sofia** | Fortemente | - |
| **Roberto** | - | Fortemente |
| **Luca** | - | Moderatamente |

**Conflitto**: Sofia e Marco vogliono badges e celebrazioni; Roberto e Luca vogliono un tool serio.

**Mitigazione: Gamification opzionale e non invasiva**
- Achievements in una sezione dedicata (chi li vuole li trova, chi no li ignora)
- Celebrazioni PR sottili (un badge piccolo, non un'animazione full-screen)
- Nessun linguaggio infantile ("Fantastico!!!" va bene, "Sei un super eroe!" no)
- Impostazione per disattivare celebrazioni/badges

### Conflitto 4: Condivisione Social vs Privacy

| | Vuole sharing | Vuole privacy |
|---|--------------|---------------|
| **Sofia** | Fortemente | - |
| **Marco** | - | Fortemente (vergogna) |
| **Roberto** | Con trainer | Pubblicamente |

**Conflitto**: Sofia vuole condividere tutto; Marco ha vergogna dei suoi numeri; Roberto condivide solo col trainer.

**Mitigazione: Sharing granulare**
- Share card mostra solo quello che l'utente sceglie (percentuale di miglioramento, non peso assoluto)
- Opzione "Solo progressi" (mostra +38% ma non "da 30kg a 41kg")
- Share privata (WhatsApp diretto) vs pubblica (Instagram Stories)
- Template diversi: "celebrativo" (Sofia), "report" (Roberto), "milestone" (Marco)

---

## 6. Top 10 Raccomandazioni

Ordinate per **Impatto x Fattibilita**. Scala impatto: 1-5. Scala fattibilita: 1-5 (5 = facile).

### R1. Summary Intelligente in Linguaggio Naturale
**Impatto**: 5 | **Fattibilita**: 4 | **Score**: 20

**Cosa**: Aggiungere in cima alla P1 un blocco testuale dinamico che risponde alla domanda "Come sto andando?" in linguaggio naturale.

**Esempio**:
> "Settimana positiva! 3 allenamenti su 5, 2 nuovi record personali.
> Peso medio in aumento del 5%. Continua cosi!"

**Perche funziona per tutti**:
- Marco: Capisce senza terminologia tecnica
- Chiara: Risposta in 2 secondi
- Luca: Apprezza come header prima di approfondire
- Sofia: Frase motivante da screenshottare
- Roberto: Executive summary che cercava

**Implementazione**: Il dato c'e gia nei provider esistenti (`workout_analytics_provider.dart`). Serve un builder che genera frasi da metriche aggregate.

---

### R2. Progressive Disclosure a 2 Livelli
**Impatto**: 5 | **Fattibilita**: 4 | **Score**: 20

**Cosa**: P1 e P4 mostrano vista semplificata di default. Toggle "Mostra dettagli" per visualizzare metriche avanzate, correlazioni, e filtri granulari.

**Vista Semplice (Default)**:
- Summary testuale
- 3 metriche chiave (Allenamenti, Trend generale, PR recenti)
- Lista esercizi con emoji trend (freccia su/giu/uguale) invece di percentuali
- Banner progresso per esercizi migliorati

**Vista Dettagliata (Toggle)**:
- Tutte le metriche attuali
- Pro Insights
- Correlazioni (in linguaggio naturale)
- Filtri metrica completi

**Perche funziona per tutti**:
- Marco/Chiara/Roberto: Non vedono complessita inutile
- Luca: Toggle una volta, la preferenza viene ricordata
- Sofia: Vista semplice piu pulita ed elegante

---

### R3. Riprogettare la Pagina Correlazioni
**Impatto**: 4 | **Fattibilita**: 4 | **Score**: 16

**Cosa**: Trasformare le correlazioni da gergo statistico a insight in linguaggio naturale. Nascondere la pagina per utenti con dati insufficienti.

**Prima** (attuale):
> Peso vs RPE (r=0.00, r2=0%, Dati Insufficienti)

**Dopo**:
> "Quando aumenti il peso, il tuo sforzo percepito tende a salire proporzionalmente.
> Questo e normale e indica che stai dosando bene l'intensita."

**Regole**:
- < 5 sessioni: Nascondere completamente la sezione
- 5-10 sessioni: Mostrare "Servono piu dati per trovare pattern" (senza dettagli tecnici)
- 10+ sessioni: Mostrare insight in linguaggio naturale + opzione "Vedi dati tecnici" per Luca

---

### R4. Tooltip Educativi su Metriche
**Impatto**: 4 | **Fattibilita**: 5 | **Score**: 20

**Cosa**: Icona `?` tappabile accanto a ogni termine tecnico (RPE, 1RM, Volume, ecc.) che mostra un bottom sheet con spiegazione semplice + esempio.

**Esempio per RPE**:
> **RPE - Quanto e stato difficile**
> Scala da 1 a 10 che misura quanto ti sei sforzato.
> RPE 7 = "Potevo fare altre 3 ripetizioni"
> RPE 10 = "Non potevo fare neanche una in piu"

**Perche funziona**:
- Marco: Impara senza vergogna (non deve chiedere a nessuno)
- Chiara: Spiegazione rapida quando serve
- Luca: Puo ignorare (gia sa)
- Zero impatto negativo su chi non ne ha bisogno

---

### R5. Sostituire "+0%" con Messaggi Contestuali
**Impatto**: 4 | **Fattibilita**: 5 | **Score**: 20

**Cosa**: Per utenti con pochi dati, sostituire il trend "+0%" con messaggi significativi.

| Condizione | Attuale | Proposto |
|-----------|---------|----------|
| 1 sessione | +0% | "Prima sessione registrata!" |
| 2 sessioni, stabile | +0% | "Stabile - consolida la tecnica" |
| 2 sessioni, migliorato | +10% | "+10% - Ottimo inizio!" |
| Nessuna sessione recente | +0% | "Torna ad allenarti!" |

---

### R6. Share Cards Personalizzate
**Impatto**: 4 | **Fattibilita**: 3 | **Score**: 12

**Cosa**: Template grafici per condivisione su social/WhatsApp con:
- Stat card verticale (formato Story): nome esercizio + PR + trend + branding FitLog
- Summary card orizzontale (formato WhatsApp): metriche settimana + emoji
- Report card (formato PDF): tabella esercizi, grafici, note (per il trainer)

**Template disponibili**:
1. **"Celebra"** - Per Sofia/Marco: focus su achievement, emoji, colori vivaci
2. **"Report"** - Per Roberto/Luca: focus su dati, formato professionale
3. **"Milestone"** - Per tutti: "100 allenamenti!" / "1 anno di FitLog!"

---

### R7. Grafici Interattivi
**Impatto**: 4 | **Fattibilita**: 3 | **Score**: 12

**Cosa**: Rendere i grafici di P2 e P4 interattivi:
- **Tap su datapoint**: Mostra tooltip con data, valore, e contesto ("Questo era il tuo PR!")
- **Pinch to zoom**: Zoom orizzontale per analizzare periodi specifici
- **Long press**: Confronta due punti (mostra differenza)
- **Gradient fill**: Area sotto la curva con gradient (piu bello e informativo)

---

### R8. Weekly Digest (Push + In-App)
**Impatto**: 3 | **Fattibilita**: 3 | **Score**: 9

**Cosa**: Ogni lunedi mattina, notifica push con riassunto settimanale.

**Formato**:
> "La tua settimana: 3 allenamenti, Volume totale 4500kg (+8%), 1 nuovo PR.
> Obiettivo prossima settimana: raggiungere 4 allenamenti!"

**In-app**: Stessa informazione come card nella P1, sotto il summary testuale.

---

### R9. Modalita Landscape per Grafici
**Impatto**: 3 | **Fattibilita**: 4 | **Score**: 12

**Cosa**: Permettere rotazione in landscape per grafici a schermo intero. Esiste gia `landscape_graph_screen.dart` nel codebase - assicurarsi che sia facilmente accessibile e ben progettato.

**Benefici**:
- Luca: Piu spazio per analizzare dati
- Sofia: Screenshot piu belli in landscape
- Roberto: Visione d'insieme piu chiara

---

### R10. Nascondere Complessita per Default
**Impatto**: 4 | **Fattibilita**: 5 | **Score**: 20

**Cosa**: Applicare il principio "sane defaults" a tutta la sezione Stats:

| Elemento | Default | Espandibile |
|----------|---------|-------------|
| Pro Insights | Collapsed | Tap per espandere |
| Correlazioni | Nascosto se < 10 sessioni | Visibile dopo soglia |
| Filtri metrica avanzati | Solo "Peso" e "Volume" | Toggle per 1RM, PxR |
| Stats box RPE | Nascosto se mai usato | Visibile se utente logga RPE |
| Grafici riordinabili | Drag handle nascosto | Visibile in "Vista dettagliata" |

---

## Appendice A: Riepilogo Voti per Pagina

| Pagina | Marco | Chiara | Luca | Sofia | Roberto | Media |
|--------|-------|--------|------|-------|---------|-------|
| P1 - Lista Statistiche | 4 | 5 | 6 | 5 | 5 | **5.0** |
| P2 - Grafici Esercizio | 3 | 4 | 5 | 4 | 5 | **4.2** |
| P3 - Correlazioni | 1 | 2 | 5 | 2 | 1 | **2.2** |
| P4 - Dettaglio Esercizio | 6 | 6 | 7 | 7 | 6 | **6.4** |

**Pagina peggiore**: P3 - Correlazioni (media 2.2/10)
**Pagina migliore**: P4 - Dettaglio Esercizio (media 6.4/10)

---

## Appendice B: Fonti della Ricerca

### Statistiche Utenti e Retention
- [Dataconomy - Best UX/UI Practices for Fitness Apps 2025](https://dataconomy.com/2025/11/11/best-ux-ui-practices-for-fitness-apps-retaining-and-re-engaging-users/)
- [JMIR - Analysis of Training Behavior in Users of a Fitness App 2026](https://mhealth.jmir.org/2026/1/e72201)
- [Orangesoft - 13 Strategies for Fitness App Engagement](https://orangesoft.co/blog/strategies-to-increase-fitness-app-engagement-and-retention)
- [Enable3 - App Retention Benchmarks 2026](https://enable3.io/blog/app-retention-benchmarks-2025)

### UX Design e Best Practices
- [Stormotion - Fitness App UI Design Key Principles](https://stormotion.io/blog/fitness-app-ux/)
- [Zfort - How to Design a Fitness App UX/UI Best Practices](https://www.zfort.com/blog/How-to-Design-a-Fitness-App-UX-UI-Best-Practices-for-Engagement-and-Retention)
- [NN/g - Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
- [Superside - UX Design Principles from Top Health and Fitness Apps](https://www.superside.com/blog/ux-design-principles-fitness-apps)

### Ricerca per Persona
- [Wiley - Unintended consequences of fitness apps](https://bpspsychub.onlinelibrary.wiley.com/doi/10.1111/bjhp.70026)
- [ParentMap - Best Fitness Apps for Busy Parents](https://www.parentmap.com/article/best-fitness-apps-busy-parents)
- [BarBend - Best Weightlifting Apps 2026](https://barbend.com/best-weightlifting-apps/)
- [Social.Plus - Fitness is Social: Top 6 Features](https://www.social.plus/blog/fitness-is-social-top-6-features-all-successful-apps-share)
- [HubFit - 5 Ways to Share Workout Programs with Clients](https://hubfit.com/blog/5-effective-ways-to-share-workout-programs-with-your-clients-as-an-online-coach-personal-trainer)

### Dati Chiave Utilizzati
- 70% di utenti fitness app abbandonano entro 90 giorni
- 48% dei principianti si sentono intimiditi dalle opzioni disponibili
- Utenti decidono se restare entro 20 secondi
- Semplificare l'onboarding aumenta retention del 50%
- App che attivano utenti entro 3 minuti vedono 2x retention
- Workout completion rate > 70% aumenta lifetime value del 43%
- 30-day retention media per fitness app: 27.2% (top: 47.5%)
- Design con oltre 2 livelli di disclosure ha bassa usabilita

---

## Appendice C: Mappa Priorita Implementazione

```
                    IMPATTO ALTO
                        |
    R1 Summary NL  -----+------ R2 Progressive Disclosure
    R4 Tooltip     -----+------ R5 Replace +0%
    R10 Hide Complex    |
                        |
  FACILE ---------------+--------------- DIFFICILE
                        |
    R9 Landscape   -----+------ R6 Share Cards
    R8 Weekly Digest    |       R7 Grafici Interattivi
                        |
                    IMPATTO BASSO
```

**Quick Wins (Alto impatto + Facile)**: R1, R2, R4, R5, R10
**Progetti Medi**: R6, R7, R8, R9
**Investimenti Grandi**: R12 (Progress photos), R15 (Dashboard personalizzabile)

---

*Report generato il 2026-02-12. Basato su analisi qualitativa delle pagine Statistiche e ricerca UX online.*
