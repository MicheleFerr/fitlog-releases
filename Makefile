# GymBro TrackLog - Makefile per sviluppo

.PHONY: help clean gen-l10n analyze check-strings fix-strings test build

help: ## Mostra questo messaggio di aiuto
	@echo "GymBro TrackLog - Comandi disponibili:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## Pulisce build e cache
	@echo "🧹 Pulizia progetto..."
	flutter clean
	flutter pub get

gen-l10n: ## Rigenera i file di localizzazione
	@echo "📝 Rigenerazione file localizzazione..."
	flutter gen-l10n

analyze: ## Esegue flutter analyze
	@echo "🔍 Analisi codice..."
	flutter analyze --no-fatal-infos

check-strings: ## Cerca testi hardcoded nel progetto
	@echo "🔍 Ricerca testi hardcoded..."
	@./scripts/find_hardcoded_strings.sh

fix-strings: ## Esegue fix automatici per testi hardcoded (da implementare)
	@echo "🔧 Fix automatico testi hardcoded..."
	@echo "💡 Usa l'IDE per sostituire manualmente i testi trovati"

test: ## Esegue i test
	@echo "🧪 Esecuzione test..."
	flutter test

build-ios: ## Build per iOS
	@echo "📱 Build iOS..."
	flutter build ios --release

build-android: ## Build per Android
	@echo "🤖 Build Android..."
	flutter build apk --release

dev-setup: clean gen-l10n analyze ## Setup completo ambiente sviluppo
	@echo "✅ Setup sviluppo completato!"

pre-commit: check-strings analyze ## Controlli pre-commit
	@echo "✅ Controlli pre-commit completati!"

install-hooks: ## Installa git hooks
	@echo "🪝 Installazione git hooks..."
	@cp scripts/pre-commit-check.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Git hooks installati!"

localization-status: ## Mostra stato localizzazione
	@echo "🌍 Stato Localizzazione:"
	@echo "========================"
	@echo "📊 Numero di chiavi EN:"
	@grep -c '"[^@].*":' assets/i18n/app_en.arb
	@echo "📊 Numero di chiavi IT:"
	@grep -c '"[^@].*":' assets/i18n/app_it.arb
	@echo ""
	@echo "🔍 Possibili testi hardcoded:"
	@find lib -name "*.dart" -not -path "*/generated/*" | xargs grep -c "Text(['\"][A-Za-z\s]{3,}['\"])" | grep -v ":0" | wc -l || echo "0"

# ===== PATROL TESTING COMMANDS =====

patrol-setup: ## Setup Patrol testing framework
	@echo "🧪 Installing Patrol CLI..."
	dart pub global activate patrol_cli
	@echo "✅ Patrol CLI installed!"
	@echo ""
	@echo "📝 Add to PATH with:"
	@echo 'export PATH="$$PATH":"$$HOME/.pub-cache/bin"'

patrol-doctor: ## Check Patrol setup
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol doctor

patrol-test: ## Run all Patrol integration tests
	@echo "🧪 Running all Patrol tests..."
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test

patrol-live: ## Run Live Activity tests (iOS)
	@echo "📱 Running Live Activity tests..."
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test --target integration_test/tests/live_activity_test.dart

patrol-bg: ## Run Background Timer tests
	@echo "⏱️ Running Background Timer tests..."
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test --target integration_test/tests/background_timer_test.dart

patrol-perm: ## Run Permission tests
	@echo "🔐 Running Permission tests..."
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test --target integration_test/tests/permission_test.dart

patrol-e2e: ## Run E2E Workflow tests
	@echo "🏋️ Running E2E Workflow tests..."
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test --target integration_test/tests/workout_flow_e2e_test.dart

patrol-ios: ## Run Patrol tests on iOS simulator
	@echo "📱 Running Patrol tests on iOS Simulator..."
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test --device "iPhone 15 Pro"

patrol-ios-device: ## Run Patrol tests on physical iOS device (release mode)
	@echo "📱 Running Patrol tests on Physical iOS Device..."
	@echo "⚠️  Note: Using release mode for physical device"
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test --release

patrol-android: ## Run Patrol tests on Android emulator
	@echo "🤖 Running Patrol tests on Android..."
	@export PATH="$$PATH":"$$HOME/.pub-cache/bin" && \
	patrol test --device "Pixel 7"

# ===== BUG CHECKING COMMANDS =====

check-bugs: ## Analisi completa di tutti i bug del progetto
	@echo "🐛 Esecuzione analisi completa bug..."
	@./scripts/check_bugs.sh

quick-check: ## Controllo veloce dei bug principali
	@echo "🚀 Controllo rapido bug..."
	@./scripts/quick_bug_check.sh

fix-critical: ## Tenta di fixare automaticamente i bug critici
	@echo "🔧 Fix automatico bug critici..."
	@echo "1. Rigenerazione localizzazioni..."
	@flutter gen-l10n
	@echo "2. Pulizia e reinstallazione dipendenze..."
	@flutter clean
	@flutter pub get
	@echo "3. Fix iOS pods..."
	@cd ios && pod install --repo-update
	@echo "4. Analisi finale..."
	@flutter analyze --no-fatal-infos || true
	@echo "✅ Fix automatici completati. Esegui 'make check-bugs' per verificare."