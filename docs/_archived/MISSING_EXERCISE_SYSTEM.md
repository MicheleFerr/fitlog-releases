# 🏋️ Sistema di Richiesta Esercizi Mancanti

## 📋 Panoramica

Sistema completo per permettere agli utenti di richiedere esercizi mancanti nel database e agli admin di gestire queste richieste.

## 🎯 Funzionalità

### Per gli Utenti

1. **Ricerca Esercizio**
   - Durante la ricerca, se non trovano l'esercizio
   - Widget in fondo ai risultati: "Non trovi l'esercizio?"

2. **Aggiunta Temporanea**
   - Dialog per inserire il nome dell'esercizio
   - Generazione automatica ID: `nome_esercizio_temp`
   - Esercizio temporaneo aggiunto immediatamente al workout
   - Segnalazione automatica inviata a Firebase

3. **Feedback Immediato**
   - Conferma tramite SnackBar
   - Pulsante rapido per aggiungere al workout

### Per gli Admin

1. **Dashboard Dedicata**
   - Accessibile da Admin Dashboard → "Esercizi Mancanti"
   - 4 filtri: In Attesa, Approvate, Completate, Rifiutate
   - Contatori per ogni stato

2. **Gestione Richieste**
   - **Pending**: Approva o Rifiuta con motivo
   - **Approved**: Segna come completato dopo aver aggiunto l'esercizio
   - **Rejected/Completed**: Solo visualizzazione

## 🏗️ Architettura

### File Creati

```
lib/
├── features/
│   ├── exercise_database/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── missing_exercise_request.dart  # Modello richiesta
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── missing_exercise_service.dart  # Service Firebase
│   │   └── presentation/
│   │       └── providers/
│   │           └── missing_exercise_provider.dart # Riverpod providers
│   └── admin/
│       └── presentation/
│           └── screens/
│               └── missing_exercises_requests_screen.dart  # Dashboard admin

docs/
└── MISSING_EXERCISE_SYSTEM.md  # Questo file
```

### File Modificati

- `exercise_search_screen.dart`: Aggiunto widget e dialog
- `admin_quick_actions.dart`: Aggiunta card nella dashboard
- `firestore.rules`: Aggiunte regole di sicurezza

## 📊 Struttura Dati Firebase

### Collezione: `missing_exercise_requests`

```typescript
{
  id: string,                    // Auto-generato da Firestore
  exerciseName: string,          // "Bulgarian Split Squat"
  exerciseId: string,            // "bulgarian_split_squat_temp"
  userId: string,                // UID utente richiedente
  requestedAt: Timestamp,        // Data richiesta
  status: 'pending' | 'approved' | 'rejected' | 'completed',
  adminNotes?: string,           // Note dell'admin
  reviewedAt?: Timestamp,        // Data revisione
  reviewedBy?: string           // UID admin che ha revisionato
}
```

## 🔐 Regole di Sicurezza

```javascript
match /missing_exercise_requests/{requestId} {
  // Lettura: proprie richieste o admin
  allow read: if auth.uid == resource.data.userId || isAdmin();

  // Creazione: solo per se stessi, sempre pending
  allow create: if auth.uid == request.resource.data.userId
                && request.resource.data.status == 'pending';

  // Update: solo admin
  allow update: if isAdmin();

  // Delete: solo admin
  allow delete: if isAdmin();
}
```

## 🔄 Workflow

### 1. Utente Richiede Esercizio

```dart
// ExerciseSearchScreen
_showAddTemporaryExerciseDialog()
  ↓
_generateExerciseId("Nome Esercizio")  // → "nome_esercizio_temp"
  ↓
Crea Exercise temporaneo con id_temp
  ↓
Aggiunge a _selectedExercises
  ↓
_sendMissingExerciseReport()
  ↓
MissingExerciseService.submitRequest()
  ↓
Firebase: crea documento in pending
  ↓
SnackBar conferma
```

### 2. Admin Gestisce Richiesta

```dart
// MissingExercisesRequestsScreen
Pending requests stream
  ↓
Admin clicca "Approva"
  ↓
Dialog conferma
  ↓
Service.approveRequest()
  ↓
Status → approved
  ↓
[Admin aggiunge esercizio manualmente]
  ↓
Admin clicca "Segna come Completato"
  ↓
Service.markAsCompleted()
  ↓
Status → completed
```

## 🚀 Prossimi Passi

### Da Implementare

1. **Notifiche Push**
   - Notifica admin quando nuova richiesta
   - Notifica utente quando approvata/rifiutata

2. **Integrazione Database**
   - Link diretto all'editor esercizi dalla richiesta approvata
   - Pre-compilazione nome esercizio

3. **Statistiche**
   - Dashboard con statistiche richieste
   - Utenti più attivi
   - Esercizi più richiesti

4. **Duplicati**
   - Check automatico duplicati
   - Suggerimenti esercizi simili

## 📱 Test

### Test User Flow

1. Apri app → Cerca Esercizio
2. Cerca "Bulgarian Split Squat" (non esiste)
3. Scroll in fondo → "Non trovi l'esercizio?"
4. Clicca "Aggiungi esercizio temporaneo"
5. Inserisci nome → Conferma
6. Verifica SnackBar conferma
7. Verifica esercizio selezionato
8. Aggiungi a workout

### Test Admin Flow

1. Login come admin
2. Admin Dashboard → "Esercizi Mancanti"
3. Verifica richiesta in "In Attesa"
4. Clicca "Approva"
5. Aggiungi esercizio completo al database manualmente
6. Clicca "Segna come Completato"
7. Verifica in "Completate"

## 🔍 Troubleshooting

### Richiesta non appare in Firebase

- Verifica autenticazione utente
- Check console per errori
- Verifica regole Firestore

### Admin non vede richieste

- Verifica token admin
- Check email in regole Firestore
- Refresh provider

### Esercizio temporaneo non funziona

- ID deve finire con `_temp`
- Tutti i campi required devono essere compilati
- Check console per errori creazione Exercise

## 📝 Note Tecniche

- **Performance**: Query ottimizzate con indici Firestore
- **Offline**: Funziona con cache Firestore
- **Sicurezza**: Regole impediscono modifiche non autorizzate
- **Scalabilità**: Supporta migliaia di richieste
- **UX**: Feedback immediato, non blocca l'utente

---

**Generato**: 5 Ottobre 2025
**Versione**: 1.0.0
**Autore**: Claude Code
