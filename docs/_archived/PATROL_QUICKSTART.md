# 🚀 Patrol Quick Start Guide

## Setup Iniziale (Solo la prima volta)

### 1. Aggiungi Patrol al PATH
```bash
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

### 2. Verifica installazione
```bash
make patrol-doctor
```

Dovresti vedere:
```
✅ Patrol CLI version: 3.10.0
✅ Flutter 3.x
✅ Android SDK found
✅ Xcode found
✅ ideviceinstaller found
```

## 🧪 Eseguire i Test

### Metodo 1: Usando Make (Consigliato)
```bash
# Tutti i test
make patrol-test

# Test specifici
make patrol-live     # Test Live Activity (iOS)
make patrol-bg       # Test Background Timer
make patrol-perm     # Test Permissions
make patrol-e2e      # Test E2E Workflow
```

### Metodo 2: Usando lo script
```bash
# Tutti i test
./scripts/run_patrol_tests.sh

# Test specifici
./scripts/run_patrol_tests.sh live
./scripts/run_patrol_tests.sh background
./scripts/run_patrol_tests.sh permissions
./scripts/run_patrol_tests.sh e2e
```

### Metodo 3: Comando diretto
```bash
# Assicurati che patrol sia nel PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Esegui test
patrol test --target integration_test/tests/live_activity_test.dart
```

## 📱 Test su Dispositivi Specifici

### iOS Simulator
```bash
# Lista simulatori disponibili
xcrun simctl list devices

# Test su iPhone specifico
make patrol-ios  # Default: iPhone 15 Pro
```

### Android Emulator
```bash
# Lista emulatori
adb devices

# Test su Android
make patrol-android  # Default: Pixel 7
```

### Device Fisico
1. Collega il device via USB
2. Abilita Developer Mode
3. Esegui:
```bash
patrol test --device "Nome del tuo device"
```

## 🔍 Troubleshooting

### Problema: "command not found: patrol"
```bash
# Reinstalla patrol
dart pub global activate patrol_cli

# Aggiungi al PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Problema: iOS Simulator non parte
```bash
# Avvia manualmente
open -a Simulator

# O crea nuovo simulator
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" iOS17.0
xcrun simctl boot "iPhone 15 Pro"
```

### Problema: Test fallisce su permission
```bash
# Reset simulator per pulire permissions
xcrun simctl erase all
```

## 🎯 Test Più Importanti

### 1. Live Activity (iOS Only)
**Cosa testa**: Timer visibile in lock screen e Dynamic Island
```bash
make patrol-live
```

### 2. Background Timer
**Cosa testa**: Timer continua quando app è in background
```bash
make patrol-bg
```

### 3. E2E Workflow
**Cosa testa**: Flusso completo workout dalla creazione al completamento
```bash
make patrol-e2e
```

## 📊 Interpretare i Risultati

### Output di Successo
```
✅ Test passed
Time: 45.2s
```

### Output di Fallimento
```
❌ Test failed
Expected: Timer should continue in background
Actual: Timer stopped after 5 seconds
```

### Screenshots/Video
I test salvano automaticamente screenshots in caso di failure:
```
screenshots/
├── test_name_failure.png
└── test_name_video.mp4
```

## 🔧 Sviluppo Test

### Debug Interattivo
```bash
# Sviluppa con Hot Restart
patrol develop --target integration_test/tests/workout_flow_e2e_test.dart
```

### Aggiungere Nuovo Test
1. Crea file in `integration_test/tests/`
2. Usa template:
```dart
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('My test', ($) async {
    // Test code
  });
}
```

## 📚 Documentazione Completa

Per maggiori dettagli vedi:
- `README_PATROL.md` - Guida completa
- `.github/workflows/patrol_tests.yml` - CI/CD setup
- `integration_test/` - Esempi di test

## 💡 Tips

1. **Test veloci**: Usa `make patrol-bg` per test rapido del timer
2. **Debug**: Aggiungi `--verbose` per più log
3. **CI/CD**: I test girano automaticamente su ogni PR
4. **Coverage**: ~16 test critici già implementati

## 🆘 Supporto

- [Patrol Docs](https://patrol.leancode.pl)
- [GitHub Issues](https://github.com/leancodepl/patrol/issues)
- Team: @michele