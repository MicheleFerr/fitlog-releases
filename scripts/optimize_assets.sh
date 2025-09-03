#!/bin/bash

# 🎯 Script di ottimizzazione asset per GymBro
# Riduce dimensioni audio e ottimizza JSON

echo "🎯 Ottimizzazione Asset GymBro"
echo "================================"

# Percorsi
ASSETS_DIR="../assets"
SOUNDS_DIR="$ASSETS_DIR/sounds"
DATA_DIR="$ASSETS_DIR/data"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\n${YELLOW}📊 Analisi pre-ottimizzazione:${NC}"
echo "Dimensione totale assets: $(du -sh $ASSETS_DIR | cut -f1)"
echo "Dimensione sounds: $(du -sh $SOUNDS_DIR | cut -f1)"
echo "Dimensione data: $(du -sh $DATA_DIR | cut -f1)"

# 1. Rimuovi duplicati audio (mantieni solo .wav compressi)
echo -e "\n${GREEN}🎵 Ottimizzazione audio...${NC}"

# Backup prima di modificare
mkdir -p "$SOUNDS_DIR/backup"
cp $SOUNDS_DIR/*.* "$SOUNDS_DIR/backup/" 2>/dev/null

# Rimuovi file .caf duplicati (iOS può usare .wav)
echo "Rimozione duplicati .caf..."
rm -f $SOUNDS_DIR/*.caf

# Comprimi file .wav con ffmpeg se disponibile
if command -v ffmpeg &> /dev/null; then
    echo "Compressione audio con ffmpeg..."
    for file in $SOUNDS_DIR/*.wav; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .wav)
            # Comprimi a 64kbps mono per effetti sonori
            ffmpeg -i "$file" -ac 1 -ar 22050 -ab 64k "$SOUNDS_DIR/${filename}_compressed.wav" -y 2>/dev/null
            if [ $? -eq 0 ]; then
                mv "$SOUNDS_DIR/${filename}_compressed.wav" "$file"
                echo "  ✅ Compresso: $filename.wav"
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠️  ffmpeg non installato. Installa con: brew install ffmpeg${NC}"
fi

# 2. Ottimizza JSON degli esercizi
echo -e "\n${GREEN}📚 Ottimizzazione database esercizi...${NC}"

# Rimuovi backup non necessario
if [ -f "$DATA_DIR/exercises_backup.json" ]; then
    echo "Rimozione backup exercises_backup.json..."
    rm -f "$DATA_DIR/exercises_backup.json"
fi

# Minifica JSON con jq se disponibile
if command -v jq &> /dev/null; then
    echo "Minificazione exercises.json..."
    jq -c . "$DATA_DIR/exercises.json" > "$DATA_DIR/exercises_min.json"
    if [ $? -eq 0 ]; then
        mv "$DATA_DIR/exercises_min.json" "$DATA_DIR/exercises.json"
        echo "  ✅ JSON minificato"
    fi
else
    echo -e "${YELLOW}⚠️  jq non installato. Installa con: brew install jq${NC}"
fi

# 3. Analisi post-ottimizzazione
echo -e "\n${GREEN}📊 Risultati ottimizzazione:${NC}"
echo "Dimensione totale assets: $(du -sh $ASSETS_DIR | cut -f1)"
echo "Dimensione sounds: $(du -sh $SOUNDS_DIR | cut -f1)"
echo "Dimensione data: $(du -sh $DATA_DIR | cut -f1)"

# Calcola risparmio
ORIGINAL_SIZE=$(du -sb "$SOUNDS_DIR/backup" 2>/dev/null | cut -f1)
NEW_SIZE=$(du -sb "$SOUNDS_DIR" | cut -f1)
if [ -n "$ORIGINAL_SIZE" ] && [ -n "$NEW_SIZE" ]; then
    SAVED=$((ORIGINAL_SIZE - NEW_SIZE))
    PERCENT=$((SAVED * 100 / ORIGINAL_SIZE))
    echo -e "${GREEN}💾 Spazio risparmiato: ~${PERCENT}%${NC}"
fi

echo -e "\n${GREEN}✅ Ottimizzazione completata!${NC}"
echo -e "${YELLOW}📝 Note:${NC}"
echo "  - File audio compressi a 64kbps mono"
echo "  - Rimossi duplicati .caf"
echo "  - JSON minificato"
echo "  - Backup salvato in sounds/backup/"