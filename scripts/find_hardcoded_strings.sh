#!/bin/bash

# Script per trovare tutti i testi hardcoded nel progetto Flutter
# Esclude i file generati e di configurazione

echo "🔍 Ricerca testi hardcoded nel progetto..."
echo "============================================"

# Pattern per trovare Text() con stringhe hardcoded
echo "📱 Testi nei widget Text():"
find lib -name "*.dart" -not -path "*/generated/*" -not -path "*/.dart_tool/*" | \
xargs grep -n "Text(['\"][A-Za-z\s]{3,}['\"])" | \
grep -v "AppLocalizations" | \
head -20

echo ""
echo "💬 Testi nei SnackBar:"
find lib -name "*.dart" -not -path "*/generated/*" | \
xargs grep -n "SnackBar.*content.*Text(['\"][^'\"]*['\"])" | \
head -10

echo ""
echo "🏷️ Titoli hardcoded:"
find lib -name "*.dart" -not -path "*/generated/*" | \
xargs grep -n "title:.*Text(['\"][^'\"]*['\"])" | \
head -10

echo ""
echo "🔘 Label hardcoded:"
find lib -name "*.dart" -not -path "*/generated/*" | \
xargs grep -n "label:.*Text(['\"][^'\"]*['\"])" | \
head -10

echo ""
echo "💡 Suggerimento: Sostituisci questi testi con AppLocalizations.of(context)!.keyName"
echo "📝 Aggiungi le traduzioni nei file assets/i18n/app_*.arb"