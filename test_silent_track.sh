#!/bin/bash

# 🧪 Test Script per Silent Track Background Audio Solution
# GymBro Flutter App - iOS Background Audio Fix

echo "🧪 === GYMBRO SILENT TRACK BACKGROUND AUDIO TEST ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 TEST CHECKLIST:${NC}"
echo "1. Verifica file silent_1s.wav esiste"
echo "2. Build app in Release mode"  
echo "3. Deploy su device iOS fisico"
echo "4. Test background audio con silent track"
echo ""

# 1. Check silent audio file exists
echo -e "${YELLOW}🔍 Step 1: Verifica Silent Audio File${NC}"
if [ -f "assets/sounds/silent_1s.wav" ]; then
    SIZE=$(ls -lh assets/sounds/silent_1s.wav | awk '{print $5}')
    echo -e "${GREEN}✅ silent_1s.wav trovato (Size: $SIZE)${NC}"
    
    # Check file duration with ffprobe if available
    if command -v ffprobe >/dev/null 2>&1; then
        DURATION=$(ffprobe -v quiet -show_entries format=duration -of csv="p=0" assets/sounds/silent_1s.wav 2>/dev/null)
        echo -e "${GREEN}✅ Duration: ${DURATION}s${NC}"
    fi
else
    echo -e "${RED}❌ silent_1s.wav NON trovato!${NC}"
    echo "Esegui: ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 1 -acodec pcm_s16le assets/sounds/silent_1s.wav -y"
    exit 1
fi
echo ""

# 2. Flutter clean and get
echo -e "${YELLOW}🔍 Step 2: Flutter Prep${NC}"
echo "Eseguendo flutter clean e pub get..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1
echo -e "${GREEN}✅ Flutter prep completato${NC}"
echo ""

# 3. Check iOS configuration
echo -e "${YELLOW}🔍 Step 3: Verifica iOS Configuration${NC}"

# Check Info.plist for background modes
if grep -q "audio" ios/Runner/Info.plist; then
    echo -e "${GREEN}✅ UIBackgroundModes audio configurato${NC}"
else
    echo -e "${RED}❌ UIBackgroundModes audio MANCANTE in Info.plist${NC}"
fi

# Check AppDelegate for AVAudioSession
if grep -q "AVAudioSession" ios/Runner/AppDelegate.swift; then
    echo -e "${GREEN}✅ AVAudioSession configuration presente${NC}"
else
    echo -e "${YELLOW}⚠️ AVAudioSession configuration potrebbe mancare${NC}"
fi
echo ""

# 4. Test instructions
echo -e "${BLUE}📱 ISTRUZIONI TEST DEVICE:${NC}"
echo ""
echo -e "${YELLOW}BUILD & DEPLOY:${NC}"
echo "1. Apri Xcode: open ios/Runner.xcworkspace"
echo "2. Seleziona device iOS fisico (non simulator)"
echo "3. Scheme: Runner (Release)"
echo "4. Build and Run (Cmd+R)"
echo ""

echo -e "${YELLOW}TEST PROCEDURE:${NC}"
echo "1. ▶️  Avvia timer (es. 15 secondi per test veloce)"
echo "2. 📱 Premi home button IMMEDIATAMENTE (va in background)"
echo "3. ⏱️  Aspetta completamento timer (15 secondi)"
echo "4. 🔊 VERIFICA: Audio dovrebbe suonare mentre app è in background"
echo "5. 📱 Riapri app per vedere logs"
echo ""

echo -e "${YELLOW}LOGS DA ASPETTARSI:${NC}"
echo "🔇 Silent audio loop started - app should stay in background"
echo "🔇 === TIMER COMPLETED [timestamp] ==="
echo "🔇 Stopping silent audio and playing completion sound"
echo "🔊 🎉 SUCCESS: Scheduled audio is playing!"
echo ""

echo -e "${YELLOW}TEST SCENARIOS:${NC}"
echo "A. 📱 FOREGROUND → BACKGROUND: Avvia timer, vai subito in background"
echo "B. 🔁 BACKGROUND ONLY: Timer completamente in background"
echo "C. 📱 BACKGROUND → FOREGROUND: Timer in background, rientri durante countdown"
echo ""

echo -e "${RED}SE AUDIO NON FUNZIONA:${NC}"
echo "1. Verifica volume device non in silent"
echo "2. Controlla Xcode logs per errori AVAudioSession"
echo "3. Verifica Background App Refresh abilitato per l'app"
echo "4. Test con cuffie/AirPods collegati"
echo ""

echo -e "${GREEN}🎯 EXPECTED RESULT:${NC}"
echo "✅ Audio completion dovrebbe suonare CHIARAMENTE in background"
echo "✅ Non dovrebbe esserci più 'PlayerState.playing but no sound'"
echo "✅ Silent track workaround mantiene app attiva"
echo ""

echo -e "${BLUE}🚀 Ready to test! Segui le istruzioni sopra.${NC}"
echo "Fai sapere i risultati per eventuali fix aggiuntivi."