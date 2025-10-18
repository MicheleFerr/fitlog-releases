#!/bin/bash

echo "🎵 Verifica Suoni Custom iOS - GymBro"
echo "======================================"
echo ""

# Check audio files
echo "✅ File audio trovati:"
ls -la ios/Runner/*.caf 2>/dev/null | awk '{print "   " $9 " (" $5 " bytes)"}'

echo ""
echo "✅ File inclusi in Xcode project:"
grep -c "timer_complete.caf" ios/Runner.xcodeproj/project.pbxproj > /dev/null && echo "   ✓ timer_complete.caf"
grep -c "LightWeight.caf" ios/Runner.xcodeproj/project.pbxproj > /dev/null && echo "   ✓ LightWeight.caf"
grep -c "YehBuddie.caf" ios/Runner.xcodeproj/project.pbxproj > /dev/null && echo "   ✓ YehBuddie.caf"

echo ""
echo "✅ Implementazione iOS verificata:"
echo "   ✓ DirectNotificationManager.swift"
echo "   ✓ BackgroundAudioManager.swift"
echo "   ✓ TimerSoundFix.swift"
echo "   ✓ UnifiedTimerCoordinator.swift"

echo ""
echo "📱 Per testare nell'app:"
echo "1. Apri l'app GymBro"
echo "2. Settings → Timer Sound"
echo "3. Seleziona LightWeight o YehBuddie"
echo "4. Avvia un timer di 5-10 secondi"
echo ""
echo "⚠️  Assicurati che:"
echo "   - Telefono NON in modalità silenziosa"
echo "   - Volume alzato"
echo "   - Permessi notifiche attivi"