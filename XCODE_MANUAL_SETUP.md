# Setup Manuale Xcode per Suoni in Lockscreen

## Problema Risolto
I suoni personalizzati (.caf) non funzionavano quando il dispositivo era bloccato a causa delle impostazioni di File Protection.

## Modifiche Automatiche Implementate
✅ **BackgroundAudioManager.swift** ora imposta automaticamente `NSFileProtectionNone` per tutti i file audio
✅ **Logging avanzato** per tracciare lo stato della file protection
✅ **Verifica automatica** delle impostazioni dopo l'applicazione

## Possibili Modifiche Manuali in Xcode (SE NECESSARIO)

### Se il Codice Automatico Non Basta:

#### 1. File Protection Settings (Non c'è in Xcode UI)
❌ **NOTA**: Non esiste una setting "File Protection" in Xcode Build Settings!
✅ **SOLUZIONE**: La file protection è gestita automaticamente dal codice in `BackgroundAudioManager.swift`

Se hai bisogno di configurazione manuale, si fa tramite Info.plist o codice Swift (già implementato).

#### 2. Verificare Resource Bundle Configuration  
- Nel **Project Navigator**, selezionare i file .caf:
  - `timer_complete.caf`
  - `YehBuddie.caf`
  - `LightWeight.caf` 
  - `silent_loop.caf`
- Nell'**Inspector** (pannello destro), verificare:
  - ✅ Target: Runner deve essere selezionato
  - ✅ Add to target: Deve essere nel bundle principale

#### 3. Alternative Location (Se Serve)
Se i file nel bundle principale non funzionano, spostarli in:
- `Library/Sounds` folder nel data container dell'app
- Ma prima prova la soluzione automatica!

## Come Testare

### 1. Controllare i Log
Dopo l'avvio dell'app, nei log iOS cerca:
```
📋 Current protection for timer_complete.caf: [valore]
✅ Set NSFileProtectionNone for timer_complete.caf  
🔍 Verified protection for timer_complete.caf: none
```

### 2. Test Completo
1. Avviare l'app
2. Verificare i log di file protection
3. Avviare un timer
4. **Bloccare il dispositivo** (lockscreen)
5. Attendere la fine del timer
6. **Dovrebbe suonare il file audio personalizzato!**

## Troubleshooting

### Se Ancora Non Funziona:
1. **Controlla i log**: Ci sono errori nella configurazione file protection?
2. **Verifica permessi notifiche**: Sono autorizzate con suoni?
3. **Prova suono default**: Sostituisci temporaneamente con `UNNotificationSound.default`
4. **Test diversi stati**: Funziona in background ma non lockscreen?

### Log da Cercare:
- `⚠️ Could not configure file protection` → Problema di accesso file
- `⚠️ Audio file not found in bundle` → File non nel bundle
- `📱 Flutter method called: scheduleTimerAudio` → Comunicazione Flutter→iOS OK

## Fallback Strategy
Se la soluzione automatica non funziona, il codice può facilmente essere modificato per usare `UNNotificationSound.default` come fallback per lockscreen.