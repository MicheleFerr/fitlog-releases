#!/bin/bash

# 🚀 Setup Sistema di Manutenzione Automatica

echo "🤖 Setup Sistema di Manutenzione Automatica GymBro"
echo "=================================================="

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Rendi eseguibili gli script
echo -e "${YELLOW}📝 Configurando permessi script...${NC}"
chmod +x .claude/agents/scripts/*.sh
chmod +x .claude/agents/hooks/pre-commit
chmod +x .claude/agents/auto_watcher.js

# 2. Installa git hooks
echo -e "${YELLOW}🔗 Installando git hooks...${NC}"
if [ -f .git/hooks/pre-commit ]; then
    echo "  ⚠️ Pre-commit hook esistente trovato"
    read -p "  Vuoi sostituirlo? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp .claude/agents/hooks/pre-commit .git/hooks/pre-commit
        echo -e "  ${GREEN}✅ Hook installato${NC}"
    fi
else
    cp .claude/agents/hooks/pre-commit .git/hooks/pre-commit
    echo -e "  ${GREEN}✅ Hook installato${NC}"
fi

# 3. Crea directory necessarie
echo -e "${YELLOW}📁 Creando directory...${NC}"
mkdir -p .claude/kb
mkdir -p .claude/marketing
mkdir -p .claude/logs

# 4. Inizializza file KB se non esistono
echo -e "${YELLOW}📚 Inizializzando Knowledge Base...${NC}"
if [ ! -f .claude/kb/PROJECT_KNOWLEDGE.md ]; then
    cat > .claude/kb/PROJECT_KNOWLEDGE.md << 'EOF'
# 📚 GymBro Project Knowledge Base

## 🎯 Overview
Knowledge base automaticamente mantenuta dal sistema di agenti.

## 📝 Updates Log
---
EOF
    echo -e "  ${GREEN}✅ KB inizializzata${NC}"
fi

# 5. Verifica Node.js per file watcher
echo -e "${YELLOW}🔍 Verificando Node.js...${NC}"
if command -v node &> /dev/null; then
    echo -e "  ${GREEN}✅ Node.js trovato: $(node --version)${NC}"
else
    echo "  ⚠️ Node.js non trovato. Installalo per usare auto_watcher.js"
fi

# 6. Crea Makefile shortcuts
echo -e "${YELLOW}⚙️ Aggiornando Makefile...${NC}"
if ! grep -q "auto-watch" Makefile 2>/dev/null; then
    cat >> Makefile << 'EOF'

# 🤖 Auto Maintenance Commands
.PHONY: auto-watch auto-test-sync auto-kb-update auto-marketing

auto-watch: ## Start automatic file watcher
	@echo "🤖 Starting auto watcher..."
	@node .claude/agents/auto_watcher.js

auto-test-sync: ## Sync all tests with current code
	@echo "🧪 Syncing all tests..."
	@find lib -name "*.dart" -exec bash .claude/agents/scripts/test_maintainer.sh {} \;

auto-kb-update: ## Force KB update for all files
	@echo "📚 Updating Knowledge Base..."
	@find lib -name "*.dart" -exec bash .claude/agents/scripts/kb_updater.sh {} \;

auto-marketing: ## Generate marketing materials
	@echo "📱 Generating marketing assets..."
	@bash .claude/agents/scripts/app_descriptor.sh

maintenance-status: ## Show maintenance system status
	@echo "📊 Maintenance Status"
	@echo "Tests: $$(flutter test --no-pub 2>/dev/null && echo '✅' || echo '❌')"
	@echo "KB Updated: $$(find .claude/kb -mtime -1 -type f | wc -l) files today"
	@echo "Git Hooks: $$([ -f .git/hooks/pre-commit ] && echo '✅' || echo '❌')"
EOF
    echo -e "  ${GREEN}✅ Makefile aggiornato${NC}"
fi

# 7. Test iniziale
echo -e "${YELLOW}🧪 Test del sistema...${NC}"
echo "Test content" > test_file.tmp
bash .claude/agents/scripts/kb_updater.sh test_file.tmp 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✅ Sistema funzionante${NC}"
else
    echo "  ⚠️ Possibili problemi con gli script"
fi
rm -f test_file.tmp

# 8. Istruzioni finali
echo ""
echo -e "${GREEN}✅ Setup completato!${NC}"
echo ""
echo "📖 Comandi disponibili:"
echo "  make auto-watch         - Avvia monitoring automatico"
echo "  make auto-test-sync     - Sincronizza tutti i test"
echo "  make auto-kb-update     - Aggiorna tutta la KB"
echo "  make auto-marketing     - Genera materiali marketing"
echo "  make maintenance-status - Mostra stato sistema"
echo ""
echo "🚀 Per iniziare:"
echo "  1. Esegui: make auto-watch"
echo "  2. Modifica qualsiasi file per vedere gli agenti in azione"
echo "  3. I git hook sono già attivi per i commit"
echo ""
echo "💡 Tip: Aggiungi 'feat:' nei commit message per trigger automatico marketing"