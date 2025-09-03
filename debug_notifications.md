# Debug Notifications - Problema Suoni in Lockscreen

## Problema Corrente
- Timer si completa correttamente (`Set completed: #4`)
- Live Activity viene aggiornata
- **NON arriva suono in lockscreen** (senza Focus Mode, senza silenzioso)
- Notifica mostra sempre "Set 1/1" invece dei valori corretti

## Modifiche Appena Fatte
1. **Semplificato messaggio notifica**: Rimosso "Set X/Y", ora solo nome esercizio
2. **Aggiunto logging**: Per vedere se Flutter chiama iOS
3. **Corretto duration**: Da 0.1 a 0.0 per notifiche immediate

## Test da Fare
1. Avvia timer
2. Metti telefono in lockscreen
3. Aspetta completamento timer
4. Controlla:
   - Arriva notifica?
   - C'è suono?
   - Log iOS mostrano chiamata da Flutter?

## Log da Controllare
Cerca nei log:
- `📱 Flutter method called: scheduleTimerAudio`
- `🔔 Triggering immediate notification for [esercizio] with sound: [nome_suono]`

Se NON vedi questi log → Il problema è nella comunicazione Flutter → iOS
Se li vedi ma niente suono → Il problema è nella notifica iOS

## Soluzioni Possibili se Suono Non Funziona

### Opzione 1: Local Notifications
Usare flutter_local_notifications per le notifiche immediate

### Opzione 2: Testare Altri Suoni
Provare con "default" invece di file .caf personalizzati

### Opzione 3: Controllare Permessi Notifiche
Verificare che le notifiche sono autorizzate per suoni in lockscreen

## File Modificati
- `BackgroundAudioManager.swift`: Semplificato messaggio, aggiunto logging
- `timer_notification_coordinator.dart`: Cambiato duration da 0.1 a 0.0