# 🧪 Patrol Testing Guide for GymBro

## Overview
Patrol è stato integrato in GymBro per testare le feature native critiche che non possono essere testate con i normali integration test Flutter:
- **Live Activities** (iOS)
- **Background Timer**
- **Permission Handling**
- **Notification System**

## 🚀 Quick Start

### Installazione
```bash
# Installa Patrol CLI globalmente
dart pub global activate patrol_cli

# Aggiungi al PATH (se necessario)
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Installa le dipendenze
flutter pub get
```

### Run Test Singolo
```bash
# Test Live Activity iOS
patrol test --target integration_test/tests/live_activity_test.dart

# Test Background Timer
patrol test --target integration_test/tests/background_timer_test.dart

# Test Permissions
patrol test --target integration_test/tests/permission_test.dart

# Test E2E Completo
patrol test --target integration_test/tests/workout_flow_e2e_test.dart
```

### Run Tutti i Test
```bash
# iOS
patrol test --device "iPhone 15 Pro"

# Android
patrol test --device "Pixel 7"
```

## 📂 Struttura Test

```
integration_test/
├── helpers/
│   └── test_base.dart          # Utilities e setup comuni
├── pages/
│   ├── workout_page.dart       # Page Object per workout screens
│   └── timer_page.dart         # Page Object per timer functionality
├── tests/
│   ├── live_activity_test.dart # Test Live Activities iOS
│   ├── background_timer_test.dart # Test timer in background
│   ├── permission_test.dart    # Test permission handling
│   └── workout_flow_e2e_test.dart # Test E2E completo
└── fixtures/                   # Test data (se necessario)
```

## 🎯 Test Critici per GymBro

### 1. Live Activity Test (iOS Only)
Verifica che:
- Live Activity appare quando il timer parte
- Timer continua ad aggiornarsi in background
- Dynamic Island mostra il timer (iPhone 14 Pro+)

### 2. Background Timer Test
Verifica che:
- Timer continua quando app va in background
- Audio suona al completamento anche in background
- Stato timer recuperato dopo app kill/restart
- Notifiche appaiono al completamento

### 3. Permission Test
Verifica che:
- Richiesta permessi notifiche
- Gestione permission denial
- Prompt per aprire Settings se permessi negati
- Health permission (iOS)
- Camera permission per form check

### 4. E2E Workout Flow
Test completo che verifica:
- Creazione workout
- Esecuzione con multiple serie
- Timer rest tra serie
- Interruzioni e recovery
- Completamento workout

## 🔧 Configurazione Avanzata

### Test su Device Specifico
```bash
# iOS Simulator specifico
patrol test --device "iPhone 15 Pro"

# Android Emulator specifico
patrol test --device "Pixel 7 API 33"

# Device fisico (deve essere connesso)
patrol test --device "Michele's iPhone"
```

### Test con Video Recording
```bash
patrol test --record-video
```

### Test con Verbose Logging
```bash
patrol test --verbose
```

## 🐛 Debugging

### Problemi Comuni

#### 1. "Device not found"
```bash
# Lista dispositivi disponibili
patrol devices
```

#### 2. iOS Simulator non parte
```bash
# Avvia manualmente
xcrun simctl boot "iPhone 15 Pro"
```

#### 3. Permission test fallisce
- Assicurati che il simulatore/emulatore sia resettato
- I permessi precedenti possono interferire

### Debug Interattivo
```bash
# Sviluppa test con Hot Restart
patrol develop --target integration_test/tests/workout_flow_e2e_test.dart
```

## 🔄 CI/CD Integration

I test Patrol sono configurati per girare automaticamente su:
- **Push** su main/develop
- **Pull Request** verso main/develop

Vedi `.github/workflows/patrol_tests.yml` per dettagli.

### GitHub Actions Status
- ✅ iOS Tests (iPhone 15 Pro simulator)
- ✅ Android Tests (API 30 & 33)
- ✅ Test report generation
- ✅ PR comment con risultati

## 📝 Writing New Tests

### Template Base
```dart
import 'package:patrol/patrol.dart';
import '../helpers/test_base.dart';

void main() {
  patrolTest(
    'My new test',
    nativeAutomation: true, // Necessario per native features
    ($) async {
      // Setup
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.MyApp());
      
      // Test logic
      await TestBase.loginTestUser($);
      
      // Native interactions
      await $.native.pressHome();
      await $.native.openApp();
      await $.native.grantPermissionWhenRequested(Permission.notification);
      
      // Cleanup
      await TestBase.cleanup();
    },
  );
}
```

### Best Practices
1. **Usa Page Objects** per mantenere test leggibili
2. **Setup/Cleanup** sempre per evitare test flaky
3. **Test Native Features** solo con Patrol
4. **Test Flutter UI** con integration_test normale
5. **Verbose Logging** per debug in CI

## 🚨 Limitazioni

### iOS
- Live Activities richiedono iOS 16.1+
- Dynamic Island solo su iPhone 14 Pro+
- Health permission richiede HealthKit capability

### Android
- Background execution limitata da battery optimization
- Notification channels devono essere configurati

## 📚 Risorse

- [Patrol Documentation](https://patrol.leancode.pl)
- [Patrol GitHub](https://github.com/leancodepl/patrol)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)

## 🤝 Contribuire

Per aggiungere nuovi test:
1. Crea il test in `integration_test/tests/`
2. Aggiungi Page Object se necessario
3. Aggiorna questo README
4. Testa localmente prima di push
5. Verifica CI passa su PR