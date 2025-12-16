# 🛡️ Firebase App Check - Guida Setup

Firebase App Check protegge le tue API backend (Firestore, Firebase Auth, ecc.) da abusi, impedendo richieste da app non autorizzate.

## 📋 Prerequisiti

- Firebase project configurato
- App iOS e Android registrate in Firebase Console
- Accesso Firebase Console con permessi admin

---

## 🚀 Setup Rapido (3 Step)

### Step 1: Aggiungi Dipendenza

Aggiungi a `pubspec.yaml`:

```yaml
dependencies:
  firebase_app_check: ^0.2.1+10  # Versione latest
```

```bash
flutter pub get
```

### Step 2: Inizializza in `main.dart`

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ AGGIUNGI QUESTO - Inizializza App Check
  await FirebaseAppCheck.instance.activate(
    // iOS: DeviceCheck (produzione) / Debug (sviluppo)
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.deviceCheck,

    // Android: Play Integrity (produzione) / Debug (sviluppo)
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,

    // Web (opzionale)
    webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'),
  );

  runApp(const MyApp());
}
```

### Step 3: Configura Firebase Console

#### Per iOS:

1. Apri [Firebase Console](https://console.firebase.google.com/)
2. Vai su **Build** → **App Check**
3. Clicca su **Register** per l'app iOS
4. Seleziona **DeviceCheck** come provider
5. Salva

#### Per Android:

1. Vai su **Build** → **App Check**
2. Clicca su **Register** per l'app Android
3. Seleziona **Play Integrity** come provider
4. Salva

---

## 🔧 Configurazione Avanzata

### Debug Token (per sviluppo locale)

Durante lo sviluppo, devi whitelistare il tuo dispositivo:

1. **Ottieni il debug token**:
   ```dart
   // Stampa il debug token nel primo avvio
   FirebaseAppCheck.instance.getToken().then((token) {
     if (kDebugMode) {
       debugPrint('App Check Debug Token: ${token?.token}');
     }
   });
   ```

2. **Registra il token in Firebase Console**:
   - Vai su **App Check** → **Apps** → tua app
   - Clicca su **Manage debug tokens**
   - Aggiungi il token stampato nel log
   - Salva

3. **Valido per 7 giorni**, poi devi rinnovarlo

### Enforcement (Attivazione protezione)

⚠️ **IMPORTANTE**: Non attivare subito l'enforcement! Prima testa.

1. **Fase 1 - Monitoring** (primi 2-3 giorni):
   - Lascia enforcement **DISABILITATO**
   - Monitora i log per verificare che App Check funzioni
   - Firebase Console → App Check → Metrics

2. **Fase 2 - Attivazione Graduale**:
   - Abilita enforcement per **Firestore** (il più importante)
   - Attendi 24 ore, monitora errori
   - Se tutto OK, abilita per **Firebase Auth**
   - Attendi 24 ore
   - Abilita per altri servizi (Storage, Functions, ecc.)

3. **Come attivare**:
   - Firebase Console → App Check
   - Per ogni servizio (Firestore, Auth, ecc.):
     - Clicca su **Enforce**
     - Conferma

---

## 🔍 Testing

### Test Manuale

```dart
// Verifica che App Check sia attivo
void testAppCheck() async {
  try {
    final token = await FirebaseAppCheck.instance.getToken();
    if (token != null) {
      if (kDebugMode) {
        debugPrint('✅ App Check token obtained successfully');
      }
    } else {
      if (kDebugMode) {
        debugPrint('❌ App Check token is null');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ App Check error: $e');
    }
  }
}
```

### Test Automatico

```bash
# Testa su device reale (non emulator)
flutter run --release
```

---

## 📊 Monitoraggio

### Metriche Firebase Console

1. Vai su **Firebase Console** → **App Check**
2. Sezione **Metrics**:
   - **Valid requests**: Richieste con token valido ✅
   - **Invalid requests**: Richieste bloccate ❌
   - **Missing requests**: Richieste senza token ⚠️

### Log Errori

Se vedi errori `PERMISSION_DENIED` dopo aver attivato enforcement:

```
FirebaseError: [code=permission-denied]:
Missing or insufficient permissions
```

**Possibili cause**:
1. App Check non inizializzato correttamente
2. Debug token non registrato (in sviluppo)
3. Device/app non autorizzato
4. Token scaduto

---

## 🛠️ Troubleshooting

### Errore: "App Check token is null"

**Soluzione**:
- Verifica che App Check sia registrato in Firebase Console
- Per iOS: verifica che DeviceCheck sia abilitato nelle capabilities
- Per Android: verifica che Play Integrity API sia abilitata

### Errore: "PERMISSION_DENIED" in sviluppo

**Soluzione**:
- Registra il debug token in Firebase Console
- Verifica che `AppleProvider.debug` / `AndroidProvider.debug` siano usati in debug mode

### App funziona in debug ma non in release

**Soluzione**:
- Assicurati di usare `deviceCheck` / `playIntegrity` in release
- Verifica che l'app sia firmata correttamente
- Per iOS: verifica il provisioning profile

### Metriche mostrano "Missing requests"

**Soluzione**:
- Alcune richieste potrebbero venire da vecchie versioni dell'app
- Assicurati che tutti gli utenti abbiano aggiornato l'app
- Considera un periodo di transizione prima di attivare enforcement

---

## 📱 Platform-Specific

### iOS Specifico

**Capabilities richieste**:

Nessuna capability extra richiesta! DeviceCheck funziona out-of-the-box.

**Versioni supportate**:
- iOS 14.0+ per DeviceCheck
- iOS 16.0+ raccomandato

### Android Specifico

**Requisiti**:
- Play Integrity API (successore di SafetyNet)
- Google Play Services installato
- App distribuita via Google Play Store (per produzione)

**Nota**: In sviluppo, usa il debug provider.

---

## 🔒 Best Practices

1. **✅ Usa sempre debug provider in sviluppo**:
   ```dart
   appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck
   ```

2. **✅ Attiva enforcement gradualmente**:
   - Prima Firestore (dati critici)
   - Poi Auth (autenticazione)
   - Infine Storage/Functions

3. **✅ Monitora metriche per 48 ore** prima di attivare enforcement

4. **✅ Tieni debug tokens aggiornati** (scadono dopo 7 giorni)

5. **✅ Documenta i token** del team di sviluppo

6. **❌ Non attivare enforcement senza testing**

7. **❌ Non dimenticare di passare a production provider** in release

---

## 📚 Risorse

- [Firebase App Check Docs](https://firebase.google.com/docs/app-check)
- [Play Integrity API](https://developer.android.com/google/play/integrity)
- [DeviceCheck (Apple)](https://developer.apple.com/documentation/devicecheck)

---

## ✅ Checklist Finale

Prima di deployare in produzione:

- [ ] App Check inizializzato in `main.dart`
- [ ] Provider configurati (debug per dev, production per release)
- [ ] App registrate in Firebase Console (iOS + Android)
- [ ] Debug tokens registrati per team di sviluppo
- [ ] Testato in debug mode (con debug provider)
- [ ] Testato in release mode (con production provider)
- [ ] Monitoraggio attivo in Firebase Console
- [ ] Enforcement attivato per Firestore
- [ ] Enforcement attivato per Firebase Auth
- [ ] Documentato per il team

---

**🎉 Complimenti! La tua app è ora protetta contro abusi con Firebase App Check!**
