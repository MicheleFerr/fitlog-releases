#!/bin/bash

# Test script per verificare i suoni custom in GymBro
echo "🎵 GymBro Custom Sound Test Script"
echo "================================="
echo ""

# Verifica che i file audio esistano
echo "1️⃣ Verifica file audio nel bundle iOS:"
echo "----------------------------------------"
for sound in "timer_complete" "LightWeight" "YehBuddie"; do
    if [ -f "ios/Runner/${sound}.caf" ]; then
        echo "✅ ${sound}.caf trovato"
        ls -lh "ios/Runner/${sound}.caf"
    else
        echo "❌ ${sound}.caf NON TROVATO!"
    fi
done

echo ""
echo "2️⃣ Verifica inclusione in Xcode project:"
echo "----------------------------------------"
for sound in "timer_complete" "LightWeight" "YehBuddie"; do
    if grep -q "${sound}.caf" ios/Runner.xcodeproj/project.pbxproj; then
        echo "✅ ${sound}.caf incluso nel progetto Xcode"
    else
        echo "❌ ${sound}.caf NON incluso nel progetto Xcode!"
    fi
done

echo ""
echo "3️⃣ Verifica implementazione iOS:"
echo "----------------------------------------"
if grep -q "DirectNotificationManager" ios/Runner/Managers/BackgroundAudioManager.swift; then
    echo "✅ DirectNotificationManager integrato"
else
    echo "❌ DirectNotificationManager non trovato!"
fi

if grep -q "verifyAudioFile" ios/Runner/Managers/DirectNotificationManager.swift; then
    echo "✅ Verifica file audio implementata"
else
    echo "❌ Verifica file audio non implementata!"
fi

echo ""
echo "4️⃣ Verifica passaggio parametri da Flutter:"
echo "----------------------------------------"
if grep -q "config.timerSound" lib/features/workout/presentation/widgets/workout_actions/workout_fab.dart; then
    echo "✅ Sound preference passata dal FAB"
else
    echo "❌ Sound preference NON passata dal FAB!"
fi

if grep -q "customSound: config.timerSound" lib/features/timer/presentation/providers/unified_timer_extensions.dart; then
    echo "✅ Sound preference passata nelle extensions"
else
    echo "❌ Sound preference NON passata nelle extensions!"
fi

echo ""
echo "5️⃣ Test da eseguire manualmente nell'app:"
echo "----------------------------------------"
echo "1. Vai in Settings → Timer Sound"
echo "2. Premi il pulsante play per aprire il test dialog"
echo "3. Testa ogni suono individualmente (3 secondi)"
echo "4. Esegui 'Full iOS Test' per test completo"
echo ""
echo "⚠️ IMPORTANTE:"
echo "- Assicurati che il telefono NON sia in modalità silenziosa"
echo "- Volume deve essere alzato"
echo "- Permessi notifiche devono essere attivi"
echo ""
echo "✅ Test script completato!"