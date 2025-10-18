# 🚨 SECURITY INCIDENT RESPONSE - Service Account Key Exposure

**Data Scoperta**: 2025-10-13
**Severità**: CRITICAL
**Status**: 🔴 RICHIEDE AZIONE IMMEDIATA

---

## 🔥 Problema Identificato

Il file `scripts/service-account-key.json` contenente la **Firebase Admin SDK private key** è stato committato su Git.

**File Compromesso**:
- Path: `scripts/service-account-key.json`
- Project: `gymprogressapp-184bc`
- Service Account: `gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com`
- Private Key ID: `8a7da7343cdd6a07bbf03862a887318efcdae140`

---

## ⚠️ AZIONI IMMEDIATE (ENTRO 1 ORA)

### Step 1: Revoca la Service Account Key Compromessa

```bash
# Vai su Firebase Console
https://console.firebase.google.com/project/gymprogressapp-184bc/settings/serviceaccounts/adminsdk

# Oppure usa gcloud CLI
gcloud iam service-accounts keys delete 8a7da7343cdd6a07bbf03862a887318efcdae140 \
  --iam-account=gym-bro-sheets-writer@gymprogressapp-184bc.iam.gserviceaccount.com
```

### Step 2: Genera Nuova Service Account Key

1. Vai su [Firebase Console](https://console.firebase.google.com/)
2. **Project Settings** → **Service Accounts**
3. Click **Generate New Private Key**
4. Salva come `scripts/serviceAccountKey.json` (SOLO LOCALMENTE)

### Step 3: Aggiungi al .gitignore

```bash
# Aggiungi questa riga al .gitignore
echo "scripts/serviceAccountKey.json" >> .gitignore
echo "scripts/service-account-key.json" >> .gitignore
echo "**/serviceAccountKey*.json" >> .gitignore
```

### Step 4: Rimuovi dalla Storia Git

⚠️ **ATTENZIONE**: Questo riscrive la storia Git. Coordina con il team!

```bash
# Metodo 1: git filter-repo (raccomandato)
git filter-repo --invert-paths --path scripts/service-account-key.json

# Metodo 2: BFG Repo Cleaner (alternativa)
bfg --delete-files service-account-key.json
git reflog expire --expire=now --all && git gc --prune=now --aggressive

# Metodo 3: git filter-branch (legacy)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch scripts/service-account-key.json" \
  --prune-empty --tag-name-filter cat -- --all
```

### Step 5: Force Push (se necessario)

⚠️ **Solo se il repository è condiviso!**

```bash
git push origin --force --all
git push origin --force --tags
```

### Step 6: Notifica il Team

Se il repository è condiviso:
1. Avvisa tutti i collaboratori
2. Chiedi di fare `git pull --rebase` dopo il force push
3. Verifica che nessuno abbia copie locali della vecchia key

---

## 🔒 AZIONI PREVENTIVE (ENTRO 24 ORE)

### 1. Audit dei Log Firebase

```bash
# Controlla accessi sospetti negli ultimi 30 giorni
# Firebase Console → Authentication → Usage
# Firebase Console → Firestore → Usage

# Cerca operazioni anomale:
# - Bulk data exports
# - Admin claim modifications non autorizzate
# - Accessi da IP non riconosciuti
```

### 2. Rotation di Altre Credenziali (se necessario)

Se sospetti che altre credenziali siano compromise:
- [ ] OAuth Client Secrets (Google Sign-In)
- [ ] Firebase API Keys (già pubbliche, ma verifica App Check)
- [ ] Altri service accounts

### 3. Implementa Monitoring

```javascript
// Cloud Function per monitorare accessi admin SDK
exports.logAdminAccess = functions.auth.user().onCreate((user) => {
  if (user.customClaims?.admin) {
    console.log(`Admin user created: ${user.uid} - ${user.email}`);
    // Send alert to team
  }
});
```

### 4. Setup Git Hooks (Preventivo)

```bash
# Pre-commit hook per bloccare commit di secrets
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Blocca commit di service account keys
if git diff --cached --name-only | grep -qE "serviceAccount|private.*key|service-account"; then
  echo "❌ BLOCKED: Service account key detected!"
  echo "File with sensitive data cannot be committed."
  exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

---

## 📋 CHECKLIST POST-INCIDENT

- [ ] Service account key revocata su Firebase Console
- [ ] Nuova key generata e salvata SOLO localmente
- [ ] `.gitignore` aggiornato con pattern service account
- [ ] File rimosso dalla storia Git con `git filter-repo` o BFG
- [ ] Force push completato (se applicabile)
- [ ] Team notificato (se applicabile)
- [ ] Log Firebase controllati per accessi sospetti
- [ ] Nessuna attività anomala rilevata nei log
- [ ] Pre-commit hook installato per prevenire futuri leak
- [ ] Documentazione aggiornata per il team

---

## 📞 Supporto

Se hai dubbi o serve assistenza:
1. Consulta: [Firebase Security Best Practices](https://firebase.google.com/docs/projects/provisioning/configure-oauth#secure-credentials)
2. GitHub Secret Scanning: https://docs.github.com/en/code-security/secret-scanning
3. Incident response team: security@yourdomain.com

---

**⏰ TIMELINE TARGET**:
- **0-1h**: Step 1-3 (revoca, nuova key, gitignore)
- **1-2h**: Step 4-5 (rimuovi da git, force push)
- **2-24h**: Audit log e preventive measures

**🎯 GOAL**: Key compromessa revocata entro 1 ora dalla scoperta.
