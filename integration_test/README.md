# 📱 Integration Test per Timer GymBro

## 🎯 Test Implementati

### 1. **Timer 60s con Lockscreen** ⏱️🔒
- Avvia timer 60 secondi
- Simula lockscreen dopo 10s
- Verifica che il timer continui in background
- Verifica audio al completamento
- Verifica Live Activity su iOS

### 2. **Timer 120s con Musica** 🎵⏱️
- Simula musica in background (Spotify/Apple Music)
- Avvia timer 120 secondi
- Verifica che la musica non si abbassi
- Verifica audio timer sopra la musica
- Test AVAudioSession su iOS

### 3. **Transizione App→Lockscreen→App** 🔄
- Avvia timer 90 secondi
- Lockscreen dopo 30s
- Riapri app dopo 60s
- Verifica sincronizzazione (±0.5s tolleranza)

### 4. **Live Activity iOS** 🍎
- Test specifico per iOS 16.1+
- Verifica attivazione Live Activity
- Verifica aggiornamenti in tempo reale
- Verifica presenza in Dynamic Island

### 5. **Audio Completion in Background** 🔊
- Timer breve (10s)
- App in background dopo 3s
- Verifica audio suona anche in background
- Test background capabilities

## 🚀 Come Eseguire i Test

### Prerequisiti
```bash
# Aggiungi dipendenza in pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### Su Simulatore iOS
```bash
# Avvia simulatore
open -a Simulator

# Esegui test
flutter test integration_test/timer_lockscreen_test.dart
```

### Su Device Fisico iOS
```bash
# Collega iPhone via USB
# Trust del computer su iPhone

# Esegui test
flutter test integration_test/timer_lockscreen_test.dart
```

### Su Emulatore Android
```bash
# Avvia emulatore
emulator -avd Pixel_6_Pro

# Esegui test
flutter test integration_test/timer_lockscreen_test.dart
```

### Esegui Tutti i Test
```bash
flutter test integration_test/
```

## ⚠️ Limitazioni

### Test Automatici NON possono:
1. **Realmente bloccare lo schermo** - Solo simulato
2. **Verificare audio reale** - Solo verificare che il metodo sia chiamato
3. **Interagire con app esterne** (Spotify, Apple Music)
4. **Testare Dynamic Island** su device non supportati

### Test Manuali Necessari per:
1. **Audio reale** in lockscreen
2. **Interazione con musica** di sistema
3. **Live Activity** visualizzazione reale
4. **Battery optimization** Android
5. **Background execution** limiti iOS/Android

## 📊 Risultati Attesi

### ✅ Pass Criteria:
- Timer mantiene stato in background
- Sincronizzazione < 0.5s dopo resume
- Audio suona al completamento
- Live Activity aggiorna ogni secondo (iOS)
- Nessun crash in transizioni

### ❌ Fail Criteria:
- Timer si resetta dopo lockscreen
- Desync > 1 secondo
- Audio non suona
- Live Activity non si aggiorna
- App crash in background

## 🧪 Test Manuali Consigliati

### Test 1: Timer Reale con Lockscreen
1. Avvia timer 60s nell'app
2. Premi tasto power per lockscreen dopo 10s
3. Attendi 50s con schermo spento
4. **Verifica**: Audio suona con schermo spento
5. Sblocca telefono
6. **Verifica**: Timer mostra 0:00

### Test 2: Timer con Spotify
1. Avvia Spotify e riproduci musica
2. Apri GymBro e avvia timer 120s
3. Blocca schermo
4. **Verifica**: Musica continua normale volume
5. Al completamento timer
6. **Verifica**: Audio timer suona sopra musica

### Test 3: Live Activity iOS
1. iPhone con iOS 16.1+
2. Avvia timer nell'app
3. Vai in home screen
4. **Verifica**: Live Activity in Dynamic Island
5. Blocca schermo
6. **Verifica**: Timer visibile in lockscreen
7. **Verifica**: Aggiornamenti ogni secondo

## 🔧 Debug

### Logs iOS
```bash
# Console logs
xcrun simctl spawn booted log stream --level debug | grep GymBro
```

### Logs Android
```bash
# Logcat
adb logcat | grep GymBro
```

### Check Background Capabilities

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
    <string>processing</string>
</array>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## 📝 Note Importanti

1. **iOS Simulator** non supporta alcune features:
   - Dynamic Island (solo iPhone 14 Pro+)
   - Background audio reale
   - Live Activities complete

2. **Android Emulator** limitazioni:
   - Battery optimization non realistico
   - Background execution più permissivo

3. **Test su Device Fisico** sempre consigliato per:
   - Performance reale
   - Battery usage
   - Background limits reali
   - Audio/musica interazione

## 🎯 Checklist Pre-Release

- [ ] Test passano su iOS Simulator
- [ ] Test passano su Android Emulator
- [ ] Test manuali su iPhone fisico
- [ ] Test manuali su Android fisico
- [ ] Audio funziona in lockscreen
- [ ] Live Activity funziona (iOS)
- [ ] Nessun battery drain eccessivo
- [ ] Sync corretta dopo background