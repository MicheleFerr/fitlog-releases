# 🔧 iOS Build Fix - BoringSSL-GRPC Error

## ⚠️ Problema:
Errore di compilazione con BoringSSL-GRPC - file di dipendenze non accessibile

## ✅ Soluzione Step-by-Step:

### 1. **Apri Xcode**
```bash
open ios/Runner.xcworkspace
```
**IMPORTANTE**: Apri `.xcworkspace`, NON `.xcodeproj`!

### 2. **In Xcode - Clean Build Folder**
- Menu: `Product` → `Clean Build Folder` (Shift+Cmd+K)
- Aspetta che finisca

### 3. **Chiudi Xcode completamente**
- Cmd+Q per uscire completamente

### 4. **Terminal - Esegui questi comandi**
```bash
# Dalla root del progetto
cd ios
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
rm -rf build/
rm -rf Pods/
rm Podfile.lock
pod cache clean --all
pod install --repo-update
cd ..
```

### 5. **Flutter Clean Build**
```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### 6. **Riapri Xcode e Build**
```bash
open ios/Runner.xcworkspace
```
- Seleziona il device/simulator
- Product → Build (Cmd+B)

## 🔄 Se Persiste l'Errore:

### Opzione A: Reset Completo Pods
```bash
cd ios
pod deintegrate
sudo gem cleanup cocoapods
sudo gem install cocoapods
pod setup
pod install --repo-update
```

### Opzione B: Modifica Podfile
Aggiungi questa riga nel Podfile dopo `platform :ios`:
```ruby
pod 'BoringSSL-GRPC', :modular_headers => true
```

### Opzione C: Build da Flutter
```bash
flutter build ios --no-codesign
```

## 📝 Note:
- L'errore è comune con Firebase/gRPC
- Spesso causato da cache corrotta in DerivedData
- Il clean completo risolve il 90% dei casi

## ✅ Script Automatico Disponibile:
```bash
./scripts/fix_ios_build.sh
```

---

**Se ancora non funziona**, prova:
1. Aggiorna CocoaPods: `sudo gem install cocoapods`
2. Aggiorna Flutter: `flutter upgrade`
3. Verifica Xcode: deve essere versione 15+ per iOS 18.5