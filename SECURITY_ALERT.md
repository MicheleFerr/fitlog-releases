# 🚨 SECURITY ALERT - AZIONI IMMEDIATE RICHIESTE

## ⛔ CRITICO: Service Account Key Compromessa

### Azioni completate:
1. ✅ Rimossa chiave esposta da `scripts/service-account-key.json`
2. ✅ Aggiornato `.gitignore` per prevenire future esposizioni
3. ✅ Creato template sicuro in `scripts/service-account-key.json.template`

### ⚠️ AZIONI IMMEDIATE DA FARE (MANUALMENTE):

#### 1. 🔴 REVOCA IMMEDIATA della chiave compromessa:
```bash
# VAI SUBITO su Google Cloud Console:
# https://console.cloud.google.com/iam-admin/serviceaccounts
# 
# Project: gymprogressapp-184bc
# Service Account: gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com
# Key ID: 8a7da7343cdd6a07bbf03862a887318efcdae140
#
# STEPS:
# 1. Trova il service account
# 2. Clicca su "Keys" 
# 3. Elimina la chiave con ID: 8a7da7343cdd6a07bbf03862a887318efcdae140
# 4. Crea una NUOVA chiave
```

#### 2. 🔴 PULISCI Git History (se il repo è pubblico):
```bash
# Installa BFG Repo-Cleaner
brew install bfg

# Rimuovi TUTTI i riferimenti alla chiave dalla history
bfg --delete-files service-account-key.json
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

#### 3. 🟡 Configura le credenziali in modo sicuro:
```bash
# Opzione A: Environment Variables
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/new/service-account-key.json"

# Opzione B: CI/CD Secrets (GitHub Actions)
# Settings → Secrets → Add secret → SERVICE_ACCOUNT_KEY

# Opzione C: Secret Manager (Google Cloud)
gcloud secrets create service-account-key \
  --data-file="/path/to/new/service-account-key.json"
```

#### 4. 🟡 Audit di sicurezza:
- Controlla i log di Google Cloud per accessi non autorizzati
- Verifica che nessun dato sia stato compromesso
- Controlla fatturazione per uso anomalo delle API

## 📋 Checklist Post-Incident:
- [ ] Chiave vecchia REVOCATA su Google Cloud Console
- [ ] Nuova chiave generata e salvata in modo sicuro
- [ ] Git history pulita (se pubblico)
- [ ] Environment variables configurate
- [ ] Team notificato dell'incidente
- [ ] Log di accesso verificati
- [ ] Monitoring attivato per futuri alert

## 🔒 Best Practices per il futuro:
1. **MAI** committare service account keys
2. Usa **Secret Manager** o **Environment Variables**
3. Rotazione chiavi ogni 90 giorni
4. Usa chiavi con permessi minimi necessari
5. Attiva alert per accessi anomali

---

**Data Incidente**: 2025-08-14
**Severity**: CRITICAL
**Status**: IN PROGRESS - Richiede azione manuale immediata