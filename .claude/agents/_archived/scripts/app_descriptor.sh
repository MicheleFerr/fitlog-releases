#!/bin/bash

# 📱 App Descriptor Agent
# Genera e mantiene descrizioni marketing dell'app

MARKETING_DIR=".claude/marketing"
APP_DESC="$MARKETING_DIR/APP_DESCRIPTION.md"
FEATURES_LIST="$MARKETING_DIR/FEATURES.md"
CHANGELOG="$MARKETING_DIR/CHANGELOG_PUBLIC.md"

echo "📱 App Descriptor Agent attivato..."

# Crea directory se non esiste
mkdir -p "$MARKETING_DIR"

# Analizza tutte le features
echo "🔍 Analizzando features esistenti..."

claude-code <<EOF
Analizza l'intera codebase di GymBro e genera/aggiorna:

1. File: $APP_DESC
   Crea una descrizione completa dell'app in formato marketing:
   
   # 💪 GymBro TrackLog
   
   ## 🎯 Tagline
   [Tagline accattivante in italiano e inglese]
   
   ## 📱 Descrizione Breve (80 caratteri)
   [Per app store]
   
   ## 📝 Descrizione Completa
   [Descrizione dettagliata per app store - max 4000 caratteri]
   
   ## ✨ Features Principali
   - 🏋️ [Feature 1 con emoji]
   - ⏱️ [Feature 2 con emoji]
   - 📊 [Feature 3 con emoji]
   
   ## 🎯 Target Audience
   [Chi dovrebbe usare l'app]
   
   ## 🆚 Differenziatori
   [Cosa rende unica GymBro]
   
   ## 📸 Screenshot Necessari
   1. [Schermata principale]
   2. [Timer in azione]
   3. [Statistiche]
   
   ## 🔑 Keywords
   [Lista keyword per ASO]

2. File: $FEATURES_LIST
   Lista dettagliata di TUTTE le features con:
   - Nome feature
   - Descrizione user-friendly
   - Beneficio principale
   - Status (✅ Completa, 🚧 In sviluppo, 📋 Pianificata)

3. File: $CHANGELOG
   Changelog in formato user-friendly (non tecnico):
   
   ## Version X.X.X - [Data]
   ### 🎉 Novità
   - [Feature nuove in linguaggio semplice]
   
   ### 💪 Miglioramenti
   - [Miglioramenti comprensibili]
   
   ### 🐛 Bug Fix
   - [Fix spiegati semplicemente]

Usa un tono entusiasta ma professionale.
Enfatizza i benefici per l'utente, non le tecnicalità.
EOF

echo "✅ Descrizioni marketing generate!"

# Genera anche copy per social
echo "📱 Generazione copy social..."

claude-code <<EOF
Genera in $MARKETING_DIR/SOCIAL_COPY.md:

## 🐦 Twitter/X Posts
[5 tweet pronti per annunciare features]

## 📷 Instagram Captions
[3 caption con emoji e hashtag]

## 📝 Blog Post Intro
[Introduzione per articolo sul blog]

## 🎥 Video Script (30 sec)
[Script per video promozionale]
EOF

# Notifica completamento
osascript -e "display notification \"Marketing assets aggiornati!\" with title \"📱 App Descriptor\""

echo "🎉 Marketing assets pronti per il lancio!"