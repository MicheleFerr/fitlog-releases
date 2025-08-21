#!/bin/bash

# 🔇 Generate Silent Audio File for GymBro Background Timer
# 
# Creates a 1-second silent WAV file optimized for iOS background audio execution
# This silent track is used to keep the app active in background while timer runs

set -e

echo "🔇 ========================================"
echo "🔇 GENERATING SILENT AUDIO FOR GYMBRO"
echo "🔇 ========================================"
echo ""

# Configuration
OUTPUT_DIR="assets/sounds"
OUTPUT_FILE="silent_1s.wav"
DURATION=1  # 1 second
SAMPLE_RATE=44100  # Standard iOS-compatible sample rate
CHANNELS=1  # Mono to minimize file size

echo "📋 Configuration:"
echo "   Output directory: $OUTPUT_DIR"
echo "   Output file: $OUTPUT_FILE"
echo "   Duration: ${DURATION}s"
echo "   Sample rate: ${SAMPLE_RATE}Hz"
echo "   Channels: $CHANNELS (mono)"
echo ""

# Check if ffmpeg is available
if command -v ffmpeg &> /dev/null; then
    echo "🔧 Using ffmpeg to generate silent audio..."
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"
    
    # Generate silent WAV file with ffmpeg
    ffmpeg -f lavfi -i anullsrc=channel_layout=mono:sample_rate=$SAMPLE_RATE -t $DURATION -c:a pcm_s16le "$OUTPUT_DIR/$OUTPUT_FILE" -y
    
    echo "✅ Silent audio generated with ffmpeg"
    
elif command -v sox &> /dev/null; then
    echo "🔧 Using sox to generate silent audio..."
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"
    
    # Generate silent WAV file with sox
    sox -n -r $SAMPLE_RATE -c $CHANNELS "$OUTPUT_DIR/$OUTPUT_FILE" trim 0.0 $DURATION
    
    echo "✅ Silent audio generated with sox"
    
else
    echo "❌ Neither ffmpeg nor sox found!"
    echo ""
    echo "🔧 INSTALLATION OPTIONS:"
    echo ""
    echo "Option 1 - Install ffmpeg (recommended):"
    echo "   brew install ffmpeg"
    echo ""
    echo "Option 2 - Install sox:"
    echo "   brew install sox"
    echo ""
    echo "Option 3 - Manual creation:"
    echo "   Use any audio editor to create a 1-second silent WAV file"
    echo "   - Duration: 1 second"
    echo "   - Sample rate: 44.1kHz"
    echo "   - Format: WAV (PCM 16-bit)"
    echo "   - Channels: Mono"
    echo "   - Save as: $OUTPUT_DIR/$OUTPUT_FILE"
    echo ""
    exit 1
fi

# Verify the generated file
if [ -f "$OUTPUT_DIR/$OUTPUT_FILE" ]; then
    FILE_SIZE=$(ls -lh "$OUTPUT_DIR/$OUTPUT_FILE" | awk '{print $5}')
    echo ""
    echo "📊 File verification:"
    echo "   Path: $OUTPUT_DIR/$OUTPUT_FILE"
    echo "   Size: $FILE_SIZE"
    
    # Check file details if ffprobe is available
    if command -v ffprobe &> /dev/null; then
        echo "   Details:"
        ffprobe -v quiet -show_format -show_streams "$OUTPUT_DIR/$OUTPUT_FILE" | grep -E "(duration|sample_rate|channels)" | sed 's/^/     /'
    fi
    
    echo ""
    echo "✅ Silent audio file ready for iOS background timer!"
    echo ""
    echo "📱 USAGE:"
    echo "   This file is used by GymBro's silent track system to maintain"
    echo "   background audio session while timer is running. The file will"
    echo "   loop silently at 0% volume to keep iOS from suspending the app."
    echo ""
    echo "🔧 TECHNICAL DETAILS:"
    echo "   - File plays in continuous loop during timer countdown"
    echo "   - Volume set to 0.0 (completely silent)"
    echo "   - Uses native AudioPlayer loop mode for efficiency"
    echo "   - Automatically switches to completion audio when timer ends"
    echo ""
    
else
    echo "❌ Failed to generate silent audio file"
    exit 1
fi

echo "🔇 ========================================"
echo "🔇 SILENT AUDIO GENERATION COMPLETE"
echo "🔇 ========================================"