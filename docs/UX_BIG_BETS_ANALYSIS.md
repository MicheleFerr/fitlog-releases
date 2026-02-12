# UX Big Bets Analysis - FitLog Pro

> Analisi dettagliata dei miglioramenti UX strutturali emersi dall'audit UX completo.
> Questi richiedono design/architettura significativa, non sono quick-fix.

**Data**: Febbraio 2026
**Fonte**: Report consolidato UX Analysis Team (5 agenti specializzati)

---

## Indice

| # | Big Bet | Effort | Impatto |
|---|---------|--------|---------|
| 1 | [Timer contestuale con fasi](#1-timer-contestuale-con-fasi) | L | Alto |
| 2 | [Onboarding interattivo](#2-onboarding-interattivo) | L | Alto |
| 3 | [Preview template](#3-preview-template-prima-delluso) | M | Medio |
| 4 | [Suggerimenti peso progressivo](#4-suggerimenti-peso-progressivo) | M | Alto |
| 5 | [Animazioni micro-feedback](#5-animazioni-micro-feedback) | M | Medio |
| 6 | [Gesture swipe navigazione](#6-gesture-swipe-per-navigazione-analytics) | S | Basso |
| 7 | [Dashboard personalizzabile](#7-dashboard-home-personalizzabile) | L | Medio |
| 8 | [Refactoring icon sizes](#8-refactoring-icon-sizes) | S | Basso |
| 9 | [Suoni e haptics](#9-suoni-e-haptics-per-eventi) | M | Medio |
| 10 | [Dark mode ottimizzato](#10-dark-mode-ottimizzato-oled) | M | Medio |
| 11 | [Widget home screen nativi](#11-widget-home-screen-nativi-iosandroid) | L | Medio |
| 12 | [Modalita offline migliorata](#12-modalita-offline-migliorata) | M | Alto |

**Effort**: S = 1-2 giorni, M = 3-5 giorni, L = 1-2 settimane

---

## 1. Timer contestuale con fasi

**Cosa**: Sostituire il timer generico con un timer che riconosce le fasi dell'allenamento (warm-up, working set, rest, cooldown) e si adatta automaticamente.

**Stato attuale**: Timer unico che conta il tempo totale. L'utente deve gestire mentalmente i rest period tra i set.

**Implementazione**:
- Timer con stati: `warmUp` → `workingSet` → `rest` → `workingSet` → ...
- Rest timer auto-start quando si completa un set
- Tempi di riposo suggeriti per tipo di esercizio (forza: 3-5min, ipertrofia: 60-90s)
- Integrazione con Live Activity iOS per mostrare fase corrente su lock screen

**Pro**:
- Elimina il carico cognitivo di gestire i tempi di riposo manualmente
- Migliora la qualità dell'allenamento (rest period corretti = performance migliore)
- Differenziatore rispetto ai competitor (pochi hanno timer contestuali)
- Sinergia perfetta con Live Activity gia implementata
- Persona Marco (principiante): guidato su quanto riposare
- Persona Luca (powerlifter): rest period precisi sono critici

**Contro**:
- Complessita significativa nella state machine del timer
- Difficile gestire edge case (superset, circuit training, AMRAP)
- Risk di essere troppo prescrittivo per utenti avanzati che preferiscono gestire i tempi
- Il timer attuale funziona gia per la maggior parte degli utenti
- Richiede refactoring del WorkoutProvider che e gia complesso

**Verdict**: Alto impatto ma alto rischio. Consigliato come feature post-lancio beta.

---

## 2. Onboarding interattivo

**Cosa**: Sostituire l'onboarding statico con un coach overlay step-by-step che guida l'utente attraverso la prima sessione.

**Stato attuale**: Sistema di discoverability hints (chip, peek, pulse) gia implementato. Manca un flusso guidato completo per il primo allenamento.

**Implementazione**:
- Overlay coach che evidenzia elementi UI uno alla volta
- Flusso: "Scegli un template" → "Tocca per iniziare" → "Inserisci il peso" → "Completa il set" → "Salva"
- Uso di `Showcaseview` package o implementazione custom con `OverlayEntry`
- Persistenza stato tutorial in Hive (quali step completati)

**Pro**:
- Riduce drasticamente il drop-off dei nuovi utenti (industry: -40% con buon onboarding)
- Persona Marco: trasforma l'esperienza da "intimidito" a "guidato"
- Persona Chiara: capisce subito il flow senza perdere tempo
- Il sistema hint gia presente fornisce l'infrastruttura base
- One-time cost con beneficio permanente sulla retention

**Contro**:
- Gli onboarding interattivi possono essere fastidiosi se troppo lunghi
- Manutenzione: ogni cambio UI richiede aggiornamento dell'onboarding
- Il sistema di hint attuale potrebbe essere sufficiente
- Rischio di over-engineering per un'app con 1 utente beta
- Difficile testare tutti i path (skip, back, interruzione)

**Verdict**: Alto impatto sulla retention. Prioritario per lancio pubblico, non urgente per beta.

---

## 3. Preview template prima dell'uso

**Cosa**: Modale di preview che mostra tutti gli esercizi di un template con dettagli (set, rep, muscoli target) prima di iniziare il workout.

**Stato attuale**: Le template card mostrano nome, categoria, numero esercizi e durata stimata. Per vedere i dettagli bisogna iniziare il workout.

**Implementazione**:
- Bottom sheet o modale full-screen con lista esercizi
- Per ogni esercizio: nome, muscolo target, set x rep suggeriti, note
- Pulsante "Personalizza" per modificare prima di iniziare
- Pulsante "Inizia workout" prominente in fondo

**Pro**:
- Riduce l'ansia del "cosa sto per fare?" (Persona Marco)
- Permette di valutare se il template e adatto prima di impegnarsi
- Persona Roberto: valuta rapidamente se il workout entra nei suoi 45 min
- Implementazione relativamente semplice (dati gia disponibili nel template)
- Pattern standard in app fitness (Strong, Hevy lo hanno)

**Contro**:
- Aggiunge un tap extra prima di iniziare (friction per utenti esperti)
- Le template card gia mostrano le info essenziali
- Persona Chiara: vuole iniziare subito, non leggere dettagli
- Richiede design attento per non essere un muro di testo
- Duplicazione parziale con la schermata workout gia attiva

**Verdict**: Effort medio, impatto medio. Buon candidato per la prossima iterazione.

---

## 4. Suggerimenti peso progressivo

**Cosa**: Suggerire automaticamente il peso per il prossimo set/workout basandosi sullo storico, implementando progressive overload intelligente.

**Stato attuale**: L'utente inserisce il peso manualmente. Lo storico e disponibile ma non viene usato per suggerimenti proattivi.

**Implementazione**:
- Analisi ultimo workout per lo stesso esercizio
- Algoritmo: se ultimo workout completato con RPE < 8, suggerisci +2.5kg
- Indicatore visivo: "Ultimo: 80kg x 8 → Suggerito: 82.5kg"
- Tap per accettare il suggerimento o inserire manualmente
- Logica adattiva per plateau (se 3+ sessioni stesso peso, suggerisci deload o variazione)

**Pro**:
- Core value proposition per un'app di fitness tracking
- Persona Luca: progressive overload e il suo obiettivo primario
- Persona Sofia: vedere numeri che crescono e motivante
- Differenziatore forte vs app che sono solo "quaderno digitale"
- I dati necessari sono gia raccolti e disponibili
- Riduce il tempo di setup di ogni set (auto-fill peso)

**Contro**:
- Algoritmo di progressive overload non e triviale (varia per esercizio, esperienza, obiettivo)
- Suggerimenti sbagliati possono causare infortuni (responsabilita)
- Richiede storico sufficiente (inutile per nuovi utenti)
- Complessita nella UI: dove mostrare il suggerimento senza essere invasivo?
- Persona Marco: potrebbe sentirsi sotto pressione a seguire i suggerimenti

**Verdict**: Alto impatto, core feature. Priorita alta per differenziazione. Implementare con approccio conservativo (suggerimento opzionale, mai forzato).

---

## 5. Animazioni micro-feedback

**Cosa**: Aggiungere animazioni sottili per eventi chiave (completamento set, PR raggiunto, workout completato) usando Lottie o Rive.

**Stato attuale**: Feedback puramente visuale (colori, icone). Nessuna animazione celebrativa.

**Implementazione**:
- Lottie animations per: checkmark set completato, confetti PR, streak flame
- Animazione breve (300-500ms) non bloccante
- Package `lottie` gia disponibile su pub.dev
- Asset animations scaricabili da LottieFiles (free tier)

**Pro**:
- Aumenta la dopamina e la soddisfazione percepita
- Persona Sofia: il feedback visuale e fondamentale per la motivazione
- Persona Marco: rinforzo positivo ad ogni set completato
- Costo di implementazione relativamente basso con Lottie
- Trend industry: tutte le app top hanno micro-animazioni
- Non richiede cambio architetturale

**Contro**:
- Rischio di essere eccessivo/distrattivo durante l'allenamento
- Animazioni Lottie aumentano la dimensione dell'app (+2-5MB per asset)
- Persona Luca: potrebbe trovarlo frivolo e distraente
- Persona Roberto: ogni millisecondo conta, le animazioni rallentano
- Difficile calibrare il "quanto e troppo"
- Manutenzione asset grafici nel tempo

**Verdict**: Impatto medio sulla percezione di qualita. Implementare in modo conservativo: solo per PR e workout completato, con opzione per disabilitare.

---

## 6. Gesture swipe per navigazione Analytics

**Cosa**: Permettere swipe orizzontale per navigare tra i tab di Analytics (Overview, Volume, Plateau) invece di solo tap.

**Stato attuale**: Navigazione solo tramite tap sui tab in alto. TabBarView senza gesture.

**Implementazione**:
- Wrappare il contenuto dei tab in un `PageView` o abilitare gesture su `TabBarView`
- Aggiungere indicatore visivo di swipe (dots o linea animata)
- Mantenere la possibilita di tap sui tab

**Pro**:
- Pattern naturale su mobile (Instagram, Twitter usano swipe tra tab)
- Persona Chiara: navigazione piu fluida e veloce
- Implementazione semplice (Flutter ha `TabBarView` con gesture built-in)
- Zero impatto sulle performance
- Migliora la discoverability dei tab laterali

**Contro**:
- Potrebbe confliggere con gesture dei grafici (pan/zoom sui chart)
- Rischio di swipe accidentali quando si scrolla verticalmente
- Il tab Analytics ha solo 3 tab, il tap e gia veloce
- Aggiunge complessita nella gesture disambiguation
- Potrebbe confondere utenti che non si aspettano lo swipe

**Verdict**: Basso impatto, basso effort. Nice-to-have. Attenzione ai conflitti gesture con i grafici.

---

## 7. Dashboard home personalizzabile

**Cosa**: Permettere all'utente di riordinare e scegliere quali widget mostrare nella home screen (PR recenti, streak, prossimo workout, stats settimana).

**Stato attuale**: Home screen con layout fisso: saluto, quick actions, template recenti.

**Implementazione**:
- Sistema di widget cards draggable (ReorderableListView)
- Widget disponibili: Streak, PR recenti, Volume settimana, Prossimo workout, Quote motivazionale
- Persistenza layout in Hive
- Modalita "edit" con long-press per riordinare
- Minimo 2 widget, massimo 6

**Pro**:
- Ogni utente ha priorita diverse (Luca vuole PR, Sofia vuole streak, Roberto vuole prossimo workout)
- Aumenta il senso di ownership sull'app
- Trend industry: widget personalizzabili sono feature premium
- Riduce la necessita di navigare in altre sezioni

**Contro**:
- Complessita di implementazione molto alta (drag & drop, persistenza, responsive)
- Rischio "paradosso della scelta": troppa personalizzazione confonde
- Persona Marco: non sa cosa vuole vedere, preferisce un default intelligente
- Manutenzione: ogni nuovo widget deve integrarsi col sistema
- La home attuale e gia funzionale e ben organizzata
- Rischio over-engineering per la fase attuale del prodotto

**Verdict**: Feature premium/differenziante ma effort alto. Rimandare a post-lancio quando ci sono dati su cosa gli utenti guardano di piu.

---

## 8. Refactoring icon sizes

**Cosa**: Sostituire tutti i valori hardcoded di icon size (es. `size: 24`, `size: 16`) con le costanti `AppIconSize.*` in tutto il codebase.

**Stato attuale**: 95+ file con icon size hardcoded. Il sistema `AppIconSize` esiste ma non e usato ovunque.

**Implementazione**:
- Mapping: 16 → `AppIconSize.tiny`, 20 → `AppIconSize.small`, 24 → `AppIconSize.medium`, 28 → `AppIconSize.large`, 32 → `AppIconSize.xlarge`, 48 → `AppIconSize.xxlarge`
- Pass sistematico file per file
- Verifica visiva per size non standard (14, 18, 22, etc.)

**Pro**:
- Coerenza visiva garantita in tutta l'app
- Facilita futuri cambiamenti di design system (modifica un valore, cambia ovunque)
- Riduce il debito tecnico
- Rende il codice piu leggibile e manutenibile

**Contro**:
- Effort meccanico e noioso (95+ file)
- Rischio di regressioni visive se il mapping non e 1:1
- Alcuni size sono intenzionalmente custom (non mappano a costanti standard)
- Nessun impatto visibile per l'utente finale
- Potrebbe causare conflitti merge con altri branch

**Verdict**: Tech debt puro. Da fare in un branch dedicato con verifica visiva. Nessuna urgenza.

---

## 9. Suoni e haptics per eventi

**Cosa**: Aggiungere feedback audio e tattile per eventi chiave (completamento set, PR, fine workout, timer scaduto).

**Stato attuale**: Haptic feedback gia presente su alcuni tap (tab navigation, button press). Nessun suono.

**Implementazione**:
- Suoni brevi (<1s) per: set completato, PR, timer done
- Haptic patterns differenziati: `lightImpact` per tap, `mediumImpact` per set, `notificationSuccess` per PR
- Settings per abilitare/disabilitare separatamente suoni e haptics
- Audio session management per non interferire con musica in riproduzione

**Pro**:
- Feedback multisensoriale migliora l'esperienza in palestra (spesso non si guarda lo schermo)
- Persona Luca: sapere che il timer e scaduto senza guardare il telefono
- Persona Chiara: conferma tattile che il set e stato salvato
- Differenziatore: poche app fitness hanno audio feedback ben fatto
- Haptics gia parzialmente implementati, estenderli e facile

**Contro**:
- Audio in palestra e complicato (cuffie, musica, rumore ambiente)
- Gestione audio session iOS e complessa (interferenza con Spotify/Apple Music)
- Persona Roberto: potrebbe trovare i suoni fastidiosi in ufficio
- Richiede asset audio (creazione/acquisto)
- Rischio di essere percepito come spam sensoriale
- Testing difficile (dipende dal dispositivo fisico)

**Verdict**: Impatto medio, focus sugli haptics (piu facili e meno invasivi). Suoni come feature opzionale.

---

## 10. Dark mode ottimizzato OLED

**Cosa**: Ottimizzare il tema dark per schermi OLED con neri puri (#000000) e contrasti calibrati per risparmio batteria e comfort visivo.

**Stato attuale**: Dark mode funzionante con Material 3 theme. Usa grigio scuro standard, non nero puro.

**Implementazione**:
- Variante "AMOLED Dark" con sfondo #000000
- Contrasti calibrati per WCAG AA su sfondo nero
- Colori accent piu saturi per compensare lo sfondo scuro
- Opzione nelle settings per scegliere tra "Dark" e "AMOLED Dark"
- Test su device OLED reali per validare leggibilita

**Pro**:
- Risparmio batteria significativo su OLED (fino a 30% in meno)
- Comfort visivo in palestra con luci basse
- Persona Sofia: estetica premium, aspetto moderno
- Feature richiesta frequentemente dagli utenti Android
- Implementazione relativamente semplice (variante del tema esistente)

**Contro**:
- Nero puro puo causare "black smearing" su alcuni display OLED
- Testo su sfondo nero puro e meno leggibile per alcuni utenti
- Richiede testing su molteplici device con display diversi
- Aggiunge complessita al theme system (3 temi invece di 2)
- Il dark mode attuale e gia buono e funzionale
- Impatto reale sulla batteria dipende molto dall'uso

**Verdict**: Nice-to-have. Basso rischio, effort medio. Buona feature per attrarre utenti Android.

---

## 11. Widget home screen nativi (iOS/Android)

**Cosa**: Widget nativi per la home screen del telefono che mostrano info rapide (prossimo workout, streak, ultimo PR).

**Stato attuale**: Live Activity iOS implementata per il timer workout attivo. Nessun widget home screen.

**Implementazione**:
- **iOS**: WidgetKit con SwiftUI (widget small/medium/large)
- **Android**: Glance (Jetpack Compose) o XML widget tradizionale
- Shared data tramite App Groups (iOS) / SharedPreferences (Android)
- Widget types: "Next Workout", "Weekly Streak", "Last PR"
- Aggiornamento periodico (ogni 15-30 minuti)

**Pro**:
- Visibilita costante dell'app sulla home screen = retention
- Persona Roberto: vede il prossimo workout senza aprire l'app
- Persona Sofia: streak visibile come motivazione passiva
- Trend industry forte: Apple spinge molto i widget
- Sinergia con Live Activity gia implementata (codice Swift riusabile)

**Contro**:
- Sviluppo nativo separato per iOS e Android (doppio effort)
- iOS: WidgetKit ha limitazioni severe (no animazioni, aggiornamenti limitati)
- Android: frammentazione device rende il testing complesso
- Shared data tra Flutter e nativo richiede bridge dedicato
- Manutenzione doppia: ogni cambio dati richiede update del widget
- Effort alto per un beneficio incrementale

**Verdict**: Feature premium per differenziazione. Iniziare con iOS (piu utenti target, codice Swift gia presente). Android in fase successiva.

---

## 12. Modalita offline migliorata

**Cosa**: Migliorare l'esperienza offline con banner informativi, sync queue visibile, e gestione conflitti intelligente.

**Stato attuale**: L'app funziona offline (Hive locale) con sync Firebase quando online. Nessun feedback visivo sullo stato di connessione.

**Implementazione**:
- Banner "Offline - i dati saranno sincronizzati" in alto
- Indicatore sync queue: "3 workout in attesa di sync"
- Gestione conflitti: merge intelligente o "scegli quale versione tenere"
- Retry automatico con backoff esponenziale
- Indicatore di ultimo sync riuscito nelle settings

**Pro**:
- Palestre spesso hanno connessione scarsa/assente
- Persona Chiara: deve sapere che i dati non si perderanno
- Persona Roberto: allena in aereo/hotel con connessione instabile
- Riduce l'ansia "i miei dati sono salvati?"
- Il sistema offline gia funziona, serve solo il feedback visivo
- Trust building: trasparenza sullo stato dei dati

**Contro**:
- Banner offline puo essere percepito come negativo ("c'e un problema")
- Gestione conflitti e complessa da implementare correttamente
- UI sync queue aggiunge complessita visiva
- Rischio di far sembrare l'app "fragile" mostrando troppi stati interni
- La maggior parte degli utenti ha connessione stabile
- Testing offline scenarios e laborioso

**Verdict**: Alto impatto sulla fiducia utente. Il feedback visivo (banner + sync status) e facile da implementare. La gestione conflitti e complessa ma puo essere iterata.

---

## Matrice di Priorita

```
                    IMPATTO
                 Alto         Basso
           ┌──────────┬──────────┐
  Basso    │  #4 Peso │  #8 Icon │
           │  #6 Swipe│  sizes   │
  EFFORT   ├──────────┼──────────┤
  Medio    │ #12 Offl │  #5 Anim │
           │  #3 Prev │  #9 Suoni│
           │          │ #10 OLED │
           ├──────────┼──────────┤
  Alto     │  #2 Onb  │  #7 Dash │
           │  #1 Timer│ #11 Widg │
           └──────────┴──────────┘
```

## Ordine di Implementazione Suggerito

### Fase 1 - Pre-lancio pubblico (priorita alta)
1. **#4 Suggerimenti peso progressivo** - Core differenziatore
2. **#12 Offline migliorata** - Trust building essenziale

### Fase 2 - Post-lancio (prime settimane)
3. **#3 Preview template** - Riduce friction
4. **#2 Onboarding interattivo** - Retention nuovi utenti

### Fase 3 - Crescita
5. **#5 Micro-animazioni** - Polish percepito
6. **#9 Haptics estesi** - Feedback multisensoriale
7. **#10 AMOLED dark** - Feature richiesta

### Fase 4 - Premium/Differenziazione
8. **#1 Timer contestuale** - Feature avanzata
9. **#11 Widget nativi** - Visibility
10. **#7 Dashboard personalizzabile** - Power user feature

### Backlog
11. **#6 Gesture swipe** - Nice-to-have
12. **#8 Icon sizes refactoring** - Tech debt
