# 🚀 TestFlight Deployment Guide

## Quick Deploy

Per deployare GymBro TrackLog su TestFlight tramite terminale:

```bash
./scripts/deploy_testflight.sh your@email.com xxxx-xxxx-xxxx-xxxx ABCD123456
```

## Preparazione Credenziali

### 1. Apple ID
- Il tuo email sviluppatore Apple

### 2. App-Specific Password
1. Vai su [appleid.apple.com](https://appleid.apple.com)
2. Accedi con il tuo Apple ID
3. Vai in **Sign-In and Security** > **App-Specific Passwords**
4. Clicca **Generate Password...**
5. Inserisci nome: "GymBro TestFlight"
6. Copia la password generata (formato: xxxx-xxxx-xxxx-xxxx)

### 3. Team ID
1. Vai su [App Store Connect](https://appstoreconnect.apple.com)
2. Clicca **Membership** nel menu laterale
3. Copia il **Team ID** (es: ABCD123456)

## Processo Completo

Lo script automaticamente:

1. 🧹 **Pulizia**: `flutter clean` + `flutter pub get`
2. 📱 **Build**: `flutter build ios --release --no-codesign`
3. 📦 **Archive**: Crea archive con build number automatico
4. 🚀 **Export**: Esporta per App Store
5. ⬆️ **Upload**: Carica su TestFlight (notarytool o altool)
6. 🧹 **Cleanup**: Rimuove file temporanei

## Dopo il Deploy

- ⏰ **Processing**: 10-60 minuti per elaborazione Apple
- 📧 **Email**: Riceverai notifica di completamento
- 🔗 **Gestione**: [App Store Connect](https://appstoreconnect.apple.com)

## Troubleshooting

### Errore "Team ID not found"
Verifica il Team ID in App Store Connect > Membership

### Errore "Invalid credentials"
Rigenera l'App-Specific Password

### Errore di provisioning profile
Lo script usa automatic signing, verifica in Xcode che sia configurato

### Build fallisce
Esegui `flutter doctor` per verificare setup Flutter/iOS

## File Configurazione

- `ios/exportOptions.plist`: Configurazione export App Store
- `scripts/deploy_testflight.sh`: Script deployment completo