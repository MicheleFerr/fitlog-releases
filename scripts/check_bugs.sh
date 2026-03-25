#!/bin/bash

# 🐛 GymBro Bug Checker Script
# Esegue un'analisi completa del progetto per identificare tutti i bug
# Usage: ./scripts/check_bugs.sh

set -e

# Colori per output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Contatori
CRITICAL_COUNT=0
WARNING_COUNT=0
INFO_COUNT=0
FLUTTER_AVAILABLE=1

if ! command -v flutter >/dev/null 2>&1; then
    FLUTTER_AVAILABLE=0
fi

echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}${BOLD}       🐛 GymBro TrackLog - Bug Detection Report 🐛${NC}"
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Funzione per stampare sezioni
print_section() {
    echo -e "\n${BOLD}═══ $1 ═══${NC}\n"
}

# Funzione per stampare errori
print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((CRITICAL_COUNT++))
}

# Funzione per stampare warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNING_COUNT++))
}

# Funzione per stampare info
print_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
    ((INFO_COUNT++))
}

# 1. FLUTTER ANALYZE
print_section "1. ANALISI STATICA FLUTTER"
echo "Esecuzione flutter analyze..."
if [ "$FLUTTER_AVAILABLE" -eq 0 ]; then
    print_error "flutter non trovato nel PATH: analisi statica non eseguita"
else
    ANALYZE_OUTPUT=$(flutter analyze 2>&1 || true)
    ANALYZE_ERRORS=$(echo "$ANALYZE_OUTPUT" | grep -c "error •" || true)
    ANALYZE_WARNINGS=$(echo "$ANALYZE_OUTPUT" | grep -c "warning •" || true)
    ANALYZE_INFO=$(echo "$ANALYZE_OUTPUT" | grep -c "info •" || true)

    if [ "$ANALYZE_ERRORS" -gt 0 ]; then
        print_error "Trovati $ANALYZE_ERRORS errori di compilazione"
        echo "$ANALYZE_OUTPUT" | grep "error •" | head -10
        echo "   ... (mostrando primi 10 errori)"
    fi

    if [ "$ANALYZE_WARNINGS" -gt 0 ]; then
        print_warning "Trovati $ANALYZE_WARNINGS warnings"
    fi

    if [ "$ANALYZE_INFO" -gt 0 ]; then
        print_info "Trovate $ANALYZE_INFO info/suggestions"
    fi
fi

# 2. TODO/FIXME/BUG COMMENTS
print_section "2. COMMENTI TODO/FIXME/BUG NEL CODICE"
echo "Ricerca commenti problematici..."

TODO_COUNT=$(grep -r "TODO\|FIXME\|BUG\|HACK\|XXX" --include="*.dart" --include="*.swift" lib/ ios/Runner/ 2>/dev/null | wc -l || echo "0")
if [ "$TODO_COUNT" -gt 0 ]; then
    print_warning "Trovati $TODO_COUNT commenti TODO/FIXME/BUG"
    echo "Primi 5:"
    grep -r "TODO\|FIXME\|BUG\|HACK\|XXX" --include="*.dart" --include="*.swift" lib/ ios/Runner/ 2>/dev/null | head -5 || true
fi

# 3. HARDCODED STRINGS
print_section "3. STRINGHE HARDCODED (Localizzazione)"
echo "Ricerca testi non localizzati..."

HARDCODED=$(grep -r "Text(['\"]" --include="*.dart" lib/ 2>/dev/null | grep -v "AppLocalizations" | wc -l || echo "0")
if [ "$HARDCODED" -gt 0 ]; then
    print_warning "Trovate $HARDCODED stringhe hardcoded potenziali"
    echo "Esempi:"
    grep -r "Text(['\"]" --include="*.dart" lib/ 2>/dev/null | grep -v "AppLocalizations" | head -3 || true
fi

# 4. TIMER/AUDIO ISSUES CONOSCIUTI
print_section "4. PROBLEMI TIMER/AUDIO DOCUMENTATI"

if [ -f "docs/TIMER_AUDIO_KB.md" ]; then
    print_info "Knowledge Base Timer/Audio trovata"
    
    # Controlla categoria notifiche
    CATEGORY_MISMATCH=$(grep -l "TIMER_COMPLETE_BACKGROUND\|TIMER_COMPLETE_FOREGROUND" lib/**/*.dart 2>/dev/null | wc -l || echo "0")
    if [ "$CATEGORY_MISMATCH" -gt 0 ]; then
        print_error "CRITICO: Mismatch categoria notifiche iOS (causa audio silenzioso)"
    fi
    
    # Controlla silent loop (App Store rejection risk)
    SILENT_LOOP=$(grep -l "startSilentLoop\|SilentAudioLoopManager" ios/Runner/**/*.swift 2>/dev/null | wc -l || echo "0")
    if [ "$SILENT_LOOP" -gt 0 ]; then
        print_warning "Silent Audio Loop presente (30-40% rejection risk App Store)"
    fi
fi

# 5. DEPRECATED APIS
print_section "5. API DEPRECATE"
echo "Ricerca API deprecate..."

DEPRECATED=$(grep -r "@deprecated\|deprecated\|withOpacity" --include="*.dart" lib/ 2>/dev/null | wc -l || echo "0")
if [ "$DEPRECATED" -gt 0 ]; then
    print_warning "Trovate $DEPRECATED API potenzialmente deprecate"
fi

# 6. MISSING AWAITS
print_section "6. AWAIT MANCANTI"
echo "Ricerca Future non awaited..."

MISSING_AWAIT=$(grep -r "^\s*[^/]*\.\(then\|catchError\)(" --include="*.dart" lib/ 2>/dev/null | wc -l || echo "0")
if [ "$MISSING_AWAIT" -gt 0 ]; then
    print_warning "Possibili $MISSING_AWAIT Future senza await"
fi

# 7. MEMORY LEAKS
print_section "7. POTENZIALI MEMORY LEAKS"
echo "Ricerca timer/stream non disposed..."

TIMER_NO_CANCEL=$(grep -r "Timer\|Timer\.periodic" --include="*.dart" lib/ 2>/dev/null | wc -l || echo "0")
DISPOSE_COUNT=$(grep -r "\.cancel()\|\.dispose()" --include="*.dart" lib/ 2>/dev/null | wc -l || echo "0")

if [ "$TIMER_NO_CANCEL" -gt "$DISPOSE_COUNT" ]; then
    print_warning "Possibili timer/stream non cancellati (Timer: $TIMER_NO_CANCEL, Dispose: $DISPOSE_COUNT)"
fi

# 8. PRINT STATEMENTS IN PRODUCTION
print_section "8. PRINT IN PRODUCTION"
echo "Ricerca print() statements..."

PRINTS=$(grep -r "print(" --include="*.dart" lib/ 2>/dev/null | wc -l || echo "0")
if [ "$PRINTS" -gt 0 ]; then
    print_warning "Trovati $PRINTS print() statements (usare debugPrint)"
fi

# 9. TEST COVERAGE
print_section "9. TEST COVERAGE"
echo "Verifica presenza test..."

TEST_FILES=$(find test/ integration_test/ -name "*_test.dart" 2>/dev/null | wc -l || echo "0")
if [ "$TEST_FILES" -lt 10 ]; then
    print_warning "Solo $TEST_FILES file di test trovati"
fi

# 10. PATROL TEST ISSUES
print_section "10. PATROL TEST FRAMEWORK"

PATROL_ERRORS=$(grep -r "PatrolTestConfig\|undefined_method\|undefined_identifier" integration_test/ 2>/dev/null | wc -l || echo "0")
if [ "$PATROL_ERRORS" -gt 0 ]; then
    print_error "Patrol test framework non configurato correttamente ($PATROL_ERRORS errori)"
fi

# 11. IOS SPECIFIC ISSUES
print_section "11. PROBLEMI SPECIFICI iOS"

if [ -d "ios/" ]; then
    # Controlla Live Activities
    LIVE_ACTIVITY=$(grep -r "ActivityKit\|startActivity\|updateActivity" ios/Runner/ 2>/dev/null | wc -l || echo "0")
    if [ "$LIVE_ACTIVITY" -gt 0 ]; then
        print_info "Live Activities implementate (richiede iOS 16.1+)"
    fi
    
    # Controlla background modes
    BG_AUDIO=$(grep -l "audio.*background\|background.*audio" ios/Runner/Info.plist 2>/dev/null | wc -l || echo "0")
    if [ "$BG_AUDIO" -eq 0 ]; then
        print_warning "Background audio capability potrebbe non essere configurata"
    fi
fi

# 12. DEPENDENCIES CHECK
print_section "12. CONTROLLO DIPENDENZE"

if [ -f "pubspec.lock" ]; then
    # Controlla dipendenze outdated
    echo "Verifica dipendenze outdated..."
    if [ "$FLUTTER_AVAILABLE" -eq 0 ]; then
        print_warning "flutter non trovato: controllo dipendenze outdated saltato"
    else
        OUTDATED=$(flutter pub outdated 2>/dev/null | grep -c "^[!]" || echo "0")
        if [ "$OUTDATED" -gt 0 ]; then
            print_warning "$OUTDATED dipendenze hanno major version updates disponibili"
        fi
    fi
fi

# 13. FIREBASE CONFIGURATION
print_section "13. CONFIGURAZIONE FIREBASE"

if [ -f "lib/firebase_options.dart" ]; then
    print_info "Firebase configurato"
    
    # Controlla se ci sono API keys hardcoded
    API_KEYS=$(grep -c "apiKey\|appId" lib/firebase_options.dart 2>/dev/null || echo "0")
    if [ "$API_KEYS" -gt 0 ]; then
        print_info "Firebase options presente (verificare sicurezza keys)"
    fi
fi

# 14. PERFORMANCE ISSUES
print_section "14. PROBLEMI PERFORMANCE"

# Controlla uso di setState eccessivo
SETSTATE=$(grep -r "setState(" --include="*.dart" lib/ 2>/dev/null | wc -l || echo "0")
if [ "$SETSTATE" -gt 50 ]; then
    print_warning "Uso eccessivo di setState ($SETSTATE occorrenze) - considerare state management"
fi

# Controlla widget rebuild
NO_CONST=$(grep -r "^\s*return.*Widget" --include="*.dart" lib/ 2>/dev/null | grep -v "const" | wc -l || echo "0")
if [ "$NO_CONST" -gt 100 ]; then
    print_warning "Molti widget senza const ($NO_CONST) - possibili rebuild non necessari"
fi

# SUMMARY
echo ""
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}                        📊 RIEPILOGO${NC}"
echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${RED}${BOLD}🔴 Errori Critici:${NC} $CRITICAL_COUNT"
echo -e "${YELLOW}${BOLD}🟡 Warnings:${NC} $WARNING_COUNT"
echo -e "${GREEN}${BOLD}🟢 Info:${NC} $INFO_COUNT"
echo ""

TOTAL_ISSUES=$((CRITICAL_COUNT + WARNING_COUNT))

if [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo -e "${RED}${BOLD}⚠️  ATTENZIONE: Ci sono $CRITICAL_COUNT problemi critici che richiedono fix immediato!${NC}"
elif [ "$WARNING_COUNT" -gt 10 ]; then
    echo -e "${YELLOW}${BOLD}⚠️  Ci sono diversi warnings da risolvere per migliorare la qualità del codice.${NC}"
else
    echo -e "${GREEN}${BOLD}✅ Il progetto è in buono stato con solo problemi minori.${NC}"
fi

echo ""
echo -e "${BLUE}Report generato: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo ""

# Genera report dettagliato in file
REPORT_FILE="bug_report_$(date '+%Y%m%d_%H%M%S').txt"
echo "Generazione report dettagliato in $REPORT_FILE..."

{
    echo "GymBro Bug Detection Report - $(date)"
    echo "========================================"
    echo ""
    echo "SUMMARY:"
    echo "- Critical Errors: $CRITICAL_COUNT"
    echo "- Warnings: $WARNING_COUNT"
    echo "- Info: $INFO_COUNT"
    echo "- Flutter Analyze Errors: $ANALYZE_ERRORS"
    echo "- Flutter Analyze Warnings: $ANALYZE_WARNINGS"
    echo ""
    echo "DETAILED FLUTTER ANALYZE OUTPUT:"
    echo "$ANALYZE_OUTPUT"
} > "$REPORT_FILE"

echo -e "${GREEN}Report salvato in: $REPORT_FILE${NC}"

exit $CRITICAL_COUNT
