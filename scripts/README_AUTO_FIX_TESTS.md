# 🚀 Auto-Fix Tests - Guida Autonoma

## 📋 Panoramica

Questi script ti permettono di raggiungere **70% test coverage** in modo **completamente autonomo**, senza dover stare al PC a confermare ogni azione!

## 🎯 Quick Start - Lancio e Vai!

```bash
# OPZIONE 1: Processo completo automatico (RACCOMANDATO)
./scripts/auto_fix_tests_to_70_percent.sh

# Vai via dal PC ☕ - Lo script lavora da solo per 1-2 ore
# Torna e verifica i risultati in logs/auto_fix_*.log
```

## 🛠️ Script Disponibili

### 1. `auto_fix_tests_to_70_percent.sh` (MASTER SCRIPT)
**Cosa fa**: Orchestra l'intero processo di fix automatico
**Durata**: 1-2 ore
**Input richiesto**: NESSUNO (100% autonomo)

**Fasi**:
- ✅ Analizza coverage attuale (15.08%)
- ✅ Fixa CSV tests automaticamente
- ✅ Identifica null safety issues
- ✅ Re-run tests e calcola nuovo coverage
- ✅ Report finale con delta

**Come usare**:
```bash
./scripts/auto_fix_tests_to_70_percent.sh

# Output salvato in: logs/auto_fix_YYYYMMDD_HHMMSS.log
```

---

### 2. `analyze_failing_tests.sh`
**Cosa fa**: Analizza e categorizza i 153 test falliti
**Durata**: 5-10 minuti
**Output**: Report con categorie di errori

**Come usare**:
```bash
./scripts/analyze_failing_tests.sh

# Output:
# ❌ Null Safety Errors: 45
# ❌ Late Init Errors: 12
# ❌ Mock/Stub Errors: 38
# ❌ CSV Parsing Errors: 15
# ... etc
```

---

### 3. `fix_csv_tests.sh`
**Cosa fa**: Fixa automaticamente i 15 CSV test falliti
**Durata**: 1-2 minuti
**Input richiesto**: NESSUNO

**Come usare**:
```bash
./scripts/fix_csv_tests.sh

# Applica .trim() a tutti i csvContent
# Verifica fix con test run
```

---

## 📊 Workflow Completo per 70% Coverage

### STEP 1: Quick Wins (15% → 25%)
**Tempo**: 2-3 ore | **Autonomous**: ✅ SÌ

```bash
# Lancia master script
./scripts/auto_fix_tests_to_70_percent.sh

# Lo script:
# 1. Fixa CSV tests (+15 tests passing)
# 2. Identifica null safety issues
# 3. Calcola nuovo coverage
```

**Risultato atteso**: ~25% coverage

---

### STEP 2: Provider Completion (25% → 35%)
**Tempo**: 3-4 ore | **Autonomous**: ⚠️ Richiede coding

**Azione manuale richiesta**:
```bash
# Completa 2 provider skippati:
# 1. test/features/workout/presentation/providers/add_exercise_provider_test.dart
# 2. test/features/exercise_database/presentation/providers/exercise_gif_provider_test.dart

# Usa come template i provider già testati
# Target: 30-40 tests per provider
```

**Risultato atteso**: ~35% coverage

---

### STEP 3: Repository Tests (35% → 50%)
**Tempo**: 5-6 ore | **Autonomous**: ⚠️ Richiede coding

**Strategia**:
```bash
# Identifica repositories senza test:
find lib/features/*/data/repositories -name "*_repository.dart"

# Per ogni repository, crea test con pattern:
# - CRUD operations
# - Error handling
# - Caching logic
# - Target: 20-30 tests per repository
```

**Risultato atteso**: ~50% coverage

---

### STEP 4: Widget Tests (50% → 65%)
**Tempo**: 6-8 ore | **Autonomous**: ⚠️ Richiede coding

**Strategia**:
```bash
# Aggiungi widget tests per screen principali:
# - workout_session_screen.dart
# - exercise_database_screen.dart
# - home_dashboard_screen.dart
# - user_profile_screen.dart

# Pattern: pump widget, find, tap, expect
# Target: 15-20 tests per screen
```

**Risultato atteso**: ~65% coverage

---

### STEP 5: Integration Tests (65% → 70%+)
**Tempo**: 4-5 ore | **Autonomous**: ⚠️ Richiede coding

**Strategia**:
```bash
# Aggiungi integration tests per flussi critici:
# - Complete workout flow
# - Exercise add flow
# - Template creation flow

# Target: 10-15 integration tests
```

**Risultato atteso**: ~70%+ coverage ✅

---

## 🎯 Timeline Realistico

| Fase | Coverage Target | Tempo | Autonomous |
|------|----------------|-------|------------|
| **Base attuale** | 15.08% | ✅ Done | - |
| **STEP 1: Quick Wins** | 25% | 2-3 ore | ✅ SÌ |
| **STEP 2: Providers** | 35% | 3-4 ore | ⚠️ No |
| **STEP 3: Repositories** | 50% | 5-6 ore | ⚠️ No |
| **STEP 4: Widgets** | 65% | 6-8 ore | ⚠️ No |
| **STEP 5: Integration** | 70%+ | 4-5 ore | ⚠️ No |
| **TOTALE** | **70%+** | **~25-30 ore** | Mixed |

---

## 💡 Best Practices

### Per Esecuzione Autonoma:
1. ✅ Sempre lancia script dal root del progetto
2. ✅ Verifica che Flutter sia installato: `flutter --version`
3. ✅ Assicurati di avere spazio su disco (logs possono essere grandi)
4. ✅ Usa `nohup` se vuoi chiudere il terminale:
   ```bash
   nohup ./scripts/auto_fix_tests_to_70_percent.sh &
   tail -f nohup.out
   ```

### Per Debug:
1. ✅ Controlla i log in `logs/auto_fix_*.log`
2. ✅ Se uno script fallisce, ri-eseguilo con debug:
   ```bash
   bash -x ./scripts/fix_csv_tests.sh
   ```

---

## 📞 Support

Se uno script fallisce o hai domande:
1. Controlla il log file in `logs/`
2. Verifica che tutti i prerequisiti siano installati
3. Esegui manualmente le singole fasi per isolare il problema

---

## 🎉 Successo!

Quando raggiungi 70% coverage:
```bash
flutter test --coverage
# Verifica finale con:
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Congratulazioni! 🎉** Hai raggiunto production-ready test coverage!
