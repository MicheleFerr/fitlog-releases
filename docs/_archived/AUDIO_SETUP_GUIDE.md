# 🎵 Guida Setup Audio Personalizzati per Timer

## 📁 Struttura File Audio

Crea i file audio nella cartella `assets/sounds/` con questi nomi:

```
assets/sounds/
├── timer_complete.wav    # Suono predefinito (già esistente)
├── timer_bell.wav        # Campana
├── timer_chime.wav       # Carillon  
├── timer_beep.wav        # Beep semplice
├── timer_whistle.wav     # Fischietto
├── timer_gong.wav        # Gong
├── timer_airhorn.wav     # Tromba aria
├── timer_boxing.wav      # Campana boxe
└── timer_custom.wav      # Il tuo audio personalizzato
```

## 📝 Aggiornare pubspec.yaml

Aggiungi nella sezione `flutter:` > `assets:`:

```yaml
flutter:
  assets:
    - assets/sounds/
    - assets/i18n/
    - assets/data/
    - assets/images/
```

## 🎯 Formati Audio Supportati

### iOS (preferito):
- **WAV** (non compresso) - Migliore qualità
- **MP3** - Compresso, file più piccoli
- **AAC** - Ottima qualità/dimensione

### Android:
- **WAV** - Supporto nativo
- **MP3** - Supporto completo
- **OGG** - Raccomandato per Android

## 🔧 Setup Completo

1. **Aggiungi i tuoi file audio** nella cartella `assets/sounds/`
2. **Rinomina il tuo file** personalizzato come `timer_custom.wav`
3. **Esegui** `flutter pub get` per ricaricare gli assets
4. **Testa** su entrambe le piattaforme (iOS/Android)

## 🎮 Come Usare

1. **Vai in Settings** nell'app
2. **Cerca "Timer Sound"** nella sezione Audio
3. **Seleziona** il suono desiderato
4. **Premi play** per sentire l'anteprima
5. **Il suono** verrà usato automaticamente per tutti i timer

## 🧪 Testing

```bash
# Build e testa
flutter build ios --debug
flutter build apk --debug

# Test su simulatore/device
flutter run
```

## ⚙️ Configurazione Avanzata

Il sistema salva la preferenza in `AppConfig.timerSound` e la usa automaticamente in:

- ✅ **Notifiche locali** quando il timer finisce
- ✅ **Live Activities** su iOS (se implementate)
- ✅ **Background notifications** 

## 🚨 Note Importanti

1. **Dimensione file**: Mantieni sotto 1MB per performance
2. **Durata**: Massimo 3-5 secondi per il timer
3. **Qualità**: 44.1kHz è sufficiente per notifiche
4. **Naming**: Rispetta esattamente i nomi dei file sopra

## 📱 Platform-Specific

### iOS:
- File copiati automaticamente nel bundle
- Supporto nativo per WAV/MP3
- Funziona con Live Activities

### Android:
- File inclusi come resources
- Richiede rebuild per nuovi file
- Funziona con Local Notifications

## 🎵 Dove Trovare Suoni

Suggerimenti per suoni professionali:
- **Freesound.org** (Creative Commons)
- **Zapsplat** (registrazione gratuita)
- **BBC Sound Effects** (gratis)
- **YouTube Audio Library**

Ricorda di rispettare le licenze audio! 📄