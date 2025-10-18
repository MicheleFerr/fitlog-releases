#!/bin/bash

# Script per convertire import relativi in assoluti in lib/app/app.dart

echo "🔧 Fixing relative imports in lib/app/app.dart..."

FILE="lib/app/app.dart"

# Backup originale
cp "$FILE" "$FILE.backup"

# Converti import relativi in assoluti
sed -i '' "s|import '../features/|import 'package:gymbro_flutter_new/features/|g" "$FILE"
sed -i '' "s|import '../shared/|import 'package:gymbro_flutter_new/shared/|g" "$FILE"

echo "✅ Import fissi! Backup salvato in $FILE.backup"
echo ""
echo "Verifica le modifiche con:"
echo "  git diff $FILE"
echo ""
echo "Se tutto ok, rimuovi il backup:"
echo "  rm $FILE.backup"
