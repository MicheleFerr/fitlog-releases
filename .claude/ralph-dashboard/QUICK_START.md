# 🚀 Quick Start - Live Dashboard

## 📺 Avvio Rapido (3 Comandi)

### Terminal 1: Live Dashboard

```bash
cd /Users/michele/gymbro_flutter_new/.claude/ralph-dashboard
./start-live-dashboard.sh
```

**Cosa fa**:
- ✅ Apre dashboard nel browser
- ✅ Monitora git activity ogni 10s
- ✅ Aggiorna status.json automaticamente
- ✅ Dashboard auto-refresh ogni 10s

**Output atteso**:
```
🚀 Starting FitLog Production Readiness Live Dashboard
📊 Opening dashboard in browser...
🔄 Starting real-time monitor...
   Dashboard will auto-refresh every 10 seconds
   Press Ctrl+C to stop

[1] 💤 No recent activity
[2] 💤 No recent activity
[3] 🔨 Ralph active: fix(ui): replace Icons.* with AppIcons.*
[4] 🔨 Ralph active: fix(ui): replace Colors.* with context.colors.*
...
```

---

### Terminal 2: Ralph Loop

```bash
cd /Users/michele/gymbro_flutter_new

/ralph-loop "$(cat .claude/ralph-prompts/production-readiness-check.md)" \
  --max-iterations 50 \
  --completion-promise "PRODUCTION READY"
```

**Cosa fa**:
- ✅ Esegue tutti i 165+ task di PRODUCTION_READINESS.md
- ✅ Commit automatici dopo ogni fix
- ✅ Monitor può vedere i commit in real-time

---

### Browser: Monitor Progress

**URL**: http://localhost:8000 o file://...

**Cosa vedi**:
```
🚀 FitLog Production Readiness Dashboard
[🟢 LIVE]

Total Tasks: 36
Completed: 12 ✅
In Progress: 8 🟠
Blocked: 2 🔴

Overall Progress: [████████░░░░░░░░░░░░] 33%

PRODUCTION_READINESS.md v2.0 | Iteration 15 | Building (Active) | Updated 5s ago
```

**Features**:
- Auto-refresh ogni 10s (no F5 needed!)
- 🟢 LIVE indicator quando attivo
- ⚪ OFFLINE se monitor stopped
- Click section per expand/collapse
- Check manual per testing

---

## 🎯 Workflow HITL Mode (Prime 3-5 Iterazioni)

1. **Avvia live dashboard** (Terminal 1)
2. **Avvia Ralph Loop** (Terminal 2)
3. **Monitora dashboard** (Browser)
4. **Osserva primi fix** di Ralph
5. **Verifica pattern** (Ralph trova Icons.*, Colors.*, etc.)
6. **Dopo 3-5 iter**: Switch to AFK mode

**Tempo stimato**: 15-20 min monitoring

---

## 🚀 Workflow AFK Mode (Iteration 6-50)

1. **Dashboard già aperta** (lasciala in background)
2. **Ralph Loop già running** (no monitor needed)
3. **Check dashboard ogni 30-60 min** (refresh automatico)
4. **Intervieni solo se blockers** (firebase auth, device test)

**Tempo stimato**: 2.5-4h total

---

## 🔧 Troubleshooting

### Monitor non parte

```bash
# Check permissions
chmod +x start-live-dashboard.sh monitor-ralph.sh

# Run with debug
bash -x start-live-dashboard.sh
```

### Dashboard non auto-refresh

- Check console browser (F12)
- Verify status.json exists
- Check "LIVE" indicator (deve essere 🟢)

### Ralph non visto da monitor

- Monitor cerca git commits
- Se Ralph non committa → monitor vede "Idle"
- Normal! Monitor update comunque status ogni 10s

---

## 💡 Pro Tips

### Tip 1: Dual Monitor Setup

- Monitor 1: Dashboard full-screen
- Monitor 2: Terminal con Ralph output

### Tip 2: Screenshots Progress

```bash
# macOS
Cmd+Shift+4 → screenshot dashboard

# Utile per:
# - Demo a stakeholders
# - Before/After comparison
# - Documentation
```

### Tip 3: Pause Monitor

```bash
# In Terminal 1 (monitor):
Ctrl+C  # Stop monitor

# Dashboard rimane aperta, no auto-refresh
# Manual refresh con button ancora funziona
```

### Tip 4: Multiple Runs Comparison

```bash
# Copia dashboard per ogni run
cp -r .claude/ralph-dashboard/ .claude/ralph-run-1/
cp -r .claude/ralph-dashboard/ .claude/ralph-run-2/

# Poi compara progress tra run
diff ralph-run-1/status.json ralph-run-2/status.json
```

---

## 📊 Status Indicators

| Indicator | Significato | Action |
|-----------|-------------|--------|
| 🟢 LIVE | Monitor attivo, auto-refresh ON | Nessuna, tutto OK |
| ⚪ OFFLINE | Monitor stopped o status.json missing | Riavvia monitor |
| ✓ Done | Task completato con successo | Nessuna |
| ⟳ Progress | Task in lavorazione | Attendi prossimo check |
| ⚠ Blocked | Task bloccato, richiede intervento | Review output Ralph |
| ☐ Todo | Task non ancora iniziato | Normale se early iteration |

---

## 🎯 Success Criteria

Dashboard mostra **PRODUCTION READY** quando:

```
✅ Total Tasks: 36
✅ Completed: 36
✅ In Progress: 0
✅ Blocked: 0

✅ Overall Progress: [████████████████████] 100%
```

Ralph Loop output finale:
```
<promise>PRODUCTION READY</promise>
```

**Tempo totale stimato**: 3-4 ore (vs 20-30h manual)

**Cost**: ~$35 USD (Sonnet 4.5)

---

**Last Updated**: 2026-02-02
**Version**: 1.0 (Live Real-Time)
