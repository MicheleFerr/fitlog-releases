# 🔥 Firestore Setup - Analytics Feedback

> **Collection**: `analytics_page_feedback`
> **Setup Required**: Security Rules + Composite Indexes

---

## 📋 Security Rules

Aggiungi queste regole alla Firestore Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Analytics Page Feedback Collection
    match /analytics_page_feedback/{feedbackId} {

      // Users can create their own feedback
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid
                    && feedbackId.matches(request.auth.uid + '_[0-9]+');

      // Users can read their own feedback
      allow read: if request.auth != null
                  && resource.data.userId == request.auth.uid;

      // Users can update their own feedback (within 24 hours)
      allow update: if request.auth != null
                    && resource.data.userId == request.auth.uid
                    && request.time < resource.data.timestamp + duration.value(24, 'h');

      // Users can delete their own feedback
      allow delete: if request.auth != null
                    && resource.data.userId == request.auth.uid;

      // Admin can read all feedback
      allow read: if request.auth != null
                  && request.auth.token.email == 'ferrara-michele@hotmail.it';
    }
  }
}
```

### ⚠️ Note Security Rules:

1. **Create**: Utenti possono creare solo feedback con proprio userId
2. **Read**: Utenti possono leggere solo proprio feedback (admin può leggere tutto)
3. **Update**: Utenti possono modificare feedback entro 24 ore (edge case)
4. **Delete**: Utenti possono eliminare proprio feedback
5. **Admin**: Email `ferrara-michele@hotmail.it` ha accesso completo

---

## 📊 Composite Indexes

Aggiungi questi indexes nella Firestore Console:

### Index 1: By User + Timestamp
```
Collection: analytics_page_feedback
Fields:
  - userId (Ascending)
  - timestamp (Descending)
Query Scope: Collection
```

**Usato da**:
- `getUserLastFeedback(userId)` - Ottieni ultimo feedback utente
- `getUserFeedbackHistory(userId)` - Cronologia feedback

### Index 2: By isHelpful + Timestamp
```
Collection: analytics_page_feedback
Fields:
  - isHelpful (Ascending)
  - timestamp (Descending)
Query Scope: Collection
```

**Usato da**:
- `getAllFeedback(isHelpful: true/false)` - Filtra feedback per tipo (admin)

### Index 3: By Section + Timestamp
```
Collection: analytics_page_feedback
Fields:
  - lastViewedSection (Ascending)
  - timestamp (Descending)
Query Scope: Collection
```

**Usato da**:
- `getFeedbackBySection(section)` - Feedback per sezione specifica (admin)

### Index 4: By Timestamp Range (Optional)
```
Collection: analytics_page_feedback
Fields:
  - timestamp (Ascending)
  - timestamp (Ascending)
Query Scope: Collection
```

**Usato da**:
- `getFeedbackCountInRange(startDate, endDate)` - Range queries (admin analytics)

---

## 🛠️ Setup Instructions

### 1. Accedi a Firestore Console
```
https://console.firebase.google.com/project/YOUR_PROJECT/firestore
```

### 2. Crea Collection (se non esiste)

La collection verrà creata automaticamente al primo feedback, ma puoi crearla manualmente:

1. Click "Start collection"
2. Collection ID: `analytics_page_feedback`
3. Document ID: Auto-generate
4. Aggiungi campo dummy:
   - Field: `dummy`
   - Type: `string`
   - Value: `delete_me`
5. Elimina il documento dummy dopo creazione

### 3. Aggiungi Security Rules

1. Vai su "Rules" tab
2. Copia le rules sopra
3. Aggiungi nella sezione appropriata (dentro `match /databases/{database}/documents`)
4. Click "Publish"

### 4. Crea Composite Indexes

**Metodo A - Automatico (Consigliato)**:
1. Esegui l'app in development
2. Triggera le query che richiedono indexes
3. Firestore ti chiederà di creare l'index automaticamente
4. Click sul link nell'errore → Crea index

**Metodo B - Manuale**:
1. Vai su "Indexes" tab
2. Click "Create Index"
3. Inserisci i dettagli di ogni index sopra
4. Click "Create"

### 5. Verifica Setup

Dopo setup, verifica che:
- ✅ Users possono creare feedback
- ✅ Users possono leggere solo proprio feedback
- ✅ Admin può leggere tutti i feedback
- ✅ Queries non generano errori "Missing Index"

---

## 🧪 Test Security Rules

Puoi testare le rules nella Firestore Console:

```
Rules Playground → Authenticated as: user@example.com

// Test: User can create own feedback
Operation: create
Collection: analytics_page_feedback/{userId}_123
Data: {
  "userId": "{userId}",
  "isHelpful": true,
  "timestamp": Timestamp.now()
}
✅ Should succeed

// Test: User CANNOT create feedback for other user
Operation: create
Collection: analytics_page_feedback/otherUser_123
Data: {
  "userId": "otherUser",
  "isHelpful": true,
  "timestamp": Timestamp.now()
}
❌ Should fail

// Test: Admin can read all
Authenticated as: ferrara-michele@hotmail.it
Operation: read
Collection: analytics_page_feedback
✅ Should succeed
```

---

## 📝 Example Firestore Document

```json
{
  "id": "user123_1698765432000",
  "userId": "user123",
  "isHelpful": true,
  "comment": "Mi piacciono molto i grafici!",
  "timestamp": "2025-10-31T14:30:00.000Z",
  "totalWorkoutsViewed": 42,
  "lastViewedSection": "progress",
  "deviceInfo": null
}
```

---

## ⚠️ Important Notes

1. **Non creare indexes troppo presto**: Aspetta che l'app generi errori "Missing Index" e poi crea solo quelli necessari
2. **Admin email**: Sostituisci `ferrara-michele@hotmail.it` con la tua email admin
3. **Testing**: Testa sempre in environment di sviluppo prima di deployare in produzione
4. **Backup**: Firestore non ha backup automatico, considera Firestore export periodici
5. **Costs**: Ogni query conta, monitora usage nella Firebase Console

---

## 🚀 Next Steps

Dopo setup Firestore:
1. ✅ Test create feedback da app
2. ✅ Verifica feedback salvato correttamente
3. ✅ Test eligibility check (7 giorni + 10 workout)
4. ✅ Test admin dashboard view
5. ✅ Monitor Firestore usage & costs

---

**Setup completato?** Passa alla **Fase 2: UI Widget** 🎨
