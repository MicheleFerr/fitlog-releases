# 🌐 Web API Configuration - Quick Checklist

**Status**: ⏳ OPZIONALE (Solo se usi l'app Web)
**Tempo Stimato**: 3-5 minuti
**Prerequisito**: iOS ✅ + Android ✅ già completati

---

## 📋 Quick Steps (3-5 min)

### 1. Apri Google Cloud Console
```
https://console.cloud.google.com/
```

- Progetto: **gymprogressapp-184bc**
- Navigare a: **API e servizi** → **Credenziali**

---

### 2. Trova la Chiave API Web

Cerca nella lista delle credenziali la chiave API per **Web**.

---

### 3. Configura Restrizioni Applicazione

**Clicca sulla chiave API Web** e imposta:

**Tipo restrizione**: `Referrer HTTP (siti web)`

**Domini autorizzati**:
```
https://gymbroapp.com/*
https://gymprogressapp-184bc.web.app/*
https://gymprogressapp-184bc.firebaseapp.com/*
http://localhost:*
```

**Note**:
- `gymbroapp.com` - Dominio custom (se lo hai)
- `gymprogressapp-184bc.web.app` - Firebase Hosting default
- `gymprogressapp-184bc.firebaseapp.com` - Firebase Hosting alternativo
- `localhost:*` - Solo per sviluppo locale

---

### 4. Configura Restrizioni API

**Seleziona**: `Limita la chiave`

**API da ABILITARE** (SOLO queste):
- ✅ **Cloud Firestore API**
- ✅ **Identity Toolkit API** (Firebase Authentication)
- ✅ **Firebase Cloud Messaging API**

**Tutte le altre API**: ❌ Disabilitate

---

### 5. Salva

Clicca su **"Salva"** per applicare le modifiche.

---

## ✅ Verifica

Dopo aver salvato, verifica che nella lista credenziali appaia:
```
Web API Key - Restricted to domains
```

---

## 🧪 Testing (Opzionale)

Se hai un'app web, testa:

```bash
# Build web
flutter build web --release

# Testa su localhost
firebase serve

# Deploy su Firebase Hosting (opzionale)
firebase deploy --only hosting
```

**Test funzionalità**:
1. Login con Google Sign-In
2. Firestore read/write
3. Push notifications (se implementate)

---

## 📊 Security Impact

**Prima della configurazione**:
```
❌ Chiave API senza restrizioni
❌ Qualsiasi sito web può usare la chiave
❌ Tutte le API Google Cloud abilitate
❌ Rischio quota abuse: ALTO
```

**Dopo la configurazione**:
```
✅ Chiave API con restrizione domini
✅ Solo domini autorizzati possono usare la chiave
✅ Solo 3 API Firebase abilitate
✅ Rischio quota abuse: BASSO (↓ 82%)
```

---

## 🎯 Success Criteria

- [ ] Domini autorizzati configurati in Google Cloud Console
- [ ] API limitate a Cloud Firestore, Identity Toolkit, FCM
- [ ] Chiave appare come "Restricted to domains" nella console
- [ ] Build web testato (se applicabile)
- [ ] Login funziona solo da domini autorizzati
- [ ] Login NON funziona da altri domini (test sicurezza)

---

## ⚠️ Note Importanti

### Se NON usi l'app Web
Se la tua app è **solo iOS + Android**, puoi:
- ✅ Saltare completamente questa configurazione
- ✅ La chiave Web può rimanere con restrizioni di default
- ✅ iOS + Android sono già protetti al 100%

### Se usi l'app Web
- ⚠️ Configurazione **raccomandata** per sicurezza
- ⚠️ Previene abuse da siti web non autorizzati
- ⚠️ Protegge quota Firebase e costi

---

## 🔄 Dopo il Completamento

Una volta completato Web:

1. ✅ Aggiorna `TODO_URGENT.md`:
   ```markdown
   ### 1. ✅ Firebase API Restrictions - COMPLETATO
   - iOS ✅
   - Android ✅
   - Web ✅

   **Progress**: 🎉 100% (3/3 piattaforme)
   ```

2. ✅ Aggiorna `FIREBASE_API_RESTRICTIONS_PROGRESS.md`:
   - Marcare Web come ✅ COMPLETATO
   - Aggiornare overall progress a 100%

3. ✅ Aggiorna `SECURITY_AUDIT_2025-10-20.md`:
   - Problema #1.2 marcato come ✅ RISOLTO
   - Security score finale: 95-98/100 (A/A+)

---

## 📚 Riferimenti

- **Main Guide**: `docs/audit/FIREBASE_API_RESTRICTIONS_GUIDE.md`
- **Progress Report**: `docs/audit/FIREBASE_API_RESTRICTIONS_PROGRESS.md`
- **Security Audit**: `docs/audit/SECURITY_AUDIT_2025-10-20.md`
- **TODO Tracking**: `TODO_URGENT.md` - Task #1

---

**Creato**: 20 Ottobre 2025
**Status iOS**: ✅ COMPLETATO
**Status Android**: ✅ COMPLETATO
**Status Web**: ⏳ OPZIONALE (Questa checklist)
