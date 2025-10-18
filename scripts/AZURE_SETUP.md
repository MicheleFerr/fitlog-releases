# 🌐 Setup Azure Translator (GRATUITO)

## 💚 Perché Azure?

- ✅ **2M caratteri GRATIS/mese** (vs 500k DeepL)
- ✅ **Completa TUTTI i 1,500 esercizi gratis**
- ✅ Qualità molto buona
- ✅ Nessuna carta di credito richiesta per iniziare

---

## 📝 Setup Passo per Passo (5 minuti)

### 1️⃣ Crea Account Azure (se non ce l'hai)

1. Vai su: https://azure.microsoft.com/free/
2. Clicca "Start free"
3. Accedi con account Microsoft (o creane uno)
4. **Non serve carta di credito** per servizi gratuiti

### 2️⃣ Crea Risorsa Translator

1. Vai su: https://portal.azure.com
2. Nel menu cerca "Translator" (o vai su https://portal.azure.com/#create/Microsoft.CognitiveServicesTextTranslation)
3. Clicca "Create"
4. Compila il form:
   - **Subscription**: La tua subscription
   - **Resource group**: Crea nuovo (es: "gymbro-translation")
   - **Region**: Scegli "Global" o la più vicina
   - **Name**: Nome a piacere (es: "gymbro-translator")
   - **Pricing tier**: Seleziona **"Free F0"** (2M caratteri/mese)
5. Clicca "Review + create" → "Create"
6. Aspetta ~1 minuto per creazione

### 3️⃣ Ottieni le Chiavi

1. Vai alla risorsa appena creata
2. Nel menu laterale clicca "Keys and Endpoint"
3. Copia **"KEY 1"** (o KEY 2, funzionano entrambe)
4. Copia anche **"Location/Region"** (es: "westeurope" o "global")

### 4️⃣ Configura lo Script

1. Apri: `scripts/translate_with_azure.py`
2. Trova la riga:
   ```python
   AZURE_KEY = "YOUR_KEY_HERE"
   ```
3. Sostituisci con la tua chiave:
   ```python
   AZURE_KEY = "abc123def456..."  # La tua KEY 1
   ```
4. Se necessario, aggiorna anche:
   ```python
   AZURE_LOCATION = "global"  # O la tua location
   ```
5. Salva il file

### 5️⃣ Installa Dipendenze

```bash
pip3 install requests
```

### 6️⃣ Esegui Traduzione

```bash
python3 scripts/translate_with_azure.py
```

---

## 📊 Cosa Aspettarsi

- ⏱️  **Tempo**: ~30-60 minuti per 1,500 esercizi
- 💾 **Output**: `assets/data/exercises_it.json`
- 💰 **Costo**: €0 (dentro quota gratuita)
- 📈 **Progresso**: Salvato ogni batch (50 esercizi)

---

## ⚠️ Troubleshooting

### Errore: "Subscription key is not valid"
- Verifica di aver copiato KEY 1 correttamente
- Assicurati non ci siano spazi prima/dopo la chiave

### Errore: "Resource not found"
- Verifica che `AZURE_LOCATION` corrisponda alla region della risorsa
- Prova a usare "global" se non sei sicuro

### Errore: "Quota exceeded"
- Impossibile con piano FREE (2M chars/mese)
- Se succede, controlla di non aver esaurito quota mensile

---

## 🎯 Dopo la Traduzione

1. ✅ Verifica qualità in `exercises_it.json`
2. 🔧 Post-processing automatico (Step → Passo)
3. 📤 Import su Firestore (opzionale)

---

## 💡 Risorse Utili

- Azure Portal: https://portal.azure.com
- Documentazione: https://docs.microsoft.com/azure/cognitive-services/translator/
- Monitoring quota: Azure Portal → Your Translator → Metrics

---

**Pronto per iniziare?** Segui gli step sopra e poi esegui lo script!
