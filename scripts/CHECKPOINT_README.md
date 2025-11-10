# 🎯 Auto-Checkpoint System

Sistema intelligente per auto-committare modifiche significative e triggerare i check del pre-commit hook.

## 🚀 Quick Start

### Modalità Manuale (commit immediato)

```bash
# Commit immediato se ci sono modifiche significative
./scripts/checkpoint.sh
```

### Modalità Watch (auto-commit in background)

```bash
# Monitora continuamente e committa automaticamente
./scripts/checkpoint.sh --watch
```

**Output esempio**:
```
👁️  Watch mode enabled
   Threshold: 50 lines OR 3 files
   Interval: 30s
   Monitoring: lib/**/*.dart

Press Ctrl+C to stop

📊 Changes detected: 2 files, ~15 lines
📊 Changes detected: 4 files, ~75 lines
⚡ Threshold met: 75 lines (>= 50)
🎯 Significant changes detected! Creating checkpoint...

📝 Files to commit (4):
lib/features/workout/workout_screen.dart
lib/features/timer/timer_provider.dart
lib/features/home/home_screen.dart
lib/shared/utils/date_utils.dart

💾 Creating checkpoint commit...

🎨 Running Design System Checks...
[1/8] Checking icon design system...
✅ Icon design system checks passed
...
[8/8] Checking CLAUDE.md auto-staging...
✅ CLAUDE.md added to commit

✅ Checkpoint created successfully!
   Pre-commit hooks executed
   4 files committed
   Commit: a1b2c3d

👁️  Resuming watch mode...
```

## ⚙️ Configurazione

### Soglie di Commit

**Default**:
- ✅ **50+ righe modificate** in totale
- ✅ **OPPURE 3+ file .dart modificati**

### Custom Thresholds

```bash
# Commit solo con modifiche >= 100 righe
./scripts/checkpoint.sh --threshold 100

# Watch mode con soglia custom
./scripts/checkpoint.sh --watch --threshold 80

# Intervallo check personalizzato (default 30s)
./scripts/checkpoint.sh --watch --interval 60
```

## 📋 Workflow Consigliato

### Opzione 1: Watch in Background (Consigliato)

**Ideale per**: Sessioni di sviluppo lunghe, lavoro su feature complesse

```bash
# Terminal 1 - Watch mode
./scripts/checkpoint.sh --watch

# Terminal 2 - Sviluppo
code lib/features/workout/
# Modifichi, salvi, continui...
# Commit automatici quando superi le soglie
```

### Opzione 2: Manual Checkpoints

**Ideale per**: Checkpoint manuali dopo completamento logico

```bash
# Implementi una feature
vim lib/features/workout/workout_screen.dart

# Checkpoint manuale
./scripts/checkpoint.sh

# Output:
# ✅ Checkpoint created successfully!
```

### Opzione 3: Git Alias (Super Quick)

Aggiungi al `.gitconfig` locale:

```bash
git config --local alias.checkpoint '!./scripts/checkpoint.sh'
git config --local alias.watch '!./scripts/checkpoint.sh --watch'
```

Poi usa:
```bash
git checkpoint       # Commit immediato
git watch           # Watch mode
```

## 🛡️ Check Pre-Commit Automatici

Ogni checkpoint triggera **TUTTI** i check del pre-commit hook:

1. ✅ **Icon design system** - Blocca `Icons.*` inline
2. ✅ **Flutter analyze** - Blocca errori compilazione
3. ✅ **Design violations** - Warn colori/testi hardcoded
4. ✅ **Localizations** - Rigenera `.arb` se necessario
5. ✅ **iOS build compliance** - Blocca `const` + `context.l10n`
6. ✅ **Template card compliance**
7. ✅ **Memory management** - Warn memory leaks
8. ✅ **CLAUDE.md auto-staging** - Auto-aggiunge se modificato

**Se un check BLOCCA** → Commit fallisce con dettagli errore

## 📊 Commit Message Format

Checkpoint commits usano questo formato:

```
chore: checkpoint - 4 files modified

Auto-checkpoint at 2025-11-10 02:45:30

Modified files:
- lib/features/workout/workout_screen.dart
- lib/features/timer/timer_provider.dart
- lib/features/home/home_screen.dart
- lib/shared/utils/date_utils.dart

🤖 Auto-generated checkpoint commit
Triggered by: checkpoint.sh
Threshold: 50 lines OR 3 files
```

## 🎯 Quando Usare

### ✅ USA Checkpoint per:

- **Sessioni di sviluppo lunghe** - Watch mode previene perdita di lavoro
- **Refactoring massicci** - Checkpoint frequenti = rollback facile
- **Feature multi-file** - Verifica incrementale con pre-commit checks
- **Debug di build errors** - Feedback immediato da `flutter analyze`
- **Testing phase** - Commit frequenti = cronologia dettagliata

### ❌ NON Usare per:

- **Commit finali** - Usa commit manuali con messaggi descrittivi
- **Feature complete** - Squasha checkpoint commits prima di push
- **Pull request** - Ripulisci cronologia prima di creare PR

## 🔧 Cleanup Checkpoint Commits

Dopo una sessione di checkpoint, puoi squashare i commit:

```bash
# Vedi ultimi 10 commit
git log --oneline -10

# Squash ultimi 5 checkpoint commits
git rebase -i HEAD~5

# Nel editor, cambia "pick" in "squash" per i checkpoint
# Salva, poi scrivi messaggio commit finale
```

## 🚨 Troubleshooting

### Script non eseguibile
```bash
chmod +x scripts/checkpoint.sh
```

### Watch mode consuma troppo CPU
```bash
# Aumenta intervallo check (default 30s)
./scripts/checkpoint.sh --watch --interval 60
```

### Soglie troppo aggressive
```bash
# Aumenta threshold (default 50 righe)
./scripts/checkpoint.sh --watch --threshold 100
```

### Pre-commit hook blocca sempre
```bash
# Identifica problema
flutter analyze

# Fix errori, poi riprova
./scripts/checkpoint.sh
```

## 📚 Best Practices

1. **Watch mode in background** durante sviluppo attivo
2. **Squash checkpoint commits** prima di push
3. **Usa soglie sensate** (50 righe è bilanciato)
4. **Stoppa watch** quando finisci sessione
5. **Review commit** prima di push con `git log --oneline`

## ⚡ Performance

- **CPU**: ~0% (sleep 30s tra check)
- **RAM**: ~5MB
- **Disk**: Nessun file temporaneo
- **Network**: Nessuna connessione richiesta

## 🔗 Integrazione CI/CD

Checkpoint commits NON devono andare in CI/CD:

```yaml
# .github/workflows/ci.yml
on:
  push:
    branches:
      - main
      - develop
    # Ignora checkpoint commits
    paths-ignore:
      - '**/*checkpoint*'
```

O squasha prima di push a branch remoti.

## 📝 Changelog

- **v1.0** (2025-11-10): Initial release
  - Manual mode
  - Watch mode
  - Custom thresholds
  - Pre-commit hook integration
  - CLAUDE.md auto-staging

---

**Creato per**: GymBro TrackLog Flutter App
**Autore**: Auto-Checkpoint System
**Licenza**: MIT
