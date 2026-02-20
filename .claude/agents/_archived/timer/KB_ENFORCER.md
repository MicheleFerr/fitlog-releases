# 🚨 KB ENFORCER - Timer Audio System

## OBBLIGATORIO: Workflow per OGNI modifica timer/audio

### 📖 STEP 1: LEGGI LA KB
```bash
# SEMPRE eseguire prima:
cat /docs/TIMER_AUDIO_KB.md
```

### 🔍 STEP 2: VERIFICA SE ESISTE SOLUZIONE
Controlla nella KB:
- Sezione "Problemi Risolti e Soluzioni"
- Sezione "Errori Comuni da Evitare"  
- Sezione "ERRORI CRITICI"

### ⚠️ STEP 3: APPLICA BEST PRACTICES
**MAI violare queste regole dalla KB:**
1. ❌ MAI categorie non registrate
2. ❌ MAI suoni custom in background senza test
3. ❌ MAI fidarsi solo di Timer Dart
4. ❌ MAI modificare senza cancellare audio precedente

### 🛠️ STEP 4: IMPLEMENTA
Se nuova soluzione:
```typescript
// ANNOTARE SEMPRE:
// KB_CHECK: Verificato, non esiste in KB sezione X
// KB_COMPLIANT: Segue best practice Y dalla KB
// KB_UPDATE: Da aggiungere alla KB dopo test
```

### 📝 STEP 5: AGGIORNA KB IMMEDIATAMENTE
```bash
# Dopo OGNI fix che funziona:
1. Aggiungi alla sezione appropriata di TIMER_AUDIO_KB.md
2. Documenta: Problema → Causa → Soluzione → Test
3. Aggiungi alla versione history
```

## 🔴 CHECKLIST PRIMA DI OGNI MODIFICA

- [ ] Ho letto TIMER_AUDIO_KB.md completamente?
- [ ] La soluzione esiste già nella KB?
- [ ] Sto seguendo le best practices documentate?
- [ ] Ho verificato gli "Errori Comuni da Evitare"?
- [ ] Aggiornerò la KB dopo il fix?

## 🚫 VIOLAZIONI CHE CAUSANO REGRESSIONI

1. **Modificare BackgroundAudioManager SENZA leggere KB**
   → Ricreerà bug già risolti

2. **Cambiare categorie notifiche SENZA verificare KB**
   → Audio smetterà di funzionare

3. **Ignorare silent loop strategy documentata**
   → Timer lunghi falliranno

4. **Non documentare nuovi fix**
   → Problema si ripresenterà

## 📊 METRICHE KB

- Fix documentati: 15+
- Regressioni evitate: 8
- Tempo risparmiato: ~20 ore
- Pattern consolidati: 5

## 🎯 COMANDO RAPIDO

```bash
# Prima di OGNI modifica timer:
alias kb-check='cat /docs/TIMER_AUDIO_KB.md | grep -A 10 "CRITICO"'

# Dopo OGNI fix:
alias kb-update='echo "TODO: Update KB with new findings" >> /docs/TIMER_AUDIO_KB.md'
```

---

**REMEMBER**: La KB è la FONTE DI VERITÀ. Ignorarla = ripetere errori già risolti!