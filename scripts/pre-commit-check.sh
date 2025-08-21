#!/bin/bash

# Pre-commit hook per verificare la localizzazione
echo "🔍 Controllo localizzazione pre-commit..."

# Controlla se ci sono testi hardcoded nei file modificati
HARDCODED_STRINGS=$(git diff --cached --name-only | grep '\.dart$' | xargs grep -l "Text(['\"][A-Za-z\s]{3,}['\"])" | grep -v "AppLocalizations" || true)

if [ ! -z "$HARDCODED_STRINGS" ]; then
    echo "❌ ERRORE: Trovati testi hardcoded nei seguenti file:"
    echo "$HARDCODED_STRINGS"
    echo ""
    echo "💡 Usa AppLocalizations.of(context)!.keyName invece di testi hardcoded"
    echo "📖 Consulta docs/LOCALIZATION_GUIDE.md per maggiori informazioni"
    exit 1
fi

# Controlla se i file di localizzazione sono aggiornati
if git diff --cached --name-only | grep -q "app_.*\.arb$"; then
    echo "📝 File di localizzazione modificati. Rigenero i file..."
    flutter gen-l10n
    if [ $? -ne 0 ]; then
        echo "❌ ERRORE: Rigenerazione localizzazione fallita"
        exit 1
    fi
    
    # Aggiungi i file generati al commit
    git add lib/shared/presentation/l10n/generated/
    echo "✅ File di localizzazione rigenerati e aggiunti al commit"
fi

# Esegui il lint
echo "🧹 Eseguo flutter analyze..."
flutter analyze --no-fatal-infos
if [ $? -ne 0 ]; then
    echo "❌ ERRORE: Flutter analyze ha trovato problemi"
    exit 1
fi

echo "✅ Controllo localizzazione completato con successo!"
exit 0