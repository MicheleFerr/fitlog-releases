# 🔐 Firebase App Check - Setup Guide

**Status**: ✅ CODE IMPLEMENTED - ⚠️ FIREBASE CONSOLE SETUP REQUIRED

Firebase App Check è ora implementato nel codice, ma richiede configurazione nella Firebase Console per funzionare.

---

## 📋 Checklist Implementazione

### ✅ Codice (Completato)

- [x] Aggiunto `firebase_app_check: ^0.3.1+3` a `pubspec.yaml`
- [x] Creato `lib/core/security/app_check_config.dart`
- [x] Integrato in `lib/main.dart` (chiamato prima di Firestore)
- [x] Configurato per iOS (Device Check) e Android (Play Integrity)

### ⚠️ Firebase Console (DA COMPLETARE)

- [ ] **Step 1**: Abilitare App Check in Firebase Console
- [ ] **Step 2**: Registrare app iOS con Device Check
- [ ] **Step 3**: Registrare app Android con Play Integrity API
- [ ] **Step 4**: (Opzionale) Configurare reCAPTCHA v3 per web
- [ ] **Step 5**: Aggiornare Firestore rules (già fatto ✅)
- [ ] **Step 6**: Testare in debug mode
- [ ] **Step 7**: Deploy in production

---

## 🚀 Step-by-Step Setup

### Step 1: Abilitare App Check nella Firebase Console

1. Vai su **Firebase Console** → Il tuo progetto (`gymprogressapp-184bc`)
2. Nel menu laterale, clicca su **"App Check"**
3. Se vedi un banner **"Get started"**, clicca su **"Get started"**
4. Leggi la panoramica e clicca su **"Continue"**

### Step 2: Configurare iOS App (Device Check)

1. In **App Check**, trova la tua app iOS (`com.michele.gymbro.flutter`)
2. Clicca su **"Register"** accanto a **"Device Check"**
3. Firebase registrerà automaticamente la tua app con Apple Device Check
4. Attendi la conferma: **"✅ Device Check is enabled for this app"**

**Nota**: Device Check richiede:
- App installata su dispositivo fisico (non simulatore)
- iOS 11.0+ (già soddisfatto)
- Apple Developer account (già hai)

### Step 3: Configurare Android App (Play Integrity API)

1. In **App Check**, trova la tua app Android
2. Clicca su **"Register"** accanto a **"Play Integrity"**
3. Firebase configurerà automaticamente Play Integrity API
4. Attendi la conferma: **"✅ Play Integrity is enabled for this app"**

**Nota**: Play Integrity richiede:
- Google Play Services installato sul dispositivo
- App distribuita tramite Google Play Console (anche internal testing)
- App firmata con lo stesso certificato registrato in Firebase

### Step 4: (Opzionale) Configurare Web App (reCAPTCHA v3)

**Solo se hai una versione web dell'app:**

1. In **App Check**, trova la tua app web
2. Clicca su **"Register"** accanto a **"reCAPTCHA v3"**
3. Copia la **"reCAPTCHA site key"** fornita
4. Aggiorna `lib/core/security/app_check_config.dart`:

```dart
webProvider: ReCaptchaV3Provider(
  'YOUR-RECAPTCHA-SITE-KEY-HERE',  // ← Sostituisci questo
),
```

### Step 5: Verificare Firestore Rules (✅ Già Fatto)

Le Firestore rules sono già configurate per supportare App Check.

**Verifica** in `firestore.rules`:

```javascript
// ✅ GIÀ PRESENTE (linea 862-871)
function isDocumentSizeValid() {
  return request.resource.size() < 500000;
}

function isQueryLimitValid() {
  return !request.query.limit.exists() || request.query.limit <= 100;
}
```

**App Check enforcement** (opzionale - NON ancora abilitato):

Per forzare App Check su tutte le richieste (SOLO dopo testing completo):

```javascript
// ⚠️ NON ABILITARE FINCHÉ NON HAI TESTATO
// Aggiungi questa funzione in firestore.rules:
function isAppCheckVerified() {
  return request.auth.token.firebase.sign_in_provider == 'custom'
    || request.time < timestamp.value(1735689600000); // Jan 1, 2025 - grace period
}

// Poi aggiungi a TUTTE le regole:
allow read: if request.auth != null && isAppCheckVerified();
allow write: if request.auth != null && isAppCheckVerified();
```

### Step 6: Testare in Debug Mode

#### A. Ottenere Debug Token

1. Esegui l'app in debug mode su dispositivo fisico (iOS/Android):

```bash
flutter run --debug
```

2. Cerca nei log il debug token:

```
🔐 [App Check] Firebase App Check debug token: XXXXX-XXXXX-XXXXX-XXXXX
```

3. Copia il token (sarà simile a: `3F2504E0-4F89-11D3-9A0C-0305E82C3301`)

#### B. Registrare Debug Token in Firebase

1. Vai su **Firebase Console** → **App Check** → **Debug tokens**
2. Clicca **"Add debug token"**
3. Incolla il token copiato
4. Aggiungi una descrizione (es: "Michele's iPhone 14 Pro")
5. Clicca **"Save"**

Ora l'app in debug mode può passare la verifica App Check.

#### C. Verificare Funzionamento

Esegui questo test nel tuo codice:

```dart
// Aggiungi temporaneamente in main.dart dopo AppCheckConfig.initialize():
if (kDebugMode) {
  final token = await AppCheckConfig.getToken();
  if (token != null) {
    debugPrint('✅ App Check is working! Token: ${token.substring(0, 20)}...');
  } else {
    debugPrint('❌ App Check failed to get token');
  }
}
```

### Step 7: Deploy in Production

#### Pre-Production Checklist:

- [ ] App Check testato in debug mode (iOS + Android)
- [ ] Debug tokens rimossi dal codice
- [ ] reCAPTCHA site key aggiornata (se web)
- [ ] App firmata con certificato di produzione
- [ ] Google Play Console: app caricata (anche internal testing)

#### Production Deployment:

1. **iOS**: Nessuna configurazione aggiuntiva - Device Check funziona automaticamente
2. **Android**:
   - Carica l'APK/AAB su Google Play Console
   - Assicurati che sia firmato con lo stesso certificato registrato in Firebase
   - Play Integrity verificherà automaticamente

#### Monitoring:

Dopo il deployment, monitora in **Firebase Console** → **App Check** → **Metrics**:

- ✅ Richieste verificate (buono)
- ⚠️ Richieste non verificate (investigare)
- ❌ Richieste bloccate (normale se enforcement è attivo)

---

## 🔍 Troubleshooting

### Problema: "App Check token is missing"

**Causa**: App Check non inizializzato o configurazione mancante

**Soluzione**:
1. Verifica che `AppCheckConfig.initialize()` sia chiamato in `main.dart`
2. Controlla Firebase Console → App Check → app registrata
3. Per Android: verifica che Play Integrity sia abilitato
4. Per iOS: verifica che Device Check sia abilitato

### Problema: "Invalid debug token"

**Causa**: Token debug scaduto o non registrato

**Soluzione**:
1. Rigenera il token: cancella app data, reinstalla, ottieni nuovo token
2. Registra il nuovo token in Firebase Console
3. Attendi 5-10 minuti per la propagazione

### Problema: "Play Integrity check failed" (Android)

**Causa**: App non distribuita via Google Play o certificato errato

**Soluzione**:
1. Carica l'app su Google Play Console (anche internal testing)
2. Verifica che il certificato SHA-1/SHA-256 sia registrato in Firebase
3. Usa una build firmata (non debug)

### Problema: "Device Check unavailable" (iOS)

**Causa**: Simulatore o iOS < 11.0

**Soluzione**:
1. Testa SOLO su dispositivi fisici
2. Verifica iOS version >= 11.0
3. In debug, usa debug token come fallback

---

## 📊 Metriche di Successo

Dopo l'implementazione, dovresti vedere in **Firebase Console** → **App Check** → **Metrics**:

- **Verification Rate**: >= 95% (ideale: 98%+)
- **Failed Verifications**: < 5% (investigare se > 10%)
- **Debug Token Usage**: 0% in production (solo development)

---

## 🔐 Security Best Practices

### ✅ DO:
- ✅ Inizializza App Check PRIMA di qualsiasi chiamata Firebase
- ✅ Registra debug tokens SOLO per dispositivi di sviluppo
- ✅ Rimuovi debug tokens prima del production deployment
- ✅ Monitora metrics regolarmente per anomalie
- ✅ Usa enforcement (blocco richieste) SOLO dopo testing completo

### ❌ DON'T:
- ❌ NON committare debug tokens nel codice
- ❌ NON abilitare enforcement senza testare prima
- ❌ NON usare debug tokens in production builds
- ❌ NON ignorare "verification failed" warnings
- ❌ NON distribuire app senza App Check in production

---

## 📚 Risorse Aggiuntive

- [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)
- [Device Check (iOS)](https://developer.apple.com/documentation/devicecheck)
- [Play Integrity API (Android)](https://developer.android.com/google/play/integrity)
- [reCAPTCHA v3 (Web)](https://developers.google.com/recaptcha/docs/v3)

---

## ✅ Next Steps

1. **Immediate (Oggi)**:
   - [ ] Abilita App Check in Firebase Console
   - [ ] Registra app iOS con Device Check
   - [ ] Registra app Android con Play Integrity

2. **Testing (Questa settimana)**:
   - [ ] Testa su dispositivo fisico iOS
   - [ ] Testa su dispositivo fisico Android
   - [ ] Verifica metrics in Firebase Console

3. **Production (Prima del deployment)**:
   - [ ] Rimuovi debug code
   - [ ] Verifica certificati di produzione
   - [ ] (Opzionale) Abilita enforcement in Firestore rules

---

**🎯 Obiettivo**: App Check completamente funzionante in production entro **7 giorni**

**Priorità**: 🔥 **CRITICAL** - Protegge da API abuse e costi inaspettati Firebase
