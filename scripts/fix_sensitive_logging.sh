#!/bin/bash

# 🔒 Script Fix Automatico Logging Sensibile
# Sostituisce debugPrint con SecureLogger nei file CRITICI
#
# Uso:
#   ./scripts/fix_sensitive_logging.sh         # Dry-run (mostra cosa farà)
#   ./scripts/fix_sensitive_logging.sh --apply # Applica modifiche
#

set -e

DRY_RUN=true
if [ "$1" == "--apply" ]; then
    DRY_RUN=false
fi

echo "🔍 Script Fix Logging Sensibile"
echo "================================"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "📋 MODALITÀ DRY-RUN (nessuna modifica applicata)"
    echo "   Usa: ./scripts/fix_sensitive_logging.sh --apply per applicare"
    echo ""
else
    echo "⚠️  MODALITÀ APPLY - Le modifiche saranno applicate!"
    echo ""
    read -p "Sei sicuro? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Annullato dall'utente"
        exit 1
    fi
fi

# File CRITICI da fixare (severity ALTA)
CRITICAL_FILES=(
    "lib/features/auth/presentation/providers/admin_provider.dart"
    "lib/features/settings/presentation/providers/cloud_sync_provider.dart"
    "lib/features/community/presentation/providers/community_provider.dart"
    "lib/features/workout/presentation/providers/recovery_provider.dart"
    "lib/features/workout/presentation/providers/workout_template_provider.dart"
)

TOTAL_FILES=${#CRITICAL_FILES[@]}
FIXED_FILES=0
TOTAL_REPLACEMENTS=0

echo "📁 File da processare: $TOTAL_FILES"
echo ""

for file in "${CRITICAL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "⚠️  File non trovato: $file (skip)"
        continue
    fi

    echo "📝 Processing: $file"

    # Conta occorrenze debugPrint con dati sensibili
    sensitive_count=$(grep -c "debugPrint.*\(email\|uid\|claims\|token\|password\|api\)" "$file" 2>/dev/null || echo "0")

    if [ "$sensitive_count" -eq 0 ]; then
        echo "   ✅ Nessun log sensibile trovato (skip)"
        echo ""
        continue
    fi

    echo "   🔍 Trovati $sensitive_count log sensibili"

    # Verifica se SecureLogger import esiste già
    has_import=$(grep -c "import.*secure_logger" "$file" 2>/dev/null || echo "0")

    if [ "$DRY_RUN" = true ]; then
        # Mostra cosa farebbe
        echo "   📋 Modifiche che saranno applicate:"
        echo "      - Sostituire debugPrint → SecureLogger.info"
        if [ "$has_import" -eq 0 ]; then
            echo "      - Aggiungere import SecureLogger"
        fi

        # Mostra preview delle linee che cambieranno
        echo "   📄 Preview modifiche:"
        grep -n "debugPrint.*\(email\|uid\|claims\|token\|password\|api\)" "$file" | head -3 | while IFS=: read -r line_num line_content; do
            echo "      Linea $line_num: ${line_content:0:60}..."
        done

    else
        # Applica modifiche

        # Backup file originale
        cp "$file" "$file.backup"

        # 1. Sostituisci debugPrint con SecureLogger.info
        sed -i.tmp 's/debugPrint(/SecureLogger.info(/g' "$file"

        # 2. Aggiungi import se non esiste
        if [ "$has_import" -eq 0 ]; then
            # Trova la prima linea di import
            first_import_line=$(grep -n "^import " "$file" | head -1 | cut -d: -f1)

            if [ -n "$first_import_line" ]; then
                # Inserisci import dopo la prima import
                sed -i.tmp "${first_import_line}a\\
import 'package:gymbro_flutter_new/core/utils/secure_logger.dart';
" "$file"
                echo "   ✅ Import SecureLogger aggiunto"
            fi
        fi

        # Rimuovi file temporanei sed
        rm -f "$file.tmp"

        # Conta modifiche applicate
        new_count=$(grep -c "SecureLogger\.info.*\(email\|uid\|claims\|token\|password\|api\)" "$file" 2>/dev/null || echo "0")
        replacements=$((new_count))

        echo "   ✅ Fix applicato: $replacements sostituzioni"
        TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + replacements))
        FIXED_FILES=$((FIXED_FILES + 1))
    fi

    echo ""
done

echo "================================"
echo "📊 Riepilogo:"
echo ""
if [ "$DRY_RUN" = true ]; then
    echo "   📋 Dry-run completato"
    echo "   📁 File che saranno modificati: $TOTAL_FILES"
    echo ""
    echo "   ⏭️  Prossimo step:"
    echo "   ./scripts/fix_sensitive_logging.sh --apply"
else
    echo "   ✅ Fix applicati!"
    echo "   📁 File modificati: $FIXED_FILES/$TOTAL_FILES"
    echo "   🔄 Sostituzioni totali: $TOTAL_REPLACEMENTS"
    echo ""
    echo "   📁 Backup salvati come: *.backup"
    echo ""
    echo "   ⏭️  Prossimi step:"
    echo "   1. Verifica modifiche: git diff lib/"
    echo "   2. Testa l'app: flutter run"
    echo "   3. Se OK: git add . && git commit -m \"fix: remove sensitive data from debug logs\""
    echo "   4. Se KO: ripristina backup"
fi
echo ""
