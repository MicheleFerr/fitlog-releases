#!/bin/bash

# Script per rimuovere unused imports automaticamente

echo "🔍 Scanning for unused imports..."

# Trova tutti gli unused import warnings
flutter analyze 2>&1 | grep "unused_import" | while read -r line; do
  # Estrai file e numero di linea
  FILE=$(echo "$line" | cut -d'•' -f2 | awk '{print $1}')

  if [ -f "$FILE" ]; then
    echo "📝 Checking: $FILE"
  fi
done

echo ""
echo "✅ Per rimuovere automaticamente gli import inutilizzati:"
echo "  dart fix --apply"
echo ""
echo "Oppure manualmente rimuovi gli import evidenziati da flutter analyze"
