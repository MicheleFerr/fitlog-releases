#!/bin/bash

# 📚 Knowledge Base Updater Agent
# Aggiorna automaticamente la KB con pattern e soluzioni

FILE_CHANGED=$1
KB_DIR=".claude/kb"
MAIN_KB="$KB_DIR/PROJECT_KNOWLEDGE.md"

echo "📚 KB Updater attivato per: $FILE_CHANGED"

# Estrai informazioni dal commit
COMMIT_MSG=$(git log -1 --pretty=%B 2>/dev/null || echo "Working changes")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Determina categoria
case "$FILE_CHANGED" in
    *timer*)
        KB_FILE="$KB_DIR/TIMER_AUDIO_KB.md"
        CATEGORY="Timer System"
        ;;
    *workout*)
        KB_FILE="$KB_DIR/WORKOUT_KB.md"
        CATEGORY="Workout System"
        ;;
    *auth*)
        KB_FILE="$KB_DIR/AUTH_KB.md"
        CATEGORY="Authentication"
        ;;
    *)
        KB_FILE="$MAIN_KB"
        CATEGORY="General"
        ;;
esac

# Usa Claude per analizzare e documentare
claude-code <<EOF
Analizza le modifiche in $FILE_CHANGED e aggiorna $KB_FILE.

Aggiungi una sezione con:
## 📝 Update: $TIMESTAMP

### File Modificato
- Path: $FILE_CHANGED
- Categoria: $CATEGORY
- Commit: $COMMIT_MSG

### Pattern Identificati
[Identifica pattern di codice riutilizzabili]

### Soluzioni Implementate
[Documenta soluzioni a problemi risolti]

### Best Practices
[Estrai best practices dal codice]

### Dipendenze Aggiornate
[Lista eventuali nuove dipendenze]

### Note per il Team
[Aggiungi note importanti per altri sviluppatori]

---

Non sovrascrivere contenuto esistente, solo aggiungere.
EOF

echo "✅ Knowledge Base aggiornata!"

# Genera summary per marketing
if [[ "$COMMIT_MSG" == *"feat:"* ]]; then
    echo "🎯 Nuova feature detectata! Aggiornamento marketing..."
    
    claude-code <<EOF
Aggiungi a .claude/marketing/FEATURES.md:

### 🆕 $TIMESTAMP
- Feature: ${COMMIT_MSG#feat: }
- Benefici per l'utente: [Descrivi in modo user-friendly]
- Screenshot necessari: [Lista screenshot da creare]
EOF
fi