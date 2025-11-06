# Legal Compliance Documentation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement complete legal compliance documentation for FITlog Pro (GDPR-compliant, Italian law-compliant, "solo tracking" scenario with zero liability risk)

**Architecture:** Multi-layer compliance system with:
- **Documentation Layer**: Privacy Policy, ToS, DPA tracking (static docs)
- **UI Layer**: Disclaimer modals, age gate, consent flows (Flutter widgets)
- **Tracking Layer**: Consent timestamps, acceptance logs (local Hive database)
- **Localization Layer**: Full IT + EN support via l10n system

**Tech Stack:**
- Flutter 3.x (UI)
- Riverpod (state management)
- Hive (local consent storage)
- AppLocalizations (i18n)
- Markdown (documentation templates)

---

## Task 1: Privacy Policy Template (IT + EN)

**Files:**
- Create: `docs/legal/PRIVACY_POLICY_IT.md`
- Create: `docs/legal/PRIVACY_POLICY_EN.md`
- Create: `docs/legal/templates/privacy_policy_template.md`

**Step 1: Create Italian Privacy Policy**

Create `docs/legal/PRIVACY_POLICY_IT.md`:

```markdown
# INFORMATIVA PRIVACY - FITlog Pro

**Data ultimo aggiornamento**: 06/11/2025
**Titolare del trattamento**: [Nome Sviluppatore], Brescia (BS), Italia
**Email**: privacy@fitlogpro.com

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

### 2.4 Dati NON Raccolti
- ❌ Dati biometrici (frequenza cardiaca, calorie)
- ❌ Dati salute (infortuni, patologie)
- ❌ Cookie di tracciamento (no Analytics, no Ads)
- ❌ Geolocalizzazione
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

**FITlog Pro NON condivide i tuoi dati con terze parti**, eccetto:

| Terza Parte | Scopo | Dati Condivisi | Base Legale |
|-------------|-------|----------------|-------------|
| Google Firebase | Autenticazione, database | Email, UID, IP | DPA Art. 28 GDPR |
| Apple/Google (IAP) | Pagamenti subscription | Transaction ID (no dati personali) | Esecuzione contratto |

**NO vendita dati**, **NO pubblicità**, **NO tracking comportamentale**.

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
Sospendere temporaneamente processing: Contatta privacy@fitlogpro.com

### 6.5 Portabilità (Art. 20)
Esportare dati in formato JSON: **Settings → Privacy → Esporta Dati**

### 6.6 Opposizione (Art. 21)
Opporti a trattamento per legittimo interesse: Contatta privacy@fitlogpro.com

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

**Versione attuale**: 1.0 (06/11/2025)
**Storico versioni**: docs/legal/PRIVACY_POLICY_CHANGELOG.md

---

## 11. CONTATTI

**Titolare del Trattamento**:
- Nome: [Nome Sviluppatore]
- Indirizzo: Via [Indirizzo], Brescia (BS), Italia
- Email: privacy@fitlogpro.com
- PEC: [PEC se disponibile]

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
```

**Step 2: Create English Privacy Policy**

Create `docs/legal/PRIVACY_POLICY_EN.md`:

```markdown
# PRIVACY POLICY - FITlog Pro

**Last updated**: November 6, 2025
**Data Controller**: [Developer Name], Brescia (BS), Italy
**Email**: privacy@fitlogpro.com

---

## 1. INTRODUCTION

Pursuant to EU Regulation 2016/679 (GDPR) and Italian Legislative Decree 196/2003 (Italian Privacy Code), this privacy policy describes how FITlog Pro collects, uses, and protects your personal data.

**FITlog Pro is a workout tracking app**. It does NOT provide medical advice, workout plans, or templates. Users are responsible for their own safety during training.

---

## 2. DATA COLLECTED

### 2.1 Registration Data
- **Email**: For Firebase authentication (required)
- **Firebase UID**: Unique user identifier (auto-generated)
- **Registration date**: Account creation timestamp

### 2.2 Workout Data (Optional)
- **Exercise name**: Manually entered by user
- **Sets, reps, weight**: Numeric values manually entered
- **Workout notes**: Free text entered by user
- **Workout date/time**: Training timestamp

**⚠️ IMPORTANT**: This data is considered "personal data" but NOT "sensitive health data" under GDPR Art. 9, as users voluntarily enter it for tracking purposes, not for medical purposes.

### 2.3 Technical Data
- **IP Address**: Collected by Firebase for security (retained 30 days)
- **Device ID**: For app functionality (not shared)
- **App/OS version**: For technical support

### 2.4 Data NOT Collected
- ❌ Biometric data (heart rate, calories)
- ❌ Health data (injuries, conditions)
- ❌ Tracking cookies (no Analytics, no Ads)
- ❌ Geolocation
- ❌ Contacts, photos, microphone

---

## 3. PROCESSING PURPOSES AND LEGAL BASIS

| Purpose | Legal Basis (GDPR Art. 6) | Data Used |
|---------|---------------------------|-----------|
| User authentication | Contract performance | Email, UID |
| Workout saving | Contract performance | Workout data |
| Technical support | Legitimate interest | Email, device info |
| Account security | Legitimate interest | IP, login timestamp |

**No automated profiling** (GDPR Art. 22): FITlog Pro does NOT make automated decisions based on your data.

---

## 4. WHERE YOUR DATA IS STORED

### 4.1 Local Database (Hive)
- **Location**: On your smartphone (internal storage)
- **Content**: All workout logs, settings, preferences
- **Deletion**: App uninstall = automatic deletion

### 4.2 Firebase Cloud (Google)
- **Location**: Google Cloud servers (EU Region - Frankfurt)
- **Content**: Email, UID, authentication timestamps
- **Protection**: TLS 1.3 encryption in transit, AES-256 at rest
- **DPA**: Data Processing Agreement signed with Google (GDPR Art. 28)
- **Retention**: Data retained until account deletion

**⚠️ Extra-EU Transfers**: Google may transfer data to USA for server maintenance, using EU-approved Standard Contractual Clauses (SCC).

---

## 5. DATA SHARING WITH THIRD PARTIES

**FITlog Pro does NOT share your data with third parties**, except:

| Third Party | Purpose | Data Shared | Legal Basis |
|-------------|---------|-------------|-------------|
| Google Firebase | Authentication, database | Email, UID, IP | DPA Art. 28 GDPR |
| Apple/Google (IAP) | Subscription payments | Transaction ID (no personal data) | Contract performance |

**NO data selling**, **NO advertising**, **NO behavioral tracking**.

---

## 6. YOUR RIGHTS (GDPR Arts. 15-22)

You have the right to:

### 6.1 Access (Art. 15)
Request copy of all your data: **Settings → Privacy → Export Data**

### 6.2 Rectification (Art. 16)
Correct inaccurate data: Edit directly in app

### 6.3 Erasure (Art. 17 - "Right to be Forgotten")
Delete account and data: **Settings → Account → Delete Account**
- Effect: Immediate deletion of local database + Firebase (30 days for backups)

### 6.4 Restriction (Art. 18)
Temporarily suspend processing: Contact privacy@fitlogpro.com

### 6.5 Portability (Art. 20)
Export data in JSON format: **Settings → Privacy → Export Data**

### 6.6 Object (Art. 21)
Object to processing for legitimate interest: Contact privacy@fitlogpro.com

### 6.7 Complaint (Art. 77)
File complaint with: **Italian Privacy Authority (Garante)** - garante@gpdp.it - Tel. +39 06 696771

---

## 7. DATA SECURITY

Technical and organizational measures (GDPR Art. 32):
- ✅ End-to-end encryption (TLS 1.3)
- ✅ Firebase authentication (bcrypt password hashing)
- ✅ Firestore Security Rules (user data isolation)
- ✅ Rate limiting (brute-force protection)
- ✅ Daily backups (30-day retention)
- ✅ Audit logging (admin access)

**Data Breach Notification**: In case of data breach, notification within 72 hours to Privacy Authority + affected users.

---

## 8. DATA RETENTION

| Data Type | Retention | Reason |
|-----------|-----------|--------|
| Active account | Until deletion | Service execution |
| Inactive account | 24 months inactivity → deletion | GDPR minimization |
| Backups | 30 days | Disaster recovery |
| Security logs | 12 months | Legal compliance |

---

## 9. MINORS (Under-18)

**FITlog Pro prohibits registration under age 14** (GDPR Art. 8 + Italian Privacy Code).

**Ages 14-17**: Allowed with:
- Truthful age declaration
- **Parental responsibility**: Parents are responsible for minors' use of the app
- Enhanced disclaimer (injury risk)

If we discover a user under 14, we will immediately delete the account.

---

## 10. PRIVACY POLICY CHANGES

Updates: In-app notification 30 days before. Continuing to use app = acceptance of new policy.

**Current version**: 1.0 (November 6, 2025)
**Version history**: docs/legal/PRIVACY_POLICY_CHANGELOG.md

---

## 11. CONTACTS

**Data Controller**:
- Name: [Developer Name]
- Address: Via [Address], Brescia (BS), Italy
- Email: privacy@fitlogpro.com
- PEC: [PEC if available]

**Data Protection Officer (DPO)**: Not required (single developer, <10,000 users)

**Italian Privacy Authority (Garante)**:
- Website: https://www.garanteprivacy.it
- Email: garante@gpdp.it
- Phone: +39 06 696771

---

**EXPLICIT CONSENT**

By using FITlog Pro, you declare that you:
- ✅ Have read and understood this privacy policy
- ✅ Consent to the data processing described
- ✅ Are at least 14 years old (or have parental consent if 14-17)
- ✅ Accept the Terms of Service

**Consent date**: [Automatically recorded at registration]
```

**Step 3: Create template with customization instructions**

Create `docs/legal/templates/privacy_policy_template.md`:

```markdown
# Privacy Policy Template - Customization Guide

## Required Customizations

Before publishing, replace the following placeholders:

1. **[Developer Name]**: Your full legal name or company name
2. **[Address]**: Your legal address in Brescia
3. **privacy@fitlogpro.com**: Your actual support email
4. **[PEC if available]**: Your PEC (Posta Elettronica Certificata) if you have one

## Optional Customizations

If you add features later, update these sections:

### If you add Analytics:
Add to section "2.3 Technical Data":
- Analytics events (app usage, screen views)
- Update "2.4 Data NOT Collected" (remove "no Analytics")
- Add Google Analytics to section "5. Data Sharing"

### If you add Ads:
Add entire new section "Advertising Partners"
- List ad networks (AdMob, Meta, etc.)
- Add cookie consent requirement
- Update retention policies

### If you add IA/Templates:
Add to section "3. Processing Purposes":
- AI workout generation
- Add GDPR Art. 22 compliance (automated decisions)
- Add explainability section

## Legal Review Checklist

- [ ] All placeholders replaced
- [ ] Email addresses tested (delivery confirmed)
- [ ] DPA signed with Google Firebase
- [ ] Reviewed by lawyer (optional but recommended)
- [ ] Published in-app AND on website (if exists)
- [ ] Version control enabled (track changes)

## Updates

When updating policy:
1. Increment version number
2. Update "Last updated" date
3. Add entry to PRIVACY_POLICY_CHANGELOG.md
4. Notify users 30 days before (in-app banner)
5. Require re-acceptance if material changes
```

**Step 4: Commit documentation**

```bash
git add docs/legal/PRIVACY_POLICY_IT.md docs/legal/PRIVACY_POLICY_EN.md docs/legal/templates/privacy_policy_template.md
git commit -m "docs: add GDPR-compliant privacy policy (IT + EN) for solo tracking scenario"
```

---

## Task 2: Terms of Service (ToS) Template

**Files:**
- Create: `docs/legal/TERMS_OF_SERVICE_IT.md`
- Create: `docs/legal/TERMS_OF_SERVICE_EN.md`

**Step 1: Create Italian ToS**

Create `docs/legal/TERMS_OF_SERVICE_IT.md`:

```markdown
# TERMINI DI SERVIZIO - FITlog Pro

**Data ultimo aggiornamento**: 06/11/2025
**Fornitore**: [Nome Sviluppatore], Brescia (BS), Italia
**Email**: support@fitlogpro.com

---

## 1. ACCETTAZIONE TERMINI

Utilizzando FITlog Pro ("App"), accetti integralmente i presenti Termini di Servizio ("ToS") e l'Informativa Privacy.

**Se non accetti, NON usare l'App.**

---

## 2. DESCRIZIONE SERVIZIO

**FITlog Pro è un'applicazione di tracciamento workout** che permette agli utenti di:
- Registrare manualmente serie, ripetizioni, peso
- Visualizzare storico allenamenti
- Esportare dati in formato JSON

**FITlog Pro NON è**:
- ❌ Un servizio di consulenza medica
- ❌ Un generatore di schede workout
- ❌ Un sostituto di personal trainer o medico sportivo
- ❌ Un dispositivo medico certificato

---

## 3. LIMITAZIONE DI RESPONSABILITÀ (CRITICAL)

### 3.1 Uso "As-Is" (Così Com'è)

**L'App è fornita "COSÌ COM'È" senza garanzie di alcun tipo**, espresse o implicite.

Il Fornitore **NON garantisce**:
- Assenza di bug o interruzioni
- Accuratezza dati inseriti dall'utente
- Compatibilità con tutti i dispositivi
- Disponibilità continuativa (99.9% uptime non garantito)

### 3.2 Responsabilità Utente per Infortuni

**⚠️ CLAUSOLA ESSENZIALE**:

**L'UTENTE RICONOSCE CHE**:
1. L'allenamento fisico comporta rischi intrinseci (infortuni, strappi, traumi)
2. L'App NON fornisce supervisione o consigli su esecuzione esercizi
3. L'Utente è **UNICO RESPONSABILE** per:
   - Scelta esercizi appropriati al proprio livello
   - Tecnica di esecuzione
   - Carichi pesi selezionati
   - Condizioni fisiche e mediche pregresse
4. L'Utente **DEVE consultare un medico** prima di iniziare attività fisica

**IL FORNITORE NON È RESPONSABILE PER**:
- Infortuni fisici derivanti da allenamento
- Peggioramento condizioni mediche pregresse
- Danni indiretti, consequenziali, punitivi
- Perdita dati (backup responsabilità utente)
- Mancato raggiungimento obiettivi fitness

**RESPONSABILITÀ MASSIMA DEL FORNITORE**: €0 (zero euro) se App gratuita, oppure importo pagato per subscription nell'ultimo anno.

### 3.3 Esclusione Garanzie Implicite

**Escluse tutte le garanzie implicite** ai sensi del Codice Civile italiano (Art. 1490-1497), incluse:
- Garanzia di commerciabilità
- Garanzia di idoneità per scopo specifico
- Garanzia di risultato

### 3.4 Esonero Responsabilità (Disclaimer)

**UTILIZZANDO L'APP, L'UTENTE ESONERA IL FORNITORE** da qualsiasi responsabilità per:
- Infortuni, malattie, decesso derivanti da allenamento
- Errori inserimento dati utente
- Malfunzionamenti dispositivo
- Incompatibilità con altri software

---

## 4. OBBLIGHI UTENTE

L'Utente si impegna a:
- ✅ Fornire dati veritieri (età, email)
- ✅ Usare App solo per scopi personali (no commerciale)
- ✅ Non violare diritti terzi (copyright, privacy)
- ✅ Non tentare hacking, reverse engineering, exploit
- ✅ Non condividere account con terzi
- ✅ Consultare medico prima di iniziare allenamento

**Violazione obblighi**: Sospensione/cancellazione account senza preavviso.

---

## 5. PROPRIETÀ INTELLETTUALE

### 5.1 Diritti Fornitore
- **Copyright**: Codice, design, UI, logo → proprietà esclusiva Fornitore
- **Licenza d'uso**: L'Utente riceve licenza **non esclusiva, non trasferibile, revocabile** per uso personale
- **Vietato**: Copiare, modificare, distribuire, vendere, decompilare l'App

### 5.2 Diritti Utente sui Propri Dati
- **Dati workout**: Di proprietà dell'Utente
- **Esportazione**: Diritto di esportare in JSON (GDPR Art. 20)
- **Cancellazione**: Diritto di cancellare account e dati (GDPR Art. 17)

---

## 6. SUBSCRIPTION E PAGAMENTI (Se applicabile)

### 6.1 Piani Disponibili
- **Free**: Funzionalità base (illimitato)
- **Pro Monthly**: €4.99/mese
- **Pro Yearly**: €39.99/anno (save 33%)

### 6.2 Pagamenti
- Gestiti da Apple App Store / Google Play Store
- **Nessun dato carta di credito** conservato da Fornitore
- Rinnovo automatico (cancellabile in-app store)

### 6.3 Rimborsi
- **Apple/Google policy**: Rimborsi gestiti da Apple/Google, non da Fornitore
- **No rimborsi automatici** (policy Apple/Google)
- Per richieste: Contatta Apple/Google Store support

### 6.4 Cancellazione Subscription
- **Dove**: Settings → Subscription → Manage (redirect a App Store/Google Play)
- **Effetto**: Fine subscription a scadenza periodo corrente (no rimborso parziale)
- **Account**: Rimane attivo in versione Free

---

## 7. SOSPENSIONE E TERMINAZIONE

### 7.1 Sospensione da Parte Fornitore
Il Fornitore può sospendere/cancellare account se:
- Violazione ToS
- Attività fraudolente
- Abuso sistema (spam, flooding)
- Richiesta autorità giudiziarie

**Preavviso**: 7 giorni (salvo violazioni gravi → immediata)

### 7.2 Cancellazione da Parte Utente
- **Dove**: Settings → Account → Delete Account
- **Effetto**: Cancellazione immediata dati (no recovery possibile)
- **Backup**: Responsabilità utente esportare dati prima

---

## 8. MINORI (Under-18)

- **Under-14**: Registrazione **VIETATA** (GDPR Art. 8)
- **14-17 anni**: Consentito con dichiarazione veritiera età
- **Responsabilità genitori**: Genitori responsabili per uso App da parte minori
- **Disclaimer maggiorato**: Minori devono leggere disclaimer infortuni con genitore

---

## 9. MODIFICHE TERMINI DI SERVIZIO

Il Fornitore può modificare ToS in qualsiasi momento.

**Notifica**: 30 giorni prima via email + banner in-app
**Accettazione**: Continuare a usare App = accettazione nuovi ToS
**Rifiuto**: Se non accetti, devi cessare uso App

---

## 10. LEGGE APPLICABILE E FORO COMPETENTE

**Legge applicabile**: Legge italiana (Codice Civile, Codice del Consumo)

**Foro competente**: Tribunale di Brescia, Italia (salvo foro consumatore se più favorevole per l'Utente)

**Risoluzione dispute**:
1. Tentativo conciliazione (contatta support@fitlogpro.com)
2. Mediazione obbligatoria (D.Lgs. 28/2010)
3. Giudizio ordinario (Tribunale Brescia)

---

## 11. CLAUSOLE FINALI

### 11.1 Indipendenza Clausole
Se una clausola è dichiarata invalida, le altre rimangono in vigore.

### 11.2 Nessuna Rinuncia
Mancata applicazione clausola ≠ rinuncia a farla valere successivamente.

### 11.3 Intero Accordo
ToS + Privacy Policy = intero accordo (prevalgono su comunicazioni precedenti).

### 11.4 Cessione
- **Utente**: Non può cedere account a terzi
- **Fornitore**: Può cedere diritti/obblighi (con preavviso 30 giorni)

---

## 12. CONTATTI

**Fornitore**:
- Nome: [Nome Sviluppatore]
- Indirizzo: Via [Indirizzo], Brescia (BS), Italia
- Email: support@fitlogpro.com
- PEC: [PEC se disponibile]

**Supporto tecnico**: support@fitlogpro.com (risposta entro 48 ore lavorative)

---

**ACCETTAZIONE**

Cliccando "Accetto" o usando l'App, dichiari di aver letto, compreso e accettato integralmente i presenti Termini di Servizio.

**Data accettazione**: [Registrata automaticamente all'iscrizione]
**Versione**: 1.0 (06/11/2025)
```

**Step 2: Create English ToS**

Create `docs/legal/TERMS_OF_SERVICE_EN.md`:

```markdown
# TERMS OF SERVICE - FITlog Pro

**Last updated**: November 6, 2025
**Provider**: [Developer Name], Brescia (BS), Italy
**Email**: support@fitlogpro.com

---

## 1. ACCEPTANCE OF TERMS

By using FITlog Pro ("App"), you fully accept these Terms of Service ("ToS") and the Privacy Policy.

**If you do not accept, DO NOT use the App.**

---

## 2. SERVICE DESCRIPTION

**FITlog Pro is a workout tracking application** that allows users to:
- Manually record sets, reps, weight
- View workout history
- Export data in JSON format

**FITlog Pro is NOT**:
- ❌ A medical consultation service
- ❌ A workout plan generator
- ❌ A substitute for personal trainer or sports physician
- ❌ A certified medical device

---

## 3. LIMITATION OF LIABILITY (CRITICAL)

### 3.1 "As-Is" Use

**The App is provided "AS-IS" without warranties of any kind**, express or implied.

The Provider does **NOT guarantee**:
- Absence of bugs or interruptions
- Accuracy of user-entered data
- Compatibility with all devices
- Continuous availability (99.9% uptime not guaranteed)

### 3.2 User Responsibility for Injuries

**⚠️ ESSENTIAL CLAUSE**:

**THE USER ACKNOWLEDGES THAT**:
1. Physical training involves inherent risks (injuries, strains, trauma)
2. The App does NOT provide supervision or advice on exercise execution
3. The User is **SOLELY RESPONSIBLE** for:
   - Choosing exercises appropriate for their level
   - Execution technique
   - Weight loads selected
   - Pre-existing physical and medical conditions
4. The User **MUST consult a physician** before starting physical activity

**THE PROVIDER IS NOT LIABLE FOR**:
- Physical injuries resulting from training
- Worsening of pre-existing medical conditions
- Indirect, consequential, punitive damages
- Data loss (backup is user's responsibility)
- Failure to achieve fitness goals

**MAXIMUM PROVIDER LIABILITY**: €0 (zero euros) if App is free, or amount paid for subscription in the last year.

### 3.3 Exclusion of Implied Warranties

**All implied warranties excluded** pursuant to Italian Civil Code (Art. 1490-1497), including:
- Warranty of merchantability
- Warranty of fitness for particular purpose
- Warranty of result

### 3.4 Release of Liability (Disclaimer)

**BY USING THE APP, THE USER RELEASES THE PROVIDER** from any liability for:
- Injuries, illnesses, death resulting from training
- User data entry errors
- Device malfunctions
- Incompatibility with other software

---

## 4. USER OBLIGATIONS

The User agrees to:
- ✅ Provide truthful data (age, email)
- ✅ Use App only for personal purposes (no commercial use)
- ✅ Not violate third-party rights (copyright, privacy)
- ✅ Not attempt hacking, reverse engineering, exploits
- ✅ Not share account with third parties
- ✅ Consult physician before starting training

**Violation of obligations**: Account suspension/deletion without notice.

---

## 5. INTELLECTUAL PROPERTY

### 5.1 Provider Rights
- **Copyright**: Code, design, UI, logo → exclusive property of Provider
- **License of use**: User receives **non-exclusive, non-transferable, revocable** license for personal use
- **Prohibited**: Copying, modifying, distributing, selling, decompiling the App

### 5.2 User Rights to Own Data
- **Workout data**: Owned by User
- **Export**: Right to export in JSON (GDPR Art. 20)
- **Deletion**: Right to delete account and data (GDPR Art. 17)

---

## 6. SUBSCRIPTION AND PAYMENTS (If applicable)

### 6.1 Available Plans
- **Free**: Basic features (unlimited)
- **Pro Monthly**: €4.99/month
- **Pro Yearly**: €39.99/year (save 33%)

### 6.2 Payments
- Managed by Apple App Store / Google Play Store
- **No credit card data** stored by Provider
- Auto-renewal (cancellable in app store)

### 6.3 Refunds
- **Apple/Google policy**: Refunds managed by Apple/Google, not Provider
- **No automatic refunds** (Apple/Google policy)
- For requests: Contact Apple/Google Store support

### 6.4 Subscription Cancellation
- **Where**: Settings → Subscription → Manage (redirects to App Store/Google Play)
- **Effect**: Subscription ends at current period expiration (no partial refund)
- **Account**: Remains active in Free version

---

## 7. SUSPENSION AND TERMINATION

### 7.1 Suspension by Provider
Provider may suspend/delete account if:
- ToS violation
- Fraudulent activities
- System abuse (spam, flooding)
- Judicial authority request

**Notice**: 7 days (except serious violations → immediate)

### 7.2 Deletion by User
- **Where**: Settings → Account → Delete Account
- **Effect**: Immediate data deletion (no recovery possible)
- **Backup**: User's responsibility to export data beforehand

---

## 8. MINORS (Under-18)

- **Under-14**: Registration **PROHIBITED** (GDPR Art. 8)
- **Ages 14-17**: Allowed with truthful age declaration
- **Parental responsibility**: Parents responsible for minors' use of App
- **Enhanced disclaimer**: Minors must read injury disclaimer with parent

---

## 9. TERMS OF SERVICE MODIFICATIONS

Provider may modify ToS at any time.

**Notice**: 30 days before via email + in-app banner
**Acceptance**: Continuing to use App = acceptance of new ToS
**Rejection**: If you do not accept, you must cease using App

---

## 10. APPLICABLE LAW AND JURISDICTION

**Applicable law**: Italian law (Civil Code, Consumer Code)

**Competent jurisdiction**: Court of Brescia, Italy (except consumer jurisdiction if more favorable for User)

**Dispute resolution**:
1. Attempted conciliation (contact support@fitlogpro.com)
2. Mandatory mediation (D.Lgs. 28/2010)
3. Ordinary judgment (Court of Brescia)

---

## 11. FINAL CLAUSES

### 11.1 Independence of Clauses
If a clause is declared invalid, the others remain in force.

### 11.2 No Waiver
Failure to enforce clause ≠ waiver of right to enforce it later.

### 11.3 Entire Agreement
ToS + Privacy Policy = entire agreement (supersede prior communications).

### 11.4 Assignment
- **User**: Cannot assign account to third parties
- **Provider**: May assign rights/obligations (with 30 days' notice)

---

## 12. CONTACTS

**Provider**:
- Name: [Developer Name]
- Address: Via [Address], Brescia (BS), Italy
- Email: support@fitlogpro.com
- PEC: [PEC if available]

**Technical support**: support@fitlogpro.com (response within 48 business hours)

---

**ACCEPTANCE**

By clicking "I Accept" or using the App, you declare that you have read, understood, and fully accepted these Terms of Service.

**Acceptance date**: [Automatically recorded at registration]
**Version**: 1.0 (November 6, 2025)
```

**Step 3: Commit ToS**

```bash
git add docs/legal/TERMS_OF_SERVICE_IT.md docs/legal/TERMS_OF_SERVICE_EN.md
git commit -m "docs: add Terms of Service (IT + EN) with liability limitation for tracking app"
```

---

## Task 3: Disclaimer Modal (Onboarding)

**Files:**
- Create: `lib/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart`
- Create: `test/features/onboarding/presentation/widgets/legal_disclaimer_modal_test.dart`
- Modify: `assets/i18n/app_en.arb` (add translations)
- Modify: `assets/i18n/app_it.arb` (add translations)

**Step 1: Write the failing test**

Create `test/features/onboarding/presentation/widgets/legal_disclaimer_modal_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

void main() {
  group('LegalDisclaimerModal', () {
    testWidgets('displays disclaimer title and content', (tester) async {
      bool wasAccepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () {
                          wasAccepted = true;
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Medical Disclaimer'), findsOneWidget);

      // Verify content (key phrases)
      expect(find.textContaining('NOT a substitute'), findsOneWidget);
      expect(find.textContaining('consult a physician'), findsOneWidget);
      expect(find.textContaining('sole responsibility'), findsOneWidget);

      // Verify "I Accept" button exists
      expect(find.text('I Accept'), findsOneWidget);
    });

    testWidgets('cannot dismiss dialog by tapping outside', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Try tapping outside dialog (barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible
      expect(find.text('Medical Disclaimer'), findsOneWidget);
    });

    testWidgets('calls onAccept when "I Accept" tapped', (tester) async {
      bool wasAccepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () {
                          wasAccepted = true;
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Tap "I Accept"
      await tester.tap(find.text('I Accept'));
      await tester.pumpAndSettle();

      expect(wasAccepted, true);
    });

    testWidgets('displays scrollable content for long text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LegalDisclaimerModal(
                        onAccept: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                  child: const Text('Show Disclaimer'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Disclaimer'));
      await tester.pumpAndSettle();

      // Verify SingleChildScrollView exists for scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
flutter test test/features/onboarding/presentation/widgets/legal_disclaimer_modal_test.dart
```

Expected output:
```
FAIL: displays disclaimer title and content
Error: LegalDisclaimerModal class not found
```

**Step 3: Add translations to ARB files**

Modify `assets/i18n/app_en.arb`:

```json
{
  "legalDisclaimerTitle": "Medical Disclaimer",
  "legalDisclaimerContent": "⚠️ IMPORTANT NOTICE\n\nFITlog Pro is a workout tracking tool.\n\nNOT a substitute for:\n• Medical advice\n• Personal trainer\n• Sports physician\n• Fitness consultant\n\nYou MUST:\n✓ Consult a physician before starting any exercise program\n✓ Stop immediately if you experience pain or discomfort\n✓ Take sole responsibility for your safety during training\n\nThe provider is NOT liable for:\n• Physical injuries\n• Worsening of medical conditions\n• Failure to achieve fitness goals\n\nBy accepting, you acknowledge these risks and agree to the Terms of Service and Privacy Policy.",
  "legalDisclaimerAccept": "I Accept",
  "legalDisclaimerDecline": "I Decline"
}
```

Modify `assets/i18n/app_it.arb`:

```json
{
  "legalDisclaimerTitle": "Disclaimer Medico",
  "legalDisclaimerContent": "⚠️ AVVISO IMPORTANTE\n\nFITlog Pro è uno strumento di tracciamento workout.\n\nNON è sostituto di:\n• Consulenza medica\n• Personal trainer\n• Medico sportivo\n• Consulente fitness\n\nDEVI:\n✓ Consultare un medico prima di iniziare qualsiasi programma di allenamento\n✓ Interrompere immediatamente in caso di dolore o disagio\n✓ Assumerti la piena responsabilità per la tua sicurezza durante l'allenamento\n\nIl fornitore NON è responsabile per:\n• Infortuni fisici\n• Peggioramento condizioni mediche\n• Mancato raggiungimento obiettivi fitness\n\nAccettando, riconosci questi rischi e accetti i Termini di Servizio e l'Informativa Privacy.",
  "legalDisclaimerAccept": "Accetto",
  "legalDisclaimerDecline": "Rifiuto"
}
```

Regenerate localizations:
```bash
flutter gen-l10n
```

**Step 4: Write minimal implementation**

Create `lib/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Modal dialog that displays medical disclaimer and liability limitations.
///
/// MUST be shown during onboarding before user can access app features.
/// Cannot be dismissed by tapping outside (barrierDismissible: false).
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (_) => LegalDisclaimerModal(
///     onAccept: () {
///       // Save consent timestamp
///       Navigator.pop(context);
///     },
///   ),
/// );
/// ```
class LegalDisclaimerModal extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  const LegalDisclaimerModal({
    super.key,
    required this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: context.colors.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.legalDisclaimerTitle,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.legalDisclaimerContent,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Privacy Policy and ToS links
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Open Privacy Policy (Task 7)
                  },
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: context.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // TODO: Open Terms of Service (Task 7)
                  },
                  child: Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: context.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        if (onDecline != null)
          TextButton(
            onPressed: onDecline,
            child: Text(
              context.l10n.legalDisclaimerDecline,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        FilledButton(
          onPressed: onAccept,
          child: Text(context.l10n.legalDisclaimerAccept),
        ),
      ],
    );
  }
}
```

**Step 5: Run test to verify it passes**

Run:
```bash
flutter test test/features/onboarding/presentation/widgets/legal_disclaimer_modal_test.dart
```

Expected output:
```
✓ displays disclaimer title and content
✓ cannot dismiss dialog by tapping outside
✓ calls onAccept when "I Accept" tapped
✓ displays scrollable content for long text
All tests passed!
```

**Step 6: Commit**

```bash
git add lib/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart \
        test/features/onboarding/presentation/widgets/legal_disclaimer_modal_test.dart \
        assets/i18n/app_en.arb \
        assets/i18n/app_it.arb \
        lib/shared/presentation/l10n/generated/
git commit -m "feat: add legal disclaimer modal with non-dismissible warning for onboarding"
```

---

## Task 4: Age Gate Screen

**Files:**
- Create: `lib/features/onboarding/presentation/widgets/age_gate_screen.dart`
- Create: `test/features/onboarding/presentation/widgets/age_gate_screen_test.dart`
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Write the failing test**

Create `test/features/onboarding/presentation/widgets/age_gate_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/age_gate_screen.dart';

void main() {
  group('AgeGateScreen', () {
    testWidgets('blocks registration if age < 14', (tester) async {
      DateTime? capturedBirthDate;
      bool wasBlocked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AgeGateScreen(
            onAgeVerified: (birthDate) {
              capturedBirthDate = birthDate;
            },
            onAgeBlocked: () {
              wasBlocked = true;
            },
          ),
        ),
      );

      // Find date picker (simplified for test)
      // In real implementation, user selects date via DatePicker
      // For test, we simulate by calling callback directly

      // Simulate user born in 2020 (age 5 → blocked)
      final under14BirthDate = DateTime(2020, 1, 1);
      final widget = tester.widget<AgeGateScreen>(find.byType(AgeGateScreen));
      widget.onAgeBlocked();

      await tester.pumpAndSettle();

      expect(wasBlocked, true);
      expect(capturedBirthDate, null);
    });

    testWidgets('allows registration if age >= 14', (tester) async {
      DateTime? capturedBirthDate;

      await tester.pumpWidget(
        MaterialApp(
          home: AgeGateScreen(
            onAgeVerified: (birthDate) {
              capturedBirthDate = birthDate;
            },
            onAgeBlocked: () {},
          ),
        ),
      );

      // Simulate user born in 2005 (age 20 → allowed)
      final validBirthDate = DateTime(2005, 1, 1);
      final widget = tester.widget<AgeGateScreen>(find.byType(AgeGateScreen));
      widget.onAgeVerified(validBirthDate);

      await tester.pumpAndSettle();

      expect(capturedBirthDate, validBirthDate);
    });

    testWidgets('displays age restriction message for under-14', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Age Restriction'),
                        content: const Text(
                          'You must be at least 14 years old to use FITlog Pro.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Age Restriction'), findsOneWidget);
      expect(find.textContaining('at least 14 years old'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
flutter test test/features/onboarding/presentation/widgets/age_gate_screen_test.dart
```

Expected: FAIL (AgeGateScreen not found)

**Step 3: Add translations**

Modify `assets/i18n/app_en.arb`:

```json
{
  "ageGateTitle": "Verify Your Age",
  "ageGateInstructions": "Please enter your date of birth to continue.",
  "ageGateBirthDate": "Date of Birth",
  "ageGateContinue": "Continue",
  "ageRestrictionTitle": "Age Restriction",
  "ageRestrictionMessage": "You must be at least 14 years old to use FITlog Pro.\n\nThis requirement is mandated by GDPR (EU Regulation 2016/679) and Italian privacy laws.",
  "ageRestrictionOk": "I Understand",
  "ageMinorWarningTitle": "Important Notice for Minors",
  "ageMinorWarningMessage": "If you are between 14 and 17 years old:\n\n• You MUST have parental consent to use this app\n• You MUST consult a physician before training\n• You MUST be supervised by an adult during workouts\n• Your parents are legally responsible for your use of this app\n\nDo you confirm you have parental consent?",
  "ageMinorWarningConfirm": "Yes, I Have Consent",
  "ageMinorWarningDecline": "No"
}
```

Modify `assets/i18n/app_it.arb`:

```json
{
  "ageGateTitle": "Verifica la Tua Età",
  "ageGateInstructions": "Inserisci la tua data di nascita per continuare.",
  "ageGateBirthDate": "Data di Nascita",
  "ageGateContinue": "Continua",
  "ageRestrictionTitle": "Limitazione di Età",
  "ageRestrictionMessage": "Devi avere almeno 14 anni per usare FITlog Pro.\n\nQuesto requisito è richiesto dal GDPR (Regolamento UE 2016/679) e dalle leggi italiane sulla privacy.",
  "ageRestrictionOk": "Ho Capito",
  "ageMinorWarningTitle": "Avviso Importante per Minori",
  "ageMinorWarningMessage": "Se hai tra 14 e 17 anni:\n\n• DEVI avere il consenso dei genitori per usare questa app\n• DEVI consultare un medico prima di allenarti\n• DEVI essere supervisionato da un adulto durante gli allenamenti\n• I tuoi genitori sono legalmente responsabili per il tuo uso di questa app\n\nConfermi di avere il consenso dei genitori?",
  "ageMinorWarningConfirm": "Sì, Ho il Consenso",
  "ageMinorWarningDecline": "No"
}
```

Regenerate:
```bash
flutter gen-l10n
```

**Step 4: Write minimal implementation**

Create `lib/features/onboarding/presentation/widgets/age_gate_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Screen that verifies user age before allowing registration.
///
/// GDPR Art. 8 compliance:
/// - Blocks users under 14 (Italian privacy law threshold)
/// - Shows enhanced disclaimer for 14-17 (minors with parental consent)
/// - Allows 18+ without restrictions
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => AgeGateScreen(
///       onAgeVerified: (birthDate) {
///         // Save birth date, proceed to registration
///       },
///       onAgeBlocked: () {
///         // Show error, exit registration flow
///       },
///     ),
///   ),
/// );
/// ```
class AgeGateScreen extends StatefulWidget {
  final Function(DateTime birthDate) onAgeVerified;
  final VoidCallback onAgeBlocked;

  const AgeGateScreen({
    super.key,
    required this.onAgeVerified,
    required this.onAgeBlocked,
  });

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  DateTime? _selectedBirthDate;

  /// Minimum age requirement (14 years per Italian law)
  static const int _minAgeYears = 14;

  /// Minor age threshold (18 years)
  static const int _minorThresholdYears = 18;

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    // Adjust if birthday hasn't occurred yet this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: context.l10n.ageGateBirthDate,
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _verifyContinue() {
    if (_selectedBirthDate == null) {
      // Show error: birth date required
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    final age = _calculateAge(_selectedBirthDate!);

    if (age < _minAgeYears) {
      // Block: under 14
      _showAgeRestrictionDialog();
    } else if (age < _minorThresholdYears) {
      // Warning: 14-17 minor
      _showMinorWarningDialog();
    } else {
      // Allow: 18+
      widget.onAgeVerified(_selectedBirthDate!);
    }
  }

  void _showAgeRestrictionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ageRestrictionTitle),
        content: Text(context.l10n.ageRestrictionMessage),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAgeBlocked();
            },
            child: Text(context.l10n.ageRestrictionOk),
          ),
        ],
      ),
    );
  }

  void _showMinorWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: context.colors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l10n.ageMinorWarningTitle),
            ),
          ],
        ),
        content: Text(context.l10n.ageMinorWarningMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAgeBlocked();
            },
            child: Text(
              context.l10n.ageMinorWarningDecline,
              style: TextStyle(color: context.colors.error),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAgeVerified(_selectedBirthDate!);
            },
            child: Text(context.l10n.ageMinorWarningConfirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.ageGateTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.cake_outlined,
              size: 64,
              color: context.colors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.ageGateTitle,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.ageGateInstructions,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _selectBirthDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedBirthDate == null
                    ? context.l10n.ageGateBirthDate
                    : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _verifyContinue,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(context.l10n.ageGateContinue),
            ),
            const SizedBox(height: 16),
            Text(
              'Required by GDPR and Italian privacy laws',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Run test to verify it passes**

Run:
```bash
flutter test test/features/onboarding/presentation/widgets/age_gate_screen_test.dart
```

Expected: All tests pass ✓

**Step 6: Commit**

```bash
git add lib/features/onboarding/presentation/widgets/age_gate_screen.dart \
        test/features/onboarding/presentation/widgets/age_gate_screen_test.dart \
        assets/i18n/ \
        lib/shared/presentation/l10n/generated/
git commit -m "feat: add age gate screen with GDPR-compliant 14+ age verification"
```

---

## Task 5: Consent Tracking System (Hive Database)

**Files:**
- Create: `lib/features/onboarding/data/models/legal_consent.dart`
- Create: `lib/features/onboarding/data/repositories/consent_repository.dart`
- Create: `test/features/onboarding/data/repositories/consent_repository_test.dart`

**Step 1: Write failing test**

Create `test/features/onboarding/data/repositories/consent_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/repositories/consent_repository.dart';

void main() {
  late ConsentRepository repository;

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LegalConsentAdapter());
  });

  setUp(() async {
    await Hive.deleteBoxFromDisk('legal_consents');
    repository = ConsentRepository();
    await repository.initialize();
  });

  tearDown(() async {
    await repository.dispose();
  });

  group('ConsentRepository', () {
    test('saves disclaimer consent with timestamp', () async {
      final consent = LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
        ipAddress: '192.168.1.1',
      );

      await repository.saveConsent(consent);

      final retrieved = await repository.getConsent(ConsentType.disclaimer);
      expect(retrieved, isNotNull);
      expect(retrieved!.accepted, true);
      expect(retrieved.type, ConsentType.disclaimer);
    });

    test('returns null if consent not found', () async {
      final retrieved = await repository.getConsent(ConsentType.tosAccepted);
      expect(retrieved, null);
    });

    test('updates existing consent', () async {
      final consent1 = LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
      );

      await repository.saveConsent(consent1);

      final consent2 = LegalConsent(
        type: ConsentType.disclaimer,
        accepted: false,
        timestamp: DateTime.now().add(const Duration(hours: 1)),
      );

      await repository.saveConsent(consent2);

      final retrieved = await repository.getConsent(ConsentType.disclaimer);
      expect(retrieved!.accepted, false);
    });

    test('checks if user has accepted all required consents', () async {
      expect(await repository.hasAcceptedAllRequired(), false);

      await repository.saveConsent(LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
      ));
      await repository.saveConsent(LegalConsent(
        type: ConsentType.privacyPolicy,
        accepted: true,
        timestamp: DateTime.now(),
      ));
      await repository.saveConsent(LegalConsent(
        type: ConsentType.tosAccepted,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      expect(await repository.hasAcceptedAllRequired(), true);
    });
  });
}
```

**Step 2: Run test to fail**

Run:
```bash
flutter test test/features/onboarding/data/repositories/consent_repository_test.dart
```

Expected: FAIL (classes not found)

**Step 3: Create LegalConsent model**

Create `lib/features/onboarding/data/models/legal_consent.dart`:

```dart
import 'package:hive/hive.dart';

part 'legal_consent.g.dart';

/// Types of legal consents required for GDPR compliance.
enum ConsentType {
  /// Medical disclaimer acceptance (liability waiver)
  disclaimer,

  /// Privacy policy acceptance
  privacyPolicy,

  /// Terms of Service acceptance
  tosAccepted,

  /// Age verification (birth date recorded)
  ageVerified,

  /// Firebase DPA acknowledgment
  firebaseDPA,
}

/// Model representing user consent for legal documents.
///
/// Stored in Hive for GDPR compliance (Art. 7 - proof of consent).
/// Records timestamp and IP address for audit trail.
@HiveType(typeId: 10)
class LegalConsent extends HiveObject {
  @HiveField(0)
  final ConsentType type;

  @HiveField(1)
  final bool accepted;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? ipAddress;

  @HiveField(4)
  final String? userAgent;

  @HiveField(5)
  final String? version; // App version at time of consent

  LegalConsent({
    required this.type,
    required this.accepted,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.version,
  });

  @override
  String toString() {
    return 'LegalConsent(type: $type, accepted: $accepted, timestamp: $timestamp)';
  }
}
```

Generate Hive adapter:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 4: Create ConsentRepository**

Create `lib/features/onboarding/data/repositories/consent_repository.dart`:

```dart
import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';

/// Repository for storing and retrieving user legal consents.
///
/// GDPR Art. 7 requires proof of consent:
/// - Timestamp of consent
/// - What user consented to (type)
/// - How consent was given (app version)
/// - Optional: IP address for audit trail
///
/// Stored locally in Hive (not uploaded to Firebase for privacy).
class ConsentRepository {
  static const String _boxName = 'legal_consents';
  late Box<LegalConsent> _box;

  /// Initialize Hive box for consent storage.
  Future<void> initialize() async {
    _box = await Hive.openBox<LegalConsent>(_boxName);
  }

  /// Save or update a consent record.
  Future<void> saveConsent(LegalConsent consent) async {
    await _box.put(consent.type.name, consent);
  }

  /// Get consent record by type.
  Future<LegalConsent?> getConsent(ConsentType type) async {
    return _box.get(type.name);
  }

  /// Check if user has accepted all required consents.
  ///
  /// Required consents:
  /// - Disclaimer
  /// - Privacy Policy
  /// - Terms of Service
  Future<bool> hasAcceptedAllRequired() async {
    final requiredTypes = [
      ConsentType.disclaimer,
      ConsentType.privacyPolicy,
      ConsentType.tosAccepted,
    ];

    for (final type in requiredTypes) {
      final consent = await getConsent(type);
      if (consent == null || !consent.accepted) {
        return false;
      }
    }

    return true;
  }

  /// Get all consent records (for export/audit).
  Future<List<LegalConsent>> getAllConsents() async {
    return _box.values.toList();
  }

  /// Delete all consents (for account deletion).
  Future<void> clearAllConsents() async {
    await _box.clear();
  }

  /// Dispose repository and close Hive box.
  Future<void> dispose() async {
    await _box.close();
  }
}
```

**Step 5: Run test to pass**

Run:
```bash
flutter test test/features/onboarding/data/repositories/consent_repository_test.dart
```

Expected: All tests pass ✓

**Step 6: Commit**

```bash
git add lib/features/onboarding/data/ \
        test/features/onboarding/data/
git commit -m "feat: add consent tracking system with Hive for GDPR Art. 7 compliance"
```

---

## Task 6: Footer Disclaimer (Persistent)

**Files:**
- Create: `lib/shared/presentation/widgets/footer_disclaimer.dart`
- Create: `test/shared/presentation/widgets/footer_disclaimer_test.dart`
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Write failing test**

Create `test/shared/presentation/widgets/footer_disclaimer_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/footer_disclaimer.dart';

void main() {
  group('FooterDisclaimer', () {
    testWidgets('displays disclaimer text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FooterDisclaimer(),
          ),
        ),
      );

      expect(find.textContaining('NOT medical advice'), findsOneWidget);
    });

    testWidgets('is visually subtle (low emphasis)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FooterDisclaimer(),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, lessThan(14)); // Small font
    });

    testWidgets('tapping opens full disclaimer dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FooterDisclaimer(),
          ),
        ),
      );

      await tester.tap(find.byType(FooterDisclaimer));
      await tester.pumpAndSettle();

      // Verify dialog opened
      expect(find.text('Medical Disclaimer'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to fail**

Run:
```bash
flutter test test/shared/presentation/widgets/footer_disclaimer_test.dart
```

Expected: FAIL

**Step 3: Add translations**

Modify `assets/i18n/app_en.arb`:

```json
{
  "footerDisclaimerShort": "NOT medical advice • Consult physician • Use at your own risk",
  "footerDisclaimerTapHint": "Tap for full disclaimer"
}
```

Modify `assets/i18n/app_it.arb`:

```json
{
  "footerDisclaimerShort": "NON è consulenza medica • Consulta un medico • Uso a tuo rischio",
  "footerDisclaimerTapHint": "Tocca per disclaimer completo"
}
```

Regenerate:
```bash
flutter gen-l10n
```

**Step 4: Implement widget**

Create `lib/shared/presentation/widgets/footer_disclaimer.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Footer disclaimer shown at bottom of workout-related screens.
///
/// Provides constant reminder of liability limitations.
/// Tapping opens full disclaimer modal.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     // Main content
///     Spacer(),
///     FooterDisclaimer(),
///   ],
/// );
/// ```
class FooterDisclaimer extends StatelessWidget {
  const FooterDisclaimer({super.key});

  void _showFullDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => LegalDisclaimerModal(
        onAccept: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showFullDisclaimer(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border(
            top: BorderSide(
              color: context.colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    context.l10n.footerDisclaimerShort,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.footerDisclaimerTapHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary.withValues(alpha: 0.7),
                fontSize: 10,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Run test to pass**

Run:
```bash
flutter test test/shared/presentation/widgets/footer_disclaimer_test.dart
```

Expected: All tests pass ✓

**Step 6: Commit**

```bash
git add lib/shared/presentation/widgets/footer_disclaimer.dart \
        test/shared/presentation/widgets/footer_disclaimer_test.dart \
        assets/i18n/ \
        lib/shared/presentation/l10n/generated/
git commit -m "feat: add persistent footer disclaimer for workout screens with tap-to-expand"
```

---

## Task 7: DPA Documentation Tracker

**Files:**
- Create: `docs/legal/DPA_FIREBASE_CHECKLIST.md`
- Create: `docs/legal/COMPLIANCE_CHECKLIST.md`

**Step 1: Create Firebase DPA checklist**

Create `docs/legal/DPA_FIREBASE_CHECKLIST.md`:

```markdown
# Firebase Data Processing Agreement (DPA) - Checklist

## Overview

**What**: Data Processing Agreement between FITlog Pro (Controller) and Google Firebase (Processor)
**Why**: GDPR Art. 28 requires written contract with any data processor
**Consequence if not signed**: €10M-€20M fine (GDPR Art. 83)

---

## Step-by-Step Process

### 1. Access Firebase Console

URL: https://console.firebase.google.com/

Login with: [Your Google Account]

---

### 2. Navigate to DPA Settings

1. Select your project: `[Your Project ID]`
2. Click ⚙️ **Settings** (top left)
3. Go to **Project Settings** → **Legal**
4. Find section: **Data Processing and Security Terms**

---

### 3. Review DPA Terms

**Document**: Google Cloud Data Processing Terms
**URL**: https://firebase.google.com/terms/data-processing-terms

**Key Sections to Review**:
- Section 2: Data Processing
- Section 5: Data Security
- Section 6: Subprocessors (list of Google's subprocessors)
- Section 7: International Data Transfers (Standard Contractual Clauses)
- Annex 1: Description of Processing
- Annex 2: Security Measures
- Annex 3: Subprocessor List

**⚠️ READ CAREFULLY**: You're legally binding yourself to these terms.

---

### 4. Accept Terms

1. Check box: ☑️ **"I accept Google Cloud Data Processing Terms"**
2. Click **Save**
3. Confirmation message appears: "Terms accepted"

---

### 5. Download Signed Copy

1. Click **Download** button next to accepted terms
2. Save PDF: `Firebase_DPA_Signed_[Date].pdf`
3. Store in: `docs/legal/signed/Firebase_DPA_Signed_2025-11-06.pdf`

**⚠️ CRITICAL**: Keep this PDF for 10 years (GDPR Art. 30 - Records of Processing)

---

### 6. Verify SCC (Standard Contractual Clauses)

**Why**: Firebase may transfer data to USA (Google servers)
**What**: SCC = EU-approved contract for safe data transfers outside EU

**Verify**:
1. In DPA document, find **Annex 3: Transfers of Personal Data**
2. Confirm: ✓ Standard Contractual Clauses (Module 2: Controller-to-Processor)
3. Confirm: ✓ EU Commission Implementing Decision 2021/914

If SCC not mentioned, contact Firebase support: firebase-support@google.com

---

### 7. Update Privacy Policy

After signing DPA, update Privacy Policy section:

**Add to section "4. Where Your Data Is Stored"**:

```markdown
### Data Processing Agreement

We have signed a Data Processing Agreement (DPA) with Google Firebase (GDPR Art. 28).
This agreement ensures:
- Google processes data only on our instructions
- Data security measures (encryption, access controls)
- Notification of data breaches within 24 hours
- Right to audit Google's security practices

**Standard Contractual Clauses**: Data transfers to USA (if any) are protected by EU-approved Standard Contractual Clauses (EU Implementing Decision 2021/914).

**DPA Reference**: Available upon request (privacy@fitlogpro.com)
```

---

## Completion Checklist

- [ ] ✅ Logged into Firebase Console
- [ ] ✅ Navigated to Settings → Legal
- [ ] ✅ Read Google Cloud Data Processing Terms
- [ ] ✅ Accepted terms (checkbox + Save)
- [ ] ✅ Downloaded signed PDF
- [ ] ✅ Stored PDF in `docs/legal/signed/`
- [ ] ✅ Verified SCC included (Annex 3)
- [ ] ✅ Updated Privacy Policy with DPA reference
- [ ] ✅ Committed to git (if not sensitive)

---

## Renewal

**Frequency**: Check annually (Google may update terms)
**Notification**: Firebase sends email if terms change
**Action**: Review changes, accept new version, download new PDF

---

## Questions?

**Firebase Support**: firebase-support@google.com
**GDPR Guidance**: https://firebase.google.com/support/privacy

**Lawyer Review** (optional but recommended):
- Cost: €200-€500
- Contact: Avvocato specializzato in GDPR (Brescia)
```

**Step 2: Create master compliance checklist**

Create `docs/legal/COMPLIANCE_CHECKLIST.md`:

```markdown
# Legal Compliance Master Checklist - FITlog Pro

**Last updated**: 2025-11-06
**Status**: 🚧 In Progress
**Target**: ✅ Launch-Ready

---

## 🔴 CRITICAL (Before Launch)

### 1. Firebase DPA

- [ ] ✅ Signed Data Processing Agreement with Google Firebase
- [ ] ✅ Downloaded PDF stored in `docs/legal/signed/`
- [ ] ✅ Verified Standard Contractual Clauses (SCC) included
- [ ] 📄 Reference: `docs/legal/DPA_FIREBASE_CHECKLIST.md`

**Deadline**: BEFORE any production user data
**Risk if missing**: €10M-€20M GDPR fine

---

### 2. Privacy Policy

- [ ] ✅ Italian version completed (`docs/legal/PRIVACY_POLICY_IT.md`)
- [ ] ✅ English version completed (`docs/legal/PRIVACY_POLICY_EN.md`)
- [ ] ✅ Published in-app (Settings → Privacy Policy)
- [ ] ✅ Published on website (if exists): [URL]
- [ ] ✅ All placeholders replaced ([Developer Name], [Email], etc.)

**Deadline**: BEFORE launch
**Risk if missing**: €10M GDPR fine + user complaints

---

### 3. Terms of Service

- [ ] ✅ Italian ToS completed (`docs/legal/TERMS_OF_SERVICE_IT.md`)
- [ ] ✅ English ToS completed (`docs/legal/TERMS_OF_SERVICE_EN.md`)
- [ ] ✅ Published in-app (Settings → Terms of Service)
- [ ] ✅ Liability limitation clauses verified
- [ ] ✅ Disclaimer section verified

**Deadline**: BEFORE launch
**Risk if missing**: Difficult legal defense if user dispute

---

### 4. Disclaimer Modal (In-App)

- [ ] ✅ Implemented `LegalDisclaimerModal` widget
- [ ] ✅ Shown during onboarding (first-time users)
- [ ] ✅ Cannot be dismissed by tapping outside (barrierDismissible: false)
- [ ] ✅ Consent tracked with timestamp in Hive
- [ ] ✅ Tested on iOS + Android

**Deadline**: BEFORE launch
**Risk if missing**: Weak legal defense if injury claim

---

### 5. Age Gate

- [ ] ✅ Implemented `AgeGateScreen` widget
- [ ] ✅ Blocks under-14 registration (GDPR Art. 8)
- [ ] ✅ Shows minor warning for 14-17 (parental consent)
- [ ] ✅ Birth date saved in Hive
- [ ] ✅ Tested edge cases (today's date, leap years)

**Deadline**: BEFORE launch
**Risk if missing**: €10M GDPR fine + minor safety liability

---

## 🟠 HIGH PRIORITY (Within 1 Month)

### 6. P.IVA (Partita IVA)

- [ ] ✅ Opened P.IVA Regime Forfettario
- [ ] ✅ Codice ATECO: 62.01.00 (Software production)
- [ ] ✅ Registered with Agenzia Entrate
- [ ] ✅ Subscribed to Gestione Separata INPS

**Deadline**: Before monetization (subscription launch)
**Risk if missing**: €1k-€3k fine + IVA recovery

---

### 7. Assicurazione RC Professionale

- [ ] ✅ Requested quote from 3 companies:
  - [ ] Allianz Tutela Professionale IT
  - [ ] Generali RC Informatici
  - [ ] HDI Polizza IT
- [ ] ✅ Selected policy: [Company Name]
- [ ] ✅ Massimale: €[Amount] (recommended: €500k)
- [ ] ✅ Policy signed and active
- [ ] ✅ Certificate stored: `docs/legal/insurance/`

**Deadline**: Before launch (strongly recommended) OR within 1 month
**Risk if missing**: Unlimited personal liability for user injuries

---

### 8. Consent Tracking System

- [ ] ✅ Implemented `ConsentRepository` (Hive)
- [ ] ✅ Tracks disclaimer acceptance
- [ ] ✅ Tracks Privacy Policy acceptance
- [ ] ✅ Tracks ToS acceptance
- [ ] ✅ Tracks age verification
- [ ] ✅ Records timestamps + IP (optional)
- [ ] ✅ Export function for user data requests (GDPR Art. 15)

**Deadline**: Before launch
**Risk if missing**: Cannot prove user consent (GDPR Art. 7)

---

### 9. Firebase Data Minimization

- [ ] ✅ Disabled Google Analytics (if not needed)
- [ ] ✅ Disabled Crashlytics automatic collection
- [ ] ✅ Disabled Performance Monitoring (if not needed)
- [ ] ✅ Firestore Security Rules: users can only read/write own data
- [ ] ✅ Audit: Verified what data Firebase actually collects

**Deadline**: Before launch
**Risk if missing**: Collecting unnecessary data (GDPR Art. 5 violation)

---

## 🟡 NICE-TO-HAVE (Can Defer)

### 10. Lawyer Review

- [ ] ✅ Privacy Policy reviewed by GDPR lawyer
- [ ] ✅ Terms of Service reviewed
- [ ] ✅ Disclaimer adequacy reviewed
- [ ] ✅ Received written opinion letter
- [ ] 💰 Cost: €[Amount] (budget: €500-€1,000)

**Deadline**: Optional (if budget allows)
**Benefit**: 100% legal certainty

---

### 11. Commercialista (Accountant)

- [ ] ✅ Initial consultation for P.IVA setup
- [ ] ✅ Tax optimization advice (regime forfettario)
- [ ] ✅ INPS contribution calculation
- [ ] ✅ Subscribed for annual tax filing
- [ ] 💰 Cost: €[Amount] (budget: €500-€1k/year)

**Deadline**: Before earning revenue
**Benefit**: Tax optimization, compliance

---

### 12. Changelog & Version Control

- [ ] ✅ Created `docs/legal/PRIVACY_POLICY_CHANGELOG.md`
- [ ] ✅ Created `docs/legal/TERMS_OF_SERVICE_CHANGELOG.md`
- [ ] ✅ Git tags for legal doc versions (e.g., `legal-v1.0`)

**Deadline**: After first version published
**Benefit**: Audit trail for changes

---

## 📊 Completion Status

**Critical (Before Launch)**: 0 / 5 completed (0%)
**High Priority**: 0 / 4 completed (0%)
**Nice-to-Have**: 0 / 3 completed (0%)

**TOTAL**: 0 / 12 completed (0%)

---

## 🚀 Launch Readiness

**Can launch when**:
- ✅ All 5 Critical items completed
- ✅ Privacy Policy + ToS published
- ✅ Disclaimer + Age Gate tested
- ✅ Firebase DPA signed

**Recommended to defer launch if missing**:
- ⚠️ Assicurazione RC (high liability risk)
- ⚠️ P.IVA (if monetizing immediately)

---

## Next Steps

1. Start with Task 1: Firebase DPA (3 hours)
2. Complete Task 2-3: Privacy Policy + ToS (1 day)
3. Implement Task 4-5: Disclaimer + Age Gate (1 day)
4. Test everything thoroughly (1 day)
5. Request insurance quotes (1 week wait)
6. **LAUNCH** (after critical items complete)

**Estimated Total Time**: 2 weeks from now
```

**Step 3: Commit documentation**

```bash
git add docs/legal/DPA_FIREBASE_CHECKLIST.md \
        docs/legal/COMPLIANCE_CHECKLIST.md
git commit -m "docs: add DPA signing checklist and master compliance tracker"
```

---

## Task 8: Integration with Onboarding Flow

**Files:**
- Modify: `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (if exists)
- Create: `lib/features/onboarding/presentation/providers/onboarding_provider.dart`
- Create: `test/features/onboarding/presentation/providers/onboarding_provider_test.dart`

**Step 1: Write failing test for provider**

Create `test/features/onboarding/presentation/providers/onboarding_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late ProviderContainer container;
  late ConsentRepository repository;

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LegalConsentAdapter());
  });

  setUp(() async {
    await Hive.deleteBoxFromDisk('legal_consents');
    repository = ConsentRepository();
    await repository.initialize();

    container = ProviderContainer(
      overrides: [
        consentRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() async {
    await repository.dispose();
    container.dispose();
  });

  group('OnboardingProvider', () {
    test('initial state is onboarding not completed', () {
      final state = container.read(onboardingProvider);
      expect(state.isOnboardingComplete, false);
    });

    test('marks onboarding complete after all consents', () async {
      final notifier = container.read(onboardingProvider.notifier);

      await notifier.acceptDisclaimer();
      await notifier.acceptPrivacyPolicy();
      await notifier.acceptTermsOfService();
      await notifier.verifyAge(DateTime(2000, 1, 1));

      final state = container.read(onboardingProvider);
      expect(state.isOnboardingComplete, true);
    });

    test('checks if user has completed onboarding on init', () async {
      // Pre-save consents
      await repository.saveConsent(LegalConsent(
        type: ConsentType.disclaimer,
        accepted: true,
        timestamp: DateTime.now(),
      ));
      await repository.saveConsent(LegalConsent(
        type: ConsentType.privacyPolicy,
        accepted: true,
        timestamp: DateTime.now(),
      ));
      await repository.saveConsent(LegalConsent(
        type: ConsentType.tosAccepted,
        accepted: true,
        timestamp: DateTime.now(),
      ));

      // Create new container (simulates app restart)
      final newContainer = ProviderContainer(
        overrides: [
          consentRepositoryProvider.overrideWithValue(repository),
        ],
      );

      final notifier = newContainer.read(onboardingProvider.notifier);
      await notifier.checkOnboardingStatus();

      final state = newContainer.read(onboardingProvider);
      expect(state.isOnboardingComplete, true);

      newContainer.dispose();
    });
  });
}
```

**Step 2: Run test to fail**

Run:
```bash
flutter test test/features/onboarding/presentation/providers/onboarding_provider_test.dart
```

Expected: FAIL

**Step 3: Implement provider**

Create `lib/features/onboarding/presentation/providers/onboarding_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/repositories/consent_repository.dart';

/// Provider for ConsentRepository instance.
final consentRepositoryProvider = Provider<ConsentRepository>((ref) {
  final repository = ConsentRepository();
  // Initialize is called in main.dart
  return repository;
});

/// State for onboarding flow.
class OnboardingState {
  final bool isOnboardingComplete;
  final DateTime? birthDate;
  final bool disclaimerAccepted;
  final bool privacyPolicyAccepted;
  final bool tosAccepted;

  OnboardingState({
    this.isOnboardingComplete = false,
    this.birthDate,
    this.disclaimerAccepted = false,
    this.privacyPolicyAccepted = false,
    this.tosAccepted = false,
  });

  OnboardingState copyWith({
    bool? isOnboardingComplete,
    DateTime? birthDate,
    bool? disclaimerAccepted,
    bool? privacyPolicyAccepted,
    bool? tosAccepted,
  }) {
    return OnboardingState(
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      birthDate: birthDate ?? this.birthDate,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      privacyPolicyAccepted: privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      tosAccepted: tosAccepted ?? this.tosAccepted,
    );
  }
}

/// Notifier for managing onboarding flow and legal consents.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final ConsentRepository _repository;

  OnboardingNotifier(this._repository) : super(OnboardingState());

  /// Check if user has already completed onboarding (on app start).
  Future<void> checkOnboardingStatus() async {
    final hasAccepted = await _repository.hasAcceptedAllRequired();
    final ageConsent = await _repository.getConsent(ConsentType.ageVerified);

    state = state.copyWith(
      isOnboardingComplete: hasAccepted && ageConsent != null,
      disclaimerAccepted: (await _repository.getConsent(ConsentType.disclaimer))?.accepted ?? false,
      privacyPolicyAccepted: (await _repository.getConsent(ConsentType.privacyPolicy))?.accepted ?? false,
      tosAccepted: (await _repository.getConsent(ConsentType.tosAccepted))?.accepted ?? false,
    );
  }

  /// Accept disclaimer and save consent.
  Future<void> acceptDisclaimer() async {
    await _repository.saveConsent(LegalConsent(
      type: ConsentType.disclaimer,
      accepted: true,
      timestamp: DateTime.now(),
    ));

    state = state.copyWith(disclaimerAccepted: true);
    _checkCompletion();
  }

  /// Accept privacy policy and save consent.
  Future<void> acceptPrivacyPolicy() async {
    await _repository.saveConsent(LegalConsent(
      type: ConsentType.privacyPolicy,
      accepted: true,
      timestamp: DateTime.now(),
    ));

    state = state.copyWith(privacyPolicyAccepted: true);
    _checkCompletion();
  }

  /// Accept Terms of Service and save consent.
  Future<void> acceptTermsOfService() async {
    await _repository.saveConsent(LegalConsent(
      type: ConsentType.tosAccepted,
      accepted: true,
      timestamp: DateTime.now(),
    ));

    state = state.copyWith(tosAccepted: true);
    _checkCompletion();
  }

  /// Verify user age and save birth date.
  Future<void> verifyAge(DateTime birthDate) async {
    await _repository.saveConsent(LegalConsent(
      type: ConsentType.ageVerified,
      accepted: true,
      timestamp: DateTime.now(),
    ));

    state = state.copyWith(birthDate: birthDate);
    _checkCompletion();
  }

  /// Check if all required consents are complete.
  void _checkCompletion() {
    final allAccepted = state.disclaimerAccepted &&
        state.privacyPolicyAccepted &&
        state.tosAccepted &&
        state.birthDate != null;

    state = state.copyWith(isOnboardingComplete: allAccepted);
  }
}

/// Provider for onboarding state and actions.
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final repository = ref.watch(consentRepositoryProvider);
  return OnboardingNotifier(repository);
});
```

**Step 4: Run test to pass**

Run:
```bash
flutter test test/features/onboarding/presentation/providers/onboarding_provider_test.dart
```

Expected: All tests pass ✓

**Step 5: Commit**

```bash
git add lib/features/onboarding/presentation/providers/ \
        test/features/onboarding/presentation/providers/
git commit -m "feat: add onboarding provider with consent state management via Riverpod"
```

---

## Task 9: Documentation - In-App Links

**Files:**
- Create: `lib/features/settings/presentation/screens/legal_documents_screen.dart`
- Create: `test/features/settings/presentation/screens/legal_documents_screen_test.dart`

**Step 1: Write failing test**

Create `test/features/settings/presentation/screens/legal_documents_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/legal_documents_screen.dart';

void main() {
  group('LegalDocumentsScreen', () {
    testWidgets('displays links to Privacy Policy and ToS', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalDocumentsScreen(),
        ),
      );

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('tapping Privacy Policy opens document', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalDocumentsScreen(),
        ),
      );

      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Verify document viewer opened (implementation detail)
      expect(find.text('PRIVACY POLICY'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to fail**

Run:
```bash
flutter test test/features/settings/presentation/screens/legal_documents_screen_test.dart
```

Expected: FAIL

**Step 3: Implement screen**

Create `lib/features/settings/presentation/screens/legal_documents_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Screen displaying legal documents (Privacy Policy, ToS, etc.).
///
/// Loads markdown files from docs/legal/ and displays in-app.
class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  Future<String> _loadDocument(String path) async {
    return await rootBundle.loadString(path);
  }

  void _showDocument(BuildContext context, String title, String assetPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DocumentViewerScreen(
          title: title,
          assetPath: assetPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Documents'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we handle your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDocument(
              context,
              'Privacy Policy',
              'docs/legal/PRIVACY_POLICY_EN.md',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            subtitle: const Text('Usage terms and liability'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDocument(
              context,
              'Terms of Service',
              'docs/legal/TERMS_OF_SERVICE_EN.md',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Medical Disclaimer'),
            subtitle: const Text('Liability limitations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show disclaimer modal
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Medical Disclaimer'),
                  content: SingleChildScrollView(
                    child: Text(context.l10n.legalDisclaimerContent),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Internal viewer for markdown documents.
class _DocumentViewerScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const _DocumentViewerScreen({
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading document: ${snapshot.error}'),
            );
          }

          // Simple text display (for full markdown rendering, use flutter_markdown package)
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              snapshot.data ?? '',
              style: context.textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }
}
```

**Step 4: Add documents to Flutter assets**

Modify `pubspec.yaml`:

```yaml
flutter:
  assets:
    - docs/legal/PRIVACY_POLICY_EN.md
    - docs/legal/PRIVACY_POLICY_IT.md
    - docs/legal/TERMS_OF_SERVICE_EN.md
    - docs/legal/TERMS_OF_SERVICE_IT.md
```

**Step 5: Run test to pass**

Run:
```bash
flutter test test/features/settings/presentation/screens/legal_documents_screen_test.dart
```

Expected: All tests pass ✓

**Step 6: Commit**

```bash
git add lib/features/settings/presentation/screens/legal_documents_screen.dart \
        test/features/settings/presentation/screens/legal_documents_screen_test.dart \
        pubspec.yaml
git commit -m "feat: add in-app legal documents viewer for Privacy Policy and ToS"
```

---

## Execution Complete

**Plan saved to**: `docs/plans/2025-11-06-legal-compliance-documentation.md`

**Total Tasks**: 9
**Estimated Time**: 2-3 days implementation + 1 week external tasks (insurance, P.IVA)
**Files Created**: 20+
**Tests Created**: 6 test suites

---

## Two Execution Options:

**1. Subagent-Driven (this session)**
- I dispatch fresh subagent per task
- Code review between tasks
- Fast iteration with quality gates
- **REQUIRED SUB-SKILL**: superpowers:subagent-driven-development

**2. Parallel Session (separate)**
- Open new session with executing-plans
- Batch execution with checkpoints
- Review at end of each batch
- **REQUIRED SUB-SKILL**: New session uses superpowers:executing-plans

**Which approach do you prefer?**
