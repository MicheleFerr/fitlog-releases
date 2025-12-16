# FitLog Copilot - Design Document

**Data**: 2024-12-16
**Stato**: Approvato
**Obiettivo**: Migliorare l'esperienza di coding con Claude Code per FitLog

---

## Problema

L'esperienza attuale presenta quattro pain points principali:

1. **Context switching** - Perdita di contesto tra sessioni
2. **File zombie** - File duplicati/orfani che confondono Claude
3. **Violazioni regole** - Claude ignora le convenzioni del progetto (AppIcons, l10n, colors)
4. **Discoverability** - Difficoltà a ricordare quale agente/comando usare

---

## Soluzione: FitLog Copilot

Sistema integrato in 4 parti che si attiva automaticamente.

---

## Parte 1: Auto-Context Loader

### Obiettivo
Caricare automaticamente il contesto a inizio sessione.

### Output atteso
```
🚀 FitLog Copilot attivato

📍 Stato progetto:
   Branch: feat/custom-exercises
   Ultimo commit: "feat: implement custom exercise categorization" (2h fa)
   File modificati non committati: 3

🧠 Contesto recente (da episodic memory):
   - Sessione precedente: lavoro su categorizzazione esercizi custom
   - Decisione presa: usare enum ExerciseCategory invece di stringhe
   - TODO lasciato: aggiungere validazione input

⚠️ Reminder attivi:
   - PR #42 in attesa di review
   - Test fallito: exercise_repository_test.dart
```

### Implementazione
- Hook `session-start` che esegue script di raccolta info
- Query automatica a `episodic-memory:search` basata su branch/file recenti
- Lettura di `.fitlog-context.md` se presente (salvato da sessione precedente)

### File da creare
- `.claude/hooks/session-start.sh`
- `.claude/scripts/gather-context.sh`

---

## Parte 2: Codebase Health Monitor

### Obiettivo
Rilevare file zombie (duplicati, orfani, stale) che confondono Claude.

### Output atteso
```
🏥 Codebase Health Check

✅ Nessun file duplicato rilevato
⚠️  3 file potenzialmente orfani (non importati):
   - lib/features/timer/old_timer_widget.dart
   - lib/shared/utils/deprecated_helpers.dart
   - lib/features/workout/temp_fix.dart

⚠️  1 possibile conflitto di naming:
   - exercise_service.dart (lib/features/exercise/)
   - exercise_service.dart (lib/shared/services/)

💡 Usa /cleanup per analisi dettagliata
```

### Implementazione
```bash
#!/bin/bash
# .claude/scripts/health-check.sh

# 1. Trova file .dart non importati (orfani)
find lib -name "*.dart" -exec basename {} \; | while read f; do
  name="${f%.dart}"
  if ! grep -rq "import.*$name" lib --include="*.dart"; then
    echo "ORPHAN: $f"
  fi
done

# 2. Trova nomi duplicati in directory diverse
find lib -name "*.dart" -exec basename {} \; | sort | uniq -d

# 3. Trova file con pattern sospetti
find lib -name "*.dart" | grep -E "(old_|temp_|deprecated_|_backup)"
```

### File da creare
- `.claude/scripts/health-check.sh`
- `.claude/commands/cleanup.md`

---

## Parte 3: Rules Enforcer

### Obiettivo
Bloccare automaticamente le modifiche che violano le regole del progetto.

### Regole da enforciare
| Regola | Pattern Vietato | Pattern Corretto |
|--------|-----------------|------------------|
| Icone | `Icons.*` | `AppIcons.*` |
| Colori | `Colors.*` | `context.colors.*` |
| Testi | `'Hardcoded'` | `context.l10n.*` |
| Loading | `CircularProgressIndicator` | `LoadingIndicator()` |
| Snackbar | `ScaffoldMessenger` | `SnackBarService.*` |

### Output atteso (quando blocca)
```
⛔ BLOCKED by FitLog Rules Enforcer:
   Line 42: Icons.delete → usa AppIcons.delete
   Line 42: Colors.red → usa context.colors.error
   Line 43: 'Elimina' → usa context.l10n.delete

   Correggo automaticamente? [Y/n]
```

### Implementazione
```json
// .claude/settings.local.json - aggiungere
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": ".claude/scripts/check-fitlog-rules.sh"
      }
    ]
  }
}
```

```bash
#!/bin/bash
# .claude/scripts/check-fitlog-rules.sh

content=$(cat)
errors=""

# Check Icons.*
if echo "$content" | grep -E "Icons\.[a-z]" | grep -v "AppIcons"; then
  errors+="❌ Usa AppIcons.* invece di Icons.*\n"
fi

# Check Colors.*
if echo "$content" | grep -E "Colors\.[a-z]"; then
  errors+="❌ Usa context.colors.* invece di Colors.*\n"
fi

# Check stringhe hardcoded
if echo "$content" | grep -E "Text\(['\"][A-Z]"; then
  errors+="❌ Usa context.l10n.* invece di stringhe hardcoded\n"
fi

# Check CircularProgressIndicator
if echo "$content" | grep "CircularProgressIndicator"; then
  errors+="❌ Usa LoadingIndicator() invece di CircularProgressIndicator\n"
fi

if [ -n "$errors" ]; then
  echo -e "⛔ FitLog Rules Violations:\n$errors"
  exit 1
fi
exit 0
```

### File da creare
- `.claude/scripts/check-fitlog-rules.sh`
- Modificare `.claude/settings.local.json`

---

## Parte 4: Smart Command Suggester

### Obiettivo
Suggerire l'agente/comando giusto in base alla richiesta.

### Output atteso
```
Tu: /fitlog debug del timer che non si ferma in background

🎯 FitLog Copilot suggerisce:

Per "debug timer background" la combo migliore è:

1. 🥇 timer-live-activity-specialist (agente)
   → Specializzato in timer + iOS background

2. 🥈 /bug-detective (comando)
   → Debugging sistematico generico

3. 🥉 ios-specialist (agente)
   → Se il problema è specifico iOS native

💡 Consiglio: Inizia con timer-live-activity-specialist
```

### Mappa agenti/comandi

**Agenti:**
| Agente | Quando usarlo |
|--------|---------------|
| flutter-architect | Nuove feature, architettura, Clean Architecture |
| flutter-debugger | Errori runtime, crash, problemi widget |
| ios-specialist | Live Activities, background tasks, Swift |
| timer-live-activity-specialist | Timer, notifiche, lock screen |
| firebase-expert | Firestore, auth, sync, security rules |
| performance-optimizer | Rebuild, memoria, batteria |
| fitness-domain-expert | Programmazione allenamenti, esercizi |
| localization-guardian | Traduzioni, i18n |
| flutter-test-engineer | Test, mocking, coverage |

**Comandi:**
| Comando | Quando usarlo |
|---------|---------------|
| /bug-detective | Debugging sistematico |
| /optimize | Performance analysis |
| /audit | Security audit |
| /code-review-assistant | Review codice |
| /sync-docs | Sincronizza documentazione |
| /cleanup | Trova file zombie |
| /fitlog | Non sai cosa usare |

### File da creare
- `.claude/commands/fitlog.md`

---

## Piano di Implementazione

### Fase 1: Setup base (priorità alta)
1. Creare `.claude/scripts/` directory structure
2. Implementare `check-fitlog-rules.sh` (Parte 3)
3. Aggiornare `settings.local.json` con hook PreToolUse

### Fase 2: Health monitoring (priorità media)
4. Implementare `health-check.sh` (Parte 2)
5. Creare comando `/cleanup`

### Fase 3: Context & discoverability (priorità media)
6. Implementare `gather-context.sh` (Parte 1)
7. Creare comando `/fitlog` (Parte 4)

### Fase 4: Polish
8. Testare tutti i componenti
9. Documentare in CLAUDE.md
10. Creare `/fitlog-help` per reference rapido

---

## Dipendenze

- `episodic-memory` plugin (già installato)
- `jq` per parsing JSON (già disponibile)
- Bash 4+ per script avanzati

---

## Rischi e Mitigazioni

| Rischio | Mitigazione |
|---------|-------------|
| Hook troppo lento | Cache risultati, esegui async |
| Falsi positivi nelle regole | Pattern regex più precisi, whitelist |
| Context troppo lungo | Limita a ultimi 5 commit/3 sessioni |

---

## Riferimenti

- [Claude Code Best Practices - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Manage Claude's Memory](https://code.claude.com/docs/en/memory)
