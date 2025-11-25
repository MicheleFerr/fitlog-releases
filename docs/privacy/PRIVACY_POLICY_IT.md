# Informativa sulla Privacy

**Data di Entrata in Vigore**: 24 Gennaio 2025
**Ultimo Aggiornamento**: 24 Gennaio 2025
**Versione**: 1.0

---

## 1. Introduzione

Questa Informativa sulla Privacy descrive come FitLog Pro ("noi", "nostro" o "ci") raccoglie, utilizza, elabora e protegge le tue informazioni personali quando utilizzi la nostra applicazione mobile (l'"App").

Ci impegniamo a proteggere la tua privacy e a rispettare il Regolamento Generale sulla Protezione dei Dati (GDPR) UE 2016/679, il California Consumer Privacy Act (CCPA) e altre leggi sulla privacy applicabili.

**Informazioni sul Titolare del Trattamento**:
- **Nome App**: FitLog Pro
- **Sviluppatore**: [Nome della Tua Azienda]
- **Email di Contatto**: privacy@fitlogpro.com
- **Indirizzo**: [Tuo Indirizzo]

Utilizzando l'App, acconsenti alle pratiche sui dati descritte in questa informativa.

---

## 2. Informazioni che Raccogliamo

### 2.1 Informazioni Personali (Fornite Direttamente)

Quando utilizzi l'App, potresti fornire volontariamente le seguenti informazioni personali:

#### Metriche Essenziali (Richieste durante l'onboarding)
- **Peso** (kg o libbre)
- **Percentuale di Grasso Corporeo** (%)
- **Altezza** (cm o pollici)
- **Massa Magra** (kg)
- **IMC** (calcolato)
- **Metabolismo Basale** (kcal/giorno, calcolato)

#### Misure Corporee (Richieste su richiesta, consenso Just-in-Time)
- **Circonferenze**: Collo, Spalle, Petto, Vita, Addome, Fianchi, Bicipiti (S/D), Avambracci (S/D), Cosce (S/D), Polpacci (S/D)

#### Parametri Vitali (Richiesti su richiesta, consenso Just-in-Time)
- **Temperatura Corporea** (°C o °F)
- **Massa Idrica** (%)
- **Massa Ossea** (kg)

#### Informazioni Opzionali
- **Note**: Annotazioni testuali per le misurazioni (es. "Peso post-allenamento")
- **Foto**: Foto di progresso (salvate solo localmente, non trasmesse)

### 2.2 Informazioni Tecniche (Raccolte Automaticamente)

- **Informazioni sul Dispositivo**: Modello dispositivo, sistema operativo (iOS/Android), versione app
- **Dati di Utilizzo**: Funzionalità utilizzate, timestamp delle azioni (aggregati, anonimi)
- **Report di Crash**: Log tecnici degli errori (nessun dato personale)

### 2.3 Integrazione Piattaforme Salute (Solo con Consenso Esplicito)

Con il tuo consenso esplicito, potremmo sincronizzare i dati con:

- **Apple HealthKit** (iOS): Peso, % Grasso Corporeo, Altezza
- **Google Health Connect** (Android): Peso, % Grasso Corporeo, Altezza

**Importante**: Controlli quali metriche vengono sincronizzate. Accediamo solo ai dati che autorizzi esplicitamente.

---

## 3. Base Giuridica del Trattamento (GDPR Articolo 6)

Trattiamo i tuoi dati personali sulla base dei seguenti fondamenti giuridici:

1. **Consenso (Articolo 6(1)(a))**: Consenti esplicitamente al trattamento di metriche specifiche (Essenziali, Misure, Parametri Vitali)
2. **Necessità Contrattuale (Articolo 6(1)(b))**: Il trattamento è necessario per fornire le funzionalità dell'App
3. **Interessi Legittimi (Articolo 6(1)(f))**: Segnalazione crash e analisi per migliorare le prestazioni dell'App (anonimizzato)

---

## 4. Come Utilizziamo le Tue Informazioni

Utilizziamo i tuoi dati personali per i seguenti scopi:

### 4.1 Funzionalità Principali
- **Monitoraggio Progressi**: Memorizzare e visualizzare le tue misure corporee nel tempo
- **Analisi Tendenze**: Calcolare e visualizzare grafici di progresso (perdita/guadagno peso, composizione corporea)
- **Sincronizzazione Salute**: Sincronizzare le misurazioni con Apple HealthKit o Google Health Connect (con consenso)

### 4.2 Analisi e Miglioramento (Anonimizzato)
- **Analisi Utilizzo App**: Comprendere quali funzionalità sono più popolari (aggregato, nessun PII)
- **Monitoraggio Prestazioni**: Rilevare crash e bug (nessuna misurazione personale registrata)

### 4.3 Sicurezza e Conformità
- **Crittografia Dati**: Crittografare tutte le misurazioni a riposo (AES-256-GCM)
- **Log di Audit**: Tracciare modifiche al consenso, esportazioni dati, eliminazioni (conformità GDPR)

---

## 5. Archiviazione e Crittografia Dati (GDPR Articolo 32)

### 5.1 Crittografia a Riposo
Tutte le misurazioni personali sono crittografate utilizzando **AES-256-GCM** (Advanced Encryption Standard con Galois/Counter Mode) prima dell'archiviazione:

- **Chiavi di Crittografia**: Memorizzate in iOS Secure Enclave o Android Keystore (hardware-backed)
- **Rotazione Chiavi**: Rotazione automatica delle chiavi ogni 90 giorni
- **Crittografia Per-Utente**: Ogni utente ha una chiave di crittografia unica (dati isolati)

### 5.2 Posizioni di Archiviazione

| Tipo di Dati | Posizione di Archiviazione | Crittografia |
|--------------|----------------------------|--------------|
| Misurazioni | Dispositivo locale (database Hive) | AES-256-GCM |
| Misurazioni | Firebase Firestore (backup cloud) | AES-256-GCM + TLS |
| Chiavi di Crittografia | iOS Secure Enclave / Android Keystore | Hardware-backed |
| Foto | Solo dispositivo locale (mai caricate) | Crittografia filesystem iOS/Android |

### 5.3 Conservazione Dati

- **Misurazioni Attive**: Conservate finché il tuo account è attivo
- **Misurazioni Eliminate**: Soft-delete con periodo di conservazione di 30 giorni (recuperabili se accidentale)
- **Eliminazione Permanente**: Dopo 30 giorni, o immediatamente su richiesta
- **Log di Audit**: Conservati per 2 anni (conformità GDPR Articolo 30)

---

## 6. Condivisione Dati e Terze Parti

**NON** vendiamo i tuoi dati personali a terze parti.

Potremmo condividere dati limitati con i seguenti fornitori di servizi:

### 6.1 Fornitori di Servizi Essenziali

| Fornitore | Scopo | Dati Condivisi | Informativa Privacy |
|-----------|-------|----------------|---------------------|
| **Firebase (Google)** | Database cloud, autenticazione | ID utente, misurazioni crittografate, email | [Privacy Firebase](https://firebase.google.com/support/privacy) |
| **Apple HealthKit** | Sincronizzazione dati salute (solo iOS) | Peso, % Grasso Corporeo, Altezza (opt-in) | [Privacy Apple](https://www.apple.com/it/privacy/) |
| **Google Health Connect** | Sincronizzazione dati salute (solo Android) | Peso, % Grasso Corporeo, Altezza (opt-in) | [Privacy Google](https://policies.google.com/privacy?hl=it) |

### 6.2 Analisi (Anonimizzata)

| Fornitore | Scopo | Dati Condivisi | Opt-Out |
|-----------|-------|----------------|---------|
| **Firebase Analytics** | Tendenze utilizzo app (aggregato) | Tipo dispositivo, versione app (nessun PII) | Impostazioni → Privacy → Analisi |

**Minimizzazione Dati**: Rimuoviamo tutte le Informazioni Personalmente Identificabili (PII) prima della trasmissione analytics. Gli ID analytics sono hash e non possono essere collegati alla tua identità.

---

## 7. I Tuoi Diritti ai sensi del GDPR (Articoli 15-22)

Hai i seguenti diritti riguardo ai tuoi dati personali:

### 7.1 Diritto di Accesso (Articolo 15)
Richiedere una copia di tutti i dati che conserviamo su di te.

**Come**: Impostazioni → Privacy → Esporta i Miei Dati (formato JSON)

### 7.2 Diritto di Rettifica (Articolo 16)
Correggere dati inesatti o incompleti.

**Come**: Modifica le misurazioni direttamente nell'App

### 7.3 Diritto alla Cancellazione ("Diritto all'Oblio", Articolo 17)
Eliminare tutti i tuoi dati personali.

**Come**: Impostazioni → Privacy → Elimina Tutti i Dati

**Opzioni**:
- Eliminazione Soft: Periodo di recupero di 30 giorni
- Eliminazione Permanente: Immediata e irreversibile

### 7.4 Diritto alla Portabilità dei Dati (Articolo 20)
Ricevere i tuoi dati in un formato leggibile da dispositivo (JSON).

**Come**: Impostazioni → Privacy → Esporta i Miei Dati → formato JSON

### 7.5 Diritto di Limitazione del Trattamento (Articolo 18)
Limitare come trattiamo i tuoi dati (es. revocare consenso sincronizzazione salute).

**Come**: Impostazioni → Privacy → Gestisci Consenso

### 7.6 Diritto di Opposizione (Articolo 21)
Opporsi al trattamento basato su interessi legittimi (es. analytics).

**Come**: Impostazioni → Privacy → Analisi → Disabilita

### 7.7 Diritto di Revocare il Consenso (Articolo 7(3))
Revocare il consenso per gruppi di metriche specifiche in qualsiasi momento.

**Come**: Impostazioni → Privacy → Gestisci Consenso → Revoca

**Effetto**: Cesseremo di sincronizzare le metriche revocate con le piattaforme salute e le elimineremo entro 30 giorni.

---

## 8. Gestione del Consenso (GDPR Articolo 7)

Implementiamo il **Consenso Just-in-Time** per un'esperienza utente ottimale:

### 8.1 Gruppi di Consenso

| Gruppo | Metriche Incluse | Quando Richiesto | Revocabile |
|--------|------------------|------------------|-----------|
| **Essenziali** | Peso, % Grasso Corporeo, Altezza, Massa Magra, IMC, MB | Onboarding (primo avvio app) | ✅ Sì |
| **Misure** | 13 Circonferenze (Collo, Petto, Vita, ecc.) | Quando tocchi "Traccia Misure Corporee" | ✅ Sì |
| **Parametri Vitali** | Temperatura Corporea, Massa Idrica, Massa Ossea | Quando tocchi "Traccia Parametri Vitali" | ✅ Sì |

### 8.2 Macchina a Stati del Consenso

- **Non Richiesto**: Stato predefinito (nessun dialogo di consenso mostrato)
- **Concesso**: Hai esplicitamente accettato (checkbox selezionata, "Accetta" toccato)
- **Negato**: Hai esplicitamente rifiutato (dialogo di consenso chiuso)

### 8.3 Traccia di Audit del Consenso

Registriamo quanto segue per conformità (GDPR Articolo 30):

- Timestamp del consenso (formato ISO 8601)
- Indirizzo IP (ultimo ottetto mascherato: `192.168.1.***`)
- Tipo di dispositivo e versione app
- Stringa user agent

**Scopo**: Provare la conformità in caso di audit normativo.

---

## 9. Privacy dei Minori (COPPA)

FitLog Pro **NON** è destinato a bambini di età inferiore ai 13 anni. Non raccogliamo consapevolmente informazioni personali da bambini.

Se sei un genitore e ritieni che tuo figlio ci abbia fornito dati personali, contattaci a privacy@fitlogpro.com e li elimineremo entro 30 giorni.

---

## 10. Trasferimenti Internazionali di Dati (GDPR Articolo 44-50)

I tuoi dati potrebbero essere trasferiti e archiviati in paesi al di fuori dello Spazio Economico Europeo (SEE):

| Servizio | Posizione | Garanzie |
|----------|-----------|----------|
| **Firebase (Google Cloud)** | USA (multi-regione) | EU-U.S. Data Privacy Framework, Clausole Contrattuali Standard (SCC) |

Garantiamo una protezione adeguata attraverso:
- **Clausole Contrattuali Standard** (approvate dalla Commissione UE)
- **Crittografia in Transito**: TLS 1.3
- **Crittografia a Riposo**: AES-256-GCM

---

## 11. Notifica di Violazione dei Dati (GDPR Articolo 33-34)

In caso di violazione dei dati che riguardi i tuoi dati personali:

- Notificheremo l'autorità di controllo competente entro **72 ore**
- Ti notificheremo direttamente se la violazione comporta un **alto rischio** per i tuoi diritti
- La notifica includerà: natura della violazione, conseguenze probabili, misure di mitigazione

**Contatto**: privacy@fitlogpro.com

---

## 12. Processo Decisionale Automatizzato (GDPR Articolo 22)

**NON** utilizziamo il processo decisionale automatizzato o la profilazione che producono effetti legali o ti influenzano in modo significativo.

---

## 13. Cookie e Tecnologie di Tracciamento

L'App **NON** utilizza cookie (tracciamento basato su web).

Utilizziamo le seguenti tecnologie di archiviazione locale:

| Tecnologia | Scopo | Dati Memorizzati | Eliminabile |
|-----------|-------|------------------|------------|
| **Hive** (database locale) | Memorizzare misurazioni | Misurazioni crittografate | ✅ Sì (Impostazioni → Elimina Dati) |
| **Secure Storage** | Memorizzare chiavi di crittografia | Chiavi AES-256 | ❌ No (eliminate con app) |
| **UserDefaults** (iOS) / SharedPreferences (Android) | Impostazioni app | Preferenza lingua, tema | ✅ Sì (Impostazioni → Ripristina) |

---

## 14. Link di Terze Parti

L'App potrebbe contenere link a siti web di terze parti (es. link alle informative privacy di Firebase, HealthKit).

**NON** siamo responsabili delle pratiche sulla privacy di queste terze parti. Ti preghiamo di rivedere le loro informative sulla privacy.

---

## 15. Modifiche a Questa Informativa sulla Privacy

Potremmo aggiornare questa Informativa sulla Privacy di tanto in tanto. Le modifiche saranno effettive immediatamente dopo la pubblicazione nell'App.

**Notifica**: Ti verrà richiesto di rivedere e riaccettare l'informativa aggiornata al prossimo avvio dell'app.

**Storico Versioni**:
- **v1.0** (24 Gen 2025): Informativa iniziale conforme GDPR

---

## 16. Contattaci

Se hai domande su questa Informativa sulla Privacy o desideri esercitare i tuoi diritti, contattaci:

**Email**: privacy@fitlogpro.com
**Oggetto**: "Richiesta Privacy - [Tipo di Richiesta]"
**Tempo di Risposta**: Entro 30 giorni

**Autorità di Controllo** (utenti UE):
Hai il diritto di presentare un reclamo alla tua autorità locale per la protezione dei dati se ritieni che abbiamo violato il GDPR.

- **Trova la tua autorità**: https://edpb.europa.eu/about-edpb/board/members_it

---

## 17. Residenti in California (CCPA)

Se sei residente in California, hai diritti aggiuntivi ai sensi del California Consumer Privacy Act (CCPA):

- **Diritto di Conoscere**: Categorie di informazioni personali raccolte
- **Diritto di Eliminare**: Eliminare informazioni personali
- **Diritto di Opt-Out**: Rinunciare alla vendita di informazioni personali (non vendiamo dati)
- **Non Discriminazione**: Non ti discrimineremo per l'esercizio dei tuoi diritti

**Contatto**: privacy@fitlogpro.com (Oggetto: "Richiesta CCPA")

---

## 18. Riconoscimento

Utilizzando FitLog Pro, riconosci di aver letto, compreso e accettato di essere vincolato da questa Informativa sulla Privacy.

---

**Versione Documento**: 1.0
**Ultima Revisione**: 24 Gennaio 2025
**Prossima Data di Revisione**: 24 Luglio 2025 (ciclo di revisione semestrale)
