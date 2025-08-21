#!/bin/bash

echo "🎯 TEST TIMER AUDIO GYMBRO"
echo "========================="
echo ""
echo "1. Verifica file audio nel bundle iOS:"
ls -la ios/Runner/*.wav ios/Runner/*.caf 2>/dev/null

echo ""
echo "2. Verifica silent loop file:"
if [ -f "ios/Runner/silent_loop.wav" ]; then
    echo "✅ silent_loop.wav PRESENTE"
    ls -lh ios/Runner/silent_loop.wav
else
    echo "❌ silent_loop.wav MANCANTE"
fi

echo ""
echo "3. Verifica timer_complete audio:"
ls -la ios/Runner/timer_complete.* 2>/dev/null

echo ""
echo "4. Per testare:"
echo "   - Avvia timer 60s"
echo "   - Blocca dispositivo"
echo "   - Controlla nei log:"
echo "     * '🔇 Silent loop started' (deve apparire)"
echo "     * '❌ Silent loop file not found' (NON deve apparire)"
echo "     * Notification scheduled for 60.0s (solo UNA)"
echo ""
echo "5. Se ancora non funziona, esegui:"
echo "   flutter clean && flutter build ios --no-codesign"