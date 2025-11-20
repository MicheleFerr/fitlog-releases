# 🗺️ Mappa Completa Sistemi di Feedback - GymBro

> **Documento Creato**: 2025-01-19
> **Scopo**: Mappare TUTTI i punti dove gli utenti possono segnalare problemi nell'app

---

## 📊 Riepilogo Rapido

**Totale Sistemi di Feedback**: 7
**Collezioni Firebase**: 5 (`ai_coach_feedback`, `analytics_page_feedback`, `exercise_feedback`, `buddy_reports`, `userFeedback`)
**File UI Coinvolti**: 7 widget principali
**Dashboard Admin**: ✅ Disponibile per review

---

## 🎯 Sistema #1: Exercise Database Feedback (CRITICO - ESERCIZI)

### Dove si trova nell'app:
- **Widget**: `lib/features/exercise_database/presentation/widgets/exercise_card_feedback.dart`
- **UI Trigger**: Icona flag 🚩 sulle exercise card (in search, detail, workout creation)

### Cosa può segnalare l'utente:
1. 🐛 **BUG** - Problemi funzionali
2. 💡 **SUGGESTION** - Idee di miglioramento
3. 📝 **TYPO** - Errori di testo/spelling
4. ❓ **OTHER** - Altro

### Dove arriva:
```
Firebase Firestore → Collection: exercise_feedback
```

### Struttura Dati:
```json
{
  "userId": "user_xyz123",
  "userEmail": "user@example.com",
  "exerciseId": "bench_press_001",
  "exerciseName": "Barbell Bench Press",
  "version": "0.1.0",
  "feedbackType": "BUG",
  "message": "Video shows incorrect grip width",
  "severity": 2,
  "createdAt": "2025-01-15T14:30:00Z",
  "status": "OPEN",
  "adminNotes": null
}
```

### Flow Completo:
```
Utente vede esercizio
    ↓
Clicca icona 🚩
    ↓
Dialog si apre (mostra info esercizio)
    ↓
Seleziona tipo (BUG/SUGGESTION/TYPO/OTHER)
    ↓
Scrive descrizione (minimo 3 righe)
    ↓
Submit → Scrive diretto su Firestore
    ↓
Documento creato con status "OPEN"
    ↓
Admin vede in dashboard (lib/features/admin/)
```

### Sicurezza (firestore.rules):
- ✅ Qualsiasi utente autenticato può leggere
- ✅ Solo il creator può creare (userId match)
- ❌ Nessuno può modificare dopo creazione (solo admin)
- ❌ Solo admin può eliminare

### File Chiave:
- UI: `lib/features/exercise_database/presentation/widgets/exercise_card_feedback.dart:412-427`
- Admin: `lib/features/admin/presentation/screens/exercise_feedback_screen.dart`
- Admin Detail: `lib/features/admin/presentation/screens/feedback_detail_screen.dart`

---

## 🤖 Sistema #2: AI Coach Insights Feedback

### Dove si trova nell'app:
- **Widget**: `lib/features/ai_coach/presentation/widgets/feedback_buttons.dart`
- **UI Trigger**: Bottoni 👍 Helpful / 👎 Not Helpful sotto ogni insight AI

### Dove arriva:
```
Firebase Firestore → Collection: ai_coach_feedback
```

### Struttura Dati:
```json
{
  "insightId": "insight_123",
  "insightType": "workout_optimization",
  "insightCategory": "performance",
  "feedbackType": "notHelpful",
  "dismissReason": "incorrect",
  "comment": "La raccomandazione non si applica al mio caso",
  "timestamp": "2025-01-15T14:30:00Z",
  "viewDurationSeconds": 45
}
```

### Dismiss Reasons (se 👎):
- `alreadyKnow` - Lo sapevo già
- `notRelevant` - Non rilevante
- `incorrect` - Informazione sbagliata
- `tooAdvanced` - Troppo avanzato
- `tooBasic` - Troppo semplice
- `notInterested` - Non interessato
- `other` - Altro

### Flow:
```
Utente vede insight AI
    ↓
Clicca 👍 o 👎
    ↓
Se 👎 → Dialog "Perché non è utile?"
    ↓
Seleziona ragione + commento opzionale
    ↓
Submit → Provider (feedbackProvider)
    ↓
Salvato in ai_coach_feedback
```

### File Chiave:
- Buttons: `lib/features/ai_coach/presentation/widgets/feedback_buttons.dart`
- Dialog: `lib/features/ai_coach/presentation/widgets/dismiss_reason_dialog.dart`
- Provider: `lib/features/ai_coach/presentation/providers/feedback_provider.dart`
- Repository: `lib/features/ai_coach/data/repositories/feedback_repository.dart`
- Entity: `lib/features/ai_coach/domain/entities/feedback_data.dart`

---

## 📈 Sistema #3: Analytics Page Feedback

### Dove si trova nell'app:
- **Widget**: `lib/features/analytics/presentation/widgets/analytics_feedback_widget.dart`
- **UI Trigger**: Form inline sulla pagina Analytics (NON dialog)

### Regole di Eligibilità (Gating):
- ✅ Account vecchio ≥ 7 giorni
- ✅ ≥ 10 workout completati
- ✅ Nessun feedback negli ultimi 30 giorni

### Dove arriva:
```
Firebase Firestore → Collection: analytics_page_feedback
```

### Struttura Dati:
```json
{
  "userId": "user_xyz123",
  "isHelpful": true,
  "comment": "Mi piace vedere i grafici di progresso",
  "timestamp": "2025-01-15T14:30:00Z",
  "lastViewedSection": "monthly_stats",
  "totalWorkoutsViewed": 15
}
```

### UX Flow:
```
Form appare (se eligibile)
    ↓
Utente clicca 👍 o 👎
    ↓
Campo testo slide down (opzionale)
    ↓
Submit → Provider (analyticsFeedbackNotifierProvider)
    ↓
Salvato in analytics_page_feedback
```

### File Chiave:
- Widget: `lib/features/analytics/presentation/widgets/analytics_feedback_widget.dart`
- Dialog: `lib/features/analytics/presentation/widgets/feedback_submission_dialog.dart`
- Provider: `lib/features/analytics/presentation/providers/analytics_feedback_provider.dart`
- Entity: `lib/features/analytics/domain/entities/analytics_page_feedback.dart`

---

## 👥 Sistema #4: Buddy Matching - Report User

### Dove si trova nell'app:
- **Widget**: `lib/features/buddy_matching/presentation/widgets/enhanced/report_user_dialog.dart`
- **UI Trigger**: Menu sul profilo buddy → "Report User"

### Motivi di Segnalazione:
1. Inappropriate Photos
2. Harassment
3. Spam
4. Fake Profile
5. Underage
6. Other

### Dove arriva:
```
Firebase Firestore → Collection: buddy_reports
```

### Struttura Dati:
```json
{
  "reporterId": "user_xyz123",
  "targetUserId": "reported_user_456",
  "targetUserName": "John Doe",
  "reason": "HARASSMENT",
  "description": "Messaggi offensivi ripetuti",
  "timestamp": "2025-01-15T14:30:00Z"
}
```

### Sicurezza:
- ✅ `reporterId` validato (DEVE matchare auth.uid)
- ✅ Solo reporter può leggere i propri report
- ❌ Nessuna modifica dopo creazione

### Success Message:
> "Utente segnalato. Grazie per aver reso GymBro più sicuro."

---

## 💬 Sistema #5: User General Feedback

### Dove si trova:
- **Entity**: `lib/features/feedback/domain/entities/user_feedback.dart`
- **Repository**: `lib/features/feedback/data/repositories/firebase_feedback_repository.dart`

### Categorie:
- `bug` - Bug report
- `feature` - Richiesta feature
- `improvement` - Miglioramento
- `praise` - Complimento
- `other` - Altro

### Status Lifecycle:
```
newFeedback → reviewed → resolved/dismissed
```

### Dove arriva:
```
Firebase Firestore → Collection: userFeedback
```

### Struttura Dati:
```json
{
  "userId": "user_xyz123",
  "message": "Sarebbe utile avere grafici settimanali",
  "category": "feature",
  "status": "newFeedback",
  "rating": 4,
  "userEmail": "user@example.com",
  "userDisplayName": "Michele",
  "deviceInfo": "iPhone 15 Pro - iOS 17.2",
  "appVersion": "1.2.3",
  "screenshotUrl": null
}
```

---

## 📜 Sistema #6: Insight Feedback History

### Dove si trova nell'app:
- **Widget**: `lib/features/home/presentation/widgets/feedback_history_modal.dart`
- **UI Trigger**: Home screen menu → "My Feedback"

### Scopo:
Mostrare all'utente la cronologia dei suoi feedback AI (👍👎)

### Cosa mostra:
- Rating (👍/👎 con colore verde/rosso)
- Data/ora submission
- Tipo di insight
- Commento utente

### Data Source:
```
Firebase Stream → ai_coach_feedback (filtrato per userId)
```

### Provider:
```dart
userFeedbackListProvider // Stream<List<FeedbackData>>
```

---

## 🛡️ Sistema #7: Admin Feedback Dashboard

### Dove si trova:
- **Screen**: `lib/features/admin/presentation/screens/exercise_feedback_screen.dart`
- **Detail**: `lib/features/admin/presentation/screens/feedback_detail_screen.dart`

### Operazioni Admin:
1. ✅ View all feedback (filtri: status, severity)
2. ✅ Update status (OPEN → REVIEWING → RESOLVED/DISMISSED)
3. ✅ Add adminNotes (spiegazione)
4. ✅ Change severity (1-5)
5. ✅ View reporter info

### Repository Admin:
```dart
lib/features/admin/data/repositories/feedback_repository.dart
```

---

## 🔒 Firestore Security Rules Summary

```javascript
// Exercise Feedback
match /exercise_feedback/{feedbackId} {
  allow read: if request.auth != null; // Anyone authenticated
  allow create: if request.auth.uid == request.resource.data.userId;
  allow delete: if isAdmin(); // Only admin
  allow update: if false; // No modifications after creation
}

// Analytics Page Feedback
match /analytics_page_feedback/{feedbackId} {
  allow read: if isOwner(feedbackId);
  allow create: if request.auth.uid == request.resource.data.userId;
  allow update: if isOwner(feedbackId);
}

// Buddy Reports
match /buddy_reports/{reportId} {
  allow read: if isReporter(reportId);
  allow create: if request.auth.uid == request.resource.data.reporterId;
  // No updates/deletes after creation
}
```

---

## 📊 Tabella Riassuntiva Collezioni

| Collection | Scopo | Creatore | Admin Review | Key Fields |
|------------|-------|----------|--------------|------------|
| `exercise_feedback` | Segnalazioni esercizi | User | ✅ Sì | exerciseId, feedbackType, message, status |
| `ai_coach_feedback` | Rating insight AI | User | ⚠️ Solo stats | insightId, feedbackType, dismissReason |
| `analytics_page_feedback` | Feedback analytics | User (gated) | ⚠️ Solo stats | isHelpful, comment |
| `buddy_reports` | Segnalazioni profili | User | ✅ Sì | reporterId, targetUserId, reason |
| `userFeedback` | Feedback generale | User | ✅ Sì | message, category, status |

---

## 🎯 Punti di Attenzione

### ⚠️ Problemi Potenziali:

1. **Exercise Feedback - Scrittura Diretta**
   - File: `exercise_card_feedback.dart:412-427`
   - Issue: Scrive diretto su Firestore (no repository pattern)
   - Fix consigliato: Creare `ExerciseFeedbackRepository`

2. **Multiple Feedback Systems**
   - 5 collezioni Firebase diverse
   - Potrebbe confondere utenti: "dove segnalo X?"
   - Suggerimento: Unificare in single "feedback" collection con `type` field

3. **Nessun Email Notification**
   - Admin non riceve email quando arriva nuovo feedback
   - Deve controllare manualmente dashboard
   - Fix: Cloud Function per email notification

4. **Feedback History Only for AI**
   - Solo AI insights hanno cronologia visibile (`feedback_history_modal.dart`)
   - Exercise feedback non ha cronologia utente
   - Suggerimento: Unified feedback history screen

---

## 🔧 File Reference Completo

### UI Entry Points (7):
1. `lib/features/ai_coach/presentation/widgets/feedback_buttons.dart`
2. `lib/features/ai_coach/presentation/widgets/dismiss_reason_dialog.dart`
3. `lib/features/analytics/presentation/widgets/analytics_feedback_widget.dart`
4. `lib/features/analytics/presentation/widgets/feedback_submission_dialog.dart`
5. `lib/features/exercise_database/presentation/widgets/exercise_card_feedback.dart`
6. `lib/features/buddy_matching/presentation/widgets/enhanced/report_user_dialog.dart`
7. `lib/features/home/presentation/widgets/feedback_history_modal.dart`

### Repositories (3):
1. `lib/features/ai_coach/data/repositories/feedback_repository.dart`
2. `lib/features/feedback/data/repositories/firebase_feedback_repository.dart`
3. `lib/features/admin/data/repositories/feedback_repository.dart`

### Entities (3):
1. `lib/features/ai_coach/domain/entities/feedback_data.dart`
2. `lib/features/feedback/domain/entities/user_feedback.dart`
3. `lib/features/analytics/domain/entities/analytics_page_feedback.dart`

### Providers (3):
1. `lib/features/ai_coach/presentation/providers/feedback_provider.dart`
2. `lib/features/analytics/presentation/providers/analytics_feedback_provider.dart`
3. `lib/features/home/presentation/providers/insight_feedback_provider.dart`

### Admin Screens (2):
1. `lib/features/admin/presentation/screens/exercise_feedback_screen.dart`
2. `lib/features/admin/presentation/screens/feedback_detail_screen.dart`

---

## 🚀 Prossimi Passi Consigliati

### Priority 1 - Unificazione:
- [ ] Creare `UnifiedFeedbackService` che gestisce tutti i tipi
- [ ] Single collection `feedback` con campo `type` (exercise/ai/analytics/buddy/general)
- [ ] Unified feedback history screen per utenti

### Priority 2 - Notifiche:
- [ ] Cloud Function per email admin su nuovo feedback
- [ ] Push notification in-app per admin
- [ ] Slack/Discord webhook integration (opzionale)

### Priority 3 - UX:
- [ ] Feedback success animation più evidente
- [ ] "Thank you" screen dopo submission
- [ ] Mostrare cronologia feedback utente (non solo AI)

---

**Documento aggiornato**: 2025-01-19
**Autore**: Claude Code (AI Assistant)
**Versione**: 1.0
