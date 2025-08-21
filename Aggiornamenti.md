# Aggiornamenti

## Data: 12/08/2025

### 1. Fix Audio Ducking in Background (iOS)

**Problema:** Quando l'app andava in background, il volume della musica si abbassava automaticamente anche senza timer attivo.

**File modificato:** `ios/Runner/AppDelegate.swift`

**Modifiche:**
- **Linea 27-28:** Ripristinata la chiamata a `setupAudioSession()` per permettere al timer di riprodurre il suono di completamento
- **Linee 84-88:** Aggiunto `.mixWithOthers` e `.defaultToSpeaker` alla configurazione audio in background, rimuovendo il ducking automatico
- **Linee 93-97:** Aggiunto `.defaultToSpeaker` alla configurazione in foreground
- **Linee 103-106:** Modificata l'attivazione dell'audio session per coesistere con altre app audio

**Risultato:** La musica ora continua a suonare normalmente quando l'app va in background, senza abbassare il volume.

---

### 2. Silent Audio Solo con Timer Attivo

**Problema:** L'audio silenzioso veniva configurato sempre quando l'app andava in background, anche senza timer attivo.

**File modificato:** `lib/features/timer/presentation/providers/timer_provider.dart`

**Modifiche:**
- **Linee 133-141:** Disabilitato il silent audio in background (commentato il codice che lo attivava)
- **Linea 152:** Commentata la chiamata a `_stopSilentAudio()` quando l'app torna in foreground
- **Linee 33, 52:** Commentate le chiamate a `_stopSilentAudio()` nei metodi `stopTimer()` e `skipTimer()`
- **Linea 137:** Commentata la chiamata a `_stopSilentAudio()` nel metodo `resetTimer()`
- **Linee 206-209:** Modificata la configurazione del silent audio per usare `PlayerMode.mediaPlayer` e volume molto basso (0.001) per migliore compatibilità con la musica

**Risultato:** Il silent audio ora si attiva SOLO quando un timer è effettivamente in esecuzione, non quando l'app va semplicemente in background.

---

### 3. Template Veloci - Tab Iniziale "I miei"

**Problema:** Nella homepage, i template veloci partivano dal tab "Predefiniti" invece di "I miei".

**File modificato:** `lib/features/home/presentation/providers/template_provider.dart`

**Modifiche:**
- **Linea 11:** Cambiato il valore iniziale del provider da `TemplateTab.predefined` a `TemplateTab.myTemplates`

**Risultato:** Ora quando si apre la homepage, la sezione "Template Veloci" mostra di default il tab "I miei" invece di "Predefiniti".

---

## Riepilogo Generale

Questi aggiornamenti migliorano l'esperienza utente in tre aspetti chiave:

1. **Audio Background:** L'app non interferisce più con la musica in riproduzione quando va in background
2. **Gestione Risorse:** L'audio silenzioso viene utilizzato solo quando necessario (timer attivo), risparmiando batteria
3. **UX Homepage:** L'interfaccia ora prioritizza i template personalizzati dell'utente rispetto a quelli predefiniti

Tutti i cambiamenti sono stati testati e l'app è stata ricompilata con successo.

---

### 4. Redesign Modal Informazioni Esercizi

**Problema:** Il modal delle informazioni esercizi aveva troppo scrolling e le sezioni non erano ben organizzate.

**File modificato:** `lib/features/workout/presentation/widgets/exercise_list_item.dart`

**Modifiche:**
- **Linee 2000-2200:** Creato nuovo sistema di raggruppamento sezioni con `_GroupedModalSection` e `_ModalItem`
- **Linee 1800-1900:** Raggruppati muscoli primari e secondari in un'unica sezione "Target Muscles"
- **Linee 1900-2000:** Raggruppati Difficoltà, Tipo, Attrezzatura e Movimento in "Exercise Details"
- Cambiato label da "Safety Tips" a "Prevention"
- Cambiato label da "Exercise Info" a solo "Info"
- Aggiunto icone colorate per ogni gruppo di sezioni
- Implementato design Material 3 con chips colorati

**Risultato:** Modal più compatto e organizzato con meno scrolling, sezioni correlate raggruppate visivamente.

---

### 5. Fix Persistenza Impostazioni Locali

**Problema:** Le impostazioni (lingua, tema, dimensione font) venivano resettate ad ogni avvio dell'app.

**File modificato:** `lib/main.dart`

**Modifiche:**
- **Linea 42:** Rimosso `await Hive.deleteBoxFromDisk('app_config');` che cancellava le impostazioni ad ogni avvio
- **Linee 43-46:** Aggiunto controllo per registrare adapter solo se non già registrato
- **Linee 47-50:** Aperto box app_config correttamente senza cancellarlo

**Risultato:** Le impostazioni utente ora persistono correttamente tra le sessioni dell'app.

---

### 6. Salvataggio Template su Firebase

**Problema:** I template venivano salvati solo localmente, non sincronizzati tra dispositivi.

**Files modificati:** 
- `lib/features/workout/presentation/workout_screen.dart`
- `lib/features/workout/presentation/providers/workout_template_provider.dart`

**Modifiche Workout Screen:**
- **Linee 1000-1100:** Aggiunto menu item "Salva come Template" nel menu workout
- **Linee 1193-1520:** Creata classe `_SaveTemplateHelper` con dialog per inserire nome e descrizione
- Aggiunto feedback visivo durante il salvataggio (loading indicator)
- Aggiunto messaggio di successo con link per visualizzare i template

**Modifiche Provider:**
- **Linee 14-18:** Modificato repository provider per usare Firebase quando utente autenticato
- **Linee 135-181:** Aggiunto logging dettagliato e invalidazione cache dopo salvataggio

**Risultato:** I template ora vengono salvati su Firebase e sincronizzati automaticamente tra tutti i dispositivi dell'utente.

---

### 7. Sistema Quote Template con Tier Account

**Problema:** Nessun limite sul numero di template salvabili, rischio costi Firebase elevati.

**Files creati/modificati:**
- `lib/features/auth/domain/entities/user_profile.dart` (NUOVO)
- `lib/features/auth/presentation/providers/user_profile_provider.dart` (NUOVO)
- `lib/features/auth/data/auth_service.dart`
- `lib/features/workout/data/repositories/firebase_workout_template_repository.dart`
- `lib/features/workout/presentation/workout_screen.dart`

**Nuove Entità Create:**

**UserProfile Entity:**
- Enum `AccountTier` con livelli: free, premium, pro
- Classe `TemplateQuota` per gestire limiti e utilizzo
- Entity `UserProfile` completa con integrazione Firestore

**User Profile Provider:**
- Stream provider per aggiornamenti real-time profilo utente
- State notifier per gestione modifiche profilo
- Metodi per controllo e aggiornamento quota
- Sincronizzazione conteggio template

**Modifiche Auth Service:**
- **Linee 201-207:** Aggiunto accountTier e templateQuota alla creazione utente
- Default: tier 'free' con 10 template privati, 2 pubblici

**Modifiche Firebase Repository:**
- **Linee 204-207:** Aggiunto controllo quota prima del salvataggio
- **Linee 706-760:** Implementato metodo `_checkAndUpdateQuota()`
- **Linee 762-788:** Implementato metodo `_decrementQuota()` per eliminazioni
- **Linee 277-309:** Integrato decremento quota in `deleteTemplate()`

**Modifiche UI Workout Screen:**
- **Linee 1200-1256:** Pre-check quota con dialog di limite raggiunto
- **Linee 1268-1287:** Indicatore visivo quota utilizzata (es: "7/10")
- **Linee 1295-1326:** Warning quando rimangono ≤2 template
- **Linee 1465-1501:** Dialog specifico per errori quota con prompt upgrade

**Limiti Implementati per Tier:**
- **Free:** 10 template privati, 2 pubblici
- **Premium:** 50 template privati, 10 pubblici
- **Pro:** Illimitati (999 ciascuno)

**Features di Sicurezza:**
- Validazione quota lato server in Firebase
- Operazioni atomiche per aggiornamenti quota
- Gestione errori con fallback graceful
- Sync automatico tra template effettivi e contatori

**Risultato:** Sistema completo di gestione quote che previene abusi, controlla costi Firebase e incentiva upgrade a piani premium. L'UI mostra chiaramente lo stato della quota con warning proattivi.