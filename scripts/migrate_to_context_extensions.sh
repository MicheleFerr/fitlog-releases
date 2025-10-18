#!/bin/bash

# Script per migrare automaticamente file da Theme.of(context) a context.colors
# Usage: ./scripts/migrate_to_context_extensions.sh <file_path>

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "Error: File $FILE not found"
  exit 1
fi

echo "🔄 Migrating $FILE to use BuildContext extensions..."

# Backup originale
cp "$FILE" "${FILE}.backup"

# 1. Aggiungi import se non presente
if ! grep -q "build_context_extensions.dart" "$FILE"; then
  echo "📝 Adding build_context_extensions import..."
  # Trova l'ultima riga di import e aggiungi dopo
  awk '/^import /{last=NR} last && NR==last+1{print "import '\''package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart'\'';"; print; next} 1' "$FILE" > "${FILE}.tmp"
  mv "${FILE}.tmp" "$FILE"
fi

# 2. Sostituisci Theme.of(context).colorScheme con context.colors
sed -i '' 's/Theme\.of(context)\.colorScheme/context.colors/g' "$FILE"

# 3. Sostituisci Theme.of(context).textTheme con context.textTheme
sed -i '' 's/Theme\.of(context)\.textTheme/context.textTheme/g' "$FILE"

# 4. Sostituisci Theme.of(context).brightness con context.isDarkMode o context.theme.brightness
# Nota: questo richiede logica più complessa, lo facciamo manualmente

# 5. Sostituisci Theme.of(context) rimanenti con context.theme
sed -i '' 's/Theme\.of(context)/context.theme/g' "$FILE"

# 6. Sostituisci AppLocalizations.of(context)! con context.l10n
sed -i '' 's/AppLocalizations\.of(context)!/context.l10n/g' "$FILE"

# 7. Sostituisci MediaQuery.of(context).size.height con context.screenHeight
sed -i '' 's/MediaQuery\.of(context)\.size\.height/context.screenHeight/g' "$FILE"

# 8. Sostituisci MediaQuery.of(context).size.width con context.screenWidth
sed -i '' 's/MediaQuery\.of(context)\.size\.width/context.screenWidth/g' "$FILE"

# 9. Sostituisci MediaQuery.of(context) rimanenti con context.mediaQuery
sed -i '' 's/MediaQuery\.of(context)/context.mediaQuery/g' "$FILE"

# 10. Rimuovi import di app_localizations se presente (ora usiamo extension)
# Commentiamo invece di rimuovere per sicurezza
# sed -i '' '/import.*app_localizations\.dart/d' "$FILE"

echo "✅ Migration completed!"
echo "📊 Changes:"
echo "   - Theme.of(context).colorScheme → context.colors"
echo "   - Theme.of(context).textTheme → context.textTheme"
echo "   - Theme.of(context) → context.theme"
echo "   - AppLocalizations.of(context)! → context.l10n"
echo "   - MediaQuery.of(context).size.* → context.screen*"
echo ""
echo "⚠️  Backup saved to: ${FILE}.backup"
echo "🔍 Please run 'flutter analyze $FILE' to verify"
