# 🇮🇹 Traduzione Esercizi - Guida Completa

## 📊 Stato Attuale

- 📦 **1,500 esercizi** in inglese
- 🎯 **Obiettivo**: Tradurli tutti in italiano
- 💰 **Costo**: €0 (usando Azure FREE)
- ⏱️  **Tempo**: ~30-60 minuti

---

## 🏆 Soluzione Scelta: Microsoft Azure Translator

### Perché Azure?

| Servizio | Quota FREE | Costo Extra | Qualità |
|----------|------------|-------------|---------|
| **Azure Translator** ⭐ | 2M chars/mese | €10/1M | ⭐⭐⭐⭐ |
| DeepL | 500k chars/mese | €20/1M | ⭐⭐⭐⭐⭐ |
| Google Cloud | 500k chars/mese | €20/1M | ⭐⭐⭐⭐ |

**Azure = Migliore per questo progetto** (completa tutto gratis!)

---

## 🚀 Quick Start (3 Passi)

### 1️⃣ Setup Azure (5 minuti)

Segui la guida dettagliata: [`AZURE_SETUP.md`](./AZURE_SETUP.md)

**TL;DR:**
1. Vai su https://portal.azure.com
2. Crea risorsa "Translator" (piano FREE)
3. Copia KEY 1

### 2️⃣ Configura Script

```bash
# Apri il file
nano scripts/translate_with_azure.py

# Modifica questa riga:
AZURE_KEY = "LA_TUA_KEY_QUI"

# Salva (Ctrl+X, Y, Enter)
```

### 3️⃣ Test & Traduzione

```bash
# Test connessione (1 minuto)
python3 scripts/test_azure.py

# Se test OK, lancia traduzione completa
python3 scripts/translate_with_azure.py
```

---

## 📁 File Importanti

| File | Descrizione |
|------|-------------|
| `AZURE_SETUP.md` | Guida setup dettagliata |
| `test_azure.py` | Test rapido API |
| `translate_with_azure.py` | Script traduzione completo |
| `fitness_glossary_en_it.json` | Glossario termini fitness |
| `check_progress.sh` | Monitora progresso |

---

## 📊 Durante la Traduzione

Lo script:
- ✅ Salva progresso ogni 50 esercizi
- ✅ Crea backup automatico
- ✅ Mostra percentuale completamento
- ✅ Gestisce errori (riprova automaticamente)

**Output**: `assets/data/exercises_it.json`

---

## 🎯 Dopo la Traduzione

### 1. Verifica Qualità

```bash
# Guarda i primi esercizi tradotti
head -100 assets/data/exercises_it.json
```

### 2. Post-Processing (opzionale)

Alcuni aggiustamenti finali:
- "Fase:" → "Passo:" (già fatto automaticamente)
- Terminologia fitness specifica

### 3. Usa gli Esercizi

L'app Flutter legge già da `exercises_it.json` se presente!

---

## ⚠️ Troubleshooting

### "Subscription key is not valid"
```bash
# Verifica la chiave
cat scripts/translate_with_azure.py | grep AZURE_KEY
```

### "Too many requests"
Impossibile con piano FREE (2M chars/mese = più che sufficiente)

### Script si blocca
```bash
# Ferma processo
pkill -f translate_with_azure

# Riprendi da dove era rimasto (riconosce progresso salvato)
python3 scripts/translate_with_azure.py
```

---

## 📈 Monitoraggio

```bash
# Controlla progresso
bash scripts/check_progress.sh

# Output live durante traduzione
tail -f /tmp/azure_translation.log
```

---

## 💡 Alternative

Se Azure non funziona:

1. **DeepL FREE** (500k chars/mese = ~700 esercizi)
   - Aspetta reset mensile per i restanti

2. **Traduzione Manuale** (Claude AI)
   - Qualità perfetta
   - ~300-400 esercizi per conversazione

3. **DeepL Pro** (€17 one-time)
   - Completa tutto subito

---

## 📞 Supporto

- 📖 Leggi: `AZURE_SETUP.md`
- 🧪 Testa: `python3 scripts/test_azure.py`
- ✅ Verifica: `bash scripts/check_progress.sh`

---

**Pronto?** Inizia con Step 1️⃣ sopra! 🚀
