# 🔍 Live Activity Troubleshooting Guide

## ✅ Cosa è Stato Risolto

1. **UnifiedTimerCoordinator ora delega correttamente a LiveActivityHandler**
   - Prima: I metodi erano vuoti e restituivano solo `result(true)`
   - Ora: Chiamano i metodi pubblici di LiveActivityHandler

2. **LiveActivityHandler espone metodi pubblici**
   - `startLiveActivityDirectly()`
   - `updateLiveActivityDirectly()`
   - `endLiveActivityDirectly()`

3. **Logging dettagliato aggiunto**
   - Flutter logga tutti i parametri inviati
   - iOS logga la ricezione e l'esecuzione

## 🧪 Come Testare

### 1. Abilita i Log di Debug
Esegui l'app con:
```bash
flutter run --debug
```

### 2. Controlla la Console Xcode
1. Apri Xcode: `open ios/Runner.xcworkspace`
2. Vai su **Window → Devices and Simulators**
3. Seleziona il tuo dispositivo
4. Clicca su **Open Console**
5. Filtra per "LiveActivity" o "Timer"

### 3. Cosa Dovresti Vedere nei Log

Quando avvii un timer:
```
📱 Starting Live Activity...
   Exercise: Bench Press
   Timer Type: rest
   Duration: 90s
   Remaining: 90s
   Set: 1/3
✅ Live Activity started successfully. ID: xyz123
```

Se NON vedi "Live Activity started successfully", controlla:

## ⚠️ Possibili Problemi Rimanenti

### 1. **Live Activities Non Abilitate nel Sistema**
**Sintomo**: Log mostra "Live Activities are disabled in system settings"
**Soluzione**: 
- Vai in **Impostazioni iOS → [Tua App] → Live Activities**
- Attiva l'interruttore

### 2. **Widget Extension Non Configurato**
**Sintomo**: Log mostra "Failed to start activity: widget not found"
**Soluzione**:
- Verifica che `GymBroTimerWidget` sia nel target corretto in Xcode
- Build scheme deve includere l'extension

### 3. **Entitlements Mancanti**
**Sintomo**: Log mostra "Missing entitlements for Live Activities"
**Soluzione**:
- Controlla che `Runner.entitlements` abbia le capability corrette
- Rigenera i provisioning profiles

### 4. **iOS Version < 16.1**
**Sintomo**: Log mostra "Live Activities require iOS 16.1 or later"
**Soluzione**: Aggiorna iOS o testa su dispositivo più recente

## 📱 Test Rapido da Console

Puoi testare direttamente da Flutter console:
```dart
// In debug console mentre l'app è in esecuzione
await MethodChannel('com.gymbro.timer/unified').invokeMethod('startLiveActivity', {
  'exerciseName': 'Test Timer',
  'timerType': 'rest',
  'totalSeconds': 60,
  'remainingSeconds': 60,
  'isRunning': true,
  'currentSet': 1,
  'totalSets': 1,
  'lastUpdated': DateTime.now().millisecondsSinceEpoch,
});
```

## 🔧 Debug Avanzato

### Controlla se ActivityKit è disponibile:
```swift
// Aggiungi temporaneamente in LiveActivityHandler
if #available(iOS 16.1, *) {
    print("ActivityKit available: \(ActivityAuthorizationInfo().areActivitiesEnabled)")
}
```

### Verifica Widget Bundle ID:
Il widget deve avere bundle ID: `com.michele.gymbro.flutter.GymBroTimerWidget`

### Controlla Activity Type Registration:
Deve corrispondere tra Swift e widget:
- Swift: `GymBroTimerWidgetAttributes`
- Widget: Stesso nome nel widget Swift file

## 📊 Status Check

Esegui questo comando per verificare lo stato:
```bash
# Controlla se il widget è nel progetto
grep -r "GymBroTimerWidget" ios/Runner.xcodeproj/project.pbxproj

# Controlla entitlements
grep -r "NSSupportsLiveActivities" ios/Runner/Info.plist

# Controlla se ActivityKit è importato
grep -r "import ActivityKit" ios/
```

## 🚀 Prossimi Passi

1. **Esegui l'app con console Xcode aperta**
2. **Avvia un timer**
3. **Controlla i log per identificare il punto di fallimento**
4. **Condividi i log specifici dell'errore**

Il codice ora è corretto, ma potrebbe esserci un problema di configurazione iOS o permessi.