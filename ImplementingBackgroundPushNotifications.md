# = SOLUZIONE: Notifiche Timer in Background

## L PROBLEMA RISOLTO
L'app iOS veniva killata dopo ~30 secondi in background, quindi il timer non poteva suonare quando finiva.

##  SOLUZIONE IMPLEMENTATA
Ora quando il timer parte, viene IMMEDIATAMENTE schedulata una notifica locale per l'orario di fine timer. In questo modo:
-  Se l'app è attiva quando il timer finisce: la notifica viene cancellata e l'audio viene gestito localmente
-  Se l'app è stata killata: la notifica schedulata suonerà comunque all'orario previsto
-  Se il timer viene fermato manualmente: la notifica viene cancellata

## =ñ COME TESTARE

### Test 1: Timer Breve (< 30 secondi)
1. Avvia un timer di 20 secondi
2. Blocca immediatamente il dispositivo
3. Attendi che il timer finisca
4. **RISULTATO ATTESO**: Dovresti sentire il suono di notifica anche con schermo bloccato

### Test 2: Timer Lungo con App Killata (> 30 secondi)
1. Avvia un timer di 2 minuti
2. Blocca il dispositivo
3. Attendi 1 minuto (iOS killerà l'app dopo ~30 secondi)
4. Attendi che il timer finisca
5. **RISULTATO ATTESO**: La notifica dovrebbe suonare anche se l'app è stata killata

### Test 3: Pausa e Riprendi
1. Avvia un timer di 1 minuto
2. Dopo 20 secondi, metti in pausa
3. Riprendi dopo 10 secondi
4. **RISULTATO ATTESO**: La notifica dovrebbe essere rischedulata correttamente

### Test 4: Stop Manuale
1. Avvia un timer di 1 minuto
2. Dopo 30 secondi, ferma il timer manualmente
3. **RISULTATO ATTESO**: Nessuna notifica dovrebbe suonare

### Test 5: Timer Multipli
1. Avvia un timer
2. Mentre è in corso, prova ad avviarne un altro
3. **RISULTATO ATTESO**: Il primo timer dovrebbe essere cancellato, solo il secondo dovrebbe notificare

## =' FILE MODIFICATI

### 1. `ios/Runner/LiveActivityHandler.swift`
- Aggiunta proprietà `scheduledNotificationId` per tracciare la notifica
- In `createNewLiveActivity`: schedula immediatamente la notifica quando il timer parte
- In `updateLiveActivity`: gestisce reschedule su pausa/riprendi
- In `endLiveActivity`: cancella la notifica se il timer viene fermato manualmente

### 2. `ios/Runner/Managers/BackgroundAudioManager.swift`
- Aggiunto parametro `skipNotification` per evitare duplicati
- Se Live Activity è attiva, la notifica è già schedulata

### 3. `ios/Runner/Managers/UnifiedTimerCoordinator.swift`
- Aggiunto flag `hasLiveActivity` per coordinare le notifiche
- Evita notifiche duplicate quando Live Activity è attiva

### 4. `ios/Runner/Managers/DirectNotificationManager.swift`
- Già configurato per gestire notifiche con suoni custom
- Verifica che i file .caf esistano nel bundle

## <µ SUONI DISPONIBILI
- `sound.caf` - Suono predefinito
- `LightWeight.caf` - "Light weight baby!"
- `YehBuddie.caf` - "Yeah buddy!"
- `timer_complete.caf` - Suono timer generico

##   REQUISITI
- iOS 10.0+ per notifiche locali
- iOS 16.1+ per Live Activities
- Permessi notifiche abilitati dall'utente
- File audio in formato .caf nel bundle

## = DEBUGGING

Se le notifiche non suonano:
1. Verifica permessi: Settings > GymBro > Notifications
2. Controlla console Xcode per log con tag "="
3. Verifica che i file .caf siano nel bundle
4. Controlla che il volume non sia a zero
5. Verifica che il telefono non sia in modalità silenziosa

## =Ê LOG IMPORTANTI
Cerca questi log in Xcode per debug:
- "= SCHEDULING NOTIFICATION IMMEDIATELY" - Quando la notifica viene schedulata
- " Notification scheduled with ID:" - Conferma scheduling
- "= Cancelling scheduled notification:" - Quando viene cancellata
- "ø Timer paused - cancelling notification" - Su pausa
- " Notification rescheduled for" - Su riprendi

## =€ PROSSIMI MIGLIORAMENTI
- [ ] Supporto per suoni diversi per tipo di timer
- [ ] Notifiche critiche per bypassare Do Not Disturb (richiede entitlement speciale)
- [ ] Vibrazione personalizzata per tipo di timer
- [ ] Badge count per timer mancati