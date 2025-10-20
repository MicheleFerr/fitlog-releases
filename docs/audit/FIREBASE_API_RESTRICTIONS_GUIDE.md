# 🔥 Guida: Configurare Restrizioni API Firebase

**Problema**: Chiavi API Firebase committate nel repository senza restrizioni
**Severità**: ALTA
**Tempo Richiesto**: 15 minuti
**Priorità**: Sprint 1 (questa settimana)

---

## ⚠️ Perché è Importante

Le chiavi API Firebase nel repository (`lib/firebase_options.dart`) sono attualmente:
- ✅ Pubblicamente visibili su GitHub
- ❌ **NON hanno restrizioni** configurate
- ⚠️ Potrebbero essere usate per:
  - Esaurire quote Firebase (attacco DoS)
  - Abuso servizi Firebase (costi elevati)
  - Letture Firestore non autorizzate (limitate dalle security rules)

**Chiavi Esposte**:
- iOS: `AIzaSyBrjfQYljHU-Gi-QnmaYcfPqdzDlITWBCo`
- Android: `AIzaSyC3g8Wg7dWg5dWg5dWg5dWg5dWg5dWg5dW` (placeholder)
- Web: `AIzaSyC3g8Wg7dWg5dWg5dWg5dWg5dWg5dWg5dW` (placeholder)

---

## 📋 Passi per Configurare le Restrizioni

### 1. Accedi a Firebase Console

1. Vai a https://console.firebase.google.com/
2. Seleziona il progetto **gymprogressapp-184bc**
3. Clicca sull'icona **⚙️ Impostazioni progetto** (in alto a sinistra)

### 2. Naviga alle Restrizioni API

1. Nella pagina Impostazioni progetto
2. Scroll fino a **Le tue app**
3. Vedrai le app registrate:
   - iOS app (Bundle ID: `com.michele.gymbro.flutter`)
   - Android app (se presente)
   - Web app (se presente)

### 3. Restrizioni iOS (PRIORITÀ MASSIMA)

#### Passo 3.1: Vai a Google Cloud Console
1. Dalla Firebase Console, clicca **Google Cloud Console** (link in alto)
2. Nel menu laterale: **API e servizi** → **Credenziali**
3. Trova la chiave API iOS: `AIzaSyBrjfQYljHU-Gi-QnmaYcfPqdzDlITWBCo`

#### Passo 3.2: Configura Restrizioni iOS
1. Clicca sulla chiave API
2. Nella sezione **Restrizioni applicazione**:
   - Seleziona **App iOS**
   - Aggiungi **Bundle ID**: `com.michele.gymbro.flutter`

3. Nella sezione **Restrizioni API**:
   - Seleziona **Limita la chiave**
   - Abilita solo le API necessarie:
     - ✅ Firebase Authentication API
     - ✅ Cloud Firestore API
     - ✅ Firebase Cloud Messaging API
     - ✅ Firebase Analytics API
     - ✅ Firebase Performance Monitoring API
     - ✅ Google Sign-In
     - ❌ Disabilita tutto il resto

4. Clicca **Salva**

### 4. Restrizioni Android

#### Passo 4.1: Ottieni SHA-1 Fingerprint

**Ambiente Debug**:
```bash
cd android
./gradlew signingReport
```
Cerca la riga con `SHA1:` e copia il valore.

**Ambiente Release** (se hai keystore di produzione):
```bash
keytool -list -v -keystore /path/to/your/release.keystore
```

#### Passo 4.2: Aggiungi SHA-1 a Firebase
1. Firebase Console → Impostazioni progetto
2. Nella sezione Android app
3. Clicca **Aggiungi impronta digitale**
4. Incolla SHA-1 debug (e release se disponibile)
5. Salva

#### Passo 4.3: Configura Restrizioni Android API Key
1. Google Cloud Console → **API e servizi** → **Credenziali**
2. Trova chiave API Android
3. Restrizioni applicazione:
   - Seleziona **App Android**
   - Nome pacchetto: `com.micheleferrero93.GymProgressAppNew`
   - SHA-1: (quello ottenuto sopra)
4. Restrizioni API: (stesse di iOS)
5. Salva

### 5. Restrizioni Web (se usato)

1. Google Cloud Console → Credenziali → Chiave API Web
2. Restrizioni applicazione:
   - Seleziona **Referrer HTTP (siti web)**
   - Aggiungi domini autorizzati:
     - `https://gymbroapp.com/*` (se hai dominio)
     - `https://gymprogressapp-184bc.web.app/*` (Firebase Hosting)
     - `https://gymprogressapp-184bc.firebaseapp.com/*` (Firebase Hosting)
     - `http://localhost:*` (solo per sviluppo locale)
3. Restrizioni API: (stesse di iOS)
4. Salva

---

## ✅ Verifica che Funzioni

### Test iOS
```bash
# Build release
flutter build ios --release

# Verifica che l'app funzioni:
# - Login con Google/Apple
# - Lettura/scrittura Firestore
# - Analytics tracking
```

### Test Android
```bash
# Build release
flutter build apk --release

# Installa e testa funzionalità Firebase
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Verifica Restrizioni
1. Prova a usare la chiave API da:
   - Un'app diversa (dovrebbe fallire)
   - Un dominio non autorizzato (dovrebbe fallire)
   - Da Postman/curl (dovrebbe fallire)

---

## 🎯 Checklist Finale

- [ ] Restrizioni iOS configurate con Bundle ID
- [ ] API iOS limitate solo a Firebase services
- [ ] SHA-1 Android aggiunto a Firebase Console
- [ ] Restrizioni Android configurate
- [ ] Restrizioni Web configurate (se applicabile)
- [ ] Build release iOS testato
- [ ] Build release Android testato
- [ ] Login Google/Apple funziona
- [ ] Firestore read/write funziona
- [ ] Analytics funziona

---

## 🚨 Troubleshooting

### Errore "API key not valid"
**Causa**: Restrizioni troppo strette o Bundle ID/Package name errato.

**Soluzione**:
1. Verifica Bundle ID in `ios/Runner.xcodeproj/project.pbxproj`
2. Verifica Package name in `android/app/build.gradle.kts`
3. Assicurati di aver salvato le modifiche in Google Cloud Console
4. Attendi 5-10 minuti per propagazione (cache)

### Build funziona ma Firebase non si connette
**Causa**: SHA-1 non corretto o mancante.

**Soluzione**:
1. Ri-genera SHA-1 con `./gradlew signingReport`
2. Verifica che sia aggiunto in Firebase Console
3. Scarica nuovo `google-services.json`
4. Rimpiazza in `android/app/google-services.json`
5. Rebuild

### Analytics non traccia eventi
**Causa**: API Analytics non abilitata nelle restrizioni.

**Soluzione**:
1. Google Cloud Console → Credenziali
2. Apri chiave API
3. Restrizioni API → Aggiungi **Firebase Analytics API**
4. Salva e attendi propagazione

---

## 📊 Impatto Sicurezza

### Prima (Vulnerabile)
```
❌ Chiave API senza restrizioni
❌ Qualsiasi app può usare la chiave
❌ Quota abuse possibile
❌ Costi inattesi
```

### Dopo (Sicuro)
```
✅ Chiave API con restrizioni Bundle ID/Package name
✅ Solo app GymBro può usare le chiavi
✅ Solo API Firebase abilitate
✅ Protezione contro quota abuse
```

**Riduzione rischio**: ALTA → BASSA
**Tempo implementazione**: 15 minuti
**Beneficio**: Blocca 90% degli abuse potenziali

---

## 🔄 Prossimi Passi

Una volta completato:
1. ✅ Marcare questo task come **COMPLETATO** nel report audit
2. ⏭️ Passare a **Problema #2**: Audit logging debug sensibili
3. 📝 Aggiornare documentazione sicurezza in `CLAUDE.md`

---

**Ultima Modifica**: 20 Ottobre 2025
**Status**: In Attesa Configurazione Utente
**Riferimento Audit**: docs/audit/SECURITY_AUDIT_2025-10-20.md, Problema #1.2

