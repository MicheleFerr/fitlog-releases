#!/bin/bash

# 🧪 Test Maintainer Agent
# Mantiene i test sincronizzati con il codice

FILE_CHANGED=$1
TEST_FILE="${FILE_CHANGED/lib/test}"
TEST_FILE="${TEST_FILE/.dart/_test.dart}"

echo "🔧 Test Maintainer attivato per: $FILE_CHANGED"

# Controlla se il file di test esiste
if [ ! -f "$TEST_FILE" ]; then
    echo "📝 Creazione nuovo test file: $TEST_FILE"
    
    # Usa Claude per generare il test
    claude-code <<EOF
Analizza il file $FILE_CHANGED e genera un test completo in $TEST_FILE.
Segui questi pattern:
- Usa i mock esistenti nel progetto
- Testa tutti i metodi pubblici
- Includi test per edge cases
- Usa emoji nei gruppi di test
EOF
else
    echo "🔄 Aggiornamento test esistente: $TEST_FILE"
    
    # Analizza differenze e aggiorna
    claude-code <<EOF
Confronta $FILE_CHANGED con $TEST_FILE.
Aggiorna il test per:
- Nuovi metodi aggiunti
- Metodi modificati
- Rimuovi test per metodi eliminati
Mantieni i test esistenti che ancora funzionano.
EOF
fi

# Esegui i test per verificare
echo "🧪 Esecuzione test..."
flutter test $TEST_FILE

if [ $? -eq 0 ]; then
    echo "✅ Test aggiornati con successo!"
    
    # Aggiorna KB
    echo "📚 Aggiornamento Knowledge Base..."
    echo "$(date): Test aggiornati per $FILE_CHANGED" >> .claude/kb/test_updates.log
else
    echo "❌ Test falliti! Review manuale richiesta."
    
    # Notifica sviluppatore
    osascript -e "display notification \"Test falliti per $FILE_CHANGED\" with title \"🔧 Test Maintainer\""
fi