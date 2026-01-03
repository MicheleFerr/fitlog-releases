# INFORMATIVA PRIVACY - FITlog Pro

**Data ultimo aggiornamento**: 21/12/2025
**Titolare del trattamento**: Michele, Brescia, Italia
**Email**: ferrara-michele@hotmail.it

---

## 1. INTRODUZIONE

Ai sensi del Regolamento UE 2016/679 (GDPR) e del D.Lgs. 196/2003 (Codice Privacy italiano), la presente informativa descrive come FITlog Pro raccoglie, utilizza e protegge i tuoi dati personali.

**FITlog Pro è un'app di tracciamento workout**. NON fornisce consigli medici, schede di allenamento o template. L'utente è responsabile per la propria sicurezza durante l'allenamento.

---

## 2. DATI RACCOLTI

### 2.1 Dati di Registrazione
- **Email**: Per autenticazione Firebase (obbligatorio)
- **UID Firebase**: Identificatore utente univoco (generato automaticamente)
- **Data registrazione**: Timestamp creazione account

### 2.2 Dati Workout (Facoltativi)
- **Nome esercizio**: Inserito manualmente dall'utente
- **Serie, ripetizioni, peso**: Valori numerici inseriti manualmente
- **Note workout**: Testo libero inserito dall'utente
- **Data/ora workout**: Timestamp allenamento

**⚠️ IMPORTANTE**: Questi dati sono considerati "dati personali" ma NON "dati sensibili salute" secondo GDPR Art. 9, poiché l'utente li inserisce volontariamente per tracking e non sono raccolti per finalità mediche.

### 2.3 Dati Tecnici
- **Indirizzo IP**: Raccolto da Firebase per sicurezza (conservato 30 giorni)
- **Device ID**: Per funzionalità app (non condiviso)
- **Versione app/OS**: Per supporto tecnico

### 2.4 Dati Analytics e Pubblicità
- **Firebase Analytics**: Eventi anonimi di utilizzo app (schermate visitate, funzionalità usate)
- **Google AdMob**: Identificatore pubblicitario (IDFA/GAID) per annunci personalizzati
- **Crash Reports**: Dati tecnici per debug (Firebase Crashlytics)

**Opt-out pubblicità personalizzata**: Puoi disabilitare la personalizzazione annunci nelle impostazioni del dispositivo (iOS: Impostazioni → Privacy → Pubblicità; Android: Impostazioni → Google → Annunci).

### 2.5 Dati NON Raccolti
- ❌ Dati biometrici (frequenza cardiaca, calorie)
- ❌ Dati salute (infortuni, patologie)
- ❌ Geolocalizzazione precisa
- ❌ Contatti, foto, microfono

---

## 3. FINALITÀ DEL TRATTAMENTO E BASE GIURIDICA

| Finalità | Base Giuridica (GDPR Art. 6) | Dati Utilizzati |
|----------|------------------------------|-----------------|
| Autenticazione utente | Esecuzione contratto | Email, UID |
| Salvataggio workout | Esecuzione contratto | Dati workout |
| Supporto tecnico | Legittimo interesse | Email, device info |
| Sicurezza account | Legittimo interesse | IP, timestamp login |

**Nessuna profilazione automatizzata** (GDPR Art. 22): FITlog Pro NON prende decisioni automatizzate basate sui tuoi dati.

---

## 4. DOVE SONO CONSERVATI I TUOI DATI

### 4.1 Database Locale (Hive)
- **Posizione**: Sul tuo smartphone (storage interno)
- **Contenuto**: Tutti i workout logs, impostazioni, preferenze
- **Cancellazione**: Disinstallazione app = cancellazione automatica

### 4.2 Firebase Cloud (Google)
- **Posizione**: Server Google Cloud (Regione EU - Frankfurt)
- **Contenuto**: Email, UID, timestamp autenticazione
- **Protezione**: Crittografia TLS 1.3 in transito, AES-256 at rest
- **DPA**: Data Processing Agreement firmato con Google (GDPR Art. 28)
- **Retention**: Dati conservati fino a cancellazione account

**⚠️ Trasferimenti Extra-UE**: Google può trasferire dati in USA per manutenzione server, con Standard Contractual Clauses (SCC) approvate UE.

---

## 5. CONDIVISIONE DATI CON TERZE PARTI

**FITlog Pro condivide dati con i seguenti fornitori di servizi**:

| Terza Parte | Scopo | Dati Condivisi | Base Legale |
|-------------|-------|----------------|-------------|
| Google Firebase | Autenticazione, database, analytics | Email, UID, IP, eventi uso | DPA Art. 28 GDPR |
| Google AdMob | Pubblicità in-app | IDFA/GAID, dati dispositivo | Consenso (Art. 6.1.a) |
| Firebase Crashlytics | Crash reporting | Dati tecnici errore | Legittimo interesse |
| Apple/Google (IAP) | Pagamenti subscription | Transaction ID (no dati personali) | Esecuzione contratto |
| ExerciseDB | Immagini dimostrative esercizi | Nessuno (immagini caricate dai loro server) | Legittimo interesse |

### 5.1 Immagini Dimostrative Esercizi

Le immagini GIF dimostrative degli esercizi visualizzate in questa app provengono da **ExerciseDB** (https://exercisedb.io). Queste immagini vengono caricate direttamente dai server ExerciseDB per mostrare la corretta esecuzione degli esercizi. Nessun dato personale viene condiviso con ExerciseDB - viene effettuata solo la richiesta dell'immagine.

**NO vendita dati a broker**, **NO condivisione con terzi non elencati**.

⚠️ **Pubblicità**: L'app mostra annunci tramite Google AdMob. Puoi disattivare la personalizzazione nelle impostazioni del dispositivo.

---

## 6. I TUOI DIRITTI (GDPR Artt. 15-22)

Hai diritto di:

### 6.1 Accesso (Art. 15)
Richiedere copia di tutti i tuoi dati: **Settings → Privacy → Esporta Dati**

### 6.2 Rettifica (Art. 16)
Correggere dati errati: Modifica direttamente nell'app

### 6.3 Cancellazione (Art. 17 - "Diritto all'Oblio")
Eliminare account e dati: **Settings → Account → Elimina Account**
- Effetto: Cancellazione immediata database locale + Firebase (30 giorni per backup)

### 6.4 Limitazione Trattamento (Art. 18)
Sospendere temporaneamente processing: Contatta ferrara-michele@hotmail.it

### 6.5 Portabilità (Art. 20)
Esportare dati in formato JSON: **Settings → Privacy → Esporta Dati**

### 6.6 Opposizione (Art. 21)
Opporti a trattamento per legittimo interesse: Contatta ferrara-michele@hotmail.it

### 6.7 Reclamo (Art. 77)
Presentare reclamo a: **Garante Privacy Italia** - garante@gpdp.it - Tel. 06 696771

---

## 7. SICUREZZA DATI

Misure tecniche e organizzative (GDPR Art. 32):
- ✅ Crittografia end-to-end (TLS 1.3)
- ✅ Autenticazione Firebase (password hashing bcrypt)
- ✅ Firestore Security Rules (isolamento dati utente)
- ✅ Rate limiting (protezione brute-force)
- ✅ Backup giornalieri (retention 30 giorni)
- ✅ Audit logging (accessi admin)

**Data Breach Notification**: In caso di violazione dati, notifica entro 72 ore a Garante Privacy + utenti interessati.

---

## 8. CONSERVAZIONE DATI

| Tipo Dato | Retention | Motivo |
|-----------|-----------|--------|
| Account attivo | Fino a cancellazione | Esecuzione servizio |
| Account inattivo | 24 mesi inattività → cancellazione | Minimizzazione GDPR |
| Backup | 30 giorni | Disaster recovery |
| Log sicurezza | 12 mesi | Conformità legale |

---

## 9. MINORI (Under-18)

**FITlog Pro vieta registrazione under-14** (GDPR Art. 8 + Codice Privacy italiano).

**14-17 anni**: Consentito con:
- Dichiarazione età veritiera
- **Responsabilità genitori**: I genitori sono responsabili per uso app da parte minori
- Disclaimer maggiorato (rischio infortuni)

Se scopriamo utente under-14, cancelleremo account immediatamente.

---

## 10. MODIFICHE PRIVACY POLICY

Aggiornamenti: Notifica in-app 30 giorni prima. Continuare a usare app = accettazione nuova policy.

**Versione attuale**: 1.1 (21/12/2025)
**Storico versioni**: docs/legal/PRIVACY_POLICY_CHANGELOG.md

---

## 11. CONTATTI

**Titolare del Trattamento**:
- Nome: Michele
- Località: Brescia, Italia
- Email: ferrara-michele@hotmail.it

**Data Protection Officer (DPO)**: Non obbligatorio (singolo sviluppatore, <10.000 utenti)

**Garante Privacy Italia**:
- Sito: https://www.garanteprivacy.it
- Email: garante@gpdp.it
- Telefono: 06 696771

---

**CONSENSO ESPLICITO**

Utilizzando FITlog Pro, dichiari di:
- ✅ Aver letto e compreso questa informativa
- ✅ Acconsentire al trattamento dati descritto
- ✅ Avere almeno 14 anni (o consenso genitori se 14-17)
- ✅ Accettare i Termini di Servizio

**Data accettazione**: [Registrata automaticamente all'iscrizione]
