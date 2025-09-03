# Fix Lockscreen Audio - Debug Guide

## 🎯 Problema Risolto
**Root Cause**: Flutter method channels non funzionano in background/lockscreen
**Soluzione**: Pre-schedulazione notifica iOS con timestamp preciso

## 📋 Come Testare

### 1. Avviare Timer
1. Avviare un timer (es: 10 secondi)  
2. **Subito** cercare nei log:
   ```
   📅 Scheduling notification for timestamp: [numero] (sound: timer_complete)
   ✅ Background notification scheduled for [data/ora]
   📋 Notification details: [esercizio] - Set X/Y - Sound: [nome_suono]
   ```

### 2. Mettere in Lockscreen
- Bloccare il telefono
- Aspettare che il timer finisca
- **NON dovrebbe esserci nessuna chiamata a scheduleTimerAudio nei log**
- La notifica dovrebbe partire automaticamente da iOS

### 3. Verificare Risultato
✅ **Successo se**:
- Suono personalizzato parte in lockscreen
- Notifica appare con testo corretto
- Log mostrano pre-schedulazione all'avvio timer

❌ **Fallimento se**: 
- Nessun suono in lockscreen
- Log non mostrano pre-schedulazione
- Suono parte solo alla riapertura app

## 🔍 Log da Cercare

### All'avvio del timer:
```
📱 Flutter method called: scheduleNotificationForTime
📅 Scheduling notification for timestamp: 1724861234.567 (sound: timer_complete)
⏰ Will trigger in 10.0 seconds
✅ Background notification scheduled for 2024-08-28 17:40:34 +0000
📋 Notification details: Squat - Set 1/4 - Sound: timer_complete
```

### Alla fine del timer (NON dovrebbe esserci):
```
// ❌ Questi log NON dovrebbero apparire più in lockscreen:
📱 Flutter method called: scheduleTimerAudio
🔔 Triggering immediate notification for [esercizio] with sound: [suono]
```

### Se app è in foreground:
```
iOS background notification already scheduled, skipping completion notification
```

## ⚙️ Modifiche Implementate

1. **Flutter Side** (`timer_audio_module.dart`):
   - Nuovo metodo `scheduleNotificationForTime` 
   - Calcola timestamp futuro preciso
   - Flag per prevenire notifiche doppie

2. **iOS Side** (`BackgroundAudioManager.swift`):
   - Nuovo metodo `scheduleNotificationForTime()`
   - Usa `UNTimeIntervalNotificationTrigger` 
   - File protection configurata per suoni custom

3. **Strategia**:
   - Pre-schedulazione al momento dell'avvio timer
   - Zero dipendenza da Flutter in background
   - iOS gestisce tutto nativamente

## 🎵 File Audio Supportati
- `timer_complete.caf` ✅
- `YehBuddie.caf` ✅  
- `LightWeight.caf` ✅
- Tutti configurati con `NSFileProtectionNone`

## 🚨 Troubleshooting

### Se ancora non funziona:
1. **Controlla permessi notifiche**: Settings > App > Notifications
2. **Verifica suoni custom**: Dovrebbero essere < 30 secondi 
3. **Check Focus Mode**: Disabilitare Do Not Disturb
4. **Log analysis**: Cercare errori nella schedulazione

### Fallback automatico:
- Se `scheduleNotificationForTime` fallisce → usa metodo precedente
- Se timestamp è nel passato → notifica immediata
- Gestione errori completa con logging dettagliato