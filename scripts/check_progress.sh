#!/bin/bash
# Monitor translation progress

EXERCISES_FILE="assets/data/exercises_it.json"
TOTAL=1500

echo "🔍 Controllo Progresso Traduzione DeepL"
echo "======================================="
echo ""

if [ ! -f "$EXERCISES_FILE" ]; then
    echo "❌ File non ancora creato"
    exit 1
fi

# Count translated
TRANSLATED=$(python3 -c "import json; print(len(json.load(open('$EXERCISES_FILE'))))")

# Calculate percentage
PERCENT=$(python3 -c "print(f'{$TRANSLATED/$TOTAL*100:.1f}')")

# Estimate time remaining (assuming 10 min per 50)
REMAINING=$(($TOTAL - $TRANSLATED))
TIME_PER_50=10
BATCHES_LEFT=$(($REMAINING / 50))
MINUTES_LEFT=$(($BATCHES_LEFT * $TIME_PER_50))

echo "📊 Progresso: $TRANSLATED / $TOTAL ($PERCENT%)"
echo "📦 Rimanenti: $REMAINING esercizi"
echo "⏱️  Tempo stimato: ~$MINUTES_LEFT minuti"
echo ""

# Show last translated
echo "📋 Ultimi tradotti:"
python3 -c "
import json
data = json.load(open('$EXERCISES_FILE'))
for ex in data[-3:]:
    print(f\"  • {ex['id']}: {ex['nome']}\")
"

echo ""
echo "🔄 Per aggiornare: bash scripts/check_progress.sh"
